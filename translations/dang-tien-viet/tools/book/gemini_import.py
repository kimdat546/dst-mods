#!/usr/bin/env python3
"""Nhập ảnh trang sách đã dịch bằng Gemini (hoặc tool AI khác) vào mod.

    python3 tools/book/gemini_import.py xd_info_ys_21 ~/Desktop/anh_gemini.png

Gemini KHÔNG giữ khung hình: ảnh ra thường to hơn, tỉ lệ khác và bị phóng/cắt
(lần đầu: 2752x1536 so với 2048x1300 xuất ra, hạc bị cắt mất). Nên không co
giãn thẳng được. Cách làm:
  1. Dò tỉ lệ + độ lệch khớp ảnh Gemini với ảnh xuất gốc, chỉ so khung sách
     (bỏ ruột trang vì Gemini vẽ lại nội dung ở đó).
  2. Chỉ lấy RUỘT HAI TRANG từ ảnh Gemini; khung sách, hạc, mây giữ ảnh gốc
     (Gemini hay vẽ lại mây/hạc khác đi).
  3. Thu về 1024 như ảnh gốc và ghi .tex (qua page_io.import_).
Ảnh ghép để soát: build/book/<trang>_gemini_check.png
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import page_io  # noqa: E402

# Ruột hai trang trong ảnh xuất 2048x1300 (toạ độ chung cho mọi trang xd_info_*,
# vì mọi trang dùng cùng một nền sách xd_info_0).
PAGES_INNER = [(335, 340, 975, 1195), (985, 340, 1655, 1195)]


def edges(im):
    return np.asarray(im.filter(ImageFilter.FIND_EDGES), dtype=np.float32)


def _masked_ref(ref, D):
    r = edges(ref.resize((ref.width // D, ref.height // D), Image.LANCZOS))
    x0, y0, x1, y1 = (v // D for v in (PAGES_INNER[0][0] + 25, PAGES_INNER[0][1] + 20,
                                        PAGES_INNER[1][2] - 15, PAGES_INNER[1][3] - 25))
    r[y0:y1, x0:x1] = 0
    return r


def _ncc_all(r, t):
    """Tương quan chuẩn hoá của t tại mọi vị trí trong r (FFT). Trả (điểm, x, y)."""
    H, W = r.shape
    h, w = t.shape
    t = t - t.mean()
    cc = np.fft.irfft2(np.fft.rfft2(r) * np.fft.rfft2(t[::-1, ::-1], s=(H, W)), s=(H, W))
    valid = cc[h - 1:H, w - 1:W]
    r = r.astype(np.float64)
    s2 = np.cumsum(np.cumsum(np.pad(r ** 2, ((1, 0), (1, 0))), 0), 1)
    E = s2[h:, w:] - s2[:-h, w:] - s2[h:, :-w] + s2[:-h, :-w]
    n = valid / (np.sqrt(np.maximum(E, 0)) + 1e-6) / np.sqrt((t ** 2).sum())
    # vị trí mà phần ref dưới template gần như trống (vùng ruột trang đã xoá về 0)
    # cho mẫu số ~0 → điểm ảo rất cao; loại bỏ
    n[E < 0.25 * E.max()] = 0
    i = np.unravel_index(np.argmax(n), n.shape)
    return float(n[i]), int(i[1]), int(i[0])


def register_by_paper(gen, ref):
    """Căn theo MÉP GIẤY của cuốn sách (trái/phải ở hàng giữa trang, trên/dưới ở cột
    trang trái). Dùng khi Gemini phóng to + cắt sát quanh sách và kéo méo hai chiều
    khác nhau — tương quan cạnh khi đó cho điểm thấp, dễ khớp nhầm."""
    g = np.asarray(gen.convert('L')).astype(int)
    r = np.asarray(ref.convert('L')).astype(int)

    def span(a, axis):
        prof = (a > 110).mean(axis=axis)
        idx = np.nonzero(prof > 0.6)[0]
        return int(idx.min()), int(idx.max())
    rx = span(r[450:550], 0)
    ry = span(r[:, 500:600], 1)
    gh, gw = g.shape
    gx = span(g[int(gh * 0.2):int(gh * 0.26)], 0)
    gy = span(g[:, int(gw * 0.2):int(gw * 0.23)], 1)
    kx = (rx[1] - rx[0]) / (gx[1] - gx[0])
    ky = (ry[1] - ry[0]) / (gy[1] - gy[0])
    ox = round(rx[0] - gx[0] * kx)
    oy = round(ry[0] - gy[0] * ky)
    print(f'  khớp theo mép giấy: tỉ lệ {kx:.3f} x {ky:.3f}, lệch ({ox}, {oy})')
    return kx, ky, ox, oy


def register(gen, ref):
    """Trả (kx, ky, ox, oy): resize gen theo kx, ky rồi đặt tại (ox, oy) trên ref."""
    gen, ref = gen.convert('L'), ref.convert('L')
    # thô: cùng tỉ lệ hai chiều, mọi vị trí (FFT) ở 1/4 độ phân giải
    D = 4
    r = _masked_ref(ref, D)
    best = (-1,)
    # Gemini có lúc phóng to (cắt bớt quanh sách) → tỉ lệ thu nhỏ có thể tới ~0.3
    for k in np.arange(0.30, 1.001, 0.01):
        w, h = int(gen.width * k / D), int(gen.height * k / D)
        if w > r.shape[1] or h > r.shape[0]:
            continue
        sc, x, y = _ncc_all(r, edges(gen.resize((w, h), Image.LANCZOS)))
        if sc > best[0]:
            best = (sc, k, x * D, y * D)
    _, k, ox, oy = best
    # tinh: tỉ lệ hai chiều riêng (Gemini hay méo nhẹ một chiều), FFT ở 1/2
    D = 2
    r = _masked_ref(ref, D)
    best = (-1,)
    for kx in np.arange(k - 0.03, k + 0.0301, 0.002):
        for ky in np.arange(k - 0.03, k + 0.0301, 0.002):
            w, h = int(gen.width * kx / D), int(gen.height * ky / D)
            if w > r.shape[1] or h > r.shape[0]:
                continue
            sc, x, y = _ncc_all(r, edges(gen.resize((w, h), Image.LANCZOS)))
            if sc > best[0]:
                best = (sc, float(kx), float(ky), x * D, y * D)
    print(f'  khớp: điểm {best[0]:.3f}, tỉ lệ {best[1]:.3f} x {best[2]:.3f}, lệch ({best[3]}, {best[4]})')
    if best[0] < 0.15:
        print('  ⚠ điểm khớp thấp (ảnh Gemini bị phóng/cắt?) → căn theo mép giấy')
        return register_by_paper(gen, ref)
    return best[1:]


# Gemini hay dùng chữ không chân đậm, hẹp ngang. Font gần nhất có đủ dấu tiếng Việt
# trên máy: Helvetica Neue Condensed Bold; vẽ theo chiều cao dòng rồi NÉN NGANG cho
# vừa ô (thay vì thu nhỏ cả chữ) để nét chữ vá không mảnh hơn chữ Gemini bên cạnh.
PATCH_FONT = ('/System/Library/Fonts/HelveticaNeue.ttc', 4)
PATCH_BOLD = ('/System/Library/Fonts/HelveticaNeue.ttc', 9)    # Condensed Black, cho nhãn đậm
# span: [chữ, màu|None] hoặc [chữ, màu|None, "b"] để in đậm


def erase_line(img, paper_big, box, band=None, pad=14):
    """Xoá dòng chữ cũ mà không cắt dấu/chân chữ của dòng trên-dưới: tách các mảng
    mực trong vùng box (nới pad px), mảng nào có tâm nằm trong box thì thuộc dòng
    cũ → thay bằng giấy; mảng của dòng bên cạnh giữ nguyên."""
    x0, y0, x1, y1 = box
    band = band or (y0, y1)      # mảng có tâm trong dải này mới bị xoá (chỉnh khi dòng sát nhau)
    Y0, Y1 = max(0, y0 - pad), min(img.height, y1 + pad)
    reg = np.asarray(img.crop((x0, Y0, x1, Y1))).astype(int)
    ink = reg.mean(-1) < 120
    h, w = ink.shape
    seen = np.zeros_like(ink)
    kill = np.zeros_like(ink)
    for sy, sx in zip(*np.nonzero(ink)):
        if seen[sy, sx]:
            continue
        stack, comp = [(sy, sx)], []
        seen[sy, sx] = True
        while stack:
            y, x = stack.pop()
            comp.append((y, x))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < h and 0 <= xx < w and ink[yy, xx] and not seen[yy, xx]:
                        seen[yy, xx] = True
                        stack.append((yy, xx))
        cy = sum(c[0] for c in comp) / len(comp) + Y0
        top = min(c[0] for c in comp) + Y0
        # thuộc dòng cũ: tâm nằm trong dải, HOẶC chữ có đuôi (y, g, p) — đỉnh trong dải,
        # tâm lệch xuống. Dấu thanh của dòng dưới có đỉnh nằm dưới dải → giữ.
        if band[0] <= cy <= band[1] or (band[0] <= top <= band[1] - 6 and cy > band[1]):
            for y, x in comp:
                kill[y, x] = True
    # nới mask 2px để ăn hết viền mờ của chữ cũ, nhưng KHÔNG đè lên mực của dòng giữ lại
    grow = np.asarray(Image.fromarray((kill * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))) > 0
    m = Image.fromarray(((grow & ~(ink & ~kill)) * 255).astype(np.uint8))
    img.paste(paper_big.crop((x0, Y0, x1, Y1)), (x0, Y0), m)


def draw_line(img, box, text, color):
    """Viết một dòng vừa khít box. text là chuỗi, hoặc list [[đoạn, màu|None], ...]
    để tô màu riêng từng đoạn (None = color). Vẽ theo chiều cao dòng rồi nén ngang
    cho vừa ô, để nét chữ không mảnh hơn chữ Gemini xung quanh."""
    from PIL import ImageDraw, ImageFont
    spans = [[text, None]] if isinstance(text, str) else text
    x0, y0, x1, y1 = box
    h = y1 - y0
    f = ImageFont.truetype(PATCH_FONT[0], int(h * 0.92), index=PATCH_FONT[1])
    fb = ImageFont.truetype(PATCH_BOLD[0], int(h * 0.92), index=PATCH_BOLD[1])
    fonts = [fb if len(sp) > 2 and sp[2] == 'b' else f for sp in spans]
    full = ''.join(sp[0] for sp in spans)
    l, t, r, b = f.getbbox(full)
    tw = int(sum(fo.getlength(sp[0]) for fo, sp in zip(fonts, spans))) + 4
    th = b - t + 4
    layer = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    x = 2
    for fo, sp in zip(fonts, spans):
        d.text((x, 2 - t), sp[0], font=fo, fill=sp[1] or color)
        x += fo.getlength(sp[0])
    k = min(1.0, h / th)
    nw, nh = max(1, int(tw * k)), max(1, int(th * k))
    nw = min(nw, x1 - x0)
    layer = layer.resize((nw, nh), Image.LANCZOS)
    img.paste(layer.convert('RGB'), (x0, y0 + (h - nh) // 2), layer.split()[3])


def paper_patch(out, paper_big, box, ring=10):
    """Miếng giấy để vá: lấy MÀU/ĐỘ SÁNG từ giấy Gemini xung quanh (nội suy mượt
    từ viền vào trong) + VÂN giấy từ giấy gốc (phần chi tiết cao tần). Vá thẳng giấy
    gốc thì lộ ô vuông vì Gemini vẽ giấy ấm/mịn khác bản gốc."""
    x0, y0, x1, y1 = box
    X0, Y0 = max(0, x0 - ring), max(0, y0 - ring)
    X1, Y1 = min(out.width, x1 + ring), min(out.height, y1 + ring)
    o = np.asarray(out.crop((X0, Y0, X1, Y1))).astype(float)
    known = np.ones(o.shape[:2], bool)
    known[y0 - Y0:y1 - Y0, x0 - X0:x1 - X0] = False
    known &= o.mean(-1) > 110                   # bỏ mực ở viền
    # nội suy màu nền: lặp làm mờ có trọng số, giữ cố định điểm đã biết
    base = np.where(known[..., None], o, 0.0)
    acc, aw = base.copy(), known.astype(float)
    for _ in range(40):
        acc = _blur(acc)
        aw = _blur(aw[..., None])[..., 0]
        acc = np.where(known[..., None], base, acc)
        aw = np.where(known, 1.0, aw)
    fill = _blur(acc / np.maximum(aw[..., None], 1e-3), 6)
    pg = np.asarray(paper_big.crop((X0, Y0, X1, Y1))).astype(float)
    grain = pg - _blur(_blur(pg))
    res = np.clip(fill + grain, 0, 255).astype(np.uint8)
    return Image.fromarray(res[y0 - Y0:y1 - Y0, x0 - X0:x1 - X0])


def _blur(a, r=3):
    """Làm mờ hộp (float, giữ kênh)."""
    k = 2 * r + 1
    pad = np.pad(a, ((r, r), (r, r), (0, 0)), mode='edge')
    c = pad.cumsum(0).cumsum(1)
    c = np.pad(c, ((1, 0), (1, 0), (0, 0)))
    return (c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k]) / (k * k)


def apply_fixes(name, out):
    """Sửa tay theo từng trang, khai ở fixes/<trang>.json (toạ độ ảnh xuất 2048x1300):
      {"op": "paper",    "box": [x0,y0,x1,y1], "note": "..."}  phủ nền giấy gốc (xoá thứ Gemini vẽ thêm)
      {"op": "orig_art", "box": [x0,y0,x1,y1], "note": "..."}  phủ giấy rồi dán lại hình GỐC theo đúng
                                                               đường viền của nó (icon bị Gemini vẽ lại)
      {"op": "move_art", "box": [...], "to": [x, y]}           dán hình GỐC ở box sang chỗ khác
      {"op": "text", "box": [...], "text": "...", "band": [ytop, ybot], "keep": [[box]...]}
                                                               xoá rồi viết lại MỘT dòng chữ
                                                               (Gemini viết sai/cụt chữ); cỡ chữ tự co cho vừa box
    Box của orig_art không được chứa chữ Hán gốc — chỉ khoanh quanh icon."""
    import json
    f = os.path.join(HERE, 'fixes', name + '.json')
    if not os.path.exists(f):
        return out
    W, H = out.size
    paper = page_io.load('xd_info_0')
    page = page_io.load(name)
    paper_big = Image.alpha_composite(Image.new('RGBA', paper.size, (0, 0, 0, 255)), paper) \
        .crop(page_io.CROP).resize((W, H), Image.LANCZOS).convert('RGB')
    orig_big = Image.alpha_composite(Image.new('RGBA', paper.size, (0, 0, 0, 255)),
                                     Image.alpha_composite(paper, page)) \
        .crop(page_io.CROP).resize((W, H), Image.LANCZOS).convert('RGB')
    art = page.split()[3].crop(page_io.CROP).resize((W, H), Image.LANCZOS) \
        .point(lambda v: 255 if v > 20 else 0).filter(ImageFilter.MaxFilter(3))
    out = out.copy()
    for fx in json.load(open(f, encoding='utf-8')):
        box = tuple(fx['box'])
        if fx['op'] == 'block':
            # cả một đoạn Gemini viết hỏng nhiều chỗ: phủ giấy cả khối rồi viết lại từng dòng
            eb = tuple(fx.get('erase', box))     # vùng xoá có thể rộng hơn vùng viết
            out.paste(paper_patch(out, paper_big, eb), eb[:2])
            x0, y0, x1, _ = box
            lh, gap = fx['line_h'], fx.get('pitch', fx['line_h'])
            for i, ln in enumerate(fx['lines']):
                draw_line(out, (x0, int(y0 + i * gap), x1, int(y0 + i * gap) + lh), ln, fx.get('color', '#1c1812'))
            print(f"  sửa block {box}: {fx.get('note', '')}")
            continue
        if fx['op'] == 'text':
            before = out.copy()
            erase_line(out, paper_big, box, fx.get('band'))
            for kb in fx.get('keep', []):        # trả lại mực bị xoá oan (dấu của dòng bên cạnh)
                kb = tuple(kb)
                out.paste(before.crop(kb), kb[:2])
            draw_line(out, box, fx['text'], fx.get('color', '#1c1812'))
            print(f"  sửa text {box}: {fx.get('note', '')}")
            continue
        if fx['op'] == 'move_art':
            # dán hình GỐC ở box sang vị trí "to" (Gemini dời chỗ icon / vẽ thêm bản sao)
            tx, ty = fx['to']
            # chỉ lấy điểm khác hẳn màu giấy (bản thân icon); lớp trang gốc có nền
            # giấy đục quanh icon, dán cả nền đó sẽ lộ thành ô sáng màu
            o = np.asarray(orig_big.crop(box)).astype(int)
            pp = np.asarray(paper_big.crop(box)).astype(int)
            m = Image.fromarray(((np.abs(o - pp).sum(-1) > 60) * 255).astype(np.uint8)) \
                .filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
            out.paste(orig_big.crop(box), (tx, ty), m)
            print(f"  sửa move_art {box} → {tx},{ty}: {fx.get('note', '')}")
            continue
        out.paste(paper_patch(out, paper_big, box), box[:2])
        if fx['op'] == 'orig_art':
            out.paste(orig_big.crop(box), box[:2], art.crop(box))
        print(f"  sửa {fx['op']} {box}: {fx.get('note', '')}")
    return out


def main(name, gen_path):
    ref_path = os.path.join(page_io.EXPORT, name + '.png')
    if not os.path.exists(ref_path):
        page_io.export(name)
    ref = Image.open(ref_path).convert('RGB')
    gen = Image.open(gen_path).convert('RGB')
    print(f'  ảnh Gemini {gen.width}x{gen.height}, ảnh gốc {ref.width}x{ref.height}')
    af = os.path.join(HERE, 'align', name + '.json')
    if os.path.exists(af):
        # căn tay (Gemini cắt sát vào trong trang, không còn mép giấy để tự căn)
        import json
        a = json.load(open(af, encoding='utf-8'))
        kx, ky, ox, oy = a['kx'], a['ky'], a['ox'], a['oy']
        print(f"  căn tay theo align/{name}.json: {a.get('note', '')}")
    else:
        kx, ky, ox, oy = register(gen, ref)
    g = gen.resize((round(gen.width * kx), round(gen.height * ky)), Image.LANCZOS)
    placed = ref.copy()
    placed.paste(g, (ox, oy))
    # mask ruột trang, viền mềm 6px để không lộ đường ghép
    mask = Image.new('L', ref.size, 0)
    d = ImageDraw.Draw(mask)
    for box in PAGES_INNER:
        d.rectangle(box, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(3))
    out = Image.composite(placed, ref, mask)
    out = apply_fixes(name, out)
    os.makedirs(os.path.dirname(ref_path), exist_ok=True)
    check = os.path.join(os.path.dirname(page_io.EXPORT), name + '_gemini_check.png')
    out.save(check)
    print(f'  ảnh ghép để soát: {check}')
    page_io.import_(name, check)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], os.path.expanduser(sys.argv[2]))

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


def register(gen, ref):
    """Trả (kx, ky, ox, oy): resize gen theo kx, ky rồi đặt tại (ox, oy) trên ref."""
    gen, ref = gen.convert('L'), ref.convert('L')
    # thô: cùng tỉ lệ hai chiều, mọi vị trí (FFT) ở 1/4 độ phân giải
    D = 4
    r = _masked_ref(ref, D)
    best = (-1,)
    for k in np.arange(0.40, 1.001, 0.01):
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
    return best[1:]


def main(name, gen_path):
    ref_path = os.path.join(page_io.EXPORT, name + '.png')
    if not os.path.exists(ref_path):
        page_io.export(name)
    ref = Image.open(ref_path).convert('RGB')
    gen = Image.open(gen_path).convert('RGB')
    print(f'  ảnh Gemini {gen.width}x{gen.height}, ảnh gốc {ref.width}x{ref.height}')
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
    os.makedirs(os.path.dirname(ref_path), exist_ok=True)
    check = os.path.join(os.path.dirname(page_io.EXPORT), name + '_gemini_check.png')
    out.save(check)
    print(f'  ảnh ghép để soát: {check}')
    page_io.import_(name, check)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], os.path.expanduser(sys.argv[2]))

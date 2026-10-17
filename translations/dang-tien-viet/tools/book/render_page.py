#!/usr/bin/env python3
"""Vẽ lại một trang sách hướng dẫn (images/xd_info_*.tex) của 【登仙】 bằng tiếng Việt.

Sách của mod gốc là ảnh, chữ Hán nằm trong pixel nên không dịch được bằng
STRINGS. Cách làm: xoá chữ Hán trong từng ô đã đo sẵn, viết chữ Việt vào
đúng ô đó, rồi đóng gói lại thành .tex. Mod dịch tráo atlas lúc chạy
(scripts/book_images.lua), không sửa file của mod gốc.

Usage:
    python3 tools/book/render_page.py tools/book/pages/xd_info_ys_21.json

Mỗi trang là một file JSON:
    {
      "src": "xd_info_ys_21",
      "boxes": [
        {
          "erase": [x0, y0, x1, y1],          # vùng chữ Hán cần xoá (toạ độ ảnh 1024x1024)
          "draw":  [x0, y0, x1, y1],          # vùng viết chữ Việt (mặc định = erase)
          "spans": [["Tên:", "#7a3fa0"], [" mô tả...", null]],   # null = màu chữ gốc
          "size": 15, "min": 9,               # cỡ chữ lớn nhất / nhỏ nhất khi co cho vừa
          "align": "left" | "center",
          "font": "body" | "title"
        }
      ]
    }

Ra: build/book/<src>.png (ảnh trong suốt), build/book/<src>_preview.png
(ghép lên nền giấy để xem), images/vn_book/<src>.tex + .xml trong mod.
"""
import json
import os
import sys
from collections import Counter

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.abspath(os.path.join(MOD, '..', '..', 'tools')))
import ktex  # noqa: E402  (tools/ktex.py ở gốc workspace)

SRC_DIR = os.path.expanduser(
    '~/Library/Application Support/Steam/steamapps/workshop/content/322330/3235319974/images')
OUT_TEX = os.path.join(MOD, 'images', 'vn_book')
OUT_PREVIEW = os.path.join(MOD, 'build', 'book')

# (đường dẫn, index trong .ttc). Chọn font PHẢI đủ chữ tiếng Việt: Arial Narrow
# Bold và phần lớn kiểu của Avenir Next Condensed thiếu ư ơ ầ ộ… — chữ sẽ mất
# ký tự mà không báo lỗi. check_font() chặn trường hợp đó.
FONTS = {
    'body': ('/System/Library/Fonts/Avenir Next Condensed.ttc', 2),   # Demi Bold
    'title': ('/System/Library/Fonts/Supplemental/Georgia Bold.ttf', 0),
}


def check_font(key):
    path, idx = FONTS[key]
    f = ImageFont.truetype(path, 20, index=idx)
    notdef = bytes(f.getmask('\uffff'))
    miss = [c for c in 'ăâđêôơưàảãáạằẳẵắặầẩẫấậềểễếệộổỗốồờởỡớợừửữứựỳỷỹýỵĐ'
            if bytes(f.getmask(c)) == notdef]
    if miss:
        sys.exit(f'font {key} ({path}#{idx}) thiếu chữ tiếng Việt: {"".join(miss)}')


def hexrgb(s):
    s = s.lstrip('#')
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def drop_large(flags, size, limit):
    """Bỏ khỏi mask các mảng liền nhau (8 hướng) rộng hoặc cao quá limit px."""
    w, h = size
    out = list(flags)
    seen = [False] * len(flags)
    for start in range(len(flags)):
        if not flags[start] or seen[start]:
            continue
        stack, comp = [start], []
        seen[start] = True
        while stack:
            i = stack.pop()
            comp.append(i)
            x, y = i % w, i // w
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        j = ny * w + nx
                        if flags[j] and not seen[j]:
                            seen[j] = True
                            stack.append(j)
        xs = [i % w for i in comp]
        ys = [i // w for i in comp]
        if max(xs) - min(xs) > limit or max(ys) - min(ys) > limit:
            for i in comp:
                out[i] = False
    return out


def erase(img, box, mode=None, drop=True):
    """Xoá chữ trong box. Có hai kiểu nền trên các trang sách:
    - nền trong suốt (giấy nằm ở ảnh khác): chữ màu tối → xoá thành trong suốt;
      chỉ xoá điểm TỐI để giữ lại hoa văn xám đi ngang qua ô chữ.
    - khung tối mờ (alpha ~80): chữ sáng viền xám → tô lại bằng màu khung;
      chỉ xoá điểm SÁNG để không ăn vào tóc/tranh màu đen bên cạnh.
    Trả về kiểu nền ("clear" | "panel")."""
    x0, y0, x1, y1 = box
    region = img.crop(box)
    px = list(region.getdata())
    q = lambda p: tuple(v // 8 * 8 for v in p)
    bg = Counter(q(p) for p in px).most_common(1)[0][0]
    if mode == 'light':
        # chữ sáng đè lên tranh tối (tóc): chỉ xoá phần ruột sáng của chữ,
        # viền xám của chữ chìm vào nền tối nên để lại không thấy
        fillc = Counter(q(p) for p in px if p[3] > 150 and max(p[:3]) < 64).most_common(1)
        fillc = fillc[0][0] if fillc else bg
        is_text = lambda p: p[3] > 150 and min(p[:3]) >= 150
    elif mode == 'all':
        fillc = (0, 0, 0, 0)
        is_text = lambda p: p[3] > 20
    elif bg[3] < 30:
        mode, fillc = 'clear', (0, 0, 0, 0)
        # chữ tối, hoặc tên in màu (tím/đỏ) — hoa văn xám thì độ bão hoà thấp
        is_text = lambda p: p[3] > 20 and (max(p[:3]) <= 60 or max(p[:3]) - min(p[:3]) > 60)
    else:
        mode, fillc = 'panel', bg
        is_text = lambda p: p[3] > 150 and max(p[:3]) >= 64
    flags = [is_text(p) for p in px]
    if drop and mode in ('panel', 'light'):
        # Viền trắng quanh tranh nhân vật cũng sáng như chữ → chỉ xoá những
        # mảng liền nhau cỡ một chữ; nét viền dài của tranh thì giữ lại.
        flags = drop_large(flags, region.size, 24)
    mask = Image.new('L', region.size, 0)
    mask.putdata([255 if f else 0 for f in flags])
    mask = mask.filter(ImageFilter.MaxFilter(3))
    region.paste(Image.new('RGBA', region.size, fillc), (0, 0), mask)
    img.paste(region, (x0, y0))
    return mode


# Vẽ chữ ở độ phân giải gấp đôi rồi thu về 1024 khi ghi .tex (khử răng cưa).
SCALE = 2

STYLE = {
    # chữ tối trên giấy, như chữ gốc (32,32,16)
    'clear': dict(fill=(34, 31, 22), stroke=None),
    # trong khung tối mờ cũng dùng chữ tối: khung chỉ làm giấy xám đi một
    # chút, chữ tối vẫn rõ. Chữ sáng viền xám (như bản gốc) nhoè ở cỡ nhỏ.
    'panel': dict(fill=(28, 24, 18), stroke=None),
}


def layout(spans, font, width):
    """Ngắt dòng theo từ, giữ màu từng đoạn. Trả về list dòng, mỗi dòng là
    list (chữ, màu)."""
    words = []
    for text, color in spans:
        for i, part in enumerate(text.split('\n')):
            if i > 0:
                words.append(('\n', None))
            for w in part.split(' '):
                if w:
                    words.append((w, color))
    lines, cur, cur_w = [], [], 0
    space = font.getlength(' ')
    for w, c in words:
        if w == '\n':
            lines.append(cur)
            cur, cur_w = [], 0
            continue
        ww = font.getlength(w)
        add = ww + (space if cur else 0)
        if cur and cur_w + add > width:
            lines.append(cur)
            cur, cur_w = [(w, c)], ww
        else:
            cur.append((w, c))
            cur_w += add
    if cur:
        lines.append(cur)
    return lines


def draw_box(layer, b, mode):
    x0, y0, x1, y1 = (v * SCALE for v in b.get('draw', b['erase']))
    spans = b['spans'] if 'spans' in b else [[b['text'], None]]
    path, idx = FONTS[b.get('font', 'body')]
    size = b.get('size', 15) * SCALE
    while True:
        font = ImageFont.truetype(path, size, index=idx)
        lines = layout(spans, font, x1 - x0)
        lh = int(size * 1.2)
        if len(lines) * lh <= (y1 - y0) or size <= b.get('min', 9) * SCALE:
            break
        size -= 1
    if len(lines) * lh > (y1 - y0):
        print(f"  ⚠ ô {b['erase']} vẫn tràn ở cỡ {size}: {len(lines)} dòng")
    d = ImageDraw.Draw(layer)
    space = font.getlength(' ')
    y = y0 + max(0, ((y1 - y0) - len(lines) * lh) // 2) if b.get('valign') == 'center' else y0
    for line in lines:
        width = sum(font.getlength(w) for w, _ in line) + space * (len(line) - 1)
        x = x0 + ((x1 - x0) - width) / 2 if b.get('align') == 'center' else x0
        for w, c in line:
            st = STYLE[b.get('style', mode)]
            col = hexrgb(c) if c else st['fill']
            if st['stroke']:
                d.text((x, y), w, font=font, fill=col + (255,),
                       stroke_width=1, stroke_fill=st['stroke'] + (255,))
            else:
                d.text((x, y), w, font=font, fill=col + (255,))
            x += font.getlength(w) + space
        y += lh
    return size / SCALE


def main(spec_path):
    spec = json.load(open(spec_path, encoding='utf-8'))
    name = spec['src']
    img, info = ktex.read(os.path.join(SRC_DIR, name + '.tex'))
    if img is None:
        sys.exit(f'không đọc được {name}.tex: {info}')
    img = img.convert('RGBA')
    for k in FONTS:
        check_font(k)
    modes = [erase(img, b['erase'], b.get('mode'), b.get('drop_large', True))
             for b in spec['boxes']]
    img = img.resize((img.size[0] * SCALE, img.size[1] * SCALE), Image.LANCZOS)
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    for b, mode in zip(spec['boxes'], modes):
        if b.get('erase_only'):
            continue
        size = draw_box(layer, b, mode)
        print(f"  ô {b['erase']}: cỡ {size}")
    img = Image.alpha_composite(img, layer)

    os.makedirs(OUT_PREVIEW, exist_ok=True)
    img.save(os.path.join(OUT_PREVIEW, name + '.png'))
    paper, _ = ktex.read(os.path.join(SRC_DIR, 'xd_info_0.tex'))
    prev = Image.new('RGBA', img.size, (230, 220, 195, 255))
    if paper is not None:
        prev = Image.alpha_composite(prev, paper.convert('RGBA').resize(img.size, Image.LANCZOS))
    Image.alpha_composite(prev, img).save(os.path.join(OUT_PREVIEW, name + '_preview.png'))

    os.makedirs(OUT_TEX, exist_ok=True)
    # Ghi 2048 (HD); scripts/book_images.lua thu widget về cỡ gốc khi hiển thị.
    ktex.write(img, os.path.join(OUT_TEX, name + '.tex'))
    # giữ nguyên toạ độ UV của atlas gốc, chỉ đổi đường dẫn texture
    xml = open(os.path.join(SRC_DIR, name + '.xml'), encoding='utf-8').read()
    open(os.path.join(OUT_TEX, name + '.xml'), 'w', encoding='utf-8').write(xml)
    print(f'✓ {name}: images/vn_book/{name}.tex  (xem trước: build/book/{name}_preview.png)')


if __name__ == '__main__':
    for p in sys.argv[1:]:
        main(p)

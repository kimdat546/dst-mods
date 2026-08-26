#!/usr/bin/env python3
"""Gộp nhiều PNG thành MỘT atlas .tex + .xml cho DST.

    python3 tools/make_atlas.py <thư_mục_png> <tên_atlas> <thư_mục_ra>

Ví dụ:  python3 tools/make_atlas.py art/icons mm_icons \
            originals/mod-mau/images/inventoryimages

Trong code mod dùng như sau:
    atlas = "images/inventoryimages/mm_icons.xml"
    image = "<tên_file_png>.tex"      ← chính là name của <Element>

⚠ HAI ĐIỀU DỄ SAI

1. `image` là TÊN ELEMENT trong xml, KHÔNG phải tên file trên đĩa.
   Một file .tex chứa 200 icon thì có 200 <Element>, mỗi cái một cái tên.
   Tên đặt tuỳ ý, nhưng quy ước của Klei là "<tên>.tex" cho dễ đọc.

2. Trục v tính TỪ ĐÁY LÊN (quy ước OpenGL), không phải từ đỉnh.
   Kiểm chứng: trong atlas gốc của 景熹家居, icon jx_potted có
   v1=0.8716 v2=0.9331; cắt theo chiều từ đỉnh ra ô RỖNG, cắt theo
   chiều từ đáy mới ra đúng icon.
"""
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ktex
from PIL import Image


def next_pow2(n):
    return 1 << (n - 1).bit_length()


def pack(src_dir, name, out_dir):
    pngs = sorted(f for f in os.listdir(src_dir) if f.lower().endswith('.png'))
    if not pngs:
        sys.exit('không có file .png nào trong ' + src_dir)

    imgs = [(f, Image.open(os.path.join(src_dir, f)).convert('RGBA')) for f in pngs]

    # Xếp theo lưới: mỗi ô rộng bằng ảnh to nhất. Đơn giản, đủ dùng cho icon.
    cw = max(im.width for _, im in imgs)
    ch = max(im.height for _, im in imgs)
    cols = max(1, int(math.ceil(math.sqrt(len(imgs)))))
    rows = int(math.ceil(len(imgs) / cols))
    W = next_pow2(cols * cw)
    H = next_pow2(rows * ch)

    sheet = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    elems = []
    for i, (f, im) in enumerate(imgs):
        cx, cy = (i % cols) * cw, (i // cols) * ch
        sheet.paste(im, (cx, cy))
        # UV: u bình thường; v ĐẢO vì tính từ đáy
        u1, u2 = cx / W, (cx + im.width) / W
        v1, v2 = 1 - (cy + im.height) / H, 1 - cy / H
        elems.append((os.path.splitext(f)[0] + '.tex', u1, u2, v1, v2))

    os.makedirs(out_dir, exist_ok=True)
    tex = os.path.join(out_dir, name + '.tex')
    ktex.write(sheet, tex, 'DXT5')

    with open(os.path.join(out_dir, name + '.xml'), 'w', encoding='utf-8') as fh:
        fh.write('<Atlas><Texture filename="%s.tex" /><Elements>' % name)
        for n, u1, u2, v1, v2 in elems:
            fh.write('<Element name="%s" u1="%.9f" u2="%.9f" v1="%.9f" v2="%.9f" />'
                     % (n, u1, u2, v1, v2))
        fh.write('</Elements></Atlas>\n')

    print('  atlas %dx%d, %d icon, %.1f KB' % (W, H, len(elems), os.path.getsize(tex) / 1024))
    for n, *_ in elems:
        print('    image = "%s"' % n)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    pack(sys.argv[1], sys.argv[2], sys.argv[3])

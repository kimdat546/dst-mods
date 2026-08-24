#!/usr/bin/env python3
"""Cắt ảnh từng vật phẩm ra khỏi atlas .tex/.xml của mod, lưu PNG.

    python3 tools/extract_images.py            → wiki/img/<tên>.png

Atlas dùng toạ độ UV chuẩn hoá 0..1, trục v tính TỪ DƯỚI LÊN (kiểu OpenGL).
Trước đây tưởng là từ trên xuống, vì ktex.read() lúc đó trả ảnh bị lật — hai cái
sai bù nhau nên cắt ra đúng vùng nhưng mỗi ảnh vẫn ngược. Nay read() trả đúng
chiều thì công thức v cũng trả về đúng chuẩn.
"""
import os
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from ktex import read as ktex_read

OUT = os.path.join(ROOT, 'wiki', 'img')


def main():
    os.makedirs(OUT, exist_ok=True)
    total, failed = 0, []

    for mod in ('core', 'base', 'nightmare'):
        base = os.path.join(ROOT, 'vendor', mod, 'images')
        if not os.path.isdir(base):
            continue
        for dp, _, fns in os.walk(base):
            for fn in fns:
                if not fn.endswith('.xml'):
                    continue
                xml = os.path.join(dp, fn)
                try:
                    tree = ET.parse(xml)
                except ET.ParseError as e:
                    failed.append((fn, f'XML hỏng: {e}'))
                    continue
                tex_el = tree.find('.//Texture')
                if tex_el is None:
                    continue
                tex = os.path.join(dp, tex_el.get('filename'))
                if not os.path.exists(tex):
                    failed.append((fn, 'thiếu file .tex'))
                    continue
                sheet, info = ktex_read(tex)
                if sheet is None:
                    failed.append((fn, info))
                    continue

                W, H = sheet.size
                for el in tree.findall('.//Element'):
                    name = el.get('name', '').replace('.tex', '')
                    u1, u2 = float(el.get('u1')), float(el.get('u2'))
                    v1, v2 = float(el.get('v1')), float(el.get('v2'))
                    # ktex.read() nay trả ảnh ĐÚNG CHIỀU, nên v (tính từ dưới
                    # theo hệ của Klei) phải đổi sang hệ Pillow (từ trên xuống).
                    left, right = round(u1 * W), round(u2 * W)
                    top, bottom = round((1 - v2) * H), round((1 - v1) * H)
                    if right - left < 2 or bottom - top < 2:
                        continue
                    img = sheet.crop((left, top, right, bottom))
                    img.save(os.path.join(OUT, f'{name}.png'))
                    total += 1

    print(f"  đã cắt {total} ảnh → wiki/img/")
    if failed:
        print(f"  {len(failed)} atlas lỗi:")
        for f, why in failed:
            print(f"    ✗ {f}: {why}")
    return 0


if __name__ == '__main__':
    sys.exit(main())

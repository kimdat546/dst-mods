#!/usr/bin/env python3
"""Làm modicon.tex + modicon.xml (+ preview Workshop) từ một ảnh bất kỳ.

    python3 tools/make_modicon.py <ảnh_nguồn> <thư_mục_ra> [--preview N] [--max-kb N]

Ví dụ:
    python3 tools/make_modicon.py art/icon.png translations/xyz/assets

Sinh ra trong <thư_mục_ra>:
    modicon.png   256×256, để xem lại và dựng lại khi cần
    modicon.tex   DXT5 kèm mipmap — thứ DST thật sự đọc
    modicon.xml   atlas 1 phần tử, tên phần tử là "modicon.tex"
    preview.png   ảnh cho trang Workshop (mặc định 1024², ép dưới 1 MB)

Rồi khai báo trong modinfo.lua:
    icon_atlas = "modicon.xml"
    icon = "modicon.tex"

⚠ modicon PHẢI vuông và là luỹ thừa 2 (Klei dùng 256×256). Ảnh không vuông sẽ
bị bóp méo, nên script tự cắt giữa cho vuông trước khi thu nhỏ.

⚠ u1/v1 = 1/512, u2/v2 = 1 − 1/512 (lùi vào nửa texel) — chép đúng atlas gốc
của Klei; để 0..1 thì viền icon bị rỉ màu từ mép texture.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ktex
from PIL import Image

XML = ('<Atlas><Texture filename="modicon.tex" /><Elements>'
       '<Element name="modicon.tex" u1="0.001953125" u2="0.998046875"'
       ' v1="0.001953125" v2="0.998046875" /></Elements></Atlas>')


def cat_vuong(im):
    """Cắt giữa cho vuông — thu nhỏ ảnh chữ nhật thẳng sẽ méo."""
    w, h = im.size
    if w == h:
        return im
    c = min(w, h)
    return im.crop(((w - c) // 2, (h - c) // 2, (w - c) // 2 + c, (h - c) // 2 + c))


def ghi_preview(im, path, canh, max_kb):
    """Ép preview lọt giới hạn 1 MB của Steam mà giữ độ phân giải cao nhất.

    Thử theo thứ tự: PNG đầy màu → PNG bảng 256 màu → hạ độ phân giải.
    Không dùng JPEG: tranh này là line-art nền phẳng, JPEG gây quầng ở nét viền,
    còn bảng 256 màu thì gần như không phân biệt được với bản gốc.
    """
    while True:
        r = im.resize((canh, canh), Image.LANCZOS)
        r.convert("RGB").save(path, optimize=True)
        kb = os.path.getsize(path) // 1024
        if kb <= max_kb:
            return canh, kb, "PNG"

        r.convert("RGB").quantize(colors=256, method=Image.MEDIANCUT,
                                  dither=Image.FLOYDSTEINBERG).save(path, optimize=True)
        kb = os.path.getsize(path) // 1024
        if kb <= max_kb or canh <= 256:
            return canh, kb, "PNG 256 màu"
        canh //= 2


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("nguon")
    ap.add_argument("ra")
    ap.add_argument("--preview", type=int, default=1024, help="cạnh ảnh preview")
    ap.add_argument("--max-kb", type=int, default=1000, help="trần dung lượng preview")
    a = ap.parse_args()

    im = cat_vuong(Image.open(a.nguon).convert("RGBA"))
    os.makedirs(a.ra, exist_ok=True)

    icon = im.resize((256, 256), Image.LANCZOS)
    icon.save(os.path.join(a.ra, "modicon.png"), optimize=True)
    ktex.write(icon, os.path.join(a.ra, "modicon.tex"), "DXT5")
    with open(os.path.join(a.ra, "modicon.xml"), "w", encoding="utf-8") as f:
        f.write(XML)

    canh, kb, kieu = ghi_preview(im, os.path.join(a.ra, "preview.png"),
                                 a.preview, a.max_kb)

    print(f"nguồn      : {im.size[0]}×{im.size[1]}")
    print(f"modicon    : 256×256  → .png .tex (DXT5) .xml")
    print(f"preview.png: {canh}×{canh}, {kb} KB ({kieu})")
    print(f"→ {a.ra}")


if __name__ == "__main__":
    main()

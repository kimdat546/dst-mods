#!/usr/bin/env python3
"""Xuất trang sách ra PNG để dịch bằng công cụ ngoài, rồi nhập bản đã dịch về .tex.

    python3 tools/book/page_io.py export xd_info_ys_21 [xd_info_ys_20 ...]
        → build/book/export/<trang>.png   (nền giấy + chữ Hán, phóng 2x)

    python3 tools/book/page_io.py import xd_info_ys_21 duong/dan/anh_da_dich.png
        → images/vn_book/<trang>.tex + .xml  (2048x2048, book_images.lua thu về cỡ gốc khi hiển thị)

Vì sao ghép thẳng được: ảnh nền giấy xd_info_0 và ảnh trang dùng CÙNG toạ độ
UV trong .xml, game vẽ trang đè khít lên giấy. Nên ảnh đã dịch (dính sẵn nền
giấy) có thể thay luôn cho ảnh trang; ngoài mép giấy thì lấy lại độ trong suốt
của giấy để viền sách không bị phủ.
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.abspath(os.path.join(MOD, '..', '..', 'tools')))
import ktex  # noqa: E402

SRC_DIR = os.path.expanduser(
    '~/Library/Application Support/Steam/steamapps/workshop/content/322330/3235319974/images')
OUT_TEX = os.path.join(MOD, 'images', 'vn_book')
EXPORT = os.path.join(MOD, 'build', 'book', 'export')
SCALE = 2
# Phần ảnh game thật sự dùng: v1=0.3667..1 trong .xml → 650 hàng trên cùng
# (Klei lưu ảnh lộn ngược). Phần dưới là trống, không xuất ra cho đỡ nặng.
CROP = (0, 0, 1024, 650)


def load(name):
    img, info = ktex.read(os.path.join(SRC_DIR, name + '.tex'))
    if img is None:
        sys.exit(f'không đọc được {name}.tex: {info}')
    return img.convert('RGBA')


def export(name):
    paper = load('xd_info_0')
    page = Image.alpha_composite(paper, load(name)).crop(CROP)
    w, h = page.size
    out = Image.new('RGB', page.size, (0, 0, 0))
    out.paste(page, (0, 0), page)
    out = out.resize((w * SCALE, h * SCALE), Image.LANCZOS)
    os.makedirs(EXPORT, exist_ok=True)
    path = os.path.join(EXPORT, name + '.png')
    out.save(path)
    print(f'✓ {path}  ({out.size[0]}x{out.size[1]})')


def import_(name, src):
    tr = Image.open(src).convert('RGB')
    w, h = (CROP[2] - CROP[0]) * SCALE, (CROP[3] - CROP[1]) * SCALE
    if tr.size != (w, h):
        print(f'  ảnh dịch {tr.size[0]}x{tr.size[1]} ≠ {w}x{h}, co giãn lại cho khớp')
        tr = tr.resize((w, h), Image.LANCZOS)
    # độ trong suốt lấy từ giấy ∪ trang gốc, phóng lên cùng tỉ lệ
    paper, page = load('xd_info_0'), load(name)
    alpha = Image.alpha_composite(paper, page).split()[3].crop(CROP)
    alpha = alpha.resize((w, h), Image.LANCZOS)
    tr.putalpha(alpha)
    full = Image.new('RGBA', (1024 * SCALE, 1024 * SCALE), (0, 0, 0, 0))
    full.paste(tr, (CROP[0] * SCALE, CROP[1] * SCALE))
    # Giữ 2048 (HD). Widget sách lấy cỡ hiển thị từ cỡ texture nên ảnh 2048
    # sẽ phình gấp đôi — scripts/book_images.lua thu widget về đúng cỡ gốc
    # ngay sau khi tráo ảnh. Thu ảnh xuống 1024 thì chữ nhoè thấy rõ trong game.
    os.makedirs(OUT_TEX, exist_ok=True)
    ktex.write(full, os.path.join(OUT_TEX, name + '.tex'))
    xml = open(os.path.join(SRC_DIR, name + '.xml'), encoding='utf-8').read()
    open(os.path.join(OUT_TEX, name + '.xml'), 'w', encoding='utf-8').write(xml)
    print(f'✓ images/vn_book/{name}.tex ({full.size[0]}x{full.size[1]})'
          f' — nhớ thêm "{name}" vào PAGES trong scripts/book_images.lua')


if __name__ == '__main__':
    if len(sys.argv) >= 3 and sys.argv[1] == 'export':
        for n in sys.argv[2:]:
            export(n)
    elif len(sys.argv) == 4 and sys.argv[1] == 'import':
        import_(sys.argv[2], sys.argv[3])
    else:
        sys.exit(__doc__)

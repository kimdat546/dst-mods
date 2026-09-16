#!/usr/bin/env python3
"""Dựng modicon.tex/.xml và preview.png từ ảnh nguồn trong assets/.

  assets/icon_source.png     (vuông)  -> assets/modicon.tex + .xml  (256x256)
  assets/preview_source.png  (ngang)  -> assets/preview.png

⚠ GIỚI HẠN 1 MB CHO ẢNH PREVIEW. Steam Workshop từ chối ảnh preview lớn hơn
  1 MB. Ảnh nguồn ở đây 7-8 MB nên phải nén; script tự hạ chất lượng tới khi
  lọt, và báo ra cỡ cuối cùng.

⚠ MODICON PHẢI LÀ 256x256. Đó là cỡ mọi mod dùng, và DXT đòi cạnh chia hết cho
  4. ktex.py tự cắt cho chia hết 4 nhưng cứ đưa đúng cỡ cho chắc.
"""

import pathlib
import sys

GOC = pathlib.Path(__file__).resolve().parent.parent
CHUNG = GOC.parent.parent / "tools"
sys.path.insert(0, str(CHUNG))

from PIL import Image
import ktex

TRAN_PREVIEW = 1024 * 1024   # 1 MB, giới hạn của Steam


def lam_icon():
    nguon = GOC / "assets" / "icon_source.png"
    if not nguon.exists():
        print(f"✗ thiếu {nguon}", file=sys.stderr)
        return False
    img = Image.open(nguon).convert("RGBA").resize((256, 256), Image.LANCZOS)

    ra_tex = GOC / "assets" / "modicon.tex"
    ktex.write(img, str(ra_tex), fmt="DXT5")

    # Atlas một phần tử, u/v chừa nửa texel mỗi bên để khỏi rỉ viền.
    n = 1.0 / 512          # nửa texel của ảnh 256
    (GOC / "assets" / "modicon.xml").write_text(
        '<Atlas><Texture filename="modicon.tex" /><Elements>'
        f'<Element name="modicon.tex" u1="{n}" u2="{1 - n}" '
        f'v1="{n}" v2="{1 - n}" /></Elements></Atlas>\n',
        encoding="utf-8",
    )
    print(f"✓ modicon.tex 256x256 ({ra_tex.stat().st_size // 1024} KB) + modicon.xml")
    return True


def lam_preview():
    nguon = GOC / "assets" / "preview_source.png"
    if not nguon.exists():
        print(f"✗ thiếu {nguon}", file=sys.stderr)
        return False
    img = Image.open(nguon).convert("RGB")
    ra = GOC / "assets" / "preview.png"

    for rong in (1280, 1024, 896, 768, 640):
        cao = round(img.height * rong / img.width)
        img.resize((rong, cao), Image.LANCZOS).save(ra, "PNG", optimize=True)
        if ra.stat().st_size <= TRAN_PREVIEW:
            print(f"✓ preview.png {rong}x{cao} ({ra.stat().st_size // 1024} KB)")
            return True
    print(f"✗ không nén nổi preview xuống dưới 1 MB", file=sys.stderr)
    return False


if __name__ == "__main__":
    ok = lam_icon() and lam_preview()
    sys.exit(0 if ok else 1)

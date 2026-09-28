#!/usr/bin/env python3
"""Thêm chữ tiếng Việt vào font bitmap của game → fonts/vi_<tên>.zip

    python3 tools/tao_font.py            # dựng mọi font
    python3 tools/tao_font.py --xem      # thêm ảnh thử viec/font_thu_<tên>.png

⚠ VÌ SAO. Font của DST chỉ có Latin-1 + Latin mở rộng A (~326 glyph): có
  á à ã â ă đ ĩ ũ nhưng THIẾU ơ ư và mọi chữ dấu riêng của tiếng Việt (ạ ả ọ
  ế ờ ự…). Game lấy những chữ đó từ font dự phòng khác kiểu → chữ lệch nét
  (người chơi phản ánh trên Workshop: "Chữ ạ bị format khác với chữ game").

CÁCH LÀM — ghép từ CHÍNH glyph của từng font để giữ đúng nét chữ:
  • dấu sắc/huyền/ngã/mũ/trăng: tách từ glyph có sẵn (á − a, Á − A…)
  • chấm dưới: glyph "."   • dấu hỏi: nửa trên glyph "?"
  • râu (ơ ư): glyph "," xoay 180°
  • dấu thanh trên â ê ô: sắc/huyền/hỏi đặt lệch phải/trái như chữ in Việt

⚠ Đầu vào là font CỦA GAME trên máy (fonts.zip trong app) — không commit font
  sinh ra vào repo public; make_upload.sh sinh lại lúc đóng gói.
"""

import io
import pathlib
import re
import sys
import unicodedata
import zipfile

from PIL import Image

GOC = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(GOC.parent.parent / "tools"))
import ktex  # noqa: E402

GAME_FONTS = pathlib.Path.home() / (
    "Library/Application Support/Steam/steamapps/common/Don't Starve Together/"
    "dontstarve_steam.app/Contents/data/databundles/fonts.zip")
RA = GOC / "fonts"

# font → alias trong game (scripts/fonts.lua). Bỏ controllers/emoji/fallback*/ptmono.
FONT = {
    "talkingfont": "talkingfont", "talkingfont_wormwood": "talkingfont_wormwood",
    "talkingfont_tradein": "talkingfont_tradein", "talkingfont_hermit": "talkingfont_hermit",
    "hammerhead50": "hammerhead", "bellefair50": "bellefair", "bellefair50_outline": "bellefair_outline",
    "stint-ucr50": "stint-ucr", "stint-ucr20": "stint-small", "opensans50": "opensans",
    "belisaplumilla50": "bp50", "belisaplumilla100": "bp100", "buttonfont": "buttonfont",
    "spirequal": "spirequal", "spirequal_small": "spirequal_small",
    "spirequal_outline": "spirequal_outline", "spirequal_outline_small": "spirequal_outline_small",
}

CHU_VIET = "".join(sorted(set(
    "aăâeêioôơuưyAĂÂEÊIOÔƠUƯYđĐ"
    + "".join(unicodedata.normalize("NFC", b + t)
              for b in "aăâeêioôơuưyAĂÂEÊIOÔƠUƯY"
              for t in ("̀", "́", "̃", "̉", "̣")))))


class Glyph:
    def __init__(self, img, xo, yo, adv):
        self.img, self.xo, self.yo, self.adv = img, xo, yo, adv

    def hop(self):
        """Khung nội dung (x0,y0,x1,y1) theo toạ độ canvas (xo,yo) — alpha > 40."""
        a = self.img.getchannel("A").point(lambda v: 255 if v > 40 else 0)
        b = a.getbbox()
        if not b:
            return (self.xo, self.yo, self.xo, self.yo)
        return (self.xo + b[0], self.yo + b[1], self.xo + b[2], self.yo + b[3])


def doc_font(ten):
    with zipfile.ZipFile(GAME_FONTS) as z:
        with zipfile.ZipFile(io.BytesIO(z.read(f"fonts/{ten}.zip"))) as zf:
            fnt = zf.read("font.fnt").decode("utf-8")
            tex = zf.read("font.tex")
    p = RA / f".tmp_{ten}.tex"
    p.parent.mkdir(exist_ok=True)
    p.write_bytes(tex)
    atlas, _ = ktex.read(str(p))
    p.unlink()
    atlas = atlas.convert("RGBA")
    g = {}
    for m in re.finditer(r"<char ([^>]*)/>", fnt):
        a = dict(re.findall(r'(\w+)="(-?\d+)"', m.group(1)))
        a = {k: int(v) for k, v in a.items()}
        img = atlas.crop((a["x"], a["y"], a["x"] + a["width"], a["y"] + a["height"]))
        g[a["id"]] = Glyph(img, a["xoffset"], a["yoffset"], a["xadvance"])
    return fnt, atlas, g


def dan(nen, cai, x, y):
    """Dán `cai` (RGBA) lên canvas nền tại (x,y), trộn alpha."""
    lop = Image.new("RGBA", nen.size, (0, 0, 0, 0))
    lop.paste(cai, (x, y))
    return Image.alpha_composite(nen, lop)


def tach_dau(g, co_dau, goc):
    """Phần của glyph `co_dau` nằm trên nội dung của `goc` → (ảnh dấu, dx so với tâm, khe hở)."""
    if co_dau not in g or goc not in g:
        return None
    A, B = g[co_dau], g[goc]
    top_goc = B.hop()[1]
    anh = A.img
    cat = top_goc - A.yo - 1
    if cat <= 0:
        return None
    dau = anh.crop((0, 0, anh.width, cat))
    b = dau.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox()
    if not b:
        return None
    dau = dau.crop(b)
    tam_goc = (B.hop()[0] + B.hop()[2]) / 2
    x_dau = A.xo + b[0]
    y_day = A.yo + b[3]
    return dau, x_dau - tam_goc, top_goc - y_day


def ghep(g, ch, dau, base_line):
    """Dựng glyph cho chữ `ch` (NFC)."""
    ten = unicodedata.normalize("NFD", ch)
    goc, marks = ten[0], ten[1:]
    hoa = goc.isupper()
    # Chữ nền: tìm glyph có sẵn nhiều dấu nhất (vd ê, ơ đã dựng)
    nen_ch, con = goc, list(marks)
    for i in range(len(marks), 0, -1):
        thu = unicodedata.normalize("NFC", goc + marks[:i])
        if len(thu) == 1 and ord(thu) in g:
            nen_ch, con = thu, list(marks[i:])
            break
    if ord(nen_ch) not in g:
        return None
    B = g[ord(nen_ch)]
    pad = 40
    W, H = B.img.width + 2 * pad + 40, B.img.height + 2 * pad + 60
    ox, oy = pad - min(0, B.xo) + 20, pad + 40  # gốc canvas
    nen = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    nen = dan(nen, B.img, ox + B.xo, oy + B.yo)
    x0, y0, x1, y1 = B.hop()
    x0, y0, x1, y1 = x0 + ox, y0 + oy, x1 + ox, y1 + oy
    co_mu = nen_ch.lower() in "âêô"
    for m in con:
        if m == "̛":  # râu
            r = dau["rau_hoa" if hoa else "rau"]
            if r is None:
                return None
            anh = r
            x = x1 - int(anh.width * 0.62)   # chân râu chạm vai phải chữ
            y = y0 - int(anh.height * 0.30)
            nen = dan(nen, anh, x, y)
            x1 = max(x1, x + anh.width)
            y0 = min(y0, y)
        elif m == "̣":  # chấm dưới
            anh = dau["cham"]
            x = (x0 + x1) // 2 - anh.width // 2
            y = max(y1, oy + base_line) + max(2, anh.height // 3)
            nen = dan(nen, anh, x, y)
        elif m in "̀́̃̉̂̆":
            khoa = {"̀": "huyen", "́": "sac", "̃": "nga", "̉": "hoi",
                    "̂": "mu", "̆": "trang"}[m] + ("_hoa" if hoa else "")
            d = dau.get(khoa)
            if d is None:
                return None
            anh, dx, khe = d
            tam = (x0 + x1) / 2
            if co_mu and m in "\u0300\u0301\u0309":
                # chữ in Việt: dấu thanh đứng sát MÉP PHẢI dấu mũ (cả sắc, huyền, hỏi),
                # hơi chồng lên đầu mũ — đặt lệch trái thì lấn sang chữ trước.
                x = x1 - int(anh.width * 0.75)
                y = y0 - int(anh.height * 0.55)
                nen = dan(nen, anh, x, y)
                x1 = max(x1, x + anh.width)
                y0 = min(y0, y)
            else:
                x = int(tam + dx)
                y = y0 - max(1, int(khe)) - anh.height
                nen = dan(nen, anh, x, y)
                y0 = min(y0, y)
    b = nen.getbbox()
    if not b:
        return None
    img = nen.crop(b)
    return Glyph(img, b[0] - ox, b[1] - oy, B.adv)


def chuan_bi_dau(g):
    d = {}
    for ten, co, goc in [("sac", "á", "a"), ("huyen", "à", "a"), ("nga", "ã", "a"), ("mu", "â", "a"),
                         ("trang", "ă", "a"), ("sac_hoa", "Á", "A"), ("huyen_hoa", "À", "A"),
                         ("nga_hoa", "Ã", "A"), ("mu_hoa", "Â", "A"), ("trang_hoa", "Ă", "A")]:
        d[ten] = tach_dau(g, ord(co), ord(goc))
    # font thiếu ă: vẽ dấu trăng bằng chữ "u" thu nhỏ
    for hoa in ("", "_hoa"):
        if d.get("trang" + hoa) is None and d.get("mu" + hoa) and ord("u") in g:
            mu = d["mu" + hoa]
            u = g[ord("u")].img
            u = u.crop(u.getchannel("A").getbbox())
            u = u.resize((max(4, mu[0].width), max(3, mu[0].height)), Image.LANCZOS)
            d["trang" + hoa] = (u, mu[1], mu[2])
    # dấu hỏi: nửa trên dấu "?" thu cỡ dấu sắc
    q = g.get(ord("?"))
    cao_x = (g[ord("x")].hop()[3] - g[ord("x")].hop()[1]) if ord("x") in g else 20
    for hoa in ("", "_hoa"):
        s = d.get("sac" + hoa)
        if q and s:
            a = q.img.crop(q.img.getchannel("A").getbbox())
            a = a.crop((0, 0, a.width, int(a.height * 0.62)))
            h = max(8, int(s[0].height * 1.35), int(cao_x * 0.42))  # đủ lớn để giữ viền
            w = max(3, int(a.width * h / a.height))
            d["hoi" + hoa] = (a.resize((w, h), Image.LANCZOS), s[1] - (w - s[0].width) / 2, s[2])
    # chấm dưới
    p = g.get(ord("."))
    d["cham"] = p.img.crop(p.img.getchannel("A").getbbox()) if p else None
    # râu: dấu phẩy xoay 180°, thu về ~42% chiều cao chữ thường / ~34% chữ hoa
    #   (để nguyên cỡ dấu phẩy thì râu to như dấu nháy rời, nhìn không ra ơ ư)
    c = g.get(ord(","))
    if c and ord("x") in g and ord("H") in g:
        a = c.img.crop(c.img.getchannel("A").getbbox()).rotate(180, expand=True)
        cao_x = g[ord("x")].hop()[3] - g[ord("x")].hop()[1]
        cao_H = g[ord("H")].hop()[3] - g[ord("H")].hop()[1]

        def co(h):
            h = max(4, int(h))
            return a.resize((max(3, int(a.width * h / a.height)), h), Image.LANCZOS)
        d["rau"] = co(cao_x * 0.42)
        d["rau_hoa"] = co(cao_H * 0.34)
    else:
        d["rau"] = d["rau_hoa"] = None
    return d


LH = {}


def dung(ten, xem=False):
    fnt, atlas, g = doc_font(ten)
    LH[ten] = int(re.search(r'lineHeight="(\d+)"', fnt).group(1))
    base_line = int(re.search(r'base="(\d+)"', fnt).group(1))
    dau = chuan_bi_dau(g)
    if dau["cham"] is None:
        print(f"  ✗ {ten}: thiếu glyph cơ bản"); return None
    # font thiếu Đ/đ: Ð (U+00D0) nhìn y hệt Đ; đ = d + gạch
    moi = {}
    if ord("Đ") not in g and ord("Ð") in g:
        # phải đưa vào `moi` để GHI RA fnt — chỉ gán vào g thì file font vẫn thiếu Đ
        moi[ord("Đ")] = g[ord("Đ")] = g[ord("Ð")]
    for ch in CHU_VIET:
        if ord(ch) in g:
            continue
        if ch == "đ":
            if ord("d") in g and ord("-") in g:
                D = g[ord("d")]
                gach = g[ord("-")].img
                gach = gach.crop(gach.getchannel("A").getbbox())
                x0, y0, x1, y1 = D.hop()
                w = max(3, int((x1 - x0) * 0.75))
                gach = gach.resize((w, max(2, gach.height)), Image.LANCZOS)
                nen = Image.new("RGBA", (D.img.width + 20, D.img.height + 10), (0, 0, 0, 0))
                nen = dan(nen, D.img, 5, 5)
                nen = dan(nen, gach, 5 + (x1 - D.xo) - w + 2, 5 + (y0 - D.yo) + int((y1 - y0) * 0.18))
                b = nen.getbbox()
                moi[ord(ch)] = g[ord(ch)] = Glyph(nen.crop(b), D.xo - 5 + b[0], D.yo - 5 + b[1], D.adv)
            continue
        gl = ghep(g, ch, dau, base_line)
        if gl:
            moi[ord(ch)] = gl
            g[ord(ch)] = gl   # để chữ sau dùng làm nền (vd ơ → ờ)
    # xếp glyph mới xuống dưới atlas cũ
    SW = atlas.width
    x = y = 2
    hang = 0
    cho = {}
    for cid in sorted(moi):
        im = moi[cid].img
        if x + im.width + 2 > SW:
            x, y, hang = 2, y + hang + 2, 0
        cho[cid] = (x, y)
        x += im.width + 2
        hang = max(hang, im.height)
    them = y + hang + 4
    SH = atlas.height
    H2 = SH + them
    # làm tròn lên luỹ thừa của 2 như atlas gốc (512, 1024…) — tránh lỗi texture NPOT
    p2 = 1
    while p2 < H2:
        p2 *= 2
    H2 = p2
    moi_atlas = Image.new("RGBA", (SW, H2), (0, 0, 0, 0))
    moi_atlas.paste(atlas, (0, 0))
    dong = []
    for cid, (px, py) in cho.items():
        gl = moi[cid]
        moi_atlas.paste(gl.img, (px, SH + py))
        dong.append(f'    <char id="{cid}" x="{px}" y="{SH + py}" width="{gl.img.width}" height="{gl.img.height}" '
                    f'xoffset="{gl.xo}" yoffset="{gl.yo}" xadvance="{gl.adv}" page="0" chnl="15" />')
    fnt2 = re.sub(r'scaleH="\d+"', f'scaleH="{H2}"', fnt, count=1)
    so = len(re.findall(r"<char ", fnt)) + len(dong)
    fnt2 = re.sub(r'<chars count="\d+">', f'<chars count="{so}">', fnt2, count=1)
    fnt2 = fnt2.replace("</chars>", "\n".join(dong) + "\n  </chars>", 1)
    RA.mkdir(exist_ok=True)
    tam = RA / f".tmp_{ten}.tex"
    ktex.write(moi_atlas, str(tam), "DXT5")
    with zipfile.ZipFile(RA / f"vi_{ten}.zip", "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("font.fnt", fnt2)
        z.write(tam, "font.tex")
    tam.unlink()
    thieu = [c for c in CHU_VIET if ord(c) not in g and ord(c) not in moi]
    print(f"  {ten:26s} +{len(moi):3d} chữ  atlas {SW}x{H2}" + (f"  ⚠ còn thiếu: {''.join(thieu)}" if thieu else ""))
    if xem:
        thu_ve(ten, g, base_line)
    return len(moi)


def thu_ve(ten, g, base_line):
    """Vẽ câu thử bằng chính metric của font → viec/font_thu_<ten>.png."""
    cau = ["Tiếng Việt: ạ ả ã ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ đ", "ơ ớ ờ ở ỡ ợ ư ứ ừ ử ữ ự ỳ ỷ ỹ ỵ",
           "ĐỪNG CHẾT ĐÓI — Ở ĐÂY, ƯỚT SŨNG, ỔN ĐỊNH", "Nguyễn Thị Hường — Bóng Tối trỗi dậy!"]
    lh = LH.get(ten, 50)
    W, H = 1400, (lh + 20) * len(cau) + 20
    nen = Image.new("RGBA", (W, H), (60, 50, 40, 255))
    y = 10
    for s in cau:
        x = 10
        for ch in s:
            gl = g.get(ord(ch))
            if gl is None:
                x += 20
                continue
            nen = dan(nen, gl.img, x + gl.xo, y + gl.yo)
            x += gl.adv
        y += lh + 20
    (GOC / "viec").mkdir(exist_ok=True)
    nen.save(GOC / "viec" / f"font_thu_{ten}.png")


def main():
    xem = "--xem" in sys.argv
    chi = [a for a in sys.argv[1:] if not a.startswith("--")]
    print(f"Chữ tiếng Việt cần có: {len(CHU_VIET)}")
    for ten in FONT:
        if chi and ten not in chi:
            continue
        dung(ten, xem)
    print(f"→ {RA}/vi_*.zip")


if __name__ == "__main__":
    main()

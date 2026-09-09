#!/usr/bin/env python3
"""Dò chữ tiếng Việt tràn khung trong giao diện đã build.

Widget DST không tự xuống dòng: chuỗi Hán 2 ký tự vừa khít ô, chuỗi Việt cùng
nghĩa dài gấp 2-4 lần nên tràn. Script ước lượng bề ngang chữ rồi so với bề
ngang widget đọc thẳng từ mã, để khỏi phải soi từng ảnh chụp màn hình.

Hằng số đo từ ảnh chụp thật (xem docs/): ở cỡ chữ 20, một ký tự Latin chiếm
~6,46 đơn vị game; button_large.tex là 188x84 px nên ở scale s rộng 188*s.
"""
import re, sys, pathlib

CHAR_W   = 6.46 / 20        # đơn vị game / (ký tự * cỡ chữ)
BTN_W_PX = 188.0            # button_large.tex

# Bề ngang (px) của phần tử atlas dùng làm nền nút. Lấy từ (u2-u1)*bề_ngang_atlas:
# ui.tex 2048px, global.tex và hh_white.tex đọc trực tiếp từ header KTEX.
TEX_W = {
    ("images/global.xml", "square.tex"): 64.0,
    ("images/ui.xml", "button_large.tex"): 188.0,
    ("images/hh_icon/hh_white.xml", "hh_white.tex"): 7.0,
}
LE = 10                     # lề an toàn

def w(text, size):
    return len(text) * CHAR_W * size

def main(root):
    files = sorted(pathlib.Path(root).rglob("scripts/widgets/**/*.lua"))
    loi = 0
    for f in files:
        src = f.read_text(encoding="utf-8")
        m = re.search(r"hh_main_size_x, hh_main_size_y = (\d+), (\d+)", src)
        if not m:
            continue
        nua = int(m.group(1)) / 2

        # ── nhãn nằm trong nút ──
        for bm in re.finditer(
            r'\["(\w+)"\] = HH_UTILS:HHCreateBtnUi\([^)]*?"button_large\.tex",'
            r'\s*Vector3\([^)]*\),\s*([\d.]+)', src):
            ten, sc = bm.group(1), float(bm.group(2))
            lm = re.search(r'\["%s"\]\["hh_str"\][^\n]*?"([^"]+)", \w+, (\d+)\)'
                           % re.escape(ten), src)
            if not lm:
                continue
            chu, cd = lm.group(1), int(lm.group(2))
            rong, suc = w(chu, cd), BTN_W_PX * sc
            if rong > suc - 4:
                loi += 1
                print(f"  NÚT   {f.name}:{ten}  {chu!r} = {rong:.0f} đv > nút {suc:.0f} đv")

        # ── nhãn trong HHCreateImageButton (đối số là TỈ LỆ, không phải kích thước) ──
        # bề ngang thật = tỉ lệ * bề ngang phần tử trong atlas; tra từ TEX_W.
        so = {}
        for lm in re.finditer(r"local ([\w, ]+?) = ([\d., ]+)$", src, re.M):
            ten = [t.strip() for t in lm.group(1).split(",")]
            gt = [g.strip() for g in lm.group(2).split(",")]
            if len(ten) == len(gt):
                for t, g in zip(ten, gt):
                    try: so[t] = float(g)
                    except ValueError: pass
        atlas = dict(re.findall(r'local (\w+), (\w+) = "([^"]+)", "([^"]+)"', src) and
                     [(m[0], (m[2], m[3])) for m in
                      re.findall(r'local (\w+), (\w+) = "([^"]+)", "([^"]+)"', src)])

        def tri(bt):
            """Tính một đối số dạng số, tên biến, hoặc A / B."""
            bt = bt.strip()
            m = re.fullmatch(r"([\w.]+)\s*/\s*([\w.]+)", bt)
            if m:
                a, b = tri(m.group(1)), tri(m.group(2))
                return a / b if a is not None and b else None
            try: return float(bt)
            except ValueError: return so.get(bt)

        for bm in re.finditer(
            r'\["(\w+)"\] = HH_UTILS:HHCreateImageButton\(\w+(?:\[[^\]]*\])*,\s*'
            r'(\w+), (\w+),[^\n]*?Vector3\([^)]*\),\s*'
            r'([\w. /]+?),\s*([\w. /]+?)[,)]', src):
            ten, xml_v, ti_le = bm.group(1), bm.group(2), tri(bm.group(4))
            px = TEX_W.get(atlas.get(xml_v))
            if ti_le is None or px is None:
                continue
            suc = ti_le * px
            lm = re.search(r'\["%s"\]\["hh_text"\][^\n]*?"([^"]+)", \w+, (\d+)\)'
                           % re.escape(ten), src)
            if not lm:
                continue
            chu, cd = lm.group(1), int(lm.group(2))
            rong = w(chu, cd)
            if rong > suc - 4:
                loi += 1
                print(f"  NÚT   {f.name}:{ten}  {chu!r} = {rong:.0f} đv > nút {suc:.0f} đv")

        # ── khối nhiều dòng canh trái (direction 3/4) ──
        for cm in re.finditer(
            r'\["(\w+)"\] = HH_UTILS:CreateMoreTextUi\(\w+, \{(.*?)\}\s*,\s*(\d)\)',
            src, re.S):
            ten, than, huong = cm.group(1), cm.group(2), int(cm.group(3))
            pm = re.search(r'\["%s"\]:SetPosition\((-?[\d.]+),' % re.escape(ten), src)
            if not pm or huong not in (3, 4):
                continue
            x = float(pm.group(1))
            for dm in re.finditer(r'\["str"\] = "([^"]+)".*?\["scale"\] = (\d+)', than):
                chu, cd = dm.group(1), int(dm.group(2))
                phai = x + w(chu, cd)
                if phai > nua - LE:
                    loi += 1
                    print(f"  KHỐI  {f.name}:{ten}  hết ở {phai:.0f} > mép {nua-LE:.0f}"
                          f"  {chu!r}")

        # ── chữ rời, canh giữa ──
        for tm in re.finditer(
            r'HH_UTILS:HHCreateTextUi\(\w+, Vector3\((-?[\d.]+), (-?[\d.]+), 1\),\s*'
            r'"([^"]+)",\s*(?:nil|\{[^}]*\}),\s*(\d+)\)', src):
            x, chu, cd = float(tm.group(1)), tm.group(3), int(tm.group(4))
            nua_chu = w(chu.replace("\\n", "\n").split("\n")[0], cd) / 2
            if abs(x) + nua_chu > nua - LE:
                loi += 1
                print(f"  CHỮ   {f.name}  x={x:.0f} rộng {nua_chu*2:.0f} → "
                      f"tràn mép {nua-LE:.0f}  {chu!r}")
    # ── nhãn 2 dòng vẽ đè lên icon vật phẩm ──
    # đo thực tế: ở cỡ chữ 40 một ký tự Latin chiếm ~14,5 đv (rộng hơn chữ
    # trong bảng vì font icon khác), ô icon túi đồ 64 đv, ô lưới 40 đv.
    ICON = 14.5 / 40
    for f in sorted(pathlib.Path(root).rglob("scripts/enums/hh_enchant.lua")) + \
             sorted(pathlib.Path(root).rglob("scripts/job/hh_job_config.lua")):
        src = f.read_text(encoding="utf-8")
        for m in re.finditer(r'\["client_text"\] = "([^"]+)"', src):
            nhan = m.group(1)
            for cd, o in ((24, 64), (14, 40)):
                rong = max(len(d) for d in nhan.split("\\n")) * ICON * cd
                if rong > o:
                    loi += 1
                    print(f"  ICON  {f.name}  {nhan!r} = {rong:.0f} đv > ô {o} đv (cỡ {cd})")
                    break

    print(f"\n{loi} chỗ tràn" if loi else "\nkhông có chỗ nào tràn")
    return 1 if loi else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "build/than-binh-phu-an-vi"))

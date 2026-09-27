#!/usr/bin/env python3
"""Chia việc dịch / soát thành các file TSV nhỏ trong viec/ để dịch song song.

    python3 tools/xuat_viec.py soat_names   [co_lo]   # soát STRINGS.NAMES
    python3 tools/xuat_viec.py soat_khac    [co_lo]   # soát RECIPE_DESC + ACTIONS
    python3 tools/xuat_viec.py soat_skin    [co_lo]   # thống nhất SKIN_NAMES theo bảng bộ sưu tập
    python3 tools/xuat_viec.py soat_skin_mo_ta [co_lo] # soát SKIN_DESCRIPTIONS + SKIN_QUOTES (dịch máy)
    python3 tools/xuat_viec.py soat_mo_ta   [co_lo]   # soát SCRAPBOOK + SKILLTREE (dịch máy, nhiều lỗi)
    python3 tools/xuat_viec.py dich         [co_lo]   # mới + gốc đổi + chưa dịch
    python3 tools/xuat_viec.py dich_skin    [co_lo]   # SKIN_NAMES còn tiếng Anh
    python3 tools/xuat_viec.py tu_dien                # viec/tu_dien.tsv (NAMES en→vi)

Mỗi dòng: khoa<TAB>en<TAB>vi_hien_tai<TAB>goi_y. `goi_y` = tên vật được nói
tới (NAMES.<vật> tiếng Anh → Việt) để câu soi đồ dùng đúng tên đã dịch.
Kết quả trả về: viec/<lo>.ra.tsv, mỗi dòng khoa<TAB>vi — áp bằng tools/ap_viec.py.
"""

import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import po  # noqa: E402
from sync_check import la_chua_dich  # noqa: E402

GOC = pathlib.Path(__file__).resolve().parent.parent
VIEC = GOC / "viec"

# Tên người trong credits, mã nội bộ chưa đặt tên — giữ nguyên, không dịch.
BO_QUA = re.compile(r"^STRINGS\.UI\.CREDITS\.|\.(?:DESC|TITLE)$(?<=laq_beetle1\.DESC)")


def esc(s):
    return s.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n")


def nap():
    _, mp = po.doc(GOC / "game_source/strings.pot")
    _, mv = po.doc(GOC / "vietnamese.po")
    return {m.ctx: m for m in mp}, {m.ctx: m for m in mv}


def goi_y(khoa, P, V):
    p = khoa.split(".")
    if len(p) > 4 and p[1] == "CHARACTERS" and p[3] == "DESCRIBE":
        k = "STRINGS.NAMES." + p[4]
        if k in P:
            return f"{P[k].id} = {V[k].str if k in V and V[k].str else '?'}"
    return ""


def ghi_lo(ten, dong, co_lo):
    VIEC.mkdir(exist_ok=True)
    # quy tắc dịch: bản chính ở tools/HUONG_DAN.md (viec/ bị gitignore)
    hd = GOC / "tools" / "HUONG_DAN.md"
    if hd.exists() and not (VIEC / "HUONG_DAN.md").exists():
        (VIEC / "HUONG_DAN.md").write_text(hd.read_text(encoding="utf-8"), encoding="utf-8")
    for f in VIEC.glob(f"{ten}_*.tsv"):
        if not f.name.endswith(".ra.tsv"):
            f.unlink()
    lo = [dong[i:i + co_lo] for i in range(0, len(dong), co_lo)]
    for i, phan in enumerate(lo, 1):
        with open(VIEC / f"{ten}_{i:02d}.tsv", "w", encoding="utf-8") as f:
            f.write("khoa\ten\tvi_hien_tai\tgoi_y\n")
            f.writelines("\t".join(esc(x) for x in r) + "\n" for r in phan)
    print(f"{ten}: {len(dong)} dòng → {len(lo)} lô ({co_lo}/lô) trong viec/")


def main():
    lenh = sys.argv[1]
    co_lo = int(sys.argv[2]) if len(sys.argv) > 2 else 400
    P, V = nap()
    if lenh == "tu_dien":
        VIEC.mkdir(exist_ok=True)
        with open(VIEC / "tu_dien.tsv", "w", encoding="utf-8") as f:
            f.write("khoa\ten\tvi\n")
            for k, m in sorted(P.items()):
                if k.startswith("STRINGS.NAMES.") and k in V and V[k].str:
                    f.write(f"{k}\t{esc(m.id)}\t{esc(V[k].str)}\n")
        print("viec/tu_dien.tsv")
        return
    dong = []
    for k, p in sorted(P.items()):
        v = V.get(k)
        if lenh == "soat_names" and k.startswith("STRINGS.NAMES.") and v and v.str:
            dong.append((k, p.id, v.str, ""))
        elif lenh == "soat_skin" and k.startswith("STRINGS.SKIN_NAMES.") and v and v.str:
            dong.append((k, p.id, v.str, ""))
        elif lenh == "soat_skin_mo_ta" and k.startswith(("STRINGS.SKIN_DESCRIPTIONS.", "STRINGS.SKIN_QUOTES.")) and v and v.str:
            ten = V.get("STRINGS.SKIN_NAMES." + k.split(".", 2)[2])
            dong.append((k, p.id, v.str, f"tên trang phục: {ten.str}" if ten and ten.str else ""))
        elif lenh == "soat_mo_ta" and k.startswith(("STRINGS.SCRAPBOOK.", "STRINGS.SKILLTREE.")) and v and v.str:
            dong.append((k, p.id, v.str, ""))
        elif lenh == "soat_khac" and k.startswith(("STRINGS.RECIPE_DESC.", "STRINGS.ACTIONS.")) and v and v.str:
            dong.append((k, p.id, v.str, ""))
        elif lenh == "dich" and not k.startswith("STRINGS.SKIN_NAMES.") and not BO_QUA.search(k):
            if v is None or v.id != p.id or la_chua_dich(v):
                dong.append((k, p.id, v.str if v else "", goi_y(k, P, V)))
        elif lenh == "dich_skin" and k.startswith("STRINGS.SKIN_NAMES.") and (v is None or la_chua_dich(v)):
            dong.append((k, p.id, v.str if v else "", ""))
    ghi_lo(lenh, dong, co_lo)


if __name__ == "__main__":
    main()

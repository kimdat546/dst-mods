#!/usr/bin/env python3
"""Áp kết quả dịch/soát (viec/*.ra.tsv: khoa<TAB>vi) vào vietnamese.po.

    python3 tools/ap_viec.py viec/soat_names_*.ra.tsv      # áp các file chỉ định
    python3 tools/ap_viec.py --dong-bo                     # chỉ đồng bộ với strings.pot

Luôn làm kèm, theo strings.pot của game:
  • khoá mới → thêm mục (đặt cạnh khoá gần nhất theo thứ tự chữ cái)
  • msgid cập nhật theo tiếng Anh hiện tại của game
  • khoá game đã bỏ → xoá
Từ chối dòng: khoá không có trong game, placeholder lệch, có tab, còn ghi chú
người dịch "(Chơi chữ…", "(Lưu ý…". Dòng bị từ chối in ra để sửa tay.
Ghi lại toàn file — dấu nháy kép trong msgstr được thoát đúng (bản cũ có 55
dòng `"` trần, game đọc tới đó là cắt chuỗi).
"""

import bisect
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import po  # noqa: E402

GOC = pathlib.Path(__file__).resolve().parent.parent
GHI_CHU = re.compile(r"\((?:Chơi chữ|chơi chữ|Ghi chú|Lưu ý: *\"|Note:)")


def giai(s):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t", "\\": "\\"}.get(m.group(1), "\\" + m.group(1)), s)


def main():
    tep = [a for a in sys.argv[1:] if not a.startswith("--")]
    _, mp = po.doc(GOC / "game_source/strings.pot")
    dau, mv = po.doc(GOC / "vietnamese.po")
    P = {m.ctx: m for m in mp}

    moi = {}
    tu_choi = []
    for t in tep:
        for so, dong in enumerate(open(t, encoding="utf-8"), 1):
            dong = dong.rstrip("\n").rstrip("\r")
            if not dong.strip() or dong.startswith("khoa\t"):
                continue
            if dong.count("\t") != 1:
                tu_choi.append(f"{t}:{so}: không đúng 2 cột"); continue
            k, vi = dong.split("\t")
            k, vi = k.strip(), giai(vi).strip(" ")
            if k not in P:
                tu_choi.append(f"{t}:{so}: khoá không có trong game: {k}"); continue
            if not vi.strip():
                tu_choi.append(f"{t}:{so}: bản dịch rỗng: {k}"); continue
            if po.placeholder(P[k].id) != po.placeholder(vi):
                tu_choi.append(f"{t}:{so}: placeholder {po.placeholder(P[k].id)} ≠ {po.placeholder(vi)}: {k}"); continue
            if GHI_CHU.search(vi) and not GHI_CHU.search(P[k].id):
                tu_choi.append(f"{t}:{so}: còn ghi chú người dịch: {k}"); continue
            moi[k] = vi

    # đồng bộ khoá với game
    giu = [m for m in mv if m.ctx in P]
    bo = len(mv) - len(giu)
    co = {m.ctx for m in giu}
    for m in giu:
        m.id = P[m.ctx].id
        if m.ctx in moi:
            m.str = moi[m.ctx]
    khoa_sx = sorted(co)
    them = 0
    vi_tri = {m.ctx: i for i, m in enumerate(giu)}
    chen = {}
    for k in sorted(set(P) - co):
        m = po.Muc(k, P[k].id, moi.get(k, ""), [f"#. {k}"])
        j = bisect.bisect_left(khoa_sx, k)
        truoc = khoa_sx[j - 1] if j > 0 else None
        chen.setdefault(truoc, []).append(m)
        them += 1
    ra = chen.get(None, [])[:]
    for m in giu:
        ra.append(m)
        ra.extend(chen.get(m.ctx, []))
    po.ghi(GOC / "vietnamese.po", dau, ra)

    ap = sum(1 for k in moi)
    print(f"áp {ap} dòng từ {len(tep)} file · thêm {them} khoá mới · xoá {bo} khoá game đã bỏ · tổng {len(ra)}")
    if tu_choi:
        print(f"⚠ từ chối {len(tu_choi)} dòng:")
        print("\n".join("  " + x for x in tu_choi[:60]))


if __name__ == "__main__":
    main()

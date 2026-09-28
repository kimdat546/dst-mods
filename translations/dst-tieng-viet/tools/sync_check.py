#!/usr/bin/env python3
"""So bản dịch với strings.pot của game — chạy sau mỗi lần game cập nhật.

    python3 tools/sync_check.py [game_source/strings.pot] [vietnamese.po]

Lấy strings.pot mới từ game:
    unzip -p ".../dontstarve_steam.app/Contents/data/databundles/scripts.zip" \\
        scripts/languages/strings.pot > game_source/strings.pot

Báo (và ghi sync_reports/sync_<ngày>.md + .tsv để dịch tiếp):
  moi        khoá có trong game, chưa có trong .po
  doi_goc    tiếng Anh gốc ĐÃ ĐỔI so với lúc dịch → bản dịch có thể lỗi thời
  bo         khoá .po có mà game đã bỏ (vô hại, chỉ thừa)
  chua_dich  msgstr rỗng, hoặc y hệt tiếng Anh dù có chữ cần dịch
  placeholder  %s / {name} lệch giữa gốc và bản dịch → hiện sai hoặc lỗi
"""

import collections
import datetime
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import po  # noqa: E402

GOC = pathlib.Path(__file__).resolve().parent.parent

# Chuỗi giữ nguyên tiếng Anh là ĐÚNG (tên riêng, ký hiệu…) thì không tính là chưa dịch.
_KHONG_CAN_DICH = re.compile(r"^[\W\d_]*$|^[A-Z][a-z]+$|^(?:[A-Z0-9-]+\s?)+$")


def la_chua_dich(m):
    # only_used_by_* / not_used_by_*: mã giữ chỗ trong speech_*.lua, game không hiện ra → giữ nguyên
    if m.id.startswith(("only_used_by", "not_used_by")):
        return False
    if not m.str.strip():
        return bool(re.search(r"[A-Za-z]", m.id))
    if m.str == m.id and re.search(r"[a-z]{3,}", m.id):
        return not _KHONG_CAN_DICH.match(m.id.strip())
    return False


def main():
    pot = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else GOC / "game_source/strings.pot"
    vi = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else GOC / "vietnamese.po"
    _, mp = po.doc(pot)
    _, mv = po.doc(vi)
    P = {m.ctx: m for m in mp}
    V = {m.ctx: m for m in mv}

    moi = [P[k] for k in P if k not in V]
    doi = [(P[k], V[k]) for k in P if k in V and P[k].id != V[k].id]
    bo = [V[k] for k in V if k not in P]
    chua = [V[k] for k in V if k in P and P[k].id == V[k].id and la_chua_dich(V[k])]
    ph = [V[k] for k in V if k in P and V[k].str.strip()
          and po.placeholder(P[k].id) != po.placeholder(V[k].str)]

    def nhom(ds):
        c = collections.Counter(".".join(m.ctx.split(".")[:2]) for m in ds)
        return ", ".join(f"{k} {n}" for k, n in c.most_common(8))

    print(f"game: {len(P)} khoá   bản dịch: {len(V)} khoá")
    for ten, ds in (("mới", moi), ("gốc đã đổi", doi), ("game đã bỏ", bo),
                    ("chưa dịch", chua), ("placeholder lệch", ph)):
        ds2 = [x[0] if isinstance(x, tuple) else x for x in ds]
        print(f"  {ten:17s} {len(ds):6d}   {nhom(ds2)}")

    ngay = datetime.date.today().isoformat()
    ra = GOC / "sync_reports"
    ra.mkdir(exist_ok=True)
    esc = lambda s: s.replace("\t", "\\t").replace("\n", "\\n")  # noqa: E731
    with open(ra / f"sync_{ngay}.tsv", "w", encoding="utf-8") as f:
        f.write("loai\tkhoa\ten_moi\ten_cu\tvi_hien_tai\n")
        for m in moi:
            f.write(f"moi\t{m.ctx}\t{esc(m.id)}\t\t\n")
        for p, v in doi:
            f.write(f"doi_goc\t{p.ctx}\t{esc(p.id)}\t{esc(v.id)}\t{esc(v.str)}\n")
        for v in chua:
            f.write(f"chua_dich\t{v.ctx}\t{esc(v.id)}\t\t{esc(v.str)}\n")
        for v in ph:
            f.write(f"placeholder\t{v.ctx}\t{esc(P[v.ctx].id)}\t\t{esc(v.str)}\n")
    with open(ra / f"sync_{ngay}.md", "w", encoding="utf-8") as f:
        f.write(f"# Sync {ngay}\n\ngame `{pot.name}`: {len(P)} khoá, bản dịch: {len(V)} khoá\n\n")
        f.write(f"| loại | số | nhóm lớn |\n|---|---|---|\n")
        for ten, ds in (("mới", moi), ("gốc đã đổi", [p for p, _ in doi]), ("game đã bỏ", bo),
                        ("chưa dịch", chua), ("placeholder lệch", ph)):
            f.write(f"| {ten} | {len(ds)} | {nhom(ds)} |\n")
        f.write(f"\nChi tiết: `sync_{ngay}.tsv`\n")
    print(f"→ sync_reports/sync_{ngay}.md / .tsv")


if __name__ == "__main__":
    main()

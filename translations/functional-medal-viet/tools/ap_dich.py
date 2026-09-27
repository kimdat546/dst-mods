#!/usr/bin/env python3
"""Ghi bản dịch vào strings_source.json.

  ./tools/ap_dich.py < bang.tsv        mỗi dòng: <khoá>\\t<tiếng Việt>
  ./tools/ap_dich.py --xem <tiền tố> [n]  in chuỗi CHƯA dịch: khoá, en, zh

Dòng trong tiếng Việt dùng \\n để xuống dòng.
"""
import json, pathlib, sys
T = pathlib.Path(__file__).resolve().parent.parent / "strings_source.json"
d = json.loads(T.read_text(encoding="utf-8"))

if len(sys.argv) > 1 and sys.argv[1] == "--xem":
    tt = sys.argv[2]; n = int(sys.argv[3]) if len(sys.argv) > 3 else 9999
    ks = [k for k in sorted(d) if k.startswith(tt) and not d[k]["vi"]]
    print(f"(còn {len(ks)} chưa dịch với tiền tố {tt})")
    for k in ks[:n]:
        en = d[k]["en"].replace("\n", "\\n"); zh = d[k]["zh"].replace("\n", "\\n")
        print(f"{k}\t{en}\t{zh}")
    sys.exit(0)

n, sai = 0, []
for dong in sys.stdin.read().splitlines():
    if not dong.strip():
        continue
    k, _, v = dong.partition("\t")
    k = k.strip()
    if k not in d:
        sai.append(k); continue
    d[k]["vi"] = v.replace("\\n", "\n")  # KHÔNG strip: nhiều chuỗi được nối, dấu cách đầu/cuối là có nghĩa
    n += 1
T.write_text(json.dumps(d, ensure_ascii=False, indent=1, sort_keys=True) + "\n", encoding="utf-8")
con = sum(1 for v in d.values() if not v["vi"])
print(f"+{n} — còn {con}/{len(d)}")
for k in sai:
    print("  !! không có khoá:", k)

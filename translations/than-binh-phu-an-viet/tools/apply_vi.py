#!/usr/bin/env python3
"""Ghi bản dịch vào strings_source.json.

    echo '{"打孔石":"Đá Đục Lỗ"}' | python3 tools/apply_vi.py

Nhận JSON {chuỗi_gốc: bản_dịch} qua stdin. Chuỗi gốc phải khớp đúng khoá đã có
trong strings_source.json, sai khoá thì báo ra chứ không ghi bừa.
"""
import json, sys
from pathlib import Path

SRC = Path(__file__).resolve().parent.parent / "strings_source.json"
table = json.loads(SRC.read_text(encoding="utf-8"))
patch = json.load(sys.stdin)

ok = miss = same = 0
for zh, vi in patch.items():
    if zh not in table:
        print(f"  ⚠ không có khoá: {zh[:50]}")
        miss += 1
        continue
    if table[zh]["vi"] == vi:
        same += 1
        continue
    table[zh]["vi"] = vi
    ok += 1

SRC.write_text(json.dumps(table, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
               encoding="utf-8")
total = len(table)
done = sum(1 for r in table.values() if r["vi"])
print(f"ghi {ok} chuỗi (trùng sẵn {same}, sai khoá {miss}) — tiến độ {done}/{total} ({done*100//total}%)")

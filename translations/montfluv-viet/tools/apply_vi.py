#!/usr/bin/env python3
"""Ghi bản dịch vào strings_source.json.

    python3 tools/apply_vi.py <file.json>     # {"chuỗi Hán": "bản dịch", ...}
    cat batch.json | python3 tools/apply_vi.py -
"""
import json, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "strings_source.json"

raw = sys.stdin.read() if sys.argv[1] == "-" else pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
batch = json.loads(raw)
table = json.loads(SRC.read_text(encoding="utf-8"))

ok = miss = same = 0
for zh, vi in batch.items():
    if zh not in table:
        print(f"  ⚠ không có trong nguồn: {zh!r}")
        miss += 1
        continue
    if table[zh]["vi"] == vi:
        same += 1
    table[zh]["vi"] = vi
    ok += 1

SRC.write_text(json.dumps(table, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
done = sum(1 for r in table.values() if r["vi"])
print(f"ghi {ok} chuỗi ({same} trùng bản cũ, {miss} không khớp) "
      f"→ {done}/{len(table)} ({done*100//len(table)}%)")

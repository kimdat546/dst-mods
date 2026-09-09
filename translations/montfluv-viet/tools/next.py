#!/usr/bin/env python3
"""In ra lô chuỗi chưa dịch tiếp theo (mặc định 100), kèm tham chiếu tiếng Anh."""
import json, pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
d = json.loads((ROOT / "strings_source.json").read_text(encoding="utf-8"))
n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
filt = sys.argv[2] if len(sys.argv) > 2 else ""
todo = [(zh, r) for zh, r in d.items() if not r["vi"] and (not filt or filt in r["o"][0])]
print(f"### còn {len(todo)} chưa dịch (in {min(n,len(todo))}) — ngữ cảnh: {todo[0][1]['o'][0] if todo else '-'}" if todo else "### xong hết")
for zh, r in todo[:n]:
    en = r.get("en", "")
    print(f"{zh}\t{en}\t{r['o'][0]}")

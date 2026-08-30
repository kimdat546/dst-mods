#!/usr/bin/env python3
"""Trích mọi chuỗi tiếng Trung trong vendor/ ra strings_source.json để dịch.

    python3 tools/extract_strings.py           # trích, giữ bản dịch đã có
    python3 tools/extract_strings.py --stats   # chỉ thống kê, không ghi file

Chỉ lấy chuỗi nằm trong nháy kép của Lua — comment `--` bị bỏ qua, vì dịch
comment không đổi gì trong game và chỉ làm loãng file dịch.

Mỗi mục có `ctx` (loại chuỗi, đoán từ ngữ cảnh dòng) để dịch đúng giọng:
tên vật phẩm, mô tả, thông báo lỗi, nhãn nút, text trợ giúp…
"""

import argparse
import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENDOR = ROOT / "vendor"
OUT = ROOT / "strings_source.json"

HAN = re.compile(r"[一-鿿]")
# chuỗi Lua trong nháy kép, không bắc qua dòng
LUA_STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')

# đoán loại chuỗi từ chính dòng chứa nó
CTX_RULES = [
    (re.compile(r'\["name"\]|\bname\b\s*='), "ten"),
    (re.compile(r'\["desc"\]|\bdesc\b\s*=|describe'), "mo_ta"),
    (re.compile(r'recipe_str'), "cong_thuc"),
    (re.compile(r'HHSay|Say\(|announce|Announce'), "thong_bao"),
    (re.compile(r'label|title|btn|button|text\s*='), "nhan_ui"),
    (re.compile(r'hover'), "chu_thich"),
    (re.compile(r'print|Debug|debug|GetDebugString'), "debug"),
]


def guess_ctx(line: str) -> str:
    for pat, tag in CTX_RULES:
        if pat.search(line):
            return tag
    return "khac"


def is_code_like(s: str) -> bool:
    """Chuỗi định dạng UI của mod (#text:color:size, @icon::w:h) — dịch phần chữ,
    nhưng đánh dấu để người dịch giữ nguyên phần cú pháp."""
    return s.startswith(("#", "@")) or "::" in s


def collect():
    items = {}
    for f in sorted(VENDOR.rglob("*.lua")):
        rel = str(f.relative_to(VENDOR))
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        for lineno, line in enumerate(text.split("\n"), 1):
            code = line.split("--", 1)[0] if not line.lstrip().startswith("--") else ""
            if not code or not HAN.search(code):
                continue
            for m in LUA_STR.finditer(code):
                s = m.group(1)
                if not HAN.search(s):
                    continue
                rec = items.setdefault(s, {
                    "vi": "",
                    "ctx": guess_ctx(code),
                    "fmt": is_code_like(s),
                    "o": [],
                })
                if len(rec["o"]) < 4:
                    rec["o"].append(f"{rel}:{lineno}")
    return items


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--stats", action="store_true", help="chỉ thống kê")
    args = ap.parse_args()

    items = collect()

    old = {}
    if OUT.exists():
        old = json.loads(OUT.read_text(encoding="utf-8"))
    kept = 0
    for zh, rec in items.items():
        if zh in old and old[zh].get("vi"):
            rec["vi"] = old[zh]["vi"]
            kept += 1

    by_ctx = Counter(r["ctx"] for r in items.values())
    print(f"chuỗi tiếng Trung cần dịch: {len(items)}")
    print(f"đã có bản dịch giữ lại:     {kept}")
    print("\ntheo loại:")
    for ctx, n in by_ctx.most_common():
        done = sum(1 for r in items.values() if r["ctx"] == ctx and r["vi"])
        print(f"  {ctx:<12} {n:>5}   (đã dịch {done})")
    fmt_n = sum(1 for r in items.values() if r["fmt"])
    print(f"\nchuỗi có cú pháp UI (#màu / @icon): {fmt_n} — giữ nguyên phần cú pháp")

    if args.stats:
        return
    OUT.write_text(
        json.dumps(items, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"\n→ ghi {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

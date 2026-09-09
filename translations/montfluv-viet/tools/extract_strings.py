#!/usr/bin/env python3
"""Trích mọi chuỗi tiếng Trung trong vendor/shanhai_strings/translation_ch/
ra strings_source.json để dịch.

    python3 tools/extract_strings.py

Khoá của bảng là CHÍNH chuỗi tiếng Trung (giống các mod dịch khác trong
workspace), kèm danh sách vị trí xuất hiện để soi khi một chuỗi cần dịch
khác nhau tuỳ ngữ cảnh.
"""
import json, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "vendor" / "shanhai_strings" / "translation_ch"
EN_DIR = ROOT / "vendor" / "shanhai_strings"
OUT = ROOT / "strings_source.json"

HAN = re.compile(r"[一-鿿]")
# chuỗi Lua "..." có thoát, bỏ qua phần comment đuôi dòng
LUA_STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')


def strings_of(path):
    """→ [(key_lua, chuỗi)] theo thứ tự xuất hiện."""
    out = []
    for line in path.read_text(encoding="utf-8", errors="replace").split("\n"):
        code = line.split("--", 1)[0] if line.lstrip().startswith("--") else line
        if not HAN.search(code):
            continue
        key = None
        m = re.match(r"\s*([A-Za-z_][\w.\[\]\"']*)\s*=", code)
        if m:
            key = m.group(1)
        for s in LUA_STR.findall(code):
            if HAN.search(s):
                out.append((key, s))
    return out


def main():
    old = json.loads(OUT.read_text(encoding="utf-8")) if OUT.exists() else {}
    table, files = {}, 0
    for f in sorted(SRC_DIR.glob("*.lua")):
        files += 1
        for key, s in strings_of(f):
            rec = table.setdefault(s, {"vi": "", "o": []})
            loc = f"{f.name}:{key}" if key else f.name
            if loc not in rec["o"]:
                rec["o"].append(loc)
    # giữ lại bản dịch cũ
    kept = 0
    for zh, rec in table.items():
        if zh in old and old[zh].get("vi"):
            rec["vi"] = old[zh]["vi"]
            kept += 1
    # đối chiếu bản tiếng Anh của tác giả để tham khảo khi dịch
    en = {}
    for f in sorted(EN_DIR.glob("*.lua")):
        ch = SRC_DIR / f.name
        if not ch.exists():
            continue
        a, b = strings_of(ch), None
        b = [(k, s) for k, s in
             ((re.match(r"\s*([A-Za-z_][\w.\[\]\"']*)\s*=", l).group(1)
               if re.match(r"\s*([A-Za-z_][\w.\[\]\"']*)\s*=", l) else None, s)
              for l in f.read_text(encoding="utf-8", errors="replace").split("\n")
              for s in LUA_STR.findall(l))]
        bk = {k: s for k, s in b if k}
        for k, s in a:
            if k and k in bk and s in table and not table[s].get("en"):
                table[s]["en"] = bk[k]

    OUT.write_text(json.dumps(table, ensure_ascii=False, indent=1) + "\n",
                   encoding="utf-8")
    done = sum(1 for r in table.values() if r["vi"])
    print(f"{files} file → {len(table)} chuỗi duy nhất "
          f"({done} đã dịch, giữ lại {kept})")
    print(f"  có tham chiếu tiếng Anh: {sum(1 for r in table.values() if r.get('en'))}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Sinh scripts/shanhai_desc_vi.lua cho mod client từ desc_source.json.

    python3 tools/build_desc_lua.py

File sinh ra chỉ TRẢ VỀ dữ liệu; phần vá bảng nằm trong modmain.
"""
import json, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "desc_source.json"
OUT = ROOT / "build" / "montfluv-vi" / "scripts" / "shanhai_desc_vi.lua"


def lua_long(s):
    """Chuỗi long-bracket, tự nâng cấp số dấu = nếu nội dung có ]]...]]."""
    n = 0
    while ("]" + "=" * n + "]") in s or ("[" + "=" * n + "[") in s:
        n += 1
    eq = "=" * n
    # long-bracket nuốt newline đầu tiên → thêm một newline đệm
    return f"[{eq}[\n{s}]{eq}]"


def main():
    d = json.loads(SRC.read_text(encoding="utf-8"))
    pages = {k: v["vi"] for k, v in d["pages"].items() if v["vi"]}
    fields = {k: v["vi"] for k, v in d["fields"].items() if v["vi"]}
    ui = d.get("ui", {})

    out = [
        "--",
        "-- Nội dung “Cuộn Tranh Sơn Hà” (sh_desc) — bản tiếng Việt.",
        "-- SINH TỰ ĐỘNG bởi tools/build_desc_lua.py, đừng sửa tay.",
        "--",
        "-- Sách KHÔNG dùng hệ STRINGS; nó đọc bảng do",
        "-- shanhai_defs/sh_desc_contents.lua dựng, nên phải vá thẳng bảng đó.",
        "--",
        "local PAGES = {",
    ]
    for k in sorted(pages):
        out.append(f'\t["{k}"] = {lua_long(pages[k])},')
    out.append("}")
    out.append("")
    out.append("local FIELDS = {")
    for k in sorted(fields):
        out.append(f'\t["{k}"] = "{fields[k]}",')
    out.append("}")
    out.append("")
    out.append("local UI = {")
    for k in sorted(ui):
        out.append(f'\t["{k}"] = "{ui[k]}",')
    out.append("}")
    out.append("")
    out.append("return { PAGES = PAGES, FIELDS = FIELDS, UI = UI }")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"{len(pages)} trang + {len(fields)} truong + {len(ui)} nhan UI"
          f" -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

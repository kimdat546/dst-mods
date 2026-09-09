#!/usr/bin/env python3
"""Trích nội dung "Cuộn Tranh Sơn Hà" (sách hướng dẫn trong mod) ra desc_source.json.

    python3 tools/extract_desc.py

Sách KHÔNG dùng hệ STRINGS như phần còn lại của mod. Nó có hệ riêng:

    sh_desc_contents.lua:2   local sh_lan = TUNING.SHANHE_LAN or "ch"
                             local desc_contents = require("shanhai_defs/sh_desc_"..sh_lan)
    sh_desc_contents.lua:1757 v.description = desc_contents[u] or [[]]

nên phải trích riêng. Hai nguồn:
  1. sh_desc_ch.lua      — 104 khối [[...]] nội dung từng trang, khoá = tên prefab.
  2. sh_desc_contents.lua — các trường location/type hardcode chữ Hán ngay trong def.
"""
import json, pathlib, re

ROOT = pathlib.Path(__file__).resolve().parent.parent
DEFS = ROOT / "vendor" / "shanhai_defs"
OUT = ROOT / "desc_source.json"

HAN = re.compile(r"[一-鿿]")
# khoá = [[ ... ]] ở cấp thụt đầu dòng bất kỳ
BLOCK = re.compile(r"^[ \t]*(\w+)\s*=\s*\[\[(.*?)\]\]", re.S | re.M)
# trường chuỗi ngắn: location = "绿洲沙漠"
FIELD = re.compile(r"^[ \t]*(\w+)\s*=\s*\"([^\"\n]*)\"", re.M)


def doc_blocks(text, need_han=True):
    """need_han=False cho bản EN — nó không có chữ Hán nhưng vẫn cần đối chiếu."""
    return {k: v for k, v in BLOCK.findall(text) if not need_han or HAN.search(v)}


def main():
    ch = (DEFS / "sh_desc_ch.lua").read_text(encoding="utf-8")
    en = (DEFS / "sh_desc_en.lua").read_text(encoding="utf-8")
    contents = (DEFS / "sh_desc_contents.lua").read_text(encoding="utf-8")

    ch_blocks, en_blocks = doc_blocks(ch), doc_blocks(en, need_han=False)

    old = json.loads(OUT.read_text(encoding="utf-8")) if OUT.exists() else {}
    old_pages = old.get("pages", {})
    old_fields = old.get("fields", {})

    pages = {}
    for key, zh in ch_blocks.items():
        prev = old_pages.get(key, {})
        pages[key] = {
            "vi": prev.get("vi", ""),
            "zh": zh,
            "en": en_blocks.get(key, ""),
        }

    # trường ngắn trong sh_desc_contents.lua — gom theo giá trị, chỉ giữ chữ Hán
    fields = {}
    for name, val in FIELD.findall(contents):
        if not HAN.search(val):
            continue
        e = fields.setdefault(val, {"vi": old_fields.get(val, {}).get("vi", ""), "f": []})
        if name not in e["f"]:
            e["f"].append(name)

    # "ui" là 31 nhãn hardcode `SH_IS_CH and "中文" or "English"` trong widget —
    # không trích ra từ file được, dịch tay, nên chỉ mang sang nguyên vẹn.
    out = {"pages": pages, "fields": fields, "ui": old.get("ui", {})}
    OUT.write_text(
        json.dumps(out, ensure_ascii=False, indent=1) + "\n",
        encoding="utf-8",
    )
    done = sum(1 for v in pages.values() if v["vi"])
    print(f"trang sach : {done}/{len(pages)}")
    print(f"truong ngan: {sum(1 for v in fields.values() if v['vi'])}/{len(fields)}")
    print(f"-> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Nạp bản dịch tiếng Việt vào desc_source.json.

    python3 tools/apply_desc.py ban_dich.json

ban_dich.json: {"pages": {khoa: "van ban"}, "fields": {chuoi_han: "van ban"}}
"""
import json, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "desc_source.json"


def main():
    inp = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    d = json.loads(SRC.read_text(encoding="utf-8"))
    n = 0
    for k, vi in inp.get("pages", {}).items():
        if k not in d["pages"]:
            print(f"!! khong co trang: {k}")
            continue
        d["pages"][k]["vi"] = vi
        n += 1
    for k, vi in inp.get("fields", {}).items():
        if k not in d["fields"]:
            print(f"!! khong co truong: {k}")
            continue
        d["fields"][k]["vi"] = vi
        n += 1
    SRC.write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    done = sum(1 for v in d["pages"].values() if v["vi"])
    print(f"nap {n} muc | trang: {done}/{len(d['pages'])} | "
          f"truong: {sum(1 for v in d['fields'].values() if v['vi'])}/{len(d['fields'])}")


if __name__ == "__main__":
    main()

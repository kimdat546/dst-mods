#!/usr/bin/env python3
"""In các trang sách chưa dịch trong desc_source.json, theo lô.

    python3 tools/next_desc.py [so_luong] [--offset N] [--fields]
"""
import json, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "desc_source.json"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    n = int(args[0]) if args else 8
    off = 0
    if "--offset" in sys.argv:
        off = int(sys.argv[sys.argv.index("--offset") + 1])

    d = json.loads(SRC.read_text(encoding="utf-8"))

    if "--fields" in sys.argv:
        for k, v in d["fields"].items():
            if not v["vi"]:
                print(f'{k}\t[{",".join(v["f"])}]')
        return

    todo = [(k, v) for k, v in d["pages"].items() if not v["vi"]]
    print(f"# con {len(todo)} trang chua dich\n")
    for k, v in todo[off:off + n]:
        print(f"===== {k} =====")
        print("--- ZH ---")
        print(v["zh"].strip())
        print("--- EN ---")
        print(v["en"].strip())
        print()


if __name__ == "__main__":
    main()

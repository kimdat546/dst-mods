#!/usr/bin/env python3
"""Sinh thư mục translation_vi/ từ translation_ch/ + strings_source.json.

    python3 tools/build.py            # dựng vào build/
    python3 tools/build.py --check    # chỉ kiểm, không ghi

Cách làm: chép nguyên từng file .lua của bản tiếng Trung rồi thay chuỗi trong
dấu nháy. Giữ trọn cấu trúc, khoá và thứ tự của tác giả nên nộp ngược lên cho
họ được, mà đóng thành mod client riêng cũng được.
"""
import argparse, json, pathlib, re, shutil, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CH = ROOT / "vendor" / "shanhai_strings" / "translation_ch"
OUT = ROOT / "build" / "shanhai_strings" / "translation_vi"
SRC = ROOT / "strings_source.json"

HAN = re.compile(r"[一-鿿]")
LUA_STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
FMT = re.compile(r"%[-+#0-9.]*[a-zA-Z%]")


def kiem_ban_dich(table):
    """Bắt lỗi dễ gây sập game trước khi dựng."""
    loi = []
    for zh, rec in table.items():
        vi = rec.get("vi")
        if not vi:
            continue
        if sorted(FMT.findall(zh)) != sorted(FMT.findall(vi)):
            loi.append(f"lệch ký tự định dạng: {zh!r} -> {vi!r}")
        if vi.count('"') != zh.count('"'):
            loi.append(f"lệch dấu nháy kép: {zh!r} -> {vi!r}")
        if vi.count("\\n") != zh.count("\\n"):
            loi.append(f"lệch số lần xuống dòng: {zh!r} -> {vi!r}")
        if HAN.search(vi):
            loi.append(f"bản dịch còn chữ Hán: {zh!r} -> {vi!r}")
    for l in loi:
        print("  ✗ " + l)
    if loi:
        sys.exit(f"dừng: {len(loi)} lỗi trong bản dịch")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()

    table = json.loads(SRC.read_text(encoding="utf-8"))
    done = {zh: r["vi"] for zh, r in table.items() if r.get("vi")}
    print(f"đã dịch {len(done)}/{len(table)} chuỗi "
          f"({len(done) * 100 // max(len(table), 1)}%)")
    kiem_ban_dich(table)
    if a.check:
        return

    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.mkdir()

    tong = sot = 0
    for f in sorted(CH.glob("*.lua")):
        text = f.read_text(encoding="utf-8", errors="replace")
        hits = [0, 0]

        def one(m):
            zh = m.group(1)
            if not HAN.search(zh):
                return m.group(0)
            vi = done.get(zh)
            if vi is None:
                hits[1] += 1
                return m.group(0)
            hits[0] += 1
            return '"' + vi + '"'

        new = "\n".join(
            l if l.lstrip().startswith("--") else LUA_STR.sub(one, l)
            for l in text.split("\n"))
        (OUT / f.name).write_text(new, encoding="utf-8")
        tong += hits[0]
        sot += hits[1]

    print(f"thay {tong} lượt chuỗi trong {len(list(OUT.glob('*.lua')))} file"
          + (f" — CÒN SÓT {sot}" if sot else ""))
    print(f"→ {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

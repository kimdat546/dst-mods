#!/usr/bin/env python3
"""Dựng bản Việt hoá: vendor/ + strings_source.json → build/than-binh-phu-an-vi

    python3 tools/build.py            # dựng
    python3 tools/build.py --check    # chỉ báo tiến độ, không ghi

Cách làm: copy nguyên vendor/ sang build/, rồi thay từng chuỗi tiếng Trung
trong file .lua bằng bản dịch. Chỉ đụng chuỗi nằm trong nháy kép — comment và
mã nguồn giữ nguyên, nên logic mod không đổi.

Chuỗi chưa dịch (`vi` rỗng) được giữ nguyên tiếng Trung, nhờ vậy dựng lúc nào
cũng ra bản chạy được, dịch tới đâu hiện tiếng Việt tới đó.
"""

import argparse
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENDOR = ROOT / "vendor"
BUILD = ROOT / "build" / "than-binh-phu-an-vi"
SRC = ROOT / "strings_source.json"

HAN = re.compile(r"[一-鿿]")
LUA_STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')


# `description` của modinfo nằm trong block [[...]], không phải nháy kép, nên
# bộ thay chuỗi không đụng tới — vá riêng ở đây. Giữ nguyên `author` gốc và ghi
# rõ nguồn: đây là bản dịch, không phải mod của mình.
MODINFO_DESC = (
    """description = [[
装备附魔/生物强化
| 煎蛋牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛煎蛋 |
]]""",
    """description = [[
Phù ấn trang bị / Cường hoá sinh vật

Bản Việt hoá của mod 传奇武器-附魔强化 (Workshop 3096210166).
Tác giả gốc: 宇宙超级霹雳闪电大煎蛋 — mã nguồn mở.
Việt hoá: kimdat546
]]""",
)


def patch_modinfo():
    f = BUILD / "modinfo.lua"
    s = f.read_text(encoding="utf-8")
    old, new = MODINFO_DESC
    if old in s:
        f.write_text(s.replace(old, new, 1), encoding="utf-8")
        print("vá modinfo: description + ghi công tác giả gốc")
    elif new not in s:
        print("⚠ không khớp description trong modinfo — mod đã đổi, xem lại tay")


def build(check_only=False):
    table = json.loads(SRC.read_text(encoding="utf-8"))
    done = {zh: rec["vi"] for zh, rec in table.items() if rec.get("vi")}

    total = len(table)
    print(f"đã dịch {len(done)}/{total} chuỗi ({len(done) * 100 // max(total, 1)}%)")
    if check_only:
        return

    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(VENDOR, BUILD)

    replaced = files_touched = 0
    for f in sorted(BUILD.rglob("*.lua")):
        text = f.read_text(encoding="utf-8", errors="replace")
        if not HAN.search(text):
            continue
        hits = 0

        def sub_line(line: str) -> str:
            nonlocal hits
            if line.lstrip().startswith("--"):
                return line
            # chỉ thay trong phần mã, giữ nguyên comment đuôi dòng
            head, sep, tail = line.partition("--")
            if not HAN.search(head):
                return line

            def one(m):
                nonlocal hits
                zh = m.group(1)
                vi = done.get(zh)
                if vi:
                    hits += 1
                    return '"' + vi + '"'
                return m.group(0)

            return LUA_STR.sub(one, head) + sep + tail

        new = "\n".join(sub_line(l) for l in text.split("\n"))
        if hits:
            f.write_text(new, encoding="utf-8")
            replaced += hits
            files_touched += 1

    patch_modinfo()

    print(f"thay {replaced} lượt chuỗi trong {files_touched} file")
    print(f"→ {BUILD.relative_to(ROOT)}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true")
    build(ap.parse_args().check)

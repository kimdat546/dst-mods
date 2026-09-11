#!/usr/bin/env python3
"""Gộp một file Lua thành MỘT dòng để gửi vào console DST.

Console DST nhận lệnh qua `printf '%s\\n'` nên Lua phải nằm trên một dòng.
Gộp thẳng thì hỏng: `--` biến phần còn lại của dòng thành comment và nuốt sạch
script. Nên phải bỏ hết dòng comment trước khi gộp.
"""

import pathlib
import sys


def gop(duong_dan: pathlib.Path) -> str:
    ra = []
    for dong in duong_dan.read_text(encoding="utf-8").splitlines():
        s = dong.strip()
        if s and not s.startswith("--"):
            ra.append(s)
    return "do " + " ".join(ra) + " end"


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("dùng: gop_mot_dong.py <file.lua>", file=sys.stderr)
        raise SystemExit(2)
    print(gop(pathlib.Path(sys.argv[1])), end="")

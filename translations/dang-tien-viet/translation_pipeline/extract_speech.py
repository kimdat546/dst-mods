#!/usr/bin/env python3
"""
Trích xuất tất cả chuỗi tiếng Trung từ file speech của mod gốc.
Mỗi entry giữ lại đường dẫn (path) trong table để re-build sau khi dịch.

Usage:
    python3 extract_speech.py <source_speech.lua> <output.tsv>

Output TSV format:
    <path>\t<chinese>\t<comment>

Path ví dụ: ACTIONFAIL.APPRAISE.NOTNOW
"""

import re
import sys
import os
import json

SOURCE_DIR = os.path.expanduser(
    "~/Library/Application Support/Steam/steamapps/workshop/content/322330/3235319974/scripts"
)

CHINESE_RE = re.compile(r'[一-鿿]')


def is_chinese(s: str) -> bool:
    return bool(CHINESE_RE.search(s))


def parse_speech_file(path: str):
    """
    Walk through Lua file line-by-line, tracking nested table keys.
    Returns list of (path, original_string, line_no, comment).
    """
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()

    stack = []  # path components
    results = []

    # Regexes
    re_open = re.compile(r"^\s*([A-Z_][A-Z_0-9]*)\s*=\s*$")  # KEY =
    re_open_brace_same = re.compile(r"^\s*([A-Z_][A-Z_0-9]*)\s*=\s*\{")  # KEY = {
    re_open_solo = re.compile(r"^\s*\{\s*$")
    re_close = re.compile(r"^\s*\},?\s*$")
    re_string_assign = re.compile(
        r'^\s*([A-Z_][A-Z_0-9]*|\[\s*\d+\s*\])\s*=\s*"((?:[^"\\]|\\.)*)"(?:\s*,)?\s*(?:--\s*(.*))?$'
    )
    re_array_string = re.compile(
        r'^\s*"((?:[^"\\]|\\.)*)"(?:\s*,)?\s*(?:--\s*(.*))?$'
    )

    array_indices = {}  # depth -> next index

    for ln, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")
        m = re_string_assign.match(line)
        if m:
            key, value, comment = m.group(1), m.group(2), m.group(3) or ""
            full_path = ".".join(stack + [key])
            if is_chinese(value):
                results.append((full_path, value, ln, comment))
            continue

        m = re_array_string.match(line)
        if m and stack:
            # array element
            depth = len(stack)
            idx = array_indices.get(depth, 0)
            array_indices[depth] = idx + 1
            value, comment = m.group(1), m.group(2) or ""
            full_path = ".".join(stack) + f"[{idx}]"
            if is_chinese(value):
                results.append((full_path, value, ln, comment))
            continue

        m = re_open_brace_same.match(line)
        if m:
            stack.append(m.group(1))
            array_indices[len(stack)] = 0
            continue
        m = re_open.match(line)
        if m:
            # next line should be {
            stack.append(m.group(1))
            array_indices[len(stack)] = 0
            continue
        if re_close.match(line):
            if stack:
                array_indices.pop(len(stack), None)
                stack.pop()
            continue

    return results


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    src, out = sys.argv[1], sys.argv[2]
    if not os.path.isabs(src):
        src = os.path.join(SOURCE_DIR, src)
    rows = parse_speech_file(src)
    print(f"Extracted {len(rows)} CN strings from {src}")
    with open(out, "w", encoding="utf-8") as f:
        f.write("path\toriginal\tline\tcomment\n")
        for path, val, ln, comment in rows:
            # Escape tabs and newlines in value
            v = val.replace("\t", "\\t").replace("\n", "\\n")
            c = comment.replace("\t", " ")
            f.write(f"{path}\t{v}\t{ln}\t{c}\n")
    print(f"Written → {out}")

    # Also dump unique strings for translation batching
    unique = {}
    for path, val, _, comment in rows:
        if val not in unique:
            unique[val] = comment
    base = os.path.splitext(out)[0]
    with open(base + "_unique.txt", "w", encoding="utf-8") as f:
        for val, comment in unique.items():
            v = val.replace("\n", "\\n")
            c = comment.strip()
            if c:
                f.write(f"{v}\t# {c}\n")
            else:
                f.write(f"{v}\n")
    print(f"Unique strings: {len(unique)} → {base}_unique.txt")


if __name__ == "__main__":
    main()

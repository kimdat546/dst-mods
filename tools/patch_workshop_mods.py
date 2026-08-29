#!/usr/bin/env python3
"""Vá lại các mod Workshop bị lỗi làm sập server.

Steam ghi đè thư mục Workshop mỗi lần mod cập nhật, cuốn theo mọi bản vá tay.
Script này áp lại toàn bộ vá đã biết, idempotent — chạy bao nhiêu lần cũng được.

    python3 tools/patch_workshop_mods.py            # áp vá
    python3 tools/patch_workshop_mods.py --check    # chỉ kiểm tra, không sửa

Mỗi bản vá giữ một `.bak` cạnh file gốc ở lần sửa đầu tiên.
"""

import argparse
import io
import shutil
import sys
from pathlib import Path

WORKSHOP = Path.home() / (
    "Library/Application Support/Steam/steamapps/workshop/content/322330"
)

# --- 2845021470 Raiden Shogun --------------------------------------------
#
# raiden_descriptions.lua:25 làm `STRINGS.CHARACTERS.RAIDEN_SHOGUN =
# require "speech_wilson"` mà không deepcopy. Vanilla strings.lua cũng có
# `STRINGS.CHARACTERS.GENERIC = require "speech_wilson"`, nên hai bảng là MỘT.
# Gán tiếp `.ACTIONFAIL.COOK = "chuỗi"` (vanilla là table {GENERIC, INUSE,
# TOOFAR}) làm hỏng speech_wilson cho toàn bộ game → mod nhân vật nạp sau
# (3625940357 腌笃鲜•神话书说) index `.COOK.xxx` và sập luôn server:
#
#   speech_xydztz_yutu.lua:34: attempt to index field 'COOK' (a string value)
#   → Error loading main.lua → Failed mSimulation->Reset()
#
# Vá: giữ nguyên kiểu table. Không đụng dòng 25 — deepcopy ở đó sẽ khiến
# Raiden mất mô tả mọi item của các mod nạp sau nó.

RAIDEN_COOK_CN = (
    '    STRINGS.CHARACTERS.RAIDEN_SHOGUN.ACTIONFAIL.COOK = '
    '"你不要让我做饭啦。我什么都能办到，但是真的不会做饭。"',
    '''    --[[ FIX: ACTIONFAIL.COOK 在原版是 table，直接赋字符串会污染 speech_wilson（与 GENERIC 同一张表），
         导致后续加载的人物 mod（如 3625940357）在 index .COOK 时崩溃。改成 table 形式。 ]]
    STRINGS.CHARACTERS.RAIDEN_SHOGUN.ACTIONFAIL.COOK = {
        GENERIC = "你不要让我做饭啦。我什么都能办到，但是真的不会做饭。",
        INUSE = "看来我们想到一块去了。",
        TOOFAR = "太远了！",
    }''',
)

RAIDEN_COOK_EN = (
    "    STRINGS.CHARACTERS.RAIDEN_SHOGUN.ACTIONFAIL.COOK = "
    "\"Don't try and get me to cook. I can take care of anything else, but not that.\"",
    '''    --[[ FIX: vanilla ACTIONFAIL.COOK is a table; assigning a string here corrupts speech_wilson
         (the same table as GENERIC) and crashes character mods loaded later. Keep it a table. ]]
    STRINGS.CHARACTERS.RAIDEN_SHOGUN.ACTIONFAIL.COOK = {
        GENERIC = "Don't try and get me to cook. I can take care of anything else, but not that.",
        INUSE = "Looks like we had the same idea.",
        TOOFAR = "It's too far away!",
    }''',
)

# --- 3014076942 【璇儿】Xuaner ---------------------------------------------
#
# Xuaner (priority=-9999999999) nạp TRƯỚC Dehydrated (priority=-10000010001).
# Nó để lại thứ gì đó trong môi trường mod khiến `set_env.lua` của Dehydrated
# quay vô hạn: server ăn 100% CPU, log đứng ở
#
#   modimport: ../mods/workshop-3004639365/scripts/set_env
#
# và không bao giờ tới worldgen. Mỗi mod chạy riêng đều bình thường — chỉ cặp
# này mới treo. modinfo của Xuaner bị obfuscate nên không truy được cơ chế,
# nhưng đảo thứ tự nạp là đủ: hạ priority Xuaner xuống dưới Dehydrated.
# Đã kiểm chứng bằng cluster test với đủ 31 mod → worldgen xong, Sim paused.

XUANER_PRIORITY = (
    "priority=-9999999999",
    "priority=-10000010002",
)

PATCHES = [
    {
        "mod": "2845021470 (Raiden Shogun)",
        "file": "2845021470/scripts/import/raiden_descriptions.lua",
        "replacements": [RAIDEN_COOK_CN, RAIDEN_COOK_EN],
    },
    {
        "mod": "3014076942 (Xuaner)",
        "file": "3014076942/modinfo.lua",
        "replacements": [XUANER_PRIORITY],
    },
]


def apply(patch, check_only):
    path = WORKSHOP / patch["file"]
    label = f'{patch["mod"]} — {Path(patch["file"]).name}'
    if not path.exists():
        print(f"  bỏ qua  {label}: không có file (mod chưa cài?)")
        return True

    text = io.open(path, encoding="utf-8").read()
    todo = []
    for old, new in patch["replacements"]:
        if new in text:
            continue
        if old not in text:
            print(f"  ⚠ LỖI   {label}: không khớp đoạn cần vá — mod đã đổi, xem lại tay")
            return False
        todo.append((old, new))

    if not todo:
        print(f"  đã vá   {label}")
        return True
    if check_only:
        print(f"  CẦN VÁ  {label} ({len(todo)} chỗ)")
        return False

    bak = path.with_suffix(path.suffix + ".bak")
    if not bak.exists():
        shutil.copy2(path, bak)
    for old, new in todo:
        text = text.replace(old, new, 1)
    io.open(path, "w", encoding="utf-8").write(text)
    print(f"  ĐÃ VÁ   {label} ({len(todo)} chỗ)")
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true", help="chỉ kiểm tra, không sửa")
    args = ap.parse_args()

    if not WORKSHOP.is_dir():
        sys.exit(f"Không thấy thư mục Workshop: {WORKSHOP}")

    print(f"Workshop: {WORKSHOP}")
    ok = all([apply(p, args.check) for p in PATCHES])
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

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
import zipfile
from pathlib import Path

WORKSHOP = Path.home() / (
    "Library/Application Support/Steam/steamapps/workshop/content/322330"
)
SCRIPTS_ZIP = Path.home() / (
    "Library/Application Support/Steam/steamapps/common/Don't Starve Together"
    "/dontstarve_steam.app/Contents/data/databundles/scripts.zip"
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

# --- 439115156 [DST]Musha ------------------------------------------------
#
# Musha đặt `scripts/components/pickable.lua` trong mod — đường dẫn này THAY
# THẾ hẳn component vanilla cho toàn bộ game (khác `postinit/`, chỉ vá thêm).
# File đó là bản chép của một phiên bản DST cũ, thiếu `IsStuck`, `SetStuck`,
# `SpawnProductLoot` và `SpringGrowthMod`. Hái bất cứ thứ gì là server chết:
#
#   actions.lua:1930: attempt to call method 'IsStuck' (a nil value)
#   ← ACTIONS.PICK.fn → pickable:IsStuck()
#
# Toàn bộ sửa đổi thật của Musha chỉ là: thú cưng yamcheb / critter_musha nhặt
# đồ vào container của nó thay vì inventory. Nên bản vá lấy pickable.lua vanilla
# hiện hành rồi port đúng chỗ đó sang, thay vì giữ bản cũ.

MUSHA_PICKABLE = (
    "    local inventory = picker ~= nil and picker.components.inventory or nil",
    """    -- MUSHA (439115156): thú cưng yamcheb / critter_musha nhặt vào container của nó
    -- thay vì inventory. Đây là toàn bộ sửa đổi của Musha so với vanilla — phần còn
    -- lại của file này là bản vanilla hiện hành, thay cho bản cũ mà mod chép theo
    -- (bản cũ thiếu IsStuck/SetStuck/SpawnProductLoot → hái gì cũng sập server).
    local inventory = picker ~= nil
        and ((picker:HasTag("yamcheb") or picker.critter_musha)
             and picker.components.container
             or picker.components.inventory)
        or nil""",
)

MUSHA_HARVESTABLE_EVENT = (
    '\t\t\tif picker ~= nil and picker.components.inventory ~= nil then\n'
    '\t\t\t\tpicker:PushEvent("harvestsomething", { object = self.inst })\n'
    '\t\t\tend',
    '\t\t\t-- MUSHA (439115156): thú cưng yamcheb / critter_musha nhận đồ vào container\n'
    '\t\t\t-- của nó thay vì inventory. Đây là toàn bộ sửa đổi của Musha so với vanilla;\n'
    '\t\t\t-- phần còn lại của file là bản vanilla hiện hành, thay cho bản cũ mà mod chép\n'
    '\t\t\t-- theo (bản cũ thiếu SetCanHarvestFn/IsMagicGrowable/DoMagicGrowth).\n'
    '\t\t\tlocal receiver = picker ~= nil\n'
    '\t\t\t\tand ((picker:HasTag("yamcheb") or picker.critter_musha)\n'
    '\t\t\t\t\t and picker.components.container\n'
    '\t\t\t\t\t or picker.components.inventory)\n'
    '\t\t\t\tor nil\n'
    '\n'
    '\t\t\tif receiver ~= nil then\n'
    '\t\t\t\tpicker:PushEvent("harvestsomething", { object = self.inst })\n'
    '\t\t\tend',
)

MUSHA_HARVESTABLE_GIVE = (
    '\t\t\t\t\tif picker ~= nil and picker.components.inventory ~= nil then\n'
    '\t\t\t\t\t\tpicker.components.inventory:GiveItem(loot, nil, pos)',
    '\t\t\t\t\tif receiver ~= nil then\n'
    '\t\t\t\t\t\treceiver:GiveItem(loot, nil, pos)',
)

# --- 3401927745 [DST] Montfluv -------------------------------------------
#
# Montfluv và newconstant-base-vi cùng khai báo bộ âm thanh Shipwrecked:
#   sound/dontstarve_DLC002.fev        (928898 B, md5 4e239ece…)
#   sound/dontstarve_shipwreckedSFX.fsb (35827008 B, md5 8105a312…)
# Hai file byte-identical, và vanilla DST không có DLC002 (chỉ có DLC001).
# FMOD phải đăng ký event project tên `dontstarve_DLC002` hai lần → client
# SIGSEGV trong FMOD::EventSystem::load(), luôn cùng một offset:
#
#   libfmodevent.dylib +227427 → +148756 → +125670 → +123545
#   → FMOD::EventSystem::load(char const*, FMOD_EVENT_LOADINFO*, ...)
#
# Log client luôn dừng đúng ở dòng cuối của giai đoạn đăng ký prefab, ngay
# trước khi nạp asset. Bỏ khai báo ở Montfluv, giữ ở newconstant-base-vi (mod
# chính, và là mod ta tự quản). FMOD project là toàn cục sau khi nạp nên âm
# thanh của Montfluv vẫn dùng được bình thường.

MONTFLUV_DUP_SOUND = (
    '    -- 单机海难的音效\n'
    '    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC002.fev"),\n'
    '    Asset("SOUND", "sound/dontstarve_shipwreckedSFX.fsb"),',
    '    -- 单机海难的音效\n'
    '    -- FIX: newconstant-base-vi 也加载同一个音效包（文件逐字节相同）。同名 FMOD event\n'
    '    -- project 被加载两次会让客户端在 FMOD::EventSystem::load() 里 SIGSEGV 崩溃。\n'
    '    -- 这里只留一份加载；FMOD project 是全局的，本模组的音效照常可用。\n'
    '    -- Asset("SOUNDPACKAGE", "sound/dontstarve_DLC002.fev"),\n'
    '    -- Asset("SOUND", "sound/dontstarve_shipwreckedSFX.fsb"),',
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
    {
        "mod": "439115156 (Musha)",
        "file": "439115156/scripts/components/pickable.lua",
        "vanilla": "scripts/components/pickable.lua",
        "replacements": [MUSHA_PICKABLE],
    },
    {
        "mod": "439115156 (Musha)",
        "file": "439115156/scripts/components/harvestable.lua",
        "vanilla": "scripts/components/harvestable.lua",
        "replacements": [MUSHA_HARVESTABLE_EVENT, MUSHA_HARVESTABLE_GIVE],
    },
    {
        "mod": "3401927745 (Montfluv)",
        "file": "3401927745/init/init_assets.lua",
        "replacements": [MONTFLUV_DUP_SOUND],
    },
]


def apply(patch, check_only):
    path = WORKSHOP / patch["file"]
    label = f'{patch["mod"]} — {Path(patch["file"]).name}'
    if not path.exists():
        print(f"  bỏ qua  {label}: không có file (mod chưa cài?)")
        return True

    if patch.get("vanilla"):
        # Lấy bản vanilla hiện hành từ scripts.zip rồi port sửa đổi của mod sang,
        # thay vì vá tại chỗ bản cũ mà mod mang theo.
        if not SCRIPTS_ZIP.exists():
            print(f"  ⚠ LỖI   {label}: không thấy {SCRIPTS_ZIP.name}")
            return False
        with zipfile.ZipFile(SCRIPTS_ZIP) as z:
            vanilla = z.read(patch["vanilla"]).decode("utf-8")
        cur = path.read_text(encoding="utf-8") if path.exists() else ""
        if all(new in cur for _, new in patch["replacements"]):
            print(f"  đã vá   {label}")
            return True
        if check_only:
            print(f"  CẦN VÁ  {label} (thay bằng vanilla + port sửa đổi)")
            return False
        text = vanilla
        for old, new in patch["replacements"]:
            if old not in text:
                print(f"  ⚠ LỖI   {label}: vanilla đã đổi, không thấy đoạn cần port")
                return False
            text = text.replace(old, new, 1)
        bak = path.with_suffix(path.suffix + ".bak")
        if not bak.exists():
            shutil.copy2(path, bak)
        io.open(path, "w", encoding="utf-8").write(text)
        print(f"  ĐÃ VÁ   {label} (vanilla + {len(patch['replacements'])} sửa đổi)")
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

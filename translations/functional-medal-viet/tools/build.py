#!/usr/bin/env python3
"""Dựng mod client Việt hoá từ strings_source.json.

Sinh ra một thư mục mod hoàn chỉnh trong build/ để rsync vào game hoặc upload.
"""

import json
import pathlib
import sys

GOC = pathlib.Path(__file__).resolve().parent.parent
RA = GOC / "build" / "functional-medal-vi"

# ⚠ PHẢI NHỎ HƠN -10001 (priority của Functional Medal).
#   scripts/mods.lua:557 sắp mod bằng `apriority > bpriority` cho table.sort —
#   tức GIẢM DẦN: số LỚN nạp TRƯỚC, số NHỎ nạp SAU. Mình cần nạp SAU mod gốc
#   thì mới ghi đè được chuỗi của nó, nên phải nhỏ hơn.
UU_TIEN = -10002


def thoat_lua(s):
    """Đưa một chuỗi Việt vào Lua an toàn."""
    return (
        s.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "")
    )


def main():
    nguon = json.loads((GOC / "strings_source.json").read_text(encoding="utf-8"))
    xong = {k: v for k, v in nguon.items() if v.get("vi")}
    if not xong:
        print("chưa có chuỗi nào được dịch — không dựng", file=sys.stderr)
        return 1

    RA.mkdir(parents=True, exist_ok=True)
    (RA / "scripts").mkdir(exist_ok=True)

    # ── bảng chuỗi: file DỮ LIỆU THUẦN ─────────────────────────────────
    #
    # ⚠ Cố ý không có logic nào trong này. Nhờ vậy sau này muốn gộp bản dịch
    #   vào mod "DST Tiếng Việt" thì chỉ cần require file này trong
    #   AddSimPostInit, không phải viết lại gì.
    dong = [
        "-- Bảng dịch Functional Medal (能力勋章) — SINH TỰ ĐỘNG, đừng sửa tay.",
        "-- Sửa ở strings_source.json rồi chạy tools/build.py.",
        "--",
        "-- File này là DỮ LIỆU THUẦN: không logic, không phụ thuộc. Gộp vào mod",
        "-- khác thì chỉ cần require nó rồi áp vào STRINGS.",
        "return {",
    ]
    for khoa in sorted(xong):
        dong.append(f'  ["{khoa}"] = "{thoat_lua(xong[khoa]["vi"])}",')
    dong.append("}")
    (RA / "scripts" / "medal_vi_strings.lua").write_text(
        "\n".join(dong) + "\n", encoding="utf-8"
    )

    # ── modmain ────────────────────────────────────────────────────────
    (RA / "modmain.lua").write_text(
        '''-- Việt hoá Functional Medal (能力勋章) — mod CLIENT, không đụng mod gốc.
--
-- ⚠ VÌ SAO GHI ĐÈ `STRINGS` CHỨ KHÔNG THÊM THƯ MỤC NGÔN NGỮ. Mod gốc hardcode
--   đúng hai nhánh:
--       if TUNING.MEDAL_LANGUAGE == "ch" then require "lang/medal_strings_ch"
--       else                                require "lang/medal_strings_eng" end
--   Không có móc mở rộng, nên không thêm "vi" vào được mà không fork cả mod.
--
-- ⚠ VÌ SAO KHÔNG LỖI KHI SERVER KHÔNG BẬT MOD GỐC. `STRINGS` là bảng toàn cục
--   của game. Gán một khoá mà không ai đọc thì không có gì xảy ra — không cần
--   kiểm tra mod gốc có mặt hay không. An toàn tự nhiên, không nhờ chốt chặn.
--
-- ⚠ VÀ VÌ SAO ÁP TRONG AddSimPostInit CHỨ KHÔNG ÁP THẲNG. Mod gốc nạp chuỗi
--   NGAY TRONG modmain của nó. Nếu mình cũng áp trong modmain thì kết quả phụ
--   thuộc thứ tự nạp — mà thứ tự đó do `priority` quyết định và tác giả mod gốc
--   có thể đổi bất cứ lúc nào. AddSimPostInit chạy SAU mọi modmain, nên đúng
--   bất kể thứ tự.

local BANG = require("medal_vi_strings")

local function ApDung()
    local n = 0
    for khoa, chu in pairs(BANG) do
        -- khoá dạng "NAMES.COOK_CERTIFICATE" hoặc
        -- "CHARACTERS.GENERIC.DESCRIBE.COOK_CERTIFICATE"
        local bang = GLOBAL.STRINGS
        local phan = {}
        for m in string.gmatch(khoa, "[^.]+") do phan[#phan + 1] = m end
        for i = 1, #phan - 1 do
            bang[phan[i]] = bang[phan[i]] or {}
            bang = bang[phan[i]]
        end
        bang[phan[#phan]] = chu
        n = n + 1
    end
    return n
end

AddSimPostInit(function()
    local ok, n = pcall(ApDung)
    if ok then
        print("[medal-vi] đã áp " .. tostring(n) .. " chuỗi tiếng Việt")
    else
        print("[medal-vi] LỖI khi áp chuỗi: " .. tostring(n))
    end
end)
''',
        encoding="utf-8",
    )

    # ── modinfo ────────────────────────────────────────────────────────
    (RA / "modinfo.lua").write_text(
        f'''name = "Functional Medal Tiếng Việt"
description = [[Việt hoá mod Functional Medal (能力勋章) của tác giả 恒子.

Mod CLIENT — chỉ đổi chữ hiện trên máy bạn, không đụng gì tới mod gốc và
không cần server bật theo. Server không chơi Functional Medal thì mod này
cũng không gây lỗi gì.

Bật mod gốc ở chế độ tiếng Anh (language_switch = eng).]]
author = "kimdat546"
version = "0.1.0"
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- Chữ hiện ở máy người chơi, nên đây là mod client. Server không cần bật.
all_clients_require_mod = false
client_only_mod = true

-- ⚠ PHẢI NHỎ HƠN -10001 (priority của Functional Medal).
--   scripts/mods.lua:557 sắp mod bằng `apriority > bpriority` cho table.sort,
--   tức GIẢM DẦN: số LỚN nạp TRƯỚC, số NHỎ nạp SAU. Muốn ghi đè chuỗi của mod
--   gốc thì phải nạp SAU nó.
priority = {UU_TIEN}

server_filter_tags = {{"tiếng việt", "vietnamese", "medal"}}

configuration_options = {{}}
'''
        , encoding="utf-8",
    )

    tong = len(nguon)
    print(f"đã dựng {RA}")
    print(f"  {len(xong)}/{tong} chuỗi ({len(xong) * 100 // tong}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

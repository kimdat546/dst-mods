#!/usr/bin/env python3
"""Dựng mod client Việt hoá từ strings_source.json.

Sinh ra một thư mục mod hoàn chỉnh trong build/ để rsync vào game hoặc upload.
"""

import json
import pathlib
import re
import shutil
import sys

GOC = pathlib.Path(__file__).resolve().parent.parent
RA = GOC / "build" / "functional-medal-vi"

# ⚠ PHẢI NHỎ HƠN -10001 (priority của Functional Medal).
#   scripts/mods.lua:557 sắp mod bằng `apriority > bpriority` cho table.sort —
#   tức GIẢM DẦN: số LỚN nạp TRƯỚC, số NHỎ nạp SAU. Mình cần nạp SAU mod gốc
#   thì mới ghi đè được chuỗi của nó, nên phải nhỏ hơn.
UU_TIEN = -10002
PHIEN_BAN = "0.1.2"


def thoat_lua(s):
    """Đưa một chuỗi Việt vào Lua an toàn."""
    return (
        s.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "")
    )


def soat_placeholder(nguon):
    """Placeholder lệch là LỖI HIỂN THỊ THẬT trong game, không phải chuyện nhỏ.

    Chuỗi gốc có {medal}, {level}, {food}, {product}... Dịch mà đánh rơi hoặc
    viết sai tên thì người chơi thấy nguyên chữ "{food}" giữa câu, hoặc tệ hơn
    là mất hẳn phần tên món. Rẻ để kiểm, nên kiểm mỗi lần dựng.
    """
    loi = []
    for khoa, v in nguon.items():
        if not v.get("vi"):
            continue
        a = sorted(re.findall(r"\{(\w+)\}", v["en"]))
        b = sorted(re.findall(r"\{(\w+)\}", v["vi"]))
        if a != b:
            loi.append(f"  {khoa}: gốc {a} -> dịch {b}")
    return loi


def main():
    nguon = json.loads((GOC / "strings_source.json").read_text(encoding="utf-8"))

    loi = soat_placeholder(nguon)
    if loi:
        print("✗ placeholder lệch — KHÔNG dựng:", file=sys.stderr)
        print("\n".join(loi), file=sys.stderr)
        return 1
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
    #
    # ⚠ NHÚNG THẲNG BẢNG CHUỖI VÀO modmain, KHÔNG `require` FILE RIÊNG.
    #   Mod Workshop MẶC ĐỊNH BẬT MANIFEST (mods.lua:566 — forcemanifest == nil
    #   và IsWorkshopMod thì LoadModManifest), và DST chỉ thấy file nằm trong
    #   manifest. Bản 0.1.0/0.1.1 `require("medal_vi_strings")` chạy ngon khi
    #   cài local nhưng hỏng khi tải từ Workshop — đúng cái bẫy README của
    #   montfluv-viet đã ghi: "DST chỉ thấy file có trong đó".
    #
    #   Nhúng thẳng thì không còn file thứ hai để tìm, nên xoá luôn cả lớp rủi
    #   ro. scripts/medal_vi_strings.lua vẫn được sinh ra để dùng lại ở chỗ
    #   khác, nhưng modmain KHÔNG phụ thuộc vào nó nữa.
    bang_nhung = "\n".join(
        f'  ["{k}"] = "{thoat_lua(xong[k]["vi"])}",' for k in sorted(xong)
    )
    (RA / "modmain.lua").write_text(
        f'''-- Việt hoá Functional Medal (能力勋章) — mod CLIENT, không đụng mod gốc.
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

local BANG = {{
{bang_nhung}
}}

local function ApDung()
    local n = 0
    for khoa, chu in pairs(BANG) do
        -- khoá dạng "NAMES.COOK_CERTIFICATE" hoặc
        -- "CHARACTERS.GENERIC.DESCRIBE.COOK_CERTIFICATE"
        local bang = GLOBAL.STRINGS
        local phan = {{}}
        for m in string.gmatch(khoa, "[^.]+") do phan[#phan + 1] = m end
        for i = 1, #phan - 1 do
            bang[phan[i]] = bang[phan[i]] or {{}}
            bang = bang[phan[i]]
        end
        bang[phan[#phan]] = chu
        n = n + 1
    end
    return n
end

-- ⚠ `pcall` KHÔNG CÓ trong môi trường mod. DST chỉ cấp cho modmain đúng mấy
--   thứ này (scripts/mods.lua:369): pairs, ipairs, print, math, table, type,
--   string, tostring, require, Class, TUNING, GLOBAL, modname, MODROOT.
--   Mọi thứ khác phải lấy qua GLOBAL.
--
--   Bản đầu gọi thẳng `pcall(...)` và nó ném "attempt to call global 'pcall'
--   (a nil value)" NGAY TRONG AddSimPostInit — tức đúng lúc người chơi vừa vào
--   world. Triệu chứng nhìn từ server: client vào được rồi rớt sau 12-26 giây,
--   kèm "[P2P] Connection failed ... error code 4". Không có dòng nào nói là
--   lỗi mod, nên rất dễ đổ oan cho đường truyền.
local pcall = GLOBAL.pcall

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
        f'''name = "Functional Medal - Đừng Chết Đói :)"
description = [[Bản dịch tiếng Việt cho mod Functional Medal (能力勋章).

Mod gốc của tác giả 恒子 — chủ đề "trưởng thành": huân chương trao năng lực,
kèm hệ nhiệm vụ, gia vị nấu ăn, cây ghép, tượng và đạn ná.

YÊU CẦU
- Phải sub và bật mod gốc trước: Functional Medal, Workshop ID 1909182187
- Trong cấu hình mod gốc để ngôn ngữ = English (language_switch)
- Mod này là MOD CLIENT, chỉ đổi chữ hiện trên máy bạn

GHI CHÚ
- Không đụng vào file mod gốc, nên Steam cập nhật mod gốc cũng không mất bản dịch
- Server không chơi Functional Medal thì mod này cũng không gây lỗi gì
- Trang chủ mod gốc: guanziheng.com

Tác giả bản dịch: kimdat546
Mọi công trạng về nội dung mod thuộc về tác giả gốc 恒子.]]
author = "kimdat546"
version = "{PHIEN_BAN}"
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- Chữ hiện ở máy người chơi, nên đây là mod client. Server không cần bật.
all_clients_require_mod = false
client_only_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- ⚠ TẮT MANIFEST. Mod Workshop mặc định BẬT (mods.lua:566), và khi bật thì DST
--   chỉ thấy file nằm trong manifest — file nào không có trong đó là "module
--   not found". Mod này đọc file của chính nó nên phải tắt.
forcemanifest = false

-- ⚠ PHẢI NHỎ HƠN -10001 (priority của Functional Medal).
--   scripts/mods.lua:557 sắp mod bằng `apriority > bpriority` cho table.sort,
--   tức GIẢM DẦN: số LỚN nạp TRƯỚC, số NHỎ nạp SAU. Muốn ghi đè chuỗi của mod
--   gốc thì phải nạp SAU nó.
priority = {UU_TIEN}

server_filter_tags = {{"vn", "vietnam", "vietnamese", "medal", "kimdat546"}}

configuration_options = {{}}
'''
        , encoding="utf-8",
    )

    # ── ảnh ────────────────────────────────────────────────────────────
    #
    # ⚠ modicon.tex/.xml PHẢI nằm cạnh modinfo.lua, không nằm trong thư mục con
    #   — modinfo trỏ tới chúng bằng tên trần. preview.png thì Workshop đọc,
    #   game không dùng.
    thieu = []
    for ten in ("modicon.tex", "modicon.xml", "preview.png"):
        nguon_anh = GOC / "assets" / ten
        if nguon_anh.exists():
            shutil.copy2(nguon_anh, RA / ten)
        else:
            thieu.append(ten)
    if thieu:
        print("  ⚠ thiếu ảnh: " + ", ".join(thieu) + " — chạy tools/make_anh.py")

    tong = len(nguon)
    print(f"đã dựng {RA}")
    print(f"  {len(xong)}/{tong} chuỗi ({len(xong) * 100 // tong}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Đóng bản dịch thành MOD CLIENT riêng, ghi đè STRINGS của Montfluv.

    python3 tools/build_client_mod.py

Vì sao cần: mod Workshop mang theo `mod.manifest` — danh mục file nhị phân.
Thêm file mới vào mod đã tải thì DST không thấy; xoá manifest thì hỏng cả tài
nguyên. Nên bản chơi thử phải ghi đè translation_es/, và Steam cập nhật là mất.

Mod client tự có manifest của mình nên không vướng gì. Nó nạp SAU Montfluv rồi
ghi đè các bảng STRINGS.* — mà mod gốc viết mọi chuỗi vào đúng các bảng đó.

Không với tới được: nhãn trong modinfo của mod gốc (tên mod, mô tả, nhãn tuỳ
chọn cấu hình) — DST đọc thẳng từ file, không mod nào chạm được.
"""
import pathlib, shutil, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
VI = ROOT / "build" / "shanhai_strings" / "translation_vi"
OUT = ROOT / "build" / "montfluv-vi"

# ĐO THỰC TẾ: priority KHÔNG quyết định thứ tự ở đây — thử cả -9999 lẫn 9999
# thì mod này vẫn nạp TRƯỚC workshop-3401927745 (DST xếp theo tên thư mục).
# Nên không dựa vào thứ tự nạp nữa: ghi đè trong AddGamePostInit, lúc đó mọi
# modmain đã chạy xong. Đây đúng là pattern ghi trong CLAUDE.md của workspace.
PRIORITY = -10000

MODINFO = '''name = "Montfluv - Đừng Chết Đói :)"
description = [[
Bản dịch tiếng Việt cho mod [DST] Montfluv (山河表里).

Bật mod này CÙNG với Montfluv (Workshop 3401927745). Nó nạp sau rồi thay
toàn bộ văn bản sang tiếng Việt: tên vật phẩm, mô tả chế tạo, thoại nhân
vật, hành động, giao diện, và toàn bộ 104 trang nội dung của sách hướng dẫn
"Cuộn Tranh Sơn Hà" (山河绘卷).

Chỉ cần MỘT MÌNH BẠN bật — người khác trong server không bị ảnh hưởng.

Riêng phần cấu hình của mod gốc (nhãn các tuỳ chọn trong menu Mods) vẫn giữ
nguyên tiếng Trung, vì DST đọc thẳng từ modinfo của mod đó, không mod nào
ghi đè được.

Nguồn: mod 山河表里 của tác giả 威吊. Xin cảm ơn tác giả gốc.
Việt hoá: kimdat546
]]
author = "kimdat546"
version = "1.1.2"

icon_atlas = "modicon.xml"
icon = "modicon.tex"
forumthread = ""

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

client_only_mod = true
all_clients_require_mod = false

-- Nạp SAU Montfluv (priority = -3097): số lớn hơn = nạp sau (đã đo)
priority = {priority}

server_filter_tags = { "viet hoa", "vietnam", "montfluv" }

configuration_options = {}
'''

MODMAIN = '''--
-- Montfluv - Đừng Chết Đói :)  (bản Việt hoá)
--
-- Mod gốc ghi mọi chuỗi vào STRINGS.NAMES / RECIPE_DESC / CHARACTERS.GENERIC
-- / ACTIONS / UI.*. Mod này ghi đè lại bằng tiếng Việt.
--
-- KHÔNG dựa vào thứ tự nạp: đã đo, priority không đổi được thứ tự (DST xếp
-- theo tên thư mục, "montfluv-vi" < "workshop-3401927745" nên luôn nạp trước).
-- Vì vậy nạp bản dịch trong AddGamePostInit — lúc đó mọi modmain đã chạy xong
-- và chuỗi tiếng Trung đã nằm sẵn trong STRINGS, ghi đè mới ăn.
--
-- Bọc pcall: một lỗi ở đây KHÔNG được phép giết mod hay cả game.
--
GLOBAL.setmetatable(env, {{ __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end }})

local FILES = {{
{files}
}}

local function ApDungBanDich()
    local nap, loi = 0, 0
    for _, f in ipairs(FILES) do
        local duong_dan = "shanhai_strings/translation_vi/" .. f
        local ok, err = pcall(function()
            -- xoá cache để gọi lại vẫn chạy lại được file
            if package and package.loaded then
                package.loaded[duong_dan] = nil
            end
            require(duong_dan)
        end)
        if ok then
            nap = nap + 1
        else
            loi = loi + 1
            print("[montfluv-vi] lỗi nạp " .. f .. ": " .. tostring(err))
        end
    end
    print(("[montfluv-vi] đã áp %d/%d file bản dịch"):format(nap, #FILES))
end

-- ĐO THỰC TẾ trên dedicated server: AddGamePostInit chạy SAU AddSimPostInit,
-- nên chỉ móc một chỗ là hụt. Áp ở cả ba mốc; xoá cache nên gọi lại vẫn ăn.
ApDungBanDich()                 -- ngay khi nạp mod
AddSimPostInit(ApDungBanDich)   -- sau khi thế giới dựng xong
AddGamePostInit(ApDungBanDich)  -- sau khi phần game khởi tạo
'''

# Khối này KHÔNG đi qua .format() nên giữ nguyên ngoặc nhọn của Lua.
MODMAIN_SACH = '''
--
-- Nội dung “Cuộn Tranh Sơn Hà” (sh_desc) — sách hướng dẫn trong mod.
--
-- Sách KHÔNG đi qua STRINGS. shanhai_defs/sh_desc_contents.lua đọc
-- shanhai_defs/sh_desc_<lang>.lua rồi COPY text vào bảng def lúc nạp
-- (dòng ~1757: v.description = desc_contents[u]), nên sửa bảng ngôn ngữ
-- sau đó là vô ích — phải vá thẳng bảng def đã dựng.
--
-- Bảng đó nạp LƯỜI: screens/sh_desc_screen.lua mới require widget, và widget
-- mới require sh_desc_contents; tức lúc mở sách. Vì package.path dùng chung
-- cho mọi mod (mods.lua:567) nên mình require hộ nó ở postinit — lúc đó
-- TUNING.SHANHE_LAN đã được init_tuning của mod gốc đặt, và bảng nằm trong
-- package.loaded dùng chung, nên mod gốc sẽ nhận đúng bảng đã vá.
--
local function ApDungNoiDungSach()
    local ok, err = pcall(function()
        local vi = require("shanhai_desc_vi")
        local mod = require("shanhai_defs/sh_desc_contents")
        if not (mod and mod.sh_desc_contents) then
            return
        end
        local so_trang, so_truong = 0, 0
        for nhom, bang in pairs(mod.sh_desc_contents) do
            if nhom ~= "about" and type(bang) == "table" then
                for khoa, def in pairs(bang) do
                    if type(def) == "table" then
                        if vi.PAGES[khoa] then
                            def.description = vi.PAGES[khoa]
                            so_trang = so_trang + 1
                        end
                        if def.location and vi.FIELDS[def.location] then
                            def.location = vi.FIELDS[def.location]
                            so_truong = so_truong + 1
                        end
                        if def.type and vi.FIELDS[def.type] then
                            def.type = vi.FIELDS[def.type]
                            so_truong = so_truong + 1
                        end
                    end
                end
            end
        end
        print(("[montfluv-vi] sách: %d trang, %d nhãn"):format(so_trang, so_truong))
    end)
    if not ok then
        print("[montfluv-vi] lỗi vá nội dung sách: " .. tostring(err))
    end
end

AddSimPostInit(ApDungNoiDungSach)
AddGamePostInit(ApDungNoiDungSach)

--
-- 31 nhãn UI của sách nằm hardcode trong widget dạng
--     SH_IS_CH and "中文" or "English"
-- (SH_IS_CH = SH_LAN == "ch"), nên bản dịch KHÔNG với tới được: đặt config
-- language = "en" thì chúng hiện tiếng Anh.
--
-- Móc _ctor thôi là HỤT: phần lớn nhãn ("desc", "type", "recipe", "location",
-- "attitude") do ShDescAnimPage:PopulateRecipeDetailPanel dựng — chạy lại mỗi
-- lần người chơi bấm một mục, chứ không phải lúc khởi tạo.
--
-- Nên chặn ở tầng dưới cùng: Text:SetString và Text:SetMultilineTruncatedString
-- (hàm sau gọi thẳng inst.TextWidget:SetString, không đi qua hàm trước, nên
-- phải móc cả hai). Chỉ dịch khi CHẮC CHẮN đang ở trong sách:
--   • trong_sach > 0  — đang chạy trong một phương thức của lớp widget sách
--   • hoặc widget có tổ tiên được đánh dấu là widget của sách
-- Nhờ vậy các từ ngắn như "OK", "type", "desc" không đụng phần còn lại của game.
--
local LOP_SACH = {
    "widgets/redux/sh_desc_widget",
    "widgets/redux/sh_desc_animpage",
    "widgets/redux/sh_desc_aboutpage",
    "widgets/redux/sh_desc_settingpage",
    "widgets/redux/sh_desc_cdk",
}

local DAU = "__montfluv_vi_sach"
local trong_sach = 0

local function ThuocVeSach(w)
    local n = 0
    while w ~= nil and n < 20 do
        if rawget(w, DAU) then
            return true
        end
        w = w.parent
        n = n + 1
    end
    return false
end

local function ApDungNhanUI()
    local ok, err = pcall(function()
        local UI = require("shanhai_desc_vi").UI
        local Text = require("widgets/text")

        -- Bọc mọi phương thức của 5 lớp widget sách: bật cờ trong lúc chúng
        -- chạy, và đánh dấu instance để nhận ra về sau (spinner đổi giá trị,
        -- panel dựng lại…).
        for _, ten in ipairs(LOP_SACH) do
            local ok2, lop = pcall(require, ten)
            if ok2 and type(lop) == "table" then
                for khoa, ham in pairs(lop) do
                    if type(ham) == "function" then
                        lop[khoa] = function(self, ...)
                            if type(self) == "table" then
                                rawset(self, DAU, true)
                            end
                            trong_sach = trong_sach + 1
                            local kq = { pcall(ham, self, ...) }
                            trong_sach = trong_sach - 1
                            if not kq[1] then
                                error(kq[2], 0)
                            end
                            return unpack(kq, 2)
                        end
                    end
                end
            else
                print("[montfluv-vi] bỏ qua " .. ten)
            end
        end

        local function Dich(self, str)
            if type(str) == "string" and UI[str]
                and (trong_sach > 0 or ThuocVeSach(self)) then
                return UI[str]
            end
            return str
        end

        local SetString = Text.SetString
        Text.SetString = function(self, str, ...)
            return SetString(self, Dich(self, str), ...)
        end

        local SetMulti = Text.SetMultilineTruncatedString
        Text.SetMultilineTruncatedString = function(self, str, ...)
            return SetMulti(self, Dich(self, str), ...)
        end

        print("[montfluv-vi] đã móc nhãn UI của sách")
    end)
    if not ok then
        print("[montfluv-vi] lỗi vá nhãn UI sách: " .. tostring(err))
    end
end

-- Chỉ móc MỘT lần: gọi hai lần sẽ bọc chồng lên nhau.
local da_moc_ui = false
local function MocNhanUIMotLan()
    if not da_moc_ui then
        da_moc_ui = true
        ApDungNhanUI()
    end
end

AddSimPostInit(MocNhanUIMotLan)
AddGamePostInit(MocNhanUIMotLan)
'''


def main():
    if not VI.exists():
        sys.exit("chưa có build/shanhai_strings/translation_vi — chạy tools/build.py trước")
    if OUT.exists():
        shutil.rmtree(OUT)
    dest = OUT / "scripts" / "shanhai_strings" / "translation_vi"
    dest.mkdir(parents=True)

    names = []
    for f in sorted(VI.glob("*.lua")):
        shutil.copy2(f, dest / f.name)
        names.append(f.stem)

    files_lua = "\n".join(f'    "{n}",' for n in names)
    (OUT / "modinfo.lua").write_text(
        MODINFO.replace("{priority}", str(PRIORITY)), encoding="utf-8")
    (OUT / "modmain.lua").write_text(
        MODMAIN.format(files=files_lua) + MODMAIN_SACH,
        encoding="utf-8")

    for icon in ("modicon.tex", "modicon.xml", "preview.png"):
        src = ROOT / "assets" / icon
        if src.exists():
            shutil.copy2(src, OUT / icon)

    # nội dung sách sống trong desc_source.json, sinh ra scripts/shanhai_desc_vi.lua
    subprocess.run([sys.executable, str(ROOT / "tools" / "build_desc_lua.py")], check=True)

    n = len(list(OUT.rglob("*")))
    print(f"{len(names)} file bản dịch → {OUT.relative_to(ROOT)}  ({n} mục)")
    print(f"  priority = {PRIORITY}  (Montfluv = -3097, nạp trước)")


if __name__ == "__main__":
    main()

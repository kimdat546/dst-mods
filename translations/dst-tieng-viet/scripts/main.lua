local env = env

local main = mods.VietnameseLang
local AddPrefabPostInit = AddPrefabPostInit
local AddClassPostConstruct = env.AddClassPostConstruct
local modimport = env.modimport

GLOBAL.setfenv(1, GLOBAL)

local Levels = require("map/levels")
require("constants")

-- Load textfix sub-modules (TextWidget.SetString hook)
modimport("scripts/textfix/init.lua")

-- Tải tệp ngôn ngữ
print("[DST-Viet] Đang tải bản dịch tiếng Việt...")
env.LoadPOFile(main.StorePath .. main.MainPoFile, main.SelectedLanguage)
main.PO = LanguageTranslator.languages[main.SelectedLanguage]

-- Kiểm tra nếu file .po tải thất bại
if not main.PO then
    print("[DST-Viet] LỖI: Không tải được " .. main.MainPoFile .. " — mod sẽ không dịch.")
    return
end

-- Lọc bỏ các entry trống hoặc placeholder
for k, v in pairs(main.PO) do
    -- BUG FIX: dùng plain string matching (tham số thứ 3 = true), không dùng Lua pattern
    -- vì "*PLACEHOLDER" là Lua pattern không hợp lệ (sẽ gây lỗi runtime)
    if v == "<trống>" or v == "" or v:find("PLACEHOLDER", 1, true) then
        main.PO[k] = nil
    end
end
-- Áp dụng bản dịch vào bảng STRINGS ngay lập tức
-- (game cũng sẽ gọi lại sau khi tất cả mod load, nhưng gọi sớm đảm bảo
-- các mod khác không cache lại giá trị tiếng Anh từ STRINGS trước đó)
TranslateStringTable(STRINGS)
print("[DST-Viet] Đã tải xong bản dịch tiếng Việt.")

-- Thay đổi tên các chế độ chơi (GAME_MODES dùng text thay vì key)
if rawget(_G, "GAME_MODES") and STRINGS.UI.GAMEMODES then
    for i, v in pairs(GAME_MODES) do
        for ii, vv in pairs(STRINGS.UI.GAMEMODES) do
            if v.text ~= nil and v.text == vv then
                GAME_MODES[i].text = main.PO["STRINGS.UI.GAMEMODES." .. ii] or GAME_MODES[i].text
            end
            if v.description ~= nil and v.description == vv then
                GAME_MODES[i].description = main.PO["STRINGS.UI.GAMEMODES." .. ii] or GAME_MODES[i].description
            end
        end
    end
end

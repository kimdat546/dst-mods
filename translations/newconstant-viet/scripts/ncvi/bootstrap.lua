-- bootstrap.lua — điểm vào của hệ ngôn ngữ, gọi từ modmain.
--
--     modimport("scripts/ncvi/bootstrap.lua")
--
-- Thay cho khối if/else cứng của mod gốc:
--     if locale == "zh" or "zht" or "zhr" then require"languages.newstring.*"
--     else                                    require"languages.newstring_en.*"
--
-- ⚠ File này nạp bằng modimport nên chạy trong MÔI TRƯỜNG SANDBOX của mod, chỉ
-- có sẵn: pairs ipairs print math table type string tostring require Class
-- TUNING GLOBAL modname MODROOT. KHÔNG có rawget/rawset/tonumber — muốn dùng
-- phải gọi qua _G. (Ngược lại, ncvi/apply.lua và ncvi/i18n.lua nạp bằng require
-- nên chạy trong _G thật và dùng rawget trực tiếp được.)

local _G = GLOBAL
local rawget, pcall = _G.rawget, _G.pcall

local i18n  = require("ncvi/i18n")
local apply = require("ncvi/apply")

-- Danh sách nhân vật để toả các chuỗi ACTIONFAIL.
-- Mod gốc chép tay 5 dòng gán cho từng nhân vật trong một vòng lặp; ở đây chỉ
-- cần khai báo một lần ở GENERIC rồi nhân bản ra, nên thêm chuỗi mới không phải
-- sửa vòng lặp.
local CHARACTERS = {
    "WILLOW", "WOLFGANG", "WENDY", "WICKERBOTTOM", "WOODIE", "WAXWELL",
    "WATHGRITHR", "WEBBER", "WINONA", "WARLY", "WORTOX", "WORMWOOD",
    "WURT", "WALTER", "WANDA",
}

-- Những nhánh dưới GENERIC cần nhân bản sang mọi nhân vật.
-- Nhân vật nào không có chuỗi riêng thì DST tự lùi về GENERIC, nhưng mod gốc
-- vẫn gán tay cho từng người — giữ nguyên hành vi đó để không đổi gameplay.
local FANOUT_PREFIX = "STRINGS.CHARACTERS.GENERIC.ACTIONFAIL."

-- Ngôn ngữ hiển thị.
-- Ưu tiên tuỳ chọn người chơi chọn trong menu mod; chỉ khi để "auto" mới dò theo
-- locale của game. Phải làm vậy vì DST KHÔNG CÓ locale tiếng Việt — nếu chỉ dò
-- locale thì bản dịch này không bao giờ được dùng.
local function pick_locale()
    local cfg = nil
    if GetModConfigData ~= nil then
        local ok, v = pcall(GetModConfigData, "ncvi_language")
        if ok then cfg = v end
    end
    if type(cfg) == "string" and cfg ~= "" and cfg ~= "auto" then
        return cfg
    end

    if modinfo ~= nil and modinfo.locale ~= nil then
        return modinfo.locale
    end
    local lt = rawget(_G, "LanguageTranslator")
    return lt ~= nil and lt.defaultlang or nil
end

local function run()
    local locale = pick_locale()

    local tbl, stats = i18n.resolve(require, locale)

    local ok, errors = apply.apply(_G.STRINGS, tbl)

    -- Toả ACTIONFAIL ra từng nhân vật.
    local fanned = 0
    local chars = _G.STRINGS.CHARACTERS
    if chars ~= nil then
        for path, value in pairs(tbl) do
            local tail = string.match(path, "^" .. FANOUT_PREFIX:gsub("%.", "%%.") .. "(.+)$")
            if tail ~= nil then
                for _, name in ipairs(CHARACTERS) do
                    if chars[name] ~= nil then
                        local done = apply.set(_G.STRINGS,
                            "STRINGS.CHARACTERS." .. name .. ".ACTIONFAIL." .. tail, value)
                        if done then fanned = fanned + 1 end
                    end
                end
            end
        end
    end

    -- Áp LẠI sau khi mọi mod đã nạp xong.
    -- Bắt buộc: các mod nạp sau Core có thể ghi đè STRINGS mà không hề đụng tới
    -- file ngôn ngữ. Ví dụ thật — Nightmare (priority -1024, nạp sau Core) gọi
    -- AddAction("LUNGE","突刺"), mà AddAction tự gán STRINGS.ACTIONS[id] từ tham
    -- số thứ hai. Kết quả: 3 nhãn hành động quay lại tiếng Trung dù bản dịch đã
    -- áp đúng. Chỉ phát hiện được khi quét STRINGS lúc chạy thật.
    if AddSimPostInit ~= nil then
        AddSimPostInit(function()
            local n = apply.apply(_G.STRINGS, tbl)
            print(string.format("[NewConstant-VI] áp lại sau khi nạp xong: %d chuỗi", n))
        end)
    end

    print(i18n.describe(stats))
    print(string.format("[NewConstant-VI] đã áp %d chuỗi, toả %d cho nhân vật, %d lỗi",
                        ok, fanned, #errors))
    for i = 1, math.min(#errors, 5) do
        print("[NewConstant-VI] LỖI: " .. errors[i])
    end
    if #errors > 5 then
        print("[NewConstant-VI] … và " .. (#errors - 5) .. " lỗi nữa")
    end

    return ok, fanned, errors
end

return run()

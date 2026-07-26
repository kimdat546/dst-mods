local _G = GLOBAL
local env = env
local modimport = env.modimport

GLOBAL.setfenv(1, GLOBAL)

print("[Myth-Viet] Đang tải bản dịch tiếng Việt cho bộ mod Thần Thoại...")

-- Bảng textfix dùng chung — các sub-module sẽ thêm Chinese → Vietnamese vào đây
local textfix = {}
-- Substring replacements — các từ Chinese xuất hiện trong string ghép
local word_fix = {}

-- Export cả hai ra global TRƯỚC khi load sub-modules
rawset(_G, "myth_viet_textfix", textfix)
rawset(_G, "myth_viet_word_fix", word_fix)

-- Load textfix entries (Chinese → Vietnamese)
modimport("scripts/patch_textfix.lua")

-- Myth Characters (神话人物) + Theme (神话书说) — cả 2 encrypted, dùng textfix
modimport("scripts/characters_textfix.lua")
modimport("scripts/theme_textfix.lua")

-- Fallback textfix: Chinese→Vietnamese cho tất cả phase strings
-- (đảm bảo dịch khi STRINGS override thất bại do table chưa sẵn sàng)
modimport("scripts/fallback_textfix.lua")
-- English→Vietnamese fallback cho Myth Characters mod (dùng English)
modimport("scripts/fallback_en_textfix.lua")

-- Debug mode — log Chinese text chưa dịch (đặt false khi release)
local DEBUG_LOG_MISSING = false
local logged_missing = {}

-- Check strict: chỉ return true nếu có 2+ CJK chars liên tiếp (tránh false positive)
local function has_chinese(s)
    local count = 0
    local i = 1
    while i <= #s do
        local b = string.byte(s, i)
        if b and b >= 0xE4 and b <= 0xE9 then
            count = count + 1
            if count >= 2 then return true end
            i = i + 3
        else
            count = 0
            i = i + 1
        end
    end
    return false
end

-- Pattern-based translations cho dynamic strings (format với số/biến)
-- Chú ý: Lua pattern là byte-based, phải viết tường minh 2 version cho : và ：
local textfix_patterns = {
    {"寸心:%s*(%-?%d+)", "Thốn Tâm: %1"},
    {"寸心：%s*(%-?%d+)", "Thốn Tâm: %1"},
    {"寸心:%s*%-%-", "Thốn Tâm: --"},
    {"寸心：%s*%-%-", "Thốn Tâm: --"},
    {"劫运:%s*(%-?%d+)", "Kiếp Vận: %1"},
    {"劫运：%s*(%-?%d+)", "Kiếp Vận: %1"},
    {"劫运:%s*%-%-", "Kiếp Vận: --"},
    {"劫运：%s*%-%-", "Kiếp Vận: --"},
    {"时辰:%s*(.+)$", "Thời Thần: %1"},
    {"时辰：%s*(.+)$", "Thời Thần: %1"},
    {"剩余(%d+)天", "Còn %1 ngày"},
    {"剩余(%d+)分钟", "Còn %1 phút"},
    {"剩余(%d+)秒", "Còn %1 giây"},
    {"已历：【(.+)】", "Đã trải: [%1]"},
    {"已历:【(.+)】", "Đã trải: [%1]"},
}

-- Hook TextWidget.SetString để dịch mọi Chinese text khi render
local oldSetString = TextWidget.SetString
TextWidget.SetString = function(guid, str)
    if type(str) == "string" then
        -- 1. Thử exact match, rồi trimmed match (xử lý trailing whitespace)
        local translated = textfix[str]
        if not translated then
            local trimmed = str:match("^(.-)%s*$")
            if trimmed ~= str and textfix[trimmed] then
                translated = textfix[trimmed] .. str:sub(#trimmed + 1)
            end
        end
        if translated then
            str = translated
        else
            -- 2. Thử pattern match (dynamic format strings)
            for _, pair in ipairs(textfix_patterns) do
                str = str:gsub(pair[1], pair[2])
            end
            -- 3. Thử substring replacement (từng từ Chinese trong string ghép)
            if has_chinese(str) then
                for cn, vn in pairs(word_fix) do
                    str = str:gsub(cn, vn)
                end
            end
            -- 4. Log nếu vẫn còn Chinese HOẶC tiếng Anh ngắn (self-filter tránh recursive)
            if DEBUG_LOG_MISSING and not logged_missing[str]
               and not str:find("Myth%-Viet", 1, true) then
                -- Log Chinese always
                if has_chinese(str) then
                    logged_missing[str] = true
                    print("[Myth-Viet] MISSING_CN: " .. str)
                -- Log English Myth-related content bằng cách check keywords
                elseif #str <= 150 and str:find("%a%a") then
                    local lower = str:lower()
                    local keywords = {"sage", "nezha", "pigsy", "yutu", "wukong", "canopy",
                                      "bunny", "immortal", "myth", "lady white", "three eye",
                                      "jade", "laozi", "chang'e", "spider", "yama", "bamboo",
                                      "peach", "ginseng", "moon palace", "cudgel", "forkspear",
                                      "rake", "damask", "cauldron", "tao", "dao", "qi"}
                    for _, kw in ipairs(keywords) do
                        if lower:find(kw, 1, true) then
                            logged_missing[str] = true
                            print("[Myth-Viet] MISSING_EN: " .. str)
                            break
                        end
                    end
                end
            end
        end
    end
    oldSetString(guid, str)
end

-- Áp dụng STRINGS overrides SAU KHI tất cả mod load (Patch mod load sau ta)
env.AddSimPostInit(function()
    modimport("scripts/patch_strings.lua")
    modimport("scripts/phase1_strings.lua")
    modimport("scripts/phase2_strings.lua")
    modimport("scripts/phase3a_strings.lua")
    modimport("scripts/phase_en_strings.lua")
    modimport("scripts/phase_en2_strings.lua")
    modimport("scripts/phase_final_strings.lua")
    -- Canonical wiki overrides (load cuối cùng để chiếm quyền)
    modimport("scripts/wiki_canonical.lua")
    -- Quét STRINGS tìm Chinese chưa dịch (đặt false khi release)
    local SCAN_STRINGS = false
    if SCAN_STRINGS then
        modimport("scripts/strings_scanner.lua")
    end
end)

-- Đếm entries để debug
local count = 0
for _ in pairs(textfix) do count = count + 1 end
print("[Myth-Viet] Đã tải xong " .. count .. " bản dịch.")

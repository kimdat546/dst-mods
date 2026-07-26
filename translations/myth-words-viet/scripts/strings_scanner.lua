-- strings_scanner.lua
-- Quét toàn bộ STRINGS table tìm text chưa dịch
-- Chạy một lần trong AddSimPostInit — dump tất cả để user grep

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local function has_chinese(s)
    if type(s) ~= "string" then return false end
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

local function has_vietnamese(s)
    -- Vietnamese specific: diacritics + combining marks
    if not s then return false end
    if s:find("[ăâđêôơưĂÂĐÊÔƠƯ]") then return true end
    for i = 1, #s do
        local b = string.byte(s, i)
        if b == 0xCC or b == 0xCD then return true end
        -- Vietnamese precomposed vowels: E1 BA/BB xx
        if b == 0xE1 and i + 1 <= #s then
            local b2 = string.byte(s, i + 1)
            if b2 == 0xBA or b2 == 0xBB then return true end
        end
    end
    return false
end

local textfix = rawget(_G, "myth_viet_textfix") or {}
local word_fix = rawget(_G, "myth_viet_word_fix") or {}

local function is_covered_by_textfix(s)
    if textfix[s] then return true end
    local stripped = s
    for cn, _ in pairs(word_fix) do
        stripped = stripped:gsub(cn, "")
    end
    return not has_chinese(stripped)
end

-- Mở rộng list path Myth (toàn diện)
local MYTH_KEY_PATTERNS = {
    "XYDZTZ", "MYTH", "MONKEY_KING", "MONKEY", "WUKONG",
    "YANGJIAN", "YANG_JIAN", "NEZA", "NEZHA",
    "PIGSY", "PIGGY", "WHITEBONE", "WHITE_BONE", "WB_",
    "MADAMEWEB", "MADAME_WEB", "WEB_", "SPIDER_QUEEN",
    "YUTU", "YU_TU", "YAMA", "COMMISSIONER", "YANG_GUI",
    "HUA_", "SKYHOUND", "LAOZI", "LAO_ZI", "QINGNIU",
    "BLACKBEAR", "BLACK_BEAR", "GOLDFROG", "GOLD_FROG",
    "NIAN", "BAMBOO", "PEACH", "INFANTREE", "INFANT_FRUIT",
    "GINSENG", "RHINO", "PANDA", "PANDAMAN",
    "LOTUS", "MOONCAKE", "FIRECRACKER", "LANTERN",
    "BONE_WAND", "BONE_MIRROR", "DRESSING_ARMOR",
    "CANE_PEACH", "CORRUPTEDHEART", "SOULS",
    "TORTOISE", "CRANE", "FAIRY", "PIG_SCEPTRE",
    "IRON_ARMOR", "BLOOD_JADE", "GOLD_CORD",
    "RED_LANTERN", "FENCE", "SCREEN",
}

local function is_myth_path(path)
    for _, pat in ipairs(MYTH_KEY_PATTERNS) do
        if path:find(pat) then return true end
    end
    return false
end

local found_chinese = {}
local found_en = {}

local function scan(tbl, path, depth)
    if depth > 8 then return end
    if type(tbl) ~= "table" then return end
    for k, v in pairs(tbl) do
        local key_path = path .. "." .. tostring(k)
        if type(v) == "string" and #v > 0 then
            if has_chinese(v) and not is_covered_by_textfix(v) then
                found_chinese[key_path] = v
            elseif is_myth_path(key_path) and not has_vietnamese(v) and #v >= 2 then
                -- English (or unknown language) under Myth path, not yet Vietnamese
                found_en[key_path] = v
            end
        elseif type(v) == "table" then
            scan(v, key_path, depth + 1)
        end
    end
end

print("[Myth-Viet-Scanner] ===== BẮT ĐẦU SCAN =====")
scan(STRINGS, "STRINGS", 0)

local cn_count = 0
for _ in pairs(found_chinese) do cn_count = cn_count + 1 end
print("[Myth-Viet-Scanner] ----- CHINESE (" .. cn_count .. ") -----")
for path, str in pairs(found_chinese) do
    print("[Myth-Viet-Scanner] CN | " .. path .. " = " .. str)
end

local en_count = 0
for _ in pairs(found_en) do en_count = en_count + 1 end
print("[Myth-Viet-Scanner] ----- MYTH ENGLISH (" .. en_count .. ") -----")
for path, str in pairs(found_en) do
    print("[Myth-Viet-Scanner] EN | " .. path .. " = " .. str)
end

print("[Myth-Viet-Scanner] ===== KẾT THÚC SCAN =====")

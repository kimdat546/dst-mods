-- Main translation logic. Runs in the mod env.
-- Pattern: TextWidget hook (render-time) + STRINGS overrides via AddSimPostInit.

local _G = GLOBAL
local env = env
local modimport = env.modimport
local mod_env = env
GLOBAL.setfenv(1, GLOBAL)

local DEBUG_SCANNER = _G.DANGTIEN_DEBUG_SCANNER == true
local DEBUG_MISSING = _G.DANGTIEN_DEBUG_MISSING == true

-- =========================================================================
-- Shared lookup tables (exposed for sub-modules)
-- =========================================================================
local textfix = {}        -- exact-match: textfix["Hán"] = "Việt"
local word_fix = {}       -- substring: replace inside compound strings
local textfix_patterns = {} -- {pattern, replacement} pairs for format strings
rawset(_G, "dangtien_viet_textfix", textfix)
rawset(_G, "dangtien_viet_word_fix", word_fix)
rawset(_G, "dangtien_viet_textfix_patterns", textfix_patterns)

-- =========================================================================
-- Helper: set_str — assign nested STRINGS path safely
-- =========================================================================
local function set_str(path, value)
    local parts = {}
    for p in path:gmatch("[^%.]+") do parts[#parts + 1] = p end
    if parts[1] == "STRINGS" then table.remove(parts, 1) end
    local tbl = STRINGS
    for i = 1, #parts - 1 do
        if type(tbl[parts[i]]) ~= "table" then return false end
        tbl = tbl[parts[i]]
    end
    tbl[parts[#parts]] = value
    return true
end
rawset(_G, "dangtien_viet_set_str", set_str)

-- =========================================================================
-- Has-Chinese check (UTF-8: CJK starts in 0xE3-0xEA range)
-- =========================================================================
local function has_chinese(s)
    if type(s) ~= "string" or #s < 3 then return false end
    local i = 1
    while i <= #s - 2 do
        local b = string.byte(s, i)
        if b and b >= 0xE3 and b <= 0xEA then
            local b2 = string.byte(s, i + 1)
            local b3 = string.byte(s, i + 2)
            if b2 and b3 and b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF then
                return true
            end
            i = i + 3
        else
            i = i + 1
        end
    end
    return false
end
rawset(_G, "dangtien_viet_has_chinese", has_chinese)

-- =========================================================================
-- TextWidget hook — render-time translation
-- =========================================================================
local logged_missing = {}
local oldSetString = TextWidget.SetString
TextWidget.SetString = function(guid, str)
    if type(str) == "string" and #str > 0 then
        local translated = textfix[str]
        if not translated then
            -- trimmed-match fallback
            local trimmed = str:match("^(.-)%s*$")
            if trimmed and trimmed ~= str and textfix[trimmed] then
                translated = textfix[trimmed] .. str:sub(#trimmed + 1)
            end
        end
        if translated then
            str = translated
        else
            -- pattern matching for format strings
            for _, p in ipairs(textfix_patterns) do
                str = str:gsub(p[1], p[2])
            end
            -- substring replacement for compound text
            for cn, vn in pairs(word_fix) do
                str = str:gsub(cn, vn)
            end
            -- log missing CN strings (debug only)
            if DEBUG_MISSING and has_chinese(str) and not logged_missing[str]
               and not str:find("DangTienVN", 1, true) then
                logged_missing[str] = true
                print("[DangTienVN] MISSING_CN: " .. str)
            end
        end
    end
    oldSetString(guid, str)
end

-- =========================================================================
-- Load translation tables (sub-modules populate textfix/word_fix)
-- =========================================================================
-- Glossary (canonical names from wiki PDF) — load FIRST so later phases reuse
modimport("scripts/wiki_glossary.lua")
modimport("scripts/textfix_dynamic.lua")

-- Phase translation tables (textfix + word_fix entries)
-- Uncomment as phases are completed:
-- modimport("scripts/textfix_speech.lua")
-- modimport("scripts/textfix_ui.lua")
-- modimport("scripts/fallback_textfix.lua")

-- =========================================================================
-- STRINGS overrides — runs AFTER all mods load
-- =========================================================================
mod_env.AddSimPostInit(function()
    modimport("scripts/phase2_strings.lua")

    if DEBUG_SCANNER then
        modimport("scripts/strings_scanner.lua")
    end
end)

print("[DangTienVN] Loaded. Scanner=" .. tostring(DEBUG_SCANNER)
      .. " MissingLog=" .. tostring(DEBUG_MISSING))

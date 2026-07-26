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
-- Translation core — applies textfix/patterns/word_fix to a string
-- =========================================================================
local logged_missing = {}
local function translate_str(str)
    if type(str) ~= "string" or #str == 0 then return str end
    local translated = textfix[str]
    if not translated then
        local trimmed = str:match("^(.-)%s*$")
        if trimmed and trimmed ~= str and textfix[trimmed] then
            translated = textfix[trimmed] .. str:sub(#trimmed + 1)
        end
    end
    if translated then return translated end
    -- pattern matching first, then substring replace
    for _, p in ipairs(textfix_patterns) do
        str = str:gsub(p[1], p[2])
    end
    for cn, vn in pairs(word_fix) do
        str = str:gsub(cn, vn)
    end
    if DEBUG_MISSING and has_chinese(str) and not logged_missing[str]
       and not str:find("DangTienVN", 1, true) then
        logged_missing[str] = true
        print("[DangTienVN] MISSING_CN: " .. str)
    end
    return str
end
rawset(_G, "dangtien_viet_translate", translate_str)

-- DIAG counter: how often each hook fires
local hook_counts = {textwidget=0, text=0, multi=0, textedit=0}
local function diag_tick(name)
    hook_counts[name] = (hook_counts[name] or 0) + 1
    if hook_counts[name] % 200 == 0 then
        print("[DangTienVN] DIAG " .. name .. " calls=" .. hook_counts[name])
    end
end

-- Hook 1: TextWidget (C++ class, low-level renderer)
local oldSetString = TextWidget.SetString
TextWidget.SetString = function(guid, str)
    diag_tick("textwidget")
    oldSetString(guid, translate_str(str))
end

-- Hook 2: Text widget (Lua class, used by popups/screens)
-- This is the Lua wrapper — many widgets call self:SetString() which routes here
local Text = require "widgets/text"
if Text and Text.SetString then
    local oldTextSetString = Text.SetString
    Text.SetString = function(self, str)
        diag_tick("text")
        return oldTextSetString(self, translate_str(str))
    end
end
if Text and Text.SetMultilineTruncatedString then
    local oldMulti = Text.SetMultilineTruncatedString
    Text.SetMultilineTruncatedString = function(self, str, ...)
        diag_tick("multi")
        return oldMulti(self, translate_str(str), ...)
    end
end

-- Hook 2.5: scan all loaded widget modules for any class with SetString
-- (some mods define custom widgets that don't extend Text)
local function hook_widget_module(modname)
    local ok, mod = pcall(require, modname)
    if not ok or type(mod) ~= "table" then return end
    if mod.SetString and mod ~= Text then
        local orig = mod.SetString
        mod.SetString = function(self, str)
            diag_tick("text") -- count under "text"
            return orig(self, translate_str(str))
        end
    end
end
-- DST built-in text-like widgets
for _, m in ipairs({
    "widgets/numericspinner",
    "widgets/spinner",
    "widgets/textbutton",
    "widgets/imagebutton",
}) do hook_widget_module(m) end

-- Hook 3: TextEdit widget (input fields, also extends Text often)
local ok_te, TextEdit = pcall(require, "widgets/textedit")
if ok_te and TextEdit and TextEdit.SetString then
    local oldTE = TextEdit.SetString
    TextEdit.SetString = function(self, str)
        diag_tick("textedit")
        return oldTE(self, translate_str(str))
    end
end

-- =========================================================================
-- Load translation tables (sub-modules populate textfix/word_fix)
-- =========================================================================
-- Glossary (canonical names from wiki PDF) — load FIRST so later phases reuse
modimport("scripts/wiki_glossary.lua")
modimport("scripts/textfix_dynamic.lua")
-- modimport("scripts/book_dump.lua")  -- disabled: no longer needed

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
    modimport("scripts/phase3_speech_wangmazi.lua")
    modimport("scripts/phase4_mod_private.lua")
    modimport("scripts/phase5_book_strings_data.lua")
    modimport("scripts/phase5_book_strings.lua")
    -- phase6 nạp CUỐI: vá các chuỗi còn thiếu ở mod gốc v19.0 (Trần Bình An,
    -- XD_USE_INVENTORY). Đặt sau cùng để không bị phase trước ghi đè.
    modimport("scripts/phase6_v19_strings.lua")

    if DEBUG_SCANNER then
        modimport("scripts/strings_scanner.lua")
        modimport("scripts/global_scanner.lua")
        modimport("scripts/runtime_dump.lua")
    end
end)

print("[DangTienVN] Loaded. Scanner=" .. tostring(DEBUG_SCANNER)
      .. " MissingLog=" .. tostring(DEBUG_MISSING))

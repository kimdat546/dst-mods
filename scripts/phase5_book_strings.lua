-- Phase 5: Load complete Tu Tien Mat Quyen translations.
-- Source: extracted from a working English/Vietnamese fork of 登仙.
-- Runs scripts/main/strings.lua which assigns 600+ STRINGS entries.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

-- Note: data file (phase5_book_strings_data.lua) is loaded by main.lua
-- BEFORE this file runs. It assigns ~600 entries into GLOBAL.STRINGS.
-- This file syncs those into mod 登仙's private STRINGS so its book reads them.
local mm = rawget(_G, "ModManager")
if mm and mm.mods then
    for _, m in ipairs(mm.mods) do
        if m.GLOBAL and m.GLOBAL.STRINGS then
            local mod_S = m.GLOBAL.STRINGS
            local game_S = STRINGS
            -- Sync NAMES, RECIPE_DESC, CHARACTERS.GENERIC.DESCRIBE
            local function sync_table(src, dst)
                if type(src) ~= "table" or type(dst) ~= "table" then return end
                for k, v in pairs(src) do
                    if type(v) == "string" and dst[k] ~= nil then
                        dst[k] = v
                    elseif type(v) == "table" and type(dst[k]) == "table" then
                        sync_table(v, dst[k])
                    end
                end
            end
            if game_S.NAMES and mod_S.NAMES then sync_table(game_S.NAMES, mod_S.NAMES) end
            if game_S.RECIPE_DESC and mod_S.RECIPE_DESC then sync_table(game_S.RECIPE_DESC, mod_S.RECIPE_DESC) end
            if game_S.CHARACTERS and mod_S.CHARACTERS then sync_table(game_S.CHARACTERS, mod_S.CHARACTERS) end
        end
    end
end

print("[DangTienVN] Phase 5 book strings loaded.")

-- textfix/init.lua
-- Quản lý tất cả bản dịch động (text không qua hệ thống .po)
-- Mỗi sub-module thêm entries vào bảng textfix chung

local _G = GLOBAL
local env = env

-- Bảng dịch toàn cục — các sub-module sẽ thêm vào đây
textfix = {}

-- Load các sub-module theo thứ tự
env.modimport("scripts/textfix/ui_gamesetup.lua")
env.modimport("scripts/textfix/character_speech.lua")

-- Hook vào TextWidget.SetString để dịch text động trong UI
-- (Những string không đi qua hệ thống STRINGS.* / .po)
local oldSetString = _G.TextWidget.SetString
_G.TextWidget.SetString = function(guid, str)
    if type(str) == "string" then
        str = textfix[str] or str
    end
    oldSetString(guid, str)
end

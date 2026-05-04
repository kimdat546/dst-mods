-- Đăng Tiên - Tiếng Việt — entry point
_G = GLOBAL

_G.DANGTIEN_DEBUG_SCANNER = GetModConfigData("DEBUG_SCANNER") == true
_G.DANGTIEN_DEBUG_MISSING = GetModConfigData("DEBUG_MISSING") == true

modimport("scripts/main.lua")

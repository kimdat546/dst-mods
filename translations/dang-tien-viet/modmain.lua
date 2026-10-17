-- Đăng Tiên - Tiếng Việt — entry point
_G = GLOBAL

_G.DANGTIEN_DEBUG_SCANNER = GetModConfigData("DEBUG_SCANNER") == true
_G.DANGTIEN_DEBUG_MISSING = GetModConfigData("DEBUG_MISSING") == true

modimport("scripts/main.lua")

-- Trang sách hướng dẫn vẽ lại bằng tiếng Việt (tráo atlas lúc chạy)
modimport("scripts/book_images.lua")

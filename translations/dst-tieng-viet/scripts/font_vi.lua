-- font_vi.lua — nạp font game ĐÃ THÊM chữ tiếng Việt (fonts/vi_*.zip, sinh bởi tools/tao_font.py)
--
-- ⚠ VÌ SAO. Font gốc chỉ có ~326 glyph: thiếu ơ ư và mọi chữ dấu riêng của tiếng
--   Việt (ạ ả ọ ế ờ ự…) → game lấy từ font dự phòng khác kiểu, chữ nhìn lệch nét.
--
-- CÁCH LÀM (theo mẫu mod Workshop đã chạy được): khai Asset("FONT") trong Assets,
-- LoadFont dưới alias MỚI "vi_<alias>", dựng lại fallback y như font gốc, rồi mới
-- trỏ các biến TALKINGFONT, UIFONT… sang alias mới.
--
-- ⚠ AN TOÀN: chỉ đổi biến font khi LoadFont chạy không lỗi. Trỏ biến sang một alias
--   chưa nạp thì chữ TRỐNG TRƠN — tệ hơn nhiều so với lệch nét.
-- Tắt được bằng tuỳ chọn "Font tiếng Việt" trong cấu hình mod.

local _G = GLOBAL

-- tên file (fonts/<file>.zip) → alias gốc trong scripts/fonts.lua
local DS = {
    { "vi_talkingfont", "talkingfont" }, { "vi_talkingfont_wormwood", "talkingfont_wormwood" },
    { "vi_talkingfont_tradein", "talkingfont_tradein" }, { "vi_talkingfont_hermit", "talkingfont_hermit" },
    { "vi_hammerhead50", "hammerhead" }, { "vi_bellefair50", "bellefair" },
    { "vi_bellefair50_outline", "bellefair_outline" }, { "vi_stint-ucr50", "stint-ucr" },
    { "vi_stint-ucr20", "stint-small" }, { "vi_opensans50", "opensans" },
    { "vi_belisaplumilla50", "bp50" }, { "vi_belisaplumilla100", "bp100" },
    { "vi_buttonfont", "buttonfont" }, { "vi_spirequal", "spirequal" },
    { "vi_spirequal_small", "spirequal_small" }, { "vi_spirequal_outline", "spirequal_outline" },
    { "vi_spirequal_outline_small", "spirequal_outline_small" },
}

-- biến font toàn cục của game (scripts/fonts.lua)
local BIEN = {
    "DEFAULTFONT", "DIALOGFONT", "TITLEFONT", "UIFONT", "BUTTONFONT", "NEWFONT", "NEWFONT_SMALL",
    "NEWFONT_OUTLINE", "NEWFONT_OUTLINE_SMALL", "NUMBERFONT", "TALKINGFONT", "TALKINGFONT_WORMWOOD",
    "TALKINGFONT_TRADEIN", "TALKINGFONT_HERMIT", "CHATFONT", "HEADERFONT", "CHATFONT_OUTLINE",
    "SMALLNUMBERFONT", "BODYTEXTFONT",
}

for _, f in ipairs(DS) do
    table.insert(Assets, Asset("FONT", "fonts/" .. f[1] .. ".zip"))
end

local function FontGoc(alias)
    for _, v in ipairs(_G.FONTS or {}) do
        if v.alias == alias then return v end
    end
end

local function NapFontViet()
    local da_nap = {}
    for _, f in ipairs(DS) do
        local moi = "vi_" .. f[2]
        local ok = _G.pcall(function()
            _G.TheSim:LoadFont(_G.resolvefilepath("fonts/" .. f[1] .. ".zip"), moi)
            local goc = FontGoc(f[2])
            if goc and goc.fallback then _G.TheSim:SetupFontFallbacks(moi, goc.fallback) end
            if goc and goc.adjustadvance then _G.TheSim:AdjustFontAdvance(moi, goc.adjustadvance) end
        end)
        if ok then da_nap[f[2]] = moi end
    end
    local so_nap = 0
    for _ in pairs(da_nap) do so_nap = so_nap + 1 end
    local doi = 0
    for _, ten in ipairs(BIEN) do
        local cu = _G.rawget(_G, ten)
        if cu and da_nap[cu] then
            _G.rawset(_G, ten, da_nap[cu])
            doi = doi + 1
        end
    end
    print("[DST-Viet] font tiếng Việt: nạp " .. so_nap .. "/" .. #DS .. " font, đổi " .. doi .. " biến")
end

if GetModConfigData("FONT_VIET") ~= false then
    AddSimPostInit(function()
        local ok, loi = _G.pcall(NapFontViet)
        if not ok then print("[DST-Viet] LỖI nạp font tiếng Việt, giữ font gốc: " .. tostring(loi)) end
    end)
end

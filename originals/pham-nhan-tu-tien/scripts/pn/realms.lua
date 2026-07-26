-- Realm ladder — pure data. M1 only enables LUYEN_KHI (13 layers). Higher realms
-- are defined (enabled=false) so later milestones flip a flag, no logic changes.
local config = require("pn/config")

local M = {}

M.macro_tiers = { "PHAM_NHAN", "LINH_GIOI", "TIEN_GIOI" }

M.realms = {
    { id="LUYEN_KHI",  macro="PHAM_NHAN", display="Luyện Khí",  mode="layers", layer_count=13, enabled=true },
    { id="TRUC_CO",    macro="LINH_GIOI", display="Trúc Cơ",    mode="quarters", enabled=false },
    { id="KET_DAN",    macro="LINH_GIOI", display="Kết Đan",    mode="quarters", enabled=false },
    { id="NGUYEN_ANH", macro="LINH_GIOI", display="Nguyên Anh", mode="quarters", enabled=false },
    { id="HOA_THAN",   macro="LINH_GIOI", display="Hoá Thần",   mode="quarters", enabled=false },
    { id="LUYEN_HU",   macro="TIEN_GIOI", display="Luyện Hư",   mode="quarters", enabled=false },
    { id="HOP_THE",    macro="TIEN_GIOI", display="Hợp Thể",    mode="quarters", enabled=false },
    { id="DAI_THUA",   macro="TIEN_GIOI", display="Đại Thừa",   mode="quarters", enabled=false },
}

-- Total cultivation "tiers" enabled in M1 = number of Luyện Khí layers.
function M.GetMaxTier()
    for _, r in ipairs(M.realms) do
        if r.id == "LUYEN_KHI" then return r.layer_count end
    end
    return 13
end

-- tu vi needed to reach tier N (1..max). threshold(N) = BASE * N^EXP.
function M.GetThreshold(target_tier)
    if target_tier <= 0 then return 0 end
    return math.floor(config.TU_VI.THRESHOLD_BASE * (target_tier ^ config.TU_VI.THRESHOLD_EXPONENT))
end

-- Display string for a tier. 0 = Phàm Nhân; 1..13 = Luyện Khí tầng N.
function M.GetDisplay(tier)
    if tier <= 0 then return "Phàm Nhân" end
    if tier <= M.GetMaxTier() then return string.format("Luyện Khí tầng %d", tier) end
    return "Vô danh"
end

-- HUD colour by tier (white phàm nhân → light-blue early → cyan high)
function M.GetColor(tier)
    if tier <= 0 then return {1,1,1,1} end
    if tier <= 6 then return {0.7,0.9,1,1} end
    return {0.3,1,1,1}
end

return M

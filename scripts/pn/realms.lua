-- scripts/pn/realms.lua
-- Helpers for cảnh giới (realm) progression — derived from tuning constants.

local TUNING = require("pn/tuning")

local M = {}

-- Vietnamese display name for a Luyện Khí tier
local LUYEN_KHI_DISPLAY = {
    [0] = "Phàm Nhân",
    [1] = "Luyện Khí sơ kỳ (tầng 1)",
    [2] = "Luyện Khí tầng 2",
    [3] = "Luyện Khí tầng 3",
    [4] = "Luyện Khí tầng 4",
    [5] = "Luyện Khí trung kỳ (tầng 5)",
    [6] = "Luyện Khí tầng 6",
    [7] = "Luyện Khí tầng 7",
    [8] = "Luyện Khí hậu kỳ (tầng 8)",
    [9] = "Luyện Khí đỉnh phong (tầng 9)",
}

-- Tu vi threshold to advance FROM tier N TO tier N+1.
-- threshold(N+1) = BASE * (N+1)^EXPONENT
function M.GetThreshold(target_tier)
    if target_tier <= 0 then return 0 end
    return math.floor(
        TUNING.TU_VI.TIER_THRESHOLD_BASE *
        (target_tier ^ TUNING.TU_VI.TIER_THRESHOLD_EXPONENT)
    )
end

-- Cumulative tu vi from tier 0 to reach `tier`.
function M.GetCumulativeThreshold(tier)
    local total = 0
    for i = 1, tier do
        total = total + M.GetThreshold(i)
    end
    return total
end

-- Display name
function M.GetDisplay(tier)
    return LUYEN_KHI_DISPLAY[tier] or "Vô danh"
end

-- Color for HUD display based on tier (hex RGB)
function M.GetTierColor(tier)
    if tier == 0     then return {1, 1, 1, 1}      end
    if tier <= 4     then return {0.7, 0.9, 1, 1}  end
    if tier <= 8     then return {0.3, 1, 1, 1}    end
    return {1, 0.85, 0.2, 1}  -- tier 9 = gold
end

-- Max tier in MVP2
function M.GetMaxTier()
    return TUNING.TU_VI.MAX_TIER_MVP
end

return M

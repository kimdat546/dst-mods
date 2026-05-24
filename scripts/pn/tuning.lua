-- scripts/pn/tuning.lua
-- Cultivation balance constants. All numbers tuneable here without touching logic.

return {
    -- Tu vi progression curve: threshold(N) = BASE * N^EXPONENT
    -- Tier 1 = 100, Tier 2 = 282, ..., Tier 9 (Luyện Khí đỉnh phong) = 2700
    TU_VI = {
        BASE_RATE_PER_SEC       = 1.0,  -- baseline gain/sec from a source, multiplied by linh căn
        TIER_THRESHOLD_BASE     = 100,
        TIER_THRESHOLD_EXPONENT = 1.5,
        MAX_TIER_MVP            = 9,    -- Luyện Khí 9 tầng (Plan 2 ceiling)
    },

    -- Stat bonus applied per tier (linear deltas)
    STATS_PER_TIER = {
        HP_BONUS          = 10,    -- +10 max HP per tier
        HUNGER_MULT_DELTA = -0.05, -- hunger drain mult: 1.0 - 0.05*tier
        ATTACK_MULT_DELTA = 0.05,  -- attack mult: 1.0 + 0.05*tier
        SPEED_MULT_DELTA  = 0.01,  -- move speed mult: 1.0 + 0.01*tier
    },

    -- Lifespan (Plan 3 will use, declared here for reference)
    LIFESPAN = {
        BASE             = 60,  -- in DST days
        BONUS_PER_TIER   = 5,   -- +5 days per Luyện Khí tier breakthrough
        DECAY_PER_DAY    = 1,
    },
}

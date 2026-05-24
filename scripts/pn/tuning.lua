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

    -- Linh mạch sources — 3 tiers, scatter on worldgen
    LINH_MACH = {
        HA_PHAM = {
            rate_per_sec = 1.0,
            aura_radius  = 4,
            tint         = { 0.5, 0.85, 1.0 },   -- light blue
        },
        TRUNG_PHAM = {
            rate_per_sec = 2.5,
            aura_radius  = 5,
            tint         = { 1.0, 0.85, 0.3 },   -- gold
        },
        THUONG_PHAM = {
            rate_per_sec = 5.0,
            aura_radius  = 6,
            tint         = { 1.0, 0.4, 0.7 },    -- pinkish red
        },
        SCAN_INTERVAL = 1.0,                      -- seconds between aura ticks
    },

    -- Tu vi source burst values (for items in later plans, defined here for reference)
    TUVI_SOURCES = {
        SIT_MEDITATE_BONUS  = 1.5,                -- multiplier when sitting on linh mạch
        AMBIENT_PER_MIN     = 3,                  -- Plan 6 — ambient passive gain
    },

    -- Worldgen scatter
    WORLDGEN = {
        LINH_MACH_COUNT     = { HA = 20, TRUNG = 6, THUONG = 2 },
        LINH_MACH_MIN_DIST  = { HA = 0,  TRUNG = 300, THUONG = 600 },
        SCATTER_ATTEMPTS    = 30,                 -- placement tries before giving up per entity
    },

    -- Mob cultivation — mobs in linh mạch aura also accumulate cultivation time
    MOB_CULTIVATION = {
        -- Seconds of aura time required for each tier upgrade
        TIER_THRESHOLDS  = { 300, 900 },  -- 5 min → Tier 1, 15 min → Tier 2

        -- Stat multipliers applied at each tier (cumulative from base)
        TIER_STATS = {
            -- Tier 1 — Linh thú
            { hp_mult = 1.5,  dmg_mult = 1.25, scale = 1.2 },
            -- Tier 2 — Yêu tu
            { hp_mult = 2.2,  dmg_mult = 1.6,  scale = 1.35 },
        },

        -- Visual tint applied at each tier (AnimState:SetMultColour)
        TIER_TINT = {
            { 0.4, 1.0, 0.4, 1 },   -- Tier 1: green glow
            { 1.0, 0.3, 0.6, 1 },   -- Tier 2: red/purple glow
        },

        -- Tu vi reward when killed by a player (placeholder for nội đan items in Plan 6)
        KILL_REWARD = {
            [0] = 0,    -- Tier 0 mobs give nothing direct (Plan 6 adds 50% drop chance)
            [1] = 120,  -- Tier 1 = trung phẩm equivalent
            [2] = 300,  -- Tier 2 = thượng phẩm equivalent
        },
    },
}

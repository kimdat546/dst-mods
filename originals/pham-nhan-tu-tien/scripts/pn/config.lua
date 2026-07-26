-- All balance constants. Tune here, never in logic files.
return {
    TU_VI = {
        THRESHOLD_BASE = 80,
        THRESHOLD_EXPONENT = 1.6,
    },
    STATS_PER_LAYER = {
        HP_BONUS          = 12,     -- +12 max HP per Luyện Khí layer
        DMG_MULT_DELTA    = 0.06,   -- +6% damage per layer
        SPEED_MULT_DELTA  = 0.008,  -- +0.8% move speed per layer
        HUNGER_MULT_DELTA = -0.02,  -- -2% hunger drain per layer
    },
    -- tu vi granted per monster kill (by prefab). Tunable starting values.
    TUVI_PER_MOB = {
        spider = 8, spider_warrior = 15, spider_hider = 12, spider_spitter = 14, spider_dropper = 12,
        hound = 20, firehound = 28, icehound = 28,
        frog = 10, killerbee = 6, bee = 4, mosquito = 4,
        merm = 18, pigman = 25, pigguard = 40, bunnyman = 12,
        rook = 60, knight = 70, bishop = 80,
        -- bosses
        deerclops = 400, moose = 350, bearger = 400, dragonfly = 600,
    },
    MOB_BUFF = { hp_mult = 1.4, dmg_mult = 1.25 },
    -- which mobs get patched (tu vi grant + buff). Combat-capable only.
    MOBS_TO_PATCH = {
        "spider", "spider_warrior", "spider_hider", "spider_spitter", "spider_dropper",
        "hound", "firehound", "icehound",
        "frog", "killerbee", "bee", "mosquito",
        "merm", "pigman", "pigguard", "bunnyman",
        "rook", "knight", "bishop",
        "deerclops", "moose", "bearger", "dragonfly",
    },

    -- Farming (Plan A)
    LINHDIEN = {
        ACCEL_MULT = 2.0,   -- crops in range grow 2x faster
        RADIUS = 6,         -- tiles-ish world units
        SCAN_PERIOD = 2,    -- seconds between linh điền rescans
    },
    HERB = {
        WILD_SCATTER_COUNT = 24,  -- wild herbs scattered near spawn on world start
        WILD_SCATTER_RADIUS = 60,
        CROP_STAGES = 3,          -- seed -> sprout -> mature
    },
}

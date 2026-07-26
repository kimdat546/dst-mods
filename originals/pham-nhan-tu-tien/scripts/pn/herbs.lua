-- Linh thảo (spirit herb) definitions. Data-driven: add a row to add a herb.
-- build = the anim build baked into anim/pn_<x>.zip (build name == file stem).
-- inv = sprite key (extensionless) in images/inventoryimages/pn_herbs.xml.
local M = {}

M.RARITY = { COMMON = "COMMON", UNCOMMON = "UNCOMMON", RARE = "RARE" }

-- ordered list; each: id (herb item prefab), build (==bank, the fsm anim build),
-- inv image, anim names (verified from the actual build.bin/anim.bin), grow/seed data.
-- prefab names derive as <id>, <id>_plant (wild), <id>_crop (planted), <id>_seed.
-- NOTE: build name is kept as the original fsm_* (no rename needed for non-character
-- prefabs; bank==build==fsm name, verified via hash brute-force).
M.herbs = {
    {
        id = "pn_herb_huangcao", display = "Hoang Thảo", rarity = "COMMON",
        build = "fsm_huang_grass", inv = "pn_herb_huangcao",
        anim = { young = "level_1_idle", mature = "level_2_idle", pick = "level_2_picking" },
        wild_regrow = 4,        -- days between wild regrowth
        crop_grow = 3,          -- in-game days seed->mature (before linh điền accel)
        seed_chance = 0.5,      -- chance a harvest also yields a seed
    },
    {
        id = "pn_herb_caochanzhi", display = "Thảo Triền Chi", rarity = "COMMON",
        build = "fsm_caochanzhi", inv = "pn_herb_caochanzhi",
        anim = { young = "grow", mature = "idle", pick = "picking" },
        wild_regrow = 5, crop_grow = 4, seed_chance = 0.5,
    },
    {
        id = "pn_herb_zhuguo", display = "Chu Quả", rarity = "UNCOMMON",
        build = "fsm_zhuguocong", inv = "pn_herb_zhuguo",
        anim = { young = "grow", mature = "idle", pick = "picking" },
        wild_regrow = 8, crop_grow = 6, seed_chance = 0.33,
    },
    {
        id = "pn_herb_fusang", display = "Phù Tang", rarity = "RARE",
        build = "fsm_fusang", inv = "pn_herb_fusang",
        anim = { young = "idle", mature = "idle", pick = "idle" },
        wild_regrow = 16, crop_grow = 10, seed_chance = 0.2,
    },
}

-- index by id for O(1) lookup
M.by_id = {}
for _, h in ipairs(M.herbs) do M.by_id[h.id] = h end

function M.Get(id) return M.by_id[id] end

return M

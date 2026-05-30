-- Linh thảo (spirit herb) definitions. Data-driven: add a row to add a herb.
-- build = the anim build baked into anim/pn_<x>.zip (build name == file stem).
-- inv = sprite key (extensionless) in images/inventoryimages/pn_herbs.xml.
local M = {}

M.RARITY = { COMMON = "COMMON", UNCOMMON = "UNCOMMON", RARE = "RARE" }

-- ordered list; each: id (herb item prefab), build, inv image, plant/crop/seed
-- prefab names derive as <id>, <id>_plant (wild), <id>_crop (planted), <id>_seed.
M.herbs = {
    {
        id = "pn_herb_huangcao", display = "Hoang Thảo", rarity = "COMMON",
        build = "pn_huangcao", inv = "pn_herb_huangcao",
        wild_regrow = 4,        -- days between wild regrowth
        crop_grow = 3,          -- in-game days seed->mature (before linh điền accel)
        seed_chance = 0.5,      -- chance a harvest also yields a seed
    },
    {
        id = "pn_herb_caochanzhi", display = "Thảo Triền Chi", rarity = "COMMON",
        build = "pn_caochanzhi", inv = "pn_herb_caochanzhi",
        wild_regrow = 5, crop_grow = 4, seed_chance = 0.5,
    },
    {
        id = "pn_herb_zhuguo", display = "Chu Quả", rarity = "UNCOMMON",
        build = "pn_zhuguo", inv = "pn_herb_zhuguo",
        wild_regrow = 8, crop_grow = 6, seed_chance = 0.33,
    },
    {
        id = "pn_herb_fusang", display = "Phù Tang", rarity = "RARE",
        build = "pn_fusang", inv = "pn_herb_fusang",
        wild_regrow = 16, crop_grow = 10, seed_chance = 0.2,
    },
}

-- index by id for O(1) lookup
M.by_id = {}
for _, h in ipairs(M.herbs) do M.by_id[h.id] = h end

function M.Get(id) return M.by_id[id] end

return M

-- Phàm Nhân Tu Tiên — modmain entry
-- Plan 1: register phamnhan character only

GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end,
})

PrefabFiles = {
    "phamnhan",
}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/phamnhan.tex"),
    Asset("ATLAS", "images/saveslot_portraits/phamnhan.xml"),

    Asset("IMAGE", "bigportraits/phamnhan.tex"),
    Asset("ATLAS", "bigportraits/phamnhan.xml"),

    Asset("IMAGE", "images/map_icons/phamnhan.tex"),
    Asset("ATLAS", "images/map_icons/phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_phamnhan.xml"),

    Asset("IMAGE", "images/names_phamnhan.tex"),
    Asset("ATLAS", "images/names_phamnhan.xml"),
}

AddMinimapAtlas("images/map_icons/phamnhan.xml")

-- Register phamnhan as a playable character
AddModCharacter("phamnhan", "MALE")

-- Character select override (load deferred until Phase E / Task 14)
-- modimport("scripts/pn/charselect_override.lua")  -- enabled in Phase E

print("[PN] Phàm Nhân Tu Tiên mod loaded (Plan 1 — Foundation)")

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

-- Register cultivation components.
-- Server components are auto-discovered by name from scripts/components/<name>.lua
-- when `inst:AddComponent("<name>")` is called. We just need to register their replicas.
AddReplicableComponent("pn_linhcan")
AddReplicableComponent("pn_tuvi")
AddReplicableComponent("pn_canhgioi")
AddReplicableComponent("pn_lifespan")
-- pn_breakthrough is server-only — no replica registration needed.

-- Attach HUD widget to player controls bottom-left.
AddClassPostConstruct("widgets/controls", function(self)
    local PnHudMain = require("widgets/pn_hud_main")
    self.pn_hud = self.bottom_root:AddChild(PnHudMain(self.owner))
    self.pn_hud:SetPosition(-400, 90)
end)

-- Character select override (Phase E / Task 14)
modimport("scripts/pn/charselect_override.lua")

-- Register character speech
STRINGS.CHARACTER_TITLES.phamnhan      = "Phàm Nhân"
STRINGS.CHARACTER_NAMES.phamnhan       = "Phàm Nhân"
STRINGS.CHARACTER_DESCRIPTIONS.phamnhan= "Một phàm nhân bình thường, mơ ước con đường tu tiên."
STRINGS.CHARACTER_QUOTES.phamnhan      = "\"Tu đạo chi lộ, nghịch thiên mà hành.\""

-- Debug console commands (always loaded during MVP; gate behind config in later plans)
modimport("scripts/pn/debug.lua")

print("[PN] Phàm Nhân Tu Tiên mod loaded (Plan 1 — Foundation)")

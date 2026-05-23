-- scripts/prefabs/phamnhan.lua
-- Plan 1: minimal player character, no perks, no cultivation yet.
-- Future plans will add pn_linhcan, pn_tuvi, pn_canhgioi, pn_lifespan, etc.

local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    -- Re-use vanilla player skeleton for MVP1. Future plans add anim/phamnhan.zip.
}

local prefabs = {}

local start_inv = {
    -- Phàm nhân spawn không có gì (đúng tinh thần PNTT novel).
}

local function common_postinit(inst)
    -- Add network tag for future mod features
    inst:AddTag("phamnhan")
end

local function master_postinit(inst)
    -- Base stats matching Wilson default (no perks for MVP1)
    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)

    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE

    -- Plan 1: NO mod components added. Plan 2 adds pn_linhcan, etc.
end

return MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)

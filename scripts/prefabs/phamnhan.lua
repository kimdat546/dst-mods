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
    -- Add network tags for mod features
    inst:AddTag("phamnhan")
    inst:AddTag("pn_aura_target")  -- so pn_aura_source picks us up
end

local function master_postinit(inst)
    -- Cultivation components (order per design spec §2.5)
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_lifespan")
    inst:AddComponent("pn_meditation")
    inst:AddComponent("pn_breakthrough")

    -- Roll linh căn on first spawn (idempotent — won't re-roll on reload)
    inst:DoTaskInTime(0, function()
        if inst.components.pn_linhcan and not inst.components.pn_linhcan.rolled then
            inst.components.pn_linhcan:RollNew()
            print(string.format("[PN] %s rolled linh căn: %s [%s]",
                tostring(inst.userid or "?"),
                inst.components.pn_linhcan:GetDisplay(),
                inst.components.pn_linhcan:GetElementDisplay()))
        end
    end)

    -- Base stats: vanilla Wilson defaults, no perks
    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
end

return MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)

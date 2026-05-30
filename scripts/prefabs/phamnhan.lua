local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    Asset("ANIM", "anim/phamnhan.zip"),
    Asset("ANIM", "anim/ghost_phamnhan_build.zip"),
}
local prefabs = {}
local start_inv = {}

local function common_postinit(inst)
    inst:AddTag("phamnhan")
    -- Build name == prefab name == "phamnhan" (baked into anim/phamnhan.zip).
    inst.AnimState:SetBuild("phamnhan")
end

local function master_postinit(inst)
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_breakthrough")

    inst:DoTaskInTime(0, function()
        if inst.components.pn_linhcan and not inst.components.pn_linhcan.rolled then
            inst.components.pn_linhcan:RollNew()
            print(string.format("[PN] %s linh căn: %s [%s]",
                tostring(inst.userid or "?"),
                inst.components.pn_linhcan:GetDisplay(),
                inst.components.pn_linhcan:GetElementDisplay()))
        end
    end)

    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
end

return MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)

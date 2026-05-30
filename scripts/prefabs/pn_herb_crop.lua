-- Planted spirit-herb crops (pn_herb_<x>_crop). Uses the pn_herb_crop component
-- (scripts/components/pn_herb_crop.lua) for the stage timer + accel logic.
local Herbs = require("pn/herbs")

local function MakeCrop(def)
    local assets = { Asset("ANIM", "anim/" .. def.build .. ".zip") }
    local cid = def.id .. "_crop"

    local function onpicked(inst, picker)
        if inst.components.pn_herb_crop then inst.components.pn_herb_crop:OnHarvest(picker) end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, 0.1)

        inst.AnimState:SetBank(def.build)
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation(def.anim.young, false)

        inst:AddTag("pn_herb_crop")
        inst:AddTag("plant")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
        inst.components.pickable.onpickedfn = onpicked
        inst.components.pickable.product = def.id          -- gives the herb item
        inst.components.pickable.canbepicked = false

        inst:AddComponent("pn_herb_crop")
        inst.components.pn_herb_crop:Configure(def)

        return inst
    end
    return Prefab(cid, fn, assets)
end

local prefabs = {}
for _, def in ipairs(Herbs.herbs) do table.insert(prefabs, MakeCrop(def)) end
return unpack(prefabs)

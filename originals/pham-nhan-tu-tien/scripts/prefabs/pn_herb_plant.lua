-- Wild spirit-herb plants (pn_herb_<x>_plant). Pickable that regenerates on its own
-- timer (vanilla pickable:SetUp). Harvest gives the herb + seed chance.
local Herbs = require("pn/herbs")
local TOTAL_DAY = TUNING.TOTAL_DAY_TIME or 480

local function MakeWild(def)
    local assets = { Asset("ANIM", "anim/" .. def.build .. ".zip") }
    local wid = def.id .. "_plant"

    local function onpicked(inst, picker)
        if math.random() < def.seed_chance and picker and picker.components.inventory then
            local seed = SpawnPrefab(def.id .. "_seed")
            if seed then picker.components.inventory:GiveItem(seed) end
        end
        if inst.AnimState then inst.AnimState:PlayAnimation(def.anim.young, false) end
    end

    local function onregen(inst)
        if inst.AnimState then inst.AnimState:PlayAnimation(def.anim.mature, false) end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, 0.1)

        inst.AnimState:SetBank(def.build)
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation(def.anim.mature, false)

        inst:AddTag("pn_herb_wild")
        inst:AddTag("plant")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("pickable")
        inst.components.pickable:SetUp(def.id, def.wild_regrow * TOTAL_DAY)
        inst.components.pickable.onpickedfn = onpicked
        inst.components.pickable.onregenfn = onregen
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
        AddToRegrowthManager(inst)  -- enables off-screen world replenishment
        return inst
    end
    return Prefab(wid, fn, assets)
end

local prefabs = {}
for _, def in ipairs(Herbs.herbs) do table.insert(prefabs, MakeWild(def)) end
return unpack(prefabs)

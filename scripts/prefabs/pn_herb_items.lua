-- Herb inventory items (pn_herb_<x>) and their seeds (pn_herb_<x>_seed).
-- Seeds are deployable on walkable ground → spawn the matching crop.
local Herbs = require("pn/herbs")

local ATLAS = "images/inventoryimages/pn_herbs.xml"

local function MakeHerbItem(def)
    local assets = { Asset("ATLAS", ATLAS), Asset("IMAGE", "images/inventoryimages/pn_herbs.tex") }

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")            -- reuse vanilla seeds bank for a small item idle
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("pn_herb")
        MakeInventoryFloatable(inst, "small", 0.1, 0.75)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = ATLAS
        inst.components.inventoryitem.imagename = def.id  -- sprite key == prefab name
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40
        inst:AddComponent("tradable")
        return inst
    end
    return Prefab(def.id, fn, assets)
end

local function OnDeploySeed(def)
    return function(inst, pt, deployer)
        local crop = SpawnPrefab(def.id .. "_crop")
        if crop then
            crop.Transform:SetPosition(pt.x, 0, pt.z)
            if crop.components.pn_herb_crop then crop.components.pn_herb_crop:OnPlanted() end
            if inst.components.stackable then inst.components.stackable:Get():Remove() else inst:Remove() end
            if deployer and deployer.SoundEmitter then deployer.SoundEmitter:PlaySound("dontstarve/common/plant") end
        end
    end
end

local function CanPlant(inst, pt, mouseover, deployer)
    return TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z) and not TheWorld.Map:IsPointNearHole(pt)
end

local function MakeSeedItem(def)
    local assets = { Asset("ATLAS", ATLAS), Asset("IMAGE", "images/inventoryimages/pn_herbs.tex") }
    local sid = def.id .. "_seed"

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("pn_herb_seed")
        MakeInventoryFloatable(inst, "small", 0.1, 0.7)

        inst._custom_candeploy_fn = CanPlant
        -- Use the always-present grid placer so we don't need a per-seed placer prefab
        -- (avoids per-frame "unknown prefab <id>_seed_placer" log spam + missing ghost).
        inst.overridedeployplacername = "gridplacer"
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = ATLAS
        inst.components.inventoryitem.imagename = def.id  -- share herb icon for v1
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 20

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
        inst.components.deployable.ondeploy = OnDeploySeed(def)
        return inst
    end
    return Prefab(sid, fn, assets)
end

local prefabs = {}
for _, def in ipairs(Herbs.herbs) do
    table.insert(prefabs, MakeHerbItem(def))
    table.insert(prefabs, MakeSeedItem(def))
end
return unpack(prefabs)

-- Herb inventory items (pn_herb_<x>) and their seeds (pn_herb_<x>_seed).
-- Seeds are deployable on walkable ground → spawn the matching crop.
-- Each herb has its OWN inventory atlas images/inventoryimages/<id>.{tex,xml}
-- (one atlas per icon = the proven-working pattern; element name == "<id>.tex").
local Herbs = require("pn/herbs")

local function atlas_of(def) return "images/inventoryimages/" .. def.id .. ".xml" end
local function tex_of(def)   return "images/inventoryimages/" .. def.id .. ".tex" end

local function MakeHerbItem(def)
    local assets = { Asset("ATLAS", atlas_of(def)), Asset("IMAGE", tex_of(def)) }

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
        inst.components.inventoryitem.atlasname = atlas_of(def)
        inst.components.inventoryitem.imagename = def.id  -- sprite key == prefab name (.tex appended)
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

local function CanPlant(inst, pt, mouseover, deployer, rot)
    return (TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z)
        and not TheWorld.Map:IsPointNearHole(pt)) and true or false
end

local function MakeSeedItem(def)
    -- seed shares the herb's icon atlas
    local assets = { Asset("ATLAS", atlas_of(def)), Asset("IMAGE", tex_of(def)) }
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
        inst:AddTag("deployedplant")   -- classifies item as a ground-plantable (vanilla seeds do this)
        MakeInventoryFloatable(inst, "small", 0.1, 0.7)

        inst._custom_candeploy_fn = CanPlant   -- consulted client-side; set BEFORE SetPristine
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = atlas_of(def)
        inst.components.inventoryitem.imagename = def.id  -- share herb icon
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 20

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
        inst.components.deployable:SetUseGridPlacer(true)             -- replicated generic placer
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.DEFAULT)
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

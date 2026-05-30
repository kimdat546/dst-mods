-- Linh Điền (spirit field) structure. Accelerates nearby pn herb crops via the
-- pn_linhdien component. Art reused from 山海秘藏's lotus pond build.
local BUILD = "fsm_lotus_pond"   -- bank==build==fsm_lotus_pond (verified)
local BANK = "fsm_lotus_pond"

local assets = {
    Asset("ANIM", "anim/" .. BUILD .. ".zip"),
    Asset("MINIMAP_IMAGE", "pn_linhdien"),
}
local prefabs = { "collapse_small" }

local function onbuilt(inst)
    if inst.AnimState then inst.AnimState:PlayAnimation("idle", true) end
    if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/common/together/sand_castle/place") end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)
    inst.MiniMapEntity:SetIcon("pn_linhdien.tex")

    inst.AnimState:SetBank(BANK)
    inst.AnimState:SetBuild(BUILD)
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("pn_linhdien")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(function(i, worker)
        i.components.lootdropper:DropLoot()
        SpawnPrefab("collapse_small").Transform:SetPosition(i.Transform:GetWorldPosition())
        i:Remove()
    end)

    inst:AddComponent("pn_linhdien")

    inst:ListenForEvent("onbuilt", onbuilt)  -- fires when crafted/placed, not on every load
    return inst
end

return Prefab("pn_linhdien", fn, assets),
       MakePlacer("pn_linhdien_placer", BANK, BUILD, "idle")

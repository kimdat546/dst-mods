local assets = {
    Asset("ANIM", "anim/hh_suit_build.zip"),
}
local function onhammered(inst, worker)
    inst["components"]["lootdropper"]:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx["Transform"]:SetPosition(inst["Transform"]:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end
local function onbuilt(inst, data)
    --inst["SoundEmitter"]:PlaySound("rifts/forge/place")
end
local function fn()
    local inst = CreateEntity()

    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddMiniMapEntity()
    inst["entity"]:AddSoundEmitter()
    inst["entity"]:AddNetwork()

    MakeObstaclePhysics(inst, 0.4)

    inst["MiniMapEntity"]:SetPriority(5)
    inst["MiniMapEntity"]:SetIcon("hh_suit_build.tex")

    inst["AnimState"]:SetBank("hh_suit_build")
    inst["AnimState"]:SetBuild("hh_suit_build")
    inst["AnimState"]:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("hh_suit_build")

    MakeSnowCoveredPristine(inst)

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    inst["components"]["workable"]:SetWorkLeft(4)
    inst["components"]["workable"]:SetOnFinishCallback(onhammered)
    --inst["components"]["workable"]:SetOnWorkCallback(onhit)

    MakeSnowCovered(inst)

    return inst
end
return Prefab("hh_suit_build", fn, assets),
MakePlacer("hh_suit_build_placer", "hh_suit_build", "hh_suit_build", "idle"),
--孵蛋窝
MakePlacer("hh_egg_nest_placer", "hh_egg_nest", "hh_egg_nest", "idle"),
MakePlacer("hh_egg_exhibition_table_placer", "hh_egg_nest", "hh_egg_nest", "idle")
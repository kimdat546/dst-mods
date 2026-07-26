-- Linh Thạch: vật phẩm ăn được, ăn vào cộng linh khí (xử lý ở modmain qua sự kiện "oneat").
-- Dùng lại art có sẵn của game (nightmarefuel) để không cần asset riêng.

local assets =
{
    Asset("ANIM", "anim/nightmarefuel.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmarefuel")
    inst.AnimState:SetBuild("nightmarefuel")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(0.6, 0.9, 1, 1) -- nhuộm xanh lam cho ra "linh thạch"

    MakeInventoryFloatable(inst)

    inst:AddTag("tu_lingshi")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"
    inst.components.inventoryitem:ChangeImageName("nightmarefuel")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 5
    inst.components.edible.hungervalue = 5
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.GENERIC
    inst.components.edible.degrades_with_spoilage = false

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("tu_lingshi", fn, assets)

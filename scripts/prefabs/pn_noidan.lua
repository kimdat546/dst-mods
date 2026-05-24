-- scripts/prefabs/pn_noidan.lua
-- Nội đan (inner pill) items dropped by cultivated mobs.
-- 3 phẩm: Hạ / Trung / Thượng. Eat → push pn_tuvi_gain on eater.

local TUNING = require("pn/tuning")

local function MakeNoiDan(tier_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        local cfg = TUNING.NOI_DAN[tier_key]
        inst.AnimState:SetBank(cfg.anim_bank)
        inst.AnimState:SetBuild(cfg.anim_build)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("molebait")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = cfg.tex_atlas

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDIUM or 40

        inst:AddComponent("edible")
        inst.components.edible.foodtype  = FOODTYPE.GENERIC
        inst.components.edible.hungervalue = 0
        inst.components.edible.healthvalue = 0
        inst.components.edible.sanityvalue = 0

        inst:ListenForEvent("oneaten", function(_, data)
            if data and data.eater then
                data.eater:PushEvent("pn_tuvi_gain", {
                    amount = cfg.tu_vi_burst,
                    source = "noidan_" .. tier_key:lower(),
                })
            end
        end)

        return inst
    end, {})
end

return
    MakeNoiDan("HA",     "pn_noidan_ha"),
    MakeNoiDan("TRUNG",  "pn_noidan_trung"),
    MakeNoiDan("THUONG", "pn_noidan_thuong")

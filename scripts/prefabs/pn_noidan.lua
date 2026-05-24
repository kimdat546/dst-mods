-- scripts/prefabs/pn_noidan.lua
-- Nội đan (inner pill) items dropped by cultivated mobs.
-- 3 phẩm: Hạ / Trung / Thượng. Eat → push pn_tuvi_gain on eater.
-- Placeholder visual reuses vanilla "gems" anim bank.

local TUNING = require("pn/tuning")

-- Vanilla anim/gems.zip auto-resolved; no mod-local asset declaration needed.
-- All gems share bank/build "gems"; animation determines the colour.
local TIER_ANIM = {
    HA     = "redgem_idle",
    TRUNG  = "bluegem_idle",
    THUONG = "purplegem_idle",
}

-- NOTE: vanilla gem.lua does NOT set inventoryitem.atlasname (relies on DST
-- default). Setting `atlasname = "images/inventoryimages/redgem.xml"` triggers
-- `resolvefilepath` Lua error because that asset lives inside DST's bundled
-- images.zip — not accessible from mod search paths. Removed in 0.1.3.

local function MakeNoiDan(tier_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("gems")
        inst.AnimState:SetBuild("gems")
        inst.AnimState:PlayAnimation(TIER_ANIM[tier_key] or "redgem_idle", true)

        inst:AddTag("molebait")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        -- atlasname intentionally omitted (see comment at top of file).

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDIUM or 40

        inst:AddComponent("edible")
        inst.components.edible.foodtype  = FOODTYPE.GENERIC
        inst.components.edible.hungervalue = 0
        inst.components.edible.healthvalue = 0
        inst.components.edible.sanityvalue = 0

        local cfg = TUNING.NOI_DAN[tier_key]
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

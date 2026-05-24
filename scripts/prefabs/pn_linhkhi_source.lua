-- scripts/prefabs/pn_linhkhi_source.lua
-- Linh mạch huyệt — 3 tier variants (Hạ / Trung / Thượng phẩm).
-- Each emits a tu vi aura per pn_aura_source. Placeholder visual reuses vanilla gem.

local TUNING = require("pn/tuning")

-- ALL gems in DST share bank "gems" and build "gems"; the colour comes from
-- the animation name (verified from reference/dst-scripts/scripts/prefabs/gem.lua).
-- No mod-local assets; reuses vanilla anim/gems.zip auto-resolved by engine.
local assets = {}

local TIER_ANIM = {
    HA_PHAM     = "bluegem_idle",
    TRUNG_PHAM  = "yellowgem_idle",
    THUONG_PHAM = "purplegem_idle",
}

local function MakeLinhKhi(tier_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()

        MakeObstaclePhysics(inst, 0.5)

        inst.MiniMapEntity:SetIcon("globalpos.tex")

        inst.AnimState:SetBank("gems")
        inst.AnimState:SetBuild("gems")
        inst.AnimState:PlayAnimation(TIER_ANIM[tier_key] or "bluegem_idle", true)
        inst.Transform:SetScale(2.5, 2.5, 2.5)

        local tint = TUNING.LINH_MACH[tier_key].tint or { 1, 1, 1 }
        inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], 1)

        inst:AddTag("pn_linhkhi_source")
        inst:AddTag("structure")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = function() return tier_key end

        inst:AddComponent("pn_aura_source")
        inst.components.pn_aura_source:SetTier(tier_key)

        return inst
    end, assets)
end

return
    MakeLinhKhi("HA_PHAM",     "pn_linhkhi_ha"),
    MakeLinhKhi("TRUNG_PHAM",  "pn_linhkhi_trung"),
    MakeLinhKhi("THUONG_PHAM", "pn_linhkhi_thuong")

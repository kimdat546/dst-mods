-- scripts/prefabs/pn_linhkhi_source.lua
-- Linh mạch huyệt — 3 tier variants (Hạ / Trung / Thượng phẩm).
-- Each emits a tu vi aura per pn_aura_source. Visual is a tinted vanilla animation.

local TUNING = require("pn/tuning")

-- No mod-local assets; reuses vanilla firefly_lightsource anim (auto-resolved by engine).
local assets = {}

local function MakeLinhKhi(tier_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()

        MakeObstaclePhysics(inst, 0.5)

        inst.MiniMapEntity:SetIcon("globalpos.tex")  -- vanilla placeholder icon

        inst.AnimState:SetBank("firefly_lightsource")
        inst.AnimState:SetBuild("firefly_lightsource")
        inst.AnimState:PlayAnimation("idle", true)

        local tint = TUNING.LINH_MACH[tier_key].tint or { 1, 1, 1 }
        inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], 1)

        -- Light source for atmospheric glow
        inst.Light:SetIntensity(0.6)
        inst.Light:SetRadius(TUNING.LINH_MACH[tier_key].aura_radius or 4)
        inst.Light:SetFalloff(0.5)
        inst.Light:SetColour(tint[1], tint[2], tint[3])
        inst.Light:Enable(true)

        inst:AddTag("pn_linhkhi_source")
        inst:AddTag("structure")  -- groups with other static structures for save handling

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

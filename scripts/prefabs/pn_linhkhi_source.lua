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
        -- Light removed — was crashing dedicated_server on macOS Rosetta.
        -- Visual atmosphere is nice-to-have; tier is already shown via tint + minimap icon.

        MakeObstaclePhysics(inst, 0.5)

        inst.MiniMapEntity:SetIcon("globalpos.tex")  -- vanilla placeholder icon

        -- Use vanilla "shadow_chunk" or "stalker_atrium" as placeholder visual.
        -- "firefly_lightsource" doesn't exist as a bank in current DST — was causing
        -- hundreds of "Could not find anim bank [FROMNUM]" warnings.
        -- redgem/bluegem/purplegem are reliable vanilla banks that always exist.
        local bank_for_tier = {
            HA_PHAM     = "bluegem",
            TRUNG_PHAM  = "yellowgem",
            THUONG_PHAM = "purplegem",
        }
        local bank = bank_for_tier[tier_key] or "bluegem"
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(bank)
        inst.AnimState:PlayAnimation("idle", true)
        -- Scale up so a gem looks like a meaningful world entity
        inst.Transform:SetScale(2.5, 2.5, 2.5)

        local tint = TUNING.LINH_MACH[tier_key].tint or { 1, 1, 1 }
        inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], 1)

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

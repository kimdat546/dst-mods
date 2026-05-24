-- scripts/prefabs/pn_linhthao.lua
-- Linh thảo (spirit herbs) — foraged from biomes. Eat for tu vi burst + 5-min buff.
-- 3 species: Tâm Tĩnh Hoa / Linh Tiền Thảo / Hồng Liên Tử.
-- Placeholder visual reuses vanilla "gems" anim bank (real bank "petals_lichen" etc.
-- didn't exist; was causing dedicated_server crashes via corrupted AnimState).

local TUNING = require("pn/tuning")

-- Declare vanilla anim explicitly so the gems bank is resident before construct.
-- Map each species to a gem animation for visual distinction.
local assets = {
    Asset("ANIM", "anim/gems.zip"),
}
local SPECIES_ANIM = {
    TAM_TINH_HOA   = "greengem_idle",
    LINH_TIEN_THAO = "yellowgem_idle",
    HONG_LIEN_TU   = "redgem_idle",
}

-- NOTE: vanilla gem.lua does NOT set inventoryitem.atlasname (relies on DST
-- default). Setting `atlasname = "images/inventoryimages/greengem.xml"`
-- triggers `resolvefilepath` Lua error during worldgen — the asset lives in
-- DST's bundled images.zip, not accessible from mod search paths.
-- This was the actual 2026-05-24 caves shard crash. Removed in 0.1.3.

local function ApplyBuff(player, cfg)
    if not player then return end
    local buff = cfg.buff
    local dur  = cfg.buff_duration or 300
    local s    = cfg.buff_strength or 0

    if buff == "sanity_regen" then
        local task = player:DoPeriodicTask(1.0, function()
            if player.components.sanity then
                player.components.sanity:DoDelta(s, true)
            end
        end)
        player:DoTaskInTime(dur, function()
            if task then task:Cancel() end
        end)

    elseif buff == "speed_boost" then
        if player.components.locomotor then
            local key = "pn_linhthao_speed"
            player.components.locomotor:SetExternalSpeedMultiplier(player, key, 1 + s)
            player:DoTaskInTime(dur, function()
                if player.components.locomotor then
                    player.components.locomotor:RemoveExternalSpeedMultiplier(player, key)
                end
            end)
        end

    elseif buff == "fire_resist" then
        if player.components.health then
            local old = player.components.health.fire_damage_scale or 1
            player.components.health.fire_damage_scale = math.max(0, old - s)
            player:DoTaskInTime(dur, function()
                if player.components.health then
                    player.components.health.fire_damage_scale = old
                end
            end)
        end
    end
end

local function MakeLinhThao(species_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("gems")
        inst.AnimState:SetBuild("gems")
        inst.AnimState:PlayAnimation(SPECIES_ANIM[species_key] or "greengem_idle", true)

        inst:AddTag("linh_thao")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        -- atlasname intentionally omitted (see comment at top of file).

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALL or 20

        inst:AddComponent("edible")
        inst.components.edible.foodtype  = FOODTYPE.VEGGIE
        inst.components.edible.hungervalue = 5
        inst.components.edible.healthvalue = 0
        inst.components.edible.sanityvalue = 0

        local cfg = TUNING.LINH_THAO[species_key]
        inst:ListenForEvent("oneaten", function(_, data)
            if data and data.eater then
                data.eater:PushEvent("pn_tuvi_gain", {
                    amount = cfg.tu_vi_burst,
                    source = "linhthao_" .. species_key:lower(),
                })
                ApplyBuff(data.eater, cfg)
            end
        end)

        return inst
    end, assets)
end

return
    MakeLinhThao("TAM_TINH_HOA",   "pn_linhthao_tam_tinh_hoa"),
    MakeLinhThao("LINH_TIEN_THAO", "pn_linhthao_linh_tien_thao"),
    MakeLinhThao("HONG_LIEN_TU",   "pn_linhthao_hong_lien_tu")

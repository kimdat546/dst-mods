-- scripts/prefabs/pn_linhthao.lua
-- Linh thảo (spirit herbs) — foraged from biomes. Eat for tu vi burst + 5-min buff.
-- 3 species: Tâm Tĩnh Hoa (forest), Linh Tiền Thảo (grassland), Hồng Liên Tử (marsh).

local TUNING = require("pn/tuning")

local function ApplyBuff(player, cfg)
    if not player then return end
    local buff = cfg.buff
    local dur  = cfg.buff_duration or 300
    local s    = cfg.buff_strength or 0

    if buff == "sanity_regen" then
        -- Custom periodic sanity restore. Simple inline implementation.
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
            player.components.locomotor:SetExternalMultiplier(player, key, 1 + s)
            player:DoTaskInTime(dur, function()
                if player.components.locomotor then
                    player.components.locomotor:RemoveExternalMultiplier(player, key)
                end
            end)
        end

    elseif buff == "fire_resist" then
        -- Use vanilla health absorption modifier.
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

        local cfg = TUNING.LINH_THAO[species_key]
        inst.AnimState:SetBank(cfg.anim_bank)
        inst.AnimState:SetBuild(cfg.anim_build)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("flower")
        inst:AddTag("linh_thao")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = cfg.tex_atlas

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALL or 20

        inst:AddComponent("edible")
        inst.components.edible.foodtype  = FOODTYPE.VEGGIE
        inst.components.edible.hungervalue = 5
        inst.components.edible.healthvalue = 0
        inst.components.edible.sanityvalue = 0

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
    end, {})
end

return
    MakeLinhThao("TAM_TINH_HOA",   "pn_linhthao_tam_tinh_hoa"),
    MakeLinhThao("LINH_TIEN_THAO", "pn_linhthao_linh_tien_thao"),
    MakeLinhThao("HONG_LIEN_TU",   "pn_linhthao_hong_lien_tu")

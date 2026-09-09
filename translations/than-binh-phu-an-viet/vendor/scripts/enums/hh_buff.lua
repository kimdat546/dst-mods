local HH_UTILS = require("utils/hh_utils")
local _G_BUFF_CONFIG = TUNING["HH_FORMAT_CONFIG"]["BUFF"]
local function handlePoisonNum(player, poison_num)
    if HH_UTILS:HasComponents(player, "hh_player") then
        --毒素免疫
        if player["components"]["hh_player"]:HasSpecialEffect("immunePoison") then
            return 0
        end
        local hh_poisonProtection = player["components"]["hh_player"]:GetEffectValueByKey("poisonProtection")
        if hh_poisonProtection > 0 then
            poison_num = poison_num * (math["max"](0, 1 - hh_poisonProtection / 100))
        end
    end
    return poison_num
end

local function checkMonster(inst)
    return HH_UTILS:HasComponents(inst, "hh_monster") and HH_UTILS:NotIsDead(inst)
end
local com_item_xml = "images/inventoryimages.xml"
local function getItemImageXml(item_id)
    if not GetInventoryItemAtlas then
        return com_item_xml
    end
    local base_xml = GetInventoryItemAtlas(tostring(item_id) .. ".tex")
    if base_xml then
        return base_xml
    end
    return com_item_xml
end
local HH_BUFF = {
    ["add_health"] = {
        ["name"] = "+󰀍",
        ["xml"] = getItemImageXml("halloweenpotion_health_large"),
        ["tex"] = "halloweenpotion_health_large.tex",
        ["str"] = _G_BUFF_CONFIG["add_health"],
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            HH_UTILS:HHKillTask(inst, "hh_add_health_task")
            inst["hh_add_health_task"] = inst:DoPeriodicTask(1, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                inst["components"]["health"]:DoDelta(1)
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "hh_add_health_task")
        end
    },
    ["buff_10s_1_health"] = {
        ["name"] = "+󰀍",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "halloweenpotion_health_large.tex",
        ["str"] = _G_BUFF_CONFIG["buff_10s_1_health"],
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            if inst["buff_10s_1_health_task"] ~= nil then
                return
            end
            inst["buff_10s_1_health_task"] = inst:DoPeriodicTask(1, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                HH_UTILS:SpawnClientStrFx(inst, "治疗")
                inst["components"]["health"]:DoDelta(1)
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "buff_10s_1_health_task")
        end
    },
    ["add_hunger"] = {
        ["name"] = "+󰀎",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "baconeggs.tex",
        ["str"] = _G_BUFF_CONFIG["add_hunger"],
        ["start_fn"] = function(inst)
            if inst["add_hunger_task"] ~= nil then
                return
            end
            if HH_UTILS:HasComponents(inst, "hunger") then
                inst["add_hunger_task"] = inst:DoPeriodicTask(1, function()
                    if HH_UTILS:HasComponents(inst, "hunger") then
                        inst["components"]["hunger"]:DoDelta(1, true)
                    end
                end)
            end
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "add_hunger_task")
        end
    },
    ["add_sanity"] = {
        ["name"] = "+󰀓",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "taffy.tex",
        ["str"] = _G_BUFF_CONFIG["add_sanity"],
        ["start_fn"] = function(inst)
            if inst["add_sanity_task"] ~= nil then
                return
            end
            if HH_UTILS:HasComponents(inst, "sanity") then
                inst["add_sanity_task"] = inst:DoPeriodicTask(1, function()
                    if HH_UTILS:HasComponents(inst, "sanity") then
                        inst["components"]["sanity"]:DoDelta(1, true)
                    end
                end)
            end
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "add_sanity_task")
        end
    },

    ["test_01"] = { ["name"] = "测01", ["str"] = _G_BUFF_CONFIG["test_01"], },
    ["test_02"] = { ["name"] = "测02", ["str"] = _G_BUFF_CONFIG["test_02"], },
    ["test_03"] = { ["name"] = "测03", ["str"] = _G_BUFF_CONFIG["test_03"], },
    ["test_04"] = { ["name"] = "测04", ["str"] = _G_BUFF_CONFIG["test_04"], },
    ["test_05"] = { ["name"] = "测05", ["str"] = _G_BUFF_CONFIG["test_05"], },
    ["test_06"] = { ["name"] = "测06", ["str"] = _G_BUFF_CONFIG["test_06"], },
    ["test_07"] = { ["name"] = "测07", ["str"] = _G_BUFF_CONFIG["test_07"], },
    ["test_08"] = { ["name"] = "测08", ["str"] = _G_BUFF_CONFIG["test_08"], },
    ["test_09"] = { ["name"] = "测09", ["str"] = _G_BUFF_CONFIG["test_09"], },
    ["test_10"] = { ["name"] = "测10", ["str"] = _G_BUFF_CONFIG["test_10"], },

    --负面buff
    ["poison"] = {
        ["name"] = "中毒",
        ["str"] = _G_BUFF_CONFIG["poison"],
        ["xml"] = "images/inventoryimages2.xml",
        ["tex"] = "monstermeat.tex",
        ["check_fn"] = function(player)
            if HH_UTILS:HasComponents(player, "hh_player")
                    and player["components"]["hh_player"]:HasSpecialEffect("immunePoison")
            then
                return true
            end
            return false
        end,
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            if inst["hh_poison_task"] ~= nil then
                return
            end
            inst["hh_poison_task"] = inst:DoPeriodicTask(3, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                local delta_num = 1
                --处理毒抗
                delta_num = handlePoisonNum(inst, delta_num)
                HH_UTILS:SpawnClientStrFx(inst, "中毒")
                inst["components"]["health"]:DoDelta(-delta_num, false, "hh_poison")
                --毒素页面显示(6s显示一次)
                if inst:HasTag("player") and HH_UTILS:HasComponents(inst, "hh_player") then
                    if inst["hh_poison_ui_bool"] == nil then
                        inst["hh_poison_ui_bool"] = false
                    end
                    if inst["hh_poison_ui_bool"] == false then
                        inst["hh_poison_ui_bool"] = true
                    else
                        --print("毒素ui同步")
                        inst["hh_poison_ui_bool"] = false
                        --移除ui展示
                        --HH_UTILS:HHClientRpc(inst, "hh_poison_ui", "")
                    end
                end
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "hh_poison_task")
        end
    },
    ["monster_poison"] = {
        ["name"] = "中毒-怪物",
        ["str"] = _G_BUFF_CONFIG["monster_poison"],
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            if inst["hh_monster_poison_task"] ~= nil then
                return
            end
            inst["hh_monster_poison_task"] = inst:DoPeriodicTask(2, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                if HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["health"]:DoDelta(-5)
                end
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "hh_monster_poison_task")
        end
    },
    ["reduce_speed"] = {
        ["name"] = "减速",
        ["str"] = _G_BUFF_CONFIG["reduce_speed"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "cavein_boulder.tex",
        ["check_fn"] = function(player)
            if not HH_UTILS:HasComponents(player, "hh_player") then
                return false
            end
            if player["components"]["hh_player"]:HasSpecialEffect("immuneReduceSpeed") then
                return true
            end
            if HH_UTILS:CheckSuitEffect(player, "suit_fyyy") then
                return true
            end
            return false
        end,
        ["start_fn"] = function(inst)
            if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:HasComponents(inst, "locomotor") then
                return
            end
            HH_UTILS:SpawnClientStrFx(inst, "减速")
            inst["components"]["locomotor"]:SetExternalSpeedMultiplier(inst, "hh_buff_reduce_speed", 0.6)
        end,
        ["stop_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "locomotor") then
                return
            end
            inst["components"]["locomotor"]:RemoveExternalSpeedMultiplier(inst, "hh_buff_reduce_speed")
        end
    },
    ["player_healthSuppressNum"] = {
        ["name"] = "制裁",
        ["str"] = _G_BUFF_CONFIG["player_healthSuppressNum"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "critter_eyeofterror_builder.tex",
        ["check_fn"] = function(player)
            if not HH_UTILS:HasComponents(player, "hh_player") then
                return false
            end
            if player["components"]["hh_player"]:HasSpecialEffect("immuneSuppressNum") then
                return true
            end
            --朱雀免疫制裁
            if HH_UTILS:CheckSuitEffect(player, "rosefinch") then
                return true
            end
            return false
        end,
        ["start_fn"] = function(inst)
            if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:HasComponents(inst, "hh_player") then
                return
            end
            HH_UTILS:SpawnClientStrFx(inst, "制裁")
            inst["components"]["hh_player"]:AddEffectValueByKey("healthSuppressNum", 1)
        end,
        ["stop_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "hh_player") then
                return
            end
            inst["components"]["hh_player"]:ReduceEffectValueByKey("healthSuppressNum", 1)
        end
    },
    ["monster_healthSuppressNum"] = {
        ["name"] = "制裁",
        ["str"] = _G_BUFF_CONFIG["monster_healthSuppressNum"],
        ["xml"] = "images/inventoryimages1.xml",
        ["tex"] = "critter_eyeofterror_builder.tex",
        ["start_fn"] = function(inst)
            if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:HasComponents(inst, "hh_monster") then
                return
            end
            inst["components"]["hh_monster"]:AddEffectValueByKey("healthSuppressNum", 1)
        end,
        ["stop_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "hh_monster") then
                return
            end
            inst["components"]["hh_monster"]:ReduceEffectValueByKey("healthSuppressNum", 1)
        end
    },
    ["monster_add_target_damage"] = {
        ["name"] = "恐惧",
        ["str"] = _G_BUFF_CONFIG["monster_add_target_damage"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "beard_monster.tex",
        ["start_fn"] = function(inst)
            if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:HasComponents(inst, "combat") then
                return
            end
            if inst["hh_poison_task"] ~= nil then
                return
            end
            inst["monster_add_target_damage_task"] = inst:DoPeriodicTask(1, function()
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "sanity") then
                    inst["components"]["sanity"]:DoDelta(-1)
                end
            end)
        end,
        ["stop_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "combat") then
                return
            end
            HH_UTILS:HHKillTask(inst, "monster_add_target_damage_task")
        end
    },
    --火焰炮塔
    ["turret_fire"] = {
        ["name"] = "烫伤",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "torch.tex",
        ["str"] = _G_BUFF_CONFIG["turret_fire"],
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            if inst["turret_fire_task"] ~= nil then
                return
            end
            inst["turret_fire_task"] = inst:DoPeriodicTask(1, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                inst["components"]["health"]:DoFireDamage(1, nil, true)
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "turret_fire_task")
        end
    },
    --毒素炮塔
    ["turret_poison"] = {
        ["name"] = "流血",
        ["str"] = _G_BUFF_CONFIG["turret_poison"],
        ["xml"] = "images/inventoryimages2.xml",
        ["tex"] = "monstermeat.tex",
        ["start_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "health")
                    or inst["components"]["health"]:IsDead()
            then
                return
            end
            if inst["turret_poison_task"] ~= nil then
                return
            end
            inst["turret_poison_task"] = inst:DoPeriodicTask(0.5, function()
                if not HH_UTILS:HasComponents(inst, "health")
                        or inst["components"]["health"]:IsDead()
                then
                    return
                end
                HH_UTILS:SpawnClientStrFx(inst, "流血")
                inst["components"]["health"]:DoDelta(-1, false, "hh_turret_poison")
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "turret_poison_task")
        end
    },
    ["suit_basalt"] = {
        ["name"] = "玄武之力",
        ["icon_text"] = "酷炫\n图片",
        ["str"] = _G_BUFF_CONFIG["suit_basalt"],
    },
    ["suit_basalt_cd"] = {
        ["name"] = "玄武套装效果",
        ["icon_text"] = "冷却\n中",
        ["str"] = _G_BUFF_CONFIG["suit_basalt"],
        ["stop_fn"] = function(inst)
            HH_UTILS:HandleSuitBuff(inst, "suit_basalt", nil, true)
        end
    },
    ["suit_yhby"] = {
        ["name"] = "圣光庇佑",
        ["icon_text"] = "酷炫\n图片",
        ["str"] = _G_BUFF_CONFIG["suit_yhby"],
    },
    ["suit_yhby_cd"] = {
        ["name"] = "庇佑-范围治疗cd",
        ["icon_text"] = "冷却\n中",
        ["str"] = "套装效果冷却中",
    },
    ["add_cold"] = {
        ["name"] = "易冷",
        ["str"] = _G_BUFF_CONFIG["add_cold"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "heat_rock1.tex",
        ["check_fn"] = function(player)
            if HH_UTILS:HasComponents(player, "hh_player") and player["components"]["hh_player"]:HasSpecialEffect("immuneCold") then
                return true
            end
            return false
        end,
        ["start_fn"] = function(inst)
            if inst["hh_cold_task"] ~= nil then
                return
            end
            inst["hh_cold_task"] = inst:DoPeriodicTask(1, function()
                --免疫冰冻自动解除
                if HH_UTILS:HasComponents(inst, "hh_player") and inst["components"]["hh_player"]:HasSpecialEffect("immuneCold") then
                    inst["components"]["hh_buff"]:RemoveBuff("add_cold")
                end
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "temperature") then
                    inst["components"]["temperature"]:DoDelta(-5)
                end
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "hh_cold_task")
        end
    },
    ["add_hot"] = {
        ["name"] = "易热",
        ["str"] = _G_BUFF_CONFIG["add_hot"],
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "heat_rock5.tex",
        ["check_fn"] = function(player)
            if HH_UTILS:HasComponents(player, "hh_player") and player["components"]["hh_player"]:HasSpecialEffect("immuneHot") then
                return true
            end
            return false
        end,
        ["start_fn"] = function(inst)
            if inst["hh_hot_task"] ~= nil then
                return
            end
            inst["hh_hot_task"] = inst:DoPeriodicTask(1, function()
                --免疫过热自动解除
                if HH_UTILS:HasComponents(inst, "hh_player") and inst["components"]["hh_player"]:HasSpecialEffect("immuneHot") then
                    inst["components"]["hh_buff"]:RemoveBuff("add_hot")
                end
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "temperature") then
                    inst["components"]["temperature"]:DoDelta(5)
                end
            end)
        end,
        ["stop_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "hh_hot_task")
        end
    },
    ["add_armor_consume"] = {
        ["name"] = "脆甲",
        ["str"] = "受到攻击护甲消耗翻倍",
        ["xml"] = "images/inventoryimages.xml",
        ["tex"] = "armorgrass.tex",
        --["icon_text"] = "护甲\n损伤",
        ["start_fn"] = function(inst)
        end,
        ["stop_fn"] = function(inst)
        end
    },
    ------------------------------------------怪物buff--------------------------------------
    ["hh_beetle_pig_speed"] = {
        ["name"] = "移速提升",
        ["str"] = _G_BUFF_CONFIG["hh_beetle_pig_speed"],
        ["start_fn"] = function(inst)
            if not checkMonster(inst) or not HH_UTILS:HasComponents(inst, "locomotor") then
                return
            end
            HH_UTILS:SpawnClientStrFx(inst, "移速强化")
            inst["components"]["locomotor"]:SetExternalSpeedMultiplier(inst, "hh_beetle_pig_speed", 2)
        end,
        ["stop_fn"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "locomotor") then
                return
            end
            inst["components"]["locomotor"]:RemoveExternalSpeedMultiplier(inst, "hh_beetle_pig_speed")
        end
    },
}

return HH_BUFF
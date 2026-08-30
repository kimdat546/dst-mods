local HH_UTILS = require("utils/hh_utils")
local TUNING_EQUIP_EFFECT = TUNING["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"]
local check_combat_str = (string["format"]("(攻击目标攻击力不低于%s时生效)", 0))
----
---通用增加套装属性方法
---
local function addSuitEffect(player, effect_list, handle_type)
    if HH_UTILS:HasComponents(player, "hh_player")
            and HH_UTILS:IsHHType(effect_list, "table")
    then
        for i, v in pairs(effect_list) do
            if HH_UTILS:IsHHType(v, "number") and v > 0 then
                if handle_type then
                    player["components"]["hh_player"]:AddEffectValueByKey(i, v)
                else
                    player["components"]["hh_player"]:ReduceEffectValueByKey(i, v)
                end
            end
        end
    end
end
local function addEquipEffect(player, effect_id, effect_value, handle_type)
    if HH_UTILS:HasComponents(player, "hh_player")
            and HH_UTILS:IsHHType(effect_id, "string")
            and HH_UTILS:IsHHType(effect_value, "number")
            and effect_value > 0
    then
        if handle_type then
            player["components"]["hh_player"]:AddEffectValueByKey(effect_id, effect_value)
        else
            player["components"]["hh_player"]:ReduceEffectValueByKey(effect_id, effect_value)
        end
    end

end
local hh_str_config = {
    ["gem_jd"] = {
        "技艺过人", "豁达大度", "超凡脱俗", "技术超群",
        "登峰造极", "融会贯通", "精湛无比", "睿智超群",
        "技术一流", "博古通今", "才华横溢", "学富五车",
        "技术卓越", "才高八斗", "才华横盛", "才华出众",
        "泰山北斗", "技术娴熟", "才气纵横", "技艺精湛",
        "技术非凡", "睿智过人", "技术精湛", "聪颖绝伦",
        "才华洋溢", "博大精深", "渊博高深", "技术一绝",
        "技巧高超", "才思敏捷", "技术独到", "神龙见首",
        "技压群雄", "技法精湛", "才华横流", "神乎其技",
        "出神入化", "出类拔萃", "一技之长", "技术过硬",
        "才思敏锐", "才气横溢", "技艺高超", "渊博精深",
        "技术高明", "技艺超群", "技术了得", "技艺出众",
        "技术过人", "悟性超群",
    },
    ["eight_pig"] = {
        "帅",
    },
    ["gem_nk"] = {
        "枝江糕手",
    },
}
local function addTextTask(player, task_name, str_index)
    HH_UTILS:HHKillTask(player, task_name)
    if hh_str_config[str_index] then
        local player_str_config = hh_str_config[str_index]
        local max_length = #player_str_config
        player[task_name] = player:DoPeriodicTask(0.3, function()
            if not HH_UTILS:IsHHType(player["hh_str_index"], "number")
                    or not player_str_config[player["hh_str_index"]]
                    or player["hh_str_index"] > max_length
            then
                player["hh_str_index"] = 1
            end
            local str_config = hh_str_config[str_index]
            local random_index = math["random"](1, #hh_str_config[str_index])
            HH_UTILS:SpawnClientStrFx(player, str_config[random_index])
            player["hh_str_index"] = player["hh_str_index"] + 1
        end)
    end
end
----
---校验是否是对应装备栏
---
local function isEquipSlot(inst, equip_type)
    if not HH_UTILS:HasComponents(inst, "equippable")
            or not (inst["components"]["equippable"]["equipslot"] == equip_type)
    then
        return false, "请附魔在套装词条对应物品栏的装备上"
    end
    return true, "满足条件"
end
----
---初始化套装词条
---
local function createSuitEffect(effect_name, client_str, hh_desc, suit_id, slot, is_person, suit_color, stone_id)
    local hh_table = {
        ["name"] = tostring(effect_name),
        ["client_text"] = tostring(client_str),
        ["desc"] = tostring(hh_desc),
        ["only_one"] = true,
        ["is_suit"] = true,
        ["client_color"] = suit_color or { 94 / 255, 38 / 255, 18 / 255, 1 },
        ["suit_str"] = tostring(suit_id),
        ["check_equip_can_add"] = function(inst)
            return isEquipSlot(inst, EQUIPSLOTS[tostring(slot)])
        end,

        ["id"] = stone_id or 9999,
    }
    --权限词条
    if is_person then
        hh_table["person_one"] = true
    end
    return hh_table
end
local function NotIsDead(inst)
    if inst:IsValid() and HH_UTILS:HasComponents(inst, "health")
            and not inst["components"]["health"]:IsDead() then
        return true
    end
    return false
end
local function HasUseComponent(inst, not_check_staff)
    if (HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"])
            or HH_UTILS:HasComponents(inst, "finiteuses")
            or HH_UTILS:HasComponents(inst, "fueled")
            or HH_UTILS:HasComponents(inst, "perishable")
    then
        if not not_check_staff then
            if inst["prefab"] == "greenstaff" or inst["prefab"] == "greenamulet" then
                return false
            end
        end
        return true
    end
    return false
end
local function UpdateMaxHealth(player, value)
    if player:IsValid() and HH_UTILS:HasComponents(player, "health")
            and HH_UTILS:IsHHType(value, "number") then
        local old_percent = player["components"]["health"]:GetPercent()
        local old_max_health = player["components"]["health"]["maxhealth"]
        if value > 0 then
            --缺省值60000
            player["components"]["health"]["maxhealth"] = math["min"](old_max_health + value, 60000)
            player["components"]["health"]:SetPercent(old_percent)
        else
            --缺省值1
            player["components"]["health"]["maxhealth"] = math["max"](old_max_health + value, 1)
            player["components"]["health"]:SetPercent(old_percent)
        end
    end
end
----
---外挂属性
---
local function addMoreBuff(owner)
    if HH_UTILS:HasComponents(owner, "hh_player") then
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
        owner["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneBramble", 1)
        --免疫减伤+制裁
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneReduceSpeed", 1)
        owner["components"]["hh_player"]:AddEffectValueByKey("immuneSuppressNum", 1)
    end
    if HH_UTILS:HasComponents(owner, "hh_buff") then
        owner["components"]["hh_buff"]:RemoveBuff("poison")
    end
end
local function removeMoreBuff(owner)
    if HH_UTILS:HasComponents(owner, "hh_player") then
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneBramble", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneReduceSpeed", 1)
        owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneSuppressNum", 1)
    end
end
local hh_equip_component = "hh_equip"
local function hookEquip(inst)
    --hook装备穿戴函数 使用监听的话 装备处于穿戴状态remove时 不会触发监听
    if not HH_UTILS:HasComponents(inst, "equippable") then
        return
    end
    local oldEquip = inst["components"]["equippable"]["onequipfn"]
    inst["components"]["equippable"]["onequipfn"] = function(equip, owner, ...)
        --只对玩家生效
        if HH_UTILS:HasComponents(equip, hh_equip_component)
                and owner:IsValid() and owner:HasTag("player")
        then
            equip["components"][hh_equip_component]:HandleEquipBuffToPlayer(owner, true)
        end
        if oldEquip then
            oldEquip(equip, owner, ...)
        end
    end
    local oldUnequip = inst["components"]["equippable"]["onunequipfn"]
    inst["components"]["equippable"]["onunequipfn"] = function(equip, owner, ...)
        if HH_UTILS:HasComponents(equip, hh_equip_component)
                and owner:IsValid() and owner:HasTag("player")
        then
            equip["components"][hh_equip_component]:HandleEquipBuffToPlayer(owner, false)
        end
        if oldUnequip then
            oldUnequip(equip, owner, ...)
        end
    end
end
local function repairEquip(inst)
    if HH_UTILS:HasComponents(inst, "forgerepairable") and inst:HasTag("broken") then
        if HH_UTILS:IsHHType(inst["components"]["forgerepairable"]["onrepaired"], "function") then
            --local needHook = false
            --if not HH_UTILS:HasComponents(inst, "equippable") then
            --    needHook = true
            --end
            inst["components"]["forgerepairable"]["onrepaired"](inst)
            --if needHook and HH_UTILS:HasComponents(inst, "equippable") then
            --    hookEquip(inst)
            --end
        end
    end
end
local function AddEquipUse(inst, add_use)
    if not HH_UTILS:IsHHType(add_use, "number") or add_use < 0 then
        return
    end
    if HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"] then
        local armor_percent = inst["components"]["armor"]:GetPercent()
        if armor_percent < 1 then
            local old_condition = inst["components"]["armor"]["condition"]
            inst["components"]["armor"]:SetCondition(old_condition + add_use)
        end
    end
    if HH_UTILS:HasComponents(inst, "finiteuses") then
        local finiteuses_percent = inst["components"]["finiteuses"]:GetPercent()
        if finiteuses_percent < 1 then
            local max_use = inst["components"]["finiteuses"]["total"]
            local old_condition = inst["components"]["finiteuses"]:GetUses()
            inst["components"]["finiteuses"]:SetUses(math["min"](max_use, old_condition + add_use))
        end
    end
    if HH_UTILS:HasComponents(inst, "fueled") then
        local fueled_percent = inst["components"]["fueled"]:GetPercent()
        if fueled_percent < 1 then
            inst["components"]["fueled"]:DoDelta(add_use)
        end
    end
    if HH_UTILS:HasComponents(inst, "perishable") then
        local perishable_percent = inst["components"]["perishable"]:GetPercent()
        if perishable_percent < 1 then
            local current_use = inst["components"]["perishable"]["perishremainingtime"]
            local max_use = inst["components"]["perishable"]["perishtime"]
            if current_use and max_use and max_use > 0 then
                current_use = current_use + add_use
                local new_cent = current_use / max_use
                inst["components"]["perishable"]:SetPercent(new_cent)
            end
        end
    end
    local success, result = pcall(repairEquip, inst)
end
----
---增加百分比耐久
---
local function AddPercentEquipUse(inst, add_percent)
    if not HH_UTILS:IsHHType(add_percent, "number") or add_percent < 0 then
        return
    end
    if HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"] then
        local armor_percent = inst["components"]["armor"]:GetPercent()
        if armor_percent < 1 then
            local new_percent = math["min"](armor_percent + add_percent, 1)
            inst["components"]["armor"]:SetPercent(new_percent)
        end
    end
    if HH_UTILS:HasComponents(inst, "finiteuses") then
        local finiteuses_percent = inst["components"]["finiteuses"]:GetPercent()
        if finiteuses_percent < 1 then
            local new_percent = math["min"](finiteuses_percent + add_percent, 1)
            inst["components"]["finiteuses"]:SetPercent(new_percent)
        end
    end
    if HH_UTILS:HasComponents(inst, "fueled") then
        local fueled_percent = inst["components"]["fueled"]:GetPercent()
        if fueled_percent < 1 then
            local new_percent = math["min"](fueled_percent + add_percent, 1)
            inst["components"]["fueled"]:SetPercent(new_percent)
        end
    end
    if HH_UTILS:HasComponents(inst, "perishable") then
        local perishable_percent = inst["components"]["perishable"]:GetPercent()
        if perishable_percent < 1 then
            local new_percent = math["min"](perishable_percent + add_percent, 1)
            inst["components"]["perishable"]:SetPercent(new_percent)
        end
    end
    local success, result = pcall(repairEquip, inst)
end
----
---增加耐久最大值
---
local function AddMaxUse(inst, add_num, hh_type)
    if not HH_UTILS:IsHHType(add_num, "number") then
        return
    end

    --todo 游戏加载时会加载保存的当前耐久 需要进行处理 否则重新加载数值错乱
    if HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"] then
        local armor_percent = inst["components"]["armor"]:GetPercent()
        local armor_max = inst["components"]["armor"]["maxcondition"]
        inst["components"]["armor"]["maxcondition"] = math["max"](armor_max + add_num)
        inst["components"]["armor"]:SetPercent(armor_percent)
    end
    if HH_UTILS:HasComponents(inst, "finiteuses") then
        local finiteuses_percent = inst["components"]["finiteuses"]:GetPercent()
        local finiteusesr_max = inst["components"]["finiteuses"]["total"]
        inst["components"]["finiteuses"]["total"] = math["max"](finiteusesr_max + add_num, 1)
        inst["components"]["finiteuses"]:SetPercent(finiteuses_percent)
    end
    if HH_UTILS:HasComponents(inst, "fueled") then
        local fueled_percent = inst["components"]["fueled"]:GetPercent()
        local fueled_max = inst["components"]["fueled"]["maxfuel"]
        inst["components"]["fueled"]["maxfuel"] = math["max"](fueled_max + add_num, 1)
        inst["components"]["fueled"]:SetPercent(fueled_percent)
    end
    if HH_UTILS:HasComponents(inst, "perishable") then
        local perishable_percent = inst["components"]["perishable"]:GetPercent()
        local perishable_max = inst["components"]["perishable"]["perishtime"]
        if perishable_max and perishable_max > 0 then
            inst["components"]["perishable"]["perishtime"] = math["max"](perishable_max + add_num, 1)
            inst["components"]["perishable"]:SetPercent(perishable_percent)
        end
    end
end

local function addBiuFn(player, target, biu_num)
    local hh_target = target
    local hh_attacker = player
    if not (HH_UTILS:NotIsDead(hh_target) and HH_UTILS:NotIsDead(hh_attacker)) then
        return
    end
    --找武器
    if not HH_UTILS:HasComponents(player, "inventory") then
        return
    end
    local staff = player["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
    if not HH_UTILS:HasComponents(staff, "weapon") then
        return
    end
    for i = -1, 1, 2 do

        local x, y, z = hh_attacker["Transform"]:GetWorldPosition()
        local hh_pos = hh_attacker:GetPosition()
        local hh_target_pos = hh_target:GetPosition()
        local run_angle = hh_attacker["Transform"]:GetRotation()
        local target_angle = hh_attacker["Transform"]:GetRotation()
        local hh_distance = hh_pos:Dist(hh_target_pos)
        if run_angle < 0 then
            run_angle = run_angle + 360
        end
        if target_angle < 0 then
            target_angle = target_angle + 360
        end
        local proj = SpawnPrefab("hh_bow_project")
        if proj and HH_UTILS:HasComponents(proj, "projectile") then
            proj["Transform"]:SetPosition(x, y, z)
            local add_ange = 140 * i
            local add_ange2 = 75 * i
            local offset_num = math["min"](10, hh_distance)
            offset_num = 30
            local offset_num2 = math["min"](10, hh_distance) * 1.5
            local offset_vector = Vector3(offset_num * math["cos"](-(run_angle + add_ange) * DEGREES), 0, offset_num * math["sin"](-(run_angle + add_ange) * DEGREES))
            local offset_vector_2 = Vector3(offset_num2 * math["cos"](-(run_angle + add_ange2) * DEGREES), 0, offset_num2 * math["sin"](-(run_angle + add_ange2) * DEGREES))
            proj["components"]["projectile"]:SetBezier3(hh_pos + offset_vector, hh_pos + offset_vector_2)
            proj["components"]["projectile"]:SetBezierCalcDist(hh_distance)
            proj["components"]["projectile"]:Throw(staff, hh_target, hh_attacker)
            proj["components"]["projectile"]:SetSpeed(8)
            proj:SpawnChild("hh_ball_fx_purple")
            proj:SpawnChild("hh_sparkle_fx")
        end
    end
end
----
---多发弹道函数
---
local function moreBiuFunc(player, target, biu_num)
    HH_UTILS:AddCdTask(player, "hh_biu_cd", 3,
            nil,
            addBiuFn, player, target, biu_num)
end
--弹道取数 最多八发
local function biuEvent(player, data)
    if not data or not data["target"] then
        return
    end
    local hh_num = player["hh_biu_num"]
    if not HH_UTILS:IsHHType(hh_num, "number") or hh_num <= 0 then
        return
    end
    moreBiuFunc(player, data["target"], math["min"](hh_num, 8))
end
----
---name词条名字
---desc描述
---can_add可以通过随机附魔出来
---only_one唯一性 一个装备是否可以镶嵌多个相同的词条
---star_rating星级 用于酷炫显示(不加默认为1)
---min_star_num星级下限 可不填 高级词条必带
---check_equip_can_add满足词条的前置条件 满足才会拥有当前词条 不加默认通过
---start_fn针对武器自身的buff效果
---end_fn针对武器自身的buff效果
---on_equip_fn针对玩家的buff效果 参数inst, player, value--词条附带的随机属性值
---un_equip_fn针对玩家的buff效果
---value_range属性范围 强化的词条属性会随机 用不到可不填
---
local HH_EQUIP_BUFF_LIST = {
    ["restore_use_10s_1use"] = {
        ["id"] = 1,
        ["name"] = TUNING_EQUIP_EFFECT["restore_use_10s_1use_name"], ["desc"] = TUNING_EQUIP_EFFECT["restore_use_10s_1use"],
        ["can_add"] = true, ["only_one"] = true, ["star_rating"] = 3,
        ["xml"] = "images/inventoryimages2.xml", ["tex"] = "sewing_kit.tex",
        ["client_text"] = string["format"]("%s\n回耐", 10),
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_10s_1use_task")
            inst["restore_use_10s_1use_task"] = inst:DoPeriodicTask(10, function()
                AddEquipUse(inst, 1)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_10s_1use_task")
        end,
    },
    ["restore_use_5s_1use"] = {
        ["id"] = 2,
        ["name"] = TUNING_EQUIP_EFFECT["restore_use_5s_1use_name"], ["desc"] = TUNING_EQUIP_EFFECT["restore_use_5s_1use"],
        ["can_add"] = true, ["only_one"] = true, ["star_rating"] = 5,
        ["client_text"] = string["format"]("%s\n回耐", 5),
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_5s_1use_task")
            inst["restore_use_5s_1use_task"] = inst:DoPeriodicTask(5, function()
                AddEquipUse(inst, 1)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_5s_1use_task")
        end,
    },
    ["restore_use_3s_1use"] = {
        ["id"] = 3,
        ["name"] = TUNING_EQUIP_EFFECT["restore_use_3s_1use_name"], ["desc"] = TUNING_EQUIP_EFFECT["restore_use_3s_1use"],
        ["can_add"] = true, ["only_one"] = true, ["star_rating"] = 8,
        ["client_text"] = string["format"]("%s\n回耐", 3),
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_3s_1use_task")
            inst["restore_use_3s_1use_task"] = inst:DoPeriodicTask(3, function()
                AddEquipUse(inst, 1)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_3s_1use_task")
        end,
    },
    ["restore_use_1s_2_percent"] = {
        ["id"] = 4,
        ["name"] = TUNING_EQUIP_EFFECT["restore_use_1s_2_percent_name"],
        ["desc"] = TUNING_EQUIP_EFFECT["restore_use_1s_2_percent"],
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["client_text"] = "极\n回耐",
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_1s_2_percent_task")
            inst["restore_use_1s_2_percent_task"] = inst:DoPeriodicTask(1, function()
                AddPercentEquipUse(inst, 0.02)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_1s_2_percent_task")
        end,
    },
    ["add_max_use"] = {
        ["id"] = 5,
        ["name"] = "耐用-通用", ["desc"] = TUNING_EQUIP_EFFECT["add_max_use"],
        ["can_add"] = true, ["only_one"] = true,
        ["client_text"] = "通\n耐久",
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 20, ["max"] = 100 },
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst, true) and HH_UTILS:HasComponents(inst, "hh_equip") then
                if inst["components"]["hh_equip"]:HasEffectByName("add_max_use_percent") then
                    return false, "增加耐久的词条只允许存在一种!!!"
                end
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["start_fn"] = function(inst, value)
            AddMaxUse(inst, value)
        end,
        ["end_fn"] = function(inst, value)
            AddMaxUse(inst, -value)
        end,
    },
    ["add_max_use_armor_01"] = {
        ["id"] = 6,
        ["name"] = "耐用-护甲(小)", ["desc"] = TUNING_EQUIP_EFFECT["add_max_use_armor_01"],
        ["can_add"] = true, ["only_one"] = false,
        ["client_text"] = "小\n护甲",
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 200, ["max"] = 500 },
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) and HH_UTILS:HasComponents(inst, "hh_equip") then
                if inst["components"]["hh_equip"]:HasEffectByName("add_max_use") then
                    return false, "增加耐久的词条只允许存在一种!!!"
                end
                if HH_UTILS:HasComponents(inst, "armor") then
                    return true, "满足条件"
                end
                return false, "只有护甲才允许附魔该词条!!!"
            end
            return false, "装备含有护甲才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲",
        ["start_fn"] = function(inst, value)
            AddMaxUse(inst, value)
        end,
        ["end_fn"] = function(inst, value)
            AddMaxUse(inst, -value)
        end,
    },
    ["add_max_use_armor_02"] = {
        ["id"] = 7,
        ["name"] = "耐用-护甲(中)", ["desc"] = TUNING_EQUIP_EFFECT["add_max_use_armor_02"],
        ["can_add"] = true, ["only_one"] = false,
        ["client_text"] = "中\n护甲",
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 500, ["max"] = 1000 },
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) and HH_UTILS:HasComponents(inst, "hh_equip") then
                if inst["components"]["hh_equip"]:HasEffectByName("add_max_use") then
                    return false, "增加耐久的词条只允许存在一种!!!"
                end
                if HH_UTILS:HasComponents(inst, "armor") then
                    return true, "满足条件"
                end
                return false, "只有护甲才允许附魔该词条!!!"
            end
            return false, "装备含有护甲才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲",
        ["start_fn"] = function(inst, value)
            AddMaxUse(inst, value)
        end,
        ["end_fn"] = function(inst, value)
            AddMaxUse(inst, -value)
        end,
    },
    ["add_max_use_armor_03"] = {
        ["id"] = 8,
        ["name"] = "耐用-护甲(大)", ["desc"] = TUNING_EQUIP_EFFECT["add_max_use_armor_03"],
        ["can_add"] = false, ["only_one"] = false,
        ["client_text"] = "大\n护甲",
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 1500, ["max"] = 3000 },
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) and HH_UTILS:HasComponents(inst, "hh_equip") then
                if inst["components"]["hh_equip"]:HasEffectByName("add_max_use") then
                    return false, "增加耐久的词条只允许存在一种!!!"
                end
                if HH_UTILS:HasComponents(inst, "armor") then
                    return true, "满足条件"
                end
                return false, "只有护甲才允许附魔该词条!!!"
            end
            return false, "装备含有护甲才可以使用该词条!!!"
        end,
        ["check_desc"] = "护甲",
        ["start_fn"] = function(inst, value)
            AddMaxUse(inst, value)
        end,
        ["end_fn"] = function(inst, value)
            AddMaxUse(inst, -value)
        end,
    },
    ["reduce_com_attacked_damage"] = {
        ["id"] = 9,
        ["name"] = "固定减伤",
        ["desc"] = TUNING_EQUIP_EFFECT["reduce_com_attacked_damage"],
        ["can_add"] = true,
        ["client_text"] = "普\n减伤",
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 5, ["max"] = 15 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return false, "武器无法附加该词条"
            end
            return true, "满足条件"
        end,
        ["check_desc"] = "非武器",
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("reduceAttackedDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("reduceAttackedDamage", value)
        end,
    },
    ["add_com_damage"] = {
        ["id"] = 10,
        ["name"] = "额外伤害",
        ["client_text"] = "普\n增伤",
        ["desc"] = TUNING_EQUIP_EFFECT["add_com_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 5, ["max"] = 20 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addComDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamage", value)
        end,
    },
    ["add_night_damage"] = {
        ["id"] = 11,
        ["name"] = "夜晚增伤",
        ["client_text"] = "夜\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_night_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 20, ["max"] = 60 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("nightMenace", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("nightMenace", value)
        end,
    },
    ["add_day_damage"] = {
        ["id"] = 12,
        ["name"] = "白天增伤",
        ["client_text"] = "白\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_day_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 20, ["max"] = 60 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("sunlightStrike", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("sunlightStrike", value)
        end,
    },
    ["add_dusk_damage"] = {
        ["id"] = 13,
        ["name"] = "黄昏增伤",
        ["client_text"] = "昏\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_dusk_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 20, ["max"] = 60 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("afterglowStrike", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("afterglowStrike", value)
        end,
    },
    ["add_moisture_damage"] = {
        ["id"] = 14,
        ["name"] = "潮湿增伤",
        ["client_text"] = "湿\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_moisture_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 20, ["max"] = 60 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("soakStrike", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("soakStrike", value)
        end,
    },
    ["blood_outburst"] = {
        ["id"] = 15,
        ["name"] = "血量增伤",
        ["client_text"] = "血\n加成",
        ["desc"] = TUNING_EQUIP_EFFECT["blood_outburst"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 4,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("bloodOutburst", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("bloodOutburst", 1)
        end,
    },
    ["spirit_fade"] = {
        ["id"] = 16,
        ["name"] = "精神增伤",
        ["client_text"] = "脑\n加成",
        ["desc"] = TUNING_EQUIP_EFFECT["spirit_fade"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 4,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("spiritFade", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("spiritFade", 1)
        end,
    },
    ["hunger_assault"] = {
        ["id"] = 17,
        ["name"] = "饥饿增伤",
        ["client_text"] = "饿\n加成",
        ["desc"] = TUNING_EQUIP_EFFECT["hunger_assault"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 4,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("hungerAssault", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("hungerAssault", 1)
        end,
    },
    ["reflexive_injury"] = {
        ["id"] = 18,
        ["name"] = "反伤",
        ["client_text"] = "普\n反伤",
        ["desc"] = TUNING_EQUIP_EFFECT["reflexive_injury"],
        ["check_desc"] = "非武器",
        ["can_add"] = true,
        ["star_rating"] = 3,
        ["value_range"] = { ["min"] = 5, ["max"] = 15 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return false, "武器无法附加改词条"
            end
            return true, "满足条件"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("reflexiveInjury", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("reflexiveInjury", value)
        end,
    },
    ["add_hit_damage_pig"] = {
        ["id"] = 19,
        ["name"] = "猪人杀手",
        ["client_text"] = "猪\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_pig"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 10, ["max"] = 30 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitPigDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitPigDamage", value)
        end,
    },
    ["add_hit_damage_fish"] = {
        ["id"] = 20,
        ["name"] = "鱼人杀手",
        ["client_text"] = "鱼\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_fish"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 10, ["max"] = 30 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitFishDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitFishDamage", value)
        end,
    },
    ["add_hit_damage_monkey"] = {
        ["id"] = 21,
        ["name"] = "猴子杀手",
        ["client_text"] = "猴\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_monkey"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 50, ["max"] = 100 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitMonkeyDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitMonkeyDamage", value)
        end,
    },
    ["add_hit_damage_gear"] = {
        ["id"] = 22,
        ["name"] = "齿轮杀手",
        ["client_text"] = "齿\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_gear"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitGearDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitGearDamage", value)
        end,
    },
    ["add_hit_damage_spider"] = {
        ["id"] = 23,
        ["name"] = "蜘蛛杀手",
        ["client_text"] = "蜘\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_spider"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitSpiderDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitSpiderDamage", value)
        end,
    },
    ["add_hit_damage_dog"] = {
        ["id"] = 24,
        ["name"] = "犬类杀手",
        ["client_text"] = "犬\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_dog"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitDogDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitDogDamage", value)
        end,
    },
    ["add_hit_damage_frog"] = {
        ["id"] = 25,
        ["name"] = "蛙类杀手",
        ["client_text"] = "蛙\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_frog"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitFrogDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitFrogDamage", value)
        end,
    },
    ["add_hit_damage_insect"] = {
        ["id"] = 26,
        ["name"] = "昆虫杀手",
        ["client_text"] = "虫\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_insect"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitInsectDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitInsectDamage", value)
        end,
    },
    ["add_hit_damage_shadow"] = {
        ["id"] = 27,
        ["name"] = "暗影杀手",
        ["client_text"] = "影\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_shadow"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitShadowDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitShadowDamage", value)
        end,
    },
    ["add_hit_damage_boss"] = {
        ["id"] = 28,
        ["name"] = "巨人杀手",
        ["client_text"] = "巨\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_boss"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitBossDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitBossDamage", value)
        end,
    },
    ["add_hit_damage_plant"] = {
        ["id"] = 29,
        ["name"] = "植物杀手",
        ["client_text"] = "植\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["add_hit_damage_plant"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addHitPlantDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitPlantDamage", value)
        end,
    },
    ["add_extra_damage_percent"] = {
        ["id"] = 30,
        ["name"] = "伤害加成",
        ["client_text"] = "普\n加成",
        ["desc"] = TUNING_EQUIP_EFFECT["add_extra_damage_percent"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["value_range"] = { ["min"] = 5, ["max"] = 15 },
        ["star_rating"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", value)
        end,
    },
    ["add_critical_hit_rate"] = {
        ["id"] = 31,
        ["name"] = "暴击率",
        ["client_text"] = "普\n暴击",
        ["desc"] = TUNING_EQUIP_EFFECT["add_critical_hit_rate"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["value_range"] = { ["min"] = 5, ["max"] = 10 },
        ["star_rating"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", value)
        end,
    },
    ["add_critical_hit_effect"] = {
        ["id"] = 32,
        ["name"] = "暴击效果",
        ["client_text"] = "普\n暴伤",
        ["desc"] = TUNING_EQUIP_EFFECT["add_critical_hit_effect"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["value_range"] = { ["min"] = 10, ["max"] = 50 },
        ["star_rating"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", value)
        end,
    },
    --["reduce_fire_damage"] = {
    --    ["name"] = "火抗",
    --["id"] = 33,
    --    ["client_text"] = "普\n火抗",
    --    ["desc"] = TUNING_EQUIP_EFFECT["reduce_fire_damage"],
    --    ["can_add"] = true,
    --    ["star_rating"] = 3,
    --    ["value_range"] = { ["min"] = 5, ["max"] = 15 },
    --    ["on_equip_fn"] = function(inst, owner, value)
    --        if not HH_UTILS:HasComponents(owner, "hh_player") then
    --            return
    --        end
    --        owner["components"]["hh_player"]:AddEffectValueByKey("fireProtection", value)
    --    end,
    --    ["un_equip_fn"] = function(inst, owner, value)
    --        if not HH_UTILS:HasComponents(owner, "hh_player") then
    --            return
    --        end
    --        owner["components"]["hh_player"]:ReduceEffectValueByKey("fireProtection", value)
    --    end,
    --},
    ["atk_blood_01"] = {
        ["id"] = 34,
        ["name"] = "小幅吸血",
        ["client_text"] = "小\n吸血",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_blood_01"],
        ["check_desc"] = "无" .. check_combat_str,
        ["can_add"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 1, ["max"] = 3 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("bloodSuck", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("bloodSuck", value)
        end,
    },
    ["atk_blood_suck_02"] = {
        ["id"] = 35,
        ["name"] = "大幅吸血",
        ["client_text"] = "大\n吸血",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_blood_suck_02"],
        ["check_desc"] = "无" .. check_combat_str,
        ["can_add"] = true,
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 2, ["max"] = 5 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("bloodSuck", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("bloodSuck", value)
        end,
    },
    ["atk_blood_suck_03"] = {
        ["id"] = 36,
        ["name"] = "极品吸血",
        ["client_text"] = "极\n吸血",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_blood_suck_03"],
        ["check_desc"] = "无" .. check_combat_str,
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 5, ["max"] = 10 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("bloodSuck", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("bloodSuck", value)
        end,
    },
    ["atk_add_good_damage"] = {
        ["id"] = 37,
        ["name"] = "极品增伤",
        ["client_text"] = "极\n增伤",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_add_good_damage"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addComDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamage", value)
        end,
    },
    ["reduce_good_damage"] = {
        ["id"] = 38,
        ["name"] = "极品减伤",
        ["client_text"] = "极\n减伤",
        ["desc"] = TUNING_EQUIP_EFFECT["reduce_good_damage"],
        ["can_add"] = false,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 15, ["max"] = 25 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return false, "武器无法附加改词条"
            end
            return true, "满足条件"
        end,
        ["check_desc"] = "非武器",
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("reduceAttackedDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("reduceAttackedDamage", value)
        end,
    },
    ["atk_add_san"] = {
        ["id"] = 39,
        ["name"] = "吸收精神",
        ["client_text"] = "脑\n回神",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_add_san"],
        ["check_desc"] = "无" .. check_combat_str,
        ["can_add"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 2, ["max"] = 5 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("restoreSpirit", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("restoreSpirit", value)
        end,
    },
    ["add_speed_percent"] = {
        ["id"] = 40,
        ["name"] = "急速",
        ["client_text"] = "速\n急速",
        ["desc"] = TUNING_EQUIP_EFFECT["add_speed_percent"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["value_range"] = { ["min"] = 1, ["max"] = 20 },
        ["star_rating"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", value)
        end,
    },
    ["add_max_health_01"] = {
        ["id"] = 41,
        ["name"] = "初级生命",
        ["client_text"] = "初\n生命",
        ["desc"] = TUNING_EQUIP_EFFECT["add_max_health_01"],
        ["check_desc"] = "无",
        ["can_add"] = false,
        ["is_special"] = true, --特殊附魔石 特殊途径获取
        ["client_color"] = { 142 / 255, 91 / 255, 0 / 255, 1 }, --指定颜色
        ["ui_from_desc"] = "获取途径未开放",
        ["star_rating"] = 4,
        ["value_range"] = { ["min"] = 1, ["max"] = 10 },
        ["on_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, -value)
        end,
    },
    ["add_max_health_02"] = {
        ["id"] = 42,
        ["name"] = "中级生命",
        ["client_text"] = "中\n生命",
        ["desc"] = TUNING_EQUIP_EFFECT["add_max_health_02"],
        ["check_desc"] = "无",
        ["can_add"] = false,
        ["is_special"] = true, --特殊附魔石 特殊途径获取
        ["client_color"] = { 142 / 255, 91 / 255, 0 / 255, 1 }, --指定颜色
        ["ui_from_desc"] = "获取途径未开放",
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 5, ["max"] = 30 },
        ["on_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, -value)
        end,
    },
    ["add_max_health_03"] = {
        ["id"] = 43,
        ["name"] = "高级生命",
        ["client_text"] = "高\n生命",
        ["desc"] = TUNING_EQUIP_EFFECT["add_max_health_03"],
        ["check_desc"] = "无",
        ["can_add"] = false,
        ["is_special"] = true, --特殊附魔石 特殊途径获取
        ["client_color"] = { 142 / 255, 91 / 255, 0 / 255, 1 }, --指定颜色
        ["ui_from_desc"] = "获取途径未开放",
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 20, ["max"] = 50 },
        ["on_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, -value)
        end,
    },
    ["add_max_health_04"] = {
        ["id"] = 44,
        ["name"] = "极品生命",
        ["client_text"] = "极\n生命",
        ["desc"] = TUNING_EQUIP_EFFECT["add_max_health_04"],
        ["check_desc"] = "无",
        ["can_add"] = false,
        ["is_special"] = true, --特殊附魔石 特殊途径获取
        ["client_color"] = { 142 / 255, 91 / 255, 0 / 255, 1 }, --指定颜色
        ["ui_from_desc"] = "获取途径未开放",
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 50, ["max"] = 100 },
        ["on_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            UpdateMaxHealth(owner, -value)
        end,
    },
    --增益buff
    ["atk_10s_health"] = {
        ["id"] = 45,
        ["name"] = "触发治疗",
        ["client_text"] = "疗\n治疗",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_10s_health"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 3,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("attackToAddHealth", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("attackToAddHealth", 1)
        end,
    },
    ["add_critical_hit_rate_damage"] = {
        ["id"] = 46,
        ["name"] = "无尽",
        ["client_text"] = "极\n无尽",
        ["desc"] = TUNING_EQUIP_EFFECT["add_critical_hit_rate_damage"],
        ["check_desc"] = "武器",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 30, ["max"] = 50 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") and isEquipSlot(inst, EQUIPSLOTS["HANDS"]) then
                return true, "满足条件"
            end
            return false, "武器+手部装备才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", value)
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", 100)

            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", value)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", 100)
            end
        end,
    },
    --["add_poisonProtection"] = {
    --    ["name"] = "毒抗",
    --    ["client_text"] = "抗\n毒抗",
    --    ["desc"] = TUNING_EQUIP_EFFECT["add_poisonProtection"],
    --    ["can_add"] = true,
    --    ["value_range"] = { ["min"] = 10, ["max"] = 30 },
    --    ["star_rating"] = 3,
    --    ["on_equip_fn"] = function(inst, owner, value)
    --        if HH_UTILS:HasComponents(owner, "hh_player") then
    --            owner["components"]["hh_player"]:AddEffectValueByKey("poisonProtection", value)
    --        end
    --    end,
    --    ["un_equip_fn"] = function(inst, owner, value)
    --        if HH_UTILS:HasComponents(owner, "hh_player") then
    --            owner["components"]["hh_player"]:ReduceEffectValueByKey("poisonProtection", value)
    --        end
    --    end,
    --},
    ["add_immune_cold"] = {
        ["id"] = 47,
        ["name"] = "免疫寒冷",
        ["client_text"] = "免\n过冷",
        ["desc"] = TUNING_EQUIP_EFFECT["add_immune_cold"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 10,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
        end,
    },
    ["add_immune_hot"] = {
        ["id"] = 48,
        ["name"] = "免疫过热",
        ["client_text"] = "免\n过热",
        ["desc"] = TUNING_EQUIP_EFFECT["add_immune_hot"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 10,
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
        end,
    },
    ["add_immune_poison"] = {
        ["id"] = 49,
        ["name"] = "免疫中毒",
        ["client_text"] = "免\n中毒",
        ["desc"] = TUNING_EQUIP_EFFECT["add_immune_poison"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
            end
            if HH_UTILS:HasComponents(owner, "hh_buff") then
                owner["components"]["hh_buff"]:RemoveBuff("poison")
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
            end
        end,
    },
    ["add_immune_freeze"] = {
        ["id"] = 50,
        ["name"] = "免疫冰冻",
        ["client_text"] = "免\n冰冻",
        ["desc"] = TUNING_EQUIP_EFFECT["add_immune_freeze"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 5,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
            end
        end,
    },
    ["immune_debuff"] = {
        ["id"] = 51,
        ["name"] = "元素防御",
        ["client_text"] = "极\n元素",
        ["desc"] = TUNING_EQUIP_EFFECT["immune_debuff"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
                owner["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
                owner["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
                owner["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
            end
            if HH_UTILS:HasComponents(owner, "hh_buff") then
                owner["components"]["hh_buff"]:RemoveBuff("poison")
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
            end
        end,
    },
    ["immune_bramble"] = {
        ["id"] = 52,
        ["name"] = "免疫反伤",
        ["client_text"] = "免\n反弹",
        ["desc"] = TUNING_EQUIP_EFFECT["immune_bramble"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("immuneBramble", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immuneBramble", 1)
            end
        end,
    },

    ["san_replace_damage"] = {
        ["id"] = 53,
        ["name"] = "暗影护盾",
        ["client_text"] = "影\n护盾",
        ["desc"] = TUNING_EQUIP_EFFECT["san_replace_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 10, ["max"] = 30 },
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("sanReplaceDamageChance", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("sanReplaceDamageChance", value)
            end
        end,
    },
    ["atk_add_poison"] = {
        ["id"] = 54,
        ["name"] = "附带毒素",
        ["client_text"] = "普\n毒素",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_add_poison"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 3,
        ["value_range"] = { ["min"] = 5, ["max"] = 20 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("atkAddPoisonChance", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("atkAddPoisonChance", value)
        end,
    },
    ["reduce_bramble_percent"] = {
        ["id"] = 55,
        ["name"] = "反伤抵抗",
        ["client_text"] = "抗\n反弹",
        ["desc"] = TUNING_EQUIP_EFFECT["reduce_bramble_percent"],
        ["check_desc"] = "无",
        ["can_add"] = true,
        ["star_rating"] = 3,
        ["value_range"] = { ["min"] = 10, ["max"] = 30 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("reduceBrambleDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("reduceBrambleDamage", value)
        end,
    },
    ["follow_add_damage"] = {
        ["id"] = 56,
        ["name"] = "随从伤害",
        ["client_text"] = "仆\n伤害",
        ["desc"] = TUNING_EQUIP_EFFECT["follow_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 10, ["max"] = 20 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addFollowDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addFollowDamage", value)
        end,
    },
    ["follow_reduce_damage"] = {
        ["id"] = 57,
        ["name"] = "随从减伤", ["only_one"] = true,
        ["client_text"] = "仆\n减伤",
        ["desc"] = TUNING_EQUIP_EFFECT["follow_reduce_damage"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 10,
        ["value_range"] = { ["min"] = 10, ["max"] = 20 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addFollowReduceDamage", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addFollowReduceDamage", value)
        end,
    },
    ["health_suppress_num"] = {
        ["id"] = 58,
        ["name"] = "制裁", ["only_one"] = true,
        ["client_text"] = "普\n制裁",
        ["desc"] = TUNING_EQUIP_EFFECT["health_suppress_num"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5,
        ["value_range"] = { ["min"] = 20, ["max"] = 40 },
        ["on_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:AddEffectValueByKey("addSuppressAddHealth", value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if not HH_UTILS:HasComponents(owner, "hh_player") then
                return
            end
            owner["components"]["hh_player"]:ReduceEffectValueByKey("addSuppressAddHealth", value)
        end,
    },
    ["more_damage_20_200"] = {
        ["id"] = 59,
        ["name"] = "双倍伤害",
        ["client_text"] = "伤\n双倍",
        ["desc"] = TUNING_EQUIP_EFFECT["more_damage_20_200"],
        ["check_desc"] = "武器",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 4, ["min_star_num"] = 5,
        ["value_range"] = { ["min"] = 150, ["max"] = 200 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("moreDamage20To200", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("moreDamage20To200", value)
            end
        end,
    },
    ["more_damage_15_300"] = {
        ["id"] = 60,
        ["name"] = "三倍伤害",
        ["client_text"] = "伤\n三倍",
        ["desc"] = TUNING_EQUIP_EFFECT["more_damage_15_300"],
        ["check_desc"] = "武器",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 200, ["max"] = 300 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("moreDamage10To300", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("moreDamage10To300", value)
            end
        end,
    },
    ["more_damage_8_500"] = {
        ["id"] = 61,
        ["name"] = "五倍伤害",
        ["client_text"] = "伤\n五倍",
        ["desc"] = TUNING_EQUIP_EFFECT["more_damage_8_500"],
        ["check_desc"] = "武器",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 5, ["min_star_num"] = 10,
        ["value_range"] = { ["min"] = 450, ["max"] = 550 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("moreDamage8To500", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("moreDamage8To500", value)
            end
        end,
    },
    --------------------------------------------------------------------------------------------------------
    ["true_damage_small"] = {
        ["id"] = 62,
        ["name"] = "穿刺-小",
        ["client_text"] = "小\n穿刺",
        ["desc"] = TUNING_EQUIP_EFFECT["true_damage_small"],
        ["check_desc"] = "武器" .. check_combat_str,
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = { ["min"] = 20, ["max"] = 40 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", value)
            end
        end,
    },
    ["true_damage_big"] = {
        ["id"] = 63,
        ["name"] = "穿刺-大",
        ["client_text"] = "大\n穿刺",
        ["desc"] = TUNING_EQUIP_EFFECT["true_damage_small"],
        ["check_desc"] = "武器" .. check_combat_str,
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 40, ["max"] = 60 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", value)
            end
        end,
    },
    ["target_percent_damage"] = {
        ["id"] = 64,
        ["name"] = "撕裂",
        ["client_text"] = "伤\n比例",
        ["desc"] = TUNING_EQUIP_EFFECT["target_percent_damage"],
        ["check_desc"] = "武器" .. check_combat_str,
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 12,
        ["value_range"] = { ["min"] = 1, ["max"] = 3 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "weapon") then
                return true, "满足条件"
            end
            return false, "武器才能附加该词条"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("targetPercentDamage", value)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("targetPercentDamage", value)
            end
        end,
    },
    ["shadow_camp"] = {
        ["id"] = 65,
        ["name"] = "暗影伪装",
        ["client_text"] = "暗\n伪装",
        ["desc"] = TUNING_EQUIP_EFFECT["shadow_camp"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("shadowCamp", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("shadowCamp", 1)
            end
        end,
    },
    ["moon_camp"] = {
        ["id"] = 66,
        ["name"] = "月灵伪装",
        ["client_text"] = "月\n伪装",
        ["desc"] = TUNING_EQUIP_EFFECT["moon_camp"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("moonCamp", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("moonCamp", 1)
            end
        end,
    },
    ["immunity_moisture"] = {
        ["id"] = 67,
        ["name"] = "免疫潮湿",
        ["client_text"] = "免\n潮湿",
        ["desc"] = TUNING_EQUIP_EFFECT["immunity_moisture"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("immunityMoisture", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("immunityMoisture", 1)
            end
        end,
    },
    ["add_light"] = {
        ["id"] = 68,
        ["name"] = "光照",
        ["client_text"] = "普\n发光",
        ["desc"] = TUNING_EQUIP_EFFECT["add_light"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            HH_UTILS:HHRemoveFx(owner, "hh_add_light_fx")

            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("add_light", 1)
                owner["hh_add_light_fx"] = SpawnPrefab("hh_light_fx")
                if owner["hh_add_light_fx"] then
                    owner["hh_add_light_fx"]["entity"]:SetParent(owner["entity"])
                end
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            HH_UTILS:HHRemoveFx(owner, "hh_add_light_fx")
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("add_light", 1)
                if owner["components"]["hh_player"]:HasSpecialEffect("add_light") then
                    owner["hh_add_light_fx"] = SpawnPrefab("hh_light_fx")
                    if owner["hh_add_light_fx"] then
                        owner["hh_add_light_fx"]["entity"]:SetParent(owner["entity"])
                    end
                end

            end
        end,
    },
    ["fast_act"] = {
        ["id"] = 69,
        ["name"] = "快速交互",
        ["client_text"] = "速\n交互",
        ["desc"] = TUNING_EQUIP_EFFECT["fast_act"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, player, value)
            if HH_UTILS:HasComponents(player, "hh_player") then
                player["components"]["hh_player"]:AddEffectValueByKey("fast_act", 1)
            end
            HH_UTILS:HHClientRpc(player, "hh_fast_act", true)
        end,
        ["un_equip_fn"] = function(inst, player, value)
            if HH_UTILS:HasComponents(player, "hh_player") then
                player["components"]["hh_player"]:ReduceEffectValueByKey("fast_act", 1)
                if player["components"]["hh_player"]:HasSpecialEffect("fast_act") then
                    HH_UTILS:HHClientRpc(player, "hh_fast_act", true)
                else
                    HH_UTILS:HHClientRpc(player, "hh_fast_act", false)
                end
            end
        end,
    },
    ["work_speed"] = {
        ["id"] = 70,
        ["name"] = "双倍工作",
        ["client_text"] = "速\n工作",
        ["desc"] = TUNING_EQUIP_EFFECT["work_speed"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("workAddSpeed", 1)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("workAddSpeed", 1)
            end
        end,
    },
    ["armor_reduce_amount_small"] = {
        ["id"] = 71,
        ["name"] = "初级护甲减免",
        ["client_text"] = "普\n减甲",
        ["desc"] = TUNING_EQUIP_EFFECT["armor_reduce_amount"],
        ["check_desc"] = "含有护甲值(armor)",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 10, ["max"] = 40 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"] then
                return true, "满足条件"
            end
            return false, "前置条件:含有护甲值"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
        end,
    },
    ["armor_reduce_amount"] = {
        ["id"] = 72,
        ["name"] = "高级护甲减免",
        ["client_text"] = "极\n减甲",
        ["desc"] = TUNING_EQUIP_EFFECT["armor_reduce_amount"],
        ["check_desc"] = "含有护甲值(armor)",
        ["can_add"] = false, ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 30, ["max"] = 80 },
        ["check_equip_can_add"] = function(inst)
            if HH_UTILS:HasComponents(inst, "armor") and not inst["components"]["armor"]["indestructible"] then
                return true, "满足条件"
            end
            return false, "前置条件:含有护甲值"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
        end,
    },
    ["porter"] = {
        ["id"] = 73,
        ["name"] = "搬运工",
        ["client_text"] = "普\n搬运",
        ["desc"] = TUNING_EQUIP_EFFECT["porter"],
        ["check_desc"] = "头部(搬雕像只能戴帽子)",
        ["can_add"] = true, ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 10, ["max"] = 80 },
        ["check_equip_can_add"] = function(inst)
            if isEquipSlot(inst, EQUIPSLOTS["HEAD"]) then
                return true, "满足条件"
            end
            return false, "只允许附魔在头部"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["porter"] = 1, --免疫雕像减速
            }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["porter"] = 1, --免疫雕像减速
            }, false)
        end,
    },
    ["atk_speed_small"] = {
        ["id"] = 74,
        ["name"] = "小攻速",
        ["client_text"] = "小\n攻速",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_speed"],
        ["check_desc"] = "手部,身体栏,头部(攻速上限一百)",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = true,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 30 },
        ["check_equip_can_add"] = function(inst)
            if isEquipSlot(inst, EQUIPSLOTS["HANDS"])
                    or isEquipSlot(inst, EQUIPSLOTS["HEAD"])
                    or isEquipSlot(inst, EQUIPSLOTS["BODY"])
            then
                return true, "满足条件"
            end
            return false, "只允许附魔在手部,身体栏,头部"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["atk_speed"] = value, }, true)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                local current_speed = owner["components"]["hh_player"]:GetEffectValueByKey("atk_speed")
                HH_UTILS:HHClientRpc(owner, "hh_atk_speed", current_speed)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["atk_speed"] = value, }, false)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                local current_speed = owner["components"]["hh_player"]:GetEffectValueByKey("atk_speed")
                HH_UTILS:HHClientRpc(owner, "hh_atk_speed", current_speed)
            end
        end,
    },
    ["atk_speed_big"] = {
        ["id"] = 75,
        ["name"] = "大攻速",
        ["client_text"] = "大\n攻速",
        ["desc"] = TUNING_EQUIP_EFFECT["atk_speed"],
        ["check_desc"] = "手部,身体栏,头部(攻速上限一百)",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = false, ["only_one"] = true,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 10, ["max"] = 70 },
        ["check_equip_can_add"] = function(inst)
            if isEquipSlot(inst, EQUIPSLOTS["HANDS"])
                    or isEquipSlot(inst, EQUIPSLOTS["HEAD"])
                    or isEquipSlot(inst, EQUIPSLOTS["BODY"])
            then
                return true, "满足条件"
            end
            return false, "只允许附魔在手部,身体栏,头部"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["atk_speed"] = value, }, true)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                local current_speed = owner["components"]["hh_player"]:GetEffectValueByKey("atk_speed")
                HH_UTILS:HHClientRpc(owner, "hh_atk_speed", current_speed)
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["atk_speed"] = value, }, false)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                local current_speed = owner["components"]["hh_player"]:GetEffectValueByKey("atk_speed")
                HH_UTILS:HHClientRpc(owner, "hh_atk_speed", current_speed)
            end
        end,
    },
    ["immune_sleep"] = {
        ["id"] = 76,
        ["name"] = "免疫催眠",
        ["client_text"] = "免\n催眠",
        ["desc"] = TUNING_EQUIP_EFFECT["immune_sleep"],
        --["check_desc"] = "手部,身体栏,头部(攻速上限一百)",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        ["check_desc"] = "无",
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["immunitySleep"] = 1, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["immunitySleep"] = 1, }, false)
        end,
    },
    ["absorb_small"] = {
        ["id"] = 77,
        ["name"] = "伤害减免-小",
        ["client_text"] = "小\n免伤",
        ["desc"] = TUNING_EQUIP_EFFECT["absorb_small"],
        ["check_desc"] = string["format"]("无,上限%s%%", 80),
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 5 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, false)
        end,
    },
    ["absorb_middle"] = {
        ["id"] = 78,
        ["name"] = "伤害减免-中",
        ["client_text"] = "中\n免伤",
        ["desc"] = TUNING_EQUIP_EFFECT["absorb_small"],
        ["check_desc"] = string["format"]("无,上限%s%%", 80),
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 3, ["max"] = 8 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, false)
        end,
    },
    ["absorb_big"] = {
        ["id"] = 79,
        ["name"] = "伤害减免-大",
        ["client_text"] = "大\n免伤",
        ["desc"] = TUNING_EQUIP_EFFECT["absorb_small"],
        ["check_desc"] = string["format"]("无,上限%s%%", 80),
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = false, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 8, ["max"] = 15 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["absorbDamage"] = value, }, false)
        end,
    },
    ["autumn_god"] = {
        ["id"] = 80,
        ["name"] = "秋季战神",
        ["client_text"] = "秋\n战神",
        ["desc"] = TUNING_EQUIP_EFFECT["autumn_god"],
        ["check_desc"] = "无",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 999 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["autumnGod"] = 1, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["autumnGod"] = 1, }, false)
        end,
    },
    ["black_monkey"] = {
        ["id"] = 81,
        ["name"] = "吗喽之力",
        ["client_text"] = "黑\n吗喽",
        ["desc"] = TUNING_EQUIP_EFFECT["black_monkey"],
        ["check_desc"] = "无(加成上限100%)",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 3, ["max"] = 6 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["monkey_god"] = value, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["monkey_god"] = value, }, false)
        end,
    },
    ["tga_robot"] = {
        ["id"] = 82,
        ["name"] = "宇宙机器人",
        ["client_text"] = "年\n最佳",
        ["desc"] = TUNING_EQUIP_EFFECT["tga_robot"],
        ["check_desc"] = "无",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = false,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 5 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["tga_robot"] = value, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["tga_robot"] = value, }, false)
        end,
    },
    ["money_player"] = {
        ["id"] = 83,
        ["name"] = "氪金玩家",
        ["client_text"] = "好\n氪金",
        ["desc"] = TUNING_EQUIP_EFFECT["money_player"],
        ["check_desc"] = "只生效一条,每次造成伤害都会消耗",
        --["ui_from_desc"] = "挖宝藏概率获得",
        ["can_add"] = true, ["only_one"] = true,
        --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        --["is_special"] = true, --特殊附魔石 特殊途径获取
        ["star_rating"] = 8,
        --["value_range"] = { ["min"] = 1, ["max"] = 5 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["money_player"] = 1, }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, { ["money_player"] = 1, }, false)
        end,
    },
    ["immunity_stick"] = {
        ["id"] = 84,
        ["name"] = "免疫粘液",
        ["client_text"] = "免\n粘液",
        ["desc"] = TUNING_EQUIP_EFFECT["immunity_stick"],
        ["check_desc"] = "无",
        ["can_add"] = true, ["only_one"] = false,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            addEquipEffect(owner, "immunityStick", 1, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addEquipEffect(owner, "immunityStick", 1, false)
        end,
    },
    --多发弹道
    --["more_biu"] = {
    --    ["id"] = 84,
    --    ["name"] = "多发弹道",
    --    ["client_text"] = "多\n弹道",
    --    ["desc"] = "多发弹道",
    --    ["check_desc"] = "只生效一条,限制武器栏",
    --    --["ui_from_desc"] = "挖宝藏概率获得",
    --    ["can_add"] = false, ["only_one"] = true,
    --    --["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
    --    --["is_special"] = true, --特殊附魔石 特殊途径获取
    --    ["star_rating"] = 8,
    --    ["value_range"] = { ["min"] = 1, ["max"] = 5 },
    --    ["on_equip_fn"] = function(inst, owner, value)
    --        owner["hh_biu_num"] = value
    --        owner:ListenForEvent("onhitother", biuEvent)
    --    end,
    --    ["un_equip_fn"] = function(inst, owner, value)
    --        owner:RemoveEventCallback("onhitother", biuEvent)
    --        owner["hh_biu_num"] = nil
    --    end,
    --},
    ---------------------------------------------宝藏词条-------------------------------------------------------------
    --["treasure_poison_freeze"] = {
    --    ["id"] = 801, ["name"] = "宝藏-毒冻", ["client_text"] = "宝\n毒冻",
    --    ["desc"] = TUNING_EQUIP_EFFECT["treasure_poison_freeze"],
    --    ["check_desc"] = "无",
    --    ["can_add"] = false, ["only_one"] = true,
    --    ["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
    --    ["is_special"] = true, --特殊附魔石 特殊途径获取
    --    ["on_equip_fn"] = function(inst, owner, value)
    --        addSuitEffect(owner, { ["immunePoison"] = 1, ["immuneFreeze"] = 1, }, true)
    --        if HH_UTILS:HasComponents(owner, "hh_buff") then
    --            owner["components"]["hh_buff"]:RemoveBuff("poison")
    --        end
    --    end,
    --    ["un_equip_fn"] = function(inst, owner, value)
    --        addSuitEffect(owner, { ["immunePoison"] = 1, ["immuneFreeze"] = 1, }, false)
    --    end,
    --},
    --["treasure_hot_cold"] = {
    --    ["id"] = 802, ["name"] = "宝藏-温度", ["client_text"] = "宝\n冷热",
    --    ["desc"] = TUNING_EQUIP_EFFECT["treasure_hot_cold"],
    --    ["check_desc"] = "无",
    --    ["can_add"] = false, ["only_one"] = true,
    --    ["client_color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
    --    ["is_special"] = true, --特殊附魔石 特殊途径获取
    --    ["on_equip_fn"] = function(inst, owner, value)
    --        addSuitEffect(owner, { ["immunePoison"] = 1, ["immuneFreeze"] = 1, }, true)
    --        if HH_UTILS:HasComponents(owner, "hh_buff") then
    --            owner["components"]["hh_buff"]:RemoveBuff("poison")
    --        end
    --    end,
    --    ["un_equip_fn"] = function(inst, owner, value)
    --        addSuitEffect(owner, { ["immunePoison"] = 1, ["immuneFreeze"] = 1, }, false)
    --    end,
    --},

    ---------------------------------------------稀有-------------------------------------------------------------
    ["armor_immune_amount"] = {
        ["id"] = 900,
        ["name"] = "稀★护甲锁定",
        ["client_text"] = "稀\n锁甲",
        ["desc"] = TUNING_EQUIP_EFFECT["armor_immune_amount"],
        ["check_desc"] = "含有护甲值(armor)且免伤比例小于1",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 10, ["max"] = 80 },
        ["check_equip_can_add"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "armor") then
                return false, "需要含有护甲值"
            end
            if not inst["components"]["armor"]["indestructible"] then
                return true, "满足条件"
            end
            local current_armor = inst["components"]["armor"]["absorb_percent"] or 0
            if not HH_UTILS:IsHHType(current_armor, "number") then
                return false, "护甲防御参数错误"
            end
            if current_armor >= 1 then
                return false, "防御过高-禁止附魔"
            end
            return false, "前置条件:含有护甲值"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
        end,
    },
    ["special_bhtg"] = {
        ["id"] = 901,
        ["name"] = "稀★白虎天罡",
        ["client_text"] = "稀\n白虎",
        ["desc"] = TUNING_EQUIP_EFFECT["special_bhtg"],
        ["check_desc"] = "武器栏",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 1000 },
        ["check_equip_can_add"] = function(inst)
            if isEquipSlot(inst, EQUIPSLOTS["HANDS"]) then
                return true, "满足条件"
            end
            return false, "只允许附魔在手部"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["restoreSpirit"] = 3, --回神
                ["bloodSuck"] = 3, --吸血-3
                ["addComDamage"] = 50, --伤害
                ["addComDamagePercent"] = 10, --伤害加成
                ["addSuppressAddHealth"] = 100, --制裁
            }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["restoreSpirit"] = 3, --回神
                ["bloodSuck"] = 3, --吸血-3
                ["addComDamage"] = 50, --伤害
                ["addComDamagePercent"] = 10, --伤害加成
                ["addSuppressAddHealth"] = 100, --制裁
            }, false)
        end,
    },
    ["special_zqrf"] = {
        ["id"] = 902,
        ["name"] = "稀★朱雀鸾凤",
        ["client_text"] = "稀\n朱雀",
        ["desc"] = TUNING_EQUIP_EFFECT["special_zqrf"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["immuneSuppressNum"] = 1, --免疫减速
                ["immuneReduceSpeed"] = 1, --免疫制裁
                ["immuneFreeze"] = 1, --免疫冰冻
                ["immunePoison"] = 1, --免疫中毒
                ["immuneCold"] = 1, --免疫过冷
                ["immuneHot"] = 1, --免疫过热
                ["immunityMoisture"] = 1, --免疫潮湿
            }, true)
            if HH_UTILS:HasComponents(owner, "hh_buff") then
                owner["components"]["hh_buff"]:RemoveBuff("poison")
                owner["components"]["hh_buff"]:RemoveBuff("reduce_speed")
                owner["components"]["hh_buff"]:RemoveBuff("add_cold")
                owner["components"]["hh_buff"]:RemoveBuff("add_hot")
                owner["components"]["hh_buff"]:RemoveBuff("player_healthSuppressNum")
            end
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["immuneSuppressNum"] = 1, --免疫减速
                ["immuneReduceSpeed"] = 1, --免疫制裁
                ["immuneFreeze"] = 1, --免疫冰冻
                ["immunePoison"] = 1, --免疫中毒
                ["immuneCold"] = 1, --免疫过冷
                ["immuneHot"] = 1, --免疫过热
                ["immunityMoisture"] = 1, --免疫潮湿
            }, false)
        end,
    },
    ["special_true_damage"] = {
        ["id"] = 903,
        ["name"] = "稀★真伤",
        ["client_text"] = "稀\n真伤",
        ["desc"] = TUNING_EQUIP_EFFECT["special_true_damage"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 150, ["max"] = 251 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["trueDamageNum"] = value, --免疫潮湿
            }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["trueDamageNum"] = value, --免疫潮湿
            }, false)
        end,
    },
    ["special_sgsy"] = {
        ["id"] = 904,
        ["name"] = "稀★神龟守御",
        ["client_text"] = "稀\n玄武",
        ["desc"] = TUNING_EQUIP_EFFECT["special_sgsy"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = false,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["value_range"] = { ["min"] = 1, ["max"] = 1000 },
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["absorbDamage"] = 45, --伤害减免
                ["reduceAttackedDamage"] = 35, --伤害减免
                ["immuneBramble"] = 1, --免疫反弹
            }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["absorbDamage"] = 45, --伤害减免
                ["reduceAttackedDamage"] = 35, --伤害减免
                ["immuneBramble"] = 1, --免疫反弹
            }, false)
        end,
    },
    ["special_immune_control"] = {
        ["id"] = 905,
        ["name"] = "稀★免疫控制",
        ["client_text"] = "稀\n免控",
        ["desc"] = TUNING_EQUIP_EFFECT["special_immune_control"],
        ["check_desc"] = "无",
        ["can_add"] = false, ["only_one"] = false,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, --超级稀有宝石
        ["only_compound"] = true, --只能合成台合成出来
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(inst, owner, value)
            addEquipEffect(owner, "immunityStick", 1, true)
            addEquipEffect(owner, "immunityKnockBack", 1, true)
            addEquipEffect(owner, "immunitySleep", 1, true)
            addEquipEffect(owner, "immuneFreeze", 1, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addEquipEffect(owner, "immunityStick", 1, false)
            addEquipEffect(owner, "immunityKnockBack", 1, false)
            addEquipEffect(owner, "immunitySleep", 1, false)
            addEquipEffect(owner, "immuneFreeze", 1, false)
        end,
    },
}
local function getOffsetNum(hh_num)
    if HH_UTILS:IsHHType(hh_num, "number") then
        return hh_num
    end
    return 0
end
local function addBodyFx(owner, fx_index, fx_name, anim_name, offset_x, offset_y, offset_z)
    if not owner or not HH_UTILS:IsHHType(fx_index, "string") or not HH_UTILS:IsHHType(fx_name, "string") then
        return
    end
    HH_UTILS:HHRemoveFx(owner, fx_index)
    owner[fx_index] = SpawnPrefab(fx_name)
    if owner[fx_index] then
        if HH_UTILS:IsHHType(anim_name, "string") and owner[fx_index]["AnimState"] then
            owner[fx_index]["AnimState"]:PlayAnimation(anim_name, true)
        end
        owner[fx_index]["entity"]:AddFollower()
        owner[fx_index]["entity"]:SetParent(owner["entity"])
        local base_x = getOffsetNum(offset_x)
        local base_y = getOffsetNum(offset_y)
        local base_z = getOffsetNum(offset_z)
        owner[fx_index]["Follower"]:FollowSymbol(owner["GUID"], "swap_body", base_x, base_y, base_z)
    end
end
--local function SpawnFootFx(player)
--    if not player or not player["sg"] or player:HasTag("playerghost") then
--        return
--    end
--    local is_moving = player["sg"]:HasStateTag("moving")
--    local is_running = player["sg"]:HasStateTag("running")
--    if (is_moving or is_running) and player["Transform"] then
--        local foot_fx = SpawnPrefab("hh_footprint_fx")
--        if foot_fx and foot_fx["Transform"] then
--            local x, y, z = player["Transform"]:GetWorldPosition()
--            local player_angle = player["Transform"]:GetRotation()
--            local foot_x, foot_y = 0, 0
--            local hh_offset = 0.3
--            if not player["hh_foot_to_change"] then
--                player["hh_foot_to_change"] = true
--            else
--                hh_offset = -0.3
--                player["hh_foot_to_change"] = false
--            end
--            foot_x = x + hh_offset * math["cos"]((-player_angle + 90) * DEGREES)
--            foot_y = z + hh_offset * math["sin"]((-player_angle + 90) * DEGREES)
--            foot_fx["Transform"]:SetPosition(foot_x, 0, foot_y)
--            foot_fx["Transform"]:SetRotation(player_angle)
--        end
--    end
--end
--宝石效果
local HH_GEM_BUFF_LIST = {
    ["durableGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["durableGem"],
        --满足前置条件才可以镶嵌
        ["check_gem_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该宝石!!!"
        end,
        --装备唯一性 一个装备是否可以镶嵌多个相同的宝石
        ["only_one"] = true,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "gem_durableGem_task")
            inst["gem_durableGem_task"] = inst:DoPeriodicTask(2, function()
                AddEquipUse(inst, 1)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "gem_durableGem_task")
        end,
    },
    ["damageBoostGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["damageBoostGem"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addComDamage", 10)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamage", 10)
            end
        end,
    },
    ["powerMettleStone"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["powerMettleStone"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", 3)
            end
        end,
    },
    ["strideBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["strideBead"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", 3)
            end
        end,
    },
    ["shadowNightBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["shadowNightBead"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("nightMenace", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("nightMenace", 20)
            end
        end,
    },
    ["twilightBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["twilightBead"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("afterglowStrike", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("afterglowStrike", 20)
            end
        end,
    },
    ["dayShineBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["dayShineBead"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("sunlightStrike", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("sunlightStrike", 20)
            end
        end,
    },
    ["critStrikeStone"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["critStrikeStone"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 3)
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", 10)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 3)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", 10)
            end
        end,
    },
    ["resistDamageGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["resistDamageGem"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("reduceAttackedDamage", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("reduceAttackedDamage", 3)
            end
        end,
    },
    ["retaliateGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["retaliateGem"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("reflexiveInjury", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("reflexiveInjury", 3)
            end
        end,
    },
    ["spiderVengeance"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["spiderVengeance"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addHitSpiderDamage", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitSpiderDamage", 20)
            end
        end,
    },
    ["insectStrikeCrystal"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["insectStrikeCrystal"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addHitInsectDamage", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitInsectDamage", 20)
            end
        end,
    },
    ["shadowStrikeLuminary"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["shadowStrikeLuminary"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addHitShadowDamage", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitShadowDamage", 20)
            end
        end,
    },
    ["bossStrikeGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["bossStrikeGem"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addHitBossDamage", 50)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addHitBossDamage", 50)
            end
        end,
    },
    --随从宝石
    ["followCritical"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followCritical"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addFollowCritical", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addFollowCritical", 3)
            end
        end,
    },
    ["followDamage"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followDamage"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addFollowDamage", 10)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addFollowDamage", 10)
            end
        end,
    },
    ["followArmor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followArmor"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addFollowReduceDamage", 3)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addFollowReduceDamage", 3)
            end
        end,
    },
    ["elementBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["elementBead"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(inst, owner)
            addMoreBuff(owner)
        end,
        ["un_equip_fn"] = function(inst, owner)
            removeMoreBuff(owner)
        end,
    },
    ["eightPigGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["eightPigGem"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(inst, owner)
            addMoreBuff(owner)
            addTextTask(owner, "eight_pig_task", "eight_pig")
        end,
        ["un_equip_fn"] = function(inst, owner)
            removeMoreBuff(owner)
            HH_UTILS:HHKillTask(owner, "eight_pig_task")
        end,
    },
    ["nkGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["nkGem"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "nkGemTask")
            inst["nkGemTask"] = inst:DoPeriodicTask(1, function()
                AddPercentEquipUse(inst, 0.02)
            end)
            AddMaxUse(inst, 750)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "nkGemTask")
            AddMaxUse(inst, -750)
        end,
        ["on_equip_fn"] = function(inst, owner)
            addMoreBuff(owner)
            addTextTask(owner, "gem_nk_task", "gem_nk")
        end,
        ["un_equip_fn"] = function(inst, owner)
            removeMoreBuff(owner)
            HH_UTILS:HHKillTask(owner, "gem_nk_task")
        end,
    },
    ["baconOmeletteBlessArmor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessArmor"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "nkGemTask")
            inst["nkGemTask"] = inst:DoPeriodicTask(1, function()
                AddPercentEquipUse(inst, 0.02)
            end)
            AddMaxUse(inst, 1000)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "nkGemTask")
            AddMaxUse(inst, -1000)
        end,
        ["on_equip_fn"] = function(inst, owner)
            addMoreBuff(owner)
        end,
        ["un_equip_fn"] = function(inst, owner)
            removeMoreBuff(owner)
        end,
    },
    ["baconOmeletteBlessAtk"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessAtk"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addComDamage", 50)
                owner["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", 15)
                owner["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", 5)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamage", 50)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", 15)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", 5)
            end
        end,
    },
    ["baconOmeletteBlessCritical"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessCritical"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 10)
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", 50)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 10)
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", 50)
            end
        end,
    },
    ["baconOmeletteTrueDamage"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteTrueDamage"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", 100)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", 100)
            end
        end,
    },
    ["fxGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["fxGem"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(inst, owner)
            addTextTask(owner, "gem_ph_task", "gem_jd")
        end,
        ["un_equip_fn"] = function(inst, owner)
            HH_UTILS:HHKillTask(owner, "gem_ph_task")
        end,
    },
    -------------------------------------------------宝藏宝石----------------------------------------------------------------
    ["treasure_armor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_armor"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "treasure_armor_task")
            inst["treasure_armor_task"] = inst:DoPeriodicTask(1, function()
                AddPercentEquipUse(inst, 0.02)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "treasure_armor_task")
        end,
    },

    ["treasure_atk"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_atk"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("addComDamage", 50)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("addComDamage", 50)
            end
        end,
    },
    ["treasure_bj"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_bj"],
        ["on_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 20)
            end
        end,
        ["un_equip_fn"] = function(inst, owner)
            if HH_UTILS:HasComponents(owner, "hh_player") then
                owner["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 20)
            end
        end,
    },
}
----
---校验是否满足套装前置条件
local function checkIsValidSuit(player, effect_list)
    if not HH_UTILS:HasComponents(player, "hh_player")
            or not HH_UTILS:IsHHType(effect_list, "table")
    then
        return false
    end
    local not_is_valid = false
    for i, v in ipairs(effect_list) do
        if not player["components"]["hh_player"]:HasSpecialEffect(v) then
            not_is_valid = true
            break
        end
    end
    if not_is_valid then
        return false
    end
    return true
end
local function hasBuff(player, buff_name)
    if HH_UTILS:HasComponents(player, "hh_buff") then
        return player["components"]["hh_buff"]:HasBuff(buff_name)
    end
    return false
end
----
---玄武套装受击效果
---
local function basaltAttacked(owner, data)
    if not HH_UTILS:NotIsDead(owner)
            or not HH_UTILS:HasComponents(owner, "hh_buff")
            or hasBuff(owner, "suit_basalt_cd")
            or not data or not HH_UTILS:IsHHType(data["damageresolved"], "number")
            or data["damageresolved"] <= 0
    then
        return
    end
    owner["components"]["health"]:DoDelta(10)
    --删除原有的显示效果 增加新的显示效果
    HH_UTILS:HandleSuitBuff(owner, "suit_basalt")
    HH_UTILS:HandleSuitBuff(owner, "suit_basalt_cd", 20, true)

end
----
---永恒庇佑套装受击效果
---
local function yhbyAttacked(owner, data)
    if not HH_UTILS:NotIsDead(owner) then
        return
    end
    if hasBuff(owner, "suit_yhby_cd") then
        return
    end
    local x, y, z = owner["Transform"]:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 10, { "player" })
    if ents then
        for i, v in ipairs(ents) do
            if HH_UTILS:NotIsDead(v)
                    and HH_UTILS:HasComponents(v, "hh_player")
                    and HH_UTILS:HasComponents(v, "hh_buff")
            then
                if not hasBuff(owner, "suit_yhby_cd") then
                    HH_UTILS:HandleSuitBuff(v, "add_health", 10, true)
                end
            end
        end
    end
    HH_UTILS:SpawnClientStrFx(owner, "永恒庇佑触发")
    HH_UTILS:HandleSuitBuff(owner, "suit_yhby_cd", 20, true)


end
--套装类词条属性
local HH_SUIT_LIST = {
    ["suit_yhby"] = {
        ["check_fn"] = checkIsValidSuit,
        ["effect_list"] = { "z_suit_yhby_hand", "z_suit_yhby_body", "z_suit_yhby_hat" },
        ["start_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["immuneSuppressNum"] = 1, --免疫制裁
                ["immunityMoisture"] = 1, --免疫潮湿
                ["immunePoison"] = 1, --免疫中毒
                ["reduceAttackedDamage"] = 10, --减伤10
            }, true)
            --清除当前的负面
            HH_UTILS:HandleSuitBuff(player, "player_healthSuppressNum")
            HH_UTILS:HandleSuitBuff(player, "poison")
            HH_UTILS:HandleSuitBuff(player, "suit_yhby", nil, true)
            player:ListenForEvent("attacked", yhbyAttacked)
        end,
        ["stop_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["immuneSuppressNum"] = 1, --免疫制裁
                ["immunityMoisture"] = 1, --免疫潮湿
                ["immunePoison"] = 1, --免疫中毒
                ["reduceAttackedDamage"] = 10, --减伤10
            }, false)
            HH_UTILS:HandleSuitBuff(player, "suit_yhby")
            player:RemoveEventCallback("attacked", yhbyAttacked)
        end,
    },
    --["suit_xwsh"] = {
    --    ["check_fn"] = checkIsValidSuit,
    --    ["effect_list"] = { "z_suit_xwsh_hand", "z_suit_xwsh_body", "z_suit_xwsh_hat" },
    --    ["start_fn"] = function(player, equip)
    --        print("玄武守护穿")
    --    end,
    --    ["stop_fn"] = function(player, equip)
    --        print("玄武守护脱")
    --    end,
    --},
    --["suit_slly"] = {
    --    ["check_fn"] = checkIsValidSuit,
    --    ["effect_list"] = { "z_suit_slly_hand", "z_suit_slly_body", "z_suit_slly_hat" },
    --    ["start_fn"] = function(player, equip)
    --        print("神龙凌云 穿")
    --    end,
    --    ["stop_fn"] = function(player, equip)
    --        print("神龙凌云 脱")
    --    end,
    --},
    ["suit_bhtg"] = {
        ["check_fn"] = checkIsValidSuit,
        ["effect_list"] = { "z_suit_bhtg_hand", "z_suit_bhtg_body", "z_suit_bhtg_hat" },
        ["start_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["targetPercentDamage"] = 2, --撕裂-2
                ["restoreSpirit"] = 3, --回神
                ["addComDamage"] = 50, --伤害
                ["addComDamagePercent"] = 10, --伤害加成
                ["addSuppressAddHealth"] = 100, --制裁
            }, true)
        end,
        ["stop_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["targetPercentDamage"] = 2, --撕裂-2
                ["restoreSpirit"] = 3, --回神
                ["addComDamage"] = 50, --伤害
                ["addComDamagePercent"] = 10, --伤害加成
                ["addSuppressAddHealth"] = 100, --制裁
            }, false)
        end,
    },
    ["suit_zqrf"] = {
        ["check_fn"] = checkIsValidSuit,
        ["effect_list"] = { "z_suit_zqrf_hand", "z_suit_zqrf_body", "z_suit_zqrf_hat" },
        ["start_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["trueDamageNum"] = 50, --50穿刺
                --["addSpeedPercent"] = 20, --加速
                ["bloodSuck"] = 3, --吸血-3
                ["immuneSuppressNum"] = 1, --免疫减速
                ["immuneReduceSpeed"] = 1, --免疫制裁
            }, true)
        end,
        ["stop_fn"] = function(player, equip)
            addSuitEffect(player, {
                ["trueDamageNum"] = 50, --50穿刺
                --["addSpeedPercent"] = 20, --加速
                ["bloodSuck"] = 3, --吸血-3
                ["immuneSuppressNum"] = 1, --免疫减速
                ["immuneReduceSpeed"] = 1, --免疫制裁
            }, false)
        end,
    },
    ---------------------------------------定制套装--------------------------------------------------
    --飞云逸影
    --["suit_fyyy"] = {
    --    ["check_fn"] = checkIsValidSuit, ["is_person"] = true,
    --    ["effect_list"] = { "z_suit_fyyy_hand", "z_suit_fyyy_body", "z_suit_fyyy_hat" },
    --    ["start_fn"] = function(player, equip)
    --        HH_UTILS:HHRemoveFx(player, "hh_suit_fyyy_fx")
    --        player["hh_suit_fyyy_fx"] = SpawnPrefab("hh_light_fx")
    --        if player["hh_suit_fyyy_fx"] then
    --            player["hh_suit_fyyy_fx"]["entity"]:SetParent(player["entity"])
    --        end
    --        addSuitEffect(player, {
    --            ["addSpeedPercent"] = 30, --移速
    --            ["restoreSpirit"] = 10, --回神
    --            ["bloodSuck"] = 10, --吸血
    --            ["addComDamage"] = 50, --伤害
    --        }, true)
    --        player["hh_fast_act"] = true
    --        HH_UTILS:HHClientRpc(player, "hh_fast_act", true)
    --    end,
    --    ["stop_fn"] = function(player, equip)
    --        HH_UTILS:HHRemoveFx(player, "hh_suit_fyyy_fx")
    --        addSuitEffect(player, {
    --            ["addSpeedPercent"] = 30, --移速
    --            ["restoreSpirit"] = 10, --回神
    --            ["bloodSuck"] = 10, --吸血
    --            ["addComDamage"] = 50, --伤害
    --        }, false)
    --        player["hh_fast_act"] = false
    --        HH_UTILS:HHClientRpc(player, "hh_fast_act", false)
    --    end,
    --},
}
local hh_xml, hh_tex = "images/hh_icon/hh_items.xml", "hh_essence.tex"
local hh_image_xml = "images/inventoryimages.xml"
--词条合成配方
local HH_SUIT_RECIPE = {
    {
        ["id"] = "z_suit_yhby_hand",
        ["recipe"] = {
            --附魔石的话 需要加effect显示对应词条
            -- 水晶小人-10 石头 蓝蘑菇 牛毛
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "rocks", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "rocks.tex", },
            { ["id"] = "blue_cap", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "blue_cap.tex", },
            { ["id"] = "beefalowool", ["num"] = 5, ["xml"] = hh_image_xml, ["tex"] = "beefalowool.tex", },
        },
    },
    {
        ["id"] = "z_suit_yhby_body",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "rocks", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "rocks.tex", },
            { ["id"] = "bandage", ["num"] = 3, ["xml"] = hh_image_xml, ["tex"] = "bandage.tex", }, --蜂蜜药膏
            { ["id"] = "red_cap", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "red_cap.tex", }, --红蘑菇
        },
    },
    {
        ["id"] = "z_suit_yhby_hat",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "rocks", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "rocks.tex", },
            { ["id"] = "jellybean", ["num"] = 3, ["xml"] = hh_image_xml, ["tex"] = "jellybean.tex", }, --糖豆
            { ["id"] = "green_cap", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "green_cap.tex", }, --绿蘑菇
        },
    },

    --白虎套装

    {
        ["id"] = "z_suit_bhtg_hand",
        ["recipe"] = {
            --水晶小人 猫尾 铥矿 金子
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "coontail", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "coontail.tex", },
            { ["id"] = "thulecite", ["num"] = 5, ["xml"] = hh_image_xml, ["tex"] = "thulecite.tex", },
            { ["id"] = "goldnugget", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "goldnugget.tex", },
        },
    },
    {
        ["id"] = "z_suit_bhtg_body",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "horn", ["num"] = 1, ["xml"] = hh_image_xml, ["tex"] = "horn.tex", }, --牛角
            { ["id"] = "steelwool", ["num"] = 5, ["xml"] = hh_image_xml, ["tex"] = "steelwool.tex", }, --刚羊毛
            { ["id"] = "stinger", ["num"] = 40, ["xml"] = hh_image_xml, ["tex"] = "stinger.tex", }, --蜂刺
        },
    },
    {
        ["id"] = "z_suit_bhtg_hat",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "pigskin", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "pigskin.tex", }, --猪皮
            { ["id"] = "tentaclespots", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "tentaclespots.tex", }, --触手皮
            { ["id"] = "slurper_pelt", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "slurper_pelt.tex", }, --帽子怪皮
        },
    },

    --朱雀鸾凤
    {
        ["id"] = "z_suit_zqrf_hand",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "feather_canary", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "feather_canary.tex", }, --金色鸟毛
            { ["id"] = "thulecite", ["num"] = 5, ["xml"] = hh_image_xml, ["tex"] = "thulecite.tex", },
            { ["id"] = "goldnugget", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "goldnugget.tex", },
        },
    },
    {
        ["id"] = "z_suit_zqrf_body",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "feather_crow", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "feather_crow.tex", }, --黑色鸟毛
            { ["id"] = "steelwool", ["num"] = 5, ["xml"] = hh_image_xml, ["tex"] = "steelwool.tex", }, --刚羊毛
            { ["id"] = "beefalowool", ["num"] = 20, ["xml"] = hh_image_xml, ["tex"] = "beefalowool.tex", }, --牛毛
        },
    },
    {
        ["id"] = "z_suit_zqrf_hat",
        ["recipe"] = {
            { ["id"] = "hh_essence", ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
            { ["id"] = "feather_robin", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "feather_robin.tex", }, --红色鸟毛
            { ["id"] = "feather_robin_winter", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "feather_robin_winter.tex", }, --白色鸟
            { ["id"] = "silk", ["num"] = 40, ["xml"] = hh_image_xml, ["tex"] = "silk.tex", }, --蜘蛛丝
        },
    },
    --{ ["id"] = "hh_essence", ["name"] = nil, ["num"] = 10, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", ["effect"] = "", },
    --{ ["id"] = "walrus_tusk", ["name"] = "铥矿", ["num"] = 2, ["xml"] = hh_image_xml, ["tex"] = "walrus_tusk.tex", },
    --{ ["id"] = "nightmarefuel", ["name"] = "恶魔燃料", ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "nightmarefuel.tex", },
    --{ ["id"] = "papyrus", ["name"] = nil, ["num"] = 10, ["xml"] = hh_image_xml, ["tex"] = "papyrus.tex", },
    ---------------------------------------------------------------------------------------------------------------------
    --{
    --    ["id"] = "z_suit_fyyy_hand",
    --    ["recipe"] = {
    --        { ["id"] = "hh_essence", ["num"] = 50, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
    --    },
    --},
    --{
    --    ["id"] = "z_suit_fyyy_body",
    --    ["recipe"] = {
    --        { ["id"] = "hh_essence", ["num"] = 50, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
    --    },
    --},
    --{
    --    ["id"] = "z_suit_fyyy_hat",
    --    ["recipe"] = {
    --        { ["id"] = "hh_essence", ["num"] = 50, ["xml"] = hh_xml, ["tex"] = "hh_essence.tex", },
    --    },
    --},

}
return {
    ["HH_EQUIP_BUFF_LIST"] = HH_EQUIP_BUFF_LIST,
    ["HH_GEM_BUFF_LIST"] = HH_GEM_BUFF_LIST,
    ["HH_SUIT_LIST"] = HH_SUIT_LIST,
    ["HH_SUIT_RECIPE"] = HH_SUIT_RECIPE,
}
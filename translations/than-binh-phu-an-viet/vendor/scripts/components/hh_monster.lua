local HH_UTILS = require("utils/hh_utils")
local HH_EFFECT_CONFIG = require("enums/hh_effects")
local HH_PREFAB_LIST = require("enums/hh_prefab_list")
local HH_MONSTER_BUFFS = require("enums/hh_monster")
local HH_EQUIP_ENCHANT = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_EQUIP_ENCHANT["HH_EQUIP_BUFF_LIST"]
local HH_BOSS_LIST = HH_PREFAB_LIST["boss_monster"]
local HH_ELITE_LIST = HH_PREFAB_LIST["elite_monster"]
local HH_MONSTER_EFFECTS = HH_EFFECT_CONFIG["monster"]
--装备掉落表
local DROP_EQUIP_LIST = HH_PREFAB_LIST["drop_equip"]
local HH_DROP_EQUIP_CHANCE = TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]
--宝箱怪相关指定强化
local HH_TREASURE = require("enums/hh_treasure_monster")
local TreasureConfig = HH_TREASURE["TREASURE_MONSTER_CONFIG"]
local hh_type_list = {
    ["common_monster"] = true,
    ["elite_monster"] = true,
    ["boss_monster"] = true,
}
local function getFirstEffect()
    local hh_new_table = HH_UTILS:HHCopyTable(HH_MONSTER_EFFECTS)
    local hh_effects = {}
    for i, v in pairs(hh_new_table) do
        hh_effects[i] = 0
    end
    return hh_effects
end
local function getMonsterType(prefab)
    if not HH_UTILS:IsHHType(prefab, "string") then
        return "common_monster"
    end
    if HH_BOSS_LIST[prefab] then
        return "boss_monster"
    elseif HH_ELITE_LIST[prefab] then
        return "elite_monster"
    else
        return "common_monster"
    end
end
----
---刷新血量上限
---
local function refreshMaxHealth(inst, health_percent)
    if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
        if not inst["components"]["health"]["hh_base_max"] or inst["components"]["health"]["hh_base_max"] <= 0 then
            --print("未识别到血量媒介")
            return
        end
        local old_percent = inst["components"]["health"]:GetPercent()
        if HH_UTILS:IsHHType(health_percent, "number") and health_percent > 0 then
            old_percent = health_percent
        end
        if old_percent <= 0 then
            --print("血量比例为0！！！！！")
            return
        end
        local base_max_health = inst["components"]["health"]["hh_base_max"]
        local hh_extra_health = inst["components"]["hh_monster"]:GetEffectValueByKey("addMaxHealthNum")
        local hh_extra_health_percent = inst["components"]["hh_monster"]:GetEffectValueByKey("addMaxHealthPercent")
        --每日加成的血量
        local day_add_health = inst["components"]["hh_monster"]:GetSpecialValue("day_add_health")
        local world_day = TheWorld and TheWorld["state"] and TheWorld["state"]["cycles"] or 0
        --最高两百天
        local hh_day_extra_health = day_add_health * math["min"](world_day, TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"])
        --print(inst, base_max_health, hh_extra_health, hh_extra_health_percent)
        inst["components"]["health"]["maxhealth"] = (base_max_health + hh_extra_health + hh_day_extra_health) * (1 + hh_extra_health_percent / 100)
        inst["components"]["health"]:SetPercent(math["min"](old_percent, 1))
    end
end
----
---获取初始化 每增加一天 增加的血量上限
local function getFirstDayHealth(inst)
    if not inst or not inst["prefab"] then
        return 0
    end
    local hh_monster_type = HH_UTILS:GetMonsterType(inst) or getMonsterType(inst["prefab"])
    if not TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][hh_monster_type] then
        return 0
    end
    local min_ran = TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][hh_monster_type]["min"] or 1
    local max_ran = TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][hh_monster_type]["max"] or 10
    return math["random"](min_ran, max_ran)
end
----
---死亡掉落奖励和武器
---
local function Death(inst, data)
    if HH_UTILS:HasComponents(inst, "hh_monster") then
        inst["components"]["hh_monster"]:StartDeadFn()
        inst["components"]["hh_monster"]:DropEquipByDead(data and data["afflicter"] or nil)
        --HH_UTILS:SpawnExplodeFx(inst)
    end
end
local function launchitem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
end

local function UpdateDayEffect(inst, data)
    --HH_UTILS:HHPrint(data)
    if not inst or not TheWorld or not TheWorld["state"]
            or not TheWorld["state"]["cycles"]
            or not HH_UTILS:IsHHType(TheWorld["state"]["cycles"], "number")
    then
        --print("每日增加血量属性失败")
        return
    end
    if not HH_UTILS:HasComponents(inst, "hh_monster") then

    end
    local hh_monster_type = HH_UTILS:GetMonsterType(inst) or getMonsterType(inst["prefab"])
    local add_limit = TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][hh_monster_type] or TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    local day_add_num = math["floor"](TheWorld["state"]["cycles"] / TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"]) + 1
    local base_num = TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"]
    local end_limit_num = math["min"](add_limit, base_num + day_add_num)
    local current_buff_num = inst["components"]["hh_monster"]:GetAllBuffNum()
    --print("应该有的词条", end_limit_num, "实际:", current_buff_num)
    if current_buff_num < end_limit_num then
        local offset_num = end_limit_num - current_buff_num
        for i = 1, offset_num do
            inst["components"]["hh_monster"]:AddBuffByName()
        end
    end
    refreshMaxHealth(inst)
end

----
---生成激光
---
local function spawnLaser(inst)
    local numsteps = 10
    local nowDays = 0
    local base_damage = 50
    local spawn_num = 1--激光个数
    if TheWorld["state"] and TheWorld["state"]["cycles"] then
        nowDays = TheWorld["state"]["cycles"]
        --最长20
        numsteps = numsteps + math["min"](math["floor"](nowDays / 10), 10)
        if nowDays > 60 then
            spawn_num = 5
            base_damage = 150
        elseif nowDays > 30 then
            base_damage = 100
            spawn_num = 3
        end
    end
    for ii = 1, spawn_num do
        local hh_angle = inst["Transform"]:GetRotation() + 90
        if spawn_num == 3 then
            if ii == 1 then
                hh_angle = hh_angle + 45
            elseif ii == 3 then
                hh_angle = hh_angle - 45
            end
        elseif spawn_num == 5 then
            if ii == 1 then
                hh_angle = hh_angle + 60
            elseif ii == 2 then
                hh_angle = hh_angle + 30
            elseif ii == 4 then
                hh_angle = hh_angle - 30
            elseif ii == 5 then
                hh_angle = hh_angle - 60
            end
        end
        local x, y, z = inst["Transform"]:GetWorldPosition()
        local angle = hh_angle * DEGREES
        local step = 0.75
        local offset = 2 - step --should still hit players right up against us
        local ground = TheWorld["Map"]
        local targets, skiptoss = {}, {}
        local i = -1
        local noground = false
        local fx, dist, delay, x1, z1
        while i < numsteps do
            i = i + 1
            dist = i * step + offset
            delay = math["max"](0, i - 1)
            x1 = x + dist * math["sin"](angle)
            z1 = z + dist * math["cos"](angle)
            if not ground:IsPassableAtPoint(x1, 0, z1) then
                if i <= 0 then
                    return
                end
                noground = true
            end
            fx = SpawnPrefab(i > 0 and "hh_deerclops_laser" or "hh_deerclops_laserempty")
            --根据天数修改伤害
            if HH_UTILS:HasComponents(fx, "combat") then
                fx["components"]["combat"]:SetDefaultDamage(base_damage)
            end
            --fx["caster"] = inst
            fx["Transform"]:SetPosition(x1, 0, z1)
            fx:Trigger(delay * FRAMES, targets, skiptoss)
            if i == 0 then
                ShakeAllCameras(CAMERASHAKE["FULL"], 0.7, 0.02, 0.6, fx, 30)
            end
            if noground then
                break
            end
        end

        if i < numsteps then
            dist = (i + 0.5) * step + offset
            x1 = x + dist * math["sin"](angle)
            z1 = z + dist * math["cos"](angle)
        end
        fx = SpawnPrefab("hh_deerclops_laser")
        fx["Transform"]:SetPosition(x1, 0, z1)
        fx:Trigger((delay + 1) * FRAMES, targets, skiptoss)

        fx = SpawnPrefab("hh_deerclops_laser")
        fx["Transform"]:SetPosition(x1, 0, z1)
        fx:Trigger((delay + 2) * FRAMES, targets, skiptoss)
    end
end
----
---攻击目标
---
local function onhitother(inst, data)
    if not HH_UTILS:HasComponents(inst, "hh_monster") then
        return
    end
    if data and data["target"] and HH_UTILS:NotIsDead(data["target"]) then
        local hh_target = data["target"]
        --免疫中毒无法增加毒素
        if HH_UTILS:HasComponents(hh_target, "hh_buff") then
            if not HH_UTILS:HasComponents(hh_target, "hh_player")
                    or not hh_target["components"]["hh_player"]:HasSpecialEffect("immunePoison")
            then
                local atk_chance_add_poison = inst["components"]["hh_monster"]:GetEffectValueByKey("atkChanceAddPoison")
                local random_num = math["random"](1, 100)
                if random_num <= atk_chance_add_poison then
                    hh_target["components"]["hh_buff"]:AddBuff("poison", 480)
                end
            end
            --制裁效果
            local add_suppress_add_health = inst["components"]["hh_monster"]:GetEffectValueByKey("addSuppressAddHealth")
            local suppress_random = math["random"](1, 100)
            if suppress_random <= add_suppress_add_health then
                if HH_UTILS:HasComponents(hh_target, "hh_monster") then
                    hh_target["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
                elseif HH_UTILS:HasComponents(hh_target, "hh_player") then
                    hh_target["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 20)
                end
            end

            local atk_chance_reduce_speed = inst["components"]["hh_monster"]:GetEffectValueByKey("atkChanceReduceSpeed")
            local speed_random = math["random"](1, 100)
            if speed_random <= atk_chance_reduce_speed then
                hh_target["components"]["hh_buff"]:AddBuff("reduce_speed", 10)
            end
            --脆甲
            local atk_reduce_armor_chance = inst["components"]["hh_monster"]:GetEffectValueByKey("atkAddArmorReduceBuff")
            local armor_random = math["random"](1, 100)
            if armor_random <= atk_reduce_armor_chance then
                hh_target["components"]["hh_buff"]:AddBuff("add_armor_consume", 180)
            end
        end
        if HH_UTILS:HasComponents(hh_target, "freezable") then
            local atk_chance_add_freeze = inst["components"]["hh_monster"]:GetEffectValueByKey("atkChanceAddFreeze")
            local random_num = math["random"](1, 100)
            if random_num <= atk_chance_add_freeze then
                hh_target["components"]["freezable"]:Freeze(2)
            end
        end
        if inst["components"]["hh_monster"]:HasSpecialEffect("iceLaser") then
            if inst["iceLaserCd"] then
                --print("激光cd")
                return
            end
            HH_UTILS:HHKillTask(inst, "iceLaserCdTask")
            spawnLaser(inst)
            inst["iceLaserCd"] = true
            inst["iceLaserCdTask"] = inst:DoTaskInTime(5, function()
                inst["iceLaserCd"] = false
            end)

        end
    end
end
----
---简单的参数校验 0-100
local function getRandomBool(inst, key)
    local key_value = inst["components"]["hh_monster"]:GetEffectValueByKey(key)
    if not key_value then
        return false
    end
    local random_num = math["random"](1, 100)
    if random_num <= key_value then
        return true
    end
    return false
end
----
---受到攻击
---
local function attacked(inst, data)
    if not HH_UTILS:HasComponents(inst, "hh_monster") then
        return
    end
    if data and data["attacker"] and HH_UTILS:NotIsDead(data["attacker"]) then
        local hh_attacker = data["attacker"]
        if HH_UTILS:HasComponents(hh_attacker, "hh_buff") then
            if not HH_UTILS:HasComponents(hh_attacker, "hh_player")
                    or not hh_attacker["components"]["hh_player"]:HasSpecialEffect("immunePoison")
            then
                local hit_chance_add_poison = inst["components"]["hh_monster"]:GetEffectValueByKey("hitChanceAddPoison")
                local random_num = math["random"](1, 100)
                if random_num <= hit_chance_add_poison then
                    hh_attacker["components"]["hh_buff"]:AddBuff("poison", 480)
                end
            end
            --制裁效果
            local hit_suppress_add_health = inst["components"]["hh_monster"]:GetEffectValueByKey("hitSuppressAddHealth")
            local suppress_random = math["random"](1, 100)
            if suppress_random <= hit_suppress_add_health then
                if HH_UTILS:HasComponents(hh_attacker, "hh_monster") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
                elseif HH_UTILS:HasComponents(hh_attacker, "hh_monster") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 20)
                end
            end
            --概率减速
            local hit_chance_reduce_speed = inst["components"]["hh_monster"]:GetEffectValueByKey("hitChanceReduceSpeed")
            local speed_random = math["random"](1, 100)
            if speed_random <= hit_chance_reduce_speed then
                hh_attacker["components"]["hh_buff"]:AddBuff("reduce_speed", 10)
            end
            --受击增加温差buff
            if HH_UTILS:HasComponents(hh_attacker, "temperature") then
                if getRandomBool(inst, "addColdBuffValue") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("add_cold", 30)
                end
                if getRandomBool(inst, "addHotBuffValue") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("add_hot", 30)
                end
            end
        end
        if HH_UTILS:HasComponents(hh_attacker, "freezable") then
            local hit_chance_add_freeze = inst["components"]["hh_monster"]:GetEffectValueByKey("hitChanceAddFreeze")
            local random_num = math["random"](1, 100)
            if random_num <= hit_chance_add_freeze then
                hh_attacker["components"]["freezable"]:Freeze(2)
            end
        end
        --受击加潮湿度
        if HH_UTILS:HasComponents(hh_attacker, "moisture") then
            local hit_add_moisture = inst["components"]["hh_monster"]:GetEffectValueByKey("hitAddMoisture")
            local random_num = math["random"](1, 100)
            if random_num <= hit_add_moisture then
                hh_attacker["components"]["moisture"]:DoDelta(20)
            end
        end
    end
end
----
---获取精品词条
---
local function GetGoodEffect()
    local hh_table = {}
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if v and not v["can_add"] and not v["is_suit"] then
            table["insert"](hh_table, i)
        end
    end
    return hh_table
end
----
---生成精品附魔石方法
---
local function SpawnSpecialStone(inst, monster_type, attacker)
    if not inst or not inst["Transform"]
            or not (monster_type == "elite_monster" or monster_type == "boss_monster")
    then
        return
    end
    --世界限制
    if not HH_UTILS:CheckWorldLimit("stone") then
        return
    end

    local good_list = HHGetGoodEquipEffect()
    local good_random = math["random"](1, #good_list)
    if good_list and #good_list > 0 then
        local hh_stone = SpawnPrefab("hh_effect_stone")
        if hh_stone then
            hh_stone["hh_effect"] = good_list[good_random]
            if TheNet and hh_stone["hh_effect"] and HH_EQUIP_BUFF_LIST[hh_stone["hh_effect"]] then
                --增加公告播报
                local inst_name = inst["name"] or STRINGS["NAMES"][string["upper"](inst["prefab"])]
                local hh_gem_str = HH_EQUIP_BUFF_LIST[hh_stone["hh_effect"]]["name"]
                TheNet:Announce(string["format"]("%s掉落极品附魔石-%s", tostring(inst_name), tostring(hh_gem_str)))
            end
            local angle = math["random"](1, 360)
            local x, y, z = inst["Transform"]:GetWorldPosition()
            hh_stone["Transform"]:SetPosition(x, 2.5, z)
            launchitem(hh_stone, angle)
            if hh_stone["HH_Update_Server"] then
                hh_stone:HH_Update_Server()
            end
            HH_UTILS:UpdateSkinItem(attacker, hh_stone)
            HH_UTILS:DoDeltaWorldLimit("stone", 1)
        end
    end
end
----
---生成精品附魔石方法
---
local function SpawnRemoveStone(inst, monster_type)
    if not inst or not inst["Transform"] then
        return
    end
    local hh_stone = SpawnPrefab("hh_remove_stone")
    if hh_stone then
        local angle = math["random"](1, 360)
        local x, y, z = inst["Transform"]:GetWorldPosition()
        hh_stone["Transform"]:SetPosition(x, 2.5, z)
        launchitem(hh_stone, angle)
    end
end
local function SpawnPoop(inst)
    if not inst or not inst["Transform"] then
        return
    end
    local hh_poop = SpawnPrefab("poop")
    if hh_poop then
        local angle = math["random"](1, 360)
        local x, y, z = inst["Transform"]:GetWorldPosition()
        hh_poop["Transform"]:SetPosition(x, 2.5, z)
        launchitem(hh_poop, angle)
    end
end

local function SpawnEquip(inst, monster_type)
    if not HH_DROP_EQUIP_CHANCE[monster_type] or not TUNING["HH_CAN_DROP_EQUIP"] then
        return
    end
    --世界限制
    if not HH_UTILS:CheckWorldLimit("equip") then
        return
    end

    local drop_chance = math["random"]()
    if drop_chance > HH_DROP_EQUIP_CHANCE[monster_type] then
        return
    end
    local all_num = #DROP_EQUIP_LIST
    local random_num = math["random"](1, all_num)
    if not DROP_EQUIP_LIST[random_num]["id"] then
        return
    end
    local ran_equip_name = DROP_EQUIP_LIST[random_num]["id"]
    local hh_equip = SpawnPrefab(ran_equip_name)
    if hh_equip and hh_equip["Physics"] then
        if HH_UTILS:HasComponents(hh_equip, "hh_equip") then
            local effect_num = 1
            local add_effect_chance = math["random"]()
            if add_effect_chance < 0.5 then
                effect_num = 1
            elseif add_effect_chance < 0.8 then
                effect_num = 2
            else
                effect_num = 3
            end
            for i = 1, effect_num do
                hh_equip["components"]["hh_equip"]:AddEquipBuff(nil)
            end
            local add_gem_chance = 0.1
            local math_gem = math["random"]()
            if math_gem <= add_gem_chance then
                local gem_num = math["random"](1, 2)
                for i = 1, gem_num do
                    hh_equip["components"]["hh_equip"]:AddGemCurrentLimit()
                end
            end
        end
        local angle = math["random"](1, 360)
        local x, y, z = inst["Transform"]:GetWorldPosition()
        hh_equip["Transform"]:SetPosition(x, 4.5, z)
        launchitem(hh_equip, angle)
        HH_UTILS:DoDeltaWorldLimit("equip", 1)
    end
end

local function SpawnEquipGif(inst, monster_type)
    if not inst or not inst["Transform"]
            or not (monster_type == "elite_monster" or monster_type == "boss_monster")
    then
        return
    end
    local hh_gift = SpawnPrefab("gift")
    if hh_gift and hh_gift["Physics"] and HH_UTILS:HasComponents(hh_gift, "unwrappable") then
        local equip_list = {}
        for i = 1, 4 do
            local all_equip = #DROP_EQUIP_LIST
            local random_equip = math["random"](1, all_equip)
            local equip_name = DROP_EQUIP_LIST[random_equip]["id"]
            local hh_equip = SpawnPrefab(equip_name)
            if hh_equip and HH_UTILS:HasComponents(hh_equip, "hh_equip") then
                hh_equip["components"]["hh_equip"]:AddGifEquipBuff()
                table["insert"](equip_list, hh_equip)
            end
        end
        if #equip_list > 0 then
            hh_gift["components"]["unwrappable"]:WrapItems(equip_list)
            --修复武器生成原点bug
            for i, v in ipairs(equip_list) do
                if v and v["Remove"] then
                    v:Remove()
                end
            end
        end
        local angle = math["random"](1, 360)
        local x, y, z = inst["Transform"]:GetWorldPosition()
        hh_gift["Transform"]:SetPosition(x, 2.5, z)
        launchitem(hh_gift, angle)
        if TheNet then
            --增加公告播报
            local inst_name = inst["name"] or STRINGS["NAMES"][string["upper"](inst["prefab"])]
            TheNet:Announce(string["format"]("%s掉落特殊装备包裹", tostring(inst_name)))
        end
    end
end
--词条上限数量
local MAX_EFFECT_NUM = 10
local HH_COMPONENT = Class(function(self, inst)
    self["inst"] = inst
    self["hh_monster_type"] = nil--用于其他mod兼容词条
    --登记词条 格式 {{name="",value=""},{name="",value=""},}
    self["hh_buffs"] = {}
    --属性
    self["hh_effects"] = getFirstEffect()
    --特殊参数
    self["special_data"] = {
        ["health_percent"] = nil,
        ["day_add_health"] = getFirstDayHealth(self["inst"]),
    }
    --------------------------宝藏怪---------------------------
    --是否不限制词条上限
    self["max_effect_limit"] = 0
    --设置宝藏类强化对应id
    self["treasure_id"] = nil
    --------------------------宝藏怪---------------------------
    --延迟一帧刷新血量属性和初始化词条
    self["inst"]:DoTaskInTime(0, function()
        self:AddFirstBuffs()
        refreshMaxHealth(self["inst"], self["special_data"]["health_percent"])
    end)
    self["inst"]:ListenForEvent("death", Death)
    --每日监听
    self["inst"]:WatchWorldState("cycles", UpdateDayEffect)
    self["inst"]:ListenForEvent("onhitother", onhitother)
    self["inst"]:ListenForEvent("attacked", attacked)
    --不需要带当前百分比
    self["inst"]:ListenForEvent("hh_change_max_health", refreshMaxHealth)
    self["inst"]:ListenForEvent("hh_monster_buff_health", refreshMaxHealth)
end)
--增加查询标签方法
local function HasHHTagFn(inst, tag_name)
    if not HH_UTILS:IsHHType(tag_name, "string")
            or not inst["hh_tags"]
            or not HH_UTILS:IsHHType(inst["hh_tags"], "table")
    then
        return false
    end
    return inst["hh_tags"][tag_name] ~= nil
end
--是否破除词条数量上限
function HH_COMPONENT:SetMaxEffectLimit(num)
    self["max_effect_limit"] = tonumber(num) or 0
end
--设置宝箱怪强化
function HH_COMPONENT:SetTreasureId(t_id)
    if TreasureConfig[t_id] then
        self["treasure_id"] = tostring(t_id)
        --增加初始函数--重载也会执行这边代码
        if TreasureConfig[t_id]["start_fn"] then
            TreasureConfig[t_id]["start_fn"](self["inst"])
        end
    end
end
----
---设置怪物类型
---
function HH_COMPONENT:SetMonsterType(hh_type, type_name)
    if not self["inst"] or not HH_UTILS:IsHHType(hh_type, "string")
            or not hh_type_list[hh_type]
    then
        return
    end
    self["hh_monster_type"] = hh_type
    if not self["inst"]["hh_tags"] then
        self["inst"]["hh_tags"] = {}
    end
    self["inst"]["hh_tags"][hh_type] = type_name or "未定义名称"
    if not self["inst"]["HasHHTag"] then
        self["inst"]["HasHHTag"] = HasHHTagFn
    end
end
----
---设置标签+名字
---
function HH_COMPONENT:SetTagType(type_id, type_name)
    if not HH_UTILS:IsHHType(type_id, "string")
            or not HH_UTILS:IsHHType(type_name, "string")
    then
        return
    end
    if not self["inst"]["hh_tags"] then
        self["inst"]["hh_tags"] = {}
    end
    self["inst"]["hh_tags"][type_id] = type_name
end
function HH_COMPONENT:GetMonsterType()
    return self["hh_monster_type"]
end
----
---初始化增加buff
---
function HH_COMPONENT:AddFirstBuffs()
    if not TheWorld or not TheWorld["state"]
            or not TheWorld["state"]["cycles"]
            or not HH_UTILS:IsHHType(TheWorld["state"]["cycles"], "number")
            or #self["hh_buffs"] > 0
    then
        return
    end
    if not self["inst"] or not self["inst"]["prefab"] then
        return
    end
    local hh_monster_type = HH_UTILS:GetMonsterType(self["inst"]) or getMonsterType(self["inst"]["prefab"])
    local add_limit = TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][hh_monster_type] or TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    local add_num = math["floor"](TheWorld["state"]["cycles"] / TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"]) + 1
    --最低三条 血量必带
    add_num = math["max"](TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"], add_num)
    local end_add_num = math["min"](add_num, add_limit)
    --print(self["inst"], "初始化词条数量", end_add_num)
    --血量是必会加成的
    self:AddBuffByName("addMaxHealthNum")
    end_add_num = end_add_num - 1
    if end_add_num > 0 then
        for i = 1, end_add_num do
            --添加随机buff
            self:AddBuffByName()
        end
    end
end

----
---每次日期变化时 更新增加的生命上限加成
---
function HH_COMPONENT:GetSpecialValue(hh_key)
    if self["special_data"] and HH_UTILS:IsHHType(self["special_data"][hh_key], "number")
            and self["special_data"][hh_key] > 0
    then
        return self["special_data"][hh_key]
    end
    return 0
end

function HH_COMPONENT:HasBuffByName(buff_name)
    for i, v in ipairs(self["hh_buffs"]) do
        if v and v["name"] == buff_name then
            return true
        end
    end
    return false
end
----
---获取拥有的词条数量
---
function HH_COMPONENT:GetAllBuffNum()
    return #self["hh_buffs"]
end
----
---获取可以增加的buff
---
function HH_COMPONENT:GetCanAddBuffs()
    if not self["inst"] or not self["inst"]["prefab"] then
        return {}
    end
    local hh_monster_type = HH_UTILS:GetMonsterType(self["inst"]) or getMonsterType(self["inst"]["prefab"])
    local all_buff_list = HH_MONSTER_BUFFS[hh_monster_type]
    if not HH_UTILS:IsHHType(all_buff_list, "table") then
        return {}
    end
    local table_sort = HH_UTILS:TableSortKeys(all_buff_list)
    if #table_sort <= 0 then
        return {}
    end
    local hh_table = {}
    for i, v in ipairs(table_sort) do
        if v and all_buff_list[v] then
            local effect_config = all_buff_list[v]
            local hh_can_add = true
            --词条增加校验
            if effect_config["check_fn"] then
                hh_can_add = effect_config["check_fn"](self["inst"])
            end
            if hh_can_add then
                if all_buff_list[v]["only_one"] then
                    if not self:HasBuffByName(v) then
                        table["insert"](hh_table, v)
                    end
                else
                    table["insert"](hh_table, v)
                end
            end
        end
    end
    --HH_UTILS:HHPrint(hh_table)
    return hh_table
end
----
---增加buff
---
function HH_COMPONENT:AddBuffByName(buff_name, value)
    if not self["inst"] or not self["inst"]["prefab"] then
        return false, "生物增加强化词条失败:入参错误"
    end
    if buff_name and not HH_UTILS:IsHHType(buff_name, "string") then
        return false, "生物增加强化词条失败:词条传参错误！！"
    end
    local hh_add_buff = buff_name
    if not hh_add_buff then
        local can_add_buffs = self:GetCanAddBuffs()
        if not can_add_buffs or #can_add_buffs <= 0 then
            return false, "生物增加强化词条失败:未找到可用词条，跳过"
        end
        local random_index = math["random"](1, #can_add_buffs)
        hh_add_buff = can_add_buffs[random_index]
        --print("生物强化-随机增加的附魔词条", hh_add_buff)
    end
    local hh_prefab = self["inst"]["prefab"]
    local hh_monster_type = HH_UTILS:GetMonsterType(self["inst"]) or getMonsterType(hh_prefab)
    local all_buff_list = HH_MONSTER_BUFFS[hh_monster_type]
    if not HH_UTILS:IsHHType(all_buff_list, "table") or not all_buff_list[hh_add_buff] then
        return false, "词条名字错误!!!"
    end
    --校验是否词条达到上限
    local add_limit = TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][hh_monster_type] or TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    --破除上限
    if HH_UTILS:IsHHType(self["max_effect_limit"], "number") and self["max_effect_limit"] > add_limit then
        --print("词条破除上限", self["inst"],self["max_effect_limit"] )
        add_limit = self["max_effect_limit"]
    end
    local current_buff_num = self:GetAllBuffNum()
    if current_buff_num >= add_limit then
        return false, "当前已达最大词条上限，词条增加失败"
    end

    local buff_config = all_buff_list[hh_add_buff]
    if buff_config["only_one"] and self:HasBuffByName(hh_add_buff) then
        return false, "此词条一个生物只允许拥有一条!!!"
    end
    if buff_config["check_fn"] then
        local check_result = buff_config["check_fn"](self["inst"])
        if not check_result then
            return false, "当前生物无法添加该词条"
        end
    end
    local buff_value = nil
    if value then
        buff_value = value
    else
        if buff_config["rangeValue"] and buff_config["rangeValue"]["min"]
                and buff_config["rangeValue"]["max"] then
            buff_value = math["random"](buff_config["rangeValue"]["min"], buff_config["rangeValue"]["max"])
        end
    end
    table["insert"](self["hh_buffs"], { ["name"] = hh_add_buff, ["value"] = buff_value, })
    if buff_config["start_fn"] then
        buff_config["start_fn"](self["inst"], buff_value)
    end
    --刷新参数
    self:RefreshSpecialFn()
    return true, "增加词条成功!"
end
----
---每次属性变化时 刷新一下相关的参数 类似移速这些
---
function HH_COMPONENT:RefreshSpecialFn()
    --刷新移速
    if HH_UTILS:HasComponents(self["inst"], "locomotor") then
        local hh_add_speed = self:GetEffectValueByKey("addSpeedPercent")
        if hh_add_speed > 0 then
            self["inst"]["components"]["locomotor"]:SetExternalSpeedMultiplier(self["inst"], "hh_monster_speed", math["max"](hh_add_speed / 100 + 1, 1))
        else
            self["inst"]["components"]["locomotor"]:RemoveExternalSpeedMultiplier(self["inst"], "hh_monster_speed")
        end
    end
end
----
---死亡触发词条end_fn函数
function HH_COMPONENT:StartDeadFn()
    for i, v in ipairs(self["hh_buffs"]) do
        if v and v["name"] and HH_MONSTER_BUFFS[v["name"]]
                and HH_MONSTER_BUFFS[v["name"]]["end_fn"]
        then
            HH_MONSTER_BUFFS[v["name"]]["end_fn"](self["inst"], v["value"])
        end
    end
end
---------------------------------------------------------------------------------------
----
---获取属性值
---
function HH_COMPONENT:GetEffectValueByKey(key)
    if not self["hh_effects"] or not self["hh_effects"][key] then
        return 0
    end
    local effect_value = self["hh_effects"][key]
    if not HH_UTILS:IsHHType(effect_value, "number") or effect_value < 0 then
        return 0
    end
    return effect_value
end
----
---处理属性值
---
function HH_COMPONENT:AddEffectValueByKey(key, hh_num)
    if not self["hh_effects"] or not self["hh_effects"][key]
            or not HH_UTILS:IsHHType(hh_num, "number")
            or hh_num <= 0
    then
        return false
    end
    self["hh_effects"][key] = self["hh_effects"][key] + hh_num
    return true
end
function HH_COMPONENT:ReduceEffectValueByKey(key, hh_num)
    if not self["hh_effects"] or not self["hh_effects"][key]
            or not HH_UTILS:IsHHType(hh_num, "number")
            or hh_num <= 0
    then
        return false
    end
    self["hh_effects"][key] = math["max"](self["hh_effects"][key] - hh_num, 0)
    return true
end
----
---一些特殊属性 值大于0就算生效
---
function HH_COMPONENT:HasSpecialEffect(effect_name)
    local special_value = self:GetEffectValueByKey(effect_name)
    return special_value > 0
end
----
---受到的反甲效果
---
function HH_COMPONENT:GetHitByBrambleFxDamage(amount)
    if not HH_UTILS:IsHHType(amount, "number") or amount <= 0 then
        return 0
    end
    --减伤
    local reduceAttackedDamage = self:GetEffectValueByKey("reduceAttackedDamage")
    amount = amount - reduceAttackedDamage
    return math["max"](amount, 0)
end

----
---造成的伤害进行数值转换
---
function HH_COMPONENT:DoAttackDamage(monster, target, amount)
    if not HH_UTILS:IsHHType(amount, "number") or amount <= 0 then
        return 0
    end
    if not HH_UTILS:NotIsDead(monster) then
        return amount
    end
    --固定增伤
    local add_com_damage = self:GetEffectValueByKey("addComDamageNum")
    amount = amount + add_com_damage
    if TheWorld and TheWorld["state"] then
        if TheWorld["state"]["isday"] then
            --阳光打击
            local sunlight_strike = self:GetEffectValueByKey("sunlightStrike")
            amount = amount + sunlight_strike
        elseif TheWorld["state"]["isdusk"] then
            --余晖打击
            local afterglow_strike = self:GetEffectValueByKey("afterglowStrike")
            amount = amount + afterglow_strike
        elseif TheWorld["state"]["isnight"] then
            --暗夜痛击
            local night_menace = self:GetEffectValueByKey("nightMenace")
            amount = amount + night_menace
        end
    end
    local all_add_percent = 0
    --伤害加成
    local add_com_damage_percent = self:GetEffectValueByKey("addComDamagePercent")
    all_add_percent = all_add_percent + add_com_damage_percent
    amount = amount * (1 + all_add_percent / 100)
    --暴击率
    local criticalHitRate = self:GetEffectValueByKey("criticalHitRate")
    if HH_UTILS:HasComponents(self["inst"], "follower")
            and self["inst"]["components"]["follower"]["leader"]
            and HH_UTILS:HasComponents(self["inst"]["components"]["follower"]["leader"], "hh_player")
    then
        local hh_leader = self["inst"]["components"]["follower"]["leader"]
        if hh_leader["components"]["hh_player"]:HasSpecialEffect("addFollowCritical") then
            local player_extra = hh_leader["components"]["hh_player"]:GetEffectValueByKey("addFollowCritical")
            criticalHitRate = criticalHitRate + player_extra
            --print("含有额外暴击", criticalHitRate, player_extra)
        end
    end
    if criticalHitRate > 0 then
        local random_num = math["random"](0, 100)
        if random_num <= criticalHitRate then
            --额外暴击效果
            local criticalHitEffect = self:GetEffectValueByKey("criticalHitEffect")
            amount = amount * (2 + criticalHitEffect / 100)
        end
    end
    -------------------------特殊效果buff-----------------------------------
    if HH_UTILS:HasComponents(target, "hh_buff") then
        local add_target_chance = self:GetEffectValueByKey("addTargetDamage")
        if add_target_chance > 0 then
            local chance_add_damage = math["random"](1, 100)
            if chance_add_damage <= add_target_chance then
                target["components"]["hh_buff"]:AddBuff("monster_add_target_damage", 30)
            end
        end
    end
    -------------------------特殊效果buff-----------------------------------
    return amount
end
----
---受到的伤害进行数值转换
---
function HH_COMPONENT:GetBlockDamage(player, attacker, amount)
    if not HH_UTILS:IsHHType(amount, "number") or amount <= 0 then
        return 0
    end

    --护盾
    local hh_chance_num = self:GetEffectValueByKey("replaceDamageChance")
    if hh_chance_num > 0 then
        local random_san = math["random"](1, 100)
        if random_san <= hh_chance_num then
            HH_UTILS:SpawnShadowFx(player)
            HH_UTILS:SpawnClientStrFx(self["inst"], "格挡")
            return 0
        end
    end

    if not HH_UTILS:NotIsDead(player) then
        return amount
    end
    --受击减免
    local hh_reduceAttackedDamage = self:GetEffectValueByKey("reduceAttackedDamage")
    amount = amount - hh_reduceAttackedDamage
    ----------------处理时段类减伤------------------------------------
    if TheWorld and TheWorld["state"] then
        if TheWorld["state"]["isday"] then
            local reduce_sunlight_damage = self:GetEffectValueByKey("reduceSunlightDamage")
            amount = amount - reduce_sunlight_damage
        elseif TheWorld["state"]["isdusk"] then
            local reduce_afterglow_damage = self:GetEffectValueByKey("reduceAfterglowDamage")
            amount = amount - reduce_afterglow_damage
        elseif TheWorld["state"]["isnight"] then
            local reduce_night_damage = self:GetEffectValueByKey("reduceNightDamage")
            amount = amount - reduce_night_damage
        end
    end
    ----------------处理时段类减伤------------------------------------
    ----百分比减伤 放最后面
    local hhReducePercentDamage = self:GetEffectValueByKey("reducePercentDamage")
    if hhReducePercentDamage > 0 then
        amount = amount * (1 - math["min"](hhReducePercentDamage / 100, 0.8))
    end
    if HH_UTILS:HasComponents(attacker, "combat") then
        --local hh_weapon = attacker["components"]["combat"]:GetWeapon()
        --fuck盾反
        --if HH_UTILS:HasComponents(hh_weapon, "shieldlegion") then
        --    --print("盾反免疫反伤")
        --else
        --固定反伤
        local hh_reflexiveInjury = self:GetEffectValueByKey("reboundDamageNum")
        if hh_reflexiveInjury > 0 then
            if attacker["components"]["combat"]["GetBrambleFx"] then
                attacker["components"]["combat"]:GetBrambleFx(player, hh_reflexiveInjury)
            end
        end
        --开t秒不死你
        local hh_reboundDamagePercent = self:GetEffectValueByKey("reboundDamagePercent")
        if hh_reboundDamagePercent > 0 then
            if attacker["components"]["combat"]["GetBrambleFx"] then
                attacker["components"]["combat"]:GetBrambleFx(player, amount * hh_reboundDamagePercent / 100)
            end
        end
        --end
    end
    ----------------宝藏怪免疫远程攻击----------------
    local self_monster = self["inst"]
    if self_monster["hh_is_treasure_boss"] and HH_UTILS:NotIsDead(attacker) and attacker["Transform"]
            and HH_UTILS:NotIsDead(self_monster) and self_monster["Transform"]
    then
        local p_x, p_y, p_z = attacker["Transform"]:GetWorldPosition()
        local m_x, m_y, m_z = self_monster["Transform"]:GetWorldPosition()
        local distance_num = HH_UTILS:GetDistance(p_x, p_z, m_x, m_z)
        --print("宝藏怪", amount, "距离", distance_num)
        distance_num = math["abs"](distance_num)
        if distance_num > 5 then
            amount = 0
        end
    end
    --超级坎普斯限制伤害最大为1010
    if self_monster["hh_is_treasure_kps"] then
        amount = math["min"](amount, 1010)
    end
    ----------------宝藏怪免疫远程攻击----------------
    return math["max"](amount, 0)
end
----
---处理吸血和吸san
---
function HH_COMPONENT:HandleBloodSuck(amount)
    if HH_UTILS:NotIsDead(self["inst"]) then
        local health_delta = math["abs"](amount)
        local hh_blood_suck = self["inst"]["components"]["hh_monster"]:GetEffectValueByKey("atkBlood")
        if hh_blood_suck > 0 then
            local add_health = health_delta * hh_blood_suck / 100
            --print("吸血", hh_blood_suck, "实际回血", add_health, "造成伤害:", health_delta)
            self["inst"]["components"]["health"]:DoDelta(add_health, true, "bloodSuck")
        end
    end
end
---------------------------------------------------------------------------------------
-----
---死亡概率掉落装备
---
local black_drop_list = {
    ["daywalker"] = true,
    ["daywalker2"] = true,
    ["sharkboi"] = true,
}
--异色蛋
local color_egg = {
    "hh_egg_cat_claw_orange",
    "hh_egg_cat_claw_purple",
    "hh_egg_cat_claw_green",
    "hh_egg_cat_claw_blue",
    "hh_egg_figure_blue_star",
    "hh_egg_figure_green_black",
    "hh_egg_figure_purple_black",
    "hh_egg_figure_red_black",
    "hh_egg_figure_red_blue",
    "hh_egg_figure_yellow_green",
    "hh_egg_figure_yellow_green_purple",
}
function HH_COMPONENT:DropEquipByDead(attacker)
    if not self["inst"] then
        return
    end
    local hh_prefab = self["inst"]["prefab"]
    if hh_prefab == "stalker_atrium" and self["inst"]["atriumdecay"] then
        --print("非正常死亡")
        SpawnPoop(self["inst"])
        return
    end
    --黑名单不掉装备
    if black_drop_list[hh_prefab] then
        return
    end
    ------------------------------宝藏怪单独增加逻辑--------------------------------
    if self["treasure_id"] and HH_UTILS:IsHHType(TreasureConfig[self["treasure_id"]], "table") then
        local treasure_config = TreasureConfig[self["treasure_id"]]
        if treasure_config["death_fn"] then
            treasure_config["death_fn"](self["inst"])
        end
        --禁止打包死亡动画 防止无限刷宝石
        self["inst"]:DoTaskInTime(0.1, function(_inst)
            if HH_UTILS:IsHHType(_inst, "table") and _inst["Remove"] then
                _inst:Remove()
            end
        end)
    end
    ------------------------------宝藏怪单独增加逻辑--------------------------------
    local monster_type = HH_UTILS:GetMonsterType(self["inst"]) or getMonsterType(hh_prefab)
    SpawnEquip(self["inst"], monster_type)
    --1%掉清除宝石
    --local spawn_remove_stone = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["monster_remove_chance"]
    --local random_remove = math["random"]()
    --if random_remove <= spawn_remove_stone then
    --    SpawnRemoveStone(self["inst"], monster_type)
    --end
    ------------------------------生成蛋-------------------------------
    local math_random_egg = math["random"](1, 100)
    if monster_type == "common_monster" and math_random_egg <= 3 then
        HH_UTILS:SpawnLaunchItem(self["inst"], "hh_egg_common", 1)
    elseif monster_type == "elite_monster" and math_random_egg <= 18 then
        HH_UTILS:SpawnLaunchItem(self["inst"], "hh_egg_silver", 1)
    elseif monster_type == "boss_monster" then
        if math_random_egg <= 30 then
            HH_UTILS:SpawnLaunchItem(self["inst"], "hh_egg_gold", 1)
        end
        local spawn_color_random = math["random"](1, 100)
        if spawn_color_random <= 3 then
            local random_egg_index = math["random"](1, #color_egg)
            HH_UTILS:SpawnLaunchItem(self["inst"], color_egg[random_egg_index], 1)
        end
    end
    ------------------------------生成蛋-------------------------------
    --小怪可以结束了
    if monster_type == "common_monster" then
        return
    end
    --蠕虫单独配置选项是否掉落战利品
    if hh_prefab == "worm" and not TUNING["HH_WORM_CONFIG"] then
        --print("不生成")
        return
    end
    local spawn_stone_chance = 0
    local spawn_gif_chance = 0
    if monster_type == "elite_monster" then
        spawn_stone_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_stone"]
        spawn_gif_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_gif"]
    elseif monster_type == "boss_monster" then
        spawn_stone_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_stone"]
        spawn_gif_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_gif"]
    end
    --概率生成极品附魔石或礼物
    local random_gif = math["random"]()
    local random_stone = math["random"]()
    if random_stone <= spawn_stone_chance then
        SpawnSpecialStone(self["inst"], monster_type, attacker)
    end
    if random_gif < spawn_gif_chance then
        SpawnEquipGif(self["inst"], monster_type)
    end
end

function HH_COMPONENT:OnSave()
    if HH_UTILS:HasComponents(self["inst"], "health") then
        local old_percent = self["inst"]["components"]["health"]:GetPercent()
        self["special_data"]["health_percent"] = old_percent
    else
        self["special_data"]["health_percent"] = nil
    end
    return {
        ["special_data"] = self["special_data"],
        ["hh_buffs"] = self["hh_buffs"],
        ["max_effect_limit"] = self["max_effect_limit"],
        ["treasure_id"] = self["treasure_id"],
    }
end
function HH_COMPONENT:OnLoad(data)
    if not data then
        return
    end
    --记录血量百分比 宝藏加强在这之后 防止血量回满
    self["special_data"] = data["special_data"] or {}
    -----------------------宝箱怪--------------------
    if data["treasure_id"] then
        local save_treasure_id = data["treasure_id"]
        --兼容下 重载导致血量变成百分百
        if HH_UTILS:IsHHType(self["special_data"], "table") and HH_UTILS:IsHHType(self["special_data"]["health_percent"], "number") then
            local old_health_percent = self["special_data"]["health_percent"]
            if old_health_percent > 0 and HH_UTILS:HasComponents(self["inst"], "health") then
                self["inst"]["components"]["health"]:SetPercent(old_health_percent)
            end
        end
        self:SetTreasureId(save_treasure_id)
    end
    self["max_effect_limit"] = data["max_effect_limit"] or 0
    -----------------------宝箱怪--------------------
    local hh_load_buffs = data["hh_buffs"] or {}
    for i, v in ipairs(hh_load_buffs) do
        local success, result = self:AddBuffByName(v["name"], v["value"])
        --print("加载", success, result, v["name"], self["inst"])
    end
end
function HH_COMPONENT:GetDebugString()
    local buff_str = ""
    local hh_prefab = self["inst"]["prefab"]
    local hh_monster_type = HH_UTILS:GetMonsterType(self["inst"]) or getMonsterType(hh_prefab)
    local all_buff_list = HH_MONSTER_BUFFS[hh_monster_type]
    if not HH_UTILS:IsHHType(all_buff_list, "table") then
        return "查询词条失败!!"
    end
    local buff_num = #self["hh_buffs"]
    local day_str = "每日血量加成异常"
    if self["special_data"] and self["special_data"]["day_add_health"] then
        local day_add_max_health = self["special_data"]["day_add_health"]
        local world_day = TheWorld and TheWorld["state"] and TheWorld["state"]["cycles"] or 0
        world_day = math["min"](TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"], world_day)
        day_str = string.format("血量天数加成:%s(%s*%s)", day_add_max_health * world_day, day_add_max_health, world_day)
    end
    buff_str = buff_str .. day_str
    for i, v in ipairs(self["hh_buffs"]) do
        if v and v["name"] and all_buff_list[v["name"]] then
            local buff_config = all_buff_list[v["name"]]
            local buff_value = tostring(v["value"])
            local buff_format = buff_config["name"]
            buff_str = buff_str .. "\n" .. string["format"](buff_format, buff_value)
        end
    end
    return buff_str
end
return HH_COMPONENT

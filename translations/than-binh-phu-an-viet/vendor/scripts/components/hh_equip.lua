local HH_UTILS = require("utils/hh_utils")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local HH_GEM_BUFF_LIST = HH_CONFIG["HH_GEM_BUFF_LIST"]
local HH_SUIT_LIST = HH_CONFIG["HH_SUIT_LIST"]
local max_buff_num = 4
local hh_equip_component = "hh_equip"
local function hookEquip(inst)
    --hook装备穿戴函数 使用监听的话 装备处于穿戴状态remove时 不会触发监听
    if not HH_UTILS:HasComponents(inst, "equippable") then
        return
    end
    local oldEquip = inst["components"]["equippable"]["onequipfn"]
    inst["components"]["equippable"]["onequipfn"] = function(equip, owner, ...)
        if oldEquip then
            oldEquip(equip, owner, ...)
        end
        --只对玩家生效
        if HH_UTILS:HasComponents(equip, hh_equip_component)
                and owner:IsValid() and owner:HasTag("player")
                and HH_UTILS:HasComponents(owner, "hh_buff")
        then
            equip["components"][hh_equip_component]:HandleEquipBuffToPlayer(owner, true)
        end
    end
    local oldUnequip = inst["components"]["equippable"]["onunequipfn"]
    inst["components"]["equippable"]["onunequipfn"] = function(equip, owner, ...)
        if HH_UTILS:HasComponents(equip, hh_equip_component)
                and owner:IsValid() and owner:HasTag("player")
                and HH_UTILS:HasComponents(owner, "hh_buff")
        then
            equip["components"][hh_equip_component]:HandleEquipBuffToPlayer(owner, false)
        end
        if oldUnequip then
            oldUnequip(equip, owner, ...)
        end
    end
    local oldIsInsulated = inst["components"]["equippable"]["IsInsulated"]
    inst["components"]["equippable"]["IsInsulated"] = function(self, ...)
        local result = false
        if oldIsInsulated then
            result = oldIsInsulated(self, ...)
        end
        if HH_UTILS:HasComponents(self["inst"], "hh_equip") then
            if self["inst"]["components"]["hh_equip"]:HasEffectByName("immunity_moisture") then
                result = true
            end
        end
        return result
    end

    --免疫雕像减速
    local oldGetWalkSpeedMult = inst["components"]["equippable"]["GetWalkSpeedMult"]
    inst["components"]["equippable"]["GetWalkSpeedMult"] = function(self, ...)
        local old_result = oldGetWalkSpeedMult(self, ...)
        if HH_UTILS:HasComponents(self["inst"], "inventoryitem")
                and self["inst"]["components"]["inventoryitem"]["owner"]
        then
            local player = self["inst"]["components"]["inventoryitem"]["owner"]
            if HH_UTILS:HasComponents(player, "hh_player")
                    and player["components"]["hh_player"]:HasSpecialEffect("porter")
            then
                return math["max"](1, old_result)
            end
        end
        return old_result
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
local function launchitem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
end
----
---装备被删除时有概率返还附魔石头
---
local function onRemove(inst)
    --print("装备删除")
    if HH_UTILS:HasComponents(inst, "hh_equip") and HH_UTILS:HasComponents(inst, "inventoryitem") and inst["Transform"] then
        if not HH_UTILS:HasComponents(inst, "equippable") or not inst["components"]["equippable"]:IsEquipped() then
            return
        end
        local hh_owner = inst["components"]["inventoryitem"]["owner"]
        if not hh_owner or not hh_owner["Transform"] then
            return
        end
        local x, y, z = hh_owner["Transform"]:GetWorldPosition()
        local effect_num = inst["components"]["hh_equip"]:GetEffectsNum()
        if effect_num <= 0 then
            return
        end
        --拆除的概率
        local base_chance = 0.1
        if effect_num >= 3 then
            base_chance = 1
        end
        local new_chance = math["random"]()
        if new_chance > base_chance then
            return
        end
        local random_effect_name = inst["components"]["hh_equip"]:GetRandomEffect()
        local effect_stone = SpawnPrefab("hh_effect_stone")
        --print(x, y, z)
        if effect_stone then
            effect_stone["Transform"]:SetPosition(x, 2.5, z)
            effect_stone["hh_effect"] = random_effect_name
            if effect_stone["HH_Update_Server"] then
                effect_stone:HH_Update_Server()
            end
            launchitem(effect_stone, math["random"](1, 360))
        end
    end
end
local function hookRepairCom(inst)
    if HH_UTILS:HasComponents(inst, "forgerepairable") then
        local oldOnRepaired = inst["components"]["forgerepairable"]["onrepaired"]
        if HH_UTILS:IsHHType(oldOnRepaired, "function") then
            inst["components"]["forgerepairable"]["onrepaired"] = function(inst, ...)
                local needHookEquip = false
                if not HH_UTILS:HasComponents(inst, "equippable") then
                    needHookEquip = true
                end
                oldOnRepaired(inst, ...)
                --print("修复函数")
                if needHookEquip and HH_UTILS:HasComponents(inst, "equippable") then
                    hookEquip(inst)
                end
            end
        end
    end
end
local function hookHauntable(inst)
    if HH_UTILS:HasComponents(inst, "hauntable") and HH_UTILS:HasComponents(inst, "weapon") then
        local oldOnhaunt = inst["components"]["hauntable"]["onhaunt"]
        inst["components"]["hauntable"]["onhaunt"] = function(hh_inst, doer, ...)
            if HH_UTILS:IsHHType(hh_inst["hh_can_life"], "number") and doer
                    and hh_inst["hh_can_life"] > 0
            then
                doer:PushEvent("respawnfromghost", { ["source"] = hh_inst })
            end
            if oldOnhaunt then
                return oldOnhaunt(hh_inst, doer, ...)
            end
        end
    end
end
local function getReduceArmor(damage_amount, reduce_percent)
    reduce_percent = math["max"](reduce_percent, 0)
    --todo 增加限制
    reduce_percent = math["min"](reduce_percent, 100)
    reduce_percent = (1 - reduce_percent / 100)
    damage_amount = damage_amount * reduce_percent
    return damage_amount
end
local function hookArmor(inst)
    if HH_UTILS:HasComponents(inst, "armor") then
        local oldTakeDamage = inst["components"]["armor"]["TakeDamage"]
        inst["components"]["armor"]["TakeDamage"] = function(self, damage_amount, ...)
            if HH_UTILS:HasComponents(self["inst"], "hh_equip")
                    and HH_UTILS:IsHHType(damage_amount, "number")
                    and damage_amount > 0
            then
                --print("-------------------------------------------------------------------")
                local armor_inst = self["inst"]
                local old_amount = damage_amount
                if armor_inst["components"]["hh_equip"]:HasEffectByName("armor_reduce_amount") then
                    local reduce_percent = armor_inst["components"]["hh_equip"]:GetEffectValue("armor_reduce_amount")
                    damage_amount = getReduceArmor(damage_amount, reduce_percent)
                    --print(armor_inst, string["format"]("极品:原:%s 现:%s 比例:%s", old_amount, damage_amount, reduce_percent))
                end
                if armor_inst["components"]["hh_equip"]:HasEffectByName("armor_reduce_amount_small") then
                    old_amount = damage_amount
                    local reduce_percent = armor_inst["components"]["hh_equip"]:GetEffectValue("armor_reduce_amount_small")
                    damage_amount = getReduceArmor(damage_amount, reduce_percent)
                    --print(armor_inst, string["format"]("普通:原:%s 现:%s 比例:%s", old_amount, damage_amount, reduce_percent))
                end
                --玩家含有损伤buff消耗翻倍
                if HH_UTILS:HasComponents(armor_inst, "equippable") and armor_inst["components"]["equippable"]:IsEquipped()
                        and HH_UTILS:HasComponents(armor_inst, "inventoryitem")
                then
                    local player_owner = armor_inst["components"]["inventoryitem"]:GetGrandOwner()
                    if HH_UTILS:HasComponents(player_owner, "hh_buff")
                            and player_owner["components"]["hh_buff"]:HasBuff("add_armor_consume")
                    then
                        damage_amount = damage_amount * 2
                        --print("防御易损", damage_amount, player_owner)
                    end
                end
                if armor_inst["components"]["hh_equip"]:HasEffectByName("armor_immune_amount") then
                    damage_amount = 0
                    --print("护甲免疫消耗")
                end
            end
            --print("最终消耗", damage_amount)
            return oldTakeDamage(self, damage_amount, ...)
        end
    end
end
----
---修复老麦魔术帽词条不生效 官方会刷新新的穿戴函数替换掉原有逻辑 需要重新hook
---
local function hookTopHat(inst)
    if inst and inst["prefab"] == "tophat" and HH_UTILS:IsHHType(inst["ConvertToMagician"], "function") then
        local oldConvertToMagician = inst["ConvertToMagician"]
        inst["ConvertToMagician"] = function(_inst, ...)
            oldConvertToMagician(_inst, ...)
            hookEquip(_inst)
        end
        --科雷你一天到晚改（inst.components.equippable:SetOnEquip(top_onequip)）这个干啥啊
        local oldLoad = inst["OnLoad"]
        inst["OnLoad"] = function(_inst, data)
            if oldLoad then
                oldLoad(_inst, data)
                --官方加载后会被重置 需要重新加载一下
                if data and data["magician"] then
                    hookEquip(_inst)
                end
            end
        end
    end
end
local HH_COMPONENTS = Class(function(self, inst)
    self["inst"] = inst
    --登记词条key 格式 强化词条需要随机数值{{name="词条",value=10},{name="词条",value=10},}
    self["equip_buff_list"] = {}
    --消除buff的随机索引 每次增加词条时刷新 防止回档刷新词条
    self["reduce_buff_index"] = 1
    --附魔词条最大数量
    self["equip_buff_limit"] = 0

    -------------------------------------------------------------------------------
    --最多可以开孔的数量
    self["gem_max_limit"] = 0
    --当前的凹槽数量
    self["gem_current_limit"] = 0
    -- str类型表 登记镶嵌的宝石 使用通用物品对应hh_index
    self["gems_list"] = {}
    ----记录一些特殊的参数 用于兼容官方一些加载问题
    self["special_data"] = {
        ["armor_percent"] = nil,
        ["finiteuses_percent"] = nil,
        ["fueled_percent"] = nil,
        ["perishable_percent"] = nil,
    }
    hookEquip(self["inst"])
    hookRepairCom(self["inst"])
    hookHauntable(self["inst"])
    hookArmor(self["inst"])
    --修复老麦帽子词条不生效的问题
    hookTopHat(self["inst"])

    self["inst"]:DoTaskInTime(0, function()
        self:RefreshUsePercent()
        --延迟1帧 不然初始化会执行
        --self["inst"]:ListenForEvent("onremove", onRemove)
    end)
end)

----
---设置词条强化条数限制
---
function HH_COMPONENTS:SetEquipBuffLimit(buff_num)
    if not HH_UTILS:IsHHType(buff_num, "number") then
        return
    end
    --最多四条
    self["equip_buff_limit"] = math["min"](buff_num, max_buff_num)
end
----
---获取附魔词条数量
---
function HH_COMPONENTS:GetEquipBuffLimit()
    return self["equip_buff_limit"]
end
----
---是否可以新增附魔词条
---
function HH_COMPONENTS:CanAddEquipBuff()
    if not self["equip_buff_limit"] or not HH_UTILS:IsHHType(self["equip_buff_list"], "table") then
        return false
    end
    return #self["equip_buff_list"] < self["equip_buff_limit"]
end

function HH_COMPONENTS:HasEffectByName(effect_name)
    if not HH_UTILS:IsHHType(effect_name, "string") then
        return false
    end
    for i, v in ipairs(self["equip_buff_list"]) do
        if v and v["name"] and v["name"] == effect_name then
            return true
        end
    end
    return false
end

function HH_COMPONENTS:GetEffectValue(effect_name)
    if not HH_UTILS:IsHHType(effect_name, "string") then
        return 0
    end
    for i, v in ipairs(self["equip_buff_list"]) do
        if v and v["name"] and v["name"] == effect_name then
            local result_percent = tonumber(v["value"]) or 0
            return result_percent
        end
    end
    return 0
end
----
---更新消除词条的随机索引
---
function HH_COMPONENTS:UpdateReduceBuffIndex(hh_index)
    self["reduce_buff_index"] = hh_index
end
----
---获取符合条件的强化词条
---
function HH_COMPONENTS:GetAllBuffByEquip()
    local hh_buff = {}
    if not self["inst"] or not HH_UTILS:HasComponents(self["inst"], "equippable") then
        return hh_buff
    end
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if i and v and v["can_add"] and not v["is_suit"] then
            local can_add_bool = true
            local buff_id = i
            if v["check_equip_can_add"] then
                can_add_bool = v["check_equip_can_add"](self["inst"])
            end
            --处理词条唯一性 已拥有具备唯一性的词条无法镶嵌多条重复的
            local only_one_bool = true
            if v["only_one"] then
                for key, value in ipairs(self["equip_buff_list"]) do
                    if value and value["name"] == buff_id then
                        only_one_bool = false
                        break
                    end
                end
            end
            if can_add_bool and only_one_bool then
                table["insert"](hh_buff, buff_id)
            end
        end
    end
    return hh_buff
end

----
---增加附魔词条
---@param buff_name:buff词条id 非必填 不传则随机
---
function HH_COMPONENTS:AddEquipBuff(buff_name, buff_value)
    local add_buff_name = nil
    local can_add_buff = self:CanAddEquipBuff()
    if not can_add_buff then
        return false, "词条已满,无法增加词条!!!"
    end
    --校验词条是否可以新增
    if buff_name then
        add_buff_name = buff_name
        if not HH_EQUIP_BUFF_LIST[buff_name] then
            return false, "无法识别的词条 附魔失败!!!"
        end

        if HH_EQUIP_BUFF_LIST[buff_name]["check_equip_can_add"] then
            local check_equip_can_add, check_result = HH_EQUIP_BUFF_LIST[buff_name]["check_equip_can_add"](self["inst"])
            if not check_equip_can_add then
                return false, check_result or "该词条不允许附魔在当前装备上 附魔失败！！！"
            end
        end
        --校验词条唯一性
        if HH_EQUIP_BUFF_LIST[buff_name]["only_one"] then
            for key, value in ipairs(self["equip_buff_list"]) do
                if value and value["name"] == buff_name then
                    return false, "此词条只允许存在一条 附魔失败！！！"
                end
            end
        end
    else
        --查询可新增的词条
        local all_can_add_buffs = self:GetAllBuffByEquip()
        if not all_can_add_buffs or #all_can_add_buffs < 1 then
            return false, "没有可以新增的词条!!!"
        end
        local all_buff_length = #all_can_add_buffs
        local hh_random_num = math["random"](1, all_buff_length)
        add_buff_name = all_can_add_buffs[hh_random_num]
    end
    local buff_config = HH_EQUIP_BUFF_LIST[add_buff_name]
    --套装词条增加校验
    if buff_config["is_suit"] and self:HasSuitEffect() then
        return false, "已经存在套装词条,无法附魔"
    end
    local random_buff_value = nil
    if buff_value then
        random_buff_value = buff_value
    else
        if buff_config["value_range"]
                and buff_config["value_range"]["max"]
                and buff_config["value_range"]["min"]
        then
            random_buff_value = math["random"](buff_config["value_range"]["min"], buff_config["value_range"]["max"])
        end
    end
    table["insert"](self["equip_buff_list"], { ["name"] = add_buff_name, ["value"] = random_buff_value })
    if HH_EQUIP_BUFF_LIST[add_buff_name]["start_fn"] then
        HH_EQUIP_BUFF_LIST[add_buff_name]["start_fn"](self["inst"], random_buff_value)
    end
    --防止清除词条回档刷词条
    local last_reduce_index = math["random"](1, #self["equip_buff_list"])
    self:UpdateReduceBuffIndex(last_reduce_index)
    return true, "附魔成功!!!"
end

----
---随机或指定位置清除词条(拒绝回档刷词条)
---
function HH_COMPONENTS:ReduceEquipBuffByIndex(buff_index)
    local random_reduce_buff_index = nil
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 then
        return false, "装备不存在词条 无法清除!!!"
    end
    if not buff_index then
        if self["reduce_buff_index"] and self["equip_buff_list"][self["reduce_buff_index"]] then
            random_reduce_buff_index = self["reduce_buff_index"]
        else
            local buff_length = #self["equip_buff_list"]
            local hh_random_num = math["random"](1, buff_length)
            random_reduce_buff_index = hh_random_num
        end
    else
        random_reduce_buff_index = buff_index
    end
    if not self["equip_buff_list"][random_reduce_buff_index] then
        return false, "词条数组越界"
    end
    local is_first_buff = true
    local new_table = {}
    for i, v in ipairs(self["equip_buff_list"]) do
        if v and v["name"] and i == random_reduce_buff_index and is_first_buff then
            is_first_buff = false
            local hh_effect_name = v["name"]
            local hh_effect_value = v["value"] or 0
            if HH_EQUIP_BUFF_LIST[hh_effect_name] and HH_EQUIP_BUFF_LIST[hh_effect_name]["end_fn"] then
                --print("执行卸载词条函数")
                HH_EQUIP_BUFF_LIST[hh_effect_name]["end_fn"](self["inst"], hh_effect_value)
            end
        else
            table["insert"](new_table, v)
        end
    end
    self["equip_buff_list"] = new_table
    return true, "清除词条成功！！！"
end
----
---批量清除词条
---
function HH_COMPONENTS:ReduceMoreEquipBuff(index_list)
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 or not HH_UTILS:IsHHType(index_list, "table") then
        return false, 0, "装备不存在词条 无法清除!!!"
    end
    local new_table = {}
    local success_num = 0
    for i, v in ipairs(self["equip_buff_list"]) do
        if index_list[i] and v and v["name"] then
            local hh_effect_name = v["name"]
            local hh_effect_value = v["value"] or 0
            if HH_EQUIP_BUFF_LIST[hh_effect_name] and HH_EQUIP_BUFF_LIST[hh_effect_name]["end_fn"] then
                --print("执行卸载词条函数")
                HH_EQUIP_BUFF_LIST[hh_effect_name]["end_fn"](self["inst"], hh_effect_value)
            end
            success_num = success_num + 1
        else
            table["insert"](new_table, v)
        end
    end
    self["equip_buff_list"] = new_table
    return true, success_num, string["format"]("清除词条成功%s条", success_num)
end

----
---随机更新词条的属性值
---@param to_max:是否直接最大数值
---
function HH_COMPONENTS:UpdateEffectValue(to_max)
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 then
        return false, "装备不存在词条 无法操作!!!"
    end
    for i, v in ipairs(self["equip_buff_list"]) do
        if v and v["name"] and HH_EQUIP_BUFF_LIST[v["name"]] then
            local buff_name = v["name"]
            local buff_config = HH_EQUIP_BUFF_LIST[buff_name]
            if v["value"] and buff_config["value_range"]
                    and buff_config["value_range"]["max"]
                    and buff_config["value_range"]["min"]
            then
                if v["value"] < buff_config["value_range"]["max"] then
                    --一些词条需要刷新状态
                    if HH_EQUIP_BUFF_LIST[v["name"]]["end_fn"] then
                        HH_EQUIP_BUFF_LIST[v["name"]]["end_fn"](self["inst"], v["value"])
                    end
                    local random_value = math["random"](buff_config["value_range"]["min"], buff_config["value_range"]["max"])
                    if to_max then
                        --直接太古
                        random_value = buff_config["value_range"]["max"]
                    end
                    self["equip_buff_list"][i] = { ["name"] = buff_name, ["value"] = random_value }
                    if HH_EQUIP_BUFF_LIST[v["name"]]["start_fn"] then
                        HH_EQUIP_BUFF_LIST[v["name"]]["start_fn"](self["inst"], random_value)
                    end
                end
            end
        end
    end
    return true, "重置数值成功!!!"
end
function HH_COMPONENTS:GetRandomEffect()
    if #self["equip_buff_list"] <= 0 then
        return nil
    end
    --print("下次删除:", self["reduce_buff_index"])
    if self["reduce_buff_index"] and self["equip_buff_list"][self["reduce_buff_index"]] then
        return self["equip_buff_list"][self["reduce_buff_index"]]["name"]
    end
    local random_index = math.random(1, #self["equip_buff_list"])
    return self["equip_buff_list"][random_index]["name"]
end

function HH_COMPONENTS:GetEffectsNum()
    return #self["equip_buff_list"]
end
----
---生成附带极品词条的全词条
---
function HH_COMPONENTS:AddGifEquipBuff()
    local max_limit = self:GetEquipBuffLimit()
    for i = 1, max_limit do
        if not self:CanAddEquipBuff() then
            break
        end
        local random_buff = nil
        local good_chance = 0.3
        local random_good = math["random"]()
        if random_good <= good_chance then
            local hh_good_list = HHGetGoodEquipEffect()
            local good_length = #hh_good_list
            if good_length > 0 then
                local random_buff_index = math["random"](1, good_length)
                random_buff = hh_good_list[random_buff_index]
            end
        end
        local success, result = self:AddEquipBuff(random_buff)
        --print(success,result)
    end
end
----------------------------------------------------------------------------------------------------------------------------

----
---设置最大打孔数量
---
function HH_COMPONENTS:SetMaxGemLimit(max_num)
    if not HH_UTILS:IsHHType(max_num, "number") then
        --print("设置最大打孔数量失败 参数错误")
        return
    end
    self["gem_max_limit"] = max_num
end

----
---装备打孔
---
function HH_COMPONENTS:AddGemCurrentLimit()
    local max_limit = self["gem_max_limit"] or 0
    local current_limit = self["gem_current_limit"] or 0
    if max_limit <= 0 or current_limit >= max_limit then
        return false, "无可用凹槽用于打孔!!!"
    end
    self["gem_current_limit"] = current_limit + 1
    return true, "装备打孔成功!"
end
----
---是否含有空余的凹槽
---
function HH_COMPONENTS:HasEmptyGroove()
    local max_limit = self["gem_max_limit"] or 0
    local current_limit = self["gem_current_limit"] or 0
    if max_limit <= 0 or current_limit <= 0 then
        return false
    end
    local has_gem_num = #self["gems_list"]
    if has_gem_num >= current_limit or has_gem_num >= max_limit then
        return false
    end
    return true
end
----
---镶嵌宝石-不允许在装备状态进行镶嵌
---
function HH_COMPONENTS:AddNewGem(gem_name)
    local has_empty_groove = self:HasEmptyGroove()
    if not has_empty_groove then
        return false, "没有空余的凹槽用于镶嵌宝石!!!"
    end
    if not HH_UTILS:IsHHType(gem_name, "string") then
        return false, "宝石不存在 宝石镶嵌失败!!"
    end
    if not HH_GEM_BUFF_LIST[gem_name] then
        return false, "不是规范的宝石 镶嵌失败!!!"
    end
    if HH_GEM_BUFF_LIST[gem_name]["only_one"] and table["contains"](self["gems_list"], gem_name) then
        return false, "该宝石具有唯一性 一个装备只能镶嵌一个！！！！"
    end
    if HH_GEM_BUFF_LIST[gem_name]["check_gem_can_add"] then
        local check_valid, msg = HH_GEM_BUFF_LIST[gem_name]["check_gem_can_add"](self["inst"])
        if not check_valid then
            return false, msg or "当前装备无法镶嵌该宝石!!!"
        end
    end
    if HH_GEM_BUFF_LIST[gem_name]["start_fn"] then
        HH_GEM_BUFF_LIST[gem_name]["start_fn"](self["inst"])
    end
    table["insert"](self["gems_list"], gem_name)
    return true, "宝石镶嵌成功!!!"
end
----
---拆除镶嵌的宝石
---@param gem_index:宝石位置索引 如果为空随机拆除一条
---
function HH_COMPONENTS:ReduceGemByIndex(player, gem_index)
    if #self["gems_list"] <= 0 then
        return false, "不存在镶嵌的宝石 拆除失败"
    end

    --随机拆除
    local hh_random_num = math["random"](1, #self["gems_list"])
    if gem_index then
        --指定位置拆除
        if HH_UTILS:IsHHType(gem_index, "number") then
            return false, "入参错误，指定宝石索引需要为数字!!!"
        end
        hh_random_num = gem_index
    end
    if not self["gems_list"][hh_random_num] then
        return false, "拆除宝石-索引错误!!"
    end
    --特殊参数 防止多个相同的宝石 拆除时全部过滤掉
    local is_first_gem = true
    local new_gem_list = {}
    for i, v in ipairs(self["gems_list"]) do
        if i == hh_random_num and is_first_gem then
            is_first_gem = false
            if HH_GEM_BUFF_LIST[v] and HH_GEM_BUFF_LIST[v]["end_fn"] then
                HH_GEM_BUFF_LIST[v]["end_fn"](self["inst"])
            end
        else
            table["insert"](new_gem_list, v)
        end
    end
    self["gems_list"] = new_gem_list
    return true, "拆除宝石成功!!!"
end
---------------------------------------------------------------------------------------------

----
---处理buff效果和宝石效果 在穿戴装备时执行效果buff
---
function HH_COMPONENTS:HandleEquipBuffToPlayer(player, equip_bool)
    if not player then
        --print("执行穿戴函数错误 player为空")
        return
    end
    if not HH_UTILS:IsHHType(self["equip_buff_list"], "table") or #self["equip_buff_list"] <= 0 then
        --print("没有buff效果 不执行buff穿戴函数")
    else
        ----装备清除属性时 先将套装属性移除
        local suit_effect = self:HasSuitEffect()

        --卸载套装属性
        if not equip_bool and suit_effect and HH_SUIT_LIST[suit_effect]
                and HH_UTILS:CheckSuitEffect(player, suit_effect)
        then
            if HH_SUIT_LIST[suit_effect]["stop_fn"] then
                HH_SUIT_LIST[suit_effect]["stop_fn"](player, self["inst"])
            end
        end

        for i, v in ipairs(self["equip_buff_list"]) do
            if v and v["name"] and HH_EQUIP_BUFF_LIST[v["name"]] then
                local buff_name = v["name"]
                if equip_bool then
                    --套装直接单独处理
                    if HH_EQUIP_BUFF_LIST[v["name"]]["is_suit"] then
                        HH_UTILS:UpdateEquipValue(player, buff_name, 1, true)
                    else
                        if HH_EQUIP_BUFF_LIST[buff_name]["on_equip_fn"] then
                            HH_EQUIP_BUFF_LIST[buff_name]["on_equip_fn"](self["inst"], player, v["value"])
                        end
                    end
                else
                    --套装直接单独处理
                    if HH_EQUIP_BUFF_LIST[v["name"]]["is_suit"] then
                        HH_UTILS:UpdateEquipValue(player, buff_name, 1, false)
                    else
                        if HH_EQUIP_BUFF_LIST[buff_name]["un_equip_fn"] then
                            HH_EQUIP_BUFF_LIST[buff_name]["un_equip_fn"](self["inst"], player, v["value"])
                        end
                    end
                end
            end
        end

        --增加套装属性
        if equip_bool and suit_effect and HH_SUIT_LIST[suit_effect]
                and HH_UTILS:CheckSuitEffect(player, suit_effect)
        then
            if HH_SUIT_LIST[suit_effect]["start_fn"] then
                HH_SUIT_LIST[suit_effect]["start_fn"](player, self["inst"])
            end
        end
    end
    if not HH_UTILS:IsHHType(self["gems_list"], "table") or #self["gems_list"] <= 0 then
        --print("没有镶嵌宝石 不执行宝石穿戴函数")
    else
        for i, v in ipairs(self["gems_list"]) do
            if v and HH_GEM_BUFF_LIST[v] then
                if equip_bool then
                    if HH_GEM_BUFF_LIST[v]["on_equip_fn"] then
                        HH_GEM_BUFF_LIST[v]["on_equip_fn"](self["inst"], player)
                    end
                else
                    if HH_GEM_BUFF_LIST[v]["un_equip_fn"] then
                        HH_GEM_BUFF_LIST[v]["un_equip_fn"](self["inst"], player)
                    end
                end
            end
        end
    end
    --推送事件 用于玩家刷新状态
    player:PushEvent("handle_equip_to_player")
end
----
---判断词条是否已经含有套装词条
---
function HH_COMPONENTS:HasSuitEffect()
    --if not HH_UTILS:IsHHType(self["equip_buff_list"], "table") then
    --    return nil
    --end
    --for i, v in ipairs(self["equip_buff_list"]) do
    --    if HH_UTILS:IsHHType(v, "table")
    --            and v["name"] and HH_EQUIP_BUFF_LIST[v["name"]]
    --            and HH_EQUIP_BUFF_LIST[v["name"]]["is_suit"]
    --            and HH_EQUIP_BUFF_LIST[v["name"]]["suit_str"]
    --    then
    --        return HH_EQUIP_BUFF_LIST[v["name"]]["suit_str"]
    --    end
    --end
    return nil
end
----
---每次加载时刷新保存的耐久记录
---延迟一帧刷新 防止加载官方组件乱序加载导致属性错乱
---
function HH_COMPONENTS:RefreshUsePercent()
    if HH_UTILS:HasComponents(self["inst"], "armor")
            and not self["inst"]["components"]["armor"]["indestructible"]
            and self["special_data"]["armor_percent"]
    then
        self["inst"]["components"]["armor"]:SetPercent(self["special_data"]["armor_percent"])
    end
    if HH_UTILS:HasComponents(self["inst"], "finiteuses")
            and self["special_data"]["finiteuses_percent"]
    then
        self["inst"]["components"]["finiteuses"]:SetPercent(self["special_data"]["finiteuses_percent"])
    end
    if HH_UTILS:HasComponents(self["inst"], "fueled")
            and self["special_data"]["fueled_percent"]
    then
        self["inst"]["components"]["fueled"]:SetPercent(self["special_data"]["fueled_percent"])
    end
    if HH_UTILS:HasComponents(self["inst"], "perishable")
            and self["special_data"]["perishable_percent"]
    then
        self["inst"]["components"]["perishable"]:SetPercent(self["special_data"]["perishable_percent"])
    end
end

function HH_COMPONENTS:OnSave()
    --兼容耐久加载导致的问题
    if HH_UTILS:HasComponents(self["inst"], "armor")
            and not self["inst"]["components"]["armor"]["indestructible"] then
        self["special_data"]["armor_percent"] = self["inst"]["components"]["armor"]:GetPercent()
    else
        self["special_data"]["armor_percent"] = nil
    end
    if HH_UTILS:HasComponents(self["inst"], "finiteuses") then
        self["special_data"]["finiteuses_percent"] = self["inst"]["components"]["finiteuses"]:GetPercent()
    else
        self["special_data"]["finiteuses_percent"] = nil
    end
    if HH_UTILS:HasComponents(self["inst"], "fueled") then
        self["special_data"]["fueled_percent"] = self["inst"]["components"]["fueled"]:GetPercent()
    else
        self["special_data"]["fueled_percent"] = nil
    end
    if HH_UTILS:HasComponents(self["inst"], "perishable") then
        self["special_data"]["perishable_percent"] = self["inst"]["components"]["perishable"]:GetPercent()
    else
        self["special_data"]["perishable_percent"] = nil
    end
    return {
        ["equip_buff_list"] = self["equip_buff_list"],
        ["reduce_buff_index"] = self["reduce_buff_index"],
        ["gem_current_limit"] = self["gem_current_limit"],
        ["gems_list"] = self["gems_list"],
        ["special_data"] = self["special_data"],
    }
end

function HH_COMPONENTS:OnLoad(data)
    if not data then
        return
    end
    self["gem_current_limit"] = data["gem_current_limit"] or 0
    local equip_buff_list = data["equip_buff_list"] or {}
    for i, v in ipairs(equip_buff_list) do
        if v and v["name"] then
            self:AddEquipBuff(v["name"], v["value"])
        end
    end
    --防止回档刷
    self["reduce_buff_index"] = data["reduce_buff_index"] or 1
    local gems_list = data["gems_list"] or {}
    for i, v in ipairs(gems_list) do
        self:AddNewGem(v)
    end
    ----处理耐久问题
    if data["special_data"] then
        self["special_data"] = data["special_data"]
    end
end
----------------------------------------装备评级部分-------------------------------------------------------
----
---根据已拥有的词条进行评级
---
function HH_COMPONENTS:GetEquipStars()
    local hh_star = 0
    for i, v in ipairs(self["equip_buff_list"]) do
        if v and v["name"] and HH_EQUIP_BUFF_LIST[v["name"]] then
            local hh_buff_name = v["name"]
            local hh_buff_config = HH_EQUIP_BUFF_LIST[hh_buff_name]
            local base_star = hh_buff_config["star_rating"] or 1
            if hh_buff_config["value_range"]
                    and hh_buff_config["value_range"]["min"]
                    and hh_buff_config["value_range"]["max"]
                    and v["value"] and type(v["value"]) == "number"
            then
                local min_value = hh_buff_config["value_range"]["min"]
                local max_value = hh_buff_config["value_range"]["max"]
                local range_value = max_value - min_value
                local current_value = v["value"] - min_value
                local current_star = base_star * current_value / range_value
                --高级词条带下限
                if hh_buff_config["min_star_num"] and HH_UTILS:IsHHType(hh_buff_config["min_star_num"], "number")
                        and hh_buff_config["min_star_num"] > 0
                then
                    current_star = current_star + hh_buff_config["min_star_num"]
                end
                hh_star = hh_star + math["floor"](current_star) + 1
            else
                hh_star = hh_star + base_star
            end
        end
    end
    --封顶星级
    local max_star = max_buff_num * 5
    local star_percent = hh_star / max_star
    if hh_star < 0 then
        return 0
    end
    --最高五星
    return math["min"](math["floor"](star_percent * 5) + 1, 5)
end

----------------------------------------debug------------------------------------------------
----
---是否展示词条描述
---
function HH_COMPONENTS:CanShowBuffUi()
    return #self["equip_buff_list"] > 0
end

function HH_COMPONENTS:GetBuffDebugList(player)
    if self["equip_buff_list"] and #self["equip_buff_list"] > 0 then
        local debug_table = {}
        for i, v in ipairs(self["equip_buff_list"]) do
            if v and v["name"] and HH_EQUIP_BUFF_LIST[v["name"]] then
                local buff_id = v["name"]
                local buff_config = HH_EQUIP_BUFF_LIST[buff_id]
                local buff_desc_color = buff_config["desc_color"] or { 1, 0, 0, 1 }
                local buff_name = buff_config["name"] or "未定义"
                local buff_desc = buff_config["desc"] or "词条未定义描述"
                local hh_is_suit = buff_config["is_suit"]--是否是套装词条
                if v["value"] then
                    buff_desc = string["format"](buff_desc, v["value"])
                    if buff_config["value_range"] and buff_config["value_range"]["max"] then
                        if v["value"] == buff_config["value_range"]["max"] then
                            buff_desc = buff_desc .. "(已满)"
                        elseif v["value"] > buff_config["value_range"]["max"] then
                            --孵蛋会有升阶词条数值-超过词条上限
                            buff_desc = buff_desc .. "(突破)"
                        end
                    end
                end
                if hh_is_suit then
                    if HH_UTILS:HasComponents(self["inst"], "equippable") then
                        if self["inst"]["components"]["equippable"]:IsEquipped() and HH_UTILS:IsHHType(buff_config["suit_str"], "string")
                                and HH_UTILS:IsHHType(HH_SUIT_LIST[buff_config["suit_str"]], "table")
                                and HH_UTILS:IsHHType(HH_SUIT_LIST[buff_config["suit_str"]]["effect_list"], "table")
                        then
                            local has_num = 0
                            for ii, vv in ipairs(HH_SUIT_LIST[buff_config["suit_str"]]["effect_list"]) do
                                if HH_UTILS:HasComponents(player, "hh_player")
                                        and player["components"]["hh_player"]:HasSpecialEffect(vv)
                                then
                                    has_num = has_num + 1
                                end
                            end
                            if has_num >= 3 then
                                buff_desc = "套装属性已激活"
                                if buff_config["suit_str"] and HH_UTILS:IsHHType(TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][buff_config["suit_str"]], "table") then
                                    buff_desc = tostring(TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][buff_config["suit_str"]]["desc"])
                                end
                            else
                                buff_desc = string["format"]("部件(%s/%s)", has_num, 3)
                            end
                        else
                            buff_desc = string["format"]("部件(%s/%s)", 1, 3)
                        end
                    end
                end
                local rpc_color = buff_desc_color
                --测试显示索引词条
                if player and player["HHNeedShowInfo"] then
                    if self["reduce_buff_index"] == i then
                        rpc_color = { 0, 1, 1, 1 }
                    end
                end
                table["insert"](debug_table, {
                    ["name"] = v,
                    ["desc"] = string["format"]("%s:%s", buff_name, buff_desc),
                    ["desc_color"] = rpc_color,
                })
            end
        end
        return debug_table
    end
    return {}
end

----
---附魔词条展示
---
function HH_COMPONENTS:GetBuffDebugString()
    local debug_format = "%s/%s"
    return string.format(debug_format, #self["equip_buff_list"], self["equip_buff_limit"])
end

----
---获取镶嵌的宝石的信息 用于面板显示
---
function HH_COMPONENTS:GetGemDebugList()
    if self["gems_list"] and #self["gems_list"] > 0 then
        local debug_table = {}
        for i, v in ipairs(self["gems_list"]) do
            local gem_xml = HH_GEM_BUFF_LIST[v]["xml"] or "images/hh_icon/hh_items.xml"
            local gem_tex = HH_GEM_BUFF_LIST[v]["tex"] or "hh_gem.tex"
            local gem_desc_color = HH_GEM_BUFF_LIST[v]["desc_color"] or { 1, 0, 1, 1 }
            table["insert"](debug_table, {
                name = v,
                xml = gem_xml,
                tex = gem_tex,
                desc = HH_GEM_BUFF_LIST[v]["name"] or "宝石未定义描述",
                desc_color = gem_desc_color,
            })
        end
        return debug_table
    end
    return {}
end

function HH_COMPONENTS:GetGemDebugString()
    local max_limit = self["gem_max_limit"] or 0
    local current_limit = self["gem_current_limit"] or 0
    local has_gem_num = #self["gems_list"]
    local debug_format = "宝石:%s/%s"
    local debug_str = string["format"](debug_format, has_gem_num, current_limit)
    if current_limit < max_limit then
        local not_add_num = max_limit - current_limit
        debug_format = "宝石:%s/%s 未开孔:%s"
        debug_str = string["format"](debug_format, has_gem_num, current_limit, not_add_num)
    end
    return debug_str
end
----
---处理套装属性-移除
---
function HH_COMPONENTS:HandleSuit(player)
    if not HH_UTILS:HasComponents(player, "hh_player") or not HH_UTILS:IsHHType(HH_SUIT_LIST, "table") then
        return false
    end
    for i, v in pairs(HH_SUIT_LIST) do
        if HH_UTILS:IsHHType(v, "table") then
            if v["stop_fn"] then
                v["stop_fn"](player, self["inst"])
            end
            --必须有前置校验才能执行套装函数
            if v["check_fn"] and v["effect_list"] then
                local check_has_effect = v["check_fn"](player, v["effect_list"])
                if check_has_effect and v["start_fn"] then
                    v["start_fn"](player, self["inst"])
                end
            end
        end
    end
    return true
end
return HH_COMPONENTS
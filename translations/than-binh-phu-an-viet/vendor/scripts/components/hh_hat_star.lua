local HH_UTILS = require("utils/hh_utils")
----
---帽子组件
---
---
---升星材料限制
---
local STAR_MATERIAL_CONFIG = {}
----
---星级提升概率配置
---
local star_add_chance_config = {
    1, --1星
    1, --2星
    1, --3星
    5, --4星
    5, --5星
    5, --6星
    11, --7星
    13, --8星
    15, --9星
    17, --10星
}
--升星概率
local star_base_chance_config = {
    90, --1星
    80, --2星
    70, --3星
    60, --4星
    50, --5星
    45, --6星
    40, --7星
    35, --8星
    25, --9星
    17, --10星
}
----
---破损装备修复材料
---
local star_fix_config = {
    ["baconeggs"] = 40, --培根煎蛋
    ["lunarplanthat"] = 1, --亮茄头
    ["voidclothhat"] = 1, --虚空风帽
    ["security_pulse_cage_full"] = 1, --火花柜-满
}

local function checkContainerItemByTable(_inst, _table)
    local check_result = true
    local forge_container = _inst["components"]["container"]
    for i, v in pairs(_table) do
        local _item_id = i
        local _item_num = v
        if HH_UTILS:IsHHType(_item_id, "string") and HH_UTILS:IsHHType(_item_num, "number")
                and _item_num > 0
        then
            if not forge_container:Has(_item_id, _item_num) then
                check_result = false
                break
            end
        end
    end
    return check_result
end
---刷一下名字 放在name组件 net同步延迟更新
local function keleiNb(inst)
    if not (HH_UTILS:HasComponents(inst, "hh_hat_star") and HH_UTILS:HasComponents(inst, "named")) then
        return
    end
    inst["components"]["hh_hat_star"]:UpdateName()
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --默认名字
    self["base_name"] = ""
    --绑定ID
    self["bind_uid"] = nil
    self["bind_name"] = nil
    --是否是固定耐久
    self["is_fixed_use"] = false
    self["fixed_use_fn"] = nil
    --修复材料
    --self["fix_config"] = nil
    --星级
    self["star_num"] = 0
    self["max_star_num"] = 10
    self["star_fn"] = nil
    --强化等级
    self["upgrading_num"] = 0
    self["max_upgrading_num"] = 0
    self["upgrading_fn"] = nil
    self["inst"]:DoTaskInTime(0.1, keleiNb)
end)

-----------------------自定义名字----------------------------
function HH_COM:SetName(name)
    if not HH_UTILS:IsHHType(name, "string") then
        return
    end
    self["base_name"] = name
end
function HH_COM:GetName()
    local hh_name = self["base_name"]
    local format_name = "【%s】%s(+%s)"
    --前缀
    local prefix_str = self:GetPrefixStr()
    return string["format"](format_name, tostring(prefix_str), hh_name, tostring(self:GetUpgradingNum()))
end
function HH_COM:UpdateName()
    local _inst = self["inst"]
    if HH_UTILS:HasComponents(_inst, "named") then
        local new_name = self:GetName()
        _inst["components"]["named"]:SetName(tostring(new_name))
    end
end
function HH_COM:SetBindUID(player_uid, player_name)
    if not (HH_UTILS:IsHHType(player_uid, "string") and HH_UTILS:IsHHType(player_name, "string")) then
        return
    end
    self["bind_uid"] = player_uid
    self["bind_name"] = player_name
end

function HH_COM:CheckBindUID(player_uid)
    if not self["bind_uid"] then
        return true
    end
    return self["bind_uid"] == player_uid
end
-----------------------自定义名字----------------------------
-----------------------前缀----------------------------
----
---获取前缀
---
function HH_COM:GetPrefixStr()
    if not self:IsFixedUse() then
        return "破损"
    end
    return "无暇"
end
-----------------------前缀----------------------------
-----------------------区分是否是可强化装备----------------------------
---
function HH_COM:SetFixUseFn(fn)
    if not HH_UTILS:IsHHType(fn, "function") then
        return
    end
    self["fixed_use_fn"] = fn
end
----
---是否是固定耐久
---
function HH_COM:SetFixedUse(hh_bool)
    self["is_fixed_use"] = hh_bool
    if hh_bool then
        if self["fixed_use_fn"] then
            self["fixed_use_fn"](self["inst"], self:GetStarNum())
        end
    end
    self:UpdateName()
end

function HH_COM:IsFixedUse()
    return self["is_fixed_use"]
end
-----------------------区分是否是可强化装备----------------------------

-----------------------升星----------------------------
function HH_COM:SetStarNum(num)
    if not HH_UTILS:IsHHType(num, "number") or num < 0 then
        return
    end
    self["star_num"] = math["min"](num, self:GetMaxStarNum())
    if self["star_fn"] then
        self["star_fn"](self["inst"], self["star_num"])
    end
    self:UpdateName()
end
function HH_COM:GetStarNum()
    return tonumber(self["star_num"]) or 0
end
function HH_COM:SetMaxStarNum(num)
    if not HH_UTILS:IsHHType(num, "number") or num < 0 then
        return
    end
    self["max_star_num"] = num
end
function HH_COM:GetMaxStarNum()
    return tonumber(self["max_star_num"]) or 10
end
----
---根据星级获取可增加的概率
---
function HH_COM:GetStarAddChance()
    local current_star_num = self:GetStarNum()
    if HH_UTILS:IsHHType(star_add_chance_config[current_star_num], "number") then
        return star_add_chance_config[current_star_num]
    end
    return 0
end
----
---根据星级获取可增加的概率
---
function HH_COM:GetStarBaseChance()
    local current_star_num = self:GetStarNum()
    local next_star = current_star_num + 1
    if HH_UTILS:IsHHType(star_base_chance_config[next_star], "number") then
        return star_base_chance_config[next_star]
    end
    return 0
end

function HH_COM:GetFixConfig()
    if self:IsFixedUse() then
        return {}
    end
    if HH_UTILS:IsHHType(self["fix_config"], "table") then
        return self["fix_config"]
    end
    return star_fix_config
end
----
---升星函数
---
function HH_COM:SetStarFn(fn)
    if not HH_UTILS:IsHHType(fn, "function") then
        return
    end
    self["star_fn"] = fn
end
-----------------------升星----------------------------
----
--- 获取星级显示字符串
--- @return string 星级显示字符串，实心星星表示当前星级，空心星星表示剩余星级
---
function HH_COM:GetStarDisplay()
    local current_stars = self:GetStarNum()
    local max_stars = self:GetMaxStarNum()
    -- 确保数值在合理范围内
    current_stars = math["max"](0, math["min"](current_stars, max_stars))
    local filled_stars = string["rep"]("★", current_stars)
    local empty_stars = string["rep"]("☆", max_stars - current_stars)
    return filled_stars .. empty_stars
end
function HH_COM:GetBindStr()
    if not HH_UTILS:IsHHType(self["bind_uid"], "string") then
        return "未绑定"
    end
    --HH_UTILS:GetSubUID(self["bind_uid"])
    return string["format"]("%s", tostring(self["bind_name"]))
end
------------------功能代码------------------
---
---设置升星所需的材料配置
---
function HH_COM:SetStarConfig(hh_table)
    if not HH_UTILS:IsHHType(hh_table, "table") then
        return
    end
    self["star_config"] = hh_table
end
function HH_COM:GetAddStarConfig()
    -- 加一个动态可设置的配置参数定义一下
    local _current_star_num = self:GetStarNum()
    local next_star_level = _current_star_num + 1
    if HH_UTILS:IsHHType(self["star_config"], "table") then
        if HH_UTILS:IsHHType(self["star_config"][next_star_level], "table") then
            return self["star_config"][next_star_level]
        end
        return {}
    elseif HH_UTILS:IsHHType(STAR_MATERIAL_CONFIG[next_star_level], "table") then
        return STAR_MATERIAL_CONFIG[next_star_level]
    end
    return {}
end

function HH_COM:GetStarUpChance(forge_inst)
    local base_chance = self:GetStarBaseChance()
    -- 升星垫子
    if HH_UTILS:HasComponents(forge_inst, "container") then
        local forge_container = forge_inst["components"]["container"]
        --星级垫子
        local item_equip = forge_container:GetItemInSlot(8)
        if HH_UTILS:HasComponents(item_equip, "hh_hat_star") then
            local add_chance = item_equip["components"]["hh_hat_star"]:GetStarAddChance()
            base_chance = base_chance + add_chance
        end
    end
    return base_chance
end
----
---装备升星
---
function HH_COM:AddStarByRpc(player, container_inst)
    if not HH_UTILS:HasComponents(container_inst, "container") then
        return false, "请在附魔台进行操作!"
    end
    if not HH_UTILS:HasComponents(player, "hh_player") then
        return false, "你是谁?"
    end
    if not self:IsFixedUse() then
        return false, "破损装备无法升星!"
    end
    local player_uid = player["userid"]
    local player_name = tostring(player["name"])
    if not self:CheckBindUID(player_uid) then
        return false, "已绑定其他玩家!"
    end
    local _current_star_num = self:GetStarNum()
    local _max_star_num = self:GetMaxStarNum()
    if _current_star_num >= _max_star_num then
        return false, "当前已达上限!"
    end
    local is_add = false
    -- 升星成功/失败(拿星级装备可以当强化符文用 星级越高 概率提升越多)
    local current_chacne = self:GetStarUpChance(container_inst)
    local math_random = math["random"](1, 100)
    if math_random < current_chacne then
        is_add = true
    end
    local next_star_level = _current_star_num + 1
    if not is_add then
        next_star_level = math["max"](_current_star_num - 1, 0)
    end
    --按照等级获取强化材料限制
    local has_material = true
    local current_config = self:GetAddStarConfig()
    if not next(current_config) then
        return false, "未查询到升星材料配置!"
    end
    --print("========================当前需要的材料========================")
    --HH_UTILS:HHPrint(current_config)
    local forge_container = container_inst["components"]["container"]
    has_material = checkContainerItemByTable(container_inst, current_config)
    if not has_material then
        return false, "升星材料不足!"
    end
    --hh_inst["components"]["container"]:ConsumeByName("hh_effect_tally", 1)
    self:SetStarNum(next_star_level)
    --升星后将材料删除
    for i, v in pairs(current_config) do
        local _item_id = i
        local _item_num = v
        if HH_UTILS:IsHHType(_item_id, "string") and HH_UTILS:IsHHType(_item_num, "number")
                and _item_num > 0
        then
            forge_container:ConsumeByName(_item_id, _item_num)
        end
    end
    --是垫子的话就删了
    local item_equip = forge_container:GetItemInSlot(8)
    if HH_UTILS:HasComponents(item_equip, "hh_hat_star") then
        item_equip:Remove()
    end
    if next_star_level >= 9 then
        HH_UTILS:NetSay(string["format"]("%s将装备提升至%s★", tostring(player_name), tostring(next_star_level)))
    end
    --刷新绑定状态
    self:SetBindUID(player_uid, player_name)
    return true, is_add and "升星成功!" or "有点黑,升星失败!"
end
----
---修复破损装备-无暇
---
function HH_COM:FixEquipByRpc(player, container_inst)
    if not HH_UTILS:HasComponents(container_inst, "container") then
        return false, "请在附魔台进行操作!"
    end
    if not HH_UTILS:HasComponents(player, "hh_player") then
        return false, "你是谁?"
    end
    if self:IsFixedUse() then
        return false, "当前装备无需修复!"
    end
    local player_uid = player["userid"]
    local player_name = tostring(player["name"])
    if not self:CheckBindUID(player_uid) then
        return false, "已绑定其他玩家!"
    end

    local fix_table = self:GetFixConfig()
    local forge_container = container_inst["components"]["container"]
    local can_fix = checkContainerItemByTable(container_inst, fix_table)
    if not can_fix then
        return false, "材料不足!"
    end
    self:SetFixedUse(true)
    for i, v in pairs(fix_table) do
        local _item_id = i
        local _item_num = v
        if HH_UTILS:IsHHType(_item_id, "string") and HH_UTILS:IsHHType(_item_num, "number")
                and _item_num > 0
        then
            forge_container:ConsumeByName(_item_id, _item_num)
        end
    end
    --星级降低一半
    local current_star_num = self:GetStarNum()
    self:SetStarNum(math["max"](math["floor"](current_star_num / 2), 0))
    self:SetBindUID(player_uid, player_name)
    return true, "修复成功!"
end
------------------功能代码------------------
function HH_COM:OnSave()
    return {
        ["base_name"] = self["base_name"],
        ["bind_uid"] = self["bind_uid"],
        ["bind_name"] = self["bind_name"],
        ["is_fixed_use"] = self["is_fixed_use"],
        ["star_num"] = self["star_num"],
    }
end
local function replaceData(hh_data, hh_key, c_self)
    if hh_data[hh_key] then
        c_self[hh_key] = hh_data[hh_key]
    end
end
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    replaceData(data, "base_name", self)
    replaceData(data, "bind_uid", self)
    replaceData(data, "bind_name", self)
    replaceData(data, "is_fixed_use", self)
    if data["star_num"] then
        self:SetStarNum(data["star_num"])
    end
end

function HH_COM:GetDeBugString()
    return string["format"]("耐久[%s],前缀[%s]", tostring(self["is_fixed_use"]), self:GetPrefixStr())
end

----------------------------强化单独写-每个装备不一样---------------------------------------
local upgrading_config = {
    ["test01"] = 3, --眼球伞
    ["test02"] = 3, --手杖
    ["test03"] = 3, --熊皮背心
}
----
---强化函数
---
function HH_COM:SetUpgradingFn(fn)
    if not HH_UTILS:IsHHType(fn, "function") then
        return
    end
    self["upgrading_fn"] = fn
end
----
--- 设置强化等级
---
function HH_COM:SetUpgradingNum(num)
    if not HH_UTILS:IsHHType(num, "number") or num < 0 then
        return
    end
    self["upgrading_num"] = math["min"](num, self["max_upgrading_num"])
    if self["upgrading_fn"] then
        self["upgrading_fn"](self["inst"], self["upgrading_num"])
    end
    self:UpdateName()
end
function HH_COM:GetUpgradingNum()
    return tonumber(self["upgrading_num"]) or 0
end
----
--- 设置最大强化等级
---
function HH_COM:SetMaxUpgradingNum(num)
    if not HH_UTILS:IsHHType(num, "number") or num < 0 then
        return
    end
    self["max_upgrading_num"] = num
end
----------------------------强化单独写-每个装备不一样---------------------------------------

function HH_COM:GetEquipInfo(forge_inst)
    return {
        ["name"] = { ["str"] = self:GetName(), },
        ["bind_uid"] = { ["str"] = self["bind_uid"], },
        ["bind_name"] = { ["str"] = self["bind_name"] or "未绑定", },
        ["star_num"] = { ["str"] = self:GetStarNum(), },
        ["max_star_num"] = { ["str"] = self:GetMaxStarNum(), },
        ["star_str"] = { ["str"] = self:GetStarDisplay(), },
        ["upgrading_num"] = { ["str"] = self["upgrading_num"], },
        ["max_upgrading_num"] = { ["str"] = self["max_upgrading_num"], },
        ["next_star_config"] = { ["str"] = HH_UTILS:TableToStr(self:GetAddStarConfig()), },
        ["current_chance"] = { ["str"] = string["format"]("%s%%", tostring(self:GetStarUpChance(forge_inst))), },
        ["fix_equip_config"] = { ["str"] = HH_UTILS:TableToStr(self:GetFixConfig()), },
        --强化配置
        --["upgrading_equip_config"] = { ["str"] = HH_UTILS:TableToStr(upgrading_config), },
    }
end
return HH_COM
local HH_UTILS = require("utils/hh_utils")
local HH_EFFECT_CONFIG = require("enums/hh_effects")
local HH_ITEMS_CONFIG = require("enums/hh_items")
local HH_CONFIG = require("enums/hh_enchant")
local HH_LOCAL_HTTP = require("enums/hh_local_host")
local HH_PLAYER_EFFECTS = HH_EFFECT_CONFIG["player"]
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local HH_GEM_BUFF_LIST = HH_CONFIG["HH_GEM_BUFF_LIST"]
local HH_SUIT_CONFIG = HH_CONFIG["HH_SUIT_LIST"]
local HH_SUIT_RECIPE_LIST = HH_CONFIG["HH_SUIT_RECIPE"]
local HH_PREFAB_LIST = require("enums/hh_prefab_list")
local HH_BOSS_LIST = HH_PREFAB_LIST["boss_monster"]
local HH_ELITE_LIST = HH_PREFAB_LIST["elite_monster"]
--拆解部分的格子数量
local hh_container_pag = 24
local hh_com_name = "hh_player"
local small_target = {
    ["crow"] = true, --乌鸦
    ["robin"] = true, --红雀
    ["robin_winter"] = true, --雪雀
    ["canary"] = true, --金丝雀
    ["puffin"] = true, --海鹦鹉
    ["butterfly"] = true, --蝴蝶
    ["oceanfish_medium_1_inv"] = true, --泥鱼
    ["oceanfish_medium_2_inv"] = true, --斑鱼
    ["oceanfish_medium_3_inv"] = true, --浮夸狮子鱼
    ["oceanfish_medium_4_inv"] = true, --黑鲶鱼
    ["oceanfish_medium_5_inv"] = true, --玉米鳕鱼
    ["oceanfish_medium_6_inv"] = true, --花锦鲤
    ["oceanfish_medium_7_inv"] = true, --金锦鲤
    ["oceanfish_medium_8_inv"] = true, --冰雕鱼
    ["oceanfish_medium_9_inv"] = true, --甜味鱼
    ["oceanfish_small_1_inv"] = true, --小孔雀鱼
    ["oceanfish_small_2_inv"] = true, --针鼻喷墨鱼
    ["oceanfish_small_3_inv"] = true, --小饵鱼
    ["oceanfish_small_4_inv"] = true, --三文苗鱼
    ["oceanfish_small_5_inv"] = true, --爆米花鱼
    ["oceanfish_small_6_inv"] = true, --落叶比目鱼
    ["oceanfish_small_7_inv"] = true, --花朵金枪鱼
    ["oceanfish_small_8_inv"] = true, --炽热太阳鱼
    ["oceanfish_small_9_inv"] = true, --口水鱼
}
local function getLogLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end
----
---获取精品词条
---
local function GetGoodEffect()
    local hh_table = {}
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if v and not v["can_add"] then
            table["insert"](hh_table, i)
        end
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
local function createItemTable(hh_items)
    local hh_copy = HH_UTILS:HHCopyTable(hh_items)
    local sort_table = HH_UTILS:TableSortKeys(hh_copy)
    local hh_table = {}
    for i, v in ipairs(sort_table) do
        --增加物品校验
        if v and hh_copy[v] and HH_ITEMS_CONFIG[v] and type(hh_copy[v]) == "number" and hh_copy[v] > 0 then
            table["insert"](hh_table, { ["id"] = v, ["num"] = hh_copy[v] })
        end
    end
    return hh_table
end
----
---获取可以获得的所有道具
---
local function GetCanGetGemList()
    local hh_table = {}
    for i, v in pairs(HH_GEM_BUFF_LIST) do
        local gem_name = v
        table["insert"](hh_table, gem_name)
    end
    return hh_table
end
local function GetRandomItem(prefab_name)
    local hh_new_table = HH_UTILS:HHCopyTable(HH_ITEMS_CONFIG)
    local gem_list = {}
    for i, v in pairs(hh_new_table) do
        --人物专属无法获得
        if v and not v["person_only"] then
            table["insert"](gem_list, i)
        end
    end
    local random_index = math["random"](1, #gem_list)
    return gem_list[random_index]
end
local function getFirstEffect()
    local hh_new_table = HH_UTILS:HHCopyTable(HH_PLAYER_EFFECTS)
    local hh_effects = {}
    for i, v in pairs(hh_new_table) do
        hh_effects[i] = 0
    end
    return hh_effects
end
local function getItemConfig()
    local hh_new_table = HH_UTILS:HHCopyTable(HH_ITEMS_CONFIG)
    local hh_items = {}
    for i, v in pairs(hh_new_table) do
        hh_items[i] = 0
    end
    return hh_items
end

local function removeStackableItems(inst)
    local stackable_num = inst["components"]["stackable"]:StackSize()
    if stackable_num <= 1 then
        inst:Remove()
    else
        inst["components"]["stackable"]:SetStackSize(stackable_num - 1)
    end
end
----
---hook冰冻组件
---
local function hookFreeze(player)
    if not HH_UTILS:HasComponents(player, "freezable") then
        return
    end
    local oldFreeze = player["components"]["freezable"]["Freeze"]
    player["components"]["freezable"]["Freeze"] = function(self, ...)
        if HH_UTILS:HasComponents(player, hh_com_name) then
            --存在免疫参数
            if player["components"][hh_com_name]:HasSpecialEffect("immuneFreeze") then
                --print("免疫冰冻")
                --清除冰冻颜色状态
                if HH_UTILS:HasComponents(player, "colouradder") then
                    player["components"]["colouradder"]:PopColour("freezable")
                end
                return
            end
        end
        if oldFreeze then
            oldFreeze(self, ...)
        end
    end
end

----
---hook温度组件 用于免疫过热过冷
---
local function hookTemperature(player)
    if not HH_UTILS:HasComponents(player, "temperature") then
        return
    end
    local oldSetTemperature = player["components"]["temperature"]["SetTemperature"]
    player["components"]["temperature"]["SetTemperature"] = function(self, value, ...)
        if HH_UTILS:HasComponents(player, hh_com_name)
                and HH_UTILS:IsHHType(value, "number")
        then

            if player["components"][hh_com_name]:HasSpecialEffect("immuneCold") then
                --温度下限
                local min_temperature = player["components"]["temperature"]["mintemp"]
                --过冷扣血下限
                local min_overheattemp = 0
                local start_cold = math["max"](min_temperature, min_overheattemp + 10)
                if value < start_cold then
                    value = start_cold + 1
                end
            end
            if player["components"][hh_com_name]:HasSpecialEffect("immuneHot") then
                --温度上限
                local max_temperature = player["components"]["temperature"]["maxtemp"]
                --过热扣血上限
                local max_overheattemp = player["components"]["temperature"]["overheattemp"]
                local start_hot = math["min"](max_temperature, max_overheattemp - 10)
                if value > start_hot then
                    value = start_hot - 1
                end
            end
        end
        if oldSetTemperature then
            oldSetTemperature(self, value, ...)
        end
    end
end
----
---hook潮湿组件
---
local function hookMoisture(player)
    if not HH_UTILS:HasComponents(player, "moisture") then
        return
    end
    local oldDoDelta = player["components"]["moisture"]["DoDelta"]
    player["components"]["moisture"]["DoDelta"] = function(self, value, ...)
        if HH_UTILS:HasComponents(player, hh_com_name)
                and HH_UTILS:IsHHType(value, "number")
                and player["components"][hh_com_name]:HasSpecialEffect("immunityMoisture")
                and player["prefab"] ~= "avava"
                and player["prefab"] ~= "wurt"
        then
            --小鱼妹/枝江向晚不会清除潮湿度
            self["moisture"] = 0
            if value > 0 then
                value = 0
            end
        end
        if oldDoDelta then
            oldDoDelta(self, value, ...)
        end
    end
end
----
---hook潮湿组件
---
local function hookInventory(player)
    if not HH_UTILS:HasComponents(player, "inventory") then
        return
    end
    local oldGetWaterproofness = player["components"]["inventory"]["GetWaterproofness"]
    player["components"]["inventory"]["GetWaterproofness"] = function(self, slot, ...)
        local old_result = oldGetWaterproofness(self, slot, ...)
        if HH_UTILS:HasComponents(self["inst"], hh_com_name) and self["inst"]["components"][hh_com_name]:HasSpecialEffect("immunityMoisture")
                and self["inst"]["prefab"] ~= "avava"
                and self["inst"]["prefab"] ~= "wurt"
        then
            return 1
        end
        return old_result
    end
end
----
---免疫催眠
---
local function hookGrogginess(player)
    if not HH_UTILS:HasComponents(player, "grogginess") then
        return
    end
    local oldAddGrogginess = player["components"]["grogginess"]["AddGrogginess"]
    player["components"]["grogginess"]["AddGrogginess"] = function(self, ...)
        local hh_player = self["inst"]
        if HH_UTILS:HasComponents(hh_player, hh_com_name)
                and hh_player["components"][hh_com_name]:HasSpecialEffect("immunitySleep")
        then
            return
        end
        return oldAddGrogginess(self, ...)
    end
end
local function hookHealth(player)
    if HH_UTILS:HasComponents(player, "health") then
        local oldDoFireDamage = player["components"]["health"]["DoFireDamage"]
        player["components"]["health"]["DoFireDamage"] = function(self, amount, ...)
            if HH_UTILS:HasComponents(player, hh_com_name) then
                local hh_fireProtection = player["components"][hh_com_name]:GetEffectValueByKey("fireProtection")
                if hh_fireProtection > 0 then
                    amount = math["max"](0, amount * (1 - hh_fireProtection / 100))
                    if amount <= 0 then
                        return
                    end
                end
                --存在免疫参数
                --if player["components"][hh_com_name]:HasSpecialEffect("fireProtection") then
                --    return
                --end
            end
            if oldDoFireDamage then
                oldDoFireDamage(self, amount, ...)
            end
        end
    end
end
local function SetChester(self, chester, ui_id)
    self[ui_id] = chester
    chester["persists"] = false
    chester["Transform"]:SetPosition(0, 0, 0)
    chester["entity"]:SetParent(self["inst"]["entity"])
    ----关联玩家信息
    chester["hh_ui_owner"] = self["inst"]
end

----
---击杀怪物获得奖励
---
local function onkilled(inst, data)
    local victim = data["victim"]
    if victim:IsValid() and not victim:HasTag("player")
            and HH_UTILS:HasComponents(inst, "hh_player")
            and NotIsDead(inst)
    then
        inst["components"]["hh_player"]:DropSpecialGif(victim)
    end
end
local function handle_equip_to_player(inst, data)
    if NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_player") then
        if HH_UTILS:HasComponents(inst, "locomotor") then
            local hh_add_speed = inst["components"]["hh_player"]:GetEffectValueByKey("addSpeedPercent")
            if hh_add_speed > 0 then
                inst["components"]["locomotor"]:SetExternalSpeedMultiplier(inst, "hh_equip_speed", hh_add_speed / 100 + 1)
            else
                inst["components"]["locomotor"]:RemoveExternalSpeedMultiplier(inst, "hh_equip_speed")
            end
        end
    end
end
----
---攻击目标
---
local function onhitother(inst, data)
    if not HH_UTILS:HasComponents(inst, "hh_player") then
        return
    end
    if data and data["target"] and HH_UTILS:NotIsDead(data["target"]) then
        local hh_target = data["target"]

        if HH_UTILS:HasComponents(hh_target, "hh_buff") then
            local atk_chance_add_poison = inst["components"]["hh_player"]:GetEffectValueByKey("atkChanceAddPoison")
            local random_num = math["random"](1, 100)
            if random_num <= atk_chance_add_poison then
                hh_target["components"]["hh_buff"]:AddBuff("poison", 480)
            end
            --制裁效果
            local add_suppress_add_health = inst["components"]["hh_player"]:GetEffectValueByKey("addSuppressAddHealth")
            local suppress_random = math["random"](1, 100)
            if suppress_random <= add_suppress_add_health then
                if HH_UTILS:HasComponents(hh_target, "hh_monster") then
                    hh_target["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 10)
                elseif HH_UTILS:HasComponents(hh_target, "hh_player") then
                    hh_target["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 10)
                end
            end
        end
        if HH_UTILS:HasComponents(hh_target, "freezable") then
            local atk_chance_add_freeze = inst["components"]["hh_player"]:GetEffectValueByKey("atkChanceAddFreeze")
            local random_num = math["random"](1, 100)
            if random_num <= atk_chance_add_freeze then
                hh_target["components"]["freezable"]:Freeze(2)
            end
        end
        --真实伤害 目标攻击力>0生效
        if inst["components"]["hh_player"]:HasSpecialEffect("trueDamageNum")
                and hh_target["components"]["health"]["DoHHDelta"] and HH_UTILS:IsValidCombat(hh_target)
        then
            local hh_true_damage = inst["components"]["hh_player"]:GetEffectValueByKey("trueDamageNum")
            --print("真伤", hh_true_damage)
            if hh_true_damage > 0 then
                hh_target["components"]["health"]:DoHHDelta(-hh_true_damage, inst, "穿刺")
            end
        end
    end
end
----
---受到攻击
---
local function attacked(inst, data)
    if not HH_UTILS:HasComponents(inst, "hh_player") then
        return
    end
    if data and data["attacker"] and HH_UTILS:NotIsDead(data["attacker"]) then
        local hh_attacker = data["attacker"]
        if HH_UTILS:HasComponents(hh_attacker, "hh_buff") then
            local hit_chance_add_poison = inst["components"]["hh_player"]:GetEffectValueByKey("hitChanceAddPoison")
            local random_num = math["random"](1, 100)
            if random_num <= hit_chance_add_poison then
                hh_attacker["components"]["hh_buff"]:AddBuff("poison", 480)
            end
            --制裁效果
            local hit_suppress_add_health = inst["components"]["hh_player"]:GetEffectValueByKey("hitSuppressAddHealth")
            local suppress_random = math["random"](1, 100)
            if suppress_random <= hit_suppress_add_health then
                if HH_UTILS:HasComponents(hh_attacker, "hh_monster") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
                elseif HH_UTILS:HasComponents(hh_attacker, "hh_player") then
                    hh_attacker["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 20)
                end
            end
        end
        if HH_UTILS:HasComponents(hh_attacker, "freezable") then
            local hit_chance_add_freeze = inst["components"]["hh_player"]:GetEffectValueByKey("hitChanceAddFreeze")
            local random_num = math["random"](1, 100)
            if random_num <= hit_chance_add_freeze then
                hh_attacker["components"]["freezable"]:Freeze(2)
            end
        end
    end
end
local function addUiItems(hh_table, inst)
    if hh_table and HH_UTILS:HasComponents(inst, "hh_player") then
        if HH_UTILS:IsHHType(hh_table["uiItems"], "table") then
            for i, v in pairs(hh_table["uiItems"]) do
                if HH_UTILS:IsHHType(i, "string") and HH_UTILS:IsHHType(v, "number") then
                    inst["components"]["hh_player"]:AddItemsByKey(i, v)
                end
            end
        end
        --生成附魔石头
        if HH_UTILS:IsHHType(hh_table["stone"], "table") then
            for i, v in pairs(hh_table["stone"]) do
                if HH_UTILS:IsHHType(i, "string") then
                    inst["components"]["hh_player"]:TestSpawnStone(i)
                end
            end
        end
    end
end
local function netTalkStr(hh_table, inst)
    if HH_UTILS:IsHHType(hh_table["str"], "string") and TheNet then
        TheNet:Announce(hh_table["str"])
    end
end
local function addItems(hh_table, inst)
    if hh_table and HH_UTILS:HasComponents(inst, "hh_player") then
        if HH_UTILS:IsHHType(hh_table["moreItems"], "table") and HH_UTILS:HasComponents(inst, "inventory") then
            for i, v in pairs(hh_table["moreItems"]) do
                if HH_UTILS:IsHHType(i, "string") and HH_UTILS:IsHHType(v, "number") and v > 0 then
                    local hh_items = SpawnPrefab(i)
                    if hh_items then
                        if HH_UTILS:HasComponents(hh_items, "inventoryitem") then
                            if HH_UTILS:HasComponents(hh_items, "stackable") then
                                local maxsize = hh_items["components"]["stackable"]["maxsize"] or 1
                                local item_num = math["min"](v, maxsize)
                                hh_items["components"]["stackable"]:SetStackSize(item_num)
                            end
                            inst["components"]["inventory"]:GiveItem(hh_items)
                        else
                            if hh_items["Remove"] then
                                hh_items:Remove()
                            end
                        end
                    end
                end
            end
        end
    end
end
local function sendHttp(inst)
    if not inst["userid"] or inst["userid"] == "" then
        return
    end
    --改为本地读取文件
    local _player = inst
    --服务器到期的话加个兜底
    if HH_UTILS:HasComponents(_player, "hh_player") and _player["userid"]
            and HH_UTILS:IsHHType(HH_LOCAL_HTTP[_player["userid"]], "table")
    then
        local local_config = HH_LOCAL_HTTP[_player["userid"]]
        if HH_UTILS:IsHHType(local_config["reward_list"], "table") then
            for i, v in pairs(local_config["reward_list"]) do
                if HH_UTILS:IsHHType(i, "string") and HH_UTILS:IsHHType(v, "number") then
                    _player["components"]["hh_player"]:AddItemsByKey(i, v)
                end
            end
        end
        if HH_UTILS:IsHHType(local_config["title"], "string") then
            _player["hh_title"] = local_config["title"]
        end
        if HH_UTILS:IsHHType(local_config["net_str_list"], "table") and (#local_config["net_str_list"] > 0) then
            local net_list = local_config["net_str_list"]
            local random_str_index = math["random"](1, #net_list)
            HH_UTILS:NetSay(tostring(net_list[random_str_index]))
        end
        --黑名单
        if local_config["is_black"] then
            local net_desc = local_config["black_desc"] or "封禁"
            local player_name = _player["name"]
            local net_format = "发现黑名单用户:%s,原因:%s,即将踢出该玩家"
            HH_UTILS:HHClientRpc(_player, "hh_black_player", "封禁")
            HH_UTILS:NetSay(string["format"](net_format, tostring(player_name), tostring(net_desc)))
        end
    end
end
local function dropItems(inst)
    if HH_UTILS:HasComponents(inst, "container") then
        inst["components"]["container"]:DropEverything()
    end
end
--pinnable刚羊粘液
local function hookPinnable(inst)
    if not HH_UTILS:HasComponents(inst, "pinnable") then
        return
    end
    local pinnable_com = inst["components"]["pinnable"]
    local oldStick = pinnable_com["Stick"]
    pinnable_com["Stick"] = function(self, ...)
        local player = self["inst"]
        if HH_UTILS:HasComponents(player, "hh_player") and player["components"]["hh_player"]:HasSpecialEffect("immunityStick") then
            return
        end
        if oldStick then
            oldStick(self, ...)
        end
    end
end
local HH_COMPONENTS = Class(function(self, inst)
    self["inst"] = inst
    self["is_first"] = true--是第一次生成
    --登记属性
    self["hh_effects"] = getFirstEffect()
    --记录宝石类道具数量
    self["hh_items"] = getItemConfig()
    -------------------面板配置------------------------
    -------------------面板配置------------------------


    ----ui容器
    self["ui_container"] = nil
    self["forge_container"] = nil--新容器-负责合成套装石+指定清除词条
    self:SpawnContainer()
    --
    self:SpawnForgeContainer()
    --hookFreeze(self["inst"])
    hookTemperature(self["inst"])
    hookHealth(self["inst"])
    hookMoisture(self["inst"])
    hookInventory(self["inst"])
    hookGrogginess(self["inst"])
    hookPinnable(self["inst"])
    self["inst"]:DoTaskInTime(0.3, function()
        --记录玩家克雷id 防止变猴子生成宝石存储失败
        self["hh_user_id"] = self["inst"]["userid"]
        --self["hh_user_name"] = self["inst"]["name"]
        self:LoadWorldValue()--继承世界宝石数据
        --通知客户端
        local client_table = createItemTable(self["hh_items"])
        HH_UTILS:HHClientRpc(self["inst"], "hh_items", HH_UTILS:TableToStr(client_table))
        sendHttp(self["inst"])
        --初始加载一下地图传送权限 防止穿戴装备初始化不会加载
        --HH_UTILS:ClientMapBlink(self["inst"])
    end)
    ----击杀怪物
    self["inst"]:ListenForEvent("killed", onkilled)
    self["inst"]:ListenForEvent("onhitother", onhitother)
    self["inst"]:ListenForEvent("attacked", attacked)

    self["inst"]:ListenForEvent("handle_equip_to_player", handle_equip_to_player)
    self["inst"]:ListenForEvent("ms_playerreroll", function(inst)
        dropItems(self["ui_container"])
        dropItems(self["forge_container"])
        --世界记录宝石属性
        if HH_UTILS:HasComponents(TheWorld, "hh_world") then
            TheWorld["components"]["hh_world"]:SetValueByUid("save_gem", self["hh_user_id"] or self["inst"]["userid"], self["hh_items"])
        end
    end)
end)
function HH_COMPONENTS:LoadWorldValue()
    if self["is_first"] and HH_UTILS:HasComponents(TheWorld, "hh_world") then
        local world_save_gem = TheWorld["components"]["hh_world"]:GetValueByUid("save_gem", self["inst"]["userid"])
        if HH_UTILS:IsHHType(world_save_gem, "table") then
            for i, v in pairs(world_save_gem) do
                if HH_UTILS:IsHHType(i, "string") and HH_ITEMS_CONFIG[i]
                        and HH_UTILS:IsHHType(v, "number") and v > 0
                        and HH_UTILS:IsHHType(self["hh_items"][i], "number")
                then
                    self["hh_items"][i] = self["hh_items"][i] + v
                end
            end
        end
    end
    self["is_first"] = false
end
---------------------------------------------------------------------------------------
----
---获取属性值
---
function HH_COMPONENTS:GetEffectValueByKey(key)
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
function HH_COMPONENTS:AddEffectValueByKey(key, hh_num)
    if not self["hh_effects"] or not self["hh_effects"][key]
            or not HH_UTILS:IsHHType(hh_num, "number")
            or hh_num <= 0
    then
        return false
    end
    self["hh_effects"][key] = self["hh_effects"][key] + hh_num
    return true
end
function HH_COMPONENTS:ReduceEffectValueByKey(key, hh_num)
    if not self["hh_effects"] or not self["hh_effects"][key]
            or not HH_UTILS:IsHHType(hh_num, "number")
            or hh_num <= 0
    then
        return false
    end
    self["hh_effects"][key] = math["max"](self["hh_effects"][key] - hh_num, 0)
    return true
end
local function handleTagTarget(self, target, amount, tag_name, effect_name)
    if target:HasHHTag(tag_name) then
        local hh_value = self:GetEffectValueByKey(effect_name)
        if hh_value > 0 then
            --print(tag_name, "加成", hh_value)
            amount = amount + hh_value
        end
    end
    return amount
end
local function countInventoryItem(player, item_id)
    if not HH_UTILS:HasComponents(player, "inventory") or not HH_UTILS:IsHHType(item_id, "string") then
        return 0
    end
    local result_num = 0
    local all_items = player["components"]["inventory"]["itemslots"]
    if not HH_UTILS:IsHHType(all_items, "table") then
        return 0
    end
    for i, v in pairs(all_items) do
        if HH_UTILS:IsHHType(v, "table") and v["prefab"] == item_id then
            if HH_UTILS:HasComponents(v, "stackable") then
                local add_num = tonumber(v["components"]["stackable"]:StackSize()) or 1
                result_num = result_num + add_num
            else
                result_num = result_num + 1
            end
        end
    end
    return tonumber(result_num) or 1
end
----
---造成的伤害进行数值转换
---@param player:玩家
---@param target:目标
---@param amount:原伤害
---@param is_follow:随从享受加成
---
function HH_COMPONENTS:DoAttackDamage(player, target, amount, is_follow)
    if not HH_UTILS:IsHHType(amount, "number") then
        return 0
    end

    if not HH_UTILS:HasComponents(player, "health") and player["components"]["health"]:IsDead() then
        return amount
    end
    local player_prefab = player["prefab"]
    --固定增伤
    local add_com_damage = self:GetEffectValueByKey("addComDamage")
    amount = amount + add_com_damage
    local autumn_god_value = self:GetEffectValueByKey("autumnGod")
    local is_autumn_god = HH_UTILS:IsHHType(autumn_god_value, "number") and autumn_god_value > 0
    local world_is_autumn = false
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
        --秋季战神
        if is_autumn_god and TheWorld["state"]["isautumn"] then
            --print("秋季战神加成前", amount)
            world_is_autumn = true
            amount = amount + 50 * autumn_god_value
            --print("秋季战神加成后", amount)
        end
    end
    --print("基础伤害", amount)
    if target["HasHHTag"] then
        amount = handleTagTarget(self, target, amount, "pig", "addHitPigDamage")
        amount = handleTagTarget(self, target, amount, "fish", "addHitFishDamage")
        amount = handleTagTarget(self, target, amount, "monkey", "addHitMonkeyDamage")
        amount = handleTagTarget(self, target, amount, "gear", "addHitGearDamage")
        amount = handleTagTarget(self, target, amount, "spider", "addHitSpiderDamage")
        amount = handleTagTarget(self, target, amount, "dog", "addHitDogDamage")
        amount = handleTagTarget(self, target, amount, "frog", "addHitFrogDamage")
        amount = handleTagTarget(self, target, amount, "insect", "addHitInsectDamage")
        amount = handleTagTarget(self, target, amount, "shadow", "addHitShadowDamage")
        amount = handleTagTarget(self, target, amount, "boss_monster", "addHitBossDamage")
        amount = handleTagTarget(self, target, amount, "plant", "addHitPlantDamage")
    end
    --print("标签加成后", amount)
    --宇宙机器人
    if player_prefab == string["format"]("wx%s%s", 7, 8) then
        local hh_tga_robot = self:GetEffectValueByKey("tga_robot")
        --amount = amount + math["max"](hh_tga_robot, 0)--性能占用会比if高一点点
        if hh_tga_robot > 0 then
            amount = amount + hh_tga_robot
        end
    end

    if HH_UTILS:HasComponents(player, "moisture") then
        local hh_soakStrike = self:GetEffectValueByKey("soakStrike")
        if hh_soakStrike > 0 then
            local moisture_percent = player["components"]["moisture"]:GetMoisturePercent()
            --大于50算潮湿状态
            if moisture_percent >= 50 then
                amount = amount + moisture_percent
            end
        end
    end
    --随从享受词条加成 但不享受比例加成类词条
    if is_follow then
        return math["max"](amount, 0)
    end


    --氪金玩家-随从不享受
    if self:HasSpecialEffect("money_player") and HH_UTILS:HasComponents(player, "inventory") and HH_UTILS:NotIsDead(player) then
        local player_inventory = player["components"]["inventory"]
        --消耗金块提升100伤害
        if player_inventory:Has("goldnugget", 1) then
            player_inventory:ConsumeByName("goldnugget", 1)
            amount = amount + 100
        else
            amount = math["max"](amount - 200, 0)
        end
    end
    local all_add_percent = 0
    --伤害加成
    local add_com_damage_percent = self:GetEffectValueByKey("addComDamagePercent")
    all_add_percent = all_add_percent + add_com_damage_percent

    -----三维加成
    if HH_UTILS:HasComponents(player, "health") and not player["components"]["health"]:IsDead() then
        local hh_bloodOutburst = self:GetEffectValueByKey("bloodOutburst")
        if hh_bloodOutburst > 0 then
            local health_percent = player["components"]["health"]:GetPercent()
            if health_percent >= 0 then
                local health_damage_percent = (1 - health_percent) * 0.5
                --print("血量加成", health_damage_percent)
                all_add_percent = all_add_percent + health_damage_percent * 100
            end
        end
    end
    if HH_UTILS:HasComponents(player, "hunger") then
        local hh_hungerAssault = self:GetEffectValueByKey("hungerAssault")
        if hh_hungerAssault > 0 then
            local hunger_percent = player["components"]["hunger"]:GetPercent()
            if hunger_percent >= 0 then
                local hunger_damage_percent = (1 - hunger_percent) * 0.5
                --print("饥饿加成", hunger_damage_percent)
                all_add_percent = all_add_percent + hunger_damage_percent * 100
            end
        end
    end
    if HH_UTILS:HasComponents(player, "sanity") then
        local hh_spiritFade = self:GetEffectValueByKey("spiritFade")
        if hh_spiritFade > 0 then
            local sanity_percent = player["components"]["sanity"]:GetPercent()
            if sanity_percent >= 0 then
                local sanity_damage_percent = (1 - sanity_percent) * 0.5
                --print("san加成", sanity_damage_percent)
                all_add_percent = all_add_percent + sanity_damage_percent * 100
            end
        end
    end
    --吗喽之力
    local monkey_god_value = self:GetEffectValueByKey("monkey_god")
    if monkey_god_value > 0 and HH_UTILS:HasComponents(player, "inventory") then
        local monkey_item_num = countInventoryItem(player, "cursed_monkey_token")
        --print("查询吗喽诅咒数量", monkey_item_num)
        --print("原加成", all_add_percent)
        --附带上限100%
        local add_percent_monkey = math["min"](monkey_god_value * monkey_item_num, 100)
        all_add_percent = all_add_percent + add_percent_monkey
        --print("吗喽加成后", all_add_percent)
    end

    amount = amount * (1 + all_add_percent / 100)
    -----------------多倍伤害-----------------------
    if self:HasSpecialEffect("moreDamage20To200") then
        local math_2 = math["random"]()
        if math_2 <= 0.2 then
            local add_percent_2 = self:GetEffectValueByKey("moreDamage20To200")
            amount = amount * (math["max"](add_percent_2 / 100, 1))
            HH_UTILS:SpawnClientStrFx(target, "双倍")
        end
    end
    if self:HasSpecialEffect("moreDamage10To300") then
        local math_3 = math["random"]()
        if math_3 <= 0.1 then
            local add_percent_3 = self:GetEffectValueByKey("moreDamage10To300")
            amount = amount * (math["max"](add_percent_3 / 100, 1))
            HH_UTILS:SpawnClientStrFx(target, "三倍")
        end
    end
    if self:HasSpecialEffect("moreDamage8To500") then
        local math_5 = math["random"]()
        if math_5 <= 0.08 then
            local add_percent_5 = self:GetEffectValueByKey("moreDamage8To500")
            amount = amount * (math["max"](add_percent_5 / 100, 1))
            HH_UTILS:SpawnClientStrFx(target, "五倍")
        end
    end
    -----------------多倍伤害-----------------------
    --暴击率
    local criticalHitRate = self:GetEffectValueByKey("criticalHitRate")
    --秋季战神-提升10暴击率
    if is_autumn_god and world_is_autumn then
        --print("原暴击率", criticalHitRate)
        criticalHitRate = criticalHitRate + 10 * autumn_god_value
        --print("秋季暴击加成", criticalHitRate)
    end
    if criticalHitRate > 0 then
        local random_num = math["random"](0, 100)
        if random_num <= criticalHitRate then
            --暴击增加特效
            HH_UTILS:SpawnExplodeFx(target)
            --额外暴击效果
            local criticalHitEffect = self:GetEffectValueByKey("criticalHitEffect")
            amount = amount * (2 + criticalHitEffect / 100)
            HH_UTILS:SpawnClientStrFx(target, "暴击")
        end
    end
    -------------------------特殊效果buff-----------------------------------
    if HH_UTILS:HasComponents(player, "hh_buff") then
        if amount > 0 then
            --攻击概率触发回血buff
            if self:HasSpecialEffect("attackToAddHealth") then
                local buff_10s_random = math["random"]()
                if buff_10s_random <= TUNING["HH_CHANCE_CONFIG"]["ATK_10s_HEALTH"] then
                    player["components"]["hh_buff"]:AddBuff("buff_10s_1_health", 10)
                end
            end
        end
    end
    if HH_UTILS:HasComponents(target, "hh_buff") and HH_UTILS:HasComponents(target, "hh_monster") then
        --攻击附带毒素
        local hh_atkAddPoisonChance = self:GetEffectValueByKey("atkAddPoisonChance")
        if hh_atkAddPoisonChance > 0 then
            local random_poison = math["random"](1, 100)
            if random_poison <= hh_atkAddPoisonChance then
                target["components"]["hh_buff"]:AddBuff("monster_poison", 60)
            end
        end
        if self:HasSpecialEffect("healthSuppressNum") then
            local random_suppress = math["random"](1, 100)
            if random_suppress <= 10 then
                target["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
            end
        end
    end
    -------------------------特殊效果buff-----------------------------------
    -------------------------附加百分比伤害-----------------------------------
    if self:HasSpecialEffect("targetPercentDamage") and HH_UTILS:HasComponents(target, "health")
            and HH_UTILS:IsHHType(target["components"]["health"]["currenthealth"], "number")
            and target["components"]["health"]["currenthealth"] > 0
            and HH_UTILS:IsValidCombat(target)
    then
        --增加校验免疫撕裂效果
        if HH_UTILS:HasComponents(target, "hh_monster")
                and not target["components"]["hh_monster"]:HasSpecialEffect("immuneTearing")
        then
            local hh_targetPercentDamage = self:GetEffectValueByKey("targetPercentDamage")
            local hh_current_health = target["components"]["health"]["currenthealth"]
            amount = amount + hh_current_health * (math["min"](hh_targetPercentDamage, 3) / 100)
        end
    end
    -------------------------附加百分比伤害-----------------------------------
    return amount
end
----
---受到的伤害进行数值转换
---
function HH_COMPONENTS:GetBlockDamage(player, attacker, amount)
    if not HH_UTILS:IsHHType(amount, "number") or amount <= 0 then
        return 0
    end

    if not HH_UTILS:HasComponents(player, "health") and player["components"]["health"]:IsDead() then
        return amount
    end
    --print("校验飞云逸影套装")
    --飞云逸影套装无负面闪避功能
    if self:HasSuitEffect("suit_fyyy") then
        --print("含有飞云逸影套装")
        local random_no_damage = math["random"]()
        if random_no_damage <= 0.3 then
            --print("飞云逸影免疫")
            --if HH_UTILS:HasComponents(self["inst"], "colouradder") then
            --    self["inst"]["components"]["colouradder"]:PushColour("suit_fyyy", 255 / 255, 242 / 255, 0 / 255, 0)
            --    if not self["inst"]["suit_fyyy_task"] then
            --        self["inst"]["suit_fyyy_task"] = self["inst"]:DoTaskInTime(0.1, function()
            --            if HH_UTILS:HasComponents(self["inst"], "colouradder") then
            --                self["inst"]["components"]["colouradder"]:PopColour("suit_fyyy")
            --            end
            --            HH_UTILS:HHKillTask(self["inst"], "suit_fyyy_task")
            --        end)
            --    end
            --end
            HH_UTILS:SpawnClientStrFx(self["inst"], "闪避")
            HH_UTILS:SpawnClientStrFx(self["inst"], "飞云逸影触发")
            return 0
        end
    end
    if HH_UTILS:HasComponents(player, "sanity") then
        --暗影护盾
        local hh_sanReplaceDamageChance = self:GetEffectValueByKey("sanReplaceDamageChance")
        if hh_sanReplaceDamageChance > 0 then
            --加上限
            hh_sanReplaceDamageChance = math["min"](hh_sanReplaceDamageChance, 80)
            local random_san = math["random"](1, 100)
            if random_san <= hh_sanReplaceDamageChance then
                local san_delta = math["abs"](amount)
                player["components"]["sanity"]:DoDelta(-san_delta)
                HH_UTILS:SpawnShadowFx(player)
                return 0
            end
        end
    end
    --受击减免
    local hh_reduceAttackedDamage = self:GetEffectValueByKey("reduceAttackedDamage")
    amount = amount - hh_reduceAttackedDamage
    if HH_UTILS:HasComponents(attacker, "combat") then
        --固定反伤
        local hh_reflexiveInjury = self:GetEffectValueByKey("reflexiveInjury")
        --print("反伤", hh_reflexiveInjury)
        if hh_reflexiveInjury > 0 then
            if attacker["components"]["combat"]["GetBrambleFx"] then
                attacker["components"]["combat"]:GetBrambleFx(player, hh_reflexiveInjury)
            end
        end
    end
    --百分比减伤 固定减伤之前
    local hh_absorbDamage = self:GetEffectValueByKey("absorbDamage")
    if hh_absorbDamage and hh_absorbDamage > 0 then
        local current_absorb = math["min"](hh_absorbDamage / 100, 0.8)
        --print("原伤害", amount, "减伤", current_absorb)
        amount = amount * (1 - current_absorb)
        --print("现伤害", amount)
    end

    local result_damage = math["max"](amount, 0)
    --白虎套装会增加受到的伤害
    if self:HasSuitEffect("suit_bhtg") then
        result_damage = result_damage * 1.2
    end
    return result_damage
end

----
---处理吸血和吸san
---
function HH_COMPONENTS:HandleBloodSuck(amount)
    if NotIsDead(self["inst"]) then
        local health_delta = math["abs"](amount)
        local hh_blood_suck = self["inst"]["components"]["hh_player"]:GetEffectValueByKey("bloodSuck")
        if hh_blood_suck > 0 then
            local add_health = health_delta * hh_blood_suck / 100
            --print("吸血", add_health)
            self["inst"]["components"]["health"]:DoDelta(add_health, true, "bloodSuck")
        end
        local hh_san_suck = self["inst"]["components"]["hh_player"]:GetEffectValueByKey("restoreSpirit")
        if hh_san_suck > 0 and HH_UTILS:HasComponents(self["inst"], "sanity") then
            local add_san = health_delta * hh_san_suck / 100
            --print("吸蓝", add_san)
            self["inst"]["components"]["sanity"]:DoDelta(add_san)
        end
    end
end
-----
---随从强化伤害
---
function HH_COMPONENTS:GetFollowerDamage(damage)
    if not HH_UTILS:IsHHType(damage, "number") or damage < 0 then
        return 0
    end
    if self:HasSpecialEffect("addFollowDamage") then
        local add_damage = self:GetEffectValueByKey("addFollowDamage")
        damage = add_damage + damage
    end
    return damage
end
-----
---随从强化减伤
---
function HH_COMPONENTS:GetFollowerArmor(damage)
    if not HH_UTILS:IsHHType(damage, "number") or damage <= 0 then
        return 0
    end
    if self:HasSpecialEffect("addFollowReduceDamage") then
        local hh_armor = self:GetEffectValueByKey("addFollowReduceDamage")
        damage = damage - hh_armor
    end
    return math["max"](damage, 0)
end
----
---受到的反甲效果
---
function HH_COMPONENTS:GetHitByBrambleFxDamage(amount)
    if not HH_UTILS:IsHHType(amount, "number") or amount <= 0 then
        return 0
    end
    --减伤
    local reduceAttackedDamage = self:GetEffectValueByKey("reduceAttackedDamage")
    amount = amount - reduceAttackedDamage
    local hh_reduceBrambleDamage = self:GetEffectValueByKey("reduceBrambleDamage")
    if hh_reduceBrambleDamage > 0 then
        amount = math["max"](0, amount * (1 - hh_reduceBrambleDamage / 100))
    end
    return math["max"](amount, 0)
end
----
---一些特殊属性 值大于0就算生效
---
function HH_COMPONENTS:HasSpecialEffect(effect_name)
    local special_value = self:GetEffectValueByKey(effect_name)
    return special_value > 0
end
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function HH_COMPONENTS:HasItemsByKey(item_name)
    if HH_UTILS:IsHHType(item_name, "string")
            and self["hh_items"][item_name]
            and HH_UTILS:IsHHType(self["hh_items"][item_name], "number")
            and self["hh_items"][item_name] > 0
            and HH_ITEMS_CONFIG[item_name]
    then
        return true
    end
    return false
end
function HH_COMPONENTS:GetItemsByKey(item_name)
    if HH_UTILS:IsHHType(item_name, "string")
            and self["hh_items"][item_name]
            and HH_UTILS:IsHHType(self["hh_items"][item_name], "number")
            and self["hh_items"][item_name] > 0
            and HH_ITEMS_CONFIG[item_name]
    then
        return self["hh_items"][item_name]
    end
    return 0
end
----
---特殊物品计数
---@param item_name:道具id
---@param item_num:数量
---@param need_show:是否提示玩家
---
function HH_COMPONENTS:AddItemsByKey(item_name, item_num, need_show)
    --print("增加物品")
    if not HH_UTILS:IsHHType(item_name, "string")
            or not self["hh_items"][item_name]
            or not HH_UTILS:IsHHType(self["hh_items"][item_name], "number")
            or not HH_ITEMS_CONFIG[item_name]
    then
        --print("非法物品！！")
        return false
    end
    --print("增加成功")
    local addNum = item_num or 1
    local oldNum = self["hh_items"][item_name]
    --增加上限
    self["hh_items"][item_name] = math["min"](oldNum + addNum, 9999)
    local client_table = createItemTable(self["hh_items"])
    HH_UTILS:HHClientRpc(self["inst"], "hh_items", HH_UTILS:TableToStr(client_table))
    --给玩家提示
    if need_show and HH_ITEMS_CONFIG[item_name]["name"] then
        --if self["inst"]["hh_tips_cd"] then
        --    --print("在cd")
        --    return
        --end
        HH_UTILS:SpawnTextFx(self["inst"], string.format("获得:%s%s个", tostring(HH_ITEMS_CONFIG[item_name]["name"]), tostring(item_num)))
        --self["inst"]["hh_tips_cd"] = true
        --self["inst"]:DoTaskInTime(0.5, function()
        --    self["inst"]["hh_tips_cd"] = false
        --end)
    end
    return true
end
function HH_COMPONENTS:RemoveItemsByKey(item_name, item_num)
    if not HH_UTILS:IsHHType(item_name, "string")
            or not self["hh_items"][item_name]
            or not HH_UTILS:IsHHType(self["hh_items"][item_name], "number")
            or not HH_ITEMS_CONFIG[item_name]
    then
        --print("非法物品！！")
        return false
    end
    local addNum = item_num or 1
    local oldNum = self["hh_items"][item_name]
    if oldNum < addNum then
        --print("物品数量不足")
        return false
    end
    self["hh_items"][item_name] = oldNum - addNum
    local client_table = createItemTable(self["hh_items"])
    HH_UTILS:HHClientRpc(self["inst"], "hh_items", HH_UTILS:TableToStr(client_table))
    return true
end
---------------------------------------------------------------------------------------
function HH_COMPONENTS:SpawnContainer()
    if self["ui_container"] == nil then
        local chester = SpawnPrefab("hh_ui_container")
        if chester then
            SetChester(self, chester, "ui_container")
        end
    end
end
function HH_COMPONENTS:SpawnForgeContainer()
    if self["forge_container"] == nil then
        local chester = SpawnPrefab("hh_forge_container")
        if chester then
            SetChester(self, chester, "forge_container")
        end
    end
end
---打开随身容器
function HH_COMPONENTS:OpenContainer(ui_name)
    if HH_UTILS:HasComponents(self[ui_name], "container") then
        if self[ui_name]["components"]["container"]:IsOpenedBy(self["inst"]) then
            self[ui_name]["components"]["container"]:Close(self["inst"])
        else
            --刷新页面 防止不显示
            local client_table = createItemTable(self["hh_items"])
            HH_UTILS:HHClientRpc(self["inst"], "hh_items", HH_UTILS:TableToStr(client_table))
            self[ui_name]["components"]["container"]:Open(self["inst"])
            --关闭定时函数 防止合成台ui再打开时 打开附魔页面 任务还在
            HH_UTILS:HHKillTask(self["inst"], "hh_suit_check_task")
        end
    end
end
function HH_COMPONENTS:OpenSuitContainer()
    if HH_UTILS:HasComponents(self["forge_container"], "container") then
        if self["forge_container"]["components"]["container"]:IsOpenedBy(self["inst"]) then
            self["forge_container"]["components"]["container"]:Close(self["inst"])
            HH_UTILS:HHKillTask(self["inst"], "hh_suit_check_task")
        else
            --刷新页面 防止不显示
            local client_table = createItemTable(self["hh_items"])
            HH_UTILS:HHClientRpc(self["inst"], "hh_items", HH_UTILS:TableToStr(client_table))
            self:UpdateForgeEquipInfo()
            HH_UTILS:ForgeStoneClient(self["forge_container"])
            self["forge_container"]["components"]["container"]:Open(self["inst"])
            HH_UTILS:HHKillTask(self["inst"], "hh_suit_check_task")
            --超过6码自动关闭
            self["inst"]["hh_suit_check_task"] = self["inst"]:DoPeriodicTask(1, function()
                if not self["inst"]["suit_hh_guid"] then
                    HH_UTILS:HHKillTask(self["inst"], "hh_suit_check_task")
                    return
                end
                local x, y, z = self["inst"]["Transform"]:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 6, { "hh_suit_build" })
                local bool = true
                for i, v in ipairs(ents) do
                    if v and v["GUID"] and v["GUID"] == self["inst"]["suit_hh_guid"] then
                        bool = false
                        break
                    end
                end
                if bool then
                    self:OpenSuitContainer()
                end
            end)
        end
    end
end
----
---关闭俩个容器
---
function HH_COMPONENTS:CloseAllContainer()
    HH_UTILS:HHKillTask(self["inst"], "hh_suit_check_task")
    local player = self["inst"]
    local forge_inst = self["forge_container"]
    local con_inst = self["ui_container"]
    if HH_UTILS:HasComponents(forge_inst, "container") and forge_inst["components"]["container"]:IsOpenedBy(player) then
        forge_inst["components"]["container"]:Close(player)
    end
    if HH_UTILS:HasComponents(con_inst, "container") and con_inst["components"]["container"]:IsOpenedBy(player) then
        con_inst["components"]["container"]:Close(player)
    end
end
----
---刷新装备词条显示
---
function HH_COMPONENTS:UpdateForgeEquipInfo()
    if not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return
    end
    local container_components = self["forge_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(1)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return
    end
    local equip_effects = hh_equip["components"]["hh_equip"]["equip_buff_list"]
    HH_UTILS:HHClientRpc(self["inst"], "hh_forge_equip", HH_UTILS:TableToStr(equip_effects))
end
---------------------------------------------装备附魔处理------------------------------------------------
----
---增加装备附魔词条
---
function HH_COMPONENTS:AddEquipEffect()
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在!!!"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(25)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请在指定的格子放入正确的装备!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行附魔操作!!!"
    end
    local hh_stone = container_components:GetItemInSlot(26)
    if not hh_stone or not hh_stone["prefab"] or not hh_stone:HasTag("hh_add_stone") then
        return false, "请放入正确的附魔道具！！！"
    end
    if hh_stone["prefab"] == "hh_effect_tally" then
        if not HH_UTILS:HasComponents(hh_stone, "stackable") then
            return false, "禁止使用被修改过属性的道具"
        end
        --随机附魔
        local success, result = hh_equip["components"]["hh_equip"]:AddEquipBuff(nil)
        if not success then
            return false, result
        end
        removeStackableItems(hh_stone)
        return true, "附魔成功"
    elseif hh_stone["prefab"] == "hh_effect_stone" then
        --指定附魔
        local hh_effect_id = hh_stone["hh_effect"]
        if not HH_UTILS:IsHHType(hh_effect_id, "string")
                or not HH_EQUIP_BUFF_LIST[hh_effect_id]
        then
            return false, "请通过正常途径获取含有词条的附魔石！！！"
        end
        if HH_UTILS:HasComponents(hh_stone, "stackable") then
            return false, "禁止叠加附魔石！！！！！！！！！！"
        end
        local success, result = hh_equip["components"]["hh_equip"]:AddEquipBuff(hh_effect_id)
        if not success then
            return false, result
        end
        --附魔石不允许叠加
        hh_stone:Remove()
        return true, "附魔成功"
    else
        return false, "未识别的附魔道具"
    end
end
----
---清除装备附魔词条
---
function HH_COMPONENTS:RemoveEquipEffect()
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在!!!"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(25)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请在指定的格子放入正确的装备!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行附魔操作!!!"
    end

    local hh_stone = container_components:GetItemInSlot(27)
    if not hh_stone or not hh_stone["prefab"]
            or not hh_stone:HasTag("hh_remove_stone")
    then
        return false, "请在指定格子放入清除道具!!!"
    end
    if not HH_UTILS:HasComponents(hh_stone, "stackable") then
        return false, "禁止使用被修改过属性的道具"
    end
    local success, result = hh_equip["components"]["hh_equip"]:ReduceEquipBuffByIndex(nil)
    if not success then
        return false, result
    end
    removeStackableItems(hh_stone)
    return true, "清除成功"
end
----
---批量清除指定位置附魔词条
---
function HH_COMPONENTS:RemoveMoreEquipEffect(index_list)
    if not HH_UTILS:IsHHType(index_list, "table") then
        return false, "定向清除词条入参错误"
    end
    if not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return false, "容器不存在!!!"
    end
    local container_components = self["forge_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(1)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请在指定的格子放入正确的装备!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行附魔操作!!!"
    end
    local need_num = 0
    for i, v in ipairs(index_list) do
        if v == true then
            need_num = need_num + 1
        end
    end
    if need_num <= 0 then
        return false, "未选中清除的词条"
    end
    local has_num = self:GetItemsByKey("z_clean_stone")
    if has_num < need_num then
        return false, "净化符数量不足"
    end
    local success, success_num, result = hh_equip["components"]["hh_equip"]:ReduceMoreEquipBuff(index_list)
    if success then
        --print(success_num)
        self:RemoveItemsByKey("z_clean_stone", success_num)
        --同步客机
        self:UpdateForgeEquipInfo()
        return true, result
    else
        return false, result
    end
end
----
---合成套装属性
---
function HH_COMPONENTS:CompositeSuitEffect(suit_id)
    if not HH_EQUIP_BUFF_LIST[suit_id] or not HH_EQUIP_BUFF_LIST[suit_id]["recipe"]
            or not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return false, "套装词条格式错误"
    end
    local hh_table = { 2, 3, 4, 5 }
    local hh_client = {}
    for i, v in ipairs(hh_table) do
        local hh_item = self["forge_container"]["components"]["container"]:GetItemInSlot(v)
        if hh_item and hh_item["prefab"] == "hh_effect_stone"
                and hh_item["hh_effect"]
        then
            table["insert"](hh_client, hh_item["hh_effect"])
        else
            return false, "请放入正确道具-含有词条的附魔石"
        end
    end
    if not HH_UTILS:HHCompareTable(HH_EQUIP_BUFF_LIST[suit_id]["recipe"], hh_client) then
        return false, "附魔石和配方顺序不同，合成失败"
    end
    for i, v in ipairs(hh_table) do
        local hh_item = self["forge_container"]["components"]["container"]:GetItemInSlot(v)
        if hh_item then
            hh_item:Remove()
        end
    end
    local player_pos = self["inst"]:GetPosition()
    local effect_stone = SpawnPrefab("hh_effect_stone")
    if effect_stone then
        effect_stone["hh_effect"] = suit_id
        if effect_stone["HH_Update_Server"] then
            effect_stone:HH_Update_Server()
        end
        --兼容一下皮肤
        HH_UTILS:UpdateSkinItem(self["inst"], effect_stone)
        self["forge_container"]["components"]["container"]:GiveItem(effect_stone, 2, player_pos)
    end
end
----
---合成套装属性
---
function HH_COMPONENTS:EquipEffectInherit()
    if not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return false, "未查到容器"
    end
    local father_item = self["forge_container"]
    local father_container = father_item["components"]["container"]
    local old_equip = father_container:GetItemInSlot(2)
    local new_equip = father_container:GetItemInSlot(3)
    if not HH_UTILS:HasComponents(old_equip, "equippable") or not HH_UTILS:HasComponents(new_equip, "equippable") then
        return false, "未放入装备"
    end
    if not HH_UTILS:HasComponents(old_equip, "hh_equip") or not HH_UTILS:HasComponents(new_equip, "hh_equip") then
        return false, "装备位置存在无法强化的装备"
    end
    local old_equip_com = old_equip["components"]["hh_equip"]
    local new_equip_com = new_equip["components"]["hh_equip"]
    local old_effect_num = old_equip_com:GetEffectsNum()
    local new_effect_num = new_equip_com:GetEffectsNum()
    if old_effect_num <= 0 or new_effect_num > 0 then
        return false, "原装备需要含有词条，继承后的装备初始状态不允许存在词条"
    end
    if not father_container:Has("hh_essence", 20)
            or not father_container:Has("nightmarefuel", 20)
    then
        return false, "材料不足"
    end
    local old_equip_effects = old_equip_com["equip_buff_list"]
    if not HH_UTILS:IsHHType(old_equip_effects, "table") then
        return false, "原装备查询词条错误"
    end
    for i, v in ipairs(old_equip_effects) do
        if v and v["name"] then
            new_equip_com:AddEquipBuff(v["name"], v["value"])
        end
    end
    father_container:ConsumeByName("hh_essence", 20)
    father_container:ConsumeByName("nightmarefuel", 20)
    -----------------------------宝石-----------------------------
    --宝石部分处理
    local old_gem_effects = old_equip_com["gems_list"]
    if HH_UTILS:IsHHType(old_gem_effects, "table") then
        for i, v in ipairs(old_gem_effects) do
            if HH_UTILS:IsHHType(v, "string") and HH_GEM_BUFF_LIST[v] then
                --先打孔再镶嵌
                new_equip_com:AddGemCurrentLimit()
                new_equip_com:AddNewGem(v)
            end
        end
    end
    -----------------------------宝石-----------------------------
    old_equip:Remove()
    return true, "继承成功"
end
----
---附魔石转换
---
function HH_COMPONENTS:AddReplaceStone()
    if not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return false, "未查到容器"
    end
    local player_inst = self["inst"]
    local father_item = self["forge_container"]
    local father_container = father_item["components"]["container"]
    local slot_02 = father_container:GetItemInSlot(2)
    local player_pos = self["inst"]:GetPosition()
    local inst_name = self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
    if not slot_02 or slot_02["prefab"] ~= "hh_effect_stone" then
        return false, "第一格放附魔石"
    end
    if not father_container:Has("hh_essence", 5) then
        return false, string["format"]("水晶小人数量不足-数量>=%s", 5)
    end
    --稀有和超稀有的附魔石不允许转换
    local old_effect = slot_02["hh_effect"]
    if HH_EQUIP_BUFF_LIST[old_effect] and not HH_EQUIP_BUFF_LIST[old_effect]["can_add"] then
        return false, "只能转换普通附魔石"
    end
    local random_num = math["random"](1, 100)
    local spawn_new_stone = nil
    local has_good = false
    --已经消耗的水晶小人数量
    local base_expend_essence_num = 5
    local current_expend_essence = HH_UTILS:GetPlayerDataByKey(player_inst, "expend_essence")
    if random_num <= 1 then
        spawn_new_stone = _G["HHSpawnRareEffectStone"]()
        if spawn_new_stone and spawn_new_stone["hh_effect"] then
            local random_effect = spawn_new_stone["hh_effect"]
            local hh_str = HH_EQUIP_BUFF_LIST[random_effect] and HH_EQUIP_BUFF_LIST[random_effect]["name"] or "???"
            TheNet:Announce(string["format"]("%s好运当头，合成出:超超超稀有的%s", tostring(inst_name), tostring(hh_str)))
            --增加世界日志
            HH_UTILS:AddLog("stone", HH_UTILS:Template(getLogLanguage("compound_stone_rare"),
                    {
                        ["data_player"] = inst_name,
                        ["data_effect"] = hh_str,
                        ["data_essence"] = base_expend_essence_num + current_expend_essence,
                    }))
            has_good = true
        end
    elseif random_num <= 5 then
        spawn_new_stone = _G["HHSpawnGoodEffectStone"]()
        --增加播报
        if spawn_new_stone and spawn_new_stone["hh_effect"] then
            local random_effect = spawn_new_stone["hh_effect"]
            local hh_str = HH_EQUIP_BUFF_LIST[random_effect] and HH_EQUIP_BUFF_LIST[random_effect]["name"] or "???"
            TheNet:Announce(string["format"]("%s运气爆棚，合成出-%s", tostring(inst_name), tostring(hh_str)))
            --增加世界日志
            HH_UTILS:AddLog("stone", HH_UTILS:Template(getLogLanguage("compound_stone_best"),
                    {
                        ["data_player"] = inst_name,
                        ["data_effect"] = hh_str,
                        ["data_essence"] = base_expend_essence_num + current_expend_essence,
                    }))
            --has_good=true
        end
    else
        spawn_new_stone = _G["HHSpawnComEffectStone"]()
    end
    if not spawn_new_stone then
        return false, "生成附魔石异常"
    end
    --兼容一下皮肤
    HH_UTILS:UpdateSkinItem(self["inst"], spawn_new_stone)
    --登记一下抽奖次数-用于发送特殊蛋奖励
    if HH_UTILS:HasComponents(player_inst, "hh_data") then
        if has_good then
            player_inst["components"]["hh_data"]:SetParamsValue("draw_lots_num_rare", 0)
        else
            player_inst["components"]["hh_data"]:DoDeltaParamValue("draw_lots_num_rare", 1)
        end
        --记录一下消耗的水晶小人 后续可能会做数据统计相关
        player_inst["components"]["hh_data"]:DoDeltaParamValue("expend_essence", base_expend_essence_num)
    end
    slot_02:Remove()
    father_container:ConsumeByName("hh_essence", base_expend_essence_num)
    father_container:GiveItem(spawn_new_stone, 2, player_pos)
    return true, "合成成功"
end
----
---合成套装词条
---
function HH_COMPONENTS:CompoundEquipEffect(effect_id)
    if not HH_UTILS:IsHHType(effect_id, "string") or not HH_EQUIP_BUFF_LIST[effect_id] then
        return false, "非法词条"
    end
    if not HH_UTILS:HasComponents(self["forge_container"], "container") then
        return false, "未查到容器"
    end
    if not HH_UTILS:HasComponents(self["inst"], "inventory") then
        return false, "物品栏不存在"
    end
    local father_item = self["forge_container"]
    local father_container = father_item["components"]["container"]
    local recipe_config = nil
    for i, v in ipairs(HH_SUIT_RECIPE_LIST) do
        if v["id"] == effect_id and v["recipe"] then
            recipe_config = v["recipe"]
            break
        end
    end
    if not recipe_config then
        return false, "未查询到对应配方"
    end
    for i, v in ipairs(recipe_config) do
        local prefab_id = v["id"]
        local prefab_num = v["num"] or 1
        if not father_container:Has(prefab_id, prefab_num) then
            return false, "材料数量不足"
        end
    end

    for i, v in ipairs(recipe_config) do
        local prefab_id = v["id"]
        local prefab_num = v["num"] or 1
        father_container:ConsumeByName(prefab_id, prefab_num)
    end
    --local player_pos = self["inst"]:GetPosition()
    local effect_stone = SpawnPrefab("hh_effect_stone")
    if effect_stone then
        effect_stone["hh_effect"] = effect_id
        if effect_stone["HH_Update_Server"] then
            effect_stone:HH_Update_Server()
        end
        --兼容一下皮肤
        HH_UTILS:UpdateSkinItem(self["inst"], effect_stone)
        self["inst"]["components"]["inventory"]:GiveItem(effect_stone)
        if TheNet then
            --增加公告播报
            local inst_name = self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
            local hh_effect_name = HH_EQUIP_BUFF_LIST[effect_id]["name"]
            TheNet:Announce(string["format"]("%s合成出-%s", tostring(inst_name), tostring(hh_effect_name)))
        end
    end
    return true, "合成成功"
end
----
---更新装备附魔词条
---
function HH_COMPONENTS:UpdateEffectValue()
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在!!!"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(25)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请在指定的格子放入正确的装备!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行附魔操作!!!"
    end
    if not self:HasItemsByKey("a_refreshStone") then
        return false, "重置宝石数量不足"
    end
    local success, result = hh_equip["components"]["hh_equip"]:UpdateEffectValue()
    if not success then
        return false, result
    end
    self:RemoveItemsByKey("a_refreshStone", 1)
    return true, "重置成功!!"
end
---------------------------------------------装备附魔处理------------------------------------------------
---
---特殊装备强化
---
function HH_COMPONENTS:EquipUpgradingV1()
    local forge_inst = self["forge_container"]
    if not HH_UTILS:HasComponents(forge_inst, "container") then
        return false, "附魔空间不存在!"
    end
    local container_components = forge_inst["components"]["container"]
    local hh_boss_equip = container_components:GetItemInSlot(2)
    --if HH_UTILS:HasComponents(hh_boss_equip, "hh_hat_star") then
    --    return hh_boss_equip["components"]["hh_hat_star"]
    --end
    if true then
        return true, "暂未开放(不想写了)"
    end
    return false, "无法强化!"
end
----
---升星
---
function HH_COMPONENTS:EquipAddStarV1()
    local forge_inst = self["forge_container"]
    if not HH_UTILS:HasComponents(forge_inst, "container") then
        return false, "附魔空间不存在!"
    end
    local container_components = forge_inst["components"]["container"]
    local hh_boss_equip = container_components:GetItemInSlot(2)
    if HH_UTILS:HasComponents(hh_boss_equip, "hh_hat_star") then
        local success, result = hh_boss_equip["components"]["hh_hat_star"]:AddStarByRpc(self["inst"], forge_inst)
        --升星完同步一下客户端数据
        self:GetForgeEquipInfo()
        return success, result
    end
    return false, "无法强化!"
end
function HH_COMPONENTS:FixStarEquipV1()
    local forge_inst = self["forge_container"]
    if not HH_UTILS:HasComponents(forge_inst, "container") then
        return false, "附魔空间不存在!"
    end
    local container_components = forge_inst["components"]["container"]
    local hh_boss_equip = container_components:GetItemInSlot(2)
    if HH_UTILS:HasComponents(hh_boss_equip, "hh_hat_star") then
        local success, result = hh_boss_equip["components"]["hh_hat_star"]:FixEquipByRpc(self["inst"], forge_inst)
        --同步一下客户端数据
        self:GetForgeEquipInfo()
        return success, result
    end
    return false, "无法强化!"
end
----
---获取第二格装的服务端信息
---
function HH_COMPONENTS:GetForgeEquipInfo()
    local forge_inst = self["forge_container"]
    if not HH_UTILS:HasComponents(forge_inst, "container") then
        return false, nil
    end
    local container_components = forge_inst["components"]["container"]
    local hh_boss_equip = container_components:GetItemInSlot(2)
    if HH_UTILS:HasComponents(hh_boss_equip, "hh_hat_star") then
        local server_equip_info = hh_boss_equip["components"]["hh_hat_star"]:GetEquipInfo(forge_inst)
        HH_UTILS:HHClientRpc(self["inst"], "forge_star_equip_info", HH_UTILS:TableToStr(server_equip_info))
        return true, nil
    end
    HH_UTILS:HHClientRpc(self["inst"], "forge_star_equip_info", HH_UTILS:TableToStr({}))
    return false, nil
end
---------------------------------------------装备宝石处理-------------------------------------------------
----
---打孔
---
function HH_COMPONENTS:AddEquipGemsLimit()
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在，无法拆解!!!"
    end
    if not self:HasItemsByKey("a_punchStone") then
        --print("打孔符数量不足")
        return false, "打孔符数量不足"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(28)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请放入正确的装备!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行操作!!!"
    end
    local success, result = hh_equip["components"]["hh_equip"]:AddGemCurrentLimit()
    if not success then
        return false, result
    end
    self:RemoveItemsByKey("a_punchStone", 1)
    return true, "打孔成功!!"
end
----
---装备增加宝石
---
function HH_COMPONENTS:AddEquipGems(gem_name)
    if not self:HasItemsByKey(gem_name) then
        --print("宝石数量不足")
        return false, "宝石数量不足"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(28)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请放入正确的装备用于镶嵌宝石!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行操作!!!"
    end
    local has_empty_groove = hh_equip["components"]["hh_equip"]:HasEmptyGroove()
    if not has_empty_groove then
        return false, "当前装备没有空余的凹槽，请先打孔/拆除已有的宝石"
    end
    local result, desc = hh_equip["components"]["hh_equip"]:AddNewGem(gem_name)
    if result then
        self:RemoveItemsByKey(gem_name, 1)
    end
    return result, desc
end
----
---装备清除宝石
---
function HH_COMPONENTS:RemoveEquipGems(gem_index)
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在，无法拆解!!!"
    end
    if not self:HasItemsByKey("a_stoneDecoder") then
        return false, "解石器数量不足"
    end
    local container_components = self["ui_container"]["components"]["container"]
    local hh_equip = container_components:GetItemInSlot(28)
    if not HH_UTILS:HasComponents(hh_equip, "hh_equip") then
        return false, "请放入正确的装备用于拆解宝石!!!"
    end
    if HH_UTILS:HasComponents(hh_equip, "stackable") then
        return false, "禁止叠加装备进行操作!!!"
    end
    local result, desc = hh_equip["components"]["hh_equip"]:ReduceGemByIndex(gem_index)
    if result then
        self:RemoveItemsByKey("a_stoneDecoder", 1)
    end
    return result, desc
end

----
---外挂道具
---
function HH_COMPONENTS:UseSpecialItem(item_index)
    if not HH_UTILS:IsHHType(item_index, "string")
            or not HH_ITEMS_CONFIG[item_index]
            or not HH_ITEMS_CONFIG[item_index]["is_item"]
            or not HH_UTILS:IsHHType(HH_ITEMS_CONFIG[item_index]["item_fn"], "function")
    then
        return false, "道具不存在"
    end
    if not self:HasItemsByKey(item_index) then
        return false, "道具数量不足"
    end
    local success, result = pcall(HH_ITEMS_CONFIG[item_index]["item_fn"], self["inst"])
    --print(success, result)
    if success then
        self:RemoveItemsByKey(item_index, 1)
    end
    return true, "道具使用成功"
end
---------------------------------------------装备宝石处理-------------------------------------------------
----
---一键拆解装备
---
function HH_COMPONENTS:RemoveEquips()
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "容器不存在，无法拆解!!!"
    end
    local remove_num = 0
    local container_inst = self["ui_container"]
    local player_pos = self["inst"]:GetPosition()
    local container_components = container_inst["components"]["container"]
    for i = 1, hh_container_pag do
        local hh_slot = container_components:GetItemInSlot(i)
        if hh_slot and HH_UTILS:HasComponents(hh_slot, "hh_equip") then
            local effect_num = hh_slot["components"]["hh_equip"]:GetEffectsNum()
            local can_spawn_stone = true
            --随机的词条id
            local random_effect_name = hh_slot["components"]["hh_equip"]:GetRandomEffect()
            if effect_num < 3 then
                local chance = math["random"]()
                if chance > 0.1 then
                    can_spawn_stone = false
                end
            end
            remove_num = remove_num + 1
            hh_slot:Remove()
            if effect_num > 0 and can_spawn_stone then
                --print("生成附魔石-词条:", random_effect_name)
                local effect_stone = SpawnPrefab("hh_effect_stone")
                if effect_stone then
                    effect_stone["hh_effect"] = random_effect_name
                    --print(random_effect_name)
                    local goodEffectList = HHGetGoodEquipEffect()
                    if HH_UTILS:IsHHType(goodEffectList, "table") and HH_UTILS:IsHHType(random_effect_name, "string")
                            and HH_EQUIP_BUFF_LIST[random_effect_name]
                            and table["contains"](goodEffectList, random_effect_name) and TheNet then
                        --增加公告播报
                        local inst_name = self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
                        local hh_effect_str = HH_EQUIP_BUFF_LIST[random_effect_name]["name"]
                        TheNet:Announce(string["format"]("%s拆解出词条-%s", tostring(inst_name), tostring(hh_effect_str)))
                    end
                    --先赋值 防止容器里第一次不显示图标
                    if effect_stone["HH_Update_Server"] then
                        effect_stone:HH_Update_Server()
                    end
                    --兼容一下皮肤
                    HH_UTILS:UpdateSkinItem(self["inst"], effect_stone)
                    container_components:GiveItem(effect_stone, nil, player_pos)
                end
            end
        end
    end
    --print("拆除装备数量:", remove_num)
end
----
---一键放入装备
---
function HH_COMPONENTS:MoveEquips()
    if not HH_UTILS:HasComponents(self["inst"], "inventory") or not NotIsDead(self["inst"]) then
        return false, "当前状态禁止交互!!!"
    end
    if not HH_UTILS:HasComponents(self["ui_container"], "container") then
        return false, "查询绑定容器失败!!!"
    end
    local has_empty_slot = false
    local can_move_equip_num = 0
    local hh_container_prefab = self["ui_container"]
    for i = 1, hh_container_pag do
        local hh_slot = hh_container_prefab["components"]["container"]:GetItemInSlot(i)
        if not hh_slot then
            has_empty_slot = true
            can_move_equip_num = can_move_equip_num + 1
        end
    end
    if not has_empty_slot then
        return false, "拆解区域格子已满！！！"
    end
    local player_pos = self["inst"]:GetPosition()
    local move_success_num = 0
    local hh_container_com = hh_container_prefab["components"]["container"]
    local player_inventory = self["inst"]["components"]["inventory"]
    --ThePlayer.Transform:SetPosition(0,0,0)
    local hh_inventory_slots = player_inventory["itemslots"]
    if hh_inventory_slots then
        for i, v in pairs(hh_inventory_slots) do
            if HH_UTILS:HasComponents(v, "hh_equip") then
                local items = v
                player_inventory:DropItem(items)
                hh_container_com:GiveItem(items, nil, player_pos)
                move_success_num = move_success_num + 1
                if move_success_num >= can_move_equip_num then
                    break
                end
            end
        end
    end
    if move_success_num >= can_move_equip_num then
        return true, "移动成功！！！"
    end
    --local body_slot_inst = player_inventory:GetEquippedItem(EQUIPSLOTS["BODY"])
    --if HH_UTILS:HasComponents(body_slot_inst, "container") then
    --    local body_container = body_slot_inst["components"]["container"]
    --    for k = 1, body_container["numslots"] do
    --        local body_slot = body_container:GetItemInSlot(k)
    --        if body_slot and HH_UTILS:HasComponents(body_slot, "hh_equip") then
    --            body_container:DropItemBySlot(k)
    --            hh_container_com:GiveItem(body_slot, nil, player_pos)
    --            move_success_num = move_success_num + 1
    --            if move_success_num >= can_move_equip_num then
    --                break
    --            end
    --        end
    --    end
    --end
    return true, "移动成功！！！"

end
function HH_COMPONENTS:OnSave()
    if self["ui_container"] ~= nil and self["forge_container"] ~= nil then
        return {
            ["pack"] = self["ui_container"]:GetSaveRecord(),
            ["forge"] = self["forge_container"]:GetSaveRecord(),
            ["hh_items"] = self["hh_items"],
            ["is_first"] = self["is_first"],
        }
    end
end

function HH_COMPONENTS:OnLoad(data)
    if not data or not data["pack"] then
        return
    end
    local chester = SpawnSaveRecord(data["pack"])
    SetChester(self, chester, "ui_container")
    --单独校验 用于兼容旧存档
    if data["forge"] then
        local forge_chester = SpawnSaveRecord(data["forge"])
        SetChester(self, forge_chester, "forge_container")
    end
    if not data["hh_items"] then
        return
    end
    self["hh_items"] = data["hh_items"]
    --同步更新新物品
    local gem_all_config = getItemConfig()
    for i, v in pairs(gem_all_config) do
        if i and not self["hh_items"][i] then
            self["hh_items"][i] = 0
        end
    end
    self["is_first"] = data["is_first"] or false
end
--------------------------------------------------debug-------------------------------------------------------------
function HH_COMPONENTS:TestSpawnStone(effect_name)
    if not HH_UTILS:IsHHType(effect_name, "string") or not HH_EQUIP_BUFF_LIST[effect_name]
            or not HH_UTILS:HasComponents(self["inst"], "inventory")
    then
        --print("生成附魔石错误", effect_name)
        return
    end
    local test_inst = SpawnPrefab("hh_effect_stone")
    if test_inst then
        test_inst["hh_effect"] = effect_name
        if test_inst["HH_Update_Server"] then
            test_inst:HH_Update_Server()
        end
        --兼容一下皮肤
        HH_UTILS:UpdateSkinItem(self["inst"], test_inst)
        self["inst"]["components"]["inventory"]:GiveItem(test_inst)
    end
end

function HH_COMPONENTS:TestSpawnAllStone()
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        self:TestSpawnStone(i)
    end
end
function HH_COMPONENTS:TestSpawnSuitStone(suit_id)
    if HH_SUIT_CONFIG[suit_id] and HH_SUIT_CONFIG[suit_id]["effect_list"] then
        for i, v in ipairs(HH_SUIT_CONFIG[suit_id]["effect_list"]) do
            self:TestSpawnStone(v)
        end
    end
end
--生成所有宝石
function HH_COMPONENTS:TestSpawnAllGem()
    for i, v in pairs(HH_ITEMS_CONFIG) do
        if HH_UTILS:IsHHType(v, "table") and not v["person_only"] then
            self:AddItemsByKey(i, 100)
        end
    end
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
local function launchitem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
end
----
---击杀掉落奖励
---
function HH_COMPONENTS:DropSpecialGif(target)
    --通用掉落宝石 卷轴函数
    if not HH_UTILS:IsValidCombat(target) then
        --print("攻击力为0不生成宝石")
        return
    end
    --小型生物不掉落卷轴和宝石
    local victim_prefab = target["prefab"]
    if small_target[victim_prefab] then
        return
    end
    if not self["inst"] or not NotIsDead(self["inst"])
            or not HH_UTILS:HasComponents(self["inst"], "inventory")
    then
        --print("当前状态禁止生成奖励")
        return
    end
    --怪物数量-堆叠类需要处理
    local hh_num = 1
    if HH_UTILS:HasComponents(target, "stackable") then
        hh_num = target["components"]["stackable"]["stacksize"]
        hh_num = math["max"](math["floor"](hh_num), 1)
    end
    for i = 1, hh_num do
        if not HH_UTILS:CheckWorldLimit("tally") then
            break
        end
        --掉率5%
        local base_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"]
        --local base_chance = 1
        local random_num = math["random"]()
        --生成附魔卷轴
        if random_num <= base_chance then
            local stone_chance = 0.5
            local stone_random = math["random"]()
            local hh_gif
            if stone_random >= stone_chance then
                hh_gif = SpawnPrefab("hh_effect_tally")
            else
                hh_gif = SpawnPrefab("hh_remove_stone")
            end
            if hh_gif and target["Transform"] then
                --掉地上 不再进入玩家身上
                local angle = math["random"](1, 360)
                local x, y, z = target["Transform"]:GetWorldPosition()
                hh_gif["Transform"]:SetPosition(x, 2.5, z)
                launchitem(hh_gif, angle)
                HH_UTILS:DoDeltaWorldLimit("tally", 1)
            end
        end
    end
    ------------生成专属道具------------------------
    local spawn_item_chance = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"]
    local random_item = math["random"]()
    if random_item <= spawn_item_chance then
        local item_name = GetRandomItem(target["prefab"])
        self:AddItemsByKey(item_name, 1, true)
    end
    --精英boss概率得宝石
    local hh_type = HH_UTILS:GetMonsterType(target) or getMonsterType(target["prefab"])
    if hh_type == "boss_monster" or hh_type == "elite_monster" then
        local chance_gem = 0.3
        if hh_type == "boss_monster" then
            chance_gem = 0.5
        end
        local random_punch = math["random"]()
        local random_refresh = math["random"]()
        if random_punch <= chance_gem then
            self:AddItemsByKey("a_punchStone", 1, true)
        end
        if random_refresh <= chance_gem then
            self:AddItemsByKey("a_refreshStone", 1, true)
        end
    end
    ------------生成专属道具------------------------
end
function HH_COMPONENTS:UseSaveStone(save_list)
    if not HH_UTILS:IsHHType(save_list, "table") then
        return false
    end
    for i, v in pairs(save_list) do
        if HH_UTILS:IsHHType(i, "string") and HH_UTILS:IsHHType(v, "number") and v >= 1 then
            self:AddItemsByKey(i, math["floor"](v))
        end
    end
    return true
end
local better_gem_list = {
    "treasure_atk",
    "treasure_bj",
    "treasure_armor",
}
----
---猫悠大王掉落宝石
---
function HH_COMPONENTS:DropRandomGem()
    local player = self["inst"]
    if not HH_UTILS:NotIsDead(player) then
        return
    end
    local random_num = math["random"](1, 100)
    if random_num <= 1 then
        local list_length = #better_gem_list
        local random_gem_index = math["random"](1, list_length)
        local gem_id = better_gem_list[random_gem_index]
        self:AddItemsByKey(gem_id, 1, true)
        --elseif random_num <= 5 then
        --    self:AddItemsByKey("a_refreshStone", 1, true)
        --elseif random_num <= 15 then
    else
        local item_name = GetRandomItem("cat_you")
        self:AddItemsByKey(item_name, 1, true)
    end
end
--------------------------------------------------debug-------------------------------------------------------------
--------------------------------------------------面板配置-------------------------------------------------------------
--------------------------------------------------面板配置-------------------------------------------------------------
--------------------------------------------------套装-------------------------------------------------------------
function HH_COMPONENTS:HasSuitEffect(suit_id)
    --if not HH_UTILS:IsHHType(suit_id, "string")
    --        or not HH_UTILS:IsHHType(HH_SUIT_CONFIG[suit_id], "table")
    --        or not HH_UTILS:IsHHType(HH_SUIT_CONFIG[suit_id]["effect_list"], "table")
    --then
    --    return false
    --end
    --for i, v in ipairs(HH_SUIT_CONFIG[suit_id]["effect_list"]) do
    --    if not self:HasSpecialEffect(v) then
    --        return false
    --    end
    --end
    --return true
    return false
end
--------------------------------------------------套装-------------------------------------------------------------
local debug_str_list = {
    { ["id"] = "criticalHitRate", ["format_str"] = "暴击率+%s%%", },
    { ["id"] = "criticalHitEffect", ["format_str"] = "暴击效果+%s%%", },
    { ["id"] = "addComDamage", ["format_str"] = "固定增伤+%s", },
    { ["id"] = "addComDamagePercent", ["format_str"] = "伤害加成+%s%%", },
    { ["id"] = "reduceAttackedDamage", ["format_str"] = "固定减伤+%s", },
    { ["id"] = "trueDamageNum", ["format_str"] = "穿刺+%s", },
    { ["id"] = "addSpeedPercent", ["format_str"] = "移速+%s%%", },
}
function HH_COMPONENTS:GetDebugStr()
    local debug_str = ""
    for i, v in ipairs(debug_str_list) do
        if v and v["id"] and v["format_str"] then
            local effect_id = v["id"]
            local effect_format = v["format_str"]
            --if self:HasSpecialEffect(v["id"]) then
            --GetEffectValueByKey
            local effect_value = self:GetEffectValueByKey(effect_id)
            local effect_str = string["format"](effect_format, tostring(effect_value))
            debug_str = debug_str .. effect_str
            if i < #debug_str_list then
                debug_str = debug_str .. "\n"
            end
            --end
        end
    end
    return debug_str
end
return HH_COMPONENTS
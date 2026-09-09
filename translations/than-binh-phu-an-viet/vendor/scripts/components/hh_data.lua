local HH_UTILS = require("utils/hh_utils")
local HH_DATA = require("enums/hh_data")
local function getLogLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end
----
---封装特殊参数-动态更新
---
local function getItemConfig()
    local hh_new_table = HH_UTILS:HHCopyTable(HH_DATA)
    local hh_items = {}
    for i, v in pairs(hh_new_table) do
        hh_items[i] = 0
    end
    return hh_items
end
local function joinGame(inst)
    if not HH_UTILS:HasComponents(inst, "hh_data") then
        return
    end
    local self_components = inst["components"]["hh_data"]
    self_components["hh_user_id"] = inst["userid"]
    self_components:LoadWorldValue()
end
local function changeCharacter(inst)
    if not HH_UTILS:HasComponents(inst, "hh_data") then
        return
    end
    local self_components = inst["components"]["hh_data"]
    if HH_UTILS:HasComponents(TheWorld, "hh_world") then
        TheWorld["components"]["hh_world"]:SetValueByUid("save_data", self_components["hh_user_id"] or inst["userid"], self_components["params"])
    end
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["params"] = getItemConfig()
    self["is_first"] = true
    self["inst"]:DoTaskInTime(0.3, joinGame)
    --世界记录属性
    self["inst"]:ListenForEvent("ms_playerreroll", changeCharacter)
end)

function HH_COM:LoadWorldValue()
    if self["is_first"] and HH_UTILS:HasComponents(TheWorld, "hh_world") then
        local world_save_data = TheWorld["components"]["hh_world"]:GetValueByUid("save_data", self["inst"]["userid"])
        if HH_UTILS:IsHHType(world_save_data, "table") then
            self:DoResetParamValue(world_save_data)
        end
    end
    self["is_first"] = false
end
function HH_COM:GetParamsValue(param_key)
    return self["params"][param_key] or 0
end
function HH_COM:SetParamsValue(param_key, param_value)
    if not HH_UTILS:IsHHType(param_value, "number") then
        return
    end
    self["params"][param_key] = param_value
end

function HH_COM:DoDeltaParamValue(param_key, delta)
    if not self["params"][param_key] then
        return
    end
    local hh_player = self["inst"]
    local player_name = hh_player["name"] or STRINGS["NAMES"][string["upper"](hh_player["prefab"])]
    local oldValue = tonumber(self["params"][param_key]) or 0
    local currentValue = math["max"](oldValue + delta, 0)
    --print("旧", oldValue, "新", currentValue, "key", param_key)
    -- 特殊参数特殊逻辑
    local maxDrawLotsNumRare = 100--稀有附魔石转换最大值
    if param_key == "draw_lots_num_rare" and currentValue >= maxDrawLotsNumRare then
        currentValue = 0
        --大黑蛋
        HH_UTILS:SendEggToPlayer(hh_player, "hh_egg_black", 1)
        HH_UTILS:AddLog("egg", HH_UTILS:Template(getLogLanguage("compound_black_egg"), { ["data_player"] = player_name, }))

        HH_UTILS:NetSay(string["format"]("%s连续转换%s次未获得稀有附魔石，奖励黑蛋一枚，怎么有人能黑成这样~", tostring(player_name), tostring(maxDrawLotsNumRare)))
    end

    self["params"][param_key] = currentValue
end
function HH_COM:DoResetParamValue(param_table)
    if HH_UTILS:IsHHType(param_table, "table") and HH_UTILS:IsHHType(self["params"], "table") then
        for i, v in pairs(param_table) do
            if self["params"][i] then
                self["params"][i] = v
            end
        end
    end
end
function HH_COM:OnSave()
    return {
        ["params"] = self["params"],
        ["is_first"] = self["is_first"],
    }
end
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    self:DoResetParamValue(data["params"])
    self["is_first"] = data["is_first"] or false
end

return HH_COM
local HH_UTILS = require("utils/hh_utils")
--封装动作函数
local ACT_CONFIG = {
    ["hh_suit_act"] = {
        ["action"] = Action({ ["priority"] = 999, ["mount_valid"] = true }),
        ["str"] = "进行操作",
        ["act_sg"] = "give",
        ["fn"] = function(act)
            local player = act["doer"]
            local target = act["target"]
            if HH_UTILS:HasComponents(player, "hh_player") and target and target["GUID"] then
                player["suit_hh_guid"] = target["GUID"]
                player["components"]["hh_player"]:OpenSuitContainer()
                return true
            end
            return false
        end,
    },
    ["hh_act_treasure_act"] = {
        ["action"] = Action({ ["priority"] = 5, ["mount_valid"] = false }),
        ["str"] = "寻宝",
        ["act_sg"] = "doshortaction",
        ["fn"] = function(act)
            local player = act["doer"]
            local item = act["invobject"]
            if not item or not player or not item["SpawnTreasureFn"] then
                return false
            end
            item:SpawnTreasureFn(player)
            return true
        end,
    },
}
local function whiteFn()
end
--增加动作
for i, v in pairs(ACT_CONFIG) do
    local hh_act_id = string["upper"](i)
    local hh_act_config = v
    local hh_act = hh_act_config["action"]
    if HH_UTILS:IsHHType(hh_act, "table") then
        hh_act["id"] = hh_act_id
        hh_act["str"] = hh_act_config["str"] or "动作未命名"
        if HH_UTILS:IsHHType(hh_act_config["str_fn"], "function") then
            hh_act_config["strfn"] = hh_act_config["str_fn"]
        end
        hh_act["fn"] = hh_act_config["fn"] or whiteFn
        AddAction(hh_act)
        ---绑定动作的sg
        local hh_act_sg = hh_act_config["act_sg"] or "give"
        AddStategraphActionHandler("wilson", ActionHandler(ACTIONS[hh_act_id], hh_act_sg))
        AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS[hh_act_id], hh_act_sg))
    end
end
----
---动作前置校验
---
local ACT_CHECK_CONFIG = {
    ["SCENE"] = {
        ["inspectable"] = function(inst, doer, actions, right)
            --if right and inst and inst["prefab"] == "hh_suit_build" and doer:HasTag("player") and not doer:HasTag("playerghost") then
            if right and inst and inst["prefab"] == "hh_suit_build" and doer:HasTag("player") and not doer:HasTag("playerghost") then
                table["insert"](actions, ACTIONS[string["upper"]("hh_suit_act")])
            end
        end,
    },
    ["INVENTORY"] = {
        ["inventoryitem"] = function(inst, doer, actions, right)
            if doer:HasTag("player") and inst["prefab"] == "hh_treasure_tally" then
                table["insert"](actions, ACTIONS[string["upper"]("hh_act_treasure_act")])
            end
        end,
    },
}
for i, v in pairs(ACT_CHECK_CONFIG) do
    local hh_act_type = i
    for act_components, v_fn in pairs(v) do
        local hh_act_components = act_components
        local hh_act_check_fn = v_fn
        if HH_UTILS:IsHHType(hh_act_check_fn, "function") then
            AddComponentAction(hh_act_type, hh_act_components, hh_act_check_fn)
        end
    end
end
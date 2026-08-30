----
---记录攻击者id-用于兼容参与击杀发放奖励
---
local HH_UTILS = require("utils/hh_utils")

local function attacked(inst, data)
    if not data or not data["attacker"] then
        return
    end
    local attacker = data["attacker"]

    if not (HH_UTILS:HasComponents(attacker, "hh_player") and attacker["userid"]) then
        return
    end
    local player_id = attacker["userid"]
    if HH_UTILS:HasComponents(inst, "hh_save_attacker") then
        inst["components"]["hh_save_attacker"]:SavePlayerID(player_id)
    end

end
local function death_fn(inst)
    if HH_UTILS:HasComponents(inst, "hh_save_attacker") then
        inst["components"]["hh_save_attacker"]:SendDeathEvent()
    end
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["save_id"] = {}
    self["inst"]:ListenForEvent("attacked", attacked)
    self["inst"]:ListenForEvent("death", death_fn)
end)
----
---保存玩家id-不需要兼容重载保存
---
function HH_COM:SavePlayerID(player_id)
    if not HH_UTILS:IsHHType(player_id, "string") then
        return
    end
    self["save_id"][player_id] = true
end
----
---死亡给参与击杀者推送事件
---
function HH_COM:SendDeathEvent()
    --只能同一个世界
    if not HH_UTILS:IsHHType(AllPlayers, "table") then
        return
    end
    for i, v in ipairs(AllPlayers) do
        if HH_UTILS:IsHHType(v, "table") and v["userid"] and HH_UTILS:HasComponents(v, "hh_job") then
            local player_id = v["userid"]
            if self["save_id"][player_id] then
                --todo 给任务组件增加记录
                --v["components"]["hh_job"]:SendDeathEvent()
            end
        end
    end
end
return HH_COM
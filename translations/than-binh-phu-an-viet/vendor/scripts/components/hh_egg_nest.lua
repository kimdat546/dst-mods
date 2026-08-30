local HH_UTILS = require("utils/hh_utils")

local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["egg_id"] = nil
    self["egg_time"] = 0
    self["finish_fn"] = nil
end)

function HH_COM:SetFinishFn(fn)
    self["finish_fn"] = fn
end

function HH_COM:GetEggId()
    return self["egg_id"]
end
----
---校验是否已经有孵化的蛋
---
function HH_COM:HasHatchedEgg()
    return HH_UTILS:IsHHType(self["egg_id"], "string")
end
----
---开始孵化
---
function HH_COM:StartHatchedEgg(prefab_id, hatched_time)
    if not HH_UTILS:IsHHType(prefab_id, "string") then
        return
    end
    local base_time = 60
    if HH_UTILS:IsHHType(hatched_time, "number") and hatched_time > 0 then
        base_time = hatched_time
    end
    local nest_inst = self["inst"]
    self["egg_id"] = prefab_id
    self["egg_time"] = base_time
    self:ReplaceEggImage()
    self:UpdateHatchedEggTask()
end
----
---设置是否可交易
---
function HH_COM:SetTraderType(can_trade)
    local nest_inst = self["inst"]
    --是否可交易
    if HH_UTILS:HasComponents(nest_inst, "trader") then
        if can_trade then
            nest_inst["components"]["trader"]:Enable()
        else
            nest_inst["components"]["trader"]:Disable()
        end
    end
end
function HH_COM:UpdateHatchedEggTask()
    local nest_inst = self["inst"]
    HH_UTILS:HHKillTask(nest_inst, "start_egg_task")
    --不能交易
    self:SetTraderType(false)
    nest_inst["start_egg_task"] = nest_inst:DoPeriodicTask(1, function(_inst)
        if HH_UTILS:HasComponents(_inst, "hh_egg_nest") then
            _inst["components"]["hh_egg_nest"]:ReduceHatchedEggTime()
        end
    end)
end
----
---更新贴图
---
function HH_COM:ReplaceEggImage()
    local nest_inst = self["inst"]
    local prefab_id = self["egg_id"]
    if prefab_id and nest_inst["AnimState"] then
        nest_inst["AnimState"]:OverrideSymbol("egg", "hh_eggs", tostring(prefab_id))
        --透明鸡蛋
        --if prefab_id == "hh_egg_clear" then
        --    HH_UTILS:HHRemoveFx(nest_inst, "egg_fx")
        --    nest_inst["egg_fx"] = SpawnPrefab("hh_test_fx")
        --    nest_inst["AnimState"]:OverrideSymbol("egg", "hh_eggs", tostring(prefab_id))
        --    if nest_inst["egg_fx"] then
        --        nest_inst["egg_fx"]["entity"]:AddFollower()
        --        nest_inst["egg_fx"]["entity"]:SetParent(nest_inst["entity"])
        --        nest_inst["egg_fx"]["Follower"]:FollowSymbol(nest_inst["GUID"], "fx", 0, -100, -0.1)
        --        nest_inst["egg_fx"]["Transform"]:SetScale(0.2, 0.2, 0.2)
        --        --nest_inst["egg_fx"]["Follower"]:FollowSymbol(nest_inst["GUID"], "fx", 0, 0, 0, true)
        --    end
        --end
    end
end
function HH_COM:StopHatchedEgg()
    local nest_inst = self["inst"]
    HH_UTILS:HHKillTask(nest_inst, "start_egg_task")
    --鸡蛋附属特效 及时清除
    HH_UTILS:HHRemoveFx(nest_inst, "egg_fx")
    --可交易
    if HH_UTILS:HasComponents(nest_inst, "trader") then
        nest_inst["components"]["trader"]["acceptnontradable"] = true
    end
    self["egg_id"] = nil
    self["egg_time"] = 0
    --可交易
    self:SetTraderType(true)
end
----
---减少剩余时间
---
function HH_COM:ReduceHatchedEggTime()
    local nest_inst = self["inst"]
    local current_time = self["egg_time"]
    local current_egg = self["egg_id"]
    if not (HH_UTILS:IsHHType(current_time, "number") and (current_time > 0) and HH_UTILS:IsHHType(current_egg, "string")) then
        self:StopHatchedEgg()
        return
    end
    self["egg_time"] = current_time - 1
    if self["egg_time"] <= 0 then
        if HH_UTILS:IsHHType(self["finish_fn"], "function") then
            self["finish_fn"](nest_inst, current_egg)
        end
        self:StopHatchedEgg()
    end
end
function HH_COM:OnSave()
    return {
        ["egg_id"] = self["egg_id"],
        ["egg_time"] = self["egg_time"]
    }
end
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    if data["egg_id"] and data["egg_time"] then
        self["egg_id"] = data["egg_id"]
        self["egg_time"] = data["egg_time"]
        self:ReplaceEggImage()
        self:UpdateHatchedEggTask()
    end
end

function HH_COM:GetDebugString()
    local egg_id = self["egg_id"]
    local egg_time = self["egg_time"]
    if not HH_UTILS:IsHHType(egg_id, "string") then
        return "空"
    end
    return string.format("%s(%s秒)", HH_UTILS:GetPrefabName(egg_id), tostring(egg_time))
end

return HH_COM
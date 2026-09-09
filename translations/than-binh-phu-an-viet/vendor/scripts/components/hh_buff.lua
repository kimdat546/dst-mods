---
---buff组件
---
local HH_UTILS = require("utils/hh_utils")
local HH_BUFF_CONFIG = require("enums/hh_buff")
local function Death(inst)
    if HH_UTILS:HasComponents(inst, "hh_buff") then
        inst["components"]["hh_buff"]:StopAllBuff()
    end
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["hh_buffs"] = {}
    self["start_update"] = false
    self["inst"]:ListenForEvent("death", Death)
    --同步客机
    self["inst"]["hh_buff_tips"] = self["inst"]:DoPeriodicTask(1, function()
        HH_UTILS:HHClientRpc(self["inst"], "hh_client_buff", HH_UTILS:TableToStr(self["hh_buffs"]))
    end)
end)
function HH_COM:HasBuff(buff_name)
    if not HH_UTILS:IsHHType(buff_name, "string") then
        return false
    end
    if self["hh_buffs"][buff_name] == nil then
        return false
    end
    return true
end
function HH_COM:AddBuff(buff_name, buff_time)
    if not HH_UTILS:IsHHType(buff_name, "string") then
        return false
    end
    if not HH_BUFF_CONFIG[buff_name] then
        --print("错误的buff")
        return false
    end
    if HH_BUFF_CONFIG[buff_name]["check_fn"] then
        local check_result = HH_BUFF_CONFIG[buff_name]["check_fn"](self["inst"])
        if check_result then
            return false
        end
    end
    --为空则为无限时间
    local hh_buff_time = buff_time
    --负数跳过
    if HH_UTILS:IsHHType(hh_buff_time, "number") and buff_time <= 0 then
        --print("buff时间错误")
        return false
    end
    ----同种buff后者覆盖前者
    if self:HasBuff(buff_name) then
        if HH_BUFF_CONFIG[buff_name]["stop_fn"] then
            HH_BUFF_CONFIG[buff_name]["stop_fn"](self["inst"])
        end
    end
    if HH_BUFF_CONFIG[buff_name]["start_fn"] then
        HH_BUFF_CONFIG[buff_name]["start_fn"](self["inst"])
    end
    self["hh_buffs"][buff_name] = { ["name"] = buff_name, ["time"] = hh_buff_time, }
    if not self["start_update"] then
        self["inst"]:StartUpdatingComponent(self)
        self["start_update"] = true
    end
    return true
end
function HH_COM:RemoveBuff(buff_name)
    if not self:HasBuff(buff_name) then
        return false
    end
    if HH_BUFF_CONFIG[buff_name]["stop_fn"] then
        HH_BUFF_CONFIG[buff_name]["stop_fn"](self["inst"])
    end
    self["hh_buffs"][buff_name] = nil
    if not self["start_update"] and next(self["hh_buffs"]) then
        --不在更新状态 且有buff就开始更新
        self["inst"]:StartUpdatingComponent(self)
        self["start_update"] = true
    end
end
----
---清除所有buff
---
function HH_COM:StopAllBuff()
    for i, v in pairs(self["hh_buffs"]) do
        if v and HH_BUFF_CONFIG[i] and HH_BUFF_CONFIG[i]["stop_fn"] then
            HH_BUFF_CONFIG[i]["stop_fn"](self["inst"])
        end
    end
    self["hh_buffs"] = {}
    self["inst"]:StopUpdatingComponent(self)
    self["start_update"] = false
end
function HH_COM:OnUpdate(dt)
    ----如果服务器是暂停状态不会更新时间
    if TheNet:IsServerPaused() then
        return
    end
    for i, v in pairs(self["hh_buffs"]) do
        if v and HH_BUFF_CONFIG[i] then
            if HH_BUFF_CONFIG[i]["update_fn"] then
                HH_BUFF_CONFIG[i]["update_fn"](self["inst"])
            end
            if v["time"] and type(v["time"]) == "number" then
                v["time"] = v["time"] - dt
                if v["time"] < 0 then
                    if HH_BUFF_CONFIG[i]["stop_fn"] then
                        HH_BUFF_CONFIG[i]["stop_fn"](self["inst"])
                    end
                    self["hh_buffs"][i] = nil
                end
            end
        end
    end
    if self["start_update"] and not next(self["hh_buffs"]) then
        --在更新状态 但是没有buff就停止更新
        self["inst"]:StopUpdatingComponent(self)
        self["start_update"] = false
    end
end

function HH_COM:OnSave()
    return { ["hh_buffs"] = self["hh_buffs"] }
end

function HH_COM:OnLoad(data)
    if not data or not data["hh_buffs"] then
        return
    end
    for k, v in pairs(data["hh_buffs"]) do
        if k and HH_BUFF_CONFIG[k] and v and v["name"] then
            self:AddBuff(v["name"], v["time"])
        end
    end
end
return HH_COM
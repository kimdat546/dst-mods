----
---世界继承玩家宝石数据
---
local HH_UTILS = require("utils/hh_utils")
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["hh_save"] = {}
end)

function HH_COM:GetValueByUid(value_type, hh_uid)
    if not HH_UTILS:IsHHType(value_type, "string")
            or not HH_UTILS:IsHHType(hh_uid, "string")
            or not HH_UTILS:IsHHType(self["hh_save"][value_type], "table")
            or not self["hh_save"][value_type]["uid_" .. hh_uid]
    then
        return nil
    end
    return self["hh_save"][value_type]["uid_" .. hh_uid]
end

function HH_COM:SetValueByUid(value_type, uid, data)
    if not HH_UTILS:IsHHType(value_type, "string")
            or not HH_UTILS:IsHHType(uid, "string")
    then
        --print("同步世界属性-参数错误")
        return false
    end
    if not HH_UTILS:IsHHType(self["hh_save"][value_type], "table") then
        self["hh_save"][value_type] = {}
    end
    self["hh_save"][value_type]["uid_" .. uid] = data
    return true
end
function HH_COM:OnSave()
    return {
        ["hh_save"] = self["hh_save"],
    }
end
function HH_COM:OnLoad(data)
    if not data or not data["hh_save"] then
        return
    end
    self["hh_save"] = data["hh_save"]
end
return HH_COM
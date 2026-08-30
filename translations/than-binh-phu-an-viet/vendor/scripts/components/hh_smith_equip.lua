local HH_UTILS = require("utils/hh_utils")
----
---锻造装备组件
---
local function hookNamed(inst)
    if not HH_UTILS:HasComponents(inst, "named") then
        return
    end
    local name_components = inst["components"]["named"]
    local oldSetName = name_components["SetName"]
    name_components["SetName"] = function(self, name, ...)
        local equip_inst = self["inst"]
        if HH_UTILS:HasComponents(equip_inst, "hh_smith_equip") then
            name = equip_inst["components"]["hh_smith_equip"]:GetName()
        end
        if oldSetName then
            oldSetName(self, name, ...)
        end
    end
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst

    --干掉命名组件 防止其他mod改名字
    hookNamed(self["inst"])
end)

----
---组装装备名字
---
function HH_COM:GetName()

    return "名字"
end
return HH_COM
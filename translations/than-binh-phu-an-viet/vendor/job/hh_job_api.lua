local HH_UTILS = require("utils/hh_utils")
AddPlayerPostInit(function(inst)
    if not TheWorld["ismastersim"] then
        return inst
    end
    if not inst["components"]["hh_job"] then
        inst:AddComponent("hh_job")
    end
end)

local function hookEdible(player, food_value, value)
    if not (HH_UTILS:IsHHType(food_value, "string") and HH_UTILS:IsHHType(value, "number")) then
        return 0
    end
    if not HH_UTILS:HasComponents(player, "hh_job") then
        return value
    end
    local job_com = player["components"]["hh_job"]
    if food_value == "hunger" then
        return job_com:GetHungerValue(value)
    elseif food_value == "sanity" then
        return job_com:GetSanityValue(value)
    elseif food_value == "health" then
        return job_com:GetHealthValue(value)
    end
    return value
end
----
---料理属性加成
---
AddComponentPostInit("edible", function(self)
    local oldGetSanity = self["GetSanity"]
    self["GetSanity"] = function(_self, eater, ...)
        local old_value = oldGetSanity and oldGetSanity(_self, eater, ...) or 0
        local new_value = hookEdible(eater, "sanity", old_value)
        return new_value
    end
    local oldGetHunger = self["GetHunger"]
    self["GetHunger"] = function(_self, eater, ...)
        local old_value = oldGetHunger and oldGetHunger(_self, eater, ...) or 0
        local new_value = hookEdible(eater, "hunger", old_value)
        return new_value
    end
    local oldGetHealth = self["GetHealth"]
    self["GetHealth"] = function(_self, eater, ...)
        local old_value = oldGetHealth and oldGetHealth(_self, eater, ...) or 0
        local new_value = hookEdible(eater, "health", old_value)
        return new_value
    end
end)
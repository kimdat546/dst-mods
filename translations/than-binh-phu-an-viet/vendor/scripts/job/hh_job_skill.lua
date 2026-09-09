local HH_UTILS = require("utils/hh_utils")

--技能配置
local HH_CONFIG = {
    ["smith"] = {
        ["skill_01"] = {
            ["name"] = "技能-1",
            --技能类型
            ["skill_type"] = "passive",
            ["start_fn"] = function(player)

            end,
            ["stop_fn"] = function(player)

            end,
        },
        ["skill_01"] = {
            ["name"] = "技能-1",
            ["skill_type"] = "active",
            ["start_fn"] = function(player)

            end,
            ["stop_fn"] = function(player)

            end,
        },

    },
}
return HH_CONFIG
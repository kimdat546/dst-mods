local HH_UTILS = require("utils/hh_utils")
----
---任务表
---
local com_table = {
    ["name"] = "坚韧蛛丝的收集",
    --权重
    ["weight"] = 10,
    --["type"] = "连环",
    ["desc"] = "铁匠八音猪最近接到一批特殊装备的订单，他打算尝试用蜘蛛丝来增强装备的韧性和弹性。然而，这种蜘蛛丝只能从蜘蛛生物身上获取。由于魔蛛行动迅速且极具攻击性，采集工作十分危险。因此，八音猪希望有勇士能帮他收集{{silk}}个蜘蛛丝。",
    ["target_desc"] = "收集【蜘蛛丝】x{{silk}}",
    --任务条件配置
    ["target_list"] = {
        --["spider"] = 10,
        ["silk"] = 15,
    },
    --连环任务id 完成后自动接取
    --["next_task"] = "",
    --奖励列表
    ["reward"] = {
        --可放在物品栏的道具
        ["item"] = {
            { ["id"] = "deerclops_eyeball", ["num"] = 1, },
            { ["id"] = "dragon_scales", ["num"] = 2, },
            { ["id"] = "minotaurhorn", ["num"] = 3, },
            { ["id"] = "greengem", ["num"] = 4, },

        },
        ["exp"] = 100,
        --随机奖励
        ["chance_item"] = {
            ["name"] = "八音猪特制装备x1（30%概率）",
            ["chance"] = 0.3,
            ["spawn_fn"] = function(player)

            end,
        },
        --好感度系统 某些npc奖励少但是好感度到一定阶段会开启隐藏职业连环任务
        ["goodwill"] = 10,
    },
}
local function addTask(job_name)
    local hh_table = HH_UTILS:HHCopyTable(com_table)
    hh_table["name"] = tostring(job_name)
    return hh_table
end
local HH_JOB = {
    --铁匠
    ["smith"] = {
        ["test_01"] = addTask("坚韧之角"),
        ["test_02"] = addTask("锋利之刺"),
        ["test_03"] = addTask("坚韧蛛丝的收集"),
        ["test_04"] = addTask("猪皮的需求"),
        ["test_05"] = addTask("古堡石砖的召集"),
        ["test_06"] = addTask("绿宝石的探寻"),
        ["test_07"] = addTask("神秘铁匠的指点"),
        ["test_08"] = addTask("寻找丢失的宝藏"),
        ["test_09"] = addTask("锻造的艺术"),

        ["add_friend"] = {
            ["name"] = "坚韧蛛丝的收集",
            --权重
            ["weight"] = 10,
            --["type"] = "连环",
            ["desc"] = "武姓隐藏高人申请加你好友",
            ["target_desc"] = "接受任务",
            --任务条件配置
            ["target_list"] = {
                --["spider"] = 10,
            },
            --连环任务id 完成后自动接取
            --["next_task"] = "",
            --奖励列表
            ["reward"] = {
                --随机奖励
                ["chance_item"] = {
                    ["name"] = "神秘奖励",
                    ["chance"] = 1,
                    ["spawn_fn"] = function(player)
                    end,
                },
            },
        },
    },
}
return HH_JOB
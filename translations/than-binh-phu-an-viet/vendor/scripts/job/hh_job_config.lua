local HH_UTILS = require("utils/hh_utils")

local HH_JOB_SMITH = require("widgets/hh_job/hh_job_smith")
--铁匠职业称号
local SMITH_TITLE_CONFIG = {
    { ["name"] = "新手铁匠", ["color"] = { 127 / 255, 255 / 255, 212 / 255, 1 }, },
    { ["name"] = "熟练工匠", ["color"] = { 240 / 255, 255 / 255, 255 / 255, 1 }, },
    { ["name"] = "大师铁匠", ["color"] = { 160 / 255, 32 / 255, 240 / 255, 1 }, },
    { ["name"] = "传奇铸造师", ["color"] = { 255 / 255, 97 / 255, 0 / 255, 1 }, },
    { ["name"] = "神铸圣匠", ["color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, },
}
----
---获取称号函数
---@param level:等级
---@param title_list:称号表-五个称号
---
local function getLevelTitle(level, title_list)
    if not HH_UTILS:IsHHType(level, "number") or not HH_UTILS:IsHHType(title_list, "table") then
        return "查询称号入参错误", { 1, 1, 1, 1 }
    end
    if not HH_UTILS:IsHHType(title_list[level], "table") then
        return string["format"]("等级%s-无称号", tostring(level)), { 1, 1, 1, 1 }
    end
    return tostring(title_list[level]["name"] or "第?阶段称号"), title_list[level]["color"] or { 255 / 255, 255 / 255, 255 / 255, 1 }
end
local HH_CONFIG = {
    ["smith"] = {
        ["name"] = "铁匠", --职业名字
        ["client_text"] = "职\n铁匠", --客户端图标名字
        ["weight"] = 10, --权重
        --------------------------------------配置项-----------------------------------------------------
        ["is_special"] = true, --不可以在职业选择页中刷新出来
        --------------------------------------ui展示-----------------------------------------------------
        ["desc"] = "精通锻造与修复武器装备。通过高超的技艺，铁匠能打造出强力的武器和护甲，提升玩家的战斗力。随着等级提升，铁匠能打造更加精良的装备，甚至拥有独特的附魔效果，为队伍提供强大支持。",
        ["help_text"] = "帮助描述",
        ["str_ui_list"] = {--初始选择页展示的内容
            { ["str"] = " ", ["color"] = { 1, 1, 1, 1 }, ["scale"] = 18, },
            { ["str"] = "类型:辅助类,生活类,万金油", ["color"] = { 1, 1, 0, 1 }, ["scale"] = 18, },
            { ["str"] = "任务类型:", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
            { ["str"] = "制造装备/提交材料", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
        },
        ["ui"] = HH_JOB_SMITH, --ui路径
        ["color"] = { 1, 1, 0, 1 }, --选择页中职业名字颜色
        ["title_fn"] = function(player)
            if not HH_UTILS:HasComponents(player, "hh_job") then
                return "未开启职业系统", { 1, 1, 1, 1 }
            end
            local current_level = player["components"]["hh_job"]:GetJobLevel()
            return getLevelTitle(current_level, SMITH_TITLE_CONFIG)
        end,
        --------------------------------------实际效果-----------------------------------------------------
        ["tags"] = {--职业类型标签，有的职业是多种类型
            ["assist"] = true, --辅助类
        },
        ["level_config"] = {
            ["level_1"] = {
                ["exp"] = 100, --配置等级需要的经验
                --等级起始函数
                ["start_fn"] = function()

                end,
                ["stop_fn"] = function()

                end,
            },
        },
        ---起始函数 初始自带
        ["start_fn"] = function(player)

        end,
        --转新职业时移除掉初始函数中的任务
        ["stop_fn"] = function(player)

        end,

    },
}
return HH_CONFIG
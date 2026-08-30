local HH_UTILS = require("utils/hh_utils")
local function getLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end
----
---日志组件
---
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --日志记录
    self["logs"] = {}
end)

function HH_COM:AddLog(log_type, log_message)
    --加上时间
    local log_date = HH_UTILS:GetCurrentDateTime()
    local log_str = HH_UTILS:Template("#{{data_date}}:white:25{{data_message}}", {
        ["data_date"] = log_date,
        ["data_message"] = log_message,
    })
    local save_type = {}
    if HH_UTILS:IsHHType(log_type, "table") then
        save_type = log_type
    elseif HH_UTILS:IsHHType(log_type, "string") then
        table["insert"](save_type, log_type)
    end
    local log_table = {
        ["ui_config"] = log_str,
        ["log_type"] = save_type,
        ["log_time"] = log_date,
    }
    table["insert"](self["logs"], log_table)
    --推实际及时更新 如果打开相关日志页面的话
    --self["inst"]:PushEvent("ovo_log_change")
end
----
---获取日志（联机传大批量数据会占带宽 默认100条吧 请求一次大概占十几k）
---@param log_type-日志类型 (如果传入，则筛选出 logs 中包含该类型的记录)
---@param limit_count-数量 (每页显示的数量)
---@param page_index-页数 (当前第几页)
---
function HH_COM:GetLogs(log_type, limit_count, page_index)
    -- 基础校验：确保 logs 是 table
    if not HH_UTILS:IsHHType(self["logs"], "table") or #self["logs"] == 0 then
        return {}
    end
    -- 设置默认值，防止传入 nil 导致报错
    limit_count = limit_count or 100
    page_index = page_index or 1
    -- 复制原表并倒序（保证最新日志在前面）
    local logsCopy = HH_UTILS:HHCopyTable(self["logs"])
    local reversedLogs = {}
    for i = #logsCopy, 1, -1 do
        table["insert"](reversedLogs, logsCopy[i])
    end
    -- 传入了 log_type，则过滤数据
    local filteredLogs = reversedLogs
    if log_type ~= nil and log_type ~= "" then
        filteredLogs = {}
        -- 遍历倒序后的日志
        for _, log_item in ipairs(reversedLogs) do
            -- 取出当前日志的 log_type 列表
            local item_log_types = log_item["log_type"]
            -- 确保它是个 table，并且里面包含我们要找的 log_type 字符串
            if HH_UTILS:IsHHType(item_log_types, "table") then
                if table["contains"](item_log_types, log_type) then
                    table["insert"](filteredLogs, log_item)
                end
            end
        end
    end
    -- 计算分页的起始和结束索引
    local start_index = (page_index - 1) * limit_count + 1
    local end_index = page_index * limit_count
    -- 边界处理
    if start_index > #filteredLogs then
        return {}
    end
    if end_index > #filteredLogs then
        end_index = #filteredLogs
    end
    --提取当前页的数据并返回
    local pageData = {}
    for i = start_index, end_index do
        table["insert"](pageData, filteredLogs[i])
    end
    return pageData
end
function HH_COM:OnSave()
    local save_data = {}
    if self["logs"] then
        save_data["logs"] = self["logs"]
    end
    return save_data
end
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    self["logs"] = data["logs"] or {}
end
return HH_COM
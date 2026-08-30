local HH_UTILS = require("utils/hh_utils")

-- 物品限制配置列表（最外面加个list配置）
-- 只需要在这里添加新的物品ID和对应的最大数量，组件会自动生效
local ITEM_LIMIT_CONFIG = {
    ["equip"] = TUNING["LIMIT_DROP_EQUIP"], -- 装备掉落限制
    ["tally"] = TUNING["LIMIT_DROP_TALLY"], -- 卷轴/洗蕴石掉落限制
    ["stone"] = TUNING["LIMIT_DROP_STONE"], -- 极品附魔石掉落限制
}

----
---限制组件（装备掉落 卷轴掉落）
---
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    -- 深拷贝配置表，作为当前实体的独立数据存储
    local init_data = HH_UTILS:HHCopyTable(ITEM_LIMIT_CONFIG)
    for item_id, max_num in pairs(init_data) do
        self[item_id] = 0
        self["max_" .. tostring(item_id)] = tonumber(max_num) or 0
    end
    -- 监听世界状态刷新限制
    self["inst"]:WatchWorldState("cycles", function(data_inst, data)
        self:RefreshLimit()
    end)
end)

----
---刷新限制
---
function HH_COM:RefreshLimit()
    for item_id, _ in pairs(ITEM_LIMIT_CONFIG) do
        self[item_id] = 0
    end
end
-- 获取物品当前数量
function HH_COM:GetItemNum(item_id)
    -- 如果请求的物品ID不在我们的配置里，直接返回0或报错，防止非法访问
    if not ITEM_LIMIT_CONFIG[item_id] then
        return 0
    end
    return tonumber(self[item_id]) or 0
end
function HH_COM:SetItemNum(item_id, item_num)
    --print("设置物品数量", item_id, item_num)
    if not (HH_UTILS:IsHHType(self[item_id], "number")
            and HH_UTILS:IsHHType(item_num, "number")) then
        return
    end
    self[item_id] = math["max"](item_num, 0)
end

-- 获取物品当前数量
function HH_COM:DoDelta(item_id, item_num)
    -- 如果请求的物品ID不在我们的配置里，直接返回0或报错，防止非法访问
    if not (ITEM_LIMIT_CONFIG[item_id] and HH_UTILS:IsHHType(item_num, "number")) then
        return
    end
    local current_num = self:GetItemNum(item_id)
    --print("DoDelta物品数量", item_id, current_num, item_num)
    self:SetItemNum(item_id, current_num + item_num)
end

-- 获取物品最大数量
function HH_COM:GetItemMaxNum(item_id)
    if not ITEM_LIMIT_CONFIG[item_id] then
        return 0
    end
    local item_key = "max_" .. tostring(item_id)
    return tonumber(self[item_key]) or 0
end

-- 检查物品数量是否达到上限
function HH_COM:CheckItemNum(item_id)
    -- 如果配置里没有这个物品，默认允许或禁止看你的业务需求，这里默认允许
    if not ITEM_LIMIT_CONFIG[item_id] then
        return false
    end
    local current_num = self:GetItemNum(item_id)
    local max_num = self:GetItemMaxNum(item_id)
    --print("校验每日上限", item_id, self[item_id], current_num, max_num)
    if current_num >= max_num then
        return false
    end
    return true
end

-- 存档
function HH_COM:OnSave()
    local save_data = {}
    -- 只保存配置表里定义的物品当前数量
    for item_id, _ in pairs(ITEM_LIMIT_CONFIG) do
        save_data[item_id] = self[item_id]
    end
    return save_data
end

-- 读档
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    -- 动态读取存档数据
    for item_id, _ in pairs(ITEM_LIMIT_CONFIG) do
        self[item_id] = data[item_id] or 0
    end
end

function HH_COM:GetDebugString()
    return ""
end

return HH_COM
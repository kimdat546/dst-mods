local HH_UTILS = require("utils/hh_utils")
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --等级
    self["level"] = 1
    self["max_level"] = 100
    --经验
    self["exp"] = 0

end)
----
---设置最大等级
---@param max_level number 最大等级值
---
function HH_COM:SetMaxLevel(max_level)
    self["max_level"] = max_level
end

function HH_COM:GetLevel()
    return self["level"]
end

function HH_COM:GetExp()
    return self["exp"]
end
----
---最大等级
---
function HH_COM:GetMaxLevel()
    return self["max_level"]
end
function HH_COM:IsMaxLevel()
    return self:GetLevel() >= self:GetMaxLevel()
end
----
---升级函数
---
function HH_COM:SetLevelUpFn(fn)
    self["level_up_fn"] = fn
end
----
---降级函数
---
function HH_COM:SetLevelDownFn(fn)
    self["level_down_fn"] = fn
end
----
--- 计算当前等级所需经验值
--- @param level number 等级
--- @return number 所需经验值
---
function HH_COM:CalculateExpForLevel(level)
    -- 使用常见的经验值公式: 每级所需经验 = 基础经验 * (等级 - 1)^指数
    local base_exp = 100     -- 基础经验值
    local exponent = 1.5     -- 指数增长因子

    if level <= 1 then
        return 0
    end

    -- 计算到达该等级所需的总经验值
    local required_exp = base_exp * ((level - 1) ^ exponent)
    return math["floor"](required_exp)
end

----
--- 计算到达下一等级所需的经验值
--- @return number 所需经验值
---
function HH_COM:GetExpRequiredForNextLevel()
    local current_level = self:GetLevel()
    local current_exp = self:GetExp()
    local exp_for_next_level = self:CalculateExpForLevel(current_level + 1)
    return exp_for_next_level - current_exp
end
----
---等级提升
---
function HH_COM:LevelUp()
    local hh_current_level = self:GetLevel()
    local hh_max_level = self:GetMaxLevel()
    if hh_current_level >= hh_max_level then
        return false, "等级已到达上限"
    end
    self["level"] = hh_current_level + 1
    -- 升级刷新方法
    if self["level_up_fn"] then
        self["level_up_fn"](self["inst"], self["level"])
    end
    return true, "等级提升"
end
----
---等级降级
---
function HH_COM:LevelDown()
    local hh_current_level = self:GetLevel()
    if hh_current_level <= 1 then
        return false, "等级已到达下限"
    end
    self["level"] = hh_current_level - 1
    -- 降级刷新方法
    if self["level_down_fn"] then
        self["level_down_fn"](self["inst"], self["level"])
    end
    return true, "等级降级"
end
function HH_COM:DoDelta(exp_num)
    if not HH_UTILS:IsHHType(exp_num, "number") then
        return false, "参数错误"
    end
    if self:IsMaxLevel() then
        return false, "等级已到达上限"
    end

    local old_exp = self:GetExp()
    local new_exp = old_exp + exp_num

    -- 如果是增加经验，则检查是否可以升级
    if exp_num > 0 then
        local leveled_up = false
        repeat
            local exp_for_next_level = self:CalculateExpForLevel(self:GetLevel() + 1)
            if new_exp >= exp_for_next_level and self:GetLevel() < self:GetMaxLevel() then
                -- 升级时清空当前等级经验值
                self["exp"] = new_exp - exp_for_next_level
                new_exp = self["exp"]  -- 更新new_exp为剩余经验值
                self:LevelUp()
                leveled_up = true
            else
                break
            end
        until false

        if not leveled_up then
            self["exp"] = new_exp
        end

        if leveled_up then
            return true, "获得经验并升级"
        else
            return true, "获得经验"
        end
        -- 如果是减少经验，则检查是否需要降级
    elseif exp_num < 0 then
        local leveled_down = false
        repeat
            local exp_for_current_level = self:CalculateExpForLevel(self:GetLevel())
            if new_exp < 0 and self:GetLevel() > 1 then
                -- 降级时保持经验为负值，直到处理完所有逻辑
                self:LevelDown()
                -- 降级后经验值设为降级前等级所需经验减去当前经验的绝对值
                local prev_level_exp = self:CalculateExpForLevel(self:GetLevel() + 1)
                self["exp"] = new_exp + prev_level_exp
                new_exp = self["exp"]
                leveled_down = true
            else
                break
            end
        until false

        if not leveled_down then
            self["exp"] = new_exp
        end

        if leveled_down then
            return true, "失去经验并降级"
        else
            return true, "失去经验"
        end
    end

    return true, "经验无变化"
end

function HH_COM:GetHovererStr()
    return string["format"]("%s(%s/%s)", self:GetLevel(), self:GetExp(), self:CalculateExpForLevel(self:GetLevel() + 1))
end

function HH_COM:OnSave()
    return {
        ["level"] = self["level"],
        ["exp"] = self["exp"],
    }
end

function HH_COM:OnLoad(data)
    if not data then
        return
    end
    --刷新等级状态
    if HH_UTILS:IsHHType(data["level"], "number") then
        local save_level = data["level"]
        for i = 1, save_level - 1 do
            self:LevelUp()
        end
    end
    self["exp"] = data["exp"] or 0
end
function HH_COM:DebugString()
    return string["format"]("当前等级:%s,当前经验:%s/%s,所需:%s", self:GetLevel(), self:GetExp(), self:CalculateExpForLevel(self:GetLevel() + 1), self:GetExpRequiredForNextLevel())
end

return HH_COM
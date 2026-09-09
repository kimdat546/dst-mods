local HH_UTILS = require("utils/hh_utils")
local HH_JOB_CONFIG = require("job/hh_job_config")
--铁匠配置类
local HH_JOB_SMITH_CONFIG = require("job/hh_job_smith_config")
local SMITH_ABILITY = HH_JOB_SMITH_CONFIG["ABILITY"]
----
---职业系统
---

local function SetChester(self, chester, ui_id)
    self[ui_id] = chester
    chester["persists"] = false
    chester["Transform"]:SetPosition(0, 0, 0)
    chester["entity"]:SetParent(self["inst"]["entity"])
    ----关联玩家信息
    chester["hh_ui_owner"] = self["inst"]
end
local function dropItems(inst)
    if HH_UTILS:HasComponents(inst, "hh_job") then
        inst["components"]["hh_job"]:DropContainerItems()
    end
end
--local function hookEater(inst)
--    if not HH_UTILS:HasComponents(inst, "eater") then
--        return
--    end
--    local eater_com=inst["components"]["eater"]
--
--end
--换人物掉落容器里面的道具
local function addChangeCharacter(player, container)
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --当前选择的职业
    self["current_job"] = nil--职业id
    --职业等级 1/30/60/90/100到对应等级需要完成进阶任务才能继续升级
    self["level"] = 1
    self["max_level"] = 5--职业最大等级
    self["exp"] = 0--经验

    --被动技能
    self["passive_skill"] = {}
    --主动技能
    self["active_skill"] = {}

    --学会的能力 铁匠的图纸 其他职业的符咒等等都可以放这边
    self["study_ability"] = {}--可以前缀_key来区分
    --特殊参数-k-v
    self["special_data"] = {}
    --npc好感度
    self["npc_goodwill"] = {}

    --职业选择默认会给选项 三选一
    self["current_choose"] = {}
    --职业转生时 保存已经选择过的职业数据
    self["save_data"] = {}


    --职业空间 又要加容器挂玩家身上
    self["job_container"] = nil
    self:SpawnContainer()

    --换人物时掉落物品
    self["inst"]:ListenForEvent("ms_playerreroll", dropItems)
end)
----
---掉落职业容器中的道具
---
function HH_COM:DropContainerItems()
    if HH_UTILS:HasComponents(self["job_container"], "container") then
        self["job_container"]["components"]["container"]:DropEverything()
    end
end

----
---封装属性表
---
function HH_COM:CreateSaveTable()
    local hh_table = {
        ["current_job"] = self["current_job"],
        ["level"] = self["level"],
        ["max_level"] = self["max_level"],
        ["exp"] = self["exp"],
        ["current_job"] = self["current_job"],
        ["passive_skill"] = self["passive_skill"],
        ["active_skill"] = self["active_skill"],
        ["study_ability"] = self["study_ability"],
        ["npc_goodwill"] = self["npc_goodwill"],
        ["special_data"] = self["special_data"],
        ["current_choose"] = self["current_choose"],
    }
    return HH_UTILS:HHCopyTable(hh_table)
end
function HH_COM:SendClient()
    HH_UTILS:HHClientRpc(self["inst"], "hh_job_data", HH_UTILS:TableToStr(self:CreateSaveTable()))
end
----
---重置等级经验技能
---
function HH_COM:ResetLevel()
    self["level"] = 1
    self["exp"] = 0--经验

    --被动技能
    self["passive_skill"] = {}
    --主动技能
    self["active_skill"] = {}

    --学会的装备图纸--限定铁匠 铁匠会学习图纸永久保留
    self["study_ability"] = {}
    self["special_data"] = {}
end
----
---保存旧版职业属性
---
function HH_COM:SaveOldJobData(job_id, job_data)
    self["save_data"][job_id] = HH_UTILS:HHCopyTable(job_data)
end
----
---开启新的职业
---
function HH_COM:SetJob(job_id)
    local old_job = self["current_job"]
    local player = self["inst"]
    if not HH_UTILS:IsHHType(job_id, "string") then
        return false, "入参错误，请选择合规的职业"
    end
    if not HH_UTILS:IsHHType(HH_JOB_CONFIG[job_id], "table") then
        return false, "未知职业，转职失败"
    end
    if not HH_UTILS:NotIsDead(player) then
        return false, "死亡状态无法进行操作"
    end
    if old_job == job_id then
        return false, "职业重复，转职失败"
    end
    --区分是第一次选职业还是后续转职
    if old_job and HH_JOB_CONFIG[old_job] then
        local old_job_config = HH_UTILS:IsHHType(HH_JOB_CONFIG[old_job], "table") and HH_JOB_CONFIG[old_job] or {}
        --卸掉原有职业的一些初始任务函数和技能等等
        if old_job_config["stop_fn"] then
            old_job_config["stop_fn"](player)
        end
        ----保存旧职业属性
        local old_job_data = self:CreateSaveTable()
        self:SaveOldJobData(old_job, old_job_data)
    end
    local new_job_config = HH_JOB_CONFIG[job_id]
    --重置等级
    self:ResetLevel()
    if HH_UTILS:IsHHType(new_job_config["max_level"], "number") and new_job_config["max_level"] > 0 then
        --职业最大等级-取自配置
        local max_num = new_job_config["max_level"]
        self["max_level"] = max_num
    end
    self["current_job"] = job_id
    --新职业的初始函数
    if new_job_config["start_fn"] then
        new_job_config["start_fn"](player)
    end
    self:SendClient()
    return true, "转职成功"
end
----
---获取职业等级
---
function HH_COM:GetJobLevel()
    return tonumber(self["level"]) or 1
end

function HH_COM:GetMaxLevel()
    return tonumber(self["max_level"]) or 5
end
----
---设置等级
---
function HH_COM:SetLevel()
end
----
---校验是否是合规职业
---
function HH_COM:CheckJobIsValid()
    local job_id = self["current_job"]
    if not job_id or not HH_UTILS:IsHHType(HH_JOB_CONFIG[job_id], "table") then
        return false
    end
    return true
end
----
---增加经验
---
function HH_COM:AddExp(exp_num)
    local job_id = self["current_job"]
    if not self:CheckJobIsValid() then
        return false, "查询职业失败"
    end
    if not HH_UTILS:IsHHType(exp_num, "number") or exp_num <= 0 then
        return false, "经验值输入错误"
    end
    local current_level = self["level"]
    local max_level = self["max_level"]
    if current_level >= max_level then
        return true, "等级已到达上限"
    end
    local job_config = HH_JOB_CONFIG[job_id]
    if not HH_UTILS:IsHHType(job_config["level_config"], "table") then
        return false, "等级经验配置查询失败"
    end
    --开始加经验
    local level_config = job_config["level_config"]
    local current_exp = self["exp"]
    local new_exp = current_exp + exp_num
    --配置key
    local level_index = "level_" .. current_level
    local base_exp = 100000000--如果不加配置 默认一亿经验升级
    if HH_UTILS:IsHHType(level_config[level_index], "table")
            and HH_UTILS:IsHHType(level_config[level_index]["exp"], "number")
            and level_config[level_index]["exp"] > 0
    then
        base_exp = level_config[level_index]["exp"]
    end
    while new_exp > base_exp do
        self:LevelUp()
        new_exp = new_exp - base_exp
    end
    self["exp"] = new_exp
    self:SendClient()
    return true, "经验增加成功"
end
----
---升级
---
function HH_COM:LevelUp()
    local job_id = self["current_job"]
    if not self:CheckJobIsValid() then
        return false, "查询职业失败"
    end
    local current_level = self["level"]
    local max_level = self["max_level"]
    if current_level >= max_level then
        return false, "等级已到达上限"
    end
    local player = self["inst"]
    local new_level = current_level + 1
    local job_config = HH_JOB_CONFIG[job_id]
    if HH_UTILS:IsHHType(job_config["level_config"], "table") and job_config["level_config"]["start_fn"] then
        job_config["level_config"]["start_fn"](player)
    end
    self["level"] = new_level
    self:SendClient()
    return true, "等级提升"
end
----
---卸载被动技能函数,场景-转职新职业
---
function HH_COM:RemovePassiveFn()

end

function HH_COM:SpawnContainer()
    if self["job_container"] == nil then
        local chester = SpawnPrefab("hh_job_container")
        if chester then
            SetChester(self, chester, "job_container")
        end
    end
end
----
---打开职业空间
---
function HH_COM:OpenContainer()
    local hh_container = self["job_container"]
    local player = self["inst"]
    if not HH_UTILS:HasComponents(hh_container, "container") then
        return
    end
    if hh_container["components"]["container"]:IsOpenedBy(player) then

        hh_container["components"]["container"]:Close(player)
    else
        if HH_UTILS:HasComponents(player, "hh_player") then
            --关闭掉额外容器
            player["components"]["hh_player"]:CloseAllContainer()
        end
        hh_container["components"]["container"]:Open(player)
    end
end

function HH_COM:TestRpc()
    HH_UTILS:HHClientRpc(self["inst"], "hh_waring_data", HH_UTILS:TableToStr({
        { ["str"] = "任务完成", ["color"] = nil, ["scale"] = 20 },
        { ["str"] = "任务完成-2", ["color"] = nil, ["scale"] = 20 },
    }))
end
--------------------------能力相关-----------------------------------
local function getJobAbility(job_id)
    if not HH_UTILS:IsHHType(job_id, "string") then
        return {}
    end
    if job_id == "smith" then
        return SMITH_ABILITY
    end
    return {}
end
----
---是否学会x能力-校验函数
---@param ability_id:能力id
---
function HH_COM:HasAbility(ability_id)
    return self["study_ability"] and self["study_ability"][ability_id] or false
end
----
---学习x能力
---@param ability_id:能力id
---
function HH_COM:StudyAbility(ability_id)
    if not HH_UTILS:IsHHType(ability_id, "string") then
        return false
    end
    self["study_ability"][ability_id] = true
    --todo 同步客机
    self:SendClient()
    return true
end
----
---遗忘x能力
---@param ability_id:能力id
---
function HH_COM:ForgetAbility(ability_id)
    if not HH_UTILS:IsHHType(ability_id, "string") then
        return false
    end
    self["study_ability"][ability_id] = false
    --todo 同步客机
    self:SendClient()
    return true
end
----
---特殊参数值
---@param k_id:k
---@param value:v
---
function HH_COM:SetSpecialData(k_id, value)
    if not HH_UTILS:IsHHType(k_id, "string") then
        return
    end
    self["special_data"][k_id] = value
end
----
---获取特殊参数值
---@param k_id:k_id
---
function HH_COM:GetSpecialData(k_id)
    return self["special_data"][k_id]
end
--------------------------能力相关-----------------------------------
--------------------------获取食物三维-----------------------------------
local function checkFoodNum(value)
    if not HH_UTILS:IsHHType(value, "number") then
        return 0
    end
    return value
end
function HH_COM:GetHungerValue(value)
    local base_value = checkFoodNum(value)
    local new_value = value
    return new_value
end
function HH_COM:GetSanityValue(value)
    local base_value = checkFoodNum(value)
    local new_value = value
    return new_value
end
function HH_COM:GetHealthValue(value)
    local base_value = checkFoodNum(value)
    local new_value = value
    return new_value
end
--------------------------获取食物三维-----------------------------------
function HH_COM:OnSave()
    local save_list = {}
    if self["job_container"] then
        save_list["job_container"] = self["job_container"]:GetSaveRecord()
    end
    return save_list
end

function HH_COM:OnLoad(data)
    if not data then
        return
    end
    if data["job_container"] then
        local chester = SpawnSaveRecord(data["job_container"])
        SetChester(self, chester, "job_container")
    end
end
-------------------debug-------------------------
function HH_COM:SpawnJobCard(job_id)
    if not job_id or not HH_JOB_CONFIG[job_id] then
        return
    end
    local player = self["inst"]
    local test_inst = SpawnPrefab("hh_job_card")
    if not test_inst then
        return
    end
    test_inst["hh_job_id"] = job_id
    if test_inst["HH_Update_Server"] then
        test_inst:HH_Update_Server()
    end
    player["components"]["inventory"]:GiveItem(test_inst)
end
-------------------debug-------------------------
return HH_COM
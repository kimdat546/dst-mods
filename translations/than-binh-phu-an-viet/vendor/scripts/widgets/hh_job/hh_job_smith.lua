local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local main_xml, main_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local HH_Task_Ui = require("widgets/hh_job/hh_job_task")
local HH_Pet_Ui = require("widgets/hh_job/hh_job_pet")
----
---铁匠职业ui板块
---
local tab_config = {
    {
        ["name"] = "详情",
        ["click_fn"] = function(self)
            self:CreateMainUi()

            if self["owner"] then
                --推送事件 更新格子坐标
                HH_UTILS:SetClientValue(self["owner"], "hh_job_slot_change", "main")
            end
        end,
    },
    {
        ["name"] = "锻造",
        ["click_fn"] = function(self)

        end,
    },
    {
        ["name"] = "拆解",
        ["click_fn"] = function(self)

        end,
    },
    {
        ["name"] = "鉴定",
        ["click_fn"] = function(self)

        end,
    },
    {
        ["name"] = "商店",
        ["click_fn"] = function(self)

        end,
    },
    {
        ["name"] = "宝宝",
        ["click_fn"] = function(self)
            self:CreatePetUi()
            if self["owner"] then
                HH_UTILS:SetClientValue(self["owner"], "hh_job_slot_change", "pet")
            end
        end,
    },
    {
        ["name"] = "任务",
        ["click_fn"] = function(self)
            self:CreateTaskUi()
            if self["owner"] then
                --推送事件 更新格子坐标
                HH_UTILS:SetClientValue(self["owner"], "hh_job_slot_change", "task")
            end
        end,
    },
}

local function addTabButton(father, ui_id, str, hh_pos, click_fn)
    if not father then
        return
    end
    if father[ui_id] then
        HH_UTILS:HHKillChild(father, ui_id)
    end
    father[ui_id] = father:AddChild(ImageButton(main_xml, main_tex))
    father[ui_id]:SetPosition(hh_pos)
    local scale_x, scale_y = 7, 3.5
    father[ui_id]["image"]:SetScale(scale_x, scale_y, 1)
    father[ui_id]["image"]:SetTint(0, 0, 0, 0.5)
    father[ui_id]["OnGainFocus"] = function()
        father[ui_id]["image"]:SetScale(scale_x * 1.1, scale_y * 1.1, 1)
    end
    father[ui_id]["OnLoseFocus"] = function()
        father[ui_id]["image"]:SetScale(scale_x, scale_y, 1)
    end
    father[ui_id]["hh_str"] = HH_UTILS:HHCreateTextUi(father[ui_id], Vector3(0, 0, 1), tostring(str), { 1, 1, 1, 1 }, 20)
    if HH_UTILS:IsHHType(click_fn, "function") then
        father[ui_id]:SetOnClick(click_fn)
    end
end
--背景大小
local main_size_x, main_size_y = 100, 100
local HH_UI = Class(Widget, function(self, owner, data)
    Widget["_ctor"](self, "hh_smith_ui")
    self["owner"] = owner
    --print(self["owner"], "铁匠职业ui")
    if data then
        main_size_x = data["size_x"] or 100
        main_size_y = data["size_y"] or 100
    end
    local main_offset = 50
    --self["hh_main"] = HH_UTILS:HHCreateTextUi(self, Vector3(0, 0, 1), "abcd", { 1, 1, 1, 1 }, 50)
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self, main_xml, main_tex, Vector3(0, 0, 1), main_size_x - main_offset, main_size_y - main_offset, { 0, 0, 0, 0.2 })
    self:CreateTabUi(1)
end)

function HH_UI:CreateTabUi(hh_index)
    HH_UTILS:HHKillChild(self["hh_main"], "hh_tab_ui")

    self["hh_main"]["hh_tab_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["hh_tab_ui"]
    father_ui:SetPosition(-main_size_x / 2 + 50, 150, 1)
    local btn_start_x, btn_start_y = 0, 0
    for i, v in ipairs(tab_config) do
        if v and v["name"] then
            local ui_name = "hh_tab_" .. i
            addTabButton(father_ui, ui_name, tostring(v["name"]), Vector3(0, 0, 1), function()
                if self["btn_index"] == i then
                    return
                end
                self["btn_index"] = i
                if v["click_fn"] then
                    v["click_fn"](self)
                end
                self:CreateTabUi(self["btn_index"])
            end)
            if hh_index and hh_index == i then
                if father_ui[ui_name]["onclick"] then
                    father_ui[ui_name]["onclick"]()
                end
                if father_ui[ui_name]["image"] then
                    father_ui[ui_name]["image"]:SetTint(1, 1, 1, 0.5)
                end
            else
                if father_ui[ui_name]["image"] then
                    father_ui[ui_name]["image"]:SetTint(0, 0, 0, 0.5)
                end
            end
            father_ui[ui_name]["OnGainFocus"] = function()
            end
            father_ui[ui_name]["OnLoseFocus"] = function()
            end
            local text_size_x, text_size_y = 40, 20
            father_ui[ui_name]:SetPosition(btn_start_x + text_size_x / 2, btn_start_y, 1)
            btn_start_x = btn_start_x + text_size_x + 15
        end
    end
end
----
---创建个人详情页面
---
function HH_UI:CreateMainUi()
    if not self["hh_main"] or not self["owner"] then
        return
    end
    local player = self["owner"]
    local father_ui = self["hh_main"]
    HH_UTILS:HHKillChild(father_ui, "hh_tab_main_ui")
    local start_pos_x, start_pos_y = -main_size_x / 2 + 50, 120
    father_ui["hh_tab_main_ui"] = father_ui:AddChild(Widget())
    local tab_father_ui = father_ui["hh_tab_main_ui"]
    tab_father_ui["hh_info_ui"] = HH_UTILS:CreateInfoUi(tab_father_ui, {
        ["name"] = { ["str"] = tostring(player["name"]), ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
        --todo 主机同步
        ["job"] = { ["str"] = "铁匠", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
        ["level"] = { ["str"] = "Lv-1(上限5)", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
        ["exp"] = { ["str"] = "10/300", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
    }, {
        { ["id"] = "name", ["name"] = "玩家:", ["scale"] = 20, },
        { ["id"] = "job", ["name"] = "职业:", ["scale"] = 20, },
        { ["id"] = "level", ["name"] = "等级:", ["scale"] = 20, },
        { ["id"] = "exp", ["name"] = "经验:", ["scale"] = 20, },
    })
    tab_father_ui["hh_info_ui"]:SetPosition(start_pos_x, start_pos_y, 1)

    --tab_father_ui["hh_container_title"] = HH_UTILS:HHCreateTextUi(tab_father_ui, Vector3(0, 0, 1), "职业空间", { 255 / 255, 102 / 255, 0 / 255, 1 }, 20)
    --local title_size_x, title_size_y = tab_father_ui["hh_container_title"]:GetRegionSize()
    --tab_father_ui["hh_container_title"]:SetPosition(start_pos_x + title_size_x / 2, 0, 1)
    --职业介绍 放在右边
    local desc_str = "这边是帮助1"
    tab_father_ui["hh_extra_help"] = HH_UTILS:CreateMoreTextUi(tab_father_ui, {
        { ["str"] = "职业介绍", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        --{ ["str"] = HH_UTILS:SubStrByLength(desc_str, 20), ["scale"] = 20 },
        { ["str"] = HH_UTILS:RemoveWhiteText(desc_str), ["scale"] = 20 },
    }, 3)
    tab_father_ui["hh_extra_help"]:SetPosition(start_pos_x, 0, 1)
end
----
---创建任务ui 通用模板 起点为屏幕中心点
---
function HH_UI:CreateTaskUi()
    if not self["hh_main"] or not self["owner"] then
        return
    end
    local player = self["owner"]
    local father_ui = self["hh_main"]
    HH_UTILS:HHKillChild(father_ui, "hh_tab_main_ui")
    father_ui["hh_tab_main_ui"] = father_ui:AddChild(Widget())
    local tab_father_ui = father_ui["hh_tab_main_ui"]
    tab_father_ui["hh_task"] = tab_father_ui:AddChild(HH_Task_Ui(self["owner"]))
end

----
---创建宝宝ui
---
function HH_UI:CreatePetUi()
    if not self["hh_main"] or not self["owner"] then
        return
    end
    local player = self["owner"]
    local father_ui = self["hh_main"]
    HH_UTILS:HHKillChild(father_ui, "hh_tab_main_ui")
    father_ui["hh_tab_main_ui"] = father_ui:AddChild(Widget())
    local tab_father_ui = father_ui["hh_tab_main_ui"]
    tab_father_ui["hh_task"] = tab_father_ui:AddChild(HH_Pet_Ui(self["owner"]))
end
return HH_UI
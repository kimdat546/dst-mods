local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local hh_main_size_x, hh_main_size_y = 10, 10
local job_ui_size_x, job_ui_size_y = 200, 350
local main_xml, main_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
-------------职业ui--------------------------------------
local HH_JOB_SMITH = require("widgets/hh_job/hh_job_smith")
-------------职业ui--------------------------------------
local function hookFocusFn(hh_ui, focus_str)
    local oldOnGainFocusBack = hh_ui["OnGainFocus"]
    hh_ui["OnGainFocus"] = function()
        if oldOnGainFocusBack then
            oldOnGainFocusBack()
        end
        hh_ui["hh_desc"] = HH_UTILS:HHCreateTextUi(hh_ui, Vector3(0, 0, 1), tostring(focus_str), { 1, 1, 1, 1 }, 30)
        hh_ui["hh_desc"]:MoveTo(Vector3(0, 20, 1), Vector3(0, 40, 1), 0.5)
    end
    local oldOnLoseFocus = hh_ui["OnLoseFocus"]
    hh_ui["OnLoseFocus"] = function()
        if oldOnLoseFocus then
            oldOnLoseFocus()
        end
        HH_UTILS:HHKillChild(hh_ui, "hh_desc")
    end
end
local function removeFocusFn(hh_ui)
    hh_ui["OnGainFocus"] = function()
    end
    hh_ui["OnLoseFocus"] = function()
    end
end
local HH_UI = Class(Widget, function(self, owner, container)
    Widget["_ctor"](self, "hh_job_ui")
    self["owner"] = owner
    print("职业ui", owner, container)
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --self["hh_open_button"] = HH_UTILS:HHCreateImageButton(self["root"], "images/crafting_menu_icons.xml", "filter_modded.tex", Vector3(-480, -300, 1), 0.2, 0.2)
    --hookFocusFn(self["hh_open_button"], "职业系统\n右键拖拽位置")
    --self["hh_open_button"]:SetOnClick(function()
    --    --print("点击职业系统")
    --    self:CreateMainUi()
    --end)
    --HH_UTILS:MakeUiCanMove(self["hh_open_button"])
end)
----
---打开职业ui
---
function HH_UI:CreateMainUi()
    if true then
        --todo 职业相关系统
        self:CreateJobComUi()
        --self:CreateChooseUi()
    else
        --self:CreateChooseUi()
    end
end

local job_config_test = {
    --["test_01"] = {
    --    ["name"] = "铁匠",
    --    ["desc"] = "精通锻造与修复武器装备。通过高超的技艺，铁匠能打造出强力的武器和护甲，提升玩家的战斗力。随着等级提升，铁匠能打造更加精良的装备，甚至拥有独特的附魔效果，为队伍提供强大支持。",
    --    ["str_ui_list"] = {
    --        { ["str"] = " ", ["color"] = { 1, 1, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "类型:辅助类,生活类,万金油", ["color"] = { 1, 1, 0, 1 }, ["scale"] = 18, },
    --        { ["str"] = "任务类型:", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "制造装备/提交材料", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
    --    },
    --    ["ui"] = HH_JOB_SMITH,
    --    ["color"] = { 1, 0, 0, 1 },
    --},
    --["test_02"] = {
    --    ["name"] = "光环骑士",
    --    ["desc"] = "擅长近战和防御。作为队伍的坚强盾牌，骑士不仅能吸引敌人攻击，还能为队友提供强力保护。随着经验积累，骑士的控制技能和团队支援能力愈发强大。",
    --    ["str_ui_list"] = {
    --        { ["str"] = " ", ["color"] = { 1, 1, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "类型:辅助类", ["color"] = { 1, 1, 0, 1 }, ["scale"] = 18, },
    --        { ["str"] = "任务类型:", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "击杀生物/提交道具", ["color"] = { 1, 0, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "特色:提供各种光环效果", ["color"] = { 1, 0, 0, 1 }, ["scale"] = 18, },
    --    },
    --    ["color"] = { 1, 1, 0, 1 },
    --},
    --["test_03"] = {
    --    ["name"] = "牧师",
    --    ["desc"] = "擅长恢复队友生命和解除负面状态。无论是单人治疗还是团队支援，牧师总是默默守护在队伍的背后，提供源源不断的恢复魔法。随着实力提升，牧师还可以施放强大的增益技能，帮助队友获得更强的战斗力。",
    --    ["color"] = { 1, 0, 0, 1 },
    --},
    --["test_03"] = {
    --    ["name"] = "猪猪骑士",
    --    ["desc"] = "大胆!我是小肥猪!!我是小肥猪!!我是小肥猪!!我是小肥猪!!我是小肥猪!!我是小肥猪!!我是小肥猪!!",
    --    ["str_ui_list"] = {
    --        { ["str"] = " ", ["color"] = { 1, 1, 1, 1 }, ["scale"] = 18, },
    --        { ["str"] = "类型:辅助类隐藏职业", ["color"] = { 1, 1, 0, 1 }, ["scale"] = 18, },
    --        { ["str"] = "眷顾人:知非", ["color"] = { 1, 1, 0, 1 }, ["scale"] = 18, },
    --    },
    --    ["color"] = { 1, 0, 0, 1 },
    --},
}
local choose_list = {
    "test_01", "test_02", "test_03"
}
----
---如果未选择过职业 打开是选择职业的ui
---
function HH_UI:CreateChooseUi()
    if self["hh_main"] then
        HH_UTILS:HHKillChild(self, "hh_main")
        return
    end
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self["root"], "images/global.xml", "square.tex", Vector3(0, 0, 1),
            hh_main_size_x, hh_main_size_y, { 0 / 255, 0 / 255, 26 / 255, 0 })

    self["hh_main"]["hh_title"] = HH_UTILS:HHCreateTextUi(self["hh_main"], Vector3(0, 270, 1), HH_UTILS:GetStrByKey("JOB", "job_start_choose"), { 1, 1, 1, 1 }, 50)
    local choose_num = 3--这边后续需要改动，主机保存选择数量,记得加上限
    local middle_pos_x, middle_pos_y = 0, 0
    --选择列数
    --local row_num = math["floor"](choose_num / 2)
    --是偶数
    --local is_two = (choose_num % 2) == 1
    local start_pos_x, start_pos_y = -350, 0
    for i = 1, choose_num do
        local job_pos_x, job_pos_y = start_pos_x + (i - 1) * 350, 0
        self["hh_main"]["hh_job_" .. i] = HH_UTILS:CreateFrameUiTwo(self["hh_main"], Vector3(job_pos_x, job_pos_y, 1),
                { ["size_x"] = job_ui_size_x, ["size_y"] = job_ui_size_y, ["color"] = { 41 / 255, 30 / 255, 21 / 255, 1 }, })
        local job_id = choose_list[i]
        if job_id and job_config_test[job_id] then
            self:CreateJobChooseUi(self["hh_main"]["hh_job_" .. i], job_id, job_config_test[job_id])
        end
    end

    --刷新按钮
    local father_ui = self["hh_main"]
    father_ui["hh_refresh"] = HH_UTILS:HHCreateImageButton(father_ui, "images/hh_icon/hh_refresh.xml", "hh_refresh.tex", Vector3(job_ui_size_x * 2, job_ui_size_y / 2 + 50, 1), 0.4, 0.4)
    --father_ui["hh_refresh"]:SetRotation(120)
    hookFocusFn(father_ui["hh_refresh"], string["format"](HH_UTILS:GetStrByKey("JOB", "job_refresh_format"), 10))

    father_ui["hh_refresh"]:SetOnClick(function()
        print("刷新职业")
        --todo rpc刷新职业
    end)
end
----
---每一个职业选择页ui
---
function HH_UI:CreateJobChooseUi(job_ui, job_id, job_config)
    if not (HH_UTILS:IsHHType(job_id, "string") and HH_UTILS:IsHHType(job_config, "table")) then
        return
    end
    local father_ui = job_ui
    local job_name = job_config["name"] or "职业名字"
    local job_desc = job_config["desc"] or "职业描述"
    local job_color = HH_UTILS:IsHHType(job_config["color"], "table") and job_config["color"] or { 1, 1, 1, 1 }
    print(job_name, job_desc)
    local offset_text = 20
    local title_scale = 35
    father_ui["hh_title"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, job_ui_size_y / 2 - title_scale / 2 - offset_text, 1), tostring(job_name), job_color, title_scale)
    --描述ui
    local desc_ui_pos_x, desc_ui_pos_y = -(job_ui_size_x - title_scale) / 2, (job_ui_size_y - title_scale * 2 - offset_text * 2) / 2
    father_ui["hh_desc_ui"] = HH_UTILS:HHCreateImageUi(father_ui, "images/global.xml", "square.tex", Vector3(0, 0, 1),
            job_ui_size_x - title_scale, job_ui_size_y - title_scale * 2 - offset_text * 2, { 0 / 255, 0 / 255, 26 / 255, 0.2 })
    --职业描述
    local desc_ui_str = HH_UTILS:SubStrByLength(tostring(job_desc), 12)
    father_ui["hh_desc_str"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, 0, 1), desc_ui_str, { 1, 1, 1, 1 }, 20, true)

    local desc_text_x, desc_text_y = father_ui["hh_desc_str"]:GetRegionSize()
    father_ui["hh_desc_str"]:SetPosition(desc_ui_pos_x + desc_text_x / 2 + offset_text / 2, desc_ui_pos_y - desc_text_y / 2 - offset_text / 2, 0)
    --特殊文字描述
    if HH_UTILS:IsHHType(job_config["str_ui_list"], "table") then
        father_ui["hh_list_str"] = HH_UTILS:CreateMoreTextUi(father_ui, job_config["str_ui_list"], 3)
        local list_str_ui_size_x, list_str_ui_size_y = father_ui["hh_list_str"]["max_x"], father_ui["hh_list_str"]["max_y"]
        father_ui["hh_list_str"]:SetPosition(desc_ui_pos_x + offset_text / 2, desc_ui_pos_y - desc_text_y - offset_text / 2, 0)
    end
    local btn_text_scale = 25
    father_ui["hh_btn"] = HH_UTILS:HHCreateImageButton(father_ui, "images/ui.xml", "button_large.tex", Vector3(0, -job_ui_size_y / 2 + btn_text_scale / 2 + offset_text, 1), 0.3, 0.3)
    father_ui["hh_btn"]["hh_text"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn"], Vector3(0, 1.5, 1), HH_UTILS:GetStrByKey("COMMON", "choose"), nil, btn_text_scale)
    --干掉聚焦缩放
    father_ui["hh_btn"]["OnGainFocus"] = function()
    end
    father_ui["hh_btn"]["OnLoseFocus"] = function()
    end
    father_ui["hh_btn"]:SetOnClick(function()
        print("选择当前职业", job_name)
        self:CreateJobSureUi(job_id, job_name)
    end)
end

function HH_UI:CreateJobSureUi(job_id, job_name)
    if not self["hh_main"] then
        return
    end
    local father_ui = self["hh_main"]
    HH_UTILS:HHKillChild(father_ui, "hh_job_sure_ui")
    father_ui["hh_job_sure_ui"] = HH_UTILS:CreateFrameUi(father_ui, Vector3(0, 0, 1),
            { ["size_x"] = 300, ["size_y"] = 150, ["color"] = { 109 / 255, 101 / 255, 88 / 255, 1 }, },
            { ["size"] = 3.5, ["color"] = { 0, 0, 0, 1 }, })
    local hh_str = string["format"](HH_UTILS:GetStrByKey("JOB", "job_change_sure_desc"), tostring(job_name))
    local sure_ui = father_ui["hh_job_sure_ui"]
    sure_ui["hh_title"] = HH_UTILS:HHCreateTextUi(sure_ui, Vector3(0, 25, 1), hh_str, { 1, 1, 1, 1 }, 25)
    sure_ui["hh_sure"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(-100, -50, 1), 8, 4, { 0, 0, 0, 0.5 })
    sure_ui["hh_sure"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_sure"], Vector3(0, 1.5, 1), HH_UTILS:GetStrByKey("COMMON", "sure"), nil, 20)
    removeFocusFn(sure_ui["hh_sure"])

    sure_ui["hh_sure"]:SetOnClick(function()
        --todo rpc通知主机选择转职
        HH_UTILS:HHKillChild(father_ui, "hh_job_sure_ui")
    end)
    sure_ui["hh_refuse"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(100, -50, 1), 8, 4, { 0, 0, 0, 0.5 })
    sure_ui["hh_refuse"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_refuse"], Vector3(0, 1.5, 1), HH_UTILS:GetStrByKey("COMMON", "refuse"), nil, 20)
    removeFocusFn(sure_ui["hh_refuse"])
    sure_ui["hh_refuse"]:SetOnClick(function()
        HH_UTILS:HHKillChild(father_ui, "hh_job_sure_ui")
    end)
end
----------------------------------职业ui页面---------------------------------------------------------
----
---创建职业相关职业
---
function HH_UI:CreateJobComUi()
    if self["hh_main"] then
        HH_UTILS:HHKillChild(self, "hh_main")
        return
    end
    self["hh_main"] = HH_UTILS:CreateFrameUiTwo(self["root"], Vector3(0, 0, 1),
            {
                ["size_x"] = 700, ["size_y"] = 400,
                --["color"] = { 195 / 255, 175 / 255, 140 / 255, 0.5 },
                ["color"] = { 41 / 255, 30 / 255, 21 / 255, 1 },
            })
    local father_ui = self["hh_main"]
    local job_id = "test_01"
    if job_id and HH_UTILS:IsHHType(job_config_test[job_id], "table") and job_config_test[job_id]["ui"] then
        local ui_file = job_config_test[job_id]["ui"]
        father_ui["job_ui"] = father_ui:AddChild(ui_file(self["owner"], {
            ["size_x"] = 700,
            ["size_y"] = 400,
        }))
    else
        father_ui["job_ui"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, 0, 1), HH_UTILS:GetStrByKey("COMMON", "not_open"), { 1, 1, 1, 1 }, 50)
    end
    --打开职业空间
    --SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_job_container"])
end
----------------------------------职业ui页面---------------------------------------------------------
return HH_UI
----
---面板配置
---
local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Image = require("widgets/image")
local TextButton = require("widgets/textbutton")
local TrueScrollArea = require("widgets/truescrollarea")
local main_ui_xml, main_ui_tex = "images/scrapbook.xml", "scrap2_wide.tex"
local frame_list = {
    "hh_frame_left",
    "hh_frame_right",
    "hh_frame_up",
    "hh_frame_down",
}
--图标拆开区分 后期会用到图标皮肤
local icon_list = {
    "hh_icon_left_up",
    "hh_icon_right_up",
    "hh_icon_right_down",
    "hh_icon_left_down",
}
----颜色配置表
local COLOR_CONFIG = TUNING["HH_COLOR_CONFIG"] or {}
local ICON_CONFIG = TUNING["HH_ICON_CONFIG"] or {}
----
---图标皮肤
---
local HH_ICON_SKIN = {
    {
        ["name"] = "", ["xml"] = "", ["tex"] = "",
    },
}
local function createFrame(father, id, pos, size_x, size_y)
    if not father[id] then
        father[id] = father:AddChild(Image("images/hh_icon/hh_ui_frame.xml", "hh_ui_frame.tex"))
    end
    father[id]:SetPosition(pos)
    father[id]:SetTint(244 / 255, 255 / 255, 0 / 255, 1)
    if id == "hh_frame_left" or id == "hh_frame_right" then
        father[id]:SetRotation(90)
        father[id]:SetSize(size_y, size_x)
    else
        father[id]:SetSize(size_x, size_y)
    end
end
----
---边角图标
---
local function createFrameIcon(father, id, pos, size_y, hh_angle)
    if not father[id] then
        father[id] = father:AddChild(Image("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"))
    end
    father[id]:SetPosition(pos)
    if father[id]["texture"] == "hh_ui_icon.tex" then
        father[id]:SetTint(244 / 255, 255 / 255, 0 / 255, 1)
    end
    father[id]:SetSize(size_y, size_y)
    if HH_UTILS:IsHHType(hh_angle, "number") then
        father[id]:SetRotation(hh_angle)
    end
end
local function replaceColor(hh_color, hh_new, hh_index)
    if HH_UTILS:IsHHType(hh_new, "number")
            and HH_UTILS:IsHHType(hh_color, "table")
            and hh_color[hh_index]
    then
        hh_color[hh_index] = hh_new
    end
end
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

local function handleConfigTable(player, config, is_show)
    if HH_UTILS:IsHHType(config, "table")
            and HH_UTILS:IsHHType(config["back_ground_config"], "table")
            and HH_UTILS:IsHHType(config["frame_config"], "table")
            and HH_UTILS:IsHHType(config["back_ground_config"][1], "number")
            and HH_UTILS:IsHHType(config["back_ground_config"][2], "number")
            and HH_UTILS:IsHHType(config["frame_config"][1], "number")
            and HH_UTILS:IsHHType(config["frame_config"][2], "number")
            and HH_UTILS:IsHHType(config["icon_config"][1], "number")
            and HH_UTILS:IsHHType(config["icon_config"][2], "number")
            and HH_UTILS:IsHHType(config["icon_config"][3], "number")
            and HH_UTILS:IsHHType(config["icon_config"][4], "number")
    then
        config["close_show"] = is_show
        if TheSim and TheSim["SetPersistentString"] then
            TheSim:SetPersistentString("hh_hoverer_config", HH_UTILS:TableToStr(config), false)
            player:PushEvent("hh_hoverer_config")
        end
    end
end
----
---获取本地缓存的配置
---
local function getSimConfig(ui_config)
    local base_config = {
        ["back_ground_config"] = { 7, 5 }, --索引2是1-10 防止小数交互发生变化
        ["frame_config"] = { 31, 10 }, --索引2是1-10 防止小数交互发生变化
        ["icon_config"] = { 1, 1, 1, 1 }, --四个角图标配置
        ["close_show"] = false,
    }
    if HH_UTILS:IsHHType(ui_config, "table") then
        base_config = ui_config
    end
    if TheSim then
        TheSim:GetPersistentString("hh_hoverer_config", function(load_success, data)
            if load_success and data ~= nil then
                base_config = HH_UTILS:StrToTable(data)
            end
        end)
    end
    return base_config
end
local HH_UI = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_hoverer_config_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["hh_config"] = {
        ["back_ground_config"] = { 7, 5 }, --索引2是1-10 防止小数交互发生变化
        ["frame_config"] = { 31, 10 }, --索引2是1-10 防止小数交互发生变化
        ["icon_config"] = { 1, 1, 1, 1 }, --四个角图标配置
        ["close_show"] = false,
    }
    self["inst"]:ListenForEvent("hh_hoverer_config", function()
        if HH_UTILS:HasComponents(self["owner"], "hh_client") then
            local hh_config_client = self["owner"]["components"]["hh_client"]:GetValue("hh_hoverer_config")
            if HH_UTILS:IsHHType(hh_config_client, "table") then
                self["hh_config"] = hh_config_client
                if self["hh_main_ui"] then
                    HH_UTILS:HHKillChild(self, "hh_main_ui")
                    self:CreateMainUi()
                end
            end
        end
    end, self["owner"])
    --local sim_w, sim_h = TheSim:GetScreenSize()
    --self["hh_open_button"] = HH_UTILS:HHCreateImageButton(self["root"], "images/global.xml", "square.tex", Vector3(100 - sim_w / 2, 100 - sim_h / 2, 1), 1, 1)
    self["hh_open_button"] = HH_UTILS:HHCreateImageButton(self["root"], "images/crafting_menu_icons.xml", "filter_modded.tex", Vector3(-460, -300, 1), 0.15, 0.15)
    HH_UTILS:UiAddFocusStr(self["hh_open_button"], "信息面板配置\n右键拖拽位置", 20)
    self["hh_open_button"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_open_button"], Vector3(0, -20, 0), "面版配置", nil, 15)
    self["hh_open_button"]:SetOnClick(function()
        self:CreateMainUi()
    end)
    HH_UTILS:MakeUiCanMove(self["hh_open_button"])
end)
local function addTextButton(father, ui_id, str, hh_pos, click_fn)
    if not father then
        return
    end
    if father[ui_id] then
        HH_UTILS:HHKillChild(father, ui_id)
    end
    father[ui_id] = father:AddChild(TextButton())
    father[ui_id]:SetFont(CODEFONT)
    father[ui_id]:SetTextSize(30)
    father[ui_id]:SetText(tostring(str))
    father[ui_id]:SetPosition(hh_pos)
    father[ui_id]:SetTextColour({ 136 / 255, 96 / 255, 29 / 255, 1 })
    father[ui_id]:SetTextFocusColour({ 1, 1, 1, 1 })
    if HH_UTILS:IsHHType(click_fn, "function") then
        father[ui_id]:SetOnClick(click_fn)
    end
end
local function handleRGBA(self, hh_type, index_key)
    if self and HH_UTILS:IsHHType(self["hh_config"], "table") and
            HH_UTILS:IsHHType(self["hh_config"][index_key], "table")
            and HH_UTILS:IsHHType(self["hh_config"][index_key][2], "number")
    then
        if hh_type == "add" then
            self["hh_config"][index_key][2] = math["min"](self["hh_config"][index_key][2] + 1, 10)
        elseif hh_type == "reduce" then
            self["hh_config"][index_key][2] = math["max"](self["hh_config"][index_key][2] - 1, 0)
        end
    end
end
function HH_UI:CreateMainUi()
    if self["hh_main_ui"] then
        HH_UTILS:HHKillChild(self, "hh_main_ui")
        return
    end
    local hh_start_x, hh_start_y = 0, 0
    local main_size_x, main_size_y = 600, 600
    local hh_offset = 20
    hh_start_x = -main_size_x / 2 + hh_offset
    --self["hh_main_ui"] = HH_UTILS:HHCreateImageUi(self["root"], main_ui_xml, main_ui_tex, Vector3(100, 0, 1), main_size_x, main_size_y)

    self["hh_main_ui"] = HH_UTILS:CreateFrameUiTwo(self["root"], Vector3(100, 0, 1),
            { ["size_x"] = main_size_x, ["size_y"] = main_size_y, ["color"] = { 41 / 255, 30 / 255, 21 / 255, 1 }, })
    self["hh_main_ui"]["hh_close"] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/crafting_menu.xml", "pinslot_unpin_button.tex", Vector3(main_size_x / 2 - hh_offset, main_size_y / 2 - hh_offset, 1), 0.5, 0.5)
    self["hh_main_ui"]["hh_close"]:SetOnClick(function()
        self:CreateMainUi()
    end)
    --创建测试面板ui
    self:CreateHovererUi()
    ------------------------------------------------------------------------------------背景-------------------------------------------------------------------------------------------
    self["hh_main_ui"]["hh_back_ground_title"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "面板配置\n背景颜色", { 1, 1, 1, 1 }, 30, true)
    local hh_back_ground_title_size_x, hh_back_ground_title_size_y = self["hh_main_ui"]["hh_back_ground_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_back_ground_title"]:SetPosition(-main_size_x / 2 + hh_offset + hh_back_ground_title_size_x / 2, main_size_y / 2 - hh_offset - hh_back_ground_title_size_y / 2, 1)
    hh_start_y = main_size_y / 2 - hh_offset - hh_back_ground_title_size_y
    local small_ui_h = 10
    local hh_x_num = 19--每行八个
    local small_icon_size = 30
    --创建颜色块
    for i, v in ipairs(COLOR_CONFIG) do
        local hh_index = i - 1
        local pos_x, pos_y = hh_start_x + (hh_index % hh_x_num) * small_icon_size + small_icon_size / 2, hh_start_y - (math["floor"](hh_index / hh_x_num)) * small_icon_size - small_icon_size / 2
        local new_color = v["color"] and { v["color"][1] / 255, v["color"][2] / 255, v["color"][3] / 255, 1 } or { 1, 1, 1, 1 }
        self["hh_main_ui"]["hh_back_ground_color_" .. i] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex", Vector3(pos_x, pos_y, 1), small_icon_size / 8, small_icon_size / 8, new_color)
        ----初始化显示当前的配置选项
        if i == self["hh_config"]["back_ground_config"][1] then
            self:HandleBlackGround(new_color[1], new_color[2], new_color[3], self["hh_config"]["back_ground_config"][2] / 10)
            self["hh_main_ui"]["hh_back_ground_ok"] = HH_UTILS:HHCreateImageUi(self["hh_main_ui"], "images/ui.xml", "checkmark.tex", Vector3(pos_x, pos_y, 1), small_icon_size, small_icon_size)
        end
        hookFocusFn(self["hh_main_ui"]["hh_back_ground_color_" .. i], tostring(v["name"]))
        self["hh_main_ui"]["hh_back_ground_color_" .. i]:SetOnClick(function()
            HH_UTILS:HHKillChild(self["hh_main_ui"], "hh_back_ground_ok")
            self["hh_config"]["back_ground_config"][1] = i
            --刷新预览页面ui
            self:HandleBlackGround(new_color[1], new_color[2], new_color[3], self["hh_config"]["back_ground_config"][2] / 10)
            self["hh_main_ui"]["hh_back_ground_ok"] = HH_UTILS:HHCreateImageUi(self["hh_main_ui"], "images/ui.xml", "checkmark.tex", Vector3(pos_x, pos_y, 1), small_icon_size, small_icon_size)
        end)
    end
    local hh_num_y = math["floor"](#COLOR_CONFIG / hh_x_num)
    if #COLOR_CONFIG % hh_x_num > 0 then
        hh_num_y = hh_num_y + 1
    end
    hh_start_y = hh_start_y - hh_num_y * small_icon_size
    --创建透明度选项
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "透明度", { 1, 1, 1, 1 }, 30, true)
    local hh_back_ground_rgb_a_title_size_x, hh_back_ground_rgb_a_title_size_y = self["hh_main_ui"]["hh_back_ground_rgb_a_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]:SetPosition(hh_start_x + hh_back_ground_rgb_a_title_size_x / 2, hh_start_y - hh_back_ground_rgb_a_title_size_y / 2, 1)
    addTextButton(self["hh_main_ui"], "hh_back_ground_rgb_a_reduce", "减", Vector3(hh_start_x + 100, hh_start_y - hh_back_ground_rgb_a_title_size_y / 2, 1), function()
        handleRGBA(self, "reduce", "back_ground_config")
        if self["hh_main_ui"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"] then
            self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]:SetString(tostring(self["hh_config"]["back_ground_config"][2]))
        end
        self:HandleBlackGround(nil, nil, nil, self["hh_config"]["back_ground_config"][2] / 10)
    end)
    addTextButton(self["hh_main_ui"], "hh_back_ground_rgb_a_add", "加", Vector3(hh_start_x + 200, hh_start_y - hh_back_ground_rgb_a_title_size_y / 2, 1), function()
        handleRGBA(self, "add", "back_ground_config")
        if self["hh_main_ui"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"] then
            self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]:SetString(tostring(self["hh_config"]["back_ground_config"][2]))
        end
        self:HandleBlackGround(nil, nil, nil, self["hh_config"]["back_ground_config"][2] / 10)
    end)
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"]["hh_back_ground_rgb_a_title"], Vector3(125, 0, 1), tostring(self["hh_config"]["back_ground_config"][2]), nil, 30, true)
    ----------------------------------------------------------------------------边框---------------------------------------------------------------------------------------------------
    self["hh_main_ui"]["hh_frame_title"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "边框颜色", { 1, 1, 1, 1 }, 30, true)
    local hh_frame_title_size_x, hh_frame_title_size_y = self["hh_main_ui"]["hh_frame_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_frame_title"]:SetPosition(-main_size_x / 2 + hh_offset + hh_frame_title_size_x / 2, hh_start_y - hh_offset - hh_frame_title_size_y / 2, 1)
    hh_start_y = hh_start_y - hh_offset - hh_frame_title_size_y
    --创建颜色块
    for i, v in ipairs(COLOR_CONFIG) do
        local hh_index = i - 1
        local pos_x, pos_y = hh_start_x + (hh_index % hh_x_num) * small_icon_size + small_icon_size / 2, hh_start_y - (math["floor"](hh_index / hh_x_num)) * small_icon_size - small_icon_size / 2
        local new_color = v["color"] and { v["color"][1] / 255, v["color"][2] / 255, v["color"][3] / 255, 1 } or { 1, 1, 1, 1 }
        self["hh_main_ui"]["hh_frame_color_" .. i] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex", Vector3(pos_x, pos_y, 1), small_icon_size / 8, small_icon_size / 8, new_color)
        ----初始化显示当前的配置选项
        if i == self["hh_config"]["frame_config"][1] then
            self:HandleHovererFrame(new_color[1], new_color[2], new_color[3], self["hh_config"]["frame_config"][2] / 10)
            self["hh_main_ui"]["hh_frame_ok"] = HH_UTILS:HHCreateImageUi(self["hh_main_ui"], "images/ui.xml", "checkmark.tex", Vector3(pos_x, pos_y, 1), small_icon_size, small_icon_size)
        end
        hookFocusFn(self["hh_main_ui"]["hh_frame_color_" .. i], tostring(v["name"]))
        self["hh_main_ui"]["hh_frame_color_" .. i]:SetOnClick(function()
            HH_UTILS:HHKillChild(self["hh_main_ui"], "hh_frame_ok")
            self["hh_config"]["frame_config"][1] = i
            --刷新预览页面ui
            self:HandleHovererFrame(new_color[1], new_color[2], new_color[3], self["hh_config"]["frame_config"][2] / 10)
            self["hh_main_ui"]["hh_frame_ok"] = HH_UTILS:HHCreateImageUi(self["hh_main_ui"], "images/ui.xml", "checkmark.tex", Vector3(pos_x, pos_y, 1), small_icon_size, small_icon_size)
        end)
    end
    hh_start_y = hh_start_y - hh_num_y * small_icon_size
    --创建透明度选项
    self["hh_main_ui"]["hh_frame_rgb_a_title"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "透明度", { 1, 1, 1, 1 }, 30, true)
    local hh_frame_rgb_a_title_size_x, hh_frame_rgb_a_title_size_y = self["hh_main_ui"]["hh_frame_rgb_a_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_frame_rgb_a_title"]:SetPosition(hh_start_x + hh_frame_rgb_a_title_size_x / 2, hh_start_y - hh_frame_rgb_a_title_size_y / 2, 1)
    addTextButton(self["hh_main_ui"], "hh_frame_rgb_a_reduce", "减", Vector3(hh_start_x + 100, hh_start_y - hh_frame_rgb_a_title_size_y / 2, 1), function()
        handleRGBA(self, "reduce", "frame_config")
        if self["hh_main_ui"] and self["hh_main_ui"]["hh_frame_rgb_a_title"] and self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"] then
            self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]:SetString(tostring(self["hh_config"]["frame_config"][2]))
        end
        self:HandleHovererFrame(nil, nil, nil, self["hh_config"]["frame_config"][2] / 10)
    end)
    addTextButton(self["hh_main_ui"], "hh_frame_rgb_a_add", "加", Vector3(hh_start_x + 200, hh_start_y - hh_frame_rgb_a_title_size_y / 2, 1), function()
        handleRGBA(self, "add", "frame_config")
        if self["hh_main_ui"] and self["hh_main_ui"]["hh_frame_rgb_a_title"] and self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"] then
            self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]:SetString(tostring(self["hh_config"]["frame_config"][2]))
        end
        self:HandleHovererFrame(nil, nil, nil, self["hh_config"]["frame_config"][2] / 10)
    end)
    self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"]["hh_frame_rgb_a_title"], Vector3(125, 0, 1), tostring(self["hh_config"]["frame_config"][2]), nil, 30, true)
    -------------------------------------------------------------边角图标------------------------------------------------------------------------------------------------------------------
    hh_start_y = hh_start_y - hh_frame_rgb_a_title_size_y
    self["hh_main_ui"]["hh_icon_config_ui_title"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "四\n角\n图\n标", { 1, 1, 1, 1 }, 30, true)
    local hh_icon_config_ui_title_size_x, hh_icon_config_ui_title_size_y = self["hh_main_ui"]["hh_icon_config_ui_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_icon_config_ui_title"]:SetPosition(hh_start_x + hh_icon_config_ui_title_size_x / 2, hh_start_y - hh_icon_config_ui_title_size_y / 2 - hh_offset, 1)
    hh_start_x = hh_start_x + hh_icon_config_ui_title_size_x
    local sub_root = Widget()
    local child_size_w, child_size_h = 300, 50
    local image_size = 40
    for i, v in ipairs(ICON_CONFIG) do
        local child_pos_x, child_pos_y = child_size_w / 2 + hh_offset, -child_size_h * (i - 1 / 2)
        sub_root["icon_" .. i] = HH_UTILS:HHCreateImageUi(sub_root, "images/hh_icon/hh_white.xml", "hh_white.tex", Vector3(child_pos_x, child_pos_y, 1), child_size_w, child_size_h - 10, { 0, 0, 0, 0.3 })
        local icon_start_x, icon_start_y = -child_size_w / 2 + image_size / 2, 0
        if HH_UTILS:IsHHType(v, "table") then
            if v["no_icon"] then
                --默认无图标
                sub_root["icon_" .. i]["hh_icon"] = HH_UTILS:HHCreateTextUi(sub_root["icon_" .. i], Vector3(icon_start_x, icon_start_y, 1), "无", { 1, 1, 1, 1 }, image_size)
            elseif v["xml"] and v["tex"] then
                sub_root["icon_" .. i]["hh_icon"] = HH_UTILS:HHCreateImageUi(sub_root["icon_" .. i], v["xml"], v["tex"], Vector3(icon_start_x, icon_start_y, 1), image_size, image_size)
            end
            addTextButton(sub_root["icon_" .. i], "hh_button_01", "左上", Vector3(icon_start_x + image_size * 3 / 2, 0, 1), function()
                self:UpdateIconImg(1, i)
            end)
            addTextButton(sub_root["icon_" .. i], "hh_button_04", "左下", Vector3(icon_start_x + image_size * 5 / 2, 0, 1), function()
                self:UpdateIconImg(4, i)
            end)
            addTextButton(sub_root["icon_" .. i], "hh_button_02", "右上", Vector3(icon_start_x + image_size * 7 / 2, 0, 1), function()
                self:UpdateIconImg(2, i)
            end)
            addTextButton(sub_root["icon_" .. i], "hh_button_03", "右下", Vector3(icon_start_x + image_size * 9 / 2, 0, 1), function()
                self:UpdateIconImg(3, i)
            end)
            addTextButton(sub_root["icon_" .. i], "hh_button_all", "全部", Vector3(icon_start_x + image_size * 11 / 2, 0, 1), function()
                self:UpdateIconImg(1, i, true)
            end)
        end
    end
    --总宽
    local all_child_h = #ICON_CONFIG * child_size_h
    local notice_size_x, notice_size_y = 200, 150
    --裁切ui和整个滚动条的偏移 ui初始位置左上
    local scissor_data = {
        ["x"] = 0,
        ["y"] = 0,
        ["width"] = child_size_w,
        ["height"] = notice_size_y
    }
    local context = {
        --挂载ui
        ["widget"] = sub_root,
        --坐标偏移
        ["offset"] = {
            ["x"] = 0,
            ["y"] = notice_size_y,
        },
        ["size"] = {
            --未找到用处
            ["w"] = 0,
            --总ui大小
            ["height"] = all_child_h,
        }
    }
    local scrollbar = { ["scroll_per_click"] = 15 * 3 }
    self["hh_main_ui"]["hh_icon_config_ui"] = self["hh_main_ui"]:AddChild(TrueScrollArea(context, scissor_data, scrollbar))
    HH_UTILS:HookFocusCamera(self["hh_main_ui"]["hh_icon_config_ui"])
    self["hh_main_ui"]["hh_icon_config_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    self["hh_main_ui"]["hh_icon_config_ui"]["up_button"]:SetScale(0.35)
    self["hh_main_ui"]["hh_icon_config_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    self["hh_main_ui"]["hh_icon_config_ui"]["down_button"]:SetScale(-0.35)
    self["hh_main_ui"]["hh_icon_config_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    self["hh_main_ui"]["hh_icon_config_ui"]["scroll_bar_line"]:SetScale(0.3)
    self["hh_main_ui"]["hh_icon_config_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    self["hh_main_ui"]["hh_icon_config_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    self["hh_main_ui"]["hh_icon_config_ui"]["position_marker"]:SetScale(0.3)
    self["hh_main_ui"]["hh_icon_config_ui"]:SetPosition(hh_start_x, hh_start_y - notice_size_y, 1)
    --处理初始化面板映射
    if self["hh_config"] and HH_UTILS:IsHHType(self["hh_config"]["icon_config"], "table")
            and HH_UTILS:IsHHType(self["hh_config"]["icon_config"][1], "number")
            and HH_UTILS:IsHHType(self["hh_config"]["icon_config"][2], "number")
            and HH_UTILS:IsHHType(self["hh_config"]["icon_config"][3], "number")
            and HH_UTILS:IsHHType(self["hh_config"]["icon_config"][4], "number")
    then
        self:UpdateIconImg(1, self["hh_config"]["icon_config"][1])
        self:UpdateIconImg(2, self["hh_config"]["icon_config"][2])
        self:UpdateIconImg(3, self["hh_config"]["icon_config"][3])
        self:UpdateIconImg(4, self["hh_config"]["icon_config"][4])
    end
    --------------------------------------------------------------边角图标-----------------------------------------------------------------------------------------------------------------
    local sure_button_size = 100
    self["hh_main_ui"]["hh_sure_button"] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex",
            Vector3(main_size_x / 2 - sure_button_size - 60, -main_size_y / 2 + sure_button_size / 2, 1), sure_button_size / 10, sure_button_size / 24,
            { 231 / 255, 195 / 255, 156 / 255, 1 }
    )
    --保存在本地
    self["hh_main_ui"]["hh_sure_button"]:SetOnClick(function()
        handleConfigTable(self["owner"], self["hh_config"], false)
        --SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_update_hoverer_config"], HH_UTILS:TableToStr(self["hh_config"]))
    end)
    self["hh_main_ui"]["hh_sure_button"]["hh_str"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"]["hh_sure_button"], Vector3(0, 0, 1), "应用边框", nil, 25)
    --removeFocusFn(self["hh_main_ui"]["hh_sure_button"])
    -------------------------------是否展示面版ui-------------------------------
    self["hh_main_ui"]["close_show_hoverer"] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex",
            Vector3(main_size_x / 2 - sure_button_size + 30, -main_size_y / 2 + sure_button_size / 2 - 23, 1), sure_button_size / 10, sure_button_size / 24,
            { 231 / 255, 195 / 255, 156 / 255, 1 }
    )
    self["hh_main_ui"]["close_show_hoverer"]:SetOnClick(function()
        local client_config = getSimConfig(self["hh_config"])
        handleConfigTable(self["owner"], client_config, true)
    end)
    self["hh_main_ui"]["close_show_hoverer"]["hh_str"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"]["close_show_hoverer"], Vector3(0, 0, 1), "关闭显示", nil, 25)
    --removeFocusFn(self["hh_main_ui"]["close_show_hoverer"])
    self["hh_main_ui"]["open_show_hoverer"] = HH_UTILS:HHCreateImageButton(self["hh_main_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex",
            Vector3(main_size_x / 2 - sure_button_size + 30, -main_size_y / 2 + sure_button_size / 2 + 13, 1), sure_button_size / 10, sure_button_size / 24,
            { 231 / 255, 195 / 255, 156 / 255, 1 }
    )
    self["hh_main_ui"]["open_show_hoverer"]:SetOnClick(function()
        local client_config = getSimConfig(self["hh_config"])
        handleConfigTable(self["owner"], client_config, false)
    end)
    self["hh_main_ui"]["open_show_hoverer"]["hh_str"] = HH_UTILS:HHCreateTextUi(self["hh_main_ui"]["open_show_hoverer"], Vector3(0, 0, 1), "打开显示", nil, 25)
    --removeFocusFn(self["hh_main_ui"]["open_show_hoverer"])
    -------------------------------是否展示面版ui-------------------------------
end
----
---处理面板背景
---
function HH_UI:HandleBlackGround(hh_r, hh_g, hh_b, hh_a)
    if not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"]
            or not HH_UTILS:IsHHType(self["hh_main_ui"]["hh_hoverer_ui"]["tint"], "table")
    then
        return
    end
    local father_ui = self["hh_main_ui"]["hh_hoverer_ui"]
    local hh_color = father_ui["tint"]
    replaceColor(hh_color, hh_r, 1)
    replaceColor(hh_color, hh_g, 2)
    replaceColor(hh_color, hh_b, 3)
    replaceColor(hh_color, hh_a, 4)
    father_ui:SetTint(hh_color[1], hh_color[2], hh_color[3], hh_color[4])
end
----
---处理面板边框
---
function HH_UI:HandleHovererFrame(hh_r, hh_g, hh_b, hh_a)
    if not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"] then
        return
    end
    local father_ui = self["hh_main_ui"]["hh_hoverer_ui"]
    local isValidUi = true
    for i, v in ipairs(frame_list) do
        if not father_ui[v] or not HH_UTILS:IsHHType(father_ui[v]["tint"], "table") then
            isValidUi = false
            break
        end
    end
    for i, v in ipairs(icon_list) do
        if not father_ui[v] or not HH_UTILS:IsHHType(father_ui[v]["tint"], "table") then
            isValidUi = false
            break
        end
    end
    if not isValidUi then
        return
    end
    for i, v in ipairs(frame_list) do
        local hh_color = father_ui[v]["tint"]
        replaceColor(hh_color, hh_r, 1)
        replaceColor(hh_color, hh_g, 2)
        replaceColor(hh_color, hh_b, 3)
        replaceColor(hh_color, hh_a, 4)
        father_ui[v]:SetTint(hh_color[1], hh_color[2], hh_color[3], hh_color[4])
    end
    for i, v in ipairs(icon_list) do
        local hh_color = father_ui[v]["tint"]
        replaceColor(hh_color, hh_r, 1)
        replaceColor(hh_color, hh_g, 2)
        replaceColor(hh_color, hh_b, 3)
        replaceColor(hh_color, hh_a, 4)
        if father_ui[v]["texture"] == "hh_ui_icon.tex" then
            father_ui[v]:SetTint(hh_color[1], hh_color[2], hh_color[3], hh_color[4])
        end
    end
end
----
---更新四角图标
---
function HH_UI:UpdateIconImg(hh_index, icon_index, is_all)
    if not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"]
            or not HH_UTILS:IsHHType(hh_index, "number")
            or not HH_UTILS:IsHHType(icon_index, "number")
            or not icon_list[hh_index]
    then
        return
    end
    local frame_size = 45
    local frame_color = { 255, 255, 255, 10 }
    if self["hh_config"] and HH_UTILS:IsHHType(self["hh_config"]["frame_config"], "table")
            and HH_UTILS:IsHHType(self["hh_config"]["frame_config"][1], "number")
            and HH_UTILS:IsHHType(self["hh_config"]["frame_config"][2], "number")
            and HH_UTILS:IsHHType(COLOR_CONFIG[self["hh_config"]["frame_config"][1]], "table")
            and HH_UTILS:IsHHType(COLOR_CONFIG[self["hh_config"]["frame_config"][1]]["color"], "table")
            and icon_index == 1
    then
        frame_size = 6
        frame_color = COLOR_CONFIG[self["hh_config"]["frame_config"][1]]["color"]
        frame_color[4] = self["hh_config"]["frame_config"][2]
    end
    if not HH_UTILS:IsHHType(self["hh_config"]["icon_config"], "table") then
        self["hh_config"]["icon_config"] = { 1, 1, 1, 1 }
    end
    local father_ui = self["hh_main_ui"]["hh_hoverer_ui"]
    if is_all then
        for i, v in ipairs(icon_list) do
            local hh_angle = 0
            local icon_xml, icon_tex = "images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"
            if icon_index == 1 then
                hh_angle = (i - 1) * 90
            end
            if icon_index ~= 1 and ICON_CONFIG[icon_index] and ICON_CONFIG[icon_index]["xml"] and ICON_CONFIG[icon_index]["tex"] then
                icon_xml, icon_tex = ICON_CONFIG[icon_index]["xml"], ICON_CONFIG[icon_index]["tex"]
            end
            if father_ui[v] and father_ui[v]["SetTexture"] then
                father_ui[v]:SetTexture(icon_xml, icon_tex)
                father_ui[v]:SetRotation(hh_angle)
                father_ui[v]:SetTint(frame_color[1] / 255, frame_color[2] / 255, frame_color[3] / 255, frame_color[4] / 10)
                father_ui[v]:SetSize(frame_size, frame_size)
            end
        end
        self["hh_config"]["icon_config"] = { icon_index, icon_index, icon_index, icon_index }
    else
        local ui_name = icon_list[hh_index] or "hh_icon_left_up"
        if father_ui[ui_name] and father_ui[ui_name]["SetTexture"] then
            local hh_angle = 0
            local icon_xml, icon_tex = "images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"
            if icon_index == 1 then
                hh_angle = (hh_index - 1) * 90
            end
            if icon_index ~= 1 and ICON_CONFIG[icon_index] and ICON_CONFIG[icon_index]["xml"] and ICON_CONFIG[icon_index]["tex"] then
                icon_xml, icon_tex = ICON_CONFIG[icon_index]["xml"], ICON_CONFIG[icon_index]["tex"]
            end
            father_ui[ui_name]:SetTexture(icon_xml, icon_tex)
            father_ui[ui_name]:SetRotation(hh_angle)
            father_ui[ui_name]:SetTint(frame_color[1] / 255, frame_color[2] / 255, frame_color[3] / 255, frame_color[4] / 10)
            father_ui[ui_name]:SetSize(frame_size, frame_size)
            self["hh_config"]["icon_config"][hh_index] = icon_index
        end
    end
end
----
---创建测试面板ui
---
function HH_UI:CreateHovererUi()
    if not self["hh_main_ui"] then
        return
    end
    HH_UTILS:HHKillChild(self["hh_main_ui"], "hh_hoverer_ui")
    local ui_size_x, ui_size_y = 200, 200
    local father_ui = self["hh_main_ui"]
    father_ui["hh_hoverer_ui"] = HH_UTILS:HHCreateImageUi(father_ui, "images/global.xml", "square.tex", Vector3(-500, 0, 1), ui_size_x, ui_size_y)
    --增加边框部分
    local frame_size = 6
    local com_x, com_y = ui_size_x / 2 + frame_size / 2, ui_size_y / 2 + frame_size / 2
    local com_size_x, com_size_y = ui_size_x + frame_size * 2, ui_size_y + frame_size * 2
    createFrame(father_ui["hh_hoverer_ui"], "hh_frame_left", Vector3(-com_x, 0, 1), frame_size, com_size_y)
    createFrame(father_ui["hh_hoverer_ui"], "hh_frame_right", Vector3(com_x, 0, 1), frame_size, com_size_y)
    createFrame(father_ui["hh_hoverer_ui"], "hh_frame_up", Vector3(0, com_y, 1), com_size_x, frame_size)
    createFrame(father_ui["hh_hoverer_ui"], "hh_frame_down", Vector3(0, -com_y, 1), com_size_x, frame_size)
    --增加边角图标
    createFrameIcon(father_ui["hh_hoverer_ui"], "hh_icon_left_up", Vector3(-com_x, com_y, 1), frame_size)
    createFrameIcon(father_ui["hh_hoverer_ui"], "hh_icon_left_down", Vector3(-com_x, -com_y, 1), frame_size, 270)
    createFrameIcon(father_ui["hh_hoverer_ui"], "hh_icon_right_up", Vector3(com_x, com_y, 1), frame_size, 90)
    createFrameIcon(father_ui["hh_hoverer_ui"], "hh_icon_right_down", Vector3(com_x, -com_y, 1), frame_size, 180)
end
function HH_UI:CreatBlackUi()
    self["black"] = self["root"]:AddChild(Image("images/global.xml", "square.tex"))
    self["black"]:SetVRegPoint(ANCHOR_MIDDLE)
    self["black"]:SetHRegPoint(ANCHOR_MIDDLE)
    self["black"]:SetVAnchor(ANCHOR_MIDDLE)
    self["black"]:SetHAnchor(ANCHOR_MIDDLE)
    self["black"]:SetScaleMode(SCALEMODE_FILLSCREEN)
    self["black"]:SetTint(0, 0, 0, 0.5)
    self["black"]["OnMouseButton"] = function()
    end
end
return HH_UI
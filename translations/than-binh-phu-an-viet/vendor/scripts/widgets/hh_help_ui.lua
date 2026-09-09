local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local TextButton = require("widgets/textbutton")
local HH_UTILS = require("utils/hh_utils")
local main_xml, main_tex = "images/global.xml", "square.tex"
local TrueScrollArea = require("widgets/truescrollarea")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local HH_SUIT_LIST = HH_CONFIG["HH_SUIT_LIST"]
local close_xml, close_tex = "images/crafting_menu.xml", "pinslot_unpin_button.tex"
local tab_xml, tab_tex = "images/scrapbook.xml", "tab.tex"
local plant_ui_xml = "images/plantregistry.xml"
local white_xml, white_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local hh_offset = 20
--自制滑轮控件
local SCROLL_UI = require("widgets/hh_widget_scroll_bar")
--只需要进入页面读一下日志表
local playerLogList = {}
local function getLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("help_ui", str_index)
end
local function getLogLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end

local child_name_size = 20
local child_name_color = { 255 / 255, 102 / 255, 0 / 255, 1 }
local child_desc_size = 20
local child_desc_color = { 255 / 255, 11 / 255, 0 / 255, 1 }
local extra_size = 10
local main_size_x, main_size_y = 800, 500
local _G_HH_UI_TEXT = TUNING["HH_UI_TEXT"]
local _G_HH_FORMAT_CONFIG = TUNING["HH_FORMAT_CONFIG"]
local function sendLogRpc(log_type)
    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_world_logs"], log_type, nil, nil)
end
local tab_config = {
    {
        ["name"] = "mod介绍",
        ["btn_type"] = "main",
        ["click_fn"] = function(self)
            self:CreateModInfo()
        end,
    },
    {
        ["name"] = "更新记录",
        ["btn_type"] = "update",
        ["click_fn"] = function(self)
            self:CreateLogUi()
        end,
    },
    {
        ["name"] = "词条详情",
        ["btn_type"] = "effect",
        ["click_fn"] = function(self)
            self:CreateEffectUi()
        end,
    },
    --{
    --    ["name"] = "宝石",
    --    ["btn_type"] = "gem",
    --    ["click_fn"] = function(self)
    --        self:CreateGemUi()
    --    end,
    --},
    {
        ["name"] = "日志",
        ["btn_type"] = "log",
        ["click_fn"] = function(self)
            sendLogRpc("")
            self:CreateWorldLogUi()
        end,
    },
}

-- 排序函数 根据id倒序 新词条在前面
local function sortById(a, b)
    local aValue = a["value"]
    local bValue = b["value"]
    -- 检查两个元素是否都有id
    if aValue["id"] and bValue["id"] then
        return aValue["id"] > bValue["id"]
        -- 只有a有id
    elseif aValue["id"] then
        return true
        -- 只有b有id
    elseif bValue["id"] then
        return false
        -- 两个元素都没有id
    else
        return false
    end
end
local effect_rare_str = "只能从合成台较低概率合成出来"
----
---封装所有词条信息
---
local function GetAllEquipBuff()
    local hh_copy = HH_UTILS:HHCopyTable(HH_EQUIP_BUFF_LIST)
    local hh_table = {}
    -- 将键值对转换为数组格式
    local itemList = {}
    for key, value in pairs(hh_copy) do
        table["insert"](itemList, { ["key"] = key, ["value"] = value })
    end
    -- 使用table.sort进行排序
    table["sort"](itemList, sortById)
    for i, v in ipairs(itemList) do
        if HH_UTILS:IsHHType(v, "table") and HH_UTILS:IsHHType(v["value"], "table") then
            local buff_config = v["value"]
            --套装属性不展示
            if not buff_config["is_suit"] then
                local buff_name = buff_config["name"] or "词条未定义"
                local buff_small_name = buff_config["client_text"] or "空"
                local buff_desc_format = buff_config["desc"] or "描述未定义"
                local buff_color = { 128 / 255, 138 / 255, 135 / 255, 1 }
                if buff_config["client_color"] then
                    buff_color = buff_config["client_color"]
                elseif not buff_config["can_add"] then
                    buff_color = { 255 / 255, 97 / 255, 0 / 255, 1 }
                end
                local range_value = buff_config["value_range"] and HH_UTILS:Template("{{min}}~{{max}}", buff_config["value_range"]) or "无取值范围"
                local buff_desc = buff_desc_format
                if range_value ~= "无取值范围" then
                    buff_desc = string["format"](buff_desc_format, range_value)
                end
                local buff_is_one = buff_config["only_one"] and "只允许存在一条" or "可重复附魔"
                local buff_can_get = buff_config["can_add"] and "可以通过普通附魔获取" or "精英/boss掉落的专属附魔石/武器包裹"
                if buff_config["only_compound"] then
                    buff_can_get = effect_rare_str
                end
                if buff_config["ui_from_desc"] then
                    buff_can_get = tostring(buff_config["ui_from_desc"])
                end
                local buff_check_desc = "无"
                if buff_config["check_desc"] then
                    buff_check_desc = tostring(buff_config["check_desc"])
                end
                table["insert"](hh_table, {
                    ["name"] = buff_name,
                    ["small_name"] = buff_small_name,
                    ["desc"] = buff_desc,
                    ["color"] = buff_color,
                    ["range_value"] = range_value,
                    ["is_one"] = buff_is_one,
                    ["can_add"] = buff_can_get,
                    ["check_desc"] = buff_check_desc,
                })
            end
        end
    end
    return hh_table
end
----
---获取所有可以查看的的套装词条-定制套装只能有权限才能查看
---
local function GetAllSuitBuff(player)
    local limit_suit_list = HH_UTILS:GetClientValue(player, "hh_suit_list")
    if not HH_UTILS:IsHHType(limit_suit_list, "table") then
        limit_suit_list = {}
    end
    local hh_copy = HH_UTILS:HHCopyTable(HH_SUIT_LIST)
    local hh_table = {}
    local hh_sort_table = HH_UTILS:TableSortKeys(hh_copy)
    local SUIT_CONFIG_STR = _G_HH_FORMAT_CONFIG["SUIT_CONFIG"]
    for i, v in ipairs(hh_sort_table) do
        if HH_UTILS:IsHHType(hh_copy[v], "table")
                and SUIT_CONFIG_STR[v]
        then
            local has_limit = true
            if hh_copy[v]["is_person"] and not limit_suit_list[v] then
                -- 定制套装不展示
                has_limit = false
            end
            if has_limit then
                local buff_config = SUIT_CONFIG_STR[v]
                local buff_name = buff_config["name"] or "词条未定义"
                local buff_desc = buff_config["effect_str"] or "描述未定义"
                table["insert"](hh_table, { ["str"] = "套装(已移除):" .. buff_name, ["color"] = { 255 / 255, 242 / 255, 0 / 255, 1 }, ["scale"] = 30 })
                table["insert"](hh_table, { ["str"] = "效果:" .. buff_desc, ["color"] = nil, ["scale"] = 30 })
                table["insert"](hh_table, { ["str"] = " ", ["color"] = nil, ["scale"] = 10 })
            end
        end
    end
    return hh_table
end
local HH_HELP = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_help_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["hh_open_button"] = HH_UTILS:HHCreateImageButton(self["root"], "images/button_icons.xml", "newsletter.tex",
            Vector3(-520, -300, 1), 0.15, 0.15)
    HH_UTILS:UiAddFocusStr(self["hh_open_button"], "mod帮助\n右键拖拽位置", 20)
    self["hh_open_button"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_open_button"], Vector3(0, -20, 0), "帮助", nil, 15)
    self["hh_open_button"]:SetOnClick(function()
        if self["hh_main"] then
            HH_UTILS:HHKillChild(self, "hh_main")
        else
            self:CreateMainUi()
        end
    end)
    HH_UTILS:MakeUiCanMove(self["hh_open_button"])

    self["hh_open_container"] = HH_UTILS:HHCreateImageButton(self["root"], "images/crafting_menu_icons.xml", "filter_summer.tex",
            Vector3(-580, -300, 1), 0.15, 0.15)
    HH_UTILS:UiAddFocusStr(self["hh_open_container"], string.format("打开强化页面(当前热键:%s)\n右键拖拽位置", tostring(TUNING["HH_KEY_CONFIG"])), 20)
    self["hh_open_container"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_open_container"], Vector3(0, -20, 0), "强化空间", nil, 15)
    self["hh_open_container"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
    end)
    HH_UTILS:MakeUiCanMove(self["hh_open_container"])
    ------------------日志监听回调-------------------------

    self["inst"]:ListenForEvent("hh_world_logs", function(inst, data)
        self:UpdateWorldLogUi()
    end, self["owner"])

end)
function HH_HELP:CreateMainUi(tab_index)
    HH_UTILS:HHKillChild(self, "hh_main")
    local hh_index = tab_index or 1
    if not tab_config[hh_index] then
        hh_index = 1
    end
    local main_length = main_size_x - 15
    --棕色{ 55 / 255, 42 / 255, 26 / 255, 0.8 }
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self["root"], plant_ui_xml, "backdrop.tex", Vector3(0, 0, 1), main_length, main_size_y)
    local father_weight, father_height = self["hh_main"]:GetSize()
    self["hh_main"]["hh_close"] = HH_UTILS:HHCreateImageButton(self["hh_main"], "images/crafting_menu.xml", "pinslot_unpin_button.tex",
            Vector3(main_size_x / 2 - hh_offset / 2 - 20, main_size_y / 2 - hh_offset / 2, 1), 0.7, 0.7)
    self["hh_main"]["hh_close"]:SetOnClick(function()
        HH_UTILS:HHKillChild(self, "hh_main")
    end)
    local tab_num = #tab_config
    local father_ui = self["hh_main"]
    local tab_start_x, tab_start_y = -father_weight / 2, father_height / 2 + 13
    local current_ui = nil
    for i = 1, tab_num do
        local child_config = tab_config[i] or {}
        local child_name = child_config["name"] or "未定义标题"
        local child_btn_id = child_config["btn_type"] or "main"
        local child_ui_name = "hh_tab_" .. i
        local tab_pos_x = tab_start_x + i * 120 - 20
        local hh_tex = "plant_tab_inactive.tex"
        if hh_index == i then
            current_ui = child_ui_name
            hh_tex = "plant_tab_active.tex"
        end
        father_ui[child_ui_name] = HH_UTILS:HHCreateImageButton(father_ui, plant_ui_xml, hh_tex, Vector3(tab_pos_x, tab_start_y, 1), 0.35, 0.45)
        father_ui[child_ui_name]["clickoffset"] = Vector3(0, 0, 0)
        father_ui[child_ui_name]["OnGainFocus"] = function()
        end
        father_ui[child_ui_name]["OnLoseFocus"] = function()
        end
        father_ui[child_ui_name]["tab_name"] = HH_UTILS:HHCreateTextUi(father_ui[child_ui_name], Vector3(0, -7, 1), tostring(child_name), { 216 / 255, 180 / 255, 74 / 255, 1 }, 30)
        --以选中的tab就行排版
        if i > hh_index then
            father_ui[child_ui_name]:MoveToBack()
        else
            father_ui[child_ui_name]:MoveToFront()
        end
        father_ui[child_ui_name]:SetOnClick(function()
            if self["tab_index"] == i then
                return
            end
            --这个用于监听rpc事件回调刷新页面
            self["current_tab"] = child_btn_id
            self:CreateMainUi(i)
        end)
    end
    --执行切换tab函数
    if tab_config[hh_index] and tab_config[hh_index]["click_fn"] then
        tab_config[hh_index]["click_fn"](self)
    end
    --记录当前索引位置
    self["tab_index"] = hh_index
end
local function removeWhiteText(hh_text)
    return hh_text:gsub("\n%s*", "\n"):gsub("^%s*", "")
end
----
---创建mod介绍页
---
function HH_HELP:CreateModInfo()
    self:CreateTitle("传奇武器mod介绍")
    local father_ui = self["hh_main"]["main_ui"]

    --左下为起点0-0-0
    local sub_root = Widget()
    local ui_text_config = _G_HH_UI_TEXT["MOD_INFO"]
    --sub_root["hh_ui"] = HH_UTILS:CreateMoreTextUi(sub_root, {
    --    { ["str"] = "附魔部分", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 28 },
    --    { ["str"] = removeWhiteText(ui_text_config["mod_role"]), ["color"] = nil, ["scale"] = 28 },
    --    { ["str"] = " ", ["color"] = nil, ["scale"] = 35 },
    --    { ["str"] = "怪物强化", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 28 },
    --    { ["str"] = removeWhiteText(ui_text_config["monster"]), ["color"] = nil, ["scale"] = 28 },
    --    { ["str"] = " ", ["color"] = nil, ["scale"] = 35 },
    --    { ["str"] = "难度配置", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 28 },
    --    { ["str"] = removeWhiteText(ui_text_config["choose_config"]), ["color"] = nil, ["scale"] = 28 },
    --    { ["str"] = " ", ["color"] = nil, ["scale"] = 35 },
    --    { ["str"] = "冲突问题", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 28 },
    --    { ["str"] = removeWhiteText(ui_text_config["conflict"]), ["color"] = nil, ["scale"] = 28 },
    --}, 3)
    sub_root["hh_ui"] = HH_UTILS:CreateMoreParseUi(sub_root, HH_UTILS:GetLanguageTableByKey("mod_help"), 1)
    local sub_ui_x, sub_ui_y = sub_root["hh_ui"]["max_x"], sub_root["hh_ui"]["max_y"] + 30
    sub_ui_x = main_size_x * 0.8
    local sub_w, sub_h = sub_ui_x + 3, main_size_y * 0.8
    father_ui["hh_info_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_root, sub_w, sub_h, sub_ui_y, 55, 3)
    father_ui["hh_info_ui"]:SetPosition(main_size_x / 2 - sub_w - hh_offset * 4, -sub_h / 2, 1)
    father_ui["hh_info_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["up_button"]:SetScale(0.35)
    father_ui["hh_info_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["down_button"]:SetScale(-0.35)
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetScale(0.75)
    father_ui["hh_info_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]:SetScale(0.3)
    HH_UTILS:HookFocusCamera(father_ui["hh_info_ui"])

    father_ui["hh_help_url"] = father_ui:AddChild(TextButton())
    father_ui["hh_help_url"]:SetFont(NUMBERFONT)
    father_ui["hh_help_url"]:SetTextSize(20)
    father_ui["hh_help_url"]:SetText(removeWhiteText(ui_text_config["qq_str"]))
    father_ui["hh_help_url"]:SetPosition(180, 220, 1)
    father_ui["hh_help_url"]:SetTextColour({ 0, 1, 1, 1 })
    father_ui["hh_help_url"]:SetTextFocusColour({ 1, 1, 1, 1 })
    father_ui["hh_help_url"]:SetOnClick(function()
        VisitURL(TUNING["HH_UI_TEXT"]["QQ_HTTP"], false)
    end)
end
----
---创建更新日志ui
---
function HH_HELP:CreateLogUi()
    self:CreateTitle("更新日志")
    local father_ui = self["hh_main"]["main_ui"]
    local log_str_config = _G_HH_UI_TEXT["UPDATE_VISION"]
    local log_list = {}
    for i, v in ipairs(log_str_config) do
        table["insert"](log_list, {
            ["str"] = v["title"], ["color"] = { 1, 1, 0, 1 }, ["scale"] = 25
        })
        table["insert"](log_list, {
            ["str"] = removeWhiteText(v["desc"]), ["color"] = nil, ["scale"] = 25
        })
    end
    --左下为起点0-0-0
    local sub_root = Widget()
    sub_root["hh_ui"] = HH_UTILS:CreateMoreTextUi(sub_root, log_list, 3)
    local sub_ui_x, sub_ui_y = sub_root["hh_ui"]["max_x"], sub_root["hh_ui"]["max_y"]
    sub_ui_x = main_size_x * 0.8
    local sub_w, sub_h = sub_ui_x + 3, 380
    father_ui["hh_info_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_root, sub_w, sub_h, sub_ui_y, 55, 3)
    father_ui["hh_info_ui"]:SetPosition(main_size_x / 2 - sub_w - hh_offset * 4, -sub_h / 2, 1)
    father_ui["hh_info_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["up_button"]:SetScale(0.35)
    father_ui["hh_info_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["down_button"]:SetScale(-0.35)
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetScale(0.75)
    father_ui["hh_info_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]:SetScale(0.3)
    HH_UTILS:HookFocusCamera(father_ui["hh_info_ui"])
end
function HH_HELP:CreateEffectUi()
    self:CreateTitle("词条属性")
    local father_ui = self["hh_main"]["main_ui"]
    local all_effect = GetAllEquipBuff()
    ----------------------------------------------------------------------------------------------
    local sub_root = Widget()
    local start_x, start_y = 0, 0
    local sub_ui_y = 0, 0
    --x轴分两段
    local sub_ui_x_left, sub_ui_x_right = 0, 0
    local image_size = 40
    for i, v in ipairs(all_effect) do
        local child_x, child_y = image_size / 2, start_y - image_size / 2
        local start_left = true
        if i % 2 ~= 0 then
            start_left = false
            child_x = image_size / 2 + main_size_x / 2 - 30
        end
        sub_root["hh_image_" .. i] = HH_UTILS:HHCreateImageUi(sub_root, "images/hh_icon/hh_status.xml", "hh_status.tex", Vector3(0, 0, 1), image_size, image_size, v["color"])
        sub_root["hh_image_" .. i]:SetPosition(child_x, child_y, 1)
        sub_root["hh_image_" .. i]["stone_image"] = HH_UTILS:HHCreateImageUi(sub_root["hh_image_" .. i], "images/hh_icon/hh_items.xml", "hh_effect_stone.tex", Vector3(0, 0, 1), image_size * 0.8, image_size * 0.8)
        sub_root["hh_image_" .. i]["hh_client_text"] = HH_UTILS:HHCreateTextUi(sub_root["hh_image_" .. i], Vector3(0, 0, 1), tostring(v["small_name"]), nil, image_size / 2, true)

        --来源
        local from_str = v["can_add"]
        local can_add_color = { 1, 1, 1, 1 }
        if from_str == effect_rare_str then
            can_add_color = { 1, 0, 0, 1 }
        end
        sub_root["hh_image_" .. i]["hh_str_ui"] = HH_UTILS:CreateMoreTextUi(sub_root["hh_image_" .. i], {
            { ["str"] = v["name"], ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 25 },
            { ["str"] = "描述:" .. v["desc"], ["color"] = nil, ["scale"] = 20 },
            { ["str"] = "唯一性:" .. v["is_one"], ["color"] = nil, ["scale"] = 20 },
            { ["str"] = "来源:" .. v["can_add"], ["color"] = can_add_color, ["scale"] = 20 },
            { ["str"] = "前置条件:" .. v["check_desc"], ["color"] = nil, ["scale"] = 20 },
            { ["str"] = " ", ["color"] = nil, ["scale"] = 20 },
        }, 3)
        local hh_str_ui_x, hh_str_ui_y = sub_root["hh_image_" .. i]["hh_str_ui"]["max_x"], sub_root["hh_image_" .. i]["hh_str_ui"]["max_y"]
        sub_root["hh_image_" .. i]["hh_str_ui"]:SetPosition(image_size / 2 + 2, image_size / 2, 1)
        if start_left then
            sub_ui_x_left = math["max"](image_size + hh_str_ui_x + 2, sub_ui_x_left)
            start_y = start_y - math["max"](hh_str_ui_y, image_size)
            sub_ui_y = sub_ui_y + math["max"](hh_str_ui_y, image_size)
        else
            sub_ui_x_right = math["max"](image_size + hh_str_ui_x + 2, sub_ui_x_right)
        end
    end
    local sub_w, sub_h = sub_ui_x_left + sub_ui_x_right + 70, 380
    father_ui["hh_info_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_root, sub_w, sub_h, sub_ui_y, 65, 3)
    father_ui["hh_info_ui"]:SetPosition(-main_size_x / 2 + hh_offset + 40, -sub_h / 2, 1)
    father_ui["hh_info_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["up_button"]:SetScale(0.35)
    father_ui["hh_info_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["down_button"]:SetScale(-0.35)
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetScale(0.75)
    father_ui["hh_info_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]:SetScale(0.3)
    ---------------------------------------------------------------------------------------
    HH_UTILS:HookFocusCamera(father_ui["hh_info_ui"])
    --local all_suit = GetAllSuitBuff(self["owner"])
    --local sub_suit_root = Widget()
    --sub_suit_root["hh_ui"] = HH_UTILS:CreateMoreTextUi(sub_suit_root, all_suit, 3)
    --local sub_suit_ui_x, sub_suit_ui_y = sub_suit_root["hh_ui"]["max_x"], sub_suit_root["hh_ui"]["max_y"]
    --local sub_suit_w, sub_suit_h = sub_suit_ui_x + 3, 380
    --father_ui["hh_suit_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_suit_root, sub_suit_w, sub_suit_h, sub_suit_ui_y, 25, 3)
    --father_ui["hh_suit_ui"]:SetPosition(main_size_x / 2 - sub_suit_w - hh_offset * 3, -sub_suit_h / 2, 1)
    --father_ui["hh_suit_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    --father_ui["hh_suit_ui"]["up_button"]:SetScale(0.35)
    --father_ui["hh_suit_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    --father_ui["hh_suit_ui"]["down_button"]:SetScale(-0.35)
    --father_ui["hh_suit_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    --father_ui["hh_suit_ui"]["scroll_bar_line"]:SetScale(0.75)
    --father_ui["hh_suit_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    --father_ui["hh_suit_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    --father_ui["hh_suit_ui"]["position_marker"]:SetScale(0.3)
end
----
---宝石道具属性
---
function HH_HELP:CreateGemUi()
    self:CreateTitle("宝石/道具")
    local father_ui = self["hh_main"]["main_ui"]
    local log_str = _G_HH_UI_TEXT["UI_ITEMS"]
    --左下为起点0-0-0
    local sub_root = Widget()
    sub_root["hh_ui"] = HH_UTILS:CreateMoreTextUi(sub_root, {
        { ["str"] = log_str, ["color"] = nil, ["scale"] = 28 },
    }, 3)
    local sub_ui_x, sub_ui_y = sub_root["hh_ui"]["max_x"], sub_root["hh_ui"]["max_y"]
    local sub_w, sub_h = sub_ui_x + 3, 380
    father_ui["hh_info_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_root, sub_w, sub_h, sub_ui_y, 55, 3)
    father_ui["hh_info_ui"]:SetPosition(main_size_x / 2 - sub_w - hh_offset * 3, -sub_h / 2, 1)
    father_ui["hh_info_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["up_button"]:SetScale(0.35)
    father_ui["hh_info_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_info_ui"]["down_button"]:SetScale(-0.35)
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    father_ui["hh_info_ui"]["scroll_bar_line"]:SetScale(0.75)
    father_ui["hh_info_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_info_ui"]["position_marker"]:SetScale(0.3)
    HH_UTILS:HookFocusCamera(father_ui["hh_info_ui"])
    --------------------------------------------------------------------------------------------
    local sub_suit_root = Widget()
    sub_suit_root["hh_ui"] = HH_UTILS:CreateMoreTextUi(sub_suit_root, {
        { ["str"] = "概率表", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 30 },
        { ["str"] = _G_HH_UI_TEXT["CHANCE_TEXT"], ["color"] = nil, ["scale"] = 20 },
    }, 3)
    local sub_suit_ui_x, sub_suit_ui_y = sub_suit_root["hh_ui"]["max_x"], sub_suit_root["hh_ui"]["max_y"]
    local sub_suit_w, sub_suit_h = sub_suit_ui_x + 3, 200
    father_ui["hh_suit_ui"] = HH_UTILS:CreateTrueScrollArea(father_ui, sub_suit_root, sub_suit_w, sub_suit_h, sub_suit_ui_y, 25, 3)
    father_ui["hh_suit_ui"]:SetPosition(-main_size_x / 2 + hh_offset * 3, main_size_y / 2 - sub_suit_h - hh_offset * 2, 1)
    father_ui["hh_suit_ui"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_suit_ui"]["up_button"]:SetScale(0.15)
    father_ui["hh_suit_ui"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    father_ui["hh_suit_ui"]["down_button"]:SetScale(-0.15)
    father_ui["hh_suit_ui"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    father_ui["hh_suit_ui"]["scroll_bar_line"]:SetScale(0.3)
    father_ui["hh_suit_ui"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_suit_ui"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    father_ui["hh_suit_ui"]["position_marker"]:SetScale(0.3)

end

local function log_child_fn(father_ui, hh_ui_index)
    if not father_ui then
        return
    end
    local log_list = playerLogList
    if HH_UTILS:IsHHType(log_list[hh_ui_index], "table") then
        local logConfig = log_list[hh_ui_index]
        if HH_UTILS:IsHHType(logConfig["ui_config"], "string") then
            father_ui["log_ui"] = HH_UTILS:CreateByCustomText(father_ui, logConfig["ui_config"], 1)
            father_ui["log_ui"]:SetPosition(-350, 10, 1)
        end
    end
end
local function createLogScrollUiConfig()
    local ui_table_config = {}
    local log_list = playerLogList
    local log_length = #log_list
    for i = 1, log_length do
        table["insert"](ui_table_config, { ["spawn_ui_fn"] = log_child_fn, })
    end
    local base_scroll_config = {
        --主背景
        ["main_xml"] = "images/global.xml",
        ["main_tex"] = "square.tex",
        --关闭按钮 必须有才会创建
        --["close_xml"] = "images/hh_ovo_image/hh_ovo_ui_close.xml",
        --["close_tex"] = "hh_ovo_ui_close.tex",
        --按钮大小
        --["close_scale"] = 0.5,
        --关闭按钮偏移(x,y一样)
        --["close_offset_pos"] = -20,
        --ui的长宽
        ["main_size"] = { ["weight"] = main_size_x * 0.9, ["height"] = main_size_y * 0.85, },
        --背景颜色
        ["main_color"] = { 0, 0, 0, 0 },
        --每一页展示的ui数量
        ["num_slot"] = 14,
        --隐藏上下箭头
        ["hide_arrow_btn"] = true,
        --显示索引文字
        ["show_index"] = false,
        --滚动条相关配置
        ["schedule_data"] = {
            ["bar_xml"] = "images/quagmire_recipebook.xml",
            ["bar_tex"] = "quagmire_recipe_scroll_handle.tex",
            ["bar_size_x"] = 15,
            ["bar_size_y"] = 30,
            ["bar_color"] = { 255 / 255, 242 / 255, 121 / 255, 1 },
        },
        --ui配置
        ["ui_table"] = ui_table_config,
    }
    return base_scroll_config
end
local function addTabButton(father, ui_id, str, hh_pos, click_fn)
    if not father then
        return
    end
    if father[ui_id] then
        HH_UTILS:HHKillChild(father, ui_id)
    end
    father[ui_id] = father:AddChild(ImageButton(white_xml, white_tex))
    father[ui_id]:SetPosition(hh_pos)
    father[ui_id]["clickoffset"] = Vector3(0, 0, 0)
    local scale_x, scale_y = 7, 3
    father[ui_id]["image"]:SetScale(scale_x, scale_y, 1)
    father[ui_id]["image"]:SetTint(0, 0, 0, 0.5)
    father[ui_id]["OnGainFocus"] = function()
        --father[ui_id]["image"]:SetScale(scale_x * 1.1, scale_y * 1.1, 1)
    end
    father[ui_id]["OnLoseFocus"] = function()
        --father[ui_id]["image"]:SetScale(scale_x, scale_y, 1)
    end
    father[ui_id]["hh_str"] = HH_UTILS:HHCreateTextUi(father[ui_id], Vector3(0, 0, 1), tostring(str), { 1, 1, 1, 1 }, 20)
    if HH_UTILS:IsHHType(click_fn, "function") then
        father[ui_id]:SetOnClick(click_fn)
    end
end
local log_tab = {
    { ["str"] = getLogLanguage("type_all"), ["log_type"] = "", },
    { ["str"] = getLogLanguage("type_stone"), ["log_type"] = "stone", },
    { ["str"] = getLogLanguage("type_treasure"), ["log_type"] = "treasure", },
    { ["str"] = getLogLanguage("type_egg"), ["log_type"] = "egg", },
}
----
---世界日志
---
function HH_HELP:CreateWorldLogUi()
    self:CreateTitle("世界日志")
    local father_ui = self["hh_main"]["main_ui"]
    local player = self["owner"]
    local log_str = HH_UTILS:GetClientValue(player, "hh_world_logs")
    if not HH_UTILS:IsHHType(log_str, "string") then
        return
    end
    --print("日志字节", #log_str)
    playerLogList = HH_UTILS:StrToTable(log_str)
    father_ui["log_ui"] = father_ui:AddChild(SCROLL_UI(createLogScrollUiConfig(self["owner"])))
    HH_UTILS:HookFocusCamera(father_ui["log_ui"])

    father_ui["ps_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, 0, 1), getLanguage("log_ps"), { 1, 0, 0, 1 }, 20)
    local ps_text_size_x, ps_text_size_y = father_ui["ps_text"]:GetRegionSize()
    father_ui["ps_text"]:SetPosition(-main_size_x / 2 + ps_text_size_x / 2 + hh_offset * 3, -main_size_y / 2 + ps_text_size_y / 2 + hh_offset, 1)
    --页签
    local btn_start_x, btn_start_y = -main_size_x / 2 + hh_offset * 3, main_size_y / 2 - 28
    for i, v in ipairs(log_tab) do
        if v and v["str"] then
            local ui_name = "hh_tab_" .. i
            local rpc_log_type = tostring(v["log_type"])
            addTabButton(father_ui, ui_name, tostring(v["str"]), Vector3(0, 0, 1), function()
                sendLogRpc(rpc_log_type)
            end)
            local text_size_x, text_size_y = 40, 20
            father_ui[ui_name]:SetPosition(btn_start_x + text_size_x / 2, btn_start_y, 1)
            btn_start_x = btn_start_x + text_size_x + 15
        end
    end
end
function HH_HELP:UpdateWorldLogUi()
    if self["current_tab"] ~= "log" then
        return
    end
    --直接重新构建ui
    self:CreateWorldLogUi()
end
function HH_HELP:CreateTitle(title_str)
    HH_UTILS:HHKillChild(self["hh_main"], "main_ui")
    self["hh_main"]["main_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["main_ui"]
    father_ui["back_image"] = HH_UTILS:HHCreateImageUi(father_ui, main_xml, main_tex, Vector3(0, 0, 1), main_size_x * 0.9, main_size_y * 0.85, { 0, 0, 0, 0.6 })
    father_ui["hh_title"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, 0, 1), title_str, nil, 30)
    local hh_title_size_x, hh_title_size_y = father_ui["hh_title"]:GetRegionSize()
    father_ui["hh_title"]:SetPosition(0, main_size_y / 2 - hh_title_size_y / 2 - hh_offset + 5, 1)
end
return HH_HELP
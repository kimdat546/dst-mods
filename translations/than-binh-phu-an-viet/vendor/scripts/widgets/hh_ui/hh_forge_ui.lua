local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local TrueScrollArea = require("widgets/truescrollarea")
local HH_UTILS = require("utils/hh_utils")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local HH_SUIT_RECIPE_LIST = HH_CONFIG["HH_SUIT_RECIPE"]
local HH_SUIT_LIST_CONFIG = HH_CONFIG["HH_SUIT_LIST"]
local background_xml, background_tex = "images/scrapbook.xml", "scrap2_wide.tex"
local white_xml, white_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local hh_main_size_x, hh_main_size_y = 600, 400
local hh_tab_config = {
    --{
    --    ["name"] = "套装合成",
    --    ["click_fn"] = function(self)
    --        --print("合成套装")
    --        if self["owner"] then
    --            --推送事件 更新格子坐标
    --            HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "suit_pos")
    --        end
    --        self:CreateSuitConfigUi()
    --    end,
    --},
    {
        ["name"] = "抽奖",
        ["click_fn"] = function(self)
            if self["owner"] then
                --推送事件 更新格子坐标
                HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "stone_change")
            end
            self:CreateReplaceStoneUi()
            self["current_tab"] = "stone_change"
        end,
    },
    {
        ["name"] = "继承",
        ["click_fn"] = function(self)
            if self["owner"] then
                --推送事件 更新格子坐标
                HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "equip_inherit")
            end
            self:CreateEquipInheritUi()
            self["current_tab"] = "equip_inherit"
        end,
    },
    {
        ["name"] = "强化",
        ["click_fn"] = function(self)
            if self["owner"] then
                --推送事件 更新格子坐标
                HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "equip_upgrading")
            end
            self:CreateEquipUpgradingUi()
            self["current_tab"] = "equip_upgrading"
        end,
    },
    --{
    --    ["name"] = "三合一",
    --    ["click_fn"] = function(self)
    --        if self["owner"] then
    --            --推送事件 更新格子坐标
    --            HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "effect_compose")
    --        end
    --        self:CreateEffectComposeUi()
    --    end,
    --},
    --{
    --    ["name"] = "333",
    --    ["click_fn"] = function(self)
    --        if self["owner"] then
    --            --推送事件 更新格子坐标
    --            HH_UTILS:SetClientValue(self["owner"], "hh_forge_slot_change", "test_03")
    --        end
    --    end,
    --},

}
local function hookFocusFn(hh_ui, focus_str)
    local oldOnGainFocusBack = hh_ui["OnGainFocus"]
    hh_ui["OnGainFocus"] = function()
        if oldOnGainFocusBack then
            oldOnGainFocusBack()
        end
        hh_ui["hh_desc"] = HH_UTILS:HHCreateTextUi(hh_ui, Vector3(0, 0, 1), tostring(focus_str), { 1, 1, 1, 1 }, 30)
        hh_ui["hh_desc"]:MoveTo(Vector3(0, -20, 1), Vector3(0, -40, 1), 0.5)
    end
    local oldOnLoseFocus = hh_ui["OnLoseFocus"]
    hh_ui["OnLoseFocus"] = function()
        if oldOnLoseFocus then
            oldOnLoseFocus()
        end
        HH_UTILS:HHKillChild(hh_ui, "hh_desc")
    end
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
----
---获取所有的套装词条
---
local function getSuitEffect(player)
    --权限表
    local limit_suit_list = HH_UTILS:GetClientValue(player, "hh_suit_list")
    if not HH_UTILS:IsHHType(limit_suit_list, "table") then
        limit_suit_list = {}
    end
    --获取配方表
    local hh_table = HH_UTILS:HHCopyTable(HH_SUIT_RECIPE_LIST)
    local new_table = {}
    for i, v in ipairs(hh_table) do
        if v and v["id"] and HH_EQUIP_BUFF_LIST[v["id"]]
                and HH_EQUIP_BUFF_LIST[v["id"]]["suit_str"]
                and HH_UTILS:IsHHType(v["recipe"], "table")
        then
            local effect_id = v["id"]
            local effect_config = HH_EQUIP_BUFF_LIST[effect_id]
            local suit_id = effect_config["suit_str"]
            if HH_SUIT_LIST_CONFIG[suit_id] then
                local has_limit = true
                if HH_SUIT_LIST_CONFIG[suit_id]["is_person"] and not limit_suit_list[suit_id] then
                    -- 定制套装不展示
                    has_limit = false
                end
                if has_limit then
                    table["insert"](new_table, {
                        ["id"] = effect_id,
                        ["name"] = effect_config["name"],
                        ["small_name"] = effect_config["client_text"],
                        ["recipe"] = v["recipe"],
                    })
                end
            end
        end
    end
    --HH_UTILS:HHPrint(new_table)
    return new_table
end
local HH_UI = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_forge_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["choose_index"] = {
        false,
        false,
        false,
        false,
    }
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self["root"], "images/plantregistry.xml", "backdrop.tex", Vector3(0, 0, 1), hh_main_size_x, hh_main_size_y)

    --self["hh_main"] = HH_UTILS:CreateFrameUiTwo(self["root"], Vector3(0, 0, 1),
    --        { ["size_x"] = hh_main_size_x, ["size_y"] = hh_main_size_y, ["color"] = { 41 / 255, 30 / 255, 21 / 255, 1 }, })
    self["hh_main"]["hh_close"] = HH_UTILS:HHCreateImageButton(self["hh_main"], "images/crafting_menu.xml", "pinslot_unpin_button.tex",
            Vector3(hh_main_size_x / 2 - 10, hh_main_size_y / 2 - 10, 1), 0.5, 0.5)
    self["hh_main"]["hh_close"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"], "forge_container")
    end)
    local line_offset = 7
    local line_size = 5
    --创建分界线
    --self["hh_main"]["hh_line_x"] = HH_UTILS:HHCreateImageUi(self["hh_main"], white_xml, white_tex, Vector3(-hh_main_size_x / 4 + line_offset, hh_main_size_y / 6, 1), hh_main_size_x / 2, line_size, { 0, 0, 0, 1 })
    --self["hh_main"]["hh_line_y"] = HH_UTILS:HHCreateImageUi(self["hh_main"], white_xml, white_tex, Vector3(line_offset, hh_main_size_y / 3 - line_offset / 2 - line_size / 2, 1), line_size, hh_main_size_y / 3 - line_offset, { 0, 0, 0, 1 })
    --清除词条ui
    self:UpdateEquipEffectUi()
    self:CreateTabUi(1)
    --全部套装词条配置
    self["inst"]:ListenForEvent("hh_forge_equip", function(inst, data)
        self:UpdateEquipEffectUi()
    end, self["owner"])

    self["inst"]:ListenForEvent("forge_star_equip_info", function(inst, data)
        if HH_UTILS:HasComponents(self["owner"], "hh_client")
                and self["current_tab"] == "equip_upgrading"
        then
            local equip_table = HH_UTILS:GetClientValue(self["owner"], "forge_star_equip_info")
            self:CreateOrUpdateEquipInfoUi(HH_UTILS:StrToTable(equip_table))
            --print("==========客户端================")
            --HH_UTILS:HHPrint(HH_UTILS:StrToTable(equip_table))
            --print("==========客户端================")
        end
    end, self["owner"])
    --self["inst"]:ListenForEvent("hh_forge_stone", function(inst, data)
    --    if self["btn_index"] == 1 then
    --        self:CreateSuitStone()
    --    end
    --end, self["owner"])
end)
----
---重置选项
---
function HH_UI:ResetChooseIndex()
    self["choose_index"] = {
        false,
        false,
        false,
        false,
    }
end
----
---创建词条显示ui
---
function HH_UI:UpdateEquipEffectUi()
    self:ResetChooseIndex()
    HH_UTILS:HHKillChild(self["hh_main"], "hh_equip_ui")
    HH_UTILS:HHKillChild(self["hh_main"], "hh_com_equip_ui")
    if not HH_UTILS:HasComponents(self["owner"], "hh_client") then
        return
    end
    local equip_table = HH_UTILS:GetClientValue(self["owner"], "hh_forge_equip")
    if not HH_UTILS:IsHHType(equip_table, "table") or #equip_table <= 0 then
        --增加帮助ui
        self["hh_main"]["hh_com_equip_ui"] = HH_UTILS:CreateMoreTextUi(self["hh_main"], {
            { ["str"] = "<定向清除>", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 20 },
            { ["str"] = "可以自由选择清除指定位置的词条", ["scale"] = 20 },
            { ["str"] = "消耗:净化符(宝石页面查看)", ["scale"] = 20 },
            { ["str"] = "消耗数量等同于选择的词条数量", ["scale"] = 20 },
        }, 3)
        local com_size_x, com_size_y = self["hh_main"]["hh_com_equip_ui"]["max_x"], self["hh_main"]["hh_com_equip_ui"]["max_y"]
        self["hh_main"]["hh_com_equip_ui"]:SetPosition(-hh_main_size_x / 2 + 90, hh_main_size_y / 2 - 20, 1)
        return
    end
    self["hh_main"]["hh_equip_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["hh_equip_ui"]
    local start_x, start_y = -170, 185
    local text_scale = 30
    father_ui["hh_reduce_button"] = HH_UTILS:HHCreateBtnUi(father_ui, "images/ui.xml", "button_large.tex", Vector3(-250, 100, 1), 0.3, 0.3)
    father_ui["hh_reduce_button"]:SetOnClick(function()
        self:CreateSureRefuseUi()
    end)
    father_ui["hh_reduce_button"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_reduce_button"], Vector3(0, 2, 1), "清除", nil, 25)
    for i, v in ipairs(equip_table) do
        if HH_UTILS:IsHHType(v, "table") and v["name"] and HH_UTILS:IsHHType(HH_EQUIP_BUFF_LIST[v["name"]], "table") then
            --"images/ui.xml", "in-window_button_tile_idle.tex",选择框
            local effect_config = HH_EQUIP_BUFF_LIST[v["name"]]
            local effect_name = effect_config["name"] or "未定义"
            father_ui["hh_text_" .. i] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(0, 0, 1), tostring(effect_name), nil, text_scale)
            local child_text_size_x, child_text_size_y = father_ui["hh_text_" .. i]:GetRegionSize()
            father_ui["hh_text_" .. i]:SetPosition(start_x + child_text_size_x / 2, start_y - child_text_size_y / 2, 1)
            local button_x, button_y = start_x - 15, start_y - child_text_size_y / 2, 1
            father_ui["hh_sure_button_" .. i] = HH_UTILS:HHCreateImageButton(father_ui, "images/ui.xml", "in-window_button_tile_idle.tex", Vector3(button_x, button_y, 1), 0.1, 0.1)
            father_ui["hh_sure_button_" .. i]:SetOnClick(function()
                --print("选中", i)
                self["choose_index"][i] = true
                HH_UTILS:HHKillChild(father_ui, "hh_is_ok_" .. i)
                father_ui["hh_is_ok_" .. i] = HH_UTILS:HHCreateImageButton(father_ui, "images/ui.xml", "checkmark.tex", Vector3(button_x, button_y, 1), 0.1, 0.1)
                father_ui["hh_is_ok_" .. i]:SetOnClick(function()
                    HH_UTILS:HHKillChild(father_ui, "hh_is_ok_" .. i)
                    --print("撤回", i)
                    self["choose_index"][i] = false
                end)
            end)
            start_y = start_y - child_text_size_y
        end
    end
end
----
---创建确认清除页面
---
function HH_UI:CreateSureRefuseUi()
    if not self["hh_main"] or not self["hh_main"]["hh_equip_ui"] then
        return
    end
    local father_ui = self["hh_main"]["hh_equip_ui"]
    HH_UTILS:HHKillChild(father_ui, "sure_refuse_ui")
    if not HH_UTILS:IsHHType(self["choose_index"], "table") then
        return
    end
    local change_num = 0
    for i, v in ipairs(self["choose_index"]) do
        if v == true then
            change_num = change_num + 1
        end
    end
    local ui_size_x, ui_size_y = 200, 130
    local offset = 10

    --father_ui["sure_refuse_ui"] = HH_UTILS:HHCreateImageUi(father_ui, background_xml, background_tex, Vector3(-100, 120, 1), ui_size_x, ui_size_y)

    father_ui["sure_refuse_ui"] = HH_UTILS:CreateFrameUi(father_ui, Vector3(-100, 120, 1),
            { ["size_x"] = ui_size_x, ["size_y"] = ui_size_y, ["color"] = { 109 / 255, 101 / 255, 88 / 255, 1 }, },
            { ["size"] = 2.5, ["color"] = { 0, 0, 0, 1 }, })
    local ui_str = ""
    if change_num <= 0 then
        ui_str = "未选择清除词条"
    else
        ui_str = string["format"]("消耗%s个净化符\n清除选中的词条", change_num)
    end
    father_ui["sure_refuse_ui"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["sure_refuse_ui"], Vector3(0, 0, 1), ui_str, nil, 25)
    local child_text_size_x, child_text_size_y = father_ui["sure_refuse_ui"]["hh_str"]:GetRegionSize()
    father_ui["sure_refuse_ui"]["hh_str"]:SetPosition(0, ui_size_y / 2 - child_text_size_y / 2 - offset, 1)
    --确认
    father_ui["sure_refuse_ui"]["hh_sure"] = HH_UTILS:HHCreateBtnUi(father_ui["sure_refuse_ui"], "images/ui.xml", "button_large.tex", Vector3(-50, -40, 1), 0.3, 0.3)
    father_ui["sure_refuse_ui"]["hh_sure"]:SetOnClick(function()
        HH_UTILS:HHKillChild(father_ui, "sure_refuse_ui")
        if change_num > 0 then
            SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "CleanEffect", HH_UTILS:TableToStr(self["choose_index"]))
        end
    end)
    father_ui["sure_refuse_ui"]["hh_sure"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["sure_refuse_ui"]["hh_sure"], Vector3(0, 2, 1), "确认", nil, 25)
    --取消
    father_ui["sure_refuse_ui"]["hh_refuse"] = HH_UTILS:HHCreateBtnUi(father_ui["sure_refuse_ui"], "images/ui.xml", "button_large.tex", Vector3(50, -40, 1), 0.3, 0.3)
    father_ui["sure_refuse_ui"]["hh_refuse"]:SetOnClick(function()
        HH_UTILS:HHKillChild(father_ui, "sure_refuse_ui")
    end)
    father_ui["sure_refuse_ui"]["hh_refuse"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["sure_refuse_ui"]["hh_refuse"], Vector3(0, 2, 1), "取消", nil, 25)
end
----
---创建切换ui-处理2-5格的效果
---
function HH_UI:CreateTabUi(hh_index)
    HH_UTILS:HHKillChild(self["hh_main"], "hh_tab_ui")
    self["hh_main"]["hh_tab_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["hh_tab_ui"]
    local btn_start_x, btn_start_y = -hh_main_size_x / 2 + 20, hh_main_size_y / 6 - 30
    for i, v in ipairs(hh_tab_config) do
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
            local text_size_x, text_size_y = 40, 20
            father_ui[ui_name]:SetPosition(btn_start_x + text_size_x / 2, btn_start_y, 1)
            btn_start_x = btn_start_x + text_size_x + 15
        end
    end
end

function HH_UI:CreateSuitConfigUi()
    HH_UTILS:HHKillChild(self["hh_main"], "suit_config_ui")
    local suit_config = getSuitEffect(self["owner"])
    local sub_root = Widget()
    local start_x, start_y = 0, 0
    local sub_w, sub_h = hh_main_size_x / 2 - 60, hh_main_size_y - 60
    local image_size = 40
    for i, v in ipairs(suit_config) do
        if v and v["id"] and HH_UTILS:IsHHType(v["recipe"], "table") then
            local effect_name = v["name"] or "未定义"
            local effect_small_name = v["small_name"] or "未定义"
            local effect_id = v["id"]
            local effect_recipe = v["recipe"] or {}
            sub_root["hh_image_" .. i] = HH_UTILS:HHCreateImageUi(sub_root, "images/hh_icon/hh_status.xml", "hh_status.tex", Vector3(0, 0, 1), image_size, image_size, { 0, 0, 0, 0.5 })
            sub_root["hh_image_" .. i]["stone_image"] = HH_UTILS:HHCreateImageUi(sub_root["hh_image_" .. i], "images/hh_icon/hh_items.xml", "hh_effect_stone.tex", Vector3(0, 0, 1), image_size * 0.9, image_size * 0.9)
            sub_root["hh_image_" .. i]["hh_client_text"] = HH_UTILS:HHCreateTextUi(sub_root["hh_image_" .. i], Vector3(0, 0, 1), tostring(effect_small_name), nil, image_size / 2, true)
            sub_root["hh_image_" .. i]:SetPosition(start_x + image_size / 2, start_y - image_size / 2, 1)
            start_y = start_y - image_size - 10
            if HH_UTILS:IsHHType(effect_recipe, "table") then
                local father_image = sub_root["hh_image_" .. i]
                for kk, vv in ipairs(effect_recipe) do
                    if vv and vv["xml"] and vv["tex"] then
                        local item_id = vv["id"]
                        local item_name = vv["name"] or STRINGS["NAMES"][string["upper"](item_id)] or "未定义"
                        local item_size = image_size
                        local item_pos_x = image_size / 2 + (kk - 1 / 2) * item_size + 3
                        father_image["hh_image_" .. kk] = HH_UTILS:HHCreateImageUi(father_image, vv["xml"], vv["tex"], Vector3(item_pos_x, 0, 1), item_size, item_size)
                        hookFocusFn(father_image["hh_image_" .. kk], tostring(item_name))
                        if vv["num"] then
                            local hh_text_ui = HH_UTILS:HHCreateTextUi(father_image["hh_image_" .. kk], Vector3(0, 0, 1), tostring(vv["num"]), nil, item_size / 2, true)
                            local hh_text_ui_size_x, hh_text_ui_size_y = hh_text_ui:GetRegionSize()
                            father_image["hh_image_" .. kk]["hh_text"] = hh_text_ui
                            father_image["hh_image_" .. kk]["hh_text"]:SetPosition(item_size / 2 - hh_text_ui_size_x / 2, -hh_text_ui_size_y / 2, 1)
                        end
                    end
                end
            end
        end
    end
    --裁切ui和整个滚动条的偏移 ui初始位置左下
    local scissor_data = {
        ["x"] = 0,
        ["y"] = 0,
        ["width"] = sub_w,
        ["height"] = sub_h
    }
    local context = {
        --挂载ui
        ["widget"] = sub_root,
        --坐标偏移
        ["offset"] = {
            ["x"] = 0,
            ["y"] = sub_h,
        },
        ["size"] = {
            --未找到用处
            ["w"] = 0,
            --总ui大小
            ["height"] = math["abs"](start_y),
        }
    }
    local scrollbar = { ["scroll_per_click"] = 5 * 3 }
    self["hh_main"]["suit_config_ui"] = self["hh_main"]:AddChild(TrueScrollArea(context, scissor_data, scrollbar))
    self["hh_main"]["suit_config_ui"]:SetPosition(20, hh_main_size_y / 2 - sub_h - 30, 1)
    --增加标题
    self["hh_main"]["suit_config_ui"]["hh_title"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["suit_config_ui"], Vector3(sub_w / 2, sub_h + 10, 1), "词条配方", nil, 20)

    local hh_sub = self["hh_main"]["suit_config_ui"]
    hh_sub["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    hh_sub["up_button"]:SetScale(0.35)
    hh_sub["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    hh_sub["down_button"]:SetScale(-0.35)
    hh_sub["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    hh_sub["scroll_bar_line"]:SetScale(0.25)
    hh_sub["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    hh_sub["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    hh_sub["position_marker"]:SetScale(0.3)
    --显示可合成的套装
    self:CreateSuitStone()
end
----
---装备继承ui
function HH_UI:CreateEquipInheritUi()
    HH_UTILS:HHKillChild(self["hh_main"], "suit_config_ui")
    self["hh_main"]["suit_config_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["suit_config_ui"]
    father_ui["hh_old_equip_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-220, -45, 1), "原装备", nil, 20)
    father_ui["hh_new_equip_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-100, -45, 1), "装备(无词条)", nil, 20)
    father_ui["hh_test_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-165, -10, 1), "===>", nil, 20)
    father_ui["hh_btn_sure"] = HH_UTILS:HHCreateBtnUi(father_ui, "images/ui.xml", "button_large.tex", Vector3(-165, -140, 1), 0.3, 0.3)
    father_ui["hh_btn_sure"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "EquipInherit")
    end)
    father_ui["hh_btn_sure"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_sure"], Vector3(0, 0, 1), "继承", nil, 20)
    father_ui["hh_need_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-80, -140, 1), "消耗:", nil, 20)
    local item_size = 40
    father_ui["hh_cl_a"] = HH_UTILS:HHCreateImageUi(father_ui, "images/hh_icon/hh_items.xml", "hh_essence.tex", Vector3(-45, -140, 1), item_size, item_size)
    hookFocusFn(father_ui["hh_cl_a"], "水晶小人")
    father_ui["hh_cl_a"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_cl_a"], Vector3(item_size / 4, -item_size / 4, 1), 20, nil, 20)
    father_ui["hh_cl_b"] = HH_UTILS:HHCreateImageUi(father_ui, "images/inventoryimages.xml", "nightmarefuel.tex", Vector3(-5, -140, 1), item_size, item_size)
    hookFocusFn(father_ui["hh_cl_b"], "噩梦燃料")
    father_ui["hh_cl_b"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_cl_b"], Vector3(item_size / 4, -item_size / 4, 1), 20, nil, 20)
    father_ui["hh_help"] = HH_UTILS:CreateMoreTextUi(father_ui, {
        { ["str"] = "<装备继承>", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = "将一件装备上的词条转移给另一个装备上", ["scale"] = 20 },
        { ["str"] = "下方格子放消耗材料", ["scale"] = 20 },
        { ["str"] = "继承成功后 原装备会消失", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = "装备a的某些词条 装备b不满足词条的前置条件", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = "该词条不会被继承", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = "装备a必须存在词条，装备b必须是无词条状态", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, ["scale"] = 20 },
    }, 3)
    father_ui["hh_help"]:SetPosition(30, 30, 1)
end
function HH_UI:CreateEffectComposeUi()
    HH_UTILS:HHKillChild(self["hh_main"], "suit_config_ui")
    self["hh_main"]["suit_config_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["suit_config_ui"]
    father_ui["hh_btn_sure"] = HH_UTILS:HHCreateBtnUi(father_ui, "images/ui.xml", "button_large.tex", Vector3(-150, -130, 1), 0.3, 0.3)
    father_ui["hh_btn_sure"]:SetOnClick(function()
        --SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "EffectCompose")
    end)
    father_ui["hh_btn_sure"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_sure"], Vector3(0, 0, 1), "合成", nil, 20)
    father_ui["hh_help"] = HH_UTILS:CreateMoreTextUi(father_ui, {
        { ["str"] = "<词条三合一>", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = "将三个附魔石合成", ["scale"] = 20 },
        { ["str"] = "百分之一概率合成出极品附魔石", ["scale"] = 20 },
    }, 3)
    father_ui["hh_help"]:SetPosition(-100, -50, 1)
end
function HH_UI:CreateReplaceStoneUi()
    HH_UTILS:HHKillChild(self["hh_main"], "suit_config_ui")
    self["hh_main"]["suit_config_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["suit_config_ui"]
    father_ui["hh_btn_sure"] = HH_UTILS:HHCreateBtnUi(father_ui, "images/ui.xml", "button_large.tex", Vector3(-150, -165, 1), 0.3, 0.3)
    father_ui["hh_btn_sure"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "ReplaceStone")
    end)
    father_ui["hh_btn_sure"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_sure"], Vector3(0, 0, 1), "转换", nil, 20)
    father_ui["hh_help"] = HH_UTILS:CreateMoreTextUi(father_ui, {
        { ["str"] = "<附魔石转换>", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 20 },
        { ["str"] = string["format"]("材料:附魔石+水晶小人*%s", 5), ["scale"] = 20 },
        { ["str"] = string["format"]("可以将附魔石随机一次属性,%s%%概率产生稀有词条", 5), ["scale"] = 20 },
        { ["str"] = string["format"]("%s%%概率产生超级稀有词条", 1), ["scale"] = 30, ["color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, },
    }, 3)
    father_ui["hh_help"]:SetPosition(-100, 35, 1)
end
function HH_UI:CreateSuitStone()
    if self["btn_index"] ~= 1 or not self["hh_main"] or not self["hh_main"]["suit_config_ui"] then
        return
    end
    local father_ui = self["hh_main"]["suit_config_ui"]
    local client_container_list = HH_UTILS:GetClientValue(self["owner"], "hh_forge_stone")
    if not HH_UTILS:IsHHType(client_container_list, "table") or next(client_container_list) == nil then
        HH_UTILS:HHKillChild(father_ui, "suit_recipe_ui")
        return
    end
    --套装词条表
    local suit_config = getSuitEffect(self["owner"])
    HH_UTILS:HHKillChild(father_ui, "suit_recipe_ui")

    --登记可以合成的套装
    local can_get_effect = {}

    for i, v in pairs(client_container_list) do
        if HH_UTILS:IsHHType(v, "string") then
            for sk, sv in ipairs(suit_config) do
                if sv and HH_UTILS:IsHHType(sv["recipe"], "table")
                        and sv["id"]
                then
                    if can_get_effect[sv["id"]] == nil or can_get_effect[sv["id"]] == true then
                        can_get_effect[sv["id"]] = true
                        local is_sure_effect = false
                        for recipe_k, recipe_v in ipairs(sv["recipe"]) do
                            if HH_UTILS:IsHHType(recipe_v, "table") then
                                if recipe_v["id"] == v then
                                    is_sure_effect = true
                                end
                            end
                        end
                        can_get_effect[sv["id"]] = is_sure_effect
                    end
                end
            end
        end
    end
    --HH_UTILS:HHPrint(can_get_effect)
    if next(can_get_effect) == nil then
        return
    end
    --登记id+配方
    local sub_root = Widget()
    local sub_w, sub_h = 150, 180
    local start_x, start_y = 0, 0
    local image_size = 40
    for i, v in pairs(can_get_effect) do
        if v and HH_EQUIP_BUFF_LIST[i] then
            local effect_id = i
            local effect_config = HH_EQUIP_BUFF_LIST[i]
            local effect_name = effect_config["name"] or "读取失败"
            local effect_small_name = effect_config["client_text"] or "空"
            sub_root["hh_image_" .. i] = HH_UTILS:HHCreateImageUi(sub_root, "images/hh_icon/hh_status.xml", "hh_status.tex", Vector3(0, 0, 1), image_size, image_size, { 0, 0, 0, 0.5 })
            sub_root["hh_image_" .. i]["stone_image"] = HH_UTILS:HHCreateImageUi(sub_root["hh_image_" .. i], "images/hh_icon/hh_items.xml", "hh_effect_stone.tex", Vector3(0, 0, 1), image_size * 0.9, image_size * 0.9)
            sub_root["hh_image_" .. i]["hh_client_text"] = HH_UTILS:HHCreateTextUi(sub_root["hh_image_" .. i], Vector3(0, 0, 1), tostring(effect_small_name), nil, image_size / 2, true)

            sub_root["hh_image_" .. i]["hh_btn"] = HH_UTILS:HHCreateBtnUi(sub_root["hh_image_" .. i], "images/ui.xml", "button_large.tex", Vector3(image_size / 2 + 50, 0, 1), 0.3, 0.3)
            sub_root["hh_image_" .. i]["hh_btn"]:SetOnClick(function()
                SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "CompoundSuitEffect", effect_id)
            end)
            sub_root["hh_image_" .. i]["hh_btn"]["hh_str"] = HH_UTILS:HHCreateTextUi(sub_root["hh_image_" .. i]["hh_btn"], Vector3(0, 0, 1), "合成", nil, 20)
            sub_root["hh_image_" .. i]:SetPosition(start_x + image_size / 2, start_y - image_size / 2, 1)
            start_y = start_y - image_size - 10
        end
    end

    --裁切ui和整个滚动条的偏移 ui初始位置左下
    local scissor_data = {
        ["x"] = 0,
        ["y"] = 0,
        ["width"] = sub_w,
        ["height"] = sub_h
    }
    local context = {
        --挂载ui
        ["widget"] = sub_root,
        --坐标偏移
        ["offset"] = {
            ["x"] = 0,
            ["y"] = sub_h,
        },
        ["size"] = {
            --未找到用处
            ["w"] = 0,
            --总ui大小
            ["height"] = math["abs"](start_y),
        }
    }
    local scrollbar = { ["scroll_per_click"] = 5 * 3 }
    father_ui["suit_recipe_ui"] = father_ui:AddChild(TrueScrollArea(context, scissor_data, scrollbar))
    father_ui["suit_recipe_ui"]:SetPosition(-220, 0, 1)
    --增加标题
    father_ui["suit_recipe_ui"]["hh_title"] = HH_UTILS:HHCreateTextUi(father_ui["suit_recipe_ui"], Vector3(sub_w / 2, sub_h + 10, 1), "可合成的词条", nil, 20)

    local hh_sub = father_ui["suit_recipe_ui"]
    hh_sub["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    hh_sub["up_button"]:SetScale(0.35)
    hh_sub["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    hh_sub["down_button"]:SetScale(-0.35)
    hh_sub["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    hh_sub["scroll_bar_line"]:SetScale(0.25)
    hh_sub["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    hh_sub["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    hh_sub["position_marker"]:SetScale(0.3)
end
----
---装备强化ui
---
function HH_UI:CreateEquipUpgradingUi()
    HH_UTILS:HHKillChild(self["hh_main"], "suit_config_ui")
    self["hh_main"]["suit_config_ui"] = self["hh_main"]:AddChild(Widget())
    local father_ui = self["hh_main"]["suit_config_ui"]
    local offset_size = 50
    local equip_info_size_x, equip_info_size_y = hh_main_size_x / 2 - offset_size, hh_main_size_y - offset_size
    local line_offset_x, line_offset_y = 30, 65
    father_ui["hh_equip_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-220, -5, 1), "装备==>", nil, 20)
    father_ui["hh_material_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-260, -60, 1), "材\n料", { 255 / 255, 116 / 255, 0 / 255, 1 }, 20)
    father_ui["hh_material_text"] = HH_UTILS:HHCreateTextUi(father_ui, Vector3(-10, -160, 1), "星级装备\n提升概率", { 255 / 255, 116 / 255, 0 / 255, 1 }, 15)
    --强化
    local btn_xml, btn_tex = "images/ui.xml", "button_large.tex"
    father_ui["hh_btn_upgrading"] = HH_UTILS:HHCreateBtnUi(father_ui, btn_xml, btn_tex, Vector3(-hh_main_size_x / 4 - line_offset_x * 2.5, -hh_main_size_y / 4 - line_offset_y, 1), 0.3, 0.3)
    father_ui["hh_btn_upgrading"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "EquipUpgrading")
    end)
    father_ui["hh_btn_upgrading"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_upgrading"], Vector3(0, 0, 1), "强化", nil, 20)
    --升星
    father_ui["hh_btn_add_star"] = HH_UTILS:HHCreateBtnUi(father_ui, btn_xml, btn_tex, Vector3(-hh_main_size_x / 4, -hh_main_size_y / 4 - line_offset_y, 1), 0.3, 0.3)
    father_ui["hh_btn_add_star"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "EquipAddStar")
    end)
    father_ui["hh_btn_add_star"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_add_star"], Vector3(0, 0, 1), "升星", nil, 20)
    --前缀
    father_ui["hh_btn_prefix"] = HH_UTILS:HHCreateBtnUi(father_ui, btn_xml, btn_tex, Vector3(-hh_main_size_x / 4 + line_offset_x * 2.5, -hh_main_size_y / 4 - line_offset_y, 1), 0.3, 0.3)
    father_ui["hh_btn_prefix"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "FixStarEquip")
    end)
    father_ui["hh_btn_prefix"]["hh_str"] = HH_UTILS:HHCreateTextUi(father_ui["hh_btn_prefix"], Vector3(0, 0, 1), "修复", nil, 20)

    --装备信息
    father_ui["equip_info_ui"] = HH_UTILS:HHCreateImageUi(father_ui, white_xml, white_tex, Vector3(hh_main_size_x / 4, 0, 1), equip_info_size_x, equip_info_size_y, { 0, 0, 0, 0.5 })

    --默认第一次获取一下装备信息
    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], "GetStarEquipInfo")

end

function HH_UI:CreateOrUpdateEquipInfoUi(server_table)
    if not (self["hh_main"] and self["hh_main"]["suit_config_ui"]) then
        return
    end
    if not HH_UTILS:IsHHType(server_table, "table") then
        return
    end
    local father_ui = self["hh_main"]["suit_config_ui"]
    if not father_ui["equip_info_ui"] then
        return
    end
    local equip_info_ui = father_ui["equip_info_ui"]
    HH_UTILS:HHKillChild(equip_info_ui, "info_ui")
    equip_info_ui["info_ui"] = HH_UTILS:CreateInfoUi(equip_info_ui,
            server_table,
            {
                { ["id"] = "name", ["name"] = "名字:", ["scale"] = 20, },
                { ["id"] = "bind_name", ["name"] = "绑定:", ["scale"] = 20, },
                { ["id"] = "star_str", ["name"] = "星级:", ["scale"] = 20, },
                { ["id"] = "current_chance", ["name"] = "升星概率:", ["scale"] = 20, },
                --{ ["id"] = "next_star_config", ["name"] = "升星材料:", ["scale"] = 20, },
                --{ ["id"] = "fix_equip_config", ["name"] = "修复材料:", ["scale"] = 20, },
            })
    local extra_info_pos_x, extra_info_pos_y = -120, 170
    equip_info_ui["info_ui"]:SetPosition(extra_info_pos_x, extra_info_pos_y, 1)
    local info_size_x, info_size_y = equip_info_ui["info_ui"]["max_x"], equip_info_ui["info_ui"]["max_y"]
    ---------------------------------升星材料ui ---------------------------------
    extra_info_pos_x, extra_info_pos_y = extra_info_pos_x, extra_info_pos_y - info_size_y
    local server_star_config = {}
    if HH_UTILS:IsHHType(server_table["next_star_config"], "table")
            and HH_UTILS:IsHHType(server_table["next_star_config"]["str"], "string")
    then
        server_star_config = HH_UTILS:StrToTable(server_table["next_star_config"]["str"])
    end
    local star_config_ui_table = {}
    local server_star_sort_table = HH_UTILS:TableSortKeys(server_star_config)
    HH_UTILS:HHKillChild(equip_info_ui, "star_config_ui")
    if #server_star_sort_table > 0 then
        for i, v in ipairs(server_star_sort_table) do
            local _item_id = tostring(v)
            local _item_tex = _item_id .. ".tex"
            local _item_xml = GetInventoryItemAtlas(_item_tex) or "images/inventoryimages1.xml"
            table["insert"](star_config_ui_table, {
                ["type"] = "image",
                ["xml"] = _item_xml,
                ["tex"] = _item_tex,
            })
            table["insert"](star_config_ui_table, {
                ["type"] = "text",
                ["str"] = tostring(server_star_config[v]) .. "  ",
                ["scale"] = 20,
            })
        end
        equip_info_ui["star_config_ui"] = HH_UTILS:CreateImageAndText(equip_info_ui, star_config_ui_table, 1)
        equip_info_ui["star_config_ui"]["label_str"] = HH_UTILS:HHCreateTextUi(equip_info_ui["star_config_ui"], Vector3(0, 0, 1),
                "升星材料:", { 255 / 255, 117 / 255, 0 / 255, 1 }, 20)
        local label_size_x, label_size_y = equip_info_ui["star_config_ui"]["label_str"]:GetRegionSize()
        equip_info_ui["star_config_ui"]["label_str"]:SetPosition(-label_size_x / 2, -label_size_y / 2, 1)
        equip_info_ui["star_config_ui"]:SetPosition(extra_info_pos_x + label_size_x, extra_info_pos_y, 1)
        info_size_x, info_size_y = equip_info_ui["star_config_ui"]["max_x"], equip_info_ui["star_config_ui"]["max_y"]
    end
    ---------------------------------升星材料ui ---------------------------------
    ---------------------------------修复材料ui ---------------------------------
    extra_info_pos_x, extra_info_pos_y = extra_info_pos_x, extra_info_pos_y - info_size_y
    local server_fix_config = {}
    if HH_UTILS:IsHHType(server_table["fix_equip_config"], "table")
            and HH_UTILS:IsHHType(server_table["fix_equip_config"]["str"], "string")
    then
        server_fix_config = HH_UTILS:StrToTable(server_table["fix_equip_config"]["str"])
    end
    local fix_config_ui_table = {}
    local server_fix_sort_table = HH_UTILS:TableSortKeys(server_fix_config)
    HH_UTILS:HHKillChild(equip_info_ui, "fix_config_ui")
    if #server_fix_sort_table > 0 then
        for i, v in ipairs(server_fix_sort_table) do
            local _item_id = tostring(v)
            local _item_tex = _item_id .. ".tex"
            local _item_xml = GetInventoryItemAtlas(_item_tex) or "images/inventoryimages1.xml"
            table["insert"](fix_config_ui_table, {
                ["type"] = "image",
                ["xml"] = _item_xml,
                ["tex"] = _item_tex,
            })
            table["insert"](fix_config_ui_table, {
                ["type"] = "text",
                ["str"] = tostring(server_fix_config[v]) .. "  ",
                ["scale"] = 20,
            })
        end
        equip_info_ui["fix_config_ui"] = HH_UTILS:CreateImageAndText(equip_info_ui, fix_config_ui_table, 1)
        equip_info_ui["fix_config_ui"]["label_str"] = HH_UTILS:HHCreateTextUi(equip_info_ui["fix_config_ui"], Vector3(0, 0, 1),
                "修复材料:", { 255 / 255, 117 / 255, 0 / 255, 1 }, 20)
        local label_size_x, label_size_y = equip_info_ui["fix_config_ui"]["label_str"]:GetRegionSize()
        equip_info_ui["fix_config_ui"]["label_str"]:SetPosition(-label_size_x / 2, -label_size_y / 2, 1)
        equip_info_ui["fix_config_ui"]:SetPosition(extra_info_pos_x + label_size_x, extra_info_pos_y, 1)
        info_size_x, info_size_y = equip_info_ui["star_config_ui"]["max_x"], equip_info_ui["fix_config_ui"]["max_y"]
    end
    ---------------------------------修复材料ui ---------------------------------
end
return HH_UI
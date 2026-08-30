local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")
local TEMPLATES = require("widgets/redux/templates")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local HH_UTILS = require("utils/hh_utils")
local background_xml, background_tex = "images/scrapbook.xml", "scrap2_wide.tex"
local scrapbook_xml = "images/scrapbook.xml"
local main_xml, main_tex = "images/global.xml", "square.tex"
local close_xml, close_tex = "images/crafting_menu.xml", "pinslot_unpin_button.tex"
local HH_ITEMS_CONFIG = require("enums/hh_items")
local hh_main_size_x, hh_main_size_y = 600, 400
local hh_title_size_x, hh_title_size_y = 100, 50
local title_size = 30
--拆解ui大小
local hh_disassembly_size_x, hh_disassembly_size_y = 200, 300
--附魔ui大小
local hh_enchant_size_x, hh_enchant_size_y = 300, 150
--宝石ui
local hh_gem_ui_size_x, hh_gem_ui_size_y = 300, 200
--白色方块的大小
local image_size = 64
local put_in_size_x, put_in_size_y = 60, 30
--边距
local hh_margins = 20
local HH_UI = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_equip_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["hh_server_items"] = {}

    --self["hh_main"] = HH_UTILS:HHCreateImageUi(self["root"], background_xml, background_tex, Vector3(0, 0, 1), hh_main_size_x, hh_main_size_y, { 1, 1, 1, 1 })
    self["hh_main"] = HH_UTILS:CreateFrameUiTwo(self["root"], Vector3(0, 0, 1),
            { ["size_x"] = hh_main_size_x, ["size_y"] = hh_main_size_y, ["color"] = { 41 / 255, 30 / 255, 21 / 255, 1 }, })
    local main_size_x, main_size_y = self["hh_main"]:GetSize()

    self["hh_main"]["hh_title"] = HH_UTILS:HHCreateImageUi(self["hh_main"], main_xml, main_tex, Vector3(0, 0, 1), hh_title_size_x, hh_title_size_y, { 0, 0, 0, 0 })
    local title_size_x, title_size_y = self["hh_main"]["hh_title"]:GetSize()
    local title_pos_x, title_pos_y = 0, main_size_y / 2 + title_size_y / 2
    self["hh_main"]["hh_title"]:SetPosition(title_pos_x, title_pos_y, 1)
    self["hh_main"]["hh_title"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_title"], Vector3(0, 0, 1), "装备强化", nil, title_size)

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --拆解装备背景
    self["hh_main"]["hh_disassembly"] = HH_UTILS:HHCreateImageUi(self["hh_main"], scrapbook_xml, "scrap2_tall.tex", Vector3(0, 0, 1), hh_disassembly_size_x, hh_disassembly_size_y, { 1, 1, 1, 0 })
    local disassembly_size_x, disassembly_size_y = self["hh_main"]["hh_disassembly"]:GetSize()
    local disassembly_pos_x, disassembly_pos_y = -main_size_x / 2 + hh_margins + disassembly_size_x / 2, main_size_y / 2 - disassembly_size_y / 2 - hh_margins
    self["hh_main"]["hh_disassembly"]:SetPosition(disassembly_pos_x, disassembly_pos_y, 1)

    --2025-02-24往右偏移一点
    disassembly_pos_x = disassembly_pos_x + 15
    --一键将物品栏放入容器中去（一键拾取会导致抢装备的情况）
    local put_pos_x, put_pos_y = disassembly_pos_x - disassembly_size_x / 2 + put_in_size_x / 2 + hh_margins, disassembly_pos_y - disassembly_size_y / 2 - hh_margins - put_in_size_y / 2
    self["hh_main"]["hh_put_in"] = HH_UTILS:HHCreateImageButton(self["hh_main"], main_xml, main_tex, Vector3(put_pos_x, put_pos_y, 1), put_in_size_x / image_size, put_in_size_y / image_size, { 0, 0, 0, 0.5 })
    self["hh_main"]["hh_put_in"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_put_in"], Vector3(0, 0, 1), "一键放入", nil, 20)
    self["hh_main"]["hh_put_in"]:SetOnClick(function()
        self:CreateSureUi("MoveEquips", "一键放入装备", nil, false)
    end)
    local disassembly_btn_pos_x, disassembly_btn_pos_y = disassembly_pos_x + disassembly_size_x / 2 - put_in_size_x / 2 - hh_margins, disassembly_pos_y - disassembly_size_y / 2 - hh_margins - put_in_size_y / 2
    self["hh_main"]["hh_disassembly_btn"] = HH_UTILS:HHCreateImageButton(self["hh_main"], main_xml, main_tex, Vector3(disassembly_btn_pos_x, disassembly_btn_pos_y, 1), put_in_size_x / image_size, put_in_size_y / image_size, { 0, 0, 0, 0.5 })
    self["hh_main"]["hh_disassembly_btn"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_disassembly_btn"], Vector3(0, 0, 1), "一键拆解", nil, 20)
    self["hh_main"]["hh_disassembly_btn"]:SetOnClick(function()
        self:CreateSureUi("RemoveEquips", "是否拆除装备", nil, true)
    end)
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --附魔ui
    self["hh_main"]["hh_enchant"] = HH_UTILS:HHCreateImageUi(self["hh_main"], main_xml, main_tex, Vector3(0, 0, 1), hh_enchant_size_x, hh_enchant_size_y, { 0, 0, 0, 0.5 })
    local enchant_size_x, enchant_size_y = self["hh_main"]["hh_enchant"]:GetSize()
    local enchant_pos_x, enchant_pos_y = main_size_x / 2 - hh_margins - enchant_size_x / 2, main_size_y / 2 - enchant_size_y / 2 - hh_margins
    self["hh_main"]["hh_enchant"]:SetPosition(enchant_pos_x, enchant_pos_y, 1)
    --增加箭头描述
    self["hh_main"]["hh_enchant"]["hh_text_weapon"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"], Vector3(-120, 5, 1), "↑\n装\n备", nil, 20)
    self["hh_main"]["hh_enchant"]["hh_text_enchant_stone"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"], Vector3(-70, -5, 1), "↑\n附\n魔\n类", nil, 20)
    self["hh_main"]["hh_enchant"]["hh_text_weapon"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"], Vector3(-20, -5, 1), "↑\n洗\n蕴\n石", nil, 20)
    --按钮
    local hh_enchant_btn_size_x, hh_enchant_btn_size_y = 35, 20
    self["hh_main"]["hh_enchant"]["hh_btn_add_effect"] = HH_UTILS:HHCreateImageButton(self["hh_main"]["hh_enchant"], main_xml, main_tex, Vector3(-120, -50, 1), hh_enchant_btn_size_x / image_size, hh_enchant_btn_size_y / image_size, { 1, 1, 1, 0.5 })
    self["hh_main"]["hh_enchant"]["hh_btn_add_effect"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"]["hh_btn_add_effect"], Vector3(0, 0, 1), "升品", nil, 15)
    self["hh_main"]["hh_enchant"]["hh_btn_add_effect"]:SetOnClick(function()
        self:CreateSureUi("UpdateEffectValue", "刷新装备所有词条的属性", nil, false)
    end)

    self["hh_main"]["hh_enchant"]["hh_btn_improve_value"] = HH_UTILS:HHCreateImageButton(self["hh_main"]["hh_enchant"], main_xml, main_tex, Vector3(-70, -50, 1), hh_enchant_btn_size_x / image_size, hh_enchant_btn_size_y / image_size, { 1, 1, 1, 0.5 })
    self["hh_main"]["hh_enchant"]["hh_btn_improve_value"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"]["hh_btn_improve_value"], Vector3(0, 0, 1), "附魔", nil, 15)
    self["hh_main"]["hh_enchant"]["hh_btn_improve_value"]:SetOnClick(function()
        self:CreateSureUi("AddEquipEffect", "对装备进行附魔", nil, false)
    end)

    self["hh_main"]["hh_enchant"]["hh_btn_reduce_effect"] = HH_UTILS:HHCreateImageButton(self["hh_main"]["hh_enchant"], main_xml, main_tex, Vector3(-20, -50, 1), hh_enchant_btn_size_x / image_size, hh_enchant_btn_size_y / image_size, { 1, 1, 1, 0.5 })
    self["hh_main"]["hh_enchant"]["hh_btn_reduce_effect"]["hh_text"] = HH_UTILS:HHCreateTextUi(self["hh_main"]["hh_enchant"]["hh_btn_reduce_effect"], Vector3(0, 0, 1), "清除", nil, 15)
    self["hh_main"]["hh_enchant"]["hh_btn_reduce_effect"]:SetOnClick(function()
        self:CreateSureUi("RemoveEquipEffect", "随机清除一个词条", nil, false)
    end)
    --附魔描述页面
    local hh_desc_ui_size_x, hh_desc_ui_size_y = hh_enchant_size_x / 2, hh_enchant_size_y
    self["hh_main"]["hh_enchant"]["hh_desc_ui"] = HH_UTILS:HHCreateImageUi(self["hh_main"]["hh_enchant"], main_xml, main_tex, Vector3(hh_enchant_size_x / 4, 0, 1), hh_desc_ui_size_x, hh_desc_ui_size_y, { 1, 1, 1, 0.5 })
    local enchant_desc_ui = self["hh_main"]["hh_enchant"]["hh_desc_ui"]
    --处理文本
    enchant_desc_ui["hh_title"] = HH_UTILS:HHCreateTextUi(enchant_desc_ui, Vector3(0, 0, 1), "附魔", { 255 / 255, 242 / 255, 0 / 255, 1 }, 20)
    local enchant_title_size_x, enchant_title_size_y = enchant_desc_ui["hh_title"]:GetRegionSize()
    local enchant_title_pos_x, enchant_title_pos_y = -hh_desc_ui_size_x / 2 + hh_margins / 2 + enchant_title_size_x / 2, hh_desc_ui_size_y / 2 - hh_margins / 2 - enchant_title_size_y / 2
    enchant_desc_ui["hh_title"]:SetPosition(enchant_title_pos_x, enchant_title_pos_y, 1)

    enchant_desc_ui["hh_text_enchant_stone"] = HH_UTILS:HHCreateTextUi(enchant_desc_ui, Vector3(0, 0, 1), "[附魔石/卷轴]:给装\n备增加指定/随机词条", { 1, 1, 1, 1 }, 20, true)
    local enchant_stone_size_x, enchant_stone_size_y = enchant_desc_ui["hh_text_enchant_stone"]:GetRegionSize()
    local enchant_stone_pos_x, enchant_stone_pos_y = -hh_desc_ui_size_x / 2 + hh_margins / 2 + enchant_stone_size_x / 2, enchant_title_pos_y - enchant_title_size_y / 2 - enchant_stone_size_y / 2
    enchant_desc_ui["hh_text_enchant_stone"]:SetPosition(enchant_stone_pos_x, enchant_stone_pos_y, 1)

    enchant_desc_ui["hh_text_enchant_stone_value"] = HH_UTILS:HHCreateTextUi(enchant_desc_ui, Vector3(0, 0, 1), "[重置宝石]:将装备数值\n类词条进行随机赋值", { 1, 1, 1, 1 }, 20, true)
    local enchant_stone_value_size_x, enchant_stone_value_size_y = enchant_desc_ui["hh_text_enchant_stone_value"]:GetRegionSize()
    local enchant_stone_value_pos_x, enchant_stone_value_pos_y = -hh_desc_ui_size_x / 2 + hh_margins / 2 + enchant_stone_value_size_x / 2, enchant_stone_pos_y - enchant_stone_size_y / 2 - enchant_stone_value_size_y / 2
    enchant_desc_ui["hh_text_enchant_stone_value"]:SetPosition(enchant_stone_value_pos_x, enchant_stone_value_pos_y, 1)

    enchant_desc_ui["hh_text_enchant_reduce_stone"] = HH_UTILS:HHCreateTextUi(enchant_desc_ui, Vector3(0, 0, 1), "[洗蕴石]:随机清除一个词\n条", { 1, 1, 1, 1 }, 20, true)
    local enchant_reduce_stone_size_x, enchant_reduce_stone_size_y = enchant_desc_ui["hh_text_enchant_reduce_stone"]:GetRegionSize()
    local enchant_reduce_stone_pos_x, enchant_reduce_stone_pos_y = -hh_desc_ui_size_x / 2 + hh_margins / 2 + enchant_reduce_stone_size_x / 2, enchant_stone_value_pos_y - enchant_stone_value_size_y / 2 - enchant_reduce_stone_size_y / 2
    enchant_desc_ui["hh_text_enchant_reduce_stone"]:SetPosition(enchant_reduce_stone_pos_x, enchant_reduce_stone_pos_y, 1)
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --宝石ui
    self["hh_main"]["hh_gem_ui"] = HH_UTILS:HHCreateImageUi(self["hh_main"], main_xml, main_tex, Vector3(0, 0, 1), hh_gem_ui_size_x, hh_gem_ui_size_y, { 0, 0, 0, 0.5 })
    local gem_ui_size_x, gem_ui_size_y = self["hh_main"]["hh_gem_ui"]:GetSize()
    local hh_gem_ui_pos_x, hh_gem_ui_pos_y = main_size_x / 2 - hh_margins - gem_ui_size_x / 2, -main_size_y / 2 + gem_ui_size_y / 2 + hh_margins
    self["hh_main"]["hh_gem_ui"]:SetPosition(hh_gem_ui_pos_x, hh_gem_ui_pos_y, 1)
    local gem_main_ui = self["hh_main"]["hh_gem_ui"]
    gem_main_ui["hh_title"] = HH_UTILS:HHCreateTextUi(gem_main_ui, Vector3(0, 0, 1), "宝石镶嵌", { 255 / 255, 242 / 255, 0 / 255, 1 }, 30, true)
    local gem_main_ui_title_size_x, gem_main_ui_title_size_y = gem_main_ui["hh_title"]:GetRegionSize()
    gem_main_ui["hh_title"]:SetPosition(0, gem_ui_size_y / 2 - 5 - gem_main_ui_title_size_y / 2, 1)

    gem_main_ui["hh_back_text"] = HH_UTILS:HHCreateTextUi(gem_main_ui, Vector3(-50, 60, 1), "↓已有物品(空白就是啥都没有)↓", { 1, 1, 1, 1 }, 20, true)
    gem_main_ui["hh_right_text"] = HH_UTILS:HHCreateTextUi(gem_main_ui, Vector3(75, 75, 1), "装备→", { 255 / 255, 11 / 255, 0 / 255, 1 }, 20, true)

    --宝石滚动条
    self["hh_main"]["hh_gem_ui"]["gem_templates"] = self["hh_main"]["hh_gem_ui"]:AddChild(self:CreateTemplates())
    self["hh_main"]["hh_gem_ui"]["gem_templates"]:SetPosition(0, -20, 1)
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --enchanting
    --self["hh_main"]["hh_slot_background"] = HH_UTILS:HHCreateImageUi(self["hh_main"], main_xml, main_tex, Vector3(0, 75, 1), 280, 110, { 0, 0, 0, 0.5 })
    self["hh_main"]["hh_close"] = HH_UTILS:HHCreateImageButton(self["hh_main"], close_xml, close_tex, Vector3(main_size_x / 2, main_size_y / 2, 1), 0.3, 0.3)
    self["hh_main"]["hh_close"]:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
    end)
    --刷新物品数量
    self:UpdateTemplates()
    self["inst"]:ListenForEvent("hh_items", function()
        self:UpdateTemplates()
    end, self["owner"])

end)

function HH_UI:UpdateTemplates()
    if self["hh_main"]
            and self["hh_main"]["hh_gem_ui"]
            and self["hh_main"]["hh_gem_ui"]["gem_templates"]
            and HH_UTILS:HasComponents(self["owner"], "hh_client")
    then
        local hh_items_client = self["owner"]["components"]["hh_client"]:GetValue("hh_items")
        if HH_UTILS:IsHHType(hh_items_client, "table") then
            self["hh_server_items"] = hh_items_client
            self["hh_main"]["hh_gem_ui"]["gem_templates"]:SetItemsData(self["hh_server_items"])
        end
    end
end
function HH_UI:CreateTemplates()
    local child_size_x, child_size_y = 95, 32

    ----滑轮每一个子类(每次滑动会刷新 index代表可见的条数)
    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)
        widget:SetOnGainFocus(
                function()
                    if self["hh_main"] and self["hh_main"]["hh_gem_ui"] and self["hh_main"]["hh_gem_ui"]["gem_templates"] then
                        self["hh_main"]["hh_gem_ui"]["gem_templates"]:OnWidgetFocus(widget)
                    end
                end
        )
        ----任务条
        widget["hh_background"] = HH_UTILS:HHCreateImageUi(widget, main_xml, main_tex, Vector3(0, 0, 1), 10, 10, { 0, 0, 0, 0 })
        widget["hh_background"]["hh_btn"] = widget["hh_background"]:AddChild(ImageButton(main_xml, main_tex))
        widget["hh_background"]["hh_btn"]["image"]:SetTint(0, 0, 0, 0.5)
        widget["hh_background"]["hh_btn"]:SetNormalScale(child_size_x / image_size, child_size_y / image_size, 1)
        widget["hh_background"]["hh_btn"]:SetPosition(0, 0, 1)
        widget["hh_background"]["hh_btn"]["focus_scale"] = { child_size_x / image_size, child_size_y / image_size, 1 }
        widget["hh_background"]["hh_btn"]["gem_name"] = HH_UTILS:HHCreateTextUi(widget["hh_background"]["hh_btn"], Vector3(0, 0, 1), "宝石", nil, 20)
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"] = HH_UTILS:HHCreateTextUi(widget["hh_background"]["hh_btn"]["gem_name"], Vector3(0, 0, 1), "宝石", nil, 20)
        return widget
    end

    local function ApplyDataToWidget(context, widget, data, index)
        widget["data"] = data
        widget["hh_background"]:Hide()
        if not data then
            return
        end
        widget["hh_background"]:Show()
        local hh_gem_list = widget["data"]
        local gem_id = hh_gem_list["id"]
        if not gem_id or not HH_ITEMS_CONFIG[gem_id] then
            return
        end
        local gem_name = HH_ITEMS_CONFIG[gem_id]["name"] or "空"
        local gem_num = hh_gem_list["num"] or "0"
        widget["hh_background"]["hh_btn"]["gem_name"]:SetString(gem_name .. ":")
        local gem_name_size_x, gem_name_size_y = widget["hh_background"]["hh_btn"]["gem_name"]:GetRegionSize()
        widget["hh_background"]["hh_btn"]["gem_name"]:SetPosition(-child_size_x / 2 + 10 + gem_name_size_x / 2, 0, 1)
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:SetString(gem_num)
        local gem_num_size_x, gem_num_size_y = widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:GetRegionSize()
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:SetPosition(gem_name_size_x / 2 + gem_num_size_x / 2, 0, 1)
        widget["hh_background"]["hh_btn"]:SetOnClick(function()
            local btn_desc = "是否镶嵌"
            if gem_id == "a_punchStone" then
                btn_desc = "是否给装备打孔"
            elseif gem_id == "a_stoneDecoder" then
                btn_desc = "是否随机销毁一个宝石"
            elseif HH_ITEMS_CONFIG[gem_id]["is_item"] then
                btn_desc = "使用" .. gem_name
            else
                btn_desc = btn_desc .. "\n" .. gem_name
            end
            --重置宝石无法进行操作
            if gem_id == "a_refreshStone" or gem_id == "z_clean_stone" then
                return
            end
            self:CreateSureUi("EquipGems", btn_desc, gem_id, true)
        end)

    end
    local grid = TEMPLATES.ScrollingGrid(
            self["hh_server_items"],
            {
                context = {},
                ----单个子类长宽
                widget_width = child_size_x,
                widget_height = child_size_y,
                ----可视行数(滚动条的高度除以单个任务条宽度)
                num_visible_rows = 4,
                ----显示列数
                num_columns = 3,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 5,
                scrollbar_height_offset = 0,
                peek_percent = 0,
                allow_bottom_empty_row = true, -- it's hidden anyway
            })
    grid:SetPosition(50, 0, 1)
    grid["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid["up_button"]:SetScale(0.2)

    grid["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid["down_button"]:SetScale(-0.2)

    grid["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    grid["scroll_bar_line"]:SetScale(0.3)

    grid["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid["position_marker"]:SetScale(0.3)
    return grid
end
----
---创建确认按钮
---@param rpc_name
---@param ui_desc
---@param gem_index
---@param need_sure_ui:是否需要确认页面
---
function HH_UI:CreateSureUi(rpc_name, ui_desc, gem_index, need_sure_ui)
    local size_x, size_y = 200, 100
    local btn_size_x, btn_size_y = 50, 30
    local sure_margins = 10
    local desc = tostring(ui_desc)
    HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
    if need_sure_ui then
        self["hh_main"]["hh_sure_ui"] = HH_UTILS:HHCreateImageUi(self["hh_main"], scrapbook_xml, "scrap_wide.tex", Vector3(50, 0, 1), size_x, size_y)
        local sure_ui = self["hh_main"]["hh_sure_ui"]

        sure_ui["hh_desc"] = HH_UTILS:HHCreateTextUi(sure_ui, Vector3(0, 0, 1), desc, nil, 25)
        local desc_size_x, desc_size_y = sure_ui["hh_desc"]:GetRegionSize()
        sure_ui["hh_desc"]:SetPosition(0, size_y / 2 - sure_margins - desc_size_y / 2, 1)

        local sure_pos_x, sure_pos_y = -size_x / 2 + sure_margins + btn_size_x / 2, -size_y / 2 + btn_size_y / 2 + sure_margins
        sure_ui["hh_sure"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(sure_pos_x, sure_pos_y, 1), btn_size_x / image_size, btn_size_y / image_size, { 0, 0, 0, 0.5 })
        sure_ui["hh_sure"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_sure"], Vector3(0, 0, 1), "确认", nil, 15)
        sure_ui["hh_sure"]:SetOnClick(function()
            SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], rpc_name, gem_index)
            HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
        end)

        local close_pos_x, close_pos_y = size_x / 2 - sure_margins - btn_size_x / 2, -size_y / 2 + btn_size_y / 2 + sure_margins
        sure_ui["hh_close"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(close_pos_x, close_pos_y, 1), btn_size_x / image_size, btn_size_y / image_size, { 0, 0, 0, 0.5 })
        sure_ui["hh_close"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_close"], Vector3(0, 0, 1), "取消", nil, 15)
        sure_ui["hh_close"]:SetOnClick(function()
            HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
        end)
    else
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], rpc_name, gem_index)
    end
end
return HH_UI
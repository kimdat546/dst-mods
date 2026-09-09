local Text = require("widgets/text")
local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local UIAnim = require("widgets/uianim")
local Image = require("widgets/image")
local HH_UTILS = require("utils/hh_utils")

local show_num = 5
local HH_ANNOUNCE = Class(Widget, function(self, owner)
    Widget["_ctor"](self, "hh_announce")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    --存储同步的装备属性
    self["save_table"] = {}
    self["inst"]:ListenForEvent("hh_share_equip_client", function(inst, data)
        local share_equip_table = HH_UTILS:GetClientValue(self["owner"], "hh_share_equip_client")
        if not HH_UTILS:IsHHType(share_equip_table, "table") then
            return
        end
        self:UpdateEquip(share_equip_table)
    end, self["owner"])
end)

----
---更新存储的装备属性
---
function HH_ANNOUNCE:UpdateEquip(equip_table)
    if #self["save_table"] <= 0 then
        table["insert"](self["save_table"], equip_table)
    elseif #self["save_table"] >= show_num then
        --长度满了 取前10条
        local old_length = #self["save_table"]
        -- 计算起始索引
        local startIndex = old_length - show_num
        local new_table = {}
        for i = startIndex, old_length do
            if HH_UTILS:IsHHType(self["save_table"][i], "table") then
                table["insert"](new_table, self["save_table"][i])
            end
        end
        table["insert"](new_table, equip_table)
        self["save_table"] = new_table
    else
        table["insert"](self["save_table"], equip_table)
    end
    --更新ui
    self:CreateAnnounceUi()
end
----
---装备类展示
---
function HH_ANNOUNCE:CreateEquipUi(father_ui, client_table, index, start_y)
    if not HH_UTILS:IsHHType(client_table, "table") or not HH_UTILS:IsHHType(index, "number") then
        return start_y
    end
    local show_text_scale = 20
    local item_name = "装备"
    local player_name = "玩家?"
    item_name = tostring(client_table["equip"])
    player_name = tostring(client_table["player"])
    local hh_player_title = client_table["player_title"] or ""--前缀称号
    father_ui["hh_child_" .. index] = HH_UTILS:CreateMoreTextUi(father_ui, {
        { ["str"] = hh_player_title, ["color"] = { 255 / 255, 232 / 255, 0 / 255, 1 }, ["scale"] = show_text_scale },
        { ["str"] = player_name, ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = show_text_scale },
        { ["str"] = ":展示了【", ["scale"] = show_text_scale },
        { ["str"] = item_name, ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, ["scale"] = show_text_scale },
        { ["str"] = "】", ["scale"] = show_text_scale },
    }, 1)
    local com_size_x, com_size_y = father_ui["hh_child_" .. index]["max_x"], father_ui["hh_child_" .. index]["max_y"]
    father_ui["hh_child_" .. index]:SetPosition(0, start_y, 1)
    local child_ui = father_ui["hh_child_" .. index]
    --------------------------------------------------------------
    --todo 增加称号系统
    --child_ui["hh_title_image"] = child_ui:AddChild(Image("images/hh_icon/hh_title_pig.xml", "hh_title_pig.tex"))
    --local title_image_size_x, title_image_size_y = child_ui["hh_title_image"]:GetSize()
    --local title_image_y_base_size = 32
    --local title_scale = title_image_y_base_size / title_image_size_y
    --child_ui["hh_title_image"]:SetSize(title_image_size_x * title_scale, title_image_y_base_size)
    --child_ui["hh_title_image"]:SetPosition(-title_image_size_x / 4 - 5, -show_text_scale / 2, 1)
    --child_ui["hh_title_image"]:SetTint(1, 0, 0, 1)
    --------------------------------------------------------------
    --装备排第三
    if child_ui["hh_text_4"] and child_ui["hh_text_4"]["GetRegionSize"] then
        local text_x, text_y = child_ui["hh_text_4"]:GetRegionSize()
        child_ui["hh_text_4"]["hh_back_ground"] = HH_UTILS:HHCreateImageUi(child_ui["hh_text_4"], "images/global.xml", "square.tex",
                Vector3(0, 0, 1), text_x, text_y, { 1, 1, 1, 0 })
        --child_ui["hh_text_4"]["hh_back_ground"]:MoveToBack()
        --child_ui["hh_text_4"]["hh_back_ground"]:SetClickable(false)
        local back_ui = child_ui["hh_text_4"]["hh_back_ground"]
        local oldOnGainFocusBack = back_ui["OnGainFocus"]
        back_ui["OnGainFocus"] = function()
            if oldOnGainFocusBack then
                oldOnGainFocusBack()
            end
            HH_UTILS:HHKillChild(back_ui, "info_ui")
            local server_info = {
                ["name"] = { ["str"] = item_name, ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
                ["player"] = { ["str"] = player_name, ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
                ["effect"] = { ["str"] = client_table["effect"], ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
            }
            --宝石增加校验
            if client_table["gem"] then
                server_info["gem"] = { ["str"] = client_table["gem"], ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, }
            end
            --星级武器
            if client_table["star"] then
                server_info["star"] = { ["str"] = client_table["star"], ["color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, }
            end
            local base_name = "装备"
            if HH_UTILS:StartWith(item_name, "附魔石") or HH_UTILS:StartWith(item_name, "职业卡") then
                base_name = "道具"
            end
            back_ui["info_ui"] = HH_UTILS:CreateInfoUi(back_ui, server_info, {
                { ["id"] = "name", ["name"] = base_name .. ":", ["scale"] = 20, },
                { ["id"] = "player", ["name"] = "玩家:", ["scale"] = 20, },
                { ["id"] = "effect", ["name"] = "词条:", ["scale"] = 20, },
                { ["id"] = "gem", ["name"] = "宝石:", ["scale"] = 20, },
                { ["id"] = "star", ["name"] = "星级:", ["scale"] = 20, },
            })
            local size_info_x, size_info_y = back_ui["info_ui"]["max_x"], back_ui["info_ui"]["max_y"]
            --创建背景
            back_ui["info_ui"]["back_ground"] = HH_UTILS:CreateFrameUi(back_ui["info_ui"], Vector3(size_info_x / 2, -size_info_y / 2, 1),
                    { ["size_x"] = size_info_x + 10, ["size_y"] = size_info_y + 10, ["color"] = { 0, 0, 0, 0.5 }, },
                    { ["size"] = 2.5, ["color"] = { 0, 0, 0, 1 }, })
            back_ui["info_ui"]["back_ground"]:MoveToBack()
            back_ui["info_ui"]:SetPosition(-size_info_x / 2, size_info_y + 20, 1)
            back_ui["info_ui"]:SetClickable(false)
        end
        local oldOnLoseFocus = back_ui["OnLoseFocus"]
        back_ui["OnLoseFocus"] = function()
            if oldOnLoseFocus then
                oldOnLoseFocus()
            end
            HH_UTILS:HHKillChild(back_ui, "info_ui")
        end
    end
    --增加背景
    --if hh_player_title and hh_player_title ~= "" then
    --    child_ui["back_ground"] = HH_UTILS:CreateFrameUi(child_ui, Vector3(com_size_x / 2, -com_size_y / 2, 1),
    --            { ["size_x"] = com_size_x + 5, ["size_y"] = com_size_y + 5, ["color"] = { 250 / 255, 230 / 255, 0 / 255, 1 }, },
    --            { ["size"] = 2, ["color"] = { 0, 0, 0, 1 }, })
    --    child_ui["back_ground"]:MoveToBack()
    --    child_ui["back_ground"]:SetClickable(false)
    --end
    return start_y - com_size_y - 10
end
----
---创建展示文本
---
function HH_ANNOUNCE:CreateAnnounceUi()
    HH_UTILS:HHKillChild(self, "hh_widget")
    if #self["save_table"] <= 0 then
        return
    end
    self["hh_widget"] = self["root"]:AddChild(Widget())
    local father_ui = self["hh_widget"]
    father_ui:SetPosition(-500, 150, 1)
    -- 获取表的长度
    local save_length = #self["save_table"]
    local start_y = 0
    -- 使用ipairs遍历表的元素（倒序）
    for i = save_length, 1, -1 do
        if HH_UTILS:IsHHType(self["save_table"][i], "table") then
            local client_table = self["save_table"][i]
            local show_type = client_table["type"]
            if show_type == "equip" then
                --装备展示ui
                start_y = self:CreateEquipUi(father_ui, client_table, i, start_y)
            elseif show_type == "task" then
                --提示任务完成展示

            end
        end
    end
    --10s后清除ui
    self["show_time"] = 0
    self:StartUpdating()
end
function HH_ANNOUNCE:OnUpdate(dt)
    if not HH_UTILS:IsHHType(self["show_time"], "number")
            or self["show_time"] < 0
    then
        self["show_time"] = 0
    end
    self["show_time"] = self["show_time"] + dt
    if self["show_time"] > 20 then
        HH_UTILS:HHKillChild(self, "hh_widget")
        --清空保存记录
        --self["save_table"] = {}
        self:StopUpdating()
    end
end

return HH_ANNOUNCE
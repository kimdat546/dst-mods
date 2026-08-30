----
---公告ui
---
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local HH_UTILS = require("utils/hh_utils")

local HH_UI = Class(Widget, function(self, owner)
    Widget["_ctor"](self, "hh_announce_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    --self["save_text"] = {}----存储播报内容 上限10条
    self["save_index"] = 1
    self["inst"]:ListenForEvent("hh_waring_data", function(inst, data)
        local hh_server_data = HH_UTILS:GetClientValue(self["owner"], "hh_waring_data")
        if HH_UTILS:IsHHType(hh_server_data, "string") then
            local str_table = HH_UTILS:StrToTable(hh_server_data)
            if next(str_table) then
                self:CreateChildUi(str_table)
            end
        end
    end, self["owner"])
end)
----
---创建公告ui
---
function HH_UI:CreateChildUi(ui_data)
    if not HH_UTILS:IsHHType(ui_data, "table") then
        --print("公告参数错误")
        return
    end
    if self["save_index"] <= 0 or self["save_index"] >= 10 then
        self["save_index"] = 1
    else
        local old_num = self["save_index"]
        self["save_index"] = old_num + 1
    end
    local hh_index = self["save_index"]
    local ui_name = "hh_child_" .. hh_index
    HH_UTILS:HHKillChild(self, ui_name)
    self[ui_name] = HH_UTILS:CreateMoreTextUi(self["root"], ui_data, 3)
    local text_x, text_y = self[ui_name]["max_x"], self[ui_name]["max_y"]
    --local start_x, start_y = -650 + text_x / 2, -280
    local start_x, start_y = -650 + text_x / 2, 280
    self[ui_name]:SetPosition(start_x, start_y, 1)
    --self[ui_name]:ScaleTo(1, 1.5, 2)
    --self[ui_name]:MoveTo(Vector3(start_x, start_y, 1), Vector3(start_x, start_y + 75, 1), 2, function()
    self[ui_name]:MoveTo(Vector3(start_x, start_y, 1), Vector3(start_x + 100, start_y, 1), 2, function()
        HH_UTILS:HHKillChild(self, ui_name)
    end)
    -----创建背景框
    local offset = 10
    self[ui_name]["hh_back_ground"] = HH_UTILS:CreateFrameUi(self[ui_name], Vector3(text_x / 2, -text_y / 2, 1),
            { ["size_x"] = text_x + offset, ["size_y"] = text_y + offset, ["color"] = { 0, 0, 0, 0.5 }, },
            { ["size"] = 2.5, ["color"] = { 0, 0, 0, 1 }, })
    self[ui_name]["hh_back_ground"]:MoveToBack()
    self[ui_name]:SetClickable(false)
end
return HH_UI
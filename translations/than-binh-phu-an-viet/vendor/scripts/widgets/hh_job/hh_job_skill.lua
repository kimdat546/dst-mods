local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local white_xml, white_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local main_size_x, main_size_y = 620, 300
local base_offset = 8
local skill_num = 5
local skill_image_size = 35
local HH_UI = Class(Widget, function(self, owner)
    Widget["_ctor"](self, "hh_job_pet_ui")
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["owner"] = owner
    self:CreateMainUi()

end)

function HH_UI:CreateMainUi()
    HH_UTILS:HHKillChild(self, "hh_main")
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self["root"], white_xml, white_tex, Vector3(-300, -200, 1), skill_image_size, skill_image_size, { 1, 1, 1, 0 })
    local main_ui = self["hh_main"]
    --HH_UTILS:UiAddFocusStr(main_ui, "右键拖动")
    HH_UTILS:MakeUiCanMove(main_ui)
    for i = 1, skill_num do
        local child_ui_name = "hh_skill_" .. i
        self:CreateSkillUi(child_ui_name, i, nil)
    end
end
----
---创建单个的技能框ui
---
function HH_UI:CreateSkillUi(ui_id, index, skill_id)
    local main_ui = self["hh_main"]
    if not main_ui then
        return
    end
    if not (HH_UTILS:IsHHType(ui_id, "string") and HH_UTILS:IsHHType(index, "number")) then
        return
    end
    local start_x, start_y = 0, 0
    local child_ui_name = ui_id
    main_ui[child_ui_name] = HH_UTILS:HHCreateImageUi(main_ui, white_xml, white_tex, Vector3(start_x + index * (skill_image_size + 10), start_y, 1), skill_image_size, skill_image_size, { 0, 0, 0, 0.5 })
    local child_skill_ui = main_ui[child_ui_name]
    child_skill_ui["hh_str"] = HH_UTILS:HHCreateTextUi(child_skill_ui, Vector3(1.5, 0, 1), "技" .. index, { 1, 1, 1, 1 }, skill_image_size / 2)

    child_skill_ui["hh_fx_anim"] = HH_UTILS:CreateAnimUi(child_skill_ui, "hh_slot_fx", "hh_slot_fx", "idle", true, 0.09)
    child_skill_ui["hh_fx_anim"]:GetAnimState():SetMultColour(255 / 255, 128 / 255, 0 / 255, 1)

end
return HH_UI

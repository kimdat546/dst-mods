local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local main_xml, main_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local main_size_x, main_size_y = 620, 300
local base_offset = 8

local function removeFocusFn(hh_ui)
    hh_ui["OnGainFocus"] = function()
    end
    hh_ui["OnLoseFocus"] = function()
    end
end
local HH_UI = Class(Widget, function(self, owner)
    Widget["_ctor"](self, "hh_job_pet_ui")
    self["owner"] = owner
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self, main_xml, main_tex, Vector3(0, -20, 1), main_size_x, main_size_y, { 0, 0, 0, 0.5 })
    local main_ui = self["hh_main"]
    main_ui["hh_title_a"] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(0, 0, 1), "宝宝栏", { 1, 0, 0, 1 }, 20)
    local hh_title_a_text_x, hh_title_a_text_y = main_ui["hh_title_a"]:GetRegionSize()
    main_ui["hh_title_a"]:SetPosition(-main_size_x / 2 + hh_title_a_text_x / 2 + base_offset, main_size_y / 2 - hh_title_a_text_y / 2 - base_offset, 1)

    main_ui["hh_line"] = HH_UTILS:HHCreateImageUi(main_ui, main_xml, main_tex, Vector3(0, 0, 1), 2, main_size_y, { 1, 1, 0, 1 })
    main_ui["hh_container_text"] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(20, -main_size_y / 2 + 28, 1), "材料", { 1, 0, 0, 1 }, 20)

    self:CreatePetChooseUi()
    self:CreatePetDescUi("pet_1")

end)
local HH_Pet_Config = {
    ["pet_1"] = { ["name"] = "宝宝-猪人", ["bank"] = "pigman", ["build"] = "pig_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    ["pet_2"] = { ["name"] = "宝宝-兔人", ["bank"] = "manrabbit", ["build"] = "manrabbit_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    ["pet_3"] = { ["name"] = "宝宝-鱼人", ["bank"] = "pigman", ["build"] = "merm_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    ["pet_4"] = { ["name"] = "宝宝-海象", ["bank"] = "walrus", ["build"] = "walrus_baby_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    ["pet_5"] = { ["name"] = "宝宝-齿轮骑士", ["bank"] = "knight", ["build"] = "knight_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    ["pet_6"] = { ["name"] = "宝宝-发条主教", ["bank"] = "bishop", ["build"] = "bishop_build", ["anim"] = "idle_loop", ["scale"] = 0.2, },
    --["pet_7"] = { ["name"] = "宝宝-发条战车", ["bank"] = "rook", ["build"] = "rook_rhino", ["anim"] = "idle", ["scale"] = 0.05, },
    ["pet_8"] = { ["name"] = "宝宝-红色猎犬", ["bank"] = "hound", ["build"] = "hound_red_ocean", ["anim"] = "idle", ["scale"] = 0.15, },
    ["pet_9"] = { ["name"] = "宝宝-青蛙", ["bank"] = "frog", ["build"] = "frog", ["anim"] = "idle", ["scale"] = 0.3, },
    ["pet_90"] = { ["name"] = "宝宝-浣猫", ["bank"] = "catcoon", ["build"] = "catcoon_build", ["anim"] = "idle_loop", ["scale"] = 0.3, },
    --["pet_91"] = { ["name"] = "宝宝-洞穴蝙蝠", ["bank"] = "bat", ["build"] = "bat_basic", ["anim"] = "fly_loop", ["scale"] = 0.3, },
    --["pet_92"] = { ["name"] = "宝宝-岩石大白鲨", ["bank"] = "shark", ["build"] = "shark_build", ["anim"] = "idle", ["scale"] = 0.15, },
    --["pet_93"] = { ["name"] = "宝宝-一角鲸", ["bank"] = "gnarwail", ["build"] = "gnarwail_build", ["anim"] = "idle_loop", ["scale"] = 0.15, },
    --["pet_94"] = { ["name"] = "宝宝-高脚鸟", ["bank"] = "tallbird", ["build"] = "DS_tallbird_basic", ["anim"] = "idle", ["scale"] = 0.15, },
    --["pet_95"] = { ["name"] = "宝宝-蜘蛛_15", ["bank"] = "", ["build"] = "", ["anim"] = "", },
    --["pet_96"] = { ["name"] = "宝宝-蜘蛛_16", ["bank"] = "", ["build"] = "", ["anim"] = "", },
    --["pet_97"] = { ["name"] = "宝宝-蜘蛛_17", ["bank"] = "", ["build"] = "", ["anim"] = "", },
    --["pet_98"] = { ["name"] = "宝宝-蜘蛛_18", ["bank"] = "", ["build"] = "", ["anim"] = "", },
}
----
---左边展示全部宝宝ui
---
function HH_UI:CreatePetChooseUi()
    local main_ui = self["hh_main"]
    HH_UTILS:HHKillChild(main_ui, "hh_pet_main")
    local sort_table = HH_UTILS:TableSortKeys(HH_Pet_Config)
    local table_length = #sort_table
    if table_length <= 0 then
        return
    end
    local sub_root = Widget()
    local ui_size_x, ui_size_y = 125, 125
    local start_pos_x, start_pos_y = 0, 0
    local line_num, row_num = 2, math["floor"]((table_length - 1) / 2) + 1
    local pet_ui_size_x, pet_ui_size_y = (line_num - 1 / 2) * (ui_size_x + 20), row_num * (ui_size_y + 20)
    for i = 1, table_length do
        local x_index = i % line_num
        local y_index = math["floor"]((i - 1) / line_num) + 1
        if x_index == 0 then
            x_index = line_num
        end
        local pet_index = sort_table[i]
        local pet_config = HH_Pet_Config[pet_index]
        local child_pos_x, child_pos_y = start_pos_x + (x_index - 1 / 2) * (ui_size_x + 10), start_pos_y - (y_index - 1 / 2) * (ui_size_y + 10)
        --sub_root["hh_pet_" .. i] = HH_UTILS:HHCreateImageUi(sub_root, main_xml, main_tex, Vector3(child_pos_x, child_pos_y, 1), ui_size_x, ui_size_y, { 1, 1, 1, 0.5 })
        sub_root["hh_pet_" .. i] = HH_UTILS:CreateFrameUi(sub_root, Vector3(child_pos_x, child_pos_y, 1),
                { ["size_x"] = 100, ["size_y"] = ui_size_y, ["color"] = { 231 / 255, 195 / 255, 156 / 255, 1 }, },
                { ["size"] = 1.5, ["color"] = { 0, 1, 1, 1 }, })
        if HH_UTILS:IsHHType(pet_config, "table") then
            local pet_ui = sub_root["hh_pet_" .. i]
            pet_ui["hh_text"] = HH_UTILS:HHCreateTextUi(pet_ui, Vector3(0, ui_size_y / 2 - 10, 1), tostring(pet_config["name"]), { 1, 1, 1, 1 }, 15)
            if pet_config["bank"] and pet_config["build"] and pet_config["anim"] then
                local base_scale = 0.25
                if HH_UTILS:IsHHType(pet_config["scale"], "number") then
                    base_scale = pet_config["scale"]
                end
                pet_ui["hh_anim"] = HH_UTILS:CreateAnimUi(pet_ui, tostring(pet_config["bank"]), tostring(pet_config["build"]), tostring(pet_config["anim"]), true, base_scale)
                pet_ui["hh_anim"]:SetPosition(0, -45, 0)
                pet_ui["hh_anim"]:SetFacing(3)
            end
        end
    end

    local sub_w, sub_h = pet_ui_size_x + ui_size_x / 2 - 10, main_size_y - base_offset * 5
    main_ui["hh_pet_main"] = HH_UTILS:CreateTrueScrollArea(main_ui, sub_root, sub_w, sub_h, pet_ui_size_y, 55, 3)
    main_ui["hh_pet_main"]:SetPosition(-main_size_x / 2 + base_offset, -sub_h + 120, 1)
    main_ui["hh_pet_main"]["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    main_ui["hh_pet_main"]["up_button"]:SetScale(0.2)
    main_ui["hh_pet_main"]["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    main_ui["hh_pet_main"]["down_button"]:SetScale(-0.2)
    main_ui["hh_pet_main"]["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    main_ui["hh_pet_main"]["scroll_bar_line"]:SetScale(0.6)
    main_ui["hh_pet_main"]["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    main_ui["hh_pet_main"]["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    main_ui["hh_pet_main"]["position_marker"]:SetScale(0.2)
end
local function addBtnPet(father_ui, ui_name, pos, data)
    if not HH_UTILS:IsHHType(data, "table") then
        data = {}
    end
    father_ui[ui_name] = HH_UTILS:HHCreateImageButton(father_ui, main_xml, main_tex, pos, 10, 3.5,
            { 231 / 255, 195 / 255, 156 / 255, 1 })

    removeFocusFn(father_ui[ui_name])
    father_ui[ui_name]["hh_text"] = HH_UTILS:HHCreateTextUi(father_ui[ui_name], Vector3(0, 0, 1), tostring(data["btn_name"]), { 1, 1, 1, 1 }, 18)
end
----
---创建宠物属性值页面
---
function HH_UI:CreatePetDescUi(pet_id)
    local main_ui = self["hh_main"]
    HH_UTILS:HHKillChild(main_ui, "hh_pet_desc_ui")
    if not HH_Pet_Config[pet_id] then
        return
    end
    main_ui["hh_pet_desc_ui"] = main_ui:AddChild(Widget())
    local father_ui = main_ui["hh_pet_desc_ui"]
    father_ui["hh_pet_test"] = HH_UTILS:CreateInfoUi(father_ui,
            {
                ["name"] = { ["str"] = "猪人(未改名)", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
                ["level"] = { ["str"] = "未读取", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
                ["health"] = { ["str"] = "未读取", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, },
                ["health_absorb"] = { ["str"] = "未读取", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
                ["damage"] = { ["str"] = "未读取", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
                ["effect"] = { ["str"] = "未读取", ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 }, },
            },
            {
                { ["id"] = "name", ["name"] = "名字:", ["scale"] = 20, },
                { ["id"] = "level", ["name"] = "等级:", ["scale"] = 20, },
                { ["id"] = "health", ["name"] = "血量:", ["scale"] = 20, },
                { ["id"] = "health_absorb", ["name"] = "免伤:", ["scale"] = 20, },
                { ["id"] = "damage", ["name"] = "伤害:", ["scale"] = 20, },
                { ["id"] = "effect", ["name"] = "词条:", ["scale"] = 20, },
            })
    father_ui["hh_pet_test"]:SetPosition(base_offset, main_size_y / 2 - base_offset, 1)

    father_ui["hh_change_name_btn"] = HH_UTILS:HHCreateImageButton(father_ui, main_xml, main_tex, Vector3(main_size_x / 2 - 180, main_size_y / 2 - base_offset * 2, 1), 2.5, 2.5,
            { 231 / 255, 195 / 255, 156 / 255, 1 })
    removeFocusFn(father_ui["hh_change_name_btn"])
    father_ui["hh_change_name_btn"]["hh_text"] = HH_UTILS:HHCreateTextUi(father_ui["hh_change_name_btn"], Vector3(1, 0, 1), "改", { 1, 1, 1, 1 }, 18)
    addBtnPet(father_ui, "hh_pet_health", Vector3(50, -30, 1), { ["btn_name"] = "提升血量", })
    addBtnPet(father_ui, "hh_pet_health_absorb", Vector3(150, -30, 1), { ["btn_name"] = "提升免伤", })
    addBtnPet(father_ui, "hh_pet_damage", Vector3(50, -60, 1), { ["btn_name"] = "提升伤害", })
end
return HH_UI
local HH_UTILS = require("utils/hh_utils")
local hoverer_text_config = GetModConfigData("hoverer_text")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local HH_SUIT_CONFIG = HH_CONFIG["HH_SUIT_LIST"]
local containers = require("containers")
local params = {}
local offset_y = -17
local offset_x = 0
local hh_container_button = {
    ["hh_cat_box"] = {
        ["button_fn"] = function(inst, doer)
            --print("盒子")
            local container_components = inst["components"]["container"]
            local slot_num = container_components:GetNumSlots()
            --print("格子数量", slot_num)
            local spawn_num = 0
            local tip_num = 0
            local remove_stone_num = 0

            --通用词条库
            local comEffectList = HHGetComEquipEffect()
            --先删除 后分发
            for i = 1, slot_num do
                local add_num = 0
                local hh_slot_item = container_components:GetItemInSlot(i)
                if hh_slot_item and hh_slot_item["prefab"] == "hh_effect_stone" then
                    local effect_id = hh_slot_item["hh_effect"]
                    if effect_id == nil or table["contains"](comEffectList, effect_id) then
                        add_num = 1
                    else
                        add_num = 5
                    end
                    hh_slot_item:Remove()
                    remove_stone_num = remove_stone_num + 1
                end
                spawn_num = spawn_num + add_num
            end
            if spawn_num <= 0 then
                HH_UTILS:HHSay(doer, "未查询到有效附魔石")
                return
            end
            tip_num = spawn_num
            local hh_essence_max_size = TUNING["STACK_SIZE_PELLET"]
            repeat
                local result_item = SpawnPrefab("hh_essence")
                if spawn_num <= hh_essence_max_size then
                    result_item["components"]["stackable"]:SetStackSize(math["max"](spawn_num, 1))
                else
                    result_item["components"]["stackable"]:SetStackSize(hh_essence_max_size)
                end
                spawn_num = spawn_num - hh_essence_max_size
                --容器满了直接发给玩家
                if inst["components"]["container"]:IsFull() then
                    doer["components"]["inventory"]:GiveItem(result_item)
                else
                    local cook_pos = inst:GetPosition()
                    inst["components"]["container"]:GiveItem(result_item, nil, cook_pos)
                end
            until spawn_num <= 0
            --inst["SoundEmitter"]:PlaySound("dontstarve/wilson/equip_item_gold")

            HH_UTILS:HHSay(doer, string["format"]("消耗%s个附魔石,最终转换个数:%s", remove_stone_num, tip_num))
            --HH_UTILS:HHPrint(container_components["slots"])
        end
    },
    ["hh_duck_box"] = {
        ["button_fn"] = function(inst, doer)
            --print("盒子")
            local container_components = inst["components"]["container"]
            local hh_slot_item = container_components:GetItemInSlot(1)
            if hh_slot_item and HH_UTILS:HasComponents(hh_slot_item, "tradable") then
                local tradable_com = hh_slot_item["components"]["tradable"]
                if HH_UTILS:IsHHType(tradable_com["goldvalue"], "number") and tradable_com["goldvalue"] > 0 then
                    local gold_num = tradable_com["goldvalue"]
                    local spawn_gold_num = gold_num
                    if HH_UTILS:HasComponents(hh_slot_item, "stackable") then
                        local current_num = hh_slot_item["components"]["stackable"]:StackSize()
                        --print("数量", spawn_gold_num, current_num)
                        if HH_UTILS:IsHHType(current_num, "number") and current_num > 0 then
                            spawn_gold_num = current_num * gold_num
                        end
                    end
                    hh_slot_item:Remove()
                    local spawn_gold = SpawnPrefab("goldnugget")
                    if spawn_gold and HH_UTILS:HasComponents(spawn_gold, "stackable") then
                        local box_pos = inst:GetPosition()
                        spawn_gold["components"]["stackable"]:SetStackSize(spawn_gold_num)
                        inst["components"]["container"]:GiveItem(spawn_gold, nil, box_pos)
                        HH_UTILS:HHSay(doer, string["format"]("转换金子:%s", tostring(spawn_gold_num)))
                    end
                    return
                end
            end
            --容器物品掉落
            --container_components:DropEverything()
            HH_UTILS:HHSay(doer, "请放入可以交易金子的道具")
        end
    },

}
---PressButton
---@param inst table
---@param doer table
local function PressButton(inst, doer)
    if HH_UTILS:HasComponents(inst, "container") then
        if hh_container_button[inst["prefab"]] and hh_container_button[inst["prefab"]]["button_fn"] then
            hh_container_button[inst["prefab"]]["button_fn"](inst, doer)
        end
    elseif HH_UTILS:HasReplica(inst, "container") then
        SendRPCToServer(RPC["DoWidgetButtonAction"], nil, inst, nil)
    end
end
----
---整理按钮亮起规则
---@param inst
---
local function slotsSortValidFn(inst)
    return inst["replica"]["container"] ~= nil and not inst["replica"]["container"]:IsEmpty()--容器不为空
end
----强化装备容器
params["hh_ui_container"] = {
    ["widget"] = {
        ["slotpos"] = {
            Vector3(-247 + 4 * 0 + offset_x, 180 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, 180 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, 180 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, 180 + offset_y, 0),

            Vector3(-247 + 4 * 0 + offset_x, 125 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, 125 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, 125 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, 125 + offset_y, 0),

            Vector3(-247 + 4 * 0 + offset_x, 70 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, 70 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, 70 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, 70 + offset_y, 0),

            Vector3(-247 + 4 * 0 + offset_x, 15 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, 15 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, 15 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, 15 + offset_y, 0),

            Vector3(-247 + 4 * 0 + offset_x, -40 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, -40 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, -40 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, -40 + offset_y, 0),

            Vector3(-247 + 4 * 0 + offset_x, -95 + offset_y, 0),
            Vector3(-202 + 4 * 2 + offset_x, -95 + offset_y, 0),
            Vector3(-157 + 4 * 4 + offset_x, -95 + offset_y, 0),
            Vector3(-112 + 4 * 6 + offset_x, -95 + offset_y, 0),

            Vector3(10 + offset_x, 170 + offset_y, 0),
            Vector3(60 + offset_x, 170 + offset_y, 0),
            Vector3(110 + offset_x, 170 + offset_y, 0),


            Vector3(250 + offset_x, 10 + offset_y, 0),
        },
        ["slotbg"] = { },
        ["pos"] = Vector3(0, 0, 0),
    },
    --acceptsstacks = false,
    --usespecificslotsforitems = true,
    ["type"] = "chest",
}
--for i = 1, 28 do
--    table["insert"](params["hh_ui_container"]["widget"]["slotbg"], { ["atlas"] = "images/hh_icon/hh_slot.xml", ["image"] = "hh_slot.tex" })
--end

params["hh_ui_container"]["itemtestfn"] = function(container, item, slot)
    --print(item, slot)
    local hh_bool = false
    if slot then
        if slot <= 24 then
            hh_bool = (item["replica"] and item["replica"]["equippable"] and item:HasTag("hh_equip")) or item:HasTag("hh_add_stone") or item:HasTag("hh_remove_stone")
        elseif slot == 25 then
            hh_bool = item:HasTag("hh_equip")
        elseif slot == 26 then
            hh_bool = item:HasTag("hh_add_stone")
        elseif slot == 27 then
            hh_bool = item:HasTag("hh_remove_stone")
        else
            hh_bool = item:HasTag("hh_equip")
        end
    else
        hh_bool = (item["replica"] and item["replica"]["equippable"] and item:HasTag("hh_equip")) or item:HasTag("hh_add_stone") or item:HasTag("hh_remove_stone")
    end
    return hh_bool
end

local forge_offset_x = 60
local forge_start_x = 0
local forge_start_y = 10
params["hh_forge_container"] = {
    widget = {
        slotpos = {
            Vector3(-250, 150, 0),
            ----合成套装部分
            Vector3(forge_start_x - forge_offset_x * 3, forge_start_y, 0),
            Vector3(forge_start_x - forge_offset_x * 2, forge_start_y, 0),
            Vector3(forge_start_x - forge_offset_x, forge_start_y, 0),
            Vector3(forge_start_x, forge_start_y, 0),
            Vector3(forge_start_x + forge_offset_x, forge_start_y, 0),
            Vector3(forge_start_x + forge_offset_x * 2, forge_start_y, 0),
            Vector3(forge_start_x + forge_offset_x * 3, forge_start_y, 0),
        },
        slotbg = {},
        pos = Vector3(0, 0, 0),
    },
    --acceptsstacks = false,
    type = "chest",
}
params["hh_forge_container"]["itemtestfn"] = function(container, item, slot)
    --if not slot then
    --    return false
    --end
    --if slot == 1 then
    --    return item["replica"] and item["replica"]["equippable"] and item:HasTag("hh_equip")
    --else
    --    if item["replica"] then
    --        return not item["replica"]["container"]
    --    end
    --    return true
    --end
    return true
end
----
---合成台的格子位置
---
local hh_forge_type_pos = {
    -----------------下面移除------------------------
    ["suit_pos"] = {},
    ["effect_compose"] = {},
    -----------------上面移除------------------------
    ["stone_change"] = {
        Vector3(-150, -10, 0),
        Vector3(-220, -65, 0),
        Vector3(-150, -65, 0),
        Vector3(-80, -65, 0),
        Vector3(-220, -120, 0),
        Vector3(-150, -120, 0),
        Vector3(-80, -120, 0),
    },
    ["equip_inherit"] = {
        Vector3(-220, -10, 0),
        Vector3(-100, -10, 0),
        Vector3(-260, -85, 0),
        Vector3(-200, -85, 0),
        Vector3(-140, -85, 0),
        Vector3(-80, -85, 0),
        Vector3(-20, -85, 0),
    },
    ["equip_upgrading"] = {
        Vector3(-150, -10, 0),
        Vector3(-220, -65, 0),
        Vector3(-150, -65, 0),
        Vector3(-80, -65, 0),
        Vector3(-185, -120, 0),
        Vector3(-115, -120, 0),
        Vector3(-10, -120, 0),
    },
}
params["hh_cat_box"] = {
    ["widget"] = {
        ["slotpos"] = {},
        ["animbank"] = "ui_bookstation_4x5",
        ["animbuild"] = "ui_bookstation_4x5",
        ["pos"] = Vector3(-200, 100, 0),
        ["side_align_tip"] = 160,
        ["buttoninfo"] = {
            ["text"] = "拆解",
            ["position"] = Vector3(0, -350, 0),
            ["fn"] = PressButton,
            ["validfn"] = slotsSortValidFn,
        }
    },
    ["type"] = "hh_cat_box",
}
for y = 0, 4 do
    table["insert"](params["hh_cat_box"]["widget"]["slotpos"], Vector3(-114, (-77 * y) + 37 - (y * 2), 0))
    table["insert"](params["hh_cat_box"]["widget"]["slotpos"], Vector3(-114 + 75, (-77 * y) + 37 - (y * 2), 0))
    table["insert"](params["hh_cat_box"]["widget"]["slotpos"], Vector3(-114 + 150, (-77 * y) + 37 - (y * 2), 0))
    table["insert"](params["hh_cat_box"]["widget"]["slotpos"], Vector3(-114 + 225, (-77 * y) + 37 - (y * 2), 0))
end

local cat_item_config = {
    ["hh_remove_stone"] = true, --洗蕴石
    ["hh_effect_tally"] = true, --卷轴
    ["hh_effect_stone"] = true, --附魔石
    ["hh_essence"] = true, --水晶小人
}
params["hh_cat_box"]["itemtestfn"] = function(container, item, slot)
    return item and (cat_item_config[item["prefab"]]
            or item:HasTag("hh_equip")
            or item:HasTag("hh_egg")
    ) or false
end
params["hh_duck_box"] = {
    ["widget"] = {
        ["slotpos"] = {
            Vector3(-2, 18, 0),
        },
        ["slotbg"] = {
            { ["image"] = "yotb_sewing_slot.tex", ["atlas"] = "images/hud2.xml" },
        },
        ["animbank"] = "ui_alterguardianhat_1x1",
        ["animbuild"] = "ui_alterguardianhat_1x1",
        ["pos"] = Vector3(0, -100, 0),
        ["side_align_tip"] = 160,
        ["buttoninfo"] = {
            ["text"] = "转换",
            ["position"] = Vector3(0, -40, 0),
            ["fn"] = PressButton,
            ["validfn"] = slotsSortValidFn,
        },
        ["hh_extra_btn"] = {
            {
                ["text"] = "转换金子",
                ["pos"] = Vector3(-200, -100, 0),
                ["fn_index"] = "test_01",
                --按钮贴图
                ["xml"] = "images/inventoryimages.xml",
                ["tex"] = "halloweenpotion_health_large.tex",
                ["focus_tex"] = "baconeggs.tex", --鼠标聚焦时候的图片 可不填 与text相同则聚焦缩放ui(官方)
                ["check_fn"] = function()
                    return false
                end,
            },
            {
                ["text"] = "转换沙石",
                ["pos"] = Vector3(-100, -100, 0),
                ["fn_index"] = "test_02",
                ["check_fn"] = function()
                    return false
                end,
            },
            {
                ["text"] = "ccc",
                ["pos"] = Vector3(0, -100, 0),
                ["fn_index"] = "test_03",
                ["check_fn"] = function()
                    return false
                end,
            },
            {
                ["text"] = "ddd",
                ["pos"] = Vector3(100, -100, 0),
                ["fn_index"] = "fn",
                ["check_fn"] = function()
                    return false
                end,
            },
        },
    },
    ["type"] = "hh_duck_box",
}

params["hh_duck_box"]["itemtestfn"] = function(container, item, slot)
    if item and item["replica"] then
        return not item["replica"]["container"]
    end
    return true
end
--拆除法杖配置
local staff_item_config = {
    ["hh_remove_stone"] = true, --洗蕴石
    ["hh_effect_tally"] = true, --卷轴
    ["hh_effect_stone"] = true, --附魔石
    ["gears"] = true, --齿轮
    ["horn"] = true, --牛角
    ["greengem"] = true, --绿宝石
    ["walrus_tusk"] = true, --海象牙
    ["redgem"] = true, --红宝石
    ["lightninggoathorn"] = true, --电羊角
    ["silk"] = true, --蜘蛛丝
    ["stinger"] = true, --蜂刺
    ["townportaltalisman"] = true, --沙之石
    ["steelwool"] = true, --刚羊毛
    ["dragon_scales"] = true, --龙蝇皮
    ["minotaurhorn"] = true, --犀牛角
    ["deerclops_eyeball"] = true, --巨鹿眼球
}
params["hh_staff_dis"] = {
    ["widget"] = {
        ["slotpos"] = {
            Vector3(-2, 18, 0),
        },
        ["slotbg"] = {
            { ["image"] = "spore_slot.tex", ["atlas"] = "images/hud2.xml" },
        },
        ["animbank"] = "ui_alterguardianhat_1x1",
        ["animbuild"] = "ui_alterguardianhat_1x1",
        ["pos"] = Vector3(250, -350, 0),
        ["side_align_tip"] = 160,
    },
    ["type"] = "hh_staff_dis",
    ["excludefromcrafting"] = true,
}
params["hh_staff_dis"]["itemtestfn"] = function(container, item, slot)
    return item and staff_item_config[item["prefab"]] or false
end
-----------------------------------------------------------------------------
params["hh_egg_exhibition_table"] = {
    widget = {
        ["slotpos"] = {
            Vector3(-2, 18, 0),
        },
        ["animbank"] = "ui_chest_1x1",
        ["animbuild"] = "ui_chest_1x1",
        ["pos"] = Vector3(0, 160, 0),
        ["side_align_tip"] = 100,
    },
    ["type"] = "chest",
}
params["hh_egg_exhibition_table"]["itemtestfn"] = function(container, item, slot)
    return item and item:HasTag("hh_egg")
end
-----------------------------------------------------------------------------
for k, v in pairs(params) do
    containers["MAXITEMSLOTS"] = math["max"](containers["MAXITEMSLOTS"], v["widget"]["slotpos"] ~= nil and #v["widget"]["slotpos"] or 0)
end
local containers_widgetsetup = containers["widgetsetup"]

function containers.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container["inst"]["prefab"]]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container["widget"]["slotpos"] ~= nil and #container["widget"]["slotpos"] or 0)
    else
        return containers_widgetsetup(container, prefab, data)
    end
end

local function removeTrailingWhitespace(str)
    -- 使用gsub替换末尾的所有空白字符为空字符串
    local result = string["gsub"](str, "%s+$", "")
    return result
end
local Image = require("widgets/image")
local hh_hoverer = require("widgets/hh_hoverer")
local HH_BUFF_UI = require("widgets/hh_buff")
local HH_HOVERER_CONFIG = require("widgets/hh_hoverer_config")
local HH_HELP_UI = require("widgets/hh_help_ui")
AddClassPostConstruct("widgets/controls", function(self, owner)
    self["hh_com_buff"] = self:AddChild(HH_BUFF_UI(self["owner"]))
    self["hh_com_buff"]:SetPosition(250, -50)
    --毒素显示页面 2025-03-13移除
    --self["inst"]:ListenForEvent("hh_poison_ui", function(inst, data)
    --    HH_UTILS:HHKillChild(self, "hh_poison_ui")
    --    self["hh_poison_ui"] = self:AddChild(Image("images/fx2.xml", "fume_over.tex"))
    --    self["hh_poison_ui"]:SetVRegPoint(ANCHOR_MIDDLE)
    --    self["hh_poison_ui"]:SetHRegPoint(ANCHOR_MIDDLE)
    --    self["hh_poison_ui"]:SetVAnchor(ANCHOR_MIDDLE)
    --    self["hh_poison_ui"]:SetHAnchor(ANCHOR_MIDDLE)
    --    self["hh_poison_ui"]:SetScaleMode(SCALEMODE_FILLSCREEN)
    --    self["hh_poison_ui"]:SetTint(1, 1, 1, 0.3)
    --    self["hh_poison_ui"]:SetClickable(false)
    --    self["hh_poison_ui"]:TintTo({ ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 0.3 }, { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 0 }, 4, function()
    --        HH_UTILS:HHKillChild(self, "hh_poison_ui")
    --    end)
    --end, self["owner"])
    --黑名单
    self["inst"]:ListenForEvent("hh_black_player", function(inst, data)
        HH_UTILS:HHKillChild(self, "hh_black_ui")
        self["hh_black_ui"] = self:AddChild(Image("images/fx2.xml", "fume_over.tex"))
        self["hh_black_ui"]:SetVRegPoint(ANCHOR_MIDDLE)
        self["hh_black_ui"]:SetHRegPoint(ANCHOR_MIDDLE)
        self["hh_black_ui"]:SetVAnchor(ANCHOR_MIDDLE)
        self["hh_black_ui"]:SetHAnchor(ANCHOR_MIDDLE)
        self["hh_black_ui"]:SetScaleMode(SCALEMODE_FILLSCREEN)
        self["hh_black_ui"]:SetTint(0, 0, 0, 1)
        local black_str = HH_UTILS:GetClientValue(self["owner"], "hh_black_player")
        self["hh_black_ui"]["hh_str"] = HH_UTILS:HHCreateTextUi(self["hh_black_ui"], Vector3(0, 100, 1), tostring(black_str), nil, 40)
        self["hh_black_ui"]["hh_button"] = HH_UTILS:HHCreateImageButton(self["hh_black_ui"], "images/hh_icon/hh_white.xml", "hh_white.tex", Vector3(0, -100, 1), 10, 5, { 231 / 255, 195 / 255, 156 / 255, 1 })
        self["hh_black_ui"]["hh_button"]["hh_str"] = HH_UTILS:HHCreateTextUi(self["hh_black_ui"]["hh_button"], Vector3(0, 0, 1), "退出", nil, 30)
        self["hh_black_ui"]["hh_button"]["hh_str"]:SetClickable(false)
        self["hh_black_ui"]["hh_button"]:SetOnClick(function()
            DoRestart(true)
        end)
        HH_UTILS:ExitGame(10)
    end, self["owner"])
    --面板配置页面
    self["hh_hoverer_config"] = self:AddChild(HH_HOVERER_CONFIG(self["owner"]))
    self["hh_help_ui"] = self:AddChild(HH_HELP_UI(self["owner"]))
end)
local function getInputItem()
    local target = TheInput:GetHUDEntityUnderMouse()
    target = (target and target["widget"] and target["widget"]["parent"] ~= nil
            and target["widget"]["parent"]["item"])
            or TheInput:GetWorldEntityUnderMouse() or nil
    return target
end
local function hh_hoverer_fn(self)
    self["hh_hoverer"] = self:AddChild(hh_hoverer(self["owner"]))
    local oldOnUpdate = self["OnUpdate"]
    self["OnUpdate"] = function(self, ...)
        oldOnUpdate(self, ...)
        if self["hh_hoverer"] and self["hh_hoverer"]["SetTargetName"] then
            if self["text"] and self["text"]["Hide"] then
                if self["text"]["shown"] then
                    local target_name = "名字"
                    if self["hh_hoverer"]["hh_main"] and self["hh_hoverer"]["hh_main"]["shown"] and hoverer_text_config then
                        self["text"]:Hide()
                    end
                    if self["text"]["GetString"] then
                        target_name = removeTrailingWhitespace(tostring(self["text"]:GetString()))
                    end
                    if self["secondarytext"] and self["secondarytext"]["Hide"] and self["secondarystr"] then
                        local hh_name_second = tostring(self["secondarystr"])
                        target_name = target_name .. "\n" .. removeTrailingWhitespace(hh_name_second)
                        if self["hh_hoverer"]["hh_main"] and self["hh_hoverer"]["hh_main"]["shown"] and hoverer_text_config then
                            self["secondarytext"]:Hide()
                        end
                    end
                    self["hh_hoverer"]:SetTargetName(target_name)
                end
            end
        end
    end
end
AddClassPostConstruct("widgets/hoverer", hh_hoverer_fn)

local can_show_equip_config = GetModConfigData("can_show_equip")
local function fuck_item(self)
    --女武神物品被覆盖ui导致物品获取不到
    if self["image"] and self["image"]["itemtile_lightning"] then
        HH_UTILS:HHKillChild(self["image"], "itemtile_lightning")
    end
    if self["item"] and self["item"]["prefab"] and self["item"]["prefab"] == "hh_effect_stone" and self["item"]["hh_client_effect"] then
        local client_effect_hh = self["item"]["hh_client_effect"]:value()
        --print(client_effect_hh)
        if HH_EQUIP_BUFF_LIST[client_effect_hh] then
            local effect_config = HH_EQUIP_BUFF_LIST[client_effect_hh]
            if effect_config["client_text"] then
                local effect_str = effect_config["client_text"]
                self["hh_effect_text"] = HH_UTILS:HHCreateTextUi(self, Vector3(0, 0, 1), tostring(effect_str), { 1, 1, 1, 1 }, 40, true)
                local hh_effect_text_size_x, hh_effect_text_size_y = self["hh_effect_text"]:GetRegionSize()
                self["hh_effect_text"]:SetPosition(-32 + hh_effect_text_size_x / 2, -32 + hh_effect_text_size_y / 2, 0)
                self["hh_effect_text"]:SetClickable(false)
            end
            local image_color = { 128 / 255, 138 / 255, 135 / 255, 1 }
            if effect_config["client_color"] then
                image_color = effect_config["client_color"]
            elseif not effect_config["can_add"] and not effect_config["is_suit"] then
                image_color = { 255 / 255, 97 / 255, 0 / 255, 1 }
            end
            --套装石头增加背景
            self["hh_suit_ui"] = HH_UTILS:HHCreateImageUi(self, "images/hh_icon/hh_status.xml", "hh_status.tex", Vector3(0, 0, 1), 64, 64, image_color)
            self["hh_suit_ui"]:SetClickable(false)
            self["hh_suit_ui"]:MoveToBack()
            --加上边框特效
            self["hh_fx_anim"] = HH_UTILS:CreateAnimUi(self, "hh_slot_fx", "hh_slot_fx", "idle", true, 0.17)
            if HH_UTILS:IsHHType(image_color, "table") then
                self["hh_fx_anim"]:GetAnimState():SetMultColour(unpack(image_color))
            end
            self["hh_fx_anim"]:MoveToBack()
            self["hh_fx_anim"]:SetClickable(false)
            local oldStartDrag = self["StartDrag"]
            self["StartDrag"] = function(...)
                if HH_UTILS:HasReplica(self["item"], "inventoryitem") then
                    if self["hh_suit_ui"] then
                        HH_UTILS:HHKillChild(self, "hh_suit_ui")
                    end
                    if self["hh_fx_anim"] then
                        HH_UTILS:HHKillChild(self, "hh_fx_anim")
                    end
                end
                if oldStartDrag then
                    oldStartDrag(...)
                end
            end
        end
    end
    local oldOnControl = self["OnControl"]
    self["OnControl"] = function(hh_self, control, down, ...)
        if control == CONTROL_ACCEPT
                and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
                and TheInput:IsControlPressed(CONTROL_FORCE_TRADE)
                and self["item"] and (self["item"]:HasTag("hh_equip")
                or self["item"]["prefab"] == "hh_effect_stone"
                or self["item"]["prefab"] == "hh_job_card"
        ) then
            if can_show_equip_config then
                SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_share_equip"], self["item"])
            end
        end
        return oldOnControl(hh_self, control, down, ...)
    end
    --星级装备修复这边要把耐久隐藏
    local oldSetPercent = self["SetPercent"]
    self["SetPercent"] = function(_self, ...)
        if _self["item"] and _self["item"]:HasTag("hh_boss_equip") and _self["item"]:HasTag("hide_percentage") then
            if HH_UTILS:IsHHType(_self["percent"], "table") and _self["percent"]["Hide"] then
                _self["percent"]:Hide()
            end
        end
        oldSetPercent(_self, ...)
    end
end
AddClassPostConstruct("widgets/itemtile", fuck_item)

local function fuck_equip(self)
    if can_show_equip_config then
        local oldOnControl = self["OnControl"]
        self["OnControl"] = function(hh_self, control, down, ...)
            if control == CONTROL_ACCEPT
                    and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
                    and TheInput:IsControlPressed(CONTROL_FORCE_TRADE)
            then
                if self["tile"] and self["tile"]["item"] and self["tile"]["item"]:HasTag("hh_equip") then
                    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_share_equip"], self["tile"]["item"])
                end
            end
            return oldOnControl(hh_self, control, down, ...)
        end
    end
end
AddClassPostConstruct("widgets/equipslot", fuck_equip)

local hh_equip_ui_file = require("widgets/hh_ui/hh_equip_ui")
local hh_forge_ui_file = require("widgets/hh_ui/hh_forge_ui")
local hh_ui_list = {
    ["hh_ui_container"] = { ["ui"] = hh_equip_ui_file, ["ui_id"] = "hh_equip_ui", },
    ["hh_forge_container"] = { ["ui"] = hh_forge_ui_file, ["ui_id"] = "hh_equip_ui", ["scale"] = 0.7, },
}
local function handleContainer(self, owner)
    local oldOpen = self["Open"]
    self["Open"] = function(self, ...)
        oldOpen(self, ...)
        if HH_UTILS:HasReplica(self["container"], "container")
                and HH_UTILS:IsHHType(hh_ui_list[self["container"]["prefab"]], "table")
                and hh_ui_list[self["container"]["prefab"]]["ui"]
                and hh_ui_list[self["container"]["prefab"]]["ui_id"]
        then
            local container_prefab = self["container"]["prefab"]
            local ui_father = hh_ui_list[container_prefab]["ui"]
            local ui_name = hh_ui_list[container_prefab]["ui_id"]
            local slot_scale = hh_ui_list[container_prefab]["scale"] or 0.5
            self:SetVAnchor(ANCHOR_MIDDLE)
            self:SetHAnchor(ANCHOR_MIDDLE)
            self:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self[ui_name] = self:AddChild(ui_father(self["owner"], self["container"]))
            self[ui_name]:MoveToBack()
            if self["inv"] and HH_UTILS:IsHHType(self["inv"], "table") then
                for i, v in ipairs(self["inv"]) do
                    if self["inv"][i] and self["inv"][i]["SetScale"] then
                        local base_scale = slot_scale
                        if container_prefab == "hh_ui_container" and HH_UTILS:IsHHType(i, "number") and (i <= 24) then
                            base_scale = 0.6
                        end
                        --防止快捷键打开初始状态太大 官方默认是有刷新任务的
                        if self["inv"][i]["ScaleTo"] then
                            self["inv"][i]:ScaleTo(base_scale * 0.5, base_scale, 0.125)
                        end
                        self["inv"][i]:SetScale(base_scale)
                        --if self["inv"][i]["bgimage"] and self["inv"][i]["bgimage"]["SetTint"] then
                        --    self["inv"][i]["bgimage"]:SetTint(1, 1, 1, 0)
                        --end
                        --修复图标变大bug
                        self["inv"][i]["OnGainFocus"] = function(obj)
                            self["inv"][i]:SetScale(base_scale)
                        end
                        self["inv"][i]["OnLoseFocus"] = function(obj)
                            self["inv"][i]:SetScale(base_scale)
                        end
                    end
                end
            end
        end
    end
    local oldClose = self["Close"]
    self["Close"] = function(self, ...)
        if HH_UTILS:HasReplica(self["container"], "container")
                and HH_UTILS:IsHHType(hh_ui_list[self["container"]["prefab"]], "table")
                and hh_ui_list[self["container"]["prefab"]]["ui"]
                and hh_ui_list[self["container"]["prefab"]]["ui_id"]
        then
            local ui_name = hh_ui_list[self["container"]["prefab"]]["ui_id"]
            HH_UTILS:HHKillChild(self, ui_name)
        end
        oldClose(self, ...)
    end
    --合成台容器增加监听用于格子移动
    self["inst"]:ListenForEvent("hh_forge_slot_change", function(inst, data)
        if HH_UTILS:HasReplica(self["container"], "container")
                and self["container"]["prefab"] == "hh_forge_container"
        then
            local hh_slot_type = HH_UTILS:GetClientValue(self["owner"], "hh_forge_slot_change")
            --print("更改合成台坐标", hh_slot_type)
            if hh_slot_type and hh_forge_type_pos[hh_slot_type]
                    and self["inv"] and HH_UTILS:IsHHType(self["inv"], "table")
            then
                for i, v in ipairs(hh_forge_type_pos[hh_slot_type]) do
                    --从2开始 1为清除词条栏
                    local hh_index = i + 1
                    if v and self["inv"][hh_index] and self["inv"][hh_index]["MoveTo"] then
                        self["inv"][hh_index]:MoveTo({ ["x"] = -130, ["y"] = -30, ["z"] = 0 }, v, 0.3)
                    end
                end
            end
        end
    end, self["owner"])

end
AddClassPostConstruct("widgets/containerwidget", handleContainer)
------------------------------------------展示装备页面--------------------------------------------------
local HH_WARING_UI = require("widgets/hh_waring_ui")
local HH_ANNOUNCE = require("widgets/hh_announce")
AddClassPostConstruct("widgets/controls", function(self, owner)
    self["hh_announce_ui"] = self:AddChild(HH_ANNOUNCE(self["owner"]))
    self["hh_announce_ui"]:MoveToBack()
    --左下角提示按钮
    self["hh_waring_ui"] = self:AddChild(HH_WARING_UI(self["owner"]))
end)
------------------------------------------展示装备页面--------------------------------------------------
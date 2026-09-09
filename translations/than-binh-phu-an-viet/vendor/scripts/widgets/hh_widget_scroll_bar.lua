----
---滚动条组件
---
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local HH_UTILS = require("utils/hh_utils")
----
---child_fn
---@param father_ui：每一行总ui
---@param child_ui：每一行的子ui 一行一个
---@param hh_ui_index：该行的索引 用于兼容单行多个ui集合
---@param higher_ui：继承上级父类-需要非空判断
---
local function child_fn(father_ui, child_ui, hh_ui_index, higher_ui)
    if not child_ui or not father_ui then
        return
    end
    if not child_ui["hh_weight"] or not child_ui["hh_height"]
            or not father_ui["hh_weight"] or not father_ui["hh_height"]
    then
        return
    end
    local child_size_x, child_size_y = child_ui["hh_weight"], child_ui["hh_height"]
    local father_size_x, father_size_y = father_ui["hh_weight"], father_ui["hh_height"]
    --print("子ui方法")
    HH_UTILS:UiAddFocusStr(father_ui, "")
    child_ui["hh_fn_ui"] = HH_UTILS:HHCreateImageUi(child_ui, "images/global.xml", "square.tex", Vector3(0, 0, 1), child_size_x, child_size_y)
    child_ui["hh_fn_ui"]:MoveToBack()
end
--scroll_data 模板案例
local test_data = {
    --主背景
    ["main_xml"] = "images/global.xml",
    ["main_tex"] = "square.tex",
    --关闭按钮 必须有才会创建
    ["close_xml"] = "images/global.xml",
    ["close_tex"] = "square.tex",
    --按钮大小
    ["close_scale"] = 1,
    --关闭按钮偏移(x,y一样)
    ["close_offset_pos"] = -50,
    --ui的长宽
    ["main_size"] = { ["weight"] = 300, ["height"] = 300, },
    --背景颜色
    ["main_color"] = { 1, 1, 1, 0.5 },
    --每一页展示的ui数量
    ["num_slot"] = 5,
    --隐藏上下箭头
    --["hide_arrow_btn"] = true,
    --显示索引文字
    ["show_index"] = true,
    --滚动条相关配置
    ["schedule_data"] = {
        ["bar_xml"] = "images/hh_icon/hh_log.xml",
        ["bar_tex"] = "default.tex",
        ["bar_size_x"] = 30,
        ["bar_size_y"] = 30,
        ["bar_color"] = { 1, 219 / 255, 0, 1 },

    },
    --ui配置
    ["ui_table"] = {
        --文字类型
        { ["ui_type"] = "text_ui", ["color"] = { 1, 1, 1, 1 }, ["scale"] = 30, ["child_fn"] = child_fn, ["str"] = "111", },
        --图片类型
        { ["ui_type"] = "image_ui", ["color"] = { 1, 1, 1, 1 }, ["size_x"] = 50, ["size_y"] = 50, ["child_fn"] = child_fn, ["xml"] = "images/inventoryimages.xml", ["tex"] = "amulet.tex", },
    },
}
----
---获取鼠标坐标
---
local function getInputPos()
    return TheSim:GetScreenPos(TheInput:GetWorldPosition():Get())
end
local HH_UI = Class(Widget, function(self, scroll_data)
    Widget["_ctor"](self, "ovo_scroll_bar")
    local main_size_x, main_size_y = 200, 200
    local main_ui_color = { 0, 0, 0, 0.5 }
    self["hh_index"] = 1--当前第一个ui的索引
    self["hh_ui_num"] = 1--当前页数最大的ui数量 每个ui需要y轴高度相同 不然ui面板尺寸错乱
    self["hh_ui_config"] = {}--所有ui的配置
    if not HH_UTILS:IsHHType(scroll_data, "table") then
        scroll_data = {}
    end
    --------------------------------------导入配置----------------------------------------------
    self["hh_ui_num"] = scroll_data["num_slot"] or 1
    self["hh_ui_config"] = scroll_data["ui_table"] or {}
    --总ui大小
    if scroll_data["main_size"] then
        main_size_x, main_size_y = scroll_data["main_size"]["weight"], scroll_data["main_size"]["height"]
    end
    --总ui背景
    if scroll_data["main_color"] then
        main_ui_color = scroll_data["main_color"]
    end
    --------------------------------------导入配置----------------------------------------------
    --滑轮背景
    local main_xml, main_tex = scroll_data["main_xml"] or "images/global.xml", scroll_data["main_tex"] or "square.tex"
    self["hh_main_ui"] = HH_UTILS:HHCreateImageUi(self, main_xml, main_tex, Vector3(0, 0, 1), main_size_x, main_size_y, main_ui_color)
    --上下增加箭头图标
    local btn_offset = 64--上下偏移 默认是上下的边界
    self["hh_up_button"] = HH_UTILS:HHCreateImageButton(self, "images/global.xml", "square.tex", Vector3(0, main_size_y / 2 + btn_offset, 1))
    self["hh_up_button"]:SetOnClick(function()
        self:ScrollUpAndDown(true)
    end)
    self["hh_down_button"] = HH_UTILS:HHCreateImageButton(self, "images/global.xml", "square.tex", Vector3(0, -main_size_y / 2 - btn_offset, 1))
    self["hh_down_button"]:SetOnClick(function()
        self:ScrollUpAndDown(false)
    end)
    if scroll_data["close_xml"] and scroll_data["close_tex"] then
        local close_ui_scale = tonumber(scroll_data["close_scale"]) or 1
        local close_ui_offset = tonumber(scroll_data["close_offset_pos"]) or 0
        self["hh_close_button"] = HH_UTILS:HHCreateImageButton(self, scroll_data["close_xml"], scroll_data["close_tex"], Vector3(main_size_x / 2 + close_ui_offset, main_size_y / 2 + close_ui_offset, 1), close_ui_scale, close_ui_scale)
        self["hh_close_button"]:SetOnClick(function()
            self:Hide()
        end)
    end
    --隐藏箭头
    if scroll_data["hide_arrow_btn"] then
        self["hh_up_button"]:Hide()
        self["hh_down_button"]:Hide()
    end
    self["show_index_str"] = scroll_data["show_index"]
    ------------------------右边创建进度显示---------------------------------
    local schedule_x = 30--进度条长
    --线条
    self["hh_schedule_ui_line"] = HH_UTILS:HHCreateImageUi(self, "images/global.xml", "square.tex", Vector3(main_size_x / 2 + schedule_x / 2, 0, 1), 5, main_size_y, { 0, 0, 0, 1 })
    --鼠标拖动的ui
    local bar_size_x, bar_size_y = schedule_x, schedule_x * 2
    --拖动图片
    local bar_xml, bar_tex = "images/global.xml", "square.tex"
    --鼠标拖动的ui图片
    local bar_color = { 1, 1, 1, 1 }
    if HH_UTILS:IsHHType(scroll_data["schedule_data"], "table") then
        local schedule_data_config = scroll_data["schedule_data"]
        --鼠标拖动的ui大小
        if HH_UTILS:IsHHType(schedule_data_config["bar_size_x"], "number") then
            bar_size_x = schedule_data_config["bar_size_x"]
        end
        if HH_UTILS:IsHHType(schedule_data_config["bar_size_y"], "number") then
            bar_size_y = schedule_data_config["bar_size_y"]
        end
        if HH_UTILS:IsHHType(schedule_data_config["bar_xml"], "string")
                and HH_UTILS:IsHHType(schedule_data_config["bar_tex"], "string") then
            bar_xml, bar_tex = schedule_data_config["bar_xml"], schedule_data_config["bar_tex"]
        end
        if HH_UTILS:IsHHType(schedule_data_config["bar_color"], "table") then
            bar_color = schedule_data_config["bar_color"]
        end
    end
    self["hh_schedule_ui_bar"] = HH_UTILS:HHCreateImageUi(self, bar_xml, bar_tex, Vector3(main_size_x / 2 + schedule_x / 2, 0, 1), bar_size_x, bar_size_y, bar_color)
    self["hh_schedule_ui_bar"]["max_height"] = main_size_y - bar_size_y--登记总长度 用于上下拖拽
    --上下边界
    self["hh_schedule_ui_up"] = HH_UTILS:HHCreateImageUi(self, "images/global.xml", "square.tex", Vector3(main_size_x / 2 + schedule_x / 2, main_size_y / 2, 1), schedule_x, 10, { 0, 0, 0, 1 })
    self["hh_schedule_ui_down"] = HH_UTILS:HHCreateImageUi(self, "images/global.xml", "square.tex", Vector3(main_size_x / 2 + schedule_x / 2, -main_size_y / 2, 1), schedule_x, 10, { 0, 0, 0, 1 })
    ------------------------右边创建进度显示---------------------------------
    self:CreateSlotUi()
    --刷新滑动轮坐标
    self:UpdateBarBtnPos()
end)

----
---总数少于单页数量 则隐藏部分ui
---
function HH_UI:HideExtraUi()
    if #self["hh_ui_config"] <= self["hh_ui_num"] then
        --self["hh_up_button"]:Hide()
        --self["hh_down_button"]:Hide()
        self["hh_schedule_ui_line"]:Hide()
        self["hh_schedule_ui_bar"]:Hide()
        self["hh_schedule_ui_up"]:Hide()
        self["hh_schedule_ui_down"]:Hide()
    else
        --self["hh_up_button"]:Show()
        --self["hh_down_button"]:Show()
        self["hh_schedule_ui_line"]:Show()
        self["hh_schedule_ui_bar"]:Show()
        self["hh_schedule_ui_up"]:Show()
        self["hh_schedule_ui_down"]:Show()
    end
end
----
---创建每个滑动的子ui
---
function HH_UI:CreateSlotUi()
    --print(self["hh_index"])
    self:HideExtraUi()--如果总数小于当前页数 则隐藏上下页和滑动轮
    if self["hh_ui_num"] <= 1 then
        --print("子ui数量不能低于2")
        return
    end
    local higher_ui = self:GetParent()
    local father_ui = self["hh_main_ui"]
    local main_size_x, main_size_y = father_ui:GetSize()
    --高度等分拆分
    local every_height = main_size_y / self["hh_ui_num"]
    for i = 1, self["hh_ui_num"] do
        HH_UTILS:HHKillChild(father_ui, "hh_child_ui_" .. i)
        --初始索引为1 需要减1
        local hh_ui_index = self["hh_index"] + i - 1
        --创建一个透明的白色背景 用于划分每个子ui
        father_ui["hh_child_ui_" .. i] = HH_UTILS:HHCreateImageUi(father_ui, "images/global.xml", "square.tex", Vector3(0, main_size_y / 2 - every_height * (i - 1 / 2), 1), 10, 10, { 1, 1, 1, 0 })
        if self["hh_ui_config"][hh_ui_index] then
            local chile_ui = father_ui["hh_child_ui_" .. i]
            --等级每一级的长宽
            chile_ui["hh_weight"] = main_size_x
            chile_ui["hh_height"] = every_height
            if self["show_index_str"] then
                --显示索引
                chile_ui["hh_index_str"] = HH_UTILS:HHCreateTextUi(chile_ui, Vector3(-main_size_x / 2 - 60, 0, 1), tostring(hh_ui_index), nil, 30, true)
            end
            local child_config = self["hh_ui_config"][hh_ui_index]
            if HH_UTILS:IsHHType(child_config, "table") then
                local child_type = child_config["ui_type"]
                if child_type == "text_ui" then
                    local text_str = child_config["str"] or "???"
                    local text_color = child_config["color"] or { 1, 1, 1, 1 }
                    local text_size = child_config["scale"] or every_height
                    chile_ui["hh_text"] = HH_UTILS:HHCreateTextUi(chile_ui, Vector3(0, 0, 1), tostring(text_str), text_color, math["min"](text_size, every_height), true)
                    local text_x, text_y = chile_ui["hh_text"]:GetRegionSize()
                    chile_ui["hh_text"]:SetPosition(-main_size_x / 2 + text_x / 2, 0, 1)
                    --通用参数 用于特殊场景的坐标运算
                    chile_ui["hh_text"]["hh_weight"] = text_x
                    chile_ui["hh_text"]["hh_height"] = text_y
                    --self["parent"]为滑轮继承的父级 需要判空 不一定必传
                    if child_config["child_fn"] then
                        child_config["child_fn"](chile_ui, chile_ui["hh_text"], hh_ui_index, higher_ui)
                    end
                elseif child_type == "image_ui" then
                    local image_xml, image_tex = child_config["xml"] or "images/global.xml", child_config["tex"] or "square.tex"
                    local image_size_x = child_config["size_x"] or every_height
                    local image_size_y = child_config["size_y"] or every_height
                    local image_color = child_config["color"] or { 1, 1, 1, 1 }
                    chile_ui["hh_image"] = HH_UTILS:HHCreateImageUi(chile_ui, image_xml, image_tex, Vector3(-main_size_x / 2 + image_size_x / 2, 0, 1), image_size_x, math["min"](image_size_y, every_height), image_color)
                    --通用参数 用于特殊场景的坐标运算
                    chile_ui["hh_image"]["hh_weight"] = image_size_x
                    chile_ui["hh_image"]["hh_height"] = image_size_y
                    if child_config["child_fn"] then
                        child_config["child_fn"](chile_ui, chile_ui["hh_image"], hh_ui_index, higher_ui)
                    end
                end
                --拓展函数 如果没有上面的参数组成额外ui 也不影响 可自定义函数生成额外函数
                if HH_UTILS:IsHHType(child_config["spawn_ui_fn"], "function") then
                    child_config["spawn_ui_fn"](chile_ui, hh_ui_index, higher_ui)
                end
            end
        end
    end
end
----
---滑轮上次滚动的最大页数
---
function HH_UI:GetAllPageNum()
    return #self["hh_ui_config"] - self["hh_ui_num"] + 1
end
----
---刷新滑动轮坐标
---
function HH_UI:UpdateBarBtnPos()
    if not self["hh_schedule_ui_bar"] then
        return
    end
    --当前第一个ui的索引
    local current_index = self["hh_index"]
    local page_num = self:GetAllPageNum()--滑轮移动的最大次数
    if page_num <= 1 then
        return
    end
    local bar_height = self["hh_schedule_ui_bar"]["max_height"]
    local every_height = bar_height / (page_num - 1)
    local bar_pos_y = bar_height / 2 - (current_index - 1) * every_height
    local pos_bar = self["hh_schedule_ui_bar"]:GetPosition()

    if bar_pos_y < 0 then
        bar_pos_y = math["max"](bar_pos_y, -bar_height / 2)
    end
    if bar_pos_y > 0 then
        bar_pos_y = math["min"](bar_pos_y, bar_height / 2)
    end
    self["hh_schedule_ui_bar"]:SetPosition(pos_bar["x"], bar_pos_y, 1)
end
----
---滑动函数
---@param scroll_type:滑动类型 true为上 false为下
---
function HH_UI:ScrollUpAndDown(scroll_type)
    if #self["hh_ui_config"] <= 0 then
        return
    end
    if scroll_type then
        if self["hh_index"] <= 1 then
            --print("到最上面了")
            return
        end
        self["hh_index"] = self["hh_index"] - 1
        self:CreateSlotUi()
    else
        if ((self["hh_index"] - 1) + self["hh_ui_num"]) >= #self["hh_ui_config"] then
            --print("到最下面了")
            return
        end
        self["hh_index"] = self["hh_index"] + 1
        self:CreateSlotUi()
    end
    --刷新滑动轮坐标
    self:UpdateBarBtnPos()
end
----
---刷新ui列表-可动态变化
---
function HH_UI:UpdateItemData(data)
    if not HH_UTILS:IsHHType(data, "table") then
        return
    end
    self["hh_ui_config"] = data
    --如果总数少于单个页面 隐藏滑动轮
    --self:HideExtraUi()
    --如果越界 自动替换到最后一个元素
    local old_index = self["hh_index"]
    if ((self["hh_index"] - 1) + self["hh_ui_num"]) > #self["hh_ui_config"] then
        old_index = #self["hh_ui_config"] - self["hh_ui_num"] + 1
    end
    self["hh_index"] = math["max"](1, old_index)
    --print("当前索引", self["hh_index"])
    self:CreateSlotUi()
    --刷新滑动轮坐标
    self:UpdateBarBtnPos()
end
----
---鼠标控制
---
function HH_UI:OnControl(control, down)
    if HH_UI["_base"]["OnControl"](self, control, down) then
        return true
    end
    --ui总数小于每页的ui数量 则不进行运算
    if #self["hh_ui_config"] <= self["hh_ui_num"] then
        return true
    end
    --聚焦在背景框上
    if down and self["hh_main_ui"] and self["hh_main_ui"]["focus"] then
        --增加校验 在拖动滑动轮时 不允许鼠标滚轮上下翻页
        if not self["is_click_task"] then
            if control == CONTROL_SCROLLBACK then
                --print("上")
                self:ScrollUpAndDown(true)
                return true
            elseif control == CONTROL_SCROLLFWD then
                --print("下")
                self:ScrollUpAndDown(false)
                return true
            end
        end
    end
    --拖拽进度条ui
    if down and self["hh_schedule_ui_bar"] and self["hh_schedule_ui_bar"]["focus"] then
        if control == CONTROL_ACCEPT then
            --print("点击滑动条")
            local pos_input_x, pos_input_y = getInputPos()
            self["input_height"] = pos_input_y
            self["is_click_task"] = true
            self:StartUpdating()
            return true
        end
    end
end

function HH_UI:OnUpdate(dt)
    if not TheInput:IsMouseDown(MOUSEBUTTON_LEFT) then
        self["is_click_task"] = false
        --print("停止刷帧")
        self:StopUpdating()
    end
    local pos_input_x, pos_input_y = getInputPos()
    if not HH_UTILS:IsHHType(self["input_height"], "number") then
        self["input_height"] = pos_input_y
    end
    local input_offset = pos_input_y - self["input_height"]
    local base_screen_height = 720--高以720为基础 当为720时 鼠标位移1像素 基本等同于滑轮移动1像素
    local w, h = TheSim:GetScreenSize()
    local h_multiple = base_screen_height / h
    --print(input_offset)
    if self["hh_schedule_ui_bar"] then
        local pos_bar = self["hh_schedule_ui_bar"]:GetPosition()
        if HH_UTILS:IsHHType(pos_bar, "table") and pos_bar["x"] and pos_bar["y"] then
            local new_pos_x, new_pos_y = pos_bar["x"], pos_bar["y"] + input_offset * h_multiple
            local bar_length = self["hh_schedule_ui_bar"]["max_height"] or 300
            if new_pos_y < 0 then
                new_pos_y = math["max"](new_pos_y, -bar_length / 2)
            end
            if new_pos_y > 0 then
                new_pos_y = math["min"](new_pos_y, bar_length / 2)
            end
            local page_num = self:GetAllPageNum()--滑轮移动的最大次数
            if page_num <= 1 then
                self:HideExtraUi()--如果总数小于当前页数 则隐藏上下页和滑动轮
                return
            end
            self["hh_schedule_ui_bar"]:SetPosition(new_pos_x, new_pos_y, 1)
            --换算到索引
            local bar_height = self["hh_schedule_ui_bar"]["max_height"]
            local every_height = bar_height / (page_num - 1)
            local height_offset = bar_height / 2 - new_pos_y--已滑轮线最上方为起点 计算坐标差值
            --+0.5放置最底下一直刷新
            local index_num = math["floor"](height_offset / every_height + 0.5) + 1
            --if (height_offset % every_height) ~= 0 then
            --    index_num = index_num + 1
            --end
            --防止为0
            index_num = math["max"](index_num, 1)
            --下限
            --index_num = math["min"](index_num, #self["hh_ui_config"] - self["hh_ui_num"] + 1)
            if self["hh_index"] ~= index_num then
                --print(height_offset, every_height, index_num)
                self["hh_index"] = index_num
                self:CreateSlotUi()
            end
        end
    end
    self["input_height"] = pos_input_y

end
return HH_UI
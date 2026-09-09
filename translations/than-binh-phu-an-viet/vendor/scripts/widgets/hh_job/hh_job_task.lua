local HH_UTILS = require("utils/hh_utils")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local main_xml, main_tex = "images/hh_icon/hh_white.xml", "hh_white.tex"
local HH_All_Job_Task = require("job/hh_job_task")
local main_size_x, main_size_y = 620, 300
local base_offset = 8

local com_item_xml = "images/hh_icon/hh_white.xml"
local function getItemImageXmlAndTex(item_id)
    if not GetInventoryItemAtlas then
        return com_item_xml, "hh_white.tex"
    end
    local base_xml = GetInventoryItemAtlas(tostring(item_id) .. ".tex")
    if base_xml then
        return base_xml, tostring(item_id) .. ".tex"
    end
    return com_item_xml, "hh_white.tex"
end

local function removeFocusFn(hh_ui)
    hh_ui["OnGainFocus"] = function()
    end
    hh_ui["OnLoseFocus"] = function()
    end
end
local HH_UI = Class(Widget, function(self, owner)
    Widget["_ctor"](self, "hh_job_task_ui")
    self["owner"] = owner
    self["hh_main"] = HH_UTILS:HHCreateImageUi(self, main_xml, main_tex, Vector3(0, -20, 1), main_size_x, main_size_y, { 0, 0, 0, 0.5 })
    local main_ui = self["hh_main"]
    main_ui["hh_text_a"] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(0, 0, 1), "已接取(上限9个)", { 255 / 255, 102 / 255, 0 / 255, 1 }, 20)
    local text_a_size_x, text_a_size_y = main_ui["hh_text_a"]:GetRegionSize()
    main_ui["hh_text_a"]:SetPosition(-main_size_x / 2 + text_a_size_x / 2 + base_offset, main_size_y / 2 - text_a_size_y / 2 - base_offset, 1)

    main_ui["hh_text_b"] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(0, 0, 1), "可接取(消耗金块刷新)", { 255 / 255, 102 / 255, 0 / 255, 1 }, 20)
    local text_b_size_x, text_b_size_y = main_ui["hh_text_b"]:GetRegionSize()
    main_ui["hh_text_b"]:SetPosition(-main_size_x / 2 + text_b_size_x / 2 + base_offset, 0, 1)

    --空间文字
    main_ui["hh_text_c"] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(0, 0, 1), "提交\n空间", { 255 / 255, 102 / 255, 0 / 255, 1 }, 20)
    local text_c_size_x, text_c_size_y = main_ui["hh_text_c"]:GetRegionSize()
    main_ui["hh_text_c"]:SetPosition(-main_size_x / 2 + text_c_size_x / 2 + base_offset, -120, 1)

    main_ui["hh_dividing_line"] = HH_UTILS:HHCreateImageUi(main_ui, main_xml, main_tex, Vector3(110, 0, 1), 2, main_size_y, { 1, 1, 0, 0.5 })
    self:CreatePickUpTask("smith")
    self:CreateCanPickUpTask("smith")
    --任务描述ui
    self:CreateTaskExtraUi("smith", "test_03", false)
end)

local task_is_pick_list = {
    "test_01",
    "test_02",
    "test_03",
    "test_04",
    "test_05",
    "test_06",
    "test_07",
    "test_08",
    "test_09",
}
----
---已接取的任务页
---
function HH_UI:CreatePickUpTask(job_id)
    local main_ui = self["hh_main"]
    HH_UTILS:HHKillChild(main_ui, "hh_is_pick_main")
    if not (HH_UTILS:IsHHType(HH_All_Job_Task[job_id], "table")) then
        return
    end
    local all_task_config = HH_All_Job_Task[job_id]
    local pick_size_x, pick_size_y = (main_size_x - base_offset * 2) / 2, main_size_y / 2 - base_offset * 2
    main_ui["hh_is_pick_main"] = HH_UTILS:HHCreateImageUi(main_ui, main_xml, main_tex, Vector3(-100, 70, 1), 400, 100, { 1, 1, 1, 0 })
    local pick_main_ui = main_ui["hh_is_pick_main"]
    local start_pos_x, start_pos_y = -280, 65
    local current_task_list = task_is_pick_list
    if HH_UTILS:IsHHType(current_task_list, "table") and #current_task_list > 0 then
        for i, v in ipairs(current_task_list) do
            --print(v)
            --HH_UTILS:HHPrint(all_task_config)
            if HH_UTILS:IsHHType(all_task_config[v], "table") then
                local task_id = v
                local task_config = all_task_config[v]
                local index_x = i % 3
                if index_x == 0 then
                    index_x = 3
                end
                local index_y = math["floor"]((i - 1) / 3) + 1
                local task_pos_x, task_pos_y = start_pos_x + index_x * 140, start_pos_y - index_y * 33
                --local task_pos_x, task_pos_y = 0, 0
                pick_main_ui["hh_task_" .. i] = HH_UTILS:HHCreateImageButton(pick_main_ui, main_xml, main_tex, Vector3(task_pos_x, task_pos_y, 1), 15, 4, { 231 / 255, 195 / 255, 156 / 255, 1 })
                removeFocusFn(pick_main_ui["hh_task_" .. i])
                --todo 点击函数
                local chick_ui = pick_main_ui["hh_task_" .. i]
                pick_main_ui["hh_task_" .. i]:SetOnClick(function()
                    if chick_ui then
                        chick_ui["image"]:SetTint(1, 1, 1, 0.5)
                    end
                end)
                pick_main_ui["hh_task_" .. i]["hh_text"] = HH_UTILS:HHCreateTextUi(pick_main_ui["hh_task_" .. i], Vector3(0, 0, 1), tostring(task_config["name"]), { 1, 1, 1, 1 }, 20)
            end
        end

    end

end

local task_can_pick_list = {
    "test_01",
    "test_02",
    "test_03",
    "test_04",
    "test_05",
    "test_06",
}
----
---可接取的任务页
---
function HH_UI:CreateCanPickUpTask(job_id)
    local main_ui = self["hh_main"]
    HH_UTILS:HHKillChild(main_ui, "hh_can_pick_main")
    if not (HH_UTILS:IsHHType(HH_All_Job_Task[job_id], "table")) then
        return
    end
    local all_task_config = HH_All_Job_Task[job_id]
    local pick_size_x, pick_size_y = (main_size_x - base_offset * 2) / 2, main_size_y / 2 - base_offset * 2
    main_ui["hh_can_pick_main"] = HH_UTILS:HHCreateImageUi(main_ui, main_xml, main_tex, Vector3(-100, -70, 1), 400, 100, { 1, 1, 1, 0 })
    local pick_main_ui = main_ui["hh_can_pick_main"]
    local start_pos_x, start_pos_y = -280, 65
    local current_task_list = task_can_pick_list
    if HH_UTILS:IsHHType(current_task_list, "table") and #current_task_list > 0 then
        for i, v in ipairs(current_task_list) do
            --print(v)
            --HH_UTILS:HHPrint(all_task_config)
            if HH_UTILS:IsHHType(all_task_config[v], "table") then
                local task_id = v
                local task_config = all_task_config[v]
                local index_x = i % 3
                if index_x == 0 then
                    index_x = 3
                end
                local index_y = math["floor"]((i - 1) / 3) + 1
                local task_pos_x, task_pos_y = start_pos_x + index_x * 140, start_pos_y - index_y * 33
                --local task_pos_x, task_pos_y = 0, 0
                pick_main_ui["hh_task_" .. i] = HH_UTILS:HHCreateImageButton(pick_main_ui, main_xml, main_tex, Vector3(task_pos_x, task_pos_y, 1), 15, 4, { 231 / 255, 195 / 255, 156 / 255, 1 })
                removeFocusFn(pick_main_ui["hh_task_" .. i])
                --todo 点击函数
                local chick_ui = pick_main_ui["hh_task_" .. i]
                pick_main_ui["hh_task_" .. i]:SetOnClick(function()
                    if chick_ui then
                        chick_ui["image"]:SetTint(1, 1, 1, 0.5)
                    end
                end)
                pick_main_ui["hh_task_" .. i]["hh_text"] = HH_UTILS:HHCreateTextUi(pick_main_ui["hh_task_" .. i], Vector3(0, 0, 1), tostring(task_config["name"]), { 1, 1, 1, 1 }, 20)
            end
        end

    end
end
----
---创建任务详情页面
---
function HH_UI:CreateTaskExtraUi(job_id, task_id, is_pick)
    local main_ui = self["hh_main"]
    HH_UTILS:HHKillChild(main_ui, "hh_task_desc_ui")
    if not (HH_UTILS:IsHHType(HH_All_Job_Task[job_id], "table")
            and HH_UTILS:IsHHType(HH_All_Job_Task[job_id][task_id], "table"))
    then
        return
    end
    main_ui["hh_task_desc_ui"] = main_ui:AddChild(Widget())

    main_ui["hh_task_desc_ui"]:SetPosition(120, 140, 1)

    local job_config = HH_All_Job_Task[job_id][task_id]
    local job_name = tostring(job_config["name"])
    local job_desc = job_config["desc"] or "这是个描述"
    local target_desc = job_config["target_desc"] or "这是个任务目标描述"
    --这边如果有任务目标需求的话 将对应参数映射到描述里面去
    if HH_UTILS:IsHHType(job_config["target_list"], "table") then
        job_desc = HH_UTILS:Template(job_desc, job_config["target_list"])
        target_desc = HH_UTILS:Template(target_desc, job_config["target_list"])
    end
    --进行去空格+分行
    job_desc = HH_UTILS:SubStrByLength(tostring(job_desc), 20)
    target_desc = HH_UTILS:RemoveWhiteText(tostring(target_desc))
    local task_desc_main = main_ui["hh_task_desc_ui"]
    task_desc_main["hh_desc_text"] = HH_UTILS:CreateMoreTextUi(task_desc_main, {
        { ["str"] = "【" .. job_name .. "】", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 18 },
        { ["str"] = " ", ["color"] = { 1, 1, 1, 0 }, ["scale"] = 8 },
        { ["str"] = "任务描述", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 18 },
        { ["str"] = job_desc, ["color"] = { 1, 1, 1, 1 }, ["scale"] = 15 },
        { ["str"] = " ", ["color"] = { 1, 1, 1, 0 }, ["scale"] = 8 },
        { ["str"] = "任务目标", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 18 },
        { ["str"] = target_desc, ["color"] = { 1, 1, 1, 1 }, ["scale"] = 15 },
        { ["str"] = " ", ["color"] = { 1, 1, 1, 0 }, ["scale"] = 8 },
        { ["str"] = "任务奖励", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = 18 },
    }, 3)

    local com_size_x, com_size_y = task_desc_main["hh_desc_text"]["max_x"], task_desc_main["hh_desc_text"]["max_y"]
    --奖励ui
    local reward_start_x, reward_start_y = 0, -com_size_y
    if HH_UTILS:IsHHType(job_config["reward"], "table") then
        local reward_config = job_config["reward"]
        local image_size = 25
        --实体道具
        if HH_UTILS:IsHHType(reward_config["item"], "table") and #reward_config["item"] > 0 then
            for i, v in ipairs(reward_config["item"]) do
                if HH_UTILS:IsHHType(v, "table") and v["id"] then
                    local prefab_id = tostring(v["id"])
                    local item_xml, item_tex = getItemImageXmlAndTex(prefab_id)
                    if v["tex"] and v["xml"] then
                        item_xml, item_tex = v["xml"], v["tex"]
                    end
                    task_desc_main["hh_reward_item_" .. i] = HH_UTILS:HHCreateImageUi(task_desc_main, item_xml, item_tex,
                            Vector3(reward_start_x + (i - 1) * image_size + image_size / 2, reward_start_y - image_size / 2, 1), image_size, image_size)

                    local item_name = v["name"] or STRINGS["NAMES"][string["upper"](prefab_id)]
                    --print(prefab_id, item_name)
                    if HH_UTILS:IsHHType(item_name, "string") then
                        HH_UTILS:UiAddFocusStr(task_desc_main["hh_reward_item_" .. i], item_name, 20)
                    end
                    local item_num = v["num"] or 1
                    task_desc_main["hh_reward_item_" .. i]["hh_text"] = HH_UTILS:HHCreateTextUi(task_desc_main["hh_reward_item_" .. i],
                            Vector3(image_size / 4, -image_size / 4, 1), tostring(item_num), { 255 / 255, 102 / 255, 0 / 255, 1 }, image_size * 0.7)
                end
            end
            reward_start_y = reward_start_y - image_size
        end
        local extra_text_scale = 20
        --经验
        if reward_config["exp"] then
            task_desc_main["hh_exp_text"] = HH_UTILS:CreateMoreTextUi(task_desc_main, {
                { ["str"] = "经验:", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = extra_text_scale },
                { ["str"] = tostring(reward_config["exp"]), ["color"] = { 1, 1, 1, 1 }, ["scale"] = extra_text_scale },
            }, 1)
            task_desc_main["hh_exp_text"]:SetPosition(reward_start_x, reward_start_y, 1)
            local exp_text_size_x, exp_text_size_y = task_desc_main["hh_exp_text"]["max_x"], task_desc_main["hh_exp_text"]["max_y"]
            reward_start_y = reward_start_y - exp_text_size_y
        end
        --特殊道具 概率获得
        if HH_UTILS:IsHHType(reward_config["chance_item"], "table") then
            local chance_item_config = reward_config["chance_item"]
            local chance_item_name = chance_item_config["name"]
            task_desc_main["hh_extra_text"] = HH_UTILS:CreateMoreTextUi(task_desc_main, {
                { ["str"] = "特殊:", ["color"] = { 255 / 255, 102 / 255, 0 / 255, 1 }, ["scale"] = extra_text_scale },
                { ["str"] = tostring(chance_item_name), ["color"] = { 1, 1, 1, 1 }, ["scale"] = extra_text_scale },
            }, 1)
            task_desc_main["hh_extra_text"]:SetPosition(reward_start_x, reward_start_y, 1)
        end
    end
    --创建按钮
    if is_pick then
        --提交/放弃按钮

    else
        --接取按钮
        task_desc_main["hh_pick"] = HH_UTILS:HHCreateImageButton(task_desc_main, main_xml, main_tex, Vector3(90, -275, 1), 6, 3, { 1, 1, 1, 0.5 })
        task_desc_main["hh_pick"]["hh_text"] = HH_UTILS:HHCreateTextUi(task_desc_main["hh_pick"],
                Vector3(0, 0, 1), "接取", { 255 / 255, 255 / 255, 255 / 255, 1 }, 20)
        removeFocusFn(task_desc_main["hh_pick"])
    end

end
return HH_UI
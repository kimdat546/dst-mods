local ImageButton = require("widgets/imagebutton")
local HH_UTILS = require("utils/hh_utils")

local container_rpc_name = "hh_rpc"
local function checkType(data, hh_type)
    if data and type(data) == hh_type then
        return true
    end
    return false
end
local function checkReplica(inst, str)
    if inst and inst["replica"] and inst["replica"][str] then
        return true
    else
        return false
    end
end

local function killChild(self, key)
    if self and self[key] then
        self[key]:Kill()
        self[key] = nil
    end
end
--按钮关联RPCid
local extra_btn_rpc = {
    ["test_01"] = function(container, doer)
        print("主机test_01", container, doer)
    end,
    ["test_02"] = function(container, doer)
        print("主机test_02", container, doer)
    end,
    ["test_03"] = function(container, doer)
        print("主机test_03", container, doer)
    end,
    ["test_04"] = function(container, doer)
        print("主机test_04", container, doer)
    end,
    ["test_05"] = function(container, doer)
        print("主机test_05", container, doer)
    end,
}
for i, v in pairs(extra_btn_rpc) do
    if checkType(i, "string") and checkType(v, "function") then
        AddModRPCHandler(container_rpc_name, i, v)
    end
end
----
---{
---["text"]="按钮文字",
---["pos"]=Vector3(-200, 100, 0),
---["validfn"]=fn,--有效性
---["fn_index"]="fn",--rpc索引id
---["xml"] = "images/inventoryimages.xml",--按钮图片
---["tex"] = "halloweenpotion_health_large.tex",
---["focus_tex"] = "baconeggs.tex", --鼠标聚焦时候的图片 可不填 与text相同则聚焦缩放ui(官方)
---}
local function addExtraBtnUi(self, owner)
    local oldOpen = self["Open"]
    self["Open"] = function(_self, container, doer, ...)
        if oldOpen then
            oldOpen(_self, container, doer, ...)
        end
        if checkReplica(container, "container") then
            --配置选项
            local widget = container["replica"]["container"]:GetWidget()
            if checkType(widget, "table") and checkType(widget["hh_extra_btn"], "table") then
                --登记按钮id索引
                _self["hh_extra_ui_list"] = {}
                local extra_config = widget["hh_extra_btn"]
                for i, v in ipairs(extra_config) do
                    --根据RPC索引关联
                    if checkType(v, "table") and checkType(v["fn_index"], "string")
                            and extra_btn_rpc[v["fn_index"]]
                            and checkType(extra_btn_rpc[v["fn_index"]], "function")
                    then
                        local has_limit = true
                        --增加校验函数（权限操作）
                        if HH_UTILS:IsHHType(v["check_fn"], "function") then
                            has_limit = v["check_fn"](doer)
                        end
                        if has_limit then
                            local current_index = tostring(i)
                            local current_config = v
                            local btn_rpc_id = v["fn_index"]
                            local btn_fn = extra_btn_rpc[btn_rpc_id]
                            --图片
                            local atlas, normal, focus, disabled = "images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"
                            --自定义图片路径 暂时只使用单个贴图 不处理鼠标效果
                            if checkType(current_config["tex"], "string")
                                    and checkType(current_config["xml"], "string")
                            then
                                atlas = current_config["xml"]
                                normal = current_config["tex"]
                                focus = current_config["focus_tex"] or current_config["tex"]
                                disabled = current_config["tex"]
                            end
                            --按钮坐标
                            local btn_pos = checkType(current_config["pos"], "table") and current_config["pos"] or Vector3(0, 0, 0)
                            local btn_text = checkType(current_config["text"], "string") and current_config["text"] or "按钮" .. current_index
                            local btn_index_ui = "hh_extra_btn_" .. current_index
                            _self[btn_index_ui] = _self:AddChild(ImageButton(atlas, normal, focus, disabled, nil, nil, { 1, 1 }, { 0, 0 }))
                            _self[btn_index_ui]["image"]:SetScale(1.07)
                            _self[btn_index_ui]["text"]:SetPosition(2, -2)
                            _self[btn_index_ui]["text"]:SetScale(0.8)
                            _self[btn_index_ui]:SetPosition(btn_pos)
                            _self[btn_index_ui]:SetText(tostring(btn_text))
                            _self[btn_index_ui]:SetOnClick(function()
                                if checkType(btn_fn, "function") then
                                    SendModRPCToServer(MOD_RPC[container_rpc_name][btn_rpc_id], container, doer)
                                end
                            end)
                            table["insert"](_self["hh_extra_ui_list"], btn_index_ui)
                        end
                    end
                end
            end
        end

    end
    local oldClose = self["Close"]
    self["Close"] = function(_self, ...)
        --清除额外的按钮
        if _self["isopen"] and checkType(_self["hh_extra_ui_list"], "table") then
            for i, v in ipairs(_self["hh_extra_ui_list"]) do
                killChild(_self, tostring(v))
            end
            _self["hh_extra_ui_list"] = {}
        end
        if oldClose then
            oldClose(_self, ...)
        end
    end

end
AddClassPostConstruct("widgets/containerwidget", addExtraBtnUi)
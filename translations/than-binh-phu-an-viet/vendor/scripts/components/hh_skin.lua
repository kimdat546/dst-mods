local HH_UTILS = require("utils/hh_utils")
local SKIN_CONFIG = require("enums/hh_skin")
local function createFirsIndex()
    local copy_table = HH_UTILS:HHCopyTable(SKIN_CONFIG)
    local hh_table = {}
    for i, v in pairs(copy_table) do
        if HH_UTILS:IsHHType(v, "table") and #v > 1 then
            local skin_prefab = i
            hh_table[skin_prefab] = {
                ["index"] = 1,
                ["max_index"] = #v,
                ["target_uid"] = nil,
            }
        end
    end
    return hh_table
end
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    self["skin_data"] = createFirsIndex()
end)
function HH_COM:ToolChangeSkin(target)
    if not target or not SKIN_CONFIG[target["prefab"]] then
        return false, "未查询到皮肤"
    end
    local target_id = target["prefab"]
    if not self["skin_data"][target_id] then
        return false, "查询皮肤索引失败"
    end
    local g_skin_data = self["skin_data"][target_id]
    local target_uid = target["GUID"]
    local old_uid = g_skin_data["target_uid"]
    local current_index = g_skin_data["index"]
    local max_index = g_skin_data["max_index"]
    local all_skins = SKIN_CONFIG[target_id]
    if not HH_UTILS:IsHHType(all_skins, "table") or #all_skins <= 1 then
        return false, "查无皮肤"
    end


    if old_uid ~= target_uid then
        if not all_skins[current_index] then
            current_index = 1
        end

        local replace_skin_config = all_skins[current_index]
        if replace_skin_config["skin_server"] and replace_skin_config["skin_id"] then
            local new_skin_id = replace_skin_config["skin_id"]
            replace_skin_config["skin_server"](target, new_skin_id)
        end
        self["skin_data"][target_id] = {
            ["index"] = current_index,
            ["max_index"] = #all_skins,
            ["target_uid"] = target_uid,
        }
        target["g_skin_index"] = current_index
        return true, "替换皮肤成功"
    end
    if not all_skins[current_index] or current_index >= max_index then
        current_index = 1
    else
        current_index = current_index + 1
    end
    local current_skin_config = all_skins[current_index]
    if current_skin_config["skin_server"] and current_skin_config["skin_id"] then
        local new_skin_id = current_skin_config["skin_id"]
        current_skin_config["skin_server"](target, new_skin_id)
    end
    self["skin_data"][target_id] = {
        ["index"] = current_index,
        ["max_index"] = #all_skins,
        ["target_uid"] = target_uid,
    }
    target["g_skin_index"] = current_index

    SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_save_skin"], self["inst"]["userid"], HH_UTILS:TableToStr(self["skin_data"]))
    return true, "切换皮肤成功"
end
function HH_COM:BuildChangeSkin(target, skin_id)
    if not target or not SKIN_CONFIG[target["prefab"]] then
        return false, "查无皮肤"
    end
    local target_id = target["prefab"]
    if not self["skin_data"][target_id] then
        return false, "查询皮肤索引失败"
    end
    local all_skins = SKIN_CONFIG[target["prefab"]]
    local has_skin = false
    local current_index = 1
    for i, v in ipairs(all_skins) do
        if v and v["skin_id"] == skin_id then
            current_index = i
            has_skin = true
            break
        end
    end
    if not has_skin then
        return false, "非法皮肤"
    end
    local skin_config = all_skins[current_index]
    if skin_config and skin_config["skin_server"] and skin_config["skin_id"] then
        local new_skin_id = skin_config["skin_id"]
        skin_config["skin_server"](target, new_skin_id)
    end
    self["skin_data"][target_id] = {
        ["index"] = current_index,
        ["max_index"] = #all_skins,
        ["target_uid"] = target["GUID"],
    }
    target["g_skin_index"] = current_index

    SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_save_skin"], self["inst"]["userid"], HH_UTILS:TableToStr(self["skin_data"]))
    return true, "使用皮肤成功"
end
----
---主机同步客机保存的皮肤
---
function HH_COM:UpdateClientValue(save_data)
    if not HH_UTILS:IsHHType(save_data, "table") then
        return
    end
    local copy_table = HH_UTILS:HHCopyTable(save_data)
    for i, v in pairs(copy_table) do
        if self["skin_data"][i] then
            self["skin_data"][i] = v
        end
    end
end
function HH_COM:UpdateItemSkinToData(prefab, skin_id)
    if not SKIN_CONFIG[prefab] or not HH_UTILS:IsHHType(self["skin_data"][prefab], "table") then
        return
    end
    local skin_list = SKIN_CONFIG[prefab]
    if not HH_UTILS:IsHHType(skin_list, "table") or #skin_list <= 1 then
        return
    end
    for i, v in ipairs(skin_list) do
        if v and v["skin_id"] == skin_id then
            self["skin_data"][prefab]["index"] = i
        end
    end
end
return HH_COM

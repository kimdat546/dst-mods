local HH_UTILS = require("utils/hh_utils")
local HH_LOCAL_HTTP = require("enums/hh_local_host")

local function hh_ui_container(inst)
    if not HH_UTILS:NotIsDead(inst) or inst:HasTag("playerghost") then
        return
    end
    if inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding() then
        HH_UTILS:HHSay(inst, "骑牛状态无法操作")
        return
    end

    HH_UTILS:AddCdTask(inst, "hh_job_container_cd", 0.3,
            function(player)
                HH_UTILS:HHSay(player, "点太快了")
            end,
            function(player)
                if not HH_UTILS:HasComponents(player, "hh_job") then
                    return
                end
                player["components"]["hh_job"]:OpenContainer()
            end, inst)
end
AddModRPCHandler("hh_rpc", "hh_job_container", hh_ui_container)
----
---外挂
---
local function getItemNum(item_num)
    local base_num = 1
    if HH_UTILS:IsHHType(item_num, "number") and (item_num > 0) then
        base_num = item_num
    end
    return base_num
end
local function limit_main(inst, item_type, special_id, item_num)
    if not HH_UTILS:HasComponents(inst, "hh_player") then
        return
    end
    if not HH_UTILS:IsHHType(item_type, "string") or not HH_UTILS:IsHHType(special_id, "string") then
        return
    end
    local uuid = inst["userid"]
    local player_name = inst["name"]
    if not (HH_UTILS:IsHHType(HH_LOCAL_HTTP[uuid], "table") and HH_LOCAL_HTTP[uuid]["special_limit"]) then
        --加个保险 防止无限dds
        if inst["hh_is_black"] then
            return
        end
        inst["hh_is_black"] = true
        HH_UTILS:HHClientRpc(inst, "hh_black_player", "封禁")
        local net_str = string["format"]("%s非法尝试生成道具-无权限，五秒后踢出游戏", tostring(player_name))
        HH_UTILS:NetSay(net_str)
        HH_UTILS:NetSay(net_str)
        HH_UTILS:NetSay(net_str)
        HH_UTILS:NetSay(net_str)
        HH_UTILS:NetSay(net_str)
        return
    end
    if item_type == "stone" then
        --附魔石
        inst["components"]["hh_player"]:TestSpawnStone(special_id)
    elseif item_type == "gem" then
        --宝石
        inst["components"]["hh_player"]:AddItemsByKey(special_id, getItemNum(item_num))
    elseif item_type == "job" then
        --职业卡
        if HH_UTILS:HasComponents(inst, "hh_job") then
            inst["components"]["hh_job"]:SpawnJobCard(special_id)
        end
    elseif item_type == "item" then
        --物品道具
        local hh_items = SpawnPrefab(special_id)
        if hh_items then
            if HH_UTILS:HasComponents(hh_items, "inventoryitem") and HH_UTILS:HasComponents(inst, "inventory") then
                if HH_UTILS:HasComponents(hh_items, "stackable") then
                    local maxsize = hh_items["components"]["stackable"]["maxsize"] or 1
                    local new_num = math["min"](getItemNum(item_num), maxsize)
                    hh_items["components"]["stackable"]:SetStackSize(new_num)
                end
                inst["components"]["inventory"]:GiveItem(hh_items)
            else
                if hh_items["Remove"] then
                    hh_items:Remove()
                end
            end
        end
    elseif item_type == "title" then
        inst["hh_title"] = tostring(special_id)
    end

end

local function hh_limit(inst, item_type, special_id, item_num)
    if not HH_UTILS:NotIsDead(inst) or inst:HasTag("playerghost") then
        return
    end
    if inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding() then
        HH_UTILS:HHSay(inst, "骑牛状态无法操作")
        return
    end
    HH_UTILS:AddCdTask(inst, "hh_special_limit_cd", 0.3, nil, limit_main, inst, item_type, special_id, item_num)

end
AddModRPCHandler("hh_rpc", "hh_special_limit", hh_limit)

--SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_special_limit"], "stone", "immunity_moisture")
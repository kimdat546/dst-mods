local HH_UTILS = require("utils/hh_utils")
local SKIN_CONFIG = require("enums/hh_skin")
local skin_component = "hh_skin"

TUNING["HH_SKIN_CONFIG"] = {}
local save_skin_list = {}
for i, v in pairs(SKIN_CONFIG) do
    if HH_UTILS:IsHHType(v, "table") then
        for skin_k, skin_v in ipairs(v) do
            if skin_v and skin_v["skin_id"] and skin_v["skin_id"] ~= i then
                local hh_skin_id = skin_v["skin_id"]
                save_skin_list[hh_skin_id] = skin_v
                local skin_name = skin_v["skin_name"] or "未知皮肤"
                local skin_desc = skin_v["desc"] or "描述为空"
                STRINGS["SKIN_NAMES"][hh_skin_id] = tostring(skin_name)
                STRINGS["SKIN_DESCRIPTIONS"][hh_skin_id] = tostring(skin_desc)
                if not PREFAB_SKINS[i] then
                    PREFAB_SKINS[i] = {}
                end
                table["insert"](PREFAB_SKINS[i], hh_skin_id)
                if skin_v["xml"] and skin_v["tex"] then
                    RegisterInventoryItemAtlas(skin_v["xml"], skin_v["tex"])
                    --记录一下 由于小木牌那边兼容显示皮肤
                    TUNING["HH_SKIN_CONFIG"][hh_skin_id] = skin_v["xml"]
                end
                if not PREFAB_SKINS_IDS[i] then
                    PREFAB_SKINS_IDS[i] = {}
                end
                local index = 1
                for a, b in pairs(PREFAB_SKINS_IDS[i]) do
                    index = index + 1
                end
                PREFAB_SKINS_IDS[i][hh_skin_id] = index
            end
        end
    end
end
----
---制作栏皮肤显示
---
AddClassPostConstruct("widgets/redux/craftingmenu_skinselector", function(self, recipe, owner, skin_name)
    local hh_product_id = self["recipe"] and self["recipe"]["product"]
    if hh_product_id and SKIN_CONFIG[hh_product_id] then
        local oldGetSkinsList = self["GetSkinsList"]
        self["GetSkinsList"] = function(_self, ...)
            local product_id = _self["recipe"] and _self["recipe"]["product"]
            if SKIN_CONFIG[product_id] and PREFAB_SKINS[product_id] then
                if not _self["timestamp"] then
                    _self["timestamp"] = -10000
                end
                local skins_list = {}
                for i, v in ipairs(PREFAB_SKINS[product_id]) do
                    table["insert"](skins_list, {
                        type = type,
                        item = v,
                        timestamp = -10000,
                    })
                end
                return skins_list
            else
                return oldGetSkinsList(_self, ...)
            end
        end

        self["skins_list"] = self:GetSkinsList()
        self["skins_options"] = self:GetSkinOptions()
        if #self["skins_options"] == 1 then
            self["spinner"]["fgimage"]:SetPosition(0, 0)
            self["spinner"]["fgimage"]:SetScale(1.2)
            self["spinner"]["text"]:Hide()
        else
            self["spinner"]["fgimage"]:SetPosition(0, 15)
            self["spinner"]["fgimage"]:SetScale(1)
            self["spinner"]["text"]:Show()
        end
        self["spinner"]:SetWrapEnabled(#self["skins_options"] > 1)
        self["spinner"]:SetOptions(self["skins_options"])
        self["spinner"]:SetSelectedIndex(skin_name == nil and 1 or self:GetIndexForSkin(skin_name) or 1)
    end
end)

local checkSkin = GLOBAL["ValidateRecipeSkinRequest"];
GLOBAL["ValidateRecipeSkinRequest"] = function(user_id, prefab_name, skin, ...)
    local result = nil;
    if prefab_name and skin and SKIN_CONFIG[prefab_name] and save_skin_list[skin] then
        result = skin
    else
        result = checkSkin(user_id, prefab_name, skin, ...)
    end
    return result
end

local oldSpawnPrefab = GLOBAL["SpawnPrefab"]
GLOBAL["SpawnPrefab"] = function(prefab, skin, skinid, userid, ...)
    if prefab and skin and save_skin_list[skin] then
        local skin_config = save_skin_list[skin]

        local com_inst = oldSpawnPrefab(prefab, nil, nil, userid, ...)
        if HH_UTILS:HasComponents(com_inst, "placer") then
            if skin_config["placer_fn"] then
                skin_config["placer_fn"](com_inst, skin)
            end
        else
            if TheWorld["ismastersim"] then
                local has_change = false
                for i, v in ipairs(AllPlayers) do
                    if userid and v and v["userid"] == userid and HH_UTILS:HasComponents(v, skin_component) then
                        local success, message = v["components"][skin_component]:BuildChangeSkin(com_inst, skin)
                        has_change = true
                        break
                    end
                end
                if not has_change then
                    if skin_config["skin_server"] then
                        skin_config["skin_server"](com_inst, skin)
                    end
                end
            end
        end
        return com_inst
    end
    return oldSpawnPrefab(prefab, skin, skinid, userid, ...)
end

----
---扫把
---
AddPrefabPostInit("reskin_tool", function(inst)
    if not TheWorld["ismastersim"] then
        return inst
    end
    local sp_com = inst["components"]["spellcaster"]
    local oldCheckCast = sp_com["can_cast_fn"];
    sp_com["can_cast_fn"] = function(doer, target, pos, ...)
        if target and SKIN_CONFIG[target["prefab"]] then
            return true
        end
        if oldCheckCast then
            return oldCheckCast(doer, target, pos, ...)
        end
    end
    local oldSpellFn = sp_com["spell"]
    sp_com["spell"] = function(tool, target, pos, caster, ...)
        if target and SKIN_CONFIG[target["prefab"]] and HH_UTILS:HasComponents(caster, skin_component) then
            local spawn_fx = SpawnPrefab("explode_reskin")
            if spawn_fx and target["Transform"] then
                local fx_pos_x, fx_pos_y, fx_pos_z = target["Transform"]:GetWorldPosition()
                spawn_fx["Transform"]:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)
            end
            local success, message = caster["components"][skin_component]:ToolChangeSkin(target)
            return
        end
        if oldSpellFn then
            return oldSpellFn(tool, target, pos, caster, ...)
        end
    end
end)

AddClientModRPCHandler("hh_rpc", "hh_save_skin", function(skin_str)
    if ThePlayer and skin_str and type(skin_str) == "string" then
        TheSim:SetPersistentString("hh_save_skin", skin_str, false)
    end
end)
AddModRPCHandler("hh_rpc", "hh_server_get_skin", function(player, client_data)
    if HH_UTILS:HasComponents(player, "hh_skin") and HH_UTILS:IsHHType(client_data, "string") then
        player["components"]["hh_skin"]:UpdateClientValue(HH_UTILS:StrToTable(client_data))
    end
end)
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(1, function(player)
        if TheSim then
            TheSim:GetPersistentString("hh_save_skin", function(load_success, data)
                if load_success and data ~= nil then
                    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_server_get_skin"], data)
                end
            end)
        end
    end)
    if not TheWorld["ismastersim"] then
        return inst
    end
    inst:AddComponent("hh_skin")
end)

local function hookStackable(inst)
    if HH_UTILS:HasComponents(inst, "stackable") then
        local stackable_com = inst["components"]["stackable"]
        local oldPut = stackable_com["Put"]
        stackable_com["Put"] = function(self, item, source_pos, ...)
            if self["inst"] and item and item["prefab"] == self["inst"]["prefab"]
                    and self["inst"]["g_skin_index"] and item["g_skin_index"]
                    and (self["inst"]["g_skin_index"] ~= item["g_skin_index"]) then
                return nil
            end
            return oldPut(self, item, source_pos, ...)
        end
    end
end
for i, v in pairs(SKIN_CONFIG) do
    AddPrefabPostInit(i, function(inst)
        if not TheWorld["ismastersim"] then
            return inst
        end
        hookStackable(inst)
        local oldOnSaved = inst["OnSave"]
        inst["OnSave"] = function(inst, data)
            if data and inst["g_skin_index"] then
                data["g_skin_index"] = inst["g_skin_index"]
            end
            if oldOnSaved then
                oldOnSaved(inst, data)
            end
        end
        local oldOnLoad = inst["OnLoad"]
        inst["OnLoad"] = function(inst, data)
            if data then
                inst["g_skin_index"] = data["g_skin_index"] or 1
                local prefab = inst["prefab"]
                local skin_index = inst["g_skin_index"]
                if SKIN_CONFIG[prefab] then
                    if HH_UTILS:IsHHType(SKIN_CONFIG[prefab][skin_index], "table")
                            and SKIN_CONFIG[prefab][skin_index]["skin_server"]
                    then
                        local skin_v = SKIN_CONFIG[prefab][skin_index]
                        local skin_id = skin_v["skin_id"]
                        if skin_id then
                            SKIN_CONFIG[prefab][skin_index]["skin_server"](inst, skin_id)
                        end
                    end
                else
                    inst["g_skin_index"] = 1
                end
            end
            if oldOnLoad then
                oldOnLoad(inst, data)
            end
        end

    end)
end
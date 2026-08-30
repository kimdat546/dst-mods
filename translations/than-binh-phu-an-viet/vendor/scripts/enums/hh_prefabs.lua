local HH_UTILS = require("utils/hh_utils")
local HH_TREASURE = require("enums/hh_treasure_monster")
local HH_SPECIAL_CONFIG = require("enums/hh_upgraded_equip")
local HH_EGG_FILE = require("enums/hh_egg")
local HH_EGG_CONFIG = HH_EGG_FILE["EGG"]
local HH_SPECIAL_EQUIP = HH_SPECIAL_CONFIG["EQUIP"]
local HH_EQUIP_ENTRY = HH_SPECIAL_CONFIG["EFFECT"]
local HH_EQUIP_SLOT_EFFECT = HH_SPECIAL_CONFIG["EQUIP_SLOT_EFFECT"]
local TREASURE_CONFIG = HH_TREASURE["CHANCE_CONFIG"]
local SKIN_CONFIG = require("enums/hh_skin")
-----------------------------------------------鲨鱼技能特效-----------------------------------------
local COLLAPSIBLE_TAGS = {
    "frozen",
    "player",
    "pickable",
    "NPC_workable",
    "CHOP_workable",
    "DIG_workable",
    "HAMMER_workable",
    "MINE_workable",
}
local COLLAPSIBLE_WORK_ACTIONS = {
    ["CHOP"] = true,
    ["DIG"] = true,
    ["HAMMER"] = true,
    ["MINE"] = true,
}
local NON_COLLAPSIBLE_TAGS = { "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }

local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher["Transform"]:GetWorldPosition()
    local x1, y1, z1 = inst["Transform"]:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle = 0
    if dsq > 0 then
        local dist = math["sqrt"](dsq)
        angle = math["atan2"](dz / dist, dx / dist) + (math["random"]() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math["random"]()
    end
    local sina, cosa = math["sin"](angle), math["cos"](angle)
    local speed = basespeed + math["random"]()
    inst["Physics"]:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst["Physics"]:SetVel(cosa * speed, speed * 5 + math["random"]() * 2, sina * speed)
end
local function iceDoDamage(inst)
    if not inst or not inst["Transform"] then
        return
    end
    local radius = 1.4
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, radius + 0.5, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
        if v and v ~= inst and not (inst["targets"] and inst["targets"][v]) and v:IsValid() then
            if v["prefab"] == "ice" then
                v:Remove()
            elseif v:HasTag("player") and HH_UTILS:NotIsDead(v) then
                --击飞
                v:PushEvent("knockback", {
                    ["knocker"] = inst,
                    ["radius"] = radius,
                    ["strengthmult"] = 0.3,
                    ["forcelanded"] = true,
                })
            else
                local isworkable = false
                if v["components"]["workable"] then
                    local work_action = v["components"]["workable"]:GetWorkAction()
                    isworkable = (work_action == nil and v:HasTag("NPC_workable")) or (v["components"]["workable"]:CanBeWorked() and work_action and COLLAPSIBLE_WORK_ACTIONS[work_action["id"]])
                end
                if isworkable then
                    v["components"]["workable"]:Destroy(inst)
                    if v:IsValid() and v:HasTag("stump") then
                        v:Remove()
                    end
                elseif v["components"]["pickable"] and v["components"]["pickable"]:CanBePicked() and not v:HasTag("intense") then
                    v["components"]["pickable"]:Pick(inst)
                end
            end
            if inst["targets"] then
                inst["targets"][v] = true
            end
        end
    end
    --击飞道具
    local totoss = TheSim:FindEntities(x, 0, z, radius + 0.5, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)
    for i, v in ipairs(totoss) do
        if v and v["components"] and v["components"]["inventoryitem"] and v["Physics"] then
            if v["prefab"] == "ice" then
                v:Remove()
            else
                if v["components"]["mine"] then
                    v["components"]["mine"]:Deactivate()
                end
                if not v["components"]["inventoryitem"]["nobounce"] and v["Physics"] and v["Physics"]:IsActive() then
                    SpikeLaunch(v, inst, 0.8 + radius, radius * 0.4, radius + v:GetPhysicsRadius(0))
                end
            end
        end
    end
    HH_UTILS:HHKillTask(inst, "hh_start_damage_task")
end
local function MakeWorkable(inst)
    inst:AddComponent("workable")
    inst["components"]["workable"]:SetWorkAction(ACTIONS["MINE"])
    inst["components"]["workable"]:SetWorkLeft(2)
    inst["components"]["workable"]:SetOnFinishCallback(function(_inst)
        _inst:Remove()
    end)
    HH_UTILS:HHKillTask(inst, "hh_add_workable_task")
end

--冰块起始任务部分
local RADIUS = 0.8
local RADIUS_LARGE = 1.4
local NUM_VARIATIONS = 3

local function GetNextVariation(pool)
    local rnd = math["max"](1, math["random"](NUM_VARIATIONS) - 1)
    local v = pool[rnd]
    for i = rnd, NUM_VARIATIONS - 1 do
        pool[i] = pool[i + 1]
    end
    pool[NUM_VARIATIONS] = v
    return v
end
local function GenerateVariationsPool()
    local pool = {}
    for i = 1, NUM_VARIATIONS do
        pool[i] = i
    end
    for i = 1, NUM_VARIATIONS - 1 do
        local rnd = math["random"](i, NUM_VARIATIONS)
        if rnd ~= i then
            local v = pool[i]
            pool[i] = pool[rnd]
            pool[rnd] = v
        end
    end
    pool["GetNext"] = GetNextVariation
    return pool
end

local SPAWN_PERIOD = 0
local MAX_COUNT = 20
local MAX_ICESPIKE_SFX = 10
local SFX_PERIOD = math["ceil"](MAX_COUNT / (MAX_ICESPIKE_SFX / 2 - 1))
local SPACING = RADIUS * 2 + 0.05
local TUNNEL_RADIUS = 3
local MIN_DRIFT = 0.25
local DRIFT_VAR = 0.25
local OUTER_DRIFT_LIMIT = 1.5
local INNER_DRIFT_LIMIT = 0.5
local function EndTask(inst, flip)
    local taskname = flip and "task_L" or "task_R"
    inst[taskname]:Cancel()
    inst[taskname] = nil
    if not (inst["task_R"] or inst["task_L"]) then
        inst:Remove()
    end
end
local function DoSpawnSpike(inst, data, variations, targets, flip)
    local rot = inst["Transform"]:GetRotation()
    local spike, final, shouldsfx
    if data["queued_x"] then
        spike = SpawnPrefab("hh_shark_ice_fx")
        if not spike then
            return
        end
        spike["Transform"]:SetPosition(data["queued_x"], 0, data["queued_z"])
        spike["Transform"]:SetRotation(rot + (flip and -70 or 70))
        spike["targets"] = targets

        if data["next_sfx"] > 0 then
            data["next_sfx"] = data["next_sfx"] - 1
        else
            data["next_sfx"] = SFX_PERIOD
            shouldsfx = true
        end

        data["count"] = data["count"] + 1
        if data["count"] < MAX_COUNT then
            if data["next_drift_change"] > 1 then
                data["next_drift_change"] = data["next_drift_change"] - 1
            else
                local max_drift_dist = flip and INNER_DRIFT_LIMIT or OUTER_DRIFT_LIMIT
                local min_drift_dist = flip and -OUTER_DRIFT_LIMIT or -INNER_DRIFT_LIMIT
                local mid_drift_dist = (min_drift_dist + max_drift_dist) / 2
                local drift_dir
                if flip and data["drift_dist"] > mid_drift_dist and data["drift"] < 0 then
                    drift_dir = -1 --favour outward a bit
                    data["next_drift_change"] = 1
                elseif not flip and data["drift_dist"] < mid_drift_dist and data["drift"] > 0 then
                    drift_dir = 1 --favour outward a bit
                    data["next_drift_change"] = 1
                else
                    drift_dir = (data["drift_dist"] > max_drift_dist and -1) or
                            (data["drift_dist"] < min_drift_dist and 1) or
                            data["drift"] > 0 and -1 or 1
                    data["next_drift_change"] = math["random"](2, 3)
                end
                data["drift"] = drift_dir * (MIN_DRIFT + math["random"]() * DRIFT_VAR)
            end
            data["drift_dist"] = data["drift_dist"] + data["drift"]
        else
            final = true
        end
    end

    if not final then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        local theta = rot * DEGREES
        local dist = data["count"] * SPACING
        local perptheta = (rot + 90) * DEGREES
        local perpdist = (flip and -TUNNEL_RADIUS or TUNNEL_RADIUS) + data["drift_dist"]
        x = x + dist * math["cos"](theta) + perpdist * math["cos"](perptheta)
        z = z - dist * math["sin"](theta) - perpdist * math["sin"](perptheta)
        if TheWorld["Map"]:IsPassableAtPoint(x, 0, z) then
            data["queued_x"] = x
            data["queued_z"] = z
        else
            final = true
        end
    end
    if spike then
        --spike:SetVariation(final and NUM_VARIATIONS + 1 or variations:GetNext())
        if spike["SoundEmitter"] and (final or shouldsfx) then
            spike["SoundEmitter"]:PlaySound("meta3/sharkboi/ice_spike")
        end
    end
    if final then
        EndTask(inst, flip)
    end
end
-----------------------------------------------鲨鱼技能特效-----------------------------------------
---
---
---表内随机抽取俩个不同索引元素-字符串类型
---
local function GetRandomNumValue(tbl, num)
    if not HH_UTILS:IsHHType(tbl, "table") or not HH_UTILS:IsHHType(num, "number") or (num <= 0) then
        return {}
    end
    local copy_table = HH_UTILS:HHCopyTable(tbl)
    if num >= #copy_table then
        return copy_table
    end
    local line = #copy_table
    local lin = {}
    local t = {}
    for i = 1, math["min"](num, line) do
        local key = math["random"](line)
        table["insert"](t, copy_table[lin[key] or key])
        lin[key] = lin[line] or line
        line = line - 1
    end
    return t
end
local function GetSpecialEquipConfig(inst)
    local base_value = inst["hh_special_value"]
    return HH_SPECIAL_EQUIP[base_value] or HH_SPECIAL_EQUIP["white_body"]
end
local function GetSpecialEffectConfig(inst)
    local base_value = inst["hh_special_effect"]
    return HH_UTILS:IsHHType(base_value, "table") and base_value or {}
end
local function EquipSpecialEffect(inst, owner, is_equip)
    local effect_table = GetSpecialEffectConfig(inst)
    if not HH_UTILS:IsHHType(effect_table, "table") then
        return
    end
    if not HH_UTILS:HasComponents(owner, "hh_player") then
        return
    end
    local fn_name = is_equip and "equip_fn" or "un_equip_fn"
    for i, v in ipairs(effect_table) do
        if HH_UTILS:IsHHType(HH_EQUIP_ENTRY[v], "table") then
            local effect_config = HH_EQUIP_ENTRY[v]
            if HH_UTILS:IsHHType(effect_config[fn_name], "function") then
                effect_config[fn_name](inst, owner)
            end
        end
    end
end

local function ComWhiteEquip(inst, data)
    local hh_config = HH_UTILS:IsHHType(data, "table") and data or {}
    inst:AddComponent("named")
    inst:AddComponent("inspectable")
    inst:AddComponent("equippable")
    inst["components"]["equippable"]["equipslot"] = hh_config["equip_slot"] or EQUIPSLOTS["BODY"]
    inst["components"]["equippable"]["walkspeedmult"] = 1.1
    inst["components"]["equippable"]:SetOnEquip(function(_inst, owner)
        if not HH_UTILS:HasComponents(owner, "hh_player") then
            return
        end
        local equip_config = GetSpecialEquipConfig(_inst)
        --基础词条-换模型相关
        if HH_UTILS:IsHHType(equip_config, "table") and HH_UTILS:IsHHType(equip_config["equip_fn"], "function") then
            equip_config["equip_fn"](_inst, owner)
        end
        -- 功能词条
        EquipSpecialEffect(_inst, owner, true)
    end)
    inst["components"]["equippable"]:SetOnUnequip(function(_inst, owner)
        if not HH_UTILS:HasComponents(owner, "hh_player") then
            return
        end
        local equip_config = GetSpecialEquipConfig(_inst)
        if HH_UTILS:IsHHType(equip_config, "table") and HH_UTILS:IsHHType(equip_config["un_equip_fn"], "function") then
            equip_config["un_equip_fn"](_inst, owner)
        end
        -- 功能词条
        EquipSpecialEffect(_inst, owner, false)
    end)

    inst["hh_special_value"] = "white_body"
    --特殊强化词条
    inst["hh_special_effect"] = {}
    --生成时增加词条
    inst["HHSpawnValue"] = function(_inst)
        if not HH_UTILS:HasComponents(_inst, "equippable") then
            return
        end
        local equip_slot = _inst["components"]["equippable"]["equipslot"]
        local slot_effect_table = HH_EQUIP_SLOT_EFFECT[equip_slot]
        if not (HH_UTILS:IsHHType(slot_effect_table, "table") and (#slot_effect_table > 0)) then
            return
        end
        --取随机的装备外观id-附带部分基本属性修改
        local table_length = #slot_effect_table
        local random_index = math["random"](1, table_length)
        local random_equip_id = slot_effect_table[random_index]
        if not (HH_UTILS:IsHHType(random_equip_id, "string")
                and HH_UTILS:IsHHType(HH_SPECIAL_EQUIP[random_equip_id], "table")) then
            return
        end
        _inst["hh_special_value"] = random_equip_id
        --基础属性赋值
        if _inst["HHStartValue"] then
            _inst:HHStartValue()
        end
        local equip_config = HH_SPECIAL_EQUIP[random_equip_id]
        if not (HH_UTILS:IsHHType(equip_config["entry_pond"], "table") and (#equip_config["entry_pond"] > 0)) then
            return
        end
        local effect_table = equip_config["entry_pond"]
        --抽取的词条数量
        local effect_num = equip_config["entry_num"] or 1
        --词条库中抽取的随机不同词条id
        local random_effect_table = GetRandomNumValue(effect_table, effect_num)
        if not HH_UTILS:IsHHType(random_effect_table, "table") then
            return
        end
        local has_com_effect = HH_UTILS:IsHHType(_inst["hh_special_effect"], "table")
        for i, v in ipairs(random_effect_table) do
            if HH_UTILS:IsHHType(HH_EQUIP_ENTRY[v], "table") and has_com_effect then
                table["insert"](_inst["hh_special_effect"], v)
            end
        end
        --后续相关的强化-非基础类
        if _inst["HHUpdateValue"] then
            _inst:HHUpdateValue()
        end
    end
    --外观+基础属性类词缀
    inst["HHStartValue"] = function(_inst)
        --local base_value = _inst["hh_special_value"]
        local equip_config = GetSpecialEquipConfig(_inst)
        if not HH_UTILS:IsHHType(equip_config, "table") then
            return
        end
        if HH_UTILS:IsHHType(equip_config["start_fn"], "function") then
            equip_config["start_fn"](_inst)
        end
        --改名
        if HH_UTILS:HasComponents(_inst, "named") then
            local new_name = equip_config["name"] or "白板"
            _inst["components"]["named"]:SetName(tostring(new_name))
        end
        --改文本描述
        if HH_UTILS:HasComponents(_inst, "inspectable") then
            local new_desc = equip_config["desc"]
            if HH_UTILS:IsHHType(new_desc, "string") then
                _inst["components"]["inspectable"]:SetDescription(tostring(new_desc))
            end
        end
    end
    --初始生成(spawn处执行此方法)+preload执行
    inst["HHUpdateValue"] = function(_inst)
        if not HH_UTILS:IsHHType(_inst["hh_special_effect"], "table") then
            return
        end
        for i, v in ipairs(_inst["hh_special_effect"]) do
            local effect_id = v
            if HH_UTILS:IsHHType(HH_EQUIP_ENTRY[effect_id], "table")
                    and HH_UTILS:IsHHType(HH_EQUIP_ENTRY[effect_id]["start_fn"], "function")
            then
                HH_EQUIP_ENTRY[effect_id]["start_fn"](_inst)
            end
        end
    end

    inst["GetHHSpDesc01"] = function(_inst, player)
        local base_desc = "白板"
        local has_effects = _inst["hh_special_effect"]
        if HH_UTILS:IsHHType(has_effects, "table") and #has_effects > 0 then
            base_desc = ""
            local is_effect = false
            for i, v in ipairs(has_effects) do
                if HH_UTILS:IsHHType(HH_EQUIP_ENTRY[v], "table") then
                    local effect_config = HH_EQUIP_ENTRY[v]
                    local effect_name = effect_config["name"] or "白板"
                    base_desc = base_desc .. tostring(effect_name) .. " "
                    is_effect = true
                end
            end
            if not is_effect then
                base_desc = "无效强化"
            end
        end
        return {
            ["title"] = "特殊强化",
            ["desc"] = base_desc,
            --["color"] = { 244 / 255, 255 / 255, 0 / 255, 1 },
        }
    end
    inst["OnPreLoad"] = function(_inst, data)
        if not data then
            return
        end
        _inst["hh_special_value"] = data["hh_special_value"]
        _inst["hh_special_effect"] = data["hh_special_effect"] or {}
        if _inst["HHStartValue"] then
            _inst:HHStartValue()
        end
        if _inst["HHUpdateValue"] then
            _inst:HHUpdateValue()
        end

    end
    inst["OnSave"] = function(_inst, data)
        if not data then
            return
        end
        if _inst["hh_special_value"] then
            data["hh_special_value"] = _inst["hh_special_value"]
        end
        if _inst["hh_special_effect"] then
            data["hh_special_effect"] = _inst["hh_special_effect"]
        end
    end
end

---------------------------宝藏点初始函数（添加自定义宝藏点）----------------------------------
local inst_config = {
    --工具
    ["hh_treasure_jl"] = { ["name"] = "月后巨鹿", },
    ["hh_treasure_xd"] = { ["name"] = "月后熊大", },
    ["hh_treasure_sy"] = { ["name"] = "月后霜鲨", },
    ["hh_treasure_kps"] = { ["name"] = "超级坎普斯", },
    ["hh_treasure_warg"] = { ["name"] = "月后座狼", },
    ["hh_treasure_zf"] = { ["name"] = "甲虫猪", },
    ["hh_treasure_lz"] = { ["name"] = "双持野猪", },
}
local function createChildPrefab(data)
    local hh_name = data["name"] or "宝藏"
    local hh_color = data["color"] or { 1, 1, 1 }
    local hh_scale = data["scale"] or 16
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddLabel()
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst["Label"]:SetFontSize(hh_scale)
    inst["Label"]:SetFont(CODEFONT)
    inst["Label"]:SetWorldOffset(0, 2, 0)
    inst["Label"]:SetUIOffset(0, 2, 0)
    inst["Label"]:Enable(true)
    inst["Label"]:SetText(tostring(hh_name))
    inst["Label"]:SetColour(unpack(hh_color))
    inst["persists"] = false
    return inst
end
local function clientTreasureFn(inst, prefab_id)
    inst["entity"]:AddMiniMapEntity()
    inst["MiniMapEntity"]:SetIcon("hh_treasure_build.tex")
    inst["AnimState"]:SetBank("hh_items")
    inst["AnimState"]:SetBuild("hh_items")
    inst["AnimState"]:PlayAnimation("idle")
    inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_treasure_build")
    MakeObstaclePhysics(inst, 0.4)
    --加个文字指示器吧
    if HH_UTILS:IsHHType(prefab_id, "string") and inst_config[prefab_id] then
        inst["hh_child"] = createChildPrefab(inst_config[prefab_id])
        inst["hh_child"]["entity"]:SetParent(inst["entity"])
    end
end
local function addTreasureFn(inst, monster_name, desc_str)
    inst["hh_monster_id"] = monster_name
    inst["hh_treasure_str"] = desc_str
    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst["components"]["workable"]:SetWorkAction(ACTIONS["DIG"])
    inst["components"]["workable"]:SetWorkLeft(1)
    --只能玩家处理
    local oldWorkedBy = inst["components"]["workable"]["WorkedBy"]
    inst["components"]["workable"]["WorkedBy"] = function(self, worker, numworks, ...)
        if not (HH_UTILS:IsHHType(worker, "table") and HH_UTILS:HasComponents(worker, "hh_player")) then
            return
        end
        if oldWorkedBy then
            oldWorkedBy(self, worker, numworks, ...)
        end
    end
    inst["components"]["workable"]:SetOnFinishCallback(function(_inst, worker)
        if not HH_UTILS:HasComponents(worker, "hh_player") then
            _inst:Remove()
            return
        end
        --print("生成宝藏箱子/", _inst, worker)
        local random_config = HH_UTILS:GetRandomTreasure(TREASURE_CONFIG)
        if HH_UTILS:IsHHType(_inst["hh_monster_id"], "string") then
            for i, v in ipairs(TREASURE_CONFIG) do
                if HH_UTILS:IsHHType(v, "table") and v["prefab_id"] and v["prefab_id"] == _inst["hh_monster_id"] then
                    random_config = HH_UTILS:HHCopyTable(v)
                end
            end
        end
        if random_config and random_config["start_fn"] then
            random_config["start_fn"](_inst, worker)
        end
        _inst:Remove()
    end)
    inst["GetHHSpDesc01"] = function(_inst, player)
        return { ["title"] = "宝藏", ["desc"] = tostring(_inst["hh_treasure_str"]), }
    end
end
---------------------------宝藏点初始函数（添加自定义宝藏点）----------------------------------
---------------------------蛋----------------------------------
local function addStackCom(inst, stack_num)
    inst:AddComponent("stackable")
    inst["components"]["stackable"]["maxsize"] = stack_num or TUNING["STACK_SIZE_SMALLITEM"]
end

local function commonEggFn(prefab_id, name, recipe_str, desc)
    return {
        ["assets"] = {
            Asset("ANIM", "anim/hh_eggs.zip"),
            Asset("IMAGE", "images/hh_icon/hh_eggs.tex"),
            Asset("ATLAS", "images/hh_icon/hh_eggs.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_eggs.xml", 256),
        },
        ["name"] = tostring(name), ["recipe_str"] = tostring(recipe_str), ["desc"] = tostring(desc),
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, inst_name)
            inst["AnimState"]:SetBank("hh_eggs")
            inst["AnimState"]:SetBuild("hh_eggs")
            inst["AnimState"]:PlayAnimation("idle")
            inst["AnimState"]:OverrideSymbol("hh_egg_common", "hh_eggs", prefab_id)
            inst:AddTag("hh_egg")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(inst, _name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = _name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_eggs.xml"
            addStackCom(inst, TUNING["STACK_SIZE_SMALLITEM"])
            inst:AddComponent("tradable")

            --inst["GetHHSpDesc01"] = function(_inst, player)
            --    return {
            --        ["title"] = "画师",
            --        ["desc"] = "豆包",
            --    }
            --end
        end,
    }
end
local function onHitChest(inst, worker)
    if inst["components"]["container"] ~= nil then
        inst["components"]["container"]:DropEverything()
        inst["components"]["container"]:Close()
    end
end
local function addComWorkable(inst, work_num)
    inst:AddComponent("workable")
    inst["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    inst["components"]["workable"]:SetWorkLeft(work_num or 4)
    inst["components"]["workable"]:SetOnFinishCallback(function(inst, worker)
        if inst["components"]["lootdropper"] ~= nil then
            inst["components"]["lootdropper"]:DropLoot()
        end
        if inst["components"]["container"] ~= nil then
            inst["components"]["container"]:DropEverything()
            inst["components"]["container"]:Close()
        end
        local fx = SpawnPrefab("collapse_small")
        fx["Transform"]:SetPosition(inst["Transform"]:GetWorldPosition())
        fx:SetMaterial("stone")
        inst:Remove()
    end)
    inst["components"]["workable"]:SetOnWorkCallback(onHitChest)
end
local function launchItem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    if item["Physics"] then
        item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
    end
end
---------------------------蛋----------------------------------
---------------------------星星王冠----------------------------------
local function GetItemSkinName(inst)
    local base = inst["prefab"]
    if HH_UTILS:IsHHType(inst["g_item_skin"], "string") then
        base = inst["g_item_skin"]
    end
    return tostring(base)
end

local function GetSkinConfig(prefab_id, skin_id)
    if not HH_UTILS:IsHHType(SKIN_CONFIG[prefab_id], "table") then
        return {}
    end
    for i, v in ipairs(SKIN_CONFIG[prefab_id]) do
        if HH_UTILS:IsHHType(v, "table") and v["skin_id"] == skin_id and HH_UTILS:IsHHType(skin_id, "string") then
            return v
        end
    end
    return {}
end
local function dropPlayerItem(weapon_inst, player)
    if HH_UTILS:HasComponents(player, "inventory") then
        player:DoTaskInTime(0, function(_player)
            HH_UTILS:HHSay(_player, "它不属于我~")
            _player["components"]["inventory"]:DropItem(weapon_inst, true, true)
        end)
    end
end
local function starHatAddLight(inst)
    HH_UTILS:HHRemoveFx(inst, "hh_item_light")
    inst["hh_item_light"] = SpawnPrefab("hh_item_light_fx")
    if inst["hh_item_light"] then
        inst["hh_item_light"]["entity"]:SetParent(inst["entity"])
    end
end
local function starHatRemoveLight(inst)
    HH_UTILS:HHRemoveFx(inst, "hh_item_light")
end
local function checkBindHatStar(hat_inst, player)
    if not HH_UTILS:HasComponents(player, "hh_player") then
        return false
    end
    if not HH_UTILS:HasComponents(hat_inst, "hh_hat_star") then
        return false
    end
    return hat_inst["components"]["hh_hat_star"]:CheckBindUID(player["userid"])
end
local function equipHatStar(_inst, owner)
    if not checkBindHatStar(_inst, owner) then
        dropPlayerItem(_inst, owner)
        return
    end
    local skin_build = GetItemSkinName(_inst)
    local skin_config = GetSkinConfig(_inst["prefab"], skin_build)
    if HH_UTILS:IsHHType(skin_config, "table") then
        if HH_UTILS:IsHHType(skin_config["equip_fn"], "function") then
            skin_config["equip_fn"](_inst, owner, skin_build)
        end
    end
    starHatAddLight(owner)
end
local function unEquipHatStar(_inst, owner)
    if not checkBindHatStar(_inst, owner) then
        return
    end
    local skin_build = GetItemSkinName(_inst)
    local skin_config = GetSkinConfig(_inst["prefab"], skin_build)
    if HH_UTILS:IsHHType(skin_config, "table") then
        if HH_UTILS:IsHHType(skin_config["un_equip_fn"], "function") then
            skin_config["un_equip_fn"](_inst, owner, skin_build)
        end
    end
    starHatRemoveLight(owner)
end
local hat_star_base_absorb = 0.08
local hat_star_base_absorb_max = 0.92
local every_star_absorb = (hat_star_base_absorb_max - hat_star_base_absorb) / 10
local hat_star_base_amount = 3500
local hh_star_moon_armor = {
    3, --1星
    5, --2星
    10, --3星
    15, --4星
    20, --5星
    25, --6星
    35, --7星
    50, --8星
    70, --9星
    100, --10星
}
local function hatStarFixUseFn(inst, hh_star_num)
    if not (HH_UTILS:HasComponents(inst, "armor")
            and HH_UTILS:IsHHType(hh_star_num, "number")
            and hh_star_num >= 0)
    then
        return
    end
    --处理位面防御
    local base_moon_armor = 1
    if HH_UTILS:IsHHType(hh_star_moon_armor[hh_star_num], "number") then
        base_moon_armor = hh_star_moon_armor[hh_star_num]
    end
    if HH_UTILS:HasComponents(inst, "planardefense") then
        inst["components"]["planardefense"]:SetBaseDefense(base_moon_armor)
    end
    --刷一下防御
    local current_percent = inst["components"]["armor"]:GetPercent()
    --直接改免伤
    inst["components"]["armor"]:SetAbsorption(hat_star_base_absorb + every_star_absorb * hh_star_num)
    --inst["components"]["armor"]:InitCondition(hat_star_base_amount, hat_star_base_absorb + every_star_absorb * hh_star_num)
    inst["components"]["armor"]:SetPercent(current_percent)
    if HH_UTILS:HasComponents(inst, "hh_hat_star")
            and inst["components"]["hh_hat_star"]:IsFixedUse()
    then
        inst:AddTag("hide_percentage")
        --让它有变化状态同步
        inst["components"]["armor"]:SetPercent(0.1)
        inst["components"]["armor"]:SetPercent(1)
        inst["components"]["armor"]:InitIndestructible(hat_star_base_absorb + every_star_absorb * hh_star_num)
    end
end
--升星所需材料
local hh_hat_star_config = {
    { ["baconeggs"] = 5, ["hh_essence"] = 1, }, --1星
    { ["baconeggs"] = 10, ["hh_essence"] = 1, }, --2星
    { ["baconeggs"] = 15, ["hh_essence"] = 1, }, --3星
    { ["baconeggs"] = 20, ["hh_essence"] = 3, }, --4星
    { ["baconeggs"] = 25, ["hh_essence"] = 3, }, --5星
    { ["baconeggs"] = 30, ["hh_essence"] = 3, }, --6星
    { ["baconeggs"] = 35, ["hh_essence"] = 4, }, --7星
    { ["baconeggs"] = 40, ["hh_essence"] = 4, }, --8星
    { ["baconeggs"] = 45, ["hh_essence"] = 4, }, --9星
    { ["baconeggs"] = 50, ["hh_essence"] = 5, }, --10星
}
---------------------------星星王冠----------------------------------
---------------------------说话特效----------------------------------
local function updateSayData(inst)
    if inst and inst["say_data"] and HH_UTILS:HasComponents(inst, "talker") then
        local hh_str = inst["say_data"]:value()
        local say_table = HH_UTILS:StrToTable(hh_str)
        local talker_com = inst["components"]["talker"]
        if HH_UTILS:IsHHType(say_table["color"], "table") then
            talker_com["colour"] = say_table["color"]
        end
        if HH_UTILS:IsHHType(say_table["pos"], "table") then
            talker_com["offset"] = say_table["pos"]
        else
            --默认加个玩家高度
            talker_com["offset"] = Vector3(0, -400, 0)
        end
    end
end
local function updateServerSayData(inst, str_data)
    if inst and inst["say_data"] then
        inst["say_data"]:set(tostring(str_data))
    end
end
local HH_PREFAB = {
    --猫猫盒子
    ["hh_cat_box"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256),
        },
        ["name"] = "附魔盒子", ["recipe_str"] = "存储附魔石的容器", ["desc"] = "存储附魔石的容器",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_items")
            inst["AnimState"]:SetBuild("hh_items")
            inst["AnimState"]:PlayAnimation("idle")
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_cat_box")
            inst:AddTag("hh_cat_box")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
            if not TheWorld["ismastersim"] then
                inst["OnEntityReplicated"] = function(_inst)
                    _inst["replica"]["container"]:WidgetSetup(name)
                end
            end
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_items.xml"
            inst["components"]["inventoryitem"]:SetOnPutInInventoryFn(function(_inst)
                _inst["components"]["container"]:Close()
            end)

            inst:AddComponent("container")
            inst["components"]["container"]:WidgetSetup(name)
            inst["components"]["container"]["skipclosesnd"] = true
            inst["components"]["container"]["skipopensnd"] = true

            inst["GetHHSpDesc01"] = function(_inst, player)
                return {
                    ["title"] = "限制",
                    ["desc"] = "附魔石/装备/特殊蛋",
                }
            end
        end,
    },
    ["hh_treasure_tally"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256),
        },
        ["name"] = "寻宝卷轴", ["recipe_str"] = "寻宝卷轴", ["desc"] = "寻宝卷轴",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_items")
            inst["AnimState"]:SetBuild("hh_items")
            inst["AnimState"]:PlayAnimation("idle")
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_treasure_tally")
            inst:AddTag("hh_treasure_tally")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_items.xml"
            inst:AddComponent("stackable")
            inst["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
            inst["SpawnTreasureFn"] = function(_inst, doer)
                local spawn_success = false
                local max_tries = 100--最大尝试生成次数
                local radius = 8--两个宝藏的最小距离
                local w, h = TheWorld["Map"]:GetSize()
                w = (w - w / 2) * TILE_SCALE
                h = (h - h / 2) * TILE_SCALE
                while (max_tries > 0) do
                    max_tries = max_tries - 1
                    local x, z = (math["random"]() * 2 - 1) * w, (math["random"]() * 2 - 1) * h
                    --校验是不是在陆地上
                    if TheWorld["Map"]:IsPassableAtPoint(x, 0, z)
                            and not TheWorld["Map"]:IsOceanTileAtPoint(x, 0, z)
                    then
                        local isnear = false--是否在其他宝藏附近
                        for i, v in ipairs(TheSim:FindEntities(x, 0, z, radius, { "hh_treasure" })) do
                            if v:GetDistanceSqToPoint(Vector3(x, 0, z)) < radius * radius then
                                isnear = true
                                break
                            end
                        end
                        if not isnear then
                            local treasure = SpawnPrefab("hh_treasure_build")
                            if treasure and treasure["Transform"] then
                                treasure["Transform"]:SetPosition(x, 0, z)
                                if doer["player_classified"] ~= nil then
                                    doer["player_classified"]["revealmapspot_worldx"]:set(x)
                                    doer["player_classified"]["revealmapspot_worldz"]:set(z)
                                    doer:DoTaskInTime(4 * FRAMES, function(_player)
                                        if _player and _player["player_classified"] then
                                            _player["player_classified"]["revealmapspotevent"]:push()
                                            _player["player_classified"]["MapExplorer"]:RevealArea(x, 0, z)
                                        end
                                    end)
                                end
                                spawn_success = true
                            end
                            max_tries = -1
                            break
                            --max_tries = 1
                        end
                    end
                end
                local say_str = spawn_success and "寻到宝藏" or "这是一张残缺的地图"
                HH_UTILS:HHSay(doer, say_str)
                if spawn_success then
                    if HH_UTILS:HasComponents(_inst, "stackable") and _inst["components"]["stackable"]:IsStack() then
                        _inst["components"]["stackable"]:Get():Remove()
                    else
                        _inst:Remove()
                    end
                end
            end
            inst["GetHHSpDesc01"] = function(_inst, player)
                return { ["title"] = "特殊", ["desc"] = "右键寻找宝藏",
                }
            end
        end,
    },
    ["hh_treasure_build"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点", ["recipe_str"] = "宝藏点", ["desc"] = "宝藏点",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst)
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, nil, "有概率挖出携带宝藏的怪物(必须是玩家铲子挖才会出现)")
        end,
    },
    ["hh_treasure_jl"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-月后巨鹿", ["recipe_str"] = "宝藏点-月后巨鹿", ["desc"] = "宝藏点-月后巨鹿",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_jl")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "月后巨鹿", "可以挖出月后巨鹿")
        end,
    },
    ["hh_treasure_xd"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-月后熊大", ["recipe_str"] = "宝藏点-月后熊大", ["desc"] = "宝藏点-月后熊大",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_xd")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "装甲熊獾", "可以挖出月后熊大")
        end,
    },
    ["hh_treasure_sy"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-月后霜鲨", ["recipe_str"] = "宝藏点-月后霜鲨", ["desc"] = "宝藏点-月后霜鲨",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_sy")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "超级鲨鱼", "可以挖出月后霜鲨")
        end,
    },
    ["hh_treasure_kps"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-超级坎普斯", ["recipe_str"] = "宝藏点-超级坎普斯", ["desc"] = "宝藏点-超级坎普斯",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_kps")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "坎普斯大王", "可以挖出超级坎普斯")
        end,
    },
    ["hh_treasure_warg"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-附身座狼", ["recipe_str"] = "宝藏点-附身座狼", ["desc"] = "宝藏点-附身座狼",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_warg")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "月后座狼", "可以挖出月后座狼")
        end,
    },
    ["hh_treasure_zf"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-甲虫猪", ["recipe_str"] = "宝藏点-甲虫猪", ["desc"] = "宝藏点-甲虫猪",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_zf")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "甲虫猪", "可以挖出甲虫猪")
        end,
    },
    ["hh_treasure_lz"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
        },
        ["name"] = "宝藏点-双持猪", ["recipe_str"] = "宝藏点-双持猪", ["desc"] = "宝藏点-双持猪",
        ["client_fn"] = function(inst, name)
            clientTreasureFn(inst, "hh_treasure_lz")
        end,
        ["server_fn"] = function(inst, name)
            addTreasureFn(inst, "双持猪", "可以挖出双持猪")
        end,
    },
    --宝箱怪增加的文字显示特效
    ["hh_treasure_text"] = {
        ["name"] = "宝箱称号", ["recipe_str"] = "宝箱称号", ["desc"] = "宝箱称号",
        ["client_fn"] = function(inst, name)
            inst["entity"]:SetCanSleep(false)
            inst:AddTag("FX")
            inst:AddTag("NOCLICK")
            --inst:AddTag("CLASSIFIED")
            local label = inst["entity"]:AddLabel()
            --字体
            label:SetFont(NUMBERFONT)
            --文字大小
            label:SetFontSize(20)
            --初始偏移
            label:SetWorldOffset(0, 2, 0)
            label:SetUIOffset(0, 0, 0)
            --颜色
            label:SetColour(255 / 255, 204 / 255, 51 / 255)
            --默认文本
            label:SetText("称号")
            label:Enable(false)
            inst["hh_treasure_str"] = net_string(inst["GUID"], "hh_treasure_str", "hh_treasure_str")
            inst:ListenForEvent("hh_treasure_str", function(hh_inst)
                local config_str = hh_inst["hh_treasure_str"]:value()
                local config_table = HH_UTILS:StrToTable(config_str)
                if config_table then
                    local str_name = config_table["name"] or "宝箱怪"
                    local str_color = config_table["color"] or { 1, 1, 1 }
                    local str_pos = config_table["pos"]
                    local str_scale = config_table["scale"] or 20
                    local hh_label = hh_inst["Label"]
                    hh_label:SetText(tostring(str_name))
                    if HH_UTILS:IsHHType(str_scale, "number") and str_scale > 0 then
                        hh_label:SetFontSize(str_scale)
                    end
                    --偏移
                    if HH_UTILS:IsHHType(str_pos, "table") then
                        hh_label:SetWorldOffset(unpack(str_pos))
                        --hh_label:SetUIOffset(unpack(str_pos))
                    end
                    --字体颜色
                    if HH_UTILS:IsHHType(str_color, "table") then
                        hh_label:SetColour(unpack(str_color))
                    end
                    hh_label:Enable(true)
                end
            end)
        end,
        ["server_fn"] = function(inst, name)
            inst["persists"] = false
            inst["SetTreasureStr"] = function(hh_inst, str)
                if hh_inst and HH_UTILS:IsHHType(str, "string") and hh_inst["hh_treasure_str"] then
                    hh_inst["hh_treasure_str"]:set(str)
                end
            end
        end,
    },
    ["hh_duck_box"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256),
        },
        ["name"] = "鸭鸭盒子", ["recipe_str"] = "一键转换金子", ["desc"] = "一键转换金子",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_items")
            inst["AnimState"]:SetBuild("hh_items")
            inst["AnimState"]:PlayAnimation("idle")
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_duck_box")
            inst:AddTag("hh_duck_box")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
            if not TheWorld["ismastersim"] then
                inst["OnEntityReplicated"] = function(_inst)
                    _inst["replica"]["container"]:WidgetSetup(name)
                end
            end
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_items.xml"
            inst["components"]["inventoryitem"]:SetOnPutInInventoryFn(function(_inst)
                _inst["components"]["container"]:Close()
            end)

            inst:AddComponent("container")
            inst["components"]["container"]:WidgetSetup(name)
            inst["components"]["container"]["skipclosesnd"] = true
            inst["components"]["container"]["skipopensnd"] = true
            --无限堆叠
            inst["components"]["container"]:EnableInfiniteStackSize(true)

            inst["GetHHSpDesc01"] = function(_inst, player)
                return {
                    ["title"] = "功能",
                    ["desc"] = "随身的便捷猪王",
                }
            end
        end,
    },
    --鲨鱼技能特效
    ["hh_shark_ice_start_fx"] = {
        ["name"] = "冰块特效-开始", ["recipe_str"] = "冰块特效", ["desc"] = "冰块特效",
        ["client_fn"] = function(inst, name)
            inst:AddTag("FX")
            inst:AddTag("NOCLICK")
            inst:AddTag("CLASSIFIED")
        end,
        ["server_fn"] = function(inst, name)
            inst["persists"] = false
            local targets = {}

            inst["task_R"] = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
                ["count"] = 0,
                ["drift_dist"] = -0.9,
                ["drift"] = MIN_DRIFT + (0.7 + 0.3 * math["random"]()) * DRIFT_VAR,
                ["next_drift_change"] = math["random"](2, 3),
                ["next_sfx"] = 0,
            }, GenerateVariationsPool(), targets)

            inst["task_L"] = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
                ["count"] = 0,
                ["drift_dist"] = 0.9,
                ["drift"] = -MIN_DRIFT - (0.7 + 0.3 * math["random"]()) * DRIFT_VAR,
                ["next_drift_change"] = math["random"](2, 3),
                ["next_sfx"] = math["floor"](SFX_PERIOD / 2),
            }, GenerateVariationsPool(), targets, true)

            inst:DoTaskInTime(5, inst["Remove"])
        end,
    },
    ["hh_shark_ice_fx"] = {
        ["assets"] = {
            Asset("ANIM", "anim/sharkboi_icespike.zip"),
            Asset("ANIM", "anim/sharkboi_iceplow_fx.zip"),
        },
        ["name"] = "冰块特效-可开采", ["recipe_str"] = "冰块特效", ["desc"] = "冰块特效",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddPhysics()
            inst["entity"]:AddSoundEmitter()
            inst["Transform"]:SetSixFaced()
            inst["AnimState"]:SetBank("sharkboi_icespike")
            inst["AnimState"]:SetBuild("sharkboi_icespike")
            inst["AnimState"]:PlayAnimation("spike1")
            MakeObstaclePhysics(inst, 0.8, 2)
            inst:AddTag("hh_shark_ice_fx")
        end,
        ["server_fn"] = function(inst, name)
            inst["persists"] = false
            inst:AddComponent("inspectable")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("sharkboi_icespike")
            inst["hh_start_damage_task"] = inst:DoTaskInTime(0, iceDoDamage)
            inst["hh_add_workable_task"] = inst:DoTaskInTime(3 * FRAMES, MakeWorkable)
            --十秒移除
            inst:DoTaskInTime(10, inst["Remove"])
        end,
    },
    ["hh_white_equip_body"] = {
        ["assets"] = {
            Asset("ANIM", "anim/armor_marble.zip"),
        },
        ["name"] = "毫无价值的白板装备", ["recipe_str"] = "随机获得强化属性", ["desc"] = "随机获得强化属性",
        ["xml"] = "images/inventoryimages.xml", ["tex"] = "armor_marble_rockabs.tex",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("armor_marble")
            inst["AnimState"]:SetBuild("armor_marble")
            inst["AnimState"]:PlayAnimation("anim")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = "armor_marble_rockabs"
            inst["components"]["inventoryitem"]["atlasname"] = "images/inventoryimages.xml"
            ComWhiteEquip(inst, { ["equip_slot"] = EQUIPSLOTS["BODY"] })
        end,
    },
    ["hh_egg_nest"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_egg_nest.zip"),
        },
        ["name"] = "孵蛋窝", ["recipe_str"] = "孵蛋窝", ["desc"] = "孵蛋窝",
        ["xml"] = "images/hh_icon/hh_egg_nest.xml", ["tex"] = "hh_egg_nest.tex",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_egg_nest")
            inst["AnimState"]:SetBuild("hh_egg_nest")
            inst["AnimState"]:PlayAnimation("idle")
            MakeObstaclePhysics(inst, 0.6, 1.5)
            inst:AddTag("structure")
            inst:AddTag("hh_egg_nest")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")

            inst:AddComponent("lootdropper")
            addComWorkable(inst, 5)
            inst["components"]["workable"]:SetOnFinishCallback(function(nest_inst, worker)
                if nest_inst["components"]["lootdropper"] ~= nil then
                    nest_inst["components"]["lootdropper"]:DropLoot()
                end
                if nest_inst["components"]["container"] ~= nil then
                    nest_inst["components"]["container"]:DropEverything()
                    nest_inst["components"]["container"]:Close()
                end
                --敲了掉孵的蛋
                if HH_UTILS:HasComponents(nest_inst, "hh_egg_nest") then
                    local hh_egg_id = nest_inst["components"]["hh_egg_nest"]:GetEggId()
                    if hh_egg_id then
                        HH_UTILS:SpawnLaunchItem(nest_inst, hh_egg_id, 1)
                    end
                end
                local fx = SpawnPrefab("collapse_small")
                fx["Transform"]:SetPosition(nest_inst["Transform"]:GetWorldPosition())
                fx:SetMaterial("stone")
                nest_inst:Remove()
            end)

            --孵蛋组件
            inst:AddComponent("hh_egg_nest")
            inst["components"]["hh_egg_nest"]:SetFinishFn(function(_inst, egg_id)
                _inst["AnimState"]:OverrideSymbol("egg", "hh_egg_nest", "egg")
                -------------------测试----------------------------
                if HH_UTILS:IsHHType(egg_id, "string") then
                    HH_UTILS:SpawnCollapseFx(_inst)
                    if HH_EGG_CONFIG[egg_id] and HH_EGG_CONFIG[egg_id]["finish_fn"] then
                        HH_EGG_CONFIG[egg_id]["finish_fn"](_inst)
                    else
                        --补偿机制-无奖励返还蛋
                        HH_UTILS:SpawnLaunchItem(_inst, egg_id, 1)
                    end
                end
                -------------------测试----------------------------
            end)

            --交易者组件
            inst:AddComponent("trader")
            inst["components"]["trader"]["acceptnontradable"] = true  --可交易
            --可接受的物品
            inst["components"]["trader"]:SetAcceptTest(function(_inst, item)
                return HH_UTILS:HasComponents(_inst, "hh_egg_nest") and not _inst["components"]["hh_egg_nest"]:HasHatchedEgg()
                        and item and item:HasTag("hh_egg")
            end)
            --获得物品时执行函数
            inst["components"]["trader"]["onaccept"] = function(_inst, giver, item)
                if HH_UTILS:HasComponents(_inst, "hh_egg_nest") and item and item:HasTag("hh_egg")
                        and not _inst["components"]["hh_egg_nest"]:HasHatchedEgg()
                then
                    local egg_prefab_id = item["prefab"]
                    local base_egg_time = 480 * 5
                    if HH_EGG_CONFIG[egg_prefab_id] and HH_UTILS:IsHHType(HH_EGG_CONFIG[egg_prefab_id]["time"], "number") then
                        base_egg_time = HH_EGG_CONFIG[egg_prefab_id]["time"]
                    end
                    _inst["components"]["hh_egg_nest"]:StartHatchedEgg(egg_prefab_id, base_egg_time)
                end
            end
            --拒绝材料时执行
            inst["components"]["trader"]["onrefuse"] = function(_inst, giver, item)
                if item and item:HasTag("hh_egg") then
                    HH_UTILS:HHSay(giver, "已经有正在孵化的蛋了，请耐心等待孵化完成~")
                    return
                end
                HH_UTILS:HHSay(giver, "只能放未孵化的蛋~")
            end

            inst["GetHHSpDesc01"] = function(_inst, player)
                local egg_desc = "空"
                if HH_UTILS:HasComponents(_inst, "hh_egg_nest") then
                    egg_desc = _inst["components"]["hh_egg_nest"]:GetDebugString()
                end
                return {
                    ["title"] = "孵蛋",
                    ["desc"] = egg_desc,
                }
            end
            inst["GetHHSpDesc02"] = function(_inst, player)
                return {
                    ["title"] = "创意来源",
                    ["desc"] = string["format"]("踏雪寻梅%s", 3124),
                }
            end
        end,
    },
    ["hh_egg_exhibition_table"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_egg_nest.zip"),
        },
        ["name"] = "孵蛋展示台", ["recipe_str"] = "用来展示不同的蛋", ["desc"] = "用来展示不同的蛋",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_egg_nest")
            inst["AnimState"]:SetBuild("hh_egg_nest")
            inst["AnimState"]:PlayAnimation("idle")
            MakeObstaclePhysics(inst, 0.6, 1.5)
            inst:AddTag("structure")
            inst:AddTag("hh_egg_exhibition_table")
            if not TheWorld["ismastersim"] then
                inst["OnEntityReplicated"] = function(_inst)
                    _inst["replica"]["container"]:WidgetSetup(name)
                end
            end
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("container")
            inst["components"]["container"]:WidgetSetup(name)
            --inst["components"]["container"]["skipclosesnd"] = true
            --inst["components"]["container"]["skipopensnd"] = true
            inst:ListenForEvent("itemget", function(_inst, data)
                if not data["item"] or not data["item"]["prefab"] then
                    _inst["AnimState"]:OverrideSymbol("egg", "hh_egg_nest", "egg")
                    return
                end
                _inst["AnimState"]:OverrideSymbol("egg", "hh_eggs", tostring(data["item"]["prefab"]))
            end)
            inst:ListenForEvent("itemlose", function(_inst, data)
                _inst["AnimState"]:OverrideSymbol("egg", "hh_egg_nest", "egg")
            end)

            inst:AddComponent("lootdropper")
            addComWorkable(inst, 5)
            inst["GetHHSpDesc02"] = function(_inst, player)
                return {
                    ["title"] = "创意来源",
                    ["desc"] = "踏雪寻梅3124",
                }
            end
        end,
    },
    --["hh_test_fx"] = {
    --    ["assets"] = {},
    --    ["name"] = "hh_test_fx", ["recipe_str"] = "hh_test_fx", ["desc"] = "hh_test_fx",
    --    ["client_fn"] = function(inst, name)
    --        inst["AnimState"]:SetBank("rook")
    --        inst["AnimState"]:SetBuild("rook_rhino")
    --        inst["AnimState"]:PlayAnimation("idle", true)
    --        inst["Transform"]:SetScale(0.7, 0.7, 0.7)
    --        --inst["AnimState"]:SetScale(0.7, 0.7, 0.7)
    --        inst["Transform"]:SetFourFaced()
    --        inst:AddTag("FX")
    --        inst:AddTag("NOCLICK")
    --    end,
    --    ["server_fn"] = function(inst, name)
    --        inst["persists"] = false
    --    end,
    --},
    ["hh_egg_common"] = commonEggFn("hh_egg_common", "普通的蛋", "看起来平平无奇", "看起来平平无奇");
    ["hh_egg_gold"] = commonEggFn("hh_egg_gold", "大金蛋", "感觉可以孵出好东西", "感觉可以孵出好东西");
    ["hh_egg_silver"] = commonEggFn("hh_egg_silver", "大银蛋", "中规中矩吧", "中规中矩吧");
    ["hh_egg_black"] = commonEggFn("hh_egg_black", "大黑蛋", "一个[幸运]的人", "一个[幸运]的人");
    ["hh_egg_cat_claw_orange"] = commonEggFn("hh_egg_cat_claw_orange", "异色[猫爪]-橘色", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_cat_claw_purple"] = commonEggFn("hh_egg_cat_claw_purple", "异色[猫爪]-紫色", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_cat_claw_green"] = commonEggFn("hh_egg_cat_claw_green", "异色[猫爪]-绿色", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_cat_claw_blue"] = commonEggFn("hh_egg_cat_claw_blue", "异色[猫爪]-蓝色", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_blue_star"] = commonEggFn("hh_egg_figure_blue_star", "异色[花纹]-蓝星", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_green_black"] = commonEggFn("hh_egg_figure_green_black", "异色[花纹]-绿黑", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_purple_black"] = commonEggFn("hh_egg_figure_purple_black", "异色[花纹]-紫黑", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_red_black"] = commonEggFn("hh_egg_figure_red_black", "异色[花纹]-红黑", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_red_blue"] = commonEggFn("hh_egg_figure_red_blue", "异色[花纹]-红蓝", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_yellow_green"] = commonEggFn("hh_egg_figure_yellow_green", "异色[花纹]-黄绿", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_figure_yellow_green_purple"] = commonEggFn("hh_egg_figure_yellow_green_purple", "异色[花纹]-三色", "异色花纹蛋", "异色花纹蛋");
    ["hh_egg_starry_sky"] = commonEggFn("hh_egg_starry_sky", "★异色[星空]-绝版", "充满神秘的宝藏", "充满神秘的宝藏");
    ----------------------------------------------------------装备-----------------------------------------------------------------------------
    ["hh_hat_star"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_hat_star.zip"),
            Asset("IMAGE", "images/hh_icon/hh_hat_star.tex"),
            Asset("ATLAS", "images/hh_icon/hh_hat_star.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_hat_star.xml", 256),
        },
        ["name"] = "彩曜星环", ["recipe_str"] = "彩曜星环", ["desc"] = "彩曜星环",
        ["xml"] = "images/hh_icon/hh_hat_star.xml", ["tex"] = "hh_hat_star.tex",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_hat_star")
            inst["AnimState"]:SetBuild("hh_hat_star")
            inst["AnimState"]:PlayAnimation("idle", true)
            --inst["AnimState"]:Hide("SparkleBit_round")
            inst["AnimState"]:SetSymbolMultColour("SparkleBit_round", 255 / 255, 255 / 255, 255 / 255, 0)
            inst["AnimState"]:SetBloomEffectHandle("shaders/anim.ksh")
            inst["AnimState"]:SetSymbolLightOverride("pb_energy_loop", 0.5)
            inst["AnimState"]:SetSymbolLightOverride("pb_ray", 0.5)
            inst["AnimState"]:SetSymbolLightOverride("SparkleBit", 0.5)
            inst["AnimState"]:SetSymbolLightOverride("lunar_seed_loop", 0.15)

            inst:AddTag("hh_boss_equip")
            --local inst_scale = 0.8
            --inst["Transform"]:SetScale(inst_scale, inst_scale, inst_scale)
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_hat_star.xml"
            --inst["components"]["inventoryitem"]:SetOnPickupFn(function(_inst, owner)
            --end)
            --加个光
            inst["components"]["inventoryitem"]:SetOnDroppedFn(starHatAddLight)
            inst["components"]["inventoryitem"]:SetOnPutInInventoryFn(starHatRemoveLight)
            starHatAddLight(inst)

            inst:AddComponent("named")
            inst:AddComponent("equippable")
            inst["components"]["equippable"]["equipslot"] = EQUIPSLOTS["HEAD"]
            inst["components"]["equippable"]:SetOnEquip(equipHatStar)
            inst["components"]["equippable"]:SetOnUnequip(unEquipHatStar)

            inst:AddComponent("armor")
            inst["components"]["armor"]:InitCondition(hat_star_base_amount, hat_star_base_absorb)

            --位面防御
            inst:AddComponent("planardefense")
            inst["components"]["planardefense"]:SetBaseDefense(1)

            inst:AddComponent("hh_hat_star")
            inst["components"]["hh_hat_star"]:SetName("彩曜星环")
            inst["components"]["hh_hat_star"]:SetFixUseFn(hatStarFixUseFn)
            inst["components"]["hh_hat_star"]:SetStarConfig(hh_hat_star_config)
            --升星函数
            inst["components"]["hh_hat_star"]:SetStarFn(hatStarFixUseFn)
            --inst["components"]["hh_hat_star"]:SetBindUID("KU_UIG3iJFW", "玩家名󰀜󰀜󰀜󰀜")
            --inst["components"]["hh_hat_star"]:SetFixedUse(true)--无限耐久
            --inst["components"]["hh_hat_star"]:SetStarNum(2)
            inst["components"]["hh_hat_star"]:UpdateName()
            --inst["GetHHSpDesc01"] = function(_inst, player)
            --    local test_str = "?"
            --    test_str = _inst["components"]["hh_hat_star"]:GetDeBugString()
            --    return {
            --        ["title"] = "测试",
            --        ["desc"] = test_str,
            --    }
            --end
        end,
    },
    ["hh_hat_star_fx"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hat_alterguardian_equipped.zip"),
            Asset("ANIM", "anim/hh_hat_star.zip"),
        },
        ["name"] = "星星王冠特效", ["recipe_str"] = "星星王冠特效", ["desc"] = "星星王冠特效",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hat_alterguardian_equipped")
            inst["AnimState"]:SetBuild("hat_alterguardian_equipped")
            inst["AnimState"]:PlayAnimation("activate_loop", true)
            inst["AnimState"]:OverrideSymbol("p4_piece", "hh_hat_star", "hh_hat_star")
            inst["AnimState"]:OverrideSymbol("flame_swap", "hat_alterguardian_equipped", "flame_loop")
            --inst["AnimState"]:OverrideSymbol("flame_outline_swap", "hat_alterguardian_equipped", "flame_outline_loop")
            inst["AnimState"]:SetFinalOffset(1)
            inst["AnimState"]:SetBloomEffectHandle("shaders/anim.ksh")
            inst["AnimState"]:SetSymbolMultColour("flame_swap", 1, 1, 1, 0.2)
            inst["AnimState"]:SetSymbolLightOverride("flame_swap", 0.5)
            inst["Transform"]:SetNoFaced()
            local inst_scale = 1
            inst["Transform"]:SetScale(inst_scale, inst_scale, inst_scale)
            inst:AddTag("FX")
            inst:AddTag("NOCLICK")
            inst:AddTag("CLASSIFIED")
            inst:AddTag("DECOR")
        end,
        ["server_fn"] = function(inst, name)
            inst["persists"] = false

            inst["OnActivated"] = function(_inst, owner, is_front)
                _inst["entity"]:SetParent(owner["entity"])
                _inst["entity"]:AddFollower()
                _inst["Follower"]:FollowSymbol(owner["GUID"], "hair", 0, 50, 0) -- "swap_hat"
                _inst["AnimState"]:Hide(is_front and "back" or "front")
                _inst["AnimState"]:SetFinalOffset(is_front and 1 or -1)
            end
        end,
    },
    ----------------------------------------------------------装备-----------------------------------------------------------------------------
    ["hh_talk_fx"] = {
        ["assets"] = {},
        ["name"] = "说话特效", ["recipe_str"] = "说话特效", ["desc"] = "说话特效",
        ["client_fn"] = function(inst, name)
            inst:AddTag("FX")
            inst:AddTag("NOCLICK")
            inst:AddTag("NOBLOCK")
            inst:AddTag("CLASSIFIED")
            inst:AddComponent("talker")
            inst["components"]["talker"]["font"] = NUMBERFONT
            inst["components"]["talker"]["fontsize"] = 30
            inst["say_data"] = net_string(inst["GUID"], "say_data", "say_data")
            inst:ListenForEvent("say_data", updateSayData)
        end,
        ["server_fn"] = function(inst, name)
            inst["persists"] = false
            inst["UpdateTalkData"] = updateServerSayData
            inst:DoTaskInTime(3, inst["Remove"])
        end,
    },
}

return HH_PREFAB
local HH_UTILS = require("utils/hh_utils")
local HH_ITEMS_CONFIG = require("enums/hh_items")
local hh_component_desc_list = require("enums/hh_hoverer")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]
local show_info_config = GetModConfigData("hoverer_effect")
----食物入锅标签
local cooking = require("cooking")
local hh_cook_tags = cooking["ingredients"]
local HH_FOOD_TYPE = {
    ["GENERIC"] = "通用",
    ["MEAT"] = "肉类",
    ["VEGGIE"] = "蔬菜",
    ["ELEMENTAL"] = "自然元素",
    ["GEARS"] = "齿轮",
    ["HORRIBLE"] = "噩梦",
    ["INSECT"] = "昆虫",
    ["SEEDS"] = "种子",
    ["BERRY"] = "浆果",
    ["RAW"] = "未加工",
    ["BURNT"] = "烧焦物",
    ["ROUGHAGE"] = "饲料",
    ["WOOD"] = "木料",
    ["GOODIES"] = "零食",
    ["MONSTER"] = "怪物",
    ["NIL"] = "未定义",
}

----工具类型
local HH_TOOL_TYPE = {
    ["CHOP"] = "砍",
    ["DIG"] = "挖",
    ["HAMMER"] = "锤",
    ["MINE"] = "开采",
    ["NET"] = "捕捉",
    ["PLAY"] = "吹奏",
    ["UNSADDLE"] = "解鞍",
    ["REACH_HIGH"] = " 抵达",
}

----食物标签
local HH_FOOD_TAGS = {
    ["veggie"] = "蔬菜",
    ["fruit"] = "水果",
    ["monster"] = "怪物",
    ["sweetener"] = "甜味",
    ["meat"] = "肉类",
    ["fish"] = "鱼类",
    ["magic"] = "魔法",
    ["egg"] = "蛋类",
    ["decoration"] = "鳞翅",
    ["dairy"] = "乳制品",
    ["fat"] = "油脂",
    ["inedible"] = "枝条",
    ["frozen"] = "冰",
    ["seed"] = "种子",
    ["fungus"] = "菌类", --all mushroom caps + cutlichen
    ["mushrooms"] = "蘑菇", --all mushroom caps
    ["poultry"] = "禽肉",
    ["wings"] = "翅膀", --about batwing
    ["seafood"] = "海鲜",
    ["nut"] = "坚果",
    ["cactus"] = "仙人掌",
    ["starch"] = "淀粉", --about corn, pumpkin, cave_banana
    ["grapes"] = "葡萄", --grapricot
    ["citrus"] = "柑橘", --grapricot_cooked, limon
    ["tuber"] = "块茎", --yamion
    ["shellfish"] = "贝类", --limpets, mussel
    ["rawmilk"] = "奶",
    ["bulb"] = "荧光果", --lightbulb
    ["spices"] = "香料",
    ["challa"] = "哈拉面包", -- Challah bread
    ["flour"] = "面粉", --flour
    ["cacao_cooked"] = "可可",
}
----处理多参数拼接字符串
local function handleFormatStr(hh_table, key, ...)
    if hh_table and hh_component_desc_list[key] and hh_component_desc_list[key]["format"] then
        if not hh_table[key] then
            hh_table[key] = {}
        end
        hh_table[key]["bool"] = true
        hh_table[key]["str"] = string["format"](hh_component_desc_list[key]["format"], ...)
    end
end
--获取实体文件路径
local function GetSourceString(inst)
    local prefab = _G["Prefabs"][inst["prefab"]]
    local info = debug["getinfo"](prefab.fn, "S")
    return info["source"]
end
local function NotIsDead(inst)
    if inst:IsValid() and HH_UTILS:HasComponents(inst, "health")
            and not inst["components"]["health"]:IsDead() then
        return true
    end
    return false
end
----
---新鲜度转换为天数-需要兼容各个季节的变化
---
local function GetPerishTime(inst, current_perishable)
    if not HH_UTILS:IsHHType(current_perishable, "number")
            or current_perishable <= 0
    then
        return 0
    end
    local modifier = 1
    local owner = inst["components"]["inventoryitem"] and inst["components"]["inventoryitem"]["owner"] or nil
    if not owner and inst["components"]["occupier"] then
        owner = inst["components"]["occupier"]:GetOwner()
    end

    local pos = owner ~= nil and owner:GetPosition() or inst:GetPosition()

    if owner then
        if owner["components"]["preserver"] ~= nil then
            modifier = owner["components"]["preserver"]:GetPerishRateMultiplier(inst) or modifier
        elseif owner:HasTag("fridge") then
            if inst:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("lowcool") then
                modifier = TUNING["PERISH_COLD_FROZEN_MULT"]
            else
                modifier = TUNING["PERISH_FRIDGE_MULT"]
            end
        elseif owner:HasTag("foodpreserver") then
            modifier = TUNING["PERISH_FOOD_PRESERVER_MULT"]
        elseif owner:HasTag("cage") and inst:HasTag("small_livestock") then
            modifier = TUNING["PERISH_CAGE_MULT"]
        end

        if owner:HasTag("spoiler") then
            modifier = modifier * TUNING["PERISH_GROUND_MULT"]
        end
    else
        modifier = TUNING["PERISH_GROUND_MULT"]
    end

    if inst:GetIsWet() and not inst["components"]["perishable"]["ignorewentness"] then
        modifier = modifier * TUNING["PERISH_WET_MULT"]
    end

    if GetTemperatureAtXZ(pos["x"], pos["z"]) < 0 then
        if inst:HasTag("frozen") and not inst["components"]["perishable"]["frozenfiremult"] then
            modifier = TUNING["PERISH_COLD_FROZEN_MULT"]
        else
            modifier = modifier * TUNING["PERISH_WINTER_MULT"]
        end
    end

    if inst["components"]["perishable"]["frozenfiremult"] then
        modifier = modifier * TUNING["PERISH_FROZEN_FIRE_MULT"]
    end

    if GetTemperatureAtXZ(pos["x"], pos["z"]) > TUNING["OVERHEAT_TEMP"] then
        modifier = modifier * TUNING["PERISH_SUMMER_MULT"]
    end

    modifier = modifier * inst["components"]["perishable"]["localPerishMultiplyer"]

    modifier = modifier * TUNING["PERISH_GLOBAL_MULT"]

    local delta = current_perishable / modifier
    return math["max"](delta, 0)
end

--nice round function
local nice_number = function(num, idp)
    return tonumber(string["format"]("%." .. (idp or 0) .. "f", num))
end
local function strToNum(num)
    local result = num
    if HH_UTILS:IsHHType(num, "number") then
        result = math["floor"](num)
    end
    return tostring(result)
end
local function getAllItemInfo(hh_copy_list, player, item, item_com, item_prefab)
    if show_info_config then

        local player_com = player["components"]
        ----====>血量<====----
        if item_com["health"] then
            local current_health = string["format"]("%.0f", item_com["health"]["currenthealth"] or "0")
            local max_health = string["format"]("%.0f", item_com["health"]["maxhealth"] or "0")
            local hh_absorb = 0
            if item_com["health"]["absorb"] ~= 0 or item_com["health"]["playerabsorb"] ~= 0 then
                hh_absorb = math["min"]((1 - (1 - item_com["health"]["absorb"]) * (1 - item_com["health"]["playerabsorb"])) * 100, 100)
            end
            if item_com["health"]["externalabsorbmodifiers"] then
                hh_absorb = hh_absorb + (100 - hh_absorb) * math["min"](item_com["health"]["externalabsorbmodifiers"]:Get(), 1)
            end
            hh_absorb = string["format"]("%.1f", hh_absorb)
            handleFormatStr(hh_copy_list, "hh_02_health", current_health, max_health, hh_absorb)
        end
        ----====>饥饿<====----
        if item_com["hunger"] then
            if item_com["hunger"]["current"] and item_com["hunger"]["max"] then
                local current_hunger = string["format"]("%.0f", item_com["hunger"]["current"] or "0")
                local max_hunger = string["format"]("%.0f", item_com["hunger"]["max"] or "0")
                handleFormatStr(hh_copy_list, "hh_02_hunger", current_hunger, max_hunger)
            end
        end
        ----====>伤害<====----
        if item_com["combat"] then
            local default_damage = item_com["combat"]["defaultdamage"] or "0"
            local attack_range = item_com["combat"]["attackrange"] or "0"
            local damage_multiplier = item_com["combat"]["damagemultiplier"] or "1"
            handleFormatStr(hh_copy_list, "hh_03_combat", tostring(default_damage), tostring(attack_range), tostring(damage_multiplier))
        end
        ------====>武器<====----
        if item_com["weapon"] then
            local weapon_str = 0
            local weapon_range = 0
            local weapon_damage = item_com["weapon"]["damage"]
            if type(weapon_damage) ~= "number" then
                weapon_str = "？？？"
            else
                weapon_str = string["format"]("%.1f", item_com["weapon"]["damage"] or "0")
                weapon_range = item_com["weapon"]["attackrange"] or "1"
            end
            handleFormatStr(hh_copy_list, "hh_03_weapon", weapon_str, weapon_range)
        end
        ----====>食物<====----
        if item_com["edible"] then
            local can_show = false
            if HH_UTILS:HasComponents(player, "eater") then
                can_show = player_com["eater"]:CanEat(item)
            end
            if can_show then
                --判断新鲜度等等
                local hunger = nice_number(item_com["edible"]:GetHunger(player), 1)
                local sanity = nice_number(item_com["edible"]:GetSanity(player), 1)
                local health = nice_number(item_com["edible"]:GetHealth(player), 1)
                --item_com["edible"]["hungervalue"]
                --item_com["edible"]["sanityvalue"]
                --item_com["edible"]["healthvalue"]
                local food_type = HH_FOOD_TYPE[tostring(item_com["edible"]["foodtype"])] or "无类型"
                local base_mult = 1
                if HH_UTILS:HasComponents(player, "foodmemory") then
                    base_mult = player["components"]["foodmemory"]:GetFoodMultiplier(item_prefab) or 1
                end
                local hg_mult = (tonumber(player_com["eater"]["hungerabsorption"]) or 1) * base_mult
                local sn_mult = (tonumber(player_com["eater"]["sanityabsorption"]) or 1) * base_mult
                local hp_mult = (tonumber(player_com["eater"]["healthabsorption"]) or 1) * base_mult
                hunger = hunger * hg_mult
                sanity = sanity * sn_mult
                health = health * hp_mult
                handleFormatStr(hh_copy_list, "hh_04_edible", food_type, hunger, sanity, health)
            end
        end
        ----====>食物标签<====----
        if hh_cook_tags and hh_cook_tags[item_prefab] and HH_UTILS:IsHHType(hh_cook_tags[item_prefab]["tags"], "table") then
            local tag_str = ""
            for id, tag in pairs(hh_cook_tags[item_prefab]["tags"]) do
                if HH_FOOD_TAGS[id] then
                    tag_str = tag_str .. (HH_FOOD_TAGS[id] or "") .. tostring(tag)
                end
            end
            handleFormatStr(hh_copy_list, "hh_05_food_tag", tag_str)
        end
        ----====>护甲<====----
        if item_com["armor"] then
            local armor_absorb_percent = (item_com["armor"]["absorb_percent"] or 0) * 100
            local armor_str = armor_absorb_percent .. "% "
            --无限耐久
            if not item_com["armor"]["indestructible"] then
                local armor_condition = string["format"]("%.1f", item_com["armor"]["condition"] or "0")
                local max_condition = string["format"]("%.1f", item_com["armor"]["maxcondition"] or "0")
                armor_str = armor_str .. armor_condition .. "/" .. max_condition
            end
            handleFormatStr(hh_copy_list, "hh_06_armor", armor_str)
        end
        ----====>耐久<====----
        if item_com["finiteuses"] then
            local use_current = string["format"]("%.0f", item_com["finiteuses"]["current"] or "0")
            local use_total = string["format"]("%.0f", item_com["finiteuses"]["total"] or "0")
            handleFormatStr(hh_copy_list, "hh_07_finiteuses", use_current, use_total)
        end
        ----====>燃料<====----
        if item_com["fueled"] then
            local currentfuel = string["format"]("%.0f", item_com["fueled"]["currentfuel"] or "0")
            local maxfuel = string["format"]("%.0f", item_com["fueled"]["maxfuel"] or "0")
            handleFormatStr(hh_copy_list, "hh_08_fueled", currentfuel, maxfuel)
        end
        ----====>工具<====----
        if item_com["tool"] and item_com["tool"]["actions"] then
            local actions = item_com["tool"]["actions"]
            local tool_string = ""
            for k, v in pairs(actions) do
                if k and k["id"] and HH_TOOL_TYPE[k["id"]] and HH_UTILS:IsHHType(v, "number") then
                    tool_string = tool_string .. HH_TOOL_TYPE[k["id"]] .. nice_number(v, 1) .. " "
                end
            end
            handleFormatStr(hh_copy_list, "hh_09_tool", tool_string)
        end
        ----====>堆叠<====----
        if item_com["stackable"] then
            local stacksize = item_com["stackable"]["stacksize"] or "0"
            local maxsize = item_com["stackable"]["maxsize"] or "0"
            local max_str = "无上限"
            if maxsize ~= math["huge"] then
                max_str = tostring(maxsize)
            end
            handleFormatStr(hh_copy_list, "hh_10_stackable", stacksize, max_str)
        end
        ----====>淘气值<====----
        --if NAUGHTY_VALUE[item_prefab] and not type(NAUGHTY_VALUE[item_prefab]) == "function" then
        --    handleFormatStr(hh_copy_list, "hh_11_naughty_value", tostring(NAUGHTY_VALUE[item_prefab]) or "0")
        --end
        ----====>容器container<====----
        if item_com["container"] then
            local num = 0
            local container_str = ""
            if HH_UTILS:IsHHType(item_com["container"]["slots"], "table") then
                for i, v in pairs(item_com["container"]["slots"]) do
                    num = num + 1
                    if v["components"]["stackable"] and v["components"]["stackable"]["stacksize"] then
                        container_str = container_str .. (v["name"] or "未定义") .. "x" .. v["components"]["stackable"]["stacksize"] .. " "
                    else
                        container_str = container_str .. (v["name"] or "未定义") .. " "
                    end
                end
            end
            if HH_UTILS:GetStringWordNum(container_str) > 20 then
                container_str = HH_UTILS:SubStringUTF8(container_str, 1, 20) .. "..."
            end
            if container_str ~= "" then
                container_str = "\n物品:" .. container_str
            end
            handleFormatStr(hh_copy_list, "hh_12_container", num, item_com["container"]["numslots"] or "0", container_str)
        end
        ----====>新鲜度<====----
        if item_com["perishable"] then
            local current_perishable = item_com["perishable"]["perishremainingtime"]
            local perishable_time = GetPerishTime(item, current_perishable)
            handleFormatStr(hh_copy_list, "hh_13_perishable", string["format"]("%.1f", perishable_time / TUNING["TOTAL_DAY_TIME"]))
        end
        ----====>包裹<====----
        if item_com["unwrappable"] and item_com["unwrappable"]["itemdata"] and type(item_com["unwrappable"]["itemdata"]) == "table" then
            local unwrappableStr = ""
            for i, v in ipairs(item_com["unwrappable"]["itemdata"]) do
                if v["prefab"] then
                    --v["data"]取自对应组件的save函数参数
                    local delta = v["data"] and v["data"]["perishable"] and v["data"]["perishable"]["time"]
                    local count = v["data"] and v["data"]["stackable"] and v["data"]["stackable"]["stack"]
                    local item_child_name = v["data"] and v["data"]["named"] and v["data"]["named"]["name"] or v["name"] or "未定义"
                    --官方物品无法读取 特殊处理
                    item_child_name = STRINGS["NAMES"][string["upper"](v["prefab"])] or "未定义名字的物品道具"
                    if i ~= 1 then
                        unwrappableStr = unwrappableStr .. "\n"
                    end
                    unwrappableStr = unwrappableStr .. tostring(item_child_name)
                    if delta ~= nil then
                        unwrappableStr = unwrappableStr .. "(" .. string["format"]("%.1f", delta / TUNING["TOTAL_DAY_TIME"]) .. "天)"
                    end
                    if count ~= nil then
                        unwrappableStr = unwrappableStr .. "x" .. count
                    end
                end
            end
            --print("含有物品")
            handleFormatStr(hh_copy_list, "hh_14_unwrappable", unwrappableStr)
        end

        ----====>烹饪锅<====----
        if item_com["stewer"] and item_com["stewer"]["product"]
                and item_com["stewer"]["IsCooking"] and item_com["stewer"]:IsCooking()
        then
            local cook_time = item_com["stewer"]["targettime"] - GetTime()
            if cook_time < 0 then
                cook_time = 0
            end
            local product = item_com["stewer"]["product"]
            handleFormatStr(hh_copy_list, "hh_15_stewer", STRINGS["NAMES"][string["upper"](tostring(product))] or "未定义", string["format"]("%.0f", cook_time))
        end
        ----====>生长<====----
        if item_com["growable"] and item_com["growable"]["stage"] then
            local grow_time = (item_com["growable"]["pausedremaining"] ~= nil
                    and math.max(0, math["floor"](item_com["growable"]["pausedremaining"])))
                    or (item_com["growable"]["targettime"] ~= nil and math["floor"](item_com["growable"]["targettime"] - GetTime()))
                    or nil
            if grow_time then
                local stage = item_com["growable"]["stage"] ~= 1 and tonumber(item_com["growable"]["stage"]) or 1;
                local data = item_com["growable"]["stages"] and item_com["growable"]["stages"][stage];
                handleFormatStr(hh_copy_list, "hh_16_growable", data and data["name"] or stage,
                        string["format"]("%.1f", grow_time / TUNING["TOTAL_DAY_TIME"]))
            end
        end
        ----====>成熟<====----
        if item_com["pickable"] and item_com["pickable"]["task"] and item_com["pickable"]["targettime"] then
            local delta = item_com["pickable"]["targettime"] - GetTime()
            if delta > 0 then
                handleFormatStr(hh_copy_list, "hh_17_pickable", string["format"]("%.1f", delta / TUNING["TOTAL_DAY_TIME"]))
            end
        end
        ----====>保暖隔热<====----
        if item_com["insulator"] and HH_UTILS:IsHHType(item_com["insulator"]["insulation"], "number")
                and item_com["insulator"]["insulation"] ~= 0
        then
            local insulator_str = string["format"]("%.0f", item_com["insulator"]["insulation"] or 0)
            handleFormatStr(hh_copy_list, "hh_18_insulator", insulator_str)
            if item_com["insulator"]["type"] == SEASONS["WINTER"] then
                hh_copy_list["hh_18_insulator"]["name"] = "保暖"
            elseif item_com["insulator"]["type"] == SEASONS["SUMMER"] then
                hh_copy_list["hh_18_insulator"]["name"] = "隔热"
            end
        end
        ----====>可钓<====----
        if item_com["fishable"] and item_com["fishable"]["fishleft"] and type(item_com["fishable"]["fishleft"]) == "number" then
            handleFormatStr(hh_copy_list, "hh_20_fishable", string["format"]("%.0f", item_com["fishable"]["fishleft"]))
        end

        ----====>忠诚<====----
        if item_com["follower"] and item_com["follower"]["leader"]
                and item_com["follower"]["leader"]:IsValid()
                and item_com["follower"]["leader"]:HasTag("player")
                and item_com["follower"]["leader"]["name"]
                and item_com["follower"]["leader"]["name"] ~= ""
        then
            local hh_leader = item_com["follower"]["leader"]["name"]
            local hh_leader_time = 0
            if item_com["follower"]["maxfollowtime"] then
                hh_leader_time = item_com["follower"]["maxfollowtime"]
            end
            local percent = item_com["follower"]:GetLoyaltyPercent()
            handleFormatStr(hh_copy_list, "hh_21_follower", hh_leader, math["floor"](percent * hh_leader_time + 0.5))
        end
        ----====>移速<====----
        if item_com["equippable"]
                and item_com["equippable"]["walkspeedmult"]
                and item_com["equippable"]["walkspeedmult"] ~= 1
        then
            local added_speed = math["floor"]((item_com["equippable"]["walkspeedmult"] - 1) * 100 + 0.5)
            handleFormatStr(hh_copy_list, "hh_23_equippable", nice_number(added_speed))
        end
        ----====>价值<====----
        if item_com["tradable"] and ((item_com["tradable"]["goldvalue"] and item_com["tradable"]["goldvalue"] > 0)
                or (item_com["tradable"]["rocktribute"] and item_com["tradable"]["rocktribute"] > 0))
        then
            local golden_num = 0
            local rock_num = 0
            if item_com["tradable"]["goldvalue"] and item_com["tradable"]["goldvalue"] > 0 then
                golden_num = item_com["tradable"]["goldvalue"]
            end
            if item_com["tradable"]["rocktribute"] and item_com["tradable"]["rocktribute"] > 0 then
                rock_num = item_com["tradable"]["rocktribute"]
            end
            handleFormatStr(hh_copy_list, "hh_24_tradable", golden_num, rock_num)
        end
        ----====>生物<====----
        if item_com["childspawner"] and item_com["childspawner"]["childreninside"] and item_com["childspawner"]["maxchildren"] then
            local inside = tonumber(item_com["childspawner"]["childreninside"])
            local maximum = tonumber(item_com["childspawner"]["maxchildren"])
            if inside and inside ~= 0 and maximum and maximum ~= 0 then
                handleFormatStr(hh_copy_list, "hh_26_childspawner", string["format"]("%.0f", inside), string["format"]("%.0f", maximum))
            end
        end
        ----====>驯化<====----
        if item_com["domesticatable"] ~= nil then
            local obedience = 0
            local domest = 0
            local domesticatable_str = ""
            local domesticatable_bool = false
            if item_com["domesticatable"]["GetObedience"] and type(item_com["domesticatable"]:GetDomestication()) == "number" then
                domesticatable_bool = true
                obedience = tonumber(item_com["domesticatable"]:GetObedience()) * 100
                domesticatable_str = domesticatable_str .. "顺从:" .. string["format"]("%.0f", obedience) .. "%"
            end
            if item_com["domesticatable"]["GetDomestication"] and type(item_com["domesticatable"]:GetDomestication()) == "number" then
                domesticatable_bool = true
                domest = tonumber(item_com["domesticatable"]:GetDomestication()) * 100
                domesticatable_str = domesticatable_str .. "驯化:" .. string["format"]("%.0f", domest) .. "%"
            end
            if domesticatable_bool then
                handleFormatStr(hh_copy_list, "hh_27_domesticatable", domesticatable_str)
            end
        end
        ----====>晾干<====----
        if item_com["dryer"] and item_com["dryer"]["IsDrying"] then
            if item_com["dryer"]:IsDrying() and item_com["dryer"]["GetTimeToDry"] then
                handleFormatStr(hh_copy_list, "hh_28_dryer", string["format"]("%.1f", item_com["dryer"]:GetTimeToDry() / TUNING["TOTAL_DAY_TIME"]) .. "天后晾干")
            elseif item_com["dryer"]["IsDone"] and item_com["dryer"]:IsDone() and item_com["dryer"]["GetTimeToSpoil"] then
                handleFormatStr(hh_copy_list, "hh_28_dryer", string["format"]("%.1f", item_com["dryer"]:GetTimeToSpoil() / TUNING["TOTAL_DAY_TIME"]) .. "天后腐烂")
            end
        end
        ----====>作物<====----
        if item_com["farmplantstress"] and item_com["farmplantstress"]["stress_points"] then
            local stress = item_com["farmplantstress"]["stress_points"]
            handleFormatStr(hh_copy_list, "hh_29_farmplantstress", stress)
        end
        ----====>火烤<====----
        if item_com["cookable"] and item_com["cookable"]["product"] then
            local cook_product = item_com["cookable"]["product"]
            if type(cook_product) == "string" then
                handleFormatStr(hh_copy_list, "hh_30_cookable", STRINGS["NAMES"][string["upper"](tostring(cook_product))] or "未定义产物")
            end
        end
        ----====>移速<====----
        if item_com["locomotor"] and item_com["locomotor"]["walkspeed"] and item_com["locomotor"]["runspeed"] then
            local speed_num = item_com["locomotor"]["runspeed"]
            local walk_speed = item_com["locomotor"]["walkspeed"]
            handleFormatStr(hh_copy_list, "hh_31_locomotor", strToNum(speed_num), strToNum(walk_speed))
        end
    end
    ----====>特殊标签<====----
    if item["hh_tags"] and HH_UTILS:IsHHType(item["hh_tags"], "table") then
        local tag_sort = HH_UTILS:TableSortKeys(item["hh_tags"])
        if #tag_sort > 0 then
            local tag_str = ""
            for i, v in ipairs(tag_sort) do
                local tag_name = tostring(item["hh_tags"][v])
                tag_str = tag_str .. tag_name .. " "
            end
            handleFormatStr(hh_copy_list, "hh_31_hh_tag", tag_str)
        end
    end
    ----====>物品描述<====----
    local item_desc = ""
    local desc_success, desc = pcall(function()
        return GetDescription(player, item)
    end)
    if desc_success and HH_UTILS:IsHHType(desc, "string") then
        item_desc = desc
        local desc_num = HH_UTILS:GetStringWordNum(item_desc)
        if desc_num > 20 then
            item_desc = HH_UTILS:SubStringUTF8(item_desc, 1, 20) .. "..."
        end
        handleFormatStr(hh_copy_list, "hh_01_text", tostring(item_desc))
    end
    ----====>装备强化<====----
    if item_com["hh_equip"] then
        local hh_gem_str = item_com["hh_equip"]:GetGemDebugString()
        handleFormatStr(hh_copy_list, "hh_32_hh_gem", tostring(hh_gem_str))
        hh_copy_list["hh_32_hh_gem"]["child_ui"] = item_com["hh_equip"]:GetGemDebugList()
        if item_com["hh_equip"]:CanShowBuffUi() then
            local buff_str = item_com["hh_equip"]:GetBuffDebugString()
            handleFormatStr(hh_copy_list, "hh_32_hh_equip", tostring(buff_str))
            hh_copy_list["hh_32_hh_equip"]["child_ui"] = item_com["hh_equip"]:GetBuffDebugList(player)
            --显示套装激活属性
            local hh_suit = item_com["hh_equip"]:HasSuitEffect()
            if hh_suit and TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][hh_suit]
                    and HH_UTILS:CheckSuitEffect(player, hh_suit)
            then
                local suit_desc = TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][hh_suit]["effect_str"]
                handleFormatStr(hh_copy_list, "hh_32_hh_equip_suit", tostring(suit_desc))
            end
            --星级移除
            --local star_num = item_com["hh_equip"]:GetEquipStars()
            --if star_num > 0 then
            --    local star_str = ""
            --    for i = 1, star_num do
            --        star_str = star_str .. "★"
            --    end
            --    handleFormatStr(hh_copy_list, "hh_32_hh_equip_star", tostring(star_str))
            --end
        end
    end
    ----====>人物属性<====----
    if item_com["hh_player"] then
        local player_effect_str = item_com["hh_player"]:GetDebugStr()
        handleFormatStr(hh_copy_list, "hh_32_hh_player", tostring(player_effect_str))
    end
    ----====>附魔石<====----
    if item_prefab == "hh_effect_stone" and item["hh_effect"] and HH_EQUIP_BUFF_LIST[item["hh_effect"]] then
        local effect_id = item["hh_effect"]
        local hh_gem_str = HH_EQUIP_BUFF_LIST[effect_id]["name"]
        if HH_EQUIP_BUFF_LIST[effect_id]["desc"] then
            local replace_str = "?"
            if HH_EQUIP_BUFF_LIST[effect_id]["value_range"] then
                replace_str = HH_UTILS:Template("({{min}}~{{max}})", HH_EQUIP_BUFF_LIST[effect_id]["value_range"])
                hh_gem_str = string["format"](HH_EQUIP_BUFF_LIST[effect_id]["desc"], replace_str)
            else
                hh_gem_str = HH_EQUIP_BUFF_LIST[effect_id]["desc"]
            end
            --展示前置条件 更加直观
            if HH_EQUIP_BUFF_LIST[effect_id]["check_desc"] then
                local check_str = HH_EQUIP_BUFF_LIST[effect_id]["check_desc"]
                handleFormatStr(hh_copy_list, "hh_32_hh_gem_check", tostring(check_str))
            end
        end
        handleFormatStr(hh_copy_list, "hh_32_hh_gem", tostring(hh_gem_str))
    end
    if item_com["hh_monster"] then
        local buff_num = item_com["hh_monster"]:GetAllBuffNum()
        if buff_num > 0 then
            local monster_debug = item_com["hh_monster"]:GetDebugString()
            handleFormatStr(hh_copy_list, "hh_32_hh_monster", monster_debug)
        end
    end
    --if HH_UTILS:HasReplica(item, "inventoryitem") then
    --    local image_xml = item["replica"]["inventoryitem"]:GetAtlas()
    --    handleFormatStr(hh_copy_list, "hh_99_image", tostring(image_xml))
    --end
    ----====>宝石归属<====----
    if item_prefab == "hh_save_stone" then
        local save_list = item["hh_save_list"]
        if HH_UTILS:IsHHType(save_list, "table") and save_list["user_id"] then
            local save_user_id = save_list["user_id"]
            local save_user_name = save_list["user_name"]
            handleFormatStr(hh_copy_list, "hh_32_hh_save", tostring(save_user_id), tostring(save_user_name))
        end
    end
    --本地测试显示代码
    if player["HHNeedShowInfo"] then
        ------====>代码<====----
        handleFormatStr(hh_copy_list, "hh_99_prefab", item_prefab)
        ------====>debug<====----
        local path_str = GetSourceString(item)
        local lastSlashIndex = string["find"](path_str, "/[^/]*$")
        if lastSlashIndex then
            local result = string["sub"](path_str, lastSlashIndex + 1)
            handleFormatStr(hh_copy_list, "hh_99_path", result)
        end
        ------====>动画<====----
        if item["AnimState"] and item["AnimState"]["GetHistoryData"] then
            local build = item["AnimState"]:GetBuild()
            local bank, idle = item["AnimState"]:GetHistoryData()
            handleFormatStr(hh_copy_list, "hh_99_idle", tostring(bank), tostring(build), tostring(idle))
        end
    end

    ----====>随从强化<====----
    if item_com["follower"] and item_com["follower"]["leader"]
            and HH_UTILS:HasComponents(item_com["follower"]["leader"], "hh_player") then
        local hh_leader = item_com["follower"]["leader"]
        if hh_leader["components"]["hh_player"]:HasSpecialEffect("addFollowDamage")
                or hh_leader["components"]["hh_player"]:HasSpecialEffect("addFollowReduceDamage")
                or hh_leader["components"]["hh_player"]:HasSpecialEffect("addFollowCritical")
        then
            local hh_damage = hh_leader["components"]["hh_player"]:GetEffectValueByKey("addFollowDamage")
            local hh_armor = hh_leader["components"]["hh_player"]:GetEffectValueByKey("addFollowReduceDamage")
            local hh_addFollowCritical = hh_leader["components"]["hh_player"]:GetEffectValueByKey("addFollowCritical")
            local follow_str = string["format"]("伤害(%s) 减伤(%s) 暴击(%s%%)", hh_damage, hh_armor, hh_addFollowCritical)
            handleFormatStr(hh_copy_list, "hh_33_hh_follow", follow_str)
        end
    end
    ----====>随从强化<====----
    ----====>通用等级<====----
    if item_com["hh_level"] then
        local hh_level_str = item_com["hh_level"]:GetHovererStr()
        handleFormatStr(hh_copy_list, "hh_33_hh_level", tostring(hh_level_str))
    end
    ----====>星星帽子<====----
    if item_com["hh_hat_star"] then
        local hh_hat_star_str = item_com["hh_hat_star"]:GetBindStr()
        handleFormatStr(hh_copy_list, "hh_34_boss_equip", tostring(hh_hat_star_str))
        local hh_hat_star_star_str = item_com["hh_hat_star"]:GetStarDisplay()
        handleFormatStr(hh_copy_list, "hh_02_boss_equip", tostring(hh_hat_star_star_str))
    end
    ----====>画师<====----
    --if item["hh_painter"] then
    --    handleFormatStr(hh_copy_list, "hh_99_painter", tostring(item["hh_painter"]))
    --end
    ----====>外部接口<====----
    if item["GetHHSpDesc01"] then
        local hh_desc_list = item:GetHHSpDesc01(player)
        if HH_UTILS:IsHHType(hh_desc_list, "table") then
            handleFormatStr(hh_copy_list, "hh_99_special_01", tostring(hh_desc_list["desc"]))
            if HH_UTILS:IsHHType(hh_desc_list["title"], "string") then
                hh_copy_list["hh_99_special_01"]["name"] = hh_desc_list["title"] .. ":"
            end
            if HH_UTILS:IsHHType(hh_desc_list["color"], "table") then
                hh_copy_list["hh_99_special_01"]["str_color"] = hh_desc_list["color"]
            end
        end
    end
    if item["GetHHSpDesc02"] then
        local hh_desc_list = item:GetHHSpDesc02(player)
        if HH_UTILS:IsHHType(hh_desc_list, "table") then
            handleFormatStr(hh_copy_list, "hh_99_special_02", tostring(hh_desc_list["desc"]))
            if HH_UTILS:IsHHType(hh_desc_list["title"], "string") then
                hh_copy_list["hh_99_special_02"]["name"] = hh_desc_list["title"] .. ":"
            end
            if HH_UTILS:IsHHType(hh_desc_list["color"], "table") then
                hh_copy_list["hh_99_special_02"]["str_color"] = hh_desc_list["color"]
            end
        end
    end
    if item["GetHHSpDesc03"] then
        local hh_desc_list = item:GetHHSpDesc03(player)
        if HH_UTILS:IsHHType(hh_desc_list, "table") then
            handleFormatStr(hh_copy_list, "hh_99_special_03", tostring(hh_desc_list["desc"]))
            if HH_UTILS:IsHHType(hh_desc_list["title"], "string") then
                hh_copy_list["hh_99_special_03"]["name"] = hh_desc_list["title"] .. ":"
            end
            if HH_UTILS:IsHHType(hh_desc_list["color"], "table") then
                hh_copy_list["hh_99_special_03"]["str_color"] = hh_desc_list["color"]
            end
        end
    end
    if item["GetHHSpDesc04"] then
        local hh_desc_list = item:GetHHSpDesc04(player)
        if HH_UTILS:IsHHType(hh_desc_list, "table") then
            handleFormatStr(hh_copy_list, "hh_99_special_04", tostring(hh_desc_list["desc"]))
            if HH_UTILS:IsHHType(hh_desc_list["title"], "string") then
                hh_copy_list["hh_99_special_04"]["name"] = hh_desc_list["title"] .. ":"
            end
            if HH_UTILS:IsHHType(hh_desc_list["color"], "table") then
                hh_copy_list["hh_99_special_04"]["str_color"] = hh_desc_list["color"]
            end
        end
    end
end
----
---获取实体详细信息
---

AddModRPCHandler("hh_rpc", "hh_hoverer_server", function(player, item, hh_target_name)
    if not (player and item and player:IsValid() and item:IsValid()) then
        return
    end
    --减少交互消耗
    local hh_copy_list = {}
    local item_prefab = item["prefab"]
    local item_com = item["components"]
    if item_prefab ~= "abigail" and item:HasTag("NOBLOCK") then
        return
    end
    --print(item_prefab, item["name"])

    ----====>物品客户端文本<====----
    if hh_target_name then
        handleFormatStr(hh_copy_list, "hh_01_name", tostring(hh_target_name))
    end
    --放异常中处理
    local success, result = pcall(getAllItemInfo, hh_copy_list, player, item, item_com, item_prefab)
    if not success then
        local exc_str = tostring(result)
        -- 找到冒号的位置
        local colonPosition = string["find"](exc_str, ":")
        local exc_text = "读取数据异常"
        if colonPosition then
            exc_text = string["sub"](exc_str, colonPosition + 1)
        end
        handleFormatStr(hh_copy_list, "hh_99_exception", tostring(exc_text))
    end
    ----====>外部接口<====----
    --local new_list = HH_UTILS:HHCopyTable(hh_copy_list)
    --校验是否需要同步
    local compare_table = HH_UTILS:HHCompareTable(player["HH_LAST_HOVERER_LIST"], hh_copy_list)
    --print(item["GUID"], "比较结果", compare_table)
    --HH_UTILS:HHPrint(hh_copy_list)
    if compare_table then
        SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_rpc_client"], player["userid"], "hh_hoverer_list", "刷新")
        return
    else
        SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_rpc_client"], player["userid"], "hh_hoverer_list", HH_UTILS:TableToStr(hh_copy_list))
        player["HH_LAST_HOVERER_LIST"] = HH_UTILS:HHCopyTable(hh_copy_list)
    end
end)
AddClientModRPCHandler("hh_rpc", "hh_rpc_client", function(key, data)
    if ThePlayer and key and type(key) == "string" then
        --print("长度", string.len(data))
        --没变通知服务器 没发生变化
        if data == "刷新" then
            --print("通知客户端没发生变化")
        else
            ThePlayer[key] = HH_UTILS:StrToTable(data)
        end
        ThePlayer:PushEvent("hh_update_hoverer")
    end
end)

local function hh_ui_container(inst, ui_name)
    if not NotIsDead(inst) or inst:HasTag("playerghost") then
        return
    end
    if inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding() then
        HH_UTILS:HHSayV2(inst, "骑牛状态无法操作")
        return
    end

    ----增加间隔防止一直点击按钮导致容器开关主客机不同步
    if inst["time_refiner"] then
        HH_UTILS:HHSayV2(inst, "点太快了")
        return
    end
    if inst["components"]["hh_player"] ~= nil then
        if ui_name then
            inst["components"]["hh_player"]:OpenSuitContainer()
        else
            inst["components"]["hh_player"]:OpenContainer("ui_container")
        end
    end
    inst["time_refiner"] = true
    inst:DoTaskInTime(0.2, function()
        inst["time_refiner"] = false
    end)
end
AddModRPCHandler("hh_rpc", "hh_ui_container", hh_ui_container)
local function hh_handle_equip(inst, rpc_type, gem_index)
    if not NotIsDead(inst) or inst:HasTag("playerghost")
            or not HH_UTILS:IsHHType(rpc_type, "string")
    then
        HH_UTILS:HHSayV2(inst, "当前状态不允许操作!!!")
        return
    end
    if inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding() then
        HH_UTILS:HHSayV2(inst, "骑牛状态无法操作")
        return
    end
    if not HH_UTILS:HasComponents(inst, "hh_player") then
        HH_UTILS:HHSayV2(inst, "没有权限使用!!!")
        return
    end
    --rpc间隔
    if inst["hh_rpc_cd"] then
        HH_UTILS:HHSayV2(inst, "点太快了!!!")
        --HH_UTILS:HHSayV2(inst, "点太快了!!!")
        return
    end

    local success, result = false, nil
    if rpc_type == "MoveEquips" then
        inst["components"]["hh_player"]:MoveEquips()
    elseif rpc_type == "RemoveEquips" then
        inst["components"]["hh_player"]:RemoveEquips()
    elseif rpc_type == "EquipGems" then
        if HH_UTILS:IsHHType(gem_index, "string") then
            if gem_index == "a_punchStone" then
                success, result = inst["components"]["hh_player"]:AddEquipGemsLimit()
            elseif gem_index == "a_stoneDecoder" then
                success, result = inst["components"]["hh_player"]:RemoveEquipGems(nil)
            elseif HH_ITEMS_CONFIG[gem_index] and HH_ITEMS_CONFIG[gem_index]["is_item"] then
                success, result = inst["components"]["hh_player"]:UseSpecialItem(gem_index)
            else
                success, result = inst["components"]["hh_player"]:AddEquipGems(gem_index)
            end
        end
    elseif rpc_type == "AddEquipEffect" then
        success, result = inst["components"]["hh_player"]:AddEquipEffect()
    elseif rpc_type == "RemoveEquipEffect" then
        success, result = inst["components"]["hh_player"]:RemoveEquipEffect()
    elseif rpc_type == "UpdateEffectValue" then
        success, result = inst["components"]["hh_player"]:UpdateEffectValue()
    elseif rpc_type == "CleanEffect" and HH_UTILS:IsHHType(gem_index, "string") then
        success, result = inst["components"]["hh_player"]:RemoveMoreEquipEffect(HH_UTILS:StrToTable(gem_index))
    elseif rpc_type == "CompositeSuit" and HH_UTILS:IsHHType(gem_index, "string") then
        --success, result = inst["components"]["hh_player"]:CompositeSuitEffect(gem_index)
    elseif rpc_type == "EquipInherit" then
        success, result = inst["components"]["hh_player"]:EquipEffectInherit()
    elseif rpc_type == "EffectCompose" then
        --success, result = inst["components"]["hh_player"]:EquipEffectCompose()
    elseif rpc_type == "ReplaceStone" then
        --重铸附魔石
        success, result = inst["components"]["hh_player"]:AddReplaceStone()
    elseif rpc_type == "CompoundSuitEffect" and HH_UTILS:IsHHType(gem_index, "string") then
        success, result = inst["components"]["hh_player"]:CompoundEquipEffect(gem_index)
    elseif rpc_type == "EquipUpgrading" then
        success, result = inst["components"]["hh_player"]:EquipUpgradingV1()
    elseif rpc_type == "EquipAddStar" then
        success, result = inst["components"]["hh_player"]:EquipAddStarV1()
    elseif rpc_type == "GetStarEquipInfo" then
        success, result = inst["components"]["hh_player"]:GetForgeEquipInfo()
    elseif rpc_type == "FixStarEquip" then
        --修复星级装备
        success, result = inst["components"]["hh_player"]:FixStarEquipV1()
    end
    if result then
        HH_UTILS:HHSayV2(inst, tostring(result))
    end
    --print(success, result)
    inst["hh_rpc_cd"] = true
    inst:DoTaskInTime(0.2, function()
        inst["hh_rpc_cd"] = false
    end)
end
AddModRPCHandler("hh_rpc", "hh_handle_equip", hh_handle_equip)
local table_key = {
    ["hh_client_buff"] = true, --buff显示
    ["hh_items"] = true, --道具数量
    ["hh_hoverer_config"] = true, --面板配置
    ["hh_forge_equip"] = true, --清除词条处
    ["hh_forge_stone"] = true, --合成套装
    ["hh_suit_list"] = true, --套装权限
    ["hh_skin_item_list"] = true, --皮肤/功能权限
}
AddClientModRPCHandler("hh_rpc", "hh_client_value", function(key, data)
    if not ThePlayer then
        return
    end
    if not HH_UTILS:HasComponents(ThePlayer, "hh_client") then
        ThePlayer:AddComponent("hh_client")
    end
    if key and type(key) == "string" then
        if table_key[key] then
            ThePlayer["components"]["hh_client"]:SetValue(key, HH_UTILS:StrToTable(data))
        else
            ThePlayer["components"]["hh_client"]:SetValue(key, data)
        end
    end
end)

local mod_info_key = GetModConfigData("key_config") or 120
----容器增加热键
TheInput:AddKeyUpHandler(mod_info_key, function()
    if ThePlayer then
        if TheFrontEnd and HH_UTILS:IsHHType(TheFrontEnd:GetActiveScreen(), "table") then
            local current_hud = TheFrontEnd:GetActiveScreen()
            if current_hud["name"] == "HUD" then
                SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
            end
        end
    end
end)
local key_config = {
    { ["hover"] = "按键B打开强化容器", ["description"] = "B", ["data"] = 98, },
    { ["hover"] = "按键G打开强化容器", ["description"] = "G", ["data"] = 103, },
    { ["hover"] = "按键H打开强化容器", ["description"] = "H", ["data"] = 104, },
    { ["hover"] = "按键I打开强化容器", ["description"] = "I", ["data"] = 105, },
    { ["hover"] = "按键J打开强化容器", ["description"] = "J", ["data"] = 106, },
    { ["hover"] = "按键K打开强化容器", ["description"] = "K", ["data"] = 107, },
    { ["hover"] = "按键L打开强化容器", ["description"] = "L", ["data"] = 108, },
    { ["hover"] = "按键N打开强化容器", ["description"] = "N", ["data"] = 110, },
    { ["hover"] = "按键O打开强化容器", ["description"] = "O", ["data"] = 111, },
    { ["hover"] = "按键P打开强化容器", ["description"] = "P", ["data"] = 112, },
    { ["hover"] = "按键R打开强化容器", ["description"] = "R", ["data"] = 114, },
    { ["hover"] = "按键T打开强化容器", ["description"] = "T", ["data"] = 116, },
    { ["hover"] = "按键V打开强化容器", ["description"] = "V", ["data"] = 118, },
    { ["hover"] = "按键X打开强化容器", ["description"] = "X", ["data"] = 120, },
    { ["hover"] = "按键Z打开强化容器", ["description"] = "Z", ["data"] = 122, },
    { ["hover"] = "按键F1打开强化容器", ["description"] = "F1", ["data"] = 282, },
    { ["hover"] = "按键F2打开强化容器", ["description"] = "F2", ["data"] = 283, },
    { ["hover"] = "按键F3打开强化容器", ["description"] = "F3", ["data"] = 284, },
    { ["hover"] = "按键F4打开强化容器", ["description"] = "F4", ["data"] = 285, },
    { ["hover"] = "按键F5打开强化容器", ["description"] = "F5", ["data"] = 286, },
    { ["hover"] = "按键F6打开强化容器", ["description"] = "F6", ["data"] = 287, },
    { ["hover"] = "按键F7打开强化容器", ["description"] = "F7", ["data"] = 288, },
    { ["hover"] = "按键F8打开强化容器", ["description"] = "F8", ["data"] = 289, },
    { ["hover"] = "按键F9打开强化容器", ["description"] = "F9", ["data"] = 290, },
    { ["hover"] = "按键F10打开强化容器", ["description"] = "F10", ["data"] = 291, },
    { ["hover"] = "按键F11打开强化容器", ["description"] = "F11", ["data"] = 292, },
    { ["hover"] = "按键F12打开强化容器", ["description"] = "F12", ["data"] = 293, },
}
for i, v in ipairs(key_config) do
    if v and v["data"] == mod_info_key then
        TUNING["HH_KEY_CONFIG"] = v["description"]
    end
end

local function launchitem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
end
_G["HHGetGoodEquipEffect"] = function()
    local hh_table = {}
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if v and not v["can_add"] and not v["is_suit"]
                and not v["only_compound"]
                and not v["is_special"]
        then
            table["insert"](hh_table, i)
        end
    end
    return hh_table
end
_G["HHGetRareEquipEffect"] = function()
    local hh_table = {}
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if v and not v["can_add"] and not v["is_suit"]
                and v["only_compound"]
        then
            table["insert"](hh_table, i)
        end
    end
    return hh_table
end
_G["HHGetComEquipEffect"] = function()
    local hh_table = {}
    for i, v in pairs(HH_EQUIP_BUFF_LIST) do
        if v and v["can_add"] and not v["is_suit"] then
            table["insert"](hh_table, i)
        end
    end
    return hh_table
end
--外部接口 随机生成附魔石
_G["HHSpawnGoodEffectStone"] = function()
    local good_list = _G["HHGetGoodEquipEffect"]()
    local good_random = math["random"](1, #good_list)
    local hh_stone = SpawnPrefab("hh_effect_stone")
    if hh_stone then
        hh_stone["hh_effect"] = good_list[good_random]
        if hh_stone["HH_Update_Server"] then
            hh_stone:HH_Update_Server()
        end
        return hh_stone
    end
    return nil
end
_G["HHSpawnRareEffectStone"] = function()
    local good_list = _G["HHGetRareEquipEffect"]()
    local good_random = math["random"](1, #good_list)
    local hh_stone = SpawnPrefab("hh_effect_stone")
    if hh_stone then
        hh_stone["hh_effect"] = good_list[good_random]
        if hh_stone["HH_Update_Server"] then
            hh_stone:HH_Update_Server()
        end
        return hh_stone
    end
    return nil
end
_G["HHSpawnComEffectStone"] = function()
    local good_list = _G["HHGetComEquipEffect"]()
    local good_random = math["random"](1, #good_list)
    local hh_stone = SpawnPrefab("hh_effect_stone")
    if hh_stone then
        hh_stone["hh_effect"] = good_list[good_random]
        if hh_stone["HH_Update_Server"] then
            hh_stone:HH_Update_Server()
        end
        return hh_stone
    end
    return nil
end
--指定id生成附魔石
_G["HHSpawnStoneById"] = function(effect_id)
    local hh_stone = SpawnPrefab("hh_effect_stone")
    if hh_stone then
        if HH_EQUIP_BUFF_LIST[effect_id] then
            hh_stone["hh_effect"] = effect_id
            if hh_stone["HH_Update_Server"] then
                hh_stone:HH_Update_Server()
            end
        end
        return hh_stone
    end
    return nil
end
_G["HHTestWhiteEquip"] = function()
    if not ThePlayer then
        return
    end
    local test_equip = SpawnPrefab("hh_white_equip_body")
    if test_equip and HH_UTILS:HasComponents(ThePlayer, "inventory") then
        if test_equip["HHSpawnValue"] then
            test_equip["HHSpawnValue"](test_equip)
        end
        ThePlayer["components"]["inventory"]:GiveItem(test_equip)
    end
end

--_G["HH_TEST_EQUIP"] = function()
--    if not ThePlayer then
--        return
--    end
--    local test_equip = SpawnPrefab("hambat")
--    if test_equip and HH_UTILS:HasComponents(test_equip, "hh_equip")
--            and HH_UTILS:HasComponents(ThePlayer, "inventory")
--    then
--        local new_equip_com = test_equip["components"]["hh_equip"]
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddNewGem("treasure_armor")--宝-回耐
--        new_equip_com:AddNewGem("treasure_bj")--宝-暴击
--        new_equip_com:AddNewGem("treasure_bj")--宝-暴击
--        new_equip_com:AddEquipBuff("add_critical_hit_rate_damage", 50)--无尽
--        new_equip_com:AddEquipBuff("special_bhtg")--白虎天罡
--        new_equip_com:AddEquipBuff("atk_add_good_damage", 50)--极品增伤
--        new_equip_com:AddEquipBuff("target_percent_damage", 3)--撕裂
--        ThePlayer["components"]["inventory"]:GiveItem(test_equip)
--    end
--    --armorruins,ruinshat
--    local armor_equip = SpawnPrefab("armorruins")
--    if armor_equip and HH_UTILS:HasComponents(armor_equip, "hh_equip")
--            and HH_UTILS:HasComponents(ThePlayer, "inventory")
--    then
--        local new_equip_com = armor_equip["components"]["hh_equip"]
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddEquipBuff("special_sgsy", 1)--玄武
--        new_equip_com:AddEquipBuff("armor_immune_amount", 1)--锁甲
--        new_equip_com:AddEquipBuff("atk_add_good_damage", 50)--极品增伤
--        new_equip_com:AddEquipBuff("atk_speed_big", 70)--攻速
--        ThePlayer["components"]["inventory"]:GiveItem(armor_equip)
--    end
--    local hat_equip = SpawnPrefab("ruinshat")
--    if hat_equip and HH_UTILS:HasComponents(hat_equip, "hh_equip")
--            and HH_UTILS:HasComponents(ThePlayer, "inventory")
--    then
--        local new_equip_com = hat_equip["components"]["hh_equip"]
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddGemCurrentLimit()
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddNewGem("treasure_atk")--宝-攻击
--        new_equip_com:AddEquipBuff("special_sgsy", 1)--玄武
--        new_equip_com:AddEquipBuff("armor_immune_amount", 1)--锁甲
--        new_equip_com:AddEquipBuff("atk_add_good_damage", 50)--极品增伤
--        new_equip_com:AddEquipBuff("special_zqrf", 50)--朱雀
--        ThePlayer["components"]["inventory"]:GiveItem(hat_equip)
--    end
--end
--读取所有道具代码
--_G["HH_Test"] = function()
--    if HH_UTILS:IsHHType(PREFABDEFINITIONS, "table") then
--        local sort_table = HH_UTILS:TableSortKeys(PREFABDEFINITIONS)
--        for i, v in ipairs(sort_table) do
--            local prefab_id = v
--            if HH_UTILS:IsHHType(prefab_id, "string") then
--                print(prefab_id, HH_UTILS:GetPrefabName(prefab_id))
--            end
--        end
--    end
--end
local function getEquipTable(inst, player)
    local has_effect = inst["components"]["hh_equip"]:CanShowBuffUi()
    if not has_effect then
        return nil
    end
    local hh_prefab = inst["prefab"]
    local inst_name = STRINGS["NAMES"][string["upper"](tostring(hh_prefab))] or "装备"
    if HH_UTILS:HasComponents(inst, "hh_hat_star") then
        inst_name = inst["components"]["hh_hat_star"]:GetName()
    end
    local player_prefab = player["prefab"]
    local player_title = player["hh_title"]
    local player_name = player["name"] or STRINGS["NAMES"][string["upper"](player_prefab)] or "玩家?"
    local effect_list = inst["components"]["hh_equip"]:GetBuffDebugList(player)
    local effect_str = ""
    local effect_num = #effect_list
    for i, v in ipairs(effect_list) do
        if v and v["desc"] then
            effect_str = effect_str .. v["desc"]
            if i < effect_num then
                effect_str = effect_str .. "\n"
            end
        end
    end
    local gem_list = inst["components"]["hh_equip"]:GetGemDebugList(player)
    local gem_num = #gem_list
    local gem_str = nil
    if gem_num > 0 then
        gem_str = ""
        for i, v in ipairs(gem_list) do
            if v and v["desc"] then
                gem_str = gem_str .. v["desc"]
                if i < gem_num then
                    gem_str = gem_str .. "\n"
                end
            end
        end
    end
    local star_str = nil
    if HH_UTILS:HasComponents(inst, "hh_hat_star") then
        star_str = inst["components"]["hh_hat_star"]:GetStarDisplay()
    end
    local tab_config = {
        ["type"] = "equip",
        ["effect"] = effect_str,
        ["gem"] = gem_str,
        ["player"] = tostring(player_name),
        ["equip"] = tostring(inst_name),
        ["player_title"] = player_title,
        ["star"] = star_str,
    }
    return tab_config
end
local function getStoneTable(inst, player)
    local effect_name = "空词条"
    local effect_id = inst["hh_effect"] or "未定义"
    if HH_EQUIP_BUFF_LIST[effect_id] then
        effect_name = HH_EQUIP_BUFF_LIST[effect_id]["name"]
    end
    local player_prefab = player["prefab"]
    local player_title = player["hh_title"]
    local player_name = player["name"] or STRINGS["NAMES"][string["upper"](player_prefab)] or "玩家?"
    local tab_config = {
        ["type"] = "equip",
        ["effect"] = tostring(effect_name),
        ["gem"] = nil,
        ["player"] = tostring(player_name),
        ["equip"] = "附魔石-" .. tostring(effect_name),
        ["player_title"] = player_title,
    }
    return tab_config
end
local HH_JOB_CONFIG = require("job/hh_job_config")
local function getJobTAble(inst, player)
    local job_name = "未知职业卡"
    local job_index = inst["hh_job_id"]
    if HH_JOB_CONFIG[job_index] then
        job_name = HH_JOB_CONFIG[job_index]["name"]
    end
    local player_prefab = player["prefab"]
    local player_title = player["hh_title"]
    local player_name = player["name"] or STRINGS["NAMES"][string["upper"](player_prefab)] or "玩家?"
    local tab_config = {
        ["type"] = "equip",
        ["effect"] = tostring(job_name),
        ["gem"] = nil,
        ["player"] = tostring(player_name),
        ["equip"] = "职业卡-" .. tostring(job_name),
        ["player_title"] = player_title,
    }
    return tab_config
end
----
---展示装备属性
---
AddModRPCHandler("hh_rpc", "hh_share_equip", function(player, inst)
    if not player then
        return false
    end
    if not HH_UTILS:IsHHType(AllPlayers, "table") then
        return false
    end
    if not HH_UTILS:IsHHType(inst, "table") then
        return false
    end
    if player["hh_share_cd"] then
        HH_UTILS:HHSayV2(player, "点太快了")
        return false
    end
    local prefab_id = inst["prefab"]
    local tab_config = nil
    if HH_UTILS:HasComponents(inst, "hh_equip") then
        --装备
        tab_config = getEquipTable(inst, player)
    elseif inst["hh_effect"] then
        --附魔石
        tab_config = getStoneTable(inst, player)
    elseif inst["hh_job_id"] then
        --职业卡
        tab_config = getJobTAble(inst, player)
    end
    if not HH_UTILS:IsHHType(tab_config, "table") then
        return
    end
    for i, v in ipairs(AllPlayers) do
        if v and v["userid"] then
            SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_share_equip_client"], v["userid"], HH_UTILS:TableToStr(tab_config))
        end
    end
    player["hh_share_cd"] = true
    player:DoTaskInTime(1, function()
        player["hh_share_cd"] = false
    end)

end)
----
---分享装备属性
---
AddClientModRPCHandler("hh_rpc", "hh_share_equip_client", function(equip_str)
    if ThePlayer and equip_str and type(equip_str) == "string" then
        local equip_table = HH_UTILS:StrToTable(equip_str)
        HH_UTILS:SetClientValue(ThePlayer, "hh_share_equip_client", equip_table)
    end
end)

local function getWorldLogs(inst, log_type, limit_count, page_index)
    if not (HH_UTILS:IsHHType(inst, "table") and HH_UTILS:HasComponents(inst, "hh_player")) then
        return
    end
    local world_log_table = {}
    HH_UTILS:AddCdTask(inst, "world_log_cd", 0.1,
            function(data_inst)
                --HH_UTILS:HHSayV2(data_inst, "请稍等...")
            end,
            function(data_inst)
                if HH_UTILS:HasComponents(TheWorld, "hh_world_log") then
                    local logComp = TheWorld["components"]["hh_world_log"]
                    world_log_table = logComp:GetLogs(log_type, limit_count, page_index)
                    HH_UTILS:HHClientRpc(data_inst, "hh_world_logs", HH_UTILS:TableToStr(world_log_table))
                end
            end, inst)
end
AddModRPCHandler("hh_rpc", "hh_world_logs", getWorldLogs)
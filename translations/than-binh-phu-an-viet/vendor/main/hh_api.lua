local HH_UTILS = require("utils/hh_utils")
local HH_LIST = require("enums/hh_prefab_list")
local HH_EQUIPS = HH_LIST["equip"]
local HH_ORGANISM = HH_LIST["organism"]
local HH_PIG = HH_LIST["pig"]
local HH_FISH = HH_LIST["fish"]
local HH_MONKEY = HH_LIST["monkey"]
local HH_PLANT = HH_LIST["plant"]
local HH_GEAR = HH_LIST["gear"]
local HH_SPIDER = HH_LIST["spider"]
local HH_DOG = HH_LIST["dog"]
local HH_FROG = HH_LIST["frog"]
local HH_INSECT = HH_LIST["insect"]
local HH_SHADOW = HH_LIST["shadow"]
local HH_COM_MONSTER = HH_LIST["common_monster"]
local HH_ELITE_MONSTER = HH_LIST["elite_monster"]
local HH_BOSS_MONSTER = HH_LIST["boss_monster"]
local medal_tr_num_config = GetModConfigData("medal_tr_num")
local function addSpecialTag(inst, hh_table, tag_name, tag_desc)
    local hh_prefab = inst["prefab"]
    if hh_table[hh_prefab] then
        inst["hh_tags"][tag_name] = tag_desc or "未定义"
    end
end
local function getEquipEffectLimit(inst)
    local base_num = 3
    if HH_UTILS:HasComponents(inst, "weapon") or HH_UTILS:HasComponents(inst, "armor") then
        base_num = 5
    end
    if HH_UTILS:HasComponents(inst, "equippable") then
        --禁用泰拉和勋章
        if inst:HasTag("medal") or inst["components"]["equippable"]["equipslot"] == "trshipin" then
            if medal_tr_num_config then
                base_num = 1
            else
                base_num = 0
            end
        end
    end
    return base_num
end
local function getSpecialTag(inst)
    if not inst["prefab"] then
        return
    end
    if not inst["hh_tags"] then
        inst["hh_tags"] = {}
    end
    addSpecialTag(inst, HH_PIG, "pig", "猪")
    addSpecialTag(inst, HH_FISH, "fish", "鱼")
    addSpecialTag(inst, HH_MONKEY, "monkey", "猴")
    addSpecialTag(inst, HH_PLANT, "plant", "植物")
    addSpecialTag(inst, HH_GEAR, "gear", "齿轮")
    addSpecialTag(inst, HH_SPIDER, "spider", "蜘蛛")
    addSpecialTag(inst, HH_DOG, "dog", "犬")
    addSpecialTag(inst, HH_FROG, "frog", "蛙")
    addSpecialTag(inst, HH_INSECT, "insect", "昆虫")
    addSpecialTag(inst, HH_SHADOW, "shadow", "暗影")
    addSpecialTag(inst, HH_COM_MONSTER, "common_monster", "普通")
    addSpecialTag(inst, HH_ELITE_MONSTER, "elite_monster", "精英")
    addSpecialTag(inst, HH_BOSS_MONSTER, "boss_monster", "boss")

end
local function HasHHTagFn(inst, tag_name)
    if not HH_UTILS:IsHHType(tag_name, "string")
            or not inst["hh_tags"]
            or not HH_UTILS:IsHHType(inst["hh_tags"], "table")
    then
        return false
    end
    return inst["hh_tags"][tag_name] ~= nil
end

AddPlayerPostInit(function(inst)
    --客机rpc相关 用于兼容特殊参数
    if not inst["components"]["hh_client"] then
        inst:AddComponent("hh_client")
    end
    if not TheWorld["ismastersim"] then
        return inst
    end
    if not inst["components"]["hh_player"] then
        inst:AddComponent("hh_player")
    end
    if not inst["components"]["hh_buff"] then
        inst:AddComponent("hh_buff")
    end
    if not inst["components"]["hh_data"] then
        inst:AddComponent("hh_data")
    end
end)
local monster_config = GetModConfigData("monster")
local equip_config = GetModConfigData("equip")
if equip_config then
    AddPrefabPostInitAny(function(inst)
        if not TheWorld["ismastersim"] then
            return inst
        end
        if HH_UTILS:HasComponents(inst, "equippable")
                and not HH_UTILS:HasComponents(inst, "stackable")
                and HH_UTILS:HasComponents(inst, "inspectable")
                and HH_UTILS:HasComponents(inst, "inventoryitem")
        then
            if not inst["components"]["hh_equip"] then
                inst:AddTag("hh_equip")
                local effect_limit = getEquipEffectLimit(inst)
                inst:AddComponent("hh_equip")
                inst["components"]["hh_equip"]:SetMaxGemLimit(3)
                inst["components"]["hh_equip"]:SetEquipBuffLimit(effect_limit or 1)
            end
        end
    end)
else
    for i, v in ipairs(HH_EQUIPS) do
        if v and v["id"] then
            AddPrefabPostInit(v["id"], function(inst)
                inst:AddTag("hh_equip")
                if not TheWorld["ismastersim"] then
                    return inst
                end
                if not inst["components"]["hh_equip"] then
                    local effect_limit = getEquipEffectLimit(inst)
                    inst:AddComponent("hh_equip")
                    inst["components"]["hh_equip"]:SetMaxGemLimit(3)
                    inst["components"]["hh_equip"]:SetEquipBuffLimit(effect_limit or 1)
                end
            end)
        end
    end
end
if monster_config then
    for i, v in ipairs(HH_ORGANISM) do
        if v and v["id"] then
            AddPrefabPostInit(v["id"], function(inst)
                if not TheWorld["ismastersim"] then
                    return inst
                end
                if not inst["components"]["hh_monster"] then
                    inst:AddComponent("hh_monster")
                    getSpecialTag(inst)
                    inst["HasHHTag"] = HasHHTagFn
                end

                if not inst["components"]["hh_buff"] then
                    inst:AddComponent("hh_buff")
                end
            end)
        end
    end
end
AddComponentPostInit("health", function(self)
    self["hh_base_max"] = 0
    local oldSetMaxHealth = self["SetMaxHealth"]
    self["SetMaxHealth"] = function(self, amount, ...)
        self["hh_base_max"] = amount
        oldSetMaxHealth(self, amount, ...)
        self["inst"]:PushEvent("hh_change_max_health")
    end
    local oldDoDelta = self["DoDelta"]
    self["DoDelta"] = function(self, amount, overtime, cause, ignore_invincible, afflicter, ...)
        --制裁效果
        if HH_UTILS:HasComponents(self["inst"], "hh_player") and HH_UTILS:IsHHType(amount, "number")
                and amount > 0
        then
            if self["inst"]["components"]["hh_player"]:HasSpecialEffect("healthSuppressNum") then
                amount = amount * 0.1
            end
        end
        if HH_UTILS:HasComponents(self["inst"], "hh_monster") and HH_UTILS:IsHHType(amount, "number")
                and amount > 0
        then
            if self["inst"]["components"]["hh_monster"]:HasSpecialEffect("healthSuppressNum") then
                amount = amount * 0.1
            end
        end
        local result = 0
        if oldDoDelta then
            result = oldDoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ...)
        end
        --攻击力大于0才能吸血
        if HH_UTILS:IsValidCombat(self["inst"]) then
            --吸血效果
            if HH_UTILS:HasComponents(afflicter, "hh_player") and HH_UTILS:IsHHType(result, "number") and result < 0 then
                afflicter["components"]["hh_player"]:HandleBloodSuck(result)
            end
            if HH_UTILS:HasComponents(afflicter, "hh_monster") and HH_UTILS:IsHHType(result, "number") and result < 0 then
                afflicter["components"]["hh_monster"]:HandleBloodSuck(result)
            end
        end
        return result
    end
    ----
    ---单独的真伤方法
    ---@param self:父类
    ---@param amount:伤害-必须为负值
    ---@param attacker:攻击者
    ---@param cause:伤害类型-中文显示
    ---
    self["DoHHDelta"] = function(self, amount, attacker, cause)
        if not HH_UTILS:IsHHType(amount, "number") or amount >= 0
                or not HH_UTILS:HasComponents(attacker, "combat")
        then
            return false
        end
        local old_percent = self:GetPercent()
        --官方限伤
        if self["maxdamagetakenperhit"] ~= nil and amount < self["maxdamagetakenperhit"] and not self["_ignore_maxdamagetakenperhit"] then
            amount = self["maxdamagetakenperhit"]
        end
        if HH_UTILS:IsHHType(cause, "string") then
            HH_UTILS:SpawnClientStrFx(self["inst"], cause)
        end
        local hh_cause = "hh_true_damage"
        self:SetVal(self["currenthealth"] + amount, hh_cause, attacker)
        --推送事件同步客机
        self["inst"]:PushEvent("healthdelta", {
            ["oldpercent"] = old_percent,
            ["newpercent"] = self:GetPercent(),
            ["overtime"] = nil,
            ["cause"] = hh_cause,
            ["afflicter"] = attacker,
            ["amount"] = amount
        })
        --实体死亡推送事件 用于兼容击杀掉落
        if self:IsDead() then
            attacker:PushEvent("killed", {
                ["victim"] = self["inst"],
                ["attacker"] = attacker
            })
            --兼容影怪san掉落
            if HH_UTILS:HasComponents(self["inst"], "combat")
                    and self["inst"]["components"]["combat"]["onkilledbyother"]
            then
                self["inst"]["components"]["combat"]["onkilledbyother"](self["inst"], attacker)
            end
        end
        return true
    end
end)

AddComponentPostInit("combat", function(self)
    local oldGetAttacked = self["GetAttacked"]
    self["GetAttacked"] = function(self, attacker, damage, ...)
        local hh_inst = self["inst"]
        if attacker and attacker["prefab"] == "abigail"
                and HH_UTILS:HasComponents(attacker, "follower")
                and attacker["components"]["follower"]["leader"]
                and HH_UTILS:HasComponents(attacker["components"]["follower"]["leader"], "hh_player")
        then
            --温蒂
            local wendy = attacker["components"]["follower"]["leader"]
            --随从享受人物固定增伤
            local extra_leader_damage = wendy["components"]["hh_player"]:DoAttackDamage(wendy, hh_inst, damage, true)
            damage = extra_leader_damage
        end
        if HH_UTILS:HasComponents(attacker, "hh_player") then
            damage = attacker["components"]["hh_player"]:DoAttackDamage(attacker, self["inst"], damage)
        end
        if HH_UTILS:HasComponents(attacker, "hh_monster") then
            damage = attacker["components"]["hh_monster"]:DoAttackDamage(attacker, self["inst"], damage)
        end
        if HH_UTILS:HasComponents(self["inst"], "hh_player") then
            damage = self["inst"]["components"]["hh_player"]:GetBlockDamage(self["inst"], attacker, damage)
        end
        if HH_UTILS:HasComponents(self["inst"], "hh_monster") then
            damage = self["inst"]["components"]["hh_monster"]:GetBlockDamage(self["inst"], attacker, damage)
        end
        --随从强化
        if HH_UTILS:HasComponents(attacker, "follower") and attacker["components"]["follower"]["leader"]
                and HH_UTILS:HasComponents(attacker["components"]["follower"]["leader"], "hh_player")
        then
            local atk_leader = attacker["components"]["follower"]["leader"]
            damage = atk_leader["components"]["hh_player"]:GetFollowerDamage(damage)
        end
        if HH_UTILS:HasComponents(self["inst"], "follower") and self["inst"]["components"]["follower"]["leader"]
                and HH_UTILS:HasComponents(self["inst"]["components"]["follower"]["leader"], "hh_player")
        then
            local inst_leader = self["inst"]["components"]["follower"]["leader"]
            damage = inst_leader["components"]["hh_player"]:GetFollowerArmor(damage)
        end
        damage = math["max"](damage, 0)
        return oldGetAttacked(self, attacker, damage, ...)
    end
    self["GetBrambleFx"] = function(self, attacker, amount)
        if not HH_UTILS:NotIsDead(self["inst"]) then
            return false
        end
        if self["inst"]["hh_bramble_cd"] then
            return false
        end
        --建筑不会受到反伤效果
        if self["inst"]:HasTag("structure") then
            return false
        end
        --反甲增加cd
        self["inst"]["hh_bramble_cd"] = true
        if not self["inst"]["hh_bramble_cd_task"] then
            self["inst"]["hh_bramble_cd_task"] = self["inst"]:DoTaskInTime(0.3, function(hh_inst)
                hh_inst["hh_bramble_cd"] = false
                HH_UTILS:HHKillTask(hh_inst, "hh_bramble_cd_task")
            end)
        end
        if not HH_UTILS:IsHHType(amount, "number") then
            return false
        end
        --小于0不做处理
        if amount <= 0 then
            return false
        end
        if attacker and HH_UTILS:NotIsDead(attacker) then
            HH_UTILS:SpawnBrambleFx(attacker)
            if HH_UTILS:HasComponents(self["inst"], "hh_player") then
                if self["inst"]["components"]["hh_player"]:HasSpecialEffect("immuneBramble") then
                    return true
                end
                amount = self["inst"]["components"]["hh_player"]:GetHitByBrambleFxDamage(amount)
            end
            if HH_UTILS:HasComponents(self["inst"], "hh_monster") then
                amount = self["inst"]["components"]["hh_monster"]:GetHitByBrambleFxDamage(amount)
            end
            --处理各自的减伤
            amount = amount * self["externaldamagetakenmultipliers"]:Get()
            if HH_UTILS:HasComponents(self["inst"], "inventory") then
                amount = self["inst"]["components"]["inventory"]:ApplyDamage(amount, attacker)
            end
            if amount > 0 then
                self["inst"]["components"]["health"]:DoDelta(-amount, false, "hh_bramble_damage")
                self:SetTarget(attacker)
            end
        end
    end
    return true
end)

AddComponentPostInit("freezable", function(self)
    local oldFreeze = self["Freeze"]
    self["Freeze"] = function(self, ...)
        if HH_UTILS:HasComponents(self["inst"], "hh_player") then
            --存在免疫参数
            if self["inst"]["components"]["hh_player"]:HasSpecialEffect("immuneFreeze") then
                --print("免疫冰冻")
                return
            end
        end
        if HH_UTILS:HasComponents(self["inst"], "hh_monster") then
            --存在免疫参数
            if self["inst"]["components"]["hh_monster"]:HasSpecialEffect("immuneFreeze") then
                --print("怪物免疫冰冻")
                return
            end
        end
        if oldFreeze then
            oldFreeze(self, ...)
        end
    end
end)

----
---月灵不攻击玩家
---
AddPrefabPostInit("gestalt", function(inst)
    if not TheWorld["ismastersim"] then
        return inst
    end
    if HH_UTILS:HasComponents(inst, "combat") then
        local oldTargetFn = inst["components"]["combat"]["targetfn"]
        if oldTargetFn then
            inst["components"]["combat"]["targetfn"] = function(inst, ...)
                if HH_UTILS:HasComponents(inst["tracking_target"], "hh_player")
                        and inst["tracking_target"]["components"]["hh_player"]:HasSpecialEffect("moonCamp") then
                    return nil
                end
                return oldTargetFn(inst, ...)
            end
        end
    end
end)
----
---暗影生物不攻击玩家
---
AddComponentPostInit("shadowsubmissive", function(self)
    local oldShouldSubmitToTarget = self["ShouldSubmitToTarget"]
    self["ShouldSubmitToTarget"] = function(self, target, ...)
        if HH_UTILS:HasComponents(target, "hh_player")
                and target["components"]["hh_player"]:HasSpecialEffect("shadowCamp")
        then
            return true
        end
        return oldShouldSubmitToTarget(self, target, ...)
    end
end)
----
---工作效率-锤以外
---
AddComponentPostInit("workable", function(self)
    local oldWorkedBy_Internal = self["WorkedBy_Internal"]
    self["WorkedBy_Internal"] = function(self, worker, numworks, ...)
        if HH_UTILS:HasComponents(worker, "hh_player")
                and worker["components"]["hh_player"]:HasSpecialEffect("workAddSpeed")
                and self["action"] ~= ACTIONS["HAMMER"]
        then
            numworks = (tonumber(numworks) or 1) * 2
        end
        return oldWorkedBy_Internal(self, worker, numworks, ...)
    end
end)
AddPrefabPostInit("world", function(inst)
    if not TheWorld["ismastersim"] then
        return inst
    end
    inst:AddComponent("hh_world")
    inst:AddComponent("hh_world_limit")
    inst:AddComponent("hh_world_log")
end)
local HH_ALL_PREFABS = require("enums/hh_prefabs")
local base_xml = "images/hh_icon/hh_items.xml"
local weapon_xml = "images/hh_icon/hh_weapon.xml"
local mini_sign_liat = {
    ["hh_cat_box"] = base_xml,
    ["hh_duck_box"] = base_xml,
    ["hh_treasure_tally"] = base_xml,
    ["hh_effect_stone"] = base_xml,
    ["hh_effect_tally"] = base_xml,
    ["hh_remove_stone"] = base_xml,
    ["hh_essence"] = base_xml,
    ["hh_ice_knife"] = weapon_xml,
    ["hh_staff_dis"] = weapon_xml,
    ["hh_staff_star"] = weapon_xml,
    ["hh_job_card"] = "images/hh_icon/hh_job_item.xml",
    ["hh_cat_staff"] = "images/hh_icon/hh_cat_staff.xml",
}
for i, v in pairs(HH_ALL_PREFABS) do
    if HH_UTILS:IsHHType(v, "table") and HH_UTILS:IsHHType(v["xml"], "string") then
        mini_sign_liat[i] = v["xml"]
    end
end
--小木牌
local function draw(inst)
    if inst["components"]["drawable"] then
        local oldOnDrawnFn = inst["components"]["drawable"]["ondrawnfn"] or nil
        inst["components"]["drawable"]["ondrawnfn"] = function(_inst, image, src, atlas, bgimagename, bgatlasname, ...)
            if oldOnDrawnFn ~= nil then
                oldOnDrawnFn(_inst, image, src, atlas, bgimagename, bgatlasname, ...)
            end
            if HH_UTILS:IsHHType(image, "string") and
                    (mini_sign_liat[image] or TUNING["HH_SKIN_CONFIG"][image]) then
                --是我的物品
                if atlas == nil then
                    if mini_sign_liat[image] then
                        atlas = mini_sign_liat[image]
                    elseif TUNING["HH_SKIN_CONFIG"][image] then
                        --皮肤兼容
                        atlas = TUNING["HH_SKIN_CONFIG"][image]
                    end
                end
                local atlas_path = resolvefilepath_soft(atlas)
                if atlas_path then
                    _inst["AnimState"]:OverrideSymbol("SWAP_SIGN", atlas_path, string["format"]("%s.tex", image))
                end
            end
        end
    end
end
AddPrefabPostInit("minisign", draw)
AddPrefabPostInit("minisign_drawn", draw)
AddPrefabPostInit("decor_pictureframe", draw)
---增加附魔石外部接口
local HH_ENCHANT = require("enums/hh_enchant")
local HH_EQUIP_EFFECT = HH_ENCHANT["HH_EQUIP_BUFF_LIST"]
--计算起始词条id
local start_id = 10000
for i, v in pairs(HH_EQUIP_EFFECT) do
    if HH_UTILS:IsHHType(v, "table") and HH_UTILS:IsHHType(v["id"], "number") and (v["id"] > start_id) then
        start_id = v["id"] + 1
    end
end
local function AddSpecialEquipEffectFn(effect_id, data)
    if not (HH_UTILS:IsHHType(effect_id, "string") and HH_UTILS:IsHHType(data, "table")) then
        print("增加词条错误，请按照文档进行正常操作参数")
        return
    end
    if HH_EQUIP_EFFECT[effect_id] then
        print("已存在相同的索引词条，请修改词条id进行添加")
        return
    end
    local effect_name = data["name"] or "词条前缀"
    HH_EQUIP_EFFECT[effect_id] = {
        ["id"] = start_id,
        ["name"] = effect_name,
        ["client_text"] = data["client_text"] or "新\n词条",
        ["desc"] = data["desc"] or "词条描述",
        ["check_desc"] = data["check_desc"], --扩展描述-可自定义显示(例如描述词条前置条件)
        ["ui_from_desc"] = data["ui_from_desc"], --扩展描述-用于帮助里面展示附魔石来源 非必填
        ["can_add"] = data["can_add"], --是否可以通过附魔卷轴附魔出来
        ["only_one"] = data["only_one"], --单个装备是否允许重复附魔
        ["only_compound"] = data["only_compound"] or false, --填true 该附魔只能合成台合成出来(等同稀有词条的概率)
        ["client_color"] = data["client_color"] or { 101 / 255, 255 / 255, 0 / 255, 1 }, --附魔石背景颜色
        ["is_special"] = data["is_special"] or false, --填true+上面can_add填false 该词条则不能通过正常途径获取 可以通过另一个接口进行生成
        ["value_range"] = data["value_range"], --如果词条带有(随机变化的)属性值则必填
        ["check_equip_can_add"] = data["check_equip_can_add"] or function(inst)
            --词条校验函数 一般用于校验词条是否能被装备附魔
            --ps：必须含有俩个返回值 1：是否符合条件(true/false) 2：如果第一个是false 需要写清楚不满足条件的原因
            return true, "满足条件"
        end,
        --下面俩个分别在装备新增/清除词条时执行 如果是定时任务类词条 记得在end_fn中清除掉对应任务
        ["start_fn"] = data["start_fn"] or function(inst)
            --inst->装备
        end,
        ["end_fn"] = data["end_fn"] or function(inst)
        end,
        --下面两个分别会在玩家穿戴/脱下装备时执行
        ["on_equip_fn"] = data["on_equip_fn"] or function(inst, owner, value)
            --inst->装备 owner->穿戴者 value->词条的属性值 如果属性值上面未定义范围 则算作nil
        end,
        ["un_equip_fn"] = data["un_equip_fn"] or function(inst, owner, value)
        end,
    }
    print(string["format"]("======>调用新增词条接口成功 词条id:%s 词条名字:%s<======", tostring(effect_id), tostring(effect_name)))
    start_id = start_id + 1
end
GLOBAL["AddSpecialEquipEffect"] = AddSpecialEquipEffectFn

--------------------------------------2025-03-13---------------------------
---随从击杀 主人也会掉落宝石卷轴
local function onkilled(inst, data)
    local victim = data["victim"]
    if victim:IsValid() and not victim:HasTag("player")
            and HH_UTILS:NotIsDead(inst)
            and HH_UTILS:HasComponents(inst, "follower")
            and inst["components"]["follower"]["leader"]
            and HH_UTILS:HasComponents(inst["components"]["follower"]["leader"], "hh_player")
    then
        local player = inst["components"]["follower"]["leader"]
        player["components"]["hh_player"]:DropSpecialGif(victim)
    end

end
AddComponentPostInit("follower", function(self)
    self["inst"]:ListenForEvent("killed", onkilled)
end)
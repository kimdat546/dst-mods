local _G = GLOBAL
local TUNING = _G.TUNING
local STRINGS = _G.STRINGS
local TECH = _G.TECH
local SpawnPrefab = _G.SpawnPrefab
local Ingredient = _G.Ingredient

-- =========================================================================
-- Cấu hình
-- =========================================================================
local SKILL_KEY = GetModConfigData("skillkey") or 122
local EXP_RATE = GetModConfigData("exprate") or 1

local RPC_NAMESPACE = "tutienlite"
local SKILL_COOLDOWN = 15      -- giây
local SKILL_MIN_LEVEL = 2      -- cần Trúc Cơ trở lên
local SKILL_RADIUS = 6
local LINGSHI_EXP = 60         -- linh khí mỗi viên linh thạch

-- =========================================================================
-- Đăng ký prefab + component
-- =========================================================================
PrefabFiles = {
    "tu_lingshi",
}

local assets = {
    Asset("ANIM", "anim/nightmarefuel.zip"),
}
Assets = assets

-- STRINGS
STRINGS.NAMES.TU_LINGSHI = "Linh Thạch"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TU_LINGSHI = "Tinh hoa linh khí ngưng tụ. Nuốt vào để tu luyện."
STRINGS.RECIPE_DESC = STRINGS.RECIPE_DESC or {}
STRINGS.RECIPE_DESC.TU_LINGSHI = "Ngưng tụ linh khí để tu luyện."

-- Công thức chế tạo Linh Thạch (luôn mở khoá, không cần khoa học)
AddRecipe2(
    "tu_lingshi",
    { Ingredient("nightmarefuel", 1), Ingredient("goldnugget", 1) },
    TECH.NONE,
    { atlas = "images/inventoryimages.xml", image = "nightmarefuel.tex" },
    { "MODS" }
)

-- =========================================================================
-- Gắn component tu luyện cho người chơi (server-side)
-- =========================================================================
AddPlayerPostInit(function(inst)
    -- Netvar tạo ở CẢ client lẫn server để đồng bộ cho UI
    inst._tu_level = _G.net_smallbyte(inst.GUID, "tu_cultivation.level", "tu_leveldirty")
    inst._tu_pct = _G.net_byte(inst.GUID, "tu_cultivation.pct", "tu_pctdirty")

    if not _G.TheWorld.ismastersim then
        return
    end

    inst._tu_level:set(1)
    inst._tu_pct:set(0)

    inst:AddComponent("tu_cultivation")
    inst.components.tu_cultivation.exprate = EXP_RATE

    -- Ăn Linh Thạch -> cộng linh khí
    inst:ListenForEvent("oneat", function(_, data)
        if data ~= nil and data.food ~= nil and data.food.prefab == "tu_lingshi" then
            if inst.components.tu_cultivation ~= nil then
                inst.components.tu_cultivation:AddExp(LINGSHI_EXP)
            end
        end
    end)

    -- Áp dụng buff khởi tạo (trường hợp người chơi mới chưa có save)
    inst:DoTaskInTime(0, function()
        if inst.components.tu_cultivation ~= nil then
            inst.components.tu_cultivation:ApplyBuffs()
        end
    end)
end)

-- =========================================================================
-- UI cảnh giới: gắn widget vào HUD (client)
-- =========================================================================
AddClassPostConstruct("widgets/controls", function(self)
    local TuRealmUI = require("widgets/tu_realmui")
    self.tu_realmui = self.topleft_root:AddChild(TuRealmUI(self.owner))
    self.tu_realmui:SetPosition(130, -40, 0)
end)

-- =========================================================================
-- Thần thông: Linh Khí Bạo (AOE quanh người chơi + hồi máu)
-- =========================================================================
local function DoSkill(player)
    if player == nil or not player:IsValid() then return end
    local cult = player.components.tu_cultivation
    if cult == nil then return end

    if cult.level < SKILL_MIN_LEVEL then
        if player.components.talker ~= nil then
            player.components.talker:Say("Tu vi chưa đủ, cần đạt Trúc Cơ.")
        end
        return
    end

    -- cooldown lưu ngay trên component
    local now = _G.GetTime()
    if cult._skill_next ~= nil and now < cult._skill_next then
        return
    end
    cult._skill_next = now + SKILL_COOLDOWN

    local x, y, z = player.Transform:GetWorldPosition()

    -- fx + âm thanh
    local fx = SpawnPrefab("explode_small")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
    end
    if player.SoundEmitter ~= nil then
        player.SoundEmitter:PlaySound("dontstarve/common/lightningstrike")
    end

    -- sát thương vùng
    local dmg = 50 * cult.level
    local ents = _G.TheSim:FindEntities(x, y, z, SKILL_RADIUS, { "_combat" }, { "INLIMBO", "player", "companion", "wall" })
    for _, ent in ipairs(ents) do
        if ent ~= player and ent:IsValid() and ent.components.combat ~= nil and ent.components.health ~= nil and not ent.components.health:IsDead() then
            ent.components.combat:GetAttacked(player, dmg)
        end
    end

    -- hồi máu cho bản thân
    if player.components.health ~= nil then
        player.components.health:DoDelta(20 * cult.level)
    end
end

AddModRPCHandler(RPC_NAMESPACE, "cast_skill", function(player)
    DoSkill(player)
end)

-- =========================================================================
-- Phím bấm phía client -> gửi RPC
-- =========================================================================
_G.TheInput:AddKeyDownHandler(SKILL_KEY, function()
    if _G.ThePlayer ~= nil and not _G.IsPaused() then
        local rpc = _G.MOD_RPC[RPC_NAMESPACE]
        if rpc ~= nil and rpc.cast_skill ~= nil then
            SendModRPCToServer(rpc.cast_skill)
        end
    end
end)

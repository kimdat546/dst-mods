-- Component tu luyện: lưu cảnh giới + linh khí (exp), áp dụng buff chỉ số.
-- Chạy phía server (mastersim). Viết mới hoàn toàn.

local REALMS = {
    { name = "Luyện Khí",  exp_to_next = 100,  hp = 0,   dmg = 1.0, speed = 0.0 },
    { name = "Trúc Cơ",    exp_to_next = 250,  hp = 40,  dmg = 1.15, speed = 0.05 },
    { name = "Kim Đan",    exp_to_next = 500,  hp = 80,  dmg = 1.3, speed = 0.10 },
    { name = "Nguyên Anh", exp_to_next = 1000, hp = 140, dmg = 1.5, speed = 0.15 },
    { name = "Hóa Thần",   exp_to_next = nil,  hp = 220, dmg = 1.8, speed = 0.20 }, -- max
}

local MOD_KEY = "tu_cultivation"

local TuCultivation = Class(function(self, inst)
    self.inst = inst
    self.level = 1          -- chỉ số cảnh giới (1..#REALMS)
    self.exp = 0            -- linh khí hiện tại trong cảnh giới này
    self.exprate = 1        -- nhân tốc độ tu luyện (set từ modmain)
    self.base_maxhealth = nil

    self.inst:ListenForEvent("killed", function(_, data)
        if data ~= nil and data.victim ~= nil and data.victim.components.health ~= nil then
            local hp = data.victim.components.health.maxhealth or 0
            self:AddExp(math.floor(hp * 0.5))
        end
    end)
end)

function TuCultivation:PushNet()
    local inst = self.inst
    if inst._tu_level == nil or inst._tu_pct == nil then return end
    inst._tu_level:set(self.level)
    local pct = 100
    local r = REALMS[self.level]
    if r ~= nil and r.exp_to_next ~= nil and r.exp_to_next > 0 then
        pct = math.floor(self.exp / r.exp_to_next * 100)
        if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
    end
    inst._tu_pct:set(pct)
end

function TuCultivation:GetRealm()
    return REALMS[self.level]
end

function TuCultivation:GetRealmName()
    local r = self:GetRealm()
    return r ~= nil and r.name or "?"
end

function TuCultivation:IsMaxLevel()
    return self.level >= #REALMS
end

function TuCultivation:ApplyBuffs()
    local r = self:GetRealm()
    if r == nil then return end
    local inst = self.inst

    -- máu
    if inst.components.health ~= nil then
        if self.base_maxhealth == nil then
            self.base_maxhealth = inst.components.health.maxhealth
        end
        local percent = inst.components.health:GetPercent()
        inst.components.health:SetMaxHealth(self.base_maxhealth + r.hp)
        inst.components.health:SetPercent(percent)
    end

    -- sát thương gây ra
    if inst.components.combat ~= nil then
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, r.dmg, MOD_KEY)
    end

    -- tốc độ di chuyển
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, MOD_KEY, 1 + r.speed)
    end

    self:PushNet()
end

function TuCultivation:DoLevelUp()
    self.level = self.level + 1
    self.exp = 0
    self:ApplyBuffs()

    local inst = self.inst
    if inst.components.talker ~= nil then
        inst.components.talker:Say("Đột phá cảnh giới! Ta đã đạt tới [" .. self:GetRealmName() .. "]!")
    end
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/lightningstrike")
    end
    local fx = SpawnPrefab("explode_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

function TuCultivation:AddExp(amount)
    if amount == nil or amount <= 0 then return end
    if self:IsMaxLevel() then return end

    self.exp = self.exp + amount * (self.exprate or 1)

    -- có thể lên nhiều cấp một lúc
    while not self:IsMaxLevel() do
        local r = self:GetRealm()
        if r.exp_to_next == nil or self.exp < r.exp_to_next then
            break
        end
        self.exp = self.exp - r.exp_to_next
        self:DoLevelUp()
    end

    self:PushNet()
end

function TuCultivation:OnSave()
    return {
        level = self.level,
        exp = self.exp,
        base_maxhealth = self.base_maxhealth,
    }
end

function TuCultivation:OnLoad(data)
    if data == nil then return end
    self.level = data.level or 1
    self.exp = data.exp or 0
    self.base_maxhealth = data.base_maxhealth
    self:ApplyBuffs()
end

function TuCultivation:GetDebugString()
    return string.format("Realm=%s(%d) Exp=%d", self:GetRealmName(), self.level, self.exp)
end

return TuCultivation

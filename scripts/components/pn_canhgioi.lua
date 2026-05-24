-- scripts/components/pn_canhgioi.lua
-- Cảnh giới tracker. On CANHGIOI_UP event, advances tier and applies stat delta.

local Events = require("pn/events")
local Realms = require("pn/realms")
local TUNING = require("pn/tuning")

local PnCanhGioi = Class(function(self, inst)
    self.inst = inst
    self.tier = 0   -- 0 = Phàm Nhân, 1..9 = Luyện Khí tầng 1..9

    if inst then
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, data)
            self:_OnCanhGioiUp(data)
        end)
    end
end)

function PnCanhGioi:_OnCanhGioiUp(data)
    if not data or not data.new_tier then return end
    if data.new_tier <= self.tier then return end  -- no downgrade

    local old_tier = self.tier
    self.tier = data.new_tier
    self:_ApplyStatDelta(old_tier, self.tier)
    self:_PushToReplica()
end

-- Apply incremental stat bonus from old_tier → new_tier
function PnCanhGioi:_ApplyStatDelta(old_tier, new_tier)
    if not self.inst then return end
    local tier_delta = new_tier - old_tier
    if tier_delta <= 0 then return end

    local s = TUNING.STATS_PER_TIER

    -- HP max
    if self.inst.components.health then
        local cur_max = self.inst.components.health.maxhealth
        self.inst.components.health:SetMaxHealth(cur_max + s.HP_BONUS * tier_delta)
    end

    -- Hunger drain rate (lower = slower hunger)
    if self.inst.components.hunger then
        local cur = self.inst.components.hunger.hungerrate
        self.inst.components.hunger.hungerrate = cur * (1 + s.HUNGER_MULT_DELTA * tier_delta)
    end

    -- Attack damage multiplier
    if self.inst.components.combat then
        local cur = self.inst.components.combat.damagemultiplier
        self.inst.components.combat.damagemultiplier = cur + s.ATTACK_MULT_DELTA * tier_delta
    end

    -- Move speed multiplier (set via locomotor)
    if self.inst.components.locomotor then
        local cur = self.inst.components.locomotor:GetExternalSpeedMultiplier(self.inst, "pn_canhgioi_speed")
                    or 1.0
        self.inst.components.locomotor:SetExternalSpeedMultiplier(
            self.inst, "pn_canhgioi_speed",
            cur + s.SPEED_MULT_DELTA * tier_delta
        )
    end
end

function PnCanhGioi:GetTier()    return self.tier end
function PnCanhGioi:GetDisplay() return Realms.GetDisplay(self.tier) end

function PnCanhGioi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_canhgioi) then return end
    self.inst.replica.pn_canhgioi:SetTier(self.tier)
end

function PnCanhGioi:OnSave()
    return { tier = self.tier }
end

function PnCanhGioi:OnLoad(data)
    if data == nil then return end
    self.tier = data.tier or 0
    -- NOTE: do NOT re-apply stat deltas here; they were already baked into the save.
    self:_PushToReplica()
end

return PnCanhGioi

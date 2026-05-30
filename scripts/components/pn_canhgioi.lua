local Events = require("pn/events")
local Realms = require("pn/realms")
local config = require("pn/config")

local PnCanhGioi = Class(function(self, inst)
    self.inst = inst
    self.tier = 0
    if inst then
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, d) self:_OnUp(d) end)
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnCanhGioi:_OnUp(data)
    if not data or not data.new_tier or data.new_tier <= self.tier then return end
    local old = self.tier
    self.tier = data.new_tier
    self:_ApplyStatDelta(old, self.tier)
    self:_PushToReplica()
end

function PnCanhGioi:_ApplyStatDelta(old_tier, new_tier)
    local d = new_tier - old_tier
    if d <= 0 or not self.inst then return end
    local s = config.STATS_PER_LAYER
    if self.inst.components.health then
        self.inst.components.health:SetMaxHealth(self.inst.components.health.maxhealth + s.HP_BONUS * d)
    end
    if self.inst.components.combat then
        self.inst.components.combat.damagemultiplier =
            (self.inst.components.combat.damagemultiplier or 1) + s.DMG_MULT_DELTA * d
    end
    if self.inst.components.hunger then
        self.inst.components.hunger.hungerrate =
            self.inst.components.hunger.hungerrate * (1 + s.HUNGER_MULT_DELTA * d)
    end
    if self.inst.components.locomotor then
        local cur = self.inst.components.locomotor:GetExternalSpeedMultiplier(self.inst, "pn_canhgioi") or 1.0
        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "pn_canhgioi", cur + s.SPEED_MULT_DELTA * d)
    end
end

function PnCanhGioi:GetTier() return self.tier end
function PnCanhGioi:GetDisplay() return Realms.GetDisplay(self.tier) end

function PnCanhGioi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_canhgioi) then return end
    self.inst.replica.pn_canhgioi:SetTier(self.tier)
end

function PnCanhGioi:OnSave() return { tier=self.tier } end
function PnCanhGioi:OnLoad(data)
    if not data then return end
    self.tier = data.tier or 0
    self:_PushToReplica()
    -- DST does not persist maxhealth/damagemultiplier/hungerrate/locomotor mults by
    -- default, so re-apply the cumulative stat delta on load. Loop per-layer (d=1)
    -- to exactly reproduce the live breakthrough sequence (matters for the
    -- multiplicative hungerrate). Deferred so master_postinit base stats land first.
    if self.tier > 0 and self.inst then
        local target = self.tier
        self.inst:DoTaskInTime(0, function()
            for t = 1, target do self:_ApplyStatDelta(t - 1, t) end
        end)
    end
end

return PnCanhGioi

-- scripts/components/pn_lifespan.lua
-- Tuổi thọ + permadeath. Decays each in-game day cycle. Extends +5 on each
-- Luyện Khí breakthrough. When remaining hits 0, player dies of old age and
-- a persistent permadeath flag blocks all respawn attempts.

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnLifespan = Class(function(self, inst)
    self.inst       = inst
    self.total      = TUNING.LIFESPAN.BASE   -- max possible (60 + 5*N tiers achieved)
    self.remaining  = TUNING.LIFESPAN.BASE
    self.permadeath = false

    if inst then
        -- Extend lifespan on breakthrough
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, _)
            self:_OnBreakthrough()
        end)

        -- Decay on every in-game day transition (dusk -> night counts as one cycle finished)
        -- We listen on the world; the world fires "phasechanged" every transition.
        -- We tick on "day" specifically to match "1 day passed = 1 lifespan day lost".
        if TheWorld then
            self._world_handler = function(_, data)
                if data and data.newphase == "day" then
                    self:_DecayOneDay()
                end
            end
            inst:ListenForEvent("phasechanged", self._world_handler, TheWorld)
        end
    end
end)

function PnLifespan:_OnBreakthrough()
    local delta = TUNING.LIFESPAN.BONUS_PER_TIER
    self.total     = self.total + delta
    self.remaining = self.remaining + delta
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_TICK, { remaining = self.remaining, total = self.total })
    end
end

function PnLifespan:_DecayOneDay()
    if self.permadeath then return end
    self.remaining = math.max(0, self.remaining - TUNING.LIFESPAN.DECAY_PER_DAY)
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_TICK, { remaining = self.remaining, total = self.total })
    end
    if self.remaining <= 0 then
        self:TriggerPermadeath()
    end
end

function PnLifespan:TriggerPermadeath()
    if self.permadeath then return end
    self.permadeath = true
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_EXPIRED, {})
        -- Kill the player. damagesource string lets the message-on-death code
        -- match "oldage" and show "Bạn đã chết già" (Plan 3 wires the message).
        if self.inst.components.health then
            self.inst.components.health:Kill()
        end
        print(string.format("[PN] %s died of old age (permadeath set)",
            tostring(self.inst.userid or "?")))
    end
end

function PnLifespan:Get()           return self.remaining end
function PnLifespan:GetTotal()      return self.total end
function PnLifespan:IsPermadeath()  return self.permadeath end

-- Admin helpers (used by debug commands).
function PnLifespan:SetRemaining(v)
    self.remaining = math.max(0, math.min(v, self.total))
    self:_PushToReplica()
end

function PnLifespan:SetTotal(v)
    self.total     = math.max(1, v)
    self.remaining = math.min(self.remaining, self.total)
    self:_PushToReplica()
end

function PnLifespan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_lifespan) then return end
    self.inst.replica.pn_lifespan:SetRemaining(self.remaining)
    self.inst.replica.pn_lifespan:SetTotal(self.total)
    self.inst.replica.pn_lifespan:SetPermadeath(self.permadeath)
end

function PnLifespan:OnSave()
    return {
        total      = self.total,
        remaining  = self.remaining,
        permadeath = self.permadeath,
    }
end

function PnLifespan:OnLoad(data)
    if data == nil then return end
    self.total      = data.total or TUNING.LIFESPAN.BASE
    self.remaining  = data.remaining or self.total
    self.permadeath = data.permadeath or false
    self:_PushToReplica()
end

function PnLifespan:OnRemoveEntity()
    -- Detach world listener so the handler doesn't outlive the player entity.
    if self._world_handler and TheWorld then
        TheWorld:RemoveEventCallback("phasechanged", self._world_handler)
    end
end

return PnLifespan

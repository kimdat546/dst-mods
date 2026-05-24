-- scripts/components/pn_aura_source.lua
-- Component on a linh mạch entity. Periodically scans for entities in radius
-- and pushes pn_tuvi_gain events on them.
--
-- Players' pn_tuvi listens for the event and accumulates (after applying linhcan mult).
-- Mobs (Plan 5) will have pn_mob_cultivation listening for the same event.

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnAuraSource = Class(function(self, inst)
    self.inst         = inst
    self.tier         = "HA_PHAM"  -- default; SetTier overrides
    self.rate_per_sec = TUNING.LINH_MACH.HA_PHAM.rate_per_sec
    self.radius       = TUNING.LINH_MACH.HA_PHAM.aura_radius
    self._task        = nil

    if inst and TheWorld and TheWorld.ismastersim then
        -- Only run on server
        self:_StartTicking()
    end
end)

function PnAuraSource:SetTier(tier_key)
    local cfg = TUNING.LINH_MACH[tier_key]
    if not cfg then return end
    self.tier         = tier_key
    self.rate_per_sec = cfg.rate_per_sec
    self.radius       = cfg.aura_radius
end

function PnAuraSource:_StartTicking()
    if self._task then return end
    local interval = TUNING.LINH_MACH.SCAN_INTERVAL or 1.0
    self._task = self.inst:DoPeriodicTask(interval, function()
        self:_Tick()
    end, interval)  -- first run after interval, not immediately
end

function PnAuraSource:_StopTicking()
    if self._task then
        self._task:Cancel()
        self._task = nil
    end
end

function PnAuraSource:_Tick()
    if not self.inst or not self.inst:IsValid() then
        self:_StopTicking()
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    -- Find players in radius. Tag-filtered for cheap query.
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "player" })

    local amount = self.rate_per_sec * (TUNING.LINH_MACH.SCAN_INTERVAL or 1.0)

    for _, ent in ipairs(ents) do
        if ent.components and ent.components.pn_tuvi then
            -- If meditating on this linh mạch, multiply by sit bonus
            local final_amount = amount
            if ent.components.pn_meditation
               and ent.components.pn_meditation:IsMeditating()
               and ent.components.pn_meditation:GetTarget() == self.inst then
                final_amount = final_amount * TUNING.TUVI_SOURCES.SIT_MEDITATE_BONUS
            end
            ent:PushEvent(Events.TUVI_GAIN, {
                amount = final_amount,
                source = "linh_mach_" .. self.tier:lower(),
            })
        end
    end
end

function PnAuraSource:OnRemoveEntity()
    self:_StopTicking()
end

return PnAuraSource

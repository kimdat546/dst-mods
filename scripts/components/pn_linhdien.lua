-- Linh Điền field: periodically tags nearby pn herb crops with an accel multiplier
-- so their grow timer runs faster. Server-only (no replica needed).
local config = require("pn/config")

local PnLinhDien = Class(function(self, inst)
    self.inst = inst
    self.radius = config.LINHDIEN.RADIUS
    self.mult = config.LINHDIEN.ACCEL_MULT
    if inst then
        self._task = inst:DoPeriodicTask(config.LINHDIEN.SCAN_PERIOD, function() self:_Scan() end)
        inst:DoTaskInTime(0, function() self:_Scan() end)
    end
end)

function PnLinhDien:_Scan()
    if not (self.inst and self.inst:IsValid()) then return end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "pn_herb_crop" })
    for _, e in ipairs(ents) do
        if e.components.pn_herb_crop then
            e.components.pn_herb_crop:SetAccel(self.mult, self.inst)
        end
    end
end

function PnLinhDien:OnRemoveFromEntity()
    if self._task then self._task:Cancel(); self._task = nil end
end

return PnLinhDien

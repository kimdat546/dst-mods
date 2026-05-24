-- scripts/components/pn_meditation.lua
-- Sit-meditate state. When active, pn_aura_source applies a 1.5× bonus to tu vi
-- gained from the targeted linh mạch.

local PnMeditation = Class(function(self, inst)
    self.inst        = inst
    self.is_meditating = false
    self.target      = nil  -- the linh mạch entity being meditated on

    if inst then
        -- Cancel on movement (any control input)
        inst:ListenForEvent("locomote", function() self:Stop("locomote") end)
        -- Cancel on damage
        inst:ListenForEvent("attacked",  function() self:Stop("attacked")  end)
    end
end)

-- Start meditating on the given linh mạch target.
function PnMeditation:Start(target)
    if self.is_meditating then return false end
    if not target or not target:IsValid() then return false end
    self.is_meditating = true
    self.target = target

    -- Play idle sit anim (reuse vanilla state)
    if self.inst.sg and self.inst.sg.GoToState then
        self.inst.sg:GoToState("idle")  -- fallback: vanilla idle, custom sit state added later
    end

    if self.inst then
        self.inst:PushEvent("pn_meditation_start", { target = target })
    end
    return true
end

function PnMeditation:Stop(reason)
    if not self.is_meditating then return end
    self.is_meditating = false
    self.target = nil
    if self.inst then
        self.inst:PushEvent("pn_meditation_stop", { reason = reason })
    end
end

function PnMeditation:IsMeditating() return self.is_meditating end
function PnMeditation:GetTarget()    return self.target        end

-- No save state: meditation is transient session-only.
function PnMeditation:OnSave()        return {} end
function PnMeditation:OnLoad(_)       end

return PnMeditation

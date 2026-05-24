-- scripts/pn/actions.lua
-- Custom actions for the PNTT mod. Registered from modmain.

-- Note: This file is `modimport`ed from modmain, so it inherits env globals
-- (Action, AddAction, ACTIONS, COMPONENT_ACTIONS, GLOBAL).

local PN_MEDITATE = Action({ priority = 5, mount_valid = false, distance = 4 })
PN_MEDITATE.id  = "PN_MEDITATE"
PN_MEDITATE.str = "Tọa thiền"
PN_MEDITATE.fn  = function(act)
    local doer   = act.doer
    local target = act.target
    if doer and doer.components and doer.components.pn_meditation then
        return doer.components.pn_meditation:Start(target)
    end
    return false
end

AddAction(PN_MEDITATE)

-- Wire the action to right-click on linh mạch entities.
-- COMPONENT_ACTIONS.SCENE callbacks fire on CLIENT to decide which actions
-- appear in the right-click menu. So we must gate by things the CLIENT can see:
-- TAGS (replicated), not server-only components (pn_aura_source, pn_meditation).
AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
    if not right then return end
    if not inst:HasTag("pn_linhkhi_source") then return end
    if not doer:HasTag("phamnhan") then return end
    table.insert(actions, ACTIONS.PN_MEDITATE)
end)

-- Provide a stategraph action handler so the action runs through normal anim flow.
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))

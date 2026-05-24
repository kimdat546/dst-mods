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
-- COMPONENT_ACTIONS.SCENE table: triggered for inspectable / scene-level interactions.
AddComponentAction("SCENE", "pn_aura_source", function(inst, doer, actions, right)
    if right and doer and doer.components and doer.components.pn_meditation
       and not doer.components.pn_meditation:IsMeditating() then
        table.insert(actions, ACTIONS.PN_MEDITATE)
    end
end)

-- Provide a stategraph action handler so the action runs through normal anim flow.
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))

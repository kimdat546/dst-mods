-- scripts/main/import.lua — modimport every other bootstrap file in order.
-- Order matters: assets/strings/character first, then components, widgets, hooks.
modimport("scripts/main/assets.lua")
modimport("scripts/main/strings.lua")
modimport("scripts/main/character.lua")
modimport("scripts/main/components.lua")
modimport("scripts/main/widgets.lua")
modimport("scripts/main/mob_hooks.lua")
modimport("scripts/main/debug.lua")

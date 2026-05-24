-- scripts/pn/charselect_override.lua
-- Hide vanilla DST characters from the character select screen.
-- Only "phamnhan" should be selectable.
--
-- Notes on DST API (verified via reference/dst-scripts):
--   The redux screen "screens/redux/characterselectscreen" no longer exists in
--   current DST builds. The character grid lives in the widget
--   "widgets/redux/characterselect" (class CharacterSelect), which exposes:
--     - self.characters                       (built list of hero prefabs)
--     - self:_BuildCharactersList(extraChars) (called once in :ctor)
--   We hook the widget via AddClassPostConstruct and filter self.characters
--   down to {"phamnhan"} after construction.

-- Client-side: hide non-phamnhan characters from the select UI.
AddClassPostConstruct("widgets/redux/characterselect", function(self)
    if self.characters ~= nil then
        local filtered = {}
        for _, hero in ipairs(self.characters) do
            if hero == "phamnhan" then
                table.insert(filtered, hero)
            end
        end
        -- If phamnhan isn't yet in the list (e.g. mod not fully registered),
        -- force it in so the player always has at least one selectable hero.
        if #filtered == 0 then
            table.insert(filtered, "phamnhan")
        end
        self.characters = filtered
    end
end)

-- Server-side conversion via ms_playerdespawnandreplace REMOVED in 0.1.1.
-- It was firing during initial spawn and destabilizing Steam IPC on macOS
-- Rosetta dedicated server (root cause of the 2026-05-24 crash). Plan 8 will
-- re-add it via a safer mechanism (kick + reconnect prompt) after verifying
-- the in-game upload runs without it.
-- For now, the client-side filter above ensures only "phamnhan" appears in
-- the select UI — which is sufficient for end-user flow.

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

-- Server-side: if a player joins as a non-phamnhan character (e.g. via the
-- c_select console command or a stale save), force-convert them to phamnhan.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end

    inst:ListenForEvent("ms_playerjoined", function(_, player)
        if player.prefab ~= "phamnhan" then
            print(string.format("[PN] Player %s joined as %s - converting to phamnhan",
                tostring(player.userid), tostring(player.prefab)))
            GLOBAL.TheWorld:PushEvent("ms_playerdespawnandreplace", {
                player    = player,
                newprefab = "phamnhan",
            })
        end
    end)
end)

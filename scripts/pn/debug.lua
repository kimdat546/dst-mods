-- scripts/pn/debug.lua
-- Console commands for testing cultivation. Use from the in-game console:
--   c_addtuvi(50)               -- add 50 tu vi to local player
--   c_addtuvi(50, AllPlayers[1]) -- to a specific player
--   c_settier(3)                -- jump to Luyện Khí tầng 3
--   c_setlinhcan("THIEN", {"KIM"}) -- force-set linh căn
--   c_pnstate()                  -- print full cultivation state
-- These commands run on the SERVER; from a client, prefix with c_remote("...").

local Events = require("pn/events")
local Realms = require("pn/realms")
local LinhCanData = require("pn/linhcan_data")

-- Add tu vi (server-side; respects linhcan multiplier)
function _G.c_addtuvi(amount, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then print("[PN] no player") return end
    player:PushEvent(Events.TUVI_GAIN, { amount = amount or 100, source = "debug" })
    print(string.format("[PN] Added %d tu vi (raw) to %s", amount or 100, tostring(player.userid)))
end

-- Jump cảnh giới directly (skipping breakthrough cost)
function _G.c_settier(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_canhgioi then return end
    local cur = player.components.pn_canhgioi:GetTier()
    if tier <= cur then
        print(string.format("[PN] Already at tier %d (target %d), nothing to do", cur, tier))
        return
    end
    -- Apply tier-ups one by one to ensure stat deltas accumulate correctly
    for t = cur + 1, tier do
        player:PushEvent(Events.CANHGIOI_UP, { new_tier = t, old_tier = t - 1 })
    end
    if player.components.pn_tuvi then
        player.components.pn_tuvi:SetCapForTier(math.min(tier + 1, Realms.GetMaxTier()))
    end
    print(string.format("[PN] Set tier %d → %d for %s", cur, tier, tostring(player.userid)))
end

-- Force linh căn (overwrites existing)
function _G.c_setlinhcan(linhcan_type, elements, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_linhcan then return end
    local lc = player.components.pn_linhcan
    if not LinhCanData.TYPES[linhcan_type] then
        print("[PN] Invalid linh căn type. Valid: NGUY, CHAN, BIEN_DI, THIEN")
        return
    end
    lc.type     = linhcan_type
    lc.elements = elements or { "KIM" }
    lc.bien_di_tag = nil
    if linhcan_type == "BIEN_DI" and #lc.elements == 2 then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = combo.elements[1], combo.elements[2]
            if (lc.elements[1] == a and lc.elements[2] == b)
            or (lc.elements[1] == b and lc.elements[2] == a) then
                lc.bien_di_tag = combo.tag
                break
            end
        end
    end
    lc.rolled = true
    lc:_PushToReplica()
    print(string.format("[PN] Set linh căn = %s [%s]", lc:GetDisplay(), lc:GetElementDisplay()))
end

-- Print full cultivation state
function _G.c_pnstate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local lc = player.components.pn_linhcan
    local tv = player.components.pn_tuvi
    local cg = player.components.pn_canhgioi
    print("===== PN cultivation state for " .. tostring(player.userid) .. " =====")
    if lc then
        print(string.format("  Linh căn: %s [%s] (mult=%.2f)",
            lc:GetDisplay(), lc:GetElementDisplay(), lc:GetTuViMult()))
    end
    if cg then
        print(string.format("  Cảnh giới: %s (tier=%d)", cg:GetDisplay(), cg:GetTier()))
    end
    if tv then
        print(string.format("  Tu vi: %d / %d", tv:Get(), tv:GetCap()))
    end
end

-- Set remaining lifespan (in days)
function _G.c_setlifespan(days, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_lifespan then return end
    player.components.pn_lifespan:SetRemaining(days or 0)
    print(string.format("[PN] Set lifespan remaining = %d for %s",
        days or 0, tostring(player.userid)))
end

-- Force death of old age (triggers permadeath flow)
function _G.c_dieofold(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_lifespan then return end
    player.components.pn_lifespan:TriggerPermadeath()
end

-- Spawn a linh mạch at the player's position
function _G.c_spawnlinhmach(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    tier = (tier or "ha"):lower()
    local prefab_map = { ha = "pn_linhkhi_ha", trung = "pn_linhkhi_trung", thuong = "pn_linhkhi_thuong" }
    local prefab = prefab_map[tier]
    if not prefab then
        print("[PN] Invalid tier. Use: ha | trung | thuong")
        return
    end
    local x, y, z = player.Transform:GetWorldPosition()
    local ent = GLOBAL.SpawnPrefab(prefab)
    if ent then
        ent.Transform:SetPosition(x + 3, y, z)
        print(string.format("[PN] Spawned %s at (%.1f, %.1f, %.1f)", prefab, x + 3, y, z))
    end
end

-- Print aura state of the linh mạch nearest to player (within 20 tiles)
function _G.c_aurastate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 20, { "pn_linhkhi_source" })
    if #ents == 0 then
        print("[PN] No linh mạch within 20 tiles")
        return
    end
    for _, e in ipairs(ents) do
        if e.components.pn_aura_source then
            local a = e.components.pn_aura_source
            print(string.format("  - %s tier=%s rate=%.2f/s radius=%d",
                e.prefab, a.tier, a.rate_per_sec, a.radius))
        end
    end
end

print("[PN] Debug commands loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_setlifespan, c_dieofold, c_spawnlinhmach, c_aurastate")

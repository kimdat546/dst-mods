local Events = GLOBAL.require("pn/events")
local LinhCanData = GLOBAL.require("pn/linhcan_data")
local Realms = GLOBAL.require("pn/realms")

function GLOBAL.c_addtuvi(amount, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    player:PushEvent(Events.TUVI_GAIN, { amount=amount or 100, source="debug" })
    print("[PN] +"..tostring(amount or 100).." tu vi (raw)")
end

function GLOBAL.c_settier(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not (player and player.components.pn_canhgioi) then return end
    local cur = player.components.pn_canhgioi:GetTier()
    for t = cur+1, tier do
        player:PushEvent(Events.CANHGIOI_UP, { new_tier=t, old_tier=t-1 })
    end
    if player.components.pn_tuvi then
        player.components.pn_tuvi:SetCapForTier(math.min(tier+1, Realms.GetMaxTier()))
    end
    print("[PN] set tier → "..tostring(tier))
end

function GLOBAL.c_setlinhcan(t, elements, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    local lc = player and player.components.pn_linhcan
    if not lc or not LinhCanData.TYPES[t] then print("[PN] valid: NGUY/CHAN/BIEN_DI/THIEN") return end
    lc.type, lc.elements, lc.bien_di_tag, lc.rolled = t, elements or {"KIM"}, nil, true
    lc:_PushToReplica()
    print("[PN] linh căn = "..lc:GetDisplay().." ["..lc:GetElementDisplay().."]")
end

function GLOBAL.c_pnstate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local lc, tv, cg = player.components.pn_linhcan, player.components.pn_tuvi, player.components.pn_canhgioi
    print("===== PN state =====")
    if lc then print(string.format("  Linh căn: %s [%s] mult=%.2f", lc:GetDisplay(), lc:GetElementDisplay(), lc:GetTuViMult())) end
    if cg then print(string.format("  Cảnh giới: %s (tier %d)", cg:GetDisplay(), cg:GetTier())) end
    if tv then print(string.format("  Tu vi: %d/%d", tv:Get(), tv:GetCap())) end
end

print("[PN] debug loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate")

local ok, err = pcall(function()
    local dan_lang = require("ailang/dan_lang")
    local ds = dan_lang.TatCa()
    if #ds == 0 then print("[X5] khong co dan lang") return end
    local e = ds[1]
    local x, y, z = e.Transform:GetWorldPosition()
    for _, v in ipairs(TheSim:FindEntities(x, y, z, 60, nil, { "INLIMBO" })) do
        if v:HasTag("prototyper") or v:HasTag("ailang_banve") then v:Remove() end
    end
    for _, d in ipairs(ds) do
        d.ailang.nha = { x, z }
        d.components.inventory:GiveItem(SpawnPrefab("pickaxe"))
        d.components.inventory:GiveItem(SpawnPrefab("axe"))
    end
    local function rai(prefab, n, r, goc)
        for i = 1, n do
            local a = goc + i * 1.2
            local p = SpawnPrefab(prefab)
            p.Transform:SetPosition(x + math.cos(a) * r, y, z + math.sin(a) * r)
        end
    end
    rai("grass",     6, 10, 0)
    rai("sapling",   6, 13, 2)
    rai("evergreen", 6, 17, 4)
    rai("rock2",     4, 21, 1)
    rai("rock1",     3, 24, 3)
    local lo = SpawnPrefab("campfire")
    lo.Transform:SetPosition(x + 3, y, z)
    lo.components.fueled:SetPercent(1)
    TheWorld:PushEvent("ms_setphase", "day")
    print("[X5] canh: co/canh/cay/rock2 rai vong cung, ca 3 co cuoc va riu")
    local dem = 0
    local function soi()
        dem = dem + 1
        TheWorld:PushEvent("ms_setphase", "day")
        local bk = require("ailang/kho_lang").Kiem()
        local bv = require("ailang/ban_ve").Tim(e, nil)
        local gop = ""
        if bv ~= nil and bv.banve ~= nil then
            for pf, can in pairs(bv.banve.can) do
                gop = gop .. pf .. " " .. tostring(bv.banve.da_gop[pf] or 0) .. "/" .. tostring(can) .. "  "
            end
        end
        local lam = {}
        for _, d in ipairs(ds) do table.insert(lam, tostring(d.ailang.dang_lam)) end
        print("[X5] lan " .. dem
              .. " capmay=" .. tostring(bk.cap_may)
              .. " vang=" .. tostring(bk.goldnugget)
              .. " da=" .. tostring(bk.rocks)
              .. " go=" .. tostring(bk.log)
              .. " | banve: " .. (bv ~= nil and gop or "chua co")
              .. "| " .. table.concat(lam, " / "))
        if bk.cap_may >= 1 then
            print("[X5] DUNG DUOC MAY KHOA HOC sau " .. dem .. " lan soi")
            print("[X5] HET") return
        end
        if dem >= 26 then print("[X5] HET GIO") print("[X5] HET") return end
        TheWorld:DoTaskInTime(12, soi)
    end
    TheWorld:DoTaskInTime(12, soi)
end)
if not ok then print("[X5] NO: " .. tostring(err)) end

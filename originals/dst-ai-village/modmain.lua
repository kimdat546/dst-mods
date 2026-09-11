-- AI Làng — điểm vào.
--
-- Chỉ chạy phía chủ (mastersim). Client không cần làm gì ngoài việc tải mod.

local GLOBAL_ = GLOBAL

-- Cấu hình phải nhét vào GLOBAL trước khi require bất cứ file nào trong
-- scripts/, vì các file đó chạy trong môi trường game và không thấy
-- GetModConfigData.
GLOBAL.AILANG_CAUHINH = {
    so_dan_lang  = GetModConfigData("so_dan_lang")  or 1,
    bat_tam_tri  = GetModConfigData("bat_tam_tri")  or false,
    nhip_suy_nghi = GetModConfigData("nhip_suy_nghi") or 15,
    muc_log      = GetModConfigData("muc_log")      or 1,
}

local nen      = GLOBAL.require("ailang/nen")
local dan_lang = GLOBAL.require("ailang/dan_lang")

local cauhinh = GLOBAL.AILANG_CAUHINH

local function QuanLy()
    local w = GLOBAL.TheWorld
    return w ~= nil and w.components ~= nil and w.components.ailangquanly or nil
end

AddPrefabPostInit("world", function(inst)
    if not inst.ismastersim then return end
    inst:AddComponent("ailangquanly")
end)

AddSimPostInit(function()
    local w = GLOBAL.TheWorld
    if w == nil or not w.ismastersim then return end

    -- Dựng lại dân làng cũ, rồi bù cho đủ số đã cấu hình. Hoãn một nhịp để
    -- world nạp xong hẳn (playerspawner mới sẵn sàng).
    w:DoTaskInTime(1, function()
        local ql = QuanLy()
        if ql == nil then
            nen.loi("không gắn được component quản lý làng")
            return
        end

        ql:DungLai()

        local thieu = cauhinh.so_dan_lang - ql:Dem()
        for _ = 1, math.max(0, thieu) do
            nen.thu("sinh dân làng mới", function() ql:Them(nil) end)
        end
        nen.log("làng có", ql:Dem(), "dân")

        if cauhinh.bat_tam_tri then
            local cau_noi = GLOBAL.require("ailang/cau_noi")
            cau_noi.Bat(cauhinh.nhip_suy_nghi)
        else
            nen.log("tầng suy nghĩ TẮT — dân làng chạy bằng não phản xạ")
        end
    end)
end)

-- ── lệnh console ────────────────────────────────────────────────────────
--
-- ⚠ ĐỪNG dùng print() cho mấy lệnh này. print() chỉ đi vào client_log.txt,
--   người chơi gõ lệnh trong game thì KHÔNG THẤY GÌ và tưởng lệnh hỏng.
--   TheNet:Announce() hiện thẳng trong khung chat, ai cũng đọc được.

-- ⚠ modmain chạy trong môi trường HẠN CHẾ: `select` không có sẵn ở đây, phải
--   lấy qua GLOBAL. Lỗi chỉ nổ lúc gọi lệnh chứ không nổ lúc nạp mod.
local select = GLOBAL.select

local function Bao(...)
    local phan = {}
    for i = 1, select("#", ...) do
        table.insert(phan, tostring((select(i, ...))))
    end
    local dong = table.concat(phan, " ")
    GLOBAL.TheNet:Announce(dong)
    print("[ailang] " .. dong)
end

GLOBAL.c_ailang_them = function(ten, nhan_vat)
    local ql = QuanLy()
    if ql == nil then Bao("chưa có quản lý làng") return end
    local inst = ql:Them({ ten = ten, nhan_vat = nhan_vat })
    if inst == nil then Bao("không sinh được dân làng") return end
    if GLOBAL.ThePlayer ~= nil then
        local x, y, z = GLOBAL.ThePlayer.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, y, z)
    end
    Bao("đã thêm dân làng", inst.ailang.ten, "(" .. inst.prefab .. ")")
    return inst
end

GLOBAL.c_ailang_dem = function()
    local ql = QuanLy()
    local ds = dan_lang.TatCa()
    Bao(string.format("làng: %d hồ sơ, %d đang sống",
        ql ~= nil and ql:Dem() or 0, #ds))
    if #ds == 0 then
        Bao("(không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?)")
        return
    end
    for _, e in ipairs(ds) do
        local x, _, z = e.Transform:GetWorldPosition()
        local tui = e.components.inventory
        local cam = tui ~= nil and tui:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) or nil
        Bao(string.format("  %s (%s) %s máu=%d%% đói=%d%% cầm=%s tại %.0f,%.0f",
            tostring(e.ailang.ten), e.prefab,
            e.ailang.la_hon_ma and "[HỒN MA]" or "",
            math.floor((e.components.health and e.components.health:GetPercent() or 1) * 100),
            math.floor((e.components.hunger and e.components.hunger:GetPercent() or 1) * 100),
            tostring(cam and cam.prefab or "tay không"), x, z))
    end
end

GLOBAL.c_ailang_xoahet = function()
    local ql = QuanLy()
    if ql ~= nil then ql:XoaHet() Bao("đã xoá toàn bộ dân làng") end
end

-- Đặt nhà cho dân làng — chúng sẽ quanh quẩn đó thay vì bám theo người chơi.
GLOBAL.c_ailang_datnha = function()
    if GLOBAL.ThePlayer == nil then Bao("không xác định được vị trí") return end
    local x, _, z = GLOBAL.ThePlayer.Transform:GetWorldPosition()
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        e.ailang.nha = { x, z }
        n = n + 1
    end
    Bao(string.format("đặt nhà cho %d dân làng tại %.0f,%.0f", n, x, z))
end

-- Phát nguyên liệu làm đuốc cho cả làng — để thử nhánh ban đêm cho nhanh.
GLOBAL.c_ailang_tiepte = function()
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        local tui = e.components.inventory
        if tui ~= nil then
            for _, m in ipairs({ "cutgrass", "cutgrass", "twigs", "twigs" }) do
                tui:GiveItem(GLOBAL.SpawnPrefab(m))
            end
            n = n + 1
        end
    end
    Bao(string.format("đã phát 2 cỏ + 2 cành cho %d dân làng", n))
end

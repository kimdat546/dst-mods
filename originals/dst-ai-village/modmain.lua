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
-- Gõ trong game: c_ailang_them("Tí", "wx78")

GLOBAL.c_ailang_them = function(ten, nhan_vat)
    local ql = QuanLy()
    if ql == nil then print("[ailang] chưa có quản lý làng") return end
    local inst = ql:Them({ ten = ten, nhan_vat = nhan_vat })
    if inst ~= nil and GLOBAL.ThePlayer ~= nil then
        local x, y, z = GLOBAL.ThePlayer.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, y, z)
    end
    return inst
end

GLOBAL.c_ailang_dem = function()
    local ql = QuanLy()
    local song = #dan_lang.TatCa()
    print(string.format("[ailang] hồ sơ=%d | đang sống=%d",
            ql ~= nil and ql:Dem() or 0, song))
    for _, e in ipairs(dan_lang.TatCa()) do
        local x, _, z = e.Transform:GetWorldPosition()
        print(string.format("[ailang]   %s (%s) máu=%d%% đói=%d%% tại %.0f,%.0f mục_tiêu=%s",
            tostring(e.ailang.ten), e.prefab,
            math.floor((e.components.health and e.components.health:GetPercent() or 1) * 100),
            math.floor((e.components.hunger and e.components.hunger:GetPercent() or 1) * 100),
            x, z, tostring(e.ailang.muc_tieu)))
    end
end

GLOBAL.c_ailang_xoahet = function()
    local ql = QuanLy()
    if ql ~= nil then ql:XoaHet() end
end

-- Đặt nhà cho dân làng gần nhất — nó sẽ lang thang quanh đó thay vì bám người.
GLOBAL.c_ailang_datnha = function()
    if GLOBAL.ThePlayer == nil then return end
    local x, _, z = GLOBAL.ThePlayer.Transform:GetWorldPosition()
    for _, e in ipairs(dan_lang.TatCa()) do
        e.ailang.nha = { x, z }
    end
    print(string.format("[ailang] đặt nhà cho %d dân làng tại %.0f,%.0f",
            #dan_lang.TatCa(), x, z))
end

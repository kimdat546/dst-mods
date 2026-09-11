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
-- Thân lệnh nằm trong scripts/ailang/lenh.lua chứ không phải ở đây, để NẠP
-- NÓNG được. modmain chỉ chạy một lần lúc world khởi động; mọi thứ định nghĩa
-- ở đây đều đóng băng tới khi khởi động lại game.

local nap_lai = GLOBAL.require("ailang/nap_lai")
nap_lai.DangKyLenh()

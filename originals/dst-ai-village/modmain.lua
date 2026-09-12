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
    ban_kinh_lang = GetModConfigData("ban_kinh_lang") or 60,
}

PrefabFiles = { "ailang_dai" }

local nen      = GLOBAL.require("ailang/nen")
local dan_lang = GLOBAL.require("ailang/dan_lang")

local cauhinh = GLOBAL.AILANG_CAUHINH

-- ── Đài Triệu Hồi ───────────────────────────────────────────────────────
--
-- Vừa là chỗ gọi dân làng mới, vừa LÀ NHÀ của cả làng. Xem
-- scripts/prefabs/ailang_dai.lua để biết vì sao gộp hai vai vào một.
--
-- ⚠ Dùng ảnh và dáng của resurrection_stone trong vanilla. Mod chưa có tài
--   nguyên riêng, mà bank/build vanilla thì client nào cũng có nên không cần
--   phần chạy ở client.
GLOBAL.STRINGS.NAMES.AILANG_DAI = "Đài Triệu Hồi"
GLOBAL.STRINGS.RECIPE_DESC.AILANG_DAI = "Gọi dân làng về, và làm nhà cho họ."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.AILANG_DAI =
    "Dân làng tụ về quanh nó."
GLOBAL.STRINGS.ACTIONS.ACTIVATE.TRIEUHOI = "Triệu hồi dân làng"

-- ⚠ `TECH` và `Ingredient` là biến TOÀN CỤC, phải lấy qua GLOBAL. Môi trường
--   modmain bị hạn chế nên gọi thẳng sẽ nổ "attempt to index global 'TECH'
--   (a nil value)" và MOD KHÔNG NẠP ĐƯỢC — cùng loại lỗi với `select`.
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

AddRecipe2("ailang_dai",
    {
        Ingredient("goldnugget", 2),
        Ingredient("log", 8),
        Ingredient("rocks", 6),
    },
    TECH.NONE,
    {
        placer = "ailang_dai_placer",
        -- ⚠ Mượn ảnh công thức của vanilla. Mod chưa có tài nguyên riêng, mà
        --   trỏ vào atlas không tồn tại thì ô công thức hiện ô vuông hồng.
        atlas = "images/inventoryimages3.xml",
        image = "resurrectionstatue_monster.tex",
        min_spacing = 6,
    },
    { "STRUCTURES" })

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

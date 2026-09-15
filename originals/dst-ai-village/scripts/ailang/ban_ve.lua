-- Tầng dùng BẢN VẼ CÔNG TRÌNH — xem scripts/prefabs/ailang_banve.lua cho lý do.
--
-- Chia vai rõ ràng:
--     nhu cầu   quyết ĐỊNH DỰNG GÌ, và đặt bản vẽ xuống khi tự mình không đủ
--     việc      lo MANG LIỆU TỚI, và đó là việc của cả làng
--
-- Nhờ tách vậy mà ba dân làng mỗi đứa ôm 2 khúc gỗ vẫn dựng được Máy Khoa Học,
-- thứ mà `builder:DoBuild` (đòi một người cầm đủ cả bộ) không bao giờ làm nổi.

local nen = require("ailang/nen")
local lang = require("ailang/lang")

local ban_ve = {}

-- Chỉ những công trình ĐÁNG chờ cả làng góp mới dùng bản vẽ. Đống lửa khẩn cấp
-- thì không: cần nó là cần NGAY, chờ người khác mang gỗ tới là chết đêm.
ban_ve.DUNG_BAN_VE = {
    researchlab   = true,
    researchlab2  = true,
    treasurechest = true,
    cookpot       = true,
    icebox        = true,
    firepit       = true,
    meatrack      = true,
}

function ban_ve.Dung(cong_thuc)
    return cong_thuc ~= nil and ban_ve.DUNG_BAN_VE[cong_thuc] == true
end

-- Bản vẽ của công thức này đã có trong làng chưa?
function ban_ve.Tim(inst, cong_thuc)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    for _, v in ipairs(TheSim:FindEntities(tam[1], 0, tam[2], lang.BanKinh(inst),
            { "ailang_banve" }, { "INLIMBO", "burnt" })) do
        if v.banve ~= nil
           and (cong_thuc == nil or v.banve.cong_thuc == cong_thuc) then
            return v
        end
    end
    return nil
end

-- Đặt bản vẽ ở làng. Trả về bản vẽ (mới hoặc đã có sẵn), hoặc nil.
function ban_ve.Dat(inst, cong_thuc)
    if not ban_ve.Dung(cong_thuc) then return nil end
    local co = ban_ve.Tim(inst, cong_thuc)
    if co ~= nil then return co end

    local tam = lang.Tam(inst)
    if tam == nil then return nil end

    -- ⚠ MỘT BẢN VẼ MỘT LÚC. Cho đặt nhiều thì làng chia liệu ra khắp nơi và
    --   không cái nào xong — đúng bệnh mà bản vẽ sinh ra để chữa, chỉ đổi từ
    --   "chia giữa các túi" sang "chia giữa các bản vẽ".
    if ban_ve.Tim(inst, nil) ~= nil then return nil end

    local bv
    local ok = nen.thu("đặt bản vẽ " .. tostring(cong_thuc), function()
        bv = SpawnPrefab("ailang_banve")
        if bv == nil then error("không sinh được ailang_banve") end
        -- Lệch khỏi tâm làng để khỏi chồng lên Đài.
        bv.Transform:SetPosition(tam[1] + 6, 0, tam[2] + 6)
        if not bv.DatCongThuc(bv, cong_thuc) then bv = nil end
    end)
    if not ok or bv == nil then return nil end
    nen.log("đặt bản vẽ", cong_thuc, "ở làng")
    return bv
end

-- Bản vẽ trong làng đang thiếu gì? Trả về bản vẽ, tên nguyên liệu, số còn thiếu.
function ban_ve.DangThieu(inst)
    local bv = ban_ve.Tim(inst, nil)
    if bv == nil then return nil end
    local prefab, con = bv.ConThieu(bv)
    if prefab == nil then return nil end
    return bv, prefab, con
end

return ban_ve

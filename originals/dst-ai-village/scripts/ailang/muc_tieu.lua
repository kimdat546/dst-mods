-- Thực thi MỤC TIÊU do tầng suy nghĩ đặt xuống.
--
-- ⚠ TRƯỚC BẢN NÀY, `muc_tieu` LÀ MỘT ỐNG DẪN RA HƯ KHÔNG. cau_noi nhận câu trả
--   lời, gán `e.ailang.muc_tieu = y.muc_tieu`, dan_lang khai báo nó và xoá nó
--   lúc chết — và KHÔNG MỘT DÒNG NÀO ĐỌC. Gemini ra lệnh gì cũng được, dân làng
--   không bao giờ biết. Tệp này là chỗ ống đó cắm vào thế giới.
--
-- ⚠ VÀ NÓ NẰM DƯỚI CÁC PHẢN XẠ GIỮ MẠNG. Trời tối mà tầng suy nghĩ bảo đi đào
--   đá thì phản xạ ánh sáng vẫn thắng. Tầng suy nghĩ có độ trễ vài giây, nó
--   không thấy được con ếch đang cắn hay cây đuốc sắp tàn. Nó lái CHIẾN LƯỢC,
--   không lái phản xạ. Xem thứ tự node trong danlangbrain.lua.
--
-- Hình dạng mục tiêu (xem hanh_dong.lua cho từng trường):
--     { hanh_dong = "CHOP", nham = "evergreen", dung = "axe", lan = 5 }
--     { che = "researchlab", dat_xuong = true }
--     { buoc = { {...}, {...} } }          -- làm lần lượt
--
-- Mọi lỗi được GIỮ LẠI trong `a.muc_tieu_loi` và gửi ngược trong gói hỏi kế
-- tiếp. Nuốt lỗi thì tầng suy nghĩ ra lệnh sai mãi mà không biết vì sao.

local nen = require("ailang/nen")
local hanh_dong = require("ailang/hanh_dong")

local muc_tieu = {}

-- Hỏng liên tiếp bấy nhiêu lần thì bỏ cuộc, khỏi quay vòng vô ích.
local BO_CUOC = 6

-- Lấy bước đang phải làm của mục tiêu hiện tại.
local function BuocHienTai(inst)
    local a = inst.ailang
    local mt = a ~= nil and a.muc_tieu or nil
    if type(mt) ~= "table" then return nil end

    if mt.buoc == nil then return mt end

    local i = a.muc_tieu_i or 1
    return mt.buoc[i]
end

function muc_tieu.Co(inst)
    return BuocHienTai(inst) ~= nil
end

function muc_tieu.Bo(inst, vi_sao)
    local a = inst.ailang
    if a == nil then return end
    if a.muc_tieu ~= nil then
        nen.chitiet(tostring(a.ten), "bỏ mục tiêu —", tostring(vi_sao))
    end
    a.muc_tieu   = nil
    a.muc_tieu_i = nil
    a.muc_tieu_hong = 0
    a.muc_tieu_loi = vi_sao
end

-- Xong một bước: sang bước sau, hoặc xong cả mục tiêu.
local function XongMotBuoc(inst)
    local a = inst.ailang
    if a == nil or a.muc_tieu == nil then return end
    a.muc_tieu_hong = 0

    local buoc = BuocHienTai(inst)
    if buoc == nil then return end

    -- Còn lượt lặp thì làm tiếp bước này.
    if type(buoc.lan) == "number" and buoc.lan > 1 then
        buoc.lan = buoc.lan - 1
        return
    end

    if a.muc_tieu.buoc == nil then
        muc_tieu.Bo(inst, nil)   -- lệnh đơn, xong là hết
        a.muc_tieu_loi = nil
        return
    end

    a.muc_tieu_i = (a.muc_tieu_i or 1) + 1
    if a.muc_tieu.buoc[a.muc_tieu_i] == nil then
        muc_tieu.Bo(inst, nil)
        a.muc_tieu_loi = nil
    end
end

local function HongMotLan(inst, vi_sao)
    local a = inst.ailang
    if a == nil then return end
    a.muc_tieu_hong = (a.muc_tieu_hong or 0) + 1
    a.muc_tieu_loi  = vi_sao
    if a.muc_tieu_hong >= BO_CUOC then
        muc_tieu.Bo(inst, vi_sao)
    end
end

-- Sinh hành động cho cây hành vi. Trả nil khi không có mục tiêu, hoặc khi vừa
-- làm xong một việc tức thì (chế đồ) — nhịp sau cây sẽ gọi lại.
function muc_tieu.HanhDong(inst)
    local buoc = BuocHienTai(inst)
    if buoc == nil then return nil end

    local ra, loi = hanh_dong.Chay(inst, buoc)

    if ra == "xong" then
        XongMotBuoc(inst)
        return nil
    end

    if ra == nil then
        HongMotLan(inst, loi)
        return nil
    end

    -- Đếm thành/bại qua chính BufferedAction, vì cây hành vi không báo lại.
    ra:AddSuccessAction(function() nen.thu("xong bước mục tiêu", XongMotBuoc, inst) end)
    ra:AddFailAction(function()
        nen.thu("hỏng bước mục tiêu", HongMotLan, inst, "hành động bị từ chối")
    end)
    return ra
end

-- Đặt mục tiêu từ ngoài (tầng suy nghĩ hoặc lệnh console). Soát trước khi nhận
-- để lệnh sai bị bắt NGAY, kèm lý do đọc được.
function muc_tieu.Dat(inst, mt)
    local a = inst.ailang
    if a == nil then return false, "không phải dân làng" end
    if mt == nil then
        muc_tieu.Bo(inst, nil)
        a.muc_tieu_loi = nil
        return true
    end
    if type(mt) ~= "table" then return false, "mục tiêu phải là bảng" end

    local ds = mt.buoc or { mt }
    if type(ds) ~= "table" or #ds == 0 then return false, "mục tiêu rỗng" end
    for i, buoc in ipairs(ds) do
        local ok, loi = hanh_dong.Soat(buoc)
        if not ok then
            a.muc_tieu_loi = "bước " .. i .. ": " .. tostring(loi)
            return false, a.muc_tieu_loi
        end
    end

    a.muc_tieu      = mt
    a.muc_tieu_i    = 1
    a.muc_tieu_hong = 0
    a.muc_tieu_loi  = nil
    nen.chitiet(tostring(a.ten), "nhận mục tiêu", #ds, "bước")
    return true
end

return muc_tieu

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

-- ⚠ HAI LOẠI HỎNG, ĐỪNG GỘP. Kiểm trên server thật bắt được: dân làng đang
--   CHOP đúng như lệnh, mục tiêu vẫn còn, mà `muc_tieu_loi` đã là "hành động
--   bị từ chối".
--
--     * hỏng lúc TÍNH  — Chay() không dựng nổi hành động: không thấy mục tiêu,
--       không có món cần dùng, động từ không tồn tại. Đây là lệnh SAI, đếm đủ
--       vài lần là bỏ, và báo ngược lên cho tầng suy nghĩ sửa.
--     * hỏng lúc LÀM   — engine từ chối hành động đã phát ra. Chuyện này xảy
--       ra suốt trong lúc chạy bình thường: cây vừa đổ, ai đó chặt mất, hoặc
--       một phản xạ giữ mạng cắt ngang. Đếm nó vào cùng một sổ thì sáu lần
--       chập tối là một mục tiêu HOÀN TOÀN ĐÚNG bị vứt.
--
--   Nên: chỉ hỏng-lúc-tính mới đếm. Hỏng-lúc-làm chỉ ghi lý do.
local BO_CUOC = 6

-- Nhưng cũng đừng ôm mãi một mục tiêu không bao giờ xong. `{EAT, rock1}` tính
-- được, phát ra được, và bị từ chối tới muôn đời. Quá bấy nhiêu giây không
-- tiến được bước nào thì buông.
local BO_CUOC_GIAY = 180

-- ⚠ ĐÀO VÀ CHẶT KHÔNG BỎ ĐỒ VÀO TÚI — NÓ RƠI XUỐNG ĐẤT. Đây là thứ làm cả một
--   mục tiêu ba bước chạy xong mà chẳng được gì. Đo trên server thật:
--
--     lệnh: MINE rock2 ×6  ->  CHOP ×8  ->  chế researchlab
--     kết quả: bước 1 xong, bước 2 xong, bước 3 "chưa đủ nguyên liệu",
--              mà vàng=0 đá=0 gỗ=0.
--
--   Cả hai bước đầu đều LÀM ĐÚNG. Vàng và gỗ nằm ngay dưới chân, chỉ là không
--   ai nhặt. Chính sách mặc định có việc nhặt đồ, nhưng nó nằm dưới và lúc đó
--   dân làng đang lo cái bụng.
--
--   Nên tầng này tự nhặt: còn đồ rơi quanh chân thì nhặt trước, và KHÔNG tính
--   vào `lan` — nhặt không phải là một lượt làm việc.
local TAM_NHAT = 8

local HANH_DONG_ROI_DO = {
    [ACTIONS.CHOP]   = true,
    [ACTIONS.MINE]   = true,
    [ACTIONS.HAMMER] = true,
    [ACTIONS.DIG]    = true,
}

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
    a.muc_tieu_tu = nil
    a.muc_tieu_loi = vi_sao
end

-- ⚠ `lan` ĐẾM MỤC TIÊU LÀM XONG, KHÔNG ĐẾM NHÁT CHÉM. ACTIONS.CHOP trả true
--   cho MỖI NHÁT, nên bản đầu "CHOP ×8" nghĩa là tám nhát rìu — mà hạ một cây
--   thông cần khoảng mười nhát. Đo trên server: bước chặt chạy đủ tám lượt,
--   KHÔNG cây nào đổ, gỗ=0, rồi bước chế báo thiếu nguyên liệu.
--
--   Tầng suy nghĩ (và người viết lệnh tay) hiểu "×8" là tám CÂY. Nên nhát nào
--   chưa hạ được mục tiêu thì tính là có tiến triển, không tính là một lượt.
local function ChuaHaDuoc(act, muc)
    if muc == nil or not muc:IsValid() then return false end
    local w = muc.components.workable
    return w ~= nil and w:CanBeWorked()
end

-- Xong một bước: sang bước sau, hoặc xong cả mục tiêu.
local function XongMotBuoc(inst)
    local a = inst.ailang
    if a == nil or a.muc_tieu == nil then return end
    a.muc_tieu_hong = 0
    a.muc_tieu_tu   = GetTime()   -- có tiến triển, tính lại từ đầu

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

-- Hỏng lúc TÍNH: lệnh sai, đếm vào sổ.
local function HongMotLan(inst, vi_sao)
    local a = inst.ailang
    if a == nil then return end
    a.muc_tieu_hong = (a.muc_tieu_hong or 0) + 1
    a.muc_tieu_loi  = vi_sao
    if a.muc_tieu_hong >= BO_CUOC then
        muc_tieu.Bo(inst, vi_sao)
    end
end

-- Hỏng lúc LÀM: chỉ ghi lý do, không đếm. Cái van chặn vòng lặp vô tận ở đây
-- là đồng hồ BO_CUOC_GIAY, xem QuaLau.
local function TuChoiMotLan(inst, vi_sao)
    local a = inst.ailang
    if a == nil then return end
    a.muc_tieu_loi = vi_sao
end

local function QuaLau(inst)
    local a = inst.ailang
    if a == nil or a.muc_tieu_tu == nil then return false end
    return GetTime() - a.muc_tieu_tu > BO_CUOC_GIAY
end

-- Sinh hành động cho cây hành vi. Trả nil khi không có mục tiêu, hoặc khi vừa
-- làm xong một việc tức thì (chế đồ) — nhịp sau cây sẽ gọi lại.
-- Có đồ vừa rơi quanh chân không? Trả về hành động nhặt, hoặc nil.
local function NhatDoVuaRoi(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local mon = FindEntity(inst, TAM_NHAT, function(v)
        return v.components.inventoryitem ~= nil
           and v.components.inventoryitem.canbepickedup
           and not v.components.inventoryitem:IsHeld()
           and v:IsOnValidGround()
    end, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire", "irreplaceable" })
    if mon == nil then return nil end
    return BufferedAction(inst, mon, ACTIONS.PICKUP)
end

function muc_tieu.HanhDong(inst)
    local buoc = BuocHienTai(inst)
    if buoc == nil then return nil end

    if QuaLau(inst) then
        muc_tieu.Bo(inst, "quá " .. BO_CUOC_GIAY .. " giây không tiến được bước nào")
        return nil
    end

    -- Vừa đào/chặt xong thì nhặt chiến lợi phẩm trước đã.
    -- (`act` dùng lại ở dưới để biết đây có phải việc bào mòn không.)
    local act = buoc.hanh_dong ~= nil and hanh_dong.Tra(buoc.hanh_dong) or nil
    if act ~= nil and HANH_DONG_ROI_DO[act] then
        local nhat = NhatDoVuaRoi(inst)
        if nhat ~= nil then
            -- Nhặt được là có tiến triển: đặt lại đồng hồ bỏ cuộc.
            nhat:AddSuccessAction(function()
                local a = inst.ailang
                if a ~= nil then a.muc_tieu_tu = GetTime() end
            end)
            return nhat
        end
    end

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
    local muc = ra.target
    ra:AddSuccessAction(function()
        -- Mục tiêu còn đứng đó và còn làm được nữa: mới là một nhát, chưa
        -- phải một lượt. Ghi nhận tiến triển rồi thôi.
        if HANH_DONG_ROI_DO[act] and ChuaHaDuoc(act, muc) then
            local a = inst.ailang
            if a ~= nil then a.muc_tieu_tu = GetTime() end
            return
        end
        nen.thu("xong bước mục tiêu", XongMotBuoc, inst)
    end)
    ra:AddFailAction(function()
        nen.thu("bước mục tiêu bị từ chối", TuChoiMotLan, inst, "hành động bị từ chối")
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
    a.muc_tieu_tu   = GetTime()
    a.muc_tieu_loi  = nil
    nen.chitiet(tostring(a.ten), "nhận mục tiêu", #ds, "bước")
    return true
end

return muc_tieu

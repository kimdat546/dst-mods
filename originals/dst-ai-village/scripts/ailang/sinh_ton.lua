-- Bộ giải nhu cầu sinh tồn.
--
-- Đi từ nhu cầu ưu tiên cao nhất xuống. Với nhu cầu đầu tiên chưa thoả:
--   1. Có sẵn món ở bậc nào thì mặc/cầm món đó
--   2. Không có nhưng chế được thì chế
--   3. Không chế được bậc nào thì đi kiếm nguyên liệu còn thiếu cho bậc RẺ
--      NHẤT — đó là chỗ dân làng trông "biết tính" thay vì đi lang thang
--
-- Trả về:
--   "xong"           vừa làm xong một việc tức thì (mặc/chế), không cần hành động
--   BufferedAction   cần đi làm gì đó (hái/chặt/đào/nhặt)
--   nil              không có việc gì

local nen      = require("ailang/nen")
local nhu_cau  = require("ailang/nhu_cau")
local ban_ve   = require("ailang/ban_ve")

local sinh_ton = {}

local TAM_KIEM     = 30    -- bán kính đi kiếm bình thường
-- ⚠ PHẢI KHỚP với VE_NHA_XA_GAP trong danlangbrain. Con số này từng là 80
--   trong khi dây trói về nhà là 50, nên nó vô nghĩa. Xem chú thích ở đó.
local TAM_KIEM_GAP = 130   -- bán kính khi nhu cầu đã cấp thiết

-- ⚠ Bán kính 30 là QUÁ HẸP khi đã bí. Đo trên server thật: một dân làng não 0%
--   mà thế giới còn 321 bụi hoa — chỉ là không có bụi nào trong vòng 30, nên
--   nó đứng chịu trận. Nhu cầu càng gấp thì phải chịu khó đi xa hơn.
local BO_QUA   = { "INLIMBO", "NOCLICK", "FX", "fire", "burnt", "catchable" }

local HANH_DONG = {
    PICK   = function() return ACTIONS.PICK end,
    CHOP   = function() return ACTIONS.CHOP end,
    MINE   = function() return ACTIONS.MINE end,
    PICKUP = function() return ACTIONS.PICKUP end,
}

-- ── nguyên liệu còn thiếu ───────────────────────────────────────────────

local function Dem(inst, ten)
    local tui = inst.components.inventory
    if tui == nil then return 0 end
    local n = 0
    nhu_cau.DuyetTui(inst, function(m)
        if m.prefab == ten then
            n = n + (m.components.stackable ~= nil
                     and m.components.stackable:StackSize() or 1)
        end
        return false
    end)
    return n
end

-- Những gì còn thiếu để chế `ten`, theo dạng { {nguyen_lieu, so_luong}, ... }.
function sinh_ton.ConThieu(inst, ten)
    local ct = AllRecipes[ten]
    if ct == nil then return nil end
    local thieu = {}
    for _, ng in ipairs(ct.ingredients or {}) do
        local con = ng.amount - Dem(inst, ng.type)
        if con > 0 then table.insert(thieu, { ng.type, con }) end
    end
    return thieu
end

-- ── dụng cụ ─────────────────────────────────────────────────────────────

local function CamDungCu(inst, hanh_dong)
    local tui = inst.components.inventory
    if tui == nil then return false end
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil and cam.components.tool ~= nil
       and cam.components.tool:CanDoAction(hanh_dong) then
        return true
    end
    local dc = nhu_cau.DuyetTui(inst, function(m)
        return m.components.tool ~= nil and m.components.tool:CanDoAction(hanh_dong)
    end)
    if dc ~= nil then tui:Equip(dc) return true end
    return false
end

sinh_ton.CamDungCu = CamDungCu

-- ── đi kiếm một nguyên liệu ─────────────────────────────────────────────

-- ⚠ Mục tiêu đi kiếm phải NẰM TRONG VÙNG LÀNG. Không chặn thì dân làng trôi
--   vô hạn: kiếm xong ở chỗ mới lại tìm tiếp từ chỗ mới, mỗi vòng xa thêm.
--   Đo trên server thật: cả ba chết cách nhà 95-235 đơn vị.
local TAM_LANG = 55

-- ⚠ Khi nhu cầu đã GẤP thì cho phép ra ngoài vùng làng. Không nới thì giới
--   hạn làng (55) chặn luôn cả vòng tìm khẩn cấp (80), và dân làng kẹt
--   "chưa có cách" giữa đêm dù chỉ thiếu 2 cành cây. Đã gặp thật: quanh làng
--   không có bụi cây con nào.
local function TrongLang(inst, v, tam)
    -- Ban đêm thì chỉ quanh đống lửa — xem lang.LamDuocLucNay.
    if not require("ailang/lang").LamDuocLucNay(inst, v) then return false end
    local nha = inst.ailang ~= nil and inst.ailang.nha or nil
    if nha == nil then return true end
    local gioi_han = math.max(TAM_LANG, tam or 0)
    local x, _, z = v.Transform:GetWorldPosition()
    return (x - nha[1]) ^ 2 + (z - nha[2]) ^ 2 <= gioi_han * gioi_han
end

function sinh_ton.DiKiem(inst, nguyen_lieu, bo_qua_fn, tam)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local TAM_KIEM = tam or TAM_KIEM

    -- Nằm sẵn dưới đất thì nhặt, khỏi phải khai thác.
    local roi = FindEntity(inst, TAM_KIEM, function(v)
        return TrongLang(inst, v, tam)
           and v.prefab == nguyen_lieu
           and v.components.inventoryitem ~= nil
           and v.components.inventoryitem.canbepickedup
           and v:IsOnValidGround()
           and not (bo_qua_fn ~= nil and bo_qua_fn(v))
    end, { "_inventoryitem" }, BO_QUA)
    if roi ~= nil then return BufferedAction(inst, roi, ACTIONS.PICKUP) end

    local nguon = nhu_cau.NGUON[nguyen_lieu]
    if nguon == nil then return nil end
    local hd = HANH_DONG[nguon.hd]
    if hd == nil then return nil end
    local hanh_dong = hd()

    if nguon.hd == "CHOP" or nguon.hd == "MINE" then
        -- Đêm mà chỉ có đuốc cầm tay thì thôi, để mai làm.
        if nhu_cau.KhongRanhTay(inst) then return nil end
        if not CamDungCu(inst, hanh_dong) then
            return nil      -- không có dụng cụ thì thôi, tụt bậc khác
        end
    end

    local muc = FindEntity(inst, TAM_KIEM, function(v)
        if not TrongLang(inst, v, tam) then return false end
        if bo_qua_fn ~= nil and bo_qua_fn(v) then return false end
        if nguon.prefab ~= nil and v.prefab ~= nguon.prefab then return false end
        if nguon.hd == "PICK" then
            return v.components.pickable ~= nil
               and v.components.pickable:CanBePicked()
               and v.components.pickable.caninteractwith ~= false
        end
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == hanh_dong
    end, { nguon.tag }, BO_QUA)

    if muc == nil then return nil end
    return BufferedAction(inst, muc, hanh_dong)
end

-- ── nhu cầu không tiến triển thì NGHỈ một lúc ───────────────────────────
--
-- ⚠ Một nhu cầu có thể GIẢI ĐƯỢC VỀ LÝ THUYẾT mà KHÔNG BAO GIỜ XONG, và khi
--   đó nó chặn đứng mọi nhu cầu xếp dưới. Đo trên server: cả ba dân làng kẹt
--   vĩnh viễn ở "mát" — mũ cỏ cần 12 bó, quanh làng chỉ có 3 bụi, hái xong
--   phải chờ mọc lại. Bộ giải vẫn tìm ra bụi cỏ mỗi nhịp nên không bao giờ coi
--   là bó tay, trong khi số cỏ trong túi đứng im ở 2-3 suốt nhiều phút. Hậu
--   quả: KHÔNG AI dựng lửa trại (lua=0) và cả làng vào đêm tay trắng.
--
--   Nên đo TIẾN TRIỂN THẬT — tổng số nguyên liệu còn thiếu — chứ không đo
--   "có tìm thấy mục tiêu không". Đứng im quá lâu thì nghỉ nhu cầu đó một lúc
--   để những nhu cầu dưới được chạy.
local KIEN_NHAN_NHU_CAU = 90    -- giây, không tiến triển thì nghỉ
local NGHI_BAO_LAU      = 120   -- giây

local function TongConThieu(inst, n)
    local re_nhat = n.bac ~= nil and n.bac[#n.bac] or nil
    if re_nhat == nil then return nil end
    local tong = 0
    for _, t in ipairs(sinh_ton.ConThieu(inst, re_nhat.mon) or {}) do
        tong = tong + t[2]
    end
    return tong
end

-- Nhu cầu này đang nghỉ à?
local function DangNghi(inst, n)
    local a = inst.ailang
    if a == nil or a.nghi == nil then return false end
    local het = a.nghi[n.ten]
    if het == nil then return false end
    if GetTime() > het then a.nghi[n.ten] = nil return false end
    return true
end

-- Ghi nhận tiến triển; trả về true nếu vừa quyết định cho nhu cầu này nghỉ.
local function SoatTienTrien(inst, n)
    local a = inst.ailang
    if a == nil then return false end
    if a.moc_tien == nil then a.moc_tien = {} end
    if a.nghi == nil then a.nghi = {} end

    local con = TongConThieu(inst, n)
    if con == nil then return false end
    -- ⚠ ĐỦ NGUYÊN LIỆU RỒI thì KHÔNG phải là đứng im — nó đang chờ tới lượt
    --   chế, và cho nghỉ lúc này là vứt đi đúng công sức vừa gom xong. Đo trên
    --   server: Cuong gom được 14 bó cỏ (mũ cần 12), thiếu=0, CanBuild=true —
    --   cho nghỉ ở trạng thái đó là phí cả buổi hái cỏ.
    if con <= 0 then
        if inst.ailang.moc_tien ~= nil then inst.ailang.moc_tien[n.ten] = nil end
        return false
    end

    local m = a.moc_tien[n.ten]
    if m == nil or m.con ~= con then
        a.moc_tien[n.ten] = { con = con, tu = GetTime() }
        return false
    end
    if GetTime() - m.tu > KIEN_NHAN_NHU_CAU then
        a.nghi[n.ten] = GetTime() + NGHI_BAO_LAU
        a.moc_tien[n.ten] = nil
        nen.doi(inst, tostring(a.ten), "nghỉ nhu cầu", n.ten,
                "— còn thiếu", con, "mà mãi không nhích")
        return true
    end
    return false
end

-- ── giải một nhu cầu ────────────────────────────────────────────────────

local function MacVao(inst, mon, n)
    -- Một số nhu cầu chỉ cần CÓ, chưa cần mặc lên (ví dụ đuốc lúc hoàng hôn,
    -- hay vũ khí lúc đang đi chặt cây — cầm giáo thì mất tay cầm rìu).
    if n.mac_khi ~= nil and not n.mac_khi(inst) then return false end
    local tui = inst.components.inventory
    if tui == nil then return false end
    tui:Equip(mon)
    -- ⚠ nen.doi chứ không nen.chitiet: hàm này chạy trong vòng quyết định nên
    --   in ra vài lần MỖI GIÂY cho mỗi dân làng. Đã đo giữa đêm: "dùng torch
    --   cho ánh sáng" lặp liên tục và che mất mọi tín hiệu khác trong nhật ký.
    nen.doi(inst, tostring(inst.ailang.ten), "dùng", mon.prefab, "cho", n.ten)
    return true
end

-- Trả "xong" nếu vừa làm một việc tức thì, BufferedAction nếu cần đi làm,
-- nil nếu bó tay với nhu cầu này.
local function GiaiMot(inst, n, tam)
    local b = inst.components.builder

    -- 1. Đã có sẵn món nào ở bậc nào chưa
    for _, bac in ipairs(n.bac or {}) do
        local co = nhu_cau.CoTrongTui(inst, bac.mon)
        if co ~= nil and not bac.dat_xuong then
            if MacVao(inst, co, n) then return "xong" end
            return nil     -- có rồi nhưng chưa tới lúc mặc: coi như ổn
        end
    end

    -- 2. Chế được bậc nào cao nhất
    for _, bac in ipairs(n.bac or {}) do
        if b ~= nil and b:CanBuild(bac.mon) then
            local ok = nen.thu("chế " .. bac.mon, function()
                if bac.dat_xuong then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    -- ⚠ ĐỐNG LỬA CỦA LÀNG phải đặt Ở LÀNG, không đặt dưới chân.
                    --   Đo trên server: dân làng dựng lửa tại chỗ nó đang đứng,
                    --   cách nhà hơn 40, nên `nha.du` đếm quanh nhà không thấy
                    --   gì — và chúng dựng lại, dựng mãi, đốt sạch gỗ vừa chặt
                    --   mà làng vẫn tối. Nhật ký cho thấy lua=1 mà cả ba vẫn
                    --   báo dang_lam="nhà".
                    --   Lửa khẩn cấp của nhu cầu ÁNH SÁNG thì ngược lại: phải
                    --   nhóm ngay dưới chân, nên chỉ bậc nào ghi `o_nha` mới
                    --   dời về làng.
                    local nha = bac.o_nha and inst.ailang ~= nil
                                and inst.ailang.nha or nil
                    if nha ~= nil then x, z = nha[1] + 4, nha[2] + 4 end
                    b:DoBuild(bac.mon, Vector3(x + 2, y, z))
                else
                    b:DoBuild(bac.mon)
                end
            end)
            if ok then
                nen.log(tostring(inst.ailang.ten), "chế", bac.mon, "cho", n.ten)
                if not bac.dat_xuong then
                    local moi = nhu_cau.CoTrongTui(inst, bac.mon)
                    -- ⚠ builder:DoBuild TỰ TRANG BỊ món vừa chế khi tay trống.
                    --   Chưa tới lúc mặc thì phải cởi ra cất đi.
                    local tay = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if tay ~= nil and tay.prefab == bac.mon then
                        if n.mac_khi ~= nil and not n.mac_khi(inst) then
                            local go = inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
                            if go ~= nil then inst.components.inventory:GiveItem(go) end
                        end
                    elseif moi ~= nil then
                        MacVao(inst, moi, n)
                    end
                end
                return "xong"
            end
        end
    end

    -- 2b. CÔNG TRÌNH LỚN TỰ MÌNH KHÔNG DỰNG NỔI: đặt BẢN VẼ cho cả làng góp.
    --
    -- ⚠ Đây là chỗ gỡ giới hạn nặng nhất của mô hình "mỗi người tự lo".
    --   `builder:DoBuild` đòi MỘT người cầm đủ cả bộ, nên Máy Khoa Học (vàng 1
    --   + gỗ 4 + đá 4) không bao giờ lên khi ba dân làng mỗi đứa ôm một phần.
    --   Đo được: vàng 3, đá 6 nằm rải trong túi nhiều người, máy vẫn không lên.
    --
    -- ⚠ Chỉ công trình ĐÁNG chờ mới dùng bản vẽ (xem ban_ve.DUNG_BAN_VE). Đống
    --   lửa khẩn cấp thì không: cần nó là cần NGAY, chờ người khác mang gỗ tới
    --   là chết đêm.
    for _, bac in ipairs(n.bac or {}) do
        if bac.dat_xuong and ban_ve.Dung(bac.mon) then
            local bv = ban_ve.Dat(inst, bac.mon)
            if bv ~= nil then
                -- Có bản vẽ rồi thì việc mang liệu là của tầng việc, không
                -- phải của nhu cầu. Nhu cầu này coi như đã có đường đi.
                return nil
            end
        end
    end

    -- 3. Không bậc nào làm ngay được: đi kiếm nguyên liệu cho bậc RẺ NHẤT
    --    (bậc cuối trong danh sách), vì đó là thứ khả thi sớm nhất.
    local re_nhat = n.bac ~= nil and n.bac[#n.bac] or nil
    if re_nhat ~= nil then
        local thieu = sinh_ton.ConThieu(inst, re_nhat.mon)
        for _, t in ipairs(thieu or {}) do
            local hd = sinh_ton.DiKiem(inst, t[1], nil, tam)
            if hd ~= nil then
                nen.doi(inst, tostring(inst.ailang.ten), "đi kiếm", t[1],
                        "(thiếu " .. t[2] .. ") cho", re_nhat.mon)
                return hd
            end
        end
    end

    -- 4. Nhu cầu có danh sách "kiếm" riêng (đồ ăn, hoa...) thì đi kiếm
    for _, ng in ipairs(n.kiem or {}) do
        local hd = sinh_ton.DiKiem(inst, ng, nil, tam)
        if hd ~= nil then
            nen.doi(inst, tostring(inst.ailang.ten), "đi kiếm", ng, "cho", n.ten)
            return hd
        end
    end

    return nil
end

-- Nhu cầu này đã đủ nguyên liệu để chế chưa (bậc nào cũng được)?
function sinh_ton.ChePDuocRoi(inst, n)
    local b = inst.components.builder
    if b == nil or n == nil then return false end
    for _, bac in ipairs(n.bac or {}) do
        local ok, duoc = pcall(b.CanBuild, b, bac.mon)
        if ok and duoc then return true end
    end
    return false
end

-- ── điểm vào ────────────────────────────────────────────────────────────

-- Mọi nhu cầu đang cần mà chưa thoả, ưu tiên cao nhất trước.
-- `loc` (tuỳ chọn): chỉ xét những nhu cầu mà loc(n) trả true.
function sinh_ton.ConThieuGi(inst, loc)
    local ra = {}
    for _, n in ipairs(nhu_cau.DANH_SACH) do
        if loc == nil or loc(n) then
            local ok_can, can = pcall(n.can, inst)
            local ok_du, du   = pcall(n.du, inst)
            if ok_can and can and ok_du and not du then
                table.insert(ra, n)
            end
        end
    end
    return ra
end

-- Có nhu cầu GẤP nào chưa thoả không (ánh sáng / đồ ăn / hồi máu).
-- Không gây tác dụng phụ — dùng để quyết định có chen ngang việc đang làm.
function sinh_ton.CoNhuCauGap(inst)
    for _, n in ipairs(sinh_ton.ConThieuGi(inst)) do
        if n.gap then return n end
    end
    return nil
end

function sinh_ton.NhuCauCapThiet(inst)
    return sinh_ton.ConThieuGi(inst)[1]
end

-- ⚠ PHẢI đi hết danh sách, không được dừng ở nhu cầu đầu tiên.
--   Bản đầu chỉ thử ĐÚNG nhu cầu ưu tiên cao nhất rồi trả nil nếu bó tay — nên
--   một nhu cầu KHÔNG GIẢI ĐƯỢC chặn đứng mọi nhu cầu bên dưới, mãi mãi. Đo
--   trên server thật: dân làng não 0%, hoi_nao không giải nổi vì quanh đó
--   không có hoa, và thế là vu_khi / giap / nha KHÔNG BAO GIỜ được xét tới.
-- ⚠ `loc` chia bảng nhu cầu thành HAI LƯỢT, và hai lượt đó KHÔNG ĐƯỢC GIẪM
--   LÊN NHAU: Giai có tác dụng phụ (mặc đồ, chế đồ, trừ nguyên liệu), gọi lại
--   cùng một nhu cầu là chế lặp. viec.NhanViec gọi đúng hai lần với hai bộ lọc
--   bù nhau (gap / không gap), nên mỗi nhu cầu được xét đúng một lần.
function sinh_ton.Giai(inst, loc)
    local ds = sinh_ton.ConThieuGi(inst, loc)
    if #ds == 0 then
        if inst.ailang ~= nil then inst.ailang.dang_lo = nil end
        return nil
    end

    -- ⚠ ƯU TIÊN Ở VÒNG NGOÀI, BÁN KÍNH Ở VÒNG TRONG. Bản trước làm ngược —
    --   quét hết mọi nhu cầu ở bán kính gần rồi mới nới rộng — và cách đó
    --   LẶNG LẼ ĐẢO NGƯỢC THỨ TỰ ƯU TIÊN: một nhu cầu quan trọng mà ở xa thua
    --   một nhu cầu vặt ở gần.
    --
    --   Đo trên server giữa mùa hè: `DiKiem("cutgrass")` trả nil ở bán kính 30
    --   nhưng trả PICK ở 130 (quanh làng chỉ có 1 bụi cỏ trong vòng 30, mà có
    --   39 bụi trong vòng 130). "Mát" xếp hạng 4 cần đi xa, "nhà" xếp hạng 6
    --   xong ngay tại chỗ — thế là dân làng đi dựng lửa trại trong khi đang
    --   mất máu vì nóng, và không bao giờ chế nổi cái mũ.
    --
    -- ⚠ ĐỪNG viết ipairs({ nil, TAM_KIEM_GAP }). Một `nil` ở đầu bảng làm độ
    --   dài bằng 0 nên ipairs lặp KHÔNG LẦN NÀO, và Giai() luôn trả nil —
    --   dân làng thôi làm mọi việc. Bộ tự kiểm bắt được ngay: ba phép kiểm
    --   đuốc đang ĐẠT chuyển sang HỎNG cùng lúc.
    --
    -- Ghi lại những nhu cầu BÓ TAY để viec.CanChenNgang đừng lấy chúng ra cướp
    -- lượt mỗi nhịp: một nhu cầu không giải được mà vẫn được quyền chen ngang
    -- thì dân làng bỏ việc liên tục và chẳng làm xong gì.
    -- ⚠ ĐỪNG dùng `goto` ở đây. Nó là cú pháp Lua 5.2+; LuaJIT nuốt được nên
    --   `luajit -bl` báo sạch, nhưng đó chính là kiểu lỗi làm MOD KHÔNG NẠP
    --   ĐƯỢC và cả world không khởi động. Viết bằng vòng lặp thường cho chắc.
    -- ⚠ CHỈ ĐO TIẾN TRIỂN CỦA NHU CẦU ĐANG ĐƯỢC CẦM LƯỢT. Bản đầu đo TẤT CẢ
    --   nhu cầu mỗi lần quét, nên một nhu cầu hoàn toàn giải được vẫn bị phạt
    --   chỉ vì nhu cầu xếp trên nó giành lượt suốt. Đo trên server: "nhà" đứng
    --   im 208 giây và bị cho nghỉ, trong khi `DiKiem("log")` trả PICKUP ngay
    --   ở bán kính 30 — nó chưa bao giờ được thử, chứ không phải làm không nổi.
    --   Hậu quả: cả hai nhu cầu gấp cùng nghỉ và làng không có lửa trại.
    local bo_tay = {}
    for _, n in ipairs(ds) do
        -- Nhu cầu đang nghỉ thì coi như bó tay, nhường lượt cho nhu cầu dưới.
        local nghi = DangNghi(inst, n)
        local kq_n = nil
        if not nghi then
            for _, tam in ipairs({ TAM_KIEM, TAM_KIEM_GAP }) do
                if kq_n == nil then
                    local ok, kq = pcall(GiaiMot, inst, n, tam)
                    if not ok then
                        nen.loi("giải nhu cầu " .. n.ten .. ":", kq)
                    elseif kq ~= nil then
                        kq_n = kq
                    end
                end
            end
        end
        if kq_n ~= nil then
            -- Nhu cầu này vừa giành được lượt: giờ mới đo xem nó có nhích
            -- được không. Đứng im quá lâu thì cho nghỉ và nhường xuống dưới.
            if SoatTienTrien(inst, n) then
                bo_tay[n.ten] = true
            else
                if inst.ailang ~= nil then
                    inst.ailang.dang_lo = n.ten
                    inst.ailang.bo_tay = bo_tay
                end
                return kq_n
            end
        else
            bo_tay[n.ten] = true
        end
    end

    if inst.ailang ~= nil then
        inst.ailang.dang_lo = ds[1].ten .. " (chưa có cách)"
        inst.ailang.bo_tay = bo_tay
    end
    return nil
end

return sinh_ton

-- Một việc, một chủ sở hữu — gom mọi loại lao động về một chỗ.
--
-- ⚠ Vì sao phải viết lại: cây hành vi cũ có NĂM nhánh làm việc riêng (mục
--   tiêu / nhặt / hái / chặt / đào), và `PriorityNode` QUYẾT LẠI TỪ ĐẦU mỗi
--   nhịp. Hệ quả là các nhánh giẫm chân nhau, người chơi thấy ngay:
--     · nhánh chặt cầm rìu lên -> nhánh ánh sáng thấy mất sáng -> cầm đuốc
--       lại -> lặp vô tận
--     · chặt vài nhát rồi bỏ sang cây khác vì nhánh khác giành lượt
--
--   Cách chữa mượn từ GrimWorld (Workshop 3748676443): bộ chạy việc GIỮ LẤY
--   một việc xuyên nhiều nhịp — nhận việc, đi tới, làm, xong hoặc bỏ — thay vì
--   bầu lại mỗi nhịp. Ở đây làm gọn hơn: vẫn dùng `DoAction` của DST nhưng
--   hàm sinh hành động NHỚ việc đang làm và trả lại đúng việc đó cho tới khi
--   xong. Ý tưởng là của họ, mã là của mình.
--
-- Một "việc" gồm:
--     muc_tieu   thực thể đích (hoặc nil nếu là món trong túi)
--     hanh_dong  ACTIONS.*
--     mon        vật phẩm dùng tới (ăn, xây...)
--     vi_sao     nhãn để hiện trong c_ailang_soi

local nen      = require("ailang/nen")
local nhu_cau  = require("ailang/nhu_cau")
local sinh_ton = require("ailang/sinh_ton")
local lang     = require("ailang/lang")

local viec = {}

local TAM_NHIN    = 20
local KIEN_NHAN   = 45    -- giây, đeo một việc tối đa bấy nhiêu
local BO_QUA_GIAY = 120   -- giây, ghi sổ đen mục tiêu cứng đầu
local KHONG_LAY   = { "INLIMBO", "NOCLICK", "FX", "fire", "burnt", "catchable" }

-- ── sổ đen và kiên nhẫn ─────────────────────────────────────────────────

local function So(inst)
    local a = inst.ailang
    if a.bo_qua == nil then a.bo_qua = {} end
    return a
end

function viec.DangBoQua(inst, e)
    local a = So(inst)
    local het = a.bo_qua[e.GUID]
    if het == nil then return false end
    if GetTime() > het then a.bo_qua[e.GUID] = nil return false end
    return true
end

-- Dấu hiệu "đang bào mòn được mục tiêu". Đếm ngược kiên nhẫn đặt lại mỗi khi
-- dấu hiệu này đổi, nên việc dài bao lâu cũng làm xong.
local function DauTienTrien(e)
    if e == nil or not e:IsValid() then return nil end
    local w = e.components.workable
    if w ~= nil then return w.workleft end
    local pk = e.components.pickable
    if pk ~= nil then return pk:CanBePicked() and 1 or 0 end
    return nil
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

-- ── tìm việc mặc định (khi không còn nhu cầu nào) ───────────────────────

-- ⚠ Mục tiêu phải NẰM TRONG VÙNG LÀNG. Không chặn thì dân làng trôi vô hạn:
--   hái xong ở chỗ mới lại tìm tiếp quanh chỗ mới, mỗi vòng xa thêm một đoạn.
--   Đo trên server: bán kính làng 60 mà dân làng ra tới 158 đơn vị. Lần trước
--   đã chặn trong sinh_ton.DiKiem nhưng QUÊN chỗ này, nên việc thường (nhặt /
--   hái / chặt) vẫn kéo chúng đi.
--   Chưa có Đài thì chưa có làng, lúc đó thả tự do — đó là đời du mục.
local function Tim(inst, musttag, loc_them)
    return FindEntity(inst, TAM_NHIN, function(v)
        if viec.DangBoQua(inst, v) then return false end
        if lang.Tam(inst) ~= nil and not lang.ThucTheTrongLang(inst, v) then
            return false
        end
        return loc_them == nil or loc_them(v)
    end, { musttag }, KHONG_LAY)
end

-- ⚠ ĐỪNG nhặt đồ quý của người chơi. Đã gặp thật: một dân làng ôm cả
--   chester_eyebone, playing_card, scandata trong túi. Tag "irreplaceable"
--   đánh dấu đúng nhóm đồ không làm lại được (mắt Chester, lều Glommer...),
--   còn lại liệt kê tay vài món hay rơi quanh base.
local KHONG_NHAT = {
    playing_card = true, scandata = true, chester_eyebone = true,
    glommerflower = true, glommerwings = true, glommerfuel = true,
    townportaltalisman = true, resurrectionstatue = true,
}

local function ViecNhat(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local mon = Tim(inst, "_inventoryitem", function(v)
        if v:HasTag("irreplaceable") or KHONG_NHAT[v.prefab] then return false end
        return v.components.inventoryitem ~= nil
           and v.components.inventoryitem.canbepickedup
           and v:IsOnValidGround()
           and not v:IsInLimbo()
    end)
    if mon == nil then return nil end
    return { muc_tieu = mon, hanh_dong = ACTIONS.PICKUP, vi_sao = "nhặt đồ" }
end

-- ⚠ ĐỪNG gom vô hạn một thứ. Đo trên server: một dân làng ôm 20 bó cỏ mà
--   vẫn đi hái cỏ tiếp, trong khi thứ nó THIẾU là cành cây. Gom quá mức vừa
--   phí công vừa làm đầy túi.
local DU_ROI = 20

local function DaDuChua(inst, san_pham)
    if san_pham == nil then return false end
    local n = 0
    nhu_cau.DuyetTui(inst, function(m)
        if m.prefab == san_pham then
            n = n + (m.components.stackable ~= nil
                     and m.components.stackable:StackSize() or 1)
        end
        return false
    end)
    return n >= DU_ROI
end

local function ViecHai(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local cay = Tim(inst, "pickable", function(v)
        if DaDuChua(inst, v.components.pickable ~= nil
                    and v.components.pickable.product or nil) then
            return false
        end
        return v.components.pickable ~= nil
           and v.components.pickable:CanBePicked()
           and v.components.pickable.caninteractwith ~= false
    end)
    if cay == nil then return nil end
    return { muc_tieu = cay, hanh_dong = ACTIONS.PICK, vi_sao = "hái lượm" }
end

local function ViecLamViec(inst, hanh_dong, tag, nhan)
    if nhu_cau.KhongRanhTay(inst) then return nil end
    if not CamDungCu(inst, hanh_dong) then return nil end
    local muc = Tim(inst, tag, function(v)
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == hanh_dong
    end)
    if muc == nil then return nil end
    return { muc_tieu = muc, hanh_dong = hanh_dong, vi_sao = nhan }
end

-- Dập lửa trong làng. Việc GẤP NHẤT trong các việc lao động — cháy lan là
-- mất cả làng.
local function ViecDapLua(inst)
    local chay = lang.ChayTrongLang(inst)
    if chay == nil then return nil end
    return { muc_tieu = chay, hanh_dong = ACTIONS.EXTINGUISH, vi_sao = "dập lửa" }
end

-- ── tiếp lửa cho đống lửa của làng ──────────────────────────────────────
--
-- ⚠ Lửa trại KHÔNG cháy mãi. Dựng xong là xong chuyện một đêm, nhưng hết
--   nhiên liệu thì nó tắt và làng lại tối — mà lúc đó thường là giữa đêm, đúng
--   lúc dân làng bị cấm cầm rìu nên không đi chặt gỗ mới được. Phải nuôi lửa
--   TỪ LÚC CÒN SÁNG, y như người chơi thật ném gỗ vào bếp trước khi đi ngủ.
--
--   Nhu cầu "nhà" chỉ lo có/không có đống lửa; giữ cho nó cháy là việc thường,
--   nên nhu cầu gấp vẫn chen ngang được (lo thân trước, nuôi lửa sau).
local NGUONG_TIEP  = 0.5   -- dưới nửa bình thì thêm củi
local GIU_LAM_DUOC = 4     -- chừa lại bấy nhiêu cỏ/cành để còn làm đuốc

-- ⚠ ĐỪNG ném đuốc vào lửa. Đuốc có `fueled` (nhận nhiên liệu) chứ không có
--   `fuel` (làm nhiên liệu), nên lọc theo `fuel` là đã loại đúng. Vẫn chặn
--   thêm đồ trang bị và dụng cụ cho chắc — mất rìu là mất đường kiếm gỗ.
local function LaCui(m)
    return m.components.fuel ~= nil
       and m.components.fuel.fueltype == FUELTYPE.BURNABLE
       and m.components.equippable == nil
       and m.components.tool == nil
end

local function ViecTiepLua(inst)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    local lo = FindEntity(inst, lang.BanKinh(inst), function(v)
        return v.components.fueled ~= nil
           and v.components.fueled.accepting
           and v.components.fueled:GetPercent() < NGUONG_TIEP
           and v.components.burnable ~= nil
           and v.components.burnable:IsBurning()
           and lang.ThucTheTrongLang(inst, v)
    end, { "campfire" }, { "INLIMBO", "burnt" })
    if lo == nil then return nil end

    -- Gỗ trước: cháy lâu nhất và không dùng vào việc gì khác cấp bách.
    local cui = nhu_cau.DuyetTui(inst, function(m)
        return m.prefab == "log" and LaCui(m)
    end)
    -- Hết gỗ thì mới động tới cỏ/cành, và phải còn dư mới được đốt.
    if cui == nil then
        cui = nhu_cau.DuyetTui(inst, function(m)
            if not LaCui(m) then return false end
            local n = m.components.stackable ~= nil
                      and m.components.stackable:StackSize() or 1
            return n > GIU_LAM_DUOC
        end)
    end
    if cui == nil then return nil end

    return { muc_tieu = lo, hanh_dong = ACTIONS.ADDFUEL, mon = cui,
             vi_sao = "tiếp lửa" }
end

-- ⚠ PHẢI CÓ CỦI DỰ TRỮ, không chỉ đủ dùng. Lửa trại mới dựng chỉ cháy được
--   (đêm + chập tối) × 0,75 — KHÔNG đủ một đêm. Mà dân làng chỉ chặt đúng 2
--   khúc gỗ mỗi lần nhu cầu "nhà" đòi, không bao giờ có dư, nên tới lúc lửa
--   cần thêm củi thì trong túi trống trơn. Đo trên server: chập tối lua=0 hai
--   đêm liền, dù cả ba đều cầm rìu và quanh làng đầy cây.
--
--   Xếp CHUNG với dập lửa và nuôi lửa, tức trên "vũ khí"/"giáp": củi giữ mạng
--   cả làng qua đêm, còn áo cỏ thì chỉ đỡ đau.
local DU_CUI = 4

local function ViecGomCui(inst)
    if lang.Tam(inst) == nil then return nil end
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end

    local n = 0
    nhu_cau.DuyetTui(inst, function(m)
        if m.prefab == "log" then
            n = n + (m.components.stackable ~= nil
                     and m.components.stackable:StackSize() or 1)
        end
        return false
    end)
    if n >= DU_CUI then return nil end

    if nhu_cau.KhongRanhTay(inst) then return nil end
    if not CamDungCu(inst, ACTIONS.CHOP) then return nil end
    local cay = Tim(inst, "CHOP_workable", function(v)
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == ACTIONS.CHOP
    end)
    if cay == nil then return nil end
    return { muc_tieu = cay, hanh_dong = ACTIONS.CHOP, vi_sao = "gom củi" }
end

-- Túi đầy thì mang đồ về rương trong làng, khỏi đứng ngây.
local function ViecCatDo(inst)
    local tui = inst.components.inventory
    if tui == nil or not tui:IsFull() then return nil end
    local mon = nhu_cau.DuyetTui(inst, function(m)
        return m.components.equippable == nil and m.components.tool == nil
    end)
    if mon == nil then return nil end
    local ruong = lang.RuongTrongLang(inst, mon)
    if ruong == nil then return nil end
    return { muc_tieu = ruong, hanh_dong = ACTIONS.STORE, mon = mon,
             vi_sao = "cất đồ" }
end

-- ── nhận việc ───────────────────────────────────────────────────────────

-- Nhu cầu trước, việc thường sau. sinh_ton trả về "xong" khi nó vừa làm một
-- việc tức thì (mặc/chế), lúc đó chưa cần đi đâu cả.
-- ⚠ GIỮ LÀNG phải chen GIỮA hai lượt nhu cầu, không xếp sau tất cả.
--   "vũ khí" và "giáp" có `can` luôn trả true, nên hễ quanh đó còn một bụi cỏ
--   là sinh_ton.Giai LUÔN trả về việc — và NhanViec không bao giờ xuống tới
--   dập lửa hay tiếp lửa. Đo trên server: lửa của làng tụt còn 17% nhiên liệu
--   trong khi cả ba dân làng đứng hái cỏ làm áo giáp. Lửa tắt là chết đêm,
--   còn thiếu áo giáp thì chỉ đau hơn.
--
--   Thứ tự đúng:
--     1. nhu cầu GẤP (ánh sáng, đồ ăn, hồi máu, nhà)
--     2. giữ làng   (dập cháy, nuôi lửa, gom củi dự trữ)
--     3. nhu cầu còn lại (dụng cụ, hồi não, vũ khí, giáp, cuốc)
--     4. việc thường (cất đồ, nhặt, hái, chặt, đào)
local function TuNhuCau(inst, kq)
    if kq == nil or kq == "xong" or kq.action == nil then return nil end
    return {
        muc_tieu  = kq.target,
        hanh_dong = kq.action,
        mon       = kq.invobject,
        vi_sao    = inst.ailang.dang_lo or "nhu cầu",
    }
end

local function LaGap(n)    return n.gap == true end
local function KhongGap(n) return n.gap ~= true end

function viec.NhanViec(inst)
    local kq = sinh_ton.Giai(inst, LaGap)
    if kq == "xong" then return nil end
    local v = TuNhuCau(inst, kq)
    if v ~= nil then return v end

    v = ViecDapLua(inst) or ViecTiepLua(inst) or ViecGomCui(inst)
    if v ~= nil then return v end

    kq = sinh_ton.Giai(inst, KhongGap)
    if kq == "xong" then return nil end
    v = TuNhuCau(inst, kq)
    if v ~= nil then return v end

    return ViecCatDo(inst)
        or ViecNhat(inst)
        or ViecHai(inst)
        or ViecLamViec(inst, ACTIONS.CHOP, "CHOP_workable", "chặt cây")
        or ViecLamViec(inst, ACTIONS.MINE, "MINE_workable", "đào đá")
end

-- ── có nên bỏ việc đang làm không ───────────────────────────────────────
--
-- ⚠ KHÔNG GÂY TÁC DỤNG PHỤ. Cây hành vi cần một phép thử để quyết có chen
--   ngang việc đang chạy dở hay không, và nó chạy mỗi 0,5 giây. Bản trước
--   dùng thẳng `sinh_ton.Giai(inst) == "xong"` làm phép thử đó — mà Giai MẶC
--   ĐỒ, CHẾ ĐỒ, TRỪ NGUYÊN LIỆU. Cộng với lần gọi bên trong viec.HanhDong là
--   Giai chạy HAI LẦN mỗi nhịp, mỗi lần đều có thể chế thêm một món. Nhật ký
--   in "đi kiếm log" bốn lần mỗi giây cho mỗi dân làng chính là dấu vết đó.
function viec.CanChenNgang(inst)
    local a = So(inst)
    if a.viec == nil then return false end
    local gap = sinh_ton.CoNhuCauGap(inst)
    if gap == nil then return false end
    local hang_gap  = nhu_cau.ChiSo(gap.ten)
    local hang_viec = nhu_cau.ChiSo(a.viec.vi_sao)
    return hang_viec == nil or (hang_gap ~= nil and hang_gap < hang_viec)
end

-- ── việc đang làm còn dùng được không ───────────────────────────────────

function viec.ConHopLe(inst, v)
    if v == nil then return false end
    local a = So(inst)

    -- Món trong túi (ăn, xây): còn trong túi là còn làm được.
    if v.muc_tieu == nil then
        return v.mon ~= nil and v.mon:IsValid()
    end

    if not v.muc_tieu:IsValid() or v.muc_tieu:IsInLimbo() then return false end
    if viec.DangBoQua(inst, v.muc_tieu) then return false end

    local w = v.muc_tieu.components.workable
    if w ~= nil and not w:CanBeWorked() then return false end
    local pk = v.muc_tieu.components.pickable
    if pk ~= nil and (not pk:CanBePicked() or pk.caninteractwith == false) then
        return false
    end

    -- Còn bào mòn được thì kiên nhẫn lại từ đầu.
    local moc = DauTienTrien(v.muc_tieu)
    if moc ~= nil and moc ~= a.viec_moc then
        a.viec_moc = moc
        a.viec_tu = GetTime()
        return true
    end

    if GetTime() - (a.viec_tu or 0) > KIEN_NHAN then
        a.bo_qua[v.muc_tieu.GUID] = GetTime() + BO_QUA_GIAY
        nen.chitiet(tostring(a.ten), "bỏ việc cứng đầu:", tostring(v.vi_sao),
                    tostring(v.muc_tieu.prefab))
        return false
    end
    return true
end

-- ── điểm vào cho cây hành vi ────────────────────────────────────────────
--
-- Trả về BufferedAction cho DoAction chạy, hoặc nil nếu không có việc gì.
-- GIỮ LẤY việc đang làm cho tới khi xong — đây là điểm khác cốt lõi so với
-- bản cũ, và là thứ chấm dứt cảnh các nhánh giành nhau.
function viec.HanhDong(inst)
    local a = So(inst)

    -- ⚠ Nhu cầu GẤP chen ngang việc đang làm dở — KỂ CẢ khi việc đó cũng là
    --   một nhu cầu. Bản đầu chỉ chen khi việc hiện tại KHÔNG phải nhu cầu,
    --   nên dân làng ôm việc "vũ khí" (cũng là nhu cầu) là ánh sáng không bao
    --   giờ giành được lượt: đêm xuống, đuốc nằm sẵn trong túi, mà nó vẫn đi
    --   kiếm đồ làm giáo cho tới sáng.
    --   So theo NHÃN việc: đang làm đúng việc gấp đó thì để yên, khác thì bỏ.
    -- ⚠ So bằng THỨ HẠNG, không bằng TÊN. Bản trước bỏ việc hễ nhãn việc khác
    --   nhãn nhu cầu gấp, mà `sinh_ton.Giai` duyệt HẾT bảng nhu cầu: nhu cầu
    --   gấp giải không nổi ở bán kính gần thì nó trả về việc của một nhu cầu
    --   THẤP HƠN. Thế là mỗi nhịp 0,5 giây lại thấy "nhãn lệch" và vứt việc —
    --   dân làng đứng nhận đi nhận lại cùng một việc, không bao giờ chặt xong
    --   một cây nào. Đo được: dang_lo="hồi máu" trong khi nhu cầu gấp là
    --   "ánh sáng".
    --   Luật đúng: chỉ bỏ việc khi nhu cầu vừa nổi lên NẶNG HƠN thứ đang làm.
    local gap = sinh_ton.CoNhuCauGap(inst)
    if a.viec ~= nil and gap ~= nil then
        local hang_gap  = nhu_cau.ChiSo(gap.ten)
        local hang_viec = nhu_cau.ChiSo(a.viec.vi_sao)   -- nil = việc thường
        if hang_viec == nil or (hang_gap ~= nil and hang_gap < hang_viec) then
            a.viec = nil
        end
    end

    if a.viec ~= nil and viec.ConHopLe(inst, a.viec) then
        local v = a.viec
        inst.ailang.dang_lam = v.vi_sao
        return BufferedAction(inst, v.muc_tieu, v.hanh_dong, v.mon)
    end

    local v = nil
    local ok, err = pcall(function() v = viec.NhanViec(inst) end)
    if not ok then nen.loi("nhận việc:", err) end

    a.viec = v
    a.viec_tu = GetTime()
    a.viec_moc = v ~= nil and DauTienTrien(v.muc_tieu) or nil
    inst.ailang.dang_lam = v ~= nil and v.vi_sao or nil

    if v == nil then return nil end
    return BufferedAction(inst, v.muc_tieu, v.hanh_dong, v.mon)
end

function viec.BoViec(inst)
    local a = So(inst)
    a.viec = nil
    inst.ailang.dang_lam = nil
end

return viec

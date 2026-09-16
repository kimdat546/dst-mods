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
local kho_lang = require("ailang/kho_lang")
local ban_ve   = require("ailang/ban_ve")
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
-- ⚠ `musttag` phải là TAG THẬT, không phải tên prefab. Đã dính: hang thỏ là
--   prefab "rabbithole" nhưng KHÔNG mang tag nào tên như vậy (nó chỉ có
--   "cattoy"), nên `Tim(inst, "rabbithole", ...)` tìm mãi không ra và việc đặt
--   bẫy chết câm — không lỗi, không log, chỉ là không bao giờ chạy.
--   Muốn tìm theo prefab thì để musttag = nil rồi lọc trong `loc_them`.
local function Tim(inst, musttag, loc_them)
    return FindEntity(inst, TAM_NHIN, function(v)
        if viec.DangBoQua(inst, v) then return false end
        if lang.Tam(inst) ~= nil and not lang.ThucTheTrongLang(inst, v) then
            return false
        end
        if not lang.LamDuocLucNay(inst, v) then return false end
        return loc_them == nil or loc_them(v)
    end, musttag ~= nil and { musttag } or nil, KHONG_LAY)
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
-- Còn giữ trần TÚI RIÊNG cho những thứ không có trong bảng trần của làng:
-- một dân làng ôm 20 cái gì đó là quá đủ, khỏi nhặt thêm cho đầy túi.
local DU_ROI = 20

-- ⚠ ĐẾM CẢ LÀNG TRƯỚC, RỒI MỚI TỚI TÚI RIÊNG. Bản đầu chỉ nhìn túi của chính
--   người đang hái, nên ba dân làng mỗi đứa ôm 19 quả berry mà không ai thấy
--   làng đang có 57 quả — và cả ba vẫn hái tiếp. Xem kho_lang.TRAN.
local function DaDuChua(inst, san_pham)
    if san_pham == nil then return false end
    if kho_lang.DaDu(san_pham) then return true end
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
    -- ⚠ Đủ rồi thì thôi. Đây là việc TỰ PHÁT (chặt/đào vu vơ khi rảnh), nên
    --   trần kho của làng áp được. Nhu cầu đi qua sinh_ton.DiKiem, không qua
    --   đây, nên vẫn kiếm được gỗ để dựng Máy Khoa Học dù kho đã đầy gỗ.
    if not kho_lang.ViecConCan(hanh_dong) then return nil end
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
-- ⚠ NGƯỠNG PHẢI ĐỔI THEO GIỜ. Lửa đầy cháy được 360 giây, mà chập tối + đêm
--   là 240 giây — nạp tới nửa bình rồi bỏ đi là nó CHẾT ngay trước bình minh.
--   Đo trên server: cả ba dân làng ôm 2 khúc gỗ mỗi đứa mà lua=0 giữa đêm, và
--   một đứa đứng tay không trong bóng tối.
--   Ban ngày thì nửa bình là đủ (còn cả ngày để nạp thêm); chập tối trở đi thì
--   nạp tới gần đầy, y như người chơi ném hết củi vào bếp trước khi trời sập.
-- ⚠ Khai báo TRƯỚC ViecTiepLua vì hàm đó đọc nó. strict.lua biến
--   biến-chưa-khai-báo thành lỗi cứng làm cả world không khởi động được.
local DU_CUI = 4

-- Dưới mức này là lửa sắp tắt: đốt cả củi dự trữ, không kể giờ giấc.
local NGUY_LUA = 0.35

local NGUONG_NGAY = 0.5
local NGUONG_TOI  = 0.95
local GIU_LAM_DUOC = 4     -- chừa lại bấy nhiêu cỏ/cành để còn làm đuốc

local function NguongTiep()
    return (TheWorld.state.isdusk or TheWorld.state.isnight)
           and NGUONG_TOI or NGUONG_NGAY
end

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
           and v.components.fueled:GetPercent() < NguongTiep()
           and v.components.burnable ~= nil
           and v.components.burnable:IsBurning()
           and lang.ThucTheTrongLang(inst, v)
    end, { "campfire" }, { "INLIMBO", "burnt" })
    if lo == nil then return nil end

    -- Gỗ trước: cháy lâu nhất và không dùng vào việc gì khác cấp bách.
    --
    -- ⚠ NHƯNG BAN NGÀY PHẢI CHỪA DỰ TRỮ, KHÔNG THÌ CẢ LÀNG KHOÁ CỨNG. Bản
    --   trước ném bằng hết gỗ vào lửa, rồi ViecGomCui thấy còn 0 khúc (dưới
    --   DU_CUI) lại đẩy đi chặt, chặt xong lại ném vào lửa — vòng khép kín.
    --   Mà bậc giữ làng nằm TRÊN các nhu cầu không gấp, nên chừng nào "gom củi"
    --   chưa xong thì lượt KHÔNG BAO GIỜ xuống tới "cuốc", "xưởng", "kho".
    --
    --   Đo trên server: ba dân làng, ba tảng đá vàng đặt sẵn trong tầm, cuốc
    --   trong tay — 4 lần soi liên tiếp vẫn vang=0 da=0 gỗ=0, cả ba "gom củi",
    --   đá vàng không sứt một mảnh. Đúng thứ đã chặn việc dựng Máy Khoa Học.
    --
    -- ⚠ Nhưng điều kiện KHÔNG PHẢI là giờ trong ngày — là LỬA NGUY ĐẾN ĐÂU.
    --   Bản sửa đầu khoá theo giờ, và ba bài kiểm cũ hỏng ngay: lửa còn 20%
    --   giữa ban ngày mà dân làng ôm củi đứng nhìn. Giữ dự trữ chỉ có nghĩa
    --   khi lửa còn sống khoẻ; lửa sắp tắt thì ném hết vào, giờ nào cũng vậy.
    --
    --   Nên: đốt cả dự trữ khi (chập tối trở đi) HOẶC (lửa dưới mức nguy).
    --   Còn lại thì chỉ đốt phần dư — và đó là chỗ vòng khoá bị cắt.
    local dot_ca_du_tru = TheWorld.state.isdusk or TheWorld.state.isnight
        or lo.components.fueled:GetPercent() < NGUY_LUA
    local cui = nhu_cau.DuyetTui(inst, function(m)
        if m.prefab ~= "log" or not LaCui(m) then return false end
        if dot_ca_du_tru then return true end
        local n = m.components.stackable ~= nil
                  and m.components.stackable:StackSize() or 1
        return n > DU_CUI
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
--   (DU_CUI khai báo phía trên, vì ViecTiepLua cũng đọc nó.)

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
    -- ⚠ DU_CUI là củi RIÊNG của người này mang theo để nuôi lửa; trần của làng
    --   là chuyện khác và cũng phải xét. Không xét thì kho đầy 200 khúc gỗ mà
    --   cả ba vẫn đi chặt vì túi ai cũng dưới 4.
    if kho_lang.DaDu("log") then return nil end

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

-- Phơi ra để bộ tự kiểm soi thẳng được, khỏi phải đoán qua cả chuỗi NhanViec.
viec.ViecTiepLua = ViecTiepLua

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

-- ── kinh tế đồ ăn ───────────────────────────────────────────────────────
--
-- ⚠ ĐÂY LÀ THỨ ĐÃ GIẾT CẢ LÀNG. Đo trên server chạy nhanh: không có Đài thì
--   chết ngày 2; có Đài thì khoẻ tới ngày 8, từ ngày 9 chết mỗi đêm, tới ngày
--   16 là 95 lượt chết và còn 10% máu. Truy ra thì không phải lỗi hành vi nào
--   cả — là BÀI TOÁN LƯƠNG THỰC KHÔNG CÓ LỜI GIẢI.
--
--   Ba dân làng đốt 225 calo/ngày. Một quả berry cho 9,375; một bụi ra 3 quả
--   rồi CHẾT, mọc lại mất 3 ngày — tức 0,33 quả/ngày/bụi. Muốn nuôi ba người
--   chỉ bằng berry thì cần KHOẢNG 70 BỤI trong bán kính làng. Không bản đồ
--   nào có. Xem docs/dst-knowledge/analysis/dst-kinh-te-sinh-ton.md.
--
--   Lời giải của người chơi thật là ba thứ, và cả ba đều nằm ở đây:
--     1. NẤU CHÍN  — gấp đôi calo, không tốn nguyên liệu nào
--     2. BẪY THỎ   — nguồn thịt TÁI TẠO, tech 0, twigs×2 cutgrass×6, 8 lượt
--     3. CẤT KHO   — để đất hỏng nhanh gấp rưỡi so với để rương

-- Nấu chín trên lửa. Rẻ nhất trong mọi cách tăng đồ ăn: không tốn gì ngoài
-- vài giây, mà thịt nhỏ 12,5 -> 25 calo và đồng hồ hỏng được đặt lại.
-- ⚠ THỊT TRƯỚC, RAU CHỈ KHI GOM ĐƯỢC KHA KHÁ. Nướng miếng thịt nhỏ được
--   +12,5 calo, nướng quả berry chỉ được +3,1 — mà quãng đường đi về đống lửa
--   thì như nhau. Không phân biệt thì dân làng hái ĐƯỢC MỘT quả là cuốc bộ về
--   lửa nướng, rồi quay ra hái quả nữa: cả ngày đi đi về về, việc khác không
--   ai làm. Lửa chỉ nướng được từng món một, nên đây không phải chuyện nhỏ.
local RAU_DU_NUONG = 3

local function ViecNauChin(inst)
    local tui = inst.components.inventory
    if tui == nil then return nil end

    local function song(m)
        return m.components.cookable ~= nil and m.components.edible ~= nil
    end
    local function la_thit(m)
        local ft = m.components.edible.foodtype
        return ft == FOODTYPE.MEAT or m:HasTag("meat")
    end

    local mon = nhu_cau.DuyetTui(inst, function(m)
        return song(m) and la_thit(m)
    end)
    if mon == nil then
        local n = 0
        for _, m in pairs(tui.itemslots or {}) do
            if m ~= nil and song(m) then
                n = n + (m.components.stackable ~= nil
                         and m.components.stackable:StackSize() or 1)
            end
        end
        if n < RAU_DU_NUONG then return nil end
        mon = nhu_cau.DuyetTui(inst, song)
    end
    if mon == nil then return nil end

    -- Chỉ lửa ĐANG CHÁY mới nấu được, và phải là lửa của làng.
    local lua = lang.LuaCuaLang(inst)
    if lua == nil or not lua:HasTag("cooker") then return nil end
    return { muc_tieu = lua, hanh_dong = ACTIONS.COOK, mon = mon,
             vi_sao = "nấu chín" }
end

-- Thu bẫy đã sập. Việc rẻ nhất trong làng: đi tới, bấm một cái, ra thịt.
local function ViecThuBay(inst)
    local bay = Tim(inst, "trap", function(v)
        local t = v.components.trap
        return t ~= nil and t.issprung and t:HasLoot()
    end)
    if bay == nil then return nil end
    return { muc_tieu = bay, hanh_dong = ACTIONS.CHECKTRAP, vi_sao = "thu bẫy" }
end

-- Đặt bẫy lên hang thỏ.
--
-- ⚠ Đặt ĐÚNG TRÊN miệng hang, không đặt cạnh. Thỏ chui ra là dính ngay; đặt
--   lệch thì phải chờ nó đi ngang qua, và phần lớn thời gian là không.
-- ⚠ Và chỉ đặt vào hang CHƯA CÓ BẪY. Không xét thì cả làng chồng bẫy lên một
--   cái hang trong khi mười hang khác bỏ trống.
local function ViecDatBay(inst)
    local bay = nhu_cau.DuyetTui(inst, function(m) return m.prefab == "trap" end)
    if bay == nil then return nil end

    local hang = Tim(inst, nil, function(v)
        if v.prefab ~= "rabbithole" then return false end
        local x, _, z = v.Transform:GetWorldPosition()
        return #TheSim:FindEntities(x, 0, z, 2, { "trap" }, { "INLIMBO" }) == 0
    end)
    if hang == nil then return nil end

    local x, y, z = hang.Transform:GetWorldPosition()
    return { muc_tieu = nil, hanh_dong = ACTIONS.DROP, mon = bay,
             diem = Vector3(x, y, z), vi_sao = "đặt bẫy" }
end

-- Cất ĐỒ ĂN vào rương, kể cả khi túi chưa đầy.
--
-- ⚠ Khác ViecCatDo ở chỗ đó, và khác biệt này quan trọng: đồ ăn để dưới đất
--   hỏng nhanh GẤP RƯỠI so với trong rương (perishable.lua nhân 1,5 khi ở
--   ngoài, 1,0 trong rương, 0,5 trong tủ lạnh). Đợi túi đầy mới cất là đã phí
--   nửa số thịt mang về.
local GIU_DO_AN = 2   -- giữ lại bấy nhiêu suất ăn trong người, dư thì cất

local function ViecCatDoAn(inst)
    local tui = inst.components.inventory
    if tui == nil then return nil end

    -- ⚠ ĐẾM SỐ SUẤT, KHÔNG ĐẾM SỐ Ô. Bản đầu đếm ô đựng, nên một chồng 40 củ
    --   cà rốt chỉ tính là 1 và dân làng KHÔNG BAO GIỜ cất gì — đúng lúc đáng
    --   cất nhất. Bộ tự kiểm bắt được ngay: cho 5 củ, chúng dồn vào một ô, và
    --   việc cất trả nil.
    --
    -- ⚠ Nhưng vẫn đòi ÍT NHẤT HAI Ô. ACTIONS.STORE chuyển NGUYÊN CHỒNG, nên
    --   chỉ có một ô mà đem cất là dân làng còn tay không. Tách chồng thì phải
    --   RemoveItem rồi dựng hành động riêng — hình dạng việc ở đây không chở
    --   nổi, mà cái giá phải trả chỉ là chờ tới khi có món thứ hai.
    local du, tong = {}, 0
    for _, m in pairs(tui.itemslots or {}) do
        if m ~= nil and m.components.edible ~= nil
           and m.components.edible.foodtype ~= FOODTYPE.INEDIBLE then
            table.insert(du, m)
            tong = tong + (m.components.stackable ~= nil
                           and m.components.stackable:StackSize() or 1)
        end
    end
    if #du < 2 or tong <= GIU_DO_AN then return nil end

    -- Cất món SẮP HỎNG trước? Không — ngược lại. Món sắp hỏng thì ăn ngay còn
    -- kịp; món còn tươi mới đáng cất để dành.
    table.sort(du, function(a, b)
        local pa = a.components.perishable and a.components.perishable:GetPercent() or 1
        local pb = b.components.perishable and b.components.perishable:GetPercent() or 1
        return pa > pb
    end)

    local mon = du[1]
    local ruong = lang.RuongTrongLang(inst, mon)
    if ruong == nil then return nil end
    return { muc_tieu = ruong, hanh_dong = ACTIONS.STORE, mon = mon,
             vi_sao = "cất đồ ăn" }
end

-- ── gom liệu làm đuốc, TỪ LÚC CÒN SÁNG ──────────────────────────────────
--
-- ⚠ ĐÂY LÀ THỨ ĐÃ CHẶN CẢ LÀNG KHỎI MỌI TIẾN BỘ. `ánh sáng` là nhu cầu ưu tiên
--   SỐ MỘT, và đuốc thì cháy hết liên tục — nên hễ quanh làng thiếu cỏ hoặc
--   cành là nó chiếm lượt VĨNH VIỄN: dân làng gom cả ngày mà không bao giờ đủ
--   2 cỏ + 2 cành cho một cây đuốc, và không nhu cầu nào phía dưới tới lượt.
--
--   Đo trên server: ba lượt thử Máy Khoa Học liên tiếp đều tắc ở đây, cả ba
--   dân làng báo dang_lam="ánh sáng" suốt 26 lần soi. Soi trực tiếp xác nhận
--   chúng KHÔNG hề kẹt — đi 17,6 đơn vị trong 8 giây, DiKiem trả về PICK grass
--   bình thường. Chỉ là cung không bao giờ đuổi kịp cầu.
--
--   Lời giải là thứ người chơi thật vẫn làm: gom DƯ cỏ và cành từ lúc còn
--   sáng, chứ không đợi tới lúc cần mới đi kiếm. Cùng tinh thần với việc gom
--   củi dự trữ cho đống lửa.
--
-- ⚠ CHỈ GOM BAN NGÀY. Chập tối trở đi thì vùng làm việc đã bị bó quanh đống
--   lửa (lang.LamDuocLucNay) và ra xa là chết — lúc đó có thiếu cũng đành chịu,
--   đó chính là lý do phải gom trước.
local LIEU_DEM = { cutgrass = 6, twigs = 6 }   -- mỗi dân làng chừng này

local function ViecGomLieuDem(inst)
    if TheWorld.state.isdusk or TheWorld.state.isnight then return nil end
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    if nhu_cau.KhongRanhTay(inst) then return nil end

    local bk = kho_lang.KiemDem()
    if bk == nil or bk.so_dan == 0 then return nil end

    for lieu, moi_nguoi in pairs(LIEU_DEM) do
        local can = moi_nguoi * bk.so_dan
        -- ⚠ Đừng vượt trần thu gom: hai cơ chế cùng nhắm một thứ mà không nhìn
        --   nhau thì dân làng gom tới trần rồi bị cái này đẩy đi gom tiếp.
        local tran = kho_lang.TRAN[lieu]
        if tran ~= nil and can > tran then can = tran end

        if (bk.mon[lieu] or 0) < can then
            local hd = sinh_ton.DiKiem(inst, lieu)
            if hd ~= nil then
                return { muc_tieu = hd.target, hanh_dong = hd.action,
                         mon = hd.invobject, vi_sao = "gom liệu cho đêm" }
            end
        end
    end
    return nil
end

viec.ViecGomLieuDem = ViecGomLieuDem

-- ── mang liệu tới bản vẽ ────────────────────────────────────────────────
--
-- ⚠ ĐÂY LÀ VIỆC CỦA CẢ LÀNG, nên nó nằm ở bậc giữ làng chứ không nằm trong
--   nhu cầu của riêng ai. Nhu cầu quyết định dựng gì và đặt bản vẽ xuống; từ
--   đó trở đi thì ai rảnh cũng mang liệu tới được, và đó chính là điều khiến
--   ba người mỗi người 2 khúc gỗ dựng nổi thứ cần 4 khúc.
local function ViecGopBanVe(inst)
    local bv, thieu = ban_ve.DangThieu(inst)
    if bv == nil then return nil end

    -- Có sẵn trong túi thì mang qua luôn.
    local mon = nhu_cau.DuyetTui(inst, function(m) return m.prefab == thieu end)
    if mon ~= nil then
        return { muc_tieu = bv, hanh_dong = ACTIONS.GIVE, mon = mon,
                 vi_sao = "góp bản vẽ" }
    end

    -- Không có thì đi kiếm. Dùng lại đúng đường kiếm liệu của nhu cầu, nên
    -- bảng NGUON và luật "đêm không cầm rìu" vẫn được tôn trọng.
    -- ⚠ KHÔNG đi qua kho_lang.ViecConCan: đây không phải chặt vu vơ, mà là
    --   nguyên liệu cho một công trình đã quyết dựng. Trần thu gom chỉ chặn
    --   việc tự phát.
    local hd = sinh_ton.DiKiem(inst, thieu)
    if hd == nil then return nil end
    return { muc_tieu = hd.target, hanh_dong = hd.action, mon = hd.invobject,
             vi_sao = "góp bản vẽ" }
end

viec.ViecGopBanVe = ViecGopBanVe
viec.ViecNauChin  = ViecNauChin
viec.ViecThuBay   = ViecThuBay
viec.ViecDatBay   = ViecDatBay
viec.ViecCatDoAn  = ViecCatDoAn

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

    -- ⚠ KINH TẾ ĐỒ ĂN NẰM CÙNG BẬC GIỮ LÀNG, tức là TRÊN các nhu cầu không
    --   gấp. Để nó xuống dưới cùng với việc thường thì nó không bao giờ tới
    --   lượt: "vũ khí" và "giáp" có `can` luôn trả true nên hễ quanh đó còn
    --   một bụi cỏ là bộ giải LUÔN trả về việc — đúng cái bệnh đã làm lửa của
    --   làng tụt còn 17% trong khi cả ba đứng hái cỏ làm áo giáp.
    --
    --   Thứ tự trong bậc này theo giá trị trên mỗi giây bỏ ra: thu bẫy (đi tới
    --   bấm một cái, ra thịt) > nấu chín (gấp đôi calo, không tốn gì) > đặt
    --   bẫy (gieo cho ngày mai) > cất kho (chống hỏng).
    v = ViecDapLua(inst) or ViecTiepLua(inst) or ViecGomCui(inst)
         or ViecThuBay(inst) or ViecNauChin(inst) or ViecDatBay(inst)
         or ViecCatDoAn(inst) or ViecGopBanVe(inst)
         or ViecGomLieuDem(inst)
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
    -- ⚠ Nhu cầu BÓ TAY thì đừng cho cướp lượt. Lần giải gần nhất đã thử nó ở
    --   cả hai bán kính và không ra được việc gì — để nó chen ngang thì dân
    --   làng bỏ việc mỗi nhịp và chẳng làm xong gì, mà nhu cầu kia vẫn không
    --   nhúc nhích. Đây là bệnh đã gặp ở nhu cầu ánh sáng, nay chặn tận gốc.
    if a.bo_tay ~= nil and a.bo_tay[gap.ten] then return false end
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

    -- ⚠ GOM ĐỦ RỒI THÌ DỪNG GOM. Việc bám dai là thứ đã chữa cảnh "chặt vài
    --   nhát rồi bỏ sang cây khác", nhưng nó không biết lúc nào nên buông:
    --   đo trên server, Cuong gom được 14 bó cỏ (mũ chống nóng cần 12),
    --   CanBuild=true, mà vẫn ôm việc hái cỏ và đứng im ở đó — bộ giải không
    --   bao giờ chạy lại để tới bước CHẾ. Nó hái cỏ suốt trong khi cái mũ đã
    --   nằm trong tầm tay.
    if a.viec ~= nil then
        for _, n in ipairs(nhu_cau.DANH_SACH) do
            if n.ten == a.viec.vi_sao and sinh_ton.ChePDuocRoi(inst, n) then
                a.viec = nil
                break
            end
        end
    end

    if a.viec ~= nil and viec.ConHopLe(inst, a.viec) then
        local v = a.viec
        inst.ailang.dang_lam = v.vi_sao
        return BufferedAction(inst, v.muc_tieu, v.hanh_dong, v.mon, v.diem)
    end

    local v = nil
    local ok, err = pcall(function() v = viec.NhanViec(inst) end)
    if not ok then nen.loi("nhận việc:", err) end

    a.viec = v
    a.viec_tu = GetTime()
    a.viec_moc = v ~= nil and DauTienTrien(v.muc_tieu) or nil
    inst.ailang.dang_lam = v ~= nil and v.vi_sao or nil

    if v == nil then return nil end
    -- ⚠ `v.diem` là điểm THẢ, cần cho việc đặt bẫy: ACTIONS.DROP nhận vị trí ở
    --   tham số thứ năm. Bỏ nó đi thì bẫy rơi dưới chân dân làng chứ không lên
    --   miệng hang thỏ, và không con nào dính.
    return BufferedAction(inst, v.muc_tieu, v.hanh_dong, v.mon, v.diem)
end

function viec.BoViec(inst)
    local a = So(inst)
    a.viec = nil
    inst.ailang.dang_lam = nil
end

return viec

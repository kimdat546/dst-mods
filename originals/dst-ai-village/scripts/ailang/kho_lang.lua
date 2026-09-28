-- Bản kiểm kê TOÀN LÀNG — để tầng suy nghĩ ra chiến lược, không chỉ ra việc vặt.
--
-- ⚠ VÌ SAO CẦN CÁI NÀY. Mỗi dân làng chỉ thấy túi của MÌNH. Nhìn vậy thì câu
--   "đủ đồ ăn chưa" không bao giờ trả lời được: ba người mỗi người hai quả berry
--   trông như đói, nhưng trong rương có 40 viên thịt viên. Ngược lại, một người
--   ôm hết đồ ăn trông như no trong khi hai người kia sắp chết.
--
-- ⚠ VÀ VÌ SAO KHÔNG CHỈ ĐẾM SỐ MÓN. "có 12 berry" không nói được gì. Thứ quyết
--   định là ĐƯỢC MẤY NGÀY: bụng 150, đốt 75/ngày (xem
--   docs/dst-knowledge/analysis/dst-kinh-te-sinh-ton.md), nên 12 berry = 112
--   calo = chưa nổi MỘT ngày cho một người. Bảng này quy hết về ngày ăn, máu hồi
--   được, và mấy câu kết luận có/không — đó mới là thứ ra quyết định được.

local nen = require("ailang/nen")
local lang = require("ailang/lang")
local dan_lang = require("ailang/dan_lang")

local kho_lang = {}

-- Đốt mỗi ngày mỗi người. wilson_hunger 150, TUNING.WILSON_HUNGER_RATE * 480.
local DOT_MOI_NGAY = 75

-- Ngưỡng để gọi là "đủ" — dùng cho mấy câu kết luận cuối bảng.
kho_lang.DU_NGAY_AN   = 3    -- ngày ăn dự trữ cho cả làng
kho_lang.DU_MAU_HOI   = 60   -- tổng máu hồi được cầm sẵn
kho_lang.SAP_HONG     = 0.25 -- dưới bấy nhiêu phần trăm tươi là sắp hỏng

-- Nguyên liệu đáng theo dõi — những thứ chặn đường công nghệ.
kho_lang.NGUYEN_LIEU = {
    "log", "rocks", "cutgrass", "twigs", "goldnugget", "flint",
    "charcoal", "boards", "cutstone", "rope", "silk", "beefalowool",
}

-- Công trình đáng theo dõi, kèm cấp máy nó mở ra.
kho_lang.CONG_TRINH = {
    firepit = 0, campfire = 0, coldfire = 0,
    researchlab = 1, treasurechest = 1, cookpot = 1, meatrack = 1,
    researchlab2 = 2, icebox = 2,
}

-- ── gom từng món ────────────────────────────────────────────────────────

local function SoLuong(mon)
    if mon == nil or not mon:IsValid() then return 0 end
    if mon.components.stackable ~= nil then return mon.components.stackable:StackSize() end
    return 1
end

-- Cộng một món vào bản kiểm kê.
local function Cong(bk, mon)
    local n = SoLuong(mon)
    if n == 0 then return end

    bk.mon[mon.prefab] = (bk.mon[mon.prefab] or 0) + n

    local an = mon.components.edible
    if an ~= nil and an.foodtype ~= FOODTYPE.INEDIBLE then
        if (an.hungervalue or 0) > 0 then
            bk.calo = bk.calo + an.hungervalue * n
        end
        if (an.healthvalue or 0) > 0 then
            bk.mau_hoi = bk.mau_hoi + an.healthvalue * n
        end
    end

    local hoi = mon.components.healer
    if hoi ~= nil then
        bk.mau_hoi = bk.mau_hoi + (hoi.health or 0) * n
    end

    -- Đồ sắp hỏng: biết sớm thì còn kịp nấu hoặc cất tủ lạnh.
    local hong = mon.components.perishable
    if hong ~= nil and hong:GetPercent() < kho_lang.SAP_HONG then
        bk.sap_hong = bk.sap_hong + n
    end

    -- ⚠ ĐỪNG ĐẾM DỤNG CỤ LÀ VŨ KHÍ. Rìu và cuốc trong DST đều có component
    --   `weapon` (axe.lua, pickaxe.lua — TUNING.AXE_DAMAGE / PICK_DAMAGE), nên
    --   đếm thô là cả làng "đủ vũ khí" ngay từ ngày đầu và `du_suc_danh` bật
    --   lên trong khi chẳng ai có cây giáo nào. Cầm rìu đi đánh là đường cùng,
    --   không phải trang bị. Rìu/cuốc đã được đếm riêng ở dưới.
    if mon.components.weapon ~= nil and mon.components.tool == nil
       and mon.components.projectile == nil then
        bk.vu_khi = bk.vu_khi + n
    end
    if mon.components.armor ~= nil then
        bk.giap = bk.giap + n
    end
    if mon.components.tool ~= nil then
        local hd = mon.components.tool
        if hd:CanDoAction(ACTIONS.CHOP)  then bk.riu   = bk.riu   + n end
        if hd:CanDoAction(ACTIONS.MINE)  then bk.cuoc  = bk.cuoc  + n end
    end
end

local function GomHopChua(bk, c)
    if c == nil then return end
    for _, mon in pairs(c.slots or {}) do Cong(bk, mon) end
end

-- ⚠ ĐỒ RƠI TRÊN ĐẤT TRONG LÀNG CŨNG LÀ KHO. Bản đầu chỉ đếm túi + đồ mặc +
--   túi hàng + rương, và cái lỗ đó làm bản kiểm kê nói dối đúng lúc quan
--   trọng nhất: đào vỡ ba tảng đá vàng xong, vàng nằm ngay dưới chân mà bảng
--   vẫn báo `vang=0`. Tôi đã đi chẩn đoán nhầm nguyên một vòng vì con số đó.
--
--   Mượn từ GrimWorld (Workshop 3748676443): `GrimColony:ColonyStock` quét một
--   lượt `_inventoryitem` trong bán kính làng RỒI MỚI cộng các rương. Nền đất
--   của làng chính là một cái kho, và người chơi thật cũng dùng nó như vậy.
--   Xem docs/dst-knowledge/analysis/refmods/3748676443-grimworld.md
local BO_QUA_DUOI_DAT = {
    "INLIMBO", "NOCLICK", "FX", "fire", "smolder", "burnt", "catchable",
    "irreplaceable", "heavy", "trap", "minesprung",
}

local function GomDuoiDat(bk, tam, ban_kinh)
    for _, v in ipairs(TheSim:FindEntities(tam[1], 0, tam[2], ban_kinh,
            { "_inventoryitem" }, BO_QUA_DUOI_DAT)) do
        local ii = v.components.inventoryitem
        -- ⚠ Đồ đang có người cầm thì BỎ QUA — đã đếm ở vòng túi rồi. Không xét
        --   thì mọi món trong tay dân làng bị đếm hai lần và "ngày ăn" tăng
        --   gấp đôi một cách âm thầm.
        if ii ~= nil and not ii:IsHeld() and not v:IsInLimbo() then
            Cong(bk, v)
        end
    end
end

-- ── điểm vào ────────────────────────────────────────────────────────────

-- Kiểm kê cả làng. Trả về một bảng phẳng, JSON hoá được để gửi cho tầng
-- suy nghĩ, và đọc thẳng được từ cây hành vi.
function kho_lang.Kiem()
    local bk = {
        mon = {}, calo = 0, mau_hoi = 0, sap_hong = 0,
        vu_khi = 0, giap = 0, riu = 0, cuoc = 0,
        so_dan = 0, mau_tb = 100, doi_tb = 100, than_tb = 100,
        cong_trinh = {}, cap_may = 0,
    }

    local ds = dan_lang.TatCa()
    bk.so_dan = #ds
    if #ds == 0 then return bk end

    local tong_mau, tong_doi, tong_than = 0, 0, 0
    for _, e in ipairs(ds) do
        local tui = e.components.inventory
        if tui ~= nil then
            for _, mon in pairs(tui.itemslots or {}) do Cong(bk, mon) end
            for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
                Cong(bk, tui:GetEquippedItem(o))
            end
        end
        GomHopChua(bk, e.components.container)   -- túi hàng

        tong_mau  = tong_mau  + (e.components.health and e.components.health:GetPercent() or 1)
        tong_doi  = tong_doi  + (e.components.hunger and e.components.hunger:GetPercent() or 1)
        tong_than = tong_than + (e.components.sanity and e.components.sanity:GetPercent() or 1)
    end
    bk.mau_tb  = math.floor(tong_mau  / #ds * 100)
    bk.doi_tb  = math.floor(tong_doi  / #ds * 100)
    bk.than_tb = math.floor(tong_than / #ds * 100)

    -- Rương và công trình quanh làng. Lấy tâm của dân làng đầu tiên CÓ nhà.
    local tam, ban_kinh
    for _, e in ipairs(ds) do
        tam = lang.Tam(e)
        if tam ~= nil then ban_kinh = lang.BanKinh(e) break end
    end
    if tam ~= nil then
        GomDuoiDat(bk, tam, ban_kinh)
        for _, v in ipairs(TheSim:FindEntities(tam[1], 0, tam[2], ban_kinh,
                nil, { "INLIMBO", "burnt" })) do
            local cap = kho_lang.CONG_TRINH[v.prefab]
            if cap ~= nil then
                bk.cong_trinh[v.prefab] = (bk.cong_trinh[v.prefab] or 0) + 1
                if cap > bk.cap_may then bk.cap_may = cap end
            end
            -- Chỉ rương mới tính là kho. Túi hàng dân làng đã đếm ở trên rồi.
            if v.components.container ~= nil and v:HasTag("structure") then
                GomHopChua(bk, v.components.container)
            end
        end
    end

    -- ── quy ra thứ quyết định được ──────────────────────────────────────
    bk.ngay_an = bk.so_dan > 0
        and tonumber(string.format("%.1f", bk.calo / (DOT_MOI_NGAY * bk.so_dan)))
        or 0

    for _, ten in ipairs(kho_lang.NGUYEN_LIEU) do
        bk[ten] = bk.mon[ten] or 0
    end

    bk.du_an     = bk.ngay_an  >= kho_lang.DU_NGAY_AN
    bk.du_thuoc  = bk.mau_hoi  >= kho_lang.DU_MAU_HOI
    bk.du_vu_khi = bk.vu_khi   >= bk.so_dan
    bk.du_giap   = bk.giap     >= bk.so_dan

    -- Câu trả lời cho "đã đủ đồ ăn và đồ hồi máu thì nghĩ tới đánh nhau chưa".
    bk.du_suc_danh = bk.du_an and bk.du_thuoc and bk.du_vu_khi and bk.mau_tb >= 70

    -- Nút thắt: thứ ĐẦU TIÊN đang chặn đường, để tầng suy nghĩ khỏi đoán.
    bk.nut_that = kho_lang.NutThat(bk)
    return bk
end

-- Đâu là thứ đang chặn làng tiến lên. Xét theo đúng thứ tự chết người: đói
-- trước, rồi công nghệ, rồi bảo quản, rồi phòng thủ.
function kho_lang.NutThat(bk)
    if bk.ngay_an < 1                       then return "đói — chưa đủ một ngày ăn" end
    if bk.riu  < 1                          then return "thiếu rìu" end
    if bk.cuoc < 1                          then return "thiếu cuốc — không đào được đá" end
    if bk.cap_may < 1 then
        if (bk.goldnugget or 0) < 1         then return "thiếu vàng cho máy khoa học" end
        if (bk.rocks or 0) < 4              then return "thiếu đá cho máy khoa học" end
        if (bk.log or 0) < 4                then return "thiếu gỗ cho máy khoa học" end
        return "đủ liệu, chưa dựng máy khoa học"
    end
    if bk.cong_trinh.cookpot == nil         then return "chưa có nồi — đồ ăn thô phí nửa giá trị" end
    if bk.cong_trinh.treasurechest == nil   then return "chưa có rương — đồ ăn để đất hỏng nhanh gấp rưỡi" end
    if bk.sap_hong > 0                      then return "có " .. bk.sap_hong .. " món sắp hỏng" end
    if not bk.du_an                         then return "dự trữ ăn mỏng" end
    if not bk.du_vu_khi                     then return "chưa đủ vũ khí" end
    if not bk.du_giap                       then return "chưa đủ giáp" end
    return nil
end

-- ── trần thu gom ────────────────────────────────────────────────────────
--
-- ⚠ ĐỦ RỒI THÌ THÔI GOM — VÀ PHẢI ĐẾM CẢ LÀNG, KHÔNG ĐẾM RIÊNG TỪNG TÚI.
--   Trước đây mấy con số này nằm rải rác và mỗi chỗ một kiểu: DU_CUI=4 trong
--   việc gom củi, DU_ROI=20 trong việc hái, GIU_LAM_DUOC=4 trong việc tiếp
--   lửa — và tất cả đều chỉ nhìn túi CỦA MỘT NGƯỜI. Ba dân làng mỗi đứa ôm 19
--   quả berry thì không ai thấy làng đang có 57 quả.
--
--   Mượn từ GrimWorld (Workshop 3748676443): bảng `worklimits` + `ResourceCapped`
--   + `AutoWorkAllowed`, cộng bảng `WORK_ACTION_PRODUCT` nói mỗi việc đẻ ra cái
--   gì. Xem docs/dst-knowledge/analysis/refmods/3748676443-grimworld.md
--
-- ⚠ TRẦN CHỈ CHẶN VIỆC TỰ PHÁT, KHÔNG CHẶN NHU CẦU. Dân làng cần 4 khúc gỗ để
--   dựng Máy Khoa Học thì vẫn phải đi chặt, dù kho đã chạm trần gỗ. GrimWorld
--   cũng tách đúng ranh giới này: lệnh người chơi ra thì trần không áp. Nên
--   `sinh_ton.DiKiem` (đường của nhu cầu) KHÔNG gọi tới đây.
kho_lang.TRAN = {
    log        = 40,
    rocks      = 40,
    cutgrass   = 40,
    twigs      = 40,
    flint      = 20,
    berries    = 20,
    goldnugget = 12,
    nitre      = 10,
    petals     = 20,
}

-- Việc này đẻ ra cái gì. Chỉ những việc có MỘT sản phẩm rõ ràng mới chặn được.
kho_lang.SAN_PHAM_VIEC = {
    CHOP = "log",
    MINE = "rocks",
}

-- ⚠ Kiểm kê quét cả bán kính làng nên KHÔNG rẻ, mà bộ chọn việc gọi nó mỗi
--   nửa giây cho từng dân làng. Nhớ đệm 1 giây, y như ColonyStockCached.
local dem_cache, dem_cache_t

function kho_lang.KiemDem()
    local gio = GetTime()
    if dem_cache == nil or gio - (dem_cache_t or 0) > 1 then
        local ok, bk = pcall(kho_lang.Kiem)
        dem_cache   = ok and bk or nil
        dem_cache_t = gio
    end
    return dem_cache
end

function kho_lang.XoaDem()
    dem_cache, dem_cache_t = nil, nil
end

-- Kho của làng đã đủ `prefab` chưa?
function kho_lang.DaDu(prefab)
    local tran = prefab ~= nil and kho_lang.TRAN[prefab] or nil
    if tran == nil then return false end
    local bk = kho_lang.KiemDem()
    if bk == nil then return false end
    return (bk.mon[prefab] or 0) >= tran
end

-- Việc TỰ PHÁT này còn đáng làm không? Việc không rõ sản phẩm thì luôn cho làm.
function kho_lang.ViecConCan(hanh_dong)
    local ten = hanh_dong ~= nil and hanh_dong.id or nil
    local sp = ten ~= nil and kho_lang.SAN_PHAM_VIEC[ten] or nil
    return sp == nil or not kho_lang.DaDu(sp)
end

-- Bản gọn để nhét vào gói hỏi — bỏ bảng `mon` dài dòng đi.
function kho_lang.BanGon()
    local ok, bk = pcall(kho_lang.Kiem)
    if not ok then
        nen.chitiet("kiểm kê hỏng:", tostring(bk))
        return nil
    end
    local g = {}
    for k, v in pairs(bk) do
        if k ~= "mon" then g[k] = v end
    end
    -- Nguyên liệu: chỉ kể thứ đang có.
    local nl = {}
    for _, ten in ipairs(kho_lang.NGUYEN_LIEU) do
        if (bk.mon[ten] or 0) > 0 then nl[ten] = bk.mon[ten] end
    end
    g.nguyen_lieu = nl
    return g
end

return kho_lang

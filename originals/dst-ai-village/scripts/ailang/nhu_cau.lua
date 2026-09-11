-- Bảng nhu cầu sinh tồn — phần "biết mình cần gì" của dân làng.
--
-- Khai báo bằng DỮ LIỆU chứ không bằng nhánh if lồng nhau, để thêm nhu cầu mới
-- chỉ là thêm một mục vào bảng. Cái này quyết định dân làng trông thông minh
-- tới đâu: càng nhiều BẬC giải pháp và càng biết đi kiếm nguyên liệu còn thiếu
-- thì càng giống người chơi thật.
--
-- Mỗi nhu cầu:
--   ma    khoá ngắn
--   ten   tên hiển thị
--   can   có đang cần không
--   du    đã thoả mãn chưa (thoả rồi thì bỏ qua, không phí công)
--   bac   danh sách giải pháp, TỐT NHẤT TRƯỚC. Không làm được bậc trên thì
--         tụt xuống bậc dưới; không bậc nào làm ngay được thì đi kiếm nguyên
--         liệu cho bậc RẺ NHẤT.
--
-- ⚠ Công thức dưới đây lấy TỪ GAME, không phải trí nhớ. Đã đo 11/09/2026:
--     torch        cutgrass×2 twigs×2                tech 0
--     campfire     cutgrass×3 log×2                  tech 0
--     armorgrass   cutgrass×10 twigs×2               tech 0
--     strawhat     cutgrass×12                       tech 0
--     researchlab  goldnugget×1 log×4 rocks×4        tech 0
--     rope         cutgrass×3                        tech 1
--     spear        twigs×2 rope×1 flint×1            tech 1
--     armorwood    log×8 rope×2                      tech 1
--     lantern      twigs×3 rope×2 lightbulb×2        tech 2
--     minerhat     strawhat×1 goldnugget×1 fireflies×1  tech 2
--   Tech 1 đòi đứng gần Máy Khoa Học, tech 2 đòi Máy Giả Kim. builder:CanBuild
--   tự xét chuyện đó, nên bậc cao tự động rụng khi chưa đủ đồ nghề.

local nen = require("ailang/nen")

local nhu_cau = {}

-- ── nguyên liệu lấy từ đâu ──────────────────────────────────────────────
--
-- Đã đo pickable.product và loot: grass→cutgrass, sapling→twigs,
-- flower→petals, berrybush→berries, flower_cave→lightbulb (chính là "trái đèn"
-- để làm đèn lồng), cây→log, đá→rocks/flint/goldnugget/nitre.

nhu_cau.NGUON = {
    cutgrass   = { hd = "PICK", tag = "pickable",      prefab = "grass" },
    twigs      = { hd = "PICK", tag = "pickable",      prefab = "sapling" },
    petals     = { hd = "PICK", tag = "pickable",      prefab = "flower" },
    berries    = { hd = "PICK", tag = "pickable",      prefab = "berrybush" },
    cutreeds   = { hd = "PICK", tag = "pickable",      prefab = "reeds" },
    lightbulb  = { hd = "PICK", tag = "pickable",      prefab = "flower_cave" },
    carrot     = { hd = "PICK", tag = "pickable",      prefab = "carrot_planted" },
    log        = { hd = "CHOP", tag = "CHOP_workable" },
    rocks      = { hd = "MINE", tag = "MINE_workable" },
    flint      = { hd = "MINE", tag = "MINE_workable" },
    goldnugget = { hd = "MINE", tag = "MINE_workable" },
    nitre      = { hd = "MINE", tag = "MINE_workable" },
}

-- ── món nào phát sáng ───────────────────────────────────────────────────
--
-- ⚠ KHÔNG có dấu hiệu chung. Đã đo: torch/lighter mang tag "lighter",
--   lantern mang tag "light", còn minerhat và nightstick KHÔNG mang tag nào.
--   inst.Light phía server là nil cho TẤT CẢ — ánh sáng là thứ client vẽ.
--   Nên phải vừa xét tag vừa có danh sách trắng.
nhu_cau.PHAT_SANG = { minerhat = true, nightstick = true }

function nhu_cau.MonPhatSang(mon)
    if mon == nil then return false end
    if mon.components.fueled ~= nil and mon.components.fueled:GetPercent() <= 0 then
        return false
    end
    return mon:HasTag("lighter") or mon:HasTag("light")
           or nhu_cau.PHAT_SANG[mon.prefab] == true
end

-- ── tiện ích chung ──────────────────────────────────────────────────────

local O_TRANG_BI = { "hands", "head", "body" }

local function DuyetTrangBi(inst, fn)
    local tui = inst.components.inventory
    if tui == nil then return nil end
    for _, o in ipairs(O_TRANG_BI) do
        local mon = tui:GetEquippedItem(o)
        if mon ~= nil and fn(mon) then return mon end
    end
    return nil
end

local function DuyetTui(inst, fn)
    local tui = inst.components.inventory
    if tui == nil then return nil end
    for _, mon in pairs(tui.itemslots or {}) do
        if mon ~= nil and fn(mon) then return mon end
    end
    return nil
end

nhu_cau.DuyetTrangBi = DuyetTrangBi
nhu_cau.DuyetTui = DuyetTui

local function DangMac(inst, ten)
    return DuyetTrangBi(inst, function(m) return m.prefab == ten end) ~= nil
end

local function CoTrongTui(inst, ten)
    return DuyetTui(inst, function(m) return m.prefab == ten end)
end

nhu_cau.CoTrongTui = CoTrongTui

-- ── ăn uống ─────────────────────────────────────────────────────────────
--
-- ⚠ ĐỪNG ăn bừa mọi thứ CanEat() cho qua. Đã đo giá trị thật:
--     red_cap    máu −20
--     green_cap  não −50
--     blue_cap   máu +20 nhưng não −15
--     meat sống  não −10
--   Bản đầu ăn bất cứ thứ gì eater:CanEat() nên dân làng tự đầu độc mình bằng
--   nấm vừa hái. Giờ chấm điểm và chỉ ăn món hại khi thật sự sắp lả.

local SAP_LA = 0.15   -- dưới mức này thì ăn gì cũng được, miễn sống

function nhu_cau.ChamDiemAn(inst, mon)
    local ed = mon.components.edible
    if ed == nil then return nil end
    local mau  = ed.healthvalue or 0
    local nao  = ed.sanityvalue or 0
    local no   = ed.hungervalue or 0
    -- No là thứ đang cần; máu và não tính nặng hơn vì mất thì khó lấy lại.
    return no + mau * 3 + nao * 2
end

function nhu_cau.ChonMonAn(inst)
    local an = inst.components.eater
    local doi = inst.components.hunger
    if an == nil then return nil end
    local sap_la = doi ~= nil and doi:GetPercent() < SAP_LA

    local tot, diem_tot = nil, nil
    DuyetTui(inst, function(mon)
        if not an:CanEat(mon) then return false end
        local d = nhu_cau.ChamDiemAn(inst, mon)
        if d == nil then return false end
        if d <= 0 and not sap_la then return false end   -- món hại, chưa đến mức
        if diem_tot == nil or d > diem_tot then tot, diem_tot = mon, d end
        return false
    end)
    return tot, diem_tot
end

-- ── bảng nhu cầu, ưu tiên từ trên xuống ─────────────────────────────────

nhu_cau.DANH_SACH = {
    {
        ma  = "anh_sang",
        ten = "ánh sáng",
        -- Chập tối đã lo, không đợi tối hẳn mới cuống.
        can = function() return TheWorld.state.isdusk or TheWorld.state.isnight end,
        du  = function(inst)
            return DuyetTrangBi(inst, nhu_cau.MonPhatSang) ~= nil
                or (not TheWorld.state.isnight
                    and DuyetTui(inst, nhu_cau.MonPhatSang) ~= nil)
        end,
        -- Chỉ CẦM LÊN khi tối hẳn; hoàng hôn thì có sẵn trong túi là đủ, để
        -- còn rảnh tay cầm rìu.
        mac_khi = function() return TheWorld.state.isnight end,
        bac = {
            { mon = "minerhat" },
            { mon = "lantern" },
            { mon = "torch" },
        },
    },
    {
        ma  = "do_an",
        ten = "đồ ăn",
        -- ⚠ Ngưỡng này phải KHỚP với DOI_THI_AN trong danlangbrain. Lệch nhau
        --   thì dân làng "đang lo đồ ăn" mà không chịu ăn món đang cầm.
        can = function(inst)
            local h = inst.components.hunger
            return h ~= nil and h:GetPercent() < 0.5
        end,
        du  = function(inst) return nhu_cau.ChonMonAn(inst) ~= nil end,
        -- Không chế được đồ ăn ở bậc này; giải pháp là đi hái, xử lý ở
        -- phần "đi kiếm" bên dưới.
        bac = {},
        kiem = { "berries", "carrot" },
    },
    {
        ma  = "hoi_mau",
        ten = "hồi máu",
        can = function(inst)
            local h = inst.components.health
            return h ~= nil and h:GetPercent() < 0.5
        end,
        du = function(inst)
            return DuyetTui(inst, function(m)
                return m.components.healer ~= nil
                    or (m.components.edible ~= nil
                        and (m.components.edible.healthvalue or 0) > 0)
            end) ~= nil
        end,
        bac = { { mon = "healingsalve" }, { mon = "bandage" } },
        kiem = { "berries", "carrot" },
    },
    {
        ma  = "hoi_nao",
        ten = "hồi não",
        can = function(inst)
            local s = inst.components.sanity
            return s ~= nil and s:GetPercent() < 0.5
        end,
        -- Đội vòng hoa là xong. Không có thì cứ đi hái hoa cũng đã hồi —
        -- flower có onpickedfn cộng tinh thần mỗi lần hái.
        du = function(inst) return DangMac(inst, "flowerhat") end,
        bac = { { mon = "flowerhat" } },   -- petals×12, tech 0
        kiem = { "petals" },
    },
    {
        ma  = "vu_khi",
        ten = "vũ khí",
        can = function() return true end,
        du  = function(inst)
            return DuyetTrangBi(inst, function(m)
                return m.components.weapon ~= nil
            end) ~= nil
        end,
        mac_khi = function() return false end,   -- không tự cầm, để rảnh tay làm việc
        bac = { { mon = "spear" } },
    },
    {
        ma  = "giap",
        ten = "giáp",
        can = function() return true end,
        du  = function(inst)
            return DuyetTrangBi(inst, function(m)
                return m.components.armor ~= nil
            end) ~= nil
        end,
        bac = { { mon = "armorwood" }, { mon = "armorgrass" } },
    },
    {
        ma  = "nha",
        ten = "nhà",
        can = function() return true end,
        du  = function(inst)
            local nha = inst.ailang ~= nil and inst.ailang.nha or nil
            if nha == nil then return false end
            -- Có nhà rồi thì phải có bếp lửa ở đó mới tính là xong.
            return FindEntity(inst, 40, nil, { "campfire" }, { "INLIMBO", "burnt" }) ~= nil
        end,
        bac = { { mon = "firepit", dat_xuong = true }, { mon = "campfire", dat_xuong = true } },
    },
}

function nhu_cau.Tim(ma)
    for _, n in ipairs(nhu_cau.DANH_SACH) do
        if n.ma == ma then return n end
    end
    return nil
end

return nhu_cau

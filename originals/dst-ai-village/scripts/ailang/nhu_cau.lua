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
    -- ⚠ VÀNG CHỈ RA TỪ rock2, VÀ ĐÂY LÀ THỨ ĐÃ CHẶN CẢ TECH 1. Bản trước để
    --   goldnugget nhắm mọi thứ mang tag MINE_workable, nên dân làng đập tảng
    --   đá thường (rock1) hết lượt này tới lượt khác và KHÔNG BAO GIỜ ra vàng
    --   — mà Máy Khoa Học cần đúng 1 cục. Không có máy thì không có rope,
    --   không nồi, không rương, không giáo, không lửa lạnh: cả nền kinh tế
    --   tech 1 chết ở một dòng bảng tra.
    --
    --   Bảng rơi trong scripts/prefabs/rocks.lua nói thẳng:
    --       rock1 -> rocks×3, nitre, flint        (KHÔNG có vàng)
    --       rock2 -> rocks×3, goldnugget, flint
    goldnugget = { hd = "MINE", tag = "MINE_workable", prefab = "rock2" },
    nitre      = { hd = "MINE", tag = "MINE_workable", prefab = "rock1" },
}

-- ── món nào phát sáng ───────────────────────────────────────────────────
--
-- ⚠ KHÔNG có dấu hiệu chung. Đã đo: torch/lighter mang tag "lighter",
--   lantern mang tag "light", còn minerhat và nightstick KHÔNG mang tag nào.
--   inst.Light phía server là nil cho TẤT CẢ — ánh sáng là thứ client vẽ.
--   Nên phải vừa xét tag vừa có danh sách trắng.
nhu_cau.PHAT_SANG = { minerhat = true, nightstick = true }

-- Bấy nhiêu cái bẫy thì coi như làng đủ nguồn thịt. Mỗi bẫy 8 lượt dùng, một
-- lượt ra một con thỏ (25 calo nướng chín) — bốn bẫy nuôi được ba người.
nhu_cau.DU_BAY = 4

-- ⚠ Đuốc dưới 25% nhiên liệu coi như KHÔNG còn là nguồn sáng, để dân làng
--   kịp làm cây mới TRƯỚC khi tắt. Đo trên server: chúng cầm đuốc từ chập
--   tối, đuốc cháy hết đúng lúc vào đêm, và cả ba chết với tay không.
local SAP_TAT = 0.25

-- Trên mức này thì khỏi lo cây tiếp theo; dưới thì phải có đồ dự phòng.
local DU_LAU = 0.5

-- ⚠ HAI CÂU HỎI KHÁC NHAU, đừng dùng lẫn:
--     DangChayThat  — món này CÓ ĐANG phát sáng không? (thực tế vật lý)
--     MonPhatSang   — món này còn đủ dùng để YÊN TÂM không? (để lập kế hoạch)
--   MonPhatSang coi đuốc dưới 25% là "không tính", để dân làng kịp làm cây mới
--   TRƯỚC khi nó tắt. Nhưng cây đuốc 20% vẫn đang cháy và vẫn cứu mạng — lấy
--   ngưỡng kế hoạch đi tắt đèn thật là tự đẩy chúng vào bóng tối.
function nhu_cau.DangChayThat(mon)
    if mon == nil then return false end
    if mon.components.fueled ~= nil
       and mon.components.fueled:GetPercent() <= 0 then
        return false
    end
    return mon:HasTag("lighter") or mon:HasTag("light")
           or nhu_cau.PHAT_SANG[mon.prefab] == true
end

function nhu_cau.MonPhatSang(mon)
    if mon == nil then return false end
    if mon.components.fueled ~= nil
       and mon.components.fueled:GetPercent() <= SAP_TAT then
        return false
    end
    return mon:HasTag("lighter") or mon:HasTag("light")
           or nhu_cau.PHAT_SANG[mon.prefab] == true
end

-- ⚠ Ban đêm mà nguồn sáng DUY NHẤT là đuốc cầm tay thì ĐỪNG cầm dụng cụ lên:
--   đổi tay là mất sáng, và mất sáng giữa đêm là chết.
--
--   Chốt này phải dùng ở MỌI chỗ có thể trang bị dụng cụ. Bản đầu chỉ đặt
--   trong viec.lua mà quên sinh_ton.DiKiem, nên nhu cầu "nhà" đi kiếm gỗ vẫn
--   cầm rìu lên giữa đêm và giành mất tay cầm đuốc.
function nhu_cau.KhongRanhTay(inst)
    if not (TheWorld.state.isnight or TheWorld.state.isdusk) then return false end
    local tui = inst.components.inventory
    if tui == nil then return false end
    -- Đèn đội đầu thì rảnh tay hẳn — nó không chiếm ô tay.
    if nhu_cau.MonPhatSang(tui:GetEquippedItem(EQUIPSLOTS.HEAD)) then return false end
    -- ⚠ KHÔNG còn lối thoát "đứng cạnh lửa trại thì rảnh tay". Đó là một THỨ
    --   THAY THẾ cho "đang trong vùng sáng", và nó SAI Ở RÌA: vùng làm việc
    --   ban đêm cho phép tới 12 đơn vị quanh lửa, trong khi lửa không chiếu
    --   xa được tới đó. Đo được trên server, giữa đêm, lửa vẫn cháy (lua=1):
    --       An[96% axe gom củi {to2,...}]   Binh[98% axe gom củi {to2}]
    --       -> An bi danh 100.05  -> Binh bi danh 100.05  -> cả hai CHẾT
    --   Cả hai có HAI cây đuốc trong túi mà đang cầm rìu, đứng trong bóng tối.
    --
    --   Cùng một sai lầm đã mắc với cây đuốc: đo bằng thứ thay thế thay vì đo
    --   thứ thật. Giờ bỏ hẳn proxy và dùng luật bảo thủ — TRỜI TỐI THÌ CẦM
    --   ĐUỐC, ĐỪNG CẦM DỤNG CỤ. Việc không cần tay (tiếp lửa, nhặt đồ) vẫn
    --   làm được bình thường.
    return true
end

-- ⚠ ĐUỐC CHÁY KHI CẦM TRÊN TAY. Cầm từ sáng tới tối là tới đêm nó tắt ngóm —
--   đúng lúc cần nhất. Đo được: dân làng cầm đuốc suốt cả ngày chỉ để đi hái
--   cỏ, việc chẳng cần tay nào cả.
--
--   Nên hễ chưa tới lúc phải cầm (ban ngày, hoặc chập tối mà đứng cạnh lửa)
--   thì CẤT ĐI. Chỉ đụng tới món cầm tay có nhiên liệu; mũ thợ mỏ đội đầu
--   không vướng việc gì nên để yên.
function nhu_cau.CatNguonSang(inst)
    local tui = inst.components.inventory
    if tui == nil then return false end
    local tay = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if tay == nil or tay.components.fueled == nil then return false end
    if not nhu_cau.MonPhatSang(tay) then return false end

    local n = nhu_cau.Tim("anh_sang")
    if n == nil or n.mac_khi == nil or n.mac_khi(inst) then return false end

    local go = tui:Unequip(EQUIPSLOTS.HANDS)
    if go ~= nil then tui:GiveItem(go) end
    nen.doi(inst, tostring(inst.ailang and inst.ailang.ten),
            "cất", tay.prefab, "đi cho khỏi cháy phí")
    return true
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

-- ⚠ HỎI CHÍNH NHÂN VẬT, ĐỪNG ĐỌC THẲNG SỐ TRÊN MÓN ĂN. `edible.healthvalue`
--   là giá trị GỐC; từng nhân vật lại đọc nó khác nhau — WX-78 ăn đồ thiu
--   không sao, Wigfrid chỉ ăn thịt, Webber ăn được đồ quái. `edible:GetHealth
--   (eater)` và `:GetSanity(eater)` đã tính sẵn phần đó.
--
-- ⚠ Và có nhân vật MIỄN NHIỄM hẳn tác dụng phụ (`eater:DoFoodEffects` trả
--   false, ví dụ lúc là hồn ma hoặc mấy nhân vật đặc biệt). Với họ thì món
--   "hại" chẳng hại gì, chỉ còn phần no — chê nó là chê oan một bữa ăn.
--   (Mượn GrimCook.Immune / ItemCost của GrimWorld.)
function nhu_cau.ChamDiemAn(inst, mon)
    local ed = mon.components.edible
    if ed == nil then return nil end

    local an = inst.components.eater
    local mien_nhiem = an ~= nil and an.DoFoodEffects ~= nil
                       and not an:DoFoodEffects(mon)

    local no = ed.GetHunger ~= nil and ed:GetHunger(inst) or (ed.hungervalue or 0)
    if mien_nhiem then return no end

    local mau = ed.GetHealth ~= nil and ed:GetHealth(inst) or (ed.healthvalue or 0)
    local nao = ed.GetSanity ~= nil and ed:GetSanity(inst) or (ed.sanityvalue or 0)
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

-- ⚠ VŨ KHÍ VÀ GIÁP LÀ VIỆC CỦA LÚC ĐÃ YÊN THÂN, không phải việc ngày đầu.
--   Áo cỏ tốn MƯỜI bó cỏ, mà đuốc chỉ tốn hai. `can` của chúng luôn trả true
--   nên ba dân làng vặt sạch cỏ trong bán kính làng để làm áo — rồi tới chập
--   tối thì đứng TAY KHÔNG với đúng 1 bó cỏ, không đủ làm nổi một cây đuốc.
--   Đo trên server: cả ba vào đêm tay không, kẹt ở cu1 nhiều nhịp liền vì
--   quanh làng không còn bụi cỏ nào chưa hái.
--
--   Người chơi thật cũng vậy: lo lửa và đồ ăn trước, áo giáp tính sau.
local function DaYenThan(inst)
    for _, ma in ipairs({ "anh_sang", "nha" }) do
        local n = nhu_cau.Tim(ma)
        if n == nil then return false end
        local ok, du = pcall(n.du, inst)
        if not ok or not du then return false end
    end
    return true
end

-- ── bảng nhu cầu, ưu tiên từ trên xuống ─────────────────────────────────
--
-- `gap = true` nghĩa là nhu cầu này được CHEN NGANG việc đang làm dở.
--
-- ⚠ Chỉ ba nhu cầu đầu được chen. vũ khí / giáp / nhà thì `can` luôn trả true
--   nên nếu cho chúng chen, dân làng sẽ bỏ việc mỗi nhịp và chẳng làm xong
--   gì — đúng cái bệnh mà bản gom-một-node sinh ra để chữa.

nhu_cau.DANH_SACH = {
    {
        ma  = "anh_sang",
        ten = "ánh sáng",
        gap = true,
        -- ⚠ LUÔN muốn có nguồn sáng sẵn trong người, kể cả giữa ban ngày.
        --   Bản trước chỉ bật nhu cầu này lúc chập tối, và đó là ÁN TỬ: đo
        --   trên server, cả ba dân làng dành nguyên ngày gom đồ cho vũ khí và
        --   giáp, tới lúc trời sập thì tay trắng, và CHẾT CẢ BA trong một đêm.
        --   Chế cây đuốc mất 2 cỏ + 2 cành — phải gom lúc còn sáng, y như
        --   người chơi thật vẫn làm.
        can = function() return true end,
        du  = function(inst)
            -- Ban đêm thì phải CẦM TRÊN TAY mới tính; ban ngày để trong túi
            -- là đủ, khỏi vướng tay làm việc.
            -- ⚠ ĐANG CẦM ĐUỐC CHƯA CHẮC LÀ ĐỦ. Đuốc cháy hao liên tục, nên
            --   "đủ" phải tính cả CÂY TIẾP THEO. Đo trên server: chập tối, An
            --   và Cuong đứng TAY KHÔNG với đúng 1 bó cỏ trong túi — đuốc vừa
            --   tắt, mà làm cây mới cần 2 cỏ. Ngưỡng 25% cho lead time trên
            --   giấy nhưng ngoài thực địa thì không kịp gom nguyên liệu.
            --   Giờ: còn trên nửa bình thì yên tâm; dưới nửa thì phải có cây
            --   dự phòng trong túi mới coi là đủ.
            local tay = DuyetTrangBi(inst, nhu_cau.MonPhatSang)
            if tay ~= nil then
                local f = tay.components.fueled
                if f == nil or f:GetPercent() > DU_LAU then return true end
                if DuyetTui(inst, nhu_cau.MonPhatSang) ~= nil then return true end
                return false
            end
            -- ⚠ `du` phải KHỚP với `mac_khi`. Nếu đang tới lúc phải cầm đuốc
            --   lên mà `du` lại báo "đủ rồi" vì đuốc nằm trong túi, thì không
            --   ai ra lệnh cầm — đo được: chập tối dân làng vẫn tay không dù
            --   túi có đuốc, và đó chính là lúc Charlie ra đòn đầu tiên.
            local n = nhu_cau.Tim("anh_sang")
            if n ~= nil and n.mac_khi ~= nil and n.mac_khi(inst) then
                return false
            end
            return DuyetTui(inst, nhu_cau.MonPhatSang) ~= nil
        end,
        -- ⚠ CẦM LÊN TỪ HOÀNG HÔN, không đợi tối hẳn. Đợi tối hẳn là CHẾT: đo
        --   trên server, cả ba dân làng bị Charlie đánh 100 sát thương lúc
        --   giao thời chập tối → đêm khi còn tay không, rồi mới kịp rút đuốc
        --   ra và lãnh đòn thứ hai. Charlie đã đếm giờ trước khi trời tối hẳn.
        --
        --   Nhưng ĐỨNG CẠNH LỬA thì khỏi cầm — người chơi từng thấy dân làng
        --   cầm đuốc từ buổi chiều và thấy vô lý. Có lửa thì rảnh tay làm việc.
        -- ⚠ TRỜI TỐI LÀ CẦM, không trừ trường hợp nào. Bản trước chừa lối
        --   "đứng cạnh lửa thì khỏi cầm" — nhưng "cạnh lửa" đo bằng bán kính
        --   10 trong khi lửa không chiếu xa tới đó, nên dân làng bỏ đuốc vào
        --   túi rồi bước ra rìa và chết. Cầm thừa một cây đuốc thì tốn chút
        --   nhiên liệu; bỏ nó xuống nhầm lúc thì mất mạng.
        mac_khi = function()
            return TheWorld.state.isnight or TheWorld.state.isdusk
        end,
        -- ⚠ LỬA TRẠI là bậc cuối và nó CỨU MẠNG. Đo trên server: cả vùng
        --   không có bụi cây con nào trong bán kính 150, nên dân làng không
        --   bao giờ làm nổi đuốc (cần 2 cành) — trong khi chúng ôm 20 bó cỏ.
        --   Lửa trại chỉ cần 3 cỏ + 2 gỗ, mà gỗ thì chặt cây là có.
        bac = {
            { mon = "minerhat" },
            { mon = "lantern" },
            { mon = "torch" },
            { mon = "campfire", dat_xuong = true },
        },
    },
    {
        ma  = "do_an",
        ten = "đồ ăn",
        gap = true,
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
        gap = true,
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
        ma  = "mat_me",
        ten = "mát",
        -- ⚠ `gap` ở đây KHÔNG phải để chen ngang cho vui — nó là thứ nới dây
        --   trói về nhà từ 50 lên 140 (xem VE_NHA_XA_GAP trong danlangbrain).
        --   Mà cỏ làm mũ thì đo được: 1 bụi trong bán kính 30, 39 bụi trong
        --   bán kính 130. Không có `gap` thì dân làng bị trói trong 50 đơn vị
        --   và không bao giờ với tới chỗ có cỏ.
        --
        --   Chuyện "chen ngang mỗi nhịp" đã chặn ở chỗ khác và chặt hơn:
        --   viec.CanChenNgang bỏ qua mọi nhu cầu đang BÓ TAY.
        gap = true,
        -- ⚠ MÙA HÈ GIẾT DÂN LÀNG GIỮA BAN NGÀY, không cần Charlie. Đo trên
        --   server ngày 57 (mùa hè): nhiệt độ MÔI TRƯỜNG đã là 71.6 trong khi
        --   TUNING.OVERHEAT_TEMP = 70 — chỉ đứng ngoài trời là đủ chết. Máu
        --   tụt đều suốt ngày mà KHÔNG có sự kiện "attacked" nào, nên ban đầu
        --   nhìn như lỗi ma. Tương quan thì thẳng tưng:
        --       An 67.6 độ -> 56% máu | Cuong 71.3 -> 1% | Binh 72.4 -> CHẾT
        --
        -- ⚠ Bắt đầu lo từ 62 độ, đừng đợi chạm 70. Cách nhiệt của DST chỉ làm
        --   CHẬM tốc độ nóng lên chứ không chặn đứng, nên đội mũ lúc đã 70 là
        --   muộn.
        can = function(inst)
            local t = inst.components.temperature
            return t ~= nil and t:GetCurrent() >= 62
        end,
        du = function(inst)
            if DuyetTrangBi(inst, function(m)
                local ins = m.components.insulator
                return ins ~= nil and ins.type == SEASONS.SUMMER
                   and ins:GetInsulation() > 0
            end) ~= nil then return true end
            -- ⚠ BÓNG CÂY KHÔNG TÍNH LÀ "ĐỦ". Đứng dưới tán cây đúng là mát
            --   thật, nhưng đó là chỗ TRÚ TẠM — dân làng phải rời gốc cây mới
            --   làm được việc, và mỗi vòng ra-vào nó lại nhích qua mốc 70 một
            --   nhịp. Đo được: nhiệt ổn định ở 67-71 mà máu vẫn tụt đều
            --   99% -> 93% -> 80%. Nếu coi bóng râm là đủ thì dân làng KHÔNG
            --   BAO GIỜ chế cái mũ, và cứ rỉ máu như thế suốt mùa hè.
            --   Việc trú tạm để cây hành vi lo; ở đây chỉ tính giải pháp BỀN.
            -- Đứng cạnh lửa lạnh đang cháy cũng là mát, y như đứng cạnh lửa
            -- trại thì coi là có sáng.
            return FindEntity(inst, 10, function(v)
                       return v.prefab == "coldfire"
                          and v.components.burnable ~= nil
                          and v.components.burnable:IsBurning()
                   end, nil, { "INLIMBO", "burnt" }) ~= nil
        end,
        -- Đã đo: grass_umbrella cách nhiệt 120 (ô tay), strawhat 60 (ô đầu),
        -- cả hai đều tech 0. Dù cầm ô mất một tay, nó gấp đôi mũ cỏ nên xếp
        -- trên; thiếu đồ thì tự tụt xuống mũ.
        --
        -- ⚠ Nhưng cả hai chỉ LÀM CHẬM tốc độ nóng lên, không chặn đứng. Đo
        --   trên server: nhiệt môi trường lên tới 78, cách nhiệt 60 của mũ cỏ
        --   không cứu nổi. Lời giải THẬT của mùa hè là LỬA LẠNH — tech 1, nên
        --   phải có Máy Khoa Học trước (xem nhu cầu "xưởng"). builder:CanBuild
        --   tự xét cấp công nghệ nên bậc này tự rụng khi chưa có máy và tự
        --   sống dậy khi có.
        -- ⚠ ĐÃ BỎ grass_umbrella dù nó cách nhiệt gấp đôi (120 so với 60).
        --   Nó chiếm Ô TAY, đúng ô mà đuốc cần — hai nhu cầu giành nhau một ô
        --   là quay lại đúng bệnh rìu↔đuốc đã mất mấy vòng để chữa. Mũ cỏ đội
        --   đầu nên không đụng ai, và 12 bó cỏ chỉ phải trả một lần.
        bac = {
            { mon = "coldfire", dat_xuong = true, o_nha = true },  -- cutgrass×3 nitre×2, tech 1
            { mon = "strawhat" },                                  -- cutgrass×12, tech 0
        },
    },
    {
        ma  = "dung_cu",
        ten = "dụng cụ",
        -- ⚠ THIẾU NHU CẦU NÀY LÀ CHẾT. Rìu nằm trong bộ đồ khởi đầu, nhưng
        --   chết một lần là rơi hết — và KHÔNG nhu cầu nào biết chế lại rìu.
        --   Đo được trên server: hai dân làng túi rỗng cho `DiKiem("log")` trả
        --   nil ở CẢ hai bán kính trong khi có 12 cây chặt được trong vòng 30,
        --   chỉ vì không có rìu. Không gỗ thì không lửa trại, không lửa trại
        --   thì chết đêm, chết lại rơi rìu — vòng xoáy khép kín.
        --
        --   Rìu chế được ngay từ tay trắng: twigs×1 flint×1, tech 0, không cần
        --   máy khoa học. Đá lửa nhặt được dưới đất (đo: 7 mảnh trong vòng
        --   120), nên không kẹt vòng "phải có cuốc mới có đá lửa".
        --
        -- ⚠ ĐỨNG TRÊN "nhà": rìu là ĐIỀU KIỆN của đống lửa, không phải thứ
        --   cạnh tranh với nó.
        can = function() return true end,
        du  = function(inst)
            local function la_riu(m)
                return m.components.tool ~= nil
                   and m.components.tool:CanDoAction(ACTIONS.CHOP)
            end
            return DuyetTui(inst, la_riu) ~= nil
                or DuyetTrangBi(inst, la_riu) ~= nil
        end,
        -- Không tự cầm lên: viec.lua và sinh_ton.DiKiem tự trang bị đúng lúc
        -- cần, còn lúc khác thì để tay trống mà cầm đuốc.
        mac_khi = function() return false end,
        bac = { { mon = "axe" } },
    },
    {
        ma  = "cuoc",
        ten = "cuốc",
        -- ⚠ ĐÃ CHUYỂN TỪ CUỐI BẢNG LÊN ĐÂY. Lý do cũ ghi "không có cuốc thì
        --   chỉ chậm, không chết" — đúng vào lúc chưa có gì trong bảng cần đá.
        --   Giờ thì ĐÀO LÀ NÚT THẮT của cả nền kinh tế:
        --       cuốc -> đá + vàng -> Máy Khoa Học
        --                          -> rương, nồi, giáo, giáp gỗ, lửa lạnh
        --   Để nó cuối bảng thì "xưởng" cứ thử dựng máy, không kiếm nổi vàng
        --   vì tay không có cuốc, bị ghi bó tay rồi cho nghỉ — mà nhu cầu giải
        --   được nút đó lại nằm sau bốn nhu cầu khác. Đúng vòng luẩn quẩn đã
        --   làm làng chết từ ngày 9.
        --
        --   Cùng lý lẽ với rìu ngay trên: cuốc là ĐIỀU KIỆN, không phải thứ
        --   cạnh tranh. Và nó rẻ — twigs×2 flint×2, tech 0, đá lửa nhặt được
        --   dưới đất nên không kẹt vòng "phải có cuốc mới có đá lửa".
        can = function() return true end,
        du  = function(inst)
            local function la_cuoc(m)
                return m.components.tool ~= nil
                   and m.components.tool:CanDoAction(ACTIONS.MINE)
            end
            return DuyetTui(inst, la_cuoc) ~= nil
                or DuyetTrangBi(inst, la_cuoc) ~= nil
        end,
        mac_khi = function() return false end,
        bac = { { mon = "pickaxe" } },
    },
    {
        ma  = "nha",
        ten = "nhà",
        -- ⚠ ĐỨNG TRƯỚC vũ khí và giáp. Đống lửa quan trọng hơn cái áo cỏ:
        --   không có lửa thì chết đêm, còn không có giáp thì chỉ đau hơn.
        --   Bản trước để "nhà" ở CUỐI danh sách nên giáp/vũ khí luôn chen
        --   trước, và dân làng không bao giờ dựng nổi đống lửa nào.
        -- ⚠ GẤP: đống lửa của làng là nguồn sáng BỀN và KHÔNG tốn tay cầm.
        --   Dân làng chỉ sống bằng đuốc thì sớm muộn cũng chết — đuốc cháy hết
        --   giữa đêm là hết đường. Dựng được lửa trại là xong chuyện đêm hôm,
        --   và đó cũng là thứ người chơi thật làm đầu tiên.
        gap = true,
        can = function() return true end,
        du  = function(inst)
            local nha = inst.ailang ~= nil and inst.ailang.nha or nil
            if nha == nil then return false end
            -- Có nhà rồi thì phải có bếp lửa Ở ĐÓ mới tính là xong.
            --
            -- ⚠ FindEntity quét quanh CHÂN dân làng, không quanh nhà. Bản
            --   trước dùng nó nên một dân làng đứng cách nhà 51 mà cạnh lửa
            --   của ai đó là coi như "nhà xong" — trong khi làng vẫn tối om.
            return #TheSim:FindEntities(nha[1], 0, nha[2], 40,
                       { "campfire" }, { "INLIMBO", "burnt" }) > 0
        end,
        -- `o_nha`: dựng Ở LÀNG chứ không dưới chân — xem chú thích trong
        -- sinh_ton.GiaiMot. Đây là bếp lửa CHUNG, không phải lửa khẩn cấp.
        bac = {
            { mon = "firepit",  dat_xuong = true, o_nha = true },
            { mon = "campfire", dat_xuong = true, o_nha = true },
        },
    },
    {
        ma  = "du_tru",
        ten = "dự trữ",
        -- ⚠ NHU CẦU NÀY LÀ LỜI GIẢI CHO CÁI CHẾT HÀNG LOẠT. Bảng nhu cầu cũ
        --   chỉ có "đồ ăn", và nó chỉ bật khi bụng đã xuống dưới 50% — tức là
        --   luôn CHỮA CHÁY, không bao giờ TÍCH TRỮ. Đo trên server chạy nhanh:
        --   khoẻ tới ngày 8, rồi chết mỗi đêm, tới ngày 16 là 95 lượt chết.
        --
        --   Và hái berry thì không cứu được: một bụi cho 3 quả rồi chết, mọc
        --   lại 3 ngày, tức 0,33 quả/ngày/bụi trong khi ba dân làng đốt 225
        --   calo/ngày — cần khoảng 70 bụi. Không bản đồ nào có.
        --
        --   Bẫy thỏ thì TÁI TẠO: twigs×2 cutgrass×6, tech 0, 8 lượt dùng, đặt
        --   lên miệng hang là thỏ tự vào. Hang thỏ có khắp đồng cỏ và KHÔNG
        --   cạn. Đây là thứ người chơi thật sống bằng trong tuần đầu.
        --
        -- ⚠ KHÔNG `gap`. Đây là đầu tư cho ngày mai, không phải cứu hôm nay;
        --   cho nó chen ngang thì dân làng bỏ cả đuốc lẫn lửa để đi đan bẫy.
        can = function() return true end,
        du  = function(inst)
            local n = 0
            -- Bẫy trong túi tính là dự trữ, bẫy đã đặt xuống cũng vậy.
            -- ⚠ Bẫy KHÔNG chồng đống được: trap.lua gắn `finiteuses` (8 lượt)
            --   nên mỗi cái chiếm một ô túi riêng. Đếm theo chồng là đếm đúng
            --   một cái dù túi có bốn.
            local tui = inst.components.inventory
            if tui ~= nil then
                for _, m in pairs(tui.itemslots or {}) do
                    if m ~= nil and m.prefab == "trap" then n = n + 1 end
                end
            end
            local nha = inst.ailang ~= nil and inst.ailang.nha or nil
            if nha ~= nil then
                n = n + #TheSim:FindEntities(nha[1], 0, nha[2], 40,
                            { "trap" }, { "INLIMBO" })
            end
            return n >= nhu_cau.DU_BAY
        end,
        mac_khi = function() return false end,
        bac = { { mon = "trap" } },   -- twigs×2 cutgrass×6, tech 0
    },
    {
        ma  = "xuong",
        ten = "xưởng",
        -- ⚠ MỘT CÁI MÁY MỞ KHOÁ CẢ MỘT TẦNG. researchlab là TECH 0
        --   (goldnugget×1 log×4 rocks×4) nên dân làng tự dựng được — và từ lúc
        --   có nó, mọi nhu cầu khác tự lên bậc mà KHÔNG phải sửa gì thêm, vì
        --   builder:CanBuild tự xét cấp công nghệ:
        --       mát     -> coldfire   (lời giải thật của mùa hè)
        --       nhà     -> firepit    (bếp lửa không biến mất khi hết củi)
        --       vũ khí  -> spear
        --       giáp    -> armorwood
        --   Vàng và đá thì cần cuốc — nhu cầu "cuốc" đã lo phần đó.
        --
        -- ⚠ KHÔNG đặt `gap`. Dựng máy là việc dài hơi; cho nó chen ngang thì
        --   dân làng bỏ dở mọi thứ khác mỗi nhịp.
        can = function() return true end,
        du  = function(inst)
            local nha = inst.ailang ~= nil and inst.ailang.nha or nil
            if nha == nil then return false end
            -- ⚠ PHẢI đòi tag "structure". Chỉ lọc theo "prototyper" là dính
            --   cả carnival_host — con quạ của sự kiện lễ hội cũng mang tag
            --   đó, mà nó BIẾT ĐI. Bộ tự kiểm bắt được đúng cảnh này: có một
            --   con lảng vảng gần điểm sinh và dân làng tưởng làng đã có xưởng
            --   dù chưa dựng gì, rồi mất luôn khi nó đi khỏi.
            return #TheSim:FindEntities(nha[1], 0, nha[2], 40, { "structure" },
                       { "INLIMBO", "burnt" }, { "prototyper" }) > 0
        end,
        bac = { { mon = "researchlab", dat_xuong = true, o_nha = true } },
    },
    {
        ma  = "kho_chua",
        ten = "kho",
        -- ⚠ ĐỒ ĂN ĐỂ ĐẤT HỎNG NHANH GẤP RƯỠI. perishable.lua nhân hệ số theo
        --   chỗ cất: ngoài trời ×1,5 — rương ×1,0 — tủ lạnh ×0,5. Mang thịt về
        --   rồi quăng dưới chân là đã phí một phần ba trước khi kịp ăn.
        --
        --   Rương là tech 1 (boards×3 <- log×4), nên nó tự rụng khi chưa có
        --   Máy Khoa Học và tự sống dậy khi có — builder:CanBuild lo phần đó.
        --
        -- ⚠ Tủ lạnh thì KHÔNG đưa vào. icebox cần gears, mà gears chỉ rơi từ
        --   người máy ở Ruộng Bàn Cờ — dân làng đánh không lại, và bắt chúng
        --   đi săn gears là bắt đi chết. Người dùng có đồ thì cứ đưa tay.
        can = function() return true end,
        du  = function(inst)
            local nha = inst.ailang ~= nil and inst.ailang.nha or nil
            if nha == nil then return false end
            for _, v in ipairs(TheSim:FindEntities(nha[1], 0, nha[2], 40,
                    { "structure" }, { "INLIMBO", "burnt" })) do
                if v.components.container ~= nil then return true end
            end
            return false
        end,
        bac = { { mon = "treasurechest", dat_xuong = true, o_nha = true } },
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
        can = DaYenThan,
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
        can = DaYenThan,
        du  = function(inst)
            return DuyetTrangBi(inst, function(m)
                return m.components.armor ~= nil
            end) ~= nil
        end,
        bac = { { mon = "armorwood" }, { mon = "armorgrass" } },
    },
}

-- Thứ hạng ưu tiên của một nhu cầu theo TÊN HIỂN THỊ, để so bề nặng nhẹ giữa
-- việc đang làm và nhu cầu vừa nổi lên. Trả nil nếu tên đó không phải nhu cầu
-- (việc thường: nhặt / hái / chặt / đào).
function nhu_cau.ChiSo(ten)
    if ten == nil then return nil end
    for i, n in ipairs(nhu_cau.DANH_SACH) do
        if n.ten == ten then return i end
    end
    return nil
end

function nhu_cau.Tim(ma)
    for _, n in ipairs(nhu_cau.DANH_SACH) do
        if n.ma == ma then return n end
    end
    return nil
end

return nhu_cau

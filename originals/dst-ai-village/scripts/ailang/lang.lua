-- Vùng làng quanh Đài Triệu Hồi.
--
-- Trong bán kính này dân làng coi là đất của mình: ưu tiên đánh quái lạc vào,
-- dập lửa, và mang đồ gom được cất vào rương. Ngoài bán kính thì kệ.
--
-- Mượn ý "work radius" của GrimWorld (Workshop 3748676443); bán kính 40/60/80
-- cũng lấy theo họ vì ba mức đó chơi thấy hợp lý.

local nen = require("ailang/nen")

local lang = {}

function lang.DaiCuaDan(inst)
    local a = inst.ailang
    if a == nil or a.dai == nil then return nil end
    for _, e in pairs(Ents) do
        if e.GUID == a.dai and e:IsValid() then return e end
    end
    return nil
end

-- Tâm làng và bán kính. Chưa có Đài thì không có làng.
function lang.Tam(inst)
    local a = inst.ailang
    if a == nil or a.nha == nil then return nil end
    return a.nha
end

function lang.BanKinh(inst)
    local dai = lang.DaiCuaDan(inst)
    if dai ~= nil and dai.ban_kinh ~= nil then return dai.ban_kinh end
    return (rawget(_G, "AILANG_CAUHINH") or {}).ban_kinh_lang or 60
end

function lang.TrongLang(inst, x, z)
    local tam = lang.Tam(inst)
    if tam == nil then return false end
    local r = lang.BanKinh(inst)
    return (x - tam[1]) ^ 2 + (z - tam[2]) ^ 2 <= r * r
end

function lang.ThucTheTrongLang(inst, e)
    if e == nil or not e:IsValid() then return false end
    local x, _, z = e.Transform:GetWorldPosition()
    return lang.TrongLang(inst, x, z)
end

-- ── đống lửa của làng và vùng làm việc ban đêm ──────────────────────────

-- ⚠ BAN ĐÊM CHỈ LÀM VIỆC QUANH ĐỐNG LỬA. Không chốt chuyện này thì node "đêm
--   thì về bên lửa" và node làm việc GIẰNG NHAU: node làm việc nhắm bụi cỏ
--   cách nhà 40, dân làng đi ra, dây trói kéo về, rồi lại đi ra — người chơi
--   nhìn thấy nó rung qua rung lại cả đêm.
--
--   Bó vùng làm việc lại thì hết giằng, và cũng đúng cách chơi thật: trời tối
--   là về bên lửa, sáng mai làm tiếp.
local TAM_DEM = 12

function lang.LuaCuaLang(inst)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    local r = lang.BanKinh(inst)
    local gan, d_gan = nil, r * r
    for _, v in ipairs(TheSim:FindEntities(tam[1], 0, tam[2], r,
            { "campfire" }, { "INLIMBO", "burnt" })) do
        if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
            local x, _, z = v.Transform:GetWorldPosition()
            local d = (x - tam[1]) ^ 2 + (z - tam[2]) ^ 2
            if gan == nil or d < d_gan then gan, d_gan = v, d end
        end
    end
    return gan
end

-- Mục tiêu này có làm được vào lúc này không? Ban ngày thì thoải mái; ban đêm
-- mà làng có lửa thì chỉ những gì nằm sát đống lửa.
function lang.LamDuocLucNay(inst, v)
    if not TheWorld.state.isnight then return true end
    local lua = lang.LuaCuaLang(inst)
    if lua == nil then return true end      -- không có lửa thì đằng nào cũng bí
    if v == lua then return true end        -- tiếp lửa cho chính nó thì luôn được
    local lx, _, lz = lua.Transform:GetWorldPosition()
    local x, _, z = v.Transform:GetWorldPosition()
    return (x - lx) ^ 2 + (z - lz) ^ 2 <= TAM_DEM * TAM_DEM
end

-- ── lo thân trước khi giữ làng ──────────────────────────────────────────
--
-- ⚠ Nhánh "giữ làng" trong cây hành vi nằm rất cao, nên hễ nó giành được lượt
--   là mọi nhánh tự-lo bên dưới KHÔNG BAO GIỜ chạy. Đã gây hoạ BA LẦN:
--     · một con hound cách 30 làm hỏng cả năm phép kiểm về đuốc và nhặt đồ
--     · dân làng đứng đánh nhau giữa đêm khi chưa có nguồn sáng
--     · cả ba khoá cứng ở đây để đuổi MỘT CON ẾCH quanh làng giữa mùa hè,
--       nhiệt độ leo 77 -> 84 -> 87 và máu tụt 94% -> 28%, trong khi có 21 gốc
--       cây rợp bóng trong bán kính 40 ngay cạnh đó
--
--   Nên phép thử này gom hết mọi lý do "chết tại chỗ đang đứng" vào một nơi,
--   thay vì thêm từng cửa thoát một sau mỗi lần chết.
function lang.LoThanTruoc(inst, nong_tu)
    local nhu_cau = require("ailang/nhu_cau")
    -- Chưa có ánh sáng giữa đêm: đứng đánh nhau là chết.
    local as = nhu_cau.Tim("anh_sang")
    if as ~= nil then
        local ok_can, can = pcall(as.can, inst)
        local ok_du, du = pcall(as.du, inst)
        if ok_can and can and ok_du and not du then return true end
    end
    -- Đang nóng: chết vì nóng trong lúc giữ làng thì giữ được gì.
    local t = inst.components.temperature
    if t ~= nil and t:GetCurrent() >= (nong_tu or 66) then return true end
    return false
end

-- ── có nên bỏ việc mà đi trú nóng không ─────────────────────────────────
--
-- Trả về trạng thái trú nóng MỚI (true = đang trú, nil = cứ làm việc). Tự nhớ
-- trạng thái cũ trong inst.ailang.tru_nong.
--
-- ⚠ PHẢI CÓ TRỄ NGƯỠNG. Không thì dân làng RUNG quanh mốc 70 và mất máu đều:
--   vào bóng cây xong là nhánh nhả lượt NGAY, node làm việc lôi đi trước khi
--   kịp nguội, rồi lại nóng, lại quay vào. Đo được máu 85% -> 77% -> 72%
--   trong khi nhiệt lẩn quẩn 67-70.
--
-- ⚠ Mức nhả KHÔNG được đặt dưới 63: bóng cây chỉ hạ nhiệt khi đang TRÊN
--   TREE_SHADE_COOLING_THRESHOLD (63), nên đòi xuống 58 là dân làng đứng dưới
--   gốc cây tới sáng mà không bao giờ đạt.
--
-- ⚠ VÀ ĐỪNG CHẶN ĐÚNG VIỆC SẼ CHẤM DỨT TÌNH TRẠNG CẤP CỨU. Đo trên server:
--   dân làng báo lo "mát" suốt hàng chục nhịp mà số cỏ trong túi KHÔNG HỀ
--   TĂNG — cỏ ở cách 110 đơn vị, vừa rời bóng cây là nhiệt vượt 66 trong vài
--   giây, nhánh trú lôi về, nhả ở 65, đi tiếp, lại bị lôi về. Nó KHÔNG BAO GIỜ
--   đi nổi tới nơi, và cứ thế mất máu 99% -> 51%.
--
-- ⚠ Đọc nhãn của VIỆC ĐANG GIỮ (`viec.vi_sao`), đừng đọc `dang_lo`: `dang_lo`
--   bị sinh_ton.Giai ghi đè MỖI NHỊP nên tới lúc xét thì đã thành thứ khác.
function lang.CanTruNong(inst, nong_tu, da_nguoi)
    local a = inst.ailang
    local t = inst.components.temperature
    if a == nil or t == nil then return nil end

    local nhiet = t:GetCurrent()
    local lo_mat = a.viec ~= nil and a.viec.vi_sao == "mát"
    local nguong = lo_mat and (TUNING.OVERHEAT_TEMP or 70) or (nong_tu or 66)

    if nhiet >= nguong then
        a.tru_nong = true
    elseif nhiet <= (da_nguoi or 65) then
        a.tru_nong = nil
    end
    return a.tru_nong
end

-- ── kẻ địch lạc vào làng ────────────────────────────────────────────────
--
-- Đây là điểm khác với việc tự vệ thường: trong làng thì dân làng CHỦ ĐỘNG
-- đánh, kể cả con đó chưa đụng tới ai. Ngoài làng thì chỉ đánh trả.
function lang.DichTrongLang(inst)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    return FindEntity(inst, lang.BanKinh(inst), function(v)
        return v.components.health ~= nil
           and not v.components.health:IsDead()
           and v.components.combat ~= nil
           and lang.ThucTheTrongLang(inst, v)
    end, nil, { "INLIMBO", "notarget", "wall", "structure", "playerghost",
                "ailang_danlang", "player" }, { "monster", "hostile" })
end

-- ── đám cháy trong làng ─────────────────────────────────────────────────

function lang.ChayTrongLang(inst)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    return FindEntity(inst, lang.BanKinh(inst), function(v)
        return v.components.burnable ~= nil
           and v.components.burnable:IsBurning()
           and not v:HasTag("campfire")     -- lửa trại thì để yên
           and lang.ThucTheTrongLang(inst, v)
    end, { "fire" }, { "INLIMBO", "burnt" })
end

-- ── chỗ cất đồ trong làng ───────────────────────────────────────────────

function lang.RuongTrongLang(inst, mon)
    local tam = lang.Tam(inst)
    if tam == nil then return nil end
    return FindEntity(inst, lang.BanKinh(inst), function(v)
        local c = v.components.container
        if c == nil or not lang.ThucTheTrongLang(inst, v) then return false end
        if c:IsFull() then return false end
        return mon == nil or c:CanTakeItemInSlot(mon)
    end, { "structure" }, { "INLIMBO", "burnt", "fire" })
end

return lang

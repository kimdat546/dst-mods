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

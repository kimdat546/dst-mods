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

-- Ban đêm mà nguồn sáng duy nhất là đuốc CẦM TAY thì không làm việc nặng:
-- cầm rìu lên là mất sáng. Có đèn đội đầu thì rảnh tay, làm bình thường.
local function KhongRanhTay(inst)
    if not TheWorld.state.isnight then return false end
    local tui = inst.components.inventory
    if tui == nil then return false end
    return nhu_cau.MonPhatSang(tui:GetEquippedItem(EQUIPSLOTS.HANDS))
end

-- ── tìm việc mặc định (khi không còn nhu cầu nào) ───────────────────────

local function Tim(inst, musttag, loc_them)
    return FindEntity(inst, TAM_NHIN, function(v)
        if viec.DangBoQua(inst, v) then return false end
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

local function ViecHai(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local cay = Tim(inst, "pickable", function(v)
        return v.components.pickable ~= nil
           and v.components.pickable:CanBePicked()
           and v.components.pickable.caninteractwith ~= false
    end)
    if cay == nil then return nil end
    return { muc_tieu = cay, hanh_dong = ACTIONS.PICK, vi_sao = "hái lượm" }
end

local function ViecLamViec(inst, hanh_dong, tag, nhan)
    if KhongRanhTay(inst) then return nil end
    if not CamDungCu(inst, hanh_dong) then return nil end
    local muc = Tim(inst, tag, function(v)
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == hanh_dong
    end)
    if muc == nil then return nil end
    return { muc_tieu = muc, hanh_dong = hanh_dong, vi_sao = nhan }
end

-- ── nhận việc ───────────────────────────────────────────────────────────

-- Nhu cầu trước, việc thường sau. sinh_ton trả về "xong" khi nó vừa làm một
-- việc tức thì (mặc/chế), lúc đó chưa cần đi đâu cả.
function viec.NhanViec(inst)
    local kq = sinh_ton.Giai(inst)
    if kq == "xong" then return nil end
    if kq ~= nil and kq.action ~= nil then
        return {
            muc_tieu  = kq.target,
            hanh_dong = kq.action,
            mon       = kq.invobject,
            vi_sao    = inst.ailang.dang_lo or "nhu cầu",
        }
    end

    return ViecNhat(inst)
        or ViecHai(inst)
        or ViecLamViec(inst, ACTIONS.CHOP, "CHOP_workable", "chặt cây")
        or ViecLamViec(inst, ACTIONS.MINE, "MINE_workable", "đào đá")
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

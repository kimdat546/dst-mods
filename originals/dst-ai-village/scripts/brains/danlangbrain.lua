-- Não phản xạ của dân làng — behaviour tree thuần Lua, chạy trong tiến trình.
--
-- Tầng này KHÔNG bao giờ gọi ra ngoài. Mất mạng, tắt dịch vụ suy nghĩ, hết
-- quota Gemini — dân làng vẫn sống và làm việc bình thường. Tầng suy nghĩ chỉ
-- ĐẶT MỤC TIÊU (inst.ailang.muc_tieu), còn thực thi luôn là cây này.
--
-- Vì sao không đi HTTP mỗi nhịp như hai mod cũ: đã đo trên DST hiện tại,
-- TheSim:QueryServer không gọi callback cho URL ngoài Klei — cả server offline
-- lẫn server online. Kiến trúc "mỗi tick một HTTP round-trip" của chúng không
-- còn chạy được nữa. Xem README.

require("behaviours/wander")
require("behaviours/follow")
require("behaviours/doaction")
require("behaviours/panic")
require("behaviours/chaseandattack")
require("behaviours/runaway")

local nen = require("ailang/nen")

local TAM_NHIN      = 20    -- bán kính nhìn quanh mình
local TAM_VE_NHA    = 30    -- lang thang quanh nhà trong bán kính này
local THEO_GAN      = 3
local THEO_VUA      = 6
local THEO_XA       = 12
local MAU_SO        = 0.35  -- dưới ngưỡng này thì bỏ chạy
local DOI_THI_AN    = 0.5

-- ⚠ Brain._ctor KHÔNG nhận inst — phải gán tay, đúng như mọi brain vanilla.
--   Truyền inst vào _ctor thì self.inst = nil, và lỗi chỉ nổ muộn ở tận trong
--   behaviours/chaseandattack.lua chứ không nổ ngay chỗ sai.
local DanLangBrain = Class(Brain, function(self, inst)
    Brain._ctor(self)
    self.inst = inst
end)

-- ── tiện ích ────────────────────────────────────────────────────────────

local function ViTriNha(inst)
    local nha = inst.ailang ~= nil and inst.ailang.nha or nil
    if nha ~= nil then return Vector3(nha[1], 0, nha[2]) end
    return nil
end

local function MauThap(inst)
    local h = inst.components.health
    return h ~= nil and h:GetPercent() < MAU_SO
end

local function DangDoi(inst)
    local h = inst.components.hunger
    return h ~= nil and h:GetPercent() < DOI_THI_AN
end

local function NguoiChoiGanNhat(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local gan, d_gan = nil, math.huge
    for _, p in ipairs(AllPlayers) do
        if p:IsValid() and p.entity:IsVisible() then
            local d = inst:GetDistanceSqToInst(p)
            if d < d_gan then gan, d_gan = p, d end
        end
    end
    return gan
end

-- ── bỏ qua mục tiêu cứng đầu ────────────────────────────────────────────
--
-- ⚠ Người chơi báo dân làng "nhặt mãi nhưng không được" ở chỗ nấm chưa mọc.
--   Nguyên nhân đã đo được: `pickable:CanBePicked()` trả TRUE cho nấm chưa
--   tới giờ mọc. Lúc hoàng hôn, nấm đỏ và nấm lam đều cho
--   CanBePicked=true nhưng caninteractwith=FALSE — mà chính caninteractwith
--   mới là thứ chặn hành động. Cây hành vi vì thế chọn lại đúng con nấm đó
--   mỗi nhịp, mãi mãi.
--
--   Sửa gốc: lọc theo TAG thay vì gọi CanBePicked. Tag bám sát trạng thái
--   thật và cũng chính là thứ game dùng để hiện nút hành động cho người chơi:
--     "pickable"       hái được ngay bây giờ  (mất tag khi chưa tới giờ mọc)
--     "CHOP_workable"  chặt được
--     "MINE_workable"  đào được
--     "_inventoryitem" nhặt được
--
--   Nhưng vẫn giữ thêm lưới này cho MỌI trường hợp còn lại — mục tiêu không
--   đi tới được, bị vật cản chắn, bị mod khác khoá. Đeo bám quá lâu thì ghi
--   sổ đen một lúc rồi làm việc khác.

local KIEN_NHAN   = 10    -- giây, đeo bám một mục tiêu tối đa bấy nhiêu
local BO_QUA_GIAY = 120   -- giây, ghi sổ đen bấy nhiêu lâu

local function So(inst)
    local a = inst.ailang
    if a.bo_qua == nil then a.bo_qua = {} end
    return a
end

local function DangBoQua(inst, e)
    local a = So(inst)
    local het = a.bo_qua[e.GUID]
    if het == nil then return false end
    if GetTime() > het then a.bo_qua[e.GUID] = nil return false end
    return true
end

-- Gọi mỗi lần chọn được mục tiêu. Trả false nếu đã đeo bám quá lâu.
local function ConKienNhan(inst, e)
    local a = So(inst)
    if a.dang_duoi ~= e.GUID then
        a.dang_duoi = e.GUID
        a.duoi_tu = GetTime()
        return true
    end
    if GetTime() - (a.duoi_tu or 0) > KIEN_NHAN then
        a.bo_qua[e.GUID] = GetTime() + BO_QUA_GIAY
        a.dang_duoi = nil
        nen.chitiet(tostring(a.ten), "bỏ qua mục tiêu cứng đầu",
                    tostring(e.prefab), e.GUID)
        return false
    end
    return true
end

local KHONG_LAY = { "INLIMBO", "NOCLICK", "FX", "fire", "burnt", "catchable" }

local function Tim(inst, musttag, loc_them)
    local e = FindEntity(inst, TAM_NHIN, function(v)
        if DangBoQua(inst, v) then return false end
        return loc_them == nil or loc_them(v)
    end, { musttag }, KHONG_LAY)
    if e == nil then return nil end
    if not ConKienNhan(inst, e) then return nil end
    return e
end

-- ── hành động ───────────────────────────────────────────────────────────

-- Ăn khi đói: tìm món ăn được trong túi.
local function HanhDongAn(inst)
    if not DangDoi(inst) then return nil end
    local tui = inst.components.inventory
    local an  = inst.components.eater
    if tui == nil or an == nil then return nil end
    for _, mon in pairs(tui.itemslots or {}) do
        if mon ~= nil and an:CanEat(mon) then
            return BufferedAction(inst, mon, ACTIONS.EAT)
        end
    end
    return nil
end

-- Nhặt đồ rơi dưới đất.
local function HanhDongNhat(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local mon = Tim(inst, "_inventoryitem", function(v)
        return v.components.inventoryitem ~= nil
           and v.components.inventoryitem.canbepickedup
           and v:IsOnValidGround()
           and not v:IsInLimbo()
    end)
    if mon == nil then return nil end
    return BufferedAction(inst, mon, ACTIONS.PICKUP)
end

-- Hái: quả mọng, cà rốt, cành cây, cỏ, nấm ĐÃ MỌC.
local function HanhDongHai(inst)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end
    local cay = Tim(inst, "pickable", function(v)
        return v.components.pickable ~= nil
           and v.components.pickable:CanBePicked()
           and v.components.pickable.caninteractwith ~= false
    end)
    if cay == nil then return nil end
    return BufferedAction(inst, cay, ACTIONS.PICK)
end

-- Chặt cây — chỉ khi đang cầm rìu, hoặc có rìu trong túi thì cầm lên trước.
local function CamDungCu(inst, hanh_dong)
    local tui = inst.components.inventory
    if tui == nil then return false end
    local dang_cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if dang_cam ~= nil and dang_cam.components.tool ~= nil
       and dang_cam.components.tool:CanDoAction(hanh_dong) then
        return true
    end
    for _, mon in pairs(tui.itemslots or {}) do
        if mon ~= nil and mon.components.tool ~= nil
           and mon.components.tool:CanDoAction(hanh_dong) then
            tui:Equip(mon)
            return true
        end
    end
    return false
end

local function LamViec(inst, hanh_dong, tag)
    if not CamDungCu(inst, hanh_dong) then return nil end
    local muc = Tim(inst, tag, function(v)
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == hanh_dong
    end)
    if muc == nil then return nil end
    return BufferedAction(inst, muc, hanh_dong)
end

local function HanhDongChat(inst) return LamViec(inst, ACTIONS.CHOP, "CHOP_workable") end
local function HanhDongDao(inst)  return LamViec(inst, ACTIONS.MINE, "MINE_workable") end

-- Mục tiêu do tầng suy nghĩ đặt vào. Không có thì trả nil để cây đi tiếp
-- xuống các nhánh mặc định.
local BANG_MUC_TIEU = {
    CHAT  = HanhDongChat,
    DAO   = HanhDongDao,
    HAI   = HanhDongHai,
    NHAT  = HanhDongNhat,
    AN    = HanhDongAn,
}

local function HanhDongTheoMucTieu(inst)
    local mt = inst.ailang ~= nil and inst.ailang.muc_tieu or nil
    if mt == nil then return nil end
    local fn = BANG_MUC_TIEU[mt]
    if fn == nil then return nil end
    return fn(inst)
end

-- ── cây ─────────────────────────────────────────────────────────────────

function DanLangBrain:OnStart()
    local inst = self.inst

    local goc = PriorityNode(
    {
        WhileNode(function() return inst.components.health.takingfiredamage end,
            "Cháy", Panic(inst)),

        WhileNode(function() return MauThap(inst) end,
            "Máu thấp",
            RunAway(inst, { tags = { "_combat", "_health" },
                            notags = { "player", "wall", "INLIMBO" } }, 8, 14)),

        ChaseAndAttack(inst, 10),

        IfNode(function() return DangDoi(inst) end, "Đói",
            DoAction(inst, HanhDongAn, "ăn", true)),

        DoAction(inst, HanhDongTheoMucTieu, "mục tiêu", true),

        DoAction(inst, HanhDongNhat, "nhặt", true),
        DoAction(inst, HanhDongHai,  "hái",  true),
        DoAction(inst, HanhDongChat, "chặt", true),

        IfNode(function() return ViTriNha(inst) == nil end, "Chưa có nhà",
            Follow(inst, NguoiChoiGanNhat, THEO_GAN, THEO_VUA, THEO_XA)),

        Wander(inst, function() return ViTriNha(inst) end, TAM_VE_NHA),
    }, 0.5)

    self.bt = BT(inst, goc)
    nen.chitiet("não khởi động cho", tostring(inst.ailang and inst.ailang.ten))
end

return DanLangBrain

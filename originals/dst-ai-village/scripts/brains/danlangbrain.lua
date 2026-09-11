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
require("behaviours/leash")
require("behaviours/standstill")

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")

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


-- ── hồn ma ──────────────────────────────────────────────────────────────

local TIM_BIA   = 60   -- bán kính tìm chỗ hồi sinh, rộng hơn tầm nhìn thường
local GAN_BIA   = 3    -- tới trong khoảng này thì hồi sinh

local function BiaGanNhat(inst)
    return FindEntity(inst, TIM_BIA, function(v)
        return not v:IsInLimbo()
    end, { "resurrector" }, { "INLIMBO", "burnt" })
end

local function ViTriBia(inst)
    local b = BiaGanNhat(inst)
    if b == nil then return nil end
    local x, _, z = b.Transform:GetWorldPosition()
    return Vector3(x, 0, z)
end

-- Tới nơi rồi thì hồi sinh. Dây chuyền hồi sinh nằm dưới đất thì dùng luôn
-- và mất đi — đúng như khi người chơi dùng nó.
local function ThuHoiSinh(inst)
    local b = BiaGanNhat(inst)
    if b == nil then return false end
    if inst:GetDistanceSqToInst(b) > GAN_BIA * GAN_BIA then return false end

    if not dan_lang.HoiSinh(inst) then return false end

    if b.components.inventoryitem ~= nil then
        b:Remove()                       -- dây chuyền: dùng là hết
    elseif b.components.cooldown ~= nil then
        b.components.cooldown:StartCharging()   -- bia đá: vào thời gian chờ
    end
    return true
end

-- ── ánh sáng ────────────────────────────────────────────────────────────

local function TroiToi()
    return TheWorld.state.isnight or TheWorld.state.isdusk
end

local function DangCoAnhSang(inst)
    local tui = inst.components.inventory
    if tui == nil then return false end
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    return cam ~= nil and cam.components.fueled ~= nil
           and cam.components.fueled:GetPercent() > 0
           and (cam.prefab == "torch" or cam:HasTag("lighter"))
end

local function DuocTrongTui(inst)
    local tui = inst.components.inventory
    if tui == nil then return nil end
    for _, mon in pairs(tui.itemslots or {}) do
        if mon ~= nil and mon.prefab == "torch"
           and (mon.components.fueled == nil or mon.components.fueled:GetPercent() > 0) then
            return mon
        end
    end
    return nil
end

local function LuaGanNhat(inst)
    return FindEntity(inst, TIM_BIA, function(v)
        return v.components.burnable ~= nil and v.components.burnable:IsBurning()
    end, { "campfire" }, { "INLIMBO", "burnt" })
end

local function ViTriLua(inst)
    local f = LuaGanNhat(inst)
    if f == nil then return nil end
    local x, _, z = f.Transform:GetWorldPosition()
    return Vector3(x, 0, z)
end

-- Còn làm được gì để có ánh sáng không? Dùng làm điều kiện canh nhánh, nên
-- KHÔNG gây tác dụng phụ.
local function ConCachThapSang(inst)
    if DangCoAnhSang(inst) then return false end
    if DuocTrongTui(inst) ~= nil then return true end
    local b = inst.components.builder
    if b == nil then return false end
    if b:CanBuild("torch") then return true end
    if b:CanBuild("campfire") and LuaGanNhat(inst) == nil then return true end
    return false
end

local function ThapSang(inst)
    local tui = inst.components.inventory
    local duoc = DuocTrongTui(inst)
    if duoc ~= nil then
        tui:Equip(duoc)
        nen.chitiet(tostring(inst.ailang.ten), "cầm đuốc lên")
        return
    end
    local b = inst.components.builder
    if b == nil then return end
    if b:CanBuild("torch") then
        nen.thu("chế đuốc", function() b:DoBuild("torch") end)
        local moi = DuocTrongTui(inst)
        if moi ~= nil then tui:Equip(moi) end
        nen.chitiet(tostring(inst.ailang.ten), "chế đuốc")
        return
    end
    if b:CanBuild("campfire") and LuaGanNhat(inst) == nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        nen.thu("dựng lửa trại", function() b:DoBuild("campfire", Vector3(x + 1, y, z)) end)
        nen.chitiet(tostring(inst.ailang.ten), "dựng lửa trại")
    end
end

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
        -- HỒN MA — tắt hết mọi việc khác. Đã chết thì không đi hái quả nữa.
        WhileNode(function() return dan_lang.LaHonMa(inst) end, "Hồn ma",
            PriorityNode({
                IfNode(function() return ThuHoiSinh(inst) end, "Tới được chỗ hồi sinh",
                    ActionNode(function() end, "hồi sinh")),
                Leash(inst, function() return ViTriBia(inst) end, GAN_BIA, GAN_BIA - 1),
                -- Không có bia đá, không có dây chuyền: đứng yên chỗ chết chờ
                -- người chơi tới cứu, thay vì lang thang khắp bản đồ.
                StandStill(inst),
            }, 0.5)),

        WhileNode(function() return inst.components.health.takingfiredamage end,
            "Cháy", Panic(inst)),

        WhileNode(function() return MauThap(inst) end,
            "Máu thấp",
            RunAway(inst, { tags = { "_combat", "_health" },
                            notags = { "player", "wall", "INLIMBO" } }, 8, 14)),

        ChaseAndAttack(inst, 10),

        IfNode(function() return DangDoi(inst) end, "Đói",
            DoAction(inst, HanhDongAn, "ăn", true)),

        -- TRỜI TỐI — lo ánh sáng TRƯỚC khi làm gì khác. Không có sáng là chết.
        WhileNode(function() return TroiToi() end, "Trời tối",
            PriorityNode({
                IfNode(function() return ConCachThapSang(inst) end, "Thắp sáng được",
                    ActionNode(function() ThapSang(inst) end, "thắp sáng")),
                -- Hết cách tự thắp: bám lấy đống lửa gần nhất.
                WhileNode(function() return not DangCoAnhSang(inst) end, "Chưa có sáng",
                    Leash(inst, function() return ViTriLua(inst) end, 4, 3)),
            }, 0.5)),

        DoAction(inst, HanhDongTheoMucTieu, "mục tiêu", true),

        DoAction(inst, HanhDongNhat, "nhặt", true),
        DoAction(inst, HanhDongHai,  "hái",  true),
        DoAction(inst, HanhDongChat, "chặt", true),

        -- Vừa hồi sinh thì quay lại chỗ chết nhặt lại đồ của mình.
        WhileNode(function() return inst.ailang.ve_nhat_do ~= nil end, "Về nhặt đồ",
            Leash(inst, function()
                local v = inst.ailang.ve_nhat_do
                if v == nil then return nil end
                local x, _, z = inst.Transform:GetWorldPosition()
                if distsq(x, z, v[1], v[2]) < 36 then
                    inst.ailang.ve_nhat_do = nil     -- tới nơi rồi, thôi
                    return nil
                end
                return Vector3(v[1], 0, v[2])
            end, 4, 3)),

        IfNode(function() return ViTriNha(inst) == nil end, "Chưa có nhà",
            Follow(inst, NguoiChoiGanNhat, THEO_GAN, THEO_VUA, THEO_XA)),

        Wander(inst, function() return ViTriNha(inst) end, TAM_VE_NHA),
    }, 0.5)

    self.bt = BT(inst, goc)
    nen.chitiet("não khởi động cho", tostring(inst.ailang and inst.ailang.ten))
end

return DanLangBrain

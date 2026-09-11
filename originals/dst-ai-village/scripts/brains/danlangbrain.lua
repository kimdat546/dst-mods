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
require("behaviours/doaction")
require("behaviours/panic")
require("behaviours/chaseandattack")
require("behaviours/runaway")
require("behaviours/leash")
require("behaviours/standstill")

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")
local nhu_cau  = require("ailang/nhu_cau")
local sinh_ton = require("ailang/sinh_ton")

local TAM_NHIN      = 20    -- bán kính nhìn quanh mình
local TAM_VE_NHA    = 30
local VE_NHA_XA     = 50   -- xa nhà quá bấy nhiêu thì bỏ việc, về đã    -- lang thang quanh nhà trong bán kính này
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

-- Khoảng cách tới nhà. Không có nhà thì coi như đang ở nhà.
local function XaNha(inst)
    local nha = inst.ailang ~= nil and inst.ailang.nha or nil
    if nha == nil then return 0 end
    local x, _, z = inst.Transform:GetWorldPosition()
    return math.sqrt((x - nha[1]) ^ 2 + (z - nha[2]) ^ 2)
end

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

local KIEN_NHAN   = 45    -- giây, đeo bám một mục tiêu tối đa bấy nhiêu
local BO_QUA_GIAY = 120   -- giây, ghi sổ đen bấy nhiêu lâu

-- Dấu hiệu "đang có tiến triển" trên mục tiêu. Đếm ngược kiên nhẫn được ĐẶT
-- LẠI mỗi khi dấu hiệu này đổi.
--
-- ⚠ Không có phần này thì dân làng chặt vài nhát rồi bỏ sang cây khác: hạ một
--   cây thông mất hơn 10 giây, mà đếm ngược cũ là 10 giây nên nó tự ghi sổ đen
--   đúng cái cây đang chặt dở. Người chơi thấy ngay.
local function DauTienTrien(e)
    if e == nil or not e:IsValid() then return nil end
    local w = e.components.workable
    if w ~= nil then return w.workleft end
    local pk = e.components.pickable
    if pk ~= nil then return pk:CanBePicked() and 1 or 0 end
    return nil
end

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
        a.duoi_moc = DauTienTrien(e)
        return true
    end
    -- Còn đang bào mòn được mục tiêu thì kiên nhẫn lại từ đầu.
    local moc = DauTienTrien(e)
    if moc ~= nil and moc ~= a.duoi_moc then
        a.duoi_moc = moc
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
-- ⚠ ĐỪNG ăn bừa mọi thứ eater:CanEat(). Đã đo giá trị thật: red_cap máu −20,
--   green_cap não −50, blue_cap não −15, thịt sống não −10. Bản đầu ăn bất cứ
--   thứ gì nên dân làng tự đầu độc mình bằng đúng con nấm vừa hái.
--   nhu_cau.ChonMonAn chấm điểm và chỉ đụng món hại khi sắp lả.
local function HanhDongAn(inst)
    if not DangDoi(inst) then return nil end
    local mon = nhu_cau.ChonMonAn(inst)
    if mon == nil then return nil end
    return BufferedAction(inst, mon, ACTIONS.EAT)
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

-- ⚠ Bán kính tìm chỗ hồi sinh phải RẤT rộng. Đo trên server thật: cả ba dân
--   làng chết thành hồn ma, thế giới CÓ 3 chỗ hồi sinh, nhưng không chỗ nào
--   trong vòng 60 nên cả ba đứng im vĩnh viễn — làng chết hẳn. Hồn ma thì bất
--   tử và không có việc gì khác, đi xa bao nhiêu cũng được.
local TIM_BIA   = 250
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

-- Hoàng hôn thì CHUẨN BỊ, ban đêm mới CẦM LÊN.
--
-- ⚠ Bản đầu gộp cả hoàng hôn vào "trời tối" nên dân làng chế và cầm đuốc từ
--   buổi chiều — người chơi thấy ngay là vô lý. Charlie chỉ ăn người trong
--   BÓNG TỐI HẲN, mà cầm đuốc thì mất luôn tay cầm rìu. Nên hoàng hôn chỉ lo
--   CÓ đuốc trong túi, tới đêm mới cầm.
local function ChapToi()
    return TheWorld.state.isdusk or TheWorld.state.isnight
end

local function ToiHan()
    return TheWorld.state.isnight
end

-- ⚠ Không có dấu hiệu CHUNG nào cho "món này phát sáng". Đã đo:
--     torch      tag "lighter"     tay
--     lighter    tag "lighter"     tay
--     lantern    tag "light"       tay
--     minerhat   KHÔNG có tag nào  đầu
--     nightstick KHÔNG có tag nào  tay
--   Và `inst.Light` phía server là nil cho TẤT CẢ — ánh sáng là thứ client vẽ.
--   Nên phải vừa xét tag vừa có danh sách trắng, và phải xét CẢ Ô ĐẦU: người
--   chơi báo thấy một dân làng vừa đội mũ thợ mỏ vừa cầm đuốc, vì bản đầu chỉ
--   nhìn mỗi ô tay.
local PHAT_SANG = { minerhat = true, nightstick = true }

local function MonPhatSang(mon)
    if mon == nil then return false end
    if mon.components.fueled ~= nil and mon.components.fueled:GetPercent() <= 0 then
        return false
    end
    return mon:HasTag("lighter") or mon:HasTag("light") or PHAT_SANG[mon.prefab] == true
end

-- Nguồn sáng đang chiếm ô TAY — tức là không rảnh tay cầm dụng cụ.
local function DangCoAnhSangTrenTay(inst)
    local tui = inst.components.inventory
    if tui == nil then return false end
    return nhu_cau.MonPhatSang(tui:GetEquippedItem(EQUIPSLOTS.HANDS))
end

local function DangCoAnhSang(inst)
    local tui = inst.components.inventory
    if tui == nil then return false end
    for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD }) do
        if MonPhatSang(tui:GetEquippedItem(o)) then return true end
    end
    return false
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
    -- Hoàng hôn: chỉ lo CÓ đuốc, chưa cầm lên.
    if DuocTrongTui(inst) ~= nil then return ToiHan() end
    local b = inst.components.builder
    if b == nil then return false end
    if b:CanBuild("torch") then return true end
    if ToiHan() and b:CanBuild("campfire") and LuaGanNhat(inst) == nil then return true end
    return false
end

local function ThapSang(inst)
    local tui = inst.components.inventory
    local duoc = DuocTrongTui(inst)
    if duoc ~= nil then
        if ToiHan() then
            tui:Equip(duoc)
            nen.chitiet(tostring(inst.ailang.ten), "cầm đuốc lên")
        end
        return
    end
    local b = inst.components.builder
    if b == nil then return end
    if b:CanBuild("torch") then
        nen.thu("chế đuốc", function() b:DoBuild("torch") end)
        if ToiHan() then
            local moi = DuocTrongTui(inst)
            if moi ~= nil then tui:Equip(moi) end
        else
            -- ⚠ builder:DoBuild TỰ TRANG BỊ món vừa chế khi tay đang trống —
            --   đó là hành vi sẵn có của DST, không phải mã ở đây. Nên ở hoàng
            --   hôn phải CỞI RA cất đi, không thì dân làng cầm đuốc từ buổi
            --   chiều và mất tay cầm rìu. Người chơi báo đúng chỗ này.
            local tay = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
            if tay ~= nil and tay.prefab == "torch" then
                local go = tui:Unequip(EQUIPSLOTS.HANDS)
                if go ~= nil then tui:GiveItem(go) end
            end
        end
        nen.chitiet(tostring(inst.ailang.ten),
                    ToiHan() and "chế đuốc và cầm lên" or "chế sẵn đuốc để dành")
        return
    end
    if ToiHan() and b:CanBuild("campfire") and LuaGanNhat(inst) == nil then
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

        -- SINH TỒN — bảng nhu cầu có thứ tự: ánh sáng > đồ ăn > hồi máu >
        -- hồi não > vũ khí > giáp > nhà. Xem scripts/ailang/nhu_cau.lua.
        -- Việc tức thì (mặc/chế) làm ngay; việc cần đi (hái/chặt/đào) trả về
        -- hành động cho DoAction chạy.
        IfNode(function() return sinh_ton.Giai(inst) == "xong" end,
            "Vừa lo xong một nhu cầu", ActionNode(function() end, "xong")),
        DoAction(inst, function() 
            local kq = sinh_ton.Giai(inst)
            return kq ~= "xong" and kq or nil
        end, "lo sinh tồn", true),

        -- Tối hẳn mà vẫn chưa có sáng: bám lấy đống lửa gần nhất.
        WhileNode(function() return ToiHan() and not DangCoAnhSang(inst) end,
                  "Đêm mà chưa có sáng",
            Leash(inst, function() return ViTriLua(inst) end, 4, 3)),

        -- ⚠ VỀ NHÀ khi đã đi quá xa. Không có nhánh này thì dân làng TRÔI VÔ
        --   HẠN: mỗi lần đi kiếm nguyên liệu lại dời đi một đoạn, rồi từ chỗ
        --   mới tìm tiếp, cứ thế xa dần. Đo trên server thật: cả ba chết ở
        --   cách nhà 95, 155 và 235 đơn vị — lang thang vào chỗ nguy hiểm,
        --   không lửa, không đường lui.
        WhileNode(function() return XaNha(inst) > VE_NHA_XA end, "Đi quá xa nhà",
            Leash(inst, function() return ViTriNha(inst) end, TAM_VE_NHA, TAM_VE_NHA - 10)),

        DoAction(inst, HanhDongTheoMucTieu, "mục tiêu", true),

        DoAction(inst, HanhDongNhat, "nhặt", true),
        DoAction(inst, HanhDongHai,  "hái",  true),

        -- ⚠ Ban đêm mà nguồn sáng duy nhất là ĐUỐC CẦM TAY thì ĐỪNG chặt/đào.
        --   Người chơi bắt được: một Wilson "vừa thay đổi giữa rìu và đuốc
        --   liên tục để chặt cây". Nhánh chặt cầm rìu lên, nhánh ánh sáng thấy
        --   mất sáng nên cầm đuốc lại, lặp vô tận. Ban đêm lo sống đã, việc
        --   nặng để mai — trừ khi có đèn đội đầu thì rảnh tay.
        WhileNode(function()
            return not (ToiHan() and DangCoAnhSangTrenTay(inst))
        end, "Không phải đang cầm đuốc giữa đêm",
            PriorityNode({
                DoAction(inst, HanhDongChat, "chặt", true),
                DoAction(inst, HanhDongDao,  "đào",  true),
            }, 0.5)),

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

        -- Dân làng quanh quẩn NHÀ của mình, KHÔNG bám theo người chơi.
        -- Nhà mặc định là chỗ nó được sinh ra (đặt trong dan_lang.Sinh), đổi
        -- bằng c_ailang_datnha().
        Wander(inst, function() return ViTriNha(inst) end, TAM_VE_NHA),
    }, 0.5)

    self.bt = BT(inst, goc)
    nen.chitiet("não khởi động cho", tostring(inst.ailang and inst.ailang.ten))
end

return DanLangBrain

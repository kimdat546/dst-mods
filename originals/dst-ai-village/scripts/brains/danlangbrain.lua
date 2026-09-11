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
require("behaviours/follow")

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")
local nhu_cau  = require("ailang/nhu_cau")
local sinh_ton = require("ailang/sinh_ton")
local than_thiet = require("ailang/than_thiet")
local viec = require("ailang/viec")

local TAM_NHIN      = 20    -- bán kính nhìn quanh mình
local TAM_VE_NHA    = 30
local VE_NHA_XA     = 50   -- xa nhà quá bấy nhiêu thì bỏ việc, về đã
local THEO_GAN      = 3
local THEO_VUA      = 6
local THEO_XA       = 12    -- lang thang quanh nhà trong bán kính này
local MAU_SO        = 0.35  -- dưới ngưỡng này thì bỏ chạy
local DOI_THI_AN    = 0.5

-- ⚠ Hai hằng số của nhánh hồn ma. Bản dọn mã chết từng xoá nhầm GAN_BIA và
--   server SẬP ngay lúc dân làng khởi động não:
--     danlangbrain.lua:206 variable 'GAN_BIA' is not declared
--   strict.lua biến biến-chưa-khai-báo thành lỗi cứng, nên đừng dọn hằng số
--   bằng cách đếm số lần xuất hiện.
local TIM_BIA       = 250   -- bán kính hồn ma tìm chỗ hồi sinh, rất rộng
local GAN_BIA       = 3     -- tới trong khoảng này thì hồi sinh

-- ⚠ Brain._ctor KHÔNG nhận inst — phải gán tay, đúng như mọi brain vanilla.
--   Truyền inst vào _ctor thì self.inst = nil, và lỗi chỉ nổ muộn ở tận trong
--   behaviours/chaseandattack.lua chứ không nổ ngay chỗ sai.
local DanLangBrain = Class(Brain, function(self, inst)
    Brain._ctor(self)
    self.inst = inst
end)

-- ── tiện ích ────────────────────────────────────────────────────────────

-- Khoảng cách tới nhà. Không có nhà thì coi như đang ở nhà.
-- Chủ đang được dân làng này đi theo. Chỉ chịu theo khi đủ thiện cảm.
local function ChuDeTheo(inst)
    local a = inst.ailang
    if a == nil or a.che_do ~= "theo_chan" then return nil end
    if not than_thiet.ChiuTheo(inst) then return nil end
    local gan, d_gan = nil, math.huge
    for _, p in ipairs(AllPlayers) do
        if p:IsValid() then
            local d = inst:GetDistanceSqToInst(p)
            if d < d_gan then gan, d_gan = p, d end
        end
    end
    return gan
end

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

-- Chỗ hồi sinh gần nhất: bia đá, tượng thịt, hoặc dây chuyền rơi dưới đất —
-- cả ba đều mang chung tag "resurrector".
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

local function DangCoAnhSang(inst)
    local tui = inst.components.inventory
    if tui == nil then return false end
    for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD }) do
        if MonPhatSang(tui:GetEquippedItem(o)) then return true end
    end
    return false
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

        -- LÀM VIỆC — MỘT node lo hết: nhu cầu sinh tồn trước, rồi nhặt /
        -- hái / chặt / đào. Xem scripts/ailang/viec.lua.
        --
        -- ⚠ Trước đây chỗ này là NĂM nhánh DoAction riêng, mà PriorityNode
        --   quyết lại từ đầu mỗi nhịp nên chúng giẫm chân nhau — người chơi
        --   thấy dân làng đổi rìu↔đuốc liên tục và chặt vài nhát rồi bỏ.
        --   Gom về một node GIỮ LẤY việc xuyên nhiều nhịp thì hết hẳn.
        --   (Mô hình mượn từ GrimWorld, Workshop 3748676443.)
        IfNode(function() return sinh_ton.Giai(inst) == "xong" end,
            "Vừa lo xong một nhu cầu tức thì", ActionNode(function() end, "xong")),

        DoAction(inst, function() return viec.HanhDong(inst) end, "làm việc", true),

        -- Tối hẳn mà vẫn chưa có sáng: bám lấy đống lửa gần nhất.
        WhileNode(function() return ToiHan() and not DangCoAnhSang(inst) end,
                  "Đêm mà chưa có sáng",
            Leash(inst, function() return ViTriLua(inst) end, 4, 3)),

        -- ĐI THEO CHỦ khi được đặt chế độ "theo chân" và đủ thiện cảm.
        -- Ở chế độ này thì bỏ qua nhánh về nhà — chủ đi đâu thì theo đó.
        WhileNode(function() return ChuDeTheo(inst) ~= nil end, "Theo chân chủ",
            Follow(inst, ChuDeTheo, THEO_GAN, THEO_VUA, THEO_XA)),

        -- ⚠ VỀ NHÀ khi đã đi quá xa. Không có nhánh này thì dân làng TRÔI VÔ
        --   HẠN: mỗi lần đi kiếm nguyên liệu lại dời đi một đoạn, rồi từ chỗ
        --   mới tìm tiếp, cứ thế xa dần. Đo trên server thật: cả ba chết ở
        --   cách nhà 95, 155 và 235 đơn vị — lang thang vào chỗ nguy hiểm,
        --   không lửa, không đường lui.
        WhileNode(function()
            return ChuDeTheo(inst) == nil and XaNha(inst) > VE_NHA_XA
        end, "Đi quá xa nhà",
            Leash(inst, function() return ViTriNha(inst) end, TAM_VE_NHA, TAM_VE_NHA - 10)),

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

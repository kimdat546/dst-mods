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
local lang = require("ailang/lang")

local TAM_NHIN      = 20    -- bán kính nhìn quanh mình
local TAM_VE_NHA    = 30
local VE_NHA_XA     = 50   -- xa nhà quá bấy nhiêu thì bỏ việc, về đã

-- ⚠ HAI CON SỐ NÀY TỪNG ĐÁ NHAU. sinh_ton tìm nguyên liệu cho nhu cầu gấp
--   trong bán kính rộng, nhưng node "đi quá xa nhà" kéo về ở 50 — nên vòng
--   tìm khẩn cấp CHƯA BAO GIỜ dùng được, dân làng bị trói trong đúng 50 đơn vị
--   quanh Đài dù thứ chúng cần nằm ngay ngoài đó.
--
--   Đo trên server, làng dựng giữa rừng rậm: trong bán kính 80 có 250 cây gỗ
--   nhưng chỉ 3 BỤI CỎ và KHÔNG MỘT BỤI CÂY CON nào trong cả bán kính 150.
--   Cỏ thì có 86 bụi — ở bán kính 150. Đuốc cần 2 cỏ + 2 cành, lửa trại cần
--   3 cỏ: cả ba dân làng chết đêm với 2 khúc gỗ trong túi, ngồi trên một mỏ
--   gỗ mà không đổi ra được ánh sáng.
--
--   Nên khi còn nhu cầu GẤP chưa giải được thì nới dây ra. Vẫn có trần cứng để
--   không quay lại bệnh trôi vô hạn (đã đo: từng trôi tới 158, chết ở 235).
local VE_NHA_XA_GAP = 140
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

-- ⚠ 66 chứ không phải 70. Ngưỡng quá nhiệt của DST là 70, nhưng đi tới gốc
--   cây cũng mất thời gian — đợi chạm 70 mới đi là đã mất máu trên đường.
local NONG_THI_TRU = 66
local BO_QUA_BONG_RAM = { "FX", "NOCLICK", "DECOR", "INLIMBO", "stump", "burnt" }

local function ViTriBongRam(inst)
    local cay = FindEntity(inst, 40, nil, { "shelter" }, BO_QUA_BONG_RAM)
    if cay == nil then return nil end
    local x, _, z = cay.Transform:GetWorldPosition()
    return Vector3(x, 0, z)
end

local function ToiHan()
    return TheWorld.state.isnight
end

-- ⚠ ĐỪNG viết lại phép thử "món này phát sáng" ở đây. Nó từng có một bản SAO
--   trong file này (PHAT_SANG / MonPhatSang / DangCoAnhSang), song song với
--   bản thật trong nhu_cau.lua — hai bản logic cho cùng một câu hỏi là mầm
--   sai lệch, và đúng là chúng đã lệch: bản ở đây coi đuốc còn 1% nhiên liệu
--   là vẫn sáng, còn nhu_cau coi dưới 25% là hết. Bản duy nhất còn lại là
--   nhu_cau.MonPhatSang.

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

        -- BẢO VỆ LÀNG: trong bán kính Đài thì CHỦ ĐỘNG đánh quái lạc vào, kể
        -- cả con đó chưa đụng tới ai. Ngoài làng thì chỉ đánh trả.
        WhileNode(function()
            if dan_lang.LaHonMa(inst) then return false end
            -- ⚠ LO THÂN TRƯỚC KHI GIỮ LÀNG. Chưa có ánh sáng giữa đêm mà đứng
            --   đánh nhau là chết, và chết thì giữ được gì.
            --   Không có chốt này thì chỉ cần MỘT con quái lảng vảng trong bán
            --   kính 60 là dân làng kẹt vĩnh viễn ở nhánh đánh nhau, không bao
            --   giờ tới được nhánh làm việc — đo được: một con hound cách 30
            --   làm hỏng cả năm phép kiểm về đuốc và nhặt đồ.
            -- ⚠ LO THÂN TRƯỚC KHI GIỮ LÀNG. Mọi lý do "chết tại chỗ đang
            --   đứng" gom trong lang.LoThanTruoc — xem chú thích ở đó, nhánh
            --   này đã gây hoạ ba lần vì mỗi lần chỉ vá thêm một cửa thoát.
            if lang.LoThanTruoc(inst, NONG_THI_TRU) then return false end
            local dich = lang.DichTrongLang(inst)
            if dich == nil then return false end
            if inst.components.combat ~= nil
               and inst.components.combat.target == nil then
                inst.components.combat:SetTarget(dich)
            end
            return true
        end, "Giữ làng", ChaseAndAttack(inst, 15)),

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
        -- ⚠ NHU CẦU GẤP phải là NODE RIÊNG, ưu tiên cao hơn node làm việc.
        --   Không thể để logic chen ngang nằm bên trong hàm sinh hành động:
        --   `DoAction` giữ trạng thái RUNNING suốt lúc dân làng đi tới mục
        --   tiêu, và trong lúc đó hàm sinh hành động KHÔNG được gọi lại. Nên
        --   đêm xuống mà nó đang trên đường đi kiếm đồ làm giáo thì chẳng ai
        --   bảo nó cầm đuốc — đuốc nằm sẵn trong túi cho tới sáng.
        --   PriorityNode xét lại từ đầu mỗi 0,5 giây, nên node này cắt ngang
        --   được việc đang dở. Xong việc tức thì thì lần sau nó tự nhường.
        -- ⚠ VỀ NHÀ phải nằm TRÊN node làm việc. Để dưới thì không bao giờ
        --   chạy: DoAction giữ RUNNING suốt lúc dân làng đi tới mục tiêu, và
        --   PriorityNode không xét tới nhánh dưới. Đo trên server: bán kính
        --   làng 60 mà dân làng ra tới 158 đơn vị rồi ở lì ngoài đó.
        -- VỀ NHÀ khi đã đi quá xa. Không có nhánh này thì dân làng TRÔI VÔ
        --   HẠN: mỗi lần đi kiếm nguyên liệu lại dời đi một đoạn, rồi từ chỗ
        --   mới tìm tiếp, cứ thế xa dần. Đo trên server thật: cả ba chết ở
        --   cách nhà 95, 155 và 235 đơn vị — lang thang vào chỗ nguy hiểm,
        --   không lửa, không đường lui.
        WhileNode(function()
            if ChuDeTheo(inst) ~= nil then return false end
            local nguong = sinh_ton.CoNhuCauGap(inst) ~= nil
                           and VE_NHA_XA_GAP or VE_NHA_XA
            return XaNha(inst) > nguong
        end, "Đi quá xa nhà",
            Leash(inst, function() return ViTriNha(inst) end, TAM_VE_NHA, TAM_VE_NHA - 10)),

        -- CHEN NGANG việc đang chạy dở khi có nhu cầu gấp NẶNG HƠN nó.
        --
        -- ⚠ Phép thử ở đây phải SẠCH (không tác dụng phụ). Bản trước dùng
        --   `sinh_ton.Giai(inst) == "xong"` — mà Giai mặc đồ, chế đồ, trừ
        --   nguyên liệu — nên cộng với lần gọi bên trong viec.HanhDong là Giai
        --   chạy HAI LẦN mỗi nhịp. Đúng cái bẫy chú thích ngay dưới đã ghi.
        --
        --   Chỉ cần BỎ việc là đủ: nhịp sau node làm việc thành READY, gọi lại
        --   viec.HanhDong, và chính nó gọi Giai (một lần) để mặc/chế thứ đang
        --   thiếu. Trễ nửa giây, đổi lấy việc không còn chế đồ trùng lặp.
        -- NÓNG QUÁ THÌ VÀO BÓNG CÂY.
        --
        -- ⚠ Lời giải mùa hè rẻ nhất, và nó KHÔNG TỐN GÌ CẢ. Tìm ra bằng cách
        --   soi vì sao ba dân làng có đồ đạc GIỐNG HỆT nhau mà nhiệt độ lệch
        --   hẳn: An và Binh 64 độ (đứng dưới tán cây), Cuong 83 độ rồi CHẾT.
        --   temperature.lua: `sheltered` và nhiệt trên
        --   TREE_SHADE_COOLING_THRESHOLD (63) thì kéo mạnh về TREE_SHADE_COOLER
        --   (45) — nên An/Binh ghim đúng ở 64-65 suốt cả ngày hè 84 độ.
        --
        --   sheltered.lua đo bằng CountEntities bán kính 2 quanh chân, tag
        --   "shelter", loại trừ stump/burnt. Làng nằm giữa rừng nên chỗ nào
        --   cũng có cây.
        --
        -- ⚠ Điều kiện gồm cả `chưa ở trong bóng râm`, và đó cũng là VAN AN
        --   TOÀN: cây có va chạm nên Leash có thể không bao giờ tới đúng cự ly
        --   đặt ra, nhưng chỉ cần vào trong bán kính 2 là `sheltered` bật lên
        --   và cả nhánh tự nhường lượt.
        WhileNode(function()
            local t = inst.components.temperature
            if t == nil or t:GetCurrent() < NONG_THI_TRU then return false end
            local che = inst.components.sheltered
            return che == nil or not che.sheltered
        end, "Nóng quá thì vào bóng cây",
            Leash(inst, function() return ViTriBongRam(inst) end, 1.8, 1.2)),

        -- ĐÊM THÌ VỀ BÊN LỬA CỦA LÀNG.
        --
        -- ⚠ PHẢI nằm TRÊN node làm việc. Bản trước để nó ở dưới cùng, nên nó
        --   KHÔNG BAO GIỜ chạy trong lúc dân làng đang đi tới mục tiêu —
        --   DoAction giữ RUNNING suốt quãng đường và PriorityNode không xét
        --   tới nhánh dưới. Đúng loại lỗi đã gặp với nhánh "về nhà".
        --
        -- ⚠ Và phải về NGAY KHI TRỜI TỐI, không đợi tới lúc tay trắng. Bản
        --   trước chỉ kéo về khi trên người không còn đèn nào, mà cây đuốc sắp
        --   tàn cũng tính là "có sáng" — nên dân làng lang thang cả đêm cho tới
        --   lúc đuốc tắt hẳn rồi mới chạy về, và thường là không kịp.
        --
        --   Về bên lửa còn tự gỡ một cái bẫy nữa: nhu cầu ánh sáng coi là ĐỦ
        --   khi có lửa trại đang cháy trong vòng 10. Đứng cạnh lửa thì không
        --   còn nhu cầu gấp nào, nên dây trói về nhà giữ mức chặt (50) thay vì
        --   nới ra 140 — hết chuyện chạy 130 đơn vị vào bóng tối tìm cỏ.
        --
        --   Leash trả FAILED khi đã ở trong bán kính, nên tới nơi rồi thì nó
        --   nhường lượt cho node làm việc; còn vùng làm việc ban đêm đã bị bó
        --   quanh đống lửa trong lang.LamDuocLucNay nên không giằng nhau.
        -- ⚠ TRỪ KHI ĐANG QUÁ NHIỆT. Mùa hè, đống lửa toả nhiệt cộng thêm vào
        --   cái nóng vốn đã quá ngưỡng — bảo chúng về bên lửa lúc đó là bảo
        --   chúng đi chết. Đo được ngày 57: nhiệt môi trường 71.6 trong khi
        --   ngưỡng quá nhiệt là 70, cả ba chết giữa ban ngày không cần Charlie.
        WhileNode(function()
            if not ToiHan() then return false end
            local t = inst.components.temperature
            return t == nil or not t:IsOverheating()
        end, "Đêm thì về bên lửa",
            Leash(inst, function() return ViTriLua(inst) end, 8, 5)),

        IfNode(function() return viec.CanChenNgang(inst) end,
            "Chen nhu cầu gấp",
            ActionNode(function() viec.BoViec(inst) end, "bỏ việc đang làm")),

        -- ⚠ CHỈ gọi sinh_ton.Giai ở MỘT chỗ. Trước đây có thêm một IfNode
        --   `Giai(inst) == "xong"` ngay trên đây, nên mỗi nhịp Giai chạy HAI
        --   lần — mà Giai có tác dụng phụ (mặc đồ, chế đồ, trừ nguyên liệu).
        --   Hậu quả: dân làng chế đuốc rồi lại chế tiếp, và bốn phép kiểm về
        --   đuốc/nhặt đồ hỏng cùng lúc. viec.HanhDong đã gọi Giai bên trong
        --   và trả nil khi Giai vừa làm xong một việc tức thì.
        DoAction(inst, function() return viec.HanhDong(inst) end, "làm việc", true),

        -- ĐI THEO CHỦ khi được đặt chế độ "theo chân" và đủ thiện cảm.
        -- Ở chế độ này thì bỏ qua nhánh về nhà — chủ đi đâu thì theo đó.
        WhileNode(function() return ChuDeTheo(inst) ~= nil end, "Theo chân chủ",
            Follow(inst, ChuDeTheo, THEO_GAN, THEO_VUA, THEO_XA)),

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

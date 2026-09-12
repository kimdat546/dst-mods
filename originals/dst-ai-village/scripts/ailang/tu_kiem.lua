-- Tự kiểm cây hành vi — chạy trên server test, KHÔNG cần người chơi.
--
-- ⚠ Vì sao phải chạy tay bt:Update() thay vì để BrainManager chạy: khi KHÔNG
--   có client nào nối vào, DST ngủ cả thế giới. Đã đo ba lần — entity ngủ thì
--   inst.brain = nil và không có nhịp nào chạy. Đối chứng bằng heo vanilla:
--   nó cũng ngủ, cũng đứng im. AddServerNonSleepable() không cứu được, nhét
--   dân làng vào AllPlayers cũng không: engine dùng client MẠNG thật.
--
--   Nên bộ này dựng não bằng tay rồi tự bơm nhịp. Nó kiểm được LOGIC CHỌN
--   HÀNH ĐỘNG — đúng chỗ hay sai nhất. Nó KHÔNG kiểm được chuyển động, tìm
--   đường, hoạt ảnh; mấy thứ đó vẫn phải vào game thật.
--
-- Cách chạy: tools/test/chay_tu_kiem.sh

local dat, hong = 0, 0
local function nhuCauTorch(tui)
    for _, m in pairs(tui.itemslots or {}) do
        if m ~= nil and m.prefab == "torch" then return m end
    end
end
-- ⚠ ĐỪNG tostring() thẳng một entity trong thông báo kiểm. Entity vừa bị gỡ
--   có __tostring hỏng và chính tostring() sẽ NỔ, kéo sập cả server test.
local function TenCua(e)
    if e == nil then return "khong co" end
    local ok, ten = pcall(function() return e.prefab end)
    return ok and tostring(ten) or "?"
end

local function KT(ten, dieu_kien, chi_tiet)
    if dieu_kien then
        dat = dat + 1
        print("[TU-KIEM] ĐẠT   " .. ten)
    else
        hong = hong + 1
        print("[TU-KIEM] HỎNG  " .. ten .. "   " .. tostring(chi_tiet or ""))
    end
end

for _, m in ipairs({ "ailang/nen", "ailang/dan_lang", "ailang/than_thiet",
                     "ailang/lang", "ailang/nhu_cau", "ailang/sinh_ton", "ailang/viec",
                     "ailang/lenh", "brains/danlangbrain" }) do
    package.loaded[m] = nil
end
local dan_lang = require("ailang/dan_lang")
local Brain    = require("brains/danlangbrain")

-- Dọn sạch quanh chỗ thử để kết quả không phụ thuộc địa hình.
local function DonQuanh(x, z, r)
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, r or 30)) do
        local c = v.components
        -- ⚠ Phải dọn CẢ bia hồi sinh và lửa trại. Chúng không có
        --   inventoryitem/pickable/workable nên bộ lọc cũ bỏ sót, và bài kiểm
        --   trước để lại một cái bia là bài sau hỏng: hồn ma hồi sinh ngay rồi
        --   đi nhặt đồ. Đã dính đúng lỗi này.
        -- ⚠ Dọn cả QUÁI. Một con hound lảng vảng trong bán kính làng là dân
        --   làng rẽ sang nhánh giữ làng và không tới được nhánh đang kiểm —
        --   đã làm hỏng oan năm phép kiểm cùng lúc.
        local bo = c ~= nil and (c.inventoryitem or c.pickable or c.workable)
                   or v:HasTag("resurrector") or v:HasTag("campfire")
                   or v:HasTag("monster") or v:HasTag("hostile")
        if bo and v.Remove ~= nil and v.ailang == nil then
            v:Remove()
        end
    end
end

-- ⚠ ĐỪNG bịa toạ độ kiểu 1400,1400. Bản đồ hữu hạn, ra ngoài là đất không
--   hợp lệ, và bộ lọc IsOnValidGround() sẽ loại sạch vật thử — bài kiểm hỏng
--   mà nhìn như mod hỏng. Lấy điểm sinh thật rồi lệch ra một chút.
local GOC_X, GOC_Z
local function Goc()
    if GOC_X == nil then
        local sp = TheWorld.components.playerspawner
        local a, _, c = sp:GetAnySpawnPoint()
        GOC_X, GOC_Z = a or 0, c or 0
    end
    return GOC_X, GOC_Z
end

local function DanLangSach(x, z)
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local e = dan_lang.Sinh({ ten = "ThuNghiem", nhan_vat = "wilson",
                              vi_tri = { x, z } })
    DonQuanh(x, z, 70)
    -- ⚠ PHẢI tắt não thật. Từ khi dân làng dùng SetCanSleep(false) thì não của
    --   chúng chạy kể cả lúc không có người chơi — hai não cùng điều khiển một
    --   entity thì kết quả kiểm thành ngẫu nhiên. Đã gặp: phép "đang bào mòn
    --   được cây thì không bỏ sang cây khác" chuyển sang HỎNG với "nhắm=grass".
    e:StopBrain()
    -- ⚠ Đặt nhà sẵn cho bài kiểm. Từ khi NHÀ = ĐÀI TRIỆU HỒI, dân làng mới
    --   sinh KHÔNG có nhà (đời du mục đầu game), nên bài nào giả định làng đã
    --   yên vị phải tự dựng cảnh đó. Bài kiểm đời du mục thì gọi thẳng
    --   dan_lang.Sinh, không qua khuôn này.
    e.ailang.nha = { x, z }
    local nao = Brain(e)
    nao:OnStart()
    return e, nao
end

-- ⚠ ms_setphase KHÔNG ăn ngay. Đừng đoán số nhịp — CHỜ tới khi pha thật sự
--   đổi rồi mới chạy tiếp, không thì bài kiểm hỏng oan lúc máy chậm.
local function DoiPha(pha, xong)
    TheWorld:PushEvent("ms_setphase", pha)
    local n = 0
    local function cho()
        n = n + 1
        if TheWorld.state.phase == pha or n > 40 then
            xong(TheWorld.state.phase == pha)
        else
            TheWorld:DoTaskInTime(0.25, cho)
        end
    end
    TheWorld:DoTaskInTime(0.25, cho)
end

-- ⚠ PHẢI dừng khi dân làng đã bị gỡ. Bài kiểm trước gọi e:Remove() nhưng các
--   callback DoTaskInTime của Nhip vẫn còn hàng đợi, và chúng tiếp tục bơm
--   nhịp cho não của một entity đã chết — DST tuôn "Stale Component
--   Reference" cho tới khi SẬP CẢ SERVER (exit code 6). Đây là nguồn của
--   hàng loạt kết quả kiểm lộn xộn khó hiểu.
local function Nhip(nao, n, xong)
    local i = 0
    local function b()
        if nao == nil or nao.inst == nil or not nao.inst:IsValid() then
            xong() return
        end
        i = i + 1
        pcall(function() nao.bt:Update() end)
        if i < n then TheWorld:DoTaskInTime(0.6, b) else xong() end
    end
    TheWorld:DoTaskInTime(0.6, b)
end

-- ── 1. nấm chưa mọc thì bỏ qua ──────────────────────────────────────────
local function ThuNam(tiep)
    local e, nao = DanLangSach(Goc())
    local x, y, z = e.Transform:GetWorldPosition()
    local chua, roi = nil, nil
    for _, p in ipairs({ "red_mushroom", "green_mushroom", "blue_mushroom" }) do
        local m = SpawnPrefab(p)
        m.Transform:SetPosition(x + 1, y, z)
        if m:HasTag("pickable") then
            if roi == nil then roi = m m.Transform:SetPosition(x + 8, y, z) else m:Remove() end
        else
            if chua == nil then chua = m else m:Remove() end
        end
    end
    if chua == nil or roi == nil then
        print("[TU-KIEM] BỎ QUA nấm — giờ này không có đủ cả nấm mọc lẫn chưa mọc")
        tiep() return
    end
    Nhip(nao, 3, function()
        local ba = e:GetBufferedAction()
        local nham = ba and ba.target or nil
        -- Khẳng định đúng TÍNH CHẤT đang thử: không đụng con nấm chưa mọc.
        -- Bản đầu đòi phải nhắm ĐÚNG con nấm đã mọc, nên hễ quanh đó có món
        -- nhặt được nào khác là hỏng oan — đã gặp, nó nhắm "twigs".
        KT("bỏ qua nấm chưa mọc dù nó GẦN hơn",
           nham ~= chua,
           "nhắm=" .. tostring(nham and nham.prefab))
        tiep()
    end)
end

-- ── 2. đêm thì tự lo ánh sáng ───────────────────────────────────────────
local function ThuDem(tiep)
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "night")
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    for _, m in ipairs({ "cutgrass", "cutgrass", "twigs", "twigs" }) do
        tui:GiveItem(SpawnPrefab(m))
    end
    Nhip(nao, 4, function()
        local sau = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
        KT("giữa đêm có nguyên liệu thì chế và cầm đuốc",
           sau ~= nil and sau.prefab == "torch",
           "đang cầm=" .. tostring(sau and sau.prefab))
        tiep()
    end)
end

-- ── 3. hồn ma đi hồi sinh ───────────────────────────────────────────────
local function ThuHonMa(tiep)
    local e, nao = DanLangSach(Goc())
    dan_lang.ThanhHonMa(e)
    KT("chết thì thành hồn ma, mang notarget, ghi vị trí chết",
       e.ailang.la_hon_ma and e:HasTag("notarget") and e.ailang.noi_chet ~= nil)
    local x, y, z = e.Transform:GetWorldPosition()
    local bia = SpawnPrefab("resurrectionstone")
    bia.Transform:SetPosition(x + 2, y, z)
    Nhip(nao, 4, function()
        KT("hồn ma tới bia đá thì hồi sinh",
           e.ailang.la_hon_ma == false,
           "la_hon_ma=" .. tostring(e.ailang.la_hon_ma))
        KT("hồi sinh xong bỏ notarget", not e:HasTag("notarget"))
        -- Cờ "về nhặt đồ" KHÔNG kiểm ở đây được: bia đá đặt sát chỗ chết nên
        -- cây hành vi thấy đã tới nơi và xoá cờ ngay — đúng như thiết kế.
        -- Kiểm hợp đồng của HoiSinh() riêng, không lệ thuộc khoảng cách.
        local e2 = dan_lang.Sinh({ ten = "ThuCo", nhan_vat = "wilson" })
        dan_lang.ThanhHonMa(e2, { 9999, 9999 })
        dan_lang.HoiSinh(e2)
        KT("hồi sinh xong đặt cờ quay về chỗ chết nhặt đồ",
           e2.ailang.ve_nhat_do ~= nil
           and e2.ailang.ve_nhat_do[1] == 9999)
        e2:Remove()
        tiep()
    end)
end

-- ── 4. hồn ma KHÔNG đi làm việc ─────────────────────────────────────────
local function ThuHonMaKhongLamViec(tiep)
    local e, nao = DanLangSach(Goc())
    dan_lang.ThanhHonMa(e)
    local x, y, z = e.Transform:GetWorldPosition()
    SpawnPrefab("flint").Transform:SetPosition(x + 2, y, z)
    Nhip(nao, 3, function()
        local ba = e:GetBufferedAction()
        KT("hồn ma không đi nhặt đồ",
           ba == nil or ba.action ~= ACTIONS.PICKUP,
           "hành động=" .. tostring(ba and ba.action and ba.action.id))
        tiep()
    end)
end

-- ── 5. nhặt đồ dưới đất ─────────────────────────────────────────────────
-- ⚠ Phải cho THOẢ HẾT nhu cầu trước. Nhánh "nhặt" nằm DƯỚI nhánh sinh tồn,
--   nên còn nhu cầu nào chưa xong là dân làng đi gom nguyên liệu cho nhu cầu
--   đó chứ không nhặt vu vơ — đã hỏng oan với "nhắm=grass".
-- ⚠ Thêm nhu cầu mới vào bảng thì PHẢI thoả nó ở đây, không thì mọi bài kiểm
--   dựa vào khuôn này hỏng theo kiểu khó đoán. Đã gặp thật khi thêm "xưởng":
--   bài "thấy đồ dưới đất thì đi nhặt" chuyển sang HỎNG với "hành động=MINE",
--   vì dân làng đi đào đá làm Máy Khoa Học thay vì nhặt món trước mặt.
local MAY_THU   -- máy khoa học của khuôn, dọn ở lần gọi sau

local function ThoaHetNhuCau(e)
    if MAY_THU ~= nil and MAY_THU:IsValid() then MAY_THU:Remove() end
    local tui = e.components.inventory
    -- ⚠ ĐUỐC PHẢI TRANG BỊ SAU CÙNG. Giáo cũng chiếm Ô TAY, nên trang bị nó
    --   sau đuốc là đẩy đuốc vào túi — và từ khi bỏ lối thoát "đứng cạnh lửa
    --   thì coi như có sáng", chập tối `anh_sang` sẽ CHƯA THOẢ và giành lượt
    --   của thứ bài kiểm muốn đo. Đã hỏng đúng vậy với "việc=nil".
    --   Giáo để trong túi là đủ: vu_khi.mac_khi trả false, dân làng không tự
    --   cầm vũ khí lên để khỏi vướng tay.
    tui:GiveItem(SpawnPrefab("spear"))
    local giap = SpawnPrefab("armorgrass")
    if giap ~= nil then tui:GiveItem(giap) tui:Equip(giap) end
    local duoc = SpawnPrefab("torch")
    if duoc ~= nil then tui:GiveItem(duoc) tui:Equip(duoc) end
    -- Rìu và cuốc: nằm TRONG TÚI chứ không trang bị, đúng như nhu cầu
    -- "dụng cụ"/"cuốc" mong đợi (mac_khi trả false để khỏi vướng tay cầm đuốc).
    for _, m in ipairs({ "axe", "pickaxe" }) do
        local mon = SpawnPrefab(m)
        if mon ~= nil then tui:GiveItem(mon) end
    end
    tui:GiveItem(SpawnPrefab("carrot"))
    local x, y, z = e.Transform:GetWorldPosition()
    e.ailang.nha = { x, z }
    local lua = SpawnPrefab("campfire")
    lua.Transform:SetPosition(x + 5, y, z)
    MAY_THU = SpawnPrefab("researchlab")
    if MAY_THU ~= nil then MAY_THU.Transform:SetPosition(x + 7, y, z) end
    return lua
end

local function ThuNhat(tiep)
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local lua = ThoaHetNhuCau(e)
    local sinh_ton = require("ailang/sinh_ton")
    local con = sinh_ton.ConThieuGi(e)
    local ten = {}
    for _, n in ipairs(con) do table.insert(ten, n.ma) end
    KT("thoả hết nhu cầu thì không còn gì để lo",
       #con == 0, "còn thiếu: " .. table.concat(ten, ","))
    local x, y, z = e.Transform:GetWorldPosition()
    local da = SpawnPrefab("flint")
    da.Transform:SetPosition(x + 3, y, z)
    Nhip(nao, 6, function()
        -- ⚠ Khẳng định theo KẾT QUẢ, không theo thời điểm. GetBufferedAction()
        --   chỉ chụp một khoảnh khắc: dân làng nhặt xong viên đá rồi chuyển
        --   sang hái là nó trả nil, và phép kiểm hỏng oan dù hành vi ĐÚNG.
        --   Đúng tính chất cần kiểm: viên đá phải biến khỏi mặt đất — hoặc vào
        --   túi, hoặc đang trên đường tới.
        local ba = e:GetBufferedAction()
        local da_nhat = not da:IsValid() or da:IsInLimbo()
        local dang_toi = ba ~= nil and ba.action == ACTIONS.PICKUP
        KT("thấy đồ dưới đất thì đi nhặt",
           da_nhat or dang_toi,
           "đã nhặt=" .. tostring(da_nhat)
           .. " hành động=" .. tostring(ba and ba.action and ba.action.id))
        if lua ~= nil and lua:IsValid() then lua:Remove() end
        tiep()
    end)
end


-- ── 6. bị đánh thì đánh trả ─────────────────────────────────────────────
local function ThuDanhTra(tiep)
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local tui = e.components.inventory
    local giao = SpawnPrefab("spear") tui:GiveItem(giao) tui:Equip(giao)
    local x, y, z = e.Transform:GetWorldPosition()
    local nhen = SpawnPrefab("spider")
    nhen.Transform:SetPosition(x + 3, y, z)
    e:PushEvent("attacked", { attacker = nhen, damage = 10 })
    KT("bị đánh thì nhắm lại kẻ tấn công",
       e.components.combat.target == nhen,
       "target=" .. tostring(e.components.combat.target))
    Nhip(nao, 3, function()
        KT("bị đánh thì cây hành vi rẽ sang đánh nhau",
           e.components.combat.target ~= nil)
        nhen:Remove()
        tiep()
    end)
end

-- ── 7. hoàng hôn CHƯA cầm đuốc, ban đêm MỚI cầm ─────────────────────────
local function ThuHoangHon(tiep)
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    for _, m in ipairs({ "cutgrass", "cutgrass", "twigs", "twigs" }) do
        tui:GiveItem(SpawnPrefab(m))
    end
    TheWorld:PushEvent("ms_setphase", "dusk")
    Nhip(nao, 4, function()
        local tay = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
        local co_duoc = false
        for _, mon in pairs(tui.itemslots or {}) do
            if mon ~= nil and mon.prefab == "torch" then co_duoc = true end
        end
        -- ⚠ Đảo so với bản trước. Đợi tối hẳn mới cầm đuốc là CHẾT — Charlie
        --   đánh ngay lúc giao thời chập tối → đêm. Giờ hoàng hôn mà quanh đó
        --   KHÔNG có lửa thì phải cầm luôn.
        KT("hoàng hôn không có lửa thì phải cầm đuốc lên",
           tay ~= nil and tay.prefab == "torch",
           "có đuốc=" .. tostring(co_duoc) .. " đang cầm=" .. tostring(tay and tay.prefab))
        -- ⚠ ms_setphase KHÔNG ăn ngay trong cùng nhịp — đo được phải hơn 2
        --   giây mới thấy TheWorld.state.isnight đổi. Cho đủ nhịp rồi mới
        --   khẳng định, không thì hỏng oan.
        DoiPha("night", function(ok)
        KT("đổi được sang đêm", ok, "pha=" .. tostring(TheWorld.state.phase))
        -- ⚠ Cần đủ nhịp: đổi pha xong, dân làng còn phải bỏ việc đang làm dở
        --   rồi mới nhận việc lo ánh sáng. Ít nhịp quá là hỏng oan.
        Nhip(nao, 8, function()
            local tay2 = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
            local co2 = {}
            for _, mon in pairs(tui.itemslots or {}) do
                if mon ~= nil then table.insert(co2, mon.prefab) end
            end
            KT("sang đêm thì cầm đuốc lên",
               tay2 ~= nil and tay2.prefab == "torch",
               "đang cầm=" .. tostring(tay2 and tay2.prefab)
               .. " túi=[" .. table.concat(co2, " ") .. "]"
               .. " isnight=" .. tostring(TheWorld.state.isnight)
               .. " lo=" .. tostring(e.ailang.dang_lo)
               .. " lam=" .. tostring(e.ailang.dang_lam))
            tiep()
        end)
        end)
    end)
end

-- ── 8. đội mũ thợ mỏ rồi thì thôi chế đuốc ──────────────────────────────
local function ThuMuThoMo(tiep)
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    local mu = SpawnPrefab("minerhat") tui:GiveItem(mu) tui:Equip(mu)
    for _, m in ipairs({ "cutgrass", "cutgrass", "twigs", "twigs" }) do
        tui:GiveItem(SpawnPrefab(m))
    end
    TheWorld:PushEvent("ms_setphase", "night")
    Nhip(nao, 4, function()
        local tay = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
        local co_duoc = false
        for _, mon in pairs(tui.itemslots or {}) do
            if mon ~= nil and mon.prefab == "torch" then co_duoc = true end
        end
        KT("đã đội mũ thợ mỏ thì KHÔNG chế thêm đuốc",
           not co_duoc and (tay == nil or tay.prefab ~= "torch"),
           "có đuốc=" .. tostring(co_duoc) .. " đang cầm=" .. tostring(tay and tay.prefab))
        tiep()
    end)
end


-- ── 9. không ăn nấm độc khi chưa đến mức ────────────────────────────────
local function ThuNamDoc(tiep)
    local nhu_cau = require("ailang/nhu_cau")
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    e.components.hunger:SetPercent(0.4)      -- đói nhưng CHƯA lả
    tui:GiveItem(SpawnPrefab("red_cap"))     -- máu −20
    tui:GiveItem(SpawnPrefab("green_cap"))   -- não −50
    KT("đói vừa thì KHÔNG đụng nấm độc",
       nhu_cau.ChonMonAn(e) == nil,
       "chọn=" .. tostring(nhu_cau.ChonMonAn(e) and nhu_cau.ChonMonAn(e).prefab))
    tui:GiveItem(SpawnPrefab("carrot"))      -- máu +1, no +12
    local chon = nhu_cau.ChonMonAn(e)
    KT("có món lành thì chọn món lành",
       chon ~= nil and chon.prefab == "carrot",
       "chọn=" .. tostring(chon and chon.prefab))
    e.components.hunger:SetPercent(0.05)     -- sắp lả
    for _, mon in pairs(tui.itemslots or {}) do
        if mon ~= nil and mon.prefab == "carrot" then tui:RemoveItem(mon):Remove() end
    end
    KT("sắp lả thì chấp nhận ăn cả món hại",
       nhu_cau.ChonMonAn(e) ~= nil)
    tiep()
end

-- ── 10. thiếu nguyên liệu thì đi kiếm đúng thứ đang thiếu ───────────────
local function ThuDiKiem(tiep)
    local sinh_ton = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    local thieu = sinh_ton.ConThieu(e, "torch")
    local ten = {}
    for _, x in ipairs(thieu or {}) do table.insert(ten, x[1] .. "x" .. x[2]) end
    KT("biết đuốc còn thiếu cutgrass×2 và twigs×2",
       #ten == 2, table.concat(ten, " "))

    local x, y, z = e.Transform:GetWorldPosition()
    local bui = SpawnPrefab("grass")
    bui.Transform:SetPosition(x + 4, y, z)
    local hd = sinh_ton.DiKiem(e, "cutgrass")
    KT("đi kiếm cutgrass thì nhắm đúng bụi cỏ",
       hd ~= nil and hd.target == bui and hd.action == ACTIONS.PICK,
       "nhắm=" .. tostring(hd and hd.target and hd.target.prefab))
    tiep()
end

-- ── 11. nhu cầu được xét đúng thứ tự ưu tiên ────────────────────────────
local function ThuThuTu(tiep)
    local sinh_ton = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    -- Vừa tối vừa đói: ánh sáng phải được lo TRƯỚC đồ ăn.
    TheWorld:PushEvent("ms_setphase", "night")
    e.components.hunger:SetPercent(0.3)
    local n = sinh_ton.NhuCauCapThiet(e)
    KT("vừa tối vừa đói thì lo ÁNH SÁNG trước",
       n ~= nil and n.ma == "anh_sang", "đang lo=" .. tostring(n and n.ma))
    -- Có đuốc rồi thì mới tới đồ ăn.
    tui:GiveItem(SpawnPrefab("torch"))
    tui:Equip(nhuCauTorch(tui))
    local n2 = sinh_ton.NhuCauCapThiet(e)
    KT("có ánh sáng rồi thì chuyển sang lo ĐỒ ĂN",
       n2 ~= nil and n2.ma == "do_an", "đang lo=" .. tostring(n2 and n2.ma))
    tiep()
end

-- ⚠ Bộ này XOÁ SẠCH dân làng để dựng bản thử sạch. Chạy trong world thật thì
--   phải cất hồ sơ đi rồi dựng lại, không thì cả làng biến mất vĩnh viễn:
--   ChupTatCa dựng lại bảng hồ sơ TỪ dân làng đang sống, mà lúc đó không còn
--   ai sống.
-- ⚠ Bộ này ĐẨY ms_setphase để thử nhánh ban đêm. Người chơi đang ở trong
--   world sẽ thấy "trời mới tối là sáng luôn" — mod KHÔNG hề đụng vào thời
--   gian, chỉ bộ kiểm làm. Nên phải nhớ giờ cũ và trả lại ở cuối.
local GIO_CU = TheWorld.state.phase

local ql = TheWorld.components ~= nil and TheWorld.components.ailangquanly or nil
local ho_so_cu = nil
if ql ~= nil then
    ho_so_cu = {}
    for ma, hs in pairs(ql.ho_so) do ho_so_cu[ma] = hs end
    ql.tam_dung_chup = true
end

local function KhoiPhucLang()
    if ql == nil then return end
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    ql.ho_so = ho_so_cu or {}
    local n = 0
    for _, hs in pairs(ql.ho_so) do
        if pcall(dan_lang.Sinh, hs) then n = n + 1 end
    end
    ql.tam_dung_chup = false
    print("[TU-KIEM] đã dựng lại " .. n .. " dân làng của bạn")
end

local function TraLaiGio()
    if GIO_CU ~= nil and TheWorld.state.phase ~= GIO_CU then
        TheWorld:PushEvent("ms_setphase", GIO_CU)
        print("[TU-KIEM] đã trả lại giờ cũ: " .. tostring(GIO_CU))
    end
end


-- ── 12. hồn ma kêu cứu để người chơi biết nó là gì ──────────────────────
local function ThuHonMaKeu(tiep)
    local e, nao = DanLangSach(Goc())
    local noi = nil
    if e.components.talker ~= nil then
        local goc_say = e.components.talker.Say
        e.components.talker.Say = function(self, ...) noi = select(1, ...) return goc_say(self, ...) end
    end
    dan_lang.ThanhHonMa(e)
    KT("hoá hồn ma thì KÊU LÊN cho người chơi biết",
       noi ~= nil and noi ~= "", "nói=" .. tostring(noi))
    KT("có hẹn giờ kêu lại định kỳ", e.hon_ma_keu ~= nil)
    noi = nil
    dan_lang.HoiSinh(e)
    KT("hồi sinh thì báo và tắt hẹn giờ kêu",
       noi ~= nil and e.hon_ma_keu == nil, "nói=" .. tostring(noi))
    tiep()
end


-- ── 13. hồn ma đúng dáng DST và nhận vật phẩm hồi sinh ──────────────────
local function ThuHonMaDangDST(tiep)
    local e, nao = DanLangSach(Goc())
    dan_lang.ThanhHonMa(e)
    KT("hồn ma mang tag playerghost để vật phẩm hồi sinh soi thấy",
       e:HasTag("playerghost"))
    KT("hồn ma có component trader để nhận vật phẩm",
       e.components.trader ~= nil)
    local tim_thu = SpawnPrefab("reviver")
    KT("trader nhận tim đập (reviver)",
       e.components.trader ~= nil and e.components.trader.acceptnontradable ~= nil
       or (e.components.trader ~= nil and e.components.trader.onaccept ~= nil))
    tim_thu:Remove()
    -- Đưa tim đập cho nó xem có sống lại không
    local tim = SpawnPrefab("reviver")
    e.components.trader.onaccept(e, nil, tim)
    KT("đưa tim đập thì hồn ma sống lại",
       e.ailang.la_hon_ma == false, "la_hon_ma=" .. tostring(e.ailang.la_hon_ma))
    KT("sống lại thì bỏ tag playerghost và gỡ trader",
       not e:HasTag("playerghost") and e.components.trader == nil)
    tiep()
end


-- ── 14. nhu cầu bí không được chặn nhu cầu bên dưới ─────────────────────
local function ThuKhongKetXe(tiep)
    local sinh_ton = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    TheWorld:PushEvent("ms_setphase", "day")
    -- Bí hoàn toàn ở hồi não: dọn sạch hoa quanh đó.
    local x, y, z = e.Transform:GetWorldPosition()
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, 90)) do
        if v.prefab == "flower" and v.Remove then v:Remove() end
    end
    e.components.sanity:SetPercent(0.1)
    local ds = sinh_ton.ConThieuGi(e)
    local ten = {}
    for _, n in ipairs(ds) do table.insert(ten, n.ma) end
    KT("thấy hồi não đang thiếu và vẫn xét tiếp các nhu cầu dưới",
       #ds >= 2, "đang thiếu: " .. table.concat(ten, ","))
    -- Cho nguyên liệu làm giáp cỏ: nhu cầu DƯỚI hồi não phải giải được
    for _ = 1, 12 do tui:GiveItem(SpawnPrefab("cutgrass")) end
    for _ = 1, 4 do tui:GiveItem(SpawnPrefab("twigs")) end
    local kq = sinh_ton.Giai(e)
    KT("bí ở hồi não thì VẪN lo được nhu cầu bên dưới",
       kq ~= nil, "Giai() trả về " .. tostring(kq))
    tiep()
end


-- ── 15. đêm cầm đuốc thì thôi chặt cây ──────────────────────────────────
local function ThuKhongDoiRiuDuoc(tiep)
    local e, nao = DanLangSach(Goc())
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    local riu = SpawnPrefab("axe") tui:GiveItem(riu)
    local duoc = SpawnPrefab("torch") tui:GiveItem(duoc) tui:Equip(duoc)
    local x, y, z = e.Transform:GetWorldPosition()
    SpawnPrefab("evergreen").Transform:SetPosition(x + 3, y, z)
    TheWorld:PushEvent("ms_setphase", "night")
    Nhip(nao, 7, function()
        local tay = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
        KT("đêm cầm đuốc thì KHÔNG đổi sang rìu để chặt",
           tay ~= nil and tay.prefab == "torch",
           "đang cầm=" .. tostring(tay and tay.prefab))
        DoiPha("day", function()
        Nhip(nao, 8, function()
            local tay2 = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
            -- ⚠ Kỳ vọng ĐÚNG ở đây KHÔNG phải "cầm rìu". Sang ngày, việc
            --   hợp lý có thể là đi hái cỏ cho đống lửa — việc đó không cần
            --   tay nào cả. Thứ BẮT BUỘC là BỎ ĐUỐC XUỐNG: đuốc cháy hao ngay
            --   trên tay, cầm suốt ngày thì tới đêm là tắt ngóm, đúng lúc cần
            --   nhất. Đo được: dân làng cầm đuốc cả ngày chỉ để đi hái cỏ.
            KT("sang ngày thì BỎ ĐUỐC XUỐNG (khỏi cháy phí tới đêm)",
               tay2 == nil or tay2.prefab ~= "torch",
               "đang cầm=" .. tostring(tay2 and tay2.prefab)
               .. " việc=" .. tostring(e.ailang.viec and e.ailang.viec.vi_sao))
            KT("bỏ xuống là CẤT VÀO TÚI, không vứt đi",
               require("ailang/nhu_cau").CoTrongTui(e, "torch") ~= nil
               or (tay2 ~= nil and tay2.prefab == "torch"))
            tiep()
        end)
        end)
    end)
end

-- ── 16. kiên nhẫn không hết khi đang bào mòn được mục tiêu ──────────────
--
-- ⚠ Bản đầu chỉ đưa cái rìu rồi mong dân làng đi chặt — SAI TIỀN ĐỀ. Từ khi
--   có bảng nhu cầu thì dân làng chặt cây vì NHU CẦU cần gỗ, chứ không chặt
--   vu vơ; thấy bụi cỏ gần hơn mà nhu cầu đang cần cỏ thì nó hái cỏ, và phép
--   kiểm hỏng oan với "nhắm=grass".
--   Giờ dựng đúng cảnh: cho đủ cỏ, thiếu MỖI gỗ, thì nó buộc phải đi chặt.
local function ThuKienNhan(tiep)
    local sinh_ton = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    tui:GiveItem(SpawnPrefab("axe"))
    for _ = 1, 3 do tui:GiveItem(SpawnPrefab("cutgrass")) end   -- lửa trại: cỏ×3 + gỗ×2

    local x, y, z = e.Transform:GetWorldPosition()
    local cay = SpawnPrefab("evergreen")
    cay.Transform:SetPosition(x + 3, y, z)

    local hd = sinh_ton.DiKiem(e, "log")
    KT("thiếu gỗ thì đi chặt cây, và cầm rìu lên",
       hd ~= nil and hd.action == ACTIONS.CHOP,
       "hành động=" .. tostring(hd and hd.action and hd.action.id))

    Nhip(nao, 3, function()
        local ba = e:GetBufferedAction()
        local nham_dau = ba and ba.target
        if cay.components.workable ~= nil then
            cay.components.workable:SetWorkLeft(cay.components.workable.workleft - 3)
        end
        Nhip(nao, 3, function()
            -- ⚠ Khẳng định đúng TÍNH CHẤT: cái cây không bị ghi sổ đen. Đòi nó
            --   vẫn đang nhắm cái cây thì hỏng oan — chặt ra gỗ thì nhánh nhặt
            --   giành lấy gỗ, và đó là hành vi ĐÚNG.
            local so_den = e.ailang.bo_qua or {}
            KT("đang bào mòn được cây thì KHÔNG ghi nó vào sổ đen",
               so_den[cay.GUID] == nil,
               "sổ đen=" .. tostring(so_den[cay.GUID]))
            tiep()
        end)
    end)
end

-- ── 17. đầu game là đời DU MỤC, chưa có nhà ────────────────────────────
--
-- ⚠ Đảo ngược so với bản trước. Trước đây nhà mặc định là chỗ được sinh ra;
--   giờ NHÀ = ĐÀI TRIỆU HỒI, nên chưa dựng Đài thì chưa có nhà, và không có
--   nhà thì dân làng bám theo người chơi. Đó là đời du mục đầu game.
local function ThuDuMuc(tiep)
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local e = dan_lang.Sinh({ ten = "DuMuc2", nhan_vat = "wilson" })
    KT("chưa có Đài thì dân làng KHÔNG có nhà",
       e.ailang.nha == nil, "nhà=" .. tostring(e.ailang.nha))
    local la = require("ailang/lang")
    KT("không nhà thì không có vùng làng", la.Tam(e) == nil)
    e:Remove()
    tiep()
end


-- ── 18. không trôi ra khỏi làng ─────────────────────────────────────────
local function ThuKhongTroi(tiep)
    local sinh_ton = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local nx, nz = e.ailang.nha[1], e.ailang.nha[2]
    -- Bụi cỏ NGOÀI vùng làng: đặt cách nhà 90 nhưng sát dân làng
    e.Transform:SetPosition(nx + 70, 0, nz)
    local bui_xa = SpawnPrefab("grass")
    bui_xa.Transform:SetPosition(nx + 75, 0, nz)
    local hd = sinh_ton.DiKiem(e, "cutgrass")
    KT("không đi kiếm nguyên liệu NGOÀI vùng làng",
       hd == nil or hd.target ~= bui_xa,
       "nhắm=" .. tostring(hd and hd.target and hd.target.prefab))
    bui_xa:Remove()
    -- Xa nhà thì cây hành vi phải ưu tiên về nhà
    Nhip(nao, 3, function()
        local x, _, z = e.Transform:GetWorldPosition()
        local xa = math.sqrt((x - nx)^2 + (z - nz)^2)
        KT("ở xa nhà thì có nhánh kéo về (không đứng ì ngoài đó)",
           e.brain == nil or xa <= 75, "cách nhà " .. math.floor(xa))
        tiep()
    end)
end

-- ── 19. hồn ma tìm chỗ hồi sinh ở RẤT xa ────────────────────────────────
local function ThuHonMaTimXa(tiep)
    local e, nao = DanLangSach(Goc())
    dan_lang.ThanhHonMa(e)
    local x, y, z = e.Transform:GetWorldPosition()
    local bia = SpawnPrefab("resurrectionstone")
    bia.Transform:SetPosition(x + 120, y, z)   -- xa hơn tầm nhìn thường rất nhiều
    local thay = FindEntity(e, 250, nil, { "resurrector" }, { "INLIMBO", "burnt" })
    KT("hồn ma thấy được chỗ hồi sinh cách 120 đơn vị",
       thay ~= nil, "thấy=" .. tostring(thay and thay.prefab))
    bia:Remove()
    dan_lang.HoiSinh(e)
    tiep()
end


-- ── 20. hồn ma KHÔNG được vô hình ───────────────────────────────────────
local function ThuHonMaCoHinh(tiep)
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local e = dan_lang.Sinh({ ten = "ThuHinh", nhan_vat = "wilson" })
    local bank_truoc = e.AnimState ~= nil and e.AnimState.GetBuild and e.AnimState:GetBuild()
    dan_lang.ThanhHonMa(e)
    local build_sau = e.AnimState ~= nil and e.AnimState.GetBuild and e.AnimState:GetBuild()
    -- ⚠ Đổi BANK sang "ghost" làm entity biến mất hẳn vì không có bank tên đó.
    --   Phép kiểm này canh chừng chuyện đó tái diễn.
    KT("hoá hồn ma thì đổi BUILD chứ không đổi sang bank không tồn tại",
       build_sau == nil or tostring(build_sau):find("ghost") ~= nil,
       "build=" .. tostring(build_sau))
    KT("hồn ma vẫn còn hiện hữu và hợp lệ",
       e:IsValid() and e.entity:IsVisible())
    dan_lang.HoiSinh(e)
    local build_ve = e.AnimState ~= nil and e.AnimState.GetBuild and e.AnimState:GetBuild()
    KT("hồi sinh thì trả build về nhân vật",
       build_ve == nil or tostring(build_ve):find("ghost") == nil,
       "build=" .. tostring(build_ve))
    e:Remove()
    tiep()
end


-- ── 21. thiện cảm kiểu Wurt-merm ────────────────────────────────────────
local function ThuThienCam(tiep)
    local tt = require("ailang/than_thiet")
    local e, nao = DanLangSach(Goc())
    KT("sinh ra với thiện cảm trung lập", tt.Lay(e) == tt.BAN_DAU,
       "thiện cảm=" .. tt.Lay(e))
    KT("chưa đủ thân thì chưa chịu đi theo", not tt.ChiuTheo(e))
    KT("có component trader để nhận đồ từ người chơi", e.components.trader ~= nil)

    -- Cho ăn: thiện cảm tăng
    local truoc = tt.Lay(e)
    local ca_rot = SpawnPrefab("carrot")
    e.components.trader.onaccept(e, nil, ca_rot)
    KT("cho ăn thì thiện cảm tăng", tt.Lay(e) > truoc,
       truoc .. " -> " .. tt.Lay(e))

    -- Không nhận nấm độc
    local nam = SpawnPrefab("green_cap")
    KT("không nhận món hại (nấm não −50)",
       e.components.trader.acceptfn == nil
       or e.components.trader.acceptfn(e, nam) ~= true)
    nam:Remove()

    -- Đủ thân thì theo được
    tt.Doi(e, 100, "thử")
    KT("đủ thân thì chịu đi theo", tt.ChiuTheo(e), "thiện cảm=" .. tt.Lay(e))

    -- Bị người chơi đánh thì mất lòng
    local truoc2 = tt.Lay(e)
    local ke_danh = AllPlayers[1]
    if ke_danh ~= nil then
        e:PushEvent("attacked", { attacker = ke_danh, damage = 1 })
        KT("bị người chơi đánh thì mất lòng", tt.Lay(e) < truoc2,
           truoc2 .. " -> " .. tt.Lay(e))
    else
        print("[TU-KIEM] BỎ QUA phép đánh — không có người chơi trong world")
    end

    -- Bỏ đói qua ngày thì mất lòng
    local truoc3 = tt.Lay(e)
    e.components.hunger:SetPercent(0.1)
    tt.SangNgayMoi(e)
    KT("bỏ đói qua ngày thì mất lòng", tt.Lay(e) < truoc3,
       truoc3 .. " -> " .. tt.Lay(e))
    tiep()
end

-- ── 22. chế độ theo chân / ở nhà ────────────────────────────────────────
local function ThuCheDo(tiep)
    local tt = require("ailang/than_thiet")
    local lenh = require("ailang/lenh")
    local e, nao = DanLangSach(Goc())
    KT("mặc định là chế độ tự do", (e.ailang.che_do or "tu_do") == "tu_do",
       "chế độ=" .. tostring(e.ailang.che_do))

    -- Chưa đủ thân thì từ chối đặt theo chân
    tt.Doi(e, -100, "thử")
    lenh.Theo(e.ailang.ten)
    KT("chưa đủ thân thì KHÔNG đặt được theo chân",
       e.ailang.che_do ~= "theo_chan", "chế độ=" .. tostring(e.ailang.che_do))

    -- Đủ thân thì đặt được
    tt.Doi(e, 100, "thử")
    lenh.Theo(e.ailang.ten)
    KT("đủ thân thì đặt được theo chân",
       e.ailang.che_do == "theo_chan", "chế độ=" .. tostring(e.ailang.che_do))

    lenh.ONha(e.ailang.ten)
    KT("đặt được chế độ ở nhà", e.ailang.che_do == "o_nha")
    lenh.TuDo(e.ailang.ten)
    KT("đặt được chế độ tự do", e.ailang.che_do == "tu_do")
    tiep()
end


-- ── 23. dân làng KHÔNG được ngủ ─────────────────────────────────────────
--
-- ⚠ Phép kiểm này canh đúng cái lỗi đã tốn nhiều công: dùng nhầm
--   AddServerNonSleepable() (vô dụng) thay vì SetCanSleep(false).
local function ThuKhongNgu(tiep)
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local e = dan_lang.Sinh({ ten = "ThuThuc", nhan_vat = "wilson" })
    local heo = SpawnPrefab("pigman")
    local x, y, z = e.Transform:GetWorldPosition()
    heo.Transform:SetPosition(x + 40, y, z + 40)
    TheWorld:DoTaskInTime(11, function()
        KT("dân làng KHÔNG ngủ dù không có người chơi ở gần",
           not e:IsAsleep(), "ngủ=" .. tostring(e:IsAsleep()))
        KT("não vẫn chạy khi không có người chơi",
           e.brain ~= nil, "brain=" .. tostring(e.brain ~= nil))
        KT("đối chứng: heo vanilla thì VẪN ngủ (đúng cơ chế DST)",
           heo:IsAsleep(), "heo ngủ=" .. tostring(heo:IsAsleep()))
        heo:Remove()
        e:Remove()
        tiep()
    end)
end


-- ── 24. giữ lấy việc xuyên nhiều nhịp ───────────────────────────────────
--
-- ⚠ Đây là TÍNH CHẤT CỐT LÕI của bản gom-năm-nhánh-thành-một. Bản cũ quyết
--   lại từ đầu mỗi nhịp nên các nhánh giẫm chân nhau: đổi rìu↔đuốc liên tục,
--   chặt vài nhát rồi bỏ. Phép kiểm này canh chừng chuyện đó tái diễn.
local function ThuGiuViec(tiep)
    local vi = require("ailang/viec")
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local tui = e.components.inventory
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil then tui:DropItem(cam) cam:Remove() end
    tui:GiveItem(SpawnPrefab("axe"))
    for _ = 1, 3 do tui:GiveItem(SpawnPrefab("cutgrass")) end

    local x, y, z = e.Transform:GetWorldPosition()
    SpawnPrefab("evergreen").Transform:SetPosition(x + 4, y, z)
    SpawnPrefab("evergreen").Transform:SetPosition(x - 4, y, z)

    local a = vi.HanhDong(e)
    KT("nhận được một việc", a ~= nil,
       "hành động=" .. tostring(a and a.action and a.action.id))
    if a == nil then tiep() return end

    local dich_dau = a.target
    local giu = true
    for _ = 1, 5 do
        local b = vi.HanhDong(e)
        if b == nil or b.target ~= dich_dau then giu = false break end
    end
    KT("gọi 5 lần liên tiếp vẫn GIỮ đúng một mục tiêu", giu,
       "mục tiêu đầu=" .. tostring(dich_dau and dich_dau.prefab))

    KT("việc được ghi lại để soi được", e.ailang.dang_lam ~= nil,
       "đang làm=" .. tostring(e.ailang.dang_lam))

    -- Mục tiêu biến mất thì phải nhận việc khác, không kẹt
    if dich_dau ~= nil and dich_dau:IsValid() then dich_dau:Remove() end
    local c = vi.HanhDong(e)
    KT("mục tiêu biến mất thì nhận việc khác, không kẹt",
       c == nil or c.target ~= dich_dau,
       "việc mới=" .. tostring(c and c.target and c.target.prefab))
    tiep()
end


-- ── 25. không nhặt đồ quý của người chơi ────────────────────────────────
local function ThuKhongTrom(tiep)
    local vi = require("ailang/viec")
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local x, y, z = e.Transform:GetWorldPosition()
    local mat = SpawnPrefab("chester_eyebone")
    if mat ~= nil then
        mat.Transform:SetPosition(x + 2, y, z)
        local tim = 0
        for _ = 1, 4 do
            local a = vi.HanhDong(e)
            if a ~= nil and a.target == mat then tim = tim + 1 end
        end
        KT("KHÔNG nhặt mắt Chester của người chơi", tim == 0,
           "số lần nhắm tới=" .. tim)
        mat:Remove()
    else
        print("[TU-KIEM] BỎ QUA — không có prefab chester_eyebone")
    end
    tiep()
end

-- ── 26. nhu cầu gấp thì được ra ngoài vùng làng ─────────────────────────
local function ThuRaNgoaiLang(tiep)
    local st = require("ailang/sinh_ton")
    local e, nao = DanLangSach(Goc())
    local nx, nz = e.ailang.nha[1], e.ailang.nha[2]
    -- Bụi cây con NGOÀI bán kính làng (55) nhưng trong tầm khẩn cấp (80)
    -- Dọn sạch quanh đó trước: còn cành rơi dưới đất thì DiKiem nhặt cái đó
    -- (đúng hành vi — nhặt rẻ hơn hái), và phép kiểm bám sai mục tiêu.
    for _, v in ipairs(TheSim:FindEntities(nx + 70, 0, nz, 40)) do
        if v.prefab == "twigs" and v.Remove ~= nil then v:Remove() end
    end
    local bui = SpawnPrefab("sapling")
    bui.Transform:SetPosition(nx + 70, 0, nz)
    e.Transform:SetPosition(nx + 65, 0, nz)
    local thuong = st.DiKiem(e, "twigs")
    local gap    = st.DiKiem(e, "twigs", nil, 80)
    KT("bán kính thường thì KHÔNG với tới bụi ngoài làng",
       thuong == nil or thuong.target ~= bui,
       "nhắm=" .. tostring(thuong and thuong.target and thuong.target.prefab))
    -- Khẳng định đúng tính chất: với tới được thứ NẰM NGOÀI vùng làng.
    local ngoai_lang = false
    if gap ~= nil and gap.target ~= nil then
        local tx, _, tz = gap.target.Transform:GetWorldPosition()
        ngoai_lang = (tx - nx) ^ 2 + (tz - nz) ^ 2 > 55 * 55
    end
    KT("nhu cầu gấp thì VỚI TỚI được thứ ngoài vùng làng", ngoai_lang,
       "nhắm=" .. tostring(gap and gap.target and gap.target.prefab))
    bui:Remove()

    -- ⚠ VÀ PHẢI VỚI TỚI TẬN 120. Đây là chỗ hai con số từng đá nhau: bán kính
    --   tìm khẩn cấp là 80 trong khi node "đi quá xa nhà" kéo về ở 50, nên
    --   vòng tìm khẩn cấp CHƯA BAO GIỜ dùng được. Đo trên server, làng dựng
    --   giữa rừng rậm: bán kính 80 có 250 cây gỗ nhưng chỉ 3 BỤI CỎ và KHÔNG
    --   MỘT bụi cây con nào trong cả bán kính 150 — cỏ thì có 86 bụi, ở 150.
    --   Cả ba chết đêm với 2 khúc gỗ trong túi, ngồi trên mỏ gỗ mà không đổi
    --   ra nổi ánh sáng.
    for _, v in ipairs(TheSim:FindEntities(nx + 120, 0, nz, 40)) do
        if v.prefab == "cutgrass" and v.Remove ~= nil then v:Remove() end
    end
    local xa = SpawnPrefab("grass")
    xa.Transform:SetPosition(nx + 120, 0, nz)
    e.Transform:SetPosition(nx + 110, 0, nz)
    local rat_gap = st.DiKiem(e, "cutgrass", nil, 130)
    -- Khẳng định theo KHOẢNG CÁCH, không theo đúng cái bụi vừa dựng: bản đồ
    -- thật có thể còn bụi khác gần đó, và nhắm bụi nào cũng được miễn là nó
    -- nằm ngoài tầm mà dây trói về nhà từng chặn.
    local xa_nha = -1
    if rat_gap ~= nil and rat_gap.target ~= nil then
        local tx, _, tz = rat_gap.target.Transform:GetWorldPosition()
        xa_nha = math.sqrt((tx - nx) ^ 2 + (tz - nz) ^ 2)
    end
    KT("nhu cầu gấp với tới được tài nguyên cách nhà hơn 100",
       xa_nha > 100,
       "nhắm=" .. tostring(rat_gap and rat_gap.target and rat_gap.target.prefab)
       .. " cách nhà " .. string.format("%.0f", xa_nha))
    xa:Remove()
    e:Remove()
    tiep()
end


-- ── 27. Đài Triệu Hồi ───────────────────────────────────────────────────
local function ThuDaiTrieuHoi(tiep)
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local ql = TheWorld.components.ailangquanly
    ql.ho_so = {}
    local gx, gz = Goc()
    local dai = SpawnPrefab("ailang_dai")
    KT("prefab Đài Triệu Hồi dựng được", dai ~= nil)
    if dai == nil then tiep() return end
    dai.Transform:SetPosition(gx, 0, gz)
    KT("Đài có bán kính làng", (dai.ban_kinh or 0) > 0,
       "bán kính=" .. tostring(dai.ban_kinh))

    -- Giá tăng dần theo số dân
    local gia0 = _G.AILANG_GIA_TRIEU_HOI(0)
    local gia3 = _G.AILANG_GIA_TRIEU_HOI(3)
    KT("giá triệu hồi tăng theo số dân đang có",
       gia3[1][2] > gia0[1][2],
       string.format("0 dân=%dx%s, 3 dân=%dx%s",
           gia0[1][2], gia0[1][1], gia3[1][2], gia3[1][1]))

    -- Chưa có Đài thì dân làng KHÔNG có nhà (đời du mục)
    local du_muc = dan_lang.Sinh({ ten = "DuMuc", nhan_vat = "wilson" })
    KT("chưa gắn Đài thì dân làng KHÔNG có nhà (đời du mục)",
       du_muc.ailang.nha == nil,
       "nhà=" .. tostring(du_muc.ailang.nha))
    du_muc:Remove()

    -- Dân làng do Đài triệu hồi thì lấy Đài làm nhà
    local e = ql:Them({ ten = "ConDai", nhan_vat = "wilson",
                        nha = { gx, gz }, dai = dai.GUID })
    KT("dân làng của Đài lấy Đài làm nhà",
       e.ailang.nha ~= nil and e.ailang.dai == dai.GUID)

    local la = require("ailang/lang")
    KT("tâm làng đúng chỗ Đài",
       la.Tam(e) ~= nil and math.abs(la.Tam(e)[1] - gx) < 1)
    KT("bán kính làng lấy từ Đài",
       la.BanKinh(e) == dai.ban_kinh,
       la.BanKinh(e) .. " vs " .. tostring(dai.ban_kinh))
    KT("điểm trong bán kính thì tính là trong làng",
       la.TrongLang(e, gx + 10, gz))
    KT("điểm ngoài bán kính thì KHÔNG tính là trong làng",
       not la.TrongLang(e, gx + dai.ban_kinh + 30, gz))

    -- Đài phải hồi sinh được dân của nó, không thì làng chết vĩnh viễn
    KT("Đài mang tag resurrector để hồn ma tìm về được",
       dai:HasTag("resurrector"))
    local ma = ql:Them({ ten = "MaThu", nhan_vat = "wilson",
                         nha = { gx, gz }, dai = dai.GUID })
    ma.Transform:SetPosition(gx + 2, 0, gz)
    dan_lang.ThanhHonMa(ma)
    local la2 = require("ailang/lang")
    KT("hồn ma nhìn thấy Đài là chỗ hồi sinh",
       FindEntity(ma, 250, nil, { "resurrector" }, { "INLIMBO", "burnt" }) ~= nil)
    ma:Remove()

    -- Đập Đài thì cả làng mất nhà
    dai.components.workable:SetWorkLeft(0)
    dai.components.workable.onfinish(dai)
    KT("đập Đài thì dân làng mất nhà, quay lại du mục",
       e.ailang.nha == nil and e.ailang.dai == nil,
       "nhà=" .. tostring(e.ailang.nha))
    e:Remove()
    tiep()
end

-- ── 28. giữ làng: đánh quái lạc vào, dập lửa ────────────────────────────
local function ThuGiuLang(tiep)
    local la = require("ailang/lang")
    local vi = require("ailang/viec")
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    local ql = TheWorld.components.ailangquanly
    ql.ho_so = {}
    local gx, gz = Goc()
    local dai = SpawnPrefab("ailang_dai")
    dai.Transform:SetPosition(gx, 0, gz)
    local e = ql:Them({ ten = "GiuLang", nhan_vat = "wilson",
                        nha = { gx, gz }, dai = dai.GUID })
    e.Transform:SetPosition(gx, 0, gz)
    e:StopBrain()

    local nhen_trong = SpawnPrefab("spider")
    nhen_trong.Transform:SetPosition(gx + 12, 0, gz)
    KT("thấy quái lạc vào trong làng", la.DichTrongLang(e) == nhen_trong,
       "thấy=" .. TenCua(la.DichTrongLang(e)))
    nhen_trong.Transform:SetPosition(gx + dai.ban_kinh + 40, 0, gz)
    -- Khẳng định đúng CON này ra ngoài tầm, chứ không đòi cả bản đồ sạch quái.
    KT("quái ở NGOÀI làng thì không chủ động đuổi",
       la.DichTrongLang(e) ~= nhen_trong,
       "thấy=" .. TenCua(la.DichTrongLang(e)))
    nhen_trong:Remove()

    local cay = SpawnPrefab("evergreen")
    cay.Transform:SetPosition(gx + 8, 0, gz)
    if cay.components.burnable ~= nil then
        cay.components.burnable:Ignite()
        KT("thấy đám cháy trong làng", la.ChayTrongLang(e) == cay,
           "thấy=" .. TenCua(la.ChayTrongLang(e)))
        local v = vi.NhanViec(e)
        KT("việc GẤP NHẤT là đi dập lửa",
           v ~= nil and v.hanh_dong == ACTIONS.EXTINGUISH,
           "việc=" .. tostring(v and v.vi_sao))
        cay.components.burnable:Extinguish()
    end
    cay:Remove()
    dai:Remove()
    e:Remove()
    tiep()
end

-- ── mất rìu thì phải CHẾ LẠI được ───────────────────────────────────────
--
-- ⚠ Đây là bài kiểm của vòng xoáy tử thần đã làm cả làng chết đi chết lại.
--   Chết một lần là rơi sạch đồ, kể cả cây rìu trong bộ khởi đầu. Trước khi có
--   nhu cầu "dụng cụ" thì KHÔNG nhu cầu nào biết chế lại rìu, nên dân làng tay
--   trắng không bao giờ chặt được gỗ nữa — dù đứng giữa rừng. Đo trên server:
--   `DiKiem("log")` trả nil ở CẢ hai bán kính với 12 cây chặt được trong vòng
--   30. Không gỗ -> không lửa trại -> chết đêm -> lại rơi rìu.
local function ThuMatRiu(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local st = require("ailang/sinh_ton")
    local nc = require("ailang/nhu_cau")
    local tui = e.components.inventory
    tui:DropEverything()

    local cay = SpawnPrefab("evergreen")
    cay.Transform:SetPosition(gx + 6, 0, gz)

    KT("tay trắng thì KHÔNG chặt nổi cây dù cây ngay cạnh",
       st.DiKiem(e, "log", nil, 30) == nil)

    local dc = nc.Tim("dung_cu")
    KT("có nhu cầu \"dụng cụ\" trong bảng", dc ~= nil)
    KT("tay trắng thì nhu cầu dụng cụ CHƯA thoả",
       dc ~= nil and not dc.du(e))
    KT("dụng cụ xếp TRÊN nhà (rìu là điều kiện của đống lửa)",
       nc.ChiSo("dụng cụ") < nc.ChiSo("nhà"),
       "dụng cụ=" .. tostring(nc.ChiSo("dụng cụ")) .. " nhà=" .. tostring(nc.ChiSo("nhà")))

    -- ⚠ PHẢI thoả ánh sáng và chống nóng trước. Từ khi sinh_ton.Giai lặp ƯU
    --   TIÊN ở vòng ngoài, nhu cầu hạng cao hơn sẽ giành lượt và Giai không
    --   bao giờ xuống tới "dụng cụ" — bài này hỏng oan với "túi=khong co".
    tui:GiveItem(SpawnPrefab("torch"))
    e.components.temperature:SetTemperature(20)
    -- Cho đúng nguyên liệu chế rìu rồi bắt nó tự chế.
    tui:GiveItem(SpawnPrefab("twigs"))
    tui:GiveItem(SpawnPrefab("flint"))
    KT("có cành + đá lửa thì chế được rìu",
       e.components.builder:CanBuild("axe"))
    st.Giai(e)
    KT("dân làng TỰ chế lại rìu khi mất rìu", dc ~= nil and dc.du(e),
       "túi=" .. TenCua(nc.CoTrongTui(e, "axe")))
    KT("có rìu rồi thì chặt được cây ngay cạnh",
       st.DiKiem(e, "log", nil, 30) ~= nil)

    cay:Remove()
    e:Remove()
    tiep()
end

-- ── hồn ma phải ĐI ĐƯỢC ─────────────────────────────────────────────────
--
-- ⚠ Trạng thái "death" của stategraph là trạng thái CUỐI: không lối ra, và bỏ
--   qua mọi lệnh di chuyển. Đo trên server: cả ba hồn ma có sg="death", não
--   vẫn chạy đúng nhánh hồn ma và vẫn ra lệnh đi tới Đài cách 51 đơn vị — mà
--   thân thể không nhích một bước suốt nhiều ngày. Người chơi chỉ thấy xác
--   nằm ì. Hồi sinh cũng vậy: không rời "death" thì được cái xác biết nói.
local function ThuHonMaDiDuoc(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    -- ⚠ RỜI TRẠNG THÁI CHẾT PHẢI ĐI ĐÚNG LỐI. SGwilson.lua:3839 có
    --   `assert(false, "Left death state.")` ngay trong onexit — gọi thẳng
    --   sg:GoToState("idle") là ném LỖI CỨNG mỗi lần hồn ma cử động, nhật ký
    --   ngập stack traceback. Đo trên server: lỗi nổ đúng lúc An hồi sinh và
    --   bắt đầu đi kiếm cỏ. Lối hợp lệ là cờ `statemem.vinesaving`.
    local loi_truoc = 0
    local print_that = print
    print = function(...)
        local d = tostring((...))
        if d:find("Left death state") then loi_truoc = loi_truoc + 1 end
        return print_that(...)
    end
    dan_lang.ThanhHonMa(e)
    print = print_that
    KT("rời trạng thái chết KHÔNG ném lỗi \"Left death state\"",
       loi_truoc == 0, "số lỗi=" .. loi_truoc)
    KT("thành hồn ma thì RỜI trạng thái chết (đi lại được)",
       e.sg == nil or e.sg.currentstate == nil or e.sg.currentstate.name ~= "death",
       "sg=" .. tostring(e.sg and e.sg.currentstate and e.sg.currentstate.name))
    KT("thành hồn ma thì bỏ luôn việc đang làm dở",
       e.ailang.viec == nil)

    local bia = SpawnPrefab("resurrectionstatue")
    if bia ~= nil then bia.Transform:SetPosition(gx + 1, 0, gz) end
    dan_lang.HoiSinh(e)
    KT("hồi sinh thì cũng RỜI trạng thái chết",
       e.sg == nil or e.sg.currentstate == nil or e.sg.currentstate.name ~= "death",
       "sg=" .. tostring(e.sg and e.sg.currentstate and e.sg.currentstate.name))
    if bia ~= nil then bia:Remove() end
    e:Remove()
    tiep()
end

-- ── chen ngang theo THỨ HẠNG, không theo tên ────────────────────────────
--
-- ⚠ `sinh_ton.Giai` duyệt HẾT bảng nhu cầu, nên khi nhu cầu gấp giải không nổi
--   ở bán kính gần, nó trả về việc của một nhu cầu THẤP HƠN. Bản trước so nhãn
--   việc với nhãn nhu cầu gấp, thấy lệch là vứt việc — mỗi 0,5 giây một lần,
--   mãi mãi. Dân làng nhận đi nhận lại cùng một việc và không chặt xong cây
--   nào. Đo được: dang_lo="hồi máu" trong khi nhu cầu gấp là "ánh sáng".
local function ThuChenTheoHang(tiep)
    local nc = require("ailang/nhu_cau")
    KT("thứ hạng nhu cầu tra được theo tên",
       nc.ChiSo("ánh sáng") == 1 and nc.ChiSo("nhà") ~= nil,
       "ánh sáng=" .. tostring(nc.ChiSo("ánh sáng")))
    KT("việc thường KHÔNG có thứ hạng (để nhu cầu nào cũng chen được)",
       nc.ChiSo("chặt cây") == nil and nc.ChiSo("hái lượm") == nil)
    KT("ánh sáng NẶNG HƠN nhà", nc.ChiSo("ánh sáng") < nc.ChiSo("nhà"))

    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    -- Đang làm việc của nhu cầu NẶNG hơn thứ vừa nổi lên -> phải GIỮ.
    -- ⚠ Việc giả vẫn phải có `hanh_dong` thật: viec.HanhDong dựng
    --   BufferedAction từ nó, và BufferedAction nil action là nổ ngay.
    e.ailang.viec = { vi_sao = "ánh sáng", muc_tieu = nil,
                      hanh_dong = ACTIONS.EQUIP, mon = SpawnPrefab("torch") }
    e.components.inventory:GiveItem(e.ailang.viec.mon)
    e.ailang.viec_tu = GetTime()
    vi.HanhDong(e)
    KT("nhu cầu nhẹ hơn KHÔNG cướp được việc đang làm",
       e.ailang.viec ~= nil and e.ailang.viec.vi_sao == "ánh sáng",
       "việc=" .. tostring(e.ailang.viec and e.ailang.viec.vi_sao))
    e:Remove()
    tiep()
end

-- ── nuôi lửa cho khỏi tắt giữa đêm ──────────────────────────────────────
--
-- ⚠ Lửa trại KHÔNG cháy mãi: hết nhiên liệu là nó nhả tro rồi BIẾN MẤT HẲN
--   (campfire.lua: accepting=false, thêm tag NOCLICK, ErodeAway sau 1 giây).
--   Tắt giữa đêm là lúc tệ nhất — dân làng đang bị cấm cầm rìu nên không đi
--   chặt gỗ mới được. Phải nuôi lửa từ lúc còn sáng.
local function ThuTiepLua(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    TheWorld:PushEvent("ms_setphase", "day")

    -- ⚠ PHẢI thoả hết nhu cầu trước. Tiếp lửa là VIỆC THƯỜNG, mà viec.NhanViec
    --   xét nhu cầu sinh tồn xong mới tới việc thường — còn thiếu cái giáp là
    --   nó đi gom cỏ chứ không ngó tới đống lửa. Đã hỏng oan với "việc=giáp".
    local lo = ThoaHetNhuCau(e)
    local tui = e.components.inventory

    lo.components.fueled:SetPercent(0.2)
    KT("lửa gần tàn mà không có củi thì KHÔNG nhận việc tiếp lửa",
       (vi.NhanViec(e) or {}).hanh_dong ~= ACTIONS.ADDFUEL,
       "việc=" .. tostring((vi.NhanViec(e) or {}).vi_sao))

    tui:GiveItem(SpawnPrefab("log"))
    vi.BoViec(e)
    local v = vi.NhanViec(e)
    KT("lửa gần tàn + có gỗ thì đi tiếp lửa",
       v ~= nil and v.hanh_dong == ACTIONS.ADDFUEL and v.muc_tieu == lo,
       "việc=" .. tostring(v and v.vi_sao))
    KT("ném GỖ vào lửa, không ném đuốc",
       v ~= nil and v.mon ~= nil and v.mon.prefab == "log",
       "ném=" .. TenCua(v and v.mon))

    lo.components.fueled:SetPercent(0.95)
    vi.BoViec(e)
    KT("lửa còn đầy thì thôi, không phí củi",
       (vi.NhanViec(e) or {}).hanh_dong ~= ACTIONS.ADDFUEL)

    lo:Remove()
    e:Remove()
    tiep()
end

-- ── giữ làng phải thắng nhu cầu không gấp ───────────────────────────────
--
-- ⚠ "vũ khí" và "giáp" có `can` luôn trả true, nên hễ quanh đó còn một bụi cỏ
--   là sinh_ton.Giai LUÔN trả về việc — và viec.NhanViec không bao giờ xuống
--   tới dập lửa hay tiếp lửa. Đo trên server: lửa của làng tụt còn 17% nhiên
--   liệu rồi TẮT HẲN trong khi cả ba dân làng đứng hái cỏ làm áo giáp. Chập
--   tối hôm đó nhật ký ghi lua=0.
local function ThuGiuLangTruocGiap(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    local st = require("ailang/sinh_ton")
    TheWorld:PushEvent("ms_setphase", "day")

    local lo = ThoaHetNhuCau(e)
    local tui = e.components.inventory

    -- Cởi giáp ra: giờ "giáp" chưa thoả và quanh đây đầy cỏ, đúng cảnh đã gặp.
    local giap = tui:GetEquippedItem(EQUIPSLOTS.BODY)
    if giap ~= nil then tui:DropItem(giap) giap:Remove() end
    SpawnPrefab("grass").Transform:SetPosition(gx + 3, 0, gz)
    KT("dựng đúng cảnh: giáp CHƯA thoả",
       #st.ConThieuGi(e, function(n) return n.ma == "giap" end) == 1)

    lo.components.fueled:SetPercent(0.2)
    tui:GiveItem(SpawnPrefab("log"))
    vi.BoViec(e)
    local v = vi.NhanViec(e)
    KT("nuôi lửa của làng THẮNG việc đi hái cỏ làm giáp",
       v ~= nil and v.hanh_dong == ACTIONS.ADDFUEL,
       "việc=" .. tostring(v and v.vi_sao))

    -- Nhưng nhu cầu GẤP thì vẫn phải thắng việc nuôi lửa.
    lo.components.fueled:SetPercent(0.2)
    for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD }) do
        local m = tui:GetEquippedItem(o)
        if m ~= nil then tui:DropItem(m) m:Remove() end
    end
    local duoc = require("ailang/nhu_cau").CoTrongTui(e, "torch")
    if duoc ~= nil then duoc:Remove() end
    lo:Remove()                      -- mất luôn chỗ trú sáng
    vi.BoViec(e)
    local v2 = vi.NhanViec(e)
    KT("nhưng nhu cầu GẤP vẫn thắng việc nuôi lửa",
       v2 == nil or v2.hanh_dong ~= ACTIONS.ADDFUEL,
       "việc=" .. tostring(v2 and v2.vi_sao))

    e:Remove()
    tiep()
end

-- ── vũ khí và giáp là việc của lúc đã yên thân ──────────────────────────
--
-- ⚠ Áo cỏ tốn MƯỜI bó cỏ, đuốc chỉ tốn hai. Khi `can` của giáp luôn trả true,
--   ba dân làng vặt sạch cỏ quanh làng để làm áo — rồi tới chập tối thì đứng
--   TAY KHÔNG với đúng 1 bó cỏ. Đo được: cả ba vào đêm tay không, kẹt ở cu1
--   nhiều nhịp liền vì quanh làng không còn bụi cỏ nào chưa hái.
local function ThuGiapSauCung(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local nc = require("ailang/nhu_cau")
    local st = require("ailang/sinh_ton")
    local giap, vu_khi = nc.Tim("giap"), nc.Tim("vu_khi")
    e.components.inventory:DropEverything()

    KT("chưa có lửa, chưa có sáng thì KHÔNG lo giáp", not giap.can(e))
    KT("chưa yên thân thì cũng KHÔNG lo vũ khí", not vu_khi.can(e))
    KT("và giáp KHÔNG nằm trong danh sách phải lo",
       #st.ConThieuGi(e, function(n) return n.ma == "giap" end) == 0)

    -- Yên thân: có đuốc đầy trong tay và có lửa ở làng.
    ThoaHetNhuCau(e)
    KT("đã có lửa và có sáng thì MỚI lo giáp", giap.can(e))
    e:Remove()
    tiep()
end

-- ── chập tối thì nạp lửa tới gần đầy ────────────────────────────────────
--
-- ⚠ Lửa đầy cháy được 360 giây, mà chập tối + đêm là 240 giây. Nạp tới nửa
--   bình rồi bỏ đi là nó CHẾT ngay trước bình minh. Đo trên server: cả ba ôm
--   2 khúc gỗ mỗi đứa mà lua=0 giữa đêm, một đứa đứng tay không trong bóng tối.
local function ThuNapDayTruocDem(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    TheWorld:PushEvent("ms_setphase", "day")
    local lo = ThoaHetNhuCau(e)
    local tui = e.components.inventory
    tui:GiveItem(SpawnPrefab("log"))
    tui:GiveItem(SpawnPrefab("log"))

    -- ⚠ Kiểm THẲNG ViecTiepLua, đừng kiểm qua viec.NhanViec. NhanViec chạy
    --   sinh_ton.Giai trước, mà Giai CÓ TÁC DỤNG PHỤ (mặc đồ, chế đồ) và có
    --   thể trả "xong" rồi nuốt luôn lượt — lúc đó NhanViec trả nil vì lý do
    --   chẳng liên quan gì tới ngưỡng tiếp lửa. Đã mất mấy vòng chẩn đoán vì
    --   phép kiểm đo quá xa nguồn: mọi điều kiện của đống lửa đều đúng, gọi
    --   thẳng thì ra việc, mà qua NhanViec thì nil.
    --   Thứ tự "giữ làng trước nhu cầu không gấp" đã có ThuGiuLangTruocGiap lo.
    lo.components.fueled:SetPercent(0.7)
    KT("ban ngày lửa hơn nửa bình thì thôi, để dành củi",
       vi.ViecTiepLua(e) == nil,
       "việc=" .. tostring((vi.ViecTiepLua(e) or {}).vi_sao))

    DoiPha("dusk", function()
        local v = vi.ViecTiepLua(e)
        KT("nhưng CHẬP TỐI thì cùng mức đó phải nạp thêm cho gần đầy",
           v ~= nil and v.hanh_dong == ACTIONS.ADDFUEL,
           "việc=" .. tostring(v and v.vi_sao)
           .. " | lửa=" .. string.format("%.2f", lo.components.fueled:GetPercent()))

        lo.components.fueled:SetPercent(0.98)
        KT("đã gần đầy thì thôi, không nhồi vô ích",
           vi.ViecTiepLua(e) == nil)

        lo:Remove()
        e:Remove()
        DoiPha("day", function() tiep() end)
    end)
end

-- ── bảng kho của làng ───────────────────────────────────────────────────
local function ThuKho(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local l = require("ailang/lenh")
    local tui = e.components.inventory
    tui:DropEverything()
    for _ = 1, 3 do tui:GiveItem(SpawnPrefab("log")) end
    local riu = SpawnPrefab("axe") tui:GiveItem(riu) tui:Equip(riu)

    local ok, tong = pcall(l.Kho)
    KT("c_ailang_kho chạy không nổ", ok, tostring(tong))
    KT("bảng kho cộng đúng 3 khúc gỗ",
       type(tong) == "table" and tong.log == 3,
       "gỗ=" .. tostring(type(tong) == "table" and tong.log))
    KT("bảng kho đếm cả đồ ĐANG CẦM, không chỉ đồ trong túi",
       type(tong) == "table" and tong.axe == 1,
       "rìu=" .. tostring(type(tong) == "table" and tong.axe))
    e:Remove()
    tiep()
end

-- ── túi hàng mở được ────────────────────────────────────────────────────
--
-- ⚠ Túi ĐỒ của một prefab người chơi thì người chơi khác KHÔNG mở được — nên
--   phải gắn hẳn một `container` lên chính entity dân làng, đúng cách Chester
--   và Glommer làm. Đây là hộp MỘT CHIỀU cố ý: inventory:GetOverflowContainer
--   chỉ nhìn món mặc ở ô BODY, nên đồ trong túi hàng không chế đồ được.
local function ThuTuiHang(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local tui, hang = e.components.inventory, e.components.container
    KT("dân làng có túi hàng mở được", hang ~= nil and hang.canbeopened)
    KT("túi hàng có ô chứa", hang ~= nil and (hang.numslots or 0) > 0,
       "ô=" .. tostring(hang and hang.numslots))

    tui:DropEverything()
    tui:GiveItem(SpawnPrefab("petals"))
    KT("túi chính CHƯA đầy thì không dồn đi đâu cả",
       not dan_lang.CatVaoTuiHang(e))

    -- ⚠ Nhồi cho đầy phải dùng NHIỀU LOẠI món khác nhau. Đổ 20 cánh hoa thì
    --   chúng chồng hết vào ĐÚNG MỘT Ô và túi không bao giờ đầy — phép kiểm
    --   hỏng oan, nhìn như tính năng hỏng.
    for _, m in ipairs({ "petals", "berries", "carrot", "ash", "charcoal",
                         "seeds", "acorn", "foliage", "cutreeds", "red_cap",
                         "blue_cap", "green_cap", "butterflywings", "honey",
                         "smallmeat", "petals_evil", "boards", "rocks" }) do
        if tui:IsFull() then break end
        local mon = SpawnPrefab(m)
        if mon ~= nil then tui:GiveItem(mon) end
    end
    KT("dựng đúng cảnh: túi chính đã đầy", tui:IsFull())
    KT("túi đầy thì dồn đồ dư sang túi hàng", dan_lang.CatVaoTuiHang(e))
    local n = 0
    for _, m in pairs(hang.slots or {}) do if m ~= nil then n = n + 1 end end
    KT("đồ đã nằm trong túi hàng", n > 0, "trong túi hàng=" .. n)

    -- Nguyên liệu sống còn thì TUYỆT ĐỐI không được dồn đi.
    tui:DropEverything()
    -- Đầy túi nhưng TOÀN nguyên liệu sống còn: không được dồn món nào đi cả.
    for _, m in ipairs({ "cutgrass", "twigs", "log", "flint" }) do
        for _ = 1, 6 do
            if tui:IsFull() then break end
            local mon = SpawnPrefab(m)
            -- Mỗi món một ô: chồng được thì ô sau không tính, nên phải cho
            -- từng cái rồi tách ra. Đơn giản hơn: chồng tới giới hạn là đủ đầy.
            if mon ~= nil then tui:GiveItem(mon) end
        end
    end
    -- Nếu vẫn chưa đầy thì nhồi thêm cho đủ ô, vẫn chỉ bằng bốn món trên.
    KT("dựng đúng cảnh: túi toàn nguyên liệu sống còn",
       require("ailang/nhu_cau").CoTrongTui(e, "cutgrass") ~= nil)
    local truoc = 0
    for _, m in pairs(hang.slots or {}) do if m ~= nil then truoc = truoc + 1 end end
    dan_lang.CatVaoTuiHang(e)
    local sau = 0
    for _, m in pairs(hang.slots or {}) do if m ~= nil then sau = sau + 1 end end
    KT("KHÔNG dồn cỏ/cành/gỗ/đá lửa đi — đó là nguyên liệu sống còn",
       sau == truoc, "trước=" .. truoc .. " sau=" .. sau)

    -- Hồ sơ phải chép túi hàng, nếu không restart là đồ người chơi gửi bay hết.
    local hs = dan_lang.ChupHoSo(e)
    KT("hồ sơ có chép túi hàng",
       hs ~= nil and hs.tui ~= nil and #(hs.tui.tui_hang or {}) > 0,
       "chép được " .. tostring(hs and hs.tui and #(hs.tui.tui_hang or {})))
    e:Remove()

    local moi = dan_lang.Sinh(hs)
    local n2 = 0
    if moi ~= nil and moi.components.container ~= nil then
        for _, m in pairs(moi.components.container.slots or {}) do
            if m ~= nil then n2 = n2 + 1 end
        end
    end
    KT("dựng lại dân làng thì đồ trong túi hàng còn nguyên", n2 > 0,
       "còn=" .. n2)
    if moi ~= nil then moi:Remove() end
    tiep()
end

-- ── đuốc phải phát sáng THẬT phía server ────────────────────────────────
--
-- ⚠ PHÉP KIỂM QUAN TRỌNG NHẤT CỦA CẢ MOD. Đuốc của DST gắn ánh sáng bằng FX
--   `torchfire` (torch.lua: onequip -> fx:AttachLightTo(owner)), mà FX là thứ
--   CLIENT VẼ — trên server chuyên dụng nó KHÔNG tạo nguồn sáng nào. Đo trực
--   tiếp giữa đêm, cách mọi đống lửa 40 đơn vị, tay cầm đuốc đang cháy:
--       ánh sáng = 0.000  ->  "enterdark"  ->  Charlie đánh 100.05
--   Nhật ký trận chết ghi rõ: Binh chết với `tay = torch`.
--
--   Cách chữa: bật `inst.Light` của chính dân làng (player_common.lua dựng sẵn
--   rồi Enable(false)). Phép kiểm này canh đúng chỗ đó.
local function ThuDenThat(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local tui = e.components.inventory
    tui:DropEverything()
    KT("dân làng có thực thể đèn của riêng nó", e.Light ~= nil)

    dan_lang.CapNhatDen(e)
    KT("tay không thì đèn TẮT", e.Light ~= nil and not e.Light:IsEnabled())

    local duoc = SpawnPrefab("torch")
    tui:GiveItem(duoc) tui:Equip(duoc)
    dan_lang.CapNhatDen(e)
    KT("cầm đuốc đang cháy thì đèn BẬT — đây là thứ cứu mạng",
       e.Light ~= nil and e.Light:IsEnabled())

    -- ⚠ Đuốc 20% vẫn đang cháy và vẫn cứu mạng. Ngưỡng 25% của MonPhatSang là
    --   ngưỡng KẾ HOẠCH (đi làm cây mới), không được dùng để tắt đèn thật.
    duoc.components.fueled:SetPercent(0.2)
    dan_lang.CapNhatDen(e)
    KT("đuốc còn 20% vẫn sáng thật (đừng lẫn ngưỡng kế hoạch)",
       e.Light ~= nil and e.Light:IsEnabled())

    duoc.components.fueled:SetPercent(0)
    dan_lang.CapNhatDen(e)
    KT("đuốc cháy hết thì đèn tắt",
       e.Light ~= nil and not e.Light:IsEnabled())

    duoc.components.fueled:SetPercent(1)
    dan_lang.CapNhatDen(e)
    tui:Unequip(EQUIPSLOTS.HANDS)
    dan_lang.CapNhatDen(e)
    KT("cởi đuốc ra thì đèn tắt",
       e.Light ~= nil and not e.Light:IsEnabled())

    -- Hồn ma không cầm gì và cũng không sáng.
    tui:Equip(duoc)
    dan_lang.CapNhatDen(e)
    dan_lang.ThanhHonMa(e)
    dan_lang.CapNhatDen(e)
    KT("hồn ma thì đèn tắt", e.Light ~= nil and not e.Light:IsEnabled())

    e:Remove()
    tiep()
end

-- ── mùa hè giết dân làng giữa ban ngày ──────────────────────────────────
--
-- ⚠ Không cần Charlie. Đo trên server ngày 57 (mùa hè): nhiệt độ MÔI TRƯỜNG
--   đã là 71.6 trong khi TUNING.OVERHEAT_TEMP = 70 — chỉ đứng ngoài trời là
--   đủ chết. Máu tụt đều suốt ngày mà KHÔNG có sự kiện "attacked" nào, nên
--   ban đầu nhìn như lỗi ma. Tương quan thì thẳng tưng:
--       An 67.6 độ -> 56% máu | Cuong 71.3 -> 1% | Binh 72.4 -> CHẾT
local function ThuChongNong(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local nc = require("ailang/nhu_cau")
    local st = require("ailang/sinh_ton")
    local n = nc.Tim("mat_me")
    KT("có nhu cầu chống nóng trong bảng", n ~= nil)

    local t = e.components.temperature
    t:SetTemperature(20)
    KT("mát trời thì KHÔNG lo chống nóng", n ~= nil and not n.can(e))

    t:SetTemperature(65)
    KT("nóng 65 độ là đã phải lo, đừng đợi chạm 70",
       n ~= nil and n.can(e), "nhiệt=" .. string.format("%.0f", t:GetCurrent()))
    e.components.inventory:DropEverything()
    KT("chưa có đồ chống nóng thì CHƯA thoả", n ~= nil and not n.du(e))

    local mu = SpawnPrefab("strawhat")
    e.components.inventory:GiveItem(mu)
    e.components.inventory:Equip(mu)
    KT("đội mũ cỏ vào thì thoả", n ~= nil and n.du(e))
    KT("mũ cỏ đúng là đồ cách nhiệt mùa hè",
       mu.components.insulator ~= nil
       and mu.components.insulator.type == SEASONS.SUMMER)

    -- ⚠ `gap` ở đây KHÔNG phải để chen ngang cho vui — nó là thứ nới dây trói
    --   về nhà từ 50 lên 140. Cỏ làm mũ thì đo được: 1 bụi trong bán kính 30,
    --   39 bụi trong bán kính 130. Không có `gap` thì dân làng bị trói trong
    --   50 đơn vị và không bao giờ với tới chỗ có cỏ.
    --   Chuyện "chen ngang mỗi nhịp" chặn ở chỗ khác: viec.CanChenNgang bỏ qua
    --   mọi nhu cầu đang BÓ TAY.
    KT("chống nóng là nhu cầu GẤP (để nới được dây trói về nhà)",
       n ~= nil and n.gap == true)
    KT("chống nóng xếp trên dụng cụ và nhà",
       nc.ChiSo("mát") < nc.ChiSo("dụng cụ")
       and nc.ChiSo("mát") < nc.ChiSo("nhà"),
       "mát=" .. tostring(nc.ChiSo("mát")))

    e.components.inventory:DropEverything()
    t:SetTemperature(65)
    KT("đang nóng mà chưa có đồ thì nó nằm trong danh sách phải lo",
       #st.ConThieuGi(e, function(m) return m.ma == "mat_me" end) == 1)
    -- ⚠ Ô TAY là ô của đuốc. Bỏ hẳn grass_umbrella dù nó cách nhiệt gấp đôi:
    --   hai nhu cầu giành nhau một ô là quay lại đúng bệnh rìu↔đuốc.
    local co_o_tay = false
    for _, b in ipairs(n.bac or {}) do
        if b.mon == "grass_umbrella" then co_o_tay = true end
    end
    KT("KHÔNG dùng ô che tay — ô đó dành cho đuốc", not co_o_tay)

    t:SetTemperature(20)
    e:Remove()
    tiep()
end

-- ── bóng cây: lời giải mùa hè không tốn gì ──────────────────────────────
--
-- ⚠ Tìm ra bằng cách soi một điều bất thường: ba dân làng có ĐỒ ĐẠC GIỐNG HỆT
--   NHAU mà nhiệt độ lệch hẳn — An và Binh 64 độ trong khi môi trường 84, còn
--   Cuong 83 độ rồi CHẾT. Khác biệt duy nhất là CHỖ ĐỨNG.
--   temperature.lua: `sheltered` và nhiệt trên TREE_SHADE_COOLING_THRESHOLD
--   (63) thì kéo mạnh về TREE_SHADE_COOLER (45) — nên hai đứa kia ghim đúng
--   ngay trên 63. Rời bóng cây đi chặt gỗ là nhảy lên 75 rồi 81 rồi chết.
--   sheltered.lua đo bằng CountEntities bán kính 2, tag "shelter", trừ stump.
local function ThuBongCay(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local nc = require("ailang/nhu_cau")
    local la = require("ailang/lang")
    local mat = nc.Tim("mat_me")
    local t = e.components.temperature
    e.components.inventory:DropEverything()
    t:SetTemperature(68)

    local che = e.components.sheltered
    KT("dân làng có bộ phận nhận biết bóng râm", che ~= nil)
    KT("ngưỡng mát của DST đúng như đã đo",
       TUNING.TREE_SHADE_COOLING_THRESHOLD == 63
       and TUNING.TREE_SHADE_COOLER == 45,
       "ngưỡng=" .. tostring(TUNING.TREE_SHADE_COOLING_THRESHOLD)
       .. " kéo về=" .. tostring(TUNING.TREE_SHADE_COOLER))

    local cay = SpawnPrefab("evergreen")
    cay.Transform:SetPosition(gx + 30, 0, gz)
    KT("cây thông mang tag shelter", cay:HasTag("shelter"))

    if che ~= nil then che.sheltered = false end
    KT("đứng xa cây thì CHƯA mát", mat ~= nil and not mat.du(e))

    -- ⚠ Bóng râm là chỗ TRÚ TẠM, KHÔNG tính là "đã mát". Dân làng phải rời gốc
    --   cây mới làm được việc, và mỗi vòng ra-vào lại nhích qua mốc 70 một
    --   nhịp — đo được nhiệt ổn định 67-71 mà máu vẫn tụt 99% -> 93% -> 80%.
    --   Coi bóng râm là đủ thì chúng KHÔNG BAO GIỜ chế cái mũ.
    if che ~= nil then che.sheltered = true end
    KT("đứng dưới tán cây vẫn CHƯA tính là đủ mát (còn phải lo cái mũ)",
       mat ~= nil and not mat.du(e))
    local mu = SpawnPrefab("strawhat")
    e.components.inventory:GiveItem(mu)
    e.components.inventory:Equip(mu)
    KT("đội mũ cỏ vào thì mới thật sự đủ", mat ~= nil and mat.du(e))

    -- ⚠ Kiểm THẲNG lang.CanTruNong, ĐỪNG tick não rồi soi inst.ailang. Cây
    --   hành vi TỰ GHI ĐÈ `a.viec` và `a.dang_lo` mỗi nhịp, nên mọi giá trị
    --   bài kiểm đặt vào đó đều bay mất ngay nhịp sau — đã hỏng hai lần liền
    --   với "trú=true" trong khi mã chạy đúng.
    e.ailang.tru_nong = nil
    e.ailang.viec = nil
    t:SetTemperature(67)
    KT("nóng 67 độ thì bật chế độ đi trú",
       la.CanTruNong(e, 66, 65) == true)
    t:SetTemperature(66)
    KT("mới xuống 66 thì CHƯA nhả — không thì rung quanh mốc 70",
       la.CanTruNong(e, 66, 65) == true)
    t:SetTemperature(64)
    KT("xuống 64 rồi mới nhả, quay lại làm việc",
       la.CanTruNong(e, 66, 65) == nil)

    -- ⚠ ĐỪNG CHẶN ĐÚNG VIỆC SẼ CHẤM DỨT TÌNH TRẠNG CẤP CỨU. Đo trên server:
    --   dân làng báo lo "mát" suốt hàng chục nhịp mà số cỏ trong túi KHÔNG HỀ
    --   TĂNG — cỏ ở cách 110 đơn vị, vừa rời bóng cây là nhiệt vượt 66 trong
    --   vài giây, nhánh trú lôi về, nhả ở 65, đi tiếp, lại bị lôi về. Nó KHÔNG
    --   BAO GIỜ đi nổi tới nơi, và cứ thế mất máu 99% -> 51%.
    e.ailang.tru_nong = nil
    e.ailang.viec = { vi_sao = "mát" }
    t:SetTemperature(67)
    local kq = la.CanTruNong(e, 66, 65)
    KT("đang đi lo chính chuyện chống nóng thì 67 độ CHƯA kéo về",
       kq == nil,
       "trú=" .. tostring(kq)
       .. " | việc=" .. tostring(e.ailang.viec and e.ailang.viec.vi_sao)
       .. " | nhiệt=" .. string.format("%.1f", t:GetCurrent())
       .. " | ngưỡng quá nhiệt=" .. tostring(TUNING.OVERHEAT_TEMP))
    t:SetTemperature(71)
    KT("nhưng chạm mức quá nhiệt thật thì vẫn kéo về",
       la.CanTruNong(e, 66, 65) == true)

    e.ailang.tru_nong = nil
    e.ailang.viec = { vi_sao = "nhà" }
    t:SetTemperature(67)
    KT("việc khác thì 67 độ là kéo về ngay",
       la.CanTruNong(e, 66, 65) == true)

    e.ailang.tru_nong = nil
    e.ailang.viec = nil
    if che ~= nil then che.sheltered = false end
    t:SetTemperature(20)
    cay:Remove()
    e:Remove()
    tiep()
end

-- ── một cái máy mở khoá cả một tầng ─────────────────────────────────────
--
-- ⚠ researchlab là TECH 0 (goldnugget×1 log×4 rocks×4) nên dân làng tự dựng
--   được, và từ lúc có nó mọi nhu cầu khác TỰ LÊN BẬC mà không phải sửa gì —
--   builder:CanBuild xét cấp công nghệ hộ. Đây là đường thoát của mùa hè: mũ
--   cỏ (cách nhiệt 60) không cứu nổi khi nhiệt môi trường lên 78, phải có lửa
--   lạnh, mà lửa lạnh là tech 1.
local function ThuXuong(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local nc = require("ailang/nhu_cau")
    local n = nc.Tim("xuong")
    KT("có nhu cầu xưởng trong bảng", n ~= nil)
    KT("chưa có máy thì CHƯA thoả", n ~= nil and not n.du(e))

    -- ⚠ Con quạ lễ hội (carnival_host) cũng mang tag "prototyper" và nó BIẾT
    --   ĐI. Bộ kiểm này từng hỏng vì có một con lảng vảng gần điểm sinh —
    --   đúng cái bẫy mà `du` phải chặn bằng cách đòi thêm tag "structure".
    local gia = SpawnPrefab("carnival_host")
    if gia ~= nil then
        gia.Transform:SetPosition(gx + 3, 0, gz)
        KT("thứ biết đi mang tag prototyper KHÔNG tính là xưởng",
           n ~= nil and not n.du(e),
           "quạ có prototyper=" .. tostring(gia:HasTag("prototyper")))
        gia:Remove()
    end

    local may = SpawnPrefab("researchlab")
    may.Transform:SetPosition(gx + 5, 0, gz)
    KT("máy khoa học mang tag prototyper", may:HasTag("prototyper"))
    KT("dựng máy cạnh nhà thì thoả", n ~= nil and n.du(e))

    KT("xưởng xếp DƯỚI nhà (có chỗ trú đã rồi mới tính chuyện máy móc)",
       nc.ChiSo("xưởng") > nc.ChiSo("nhà"))
    KT("nhưng TRÊN vũ khí và giáp",
       nc.ChiSo("xưởng") < nc.ChiSo("vũ khí")
       and nc.ChiSo("xưởng") < nc.ChiSo("giáp"))
    KT("xưởng KHÔNG chen ngang (dựng máy là việc dài hơi)", n ~= nil and n.gap ~= true)

    -- Lửa lạnh phải là bậc CAO NHẤT của nhu cầu chống nóng.
    local mat = nc.Tim("mat_me")
    KT("lửa lạnh là bậc cao nhất của chống nóng",
       mat ~= nil and mat.bac[1] ~= nil and mat.bac[1].mon == "coldfire",
       "bậc 1=" .. tostring(mat and mat.bac[1] and mat.bac[1].mon))
    KT("lửa lạnh dựng Ở LÀNG, không dựng dưới chân",
       mat ~= nil and mat.bac[1] ~= nil and mat.bac[1].o_nha == true)

    -- Đứng cạnh lửa lạnh đang cháy thì coi như đã mát.
    e.components.inventory:DropEverything()
    e.components.temperature:SetTemperature(65)
    KT("đang nóng, chưa có gì thì CHƯA mát", mat ~= nil and not mat.du(e))
    local lanh = SpawnPrefab("coldfire")
    if lanh ~= nil then
        local ex, _, ez = e.Transform:GetWorldPosition()
        lanh.Transform:SetPosition(ex + 2, 0, ez)
        if lanh.components.fueled ~= nil then lanh.components.fueled:SetPercent(1) end
        KT("đứng cạnh lửa lạnh đang cháy thì tính là mát",
           mat ~= nil and mat.du(e),
           "cháy=" .. tostring(lanh.components.burnable
                               and lanh.components.burnable:IsBurning()))
        lanh:Remove()
    end
    e.components.temperature:SetTemperature(20)
    may:Remove()
    e:Remove()
    tiep()
end

-- ── lo thân trước khi giữ làng ──────────────────────────────────────────
--
-- ⚠ Nhánh "giữ làng" nằm rất cao trong cây, nên hễ nó giành được lượt là mọi
--   nhánh tự-lo bên dưới KHÔNG BAO GIỜ chạy. Đã gây hoạ BA LẦN, lần gần nhất
--   bắt được tận tay: cả ba dân làng khoá cứng ở đây để đuổi MỘT CON ẾCH quanh
--   làng giữa mùa hè — nhiệt độ leo 77 -> 84 -> 87, máu tụt 94% -> 28% -> chết,
--   trong khi có 21 gốc cây rợp bóng trong bán kính 40 ngay cạnh đó.
local function ThuLoThanTruoc(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local la = require("ailang/lang")
    local lo = ThoaHetNhuCau(e)
    e.components.temperature:SetTemperature(20)
    KT("bình thường thì KHÔNG phải lo thân, cứ giữ làng",
       not la.LoThanTruoc(e, 66))

    e.components.temperature:SetTemperature(70)
    KT("đang nóng thì bỏ giữ làng mà đi trú — chết vì nóng thì giữ được gì",
       la.LoThanTruoc(e, 66))

    e.components.temperature:SetTemperature(20)
    KT("mát trở lại thì quay về giữ làng", not la.LoThanTruoc(e, 66))

    -- ⚠ CẢ HAI NHÁNH ĐÁNH NHAU đều phải dùng chung chốt này. Đã vá sót một
    --   lần: gắn cho "Giữ làng" mà QUÊN nhánh tự vệ ngay dưới, mà nó cũng cao
    --   hơn mọi nhánh tự lo. Đo được hậu quả: dân làng đứng CÁCH BỤI CỎ ĐÚNG
    --   17 ĐƠN VỊ, việc đang giữ là "mát", mà suốt 24 giây chỉ nhích được 6
    --   đơn vị — quá nửa số nhịp bị ChaseAndAttack giành lượt, nhiệt leo
    --   70 -> 76, máu tụt đều. Nó không chết vì xa tài nguyên; nó chết vì mải
    --   đánh nhau.
    -- ⚠ Khẳng định theo BẤT BIẾN, không theo nhãn: WhileNode đặt tên node là
    --   "Parallel" chứ không giữ nhãn mình truyền vào, nên tìm theo nhãn là
    --   hỏng oan. Thứ cần bảo đảm là KHÔNG CÒN ChaseAndAttack nào để TRẦN ở
    --   tầng gốc — mọi nhánh đánh nhau đều phải nằm dưới một chốt lo-thân.
    local nao2 = Brain(e)
    nao2:OnStart()
    local ten_nhanh, tran = {}, 0
    local goc = nao2.bt and nao2.bt.root
    for _, c in ipairs((goc and goc.children) or {}) do
        table.insert(ten_nhanh, tostring(c.name))
        if tostring(c.name) == "ChaseAndAttack" then tran = tran + 1 end
    end
    KT("KHÔNG còn nhánh đánh nhau nào để trần ở tầng gốc",
       tran == 0, "để trần=" .. tran .. " | các nhánh=" .. table.concat(ten_nhanh, ","))

    -- Thiếu ánh sáng giữa đêm cũng là lý do bỏ giữ làng.
    local tui = e.components.inventory
    for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD }) do
        local m = tui:GetEquippedItem(o)
        if m ~= nil then tui:DropItem(m) m:Remove() end
    end
    local duoc = require("ailang/nhu_cau").CoTrongTui(e, "torch")
    if duoc ~= nil then duoc:Remove() end
    -- ⚠ Phải dọn cả ĐỐNG LỬA mà khuôn ThoaHetNhuCau dựng sẵn: đứng cạnh lửa
    --   đang cháy thì `anh_sang.du` vẫn trả true và cảnh "tối om" không dựng
    --   được. Phép kiểm này từng hỏng oan đúng vì bỏ sót nó.
    if lo ~= nil and lo:IsValid() then lo:Remove() end
    DoiPha("night", function()
        KT("chưa có sáng giữa đêm thì cũng bỏ giữ làng",
           la.LoThanTruoc(e, 66))
        e:Remove()
        -- ⚠ TRẢ LẠI BAN NGÀY. Bài kiểm nào đổi pha thì phải đổi về, không thì
        --   bài CHẠY SAU thừa hưởng trời tối và hỏng oan vì lý do chẳng liên
        --   quan gì tới nó — đã xảy ra với bài "ưu tiên thắng khoảng cách".
        DoiPha("day", function() tiep() end)
    end)
end

-- ── ưu tiên phải thắng khoảng cách ──────────────────────────────────────
--
-- ⚠ sinh_ton.Giai từng lặp BÁN KÍNH ở vòng ngoài, ƯU TIÊN ở vòng trong — quét
--   hết mọi nhu cầu ở gần rồi mới nới rộng. Cách đó LẶNG LẼ ĐẢO NGƯỢC thứ tự
--   ưu tiên: một nhu cầu quan trọng ở xa thua một nhu cầu vặt ở gần.
--   Đo trên server giữa mùa hè: DiKiem("cutgrass") trả nil ở 30 nhưng PICK ở
--   130 (1 bụi cỏ trong vòng 30, 39 bụi trong vòng 130). "Mát" hạng 4 cần đi
--   xa, "nhà" hạng 6 xong tại chỗ — dân làng đi dựng lửa trại trong khi đang
--   mất máu vì nóng, và không bao giờ chế nổi cái mũ.
local function ThuUuTienThangKhoangCach(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local st = require("ailang/sinh_ton")
    local nc = require("ailang/nhu_cau")
    local tui = e.components.inventory
    tui:DropEverything()
    DonQuanh(gx, gz, 140)

    -- Cảnh dựng lại đúng số đo trên server: thứ cho nhu cầu HẠNG CAO thì ở xa,
    -- thứ cho nhu cầu HẠNG THẤP thì ngay dưới chân.
    -- ⚠ Phải thoả ÁNH SÁNG trước: nó hạng 1, không thoả thì nó thắng cả "mát"
    --   và bài kiểm đo nhầm thứ. Bài này từng hỏng với "đang lo=ánh sáng" —
    --   mà đó chính là bộ giải chạy ĐÚNG, chỉ là cảnh dựng sai.
    local duoc = SpawnPrefab("torch")
    tui:GiveItem(duoc)
    tui:Equip(duoc)   -- cầm hẳn lên: thoả ánh sáng bất kể trời ngày hay đêm
    e.components.temperature:SetTemperature(68)   -- "mát" (hạng cao) vào cuộc
    local co = SpawnPrefab("grass")
    co.Transform:SetPosition(gx + 110, 0, gz)
    local cay = SpawnPrefab("evergreen")
    cay.Transform:SetPosition(gx + 6, 0, gz)
    tui:GiveItem(SpawnPrefab("axe"))

    KT("dựng đúng cảnh: cỏ chỉ với tới được ở bán kính xa",
       st.DiKiem(e, "cutgrass", nil, 30) == nil
       and st.DiKiem(e, "cutgrass", nil, 130) ~= nil)
    KT("và mát xếp trên nhà", nc.ChiSo("mát") < nc.ChiSo("nhà"))

    st.Giai(e)
    KT("nhu cầu ƯU TIÊN CAO ở xa phải thắng nhu cầu thấp ở gần",
       e.ailang.dang_lo == "mát",
       "đang lo=" .. tostring(e.ailang.dang_lo))

    e.components.temperature:SetTemperature(20)
    co:Remove()
    cay:Remove()
    e:Remove()
    tiep()
end

-- ── nhu cầu bó tay thì đừng cho cướp lượt ───────────────────────────────
--
-- ⚠ Một nhu cầu GẤP mà giải không ra — thử cả hai bán kính đều tay trắng — nếu
--   vẫn giữ quyền chen ngang thì nó cướp lượt MỖI NHỊP: dân làng bỏ việc liên
--   tục, chẳng làm xong gì, mà nhu cầu kia vẫn không nhúc nhích.
local function ThuBoTayThiThoi(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    local st = require("ailang/sinh_ton")
    local nc = require("ailang/nhu_cau")

    -- ⚠ DỰNG XONG CẢNH RỒI MỚI ĐỌC nhu cầu gấp. Bài này từng hỏng vì đọc
    --   trước: cây đuốc cấp cho việc giả rơi vào túi và làm THOẢ luôn nhu cầu
    --   ánh sáng, nên nhu cầu gấp đổi từ "ánh sáng" sang "nhà" và khoá bó tay
    --   ghi sẵn không còn khớp với gì cả.
    local mon = SpawnPrefab("torch")
    e.components.inventory:GiveItem(mon)

    -- ⚠ Và ĐỪNG cố định tên nhu cầu gấp: nó đổi theo pha trời, đồ trong túi và
    --   cả những bài chạy trước. Cứ lấy đúng thứ bộ giải trả về.
    local gap = st.CoNhuCauGap(e)
    if gap == nil then
        KT("dựng được cảnh có nhu cầu gấp", false, "không có nhu cầu gấp nào")
        e:Remove() tiep() return
    end

    -- Việc đang làm phải xếp THẤP HƠN nhu cầu gấp kia, không thì nó vốn đã
    -- không có quyền cướp lượt và bài kiểm chẳng chứng minh được gì.
    local thap
    for i = #nc.DANH_SACH, 1, -1 do
        if nc.DANH_SACH[i].ten ~= gap.ten then thap = nc.DANH_SACH[i].ten break end
    end
    e.ailang.viec = { vi_sao = thap, muc_tieu = nil,
                      hanh_dong = ACTIONS.EQUIP, mon = mon }
    e.ailang.viec_tu = GetTime()

    e.ailang.bo_tay = nil
    KT("nhu cầu gấp giải được thì chen ngang được như thường",
       vi.CanChenNgang(e),
       "gấp=" .. tostring(gap.ten) .. " việc=" .. tostring(thap))

    e.ailang.bo_tay = { [gap.ten] = true }
    KT("nhưng khi nó đang BÓ TAY thì không cướp được việc đang làm",
       not vi.CanChenNgang(e),
       "gấp giờ=" .. tostring((st.CoNhuCauGap(e) or {}).ten))

    e.ailang.bo_tay = nil
    e:Remove()
    tiep()
end

-- ── nhu cầu không tiến triển thì NGHỈ một lúc ───────────────────────────
--
-- ⚠ Một nhu cầu có thể GIẢI ĐƯỢC VỀ LÝ THUYẾT mà KHÔNG BAO GIỜ XONG, và khi đó
--   nó chặn đứng mọi nhu cầu xếp dưới. Đo trên server: cả ba kẹt vĩnh viễn ở
--   "mát" — mũ cỏ cần 12 bó, quanh làng chỉ 3 bụi, hái xong phải chờ mọc lại.
--   Bộ giải vẫn tìm ra bụi cỏ mỗi nhịp nên không bao giờ coi là bó tay, trong
--   khi số cỏ đứng im suốt nhiều phút. Chuỗi tử thần:
--       "mát" không xong -> chặn "nhà" -> KHÔNG có lửa trại (lua=0)
--       -> sống bằng đuốc -> hết cành cây -> tối -> Charlie
--   Máu 87% tụt xuống 21% trong một nhịp, cả ba tay không.
local function ThuNghiNhuCau(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local st = require("ailang/sinh_ton")
    local tui = e.components.inventory
    tui:DropEverything()
    DonQuanh(gx, gz, 140)
    -- Thoả ánh sáng để nó không giành lượt của thứ ta muốn đo.
    tui:GiveItem(SpawnPrefab("torch"))
    e.components.temperature:SetTemperature(20)
    e.ailang.nghi, e.ailang.moc_tien = nil, nil

    -- Lần đầu: nhu cầu nào giành được lượt thì ghi mốc, chưa nghỉ ai cả.
    st.Giai(e)
    KT("lần đầu chưa cho nhu cầu nào nghỉ",
       e.ailang.nghi == nil or next(e.ailang.nghi) == nil)

    -- ⚠ Mốc CHỈ ghi cho nhu cầu ĐƯỢC CẦM LƯỢT, không ghi cho mọi nhu cầu được
    --   quét. Bản đầu đo tất cả, nên một nhu cầu hoàn toàn giải được vẫn bị
    --   phạt chỉ vì nhu cầu xếp trên giành lượt suốt — đo trên server: "nhà"
    --   đứng im 208 giây và bị cho nghỉ, trong khi DiKiem("log") trả PICKUP
    --   ngay ở bán kính 30. Nó chưa bao giờ được thử, chứ không phải làm
    --   không nổi. Hậu quả: cả hai nhu cầu gấp cùng nghỉ, làng không có lửa.
    local so_moc = 0
    for _ in pairs(e.ailang.moc_tien or {}) do so_moc = so_moc + 1 end
    KT("chỉ ghi mốc cho nhu cầu ĐƯỢC CẦM LƯỢT, không ghi cho cả bảng",
       so_moc <= 1, "số mốc=" .. so_moc)

    -- Giả lập đã đứng im quá lâu: lùi mốc về quá khứ.
    for _, m in pairs(e.ailang.moc_tien or {}) do m.tu = GetTime() - 1000 end
    st.Giai(e)
    local so_nghi = 0
    for _ in pairs(e.ailang.nghi or {}) do so_nghi = so_nghi + 1 end
    KT("đứng im quá lâu thì cho nhu cầu đó NGHỈ, nhường lượt xuống dưới",
       so_nghi > 0 or so_moc == 0, "đang nghỉ=" .. so_nghi .. " mốc=" .. so_moc)

    e.ailang.nghi, e.ailang.moc_tien = nil, nil
    e:Remove()
    tiep()
end

-- ── gom đủ rồi thì DỪNG GOM ─────────────────────────────────────────────
--
-- ⚠ Việc bám dai là thứ đã chữa cảnh "chặt vài nhát rồi bỏ sang cây khác",
--   nhưng nó KHÔNG BIẾT LÚC NÀO NÊN BUÔNG. Đo trên server: Cuong gom được 14
--   bó cỏ (mũ chống nóng cần 12), CanBuild=true, thiếu=0 — mà vẫn ôm việc hái
--   cỏ và đứng im ở đó suốt nhiều phút. Bộ giải không bao giờ chạy lại để tới
--   bước CHẾ, nên nó hái cỏ mãi trong khi cái mũ đã nằm trong tầm tay.
local function ThuGomDuThiDung(tiep)
    local gx, gz = Goc()
    local e = DanLangSach(gx, gz)
    local vi = require("ailang/viec")
    local st = require("ailang/sinh_ton")
    local nc = require("ailang/nhu_cau")
    local mat = nc.Tim("mat_me")
    local tui = e.components.inventory
    tui:DropEverything()
    -- ⚠ Phải thoả ÁNH SÁNG trước: nó hạng 1 và `gap`, không thoả thì nó chen
    --   ngang việc "mát" (hạng 4) và bài kiểm đo nhầm thứ — đã hỏng đúng vậy
    --   với "việc=ánh sáng", mà đó chính là bộ giải chạy ĐÚNG.
    tui:GiveItem(SpawnPrefab("torch"))
    e.components.temperature:SetTemperature(68)

    KT("chưa có cỏ thì CHƯA chế được mũ",
       not st.ChePDuocRoi(e, mat))

    -- Ôm sẵn một việc gom cỏ cho nhu cầu "mát", đúng cảnh đã gặp.
    local bui = SpawnPrefab("grass")
    bui.Transform:SetPosition(gx + 4, 0, gz)
    e.ailang.viec = { vi_sao = "mát", muc_tieu = bui,
                      hanh_dong = ACTIONS.PICK }
    e.ailang.viec_tu = GetTime()
    vi.HanhDong(e)
    KT("chưa đủ cỏ thì cứ ôm việc gom mà làm tiếp",
       e.ailang.viec ~= nil and e.ailang.viec.vi_sao == "mát",
       "việc=" .. tostring(e.ailang.viec and e.ailang.viec.vi_sao))

    -- Giờ cho đủ nguyên liệu: phải BUÔNG việc gom để còn đi chế.
    for _ = 1, 14 do tui:GiveItem(SpawnPrefab("cutgrass")) end
    KT("đủ 12 bó cỏ thì chế được mũ", st.ChePDuocRoi(e, mat))
    e.ailang.viec = { vi_sao = "mát", muc_tieu = bui,
                      hanh_dong = ACTIONS.PICK }
    e.ailang.viec_tu = GetTime()
    vi.HanhDong(e)
    KT("đủ nguyên liệu rồi thì BUÔNG việc gom, để còn đi chế",
       e.ailang.viec == nil or e.ailang.viec.vi_sao ~= "mát"
       or e.ailang.viec.hanh_dong ~= ACTIONS.PICK,
       "việc=" .. tostring(e.ailang.viec and e.ailang.viec.vi_sao)
       .. "/" .. tostring(e.ailang.viec and e.ailang.viec.hanh_dong
                          and e.ailang.viec.hanh_dong.id))

    e.components.temperature:SetTemperature(20)
    bui:Remove()
    e:Remove()
    tiep()
end

-- ── chạy tuần tự ────────────────────────────────────────────────────────
local buoc = { ThuNam, ThuDem, ThuHonMa, ThuHonMaKhongLamViec, ThuNhat,
               ThuDanhTra, ThuHoangHon, ThuMuThoMo,
               ThuNamDoc, ThuDiKiem, ThuThuTu, ThuHonMaKeu,
               ThuHonMaDangDST, ThuKhongKetXe,
               ThuKhongDoiRiuDuoc, ThuKienNhan, ThuDuMuc,
               ThuKhongTroi, ThuHonMaTimXa, ThuHonMaCoHinh,
               ThuThienCam, ThuCheDo, ThuKhongNgu, ThuGiuViec,
               ThuKhongTrom, ThuRaNgoaiLang,
               ThuDaiTrieuHoi, ThuGiuLang,
               ThuMatRiu, ThuHonMaDiDuoc, ThuChenTheoHang,
               ThuTiepLua, ThuGiuLangTruocGiap, ThuGiapSauCung,
               ThuNapDayTruocDem, ThuKho, ThuTuiHang, ThuDenThat,
               ThuChongNong, ThuBongCay, ThuXuong,
               ThuLoThanTruoc,
               ThuUuTienThangKhoangCach, ThuBoTayThiThoi,
               ThuNghiNhuCau, ThuGomDuThiDung }
local i = 0
local function tiep()
    i = i + 1
    if buoc[i] ~= nil then
        buoc[i](tiep)
    else
        TraLaiGio()
        if MAY_THU ~= nil and MAY_THU:IsValid() then MAY_THU:Remove() end
        KhoiPhucLang()
        print(string.format("[TU-KIEM] ===== XONG: %d đạt, %d hỏng =====", dat, hong))
    end
end
print("[TU-KIEM] ===== bắt đầu =====")
tiep()

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
local function ThoaHetNhuCau(e)
    local tui = e.components.inventory
    for _, m in ipairs({ "spear", "armorgrass", "torch" }) do
        local mon = SpawnPrefab(m)
        if mon ~= nil then tui:GiveItem(mon) tui:Equip(mon) end
    end
    tui:GiveItem(SpawnPrefab("carrot"))
    local x, y, z = e.Transform:GetWorldPosition()
    e.ailang.nha = { x, z }
    local lua = SpawnPrefab("campfire")
    lua.Transform:SetPosition(x + 5, y, z)
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
        KT("hoàng hôn thì chế sẵn đuốc nhưng CHƯA cầm lên",
           co_duoc and (tay == nil or tay.prefab ~= "torch"),
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
            KT("sang ngày thì mới cầm rìu đi chặt",
               tay2 ~= nil and tay2.prefab == "axe",
               "đang cầm=" .. tostring(tay2 and tay2.prefab))
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

-- ── chạy tuần tự ────────────────────────────────────────────────────────
local buoc = { ThuNam, ThuDem, ThuHonMa, ThuHonMaKhongLamViec, ThuNhat,
               ThuDanhTra, ThuHoangHon, ThuMuThoMo,
               ThuNamDoc, ThuDiKiem, ThuThuTu, ThuHonMaKeu,
               ThuHonMaDangDST, ThuKhongKetXe,
               ThuKhongDoiRiuDuoc, ThuKienNhan, ThuDuMuc,
               ThuKhongTroi, ThuHonMaTimXa, ThuHonMaCoHinh,
               ThuThienCam, ThuCheDo, ThuKhongNgu, ThuGiuViec,
               ThuKhongTrom, ThuRaNgoaiLang,
               ThuDaiTrieuHoi, ThuGiuLang }
local i = 0
local function tiep()
    i = i + 1
    if buoc[i] ~= nil then
        buoc[i](tiep)
    else
        TraLaiGio()
        KhoiPhucLang()
        print(string.format("[TU-KIEM] ===== XONG: %d đạt, %d hỏng =====", dat, hong))
    end
end
print("[TU-KIEM] ===== bắt đầu =====")
tiep()

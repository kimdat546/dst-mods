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
local function KT(ten, dieu_kien, chi_tiet)
    if dieu_kien then
        dat = dat + 1
        print("[TU-KIEM] ĐẠT   " .. ten)
    else
        hong = hong + 1
        print("[TU-KIEM] HỎNG  " .. ten .. "   " .. tostring(chi_tiet or ""))
    end
end

for _, m in ipairs({ "ailang/nen", "ailang/dan_lang", "ailang/nhu_cau",
                     "ailang/sinh_ton", "ailang/lenh", "brains/danlangbrain" }) do
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
        local bo = c ~= nil and (c.inventoryitem or c.pickable or c.workable)
                   or v:HasTag("resurrector") or v:HasTag("campfire")
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
    DonQuanh(x, z, 30)
    local nao = Brain(e)
    nao:OnStart()
    return e, nao
end

local function Nhip(nao, n, xong)
    local i = 0
    local function b()
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
        KT("bỏ qua nấm chưa mọc dù nó GẦN hơn",
           nham == roi,
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
local function ThuNhat(tiep)
    local e, nao = DanLangSach(Goc())
    TheWorld:PushEvent("ms_setphase", "day")
    local x, y, z = e.Transform:GetWorldPosition()
    local da = SpawnPrefab("flint")
    da.Transform:SetPosition(x + 3, y, z)
    Nhip(nao, 3, function()
        local ba = e:GetBufferedAction()
        KT("thấy đồ dưới đất thì đi nhặt",
           ba ~= nil and ba.action == ACTIONS.PICKUP and ba.target == da,
           "hành động=" .. tostring(ba and ba.action and ba.action.id))
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
        TheWorld:PushEvent("ms_setphase", "night")
        Nhip(nao, 3, function()
            local tay2 = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
            KT("sang đêm thì cầm đuốc lên",
               tay2 ~= nil and tay2.prefab == "torch",
               "đang cầm=" .. tostring(tay2 and tay2.prefab))
            tiep()
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

-- ── chạy tuần tự ────────────────────────────────────────────────────────
local buoc = { ThuNam, ThuDem, ThuHonMa, ThuHonMaKhongLamViec, ThuNhat,
               ThuDanhTra, ThuHoangHon, ThuMuThoMo,
               ThuNamDoc, ThuDiKiem, ThuThuTu }
local i = 0
local function tiep()
    i = i + 1
    if buoc[i] ~= nil then
        buoc[i](tiep)
    else
        KhoiPhucLang()
        print(string.format("[TU-KIEM] ===== XONG: %d đạt, %d hỏng =====", dat, hong))
    end
end
print("[TU-KIEM] ===== bắt đầu =====")
tiep()

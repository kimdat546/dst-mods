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
local function KT(ten, dieu_kien, chi_tiet)
    if dieu_kien then
        dat = dat + 1
        print("[TU-KIEM] ĐẠT   " .. ten)
    else
        hong = hong + 1
        print("[TU-KIEM] HỎNG  " .. ten .. "   " .. tostring(chi_tiet or ""))
    end
end

for _, m in ipairs({ "ailang/nen", "ailang/dan_lang", "ailang/lenh",
                     "brains/danlangbrain" }) do
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

-- ── chạy tuần tự ────────────────────────────────────────────────────────
local buoc = { ThuNam, ThuDem, ThuHonMa, ThuHonMaKhongLamViec, ThuNhat }
local i = 0
local function tiep()
    i = i + 1
    if buoc[i] ~= nil then
        buoc[i](tiep)
    else
        for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
        print(string.format("[TU-KIEM] ===== XONG: %d đạt, %d hỏng =====", dat, hong))
    end
end
print("[TU-KIEM] ===== bắt đầu =====")
tiep()

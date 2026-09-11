-- Lệnh console. Để ở đây thay vì trong modmain để NẠP NÓNG được.
--
-- modmain chỉ chạy MỘT LẦN lúc world khởi động, nên mọi thứ định nghĩa trong
-- đó đều đóng băng cho tới khi khởi động lại game. File này thì `require`
-- được, nên xoá khỏi package.loaded rồi require lại là có mã mới ngay.

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")

local lenh = {}

local function QuanLy()
    return TheWorld ~= nil and TheWorld.components ~= nil
           and TheWorld.components.ailangquanly or nil
end

-- Nói vào khung chat, KHÔNG chỉ print().
--
-- ⚠ print() chỉ đi vào client_log.txt. Người chơi gõ lệnh trong game thì không
--   thấy gì và tưởng lệnh hỏng — đã xảy ra thật.
local function Bao(...)
    local phan = {}
    for i = 1, select("#", ...) do
        table.insert(phan, tostring((select(i, ...))))
    end
    local dong = table.concat(phan, " ")
    TheNet:Announce(dong)
    print("[ailang] " .. dong)
end

lenh.Bao = Bao

function lenh.Dem()
    local ql = QuanLy()
    local ds = dan_lang.TatCa()
    Bao(string.format("làng: %d hồ sơ, %d đang sống",
        ql ~= nil and ql:Dem() or 0, #ds))
    if #ds == 0 then
        Bao("(không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?)")
        return
    end
    for _, e in ipairs(ds) do
        local x, _, z = e.Transform:GetWorldPosition()
        local tui = e.components.inventory
        local cam = tui ~= nil and tui:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        Bao(string.format("  %s (%s)%s máu=%d%% đói=%d%% cầm=%s tại %.0f,%.0f",
            tostring(e.ailang.ten), e.prefab,
            e.ailang.la_hon_ma and " [HỒN MA]" or "",
            math.floor((e.components.health and e.components.health:GetPercent() or 1) * 100),
            math.floor((e.components.hunger and e.components.hunger:GetPercent() or 1) * 100),
            tostring(cam and cam.prefab or "tay không"), x, z))
    end
end

function lenh.Them(ten, nhan_vat)
    local ql = QuanLy()
    if ql == nil then Bao("chưa có quản lý làng") return end
    local inst = ql:Them({ ten = ten, nhan_vat = nhan_vat })
    if inst == nil then Bao("không sinh được dân làng") return end
    if ThePlayer ~= nil then
        local x, y, z = ThePlayer.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, y, z)
    end
    Bao("đã thêm dân làng", inst.ailang.ten, "(" .. inst.prefab .. ")")
    return inst
end

function lenh.XoaHet()
    local ql = QuanLy()
    if ql ~= nil then ql:XoaHet() Bao("đã xoá toàn bộ dân làng") end
end

function lenh.DatNha()
    if ThePlayer == nil then Bao("không xác định được vị trí") return end
    local x, _, z = ThePlayer.Transform:GetWorldPosition()
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        e.ailang.nha = { x, z }
        n = n + 1
    end
    Bao(string.format("đặt nhà cho %d dân làng tại %.0f,%.0f", n, x, z))
end

function lenh.TiepTe()
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        local tui = e.components.inventory
        if tui ~= nil then
            for _, m in ipairs({ "cutgrass", "cutgrass", "twigs", "twigs" }) do
                tui:GiveItem(SpawnPrefab(m))
            end
            n = n + 1
        end
    end
    Bao(string.format("đã phát 2 cỏ + 2 cành cho %d dân làng", n))
end


-- Soi xem dân làng ĐANG NGHĨ GÌ. Không đụng chạm gì tới thế giới, dùng được
-- bất cứ lúc nào trong lúc chơi.
--
-- Đây là thứ biến cái vô hình thành nhìn thấy được: cây hành vi chạy trong im
-- lặng nên "nó có làm đúng không" rất khó đoán bằng mắt thường.
function lenh.Soi()
    local sinh_ton = require("ailang/sinh_ton")
    local ds = dan_lang.TatCa()
    if #ds == 0 then
        Bao("không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?")
        return
    end
    Bao(string.format("── soi %d dân làng ── %s, ngày %s ──", #ds,
        TheWorld.state.isnight and "ĐÊM"
            or (TheWorld.state.isdusk and "hoàng hôn" or "ngày"),
        tostring(TheWorld.state.cycles)))

    for _, e in ipairs(ds) do
        local a = e.ailang
        local tui = e.components.inventory
        local tay = tui ~= nil and tui:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        local dau = tui ~= nil and tui:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        local minh = tui ~= nil and tui:GetEquippedItem(EQUIPSLOTS.BODY) or nil

        Bao(string.format("%s%s  máu %d%%  đói %d%%  não %d%%",
            tostring(a.ten), a.la_hon_ma and " [HỒN MA]" or "",
            math.floor((e.components.health and e.components.health:GetPercent() or 1) * 100),
            math.floor((e.components.hunger and e.components.hunger:GetPercent() or 1) * 100),
            math.floor((e.components.sanity and e.components.sanity:GetPercent() or 1) * 100)))

        local nc = sinh_ton.NhuCauCapThiet(e)
        Bao(string.format("   đang lo : %s", nc ~= nil and nc.ten or "không thiếu gì"))

        local ba = e:GetBufferedAction()
        Bao(string.format("   đang làm: %s%s",
            ba ~= nil and ba.action ~= nil and ba.action.id or "chưa làm gì",
            ba ~= nil and ba.target ~= nil and (" -> " .. tostring(ba.target.prefab)) or ""))

        Bao(string.format("   mang    : tay=%s đầu=%s mình=%s",
            tay ~= nil and tay.prefab or "-",
            dau ~= nil and dau.prefab or "-",
            minh ~= nil and minh.prefab or "-"))

        -- Đếm nguyên liệu quan trọng để biết nó có đủ làm đuốc chưa
        local dem = {}
        for _, mon in pairs((tui and tui.itemslots) or {}) do
            if mon ~= nil then
                local n = mon.components.stackable ~= nil
                          and mon.components.stackable:StackSize() or 1
                dem[mon.prefab] = (dem[mon.prefab] or 0) + n
            end
        end
        local tui_do = {}
        for k, v in pairs(dem) do table.insert(tui_do, k .. "x" .. v) end
        table.sort(tui_do)
        Bao("   túi     : " .. (#tui_do > 0 and table.concat(tui_do, " ") or "trống"))
    end
end

-- Chạy cả bộ tự kiểm ngay trong world đang chơi.
--
-- ⚠ Nó xoá sạch dân làng để dựng bản thử, rồi DỰNG LẠI làng của bạn ở cuối.
--   Nó cũng đổi giờ trong ngày và sinh vài thứ ở điểm spawn. Chạy lúc đang
--   rảnh, đừng chạy giữa lúc đánh boss.
function lenh.Kiem()
    Bao("chạy bộ tự kiểm — dân làng sẽ biến mất một lúc rồi dựng lại...")
    package.loaded["ailang/tu_kiem"] = nil
    local ok, err = pcall(require, "ailang/tu_kiem")
    if not ok then Bao("bộ tự kiểm HỎNG: " .. tostring(err)) end
end


-- Cứu hồn ma dân làng quanh mình. Dùng khi không tiện dựng bia đá, hoặc để
-- gỡ bí khi một hồn ma kẹt ở chỗ không có gì hồi sinh được.
function lenh.Cuu()
    local ds = dan_lang.TatCa()
    local n = 0
    for _, e in ipairs(ds) do
        if dan_lang.LaHonMa(e) then
            if dan_lang.HoiSinh(e) then n = n + 1 end
        end
    end
    if n == 0 then
        Bao("không có hồn ma dân làng nào")
    else
        Bao(string.format("đã cứu %d hồn ma dân làng", n))
    end
end

-- Giết một dân làng để xem cơ chế chết/hồn ma. Chỉ dùng để thử.
function lenh.Giet(ten)
    for _, e in ipairs(dan_lang.TatCa()) do
        if ten == nil or e.ailang.ten == ten then
            if e.components.health ~= nil then
                e.components.health:SetInvincible(false)
                e.components.health:DoDelta(-99999)
            end
            Bao("đã giết", tostring(e.ailang.ten), "— xem nó hoá hồn ma")
            return
        end
    end
    Bao("không tìm thấy dân làng nào tên " .. tostring(ten))
end


-- Gọi dân làng tới chỗ mình, và đặt nhà ngay tại đó.
--
-- ⚠ Dân làng CHỈ SỐNG khi có người chơi ở gần — cách khoảng 95 đơn vị là DST
--   cho ngủ và não thôi chạy. Đã đo, và không ép thức được:
--   AddServerNonSleepable / SetCanSleep(false) / RestartBrain đều vô hiệu.
--   Nên nhà của dân làng nên đặt ở chỗ mình hay lui tới.
function lenh.Goi()
    if ThePlayer == nil then Bao("không xác định được vị trí") return end
    local x, y, z = ThePlayer.Transform:GetWorldPosition()
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        e.Transform:SetPosition(x + math.random(-4, 4), y, z + math.random(-4, 4))
        e.ailang.nha = { x, z }
        e:RestartBrain()
        n = n + 1
    end
    Bao(string.format("đã gọi %d dân làng tới đây và đặt nhà tại %.0f,%.0f", n, x, z))
end


-- ── bảng điều khiển dân làng ────────────────────────────────────────────
--
-- ⚠ Đây là "bảng setting" dạng LỆNH, không phải giao diện. Giao diện thật đòi
--   phần chạy ở client, mà mod cố ý giữ server-only để không ai phải cài gì
--   mới vào được server. Xem mục "Quyết định" trong README.

local function TimTheoTen(ten)
    local ra = {}
    for _, e in ipairs(dan_lang.TatCa()) do
        if ten == nil or e.ailang.ten == ten then table.insert(ra, e) end
    end
    return ra
end

local function DatCheDo(ten, che_do, mo_ta)
    local than_thiet = require("ailang/than_thiet")
    local ds = TimTheoTen(ten)
    if #ds == 0 then Bao("không tìm thấy dân làng nào") return end
    local n, tu_choi = 0, {}
    for _, e in ipairs(ds) do
        if che_do == "theo_chan" and not than_thiet.ChiuTheo(e) then
            table.insert(tu_choi, string.format("%s (thiện cảm %d, cần %d)",
                e.ailang.ten, than_thiet.Lay(e), than_thiet.DU_THEO))
        else
            e.ailang.che_do = che_do
            e:RestartBrain()
            n = n + 1
        end
    end
    if n > 0 then Bao(string.format("%d dân làng: %s", n, mo_ta)) end
    for _, s in ipairs(tu_choi) do
        Bao("  " .. s .. " — chưa đủ thân, cho ăn thêm đã")
    end
end

function lenh.Theo(ten)   DatCheDo(ten, "theo_chan", "đi theo bạn")            end
function lenh.ONha(ten)   DatCheDo(ten, "o_nha",     "ở nhà, không đi đâu")    end
function lenh.TuDo(ten)   DatCheDo(ten, "tu_do",     "làm việc quanh nhà")     end

-- Bảng liệt kê đủ để quyết ai theo, ai ở nhà.
function lenh.Bang()
    local than_thiet = require("ailang/than_thiet")
    local ds = dan_lang.TatCa()
    if #ds == 0 then
        Bao("không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?")
        return
    end
    Bao("── dân làng ──  (c_ailang_theo/onha/tudo \"tên\")")
    for _, e in ipairs(ds) do
        local a = e.ailang
        local tc = than_thiet.Lay(e)
        Bao(string.format("%-8s %-11s thân %3d/100 %s  máu %d%%  đói %d%%%s",
            a.ten, than_thiet.CHE_DO[a.che_do or "tu_do"], tc,
            tc >= than_thiet.DU_THEO and "(theo được)"
                or (tc < than_thiet.BO_DI and "(sắp bỏ đi)" or "(chưa đủ thân)"),
            math.floor((e.components.health and e.components.health:GetPercent() or 1) * 100),
            math.floor((e.components.hunger and e.components.hunger:GetPercent() or 1) * 100),
            a.la_hon_ma and "  [HỒN MA]" or ""))
    end
    Bao("Cho ăn để tăng thân (thả đồ ăn lên dân làng). Đánh nó thì mất thân.")
end

return lenh

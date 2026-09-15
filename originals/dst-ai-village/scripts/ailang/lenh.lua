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
-- ── kho của làng ────────────────────────────────────────────────────────
--
-- Gom cả TÚI DÂN LÀNG lẫn RƯƠNG TRONG LÀNG về một bảng. Không có bảng này thì
-- muốn biết làng đang có bao nhiêu gỗ phải đi soi từng đứa một.

-- Tên tiếng Việt cho những thứ hay gặp; còn lại in thẳng tên prefab.
local TEN_VIET = {
    log = "gỗ", cutgrass = "cỏ", twigs = "cành cây", flint = "đá lửa",
    rocks = "đá", goldnugget = "vàng", nitre = "diêm tiêu",
    petals = "cánh hoa", berries = "quả mọng", carrot = "cà rốt",
    torch = "đuốc", axe = "rìu", pickaxe = "cuốc", spear = "giáo",
    armorgrass = "áo cỏ", armorwood = "áo gỗ", rope = "dây thừng",
    lightbulb = "trái đèn", ash = "tro", charcoal = "than",
}

local function TenMon(prefab)
    return TEN_VIET[prefab] or prefab
end

local function DemVao(bang, mon)
    if mon == nil then return end
    local n = mon.components.stackable ~= nil
              and mon.components.stackable:StackSize() or 1
    bang[mon.prefab] = (bang[mon.prefab] or 0) + n
end

function lenh.Kho()
    local lang = require("ailang/lang")
    local ds = dan_lang.TatCa()
    if #ds == 0 then
        Bao("không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?")
        return
    end

    local tong, tu_ruong = {}, {}
    local dong_dan = {}

    for _, e in ipairs(ds) do
        local tui = e.components.inventory
        if tui ~= nil then
            local rieng = {}
            for _, mon in pairs(tui.itemslots or {}) do
                DemVao(tong, mon) DemVao(rieng, mon)
            end
            -- Đồ đang mặc/cầm cũng là của làng, đếm luôn.
            for _, o in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
                local mon = tui:GetEquippedItem(o)
                DemVao(tong, mon) DemVao(rieng, mon)
            end
            -- Túi hàng (chỗ người chơi mở ra lấy đồ) cũng là kho của làng.
            local hang = e.components.container
            if hang ~= nil then
                for _, mon in pairs(hang.slots or {}) do
                    DemVao(tong, mon) DemVao(rieng, mon)
                end
            end
            local n = 0
            for _ in pairs(rieng) do n = n + 1 end
            table.insert(dong_dan, string.format("%-8s %2d loại", e.ailang.ten, n))
        end
    end

    -- Rương trong bán kính làng. Lấy tâm làng của dân làng đầu tiên có nhà.
    local tam
    for _, e in ipairs(ds) do
        tam = lang.Tam(e)
        if tam ~= nil then
            for _, v in ipairs(TheSim:FindEntities(tam[1], 0, tam[2],
                    lang.BanKinh(e), { "structure" }, { "INLIMBO", "burnt" })) do
                local c = v.components.container
                if c ~= nil then
                    for _, mon in pairs(c.slots or {}) do
                        DemVao(tong, mon) DemVao(tu_ruong, mon)
                    end
                end
            end
            break
        end
    end

    local ds_mon = {}
    for prefab, n in pairs(tong) do
        table.insert(ds_mon, { prefab = prefab, n = n })
    end
    table.sort(ds_mon, function(a, b)
        if a.n ~= b.n then return a.n > b.n end
        return a.prefab < b.prefab
    end)

    Bao("── kho của làng ──  (" .. #ds .. " dân"
        .. (tam ~= nil and "" or ", chưa có Đài nên không tính rương") .. ")")
    if #ds_mon == 0 then
        Bao("trống trơn.")
        return
    end
    for _, m in ipairs(ds_mon) do
        local trong_ruong = tu_ruong[m.prefab] or 0
        Bao(string.format("%-12s %4d%s", TenMon(m.prefab), m.n,
            trong_ruong > 0 and ("   (rương " .. trong_ruong .. ")") or ""))
    end
    Bao(table.concat(dong_dan, "  |  "))
    -- Trả về bảng để bộ tự kiểm soi được. Bắt lỗi qua chuỗi in ra thì hỏng:
    -- Bao là hàm local, bộ kiểm thay lenh.Bao không đụng tới nó được.
    return tong, tu_ruong
end

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

-- Bản CHIẾN LƯỢC — cùng dữ liệu tầng suy nghĩ nhận được, in ra cho người đọc.
--
-- Khác c_ailang_kho ở chỗ kho kể TỪNG MÓN, còn cái này trả lời mấy câu quyết
-- định được: đủ ăn mấy ngày, đủ thuốc chưa, đủ sức đi đánh chưa, đang tắc ở đâu.
function lenh.ChienLuoc()
    local kho_lang = require("ailang/kho_lang")
    local bk = kho_lang.Kiem()
    if bk.so_dan == 0 then
        Bao("không có dân làng nào — mod đã bật ở tab SERVER MODS chưa?")
        return
    end

    local function co(b) return b and "có" or "CHƯA" end

    Bao("── chiến lược của làng ──  (" .. bk.so_dan .. " dân)")
    Bao(string.format("ăn     %.1f ngày (%d calo)   %s", bk.ngay_an, bk.calo, co(bk.du_an)))
    Bao(string.format("thuốc  %d máu hồi được       %s", bk.mau_hoi, co(bk.du_thuoc)))
    Bao(string.format("người  máu %d%%  đói %d%%  tinh thần %d%%",
        bk.mau_tb, bk.doi_tb, bk.than_tb))
    Bao(string.format("đánh   %d vũ khí, %d giáp, %d rìu, %d cuốc",
        bk.vu_khi, bk.giap, bk.riu, bk.cuoc))

    local ct = {}
    for ten, n in pairs(bk.cong_trinh) do table.insert(ct, ten .. "x" .. n) end
    table.sort(ct)
    Bao("nhà    cấp máy " .. bk.cap_may
        .. (#ct > 0 and ("  |  " .. table.concat(ct, ", ")) or "  |  chưa có công trình nào"))

    local nl = {}
    for _, ten in ipairs(kho_lang.NGUYEN_LIEU) do
        local n = bk.mon[ten] or 0
        if n > 0 then table.insert(nl, TenMon(ten) .. " " .. n) end
    end
    if #nl > 0 then Bao("liệu   " .. table.concat(nl, ", ")) end
    if bk.sap_hong > 0 then Bao("⚠ " .. bk.sap_hong .. " món SẮP HỎNG") end

    Bao(bk.du_suc_danh and "→ đủ ăn, đủ thuốc, đủ vũ khí: ĐI ĐÁNH ĐƯỢC"
                       or ("→ nút thắt: " .. tostring(bk.nut_that or "không rõ")))
    return bk
end

-- Đặt mục tiêu bằng tay — để thử đúng cái tầng suy nghĩ sẽ gửi xuống.
--
--   c_ailang_muctieu("An", { hanh_dong = "CHOP", nham = "evergreen", dung = "axe", lan = 3 })
--   c_ailang_muctieu("An", { che = "researchlab", dat_xuong = true })
--   c_ailang_muctieu("An")                       -- xoá mục tiêu
function lenh.MucTieu(ten, mt)
    local muc_tieu = require("ailang/muc_tieu")
    local ds = TimTheoTen(ten)
    if #ds == 0 then Bao("không tìm thấy dân làng nào") return end
    local n = 0
    for _, e in ipairs(ds) do
        local ok, loi = muc_tieu.Dat(e, mt)
        if ok then n = n + 1
        else Bao(e.ailang.ten .. ": " .. tostring(loi)) end
    end
    Bao(mt == nil and ("đã xoá mục tiêu của " .. n .. " dân làng")
                   or ("đã đặt mục tiêu cho " .. n .. " dân làng"))
    return n
end

return lenh

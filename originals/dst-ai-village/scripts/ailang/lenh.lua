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

return lenh

-- Cầu nối sang tầng suy nghĩ — đi bằng FILE, không đi bằng HTTP.
--
-- ⚠ Vì sao không dùng HTTP như hai mod cũ (FAtiMA-DST 2018, DST-AICompanion
--   2024): đã đo trên DST bản 11/09/2026, `TheSim:QueryServer` KHÔNG BAO GIỜ
--   gọi callback cho URL ngoài Klei — thử cả http lẫn https, cả tên miền lẫn
--   IP, trên cả server offline lẫn server online đang có người chơi. Klei đã
--   khoá. Toàn bộ kiến trúc "mỗi nhịp một HTTP round-trip tới localhost:8080"
--   của hai mod đó chết ở đây, không cứu được.
--
-- Kênh thay thế đã đo là chạy: TheSim:SetPersistentString / GetPersistentString.
-- Ghi ra <save>/ailang_hoi.json, dịch vụ ngoài mount thư mục đó, xử lý, ghi
-- lại ailang_dap.json. Round-trip đã kiểm cả hai chiều, giữ nguyên tiếng Việt
-- có dấu. `io.open` thì KHÔNG dùng được — DST chặn, trả "invalid filepath".

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")

local cau_noi = {}

local TEP_HOI = "ailang_hoi.json"
local TEP_DAP = "ailang_dap.json"

local SO_QUANH = 6     -- kể tối đa bấy nhiêu loại vật quanh mình

local dem_nhip = 0

-- Kể xem quanh dân làng có gì — để tầng suy nghĩ biết bối cảnh.
local function QuanhMinh(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local dem = {}
    for _, e in ipairs(TheSim:FindEntities(x, y, z, 20, nil, { "INLIMBO", "FX", "NOCLICK" })) do
        if e ~= inst and e.prefab ~= nil then
            dem[e.prefab] = (dem[e.prefab] or 0) + 1
        end
    end
    local ds = {}
    for p, n in pairs(dem) do table.insert(ds, { p, n }) end
    table.sort(ds, function(a, b) return a[2] > b[2] end)
    local ra = {}
    for i = 1, math.min(SO_QUANH, #ds) do
        table.insert(ra, ds[i][1] .. "x" .. ds[i][2])
    end
    return ra
end

local function ChupMot(inst)
    local a = inst.ailang
    local x, _, z = inst.Transform:GetWorldPosition()
    local tui = inst.components.inventory
    local tren_tay = tui ~= nil and tui:GetEquippedItem(EQUIPSLOTS.HANDS) or nil

    local nguoi_gan = nil
    local d_gan = math.huge
    for _, p in ipairs(AllPlayers) do
        if p:IsValid() then
            local d = inst:GetDistanceSqToInst(p)
            if d < d_gan then nguoi_gan, d_gan = p, d end
        end
    end

    return {
        ma        = a.ma,
        ten       = a.ten,
        tinh_cach = a.tinh_cach,
        nhan_vat  = inst.prefab,
        mau       = inst.components.health  and math.floor(inst.components.health:GetPercent()  * 100) or 100,
        doi       = inst.components.hunger  and math.floor(inst.components.hunger:GetPercent()  * 100) or 100,
        tinh_than = inst.components.sanity  and math.floor(inst.components.sanity:GetPercent()  * 100) or 100,
        vi_tri    = { math.floor(x), math.floor(z) },
        tren_tay  = tren_tay ~= nil and tren_tay.prefab or nil,
        muc_tieu  = a.muc_tieu,
        quanh     = QuanhMinh(inst),
        nguoi_gan = nguoi_gan ~= nil and {
            ten = nguoi_gan.name,
            xa  = math.floor(math.sqrt(d_gan)),
        } or nil,
    }
end

-- Ghi câu hỏi ra đĩa cho dịch vụ ngoài đọc.
function cau_noi.Hoi()
    local ds = dan_lang.TatCa()
    if #ds == 0 then return end

    dem_nhip = dem_nhip + 1
    local goi = {
        nhip   = dem_nhip,
        ngay   = TheWorld.state.cycles,
        gio    = string.format("%.2f", TheWorld.state.time),
        mua    = TheWorld.state.season,
        troi   = TheWorld.state.isnight and "đêm" or (TheWorld.state.isdusk and "hoàng hôn" or "ngày"),
        dan_lang = {},
    }
    for _, e in ipairs(ds) do
        local ok, hs = pcall(ChupMot, e)
        if ok then table.insert(goi.dan_lang, hs) end
    end

    TheSim:SetPersistentString(TEP_HOI, json.encode(goi), false)
    nen.chitiet("gửi câu hỏi nhịp", dem_nhip, "cho", #goi.dan_lang, "dân làng")
end

-- Đọc câu trả lời và áp vào dân làng.
function cau_noi.NgheTraLoi()
    TheSim:GetPersistentString(TEP_DAP, function(ok, noi_dung)
        if not ok or noi_dung == nil or noi_dung == "" then return end

        local okj, dap = pcall(json.decode, noi_dung)
        if not okj or type(dap) ~= "table" or dap.dan_lang == nil then
            nen.chitiet("câu trả lời không đọc được, bỏ qua")
            return
        end

        local theo_ma = {}
        for _, e in ipairs(dan_lang.TatCa()) do
            if e.ailang ~= nil then theo_ma[e.ailang.ma] = e end
        end

        local n = 0
        for _, y in ipairs(dap.dan_lang) do
            local e = theo_ma[y.ma]
            if e ~= nil then
                if y.muc_tieu ~= nil then
                    e.ailang.muc_tieu = y.muc_tieu
                end
                if y.noi_gi ~= nil and y.noi_gi ~= "" and e.components.talker ~= nil then
                    e.components.talker:Say(y.noi_gi)
                end
                n = n + 1
            end
        end
        nen.chitiet("áp câu trả lời cho", n, "dân làng")
    end)
end

function cau_noi.Bat(nhip)
    nhip = nhip or 15
    TheWorld:DoPeriodicTask(nhip, function()
        nen.thu("hỏi tầng suy nghĩ", cau_noi.Hoi)
        nen.thu("nghe trả lời", cau_noi.NgheTraLoi)
    end)
    nen.log("tầng suy nghĩ BẬT, nhịp", nhip, "giây — kênh: file trong thư mục save")
end

return cau_noi

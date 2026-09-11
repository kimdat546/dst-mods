-- Quản lý làng — gắn trên TheWorld.
--
-- Vì prefab người chơi có persists = false (không được lưu cùng world), thứ
-- được lưu là HỒ SƠ dân làng trong component này. Mỗi lần thế giới nạp,
-- component dựng lại dân làng từ hồ sơ.

local nen = require("ailang/nen")
local dan_lang = require("ailang/dan_lang")

local NHIP_CHUP = 30   -- giây, chụp lại hồ sơ định kỳ để crash không mất vị trí

local QuanLyLang = Class(function(self, inst)
    self.inst = inst
    self.ho_so = {}          -- ma -> bảng hồ sơ
    self.da_dung_lai = false

    self.inst:DoPeriodicTask(NHIP_CHUP, function() self:ChupTatCa() end)

    -- Thiện cảm trôi theo ngày: sống yên thì tăng, bị bỏ đói thì giảm.
    self.inst:ListenForEvent("cycleschanged", function()
        local than_thiet = require("ailang/than_thiet")
        for _, e in ipairs(dan_lang.TatCa()) do
            nen.thu("trôi thiện cảm", than_thiet.SangNgayMoi, e)
        end
    end)
end)

-- DỰNG LẠI bảng hồ sơ từ dân làng đang sống, chứ không ghi đè từng mục.
--
-- ⚠ Bản đầu chỉ làm `self.ho_so[hs.ma] = hs`, không bao giờ dọn mục cũ, nên
--   mọi hồ sơ mồ côi (dân làng sinh hụt, xoá tay, đổi số dân trong cấu hình)
--   nằm lại vĩnh viễn và được dựng lại sau mỗi restart. Đo được 6 hồ sơ cho 3
--   dân làng đang sống, và con số chỉ có tăng.
function QuanLyLang:ChupTatCa()
    -- Chưa dựng lại xong thì chưa có ai sống — chụp lúc này là xoá sạch hồ sơ.
    if not self.da_dung_lai then return end
    -- Bộ tự kiểm xoá sạch dân làng để dựng bản thử. Chụp lúc đó là XOÁ VĨNH
    -- VIỄN cả làng của người chơi — nên nó tạm khoá cờ này trong lúc chạy.
    if self.tam_dung_chup then return end

    local moi = {}
    for _, e in ipairs(dan_lang.TatCa()) do
        local hs = dan_lang.ChupHoSo(e)
        if hs ~= nil then moi[hs.ma] = hs end
    end
    self.ho_so = moi
end

-- Dựng lại toàn bộ dân làng từ hồ sơ đã lưu. Gọi một lần sau khi world nạp.
function QuanLyLang:DungLai()
    if self.da_dung_lai then return 0 end
    self.da_dung_lai = true

    local n = 0
    for _, hs in pairs(self.ho_so) do
        local ok = nen.thu("dựng lại " .. tostring(hs.ten), function()
            if dan_lang.Sinh(hs) ~= nil then n = n + 1 end
        end)
        if not ok then self.ho_so[hs.ma] = nil end
    end
    nen.log("dựng lại", n, "dân làng từ hồ sơ đã lưu")
    return n
end

-- Thêm dân làng mới (lệnh console hoặc lúc tạo thế giới).
function QuanLyLang:Them(hoso)
    local inst = dan_lang.Sinh(hoso)
    if inst == nil then return nil end
    local hs = dan_lang.ChupHoSo(inst)
    if hs ~= nil then self.ho_so[hs.ma] = hs end
    return inst
end

function QuanLyLang:Xoa(ma)
    for _, e in ipairs(dan_lang.TatCa()) do
        if e.ailang ~= nil and e.ailang.ma == ma then e:Remove() end
    end
    self.ho_so[ma] = nil
end

function QuanLyLang:XoaHet()
    for _, e in ipairs(dan_lang.TatCa()) do e:Remove() end
    self.ho_so = {}
    nen.log("đã xoá toàn bộ dân làng")
end

function QuanLyLang:Dem()
    local n = 0
    for _ in pairs(self.ho_so) do n = n + 1 end
    return n
end

function QuanLyLang:OnSave()
    self:ChupTatCa()
    local ds = {}
    for _, hs in pairs(self.ho_so) do table.insert(ds, hs) end
    return { ho_so = ds }
end

function QuanLyLang:OnLoad(data)
    if data == nil or data.ho_so == nil then return end
    for _, hs in ipairs(data.ho_so) do
        if hs.ma ~= nil then self.ho_so[hs.ma] = hs end
    end
    nen.log("nạp", #data.ho_so, "hồ sơ dân làng")
end

return QuanLyLang

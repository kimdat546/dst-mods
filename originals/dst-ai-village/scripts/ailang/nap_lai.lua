-- Nạp nóng: đổi mã mod mà KHÔNG phải khởi động lại game.
--
-- Vì sao cần: vòng lặp thử trước đây là sửa mã -> cài lại -> THOÁT HẲN DST ->
-- mở lại -> host world -> chơi. Hai bước giữa mất vài phút mỗi vòng, mà một
-- buổi có hàng chục vòng.
--
-- ⚠ Không nạp lại được modmain. modmain chạy MỘT LẦN lúc world khởi động, và
--   những thứ nó đăng ký (AddPrefabPostInit, AddSimPostInit, component trên
--   TheWorld) không gỡ ra đăng ký lại được. Nên mọi mã hay sửa đều nằm trong
--   scripts/ailang/ và scripts/brains/ — chỗ này thì nạp lại được.
--
-- ⚠ Vẫn phải chạy tools/sync_local.sh trước, vì file trong thư mục mod của
--   game mới là file được đọc, không phải file trong repo.

local MO_DUN = {
    "ailang/nen",
    "ailang/dan_lang",
    "ailang/cau_noi",
    "ailang/lenh",
    "brains/danlangbrain",
}

local nap_lai = {}

function nap_lai.ChayLai()
    local nen = require("ailang/nen")

    for _, m in ipairs(MO_DUN) do
        package.loaded[m] = nil
    end

    local ok, err = pcall(function()
        for _, m in ipairs(MO_DUN) do require(m) end
    end)
    if not ok then
        return false, tostring(err)
    end

    -- Gắn lại não mới cho dân làng đang sống. Không làm bước này thì chúng vẫn
    -- chạy bằng cây hành vi cũ đã dựng trong bộ nhớ.
    local dan_lang = require("ailang/dan_lang")
    local brain = require("brains/danlangbrain")
    local n = 0
    for _, e in ipairs(dan_lang.TatCa()) do
        local ok2 = pcall(function()
            e:SetBrain(brain)
            e:RestartBrain()
        end)
        if ok2 then n = n + 1 end
    end

    -- Lệnh console cũng trỏ lại vào mã mới.
    nap_lai.DangKyLenh()

    nen.log("nạp nóng xong —", #MO_DUN, "mô đun,", n, "dân làng gắn lại não")
    return true, n
end

-- Buộc các lệnh c_ailang_* luôn gọi vào bản MỚI NHẤT của ailang/lenh.
-- Không tham chiếu thẳng hàm, mà tra lại mô đun mỗi lần gọi.
function nap_lai.DangKyLenh()
    local function goi(ten)
        return function(...)
            local l = require("ailang/lenh")
            return l[ten](...)
        end
    end
    -- ⚠ PHẢI dùng rawset. DST bật strict globals: `_G.ten = ...` từ file trong
    --   scripts/ bị chặn thẳng bằng
    --       "assign to undeclared variable 'c_ailang_dem'"
    --   và MOD ERROR đó làm CẢ WORLD không khởi động được. modmain thì gán
    --   bình thường được vì nó có lớp bọc riêng — nên lỗi chỉ lộ ra sau khi
    --   chuyển mã từ modmain sang scripts/. rawset đi vòng qua metatable.
    rawset(_G, "c_ailang_dem",    goi("Dem"))
    rawset(_G, "c_ailang_them",   goi("Them"))
    rawset(_G, "c_ailang_xoahet", goi("XoaHet"))
    rawset(_G, "c_ailang_datnha", goi("DatNha"))
    rawset(_G, "c_ailang_tiepte", goi("TiepTe"))

    rawset(_G, "c_ailang_naplai", function()
        local ok, kq = nap_lai.ChayLai()
        local l = require("ailang/lenh")
        if ok then
            l.Bao(string.format("nạp nóng XONG — %d dân làng đã gắn lại não mới", kq))
        else
            l.Bao("nạp nóng HỎNG: " .. tostring(kq))
        end
        return ok
    end)
end

return nap_lai

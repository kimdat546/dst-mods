-- Thiện cảm và chế độ đi theo — mượn mô hình Wurt ↔ merm.
--
-- Wurt cho merm ăn thì merm kết thân và đi theo. Ở đây cũng vậy, nhưng dân
-- làng là prefab người chơi nên KHÔNG dùng được component `follower`/`leader`
-- của merm — mình tự giữ quan hệ để khỏi dính các hành vi vanilla đi kèm.
--
-- ⚠ Vì sao không đổi dân làng sang prefab kiểu merm/pigman cho gọn: đã ĐO.
--   20 heo vanilla thức tốn +11,8% CPU, 20 dân làng (đã tắt não) tốn +13,9% —
--   prefab người chơi chỉ đắt hơn khoảng 18%. Đổi lấy chừng đó mà mất
--   `builder` (heo và merm KHÔNG chế tạo được), mất mặc giáp, mất cầm vũ khí
--   bất kỳ thì không đáng. Thứ đáng mượn từ merm là QUAN HỆ, không phải prefab.

local nen = require("ailang/nen")

local than_thiet = {}

-- ── chế độ ──────────────────────────────────────────────────────────────

than_thiet.CHE_DO = {
    tu_do     = "tự do",      -- làm việc quanh nhà (mặc định)
    theo_chan = "theo chân",  -- bám theo chủ đi khắp nơi
    o_nha     = "ở nhà",      -- không rời nhà, kể cả để đi kiếm
}

-- ── thiện cảm ───────────────────────────────────────────────────────────

than_thiet.BAN_DAU   = 50
than_thiet.DU_THEO   = 70   -- từ mức này mới chịu đi theo
than_thiet.BO_DI     = 15   -- dưới mức này thì bỏ làng

local THEM_CHO_AN    = 10
local BOT_BI_DANH    = 25
local THEM_MOI_NGAY  = 2
local BOT_DOI_MOI_NGAY = 5

function than_thiet.Lay(inst)
    local a = inst.ailang
    if a == nil then return 0 end
    if a.thien_cam == nil then a.thien_cam = than_thiet.BAN_DAU end
    return a.thien_cam
end

function than_thiet.Doi(inst, delta, vi_sao)
    local a = inst.ailang
    if a == nil then return end
    local cu = than_thiet.Lay(inst)
    a.thien_cam = math.max(0, math.min(100, cu + delta))
    if a.thien_cam ~= cu then
        nen.chitiet(tostring(a.ten), "thiện cảm", cu, "->", a.thien_cam,
                    "(" .. tostring(vi_sao) .. ")")
    end
    return a.thien_cam
end

function than_thiet.ChiuTheo(inst)
    return than_thiet.Lay(inst) >= than_thiet.DU_THEO
end

-- ── nhận đồ từ người chơi ───────────────────────────────────────────────
--
-- Đây là cách tương tác CHÍNH, và nó chạy được mà không cần mod ở client:
-- người chơi kéo món đồ thả lên dân làng, đúng thao tác vanilla.

local function NhanDuoc(inst, mon)
    if mon == nil then return false end
    -- Đồ hồi sinh: chỉ nhận khi đang là hồn ma
    if mon:HasTag("reviver") or mon:HasTag("resurrector") then
        return inst.ailang ~= nil and inst.ailang.la_hon_ma == true
    end
    -- Đồ ăn: nhận nếu ăn được và không phải món hại
    local an = inst.components.eater
    if an ~= nil and an:CanEat(mon) then
        local nhu_cau = require("ailang/nhu_cau")
        local diem = nhu_cau.ChamDiemAn(inst, mon)
        return diem ~= nil and diem > 0
    end
    -- Dụng cụ, vũ khí, giáp: nhận tuốt, dân làng tự biết dùng
    return mon.components.tool ~= nil
        or mon.components.weapon ~= nil
        or mon.components.armor ~= nil
        or mon.components.equippable ~= nil
end

local function KhiNhan(inst, nguoi_dua, mon)
    local dan_lang = require("ailang/dan_lang")
    local ten_nguoi = nguoi_dua ~= nil and nguoi_dua.name or "ai đó"

    if mon ~= nil and (mon:HasTag("reviver") or mon:HasTag("resurrector"))
       and dan_lang.LaHonMa(inst) then
        if mon:IsValid() then mon:Remove() end
        dan_lang.HoiSinh(inst)
        than_thiet.Doi(inst, 20, "được cứu sống")
        if inst.components.talker ~= nil then
            inst.components.talker:Say("Cảm ơn " .. ten_nguoi .. "! Tôi nợ bạn một mạng.")
        end
        return
    end

    local an = inst.components.eater
    if mon ~= nil and an ~= nil and an:CanEat(mon) then
        than_thiet.Doi(inst, THEM_CHO_AN, "được cho ăn")
        local moi = than_thiet.Lay(inst)
        if inst.components.talker ~= nil then
            inst.components.talker:Say(
                moi >= than_thiet.DU_THEO
                    and ("Cảm ơn " .. ten_nguoi .. "! Tôi đi theo bạn được rồi đấy.")
                    or ("Cảm ơn " .. ten_nguoi .. "!"))
        end
        return
    end

    if inst.components.talker ~= nil then
        inst.components.talker:Say("Cảm ơn, tôi dùng được thứ này.")
    end
    than_thiet.Doi(inst, 3, "được tặng đồ")
end

function than_thiet.GanVaoDanLang(inst)
    local a = inst.ailang
    if a == nil then return end
    if a.thien_cam == nil then a.thien_cam = than_thiet.BAN_DAU end
    if a.che_do == nil then a.che_do = "tu_do" end

    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    inst.components.trader:SetAcceptTest(function(_, mon) return NhanDuoc(inst, mon) end)
    inst.components.trader.onaccept = KhiNhan

    -- Bị chính người chơi đánh thì mất lòng. KHÔNG tính khi quái đánh.
    inst:ListenForEvent("attacked", function(_, data)
        if data ~= nil and data.attacker ~= nil and data.attacker:HasTag("player")
           and not data.attacker:HasTag("ailang_danlang") then
            than_thiet.Doi(inst, -BOT_BI_DANH, "bị " .. tostring(data.attacker.name) .. " đánh")
            if than_thiet.Lay(inst) < than_thiet.BO_DI and inst.components.talker ~= nil then
                inst.components.talker:Say("Đủ rồi! Tôi không ở đây nữa.")
            end
        end
    end)
end

-- Trôi thiện cảm theo ngày. Gọi từ quản lý làng mỗi khi sang ngày mới.
function than_thiet.SangNgayMoi(inst)
    local doi = inst.components.hunger
    if doi ~= nil and doi:GetPercent() < 0.25 then
        than_thiet.Doi(inst, -BOT_DOI_MOI_NGAY, "bị bỏ đói")
    else
        than_thiet.Doi(inst, THEM_MOI_NGAY, "sống yên ổn qua một ngày")
    end
end

return than_thiet

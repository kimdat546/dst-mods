-- Bộ chạy ĐỘNG TỪ chung — cầu nối giữa tầng suy nghĩ và thế giới.
--
-- ⚠ VÌ SAO KHÔNG VIẾT TAY TỪNG ĐỘNG TỪ. DST đã có sẵn bảng ACTIONS với khoảng
--   200 hành động: CHOP, MINE, PICK, COOK, STORE, SHAVE, FISH, GIVE... Viết tay
--   từng cái là chép lại một thứ đã có, và chép mãi cũng không đủ — người chơi
--   sẽ luôn nghĩ ra tình huống mình chưa lường.
--
--   Nên tầng này phơi THẲNG bảng đó ra dưới dạng dữ liệu. "Cạo lông bò" không
--   cần một dòng mã riêng nào, chỉ là:
--       { hanh_dong = "SHAVE", nham = "beefalo", dung = "razor" }
--
--   Nhờ vậy tầng suy nghĩ (Gemini) ra lệnh được những việc mod chưa từng nghĩ
--   tới, còn bảng nhu cầu thì viết lại bằng chính những động từ này.
--
-- ⚠ TẦNG SUY NGHĨ KHÔNG LÁI ĐƯỢC VÒNG LẶP 0,5 GIÂY. Kênh đi bằng file (xem
--   cau_noi.lua — QueryServer chết với URL ngoài Klei) cộng độ trễ LLM là vài
--   giây, trong khi cây hành vi quyết lại mỗi nửa giây. Nên nó đặt MỤC TIÊU,
--   còn thực thi vẫn là cây hành vi. Tầng này là chỗ mục tiêu biến thành việc.
--
-- Hình dạng một mệnh lệnh:
--     hanh_dong  tên trong ACTIONS, ví dụ "CHOP" / "SHAVE" / "STORE"
--     nham       tìm mục tiêu: tên prefab ("beefalo") hoặc tag ("CHOP_workable")
--     dung       món cần cầm/dùng, theo tên prefab ("razor", "axe")
--     tam        bán kính tìm, mặc định 30
--     che        (thay cho hanh_dong) tên công thức cần chế, ví dụ "researchlab"
--     dat_xuong  công thức này là công trình, đặt xuống đất

local nen = require("ailang/nen")
local nhu_cau = require("ailang/nhu_cau")

local hanh_dong = {}

local TAM_MAC_DINH = 30
local BO_QUA = { "INLIMBO", "NOCLICK", "FX", "playerghost" }

-- ── tra cứu ─────────────────────────────────────────────────────────────

-- Tên động từ có thật không? Trả về ACTION hoặc nil kèm lý do.
function hanh_dong.Tra(ten)
    if type(ten) ~= "string" then return nil, "tên động từ phải là chuỗi" end
    local a = ACTIONS[string.upper(ten)]
    if a == nil then return nil, "không có động từ tên '" .. ten .. "'" end
    return a
end

-- ── tìm mục tiêu ────────────────────────────────────────────────────────
--
-- `nham` có thể là tên prefab hoặc tên tag. Thử prefab trước vì nó cụ thể hơn;
-- không thấy thì coi như tag. Cách này cho tầng suy nghĩ viết tự nhiên —
-- "beefalo" hay "CHOP_workable" đều dùng được mà không cần biết phân biệt.
function hanh_dong.TimMucTieu(inst, nham, tam, loc_them)
    if nham == nil then return nil end
    tam = tam or TAM_MAC_DINH

    local theo_prefab = FindEntity(inst, tam, function(v)
        return v.prefab == nham and (loc_them == nil or loc_them(v))
    end, nil, BO_QUA)
    if theo_prefab ~= nil then return theo_prefab end

    return FindEntity(inst, tam, function(v)
        return loc_them == nil or loc_them(v)
    end, { nham }, BO_QUA)
end

-- ── món cần dùng ────────────────────────────────────────────────────────

-- Tìm món trong túi theo tên prefab, trang bị lên nếu trang bị được.
-- Trả về món, hoặc nil kèm lý do.
function hanh_dong.ChuanBiMon(inst, ten_mon)
    if ten_mon == nil then return nil end
    local tui = inst.components.inventory
    if tui == nil then return nil, "không có túi đồ" end

    local dang_cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if dang_cam ~= nil and dang_cam.prefab == ten_mon then return dang_cam end

    local mon = nhu_cau.DuyetTui(inst, function(m) return m.prefab == ten_mon end)
    if mon == nil then return nil, "trong túi không có " .. ten_mon end

    if mon.components.equippable ~= nil then
        nen.thu("cầm " .. ten_mon, function() tui:Equip(mon) end)
    end
    return mon
end

-- ── chế đồ ──────────────────────────────────────────────────────────────

-- Chế một công thức. Khác các động từ khác ở chỗ nó không nhắm vào thực thể
-- nào — builder tự trừ nguyên liệu trong túi.
function hanh_dong.Che(inst, ten, dat_xuong, vi_tri)
    local b = inst.components.builder
    if b == nil then return nil, "không có bộ chế đồ" end
    if AllRecipes[ten] == nil then return nil, "không có công thức '" .. tostring(ten) .. "'" end
    if not b:CanBuild(ten) then return nil, "chưa đủ nguyên liệu hoặc chưa đủ cấp máy" end

    local ok, loi = nen.thu("chế " .. ten, function()
        if dat_xuong then
            local x, y, z = inst.Transform:GetWorldPosition()
            if vi_tri ~= nil then x, z = vi_tri[1], vi_tri[2] end
            b:DoBuild(ten, Vector3(x + 2, y, z))
        else
            b:DoBuild(ten)
        end
    end)
    if not ok then return nil, tostring(loi) end
    return true
end

-- ── điểm vào ────────────────────────────────────────────────────────────
--
-- Trả về:
--   BufferedAction  cần đi làm gì đó
--   "xong"          đã làm xong ngay (chế đồ)
--   nil, lý_do      không làm được, kèm lý do để báo ngược cho tầng suy nghĩ
function hanh_dong.Chay(inst, lenh)
    if type(lenh) ~= "table" then return nil, "mệnh lệnh phải là bảng" end

    -- Chế đồ: không nhắm vào ai cả.
    if lenh.che ~= nil then
        local ok, loi = hanh_dong.Che(inst, lenh.che, lenh.dat_xuong, lenh.vi_tri)
        if not ok then return nil, loi end
        return "xong"
    end

    local act, loi = hanh_dong.Tra(lenh.hanh_dong)
    if act == nil then return nil, loi end

    -- Món cần dùng: có khai thì phải có, không thì chịu.
    local mon = nil
    if lenh.dung ~= nil then
        mon, loi = hanh_dong.ChuanBiMon(inst, lenh.dung)
        if mon == nil then return nil, loi end
    end

    -- Không khai mục tiêu thì coi như tác động lên chính món đang cầm
    -- (ăn, mặc, thắp...).
    if lenh.nham == nil then
        if mon == nil then return nil, "thiếu cả `nham` lẫn `dung`" end
        return BufferedAction(inst, nil, act, mon)
    end

    local muc = hanh_dong.TimMucTieu(inst, lenh.nham, lenh.tam)
    if muc == nil then
        return nil, "không thấy '" .. tostring(lenh.nham) .. "' trong bán kính "
                    .. tostring(lenh.tam or TAM_MAC_DINH)
    end

    return BufferedAction(inst, muc, act, mon)
end

-- Kiểm một mệnh lệnh mà KHÔNG thực hiện — để báo lại cho tầng suy nghĩ biết
-- lệnh của nó có hợp lệ không, thay vì im lặng nuốt.
function hanh_dong.Soat(lenh)
    if type(lenh) ~= "table" then return false, "mệnh lệnh phải là bảng" end
    if lenh.che ~= nil then
        if AllRecipes[lenh.che] == nil then
            return false, "không có công thức '" .. tostring(lenh.che) .. "'"
        end
        return true
    end
    local act, loi = hanh_dong.Tra(lenh.hanh_dong)
    if act == nil then return false, loi end
    return true
end

return hanh_dong

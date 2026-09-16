-- BẢN VẼ CÔNG TRÌNH — chỗ cả làng góp nguyên liệu vào một công trình.
--
-- ⚠ VÌ SAO PHẢI CÓ. `builder:DoBuild` của DST đòi MỘT người cầm ĐỦ CẢ bộ
--   nguyên liệu. Máy Khoa Học cần vàng 1 + gỗ 4 + đá 4 — ba dân làng mỗi đứa
--   ôm 2 khúc gỗ thì KHÔNG BAO GIỜ dựng nổi, dù cả làng cộng lại thừa. Đo được
--   trong lượt thử ngày 15/09: vàng 3, đá 6 nằm rải trong túi nhiều người, máy
--   vẫn không lên. Đây không phải lỗi hành vi — là giới hạn của mô hình "mỗi
--   người tự lo".
--
--   Mẫu mượn từ GrimWorld (Workshop 3748676443, grim_blueprint.lua): đặt một
--   thực thể bản vẽ kèm bảng giá, ai rảnh thì mang liệu tới, đủ thì dựng.
--   Xem docs/dst-knowledge/analysis/refmods/3748676443-grimworld.md
--
-- ⚠ GIAO LIỆU BẰNG `trader`, KHÔNG BẰNG `container`. Ba lý do:
--     * ACTIONS.GIVE chạy thẳng từ cây hành vi, không cần widget nào
--     * `trader:SetAcceptTest` chặn được đúng thứ còn thiếu, nên dân làng
--       không nhét gỗ vào một bản vẽ chỉ còn thiếu vàng
--     * `container` sẽ bị kho_lang đếm là rương của làng, và đồ đã giao thì
--       không còn là đồ dùng được nữa
--
--   DST có sẵn component `constructionsite` làm đúng việc này, nhưng nó dính
--   chặt vào UI người chơi (CONSTRUCT mở widget, cần
--   `constructionbuilderuidata` trên người làm). Dân làng không có UI.

local nen = require("ailang/nen")

-- ⚠ TÊN FILE HOẠT ẢNH PHẢI ĐÚNG TỪNG CHỮ. Viết nhầm "pigman_house" (tên
--   prefab con heo) thay vì "pig_house" (tên file anim) làm CẢ SERVER không
--   khởi động nổi — không MOD ERROR, không dòng lỗi nào, world chỉ đơn giản
--   không bao giờ nạp xong và bộ kiểm treo tới hết giờ. Tra tên thật trong
--   data/anim/ hoặc trong prefab vanilla đang dùng nó.
local Assets = {
    Asset("ANIM", "anim/pig_house.zip"),
}

-- Đọc giá của một công thức ra bảng phẳng { prefab = số }.
local function GiaCongThuc(ten)
    local ct = AllRecipes[ten]
    if ct == nil then return nil end
    local gia = {}
    for _, ng in ipairs(ct.ingredients or {}) do
        gia[ng.type] = (gia[ng.type] or 0) + ng.amount
    end
    return gia
end

local function ConThieu(inst)
    local bv = inst.banve
    if bv == nil or bv.can == nil then return nil end
    for prefab, can in pairs(bv.can) do
        local co = bv.da_gop[prefab] or 0
        if co < can then return prefab, can - co end
    end
    return nil
end

local function Xong(inst)
    return ConThieu(inst) == nil
end

-- Dựng thành công trình thật rồi tự xoá.
local function Dung(inst)
    local bv = inst.banve
    if bv == nil or bv.cong_thuc == nil then return false end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ok = nen.thu("dựng " .. bv.cong_thuc .. " từ bản vẽ", function()
        local ct = SpawnPrefab(bv.cong_thuc)
        if ct == nil then error("không sinh được " .. bv.cong_thuc) end
        ct.Transform:SetPosition(x, y, z)
        -- ⚠ Đánh dấu là do dân làng dựng. `nha.du`/`xuong.du` đếm công trình
        --   quanh nhà, và nếu không phân biệt được thì bản vẽ CHƯA xong cũng
        --   bị đếm là đã có — làng tưởng xong rồi và không ai mang liệu tới.
        ct:AddTag("ailang_tu_dung")
    end)
    if not ok then return false end
    nen.log("bản vẽ", bv.cong_thuc, "đã thành công trình")
    -- Công trình mới là việc đáng nhớ: tầng suy nghĩ cần biết làng vừa lên
    -- một bậc, không thì nhịp sau nó lại ra lệnh dựng đúng cái vừa xong.
    pcall(function()
        require("ailang/nhat_ky").Ghi("dựng xong " .. tostring(bv.cong_thuc))
    end)
    inst:Remove()
    return true
end

-- Nhận đúng thứ còn thiếu, không nhận thứ khác.
local function NhanDuoc(inst, mon)
    if mon == nil or inst.banve == nil then return false end
    local can = inst.banve.can[mon.prefab]
    if can == nil then return false end
    return (inst.banve.da_gop[mon.prefab] or 0) < can
end

-- Lấy thêm từ túi người đưa cho đủ phần còn thiếu.
--
-- ⚠ `trader:AcceptGift` MẶC ĐỊNH CHỈ LẤY MỘT MÓN (`count = count or 1`, rồi
--   `stackable:Get(count)`). Bản đầu tưởng nó nuốt cả chồng nên viết hẳn một
--   đoạn "trả lại phần dư" — đoạn đó vừa thừa vừa sai. Mà ACTIONS.GIVE không
--   truyền `count` được, nên nếu cứ để vậy thì mỗi lượt đưa chỉ được 1 khúc
--   gỗ: bản vẽ cần 4 khúc là bốn lượt đi lại.
--
--   Nên sau khi nhận món đầu, tự moi thêm trong túi người đưa cho đủ. Người
--   đưa giữ lại phần dư một cách tự nhiên, không cần trả lại gì cả.
local function LayThem(inst, nguoi_dua, prefab, con_thieu)
    local tui = nguoi_dua ~= nil and nguoi_dua.components.inventory or nil
    if tui == nil or con_thieu <= 0 then return 0 end
    local lay = 0
    while lay < con_thieu do
        local mon = tui:FindItem(function(m) return m.prefab == prefab end)
        if mon == nil then break end
        local co = mon.components.stackable ~= nil
                   and mon.components.stackable:StackSize() or 1
        local n = math.min(co, con_thieu - lay)
        if n >= co then
            local go = tui:RemoveItem(mon, true)
            if go ~= nil then go:Remove() end
        else
            local go = mon.components.stackable:Get(n)
            if go ~= nil then go:Remove() end
        end
        lay = lay + n
    end
    return lay
end

local function KhiNhan(inst, nguoi_dua, mon, count)
    if mon == nil or inst.banve == nil then return end
    local prefab = mon.prefab
    local can = inst.banve.can[prefab] or 0
    local co  = inst.banve.da_gop[prefab] or 0
    if can <= co then return end

    -- Món vừa nhận (trader đã tách khỏi túi người đưa rồi).
    local n = mon.components.stackable ~= nil
              and mon.components.stackable:StackSize() or (count or 1)
    local lay = math.min(n, can - co)
    co = co + lay

    -- Còn thiếu thì moi thêm trong túi người đưa, khỏi phải đi đi lại lại.
    co = co + LayThem(inst, nguoi_dua, prefab, can - co)
    inst.banve.da_gop[prefab] = co

    nen.chitiet("bản vẽ", inst.banve.cong_thuc, "nhận", prefab,
                "(" .. tostring(co) .. "/" .. tostring(can) .. ")")
    if Xong(inst) then Dung(inst) end
end

-- Dựng bảng giá cho một công thức. Gọi ngay sau khi sinh.
local function DatCongThuc(inst, ten)
    local gia = GiaCongThuc(ten)
    if gia == nil then
        nen.loi("không có công thức", tostring(ten), "— xoá bản vẽ")
        inst:Remove()
        return false
    end
    inst.banve = { cong_thuc = ten, can = gia, da_gop = {} }
    if inst.components.talker ~= nil then
        inst.components.talker:Say("bản vẽ: " .. ten)
    end
    return true
end

local function OnSave(inst, data)
    if inst.banve == nil then return end
    data.cong_thuc = inst.banve.cong_thuc
    data.da_gop    = inst.banve.da_gop
end

local function OnLoad(inst, data)
    if data == nil or data.cong_thuc == nil then
        inst:Remove()
        return
    end
    if DatCongThuc(inst, data.cong_thuc) then
        inst.banve.da_gop = data.da_gop or {}
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("idle")
    -- Mờ đi để nhìn ra ngay là chưa dựng xong.
    inst.AnimState:SetMultColour(1, 1, 1, 0.45)
    inst.AnimState:SetScale(0.6, 0.6, 0.6)

    inst:AddTag("structure")
    inst:AddTag("ailang_banve")
    -- ⚠ KHÔNG mang tag "prototyper"/"campfire"/... của thứ nó sắp trở thành.
    --   Bản vẽ Máy Khoa Học mà mang "prototyper" thì `xuong.du` báo làng đã có
    --   xưởng, và không ai mang liệu tới nữa — bản vẽ nằm đó vĩnh viễn.

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(function(_, mon) return NhanDuoc(inst, mon) end)
    -- ⚠ Xoá món đã nhận. Bản vẽ KHÔNG có `inventory`, nên nếu không xoá thì
    --   trader thả món xuống đất ngay cạnh — và kho_lang (đã đếm đồ rơi trên
    --   đất) sẽ đếm lại chính thứ vừa giao, tưởng làng vẫn còn nguyên liệu đó.
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = KhiNhan

    inst.DatCongThuc = DatCongThuc
    inst.ConThieu    = ConThieu
    inst.Xong        = Xong

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    return inst
end

return Prefab("ailang_banve", fn, Assets)

-- Bộ giải nhu cầu sinh tồn.
--
-- Đi từ nhu cầu ưu tiên cao nhất xuống. Với nhu cầu đầu tiên chưa thoả:
--   1. Có sẵn món ở bậc nào thì mặc/cầm món đó
--   2. Không có nhưng chế được thì chế
--   3. Không chế được bậc nào thì đi kiếm nguyên liệu còn thiếu cho bậc RẺ
--      NHẤT — đó là chỗ dân làng trông "biết tính" thay vì đi lang thang
--
-- Trả về:
--   "xong"           vừa làm xong một việc tức thì (mặc/chế), không cần hành động
--   BufferedAction   cần đi làm gì đó (hái/chặt/đào/nhặt)
--   nil              không có việc gì

local nen      = require("ailang/nen")
local nhu_cau  = require("ailang/nhu_cau")

local sinh_ton = {}

local TAM_KIEM = 30    -- bán kính đi kiếm nguyên liệu
local BO_QUA   = { "INLIMBO", "NOCLICK", "FX", "fire", "burnt", "catchable" }

local HANH_DONG = {
    PICK   = function() return ACTIONS.PICK end,
    CHOP   = function() return ACTIONS.CHOP end,
    MINE   = function() return ACTIONS.MINE end,
    PICKUP = function() return ACTIONS.PICKUP end,
}

-- ── nguyên liệu còn thiếu ───────────────────────────────────────────────

local function Dem(inst, ten)
    local tui = inst.components.inventory
    if tui == nil then return 0 end
    local n = 0
    nhu_cau.DuyetTui(inst, function(m)
        if m.prefab == ten then
            n = n + (m.components.stackable ~= nil
                     and m.components.stackable:StackSize() or 1)
        end
        return false
    end)
    return n
end

-- Những gì còn thiếu để chế `ten`, theo dạng { {nguyen_lieu, so_luong}, ... }.
function sinh_ton.ConThieu(inst, ten)
    local ct = AllRecipes[ten]
    if ct == nil then return nil end
    local thieu = {}
    for _, ng in ipairs(ct.ingredients or {}) do
        local con = ng.amount - Dem(inst, ng.type)
        if con > 0 then table.insert(thieu, { ng.type, con }) end
    end
    return thieu
end

-- ── dụng cụ ─────────────────────────────────────────────────────────────

local function CamDungCu(inst, hanh_dong)
    local tui = inst.components.inventory
    if tui == nil then return false end
    local cam = tui:GetEquippedItem(EQUIPSLOTS.HANDS)
    if cam ~= nil and cam.components.tool ~= nil
       and cam.components.tool:CanDoAction(hanh_dong) then
        return true
    end
    local dc = nhu_cau.DuyetTui(inst, function(m)
        return m.components.tool ~= nil and m.components.tool:CanDoAction(hanh_dong)
    end)
    if dc ~= nil then tui:Equip(dc) return true end
    return false
end

sinh_ton.CamDungCu = CamDungCu

-- ── đi kiếm một nguyên liệu ─────────────────────────────────────────────

function sinh_ton.DiKiem(inst, nguyen_lieu, bo_qua_fn)
    local tui = inst.components.inventory
    if tui == nil or tui:IsFull() then return nil end

    -- Nằm sẵn dưới đất thì nhặt, khỏi phải khai thác.
    local roi = FindEntity(inst, TAM_KIEM, function(v)
        return v.prefab == nguyen_lieu
           and v.components.inventoryitem ~= nil
           and v.components.inventoryitem.canbepickedup
           and v:IsOnValidGround()
           and not (bo_qua_fn ~= nil and bo_qua_fn(v))
    end, { "_inventoryitem" }, BO_QUA)
    if roi ~= nil then return BufferedAction(inst, roi, ACTIONS.PICKUP) end

    local nguon = nhu_cau.NGUON[nguyen_lieu]
    if nguon == nil then return nil end
    local hd = HANH_DONG[nguon.hd]
    if hd == nil then return nil end
    local hanh_dong = hd()

    if (nguon.hd == "CHOP" or nguon.hd == "MINE")
       and not CamDungCu(inst, hanh_dong) then
        return nil          -- không có dụng cụ thì thôi, tụt bậc khác
    end

    local muc = FindEntity(inst, TAM_KIEM, function(v)
        if bo_qua_fn ~= nil and bo_qua_fn(v) then return false end
        if nguon.prefab ~= nil and v.prefab ~= nguon.prefab then return false end
        if nguon.hd == "PICK" then
            return v.components.pickable ~= nil
               and v.components.pickable:CanBePicked()
               and v.components.pickable.caninteractwith ~= false
        end
        return v.components.workable ~= nil
           and v.components.workable:CanBeWorked()
           and v.components.workable:GetWorkAction() == hanh_dong
    end, { nguon.tag }, BO_QUA)

    if muc == nil then return nil end
    return BufferedAction(inst, muc, hanh_dong)
end

-- ── giải một nhu cầu ────────────────────────────────────────────────────

local function MacVao(inst, mon, n)
    -- Một số nhu cầu chỉ cần CÓ, chưa cần mặc lên (ví dụ đuốc lúc hoàng hôn,
    -- hay vũ khí lúc đang đi chặt cây — cầm giáo thì mất tay cầm rìu).
    if n.mac_khi ~= nil and not n.mac_khi(inst) then return false end
    local tui = inst.components.inventory
    if tui == nil then return false end
    tui:Equip(mon)
    nen.chitiet(tostring(inst.ailang.ten), "dùng", mon.prefab, "cho", n.ten)
    return true
end

-- Trả "xong" nếu vừa làm một việc tức thì, BufferedAction nếu cần đi làm,
-- nil nếu bó tay với nhu cầu này.
local function GiaiMot(inst, n)
    local b = inst.components.builder

    -- 1. Đã có sẵn món nào ở bậc nào chưa
    for _, bac in ipairs(n.bac or {}) do
        local co = nhu_cau.CoTrongTui(inst, bac.mon)
        if co ~= nil and not bac.dat_xuong then
            if MacVao(inst, co, n) then return "xong" end
            return nil     -- có rồi nhưng chưa tới lúc mặc: coi như ổn
        end
    end

    -- 2. Chế được bậc nào cao nhất
    for _, bac in ipairs(n.bac or {}) do
        if b ~= nil and b:CanBuild(bac.mon) then
            local ok = nen.thu("chế " .. bac.mon, function()
                if bac.dat_xuong then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    b:DoBuild(bac.mon, Vector3(x + 2, y, z))
                else
                    b:DoBuild(bac.mon)
                end
            end)
            if ok then
                nen.log(tostring(inst.ailang.ten), "chế", bac.mon, "cho", n.ten)
                if not bac.dat_xuong then
                    local moi = nhu_cau.CoTrongTui(inst, bac.mon)
                    -- ⚠ builder:DoBuild TỰ TRANG BỊ món vừa chế khi tay trống.
                    --   Chưa tới lúc mặc thì phải cởi ra cất đi.
                    local tay = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if tay ~= nil and tay.prefab == bac.mon then
                        if n.mac_khi ~= nil and not n.mac_khi(inst) then
                            local go = inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
                            if go ~= nil then inst.components.inventory:GiveItem(go) end
                        end
                    elseif moi ~= nil then
                        MacVao(inst, moi, n)
                    end
                end
                return "xong"
            end
        end
    end

    -- 3. Không bậc nào làm ngay được: đi kiếm nguyên liệu cho bậc RẺ NHẤT
    --    (bậc cuối trong danh sách), vì đó là thứ khả thi sớm nhất.
    local re_nhat = n.bac ~= nil and n.bac[#n.bac] or nil
    if re_nhat ~= nil then
        local thieu = sinh_ton.ConThieu(inst, re_nhat.mon)
        for _, t in ipairs(thieu or {}) do
            local hd = sinh_ton.DiKiem(inst, t[1])
            if hd ~= nil then
                nen.chitiet(tostring(inst.ailang.ten), "đi kiếm", t[1],
                            "(thiếu " .. t[2] .. ") cho", re_nhat.mon)
                return hd
            end
        end
    end

    -- 4. Nhu cầu có danh sách "kiếm" riêng (đồ ăn, hoa...) thì đi kiếm
    for _, ng in ipairs(n.kiem or {}) do
        local hd = sinh_ton.DiKiem(inst, ng)
        if hd ~= nil then
            nen.chitiet(tostring(inst.ailang.ten), "đi kiếm", ng, "cho", n.ten)
            return hd
        end
    end

    return nil
end

-- ── điểm vào ────────────────────────────────────────────────────────────

-- Nhu cầu đang cần mà chưa thoả, ưu tiên cao nhất trước.
function sinh_ton.NhuCauCapThiet(inst)
    for _, n in ipairs(nhu_cau.DANH_SACH) do
        local ok_can, can = pcall(n.can, inst)
        local ok_du, du   = pcall(n.du, inst)
        if ok_can and can and ok_du and not du then
            return n
        end
    end
    return nil
end

function sinh_ton.Giai(inst)
    local n = sinh_ton.NhuCauCapThiet(inst)
    if n == nil then return nil end
    if inst.ailang ~= nil then inst.ailang.dang_lo = n.ten end
    local ok, kq = pcall(GiaiMot, inst, n)
    if not ok then
        nen.loi("giải nhu cầu " .. n.ten .. ":", kq)
        return nil
    end
    return kq
end

return sinh_ton

-- Đài Triệu Hồi — vừa là chỗ gọi dân làng mới, vừa LÀ NHÀ của cả làng.
--
-- Gộp hai vai vào một công trình là có chủ ý, và nó giải luôn bài toán đầu
-- game du mục:
--     chưa dựng Đài  ->  dân làng KHÔNG có nhà  ->  bám theo người chơi
--     dựng Đài       ->  Đài thành nhà          ->  làng hình thành quanh đó
--     đập Đài        ->  cả làng mất nhà        ->  quay lại bám theo
-- Không cần luật "theo chân cho tới khi có nhà" riêng — nó rơi ra tự nhiên.
--
-- ⚠ Dùng dáng `resurrection_stone` của vanilla, KHÔNG tự vẽ. Mod chưa có tài
--   nguyên hình ảnh riêng, mà bank/build vanilla thì client nào cũng có sẵn
--   nên không cần phần chạy ở client.

local nen = require("ailang/nen")

local Assets = {
    Asset("ANIM", "anim/resurrection_stone.zip"),
    Asset("MINIMAP_IMAGE", "resurrection_stone"),
}

-- Giá triệu hồi: nhân lên theo số dân đang có, để đông dân là một lựa chọn
-- phải trả giá chứ không phải thứ spam được.
local GIA_GOC = {
    { "goldnugget", 1 },
    { "log", 4 },
    { "cutgrass", 8 },
}

local function GiaHienTai(so_dan)
    local he_so = 1 + (so_dan or 0) * 0.5
    local ra = {}
    for _, g in ipairs(GIA_GOC) do
        table.insert(ra, { g[1], math.ceil(g[2] * he_so) })
    end
    return ra
end

local function DemTrongTui(nguoi, ten)
    local tui = nguoi.components.inventory
    if tui == nil then return 0 end
    local n = 0
    for _, m in pairs(tui.itemslots or {}) do
        if m ~= nil and m.prefab == ten then
            n = n + (m.components.stackable ~= nil
                     and m.components.stackable:StackSize() or 1)
        end
    end
    return n
end

local function ThieuGi(nguoi, gia)
    local thieu = {}
    for _, g in ipairs(gia) do
        local con = g[2] - DemTrongTui(nguoi, g[1])
        if con > 0 then table.insert(thieu, g[1] .. " x" .. con) end
    end
    return thieu
end

local function TruNguyenLieu(nguoi, gia)
    local tui = nguoi.components.inventory
    for _, g in ipairs(gia) do
        local con = g[2]
        while con > 0 do
            local mon = nil
            for _, m in pairs(tui.itemslots or {}) do
                if m ~= nil and m.prefab == g[1] then mon = m break end
            end
            if mon == nil then break end
            local co = mon.components.stackable ~= nil
                       and mon.components.stackable:StackSize() or 1
            if co <= con then
                con = con - co
                tui:RemoveItem(mon, true):Remove()
            else
                mon.components.stackable:SetStackSize(co - con)
                con = 0
            end
        end
    end
end

-- ── gacha ───────────────────────────────────────────────────────────────

local function BocNgauNhien()
    local nen_mod = require("ailang/nen")
    local tinh_cach = { "binh_than", "sieng_nang", "nhat_gan", "hieu_chien", "tham_an" }
    local thien_huong = { "chat_cay", "dao_da", "hai_luom", "chien_dau" }
    return {
        nhan_vat    = nen_mod.NHAN_VAT[math.random(#nen_mod.NHAN_VAT)],
        ten         = nen_mod.TEN[math.random(#nen_mod.TEN)],
        tinh_cach   = tinh_cach[math.random(#tinh_cach)],
        thien_huong = thien_huong[math.random(#thien_huong)],
    }
end

-- ── triệu hồi ───────────────────────────────────────────────────────────

local function CoTheTrieuHoi(inst, nguoi)
    return nguoi ~= nil and nguoi.components.inventory ~= nil
end

local function TrieuHoi(inst, nguoi)
    local ql = TheWorld.components ~= nil and TheWorld.components.ailangquanly or nil
    if ql == nil then return false end

    local gia = GiaHienTai(ql:Dem())
    local thieu = ThieuGi(nguoi, gia)
    if #thieu > 0 then
        if nguoi.components.talker ~= nil then
            nguoi.components.talker:Say("Còn thiếu: " .. table.concat(thieu, ", "))
        end
        return false
    end

    TruNguyenLieu(nguoi, gia)

    local hoso = BocNgauNhien()
    local x, y, z = inst.Transform:GetWorldPosition()
    hoso.vi_tri = { x + math.random(-3, 3), z + math.random(-3, 3) }
    hoso.nha    = { x, z }
    hoso.dai    = inst.GUID

    local e = ql:Them(hoso)
    if e == nil then return false end

    inst.AnimState:PlayAnimation("resurrect")
    inst.AnimState:PushAnimation("idle_off", true)

    TheNet:Announce(string.format("Đài Triệu Hồi gọi về %s (%s, %s)",
        tostring(e.ailang.ten), tostring(e.prefab), tostring(hoso.thien_huong)))
    nen.log("triệu hồi", e.ailang.ten, e.prefab, hoso.thien_huong,
            "— làng có", ql:Dem(), "dân")
    return true
end

-- ── prefab ──────────────────────────────────────────────────────────────

local function OnSave(inst, data)
    data.ban_kinh = inst.ban_kinh
end

local function OnLoad(inst, data)
    if data ~= nil and data.ban_kinh ~= nil then inst.ban_kinh = data.ban_kinh end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("resurrection_stone.png")
    inst.MiniMapEntity:SetPriority(6)

    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("resurrection_stone")
    inst.AnimState:SetBuild("resurrection_stone")
    inst.AnimState:PlayAnimation("idle_off", true)

    inst:AddTag("structure")
    inst:AddTag("ailang_dai")

    -- ⚠ Đài hồi sinh được chính dân của nó. Không có thứ này thì làng CHẾT
    --   VĨNH VIỄN: đo trên server, cả ba dân làng chết đêm rồi đứng làm hồn ma
    --   mãi vì quanh đó không có bia đá hay tượng thịt nào. Một đài triệu hồi
    --   mà không gọi lại được người của mình thì cũng vô lý.
    inst:AddTag("resurrector")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    -- Bán kính làng: dân làng ưu tiên bảo vệ, dập lửa, cất đồ trong vòng này.
    inst.ban_kinh = (rawget(_G, "AILANG_CAUHINH") or {}).ban_kinh_lang or 60

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(function()
        inst.components.lootdropper:DropLoot()
        -- Đập Đài thì cả làng mất nhà và quay lại bám theo người chơi.
        local dan_lang = require("ailang/dan_lang")
        for _, e in ipairs(dan_lang.TatCa()) do
            if e.ailang ~= nil and e.ailang.dai == inst.GUID then
                e.ailang.nha = nil
                e.ailang.dai = nil
            end
        end
        TheNet:Announce("Đài Triệu Hồi đã đổ — dân làng mất nhà.")
        inst:Remove()
    end)

    -- `activatable` cho ra hành động chuột phải của vanilla, không cần mod ở
    -- client nào cả.
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = TrieuHoi
    inst.components.activatable.CanActivate = CoTheTrieuHoi
    inst.components.activatable.quickaction = true
    inst.components.activatable.getverb = function() return "TRIEUHOI" end

    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

-- Cho nơi khác hỏi giá mà không phải nhân bản công thức.
_G.AILANG_GIA_TRIEU_HOI = GiaHienTai

return Prefab("ailang_dai", fn, Assets),
       MakePlacer("ailang_dai_placer", "resurrection_stone", "resurrection_stone", "idle_off")

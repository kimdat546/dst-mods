-- Sinh và dựng lại dân làng.
--
-- ⚠ Dân làng là PREFAB NGƯỜI CHƠI spawn ra mà không có ai điều khiển. Đã đo
--   trên DST bản hiện tại (11/09/2026), ba điều quan trọng:
--
--   1. Nó TỰ ĐĂNG KÝ vào bảng AllPlayers (0 -> 1). Không gỡ ra thì mọi thứ
--      đếm người chơi đều sai — số người trên server, mod chia máu boss theo
--      đầu người, lệnh c_listallplayers...
--      Nhưng TheNet:GetPlayerCount() vẫn = 0, nên server vẫn tự pause đúng
--      khi không có người thật. Gỡ khỏi AllPlayers là đủ.
--
--   2. persists = false — prefab người chơi KHÔNG được lưu cùng world. Restart
--      là mất sạch. Nên trạng thái dân làng do quan_ly_lang giữ, và dựng lại
--      từ đó mỗi lần thế giới nạp.
--
--   3. Giữ nguyên tag "player" là CÓ CHỦ Ý: nhờ nó dân làng mặc được giáp,
--      cầm được vũ khí, ăn được mọi thứ, và bị quái nhắm tới. Muốn loại dân
--      làng ra khỏi chỗ nào thì lọc bằng tag riêng "ailang_danlang".

local nen = require("ailang/nen")

local dan_lang = {}

local TAG = "ailang_danlang"

local function GoKhoiAllPlayers(inst)
    local go = 0
    for i = #AllPlayers, 1, -1 do
        if AllPlayers[i] == inst then
            table.remove(AllPlayers, i)
            go = go + 1
        end
    end
    return go
end

-- Chụp túi đồ. Chỉ giữ tên prefab và số lượng chồng — mất độ bền và mất mọi
-- thứ mod khác gắn lên món đồ, nhưng đủ để dân làng không tay trắng sau mỗi
-- lần restart (gặp thật: phát rìu xong restart là mất sạch).
local function ChupTui(inst)
    local tui = inst.components.inventory
    if tui == nil then return nil end

    local function mo_ta(mon)
        if mon == nil then return nil end
        local n = mon.components.stackable ~= nil
                  and mon.components.stackable:StackSize() or 1
        return { mon.prefab, n }
    end

    local ra = { tui_do = {}, tren_nguoi = {} }
    for _, mon in pairs(tui.itemslots or {}) do
        table.insert(ra.tui_do, mo_ta(mon))
    end
    for o, mon in pairs(tui.equipslots or {}) do
        ra.tren_nguoi[o] = mo_ta(mon)
    end
    return ra
end

local function DungLaiTui(inst, tui_hs)
    local tui = inst.components.inventory
    if tui == nil or tui_hs == nil then return end

    local function tao(m)
        if m == nil or Prefabs[m[1]] == nil then return nil end
        local mon = SpawnPrefab(m[1])
        if mon ~= nil and m[2] and m[2] > 1 and mon.components.stackable ~= nil then
            mon.components.stackable:SetStackSize(m[2])
        end
        return mon
    end

    for _, m in ipairs(tui_hs.tui_do or {}) do
        local mon = tao(m)
        if mon ~= nil then tui:GiveItem(mon) end
    end
    for _, m in pairs(tui_hs.tren_nguoi or {}) do
        local mon = tao(m)
        if mon ~= nil then tui:GiveItem(mon) tui:Equip(mon) end
    end
end

-- Sinh một dân làng. `hoso` là bảng đã lưu (hoặc nil để tạo mới).
function dan_lang.Sinh(hoso)
    hoso = hoso or {}

    local nhan_vat = hoso.nhan_vat or nen.NHAN_VAT[math.random(#nen.NHAN_VAT)]
    if Prefabs[nhan_vat] == nil then
        nen.loi("không có prefab nhân vật", nhan_vat, "— dùng wilson")
        nhan_vat = "wilson"
    end

    local inst = SpawnPrefab(nhan_vat)
    if inst == nil then
        nen.loi("SpawnPrefab thất bại cho", nhan_vat)
        return nil
    end

    local go = GoKhoiAllPlayers(inst)
    nen.chitiet("gỡ khỏi AllPlayers:", go, "lần | còn lại", #AllPlayers)

    inst:AddTag(TAG)
    inst.ailang = {
        ma       = hoso.ma or tostring(inst.GUID),
        ten      = hoso.ten or nen.TEN[math.random(#nen.TEN)],
        tinh_cach = hoso.tinh_cach or "binh_than",
        nha      = hoso.nha,          -- {x, z} hoặc nil
        muc_tieu = nil,               -- do tầng suy nghĩ đặt vào
        noi_gi   = nil,
    }
    inst.name = inst.ailang.ten

    local x, y, z
    if hoso.vi_tri then
        x, y, z = hoso.vi_tri[1], 0, hoso.vi_tri[2]
    else
        local sinh = TheWorld.components.playerspawner
        if sinh ~= nil and sinh.GetAnySpawnPoint ~= nil then
            -- GetAnySpawnPoint trả về BA SỐ x, y, z — không phải Vector3.
            local a, b, c = sinh:GetAnySpawnPoint()
            if type(a) == "number" then
                x, y, z = a, b, c
            elseif a ~= nil and a.Get ~= nil then
                x, y, z = a:Get()
            end
        end
    end
    inst.Transform:SetPosition(x or 0, y or 0, z or 0)

    if hoso.mau and inst.components.health then
        -- Dựng lại tối thiểu 30% chứ không phải 10%: dân làng hồi sinh với
        -- 10% máu thì chết lại ngay trong đêm đầu tiên, và chưa có hành vi
        -- tự chữa thương. Đã gặp thật sau vài lần restart liên tiếp.
        inst.components.health:SetPercent(math.max(0.3, hoso.mau))
    end

    nen.thu("dựng lại túi đồ", DungLaiTui, inst, hoso.tui)

    inst:ListenForEvent("death", function()
        dan_lang.ThanhHonMa(inst)
    end)

    if hoso.la_hon_ma then
        dan_lang.ThanhHonMa(inst, hoso.noi_chet)
    end

    -- Entity DST "ngủ" khi không có người chơi ở gần, và entity ngủ thì KHÔNG
    -- chạy não (đo được: IsAsleep()=true -> inst.brain=nil ngay sau SetBrain).
    -- Dòng này để cái làng sống tiếp lúc cả đội đang ở hang, thay vì đóng băng.
    --
    -- ⚠ Không kiểm được trên server test: khi KHÔNG có client nào nối vào, DST
    --   ngủ cả thế giới — đã đối chứng bằng heo vanilla, nó cũng ngủ và cũng
    --   đứng im y hệt. Nên phần hành vi phải kiểm trong game thật.
    inst.entity:AddServerNonSleepable()

    local brain = require("brains/danlangbrain")
    inst:SetBrain(brain)
    inst:RestartBrain()

    nen.log("sinh dân làng", inst.ailang.ten, "(" .. nhan_vat .. ")",
            "tại", string.format("%.0f,%.0f", x or 0, z or 0))
    return inst
end


-- ── hồn ma ──────────────────────────────────────────────────────────────
--
-- ⚠ KHÔNG dùng được hồn ma thật của engine. `inst:SetGhostMode(true)` tồn tại
--   nhưng nổ ngay: player_common.lua:957 "attempt to index field 'HUD'" — nó
--   đòi HUD của client, mà dân làng không có ai điều khiển nên không có HUD.
--   Nên trạng thái hồn ma ở đây là do mình tự dựng: vẫn là cùng một entity,
--   chỉ đổi màu, gỡ khả năng đánh nhau, và cắm cờ để cây hành vi rẽ nhánh.

local MAU_HON_MA = { 0.5, 0.6, 1, 0.5 }   -- xanh lơ, mờ

function dan_lang.ThanhHonMa(inst, noi_chet)
    local a = inst.ailang
    if a == nil or a.la_hon_ma then return end

    local x, _, z = inst.Transform:GetWorldPosition()
    a.noi_chet = noi_chet or { x, z }
    a.la_hon_ma = true
    a.muc_tieu = nil

    -- Quái thôi nhắm vào hồn ma, và hồn ma thôi đánh lại.
    inst:AddTag("notarget")
    if inst.components.combat ~= nil then
        inst.components.combat:SetTarget(nil)
        inst.components.combat.defaultdamage = 0
    end
    if inst.components.health ~= nil then
        inst.components.health:SetInvincible(true)
    end
    if inst.AnimState ~= nil then
        inst.AnimState:SetMultColour(unpack(MAU_HON_MA))
    end

    nen.log("dân làng", tostring(a.ten), "đã chết tại",
            string.format("%.0f,%.0f", a.noi_chet[1], a.noi_chet[2]),
            "— thành hồn ma, đi tìm chỗ hồi sinh")
end

function dan_lang.HoiSinh(inst)
    local a = inst.ailang
    if a == nil or not a.la_hon_ma then return false end

    a.la_hon_ma = false
    inst:RemoveTag("notarget")
    if inst.components.health ~= nil then
        inst.components.health:SetInvincible(false)
        inst.components.health:SetPercent(0.5)
    end
    if inst.components.combat ~= nil then
        inst.components.combat.defaultdamage = TUNING.WILSON_ATTACK_DAMAGE or 34
    end
    if inst.AnimState ~= nil then
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end

    -- Quay lại chỗ chết nhặt đồ. Nhánh "nhặt" của cây hành vi lo phần còn lại.
    a.ve_nhat_do = a.noi_chet
    nen.log("dân làng", tostring(a.ten), "đã hồi sinh — quay lại chỗ chết nhặt đồ")
    return true
end

function dan_lang.LaHonMa(inst)
    return inst ~= nil and inst.ailang ~= nil and inst.ailang.la_hon_ma == true
end

-- Chụp lại trạng thái để lưu vào world.
function dan_lang.ChupHoSo(inst)
    if inst == nil or not inst:IsValid() or inst.ailang == nil then return nil end
    local x, _, z = inst.Transform:GetWorldPosition()
    return {
        tui       = ChupTui(inst),
        ma        = inst.ailang.ma,
        ten       = inst.ailang.ten,
        nhan_vat  = inst.prefab,
        tinh_cach = inst.ailang.tinh_cach,
        nha       = inst.ailang.nha,
        vi_tri    = { x, z },
        la_hon_ma = inst.ailang.la_hon_ma,
        noi_chet  = inst.ailang.noi_chet,
        mau       = inst.components.health ~= nil
                    and inst.components.health:GetPercent() or 1,
    }
end

function dan_lang.LaDanLang(inst)
    return inst ~= nil and inst.IsValid ~= nil and inst:IsValid() and inst:HasTag(TAG)
end

function dan_lang.TatCa()
    local ds = {}
    for _, e in pairs(Ents) do
        if dan_lang.LaDanLang(e) then table.insert(ds, e) end
    end
    return ds
end

dan_lang.TAG = TAG

return dan_lang

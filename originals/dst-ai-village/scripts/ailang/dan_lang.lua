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

local TIM_DICH = 12   -- bán kính tự tìm kẻ địch

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
        thien_cam = hoso.thien_cam,
        che_do   = hoso.che_do,
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

    -- Nhà mặc định là chỗ được sinh ra. Không có nhà thì cây hành vi cũ cho
    -- dân làng BÁM THEO NGƯỜI CHƠI — người chơi không muốn vậy, họ muốn dân
    -- làng sống quanh làng của mình.
    if inst.ailang.nha == nil then
        inst.ailang.nha = { x or 0, z or 0 }
    end

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

    -- ⚠ Prefab người chơi KHÔNG BAO GIỜ tự nhắm mục tiêu — người chơi thật tự
    --   bấm chuột. Đã đo: targetfn=false, retargetperiod=nil, và đẩy sự kiện
    --   "attacked" vào thì combat.target vẫn nil. Không có hai thứ dưới đây
    --   thì dân làng cầm giáo đứng chịu trận, đúng như người chơi báo.
    inst:ListenForEvent("attacked", function(_, data)
        if data ~= nil and data.attacker ~= nil and not dan_lang.LaHonMa(inst)
           and inst.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end)

    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(2, function(me)
            if dan_lang.LaHonMa(me) then return nil end
            return FindEntity(me, TIM_DICH, function(v)
                return v.components.combat ~= nil
                   and v.components.health ~= nil
                   and not v.components.health:IsDead()
                   and not dan_lang.LaDanLang(v)
                   -- Chỉ đánh thứ ĐANG nhắm vào mình hoặc vào người chơi.
                   -- Không thì dân làng đi tàn sát cả thỏ và heo trong bản đồ.
                   and (v.components.combat.target == me
                        or (v.components.combat.target ~= nil
                            and v.components.combat.target:HasTag("player")))
            end, nil, { "INLIMBO", "notarget", "wall", "structure", "playerghost" },
               { "monster", "hostile" })
        end)
    end

    if hoso.la_hon_ma then
        dan_lang.ThanhHonMa(inst, hoso.noi_chet)
    end

    -- ⚠ PHẢI là SetCanSleep(false), KHÔNG phải AddServerNonSleepable().
    --
    --   Entity DST "ngủ" khi không có người chơi ở gần, và entity ngủ thì
    --   KHÔNG chạy não — não dừng là mất luôn việc đang làm dở.
    --
    --   Mình từng dùng AddServerNonSleepable() và kết luận nhầm rằng "engine
    --   không cho ép thức". Sai ở chỗ dùng SAI HÀM. Đã đo, không có người chơi
    --   nào trong world:
    --     heo vanilla, không làm gì                  -> ngủ
    --     heo + SetCanSleep(false)                   -> THỨC, não chạy
    --     dân làng, chỉ có AddServerNonSleepable()   -> ngủ
    --     dân làng + SetCanSleep(false)              -> THỨC, não chạy
    --
    --   Phải gọi lúc entity CÒN THỨC (ngay sau khi spawn). Gọi lên một entity
    --   đã ngủ rồi thì vô hiệu — đó là lý do lần thử đầu của mình thất bại.
    --
    --   Cái giá: mỗi dân làng thức tốn ≈0,9% CPU liên tục, kể cả lúc không có
    --   ai xem. Xem mục "Chi phí" trong README trước khi tăng số dân làng.
    inst.entity:SetCanSleep(false)

    -- Thiện cảm và chế độ đi theo, mượn mô hình Wurt ↔ merm.
    require("ailang/than_thiet").GanVaoDanLang(inst)

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

local MAU_HON_MA = { 1, 1, 1, 0.7 }   -- build hồn ma đã mờ sẵn, chỉ mờ thêm chút

-- Nhân vật nào có build hồn ma riêng. Lấy từ chính file game
-- (data/anim/ghost_<tên>_build.zip), không phải đoán.
local HON_MA_BUILD = {
    wilson = true, willow = true, wendy = true, wolfgang = true, wx78 = true,
    wickerbottom = true, woodie = true, wes = true, waxwell = true,
    wathgrithr = true, webber = true, winona = true, warly = true,
    wortox = true, wormwood = true, wurt = true, walter = true, wanda = true,
}

-- Hồn ma kêu định kỳ để người chơi biết nó là gì và cần gì.
local KEU = {
    "Tôi chết rồi... ai đó cứu tôi với.",
    "Lạnh quá... tôi cần một bia đá hồi sinh.",
    "Dựng cho tôi một tượng thịt đi, tôi đứng đây chờ.",
    "Đồ của tôi vẫn còn ở chỗ tôi ngã xuống.",
}

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
    -- Đổi sang dáng hồn ma của DST bằng cách thay BUILD, giữ nguyên BANK.
    --
    -- ⚠ ĐỪNG gọi AnimState:SetBank("ghost") — KHÔNG CÓ bank nào tên "ghost".
    --   Kiểm trong chính file game: data/anim/ KHÔNG có ghost.zip, chỉ có
    --   ghost_build.zip và ghost_<nhân vật>_build.zip. Trỏ bank vào hư vô thì
    --   entity BIẾN MẤT HẲN — người chơi báo "thấy chỉ hướng của wilson nhưng
    --   bay tới không thấy ai". Hàm không báo lỗi gì cả.
    --
    --   Đổi mỗi build thì mọi hoạt ảnh vẫn chạy (bank không đổi) mà trông vẫn
    --   ra hồn ma — DST có sẵn build hồn ma riêng cho từng nhân vật.
    if inst.AnimState ~= nil then
        nen.thu("đổi dáng hồn ma", function()
            local rieng = "ghost_" .. tostring(inst.prefab) .. "_build"
            inst.AnimState:SetBuild(HON_MA_BUILD[inst.prefab] and rieng or "ghost_build")
            inst.AnimState:SetMultColour(unpack(MAU_HON_MA))
        end)
    end

    -- Tag "playerghost" là thứ các vật phẩm hồi sinh soi vào để biết có dùng
    -- được không.
    inst:AddTag("playerghost")

    -- ⚠ KHÔNG dựa vào đường hồi sinh nội bộ của engine — nó gắn với phiên
    --   người chơi thật. `trader` do than_thiet gắn sẵn cho MỌI dân làng nhận
    --   luôn cả đồ hồi sinh khi đang là hồn ma, nên ở đây không cần làm gì.

    -- ⚠ Hồn ma ở đây KHÔNG giống hồn ma DST thật (engine không cho, xem chú
    --   thích ở đầu mục). Người chơi báo "thấy một Wendy mờ đứng im, giống hồn
    --   ma nhưng không hiện giống hồn ma" — nhìn thì lạ mà không đoán ra là gì,
    --   và không biết cứu kiểu nào. Nên phải TỰ NÓI RA.
    if inst.hon_ma_keu == nil then
        inst.hon_ma_keu = inst:DoPeriodicTask(20, function()
            if not dan_lang.LaHonMa(inst) then
                if inst.hon_ma_keu ~= nil then inst.hon_ma_keu:Cancel() end
                inst.hon_ma_keu = nil
                return
            end
            if inst.components.talker ~= nil then
                inst.components.talker:Say(KEU[math.random(#KEU)])
            end
        end)
        if inst.components.talker ~= nil then
            inst.components.talker:Say("Tôi chết rồi... ai đó cứu tôi với.")
        end
    end

    nen.log("dân làng", tostring(a.ten), "đã chết tại",
            string.format("%.0f,%.0f", a.noi_chet[1], a.noi_chet[2]),
            "— thành hồn ma, đi tìm chỗ hồi sinh")
end

function dan_lang.HoiSinh(inst)
    local a = inst.ailang
    if a == nil or not a.la_hon_ma then return false end

    a.la_hon_ma = false
    inst:RemoveTag("playerghost")
    if inst.components.trader ~= nil then inst:RemoveComponent("trader") end
    -- Trả lại dáng người: chỉ đổi build về, KHÔNG đụng bank (xem chú thích ở
    -- ThanhHonMa — đụng bank là entity biến mất).
    if inst.AnimState ~= nil then
        nen.thu("trả lại dáng người", function()
            inst.AnimState:SetBuild(inst.prefab)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
        end)
    end
    if inst.hon_ma_keu ~= nil then inst.hon_ma_keu:Cancel() inst.hon_ma_keu = nil end
    if inst.components.talker ~= nil then
        inst.components.talker:Say("Tôi sống lại rồi! Để tôi đi tìm đồ của mình.")
    end
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
        thien_cam = inst.ailang.thien_cam,
        che_do    = inst.ailang.che_do,
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

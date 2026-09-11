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
        inst.components.health:SetPercent(math.max(0.1, hoso.mau))
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

-- Chụp lại trạng thái để lưu vào world.
function dan_lang.ChupHoSo(inst)
    if inst == nil or not inst:IsValid() or inst.ailang == nil then return nil end
    local x, _, z = inst.Transform:GetWorldPosition()
    return {
        ma        = inst.ailang.ma,
        ten       = inst.ailang.ten,
        nhan_vat  = inst.prefab,
        tinh_cach = inst.ailang.tinh_cach,
        nha       = inst.ailang.nha,
        vi_tri    = { x, z },
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

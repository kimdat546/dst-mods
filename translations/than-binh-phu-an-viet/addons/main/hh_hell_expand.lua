--
-- ĐỊA NGỤC — mở rộng cường hoá sang quái của MOD KHÁC
-- (phần mở rộng của bản Việt hoá, không có trong mod gốc)
--
-- VẤN ĐỀ: mod gốc chỉ cường hoá quái nằm trong danh sách trắng cứng
-- scripts/enums/hh_prefab_list.lua -> ["organism"]: 226 prefab, TOÀN BỘ là
-- vanilla, 0 con từ mod khác. Quét server thật ngày 831 thấy 19 loại có
-- >=1000 máu mà không hề được cường hoá, trong đó có boss Đăng Tiên:
--     xd_jfsn  121.500 máu -> 1,7 giây ở 73.400 DPS
--     xd_qlch  113.400 máu -> 1,5 giây
-- và cả vài con vanilla mới tác giả chưa kịp thêm (lunar_grazer,
-- lunarthrall_plant_queen, stageusher).
--
-- CÁCH LÀM: AddPrefabPostInitAny bắt MỌI thực thể, lọc chặt rồi mới gắn
-- component hh_monster. Chỉ chạy khi độ khó = Địa Ngục.
--
-- ⚠ Hàm này chạy cho TỪNG thực thể sinh ra trong game, nên bộ lọc phải rẻ và
-- phải chặt. Gắn nhầm vào thú cưng hay công trình là hỏng ván chơi.
--
local function batDau()
    if TUNING["HH_HELL_MODE"] == nil then
        return
    end

    -- Ngưỡng máu: dưới mức này thì kệ, tránh đụng vào bướm/chim/thỏ vặt.
    local NGUONG_MAU = 200

    -- Tag loại trừ: người chơi, thú cưng, công trình, bù nhìn tập đánh.
    local TAG_LOAI_TRU = {
        "player", "playerghost", "companion", "abigail", "ghost",
        "structure", "wall", "chester", "hutch", "critter", "pet",
        "balloon", "bird", "veggie", "farm_plant",
        -- bù nhìn đo Chiến lực của chính bản Việt hoá: cường hoá nó thì
        -- số đo sai hoàn toàn.
        "hh_rank_dummy",
    }

    -- Prefab loại trừ hẳn: bù nhìn tập đánh vanilla và của mod này.
    local PREFAB_LOAI_TRU = {
        ["punchingbag"] = true,
        ["hh_rank_dummy"] = true,
        ["hh_rank_dummy_placed"] = true,
    }

    local so_da_gan = 0

    AddPrefabPostInitAny(function(inst)
        if not TheWorld or not TheWorld["ismastersim"] then
            return
        end
        if inst == nil or inst["prefab"] == nil then
            return
        end
        if PREFAB_LOAI_TRU[inst["prefab"]] then
            return
        end
        -- prefab của chính mod này đã có đường xử lý riêng
        if string["sub"](inst["prefab"], 1, 3) == "hh_" then
            return
        end
        local com = inst["components"]
        if com == nil or com["hh_monster"] ~= nil then
            return
        end
        -- BẮT BUỘC có cả combat lẫn health: chỉ cường hoá thứ biết đánh nhau.
        if com["combat"] == nil or com["health"] == nil then
            return
        end
        if com["health"]["maxhealth"] == nil or com["health"]["maxhealth"] < NGUONG_MAU then
            return
        end
        for _, tag in ipairs(TAG_LOAI_TRU) do
            if inst:HasTag(tag) then
                return
            end
        end
        -- theo người chơi (thú cưng, lính triệu hồi) thì bỏ qua
        if com["follower"] ~= nil and com["follower"]["leader"] ~= nil then
            return
        end

        inst:AddComponent("hh_monster")
        so_da_gan = so_da_gan + 1
    end)

    -- In một lần sau khi thế giới dựng xong, để soi log biết có ăn không.
    AddSimPostInit(function()
        print(("[hh-viet] Địa Ngục: đã mở rộng cường hoá cho %d thực thể ngoài danh sách gốc")
                :format(so_da_gan))
    end)
end

local ok, loi = pcall(batDau)
if not ok then
    print("[hh-viet] lỗi mở rộng Địa Ngục: " .. tostring(loi))
end

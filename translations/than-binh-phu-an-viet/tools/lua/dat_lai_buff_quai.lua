-- Đặt lại dòng cường hoá cho MỌI quái đang tồn tại trong world.
--
-- Dùng sau khi đổi độ khó / cường độ Địa Ngục, vì quái đã sinh từ trước giữ
-- nguyên dòng cũ cho tới khi chết và sinh lại.
--
-- ⚠ HAI CÁI BẪY, cả hai đều đã vấp phải trên server thật:
--
-- 1. ĐỪNG gán `m.hh_effects = {}`.
--    hh_monster.lua:824  AddEffectValueByKey(key, num)
--        if not self.hh_effects[key] then return false end   ← khoá phải CÓ SẴN
--    Bảng này được gieo đầy đủ khoá lúc tạo component. Gán về bảng rỗng là mọi
--    khoá thành nil -> KHÔNG dòng nào áp được nữa, quái thành bao cát. Đã làm
--    hỏng 775 quái theo đúng cách này rồi mới phát hiện.
--    Cách đúng: DỰNG LẠI component (RemoveComponent + AddComponent).
--
-- 2. Quái kho báu có BỘ KIT CỐ ĐỊNH do tác giả gán (immuneTearing, poisonTurret,
--    iceLaser, atkBlood...). Bốc ngẫu nhiên đè lên là mất kit — mất
--    immuneTearing thì phần "miễn Xé Rách không nhân máu" của Địa Ngục không
--    còn tác dụng, boss vọt lên hàng triệu máu. Phải phục hồi theo treasure_id.
--
local T = require("enums/hh_treasure_monster")
local cfg = T["TREASURE_MONSTER_CONFIG"]

-- Dự phòng khi treasure_id đã mất: dò kit theo prefab.
local THEO_PREFAB = {
    ["mutatedbearger"] = "mutatedbearger_boss",
    ["mutateddeerclops"] = "mutateddeerclops_boss",
    ["warg"] = "mutatedwarg_boss",
}

local thuong, kho_bau, loi = 0, 0, 0
for _, e in pairs(Ents) do
    local m_cu = e.components and e.components.hh_monster
    if m_cu and e:IsValid() then
        local tid = m_cu["treasure_id"]
        if tid == nil and (e["hh_is_treasure_boss"] or e["hh_is_treasure"]) then
            tid = THEO_PREFAB[e["prefab"]]
        end
        local ok = pcall(function()
            e:RemoveComponent("hh_monster")
            e:AddComponent("hh_monster")
            local m = e.components.hh_monster
            if tid and cfg[tid] and cfg[tid]["start_fn"] then
                m:SetTreasureId(tid)
                cfg[tid]["start_fn"](e)
                kho_bau = kho_bau + 1
            else
                for _ = 1, 40 do
                    if not m:AddBuffByName() then break end
                end
                thuong = thuong + 1
            end
            e:PushEvent("hh_change_max_health")
        end)
        if not ok then loi = loi + 1 end
    end
end
print(string.format("[dat-lai-buff] quai thuong=%d | quai kho bau=%d | loi=%d | ngay=%s",
        thuong, kho_bau, loi, tostring(TheWorld.state.cycles)))

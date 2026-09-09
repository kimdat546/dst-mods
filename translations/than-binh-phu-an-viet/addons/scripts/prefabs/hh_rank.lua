--
-- Bù nhìn đo chiến lực — phần mở rộng của bản Việt hoá, không có trong mod gốc.
-- Dùng lại anim "wilsonstatue" của game (prefab dummytarget trong Đấu Trường Dung Nham)
-- nên không cần thêm tài nguyên đồ hoạ nào.
--
local assets = {
    Asset("ANIM", "anim/wilsonstatue.zip"),
}

-- Máu chuẩn của bù nhìn. Con số này PHẢI cố định cho mọi lần đo:
-- phù ấn "Xé Rách" cộng 3% máu HIỆN TẠI của mục tiêu, nên nếu máu thay đổi
-- thì điểm của hai người chơi không còn so sánh được với nhau.
local MAX_HP = 500000

-- Độ dài một phiên đo (giây). 60 giây x ~5 nhát/giây = ~300 nhát, đủ để
-- phương sai của các dòng theo xác suất (bạo kích, sát thương gấp năm) về
-- gần kỳ vọng — sai số tổng chỉ khoảng vài phần trăm.
local SESSION_TIME = 60

-- Đòn quy chiếu để quy đổi "giảm sát thương phẳng" thành tỉ lệ. Chọn 1000 cho
-- sát với đòn boss thật; đổi số này chỉ làm nặng/nhẹ giá trị của giảm phẳng.
local REF_HIT = 1000

----------------------------------------------------------------------
-- Ghi nhận sát thương
----------------------------------------------------------------------

-- Quy sát thương của thuộc hạ (Abigail, clone Đăng Tiên, thú cưng...) về cho chủ,
-- nếu không thì phần sức mạnh đó bị bỏ sót khỏi chiến lực.
local function getOwner(afflicter)
    if afflicter == nil then
        return nil
    end
    if afflicter.components ~= nil and afflicter.components.hh_player ~= nil then
        return afflicter
    end
    local follower = afflicter.components ~= nil and afflicter.components.follower or nil
    if follower ~= nil and follower.leader ~= nil
            and follower.leader.components ~= nil
            and follower.leader.components.hh_player ~= nil then
        return follower.leader
    end
    return nil
end

local function recordDamage(inst, afflicter, amount)
    local owner = getOwner(afflicter)
    if owner == nil or owner.userid == nil or owner.userid == "" then
        return
    end
    -- Chỉ ghi khi có phiên đang chạy, và CHỈ của người đã kích hoạt.
    -- Chém nhầm lúc rảnh không còn khởi động phiên hay làm bẩn số liệu.
    if inst.hh_left == nil or inst.hh_owner == nil then
        return
    end
    if owner.userid ~= inst.hh_owner then
        return
    end
    local rec = inst.hh_damage[owner.userid]
    if rec == nil then
        rec = { name = owner.name or owner.prefab, userid = owner.userid,
                player = owner, total = 0, hits = 0, best = 0 }
        inst.hh_damage[owner.userid] = rec
    end
    rec.total = rec.total + amount
    rec.hits = rec.hits + 1
    if amount > rec.best then
        rec.best = amount
    end
    inst.hh_dirty = true
end

-- Móc vào MÁU của bù nhìn chứ không vào hàm sát thương của người chơi.
-- Lý do: sát thương chuẩn (DoHHDelta), đòn của thuộc hạ, độc và phản thương
-- đều KHÔNG đi qua hh_player:DoAttackDamage — móc ở đây mới bắt được đủ.
local function hookHealth(inst)
    local health = inst.components.health
    local oldSetVal = health.SetVal
    health.SetVal = function(self, val, cause, afflicter, ...)
        local cur = self.currenthealth or MAX_HP
        local lost = cur - (val or cur)
        if lost > 0 then
            recordDamage(inst, afflicter, lost)
        end
        -- Luôn kéo về đầy máu: vừa để bù nhìn không chết,
        -- vừa để "Xé Rách" luôn tính trên cùng một mốc máu.
        return oldSetVal(self, MAX_HP, cause, afflicter, ...)
    end
end

----------------------------------------------------------------------
-- Nhãn nổi trên đầu
----------------------------------------------------------------------

local function formatNum(n)
    if n >= 1e6 then
        return string.format("%.2fm", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n / 1e3)
    end
    return tostring(math.floor(n))
end

-- Client đọc net_string rồi mới vẽ nhãn.
-- KHÔNG gọi Label:SetText() ở phía server: world local chạy server trong tiến
-- trình riêng (dontstarve_dedicated_server_nullrenderer), Label là thứ của
-- client nên chữ đặt bên server không bao giờ tới người chơi.
local function onTextDirty(inst)
    if inst.Label ~= nil and inst.hh_text ~= nil then
        inst.Label:SetText(inst.hh_text:value())
    end
end

local function sumDamage(inst)
    local total, hits = 0, 0
    for _, rec in pairs(inst.hh_damage) do
        total = total + rec.total
        hits = hits + rec.hits
    end
    return total, hits
end

----------------------------------------------------------------------
-- Phiên đo 60 giây
----------------------------------------------------------------------

-- Ghi kỷ lục vào kho của thế giới, khoá theo userid (tài khoản Klei) nên
-- vẫn còn sau khi chết, đổi nhân vật hay khởi động lại server.
local function saveRecord(player_name, userid, cl, dps, ehp, total, hits)
    local world = TheWorld ~= nil and TheWorld.components ~= nil
            and TheWorld.components.hh_world or nil
    if world == nil then
        return false
    end
    local old = world:GetValueByUid("power_rank", userid)
    local best = (type(old) == "table" and tonumber(old.cl)) or 0
    if cl <= best then
        return false, best
    end
    world:SetValueByUid("power_rank", userid, {
        name  = player_name,
        cl    = cl,      -- Chiến lực = √(công × thủ)
        dps   = dps,     -- vế công, đo trên bù nhìn
        ehp   = ehp,     -- vế thủ, tính từ chỉ số
        total = total,
        hits  = hits,
        day   = TheWorld.state ~= nil and TheWorld.state.cycles or 0,
    })
    return true, best
end

----------------------------------------------------------------------
-- Vế PHÒNG THỦ: tính thẳng từ chỉ số, không cần đo
--
-- Công thì phải đo (kỹ năng nhân vật, clone, mod khác, xác suất bạo kích...),
-- nhưng thủ là công thức tất định nên đọc chỉ số ra là đủ.
----------------------------------------------------------------------
local function computeEHP(player)
    if player == nil or player.components == nil
            or player.components.health == nil then
        return 0
    end
    local hp = player.components.health.maxhealth or 0
    if hp <= 0 then
        return 0
    end

    local absorb, flat = 0, 0
    local hp_com = player.components.hh_player
    if hp_com ~= nil and hp_com.GetEffectValueByKey ~= nil then
        absorb = (hp_com:GetEffectValueByKey("absorbDamage") or 0) / 100
        flat = hp_com:GetEffectValueByKey("reduceAttackedDamage") or 0
    end
    absorb = math.min(absorb, 0.8)   -- trần cứng trong hh_player:GetBlockDamage

    -- Giáp gốc của game: lấy MAX chứ không cộng dồn (inventory:ApplyDamage)
    local armor = 0
    local inv = player.components.inventory
    if inv ~= nil and inv.equipslots ~= nil then
        for _, item in pairs(inv.equipslots) do
            if item.components ~= nil and item.components.armor ~= nil then
                local a = item.components.armor:GetAbsorption(nil, nil) or 0
                if a > armor then armor = a end
            end
        end
    end
    armor = math.min(armor, 1)

    local taken = math.max(REF_HIT - flat, 1) * (1 - absorb) * (1 - armor)
    if taken <= 0 then
        taken = 1
    end
    return hp * REF_HIT / taken
end

-- Đọc toàn bộ bảng kỷ lục đã lưu, sắp theo DPS giảm dần.
local function getBoard()
    local world = TheWorld ~= nil and TheWorld.components ~= nil
            and TheWorld.components.hh_world or nil
    if world == nil or world.hh_save == nil or world.hh_save["power_rank"] == nil then
        return {}
    end
    local rows = {}
    for uid, v in pairs(world.hh_save["power_rank"]) do
        if type(v) == "table" and v.dps ~= nil then
            v.uid = uid
            table.insert(rows, v)
        end
    end
    table.sort(rows, function(a, b) return (a.dps or 0) > (b.dps or 0) end)
    return rows
end

-- Thứ hạng của một chỉ số DPS trong bảng đã lưu.
local function getRank(cl)
    local world = TheWorld ~= nil and TheWorld.components ~= nil
            and TheWorld.components.hh_world or nil
    if world == nil or world.hh_save == nil or world.hh_save["power_rank"] == nil then
        return 1
    end
    local higher = 0
    for _, v in pairs(world.hh_save["power_rank"]) do
        if type(v) == "table" and (tonumber(v.cl) or 0) > cl then
            higher = higher + 1
        end
    end
    return higher + 1
end

local function finishSession(inst)
    inst.hh_left = nil
    if inst.hh_tick ~= nil then
        inst.hh_tick:Cancel()
        inst.hh_tick = nil
    end
    inst.hh_text:set("")
    if inst.components.activatable ~= nil then
        inst.components.activatable.inactive = true
    end

    local rec = inst.hh_owner ~= nil and inst.hh_damage[inst.hh_owner] or nil
    inst.hh_owner = nil
    if rec == nil or rec.total <= 0 then
        return
    end

    local dps = rec.total / SESSION_TIME
    local ehp = computeEHP(rec.player)
    local cl = math.floor(math.sqrt(dps * ehp))
    local is_record, old_best = saveRecord(rec.name, rec.userid, cl, dps, ehp,
            rec.total, rec.hits)

    -- Chỉ thông báo khi bảng xếp hạng THỰC SỰ đổi. Không phải kỷ lục mới thì
    -- thứ hạng không thể xê dịch, nên im lặng — tránh làm loãng khung chat.
    if is_record and TheNet ~= nil then
        local rank = getRank(cl)
        if rank == 1 then
            TheNet:Announce(string.format(
                    "%s vươn lên DẪN ĐẦU bảng chiến lực: %d điểm",
                    tostring(rec.name), cl))
        else
            TheNet:Announce(string.format(
                    "%s lập kỷ lục mới: %d điểm chiến lực (cũ %d) — hạng %d",
                    tostring(rec.name), cl, math.floor(old_best or 0), rank))
        end
    end
end

local function tickSession(inst)
    if inst.hh_left == nil then
        return
    end
    inst.hh_left = inst.hh_left - 1
    if inst.hh_left <= 0 then
        finishSession(inst)
        return
    end
    -- Nhãn chỉ hiện bộ đếm. Chi tiết nằm ở bảng thông tin khi rê chuột.
    inst.hh_text:set(inst.hh_left .. "s")
end

local function startSession(inst, player)
    if player == nil or player.userid == nil or player.userid == "" then
        return
    end
    inst.hh_damage = {}
    inst.hh_owner = player.userid
    inst.hh_owner_name = player.name or player.prefab
    inst.hh_left = SESSION_TIME
    if inst.components.activatable ~= nil then
        inst.components.activatable.inactive = false   -- ẩn hành động khi đang đo
    end
    if inst.hh_tick ~= nil then
        inst.hh_tick:Cancel()
    end
    inst.hh_tick = inst:DoPeriodicTask(1, tickSession)
    inst.hh_text:set(SESSION_TIME .. "s")
end

local function updateLabel(inst)
    -- Khi đang đo thì tickSession lo phần chữ, đừng ghi đè.
    if inst.hh_left ~= nil or not inst.hh_dirty then
        return
    end
    inst.hh_dirty = false
    inst.hh_text:set("")
end

----------------------------------------------------------------------

local function onHit(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onWorked(inst, worker)
    if worker ~= nil and worker.components ~= nil and worker.components.inventory ~= nil then
        local item = SpawnPrefab("hh_rank_dummy")
        if item ~= nil then
            item.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLabel()

    inst.Label:SetFontSize(52)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetWorldOffset(0, 4.4, 0)
    inst.Label:SetColour(1, 0.85, 0.2)
    inst.Label:Enable(true)

    inst:SetDeploySmartRadius(1)
    MakeObstaclePhysics(inst, 0.3)

    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")

    -- "monster" để người chơi nhắm và đánh được bằng chuột phải
    inst:AddTag("monster")
    inst:AddTag("hh_rank_dummy")
    inst:AddTag("notraptrigger")

    -- Biến mạng: server set, client nghe sự kiện dirty rồi vẽ nhãn.
    inst.hh_text = net_string(inst.GUID, "hh_rank_text", "hh_rank_text_dirty")
    inst:ListenForEvent("hh_rank_text_dirty", onTextDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.hh_damage = {}
    inst.hh_dirty = true

    inst:AddComponent("inspectable")
    -- Mod đọc GetDescription() để đổ vào ô "Mô tả" của bảng thông tin khi rê
    -- chuột, nên chỉ cần trả chuỗi động ở đây là ăn khớp sẵn, không phải vá
    -- hh_rpc.lua của mod gốc.
    inst.components.inspectable.descriptionfn = function(dummy, viewer)
        local total, hits = sumDamage(dummy)
        -- Lúc rảnh: hiện luôn top 1 và hạng của người đang rê chuột, để xem
        -- bảng ngay tại chỗ mà không cần mở console.
        if dummy.hh_left == nil and hits <= 0 then
            local board = getBoard()
            if #board == 0 then
                return "Bấm để đo chiến lực trong " .. SESSION_TIME .. " giây"
            end
            local top = string.format("#1 %s %s", tostring(board[1].name),
                    formatNum(board[1].dps))
            local mine = " | bạn chưa đo"
            if viewer ~= nil and viewer.userid ~= nil then
                for i, v in ipairs(board) do
                    if v.uid == "uid_" .. viewer.userid or v.uid == viewer.userid then
                        mine = string.format(" | bạn hạng %d: %s", i, formatNum(v.dps))
                        break
                    end
                end
            end
            return top .. mine
        end
        local secs = dummy.hh_left ~= nil and (SESSION_TIME - dummy.hh_left) or SESSION_TIME
        local who = dummy.hh_owner_name or "?"
        return string.format("%s | %s sát thương | %d nhát | %s/giây",
                tostring(who), formatNum(total), hits,
                formatNum(secs > 0 and total / secs or 0))
    end

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "ww_torso"
    -- BẮT BUỘC phải > 0: HH_UTILS:IsValidCombat() kiểm tra defaultdamage,
    -- nếu bằng 0 thì phù ấn "Xé Rách" bị bỏ qua hoàn toàn và người có nó bị đo hụt.
    inst.components.combat.defaultdamage = 1
    inst.components.combat:SetAttackPeriod(math.huge)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(MAX_HP)
    inst.components.health.canheal = false
    hookHealth(inst)
    inst:ListenForEvent("attacked", onHit)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onWorked)

    -- Gắn thẻ "boss_monster" của mod. Không có thẻ này thì dòng "Sát Thủ Khổng Lồ"
    -- và mọi viên ngọc "Khắc Chế Thủ Lĩnh" đóng góp bằng 0 — sai lệch tới ba lần.
    -- Gắn thẻ "boss_monster" bằng TAY, KHÔNG dùng component hh_monster.
    --
    -- Vì sao: hh_monster:AddFirstBuffs() luôn tự bốc buff ngẫu nhiên cho quái
    -- (boss được tới 10 dòng), gồm cả reducePercentDamage 10~20% và cộng máu
    -- theo ngày. Mỗi con bù nhìn sẽ chống chịu một kiểu -> số đo vô nghĩa.
    -- SetMaxEffectLimit(0) KHÔNG chặn được, vì trong AddBuffByName nó chỉ dùng
    -- để NÂNG trần:  if max_effect_limit > add_limit then add_limit = ... end
    --
    -- Mà thứ duy nhất mod cần để tính "sát thương lên boss" là cái thẻ:
    --     if target["HasHHTag"] then
    --         amount = handleTagTarget(self, target, amount, "boss_monster", ...)
    -- nên chỉ cần tự dựng hh_tags + HasHHTag là đủ, không kéo theo buff nào.
    inst.hh_tags = { ["boss_monster"] = "boss" }
    inst.HasHHTag = function(self, tag_name)
        return tag_name ~= nil and self.hh_tags[tag_name] ~= nil
    end

    inst.StartSession = startSession
    inst.hh_text:set("")

    inst:AddComponent("activatable")
    inst.components.activatable.inactive = true
    inst.components.activatable.OnActivate = function(_, doer)
        -- Đang có phiên của người khác thì không cho cướp.
        if inst.hh_left ~= nil then
            return false
        end
        startSession(inst, doer)
        return true
    end
    inst.components.activatable.quickaction = true

    inst:DoPeriodicTask(0.5, updateLabel)

    return inst
end

return Prefab("hh_rank_dummy_placed", fn, assets),
    MakePlacer("hh_rank_dummy_placer", "wilsonstatue", "wilsonstatue", "idle")

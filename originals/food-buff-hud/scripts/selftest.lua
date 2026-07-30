-- Selftest chạy trên dedicated server HEADLESS, in PASS/FAIL ra log.
--
-- Kiểm giả định CỐT LÕI của mod: buff gắn vào người chơi có timer "buffover"
-- đọc được số giây thật. Nếu giả định này sai thì toàn bộ mod vô nghĩa, nên
-- đây là thứ đáng kiểm trước khi bàn tới HUD.
--
-- Đọc kết quả: docker compose logs master | grep '\[FoodBuffHUD\]\[TEST\]'
--
-- KHÔNG kiểm được ở đây (cần client thật có màn hình):
--   HUD hiện ra, RPC tới được client, kéo thả bằng chuột phải.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local function log(msg) print("[FoodBuffHUD][TEST] " .. msg) end

local DEBUG = rawget(_G, "FOODBUFFHUD_DEBUG")
if DEBUG == nil then
    log("FATAL: không thấy FOODBUFFHUD_DEBUG — modmain chưa nạp?")
    return
end

local pass, fail = 0, 0
local function check(ok, what, detail)
    if ok then
        pass = pass + 1
    else
        fail = fail + 1
        log("  FAIL " .. what .. (detail and ("  → " .. tostring(detail)) or ""))
    end
end

-- Các buff dựng bằng MakeBuff trong prefabs/foodbuffs.lua
local BUFFS = {
    "buff_attack",
    "buff_playerabsorption",
    "buff_workeffectiveness",
    "buff_moistureimmunity",
    "buff_electricattack",
    "buff_sleepresistance",
}

log("===== BẮT ĐẦU =====")

-- 1. Dựng một entity người chơi giả. Không có client điều khiển, nên phải
--    truyền skip_test=true cho AddDebuff (không thì bị coi là chết/ghost).
local p = SpawnPrefab("wilson")
if p == nil then
    log("FATAL: không spawn được wilson")
    return
end
p.Transform:SetPosition(0, 0, 0)
log("đã spawn wilson để test")

-- 2. Gắn từng buff rồi đọc lại thời gian còn lại
for _, key in ipairs(BUFFS) do
    p:AddDebuff(key, key, nil, true)
end

local d = p.components.debuffable
check(d ~= nil, "player có component debuffable")

if d ~= nil then
    for _, key in ipairs(BUFFS) do
        local rec = d.debuffs[key]
        if rec == nil then
            check(false, key .. ": gắn được vào debuffable", "không thấy trong bảng debuffs")
        else
            local ent = rec.inst
            local timer = (ent ~= nil and ent:IsValid()) and ent.components.timer or nil
            if timer == nil then
                check(false, key .. ": buff entity có component timer", "không có timer")
            elseif not timer:TimerExists("buffover") then
                check(false, key .. ': có timer tên "buffover"', "timer không tồn tại")
            else
                local left = timer:GetTimeLeft("buffover")
                check(left ~= nil and left > 0, key .. ": đọc được thời gian còn lại", left)
                log(string.format("  %s → còn %.1fs", key, left or -1))
            end
        end
    end
end

-- 3. Collect() có trả về đúng và sắp xếp tăng dần không
local list = DEBUG.Collect(p)
check(list ~= nil, "Collect() trả về danh sách")
if list ~= nil then
    check(#list == #BUFFS, string.format("Collect() thấy đủ %d buff", #BUFFS), "thấy " .. #list)
    local sorted = true
    for i = 2, #list do
        if list[i].left < list[i - 1].left then sorted = false end
    end
    check(sorted, "Collect() sắp xếp tăng dần (cái sắp hết lên trên)")
end

-- 4. Encode/Decode đi vòng có mất mát không
if list ~= nil and #list > 0 then
    local payload = DEBUG.Encode(list)
    local back = DEBUG.Decode(payload)
    check(#back == #list, "Encode→Decode giữ đủ số phần tử", #back .. "/" .. #list)
    check(back[1] ~= nil and back[1].key == list[1].key, "Encode→Decode giữ đúng key")
    check(back[1] ~= nil and math.abs(back[1].left - list[1].left) < 0.15,
        "Encode→Decode giữ đúng số giây (sai số làm tròn < 0.15s)")
    log("  payload mẫu: " .. payload:sub(1, 90))
end

-- 5. Buff lạ phải hiện tên thô hoá chứ không bị ẩn — đây là điểm chống mục ruỗng
local pretty = _G.FOODBUFFHUD_PrettyName("buff_some_future_thing")
check(pretty ~= nil and pretty ~= "" and not pretty:find("buff_"),
    "buff lạ được thô hoá tên thay vì bị bỏ", pretty)
log("  buff_some_future_thing → \"" .. tostring(pretty) .. "\"")

-- 6. Dọn
p:Remove()

log(string.format("===== KẾT QUẢ: PASS %d / FAIL %d =====", pass, fail))
log(fail == 0 and "TỔNG: PASS" or "TỔNG: FAIL")

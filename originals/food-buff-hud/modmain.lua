-- Food Buff HUD — entry point
--
-- Kiến trúc (xem README.md để biết vì sao):
--   SERVER  quét player.components.debuffable.debuffs, đọc timer "buffover"
--           → số giây THẬT → gửi RPC xuống đúng client đó
--   CLIENT  nhận RPC, tự đếm ngược tại chỗ giữa hai lần đồng bộ
--
-- Không dùng netvar vì netvar cần khai báo khớp hai phía; RPC thì không, nên
-- sau này muốn tách bản client riêng cũng không phải sửa gì ở đây.

local _G = GLOBAL
local TheNet = _G.TheNet

local RPC_NS = "FoodBuffHUD"
local SHOW_HUD = GetModConfigData("SHOW_HUD") ~= false
local WARN_SECONDS = GetModConfigData("WARN_SECONDS") or 30

-- =========================================================================
-- Tên hiển thị
--
-- Chủ ý KHÔNG hardcode danh sách buff để quyết định hiện hay không — cái đó
-- chính là lý do các mod tương tự mục ruỗng sau mỗi bản cập nhật của Klei.
-- Bảng này chỉ để dịch tên cho đẹp; buff lạ vẫn hiện, chỉ là tên thô hoá.
-- =========================================================================
local BUFF_NAMES = {
    buff_attack            = "Tăng sát thương",
    buff_playerabsorption  = "Giảm sát thương nhận",
    buff_workeffectiveness = "Làm việc nhanh",
    buff_moistureimmunity  = "Miễn ẩm ướt",
    buff_electricattack    = "Sát thương điện",
    buff_sleepresistance   = "Kháng buồn ngủ",
    buff_sleepimmunity     = "Miễn buồn ngủ",
    buff_firefrenzy        = "Cuồng hoả",
}

-- "buff_foo_bar" → "Foo bar": buff Klei thêm sau này vẫn đọc được thay vì bị ẩn
local function PrettyName(key)
    if BUFF_NAMES[key] ~= nil then return BUFF_NAMES[key] end
    local s = key:gsub("^buff_", ""):gsub("_", " ")
    return (s:gsub("^%l", string.upper))
end
_G.FOODBUFFHUD_PrettyName = PrettyName
_G.FOODBUFFHUD_WARN_SECONDS = WARN_SECONDS

-- =========================================================================
-- Mã hoá payload:  "buff_attack=178.4|buff_playerabsorption=42.0"
-- =========================================================================
local function Encode(list)
    local parts = {}
    for i = 1, #list do
        parts[#parts + 1] = string.format("%s=%.1f", list[i].key, list[i].left)
    end
    return table.concat(parts, "|")
end

local function Decode(payload)
    local list = {}
    if payload == nil or payload == "" then return list end
    for key, secs in payload:gmatch("([%w_]+)=([%d%.]+)") do
        list[#list + 1] = { key = key, left = tonumber(secs) or 0 }
    end
    return list
end

-- =========================================================================
-- CLIENT — nhận số từ server
-- =========================================================================
_G.FOODBUFFHUD_DATA = { list = {}, at = 0 }

AddClientModRPCHandler(RPC_NS, "Sync", function(payload)
    _G.FOODBUFFHUD_DATA = {
        list = Decode(payload),
        at = _G.GetTime(),   -- mốc để client tự trừ dần giữa hai lần đồng bộ
    }
end)

if SHOW_HUD then
    AddClassPostConstruct("widgets/controls", function(self)
        local FoodBuffHUD = require("widgets/foodbuffhud")
        self.foodbuffhud = self:AddChild(FoodBuffHUD(self.owner))
    end)
end

-- =========================================================================
-- SERVER — đọc thời gian thật rồi gửi xuống
-- =========================================================================
local SCAN_PERIOD = 1     -- quét mỗi giây; client tự đếm nên không cần dày hơn
local HEARTBEAT   = 5     -- gửi lại định kỳ dù không đổi, để sửa lệch

-- Đọc trực tiếp từ debuffable + timer "buffover" (cơ chế MakeBuff của game).
-- Nhờ vậy mọi buff dùng chung cơ chế đó đều được phủ, không cần biết trước tên.
local function Collect(player)
    local d = player.components.debuffable
    if d == nil or d.debuffs == nil then return nil end
    local list = {}
    for key, rec in pairs(d.debuffs) do
        local ent = rec.inst
        local timer = (ent ~= nil and ent:IsValid()) and ent.components.timer or nil
        if timer ~= nil and timer:TimerExists("buffover") then
            list[#list + 1] = { key = key, left = timer:GetTimeLeft("buffover") or 0 }
        end
    end
    -- sắp xếp theo thời gian còn lại tăng dần: cái sắp hết nằm trên cùng
    table.sort(list, function(a, b) return a.left < b.left end)
    return list
end

local function StartTracking(player)
    local last_payload, last_sent = nil, -math.huge

    player:DoPeriodicTask(SCAN_PERIOD, function()
        if not (player:IsValid() and player.userid ~= nil and player.userid ~= "") then return end

        local list = Collect(player)
        if list == nil then return end
        local payload = Encode(list)
        local now = _G.GetTime()

        -- Gửi khi tập buff đổi, hoặc theo nhịp heartbeat. Không gửi mỗi giây để
        -- khỏi tốn băng thông vô ích — client tự trừ dần được.
        if payload ~= last_payload or (now - last_sent) >= HEARTBEAT then
            last_payload, last_sent = payload, now
            SendModRPCToClient(GetClientModRPC(RPC_NS, "Sync"), player.userid, payload)
        end
    end)
end

AddPlayerPostInit(function(inst)
    -- debuffable chỉ tồn tại phía server → dùng luôn làm phép thử master sim
    inst:DoTaskInTime(0, function()
        if inst:IsValid() and inst.components.debuffable ~= nil then
            StartTracking(inst)
        end
    end)
end)

-- Phơi hàm nội bộ để selftest headless kiểm được, và để chẩn đoán khi cần.
-- Không có tác dụng phụ, không ai gọi trong lúc chơi bình thường.
_G.FOODBUFFHUD_DEBUG = { Collect = Collect, Encode = Encode, Decode = Decode }

-- Selftest chỉ chạy khi bản build test bật cờ (tools/test-harness/build.sh).
-- Bản phát hành không bao giờ đặt cờ này.
if rawget(_G, "FOODBUFFHUD_SELFTEST") then
    AddPrefabPostInit("world", function()
        _G.TheWorld:DoTaskInTime(3, function() modimport("scripts/selftest.lua") end)
    end)
end

print("[FoodBuffHUD] loaded. HUD=" .. tostring(SHOW_HUD) .. " warn=" .. tostring(WARN_SECONDS) .. "s")

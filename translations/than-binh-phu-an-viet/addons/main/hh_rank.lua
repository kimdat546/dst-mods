--
-- Đua top chiến lực — phần mở rộng của bản Việt hoá, không có trong mod gốc.
--
-- Giai đoạn 1: dựng bù nhìn, ghi nhận sát thương, đọc kết quả qua console.
-- Phiên đo 60 giây, lưu kỷ lục và bảng xếp hạng sẽ làm ở các giai đoạn sau.
--
-- Mọi thứ chạy trong pcall: một lỗi ở đây KHÔNG được phép giết cả mod.
-- (07/09/2026: một dòng sai làm mod chết lúc nạp, kéo theo mod khác spam
--  cảnh báo tới mức log phình 2 GB — không để lặp lại.)
local ok_all, err_all = pcall(function()

-- HH_UTILS là MODULE, không phải biến toàn cục: mọi file của mod đều lấy bằng
-- require. Tham chiếu thẳng như biến toàn cục sẽ ra nil và làm sập server ngay
-- khi có ai bấm vào tab (đã xảy ra 07/09/2026).
local HH_UTILS = require("utils/hh_utils")

-- Atlas nằm trong chính mod này. Dùng softresolvefilepath (trả nil thay vì
-- assert) để nếu đường dẫn sai thì chỉ mất cái icon, không sập mod.
local atlas_path = softresolvefilepath(MODROOT .. "images/hh_icon/hh_items.xml")
if atlas_path == nil then
    print("[hh_rank] không phân giải được atlas, dùng icon mặc định")
end

----------------------------------------------------------------------
-- Công thức chế tạo
----------------------------------------------------------------------

AddRecipe2("hh_rank_dummy",
        {
            Ingredient("boards", 4),
            Ingredient("hh_essence", 10),
        },
        TECH["NONE"],
        {
            ["placer"] = "hh_rank_dummy_placer",
            ["product"] = "hh_rank_dummy_placed",
            ["atlas"] = atlas_path,
            ["image"] = atlas_path ~= nil and "hh_treasure_build.tex" or nil,
        },
        { "MAGIC", "REFINE", }
)

----------------------------------------------------------------------
-- Tên và mô tả
----------------------------------------------------------------------

GLOBAL.STRINGS.NAMES.HH_RANK_DUMMY_PLACED = "Bù Nhìn Đo Chiến Lực"
GLOBAL.STRINGS.NAMES.HH_RANK_DUMMY = "Bù Nhìn Đo Chiến Lực"
GLOBAL.STRINGS.RECIPE_DESC.HH_RANK_DUMMY = "Đánh vào nó để biết mình mạnh cỡ nào."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.HH_RANK_DUMMY_PLACED =
        "Nó không đánh trả, chỉ lặng lẽ đếm."

----------------------------------------------------------------------
-- Đọc kết quả (giai đoạn 1 — tạm dùng console)
----------------------------------------------------------------------

local function formatNum(n)
    if n >= 1e6 then
        return string.format("%.2fm", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n / 1e3)
    end
    return tostring(math.floor(n))
end

local function findDummies()
    local list = {}
    for _, ent in pairs(GLOBAL.Ents) do
        if ent.prefab == "hh_rank_dummy_placed" and ent.hh_damage ~= nil then
            table.insert(list, ent)
        end
    end
    return list
end

-- Console: HH_RANK_DUMP()  — in bảng sát thương của mọi bù nhìn đang có
-- Phải dùng rawset: DST bật strict global, gán thẳng GLOBAL.X = ... sẽ ném
-- "assign to undeclared variable". Đây là lỗi làm mod chết ngày 07/09/2026.
GLOBAL.rawset(GLOBAL, "HH_RANK_DUMP", function()
    local dummies = findDummies()
    if #dummies == 0 then
        print("[chiến lực] chưa đặt bù nhìn nào")
        return
    end
    for i, inst in ipairs(dummies) do
        print(string.format("--- bù nhìn #%d ---", i))
        for userid, rec in pairs(inst.hh_damage) do
            local tb = rec.hits > 0 and rec.total / rec.hits or 0
            print(string.format("  %-16s tổng %-10s nhát %-6d tb/nhát %-10s cao nhất %s",
                    tostring(rec.name), formatNum(rec.total), rec.hits,
                    formatNum(tb), formatNum(rec.best)))
        end
    end
end)

----------------------------------------------------------------------
-- Tab "Chiến lực" trong Nhật ký thế giới
--
-- Không dựng UI mới: tab này đi qua đúng đường ống của nhật ký sẵn có
-- (RPC hh_world_logs -> danh sách chuỗi ui_config -> widget cuộn).
-- Bảng xếp hạng cũng chỉ là một danh sách dòng chữ, nên tái dùng được trọn vẹn.
--
-- Thay hàm xử lý TẠI CHỖ thay vì AddModRPCHandler lần nữa: hàm đó dùng
-- table.insert nên đăng ký lại sẽ cấp id mới và lệch với id client đã có.
----------------------------------------------------------------------

local function fmt(n)
    if n >= 1e6 then return string.format("%.2fm", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fk", n / 1e3) end
    return tostring(math.floor(n or 0))
end

-- Số chiến lực để NGUYÊN chữ số: người chơi cùng hạng nghìn phải so được
-- từng đơn vị. Chỉ chèn dấu chấm phân cách cho dễ đọc.
local function fmtCL(n)
    local t = tostring(math.floor(n or 0))
    local out = t:reverse():gsub("(%d%d%d)", "%1."):reverse()
    return (out:gsub("^%.", ""))
end

local RANK_COLOR = { "yellow", "orange", "purple" }

-- Đăng ký huy hiệu hạng vào bảng icon của mod, để chuỗi "@rank_1::22:22"
-- trong ui_config vẽ được. Atlas nằm trong addons/images/hh_icon/.
do
    -- Hai bảng icon KHÁC NHAU, dễ nhầm:
    --   TUNING.HH_ICON_CONFIG            -> chỉ dùng cho widget hover
    --   TUNING.HH_OVO_CONFIG.UI_IMAGE    -> dùng cho cú pháp "@tên" trong
    --                                       ui_config (nhật ký, bảng này)
    -- hh_utils giữ tham chiếu tới UI_IMAGE từ lúc nạp, nên phải THÊM VÀO bảng
    -- có sẵn chứ không được gán đè cả bảng.
    local xml = "images/hh_icon/hh_rank_icons.xml"
    if Assets ~= nil then
        table.insert(Assets, Asset("IMAGE", "images/hh_icon/hh_rank_icons.tex"))
        table.insert(Assets, Asset("ATLAS", xml))
    end
    local ovo = GLOBAL.TUNING["HH_OVO_CONFIG"]
    if ovo ~= nil and ovo["UI_IMAGE"] ~= nil then
        for i = 1, 3 do
            ovo["UI_IMAGE"]["rank_" .. i] = { xml, "rank_" .. i .. ".tex" }
        end
    end
end

local function buildRankRows()
    local w = GLOBAL.TheWorld
    local world = w ~= nil and w.components ~= nil and w.components.hh_world or nil
    local rows = {}

    local list = {}
    if world ~= nil and world.hh_save ~= nil and world.hh_save["power_rank"] ~= nil then
        for _, v in pairs(world.hh_save["power_rank"]) do
            if type(v) == "table" and v.cl ~= nil then
                table.insert(list, v)
            end
        end
    end
    if #list == 0 then
        table.insert(rows, { ["ui_config"] =
            "@suit_build::28:28#  Chưa có ai đo chiến lực:white:25" })
        table.insert(rows, { ["ui_config"] =
            "#  Chế Bù Nhìn Đo Chiến Lực ở tab Tinh Chế, bấm vào nó rồi đánh 60 giây:white:18" })
        return rows
    end
    table.sort(list, function(a, b) return (a.cl or 0) > (b.cl or 0) end)

    -- Dòng đệm: danh sách bắt đầu sát viền trên của khung nội dung.
    table.insert(rows, { ["ui_config"] = "# :white:7" })
    table.insert(rows, { ["ui_config"] =
        "@rank_1::28:28#  BẢNG CHIẾN LỰC:yellow:26" })

    for i, v in ipairs(list) do
        local colour = RANK_COLOR[i] or "white"
        local mark = i <= 3 and ("@rank_" .. i .. "::30:30") or "#      :white:22"
        table.insert(rows, { ["ui_config"] = string.format(
            "%s#%2d:%s:26# %s:white:24#  %s:green:30",
            mark, i, colour, tostring(v.name or "?"), fmtCL(v.cl)) })
        table.insert(rows, { ["ui_config"] = string.format(
            "#          công %s:orange:17#  ·  thủ %s:blue:17#  ·  ngày %s, %d nhát:white:15",
            fmt(v.dps or 0), fmt(v.ehp or 0), tostring(v.day or "?"), v.hits or 0) })
    end
    return rows
end

do
    local rpc = GLOBAL.MOD_RPC["hh_rpc"] and GLOBAL.MOD_RPC["hh_rpc"]["hh_world_logs"]
    local handlers = GLOBAL.MOD_RPC_HANDLERS["hh_rpc"]
    if rpc ~= nil and handlers ~= nil and handlers[rpc.id] ~= nil then
        local old = handlers[rpc.id]
        handlers[rpc.id] = function(inst, log_type, limit_count, page_index)
            if log_type == "hh_rank" then
                HH_UTILS:HHClientRpc(inst, "hh_world_logs",
                        HH_UTILS:TableToStr(buildRankRows()))
                return
            end
            return old(inst, log_type, limit_count, page_index)
        end
        print("[hh_rank] đã gắn tab Chiến lực vào nhật ký thế giới")
    else
        print("[hh_rank] không tìm thấy RPC hh_world_logs, bỏ qua tab Chiến lực")
    end
end

-- Console: HH_RANK_TOP() — bảng xếp hạng chiến lực đã lưu
GLOBAL.rawset(GLOBAL, "HH_RANK_TOP", function()
    local w = GLOBAL.TheWorld
    local world = w ~= nil and w.components ~= nil and w.components.hh_world or nil
    if world == nil or world.hh_save == nil or world.hh_save["power_rank"] == nil then
        print("[chiến lực] chưa có ai lập kỷ lục")
        return
    end
    local rows = {}
    for _, v in pairs(world.hh_save["power_rank"]) do
        if type(v) == "table" and v.cl ~= nil then table.insert(rows, v) end
    end
    table.sort(rows, function(a, b) return (a.cl or 0) > (b.cl or 0) end)
    print("=== BẢNG CHIẾN LỰC ===")
    for i, v in ipairs(rows) do
        print(string.format("%2d. %-16s %10s   (công %s · thủ %s · ngày %s)",
                i, tostring(v.name), fmtCL(v.cl or 0),
                fmt(v.dps or 0), fmt(v.ehp or 0), tostring(v.day or "?")))
    end
end)

-- Console: HH_RANK_RESET() — xoá số liệu để đo lại
GLOBAL.rawset(GLOBAL, "HH_RANK_RESET", function()
    for _, inst in ipairs(findDummies()) do
        inst.hh_damage = {}
        inst.hh_dirty = true
    end
    print("[chiến lực] đã xoá số liệu")
end)

end)  -- hết pcall

if not ok_all then
    print("[hh_rank] LỖI KHI NẠP: " .. tostring(err_all))
else
    print("[hh_rank] nạp xong")
end

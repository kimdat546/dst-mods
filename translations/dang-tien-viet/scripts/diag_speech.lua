-- Chẩn đoán thoại nhân vật: kiểm tra giá trị THẬT trong STRINGS ở hai thời điểm.
--
-- Đặt ra để trả lời: bản dịch không vào, hay có vào rồi bị ghi đè sau đó?
--   • "sau phase"  — ngay sau khi các phase chạy xong trong AddSimPostInit
--   • "trong game" — 5 giây sau khi nhân vật spawn, tức sau khi mọi thứ đã nạp
-- Nếu "sau phase" là tiếng Việt mà "trong game" quay lại tiếng Trung
-- → có kẻ ghi đè, phải áp dụng lại muộn hơn.
--
-- Chỉ nạp khi bật option "Log string thiếu" (DEBUG_MISSING).

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")

-- Vài path đại diện, chọn loại hay gặp khi chơi
local CHECKS = {
    { "XD_CHENPINGAN", "ACTIONFAIL.GENERIC.ITEMMIMIC" },
    { "XD_CHENPINGAN", "ANNOUNCE_HUNGRY" },
    { "XD_CHENPINGAN", "ANNOUNCE_COLD" },
    { "XD_CHENPINGAN", "DESCRIBE.FLINT" },
    { "XD_WANGMAZI",   "ACTIONFAIL.GENERIC.ITEMMIMIC" },
}

local function lookup(char, path)
    local t = STRINGS.CHARACTERS and STRINGS.CHARACTERS[char]
    if t == nil then return nil, "bảng nhân vật KHÔNG TỒN TẠI" end
    for part in path:gmatch("[^%.]+") do
        if type(t) ~= "table" then return nil, "đứt path tại " .. part end
        t = t[part]
        if t == nil then return nil, "không có key " .. part end
    end
    return t
end

_G.dangtien_diag_speech = function(tag)
    print("[DangTienVN][DIAG-SPEECH] ===== " .. tostring(tag) .. " =====")
    for _, c in ipairs(CHECKS) do
        local char, path = c[1], c[2]
        local v, why = lookup(char, path)
        if v == nil then
            print(string.format("[DangTienVN][DIAG-SPEECH]   %s.%s → KHÔNG ĐỌC ĐƯỢC (%s)",
                char, path, tostring(why)))
        elseif type(v) ~= "string" then
            print(string.format("[DangTienVN][DIAG-SPEECH]   %s.%s → không phải chuỗi (%s)",
                char, path, type(v)))
        else
            local lang = (has_chinese and has_chinese(v)) and "**CÒN TIẾNG TRUNG**" or "tiếng Việt OK"
            print(string.format("[DangTienVN][DIAG-SPEECH]   %s.%s → %s | %s",
                char, path, lang, v:sub(1, 60)))
        end
    end
    -- Nhân vật đang chơi là ai, và game tra thoại ở bảng nào
    local p = _G.ThePlayer
    if p ~= nil then
        print(string.format("[DangTienVN][DIAG-SPEECH]   ThePlayer.prefab = %s → tra bảng STRINGS.CHARACTERS.%s (%s)",
            tostring(p.prefab), tostring(p.prefab and p.prefab:upper()),
            (STRINGS.CHARACTERS and STRINGS.CHARACTERS[tostring(p.prefab):upper()]) and "CÓ" or "KHÔNG CÓ"))
    else
        print("[DangTienVN][DIAG-SPEECH]   ThePlayer chưa tồn tại")
    end
end

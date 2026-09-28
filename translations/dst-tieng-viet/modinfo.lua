-- This information tells other players more about the mod
name = "DST Tiếng Việt - Đừng Chết Đói :)"
version = "2026.9"
description = "Việt hóa toàn bộ Don't Starve Together sang tiếng Việt.\n\nDựa trên bản dịch gốc của Khoa.ga, đã soát lại toàn bộ: sửa bản dịch máy sai nghĩa, dịch nội dung mới của game, thống nhất tên vật phẩm và giọng từng nhân vật.\n\nFont tiếng Việt: chữ ơ ư ạ ả ọ ế… cùng nét với font game (tắt được trong cấu hình mod).\n\nCách dùng: bấm Đăng ký, khởi động lại game, vào Mods → Client Mods và bật mod.\n\nCập nhật lần cuối ngày 28/09/2026"
author = "Datgavl"

forumthread = ""
-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10
priority = 9999

-- Can specify a custom icon for this mod!
icon_atlas = "DST_Vietnamese.xml"
icon = "DST_Vietnamese.tex"

server_filter_tags = {"vn", "vietnam", "vietnamese", "viet nam", "datgavl"}

dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
-- ⚠ Mod Workshop MẶC ĐỊNH bật manifest (scripts/mods.lua:566): game chỉ thấy file
--   có trong mod.manifest. Manifest cũ không có scripts/textfix/ngoai_po.lua →
--   "module not found". Mod không cần manifest nên tắt hẳn, và không upload nó.
forcemanifest = false

configuration_options = {
    {
        name = "FONT_VIET",
        label = "Font tiếng Việt",
        hover = "Dùng font game đã thêm đủ chữ tiếng Việt (ơ ư ạ ả ọ ế…) cho nét chữ đồng bộ. Tắt nếu chữ hiển thị lỗi.",
        options = {
            { description = "Bật", data = true },
            { description = "Tắt", data = false },
        },
        default = true,
    },
}

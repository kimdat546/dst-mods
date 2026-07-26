-- theme_textfix.lua
-- Textfix cho Myth Words Theme (神话书说) — mod encrypted, phải dùng textfix

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local textfix = rawget(_G, "myth_viet_textfix")
local word_fix = rawget(_G, "myth_viet_word_fix")
if not textfix or not word_fix then return end

-- =================================================================
-- Crafting tab categories (exact match — tab names)
-- =================================================================
textfix["人物"] = "Nhân Vật"
textfix["公告"] = "Thông Báo"
textfix["地形"] = "Địa Hình"
textfix["妖怪"] = "Yêu Quái"
textfix["炼制"] = "Luyện Chế"
textfix["神仙"] = "Thần Tiên"
textfix["神话"] = "Thần Thoại"

-- =================================================================
-- Item names
-- =================================================================
textfix["年兽面具"] = "Mặt Nạ Niên Thú"
textfix["月饼盒"] = "Hộp Bánh Trung Thu"
textfix["爆竹"] = "Pháo"
textfix["人参果地毯"] = "Thảm Nhân Sâm Quả"
textfix["缠根青苔绿"] = "Rêu Xanh Quấn Rễ"

-- =================================================================
-- NPC / character names — cần word_fix để xử lý khi xuất hiện trong "Đi tới X"
-- =================================================================
word_fix["青竹"] = "Thanh Trúc"
word_fix["熊猫村民"] = "Dân Làng Gấu Trúc"

-- Cũng add vào textfix để exact match
textfix["青竹"] = "Thanh Trúc"
textfix["熊猫村民"] = "Dân Làng Gấu Trúc"

-- =================================================================
-- Skills / buffs / speech
-- =================================================================
textfix["火眼金睛"] = "Hỏa Nhãn Kim Tinh"
textfix["以柔克刚"] = "Dĩ Nhu Khắc Cương"
textfix["月儿弯弯，满载欣欢"] = "Trăng cong cong, đầy niềm vui"

-- =================================================================
-- Recipe descriptions
-- =================================================================
textfix["使用天书制造一个原型！"] = "Dùng Thiên Thư để tạo nguyên mẫu!"
textfix["靠近人参果树制造一个原型"] = "Đứng gần cây Nhân Sâm Quả để tạo nguyên mẫu"
textfix["靠近人参果树制造一个原型！"] = "Đứng gần cây Nhân Sâm Quả để tạo nguyên mẫu!"

-- =================================================================
-- NPC dialogue (熊猫村民 / Dân Làng Gấu Trúc)
-- =================================================================
textfix["流离失所的熊猫村民在重建他们的家园"] = "Dân làng gấu trúc lưu lạc đang tái thiết quê hương"
textfix["你能帮我修缮一下店铺吗"] = "Bạn có thể giúp tôi sửa chữa cửa hàng không?"
textfix["若是能帮我们重建家园那实在是万分感谢"] = "Nếu bạn có thể giúp tái thiết quê hương chúng tôi thì rất cảm ơn"
textfix["村庄重建后欢迎你前来做客"] = "Sau khi làng được tái thiết, hoan nghênh bạn ghé thăm"
textfix["你能帮我寻一些建材吗"] = "Bạn có thể giúp tôi tìm vật liệu xây dựng không?"
textfix["村庄被怪物侵袭后很久都没有来客了"] = "Làng bị quái vật xâm lược đã lâu không có khách ghé"

-- =================================================================
-- Misc
-- =================================================================
textfix["！"] = "!"  -- lone exclamation
-- Jieyun announcement (standalone line)
textfix["凡人仰首望星河，仙家足下踏青云。"] = "Phàm nhân ngắm ngân hà, tiên gia đạp thanh vân."

print("[Myth-Viet] Theme textfix loaded.")

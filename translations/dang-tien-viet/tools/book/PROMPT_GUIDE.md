# Viết prompt Gemini cho một trang sách 【登仙】

Mỗi trang sách (`images/xd_info_*.tex`, 1 file = 2 trang mở đôi) được dịch bằng
Gemini web: user tải ảnh xuất + dán prompt, Gemini thay chữ; sau đó
`gemini_import.py` căn khớp và ghép vào mod. Prompt quyết định chất lượng: Gemini
chỉ VẼ chữ, KHÔNG được tự dịch — nên prompt phải chứa sẵn bản dịch hoàn chỉnh.

## Đầu vào
- Ảnh trang: `build/book/export/<trang>.png` (2048x1300, nền sách + chữ Hán).
  Đọc bằng công cụ xem ảnh; ảnh lớn thì cắt/phóng từng vùng để đọc chữ nhỏ cho
  chính xác (python3 + PIL có sẵn; chạy python từ thư mục khác, ví dụ /tmp).
- Thuật ngữ: `glossary.tsv` (CN<TAB>VN, ~590 tên vật phẩm/đan/boss/cảnh giới đã
  dùng trong game). Tên có trong bảng thì PHẢI dùng đúng bản dịch đó.
  Không có → Hán-Việt cho tên riêng (pháp bảo, đan, boss, công pháp), tiếng
  Việt thường cho vật thường; tên sinh vật/boss DST gốc giữ tên tiếng Anh
  (Beefalo, Deerclops, Bearger, Antlion, Klaus...).
- Mẫu đã duyệt: `prompts/xd_info_ys_21.txt` — theo ĐÚNG khung này.

## Đầu ra (mỗi trang)
1. `prompts/<trang>.txt` — prompt hoàn chỉnh, tiếng Anh cho phần hướng dẫn,
   tiếng Việt cho nội dung chữ. Giữ nguyên khối STRICT RULES của mẫu.
2. `notes/<trang>.md` — bảng soát: mỗi ô chữ một dòng `| vị trí | CN gốc | VN |`,
   cùng ghi chú chỗ không chắc (chữ mờ, nghĩa mơ hồ).

## Quy tắc nội dung
- Liệt kê MỌI ô chữ theo thứ tự trên → dưới, trái → phải, mỗi ô gắn với một
  mốc dễ nhận (icon nào, khung nào, cạnh hình gì) để Gemini đặt đúng chỗ.
- Chữ dọc (viết theo cột) → đổi thành dòng ngang trong cùng vùng, ghi rõ trong prompt.
- Nhãn trước dấu hai chấm có màu (tên vật phẩm/boss): ghi [dark red] hoặc màu gốc
  nếu chữ gốc có màu riêng (tím, đỏ...). Không có nhãn thì không cần màu.
- Dịch đủ ý, không bỏ câu; ngắn gọn vì ô chữ chật (chữ Việt dài hơn Hán ~1.7x).
  Số liệu, ký hiệu (*3, %, +) giữ nguyên.
- Thuật ngữ chung: tinh thần (理智), no (饱食度), máu (血量/生命), hồi chiêu (冷却),
  công thức (制作公式/配方), bảng chế tạo (制作栏), tu vi, cảnh giới, linh lực.
- Số trang, chữ trên con dấu/hoa văn trang trí (nếu chỉ là hoạ tiết) → giữ nguyên
  và nói rõ trong prompt là không đổi.
- Chữ Hán không đọc chắc được → vẫn dịch theo ngữ cảnh tốt nhất, ghi vào notes.

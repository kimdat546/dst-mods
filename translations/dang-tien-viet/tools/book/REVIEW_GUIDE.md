# Soát & ghép ảnh trang sách Gemini trả về

Đầu vào mỗi trang <trang>:
- Ảnh Gemini: ~/Desktop/dang-tien-book/output/<trang>.png
- Ảnh gốc (chữ Hán): ~/Desktop/dang-tien-book/input/<trang>.png
- Prompt (nội dung chữ ĐÚNG): tools/book/prompts/<trang>.txt ; bảng soát: tools/book/notes/<trang>.md
- Tên đồ phải khớp game: tools/book/glossary.tsv

## Quy trình
1. Ghép thử: `python3 tools/book/gemini_import.py <trang> ~/Desktop/dang-tien-book/output/<trang>.png`
   (chạy từ translations/dang-tien-viet). Ra build/book/<trang>_gemini_check.png (2048x1300).
2. So ảnh ghép với ảnh gốc và prompt, cắt từng vùng ~600px rồi đọc kỹ (PIL, chạy python từ /tmp):
   - Mỗi ô chữ trong prompt có mặt, đủ câu, đúng chữ, đúng dấu, không lặp/cụt chữ, không còn chữ Hán.
   - Mỗi đoạn nằm cạnh đúng icon như bản gốc; không mất icon/hàng icon; không có icon/khung/mũi tên/
     nút điều hướng Gemini tự vẽ thêm; icon không bị vẽ thành vật khác hẳn.
   - Ảnh ghép không lệch so với khung sách (không thấy hai lớp chồng nhau ở mép trang).
3. Lỗi nhỏ → sửa bằng tools/book/fixes/<trang>.json (đọc docstring apply_fixes/draw_line trong
   gemini_import.py). Các thao tác:
   - paper: xoá thứ Gemini vẽ thêm; orig_art: dán lại icon gốc tại chỗ; move_art: dời icon gốc;
   - text: viết lại MỘT dòng (box = vùng viết, band = dải y mà mảng chữ cũ có tâm nằm trong sẽ bị xoá,
     keep = các box trả lại mực bị xoá oan, vd dấu thanh của dòng kề);
   - block: xoá cả vùng (erase) rồi viết lại nhiều dòng (lines, line_h, pitch). Dùng block khi sửa
     dòng lẻ để lại vụn chữ / ăn mất dấu dòng bên cạnh.
   - span in đậm/màu: ["chữ", "#màu"|null, "b"].
   Toạ độ theo ảnh ghép 2048x1300. Vẽ lưới toạ độ lên vùng cắt để đo; sau mỗi lần sửa chạy lại bước 1
   và XEM LẠI ảnh tới khi sạch (không vụn chữ cũ, không mất dấu dòng bên cạnh, cỡ chữ hợp lý).
4. Lỗi lớn (mất cả đoạn/hàng icon, bố cục lệch hẳn, sai nhiều dòng) → KHÔNG vá; đánh dấu cần chạy
   lại Gemini và thêm vào prompt <trang>.txt một câu dặn cụ thể đúng lỗi đó.

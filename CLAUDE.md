# CLAUDE.md — DST Mods Workspace

Đây là workspace tập trung **tất cả mod Don't Starve Together (DST)** của kimdat546. Khi làm việc ở đây:

1. **Đọc `README.md`** ở cùng thư mục trước — nó là index đầy đủ (mod nào ở đâu, làm bằng cách gì, upload ra sao).
2. Mỗi mod là một project độc lập trong `translations/`, `originals/`, hoặc `_infra/`. Nhiều mod có `README.md`/`CLAUDE.md`/`docs/` riêng — đọc của mod đang làm.

## Quy ước nhanh
- `translations/` = mod dịch tiếng Việt (phủ text). `originals/` = mod tự làm. `_sources/` = nguồn tham khảo (không phải mod của mình, đừng sửa để upload). `_infra/` = server, không phải mod. `docs/dst-knowledge/` = kiến thức DST dùng chung.
- **Git:** cả workspace là MỘT monorepo → `github.com/kimdat546/dst-mods` (public). Ngoại lệ duy nhất: `_infra/dst-server-docker` là repo RIÊNG (nó dùng branch làm cấu hình từng world, gộp vào sẽ hỏng). Chỉ commit/push khi user yêu cầu; nếu đang ở nhánh mặc định thì tạo nhánh trước.
- **Kiến thức DST API / pitfalls / hot-reload / kiến trúc 登仙:** `docs/dst-knowledge/analysis/`.
- **Skill dựng nội dung DST** (nhân vật, vật phẩm, công trình, đan dược, mob AI): `.claude/skills/`.
- **Hai pattern dịch:** (a) mod bytecode → hook runtime, `priority=-10000`, ghi đè `STRINGS.*` trong `AddSimPostInit` + hook `TextWidget.SetString`; (b) game gốc → file `.po` qua `LoadPOFile()` + textfix cho text động.
- **Upload Workshop:** rsync sang thư mục build sạch → tăng version → Don't Starve Mod Tools → Upload Existing Mod → nhập Workshop ID.

## Dọn tài nguyên máy — BẮT BUỘC

Máy làm việc là **MacBook của user**, không phải máy chủ. Chạy xong bất cứ thứ
gì nặng thì **dừng ngay trong cùng lượt đó**, đừng đợi được nhắc:

- Đọc xong kết quả `chay_tu_kiem.sh` → `docker stop dst-ailang-test` ngay.
  **`stop`, KHÔNG `rm`** — giữ nguyên container và data.
- Dừng mọi việc nền còn treo, đừng để vòng `until ... sleep` chạy mãi.
- Trước khi kết thúc lượt: `docker ps` phải trống.
- Còn cần container cho lượt sau thì **nói rõ** là đang để chạy và vì sao.

Đã xảy ra thật (2026-09-15): container DST test chạy nền nhiều tiếng sau khi bộ
kiểm xong — nó là server game đầy đủ, ăn CPU liên tục, máy user nóng lên. Đây là
lần lặp lại thứ hai của cùng một lỗi.

## Lịch sử
Gom về đây 2026-07-26 từ các folder rải trên Desktop. Không có session Claude cũ nào được lưu; context được tái dựng từ file dự án.

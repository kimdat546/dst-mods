# CLAUDE.md — DST Tiếng Việt

Mod dịch **toàn bộ game Don't Starve Together** sang tiếng Việt. Workshop ID `3683660917`.
Mod client (`client_only_mod = true`).

## Kiến trúc — hai lớp dịch

1. **`vietnamese.po`** (~87.700 khoá, khoá = `msgctxt` kiểu `STRINGS.NAMES.AXE`) — nạp bằng
   `LoadPOFile()` trong `scripts/main.lua`, rồi `TranslateStringTable(STRINGS)`.
2. **`scripts/textfix/`** — móc `TextWidget.SetString`, gặp chuỗi TIẾNG ANH có trong bảng thì
   thay. Bắt được chữ không đi qua `STRINGS` của máy mình, quan trọng nhất là **thoại do server
   gửi về** (world có hang / server riêng không nạp mod client).
   - `character_speech.lua` — **SINH TỰ ĐỘNG từ `.po`** bằng `tools/tao_textfix.py`. Đừng sửa tay.
   - `ngoai_po.lua` — câu KHÔNG có trong `strings.pot` (câu ghép động…). Sửa tay ở đây.
   - `ui_gamesetup.lua` — chữ màn hình tạo world, sửa tay.

## Quy trình khi game cập nhật

```bash
# 1. lấy strings.pot mới (game_source/ không version, 234 MB)
unzip -p ~/"Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip" \
    scripts/languages/strings.pot > game_source/strings.pot
# (chinese_s.po cùng chỗ — tham khảo khi tiếng Anh mơ hồ)

python3 tools/sync_check.py                 # báo: mới / gốc đổi / game bỏ / chưa dịch / placeholder lệch
python3 tools/xuat_viec.py tu_dien          # viec/tu_dien.tsv — bảng tên chuẩn (NAMES en→vi)
python3 tools/xuat_viec.py dich 500         # chia việc dịch thành lô viec/dich_*.tsv
#    → mỗi lô dịch theo viec/HUONG_DAN.md, kết quả viec/<lô>.ra.tsv (khoa<TAB>vi)
python3 tools/ap_viec.py viec/dich_*.ra.tsv # áp + đồng bộ khoá với game + kiểm placeholder
./tools/make_upload.sh 2026.10              # sinh textfix, kiểm Lua, dựng upload/dst-tieng-viet
```

`xuat_viec.py` còn các chế độ soát: `soat_names`, `soat_khac` (RECIPE_DESC+ACTIONS),
`soat_mo_ta` (SCRAPBOOK+SKILLTREE), `soat_skin`, `soat_skin_mo_ta`. `viec/` bị gitignore;
`viec/HUONG_DAN.md` là quy tắc dịch (giọng nhân vật, bảng chữ bộ sưu tập trang phục…) —
bản chính giữ ở `tools/HUONG_DAN.md`.

## Upload

`./tools/make_upload.sh <version>` → Don't Starve Mod Tools → Upload Existing Mod →
`upload/dst-tieng-viet` → Workshop ID `3683660917`.

⚠ **KHÔNG upload `mod.manifest`**. Mod Workshop mặc định bật manifest (`scripts/mods.lua:566`),
game chỉ thấy file có trong manifest; manifest cũ thiếu file mới → `module not found`.
`modinfo.lua` đặt `forcemanifest = false`.

## Bẫy đã gặp

- **Bộ đọc .po phải chịu được `"` không thoát** — bản cũ có 55 dòng như vậy. Bộ đọc CỦA GAME
  (`scripts/translator.lua`, mẫu tham lam `"(.*)"`) vẫn đọc đúng, nhưng sai chuẩn .po với công cụ
  khác. `tools/po.py` đọc được và khi ghi lại thì thoát `\"` — game giải lại đúng (đã chạy thử
  translator.lua của game trên file: đọc đủ 87.652 mục có nội dung).
- **Kiểm placeholder: đừng coi `% s` là `%s`** — "25% sát thương" từng bị báo lệch nhầm.
- **textfix 66k dòng vượt 65.536 hằng số/hàm của LuaJIT** → `tao_textfix.py` chia thành hàm con
  15k dòng, nối bằng `end)();` (thiếu `;` là lỗi "ambiguous syntax").
- **Ghi chú người dịch lọt vào game** ("(Chơi chữ với…)") — `ap_viec.py` từ chối dòng có ghi chú.
- **Chất lượng nền:** phần lớn bản cũ là dịch máy. Đã soát NAMES, RECIPE_DESC, ACTIONS,
  SCRAPBOOK, SKILLTREE, SKIN_NAMES, SKIN_DESCRIPTIONS (09/2026). **Chưa soát ~62.000 câu thoại
  nhân vật** (`STRINGS.CHARACTERS.*`) — mẫu 40 câu có ~15% sai hẳn nghĩa.
- **Font:** font của game chỉ có ~326 glyph — có ă â đ à á nhưng THIẾU ơ ư và mọi chữ dấu riêng
  (ạ ả ọ ế ờ ự…) → game lấy từ font dự phòng, lệch nét (người chơi phản ánh trên Workshop).
  Cách chữa: `tools/tao_font.py` GHÉP 94–101 chữ Việt từ chính glyph của từng font (á−a = dấu sắc,
  "." = chấm dưới, nửa trên "?" = dấu hỏi, "," xoay 180° = râu) cho 17 font → `fonts/vi_*.zip`;
  `scripts/font_vi.lua` nạp trong AddSimPostInit dưới alias `vi_*` rồi mới trỏ TALKINGFONT, UIFONT…
  sang — nạp lỗi thì giữ font gốc (trỏ sang alias chưa nạp = chữ trống). Tắt được bằng tuỳ chọn
  "Font tiếng Việt". ⚠ `fonts/` sinh từ font CỦA GAME (dữ liệu Klei) → gitignore, không lên repo
  public; `make_upload.sh` sinh lại. Menu chính vẫn dùng font gốc (chỉ đổi khi vào world).

## Không upload

`game_source/`, `tools/`, `sync_reports/`, `viec/`, `CLAUDE.md`, `README.md`, các file
`phase*_entries.txt`, `scanner.txt`, `new_strings_*.po` (công cụ/dữ liệu làm việc cũ).

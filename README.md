# DST Mods — Workspace của kimdat546

Nơi tập trung **tất cả mod Don't Starve Together (DST)** mình làm: mod dịch tiếng Việt và mod tự phát triển. Gom về đây ngày **2026-07-26** từ nhiều folder rải rác trên Desktop.

> Đọc file này để nắm nhanh mỗi mod là gì, đang ở đâu, làm bằng cách nào và upload ra sao. Chi tiết kỹ thuật nằm trong README/CLAUDE.md/docs của từng mod.

## Git / GitHub

**Monorepo:** <https://github.com/kimdat546/dst-mods> (public) — chứa toàn bộ 5 mod.
Lịch sử 116 commit của `pham-nhan-tu-tien` và của `dang-tien-viet` được bảo toàn qua `git subtree`.

**Repo riêng:** `_infra/dst-server-docker` KHÔNG gộp vào đây, vì nó dùng *branch làm cấu hình từng thế giới*
(`dang-tien`, `myth-words`, `pntt-dev`, `speedrun`…). Gộp vào thì `git checkout dang-tien` sẽ đổi luôn code cả 5 mod.

**Không version** (xem `.gitignore`): `_sources/` (mod của tác giả khác), `_archive/`,
`translations/dst-tieng-viet/game_source/` (234MB source Klei — giải nén lại từ `scripts.zip`),
các file dump debug.

Repo cũ `github.com/kimdat546/dst-tieng-viet` giữ lại làm lưu trữ; công việc mới làm ở monorepo.

---

## Bản đồ thư mục

```
~/code/dst-mods/
├── README.md            ← file này (index tất cả)
├── CLAUDE.md            ← context cho Claude Code khi mở từ đây
│
├── translations/        ← mod DỊCH (phủ text lên game/mod khác)
│   ├── dst-tieng-viet/      DST Tiếng Việt (dịch game gốc)      [git]
│   ├── dang-tien-viet/      Đăng Tiên VN (dịch mod 登仙)          [git]
│   └── myth-words-viet/     Myth Words VN
│
├── originals/           ← mod TỰ LÀM (custom content)
│   ├── pham-nhan-tu-tien/   Phàm Nhân Tu Tiên [Alpha] — flagship [git]
│   └── tu-tien-lite/        Tu Tiên Lite (Đăng Tiên gọn nhẹ)
│
├── _sources/            ← nguồn tham khảo, KHÔNG phải mod của mình
│   ├── dengxian-3235319974/ mod gốc 【登仙】 v18.1 (nguồn để dịch/nghiên cứu)
│   ├── dang-tien-wiki.pdf    PDF wiki/cẩm nang 登仙 (nguồn glossary)
│   └── neverland_mod[.zip]   mod ngoài "Neverland" (của Neverland Team)
│
├── _archive/            ← bản trùng / build cũ (xóa lúc nào cũng được)
│   ├── dst-viet-modv3-dupe/     .po y hệt dst-tieng-viet, chỉ khác version
│   ├── dang-tien-viet-upload/   build sạch để upload (dang-tien)
│   ├── pham-nhan-tu-tien-upload/ build sạch để upload (pham-nhan)
│   └── myth-words-viet-v1.0/    bản Myth Words cũ (v1.0)
│
└── _infra/              ← hạ tầng, KHÔNG phải mod
    └── dst-server-docker/   server DST chạy Docker + bot + CLI  [git]
```

---

## Danh mục mod

| Mod | Thư mục | Loại | Version | Tác giả | Workshop ID |
|---|---|---|---|---|---|
| DST Tiếng Việt | `translations/dst-tieng-viet` | Dịch game gốc | 2026.5 (git) | Datgavl | **3683660917** |
| Đăng Tiên VN | `translations/dang-tien-viet` | Dịch mod 登仙 | 1.1.0 (git) / **1.0.0 trên Workshop** | kimdat546 | **3719981130** (mod nguồn: 3235319974) |
| Myth Words VN | `translations/myth-words-viet` | Dịch mod | 1.2 | Datgavl | *cần điền* |
| Phàm Nhân Tu Tiên | `originals/pham-nhan-tu-tien` | Tự làm (alpha) | 0.2.0-remake-m1 | kimdat546 | *chưa publish?* |
| Tu Tiên Lite | `originals/tu-tien-lite` | Tự làm | 1.0.0 | kimdat546 + Claude | *cần điền* |
| Food Buff HUD | `originals/food-buff-hud` | Tự làm | 0.1.0 | kimdat546 | *chưa publish* |

> **TODO:** còn thiếu Workshop ID của Myth Words VN và Tu Tiên Lite.

---

## Chi tiết từng mod

### 1. DST Tiếng Việt — `translations/dst-tieng-viet/`
Dịch **toàn bộ game DST gốc** sang tiếng Việt. Bản trưởng thành nhất, đã ra v1.0+ và có quy trình vận hành đầy đủ.
- **Kỹ thuật (2 lớp):**
  1. `vietnamese.po` (~85.000 string, 17MB) — nạp qua API sẵn có `LoadPOFile()`, phủ text tĩnh lúc khởi động.
  2. `scripts/textfix/` — hook `TextWidget.SetString` phủ text động (skill tree, speech, UI) mà `.po` không tới.
- **Công cụ:** `tools/sync_check.py` (phát hiện string mới khi game update), `tools/quality_check.py` (kiểm lỗi format `%s`, `{winner}`). Báo cáo trong `sync_reports/`.
- **Git:** `git@github.com:kimdat546/dst-tieng-viet.git` (branch `main`). Có thay đổi chưa commit.
- **Đọc thêm:** `CLAUDE.md` + `README.md` trong folder (quy trình sync + upload).
- ⚠️ Bản upload cuối là **v2026.7** (xem `_archive/dst-viet-modv3-dupe`), nhưng git repo mới ở **v2026.5** — nội dung `.po` giống hệt, chỉ lệch số version.

### 2. Đăng Tiên VN — `translations/dang-tien-viet/`
Dịch mod tu tiên tiếng Trung **【登仙】** (nguồn Workshop `3235319974`).

- **Mức mã hóa mod gốc:** 569/584 file `.lua` bị mã hóa (97,4%) bằng định dạng riêng (không phải bytecode Lua chuẩn).
  Nhưng **15 file đọc được chính là toàn bộ bề mặt dịch**: `scripts/main/strings.lua` + 10 file `speech_xd_*.lua`.
  → Trích 100% text cần dịch bằng script tĩnh, không cần dump runtime.
- **Kỹ thuật:** không sửa được file gốc → hook runtime. `priority = -10000` để load **sau** mod gốc.
  2 lớp: hook `TextWidget/Text.SetString` (bắt lúc render) + ghi đè `STRINGS.*` sau `AddSimPostInit`.
- **Độ phủ (đo 2026-07-26 với mod gốc v19.0):** `strings.lua` có 1022 chuỗi Hán, các phase phủ 1273 path,
  **còn thiếu 109** — trong đó 69 là chuỗi mới của v19.0.
- **⚠ Mod gốc đã lên v19.0** (bản trong `_sources` là v18.1): thêm nhân vật **陈平安 Trần Bình An**
  (44 file anim, ~30 prefab, `speech_xd_chenpingan.lua` 5282 dòng — lớn nhất). Không chuỗi nào bị xóa
  nên bản dịch cũ không hỏng, chỉ thiếu phần mới.
- **Còn phải làm:** thoại **9 nhân vật** (~28.000 dòng Hán) — Trần Bình An, Hàn Thiên Tôn, Long Thái Tử,
  Tinh Vệ, Tô Đát Kỷ, Ngộ Không, Lạc Thần, Vân Tiêu, Thi Cơ. TSV đã trích sẵn trong `translation_pipeline/`.
- **⚠ Khi chơi thử bản local:** bạn đang sub chính bản Workshop của mình (`3719981130`, v1.0.0),
  trùng tên và trùng `priority = -10000` với bản đang phát triển → trong danh sách Client Mods sẽ có
  hai dòng không phân biệt được. `tools/sync_local.sh` tự gắn tiền tố `[LOCAL]` vào tên bản cài để
  khỏi bật nhầm; nhớ **tắt bản Workshop** khi test.
- **Chữ nằm trong ảnh** (không dịch được bằng STRINGS): 40 trang Tu Tiên Mật Quyển `images/xd_info_*.tex`,
  10 ảnh tên nhân vật `images/names_xd_*.tex`, và nhãn UI nướng trong atlas `images/xd_ui.tex`.
  **Lưu ý quan trọng:** `xd_info_0.tex` là **khung sách RỖNG** — nên không cần vẽ lại 40 trang chữ,
  chỉ cần ẩn ảnh trang rồi vẽ chữ Việt bằng Text widget đè lên khung có sẵn.

### 3. Myth Words VN — `translations/myth-words-viet/`
Dịch mod "Myth Words" sang tiếng Việt. v1.2 (bản v1.0 cũ ở `_archive/myth-words-viet-v1.0`). Kỹ thuật giống Đăng Tiên (phase strings + textfix + fallback). Không có git.

### 4. Phàm Nhân Tu Tiên [Alpha] — `originals/pham-nhan-tu-tien/` ⭐
**Mod tự làm lớn nhất** — custom content tu tiên từ đầu (1.3GB gồm anim/art/portraits). Đang phát triển (alpha).
- **Git:** branch `main`, commit chi tiết (items, atlas icon, prefab, placer…).
- **Kho tài liệu (rất giá trị, tái dùng được):** `docs/analysis/` — phân tích kiến trúc 登仙, `dst-api-foundation.md`, `dst-hot-reload.md`, glossary gameplay; `docs/superpowers/` — plans + specs; `docs/ai-art-prompts.md`, `docs/icon-assets-reference.md`.
- **Build upload:** `tools/make_swap_build.md`. Bản build sạch cũ ở `_archive/pham-nhan-tu-tien-upload`.

### 6. Food Buff HUD — `originals/food-buff-hud/`
Hiện buff từ thức ăn đang có tác dụng + đếm ngược chính xác (món Warly, món nêm gia vị).
- **Vì sao chạy ở server:** `debuffable`/`debuff`/`timer` không có replica → client không đọc được thời gian còn lại. Mod tính ở server rồi gửi RPC xuống. Các mod buff-timer chỉ chạy client buộc phải đoán theo `TUNING`, nên sai khi buff được gia hạn hoặc khi vào server giữa lúc buff đang chạy.
- **Chống mục ruỗng:** duyệt `debuffable.debuffs` + đọc timer `"buffover"` → tự phủ mọi buff dùng `MakeBuff`, kể cả món Klei thêm sau. Không hardcode danh sách như hai mod "Buff Timer" trên Workshop (58–80 entry, tác giả bỏ từ 2024-03).
- **Đóng gói:** `all_clients_require_mod = true` (client tự tải khi join) + `version_compatible` để client cũ/mới đều vào được.
- **Đọc thêm:** `README.md` trong folder.

### 5. Tu Tiên Lite — `originals/tu-tien-lite/`
Bản làm lại **gọn nhẹ** của 登仙 (do kimdat546 + Claude). Chỉ scripts, nhỏ. v1.0.0.

---

## Kiến thức DST modding dùng chung (tái sử dụng cho mọi mod)

- **Dịch mod bị mã hóa/bytecode:** không sửa được source → hook runtime. Đặt `priority = -10000` để load sau mod gốc, ghi đè `STRINGS.*` trong `AddSimPostInit`, hook `TextWidget.SetString` để bắt text render-time.
- **Dịch game gốc:** ưu tiên file `.po` qua `LoadPOFile()` cho string tĩnh; chỉ dùng textfix hook cho text động lọt lưới.
- **DST API pitfalls / hot-reload / kiến trúc:** xem `originals/pham-nhan-tu-tien/docs/analysis/`.
- **Quy trình upload Workshop:**
  1. `rsync` các file cần thiết sang thư mục build sạch (chỉ file upload, bỏ tools/docs/git).
  2. Tăng `version` + cập nhật ngày trong `description` của `modinfo.lua`.
  3. Steam → **Don't Starve Mod Tools** → *Upload Existing Mod* → chọn thư mục build → nhập Workshop ID → Upload.
- **Lấy strings.pot mới sau khi game update:** giải nén từ `.../Don't Starve Together/.../data/databundles/scripts.zip`.

## Ghi chú dọn dẹp còn lại
- Đường dẫn upload trong vài `CLAUDE.md`/`README.md` cũ còn trỏ tới `~/Desktop/dst-viet-mod/` (không còn tồn tại) — cập nhật khi cần build.
- `_archive/` và `_sources/neverland_*` có thể xóa để tiết kiệm đĩa; `_sources/dengxian-3235319974` (376MB) giữ lại vì là nguồn dịch/nghiên cứu.

# Functional Medal Việt hoá — 能力勋章

Bản dịch tiếng Việt cho mod [**Functional Medal / 能力勋章**](https://steamcommunity.com/sharedfiles/filedetails/?id=1909182187)
của tác giả **恒子** — mod chủ đề "trưởng thành": huân chương trao năng lực,
kèm hệ nhiệm vụ/khảo thí, gia vị, cây trồng, tượng, đạn ná.

Trang chủ mod: <https://www.guanziheng.com/>

## Vì sao là mod CLIENT RIÊNG, không fork, không thêm thư mục ngôn ngữ

Mod gốc **hardcode đúng hai nhánh ngôn ngữ** (`modmain.lua:213`):

```lua
if TUNING.MEDAL_LANGUAGE == "ch" then require "lang/medal_strings_ch"
else                                 require "lang/medal_strings_eng" end
```

Không có móc mở rộng — khác Montfluv (mod đó nạp theo **tên thư mục** nên chỉ
cần thêm `translation_vi/`). Ở đây muốn thêm "vi" thì phải fork cả mod.

Nên cách sạch nhất là **ghi đè `STRINGS` sau khi mod gốc nạp xong**:

| | |
|---|---|
| Không đụng file mod gốc | Steam cập nhật mod gốc cũng không mất bản dịch |
| Mod client | Server không cần bật theo |
| Không cần fork | Không bắt người chơi tải lại cả mod |

## Server không chơi Functional Medal thì có lỗi không?

**Không, và không nhờ chốt chặn nào cả.** `STRINGS` là bảng toàn cục của game;
gán `STRINGS.NAMES.COOK_CERTIFICATE` khi mod gốc vắng mặt chỉ tạo ra một khoá
**không ai đọc tới**. An toàn tự nhiên — không cần `if mod tồn tại then`.

## Thứ tự nạp — chỗ dễ sai nhất

`scripts/mods.lua:557` sắp mod bằng `apriority > bpriority` cho `table.sort`,
tức **giảm dần: số LỚN nạp TRƯỚC, số NHỎ nạp SAU**.

- Functional Medal: `priority = -10001`
- Mod này: `priority = -10002` → nạp **sau** → ghi đè được

Nhưng chuỗi vẫn áp trong `AddSimPostInit` (chạy sau **mọi** modmain), nên đúng
kể cả khi tác giả mod gốc đổi `priority` ở bản sau.

## Quy trình

```bash
./tools/extract_strings.py     # rút chuỗi từ mod gốc + cơ chế từ wiki
# dịch trong strings_source.json (trường "vi")
./tools/build.py               # dựng build/functional-medal-vi/
./tools/sync_local.sh          # cài vào game để thử
./tools/sync_local.sh --clean  # gỡ
```

`extract_strings.py` **giữ lại bản dịch cũ** khi chạy lại — mod gốc cập nhật
thì không mất công dịch.

## Nguồn đối chiếu

`wiki/medal_item_data.js` tải từ guanziheng.com — dữ liệu có cấu trúc: tên gốc
tiếng Trung, **mã prefab** (`item_code`, khớp thẳng với khoá `STRINGS`), cơ chế,
nguyên liệu, bàn chế, độ bền. 218 vật phẩm, khớp 213 khoá của mod.

Dùng để **hiểu cơ chế mà dịch cho đúng**, không phải để chép lại nội dung wiki.

## Gộp vào "DST Tiếng Việt" sau này

`scripts/medal_vi_strings.lua` cố ý là **file dữ liệu thuần** — không logic,
không phụ thuộc. Muốn gộp thì chỉ cần `require` nó trong `AddSimPostInit` của
mod kia, không phải làm lại gì.

Hiện để riêng vì: mod gốc vá thường xuyên (1.6.8.1) nên gộp vào là mỗi lần nó
đổi chuỗi lại phải phát hành lại DST Tiếng Việt cho **toàn bộ** người dùng mod
đó; và DST Tiếng Việt dịch **game gốc** bằng `.po` + `LoadPOFile` — cơ chế khác
hẳn.

## ⚠ Trước khi đăng Workshop

**Cần hỏi ý tác giả 恒子.** Mod này không có sẵn thư mục dịch cộng đồng như
Montfluv (`translation_es/` cho thấy tác giả đó nhận đóng góp), nên không suy ra
được là họ đồng ý. Trang chủ có mục "作者留言" và nhóm QQ `967226714`.

Dùng riêng trong nhóm thì không vướng gì.

## Tiến độ

Xem `tools/build.py` in ra khi dựng. Bảng thuật ngữ bám theo bản dịch game gốc
trong `translations/dst-tieng-viet/vietnamese.po` (Đá cẩm thạch, Nhân Sâm,
Củ Thịt, Ong Chúa, Ngọc Lam, Đạn, Bẫy, Ba Lô, Rương…).

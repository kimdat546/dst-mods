# Mod dịch: bản CLIENT + bản SERVER

Làm lần đầu cho `translations/functional-medal-viet` (2026-09-27). Dùng lại cho
mọi mod dịch kiểu "phủ `STRINGS.*` từ mod client".

## Vấn đề

Mod dịch client (`client_only_mod = true`) chỉ chạy **trong tiến trình game của
người chơi**. Chữ nào **server ghép rồi gửi về** thì vẫn là ngôn ngữ của server:

- câu nhân vật nói do mod gọi trên server (`talker:Say(STRINGS.X .. y)`,
  kiểu `MedalSay`) — gồm cả phần ghép động như đáp án đề thi
- thông tin thêm khi rê chuột mà mod lấy qua RPC (FM: `Showinfo` → `getMedalInfo`)
- thông báo toàn server (announce)

Chữ do **máy người chơi tự vẽ** thì bản client lo được: tên đồ, mô tả công
thức, giao diện, màn hình đề thi.

## ⚠ Host trên chính máy mình CŨNG dính, nếu world có hang

| World | Tiến trình | Mod client có tác dụng với chữ server? |
|---|---|---|
| Host **không hang** | 1 tiến trình: vừa server vừa client, chung `STRINGS` | **Có** |
| Host **có hang** | Game tự bật **2 server dedicated ẩn** (Master + Caves); cửa sổ game chỉ là client | **Không** |
| Server riêng (ThinkPad, VPS, docker) | dedicated | **Không** |

Nhận ra bằng log: `Cluster_N/Master/server_log.txt` có
`Beginning normal load sequence for dedicated server` và **không** có dòng log
của mod dịch, trong khi `client_log.txt` có.

→ Thử bản dịch client thì dùng **world không hang** mới thấy đủ. Đừng đổ cho
bản dịch thiếu khi test ở world có hang.

## Cách làm: thêm bản `[Server]`, KHÔNG đổi bản client

Đừng đổi mod dịch thành `all_clients_require_mod = true`: người chơi mất khả
năng tự bật khi vào server người khác — mất phần lớn người dùng.

Thay vào đó `build.py` dựng **hai thư mục từ cùng một `modmain.lua`**:

| | client (giữ nguyên) | server (mới) |
|---|---|---|
| thư mục | `build/<mod>-vi` | `build/<mod>-vi-server` |
| `name` | `… - Đừng Chết Đói :)` | `… - Đừng Chết Đói :) [Server]` |
| `client_only_mod` | `true` | `false` |
| `all_clients_require_mod` | `false` | `false` ← server-only, người chơi KHÔNG phải tải |
| Workshop | item cũ | **item mới riêng** |

- Chủ server bật bản `[Server]` ở tab Mods khi tạo world; người chơi bật bản
  client như cũ. Host không hang thì chỉ cần bản client.
- Bản server đổi thoại sang tiếng Việt cho **mọi người trong server**.
- `make_upload.sh` kiểm `cmp` hai `modmain.lua` phải giống hệt — sửa một chỗ,
  không bao giờ lệch.
- `sync_local.sh` cài cả hai (qua Finder); server dedicated ẩn của host có
  hang đọc mod từ cùng thư mục `mods/` của game.

Mẫu hoàn chỉnh: `translations/functional-medal-viet/tools/build.py`
(`RA_SV`, hàm `modinfo(server)`), `make_upload.sh` (`CAC_BAN`), `sync_local.sh`.

## ⚠ Trước khi nhân bản cho mod khác: modmain phải chạy được trên dedicated

Bản server chạy `modmain` trên server **không có giao diện**. Soát:

- Móc chỉ dành cho client (`AddClassPostConstruct("widgets/…")`, hook
  `TextWidget.SetString`, `ThePlayer`, `TheFrontEnd`, scanner/dump màn hình)
  → bọc trong `if not GLOBAL.TheNet:IsDedicated() then … end`, hoặc tách file.
- Ghi đè `STRINGS.*` trong `AddSimPostInit`/`AddGamePostInit` thì chạy được cả
  hai phía.
- Chạy thử trên server headless (`<mod>/tools/test/`, xem memory
  server-test-cuc-bo) xem log có dòng của mod và không có lỗi Lua.

## Tình trạng các mod dịch (2026-09-27)

| Mod | Kiểu hiện tại | Cần bản server? |
|---|---|---|
| functional-medal-viet | client 3802626143 + **[Server] 3809137709** | xong |
| dang-tien-viet | client (`modimport scripts/main.lua`, có scanner, hook widget) | **Có** — phải tách móc client trước |
| myth-words-viet | client | **Có** — soát modmain |
| montfluv-viet | client (`tools/build_client_mod.py`) | **Có** |
| dst-tieng-viet | client, `.po` qua `LoadPOFile` cho game gốc | **Chưa rõ** — cần đo thoại game gốc có dịch phía client không trước khi làm |
| newconstant-viet | fork, `all_clients_require_mod = true` | Không — đã chạy cả hai phía |
| than-binh-phu-an-viet | fork, `all_clients_require_mod = true` | Không |

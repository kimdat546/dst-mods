# Thần Binh Phù Ấn — Việt hoá

Bản dịch tiếng Việt của mod DST **传奇武器-附魔强化**
([Workshop 3096210166](https://steamcommunity.com/sharedfiles/filedetails/?id=3096210166),
bản 3.21). Tác giả gốc: 宇宙超级霹雳闪电大煎蛋 — tác giả ghi rõ `代码已开源`
(mã nguồn mở) và không kèm điều khoản cấm nào trong `modinfo.lua`.

Nội dung mod: phù ấn trang bị, cường hoá quái, hệ thống nghề, boss riêng. Xem
`docs/dst-knowledge/mod-3096210166-fu-ma-cuong-hoa.md` để biết cách chơi.

## Khác với hai pattern dịch quen thuộc

Mod này **không bị obfuscate** — đọc được toàn bộ mã. Nên không cần hook runtime
kiểu `AddSimPostInit` + `TextWidget.SetString` như các mod bytecode, cũng không
dùng `.po`. Ở đây sửa thẳng chuỗi trong nguồn: sạch hơn, không tốn chi phí lúc
chạy, và không sợ sót chuỗi động.

## Cách làm

```
vendor/               bản gốc 3.21 nguyên vẹn — KHÔNG sửa tay
strings_source.json   2131 chuỗi Hán + bản dịch + ngữ cảnh + vị trí trong mã
build/                bản dựng ra, đây là thứ cài vào game
tools/
  extract_strings.py  quét vendor/ → strings_source.json
  apply_vi.py         ghi bản dịch vào strings_source.json (nhận JSON qua stdin)
  build.py            vendor/ + bản dịch → build/
  sync_local.sh       dựng, kiểm cú pháp, cài vào game qua Finder
```

Quy trình:

```bash
python3 tools/extract_strings.py          # sau khi mod cập nhật
echo '{"打孔石":"Đá Đục Lỗ"}' | python3 tools/apply_vi.py
python3 tools/build.py                    # hoặc ./tools/sync_local.sh để cài luôn
```

Bộ thay chuỗi **chỉ đụng chuỗi trong nháy kép, bỏ qua comment** — logic mod
không đổi. Chuỗi chưa dịch giữ nguyên tiếng Trung, nên build lúc nào cũng ra bản
chạy được, dịch tới đâu hiện tiếng Việt tới đó.

`description` của `modinfo.lua` nằm trong block `[[...]]` nên `build.py` vá
riêng, kèm ghi công tác giả gốc. `author` giữ nguyên tên tác giả.

## Lưu ý khi chơi

**Tắt mod gốc `workshop-3096210166` khi bật bản này** — hai bản cùng bật sẽ
trùng prefab và công thức.

Chuỗi có `\n` trong mã nguồn là **hai ký tự** `\` + `n`, không phải xuống dòng
thật. Khi dịch phải viết `"Khu\\nnộp đồ"` trong Python, sai chỗ này thì
`apply_vi.py` báo không khớp khoá.

## Bảng thuật ngữ

| Gốc | Việt |
|---|---|
| 附魔 | phù ấn |
| 强化 | cường hoá |
| 词条 | dòng thuộc tính |
| 装备 | trang bị |
| 宝石 | ngọc |
| 打孔 | đục lỗ |
| 镶嵌 | khảm |
| 耐久 | độ bền |
| 暴击 | chí mạng |
| 减伤 / 免伤 | giảm sát thương |
| 增伤 | tăng sát thương |
| 附魔石 | Đá Phù Ấn |
| 洗蕴石 | Đá Tẩy Ấn |
| 重置宝石 | Ngọc Tái Luyện |
| 打孔石 | Đá Đục Lỗ |
| 解石器 | Máy Gỡ Ngọc |
| 水晶道具 / 水晶小人 | Tinh Thể |
| 附魔合成台 | Bàn Phù Ấn |
| 拆除法杖 | Trượng Tháo Gỡ |
| 随从 | thuộc hạ |
| 精英 | tinh anh |

## Tiến độ

Chạy `python3 tools/build.py --check` để xem số hiện tại.

Đã xong trọn vẹn: màn hình cấu hình mod, tên vật phẩm và toàn bộ ngọc, dòng
thuộc tính trang bị, giao diện Bàn Phù Ấn, tên sinh vật và trang bị, điều kiện
phù ấn, danh hiệu ngẫu nhiên.

Còn lại chủ yếu: `hh_tunning.lua` (bảng số liệu), `hh_prefabs.lua`,
`hh_treasure_monster.lua` (thoại sự kiện kho báu), `hh_player.lua`,
`hh_rpc.lua`, `hh_language.lua` (bảng trợ giúp trong game).

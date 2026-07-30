# DST — Dựng widget HUD cho mod

Rút ra khi làm `originals/food-buff-hud` (2026-07-30). Mất 3 vòng test vì thiếu
đúng một thứ, nên ghi lại cho rõ.

## Quy tắc số một: PHẢI NEO

Widget con của `controls.top_root` **bắt buộc** phải neo. Thiếu neo thì nó nằm
trong không gian toạ độ không neo và **trôi ra ngoài màn hình dù đặt toạ độ nào**
— kể cả `(0,0)`. Triệu chứng đánh lừa: widget dựng thành công, `OnUpdate` chạy,
dữ liệu đúng, `Show()` được gọi, log sạch — mà màn hình trống trơn.

```lua
self.root = self:AddChild(Widget("root"))
self.root:SetVAnchor(ANCHOR_TOP)     -- ANCHOR_TOP / ANCHOR_MIDDLE / ANCHOR_BOTTOM
self.root:SetHAnchor(ANCHOR_LEFT)    -- ANCHOR_LEFT / ANCHOR_MIDDLE / ANCHOR_RIGHT
```

Sau khi neo, toạ độ là **offset từ góc đã neo**, giá trị nhỏ (vài chục đến vài
trăm), y âm là đi xuống khi neo TOP. Không phải ±500 như không gian không neo.

## Cấu trúc 3 lớp

```
MyHUD                 ← controls.top_root:AddChild(...)
 └ root               ← SetVAnchor + SetHAnchor  (lớp NEO)
    └ panel           ← lớp kéo thả được, SetPosition(offset từ góc)
       └ row1..N
```

Tách lớp neo và lớp di chuyển ra: kéo thả chỉ đụng `panel`, neo giữ nguyên.

## Gắn vào đâu

```lua
AddClassPostConstruct("widgets/controls", function(self)
    local MyHUD = require("widgets/myhud")
    self.myhud = self.top_root:AddChild(MyHUD(self.owner))
end)
```

`controls` có `top_root` và `bottom_root`. Gắn thẳng vào `self` (tức controls)
thì rơi vào không gian không neo → không hiện.

## Text mặc định căn GIỮA

`Text` căn giữa quanh toạ độ của nó. `SetHAlign(ANCHOR_LEFT)` **một mình không đủ**
— nó chỉ có tác dụng khi Text có region:

```lua
txt:SetRegionSize(W, H)
txt:SetHAlign(ANCHOR_LEFT)
txt:SetPosition(W / 2, 0)   -- region căn giữa quanh vị trí → dời nửa bề rộng
                            -- để chữ bắt đầu đúng từ gốc
```

Không làm vậy thì nửa chuỗi thò ra ngoài mép màn hình.

## Tham chiếu đáng tin

- `originals/food-buff-hud/scripts/widgets/foodbuffhud.lua` — của mình, đã test chạy
- `workshop-2905304624` Buff Timer (client), `scripts/BuffTimerClient/widgets/Root.lua`

⚠ **KHÔNG** dùng `pham-nhan-tu-tien/scripts/widgets/pn_hud_dantian.lua` làm mẫu:
mod đó chưa chạy được và widget thiếu `SetVAnchor`/`SetHAnchor`.

## Bẫy liên quan (env mod)

`modmain` chạy trong env sandbox, chỉ có `pairs ipairs print math table type
string tostring require Class TUNING GLOBAL modname MODROOT`. Không có `rawget`,
`tonumber`, `pcall`… → gọi qua `_G.`. File trong `scripts/` được `require` thì
chạy trong `_G` thật nên dùng trực tiếp được.

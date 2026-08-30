# Mod 3096210166 — 传奇武器-附魔强化 (Phù phép & Cường hoá)

Ghi chép đọc từ mã nguồn mod, bản **3.21**, ngày 2026-08-30. Dùng để test từng
tính năng.

- Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3096210166
- Tác giả: 宇宙超级霹雳闪电大煎蛋
- Mô tả gốc: `装备附魔/生物强化` — *phù phép trang bị / cường hoá sinh vật*
- **Mod này KHÔNG có nhân vật chơi được.** Không có `AddModCharacter` ở bất kỳ
  đâu, không có speech file, không có bigportraits.

---

## Cấu hình đang dùng ở Cluster_1

| Tuỳ chọn | Đang đặt | Nhãn gốc | Ý nghĩa |
|---|---|---|---|
| `key_config` | 120 | 快捷键打开强化页面 | **phím X** mở bảng cường hoá |
| `monster` | true | 开启部分怪物加强 | bật cường hoá một số quái |
| `monster_difficulty` | "3" | 怪物强化难度 | độ khó cường hoá quái |
| `monster_day` | false | 生物每日血量提高不限制天数 | máu quái tăng theo ngày, không giới hạn |
| `can_drop_equip` | true | 生物是否掉落装备 | quái rơi trang bị *(tác giả khuyên tắt ở hậu kỳ)* |
| `equip_drop` | true | 装备掉率 | tỉ lệ rơi trang bị |
| `equip` | **false** | 开启所有装备强化(mod武器可能崩溃) | cho cường hoá **mọi** trang bị; tác giả cảnh báo dễ crash với vũ khí của mod khác |
| `can_build_duck_box` | true | — | mở công thức 鸭鸭盒子 |
| `limit_drop_equip/stone/tally` | 40 | — | giới hạn rơi mỗi loại |

`equip = false` là **mặc định của mod**, không phải nguyên nhân "không thấy gì".

---

## Quy trình phù phép

Cốt lõi nằm ở `scripts/enums/hh_equip.lua`. Cách chơi:

1. Chế **拆除法杖 `hh_staff_dis`** (Quyền trượng tháo gỡ) — 10 vàng + 10 đá,
   không cần tech. Đây là công cụ thao tác chính.
2. Bỏ **vật liệu** vào ô 1 của quyền trượng (nó là container).
3. **Chuột phải vào món trang bị** muốn phù phép.

Mã tra vật liệu → hành động (`staff_gem_list`):

| Vật liệu bỏ vào trượng | Tác dụng | Tốn |
|---|---|---|
| `horn` sừng bò | **đục thêm lỗ** trên trang bị | 打孔石 |
| `gears` bánh răng | **gỡ ngọc** khỏi trang bị | 解石器 |
| `greengem` ngọc lục | **random lại chỉ số** của các dòng | 重置宝石 |
| `walrus_tusk` ngà hải mã | khảm 步伐珠 — tăng tốc chạy | ngọc tương ứng |
| `redgem` ngọc đỏ | khảm 暴击石 — tỉ lệ + sát thương chí mạng | — |
| `lightninggoathorn` sừng dê sét | khảm 首领打击 — sát thương lên boss | — |
| `silk` tơ nhện | khảm 蜘蛛打击 — sát thương lên nhện | — |
| `stinger` ngòi ong | khảm 昆虫打击 — sát thương lên côn trùng | — |
| `townportaltalisman` đá cát | khảm 力势石 — tăng sát thương | — |
| `steelwool` len thép | khảm 增伤宝珠 — cộng thẳng sát thương | — |
| `dragon_scales` vảy rồng ruồi | khảm 宝★攻击 | — |
| `minotaurhorn` sừng tê giác | khảm 宝★暴击 | — |
| `deerclops_eyeball` mắt Deerclops | khảm 宝★回耐 — hồi độ bền | — |

Muốn khảm thì **phải có sẵn viên ngọc tương ứng trong kho của mod** (kho riêng,
xem bằng phím **X**, không nằm trong túi đồ thường). Thiếu thì mod báo
`宝石数量不足`.

Thông báo lỗi hay gặp, để đối chiếu khi test:

- `右键附魔装备操作` — món bạn nhắm không phải trang bị phù phép được
- `请放正确的道具进行操作` — vật liệu trong trượng không nằm trong bảng trên
- `宝石数量不足` — chưa có viên ngọc đó trong kho

---

## Danh sách ngọc (`scripts/enums/hh_items.lua`)

`person_only = true` nghĩa là chỉ khảm được lên trang bị người chơi (giáp/mũ),
không phải vũ khí.

**Công cụ thao tác**

| Id | Tên | Việc |
|---|---|---|
| `a_punchStone` | 打孔石 | đá đục lỗ |
| `a_stoneDecoder` | 解石器 | máy gỡ ngọc |
| `a_refreshStone` | 重置宝石 | ngọc random lại chỉ số |

**Ngọc chiến đấu**

| Id | Tên | Hiệu ứng (theo chú thích trong mã) |
|---|---|---|
| `durableGem` | 耐用宝珠 | hồi độ bền |
| `damageBoostGem` | 增伤宝珠 | cộng thẳng sát thương |
| `powerMettleStone` | 力势石 | tăng sát thương theo % |
| `strideBead` | 步伐珠 | tăng tốc chạy |
| `shadowNightBead` | 暗袭珠 | tăng sát thương ban đêm |
| `twilightBead` | 昏光珠 | tăng sát thương lúc hoàng hôn |
| `dayShineBead` | 光耀珠 | tăng sát thương ban ngày |
| `critStrikeStone` | 暴击石 | tỉ lệ và mức chí mạng |
| `resistDamageGem` | 抗伤石 | giảm sát thương nhận |
| `retaliateGem` | 反伤石 | phản sát thương |
| `vigorousStone` | 蓬勃石 | tăng máu tối đa *(person_only)* |

**Ngọc khắc chế theo loại địch**

| Id | Tên | Khắc chế |
|---|---|---|
| `spiderVengeance` | 蜘蛛打击 | nhện |
| `insectStrikeCrystal` | 昆虫打击 | côn trùng |
| `shadowStrikeLuminary` | 暗影打击 | sinh vật bóng tối |
| `bossStrikeGem` | 首领打击 | boss |

**Ngọc phòng hộ môi trường** *(đều person_only)*

| Id | Tên | Hiệu ứng |
|---|---|---|
| `frostGuardCrystal` | 防寒晶 | miễn quá lạnh |
| `heatGuardCrystal` | 防暑晶 | miễn quá nóng |
| `elementBead` | 元素之星 | miễn lạnh + nóng + sát thương lửa + đóng băng |

**Linh thú và ngọc cao cấp**

| Id | Tên |
|---|---|
| `followCritical` / `followDamage` / `followArmor` | 灵兽-暴 / 灵兽-攻 / 灵兽-御 |
| `baconOmeletteBlessArmor/Atk/Critical` | 极致-防 / 极致-攻 / 极致-暴 |
| `baconOmeletteTrueDamage` | 极-真伤 (true damage) |
| `treasure_atk` / `treasure_bj` / `treasure_armor` | 宝★攻击 / 宝★暴击 / 宝★回耐 |
| `fxGem` | 特效宝石 (hiệu ứng hình ảnh) |
| `eightPigGem` / `nkGem` | 音音石 / 嘉心糖 |
| `z_clean_stone` | 净化符 |

**Thuật — vật phẩm dùng chủ động** (`is_item = true`, đều person_only)

| Id | Tên | Tác dụng đọc từ `item_fn` |
|---|---|---|
| `z_fertilizer` | 术:施肥 | bán kính 28: dập lửa, chống héo, tưới đầy nước + đầy phân cho mọi ô đất trồng |
| `z_plant` | 术:催熟 | bán kính 30: thúc chín lần lượt mọi cây/bụi hái được |
| `z_soil` | 术:耕地 | bán kính 28: dọn ụ đất cũ, xới lại thành lưới 3×3 ngay ngắn trên mỗi ô đất |
| `z_rain` | 术:雨书 | bật/tắt mưa (đang mưa thì tạnh, đang tạnh thì mưa) |
| `z_sleep` | 术:催眠 | bán kính 30: ru ngủ mọi sinh vật quanh mình |

---

## Công thức chế tạo (`main/hh_recipe.lua`)

| Vật phẩm | Tên | Nguyên liệu | Tech | Tab |
|---|---|---|---|---|
| `hh_staff_dis` | 拆除法杖 | 10 vàng + 10 đá | **không cần** | MAGIC / WEAPONS |
| `hh_cat_box` | 附魔盒子 | 10 vàng + 10 đá | **không cần** | MAGIC / CONTAINERS |
| `hh_duck_box` | 鸭鸭盒子 | 2 ngọc đỏ + 3 da heo + 10 vàng | **không cần** | MAGIC / CONTAINERS |
| `hh_essence` | 水晶道具 | 1 普通附魔卷轴 + 2 洗蕴石 | **không cần** | MAGIC / REFINE |
| `hh_treasure_tally_a` | 寻宝卷轴 | 40 ngòi ong | **không cần** | REFINE |
| `hh_treasure_tally_b` | 寻宝卷轴 | 20 tơ nhện + 20 tuyến nhện | **không cần** | REFINE |
| `hh_egg_nest` | tổ trứng | 1 vàng + 2 đá | SCIENCE_ONE | STRUCTURES |
| `hh_egg_exhibition_table` | bàn trưng bày trứng | 1 vàng + 2 đá | SCIENCE_ONE | STRUCTURES |
| `hh_suit_build` | 附魔合成台 | 10 vàng + 10 đá | MAGIC_TWO | MAGIC / STRUCTURES |
| `hh_ice_knife` | 冰刃 | 25 `hh_essence` + 1 ngọc opal + 40 nhiên liệu ác mộng | MAGIC_THREE | MAGIC / WEAPONS |
| `hh_staff_star` | 星星法杖 | 50 `hh_essence` + 5 ngọc opal + 50 nhiên liệu ác mộng | MAGIC_THREE | MAGIC / WEAPONS |

`hh_ice_knife` và `hh_staff_star` **không tháo rời được** (`no_deconstruction`).

Vật phẩm nền, không chế được — phải nhặt từ quái:

| Id | Tên | Việc |
|---|---|---|
| `hh_effect_tally` | 普通附魔卷轴 | cuộn phù phép thường, nguyên liệu chế `hh_essence` |
| `hh_effect_stone` | 特殊附魔石 | mang dòng phù phép đặc biệt |
| `hh_remove_stone` | 洗蕴石 | xoá dòng phù phép của trang bị |

---

## Nội dung khác mod thêm

**Nghề nghiệp** (`scripts/job/`) — hiện có 铁匠 *thợ rèn*, 5 bậc danh hiệu:
新手铁匠 → 熟练工匠 → 大师铁匠 → 传奇铸造师 → 神铸圣匠.
Mô tả: rèn và sửa vũ khí/giáp, lên cấp thì rèn được đồ tốt hơn và có hiệu ứng
phù phép riêng. Có cả `hh_job_shop_config`, `hh_job_task`, `hh_job_skill`,
`hh_job_npc` — nghĩa là có NPC, nhiệm vụ và cây kỹ năng.

**Boss và quái riêng**: `hh_boss_a`, `hh_klaus`, `hh_sharkboi`, `hh_beetle_pig`,
`hh_dual_wield_pig`, `hh_treasure_monster`, NPC `hh_npc_fire`.

**Trụ pháo** (dòng phù phép sinh trụ): `hh_turret`, `hh_turret_ice`,
`hh_turret_fire`, `hh_turret_poison` — sát thương tăng theo số ngày, trần 20.

**Dòng hiệu ứng**: 反甲 (phản giáp), 中毒 (độc), 恐惧 (sợ hãi), 流血 (chảy máu).

Danh sách quái **không** nhận dòng hồi máu: `sharkboi`, `daywalker`,
`daywalker2`.

---

## Thứ tự test đề nghị

1. **Bảng cường hoá** — vào game nhấn **X**. Không lên thì kiểm tra `key_config`
   trong cấu hình mod (120 = X).
2. **Chế `hh_staff_dis`** (10 vàng + 10 đá, không cần bàn chế) — kiểm tra tab
   MAGIC có hiện đồ mod không.
3. **Đánh quái** thường xem có rơi 普通附魔卷轴 / 洗蕴石 / trang bị không
   (`can_drop_equip` + `equip_drop` đang bật).
4. **Đục lỗ**: bỏ `horn` vào trượng → chuột phải vào vũ khí. Cần có 打孔石.
5. **Khảm ngọc**: bỏ `redgem` vào trượng → chuột phải vào vũ khí đã có lỗ.
6. **Chế `hh_essence`** rồi lên `hh_ice_knife` / `hh_staff_star` (cần
   MAGIC_THREE — bàn ma thuật cấp cao).
7. **Quái cường hoá**: `monster=true`, độ khó 3 — đánh nhau xem quái có buff và
   thanh máu khác thường không.
8. **Nghề thợ rèn**: tìm NPC (`hh_npc_fire`) trong world.

Nếu bước 1 không lên bảng thì mọi bước sau vô nghĩa — kiểm tra trước hết là mod
có nạp không: `master_server_log.txt` phải có dòng
`Loading mod: workshop-3096210166 (【附魔-强化】)`.

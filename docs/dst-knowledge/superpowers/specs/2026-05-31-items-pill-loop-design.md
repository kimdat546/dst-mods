# M-Items-1: Vòng Đan Dược (Đan Lô Loop) — Design Spec

**Status:** Approved (brainstorm) — pending user review of this doc.
**Date:** 2026-05-31
**Depends on:** `remake-m1-complete` (cultivation core: pn_tuvi, pn_linhcan, pn_canhgioi, events).

## 1. Mục tiêu

Khép kín **nguồn tu vi thứ 2** đã hứa ở M1 (kill + **đan dược**) bằng một vòng chơi hoàn chỉnh:

> Linh thảo hoang → hái (linh thảo + hạt) → trồng nhân giống trong **linh điền** (sinh trưởng nhanh) → luyện đan ở **đan lô** → uống đan (tăng tu vi / sửa linh căn / buff / hồi phục).

**Triết lý giữ nguyên từ M1:** tu vi CHỈ từ kill + đan; không thọ nguyên; vanilla survival nguyên vẹn. Đan dược là nguồn bổ trợ, KHÔNG được nhanh hơn cày quái (gated bởi trồng + thời gian luyện).

## 2. Nguyên tắc kiến trúc

- **Approach A — code sạch, mượn ART.** Tự viết prefab/component `pn_*` theo kiến trúc bootstrap M1. Chỉ copy **asset đồ họa** (.tex/.zip: icon đan, anim linh thảo) từ mod tham khảo. KHÔNG bê code mod khác.
- **Data-driven:** linh thảo và đan định nghĩa trong bảng data (`pn/herbs.lua`, `pn/pills.lua`); thêm loại = thêm dòng data, không sửa logic.
- **Tham khảo NHIỀU mod** (xem `docs/analysis/refmods/` + memory `reference-workshop-mods`):
  - Farm nhiều tầng + gia tốc sinh trưởng: **万物书** (`3730126500`, `tbat_farm_plant_*`), **Hall of Food** (`3731336839`, regrowth/crop).
  - Đan + lò luyện + icon đan: **山海秘藏** (`3046680574`, `fsm_ruyi_pellet`, `fsm_pellet_cookpot`, atlas `fsm_*pill*`), anim linh thảo `fsm_*`.
- **Skill áp dụng:** `dst-create-item-food` (linh thảo/hạt/đan là item+edible), `dst-create-building` (linh điền + đan lô), `dst-create-pill-buff` (đan + component buff).

## 3. Module data mới (`scripts/pn/`)

### 3.1 `herbs.lua`
Mỗi loài linh thảo:
```
{ id, display, rarity (COMMON/UNCOMMON/RARE), biome_tags,
  grow_stages = N, regrow_time, harvest = { herb_item, seed_chance },
  pill_tier_hint }  -- linh thảo hiếm → đan phẩm cao
```
v1: **4 loài** — 2 COMMON (cho hạ/trung-phẩm tu vi đan), 1 UNCOMMON (thượng-phẩm + buff/hồi phục), 1 RARE (Bổ Thiên Đan).

### 3.2 `pills.lua`
Mỗi đan:
```
{ id, display, category (TUVI/BOTHIEN/BUFF/HOIPHUC), tier,
  recipe = { {herb_id, count}, ... }, brew_time, fuel_cost,
  effect = { ... } }   -- effect schema theo category
```
v1: **6 đan** — Tu vi đan ×3 (hạ/trung/thượng), Bổ Thiên Đan ×1, Buff đan ×1, Hồi phục đan ×1.

### 3.3 Bổ sung `config.lua`
`HERB_GROW`, `LINHDIEN_ACCEL_MULT` (vd 2.0×), `LINHDIEN_RADIUS`, `TUVI_PER_PILL` theo phẩm, `BREW_BASE_TIME`.

## 4. Chuỗi farming

### 4.1 Linh thảo hoang (pickable prefab)
- 4 prefab cây `pn_herb_<id>` mọc trong thế giới (regrowth định kỳ qua `TheWorld` regrowthmanager, học từ Hall of Food `hof_regrowth`). Hái (pickable component) → cho **linh thảo item** + % rớt **hạt item**.
- Art: anim `fsm_*` mượn từ 山海秘藏 (re-encode qua tools nếu cần). Mỗi loài 1 build riêng (tránh pitfall bank dùng chung).

### 4.2 Hạt giống (`pn_herb_seed_<id>`)
- Item stackable, `inventoryitem` (atlasname đúng — pitfall #3). Hành động `PLANT`/deploy trên đất → spawn cây trồng.

### 4.3 Linh điền (`pn_linhdien` — công trình)
- Công trình craft được (tab tu tiên), đặt được, có minimap icon.
- Component `pn_linhdien`: định kỳ quét cây `pn_herb_crop_*` trong `LINHDIEN_RADIUS` → set cờ gia tốc → cây áp `LINHDIEN_ACCEL_MULT` vào timer sinh trưởng. Flavor "tiểu bình xanh".
- Không có linh điền: hạt vẫn trồng được nhưng lớn chậm (tốc độ nền).

### 4.4 Cây linh thảo trồng (`pn_herb_crop_<id>`)
- Phiên bản trồng: tầng sinh trưởng (hạt→mầm→trưởng thành), timer dùng `LINHDIEN_ACCEL_MULT` nếu trong vùng linh điền. Học growth-stage từ 万物书 `17_farm_plant_defs`.
- Trưởng thành → hái ra linh thảo (+ % hạt để nhân giống tiếp).

## 5. Đan lô + Đan dược

### 5.1 Đan lô (`pn_danlo` — công trình)
- Công trình craft được, có **UI container** (N ô bỏ linh thảo). Học building từ 万物书, container/cookpot UI từ 山海秘藏 `fsm_pellet_cookpot`.
- **Đan hoả:** đan lô cần được đốt (fuel nhẹ, vd than/gỗ) HOẶC chỉ tốn thời gian — **chốt ở plan**, mặc định: cần nhiên liệu + tốn `brew_time`.
- Component `pn_danlo`: nội dung ô → match công thức trong `pills.lua` (so khớp herb_id+count, kiểu crockpot test fn của Hall of Food) → luyện `brew_time` → spawn đan tương ứng. Không khớp → ra "phế đan" (hoặc trả lại nguyên liệu — chốt ở plan).

### 5.2 Đan dược (factory `MakePill`, data-driven)
Item edible/consumable; `oneaten` rẽ theo `category`:
| Category | Hiệu ứng |
|---|---|
| `TUVI` (×3 phẩm) | `inst.components.edible`/oneaten → eater `PushEvent(Events.TUVI_GAIN, {amount=TUVI_PER_PILL[tier], source="pill"})` |
| `BOTHIEN` | Nâng `pn_linhcan.type` 1 bậc theo thứ tự NGUY→CHAN→BIEN_DI→THIEN; đã THIEN thì no-op; re-push replica |
| `BUFF` | Gắn buff có thời hạn qua component mới `pn_buff` (lifecycle attach/extend/detach + stat modifier), vd +dmg trong T giây |
| `HOIPHUC` | Hồi HP/sanity (edible health/sanity value hoặc oneaten delta) |

### 5.3 Component `pn_buff` (mới)
- Theo skill `dst-create-pill-buff`: bảng buff (onattached/onextended/ondetached), áp/gỡ stat modifier, timed, save/load, replica để client hiển thị (HUD buff để milestone polish — v1 chỉ cần buff chạy đúng, HUD buff TÙY CHỌN).

## 6. Đăng ký (main/*)
- `main/items.lua` (mới): PrefabFiles cho herbs/seeds/crops/pills/structures; Assets cho atlas đan + anim linh thảo; AddIngredientValues nếu cần.
- `main/recipes.lua` (mới): AddRecipe2 cho linh điền + đan lô (tab tu tiên), recipe hạt nếu cần.
- `main/components.lua`: AddReplicableComponent cho `pn_buff` (và `pn_danlo` nếu cần client UI).
- import.lua: thêm items.lua, recipes.lua đúng thứ tự.

## 7. Cân bằng
- **Tu vi đan** cho cục tu vi đáng kể nhưng bị chặn bởi: trồng + `brew_time` + nhiên liệu → bổ trợ, không thay cày quái. `TUVI_PER_PILL` đặt sao cho 1 mẻ đan ≈ vài chục kill, không hơn.
- **Bổ Thiên Đan:** cần linh thảo RARE, 1 bậc/lần, trần Thiên → catch-up cho người roll xui, củng cố nguyên tắc công bằng ±30% (xem memory `feedback-balance-principles`).
- **Buff đan:** thời hạn ngắn, không stack cùng loại (hierarchy type+level).

## 8. Phạm vi & phi mục tiêu (YAGNI)
- **Trong v1:** 4 linh thảo, 6 đan, linh điền, đan lô, `pn_buff`, tích hợp tu vi/linh căn.
- **NGOÀI v1 (sau):** pháp bảo/phi kiếm (sub-milestone riêng); HUD buff panel đẹp (polish); địa hoả/đan hoả nhiều cấp; thêm loài/đan; linh thạch economy; phế đan craft lại.

## 9. Kiến trúc file (dự kiến)
```
scripts/pn/herbs.lua, pills.lua  (+ config.lua bổ sung)
scripts/components/pn_linhdien.lua (+_replica nếu cần)
scripts/components/pn_danlo.lua (+_replica)
scripts/components/pn_buff.lua (+_replica)
scripts/prefabs/pn_herb_<id>.lua            (cây hoang, ×4)
scripts/prefabs/pn_herb_seed.lua            (factory hạt)
scripts/prefabs/pn_herb_crop.lua            (factory cây trồng)
scripts/prefabs/pn_linhdien.lua, pn_danlo.lua (công trình)
scripts/prefabs/pn_pill.lua                 (factory MakePill)
scripts/main/items.lua, recipes.lua         (đăng ký)
images/ + anim/  (art mượn, re-encode)
```

## 10. Testing (DST-specific)
Static: `tools/check_syntax.sh` + `tools/check_assets.py` mỗi commit. In-game (sync_local + Host):
1. Tìm/hái linh thảo hoang → nhận linh thảo + hạt.
2. Craft linh điền; trồng hạt trong vùng → lớn nhanh hơn ngoài vùng.
3. Hái cây trồng → linh thảo.
4. Craft đan lô; bỏ linh thảo + đốt → sau `brew_time` ra đan đúng công thức.
5. Ăn tu vi đan → tu vi tăng (HUD); đủ ngưỡng → đột phá.
6. Ăn Bổ Thiên Đan → linh căn lên 1 bậc (`c_pnstate`).
7. Ăn buff đan → có buff thời hạn (stat đổi, hết giờ tự gỡ).
8. Ăn hồi phục đan → HP/sanity hồi.
9. Vanilla survival vẫn nguyên (đêm không lửa vẫn chết).

## 11. Known-unknowns (chốt ở plan)
- Đan hoả: cần fuel hay chỉ thời gian → mặc định cần fuel nhẹ.
- Đan lô UI: container N ô + nút luyện, hay auto-brew khi đủ nguyên liệu.
- Không khớp công thức → phế đan vs trả nguyên liệu → mặc định trả nguyên liệu (đỡ ức chế).
- Linh thảo hoang spawn: setpiece worldgen vs ambient regrowth → mặc định ambient regrowth (không đụng worldgen).
- Bổ Thiên Đan với Biến Dị (nhánh đặc thù) xử lý ra sao khi "lên bậc" → chốt: Biến Dị → Thiên giữ element chính.

# Phàm Nhân Tu Tiên — DST Mod Design Spec (MVP1)

**Tác giả:** kimdat546
**Ngày:** 2026-05-24
**Trạng thái:** Design approved, ready for implementation plan
**Scope:** MVP1 — vertical slice 6-10 tuần solo dev
**Cảm hứng:** Tiểu thuyết 「凡人修仙传」(Phàm Nhân Tu Tiên Truyện) của 忘语. Cảm hứng kỹ thuật: mod DST 「登仙」(Dengxian, ID 3235319974) — kiến trúc code đã được phân tích trong `dengxian_architecture.md`, `dengxian_gameplay_glossary.md`, `dengxian_wiki_data.md`.

---

## 1. Tổng quan

### 1.1 Identity (linh hồn mod)

**PNTT-thuần**: cultivation là gameplay chính, sinh tồn DST là phụ. Người chơi được đánh giá bằng **cảnh giới**, **linh căn**, **pháp bảo** (pháp bảo ở MVP2+) — không phải bằng số ngày sống sót.

Khác biệt cốt lõi so với mod tham khảo (Dengxian):
- **Không có 9 nhân vật cố định.** Mọi player bắt đầu là một **phàm nhân** trống trơn.
- **Linh căn random** quyết định tốc độ tu luyện — không thể chọn.
- **Player tự tìm linh dược, tự luyện pháp bảo** — không có class-given starter weapon.
- **Tuổi thọ + permadeath** — must break through before old age.

### 1.2 Ràng buộc đã chốt (qua brainstorming)

| # | Quyết định | Lý do |
|---|---|---|
| 1 | PNTT-thuần (cultivation = game, survival = phụ) | User vision rõ ràng — đậm chất novel |
| 2 | Co-op + PvP optional + sĩ môn | Long-term roadmap; **KHÔNG trong MVP1** |
| 3 | Tuổi thọ + permadeath khi hết | Hardcore PNTT-feel; trong MVP1 |
| 4 | Bỏ hết vanilla characters, chỉ 1 class "phàm nhân" | Tinh thần "ai cũng bắt đầu từ 0" |
| 5 | Worldgen vanilla cho MVP1, custom sau | Tránh asset workload sớm |
| 6 | MVP1 6-10 tuần vertical slice | Solo dev mới học DST modding |
| 7 | Multi-component architecture từ ngày 1 | User chose Approach B over A — value clean structure |
| 8 | 4 nguồn tu vi (active play > passive sit) | User flagged "ngồi im nhàm chán" |
| 9 | Linh mạch attract + mob cultivate ở đó | User-added emergent design |

### 1.3 Scope MVP1 (single source of truth)

**TRONG MVP1:**
- 1 character class "phàm nhân", linh căn random
- Tu vi tăng từ: linh mạch aura, yêu thú nội đan, linh thảo, ambient
- Cảnh giới Luyện Khí 9 tầng (sơ kỳ → đỉnh phong)
- Tuổi thọ + permadeath
- 3 tier linh mạch trên worldgen
- Mob cultivation (vanilla mob tu luyện trong aura)
- HUD widget + multiplayer indicator
- Character select override

**KHÔNG TRONG MVP1 (planned cho MVP2+):**
- Đan dược / alchemy / lò luyện
- Pháp bảo + refinement
- Cảnh giới Trúc Cơ và cao hơn + đan kiếp tribulation
- Sĩ môn / sect system + sư đồ
- PvP mechanics
- Dungeon / phó bản
- Custom worldgen (xianxia biomes)
- Custom mob xianxia (yêu thú riêng)
- Quest / cốt truyện

---

## 2. Kiến trúc tổng thể

### 2.1 File structure

```
pham-nhan-tu-tien-mod/
├── modinfo.lua                          # config, name, version, mod tags
├── modmain.lua                          # entry: AddAction, AddPrefab, AddClassPostConstruct
├── modicon.tex / modicon.xml
├── strings/
│   └── strings_vn.lua                   # mọi text tiếng Việt
├── anim/
│   └── phamnhan.zip                     # MVP1: clone player_wilson + tint
├── images/
│   ├── inventoryimages/
│   ├── hud/
│   │   └── pn_hud_frame.tex/.xml
│   └── minimap/
│       └── pn_linhkhi_*.tex/.xml
├── scripts/
│   ├── components/
│   │   ├── pn_linhcan.lua + _replica.lua
│   │   ├── pn_tuvi.lua + _replica.lua
│   │   ├── pn_canhgioi.lua + _replica.lua
│   │   ├── pn_lifespan.lua + _replica.lua
│   │   ├── pn_meditation.lua            (server-only)
│   │   ├── pn_aura.lua                  (server-only)
│   │   ├── pn_breakthrough.lua          (server-only)
│   │   └── pn_mob_cultivation.lua       (server-only, on mobs)
│   ├── widgets/
│   │   ├── pn_hud_main.lua
│   │   └── pn_canhgioi_indicator.lua
│   ├── prefabs/
│   │   ├── phamnhan.lua                 # player
│   │   ├── pn_linhkhi_source.lua        # 3-tier linh mạch
│   │   ├── pn_noidan.lua                # nội đan items
│   │   └── pn_linhthao.lua              # linh thảo plants
│   └── pn/                               # mod-internal modules
│       ├── tuning.lua                   # tất cả constants
│       ├── events.lua                   # event name constants
│       ├── linhcan_data.lua             # 4 loại linh căn
│       ├── realms.lua                   # Luyện Khí 9 tầng
│       ├── actions.lua                  # PN_MEDITATE
│       ├── worldgen.lua                 # linh mạch placement
│       ├── charselect_override.lua      # force phàm nhân
│       ├── mob_patches.lua              # AddPrefabPostInit vanilla mobs
│       └── debug.lua                    # console commands (DEBUG_PNTT only)
└── tools/                                # dev only, không ship
    ├── check_syntax.sh
    ├── check_assets.py
    ├── check_tuning.lua
    └── smoke_test.sh
```

**Convention:**
- Prefix `pn_` cho tất cả mod-specific identifiers (tương tự `xd_` của Dengxian)
- `_replica.lua` đi cùng folder với server component (DST chuẩn)
- `pn/` namespace cho mod-internal modules (không phải DST API)
- 1 file 1 prefab khi reasonable; nhiều prefab cùng loại có thể chia sẻ 1 file (`pn_linhkhi_source.lua` define 3 variants)

### 2.2 8 components

| Component | Server/Client | Responsibility | State |
|---|---|---|---|
| `pn_linhcan` | Server + Replica | Linh căn random 1 lần. Cung cấp multiplier tu vi rate. | `type`, `elements`, `tu_vi_mult` |
| `pn_tuvi` | Server + Replica | Tích lũy tu vi. Listen `TUVI_GAIN`. | `current_amount`, `cap` |
| `pn_canhgioi` | Server + Replica | Track realm + tier. Apply stat bonus on tier-up. | `tier_index` (1-9) |
| `pn_lifespan` | Server + Replica | Tuổi thọ + decay + permadeath trigger. | `total`, `remaining`, `permadeath` |
| `pn_meditation` | Server-only | Sit-meditate action handler. Bonus 1.5× rate. | `is_sitting`, `target_source` |
| `pn_aura` | Server-only | Track entities in linh mạch radius. Spawn `TUVI_GAIN`. | `entered_auras` set |
| `pn_breakthrough` | Server-only | Detect tu_vi threshold crossings. Trigger tier-up. | (stateless) |
| `pn_mob_cultivation` | Server-only | Same as player cultivation, applied to mobs via `AddPrefabPostInit`. | `time_in_aura`, `current_tier` |

**Replica components** chỉ cho 4 thứ HUD cần đọc: `pn_linhcan`, `pn_tuvi`, `pn_canhgioi`, `pn_lifespan`.

### 2.3 Data flow: event-driven

Tất cả cross-component communication đi qua DST event system. **Component không gọi trực tiếp method của component khác để mutate**, chỉ đọc state khi cần.

```
[Player nhận tu vi từ bất kỳ nguồn nào]
         │
         ▼
   player:PushEvent("pn_tuvi_gain", { amount = N, source = "linh_mach" })
         │
         ▼
   pn_tuvi: listen → mult với linhcan.multiplier → tích lũy
         │
         ▼
   player:PushEvent("pn_tuvi_changed", { new_value = ... })
         │
         ▼
   pn_breakthrough: kiểm tra threshold → nếu vượt, trigger
         │
         ▼
   player:PushEvent("pn_canhgioi_up", { new_tier = ... })
         │
         ▼
   pn_canhgioi: cập nhật state + apply stat bonus (HP/SAN/ATK/SPD)
   pn_lifespan: cộng thêm tuổi thọ
   HUD widgets: re-render qua replica
```

### 2.4 Event constants — `scripts/pn/events.lua`

```lua
return {
    TUVI_GAIN        = "pn_tuvi_gain",         -- payload: {amount, source}
    TUVI_CHANGED     = "pn_tuvi_changed",      -- payload: {new_value, old_value}
    CANHGIOI_UP      = "pn_canhgioi_up",       -- payload: {new_tier, old_tier}
    LIFESPAN_TICK    = "pn_lifespan_tick",     -- payload: {remaining}
    LIFESPAN_EXPIRED = "pn_lifespan_expired",  -- payload: {}
    AURA_ENTER       = "pn_aura_enter",        -- payload: {source}
    AURA_EXIT        = "pn_aura_exit",         -- payload: {source}
}
```

### 2.5 Component init order

Trong `scripts/prefabs/phamnhan.lua` `MasterPostInit`, thứ tự cố định:

1. `pn_linhcan` — sinh trước vì các component khác đọc multiplier
2. `pn_tuvi` — listen cho `TUVI_GAIN`
3. `pn_canhgioi` — listen cho `TUVI_CHANGED`
4. `pn_lifespan` — listen cho `CANHGIOI_UP`
5. `pn_meditation` — independent
6. `pn_aura` — push `TUVI_GAIN`, listen `AURA_ENTER/EXIT`
7. `pn_breakthrough` — listen cho `TUVI_CHANGED` (sau `pn_tuvi` đã init)

`pn_mob_cultivation` attach vào vanilla mob prefabs qua `AddPrefabPostInit`, không phải player.

### 2.6 Quy tắc tránh coordination hell

1. **Read-only cross-component**: component đọc state công khai (vd `pn_linhcan:GetMultiplier()`) nhưng không bao giờ `:Set...()` lên component khác.
2. **Mutation chỉ qua event**: nếu A cần B thay đổi state, A push event, B listen.
3. **Init order fixed** (xem 2.5).

---

## 3. Hệ thống cultivation

### 3.1 Linh căn (PNTT canonical)

**4 loại**, random tại spawn lần đầu. Sau đó **immutable** (chỉ thay đổi qua permadeath → nhân vật mới).

| Loại | Số element | Tỷ lệ roll | Multiplier tu vi | Display |
|---|---|---|---|---|
| Ngụy Linh Căn | 4-5 | 65% | 1.0× | Đa số phàm nhân |
| Chân Linh Căn | 2-3 | 30% | 1.5× | Khá — tu chân tốt |
| Biến Dị Linh Căn | 2-3 combo đặc biệt | 3% | 2.5× | Lôi/Băng/Phượng/v.v. |
| Thiên Linh Căn | 1 | 2% | 3.0× | Thiên tài hiếm |

5 element gốc: **Kim, Mộc, Thủy, Hỏa, Thổ**. Subset rolled dựa vào loại.

**Biến Dị combos** (ví dụ — sẽ mở rộng MVP2):
- Kim + Thủy → Băng Linh Căn
- Kim + Hỏa → Lôi Linh Căn
- Mộc + Hỏa → Phượng Linh Căn

**MVP1 scope:** Linh căn chỉ ảnh hưởng `tu_vi_mult`. Element chưa ảnh hưởng pháp bảo affinity (MVP2).

**File data:** `scripts/pn/linhcan_data.lua` — bảng config-able, không hard-code trong logic.

### 3.2 Cultivation math — Luyện Khí 9 tầng

**Threshold formula:** `threshold(N) = 100 × N^1.5`

| Tầng | Tu vi cần lên | Tu vi tích lũy |
|---|---|---|
| 1 (sơ kỳ) | 100 | 100 |
| 2 | 282 | 382 |
| 3 | 519 | 901 |
| 4 | 800 | 1,701 |
| 5 (trung kỳ) | 1,118 | 2,819 |
| 6 | 1,469 | 4,288 |
| 7 | 1,852 | 6,140 |
| 8 (hậu kỳ) | 2,262 | 8,402 |
| 9 (đỉnh phong) | 2,700 | **11,102** |

**Stat bonus mỗi tầng** (linear, dễ tune):

| Stat | Formula | Tại tầng 9 |
|---|---|---|
| HP max | +10 × tier | +90 (base 100 → 190) |
| Hunger drain mult | 1.0 - (0.05 × tier) | 0.55× (chậm hơn 45%) |
| Attack mult | 1.0 + (0.05 × tier) | 1.45× |
| Move speed mult | 1.0 + (0.01 × tier) | 1.09× |

### 3.3 Breakthrough (đột phá)

**MVP1:** Auto-pass. Khi `pn_tuvi.current >= threshold(next_tier)`:
1. `pn_breakthrough` push event `CANHGIOI_UP`
2. `pn_canhgioi` advance tier, apply stat bonus delta
3. `pn_lifespan` extend +5 days
4. HUD broadcast notification "Đột phá Luyện Khí N tầng thành công!"
5. Visual FX: brief glow particle on player

**MVP2+:** thêm risk (% fail dựa cảnh giới), fail = mất 50% tu vi. MVP3+: Trúc Cơ trở lên cần đan kiếp event.

### 3.4 Lifespan & permadeath

**Đơn vị:** DST days. 1 DST day = 8 phút real.

**Tuổi thọ:**
- Phàm nhân base: **60 days** (`total = 60`, `remaining = 60` tại spawn)
- Mỗi tầng Luyện Khí breakthrough: **+5 vào CẢ `total` lẫn `remaining`** — cảnh giới mới mở ra thọ nguyên mới, đồng thời cứu hồi tức thời 5 ngày
- Đạt Luyện Khí 9 (đỉnh phong) trong 25 days: `total = 60 + 9×5 = 105`, `remaining = 105 - 25 = 80`
- Maximum lifespan possible với Luyện Khí ceiling: **105 days total**

**Decay:** `remaining -= 1` mỗi DST day cycle. Track qua `worldevent` `dayphasestart` chuyển sang `day`.

**Khi `remaining = 0`:**
1. `pn_lifespan` push `LIFESPAN_EXPIRED`
2. `player:DoTaskInTime(0, ...)` → `health:Kill()` với damage source `"oldage"`
3. `OnSave`: persist `permadeath = true` flag trên `player.userdata`
4. Mọi respawn attempt (touchstone, ghost revive amulet) → check flag → block + message "Tuổi thọ đã tận, không thể hồi sinh"
5. Player phải rời server và rejoin → spawn nhân vật mới với linh căn random mới

**Edge cases:**

| Tình huống | Xử lý |
|---|---|
| Server tắt | Time không trôi → lifespan không giảm. Vanilla DST behavior. |
| Player disconnect | `OnSave` persist mọi state, `OnLoad` restore. |
| Ghost form trước permadeath | Allow vanilla flow, chỉ block respawn cuối. |
| Touchstone activated trước chết | Check flag SAU touchstone respawn, override. |
| Admin reset | `c_setlifespan(player, N)` debug command bypass cho admin. |

---

## 4. Engagement loop — 4 nguồn tu vi

Vấn đề: nếu chỉ "ngồi thiền" để tu vi, player không có gì làm → boring. Giải pháp: 4 nguồn parallel, kết hợp passive + active.

| Nguồn | Cơ chế | Tốc độ | Player làm gì |
|---|---|---|---|
| A. Linh mạch aura | Đứng trong radius | 1.0-5.0 tu vi/s (base, theo tier) | Tìm, claim, defend |
| B. Yêu thú nội đan | Drop từ kill mob | 50-300 burst | Combat |
| C. Linh thảo | Eat plant | 15-50 burst + 5min buff | Foraging |
| D. Ambient passive | Always-on khi sống | 3 tu vi/in-game min | Tồn tại |

**Tổng hoà:** chơi DST như bình thường (combat, forage, survival) → tu vi tăng từ B+C+D. Khi muốn boost → linh mạch (A). Active gameplay là path chính.

### 4.1 Sample journey (Ngụy linh căn, worst case 1.0×)

| Phase | Hoạt động | Tu vi tích lũy | Real time |
|---|---|---|---|
| Day 1-3 | Sinh tồn + 1-2 hạ phẩm linh mạch | → 800 (LK 1) | ~30 phút |
| Day 4-8 | Combat mob, ăn linh thảo, claim thêm hạ phẩm | → 3,000 (LK 3) | ~1 giờ |
| Day 9-15 | Thử trung phẩm linh mạch | → 6,500 (LK 5-6) | ~1 giờ |
| Day 16-25 | Combat thượng phẩm linh mạch | → 11,100 (LK 9) | ~45 phút |
| **Tổng** | | | **~3.5 giờ active** |

Thiên linh căn (3.0×): ~1.2 giờ. "Easy mode" cho thiên tài.

---

## 5. Linh mạch — chiến trường tu luyện

### 5.1 3 tier linh mạch

| Tier | Rate | Aura radius | Spawn pool | Max mob | Spawn interval | Aggression |
|---|---|---|---|---|---|---|
| Hạ phẩm | 1.0/s | 4 tiles | spider × 1-2, mosquito × 0-1 (forest); frog × 1-2 (marsh); killer rabbit (savanna) | 2 | 90s | normal |
| Trung phẩm | 2.5/s | 5 tiles | spider warrior × 2-3, hound × 1, clockwork knight × 1 | 3 | 120s | +20% aggro range |
| Thượng phẩm | 5.0/s | 6 tiles | shadow creature × 1-2, depths worm × 1, red hound × 2 | 4 | 150s | +50% aggro range |

### 5.2 Worldgen placement

| Tier | Count | Min distance from spawn |
|---|---|---|
| Hạ phẩm | 20 | 0 tiles |
| Trung phẩm | 6 | 300 tiles |
| Thượng phẩm | 2 | 600 tiles |

**Distance-from-spawn rule** — new player chỉ gặp hạ phẩm tự nhiên. Phải có purpose mới đi xa.

Algorithm: 30 attempts random placement per linh mạch, reject nếu nằm trên water/setpiece, retry. Acceptable nếu map nhỏ tạo ít hơn requested.

### 5.3 Mob cultivation — 3 tier linh thú

Vanilla mob trong linh mạch aura cũng tu vi qua `pn_mob_cultivation`.

| Cấp | Time in aura | Stat | Visual | Drop khi chết |
|---|---|---|---|---|
| Tier 0 | 0 | vanilla | vanilla | hạ phẩm nội đan (50% chance) |
| Tier 1 (Linh thú) | 5 phút | +50% HP, +25% dmg, +20% size | green glow | trung phẩm nội đan (100%) |
| Tier 2 (Yêu tu) | 15 phút | +120% HP, +60% dmg, +35% size | red/purple glow + particle | thượng phẩm nội đan (100%) + 5% drop linh thảo |

**Component `pn_mob_cultivation`** attach via `AddPrefabPostInit` lên vanilla mob prefabs (danh sách trong `scripts/pn/mob_patches.lua`).

**Aura exit decay:** time_in_aura giảm 50% rate khi mob rời aura. Tránh "yêu tu lưu vong" lang thang map.

**Demotion:** mob exit aura > 5 phút → demote Tier 2 → Tier 1 (giữ stat Tier 1 nhưng visual mờ).

### 5.4 Balance rules — phòng frustration

1. **Distance-from-spawn rule** (đã ở 5.2)
2. **Grace period:** player mới enter aura có 30s không bị aggro. Cho thời gian chạy nếu thấy đông.
3. **Visible warning:**
   - Linh mạch visual chỉ tier (xanh/vàng/đỏ)
   - Tier 1+ mob có glow rõ ràng → thấy từ xa
   - HUD báo "1 yêu tu nearby" khi vào aura thượng phẩm
4. **Mob leash:** mob không đuổi player xa hơn 25 tiles từ linh mạch. Vượt → return + heal full. Tránh kite cheese.
5. **Global cap:** max 8 Tier 1+ mobs toàn map. Khi đầy → mob mới spawn Tier 0. Tránh map quá tải.
6. **Death penalty:** chết tại linh mạch = mất 30% tu vi current. **KHÔNG mất cảnh giới đã đạt.** Lifespan không trừ thêm.

### 5.5 Linh mạch entity — `pn_linhkhi_source`

3 prefab variants: `pn_linhkhi_ha`, `pn_linhkhi_trung`, `pn_linhkhi_thuong`. Cùng factory function trong file `scripts/prefabs/pn_linhkhi_source.lua`.

Components attached:
- `Transform`, `AnimState`, `Network` (DST standard)
- `MiniMapEntity` — icon trên minimap theo tier
- `Inspectable` — examine quote tiếng Việt
- `pn_aura_source` — gameplay logic (radius scan, push events)
- `spawner` (vanilla) — spawn yêu thú theo pool/interval
- `lighting` (optional, atmospheric)

**Indestructible** — no `health` component, no `workable`. Tag `nointerpolate`. Tránh griefing.

**Visual MVP1 fallback** (chưa có art):
- Hạ phẩm: vanilla `firefly_lightsource` + tint xanh
- Trung phẩm: vanilla `winterometer` + tint vàng
- Thượng phẩm: vanilla `archive_orchestrina_base` + tint đỏ
- Sau MVP1 thay bằng art riêng

---

## 6. Linh thảo & nội đan

### 6.1 Linh thảo (3 loại MVP1)

| Tên | Spawn biome | Tu vi gain | Buff 5 phút |
|---|---|---|---|
| Tâm Tĩnh Hoa | Forest | +20 | Mild sanity regen |
| Linh Tiền Thảo | Grassland | +15 | Mild speed +5% |
| Hồng Liên Tử | Marsh | +30 | Fire resistance |

Spawn ambient (worldgen), không thay vanilla berry/carrot. Tỷ lệ tương đương vanilla `flower`.

Item action: `EAT` (vanilla) → consume → push `TUVI_GAIN` event.

### 6.2 Nội đan (3 phẩm)

| Phẩm | Tu vi gain | Drop từ |
|---|---|---|
| Hạ phẩm | +50 | Tier 0 mob (50% chance) |
| Trung phẩm | +120 | Tier 1 mob (100%) |
| Thượng phẩm | +300 | Tier 2 mob (100%) |

Stackable inventory item. Action `EAT` push `TUVI_GAIN`.

---

## 7. Interaction layer

### 7.1 Action `PN_MEDITATE`

File: `scripts/pn/actions.lua`. Register trong `modmain` qua `AddAction`.

Triggering:
- Right-click linh mạch entity → action available nếu trong distance 4
- Hoặc phím `Z` (configurable trong modinfo) khi đang đứng trong aura

Effect:
- Sit-down animation (reuse vanilla `state_idle_sit`)
- Bonus 1.5× tu vi rate trong khi sit
- Particle aura quanh player

Cancel:
- WASD movement
- Take damage
- Bấm `Z` lại

### 7.2 HUD widget — `pn_hud_main`

Layout góc dưới trái:

```
┌──────────────────────────────────────────┐
│ 🌿 Linh căn: Ngụy (Mộc/Thủy/Hỏa/Thổ)      │
│ ⚡ Cảnh giới: Luyện Khí 5 tầng              │
│ ▓▓▓▓▓▓▓▓▓░░░░░  2,432 / 3,000 tu vi      │
│ ⏳ Thọ: 78 / 105 ngày                       │
└──────────────────────────────────────────┘
```

Class extends `Widget`. Update via `OnUpdate(dt)` mỗi 0.5s, đọc từ replicas.

Attach: `AddClassPostConstruct("widgets/controls", function(self) … end)` → append vào `self.bottom_root`.

Lifespan text màu cảnh báo: white >50%, yellow 20-50%, red <20%.

### 7.3 Multiplayer indicator — `pn_canhgioi_indicator`

Label nhỏ overhead nameplate player khác, hiện "Luyện Khí 7 tầng" với màu theo realm tier.

Đọc từ `pn_canhgioi_replica` (networked). Cho phép player thấy power level từ xa → essential cho future PvP + sect coordination.

### 7.4 Character select override

**Server-side** (`scripts/pn/charselect_override.lua`):
```lua
AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("ms_playerjoined", function(_, player)
        if player.prefab ~= "phamnhan" then
            -- DespawnAndConvert: mod helper (TBD implementation, plan phase)
            -- Uses TheWorld:PushEvent("ms_playerdespawnandreplace", {player=player, newprefab="phamnhan"})
            DespawnAndConvert(player)
        end
    end)
end)
```

**Client-side**:
```lua
AddClassPostConstruct("screens/redux/characterselectscreen", function(self)
    self.character_list = {"phamnhan"}
    if self.RefreshPortraits then self:RefreshPortraits() end
end)
```

**Caveat:** Klei occasionally renames internal CharacterSelectScreen methods. Implementation phase cần test thực tế và adapt.

### 7.5 Prefab `phamnhan` skeleton

```lua
-- scripts/prefabs/phamnhan.lua
local assets = {
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/phamnhan.zip"),
}

local start_inv = {}  -- naked spawn (đúng PNTT)

local function MasterPostInit(inst)
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_lifespan")
    inst:AddComponent("pn_meditation")
    inst:AddComponent("pn_aura")
    inst:AddComponent("pn_breakthrough")

    inst:ListenForEvent("ms_playerjoined", function()
        if not inst.userdata or not inst.userdata.pn_linhcan_rolled then
            inst.components.pn_linhcan:RollNew()
            inst.userdata = inst.userdata or {}
            inst.userdata.pn_linhcan_rolled = true
        end
    end)

    -- Base stats như Wilson default
    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
end

return MakePlayerCharacter("phamnhan", {}, assets, nil, MasterPostInit, start_inv)
```

---

## 8. Tuning constants — `scripts/pn/tuning.lua`

Single source of truth cho mọi numeric balance. Mục đích: thay đổi mà không touch logic code.

```lua
return {
    LIFESPAN = {
        BASE = 60,
        BONUS_PER_TIER = 5,
        DECAY_PER_DAY = 1,
    },
    TU_VI = {
        BASE_RATE_PER_SEC = 1.0,
        TIER_THRESHOLD_BASE = 100,
        TIER_THRESHOLD_EXPONENT = 1.5,
        MAX_TIER_MVP1 = 9,
    },
    STATS_PER_TIER = {
        HP_BONUS = 10,
        HUNGER_MULT_DELTA = -0.05,
        ATTACK_MULT_DELTA = 0.05,
        SPEED_MULT_DELTA = 0.01,
    },
    TUVI_SOURCES = {
        LINH_MACH_HA      = { rate_per_sec = 1.0, aura_radius = 4 },
        LINH_MACH_TRUNG   = { rate_per_sec = 2.5, aura_radius = 5 },
        LINH_MACH_THUONG  = { rate_per_sec = 5.0, aura_radius = 6 },
        NOI_DAN_HA        = { burst = 50 },
        NOI_DAN_TRUNG     = { burst = 120 },
        NOI_DAN_THUONG    = { burst = 300 },
        LINH_THAO_BASE    = 15,
        AMBIENT_PER_MIN   = 3,
        SIT_MEDITATE_BONUS = 1.5,
    },
    LINH_MACH = {
        HA_PHAM    = { spawn_pool = "weak",   max_mob = 2, interval = 90 },
        TRUNG_PHAM = { spawn_pool = "medium", max_mob = 3, interval = 120 },
        THUONG_PHAM= { spawn_pool = "strong", max_mob = 4, interval = 150 },
        MOB_GRACE_PERIOD = 30,
        MOB_LEASH_RADIUS = 25,
        PLAYER_DEATH_TUVI_LOSS = 0.30,
    },
    MOB_CULTIVATION = {
        TIER_THRESHOLDS = { 300, 900 },  -- giây
        TIER_STAT_MULT = {
            { hp = 1.5, dmg = 1.25, size = 1.2 },
            { hp = 2.2, dmg = 1.6,  size = 1.35 },
        },
        AURA_EXIT_DECAY_RATE = 0.5,
        GLOBAL_TIER1_PLUS_CAP = 8,
        DEMOTION_DELAY = 300,  -- giây ngoài aura → demote
    },
    WORLDGEN = {
        LINH_MACH_COUNT = { HA = 20, TRUNG = 6, THUONG = 2 },
        LINH_MACH_MIN_DIST = { HA = 0, TRUNG = 300, THUONG = 600 },
    },
}
```

---

## 9. Testing strategy

### 9.1 5-layer pyramid

```
┌─────────────────────────────────────────┐
│   Lớp 5: Human playtest (cảm nhận)     │ ← chỉ khi feel
├─────────────────────────────────────────┤
│   Lớp 4: Interactive in-game           │ ← console commands
├─────────────────────────────────────────┤
│   Lớp 3: Headless server smoke test    │ ← Docker, log scan
├─────────────────────────────────────────┤
│   Lớp 2: Asset/Tuning validity         │ ← Python/Lua scripts
├─────────────────────────────────────────┤
│   Lớp 1: Lua syntax (luac -p)          │ ← mỗi commit
└─────────────────────────────────────────┘
```

**Mục tiêu**: tự động hoá tối đa, hỏi user playtest chỉ khi không tự verify được.

### 9.2 Tools (`tools/` directory)

- `check_syntax.sh` — `luac -p` mọi `.lua`. Run mỗi edit.
- `check_assets.py` — parse `Asset(...)` references, verify file exists; verify `.xml` ↔ `.tex` pairs.
- `check_tuning.lua` — standalone validation: thresholds monotonic, multipliers > 0, no nil.
- `smoke_test.sh` — Docker compose up, wait 90s, grep logs for errors, compose down.

### 9.3 Docker dev workflow

Repo `~/Desktop/dst-server-docker` dùng branch-per-world. Tạo branch `pntt-dev`:

```bash
cd ~/Desktop/dst-server-docker
git checkout -b pntt-dev
```

**Override compose** `cli/compose.override.yml`:
```yaml
services:
  master:
    volumes:
      - ~/Desktop/pham-nhan-tu-tien-mod:/home/steam/dst/mods/pntt_mod:ro
    environment:
      DST_FORCE_ENABLE_MODS: "pntt_mod"
      DEBUG_PNTT: "true"
```

**Modoverrides** `server/config/Master/modoverrides.lua`:
```lua
return {
    ["pntt_mod"] = {
        enabled = true,
        configuration_options = {},
    },
}
```

**Iteration:**
- Tuning change → `c_reset()` admin console (5s reload world)
- Component logic change → full container restart (30s)

### 9.4 Debug console commands — `scripts/pn/debug.lua`

Only loaded khi `DEBUG_PNTT=true` env. Examples:
- `c_setlifespan(player, N)` — set lifespan
- `c_setcanhgioi(player, N)` — jump to tier
- `c_addtuvi(player, N)` — add tu vi
- `c_setlinhcan(player, "THIEN", {"KIM"})` — force linh căn
- `c_spawnlinhmach(tier)` — spawn linh mạch tại player position
- `c_listallcomps(player)` — list installed pn_* components

---

## 10. Performance ceilings

| System | Budget | Notes |
|---|---|---|
| `pn_aura` radius scan | 1 query/sec/source, cap 50 sources active | Use `TheSim:FindEntities` (spatial query) |
| `pn_mob_cultivation` tick | 1 update/sec/mob, cap 30 mobs active | Combined với global cap 8 Tier1+ |
| HUD widget update | 2/sec (0.5s interval) | Read replica only |
| Worldgen | One-time at world init | Not recurring |

If lag → first suspect `pn_aura`. Profile via `c_perfgraphs()`.

---

## 11. Save/load contract

Mỗi server component implements `OnSave` / `OnLoad`:

```lua
function PnLinhCan:OnSave()
    return { type = self.type, elements = self.elements, rolled = self.rolled }
end

function PnLinhCan:OnLoad(data)
    if data then
        self.type = data.type
        self.elements = data.elements
        self.rolled = data.rolled
    end
end
```

**Critical:** `pn_lifespan` persist `permadeath = true` flag → reload không bypass permadeath.

**Idempotent OnLoad:** re-running OnLoad with same data không corrupt state.

---

## 12. Error handling principles

| Nguyên tắc | Áp dụng ở đâu |
|---|---|
| Defensive component access | `if self.inst and self.inst.components.xxx then …` |
| Read-only cross-component | Component chỉ đọc state, sửa qua event |
| No silent failures | `error()` rõ khi assumption sai (debug build) |
| Idempotent OnLoad | Re-load không corrupt |
| Network-aware client | `if replica:HasData()` trước khi đọc |
| Mod-compat | `AddPrefabPostInit`, không overwrite |

---

## 13. Workload breakdown

| Hệ thống | Component | Prefab | Estimate |
|---|---|---|---|
| Character + linh căn | 1 | 1 | 1 tuần |
| Cultivation (tu vi + canh giới + breakthrough) | 3 | 0 | 1.5 tuần |
| Lifespan + permadeath | 1 | 0 | 0.5 tuần |
| Aura + meditation | 2 | 0 | 1 tuần |
| Linh mạch entity + worldgen | 0 | 3 (1 file) | 1 tuần |
| Mob cultivation | 1 | 0 (patch) | 1 tuần |
| Nội đan + linh thảo | 0 | 6 (2 files) | 0.5 tuần |
| HUD + indicator | 0 | 0 | 1 tuần |
| Character select override | 0 | 0 | 0.5 tuần |
| Docker dev workflow + testing | 0 | 0 | 0.5 tuần |
| Polish, bug fix, asset placeholder | — | — | 1.5 tuần |
| **TỔNG** | **8** | **10 prefab / 4 files** | **~9.5 tuần** |

Phù hợp target 6-10 tuần MVP1.

---

## 14. Out of scope — explicitly NOT in MVP1

Để tránh scope creep, các thứ sau **không được implement** trong MVP1 dù có thể tempting:

- Đan dược / alchemy / lò luyện
- Pháp bảo / spirit treasures / refinement
- Cảnh giới trên Luyện Khí 9 tầng (Trúc Cơ trở lên)
- Đan kiếp / heavenly tribulation event
- Sĩ môn / sect / master-disciple
- PvP mechanics + balance
- Dungeon / phó bản
- Custom worldgen / xianxia biomes
- Custom mob art (chỉ patch vanilla mob)
- Quest / cốt truyện linear

Mỗi item sẽ có spec riêng cho MVP2/3/v.v.

---

## 15. Open questions / known unknowns

Acknowledge các thứ chưa rõ hoàn toàn — sẽ resolve trong implementation phase:

1. **CharacterSelectScreen API name** — Klei có thể đổi method name. Verify trong DST source và test trên client thật.
2. **`MakePlayerCharacter` 5th vs 6th argument** — sự khác biệt giữa `ClientPostInit` và `MasterPostInit` cần verify với DST source.
3. **`pn_aura_source` spawn integration với `spawner` component** — cần test thực tế xem 2 component cùng prefab có conflict không.
4. **`AddPrefabPostInit` thứ tự với mod khác** — nếu mod khác cũng patch spider, init order matter.
5. **Replica networking limits** — DST netvar có size limit. `linhcan.elements` table có thể cần serialize sang string.
6. **Save migration** — nếu sau này thay đổi tuning, save cũ có break không? Plan: version field trong save data.
7. **Git status** — thư mục mod `~/Desktop/pham-nhan-tu-tien-mod/` hiện chưa init git. Plan phase đầu tiên sẽ `git init` + commit design doc trước khi viết code đầu tiên.

---

## 16. References

- `dengxian_architecture.md` — kiến trúc code Dengxian (797 dòng)
- `dengxian_gameplay_glossary.md` — gameplay từ speech files (954 dòng)
- `dengxian_wiki_data.md` — spec số liệu từ wiki PDF (2,267 dòng)
- `Đăng-Tiên.pdf` — wiki tiếng Việt 186 trang
- Novel: 「凡人修仙传」by 忘语 — canonical reference cho cảnh giới + linh căn system

---

**End of design spec.**

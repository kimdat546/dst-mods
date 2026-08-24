# Remake — Milestone 1: Cultivation Core — Design Spec

**Tác giả:** kimdat546
**Ngày:** 2026-05-30
**Trạng thái:** Design approved, ready for implementation plan
**Bối cảnh:** Remake sạch của mod Phàm Nhân Tu Tiên (MVP1 archived tại tag `mvp1-archive`). Foundation-first — M1 là Cultivation Core, các milestone sau (Active Engagement đã gộp vào M1, World Scaling, Co-op Social, Items) build lên.

---

## 1. Mục tiêu & phạm vi

### 1.1 Vision tổng (3 USP — khác Dengxian)
1. **Phàm nhân thật** — bắt đầu yếu, linh căn random (đa số kém như Hàn Lập), grind có ý nghĩa
2. **Co-op sĩ môn** — nhiều phàm nhân cùng tu, lập sĩ môn, tranh tài (milestone sau)
3. **World scaling** — quái/thế giới nâng cấp theo tiến độ player (milestone sau)

### 1.2 Phạm vi M1 (CHỈ Cultivation Core)
**TRONG M1:**
- 1 class "phàm nhân", linh căn random 4 loại
- Cảnh giới **Luyện Khí 13 tầng** (data-driven, mở rộng được)
- Tu vi tăng **chỉ từ giết quái**
- Đột phá tầng (auto-pass)
- Stat bonus theo tầng (mạnh, kèm buff quái bù)
- HUD đan điền (art Dengxian)

**KHÔNG trong M1 (milestone sau):**
- Thọ nguyên / permadeath (Luyện Khí vẫn là phàm nhân → vanilla mechanics nguyên vẹn)
- Tọa thiền, linh mạch, ambient (đã bỏ — tu vi chỉ từ combat)
- Đan dược (nguồn tu vi phụ — milestone Items)
- Cảnh giới trên Luyện Khí (Trúc Cơ+), đan kiếp
- Sĩ môn, PvP, world scaling động, pháp bảo, skill

### 1.3 Nguyên tắc cốt lõi
- **Code chuẩn theo `docs/analysis/dst-api-foundation.md`** — tránh 8 pitfall đã gây 19 lần fix bug ở MVP1
- **Bám novel** (`docs/analysis/pntt-novel-systems.md`): Luyện Khí 13 tầng, linh căn (Hàn Lập 4 ngụy thiếu Kim)
- **Cân bằng cho MP:** linh căn gap ≤ +30%; cultivation mạnh nhưng quái buff bù
- **Vanilla nguyên vẹn:** tối chết, đói, mùa — cultivation là lớp THÊM, không thay thế

---

## 2. Kiến trúc — bootstrap layer kiểu Dengxian

### 2.1 File structure
```
modinfo.lua
modmain.lua                      # MỎNG: env setup + modimport("scripts/main/import")
scripts/
├── main/                        # bootstrap layer (mỗi file 1 nhiệm vụ đăng ký)
│   ├── import.lua               # orchestrator: modimport mọi main/* khác
│   ├── assets.lua               # PrefabFiles + Assets
│   ├── strings.lua              # STRINGS.NAMES + CHARACTERS.PHAMNHAN.DESCRIBE
│   ├── character.lua            # AddModCharacter + RemoveDefaultCharacter
│   ├── components.lua           # AddReplicableComponent
│   ├── widgets.lua              # AddClassPostConstruct gắn HUD
│   └── mob_hooks.lua            # AddPrefabPostInit: quái chết → tu vi + buff stat
├── components/
│   ├── pn_linhcan.lua + pn_linhcan_replica.lua
│   ├── pn_tuvi.lua + pn_tuvi_replica.lua
│   ├── pn_canhgioi.lua + pn_canhgioi_replica.lua
│   └── pn_breakthrough.lua      # server-only, không replica
├── widgets/
│   └── pn_hud_dantian.lua
├── prefabs/
│   └── phamnhan.lua
└── pn/                          # pure data + helpers
    ├── config.lua               # hằng số balance nội bộ
    ├── events.lua               # tên event constants
    ├── linhcan_data.lua         # 4 loại linh căn + 5 hệ
    └── realms.lua               # ⭐ realm ladder data-driven
```

**Vì sao bootstrap layer:** MVP1 dồn 300+ dòng vào modmain → khó mở rộng. Dengxian dùng 32 file `main/*`. Thêm milestone (sĩ môn, world scaling) = thêm `main/sect.lua`, `main/worldscaling.lua`, không đụng modmain. `import.lua` là entrypoint duy nhất modmain gọi.

### 2.2 Pitfall compliance (từ dst-api-foundation.md)
- `GLOBAL` chỉ trong modmain/main env; trong `components/*` + `prefabs/*` (load qua require) dùng bare `TheWorld`/`TheSim`/`SpawnPrefab`
- `common_postinit` (client+server) cho visual; `master_postinit` (server) cho components/logic
- Component init push initial state qua `DoTaskInTime(0, _PushToReplica)` để client thấy ngay
- net var: `net_string/float/byte/bool(inst.GUID, "name", "dirtyevent")`, đọc `:value()`, client đọc qua `inst.replica.<comp>`
- atlasname chỉ trỏ atlas MOD-shipped (pn_ui), không phải vanilla bundled
- mob patch: `AddPrefabPostInit(name, fn)`, gate `if not TheWorld.ismastersim then return end`

### 2.3 Realm data model (điểm "mở rộng được" cốt lõi)
`pn/realms.lua` — pure data, logic đọc generic:
```lua
return {
  macro_tiers = { "PHAM_NHAN", "LINH_GIOI", "TIEN_GIOI" },
  realms = {
    { id="LUYEN_KHI", macro="PHAM_NHAN", display="Luyện Khí",
      mode="layers", layer_count=13, enabled=true },
    -- Định nghĩa sẵn (enabled=false) — milestone sau chỉ bật + cân bằng, KHÔNG refactor:
    { id="TRUC_CO",  macro="LINH_GIOI", display="Trúc Cơ",
      mode="quarters", enabled=false },   -- sơ/trung/hậu/đại viên mãn
    { id="KET_DAN",  macro="LINH_GIOI", display="Kết Đan",  mode="quarters", enabled=false },
    { id="NGUYEN_ANH", macro="LINH_GIOI", display="Nguyên Anh", mode="quarters", enabled=false },
    { id="HOA_THAN", macro="LINH_GIOI", display="Hoá Thần", mode="quarters", enabled=false },
    { id="LUYEN_HU", macro="TIEN_GIOI", display="Luyện Hư", mode="quarters", enabled=false },
    { id="HOP_THE",  macro="TIEN_GIOI", display="Hợp Thể",  mode="quarters", enabled=false },
    { id="DAI_THUA", macro="TIEN_GIOI", display="Đại Thừa", mode="quarters", enabled=false },
  },
}
```
`pn_canhgioi` + `pn_breakthrough` đọc data này generic — không hard-code "13 tầng". M1 chỉ có `LUYEN_KHI` enabled.

---

## 3. Linh căn (pn_linhcan)

### 3.1 Data (`pn/linhcan_data.lua`)
5 hệ: **KIM, MOC, THUY, HOA, THO**.

| Loại | 中文 | Số hệ | Roll weight | tu_vi_mult | display |
|---|---|---|---|---|---|
| NGUY | 伪灵根 | 4-5 | 65 | 1.0 | Ngụy Linh Căn |
| CHAN | 真灵根 | 2-3 | 30 | 1.1 | Chân Linh Căn |
| BIEN_DI | 变异灵根 | 2-3 (combo) | 3 | 1.2 | Biến Dị Linh Căn |
| THIEN | 天灵根 | 1 | 2 | 1.3 | Thiên Linh Căn |

- **Gap ≤ +30%** (MP fairness — không nản người roll xui). Khác biệt thật = element affinity (milestone pháp bảo/skill), không phải tốc độ.
- Biến Dị combo (vd KIM+HOA→Lôi, KIM+THUY→Băng) — M1 chỉ lưu tag + hiển thị; affinity dùng sau.

### 3.2 Component behavior
- `RollNew()` 1 lần khi spawn đầu (idempotent, lưu `rolled` flag). Random theo weight.
- `GetTuViMult()` cho `pn_tuvi` query.
- `GetPrimaryElement()` cho HUD chọn màu medallion.
- Replica: net_string type + elements + bien_di_tag. Push initial trong ctor.
- OnSave/OnLoad persist.

---

## 4. Tu vi (pn_tuvi) + nguồn từ giết quái

### 4.1 Component
- `current`, `cap` (= threshold tầng kế).
- Listen event `TUVI_GAIN {amount, source}` → `amount × linhcan_mult` → cộng, cap tại threshold.
- Vượt cap → push `TUVI_CHANGED` → `pn_breakthrough` xử lý.
- Replica current/cap cho HUD bar. Push initial trong ctor.

### 4.2 Nguồn: giết quái (`main/mob_hooks.lua`)
- `AddPrefabPostInit(<mob>, fn)` cho danh sách quái vanilla có combat.
- Trong fn (server): listen `"death"` → nếu `combat.lastattacker` là phàm nhân → push `TUVI_GAIN` lên killer, amount theo bảng `config.TUVI_PER_MOB`.
- **CÙNG fn buff stat quái** (+40% HP, +25% dmg — flat M1) để cân bằng với player mạnh.

```lua
-- pn/config.lua
TUVI_PER_MOB = {
  spider=8, spider_warrior=15, spider_hider=12, spider_spitter=14,
  hound=20, firehound=28, icehound=28,
  frog=10, killerbee=6, mosquito=4,
  merm=18, pigman=25, pigguard=40,
  -- boss: deerclops=400, moose=350, bearger=400, dragonfly=600, ...
}
MOB_BUFF = { hp_mult=1.4, dmg_mult=1.25 }
```

### 4.3 Threshold curve (Luyện Khí 13 tầng)
`threshold(N) = BASE × N^EXPONENT`, BASE=80, EXPONENT=1.6.
Tổng ~16,500 tu vi tới tầng 13. Với quái ~8-25 tu vi × Ngụy 1.0× → ~vài giờ active combat. Boss thưởng đậm → khuyến khích đánh khó.

---

## 5. Cảnh giới (pn_canhgioi) + đột phá (pn_breakthrough)

### 5.1 pn_canhgioi
- `tier` (0 = Phàm Nhân, 1..13 = Luyện Khí tầng N — đọc từ realms.lua `LUYEN_KHI.layer_count`).
- Listen `CANHGIOI_UP {new_tier}` → cập nhật tier + apply stat delta.
- `GetDisplay()`: tier 0 = "Phàm Nhân", 1-13 = "Luyện Khí tầng N".
- Replica: net_tinybyte tier. Push initial (tier 0 hiện "Phàm Nhân" ngay).

### 5.2 Stat bonus mỗi tầng (mạnh — giống tu tiên thật)
| Stat | Mỗi tầng | Tầng 13 |
|---|---|---|
| HP max | +12 | 100 → 256 |
| Damage mult | +0.06 | 1.0 → 1.78 |
| Move speed | +0.008 (locomotor SetExternalSpeedMultiplier) | +10% |
| Hunger drain | ×(1 - 0.02·tier) | -26% |

- Apply DELTA mỗi lần lên tầng (không re-apply toàn bộ on load — đã baked vào save).
- Dùng `SetExternalSpeedMultiplier(inst, "pn_canhgioi", mult)` (đúng API, pitfall #4).

### 5.3 pn_breakthrough (server-only)
- Listen `TUVI_CHANGED` → nếu `current >= cap` và tier < max(13):
  - push `CANHGIOI_UP {new_tier=tier+1}`
  - `pn_tuvi:ConsumeForBreakthrough(cost)` + `SetCapForTier(tier+2)`
- **M1: auto-pass** (Luyện Khí không có đan kiếp theo novel). Tribulation cho đại cảnh giới = milestone sau.

---

## 6. HUD đan điền (pn_hud_dantian) — art Dengxian

### 6.1 Asset
- Atlas `images/pn_ui.xml` (copy từ Dengxian `xd_ui`, đã có).
- Medallion `level1-6.tex` (Luyện Khí, lửa màu theo hệ linh căn chính):
  THUY→level1, KIM→level3, MOC→level4, THO→level5, HOA→level6, mixed/Ngụy→level2.

### 6.2 Layout (dùng đúng tỉ lệ Dengxian, KHÔNG chế size tùy tiện)
- Medallion render **giữ aspect ratio native** (186×206), scale hợp lý 1 lần, không kéo méo (bài học MVP1: chỉnh size lung tung không khớp).
- Tu vi "X/Y" + cảnh giới "Luyện Khí tầng N" gắn theo medallion.
- **KHÔNG có dòng thọ** (bỏ lifespan).
- Đặt góc gọn (top-left), drag được + lưu vị trí (TheSim:SetPersistentString).
- `AddClassPostConstruct("widgets/controls")` gắn vào `top_root`.

### 6.3 Đọc data
- Qua `ThePlayer.replica.pn_linhcan/pn_tuvi/pn_canhgioi`, update mỗi 0.5s (`OnUpdate`).

---

## 7. Prefab phamnhan

- `MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)` (đúng thứ tự arg — pitfall #8 verify).
- `common_postinit`: tag "phamnhan" + `AnimState:SetBuild("phamnhan")` (build name == prefab name, dùng art repack từ MVP1 hoặc art mới).
- `master_postinit`: AddComponent linhcan/tuvi/canhgioi/breakthrough; roll linh căn lần đầu; base stats Wilson (HP100/hunger150/sanity200).
- Start inventory: rỗng (phàm nhân tay trắng).

---

## 8. Vanilla giữ nguyên
- KHÔNG đụng: darkness/Charlie, hunger, sanity, seasons, temperature, death/revive.
- Chết → ghost/touchstone/meat-effigy vanilla. Cultivation state persist qua save (lưu trên player).
- Cultivation = lớp power THÊM lên vanilla survival.

---

## 9. Testing
- **Static:** `tools/check_syntax.sh` + `tools/check_assets.py` (whitelist vanilla anims).
- **Local:** `tools/sync_local.sh` → copy folder thật vào Contents/mods (không cần Workshop).
- **Debug (`pn/debug.lua` hoặc main/debug):** `c_addtuvi(N)`, `c_settier(N)`, `c_setlinhcan(type, elements)`, `c_pnstate()`.
- **In-game verify:** linh căn random hiện HUD → giết quái → tu vi tăng (×mult) → đủ threshold → lên tầng → stat tăng rõ → quái buff thấy khó hơn → tối vẫn chết (vanilla nguyên) → chết+revive giữ cảnh giới.

---

## 10. Workload ước tính
~1.5-2 tuần. Nhỏ hơn MVP1 (bỏ meditation/linh mạch/lifespan; sẵn art/tools/api-foundation; code sạch 1 lần).

---

## 11. Out of scope (milestone sau, KHÔNG làm M1)
Đan dược, pháp bảo, skill/thần thông, Trúc Cơ+ & đan kiếp, thọ nguyên/permadeath, sĩ môn/PvP, world scaling động, luyện thể, dungeon, quest, custom worldgen, custom mob art.

---

## 12. Known unknowns
1. Build name của phàm nhân: tái dùng art repack MVP1 (`phamnhan.zip` build="phamnhan") hay art mới — quyết ở plan.
2. Bảng `TUVI_PER_MOB` cần playtest cân bằng — số trong spec là khởi điểm.
3. `MOB_BUFF` flat M1 có thể cần điều chỉnh khi có nhiều cảnh giới (chuyển sang scale động ở world-scaling milestone).
4. Repo chưa có modinfo/modmain mới — plan task đầu tạo scaffold sạch.

---

**End of M1 design spec.**

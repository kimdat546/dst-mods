# AI Art Prompts — Phàm Nhân Tu Tiên icons

Prompts tối ưu cho **Recraft** / **Ludo.ai** (tool cho upload reference image).
Mỗi icon: dùng 1 ảnh Dengxian trong `~/Desktop/dengxian-assets-review/decoded_png/`
làm **Style Reference** → AI khớp tông màu + nét vẽ → sinh icon mới.

## Cách dùng (Recraft)
1. New project → Image → chọn **Style: "Use a reference image"**
2. Upload ảnh reference (ghi rõ bên dưới mỗi icon)
3. Paste prompt
4. Set **transparent background = ON**, aspect **1:1 (square)**
5. Generate 4 variants → chọn cái đẹp → download PNG

## Style anchor chung (thêm vào MỌI prompt)
```
Art style: Don't Starve Together — hand-drawn ink illustration with a light
watercolor wash, bold 2-3px black ink outlines, soft cel-shading, slightly
gothic Tim Burton-esque silhouette, muted earthy palette with one glowing
accent colour. Centered single object, ~12% padding, transparent background,
no text, no watermark, no frame unless specified. Square 1:1.
```

---

# 1. Đan điền medallion (cảnh giới icon)

**Reference:** `decoded_png/images/level1.png` (hồ lô + lửa trên bệ)
**Kích thước xuất:** 256×256 (sẽ scale nhỏ trong game)

Mỗi nguyên tố 1 màu lửa. Khung tròn + bệ giữ nguyên concept, đổi nội dung hồ lô:

| Element | Prompt phần lửa |
|---|---|
| Kim (Metal) | `a small jade gourd emitting a swirling GOLDEN-WHITE metallic qi flame` |
| Mộc (Wood) | `...emitting a GREEN leafy vine-like qi with tiny floating leaves` |
| Thủy (Water) | `...emitting a flowing BLUE water-qi ribbon` |
| Hỏa (Fire) | `...emitting a fierce CRIMSON-ORANGE flame` |
| Thổ (Earth) | `...emitting a warm AMBER-BROWN earthen glow with floating stone motes` |

Full prompt template:
```
A circular ornate medallion (dark bronze ring with a small jade clasp at top)
containing <gourd+flame description>, resting on a small carved stone pedestal
with a blank nameplate below. Sacred cultivation altar feel. <style anchor>
```

---

# 2. Nội đan (inner pills) — 3 phẩm

**Reference:** `decoded_png/images/inventoryimages/` (bất kỳ gem/pill icon nào)
**Kích thước:** 128×128 (inventory icon)

```
HẠ PHẨM:  A small translucent dark-RED spherical pill resting on a tiny
          ceramic dish, faint crimson energy veins pulsing inside. <style anchor>

TRUNG PHẨM: A SAPPHIRE-BLUE glossy pill, slightly larger, silver energy veins,
            faint mist drifting off, on a gold-rimmed ceramic dish. <style anchor>

THƯỢNG PHẨM: A deep AMETHYST-PURPLE radiant pill with golden inner light and
             tiny lightning sparks, on an ornate jade dish, almost glowing.
             <style anchor>
```

---

# 3. Linh thảo (spirit herbs) — 3 loại

**Reference:** `decoded_png/images/map_icons/xd_flower_*.png` (hoa Dengxian)
**Kích thước:** 128×128

```
TÂM TĨNH HOA: A delicate luminescent white 6-petal flower with a pale-blue
              glowing center and dewdrops, single leafed stem. Soothing,
              phosphorescent. <style anchor>

LINH TIỀN THẢO: Three small round jade-green coin-shaped leaves stacked like
                ancient Chinese coins, with glowing golden veins and thin gold
                filaments on the stem. <style anchor>

HỒNG LIÊN TỬ: A crimson lotus seed-pod with five visible seeds each holding a
              tiny flame, dark bronze-green pod, heat-shimmer rising. <style anchor>
```

---

# 4. Linh mạch huyệt (spirit vein, world entity) — 3 tiers

**Reference:** `decoded_png/images/` UI crystal/altar sprites
**Kích thước:** 256×256 (đặt trên đất trong world)

```
HẠ PHẨM:  A small cluster of pale-blue glowing crystals erupting from mossy
          ground, soft cyan qi vapor drifting up. <style anchor>

TRUNG PHẨM: Larger GOLDEN-YELLOW topaz crystal cluster on a raised stone
            platform engraved with faint Bagua taoist trigrams, amber glow.
            <style anchor>

THƯỢNG PHẨM: Brilliant PINK-MAGENTA prismatic crystals on an ancient jade altar
             with dragon carvings, swirling visible qi. <style anchor>
```

---

# 5. Nhân vật Phàm Nhân (character portrait)

**Reference:** `decoded_png/bigportraits/xd_wangmazi.png`
**Kích thước:** 512×768 (bigportrait) + 256×256 (saveslot)

```
A young Vietnamese mortal cultivator, gender-ambiguous, age ~16, plain dark
indigo hanfu robe with simple white trim, calm determined expression, faint
qi aura at the fingertips. Humble beginnings — no fancy weapons. Half-body
portrait. <style anchor but slightly more detailed for a portrait>
```

---

# 6. Modicon / Workshop preview (512×512)

```
A lone young cultivator meditating cross-legged on a floating rock amid swirling
qi wisps, mist-shrouded mountains and a pale moon behind. Atmospheric, mystical.
Vietnamese brush-calligraphy vibe. Don't Starve hand-drawn ink+watercolor style.
512x512.
```

---

# Sau khi gen xong

Gửi mình các file PNG (qua đường dẫn trên máy). Mình sẽ:
1. Convert PNG → `.tex` (cần ktech — xem docs nếu chưa setup)
2. Tạo `.xml` atlas tương ứng
3. Wire vào `pn_hud_main.lua` / prefab items
4. Cập nhật `MEDALLION_W/H` cho khớp art mới

**Lưu ý bản quyền:** dùng reference để KHỚP STYLE là OK, nhưng output phải là art MỚI (không copy nguyên xi Dengxian). Khi gen, mô tả nội dung khác đi (vd hồ lô khác kiểu, hoa khác loài) để ra sản phẩm gốc.

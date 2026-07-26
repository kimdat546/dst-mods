# Phân tích kiến trúc mod 「登仙」(Dengxian) cho Don't Starve Together

> Tài liệu tham chiếu nội bộ, dùng làm khung sườn cho dự án mod tu tiên / xianxia tự xây.
> Workshop ID: `3235319974` — phiên bản: `18.1` — tác giả: 薪人小黄、路障僵尸、吃不吃大肉丸子.

---

## 1. Tổng quan

### 1.1 Mod là gì

「登仙」(phiên âm: **Dengxian**, nghĩa: "đăng tiên" — bước lên cõi tiên) là một **total conversion mod** cho Don't Starve Together theo phong cách **tu tiên / huyền huyễn Trung Hoa (xianxia)**. Mod thêm:

- **9 nhân vật chơi được**, mỗi nhân vật là một "tiên" / "ma" / "thần" có hệ thống pháp bảo, kỹ năng, UI và cốt truyện riêng:
  - `xd_hantianzun` — Hàn Thiên Tôn (韩天尊)
  - `xd_jingwei` — Tinh Vệ (精卫, nữ điểu thần lấp biển)
  - `xd_longtaizi` — Long Thái Tử (龙太子)
  - `xd_luoshen` — Lạc Thần (洛神)
  - `xd_shiji` — Thạch Cơ (石矶, nữ yêu)
  - `xd_sudaji` — Tô Đát Kỷ (苏妲己, nữ ma)
  - `xd_wangmazi` — Vương Ma Tử (王妈子)
  - `xd_wukong` — Ngộ Không (悟空, Tôn Ngộ Không)
  - `xd_yunxiao` — Vân Tiêu (云霄)
- Hệ thống cảnh giới tu luyện (`xd_level`, `xd_dtlevel`, `xd_worldlevel`).
- Hệ thống đan dược (`xd_danyao`, `xd_liandanlu` — lò luyện đan), linh thạch (`xd_lingshi`), linh bảo (`xd_lingbao`).
- Bộ boss gốc xianxia (Bạch Hổ `xd_baihu`, Côn Bằng `xd_kunpeng`, Roc `xd_roc`, Tiên Hạc `xd_xianhe`, Băng Long `xd_icedragon`, Trụ Vương `xd_zhouwang`, v.v.).
- Bộ phó bản (`xd_fb_*` — 副本 / dungeon) tái thiết kế các boss vanilla DST: Bearger, Deerclops, Dragonfly, Eye of Terror, Stalker, Spider Queen…
- Bộ hệ thống "tăng cường" quái vanilla theo cấp (`xd_moster_qianghua`, `xd_moster_skill`, `xd_moster_shengti_set`, `xd_moster_healthbar`).
- Hệ thống nhà riêng cho người chơi (`xd_playerhouse`, `xd_interiors`, `xd_dockmanager`).
- Hệ thống thú cưng / triệu hồi với leash riêng cho từng loại (7 biến thể của `xd_petleash`).

### 1.2 Quy mô (file & dung lượng)

| Hạng mục | Số lượng / dung lượng |
|---|---|
| Tổng dung lượng mod | **376 MB** |
| `anim/` (file `.zip` build animation) | **647** file, **247 MB** |
| `bigportraits/` | 44 file (22 cặp `.tex`/`.xml`) |
| `images/` (UI / inventory / skill icon) | **90 MB**, 758 file trong `inventoryimages/` |
| `scripts/` | **9.4 MB** (toàn bộ Lua đã bị mã hoá) |
| `sound/` | 3.0 MB |
| `levels/` | 5.4 MB (tile, texture) |
| `fx/` | 992 KB |
| `scripts/prefabs/` | **274** file `.lua` |
| `scripts/components/` | **85** file `.lua` |
| `scripts/stategraphs/` | **69** file `.lua` (`SG…`) |
| `scripts/brains/` | **44** file `.lua` |
| `scripts/widgets/` | **26** file `.lua` |
| `scripts/screens/` | **1** file (`xdbookpopupscreen.lua`) |
| `scripts/main/` | **32** file (lớp bootstrap) |
| `scripts/speech_xd_*.lua` | **9** file (mỗi nhân vật một file lời thoại, plaintext) |
| `daxsg_mod_path.txt` | **532 dòng** — bảng chỉ mục mọi file mà loader đăng ký |

### 1.3 Tình trạng mã hoá

Mod sử dụng **custom loader** (xem `modmain.lua`, `modmain0.lua`, `modmain1.lua`) với cipher 1-byte XOR đơn giản để **mã hoá toàn bộ phần thân (body) của các file Lua** trong `scripts/prefabs/`, `scripts/components/`, `scripts/stategraphs/`, `scripts/brains/`, `scripts/widgets/`, `scripts/screens/`, `scripts/main/`.

**Có thể đọc:**
- `modinfo.lua` — config options + phím tắt.
- `daxsg_mod_path.txt` — danh sách đường dẫn module mà loader đăng ký.
- 9 file `speech_xd_*.lua` (plaintext, để tiện cộng đồng dịch).
- Tên file (filename) của **tất cả** module — vì hệ thống Lua / DST bắt buộc tên file phải khớp tên prefab/component khi register, nên dù body bị mã hoá, **tên file là plaintext và đầy đủ giá trị về mặt kiến trúc**.
- Tên file asset: `anim/*.zip`, `images/**/*.tex`/`*.xml` đều plaintext.

**KHÔNG đọc được:**
- Thân (body) Lua của mọi script trong `scripts/{prefabs,components,stategraphs,brains,widgets,screens,main}/`.

Vì vậy tài liệu này **suy diễn kiến trúc dựa trên quy ước đặt tên + asset + chỉ mục loader**, không trích logic chi tiết.

---

## 2. Quy ước đặt tên

Mod tuân thủ quy ước rất nhất quán. Nắm vững phần này là chìa khoá đọc hiểu phần còn lại.

### 2.1 Tiền tố `xd_`

**Tất cả** prefab/component/stategraph/brain/widget đều dùng tiền tố `xd_`. Đây là **namespace** giúp tách mod khỏi vanilla DST và khỏi các mod khác — tránh đụng tên prefab. (`xd` ban đầu có thể là từ "薪小黄道" / "薪小黄登仙" hoặc viết tắt nội bộ của tác giả 薪人小黄.)

> **Bài học cho mod mới:** Hãy chọn một prefix 2–3 ký tự duy nhất (ví dụ `pn_` cho "Phàm Nhân", hoặc `tt_` cho "Tu Tiên") và áp dụng cho **mọi** prefab/component bạn tạo.

### 2.2 Hậu tố `_fx` — hiệu ứng hình ảnh thuần

Mọi prefab chỉ tồn tại để vẽ hiệu ứng (particle, sparkle, flash) đều có hậu tố `_fx`. Ví dụ:
- `xd_baihu_shadow_fx`, `xd_baihufx`, `xd_swordfx`, `xd_qlch_fx`, `xd_poison_fx`, `xd_sand_spike`, `xd_vortex_fx`, `xd_mutated_fx`, `xd_shengge_fx`, `xd_yumao_fx`, `xd_yumao_goldfx`, `xd_lgg_fx`, `xd_jingwei_zzql` (hậu tố `_zzql` là biến thể).
- `SGxd_weapon_fx.lua` — stategraph riêng cho fx vũ khí.

### 2.3 Hậu tố `_none` — biến thể "trần" / không skin

Có **đúng 9** prefab `xd_*_none` — chính xác bằng số nhân vật:

`xd_hantianzun_none`, `xd_jingwei_none`, `xd_longtaizi_none`, `xd_luoshen_none`, `xd_shiji_none`, `xd_sudaji_none`, `xd_wangmazi_none`, `xd_wukong_none`, `xd_yunxiao_none`.

→ Đây là **phiên bản nhân vật không có skin (base build)**. DST phân biệt `prefab` vs `skin`. `_none` là build mặc định khi người chơi chưa chọn skin, hoặc là build "ghost form" — đối chiếu với asset `anim/ghost_xd_<name>_build.zip` và `bigportraits/xd_<name>_none.tex` xác nhận điều này.

### 2.4 Tiền tố `_fb_` / `xd_fb_` — phó bản (副本, fùběn = instance / dungeon)

Mọi nội dung phó bản dùng hậu tố `fb`:
- `xd_fb_hound`, `xd_fb_jcbird`, `xd_fb_jfsn`, `xd_fb_lavae`, `xd_fb_mutateddeerclops`, `xd_fb_mutatedwarg`, `xd_fb_warg_mutated_fx`.
- Stategraph tương ứng: `SGxd_fb_hound`, `SGxd_fb_jfsn`, `SGxd_fb_lavae`, `SGxd_fb_mutateddeerclops`, `SGxd_fb_mutatedwarg`.

→ Đây là phiên bản "boss/quái phó bản" — thường mạnh hơn, có moveset mới, dùng cho map instance.

### 2.5 Hậu tố `_buff` / `_buffs` / `_debuff`

- `xd_buffs`, `xd_dy_buffs`, `xd_weaponbuffs`, `xd_baihu_buff`, `xd_dms_healthregenbuff`, `xd_luoshen_jihuaze_debuff`.
- Đây là các prefab "trạng thái" (status effect) gắn vào entity để buff/debuff.

### 2.6 Hậu tố `_replica` — phía client

DST tách logic theo server/client. Một component cần truy cập từ client phải có **replica** đi kèm (RPC qua netvar). Trong mod thấy ba cặp rõ ràng:
- `xd_bd` ↔ `xd_bd_replica`
- `xd_damagenumber` ↔ `xd_damagenumber_replica`
- `xd_skillcd` ↔ `xd_skillcd_replica`
- `xd_xuetiao` ↔ `xd_xuetiao_replica`

→ **Quy tắc:** Mỗi component cần đọc giá trị từ UI hoặc input bên client đều phải tạo thêm file `<name>_replica.lua`.

### 2.7 Tiền tố `SG` — stategraph

DST stategraph bắt buộc tên file dạng `SG<prefab>.lua`. Mod tuân thủ tuyệt đối: `SGxd_baihu`, `SGxd_jcbird`, `SGxd_qlch`, … Một số stategraph dùng cho cơ chế phụ (không phải prefab độc lập): `SGxd_weapon_fx`, `SGxd_jingwei_fan_tornado`, `SGqfwjdtornado`.

### 2.8 Tiền tố `xd_moster_` (sic) — hệ thống tăng cường quái

Trong `scripts/main/` có một cụm 6 file dùng tiền tố `xd_moster_` (đánh vần sai chính tả của "monster" — đây là dấu nhận diện rõ ràng của tác giả): `xd_moster_healthbar`, `xd_moster_qianghua`, `xd_moster_shengti_set`, `xd_moster_skill`, `xd_moster_skill_set1`, `xd_moster_skill_set2`. Đây là **lớp patch quái vanilla** để gắn cấp độ, HP bar custom, skill mới.

### 2.9 Bảng từ viết tắt pinyin có thể giải mã

Đây là bảng đối chiếu các viết tắt pinyin xuất hiện nhiều nhất trong tên file. Đã được kiểm chứng chéo qua tên nhân vật / boss / skill icon.

| Viết tắt | Pinyin đầy đủ | Hán tự | Nghĩa Việt | Xuất hiện ở |
|---|---|---|---|---|
| `htz` | Hán Thiên Tôn | 韩天尊 | Hàn Thiên Tôn (nhân vật) | `xd_htz_*`, `xd_hantianzun_*` |
| `wmz` | Wáng Mā Zi | 王妈子 | Vương Ma Tử (nhân vật) | `xd_wmz_*`, `xd_wangmazi_*` |
| `yx` | Yún Xiāo | 云霄 | Vân Tiêu (nhân vật) | `xd_yunxiao_*`, `xd_yumao_*` (lông vũ — pháp bảo của Yunxiao) |
| `sj` | Shí Jī / Shíjī | 石矶 | Thạch Cơ (nhân vật) | `xd_sj_*` |
| `jgb` | Jīn Gū Bàng | 金箍棒 | Gậy Như Ý (vũ khí Ngộ Không) | `xd_jgb`, `xd_wukong_jgb`, `SGxd_jgb_monkey`, `SGxd_jgb_mate` |
| `jfsn` | Jiǔ Fā Shén Niǎo (?) | 九发神鸟 (?) | "Chín đầu thần điểu" — loại boss/quái | `xd_jfsn*`, `SGxd_jfsn` |
| `qlch` | Qí Lín Chī Hóu / Qílín Chìhōng (?) | 麒麟? | Boss kỳ lân | `xd_qlch*`, `SGxd_qlch` |
| `jcbird` | Jīn Chì bird | 金翅鸟 (?) | "Kim Sí Điểu" — Ca Lâu La | `xd_jcbird`, `SGxd_jcbird` |
| `ws` | Wū Shī | 巫师 (?) | Phù thuỷ shadow | `xd_ws`, `xd_ws_wizard_fx` |
| `dms` | Dī Mài Shén (?) | — | Trạng thái hồi máu | `xd_dms_healthregenbuff` |
| `lq` | Líng Qì | 灵气 | Linh khí (resource) | `xd_htz_lq` (component), `status_xd_htz_lq.zip` |
| `lj` | Líng Jī | 灵集 / 灵机 | Linh tập / Linh cơ | `xd_lingji` (component) |
| `cl` | Chōng Líng (?) | — | — | `xd_cl` |
| `dy` | Dān Yào | 丹药 | Đan dược | `xd_danyao*`, `xd_dy_buffs` |
| `bd` | Bù Dāo / Bàn Dào (?) | — | Component cốt lõi nhân vật | `xd_bd`, `xd_bd_replica` |
| `cdk` | Cool Down Key | — | Phím tắt + đếm cooldown | `xd_cdkui` |
| `ftj` | Fēi Tiān Jiàn (?) | 飞天剑 | "Phi Thiên Kiếm" | `xd_ftj` |
| `qy` | Qīng Yú (?) | — | Một loại pet | `xd_qy`, `xd_petleash_qy` |
| `cy` | Cāng Yú / Chī Yú (?) | — | Pet/minion của Shiji | `xd_sj_cy`, `xd_petleash_cy`, `SGxd_sj_cy` |
| `by` | Bái Yīng / Bái Yáo (?) | — | Pet/minion của Shiji | `xd_sj_by`, `xd_by_container`, `xd_byspui`, `SGxd_sj_by` |
| `cwkj` | Cún Wù Kōng Jiān | 存物空间 | "Kho chứa vật phẩm" | `xd_cwkj`, `xd_cwkj_container` |
| `cjj` | Chōu Jiǎng Jī | 抽奖机 | "Máy quay xổ số" | `xd_choujiangji`, `xd_cjjspwner`, `xd_choujiang_creature` |
| `dsmo` | Dài Shǒu Mó (?) | — | Boss / cánh tay Mộc Ma | `xd_wukong_dsmo` |
| `tnz` | — | — | Pháp bảo WMZ | `xd_wmz_tnz` |
| `tlz` | Tài Liè Zhū (?) | — | Pháp bảo HTZ | `xd_htz_tlz` |
| `ztp` | Zhuó Tǎ Pái (?) | — | Pháp bảo HTZ | `xd_htz_ztp`, `xd_ztp` |
| `sjcx` | Shī Jiè Chuān Xíng (?) | — | "Thi giải xuyên hình" | `xd_htz_sjcx`, `SGxd_htz_sjc` |
| `xyzz` | Xià Yú Zhèn Záng (?) | — | Skill HTZ | `xd_htz_xyzz` |
| `qzj` | Qián Zǒu Jiàn (?) | — | Pháp bảo HTZ | `xd_htz_qzj` |
| `xtzlj` | Xiān Tiān Zhū Líng Jiàn (?) | — | Pháp bảo HTZ | `xd_htz_xtzlj` |
| `pn` | Pó Niáng / Bà Niáng (?) | — | Pháp bảo WMZ | `xd_sudaji_sjpn`, `xd_sjpn_container` |
| `zzxhcx` | — | — | Pháp bảo (chưa rõ) | `xd_zzxhcx` |
| `qfwjd` | Qí Fēng Wàn Jié Dāo (?) | 起风万劫刀? | "Khởi Phong Vạn Kiếp Đao" | `xd_qfwjd`, `SGqfwjdtornado` |
| `qxdx` | Qī Xīng Dòu Xiá (?) | — | NPC/shop bán đồ | `xd_qxdx`, `xd_qxdxspwner`, `xd_qxdx_shopui`, `SGxd_qxdx` |
| `kls` | Kǒu Lǎo Shǔ (?) | — | Pháp bảo SJ | `xd_sj_kls` |
| `sxz` | Shén Xīng Zhǔ (?) | — | Pháp bảo SJ | `xd_sj_sxz` |
| `tej` | Tóu Èr Jiàn (?) | — | Pháp bảo SJ | `xd_sj_tej` |
| `tlsq` | Tóng Lǐng Sōng Què (?) | — | Pháp bảo SJ | `xd_sj_tlsq` |
| `xsydz` | Xǐ Sǔn Yù Dé Zhū (?) | — | Pháp bảo SJ | `xd_sj_xsydz` |
| `bglxp` | Bā Guà Liú Xīng Pán (?) | 八卦流星盘 | "Bát Quái Lưu Tinh Bàn" | `xd_sj_bglxp` |
| `bgygp` | Bā Guà Yīn Yáng Pán (?) | 八卦阴阳盘 | "Bát Quái Âm Dương Bàn" | `xd_sj_bgygp` |
| `pysk` | Pī Yǐ Shén Kē (?) | — | Stategraph SJ | `SGxd_sj_pysk` |
| `jjj` | Jīn Jīng Jiàn (?) | — | Pháp bảo Yunxiao | `xd_yunxiao_jjj` |
| `fls` | Fēi Líng Suō (?) | 飞灵梭? | "Phi Linh Toa" | `xd_yunxiao_fls` |
| `fysz` | Fú Yīn Shén Zhì (?) | — | Pháp bảo Yunxiao | `xd_yunxiao_fysz` |
| `fgfq` | Fēng Gǔ Fēng Qí (?) | — | Pháp bảo Yunxiao | `xd_yunxiao_fgfq` |
| `hyjd` | Hùn Yuán Jīn Dǒu | 混元金斗 | "Hỗn Nguyên Kim Đẩu" (pháp bảo Vân Tiêu) | `xd_yunxiao_hyjd` |
| `ymsz` | Yún Mā Shén Zhū (?) | — | Pháp bảo Yunxiao | `xd_yunxiao_ymsz` |
| `hytxtele` | Hùn Yuán Tiān Xí Tele | — | Teleport bằng Hỗn Nguyên | `xd_yunxiao_hytxtele` |
| `krss` | Kāi Rì Shén Shù (?) | — | Pháp bảo Luoshen | `xd_luoshen_krss` |
| `mxrg` | — | — | Pet/minion Sudaji | `xd_sudaji_mxrg`, `xd_petleash_mxrg` |
| `tsmd` | Tiān Shī Mó Đẳo (?) | — | Pháp bảo Sudaji | `xd_sudaji_tsmd` |
| `xyj` | Xiāng Yìn Jué (?) | — | Pháp bảo Sudaji | `xd_sudaji_xyj` |
| `yhly` | Yāo Hú Lǐ Yuán (?) | — | Pháp bảo Sudaji | `xd_sudaji_yhly` |
| `ywfh` | Yāo Wáng Fù Huà (?) | — | Pháp bảo Sudaji | `xd_sudaji_ywfh` |
| `sjpn` | Shén Jī Pó Niáng (?) | — | Pháp bảo Sudaji | `xd_sudaji_sjpn` |
| `db` | Diāo Bàng (?) | — | Pháp bảo WMZ | `xd_wmz_db` |
| `kjb` | — | — | Pháp bảo WMZ | `xd_wmz_kjb` |
| `md` | Mó Đǎo (?) | — | Pháp bảo WMZ | `xd_wmz_md`, `SGxd_wmz_md` |
| `slxj` | Sān Liù Xiá Jiàn (?) | — | Pháp bảo WMZ | `xd_wmz_slxj` |
| `xsj` | Xián Sūn Jiàn (?) | — | Pháp bảo WMZ | `xd_wmz_xsj` |
| `zhf` | Zhū Hóng Fú (?) | — | Pháp bảo WMZ | `xd_wmz_zhf`, `xd_zhf`, `SGxd_wmz_zhf_soul` |
| `dock` | (English) | — | Bến tàu / dock cho map ocean | `xd_dock_damage`, `xd_dockmanager` |
| `fb` | Fù Běn | 副本 | "Phó bản" / dungeon | `xd_fb_*` |
| `dtwq` | Dòu Tiān Wǔ Qí (?) | — | FX | `xd_dtwqfx` |
| `wxj` | Wàn Xiè Jiàn (?) | — | Vũ khí | `xd_wxj` |
| `xjs` | Xié Jīng Shé (?) | — | Boss / pet | `xd_xjs`, `xd_xjs_curve_fx`, `SGxd_xjspuppet`, `SGxd_xjstentacle` |
| `swhs` | Shén Wǔ Hóu Shǔ (?) | — | Quái | `xd_swhs`, `SGxd_swhs` |
| `mglz` | — | — | Quái / pet | `xd_mglz` |
| `klxw` | Kǔ Líng Xiān Wǔ (?) | — | Boss / pet | `xd_klxw` |
| `lbjlt` | — | — | Vật phẩm | `xd_lbjlt` |
| `lbx` | Líng Bǎo Xiāng | 灵宝箱 | "Linh Bảo Tương" (rương) | `xd_lbx`, `xd_llbx`, `xd_llbx_container` |
| `llbx` | — | — | — | `xd_llbx`, `xd_llbx_container` |
| `gcsz` | — | — | Vật phẩm | `xd_gcsz` |
| `fxs` | Fēi Xiá Shù (?) | — | Vật phẩm | `xd_fxs` |
| `pflnw` | — | — | Vật phẩm | `xd_pflnw` |
| `pog` | (English: pet? POG) | — | Pet (giống loại POG vanilla) | `xd_pog`, `SGxd_pog`, `xd_pogbrain` |

> **Lưu ý:** Các viết tắt có dấu `(?)` là phỏng đoán pinyin gần đúng — chỉ có thể xác nhận chính xác khi đọc được body Lua hoặc đối chiếu UI in-game.

---

## 3. Bản đồ 9 nhân vật

Mỗi nhân vật là một "slice" hoàn chỉnh: prefab nhân vật + prefab pháp bảo riêng + brain/SG cho pet riêng + widget UI riêng + asset anim riêng. Dưới đây là bản đồ chi tiết — đây cũng chính là khuôn mẫu cần học để dựng nhân vật của riêng bạn.

### 3.1 `xd_hantianzun` — Hàn Thiên Tôn (HTZ)

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_hantianzun.lua`, `xd_hantianzun_none.lua` |
| Pháp bảo / skill | `xd_htz_firefx.lua`, `xd_htz_fjfb.lua`, `xd_htz_qzj.lua`, `xd_htz_sjcx.lua`, `xd_htz_spell.lua`, `xd_htz_tlz.lua`, `xd_htz_xtzlj.lua`, `xd_htz_xyzz.lua`, `xd_htz_ztp.lua`, `xd_ztp.lua` |
| Component riêng | `xd_htz_lq.lua` (linh khí), `xd_htz_sword_controller.lua` |
| Stategraph riêng | `SGxd_htz_sjc.lua` |
| Brain riêng | `xd_htbrains.lua` |
| Widget UI | `xd_hantianzunui.lua`, `xd_hantianzun_skillui.lua` |
| Speech | `speech_xd_hantianzun.lua` |
| Anim/asset | `ghost_xd_hantianzun_build.zip`, `status_xd_htz_lq.zip`, `bigportraits/xd_hantianzun{,_none}.tex`, `images/saveslot_portraits/xd_hantianzun.tex`, `images/avatars/avatar*_xd_hantianzun.tex`, `images/skills/xd_htz_skillicon.tex`, `images/names_xd_hantianzun.tex` |

### 3.2 `xd_jingwei` — Tinh Vệ

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_jingwei.lua`, `xd_jingwei_none.lua` |
| Pháp bảo / vũ khí | `xd_jingwei_blowdart.lua`, `xd_jingwei_fan.lua`, `xd_jingwei_fenice.lua`, `xd_jingwei_hat.lua`, `xd_jingwei_zzql.lua` |
| Component riêng | `xd_jingwei_pet.lua`, `xd_petleash_fly.lua` (?) |
| Stategraph riêng | `SGxd_jingwei_fan_tornado.lua`, `SGxd_jingwei_fenice1.lua`, `SGxd_jingwei_fenice3.lua`, `SGxd_jingwei_fenice4.lua`, `SGxd_icebutterfly.lua` (?) |
| Brain riêng | `xd_jingwei_fan_tornadobrain.lua`, `xd_jingwei_fenicebrain.lua`, `xd_jingwei_fenice4brain.lua` |
| Widget UI | (dùng chung) |
| Speech | `speech_xd_jingwei.lua` |
| Anim/asset | `ghost_xd_jingwei_build.zip`, `ui_xd_jingwei_fenice_3x3.zip`, `bigportraits/xd_jingwei{,_none}.tex`, tile riêng `levels/tiles/xd_jingwei_tile.tex` + `mini_xd_jingwei_tile.tex` (Tinh Vệ có biome riêng) |

### 3.3 `xd_longtaizi` — Long Thái Tử

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_longtaizi.lua`, `xd_longtaizi_none.lua` |
| Pháp bảo / vũ khí | `xd_longzhu.lua` (Long Châu — pháp bảo cốt lõi), `xd_sword.lua` (?) |
| Component riêng | (chia sẻ với hệ thống chung) |
| Stategraph riêng | (chưa thấy SG dành riêng) |
| Brain riêng | (chưa thấy) |
| Widget UI | (chưa có widget riêng tên longtaizi — có thể dùng UI chung) |
| Speech | `speech_xd_longtaizi.lua` |
| Anim/asset | `ghost_xd_longtaizi_build.zip`, `bigportraits/xd_longtaizi{,_none,_hysj}.tex` — có thêm form **`hysj`** (Hí Yú Shén Jí?), nhân vật có 2 form transformation |

> **Lưu ý:** Long Thái Tử có vẻ là nhân vật "nhẹ" nhất — ít file nhất, có thể chỉ là class chiến binh có buff thuỷ tính dùng `xd_longzhu` làm pháp bảo chính.

### 3.4 `xd_luoshen` — Lạc Thần

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_luoshen.lua`, `xd_luoshen_none.lua` |
| Pháp bảo / skill | `xd_luoshen_flower.lua`, `xd_luoshen_items.lua`, `xd_luoshen_jihuaze_debuff.lua`, `xd_luoshen_krss.lua`, `xd_luoshen_shentong_fx.lua` |
| Stategraph riêng | `SGxd_luoshenzhu_vine.lua` |
| Brain riêng | (chưa thấy) |
| Phụ trợ | `fence_luoshen.zip`, `fence_gate_luoshen.zip`, `wall_luoshen.zip` (Luoshen có set tường/rào riêng) |
| Widget UI | (dùng chung) |
| Speech | `speech_xd_luoshen.lua` |
| Anim/asset | `ghost_xd_luoshen_build.zip`, `bigportraits/xd_luoshen{,_none}.tex`, `images/skills/xd_luoshen_shentong_death_hit.tex`, `xd_luoshen_shentong_life_hit.tex` (skill có 2 phiên bản: tử/sinh) |

### 3.5 `xd_shiji` — Thạch Cơ

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_shiji.lua`, `xd_shiji_none.lua` |
| Pháp bảo (loạt `sj_*`) | `xd_sj_bglxp.lua` (Bát Quái Lưu Tinh Bàn), `xd_sj_bgygp.lua` (Bát Quái Âm Dương Bàn), `xd_sj_by.lua`, `xd_sj_cy.lua`, `xd_sj_kls.lua`, `xd_sj_sxz.lua`, `xd_sj_tej.lua`, `xd_sj_tlsq.lua`, `xd_sj_xsydz.lua` |
| Component riêng | `xd_by_container.lua`, `xd_petleash_cy.lua` (Shiji có 2 loại pet `by` và `cy`) |
| Stategraph riêng | `SGxd_sj_by.lua`, `SGxd_sj_cy.lua`, `SGxd_sj_pysk.lua` |
| Brain riêng | `xd_sj_bybrain.lua`, `xd_sj_cybrain.lua` |
| Widget UI | `xd_shijiui.lua`, `xd_byspui.lua` |
| Speech | `speech_xd_shiji.lua` |
| Anim/asset | `ghost_xd_shiji_build.zip`, `bigportraits/xd_shiji{,_none}.tex` |

### 3.6 `xd_sudaji` — Tô Đát Kỷ

Đây là nhân vật **phức tạp nhất**, có form chuyển đổi (`qrsy` / `wcgz`) và hệ "linh hồn" (soul) riêng:

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_sudaji.lua`, `xd_sudaji_none.lua` |
| Pháp bảo / item | `xd_sudaji_fx.lua`, `xd_sudaji_mxrg.lua`, `xd_sudaji_redlantern.lua`, `xd_sudaji_sjpn.lua`, `xd_sudaji_soul_spawn.lua`, `xd_sudaji_soul.lua`, `xd_sudaji_tsmd.lua`, `xd_sudaji_xyj.lua`, `xd_sudaji_yhly.lua`, `xd_sudaji_ywfh.lua` |
| Component riêng | `xd_sudaji_controller.lua`, `xd_sjpn_container.lua`, `xd_petleash_mxrg.lua` |
| Stategraph riêng | `SGxd_sudaji_rotatefire.lua` |
| Brain riêng | (dùng `xd_minionbrain.lua` cho soul minion) |
| Widget UI | (chưa thấy widget riêng tên sudaji — có thể dùng UI chung) |
| Speech | `speech_xd_sudaji.lua` |
| Anim/asset | `ghost_xd_sudaji_build.zip`, `bigportraits/xd_sudaji{,_none,_qrsy,_wcgz}.tex` (có **3 form** ngoài form none), `swap_xd_sudaji_redlantern{,_zyx}.zip` |

### 3.7 `xd_wangmazi` — Vương Ma Tử

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_wangmazi.lua`, `xd_wangmazi_none.lua` |
| Pháp bảo (loạt `wmz_*`) | `xd_wmz_butterfly.lua`, `xd_wmz_db.lua`, `xd_wmz_kjb.lua`, `xd_wmz_md.lua`, `xd_wmz_slxj.lua`, `xd_wmz_spell.lua`, `xd_wmz_tnz.lua`, `xd_wmz_xsj.lua`, `xd_wmz_zhf.lua`, `xd_zhf.lua` |
| Stategraph riêng | `SGxd_wmz_md.lua`, `SGxd_wmz_zhf_soul.lua` |
| Brain riêng | `xd_wmzsoulbrain.lua` |
| Widget UI | `xd_wmz_skillui.lua` |
| Speech | `speech_xd_wangmazi.lua` |
| Anim/asset | `ghost_xd_wangmazi_build.zip`, `bigportraits/xd_wangmazi{,_none}.tex`, `images/skills/xd_wmz_skillicon.tex` |

### 3.8 `xd_wukong` — Tôn Ngộ Không

Đây là nhân vật **đặc biệt** — có thể tắt qua config `set6` (xem `modinfo.lua`), có cơ chế "biến hoá 72 phép" (`xd_72bian`), và là nhân vật duy nhất có cả file `main/wukong_skill.lua` riêng song song với `main/wilson_skill.lua`:

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_wukong.lua`, `xd_wukong_none.lua` |
| Pháp bảo / biến hoá | `xd_72bian.lua`, `xd_jgb.lua` (Như Ý Kim Cô Bổng), `xd_wukong_jgb.lua`, `xd_wukong_dsmo.lua`, `xd_wukong_shadow.lua`, `xd_wukong_breath_fx.lua`, `xd_wukong_moose_fx.lua` |
| Component riêng | `xd_wukong_skill.lua` |
| Stategraph riêng | `SGxd_jgb_mate.lua`, `SGxd_jgb_monkey.lua` |
| Brain riêng | (dùng chung) |
| Widget UI | `xd_wukong_skillui.lua`, `xd_wukonglequi.lua` |
| Bootstrap riêng | `scripts/main/wukong_skill.lua` |
| Config option | `set6` (bật/tắt), `wukongkey` (phím biến hoá, default R) |
| Speech | `speech_xd_wukong.lua` |
| Anim/asset | `ghost_xd_wukong_build.zip`, `bigportraits/xd_wukong{,_none,_ds}.tex` (có thêm form `ds` — "ác thần"), `images/skills/xd_wukong_bsicons.tex` |

### 3.9 `xd_yunxiao` — Vân Tiêu

| Loại | File |
|---|---|
| Prefab nhân vật | `xd_yunxiao.lua`, `xd_yunxiao_none.lua` |
| Pháp bảo (loạt `yunxiao_*`) | `xd_yunxiao_fgfq.lua`, `xd_yunxiao_fls.lua`, `xd_yunxiao_fysz.lua`, `xd_yunxiao_hyjd.lua` (Hỗn Nguyên Kim Đẩu), `xd_yunxiao_jjj.lua`, `xd_yunxiao_ymsz.lua`, `xd_yunxiao_portable_spicer.lua`, `xd_yunxiao_tooler.lua` |
| Lông vũ FX | `xd_yumao_fx.lua`, `xd_yumao_goldfx.lua`, `xd_yumao_jydmfx.lua`, `xd_yumao_wxshlfx.lua` |
| Component riêng | `xd_yunxiao_battleborn.lua`, `xd_yunxiao_hytxtele.lua` |
| Stategraph riêng | `SGxd_yunxiao_tooler.lua` |
| Brain riêng | `xd_yunxiao_toolerbrain.lua` |
| Widget UI | `xd_yunxiao_battleborn.lua` (cùng tên với component — DST cho phép), `xd_yunxiaoqui.lua`, `xd_hyyqdui.lua` (?) |
| Speech | `speech_xd_yunxiao.lua` |
| Anim/asset | `ghost_xd_yunxiao_build.zip`, `bigportraits/xd_yunxiao{,_none}.tex`, `status_xd_yunxiao_battleborn.zip` |

### 3.10 So sánh độ phức tạp 9 nhân vật

| Nhân vật | Số prefab pháp bảo | SG riêng | Brain riêng | Widget riêng | Bigportrait form | Mức độ phức tạp |
|---|---|---|---|---|---|---|
| Hantianzun (HTZ) | 9 | 1 | 1 | 2 | 2 (`none`, default) | Cao |
| Jingwei | 5 | 5 | 3 | 0 | 2 | Cao (có biome riêng) |
| Longtaizi | ~1 | 0 | 0 | 0 | 3 (`none`, default, `hysj`) | Thấp |
| Luoshen | 5 | 1 | 0 | 0 | 2 | Trung |
| Shiji | 9 | 3 | 2 | 2 | 2 | Cao |
| Sudaji | 10 | 1 | 0 | 0 | 4 (`none`, default, `qrsy`, `wcgz`) | Cao nhất (3 form) |
| Wangmazi | 10 | 2 | 1 | 1 | 2 | Cao |
| Wukong | 7 | 2 | 0 | 2 | 3 (`none`, default, `ds`) | Cao (có 72 phép) |
| Yunxiao | 8 + 4 fx | 1 | 1 | 3 | 2 | Cao |

→ Khuôn mẫu phổ biến: **~5–10 prefab pháp bảo / nhân vật, 1–3 stategraph riêng, 1–3 widget UI riêng**.

---

## 4. Phân loại 274 prefab

Tổng cộng có **274** prefab trong `scripts/prefabs/`. Phân loại như sau:

### 4.1 Nhân vật (18 prefab)

9 nhân vật chính + 9 biến thể `_none` (build không skin):

`xd_hantianzun`, `xd_hantianzun_none`, `xd_jingwei`, `xd_jingwei_none`, `xd_longtaizi`, `xd_longtaizi_none`, `xd_luoshen`, `xd_luoshen_none`, `xd_shiji`, `xd_shiji_none`, `xd_sudaji`, `xd_sudaji_none`, `xd_wangmazi`, `xd_wangmazi_none`, `xd_wukong`, `xd_wukong_none`, `xd_yunxiao`, `xd_yunxiao_none`.

### 4.2 Pháp bảo / vũ khí (~60 prefab)

#### 4.2.1 Vũ khí kiếm / đao tổng quát
- `xd_sword`, `xd_swordfx`, `xd_ziyunswordfx`, `xd_jgb` (Như Ý), `xd_jgb` (xem mục Wukong), `xd_wxj`, `xd_qfwjd` (Khởi Phong Vạn Kiếp Đao), `xd_ftj` (Phi Thiên Kiếm), `xd_xhwyj`, `xd_hyf` (?), `xd_wyj`.

#### 4.2.2 Pháp bảo Hantianzun (10)
`xd_htz_firefx`, `xd_htz_fjfb`, `xd_htz_qzj`, `xd_htz_sjcx`, `xd_htz_spell`, `xd_htz_tlz`, `xd_htz_xtzlj`, `xd_htz_xyzz`, `xd_htz_ztp`, `xd_ztp`.

#### 4.2.3 Pháp bảo Jingwei (5)
`xd_jingwei_blowdart`, `xd_jingwei_fan`, `xd_jingwei_fenice`, `xd_jingwei_hat`, `xd_jingwei_zzql`.

#### 4.2.4 Pháp bảo Luoshen (4)
`xd_luoshen_flower`, `xd_luoshen_items`, `xd_luoshen_krss`, `xd_luoshen_jihuaze_debuff`.

#### 4.2.5 Pháp bảo Shiji (9 — bộ `xd_sj_*`)
`xd_sj_bglxp`, `xd_sj_bgygp`, `xd_sj_by`, `xd_sj_cy`, `xd_sj_kls`, `xd_sj_sxz`, `xd_sj_tej`, `xd_sj_tlsq`, `xd_sj_xsydz`.

#### 4.2.6 Pháp bảo Sudaji (10)
`xd_sudaji_fx`, `xd_sudaji_mxrg`, `xd_sudaji_redlantern`, `xd_sudaji_sjpn`, `xd_sudaji_soul`, `xd_sudaji_soul_spawn`, `xd_sudaji_tsmd`, `xd_sudaji_xyj`, `xd_sudaji_yhly`, `xd_sudaji_ywfh`.

#### 4.2.7 Pháp bảo Wangmazi (10)
`xd_wmz_butterfly`, `xd_wmz_db`, `xd_wmz_kjb`, `xd_wmz_md`, `xd_wmz_slxj`, `xd_wmz_spell`, `xd_wmz_tnz`, `xd_wmz_xsj`, `xd_wmz_zhf`, `xd_zhf`.

#### 4.2.8 Pháp bảo Wukong (3)
`xd_72bian`, `xd_wukong_jgb`, `xd_wukong_dsmo`.

#### 4.2.9 Pháp bảo Yunxiao (8)
`xd_yunxiao_fgfq`, `xd_yunxiao_fls`, `xd_yunxiao_fysz`, `xd_yunxiao_hyjd`, `xd_yunxiao_jjj`, `xd_yunxiao_portable_spicer`, `xd_yunxiao_tooler`, `xd_yunxiao_ymsz`.

### 4.3 Đan dược / linh thạch / luyện đan (~12)

- `xd_danyao`, `xd_danyao_new`, `xd_danyao_items`, `xd_dy_buffs`.
- `xd_lingshi` — linh thạch (resource cốt lõi).
- `xd_liandanlu` — lò luyện đan (luyện đan).
- `xd_jitan`, `xd_jitan_antlion_sinkhole` — tế đàn.
- `xd_jl`, `xd_jilianmanager` (component — xem mục 5).
- `xd_tianji_items`, `xd_tianjiwu` — vật phẩm Thiên Cơ.

### 4.4 Thú cưng / triệu hồi (~20)

#### 4.4.1 Pet "chung" (chia sẻ giữa các nhân vật)
- `xd_minions`, `xd_fubenminions`, `xd_ziyunminions` — set minion sinh trong phó bản / boss tử vân.
- `xd_pet_level` (component).
- `xd_soul_common`, `xd_soul_wolf`, `xd_sudaji_soul`, `xd_wmz_zhf` (soul) — hệ thống "hồn" minion.

#### 4.4.2 Pet đặc thù
- `xd_jingwei_fenice` (chim của Tinh Vệ).
- `xd_sj_by`, `xd_sj_cy` (Shiji).
- `xd_sudaji_mxrg` (Sudaji).
- `xd_wmz_butterfly`, `xd_wmz_tnz` (Wangmazi).
- `xd_pog` — pet kiểu POG (gợi nhớ DLC vanilla).
- `xd_icebutterfly` — bướm băng.
- `xd_qy`, `xd_xinmo` — pet với leash riêng (`xd_petleash_qy`, `xd_petleash_xinmo`).

### 4.5 Boss & quái

#### 4.5.1 Boss tu sửa từ boss vanilla DST (10)
| Prefab mod | Boss vanilla tương ứng |
|---|---|
| `xd_bearger` | Bearger |
| `xd_deerclops_ziyun` | Deerclops (form "Tử Vân") |
| `xd_dragonfly` | Dragonfly |
| `xd_eyeofterror` | Eye of Terror |
| `xd_stalke`, `xd_stalke_ziyun`, `xd_stalke_fuben` | Ancient Fuelweaver (3 biến thể!) |
| `xd_spiderqueen`, `xd_shadowspiderqueen` | Spider Queen + bóng |
| `xd_ziyunwarg` | Varg "Tử Vân" |
| `xd_zhouwang` (?) | Có thể là phiên bản custom của Crab King / boss vanilla |

#### 4.5.2 Boss gốc xianxia (~15)
- `xd_baihu` (Bạch Hổ) + `xd_baihu_buff`, `xd_baihu_shadow_fx`, `xd_baihufx`.
- `xd_jcbird` (Kim Sí Điểu / Ca Lâu La).
- `xd_jfsn` (cửu phát thần điểu?) + `xd_jfsn_fire`, `xd_jfsnmeteor`.
- `xd_roc`, `xd_roc_leg` (Đại Bằng Điểu).
- `xd_xianhe` (Tiên Hạc).
- `xd_qlch` (kỳ lân?) + `xd_qlch_cloud`, `xd_qlch_fx`.
- `xd_icedragon` (Băng Long).
- `xd_zhouwang` (Trụ Vương) + `xd_zhouwang_shadow`.
- `xd_ziyunboss`, `xd_ziyunjfsn`, `xd_ziyunge`.
- `xd_kunpeng_shadow` — Côn Bằng (boss, spawn qua `xd_kunpengspawner`).
- `xd_xjs` — boss tentacle phù thuỷ.
- `xd_swhs`.

#### 4.5.3 Quái nhỏ / npc / mob vanilla được "xd hoá" (~25)
`xd_beefalo`, `xd_koalefant`, `xd_lightninggoat`, `xd_merm`, `xd_spider`, `xd_spiderden`, `xd_spiderqueen_cloud`, `xd_wickerbottom` (NPC?), `xd_ws`, `xd_ws_wizard_fx`, `xd_shadow_bishop`, `xd_shadowmeteor`, `xd_shadowmonster`, `xd_shadowspider_fx`, `xd_gestalt`, `xd_qxdx` (NPC shop), `xd_zuichunyan`, `xd_aoeent`, `xd_gongdeshadow`, `xd_ds_entity`, `xd_dbg`, `xd_klxw`, `xd_mglz`, `xd_ftys`, `xd_ylxc`, `xd_lhwdc`, `xd_mr`, `xd_nl`, `xd_sly`, `xd_hjjm`, `xd_xtbh`.

### 4.6 Dungeon / phó bản (~12)

- Quái phó bản (`fb`): `xd_fb_hound`, `xd_fb_jcbird`, `xd_fb_jfsn`, `xd_fb_lavae`, `xd_fb_mutateddeerclops`, `xd_fb_mutatedwarg`, `xd_fb_warg_mutated_fx`, `xd_stalke_fuben`.
- Cấu trúc dungeon: `xd_door_exit` (cửa ra), `xd_interiors` (phòng instance), `xd_dock_damage`, `xd_sinkhole`, `xd_jitan_antlion_sinkhole`.
- Nhà người chơi: `xd_playerhouse` (xem component cùng tên).

### 4.7 Container / nội thất (~15)

- Container: `xd_cangku` (kho), `xd_cwkj_container`, `xd_he_container`, `xd_llbx` (Linh Bảo Tương), `xd_lbx`, `xd_lbjlt`, `xd_choujiangji` (máy quay xổ số).
- Nội thất: `xd_chairs`, `xd_fence`, `xd_walls`, `xd_floor`, `xd_lights`, `xd_huapen` (chậu hoa), `xd_futu` (?), `xd_jl`, `xd_jitan` (tế đàn).
- Phương tiện / điểm: `xd_planted_tree`, `xd_qianyu`, `xd_zcmj`.

### 4.8 Thực phẩm / tài nguyên (~15)

- `xd_foods`, `xd_veggie`, `xd_plant`, `xd_flowers`, `xd_trees`, `xd_rocks`, `xd_rock_basalt`, `xd_deciduous_root`, `xd_shatangshu` (cây đường), `xd_yhsyz`.
- Animal/spawn: `xd_fanhunshu`, `xd_fsct`, `xd_gjx`, `xd_ht`, `xd_hyc`, `xd_lycx`, `xd_qwsk`, `xd_mg`, `xd_ylxq`, `xd_pflnw`.

### 4.9 FX / hiệu ứng (~30)

`xd_acidsmoke`, `xd_baihufx`, `xd_baihu_shadow_fx`, `xd_dtwqfx`, `xd_flamethrower_fx`, `xd_guaiwu_sporecloud`, `xd_guaiwumushroombomb`, `xd_guaiwumushroomsprout`, `xd_guaiwusporebomb`, `xd_htz_firefx`, `xd_ice_fx`, `xd_jingwei_fenice` (?), `xd_kunpeng_shadow`, `xd_laser`, `xd_laser_ring`, `xd_lgg_fx`, `xd_lgzbh`, `xd_lightning`, `xd_luoshen_shentong_fx`, `xd_mutated_fx`, `xd_poison_fx`, `xd_qlch_cloud`, `xd_qlch_fx`, `xd_sand_spike`, `xd_shadowspider_fx`, `xd_sharp_fx`, `xd_shengge_fx`, `xd_skin_hyys_fx`, `xd_stmeteor`, `xd_sudaji_fx`, `xd_swordfx`, `xd_vortex_fx`, `xd_ws_wizard_fx`, `xd_xjs_curve_fx`, `xd_yumao_fx`, `xd_yumao_goldfx`, `xd_yumao_jydmfx`, `xd_yumao_wxshlfx`, `xd_ziyunswordfx`.

### 4.10 Vật phẩm / items thông thường (~15)

- `xd_items`, `xd_itemskin_prefabs` — items + reskin items.
- `xd_back_xh` — backpack riêng.
- `xd_infobook` — sách thông tin (hệ thống wiki in-game).
- `xd_fj`, `xd_gcsz`, `xd_fxs`, `xd_xjcgd`, `xd_xshj`, `xd_xcdf`, `xd_zzxhcx`, `xd_swhs`, `xd_xlj`, `xd_qy`, `xd_xinmo`.
- `xd_back_xh` (extra back) — gắn với option `set00` (4 hoặc 5 ô bag).

### 4.11 Khác / không phân loại được (~10)

`xd_bjms`, `xd_bjms_kl`, `xd_bjsj`, `xd_bysp`, `xd_cl`, `xd_choujiangji`, `xd_hhlmz`, `xd_hmsw`, `xd_buffs`, `xd_weaponbuffs`, `xd_dms_healthregenbuff`, `xd_dock_damage`, `xd_qxdx` (NPC shop), `xd_pog`, `xd_72bian`.

### 4.12 Bảng tóm tắt số lượng

| Phân loại | Số prefab |
|---|---|
| Nhân vật (kể cả `_none`) | 18 |
| Pháp bảo / vũ khí | ~60 |
| Đan dược / linh thạch | ~12 |
| Pet / triệu hồi | ~20 |
| Boss / quái (mod sửa vanilla) | ~10 |
| Boss xianxia gốc | ~15 |
| Quái phụ / NPC | ~25 |
| Phó bản | ~12 |
| Container / nội thất | ~15 |
| Tài nguyên / cây / con | ~15 |
| FX | ~30 |
| Vật phẩm thông thường | ~15 |
| Khác | ~10 |
| **Tổng (xấp xỉ)** | **~257** (chênh ~17 do prefab nằm trùng nhiều nhóm) |

---

## 5. Phân loại 85 components

Component là **hệ thống logic** gắn vào entity. Mod có 85 component custom. Phân chia theo chức năng:

### 5.1 Hệ thống tu luyện / cấp độ (8)

| Component | Vai trò suy diễn |
|---|---|
| `xd_level` | Cấp độ cảnh giới (chính) của người chơi |
| `xd_dtlevel` | Cấp độ "đại đạo" / phụ trợ |
| `xd_worldlevel` | Cấp độ chung của thế giới (ảnh hưởng spawn rate, độ khó) |
| `xd_worldlevel_old` | Phiên bản cũ — giữ để backward compatible |
| `xd_savelevel` | Lưu/khôi phục cấp độ qua save |
| `xd_pet_level` | Cấp độ riêng cho thú cưng |
| `xd_armor_levelup` | Hệ thống nâng cấp giáp |
| `xd_armor_levelupitem` | Vật phẩm dùng để nâng cấp giáp |
| `xd_levelupitem` | Vật phẩm dùng để lên cấp tổng quát |

### 5.2 Tài nguyên tu luyện (8)

| Component | Vai trò |
|---|---|
| `xd_lingji` | "Linh cơ" — pool tài nguyên chính (giống "mana") |
| `xd_lingbao` | "Linh bảo" — vật phẩm legendary |
| `xd_lingbaojilian` | Tinh luyện linh bảo |
| `xd_lingbaojilian10` | Tinh luyện linh bảo 10x (nâng cấp pool) |
| `xd_jllingshi` | Quản lý linh thạch (currency) |
| `xd_lingliitem` | Item chứa linh lực |
| `xd_wenyang` | "Văn dạng" — có thể là enchantment marker |
| `xd_renwulingji` (file ở `main/`) | Linh cơ nhiệm vụ |

### 5.3 Combat / sát thương / chống chịu (12)

| Component | Vai trò |
|---|---|
| `xd_consciousnessdamage` | Sát thương theo "tâm thức / ý chí" (giống sanity damage) |
| `xd_consciousnessdefense` | Phòng vệ tâm thức |
| `xd_damagenumber` + `xd_damagenumber_replica` | Hiển thị số sát thương trên đầu (option `set5`) |
| `xd_xuetiao` + `xd_xuetiao_replica` | Thanh máu custom (option `set2`) |
| `xd_skillcd` + `xd_skillcd_replica` | Đếm cooldown skill |
| `xd_poisonable` | Trạng thái trúng độc |
| `xd_projectile` | Đầu đạn / phép phóng |
| `xd_repairable` | Vật phẩm tự sửa |
| `xd_hauntable` | Tương tác bóng ma (ghost interact) |
| `xd_healthtrigger` | Trigger khi máu xuống ngưỡng |
| `xd_bd` + `xd_bd_replica` | Component cốt lõi nhân vật (có thể là "bản đồ" buff / status panel) |
| `xd_biu` | Hiệu ứng "biu" — explode / projectile event |

### 5.4 Thú cưng / triệu hồi (10)

| Component | Vai trò |
|---|---|
| `xd_petleash` | Leash chung — gắn pet với chủ |
| `xd_petleash_bjms` | Leash riêng cho pet "bjms" |
| `xd_petleash_cy` | Leash cho pet `cy` (Shiji) |
| `xd_petleash_fly` | Leash cho pet bay (Tinh Vệ?) |
| `xd_petleash_mxrg` | Leash cho pet Sudaji `mxrg` |
| `xd_petleash_qy` | Leash cho pet `qy` |
| `xd_petleash_xinmo` | Leash cho `xinmo` |
| `xd_allpetleash` | Quản lý tổng tất cả leash của một chủ (gọi về phím `key_v`) |
| `xd_jingwei_pet` | Đặc thù pet Jingwei |

### 5.5 Spawner / boss controller (5)

| Component | Vai trò |
|---|---|
| `xd_baihuspwner` | Spawner Bạch Hổ |
| `xd_jfsnspwner` | Spawner JFSN |
| `xd_kunpengspawner` | Spawner Côn Bằng |
| `xd_kunpengstage` | Quản lý "stage" của trận đánh Côn Bằng |
| `xd_cjjspwner` | Spawner cho máy quay xổ số |
| `xd_qlchspwner` | Spawner QLCH |
| `xd_qxdxspwner` | Spawner NPC shop QXDX |

### 5.6 Container / inventory (6)

| Component | Vai trò |
|---|---|
| `xd_by_container` | Container cho pet `by` của Shiji |
| `xd_cwkj` | "Kho chứa vật phẩm" |
| `xd_llbx_container` | Container Linh Bảo Tương |
| `xd_sjpn_container` | Container Sudaji `sjpn` |
| `xd_storeitem` | Lưu trữ vật phẩm trong slot |
| `xd_use_inventory` | Tương tác item trong inventory |

### 5.7 Nhà / dungeon / world (8)

| Component | Vai trò |
|---|---|
| `xd_playerhouse` | Logic nhà người chơi |
| `xd_playerhousepos` | Vị trí nhà (toạ độ lưu) |
| `xdhouse` | Wrapper nhà (chú ý không có dấu `_`) |
| `xd_dockmanager` | Quản lý hệ thống dock (bến cảng) |
| `xd_teleporter` | Dịch chuyển tức thời |
| `xd_kunpengstage` | Stage thế giới khi đánh Côn Bằng |
| `xd_time_st` | Quản lý thời gian / state động (status timer) |
| `xd_acidrain` | Mưa acid (worldevent) |

### 5.8 Luyện đan / luyện chế / nâng cấp (5)

| Component | Vai trò |
|---|---|
| `xd_jilianmanager` | Quản lý quá trình "tế luyện" pháp bảo |
| `xd_lingbaojilian` | Tế luyện linh bảo |
| `xd_lingbaojilian10` | Tế luyện linh bảo cấp 10 |
| `xd_huapen_giver` | Cho chậu hoa thứ gì đó (gieo) |
| `xd_huapen_plant` | Cây trồng trong chậu hoa |

### 5.9 Controller riêng cho từng nhân vật / pháp bảo (6)

| Component | Vai trò |
|---|---|
| `xd_htz_lq` | Linh khí của HTZ |
| `xd_htz_sword_controller` | Điều khiển kiếm HTZ |
| `xd_sword_controller` | Điều khiển kiếm chung |
| `xd_sudaji_controller` | Controller Sudaji (form switch, soul) |
| `xd_wukong_skill` | Skill Wukong |
| `xd_yunxiao_battleborn` | Yunxiao "battleborn" — chiến đấu sinh ra |
| `xd_yunxiao_hytxtele` | Yunxiao Hỗn Nguyên teleport |

### 5.10 Khác (16)

| Component | Vai trò |
|---|---|
| `xd_binglingqi` | "Bính linh khí" — vũ khí băng |
| `xd_choujiang_creature` | Sinh vật trong máy quay xổ số |
| `xd_fishing` | Câu cá custom |
| `xd_guaiwu_skills` | Skill cho boss (gọi từ `main/xd_moster_skill`) |
| `xd_hxyp` | (?) |
| `xd_jiangren` | "Tướng nhân" — nhân vật NPC tương trợ |
| `xd_lightitem` | Vật phẩm phát sáng |
| `xd_pick_plant` | Hái cây |
| `xd_qishu` | "Kỳ thư" — sách kỹ năng |
| `xd_reskin` | Reskin items |
| `xd_robot` | Robot AI logic |
| `xd_stafflight` | Đèn / staff phát sáng |
| `xd_stewer_fur` | Stewer (luyện chế đặc biệt) |
| `xd_ylxq_grower` | "Ylxq" grower — trồng cây đặc biệt |

---

## 6. Phân loại widgets / UI (26 widget)

`scripts/widgets/` chứa toàn bộ UI riêng. Mỗi widget thường được attach vào HUD hoặc một panel cụ thể.

| Widget | Vai trò suy diễn |
|---|---|
| `xd_levelui.lua` | Hiển thị cấp độ tu luyện chính + thanh kinh nghiệm |
| `xd_dtlevelui.lua` | Hiển thị cấp "đại đạo" |
| `xd_xuetiao_ui.lua` | Thanh máu tuỳ biến (option `set2`) |
| `xd_damagenumber.lua` | Số sát thương popup (option `set5`) |
| `xd_skilltimer.lua` | Đồng hồ đếm cooldown skill |
| `xd_cdkui.lua` | Panel cooldown — phím tắt + biểu tượng |
| `xd_showhoverui.lua` | Tooltip hover (option `set7`) |
| `xd_bookinfowidget.lua` | Widget hiển thị nội dung trang sách wiki |
| `xd_boss_healthbar.lua` | Healthbar tuỳ biến cho boss |
| `xd_kunpengui.lua` | UI riêng cho boss Côn Bằng (stage tracker) |
| `xd_qxdx_shopui.lua` | Giao diện shop NPC QXDX |
| `xd_choujiangji` (không thấy ở widgets — chỉ prefab) | — |
| `xd_skinui.lua` | Chọn skin cho nhân vật |
| `xd_sandover.lua` | Hiệu ứng overlay "cát" (sandstorm) |
| `xd_danmu_show.lua` | "Đạn mạc" — bullet-screen comment (lời thoại bay ngang) |
| `xd_ds_ui.lua` | UI tổng (Dengxian Status) |
| `xd_binglingqi.lua` | UI vũ khí băng |
| `xd_byspui.lua` | UI cho pet `by` (Shiji) |
| `xd_hyyqdui.lua` | UI hệ phái (?) Yunxiao |
| `xd_hantianzunui.lua` | HUD tổng HTZ |
| `xd_hantianzun_skillui.lua` | Bảng skill HTZ |
| `xd_shijiui.lua` | HUD Shiji |
| `xd_wmz_skillui.lua` | Bảng skill Wangmazi |
| `xd_wukong_skillui.lua` | Bảng skill Wukong |
| `xd_wukonglequi.lua` | UI "lequ" / niềm vui Wukong (form-meter) |
| `xd_yunxiao_battleborn.lua` | Trạng thái battleborn Yunxiao |
| `xd_yunxiaoqui.lua` | HUD Yunxiao |

Và 1 screen:
| Screen | Vai trò |
|---|---|
| `xdbookpopupscreen.lua` | Popup mở sách wiki — fullscreen overlay |

---

## 7. `scripts/main/` — lớp bootstrap

Đây là **lớp gắn kết** — chạy ngay khi mod load để patch vanilla, đăng ký prefab, dựng action, RPC. Mod có 32 file trong `scripts/main/`. Đoán vai trò từng file:

| File | Vai trò suy diễn |
|---|---|
| `actions.lua` | Đăng ký các `Action` mới (vd. Hái linh thạch, Luyện đan, Triệu hồi pet, Kích hoạt pháp bảo). Mỗi action cần `AddAction(...)` + handler trong Component Action. |
| `components.lua` | `AddComponentPostInit` cho component vanilla — vd. patch `combat`, `inventory`, `health`, `sanity` để thêm logic tu tiên. |
| `containers.lua` | Đăng ký metadata `containers.params` cho các container custom (`xd_cangku`, `xd_cwkj_container`, `xd_llbx`, …) — slot layout, ô số, item filter. |
| `extra_back.lua` | Logic mở rộng backpack 4/5 slot dựa trên config `set00`. Patch `Wilson_PostInit` để thêm slot. |
| `fabao.lua` | "Pháp bảo" — đăng ký framework chung cho pháp bảo (action `EQUIPFABAO`, slot riêng, mapping skill). |
| `food.lua` | Đăng ký công thức `STRINGS.NAMES`, recipe nấu, cook tag cho `xd_foods` / `xd_veggie` / `xd_danyao`. |
| `house.lua` | Logic player house cấp cao (patch `world`, `playerhouse` manager). |
| `import.lua` | `modimport` toàn bộ file `main/` còn lại — entrypoint. |
| `mainfunction.lua` | Hàm tiện ích dùng chung (helpers, math, table, GLOBAL injection). |
| `prefabpostInit.lua` | Patch các prefab vanilla DST (`wilson`, `wickerbottom`, `deerclops`, …) bằng `AddPrefabPostInit` — gắn component custom vào nhân vật/boss vanilla. |
| `recipes.lua` | Đăng ký công thức chế tạo: `AddRecipe` / `AddRecipeToFilter`, tab tu tiên riêng (`RECIPETABS.XD_*`). |
| `rpcs.lua` | Đăng ký RPC server-client cho hành động cần đồng bộ (cast skill, mở UI, swap form). |
| `stategraph.lua` | Patch state vanilla — `AddStategraphPostInit` cho `wilson`, `wilson_client`, hoặc inject state mới. |
| `strings.lua` | Localize / `STRINGS.NAMES`, `STRINGS.CHARACTERS`, recipe description. |
| `tiles.lua` | Đăng ký tile mới (xd_jingwei_tile, xdtile1-3) qua `AddTile`. |
| `tuning.lua` | Hằng số cân bằng game: `TUNING.XD_LINGSHI_GAIN`, HP boss, cooldown, dmg multiplier. |
| `widgets.lua` | Inject widget vào HUD — `AddClassPostConstruct("widgets/controls", ...)`. |
| `wilson_skill.lua` | Cây skill cho character (patch `WilsonSkillTree`, thêm node tu tiên). |
| `wukong_skill.lua` | Cây skill riêng Wukong (chỉ load khi config `set6 = true`). |
| `xd_hoverer.lua` | "Hoverer" — phát hiện chuột hover lên entity → hiển thị `xd_showhoverui` (option `set7`). |
| `xd_huoqu.lua` | "Hoạch quả" — patch loot drop / loot table. |
| `xd_moster_healthbar.lua` | Inject thanh máu custom cho quái (option `set2`). |
| `xd_moster_qianghua.lua` | "Cường hoá quái" — scale HP/dmg theo `worldlevel`. |
| `xd_moster_shengti_set.lua` | "Cường thể" — đặt tham số thể chất quái. |
| `xd_moster_skill.lua` | Cấu hình hệ thống skill quái (gọi `xd_guaiwu_skills`). |
| `xd_moster_skill_set1.lua` | Bộ skill set 1 (vd. Bearger, Deerclops). |
| `xd_moster_skill_set2.lua` | Bộ skill set 2 (vd. Spider Queen, Stalker). |
| `xd_new.lua` | Logic "new game" — chạy khi tạo thế giới mới (set up tài nguyên ban đầu). |
| `xd_pi.lua` | "PI" — có thể là Public Interface hoặc PI = "皮" (skin). Quản lý skin marketplace. |
| `xd_renwulingji.lua` | "Nhân vật linh cơ" — gắn linh cơ pool cho player. |
| `xd_shardrpc.lua` | RPC giữa các shard (cave ↔ overworld) — dùng cho dungeon dịch chuyển. |
| `xfd_boss_critters.lua` | Boss → critter (pet nhỏ sau khi đánh bại) — chú ý prefix `xfd_` (gõ nhầm `xd_`). |

---

## 8. Kết luận: kiến trúc Dengxian theo lớp

### 8.1 Sơ đồ lớp

```
                       ┌──────────────────────────────┐
                       │  modmain.lua / modmain0.lua  │  ← entrypoint, gọi loader cipher
                       │  modmain1.lua                │
                       └──────────────┬───────────────┘
                                      │
                       ┌──────────────▼───────────────┐
                       │  scripts/main/import.lua     │  ← orchestrator: modimport hết
                       └──────────────┬───────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
┌───────▼────────┐         ┌──────────▼─────────┐        ┌─────────▼──────────┐
│ Patch vanilla  │         │ Đăng ký system mới │        │ Đăng ký data       │
│  - prefab      │         │  - actions         │        │  - recipes         │
│  - stategraph  │         │  - components      │        │  - tuning          │
│  - components  │         │  - containers      │        │  - strings         │
│  - moster_*    │         │  - rpcs            │        │  - tiles           │
└────────────────┘         │  - widgets (HUD)   │        └────────────────────┘
                           └────────────────────┘
                                      │
                       ┌──────────────▼───────────────┐
                       │  scripts/prefabs/  (274 file) │  ← entity definitions
                       │  scripts/stategraphs/ (69)    │  ← state machines
                       │  scripts/brains/      (44)    │  ← AI behavior trees
                       │  scripts/widgets/     (26)    │  ← UI elements
                       │  scripts/screens/      (1)    │  ← fullscreen overlays
                       └───────────────────────────────┘
```

### 8.2 Các nguyên tắc thiết kế tác giả tuân thủ

1. **Namespace tuyệt đối với prefix `xd_`** — mọi prefab, component, asset, tile, string đều mang prefix. Không có exception.
2. **Mỗi nhân vật là một slice độc lập** — prefab nhân vật + bộ pháp bảo + brain pet + widget UI + bigportrait đều dùng chung sub-prefix (`htz`, `wmz`, `yx`, `sj`, …). Đọc tên file là biết ngay nó thuộc về ai.
3. **Phân biệt rõ logic vs hiển thị** — mọi cái chỉ-vẽ (no logic) đều có hậu tố `_fx`. UI thì ở `widgets/`. Logic thì ở `components/`. Stategraph chỉ chứa state, không chứa data.
4. **Replica pattern cho mọi component cần client đọc** — `xd_xuetiao` ↔ `xd_xuetiao_replica`, `xd_skillcd` ↔ `xd_skillcd_replica`, `xd_damagenumber` ↔ `xd_damagenumber_replica`. Không cố làm tất cả phía server.
5. **Tách patch vanilla khỏi đăng ký mới** — `prefabpostInit.lua`, `xd_moster_*.lua` chỉ patch vanilla. `prefabs/xd_*` chỉ đăng ký prefab mới. Hai lớp không lẫn lộn.
6. **Spawner riêng cho từng boss** — `xd_baihuspwner`, `xd_jfsnspwner`, `xd_kunpengspawner`, `xd_qlchspwner` — không gộp chung. Mỗi boss có lifecycle (cooldown, requirement, drop) riêng.
7. **Pet leash mỗi loại pet một file** — 7 biến thể `xd_petleash_*`. Tác giả không cố làm 1 component "đa năng".
8. **Cấp độ chia 5 chiều**: `xd_level` (cảnh giới chính) + `xd_dtlevel` (đại đạo) + `xd_worldlevel` (thế giới) + `xd_pet_level` (pet) + `xd_armor_levelup` (giáp). Khá rõ ràng, mỗi chiều một component.
9. **Phó bản & boss vanilla cùng tồn tại** — `xd_bearger` (mod-buffed vanilla bearger) vs `xd_fb_mutateddeerclops` (phó bản phiên bản). Người chơi vẫn gặp boss gốc DST, nhưng có thêm trải nghiệm dungeon.
10. **Asset đặt tên khớp prefab 100%** — `anim/ghost_xd_<character>_build.zip`, `bigportraits/xd_<character>.tex`, `images/avatars/avatar_xd_<character>.tex`. Không có "magic mapping" trong code.

### 8.3 5 pattern nên mô phỏng khi build mod tu tiên của riêng bạn

1. **Chọn prefix duy nhất 2–3 ký tự (`pn_` / `tt_`) và dùng tuyệt đối cho mọi file.**
2. **Một nhân vật = 1 slice**: prefab nhân vật + 5–10 prefab pháp bảo riêng + 1–3 stategraph + 1–2 widget UI + 1 speech file + 1 bigportrait set. Đừng dùng chung logic giữa nhân vật khi chưa cần.
3. **Tách rõ `components/` (data + logic), `stategraphs/` (animation state), `brains/` (AI), `widgets/` (UI). Không bao giờ trộn UI vào component.**
4. **Mỗi component cần đọc/ghi từ client → tạo ngay file `<name>_replica.lua`. Đừng cố RPC tay.**
5. **Thư mục `scripts/main/` là lớp keo (glue layer):** 1 file riêng cho `actions`, `recipes`, `tuning`, `strings`, `containers`, `rpcs`, `tiles`, `widgets`, `prefabpostInit`. Đừng dồn tất cả vào `modmain.lua`. Khi mod lớn lên (> 50 file Lua) bạn sẽ cảm ơn chính mình.

### 8.4 Lưu ý cuối

- Mod gốc đã có **9.4 MB Lua đã mã hoá** — đây là 1 mod rất lớn (so với mod trung bình DST chỉ vài trăm KB Lua). Đừng kỳ vọng đạt quy mô này trong vài tháng đầu.
- 80% công sức tác giả nằm ở **asset (anim, image): 350+ MB**. Code chỉ là 9 MB. Lên kế hoạch art pipeline từ sớm — hoặc dùng asset vanilla DST + recolor.
- Cấu trúc `main/` rất gọn (32 file). Hãy bắt đầu mod của bạn bằng đúng cách sắp xếp này: `import.lua`, `prefabpostInit.lua`, `actions.lua`, `recipes.lua`, `tuning.lua`, `strings.lua`, `containers.lua`, `widgets.lua`, `rpcs.lua` — chỉ 9 file đã đủ chạy một mod nhỏ-vừa.

---

> **Hết tài liệu.** Mọi suy diễn đều dựa trên tên file và quy ước đặt tên — không có quyền truy cập vào body Lua đã mã hoá. Khi bạn bắt đầu build mod của mình, tài liệu này nên dùng như **bản đồ tham chiếu**, không phải bản thiết kế chính xác.

# Tài liệu tham khảo cơ chế gameplay — Mod「登仙」(Dengxian / Đăng Tiên)

> **Workshop ID:** 3235319974  
> **Đối tượng:** Lập trình viên người Việt đang phát triển một mod cultivation/tiên hiệp tương tự cho Don't Starve Together.  
> **Mục tiêu:** Suy luận cơ chế gameplay từ 9 file thoại nhân vật (plain-text) vì mã nguồn `prefabs/`, `components/`, `stategraphs/` đều đã bị mã hoá.

---

## 1. Phương pháp

Mod gốc gồm các file Lua đã bị mã hoá nhị phân, **không thể đọc trực tiếp**. Tuy nhiên, 9 file thoại (`speech_xd_*.lua`) trong thư mục `scripts/` lại được lưu dưới dạng văn bản thuần (mỗi file ~4.400 dòng, tổng cộng ~40.000 dòng). Đây là nguồn duy nhất chúng ta có thể khai thác.

Mỗi file thoại tổ chức theo cấu trúc:

```
return {
    ACTIONFAIL = { ... },
    ANNOUNCE_XYZ = "câu thoại",
    BATTLECRY = { ... },
    DESCRIBE = {
        PREFAB_KEY = "mô tả tiếng Trung",  -- 物品名:"tên tiếng Trung"
        ...
    },
}
```

Tài liệu này được tổng hợp bằng cách:

1. `grep` các thuật ngữ tu tiên (cảnh giới, linh khí, đan dược, pháp bảo, yêu thú…) trong cả 9 file.
2. Đối chiếu khoá DESCRIBE (thường là tên prefab vanilla DST viết hoa) với mô tả tiếng Trung do mod gốc viết lại theo phong cách tiên hiệp.
3. Đối chiếu prefab/component **gốc của mod** từ file `daxsg_mod_path.txt` (532 dòng — chứa toàn bộ đường dẫn của brains/components/prefabs/stategraphs/widgets do mod tự thêm vào).

**Giới hạn của phương pháp này:**

- File thoại **không hề** chứa khoá kiểu `XD_LINGSHI = "..."`. Các nhân vật nói về **vật phẩm DST gốc bằng giọng tu tiên** chứ không trực tiếp mô tả prefab `xd_*` của mod. Cho nên các prefab gốc của mod phải được suy ra **bằng tên** trong `daxsg_mod_path.txt`.
- Số liệu cụ thể (sát thương, máu, cooldown, công thức chế tạo) **không bao giờ** xuất hiện trong thoại — chỉ có thể đoán định tính.
- Phong cách mô tả là **tu tiên/tiên hiệp Trung Quốc**: từ "妖丹" (yêu đan) thay cho "monster meat", "灵气" (linh khí) thay cho "magic", "法宝" (pháp bảo) thay cho "weapon", "渡劫" (độ kiếp) thay cho "advancement". Người mod nên giữ vibe này.

---

## 2. Chín nhân vật — vai trò qua lời thoại

Cả 9 nhân vật đều là người tu tiên / yêu tiên / thần tiên từ thần thoại Trung Hoa. Mỗi nhân vật có **đại từ xưng hô riêng**, định nghĩa rõ phong cách & địa vị:

| Nhân vật | Hán-Việt | Đại từ xưng hô | Phong cách thoại |
|---|---|---|---|
| 韩天尊 | Hàn Thiên Tôn | **韩某** (Hàn mỗ) | trầm ổn, cao ngạo, văn ngôn |
| 精卫 | Tinh Vệ | **我** (ta) | trẻ trung, hiếu thắng |
| 龙太子 | Long Thái Tử | **本太子** | kiêu căng, tự đại, hoàng tộc |
| 洛神 | Lạc Thần | **吾** | cổ phong, ngắn gọn, thanh nhã |
| 石矶 | Thạch Cơ | **本座 / 本宫** | tà ma, hắc ám, kiêu ngạo cực điểm |
| 苏妲己 | Tô Đát Kỷ | **妾身** | nũng nịu, mỵ hoặc |
| 王麻子 | Vương Ma Tử | **王某 / 本尊** | lão luyện, sát phạt, thực dụng |
| 悟空 | Ngộ Không | **俺老孙** | suồng sã, hào sảng |
| 云霄 | Vân Tiêu | **我** | dịu dàng, kiên định, đầu bếp |

### 2.1 韩天尊 — Hàn Thiên Tôn

**Vai trò gameplay:** Tu sĩ chính phái, có pháp bảo bản mệnh là **kiếm**, hệ phái thiên về **lôi (sét)** và **hoả** (xem mục 5 — `xd_htz_firefx`, `xd_htz_sword_controller`, `xd_htz_spell`).

Đại từ "韩某" — một cách xưng hô khiêm tốn nhưng đầy uy nghiêm của một tu sĩ thâm hiểu đạo lý. Lời thoại đậm chất văn ngôn, đánh giá vạn vật qua **lăng kính cảnh giới tu vi** — ông đặt tên lại cho mọi vật phẩm DST gốc bằng thuật ngữ tu chân (xem cột "DESCRIBE" — ông là nhân vật duy nhất gọi gấu là `化神期熊妖`, gọi sứa là `蜂卫…金丹初期`).

Trích dẫn tiêu biểu:

- `"哼...自寻死路。"` — "Hừ... tự tìm đường chết." (BATTLECRY GENERIC, `speech_xd_hantianzun.lua:821`)
- `"九天神雷，加诸吾身。"` — "Cửu thiên thần lôi, gia vào thân ta." (ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK, `speech_xd_hantianzun.lua:634`)
- `"经脉灼焚...紫府欲裂..."` — "Kinh mạch thiêu đốt... Tử phủ muốn vỡ..." (ANNOUNCE_FIRENETTLE_TOXIN, `speech_xd_hantianzun.lua:741`) — "tử phủ" là đan điền trong tu tiên.
- `"金睛蜂卫...金丹初期。"` — "Kim Tinh Phong vệ... Kim Đan sơ kỳ." (BEEGUARD, `:1460`) — đây là **dòng giá trị nhất** vì xác nhận hệ thống "cảnh giới" áp dụng cho NPC/quái.
- `"化神蜂巢...沉睡的妖后。"` — "Tổ ong Hoá Thần... Yêu hậu trầm ngủ." (BEEQUEENHIVEGROWN, `:1459`)
- `"远古力场...不及本命法宝。"` — "Cổ lực trường... không bằng pháp bảo bản mệnh." (RUINSHAT, `:1186`)

→ Hàn Thiên Tôn là **nhân vật mẫu mực** mà người mod nên dùng làm template phong cách: ông gắn nhãn cảnh giới (Kim Đan, Hoá Thần) cho mọi sinh vật và đề cập đến "**bản mệnh pháp bảo**" — đây chính là cơ chế trung tâm của mod.

### 2.2 精卫 — Tinh Vệ

**Vai trò gameplay:** Yêu nữ trẻ, biến hình từ chim Tinh Vệ trong thần thoại Sơn Hải Kinh. Pháp bảo bao gồm **quạt (扇)**, **lông vũ/dart**, **chim phượng nhỏ (fenice)** — xem `xd_jingwei_fan`, `xd_jingwei_blowdart`, `xd_jingwei_fenice`, `xd_jingwei_hat`, `xd_jingwei_zzql`.

Lời thoại đơn giản, hồn nhiên, gần với phong cách Wendy/Wickerbottom — vì cô là nhân vật **trẻ** trong dàn. Cô không dùng nhiều thuật ngữ tu chân nặng, mà chủ yếu dùng "灵力" (linh lực).

Trích dẫn:

- `"我才不会输给你！"` — "Ta sẽ không thua đâu!" (BATTLECRY GENERIC, `speech_xd_jingwei.lua:821`)
- `"我还要勤加修炼才是！"` — "Ta vẫn cần chăm chỉ tu luyện thêm!" (`:516`)
- `"得给它提供点法力。"` — "Cần cung cấp chút pháp lực." (ANNOUNCE_ARCHIVE_NO_POWER, `:732`)
- `"一种有灵力的东西。"` — "Một thứ có linh lực." (`:1156`)

### 2.3 龙太子 — Long Thái Tử

**Vai trò gameplay:** Hoàng tử Long Cung, hệ **thuỷ** + **tài bảo**. Là duy nhất trong dàn dùng đại từ "**本太子**" (Bổn Thái tử) trên 700 lần. Có khả năng "**不会被淹死**" (không bị chết đuối) — ANNOUNCE_BOAT_SINK (`:390`). Prefab: `xd_longtaizi`, `xd_longzhu` (long châu), `xd_longtaizi_none`.

Trích dẫn:

- `"受死吧！"` — "Chịu chết đi!" (BATTLECRY, `:821`)
- `"本太子虽然不会被淹死。"` — "Bổn Thái tử dù không bị chết đuối." (`:390`)
- `"龙宫也需要一个这个！"` — "Long Cung cũng cần một cái này!" (GREENAMULET, `:1208`)
- `"我龙宫的龙虾大将军就这么被你们煮了？"` — "Tướng quân long tôm của Long Cung của ta cứ thế bị các ngươi nấu sao?" (LOBSTERDINNER, `:3338`)
- `"我水族已经沦落至此了吗。"` — "Thuỷ tộc của ta đã sa sút đến mức này sao?" (MERMWATCHTOWER_REGULAR, `:3506`)
- `"这个法宝控制着沙子。"` — "Pháp bảo này khống chế cát." (LAZY_FORAGER, `:1151`)

→ Mô típ: hoàng tử mất kiêu hãnh, đến nhân giới, đánh giá vạn vật bằng tiêu chuẩn Long Cung.

### 2.4 洛神 — Lạc Thần

**Vai trò gameplay:** Nữ thần sông Lạc (Mật Phi). Hệ **thuỷ + hoa cỏ**. Prefab: `xd_luoshen`, `xd_luoshen_flower`, `xd_luoshen_items`, `xd_luoshen_jihuaze_debuff` (亟花泽 — debuff hoa), `xd_luoshen_krss`, `xd_luoshen_shentong_fx` (神通 = thần thông).

Phong cách: cực ngắn, văn cổ điển 2–4 chữ. Đại từ "**吾**".

Trích dẫn:

- `"吾不退。"` — "Ta không lùi." (BATTLECRY, `:821`)
- `"吾饥。"` — "Ta đói." (ANNOUNCE_HUNGRY)
- `"水愈多。"` — "Nước càng nhiều." (ANNOUNCE_BOAT_LEAK)
- `"朱雀之羽。"` — "Lông của Chu Tước." (FEATHER_ROBIN, `:1888`) — xác nhận có khái niệm Tứ Linh.
- `"原是花仙子。"` — "Vốn là hoa tiên tử." (ABIGAIL_FLOWER LEVEL2, `:857`)
- `"此花不似宜吾。"` — "Hoa này dường không hợp ta." (`:855`)

→ Lạc Thần có **shentong fx** (神通) riêng — cơ chế skill kích hoạt bằng thần thông.

### 2.5 石矶 — Thạch Cơ

**Vai trò gameplay:** Yêu nữ chính nhân vật **phản diện/tà ma** trong Phong Thần Diễn Nghĩa. Hệ **âm/ma/đan**. Đại từ "**本座 / 本宫**". Là nhân vật **nói nhiều nhất** về luyện đan (nhiều hơn cả Hàn Thiên Tôn). Prefab: `xd_shiji`, `xd_sj_by` (by = ?), `xd_sj_cy` (cy = ?), `xd_sj_bglxp`, `xd_sj_bgygp`, `xd_sj_kls`, `xd_sj_sxz`, `xd_sj_tej`, `xd_sj_tlsq`, `xd_sj_xsydz` — có 9 vũ khí/đệ tử riêng.

Trích dẫn:

- `"哼！区区蝼蚁也敢挡本座去路？！"` — "Hừ! Lũ kiến nhỏ cũng dám chắn đường Bổn tọa?!" (BATTLECRY, `speech_xd_shiji.lua:821`)
- `"血煞当空，正是修炼魔功的良辰！"` — "Huyết sát ngất trời, đúng là thời điểm tốt để tu ma công!" (ANNOUNCE_DUSK, `:437`)
- `"九幽阴气...正合本座修炼！"` — "Cửu u âm khí... vừa hợp Bổn tọa tu luyện!" (ANNOUNCE_ENTER_DARK, `:482`)
- `"哼！本座炼丹千年，岂是尔等凡厨可比？"` — "Hừ! Bổn tọa luyện đan ngàn năm, há lũ phàm trù các ngươi sánh được?" (PROFESSIONALCHEF, `:72`)
- `"这炉九转金丹...还需七七四十九日。"` — "Lò Cửu Chuyển Kim Đan này... còn cần bảy bảy bốn chín ngày." (COOKING_LONG ancient oven, `:3587`)
- `"千年妖兽现世？！正好取它内丹！"` — "Yêu thú ngàn năm xuất thế?! Vừa hay lấy nội đan của nó!" (ANNOUNCE_DEERCLOPS, `:421`)
- `"待本宫取了你的妖丹！"` — "Đợi Bản cung lấy yêu đan của ngươi!" (INERT KINGCRAB, `:3521`)

→ Thạch Cơ là **mẫu nhân vật phản diện/ma đạo** rõ rệt nhất trong mod — cô đại diện cho **playstyle hắc ám**: luyện đan từ xác sinh vật, dùng âm khí để tu luyện.

### 2.6 苏妲己 — Tô Đát Kỷ

**Vai trò gameplay:** Cửu vĩ hồ ly tinh, hệ **mỵ hoặc/cám dỗ/hồn**. Prefab: `xd_sudaji`, `xd_sudaji_fx`, `xd_sudaji_mxrg` (mỵ hoặc rg?), `xd_sudaji_redlantern`, `xd_sudaji_sjpn` (sjpn = ?), `xd_sudaji_soul`, `xd_sudaji_soul_spawn`, `xd_sudaji_tsmd`, `xd_sudaji_xyj`, `xd_sudaji_yhly`, `xd_sudaji_ywfh`, `xd_sudaji_controller`.

Đại từ "**妾身**" — phong cách phi tần quý phái nhưng nguy hiểm.

Trích dẫn:

- `"受死吧。"` — "Chết đi." (BATTLECRY, `speech_xd_sudaji.lua:880`)
- `"妾身要灭了你。"` — "Thiếp sẽ diệt ngươi." (`:882`)
- `"那不是妖术。"` — "Đó không phải yêu thuật." (SHADOWMAGIC, `:78`) — phủ nhận shadow magic, ám chỉ cô có yêu thuật **riêng**.
- `"区区3百年道行的妖精。"` — "Chỉ là yêu tinh 300 năm đạo hạnh." (SPIDERQUEEN, `:2513`) — xác nhận hệ thống "**đạo hạnh ~ năm tu luyện**".
- `"兔子修炼成精了。"` — "Thỏ tu luyện thành tinh rồi." (BUNNYMAN, `:1319`)

→ Đát Kỷ có file rất dài (4690 dòng — dài nhất trong 9 file) → có thể là nhân vật có **nhiều mechanic riêng nhất** (soul container, đèn lồng đỏ, mỵ hoặc cương thi).

### 2.7 王麻子 — Vương Ma Tử

**Vai trò gameplay:** Tu sĩ lão luyện, hệ **trung lập/sát phạt**, có thể nghiêng tà. Đại từ "**王某 / 本尊**". Lời thoại đậm chất tu tiên cao cấp, đầy thuật ngữ. Prefab: `xd_wangmazi`, `xd_wmz_butterfly`, `xd_wmz_db`, `xd_wmz_kjb`, `xd_wmz_md`, `xd_wmz_slxj`, `xd_wmz_spell`, `xd_wmz_tnz`, `xd_wmz_xsj`, `xd_wmz_zhf` — 9 pháp bảo.

Trích dẫn:

- `"挡本尊者，死。"` — "Cản Bản tôn — chết." (BATTLECRY, `speech_xd_wangmazi.lua:821`)
- `"千年...道行...岂惧...物重..."` — "Ngàn năm... đạo hạnh... há sợ... vật nặng..." (`:467`) — phát ngôn khi cõng nặng.
- `"腹中灵气渐消，需进补了。"` — "Trong bụng linh khí dần tiêu, cần tẩm bổ rồi." (ANNOUNCE_HUNGRY, `:488`)
- `"夜间乃修炼佳时，岂可虚度于小憩。"` — "Đêm là thời gian tu luyện tốt, há có thể uổng phí cho ngủ trưa nhỏ." (ANNOUNCE_NONIGHTSIESTA, `:510`)
- `"凝练的梦魇精华，是修炼邪功、炼制魔器的至阴之物。"` — "Mộng yểm tinh hoa ngưng luyện — là chí âm vật để tu tà công, luyện ma khí." (NIGHTMAREFUEL, `:2176`)
- `"百花灵气所凝，可制香囊，亦可作为低阶丹药的引子。"` — "Linh khí bách hoa ngưng tụ, có thể chế hương nang, cũng có thể làm dẫn cho đan dược cấp thấp." (PETALS, `:2192`)
- `"曼德拉草，蕴含极阴之气，可入药亦可炼魂。"` — "Mandrake, hàm cực âm khí, có thể nhập dược cũng có thể luyện hồn." (`:2088`)

→ Vương Ma Tử có **bộ thoại DESCRIBE chi tiết nhất** về **luyện đan & luyện khí**. Mọi vật phẩm vanilla DST đều được ông phân loại theo **dược liệu / luyện khí liệu / âm dương ngũ hành**. Đây là **kho từ vựng vàng** cho người mod.

### 2.8 悟空 — Ngộ Không

**Vai trò gameplay:** Tôn Ngộ Không. Hệ **thiết bổng + biến hoá 72**. Đại từ "**俺老孙**". Prefab: `xd_wukong`, `xd_wukong_breath_fx`, `xd_wukong_dsmo`, `xd_wukong_jgb` (jgb = kim cô bổng), `xd_wukong_moose_fx`, `xd_wukong_shadow`, `xd_72bian` (72 biến hoá), `xd_jgb` (kim cô bổng dùng chung).

Trích dẫn:

- `"呔！妖怪！"` — "Đoài! Yêu quái!" (BATTLECRY, `speech_xd_wukong.lua:821`)
- `"俺老孙忙着呢。"` — "Lão Tôn đang bận." (`:7`)
- `"俺老孙还要勤加修炼才是！"` — "Lão Tôn còn cần tu luyện chăm chỉ hơn!" (`:516`)
- `"和我那师弟谁更厉害！"` — "So với sư đệ của ta xem ai mạnh hơn!" (PIGKING, `:2209`) — ám chỉ Bát Giới.

### 2.9 云霄 — Vân Tiêu

**Vai trò gameplay:** Vân Tiêu nương nương (Phong Thần Diễn Nghĩa, một trong Tam Tiêu). Hệ **đầu bếp / dụng cụ / hỗn nguyên kim đẩu**. Đại từ "**我**". Prefab: `xd_yunxiao`, `xd_yunxiao_fgfq`, `xd_yunxiao_fls`, `xd_yunxiao_fysz`, `xd_yunxiao_hyjd`, `xd_yunxiao_jjj`, `xd_yunxiao_portable_spicer` (gia vị di động — xác nhận hệ **cooking**!), `xd_yunxiao_tooler` (tool — đệ tử/tool dùng chung), `xd_yunxiao_ymsz`, `xd_yunxiao_battleborn`, `xd_yunxiao_hytxtele`. Có **widget riêng** `xd_yunxiao_battleborn` (lưu vong/chiến đấu) và `xd_yunxiaoqui`.

Trích dẫn:

- `"我绝不退缩。"` — "Ta tuyệt không lùi." (BATTLECRY)
- `"我要精进一下我的烹饪技术。"` — "Ta cần nâng cao kỹ thuật nấu nướng của mình." (PROFESSIONALCHEF, `:72`)
- `"你的烹饪技巧可不要失传了。"` — "Kỹ năng nấu nướng của ngươi đừng để thất truyền." (GHOST, `:1053`)

→ Vân Tiêu là **nhân vật đầu bếp** — có gia vị di động và buff khi chiến đấu (battleborn).

---

## 3. Hệ thống cảnh giới tu vi

### 3.1 Các cảnh giới được xác nhận

Dựa trên tần suất xuất hiện và ngữ cảnh trong thoại, mod **chắc chắn** có các cảnh giới sau (đây là cảnh giới tu tiên Trung Hoa chuẩn):

| Tiếng Trung | Hán-Việt | Ghi chú | Lần xuất hiện trong thoại |
|---|---|---|---|
| 炼气 | Luyện Khí | Cảnh giới khởi đầu (không tìm thấy trong thoại — suy ra) | 0 |
| 筑基 | Trúc Cơ | (không tìm thấy — có thể đã bị mã hoá trong file khác) | 0 |
| **金丹** | **Kim Đan** | Xác nhận: "金丹初期" (Kim Đan sơ kỳ) | 4+ |
| 元婴 | Nguyên Anh | Không thấy trong thoại — có thể có | 0 |
| **化神** | **Hoá Thần** | Xác nhận: "化神期熊妖皮" (da gấu Hoá Thần kỳ); "化神蜂巢" | 3+ |
| 炼虚 | Luyện Hư | Không thấy | 0 |
| 合体 | Hợp Thể | Không thấy | 0 |
| 大乘 | Đại Thừa | Không thấy | 0 |
| **渡劫** | **Độ Kiếp** | Xác nhận: "蜂后渡劫失败堕魔" — "Phong hậu độ kiếp thất bại đoạ ma"; "灵植渡劫失败" | 5+ |

**Trích dẫn xác nhận:**

- `"金睛蜂卫...金丹初期。"` (`speech_xd_hantianzun.lua:1460`) — Ong vệ = Kim Đan sơ kỳ.
- `"化神蜂巢...沉睡的妖后。"` (`speech_xd_hantianzun.lua:1459`) — Tổ ong Hoá Thần.
- `"化神期熊妖皮！"` (`speech_xd_hantianzun.lua:1451`) — Da gấu Hoá Thần kỳ.
- `"蜂后渡劫失败堕魔？"` (`speech_xd_hantianzun.lua:1453`) — Phong hậu độ kiếp thất bại đoạ ma → xác nhận **độ kiếp = breakthrough**, **thất bại = đoạ ma**.
- `"灵植渡劫失败。"` (`speech_xd_hantianzun.lua:1431`) — cả cây cối cũng độ kiếp.
- `"%s突破了原有的境界桎梏。"` (`speech_xd_longtaizi.lua:998`) — "x đột phá tù túng của cảnh giới cũ" — REVIVER → **revive = breakthrough**.

### 3.2 Cơ chế "đột phá" (突破)

Từ "**突破**" (đột phá) xuất hiện 6+ lần — là từ khoá then chốt. Một số bối cảnh:

- `"小有突破，仍需谨慎。"` (`hantianzun:637`) — khi gain buff WORK_EFFECTIVENESS.
- `"灵力提升！"` / `"灵力的突破！"` (`longtaizi:637, 2942`) — khi dùng LIFEINJECTOR (kim tiêm tăng máu).
- `"%s突破固有的星法。"` (`sudaji:1057`) — khi revive.
- `"晨膳新法...突破！"` (`shiji:4123`) — khi ăn trứng cao bird (đột phá ẩm thực).

→ Đột phá = mọi sự "lên cấp" trong mod đều được gọi là 突破.

### 3.3 Cơ chế "đạo hạnh / năm tu luyện"

Sinh vật quái được phân loại theo **năm tu luyện** (年道行):

- `"区区3百年道行的妖精。"` (`sudaji:2513`) — nhện hoàng hậu = yêu tinh 300 năm đạo hạnh.
- `"千年妖兽现世？！"` (`shiji:421`) — yêu thú ngàn năm xuất thế (Deerclops).
- `"千年灵芝"`, `"千年妖兽"`, `"千年道行"` — số năm là thước đo độ mạnh.

→ Người mod có thể implement: mỗi quái có thuộc tính "**niên đạo hạnh**" — quyết định máu/sát thương, hiển thị trên healthbar (xem widget `xd_boss_healthbar`).

### 3.4 Component liên quan (suy luận từ `daxsg_mod_path.txt`)

- `components/xd_level` — cảnh giới người chơi (level cultivation)
- `components/xd_savelevel` — lưu cảnh giới
- `components/xd_dtlevel` — có thể là level "Độ Thủy" hoặc "Đạo Thuật"; UI riêng `widgets/xd_dtlevelui`
- `components/xd_pet_level` — cấp độ linh sủng
- `components/xd_worldlevel` + `xd_worldlevel_old` — cấp độ thế giới (tăng dần)
- `components/xd_armor_levelup` + `xd_armor_levelupitem` — giáp có thể nâng cấp
- `components/xd_levelupitem` — item dùng để lên cấp
- `components/xd_lingbao` (linh bảo) + `xd_lingbaojilian` + `xd_lingbaojilian10` — **pháp bảo có thể tế luyện (10 cấp)**
- `widgets/xd_levelui` — UI cảnh giới

---

## 4. Tài nguyên cốt lõi

### 4.1 Linh khí / Linh lực (灵气 / 灵力)

**Linh khí** = năng lượng môi trường, **Linh lực** = năng lượng cá nhân tu sĩ. Đây là tài nguyên trung tâm.

- `"灵气已散，锋芒犹存。"` (`hantianzun:1594`) — linh khí đã tản, mũi nhọn vẫn còn (cây xương rồng bị hái).
- `"狡兔三窟，此洞府灵气充裕，乃修炼宝地。"` (`wangmazi:2254`) — hang thỏ → "tu luyện bảo địa" vì giàu linh khí.
- `"百花灵气所凝，可制香囊。"` (`wangmazi:2192`) — linh khí trăm hoa ngưng tụ.
- `"腹中灵气渐消，需进补了。"` (`wangmazi:488`) — đói = linh khí trong bụng dần tan.

**Component:** `components/xd_lingji` (linh tịch?), `components/xd_lingliitem` (linh lực item), `components/xd_jllingshi` (?, có thể là tổng quát hơn).

→ Cơ chế suy đoán: Một số khu vực có **mật độ linh khí cao** (đồng cỏ trăm hoa, hang thỏ, thạch sơn) → tu luyện ở đó nhanh hơn. Một số item (Wickerbottom magic) làm "灵力流动" — có thể là buff vùng.

### 4.2 Linh thạch (灵石) — đơn vị tiền tệ tu tiên

| Phẩm cấp | Trích dẫn | Nguồn |
|---|---|---|
| 上品灵石 | `"上品灵偶，灵气充盈。"` | `wangmazi:3810` |
| 中品灵膳 | `"地灵根焗饭，中品灵膳"` | `hantianzun:2890` |
| 极品灵石 | `"需极品灵石为引..."` | `shiji:3622` |
| 阴灵石 | `"需以阴灵石为引"` | `hantianzun:2931` |
| (普通) 灵石 | `"方整灵石" / "灵石矿脉"` | nhiều file |

**Prefab:** `prefabs/xd_lingshi` — linh thạch chính. **Component:** `components/xd_jllingshi`.

Trích dẫn quan trọng:
- `"嵌上灵石...即可运转！"` (`shiji:3621`) — gắn linh thạch để vận hành (cơ chế nguồn năng lượng — giống pin của Wagstaff nhưng đậm chất tu chân).
- `"开山镐，采掘灵石矿脉的必备工具。"` (`wangmazi:2195`) — cuốc chim = công cụ khai thác mạch linh thạch.

→ Cơ chế: dùng cuốc đập đá phỉ thuý → ra linh thạch theo phẩm cấp ngẫu nhiên. Linh thạch dùng làm "nguồn" cho **pháp bảo / công trình**.

### 4.3 Đan dược (丹药)

**Prefab:** `xd_danyao`, `xd_danyao_items`, `xd_danyao_new`, `xd_dy_buffs`, `xd_liandanlu` (luyện đan lô = lò luyện đan).

| Đan dược (Hán-Việt) | Tiếng Trung | Trích dẫn |
|---|---|---|
| Kim Đan (Cửu Chuyển) | 九转金丹 | `"这炉九转金丹...还需七七四十九日。"` (`shiji:3587`) |
| Định Hồn Đan | 定魂丹 | `"草精经真火淬炼，药性已变，可炼定魂丹。"` (`wangmazi:2090`) |
| Phá Chướng Đan | 破障丹 | `"妖猴！正好取你妖丹炼制破障丹！"` (`wangmazi:1087`) |
| Tị Thuỷ Châu | 避水珠 | `"水妖！正好取你妖丹炼制避水珠！"` (`wangmazi:1060`) |
| Tráng Đảm Đan | 壮胆丹 | `"壮胆丹，需以道心为引"` (`hantianzun:2620`) |
| Tự Linh Đan | 饲灵丹 | `"看来要检查下最近的饲灵丹了。"` (`hantianzun:687`) — đan cho thú nuôi/Carrat |
| Linh Đan (chung) | 灵丹 | `"哼，勉强可炼几颗灵丹！"` (`shiji:2693`) |

**Phụ liệu đan dược (xác định từ thoại):**
- 妖丹 (yêu đan): drop từ quái — `"既起杀心..你的内丹，本尊收了。"` (`wangmazi:823`)
- 内丹 (nội đan): từ thú lớn — `"千年妖兽现世？！正好取它内丹！"` 
- 花瓣 (cánh hoa): "百花灵气所凝, 可制香囊，亦可作为低阶丹药的引子" (`wangmazi:2192`)
- 噩梦燃料 (mộng yểm tiên hoa): "凝练的梦魇精华，是修炼邪功、炼制魔器的至阴之物" (`wangmazi:2176`)
- 曼德拉草 (mandrake): "可入药亦可炼魂" (`wangmazi:2088`)

**Cơ chế "thời gian luyện đan dài":** `"七七四十九日"` — 49 ngày = thời gian luyện Kim Đan. Có thể implement bằng `xd_time_st` (time stat component?).

### 4.4 Pháp bảo (法宝) / Linh bảo (灵宝)

**Component:**
- `components/xd_lingbao` — linh bảo core
- `components/xd_lingbaojilian` — **tế luyện linh bảo** (jilian = tế luyện, cách bonding với pháp bảo trong tu tiên)
- `components/xd_lingbaojilian10` — tế luyện đến cấp 10
- `components/xd_jilianmanager` — quản lý tế luyện

**Tế luyện** = quá trình kết nối tu sĩ với pháp bảo qua nhỏ máu/thần thức. Tế luyện đầy đủ = "**bản mệnh pháp bảo**" (本命法宝).

Trích dẫn xác nhận:

- `"远古力场...不及本命法宝。"` (`hantianzun:1186`) — sức mạnh cổ không bằng pháp bảo bản mệnh.
- `"缩地石...未祭炼。"` (`hantianzun:1156`) — "Súc Địa Thạch... chưa tế luyện." → confirm cần tế luyện trước khi dùng.
- `"此光...倒是可炼为本命法宝..."` (`shiji:898`) — sách "永恒之光" có thể luyện thành pháp bảo bản mệnh.
- `"哼！区区池塘小术，岂需动用本座法宝？"` (`shiji:97`) — pháp bảo có cooldown / dùng cẩn thận.

**Loại pháp bảo theo ngũ hành (suy luận):**

| Hệ | Trích dẫn |
|---|---|
| 木属性 (Mộc) | `"绿宝石...可作炼器之用。木属性灵气充沛"` (`wangmazi:1204`); `"木灵晶...可炼乙木法宝"` (`hantianzun:1204`) |
| 火属性 (Hoả) | `"离火精粹"` (`hantianzun:2622`); `xd_htz_firefx` |
| 水属性 (Thuỷ) | `"避水珠"` |
| 雷部 (Lôi) | `"莫非是雷部法宝？"` (`shiji:2525`) |
| 冰系 (Băng) | `"修炼冰系功法的好去处"` (`hantianzun:2339`) |
| 玄冰 (Huyền Băng) | `"玄冰心法...冻彻骨髓！"` (`shiji:4103`) |

### 4.5 Bản nguyên (本源) — tinh hoa cốt lõi

- `"此器正在抽取那妖物的本源。"` (`hantianzun:3946`) — "Khí này đang hút bản nguyên của yêu vật đó." — Alterguardian (Celestial Champion).
- `"气血有亏，强施此术恐伤及本源。"` (`wangmazi:182`) — sát thương lên bản nguyên = không thể hồi.
- `"另一种世界的本源。"` (multiple) — blueprint = bản nguyên của thế giới khác.

→ Bản nguyên = "essence" — chỉ những tài nguyên cấp cao nhất (drop từ raid boss như Celestial Champion).

---

## 5. Pháp bảo / vũ khí riêng của từng nhân vật

Đây là phần **giá trị nhất** — đối chiếu trực tiếp với `daxsg_mod_path.txt`.

### 5.1 韩天尊 — Hàn Thiên Tôn

| Prefab | Suy đoán (Hán-Việt / Vietnamese) |
|---|---|
| `xd_hantianzun` | nhân vật chính |
| `xd_hantianzun_none` | skin none (rỗng) |
| `xd_htz_tlz` | TLZ = ? (có thể **太乙诛 / 通灵珠**); chuông triệu hồi? |
| `xd_htz_xtzlj` | XTZLJ = ? (**仙天诛灵剑** — Tiên Thiên Tru Linh Kiếm?) |
| `xd_htz_sjcx` | SJCX = ? (**杀机苍穹 / 神剑出鞘**?) — có stategraph `SGxd_htz_sjc` xác nhận đây là vũ khí xuất kích |
| `xd_htz_qzj` | QZJ = ? (**乾坤镯** — Càn Khôn Trạc / Vòng Càn Khôn?) |
| `xd_htz_xyzz` | XYZZ = ? (**玄元真子**?) |
| `xd_htz_ztp` | ZTP = ? (**斩天瓶** — Trảm Thiên Bình?) |
| `xd_htz_fjfb` | FJFB = ? (**封剑封宝** — Phong Kiếm Phong Bảo?) |
| `xd_htz_firefx` | hiệu ứng lửa |
| `xd_htz_spell` | spell — phép thuật |
| `xd_htz_sword_controller` | **bộ điều khiển kiếm** (giống Sword Storm) |

**Component:** `components/xd_htz_lq` (linh khí riêng?), `components/xd_htz_sword_controller`.  
**Widget:** `xd_hantianzun_skillui`, `xd_hantianzunui`.

→ Hàn Thiên Tôn là **kiếm tu**: có nhiều thanh kiếm + cơ chế **điều khiển kiếm bay** (như Vô Thượng Kiếm Tâm). Sword controller ngụ ý cơ chế tương tự "御剑" (ngự kiếm) trong tu tiên.

### 5.2 精卫 — Tinh Vệ

| Prefab | Vietnamese |
|---|---|
| `xd_jingwei` | nhân vật |
| `xd_jingwei_blowdart` | phi tiêu (lông vũ?) |
| `xd_jingwei_fan` | **quạt** (扇 = pháp bảo chính) |
| `xd_jingwei_fan_tornado` (brain + stategraph) | quạt triệu hồi gió lốc |
| `xd_jingwei_fenice` | **chim Phượng nhỏ** (Phenix/Fenice) — pet bay |
| `xd_jingwei_fenice4` (brain) | có 4 cấp / 4 con phượng? |
| `xd_jingwei_hat` | mũ (set bonus?) |
| `xd_jingwei_zzql` | ZZQL = ? (**追踪青鸾**?) |

→ Tinh Vệ = **đệ tử quạt tornado + pet chim phượng** (giống Jingwei thần thoại lấp biển).

### 5.3 龙太子 — Long Thái Tử

| Prefab | Vietnamese |
|---|---|
| `xd_longtaizi` | nhân vật |
| `xd_longzhu` | **long châu** — ngọc rồng (pháp bảo chính) |
| `xd_longtaizi_none` | skin none |

→ Bộ pháp bảo của Long Thái Tử có vẻ tối giản — có thể skill set là **ngọc rồng triệu hồi nước/sét**. Còn liên quan có thể là `xd_dragonfly` (chuồn chuồn rồng — biến thể).

### 5.4 洛神 — Lạc Thần

| Prefab | Vietnamese |
|---|---|
| `xd_luoshen` | nhân vật |
| `xd_luoshen_flower` | hoa Lạc (debuff) |
| `xd_luoshen_items` | bộ item |
| `xd_luoshen_jihuaze_debuff` | jihuaze = 亟花泽? — debuff "hoa nở" |
| `xd_luoshen_krss` | KRSS = ? (có thể "凯瑞丝丝" hoặc tên độc đáo) |
| `xd_luoshen_shentong_fx` | **thần thông hiệu ứng** — confirm có **skill thần thông** |
| `xd_luoshen_none` | skin none |

**Stategraph:** `SGxd_luoshenzhu_vine` — dây leo Lạc Thần.

→ Lạc Thần = **AOE debuff hoa + dây leo** (control mage).

### 5.5 石矶 — Thạch Cơ

| Prefab | Vietnamese |
|---|---|
| `xd_shiji` | nhân vật |
| `xd_shiji_none` | skin none |
| `xd_sj_by` | BY = **白鹰** (Bạch Ưng?) — stategraph `SGxd_sj_by` xác nhận là sinh vật |
| `xd_sj_cy` | CY = **彩云 / 苍鹰**?; `SGxd_sj_cy` |
| `xd_sj_bglxp` | BGLXP = ? (có thể "白骨灵血幡" — Bạch Cốt Linh Huyết Phiên) |
| `xd_sj_bgygp` | BGYGP = ? ("白骨阴光幡"?) |
| `xd_sj_kls` | KLS = ? |
| `xd_sj_sxz` | SXZ = ? ("十绝阵"?) |
| `xd_sj_tej` | TEJ = ? |
| `xd_sj_tlsq` | TLSQ = ? |
| `xd_sj_xsydz` | XSYDZ = ? |
| `SGxd_sj_pysk` | pysk = ? |

→ Thạch Cơ có **rất nhiều pháp bảo** (10+) — đặc trưng của ma đạo: mỗi pháp bảo là một loại phiên/đan/yêu. Tham khảo Phong Thần Diễn Nghĩa chương Thạch Cơ → có "Bát Quái Tử Thụ Long Tu Thân", "Phách Phong Quan".

### 5.6 苏妲己 — Tô Đát Kỷ

| Prefab | Vietnamese |
|---|---|
| `xd_sudaji` | nhân vật |
| `xd_sudaji_none` | skin none |
| `xd_sudaji_fx` | fx chung |
| `xd_sudaji_mxrg` | MXRG = ? ("魅惑人偶" — Mỵ Hoặc Nhân Ngẫu?) — có petleash `xd_petleash_mxrg` |
| `xd_sudaji_redlantern` | **đèn lồng đỏ** (đèn cám dỗ) |
| `xd_sudaji_sjpn` | SJPN = ? (có container `xd_sjpn_container` → một loại rương) |
| `xd_sudaji_soul` | **hồn** (linh hồn) |
| `xd_sudaji_soul_spawn` | spawner hồn |
| `xd_sudaji_tsmd` | TSMD = ? |
| `xd_sudaji_xyj` | XYJ = ? ("勾魂使者"?) |
| `xd_sudaji_yhly` | YHLY = ? ("妖狐灵狱"?) |
| `xd_sudaji_ywfh` | YWFH = ? |
| `xd_sudaji_controller` | controller |

**Stategraph:** `SGxd_sudaji_rotatefire` — bộ xoay lửa.

→ Đát Kỷ = **hệ hồn + đèn lồng + nhân ngẫu**. Cô có thể là class **summoner** mạnh nhất mod.

### 5.7 王麻子 — Vương Ma Tử

| Prefab | Vietnamese |
|---|---|
| `xd_wangmazi` | nhân vật |
| `xd_wangmazi_none` | skin none |
| `xd_wmz_butterfly` | **bướm** (ám sát/scout) |
| `xd_wmz_db` | DB = ? ("毒钵"?) |
| `xd_wmz_kjb` | KJB = ? ("枯静碑"?) |
| `xd_wmz_md` | MD = ? — có stategraph `SGxd_wmz_md` |
| `xd_wmz_slxj` | SLXJ = ? |
| `xd_wmz_spell` | bộ spell |
| `xd_wmz_tnz` | TNZ = ? |
| `xd_wmz_xsj` | XSJ = ? |
| `xd_wmz_zhf` | ZHF = ? (招魂幡 — Chiêu Hồn Phiên?) |

**Brain/SG riêng:** `xd_wmzsoulbrain`, `SGxd_wmz_zhf_soul` — xác nhận có **soul mechanic**: thu hồn rồi triệu hồi đánh.

### 5.8 悟空 — Ngộ Không

| Prefab | Vietnamese |
|---|---|
| `xd_wukong` | nhân vật |
| `xd_wukong_none` | skin none |
| `xd_wukong_jgb` | **金箍棒** — Kim Cô Bổng (vũ khí chính) |
| `xd_jgb` | bản dùng chung của Kim Cô Bổng |
| `xd_72bian` | **72 biến** — 72 phép biến hoá (mounted/transform) |
| `xd_wukong_breath_fx` | hiệu ứng thở |
| `xd_wukong_dsmo` | DSMO = ? ("大圣魔"?) |
| `xd_wukong_moose_fx` | hiệu ứng moose (biến thành Moose?) |
| `xd_wukong_shadow` | bóng (clone — phân thân) |

**Component:** `components/xd_wukong_skill` — bộ skill riêng. **Widget:** `xd_wukong_skillui`, `xd_wukonglequi`.  
**Stategraph:** `SGxd_jgb_mate`, `SGxd_jgb_monkey` — **Kim Cô Bổng có 2 mode: mate (đối tác) và monkey** → có thể cô lập / triệu hồi khỉ phụ.

→ Ngộ Không = **kiếm sĩ một vũ khí (Kim Cô Bổng) + phân thân + 72 biến**.

### 5.9 云霄 — Vân Tiêu

| Prefab | Vietnamese |
|---|---|
| `xd_yunxiao` | nhân vật |
| `xd_yunxiao_none` | skin none |
| `xd_yunxiao_fgfq` | FGFQ = ? (**缚仙绳/封锁阵** — dây trói tiên?) |
| `xd_yunxiao_fls` | FLS = ? |
| `xd_yunxiao_fysz` | FYSZ = ? |
| `xd_yunxiao_hyjd` | HYJD = ? (**混元金斗** — Hỗn Nguyên Kim Đẩu — pháp bảo nổi tiếng của Tam Tiêu!) |
| `xd_yunxiao_jjj` | JJJ = ? (có thể là "**金蛟剪**" — Kim Giao Tiễn?) |
| `xd_yunxiao_portable_spicer` | **dụng cụ gia vị di động** — confirm cooking class |
| `xd_yunxiao_tooler` | **dụng cụ pet** — có brain `xd_yunxiao_toolerbrain` và stategraph `SGxd_yunxiao_tooler` — pet là **công cụ trợ thủ** (auto-craft?) |
| `xd_yunxiao_ymsz` | YMSZ = ? |

**Component:** `xd_yunxiao_battleborn` (chiến đấu sinh ra — buff khi đánh), `xd_yunxiao_hytxtele` (HYTX teleport — Hỗn Nguyên Kim Đẩu có thể teleport!).  
**Widget:** `xd_yunxiao_battleborn`, `xd_yunxiaoqui`, `xd_hyyqdui` (HYYQD — Hỗn Nguyên Khí Đẩu UI?).

→ Vân Tiêu = **lớp đầu bếp đa năng + pet tool + Hỗn Nguyên Kim Đẩu**. Trong Phong Thần, HNKĐ có thể nhốt và biến mọi sinh vật thành "máu mủ" — đây là pháp bảo cấp tối thượng.

---

## 6. Boss & yêu thú

### 6.1 Boss/quái nguyên gốc mod

Suy ra từ `prefabs/`:

| Prefab | Hán-Việt / Vietnamese | Suy đoán vai trò |
|---|---|---|
| `xd_baihu` + `xd_baihu_buff` + `xd_baihu_shadow_fx` + `xd_baihufx` | **Bạch Hổ** | một trong Tứ Linh — Tây phương. Có brain riêng + brain "no attack" (giai đoạn cảm hoá). Có `xd_baihuspwner` component. |
| `xd_kunpeng_shadow` + map `xd_kunpeng` + spawner `xd_kunpengspawner` + stage `xd_kunpengstage` | **Côn Bằng** | đại điểu thần thoại Trang Tử; có dungeon riêng (kunpeng map). |
| `xd_roc` + `xd_roc_leg` | **Đại Bàng** (Roc) | đại bàng khổng lồ; có 2 phần (chân riêng — multi-part boss như Wagstaff Eye of Terror). |
| `xd_xianhe` + `SGxd_xianhe` + `xd_zzxhcx` + `xd_swhsbrain` | **Tiên Hạc** | hạc tiên — có thể là pet/boss bay. Có thể là **坐骑** (mount). |
| `xd_swhs` | có thể "**水猴**" (Thuỷ Hầu) hoặc "**碎魂者**" | quái riêng |
| `xd_zhouwang` + `xd_zhouwang_shadow` + brain `xd_zhouwangshadowbrain` | **Chu Vương** | vua nhà Chu — Phong Thần Diễn Nghĩa boss; có bóng (giai đoạn 2). |
| `xd_ziyunboss` + `xd_ziyunge` + `xd_ziyunjfsn` + `xd_ziyunminions` + `xd_ziyunswordfx` + `xd_ziyunwarg` + `xd_deerclops_ziyun` + `xd_stalke_ziyun` | **Tử Vân (boss series)** | **toàn bộ raid boss + minion + variant biến đổi của Deerclops/Stalker/Warg** — đây là **endgame raid**. |
| `xd_qlch` + `xd_qlch_cloud` + `xd_qlch_fx` + brain `xd_qlchbrain` + `xd_qlchfsbrain` + `xd_qlchtxbrain` | QLCH = ? (có thể **奇灵长虫** — Kỳ Linh Trường Trùng, hoặc **麒麟长虫**?) | có nhiều biến thể brain (cloud + tx + fs) → multi-phase boss. |
| `xd_qxdx` + brain `xd_qxdxbrain` + spawner `xd_qxdxspwner` + widget `xd_qxdx_shopui` | QXDX = ? — có **shop UI**! | một **NPC bán hàng** kiểu Hermit |
| `xd_jfsn` + `xd_jfsn_fire` + `xd_jfsnmeteor` + spawner `xd_jfsnspwner` + brain `xd_jfsnbrain` | JFSN = ? ("巨魔神/狮神"?) | boss có thể tạo meteor lửa |
| `xd_jcbird` + brain `xd_jcbirdbrain` | "**精怪鸟**"? — `xd_fb_jcbird` (dungeon mutated) | quái rừng phụ |
| `xd_xinmo` + brain `xd_xinmobrain` + `SGxd_xinmo` + petleash `xd_petleash_xinmo` | **Tâm Ma** | inner demon — có thể là enemy & pet (tame được). |
| `xd_eyeofterror` (xd_) + brain | **Khủng Bố Chi Nhãn** | port DST vanilla nhưng có brain riêng |
| `xd_shadowmonster` + `xd_shadowmeteor` + `xd_shadow_bishop` | **bóng quái** | shadow creature port |
| `xd_futu` + brain `xd_futubrain` + brain `xd_futu_smallbrain` + `SGxd_futu` | FUTU = "**佛图**" / "**蜉蝣**"? | có version small (con non) |
| `xd_pog` + brain `xd_pogbrain` + `SGxd_pog` | **pog** | quái phụ |
| `xd_icebutterfly` + brain + `SGxd_icebutterfly` | **bướm băng** | quái băng / pet |
| `xd_icedragon` | **rồng băng** | mini-boss |
| `xd_minions` + `xd_fubenminions` + `xd_ziyunminions` + brain `xd_minionbrain` + SG `SGxd_minion` | **lâu la** | trong dungeon (fuben) và Tử Vân |
| `xd_lightninggoat` | **dê sấm** | port DST với buff |
| `xd_klxw` | KLXW = ? ("克劳斯小兽"?) | port Klaus |
| `xd_dbg` | DBG = ? | quái phụ |
| `xd_qy` + petleash `xd_petleash_qy` | QY = "**青鸟**"? | có thể là pet |
| `xd_xjs` + `xd_xjs_curve_fx` + `xd_xjspuppet` + brain `xd_xjspuppetbrain` + SG `SGxd_xjspuppet` + `SGxd_xjstentacle` | XJS = "**血祭尸/魅惑师**"? | có puppet + tentacle — controlled minion |
| `xd_tssyq` + `SGxd_tssyq_puppet` + `SGxd_tssyq_shark` | TSSYQ = "**太上孙悟空？**" hay "**天上斯诺鱼**" | có cả puppet và shark form |
| `xd_qfwjd` + `SGqfwjdtornado` | QFWJD = "**乾坤纹炸弹**" | có tornado |
| `xd_mr` | MR = ? | quái phụ |
| `xd_nl` | NL = ? | quái phụ |
| `xd_sly` | SLY = ? | quái phụ |
| `xd_pflnw` | PFLNW = ? | quái phụ |
| `xd_lhwdc` | LHWDC = ? | quái phụ |

→ Mod có **rất nhiều quái riêng** — ~50+ entities mới ngoài port của vanilla.

### 6.2 Tứ Linh (xác nhận)

- 白虎 (Bạch Hổ) — xác nhận có prefab `xd_baihu`
- 朱雀 (Chu Tước) — chỉ có lông `feather_robin` được mod gán: `"朱雀之羽。"` (`luoshen:1888`) — có thể chỉ ở dạng tài liệu
- 玄龟 (Huyền Quy) — chỉ có "玄龟甲" mô tả áo giáp ốc (`"玄龟甲...七成防御"` `hantianzun:1253`) — chưa thấy prefab boss
- 蛟龙 (Giao Long) — `"蛟龙幼体..."` mô tả lươn — `xd_dragonfly` có thể là biến thể giao long

### 6.3 Boss biến dị / Phó bản (Fuben mutant)

Prefab `xd_fb_*` = **副本** (phó bản = instance dungeon):

| Prefab | Biến dị |
|---|---|
| `xd_fb_hound` + `SGxd_fb_hound` | Hound version fuben |
| `xd_fb_jcbird` | bird version fuben |
| `xd_fb_jfsn` + `SGxd_fb_jfsn` | JFSN fuben |
| `xd_fb_lavae` + `SGxd_fb_lavae` | nhện dung nham fuben |
| `xd_fb_mutateddeerclops` + `SGxd_fb_mutateddeerclops` | Deerclops biến dị (sau Lunar Storm?) |
| `xd_fb_mutatedwarg` + `SGxd_fb_mutatedwarg` + `xd_fb_warg_mutated_fx` | Warg biến dị |
| `xd_fubenminions` | lính phó bản |
| `xd_stalke_fuben` | Stalker phó bản |

→ Confirm **dungeon system với boss biến dị**: bản fuben có sức mạnh + cơ chế khác.

---

## 7. Phó bản / dungeons / nhà cửa

### 7.1 Dungeons & teleport

- `prefabs/xd_door_exit` — **cửa thoát phó bản**
- `components/xd_teleporter` — teleporter
- `components/xd_dockmanager` — quản lý dock (cầu cảng?)
- `components/xd_dock_damage` (thực ra là prefab) — sát thương dock
- `map/static_layouts/xd_kunpeng` — **map static cho Côn Bằng** — confirm có raid arena cố định
- `map/static_layouts/xd_choujiangjimap` — **map cho máy抽奖** (xem 9.1)

### 7.2 Nhà chơi (player housing)

- `components/xd_playerhouse` + `components/xd_playerhousepos` + `components/xdhouse`
- `prefabs/xd_interiors` — **interior tiles** (giống Hamlet)
- `prefabs/xd_floor`, `xd_walls`, `xd_fence`, `xd_door_exit`, `xd_chairs`, `xd_fence`
- `main/house` — main module

→ Confirm có **hệ thống nhà cửa nội thất** đầy đủ — người chơi xây dựng động phủ tu luyện (洞府).

Trích dẫn liên quan:
- `"狡兔三窟，此洞府灵气充裕，乃修炼宝地。"` (`wangmazi:2254`)

### 7.3 Crafting station / lò luyện

- `prefabs/xd_liandanlu` — **luyện đan lô** (lò luyện đan)
- `prefabs/xd_jitan` + `prefabs/xd_jitan_antlion_sinkhole` — **祭坛** (tế đàn) — bàn thờ
- `prefabs/xd_ftj` — FTJ = "**法天界**"? hoặc "**飞天境**"?

### 7.4 Hộp chứa / Linglong treasure box

- `components/xd_by_container`, `xd_cwkj_container`, `xd_he_container`, `xd_llbx_container`, `xd_sjpn_container` (cho Đát Kỷ)
- `prefabs/xd_lbx` + `xd_llbx` — **LLBX = 玲珑宝箱** (Linh Lung Bảo Hộp) — **xác nhận lottery box**
- `prefabs/xd_cangku` — kho tàng

### 7.5 Mining & gathering

- `components/xd_pick_plant` — hái cây custom
- `components/xd_huapen_giver` + `xd_huapen_plant` — **chậu hoa** (huapen) — giữ cây
- `prefabs/xd_huapen` — chậu
- `components/xd_ylxq_grower` — YLXQ = "**药林星球**" hoặc "**灵药仙泉**"?
- `prefabs/xd_ylxq` + `xd_ylxc` — vườn dược liệu

---

## 8. Skill / chiến đấu / cooldown

### 8.1 Skill system

**Component:**
- `components/xd_skillcd` + replica — **skill cooldown**
- `components/xd_wukong_skill` — riêng cho Ngộ Không
- `main/wukong_skill` + `main/wilson_skill` — module skill
- `main/xd_moster_skill` + `xd_moster_skill_set1` + `xd_moster_skill_set2` — **skill cho quái** (boss có skill như player)
- `main/xd_moster_qianghua` — **强化** (cường hoá) cho quái
- `main/xd_moster_shengti_set` — body cho quái

**Widget:**
- `widgets/xd_skilltimer` — bộ đếm cooldown
- `widgets/xd_cdkui` — CD UI
- `widgets/xd_wukong_skillui`, `xd_hantianzun_skillui`, `xd_wmz_skillui` — UI skill riêng cho từng nhân vật

### 8.2 Thần thông / Thần thức

- 神通 (thần thông): xuất hiện 8+ lần. Confirm với `xd_luoshen_shentong_fx`.
- 神识 (thần thức = spiritual sense): xuất hiện trong:
  - `"神识可及之处。"` (`hantianzun:61`) — phạm vi thần thức (giống minimap radar).
  - `"在王某神识之下，无所遁形。"` (`wangmazi:758`) — Vương Ma Tử dò thần thức.
  - `"需以神识刻印，方可不漏分毫。"` (`hantianzun:744`)
  - `"如果神识能让它为本太子所用就好了。"` (`longtaizi:3413`)

→ Cơ chế: **thần thức** = phạm vi minimap/scan; **thần thông** = active skill cooldown lớn.

### 8.3 Damage / defense components

- `components/xd_consciousnessdamage` + `xd_consciousnessdefense` — **sát thương ý thức / phòng ngự ý thức** — kiểu "Sanity damage" có tính riêng (cho ma/hồn)
- `components/xd_damagenumber` + replica — **hiển thị số sát thương**
- `components/xd_xuetiao` + replica — **xuetiao = huyết điều** (healthbar tuỳ chỉnh) cho enemy
- `widgets/xd_boss_healthbar` — healthbar boss
- `widgets/xd_damagenumber` — UI damage number
- `widgets/xd_xuetiao_ui` — UI huyết điều

→ Confirm **damage number floating** trên đầu enemy (như MMO modern), không phải DST vanilla.

### 8.4 Status effect / buff

- `components/xd_hauntable` — custom hauntable
- `components/xd_poisonable` — **trúng độc tuỳ chỉnh**
- `prefabs/xd_buffs` + `xd_dy_buffs` (đan dược buff) + `xd_weaponbuffs` + `xd_dms_healthregenbuff`
- `prefabs/xd_acidsmoke` + component `xd_acidrain` — **mưa axit**
- `prefabs/xd_poison_fx` — fx độc
- `prefabs/xd_baihu_buff` — buff Bạch Hổ (sau khi tame?)
- `prefabs/xd_sudaji_redlantern` — đèn lồng đỏ (charm debuff)

### 8.5 Mounting / Cưỡi linh thú

Từ thoại:
- `"灵兽搏杀中，不宜乘骑！"` (`hantianzun:186`) — không cưỡi linh thú khi nó đánh nhau
- `"我的坐骑..."` (`jingwei:298`)
- Prefab `xd_beefalo` + brain `xd_beefalobrain` + SG `SGxd_beefalo` — **beefalo phiên bản mod** (mount)

→ Confirm **cưỡi tiên hạc / linh thú** — `xd_xianhe` có thể là mount cao cấp; suy đoán: cưỡi hạc bay sau khi đạt cảnh giới đủ cao.

---

## 9. Hệ thống đặc biệt khác

### 9.1 Lottery (抽奖) / Linglong Box

- `prefabs/xd_choujiangji` + `SGxd_choujiangji` + map `xd_choujiangjimap` — **máy 抽奖**
- `components/xd_choujiang_creature` — sinh vật từ抽奖
- `components/xd_cjjspwner` — spawner cho choujiang

→ **Lottery machine** quay ra item ngẫu nhiên hoặc sinh vật. Có map static riêng → có thể là **một khu vực riêng để抽奖** (đào mỏ hên xui).

Linglong:
- `prefabs/xd_llbx` + `components/xd_llbx_container` — **玲珑宝箱** (Linh Lung Bảo Hộp) — kiểu Daily reward chest.
- `widgets/xd_llbxx`? — không có nhưng có `xd_bookinfowidget`.

### 9.2 Reincarnation / Revive (转世 / 复活)

- `prefabs/xd_fanhunshu` — FANHUNSHU = **返魂树** (Phản Hồn Thụ) — **cây hồi sinh** (giống Resurrection Stone)
- Trích dẫn: `"里面蕴含了返魂的法力。"` (`jingwei:2309`) — Touchstone = chứa phép返魂

### 9.3 Heavenly Tribulation (渡劫)

Confirm trong thoại (xem mục 3.1):
- "**蜂后渡劫失败堕魔**" → fail = đoạ ma (rồi).
- "**灵植渡劫失败**" → kể cả thực vật cũng độ kiếp.

**Prefab:** `xd_lightning` + `xd_stmeteor` (thiên lôi meteor) — có thể là FX của thiên kiếp.

### 9.4 Cooking / 灵膳 / 妖膳

- `main/food` — module food
- `prefabs/xd_foods` + `xd_veggie` + `xd_danyao` (cũng tính là food?)
- `prefabs/xd_yunxiao_portable_spicer` — Vân Tiêu có bộ gia vị di động
- Trích dẫn: `"地灵根焗饭，中品灵膳"` (`hantianzun:2890`) — **xác nhận hệ thực phẩm phân phẩm cấp** (thượng/trung/hạ phẩm linh thiện).

### 9.5 Pet system (灵宠 / 本命)

- `components/xd_allpetleash` — leash chung
- `components/xd_petleash` (+ 7 biến thể: `_bjms`, `_cy`, `_fly`, `_mxrg`, `_qy`, `_xinmo`) — **7+ loại pet** với leash riêng
- `components/xd_jingwei_pet` — pet đặc biệt cho Tinh Vệ
- `components/xd_pet_level` — pet có cấp độ

→ Confirm có **hệ thống thú linh đa dạng** — mỗi nhân vật có thể có 1-2 loại pet độc quyền + cấp độ tăng dần.

Trích dẫn:
- `"韩某已收灵宠，不便再纳。"` (`hantianzun:16`) — confirm 1 pet/người.
- `"此兽灵性尚可，或可收为灵宠。"` (`hantianzun:3907-3915`) — bắt các loại kitcoon thành linh sủng.

### 9.6 Lighting / Lighting prefabs (linh khí lights)

- `prefabs/xd_lights` + `xd_lightning` + component `xd_lightitem` + `xd_stafflight` — confirm có hệ thống ánh sáng riêng (linh khí phát sáng).

### 9.7 Forging / Re-skinning

- `components/xd_reskin` — change appearance
- `components/xd_repairable` — repair custom
- `components/xd_lingbaojilian10` — tế luyện 10 cấp pháp bảo → confirm **upgrade tree cho mỗi pháp bảo**

### 9.8 World Level

- `components/xd_worldlevel` (mới) + `xd_worldlevel_old` — **cấp độ thế giới** (giống mức độ Krampus): càng cao quái càng mạnh, loot càng tốt.
- `main/xd_huoqu` — HUOQU = "**获取**" (thu thập) hoặc "**火炉**" (lò lửa)?

### 9.9 Book / Tooltips

- `prefabs/xd_infobook` — sách hướng dẫn
- `screens/xdbookpopupscreen` — popup sách
- `widgets/xd_bookinfowidget` + `xd_showhoverui` — tooltip riêng cho item mod
- `main/wilson_skill` — Wilson có skill — confirm các nhân vật DST gốc cũng có skill khi cài mod này

### 9.10 Misc unique systems

- `components/xd_qishu` — QISHU = "**棋术**" (cờ thuật)? — có thể là minigame
- `components/xd_wenyang` — WENYANG = "**温养**" (ấm dưỡng = bí mật incubate pháp bảo)
- `components/xd_biu` — biu (sound/projectile FX?)
- `components/xd_robot` — robot (port WX?)
- `components/xd_jiangren` — JIANGREN = "**僵尸/僵人**" (cương thi)
- `components/xd_binglingqi` + widget — **冰灵气** (băng linh khí) — chỉ số riêng giống nhiệt độ
- `components/xd_use_inventory` — UI nhanh inventory
- `components/xd_storeitem` — store
- `components/xd_stewer_fur` — lò hầm lông (cooking variant)
- `main/xd_pi` — pi component
- `main/xd_renwulingji` — **任务灵机** (nhiệm vụ linh cơ) — **xác nhận quest system!**
- `main/xd_new` — newbie tutorial?
- `main/xd_hoverer` — hover UI
- `main/extra_back` — extra back slot — confirm **slot lưng phụ** (cho pháp bảo phù hộ)
- `widgets/xd_skinui` — skin UI

---

## 10. Từ vựng Hán-Việt cho người mod

Bảng tra cứu nhanh — sắp xếp theo chủ đề:

### 10.1 Cảnh giới & tu vi

| Tiếng Trung | Pinyin | Hán-Việt | Nghĩa Việt | Prefab/component liên quan |
|---|---|---|---|---|
| 修为 | xiūwéi | tu vi | trình độ tu luyện | `xd_level` |
| 修炼 | xiūliàn | tu luyện | rèn luyện | (general) |
| 境界 | jìngjiè | cảnh giới | cấp độ tu luyện | `xd_level`, `xd_dtlevel` |
| 突破 | tūpò | đột phá | tiến cấp | (level-up event) |
| 渡劫 | dùjié | độ kiếp | vượt thiên kiếp | `xd_lightning`, `xd_stmeteor` |
| 天劫 / 劫雷 | tiānjié / jiéléi | thiên kiếp / kiếp lôi | sấm sét trừng phạt | `xd_lightning` |
| 飞升 | fēishēng | phi thăng | thành tiên | (endgame?) |
| 道行 | dàoxíng | đạo hạnh | số năm tu | (creature stat) |
| 金丹 | jīndān | Kim Đan | giai đoạn 4 | `xd_danyao` |
| 化神 | huàshén | Hoá Thần | giai đoạn 6 | (creature scaling) |
| 元婴 | yuányīng | Nguyên Anh | giai đoạn 5 | — |

### 10.2 Năng lượng / tinh hoa

| TQ | Pinyin | Hán-Việt | Nghĩa | Prefab |
|---|---|---|---|---|
| 灵气 | língqì | linh khí | năng lượng môi trường | `xd_lingji` |
| 灵力 | línglì | linh lực | năng lượng cá nhân | `xd_lingliitem` |
| 法力 | fǎlì | pháp lực | mana | (resource bar) |
| 真元 | zhēnyuán | chân nguyên | true essence | — |
| 神识 | shénshí | thần thức | spiritual sense | (radar widget) |
| 紫府 | zǐfǔ | tử phủ | đan điền | — |
| 经脉 | jīngmài | kinh mạch | meridian | — |
| 本源 | běnyuán | bản nguyên | essence (cấp cao nhất) | (rare drop) |
| 道心 | dàoxīn | đạo tâm | mental willpower | (sanity variant) |
| 妖气 | yāoqì | yêu khí | aura quái | (creature stat) |
| 煞气 | shàqì | sát khí | killing intent | (debuff?) |
| 阴气 | yīnqì | âm khí | yin energy | (night buff) |
| 阳气 | yángqì | dương khí | yang energy | (day buff) |
| 噩梦燃料 | èmèng ránliào | mộng yểm nhiên liệu | nightmare fuel | (port DST) |

### 10.3 Vật phẩm tu chân

| TQ | Pinyin | Hán-Việt | Nghĩa | Prefab |
|---|---|---|---|---|
| 灵石 | língshí | linh thạch | spirit stone | `xd_lingshi` |
| 上品灵石 | shàngpǐn língshí | thượng phẩm linh thạch | grade A | (variant) |
| 极品灵石 | jípǐn língshí | cực phẩm linh thạch | grade S | (variant) |
| 丹药 | dānyào | đan dược | pill | `xd_danyao` |
| 内丹 / 妖丹 | nèidān / yāodān | nội đan / yêu đan | inner pill (drop từ quái) | (creature drop) |
| 法宝 | fǎbǎo | pháp bảo | magic treasure | `xd_lingbao` |
| 灵宝 | língbǎo | linh bảo | spirit treasure | `xd_lingbao` |
| 本命法宝 | běnmìng fǎbǎo | bản mệnh pháp bảo | soul-bound treasure | `xd_lingbaojilian` |
| 祭炼 | jìliàn | tế luyện | bond ritual | `xd_lingbaojilian` |
| 炼丹 / 炼器 | liàndān / liànqì | luyện đan / luyện khí | alchemy / forging | `xd_liandanlu` |
| 丹炉 | dānlú | đan lô | alchemy furnace | `xd_liandanlu` |
| 灵植 / 灵药 | língzhí / língyào | linh thực / linh dược | spirit plant/herb | `xd_plant`, `xd_ylxq` |
| 灵兽 / 灵宠 | língshòu / língchǒng | linh thú / linh sủng | spirit beast / pet | `xd_petleash` |
| 坐骑 | zuòqí | toạ kỵ | mount | `xd_beefalo`, `xd_xianhe` |
| 阵法 | zhènfǎ | trận pháp | spell circle | — |
| 功法 / 心法 | gōngfǎ / xīnfǎ | công pháp / tâm pháp | cultivation method | (recipe?) |
| 秘籍 | mìjí | bí tịch | secret manual | `xd_infobook` |
| 神通 | shéntōng | thần thông | divine power (active skill) | `xd_skillcd` |
| 仙器 / 神器 | xiānqì / shénqì | tiên khí / thần khí | celestial artifact | (top-tier) |
| 福袋 | fúdài | phúc đại | red packet | (red_pouch port) |
| 玲珑宝箱 | línglóng bǎoxiāng | Linh Lung bảo hộp | gacha box | `xd_llbx` |

### 10.4 Sinh vật / cảnh giới sinh vật

| TQ | Pinyin | Hán-Việt | Nghĩa |
|---|---|---|---|
| 妖怪 / 妖兽 | yāoguài / yāoshòu | yêu quái / yêu thú | monster |
| 妖王 / 妖后 | yāowáng / yāohòu | yêu vương / yêu hậu | boss-tier yêu |
| 仙人 | xiānrén | tiên nhân | immortal |
| 金仙 / 大罗 | jīnxiān / dàluó | Kim Tiên / Đại La | cảnh giới thượng tiên |
| 修士 | xiūshì | tu sĩ | cultivator |
| 散仙 | sǎnxiān | tản tiên | wandering immortal |
| 魔尊 / 魔门 | mózūn / mómén | ma tôn / ma môn | demon sect |
| 蛟龙 | jiāolóng | giao long | water dragon (juvenile) |
| 鲲鹏 | kūnpéng | Côn Bằng | giant fish-bird |
| 白虎 / 朱雀 / 玄龟 / 青龙 | bái hǔ / zhū què / xuán guī / qīng lóng | Tứ Linh | four guardian beasts |
| 仙鹤 | xiānhè | tiên hạc | crane |

### 10.5 Loại đan/dược cụ thể

| TQ | Hán-Việt | Công dụng |
|---|---|---|
| 九转金丹 | Cửu Chuyển Kim Đan | (49 ngày luyện, ultimate pill) |
| 定魂丹 | Định Hồn Đan | ổn định linh hồn |
| 破障丹 | Phá Chướng Đan | đột phá cảnh giới |
| 避水珠 | Tị Thuỷ Châu | bơi không chết đuối |
| 壮胆丹 | Tráng Đảm Đan | tăng SAN |
| 饲灵丹 | Tự Linh Đan | pet food |
| 凝神丹 | Ngưng Thần Đan | hồi SAN |
| 筑基丹 | Trúc Cơ Đan | đột phá Trúc Cơ |

### 10.6 Hành động / verb

| TQ | Hán-Việt | Nghĩa game |
|---|---|---|
| 修炼 | tu luyện | grind cảnh giới |
| 闭关 | bế quan | meditation (regen mode) |
| 吐纳 | thổ nạp | breath cultivation |
| 凝神 | ngưng thần | concentrate |
| 调息 | điều tức | rest |
| 飞剑 / 御剑 | phi kiếm / ngự kiếm | flying sword control |
| 缩地成寸 | súc địa thành thốn | teleport |
| 噬魂 | phệ hồn | soul-devour |
| 招魂 | chiêu hồn | summon soul (`xd_wmz_zhf`) |

---

## 11. Kết luận — Các gameplay loop cần implement

Dựa trên phân tích 9 file thoại (40.105 dòng) và 532 prefab/component được phơi bày trong `daxsg_mod_path.txt`, mod **「登仙」** xoay quanh **5 vòng lặp gameplay** sau đây — đây là roadmap người dùng nên tham khảo khi xây dựng mod của mình:

### Loop 1 — Tu luyện căn bản (Daily grind)

> **Thu thập linh khí từ môi trường → tích luỹ tu vi → đột phá cảnh giới → mở khoá skill mới**

- Component cốt lõi: `xd_level`, `xd_savelevel`, `xd_skillcd`
- Nguồn linh khí: hoa cỏ (`xd_flowers`), nguyệt hoa (`xd_lingji`), thiền định (đêm), ăn linh thực
- Đột phá kích hoạt FX thiên kiếp (`xd_lightning`, `xd_stmeteor`)
- Mở khoá theo từng cảnh giới: Trúc Cơ → Kim Đan → Hoá Thần → … → Đại Thừa
- UI: `widgets/xd_levelui`, `xd_dtlevelui`

### Loop 2 — Luyện đan & luyện khí (Crafting xanh)

> **Săn yêu thú → drop nội đan → đem về luyện đan lô (`xd_liandanlu`) → ra đan dược → buff tu luyện vĩnh viễn / tạm thời**

- Component: `xd_dy_buffs`, `xd_lingbao`
- Phẩm cấp đan (lower/mid/upper) đối ứng phẩm cấp linh thạch
- Thời gian luyện rất dài (`xd_time_st` — quote "49 ngày Cửu Chuyển Kim Đan")
- Tương tự luyện khí: phối linh thạch + vật liệu → pháp bảo cấp tăng dần qua `xd_lingbaojilian10`

### Loop 3 — Tế luyện & Bản mệnh pháp bảo (Endgame weapon binding)

> **Mỗi nhân vật có 6-10 pháp bảo cố định → tế luyện từng cái lên cấp tối đa 10 → unlock combo skill / dạng tiến hoá / dạng "bản mệnh"**

- Component: `xd_lingbaojilian`, `xd_lingbaojilian10`, `xd_jilianmanager`
- Hàn Thiên Tôn dùng kiếm controller (`xd_htz_sword_controller`) — gợi ý cơ chế ngự kiếm (phi kiếm điều khiển trên không)
- Vân Tiêu có Hỗn Nguyên Kim Đẩu (`xd_yunxiao_hyjd` + `xd_yunxiao_hytxtele`) — teleport + nhốt
- Bản mệnh pháp bảo có thể là **một vũ khí duy nhất follow theo nhân vật suốt game**

### Loop 4 — Phó bản & Boss biến dị (Endgame raids)

> **Khu vực phó bản (`xd_fb_*`) → đánh trùm biến dị → ra **本源** (bản nguyên, essence) → dùng để mở khoá final tier item**

- Static layout: `xd_kunpeng` (Côn Bằng raid), `xd_choujiangjimap` (lottery zone)
- Boss series:
  - Phó bản: `xd_fb_mutateddeerclops`, `xd_fb_mutatedwarg`, `xd_fb_jfsn`, `xd_fb_lavae`
  - Raid: `xd_ziyunboss` + cả "**series Tử Vân**" (Deerclops/Stalker/Warg version Tử Vân)
  - Côn Bằng, Bạch Hổ, Tiên Hạc, Chu Vương — boss thần thoại nguyên gốc
- UI: `xd_boss_healthbar` cho boss riêng

### Loop 5 — Linh sủng & Toạ kỵ (Companion progression)

> **Bắt sinh vật làm linh sủng (`xd_petleash`) → nuôi đan dược (`饲灵丹`) → lên cấp (`xd_pet_level`) → unlock dạng cao hơn / có thể cưỡi**

- 7+ pet leash variants: `_bjms`, `_cy`, `_fly`, `_mxrg`, `_qy`, `_xinmo` — mỗi loại có brain riêng
- Cưỡi tiên hạc (`xd_xianhe`) khi cảnh giới đủ → unlock chuyển vùng nhanh
- Bạch Hổ (`xd_baihu`) có 2 brain: attack + noattack → tame/befriend mechanic

### Loop phụ — Gacha / Lottery

> Máy `xd_choujiangji` + Linh Lung bảo hộp (`xd_llbx`) — daily reward, item ngẫu nhiên (hỗ trợ free-to-play vibe).

### Loop phụ — Player housing & Quest

> Xây động phủ (`xd_playerhouse`, `xd_interiors`) → đặt pháp bảo (`xd_lingbao`), bồn thuốc (`xd_ylxq`), bàn thờ (`xd_jitan`) trong nhà → quest từ NPC (`xd_renwulingji`).

---

### Gợi ý cuối cùng cho người mod Việt

1. **Bắt đầu từ Loop 1** — không có hệ thống cảnh giới + đột phá thì các loop khác đều không có nền tảng. Implement `xd_level` + đột phá FX (sét đánh) **trước**.
2. **Mỗi nhân vật cần 1 pháp bảo bản mệnh** ngay từ V0.1 — chứ không cần đủ 10 cái như mod gốc. Sword controller của Hàn Thiên Tôn là ví dụ tốt: chỉ 1 vũ khí nhưng có cơ chế **bay/control** đặc trưng tu tiên.
3. **Hệ thống đan dược** là "nội dung trung kỳ" — phải có ít nhất 4-5 đan tiêu biểu (Tráng Đảm, Phá Chướng, Ngưng Thần, Cửu Chuyển) trước khi tính tới raid.
4. **Đừng quên giọng văn**: phong cách 9 nhân vật là **vibe quan trọng nhất** mà mod gốc làm được. Khi viết speech cho nhân vật mới, dùng **đại từ xưng hô đặc biệt** + thuật ngữ Hán-Việt (linh khí, pháp bảo, độ kiếp) để tạo "feel" tiên hiệp ngay lập tức.
5. **Tham khảo wangmazi.lua** cho hệ thống tooltip — đây là nhân vật có DESCRIBE phong phú nhất về phân loại vật liệu (mộc/hoả/thuỷ/âm/dương). Đem áp dụng vào tooltip cho mod của bạn.

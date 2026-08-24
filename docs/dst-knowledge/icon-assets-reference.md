# Icon Assets Reference (borrowed from Dengxian)

All icons below are **placeholder art copied from Dengxian (workshop 3235319974)** —
must be replaced before any public release (see PLACEHOLDER.md).

To use any region in a widget:
```lua
local Image = require("widgets/image")
local icon = self:AddChild(Image("images/<atlas>.xml", "<region>.tex"))
icon:SetSize(W, H)
```

To preview a `.tex` as PNG: `python3 tools/ktex_to_png.py images/<atlas>.tex /tmp/out.png`

---

## images/pn_ui.xml — main cultivation UI atlas

### Đan điền medallions (gourd-on-pedestal, ~186×206 native)
| Region | Content (flame/element inside) |
|---|---|
| `level1.tex` | Luyện Khí — blue flame (Thủy/Water) |
| `level2.tex` | Luyện Khí — purple swirl (mixed / default) |
| `level3.tex` | Luyện Khí — golden yin-yang orb (Kim/Metal) |
| `level4.tex` | Luyện Khí — cyan figure (Mộc/Wood) |
| `level5.tex` | Luyện Khí — golden phoenix (Thổ/Earth) |
| `level6.tex` | Luyện Khí — red flame (Hỏa/Fire) |
| `dtlevel1.tex` | Luyện Thể — golden tree |
| `dtlevel2.tex` | Luyện Thể — golden buddha figure |
| `dtlevel3.tex` | Luyện Thể — golden yin-yang |
| `dtlevel4.tex` | Luyện Thể — golden crystal |
| `dtlevel5.tex` | Luyện Thể — golden beast |
| `dtlevel6.tex` | Luyện Thể — golden flame |

### Bars (progress / health)
| Region | Content |
|---|---|
| `xuetiao1.tex` | wide dragon-framed empty bar (1468×314) |
| `xuetiao2.tex` | rounded brown bar fill (915×53) |
| `xuetiao3.tex` | thin bar segment (left) |
| `xuetiao5/6/7.tex` | more bar segments/fills |

### Panels / frames
| Region | Content |
|---|---|
| `yqdback.tex` | ornate portrait panel frame (412×561) |
| `dtback1.tex` / `dtback2.tex` | small gray / yellow circle backings (102×102) |
| `bysolt.tex` | empty square inventory-slot frame |

---

## images/pn_spell_icons.xml — skill icons (snowflake-framed, Yunxiao/ice theme)
`xd_spell_icons_1.tex` … `xd_spell_icons_8.tex`
Contents: ice crystal, frozen creatures, star burst, lightning, butterfly,
dragon, smoke, snail/rain. Circular icon with a blue snowflake frame.

---

## images/skills/pn_htz_skillicon.xml — Hàn Thiên Tôn skills
`skill1_on/off.tex` … `skill7_on/off.tex` (on = active, off = greyed), plus `button.tex`.
Each is a circular skill button.

## images/skills/pn_wmz_skillicon.xml — Vương Ma Tử skills
`skill1_on/off.tex` … `skill4_on/off.tex`.

## images/skills/pn_wukong_bsicons.xml — Tôn Ngộ Không transform/skill icons
Many: `bearger_on/off`, `deerclops_on/off`, `dragonfly_on/off`, `moose_on/off`,
`mutatedwarg_on/off`, `stalker_atrium_on/off`, `ding`, `he_1/he_2`, etc. —
the 72-transformations + boss-form icons.

---

## How the HUD currently uses these (scripts/widgets/pn_hud_main.lua)
- Medallion centerpiece: `level1-6` picked by primary linh căn element
- Constants `ELEMENT_MEDALLION` + `DEFAULT_MEDALLION` at top of the widget —
  swap region names there to change which icon shows.
- `MEDALLION_W` / `MEDALLION_H` control size.

To switch the HUD to Luyện Thể icons, point those at `dtlevel1-6` instead.

# Phàm Nhân Tu Tiên — DST Mod

A Don't Starve Together mod inspired by the Chinese xianxia novel 《凡人修仙传》(Phàm Nhân Tu Tiên Truyện) by 忘语. Every player starts as a mortal, rolls a random spiritual root (linh căn), and cultivates by absorbing spiritual energy from world resources. Realistic, slow, lifespan-bounded — heroic ascension or death of old age.

**Status:** MVP1 in development. See `docs/superpowers/plans/` for plan-by-plan progress.

## Gameplay loop

1. **Spawn as a phàm nhân** with a random linh căn (Ngụy 65% / Chân 30% / Biến Dị 3% / Thiên 2%).
2. **Find linh mạch huyệt** scattered across the map (3 tiers: Hạ / Trung / Thượng phẩm).
3. **Stand in the aura** to passively accumulate tu vi. Right-click to **tọa thiền** for 1.5× bonus.
4. **Vanilla mobs also cultivate** in the aura — after 5 min they become Linh thú (Tier 1, green glow), after 15 min Yêu tu (Tier 2, red glow).
5. **Kill cultivated mobs** to drop nội đan (3 phẩm) — eat for tu vi burst.
6. **Forage linh thảo** (3 species in forest/grassland/marsh biomes) for tu vi + 5-min buff.
7. **Break through Luyện Khí tiers** (9 stages total) — each tier grants +10 HP, +5% damage, -5% hunger drain, +1% speed, and +5 days lifespan.
8. **Die of old age** when remaining lifespan hits 0. Permadeath — must reroll a new phàm nhân.

## Architecture

```
modinfo.lua  +  modmain.lua  →  entry
scripts/
├── components/                      # 8 server + 4 replicas
│   ├── pn_linhcan{,_replica}        # rolled at spawn, immutable
│   ├── pn_tuvi{,_replica}           # capped accumulator
│   ├── pn_canhgioi{,_replica}       # realm tier + stat deltas
│   ├── pn_lifespan{,_replica}       # decay + permadeath flag
│   ├── pn_meditation                # sit-state for 1.5× bonus
│   ├── pn_aura_source               # radius scanner on linh mạch
│   ├── pn_breakthrough              # threshold detector
│   └── pn_mob_cultivation           # mob-side tier upgrade
├── widgets/
│   ├── pn_hud_main                  # 4-line HUD: linh căn / cảnh giới / tu vi / thọ
│   └── pn_canhgioi_indicator        # overhead label (post-MVP wiring)
├── prefabs/
│   ├── phamnhan                     # the one playable class
│   ├── pn_linhkhi_source            # 3 tier variants
│   ├── pn_noidan                    # 3 phẩm dropped items
│   └── pn_linhthao                  # 3 species foraged items
└── pn/                              # mod-internal data + helpers
    ├── tuning                       # ALL balance constants
    ├── events                       # event name constants
    ├── linhcan_data, realms         # data tables
    ├── actions                      # PN_MEDITATE
    ├── mob_patches                  # AddPrefabPostInit list
    ├── charselect_override          # force phàm nhân only
    └── debug                        # 10 console commands
```

Event-driven design: components communicate via `pn_tuvi_gain`, `pn_canhgioi_up`, `pn_lifespan_tick` events. No direct cross-component mutation.

## Debug commands

Available in the in-game console (`~` key, prefix with `c_remote("...")` from a client):

| Command | Purpose |
|---|---|
| `c_addtuvi(N)` | Add tu vi (respects linh căn multiplier) |
| `c_settier(N)` | Jump to Luyện Khí tầng N (skips threshold) |
| `c_setlinhcan(type, elements)` | Force linh căn (`"THIEN"`, `{"KIM"}`) |
| `c_pnstate()` | Print full cultivation state |
| `c_setlifespan(N)` | Set remaining lifespan |
| `c_dieofold()` | Force death of old age |
| `c_spawnlinhmach(tier)` | Spawn a linh mạch nearby (`"ha"`/`"trung"`/`"thuong"`) |
| `c_aurastate()` | List linh mạch within 20 tiles + their rates |
| `c_mobcult()` | List cultivated mobs nearby |
| `c_giveitem(prefab, N)` | Spawn item(s) in inventory |

## Development

```bash
# Run static checks
./tools/check_syntax.sh
./tools/check_assets.py

# Symlink for local DST client testing (macOS Steam install)
ln -sfn "$PWD" "$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods/pntt_mod"
```

**Mac-specific testing note:** macOS Sonoma+ blocks writes to the Steam-installed `.app` bundle's `Contents/mods/modsettings.lua` (so `ForceEnableMod` workflow doesn't work). For runtime testing, either upload a private Workshop build or deploy via the `dst-server-docker` repo on a Linux VPS. See `memory/macos_dst_mod_loading.md` for details.

## References

- `docs/superpowers/specs/2026-05-24-pntt-mod-design.md` — full design spec
- `docs/superpowers/plans/` — incremental plan docs (1 per milestone)
- `dengxian_architecture.md`, `dengxian_gameplay_glossary.md`, `dengxian_wiki_data.md` — reference analysis of the Dengxian (登仙) mod that inspired this project
- `Đăng-Tiên.pdf` — community wiki of Dengxian (186 pages, Vietnamese)
- Source novel: 凡人修仙传 (Han Li's cultivation system, especially linh căn classifications)

## Credits

- Vision & design: kimdat546
- Implementation: kimdat546 with [Claude Code](https://claude.com/claude-code)
- Placeholder portrait assets: temporarily borrowed from Dengxian mod (workshop ID 3235319974); see `PLACEHOLDER.md` for replacement plan before public release.
- Cultivation system inspired by Chinese xianxia novels, particularly 《凡人修仙传》 by 忘语.

## License

Not yet licensed. Workshop publication will add a license file.

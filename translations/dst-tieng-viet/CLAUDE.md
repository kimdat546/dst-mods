# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Vietnamese localization mod for **Don't Starve Together (DST)**, a Klei Entertainment multiplayer survival game. Distributed via Steam Workshop (ID: `3683660917`).

## Commands

### Quality check (format string errors)
```bash
python3 tools/quality_check.py vietnamese.po --format-only
```

### Sync check (detect untranslated strings after a game update)
```bash
python3 tools/sync_check.py game_source/strings.pot vietnamese.po --output-dir sync_reports/
```

### Upload mod to Steam Workshop

The clean upload directory is `/Users/kimdat546/Desktop/dst-viet-mod/`. It contains only the files needed for Workshop.

**Step 1 — Sync files to the clean upload directory:**
```bash
rsync -av \
  modinfo.lua modmain.lua vietnamese.po \
  DST_Vietnamese.tex DST_Vietnamese.xml \
  mod.manifest preview.png \
  /Users/kimdat546/Desktop/dst-viet-mod/

rsync -av --delete scripts/ /Users/kimdat546/Desktop/dst-viet-mod/scripts/
```

**Step 2 — Update version in** `/Users/kimdat546/Desktop/dst-viet-mod/modinfo.lua`:
- `version` → increment (e.g. `"2026.2"` → `"2026.3"`)
- `description` → update the "Cập nhật lần cuối ngày..." date line

**Step 3 — Upload via Don't Starve Mod Tools:**
1. Steam → Library → **Don't Starve Mod Tools** → Play
2. Select **Upload Existing Mod**
3. Choose folder: `/Users/kimdat546/Desktop/dst-viet-mod/`
4. Enter Workshop ID: `3683660917`
5. Click **Upload**

### Get a new strings.pot after a game update
Extract from: `~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip`

## Architecture

### Translation Pipeline

1. **`modmain.lua`** — Entry point. Sets up `mods.VietnameseLang` global config table and imports `scripts/main.lua`.
2. **`scripts/main.lua`** — Calls `LoadPOFile("vietnamese.po")` to parse translations into `mods.VietnameseLang.PO`, then applies them to the game's `STRINGS` global via `TranslateStringTable()`.
3. **`scripts/textfix/init.lua`** — Hooks `TextWidget.SetString()` to intercept dynamic UI text at render time and apply translations not covered by the `.po` file.
4. **`scripts/textfix/ui_gamesetup.lua`** — Populates the `textfix` lookup table for game mode options, world gen UI, lobby screens.
5. **`scripts/textfix/character_speech.lua`** — Populates the `textfix` table for character skill trees, speech, and item descriptions (~70k lines).

### Two-layer translation approach

- **Layer 1 (`.po` file):** Covers ~84,968 static game strings loaded at startup via the game's built-in `LoadPOFile()` API.
- **Layer 2 (`textfix`):** Covers dynamic/runtime UI text that bypasses the PO system, intercepted via a `TextWidget.SetString` hook.

### Key files

| File | Role |
|---|---|
| `vietnamese.po` | Main translation database (17.9 MB, 425k lines) |
| `game_source/strings.pot` | Game's original translation template — reference only, not uploaded |
| `tools/sync_check.py` | Detects new/changed/removed strings when game updates |
| `tools/quality_check.py` | Validates format string consistency (`%s`, `{winner}`, etc.) |
| `sync_reports/` | Output from QA tools — not uploaded to Workshop |

### What NOT to upload to Workshop

`game_source/`, `tools/`, `sync_reports/`, `CLAUDE.md`, and any dev tooling. Only upload the files listed in `README.md`.

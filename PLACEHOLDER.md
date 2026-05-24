# Placeholder assets — must replace before public release

The following assets are **temporarily copied from Dengxian mod (Steam Workshop ID 3235319974)** for MVP1 development testing:

**Portrait images (from xd_wangmazi character):**
- `modicon.tex` / `modicon.xml`
- `images/saveslot_portraits/phamnhan.*`
- `bigportraits/phamnhan.*`
- `images/map_icons/phamnhan.*`
- `images/avatars/avatar_phamnhan.*`
- `images/avatars/avatar_ghost_phamnhan.*`
- `images/names_phamnhan.*`

**Character animation build (from xd_hantianzun character, added 2026-05-24):**
- `anim/xd_hantianzun.zip` — the body anim build, referenced via `SetBuild("xd_hantianzun")` in `scripts/prefabs/phamnhan.lua`
- `anim/ghost_xd_hantianzun_build.zip` — ghost form build

These were copied because:
- We have not yet commissioned original art for the phàm nhân character
- A working anim build is required for the character to appear visible in-game
- The Dengxian mod is widely played in the Vietnamese DST community; players may recognize the visual but it is clearly understood as alpha placeholder

**MUST be replaced with original art before any public release** (Workshop publish at public visibility, screenshots in marketing, etc.). Currently the mod is uploaded as Unlisted to a single tester's account; this is acceptable for internal alpha.

Original art commissioning is part of Plan 7+ (Polish).

## Removing placeholders

When ready to ship real art:
1. Replace each file above with the original asset
2. Delete this PLACEHOLDER.md file
3. Remove the `xd_hantianzun` references from `scripts/prefabs/phamnhan.lua` (change SetBuild back to the proper character build name)
4. Optionally adjust portrait file paths if you've renamed assets

## Credit

Dengxian mod authors: 薪人小黄, 路障僵尸, 吃không吃大肉丸子. The mod has not been formally contacted re: placeholder use; remove all assets before any public/Workshop-public visibility.

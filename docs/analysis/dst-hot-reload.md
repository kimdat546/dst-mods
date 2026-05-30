# DST HUD hot-reload: iterating on `pn_hud_dantian` without quitting

Goal: tweak the size/position of our client HUD widget (`ThePlayer.HUD.controls.pn_hud`,
instance of `scripts/widgets/pn_hud_dantian.lua`) fast — without the
`edit → Cmd+Q → relaunch → host → check` loop.

Context recap of the widget (from `scripts/widgets/pn_hud_dantian.lua`):

- `self.medallion` — `Image`, sized `MED_W x MED_H` where `MED_H = 96`,
  `MED_W = floor(MED_H * 186 / 206)`.
- `self.tuvi_text` — `Text`, positioned at `(0, -(MED_H * 0.33))`.
- `self.canhgioi_text` — `Text`, positioned at `(0, -(MED_H/2) - 12)`.
- `OnUpdate` re-applies `medallion:SetSize(MED_W, MED_H)` after any texture swap.

---

## TL;DR — recommended workflow

**Add a `c_pnhud(height, yfactor)` debug command (Option 5) that live-resizes the
EXISTING widget in place, with no file reload and no rehost.** Type a number, press
Enter, see the result instantly. Iterate to convergence in seconds, then bake the
final numbers into the source file once. This is the highest-value option and the
exact code is given below.

Ranking by practicality:

1. **`c_pnhud(h, yf)` live-tweak command** — best. Zero reload, instant feedback.
2. **Console one-liner that mutates the live widget** — same idea, no code to add, but verbose to retype.
3. **Console re-create of the widget from an edited file** (`package.loaded[...]=nil` + require) — works, picks up disk edits, but heavier and has caveats.
4. **`c_reset()`** — does NOT reload mod Lua; only use to reset the world sim. Not useful here.
5. **Reduce rehost cost** (dedicated test slot, skip-intro launch) — fallback for changes that genuinely need a full reload (assets, modmain wiring).

---

## 1. `c_reset()` — does it reload mod Lua from disk?

**No.** `c_reset()` does not re-run `modmain`, `AddClassPostConstruct`, prefab files,
or widget files. It only resets the world simulation using **already-loaded Lua**.

From `reference/dst-scripts/scripts/consolecommands.lua`:

```lua
function c_reset()
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_reset()")
        return
    end
    if not InGamePlay() then
        StartNextInstance()                       -- front-end: relaunch into a slot
    elseif TheWorld ~= nil and TheWorld.ismastersim then
        TheNet:SendWorldRollbackRequestToServer(0) -- in-game: roll back to last save
    end
end
```

- In-game it calls `SendWorldRollbackRequestToServer(0)` — identical to `c_rollback(0)`.
  This reloads the **world save**, not your scripts.
- `doreset()` / the front-end path uses `StartNextInstance{ reset_action = RESET_ACTION.LOAD_SLOT }`
  which restarts the sim instance. Mod scripts are re-evaluated only on a true process/sim
  restart — and even then the Lua VM caches modules (see §3 caveat).
- `c_regenerateworld()` / `c_regenerateshard()` wipe/regenerate the world. Irrelevant to
  HUD layout and slower than a rehost.

Related: there is **no built-in "reload mods" console command or hotkey** in DST. Klei's
own fast-iteration story relies on the console for live object mutation (see `c_doscenario`,
which is the only place in the codebase that deliberately busts `package.loaded` to re-read
a file from disk: `package.loaded["scenarios/"..scenario] = nil`).

**Conclusion:** `c_reset()` is useless for picking up an edited widget file. Skip it.

---

## 2. Live widget recreation via console

Two flavors. Both run from the in-game console (`~`) on the client (the HUD is
client-side, so no `c_remote` needed).

### 2a. Mutate the existing instance (no file involved) — fast, safe

The widget object is live in memory. You can poke it directly:

```lua
-- move it
ThePlayer.HUD.controls.pn_hud:SetPosition(-200, 120)
-- resize the medallion and re-place the texts to match a new height H
local w = ThePlayer.HUD.controls.pn_hud
local H = 120
local W = math.floor(H * 186 / 206)
w.medallion:SetSize(W, H)
w.tuvi_text:SetPosition(0, -(H * 0.33))
w.canhgioi_text:SetPosition(0, -(H/2) - 12)
```

Caveat: our `OnUpdate` re-applies `medallion:SetSize(MED_W, MED_H)` **every frame on
texture change**, using the module-level `MED_H`/`MED_W`. As long as the texture doesn't
change, your console `SetSize` sticks. If the medallion swaps mid-test it snaps back to 96.
The `c_pnhud` command in §5 fixes this permanently by storing the height on the instance.

### 2b. Re-create from an edited file (`package.loaded` bust + re-require) — picks up disk edits

DST's `require` caches every loaded module in `package.loaded[name]`. Mod files are loaded
into the mod's environment; the widget was pulled in via `require("widgets/pn_hud_dantian")`
(adjusted to the mod's namespaced path). To force a fresh read from disk you must clear the
cache entry, then re-require, then rebuild the instance:

```lua
-- 1. find the controls widget that owns our HUD
local controls = ThePlayer.HUD.controls
-- 2. kill the old instance
if controls.pn_hud then controls.pn_hud:Kill(); controls.pn_hud = nil end
-- 3. bust the cached module so require reads the edited .lua from disk
package.loaded["widgets/pn_hud_dantian"] = nil
-- 4. re-require and re-add
local PnHud = require("widgets/pn_hud_dantian")
controls.pn_hud = controls:AddChild(PnHud(ThePlayer))
```

Caveats and reality check:

- **Path/namespace:** inside a mod, scripts are resolved under the mod's environment. The
  exact key in `package.loaded` may be the bare `"widgets/pn_hud_dantian"` OR a mod-prefixed
  path, depending on how `modmain` referenced it. If the bare key doesn't exist, dump the
  table to find it: `for k in pairs(package.loaded) do if k:find("pn_hud") then print(k) end end`.
- **`kleiloadlua`:** DST's `require` ultimately calls the engine loader `kleiloadlua(path)` to
  compile the file. Once you clear `package.loaded[key]`, the next `require` recompiles from
  disk — so your edits ARE picked up. This is exactly how `c_doscenario` re-reads scenario
  files for testing.
- **Console sandbox:** the in-game console runs in the GLOBAL env, not the mod env, so a bare
  `require(...)` may not resolve mod-local paths or upvalues (`LinhCanData`, `ATLAS`). If it
  errors, fall back to 2a / §5 which need no re-require.
- This is heavier than 2a and only worth it if you've changed *logic* in the file, not just
  layout numbers. For pure size/position, use §5.

---

## 3. Enabling the in-game Lua console + reload hotkeys

- **Enable the console:** in `settings.ini` (macOS:
  `~/Documents/Klei/DoNotStarveTogether/settings.ini`) under `[MISC]`:

  ```ini
  [MISC]
  ENABLECONSOLE = true
  ```

  Then `~` (or your bound key) opens the console in-game.

- **Enable debug keys** (for `c_select`, reload-ish helpers, free camera): in
  `scripts/main.lua` the flag is `CHEATS_ENABLED` / `DEBUGTOOLS`. For a workshop dev build
  you typically also set `Set("ENABLECONSOLE","true")`. With debug keys on, **Ctrl+R** is the
  built-in "reload the front-end screen" in some Klei builds, but it does **not** reload mod
  Lua and is unreliable across versions — do not rely on it.

- **Built-in "reload mods without quit": none.** There is no such command. The only
  deliberate hot-reload mechanism in the scripts is the manual `package.loaded[x]=nil` +
  re-require pattern (§2b).

---

## 4. Reducing restart cost (when a full reload is unavoidable)

For changes that genuinely need re-running `modmain`/`AddClassPostConstruct` (new assets,
changed widget *wiring*), minimize the host loop:

- **Keep a dedicated tiny test save slot** already generated (small world / "Survival" with
  a flat preset). Re-hosting an existing slot skips worldgen entirely.
- **Skip the intro/menus:** with the console enabled you can chain from the main menu, but the
  simplest is: keep DST running, leave to main menu (don't Cmd+Q), Play → Host → your test
  slot → Resume. This avoids the multi-second process relaunch and Steam handshake.
- **Launch flags:** add to Steam launch options to cut startup: `-disableintro` (skip the
  logo movie). There is no supported flag that auto-hosts a slot.
- **Tiny client-only HUD-preview mod:** you can make a separate `client_only_mod = true`
  test mod whose `modmain` does `AddClassPostConstruct("widgets/controls", ...)` to attach a
  preview of the medallion that re-reads a value from a global each frame — but this is
  strictly worse than §5 because you still rehost to load it. Prefer §5.

Even at its best, this loop is seconds-to-tens-of-seconds. For layout numbers it is never
the right tool — use §5.

---

## 5. (Highest value) `c_pnhud(height, yfactor)` — live resize/reposition, zero reload

Tweak the medallion height and the tu-vi vertical factor live, by typing a number in the
console and pressing Enter. No file reload, no rehost, no texture-swap snap-back.

### Code to add to `scripts/main/debug.lua`

```lua
-- Live-tweak the PN HUD medallion size/position WITHOUT reloading anything.
--   c_pnhud()            -> print current values
--   c_pnhud(120)         -> set medallion height to 120 (width auto from 186:206 ratio)
--   c_pnhud(120, 0.40)   -> also set tu-vi text vertical factor (default 0.33)
function GLOBAL.c_pnhud(height, yfactor)
    local player = GLOBAL.ThePlayer
    local hud = player and player.HUD
    local w = hud and hud.controls and hud.controls.pn_hud
    if not w then print("[PN] pn_hud widget not found on HUD") return end

    -- read current/default state, persisted on the instance so OnUpdate won't fight us
    local H  = height  or w._dbg_H  or 96
    local YF = yfactor or w._dbg_YF or 0.33
    local W  = math.floor(H * 186 / 206)

    -- store so a later texture swap re-applies THESE values, not the file's MED_H
    w._dbg_H, w._dbg_YF = H, YF

    w.medallion:SetSize(W, H)
    w.tuvi_text:SetPosition(0, -(H * YF))
    w.canhgioi_text:SetPosition(0, -(H / 2) - 12)

    print(string.format("[PN] c_pnhud  H=%d  W=%d  yfactor=%.2f", H, W, YF))
end

print("[PN] debug loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_pnhud")
```

### One-line companion to also drag it into place live

```lua
-- nudge the whole widget; right-click-drag already saves position via SavePos
ThePlayer.HUD.controls.pn_hud:SetPosition(-210, 110)
```

### Making the live values "stick" against `OnUpdate`

Our `OnUpdate` re-applies `medallion:SetSize(MED_W, MED_H)` only when the texture changes.
To make `c_pnhud` fully robust, update the widget's `OnUpdate` to prefer the instance debug
values when present. Optional one-line change in `pn_hud_dantian.lua`:

```lua
-- inside OnUpdate, replace the SetSize line after SetTexture with:
local h = self._dbg_H or MED_H
self.medallion:SetSize(math.floor(h * 186 / 206), h)
```

### Iteration loop with `c_pnhud`

1. `~` to open console, type `c_pnhud(110)` → Enter. See it instantly.
2. Try `c_pnhud(96)`, `c_pnhud(120, 0.40)`, etc. until it looks right.
3. Note the converged `H`/`yfactor`, edit `MED_H` and the `tuvi_text` factor in
   `scripts/widgets/pn_hud_dantian.lua` once, commit.

Total feedback time per try: ~1 second. No quit, no rehost, no file reload.

---

## Notes / gotchas

- The HUD is **client-side**; all the above runs locally — no `c_remote()` wrapping needed.
- `debug.lua` is loaded once at mod init (it prints its banner). Adding `c_pnhud` there means
  it is available the first time you host after the next launch — that one relaunch is the
  last full restart you need for layout work.
- If you ever edit `debug.lua` itself and want it live without relaunch, paste the function
  body straight into the console (it's just a `GLOBAL.c_pnhud = function(...) ... end`).

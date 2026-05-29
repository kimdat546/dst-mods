# Making a custom held-weapon swap build (texture-swap method)

Reliable way to give a weapon a real in-hand appearance using your own art,
without a Spriter/autocompiler pipeline.

1. Extract a vanilla swap build whose shape is close (e.g. swap_spear.zip from
   DST .../Contents/data/anim/swap_spear.zip) → atlas-0.tex + build.bin
2. Decode atlas:  python3 tools/ktex_to_png.py atlas-0.tex /tmp/atlas.png
3. Detect the sprite bounding boxes (alpha components) in the atlas.
4. Rotate/scale YOUR art to match each frame's orientation+box; composite into
   a new 512x512 atlas at the SAME positions (so build.bin UVs still line up).
5. Re-encode:  python3 tools/png_to_ktex.py /tmp/new_atlas.png atlas-0.tex
6. Rename the build.bin internal BILD name (NOT the symbol) so it doesn't
   collide with the vanilla build. (symbol stays e.g. "swap_spear")
7. zip atlas-0.tex build.bin -> anim/swap_<yourname>.zip
8. In the weapon prefab:
   - ground/world: SetBank("spear"); SetBuild("swap_<yourname>")
   - onequip: owner.AnimState:OverrideSymbol("swap_object", "swap_<yourname>", "swap_spear")
   - assets: Asset("ANIM","anim/spear.zip") for the bank + Asset("ANIM","anim/swap_<yourname>.zip")

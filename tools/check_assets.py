#!/usr/bin/env python3
"""Verify all Asset() references in .lua files point to existing files,
and all .xml atlas references point to existing .tex files."""

import re
import sys
from pathlib import Path

MOD_ROOT = Path(__file__).parent.parent
ASSET_RE = re.compile(r'Asset\s*\(\s*"([A-Z]+)"\s*,\s*"([^"]+)"\s*\)')
XML_TEX_RE = re.compile(r'<Texture\s+filename="([^"]+)"')

def main() -> int:
    errors = []

    for lua_file in MOD_ROOT.rglob("*.lua"):
        if "reference" in lua_file.parts or ".git" in lua_file.parts:
            continue
        text = lua_file.read_text(encoding="utf-8", errors="ignore")
        for kind, path in ASSET_RE.findall(text):
            full = MOD_ROOT / path
            if not full.exists():
                errors.append(f"{lua_file.relative_to(MOD_ROOT)}: Asset(\"{kind}\", \"{path}\") not found")

    for xml in MOD_ROOT.rglob("*.xml"):
        if "reference" in xml.parts or ".git" in xml.parts:
            continue
        text = xml.read_text(encoding="utf-8", errors="ignore")
        for tex_ref in XML_TEX_RE.findall(text):
            tex_path = xml.parent / tex_ref
            if not tex_path.exists():
                errors.append(f"{xml.relative_to(MOD_ROOT)}: <Texture filename=\"{tex_ref}\"> not found")

    if errors:
        for e in errors:
            print(f"✗ {e}")
        print(f"\n✗ {len(errors)} asset reference error(s)")
        return 1

    print("✓ All asset references valid")
    return 0

if __name__ == "__main__":
    sys.exit(main())

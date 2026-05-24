#!/usr/bin/env python3
"""Rename the internal build name inside a Klei build.bin file.

DST character mods need anim/<charname>.zip with internal build name = <charname>.
When we reuse another character's build (e.g. Hàn Thiên Tôn's xd_hantianzun.zip
as a placeholder for phamnhan), we need to:
  1. Patch build.bin to change build name from "xd_hantianzun" -> "phamnhan"
  2. Repack the zip as anim/phamnhan.zip

build.bin format (community-reverse-engineered):
  Magic: "BILD"        4 bytes
  Version: u32         4 bytes
  NumSymbols: u32      4 bytes
  NumFrames: u32       4 bytes
  BuildName: pstring   4-byte length + N chars
  NumAtlases: u32
  ... (rest is symbol data)
"""

import struct, sys, zipfile, shutil
from pathlib import Path


def patch_build_name(build_bin_path: Path, new_name: str) -> bytes:
    data = build_bin_path.read_bytes()
    if data[:4] != b"BILD":
        raise ValueError(f"not a build.bin file (magic = {data[:4]!r})")

    # Header is 16 bytes: BILD + version + numsymbols + numframes
    offset = 16
    old_len = struct.unpack_from("<I", data, offset)[0]
    old_name = data[offset + 4 : offset + 4 + old_len].decode("ascii")

    print(f"  Found internal build name: {old_name!r} (len {old_len})")
    print(f"  Renaming to:               {new_name!r} (len {len(new_name)})")

    # Build new bytes: header unchanged + new pstring + rest unchanged
    new_pstring = struct.pack("<I", len(new_name)) + new_name.encode("ascii")
    rest = data[offset + 4 + old_len :]
    return data[:offset] + new_pstring + rest


def main():
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} <source.zip> <new_build_name> <output.zip>")
        sys.exit(1)

    src_zip = Path(sys.argv[1])
    new_name = sys.argv[2]
    out_zip = Path(sys.argv[3])

    print(f"Source: {src_zip}")
    print(f"Output: {out_zip}")

    # Unpack
    work_dir = Path("/tmp/rename_build_work")
    if work_dir.exists():
        shutil.rmtree(work_dir)
    work_dir.mkdir(parents=True)

    with zipfile.ZipFile(src_zip, "r") as z:
        z.extractall(work_dir)

    # Patch build.bin
    build_bin = work_dir / "build.bin"
    if not build_bin.exists():
        print(f"✗ no build.bin found in {src_zip}")
        sys.exit(2)

    new_data = patch_build_name(build_bin, new_name)
    build_bin.write_bytes(new_data)

    # Repack zip — preserve original member ordering
    out_zip.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
        with zipfile.ZipFile(src_zip, "r") as src_z:
            for info in src_z.infolist():
                member_path = work_dir / info.filename
                z.write(member_path, info.filename)

    print(f"✓ Wrote {out_zip} ({out_zip.stat().st_size} bytes)")


if __name__ == "__main__":
    main()

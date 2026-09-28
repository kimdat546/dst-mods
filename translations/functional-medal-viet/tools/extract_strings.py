#!/usr/bin/env python3
"""Rút MỌI chuỗi của Functional Medal ra strings_source.json.

⚠ BẢN ĐẦU DÒ BẰNG REGEX VÀ BÁO SAI "100%". Nó chỉ bắt dạng
  `STRINGS.X.Y = "..."` nên được 856 chuỗi, trong khi file thật sinh ra 1.568 —
  mọi bảng khai kiểu `STRINGS.X = { ... }` đều lọt lưới. Giờ chạy thẳng file
  Lua trong hộp cát (tools/rut_chuoi.lua): mod gán gì thì mình thấy nấy.

Hai nguồn:
  scripts/lang/medal_strings_eng.lua       -> loai "strings"  (bảng STRINGS)
  scripts/medal_defs/medal_exam_defs_en.lua -> loai "exam"     (49 câu đề thi)

Mỗi mục:
  p     đường dẫn thô, giữ KIỂU khoá (s:chữ / n:số) — build.py cần để áp đúng
  en    chuỗi tiếng Anh (bản mod dùng khi language_switch = eng)
  zh    chuỗi tiếng Trung cùng đường dẫn, nếu có — để đối chiếu nghĩa
  vi    bản dịch (GIỮ LẠI khi chạy lại)
  wiki  cơ chế vật phẩm tra từ guanziheng.com, nếu có
"""

import json
import pathlib
import subprocess
import sys

GOC = pathlib.Path(__file__).resolve().parent.parent
MOD = pathlib.Path(
    "~/Library/Application Support/Steam/steamapps/workshop/content/322330/1909182187"
).expanduser()


def rut(che_do, tep):
    ra = subprocess.run(
        ["luajit", str(GOC / "tools" / "rut_chuoi.lua"), che_do, str(tep)],
        capture_output=True, text=True, check=True,
    ).stdout
    muc = {}
    for dong in ra.splitlines():
        p, _, v = dong.partition("\t")
        v = v.replace("\\t", "\t").replace("\\n", "\n").replace("\\\\", "\\")
        muc[p] = v
    return muc


def ten_hien(p, tien_to=""):
    """s:NAMES/s:X -> NAMES.X ; s:A/n:1 -> A[1]. Khớp khoá cũ của bản đầu."""
    ra = tien_to
    for doan in p.split("/"):
        kieu, _, k = doan.partition(":")
        if kieu == "n":
            ra += f"[{k}]"
        else:
            ra += ("." if ra else "") + k
    return ra


def main():
    goc = pathlib.Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else MOD
    en = rut("strings", goc / "scripts/lang/medal_strings_eng.lua")
    zh = rut("strings", goc / "scripts/lang/medal_strings_ch.lua")
    thi = rut("bang", goc / "scripts/medal_defs/medal_exam_defs_en.lua")

    tep = GOC / "strings_source.json"
    cu = json.loads(tep.read_text(encoding="utf-8")) if tep.exists() else {}

    ra = {}
    for p, v in en.items():
        k = ten_hien(p)
        m = {"loai": "strings", "p": p, "en": v, "zh": zh.get(p, ""),
             "vi": cu.get(k, {}).get("vi", "")}
        if "wiki" in cu.get(k, {}):
            m["wiki"] = cu[k]["wiki"]
        ra[k] = m
    for p, v in thi.items():
        k = ten_hien(p, "EXAM")
        ra[k] = {"loai": "exam", "p": p, "en": v, "zh": "",
                 "vi": cu.get(k, {}).get("vi", "")}

    mat = [k for k in cu if cu[k].get("vi") and k not in ra]
    tep.write_text(json.dumps(ra, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
                   encoding="utf-8")
    xong = sum(1 for m in ra.values() if m["vi"])
    print(f"{len(ra)} chuỗi ({len(en)} STRINGS + {len(thi)} đề thi), đã dịch {xong}")
    if mat:
        print(f"⚠ {len(mat)} bản dịch cũ không còn khoá tương ứng (mod gốc đã đổi/bỏ):")
        for k in mat[:10]:
            print("   ", k)
    return 0


if __name__ == "__main__":
    sys.exit(main())

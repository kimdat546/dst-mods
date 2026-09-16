#!/usr/bin/env python3
"""Rút chuỗi của Functional Medal ra strings_source.json.

⚠ VÌ SAO KHÔNG FORK MOD GỐC. Nó hardcode đúng hai nhánh ngôn ngữ:

    if TUNING.MEDAL_LANGUAGE == "ch" then require "lang/medal_strings_ch"
    else                                require "lang/medal_strings_eng" end

Không có móc mở rộng như Montfluv (mod đó nạp theo tên thư mục nên chỉ cần thêm
translation_vi/). Nên cách duy nhất không phải fork là GHI ĐÈ `STRINGS` sau khi
mod gốc đã nạp xong.

⚠ VÀ ĐÓ CŨNG LÀ LÝ DO BẢN DỊCH AN TOÀN KHI SERVER KHÔNG BẬT MOD GỐC. `STRINGS`
  là bảng toàn cục của game; gán một khoá không ai đọc thì không có gì xảy ra.
  Không cần kiểm tra mod có tồn tại hay không.

Nguồn đối chiếu:
  scripts/lang/medal_strings_eng.lua   tiếng Anh (bản mod dùng)
  scripts/lang/medal_strings_ch.lua    tiếng Trung (bản gốc tác giả viết)
  wiki/medal_item_data.js              cơ chế từng vật phẩm, tra từ guanziheng.com
"""

import json
import pathlib
import re
import sys

GOC = pathlib.Path(
    "~/Library/Application Support/Steam/steamapps/workshop/content/322330/1909182187"
).expanduser()

# Bắt cả ba họ khoá mà mod dùng.
MAU = re.compile(
    r'STRINGS\.(NAMES|RECIPE_DESC|CHARACTERS\.GENERIC\.DESCRIBE)\.([A-Z0-9_]+)\s*=\s*(".*?"|\[\[.*?\]\])',
    re.S,
)


def doc_chuoi(tep):
    """khoá đầy đủ -> chuỗi. Giữ nguyên thứ tự xuất hiện trong file."""
    if not tep.exists():
        return {}
    noi = tep.read_text(encoding="utf-8", errors="replace")
    ra = {}
    for ho, ten, gia in MAU.findall(noi):
        khoa = f"{ho}.{ten}"
        v = gia.strip()
        v = v[2:-2] if v.startswith("[[") else v[1:-1]
        ra[khoa] = v
    return ra


def doc_wiki(tep):
    """item_code (viết hoa) -> thông tin cơ chế, để dịch cho đúng nghĩa."""
    if not tep.exists():
        return {}
    noi = tep.read_text(encoding="utf-8-sig", errors="replace")
    try:
        ds = json.loads(noi[noi.index("[") : noi.rindex("]") + 1])
    except ValueError:
        return {}
    ra = {}
    for d in ds:
        ma = (d.get("item_code") or "").strip().upper()
        if not ma:
            continue
        ra[ma] = {
            "ten_tq": d.get("item_name", ""),
            "co_che": d.get("item_function", ""),
            "nguyen_lieu": d.get("item_cailiao", ""),
            "ban_cong": d.get("item_zhizuolan", ""),
            "may": d.get("item_keji", ""),
        }
    return ra


def main():
    goc = pathlib.Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else GOC
    lang = goc / "scripts" / "lang"
    en = doc_chuoi(lang / "medal_strings_eng.lua")
    ch = doc_chuoi(lang / "medal_strings_ch.lua")
    if not en:
        print(f"không đọc được chuỗi trong {lang}", file=sys.stderr)
        return 1

    here = pathlib.Path(__file__).resolve().parent.parent
    wiki = doc_wiki(here / "wiki" / "medal_item_data.js")

    cu = {}
    tep_ra = here / "strings_source.json"
    if tep_ra.exists():
        cu = json.loads(tep_ra.read_text(encoding="utf-8"))

    ra, giu = {}, 0
    for khoa in en:
        ten = khoa.rsplit(".", 1)[1]
        muc = {
            "en": en[khoa],
            "zh": ch.get(khoa, ""),
            # ⚠ Giữ lại bản dịch cũ khi chạy lại. Không giữ thì mỗi lần mod gốc
            #   cập nhật là mất sạch công dịch.
            "vi": cu.get(khoa, {}).get("vi", ""),
        }
        if muc["vi"]:
            giu += 1
        w = wiki.get(ten)
        if w and any(w.values()):
            muc["wiki"] = w
        ra[khoa] = muc

    tep_ra.write_text(
        json.dumps(ra, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    co_wiki = sum(1 for v in ra.values() if "wiki" in v)
    print(f"{len(ra)} chuỗi ({giu} đã dịch từ trước, {co_wiki} có cơ chế từ wiki)")
    print(f"-> {tep_ra}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

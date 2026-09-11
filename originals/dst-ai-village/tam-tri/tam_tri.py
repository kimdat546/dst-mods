#!/usr/bin/env python3
"""Dịch vụ suy nghĩ cho dân làng AI Làng.

Vòng lặp: đọc câu hỏi mod ghi ra -> hỏi bộ não -> ghi câu trả lời.
Không có web framework, không có phụ thuộc ngoài — chỉ thư viện chuẩn Python.

Chạy:
    AILANG_NAO=luat   python3 tam_tri.py /duong/dan/toi/save
    AILANG_NAO=gemini GEMINI_API_KEY=... python3 tam_tri.py /save
"""

import os
import pathlib
import sys
import time

import backends
import giao_thuc

NHIP = float(os.environ.get("AILANG_NHIP", "2"))


def main():
    if len(sys.argv) < 2:
        print("dùng: tam_tri.py <thư mục save của world>", file=sys.stderr)
        return 2

    thu_muc = pathlib.Path(sys.argv[1])
    ten_nao = os.environ.get("AILANG_NAO", "luat")
    nao = backends.lay(ten_nao)

    print(f"[tam-tri] não={ten_nao} thư_mục={thu_muc} nhịp={NHIP}s", flush=True)
    if not thu_muc.is_dir():
        print(f"[tam-tri] CHƯA CÓ thư mục {thu_muc} — chờ mod tạo...", flush=True)

    nhip_cu = None
    while True:
        try:
            goi = giao_thuc.doc_hoi(thu_muc)
            if goi is not None and goi.get("nhip") != nhip_cu:
                nhip_cu = goi.get("nhip")
                ra = nao.nghi(goi)
                giao_thuc.ghi_dap(thu_muc, ra)
                tom = ", ".join(
                    f"{d.get('ten', d['ma'])}->{y.get('muc_tieu')}"
                    for d, y in zip(goi.get("dan_lang", []), ra))
                print(f"[tam-tri] nhịp {nhip_cu}: {tom}", flush=True)
        except Exception as e:  # vòng lặp dịch vụ, chết là mất cả tầng suy nghĩ
            print(f"[tam-tri] lỗi vòng lặp: {type(e).__name__}: {e}", flush=True)
        time.sleep(NHIP)


if __name__ == "__main__":
    sys.exit(main() or 0)

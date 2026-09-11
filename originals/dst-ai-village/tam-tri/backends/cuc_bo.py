"""Não bằng model chạy local (Ollama hoặc bất cứ thứ gì nói giọng OpenAI).

⚠ ĐỪNG chạy trên chính con ThinkPad đang gánh server. Đo ngày 11/09/2026:
  i5-8250U (4 nhân ULV 1.6GHz), 7,7 GB RAM mà DST đã ăn 5 GB — chỉ còn 2,7 GB
  trống, GPU là UHD 620 không tính toán được. Nhét thêm model vào đó là tranh
  CPU với vòng lặp sim của DST, và sim DST nhạy với độ trễ.

  Muốn chạy local thì để trên máy khác rồi trỏ AILANG_URL qua Tailscale —
  Mac mini (100.64.0.2) là chỗ hợp lý, Apple Silicon chạy Ollama nhẹ nhàng.
"""

import json
import os
import urllib.error
import urllib.request

from . import MUC_TIEU, luat
from .gemini import HE_THONG

URL = os.environ.get("AILANG_URL", "http://127.0.0.1:11434/v1/chat/completions")
MODEL = os.environ.get("AILANG_MODEL", "qwen2.5:3b")
HET_GIO = float(os.environ.get("AILANG_HET_GIO", "30"))


def nghi(goi):
    tom_tat = {
        "troi": goi.get("troi"),
        "ngay": goi.get("ngay"),
        "mua": goi.get("mua"),
        "dan_lang": goi.get("dan_lang", []),
    }
    than = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": HE_THONG},
            {"role": "user", "content": json.dumps(tom_tat, ensure_ascii=False)},
        ],
        "temperature": 0.9,
        "stream": False,
    }
    try:
        yc = urllib.request.Request(
            URL, data=json.dumps(than).encode("utf-8"),
            headers={"Content-Type": "application/json"}, method="POST")
        with urllib.request.urlopen(yc, timeout=HET_GIO) as tl:
            goi_ve = json.loads(tl.read().decode("utf-8"))
        tho = goi_ve["choices"][0]["message"]["content"]
        i, j = tho.find("{"), tho.rfind("}")
        ra = json.loads(tho[i:j + 1]).get("dan_lang", [])
    except (urllib.error.URLError, OSError, KeyError, IndexError, ValueError) as e:
        print(f"[tam-tri] model local hỏng ({type(e).__name__}: {e}) — tụt về não luật",
              flush=True)
        return luat.nghi(goi)

    hop_le = {d["ma"] for d in goi.get("dan_lang", [])}
    sach = []
    for y in ra:
        if y.get("ma") not in hop_le:
            continue
        if y.get("muc_tieu") not in MUC_TIEU:
            y["muc_tieu"] = None
        sach.append({"ma": y["ma"], "muc_tieu": y.get("muc_tieu"),
                     "noi_gi": y.get("noi_gi")})
    return sach or luat.nghi(goi)

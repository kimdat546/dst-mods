"""Não bằng Gemini — chỉ dùng urllib, KHÔNG cần cài SDK.

Cố ý không dùng google-genai SDK: cả dự án này sinh ra vì hai mod cũ chết do
phụ thuộc (một app C# .NET Framework chỉ chạy Windows). Không thêm phụ thuộc
nào là cách chắc nhất để năm sau nó vẫn chạy. REST của Gemini chỉ là một cú
POST JSON.

Gọi hỏng (hết quota, mất mạng, khoá sai) thì TỤT VỀ não luật, không để dân
làng đứng ngây. Đó là lý do tầng này chỉ ĐẶT MỤC TIÊU chứ không điều khiển
từng bước đi — mất nó thì làng chậm chứ không chết.
"""

import json
import os
import urllib.error
import urllib.request

from . import MUC_TIEU, luat

MODEL = os.environ.get("AILANG_GEMINI_MODEL", "gemini-2.5-flash")
KHOA = os.environ.get("GEMINI_API_KEY", "")
HET_GIO = float(os.environ.get("AILANG_HET_GIO", "20"))

URL = ("https://generativelanguage.googleapis.com/v1beta/models/"
       "{model}:generateContent")

HE_THONG = """Bạn điều khiển các dân làng NPC trong Don't Starve Together.
Mỗi dân làng có tính cách riêng và đang sống trong thế giới sinh tồn.

Với MỖI dân làng, chọn một mục tiêu và (tuỳ ý) một câu thoại ngắn tiếng Việt.

Mục tiêu hợp lệ, chỉ được dùng đúng các từ này:
- CHAT : đi chặt cây (chỉ chọn khi đang cầm rìu)
- DAO  : đi đập đá (chỉ chọn khi đang cầm cuốc)
- HAI  : hái quả, cỏ, cành
- NHAT : nhặt đồ rơi dưới đất
- AN   : ăn đồ trong túi

Nguyên tắc:
- Đói dưới 40 thì phải AN.
- Ban đêm thì đừng đi xa, chọn NHAT.
- Câu thoại tối đa 12 từ, giọng đời thường, hợp tính cách. Không phải lúc nào
  cũng cần nói — đa số nhịp để noi_gi là null cho đỡ ồn.

Trả về DUY NHẤT một JSON, không bọc markdown:
{"dan_lang":[{"ma":"...","muc_tieu":"HAI","noi_gi":null}]}"""


def _goi_gemini(noi_dung: str) -> str:
    than = {
        "systemInstruction": {"parts": [{"text": HE_THONG}]},
        "contents": [{"role": "user", "parts": [{"text": noi_dung}]}],
        "generationConfig": {"temperature": 0.9, "responseMimeType": "application/json"},
    }
    yc = urllib.request.Request(
        URL.format(model=MODEL),
        data=json.dumps(than).encode("utf-8"),
        headers={"Content-Type": "application/json", "x-goog-api-key": KHOA},
        method="POST",
    )
    with urllib.request.urlopen(yc, timeout=HET_GIO) as tl:
        goi = json.loads(tl.read().decode("utf-8"))
    return goi["candidates"][0]["content"]["parts"][0]["text"]


def nghi(goi):
    if not KHOA:
        return luat.nghi(goi)

    tom_tat = {
        "troi": goi.get("troi"),
        "ngay": goi.get("ngay"),
        "mua": goi.get("mua"),
        "dan_lang": goi.get("dan_lang", []),
    }
    try:
        tho = _goi_gemini(json.dumps(tom_tat, ensure_ascii=False))
        ra = json.loads(tho).get("dan_lang", [])
    except (urllib.error.URLError, OSError, KeyError, IndexError,
            json.JSONDecodeError) as e:
        print(f"[tam-tri] Gemini hỏng ({type(e).__name__}: {e}) — tụt về não luật",
              flush=True)
        return luat.nghi(goi)

    # Lọc lại: model có thể bịa mục tiêu không tồn tại hoặc bịa mã dân làng.
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

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

from . import luat, soat

MODEL = os.environ.get("AILANG_GEMINI_MODEL", "gemini-2.5-flash")
KHOA = os.environ.get("GEMINI_API_KEY", "")
HET_GIO = float(os.environ.get("AILANG_HET_GIO", "20"))

URL = ("https://generativelanguage.googleapis.com/v1beta/models/"
       "{model}:generateContent")

# ⚠ ĐỪNG DẠY NÓ LÀM PHẢN XẠ. Đói, tối, bị đánh, quá nóng, cháy nhà — cây hành
#   vi trong mod tự lo, nhịp 0,5 giây, và nó LUÔN THẮNG mục tiêu gửi từ đây
#   (xem thứ tự node trong danlangbrain.lua). Kênh này trễ vài giây, bảo dân
#   làng "đi ăn" từ đây là vừa thừa vừa muộn.
#
# ⚠ VÀ ĐỪNG LIỆT KÊ CẢ 200 ĐỘNG TỪ. Gửi lại mỗi 15 giây là phí token, mà model
#   cũng không cần: nó biết Don't Starve. Chỉ cần nói rõ LUẬT CHƠI của định
#   dạng, kèm chừng hai chục động từ hay dùng làm mỏ neo.
HE_THONG = """Bạn là tầng chiến lược của một làng NPC trong Don't Starve Together.

Dân làng ĐÃ TỰ BIẾT sống: tự cầm đuốc khi tối, tự ăn khi đói, tự trốn nóng,
tự đánh trả, tự dựng lửa trại. Đừng ra lệnh những việc đó — phản xạ của chúng
luôn thắng lệnh của bạn, nên lệnh kiểu ấy chỉ bị bỏ phí.

Việc của bạn là thứ chúng KHÔNG tự nghĩ ra: nhìn KHO CỦA CẢ LÀNG, thấy chỗ
đang tắc, rồi dồn người vào đúng chỗ đó.

MỆNH LỆNH LÀ DỮ LIỆU, ánh thẳng vào bảng ACTIONS của DST:
  {"hanh_dong":"CHOP","nham":"evergreen","dung":"axe","lan":5}
  {"hanh_dong":"SHAVE","nham":"beefalo","dung":"razor"}
  {"che":"researchlab","dat_xuong":true}
  {"buoc":[{"che":"trap"},{"hanh_dong":"DROP","nham":"rabbithole","dung":"trap"}]}

  hanh_dong  tên bất kỳ trong ACTIONS của DST (CHOP MINE PICK PICKUP ATTACK
             COOK STORE CHECKTRAP DROP SHAVE HAMMER DIG NET FISH GIVE HARVEST
             FERTILIZE EAT EQUIP LIGHT EXTINGUISH ...). Cứ dùng tên đúng của
             game, không giới hạn ở danh sách này.
  nham       tên prefab ("beefalo", "rock2") HOẶC tag ("CHOP_workable")
  dung       prefab món cần cầm; dân làng tự moi trong túi ra cầm
  lan        lặp bấy nhiêu lượt
  tam        bán kính tìm, mặc định 30, tối đa nên để 60
  che        tên công thức, thay cho hanh_dong
  dat_xuong  true nếu công thức đó là công trình
  buoc       danh sách mệnh lệnh làm lần lượt

MẤY ĐIỀU ĐÃ ĐO ĐƯỢC TRONG GAME, dùng mà quyết:
- Vàng CHỈ ra từ "rock2", không ra từ "rock1". Máy Khoa Học (researchlab) cần
  vàng 1 + gỗ 4 + đá 4, và nó mở khoá giáo, rương, nồi, lửa lạnh.
- Hái berry KHÔNG nuôi nổi làng: một bụi cho 0,33 quả/ngày, ba người đốt 225
  calo/ngày, tức cần khoảng 70 bụi. Nguồn thịt tái tạo là BẪY THỎ
  (che "trap", tech 0) đặt lên "rabbithole".
- Nấu chín gấp đôi calo và không tốn nguyên liệu nào.

Trường "kho" trong dữ liệu là kiểm kê CẢ LÀNG, đã quy sẵn: ngay_an (dự trữ ăn
được mấy ngày), mau_hoi, cap_may, du_an/du_thuoc/du_vu_khi/du_giap,
du_suc_danh, và nut_that — thứ ĐANG chặn làng. Dựa vào đó mà ra lệnh.
Khi du_suc_danh là true thì đã đủ ăn đủ thuốc đủ vũ khí: nghĩ tới đi săn.

Nếu nhịp trước lệnh bị từ chối, lý do nằm ở "muc_tieu_loi" của dân làng đó.
Đọc nó rồi sửa, đừng gửi lại y nguyên.

Đừng dồn cả làng vào một việc — chừa ít nhất một người cho việc thường
(muc_tieu = null). Dân làng đang làm dở việc tốt thì cứ để null.

noi_gi: câu tiếng Việt tối đa 12 từ, hợp tính cách, đa số nhịp để null cho
đỡ ồn.

Trả về DUY NHẤT một JSON, không bọc markdown:
{"dan_lang":[{"ma":"...","muc_tieu":{...}|null,"noi_gi":null}]}"""


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


def loc(ra, goi):
    """Bỏ mã dân làng bịa và mục tiêu sai hình dạng.

    ⚠ Chỉ soát HÌNH DẠNG ở đây, không soát tên động từ. Mod có bảng ACTIONS
      thật và tự soát kỹ hơn, rồi gửi lý do từ chối lại trong `muc_tieu_loi`.
      Đoán mò danh sách động từ ở phía này là chặn nhầm lệnh đúng.
    """
    hop_le = {d["ma"] for d in goi.get("dan_lang", [])}
    sach = []
    for y in ra:
        if not isinstance(y, dict) or y.get("ma") not in hop_le:
            continue
        mt = y.get("muc_tieu")
        if not soat(mt):
            mt = None
        sach.append({"ma": y["ma"], "muc_tieu": mt, "noi_gi": y.get("noi_gi")})
    return sach


def nghi(goi):
    if not KHOA:
        return luat.nghi(goi)

    tom_tat = {
        "troi": goi.get("troi"),
        "ngay": goi.get("ngay"),
        "mua": goi.get("mua"),
        "kho": goi.get("kho"),
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

    return loc(ra, goi) or luat.nghi(goi)

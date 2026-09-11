"""Giao thức file giữa mod DST và dịch vụ suy nghĩ.

⚠ Vì sao đi bằng file chứ không phải HTTP: đã đo trên DST bản 11/09/2026,
  `TheSim:QueryServer` KHÔNG gọi callback cho URL ngoài Klei — thử http lẫn
  https, tên miền lẫn IP, server offline lẫn server online đang có người chơi.
  Kiến trúc HTTP của FAtiMA-DST (2018) và DST-AICompanion (2024) chết ở đây.

  Kênh thay thế: TheSim:SetPersistentString / GetPersistentString. Mod ghi và
  đọc trong thư mục save của world, dịch vụ này mount đúng thư mục đó.
"""

import json
import pathlib

TEP_HOI = "ailang_hoi.json"
TEP_DAP = "ailang_dap.json"

# SetPersistentString chèn tiền tép "KLEI     1 " trước JSON. Lúc ĐỌC thì
# GetPersistentString tự bóc, nên phía mình ghi ra KHÔNG cần thêm tiền tố —
# đã kiểm cả hai chiều.
TIEN_TO = "KLEI"


def doc_hoi(thu_muc: pathlib.Path):
    """Đọc câu hỏi mod vừa ghi. Trả None nếu chưa có hoặc chưa ghi xong."""
    tep = thu_muc / TEP_HOI
    if not tep.exists():
        return None
    try:
        tho = tep.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None

    # Bóc tiền tố bằng cách nhảy tới dấu { đầu tiên — bền hơn là đếm ký tự,
    # vì độ dài tiền tố không có gì đảm bảo giữ nguyên qua các bản DST.
    i = tho.find("{")
    if i < 0:
        return None
    try:
        return json.loads(tho[i:])
    except json.JSONDecodeError:
        # Bắt được lúc mod đang ghi dở. Nhịp sau đọc lại.
        return None


def ghi_dap(thu_muc: pathlib.Path, dan_lang: list):
    """Ghi câu trả lời. Ghi tạm rồi đổi tên để mod không đọc phải file dở."""
    tep = thu_muc / TEP_DAP
    tam = thu_muc / (TEP_DAP + ".tam")
    tam.write_text(
        json.dumps({"dan_lang": dan_lang}, ensure_ascii=False),
        encoding="utf-8",
    )
    tam.replace(tep)

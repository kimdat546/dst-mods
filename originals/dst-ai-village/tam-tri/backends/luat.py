"""Não bằng luật — không cần khoá API, không cần mạng, chạy tức thì.

Đây là bộ mặc định và cũng là lưới an toàn: Gemini hết quota hay model local
chết thì đổi sang bộ này, dân làng vẫn có mục tiêu hợp lý.

Không thay thế được cái mà LLM làm được (nói chuyện, mục tiêu dài hơi), nhưng
cho việc "chọn làm gì bây giờ" thì luật đơn giản đã đủ tốt — và đó cũng đúng
là mức mà FAtiMA trong hai mod cũ đạt tới, chỉ khác là nó cần một app C#
Windows 12 MB để làm.
"""

CAY = ("evergreen", "deciduoustree", "twiggytree", "marsh_tree", "mushtree")
HAI_DUOC = ("berrybush", "sapling", "grass", "reeds", "carrot", "flower")


def _co(quanh, tu_khoa):
    return any(any(k in mon for k in tu_khoa) for mon in quanh)


def nghi(goi):
    ra = []
    troi_toi = goi.get("troi") in ("đêm", "hoàng hôn")

    for d in goi.get("dan_lang", []):
        quanh = d.get("quanh", [])
        muc_tieu, noi_gi = None, None

        if d.get("doi", 100) < 40:
            muc_tieu = "AN"
            noi_gi = "Đói quá, ăn cái đã."
        elif d.get("mau", 100) < 40:
            noi_gi = "Đau quá, để tôi nghỉ chút."
        elif troi_toi:
            muc_tieu = "NHAT"
        elif _co(quanh, CAY) and d.get("tren_tay", "") and "axe" in str(d.get("tren_tay")):
            muc_tieu = "CHAT"
        elif _co(quanh, HAI_DUOC):
            muc_tieu = "HAI"
        else:
            muc_tieu = "NHAT"

        ra.append({"ma": d["ma"], "muc_tieu": muc_tieu, "noi_gi": noi_gi})
    return ra

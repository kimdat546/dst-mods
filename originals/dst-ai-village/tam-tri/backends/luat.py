"""Não bằng luật — không cần khoá API, không cần mạng, chạy tức thì.

Đây là bộ mặc định và cũng là lưới an toàn: Gemini hết quota hay model local
chết thì đổi sang bộ này, dân làng vẫn có mục tiêu hợp lý.

⚠ BỘ NÀY LÁI CHIẾN LƯỢC, KHÔNG LÁI PHẢN XẠ. Đói, tối, cháy, bị đánh — cây
  hành vi trong mod tự lo hết và lo nhanh hơn (0,5 giây một nhịp, trong khi
  kênh này trễ vài giây). Bảo dân làng "đi ăn" từ đây là thừa, và tệ hơn là
  giành lượt với thứ đã làm tốt hơn.

  Việc của bộ này là thứ cây hành vi KHÔNG tự nghĩ ra: nhìn kho của cả làng,
  thấy nút thắt, rồi dồn người vào đúng chỗ tắc. Mod đã tính sẵn nút thắt đó
  trong `kho.nut_that` — ở đây chỉ dịch nó thành mệnh lệnh.
"""

# Nút thắt -> mệnh lệnh gỡ nút. Khớp theo chuỗi con, xem kho_lang.NutThat.
GO_NUT = (
    ("thiếu rìu",       {"che": "axe"}),
    ("thiếu cuốc",      {"che": "pickaxe"}),
    ("thiếu vàng",      {"hanh_dong": "MINE", "nham": "rock2",
                         "dung": "pickaxe", "lan": 4, "tam": 60}),
    ("thiếu đá",        {"hanh_dong": "MINE", "nham": "rock1",
                         "dung": "pickaxe", "lan": 4, "tam": 60}),
    ("thiếu gỗ",        {"hanh_dong": "CHOP", "nham": "CHOP_workable",
                         "dung": "axe", "lan": 6, "tam": 60}),
    ("chưa dựng máy",   {"che": "researchlab", "dat_xuong": True}),
    ("chưa có rương",   {"che": "treasurechest", "dat_xuong": True}),
)

# Chưa đủ ăn thì gieo bẫy: nguồn thịt TÁI TẠO, tech 0. Xem
# docs/dst-knowledge/analysis/dst-kinh-te-sinh-ton.md — hái berry không đủ
# nuôi ba người, cần khoảng 70 bụi.
DAT_BAY = {"buoc": [
    {"che": "trap"},
    {"hanh_dong": "DROP", "nham": "rabbithole", "dung": "trap", "tam": 60},
]}

# Đủ ăn, đủ thuốc, đủ vũ khí rồi thì mới nghĩ tới đánh nhau.
DI_SAN = {"hanh_dong": "ATTACK", "nham": "rabbit", "tam": 40}


def _cau_noi(d, kho, dau_tien):
    doi, mau = d.get("doi", 100), d.get("mau", 100)
    if doi < 30:
        return "Đói quá."
    if mau < 40:
        return "Đau quá, để tôi nghỉ chút."
    # Chỉ MỘT người kể chuyện làng. Cả ba cùng đọc một câu là thành tụng kinh.
    if dau_tien and kho and kho.get("nut_that"):
        return "Làng mình đang " + kho["nut_that"] + "."
    return None


def nghi(goi):
    kho = goi.get("kho") or {}
    nut = kho.get("nut_that")

    chung = None
    if nut:
        for khoa, lenh in GO_NUT:
            if khoa in nut:
                chung = lenh
                break
        if chung is None and "đói" in nut:
            chung = DAT_BAY
    elif not kho.get("du_an"):
        chung = DAT_BAY
    elif kho.get("du_suc_danh"):
        chung = DI_SAN

    ra = []
    for i, d in enumerate(goi.get("dan_lang", [])):
        # ⚠ ĐỪNG dồn CẢ LÀNG vào một việc. Ba người cùng đi đào một tảng đá
        #   thì hai người đứng nhìn. Cho một người ở nhà lo việc thường —
        #   cây hành vi mặc định vẫn chạy khi muc_tieu là None.
        mt = chung if (chung is not None and i < max(1, len(goi.get("dan_lang", [])) - 1)) else None
        ra.append({"ma": d["ma"], "muc_tieu": mt, "noi_gi": _cau_noi(d, kho, i == 0)})
    # Não luật không có gì để nhớ: nó quyết lại từ đầu mỗi nhịp, và đó là chủ ý
    # — nó là lưới an toàn, phải đoán được và không tích trạng thái.
    return ra, None

"""Các bộ não cắm được. Mỗi bộ chỉ cần một hàm:

    nghi(goi: dict) -> (list[dict], str | None)

`goi` là nguyên văn câu hỏi mod gửi sang (xem giao_thuc.doc_hoi).
Trả về danh sách {"ma": ..., "muc_tieu": ..., "noi_gi": ...} KÈM ghi nhớ.

⚠ Ghi nhớ là của CẢ TẦNG SUY NGHĨ, không của riêng dân làng nào — nên nó nằm
  ngoài danh sách chứ không nhét vào từng mục. Mod chỉ giữ hộ và trả lại
  nguyên văn ở nhịp sau (xem ailang/nhat_ky.lua); nó không đọc hiểu gì cả.
  Bộ nào không có gì để nhớ thì trả None.

⚠ MỤC TIÊU KHÔNG CÒN LÀ MỘT TỪ TRONG DANH SÁCH NĂM TỪ. Bản trước dùng enum
  ("CHAT", "DAO", "HAI", "NHAT", "AN") và enum đó có hai vấn đề: nó không bao
  giờ đủ cho mọi tình huống người chơi nghĩ ra, và — tệ hơn — MOD KHÔNG HỀ ĐỌC
  NÓ. `muc_tieu` được gán rồi bị xoá lúc chết, không một dòng nào đọc.

  Giờ mục tiêu là DỮ LIỆU ánh thẳng vào bảng ACTIONS của DST (~200 động từ):

      {"hanh_dong": "CHOP", "nham": "evergreen", "dung": "axe", "lan": 5}
      {"hanh_dong": "SHAVE", "nham": "beefalo", "dung": "razor"}
      {"che": "researchlab", "dat_xuong": True}
      {"buoc": [ {...}, {...} ]}          # làm lần lượt

  Trường:
      hanh_dong  tên trong ACTIONS (không phân biệt hoa thường)
      nham       tên prefab ("beefalo") hoặc tag ("CHOP_workable")
      dung       prefab món cần cầm; mod tự tìm trong túi và cầm lên
      lan        làm bấy nhiêu MỤC TIÊU (cây đổ, đá vỡ) rồi thôi — KHÔNG phải
                 bấy nhiêu nhát. Đào/chặt làm rơi đồ xuống đất, dân làng tự
                 nhặt, và lần nhặt đó không tính vào `lan`.
      tam        bán kính tìm mục tiêu, mặc định 30
      che        tên công thức (thay cho hanh_dong)
      dat_xuong  công thức này là công trình, đặt xuống đất

  Mod SOÁT mục tiêu trước khi nhận và gửi lý do từ chối lại trong trường
  `muc_tieu_loi` của nhịp sau — đọc nó để biết lệnh sai ở đâu.

  Toàn bộ từ vựng mod chấp nhận nằm trong <save>/ailang_tudien.json, do mod
  ghi ra lúc khởi động.
"""


def soat(mt) -> bool:
    """Mục tiêu có ĐÚNG HÌNH DẠNG không. Không kiểm tên động từ có thật —
    mod tự làm việc đó và báo lại; ở đây chỉ chặn thứ rõ ràng hỏng."""
    if mt is None:
        return True
    if not isinstance(mt, dict):
        return False
    if "buoc" in mt:
        ds = mt["buoc"]
        return isinstance(ds, list) and len(ds) > 0 and all(soat(b) for b in ds)
    return isinstance(mt.get("hanh_dong"), str) or isinstance(mt.get("che"), str)


def lay(ten: str):
    if ten == "gemini":
        from . import gemini
        return gemini
    if ten == "cuc_bo":
        from . import cuc_bo
        return cuc_bo
    from . import luat
    return luat

"""Các bộ não cắm được. Mỗi bộ chỉ cần một hàm:

    nghi(goi: dict) -> list[dict]

`goi` là nguyên văn câu hỏi mod gửi sang (xem giao_thuc.doc_hoi).
Trả về danh sách {"ma": ..., "muc_tieu": ..., "noi_gi": ...}.

MUC_TIEU phải nằm trong bộ từ vựng mod hiểu, xem MUC_TIEU bên dưới. Trả về
mục tiêu lạ thì mod bỏ qua — cây hành vi tự chạy nhánh mặc định, không hỏng.
"""

MUC_TIEU = ("CHAT", "DAO", "HAI", "NHAT", "AN")


def lay(ten: str):
    if ten == "gemini":
        from . import gemini
        return gemini
    if ten == "cuc_bo":
        from . import cuc_bo
        return cuc_bo
    from . import luat
    return luat

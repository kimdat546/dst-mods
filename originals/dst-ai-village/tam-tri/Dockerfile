# Không cài gì cả — toàn bộ dịch vụ chỉ dùng thư viện chuẩn Python.
# Cố ý như vậy: hai mod cũ chết vì phụ thuộc (.NET Framework chỉ chạy Windows).
FROM python:3.12-alpine
WORKDIR /app
COPY . /app
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["python3", "/app/tam_tri.py"]
CMD ["/save"]

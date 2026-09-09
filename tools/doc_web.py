#!/usr/bin/env python3
"""Đọc trang web dựng bằng JS (SPA) — chạy trình duyệt thật rồi lấy text.

    python3 tools/doc_web.py <url> [--sel CSS] [--html] [--wait GIÂY]

Vì sao cần: nhiều wiki mod (modwikis.com…) trả về HTML rỗng cho curl, toàn bộ
nội dung do JavaScript dựng. MCP trình duyệt của workspace mở được tab nhưng
proxy CDP bị khoá (browser_disabled) nên không đọc được DOM.
"""
import argparse, sys
from playwright.sync_api import sync_playwright

ap = argparse.ArgumentParser()
ap.add_argument("url")
ap.add_argument("--sel", default="body")
ap.add_argument("--html", action="store_true")
ap.add_argument("--wait", type=float, default=3.0)
a = ap.parse_args()

with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(locale="zh-CN")
    pg.goto(a.url, wait_until="networkidle", timeout=60000)
    pg.wait_for_timeout(int(a.wait * 1000))
    try:
        pg.wait_for_selector(a.sel, timeout=8000)
    except Exception:
        pass
    out = pg.inner_html(a.sel) if a.html else pg.inner_text(a.sel)
    b.close()
print(out)

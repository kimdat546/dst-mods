#!/usr/bin/env python3
"""Điều khiển DST Mod Tool từ dòng lệnh (và từ Claude) qua IPC.

DST Mod Tool 1.1+ mở một cổng IPC nội bộ nhận mã Lua thao tác trên document
đang mở trong app. KHÔNG phải MCP, không phải HTTP — chỉ là gọi binary rồi
đọc JSON trả về. Bản thân tool có hẳn chương "Guide for AI Agents" mô tả
đúng cách dùng này.

    python3 tools/dstmod.py info
    python3 tools/dstmod.py render <bank> <anim> <frame> <ảnh_ra.png>
    python3 tools/dstmod.py lua <file.lua>
    python3 tools/dstmod.py lua -            # đọc Lua từ stdin
    python3 tools/dstmod.py doc              # in tài liệu API đầy đủ

⚠ App PHẢI đang chạy và có document mở sẵn. Script chạy trên workspace hiện
  tại, không tự mở file.

⚠ Sửa document thì đặt nhãn lịch sử: doc:set_label("...") — để bạn undo được
  và biết ai đã đổi gì.
"""
import json, os, subprocess, sys

BIN = "/Applications/DST Mod Tool.app/Contents/MacOS/dst-app"


def _bin():
    if os.path.exists(BIN):
        return BIN
    # bản cũ tên khác
    alt = os.path.join(os.path.dirname(BIN), "dst-mod-tool")
    if os.path.exists(alt):
        return alt
    sys.exit("không tìm thấy DST Mod Tool ở /Applications")


def run(lua):
    """Chạy một đoạn Lua, trả về report (dict). Ném RuntimeError nếu lỗi."""
    p = subprocess.run([_bin(), "script", "--stdin"], input=lua.encode(),
                       capture_output=True)
    # dòng log lẫn vào stdout, JSON là dòng cuối bắt đầu bằng '{'
    line = next((l for l in reversed(p.stdout.decode().splitlines())
                 if l.startswith("{")), None)
    if line is None:
        raise RuntimeError("không nhận được JSON. stderr:\n" + p.stderr.decode()[:500])
    rep = json.loads(line)["response"]["report"]
    if not rep["ok"]:
        raise RuntimeError("Lua lỗi: %s" % rep.get("error"))
    for t in rep.get("tool_results", []):
        if not t.get("ok"):
            raise RuntimeError("lệnh tool thất bại: %s" % t)
    return rep


def info():
    rep = run('''
print("revision", tool.document_revision)
print("path", tool.document_path)
for _, b in ipairs(doc.builds) do
  print("BUILD", b.name, #b.symbols)
end
for _, bk in ipairs(doc.banks) do
  print("BANK", bk.name, #bk.animations)
  for _, a in ipairs(bk.animations) do
    print("  ANIM", a.name, #a.frames)
  end
end
''')
    return rep["output"]


def render(bank, anim, frame, out, max_dim=512):
    out = os.path.abspath(out)
    run('''
local bk = assert(doc.banks:find(%s), "khong thay bank")
local an = assert(bk.animations:find(%s), "khong thay animation")
local fr = assert(an.frames[%d], "khong thay frame")
fr:export_png([[%s]], { max_dimension = %d })
''' % (json.dumps(bank), json.dumps(anim), int(frame), out, int(max_dim)))
    if not os.path.exists(out):
        raise RuntimeError("tool báo thành công nhưng không có file " + out)
    return out


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    if a[0] == "info":
        for l in info():
            print(" ", l)
    elif a[0] == "render":
        if len(a) < 5:
            sys.exit("dùng: render <bank> <anim> <frame> <ảnh_ra.png>")
        print(" ", render(a[1], a[2], a[3], a[4]))
    elif a[0] == "lua":
        src = sys.stdin.read() if a[1] == "-" else open(a[1], encoding="utf-8").read()
        rep = run(src)
        for l in rep["output"]:
            print(" ", l)
    elif a[0] == "doc":
        subprocess.run([_bin(), "script", "--help", "--lang", "en"])
    else:
        sys.exit(__doc__)

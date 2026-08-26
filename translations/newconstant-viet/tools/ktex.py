"""Chuyển tiếp sang tools/ktex.py dùng chung ở gốc workspace.

File thật đã dời ra `tools/` (2026-08-26) để mọi mod dùng chung. Giữ file này
làm cầu nối vì build.py, make_preview.py, extract_images.py, anim_sprite.py
đều `from ktex import ...` theo đường dẫn tương đối cùng thư mục.
"""
import importlib.util as _il, os as _os, sys as _sys

_path = _os.path.normpath(_os.path.join(
    _os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..', 'tools', 'ktex.py'))
if not _os.path.exists(_path):
    raise ImportError('không tìm thấy tools/ktex.py dùng chung tại ' + _path)

_spec = _il.spec_from_file_location('_ktex_shared', _path)
_mod = _il.module_from_spec(_spec)
_spec.loader.exec_module(_mod)

# đưa mọi tên công khai của bản gốc sang module này
globals().update({k: v for k, v in vars(_mod).items() if not k.startswith('_')})

#!/usr/bin/env python3
"""Create the source distribution, generated compiler, and validation evidence."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT.parent / "bend2-selfhost-compiler.zip"
EXCLUDED_DIRS = {".git", ".bootstrap", "build", "node_modules", "__pycache__"}
EXCLUDED_FILES = {"src/back/native/smoke.bend"}


def include(relative):
    return not (
        any(part in EXCLUDED_DIRS for part in relative.parts)
        or relative.as_posix() in EXCLUDED_FILES
        or relative.name.startswith("typed-frontend-seeded.")
        or relative.name.endswith(".progress.jsonl")
        or ".tmp-" in relative.name
        or relative.suffix in {".zip", ".pyc"}
    )


files = []
for file in sorted(ROOT.rglob("*")):
    relative = file.relative_to(ROOT)
    if file.is_file() and include(relative):
        if file.is_symlink():
            raise SystemExit(f"Refusing to package symlink: {relative}")
        files.append((relative.as_posix(), file.read_bytes()))

required = {"cli.mjs", "src/compiler.json", "dist/typed-api.mjs", "dist/base.bend", "src/runtime.mjs", "README.md", "NOTICE", "UPSTREAM-LICENSE"}
missing = required - {name for name, _ in files}
if missing:
    raise SystemExit(f"Missing distribution files: {sorted(missing)}")

manifest = {
    "upstream": json.loads((ROOT / "src/compiler.json").read_text())["upstream"],
    "files": [{"path": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()} for name, data in files],
}
files.append(("ARCHIVE-MANIFEST.json", (json.dumps(manifest, indent=2) + "\n").encode()))
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
with tempfile.NamedTemporaryFile(dir=OUTPUT.parent, prefix=OUTPUT.name + ".tmp-", delete=False) as temporary:
    staged = Path(temporary.name)
try:
    with zipfile.ZipFile(staged, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in files:
            info = zipfile.ZipInfo("bend2-selfhost/" + name, date_time=(1980, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, data, compresslevel=9)
    staged.replace(OUTPUT)
finally:
    staged.unlink(missing_ok=True)
print(f"{OUTPUT}: {len(files)} files, {OUTPUT.stat().st_size} bytes")

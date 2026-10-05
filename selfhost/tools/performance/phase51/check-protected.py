#!/usr/bin/env python3
"""Verify the 103 pre-existing files without modifying them."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
start = ROOT / 'selfhost/build/phase45/protected-start.json'
out = Path(sys.argv[1]).resolve()
assert not out.exists()

def identity(file):
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())

rows = json.loads(start.read_text())['files']
assert len(rows) == len({r['path'] for r in rows}) == 103
changed = [r['path'] for r in rows if any(identity(ROOT / r['path'])[k] != r[k] for k in ['bytes', 'sha256'])]
staged = set(subprocess.check_output(['git', 'diff', '--cached', '--name-only'], cwd=ROOT, text=True).splitlines())
protected_staged = sorted(staged & {r['path'] for r in rows})
assert not changed and not protected_staged, (changed, protected_staged)
report = dict(complete=True, checked=103, changed=changed, protectedStaged=protected_staged,
              start=identity(start), producer=identity(Path(__file__).resolve()))
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))

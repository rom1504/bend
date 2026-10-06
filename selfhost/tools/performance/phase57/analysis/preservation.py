#!/usr/bin/env python3
"""Data-only check of the installed release and closed historical raw trees."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase57'
out = Path(sys.argv[1]).resolve()
assert out.is_relative_to(RAW) and not out.exists()

def identity(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())

installed_start = RAW / 'installed-start.json'
historical_start = RAW / 'closed-inputs-start.json'
installed = json.loads(installed_start.read_text())['files']
historical = json.loads(historical_start.read_text())['files']
assert len(installed) == 7 and len(historical) == 16034
assert all(identity(r['file']) == r for r in installed)
assert all(identity(r['file']) == r for r in historical)
actual = {str(p.resolve()) for phase in ['phase54', 'phase55', 'phase56']
          for p in (ROOT / 'selfhost/build' / phase).rglob('*') if p.is_file()}
assert actual == {r['file'] for r in historical}
paths = ['selfhost/src', 'selfhost/dist', 'selfhost/cli.mjs',
         'selfhost/tools/typed-driver.mjs', 'bend2']
changed = subprocess.check_output(
    ['git', 'diff', '--name-only', 'd8431c2', '--', *paths], cwd=ROOT, text=True)
assert not changed, changed
report = dict(complete=True, installedFiles=len(installed),
              closedHistoricalFiles=len(historical), changed=[],
              addedHistoricalFiles=[], removedHistoricalFiles=[],
              installedStart=identity(installed_start),
              historicalStart=identity(historical_start),
              productionDiff=dict(base='d8431c2', paths=paths, changed=[]),
              producer=identity(__file__),
              scope='Exact bytes and file set; no compiler or target execution. '
                    'The separate protected-file audit covers the 103 inherited files.')
out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['complete', 'installedFiles', 'closedHistoricalFiles']}))

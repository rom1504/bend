#!/usr/bin/env python3
"""Freeze the selected two-change candidate from the checked RNFA04 snapshot."""
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RAW = ROOT / 'build/phase51'
OUT = RAW / 'source-candidate01'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'

def identity(p):
    return {'file': str(p), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}

assert not OUT.exists(), 'fresh output required'
attempt_file = ROOT / 'build/phase48/checked-combined-rnfa04/attempt.json'
attempt = json.loads(attempt_file.read_text())
snapshot = Path(attempt['snapshot']['root'])
OUT.mkdir(parents=True)
for row in attempt['snapshot']['sources']:
    src = Path(row['frozen']['file'])
    assert identity(src)['sha256'] == row['frozen']['sha256'], src
    dst = OUT / src.relative_to(snapshot)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)
patches = []
for name in ['same-entry-string-proof', 'dispatch-io-runtime']:
    patch = ROOT / ('tools/performance/phase51/proposals/' + name + '.patch')
    subprocess.run(['patch', '--batch', '--fuzz=0', '-p2', '-i', str(patch)], cwd=OUT, check=True)
    patches.append(identity(patch))
subprocess.run([NODE, str(OUT / 'src/runtime/js/build.mjs')], check=True)
# Use only workflow configuration fields, retaining the pinned upstream and profile.
config = json.loads((ROOT / 'build/phase48/combined-rnfa04-config.json').read_text())
config['project'] = str(OUT)
(RAW / 'candidate-config01.json').write_text(json.dumps(config, indent=2) + '\n')
receipt = {'kind': 'phase51-selected-source', 'baseAttempt': identity(attempt_file),
           'producer': identity(Path(__file__).resolve()), 'patches': patches,
           'sources': [identity(OUT / p) for p in ['src/runtime/js/core.mjs', 'src/runtime.mjs', 'src/back/js/jpure.bend']],
           'status': 'unqualified until checked build and validation'}
(RAW / 'selected-source01.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps(receipt, indent=2))

"""Recompose the experimental candidate from pinned Bend modules; no promotion."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
a.out = a.out.resolve()
recipe = json.loads((Path(__file__).parent / 'candidate-recipe.json').read_text())
for item in [recipe['parent'], recipe['prepare'], *recipe['modules']]:
    data = (ROOT / item['file']).read_bytes()
    assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == item['sha256'], item['file']
command = ['python3', '-B', str(ROOT / recipe['prepare']['file']), '--out', str(a.out)]
for module in recipe['modules']:
    command += ['--module', str(ROOT / module['file'])]
command += ['--overrides', *recipe['overrides'], '--module-overrides', *recipe['moduleOverrides']]
subprocess.run(command, cwd=ROOT, check=True)
source = (a.out / 'compiler.bend').read_bytes()
assert len(source) == recipe['result']['bytes']
assert hashlib.sha256(source).hexdigest() == recipe['result']['sha256']
print('Exact experimental source reproduced; source checking and native qualification are separate.')

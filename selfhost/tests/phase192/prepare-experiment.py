#!/usr/bin/env python3
"""Freeze an experimental source inventory; all compiler algorithms stay Bend."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--manifest', type=Path, default=Path('selfhost/src/compiler.json'))
p.add_argument('--module', action='append', default=[])
p.add_argument('--root-symbol', action='append', default=[])
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists(), 'Fresh output required'
root = Path('selfhost').resolve()
def pin(file):
    data = file.read_bytes()
    return dict(file=str(file.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
source = json.loads(a.manifest.read_text())
profile = source['profiles']['x86']
inputs = [pin(Path(__file__)), pin(a.manifest)]
for module in a.module:
    file = (root / module).resolve()
    assert root in file.parents and file.is_file(), 'Module must belong to selfhost'
    assert module not in profile['modules'], 'Duplicate experimental module'
    profile['modules'].append(module)
    inputs.append(pin(file))
for symbol in a.root_symbol:
    assert symbol not in profile['roots'], 'Duplicate experimental root'
    profile['roots'].append(symbol)
a.out.mkdir(parents=True)
manifest = a.out / 'compiler.json'
manifest.write_text(json.dumps(source, indent=2) + '\n')
(a.out / 'report.json').write_text(json.dumps(dict(
    kind='phase192-source-inventory', complete=True, inputs=inputs,
    addedModules=a.module, addedRoots=a.root_symbol, manifest=pin(manifest),
    scope='Source inventory only; no compilation, transformation or qualification.'), indent=2) + '\n')
print(manifest)

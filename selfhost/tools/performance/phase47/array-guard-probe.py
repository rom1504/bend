#!/usr/bin/env python3
"""Produce pinned array04 guard-only diagnostic variants; execute nothing.
Usage: array-guard-probe.py MODULE NEW_OUT
"""
import hashlib
import json
import sys
from pathlib import Path
PIN = '939da9e9644487fcc8cef3b34436a529a796adbab352403c4bd2a7af002a5387'
def identity(p):
    p = Path(p).resolve(strict=True)
    data = p.read_bytes()
    return dict(path=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
def oracle(n, seed):
    a, acc = [seed] * 128, 0
    for i in range(n):
        j = i % 128
        acc = (acc + a[j]) & 0xffffffff
        a[j] = (acc ^ i) & 0xffffffff
    return acc
module, output = map(Path, sys.argv[1:])
inputs = [identity(__file__), identity(module), identity(str(module) + '.json')]
assert inputs[1]['sha256'] == PIN
receipt = json.loads(Path(str(module) + '.json').read_text())
assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
assert receipt['output']['sha256'] == PIN
for record in [receipt['attempt'], receipt['compiler']['api'], receipt['compiler']['runtime'], receipt['input']]:
    p = record.get('path', record.get('file', record.get('canonicalPath')))
    actual = identity(p)
    assert actual['sha256'] == record['sha256']
    inputs.append(actual)
text = module.read_text()
anchor = 'if(regionProof!==null||!regionHostGuard()||regionGetPrototype(scalarObjectPrototype)!==null)return false;'
entry = 'if(arrayViewHostGuard()&&'
assert text.count(anchor) == text.count(entry) == 1
variants = {
    'original': text,
    'integer-only': text.replace(anchor, anchor.replace('regionHostGuard()', 'regionHostGuard(true)'), 1),
    'bypass-array-host': text.replace(entry, 'if(true&&', 1),
}
# Neither entry canonical validation nor source dependency/local guards change.
for name, body in variants.items():
    assert body.count('&&localGuard($guards)') == text.count('&&localGuard($guards)')
    assert body.count('Number.isInteger($s') == text.count('Number.isInteger($s')
    if name == 'integer-only': assert body.replace('!regionHostGuard(true)', '!regionHostGuard()', 1) == text
    if name == 'bypass-array-host': assert body.replace('if(true&&', entry, 1) == text
out = output.resolve()
out.mkdir(parents=True, exist_ok=False)
manifest = dict(kind='phase47-array04-guard-only-ablation', complete=False,
    diagnosticOnly=True, productionSafe=False, checkedDerivative=False,
    correctness='not-run', timing='not-run', inputs=inputs, variants={}, points=[])
for name, body in variants.items():
    p = out / name / 'program.mjs'; p.parent.mkdir()
    with p.open('x') as f: f.write(body)
    manifest['variants'][name] = identity(p)
for n, seed in [(128, 0), (4096, 17), (8192, 123)]:
    expected = oracle(n, seed)
    assert expected == {(128, 0): 0, (4096, 17): 2339999928, (8192, 123): 805701512}[n, seed]
    config = dict(exportName='bench', args=[n, seed], expected=expected,
                  warmupCalls=3, warmupMs=1000, calibrationMs=50, targetMs=200,
                  maxRepetitions=1000000)
    p = out / f'point-{n}-{seed}.json'
    with p.open('x') as f: json.dump(config, f, indent=2); f.write('\n')
    manifest['points'].append(dict(id=f'{n}-{seed}', config=identity(p)))
for record in inputs: assert identity(record['path']) == record
manifest['complete'] = True
with (out / 'manifest.json').open('x') as f: json.dump(manifest, f, indent=2); f.write('\n')
print(json.dumps(dict(output=str(out), complete=True, executed=False)))

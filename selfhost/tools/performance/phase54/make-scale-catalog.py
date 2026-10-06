#!/usr/bin/env python3
"""Generate checked-input candidates only; never compile or execute a program."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline-attempt', type=Path,
               default=ROOT/'selfhost/build/phase53/checked-ordered02')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase54') and not out.exists()
inputs = {}

def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert row['sha256'] == expected['sha256'], str(file)
    inputs[str(file)] = row
    return row

def save(file, value):
    with file.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')

pin(__file__)
attempt_file = a.baseline_attempt/'attempt.json'
attempt_pin = pin(attempt_file)
assert attempt_pin['sha256'] == 'c8e1a28b53d42a44eb7d8ebe69a17fa52967359019ea8eac7bd02671e961ba0f'
attempt = json.loads(attempt_file.read_text())
assert attempt['checked'] and attempt['config']['strictExact']
assert attempt['api']['sha256'] == '3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9'
pin(attempt['api']['file'], attempt['api'])
snapshot = Path(attempt['snapshot']['root'])
frozen = {str(Path(row['frozen']['file']).relative_to(snapshot)): row['frozen']
          for row in attempt['snapshot']['sources']}
manifest = snapshot/'src/compiler.json'
pin(manifest, frozen['src/compiler.json'])
modules = json.loads(manifest.read_text())['modules']
compiler_defs = 0
for relative in modules:
    file = snapshot/relative
    pin(file, frozen[relative])
    compiler_defs += len(re.findall(r'^def\s+', file.read_text(), re.MULTILINE))
assert compiler_defs == 3004 and len(modules) == 103
sizes = list(dict.fromkeys([128, 512, 513, 1024, compiler_defs]))
out.mkdir(parents=True)
fixtures = out/'fixtures'
fixtures.mkdir()
cases = []
for size in sizes:
    names = ['bench'] + [f'renamed_hop_{i:05d}' for i in range(1, size)]
    text = '# Independent scalar call chain; every function preserves its argument.\n'
    text += '# Declared function count includes bench; no primitive or foreign calls.\n\n'
    for i, name in enumerate(names):
        body = names[i+1]+'(value)' if i+1<size else 'value'
        text += f'def {name}(+value: U32) -> U32:\n  {body}\n\n'
    assert len(re.findall(r'^def\s+', text, re.MULTILINE)) == size
    file = fixtures/f'call-chain-{size}.bend'
    with file.open('x') as stream:
        stream.write(text)
    data = file.read_bytes()
    case_id = f'call-chain-{size}'
    cases.append(dict(id=case_id, category='source-scale', family='named-call-chain',
        description=f'{size} monomorphic scalar definitions in an acyclic identity chain',
        source=dict(path=str(file.relative_to(out)), bytes=len(data),
                    sha256=hashlib.sha256(data).hexdigest()),
        point=dict(exportName='bench', args=[37], expected=37),
        oracle='Every function forwards the same U32 argument; terminal function returns it.',
        declaredFunctions=size, sourceCallEdges=size-1,
        scope='Declared source count, not an assertion of selected graph vertex count. Files are unqualified until checked acquisition succeeds.',
        sets=['full', 'broad']+(['core'] if size<=513 else [])+(['fast'] if size==128 else [])))
ids = [case['id'] for case in cases]
catalog = dict(kind='bend-program-catalog', schemaVersion=1,
    upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',
    scope='Checked acquisition/request-cost probes; independent scalar output oracle. No generated-program speed claim.',
    sets=dict(fast=ids[:1], core=ids[:3], broad=ids, full=ids), cases=cases)
save(out/'catalog.json', catalog)
for file, row in inputs.items():
    assert pin(file) == row, file
save(out/'generation.json', dict(kind='phase54-independent-scale-source-generation',
    complete=True, dataOnly=True, checked=False, executed=False,
    compilerSize=dict(method='Count column-zero def declarations in frozen Phase53 compiler modules',
                      modules=len(modules), definitions=compiler_defs),
    inputs=list(inputs.values()), inputsUnchanged=True,
    catalog=pin(out/'catalog.json'), sizes=sizes,
    scope='Exact generated inputs and arithmetic-free oracle. A future compiler run must establish source acceptance.'))
print(json.dumps(dict(complete=True, checked=False, sizes=sizes, catalog=str(out/'catalog.json'))))

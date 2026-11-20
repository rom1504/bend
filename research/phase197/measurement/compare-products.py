#!/usr/bin/env python3
"""Freeze complete object identities before timing; execute no generated program."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase197'

def read(p):
    return json.loads(p.read_text())

def pin(p):
    data = p.read_bytes()
    return {'file': str(p), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def verify(item):
    assert pin(Path(item['file'])) == item, item['file']

plan = read(BUILD / 'measurement-plan01.json')
base_path = ROOT / 'selfhost/build/phase195/native45-01/programs.manifest.json'
baseline = read(base_path)
original = {row['id']: row for row in baseline['cases']}
rows, inputs = [], [pin(Path(__file__)), pin(base_path), pin(BUILD / 'measurement-plan01.json')]
for role in ['minimum', 'decrement', 'combined']:
    path = BUILD / f'{role}-build01/programs.manifest.json'
    build = read(path.with_name('report.json'))
    assert build['complete'] and not build.get('changedInputs') and len(build['rows']) == 6
    assert build['programManifest'] == pin(path)
    candidate = read(path)
    inputs += [pin(path), pin(path.with_name('report.json'))]
    for case in candidate['cases']:
        name = case['id']
        assert name in plan['cases']
        assert all(case[k] == original[name][k] for k in ['point', 'family', 'sourceGroup', 'source', 'expectedFile'])
        old = original[name]['products']['candidate']['generatedSource']
        new = case['products'][role]['generatedSource']
        verify(old)
        verify(new)
        rows.append({'role': role, 'case': name, 'baselineObject': old, 'candidateObject': new,
                     'wholeObjectIdentical': old['bytes'] == new['bytes'] and old['sha256'] == new['sha256']})
out = BUILD / 'machine-product-comparison01.json'
assert not out.exists()
out.write_text(json.dumps({'kind': 'phase197-machine-product-comparison', 'complete': True,
    'targetsRun': False, 'timingsRun': False, 'inputs': inputs, 'rows': rows,
    'scope': 'Whole emitted ELF object identity and exact benchmark/oracle inputs. Instruction activation witnesses are separately pinned by the mechanism authors.'}, indent=2) + '\n')
print(json.dumps({'complete': True, 'report': str(out), 'objectsCompared': len(rows),
                  'unchanged': [(r['role'], r['case']) for r in rows if r['wholeObjectIdentical']]}))

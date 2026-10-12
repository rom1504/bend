#!/usr/bin/env python3
"""Bind the unchanged guarded methods to corrected v2 corpus; source-only."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT / 'selfhost/build/phase70'


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, default=RAW/'coverage-methods01')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert os.sched_getaffinity(0) == {0}
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
parent = a.parent.resolve()
manifest = json.loads((parent/'methods.json').read_text())
assert manifest['kind'] == 'phase70-native-coverage-methods' and not manifest['targetsExecuted']
out.mkdir(parents=True)
changes = {
    'run.py': [("OLD/'cases.json'", "OLD/'cases-v2.json'", 1),
               ("OLD/'oracle.py'", "OLD/'oracle-v2.py'", 1),
               ("src=OLD/(name+'-batch.bend')", "src=ROOT/c['wrapper']", 1)],
    'emit.mjs': [('phase70/coverage/cases.json', 'phase70/coverage/cases-v2.json', 1)],
    'freeze.py': [
        ("['cases.json','oracle.py','prepare.py','make-batch.py']",
         "['cases-v2.json','oracle-v2.py','oracle.py','prepare.py','prepare-v2.py','make-batch.py','merge-plans.py']", 1),
        ('phase70/coverage/cases.json', 'phase70/coverage/cases-v2.json', 1),
        ("ROOT/'selfhost/tools/performance/phase70/coverage'/(c['name']+'-batch.bend')", "ROOT/c['wrapper']", 1),
        ('phase70-native-coverage-method-v1', 'phase70-native-coverage-method-v2', 1)],
    'compare.py': [('phase70/coverage/cases.json', 'phase70/coverage/cases-v2.json', 1),
                   ('phase70/coverage/oracle.py', 'phase70/coverage/oracle-v2.py', 2)]}
results = []
for method in manifest['methods']:
    source_pin = method['output']
    assert pin(source_pin['path']) == source_pin
    source_path = Path(source_pin['path'])
    assert source_path.parent == parent
    name = source_path.name
    source = source_path.read_text()
    edits = []
    for old, new, count in changes[name]:
        assert source.count(old) == count, (name, old, source.count(old))
        source = source.replace(old, new)
        edits.append(dict(before=old, after=new, count=count))
    if name.endswith('.py'):
        ast.parse(source, filename=name)
    dest = out/name
    write(dest, source)
    receipt = dict(kind='phase70-coverage-v2-derivation', parent=source_pin,
                   output=pin(dest), edits=edits, producer=pin(__file__), targetsExecuted=False)
    write(dest.with_suffix('.derivation.json'), receipt)
    results.append(receipt)
write(out/'methods.json', dict(kind='phase70-native-coverage-methods-v2',
                               targetsExecuted=False, parent=pin(parent/'methods.json'),
                               producer=pin(__file__), methods=results,
                               catalog=pin(HERE/'cases-v2.json'), oracle=pin(HERE/'oracle-v2.py')))
print(json.dumps(dict(manifest=pin(out/'methods.json'), targetsExecuted=False)))

#!/usr/bin/env python3
"""Record checked-build inputs at an explicit source freeze; print, never execute, the build."""
import argparse
import hashlib
import json
import shlex
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT/'selfhost'
RAW = PROJECT/'build/phase63'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def walk(directory):
    return sorted(p for p in directory.rglob('*') if p.is_file())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
p.add_argument('--attempt', type=Path)
p.add_argument('--selection', type=Path)
p.add_argument('--verify', action='store_true')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW.resolve())
if a.verify:
    report = json.loads((out/'recipe.json').read_text())
    for item in report['inputs']:
        assert identity(item['file']) == item, item['file']
    assert identity(out/'development.json') == report['config']
    print(json.dumps(dict(verified=True, inputs=len(report['inputs']))))
    raise SystemExit(0)
assert not out.exists() and a.attempt
attempt = a.attempt.resolve()
assert attempt.is_relative_to(RAW.resolve()) and not attempt.exists()
files = (walk(PROJECT/'src') +
    [p for p in walk(PROJECT/'tools/conformance') if p.suffix == '.mjs'] +
    [PROJECT/'tools'/f'{name}.mjs' for name in ['typed-driver','base-cache-graph','stage0-library','assemble',
        'compiler-abi','native-build','node-resource-args']] +
    [p for p in walk(PROJECT/'tools/development') if p.suffix == '.mjs'] +
    walk(PROJECT/'tests/frontend/phase2-rules'))
config = dict(project=str(PROJECT), upstream=str(PROJECT/'.bootstrap/upstream-phase23'),
    profile='equality', jobs=1, cpu='3', heapMb=1024, strictExact=True)
if a.selection:
    config['selection'] = str(a.selection.resolve(strict=True))
    files += [a.selection]
guard = PROJECT/'tools/performance/phase32/bounded-run.py'
files += [Path(__file__), NODE, guard, PROJECT/'.bootstrap/upstream-phase23/bend2/base.bend']
inputs = [identity(file) for file in sorted(set(files))]
for item in inputs:
    assert identity(item['file']) == item
out.mkdir(parents=True)
(out/'development.json').write_text(json.dumps(config, indent=2)+'\n')
command = ['python3', str(guard), '--seconds', '300', '--rss-mib', '2048', '--available-mib', '4096',
    str(out/'execution'), '--', 'taskset', '-c', '3', str(NODE), '--stack-size=4096',
    '--max-old-space-size=1024', str(PROJECT/'tools/development/workflow.mjs'), 'run',
    str(out/'development.json'), str(attempt)]
report = dict(kind='phase63-checked-build-recipe', complete=True, **{'pass':True}, dataOnly=True,
    targetExecuted=False, producer=identity(__file__), inputs=inputs,
    config=identity(out/'development.json'), attempt=str(attempt), command=command,
    scope='Root-requested source freeze, prior to workflow snapshot. Root runs only with editors paused. '
          'Workflow produces the authoritative checked source/API/driver/runtime snapshot and gate receipts. '
          'This recipe itself does not establish checking, conformance or performance.')
(out/'recipe.json').write_text(json.dumps(report, indent=2)+'\n')
(out/'commands.txt').write_text(shlex.join(command)+'\n')
print(json.dumps(dict(recipe=identity(out/'recipe.json'), command=command)))

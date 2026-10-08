#!/usr/bin/env python3
"""Derive selected final-gate methods into Phase68; data only, no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase68'
OLD = ROOT / 'selfhost/build/phase67'
HISTORICAL = ROOT / 'selfhost/build/phase66'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
TOOLS = ROOT / 'selfhost/tools/performance'


def pin(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def write(file, value):
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--baseline-attempt', type=Path, default=OLD/'scalars-build01')
p.add_argument('--baseline-js-manifest', type=Path, default=OLD/'scalars-build01-qualification/b1-programs/manifest.json')
a = p.parse_args()
out, attempt = a.out.resolve(), a.attempt.resolve()
assert out.is_relative_to(RAW) and out.parent == RAW and not out.exists()
assert attempt.is_relative_to(RAW)
assert attempt.exists(), 'Select an actual completed checked B1 before preparing final gates'
selected = json.loads((attempt/'attempt.json').read_text())
baseline = json.loads((a.baseline_attempt/'attempt.json').read_text())
for record in (selected, baseline):
    assert record['checked'] and record['config']['strictExact']
    assert pin(record['api']['file'])['sha256'] == record['api']['sha256']
assert pin(selected['node']['file'])['sha256'] == selected['node']['sha256']
assert selected['node']['file'] == NODE
source_maps = []
for record in (baseline,selected):
    sources = {}
    for row in record['snapshot']['sources']:
        actual = pin(row['frozen']['file'])
        assert actual['sha256'] == row['frozen']['sha256']
        sources[str(Path(actual['file']).relative_to(record['snapshot']['root']))] = actual
    source_maps.append(sources)
changed_inputs = [dict(path=k,baseline=source_maps[0].get(k),candidate=source_maps[1].get(k))
    for k in sorted(source_maps[0].keys() | source_maps[1].keys())
    if source_maps[0].get(k,{}).get('sha256') != source_maps[1].get(k,{}).get('sha256')]
parent_index = OLD/'qualification-method01/methods.json'
parent_methods = json.loads(parent_index.read_text())
assert parent_methods['complete'] and parent_methods['dataOnly'] and not parent_methods['targetsExecuted']
parent_pins = {row['output']['file']: row['output'] for row in parent_methods['methods']}

def inherited(file):
    assert pin(file) == parent_pins[str(file)]
    return file.read_text()

out.mkdir(parents=True)
rows = []
for relative in ['bootstrap/setup.mjs', 'bootstrap/reproduce.mjs',
                 'qualification/self-check.mjs', 'qualification/benchmark-equality.mjs']:
    parent = OLD / 'qualification-method01' / relative
    before = inherited(parent)
    after = before.replace('selfhost/build/phase67', 'selfhost/build/phase68')
    after = after.replace('inside Phase67', 'inside Phase68')
    output = out / relative
    write(output, after)
    rows.append(dict(parent=pin(parent), output=pin(output),
                     replacements=[dict(old='selfhost/build/phase67', new='selfhost/build/phase68', count=before.count('selfhost/build/phase67')),
                                   dict(old='inside Phase67', new='inside Phase68', count=before.count('inside Phase67'))]))
parent = OLD / 'qualification-method01/bootstrap/prepare-bootstrap.py'
before = inherited(parent)
edits = [("ROOT / 'selfhost/build/phase67'", "ROOT / 'selfhost/build/phase68'")]
after = before
for old, new in edits:
    assert after.count(old) == 1
    after = after.replace(old, new)
factory = out / 'bootstrap/prepare-bootstrap.py'
write(factory, after)
factory_derivation = dict(kind='phase68-bootstrap-path-only-derivation', parent=pin(parent),
                         output=pin(factory), edits=[dict(old=x, new=y, count=1) for x, y in edits])
write(out / 'bootstrap/derivation.json', factory_derivation)
rows.append(factory_derivation)
write(out / 'development.json', dict(project=str(ROOT/'selfhost'),
    upstream=str(ROOT/'selfhost/.bootstrap/upstream-phase66'), profile='equality',
    jobs=1, cpu='3', heapMb=1024, strictExact=True))
bootstrap = attempt.parent / (attempt.name + '-b2')
qualification = attempt.parent / (attempt.name + '-qualification')


def guarded(name, script, args, seconds=300):
    return ['python3', str(TOOLS/'phase46/job.py'), '--out', str(qualification/('job-'+name)),
            '--seconds', str(seconds), '--', NODE, '--stack-size=4096', '--max-old-space-size=1024',
            str(script), *map(str, args)]


commands = [
    dict(name='unchanged-js-closure', dataOnly=True, command=['taskset', '-c', '0', 'python3', '-B',
        str(TOOLS/'phase68/qualification/unchanged-js-routes-v2.py'), '--baseline', str(a.baseline_attempt.resolve()),
        '--candidate', str(attempt), '--out', str(qualification/'unchanged-js.json')]),
    dict(name='prepare-b2-plan', dataOnly=True, command=['taskset', '-c', '0', 'python3', '-B', str(factory),
        'plan', str(attempt), str(bootstrap), '--admission', str(HISTORICAL/'export-admission06/admission.json')]),
    dict(name='build-and-compare-b2', command=['bash', str(bootstrap/'run.sh')],
        note='Existing tiny/full/driver-source/driver-direct/driver-join/image-pins sequence; owns target guards internally.'),
    dict(name='fresh-b2-self-check', command=guarded('self-check', out/'qualification/self-check.mjs',
        [bootstrap/'image-pins.json', qualification/'self-check'])),
    dict(name='fresh-b2-fixed-point', command=guarded('fixed-point', out/'bootstrap/reproduce.mjs',
        [bootstrap/'image-pins.json', qualification/'fixed-point'])),
    dict(name='fresh-b1-js23', command=['python3', '-B', str(TOOLS/'phase52/prepare-v2.py'),
        '--attempt', str(attempt), '--catalog', str(HISTORICAL/'head-ts-inputs/catalog.json'), '--role', 'candidate',
        '--backend', 'direct', '--cpu', '3', '--rss-mib', '2048', '--available-mib', '4096',
        '--timeout', '30', '--node', NODE, '--set', 'full', '--out', str(qualification/'b1-programs')],
        note='Existing acquisition owns its sole guard; do not nest another.'),
    dict(name='fresh-b2-js23', command=guarded('b2-programs', out/'qualification/benchmark-equality.mjs',
        [bootstrap/'image-pins.json', qualification/'b1-programs/manifest.json', qualification/'b2-programs'])),
]
result = dict(kind='phase68-reused-final-methods', complete=True, dataOnly=True, targetsExecuted=False,
              producer=pin(__file__), closureMethod=pin(TOOLS/'phase68/qualification/unchanged-js-routes-v2.py'), parentMethods=pin(parent_index), selectedAttempt=pin(attempt/'attempt.json'),
              baselineAttempt=pin(a.baseline_attempt/'attempt.json'), baselineJsManifest=pin(a.baseline_js_manifest),
              changedInputs=changed_inputs, attempt=str(attempt), bootstrap=str(bootstrap),
              qualification=str(qualification), methods=rows, commands=commands,
              scope='Gate methods have only output-boundary relocation; actual selected attempt and all changed snapshot inputs are explicitly recorded. Existing actual checked source/API, bootstrap, B2 setup, unsafe verdict and fixed-point checks remain unchanged. No gate is claimed passed by preparing these commands; install only after final admission.')
write(out/'methods.json', result)
print(json.dumps(dict(methods=pin(out/'methods.json'), commands=len(commands))))

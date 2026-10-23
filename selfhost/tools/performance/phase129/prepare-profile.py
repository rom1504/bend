"""Bind the qualified Phase128 requests to existing generic profiling tools.

No target execution. Oracles come from the independently qualified timing block.
Sample counts are budgeted per workload instead of repeating every case equally.
"""
import argparse
import importlib.util
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('profiler_run', ROOT/'selfhost/tools/profiler/run.py')
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase129')
receipt = ROOT/'selfhost/build/phase112/p128-qualified01-n1-n2/report.json'
candidate = ROOT/'implementation/phase128/candidate.json'
data = json.loads(receipt.read_text())
selected = json.loads(candidate.read_text())
assert data['complete'] and data['passed'] and selected['nativeQualified']
R.verify(selected['n1'])
old = json.loads((ROOT/'selfhost/build/phase127/n1-physical-manifest02.json').read_text())
manifest = dict(schema='bend-native-profile-workloads-v1', cwd=str(ROOT),
    inputs=[R.pin(__file__), R.pin(receipt), R.pin(candidate), selected['qualification']],
    sampler=old['sampler'], unwindTable=old['unwindTable'], workloads=[],
    scope='Qualified Phase128 original N1 ELF, three frozen cold requests, exact previous qualified QBE oracles. Physical sampling only; no compiler rebuild, no newly inferred upstream speed ratio.')
jobs = []
for row in data['rows']:
    if row['round'] != 1 or row['role'] != 'phase111' or row['mode'] != 'cache':
        continue
    job = row['jobs'][0]
    assert job['stage'] == 'compile-qbe' and job['returncode'] == 0
    assert job['command'][0] == selected['n1']['file']
    inputs = [R.pin(x) for x in job['command'] if Path(x).is_file()]
    expected = dict(exitCode=0, stdout=dict(kind='exact', **job['stdout']),
                    stderr=dict(kind='exact', **job['stderr']))
    manifest['workloads'].append(dict(name=row['name'], timeoutSeconds=30,
        variants=[dict(name='phase128', command=job['command'], binary=selected['n1'],
                       inputs=inputs, expected=expected, dispatchInstrumentation=False)]))
    # Roughly 700 expected samples across both periods, >=2 complete pairs.
    # Actual loss/coverage gates still decide whether pooling is usable.
    samples_per_pair = job['seconds'] * (1e6/8000 + 1e6/13000)
    pairs = max(2, min(8, math.ceil(700/samples_per_pair)))
    command = ['python3', '-B', str(ROOT/'selfhost/tools/profiler/run.py'),
        '--manifest', str(out/'manifest.json'), '--out', str(out/row['name']),
        '--names', row['name'], '--modes', 'clean,sample', '--rounds', '3',
        '--periods-us', ','.join(['8000','13000']*pairs)]
    jobs.append(dict(name=row['name'], command=command, seconds=150,
                     plannedSamplePairs=pairs, priorCleanSeconds=job['seconds']))
assert len(jobs) == 3
for item in R.all_pins(manifest): R.verify(item)
out.mkdir(parents=True)
R.save(out/'manifest.json', manifest)
R.save(out/'jobs.json', dict(jobs=jobs, targetsRun=False, targetSamplesPerWorkload=700,
    scope='Planning only. Existing 500-sample, no-loss, CPU-coverage gates remain unchanged.'))
print(json.dumps(dict(complete=True, targetsRun=False, jobs=jobs)))

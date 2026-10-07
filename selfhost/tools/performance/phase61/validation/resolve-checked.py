#!/usr/bin/env python3
"""Join the preserved EPERM failure to a healthy unchanged-controller retry; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase61'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--final-root', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
base = a.final_root.resolve(strict=True)
out = a.out.resolve()
assert base.is_relative_to(RAW) and out.is_relative_to(RAW) and not out.exists()
inputs = {}

def pin(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024**2), b''):
            h.update(chunk)
    row = dict(file=str(file), sha256=h.hexdigest())
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row

def read(file):
    pin(file)
    return json.loads(Path(file).read_text())

def completed_step(step, command, code):
    assert step['name'] == command['name'] and step['command'] == command['command']
    assert step['environment'] == command.get('environment', {})
    assert step['returncode'] == code and step['finished'] >= step['started']

pin(__file__)
plan = read(base / 'checked-plan.json')
failed = read(base / 'checked-execution/report.json')
retry = read(base / 'checked-resume02-plan.json')
execution = read(base / 'checked-resume02-execution/report.json')
assert plan['kind'] == 'phase58-checked-qualification-plan' and plan['scope'] == 'final'
assert len(plan['commands']) == 14 and plan['executed'] is False
assert failed['planSha256'] == pin(base / 'checked-plan.json')['sha256']
assert failed['complete'] is False and failed['pass'] is False and len(failed['steps']) == 2
completed_step(failed['steps'][0], plan['commands'][0], 0)
completed_step(failed['steps'][1], plan['commands'][1], 1)
assert [x['name'] for x in plan['commands'][:2]] == ['acquire-composition', 'composition-controls']
assert retry['derivedFrom'] == pin(base / 'checked-plan.json') and retry['attempt'] == plan['attempt']
assert len(retry['commands']) == 13 and retry['commands'][1:] == plan['commands'][2:]
old = str(base / 'checked/composition-controls')
new = str(base / 'checked/composition-controls-retry02')
expected = {**plan['commands'][1], 'command': [new if x == old else new + '-supervisor' if x == old + '-supervisor' else x for x in plan['commands'][1]['command']]}
assert plan['commands'][1]['command'].count(old) == plan['commands'][1]['command'].count(old + '-supervisor') == 1
assert retry['commands'][0] == expected
assert execution['complete'] is True and execution['pass'] is True and execution['returncode'] == 0
assert execution['planSha256'] == pin(base / 'checked-resume02-plan.json')['sha256']
assert len(execution['steps']) == 13
for step, command in zip(execution['steps'], retry['commands']):
    completed_step(step, command, 0)
original = read(base / 'checked/composition-controls/report.json')
assert original['complete'] and not original['pass'] and len(original['observations']) == 18
assert not original['changedInputs']
for row in original['observations']:
    for result in row['roles'].values():
        assert not result['healthy'] and result['error'].startswith('spawnSync ') and result['error'].endswith(' EPERM')
healthy = read(Path(new) / 'report.json')
assert healthy['complete'] and healthy['pass'] and not healthy['changedInputs']
assert healthy['counts'] == dict(candidatePass=18, referencePass=18, referenceFailures=[], total=18)
assert len(healthy['observations']) == 18 and all(row['pass'] for row in healthy['observations'])
guard = read(Path(new + '-supervisor') / 'run.json')
assert guard['complete'] and guard['returncode'] == 0
assert guard['command'] == expected['command'][expected['command'].index('--') + 1:]
manifest = read(base / 'checked/composition-acquisition/manifest.json')
assert manifest['complete'] and manifest['passed'] and manifest['roles']['direct']['attempt'] == plan['attempt']
assert pin(plan['attempt']['file']) == plan['attempt']
for module in manifest['roles']['direct']['modules'].values():
    receipt = read(module + '.json')
    assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
    assert {k: receipt['attempt'][k] for k in ['file', 'sha256']} == plan['attempt']
    assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
    assert pin(module)['sha256'] == receipt['output']['sha256']
for row in plan['inputs'] + retry['inputs'] + healthy['inputs']:
    assert pin(row['file'])['sha256'] == row['sha256']
for row in list(inputs.values()):
    assert pin(row['file']) == row
report = dict(kind='phase61-resolved-checked-qualification', complete=True,
              attempt=plan['attempt'], originalPlan=pin(base / 'checked-plan.json'),
              preservedFailure=pin(base / 'checked-execution/report.json'),
              retryPlan=pin(base / 'checked-resume02-plan.json'), retryExecution=pin(base / 'checked-resume02-execution/report.json'),
              compositionReceipt=pin(Path(new) / 'report.json'), reusedAcquisition=pin(base / 'checked/composition-acquisition/manifest.json'),
              logicalJobs=14, reusedSuccessfulJobs=1, healthyRetryJobs=13, originalQueuePass=False,
              expected=[dict(name=x['name'], expected=x.get('expected')) for x in plan['commands']],
              inputs=list(inputs.values()), targetsExecuted=False,
              scope='Checked-stage command and input closure only: original successful acquisition plus thirteen healthy commands with their original guards, including unchanged composition18 retry. Original EPERM failure remains failed. No bootstrap, B2, performance, install or final release admission is implied.')
report['pass'] = True
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, passed=True, logicalJobs=14, receipt=pin(out))))

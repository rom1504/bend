#!/usr/bin/env python3
"""Join closed final04 semantic gates without executing compilers or programs."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = {}


def pin(value, base=ROOT):
    item = value if isinstance(value, dict) else None
    file = (Path(base) / (item.get('file', item.get('path')) if item else value)).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value, base=ROOT):
    return json.loads(Path(pin(value, base)['file']).read_text())


attempt_pin = pin(RAW / 'checked-b1-04/attempt.json')
attempt = read(attempt_pin)
bootstrap = read(attempt['bootstrapReport'])
image_pins = pin(RAW / 'bootstrap-b2-04b/image-pins.json')
image = read(image_pins)
assert image['attempt'] == attempt_pin and pin(attempt['api']) == image['b1']
assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
reference_audit = pin(ROOT / 'implementation/phase66/evidence/reference-oracles.json')
assert read(reference_audit)['complete']
methods = read(RAW / 'qualification-method01/methods.json')
for row in methods['rows']:
    pin(row['output'])
groups = []
executions = []
for role, plan_name, execution_name, jobs in [
    ('checked', 'checked-js-plan.json', 'checked-js-execution', 10),
    ('b2', 'b2-plan.json', 'b2-execution', 8),
]:
    plan_pin = pin(RAW / 'qualification04' / plan_name)
    plan = read(plan_pin)
    assert plan['complete'] and not plan['executed'] and plan['attempt'] == attempt_pin
    execution_pin = pin(RAW / 'qualification04' / execution_name / 'report.json')
    execution = read(execution_pin)
    assert execution['complete'] and execution['pass'] and execution['returncode'] == 0
    assert execution['planSha256'] == plan_pin['sha256']
    assert Path(execution['plan']).resolve() == Path(plan_pin['file'])
    assert len(execution['steps']) == len(plan['commands']) == jobs
    for command, step in zip(plan['commands'], execution['steps']):
        assert command['name'] == step['name'] and command['command'] == step['command']
        assert command.get('environment', {}) == step['environment']
        assert step['returncode'] == 0 and step['finished'] >= step['started']
    for row in plan['inputs']:
        pin(row)
    executions.append(dict(role=role, plan=plan_pin, execution=execution_pin, jobs=jobs))
    for name, total in [('source', 96), ('numeric', 34), ('composition', 18), ('overapplication', 2)]:
        directory = RAW / 'qualification04' / role
        acquisition_pin = pin(directory / (name + '-acquisition/manifest.json'))
        acquisition = read(acquisition_pin)
        assert acquisition['complete'] and acquisition['passed']
        catalog = read(acquisition['catalog'])
        assert catalog['upstreamCommit'] == bootstrap['revision']
        if role == 'checked':
            assert pin(acquisition['roles']['direct']['attempt']) == attempt_pin
        else:
            staged = read(acquisition['roles']['direct']['image'])
            assert staged['kind'] == 'phase56-staged-direct-image' and staged['complete']
            assert pin(staged['image']['pins']) == image_pins
            assert staged['image']['api']['sha256'] == image['b2']['sha256']
            assert pin(staged['image']['checkedSubject']) == attempt_pin
        report_pin = pin(directory / (name + '-controls/report.json'))
        report = read(report_pin)
        assert report['complete'] and report['pass'] and not report.get('error')
        assert not report.get('changedInputs')
        assert len(report['observations']) == total and all(row['pass'] for row in report['observations'])
        assert report['counts']['total'] == total
        candidate_key = 'candidateSourcePass' if name == 'source' else 'candidatePass'
        reference_key = 'referenceSourcePass' if name == 'source' else 'referencePass'
        assert report['counts'][candidate_key] == total
        assert report['counts'][reference_key] == dict(source=95, numeric=28, composition=18, overapplication=2)[name]
        for row in report['inputs']:
            pin(row)
        groups.append(dict(role=role, name=name, acquisition=acquisition_pin,
                           report=report_pin, counts=report['counts']))
maintained_pin = pin(RAW / 'qualification04/checked/maintained8/report.json')
maintained = read(maintained_pin)
assert maintained['complete'] and maintained['pass'] and maintained['inputsUnchanged']
assert pin(maintained['attempt']) == attempt_pin
assert len(maintained['tests']) == 8 and all(row['pass'] for row in maintained['tests'])
assert {row['name'] for row in maintained['tests']} == {
    'ir', 'backend', 'global-initializers', 'choice', 'arm', 'primitive-guards', 'provenance', 'foreign'}
for row in maintained['inputs']:
    pin(row)
for row in maintained['tests']:
    if 'report' in row:
        pin(row['report'])
pin(__file__)
result = dict(kind='phase66-final04-semantic-qualification-audit', complete=True,
              **{'pass': True}, dataOnly=True, targetExecuted=False,
              producer=pin(__file__), attempt=attempt_pin, selectedB1=pin(attempt['api']),
              selectedB2=image['b2'], imagePins=image_pins, source=image['source'],
              referenceAudit=reference_audit, executions=executions, groups=groups,
              maintained8=maintained_pin, verifiedInputFiles=len(inputs),
              inputIndexSha256=hashlib.sha256(json.dumps(sorted(inputs.values(), key=lambda row: row['file']), sort_keys=True).encode()).hexdigest(),
              scope='Both actual checked B1 and genuine emitted B2 satisfy all source96/numeric34/composition18/overapplication2 candidate oracles; maintained8 also passes. Fresh TypeScript failures remain explicit at95/28/18/2. Counts overlap. Native qualification, final05 unchanged-JS closure reuse, full frontend/backend corpus, selfhosting, program equality, timing and release are separate mandatory receipts.')
out = a.out.resolve()
assert out.is_relative_to(ROOT) and not out.exists()
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(out), candidateGroups=8, maintainedSuites=8, targetExecuted=False)))

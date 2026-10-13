#!/usr/bin/env python3
"""Freeze a new checked candidate against unchanged Phase82, exact C required."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('attempt', type=Path)
parser.add_argument('out', type=Path)
parser.add_argument('--cases', default='numeric,map,functions65,small')
parser.add_argument('--rounds', type=int, default=2)
parser.add_argument('--stage', choices=['b1', 'b2'], default='b1')
parser.add_argument('--images', type=Path)
parser.add_argument('--typescript', action='store_true')
args = parser.parse_args()
inputs = {}


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    value = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    assert str(file) not in inputs or inputs[str(file)] == value
    inputs[str(file)] = value
    return value


def verify(value):
    actual = pin(value['file'])
    assert actual['sha256'] == value['sha256'], actual['file']
    if 'bytes' in value:
        assert actual['bytes'] == value['bytes']
    return actual


parent = ROOT/'selfhost/build/phase83/survey01/plan.json'
parent_pin = pin(parent)
plan = json.loads(parent.read_text())
for item in plan['inputs']:
    verify(item)
attempt = json.loads(Path(pin(args.attempt)['file']).read_text())
assert attempt['checked'] and attempt['config']['strictExact']
candidate_api = verify(attempt['api'])
if args.stage == 'b2':
    assert args.images
    images = json.loads(Path(pin(args.images)['file']).read_text())
    assert verify(images['b1']) == candidate_api
    candidate_api = verify(images['b2'])
out = args.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase84')
out.mkdir(exist_ok=False)
baseline = plan['roles'][args.stage]
roles = {args.stage: {**baseline, 'preparationPlan': parent_pin}}
prepare = json.loads(Path(pin(baseline['preparation'])['file']).read_text())
assert prepare['pass'] and prepare['complete'] and prepare['plan'] == parent_pin
for item in prepare['cache']+prepare['products']:
    verify(item)
source = Path(attempt['snapshot']['root'])
project = out/'candidate/project'
for rel in ['tools/typed-driver.mjs', 'tools/assemble.mjs', 'tools/native-build.mjs',
            'tools/node-resource-args.mjs', 'tools/compiler-abi.mjs',
            'tools/base-cache-graph.mjs', 'src/runtime.mjs', 'src/compiler.json']:
    target = project/rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source/rel, target)
    assert pin(source/rel)['sha256'] == pin(target)['sha256']
shutil.copytree(source/'src/runtime/native', project/'src/runtime/native')
for directory in [source/'src/runtime/native', project/'src/runtime/native']:
    for file in directory.rglob('*'):
        if file.is_file():
            pin(file)
roles['candidate'] = {**baseline, 'project': str(project), 'api': candidate_api,
    'driver': pin(project/'tools/typed-driver.mjs'), 'runtime': pin(project/'src/runtime.mjs'),
    'preparation': str(out/'runs/prepare-candidate/report.json')}
if args.typescript:
    roles['typescript'] = plan['roles']['typescript']
cases = {key: plan['cases'][key] for key in args.cases.split(',')}
for case in cases.values():
    old = case['expected']
    case['expected'] = {r: old['b1' if r == 'candidate' else r] for r in roles}
jobs = [dict(name='prepare-candidate', role='candidate', action='prepare', profile=False)]
for round_ in range(args.rounds):
    for i, case in enumerate(cases):
        order = list(roles)
        shift = (round_+i) % len(order)
        order = order[shift:]+order[:shift]
        for role in order:
            jobs.append(dict(name=f'clean-{round_}-{case}-{role}', role=role, case=case,
                action='request', profile=False, round=round_))
for name in ['prepare-screen.py', 'worker.mjs', 'run.py', 'derivation.json']:
    pin(HERE/name)
plan.update(roles=roles, cases=cases, jobs=jobs, inputs=list(inputs.values()),
    scope=f'Phase84 {args.stage} candidate versus unchanged Phase82. Fresh checked C requests with ordinary reports, exact per-role previous C. Prepared Bend Base/imports separate; all candidate preparation/processing inside request remains timed. Explicit historical preparation binding for baseline; no process reuse. Screening only until broader qualification.')
(out/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
print(out/'plan.json')

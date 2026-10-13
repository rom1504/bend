#!/usr/bin/env python3
"""Freeze unchanged Phase82 and eight varied existing C compilation inputs."""
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'selfhost/build/phase83/survey01'
inputs = {}


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if str(path) in inputs:
        assert inputs[str(path)] == value
    inputs[str(path)] = value
    return value


def verify(value):
    actual = pin(value.get('file', value.get('path')))
    assert actual['sha256'] == value['sha256'], actual['file']
    return actual


def read(path):
    return json.loads(Path(pin(path)['file']).read_text())


paired = read(ROOT/'selfhost/build/phase82/paired04/plan.json')
held = read(ROOT/'selfhost/build/phase82/heldout04/plan.json')
identity = read(ROOT/'selfhost/build/phase82/compiler04-C-identity12/plan.json')
OUT.mkdir(parents=True, exist_ok=False)
# Retain and verify the complete existing input inventory, deduplicated by path.
for parent in [paired, held, identity]:
    for item in parent['inputs']:
        verify(item)
roles = {'typescript': paired['roles']['typescript']}
for label, parent_label in [('b1', 'ordinary'), ('b2', 'ordinary-b2')]:
    old = paired['roles'][parent_label]
    source, project = Path(old['project']), OUT/label/'project'
    for directory in ['tools', 'src']:
        shutil.copytree(source/directory, project/directory)
    for file in project.rglob('*'):
        if file.is_file():
            pin(file)
    roles[label] = {**old, 'project': str(project),
        'driver': pin(project/'tools/typed-driver.mjs'),
        'runtime': pin(project/'src/runtime.mjs'),
        'preparation': str(OUT/'runs'/('prepare-'+label)/'report.json')}

cases = {}
for name in ['numeric', 'array', 'lexer', 'closures', 'map', 'expression', 'small', 'functions65']:
    if name in paired['cases'] or name in held['cases']:
        case = (paired['cases'] | held['cases'])[name]
        expected = case['expected']
        case = {**case, 'expected': {'typescript': expected['typescript'],
            'b1': expected['ordinary'], 'b2': expected['ordinary-b2']}}
    else:
        case = identity['cases'][name]
        directories = {'closures': 'phase67/native-baseline02',
            'map': 'phase67/native-heldout-baseline02',
            'expression': 'phase70/compiler02-coverage-baseline-holdouts01'}
        directory = ROOT/'selfhost/build'/directories[name]
        acquisition = read(directory/'report.json')
        row, = [r for r in acquisition['records'] if r['case'] == name and r['role'] == 'upstream']
        assert row['correct'] and row['emission']['complete'] and row['process']['complete']
        assert verify(row['source']) == verify(case['input'])
        case = {**case, 'referenceAcquisition': pin(directory/'report.json'),
            'expected': {**case['expected'], 'typescript': verify(row['nativeSource'])}}
    verify(case['input'])
    for value in case['expected'].values():
        verify(value)
    cases[name] = case

jobs = [dict(name='prepare-'+r, role=r, action='prepare', profile=False) for r in ['b1', 'b2']]
for round_ in range(2):
    for i, case in enumerate(cases):
        order = ['b1', 'b2', 'typescript']
        shift = (round_ + i) % 3
        order = order[shift:] + order[:shift]
        for role in order:
            jobs.append(dict(name=f'clean-{round_}-{case}-{role}', role=role,
                case=case, action='request', profile=False, round=round_))
for case in cases:
    for role in ['b2', 'typescript']:
        jobs.append(dict(name=f'profile-{case}-{role}', role=role,
            case=case, action='request', profile=True))
for role in ['b1', 'b2', 'typescript']:
    jobs.append(dict(name=f'profile-heap-numeric-{role}', role=role,
        case='numeric', action='request', profile=True, heap=True))
for file in HERE.iterdir():
    if file.is_file():
        pin(file)
plan = {**paired, 'roles': roles, 'cases': cases, 'jobs': jobs,
    'inputs': list(inputs.values()),
    'scope': 'Phase83 unchanged Phase82 compilation investigation. Eight sources chosen for scalar/array/lexer/closure/map/ADT and non-IO small/many-function diversity. Two rotating clean rounds are diagnostic coverage, not qualification or improvement. Fresh requests, ordinary reports, prepared Bend Base and imports excluded, no Clang/execution. Separate CPU/heap diagnostic runs.'}
(OUT/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
print(OUT/'plan.json')

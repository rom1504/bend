#!/usr/bin/env python3
"""Freeze three emission-only jobs against runtime-qualified Products10 C."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
RAW = ROOT/'selfhost/build/phase68'
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    p = Path(expected.get('file', expected.get('path')) if expected else value).resolve(strict=True)
    data = p.read_bytes()
    result = dict(path=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256']
        assert 'bytes' not in expected or result['bytes'] == expected['bytes']
    inputs[str(p)] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['path']).read_text())


ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--attempt', type=Path, required=True)
ap.add_argument('--out', type=Path, required=True)
args = ap.parse_args()
out = args.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
proposal = read(HERE/'candidate-v2.json')
pin(proposal['patch'])
baseline_attempt = read(proposal['baselineAttempt'])
baseline_api = pin(baseline_attempt['api'])
attempt_pin, attempt = pin(args.attempt), read(args.attempt)
assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
for item in attempt['snapshot']['sources']:
    pin(item['frozen'])
for key in ['checkedApi', 'derivationReport', 'bootstrapReport', 'base', 'runtime', 'node']:
    pin(attempt[key])
api = pin(attempt['api'])
strict = pin(args.attempt.parent/'validation-001/report.json')
assert read(strict)['complete'] and read(strict)['pass']
changed = {f['path'].removeprefix('selfhost/') for f in proposal['files']}


def inventory(a):
    return sorted((str(Path(x['frozen']['file']).relative_to(a['snapshot']['root'])),
                   pin(x['frozen'])['sha256']) for x in a['snapshot']['sources']
                  if str(Path(x['frozen']['file']).relative_to(a['snapshot']['root'])) not in changed)


assert inventory(attempt) == inventory(baseline_attempt)
for f in proposal['files']:
    relative = f['path'].removeprefix('selfhost/')
    assert pin(Path(attempt['snapshot']['root'])/relative)['sha256'] == pin(f['after'])['sha256']
    assert pin(Path(baseline_attempt['snapshot']['root'])/relative)['sha256'] == pin(f['before'])['sha256']
acquisition_pin = pin(RAW/'native-products10/report.json')
acquisition = read(acquisition_pin)
assert acquisition['complete']
recipe_parent = pin(acquisition['recipe'])
recipe = read(recipe_parent)
assert recipe['api'] == baseline_api['path']
for p in recipe['inputs']:
    pin(p)
assert sum(p['path'] == baseline_api['path'] for p in recipe['inputs']) == 1
recipe['api'] = api['path']
recipe['verifyInstalled'] = False
recipe['inputs'] = [api if p['path'] == baseline_api['path'] else p for p in recipe['inputs']]
pin(__file__)
guard = pin(ROOT/'selfhost/tools/performance/phase46/job.py')
emitter = pin(ROOT/'selfhost/tools/performance/phase67/benchmark/emit.mjs')
out.mkdir(parents=True)
recipe_path = out/'recipe.json'
recipe_path.write_text(json.dumps(recipe, indent=2)+'\n')
pin(recipe_path)
jobs = []
for case in ['numeric', 'array', 'lexer']:
    records = [r for r in acquisition['records'] if r['case'] == case and r['role'] == 'selfhost']
    assert len(records) == 1
    row = records[0]
    assert row['correct'] and row['emission']['complete'] and row['emission']['returncode'] == 0
    assert row['toolchain']['complete'] and row['toolchain']['returncode'] == 0
    assert row['process']['complete'] and row['process']['returncode'] == 0
    baseline = pin(row['nativeSource'])
    receipt_pin = pin(row['emissionReceipt'])
    receipt = read(receipt_pin)
    assert receipt['complete'] and receipt['role'] == 'selfhost' and receipt['target'] == 'c'
    assert pin(receipt['recipe']) == recipe_parent
    assert pin(receipt['output']) == baseline
    assert pin(receipt['compiler'][0]) == baseline_api
    assert pin(receipt['producer']) == emitter
    assert pin(receipt['input']) == pin(row['source'])
    for group in ['inputs', 'compiler', 'programInputs', 'effectInputs']:
        for value in receipt[group]:
            pin(value)
    original = copy.deepcopy(row['emission']['command'])
    assert original[:3] == ['taskset', '-c', '3']
    assert original[-3:] == ['selfhost', row['source']['path'], baseline['path']]
    assert original.count(recipe_parent['path']) == 1
    destination = out/case/'program.c'
    command = [str(recipe_path) if x == recipe_parent['path'] else
               str(destination) if x == baseline['path'] else x for x in original[3:]]
    jobs.append(dict(case=case,
        command=['python3', guard['path'], '--out', str(destination.parent/'supervisor'),
                 '--seconds', '120', '--']+command,
        baseline=baseline['path'], output=str(destination),
        baselineIdentity=baseline, baselineEmission=receipt_pin))
plan = dict(kind='phase68-local-occurrence-emission-equality', recipe=str(recipe_path),
    jobs=jobs, attempt=attempt_pin, api=api, strict=strict,
    baselineAttempt=pin(proposal['baselineAttempt']), baselineApi=baseline_api,
    acquisition=acquisition_pin, inputs=list(inputs.values()), targetExecuted=False,
    scope='Only the actual compiler API changes in the pinned Products10 acquisition recipe. Three guarded emissions must reproduce entire runtime-qualified Products10 C. No Clang/runtime execution or speed claim from plan preparation.')
plan_path = out/'plan.json'
plan_path.write_text(json.dumps(plan, indent=2)+'\n')
print(json.dumps(dict(plan=pin(plan_path), jobs=len(jobs), targetExecuted=False)))

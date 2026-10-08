#!/usr/bin/env python3
"""Data-only C transformation and command preparation; executes no target."""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
BUILD = ROOT / 'selfhost/build/phase68'
OLD = ROOT / 'selfhost/tools/performance/phase46'


def identity(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {'path': str(path), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


def write(path, value):
    with path.open('x') as f:
        f.write(json.dumps(value, indent=2) + '\n')


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
out = args.out.resolve()
out.mkdir(parents=True, exist_ok=False)
recipe_path = BUILD / 'native-flat06-recipe.json'
plan_path = BUILD / 'native-plan02.json'
recipe = json.loads(recipe_path.read_text())
plan = json.loads(plan_path.read_text())
acquisition_path = BUILD / 'native-flat06/report.json'
acquisition = json.loads(acquisition_path.read_text())
assert acquisition['complete']
assert acquisition['recipe'] == identity(recipe_path)
spec = importlib.util.spec_from_file_location('phase68_inline_oracle', OLD / 'oracle.py')
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)
catalog = {c['name']: c for c in json.loads((OLD / 'cases.json').read_text())}
pins = {x['path']: x for x in recipe['inputs']}
assert identity(recipe['clang']) == pins[recipe['clang']]
rows = []
measurements = []
for case in ['numeric', 'array']:
    directory = out / case
    directory.mkdir()
    original = next(r for r in acquisition['records'] if r['case'] == case and r['role'] == 'selfhost')
    assert original['correct']
    for key in ['nativeSource', 'executable', 'emissionReceipt']:
        assert identity(original[key]['path']) == original[key]
    source = Path(original['nativeSource']['path'])
    audit_path = directory / 'original-worker-audit.json'
    subprocess.run([sys.executable, str(HERE.parent / 'check-workers.py'), str(source),
                    '--require-workers', '--out', str(audit_path)], check=True)
    audit = json.loads(audit_path.read_text())
    assert audit['pass']
    before = source.read_text()
    after, count = re.subn(r'^INLINE Term (?=NF_[A-Za-z0-9_]+\()',
                          'INLINE __attribute__((always_inline)) Term ', before, flags=re.M)
    assert count == 2 * audit['workerCount']
    assert after.replace('INLINE __attribute__((always_inline)) Term NF_', 'INLINE Term NF_') == before
    candidate = directory / 'program.c'
    with candidate.open('x') as f:
        f.write(after)
    executable = directory / 'program'
    c = catalog[case]
    points = oracle.points(c)
    assert points[0] == c['expected']
    n, warm = plan[case]['repetitions'], plan[case]['warmups']
    expected_smoke = [c['expected'], oracle.digest(points, 0), oracle.digest(points, 1)]
    expected_plan = [c['expected'], oracle.digest(points, warm), oracle.digest(points, n)]
    row = dict(case=case, originalSource=original['nativeSource'], originalExecutable=original['executable'],
               originalEmissionReceipt=original['emissionReceipt'], candidateSource=identity(candidate),
               candidateExecutable=str(executable), replacements=count, workerCount=audit['workerCount'],
               maxCallDagDepth=audit['maxCallDagDepth'], workerAudit=identity(audit_path),
               totalWorkerBodyBytes=sum(w['bodyBytes'] for w in audit['workers'].values()),
               largestWorkerBodyBytes=max(w['bodyBytes'] for w in audit['workers'].values()),
               binarySizeLimitBytes=8 * original['executable']['bytes'],
               clangCommand=['taskset', '-c', '3', recipe['clang'], *recipe['clangArgs'], str(candidate),
                             *recipe['linkArgs'], '-o', str(executable)],
               clangReceiptDir=str(directory / 'toolchain'),
               smokeCommand=['taskset', '-c', '3', str(executable), '--threads', '1', '--gpu', 'off', '--', '1', '0'],
               smokeReceiptDir=str(directory / 'smoke'), expectedSmoke=expected_smoke,
               expectedPlan02=expected_plan, repetitions=n, warmups=warm)
    rows.append(row)
    for round_index in range(3):
        roles = ['baseline', 'candidate'] if round_index % 2 == 0 else ['candidate', 'baseline']
        for role in roles:
            executable_path = original['executable']['path'] if role == 'baseline' else str(executable)
            dest = out / 'measure' / (case + '-' + role + '-r' + str(round_index))
            measurements.append(dict(case=case, role=role, round=round_index, receiptDir=str(dest),
                childReceipt=str(dest / 'child.json'), expected=expected_plan,
                command=['taskset', '-c', '3', 'python3', str(OLD / 'execute.py'), str(dest / 'child.json'),
                         executable_path, '--threads', '1', '--gpu', 'off', '--', str(n), str(warm)]))
manifest = dict(kind='phase68-c-worker-inline-diagnostic-proposal', executed=False,
    producer=identity(__file__), recipe=identity(recipe_path), originalAcquisition=identity(acquisition_path),
    plan=identity(plan_path), clang=identity(recipe['clang']), compilerEnvironment=recipe['compilerEnvironment'],
    oracleInputs=[identity(OLD / 'oracle.py'), identity(OLD / 'cases.json'), *map(identity, oracle.ORACLE_FILES)],
    executionGuard=dict(rssMiB=2048, availableMiB=4096, clangSeconds=90, smokeSeconds=20, runtimeSeconds=45),
    transform='Only every private NF prototype/definition gains __attribute__((always_inline)); inverse is exact original C.',
    policy='Diagnostic only. Stop before timing on compilation/oracle failure or executable >8x own baseline. Do not narrow selection.',
    cases=rows, measurements=measurements)
write(out / 'diagnostic.json', manifest)
print(json.dumps({'manifest': identity(out / 'diagnostic.json'), 'cases': [r['case'] for r in rows]}))

#!/usr/bin/env python3
"""Freeze the P68-016 four-arm plan without executing any target."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT/'selfhost/build/phase68'
METHOD = ROOT/'selfhost/tools/performance/phase68/benchmark/saved-native-v2.py'
assert hashlib.sha256(METHOD.read_bytes()).hexdigest() == '83c586f20c37965a536c32d8c129a6cf481e66e634ab437a6b4a944016510cd2'
spec = importlib.util.spec_from_file_location('p68_array_admission', METHOD)
m = importlib.util.module_from_spec(spec)
source = METHOD.read_text()
marker = '\nparser = argparse.ArgumentParser(description=__doc__)\n'
assert source.count(marker) == 1
exec(compile(source.split(marker)[0], str(METHOD), 'exec'), m.__dict__)
spec = importlib.util.spec_from_file_location('p68_array_derivation', HERE/'derive-v1.py')
d = importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--recipe', type=Path, required=True)
ap.add_argument('--attempt', type=Path, required=True)
ap.add_argument('--acquired', type=Path, required=True)
ap.add_argument('--plan', type=Path, required=True)
ap.add_argument('--out', type=Path, required=True)
args = ap.parse_args()
out = args.out.resolve()
out.relative_to(RAW)
assert not out.exists()
recipe, recipe_pin, continuity, inputs, acquisitions, products = m.admit(
    args.recipe, args.attempt, [args.acquired])
plan_pin, protocol = m.pin(args.plan), m.read(args.plan)['array']
repetitions, warmups = protocol['repetitions'], protocol['warmups']
assert repetitions == 61440 and warmups == 7680, 'Only the reviewed common plan03 counts'
parent = products[('array', 'selfhost')]
out.mkdir(parents=True)
derived_pin = d.derive(parent['nativeSource']['path'], out/'derived')
derived = m.read(derived_pin['path'])
records, executables = [], {'baseline': parent['executable']['path']}
for variant in derived['variants']:
    role = variant['name']
    directory = out/'derived'/role
    executable = directory/'program'
    executables[role] = str(executable)
    records.append(dict(role=role, candidateSource=variant['source'], derivation=variant['derivation'],
        candidateExecutable=str(executable), clangReceiptDir=str(directory/'toolchain'),
        clangCommand=['taskset', '-c', '3', recipe['clang'], *recipe['clangArgs'],
            variant['source']['path'], *recipe['linkArgs'], '-o', str(executable)]))
points = m.O.points(m.CATALOG['array'])
assert points[0] == m.CATALOG['array']['expected']
roles = ['baseline', 'packed', 'unshared', 'combined']
smokes = []
for role in roles:
    for threads in [1, 4]:
        for count in [1, 17]:
            destination = out/'smoke'/f'{role}-t{threads}-n{count}'
            smokes.append(dict(role=role, threads=threads, repetitions=count, warmups=0,
                expected=[points[0], m.O.digest(points, 0), m.O.digest(points, count)],
                receiptDir=str(destination), command=['taskset', '-c', '3', executables[role],
                    '--threads', str(threads), '--gpu', 'off', '--', str(count), '0']))
measurements = []
for round_index in range(3):
    for role in roles[round_index:] + roles[:round_index]:
        destination = out/'measure'/f'{role}-r{round_index}'
        child = destination/'child.json'
        measurements.append(dict(role=role, round=round_index, repetitions=repetitions, warmups=warmups,
            expected=[points[0], m.O.digest(points, warmups), m.O.digest(points, repetitions)],
            receiptDir=str(destination), childReceipt=str(child),
            command=['taskset', '-c', '3', 'python3', str(m.OLD/'execute.py'), str(child),
                executables[role], '--threads', '1', '--gpu', 'off', '--', str(repetitions), str(warmups)]))
extra = [m.pin(__file__), m.pin(HERE/'derive-v1.py'), m.pin(HERE/'run-v1.py'), m.pin(METHOD),
    m.pin(ROOT/'selfhost/tools/performance/programs/support.py'), m.pin(m.OLD/'execute.py'),
    m.pin(m.OLD/'oracle.py'), m.pin(m.OLD/'cases.json'), *map(m.pin, m.O.ORACLE_FILES), plan_pin,
    m.pin(ROOT/'experiments/phase68/P68-016-scalar-arrays.md'), derived_pin, continuity['attempt']]
manifest = dict(kind='phase68-scalar-array-four-arm-plan-v1', targetExecuted=False,
    producer=m.pin(__file__), runner=m.pin(HERE/'run-v1.py'), derivationMethod=m.pin(HERE/'derive-v1.py'),
    recipe=recipe_pin, admissionMethod=m.pin(METHOD), continuity=continuity,
    acquisitions=acquisitions, actualInputs=inputs+extra, plan=plan_pin, parent=parent,
    compilerEnvironment=recipe['compilerEnvironment'], records=records, smokes=smokes, measurements=measurements,
    executionGuard=dict(cpu=3, rssMiB=2048, availableMiB=4096, clangSeconds=90, smokeSeconds=20, runtimeSeconds=45),
    scope='Exact checked products15 saved C only; three independent intervention builds, '
        'four arms, three rotated rounds at common plan03 counts, independent oracle16 '
        'schedule. Smokes include1/17 repetitions and1/4 threads, no concurrency proof. '
        'No production compiler/raw ABI change or general conformance claim.')
for item in inputs+extra+acquisitions+[recipe_pin]:
    m.verify(item)
for row in records:
    m.verify(row['candidateSource']); m.verify(row['derivation'])
(out/'plan.json').write_text(json.dumps(manifest, indent=2)+'\n')
print(json.dumps(dict(plan=m.pin(out/'plan.json'), targetExecuted=False)))

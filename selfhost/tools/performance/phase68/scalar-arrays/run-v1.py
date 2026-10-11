#!/usr/bin/env python3
"""Root-only execution of the frozen P68-016 four-arm plan, serial CPU3."""
import argparse
import importlib.util
import json
import os
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SUPPORT = ROOT/'selfhost/tools/performance/programs/support.py'
spec = importlib.util.spec_from_file_location('p68_array_support', SUPPORT)
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--plan', type=Path, required=True)
args = ap.parse_args()
plan_pin = S.identity(args.plan)
plan = json.loads(args.plan.read_text())
assert plan['kind'] == 'phase68-scalar-array-four-arm-plan-v1'
assert S.identity(__file__) == plan['runner']
pins = [plan_pin, plan['runner'], plan['producer'], plan['recipe'], plan['admissionMethod'],
    plan['derivationMethod'], *plan['actualInputs'], *plan['acquisitions']]
pins += [plan['parent'][key] for key in ['nativeSource', 'executable', 'emissionReceipt', 'source']]
for row in plan['records']:
    pins += [row['candidateSource'], row['derivation']]


def verify():
    for item in pins:
        assert S.identity(item['path']) == item
    assert {k: os.environ.get(k) for k in plan['compilerEnvironment']} == plan['compilerEnvironment']


verify()
assert len(plan['records']) == 3 and len(plan['smokes']) == 16 and len(plan['measurements']) == 12
spec = importlib.util.spec_from_file_location('p68_array_derivation', plan['derivationMethod']['path'])
D = importlib.util.module_from_spec(spec)
spec.loader.exec_module(D)
original = Path(plan['parent']['nativeSource']['path']).read_text()
for row in plan['records']:
    derivation = json.loads(Path(row['derivation']['path']).read_text())
    assert derivation['variant'] == row['role'] and derivation['parentEmission'] == plan['parent']['nativeSource']
    reconstructed = original
    for change in derivation['replacements']:
        reconstructed = D.edit(reconstructed, change['worker'], change['before'], change['after'], [], change['count'])
    assert reconstructed == Path(row['candidateSource']['path']).read_text()
report_path = args.plan.resolve().parent/'execution.json'
with report_path.open('x') as stream:
    stream.write('{}\n')
report = dict(kind='phase68-scalar-array-four-arm-execution-v1', complete=False,
    started=time.time(), plan=plan_pin, runner=S.identity(__file__), builds=[], smokes=[], measurements=[])


def save():
    report['finished'] = time.time()
    S.save(report_path, report)


def observe(row, directory):
    directory = Path(directory)
    row['stdout'] = (directory/'stdout.log').read_text() if (directory/'stdout.log').exists() else ''
    row['stderr'] = (directory/'stderr.log').read_text() if (directory/'stderr.log').exists() else ''
    words = row['stdout'].strip().splitlines()
    row['correct'] = (row['process']['complete'] and row['process']['returncode'] == 0 and
        not row['stderr'] and len(words) == 4 and all(x.isdecimal() for x in words) and
        list(map(int, words[:3])) == row['expected'])
    if row['correct']:
        row['elapsedMs'] = int(words[3])
    save()
    assert row['correct'], row


limits = plan['executionGuard']
executables = {'baseline': plan['parent']['executable']}
try:
    with S.ExecutionGuard(rss_mib=limits['rssMiB'], available_mib=limits['availableMiB']) as guard:
        for record in plan['records']:
            executable = Path(record['candidateExecutable'])
            assert not executable.exists()
            row = dict(role=record['role'], candidateSource=record['candidateSource'])
            report['builds'].append(row)
            row['process'] = guard.run(record['clangCommand'], record['clangReceiptDir'], time.monotonic()+limits['clangSeconds'])
            save()
            assert row['process']['complete'] and row['process']['returncode'] == 0
            row['executable'] = S.identity(executable)
            assert row['executable']['bytes'] <= 8*plan['parent']['executable']['bytes']
            pins.append(row['executable'])
            executables[record['role']] = row['executable']
        for planned in plan['smokes']:
            assert S.identity(executables[planned['role']]['path']) == executables[planned['role']]
            row = {key: planned[key] for key in ['role', 'threads', 'repetitions', 'warmups', 'expected']}
            report['smokes'].append(row)
            row['process'] = guard.run(planned['command'], planned['receiptDir'], time.monotonic()+limits['smokeSeconds'])
            observe(row, planned['receiptDir'])
        for planned in plan['measurements']:
            assert S.identity(executables[planned['role']]['path']) == executables[planned['role']]
            row = {key: planned[key] for key in ['role', 'round', 'repetitions', 'warmups', 'expected']}
            report['measurements'].append(row)
            row['process'] = guard.run(planned['command'], planned['receiptDir'], time.monotonic()+limits['runtimeSeconds'])
            observe(row, planned['receiptDir'])
            row['child'] = json.loads(Path(planned['childReceipt']).read_text())
            row['validClock'] = row['child']['returncode'] == 0 and 0 < row['elapsedMs'] <= row['child']['processSeconds']*1000+2
            row['timingQualified'] = row['validClock'] and row['elapsedMs'] >= 100
            save()
            print(json.dumps({key: row[key] for key in ['role', 'round', 'elapsedMs', 'timingQualified']}), flush=True)
    verify()
    report['complete'] = (len(report['builds']) == 3 and len(report['smokes']) == 16 and
        len(report['measurements']) == 12 and all(row['correct'] for row in report['smokes']+report['measurements']))
    report['allTimingQualified'] = all(row['timingQualified'] for row in report['measurements'])
    save()
except BaseException as error:
    report['error'] = repr(error)
    save()
    raise

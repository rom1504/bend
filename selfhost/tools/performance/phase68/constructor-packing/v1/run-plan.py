#!/usr/bin/env python3
"""Root-only execution of the frozen P68-011 saved-C discriminator."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
METHOD = ROOT / 'selfhost/tools/performance/phase68/benchmark/saved-native-v2.py'
spec = importlib.util.spec_from_file_location('p68_packing_method', METHOD)
M = importlib.util.module_from_spec(spec)
import hashlib
assert hashlib.sha256(METHOD.read_bytes()).hexdigest() == '83c586f20c37965a536c32d8c129a6cf481e66e634ab437a6b4a944016510cd2'
marker = '\nparser = argparse.ArgumentParser(description=__doc__)\n'
assert METHOD.read_text().count(marker) == 1
exec(compile(METHOD.read_text().split(marker)[0], str(METHOD), 'exec'), M.__dict__)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--plan', type=Path, required=True)
args = parser.parse_args()
plan_pin = M.pin(args.plan)
assert plan_pin['sha256'] == '040494be97849b2de736ec7f908d005982d44b4cb15d044d03e7bd0e98570cb6'
plan = M.read(args.plan)
output = args.plan.resolve().parent
pins = [plan_pin, M.pin(__file__), plan['producer'], plan['admissionMethod'],
        plan['recipe'], plan['plan'], *plan['actualInputs'], *plan['acquisitions']]
assert plan['resourcePolicy'] == dict(cpu=3, treeRssMiB=2048, availableMiB=4096, serial=True)


def check():
    admitted = M.admit(plan['recipe']['path'], plan['continuity']['attempt']['path'],
                       [p['path'] for p in plan['acquisitions']])
    recipe, _, continuity, inputs, _, products = admitted
    assert continuity == plan['continuity'] and inputs == plan['actualInputs']
    assert {k: os.environ.get(k) for k in recipe['compilerEnvironment']} == recipe['compilerEnvironment']
    for p in pins:
        M.verify(p)
    for c in plan['records']:
        assert c['parent'] == products[(c['case'], 'selfhost')]
        M.verify(c['diagnosticC'])
        source = Path(c['parent']['nativeSource']['path']).read_text()
        fragments, position = [], 0
        for change in c['changes']:
            start = source.index(change['before'], position)
            assert source.count('\n', 0, start) + 1 == change['line']
            fragments.extend([source[position:start], change['after']])
            position = start + len(change['before'])
        fragments.append(source[position:])
        assert ''.join(fragments) == Path(c['diagnosticC']['path']).read_text()


check()
report_path = output / 'execution.json'
with report_path.open('x') as f:
    f.write('{}\n')
report = dict(kind='phase68-guarded-packing-c-diagnostic-execution-v1', complete=False,
    started=time.time(), plan=plan_pin, runner=M.pin(__file__), cases=[], measurements=[],
    scope='Saved-C diagnostic; no checked compiler or foreign/raw ABI qualification.')
executables = {(c['case'], 'baseline'): c['parent']['executable'] for c in plan['records']}


def save():
    report['finished'] = time.time()
    M.S.save(report_path, report)


def observe(row, directory, expected):
    row['stdout'] = (directory / 'stdout.log').read_text() if (directory / 'stdout.log').exists() else ''
    row['stderr'] = (directory / 'stderr.log').read_text() if (directory / 'stderr.log').exists() else ''
    words = row['stdout'].strip().splitlines()
    row['correct'] = row['process']['complete'] and not row['stderr'] and len(words) == 4 and all(w.isdecimal() for w in words) and list(map(int, words[:3])) == expected
    if row['correct']:
        row['elapsedMs'] = int(words[3])
    save()
    assert row['correct'], row


save()
try:
    with M.S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
        for c in plan['records']:
            directory = output / c['case']
            binary = Path(c['buildCommand'][-1])
            assert binary == directory / 'program' and not binary.exists()
            row = dict(case=c['case'], diagnosticC=c['diagnosticC'])
            report['cases'].append(row)
            row['clang'] = guard.run(c['buildCommand'], directory / 'clang', time.monotonic() + 90)
            save()
            assert row['clang']['complete'], row['clang']
            row['executable'] = M.pin(binary)
            pins.append(row['executable'])
            executables[(c['case'], 'candidate')] = row['executable']
            smoke = directory / 'smoke'
            row['process'] = guard.run(['taskset', '-c', '3', str(binary), '--threads', '1', '--gpu', 'off', '--', '1', '0'], smoke, time.monotonic() + 45)
            observe(row, smoke, c['parent']['expected'])
            print(json.dumps(dict(case=c['case'], smokeCorrect=row['correct'], clangSeconds=row['clang']['wallSeconds'], binaryBytes=row['executable']['bytes'])), flush=True)
        for round_index in range(3):
            for c in plan['records']:
                roles = ['baseline', 'candidate'] if round_index % 2 == 0 else ['candidate', 'baseline']
                for role in roles:
                    artifact = M.verify(executables[(c['case'], role)])
                    directory = output / (c['case'] + '-' + role + '-r' + str(round_index))
                    child = directory / 'child.json'
                    command = ['taskset', '-c', '3', 'python3', str(M.OLD / 'execute.py'), str(child), artifact['path'], *c['runCommand'][4:]]
                    row = dict(case=c['case'], role=role, round=round_index, expected=c['expected'])
                    report['measurements'].append(row)
                    row['process'] = guard.run(command, directory, time.monotonic() + 45)
                    observe(row, directory, c['expected'])
                    row['child'] = M.read(child)
                    row['validClock'] = 0 < row['elapsedMs'] <= row['child']['processSeconds'] * 1000 + 2
                    row['timingQualified'] = row['validClock'] and row['elapsedMs'] >= 100
                    save()
                    print(json.dumps({k: row[k] for k in ['case', 'role', 'round', 'correct', 'elapsedMs', 'timingQualified']}), flush=True)
    check()
    report['complete'] = len(report['cases']) == 2 and len(report['measurements']) == 12 and all(r['correct'] for r in report['measurements'])
    report['allTimingQualified'] = all(r['timingQualified'] for r in report['measurements'])
    report['ratios'] = {c['case']: statistics.median(r['elapsedMs'] for r in report['measurements'] if r['case'] == c['case'] and r['role'] == 'candidate') / statistics.median(r['elapsedMs'] for r in report['measurements'] if r['case'] == c['case'] and r['role'] == 'baseline') for c in plan['records']}
    save()
except BaseException as error:
    report['error'] = repr(error)
    save()
    raise

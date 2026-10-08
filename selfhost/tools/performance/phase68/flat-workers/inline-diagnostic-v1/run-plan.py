#!/usr/bin/env python3
"""Root-only execution of the single frozen P68-008 diagnostic manifest."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
SUPPORT = ROOT / 'selfhost/tools/performance/programs/support.py'
spec = importlib.util.spec_from_file_location('phase68_inline_support', SUPPORT)
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--manifest', required=True, type=Path)
args = parser.parse_args()
manifest_id = S.identity(args.manifest)
assert manifest_id['sha256'] == '30d7a50865b0da4c11d6dfd03d6094e96cde323458dc23d768c8817f704a2e3c'
manifest = json.loads(args.manifest.read_text())
recipe = json.loads(Path(manifest['recipe']['path']).read_text())
pins = [manifest['producer'], manifest['recipe'], manifest['originalAcquisition'], manifest['plan'],
        manifest['clang'], *manifest['oracleInputs'], *recipe['inputs']]
for c in manifest['cases']:
    pins += [c[k] for k in ['originalSource', 'originalExecutable', 'originalEmissionReceipt', 'candidateSource', 'workerAudit']]


def check():
    for pin in pins:
        assert S.identity(pin['path']) == pin, pin['path']
    assert {k: os.environ.get(k) for k in manifest['compilerEnvironment']} == manifest['compilerEnvironment']


check()
report_path = args.manifest.resolve().parent / 'execution.json'
with report_path.open('x') as stream:
    stream.write('{}\n')
report = dict(kind='phase68-c-worker-inline-diagnostic-execution', complete=False, started=time.time(),
              manifest=manifest_id, runner=S.identity(__file__), support=S.identity(SUPPORT), cases=[], measurements=[])
pins += [manifest_id, report['runner'], report['support']]
executables = {(c['case'], 'baseline'): c['originalExecutable'] for c in manifest['cases']}


def save():
    report['finished'] = time.time()
    S.save(report_path, report)


def observe(row, directory, expected):
    directory = Path(directory)
    row['stdout'] = (directory / 'stdout.log').read_text() if (directory / 'stdout.log').exists() else ''
    row['stderr'] = (directory / 'stderr.log').read_text() if (directory / 'stderr.log').exists() else ''
    words = row['stdout'].strip().splitlines()
    row['correct'] = row['process']['complete'] and not row['stderr'] and len(words) == 4 and all(w.isdecimal() for w in words) and list(map(int, words[:3])) == expected
    if row['correct']:
        row['elapsedMs'] = int(words[3])
    save()
    assert row['correct'], row


save()
limits = manifest['executionGuard']
try:
    with S.ExecutionGuard(rss_mib=limits['rssMiB'], available_mib=limits['availableMiB']) as guard:
        for c in manifest['cases']:
            executable = Path(c['candidateExecutable'])
            assert not executable.exists(), executable
            before = Path(c['originalSource']['path']).read_text()
            after = Path(c['candidateSource']['path']).read_text()
            assert after.replace('INLINE __attribute__((always_inline)) Term NF_', 'INLINE Term NF_') == before
            row = dict(case=c['case'], expectedSmoke=c['expectedSmoke'], candidateSource=c['candidateSource'])
            report['cases'].append(row)
            row['clang'] = guard.run(c['clangCommand'], c['clangReceiptDir'], time.monotonic() + limits['clangSeconds'])
            save()
            assert row['clang']['complete'], row['clang']
            row['executable'] = S.identity(executable)
            row['binarySizeLimitBytes'] = c['binarySizeLimitBytes']
            save()
            assert row['executable']['bytes'] <= c['binarySizeLimitBytes'], row
            pins.append(row['executable'])
            executables[(c['case'], 'candidate')] = row['executable']
            row['process'] = guard.run(c['smokeCommand'], c['smokeReceiptDir'], time.monotonic() + limits['smokeSeconds'])
            observe(row, c['smokeReceiptDir'], c['expectedSmoke'])
            print(json.dumps({'case': c['case'], 'smokeCorrect': row['correct'], 'clangSeconds': row['clang']['wallSeconds'], 'binaryBytes': row['executable']['bytes']}), flush=True)
        for command in manifest['measurements']:
            pin = executables[(command['case'], command['role'])]
            assert S.identity(pin['path']) == pin, pin['path']
            row = {k: command[k] for k in ['case', 'role', 'round', 'expected']}
            report['measurements'].append(row)
            row['process'] = guard.run(command['command'], command['receiptDir'], time.monotonic() + limits['runtimeSeconds'])
            observe(row, command['receiptDir'], command['expected'])
            row['child'] = json.loads(Path(command['childReceipt']).read_text())
            row['validClock'] = 0 < row['elapsedMs'] <= row['child']['processSeconds'] * 1000 + 2
            row['timingQualified'] = row['validClock'] and row['elapsedMs'] >= 100
            save()
            print(json.dumps({k: row[k] for k in ['case', 'role', 'round', 'correct', 'elapsedMs', 'timingQualified']}), flush=True)
    check()
    report['complete'] = len(report['cases']) == 2 and len(report['measurements']) == 12 and all(r['correct'] for r in report['measurements'])
    save()
except BaseException as error:
    report['error'] = repr(error)
    save()
    raise

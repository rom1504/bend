#!/usr/bin/env python3
"""Bounded native product comparison; transport only, run under the disk guard."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline', type=Path, required=True)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--expected', type=Path)
p.add_argument('--rounds', type=int, choices=[1, 4], default=4)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = fresh_output(a.out, ROOT)
receipts = {k: json.loads(v.read_text()) for k, v in
            [('baseline', a.baseline), ('candidate', a.candidate)]}
inputs = [pin(__file__), pin(a.baseline), pin(a.candidate)]
for r in receipts.values():
    require(r['kind'] == 'bend-native-build' and r['complete'], 'Native build required')
    ir = r.get('sourceIR') or r.get('retainedIR')
    require(ir is not None, 'Authenticated retained IR required')
    if r.get('irDigest'):
        require({k: ir[k] for k in ['bytes','sha256']} == r['irDigest'], 'Retained IR differs from relay digest')
    inputs += [r['binary'], r['runtime'], ir]
require(receipts['baseline']['runtime'] == receipts['candidate']['runtime'], 'Runtime differs')
require(receipts['baseline']['toolchain'] == receipts['candidate']['toolchain'], 'Toolchain differs')
if a.expected:
    inputs += [pin(a.expected)]
for v in inputs:
    verify(v)
env = {k: v for k, v in os.environ.items()
       if not k.startswith('BEND_') and k not in ['BANGS', 'LD_PRELOAD', 'LD_AUDIT']}
report = dict(kind='phase173-native-product-pair', complete=False, inputs=inputs,
              runs=[], rounds=a.rounds,
              oracle='fixed expected bytes' if a.expected else 'baseline complete output; see source oracle manifest',
              scope='Whole process including setup/teardown; finite output check, not a proof or full compiler speed.')
expected = a.expected.read_bytes() if a.expected else None
def save(): write_json(out / 'report.json', report)
save()
try:
    for cycle in range(a.rounds):
        for role in (['baseline', 'candidate'] if cycle % 2 == 0 else ['candidate', 'baseline']):
            binary = receipts[role]['binary']; verify(binary)
            command = [binary['file'], '--threads', '1', '--gpu', 'off']
            start = time.perf_counter()
            r = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=15)
            seconds = time.perf_counter() - start
            so = out / f'{cycle}-{role}.stdout'; se = out / f'{cycle}-{role}.stderr'
            so.write_bytes(r.stdout); se.write_bytes(r.stderr)
            if expected is None:
                require(role == 'baseline', 'Reference must execute first')
                expected = r.stdout
            ok = r.returncode == 0 and not r.stderr and r.stdout == expected
            report['runs'].append(dict(role=role, cycle=cycle, command=command,
                seconds=seconds, exitCode=r.returncode, stdout=pin(so), stderr=pin(se), outputExact=ok))
            save(); require(ok, 'Native output mismatch: ' + role)
    report['medians'] = {k: statistics.median(x['seconds'] for x in report['runs'] if x['role'] == k)
                         for k in receipts}
    report['resolved'] = a.rounds == 4 and min(x['seconds'] for x in report['runs']) >= .03
    if report['resolved']:
        report['ratio'] = report['medians']['candidate'] / report['medians']['baseline']
    for v in inputs: verify(v)
    report['complete'] = True
except Exception as e:
    report['error'] = repr(e)
finally:
    save()
    print(json.dumps({k: v for k, v in report.items() if k in ['complete', 'resolved', 'medians', 'ratio', 'error']}))
if not report['complete']: raise SystemExit(1)

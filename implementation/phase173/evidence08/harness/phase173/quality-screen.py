#!/usr/bin/env python3
"""Run six pinned existing request/oracle comparisons; no compiler logic."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, verify, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
plan = json.loads(a.plan.read_text())
cases = plan['runtimeIdentityScreen']['cases']
assert len(cases) == 6
out = fresh_output(a.out, ROOT)
inputs = [pin(__file__), pin(a.plan), *plan['protectedInputs'],
          plan['runtimeIdentityScreen']['reference']]
for row in cases:
    inputs += [row['source'], row['expectedQbe']]
for item in inputs:
    verify(item)
r = dict(kind='phase173-six-timed-product-screen', complete=False,
         inputs=inputs, cases=[], scope='Six exact QBE comparisons, no runtime score.')
start = time.monotonic()
for i, row in enumerate(cases):
    command = list(row['command'])
    child = out / ('%02d-' % i + row['id'])
    command[command.index('--out') + 1] = str(child)
    with (out / ('%02d.log' % i)).open('wb') as log:
        run = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    report = child / 'report.json'
    result = json.loads(report.read_text()) if report.exists() else {}
    r['cases'].append(dict(id=row['id'], command=command, exitCode=run.returncode,
        exact=run.returncode == 0 and result.get('complete', False),
        report=pin(report) if report.exists() else None))
    write_json(out / 'report.json', r)
for item in inputs:
    verify(item)
r.update(complete=True, allExact=all(x['exact'] for x in r['cases']),
         wallSeconds=time.monotonic() - start)
write_json(out / 'report.json', r)
print(json.dumps({k:r[k] for k in ['complete','allExact','wallSeconds']}))

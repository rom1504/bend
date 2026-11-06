#!/usr/bin/env python3
"""Execute a frozen link-only observation inside one outer resource guard."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
a = p.parse_args()
plan = json.loads(a.plan.read_text())
require(plan['kind'] == 'phase171-guard-counter-plan' and plan['complete'], 'Frozen plan required')
inputs = [pin(__file__), pin(a.plan), *plan['inputs']]
for v in inputs: verify(v)
out = fresh_output(Path(plan['freshExecutionDirectory']), ROOT)
report = dict(kind='phase171-guard-counter-observation', complete=False,
              inputs=inputs, jobs=[], scope=plan['scope'])
env = {k: v for k, v in os.environ.items()
       if not k.startswith('BEND_') and k not in ['BANGS', 'LD_PRELOAD', 'LD_AUDIT']}
env.update(plan['executionEnvironment'])
def save(): write_json(out / 'report.json', report)
save()
try:
    for i, command in enumerate(plan['commands']):
        start = time.monotonic()
        r = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=15)
        so = out / f'{i}.stdout'; se = out / f'{i}.stderr'
        so.write_bytes(r.stdout); se.write_bytes(r.stderr)
        report['jobs'].append(dict(command=command, seconds=time.monotonic()-start,
                                   exitCode=r.returncode, stdout=pin(so), stderr=pin(se)))
        save(); require(r.returncode == 0 and not r.stderr, 'Diagnostic command failed')
        if i == len(plan['commands'])-1:
            require(r.stdout == Path(plan['expectedStdout']['file']).read_bytes(), 'Oracle mismatch')
    counts = json.loads((out / 'counts.json').read_text())
    require(counts['unrecorded'] == 0 and all(x['unexpected'] == 0 for x in counts['sites']), 'Incomplete counts')
    require(all(0 <= x['passed'] <= x['calls'] for x in counts['sites']), 'Invalid count range')
    report.update(counts=pin(out / 'counts.json'), binary=pin(out / 'program'), outputExact=True)
    for v in inputs: verify(v)
    report['complete'] = True
except Exception as e:
    report['error'] = repr(e)
finally:
    save(); print(json.dumps({k:v for k,v in report.items() if k in ['complete','counts','error']}))
if not report['complete']: raise SystemExit(1)

#!/usr/bin/env python3
"""Root-only serial request executor, using the existing single ExecutionGuard."""
import argparse
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('support', ROOT/'selfhost/tools/performance/programs/support.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--plan', type=Path, required=True)
ap.add_argument('--group', choices=['prepare','clean','profile'], required=True)
ap.add_argument('--only', help='Comma-separated exact job names within this group')
args = ap.parse_args()
plan_file = args.plan.resolve()
plan = json.loads(plan_file.read_text())
jobs = [j for j in plan['jobs'] if j['name'].startswith(args.group+'-')]
if args.only:
    names = set(args.only.split(','))
    jobs = [j for j in jobs if j['name'] in names]
    assert {j['name'] for j in jobs} == names
assert jobs
root = plan_file.parent/'runs'
root.mkdir(exist_ok=True)


def check():
    for p in plan['inputs']:
        actual = S.identity(p['file'])
        assert actual == dict(path=p['file'], sha256=p['sha256'], bytes=p['bytes']), p['file']


check()
with S.ExecutionGuard(rss_mib=plan['rssMiB'], available_mib=plan['availableMiB']) as guard:
    for job in jobs:
        out = root/job['name']
        assert not out.exists() and not out.with_name(out.name+'-guard').exists()
        command = ['taskset','-c',str(plan['cpu']),plan['roles'][job['role']]['node']['file'],
            *plan['nodeArgs'],str(HERE/'worker.mjs'),str(plan_file),job['name'],str(out)]
        result = guard.run(command, out.with_name(out.name+'-guard'), time.monotonic()+plan['seconds'])
        print(json.dumps(dict(job=job['name'], supervisor=result)), flush=True)
        assert result['complete'], 'Stopped at failed job; keep its output and use a fresh plan for retry'
        report = json.loads((out/'report.json').read_text())
        assert report['complete'] and report['pass'] and report['inputsUnchanged']
check()

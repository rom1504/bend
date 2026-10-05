#!/usr/bin/env python3
"""Bounded serial CPU/allocation survey using the unchanged maintained profiler."""
import argparse
import hashlib
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
SUPPORT = ROOT / 'selfhost/tools/performance/programs/support.py'
DRIVER = ROOT / 'selfhost/tools/performance/programs/profile.mjs'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
spec = importlib.util.spec_from_file_location('support', SUPPORT)
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)


def identity(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--jobs', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
jobs = json.loads(a.jobs.read_text())
assert 0 < len(jobs) <= 50
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=False)
inputs = [identity(x) for x in [__file__, SUPPORT, DRIVER, NODE, a.jobs]]
report = dict(kind='phase50-profile-queue', complete=False, started=time.time(),
              inputs=inputs, jobs=[], diagnosticOnly=True)


def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')


launch = 'import os,resource,sys;resource.setrlimit(resource.RLIMIT_FSIZE,(67108864,67108864));os.chdir(sys.argv[1]);os.execv(sys.argv[2],sys.argv[2:])'
save()
with support.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
    for job in jobs:
        module = identity(job['module']['file'])
        assert module == job['module']
        config = identity(job['config'])
        inputs.extend([module, config])
        home = out / job['label']
        home.mkdir()
        command = ['taskset', '-c', '3', sys.executable, '-c', launch, str(home), str(NODE),
                   '--stack-size=4096', '--max-old-space-size=1024', str(DRIVER),
                   module['file'], config['file'], str(home / 'profile-report.json'),
                   str(home / 'profile.json')]
        result = guard.run(command, home / 'process', time.monotonic() + 30)
        leaf = home / 'profile-report.json'
        passed = leaf.exists() and json.loads(leaf.read_text()).get('pass', False)
        report['jobs'].append(dict(label=job['label'], process=result, passed=passed,
                                   report=identity(leaf) if leaf.exists() else None))
        save()
        print(json.dumps(dict(label=job['label'], passed=passed, wallSeconds=result['wallSeconds'])), flush=True)
        if not result['complete'] or not passed:
            break
report.update(finished=time.time(), complete=len(report['jobs']) == len(jobs)
              and all(j['passed'] and j['process']['complete'] for j in report['jobs']))
report['inputStabilityVerified'] = all(identity(r['file']) == r for r in inputs)
report['complete'] &= report['inputStabilityVerified']
save()
raise SystemExit(0 if report['complete'] else 1)

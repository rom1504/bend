#!/usr/bin/env python3
"""Serial bounded diagnostics over frozen configs; never builds a compiler."""
import argparse
import hashlib
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SUPPORT = HERE.parent / 'programs/support.py'
spec = importlib.util.spec_from_file_location('support', SUPPORT)
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--jobs', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--seconds', type=float, default=45)
a = p.parse_args()
jobs = json.loads(a.jobs.read_text())
assert isinstance(jobs, list) and 0 < len(jobs) <= 30
assert 0 < a.seconds <= 120
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=False)
node = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
driver = HERE / 'v8-probe.mjs'
def ident(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
inputs = [ident(x) for x in [__file__, SUPPORT, driver, a.jobs]]
# Per-file output limit inherited by Node. A truncated dump makes the job fail.
launch = 'import os,resource,sys;resource.setrlimit(resource.RLIMIT_FSIZE,(67108864,67108864));os.chdir(sys.argv[1]);os.execv(sys.argv[2],sys.argv[2:])'
report = dict(kind='phase49-probe-queue', complete=False, inputs=inputs,
              started=time.time(), jobs=[], outputLimitBytesPerFile=67108864,
              scope='Diagnostic-only unless driver mode is clean; no mixed/profiled speed ratios.')
def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
save()
with support.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
    for i, job in enumerate(jobs):
        config = Path(job['config']).resolve(strict=True)
        inputs.append(ident(config))
        selected_driver = Path(job.get('driver', str(driver))).resolve(strict=True)
        inputs.append(ident(selected_driver))
        home = out / ('%02d-' % i + job['label'])
        home.mkdir()
        flags = [str(x).replace('{dump}', str(home / 'dumps')) for x in job.get('flags', [])]
        (home / 'dumps').mkdir()
        command = ['taskset', '-c', '3', sys.executable, '-c', launch, str(home), node,
                   '--stack-size=4096', '--max-old-space-size=1024', *flags,
                   str(selected_driver), str(config), str(home / 'probe')]
        result = guard.run(command, home / 'process', time.monotonic() + a.seconds)
        row = dict(label=job['label'], config=ident(config), flags=flags, process=result)
        probe = home / 'probe/report.json'
        if probe.exists():
            row['report'] = ident(probe)
        report['jobs'].append(row)
        save()
        print(json.dumps(dict(label=job['label'], complete=result['complete'], wallSeconds=result['wallSeconds'])), flush=True)
        if not result['complete']:
            break
report.update(finished=time.time(), complete=len(report['jobs']) == len(jobs)
              and all(x['process']['complete'] for x in report['jobs']))
report['inputStabilityVerified'] = all(ident(x['file']) == x for x in inputs)
report['complete'] = report['complete'] and report['inputStabilityVerified']
save()
raise SystemExit(0 if report['complete'] else 1)

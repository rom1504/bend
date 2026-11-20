#!/usr/bin/env python3
"""Two predeclared arithmetic projections, no target or compiler execution."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path)
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    begin = time.monotonic()
    frozen = HERE/'evidence/prospective-frozen'
    freeze = json.loads((frozen/'freeze.json').read_text())
    evidence = json.loads((frozen/'constant-remainder-evidence.json').read_text())
    acquisition_path = ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json'
    acquisition = json.loads(acquisition_path.read_text())
    verified = []
    for row in [*freeze['pins'], acquisition['tool'], *acquisition['libraries']]:
        actual = pin(row['file'])
        assert actual['sha256'] == row['sha256'] and actual['bytes'] == row['bytes'], row
        verified.append(actual)
    for row in evidence['inputs']:
        actual = pin(ROOT/row['path'])
        assert actual['sha256'] == row['sha256'], row
        verified.append(actual)
    report = dict(kind='phase195-remainder26-prospective-model-v1', targetsRun=False,
                  compilerRun=False, freeze=freeze, freezePin=pin(frozen/'freeze.json'),
                  acquisition=pin(acquisition_path), tool=acquisition['tool'],
                  runner=pin(__file__), verifiedInputs=verified,
                  hostAffinity=sorted(os.sched_getaffinity(0)), runs=[])
    for role, expected in [('before', 500), ('after', 700)]:
        argv = [acquisition['tool']['file'], '-mtriple=x86_64-unknown-linux-gnu',
                '-mcpu=ivybridge', '-iterations=100', '-noalias=true',
                str(frozen/('remainder26-'+role+'.s'))]
        start = time.monotonic()
        usage = resource.getrusage(resource.RUSAGE_CHILDREN)
        try:
            result = subprocess.run(argv, capture_output=True, timeout=2)
            stdout, stderr, code, timedout = result.stdout, result.stderr, result.returncode, False
        except subprocess.TimeoutExpired as error:
            stdout, stderr, code, timedout = error.stdout or b'', error.stderr or b'', None, True
        endusage = resource.getrusage(resource.RUSAGE_CHILDREN)
        row = dict(role=role, argv=argv, wallSeconds=time.monotonic()-start, exitCode=code,
                   timedOut=timedout, expectedInstructions=expected, metrics={},
                   cpuSeconds=endusage.ru_utime+endusage.ru_stime-usage.ru_utime-usage.ru_stime)
        for key, data in [('stdout', stdout), ('stderr', stderr)]:
            path = args.out/(role+'.'+key)
            path.write_bytes(data)
            row[key] = pin(path)
        for label, key in [('Iterations', 'iterations'), ('Instructions', 'instructions'),
                           ('Total Cycles', 'totalCycles'), ('Total uOps', 'totalUops'),
                           ('Block RThroughput', 'blockReciprocalThroughput')]:
            match = re.search(r'^'+re.escape(label)+r':\s*([0-9.]+)', stdout.decode(), re.M)
            if match:
                row['metrics'][key] = float(match[1])
        report['runs'].append(row)
    report['complete'] = all(row['exitCode'] == 0 and row['stderr']['bytes'] == 0
                             and len(row['metrics']) == 5
                             and row['metrics']['instructions'] == row['expectedInstructions']
                             for row in report['runs'])
    report['wallSeconds'] = time.monotonic()-begin
    report['modelProcessWallSeconds'] = sum(row['wallSeconds'] for row in report['runs'])
    report['modelProcessCpuSeconds'] = sum(row['cpuSeconds'] for row in report['runs'])
    (args.out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ('complete', 'wallSeconds', 'modelProcessWallSeconds', 'modelProcessCpuSeconds')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

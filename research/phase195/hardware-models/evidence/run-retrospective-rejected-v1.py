#!/usr/bin/env python3
"""Frozen four-pair backend retrospective; never executes target binaries."""
import argparse
import hashlib
import json
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
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(row):
    actual = pin(row['file'])
    assert all(actual[k] == row[k] for k in ('bytes', 'sha256')), row['file']
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    started = time.monotonic()
    manifest_path = HERE/'pairs-v1.json'
    manifest = json.loads(manifest_path.read_text())
    acquisition_path = ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json'
    acquisition = json.loads(acquisition_path.read_text())
    verified = [verify(acquisition['tool'])]
    verified += [verify(row) for row in acquisition['libraries']]
    verified += [verify(row) for row in manifest['inputs']]
    for pair in manifest['pairs']:
        for role in pair['roles'].values():
            verified += [verify(role[key]) for key in ('binary', 'assembly', 'disassembly')]
        verified += [verify(pair[key]) for key in ('runtimeReceipt', 'machineReceipt', 'summaryReceipt') if key in pair]
    report = dict(kind='phase195-llvm-mca-retrospective-v1', targetsRun=False,
                  cpu='ivybridge', iterations=100, hostAffinity=sorted(__import__('os').sched_getaffinity(0)),
                  inputManifest=pin(manifest_path), runner=pin(__file__),
                  acquisition=acquisition, acquisitionManifest=pin(acquisition_path), verifiedInputs=verified,
                  nonblind=True, profileWeighted=False, runs=[])
    jobs = [(pair, role, True) for pair in manifest['pairs'] for role in ('before', 'after')]
    many = next(pair for pair in manifest['pairs'] if pair['id'] == 'p194-register-pressure-many')
    jobs += [(many, role, False) for role in ('before', 'after')]
    for pair, role, noalias in jobs:
        name = pair['id']+'-'+role+('-noalias' if noalias else '-mayalias')
        argv = [acquisition['tool']['file'], '-mtriple=x86_64-unknown-linux-gnu',
                '-mcpu=ivybridge', '-iterations=100', '-noalias='+str(noalias).lower(),
                pair['roles'][role]['assembly']['file']]
        before = resource.getrusage(resource.RUSAGE_CHILDREN)
        begin = time.monotonic()
        try:
            process = subprocess.run(argv, capture_output=True, timeout=2)
            stdout, stderr, code, timedout = process.stdout, process.stderr, process.returncode, False
        except subprocess.TimeoutExpired as error:
            stdout, stderr, code, timedout = error.stdout or b'', error.stderr or b'', None, True
        after = resource.getrusage(resource.RUSAGE_CHILDREN)
        row = dict(pair=pair['id'], role=role, noalias=noalias, argv=argv, exitCode=code,
                   timedOut=timedout, wallSeconds=time.monotonic()-begin,
                   cpuSeconds=after.ru_utime+after.ru_stime-before.ru_utime-before.ru_stime,
                   cumulativeChildPeakRssKiB=after.ru_maxrss, metrics={})
        for key, data in [('stdout', stdout), ('stderr', stderr)]:
            file = args.out/(name+'.'+key)
            file.write_bytes(data)
            row[key] = pin(file)
        for label, key in [('Iterations', 'iterations'), ('Instructions', 'instructions'),
                           ('Total Cycles', 'totalCycles'), ('Total uOps', 'totalUops'),
                           ('Block RThroughput', 'blockReciprocalThroughput')]:
            match = re.search(r'^'+re.escape(label)+r':\s*([0-9.]+)', stdout.decode(), re.M)
            if match:
                row['metrics'][key] = float(match[1])
        report['runs'].append(row)
        (args.out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    report['wallSeconds'] = time.monotonic()-started
    report['modelProcessWallSeconds'] = sum(row['wallSeconds'] for row in report['runs'])
    report['modelProcessCpuSeconds'] = sum(row['cpuSeconds'] for row in report['runs'])
    report['complete'] = all(row['exitCode'] == 0 and len(row['metrics']) == 5 for row in report['runs'])
    (args.out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ('complete', 'wallSeconds', 'modelProcessWallSeconds', 'modelProcessCpuSeconds')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

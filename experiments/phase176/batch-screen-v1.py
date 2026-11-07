#!/usr/bin/env python3
"""Bounded independent software jobs. Run inside ONE aggregate disk guard.

No compiler semantics or cache: exact command arrays, input identities, per-job
timeouts and receipts. Parallel runs are screening, never isolated timing claims.
"""
import argparse
import json
import os
from pathlib import Path
import re
import sys
import signal
import subprocess
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json, timeout


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--cpus', required=True, help='One distinct CPU per worker; e.g. 3 or 3,5')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    cpus = [int(x) for x in a.cpus.split(',')]
    require(1 <= len(cpus) <= 4 and len(set(cpus)) == len(cpus), 'One to four distinct CPUs required')
    require(set(cpus) <= os.sched_getaffinity(0), 'CPUs outside outer guard affinity')
    manifest = json.loads(a.manifest.read_text())
    require(manifest['kind'] == 'phase176-independent-jobs' and manifest['version'] == 1, 'Wrong manifest')
    jobs = manifest['jobs']
    require(0 < len(jobs) <= 64, 'One to 64 bounded jobs required')
    names = [j['id'] for j in jobs]
    require(len(set(names)) == len(names) and all(re.fullmatch('[a-z0-9-]+', n) for n in names), 'Unique simple names required')
    for job in jobs:
        require(job['command'] and all(isinstance(x,str) for x in job['command']), 'Command argument array required')
        timeout(job['seconds'])
    inputs = [pin(__file__), pin(ROOT/'selfhost/tools/build/common.py'), pin(a.manifest), *manifest['inputs']]
    for item in inputs:
        verify(item)
    out = fresh_output(a.out, ROOT)
    env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ('LD_PRELOAD','LD_AUDIT','NODE_OPTIONS','NODE_PATH')}
    report = dict(kind='phase176-software-batch', complete=False, inputs=inputs,
                  cpus=cpus, started=time.time(), jobs=[],
                  scope='One aggregate outer guard required. Concurrent individual timings are screening only; no promotion or correctness theorem.')
    write_json(out/'report.json', report)
    begin = time.monotonic()

    # Spawn in the main OS thread: the existing guard discovers children through
    # /proc/PID/task/PID/children. Thread-pool forks would evade that traversal.
    pending = iter(jobs)
    active = {}
    free = list(cpus)
    try:
        while True:
            while free:
                job = next(pending, None)
                if job is None:
                    break
                cpu = free.pop(0)
                folder = out/job['id']
                folder.mkdir()
                command = ['taskset','-c',str(cpu), *[x.replace('{out}', str(folder/'result')) for x in job['command']]]
                row = dict(id=job['id'],cpu=cpu,command=command,complete=False,started=time.time(),limitSeconds=job['seconds'])
                with (folder/'stdout').open('xb') as so, (folder/'stderr').open('xb') as se:
                    child = subprocess.Popen(command,cwd=ROOT,env=env,stdout=so,stderr=se,start_new_session=True)
                active[child.pid] = (child,job,folder,row,time.monotonic())
            if not active:
                break
            for pid,(child,job,folder,row,begun) in list(active.items()):
                if time.monotonic()-begun >= job['seconds'] and not row.get('timedOut'):
                    row['timedOut'] = True
                    try:
                        os.killpg(pid,signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                done,status,usage = os.wait4(pid,os.WNOHANG)
                if not done:
                    continue
                child.returncode = os.waitstatus_to_exitcode(status)
                # Kill any process still in this job's session before releasing
                # its lane, including children left by an exited launcher.
                try:
                    os.killpg(pid,signal.SIGKILL)
                except ProcessLookupError:
                    pass
                row.update(exitCode=child.returncode,seconds=time.monotonic()-begun,
                           userSeconds=usage.ru_utime,systemSeconds=usage.ru_stime,
                           peakRssKiB=usage.ru_maxrss,stdout=pin(folder/'stdout'),stderr=pin(folder/'stderr'))
                row['complete'] = child.returncode == 0 and not row.get('timedOut',False)
                result = folder/'result/report.json'
                if job.get('resultReport',True):
                    try:
                        row['payloadComplete'] = result.is_file() and json.loads(result.read_text()).get('complete') is True
                        if result.is_file():
                            row['result'] = pin(result)
                    except Exception as error:
                        row.update(payloadComplete=False,error=repr(error))
                    row['complete'] = row['complete'] and row['payloadComplete']
                write_json(folder/'process.json',row)
                report['jobs'].append(row)
                write_json(out/'report.json',report)
                del active[pid]
                free.append(row['cpu'])
            if active:
                time.sleep(.02)
    finally:
        for pid,(child,*_) in active.items():
            try:
                os.killpg(pid,signal.SIGKILL)
            except ProcessLookupError:
                pass
            child.wait()
    report.update(seconds=time.monotonic()-begin, finished=time.time(),
                  childCpuSeconds=sum(r.get('userSeconds',0)+r.get('systemSeconds',0) for r in report['jobs']),
                  failedJobs=[r['id'] for r in report['jobs'] if not r['complete']])
    try:
        for item in inputs:
            verify(item)
        report['complete'] = not report['failedJobs']
    except Exception as error:
        report['error'] = repr(error)
    write_json(out/'report.json', report)
    print(json.dumps({k:report[k] for k in ['complete','seconds','childCpuSeconds','failedJobs']}), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

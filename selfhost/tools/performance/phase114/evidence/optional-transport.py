#!/usr/bin/env python3
"""Record an optional transport attempt without weakening native qualification."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
SUPPORT = ROOT/'selfhost/tools/performance/programs/support.py'


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    if sorted(os.sched_getaffinity(0)) != [3] or out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase114'):
        raise ValueError('Root CPU3 guard and fresh Phase114 attempt directory required')
    plan = json.loads(a.plan.read_text())
    if plan.get('kind') != 'phase114-optional-native-transport': raise ValueError('Explicit optional transport plan required')
    out.mkdir(parents=True)
    report = dict(kind='phase114-optional-native-transport-attempt', complete=False, wrapperComplete=False,
        measurementPassed=False, started=time.time(), inputs=[pin(a.plan), pin(__file__)], jobs=[],
        scope='Optional compiler-request screen only. Wrapper exit0 means its outcome was recorded; only measurementPassed authenticates success. A transport failure does not satisfy or alter any native qualification gate.')
    def save(): (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    try:
        for row in plan['inputs']:
            if pin(row['file']) != row: raise ValueError('Changed optional transport input: '+row['file'])
        spec = importlib.util.spec_from_file_location('transport_cleanup_support', SUPPORT)
        support = importlib.util.module_from_spec(spec); spec.loader.exec_module(support)
        for index, job in enumerate(plan['jobs']):
            row = dict(name=job['name'], command=job['command'], limitSeconds=job['seconds'])
            report['jobs'].append(row); save(); start = time.monotonic()
            so, se = out/(str(index)+'.stdout'), out/(str(index)+'.stderr')
            with so.open('xb') as sout, se.open('xb') as serr:
                child = subprocess.Popen(job['command'], cwd=ROOT, stdout=sout, stderr=serr, start_new_session=True)
                try:
                    child.wait(timeout=job['seconds'])
                except BaseException:
                    # The unchanged runner gives compiler children separate
                    # sessions. Reuse the existing guard's tree cleanup rather
                    # than killing only the Python supervisor's process group.
                    if child.poll() is None:
                        cleanup = support.ExecutionGuard()
                        cleanup.active = child
                        cleanup._tree(child.pid)
                        cleanup._stop()
                    child.wait(); raise
                finally:
                    row.update(seconds=time.monotonic()-start, exitCode=child.returncode, stdout=pin(so), stderr=pin(se)); save()
            if child.returncode: raise RuntimeError('Optional transport job failed: '+job['name'])
        result = json.loads(Path(plan['measurementReport']).read_text())
        if not result.get('complete') or not result.get('passed'): raise ValueError('Complete passed transport report required')
        for row in plan['inputs']:
            if pin(row['file']) != row: raise ValueError('Changed optional transport input after execution')
        report.update(complete=True, measurementPassed=True, measurementReport=pin(plan['measurementReport']))
    except Exception as error:
        report['error'] = repr(error)
        if Path(plan['measurementReport']).exists(): report['measurementReport'] = pin(plan['measurementReport'])
    finally:
        report.update(wrapperComplete=True, finished=time.time()); save()
    print(json.dumps(dict(wrapperComplete=True, measurementPassed=report['measurementPassed'], report=pin(out/'report.json'))))


if __name__ == '__main__': main()

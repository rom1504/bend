#!/usr/bin/env python3
"""Root-run serial acquisition of frozen Phase111 batch products; no timings claim."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('phase112_benchmark', HERE / 'run.py')
method = importlib.util.module_from_spec(spec)
spec.loader.exec_module(method)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3]:
        raise ValueError('Root must bind this supervisor to CPU3 under its outer guard')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Fresh Phase112 output required')
    commands_file = HERE / 'acquire-phase11101.json'
    commands = method.read(commands_file)
    method.verify(commands['manifest'])
    manifest = method.read(commands['manifest']['file'])
    inputs = [method.pin(__file__), method.pin(HERE / 'run.py'), method.pin(commands_file),
              commands['manifest'], method.pin(sys.executable), *manifest['inputs'],
              method.pin(ROOT / 'selfhost/tools/performance/phase111/native-emit.py'),
              method.pin(ROOT / 'selfhost/tools/performance/phase111/build.py')]
    for item in inputs:
        method.verify(item)
    out.mkdir(parents=True)
    report = dict(kind='phase112-baseline-batch-acquisition', complete=False, inputs=inputs,
                  jobs=[], started=time.time(), scope='Compiler requests and builds only; excluded from program runtime ratios.')
    save = lambda: method.save(out / 'report.json', report)
    save()
    try:
        for index, planned in enumerate(commands['jobs']):
            command = [sys.executable, *planned['command'][1:]]
            job = dict(name=planned['name'], command=command)
            report['jobs'].append(job)
            save()
            print(json.dumps(dict(acquiring=job['name'])), flush=True)
            start = time.monotonic()
            stdout, stderr = out / (str(index) + '.stdout'), out / (str(index) + '.stderr')
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se)
            job.update(seconds=time.monotonic() - start, exitCode=child.returncode,
                       stdout=method.pin(stdout), stderr=method.pin(stderr))
            receipt = Path(command[command.index('--out') + 1]) / 'report.json'
            if receipt.exists():
                job['emission'] = method.pin(receipt)
            save()
            if child.returncode or not receipt.exists() or not method.read(receipt).get('complete'):
                raise RuntimeError('Failed batch acquisition: ' + job['name'])
        for item in inputs:
            method.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['finished'] = time.time()
        save()
    print(json.dumps(dict(complete=report['complete'], jobs=len(report['jobs']))), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

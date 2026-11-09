#!/usr/bin/env python3
"""Dispatch one prepared profiler job list serially inside an external guard."""
import argparse
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import changed_inputs, clean_environment, fresh_output, pin, require, run, write_json


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--jobs', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=float, default=150)
    p.add_argument('--cpu', type=int, default=3)
    p.add_argument('--guarded', action='store_true')
    a = p.parse_args()
    require(a.guarded and os.sched_getaffinity(0) == {a.cpu}, 'One external guarded CPU lane required')
    require(0 < a.seconds <= 180, 'Whole diagnostic deadline must be at most180 seconds')
    clean_environment()
    require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    started = time.monotonic()
    prepared = a.jobs.resolve().parent
    jobs = json.loads(a.jobs.read_text())
    require(jobs.get('targetsRun') is False and 0 < len(jobs['jobs']) <= 100, 'Prepared bounded job list required')
    out = fresh_output(a.out, ROOT)
    inputs = [pin(a.jobs), pin(__file__), pin(ROOT / 'selfhost/tools/build/common.py')]
    report = dict(kind='phase185-native-profile-jobs', complete=False, inputs=inputs, jobs=[],
        secondsLimit=a.seconds, cpu=a.cpu,
        scope='Serial prepared diagnostic jobs and offline attribution; operational completion is not quantitative admission.')

    def save():
        report['wallSeconds'] = time.monotonic() - started
        write_json(out / 'report.json', report)

    def invoke(name, command):
        remaining = a.seconds - (time.monotonic() - started)
        require(remaining > 0, 'Whole profile deadline exhausted')
        require(isinstance(command, list) and all(isinstance(v, str) for v in command), 'Explicit argv required')
        index = len(report['jobs'])
        row = dict(name=name, command=command)
        report['jobs'].append(row)
        save()
        row['process'] = run(command, cwd=ROOT, stdout=out / (str(index) + '.stdout'),
                             stderr=out / (str(index) + '.stderr'), seconds=remaining)
        save()
        require(row['process']['complete'], 'Profile job failed: ' + name)

    save()
    try:
        for job in jobs['jobs']:
            invoke(job['name'], job['command'])
        capture = json.loads((prepared / 'capture/report.json').read_text())
        require(capture['complete'] and capture['passed'] and not capture.get('changedInputs'), 'Incomplete capture')
        for index, row in enumerate(capture['rows']):
            owner = jobs.get('ownerMaps', {}).get(row['workload'], {}).get(row['variant'])
            if row['mode'] != 'sample' or not owner:
                continue
            command = [sys.executable, '-B', str(ROOT / 'selfhost/tools/profiler/attribute.py'),
                       '--analysis', row['analysis']['file'], '--owners', owner, '--summary-only',
                       '--out', str(prepared / ('attribution-' + str(index)))]
            if row.get('contexts'):
                command += ['--contexts', row['contexts']['file']]
            invoke('attribute-' + str(index), command)
        comparison = json.loads((prepared / 'comparison.json').read_text())
        report['pooledQuality'] = {name: {role: value['profile']['adequate'] for role, value in variants.items()}
                                   for name, variants in comparison['workloads'].items()}
        report['capture'] = pin(prepared / 'capture/report.json')
        report['comparison'] = pin(prepared / 'comparison.json')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({k: report.get(k) for k in ('complete', 'wallSeconds', 'pooledQuality', 'error')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())

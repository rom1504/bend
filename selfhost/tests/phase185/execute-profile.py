#!/usr/bin/env python3
"""Run a sample-only QBE/C baseline screen inside one external CPU3 guard."""
import argparse
import importlib.util
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p185_profile_plan', HERE / 'profile-plan.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
B, L, ROOT = P.B, P.L, P.ROOT
from common import run, changed_inputs, clean_environment


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, default=ROOT / 'selfhost/build/phase184/bend-products01/programs.manifest.json')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=165)
    parser.add_argument('--cpu', type=int, default=3)
    parser.add_argument('--guarded', action='store_true')
    a = parser.parse_args()
    B.require(a.guarded and L.os.sched_getaffinity(0) == {a.cpu}, 'One outer guarded lane required')
    B.require(0 < a.seconds <= 180, 'Whole diagnostic deadline must not exceed180 seconds')
    clean_environment()
    B.require('BENDRTS' not in L.os.environ, 'Unset ambient BENDRTS')
    out = L.fresh_output(a.out, ROOT)
    started = time.monotonic()
    inputs = [B.pin(a.manifest), *[B.pin(HERE / n) for n in ('execute-profile.py', 'profile-plan.py', 'runtime-loop.py')]]
    report = dict(kind='phase185-baseline-cpu-screen', complete=False, inputs=inputs, jobs=[],
        secondsLimit=a.seconds, cpu=a.cpu, profiles=[],
        scope='Sample-only unchanged QBE and C binaries; no clean timing ratios or runtime hooks.',
        ownerProvenance='Conditional lexical QBE grouping plus linked FID authentication. Current edited emitters are unbound.')

    def save():
        report['wallSeconds'] = time.monotonic() - started
        B.save(out / 'report.json', report)

    def invoke(name, command):
        remaining = a.seconds - (time.monotonic() - started)
        B.require(remaining > 0, 'Whole profile deadline exhausted')
        index = len(report['jobs'])
        row = dict(name=name, command=command)
        report['jobs'].append(row)
        save()
        row['process'] = run(command, cwd=ROOT, stdout=out / (str(index) + '.stdout'),
                             stderr=out / (str(index) + '.stderr'), seconds=remaining)
        save()
        B.require(row['process']['complete'], 'Profile job failed: ' + name)

    save()
    try:
        for role, sampler, counts in [
            ('bend-qbe', 'selfhost/build/phase183/profile-controls01/sampler/sampler.so', [5000, 7000, 128]),
            ('bend-c', 'selfhost/build/phase159/thread-sampler01/sampler.so', [18000, 24000, 144])]:
            prepared = out / role
            P.prepare(argparse.Namespace(manifest=a.manifest, role=role, instrument=False,
                sampler=ROOT / sampler, case=list(zip(['coverage-map-churn-128', 'tree-bitonic', 'raytrace'], map(str, counts))),
                out=prepared, periods_us='8000,13000', modes='sample', runtime_report=None))
            jobs = B.read(prepared / 'jobs.json')
            for job in jobs['jobs']:
                invoke(role + '-' + job['name'], job['command'])
            capture = B.read(prepared / 'capture/report.json')
            B.require(capture['complete'] and capture['passed'] and not capture.get('changedInputs'), 'Incomplete capture')
            for index, row in enumerate(capture['rows']):
                owner = jobs['ownerMaps'][row['workload']].get(row['variant'])
                if owner:
                    invoke(role + '-attribute-' + str(index), [sys.executable, '-B', str(P.PROF / 'attribute.py'),
                        '--analysis', row['analysis']['file'], '--owners', owner, '--summary-only',
                        '--out', str(prepared / ('attribution-' + str(index)))])
            report['profiles'].append(dict(role=role, capture=B.pin(prepared / 'capture/report.json'),
                comparison=B.pin(prepared / 'comparison.json'), summary=B.pin(prepared / 'summary.md')))
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(__import__('json').dumps({k: report[k] for k in ('complete', 'wallSeconds', 'profiles')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())

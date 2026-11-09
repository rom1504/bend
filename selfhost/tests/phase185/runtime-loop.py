#!/usr/bin/env python3
"""Small native45 role merger and adaptive runtime screen; never compiles products.

The maintained bench module owns manifests, runtime arguments, subprocess cleanup,
complete-output validation and summaries. Calibration follows Phase184 without
changing its frozen three-role tool. All execution requires one outer guard.
"""
import argparse
import json
import math
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/bench'))
import bench as B
from common import clean_environment, changed_inputs, fresh_output

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
MAX_COUNT = 2**31 - 1


def load(path):
    document = B.read(path)
    B.require(document.get('schema') == 'bend-benchmark-manifest-v1'
              and document.get('kind') == 'programs', 'Maintained program manifest required')
    for item in document['inputs']:
        B.verify(item)
    B.require(all(r['target'] in ('c', 'qbe', 'x86') for r in document['roles'].values()),
              'Native prepared products only')
    catalog = {c['id']: c for c in B.catalog(CATALOG)['cases']}
    for case in document['cases']:
        original = catalog[case['id']]
        B.require(all(case[k] == original[k] for k in
                      ('point', 'family', 'sourceGroup', 'source', 'expectedFile')),
                  'Case differs from native45: ' + case['id'])
    return document


def merge(a):
    names = a.cases.split(',')
    B.require(names and len(names) == len(set(names)), 'Unique explicit case IDs required')
    roles, products = {}, {name: {} for name in names}
    for alias, filename, source_role in a.role:
        document = load(filename)
        B.require(alias not in roles and source_role in document['roles'], 'Unknown or duplicate role')
        role = dict(document['roles'][source_role])
        role['inputs'] = [*role.get('inputs', []), B.pin(filename), B.pin(__file__)]
        roles[alias] = role
        cases = {case['id']: case for case in document['cases']}
        for name in names:
            B.require(name in cases, 'Selected case missing from role ' + alias + ': ' + name)
            products[name][alias] = cases[name]['products'][source_role]
    B.require(a.reference in roles and len(roles) >= 2, 'At least two roles including reference required')
    out = fresh_output(a.out, ROOT)
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(CATALOG), reference=a.reference,
                  roles=roles, cases=[dict(id=name, products=products[name]) for name in names])
    B.save(out / 'recipe.json', recipe, fresh=True)
    B.freeze(out / 'recipe.json', out / 'manifest.json')
    return dict(targetsRun=False, manifest=str(out / 'manifest.json'), roles=list(roles), cases=names)


def next_count(count, elapsed, target):
    if elapsed > 2 * target and count > 1:
        return max(1, math.ceil(count * target / elapsed))
    return min(MAX_COUNT, max(count + 1, count * 10 if elapsed == 0 else math.ceil(count * target / elapsed)))


def run(a):
    start = time.monotonic()
    B.require(a.guarded and os.sched_getaffinity(0) == {a.cpu}, 'One outer guarded CPU lane required')
    B.require(0 < a.seconds <= 900 and 1 <= a.rounds <= 20 and 200 <= a.target_ms <= 300,
              'Invalid deadline, rounds or calibration target')
    clean_environment()
    B.require('BENDRTS' not in os.environ, 'Unset ambient BENDRTS')
    document = load(a.manifest)
    roles, reference = list(document['roles']), document['reference']
    known = {c['id']: c for c in document['cases']}
    names = a.cases.split(',') if a.cases else list(known)
    B.require(names and len(names) == len(set(names)) and all(n in known for n in names), 'Invalid selection')
    selected = [known[n] for n in names]
    inputs = B.unique_inputs([B.pin(a.manifest), B.pin(__file__), B.pin(CATALOG), *document['inputs']])
    out = fresh_output(a.out, ROOT)
    deadline = start + a.seconds
    report = dict(kind='phase185-adaptive-native-runtime', version=1, complete=False,
        inputs=inputs, roles=document['roles'], reference=reference, rounds=a.rounds,
        selectedCaseIds=names, fullCatalog=len(names) == 45, targetMs=a.target_ms,
        initialPilotMaximumRepetitions=16, minimumAcceptedMs=100, secondsLimit=a.seconds, cpu=a.cpu,
        positionBalanced=a.rounds % len(roles) == 0,
        scope='Prepared program runtime only; per-role calibrated ms/invocation. No compiler timing.',
        ordering='Serial role rotation by case and round; calibration pilots excluded from ratios.',
        cases=[dict(id=c['id'], family=c['family'], sourceGroup=c['sourceGroup'], point=c['point'],
                    calibration={}, pilots=[], samples=[]) for c in selected])

    def save():
        B.save(out / 'report.json', report)

    def sample(case, item, role, count, stage, iteration):
        B.require(time.monotonic() < deadline, 'Campaign deadline exhausted')
        point = dict(case['point'], repetitions=count)
        product = case['products'][role]
        row = dict(role=role, round=iteration, repetitions=count, warmups=point['warmups'], correct=False)
        item['pilots' if stage == 'pilot' else 'samples'].append(row)
        save()
        command = [product['artifact']['file'], *B.native_runtime_arguments(product), str(count),
                   str(point['warmups']), *map(str, point['runtimeArgs'])]
        try:
            child = B.child(command, out / stage / case['id'] / (str(iteration) + '-' + role),
                            min(deadline, time.monotonic() + 30), document['cwd'])
            row['process'] = child
            B.require(not child['timedOut'], 'Child deadline exceeded')
            B.require(child['stdout']['bytes'] <= len(point['expectedStdout'].encode()) + 128,
                      'Output exceeds exact native45 contract')
            elapsed = B.observation(Path(child['stdout']['file']).read_bytes(),
                                    Path(child['stderr']['file']).read_bytes(), child['exitCode'], point, child['seconds'])
            row.update(correct=True, elapsedMs=elapsed, metricMs=elapsed / count,
                       lowResolution=point['ratioEligible'] and elapsed < 100)
        except (OSError, ValueError, TimeoutError) as error:
            row['error'] = str(error)
        save()
        return row

    save()
    try:
        for ci, (case, item) in enumerate(zip(selected, report['cases'])):
            order = roles[ci % len(roles):] + roles[:ci % len(roles)]
            for role in order:
                count = min(16, case['point']['repetitions'])
                if not case['point']['ratioEligible']:
                    item['calibration'][role] = count
                    continue
                for attempt in range(8):
                    row = sample(case, item, role, count, 'pilot', attempt)
                    B.require(row['correct'], 'Calibration child failed')
                    if row['elapsedMs'] >= a.target_ms and (row['elapsedMs'] <= 2 * a.target_ms or count == 1):
                        item['calibration'][role] = count
                        break
                    count = next_count(count, row['elapsedMs'], a.target_ms)
                B.require(role in item['calibration'], 'Calibration did not converge')
            for ri in range(a.rounds):
                offset = (ci + ri) % len(roles)
                for role in roles[offset:] + roles[:offset]:
                    sample(case, item, role, item['calibration'][role], 'timed', ri)
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        for item in report['cases']:
            summary = B.summary(item['samples'], roles, reference, a.rounds, item['point']['ratioEligible'])
            summary['admitted'] = summary['complete'] and (not summary['ratioEligible'] or summary['ratios'] is not None)
            if report['changedInputs']:
                summary.update(admitted=False, ratios=None)
            item['summary'] = summary
        report['complete'] = not report.get('error') and not report['changedInputs'] and all(
            c['summary']['admitted'] for c in report['cases'])
        report['aggregate'] = B.aggregate(report['cases'], roles, reference) if report['complete'] else dict(complete=False)
        report['wallSeconds'] = time.monotonic() - start
        report['deadlineReached'] = report['wallSeconds'] >= a.seconds
        save()
    return dict(complete=report['complete'], report=str(out / 'report.json'), aggregate=report['aggregate'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest='command', required=True)
    m = sub.add_parser('merge')
    m.add_argument('--role', nargs=3, action='append', required=True, metavar=('ALIAS', 'MANIFEST', 'SOURCE_ROLE'))
    m.add_argument('--reference', required=True)
    m.add_argument('--cases', required=True)
    m.add_argument('--out', type=Path, required=True)
    r = sub.add_parser('run')
    r.add_argument('--manifest', type=Path, required=True)
    r.add_argument('--out', type=Path, required=True)
    r.add_argument('--cases')
    r.add_argument('--rounds', type=int, default=3)
    r.add_argument('--seconds', type=float, default=60)
    r.add_argument('--target-ms', type=int, default=250)
    r.add_argument('--cpu', type=int, default=3)
    r.add_argument('--guarded', action='store_true')
    a = p.parse_args()
    result = merge(a) if a.command == 'merge' else run(a)
    print(json.dumps(result))
    return 0 if result.get('complete', True) else 1


if __name__ == '__main__':
    sys.exit(main())

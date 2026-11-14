#!/usr/bin/env python3
"""Diagnostic-only four-role merge, both-point oracles, and Phase185 timing.

Imports the maintained bench subprocess/output/summary implementation and the
unchanged Phase185 calibration/rotation engine. No compilation or acquisition.
"""
import argparse
import copy
import importlib.util
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
METHOD = ROOT / 'selfhost/tests/phase185/runtime-loop.py'
spec = importlib.util.spec_from_file_location('p194_diagnostic_runtime', METHOD)
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)
B = R.B
CATALOG = HERE / 'catalog-v2.json'
ALIASES = ['c', 'qbe', 'baseline', 'candidate']
IDS = ['value-identity-rebind', 'value-identity-helpers',
       'register-pressure-few', 'register-pressure-many',
       'f32-region-closed', 'f32-region-mixed',
       'predicate-flow-branch', 'predicate-flow-mask',
       'product-ownership-unique', 'product-ownership-shared',
       'memory-dependence-sequential', 'memory-dependence-dependent']


def catalog():
    value = B.catalog(CATALOG)
    B.require(value.get('kind') == 'phase194-independent-paired-diagnostics'
        and value.get('diagnosticOnly') is True
        and value.get('native45Membership') is False
        and [c['id'] for c in value['cases']] == IDS,
        'Exact twelve-case diagnostic catalog required')
    pins = [B.pin(CATALOG), B.pin(__file__), B.pin(METHOD), B.pin(B.__file__), value['oracle']]
    base = (CATALOG.parent / value.get('assetRoot', '.')).resolve()
    for case in value['cases']:
        small = B.bind(case['correctness']['expectedFile'], base)
        B.require(Path(small['file']).read_text() == case['correctness']['expectedStdout'],
                  'Independent small-point oracle differs')
        pins.extend([case['source'], case['expectedFile'], small, case['lineage']])
    for item in pins:
        B.verify(item)
    return value, B.unique_inputs(pins)


def load(path):
    """Authenticate all original metadata, then add runtime-only grouping."""
    original, extra = catalog()
    known = {c['id']: c for c in original['cases']}
    doc = B.read(path)
    B.require(doc.get('schema') == 'bend-benchmark-manifest-v1'
        and doc.get('kind') == 'programs' and B.pin(CATALOG) in doc['inputs'],
        'Program manifest must bind this exact diagnostic catalog')
    for item in doc['inputs']:
        B.verify(item)
    B.require(len(doc['cases']) == 12 and {c['id'] for c in doc['cases']} == set(IDS),
              'Complete unique twelve-case acquisition required')
    for case in doc['cases']:
        expected = known[case['id']]
        B.require(all(case.get(k) == v for k, v in expected.items()),
                  'Diagnostic source/point/oracle metadata differs: ' + case['id'])
        B.require('sourceGroup' not in case or case['sourceGroup'] == case['source']['sha256'],
                  'Unexpected source grouping')
        case['sourceGroup'] = case['source']['sha256']
        B.require(set(case['products']) == set(doc['roles']), 'Product roles differ')
        for product in case['products'].values():
            B.verify(product['artifact'])
            B.require(product['artifact'] in doc['inputs'], 'Unbound executable artifact')
            B.native_runtime_arguments(product)
    for role in doc['roles'].values():
        B.require(role['target'] in ('c', 'qbe', 'x86'), 'Native prepared products required')
        role['inputs'] = B.unique_inputs([*role.get('inputs', []), *extra])
    doc['inputs'] = B.unique_inputs([*doc['inputs'], *extra])
    return doc


def merged_roles(doc):
    B.require(list(doc['roles']) == ALIASES and doc['reference'] == 'c',
              'Ordered c/qbe/baseline/candidate roles with C reference required')
    B.require([doc['roles'][r]['target'] for r in ALIASES] == ['c', 'qbe', 'x86', 'x86'],
              'Expected C, QBE, baseline x86 and candidate x86 targets')


def merge(args):
    B.require([r[0] for r in args.role] == ALIASES,
              'Provide --role c, qbe, baseline, candidate in that order')
    args.reference, args.cases = 'c', ','.join(IDS)
    result = R.merge(args)
    merged_roles(load(result['manifest']))
    result.update(kind='phase194-diagnostic-runtime-merge', diagnosticOnly=True,
                  native45Membership=False, complete=True)
    B.save(args.out / 'report.json', result, fresh=True)
    return result


def summary(path, timing, checks):
    lines = ['# Phase194 diagnostic runtime', '',
        'Diagnostic-only; excluded from native45. Times are milliseconds per complete bench invocation.',
        f'Timing complete: {timing["complete"]}.',
        f'Both declared parameter points: {checks} exact-output observations passed.',
        f'{timing["rounds"]} rounds rotate all four roles through every position. Per-role calibration targets 200–300 ms; pilots are excluded.', '',
        '| Program | C ms | QBE ms | Baseline ms | Candidate ms | Candidate/baseline | Range flag |',
        '|---|---:|---:|---:|---:|---:|---|']
    for case in timing['cases']:
        stats = case['summary']['stats']
        if all(r in stats for r in ALIASES):
            values = [stats[r]['medianMs'] for r in ALIASES]
            ratio = values[3] / values[2] if values[2] and case['summary']['admitted'] else None
            flags = [r for r in ALIASES if stats[r]['minimumMs'] > 0
                     and stats[r]['maximumMs'] / stats[r]['minimumMs'] > 1.10]
            lines.append('| ' + case['id'] + ' | ' + ' | '.join(f'{v:.6g}' for v in values)
                         + ' | ' + (f'{ratio:.6f}' if ratio is not None else 'not admitted')
                         + ' | ' + (','.join(flags) or '—') + ' |')
    lines.extend(['', 'Range flag means max/min > 1.10 across retained samples; it is not a confidence interval.',
        'F32 mixed adds conversions; predicate mask evaluates both arms. Pairwise source differences are not equal-instruction-work claims.',
        'Source sharing and pressure do not guarantee surviving allocations/spills. The 256-word memory pair is cache-resident.',
        'Failed, incomplete or low-resolution timing sets do not qualify as passes; consult report.json and timing/report.json.', ''])
    path.write_text('\n'.join(lines))


def run(args):
    started = time.monotonic()
    B.require(args.guarded and args.cpu == 3 and os.sched_getaffinity(0) == {3},
              'One outer guarded CPU3 lane required')
    B.require(0 < args.seconds <= 900 and args.rounds in (4, 8, 12, 16, 20)
        and 200 <= args.target_ms <= 300, 'Bounded deadline, balanced rounds and calibration target required')
    R.clean_environment()
    B.require('BENDRTS' not in os.environ, 'Unset ambient BENDRTS')
    document = load(args.manifest)
    merged_roles(document)
    known = {c['id']: c for c in document['cases']}
    inputs = B.unique_inputs([B.pin(args.manifest), *document['inputs']])
    out = R.fresh_output(args.out, ROOT)
    deadline = started + args.seconds
    report = dict(kind='phase194-diagnostic-runtime', version=1, complete=False,
        diagnosticOnly=True, native45Membership=False, inputs=inputs,
        selectedCaseIds=IDS, roles=document['roles'], reference='c',
        correctness=[], rounds=args.rounds, positionBalanced=True,
        scope='Prepared diagnostic runtime only. Both declared points checked on all four roles, then original Phase185 calibrated timing. No compilation, acquisition, native45 score or producer qualification.')

    def save():
        report['wallSeconds'] = time.monotonic() - started
        B.save(out / 'report.json', report)

    save()
    try:
        for index, name in enumerate(IDS):
            case = known[name]
            for label, selected in [('small', case['correctness']), ('timing', case['point'])]:
                point = dict(selected, repetitions=1, warmups=0)
                order = ALIASES[index % 4:] + ALIASES[:index % 4]
                for role in order:
                    product = case['products'][role]
                    row = dict(id=name, point=label, role=role, correct=False)
                    report['correctness'].append(row); save()
                    command = [product['artifact']['file'], *B.native_runtime_arguments(product),
                               '1', '0', *map(str, point['runtimeArgs'])]
                    child = B.child(command, out / 'correctness' / name / label / role,
                                    min(deadline, time.monotonic() + 30), document['cwd'])
                    row['process'] = child
                    B.require(not child['timedOut'], 'Correctness child timed out')
                    B.require(child['stdout']['bytes'] <= len(point['expectedStdout'].encode()) + 128,
                              'Output exceeds exact diagnostic contract')
                    B.observation(Path(child['stdout']['file']).read_bytes(),
                        Path(child['stderr']['file']).read_bytes(), child['exitCode'], point, child['seconds'])
                    row['correct'] = True; save()
        timed = copy.copy(args)
        timed.out, timed.cases = out / 'timing', ','.join(IDS)
        timed.seconds = deadline - time.monotonic()
        B.require(timed.seconds > 0, 'Campaign exhausted before timing')
        result = R.run(timed)
        report['timingReceipt'] = B.pin(timed.out / 'report.json')
        timing = B.read(report['timingReceipt']['file'])
        report['complete'] = result['complete'] and len(report['correctness']) == 96
        summary(out / 'summary.md', timing, len(report['correctness']))
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = R.changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    return dict(complete=report['complete'], report=str(out / 'report.json'),
                summary=str(out / 'summary.md'), error=report.get('error'))


def main():
    global CATALOG
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalog', type=Path, default=CATALOG)
    commands = parser.add_subparsers(dest='command', required=True)
    m = commands.add_parser('merge')
    m.add_argument('--role', nargs=3, action='append', required=True,
                   metavar=('ALIAS', 'MANIFEST', 'SOURCE_ROLE'))
    m.add_argument('--out', type=Path, required=True)
    r = commands.add_parser('run')
    r.add_argument('--manifest', type=Path, required=True)
    r.add_argument('--out', type=Path, required=True)
    r.add_argument('--rounds', type=int, default=4)
    r.add_argument('--seconds', type=float, default=240)
    r.add_argument('--target-ms', type=int, default=250)
    r.add_argument('--cpu', type=int, default=3)
    r.add_argument('--guarded', action='store_true')
    args = parser.parse_args()
    CATALOG = args.catalog.resolve(strict=True)
    R.CATALOG, R.load = CATALOG, load
    original_save = B.save

    def save(path, value, fresh=False):
        if isinstance(value, dict) and value.get('kind') == 'phase185-adaptive-native-runtime':
            value.update(kind='phase194-diagnostic-adaptive-runtime', diagnosticOnly=True,
                native45Membership=False, fullCatalog=False, allDiagnosticCases=True,
                scope='Twelve diagnostic timing points only, excluded from native45. Original Phase185 calibration and rotating order; no compiler timing or producer qualification.')
        return original_save(path, value, fresh=fresh)

    B.save = save
    result = merge(args) if args.command == 'merge' else run(args)
    print(json.dumps(result))
    return 0 if result.get('complete', True) else 1


if __name__ == '__main__':
    sys.exit(main())

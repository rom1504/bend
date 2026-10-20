#!/usr/bin/env python3
"""Phase113 screen adapter: unchanged Phase112 binder/measurement, explicit grade.

Only root invokes measure, inside its serial CPU3 guard. Artifact directories
retain the old Phase112 parent required by the unchanged measurement function.
"""
import argparse
import importlib.util
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
ORIGINAL = ROOT/'selfhost/tools/performance/phase112/benchmark/run.py'
spec = importlib.util.spec_from_file_location('phase112_frozen_measurement', ORIGINAL)
method = importlib.util.module_from_spec(spec)
spec.loader.exec_module(method)
# Configuration only: the original methods receive the new manifest explicitly;
# HERE supplies its pin and copied manifest, without rewriting original source.
method.HERE = HERE


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest='action', required=True)
    b = actions.add_parser('bind')
    b.add_argument('--label', required=True)
    b.add_argument('--reports', type=Path, required=True)
    b.add_argument('--out', type=Path, required=True)
    b.set_defaults(names=None)
    m = actions.add_parser('measure')
    m.add_argument('--bindings', nargs='+', type=Path, required=True)
    m.add_argument('--out', type=Path, required=True)
    m.add_argument('--grade', choices=['diagnostic1', 'paired3'], required=True)
    m.add_argument('--budget-seconds', type=int)
    m.add_argument('--seconds', type=int, default=12)
    args = parser.parse_args()
    manifest = method.read(HERE/'manifest01.json')
    method.verify(manifest['measurementMethod'])
    if args.action == 'bind':
        if args.label in {'phase111', 'facts-n2'}:
            raise ValueError('Reserved baseline names; use a fresh candidate label')
        return method.bind(args, manifest) or 0
    args.rounds = 1 if args.grade == 'diagnostic1' else 3
    args.budget_seconds = args.budget_seconds or (20 if args.rounds == 1 else 60)
    if args.budget_seconds <= 0 or args.seconds <= 0:
        raise ValueError('Positive process and campaign budgets required')
    args.profile, args.names = HERE/'upstream-15ms-profile01.json', None
    bindings = [method.read(path) for path in args.bindings]
    if not any(x.get('label') == 'facts-n2' for x in bindings):
        raise ValueError('The frozen facts-n2 baseline binding is required')
    for binding in bindings:
        if not binding.get('fullFrozenQualified') or set(binding['products']) != {c['name'] for c in manifest['cases']}:
            raise ValueError('Every bound role must cover all six exact Phase113 points')
    inputs = [method.pin(__file__), method.pin(ORIGINAL), method.pin(HERE/'manifest01.json'),
              method.pin(args.profile), *[method.pin(x) for x in args.bindings]]
    for item in inputs:
        method.verify(item)
    code = method.measure(args, manifest)
    legacy = method.read(args.out/'report.json')
    complete = bool(legacy.get('complete') and legacy.get('fullRequestedQualification'))
    paired = args.grade == 'paired3' and complete
    ratios = {}
    if paired:
        for role in legacy['roles']:
            values = [row['mediansMs'][role]/row['mediansMs']['facts-n2'] for row in legacy['perProgram'].values()]
            ratios[role] = math.exp(sum(map(math.log, values))/len(values))
    for item in inputs:
        method.verify(item)
    report = dict(kind='phase113-six-program-screen', complete=complete, comparisonGrade=args.grade,
        diagnosticOnly=args.grade == 'diagnostic1', pairedTimingQualified=paired,
        rawReceipt=method.pin(args.out/'report.json'), inputs=inputs, names=[c['name'] for c in manifest['cases']],
        rounds=args.rounds, geomeanRatiosToFactsN2=ratios if paired else None,
        geomeanRatiosToUpstream=legacy.get('geomeanRatios', {}).get('upstream') if paired else None,
        perProgram=legacy.get('perProgram'),
        scope='New Phase113 six-point development screen. Diagnostic1 has no qualified timing aggregate. Paired3 uses three rotated rounds and full-output checks. Raw legacy report fields do not change this grade. Original45 and Phase112 screens remain separate.',
        precision='15ms target from historical upstream only; 5ms floor; 1ms clock. Small percentage changes remain unresolved.')
    method.save(args.out/'phase113-report.json', report)
    print(json.dumps(dict(complete=complete, grade=args.grade, pairedTimingQualified=paired,
        ratiosToFactsN2=report['geomeanRatiosToFactsN2'], report=str(args.out/'phase113-report.json'))))
    return code if complete else 1


if __name__ == '__main__':
    raise SystemExit(main())

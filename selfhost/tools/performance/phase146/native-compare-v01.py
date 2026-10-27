#!/usr/bin/env python3
"""Alternating native request pairs; root wraps the entire run in one guard."""
import argparse
import importlib.util
import json
import math
import os
import statistics
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT/'selfhost/tools/performance/phase145/execution/run-v01.py'
spec = importlib.util.spec_from_file_location('execution', METHOD)
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','candidate','plan','out']:
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=4)
    args = parser.parse_args()
    out = args.out.resolve()
    E.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase146'), 'Fresh Phase146 output')
    E.require(1 <= args.rounds <= 6, 'Bounded pairs')
    E.require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS']), 'No diagnostic environment')
    plan = json.loads(args.plan.read_text())
    E.require(plan['complete'] and plan['kind'] == 'phase145-same-source-execution-plan', 'Frozen input plan')
    images = dict(baseline=E.pin(args.baseline), candidate=E.pin(args.candidate))
    inputs = [E.pin(__file__), E.pin(METHOD), E.pin(args.plan), *images.values(), plan['base'], plan['carrier']]
    for case in plan['cases']:
        inputs.extend([case['source'], case['expectedQbe']])
    for item in inputs:
        E.verify(item)
    out.mkdir(parents=True)
    report = dict(kind='phase146-paired-native-requests', complete=False, inputs=inputs,
                  rows=[], cases=[], inheritedAffinity=sorted(os.sched_getaffinity(0)),
                  scope='Fresh native processes, exact same ordinary inputs/prepared Base and complete frozen QBE. Alternating order by pair/case; exploratory compiler latency, not generated-program runtime.')
    start = time.monotonic()

    def save():
        report['seconds'] = time.monotonic()-start
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    try:
        for repeat in range(args.rounds):
            for i, case in enumerate(plan['cases']):
                for role in (['baseline','candidate'] if (repeat+i) % 2 == 0 else ['candidate','baseline']):
                    work = out/f'{case["name"]}-{repeat:02d}-{role}'
                    work.mkdir()
                    row = E.child([images[role]['file'],'--threads','1','--gpu','off','--','phase111',
                                   case['source']['file'],plan['base']['file'],'cache',plan['carrier']['file'],plan['stamp']], work, 60)
                    E.require(E.N.same_bytes(work/'stdout', Path(case['expectedQbe']['file'])), 'Complete native QBE differs')
                    row.update(case=case['name'], role=role, round=repeat, byteExact=True, product=E.pin(work/'stdout'))
                    report['rows'].append(row)
                    save()
        for case in plan['cases']:
            rows = [r for r in report['rows'] if r['case'] == case['name']]
            medians = {role: statistics.median(r['seconds'] for r in rows if r['role'] == role) for role in images}
            ratios = [next(r['seconds'] for r in rows if r['round'] == i and r['role'] == 'candidate') /
                      next(r['seconds'] for r in rows if r['round'] == i and r['role'] == 'baseline') for i in range(args.rounds)]
            report['cases'].append(dict(name=case['name'], medians=medians, pairedRatios=ratios,
                                       candidateOverBaselineGeometric=math.exp(statistics.mean(map(math.log,ratios)))))
        for item in inputs:
            E.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps({k:report.get(k) for k in ['complete','cases','error','seconds']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

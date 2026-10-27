#!/usr/bin/env python3
"""Matched checked-API requests with complete frozen QBE oracles."""
import argparse
import importlib.util
import json
import math
import os
import statistics
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RUNNER = ROOT/'selfhost/tools/performance/phase145/execution/run-v01.py'
HOSTED = RUNNER.with_name('hosted-v01.mjs')
spec = importlib.util.spec_from_file_location('execution', RUNNER)
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate-api', type=Path, required=True)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=2)
    parser.add_argument('--case', action='append')
    args = parser.parse_args()
    out = args.out.resolve()
    E.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase146'), 'Fresh Phase146 output')
    E.require(1 <= args.rounds <= 4, 'Bounded rounds')
    E.require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS']), 'No diagnostic environment')
    candidate = json.loads(args.candidate_api.read_text())
    plan = json.loads(args.plan.read_text())
    E.require(candidate['complete'] and candidate['checked'] and candidate['status'] == 0, 'Checked candidate required')
    E.require(plan['complete'] and plan['kind'] == 'phase145-same-source-execution-plan', 'Frozen parent plan required')
    inputs = [E.pin(__file__), E.pin(RUNNER), E.pin(HOSTED), E.pin(args.candidate_api),
              E.pin(args.plan), *candidate['inputs'], candidate['api'], plan['api'],
              plan['base'], plan['carrier'], plan['bun']]
    cases = [c for c in plan['cases'] if not args.case or c['name'] in args.case]
    E.require(cases and (not args.case or set(args.case) == {c['name'] for c in cases}), 'Unknown cases')
    for case in cases:
        inputs.extend([case['source'], case['expectedQbe']])
    for item in inputs:
        E.verify(item)
    out.mkdir(parents=True)
    report = dict(kind='phase146-matched-hosted-request-screen', complete=False, inputs=inputs,
                  rows=[], cases=[], inheritedAffinity=sorted(os.sched_getaffinity(0)),
                  scope='Fresh-process same ordinary source/Base request; natural JIT/GC. Complete parent QBE required. This is hosted cost, not native or full self-build speed.')
    start = time.monotonic()

    def save():
        report['totalSeconds'] = time.monotonic()-start
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    try:
        for case in cases:
            for repeat in range(args.rounds):
                for role in (['parent','candidate'] if repeat % 2 == 0 else ['candidate','parent']):
                    work = out/f'{case["name"]}-{repeat:02d}-{role}'
                    work.mkdir()
                    product = work/'program.ssa'
                    config = dict(api=plan['api'] if role == 'parent' else candidate['api'],
                                  source=case['source'], base=plan['base'], carrier=plan['carrier'],
                                  stamp=plan['stamp'], output=str(product), observation=str(work/'observation.json'),
                                  instrumented=False)
                    (work/'input.json').write_text(json.dumps(config, indent=2)+'\n')
                    row = E.child([plan['bun']['file'],str(HOSTED),str(work/'input.json')], work, 90)
                    observation = json.loads((work/'observation.json').read_text())
                    E.require(observation['complete'] and row['stdout']['bytes'] == 0, 'Observer failed')
                    E.require(E.N.same_bytes(product, Path(case['expectedQbe']['file'])), 'Complete QBE differs')
                    row.update(case=case['name'], role=role, round=repeat, byteExact=True,
                               product=E.pin(product), observation=E.pin(work/'observation.json'), stages=observation['timings'])
                    report['rows'].append(row)
                    save()
            rows = [r for r in report['rows'] if r['case'] == case['name']]
            medians = {role: statistics.median(r['seconds'] for r in rows if r['role'] == role)
                       for role in ['parent','candidate']}
            ratios = [next(r['seconds'] for r in rows if r['round'] == i and r['role'] == 'candidate') /
                      next(r['seconds'] for r in rows if r['round'] == i and r['role'] == 'parent')
                      for i in range(args.rounds)]
            report['cases'].append(dict(name=case['name'], medians=medians, pairedRatios=ratios,
                                       candidateOverParentGeometric=math.exp(statistics.mean(map(math.log,ratios)))))
        for item in inputs:
            E.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps({k: report.get(k) for k in ['complete','cases','error','totalSeconds']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

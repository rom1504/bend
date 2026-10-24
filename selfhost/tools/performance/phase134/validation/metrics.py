#!/usr/bin/env python3
"""Summarize a completed matched Phase134 timing block; execute no targets."""
import argparse
import importlib.util
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('p134_plan', Path(__file__).with_name('plan.py'))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); r = P.read(a.report)
    P.require(r.get('complete') and r.get('passed') and not r.get('checkOnly') and r.get('inputsUnchanged'), 'Complete actual timing report required')
    m = P.read(P.verify(r['manifest']))
    ref, _, base, t = P.reference(m['lineage']['reference']['file'])
    P.require(r['roles'] == m['roles'] and r['roles']['phase111']['binary'] == ref['measuredN2'], 'Measured parent role changed')
    P.require(r['cases'] == base['cases'] and r['rounds'] == 3 and r['modes'] == ['cache'] and len(r['rows']) == 27, 'Frozen three-case three-round cache block required')
    P.require(r['cpuAffinity'] == [3], 'Clean timing requires CPU3 lane')
    P.require(all(x['passed'] and x['outputExact'] and x['stderrExact'] for x in r['rows']), 'All independent output observations required')
    for item in [*r['inputs'], *t.pins(m)]: P.verify(item)
    runner = P.load(t.RUNNER, 'p134_frozen_timer')
    summary = runner.summarize(r['rows'], r['cases'], r['rounds'])
    P.require(summary == r['summary'], 'Summary differs from raw observations')
    cases = []
    for case in ref['cases']:
        row = dict(name=case['name'], roles={}, candidateMatchesPhase131Qbe=True)
        for role in ['phase111', 'phase112', 'upstream']:
            observations = [x for x in r['rows'] if x['name'] == case['name'] and x['role'] == role]
            P.require(len(observations) == 3 and len({x['round'] for x in observations}) == 3, 'Missing or duplicate round')
            jobs = [next(j for j in x['jobs'] if j['stage'] in ['compile-qbe', 'compile-c']) for x in observations]
            row['roles'][role] = dict(requestSeconds=[x['requestSeconds'] for x in observations],
                requestCpuSeconds=[j['userSeconds'] + j['systemSeconds'] for j in jobs],
                medianPeakRssKiB=statistics.median(j['peakRssKiB'] for j in jobs))
            for x in observations:
                P.verify(x['representation'])
                if role == 'phase112' and x['representation']['sha256'] != case['expectedQbe']['sha256']:
                    row['candidateMatchesPhase131Qbe'] = False
        cases.append(row)
    P.save(a.out, dict(complete=True, targetsRun=False, inputs=[P.pin(__file__), P.pin(a.report), r['manifest']],
        roles=r['roles'], summary=summary, cases=cases, observations=27,
        scope='Fresh same-block medians and ranges; no formal confidence interval. Request time is complete fresh compiler child with prepared Base for both native roles; upstream reads source Base. Ready-stage sums include distinct machine/runtime build policies. Execute rows are correctness only, not generated-program speed. N2 reference timings are not assigned to N3.'))
    print(summary['cache']['threeCaseGeometricRatios'])


if __name__ == '__main__': main()

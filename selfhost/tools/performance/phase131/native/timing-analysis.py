#!/usr/bin/env python3
"""Summarize completed native timing from retained rows; execute no targets."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import statistics as S

ROOT = Path(__file__).resolve().parents[5]


def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--report', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    r = json.loads(a.report.read_text())
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131')
    assert r['complete'] and r['passed'] and r['inputsUnchanged'] and not r['checkOnly']
    assert r['modes'] == ['cache'] and len(r['rows']) == 3 * len(r['cases']) * r['rounds']
    assert all(x['passed'] and x['outputExact'] and x['stderrExact'] for x in r['rows'])
    cases = []
    for c in r['cases']:
        roles = {}
        for role in ['phase111', 'phase112', 'upstream']:
            rows = [x for x in r['rows'] if x['name'] == c['name'] and x['role'] == role]
            assert len(rows) == r['rounds']
            cpu = [x['jobs'][0]['userSeconds'] + x['jobs'][0]['systemSeconds'] for x in rows]
            roles[role] = dict(requestSeconds=[x['requestSeconds'] for x in rows],
                requestMedian=S.median(x['requestSeconds'] for x in rows), requestCpuSeconds=cpu,
                cpuMedian=S.median(cpu), requestWallOverCpu=[x['requestSeconds'] / y for x, y in zip(rows, cpu)],
                machineMedian=S.median(x['machineBuildSeconds'] for x in rows),
                readyMedian=S.median(x['readyExecutableStageSumSeconds'] for x in rows),
                rawOutputSha256=sorted({x['jobs'][0]['stdout']['sha256'] for x in rows}))
        native_exact = roles['phase111']['rawOutputSha256'] == roles['phase112']['rawOutputSha256']
        assert len(roles['phase111']['rawOutputSha256']) == len(roles['phase112']['rawOutputSha256']) == 1
        pairs = []
        for rnd in range(1, r['rounds'] + 1):
            rows = {x['role']: x for x in r['rows'] if x['name'] == c['name'] and x['round'] == rnd}
            pairs.append(rows['phase112']['requestSeconds'] / rows['phase111']['requestSeconds'])
        ratio = roles['phase112']['requestMedian'] / roles['phase111']['requestMedian']
        left, right = roles['phase111']['requestSeconds'], roles['phase112']['requestSeconds']
        range_hint = ('candidate_range_below_parent' if max(right) < min(left) else
                      'candidate_range_above_parent' if min(right) > max(left) else 'ranges_overlap')
        cases.append(dict(name=c['name'], roles=roles, candidateOverParent=ratio,
            candidateOverUpstream=roles['phase112']['requestMedian'] / roles['upstream']['requestMedian'],
            parentOverUpstream=roles['phase111']['requestMedian'] / roles['upstream']['requestMedian'],
            requestPercentChange=100 * (ratio - 1), pairedRoundRatios=pairs, nativeQbeExact=native_exact,
            observedRangeHint=range_hint))
    geo = lambda values: math.exp(S.mean(math.log(x) for x in values))
    request = {k: geo(c[k] for c in cases) for k in ['candidateOverParent', 'candidateOverUpstream', 'parentOverUpstream']}
    existing = r['summary']['cache']['threeCaseGeometricRatios']['requestSeconds']
    for k, old in [('candidateOverParent', 'phase112/phase111'), ('candidateOverUpstream', 'phase112/upstream'), ('parentOverUpstream', 'phase111/upstream')]:
        assert math.isclose(request[k], existing[old], rel_tol=1e-12)
    result = dict(complete=True, inputs=[pin(__file__), pin(a.report), r['manifest']], roles=r['roles'],
        observations=len(r['rows']), cases=cases, geometricRequestRatios=request,
        geometricReadyRatios=r['summary']['cache']['threeCaseGeometricRatios']['readyExecutableStageSumSeconds'],
        exactNativeQbeAllCases=all(c['nativeQbeExact'] for c in cases),
        sampleWindowSeconds=r['finished'] - r['started'],
        scope='Same requested programs and controlled workflow; compiler source identities are recorded, not assumed equal. Three repetitions are a screen. Request and ready-child sums are distinct; execution is correctness-only. No full45 or recursive-improvement claim.')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    lines = ['# Phase131 native request timing', '',
        f"All{len(r['rows'])} observations pass independent complete-output checks. Both native roles use the identical compact Base carrier.", '',
        '| Request | Parent seconds | Candidate seconds | Upstream seconds | Candidate/parent | Candidate/upstream |',
        '|---|---:|---:|---:|---:|---:|']
    for c in cases:
        roles = c['roles']
        lines.append(f"|{c['name']}|{roles['phase111']['requestMedian']:.6f}|{roles['phase112']['requestMedian']:.6f}|{roles['upstream']['requestMedian']:.6f}|{c['candidateOverParent']:.6f}|{c['candidateOverUpstream']:.6f}|")
    lines += ['', f"Geometric request ratio: candidate/parent{request['candidateOverParent']:.6f}; candidate/upstream{request['candidateOverUpstream']:.6f}; parent/upstream{request['parentOverUpstream']:.6f}.", '',
        'Observed request ranges (descriptive, not confidence intervals): ' + '; '.join(c['name'] + '=' + c['observedRangeHint'] for c in cases) + '.', '',
        'Ready-executable child sums include the different QBE/as/link versus full C/Clang workflows. Native prepared Base and cached runtime are explicit advantages. These timings do not measure generated-program execution speed.', '',
        'Raw request observations, role identities, per-round paired ratios and exact-QBE checks are retained in `report.json`.']
    (out / 'README.md').write_text('\n'.join(lines) + '\n')
    print(json.dumps(dict(complete=True, geometricRequestRatios=request, exactNativeQbeAllCases=result['exactNativeQbeAllCases'])))


if __name__ == '__main__':
    main()

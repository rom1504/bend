#!/usr/bin/env python3
"""Offline authenticated equal-family and positive fixed-work deficit diagnostics."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('phase186_analysis', ROOT/'selfhost/tests/phase186/analyze-runtime.py')
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
B, C = A.B, A.C


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--summary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    C.require(not a.out.exists(), 'Fresh output required')
    summary_pin = C.pin(a.summary)
    summary = B.read(a.summary)
    C.require(summary['kind'] == 'phase190-authenticated-runtime-summary', 'Phase190 summary required')
    current = A.analyze(C.verify(summary['report']), summary['dispersionThreshold'])
    old = {c['id']: c for c in summary['cases']}
    C.require(len(old) == len(current['cases']) and summary['roles'] == current['roles'], 'Summary case/role set differs')
    for case in current['cases']:
        row = old[case['id']]
        C.require(row['ratioEligible'] == case['ratioEligible'] and
            row['medianMs'] == {r: case['stats'][r]['medianMs'] for r in current['roles']}, 'Summary medians differ')
    eligible = [c for c in current['cases'] if c['ratioEligible']]
    roles = {}
    for role in current['roles']:
        comparisons = {}
        for reference in [summary['cRole'], summary['baselineRole']]:
            families = {}
            for c in eligible:
                families.setdefault(c['family'], []).append(c['stats'][role]['medianMs']/c['stats'][reference]['medianMs'])
            means = {k: A.gm(v) for k, v in families.items()}
            comparisons[reference] = dict(familyCount=len(means), familyGeomeans=means,
                equalFamilyGeomean=A.gm(means.values()),
                positiveFixedEquivalentExcessMs=sum(max(0, c['stats'][role]['medianMs']-c['stats'][reference]['medianMs'])*c['point']['repetitions'] for c in eligible))
        roles[role] = comparisons
    C.require(C.pin(a.summary) == summary_pin, 'Summary changed during analysis')
    result = dict(kind='phase190-family-fixed-work-diagnostics', programsExecuted=False,
        method=C.pin(__file__), analyzer=C.pin(A.__file__), summary=summary_pin, report=current['report'],
        catalog=C.pin(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'),
        caseCount=len(current['cases']), ratioEligibleCount=len(eligible), roles=roles,
        scope='Diagnostic only: equal weight per family after geometric averaging within each family; positive fixed-work excess sums max(0, role median minus reference median) times original catalog repetitions. All eligible cases retained, including dispersion flags; zero-work excluded. Does not replace the historical equal-case 44-case geometric mean or establish significance.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    B.save(a.out, result, fresh=True)
    print(json.dumps(dict(out=str(a.out), roles={k:{r:{n:v for n,v in x.items() if n!='familyGeomeans'} for r,x in s.items()} for k,s in roles.items()})))


if __name__ == '__main__':
    main()

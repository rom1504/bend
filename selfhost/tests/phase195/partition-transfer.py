#!/usr/bin/env python3
"""Annotate the authenticated full runtime score with code changes and exposure."""
import argparse
import json
import math
from pathlib import Path
from statistics import geometric_mean
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, require, verify, write_json


def objects(path):
    data = json.loads(path.read_text())
    require(data['complete'] and not data.get('changedInputs'), 'Incomplete program acquisition')
    result = {}
    for row in data['rows']:
        require(row['complete'], 'Incomplete product')
        verify(row['artifact'])
        verify(row['object'])
        result[row['id']] = row
    require(len(result) == len(data['rows']) == 45, 'Expected all 45 products')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ['summary', 'baseline', 'candidate', 'out']:
        parser.add_argument('--' + key, required=True, type=Path)
    args = parser.parse_args()
    summary = json.loads(args.summary.read_text())
    require(summary['kind'] == 'phase195-authenticated-runtime-summary' and
            summary['subsets']['all']['caseCount'] == 45, 'Expected authenticated full score')
    baseline, candidate = objects(args.baseline), objects(args.candidate)
    # These two historical baseline functions were inspected during ownership research.
    inspected = {'coverage-map-churn-128', 'coverage-record-aggregation-256'}
    rows = []
    for case in summary['cases']:
        name = case['id']
        before, after = baseline[name], candidate[name]
        require(case['artifacts']['candidate'] == after['artifact'] and
                case['artifacts']['baseline'] == before['artifact'], 'Runtime product differs')
        rows.append(dict(id=name, sameObject=before['object']['sha256'] == after['object']['sha256'],
                         heldout=case['partition'] == 'heldout', inspected=name in inspected,
                         ratio=case['ratios']['candidate']['overBaseline'] if case['ratioEligible'] else None))
    catalog = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
    families = {c['id']: c['family'] for c in json.loads(catalog.read_text())['cases']}
    require(families.keys() == candidate.keys(), 'Catalog mismatch')
    eligible = [c for c in summary['cases'] if c['ratioEligible']]
    opportunities = []
    for family in sorted(set(families.values())):
        selected = [c for c in eligible if families[c['id']] == family]
        if not selected:
            continue
        positive_log_sum = sum(max(0, math.log(c['ratios']['candidate']['overC'])) for c in selected)
        excess_ms = sum(max(0, c['fixedEquivalentMs']['candidate'] - c['fixedEquivalentMs']['c']) for c in selected)
        opportunities.append(dict(family=family, cases=len(selected), positiveFixedExcessMs=excess_ms,
            fullSuiteFractionSavedIfSlowerCasesReachC=1 - math.exp(-positive_log_sum / len(eligible))))
    opportunities.sort(key=lambda r: -r['fullSuiteFractionSavedIfSlowerCasesReachC'])
    groups = {}
    for name, select in [('uninspectedHeldout', lambda r: r['heldout'] and not r['inspected']),
                         ('sameObject', lambda r: r['sameObject']), ('changedObject', lambda r: not r['sameObject'])]:
        selected = [r['ratio'] for r in rows if r['ratio'] is not None and select(r)]
        groups[name] = dict(timedCases=len(selected), geometricRuntimeRatio=geometric_mean(selected) if selected else None)
    require(not args.out.exists(), 'Fresh output required')
    write_json(args.out, dict(inputs=[pin(p) for p in [args.summary, args.baseline, args.candidate, catalog]],
        groups=groups, cases=rows, familyOpportunity=opportunities,
        scope='Family opportunity is a counterfactual at C parity for slow cases, retaining already faster cases. No predicted transformation speedup.'))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Authenticate retained native runtime reports and summarize; never run targets."""
import argparse
import json
import math
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build')]
import bench as B
import common as C


def gm(values):
    return math.exp(statistics.mean(math.log(v) for v in values))


def analyze(filename, spread_limit=1.10):
    report_pin = C.pin(filename)
    report = B.read(filename)
    B.require(report.get('complete') and not report.get('changedInputs')
              and not report.get('deadlineReached'), 'Complete unchanged runtime report required')
    B.require(report.get('kind') == 'phase185-adaptive-native-runtime', 'Adaptive runtime report required')
    for item in report['inputs']:
        C.verify(item)
    catalog_path = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
    catalog_pin = C.pin(catalog_path)
    B.require(catalog_pin in report['inputs'], 'Frozen native45 catalog identity required')
    catalog = {c['id']: c for c in B.catalog(catalog_path)['cases']}
    roles, reference = list(report['roles']), report['reference']
    counts, cases = dict(pilots=0, samples=0), []
    for case in report['cases']:
        B.require(case['id'] in catalog and all(case[k] == catalog[case['id']][k]
                  for k in ('point', 'family', 'sourceGroup')), 'Case differs from frozen catalog')
        for stage in counts:
            for row in case[stage]:
                proc = row['process']
                B.require(row['correct'] and proc['exitCode'] == 0 and not proc['timedOut']
                          and row['warmups'] == case['point']['warmups'], 'Failed sample or changed warmups')
                point = dict(case['point'], repetitions=row['repetitions'])
                elapsed = B.observation(C.verify(proc['stdout']).read_bytes(),
                    C.verify(proc['stderr']).read_bytes(), proc['exitCode'], point, proc['seconds'])
                B.require(elapsed == row['elapsedMs'] and elapsed / row['repetitions'] == row['metricMs'],
                          'Recorded metric differs from authenticated output')
                counts[stage] += 1
        summary = B.summary(case['samples'], roles, reference, report['rounds'], case['point']['ratioEligible'])
        B.require(summary == {k: v for k, v in case['summary'].items() if k != 'admitted'}
                  and case['summary'].get('admitted'), 'Case summary differs')
        dispersion, artifacts = {}, {}
        for role, stats in summary['stats'].items():
            minimum, maximum = stats['minimumMs'], stats['maximumMs']
            spread = maximum / minimum if minimum > 0 else None
            dispersion[role] = dict(samplesMs=stats['samplesMs'], medianMs=stats['medianMs'],
                maxOverMin=spread, flagged=summary['ratioEligible'] and (spread is None or spread > spread_limit))
            command = next(s['process']['command'] for s in case['samples'] if s['role'] == role)
            identities = [p for p in report['inputs'] if p['file'] == command[0]]
            B.require(len(identities) == 1, 'One authenticated executable identity required')
            artifacts[role] = identities[0]
        cases.append(dict(id=case['id'], family=case['family'], sourceGroup=case['sourceGroup'],
            point=case['point'], ratios=summary['ratios'], ratioEligible=summary['ratioEligible'],
            stats=dispersion, artifacts=artifacts, flagged=any(v['flagged'] for v in dispersion.values())))
    B.require(B.aggregate(report['cases'], roles, reference) == report['aggregate'], 'Aggregate differs')
    eligible = [c for c in cases if c['ratioEligible']]
    totals = {}
    for role in roles:
        ratios = [c['stats'][role]['medianMs'] / c['stats'][reference]['medianMs'] for c in eligible]
        families, sources = {}, {}
        for case, ratio in zip(eligible, ratios):
            families.setdefault(case['family'], []).append(ratio)
            sources.setdefault(case['sourceGroup'], []).append(ratio)
        fixed = sum(c['stats'][role]['medianMs'] * c['point']['repetitions'] for c in eligible)
        fixed_ref = sum(c['stats'][reference]['medianMs'] * c['point']['repetitions'] for c in eligible)
        totals[role] = dict(geomeanOverReference=gm(ratios),
            equalFamilyGeomeanOverReference=gm(gm(v) for v in families.values()),
            equalSourceGeomeanOverReference=gm(gm(v) for v in sources.values()),
            meanPositiveLogDeficit=statistics.mean(max(0, math.log(v)) for v in ratios),
            casesOver110=sum(v > 1.1 for v in ratios), casesOver2=sum(v > 2 for v in ratios),
            fixedCatalogProjectedMs=fixed, fixedCatalogReferenceProjectedMs=fixed_ref,
            fixedCatalogTotalRatio=fixed / fixed_ref,
            fixedCatalogPositiveExcessMs=sum(max(0, c['stats'][role]['medianMs'] -
                c['stats'][reference]['medianMs']) * c['point']['repetitions'] for c in eligible))
    B.require(C.pin(filename) == report_pin, 'Report changed while analyzing')
    return dict(report=report_pin, reference=reference, roles=roles, rounds=report['rounds'],
        positionBalanced=report['positionBalanced'], oracleRevalidated=counts, inputPinsVerified=len(report['inputs']),
        caseCount=len(cases), ratioEligibleCount=len(eligible), totals=totals, cases=cases,
        dispersionThreshold=spread_limit, flaggedCases=[c['id'] for c in cases if c['flagged']],
        scope='Original ratios retained, including flagged cases. Dispersion flags are review triggers, not automatic exclusions or significance tests. Fixed-catalog projections use original repetition counts on ratio-eligible cases only; adaptive calibration counts do not weight aggregates.')


def compare(before, after, old_role, new_role, cross_campaign):
    B.require(old_role in before['roles'] and new_role in after['roles'], 'Comparison role missing')
    old = {c['id']: c for c in before['cases'] if c['ratioEligible']}
    rows = []
    for case in after['cases']:
        if not case['ratioEligible']:
            continue
        B.require(case['id'] in old, 'Historical report lacks selected case')
        prior = old[case['id']]
        B.require(case['point'] == prior['point'] and case['sourceGroup'] == prior['sourceGroup'],
                  'Comparison catalog point differs')
        old_ref, new_ref = before['reference'], after['reference']
        old_ratio = prior['stats'][old_role]['medianMs'] / prior['stats'][old_ref]['medianMs']
        new_ratio = case['stats'][new_role]['medianMs'] / case['stats'][new_ref]['medianMs']
        ratio = new_ratio / old_ratio
        rows.append(dict(id=case['id'], normalizedAfterOverBefore=ratio,
            timeReductionPercent=100 * (1 - ratio), sameReferenceArtifact=
            prior['artifacts'][old_ref] == case['artifacts'][new_ref],
            flagged=prior['flagged'] or case['flagged']))
    ratio = gm(r['normalizedAfterOverBefore'] for r in rows)
    return dict(beforeRole=old_role, afterRole=new_role, crossCampaign=cross_campaign,
        caseCount=len(rows), normalizedAfterOverBeforeGeomean=ratio,
        timeReductionPercent=100 * (1 - ratio), cases=rows,
        worstRegressions=sorted(rows, key=lambda r: -r['normalizedAfterOverBefore'])[:10],
        scope='Cross-campaign normalization by each report reference; no paired significance claim.'
              if cross_campaign else 'Same-campaign ratios of role medians; no paired significance claim.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--pair', nargs=2, action='append', default=[], metavar=('BEFORE', 'AFTER'))
    parser.add_argument('--historical', type=Path)
    parser.add_argument('--historical-pair', nargs=2, action='append', default=[], metavar=('OLD', 'NEW'))
    a = parser.parse_args()
    B.require(not a.out.exists(), 'Fresh analysis output required')
    B.require(not a.historical_pair or a.historical, 'Historical report required')
    current = analyze(a.report)
    historical = analyze(a.historical) if a.historical else None
    pairs = [compare(current, current, x, y, False) for x, y in a.pair]
    pairs += [compare(historical, current, x, y, True) for x, y in a.historical_pair]
    result = dict(kind='phase186-retained-runtime-analysis', method=C.pin(__file__),
        programsExecuted=False, current=current, comparisons=pairs,
        historical=historical if historical else None)
    a.out.parent.mkdir(parents=True, exist_ok=True)
    B.save(a.out, result, fresh=True)
    print(json.dumps(dict(analysis=str(a.out), validated=current['oracleRevalidated'],
        flaggedCases=current['flaggedCases'], comparisons=[dict(before=p['beforeRole'],
        after=p['afterRole'], ratio=p['normalizedAfterOverBeforeGeomean']) for p in pairs])))


if __name__ == '__main__':
    main()

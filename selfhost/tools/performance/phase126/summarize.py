"""Read-only paired-screen statistics; optional final outer-guard accounting."""
import argparse
import datetime
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
MANIFEST = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
ROLES = ('candidate', 'baseline', 'upstream')
RATIOS = {'candidateOverBaseline': ('candidate', 'baseline'),
          'candidateOverUpstream': ('candidate', 'upstream'),
          'baselineOverUpstream': ('baseline', 'upstream')}


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def gm(values):
    return math.exp(statistics.mean(math.log(x) for x in values)) if values else None


def spread(values):
    median = statistics.median(values)
    return dict(count=len(values), minimum=min(values), median=median, maximum=max(values),
                rangeOverMedian=(max(values)-min(values))/median if median else None,
                medianAbsoluteDeviation=statistics.median(abs(x-median) for x in values))


def deficit(ratios):
    return dict(points=len(ratios), geometricRatio=gm(ratios),
                positiveLogSlowdown=statistics.mean(max(math.log(x), 0) for x in ratios) if ratios else None,
                thresholds={str(t): sum(x > t for x in ratios) for t in (1, 1.1, 2, 5, 10)})


def variants_summary(path, raw, cases):
    """The matched-ablation runner has arbitrary roles and may lack upstream."""
    roles = list(raw['variants'])
    reference = 'baseline' if 'baseline' in roles else roles[0]
    names = list(dict.fromkeys(r['name'] for r in raw['rows']))
    assert set(names) <= set(cases)
    result = dict(file=str(path.resolve()), observations=len(raw['rows']), cases=[], reference=reference)
    lookup = {}
    for row in raw['rows']:
        key = (row['name'],row['role'],row['round'])
        assert key not in lookup and row['role'] in roles and math.isfinite(row['elapsedMs']) and row['elapsedMs'] >= 0
        for field in ('stdout','stderr'):
            assert pin(row[field]['file']) == row[field]
        lookup[key] = row
    for name in names:
        rounds = sorted(r['round'] for r in raw['rows'] if r['name']==name and r['role']==reference)
        rows = [lookup[(name,role,rnd)] for rnd in rounds for role in roles]
        assert rounds and len(rows)==sum(r['name']==name for r in raw['rows'])
        assert all(r['command'][1:]==rows[0]['command'][1:] for r in rows)
        samples = {role:[lookup[(name,role,rnd)]['elapsedMs'] for rnd in rounds] for role in roles}
        for role in roles:
            assert all(lookup[(name,role,rnd)]['binary']==raw['variants'][role]['cases'][name]['binary'] for rnd in rounds)
        medians = {role:statistics.median(xs) for role,xs in samples.items()}
        row = dict(name=name,family=cases[name]['family'],ratioEligible=cases[name]['ratioEligible'],
                   samplesMs=samples,mediansMs=medians,spreadMs={role:spread(xs) for role,xs in samples.items()})
        if row['ratioEligible']:
            assert all(x>0 for xs in samples.values() for x in xs)
            row['pairwiseRatios'] = {a:{b:medians[a]/medians[b] for b in roles} for a in roles}
            row['roundRatiosToReference'] = {role:[samples[role][i]/samples[reference][i] for i in range(len(rounds))] for role in roles}
            row['ratioSpread'] = {role:spread(xs) for role,xs in row['roundRatiosToReference'].items()}
        result['cases'].append(row)
    timed = [r for r in result['cases'] if r['ratioEligible']]
    eligible = {n for n,c in cases.items() if c['ratioEligible']}
    result.update(timedCases=len(timed),population='full-original45' if set(names)==set(cases) else
                  'original44-timed-only' if set(names)==eligible else 'partial-original-subset',
                  missingOriginalCases=sorted(set(cases)-set(names)),missingOriginalTimedCases=sorted(eligible-set(names)),
                  pairwiseGeometricRatios={a:{b:gm([r['pairwiseRatios'][a][b] for r in timed]) for b in roles} for a in roles},
                  deficitAgainstReference={role:deficit([r['pairwiseRatios'][role][reference] for r in timed]) for role in roles},
                  scope='Same-run matched existing products; arbitrary roles. Relative deficit uses the explicitly named reference, not an inferred upstream denominator. No broad-parity inference from a subset.')
    return result


def summarize(path, cases):
    raw = read(path)
    assert raw['complete'] and raw['rows'] and all(r.get('correct') and r['status'] == 0 for r in raw['rows'])
    if 'variants' in raw:
        return variants_summary(path,raw,cases)
    names = list(dict.fromkeys(r['name'] for r in raw['rows']))
    assert set(names) <= set(cases), 'Unknown case: supply only the unchanged original45 population'
    lookup = {}
    for row in raw['rows']:
        key = (row['name'], row['role'], row['round'])
        assert key not in lookup and row['role'] in ROLES, 'Duplicate observation/unknown role'
        assert math.isfinite(row['elapsedMs']) and row['elapsedMs'] >= 0
        # Small output receipts are authenticated; no binaries are executed/read.
        for field in ('stdout', 'stderr'):
            assert pin(row[field]['file']) == row[field], 'Changed output receipt'
        lookup[key] = row
    result = dict(file=str(path.resolve()), observations=len(raw['rows']), cases=[], timedCases=0)
    all_rounds = None
    for name in names:
        rounds = sorted(r['round'] for r in raw['rows'] if r['name'] == name and r['role'] == 'candidate')
        assert rounds and (all_rounds is None or rounds == all_rounds), 'Unmatched case rounds'
        all_rounds = rounds
        rows = [lookup[(name, role, rnd)] for rnd in rounds for role in ROLES]
        assert len(rows) == sum(r['name'] == name for r in raw['rows'])
        assert all(r['command'][1:] == rows[0]['command'][1:] for r in rows), 'Unequal runtime/count arguments'
        binaries = {}
        for role in ROLES:
            bins = [lookup[(name, role, rnd)]['binary'] for rnd in rounds]
            assert all(b == bins[0] for b in bins), 'Product changed between rounds'
            binaries[role] = bins[0]
        samples = {role: [lookup[(name, role, rnd)]['elapsedMs'] for rnd in rounds] for role in ROLES}
        medians = {role: statistics.median(xs) for role, xs in samples.items()}
        row = dict(name=name, family=cases[name]['family'], ratioEligible=cases[name]['ratioEligible'],
                   rounds=rounds, binaries=binaries, samplesMs=samples, mediansMs=medians,
                   spreadMs={role: spread(xs) for role, xs in samples.items()})
        if row['ratioEligible']:
            assert all(value > 0 for xs in samples.values() for value in xs), 'Zero timed observation; do not silently exclude'
            row.update({key: medians[a] / medians[b] for key, (a, b) in RATIOS.items()})
            row['roundRatios'] = {key: [samples[a][i]/samples[b][i] for i in range(len(rounds))]
                                  for key, (a, b) in RATIOS.items()}
            row['ratioSpread'] = {key: spread(xs) for key, xs in row['roundRatios'].items()}
        result['cases'].append(row)
    timed = [r for r in result['cases'] if r['ratioEligible']]
    eligible = {name for name, case in cases.items() if case['ratioEligible']}
    covered = {r['name'] for r in timed}
    coverage = ('full-original45' if set(names) == set(cases) else
                'original44-timed-only' if set(names) == eligible else 'partial-original-subset')
    result.update(timedCases=len(timed), population=coverage, originalCases=len(cases),
                  originalTimedCases=len(eligible), missingOriginalCases=sorted(set(cases)-set(names)),
                  missingOriginalTimedCases=sorted(eligible-covered), fullTimedPopulation=covered == eligible,
                  correctnessObservationCount=len(raw['rows']), rounds=all_rounds)
    for key in RATIOS:
        result[key] = gm([r[key] for r in timed])
    result['deficit'] = {role: deficit([r[role+'OverUpstream'] for r in timed]) for role in ('candidate','baseline')}
    result['countsAgainstBaseline'] = dict(faster=sum(r['candidateOverBaseline'] < 1 for r in timed),
        equal=sum(r['candidateOverBaseline'] == 1 for r in timed), slower=sum(r['candidateOverBaseline'] > 1 for r in timed))
    result['roundGeometricRatios'] = [dict(round=rnd, **{key: gm([r['roundRatios'][key][i] for r in timed])
        for key in RATIOS}) for i, rnd in enumerate(all_rounds)]
    result['summedMedianBatchMs'] = {role: sum(r['mediansMs'][role] for r in timed) for role in ROLES}
    result['positiveExcessBatchMs'] = {role: sum(max(r['mediansMs'][role]-r['mediansMs']['upstream'],0) for r in timed)
                                       for role in ('candidate','baseline')}
    families = sorted({r['family'] for r in timed})
    result['families'] = [dict(family=family, cases=[r['name'] for r in timed if r['family']==family],
        **{key: gm([r[key] for r in timed if r['family']==family]) for key in RATIOS}) for family in families]
    result['equalObservedFamilyRatios'] = {key: gm([r[key] for r in result['families']]) for key in RATIOS}
    result['scope'] = 'Same-screen medians/rounds only. Subset metrics are not original44 parity. Spread is descriptive, not a confidence interval. Product pins are retained; small output receipts are verified; no fresh oracle or binary execution.'
    return result


def category(command):
    text = ' '.join(command)
    for needles, name in [(['qualification'], 'native qualification'),
        (['timing-run','cost-v2.mjs'], 'compiler timing'),
        (['check-api','api-plan'], 'checked API acquisition'),
        (['emit-integrated','emit-plan'], 'checked program emission'),
        (['screen','repeat-products'], 'program execution and correctness')]:
        if any(needle in text for needle in needles):
            return name
    return 'controls, builds and diagnostics'


def accounting(start, end):
    rows = []
    for path in sorted((ROOT/'selfhost/build/phase126').glob('*guard*/process.json')):
        row = read(path)
        assert 'finished' in row, 'Accounting requires every discovered outer guard to finish: ' + str(path)
        rows.append(dict(receipt=pin(path), **row))
    assert rows, 'No outer guard receipts'
    rows.sort(key=lambda row: row['started'])
    assert all(a['finished'] <= b['started']+.01 for a,b in zip(rows,rows[1:])), 'Overlapping outer guard intervals'
    start = datetime.datetime.fromisoformat(start).timestamp()
    end = datetime.datetime.fromisoformat(end).timestamp() if end else max(r['finished'] for r in rows)
    assert start <= min(r['started'] for r in rows) and end >= max(r['finished'] for r in rows)
    groups = {}
    for row in rows:
        group = groups.setdefault(category(row['command']), dict(attempts=0, failures=0, wallSeconds=0, failedWallSeconds=0))
        group['attempts'] += 1
        group['wallSeconds'] += row['wallSeconds']
        if not row['complete']:
            group['failures'] += 1
            group['failedWallSeconds'] += row['wallSeconds']
    return dict(complete=True, started=start, measuredThrough=end, elapsedWallSeconds=end-start,
        guardedWallSeconds=sum(r['wallSeconds'] for r in rows), attempts=len(rows),
        failures=sum(not r['complete'] for r in rows), categories=groups, rows=rows,
        maximumTreeRssBytes=max(r['peakTreeRssBytes'] for r in rows),
        minimumAvailableBytes=min(r['minimumAvailableBytes'] for r in rows),
        directoriesWithoutProcessReceipt=[str(p) for p in sorted((ROOT/'selfhost/build/phase126').glob('*guard*'))
                                          if p.is_dir() and not (p/'process.json').exists()],
        scope='Finished exclusive outer guards, including failures once. No child-duration double count. Default endpoint is last finished guard; supply campaign-end for final campaign wall time. Unmetered editing/reasoning is not inference-time accounting.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--screen', type=Path, action='append', required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--account-guards', action='store_true')
    parser.add_argument('--campaign-start', default='2026-10-22T22:59:00+00:00')
    parser.add_argument('--campaign-end')
    args = parser.parse_args()
    assert not args.out.exists(), 'Fresh summary output required'
    assert len(set(p.resolve() for p in args.screen)) == len(args.screen), 'Repeated screen'
    cases = {r['name']: r for r in read(MANIFEST)['cases']}
    result = dict(complete=True, targetsRun=False, inputs=[pin(__file__),pin(MANIFEST),
        pin(ROOT/'selfhost/tools/performance/phase123/summarize.py'),
        pin(ROOT/'selfhost/tools/performance/phase125/accounting.py'), *[pin(p) for p in args.screen]],
        screens=[summarize(p,cases) for p in args.screen],
        scope='Independent screen populations, never pooled across attempts. No benchmark/compiler execution or report modification. No broad improvement claim follows from a three-case screen.')
    if args.account_guards:
        result['guardAccounting'] = accounting(args.campaign_start,args.campaign_end)
    for original in result['inputs']:
        assert pin(original['file']) == original, 'Input changed during summary'
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result,stream,indent=2)
        stream.write('\n')
    print(json.dumps([{k:r[k] for k in ('file','population','timedCases','candidateOverBaseline',
        'candidateOverUpstream','pairwiseGeometricRatios') if k in r} for r in result['screens']],indent=2))


if __name__ == '__main__':
    main()

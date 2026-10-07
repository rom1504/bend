#!/usr/bin/env python3
"""Compact data-only analysis of a balanced genuine-B2/TS broad campaign."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def identity(path):
    path = Path(path).resolve(strict=True)
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def read_pin(row):
    assert identity(row['file']) == row
    return json.loads(Path(row['file']).read_text())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('report', type=Path)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
r = json.loads(a.report.read_text())
assert r['complete'] and r['pass'] and r['mode'] == 'clean' and not r['failures']
assert r['successfulWorkers'] == r['expectedWorkers'] == len(r['rows']) == 207
plan = read_pin(r['config'])
binding = read_pin(plan['imageBindings'])
assert plan['rounds'] == 3 and plan['roles'] == ['baseline', 'candidate', 'typescript']
assert len(plan['cases']) == len(r['statistics']) == 23
assert all(v['kind'] == 'direct' for v in binding['roles'].values())
clocks = ['firstRequestMs', 'importApiAndFirstMs']
pairs = [('candidate', 'typescript'), ('baseline', 'typescript'), ('candidate', 'baseline')]
ratios = {clock:{'/'.join(pair):[] for pair in pairs} for clock in clocks}
columns = ['source'] + [clock + ':' + role for clock in clocks for role in plan['roles']]
matrix, orders = [], set()
for case in plan['cases']:
    name = case['id']
    rows = [row for row in r['rows'] if row['case'] == name]
    assert len(rows) == 9 and all(row['success'] for row in rows)
    order = tuple(tuple(row['role'] for row in rows if row['sample'] == i) for i in range(3))
    assert all(set(o) == set(plan['roles']) for o in order)
    assert all(len({o[position] for o in order}) == 3 for position in range(3))
    orders.add(order)
    stats = r['statistics'][name]
    for values in stats.values():
        assert all(len(values[c]['samples']) == 3 and
                   statistics.median(values[c]['samples']) == values[c]['median'] for c in clocks)
    matrix.append([name] + [stats[role][clock]['median'] for clock in clocks for role in plan['roles']])
    for clock in clocks:
        for numerator, denominator in pairs:
            ratios[clock][numerator+'/'+denominator].append(
                dict(source=name, ratio=stats[numerator][clock]['median']/stats[denominator][clock]['median']))
summary = {}
for clock, comparisons in ratios.items():
    summary[clock] = {}
    for label, values in comparisons.items():
        summary[clock][label] = dict(
            geometricMean=math.exp(statistics.mean(math.log(v['ratio']) for v in values)),
            min=min(values, key=lambda v:v['ratio']), max=max(values, key=lambda v:v['ratio']),
            belowOne=sum(v['ratio'] < 1 for v in values),
            atOrAboveOne=[v for v in values if v['ratio'] >= 1])
workers = [row['execution'] for row in r['rows']]
intervals = sorted((w['started'],w['finished']) for w in workers)
assert all(end <= later for (_,end),(later,_) in zip(intervals,intervals[1:]))
result = dict(kind='phase63-balanced-b2-broad-summary', dataOnly=True, targetExecuted=False,
    producer=identity(__file__), report=identity(a.report), plan=r['config'], binding=plan['imageBindings'],
    roles=binding['roles'], pass_=True, sourceCount=23, rounds=3, workers=207,
    roleOrders=[list(map(list, order)) for order in orders],
    clocks='Source load/check/library emission in firstRequestMs; importApiAndFirstMs additionally includes host/API import. Prepared caches; fresh process per sample.',
    weighting='Median of three samples per role/source, then equal-source geometric mean of ratios. Forty-five runtime points are not forty-five independent compilation sources.',
    coverage=r['coverage'], summary=summary, matrixColumns=columns, matrix=matrix,
    timing=dict(campaignWallSeconds=r['wallSeconds'],measurementStageSeconds=r['measurementStageSeconds'],
                closedWorkerWallSeconds=sum(w['wallSeconds'] for w in workers),
                targetIntervalUnionSeconds=sum(end-start for start,end in intervals),
                firstWorkerStart=intervals[0][0],lastWorkerFinish=intervals[-1][1],
                maxTreeRssBytes=max(w['peakTreeRssBytes'] for w in workers)),
    limitations='Every emitted module passes its full qualified raw-byte oracle. No fresh generated-program runtime execution; final semantic/self-host/release gates remain separate. Ratios describe this frozen 23-source catalog and machine, not all possible Bend programs. Three samples do not establish statistical significance.')
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out),summary={clock:{label:{k:v for k,v in value.items() if k!='atOrAboveOne'}
                     for label,value in comparisons.items()} for clock,comparisons in summary.items()},timing=result['timing'])))

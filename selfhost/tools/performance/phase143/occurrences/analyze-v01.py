"""Data-only grouped derivation of the frozen occurrence predicate screen."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import statistics


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def stats(values):
    return dict(count=len(values), minimum=min(values), median=statistics.median(values),
                maximum=max(values), geometricMean=math.exp(statistics.mean(math.log(v) for v in values)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    data = json.loads(args.report.read_text())
    assert data['complete'] and data['semanticComplete'] and data['timingComplete']
    assert data['controlsPassed'] == 47 and data['semanticQueriesPassed'] == 72
    queries = {q['id']: q for q in data['queries']}
    timings = data['timings']
    assert len(timings) == len(queries) * 6

    def group(rows):
        return dict(pairedRounds=len(rows), queries=len({r['query'] for r in rows}),
                    ratios={mode: stats([r['ratios'][mode] for r in rows]) for mode in ['range', 'summary']})

    grouped = []
    for field in ['left', 'scenario', 'subject']:
        for value in sorted({q[field] for q in queries.values()}):
            grouped.append(dict(field=field, value=value, **group([r for r in timings if queries[r['query']][field] == value])))
    matrix = [dict(left=n, scenario=s, **group([r for r in timings if queries[r['query']]['left'] == n and queries[r['query']]['scenario'] == s]))
              for n in [1, 4, 64] for s in ['empty-env', 'actual-child-argument', 'env-first', 'env-last']]
    per_query = []
    for name, query in queries.items():
        rows = [r for r in timings if r['query'] == name]
        per_query.append(dict(query=query, **group(rows)))
    floors = {}
    for mode in ['original', 'range', 'summary']:
        seconds = [r['seconds'] for t in timings for r in t['rows'] if r['mode'] == mode]
        floors[mode] = dict(**stats(seconds), under100Microseconds=sum(t < .0001 for t in seconds),
                            under1Millisecond=sum(t < .001 for t in seconds), sumSeconds=sum(seconds))
    result = dict(kind='phase143-occurrence-grouped-analysis', complete=True, targetsRun=False,
                  inputs=[pin(__file__), pin(args.report)], controls=47, semanticQueries=72,
                  pairedRounds=len(timings), individualModeMeasurements=sum(len(t['rows']) for t in timings),
                  observerSeconds=data['elapsedSeconds'], subjects=data['subjects'], groups=grouped,
                  countScenarioMatrix=matrix, perQuery=per_query, measuredIntervalSeconds=floors,
                  worstRangeQueryMedian=max(row['ratios']['range']['median'] for row in per_query),
                  scope='Descriptive grouped ratios from one hosted checked-API process. Constructed fresh-ID/env schedules on six real compacted bodies. No confidence intervals, production-frequency weighting, full-QBE gate or native/compiler speed claim.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=pin(args.out), worstRangeQueryMedian=result['worstRangeQueryMedian'])))


if __name__ == '__main__':
    main()

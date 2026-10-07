#!/usr/bin/env python3
"""Compact, equal-source summary of the audited Phase62 profile data."""
import argparse
import collections
import hashlib
import json
import math
import statistics
from pathlib import Path


def identity(file):
    p = Path(file).resolve()
    return dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)


def table(values, field='percent'):
    return {v['name']: v[field] for v in values}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--analysis', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    source = identity(a.analysis)
    data = json.loads(a.analysis.read_text())
    assert data['complete'] and data['pass'] and len(data['rows']) == 92
    rows = {(r['mode'], r['case'], r['role']): r for r in data['rows']}
    cases = list(dict.fromkeys(r['case'] for r in data['rows']))
    assert len(cases) == 23
    means = {role: collections.Counter() for role in ['b2', 'typescript']}
    unions = {kind: collections.Counter() for kind in ['cpuCounts', 'allocation']}
    records, absent, refused = [], [], []
    for case in cases:
        row = dict(case=case, cpuCounts={}, allocation={})
        for role in ['b2', 'typescript']:
            cpu = rows['cpu', case, role]
            view = cpu['views']['counts']
            row['cpuCounts'][role] = dict(sampleEvents=view['sampleEvents'], exclusiveStagePercents=table(view['exclusiveStages']))
            row['cpuCounts'][role]['weightedStatus'] = cpu['weightedStatus']
            if cpu['weightedStatus'] == 'refused': refused.append(dict(case=case, role=role, accounting=cpu['weightedAccounting']))
            for name, percent in table(view['exclusiveStages']).items(): means[role][name] += percent/23
            alloc = rows['allocation', case, role]['views']['bytes']
            row['allocation'][role] = dict(bytes=alloc['total'], exclusiveStagePercents=table(alloc['exclusiveStages']), absentTreeNodes=alloc['absentTreeNodes'])
            if alloc['absentTreeNodes']['weight']: absent.append(dict(case=case, role=role, **alloc['absentTreeNodes']))
            if role == 'b2':
                row['cpuCounts'][role]['ancestorUnionPercents'] = table(view['inclusiveAncestorUnions'])
                row['allocation'][role]['ancestorUnionPercents'] = table(alloc['inclusiveAncestorUnions'])
                for kind, values in [('cpuCounts', view), ('allocation', alloc)]:
                    for name, percent in table(values['inclusiveAncestorUnions']).items(): unions[kind][name] += percent/23
        row['allocation']['b2OverTS'] = row['allocation']['b2']['bytes']/row['allocation']['typescript']['bytes']
        records.append(row)
    ratios = [r['allocation']['b2OverTS'] for r in records]
    result = dict(kind='phase62-profile-compact-summary', complete=True, source=source, producer=identity(__file__),
        targetExecuted=False, rows=records, meanCpuCountStagePercent=means, meanB2AncestorUnionPercent=unions,
        allocationComparison=dict(equalSourceGeometricMean=math.exp(statistics.mean(map(math.log, ratios))),
            minimum=min(ratios), maximum=max(ratios), belowTS=sum(v<1 for v in ratios), aboveTS=sum(v>1 for v in ratios)),
        weightedCpuRefusals=refused, absentAllocationTreeNodes=absent,
        scope='Arithmetic mean of per-source CPU count percentages and geometric mean of per-source cumulative sampled-allocation ratios. CPU weighting refusals remain refused. Counts are not wall time; allocation is not peak memory. Ancestor unions overlap and cannot be added to each other or to exclusive partitions.')
    result['pass'] = True
    assert identity(a.analysis) == source
    out = a.out.resolve()
    assert not out.exists() and '/selfhost/build/phase62/' in str(out)
    out.mkdir(parents=True)
    (out/'summary.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(out), bytes=(out/'summary.json').stat().st_size)))


if __name__ == '__main__':
    main()

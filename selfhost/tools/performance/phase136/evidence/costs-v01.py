#!/usr/bin/env python3
"""Collect completed Phase136 execution receipts without adding nested clocks."""
import argparse
import importlib.util
import json
from pathlib import Path

SPEC = importlib.util.spec_from_file_location('phase136_evidence', Path(__file__).with_name('common-v01.py'))
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


def category(path):
    name = str(path.relative_to(C.ROOT))
    if 'cold-baseline' in name:
        return 'qualified-cold-baseline'
    if 'native' in name and ('guard' in name or 'phase134' in name):
        return 'diagnostic-image-acquisition'
    if 'profile' in name:
        return 'profiling-and-analysis'
    if any(word in name for word in ('api', 'bridge', 'finite', 'query')):
        return 'source-and-correctness-gates'
    if any(word in name for word in ('staged', 'overhead', 'ordinary', 'stage-run')):
        return 'native-diagnostic-requests'
    return 'other-preserved-execution'


def union_seconds(intervals):
    total, end = 0.0, None
    for start, finish in sorted(intervals):
        total += max(0.0, finish - max(start, end if end is not None else start))
        end = max(finish, end if end is not None else finish)
    return total


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    a = parser.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(C.ROOT / 'implementation/phase136'):
        raise ValueError('Fresh Phase136 JSON output required')
    paths = sorted({p.resolve() for root in C.roots() if root.exists()
                    for p in root.rglob('*.json') if p.name in ('process.json', 'report.json')})
    guards, receipts, problems = [], [], []
    clock_keys = ['seconds', 'wallSeconds', 'totalSeconds', 'nativeSeconds',
                  'nativeWallSeconds', 'emitAndQbeSeconds', 'cpuSeconds',
                  'userSeconds', 'systemSeconds', 'peakRssKiB', 'peakRssBytes',
                  'peakTreeRssBytes', 'returncode', 'exitCode', 'status']
    for path in paths:
        if path.stat().st_size > 8 * 1024**2:
            problems.append(dict(file=str(path), reason='Oversized receipt; excluded from clock collection'))
            continue
        try:
            r = json.loads(path.read_text())
        except (UnicodeError, json.JSONDecodeError) as error:
            problems.append(dict(file=str(path), reason=str(error)))
            continue
        identity = C.pin(path)
        clocks = {k: r[k] for k in clock_keys if isinstance(r.get(k), (int, float))}
        entry = dict(receipt=identity, category=category(path), complete=r.get('complete'),
                     kind=r.get('kind'), clocks=clocks)
        if path.name == 'process.json' and isinstance(r.get('started'), (int, float)):
            entry.update(started=r['started'], finished=r.get('finished'),
                         command=r.get('command'), timedOut=r.get('timedOut'))
            guards.append(entry)
        else:
            nested = []
            for field in ('rows', 'jobs'):
                for i, row in enumerate(r.get(field, [])):
                    if isinstance(row, dict):
                        values = {k: row[k] for k in clock_keys if isinstance(row.get(k), (int, float))}
                        if values:
                            nested.append(dict(field=field, index=i,
                                name=row.get('name', row.get('label')), clocks=values))
            if nested:
                entry['nestedClocksNotAdded'] = nested
            if clocks or nested:
                receipts.append(entry)
    finished = [r for r in guards if isinstance(r.get('finished'), (int, float))]
    intervals = [(r['started'], r['finished']) for r in finished]
    groups = {}
    for r in finished:
        group = groups.setdefault(r['category'], dict(guardCount=0, guardWallSeconds=0.0))
        group['guardCount'] += 1
        group['guardWallSeconds'] += r['clocks'].get('wallSeconds', r['finished'] - r['started'])
    result = dict(kind='phase136-research-cost-receipts', complete=not problems,
        targetsRun=False, method=C.pin(__file__), inventoryMethod=C.pin(C.__file__),
        guards=guards, nestedReceipts=receipts, collectionProblems=problems,
        observedGuardWallSeconds=sum(r['clocks'].get('wallSeconds', r['finished'] - r['started']) for r in finished),
        observedGuardIntervalUnionSeconds=union_seconds(intervals), categories=groups,
        unfinishedGuardCount=len(guards) - len(finished),
        missingCosts=['Agent tokens/quota/money were not exposed by these execution receipts.',
                      'Source reasoning, unattended time and unguarded metadata work are not measured here.'],
        scope='Finished failed and successful guard receipts both count. Guard wall sum is resource-lane exposure, not researcher elapsed time. Interval union covers observed guarded work only. Nested native/stage/tool clocks are preserved separately and never added to guard totals. No monetary or quota estimate is invented.')
    for row in [*guards, *receipts]:
        C.verify(row['receipt'])
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ['complete', 'observedGuardWallSeconds',
        'observedGuardIntervalUnionSeconds', 'unfinishedGuardCount', 'targetsRun']}))


if __name__ == '__main__':
    main()

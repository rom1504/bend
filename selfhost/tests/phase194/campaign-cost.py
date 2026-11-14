#!/usr/bin/env python3
"""Adapt Phase193 accounting: count terminal outer guards once, including failures."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/build/phase194'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def category(name):
    for prefix in ('float-', 'predicate-', 'combined-', 'diag-baseline-', 'diag-combined-'):
        if name.startswith(prefix):
            name = name[len(prefix):]
            break
    if name.startswith(('native-image', 'native-self', 'native-reproduction')):
        return 'compiler-image-builds'
    if name.startswith(('native45', 'native64', 'runtime10', 'hosted-native', 'native-generations')):
        return 'native-oracle-and-qualification'
    if name.startswith('compiler-cost'):
        return 'compiler-request-planning' if '-plan' in name else 'compiler-request-timing'
    if 'api' in name:
        return 'checked-api-acquisition'
    if 'controls' in name:
        return 'adversarial-controls'
    if 'profile' in name:
        return 'compiler-profiling'
    if 'runtime' in name or name.startswith('timing'):
        return 'program-runtime'
    if name.startswith(('dev-', 'build', 'emit', 'references')) or any(part in name for part in ('-emit', '-build', '-references')):
        return 'development-products'
    if 'check' in name:
        return 'source-checking'
    return 'offline-or-other'


def total(rows):
    return dict(jobs=len(rows), failed=sum(row['returncode'] != 0 for row in rows),
        wallSeconds=sum(row['wallSeconds'] for row in rows),
        peakRssBytes=max((row['peakTreeRssBytes'] for row in rows), default=0),
        peakRunAllocatedBytes=max((row['peakRunAllocatedBytes'] for row in rows), default=0),
        minimumDiskFreeBytes=min((row['minimumDiskFreeBytes'] for row in rows), default=None))


def collect():
    rows, pending = [], []
    for path in sorted(BUILD.glob('*-guard/process.json')):
        receipt = pin(path)
        data = json.loads(path.read_text())
        assert pin(path) == receipt, 'Guard changed while reading: '+str(path)
        name = path.parent.name[:-6]
        if data.get('finished') is None or data.get('returncode') is None:
            pending.append(dict(job=name, receipt=receipt))
            continue
        rows.append(dict(job=name, category=category(name), receipt=receipt,
            **{key: data[key] for key in ['complete', 'returncode', 'wallSeconds',
                'peakTreeRssBytes', 'peakRunAllocatedBytes', 'minimumDiskFreeBytes']}))
    # A guard directory without its first receipt is also unfinished.
    pending.extend(dict(job=path.name[:-6], receipt=None)
        for path in sorted(BUILD.glob('*-guard')) if not (path/'process.json').exists())
    return rows, pending


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--plan-only', action='store_true')
    args = parser.parse_args()
    rows, pending = collect()
    result = dict(kind='phase194-outer-guard-cost', complete=not pending,
        programsExecuted=False, capturedUTC=datetime.now(timezone.utc).isoformat(),
        method=pin(Path(__file__)), predecessor=pin(ROOT/'selfhost/tests/phase193/campaign-cost.py'),
        total=total(rows), byCategory={name: total([r for r in rows if r['category'] == name])
            for name in sorted({r['category'] for r in rows})},
        jobs=rows, unfinished=pending,
        scope='Each top-level outer guard once; nested process receipts excluded. '
              'Finished failures are included even when complete=false. Guard wall is not total '
              'research time, agent compute, billed quota or a compiler throughput measurement. '
              'Unguarded metadata analysis, retention and orchestration are excluded. '
              'Resource fields are maxima/minima, not cumulative storage.')
    if args.plan_only:
        print(json.dumps(dict(planOnly=True, **result)))
        return
    assert args.out is not None, '--out is required unless --plan-only'
    assert not pending, 'Wait for unfinished outer guards'
    assert collect() == (rows, pending), 'Guard set changed during accounting'
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(result['total']))


if __name__ == '__main__':
    main()

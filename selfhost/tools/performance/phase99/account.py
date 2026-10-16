#!/usr/bin/env python3
"""Account completed guard intervals without guessing uninstrumented work or quota."""
import argparse
from collections import defaultdict
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase99'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    grouped = defaultdict(lambda: dict(jobs=0, summedGuardSeconds=0))
    jobs = {}; incomplete = []
    for path in sorted(BUILD.rglob('process.json')):
        row = json.loads(path.read_text())
        if not row.get('complete') or not all(k in row for k in ['started', 'finished', 'wallSeconds']):
            incomplete.append(pin(path)); continue
        key = (row['started'], row['finished'], tuple(row['command']))
        if key in jobs:
            jobs[key]['receiptAliases'].append(pin(path)); continue
        group = path.relative_to(BUILD).parts[0]
        jobs[key] = dict(receipt=pin(path), receiptAliases=[], group=group, **row)
        grouped[group]['jobs'] += 1
        grouped[group]['summedGuardSeconds'] += row['wallSeconds']
    rows = sorted(jobs.values(), key=lambda r: (r['started'], -r['finished']))
    union = 0; end = None; overlaps = []
    for row in rows:
        start, stop = row['started'], row['finished']
        if end is not None and start < end:
            overlaps.append(dict(receipt=row['receipt'], overlapSeconds=min(stop, end)-start))
        union += max(0, stop - max(start, end if end is not None else start))
        end = max(stop, end if end is not None else stop)
    result = dict(complete=True, targetsRun=False, method=pin(Path(__file__).resolve()),
        jobs=len(rows), summedGuardSeconds=sum(r['wallSeconds'] for r in rows),
        unionGuardSeconds=union, targetSpanSeconds=rows[-1]['finished']-rows[0]['started'] if rows else 0,
        peakTreeRssBytes=max((r.get('peakTreeRssBytes', 0) for r in rows), default=0),
        nonzeroExits=sum(r.get('returncode') != 0 for r in rows),
        resourceStops=[r['receipt'] for r in rows if r.get('stoppedFor') or r.get('interrupted')],
        overlaps=overlaps, incomplete=incomplete, groups=dict(grouped), records=rows,
        scope='Completed unique guard intervals, including expected negative checks and failed attempts. '
              'Union avoids counting nested supervisors twice; overlapping intervals require inspection, '
              'not an automatic claim of simultaneous independent targets. Groups follow output directories. '
              'Planning, source review, unguarded packaging and publication are not attributed to coding or idle time. '
              'Token and quota usage are unavailable.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['records', 'groups', 'scope', 'method']}))


if __name__ == '__main__': main()

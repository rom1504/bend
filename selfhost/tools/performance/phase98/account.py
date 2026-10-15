#!/usr/bin/env python3
"""Summarize retained guard intervals; no targets, quota inference or log changes."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=Path('selfhost/build/phase98'))
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    start = datetime(2026, 10, 15, 20, 7, 27, tzinfo=timezone.utc).timestamp()
    now = time.time()
    rows, intervals, missing = [], [], []
    groups = defaultdict(lambda: dict(processes=0, recordedSeconds=0, peakRssBytes=0))
    seen = set()
    for path in sorted(a.root.rglob('process.json')):
        data = path.read_bytes()
        r = json.loads(data)
        if r.get('started', 0) < start:
            continue
        identity = (r['started'], tuple(r['command']))
        if identity in seen:
            continue
        seen.add(identity)
        row = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(),
                   **{k:r.get(k) for k in ['started', 'finished', 'wallSeconds',
                       'complete', 'returncode', 'stoppedFor', 'peakTreeRssBytes']})
        rows.append(row)
        if r.get('finished') is None:
            missing.append(str(path))
            continue
        intervals.append((max(start, r['started']), min(now, r['finished'])))
        group = groups[path.relative_to(a.root).parts[0]]
        group['processes'] += 1
        group['recordedSeconds'] += r['wallSeconds']
        group['peakRssBytes'] = max(group['peakRssBytes'], r['peakTreeRssBytes'])
    merged = []
    for begin, end in sorted(intervals):
        if merged and begin <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([begin, end])
    report = dict(kind='phase98-retained-execution-accounting', complete=True,
        generated=now, phaseStart=start, elapsedSeconds=now-start,
        endedGuardIntervals=len(intervals), missingEndRecords=missing,
        recordedGuardSeconds=sum(r['wallSeconds'] or 0 for r in rows),
        unionGuardSeconds=sum(end-begin for begin, end in merged),
        exitStatuses=dict(Counter(str(r['returncode']) for r in rows)),
        maximumRecordedRssBytes=max((r['peakTreeRssBytes'] or 0 for r in rows), default=0),
        groups=dict(sorted(groups.items(), key=lambda item:-item[1]['recordedSeconds'])),
        rows=rows, scope='Retained root guard wall intervals only, not CPU time, tokens or quota. '
        'Expected negative tests also have nonzero exits. Missing final records are listed without '
        'inventing their durations. Unguarded preparation, analysis, server interruption and archival '
        'work are outside these intervals. Overlaps are merged for occupancy.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f:
        json.dump(report, f, indent=2)
        f.write('\n')
    print(json.dumps({k:report[k] for k in ['elapsedSeconds', 'endedGuardIntervals',
        'recordedGuardSeconds', 'unionGuardSeconds', 'maximumRecordedRssBytes', 'missingEndRecords']}))


if __name__ == '__main__':
    main()

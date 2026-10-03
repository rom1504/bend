#!/usr/bin/env python3
"""Append campaign evidence events and summarize elapsed and declared windows; execute no jobs."""
import argparse
import datetime
import fcntl
import hashlib
import json
from pathlib import Path
import time


def identity(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(2**20), b''):
            digest.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def append(path, event):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a+') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.seek(0)
        prior = [json.loads(line) for line in stream if line.strip()]
        event.update(sequence=len(prior) + 1, recorded=time.time(), producer=identity(__file__))
        stream.seek(0, 2)
        stream.write(json.dumps(event, sort_keys=True) + '\n')
        stream.flush()


def union_seconds(intervals, start, end):
    spans = sorted((max(start, a), min(end, b)) for a, b in intervals if b > start and a < end)
    total, stop = 0.0, start
    for a, b in spans:
        if b > max(a, stop):
            total += b - max(a, stop)
        stop = max(stop, b)
    return total


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ledger', type=Path, required=True)
    sub = p.add_subparsers(dest='action', required=True)
    begin = sub.add_parser('start')
    begin.add_argument('--at', type=float, default=None, help='UTC epoch campaign start; defaults to now')
    event = sub.add_parser('event')
    event.add_argument('--label', required=True)
    event.add_argument('--decision', default='')
    event.add_argument('--receipt', type=Path, help='Existing bounded-run run.json; copies exact command and interval')
    event.add_argument('--start', type=float)
    event.add_argument('--seconds', type=float)
    event.add_argument('--command', default='', help='Manual command text, never executed')
    event.add_argument('--file', action='append', default=[], help='Hash consumed module/report/source; repeatable')
    window = sub.add_parser('window')
    window.add_argument('--label', required=True)
    window.add_argument('--start', type=float, required=True)
    window.add_argument('--end', type=float, required=True)
    window.add_argument('--basis', required=True, help='Evidence and uncertainty; windows do not prove continuous active work')
    report = sub.add_parser('report')
    report.add_argument('--end', type=float, default=None, help='UTC epoch cutoff; defaults to now')
    report.add_argument('--out', type=Path, required=True, help='New output directory')
    a = p.parse_args()
    if a.action == 'start':
        assert not a.ledger.exists(), 'Use a new campaign ledger'
        append(a.ledger, dict(kind='start', started=a.at if a.at is not None else time.time()))
    elif a.action == 'event':
        assert a.ledger.is_file(), 'Start campaign first'
        row = dict(kind='event', label=a.label, decision=a.decision,
                   files=[identity(x) for x in a.file], command=a.command)
        if a.receipt:
            assert a.start is None and a.seconds is None, 'Receipt owns time boundaries'
            data = json.loads(a.receipt.read_text())
            row.update(receipt=identity(a.receipt), command=data['command'],
                       started=data['started'], finished=data['finished'],
                       toolElapsedSeconds=data['wallSeconds'], complete=data['complete'],
                       returncode=data['returncode'])
        elif a.start is not None or a.seconds is not None:
            assert a.start is not None and a.seconds is not None and a.seconds >= 0
            row.update(started=a.start, finished=a.start+a.seconds, toolElapsedSeconds=a.seconds,
                       intervalSource='operator supplied; not independently measured')
        append(a.ledger, row)
    elif a.action == 'window':
        assert a.ledger.is_file() and a.end >= a.start
        append(a.ledger, dict(kind='window', label=a.label, windowStart=a.start,
                             windowEnd=a.end, basis=a.basis))
    else:
        events = [json.loads(line) for line in a.ledger.read_text().splitlines() if line.strip()]
        assert events and events[0]['kind'] == 'start'
        start, end = events[0]['started'], a.end if a.end is not None else time.time()
        assert end >= start
        intervals = [(r['started'], r['finished']) for r in events if 'finished' in r]
        assert all(b >= c for c, b in intervals)
        classified = union_seconds(intervals, start, end)
        windows = [(r['windowStart'], r['windowEnd']) for r in events if r['kind'] == 'window']
        window_covered = union_seconds(windows, start, end)
        result = dict(kind='phase40-campaign-accounting-v2', ledger=identity(a.ledger),
                      started=start, finished=end, wallSeconds=end-start,
                      recordedToolElapsedSeconds=sum(r.get('toolElapsedSeconds', 0) for r in events),
                      toolCoveredWallSeconds=classified, unclassifiedWallSeconds=end-start-classified,
                      declaredWindowWallSeconds=window_covered,
                      outsideDeclaredWindowsWallSeconds=end-start-window_covered,
                      scope='Recorded tool intervals are merged for wall coverage. Unclassified includes '
                            'reasoning, editing, waiting and unrecorded tools; it is not model latency. '
                            'Declared windows bound observed sessions, not continuous active work; outside-window time '
                            'includes interruption and uncertain agent continuation. One campaign establishes no model-speed comparison.', events=events)
        a.out.mkdir(parents=True, exist_ok=False)
        (a.out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
        rows = ['# Phase40 campaign accounting', '', '| Quantity | Seconds |', '|---|---:|']
        for key in ['wallSeconds', 'recordedToolElapsedSeconds', 'toolCoveredWallSeconds', 'unclassifiedWallSeconds', 'declaredWindowWallSeconds', 'outsideDeclaredWindowsWallSeconds']:
            rows.append(f'| {key} | {result[key]:.3f} |')
        rows += ['', result['scope'], '', '| Event | Tool seconds | Decision |', '|---|---:|---|']
        for r in events[1:]:
            if r['kind'] == 'window':
                continue
            clean = lambda x: str(x).replace('|', '\\|').replace('\n', ' ')
            rows.append(f"| {clean(r['label'])} | {r.get('toolElapsedSeconds', 0):.3f} | {clean(r['decision'])} |")
        rows += ['', '| Declared window | UTC epoch start | UTC epoch end | Evidence / uncertainty |', '|---|---:|---:|---|']
        for r in events:
            if r['kind'] == 'window':
                clean = lambda x: str(x).replace('|', '\\|').replace('\n', ' ')
                rows.append(f"| {clean(r['label'])} | {r['windowStart']} | {r['windowEnd']} | {clean(r['basis'])} |")
        (a.out/'report.md').write_text('\n'.join(rows)+'\n')
        print(json.dumps({k: v for k, v in result.items() if k not in ['events', 'ledger']}))


if __name__ == '__main__':
    main()

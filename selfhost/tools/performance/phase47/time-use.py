#!/usr/bin/env python3
"""Data-only union of recorded Phase47 supervisor intervals; no target execution."""
import argparse
import collections
import datetime as dt
import hashlib
import json
import math
import os
from pathlib import Path

CATEGORIES = ('build', 'correctness', 'performance', 'compiler-cost', 'profiles', 'misc')

def stamp(value):
    if isinstance(value, (int, float)) and math.isfinite(value):
        return float(value)
    if isinstance(value, str):
        parsed = dt.datetime.fromisoformat(value.replace('Z', '+00:00'))
        if parsed.tzinfo is None:
            raise ValueError('timestamp must include timezone')
        return parsed.timestamp()
    raise ValueError('missing timestamp')

def iso(value):
    return dt.datetime.fromtimestamp(value, dt.timezone.utc).isoformat().replace('+00:00', 'Z')

def classify(file, command):
    text = (str(file) + ' ' + ' '.join(map(str, command))).lower()
    if any(s in text for s in ('v8-diagnostic', 'v8-probe', '--cpu-prof', '--heap-prof', '--trace-opt', '--trace-deopt', 'profile-')):
        return 'profiles'
    if any(s in text for s in ('compiler-cost', 'compiler-memo', 'compiler-probe', 'run-census', 'run-memo', 'compiler-census')):
        return 'compiler-cost'
    if any(str(s).endswith('/workflow.mjs') or str(s) == 'workflow.mjs' for s in command) and 'run' in command:
        return 'build'
    # Classify preparation as build work, even inside a performance/control campaign.
    if any(s in text for s in ('emit-worker.mjs', 'prepare-programs', 'prepare-compiler', '--bootstrap')):
        return 'build'
    if any(s in text for s in ('consumed-execute', '/execute.mjs', '/execute.py', '/worker.mjs', '-timing/', 'first-screen', 'public-screen')):
        return 'performance'
    if any(s in text for s in ('controls', 'qualify', 'test-', '/test.mjs', 'gate-', 'activation', 'admission', 'accounting', 'verify', 'smoke')):
        return 'correctness'
    return 'misc'

def process_rows(obj, location='$'):
    if isinstance(obj, dict):
        if isinstance(obj.get('command'), list) and 'started' in obj:
            yield location, obj
        for key, value in obj.items():
            if isinstance(value, (dict, list)):
                yield from process_rows(value, location + '.' + str(key))
    elif isinstance(obj, list):
        for index, value in enumerate(obj):
            yield from process_rows(value, location + '[' + str(index) + ']')

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root', default='selfhost/build/phase47')
    ap.add_argument('--start', default='2026-10-04T23:00:16Z')
    ap.add_argument('--end', help='Explicit final UTC cutoff; omission produces provisional audit at current UTC')
    ap.add_argument('--out', required=True, help='Fresh JSON report path; refresh into a new path')
    ap.add_argument('--markdown', help='Optional fresh Markdown report path')
    args = ap.parse_args()
    root = Path(args.root).resolve()
    start = stamp(args.start)
    end = stamp(args.end) if args.end else dt.datetime.now(dt.timezone.utc).timestamp()
    if end <= start:
        ap.error('end must follow start')
    output = Path(args.out)
    if output.exists() or (args.markdown and Path(args.markdown).exists()):
        ap.error('outputs must be fresh')
    inputs, records, skipped = [], [], []
    seen = {}
    # Scan names only. Never read generated sources, other reports or profile payloads.
    for directory, _, files in os.walk(root):
        for name in sorted(files):
            if name != 'process.json' and not (name.startswith('job') and name.endswith('.json')):
                continue
            file = Path(directory) / name
            relative = str(file.relative_to(root))
            try:
                raw = file.read_bytes()
                inputs.append({'file': str(file), 'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)})
                obj = json.loads(raw)
            except Exception as error:
                skipped.append({'file': relative, 'reason': 'unreadable-json', 'detail': str(error)})
                continue
            for location, row in process_rows(obj):
                try:
                    begin = stamp(row['started'])
                    if 'finished' in row:
                        finish = stamp(row['finished'])
                        endpoint = 'recorded-finished'
                    elif row.get('complete') is True and isinstance(row.get('wallSeconds'), (int, float)):
                        finish = begin + float(row['wallSeconds'])
                        endpoint = 'completed-start-plus-wall'
                    else:
                        skipped.append({'file': relative, 'location': location, 'reason': 'unfinished-no-observed-duration'})
                        continue
                    if finish <= begin:
                        raise ValueError('non-positive interval')
                except Exception as error:
                    skipped.append({'file': relative, 'location': location, 'reason': 'invalid-interval', 'detail': str(error)})
                    continue
                if finish <= start or begin >= end:
                    continue
                key = (begin, finish, tuple(map(str, row['command'])))
                if key in seen:
                    records[seen[key]]['alsoRecordedAt'].append(relative + ':' + location)
                    continue
                seen[key] = len(records)
                records.append({'id': len(records), 'file': relative, 'location': location,
                                'alsoRecordedAt': [], 'start': begin, 'finish': finish,
                                'clippedStart': max(begin, start), 'clippedFinish': min(finish, end),
                                'durationSeconds': finish - begin, 'category': classify(relative, row['command']),
                                'command': row['command'], 'endpoint': endpoint,
                                'recordedWallSeconds': row.get('wallSeconds'),
                                'returncode': row.get('returncode'), 'complete': row.get('complete')})
    events = collections.defaultdict(lambda: {'start': [], 'end': []})
    for row in records:
        events[row['clippedStart']]['start'].append(row['id'])
        events[row['clippedFinish']]['end'].append(row['id'])
    active, exclusive, segments = set(), collections.Counter(), []
    total, overlap, mixed = 0.0, 0.0, 0.0
    points = sorted(events)
    for index, point in enumerate(points[:-1]):
        active.difference_update(events[point]['end'])
        active.update(events[point]['start'])
        following = points[index + 1]
        if not active or following <= point:
            continue
        duration = following - point
        # Most specific overlapping supervisor interval wins category attribution.
        owner = min(active, key=lambda i: (records[i]['durationSeconds'], records[i]['file'], i))
        category = records[owner]['category']
        exclusive[category] += duration
        total += duration
        if len(active) > 1:
            overlap += duration
        if len({records[i]['category'] for i in active}) > 1:
            mixed += duration
        segments.append({'start': iso(point), 'finish': iso(following), 'seconds': duration,
                         'category': category, 'attributionRecord': owner, 'overlappingRecords': len(active)})
    elapsed = end - start
    changed = [i['file'] for i in inputs if not Path(i['file']).is_file() or hashlib.sha256(Path(i['file']).read_bytes()).hexdigest() != i['sha256']]
    producer = Path(__file__).resolve()
    report = {'producer': {'file': str(producer), 'sha256': hashlib.sha256(producer.read_bytes()).hexdigest(), 'bytes': producer.stat().st_size}, 'changedInputs': changed, 'kind': 'phase47-supervisor-wall-time-audit', 'dataOnly': True,
              'provisional': args.end is None, 'start': iso(start), 'cutoff': iso(end),
              'receiptRoot': str(root), 'elapsedSeconds': elapsed, 'observedSupervisorUnionSeconds': total,
              'observedFraction': total / elapsed, 'uncoveredSeconds': elapsed - total,
              'rawClippedReceiptSumSeconds': sum(r['clippedFinish'] - r['clippedStart'] for r in records),
              'overlapSeconds': overlap, 'crossCategoryOverlapSeconds': mixed,
              'exclusiveCategorySeconds': {c: exclusive[c] for c in CATEGORIES},
              'uniqueProcessRecords': len(records), 'scannedInputFiles': len(inputs),
              'duplicateRecordLocations': sum(len(r['alsoRecordedAt']) for r in records),
              'maxEndpointWallDifferenceSeconds': max((abs(r['durationSeconds'] - r['recordedWallSeconds']) for r in records if isinstance(r['recordedWallSeconds'], (int, float))), default=0),
              'failedProcessRecords': sum(r['returncode'] not in (None, 0) for r in records),
              'inputs': inputs, 'records': records, 'segments': segments, 'skipped': skipped,
              'method': 'Half-open timestamp interval union, clipped to campaign window. Exact command/start/finish duplicates collapsed. Overlapping parent/child jobs count once; category attributed to shortest active supervisor interval. Categories describe job intent, not exclusive CPU stages.',
              'limits': 'Observed wall includes supervised host/tool setup and waiting, not CPU utilization. Uncovered time can include analysis, docs, handoff, preservation, unrecorded jobs and idle time; it is not a claim that all thinking was active. Only process.json/job*.json read; ongoing records without observed duration excluded. Finality requires an explicit cutoff and writer closure, not just this report.'}
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as handle:
        json.dump(report, handle, indent=2)
        handle.write('\n')
    if args.markdown:
        lines = ['# Phase47 recorded wall-time audit', '',
                 '**Provisional**' if report['provisional'] else '**Explicit cutoff; receipt completeness remains bounded by the scanned inputs.**', '',
                 f"Window: {report['start']} to {report['cutoff']} ({elapsed / 60:.2f} minutes).", '',
                 f"Observed supervised wall: **{total / 60:.2f} minutes ({100 * total / elapsed:.1f}%)**; uncovered: **{(elapsed - total) / 60:.2f} minutes**.", '',
                 '| Job category | Union-attributed minutes |', '| --- | ---: |']
        lines += [f'| {c} | {exclusive[c] / 60:.2f} |' for c in CATEGORIES]
        lines += ['', f"{len(records)} unique process records; parent/child and overlapping receipts count once. {sum(len(r['alsoRecordedAt']) for r in records)} duplicate record locations collapsed.", '', report['method'], '', report['limits'], '',
                  'Two full representative runs were needed after the first corpus exposed a missed private tree path. Future pre-corpus activation checks should instrument the actual private entry reached by the workload, rather than only the corresponding public wrapper.', '',
                  f'Full data and input hashes: `{output}`.', '']
        md = Path(args.markdown)
        md.parent.mkdir(parents=True, exist_ok=True)
        with md.open('x') as handle:
            handle.write('\n'.join(lines))
    print(json.dumps({key: report[key] for key in ('provisional', 'elapsedSeconds', 'observedSupervisorUnionSeconds', 'uncoveredSeconds', 'exclusiveCategorySeconds', 'uniqueProcessRecords')}))

if __name__ == '__main__':
    main()

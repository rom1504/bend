#!/usr/bin/env python3
"""Snapshot terminal Phase195 outer-guard costs from immutable receipts only.

Includes successful, failed and prelaunch-refused guards. Never sums nested
compiler/target process receipts, runs jobs, changes retention, or reads archives.
Use a fresh --out at campaign close to preserve intermediate snapshots.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[3]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT / 'selfhost/build/phase195')
    parser.add_argument('--close-root', type=Path, default=ROOT / 'selfhost/build-retention/phase195')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--require-closed', action='store_true',
                        help='At final close, refuse any discovered unfinished/missing guard receipt or unsealed terminal job')
    args = parser.parse_args()
    assert not args.out.exists(), 'Fresh output required'
    cutoff = time.time()
    closures = {}
    for file in sorted(args.close_root.glob('*-close/report.json')):
        value = json.loads(file.read_text())
        if value.get('kind') == 'build-retention-run-close-v1' and value.get('complete'):
            key = value.get('process', {}).get('file')
            if key:
                assert key not in closures, 'Duplicate closure for ' + key
                closures[key] = (value, file)
    rows, pending, pins = [], [], [pin(__file__)]
    seen = set()
    for directory in sorted(args.root.rglob('*-guard')):
        if not directory.is_dir():
            continue
        file = directory / 'process.json'
        if not file.exists():
            pending.append(dict(guard=str(directory.resolve()), reason='No terminal process receipt'))
            continue
        raw = file.read_bytes()
        try:
            value = json.loads(raw)
        except json.JSONDecodeError:
            pending.append(dict(guard=str(directory.resolve()), reason='Incomplete JSON at snapshot'))
            continue
        assert value.get('kind') == 'build-retention-disk-guard-v1', str(file)
        if not number(value.get('finished')) or value['finished'] > cutoff:
            pending.append(dict(guard=str(directory.resolve()), reason='Not terminal before snapshot cutoff'))
            continue
        elapsed = value.get('wallSeconds')
        assert number(elapsed) and elapsed >= 0 and number(value.get('started')), str(file)
        assert value['finished'] >= value['started'], str(file)
        identity = pin(file)
        assert identity['sha256'] == hashlib.sha256(raw).hexdigest(), 'Receipt changed during read'
        assert identity['file'] not in seen, 'Duplicate guard process receipt'
        seen.add(identity['file']); pins.append(identity)
        passed = value.get('complete') is True and value.get('returncode') == 0
        row = dict(name=directory.name.removesuffix('-guard'), process=identity,
            guardPassed=passed, returncode=value.get('returncode'),
            stoppedFor=value.get('stoppedFor'), wallSeconds=elapsed,
            started=value['started'], finished=value['finished'],
            peakTreeRssBytes=value.get('peakTreeRssBytes', 0),
            peakRunAllocatedBytes=value.get('peakRunAllocatedBytes', 0),
            peakFilesystemDecreaseBytes=value.get('peakFilesystemDecreaseBytes', 0),
            closure=None)
        if identity['file'] in closures:
            close, close_file = closures[identity['file']]
            assert close['process'] == identity, 'Closure/process identity differs'
            closure_pin = pin(close_file); pins.append(closure_pin)
            row['closure'] = dict(receipt=closure_pin, classification=close['classification'],
                                  state=close.get('state'))
        rows.append(row)
    # Keep sum-of-job-wall distinct from elapsed campaign duration; the former
    # includes failures and may overlap if some authorized lanes ran together.
    passed = [r for r in rows if r['guardPassed']]
    failed = [r for r in rows if not r['guardPassed']]
    intervals = sorted((r['started'], r['finished']) for r in rows)
    union = []
    for start, end in intervals:
        if union and start <= union[-1][1]:
            union[-1][1] = max(union[-1][1], end)
        else:
            union.append([start, end])
    changed = [p['file'] for p in pins if pin(p['file']) != p]
    unsealed = [r['name'] for r in rows if r['closure'] is None or r['closure']['state'] != 'sealed']
    report = dict(kind='phase195-terminal-guard-cost-snapshot', version=1,
        complete=not changed, targetsRun=False, cutoffEpoch=cutoff,
        cutoffUTC=datetime.fromtimestamp(cutoff, timezone.utc).isoformat(),
        root=str(args.root.resolve()), inputs=pins, rows=rows,
        terminalGuards=len(rows), passedGuards=len(passed), failedGuards=len(failed),
        prelaunchRefusals=sum(r['returncode'] is None for r in rows),
        summedGuardWallSeconds=sum(r['wallSeconds'] for r in rows),
        passedGuardWallSeconds=sum(r['wallSeconds'] for r in passed),
        failedGuardWallSeconds=sum(r['wallSeconds'] for r in failed),
        unionGuardIntervalSeconds=sum(end-start for start, end in union),
        maximumPeakTreeRssBytes=max((r['peakTreeRssBytes'] for r in rows), default=0),
        failureReasons=dict(Counter(r['stoppedFor'] or 'command-failure' for r in failed)),
        pendingOrMissing=pending, unsealedTerminalGuards=unsealed,
        changedInputs=changed, campaignClosed=not pending and not unsealed,
        scope='Terminal outer guards discovered below this Phase195 run root, as of cutoff, counted once. Includes failures and admission refusals. Sum is guarded wall time, not CPU time, billing, complete human/agent time, or compilation latency. Unguarded metadata, closure/archival work outside guard processes, missing archived receipts and active jobs are excluded. No target execution or retention mutation.')
    if args.require_closed and not report['campaignClosed']:
        report['complete'] = False
        report['error'] = 'Final closure requested but unfinished/missing or unsealed guards remain'
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps({k: report[k] for k in ('complete', 'terminalGuards', 'passedGuards',
        'failedGuards', 'summedGuardWallSeconds', 'failedGuardWallSeconds', 'campaignClosed')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

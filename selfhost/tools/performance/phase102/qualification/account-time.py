#!/usr/bin/env python3
"""Data-only wall-time accounting from closed ExecutionGuard process receipts."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import sys

sys.dont_write_bytecode = True


def utc(text):
    value = datetime.fromisoformat(text.replace('Z', '+00:00'))
    if value.tzinfo is None or value.utcoffset().total_seconds() != 0:
        raise ValueError('Boundaries must explicitly use UTC (Z or +00:00)')
    return value.timestamp()


def identity(path, data=None):
    raw = path.read_bytes() if data is None else data
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def reject_constant(value):
    raise ValueError('nonfinite JSON constant: ' + value)


def finite_float(value):
    parsed = float(value)
    if not math.isfinite(parsed):
        raise ValueError('nonfinite JSON number: ' + value)
    return parsed


def union(intervals):
    merged = []
    for start, finish in sorted(intervals):
        if merged and start <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], finish)
        else:
            merged.append([start, finish])
    return merged


def seconds(intervals):
    return math.fsum(finish - start for start, finish in intervals)


def enumerate_receipts(roots):
    files = set()
    for root in roots:
        def fail(error):
            raise error
        for directory, directories, names in os.walk(root, onerror=fail, followlinks=False):
            if any((Path(directory) / name).is_symlink() for name in directories):
                raise ValueError('Symlink directory would leave scan scope ambiguous: ' + directory)
            if 'process.json' in names:
                path = (Path(directory) / 'process.json').resolve(strict=True)
                if not path.is_relative_to(root):
                    raise ValueError('Receipt symlink escapes root: ' + str(path))
                files.add(path)
    return sorted(files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, action='append', required=True)
    parser.add_argument('--start', required=True)
    parser.add_argument('--start-meaning', required=True)
    parser.add_argument('--cutoff', required=True)
    parser.add_argument('--cutoff-meaning', required=True)
    parser.add_argument('--final', action='store_true')
    parser.add_argument('--writers-closed', action='store_true')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    start, cutoff = utc(args.start), utc(args.cutoff)
    if not start < cutoff:
        parser.error('start must precede cutoff')
    if args.final and not args.writers_closed:
        parser.error('--final requires the coordinator declaration --writers-closed')
    if args.out.exists():
        parser.error('output must be fresh')
    requested = sorted(set(path.resolve(strict=True) for path in args.root))
    if any(not path.is_dir() for path in requested):
        parser.error('each root must be a directory')
    # Remove nested roots; a physical receipt is read and counted only once.
    roots = [p for p in requested if not any(p != q and p.is_relative_to(q) for q in requested)]
    if args.out.name == 'process.json' and any(args.out.resolve().is_relative_to(p) for p in roots):
        parser.error('output cannot create a process receipt inside the scanned scope')
    files = enumerate_receipts(roots)
    method = identity(Path(__file__).resolve())
    issues, rows, inputs, intervals, buckets = [], [], [], [], {}
    for path in files:
        row = dict(file=str(path))
        rows.append(row)
        try:
            raw = path.read_bytes()
            pin = identity(path, raw)
            inputs.append(pin)
            row['receipt'] = pin
            value = json.loads(raw, parse_constant=reject_constant, parse_float=finite_float)
            if not isinstance(value, dict):
                raise ValueError('receipt must be an object')
            begin, end = value.get('started'), value.get('finished')
            if not number(begin) or not number(end) or begin < 0 or end < begin:
                raise ValueError('missing, nonfinite, negative, or reversed epoch timestamps')
            argv, returncode = value.get('command'), value.get('returncode')
            if not isinstance(argv, list) or not argv or not all(isinstance(x, str) for x in argv):
                raise ValueError('missing/non-string command vector')
            exit_known = type(returncode) is int
            stopped_before_exit = ('returncode' not in value and value.get('complete') is False
                                   and (isinstance(value.get('stoppedFor'), str) and value['stoppedFor']
                                        or isinstance(value.get('error'), str) and value['error']))
            if not exit_known and not stopped_before_exit:
                raise ValueError('closed receipt requires integer returncode or explicit stopped/error outcome')
            root = next(p for p in roots if path.is_relative_to(p))
            relative = path.relative_to(root)
            bucket = str(root / relative.parts[0]) if len(relative.parts) > 1 else str(root)
            clipped = [max(start, begin), min(cutoff, end)]
            included = clipped[1] > clipped[0]
            # complete:false is expected for nonzero/timeout attempts; it does not
            # remove their elapsed time or make a finished receipt incomplete.
            row.update(started=begin, finished=end, command=argv, returncode=returncode,
                       guardComplete=value.get('complete'), stoppedFor=value.get('stoppedFor'),
                       guardError=value.get('error'), exitCodeRecorded=exit_known,
                       reportedWallSeconds=value.get('wallSeconds'), filesystemBucket=bucket,
                       intersectsWindow=included, clippedInterval=clipped if included else None,
                       beforeWindow=end <= start, afterWindow=begin >= cutoff,
                       crossesStart=begin < start < end, crossesCutoff=begin < cutoff < end)
            if included:
                intervals.append(clipped)
                buckets.setdefault(bucket, []).append(clipped)
        except (OSError, ValueError, TypeError, KeyError) as error:
            row['error'] = str(error)
            issues.append(dict(file=str(path), error=str(error)))
    # A stable inventory plus byte recheck makes this a bound snapshot, not a
    # race-prone claim that a scan itself establishes writer closure.
    if enumerate_receipts(roots) != files:
        issues.append(dict(error='receipt inventory changed during accounting'))
    for pin in inputs + [method]:
        try:
            if identity(Path(pin['file'])) != pin:
                issues.append(dict(file=pin['file'], error='input changed during accounting'))
        except OSError as error:
            issues.append(dict(file=pin['file'], error=str(error)))
    merged = union(intervals)
    guarded = seconds(merged)
    wall = cutoff - start
    good = [row for row in rows if 'error' not in row]
    included = [row for row in good if row['intersectsWindow']]
    complete = args.final and args.writers_closed and not issues
    report = dict(kind='phase102-guard-time-account', version=1,
        complete=complete, dataOnly=True, targetExecuted=False,
        snapshotStable=not issues, finalRequested=args.final,
        writersClosedDeclared=args.writers_closed,
        start=args.start, startEpoch=start, startMeaning=args.start_meaning,
        cutoff=args.cutoff, cutoffEpoch=cutoff, cutoffMeaning=args.cutoff_meaning,
        requestedRoots=[str(p) for p in requested], roots=[str(p) for p in roots],
        receiptCount=len(rows), validReceiptCount=len(good), includedReceiptCount=len(included),
        nonzeroIncludedCount=sum(row['exitCodeRecorded'] and row['returncode'] != 0 for row in included),
        noExitCodeIncludedCount=sum(not row['exitCodeRecorded'] for row in included),
        stoppedIncludedCount=sum(bool(row['stoppedFor']) for row in included),
        beforeWindowCount=sum(row['beforeWindow'] for row in good),
        afterWindowCount=sum(row['afterWindow'] for row in good),
        crossesStartCount=sum(row['crossesStart'] for row in good),
        crossesCutoffCount=sum(row['crossesCutoff'] for row in good),
        elapsedWallSeconds=wall, summedClippedReceiptSeconds=seconds(intervals),
        guardedUnionSeconds=guarded, unclassifiedWallSeconds=wall - guarded,
        guardedUnionIntervals=merged,
        filesystemBuckets=[dict(path=key, receiptCount=len(value), unionSeconds=seconds(union(value)),
                                summedClippedReceiptSeconds=seconds(value))
                           for key, value in sorted(buckets.items())],
        scope='Epoch wall intervals from process.json receipts in the explicitly listed roots, clipped to the supplied boundaries. Includes failed and stopped attempts. Nested/overlapping intervals count once in the union; summed receipt time and filesystem bucket unions are not additive CPU or activity time. The complement remains unclassified. Work outside the window and unguarded work are not measured as guarded work.',
        issues=issues, method=method, inputs=inputs, receipts=rows)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(report, stream, indent=2, allow_nan=False)
        stream.write('\n')
    print(json.dumps({key: report[key] for key in ['complete', 'snapshotStable', 'receiptCount',
        'includedReceiptCount', 'elapsedWallSeconds', 'guardedUnionSeconds', 'unclassifiedWallSeconds']}))
    return 0 if not issues else 1


if __name__ == '__main__':
    sys.exit(main())

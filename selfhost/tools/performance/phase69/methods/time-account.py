#!/usr/bin/env python3
"""Summarize actual guard receipts; no targets, billing estimate or quota claim."""
import argparse
import hashlib
import json
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--raw', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    root, out = a.raw.resolve(strict=True), a.out.resolve()
    assert not out.exists()
    rows, pending = [], []
    for file in sorted(root.rglob('*.json')):
        if file.name not in {'process.json', 'run.json'}:
            continue
        try:
            data = file.read_bytes()
            j = json.loads(data)
        except (OSError, json.JSONDecodeError):
            pending.append(str(file))
            continue
        if not isinstance(j, dict) or not {'started', 'rssLimitBytes', 'availableFloorBytes'} <= j.keys():
            continue
        if not {'finished', 'wallSeconds'} <= j.keys():
            pending.append(str(file))
            continue
        rows.append(dict(receipt=str(file), sha256=hashlib.sha256(data).hexdigest(),
                         started=j['started'], finished=j['finished'], wallSeconds=j['wallSeconds'],
                         complete=j.get('complete', False), returncode=j.get('returncode'),
                         peakTreeRssBytes=j.get('peakTreeRssBytes', 0),
                         minimumAvailableBytes=j.get('minimumAvailableBytes'),
                         command=j.get('command', [])))
    # Do not add overlapping intervals twice. Report duplicates separately so
    # an archived copy or nested receipt cannot conceal accounting uncertainty.
    unique, duplicates = {}, []
    for r in rows:
        key = (r['started'], r['finished'], tuple(r['command']))
        if key in unique:
            duplicates.append(dict(receipt=r['receipt'], duplicateOf=unique[key]['receipt']))
        else:
            unique[key] = r
    intervals = sorted((r['started'], r['finished']) for r in unique.values())
    merged = []
    for start, end in intervals:
        assert start <= end
        if merged and start <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([start, end])
    result = dict(kind='phase69-guard-time-account', raw=str(root), receiptCount=len(rows),
                  uniqueReceiptCount=len(unique), duplicateReceipts=duplicates, pendingReceipts=pending,
                  summedUniqueGuardSeconds=sum(r['wallSeconds'] for r in unique.values()),
                  guardOccupancySeconds=sum(end-start for start, end in merged),
                  firstTargetStart=min((r['started'] for r in rows), default=None),
                  lastTargetFinish=max((r['finished'] for r in rows), default=None),
                  peakTreeRssBytes=max((r['peakTreeRssBytes'] for r in rows), default=0),
                  failedReceipts=[r['receipt'] for r in rows if not r['complete'] or r['returncode'] != 0],
                  rows=rows,
                  scope='Observed process-tree guard receipts only. Union occupancy excludes idle/source work; overlapping guards are not independent speed evidence. No compiler/runtime aggregation, billing or exact model quota claim.')
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps({k: result[k] for k in ['receiptCount', 'uniqueReceiptCount', 'summedUniqueGuardSeconds', 'guardOccupancySeconds', 'peakTreeRssBytes', 'failedReceipts', 'pendingReceipts']}))


if __name__ == '__main__':
    main()

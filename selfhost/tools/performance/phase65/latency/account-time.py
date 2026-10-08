#!/usr/bin/env python3
"""Data-only union of closed Phase65 guard receipts through an explicit UTC cutoff."""
import argparse
import datetime as dt
import hashlib
import json
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase65'


def stamp(value):
    return dt.datetime.fromisoformat(value.replace('Z', '+00:00')).timestamp()


def utc(value):
    return dt.datetime.fromtimestamp(value, dt.timezone.utc).isoformat()


def identity(path):
    return dict(file=str(path.resolve()), sha256=hashlib.sha256(path.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--cutoff', help='ISO UTC cutoff; default is time at invocation, not phase completion')
a = p.parse_args()
assert not a.out.exists()
cutoff = stamp(a.cutoff) if a.cutoff else time.time()
campaign = json.loads((RAW / 'campaign.json').read_text())
begin = stamp(campaign['started'])
assert begin < cutoff
closed, open_receipts, late, unreadable = [], [], [], []
for path in sorted([*RAW.rglob('run.json'), *RAW.rglob('process.json')]):
    try:
        payload = path.read_bytes()
        row = json.loads(payload)
    except (json.JSONDecodeError, FileNotFoundError) as error:
        unreadable.append(dict(file=str(path), error=type(error).__name__))
        continue
    if not isinstance(row, dict) or not isinstance(row.get('command'), list):
        continue
    start, end = row.get('started'), row.get('finished')
    if not isinstance(start, (int, float)) or start >= cutoff:
        continue
    if not isinstance(end, (int, float)):
        if start >= begin:
            open_receipts.append(str(path))
        continue
    if end <= begin:
        continue
    assert end >= start
    if end > cutoff:
        late.append(str(path))
        continue
    closed.append(dict(receipt=dict(file=str(path), sha256=hashlib.sha256(payload).hexdigest()),
                       start=max(begin, start), finish=end, returncode=row.get('returncode'),
                       complete=row.get('complete'), stoppedFor=row.get('stoppedFor'),
                       processWallSeconds=row.get('wallSeconds')))
merged = []
for row in sorted(closed, key=lambda x: x['start']):
    if not merged or row['start'] > merged[-1][1]:
        merged.append([row['start'], row['finish']])
    else:
        merged[-1][1] = max(merged[-1][1], row['finish'])
occupied = sum(end - start for start, end in merged)
interruption_path = ROOT / 'implementation/phase65/evidence/interruption.json'
interruption_bytes = interruption_path.read_bytes()
interruption = json.loads(interruption_bytes)
assert interruption['kind'] == 'phase65-external-interruption-note'
assert interruption['boundariesExact'] is False
pause_start = stamp(interruption['approximateStartUtc'])
pause_finish = stamp(interruption['approximateResumeUtc'])
assert pause_finish >= pause_start
clipped_start, clipped_finish = max(begin, pause_start), min(cutoff, pause_finish)
clipped_seconds = max(0.0, clipped_finish - clipped_start)
overlap_seconds = sum(max(0.0, min(end, clipped_finish) - max(start, clipped_start))
                      for start, end in merged) if clipped_seconds else 0.0
approximate_interruption = dict(
    input=dict(file=str(interruption_path), sha256=hashlib.sha256(interruption_bytes).hexdigest()),
    boundariesExact=False, source=interruption['source'],
    declaredStart=interruption['approximateStartUtc'],
    declaredResume=interruption['approximateResumeUtc'],
    declaredApproximateSeconds=pause_finish-pause_start,
    clippedStart=utc(clipped_start) if clipped_seconds else None,
    clippedFinish=utc(clipped_finish) if clipped_seconds else None,
    clippedApproximateDowntimeSeconds=clipped_seconds,
    measuredClosedGuardOverlapSeconds=overlap_seconds,
    elapsedOutsideApproximateDowntimeSeconds=cutoff-begin-clipped_seconds,
    closedGuardUnionOutsideApproximateDowntimeSeconds=occupied-overlap_seconds,
    uncoveredOutsideApproximateDowntimeSeconds=cutoff-begin-occupied-clipped_seconds+overlap_seconds,
    scope='Separately clips root-declared approximate external downtime to this accounting interval. '
          'Guard overlap uses measured closed intervals within approximate boundaries; total elapsed '
          'and occupied union above remain unchanged. Outside-downtime values are approximate and '
          'unclassified, not precise active work, CPU time or waiting. No open-guard finish is inferred.')
result = dict(kind='phase65-closed-guard-time-account', dataOnly=True, targetExecuted=False,
    producer=identity(Path(__file__)), campaign=identity(RAW / 'campaign.json'),
    start=utc(begin), cutoff=utc(cutoff), cutoffMeaning='Explicit or invocation time; not a phase-completion claim',
    elapsedSeconds=cutoff-begin, completedSupervisorReceipts=len(closed),
    failedReceipts=sum(r['returncode'] != 0 or not r['complete'] for r in closed),
    occupiedUnionSeconds=occupied, occupiedFraction=occupied/(cutoff-begin),
    uncoveredSeconds=cutoff-begin-occupied, intervals=closed, mergedIntervals=merged,
    approximateInterruption=approximate_interruption,
    unfinishedBeforeCutoff=open_receipts, finishedAfterCutoff=late, unreadable=unreadable,
    scope='Union of closed run.json/process.json guards, including ExecutionGuard workers and failures. '
          'Reused or nested receipts are never double-counted. Open intervals have no invented finish. '
          'Uncovered elapsed time is unclassified, not measured waiting or idle time; it includes source '
          'and tool work, analysis, review and unobserved work. This is occupancy, not CPU utilization.')
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out), **{k:v for k,v in result.items()
                     if k not in ['intervals','mergedIntervals','producer','campaign']})))

#!/usr/bin/env python3
"""Data-only Phase66 closed-guard occupancy; never infers unrecorded activity."""
import argparse
import datetime as dt
import hashlib
import json
import math
import os
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / "selfhost/build/phase66"


def stamp(value):
    return dt.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()


def utc(value):
    return dt.datetime.fromtimestamp(value, dt.timezone.utc).isoformat()


def identity(path, payload=None):
    payload = path.read_bytes() if payload is None else payload
    return dict(file=str(path.resolve()), bytes=len(payload), sha256=hashlib.sha256(payload).hexdigest())


def partition(rows, begin, cutoff):
    events = []
    for i, row in enumerate(rows):
        events.extend([(row["start"], 1, i), (row["finish"], -1, i)])
    active, occupied, gaps, groups = set(), [], [], Counter()
    previous = begin
    for point in sorted(set([begin, cutoff] + [e[0] for e in events])):
        if point > previous:
            if active:
                names = sorted(set(rows[i]["group"] for i in active))
                label = names[0] if len(names) == 1 else "overlap: " + " + ".join(names)
                groups[label] += point - previous
                if occupied and occupied[-1][1] == previous:
                    occupied[-1][1] = point
                else:
                    occupied.append([previous, point])
            else:
                gaps.append([previous, point])
        for _, delta, i in by_time.get(point, []):
            if delta == 1:
                active.add(i)
            else:
                active.remove(i)
        previous = point
    return occupied, gaps, groups


p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--out", type=Path, required=True)
p.add_argument("--cutoff", required=True, help="Explicit ISO UTC accounting boundary")
p.add_argument("--final", action="store_true", help="Root confirms targets closed at this boundary")
a = p.parse_args()
assert not a.out.exists(), "Receipts are immutable: choose a fresh output"
cutoff = stamp(a.cutoff)
campaign_path = RAW / "campaign.json"
campaign = json.loads(campaign_path.read_text())
begin = stamp(campaign["started"])
assert math.isfinite(cutoff) and begin < cutoff
closed, open_receipts, late, unreadable = [], [], [], []
paths = []
for directory, directories, files in os.walk(RAW, followlinks=False):
    directories[:] = [x for x in directories if not (Path(directory) / x).is_symlink()]
    paths.extend(Path(directory) / name for name in ["run.json", "process.json"] if name in files)
for path in sorted(paths):
    try:
        payload = path.read_bytes()
        row = json.loads(payload)
    except (json.JSONDecodeError, FileNotFoundError) as error:
        unreadable.append(dict(file=str(path), error=type(error).__name__))
        continue
    if not isinstance(row, dict) or not isinstance(row.get("command"), list):
        continue
    start, end = row.get("started"), row.get("finished")
    if not isinstance(start, (int, float)) or not math.isfinite(start) or start >= cutoff:
        continue
    if not isinstance(end, (int, float)):
        if start >= begin:
            open_receipts.append(identity(path, payload))
        continue
    assert math.isfinite(end) and end >= start, str(path)
    if end <= begin:
        continue
    if end > cutoff:
        late.append(identity(path, payload))
        continue
    closed.append(dict(receipt=identity(path, payload), group=path.relative_to(RAW).parts[0],
                       start=max(begin, start), finish=end, returncode=row.get("returncode"),
                       complete=row.get("complete"), stoppedFor=row.get("stoppedFor"),
                       processWallSeconds=row.get("wallSeconds")))
by_time = {}
for i, row in enumerate(closed):
    by_time.setdefault(row["start"], []).append((row["start"], 1, i))
    by_time.setdefault(row["finish"], []).append((row["finish"], -1, i))
merged, uncovered, groups = partition(closed, begin, cutoff)
occupied = sum(end - start for start, end in merged)
uncovered_seconds = sum(end - start for start, end in uncovered)
assert abs(occupied + uncovered_seconds - (cutoff - begin)) < 1e-5
assert abs(sum(groups.values()) - occupied) < 1e-5
if a.final:
    assert not unreadable and not late, "Cannot close over unreadable or crossing receipts"
result = dict(kind="phase66-closed-guard-time-account", version=1,
    complete=bool(a.final and not unreadable and not late), dataOnly=True, targetExecuted=False,
    producer=identity(Path(__file__)), campaign=identity(campaign_path),
    start=utc(begin), cutoff=utc(cutoff),
    cutoffMeaning="Root-declared release-target closure boundary; archive and later reporting/commit/push excluded" if a.final
                  else "Provisional explicit observation cutoff; not target or phase completion",
    elapsedSeconds=cutoff-begin, closedSupervisorReceipts=len(closed),
    nonzeroOrIncompleteReceipts=sum(r["returncode"] != 0 or not r["complete"] for r in closed),
    occupiedUnionSeconds=occupied, occupiedFraction=occupied/(cutoff-begin),
    uncoveredSeconds=uncovered_seconds, intervals=closed, mergedIntervals=merged,
    uncoveredIntervals=uncovered,
    nonoverlappingGroupSeconds=dict(sorted(groups.items(), key=lambda item: (-item[1], item[0]))),
    unfinishedBeforeCutoff=open_receipts, finishedAfterCutoff=late, unreadable=unreadable,
    scope="Union of numeric started/finished command-array run.json/process.json guard receipts under Phase66, "
          "including failed/rejected attempts and ExecutionGuard workers. Reused or nested receipts count once. "
          "Groups partition occupancy by top-level raw directory; mixed-group overlaps are explicit. "
          "Open intervals have no invented finish and remain outside measured occupancy. "
          "Uncovered elapsed time is unclassified, not measured waiting, idle time or model work; it includes "
          "editing, analysis, review, source/data tools, orchestration and any unrecorded activity. "
          "This is target-tree wall occupancy, not CPU utilization or a compiler speed benchmark. "
          "Nonzero/incomplete guard status is not necessarily a compiler defect (e.g. conformance negative cases).")
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open("x") as stream:
    stream.write(json.dumps(result, indent=2)+"\n")
print(json.dumps(dict(output=identity(a.out), **{k:v for k,v in result.items()
                     if k not in ["intervals", "mergedIntervals", "uncoveredIntervals", "producer", "campaign"]})))

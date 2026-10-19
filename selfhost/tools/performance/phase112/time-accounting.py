#!/usr/bin/env python3
"""Offline wall-time accounting. Reads compact receipts; never runs a target.

Use guard interval unions, not sums of nested job/child clocks. Job seconds
are diagnostic attribution only, without invented per-job start timestamps.
"""
import argparse
import collections
import datetime as dt
import hashlib
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[4]
MAX_RECEIPT = 8 * 1024 * 1024


def timestamp(value):
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        return dt.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
    return None


def iso(value):
    return dt.datetime.fromtimestamp(value, dt.timezone.utc).isoformat()


def read(path):
    if path.stat().st_size > MAX_RECEIPT:
        raise ValueError(f"receipt exceeds cap: {path}")
    raw = path.read_bytes()
    return json.loads(raw), dict(file=str(path.relative_to(ROOT)), bytes=len(raw),
                                sha256=hashlib.sha256(raw).hexdigest())


def union(intervals):
    result = []
    for start, finish in sorted(intervals):
        if result and start <= result[-1][1]:
            result[-1][1] = max(finish, result[-1][1])
        else:
            result.append([start, finish])
    return result


def seconds(intervals):
    return sum(b - a for a, b in union(intervals))


def category(name, command):
    text = " ".join(command)
    if "native-self" in name:
        return "native self-reproduction"
    if name == "full-guard01" or "full-compiler-emission" in text:
        return "full compiler image acquisition"
    if name in {"first-image-guard01", "selector-fixtures-guard01",
                "combined-screen-guard01", "static-controls-guard01",
                "runtime-guard01", "word-regions-native-guard01"}:
        return "mixed qualification and benchmark batches"
    if any(x in name for x in ("baseline-acquisition", "baseline-api-guard",
                              "unicode-baseline", "fusion-batch")):
        return "representative benchmark acquisition"
    if "runtime-guard" in name:
        return "generated-program runtime measurement"
    if "profile-guard" in name:
        return "profiling"
    return "focused source, IR and semantic loops (provisional default)"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--start", default="2026-10-19T00:41:00Z")
    parser.add_argument("--until", required=True, help="UTC ISO timestamp, or now")
    parser.add_argument("--out", required=True, type=Path, help="fresh JSON path")
    args = parser.parse_args()
    captured = time.time()
    start = timestamp(args.start)
    until = captured if args.until == "now" else timestamp(args.until)
    if not start < until <= captured + 1:
        raise ValueError("require start < cutoff <= current time")
    if args.out.exists():
        raise ValueError("output must be fresh")
    roots = [ROOT / "selfhost/build/phase112"]
    roots += sorted(p for p in (ROOT / "selfhost/build/phase111").glob("p112-*")
                    if p.is_dir())
    # Bounded to immediate receipts and one nested directory. No artifact scan.
    process_paths = sorted({p for base in roots for pattern in
                            ("process.json", "*/process.json")
                            for p in base.glob(pattern)})
    rows, pending, jobs, inputs = [], [], [], []
    for path in process_paths:
        value, pin = read(path)
        begin, end = timestamp(value.get("started")), timestamp(value.get("finished"))
        if begin is None or begin >= until or (end is not None and end <= start):
            continue
        command = value.get("command", [])
        row = dict(receipt=pin, startUtc=iso(begin), category=category(path.parent.name, command),
                   command=command, returncode=value.get("returncode"),
                   success=value.get("complete") is True)
        inputs.append(pin)
        if end is None:
            row.update(status="no recorded finish", maximumWindowSeconds=until-max(start, begin))
            pending.append(row)
            continue
        if end < begin:
            raise ValueError(f"invalid guard clock: {path}")
        lo, hi = max(start, begin), min(until, end)
        row.update(finishUtc=iso(end), interval=[lo, hi], seconds=hi-lo,
                   finishedByCutoff=end <= until, guardReportedSeconds=value.get("wallSeconds"))
        rows.append(row)
        # Only the direct run-jobs child. Its nested reports are not extra wall time.
        if any(str(x).endswith("phase112/run-jobs.py") for x in command) and "--out" in command:
            child = ROOT / command[command.index("--out")+1] / "report.json"
            if child.is_file():
                report, child_pin = read(child)
                inputs.append(child_pin)
                jobs.append(dict(parent=pin["file"], receipt=child_pin,
                    finishedByCutoff=end <= until, complete=report.get("complete", False),
                    jobs=[{k: item[k] for k in ("name", "seconds", "status") if k in item}
                          for item in report.get("jobs", [])], error=report.get("error")))
    intervals = [r["interval"] for r in rows]
    occupied = seconds(intervals)
    categories = collections.defaultdict(list)
    for row in rows:
        categories[row["category"]].append(row["interval"])
    groups = {name: dict(seconds=seconds(parts), guardCount=sum(r["category"] == name for r in rows))
              for name, parts in sorted(categories.items())}
    # The transport clock is explicitly nested. Preserve the receipt without
    # adding it, even when its timestamp range is known more precisely.
    nested = []
    for p in (ROOT / "selfhost/build/phase112").glob("transport*/report.json"):
        report, pin = read(p)
        a, b = timestamp(report.get("started")), timestamp(report.get("finished"))
        if a is not None and b is not None and a < until and b > start:
            inputs.append(pin)
            enclosing = [r["receipt"]["file"] for r in rows
                         if timestamp(r["startUtc"]) <= a and timestamp(r["finishUtc"]) >= b]
            nested.append(dict(receipt=pin, seconds=b-a, enclosingGuards=enclosing,
                               countedSeparately=False, complete=report.get("complete")))
    failed = [r["interval"] for r in rows if r["returncode"] not in (None, 0)]
    result = dict(kind="phase112-offline-wall-accounting", version=1,
        startUtc=iso(start), cutoffUtc=iso(until), capturedUtc=iso(captured),
        elapsedSeconds=until-start, confirmedGuardUnionSeconds=occupied,
        guardIntervalSumSeconds=sum(r["seconds"] for r in rows),
        guardOverlapSeconds=sum(r["seconds"] for r in rows)-occupied,
        categoryOverlapSeconds=sum(v["seconds"] for v in groups.values())-occupied,
        outsideRecordedFinishedGuardSeconds=until-start-occupied,
        failedGuardUnionSeconds=seconds(failed),
        finishedGuardCount=sum(r["finishedByCutoff"] for r in rows),
        crossingCutoffGuardCount=sum(not r["finishedByCutoff"] for r in rows),
        failedGuardCount=sum(r["returncode"] not in (None, 0) for r in rows),
        categories=groups, guards=sorted(rows, key=lambda r:r["interval"]),
        pendingGuards=pending, directJobsAttributionOnly=jobs, nestedTimedReports=nested,
        inputs=inputs,
        methodSource=dict(file=str(Path(__file__).relative_to(ROOT)),
                          sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
        limitations=[
            "Only scoped recorded guard envelopes count as confirmed occupancy; failures count too.",
            "Pending guards have no measured finish; their potential window is not counted.",
            "No sum of nested job, emission, build or runtime clocks is added to a guard envelope.",
            "Category labels are coarse; unknown new guard names use the provisional focused-loop default.",
            "Outside recorded guards is not measured idle time: source work, analysis, cleanup, scheduling and unrecorded jobs are unresolved.",
            "Agent work can overlap target occupancy. No token, agent labor, CPU-time or waiting attribution is inferred.",
            "No all-children timestamps exist for run-jobs; job durations are diagnostic attribution only."])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({k:result[k] for k in ("elapsedSeconds", "confirmedGuardUnionSeconds",
        "guardOverlapSeconds", "outsideRecordedFinishedGuardSeconds", "finishedGuardCount",
        "crossingCutoffGuardCount", "failedGuardCount", "failedGuardUnionSeconds", "categories")}, indent=2))


if __name__ == "__main__":
    main()

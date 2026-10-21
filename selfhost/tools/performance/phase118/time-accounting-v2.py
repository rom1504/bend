"""Snapshot and union existing guard intervals. Never launch compiler targets."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]
START = "2026-10-21T09:47:34Z"


def stamp(text):
    return datetime.fromisoformat(text.replace("Z", "+00:00")).timestamp()


def utc(value):
    return datetime.fromtimestamp(value, timezone.utc).isoformat()


def number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def pinned(path, data):
    return {"file": str(path), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def category(path, command):
    name = path.lower()
    text = " ".join(command).lower()
    if "qualification" in name or "p118-native" in name or "native-qualification" in text:
        return "native qualification"
    if "hosted-cost" in name or "/phase118/cost.mjs" in text:
        return "hosted cost"
    if "profile" in name or "inspect" in name and "api" not in name:
        return "profiling and IR inspection"
    if "api" in name or "check-api.py" in text:
        return "checked API acquisition"
    if "finite" in name or "laws" in name or "stack-controls" in text:
        return "finite controls"
    if "broad" in name or "safe-emission" in name:
        return "broad qualification and emission"
    if "/runtime" in name and "screen" not in name:
        return "runtime acquisition"
    if any(word in name for word in ["screen", "emit", "control", "clean", "jobs", "match", "small", "dce-"]):
        return "focused experiments and mixed pipelines"
    return "other guarded work"


def union_seconds(intervals):
    end = None
    total = 0.0
    for a, b in sorted(intervals):
        total += b - a if end is None else max(0.0, b - max(a, end))
        end = b if end is None else max(end, b)
    return total


def partitions(rows):
    """Charge each time slice once to its outermost campaign; label true overlap."""
    bounds = sorted({x for row in rows for x in (row["from"], row["to"])})
    parts = []
    for a, b in zip(bounds, bounds[1:]):
        active = [r for r in rows if r["from"] <= a and r["to"] >= b]
        if not active or a == b:
            continue
        outer = [r for r in active if not any(
            (q["from"] <= r["from"] and q["to"] >= r["to"] and
             (q["from"] < r["from"] or q["to"] > r["to"])) for q in active)]
        categories = sorted({r["category"] for r in outer})
        group = categories[0] if len(categories) == 1 else "overlapping campaigns"
        parts.append({"from": a, "to": b, "seconds": b-a, "category": group,
                      "owners": [r["receipt"]["file"] for r in outer],
                      "activeReceipts": len(active)})
    return parts


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--start", default=START)
    ap.add_argument("--until", help="UTC ISO cutoff; default current host wall clock")
    ap.add_argument("--out", required=True, type=Path, help="Fresh output directory")
    ap.add_argument("--snapshot", type=Path, help="Replay an earlier immutable receipts.json")
    args = ap.parse_args()
    begin, cutoff = stamp(args.start), stamp(args.until) if args.until else time.time()
    assert cutoff > begin
    out = args.out.resolve()
    assert not out.exists(), "Output must be fresh"
    method = Path(__file__).resolve()
    errors, selected = [], []
    if args.snapshot:
        snapshot = json.loads(args.snapshot.read_text())
        selected = snapshot["receipts"]
        discovery = dict(snapshot["discovery"], replaySource=str(args.snapshot.resolve()))
        errors = snapshot["unreadable"]
    else:
        # Enumerate all guard receipt paths, including ignored and hidden trees.
        # The mtime prefilter avoids reading historical JSON bodies.
        result = subprocess.run(["rg", "--files", "--hidden", "--no-ignore", "selfhost/build", "-g", "process.json"],
                                cwd=ROOT, text=True, capture_output=True, timeout=45, check=True)
        paths = sorted(set(result.stdout.splitlines()))
        for relative in paths:
            path = ROOT / relative
            # ExecutionGuard creates/writes a receipt after its recorded start.
            # Old mtimes eliminate historical files without loading their JSON.
            # All recent snapshots are still filtered by actual recorded times.
            if path.stat().st_mtime < begin:
                continue
            try:
                data = path.read_bytes()
                record = json.loads(data)
            except (OSError, ValueError) as error:
                errors.append({"file": str(path), "error": str(error)})
                continue
            if not isinstance(record, dict) or not all(k in record for k in ["command", "started", "rssLimitBytes"]):
                continue
            start, end = record["started"], record.get("finished")
            if not number(start) or start > cutoff or number(end) and end < begin:
                continue
            selected.append({"receipt": pinned(path, data), "record": record})
        discovery = {"command": ["rg", "--files", "--hidden", "--no-ignore", "selfhost/build", "-g", "process.json"],
                     "candidatePaths": len(paths), "mtimePrefilterBefore": args.start,
                     "scope": "All existing process.json paths under selfhost/build, including ignored/hidden trees; only guard-schema records overlapping the window are selected."}
    grouped = defaultdict(list)
    for item in selected:
        r = item["record"]
        grouped[json.dumps([r["started"], r["command"]], sort_keys=True)].append(item)
    rows, duplicates = [], []
    for copies in grouped.values():
        copies.sort(key=lambda x: (not number(x["record"].get("finished")), len(x["receipt"]["file"]), x["receipt"]["file"]))
        chosen = copies[0]
        r = chosen["record"]
        a = max(begin, r["started"])
        b = min(cutoff, r["finished"]) if number(r.get("finished")) else cutoff
        if b < a:
            continue
        closed = number(r.get("finished")) and r["finished"] <= cutoff
        status = ("open receipt at cutoff" if not closed else
                  "timeout" if r.get("stoppedFor") == "deadline" else
                  "guard stop" if r.get("stoppedFor") else
                  "success" if r.get("complete") is True and r.get("returncode") == 0 else "failed")
        row = {"receipt": chosen["receipt"], "aliases": [c["receipt"] for c in copies[1:]],
               "from": a, "to": b, "seconds": b-a, "closedAtCutoff": closed,
               "category": category(chosen["receipt"]["file"], r["command"]),
               "status": status, "returncode": r.get("returncode"), "stoppedFor": r.get("stoppedFor"),
               "recordedWallSeconds": r.get("wallSeconds"), "peakTreeRssBytes": r.get("peakTreeRssBytes"),
               "command": r["command"]}
        rows.append(row)
        if len(copies) > 1:
            duplicates.append({"canonical": row["receipt"], "aliases": row["aliases"]})
    rows.sort(key=lambda r: (r["from"], r["receipt"]["file"]))
    parts = partitions(rows)
    total = union_seconds([(r["from"], r["to"]) for r in rows])
    closed_total = union_seconds([(r["from"], r["to"]) for r in rows if r["closedAtCutoff"]])
    assert abs(total - sum(p["seconds"] for p in parts)) < 1e-6
    assert 0 <= closed_total <= total <= cutoff-begin + 1e-6
    categories = defaultdict(float)
    for p in parts:
        categories[p["category"]] += p["seconds"]
    failures = [r for r in rows if r["status"] not in ["success", "open receipt at cutoff"]]
    report = {"kind": "phase118-guard-time-accounting", "complete": True,
              "method": pinned(method, method.read_bytes()), "windowStart": utc(begin), "windowEnd": utc(cutoff),
              "elapsedSeconds": cutoff-begin, "finishedGuardUnionSeconds": closed_total,
              "guardEnvelopeUnionSeconds": total, "uncoveredElapsedSeconds": cutoff-begin-total,
              "summedReceiptSeconds": sum(r["seconds"] for r in rows),
              "overlapOrNestingSeconds": sum(r["seconds"] for r in rows)-total,
              "uniqueReceipts": len(rows), "statusCounts": dict(Counter(r["status"] for r in rows)),
              "categoryDisjointSeconds": dict(sorted(categories.items())),
              "failedGuardUnionSeconds": union_seconds([(r["from"], r["to"]) for r in failures]),
              "duplicates": duplicates, "rows": rows, "disjointIntervals": parts, "discovery": discovery,
              "unreadable": errors, "limitations": [
                  "Guard wall duration includes subprocess/build/validation/orchestration time, not CPU time.",
                  "An open receipt is an unfinished envelope, not proof its process remains active; it may be stale.",
                  "Categories label outermost named campaigns; bundled API, finite, and target work is not split without timestamps.",
                  "Uncovered elapsed time is unclassified, not thinking time: includes unguarded source work, tools, agents, waiting and possible missing receipts.",
                  "Source/static audits and agent/model tokens, monetary cost, quota, billing and CPU-seconds are not measured here.",
                  "mtime prefilter assumes normal ExecutionGuard writes; backdated/copied receipts outside selfhost/build require an explicit supplemental audit."]}
    out.mkdir(parents=True)
    snapshot = {"discovery": discovery, "unreadable": errors, "receipts": selected}
    (out/"receipts.json").write_text(json.dumps(snapshot, indent=2)+"\n")
    report["snapshot"] = pinned(out/"receipts.json", (out/"receipts.json").read_bytes())
    (out/"report.json").write_text(json.dumps(report, indent=2)+"\n")
    lines = ["# Phase118 observed time accounting", "", f"Window: {utc(begin)} to {utc(cutoff)}.", "",
             f"Elapsed wall time: **{(cutoff-begin)/60:.2f} min**. Finished-guard union: **{closed_total/60:.2f} min**.",
             f"Including open-receipt envelopes: **{total/60:.2f} min**; uncovered elapsed: **{(cutoff-begin-total)/60:.2f} min**.",
             f"{len(rows)} unique receipts; statuses: `{json.dumps(report['statusCounts'], sort_keys=True)}`.",
             f"Summing receipts would count **{report['overlapOrNestingSeconds']/60:.2f} min** of overlap/nesting again.", "",
             "| Outermost named campaign | Disjoint minutes |", "| --- | ---: |"]
    lines += [f"| {k} | {v/60:.2f} |" for k, v in sorted(categories.items(), key=lambda x: -x[1])]
    lines += ["", "Failed/stopped intervals are included above, not discarded. Their union is "
              f"{report['failedGuardUnionSeconds']/60:.2f} min; this is not automatically wasted time.", "",
              "| Failed/stopped guard | Status | Seconds |", "| --- | --- | ---: |"]
    lines += [f"| {Path(r['receipt']['file']).parent.name} | {r['status']} | {r['seconds']:.2f} |" for r in failures]
    lines += ["", "## Limits", ""] + ["- "+x for x in report["limitations"]]
    lines += ["", "The JSON includes pinned receipt snapshots, exact commands, all intervals and category ownership. "
              "Rerun into a fresh directory after active jobs finish; never overwrite this snapshot."]
    (out/"report.md").write_text("\n".join(lines)+"\n")
    print(json.dumps({"out": str(out), "elapsedMinutes": (cutoff-begin)/60,
                      "guardMinutes": total/60, "receipts": len(rows), "statuses": report["statusCounts"]}))


if __name__ == "__main__":
    main()

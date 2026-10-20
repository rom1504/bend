#!/usr/bin/env python3
"""Read emitted QBE only; count sites, never execute or lower a program."""
import argparse
import collections
import hashlib
import json
import pathlib
import re

parser = argparse.ArgumentParser()
parser.add_argument("--ssa", required=True, type=pathlib.Path)
parser.add_argument("--out", required=True, type=pathlib.Path)
args = parser.parse_args()
if args.out.exists():
    raise SystemExit("output already exists")
raw = args.ssa.read_bytes()
text = raw.decode()


def display(symbol):
    match = re.search(r"FID_((?:\d+_)+)", symbol)
    if not match:
        return symbol
    return symbol[:match.start()] + "".join(
        chr(int(word)) for word in match.group(1).split("_") if word
    )


segments_line = next(
    (line for line in text.splitlines()
     if line.startswith("data $p111_segments ")), ""
)
segments = re.findall(r"\$(p111_FID_[^, }]+)", segments_line)
functions = []
totals = collections.Counter()
pattern = r"^(?:export )?function(?: [a-z]+)? \$([^ (]+).*?^}"
for match in re.finditer(pattern, text, re.M | re.S):
    symbol, body = match.group(1), match.group()
    calls = collections.Counter(re.findall(r"call \$([^ (]+)", body))
    runtime = {name: count for name, count in calls.items()
               if name.startswith("p111_rt_")}
    totals.update(runtime)
    targets = []
    for target in re.finditer(
        r"call \$(p111_rt_(?:closure|frame|jump))"
        r"\(l %[^,]+, w (\d+)", body
    ):
        index = int(target.group(2))
        targets.append({
            "operation": target.group(1),
            "fid": index,
            "target": display(segments[index]) if index < len(segments) else None,
        })
    functions.append({
        "symbol": symbol,
        "display": display(symbol),
        "bytes": len(body.encode()),
        "runtimeSites": runtime,
        "directCallSites": {
            display(name): count for name, count in calls.items()
            if not name.startswith("p111_rt_")
        },
        "staticTargets": targets,
    })

report = {
    "kind": "phase113-closure-qbe-static-inspection",
    "complete": True,
    "targetsRun": False,
    "method": {
        "file": str(pathlib.Path(__file__).resolve()),
        "sha256": hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),
    },
    "input": {
        "file": str(args.ssa.resolve()),
        "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
    },
    "scope": "Static sites, including retained fallback bodies; not dynamic counts.",
    "runtimeSiteTotals": dict(totals),
    "functions": functions,
}
args.out.parent.mkdir(parents=True, exist_ok=True)
args.out.write_text(json.dumps(report, indent=2) + "\n")

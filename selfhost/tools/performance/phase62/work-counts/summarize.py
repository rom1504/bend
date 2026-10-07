#!/usr/bin/env python3
"""Read a completed diagnostic report; never execute a compiler."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("report", type=Path)
parser.add_argument("--output", type=Path)
args = parser.parse_args()
report = json.loads(args.report.read_text())
assert report["complete"] and report["pass"]
if args.output:
    assert not args.output.exists()
    compact = {"kind": "phase62-work-counts-summary", "complete": True, "pass": True,
               "diagnosticOnly": True, "productionQualified": False,
               "parent": {"file": str(args.report.resolve()),
                          "sha256": hashlib.sha256(args.report.read_bytes()).hexdigest()},
               "producer": {"file": str(Path(__file__).resolve()),
                            "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},
               "scope": report["scope"], "node": report["node"],
               "image": report["image"], "preparation": report["preparation"],
               "derivations": [{k: d[k] for k in ["role", "originalSha256", "strippedSha256",
                   "outputSha256", "exactInverseToStripped", "parserSha256", "probes", "missing", "scope"]}
                   for d in report["derivations"]], "rows": []}
    for row in report["rows"]:
        item = {k: row[k] for k in ["id", "source", "bendOutput", "typescriptOutput", "rawBytesEqual"]}
        for role in ["bend", "theory", "backend"]:
            block = row[role]
            item[role] = {"totals": {name: sum(v[i] for v in block["phases"].values())
                         for i, name in enumerate(block["names"])},
                         "nonzeroPhases": {phase: {name: v[i] for i, name in enumerate(block["names"])
                                                   if v[i]} for phase, v in block["phases"].items() if any(v)}}
        compact["rows"].append(item)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(compact, indent=2) + "\n")
selected = ["subst", "env_subst_term", "norm_eval", "index_lookup", "jd_arity",
            "jd_domains", "jd_raise", "jd_live_arity", "jd_params", "jd_doc_definition"]

for row in report["rows"]:
    print("\n" + row["id"])
    for role in ["bend", "theory", "backend"]:
        block = row[role]
        totals = {name: sum(values[i] for values in block["phases"].values())
                  for i, name in enumerate(block["names"])}
        keys = selected if role == "bend" else totals
        print(role + ": " + ", ".join(f"{k}={totals[k]:,}" for k in keys if k in totals))
        if role == "backend":
            for name in ["FUNS", "TELES", "OPENS", "SPINES"]:
                calls, misses = (totals[f"memo_{name}_{kind}"] for kind in ["calls", "misses"])
                if calls:
                    print(f"  {name}: {calls:,} requests, {misses:,} misses, {(1-misses/calls):.2%} hit rate")
    bend = row["bend"]
    for phase, counts in bend["phases"].items():
        pairs = [(name, counts[bend["names"].index(name)]) for name in selected if name in bend["names"]]
        if any(value for _, value in pairs):
            print("  " + phase + ": " + ", ".join(f"{name}={value:,}" for name, value in pairs if value))

#!/usr/bin/env python3
"""Data-only bounded latency review; does not run or modify a compiler."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(relative):
    path = ROOT / relative
    return {"file": relative, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def read(relative):
    return json.loads((ROOT / relative).read_text())


baseline_path = "implementation/phase66/evidence/b2-07-broad.json"
ancestry_path = "implementation/phase65/evidence/baseline-state09-target-ancestry.json"
baseline = read(baseline_path)
ancestry = read(ancestry_path)
assert baseline["complete"] and baseline["pass"]
assert ancestry["complete"] and ancestry["pass"]
ratio = baseline["aggregate"]["candidate/typescript_head"]["firstRequestMs"]["geometricMean"]
map_row = next(row for row in baseline["sources"] if row["case"] == "test-map-set-ops")
map_profile = next(row for row in ancestry["rows"]
                   if row["mode"] == "cpu" and row["case"] == "test-map-set-ops")
arity = next(row for row in map_profile["targets"] if row["name"] == "jd_arity")
caller = next(row for row in arity["nearestExactGeneratedAncestors"]
              if row["name"] == "jd_calls_named")
sources = ["selfhost/src/back/js/direct/" + name for name in
           ["calls.bend", "model.bend", "host.bend", "reach.bend"]]
result = {
    "kind": "phase67-bounded-compilation-opportunity-review",
    "complete": True, "dataOnly": True, "targetExecuted": False,
    "productionChanged": False, "decision": "defer",
    "producer": pin(str(Path(__file__).relative_to(ROOT))),
    "inputs": [pin(p) for p in [baseline_path, ancestry_path,
        "selfhost/build/phase66/bootstrap-b2-07/image-pins.json",
        "implementation/phase65/base-products.md",
        "implementation/phase65/measurement.md"] + sources],
    "actualB2": baseline["images"]["candidate"]["api"],
    "current": {"sourceCount": baseline["sourceCount"],
        "compilationRatioToTS": ratio,
        "uniformTimeReductionForParity": 1 - 1 / ratio,
        "mapCompilationMs": map_row["roles"]["candidate"]["firstRequestMs"]["median"],
        "mapTSCompilationMs": map_row["roles"]["typescript_head"]["firstRequestMs"]["median"]},
    "historicalProfileOnly": {"api": map_profile["api"],
        "allAritySampledMicroseconds": arity["inclusiveWeight"],
        "namedCallAritySampledMicroseconds": caller["weight"],
        "allArityCountShare": arity["inclusivePercent"] / 100,
        "scope": "Phase65 baseline, before retained Base annotations and decoder improvement; not a current timing prediction."},
    "rejectedBeforeBuild": "Precompute arities before local tail-call analysis: only the repeated named-call portion is removable; the existing per-definition computation must remain, and a new pass/index adds cost.",
    "nextAdmission": "Resume only after a current Numeric/Map diagnostic identifies >=5% plausible net affected-source saving; keep native primary and do not rebuild merely to try a previously rejected guard.",
    "targetRuns": 0,
}
out = ROOT / "implementation/phase67/evidence/latency-review.json"
assert not out.exists(), out
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"report": pin(str(out.relative_to(ROOT))), "decision": "defer"}))

"""Reprice the remaining opportunities at the measured final fixed-work medians."""
import json
import sys
from collections import defaultdict
from pathlib import Path

summary = json.loads(Path(sys.argv[1]).read_bytes())
assert summary["complete"]
weights = json.loads(Path("research/phase205/weights/results01.json").read_bytes())
families = {c["id"]: c["family"] for c in weights["cases"]}
totals = defaultdict(lambda: dict(cases=0, x86=0.0, c=0.0))
for case in summary["cases"]:
    if case["ratioEligible"]:
        family = totals[families[case["id"]]]
        family["cases"] += 1
        for key, role in [("x86", "candidate"), ("c", "c")]:
            family[key] += case["fixedEquivalentMs"][role] / 1000
for family in totals.values():
    family["savingAtCParity"] = family["x86"] - family["c"]
    family["savingAtDoubleSpeed"] = family["x86"] / 2
print(json.dumps(dict(sorted(totals.items(), key=lambda item: -item[1]["savingAtCParity"])), indent=2))

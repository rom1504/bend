#!/usr/bin/env python3
"""Execute only the reviewed Phase168 retention tranche using maintained tools.

Usage: retention-plan02.py verify | apply | restore
Each action is explicit. Verification never applies. All apply plans are checked
against the reviewed exact file list before the first existing tool invocation.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
POLICY = Path(__file__).resolve().with_name("retention-policy02.json")

def need(value, message):
    if not value:
        raise SystemExit(message)

def authenticate(item):
    path = Path(item["file"])
    if not path.is_absolute():
        path = ROOT / path
    h = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1048576), b""):
            h.update(block)
    need(path.stat().st_size == item["bytes"] and h.hexdigest() == item["sha256"],
         "Changed pinned file: " + str(path))
    return path

def checked(row):
    plan = json.loads((ROOT / row["plan"]).read_text())
    need(plan["complete"] and Path(plan["root"]) == ROOT / row["root"], "Wrong plan root")
    need(authenticate(plan["policy"]) == POLICY, "Wrong policy binding")
    listing = authenticate(plan["files"])
    actual = {}
    for line in listing.read_text().splitlines():
        value = json.loads(line)
        key = str(Path(value["file"]["file"]).relative_to(ROOT))
        need(key not in actual and value["metadata"]["links"] == 1, "Duplicate/shared selection")
        actual[key] = (value["file"]["bytes"], value["file"]["sha256"])
    expected = {v["file"]: (v["bytes"], v["sha256"]) for v in row["selectedFiles"]}
    need(actual == expected and plan["selectedFiles"] == len(expected), "Selection differs")
    need(plan["allocatedBytes"] == row["allocatedBytes"], "Allocation changed")

need(len(sys.argv) == 2 and sys.argv[1] in {"verify", "apply", "restore"},
     "Usage: retention-plan02.py verify|apply|restore")
action = sys.argv[1]
policy = json.loads(POLICY.read_text())
authenticate(policy["method"])
authenticate(policy["runner"])
if action != "verify":
    for row in policy["roots"]:
        checked(row)
for row in policy["roots"]:
    subprocess.run(row[action + "Command"], cwd=ROOT, check=True)
if action == "verify":
    for row in policy["roots"]:
        checked(row)
print(json.dumps({"action": action, "roots": len(policy["roots"]),
                  "selectedFiles": policy["totals"]["selectedFiles"]}))

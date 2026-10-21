"""Read-only static QBE call census; counts are sites, never execution frequency."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def checked(record):
    assert pin(record["file"]) == record, record["file"]
    return Path(record["file"]).read_text()


def census(text):
    calls = collections.Counter(re.findall(r"\bcall \$(p\d+_[A-Za-z0-9_]+)\(", text))
    return {"physicalLines": len(text.splitlines()),
            "functionDefinitions": len(re.findall(r"^(?:export )?function\b", text, re.M)),
            "runtimeCallSites": dict(sorted(calls.items())),
            "wordUnsignedDivisionSites": len(re.findall(r"=w udiv\b", text)),
            "wordUnsignedRemainderSites": len(re.findall(r"=w urem\b", text)),
            "wordFloatConversionSites": len(re.findall(r"=w stoui\b", text))}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    reports = [json.loads(path.read_text()) for path in [args.baseline, args.candidate]]
    assert all(report["complete"] for report in reports)
    cases = [{case["name"]: case for case in report["cases"]} for report in reports]
    assert cases[0].keys() == cases[1].keys()
    rows = []
    for name in cases[0]:
        before, after = (items[name] for items in cases)
        assert before["source"] == after["source"]
        rows.append({"name": name, "source": before["source"],
                     "baselineQbe": before["qbe"], "candidateQbe": after["qbe"],
                     "baseline": census(checked(before["qbe"])),
                     "candidate": census(checked(after["qbe"]))})
    result = {"complete": True, "kind": "phase118-static-qbe-census",
              "scope": "Literal emitted call/instruction sites. No dynamic frequency, hotness, semantic or speed attribution.",
              "inputs": [pin(__file__), pin(args.baseline), pin(args.candidate)], "rows": rows}
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"cases": len(rows), "out": str(args.out)}))


if __name__ == "__main__":
    main()

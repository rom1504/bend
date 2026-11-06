#!/usr/bin/env python3
"""Root-run bounded semantic ABI controls; invoke inside the maintained guard."""
import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path

CASES = [
    "raw-unique", "static", "rfc-unique", "packed-one",
    "shared-one", "shared-two", "shared-three", "shared-four",
    "shared-five-generic", "shared-two-generic", "duplicate-child",
    "parent-maximum", "parent-zero-fallback", "child-last-valid",
    "child-overflow", "duplicate-overflow", "unsealed-last", "unsealed-first",
    "raw-unique-unsealed", "wrong-arity", "wrong-tag",
]
ERRORS = {name: b"bend: runtime fail-stop\n" for name in
          ("child-overflow", "duplicate-overflow", "unsealed-last", "unsealed-first")}
ERRORS["wrong-arity"] = b"bend: phase118: take arity mismatch\n"
ERRORS["wrong-tag"] = b"bend: phase118: expected constructor owner\n"


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def check(saved):
    actual = pin(Path(saved["file"]))
    assert actual["sha256"] == saved["sha256"] and actual["bytes"] == saved["bytes"], saved


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--plan", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    assert not any(out.iterdir()), "fresh empty run root required"
    plan = json.loads(args.plan.read_text())
    for saved in plan["inputs"] + plan["headers"] + [plan["source"]]:
        check(saved)
    source = Path(__file__).with_suffix(".c")
    (out / source.name).write_bytes(source.read_bytes())
    source = out / source.name
    report = {"kind": "phase169-runtime-abi-controls", "complete": False,
              "inputs": [pin(Path(__file__)), pin(source), pin(args.plan)] + plan["inputs"] +
                        plan["headers"] + [plan["source"]], "cases": CASES,
              "jobs": [], "results": []}

    def save():
        (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")

    def run(command, label, limit):
        start = time.monotonic()
        result = subprocess.run(command, capture_output=True, timeout=limit)
        stdout = out / (label + ".stdout")
        stderr = out / (label + ".stderr")
        stdout.write_bytes(result.stdout)
        stderr.write_bytes(result.stderr)
        row = {"label": label, "command": command, "seconds": time.monotonic() - start,
               "exitCode": result.returncode, "stdout": pin(stdout), "stderr": pin(stderr)}
        report["jobs"].append(row)
        save()
        return result

    save()
    for variant in plan["jobs"]:
        name = variant["label"]
        flags = variant["flags"]
        binary = out / name
        # Same compiler and optimization/ABI policy as the actual runtime build.
        command = [variant["compile"][0], "-O2", "-std=gnu11", "-ffp-contract=off",
                   f"-DP144_SINGLE_MUTATOR_RFC={flags['singleMutator']}",
                   f"-DP169_WARM_SPAN={flags['warm']}",
                   f"-DP169_SHARED_TAKE={flags['shared']}",
                   "-I", str(Path(plan["source"]["file"]).parent), str(source),
                   "-pthread", "-lm", "-o", str(binary)]
        result = run(command, name + "-compile", 30)
        assert result.returncode == 0, name + " compilation failed"
        for case in CASES:
            result = run([str(binary), case], name + "-" + case, 5)
            expected = (case + ": complete state PASS\n").encode()
            ok = result.returncode == 0 and result.stdout == expected and result.stderr == ERRORS.get(case, b"")
            report["results"].append({"variant": name, "case": case, "pass": ok,
                                      "expectedStdout": expected.decode(),
                                      "expectedStderr": ERRORS.get(case, b"").decode()})
            save()
            assert ok, (name, case)
    for saved in report["inputs"]:
        check(saved)
    report["complete"] = True
    report["semanticRows"] = len(report["results"])
    report["scope"] = "Finite runtime state/field/refcount/free-list/error-order controls, not a compiler proof or multiworker qualification"
    save()
    print(json.dumps({"report": str(out / "report.json"), "complete": True,
                      "semanticRows": report["semanticRows"]}))


if __name__ == "__main__":
    main()

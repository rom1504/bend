#!/usr/bin/env python3
"""Prepare matched baseline/candidate scalar-facts source jobs; execute no targets."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--baseline", type=Path, required=True)
    p.add_argument("--candidate", type=Path, required=True)
    p.add_argument("--runtime", type=Path, required=True)
    p.add_argument("--prefix", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    a = p.parse_args()
    prefix = a.prefix.resolve()
    if not prefix.is_relative_to(ROOT / "selfhost/build/phase111") or a.out.exists():
        raise ValueError("Fresh plan and Phase111 path prefix required")
    manifest_path = HERE / "native-manifest01.json"
    manifest = json.loads(manifest_path.read_text())
    for row in manifest["inputs"]:
        actual = pin(ROOT / row["file"])
        if any(actual[k] != row[k] for k in ("bytes", "sha256")):
            raise ValueError("Frozen source/method changed: " + row["file"])
    jobs = []
    for label, api in [("baseline", a.baseline.resolve()), ("candidate", a.candidate.resolve())]:
        receipt_path = api.parent / "report.json"
        receipt = json.loads(receipt_path.read_text())
        required = ["p88_cache_prepare", "p86_prepare", "p86_plan",
                    "p111_runtime_admission", "p113d_lower_request", "p113d_verify", "p113d_chunks"]
        if not receipt.get("complete") or not receipt.get("checked") or \
                not all(x in receipt.get("exports", []) for x in required):
            raise ValueError("Complete checked direct staged API required")
        for case in manifest["cases"]:
            stem = str(prefix) + "-" + label + "-" + case["name"]
            emit, build, observe = [Path(stem + "-" + suffix) for suffix in ("emit", "build", "observe")]
            if any(x.exists() for x in (emit, build, observe)):
                raise ValueError("Output already exists: " + stem)
            jobs.extend([
                dict(name=label+"-"+case["name"]+"-emit", seconds=60, command=[
                    receipt["command"][0], str(ROOT / "selfhost/tools/performance/phase113/staged-emit.mjs"),
                    str(api), str(ROOT / case["source"]), str(emit), "cache", "direct"]),
                dict(name=label+"-"+case["name"]+"-build", seconds=60, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase111/build.py"),
                    "--source", str(emit / "program.ssa"), "--runtime", str(a.runtime.resolve()),
                    "--out", str(build)]),
                dict(name=label+"-"+case["name"]+"-observe", seconds=20, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase112/observe.py"),
                    "--binary", str(build / "program"), "--expected", str(ROOT / case["expected"]),
                    "--out", str(observe)])
            ])
    a.out.parent.mkdir(parents=True, exist_ok=True)
    report = dict(kind="phase113-independent-scalar-facts-native-jobs", targetsRun=False,
                  inputs=[pin(manifest_path), pin(__file__), pin(a.baseline), pin(a.candidate), pin(a.runtime)],
                  jobs=jobs, scope="Exact source execution parity; emitted guard-removal is a separate required optimization witness.")
    a.out.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(dict(plan=str(a.out), jobs=len(jobs), targetsRun=False)))


if __name__ == "__main__":
    main()

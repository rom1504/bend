#!/usr/bin/env python3
"""Prepare matched baseline/candidate field and array source jobs; execute no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
HELPER = HERE.parents[1]/"bench/transport-v2.py"
spec = importlib.util.spec_from_file_location("phase113_transport_v2", HELPER)
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--baseline", type=Path, required=True)
    p.add_argument("--candidate", type=Path, required=True)
    p.add_argument("--baseline-pipeline", choices=["direct", "array"], default="direct")
    p.add_argument("--candidate-pipeline", choices=["direct", "array"], default="array")
    p.add_argument("--array-controls-out", type=Path,
                   help="Optionally prepend candidate array structural controls at this fresh Phase113 output")
    p.add_argument("--runtime", type=Path, required=True)
    p.add_argument("--prefix", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--names", nargs="+")
    a = p.parse_args()
    prefix = a.prefix.resolve()
    if not prefix.is_relative_to(ROOT / "selfhost/build/phase111") or a.out.exists():
        raise ValueError("Fresh plan and Phase111 path prefix required")
    manifest_path = HERE / "source-manifest01.json"
    manifest = json.loads(manifest_path.read_text())
    for row in manifest["inputs"]:
        actual = pin(ROOT / row["file"])
        if any(actual[k] != row[k] for k in ("bytes", "sha256")):
            raise ValueError("Frozen source/method changed: " + row["file"])
    selected = a.names or [case["name"] for case in manifest["cases"]]
    if len(selected) != len(set(selected)) or set(selected) - {case["name"] for case in manifest["cases"]}:
        raise ValueError("Unknown or duplicate case name")
    runtime = a.runtime.resolve()
    if runtime.is_dir():
        runtime /= "runtime.o"
    emitter = HERE.parents[1]/"staged-emit-v2.mjs"
    jobs, roles = [], {}
    inputs = [pin(manifest_path), pin(__file__), pin(HELPER), pin(emitter), pin(runtime)]
    inputs += [dict(row, file=str((ROOT/row["file"]).resolve())) for row in manifest["inputs"]]
    for label, api, pipeline in [("baseline", a.baseline.resolve(), a.baseline_pipeline),
                                 ("candidate", a.candidate.resolve(), a.candidate_pipeline)]:
        if api.is_dir():
            api /= "api.mjs"
        receipt_path = api.parent / "report.json"
        receipt = json.loads(receipt_path.read_text())
        if not receipt.get("complete") or not receipt.get("checked") or receipt["api"] != pin(api):
            raise ValueError("Complete exact checked staged API required")
        contract = transport.select_exports(receipt, pipeline)
        roles[label] = dict(api=pin(api), apiReceipt=pin(receipt_path), pipeline=pipeline, **contract)
        inputs += [pin(api), pin(receipt_path), *receipt["inputs"]]
        if label == "candidate" and a.array_controls_out:
            controls = HERE.parents[1]/"array-fast/controls-v2.mjs"
            controls_out = a.array_controls_out.resolve()
            required = ["p113a_verify", "p113a_chunks", "p113a_stmt_id", "p113a_template",
                        "p113a_scan", "p113a_heap_min", "p113a_enabled", "p113a_body_names", "p113d_verify"]
            if (pipeline != "array" or not set(required).issubset(receipt.get("exports", [])) or
                    controls_out.exists() or not controls_out.is_relative_to(ROOT/"selfhost/build/phase113")):
                raise ValueError("Array controls need checked exports and fresh Phase113 output")
            inputs.append(pin(controls))
            jobs.insert(0, dict(name="candidate-array-structural-controls", seconds=60,
                               command=[receipt["command"][0], str(controls), str(api), str(controls_out)]))
        for case in manifest["cases"]:
            if case["name"] not in selected:
                continue
            stem = str(prefix) + "-" + label + "-" + case["name"]
            emit, build, observe = [Path(stem + "-" + suffix) for suffix in ("emit", "build", "observe")]
            if any(x.exists() for x in (emit, build, observe)):
                raise ValueError("Output already exists: " + stem)
            jobs.extend([
                dict(name=label+"-"+case["name"]+"-emit", seconds=60, command=[
                    receipt["command"][0], str(emitter),
                    str(api), str(ROOT / case["source"]), str(emit), "cache", pipeline]),
                dict(name=label+"-"+case["name"]+"-build", seconds=60, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase111/build.py"),
                    "--source", str(emit / "program.ssa"), "--runtime", str(runtime),
                    "--out", str(build)]),
                dict(name=label+"-"+case["name"]+"-observe", seconds=20, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase112/observe.py"),
                    "--binary", str(build / "program"), "--expected", str(ROOT / case["expected"]),
                    "--out", str(observe)])
            ])
    for row in inputs:
        if pin(row["file"]) != row:
            raise ValueError("Changed pinned input: " + row["file"])
    a.out.parent.mkdir(parents=True, exist_ok=True)
    report = dict(kind="phase113-independent-field-array-jobs", version=2, transportVersion=2, targetsRun=False,
                  inputs=list({row["file"]: row for row in inputs}.values()), roles=roles,
                  names=selected, manifest=pin(manifest_path), runtime=pin(runtime),
                  jobs=jobs, scope="Exact frozen source execution parity through explicitly recorded baseline/candidate pipelines. Optional array structural controls are separate from source/native/runtime qualification.")
    a.out.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(dict(plan=str(a.out), jobs=len(jobs), targetsRun=False)))


if __name__ == "__main__":
    main()

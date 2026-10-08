#!/usr/bin/env python3
"""Prepare one existing paired native gate, without running any target."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
RAW = ROOT / "selfhost/build/phase68"


def pin(value):
    item = value if isinstance(value, dict) else None
    path = Path(item.get("file", item.get("path")) if item else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert result["sha256"] == item["sha256"], path
        if "bytes" in item:
            assert result["bytes"] == item["bytes"], path
        if "canonicalPath" in item:
            assert str(path) == item["canonicalPath"], path
    return result


def write(path, value):
    with path.open("x") as stream:
        stream.write(json.dumps(value, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--toolchain-recipe", type=Path, required=True)
    parser.add_argument("--set", choices=["prefix-retry"], required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}, "source/data preparation belongs on CPU0"
    output = args.out.resolve()
    output.relative_to(RAW)
    assert not output.exists(), output
    attempt_dir = args.attempt.resolve(strict=True)
    attempt_pin = pin(attempt_dir / "attempt.json")
    attempt = json.loads(Path(attempt_pin["file"]).read_text())
    assert attempt["checked"] and attempt["config"]["strictExact"]
    snapshot = Path(attempt["snapshot"]["root"]).resolve(strict=True)
    snapshot.relative_to(RAW)  # validation primes this snapshot; old raw stays closed.
    assert attempt["config"]["jobs"] == 1 and str(attempt["config"]["cpu"]) == "3"
    assert attempt["config"]["heapMb"] <= 1024
    inputs = [attempt_pin, pin(__file__)]
    inputs += [pin(attempt[k]) for k in ["api", "checkedApi", "base", "runtime", "node"]]
    inputs += [pin(row["frozen"]) for row in attempt["snapshot"]["sources"]]
    toolchain_pin = pin(args.toolchain_recipe)
    toolchain = json.loads(Path(toolchain_pin["file"]).read_text())
    assert toolchain["kind"] == "phase67-native-method-v2"
    inputs.append(toolchain_pin)
    inputs += [pin(row) for row in toolchain["inputs"]]
    assert toolchain["clangArgs"][0] == "-isystem"
    clang, headers = Path(toolchain["clang"]).resolve(strict=True), Path(toolchain["clangArgs"][1]).resolve(strict=True)
    inputs.append(pin(clang))
    catalog_pin = pin(HERE / "catalog-v1.json")
    catalog = json.loads(Path(catalog_pin["file"]).read_text())
    assert catalog["targetExecuted"] is False
    upstream = Path(attempt["config"]["upstream"]).resolve(strict=True)
    assert upstream == Path(catalog["reference"]).resolve(strict=True)
    assert pin(upstream / "bend2/base.bend")["sha256"] == attempt["base"]["sha256"]
    wanted = catalog["sets"][args.set]
    cases = {row["id"]: row for row in catalog["cases"]}
    assert len(wanted) == len(set(wanted))
    selection_pin = pin(HERE / (args.set + "-selection.json"))
    selection = json.loads(Path(selection_pin["file"]).read_text())
    assert [row["id"] for row in selection["cases"]] == wanted
    for row in selection["cases"]:
        case = cases[row["id"]]
        source = pin(case["source"])
        assert row["lanes"] == ["native"]
        assert case["goldenLines"] == [line[2:] for line in Path(source["file"]).read_text().splitlines() if line.startswith("#|")]
        if case["external"]:
            assert Path(row["file"]).resolve(strict=True) == Path(source["file"])
        else:
            assert Path(source["file"]) == upstream / "tests" / row["id"]
        inputs.append(source)
    inputs += [catalog_pin, selection_pin]
    workflow = snapshot / "tools/development/workflow.mjs"
    guard = ROOT / "selfhost/tools/performance/phase32/bounded-run.py"
    inputs += [pin(workflow), pin(guard)]
    output.mkdir(parents=True)
    frozen_selection = output / "selection.json"
    write(frozen_selection, selection)
    command = ["python3", "-B", str(guard), "--seconds", "900" if args.set == "integration" else "360",
        "--rss-mib", "2048", "--available-mib", "4096", str(output / "supervisor"), "--", "env",
        "CC=" + str(clang), "CPATH=" + str(headers), "NODE_OPTIONS=", "NODE_PATH=",
        attempt["node"]["file"], "--max-old-space-size=1024", "--stack-size=4096", str(workflow),
        "validate", str(attempt_dir), str(frozen_selection), str(output / "execution")]
    result = dict(kind="phase68-native-selected-control-plan", complete=False, targetExecuted=False,
        producer=pin(__file__), attempt=attempt_pin, selectedApi=pin(attempt["api"]),
        set=args.set, expectedCases=len(wanted), selection=pin(frozen_selection),
        report=str(output / "execution/report.json"), command=command, inputs=inputs,
        scope="Existing paired workflow and unchanged independent fixture goldens; no test framework or compiler changes. Outer orchestration unrestricted, target workers pinned by checked config CPU3/jobs1. No timing or all-native-conformance claim.")
    for item in inputs:
        pin(item)
    write(output / "plan.json", result)
    print(json.dumps(dict(plan=pin(output / "plan.json"), expectedCases=len(wanted), targetsExecuted=False)))


if __name__ == "__main__":
    main()

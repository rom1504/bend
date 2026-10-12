#!/usr/bin/env python3
"""Prepare one existing paired native gate, without running any target."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path('/home/ai/bend2/build/publish/bend')
HERE = ROOT / 'selfhost/tools/performance/phase68/controls/integration-v3'
RAW = ROOT / "selfhost/build/phase76"


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
    parser.add_argument("--selection", type=Path, action="append", required=True)
    parser.add_argument("--expected-cases", type=int, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    assert 0 < args.expected_cases <= 100
    # Preserve the parent's existing short/integration deadline choices.
    args.set = "integration" if args.expected_cases > 10 else "custom"
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
    upstream = Path(attempt["config"]["upstream"]).resolve(strict=True)
    assert upstream == (ROOT / "selfhost/.bootstrap/upstream-phase66").resolve(strict=True)
    assert pin(upstream / "bend2/base.bend")["sha256"] == attempt["base"]["sha256"]
    selections, cases, duplicate_ids, goldens = [], {}, [], []
    for path in args.selection:
        selection_pin = pin(path)
        selected = json.loads(Path(selection_pin["file"]).read_text())
        assert set(selected) == {"cases"} and isinstance(selected["cases"], list)
        assert selected["cases"], path
        inputs.append(selection_pin)
        selections.append(selection_pin)
        for row in selected["cases"]:
            assert set(row) == {"id", "file", "lanes"}, row
            assert isinstance(row["id"], str) and row["id"] and row["lanes"] == ["native"]
            file = Path(row["file"])
            assert file.is_absolute() and file.suffix == ".bend", file
            source = pin(file)
            assert str(file) == source["file"], "Use canonical absolute fixture paths"
            golden = [line[2:] for line in file.read_text().splitlines() if line.startswith("#|")]
            assert golden, (row["id"], "Each selected source needs an explicit #| golden")
            if row["id"] in cases:
                assert cases[row["id"]] == row, (row["id"], "Conflicting duplicate selection")
                duplicate_ids.append(dict(id=row["id"], selection=selection_pin))
                continue
            cases[row["id"]] = row
            inputs.append(source)
            goldens.append(dict(id=row["id"], source=source, goldenLines=golden))
    wanted = list(cases)
    assert len(wanted) == args.expected_cases, (len(wanted), args.expected_cases)
    selection = dict(cases=list(cases.values()))
    inputs.append(pin(Path(__file__).with_suffix(".derivation.json")))
    workflow = snapshot / "tools/development/workflow.mjs"
    guard = ROOT / "selfhost/tools/performance/phase32/bounded-run.py"
    inputs += [pin(workflow), pin(guard)]
    output.mkdir(parents=True)
    frozen_selection = output / "selection.json"
    write(frozen_selection, selection)
    original_workflow = pin(workflow)
    source = workflow.read_text()
    replacements = []
    for specifier in ['../conformance/inventory.mjs', './process.mjs', '../typed-driver.mjs']:
        old = "from '" + specifier + "';"
        new = 'from ' + json.dumps((workflow.parent / specifier).resolve().as_uri()) + ';'
        assert source.count(old) == 1
        source = source.replace(old, new)
        replacements.append(dict(before=old, after=new, count=1))
    for old, new in [('import.meta.dirname', json.dumps(str(workflow.parent))), ("retain:'failed'", "retain:'all'")]:
        count = source.count(old)
        assert count > 0 and (old != "retain:'failed'" or count == 1)
        source = source.replace(old, new)
        replacements.append(dict(before=old, after=new, count=count))
    workflow = output / 'workflow-retained.mjs'
    workflow.write_text(source)
    derivative = dict(parent=original_workflow, candidate=pin(workflow), edits=replacements,
        scope='Exact maintained workflow with source-relative dependencies pinned to the same checked snapshot; only selected artifact retention changes failed to all. Oracles, guards, phases and compiler calls unchanged.')
    write(output / 'workflow-derivation.json', derivative)
    inputs += [pin(workflow), pin(output / 'workflow-derivation.json')]
    command = ["python3", "-B", str(guard), "--seconds", "900" if args.set == "integration" else "360",
        "--rss-mib", "2048", "--available-mib", "4096", str(output / "supervisor"), "--", "env",
        "CC=" + str(clang), "CPATH=" + str(headers), "NODE_OPTIONS=", "NODE_PATH=",
        attempt["node"]["file"], "--max-old-space-size=1024", "--stack-size=4096", str(workflow),
        "validate", str(attempt_dir), str(frozen_selection), str(output / "execution")]
    result = dict(kind="phase69-native-custom-control-plan", complete=False, targetExecuted=False,
        producer=pin(__file__), attempt=attempt_pin, selectedApi=pin(attempt["api"]),
        set="custom", expectedCases=len(wanted), selection=pin(frozen_selection),
        originalSelections=selections, identicalDuplicateIds=duplicate_ids, fixtureGoldens=goldens,
        report=str(output / "execution/report.json"), command=command, inputs=inputs,
        scope="Existing paired workflow and literal source #| goldens from explicit native selections. Identical duplicate IDs are listed and merged; conflicts and unexpected case counts refuse. Retained C, snapshot/recipe pins, CC environment and resource guard are unchanged. The inherited deadline is360s for up to10cases,900s above10. Outer orchestration unrestricted, target workers CPU3/jobs1. No target success, performance or all-native-conformance claim.")
    for item in inputs:
        pin(item)
    write(output / "plan.json", result)
    print(json.dumps(dict(plan=pin(output / "plan.json"), expectedCases=len(wanted), targetsExecuted=False)))


if __name__ == "__main__":
    main()

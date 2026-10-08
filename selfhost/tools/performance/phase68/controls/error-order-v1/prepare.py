#!/usr/bin/env python3
"""Derive a tiny diagnostic selection from an already pinned Phase68 gate."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent

def pin(value):
    item = value if isinstance(value, dict) else None
    path = Path(item.get("file", item.get("path")) if item else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert result["sha256"] == item["sha256"]
        if "bytes" in item:
            assert result["bytes"] == item["bytes"]
    return result

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--parent", type=Path, required=True)
    p.add_argument("--set", choices=["required", "characterization"], default="characterization")
    p.add_argument("--out", type=Path, required=True)
    a = p.parse_args()
    assert os.sched_getaffinity(0) == {0}
    parent_pin = pin(a.parent)
    parent = json.loads(Path(parent_pin["file"]).read_text())
    assert parent["kind"] == "phase68-native-selected-control-plan" and not parent["targetExecuted"]
    inputs = [pin(x) for x in parent["inputs"]] + [parent_pin, pin(__file__)]
    manifest_pin = pin(HERE / "manifest.json")
    manifest = json.loads(Path(manifest_pin["file"]).read_text())
    assert manifest["targetExecuted"] is False
    inputs += [manifest_pin, pin(manifest["referenceSource"])]
    sources = {x["id"]: x for x in manifest["sources"]}
    selection_pin = pin(HERE / (a.set + "-selection.json"))
    selection = json.loads(Path(selection_pin["file"]).read_text())
    assert len(selection["cases"]) == (2 if a.set == "required" else 3)
    for row in selection["cases"]:
        source = sources[row["id"]]
        assert row["file"] == source["file"] and row["lanes"] == ["native"]
        inputs.append(pin(source))
        assert source["goldenLines"] == [line[2:] for line in Path(source["file"]).read_text().splitlines() if line.startswith("#|")]
    inputs.append(selection_pin)
    output = a.out.resolve()
    output.relative_to(ROOT / "selfhost/build/phase68")
    assert not output.exists()
    old = str(a.parent.resolve().parent)
    assert sum(old in word for word in parent["command"]) == 3
    command = [word.replace(old, str(output)) for word in parent["command"]]
    output.mkdir(parents=True)
    (output / "selection.json").write_text(json.dumps(selection, indent=2) + "\n")
    result = dict(kind="phase68-native-error-order-plan", complete=False, targetExecuted=False,
        producer=pin(__file__), parent=parent_pin, attempt=parent["attempt"], selectedApi=parent["selectedApi"],
        selection=pin(output / "selection.json"), expectedCases=len(selection["cases"]), command=command,
        report=str(output / "execution/report.json"), inputs=inputs,
        scope="Fresh paired native error-order observations. Expected nonzero exits must match independent fixture text. Partial-call mismatch may characterize an inherited divergence; it is never relabelled passing.")
    for row in inputs:
        pin(row)
    (output / "plan.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(dict(plan=pin(output / "plan.json"), targetsExecuted=False)))

if __name__ == "__main__":
    main()

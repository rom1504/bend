#!/usr/bin/env python3
"""Summarize completed ownership receipts; no compiler or benchmark execution."""
import hashlib
import json
import math
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[5]


def load(relative):
    path = ROOT / relative
    data = path.read_bytes()
    value = json.loads(data)
    assert value.get("complete"), relative
    return value, {"file": str(path), "bytes": len(data),
                   "sha256": hashlib.sha256(data).hexdigest()}


def main():
    screen, screen_pin = load("selfhost/build/phase135/ownership-compare01/report.json")
    guard, guard_pin = load("selfhost/build/phase135/ownership-compare-guard01/process.json")
    finite, finite_pin = load("selfhost/build/phase135/ownership-finite01/report.json")
    api, api_pin = load("selfhost/build/phase111/p135-ownership-api01/report.json")
    native, native_pin = load("selfhost/build/phase135/machine-session01/report.json")
    assert api["checked"] and api["status"] == 0 and guard["returncode"] == 0
    assert len(screen["rows"]) == 18 and all(
        row["complete"] and row["exactFrozen"] for row in screen["rows"])
    assert screen["rounds"] == 2 and len(screen["pairs"]) == 6
    assert len(finite["groups"]) == 1
    controls = finite["groups"][0]
    assert controls["complete"] and len(controls["rows"]) == controls["expectedCount"] == 29
    assert all(row.startswith("PASS ") for row in controls["rows"])
    metrics = ("indexedOverParentBackend", "indexedOverWrapperBackend",
               "wrapperOverParentBackend", "indexedOverParentWhole")
    cases = []
    for name in dict.fromkeys(row["name"] for row in screen["pairs"]):
        pairs = [row for row in screen["pairs"] if row["name"] == name]
        assert {row["round"] for row in pairs} == {0, 1}
        cases.append({"name": name, "pairs": pairs, "geometricRatios": {
            key: math.exp(sum(math.log(row[key]) for row in pairs) / 2)
            for key in metrics}})
    stages = native["stats"]["stages"]["B"]
    total_ms = native["stats"]["requests"]["B"]["milliseconds"]
    assert sum(stages.values()) == total_ms
    method = pathlib.Path(__file__).read_bytes()
    result = {
        "kind": "phase135-ownership-hosted-screen-summary", "complete": True,
        "targetsRun": False, "productionAdopted": False,
        "method": {"file": str(pathlib.Path(__file__).resolve()), "bytes": len(method),
                   "sha256": hashlib.sha256(method).hexdigest()},
        "inputs": [screen_pin, guard_pin, finite_pin, api_pin, native_pin],
        "controlsPassed": 29, "exactQbeProducts": 18, "rounds": 2, "cases": cases,
        "screenCost": {"guardSeconds": guard["wallSeconds"],
                       "harnessSeconds": screen["seconds"],
                       "peakRssBytes": screen["peakRssBytes"]},
        "separateNativeStageObservation": {
            "ownershipIndexIncluded": False, "editedRequestSeconds": total_ms / 1000,
            "stages": {name: {"seconds": ms / 1000, "fraction": ms / total_ms}
                       for name, ms in stages.items()}},
        "limitations": [
            "Two alternating-order hosted observations, with JIT/GC variance; no native candidate timing.",
            "Indexed round0 builds the cache; round1 reuses it. Order and acquisition state are confounded.",
            "Identical source repeated; finite invalidation controls are not a timed actual-edit campaign.",
            "Whole computation excludes Base seed acquisition and host output transport.",
            "Separate native stage observations use an unindexed image and include FIFO backpressure.",
            "No cross-family aggregate or default integration is justified by this screen."]}
    out = ROOT / "implementation/phase135/preparation/summary.json"
    assert not out.exists(), "Preserve the completed summary; use a new version"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"out": str(out), "cases": cases, "targetsRun": False}))


if __name__ == "__main__":
    main()

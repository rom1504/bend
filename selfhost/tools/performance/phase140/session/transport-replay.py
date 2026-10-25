#!/usr/bin/env python3
"""Bounded old/new byte-transport replay of retained native frames; no compiler."""
import argparse
import importlib.util
import json
from pathlib import Path
import resource
import time

HERE = Path(__file__).resolve().parent


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--session", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--labels", nargs="+", choices=["a", "b"], default=["b"])
    parser.add_argument("--order", nargs="+", choices=["old", "new"], default=["old", "new"])
    args = parser.parse_args()
    assert not args.out.exists()
    old = load("old_transport", HERE / "transport.py")
    new = load("new_transport", HERE / "transport-v02.py")
    session = json.loads(args.session.read_text())
    assert session["complete"] and session["nativeCompleted"] and session["exitCode"] == 0
    sources = args.session.resolve().parent
    inputs = [new.pin(__file__), new.pin(HERE / "transport.py"), new.pin(HERE / "transport-v02.py"), new.pin(args.session)]
    references = {row["label"]: row for row in session["transport"]}
    frames = {Path(row["file"]).stem: row for row in session["frames"]}
    for label in args.labels:
        inputs.extend([references[label]["receipt"], references[label]["payload"], frames[label], new.pin(sources / (label + "-context.json"))])
    inputs.extend([references["a"]["receipt"], references["a"]["payload"]])
    seen = set()
    for identity in inputs:
        new.verify(identity, seen)
    args.out.mkdir(parents=True)
    report = {"kind": "phase140-byte-transport-replay", "complete": False, "compilerTargetsRun": False,
              "scope": "Same retained frames/prior map; byte equivalence, not independent source semantics or native compilation",
              "order": args.order, "inputs": inputs, "rows": []}
    try:
        for label in args.labels:
            reference = references[label]
            context = sources / (label + "-context.json")
            context_sha = new.pin(context)["sha256"]
            for index, version in enumerate(args.order):
                module = old if version == "old" else new
                output = args.out / f"{label}-{index}-{version}"
                cpu0 = resource.getrusage(resource.RUSAGE_SELF)
                with Path(frames[label]["file"]).open("rb") as stream:
                    start = time.perf_counter()
                    decoded = module.decode(stream, output, context, context_sha,
                      references["a"]["receipt"]["file"] if label == "b" else None,
                      references["a"]["receipt"]["sha256"] if label == "b" else None,
                      reference["payload"]["sha256"])
                    seconds = time.perf_counter() - start
                cpu1 = resource.getrusage(resource.RUSAGE_SELF)
                for key in ("pieces", "reusedPieces", "freshBytes", "reusedBytes"):
                    assert decoded[key] == reference[key]
                assert decoded["payload"]["bytes"] == reference["payload"]["bytes"]
                assert decoded["wire"] == {key: frames[label][key] for key in ("bytes", "sha256")}
                report["rows"].append(dict(label=label, version=version, seconds=seconds,
                  cpuSeconds=(cpu1.ru_utime + cpu1.ru_stime) - (cpu0.ru_utime + cpu0.ru_stime),
                  receipt=new.pin(output / "report.json"), payload=decoded["payload"],
                  pieces=decoded["pieces"], reusedPieces=decoded["reusedPieces"]))
        seen = set()
        for identity in inputs:
            new.verify(identity, seen)
        report["complete"] = True
    finally:
        (args.out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"complete": report["complete"], "rows": report["rows"], "report": new.pin(args.out / "report.json")}))


if __name__ == "__main__":
    main()

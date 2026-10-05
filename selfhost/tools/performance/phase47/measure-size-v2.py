#!/usr/bin/env python3
"""Three-way static accounting, retaining the consumed array04 producer unchanged."""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import sys

sys.dont_write_bytecode = True
SUPPORT = pathlib.Path(__file__).with_name("measure-size.py").resolve(strict=True)
SUPPORT_SHA = "8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681"
assert hashlib.sha256(SUPPORT.read_bytes()).hexdigest() == SUPPORT_SHA
SPEC = importlib.util.spec_from_file_location("phase47_size_v1", SUPPORT)
V1 = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V1)


def source_delta(before, after):
    a = {row["module"]: row for row in before["files"]}
    b = {row["module"]: row for row in after["files"]}
    changed = []
    for module in sorted(set(a) | set(b)):
        old, new = a.get(module), b.get(module)
        if old is None or new is None or old["sha256"] != new["sha256"]:
            changed.append({"module": module, "delta": {
                key: (new[key] if new else 0) - (old[key] if old else 0)
                for key in V1.counts(b"")}})
    return {"totals": V1.delta(before["totals"], after["totals"]), "changedModules": changed}


def measure(args):
    producer = V1.read(__file__)
    V1.read(SUPPORT, SUPPORT_SHA)
    V1.read(sys.executable)
    roles, attempts, cores, bundles, modules, compilers = {}, {}, {}, {}, {}, {}
    for role in ("baseline", "previous", "candidate"):
        roles[role], attempts[role], cores[role] = V1.snapshot(getattr(args, role + "_attempt"))
        bundles[role], modules[role], compilers[role] = V1.bundle(getattr(args, role + "_bundle"), attempts[role])
        assert len(modules[role]) == 45
        assert bundles[role]["catalogSha256"] == bundles["baseline"]["catalogSha256"]
        assert set(modules[role]) == set(modules["baseline"])
    blocks = {"baseline": b""}
    runtime_blocks = {}
    for role in ("previous", "candidate"):
        block = V1.insertion(cores["baseline"], cores[role])
        before = V1.read_record(attempts["baseline"]["runtime"])
        after = V1.read_record(attempts[role]["runtime"])
        assert after.count(block) == 1 and after.replace(block, b"", 1) == before
        blocks[role] = block
        runtime_blocks[role] = {"bytes": len(block), "physicalLines": len(block.splitlines()),
                               "sha256": hashlib.sha256(block).hexdigest(), "text": block.decode(),
                               "assembledRuntimeExactInsertionOnly": True}
    cases = {role: {case["id"]: case for case in bundle["cases"]} for role, bundle in bundles.items()}
    rows, variants, seen = [], [], {}
    for case in bundles["candidate"]["cases"]:
        key, source = case["id"], case["sourceSha256"]
        images, stripped = {}, {}
        for role in roles:
            observed = cases[role][key]
            assert observed["sourceSha256"] == source and observed["point"] == case["point"]
            path, data = modules[role][key]
            images[role] = V1.identity(path, data)
            if blocks[role]:
                assert data.count(blocks[role]) == 1
                stripped[role] = data.replace(blocks[role], b"", 1)
            else:
                stripped[role] = data
        row = {"id": key, "sourceSha256": source, "module": modules["candidate"][key][0].name,
               "images": images, "deltaFromBaselineBytes": images["candidate"]["bytes"] - images["baseline"]["bytes"],
               "deltaFromPreviousBytes": images["candidate"]["bytes"] - images["previous"]["bytes"],
               "sameBodyAsBaseline": stripped["candidate"] == stripped["baseline"],
               "sameBodyAsPrevious": stripped["candidate"] == stripped["previous"],
               "bodyHashes": {role: hashlib.sha256(data).hexdigest() for role, data in stripped.items()}}
        if source in seen:
            if modules["candidate"][key][0] != seen[source]:
                variants.append(row)
            continue
        seen[source] = modules["candidate"][key][0]
        for role in roles:
            V1.emission_receipt(modules[role][key][0], source, compilers[role], roles[role]["attempt"])
        rows.append(row)
    assert len(rows) == 23
    report = {"kind": "phase47-three-way-static-size-accounting", "schemaVersion": 2,
              "complete": True, "pass": True, "producer": V1.identity(__file__, producer),
              "supportProducer": V1.INPUTS[str(SUPPORT)], "python": sys.version,
              "command": [sys.executable, *sys.argv], "upstreamCommit": V1.UPSTREAM,
              "scope": {"source": "Frozen manifest-listed Bend modules; code excludes blank/#-comment lines. Declaration counts are syntactic proxies.",
                        "runtime": "Each role's exact core insertion relative to baseline is verified in its assembled runtime; source growth is not counted twice.",
                        "libraries": "First manifest entry per exact source; derived observation adapters are separate; full sizes include runtime.",
                        "bodyComparison": "Remove each role's exact unique runtime insertion before comparing whole-module bytes.",
                        "execution": "Data-only file analysis. No compiler, emitted module or target program executes."},
              "roles": roles, "sourceBaselineToCandidate": source_delta(roles["baseline"], roles["candidate"]),
              "sourcePreviousToCandidate": source_delta(roles["previous"], roles["candidate"]),
              "runtimeBlocksRelativeToBaseline": runtime_blocks,
              "libraries": {"uniqueSources": len(rows),
                            "sameBodyAsBaseline": sum(row["sameBodyAsBaseline"] for row in rows),
                            "sameBodyAsPrevious": sum(row["sameBodyAsPrevious"] for row in rows),
                            "totalBytes": {role: sum(row["images"][role]["bytes"] for row in rows) for role in roles},
                            "rows": rows, "derivedVariants": variants}}
    for path, expected in V1.INPUTS.items():
        assert V1.identity(path, pathlib.Path(path).read_bytes()) == expected, f"Changed input at final rehash: {path}"
    report["inputs"] = list(V1.INPUTS.values())
    report["finalRehash"] = {"pass": True, "files": len(V1.INPUTS)}
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for role in ("baseline", "previous", "candidate"):
        parser.add_argument(f"--{role}-attempt", type=pathlib.Path, required=True)
        parser.add_argument(f"--{role}-bundle", type=pathlib.Path, required=True)
    parser.add_argument("--out", type=pathlib.Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), f"Refusing to overwrite {args.out}"
    result = measure(args)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("x") as handle:
        json.dump(result, handle, indent=2)
        handle.write("\n")
    print(json.dumps({"pass": True, "out": str(args.out),
                      "sourceDelta": result["sourceBaselineToCandidate"]["totals"],
                      "sameBodyAsBaseline": result["libraries"]["sameBodyAsBaseline"],
                      "sameBodyAsPrevious": result["libraries"]["sameBodyAsPrevious"],
                      "inputs": len(V1.INPUTS)}))


if __name__ == "__main__":
    main()

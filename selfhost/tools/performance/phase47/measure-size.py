#!/usr/bin/env python3
"""Read-only Phase47 source/image accounting; never execute compiler artifacts."""
import argparse
import hashlib
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parents[4]
UPSTREAM = "018751270e800bc222a93dad7f257083ee53a5f7"
INPUTS = {}


def identity(path, data):
    path = pathlib.Path(path).resolve(strict=True)
    return {"path": str(path), "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}


def read(path, expected=None):
    path = pathlib.Path(path).resolve(strict=True)
    data = path.read_bytes()
    item = identity(path, data)
    if expected is not None:
        assert item["sha256"] == expected, f"Hash mismatch: {path}"
    assert str(path) not in INPUTS or INPUTS[str(path)] == item, f"Changed input: {path}"
    INPUTS[str(path)] = item
    return data


def record_path(record):
    return pathlib.Path(record.get("canonicalPath", record.get("file", record.get("path")))).resolve(strict=True)


def read_record(record):
    return read(record_path(record), record["sha256"])


def counts(data, bend=True):
    lines = data.decode("utf-8").splitlines()
    result = {"bytes": len(data), "physicalLines": len(lines)}
    if bend:
        result.update(codeLines=sum(bool(s.strip()) and not s.lstrip().startswith("#") for s in lines),
                      definitions=sum(bool(re.match(r"^def\s", s)) for s in lines),
                      laws=sum(bool(re.match(r"^law\s", s)) for s in lines),
                      types=sum(bool(re.match(r"^type\s", s)) for s in lines))
    return result


def snapshot(attempt_path):
    attempt_bytes = read(attempt_path)
    attempt = json.loads(attempt_bytes)
    assert attempt["checked"] and attempt["artifactKind"] == "derived-b1"
    root = pathlib.Path(attempt["snapshot"]["root"]).resolve(strict=True)
    frozen = {record_path(row["frozen"]): row["frozen"]["sha256"] for row in attempt["snapshot"]["sources"]}
    manifest_path = root / "src/compiler.json"
    manifest = json.loads(read(manifest_path, frozen[manifest_path]))
    assert manifest["upstream"] == UPSTREAM
    assert len(manifest["modules"]) == len(set(manifest["modules"]))
    files = []
    for module in manifest["modules"]:
        path = (root / module).resolve(strict=True)
        assert path.is_relative_to(root) and path.suffix == ".bend"
        data = read(path, frozen[path])
        files.append({"module": module, **identity(path, data), **counts(data)})
    totals = {key: sum(row[key] for row in files) for key in counts(b"")}
    totals["modules"] = len(files)
    images = {}
    for key in ("api", "checkedApi", "runtime"):
        data = read_record(attempt[key])
        images[key] = {**identity(record_path(attempt[key]), data), **counts(data, False)}
    core_path = root / "src/runtime/js/core.mjs"
    core = read(core_path, frozen[core_path])
    return {"attempt": identity(attempt_path, attempt_bytes), "manifest": INPUTS[str(manifest_path)],
            "files": files, "totals": totals, "images": images,
            "runtimeCore": {**identity(core_path, core), **counts(core, False)}}, attempt, core


def bundle(path, attempt):
    path = pathlib.Path(path).resolve(strict=True)
    value = json.loads(read(path))
    assert value["complete"] and value["upstreamCommit"] == UPSTREAM
    assert set(value["roles"]) == {"candidate"}
    compiler = value["roles"]["candidate"]["compiler"]
    for key in ("api", "runtime"):
        assert compiler[key]["sha256"] == attempt[key]["sha256"]
        read_record(compiler[key])
    for key in ("base", "driver"):
        read_record(compiler[key])
    assert len(value["cases"]) == len({case["id"] for case in value["cases"]})
    modules = {}
    for case in value["cases"]:
        module = case["modules"]["candidate"]
        module_path = (path.parent / module["path"]).resolve(strict=True)
        assert module_path.is_relative_to(path.parent)
        data = read(module_path, module["sha256"])
        assert len(data) == module["bytes"]
        modules[case["id"]] = (module_path, data)
    return value, modules, compiler


def emission_receipt(module_path, source_sha, compiler, attempt_identity):
    receipt_path = pathlib.Path(str(module_path) + ".json")
    receipt = json.loads(read(receipt_path))
    assert receipt["complete"] and receipt["observation"]["checked"]
    assert receipt["observation"]["typeAccepted"] and receipt["observation"]["status"] == "ok"
    assert receipt["attempt"]["sha256"] == attempt_identity["sha256"]
    read_record(receipt["attempt"])
    assert receipt["compiler"] == compiler
    assert receipt["input"]["sha256"] == source_sha
    read_record(receipt["input"])
    assert record_path(receipt["output"]) == module_path
    read_record(receipt["output"])


def insertion(old, new):
    """Find a single complete-line insertion, retaining exact comment bytes."""
    a, b = old.splitlines(keepends=True), new.splitlines(keepends=True)
    prefix = 0
    while prefix < min(len(a), len(b)) and a[prefix] == b[prefix]:
        prefix += 1
    suffix = 0
    while suffix < len(a) - prefix and a[-1 - suffix] == b[-1 - suffix]:
        suffix += 1
    assert prefix + suffix == len(a), "Runtime change is not insertion-only"
    block = b[prefix:len(b) - suffix if suffix else len(b)]
    added = b"".join(block)
    assert added and new.count(added) == 1 and new.replace(added, b"", 1) == old
    return added


def delta(old, new):
    return {key: new[key] - old[key] for key in old}


def measure(args):
    producer_bytes = read(__file__)
    read(sys.executable)
    old, old_attempt, old_core = snapshot(args.baseline_attempt)
    new, new_attempt, new_core = snapshot(args.candidate_attempt)
    old_bundle, old_modules, old_compiler = bundle(args.baseline_bundle, old_attempt)
    new_bundle, new_modules, new_compiler = bundle(args.candidate_bundle, new_attempt)
    assert old_bundle["catalogSha256"] == new_bundle["catalogSha256"]
    assert len(old_modules) == len(new_modules) == 45 and set(old_modules) == set(new_modules)
    added = insertion(old_core, new_core)
    assert len(added) == 820 and len(added.splitlines()) == 13
    old_runtime = read_record(old_attempt["runtime"])
    new_runtime = read_record(new_attempt["runtime"])
    assert new_runtime.count(added) == 1 and new_runtime.replace(added, b"", 1) == old_runtime
    old_cases = {case["id"]: case for case in old_bundle["cases"]}
    rows, variants, seen = [], [], {}
    for case in new_bundle["cases"]:
        before = old_cases[case["id"]]
        assert before["sourceSha256"] == case["sourceSha256"] and before["point"] == case["point"]
        op, ob = old_modules[case["id"]]
        np, nb = new_modules[case["id"]]
        assert nb.count(added) == 1
        stripped = nb.replace(added, b"", 1)
        row = {"id": case["id"], "sourceSha256": case["sourceSha256"], "module": str(np.name),
               "baseline": identity(op, ob), "candidate": identity(np, nb),
               "deltaBytes": len(nb) - len(ob), "deltaBeyondRuntimeBytes": len(nb) - len(ob) - len(added),
               "afterRemovingExactGuardSha256": hashlib.sha256(stripped).hexdigest(),
               "unchangedAfterRemovingExactAddedGuard": stripped == ob}
        if case["sourceSha256"] in seen:
            representative = seen[case["sourceSha256"]]
            if np != representative:
                variants.append(row)
            continue
        seen[case["sourceSha256"]] = np
        emission_receipt(op, case["sourceSha256"], old_compiler, old["attempt"])
        emission_receipt(np, case["sourceSha256"], new_compiler, new["attempt"])
        rows.append(row)
    assert len(rows) == 23
    unchanged = sum(row["unchangedAfterRemovingExactAddedGuard"] for row in rows)
    changed = {row["module"]: row["deltaBytes"] for row in rows if not row["unchangedAfterRemovingExactAddedGuard"]}
    assert unchanged == 20 and changed == {"local-row.mjs": 18462, "local-fold.mjs": 4428, "editdist.mjs": 18462}
    by_old = {row["module"]: row for row in old["files"]}
    by_new = {row["module"]: row for row in new["files"]}
    source_changes = []
    for module in sorted(set(by_old) | set(by_new)):
        a, b = by_old.get(module), by_new.get(module)
        if a is None or b is None or a["sha256"] != b["sha256"]:
            metrics = counts(b"")
            source_changes.append({"module": module, "delta": delta(
                {key: a[key] if a else 0 for key in metrics}, {key: b[key] if b else 0 for key in metrics})})
    report = {"kind": "phase47-static-size-accounting", "schemaVersion": 1, "complete": True, "pass": True,
              "producer": identity(__file__, producer_bytes), "python": sys.version,
              "command": [sys.executable, *sys.argv], "upstreamCommit": UPSTREAM,
              "scope": {"source": "Manifest-listed Bend modules only; code means nonblank, non-#-comment lines; declarations are syntactic counts.",
                        "runtime": "Runtime core and assembled image shown separately; the same 820-byte insertion is not counted twice as maintained source.",
                        "libraries": "First matching manifest entry per exact source; derived local-row observation adapter listed separately; sizes include runtime prefix.",
                        "execution": "None. No compiler, generated module or target program was executed."},
              "roles": {"worker23": old, "array04": new}, "sourceDelta": delta(old["totals"], new["totals"]),
              "changedSourceModules": source_changes,
              "runtimeInsertion": {"bytes": len(added), "physicalLines": len(added.splitlines()),
                                   "sha256": hashlib.sha256(added).hexdigest(), "text": added.decode("utf-8"),
                                   "assembledRuntimeExactInsertionOnly": True},
              "libraries": {"uniqueSources": len(rows), "guardOnly": unchanged, "changed": len(changed),
                            "baselineTotalBytes": sum(row["baseline"]["bytes"] for row in rows),
                            "candidateTotalBytes": sum(row["candidate"]["bytes"] for row in rows),
                            "rows": rows, "derivedVariants": variants}}
    for path, expected in INPUTS.items():
        assert identity(path, pathlib.Path(path).read_bytes()) == expected, f"Input changed at final rehash: {path}"
    report["inputs"] = list(INPUTS.values())
    report["finalRehash"] = {"pass": True, "files": len(INPUTS)}
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for role in ("baseline", "candidate"):
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
    print(json.dumps({"pass": True, "out": str(args.out), "sourceDelta": result["sourceDelta"],
                      "guardOnlyLibraries": result["libraries"]["guardOnly"], "inputs": len(INPUTS)}))


if __name__ == "__main__":
    main()

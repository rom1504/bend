#!/usr/bin/env python3
"""Data-only frozen compiler-source census; no compiler imports or target runs."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
TOOLS = ROOT / "selfhost/tools/performance"
METHOD = TOOLS / "phase47/measure-size.py"
spec = importlib.util.spec_from_file_location("frozen_counts", METHOD)
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)
old.read(METHOD, "8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681")


def run(args):
    out = args.out.resolve()
    assert out.is_relative_to(TOOLS / "phase61/evidence") and not out.exists()
    old.read(__file__)
    old.read(sys.executable)
    roles = {}
    support = {}
    for role, path in [("installedLast01", args.baseline), ("state08", args.candidate)]:
        row, attempt, _ = old.snapshot(path.resolve() / "attempt.json")
        for file in row["files"]:
            lines = old.read(file["path"], file["sha256"]).decode("utf-8").splitlines()
            file["blankLines"] = sum(not line.strip() for line in lines)
            file["commentOnlyLines"] = sum(line.lstrip().startswith("#") for line in lines)
            assert file["physicalLines"] == file["blankLines"] + file["commentOnlyLines"] + file["codeLines"]
        for key in ["blankLines", "commentOnlyLines"]:
            row["totals"][key] = sum(file[key] for file in row["files"])
        roles[role] = row
        root = Path(attempt["snapshot"]["root"]).resolve()
        support[role] = {}
        for record in attempt["snapshot"]["sources"]:
            frozen = record["frozen"]
            file = old.record_path(frozen)
            name = str(file.relative_to(root))
            if name == "src/runtime.mjs" or name.startswith("src/runtime/") or name in ["tools/typed-driver.mjs", "tools/development/workflow.mjs"]:
                data = old.read(file, frozen["sha256"])
                support[role][name] = dict(old.identity(file, data), **old.counts(data, False))
    left, right = roles.values()
    before = {r["module"]: r for r in left["files"]}
    after = {r["module"]: r for r in right["files"]}
    keys = list(old.counts(b"")) + ["blankLines", "commentOnlyLines"]
    changes, unchanged = [], []
    for name in sorted(before.keys() | after.keys()):
        a, b = before.get(name), after.get(name)
        if a and b and a["sha256"] == b["sha256"]:
            unchanged.append(name)
        else:
            changes.append(dict(module=name, status="added" if a is None else "removed" if b is None else "changed",
                                delta={k: (b[k] if b else 0) - (a[k] if a else 0) for k in keys}))
    a, b = support.values()
    support_rows = [dict(module=n, before=a.get(n), after=b.get(n), byteEqual=bool(n in a and n in b and a[n]["sha256"] == b[n]["sha256"]))
                    for n in sorted(a.keys() | b.keys())]
    native = sorted(n for n in before.keys() | after.keys() if n.startswith("src/back/native/"))
    for path, identity in old.INPUTS.items():
        assert old.identity(path, Path(path).read_bytes()) == identity
    result = dict(kind="phase61-frozen-source-footprint", complete=True, targetExecuted=False,
                  producer=old.identity(__file__, Path(__file__).read_bytes()), method=old.INPUTS[str(METHOD.resolve())],
                  command=[sys.executable, *sys.argv], roles=roles,
                  delta=old.delta(left["totals"], right["totals"]), changedModules=changes,
                  unchangedModules=unchanged, runtimeAndHostFiles=support_rows,
                  nativeModules=len(native), nativeModulesByteEqual=all(n in unchanged for n in native),
                  inputs=list(old.INPUTS.values()), inputsUnchanged=True,
                  scope="Manifest-listed frozen Bend modules only. Unchanged Phase47 code/def/law/type rules; blanks and #-comment-only lines are separately partitioned. Runtime-tree inventory (including its tests/docs) and two host helpers are separate, not added to Bend totals. Other tests/research/tools are excluded. No target execution, live-source equality, simplification or speed claim.")
    result["pass"] = True
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("x") as handle:
        json.dump(result, handle, indent=2)
        handle.write("\n")
    print(json.dumps(dict(out=str(out), totals=right["totals"], delta=result["delta"], unchanged=len(unchanged), changed=len(changes))))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    run(parser.parse_args())

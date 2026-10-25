#!/usr/bin/env python3
"""Compare old/new ELF audit outcomes using retained qualified object metadata.

No assembler, linker, compiler or generated program runs. Reconstruct the old
local-binding view using the authenticated Phase135 promotion receipt, whose
original audit attested exact allocated bytes/relocations and binding-only edits.
Do not label the reconstruction a retained raw object: raw.o was deleted.
"""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[5]
OLD = ROOT / "selfhost/tools/performance/phase135/machine/elf-v01.py"
NEW = Path(__file__).with_name("elf-v02.py")


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def outcome(module, before, after):
    start = time.perf_counter()
    try:
        module.compare(before, after)
        result = {"accepted": True}
    except ValueError as error:
        result = {"accepted": False, "error": str(error)}
    return result, time.perf_counter() - start


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--build", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--indices", nargs="+", type=int, default=[1, 64])
    a = p.parse_args()
    assert not a.out.exists()
    old_text, new_text = OLD.read_text(), NEW.read_text()
    expected = old_text.replace(" expected=[dict(x,binding=1)if x['name']in before['promoted']else x for x in before['symbols']]",
      " promoted=set(before['promoted'])\n expected=[dict(x,binding=1)if x['name']in promoted else x for x in before['symbols']]")
    assert expected != old_text and new_text == expected, "Only the reviewed set-membership substitution is allowed"
    old, new = load("old_elf", OLD), load("new_elf", NEW)
    build = json.loads(a.build.read_text())
    assert build["complete"] and build["kind"] == "phase135-framed-machine-build"
    result = dict(kind="phase140-elf-audit-observation", complete=False, compilerTargetsRun=False,
                  scope="Retained metadata audit; reconstructed prior binding view, no raw object claim or full machine timing",
                  inputs=[pin(__file__), pin(OLD), pin(NEW), pin(a.build)], rows=[])
    for index in a.indices:
        unit = build["units"][index]
        assert unit["index"] == index
        assert pin(unit["receipt"]["file"]) == unit["receipt"]
        receipt = json.loads(Path(unit["receipt"]["file"]).read_text())
        assert receipt["complete"] and receipt["allocatedAndRelocationsExact"]
        assert receipt["key"] == unit["key"] and receipt["object"] == unit["object"]
        assert pin(unit["object"]["file"]) == unit["object"]
        result["inputs"].extend([unit["receipt"], unit["object"]])
        start = time.perf_counter()
        after = old.metadata(Path(unit["object"]["file"]))
        metadata_seconds = time.perf_counter() - start
        assert not after["promoted"]
        before = copy.deepcopy(after)
        promoted = set(receipt["promoted"])
        for symbol in before["symbols"]:
            if symbol["name"] in promoted:
                assert symbol["binding"] == 1
                symbol["binding"] = 0
        before["promoted"] = receipt["promoted"]
        before["symbols"].sort(key=lambda x: repr(sorted(x.items())))
        rank = {name: n + 1 for n, name in enumerate(receipt["promoted"])}
        old_result, old_seconds = outcome(old, before, after)
        new_result, new_seconds = outcome(new, before, after)
        assert old_result == new_result == {"accepted": True}
        cases = []
        for kind in ("allocated", "relocations", "symbol-binding", "promoted-remains"):
            corrupted = copy.deepcopy(after)
            if kind == "allocated":
                assert corrupted["allocated"]
                corrupted["allocated"][0]["sha256"] = "0" * 64
            elif kind == "relocations":
                corrupted["relocations"].append({"unexpected": True})
            elif kind == "symbol-binding":
                assert corrupted["symbols"]
                corrupted["symbols"][0]["binding"] = 99
            else:
                corrupted["promoted"] = ["unexpected"]
            ro, _ = outcome(old, before, corrupted)
            rn, _ = outcome(new, before, corrupted)
            assert ro == rn and not ro["accepted"]
            cases.append({"kind": kind, "result": ro})
        result["rows"].append(dict(index=index, symbols=len(after["symbols"]), promoted=len(promoted),
          listMembershipComparisons=sum(rank.get(s["name"], len(promoted)) for s in before["symbols"]),
          setMembershipProbes=len(before["symbols"]), metadataSeconds=metadata_seconds,
          oldCompareSeconds=old_seconds, newCompareSeconds=new_seconds,
          beforeMetadataSha256=digest(before), afterMetadataSha256=digest(after),
          outcome=old_result, refusalCases=cases))
    for identity in result["inputs"]:
        assert pin(identity["file"]) == identity
    result["complete"] = True
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"complete": True, "rows": result["rows"], "report": pin(a.out)}))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Offline exact QBE comparison; never executes or lowers a Bend program."""
import collections
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[5]
OLD = ROOT / "selfhost/build/phase111/p113-inline15-variation-ray-active-256-2240-emit/program.ssa"
NEW = ROOT / "selfhost/build/phase111/p113-shared16-variation-ray-active-256-2240-emit/program.ssa"
FUNCTION = re.compile(r"^(?:export )?function(?: [a-z]+)? \$([^ (]+).*?^}", re.M | re.S)
SUCCESSOR = re.compile(
    r"%[^ =]+ =l call \$p111_rt_special_take\(l %state, w 4, l (%[^,]+), l (%[^,]+), w 1\)\n"
    r"(%[^ =]+) =l loadl \2"
)


def display(name):
    match = re.search(r"FID_((?:\d+_)+)", name)
    return name[:match.start()] + "".join(
        chr(int(x)) for x in match.group(1).split("_") if x
    ) if match else name


def pin(path):
    raw = path.read_bytes()
    return {"file": str(path.relative_to(ROOT)), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def main():
    before, after = OLD.read_text(), NEW.read_text()
    changed = []

    def rewrite(function):
        if not function[1].startswith("p113d_"):
            return function[0]
        body, count = SUCCESSOR.subn(lambda m: f"{m[3]} =l sub {m[1]}, 1", function[0])
        if count:
            changed.append({"function": display(function[1]), "successorSites": count,
                            "oldBytes": len(function[0].encode()), "newBytes": len(body.encode())})
        return body

    projected = FUNCTION.sub(rewrite, before)
    assert projected == after, "The entire-program exact comparison failed"
    selected = {"p113d_$direct.p93.loop", "p113d_$direct.coverage.active.loop",
                "p113d_$direct.pixel", "p113d_$direct.subray",
                "p113d_$product.trace", "p113d_$product.nearest"}
    route = []
    for function in FUNCTION.finditer(after):
        name = display(function[1])
        if name in selected:
            route.append({"function": name, "calls": dict(collections.Counter(
                display(x) for x in re.findall(r"call \$([^ (]+)", function[0])))})
    print(json.dumps({"kind": "phase113-ray16-exact-static-delta", "complete": True,
                      "targetsRun": False, "inputs": [pin(OLD), pin(NEW)],
                      "method": pin(pathlib.Path(__file__).resolve()),
                      "entireProgramEqualAfterSuccessorReplacement": True,
                      "successorSites": sum(x["successorSites"] for x in changed),
                      "changedFunctions": changed, "selectedCallRoute": route,
                      "scope": "Static source comparison; no new timing or dynamic counts."}, indent=2))


if __name__ == "__main__":
    main()

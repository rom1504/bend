#!/usr/bin/env python3
"""Count exact assembled inputs and frozen module snapshots; no target runs."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
MODULES = ROOT / "selfhost/tools/performance/phase112"
CONTROLS = {"static/controls.bend", "float/controls.bend"}
ALTERNATIVES = {"uses.bend", "workers/entry.bend", "accessors/entry-registers.bend",
                "accessors/entry-tag.bend"}


def count(path, expected=None):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if expected and (digest != expected["sha256"] or len(data) != expected["bytes"]):
        raise ValueError("Input pin mismatch: " + str(path))
    source = data.decode("utf-8")
    kinds = Counter(re.findall(r"^(def|type|law) ", source, re.M))
    return dict(file=str(path.relative_to(ROOT)), sha256=digest, bytes=len(data),
                lines=data.count(b"\n")+int(bool(data) and not data.endswith(b"\n")),
                nonblank=sum(bool(x.strip()) for x in source.split("\n")),
                declarations=sum(kinds.values()), kinds=dict(kinds))


def totals(rows):
    return dict(files=len(rows), **{key: sum(x[key] for x in rows)
                for key in ("bytes", "lines", "nonblank", "declarations")})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=ROOT / "selfhost/build/phase112/word-source02/manifest.json")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError("fresh output required")
    manifest = json.loads(args.manifest.read_text())
    assembled = {key: count(Path(manifest[key]["file"]), manifest[key]) for key in ("baseline", "source")}
    rows, selected = [], set()
    for item in manifest["moduleSnapshots"]:
        original = Path(item["original"]["file"])
        name = str(original.relative_to(MODULES))
        selected.add(original)
        row = count(Path(item["snapshot"]["file"]), item["snapshot"])
        row.update(origin=name, category="embedded controls" if name in CONTROLS else "selected implementation")
        rows.append(row)
    other = []
    for path in sorted(MODULES.rglob("*.bend")):
        if path in selected:
            continue
        name = str(path.relative_to(MODULES))
        row = count(path)
        implementation = name in ALTERNATIVES or name.startswith(("regions/", "region-multi/"))
        row.update(origin=name, category="experimental or superseded implementation" if implementation else "external controls and fixtures")
        other.append(row)
    groups = {key: totals([x for x in rows+other if x["category"] == key])
              for key in sorted({x["category"] for x in rows+other})}
    result = dict(kind="phase112-source-complexity", assembled=assembled,
        delta={key: assembled["source"][key]-assembled["baseline"][key]
               for key in ("bytes", "lines", "nonblank", "declarations")},
        groups=groups, selectedSnapshots=rows, otherPhase112BendFiles=other,
        compositionEdits=dict(Counter(x["action"] for x in manifest["edits"])),
        inputs=[count(args.manifest.resolve()), count(Path(__file__).resolve())],
        method="Physical LF lines, whitespace-nonblank LF lines, UTF-8 bytes, and top-level ^(def|type|law) declarations; no semantic reachability or complexity inference.",
        scope="Assembled full sources and Phase112 Bend modules only. Not repository totals, installed compiler changes, executable reachability, or language conformance.")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({key:result[key] for key in ("assembled", "delta", "groups")}, indent=2))


if __name__ == "__main__":
    main()

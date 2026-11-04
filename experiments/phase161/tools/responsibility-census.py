#!/usr/bin/env python3
"""Offline source inventory: no compilation, subprocesses, or network access."""
import argparse
import collections
import hashlib
import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
OUR_COMMIT = "d3588cfc5d6f0499208357b455b3043f436cd83f"
BENDC_COMMIT = "56edcc65b3527a75838011682c231072d5b46097"
BENDC = "selfhost/build/phase158/current/"
EXPECTED = {
    "bendc.bend": "72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99",
    "check.bend": "786514afc1804c00371356943ac6790c16c04c04551e7ab8e0d8f6468e22bf41",
    "core.bend": "776ec5d81269d74ab3e8da0ad0f748e0f0e48695aae667a5d57ed033c433a1b7",
}
DRIVER_PREFIXES = (
    "Main.chk.", "Main.check", "Main.load", "Main.parse", "Main.resolve",
    "Mod.", "Eff.", "Path.", "CS.", "ChkSel.", "LoadSel.",
)
DRIVER_TYPES = ("CS", "ChkSel", "LoadSel", "Qual")
SUPPORT = (
    BENDC + "rt/bendrt.h", BENDC + "rt/native.c",
    "selfhost/src/runtime/qbe/runtime.c", "selfhost/src/runtime/qbe/runtime.h",
    "selfhost/src/runtime/qbe/primitives.h", "selfhost/src/runtime/native/runtime.c",
)
EXTRACTOR = ROOT / "selfhost/tools/build/source.py"
SPEC = importlib.util.spec_from_file_location("source_inventory", EXTRACTOR)
SOURCE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SOURCE)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def counts(data):
    lines = data.splitlines()
    return {
        "bytes": len(data), "physicalLines": len(lines),
        "nonblankNoncommentLines": sum(
            bool(line.strip()) and not line.lstrip().startswith(b"#")
            for line in lines),
    }


def kinds(rows):
    histogram = collections.Counter(row["kind"] for row in rows)
    return {kind: histogram[kind] for kind in ("def", "law", "type")}


def block_pin(data, row):
    return {
        "kind": row["kind"], "name": row["name"],
        "headerLine": data[:row["headerOffset"]].count(b"\n") + 1,
        "startByte": row["offset"], "endByteExclusive": row["offset"] + len(row["data"]),
        "sha256": sha(row["data"]), **counts(row["data"]),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path,
                        default=ROOT / "experiments/phase161/responsibility-census.json")
    parser.add_argument("--check", action="store_true",
                        help="Recompute and compare with an existing JSON; write nothing")
    args = parser.parse_args()
    files = {}
    cache = {}

    def read(relative):
        if relative not in cache:
            data = (ROOT / relative).read_bytes()
            cache[relative] = data
            files[relative] = {"sha256": sha(data), **counts(data)}
        return cache[relative]

    for name, expected in EXPECTED.items():
        if sha(read(BENDC + name)) != expected:
            raise ValueError("Pinned bendc source changed: " + name)

    groups = []
    our_files = []
    our_rows = []
    for area in ("front", "load", "core", "check", "diagnostic"):
        selected = []
        rows = []
        names = sorted(path.relative_to(ROOT).as_posix()
                       for path in (ROOT / "selfhost/src" / area).rglob("*.bend"))
        for name in names:
            data = read(name)
            prefix, items = SOURCE.blocks(data)
            files[name]["declarations"] = kinds(items)
            files[name]["selection"] = {"wholeFile": True, "startByte": 0,
                                         "endByteExclusive": len(data)}
            selected.append(data)
            rows.extend(items)
        our_files.extend(names)
        our_rows.extend(rows)
        groups.append({"id": "ours-" + area, "files": names,
                       "selection": "whole listed .bend files, sorted path order",
                       **counts(b"".join(selected)), "declarations": kinds(rows)})

    all_ours = b"".join(read(name) for name in our_files)
    ours_total = {"files": len(our_files), **counts(all_ours),
                  "declarations": kinds(our_rows)}
    laws = b"".join(row["data"] for row in our_rows if row["kind"] == "law")
    ours_total["lawBlocks"] = counts(laws)
    ours_total["standaloneUnsafeLines"] = sum(
        line.strip() == b"@unsafe" for line in all_ours.splitlines())

    def selected_group(identifier, filename, selection, predicate=None):
        data = read(filename)
        _, rows = SOURCE.blocks(data)
        if predicate is None:
            chosen = rows
            value = data
        else:
            chosen = [row for row in rows if predicate(row, data)]
            value = b"".join(row["data"] for row in chosen)
        group = {"id": identifier, "files": [filename], "selection": selection,
                 "selectedBytesSha256": sha(value), **counts(value),
                 "declarations": kinds(chosen)}
        if predicate is not None:
            group["blocks"] = [block_pin(data, row) for row in chosen]
        groups.append(group)
        return value

    selected_bendc = [selected_group("bendc-checker", BENDC + "check.bend", {"wholeFile": True})]
    selected_bendc.append(selected_group(
        "bendc-emission-frontend", BENDC + "bendc.bend",
        {"headerLineAtLeast": 88, "headerLineLessThan": 3349,
         "includeAttachedLeadingComments": True},
        lambda row, data: 88 <= data[:row["headerOffset"]].count(b"\n") + 1 < 3349))
    selected_bendc.append(selected_group(
        "bendc-selected-driver", BENDC + "bendc.bend",
        {"namePrefixes": list(DRIVER_PREFIXES), "exactNames": list(DRIVER_TYPES),
         "includeAttachedLeadingComments": True},
        lambda row, data: row["name"].startswith(DRIVER_PREFIXES) or row["name"] in DRIVER_TYPES))
    selected_bendc.append(selected_group(
        "bendc-surface-types", BENDC + "core.bend",
        {"exactNames": ["Pat", "Expr", "Param"], "includeAttachedLeadingComments": True},
        lambda row, data: row["name"] in ("Pat", "Expr", "Param")))

    for name in ("bendc.bend", "core.bend"):
        selected_group("bendc-whole-" + name, BENDC + name, {"wholeFile": True})
    for name in SUPPORT:
        read(name)
    tool = Path(__file__).resolve().relative_to(ROOT).as_posix()
    extractor = EXTRACTOR.relative_to(ROOT).as_posix()
    read(tool)
    read(extractor)
    result = {
        "schema": "phase161-offline-responsibility-census-v1",
        "sourcePins": {"oursAnalyzedCommit": OUR_COMMIT, "bendcCommit": BENDC_COMMIT,
                       "bendcRequiredSourceSha256": EXPECTED},
        "method": {
            "tool": tool, "blockExtractor": extractor,
            "physicalLines": "len(bytes.splitlines())",
            "nonblankNoncommentLines": "nonempty stripped lines not starting # after lstrip",
            "declarations": "source.py HEADER/blocks textual extraction, not Bend parsing",
            "selectionBytes": "whole file or concatenation of selected complete blocks in source order",
            "scopeLimit": "Responsibility envelopes are not equivalent dependency closures or runtime costs.",
            "supportLimit": "Support files are an inventory, not additive comparable runtime totals.",
        },
        "files": files, "groups": groups,
        "oursFrontendEnvelope": ours_total,
        "bendcSelectedFrontendEnvelope": counts(b"".join(selected_bendc)),
        "supportFiles": list(SUPPORT),
    }
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.check:
        if args.output.read_text() != encoded:
            raise ValueError("Census differs from recorded source/tool pins or counts")
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded)
    print(json.dumps({"checked": args.check, "output": str(args.output),
                      "ours": result["oursFrontendEnvelope"],
                      "bendc": result["bendcSelectedFrontendEnvelope"]}, indent=2))


if __name__ == "__main__":
    main()

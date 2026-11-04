#!/usr/bin/env python3
"""Prepare an exact root-main declaration closure; execute no compiler jobs."""
import argparse
import collections
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "selfhost/tools/build"))
import source as assembly
from common import fresh_output, pin, require, verify, write_json

spec = importlib.util.spec_from_file_location(
    "phase147_extract", ROOT / "experiments/phase147/tools/prepare.py")
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)

SOURCE_SHA = "027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8"
CLOSURE_SHA = "15d41d9bf2cec2b11f4dab6dbce8c2cfea5eb59b5ce0b879d5281a5084012bc2"
EXTRACT_SHA = "f218c0b934c105592b33b48938c7de5e0353660bb0efd0033963817f1d3c6cc6"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def key(row):
    return row["kind"], row["name"]


def area(row):
    parts = row["file"].split("/")
    return "/".join(parts[:3] if parts[:2] == ["src", "back"] else parts[:2])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    recipe = ROOT / "selfhost/src/compiler.json"
    qualification = ROOT / "implementation/phase152/qualification.json"
    reference_map = ROOT / "selfhost/build/phase153/source01/compiler.map.json"
    reference_owners = ROOT / "selfhost/build/phase153/prep01/source-owners.json"
    q = json.loads(qualification.read_text())
    require(q["complete"] and q["source"]["sha256"] == SOURCE_SHA,
            "The exact Phase152 qualification is required")
    frozen_source = dict(q["source"], file=str(ROOT / q["source"]["file"]))
    verify(frozen_source)
    require(pin(E.__file__)["sha256"] == EXTRACT_SHA, "Audited extractor changed")
    canonical, canonical_map = assembly.maintained_assemble(
        recipe, ROOT / "selfhost", "qbe", with_map=True)
    require(digest(canonical) == SOURCE_SHA and len(canonical) == q["source"]["bytes"],
            "Maintained QBE source differs from qualified input")
    require(canonical_map == json.loads(reference_map.read_text()),
            "Current source map differs from retained qualified source map")
    body, extracted = E.extract([("qualified-qbe-canonical", canonical)], ["main"])
    require(digest(body) == CLOSURE_SHA, "Closure differs from audited census")

    _, blocks = assembly.blocks(canonical)
    by_key = {key(row): row for row in canonical_map}
    selected = {key(row): row for row in extracted}
    require(len(by_key) == len(blocks) == len(canonical_map),
            "Source rows are not uniquely identified")
    require(len(selected) == len(extracted), "Duplicate selected identity")
    groups = collections.defaultdict(set)
    for row in blocks:
        groups[row["name"]].add(row["kind"])
    split_groups = [name for name, kinds in groups.items()
                    if any((kind, name) in selected for kind in kinds)
                    and not all((kind, name) in selected for kind in kinds)]
    require(not split_groups, "Partial law/definition group selected")

    inventory, source_map, kept, dropped = [], [], [], []
    cursor, kept_index = len(b"import Base\n\n"), 0
    original_area, closure_area = collections.defaultdict(lambda: [0, 0]), collections.defaultdict(lambda: [0, 0])
    for index, row in enumerate(blocks):
        identity = key(row)
        origin = by_key[identity]
        original_area[area(origin)][0] += 1
        original_area[area(origin)][1] += origin["bytes"]
        item = dict(originalOrder=index, kind=row["kind"], name=row["name"],
                    disposition="kept" if identity in selected else "dropped",
                    blockBytes=len(row["data"]), blockSha256=digest(row["data"]),
                    originalBlockStartByte=row["offset"],
                    originalHeaderByte=origin["generatedByte"],
                    originalGeneratedLine=origin["generatedLine"],
                    module=origin["file"], sourceLine=origin["sourceLine"],
                    sourceByte=origin["sourceByte"])
        if identity in selected:
            require(item["blockSha256"] == selected[identity]["sha256"],
                    "Selected declaration content changed")
            require(key(extracted[kept_index]) == identity, "Selected order changed")
            separator = 1 if kept_index else 0
            cursor += separator
            require(body[cursor:cursor + len(row["data"])] == row["data"],
                    "Emitted declaration bytes changed")
            header = cursor + origin["generatedByte"] - row["offset"]
            require(body[header:].startswith((row["kind"] + " " + row["name"]).encode()),
                    "Output header/source map differs")
            location = dict(origin, generatedStartByte=cursor,
                            generatedByte=header,
                            generatedLine=body[:header].count(b"\n") + 1,
                            spanBytes=len(row["data"]),
                            bytes=len(row["data"]) - (header - cursor),
                            separatorBeforeBytes=separator,
                            originalGeneratedByte=origin["generatedByte"],
                            originalGeneratedStartByte=origin["generatedStartByte"])
            source_map.append(location)
            item.update(closureOrder=kept_index, closureBlockStartByte=cursor,
                        closureHeaderByte=header,
                        closureGeneratedLine=location["generatedLine"])
            closure_area[area(origin)][0] += 1
            closure_area[area(origin)][1] += origin["bytes"]
            kept.append(item)
            kept_index += 1
            cursor += len(row["data"])
        else:
            dropped.append(item)
        inventory.append(item)
    require(cursor == len(body) and kept_index == len(extracted),
            "Output inventory does not cover the complete closure")

    owners = json.loads(reference_owners.read_text())
    require(owners["complete"] and owners["source"]["sha256"] == SOURCE_SHA,
            "Owner map is not bound to the qualified source")
    owner_rows = []
    for group in owners["groups"]:
        declarations = [dict(name=d["name"], kind=d["kind"], file=d["file"],
                             retained=key(d) in selected)
                        for d in group["sourceDeclarations"]]
        require(all(d["retained"] for d in declarations),
                "Mapped runtime owner lost: " + group["loweredOwner"])
        owner_rows.append(dict(loweredOwner=group["loweredOwner"],
                               firstFid=group["firstFid"], lastFid=group["lastFid"],
                               mapped=bool(declarations), declarations=declarations))

    recipe_data = json.loads(recipe.read_text())
    input_files = [Path(__file__), Path(E.__file__), Path(assembly.__file__),
                   ROOT / "selfhost/tools/build/common.py", recipe, qualification,
                   Path(frozen_source["file"]), reference_map, reference_owners]
    input_files += [ROOT / "selfhost" / name for name in recipe_data["modules"]]
    input_files.append(ROOT / "selfhost" / recipe_data["preamble"])
    entry = recipe_data["profiles"]["qbe"].get("entryModule")
    if entry:
        input_files.append(ROOT / "selfhost" / entry)
    inputs = [pin(path) for path in dict.fromkeys(input_files)]
    out = fresh_output(args.out, ROOT)
    (out / "compiler.bend").write_bytes(body)
    write_json(out / "compiler.map.json", source_map)
    write_json(out / "declarations.json", inventory)
    write_json(out / "kept.json", kept)
    write_json(out / "dropped.json", dropped)
    write_json(out / "runtime-owners.json", dict(
        kind="phase160-lexical-owner-retention", complete=True,
        mappedOwnersRetained=sum(row["mapped"] for row in owner_rows),
        unmappedOwners=sum(not row["mapped"] for row in owner_rows),
        missingMappedOwners=[], owners=owner_rows,
        scope="Lexical identity retention only, not a reachability or correctness proof."))
    artifacts = {name: pin(out / name) for name in (
        "compiler.bend", "compiler.map.json", "declarations.json", "kept.json",
        "dropped.json", "runtime-owners.json")}
    report = dict(
        kind="phase160-main-closure-preparation", version=1, complete=True,
        targetsRun=False, roots=["main"], originalQualifiedSource=frozen_source,
        source=artifacts["compiler.bend"], artifacts=artifacts, inputs=inputs,
        counts=dict(originalBytes=len(canonical), closureBytes=len(body),
                    originalLines=len(canonical.splitlines()), closureLines=len(body.splitlines()),
                    originalDeclarations=len(blocks), keptDeclarations=len(kept),
                    droppedDeclarations=len(dropped),
                    keptKinds=dict(collections.Counter(row["kind"] for row in kept)),
                    sourceByteReductionFraction=1 - len(body) / len(canonical)),
        invariants=dict(selectedBlocksByteIdentical=True, originalOrderPreserved=True,
                        allSelectedLawDefinitionGroupsWhole=True,
                        mappedRuntimeOwnersLost=0, constructorOrderWithinRetainedTypesPreserved=True),
        areaCounts={name: dict(originalRows=counts[0], originalDeclarationBytes=counts[1],
                               closureRows=closure_area[name][0],
                               closureDeclarationBytes=closure_area[name][1])
                    for name, counts in sorted(original_area.items())},
        qualification="Provisional source extraction; no source check, image acquisition, output equivalence or compiler promotion.",
        nextGate="Independently check/acquire this compiler, then compare its complete output on the ORIGINAL qualified 3,085,157-byte source with the existing oracle.",
        limitations=["Lexical closure is not an independent Bend parser/typechecker.",
                     "Dropped type metadata may change constructor IDs, output tables or compile-time behavior.",
                     "Unmapped Base/composite owners are retained as unknown, not proved reachable.",
                     "This source drops unreferenced exports; only the root-main native compiler product is proposed."])
    write_json(out / "manifest.json", report)
    print(json.dumps(dict(manifest=str(out / "manifest.json"), source=report["source"],
                          counts=report["counts"], targetsRun=False)))


if __name__ == "__main__":
    main()

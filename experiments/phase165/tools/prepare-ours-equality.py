#!/usr/bin/env python3
"""Copy our exact three safe equality defs into the original Bendc checker."""
import argparse
import importlib.util
import json
from pathlib import Path

HELPER = Path(__file__).with_name("prepare-native-lookup.py")
spec = importlib.util.spec_from_file_location("lookup_source", HELPER)
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
NAMES = (b"p88_string_eq_go", b"p98_eq_finish", b"p88_string_eq")
RENAMES = {name: b"p165ours." + name for name in NAMES}


def rename(data, mapping):
    chunks, edits, at, shift = [], [], 0, 0
    for begin, end, old in V.tokens(data):
        if old not in mapping:
            continue
        new = mapping[old]
        chunks.extend((data[at:begin], new))
        edits.append({"originalStart": begin, "originalEnd": end,
                      "candidateStart": begin + shift, "candidateEnd": begin + shift + len(new),
                      "old": old.decode(), "new": new.decode()})
        at, shift = end, shift + len(new) - len(old)
    output = b"".join(chunks + [data[at:]])
    inverse = output
    for edit in reversed(edits):
        a, b = edit["candidateStart"], edit["candidateEnd"]
        V.require(inverse[a:b] == edit["new"].encode(), "inverse span mismatch")
        inverse = inverse[:a] + edit["old"].encode() + inverse[b:]
    V.require(inverse == data, "nonidentifier bytes changed")
    return output, edits


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-tree", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    sources = {name: (args.source_tree / name).read_bytes() for name in V.PINS}
    for name, data in sources.items():
        V.require(V.sha(data) == V.PINS[name], "requires exact original module: " + name)
    ours = V.ROOT / "selfhost/src/core/consuming-strings.bend"
    ours_data = ours.read_bytes()
    definitions = {r["name"]: r for r in V.declarations(ours_data) if r["kind"] == b"def"}
    fragment, records, published = [], [], set()
    for name in NAMES:
        row = definitions[name]
        body = row["body"]
        names = {t[2] for t in V.tokens(body)}
        V.require(b"unsafe" not in names, "selected declaration is not safe")
        V.require((names & set(NAMES)) - {name} <= published, "unfilled private dependency")
        private, edits = rename(body, RENAMES)
        fragment.append(private)
        records.append({"name": name.decode(), "sourceStart": row["start"], "sourceEnd": row["end"],
                        "sourceSha256": V.sha(body), "privateSha256": V.sha(private), "edits": edits})
        published.add(name)
    checker = sources["check.bend"]
    V.require(not any(t[2].startswith(b"p165ours.") for t in V.tokens(checker)), "private name collision")
    rewritten, edits = rename(checker, {b"String.eq": RENAMES[b"p88_string_eq"]})
    V.require(len(edits) == 41, "expected exactly 41 checker String.eq references")
    marker = b"import Base\n"
    V.require(rewritten.startswith(marker), "unexpected checker import boundary")
    fragment = b"\n".join(fragment)
    insertion = b"\n# Phase165 exact safe equality definitions from our compiler.\n" + fragment + b"\n"
    candidate = marker + insertion + rewritten[len(marker):]
    V.require(candidate[:len(marker)] + candidate[len(marker) + len(insertion):] == rewritten, "insertion inverse failed")
    native_block = next(r for r in V.declarations(sources["bendc.bend"]) if r["name"] == b"Natives")
    V.require(b"p165ours." not in native_block["body"], "private name recognized as native")
    out = args.out.resolve()
    V.require(not out.exists() and out.is_relative_to(V.ROOT / "selfhost/build/phase165"), "fresh phase165 output required")
    out.mkdir(parents=True)
    products = []
    for name, data in sources.items():
        path = out / "source" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(candidate if name == "check.bend" else data)
        products.append(V.identity(path))
    (out / "portable.bend").write_bytes(fragment)
    manifest = {"kind": "phase165-exact-ours-equality-transplant", "version": 1, "complete": True,
                "targetsRun": False, "method": V.identity(Path(__file__).resolve()),
                "inputs": [V.identity(HELPER), V.identity(V.HELPER), V.identity(ours)] +
                          [V.identity(args.source_tree / n) for n in sources],
                "policies": {"checkerStringEq": "exact-safe-ours-predicate", "maps": "native", "memo": "native"},
                "definitions": records, "checkerEdits": edits, "insertedBytes": len(insertion),
                "audit": {"allEditsInvertExactly": True, "only41CheckerStringEqReferencesChanged": True,
                          "definitionsUnchangedModuloNames": True, "noNewUnsafe": True,
                          "nativeTableAndOtherModulesUnchanged": True, "CharIsEqFromOriginalBase": True},
                "products": products, "helperFragment": V.identity(out / "portable.bend"),
                "scope": "Source preparation only; ordinary checked acquisition and independent runtime controls required."}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps({"manifest": V.identity(out / "manifest.json"), "checkerBytes": len(candidate)}))


if __name__ == "__main__":
    main()

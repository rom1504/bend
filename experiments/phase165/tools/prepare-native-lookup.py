#!/usr/bin/env python3
"""Prepare checker-only portable Map/String closures. No compiler is invoked."""
import argparse
import collections
import json
from pathlib import Path
import re
import runpy

HELPER = Path(__file__).with_name("prepare-memo.py")
M = runpy.run_path(str(HELPER))
ROOT, SOURCE, PINS = M["ROOT"], M["SOURCE"], M["PINS"]
tokens, require, sha, identity = (M[k] for k in ("tokens", "require", "sha", "identity"))
BASE = M["BASE"] / "base.bend"
PREFIX = b"p165portable."
MAP_NAMES = {b"Map.bit", b"Map.get", b"Map.has"}
STRING_NAMES = {b"String.cmp", b"String.eq"}


def declarations(data):
    """Exact top-level blocks on the separately pinned source syntax."""
    marks = list(re.finditer(rb"(?m)^(def|law|type|import|@unsafe)\b[^\n]*", data))
    result = []
    for i, marker in enumerate(marks):
        if marker[1] not in (b"def", b"law"):
            continue
        name = re.match(rb"(?:def|law)\s+([A-Za-z_$][A-Za-z0-9_.$%]*)", marker[0])
        require(name is not None, "unrecognized declaration")
        start = marker.start()
        if i and marks[i - 1][1] == b"@unsafe":
            start = marks[i - 1].start()
        end = marks[i + 1].start() if i + 1 < len(marks) else len(data)
        result.append({"name": name[1], "kind": marker[1], "start": start, "end": end,
                       "body": data[start:end]})
    return result


def rename(data, names):
    chunks, edits, at, shift = [], [], 0, 0
    for begin, end, old in tokens(data):
        if old not in names:
            continue
        new = PREFIX + old
        chunks.extend((data[at:begin], new))
        edits.append({"originalStart": begin, "originalEnd": end,
                      "candidateStart": begin + shift, "candidateEnd": begin + shift + len(new),
                      "old": old.decode(), "new": new.decode(),
                      "line": data.count(b"\n", 0, begin) + 1})
        at, shift = end, shift + len(new) - len(old)
    chunks.append(data[at:])
    output = b"".join(chunks)
    inverse = output
    for edit in reversed(edits):
        a, b = edit["candidateStart"], edit["candidateEnd"]
        require(inverse[a:b] == edit["new"].encode(), "inverse span mismatch")
        inverse = inverse[:a] + edit["old"].encode() + inverse[b:]
    require(inverse == data, "nonidentifier bytes changed")
    return output, edits


def prepare(checker, base, compiler, maps, strings):
    selected = (MAP_NAMES if maps == "portable" else set()) | (STRING_NAMES if strings == "portable" else set())
    blocks = declarations(base)
    definitions = {x["name"]: x for x in blocks if x["kind"] == b"def"}
    require(len(definitions) == sum(x["kind"] == b"def" for x in blocks), "duplicate Base definitions")
    native_block = next(x for x in declarations(compiler) if x["name"] == b"Natives" and x["kind"] == b"def")
    native = set(re.findall(rb'"([^"\n]+)"', native_block["body"]))
    require(MAP_NAMES | STRING_NAMES <= native, "native operation inventory changed")
    require(selected <= definitions.keys(), "missing selected Base implementation")
    # Type aliases remain the same Base identities, just like constructors and
    # nominal types. This includes Set()->Data, not merely `type` declarations.
    aliases = {name for name, row in definitions.items()
               if re.search(rb"->\s*(?:Data|Type)\s*:", row["body"].split(b"\n\n", 1)[0])}
    native_frontier = native - selected
    frontier = native_frontier | aliases
    dependencies = {name: {t[2] for t in tokens(row["body"])} & definitions.keys()
                    for name, row in definitions.items()}
    impacted = set(selected)
    while True:
        expanded = impacted | {name for name, deps in dependencies.items()
                               if name not in frontier and deps & impacted}
        if expanded == impacted:
            break
        impacted = expanded
    local_names = {x["name"] for x in declarations(checker)}
    refs = collections.Counter(t[2] for t in tokens(checker))
    roots = (refs.keys() & definitions.keys() & impacted) - local_names
    # Selected roots are included even if unreachable (Map.get/has in this
    # checker). Ordinary code reachability may later eliminate unused copies.
    copied, pending = set(), list(roots | selected)
    while pending:
        name = pending.pop()
        if name in copied or name in frontier:
            continue
        copied.add(name)
        pending.extend(dependencies[name] - copied - frontier)
    require(not any(t[2].startswith(PREFIX) for t in tokens(checker)), "private name collision")
    require(not ({b"Chk." + PREFIX + n for n in copied} & native), "private helper recognized as native")
    rewritten, edits = rename(checker, roots)
    closure, records = [], []
    for row in blocks:
        if row["name"] not in copied:
            continue
        changed, helper_edits = rename(row["body"], copied)
        require(not ({t[2] for t in tokens(changed)} & selected), "selected native leaks from helper")
        closure.append(changed)
        records.append({"name": row["name"].decode(), "kind": row["kind"].decode(),
                        "sourceStart": row["start"], "sourceEnd": row["end"],
                        "sourceSha256": sha(row["body"]), "privateSha256": sha(changed),
                        "renameCount": len(helper_edits)})
    fragment = b"\n".join(closure)
    suffix = b"\n# Phase165 private portable helpers from pinned acquisition Base.\n" + fragment if fragment else b""
    candidate = rewritten + suffix
    require(not ({t[2] for t in tokens(rewritten)} & selected), "selected native checker reference remains")
    return candidate, fragment, {
        "policies": {"maps": maps, "strings": strings},
        "selectedNativeOperations": sorted(x.decode() for x in selected),
        "checkerDirectNativeOccurrences": {x.decode(): refs[x] for x in sorted(MAP_NAMES | STRING_NAMES)},
        "redirectedCheckerRoots": {x.decode(): refs[x] for x in sorted(roots)},
        "copiedDefinitions": sorted(x.decode() for x in copied),
        "copiedDeclarationBlocks": records, "checkerEdits": edits,
        "retainedNativeFrontier": sorted(x.decode() for x in native_frontier & set().union(*(dependencies[n] for n in copied))) if copied else [],
        "retainedTypeAliases": sorted(x.decode() for x in aliases & set().union(*(dependencies[n] for n in copied))) if copied else [],
        "audit": {"checkerExactInverseBeforeAppend": True, "helperExactInverseModuloRenames": True,
                  "stringsCommentsLayoutPreserved": True, "typesQuantitiesLawsPreserved": True,
                  "selectedNativeEdgesClosed": True, "nativeTableUnchanged": True},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-tree", type=Path, default=SOURCE)
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--maps", choices=("native", "portable"), default="portable")
    parser.add_argument("--strings", choices=("native", "portable"), default="portable")
    parser.add_argument("--out", type=Path)
    parser.add_argument("--audit-only", action="store_true")
    args = parser.parse_args()
    require(args.audit_only or args.out is not None, "--out required except with --audit-only")
    sources = {name: (args.source_tree / name).read_bytes() for name in PINS}
    reference = (SOURCE / "check.bend").read_bytes()
    require(sha(reference) == PINS["check.bend"], "pinned checker changed")
    memo_candidate = M["transform"](reference)[0]
    require(sources["check.bend"] in (reference, memo_candidate), "checker is neither pinned original nor exact memo treatment")
    memo = "native" if sources["check.bend"] == reference else "portable"
    for name, data in sources.items():
        if name != "check.bend":
            require(sha(data) == PINS[name], "nonchecker source pin mismatch: " + name)
    base = args.base.read_bytes()
    require(sha(base) == M["BASE_SHA"], "requires matching pinned2.0.34 acquisition Base")
    candidate, fragment, detail = prepare(sources["check.bend"], base, sources["bendc.bend"], args.maps, args.strings)
    detail["policies"]["memo"] = memo
    manifest = {"kind": "phase165-checker-portable-native-closure", "version": 1,
                "complete": True, "targetsRun": False, "bendcCommit": "56edcc65b3527a75838011682c231072d5b46097",
                "method": identity(Path(__file__).resolve()),
                "inputs": [identity(HELPER), identity(args.base)] + [identity(args.source_tree / n, b) for n, b in sources.items()],
                "detail": detail, "scope": "Source preparation only; source checking, generated helper inspection and runtime equality/timing are separate gates.",
                "workloadBase": {"bytes": 75064, "sha256": "99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf",
                                 "note": "Common measured-input Base; not the71530-byte acquisition Base."}}
    if args.audit_only:
        print(json.dumps({"policies": detail["policies"], "roots": detail["redirectedCheckerRoots"],
                          "copiedDefinitions": detail["copiedDefinitions"], "nativeFrontier": detail["retainedNativeFrontier"],
                          "checkerBytes": len(candidate), "helperBytes": len(fragment)}, indent=2))
        return
    out = args.out.resolve()
    require(not out.exists(), "output already exists")
    require(out.is_relative_to(ROOT / "selfhost/build/phase165"), "output must be under selfhost/build/phase165")
    out.mkdir(parents=True)
    products = []
    for name, original in sources.items():
        data = candidate if name == "check.bend" else original
        path = out / "source" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        products.append(identity(path))
    (out / "portable.bend").write_bytes(fragment)
    manifest["products"] = products
    manifest["helperFragment"] = identity(out / "portable.bend")
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    for product in products:
        require(identity(Path(product["file"])) == product, "written product mismatch")
    print(json.dumps({"complete": True, "manifest": identity(out / "manifest.json"), "policies": detail["policies"],
                      "checkerBytes": len(candidate), "helperDefinitions": len(detail["copiedDefinitions"])}))


if __name__ == "__main__":
    main()

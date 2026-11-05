#!/usr/bin/env python3
"""Checked-order portable transplant; preserves the refused v1 preparation."""
import argparse
import importlib.util
import json
from pathlib import Path

V1 = Path(__file__).with_name("prepare-native-lookup.py")
spec = importlib.util.spec_from_file_location("p165_lookup_v1", V1)
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
ROOT, SOURCE, PINS = V.ROOT, V.SOURCE, V.PINS
require, identity, sha, tokens = V.require, V.identity, V.sha, V.tokens


def body(declaration):
    lines = declaration.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.rstrip().endswith(b":"):
            return b"".join(lines[i + 1:]).rstrip() + b"\n"
    raise ValueError("declaration header has no terminator")


def substitute(data, mapping):
    pieces, at = [], 0
    for begin, end, name in tokens(data):
        if name in mapping:
            pieces.extend((data[at:begin], mapping[name]))
            at = end
    return b"".join(pieces + [data[at:]])


def legal_order(fragment):
    blocks = V.declarations(fragment)
    definitions = {r["name"]: r for r in blocks if r["kind"] == b"def"}
    # Unfold a worker at its recursive call inside the matching helper. The
    # helper owns the scrutinees as parameters, and its new self-call shrinks
    # those parameters. This avoids matching local intermediate values.
    recipes = [
        (b"String.cmp", b"String.cmp.fin",
         b"      p165portable.String.cmp.rec(h1b, h2b, p165portable.String.cmp(t1, t2))\n",
         b"""      match t1 t2:
        case SNil{} SNil{}:
          p165portable.String.cmp.rec(h1b, h2b, ((SNil{}, SNil{}), EQ{}))
        case SNil{} SCon{p165h, p165t}:
          p165portable.String.cmp.rec(h1b, h2b, ((SNil{}, SCon{p165h, p165t}), LT{}))
        case SCon{p165h, p165t} SNil{}:
          p165portable.String.cmp.rec(h1b, h2b, ((SCon{p165h, p165t}, SNil{}), GT{}))
        case SCon{p165x, p165xt} SCon{p165y, p165yt}:
          p165portable.String.cmp.rec(h1b, h2b,
            p165portable.String.cmp.fin(p165xt, p165yt, p165portable.Char.cmp(p165x, p165y)))
"""),
        (b"Map.diff", b"Map.diff.fin",
         b"      Nat.add(33n, p165portable.Map.diff(xt, yt))\n",
         b"""      match xt yt:
        case SNil{} _:
          Nat.add(33n, 0n)
        case SCon{p165h, p165t} SNil{}:
          Nat.add(33n, 0n)
        case SCon{p165x, p165xt} SCon{p165y, p165yt}:
          Nat.add(33n, p165portable.Map.diff.fin(p165xt, p165yt, p165portable.Map.diff.step(p165x, p165y)))
"""),
        (b"Map.msb.u", b"Map.msb.u.if",
         b"      Nat.add(1n, p165portable.Map.msb.u(p, U32.shr(x2)))\n",
         b"""      +p165next : U32 = U32.shr(x2)
      match p:
        case 0n:
          Nat.add(1n, 0n)
        case 1n+p165q:
          Nat.add(1n, p165portable.Map.msb.u.if(p165q, p165next, U32.is_zero(p165next)))
"""),
    ]
    changes = []
    for worker, helper, needle, replacement in recipes:
        worker, helper = V.PREFIX + worker, V.PREFIX + helper
        if worker not in definitions:
            continue
        require(helper in definitions, "missing cycle helper")
        original = definitions[helper]["body"]
        require(original.count(needle) == 1, "cycle call-site drift: " + helper.decode())
        require(not any(n.startswith(b"p165") and not n.startswith(V.PREFIX)
                        for _, _, n in tokens(original)), "fresh binder collision")
        definitions[helper]["body"] = original.replace(needle, replacement)
        changes.append({"worker": worker.decode(), "helper": helper.decode(),
                        "originalDefinitionSha256": sha(original),
                        "unfoldedWorkerSha256": sha(definitions[worker]["body"]),
                        "newDefinitionSha256": sha(definitions[helper]["body"]),
                        "call": needle.decode(), "replacement": replacement.decode(),
                        "direction": "worker body unfolded inside helper recursive branch",
                        "freshBinderPrefix": "p165"})
    dependencies = {n: {t[2] for t in tokens(r["body"])} & definitions.keys() - {n}
                    for n, r in definitions.items()}
    order, done, active = [], set(), set()

    def visit(name):
        require(name not in active, "unresolved live dependency cycle: " + name.decode())
        if name in done:
            return
        active.add(name)
        for dep in sorted(dependencies[name]):
            visit(dep)
        active.remove(name)
        done.add(name)
        order.append(name)

    for name in definitions:
        visit(name)
    result = []
    for name in order:
        # Preserve the actual law immediately before its filled definition.
        result.extend(r["body"] for r in blocks if r["name"] == name and r["kind"] == b"law")
        result.append(definitions[name]["body"])
    output = b"\n".join(result)
    require(sum(t[2] == b"unsafe" for t in tokens(output)) == sum(t[2] == b"unsafe" for t in tokens(fragment)),
            "unsafe annotation inventory changed")
    return output, {"betaExpansions": changes, "definitionPublicationOrder": [n.decode() for n in order],
                    "allNonselfPrivateDependenciesEarlier": True, "newUnsafeAnnotations": 0,
                    "baseTrustMarkerChanges": 0}


def prepare(checker, base, compiler, maps, strings):
    old_candidate, fragment, detail = V.prepare(checker, base, compiler, maps, strings)
    if not fragment:
        detail["legalPublication"] = {"betaExpansions": [], "definitionPublicationOrder": [],
                                       "allNonselfPrivateDependenciesEarlier": True, "newUnsafeAnnotations": 0,
                                       "baseTrustMarkerChanges": 0}
        return checker, fragment, detail
    ordered, publication = legal_order(fragment)
    roots = {n.encode() for n in detail["redirectedCheckerRoots"]}
    rewritten, edits = V.rename(checker, roots)
    marker = b"import Base\n"
    require(rewritten.startswith(marker), "unexpected checker import boundary")
    insertion = b"\n# Phase165 portable helpers, checked before their callers.\n" + ordered + b"\n"
    candidate = marker + insertion + rewritten[len(marker):]
    require(candidate[:len(marker)] + candidate[len(marker) + len(insertion):] == rewritten,
            "checker insertion inverse failed")
    detail["legalPublication"] = publication
    detail["legalPublication"].update({"insertionByte": len(marker), "insertedBytes": len(insertion),
                                      "checkerExactInverseAfterRemovingInsertion": True})
    detail["v1FailedLayoutSha256"] = sha(old_candidate)
    # V1's helper inverse statement describes the input to beta expansion only.
    detail["audit"]["helperExactInverseModuloRenames"] = False
    detail["audit"]["helperBodyChangesExactlyRecordedWorkerUnfoldings"] = True
    return candidate, ordered, detail


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-tree", type=Path, default=SOURCE)
    parser.add_argument("--base", type=Path, default=V.BASE)
    parser.add_argument("--maps", choices=("native", "portable"), default="portable")
    parser.add_argument("--strings", choices=("native", "portable"), default="portable")
    parser.add_argument("--out", type=Path)
    parser.add_argument("--audit-only", action="store_true")
    args = parser.parse_args()
    require(args.audit_only or args.out is not None, "--out required except with --audit-only")
    sources = {name: (args.source_tree / name).read_bytes() for name in PINS}
    reference = (SOURCE / "check.bend").read_bytes()
    require(sha(reference) == PINS["check.bend"], "pinned checker changed")
    memo_candidate = V.M["transform"](reference)[0]
    require(sources["check.bend"] in (reference, memo_candidate), "unexpected checker treatment")
    for name, data in sources.items():
        if name != "check.bend":
            require(sha(data) == PINS[name], "nonchecker source pin mismatch: " + name)
    base = args.base.read_bytes()
    require(sha(base) == V.M["BASE_SHA"], "acquisition Base pin mismatch")
    candidate, fragment, detail = prepare(sources["check.bend"], base, sources["bendc.bend"], args.maps, args.strings)
    detail["policies"]["memo"] = "native" if sources["check.bend"] == reference else "portable"
    if args.audit_only:
        print(json.dumps({"policies": detail["policies"], "helperDefinitions": len(detail["copiedDefinitions"]),
                          "cyclesInlined": [x["worker"] for x in detail["legalPublication"]["betaExpansions"]],
                          "checkerBytes": len(candidate), "helperBytes": len(fragment)}))
        return
    out = args.out.resolve()
    require(not out.exists(), "output already exists")
    require(out.is_relative_to(ROOT / "selfhost/build/phase165"), "output must be under phase165 build")
    manifest = {"kind": "phase165-checker-portable-native-closure", "version": 3, "complete": True,
                "targetsRun": False, "bendcCommit": "56edcc65b3527a75838011682c231072d5b46097",
                "method": identity(Path(__file__).resolve()),
                "inputs": [identity(V1), identity(V.HELPER), identity(args.base)] +
                          [identity(args.source_tree / n, b) for n, b in sources.items()],
                "detail": detail,
                "scope": "Source preparation only. Forward publication and three Base mutual-helper cycles repaired by helper-local worker unfolding; no local scrutinees, unsafe/no-check/Base-trust changes. Checked acquisition remains required.",
                "workloadBase": {"bytes": 75064, "sha256": "99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf"}}
    out.mkdir(parents=True)
    products = []
    for name, original in sources.items():
        data = candidate if name == "check.bend" else original
        path = out / "source" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        products.append(identity(path))
    (out / "portable.bend").write_bytes(fragment)
    manifest.update(products=products, helperFragment=identity(out / "portable.bend"))
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    for product in products:
        require(identity(Path(product["file"])) == product, "written product mismatch")
    print(json.dumps({"complete": True, "manifest": identity(out / "manifest.json"),
                      "policies": detail["policies"], "checkerBytes": len(candidate)}))


if __name__ == "__main__":
    main()

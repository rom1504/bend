#!/usr/bin/env python3
"""Pin source and generated-C borrowing boundaries. Runs no compiler or program."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
INPUTS = {
    "source": ("selfhost/build/phase98/origin-guard-source01/compiler.bend",
               "2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051"),
    "upstreamBackend": ("selfhost/.bootstrap/upstream-phase66/bend2/comp.ts",
                        "2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c"),
    "upstreamC": ("selfhost/build/phase98/origin-checked01/program.c",
                  "21c0e6b6a71a4bd409f0945bb0c1ff8928e3f4917cd445df06d4c5b07aa4e128"),
    "selfC": ("selfhost/build/phase98/origin-b1-self01/execution/output.1.c",
              "6ae1675a1472afff7a871eb2cf3b42186ca51d0f1b28c03b567863fc4dcdd9d6"),
}
SOURCE_NAMES = [
    "p88_string_eq_go", "p88_string_eq", "p98_eq_finish", "p98_tag_eq_read",
    "p98_tag_eq", "p98_tag_eq_finish", "nol_plain", "nol_owner", "nol_fields",
    "nol_field", "nol_ctor_fields", "nol_type_names", "nol_root_fields",
    "nol_root_pair", "nol_root_ctors", "nol_root_specs", "nol_param_type",
    "noa_reference", "noa_field_values", "noa_match_spec", "noa_finish_value",
    "noa_below", "noa_loop_valid", "noa_recur_done", "noa_literal",
    "no_literal_string_step", "no_atom", "no_emit", "no_emit_let",
    "no_route_names", "no_route_pair", "no_route_plan", "no_adapter_lower",
    "no_scalar_redirect", "nc_keep_uses",
]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return {"file": str(path.relative_to(ROOT)), "bytes": len(data), "sha256": sha(data)}


def span(text, start, end):
    body = text[start:end]
    return {"lineStart": text.count("\n", 0, start) + 1,
            "lineEnd": text.count("\n", 0, end - 1) + 1,
            "bytes": len(body.encode()), "sha256": sha(body.encode()), "text": body}


def bend_definition(text, name, kind="def"):
    found = list(re.finditer(r"^" + kind + " " + re.escape(name) + r"(?:\(| is )", text, re.M))
    assert len(found) == 1, (kind, name, len(found))
    start = found[0].start()
    end = text.find("\n\n", start)
    assert end > start
    return span(text, start, end + 1)


def c_definition(text, name):
    found = list(re.finditer(r"^(?:NF_INLINE|INLINE) Term " + re.escape(name)
                            + r"\([^\n;]*\) \{", text, re.M))
    assert len(found) == 1, (name, len(found))
    start = found[0].start()
    # These selected, fully pinned generated bodies have no comment/string braces.
    pos = text.index("{", start)
    depth = 0
    for end in range(pos, len(text)):
        depth += (text[end] == "{") - (text[end] == "}")
        if depth == 0:
            return span(text, start, end + 2)
    raise AssertionError(("unclosed", name))


def nf(name):
    return "NF_FID_" + "".join(str(ord(c)) + "_" for c in name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / "selfhost/build/phase99"), "Phase99 output only"
    assert not out.exists(), "preserve previous receipts"
    texts, pins = {}, {}
    for role, (relative, expected) in INPUTS.items():
        path = ROOT / relative
        pins[role] = pin(path)
        assert pins[role]["sha256"] == expected, (role, "input changed")
        texts[role] = path.read_text()
    source = {name: bend_definition(texts["source"], name) for name in SOURCE_NAMES}
    term = bend_definition(texts["source"], "KTerm", "type")
    widths = {line.strip().split("{")[0]: line.count("+")
              for line in term["text"].splitlines()[1:] if "{" in line}
    upstream = {name: c_definition(texts["upstreamC"], name)
                for name in ["spin_1", "spin_2", "spin_3", "spin_5", "spin_6", "spin_7"]}
    own = {name: c_definition(texts["selfC"], nf(name)) for name in [
        "p88_string_eq", "p98_tag_eq_read", "p98_tag_eq",
        "$observer.p88_string_eq_go", "$observer.adapter.p88_string_eq_go"]}
    backend = {}
    for name in ["brw_of", "node_fields", "val_own", "emit_args", "emit_put"]:
        match = re.search(r"^function " + name + r"\(", texts["upstreamBackend"], re.M)
        assert match
        end = texts["upstreamBackend"].index("\n}\n", match.start()) + 3
        backend[name] = span(texts["upstreamBackend"], match.start(), end)
    start = texts["upstreamBackend"].index("  const facts = () => FL.own.size")
    end = texts["upstreamBackend"].index("  } while (was !== facts());", start)
    backend["borrowFixedPoint"] = span(texts["upstreamBackend"], start, end + len("  } while (was !== facts());\n"))
    checks = {}

    def check(name, condition):
        assert condition, name
        checks[name] = True

    check("actualWidthsAre8_8_5NoWidthIncreaseNeeded", widths == {"KTerm": 8, "KLambda": 8, "KLiteral": 5})
    check("schemaDemandsExactlyTwoConstructors", "case Con{+a, Con{+b, Nil{}}}" in source["nol_root_ctors"]["text"])
    check("schemaDemandsNullaryArm", "U32.is_eq(da(nil), 0)" in source["nol_root_pair"]["text"])
    check("schemaRestrictsNonScalarFieldToOneSameOwnerChild", all(s in source["nol_root_fields"]["text"] for s in ["U32.is_eq(recursive, 1)", "nol_plain(h)", "nol_scalar(book, h)"]))
    check("onlyOwnerRecursionIsResidualized", "noa_owner(ctx)), u => noa_recur" in source["noa_reference"]["text"])
    check("helperCycleAndDepthRefusalPresent", all(s in source["noa_reference"]["text"] for s in ["nb_contains(stack, name)", "U32.is_lt(nt_count(String, stack), 8)"]))
    check("residualEmitterHasNoCallNode", '"NO_Call"' not in source["no_emit"]["text"])
    check("genericTagArmCallsRecursiveEqualityHelper", "p88_string_eq_go(tag, key, True{})" in source["p98_tag_eq_read"]["text"])
    check("otherTagArmsHaveVirtualStringArguments", all(s in source["p98_tag_eq_read"]["text"] for s in ['p88_string_eq("Lam", key)', 'p88_string_eq("Lit", key)']))
    check("lazyAncestryFixPreserved", 'nt_choose(Bool, p98_tag_eq(origin, "OField"), v => noa_below' in source["noa_below"]["text"])
    check("upstreamTagBorrowsParentButConsumesKey", "term_peek(e.mem, _term_2)" in upstream["spin_2"]["text"] and "ctr_take(" not in upstream["spin_2"]["text"] and "term_sink(e, _key_1)" in upstream["spin_2"]["text"])
    check("upstreamEqualityWrapperHasNoRetain", "term_keep(" not in upstream["spin_5"]["text"] and "spin_3(" in upstream["spin_5"]["text"] and "spin_6(" in upstream["spin_5"]["text"])
    check("ownTagStillConsumesParent", "ctr_take(" in own["p98_tag_eq_read"]["text"] and "term_peek(" not in own["p98_tag_eq_read"]["text"])
    check("ownEqualityWrapperRetainsBothInputs", own["p88_string_eq"]["text"].count("term_keep(") == 2)
    check("ownBorrowedEqualityHasNoOwnershipOperations", all(t not in own["$observer.p88_string_eq_go"]["text"] for t in ["term_keep(", "term_sink(", "ctr_take(", "spare_free(", "heap_alloc("]))
    check("noBorrowedTagOrPublicEqualityWorker", all(nf(n) + "(" not in texts["selfC"] for n in ["$observer.p98_tag_eq_read", "$observer.p88_string_eq"]))
    check("upstreamChildrenInheritRoot", "sc.brwl.set(w, r)" in backend["node_fields"]["text"])
    check("upstreamOwnedEscapeMarksRootOwned", "FL.own.add(r ?? at!)" in backend["val_own"]["text"] and "val_own(sc, val_to(sc, v, dst?.lay ?? sc.seg.ret))" in backend["emit_put"]["text"])
    for role, (relative, _) in INPUTS.items():
        assert pin(ROOT / relative) == pins[role], (role, "input changed during audit")
    result = {"kind": "phase99-borrowed-tags-source-audit", "complete": True,
              "passed": True, "targetsRun": False, "compilerCandidatePrepared": False,
              "method": pin(Path(__file__).resolve()), "inputs": pins,
              "checks": checks, "termWidths": widths, "termType": term,
              "sourceDefinitions": source, "upstreamBackend": backend,
              "upstreamC": upstream, "selfC": own,
              "limits": ["Static exact-source observations, not execution of schema analysis.",
                         "No new runtime safety, conformance or performance claim.",
                         "Borrowed call and opaque aggregate design remain unimplemented."]}
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"passed": True, "checks": len(checks), "report": pin(out)}))


if __name__ == "__main__":
    main()

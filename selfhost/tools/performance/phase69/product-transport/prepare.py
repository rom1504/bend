#!/usr/bin/env python3
"""Derive the P69-004 saved-C experiment; never compile or execute a target."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


LEX = "NF_FID_" + "".join(f"{ord(c)}_" for c in "../phase37/fixtures-historical/lexer:lex")
FLAT = LEX + "p69_product_loop"


def pin(path: Path) -> dict:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def one(text: str, old: str, new: str) -> str:
    assert text.count(old) == 1, ("replacement cardinality", text.count(old), old)
    return text.replace(old, new, 1)


def extent(text: str, name: str) -> tuple[int, int]:
    needle = "NF_INLINE Term " + name + "("
    begins = [i for i in range(len(text)) if text.startswith(needle, i)]
    definitions = [i for i in begins if text[text.index(")", i) + 1:].startswith(" {")]
    assert len(definitions) == 1
    start = definitions[0]
    opening = text.index("{", start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (text[end] == "{") - (text[end] == "}")
        end += 1
    assert text[end] == "\n"
    return start, end + 1


def derive(source: str) -> tuple[str, dict]:
    start, end = extent(source, LEX)
    original = source[start:end]
    signature = f"NF_INLINE Term {LEX}(Env e, bool seq, Term* nf_out, Term v_4294967295, Term v_4294967294)"
    assert original.startswith(signature + " {\n")
    flat_signature = f"NF_INLINE Term {FLAT}(Env e, bool seq, Term* nf_out, Term v_4294967295, Term p69_state0, Term p69_state1, u32 p69_poll)"

    allocation = """Term v_4294967262;
{
u64 nd_36 = heap_alloc(e, cls_fit(2));
e.mem[nd_36 + 0] = rfc_seal(e, v_4294967264);
e.mem[nd_36 + 1] = rfc_seal(e, v_4294967263);
v_4294967262 = term_ctr(CID_TUPLE, nd_36);
goto nf_join_35;
}"""
    virtual = """Term p69_next0, p69_next1;
{
p69_next0 = rfc_seal(e, v_4294967264);
p69_next1 = rfc_seal(e, v_4294967263);
goto nf_join_35;
}"""
    tail = """{
Term nf_arg_0 = v_4294967267;
Term nf_arg_1 = v_4294967262;
v_4294967295 = nf_arg_0;
v_4294967294 = nf_arg_1;
goto nf_again;
}"""
    generic = one(original, allocation, virtual)
    generic = one(generic, tail, f"return {FLAT}(e, seq, nf_out, v_4294967267, p69_next0, p69_next1, nf_poll);")

    flat = one(original, signature, flat_signature)
    flat = one(flat, "u32 nf_poll = 0;", "Term v_4294967294 = 0; /* Box identity is absent only in this proven private entry. */\nu32 nf_poll = p69_poll;")
    for variable in ["v_4294967292", "v_4294967274"]:
        flat = one(flat, f"if ((term_aux({variable}) == CID_TUPLE)) {{", "if (1) { /* Constructor proved at the private entry. */")
        flat = one(flat,
                   f"Term fields[2];\nspare_free(e, cls_fit(2), ctr_take(e, {variable}, 2, fields));",
                   "Term fields[2] = {p69_state0, p69_state1};")
    flat = one(flat, allocation, virtual)
    flat = one(flat, tail, """{
Term nf_arg_0 = v_4294967267;
Term nf_arg_1 = p69_next0;
Term nf_arg_2 = p69_next1;
v_4294967295 = nf_arg_0;
p69_state0 = nf_arg_1;
p69_state1 = nf_arg_2;
goto nf_again;
}""")
    # This is the only reachable branch that disposes of the virtual parent
    # without first matching it. Rebox the sealed fields and execute the exact
    # parent-drop operation, after the original String sink and before ERR_FIDS.
    flat = one(flat,
               "term_sink(e, v_4294967282);\nterm_sink(e, v_4294967281);\nerr_post(e.mem, ERR_FIDS); return 0;",
               """term_sink(e, v_4294967282);
{
u64 p69_cold_box = heap_alloc(e, cls_fit(2));
e.mem[p69_cold_box + 0] = p69_state0;
e.mem[p69_cold_box + 1] = p69_state1;
term_sink(e, term_ctr(CID_TUPLE, p69_cold_box));
}
err_post(e.mem, ERR_FIDS); return 0;""")

    # These facts make accidental editing of a different acquired worker fail.
    assert original.count("heap_alloc(e, cls_fit(2))") == 1
    assert original.count("ctr_take(e,") == 3
    assert generic.count("heap_alloc(e, cls_fit(2))") == 0
    assert flat.count("heap_alloc(e, cls_fit(2))") == 1  # cold raw-error fallback
    assert flat.count("ctr_take(e,") == 1            # input String remains owned
    assert original.count("if (!seq && err_seen(e.mem))") == flat.count("if (!seq && err_seen(e.mem))")
    assert original.count("rfc_seal(e,") == generic.count("rfc_seal(e,") == flat.count("rfc_seal(e,") == 2
    assert original.count("ERR_FIDS") == generic.count("ERR_FIDS") == flat.count("ERR_FIDS") == 4
    replacement = flat_signature + ";\n" + generic + flat
    result = source[:start] + replacement + source[end:]
    assert one(result, replacement, original) == source
    return result, {
        "entry": LEX, "privateLoop": FLAT,
        "oldWorkerSha256": hashlib.sha256(original.encode()).hexdigest(),
        "newWorkerSha256": hashlib.sha256(replacement.encode()).hexdigest(),
        "originalWorker": original, "replacementWorkers": replacement,
        "byteRange": [start, end],
        "sourceOutsideWorkerUnchanged": True,
        "reverseEditRecoversInput": True,
        "changes": [
            "Known self-tail constructor transition transports two sealed fields to a private loop.",
            "Generic initial parameter guards and matching order stay unchanged.",
            "Private loop removes only Tuple guard/take/free and recurrent outer Tuple allocation.",
            "Private invalid-String path recreates the parent before the original parent drop.",
            "Polling counter is transported to preserve checkpoint cadence; no C recursion added.",
        ],
        "scope": "Saved-C diagnostic only. Dynamic ownership, raw-error and performance qualification remain root-owned; no compiler source changed.",
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    before = pin(args.input)
    source = args.input.read_text()
    result, audit = derive(source)
    target = args.out / "program.c"
    target.write_text(result)
    assert pin(args.input) == before
    report = {"kind": "phase69-product-transport-saved-c-v1", "targetExecuted": False,
              "producer": pin(Path(__file__)), "hypothesis": pin(Path("experiments/phase69/P69-004-product-transport.md")),
              "input": before, "output": pin(target), "audit": audit}
    (args.out / "derivation.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"targetExecuted": False, "output": str(target), "derivation": str(args.out / "derivation.json")}))


if __name__ == "__main__":
    main()

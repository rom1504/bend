#!/usr/bin/env python3
"""P69-009 separate String.cmp root-preservation arm, source preparation only."""
from __future__ import annotations
import argparse
import difflib
import hashlib
import json
from pathlib import Path


def pin(path: Path) -> dict:
    data = path.read_bytes()
    return dict(path=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def once(text: str, old: str, new: str) -> str:
    assert text.count(old) == 1, (text.count(old), old[:100])
    return text.replace(old, new, 1)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    source = original = args.input.read_text()
    edits = []

    def edit(before: str, after: str, reason: str) -> None:
        nonlocal source
        source = once(source, before, after)
        edits.append(dict(before=before, after=after, reason=reason))

    helper = """
/* P69-009 separate identity-return arm. Both original roots remain owned. */
INLINE u32 p69_string_compare_borrow(Env e, Term* out, Term root_a, Term root_b) {
  Term a = root_a, b = root_b;
  u32 poll = 0;
  for (;;) {
    if (err_spun(e.mem, &poll)) { return 2; }
    bool nil_a = a == term_pak(CID_SNIL, 0);
    bool nil_b = b == term_pak(CID_SNIL, 0);
    if (!nil_a && (term_tag(a) != TAG_CTR || term_aux(a) != CID_SCON)) { return 0; }
    if (!nil_b && (term_tag(b) != TAG_CTR || term_aux(b) != CID_SCON)) { return 0; }
    if (nil_a || nil_b) {
      out[0] = term_pak(nil_a ? (nil_b ? CID_EQ : CID_LT) : CID_GT, 0);
      return 1;
    }
    Loc la = term_peek(e, a), lb = term_peek(e, b);
    Term ca = e.mem[la], cb = e.mem[lb];
    if (ca > 4294967295ull || cb > 4294967295ull) { return 0; }
    if (ca != cb) {
      out[0] = term_pak(ca < cb ? CID_LT : CID_GT, 0);
      return 1;
    }
    a = e.mem[la + 1];
    b = e.mem[lb + 1];
  }
}
"""
    edit("#undef NF_INLINE\n#endif\n", helper + "#undef NF_INLINE\n#endif\n",
         "Add host-only read cursors with both original roots alive; comparisons keep U32 semantics on admitted fields.")
    fid = "FID_" + "".join(f"{ord(c)}_" for c in "$direct.String.cmp")
    entry = "  WL_CASE(" + fid + ")\n  {\n    Term v_4294914854 = r0;\n    Term v_4294914853 = r1;\n    WL_OPEN\n"
    fast = """#if !DEVICE
    {
      Term p69_result[1];
      u32 p69_status = p69_string_compare_borrow(e, p69_result,
          v_4294914854, v_4294914853);
      if (p69_status == 2) { return 0; }
      if (p69_status == 1) {
        u64 p69_roots = heap_alloc(e, cls_fit(2));
        e.mem[p69_roots] = rfc_seal(e, v_4294914854);
        e.mem[p69_roots + 1] = rfc_seal(e, v_4294914853);
        u64 p69_result_pair = heap_alloc(e, cls_fit(2));
        e.mem[p69_result_pair] = rfc_seal(e, term_ctr(CID_TUPLE, p69_roots));
        e.mem[p69_result_pair + 1] = rfc_seal(e, p69_result[0]);
        r0 = term_ctr(CID_TUPLE, p69_result_pair);
        WL_RETN(1);
      }
    }
#endif
"""
    edit(entry, entry + fast, "Return original owned String roots and scalar ordering at unchanged nested boxed boundary; keep original raw/device fallback.")
    recovered = source
    for change in reversed(edits):
        recovered = once(recovered, change["after"], change["before"])
    assert recovered == original
    output = args.out / "program.c"
    output.write_text(source)
    report = dict(kind="phase69-root-preserving-string-comparison-v1", targetExecuted=False,
                  producer=pin(Path(__file__)), hypothesis=pin(Path("experiments/phase69/P69-009-root-preserving-traversal.md")),
                  input=pin(args.input), output=pin(output), edits=edits,
                  reverseEditsRecoverInput=True,
                  scope="Separate typed-value String.cmp diagnostic. Both owned roots stay alive during read-only traversal. Unsupported fallback unchanged; general raw/foreign/async equivalence and compiler proof unimplemented.")
    (args.out / "derivation.json").write_text(json.dumps(report, indent=2) + "\n")
    (args.out / "program.diff").write_text("".join(difflib.unified_diff(original.splitlines(True), source.splitlines(True), fromfile="before.c", tofile="borrowed-strings.c")))
    assert args.input.read_text() == original
    print(json.dumps(dict(targetExecuted=False, output=str(output), edits=len(edits))))


if __name__ == "__main__":
    main()

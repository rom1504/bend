#!/usr/bin/env python3
"""P69-009 source-only identity-return diagnostic; preserves ordinary fallback."""
from __future__ import annotations
import argparse
import difflib
import hashlib
import json
from pathlib import Path


def fid(name: str) -> str:
    return "FID_" + "".join(f"{ord(c)}_" for c in name)


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

    chr_worker = "NF_" + fid("$product.Map.bit.chr")
    assert source.count(chr_worker + "(") == 2
    helper = f"""
/* P69-009 typed identity-return diagnostic. 0 declines untouched ownership,
   1 returns the original owned root plus bit, 2 observes a runtime error. */
INLINE u32 p69_map_bit_borrow(Env e, bool seq, Term* out,
                            Term root, Term ci, Term off) {{
  if (ci > NAT_IMM || off > NAT_IMM) {{ return 0; }}
  Term cursor = root;
  u32 poll = 0;
  for (;;) {{
    if (err_spun(e.mem, &poll)) {{ return 2; }}
    if (cursor == term_pak(CID_SNIL, 0)) {{
      out[0] = root;
      out[1] = 0;
      return 1;
    }}
    if (term_tag(cursor) != TAG_CTR || term_aux(cursor) != CID_SCON) {{ return 0; }}
    Loc loc = term_peek(e, cursor);
    Term chr = e.mem[loc];
    Term tail = e.mem[loc + 1];
    if (chr > 4294967295ull) {{ return 0; }}
    if (ci == 0) {{
      Term pair[2];
      if (!{chr_worker}(e, seq, pair, chr, off)) {{ return 2; }}
      out[0] = root;
      out[1] = pair[1];
      return 1;
    }}
    ci -= 1;
    cursor = tail;
  }}
}}
"""
    edit("#undef NF_INLINE\n#endif\n", helper + "#undef NF_INLINE\n#endif\n",
         "Add host-only read cursor with live owned root; reuse existing scalar product worker.")
    entry = "  WL_CASE(" + fid("$direct.Map.bit.go") + ")\n  {\n    Term v_4294941797 = r0;\n    Term v_4294941796 = r1;\n    Term v_4294941795 = r2;\n    WL_OPEN\n"
    fast = """#if !DEVICE
    {
      Term p69_result[2];
      u32 p69_status = p69_map_bit_borrow(e, seq, p69_result,
          v_4294941797, v_4294941796, v_4294941795);
      if (p69_status == 2) { return 0; }
      if (p69_status == 1) {
        u64 p69_pair = heap_alloc(e, cls_fit(2));
        e.mem[p69_pair] = rfc_seal(e, p69_result[0]);
        e.mem[p69_pair + 1] = rfc_seal(e, p69_result[1]);
        r0 = term_ctr(CID_TUPLE, p69_pair);
        WL_RETN(1);
      }
    }
#endif
"""
    edit(entry, entry + fast, "Guarded host fast route; original body remains byte-for-byte as fallback and device path.")
    recovered = source
    for change in reversed(edits):
        recovered = once(recovered, change["after"], change["before"])
    assert recovered == original
    output = args.out / "program.c"
    output.write_text(source)
    report = dict(kind="phase69-root-preserving-map-traversal-v1", targetExecuted=False,
                  producer=pin(Path(__file__)), hypothesis=pin(Path("experiments/phase69/P69-009-root-preserving-traversal.md")),
                  input=pin(args.input), output=pin(output), edits=edits,
                  reverseEditsRecoverInput=True,
                  scope="Typed-value diagnostic. Original malformed/unsupported fallback retained without ownership mutation; general raw/foreign/async-error equivalence and production inference are unproved.")
    (args.out / "derivation.json").write_text(json.dumps(report, indent=2) + "\n")
    (args.out / "program.diff").write_text("".join(difflib.unified_diff(original.splitlines(True), source.splitlines(True), fromfile="before.c", tofile="borrowed.c")))
    assert args.input.read_text() == original
    print(json.dumps(dict(targetExecuted=False, output=str(output), edits=len(edits))))


if __name__ == "__main__":
    main()

"""Add a strict zero-count branch to the staged checked repeat-hoist pass."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent

def one(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f"expected one hoist hook: {old}")
    return source.replace(old, new)

def apply(source):
    anchor = "@unsafe\ndef p205_attempt("
    source = one(source, anchor, (HERE / "guard.bend").read_text() + "\n" + anchor)
    source = one(source,
        "p205_pair(nm(rep),kid(rep,0),p205_pair(nm(join),kid(join,0),p205_pair(nm(split),kid(split,0),kid(rep,1))))",
        "p205z_guard(book,rep,join,split)")
    source = one(source, "p205_decls(context,rest,kc(", "p205_decls(p205z_advance(context,change),rest,kc(")
    source = one(source, "p205_recheck(context,dg_event_output(raw,body))",
        "p205_recheck(p205z_advance(context,dg_event_output(raw,body)),dg_event_output(raw,body))")
    if "def p205u_next_decl(" in source:
        source = one(source,
            "p205u_checked(context,dg_event_output(raw,body),check_definition_body(kw_initial(context),dg_event_output(raw,body),0))",
            "p205z_unfold_check(p205z_advance(context,dg_event_output(raw,body)),dg_event_output(raw,body))")
        source = one(source, "@unsafe\ndef p205u_checked(", """@unsafe
def p205z_unfold_check(+context: List<&2,KDef>, +change: KDef) -> KDef:
  p205u_checked(context,change,check_definition_body(kw_initial(context),change,0))

@unsafe
def p205u_checked(""")
        source = one(source, "p205u_decls(context,rest,kc(", "p205u_decls(p205z_advance(context,change),rest,kc(")
        source = one(source, "p205u_list(context,rest,used)}", "p205u_list(p205z_advance(context,change),rest,used)}")
    # The edit index exposes both node children and leaf definitions via dc.
    # Scan only changes to restore the same bound when the caller consumes them.
    source = one(source, "p205_candidate(context,stops,verdict,original,p205_overlay(original,edits))",
        "p205_candidate(p205z_advance(context,edits),stops,verdict,original,p205_overlay(original,edits))")
    return source

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    original = args.source.read_bytes()
    changed = apply(original.decode()).encode()
    args.out.mkdir(parents=True, exist_ok=False)
    (args.out / "compiler.bend").write_bytes(changed)
    pin = lambda b: hashlib.sha256(b).hexdigest()
    (args.out / "preparation.json").write_text(json.dumps({
        "parentSha256": pin(original), "sourceSha256": pin(changed), "parent": str(args.source),
        "bytes": len(changed), "status": "offline preparation"
    }, indent=2) + "\n")

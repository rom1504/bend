#!/usr/bin/env python3
"""Apply AGY-005a (CTFE + Phase205 scalar.bend p205v) onto p205-compiler.bend."""
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CTFE = ROOT / "research/agy/big_wins/ctfe.bend"
SCALAR = ROOT / "research/phase205/native-unfold/scalar.bend"

def once(s: str, old: str, new: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"Expected 1 occurrence of {old[:80]!r}, found {n}")
    return s.replace(old, new, 1)

def main():
    src = Path(sys.argv[1]).read_text()
    out = Path(sys.argv[2])
    enable_scalar = "--no-scalar" not in sys.argv[3:]

    patched = src

    # 1. Optionally enable Phase205 scalar.bend (p205v) inside p205u_pick
    if enable_scalar:
        scalar_text = SCALAR.read_text()
        anchor_pick = "@unsafe\ndef p205u_pick("
        scalar_select = """@unsafe
def p205u_select(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  +first = p205u_attempt(context,dv(raw))
  p205u_scalar_checked(context,raw,first,p205u_check(context,raw,p205v_on(context,first)))
@unsafe
def p205u_scalar_checked(+context: List<&2,KDef>, +raw: KDef, +first: KTerm, +checked: KDef) -> KDef:
  kc(KDef,String.eq(dk(checked),"Absent"),u => p205u_check(context,raw,first),u => checked)
"""
        patched = once(patched, anchor_pick, scalar_text + "\n" + scalar_select + "\n" + anchor_pick)
        old_pick_call = "p205u_record(p205u_check(context,raw,p205u_variant(context,dv(raw))),used)"
        new_pick_call = "p205u_record(p205u_select(context,raw),used)"
        patched = once(patched, old_pick_call, new_pick_call)

    # 2. Insert CTFE pass right before p86_plan_annotated and hook it in
    ctfe_text = CTFE.read_text()
    anchor_plan = "@unsafe\ndef p86_plan_annotated("
    patched = once(patched, anchor_plan, ctfe_text + "\n\n" + anchor_plan)
    old_plan_call = "u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))"
    new_plan_call = "u => agy_ctfe_plan(context,stops,verdict,annotated)"
    patched = once(patched, old_plan_call, new_plan_call)

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(patched)
    print(f"Wrote {out} ({len(patched)} bytes; scalar={enable_scalar})")

if __name__ == "__main__":
    main()

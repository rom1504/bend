#!/usr/bin/env python3
"""Apply Wave 2 Track D: p205v (with U32 interval folding) + W2D String foldl deforestation."""
import sys
from pathlib import Path

root = Path("/home/ai/bend2_agy")
src = Path(sys.argv[1]).read_text()
out = Path(sys.argv[2])
w2d = (root / "research/agy/wave2_lexrec/wave2_lex_deforest.bend").read_text()

# 1. Fix p205u_bind_type Ctr lookup to use j_find_ctor (from Phase 205 scalar.patch.gz)
old_ctr = 'kc(KTerm,p98_tag_eq(t,"Ctr"),y => p205u_after_args(book,dt(lookup(book,nm(t))),terms_len(ks(t))),y =>'
new_ctr = 'kc(KTerm,p98_tag_eq(t,"Ctr"),y => p205u_after_args(book,dt(j_find_ctor(book,nm(t))),terms_len(ks(t))),y =>'
assert src.count(old_ctr) == 1, f"old_ctr count={src.count(old_ctr)}"
src = src.replace(old_ctr, new_ctr, 1)

# 2. Upgrade p205u_pick to try p205v_on with fallback to first (Phase 205 p205u_select)
old_pick = "p205u_record(p205u_check(context,raw,p205u_variant(context,dv(raw))),used)),u =>"
new_pick = "p205u_record(p205u_select(context,raw),used)),u =>"
assert src.count(old_pick) == 1, f"old_pick count={src.count(old_pick)}"
src = src.replace(old_pick, new_pick, 1)

old_var = """@unsafe
def p205u_variant(+book: List<&2,KDef>, +input: KTerm) -> KTerm:
  p205u_attempt(book,input)"""
new_var = """@unsafe
def p205u_variant(+book: List<&2,KDef>, +input: KTerm) -> KTerm:
  p205v_on(book,p205u_attempt(book,input))

@unsafe
def p205u_scalar_checked(+context: List<&2,KDef>, +raw: KDef, +first: KTerm, +checked: KDef) -> KDef:
  kc(KDef,String.eq(dk(checked),"Absent"),u => p205u_check(context,raw,first),u => checked)

@unsafe
def p205u_select(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  +first = p205u_attempt(context,dv(raw))
  p205u_scalar_checked(context,raw,first,p205u_check(context,raw,p205v_on(context,first)))"""
assert src.count(old_var) == 1, f"old_var count={src.count(old_var)}"
src = src.replace(old_var, new_var, 1)

# 3. Hook w2d_plan into p205_ready / p205_candidate
old_ready = """@unsafe
def p205_candidate(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  kc(P86Plan,String.is_empty(jl_checked_error(context,candidate,["main"],stops)),
    u => P86PlanReady{nr_prepare_annotated(context,candidate),verdict},u => P86PlanReady{nr_prepare_annotated(context,original),verdict})

@unsafe
def p205_ready(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +edits: KDef) -> P86Plan:
  kc(P86Plan,String.eq(dk(edits),"Absent"),u => P86PlanReady{nr_prepare_annotated(context,original),verdict},
    u => p205_candidate(p205z_advance(context,edits),stops,verdict,original,p205_overlay(original,edits)))"""

new_ready = """@unsafe
def p205_candidate(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  kc(P86Plan,String.is_empty(jl_checked_error(context,candidate,["main"],stops)),
    u => w2d_plan(context,stops,verdict,candidate),u => w2d_plan(context,stops,verdict,original))

@unsafe
def p205_ready(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +edits: KDef) -> P86Plan:
  kc(P86Plan,String.eq(dk(edits),"Absent"),u => w2d_plan(context,stops,verdict,original),
    u => p205_candidate(p205z_advance(context,edits),stops,verdict,original,p205_overlay(original,edits)))"""
assert src.count(old_ready) == 1, f"old_ready count={src.count(old_ready)}"
src = src.replace(old_ready, new_ready, 1)

# 4. Insert w2d definitions right after agy_bf_plan (so agy_bf_* helpers are in scope!)
# Wait: p205u_variant calls p205v_on, so p205v_on needs a law or to be placed before p205u_variant!
# Better: put a single `law p205v_on` and `law w2d_plan` right before p205u_variant, and put the full
# w2d implementation right before p86_plan_annotated (after agy_bf_*)!
laws = """law p205v_on:
  for +book: List<&2,KDef>
  for +first: KTerm
  KTerm

law w2d_plan:
  for +ctx: List<&2,KDef>
  for +stops: List<&2,String>
  for +verdict: String
  for +defs: List<&2,KDef>
  P86Plan

"""
src = src.replace(new_var, laws + new_var, 1)

anchor = "@unsafe\ndef p86_plan_annotated("
assert src.count(anchor) == 1, f"anchor count={src.count(anchor)}"
src = src.replace(anchor, w2d + "\n\n" + anchor, 1)

out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(src)
print(f"Wrote {out} ({len(src)} bytes)")

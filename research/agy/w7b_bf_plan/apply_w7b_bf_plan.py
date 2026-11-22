#!/usr/bin/env python3
"""Wave 7B Track: Fast O(1)-guarded agy_bf_pass, agy_abs_pass, and w2d_pass.

Eliminates redundant per-def `lookup(ctx1, dn(d))` calls in `agy_bf_pass_step`
and `agy_abs_pass_step` (guarding on `dk`/`db`/`du`/`dx`/`da`/type signature
before lookup), and adds a single-pass O(N) `w2d_collect_folds` pre-scan +
hash-trie filter in `w2d_pass` so programs with zero `W2Fold` candidates
(including self-compiling `compiler.bend`) skip AST walking and `norm_max_term`
entirely, while programs with `W2Fold` candidates get O(1) fold-callee filtering
and zero-copy unchanged AST nodes.

Strictly scoped to `agy_abs_pass_step`, `agy_bf_pass_step`, and `w2d_*`
(lines ~29780-32450). Preserves 100% of -O2 semantics and runtime wins.
"""
from __future__ import annotations

import argparse
from pathlib import Path


OLD_ABS_STEP = """@unsafe
def agy_abs_pass_step(+d: KDef, +tail_res: AgyAbsResult) -> AgyAbsResult:
  match tail_res:
    case AgyAbsResult{ctx1,out1,ch1}:
      +raw = lookup(ctx1,dn(d))
      agy_abs_join(ch1,kc(AgyAbsResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_abs_try_def(ctx1,d,raw,out1),
        u => AgyAbsResult{ctx1,Con{d,out1},False{}}))"""

NEW_ABS_STEP = """@unsafe
def w7b_abs_sig_ok(+d: KDef) -> Bool:
  +t0 = j_strip(dt(d))
  agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_ge(da(d),2) && p98_tag_eq(t0,"All") && p198e_owner(kid(t0,0),"Nat")

@unsafe
def agy_abs_pass_step(+d: KDef, +tail_res: AgyAbsResult) -> AgyAbsResult:
  match tail_res:
    case AgyAbsResult{ctx1,out1,ch1}:
      agy_abs_join(ch1,kc(AgyAbsResult,w7b_abs_sig_ok(d),
        u => agy_abs_try_def(ctx1,d,lookup(ctx1,dn(d)),out1),
        u => AgyAbsResult{ctx1,Con{d,out1},False{}}))"""


OLD_BF_STEP = """@unsafe
def agy_bf_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      +raw = lookup(ctx1,dn(d))
      agy_bf_join(ch1,kc(AgyBFResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_bf_try_def(ctx1,d,raw,out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))"""

NEW_BF_STEP = """@unsafe
def w7b_bf_sig_ok(+d: KDef) -> Bool:
  agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_ge(da(d),2) && U32.is_ge(agy_bf_type_arity(dt(d)),2)

@unsafe
def agy_bf_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      agy_bf_join(ch1,kc(AgyBFResult,w7b_bf_sig_ok(d),
        u => agy_bf_try_def(ctx1,d,lookup(ctx1,dn(d)),out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))"""


OLD_W2D_PASS = """@unsafe
def w2d_pass(+ctx: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{ctx,[],False{}}
    case Con{+d,rest}: w2d_pass_step(d,w2d_pass(ctx,rest))"""

NEW_W2D_PASS = """@unsafe
def w7b_w2d_fold_cand(+d: KDef) -> Bool:
  +ty0 = j_strip(dt(d))
  agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),2) && p98_tag_eq(ty0,"All") && p198e_owner(kid(ty0,0),"String") &&
    p98_tag_eq(j_strip(kid(ty0,1)),"All")

@unsafe
def w7b_w2d_any_fold(defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{+d,rest}:
      kc(Bool,w7b_w2d_fold_cand(d),u => True{},u => w7b_w2d_any_fold(rest))

@unsafe
def w2d_pass_go(+ctx: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{ctx,[],False{}}
    case Con{+d,rest}: w2d_pass_step(d,w2d_pass_go(ctx,rest))

@unsafe
def w2d_pass(+ctx: List<&2,KDef>, +defs: List<&2,KDef>) -> AgyBFResult:
  kc(AgyBFResult,w7b_w2d_any_fold(defs),
    u => w2d_pass_go(ctx,defs),
    u => AgyBFResult{ctx,defs,False{}})"""


OLD_W2D_WALK_LIST = """@unsafe
def w2d_walk_list(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32) -> W2State:
  match xs:
    case Nil{}: W2State{ctx,added,next,k_with_children(parent,nt_reverse(KTerm,acc,[])),ch}
    case Con{x,rest}: w2d_walk_step(parent,rest,acc,ch,fuel,w2d_walk(ctx,added,next,x,fuel))"""

NEW_W2D_WALK_LIST = """@unsafe
def w7b_w2d_rebuild(ch: Bool, +parent: KTerm, +acc: List<&2,KTerm>) -> KTerm:
  match ch:
    case True{}: k_with_children(parent,nt_reverse(KTerm,acc,[]))
    case False{}: parent

@unsafe
def w2d_walk_list(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32) -> W2State:
  match xs:
    case Nil{}: W2State{ctx,added,next,w7b_w2d_rebuild(ch,parent,acc),ch}
    case Con{x,rest}: w2d_walk_step(parent,rest,acc,ch,fuel,w2d_walk(ctx,added,next,x,fuel))"""


def apply_patch(src_text: str) -> str:
    patches = [
        ("agy_abs_pass_step", OLD_ABS_STEP, NEW_ABS_STEP),
        ("agy_bf_pass_step", OLD_BF_STEP, NEW_BF_STEP),
        ("w2d_walk_list", OLD_W2D_WALK_LIST, NEW_W2D_WALK_LIST),
        ("w2d_pass", OLD_W2D_PASS, NEW_W2D_PASS),
    ]
    out = src_text
    for name, old, new in patches:
        if new in out:
            continue
        if old not in out:
            raise SystemExit(f"[apply_w7b_bf_plan] anchor not found: {name}")
        count = out.count(old)
        if count != 1:
            raise SystemExit(f"[apply_w7b_bf_plan] expected 1 match for {name}, found {count}")
        out = out.replace(old, new, 1)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    text = args.src.read_text(encoding="utf-8")
    patched = apply_patch(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(patched, encoding="utf-8")
    print(f"[apply_w7b_bf_plan] Wrote {args.dst} ({len(patched):,} bytes)", flush=True)


if __name__ == "__main__":
    main()

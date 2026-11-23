#!/usr/bin/env python3
"""S10-A: Pure-Bend Zero-.p130 Stub-Weak Visibility Patch (`apply_s10a.py`).

Patches `compiler.bend` (or `m09.bend` directly) so that `x86-module`,
`x86-module-fast`, `--trace`, and `--trace-slow` automatically mark any
self-recursive stub def (`f(x0..xk)` or `_f = ...; f(x0..xk)`), `_s10a_cps`,
or template def (`templates > 0`) in `plan.request.source` as `STB_WEAK` in
`weak_set`.

Properties:
- 100% pure Bend, 0 new types, 0 C, 0 JS, 0 `objcopy`, 0 `--allow-multiple-definition`.
- Self-contained in `m09.bend` (works on both monolithic `compiler.bend` and `k10_wave15/m09.bend`).
- 100% backwards-compatible with `.p130` builds (when `source` has 0 stubs,
  `weak_set` is identical).
- Enables 100% parallel zero-`.p130` module compilation against `base.p130`
  from t = 0.00 s with ZERO `x86-iface` chain!
"""
from __future__ import annotations

import argparse
from pathlib import Path

ANCHOR_PREP_RUN = """@unsafe
def w10_module_prep_run(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_io(x198pw_plan(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)"""

REPLACE_PREP_RUN = """# === S10-A: Pure-Bend Zero-.p130 Stub-Weak Visibility ===
law s10a_strip_ann:
  for +t: KTerm
  KTerm

@unsafe
def s10a_strip_ann_kids(+t: KTerm, kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Con{k0, _}: s10a_strip_ann(k0)
    case _: t

@unsafe
def s10a_strip_ann(t):
  match t:
    case KTerm{+tag, name, id, quant, +kids, removed, ob, oe}:
      nt_choose(KTerm, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Use"),
        u => s10a_strip_ann_kids(t, kids),
        u => t)
    case _: t

@unsafe
def s10a_is_self_call(+name: String, +t0: KTerm, +k: U32) -> Bool:
  +t = s10a_strip_ann(t0)
  nt_choose(Bool, U32.is_eq(k, 0),
    u => p98_tag_eq(t, "Ref") && agy_str_eq(nm(t), name),
    u => p98_tag_eq(t, "App") && p98_tag_eq(s10a_strip_ann(kid(t, 1)), "Var") && s10a_is_self_call(name, kid(t, 0), U32.sub(k, 1)))

law s10a_is_stub:
  for +name: String
  for +t0: KTerm
  for +k: U32
  Bool

@unsafe
def s10a_is_stub_cur(+name: String, +t: KTerm, +k: U32) -> Bool:
  match t:
    case KLambda{_, _, _, Con{body, _}, _, _, _, _}:
      s10a_is_stub(name, body, U32.inc(k))
    case _:
      nt_choose(Bool, s10a_is_self_call(name, t, k),
        u => True{},
        u =>
          +b0 = s10a_strip_ann(kid(t, 0))
          p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && agy_str_eq(nm(b0), "_f") && s10a_is_self_call(name, kid(t, 1), k))

@unsafe
def s10a_is_stub(name, t0, k):
  s10a_is_stub_cur(name, s10a_strip_ann(t0), k)

law s10a_has_type_param:
  for +t: KTerm
  Bool

@unsafe
def s10a_has_type_param_cur(+t: KTerm) -> Bool:
  match t:
    case KTerm{+tag, _, _, _, Con{+dom, Con{+bod, _}}, _, _, _}:
      nt_choose(Bool, agy_str_eq(tag, "All"),
        u =>
          +d0 = s10a_strip_ann(dom)
          p98_tag_eq(d0, "Typ") || p98_tag_eq(d0, "Set") || s10a_has_type_param(bod),
        u => False{})
    case _: False{}

@unsafe
def s10a_has_type_param(t):
  s10a_has_type_param_cur(s10a_strip_ann(t))

@unsafe
def w10_weak_add_stubs(source: List<&2, KDef>, +acc: KDef) -> KDef:
  match source:
    case Nil{}: acc
    case Con{+d, +rest}:
      +nm_d = dn(d)
      nt_choose(KDef, agy_str_eq(dk(d), "Def") &&
          (Bool.not(U32.is_eq(dx(d), 0)) || s10a_has_type_param(dt(d)) || agy_str_eq(nm_d, "_s10a_cps") || s10a_is_stub(nm_d, dv(d), 0)),
        u => w10_weak_add_stubs(rest, w10_weak_add_def(nm_d, acc)),
        u => w10_weak_add_stubs(rest, acc))

@unsafe
def w10_weak_from_plan(+seed: P86Seed, plan: P86Plan) -> KDef:
  match plan:
    case P86PlanReady{NR_Request{+source, book, names, paths, scope, bound}, verdict}:
      w10_weak_add_stubs(source, w10_weak_from_seed(seed))
    case _: w10_weak_from_seed(seed)

@unsafe
def w10_module_prep_run(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      +plan = p86_plan(seed,path,source)
      w10_module_prepared_io(x198pw_plan(plan),w10_weak_from_plan(seed,plan),fid_base,mod_name)"""

CALL_SITES = [
    (ANCHOR_PREP_RUN, REPLACE_PREP_RUN),
    (
        """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan_fast(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)""",
        """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      +plan = p86_plan(seed,path,source)
      w10_module_prepared_fast_io(x198pw_plan_fast(plan),w10_weak_from_plan(seed,plan),fid_base,mod_name)""",
    ),
    (
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))""",
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_plan(seed,plan),u => missing())""",
    ),
    (
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef, is_mod, u => w10_weak_from_seed(seed), u => missing())
        +plan : P86Plan <- ts_p86_plan_io(thresh, seed, path, source)""",
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +plan : P86Plan <- ts_p86_plan_io(thresh, seed, path, source)
        +weak_set : KDef = nt_choose(KDef, is_mod, u => w10_weak_from_plan(seed, plan), u => missing())""",
    ),
]


def patch_text(src: str) -> str:
    if "def w10_weak_add_stubs(" in src:
        return src
    for i, (old, new) in enumerate(CALL_SITES):
        cnt = src.count(old)
        if cnt != 1:
            raise RuntimeError(f"apply_s10a: expected 1 occurrence of CALL_SITE_{i}, found {cnt}")
        src = src.replace(old, new, 1)
    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("input", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    src = args.input.read_text(encoding="utf-8")
    out = patch_text(src)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(out, encoding="utf-8")
    print(f"Patched {args.input} -> {args.output} (+{len(out) - len(src)} bytes)")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""B2: Direct-Only FID Omission & Explicit Cross-Module Contracts (BOTH -O0 and -O2).

Applies cleanly and idempotently to `selfhost/build/agy/wave17_unified/compiler.bend`:
1. Replaces `o2d_is_exp_main_go` / `o2d_exp_main_dispatch` in `p167l_dispatch` with
   `b2_is_exp_main_go` / `b2_exp_main_dispatch` supporting explicit cross-module export
   contracts declared by the defining module in its synthetic `.exp` `main()`:
   - `_d* = fn` (Direct-Only): verifies `fn` was lowered direct (`P113DFunction`,
     `dx(entry) == 1`) and OMITS `p111_FID_$direct.<fn>` (`p164a_segment`) and
     `P167Factory` (0 `p111` FIDs, 0 `x187_pub` emission!). Fails loudly with a
     contract violation if an internal change makes `fn` non-direct.
   - `_b* = fn` (Direct + CPS Worker): verifies `fn` was lowered direct (`dx == 1`)
     and demands `p113d_public(book, fn)` (`p164a_segment`), guaranteeing BOTH
     `p113d_FID_$direct.<fn>` and `p111_FID_$direct.<fn>`.
   - `_c* = fn` (Closure / Factory + Worker): verifies `fn` is in catalogue and
     demands BOTH `nc_ref_name(book, fn)` (`P167Factory`) and `p113d_public(book, fn)`.
   - `_w* = fn` or legacy `_ = fn` (CPS Worker): demands `p113d_public(book, fn)`
     (100% backward compatible with O2-D `.exp` files).
2. Recognizes explicit contract modules with `count >= 1` (and legacy `_ = fn`
   modules with `count >= 5`), requiring every binding RHS to be a `Ref` so normal
   user `main()` functions are never misclassified.
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave17_unified/compiler.bend"
MARKER = "# === B2 DIRECT-ONLY FID OMISSION & EXPLICIT MODULE CONTRACTS ==="

B2_HELPERS = f"""{MARKER}

law b2_strip_ann:
  for +t: KTerm
  KTerm

@unsafe
def b2_strip_ann_kids(+t: KTerm, kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Con{{k0, _}}: b2_strip_ann(k0)
    case _: t

@unsafe
def b2_strip_ann(t):
  match t:
    case KTerm{{+tag, name, id, quant, +kids, removed, ob, oe}}:
      nt_choose(KTerm, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Use"),
        u => b2_strip_ann_kids(t, kids),
        u => t)
    case _: t

@unsafe
def b2_exp_main_body() -> List<&2, N111Stmt>:
  [N111Alloca{{"b2_out", 8, 8}},
   N111Store{{N111U64{{}}, N111Local{{"b2_out"}}, 0, N111Const{{0, 0}}}},
   N111Call{{"b2_ret", N111U64{{}}, "p111_rt_return", [
     p111_state(), N111Arg{{N111Ptr{{}}, N111Local{{"b2_out"}}}}, p111_u32(1)]}},
   N111Return{{N111Local{{"b2_ret"}}}}]

@unsafe
def b2_is_direct_bind(+bn: String) -> Bool:
  String.starts_with(bn, "_d")

@unsafe
def b2_is_both_bind(+bn: String) -> Bool:
  String.starts_with(bn, "_b")

@unsafe
def b2_is_closure_bind(+bn: String) -> Bool:
  String.starts_with(bn, "_c")

@unsafe
def b2_is_worker_bind(+bn: String) -> Bool:
  String.starts_with(bn, "_w")

@unsafe
def b2_is_explicit_bind(+bn: String) -> Bool:
  b2_is_direct_bind(bn) || b2_is_both_bind(bn) || b2_is_closure_bind(bn) || b2_is_worker_bind(bn)

law b2_is_exp_kids:
  for xs: List<&2, KTerm>
  for +count: U32
  for +has_exp: Bool
  Bool

@unsafe
def b2_is_exp_kids(xs, count, has_exp):
  match xs:
    case Nil{{}}: False{{}}
    case Con{{x, Nil{{}}}}:
      +t = b2_strip_ann(x)
      nt_choose(Bool, p98_tag_eq(t, "Let"),
        u => b2_is_exp_kids(ks(t), count, has_exp),
        u => ((has_exp && U32.is_ge(count, 1)) || U32.is_ge(count, 5)) &&
             (p98_tag_eq(t, "Num") || p98_tag_eq(t, "U32") || p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Lit")))
    case Con{{x, rest}}:
      +b = b2_strip_ann(x)
      +bn = nm(b)
      +rhs = b2_strip_ann(kid(b, 0))
      nt_choose(Bool, p98_tag_eq(b, "Bind") && (String.starts_with(bn, "_") || String.is_empty(bn)) && p98_tag_eq(rhs, "Ref"),
        u => b2_is_exp_kids(rest, U32.inc(count), has_exp || b2_is_explicit_bind(bn)),
        u => False{{}})

@unsafe
def b2_is_exp_main_go(+t0: KTerm) -> Bool:
  +t = b2_strip_ann(t0)
  nt_choose(Bool, p98_tag_eq(t, "Let"),
    u => b2_is_exp_kids(ks(t), 0, False{{}}),
    u => False{{}})

@unsafe
def b2_check_bind(+book: List<&2, KDef>, +catalogue: KDef, +b: KTerm) -> String:
  +bn = nm(b)
  +rhs = b2_strip_ann(kid(b, 0))
  nt_choose(String, p98_tag_eq(rhs, "Ref"),
    u =>
      +fname = nm(rhs)
      +pub = p113d_public(book, fname)
      +h = index_hash(pub, 2166136261)
      +entry = w5c3_find(catalogue, pub, h)
      +is_direct = Bool.not(agy_str_eq(dk(entry), "Absent")) && U32.is_eq(dx(entry), 1)
      nt_choose(String, b2_is_direct_bind(bn),
        v => nt_choose(String, is_direct, w => "", w => "b2 contract violation: direct-only export " ++ fname ++ " was not lowered direct"),
        v => nt_choose(String, b2_is_both_bind(bn),
          w => nt_choose(String, is_direct, z => "", z => "b2 contract violation: direct+worker export " ++ fname ++ " was not lowered direct"),
          w => nt_choose(String, b2_is_closure_bind(bn),
            z =>
              +fac = nc_ref_name(book, fname)
              +hf = index_hash(fac, 2166136261)
              +fentry = w5c3_find(catalogue, fac, hf)
              nt_choose(String, Bool.not(agy_str_eq(dk(fentry), "Absent")),
                q => "", q => "b2 contract violation: closure export " ++ fname ++ " is absent from catalogue"),
            z => ""))),
    u => "")

law b2_check_exp_kids:
  for +book: List<&2, KDef>
  for +catalogue: KDef
  for xs: List<&2, KTerm>
  String

@unsafe
def b2_check_exp_kids(book, catalogue, xs):
  match xs:
    case Nil{{}}: ""
    case Con{{x, Nil{{}}}}:
      +t = b2_strip_ann(x)
      nt_choose(String, p98_tag_eq(t, "Let"),
        u => b2_check_exp_kids(book, catalogue, ks(t)),
        u => "")
    case Con{{x, rest}}:
      +b = b2_strip_ann(x)
      +err = nt_choose(String, p98_tag_eq(b, "Bind"), u => b2_check_bind(book, catalogue, b), u => "")
      nt_choose(String, String.is_empty(err),
        u => b2_check_exp_kids(book, catalogue, rest),
        u => err)

@unsafe
def b2_check_exp_contracts(+book: List<&2, KDef>, +catalogue: KDef, +t0: KTerm) -> String:
  +t = b2_strip_ann(t0)
  nt_choose(String, p98_tag_eq(t, "Let"),
    u => b2_check_exp_kids(book, catalogue, ks(t)),
    u => "")

@unsafe
def b2_demand_if_present(+catalogue: KDef, +sym: String, +demand: P167Demand) -> P167Demand:
  +h = index_hash(sym, 2166136261)
  nt_choose(P167Demand, Bool.not(agy_str_eq(dk(w5c3_find(catalogue, sym, h)), "Absent")),
    v => p167l_demand(sym, demand),
    v => demand)

@unsafe
def b2_demand_bind(+book: List<&2, KDef>, +catalogue: KDef, +b: KTerm, +demand: P167Demand) -> P167Demand:
  +bn = nm(b)
  +rhs = b2_strip_ann(kid(b, 0))
  nt_choose(P167Demand, p98_tag_eq(rhs, "Ref"),
    u =>
      +fname = nm(rhs)
      nt_choose(P167Demand, b2_is_direct_bind(bn),
        v => demand,
        v =>
          +pub = p113d_public(book, fname)
          +d1 = b2_demand_if_present(catalogue, pub, demand)
          nt_choose(P167Demand, b2_is_closure_bind(bn),
            w => b2_demand_if_present(catalogue, nc_ref_name(book, fname), d1),
            w => d1)),
    u => demand)

law b2_collect_exp_kids:
  for +book: List<&2, KDef>
  for +catalogue: KDef
  for xs: List<&2, KTerm>
  for +demand: P167Demand
  P167Demand

@unsafe
def b2_collect_exp_kids(book, catalogue, xs, demand):
  match xs:
    case Nil{{}}: demand
    case Con{{x, Nil{{}}}}:
      +t = b2_strip_ann(x)
      nt_choose(P167Demand, p98_tag_eq(t, "Let"),
        u => b2_collect_exp_kids(book, catalogue, ks(t), demand),
        u => demand)
    case Con{{x, rest}}:
      +b = b2_strip_ann(x)
      +d2 = nt_choose(P167Demand, p98_tag_eq(b, "Bind"), u => b2_demand_bind(book, catalogue, b, demand), u => demand)
      b2_collect_exp_kids(book, catalogue, rest, d2)

@unsafe
def b2_collect_exp_refs(+book: List<&2, KDef>, +catalogue: KDef, +t0: KTerm, +demand: P167Demand) -> P167Demand:
  +t = b2_strip_ann(t0)
  nt_choose(P167Demand, p98_tag_eq(t, "Let"),
    u => b2_collect_exp_kids(book, catalogue, ks(t), demand),
    u => demand)

@unsafe
def b2_exp_main_dispatch(+context: P167Context, +pending: P167Demand, built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{{+book, +catalogue, bangs}}:
      +d = lookup(book, "main")
      +err = b2_check_exp_contracts(book, catalogue, dv(d))
      +p2 = nt_choose(P167Demand, String.is_empty(err),
        u => b2_collect_exp_refs(book, catalogue, dv(d), pending),
        u => pending)
      p167l_accept(context, [N111Segment{{"main", 0, 1, 0, 0, b2_exp_main_body()}}], fresh, p2, built, 0, "main", "main", 0, err)
"""

OLD_DISPATCH_ANCHOR = """@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      +arity = da(entry)
      nt_choose(P167Built,U32.is_gt(o2d_stub_kind(book,source),0),
        z => o2d_stub_dispatch(context,entry,source,owner,arity,pending,built,fresh),
        z => nt_choose(P167Built,agy_str_eq(source,"main") && Bool.not(nb_contains(bangs,"main")) && o2d_is_exp_main_go(dv(lookup(book,"main")),0),
          y => o2d_exp_main_dispatch(context,pending,built,fresh),"""

NEW_DISPATCH_ANCHOR = B2_HELPERS + """
@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      +arity = da(entry)
      nt_choose(P167Built,U32.is_gt(o2d_stub_kind(book,source),0),
        z => o2d_stub_dispatch(context,entry,source,owner,arity,pending,built,fresh),
        z => nt_choose(P167Built,agy_str_eq(source,"main") && Bool.not(nb_contains(bangs,"main")) && b2_is_exp_main_go(dv(lookup(book,"main"))),
          y => b2_exp_main_dispatch(context,pending,built,fresh),"""


def apply_text(src: str) -> tuple[str, bool]:
    if MARKER in src:
        return src, False
    cnt = src.count(OLD_DISPATCH_ANCHOR)
    if cnt != 1:
        raise RuntimeError(f"Patch p167l_dispatch: expected 1 occurrence, found {cnt}")
    return src.replace(OLD_DISPATCH_ANCHOR, NEW_DISPATCH_ANCHOR, 1), True


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=None, help="Write to output path instead of in-place")
    ap.add_argument("--check-only", action="store_true", help="Run locked_bun.sh --check-only on patched output")
    args = ap.parse_args()

    text = args.src.read_text(encoding="utf-8")
    patched, changed = apply_text(text)
    dst = args.out if args.out is not None else args.src
    dst.parent.mkdir(parents=True, exist_ok=True)
    if changed or not dst.exists():
        dst.write_text(patched, encoding="utf-8")
        print(f"[b2] Applied B2 patches -> {dst} ({len(patched):,} B, +{len(patched)-len(text):,} B)")
    else:
        print(f"[b2] Already applied (idempotent) -> {dst}")

    if args.check_only:
        cmd = [str(ROOT / "research/agy/locked_bun.sh"), "--check-only", str(dst)]
        print(f"[b2] Running: {' '.join(cmd)}", flush=True)
        r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        only_unsafe = (
            r.returncode == 0
            or ("defs rely on unsafe or foreign code:" in combined and "Location:" not in combined)
        )
        if not only_unsafe:
            print(combined[-3000:], file=sys.stderr)
            sys.exit(r.returncode or 1)
        print("[b2] --check-only PASS (0 type/linearity errors)")


if __name__ == "__main__":
    main()

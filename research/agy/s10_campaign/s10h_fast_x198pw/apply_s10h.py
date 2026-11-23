#!/usr/bin/env python3
"""S10-H: Fast -O0 `x198pw_plan_fast` Patch (Stacks cleanly after S10-A + S10-C).

Targets ONLY `-O0` (`x86-object-fast` / `x86-module-fast` via `x198pw_plan_fast`).
`-O2` (`x86-object` / `x86-module` / `x86` / `x86-shard` / `x86-iface`) is 100% untouched.
100% self-contained in `m09.bend` and idempotent on both `wave15_unified/compiler.bend`
and `k10_wave15/m09.bend`.

Four pure-Bend `-O0` lowering accelerations inside `x198pw_plan_fast`:
  1. Unified Stub Recognition (`s10h_stub_kind`): extends S10-C's `.p130`-only stub
     skip (`w10_if_stub_kind`) to ALSO recognize S10-A zero-`.p130` self-recursive
     direct (`1000 + arity`) and CPS (`2`) stubs, eliminating redundant lowering of
     559–1,303 imported stubs per module in `p128br_scan`, `w14a_prune_active`,
     `w13d_p113pl_candidates_fast`, `p113d_passes`, and `x187_priv`.
  2. Skip `-O2` Mutual-Tail-Call SCC Fusion (`p126sc_candidates`) in `-O0`:
     passes `raw` directly to `p113d_passes` (zero cross-module ABI change).
  3. O(1) Hash-Trie `bangMap` in `s10h_p167ob_remaining`: eliminates O(N * |bangs|)
     `nb_contains` list scans in `p167ob_remaining`.
  4. Fast `-O0` `s10h_p112s_defs`: skips static-image compaction (`nc_compact` +
     `p112s_term`) on direct stubs (`sk >= 1000`), which contain zero static
     constructors and are never lowered via `nc_compact_definition`.
"""
from __future__ import annotations

import argparse
from pathlib import Path

MARKER = "# === S10-H: Fast -O0 x198pw_plan_fast ==="

S10H_IMPL = """
# === S10-H: Fast -O0 x198pw_plan_fast ===

law s10h_strip_ann:
  for +t: KTerm
  KTerm

@unsafe
def s10h_strip_ann_kids(+t: KTerm, kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Con{k0, _}: s10h_strip_ann(k0)
    case _: t

@unsafe
def s10h_strip_ann(t):
  match t:
    case KTerm{+tag, name, id, quant, +kids, removed, ob, oe}:
      nt_choose(KTerm, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Use"),
        u => s10h_strip_ann_kids(t, kids),
        u => t)
    case _: t

@unsafe
def s10h_is_self_call(+name: String, +t0: KTerm, +k: U32) -> Bool:
  +t = s10h_strip_ann(t0)
  nt_choose(Bool, U32.is_eq(k, 0),
    u => p98_tag_eq(t, "Ref") && agy_str_eq(nm(t), name),
    u => p98_tag_eq(t, "App") && p98_tag_eq(s10h_strip_ann(kid(t, 1)), "Var") && s10h_is_self_call(name, kid(t, 0), U32.sub(k, 1)))

law s10h_s10a_kind_go:
  for +name: String
  for +t0: KTerm
  for +k: U32
  U32

@unsafe
def s10h_s10a_kind_cur(+name: String, +t: KTerm, +k: U32) -> U32:
  match t:
    case KLambda{_, _, _, Con{body, _}, _, _, _, _}:
      s10h_s10a_kind_go(name, body, U32.inc(k))
    case _:
      nt_choose(U32, s10h_is_self_call(name, t, k),
        u => U32.add(1000, k),
        u =>
          +b0 = s10h_strip_ann(kid(t, 0))
          nt_choose(U32, p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && agy_str_eq(nm(b0), "_f") && s10h_is_self_call(name, kid(t, 1), k),
            v => 2,
            v => 0))

@unsafe
def s10h_s10a_kind_go(name, t0, k):
  s10h_s10a_kind_cur(name, s10h_strip_ann(t0), k)

@unsafe
def s10h_stub_kind(+book: List<&2, KDef>, +name: String) -> U32:
  +sk = w10_if_stub_kind(book, name)
  nt_choose(U32, U32.is_gt(sk, 0),
    u => sk,
    u =>
      +d = lookup(book, name)
      nt_choose(U32, agy_str_eq(dk(d), "Def") && U32.is_eq(dx(d), 0),
        v => nt_choose(U32, agy_str_eq(name, "_s10a_cps"),
          w => 2,
          w => s10h_s10a_kind_go(name, dv(d), 0)),
        v => 0))

@unsafe
def s10h_drop_stubs(+book: List<&2, KDef>, names: List<&2, String>, +acc: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: nt_reverse(String, acc, [])
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, U32.is_eq(s10h_stub_kind(book, name), 0),
        u => s10h_drop_stubs(book, rest, Con{name, acc}),
        u => s10h_drop_stubs(book, rest, acc))

@unsafe
def s10h_split_stubs(+book: List<&2, KDef>, names: List<&2, String>, +ready: KDef, +cps: KDef, +active: List<&2, String>) -> S10cSplit:
  match names:
    case Nil{}: S10cSplit{ready, cps, nt_reverse(String, active, [])}
    case Con{+name, +rest}:
      +sk = s10h_stub_kind(book, name)
      nt_choose(S10cSplit, U32.is_ge(sk, 1000),
        u => s10h_split_stubs(book, rest, p113e_insert(ready, s10c_stub_sig(p113d_public(book, name), U32.sub(sk, 1000))), cps, active),
        u => nt_choose(S10cSplit, U32.is_eq(sk, 2),
          v => s10h_split_stubs(book, rest, ready, p111v_put(cps, name, "W7Rem", 1, 0), active),
          v => s10h_split_stubs(book, rest, ready, cps, Con{name, active})))

@unsafe
def s10h_p167ob_remaining(+book: List<&2, KDef>, names: List<&2, String>, +bangMap: KDef, +ready: KDef, +acc: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: nt_reverse(String, acc, [])
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, s10c_p164a_allowed_fast(book, name, bangMap, ready),
        u => s10h_p167ob_remaining(book, rest, bangMap, ready, acc),
        u => s10h_p167ob_remaining(book, rest, bangMap, ready, Con{name, acc}))

@unsafe
def s10h_p112s_filter_names(+book: List<&2, KDef>, names: List<&2, String>, +acc: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: nt_reverse(String, acc, [])
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, U32.is_ge(s10h_stub_kind(book, name), 1000),
        u => s10h_p112s_filter_names(book, rest, acc),
        u => s10h_p112s_filter_names(book, rest, Con{name, acc}))

@unsafe
def s10h_p168_selected_split(source: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>,
    constructors: List<&2, N_Constructor>, nodes: List<&2, P112SNode>, +bangs: List<&2, String>,
    +bangMap: KDef, +workers: List<&2, P113DFunction>, split: S10cSplit) -> P167Lowered:
  match split:
    case S10cSplit{+ready_stubs, +cps, +active}:
      +pruned = w14a_prune_active(book, active, bangs, cps)
      +raw = w13d_p113pl_candidates_fast(book, pruned, bangs)
      +fns0 = p113d_passes(raw, ready_stubs, nt_reverse(P113DFunction, workers, []), 32)
      +all_ready = p113e_signatures(fns0, ready_stubs)
      s10c_p167l_catalogued_fast(source, book, names, constructors, nodes, bangs, p167l_private(fns0),
        s10c_p167l_catalogue(book, names, bangMap, all_ready, P167Catalogue{missing(), ""}))

@unsafe
def s10h_p168_seed_verified_fast(source: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>,
    constructors: List<&2, N_Constructor>, nodes: List<&2, P112SNode>, +bangs: List<&2, String>,
    +workers: List<&2, P113DFunction>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered, String.is_empty(error),
    u =>
      +ready0 = p113e_signatures(workers, missing())
      +bangMap = w8_bangs_index(bangs, missing())
      +rem = s10h_p167ob_remaining(book, names, bangMap, ready0, [])
      s10h_p168_selected_split(source, book, names, constructors, nodes, bangs, bangMap, workers,
        s10h_split_stubs(book, rem, ready0, w14d_cps_seed(), [])),
    u => p167l_fail("early scalar observer verification: " ++ error))

@unsafe
def s10h_p168_scanned_fast(source: List<&2, KDef>, book: List<&2, KDef>, names: List<&2, String>,
    +constructors: List<&2, N_Constructor>, nodes: List<&2, P112SNode>, bangs: List<&2, String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers, helpers, retry, +error}:
      nt_choose(P167Lowered, String.is_empty(error),
        u => s10h_p168_seed_verified_fast(source, book, names, constructors, nodes, bangs, workers,
          p167ob_seed_verify(constructors, workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))

@unsafe
def s10h_p168_prepared_fast(source: List<&2, KDef>, +names: List<&2, String>,
    constructors: List<&2, N_Constructor>, prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book, nodes, +error}:
      +bangs = nc_bangs_names(book, names)
      nt_choose(P167Lowered, String.is_empty(error),
        u => s10h_p168_scanned_fast(source, book, names, constructors, nodes, bangs,
          p128br_scan(book, s10h_drop_stubs(book, no_candidate_names(book, names, bangs), []), [], [], [], [])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def s10h_p168_fast(+request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source, +book, +names, paths, scope, bound}:
      +error = nc_compile_error_known(source, bound)
      nt_choose(P167Lowered, String.is_empty(error), u =>
        nt_choose(P167Lowered, p167ob_permission(request),
          v =>
            +ctors = nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
            +p112s_names = s10h_p112s_filter_names(book, names, [])
            s10h_p168_prepared_fast(source, names, ctors, p112s_prepare(book, p112s_names, ctors)),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error))

@unsafe
def s10h_p169np_admitted_fast(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared, String.is_empty(error),
    u => w13d_p169s_lowered_fast(s10h_p168_fast(request)),
    u => p169s_fail("compile: " ++ error))
"""

OLD_S10C_PLAN = """@unsafe
def s10c_plan_fast(plan):
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      s10c_p169np_admitted_fast(request,p111_runtime_admission(request))"""

NEW_S10C_PLAN = S10H_IMPL + """
@unsafe
def s10c_plan_fast(plan):
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      s10h_p169np_admitted_fast(request,p111_runtime_admission(request))"""


def patch_text(src: str) -> tuple[str, bool]:
    if MARKER in src:
        return src, False
    if OLD_S10C_PLAN not in src:
        raise RuntimeError(
            "S10-H requires S10-C (`apply_s10c.py`) to be applied first: "
            "`s10c_plan_fast` anchor not found."
        )
    count = src.count(OLD_S10C_PLAN)
    if count != 1:
        raise RuntimeError(f"S10-H anchor matched {count} times (expected 1)")
    return src.replace(OLD_S10C_PLAN, NEW_S10C_PLAN, 1), True


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-H fast -O0 x198pw_plan_fast patch (after S10-C).")
    ap.add_argument("input", type=Path, help="Input compiler.bend or m09.bend (with S10-C applied)")
    ap.add_argument("-o", "--output", type=Path, default=None, help="Output file (defaults to overwriting input)")
    args = ap.parse_args()
    src = args.input.read_text(encoding="utf-8")
    patched, changed = patch_text(src)
    dst = args.output or args.input
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(patched, encoding="utf-8")
    status = "APPLIED" if changed else "ALREADY_APPLIED"
    print(f"[S10-H] {status}: {args.input} -> {dst} ({len(patched):,} bytes)")


if __name__ == "__main__":
    main()

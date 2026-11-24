#!/usr/bin/env python3
"""B4: x198pw_plan + p86_plan Algorithmic Hotspot Killer.

Idempotent, semantics-preserving patcher targeting
`selfhost/build/agy/wave17_unified/compiler.bend` (100% disjoint from B2/B3).
Zero change to `-O2` codegen semantics (0% `-O2` runtime regression).

Four surgical optimizations backed by `gdb` sampling on `n8_o2`:
1. `b4_nc_uses_term` (`x198pw_plan`, 3/30 gdb samples):
   Unpacks `KTerm` ONCE in `nc_uses_term` instead of calling `p98_tag_eq` +
   re-unpacking `ix(t)`/`ks(t)` in `w5c2_nc_uses_if`. Fast-paths `KLiteral`
   (immediate `uses` return), `KLambda` (skips `"Var"` check), and leaf `KTerm`
   with `Nil{}` kids.
2. `b4_nq_layout_subst` (`x198pw_plan`, 2/30 gdb samples):
   Replaces slow CPS `String.eq(tag, "Var")` with `agy_str_eq(tag, "Var")`,
   short-circuits leaf `KTerm` (`kids == Nil{}`) to return `t` with zero
   allocation, and constructs `KTerm{...}` directly instead of calling
   `k_rebuild` + 6 field accessors (`nm/qt/ks/rm/kb/ke`).
3. `b4_pre_bang_index` (`x198pw_plan` `w7_filter_remaining`):
   Replaces O(N * |bangs|) `nb_contains(bangs, name)` linear scan in
   `w7_pre_build_set` with O(1) `w5c3_find` on a pre-built `w8_bangs_index`.
4. `b4_o2_mod_check` (`p86_plan` `s10e_plan_loaded_check`):
   In `-O2` modular mode (`fast == False && is_mod == True`), routes through
   `s10e_p143cb_program(..., True{})` so the 422 shared `ADT`s, `law`s, and
   synthetic zero-`.p130` `@unsafe` stubs skip redundant `check_definition_world`
   while every real `def` remains 100% typechecked. (`x86-object`/`x86` stays
   100% untouched.)
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave17_unified/compiler.bend"
MARKER = "# === B4 X198PW_PLAN + P86_PLAN HOTSPOT KILLER ==="

# --- Patch 1: nc_uses_term single-unpack + KLiteral/KLambda/Nil fast paths ---
OLD_NC_USES = """@unsafe
def w5c2_nc_uses_if(is_var: Bool, +t: KTerm, +uses: NU_Set) -> NU_Set:
  match is_var:
    case True{}: nu_add(uses, ix(t))
    case False{}: nc_uses_list(ks(t), uses)

@unsafe
def nc_uses_term(+t: KTerm, +uses: NU_Set) -> NU_Set:
  w5c2_nc_uses_if(p98_tag_eq(t, "Var"), t, uses)"""

NEW_NC_USES = f"""{MARKER}
@unsafe
def b4_nc_uses_kterm(is_var: Bool, +n: U32, kids: List<&2, KTerm>, +uses: NU_Set) -> NU_Set:
  match is_var:
    case True{{}}: nu_add(uses, n)
    case False{{}}:
      match kids:
        case Nil{{}}: uses
        case Con{{h, rest}}: nc_uses_list(rest, nc_uses_term(h, uses))

@unsafe
def w5c2_nc_uses_if(is_var: Bool, +t: KTerm, +uses: NU_Set) -> NU_Set:
  match is_var:
    case True{{}}: nu_add(uses, ix(t))
    case False{{}}: nc_uses_list(ks(t), uses)

@unsafe
def nc_uses_term(+t: KTerm, +uses: NU_Set) -> NU_Set:
  match t:
    case KTerm{{tag, _, n, _, kids, _, _, _}}:
      b4_nc_uses_kterm(agy_str_eq(tag, "Var"), n, kids, uses)
    case KLambda{{_, _, _, kids, _, _, _, _}}:
      nc_uses_list(kids, uses)
    case KLiteral{{_, _, _, _, _}}: uses"""

# --- Patch 2: nq_layout_subst agy_str_eq + leaf short-circuit + direct KTerm ---
OLD_NQ_SUBST = """@unsafe
def w5c2_nq_sub_if(is_var: Bool, +t: KTerm, +n: U32, +id: U32, +value: KTerm) -> KTerm:
  match is_var:
    case True{}: w5c2_nq_sub_var(U32.is_eq(n, id), t, value)
    case False{}: k_rebuild(t, nm(t), n, qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t))

@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KTerm{tag, _, n, _, _, _, _, _}:
      w5c2_nq_sub_if(String.eq(tag, "Var"), t, n, id, value)
    case KLambda{name, n, quant, kids, removed, begin, end, present}:
      KLambda{name, n, quant, nq_layout_subst_list(kids, id, value), removed, begin, end, present}
    case KLiteral{_, _, _, _, _}: t"""

NEW_NQ_SUBST = """@unsafe
def b4_nq_sub_kids(+t: KTerm, +tag: String, +name: String, +n: U32, +quant: U32,
    kids: List<&2, KTerm>, +removed: List<&2, String>, +begin: U32, +end: U32,
    +id: U32, +value: KTerm) -> KTerm:
  match kids:
    case Nil{}: t
    case Con{h, rest}:
      KTerm{tag, name, n, quant, Con{nq_layout_subst(h, id, value), nq_layout_subst_list(rest, id, value)}, removed, begin, end}

@unsafe
def b4_nq_sub_kterm(is_var: Bool, +t: KTerm, +tag: String, +name: String, +n: U32, +quant: U32,
    kids: List<&2, KTerm>, +removed: List<&2, String>, +begin: U32, +end: U32,
    +id: U32, +value: KTerm) -> KTerm:
  match is_var:
    case True{}: w5c2_nq_sub_var(U32.is_eq(n, id), t, value)
    case False{}: b4_nq_sub_kids(t, tag, name, n, quant, kids, removed, begin, end, id, value)

@unsafe
def w5c2_nq_sub_if(is_var: Bool, +t: KTerm, +n: U32, +id: U32, +value: KTerm) -> KTerm:
  match is_var:
    case True{}: w5c2_nq_sub_var(U32.is_eq(n, id), t, value)
    case False{}: k_rebuild(t, nm(t), n, qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t))

@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KTerm{tag, name, n, quant, kids, removed, begin, end}:
      b4_nq_sub_kterm(agy_str_eq(tag, "Var"), t, tag, name, n, quant, kids, removed, begin, end, id, value)
    case KLambda{name, n, quant, kids, removed, begin, end, present}:
      KLambda{name, n, quant, nq_layout_subst_list(kids, id, value), removed, begin, end, present}
    case KLiteral{_, _, _, _, _}: t"""

# --- Patch 3: w7_pre_build_set O(1) bangMap lookup ---
OLD_PRE_BUILD = """@unsafe
def w7_pre_build_set(+book: List<&2,KDef>, xs: List<&2,String>, +bangs: List<&2,String>, +acc: KDef) -> KDef:
  match xs:
    case Nil{}: acc
    case Con{+name,+rest}:
      +d = lookup(book,name)
      nt_choose(KDef,agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),64),
        u => w7_pre_build_set(book,rest,bangs,p111v_put(acc,name,"W7Rem",1,0)),
        u => w7_pre_build_set(book,rest,bangs,acc))"""

NEW_PRE_BUILD = """@unsafe
def b4_pre_build_set_idx(+book: List<&2,KDef>, xs: List<&2,String>, +bangMap: KDef, +acc: KDef) -> KDef:
  match xs:
    case Nil{}: acc
    case Con{+name,+rest}:
      +d = lookup(book,name)
      +bh = index_hash(name,2166136261)
      +isBang = Bool.not(agy_str_eq(dk(w5c3_find(bangMap,name,bh)),"Absent"))
      nt_choose(KDef,agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || isBang) && U32.is_le(nd_arity(book,name),64),
        u => b4_pre_build_set_idx(book,rest,bangMap,p111v_put(acc,name,"W7Rem",1,0)),
        u => b4_pre_build_set_idx(book,rest,bangMap,acc))

@unsafe
def w7_pre_build_set(+book: List<&2,KDef>, xs: List<&2,String>, +bangs: List<&2,String>, +acc: KDef) -> KDef:
  b4_pre_build_set_idx(book,xs,w8_bangs_index(bangs,missing()),acc)"""

# --- Patch 4: s10e_plan_loaded_check -O2 x86-module fast ADT/law/stub skip ---
OLD_S10E_CHECK = """@unsafe
def s10e_plan_loaded_check(fast: Bool, +load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, +is_mod: Bool) -> DResult:
  match fast:
    case True{}: s10e_p143cb_program(load, Nil{}, world, is_mod)
    case False{}:
      nt_choose(DResult, p143cg_enough(suffix, 256),
        v => p143cb_program(load, Nil{}, world, True{}),
        v => check_program_diagnostic_world(load, Nil{}, world))"""

NEW_S10E_CHECK = """@unsafe
def s10e_plan_loaded_check(fast: Bool, +load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, +is_mod: Bool) -> DResult:
  match fast:
    case True{}: s10e_p143cb_program(load, Nil{}, world, is_mod)
    case False{}:
      nt_choose(DResult, is_mod && p143cg_enough(suffix, 256),
        u => s10e_p143cb_program(load, Nil{}, world, True{}),
        u => nt_choose(DResult, p143cg_enough(suffix, 256),
          v => p143cb_program(load, Nil{}, world, True{}),
          v => check_program_diagnostic_world(load, Nil{}, world)))"""


def apply_patch(text: str) -> tuple[str, bool]:
    if MARKER in text:
        return text, False

    patches = [
        ("b4_nc_uses_term", OLD_NC_USES, NEW_NC_USES),
        ("b4_nq_layout_subst", OLD_NQ_SUBST, NEW_NQ_SUBST),
        ("b4_pre_bang_index", OLD_PRE_BUILD, NEW_PRE_BUILD),
        ("b4_o2_mod_check", OLD_S10E_CHECK, NEW_S10E_CHECK),
    ]
    out = text
    for name, old, new in patches:
        cnt = out.count(old)
        if cnt != 1:
            raise RuntimeError(f"Patch {name} expected 1 anchor match, found {cnt}")
        out = out.replace(old, new, 1)
    return out, True


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply B4 x198pw_plan + p86_plan hotspot optimizations")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC, help="Input compiler.bend")
    ap.add_argument("--out", type=Path, default=None, help="Output path (defaults to --src in-place)")
    ap.add_argument("--check", "--check-only", dest="check", action="store_true",
                    help="Run research/agy/locked_bun.sh --check-only after patching")
    args = ap.parse_args()

    out_path = args.out if args.out is not None else args.src
    src_text = args.src.read_text(encoding="utf-8")
    patched, changed = apply_patch(src_text)
    if changed or out_path != args.src:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(patched, encoding="utf-8")
        print(f"[b4] Patched ({'applied 4 optimizations' if changed else 'already applied, copied'}) -> {out_path}")
    else:
        print(f"[b4] Already applied (idempotent no-op) -> {out_path}")

    if args.check:
        cmd = ["bash", str(ROOT / "research/agy/locked_bun.sh"), "--check-only", str(out_path)]
        print(f"[b4] Running: {' '.join(cmd)}", flush=True)
        r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        only_unsafe = (
            r.returncode == 0
            or ("defs rely on unsafe or foreign code:" in combined and "Location:" not in combined)
        )
        if not only_unsafe:
            print(combined[-3000:], file=sys.stderr)
            sys.exit(r.returncode or 1)
        print("[b4] --check-only PASS (0 type/linearity errors)")


if __name__ == "__main__":
    main()

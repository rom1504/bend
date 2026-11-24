#!/usr/bin/env python3
"""O2-C: Fix the 3 Wave 16 -O2 bugs blocking 158/158 PASS.

Idempotent, pure-Bend patcher for selfhost/build/agy/wave16_unified/compiler.bend:

  1. Bug #1 (`x86-merge-obj` `p111_program.caps` bit `0x2` bug):
     - In `w10_merge_copy_one`, bitwise-AND each merged module's `caps`
       (`p111_mod_<mod>_program + 88`) into the global `p111_program + 88`.
     - Prevents an entry module with `caps = 7` (`set3 = True`, region-only mode)
       from overriding a module with `Array.new`/`Array.set` (`caps = 5`,
       `set3 = False`). `set3` (and all capability bits) stay set if and only if
       ALL merged modules satisfy them.

  2. Bug #2 (`x86-iface v3` `x198o_progress_get` `jmpq <self>` thunk):
     - In `w14a_fast_abi_go2`, compute `nq_sigs = book_cached(nq_signatures(book, names), 0)`
       and call `p113pl_candidates(book, pruned, bangs, nq_sigs)` instead of
       `w13d_p113pl_candidates_fast(book, pruned, bangs)` (which passed `[]`).
     - Previously, passing `[]` caused `x86-iface v3` to compute the `-O0` direct
       set instead of the `-O2` direct set: functions returning a product type
       like `x198o_progress_get` (`X198OProgress`) were emitted as `$direct` stubs
       in `m00.p130`, while `-O2` `x86-object` on `m00` kept them CPS. Downstream
       `m01.o` then compiled the `$direct` stub into a 3-insn infinite loop
       (`mov %rsi,%rdi; mov %rdx,%rsi; jmpq <self>`).

  3. Bug #3 (`w11_cmp_jcc_emit` missing branch-target liveness check -> `w5c2_bits_nz` `xorl $1, %edx` bug):
     - In `w11_cmp_jcc_emit`, check `w5b_reg_dead_fast(rA, after, fnItems)` and
       `w5b_reg_dead_fast(rB, after, fnItems)` where
       `after = Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}`,
       rather than checking only fallthrough `tail`.
     - Previously, `w11_cmp_jcc_emit` fused `cmpq $1, %r8; sete %dl; movzbl %dl, %edx;
       movq %rdx, %r10; testl %r10d, %r10d; jz .L_b0` into `cmpq $1, %r8; jne .L_b0`
       whenever `%edx` was dead on fallthrough `tail` (`ret`), even when `%edx` was
       still live at `.L_b0` (`xorl $1, %edx`), leaving `%edx` holding uninitialized
       garbage (argument `v`).
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
DEFAULT_OUT = Path("/tmp/agy_o2c/compiler_o2c.bend")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        print(f"  [SKIP] {label} (already applied)", flush=True)
        return text
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"{label}: expected 1 match, found {cnt}")
    print(f"  [OK]   {label}", flush=True)
    return text.replace(old, new, 1)


def apply_o2c(text: str) -> str:
    # Fix #1: x86-merge-obj caps bitwise-AND across all merged modules in w10_merge_copy_one
    old_fix1 = """    x188_i2("movq",X187Mem{8,56},x188_reg(0,64)),
    x188_i2("cmpq",X187Mem{9,56},x188_reg(0,64)),
    x188_i1("jbe",X187Target{lbl_resw}),
    x188_i2("movq",x188_reg(0,64),X187Mem{9,56}),
    x188_label(lbl_resw),
    x188_i2("movq",X187Mem{8,16},x188_reg(1,64)),"""

    new_fix1 = """    x188_i2("movq",X187Mem{8,56},x188_reg(0,64)),
    x188_i2("cmpq",X187Mem{9,56},x188_reg(0,64)),
    x188_i1("jbe",X187Target{lbl_resw}),
    x188_i2("movq",x188_reg(0,64),X187Mem{9,56}),
    x188_label(lbl_resw),
    x188_i2("movq",X187Mem{8,88},x188_reg(0,64)),
    x188_i2("movq",X187Mem{9,88},x188_reg(1,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{9,88}),
    x188_i2("movq",X187Mem{8,16},x188_reg(1,64)),"""

    text = replace_once(text, old_fix1, new_fix1, "Fix #1: w10_merge_copy_one caps bitwise-AND")

    # Fix #2: x86-iface v3 w14a_fast_abi_go2 use nq_signatures + p113pl_candidates
    old_fix2 = """@unsafe
def w14a_fast_abi_go2(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, pair: W10IfAbi, +active0: List<&2, String>) -> IO(U32):
  match pair:
    case W10IfAbi{+seeded_sigs, +cps}:
      +pruned = w14a_prune_active(book, active0, bangs, cps)
      +raw = w13d_p113pl_candidates_fast(book, pruned, bangs)
      +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
      +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
      w10_if_emit_seed(seed, suffix, abi)"""

    new_fix2 = """@unsafe
def w14a_fast_abi_go2(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, pair: W10IfAbi, +active0: List<&2, String>) -> IO(U32):
  match pair:
    case W10IfAbi{+seeded_sigs, +cps}:
      +pruned = w14a_prune_active(book, active0, bangs, cps)
      +nq_sigs = book_cached(nq_signatures(book, names), 0)
      +raw = p113pl_candidates(book, pruned, bangs, nq_sigs)
      +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
      +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
      w10_if_emit_seed(seed, suffix, abi)"""

    text = replace_once(text, old_fix2, new_fix2, "Fix #2: w14a_fast_abi_go2 use nq_signatures + p113pl_candidates")

    # Fix #3: w11_cmp_jcc_emit check branch target + fallthrough liveness
    old_fix3 = """@unsafe
def w11_cmp_jcc_emit(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    j_opt: Maybe<&2,W11Jcc>, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match j_opt:
    case Some{W11Jcc{+isN,+lbl}}:
      +flip = nt_choose(Bool,inv,w => isN,w => Bool.not(isN))
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems),
        w => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}}},
        w => None{})
    case _: None{}"""

    new_fix3 = """@unsafe
def w11_cmp_jcc_emit(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    j_opt: Maybe<&2,W11Jcc>, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match j_opt:
    case Some{W11Jcc{+isN,+lbl}}:
      +flip = nt_choose(Bool,inv,w => isN,w => Bool.not(isN))
      +after : List<&2,X187Parsed> = Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_reg_dead_fast(rA,after,fnItems) && w5b_reg_dead_fast(rB,after,fnItems),
        w => Some{Con{cmpInst,after}},
        w => None{})
    case _: None{}"""

    text = replace_once(text, old_fix3, new_fix3, "Fix #3: w11_cmp_jcc_emit check branch-target + fallthrough liveness")

    return text


def main() -> int:
    ap = argparse.ArgumentParser(description="Apply O2-C 3-bug -O2 fix to wave16_unified/compiler.bend")
    ap.add_argument("src", nargs="?", default=str(DEFAULT_SRC), help="Input compiler.bend")
    ap.add_argument("out", nargs="?", default=str(DEFAULT_OUT), help="Output compiler.bend")
    ap.add_argument("--in-place", action="store_true", help="Modify src in place")
    args = ap.parse_args()

    src_path = Path(args.src)
    out_path = src_path if args.in_place else Path(args.out)

    text = src_path.read_text(encoding="utf-8")
    patched = apply_o2c(text)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(patched, encoding="utf-8")
    print(f"Wrote {out_path} ({len(patched):,} B)", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

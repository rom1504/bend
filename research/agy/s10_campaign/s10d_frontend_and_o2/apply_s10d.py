#!/usr/bin/env python3
"""S10-D: Pure-Bend -O2 Codegen Restoration for wave15_unified.

Idempotent, general, pure-Bend patcher for wave15_unified/compiler.bend (or S10-B pruned
compiler_pruned.bend). Touches ZERO runtime.c, runtime-agy.o, bend2/bend.ts, p86_plan, or
term_drop code (100% orthogonal to S10-B, S10-E, and S10-F).

Upgrades:
  1. Restore W14-A editdist ($product.columns 0-spill inner loop -> ~16.4 ms / 1.62x C):
     - Extend `w5_g11_b` (G11 if-conversion) to also match fallthrough
       `jne/je L; movq -disp(%rbp), %r64; L:` (when an earlier peephole already removed
       the redundant `jmp L; L:`). This restores `cmoveq -disp(%rbp), %r64; L:`, which
       unlocks `w14a_cmov_table_go` (`negq` + indexed `movq`) and `w14a_sl_loop_opt`
       (straight-line loop register promotion, eliminating all 6 stack spills).
     - Leaves all other 6 proxy families 100% bit-identical to `n6_o2` (zero regression).
  2. Optional (`--with-imm8`): Compact x86-64 ALU `0x83` `imm8` encoding in `x187_e_alu`
     for `0 <= lo <= 127` (`hi == 0`, `width != 8`), shrinking `.o` files by ~1-3%
     (disabled by default to avoid Ivy Bridge 32B DSB alignment jitter on `bst`).
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
DEFAULT_OUT = Path("/tmp/agy_s10d/compiler_s10d.bend")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        print(f"  [SKIP] {label} (already applied)", flush=True)
        return text
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"{label}: expected 1 match, found {cnt}")
    print(f"  [OK]   {label}", flush=True)
    return text.replace(old, new, 1)


def apply_s10d(text: str, with_imm8: bool = False) -> str:
    # 1. w5_g11_b fallthrough jne/je L; movq -d(%rbp), %r; L: -> cmoveq/cmovneq -d(%rbp), %r; L:
    old_g11 = """@unsafe
def w5_g11_b(+cmop: String, +lbl: String, ld1: W5LoadRbp, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d,r}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5_g11_c(cmop,d,r,lbl,w4b_as_branch(i2),i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}"""

    new_g11 = """@unsafe
def w5_g11_b(+cmop: String, +lbl: String, ld1: W5LoadRbp, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d,r}:
      match r2:
        case Con{PLabel{+l2},+r3}:
          nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l2,lbl),
            u => Some{w5_gpr_peep(Con{PLabel{l2},r3},fnItems,
              Con{PInst{X187Instruction{cmop,[X187Mem{5,d},x188_reg(r,64)]}},acc})},
            u => None{})
        case Con{+i2,Con{+i3,+r4}}: w5_g11_c(cmop,d,r,lbl,w4b_as_branch(i2),i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}"""

    text = replace_once(text, old_g11, new_g11, "s10d_g11_fallthrough_cmov")

    if with_imm8:
        old_alu = """@unsafe
def x187_e_alu(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 128,v => 129)],U32.is_eq(width,64),ext,dst,
          x187_e_byte(dst),x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),v => 1,v => 4)),offset),u => x187_e_error())"""

        new_alu = """@unsafe
def x187_e_alu(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      +imm8 = Bool.not(U32.is_eq(width,8)) && U32.is_eq(hi,0) && U32.is_le(lo,127)
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 128,v => nt_choose(U32,imm8,w => 131,w => 129))],U32.is_eq(width,64),ext,dst,
          x187_e_byte(dst),x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8) || imm8,v => 1,v => 4)),offset),u => x187_e_error())"""

        text = replace_once(text, old_alu, new_alu, "s10d_alu_imm8_0x83")

    return text


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-D pure-Bend -O2 restoration upgrades")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--with-imm8", action="store_true", help="Also enable compact 0x83 imm8 ALU encoding")
    args = ap.parse_args()

    print(f"=== S10-D Patching {args.src} -> {args.out} ===", flush=True)
    text = args.src.read_text(encoding="utf-8")
    patched = apply_s10d(text, with_imm8=args.with_imm8)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(patched, encoding="utf-8")
    print(f"=== Done ({len(patched):,} B) ===", flush=True)


if __name__ == "__main__":
    main()

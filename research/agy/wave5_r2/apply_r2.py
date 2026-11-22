#!/usr/bin/env python3
"""Wave 5 Engine B Track W5-R2: General nbody / gameoflife / expression C16 Closer.

100% general, semantics-preserving compiler passes on top of wave4c_unified/compiler.bend:
  1. High-Param Loop Regalloc Dispatch (`x190_j_counted`):
     Only dispatch >64-candidate loop functions to `x181_register_frame` (4 callee-saved GPRs)
     + `x185_transient_frame` when `params <= 8`. High-param loops (>8 params) stay in
     `x190_j_selected` (9-GPR graph coloring), eliminating the Wave 4C composition spill
     regression on high-param loops while keeping huge-body low-param loops on transient alloc.
  2. General XMM Register-Copy & Commutative Memory-Operand Folding (`w5_xmm_fold`):
     Runs at the end of `w4c_xmm_opt` (preserving exact IEEE-754 F32 semantics, no FMA):
       - X1: `movaps %xmmA, %xmmA` -> drop
       - X2: `movaps %xmmA, %xmmB; <fop> src, %xmmB; movaps %xmmB, %xmmA` (%xmmB dead) -> `<fop> src, %xmmA`
       - X3: `movaps %xmmA, %xmmB; movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA` (%xmmB dead)
             -> `<addss|mulss> disp(%rbp), %xmmA`
       - X4: `movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA; movq %xmmA, disp(%rbp)` (%xmmA,%xmmB dead)
             -> `<addss|mulss> disp(%rbp), %xmmB; movq %xmmB, disp(%rbp)`
       - X5: `movaps %xmmA, %xmmB; <fop> %xmmB, %xmmC` (%xmmB dead) -> `<fop> %xmmA, %xmmC`
       - X6: `<movd|movaps|sqrtss> src, %xmmA; movaps %xmmA, %xmmB` (%xmmA dead) -> `<op> src, %xmmB`
  3. General x86-64 GPR Peepholes (`w5_gpr_peep` in `w4_post_select`):
       - G1: 4-inst commutative memory-operand ALU ping-pong collapse:
             `movq m1, %rB; <comm64> %rA, %rB; movq m2, %rA; <comm64> %rB, %rA` (%rB dead)
             -> `<comm64> m1, %rA; <comm64> m2, %rA`
       - G2: 6-inst direct-register `cmov` select (no %rax/%r10/%r11 bounce):
             `movq %rC, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst`
             -> `testl %rC32, %rC32; cmovneq srcY, %rN; movq %rN, dst`
       - G3: 4-inst 3-way swap before commutative 32/64-bit ALU:
             `movq %rA, %rT; movq %rB, %rA; movq %rT, %rB; <comm> %rA, %rB` (%rT,%rA dead) -> `<comm> %rA, %rB`
       - G4: 4-inst non-commutative `subl` copy-bounce collapse:
             `movq %rA, %rT; movq %rD, %rA; subl %rT32, %rA32; movq %rA, %rD` (%rT,%rA dead) -> `subl %rA32, %rD32`
       - G5: 4-inst `movq %rA, %rB; cmpq $C, %rB; setcc %rB8; movzbl %rB8, %rB32` -> drop `movq`
       - G6: 3-inst `movq %rA, %rB; imull $3, %rB32; addl %rB32, %rD32` -> `leaq (%rA,%rA,2), %rB; addl %rB32, %rD32`;
             3-inst `movq %rA, %rB; addl $c, %rB32; subl %rB32, %rD32` -> `leaq c(%rA), %rB; subl %rB32, %rD32`;
             3-inst `movl %rA32, %rB32; addl $c, %rB32; imull %rB32, %rD32` -> `addl $c, %rA32; imull %rA32, %rD32`
       - G7: 3-inst `movq %rA, %rB; andq $M, %rB; movq %rB, disp(%rbp)` (%rA,%rB dead) -> `andq $M, %rA; movq %rA, disp(%rbp)`
       - G8: 2-inst double `xor $1` (`xorl $1, %r32; xorq $1, %r64`, flags dead) -> `movl %r32, %r32`
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4c_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5_r2/compiler.bend"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------------------------
# Patch 1: High-param loop regalloc dispatch in x190_j_counted
# ---------------------------------------------------------------------------
OLD_J_COUNTED = """      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) || U32.is_gt(nCands,64),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),"""

NEW_J_COUNTED = """      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) ||
          (U32.is_gt(nCands,64) && U32.is_le(nt_count(String,params),8)),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),"""


# ---------------------------------------------------------------------------
# Patch 1b: Allow w4b_reg_dead to walk past setcc instructions
# ---------------------------------------------------------------------------
OLD_SIMPLE_ALU = """  agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || String.starts_with(op,"cmov")"""

NEW_SIMPLE_ALU = """  agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || String.starts_with(op,"cmov") ||
  String.starts_with(op,"set")"""


# ---------------------------------------------------------------------------
# Patch 2 & 3: General XMM fold (`w5_xmm_fold`) + General GPR peepholes (`w5_gpr_peep`)
# ---------------------------------------------------------------------------
W5_PASSES = r"""
# ---- W5-R2: General XMM Register-Copy & Commutative Memory-Operand Folding ----

@unsafe
def w5_is_comm_fop(+op: String) -> Bool:
  agy_str_eq(op,"addss") || agy_str_eq(op,"mulss")

type W5Movaps is Data:
  W5MANo{}
  W5MAYes{+src: U32, +dst: U32}

@unsafe
def w5_as_movaps(item: X187Parsed) -> W5Movaps:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,_,True{}},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5Movaps,agy_str_eq(op,"movaps"),u => W5MAYes{sr,dr},u => W5MANo{})
    case _: W5MANo{}

type W5MovdSlot is Data:
  W5MSNo{}
  W5MSYes{+disp: U32, +dst: U32}

@unsafe
def w5_as_movd_slot(item: X187Parsed) -> W5MovdSlot:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5MovdSlot,agy_str_eq(op,"movd") && U32.is_eq(b,5),u => W5MSYes{d,dr},u => W5MSNo{})
    case _: W5MSNo{}

type W5XmmProd is Data:
  W5XPNo{}
  W5XPYes{+op: String, +src: X187Operand, +dst: U32}

@unsafe
def w5_as_xmm_prod(item: X187Parsed) -> W5XmmProd:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5XmmProd,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps") || agy_str_eq(op,"sqrtss"),
        u => W5XPYes{op,src,dr},u => W5XPNo{})
    case _: W5XPNo{}

law w5_xmm_fold:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# X2: movaps %xmmA, %xmmB; <fop> src, %xmmB; movaps %xmmB, %xmmA (%xmmB dead) -> <fop> src, %xmmA
@unsafe
def w5_x2_c(+a: U32, +b: U32, +fop: String, +fsrc: X187Operand, m2: W5Movaps,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m2:
    case W5MAYes{s2,d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s2,b) && U32.is_eq(d2,a) && Bool.not(w4c_op_is_xmm(a,fsrc)) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,Con{PInst{X187Instruction{fop,[fsrc,x188_xmm(a)]}},acc})},
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_x2_b(+a: U32, +b: U32, f1: W4CFopAny, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst,b),
        u => w5_x2_c(a,b,fop,fsrc,w5_as_movaps(i2),r3,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

# X3: movaps %xmmA, %xmmB; movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA (%xmmB dead)
#     -> <addss|mulss> disp(%rbp), %xmmA
@unsafe
def w5_x3_c(+a: U32, +b: U32, +disp: U32, f2: W4CFopAny,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm_fop(fop) && U32.is_eq(fdst,a) && w4c_op_is_xmm(b,fsrc) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,Con{PInst{X187Instruction{fop,[X187Mem{5,disp},x188_xmm(a)]}},acc})},
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5_x3_b(+a: U32, +b: U32, ld1: W5MovdSlot, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5MSYes{disp,ldst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(ldst,a),
        u => w5_x3_c(a,b,disp,w4c_as_fop_any(i2),r3,fnItems,acc),
        u => None{})
    case W5MSNo{}: None{}

# X5: movaps %xmmA, %xmmB; <fop> %xmmB, %xmmC (%xmmB dead) -> <fop> %xmmA, %xmmC
@unsafe
def w5_x5(+a: U32, +b: U32, f1: W4CFopAny, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+fop,fsrc,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(b,fdst)) && w4c_op_is_xmm(b,fsrc) && w4c_xmm_dead(b,r2,fnItems,400,2),
        u => Some{w5_xmm_fold(r2,fnItems,Con{PInst{X187Instruction{fop,[x188_xmm(a),x188_xmm(fdst)]}},acc})},
        u => None{})
    case W4CFANo{}: None{}

# X4: movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA; movq %xmmA, disp(%rbp) (%xmmA,%xmmB dead)
#     -> <addss|mulss> disp(%rbp), %xmmB; movq %xmmB, disp(%rbp)
@unsafe
def w5_x4_d(+disp: U32, +a: U32, +b: U32, +fop: String, st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W4CMXMYes{sx,sdisp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(a,b)) && U32.is_eq(sx,a) && U32.is_eq(sdisp,disp) &&
        w4c_xmm_dead(a,r3,fnItems,400,2) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(b),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{fop,[X187Mem{5,disp},x188_xmm(b)]}},acc}})},
        u => None{})
    case W4CMXMNo{}: None{}

@unsafe
def w5_x4_c(+disp: U32, +a: U32, +fop: String, fsrc: X187Operand, +st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match fsrc:
    case X187Reg{b,_,True{}}: w5_x4_d(disp,a,b,fop,st2,r3,fnItems,acc)
    case _: None{}

@unsafe
def w5_x4_b(+disp: U32, +a: U32, f1: W4CFopAny, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5_is_comm_fop(fop) && U32.is_eq(fdst,a),
        u => w5_x4_c(disp,a,fop,fsrc,w4c_as_movq_xm(i2),r3,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

# X6: <movd|movaps|sqrtss> src, %xmmA; movaps %xmmA, %xmmB (%xmmA dead) -> <op> src, %xmmB
@unsafe
def w5_x6_b(+op0: String, +src0: X187Operand, +a: U32, m1: W5Movaps,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MAYes{s1,+b}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s1,a) && Bool.not(U32.is_eq(a,b)) && Bool.not(w4c_op_is_xmm(b,src0)) &&
        w4c_xmm_dead(a,r2,fnItems,400,2),
        u => Some{w5_xmm_fold(r2,fnItems,Con{PInst{X187Instruction{op0,[src0,x188_xmm(b)]}},acc})},
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_x6_a(p0: W5XmmProd, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match p0:
    case W5XPYes{op0,src0,a}: w5_x6_b(op0,src0,a,w5_as_movaps(i1),r2,fnItems,acc)
    case W5XPNo{}: None{}

@unsafe
def w5_x6(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w5_x6_a(w5_as_xmm_prod(i0),i1,r2,fnItems,acc)

@unsafe
def w4c_or_peep_opt(res: Maybe<&2,List<&2,X187Parsed>>,
    fallback: Unit -> Maybe<&2,List<&2,X187Parsed>>) -> Maybe<&2,List<&2,X187Parsed>>:
  match res:
    case Some{out}: Some{out}
    case None{}: fallback(Unit{})

@unsafe
def w5_xmm_fold_ma_r2(+a: U32, +b: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_x2_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
        v => w4c_or_peep_opt(w5_x3_b(a,b,w5_as_movd_slot(i1),i2,r3,fnItems,acc),
          w => w5_x5(a,b,w4c_as_fop_any(i1),Con{i2,r3},fnItems,acc)))
    case Nil{}: w5_x5(a,b,w4c_as_fop_any(i1),[],fnItems,acc)

@unsafe
def w5_xmm_fold_ma(+a: U32, +b: U32, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(a,b),
    u => Some{w5_xmm_fold(Con{i1,r2},fnItems,acc)},
    u => w5_xmm_fold_ma_r2(a,b,i1,r2,fnItems,acc))

@unsafe
def w5_xmm_try_ma(ma: W5Movaps, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ma:
    case W5MAYes{a,b}: w5_xmm_fold_ma(a,b,i0,i1,r2,fnItems,acc)
    case W5MANo{}: None{}

@unsafe
def w5_xmm_try_ms(ms: W5MovdSlot, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ms:
    case W5MSYes{disp,a}:
      match r2:
        case Con{+i2,+r3}: w5_x4_b(disp,a,w4c_as_fop_any(i1),i2,r3,fnItems,acc)
        case Nil{}: None{}
    case W5MSNo{}: None{}

@unsafe
def w5_xmm_fold_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_xmm_try_ma(w5_as_movaps(i0),i0,i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_xmm_try_ms(w5_as_movd_slot(i0),i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_x6(i0,i1,r2,fnItems,acc),
        w => w5_xmm_fold(Con{i1,r2},fnItems,Con{i0,acc}))))

@unsafe
def w5_xmm_fold_last(ma: W5Movaps, +i0: X187Parsed, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ma:
    case W5MAYes{a,b}:
      nt_choose(List<&2,X187Parsed>,U32.is_eq(a,b),
        u => nt_reverse(X187Parsed,acc,[]),
        u => nt_reverse(X187Parsed,Con{i0,acc},[]))
    case W5MANo{}: nt_reverse(X187Parsed,Con{i0,acc},[])

@unsafe
def w5_xmm_fold(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+r2}}: w5_xmm_fold_step(i0,i1,r2,fnItems,acc)
    case Con{+i0,Nil{}}: w5_xmm_fold_last(w5_as_movaps(i0),i0,acc)

# ---- W5-R2: General x86-64 GPR Peepholes (`w5_gpr_peep`) ----

@unsafe
def w5_is_comm64(+op: String) -> Bool:
  agy_str_eq(op,"addq") || agy_str_eq(op,"orq") || agy_str_eq(op,"andq") || agy_str_eq(op,"xorq")

@unsafe
def w5_is_comm32(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"orl") || agy_str_eq(op,"andl") || agy_str_eq(op,"xorl")

type W5LoadRbp is Data:
  W5LRNo{}
  W5LRYes{+disp: U32, +dst: U32}

@unsafe
def w5_as_load_rbp(item: X187Parsed) -> W5LoadRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5LoadRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5LRYes{d,dr},u => W5LRNo{})
    case _: W5LRNo{}

type W5StoreRbp is Data:
  W5SRNo{}
  W5SRYes{+src: U32, +disp: U32}

@unsafe
def w5_as_store_rbp(item: X187Parsed) -> W5StoreRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Mem{b,d},Nil{}}}}}:
      nt_choose(W5StoreRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5SRYes{sr,d},u => W5SRNo{})
    case _: W5SRNo{}

type W5MovqToReg is Data:
  W5MTRNo{}
  W5MTRYes{+src: X187Operand, +dst: U32}

@unsafe
def w5_as_movq_to_reg(item: X187Parsed) -> W5MovqToReg:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5MovqToReg,agy_str_eq(op,"movq"),u => W5MTRYes{src,dr},u => W5MTRNo{})
    case _: W5MTRNo{}

type W5MovqFromReg is Data:
  W5MFRNo{}
  W5MFRYes{+src: U32, +dst: X187Operand}

@unsafe
def w5_as_movq_from_reg(item: X187Parsed) -> W5MovqFromReg:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{dst,Nil{}}}}}:
      nt_choose(W5MovqFromReg,agy_str_eq(op,"movq"),u => W5MFRYes{sr,dst},u => W5MFRNo{})
    case _: W5MFRNo{}

type W5Setcc is Data:
  W5SetNo{}
  W5SetYes{+op: String, +reg: U32}

@unsafe
def w5_as_setcc(item: X187Parsed) -> W5Setcc:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{r,8,False{}},Nil{}}}}:
      nt_choose(W5Setcc,w4_peep_is_setcc(op),u => W5SetYes{op,r},u => W5SetNo{})
    case _: W5SetNo{}

type W5Movzbl is Data:
  W5MZNo{}
  W5MZYes{+sr: U32, +dr: U32}

@unsafe
def w5_as_movzbl(item: X187Parsed) -> W5Movzbl:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,8,False{}},Con{X187Reg{dr,32,False{}},Nil{}}}}}:
      nt_choose(W5Movzbl,agy_str_eq(op,"movzbl"),u => W5MZYes{sr,dr},u => W5MZNo{})
    case _: W5MZNo{}

@unsafe
def w5_not_scratch(+r: U32) -> Bool:
  Bool.not(U32.is_eq(r,0)) && Bool.not(U32.is_eq(r,10)) && Bool.not(U32.is_eq(r,11))

@unsafe
def w5_src_ok_cmov(+rN: U32, src: X187Operand) -> Bool:
  match src:
    case X187Reg{r,64,False{}}: w5_not_scratch(r) && Bool.not(U32.is_eq(r,rN))
    case X187Mem{b,_}: U32.is_eq(b,5)
    case _: False{}

@unsafe
def w5_dst_ok_cmov(+rN: U32, dst: X187Operand) -> Bool:
  match dst:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Reg{r,64,False{}}: Bool.not(U32.is_eq(r,rN)) && w5_not_scratch(r)
    case _: False{}

law w5_gpr_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# G1: movq d1(%rbp), %rB; <comm64> %rA, %rB; movq d2(%rbp), %rA; <comm64> %rB, %rA (%rB dead)
@unsafe
def w5_g1_d(+d1: U32, +d2: U32, +op1: String, +rA: U32, +rB: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,op1) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
        w4b_reg_dead(rB,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op1,[X187Mem{5,d2},x188_reg(rA,64)]}},
          Con{PInst{X187Instruction{op1,[X187Mem{5,d1},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g1_c(+d1: U32, +op1: String, +rA: U32, +rB: U32, ld2: W5LoadRbp, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld2:
    case W5LRYes{d2,dr2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(dr2,rA),
        u => w5_g1_d(d1,d2,op1,rA,rB,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case W5LRNo{}: None{}

@unsafe
def w5_g1_b(+d1: U32, +rB: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{+op1,+rA,64,dr1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op1) && U32.is_eq(dr1,rB) && Bool.not(U32.is_eq(rA,rB)) &&
        Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)),
        u => w5_g1_c(d1,op1,rA,rB,w5_as_load_rbp(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G2: movq %rC, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst
@unsafe
def w5_g2_f(+rC: U32, +srcY: X187Operand, +rN: U32, +cmop: String, st5: W5MovqFromReg,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st5:
    case W5MFRYes{s5,+dst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s5,11) && w5_dst_ok_cmov(rN,dst) &&
        w4b_reg_dead(0,r6,fnItems,96) && w4b_reg_dead(10,r6,fnItems,96) &&
        w4b_reg_dead(11,r6,fnItems,96) && w4b_reg_dead(rN,r6,fnItems,96),
        u => Some{w5_gpr_peep(r6,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},
          Con{PInst{X187Instruction{cmop,[srcY,x188_reg(rN,64)]}},
          Con{PInst{X187Instruction{"testl",[x188_reg(rC,32),x188_reg(rC,32)]}},acc}}})},
        u => None{})
    case W5MFRNo{}: None{}

@unsafe
def w5_g2_e(+rC: U32, +srcY: X187Operand, +rN: U32, rr4: W4BRR, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr4:
    case W4BRR{+cmop,10,64,11,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(cmop,"cmovneq") || agy_str_eq(cmop,"cmoveq"),
        u => w5_g2_f(rC,srcY,rN,cmop,w5_as_movq_from_reg(i5),r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_d(+rC: U32, +srcY: X187Operand, +rN: U32, rr3: W4BRR, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{top,0,32,0,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(top,"testl"),
        u => w5_g2_e(rC,srcY,rN,w4b_as_rr(i4),i5,r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_c(+rC: U32, +srcY: X187Operand, rr2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,+rN,64,11,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && w5_not_scratch(rN) && Bool.not(U32.is_eq(rN,rC)) &&
        w5_src_ok_cmov(rN,srcY),
        u => w5_g2_d(rC,srcY,rN,w4b_as_rr(i3),i4,i5,r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_b(+rC: U32, m1: W5MovqToReg, +i2: X187Parsed, +i3: X187Parsed, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MTRYes{srcY,10}: w5_g2_c(rC,srcY,w4b_as_rr(i2),i3,i4,i5,r6,fnItems,acc)
    case _: None{}

# G3: movq %rA, %rT; movq %rB, %rA; movq %rT, %rB; <comm> %rA, %rB (%rT,%rA dead) -> <comm> %rA, %rB
@unsafe
def w5_g3_d(+rA: U32, +rB: U32, +rT: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{+op3,s3,+w3,d3,dw3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(w3,dw3) && U32.is_eq(s3,rA) && U32.is_eq(d3,rB) &&
        ((U32.is_eq(w3,32) && w5_is_comm32(op3)) || (U32.is_eq(w3,64) && w5_is_comm64(op3))) &&
        w4b_reg_dead(rT,r4,fnItems,96) && w4b_reg_dead(rA,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op3,[x188_reg(rA,w3),x188_reg(rB,w3)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g3_c(+rA: U32, +rB: U32, +rT: U32, rr2: W4BRR, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,64,d2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,rT) && U32.is_eq(d2,rB),
        u => w5_g3_d(rA,rB,rT,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case _: None{}

# G4: movq %rA, %rT; movq %rD, %rA; subl %rT32, %rA32; movq %rA, %rD (%rT,%rA dead) -> subl %rA32, %rD32
@unsafe
def w5_g4_d(+rA: U32, +rD: U32, +rT: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,"movq") && U32.is_eq(s3,rA) && U32.is_eq(d3,rD) &&
        w4b_reg_dead(rT,r4,fnItems,96) && w4b_reg_dead(rA,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{"subl",[x188_reg(rA,32),x188_reg(rD,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g4_c(+rA: U32, +rD: U32, +rT: U32, rr2: W4BRR, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,d2,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"subl") && U32.is_eq(s2,rT) && U32.is_eq(d2,rA),
        u => w5_g4_d(rA,rD,rT,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g34_b(+rA: U32, +rT: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,+rB,64,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_eq(d1,rA) && Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rT)),
        u => w4c_or_peep_opt(w5_g3_c(rA,rB,rT,w4b_as_rr(i2),i3,r4,fnItems,acc),
          v => w5_g4_c(rA,rB,rT,w4b_as_rr(i2),i3,r4,fnItems,acc)),
        u => None{})
    case _: None{}

# G5: movq %rA, %rB; cmpq $C, %rB; setcc %rB8; movzbl %rB8, %rB32 -> cmpq $C, %rA; setcc %rB8; movzbl %rB8, %rB32
@unsafe
def w5_g5_d(+rA: U32, +rB: U32, +lo: U32, +hi: U32, +setop: String, mz3: W5Movzbl,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mz3:
    case W5MZYes{sr,dr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rB) && U32.is_eq(dr,rB),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{"movzbl",[x188_reg(rB,8),x188_reg(rB,32)]}},
          Con{PInst{X187Instruction{setop,[x188_reg(rB,8)]}},
          Con{PInst{X187Instruction{"cmpq",[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}}})},
        u => None{})
    case W5MZNo{}: None{}

@unsafe
def w5_g5_c(+rA: U32, +rB: U32, +lo: U32, +hi: U32, sc2: W5Setcc, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match sc2:
    case W5SetYes{setop,sr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rB),
        u => w5_g5_d(rA,rB,lo,hi,setop,w5_as_movzbl(i3),r4,fnItems,acc),
        u => None{})
    case W5SetNo{}: None{}

@unsafe
def w5_g5_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"cmpq") && U32.is_eq(d1,rB),
        u => w5_g5_c(rA,rB,lo,hi,w5_as_setcc(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G6a: movq %rA, %rB; imull $3, %rB32; addl %rB32, %rD32 (%rB dead) -> leaq (%rA,%rA,2), %rB; addl %rB32, %rD32
# G6b: movq %rA, %rB; addl $c, %rB32; subl %rB32, %rD32 (%rB dead) -> leaq c(%rA), %rB; subl %rB32, %rD32
# G7:  movq %rA, %rB; andq $M, %rB; movq %rB, disp(%rbp) (%rA,%rB dead) -> andq $M, %rA; movq %rA, disp(%rbp)
@unsafe
def w5_g6a_c(+rA: U32, +rB: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"addl") && U32.is_eq(s2,rB) && Bool.not(U32.is_eq(rB,rD)) &&
        Bool.not(U32.is_eq(rA,4)) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"addl",[x188_reg(rB,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"leaq",[X187Indexed{rA,rA,2,0},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g6b_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{+op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        (agy_str_eq(op2,"subl") || agy_str_eq(op2,"addl")) && U32.is_eq(s2,rB) &&
        Bool.not(U32.is_eq(rB,rD)) && U32.is_le(c,2147483647) &&
        w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{op2,[x188_reg(rB,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"leaq",[X187Mem{rA,c},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g7_c(+rA: U32, +rB: U32, +lo: U32, +hi: U32, st2: W5StoreRbp, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W5SRYes{sr,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sr,rB) && Bool.not(U32.is_eq(rA,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{"andq",[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case W5SRNo{}: None{}

@unsafe
def w5_g67_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{+op1,+lo,+hi,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && U32.is_eq(hi,0),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"imull") && U32.is_eq(lo,3),
          v => w5_g6a_c(rA,rB,w4b_as_rr(i2),r3,fnItems,acc),
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl"),
            w => w5_g6b_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
            w => None{})),
        u => None{})
    case W4BImmReg{+op1,+lo,+hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && agy_str_eq(op1,"andq"),
        u => w5_g7_c(rA,rB,lo,hi,w5_as_store_rbp(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

# G6c: movl %rA32, %rB32; addl $c, %rB32; imull %rB32, %rD32 (%rA,%rB dead) -> addl $c, %rA32; imull %rA32, %rD32
@unsafe
def w5_g6c_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"imull") && U32.is_eq(s2,rB) && Bool.not(U32.is_eq(rA,rD)) && Bool.not(U32.is_eq(rB,rD)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"imull",[x188_reg(rA,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"addl",[X187Imm{c,0},x188_reg(rA,32)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g6c_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,0,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl") && U32.is_eq(d1,rB),
        u => w5_g6c_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

# G8: xorl $1, %r32; xorq $1, %r64 (flags dead) -> movl %r32, %r32
@unsafe
def w5_g8_b(+r: U32, im1: W4BImmReg, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,1,0,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"xorq") && U32.is_eq(d1,r) && w4_peep_flags_dead_list(r2,16),
        u => Some{w5_gpr_peep(r2,fnItems,Con{PInst{X187Instruction{"movl",[x188_reg(r,32),x188_reg(r,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr64_g2(+rA: U32, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed, r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r4:
    case Con{+i4,Con{+i5,+r6}}: w5_g2_b(rA,w5_as_movq_to_reg(i1),i2,i3,i4,i5,r6,fnItems,acc)
    case _: None{}

@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
            x => w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc))))
    case Con{+i2,+r3}: w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc)
    case Nil{}: None{}

# G9: movl %rA32, %rB32; movl %rB32, %rC32 -> movl %rA32, %rB32; movl %rA32, %rC32
@unsafe
def w5_g9_b(+rA: U32, +rB: U32, rr1: W4BRR, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,s1,32,+rC,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movl") && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rC,rA)) && Bool.not(U32.is_eq(rC,rB)),
        u => Some{w5_gpr_peep(r2,fnItems,
          Con{PInst{X187Instruction{"movl",[x188_reg(rA,32),x188_reg(rC,32)]}},
          Con{PInst{X187Instruction{"movl",[x188_reg(rA,32),x188_reg(rB,32)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr32_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g6c_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w5_g9_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc))
    case Nil{}: w5_g9_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)

@unsafe
def w5_gpr_try_rr(rr0: W4BRR, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr0:
    case W4BRR{+op0,+rA,64,+rB,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"movq") && Bool.not(U32.is_eq(rA,rB)),
        u => w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),
        u => None{})
    case W4BRR{+op0,+rA,32,+rB,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"movl") && Bool.not(U32.is_eq(rA,rB)),
        u => w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_try_imm(im0: W4BImmReg, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im0:
    case W4BImmReg{op0,1,0,r,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"xorl"),
        u => w5_g8_b(r,w4b_as_imm_reg(i1),r2,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_try_ld(ld0: W5LoadRbp, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld0:
    case W5LRYes{d1,rB}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5_g1_b(d1,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_gpr_try_ld(w5_as_load_rbp(i0),i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_gpr_try_rr(w4b_as_rr(i0),i0,i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_gpr_try_imm(w4b_as_imm_reg(i0),i1,r2,fnItems,acc),
        w => w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc}))))

@unsafe
def w5_gpr_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+r2}}: w5_gpr_step(i0,i1,r2,fnItems,acc)
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])
"""

OLD_POST_SELECT = """@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  w4c_dead_slot_elim(p8)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])
  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))
  +f5 = w4_peep_flat([peep5],[])
  +xmm = w4c_xmm_opt(f5)
  w4b_wrap_items(xmm,[])"""

NEW_POST_SELECT = W5_PASSES + """
@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  +p9 = w4c_dead_slot_elim(p8)
  +p10 = w5_xmm_fold(p9,p9,[])
  w5_xmm_fold(p10,p10,[])

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])
  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))
  +f5 = w4_peep_flat([peep5],[])
  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +xmm = w4c_xmm_opt(g3)
  w4b_wrap_items(xmm,[])"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    if OLD_J_COUNTED in src:
        src = replace_once(src, OLD_J_COUNTED, NEW_J_COUNTED, "Patch 1: x190_j_counted high-param loop dispatch")
    else:
        old_r1 = OLD_J_COUNTED.replace("U32.is_gt(nCands,64)", "U32.is_gt(nCands,256)")
        new_r1 = NEW_J_COUNTED.replace("U32.is_gt(nCands,64)", "U32.is_gt(nCands,256)")
        src = replace_once(src, old_r1, new_r1, "Patch 1: x190_j_counted (composed on W5-R1 256)")
    src = replace_once(src, OLD_SIMPLE_ALU, NEW_SIMPLE_ALU, "Patch 1b: w4b_is_simple_alu setcc support")
    src = replace_once(src, OLD_POST_SELECT, NEW_POST_SELECT, "Patch 2+3: w5_xmm_fold + w5_gpr_peep")

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(src)
    print(f"Wrote {args.dst} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

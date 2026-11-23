#!/usr/bin/env python3
"""Build W14-A pure-Bend compiler from read-only wave11_unified/compiler.bend
(+ W12-G + W13-E baseline patches), emit unified diff patch, run --check-only,
and compile to /tmp/agy_w14a/api_w14a.mjs on CPU 7.
"""
from __future__ import annotations

import difflib
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
sys.path.insert(0, str(ROOT / "research/agy/w13_campaign/w13e_bst_hist_1x"))
import build_w13e

ORIG = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
OUT_DIR = ROOT / "research/agy/w14_campaign/w14a_edit_expr_1x"
PATCH_OUT = OUT_DIR / "w14a_edit_expr_1x.patch"
TMP = Path("/tmp/agy_w14a")
COMP_OUT = TMP / "compiler_w14a.bend"
API_OUT = TMP / "api_w14a.mjs"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
CPU = 7


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return text.replace(old, new, 1)


W14A_CODE = r"""
# ==== W14-A: General Pure-Bend x86-64 Loop & Codegen Passes ====

@unsafe
def w14a_has_rt_op(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{name},Nil{}}}},rest}:
      (agy_str_eq(op,"call") && agy_str_eq(name,"p111_rt_op")) || w14a_has_rt_op(rest)
    case Con{_,rest}: w14a_has_rt_op(rest)

# ---- Pass 2: Contiguous 4-slot descending cmoveq chain -> negq + indexed movq ----

type W14ALblSkip is Data:
  W14ALblSkip{+rest: List<&2,X187Parsed>, +ok: Bool}

@unsafe
def w14a_skip_dead_lbls(+fuel: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> W14ALblSkip:
  match fuel items:
    case 0 _: W14ALblSkip{items,True{}}
    case _ Con{PLabel{+lbl},+rest}:
      nt_choose(W14ALblSkip,w4b_has_any_branch_to(lbl,fnItems),
        u => W14ALblSkip{Con{PLabel{lbl},rest},False{}},
        u => w14a_skip_dead_lbls(U32.sub(fuel,1),rest,fnItems))
    case _ other: W14ALblSkip{other,True{}}

@unsafe
def w14a_is_andq_3(it: X187Parsed) -> U32:
  match it:
    case PInst{X187Instruction{op,Con{X187Imm{3,0},Con{X187Reg{r,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"andq"),u => r,u => 99)
    case _: 99

@unsafe
def w14a_is_cmpq_imm(it: X187Parsed, +imm: U32, +r: U32) -> Bool:
  match it:
    case PInst{X187Instruction{op,Con{X187Imm{v,0},Con{X187Reg{rr,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"cmpq") && U32.is_eq(v,imm) && U32.is_eq(rr,r)
    case _: False{}

@unsafe
def w14a_is_testq_rr(it: X187Parsed, +r: U32) -> Bool:
  match it:
    case PInst{X187Instruction{op,Con{X187Reg{r1,64,False{}},Con{X187Reg{r2,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"testq") && U32.is_eq(r1,r) && U32.is_eq(r2,r)
    case _: False{}

@unsafe
def w14a_is_rbp_load(it: X187Parsed, +wantOp: String, +rDst: U32) -> U32:
  match it:
    case PInst{X187Instruction{op,Con{X187Mem{5,disp},Con{X187Reg{rr,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,wantOp) && U32.is_eq(rr,rDst) && U32.is_ge(disp,2147483648),
        u => disp,u => 0)
    case _: 0

@unsafe
def w14a_not_flag_reader(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{PLabel{_},rest}: w14a_not_flag_reader(rest)
    case Con{PInst{X187Instruction{op,_}},_}:
      Bool.not(String.starts_with(op,"j") || String.starts_with(op,"set") || String.starts_with(op,"cmov"))
    case _: False{}

@unsafe
def w14a_cmov_match3(+rIdx: U32, +rDst: U32, +d3: U32, +d2: U32, +d1: U32,
    s2: W14ALblSkip, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s2:
    case W14ALblSkip{Con{i6,Con{i7,+tail}},True{}}:
      +d0 = w14a_is_rbp_load(i7,"cmoveq",rDst)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_testq_rr(i6,rIdx) && Bool.not(U32.is_eq(d0,0)) &&
        U32.is_eq(d1,U32.sub(d0,8)) && U32.is_eq(d2,U32.sub(d0,16)) && U32.is_eq(d3,U32.sub(d0,24)) &&
        w4b_reg_dead(rIdx,tail,fnItems,64) && w14a_not_flag_reader(tail),
        u => Some{Con{PInst{X187Instruction{"andq",[X187Imm{3,0},x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"negq",[x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"movq",[X187Indexed{5,rIdx,8,d0},x188_reg(rDst,64)]}},tail}}}},
        u => None{})
    case _: None{}

@unsafe
def w14a_cmov_match2(+rIdx: U32, +rDst: U32, +d3: U32, +d2: U32,
    s1: W14ALblSkip, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s1:
    case W14ALblSkip{Con{i4,Con{i5,+r6}},True{}}:
      +d1 = w14a_is_rbp_load(i5,"cmoveq",rDst)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_cmpq_imm(i4,1,rIdx) && Bool.not(U32.is_eq(d1,0)),
        u => w14a_cmov_match3(rIdx,rDst,d3,d2,d1,w14a_skip_dead_lbls(2,r6,fnItems),fnItems),
        u => None{})
    case _: None{}

@unsafe
def w14a_cmov_match1(+rIdx: U32, i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1 r2:
    case PInst{X187Instruction{op1,Con{X187Mem{5,+d3},Con{X187Reg{+rDst,64,False{}},Nil{}}}}} Con{i2,Con{i3,+r4}}:
      +d2 = w14a_is_rbp_load(i3,"cmoveq",rDst)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_ge(d3,2147483648) &&
        Bool.not(U32.is_eq(rIdx,rDst)) && Bool.not(U32.is_eq(rIdx,4)) && Bool.not(U32.is_eq(rIdx,5)) &&
        Bool.not(U32.is_eq(rDst,4)) && Bool.not(U32.is_eq(rDst,5)) &&
        w14a_is_cmpq_imm(i2,2,rIdx) && Bool.not(U32.is_eq(d2,0)),
        u => w14a_cmov_match2(rIdx,rDst,d3,d2,w14a_skip_dead_lbls(2,r4,fnItems),fnItems),
        u => None{})
    case _ _: None{}

law w14a_cmov_table_go:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14a_cmov_table_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{rew}: w14a_cmov_table_go(rew,fnItems,acc)
    case None{}: w14a_cmov_table_go(rest,fnItems,Con{i0,acc})

@unsafe
def w14a_cmov_table_go(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+r2}}:
      +rIdx = w14a_is_andq_3(i0)
      nt_choose(List<&2,X187Parsed>,U32.is_lt(rIdx,16),
        u => w14a_cmov_table_apply(w14a_cmov_match1(rIdx,i1,r2,fnItems),i0,Con{i1,r2},fnItems,acc),
        u => w14a_cmov_table_go(Con{i1,r2},fnItems,Con{i0,acc}))
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])

# ---- Pass 3: General Straight-Line Call-Free Loop Register & Copy Optimizer ----

type W14ASLSplit is Data:
  W14ASLNo{}
  W14ASLHit{+pre: List<&2,X187Parsed>, +lTop: String, +body: List<&2,X187Parsed>,
            +backJcc: X187Parsed, +post: List<&2,X187Parsed>}

@unsafe
def w14a_sl_ok_inst(it: X187Parsed) -> Bool:
  match it:
    case PInst{X187Instruction{+op,+args}}:
      Bool.not(agy_str_eq(op,"call") || agy_str_eq(op,"ret") || agy_str_eq(op,"pushq") ||
               agy_str_eq(op,"popq") || agy_str_eq(op,"rep_stosq") || String.starts_with(op,"j") ||
               (agy_str_eq(op,"leaq") && w4b_args_read_reg(5,args)))
    case _: False{}

@unsafe
def w14a_sl_take_body(+fuel: U32, +lTop: String, items: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>,
    +pre: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> W14ASLSplit:
  match fuel items:
    case 0 _: W14ASLNo{}
    case _ Con{PInst{X187Instruction{+op,Con{X187Target{+t},Nil{}}}},+post}:
      nt_choose(W14ASLSplit,(agy_str_eq(op,"jne") || agy_str_eq(op,"jnz")) && agy_str_eq(t,lTop),
        u => W14ASLHit{pre,lTop,nt_reverse(X187Parsed,acc,[]),
               PInst{X187Instruction{op,[X187Target{t}]}},post},
        u => W14ASLNo{})
    case _ Con{PLabel{+lbl},+rest}:
      nt_choose(W14ASLSplit,w4b_has_any_branch_to(lbl,fnItems),
        u => W14ASLNo{},
        u => w14a_sl_take_body(U32.sub(fuel,1),lTop,rest,acc,pre,fnItems))
    case _ Con{+h,+rest}:
      nt_choose(W14ASLSplit,w14a_sl_ok_inst(h),
        u => w14a_sl_take_body(U32.sub(fuel,1),lTop,rest,Con{h,acc},pre,fnItems),
        u => W14ASLNo{})
    case _ Nil{}: W14ASLNo{}

law w14a_sl_find_loop:
  for items: List<&2,X187Parsed>
  for +preAcc: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  W14ASLSplit

@unsafe
def w14a_sl_find_step(sp: W14ASLSplit, +lTop: String, +rest: List<&2,X187Parsed>,
    +preAcc: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> W14ASLSplit:
  match sp:
    case W14ASLHit{p,l,b,j,po}: W14ASLHit{p,l,b,j,po}
    case W14ASLNo{}: w14a_sl_find_loop(rest,Con{PLabel{lTop},preAcc},fnItems)

@unsafe
def w14a_sl_find_loop(items,preAcc,fnItems):
  match items:
    case Nil{}: W14ASLNo{}
    case Con{PLabel{+lTop},+rest}:
      w14a_sl_find_step(w14a_sl_take_body(220,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[]),fnItems),lTop,rest,preAcc,fnItems)
    case Con{h,rest}: w14a_sl_find_loop(rest,Con{h,preAcc},fnItems)

# Straight-line local liveness: is register r dead starting at tail (inside body ++ [backJcc] ++ post)?
@unsafe
def w14a_sl_dead(+r: U32, tail: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Bool:
  w4b_reg_dead(r,nt_append(X187Parsed,tail,afterBody),fnItems,128)

@unsafe
def w14a_is_alu2_op(+op: String) -> Bool:
  agy_str_eq(op,"orq") || agy_str_eq(op,"orl") || agy_str_eq(op,"andq") || agy_str_eq(op,"andl") ||
  agy_str_eq(op,"xorq") || agy_str_eq(op,"xorl") || agy_str_eq(op,"addq") || agy_str_eq(op,"addl") ||
  agy_str_eq(op,"subq") || agy_str_eq(op,"subl")

@unsafe
def w14a_is_imm_alu_op(+op: String) -> Bool:
  agy_str_eq(op,"shrq") || agy_str_eq(op,"shlq") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shll") ||
  agy_str_eq(op,"andq") || agy_str_eq(op,"andl") || agy_str_eq(op,"addl") || agy_str_eq(op,"subl") ||
  agy_str_eq(op,"addq") || agy_str_eq(op,"subq")

@unsafe
def w14a_op_width(+op: String) -> U32:
  nt_choose(U32,agy_str_eq(op,"orl") || agy_str_eq(op,"andl") || agy_str_eq(op,"xorl") ||
                agy_str_eq(op,"addl") || agy_str_eq(op,"subl") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shll"),
    u => 32,u => 64)

law w14a_sl_copy_go:
  for body: List<&2,X187Parsed>
  for +afterBody: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14a_sl_copy_3(+rA: U32, +rB: U32, i1: X187Parsed, i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1 i2:
    # movq rA, rB; movq rX, rY; alu rB, rY (rB dead) -> movq rX, rY; alu rA, rY
    case PInst{X187Instruction{op1,Con{X187Reg{+rX,64,False{}},Con{X187Reg{+rY,64,False{}},Nil{}}}}}
         PInst{X187Instruction{+op2,Con{X187Reg{+s2,+w2,False{}},Con{X187Reg{+d2,+dw2,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && w14a_is_alu2_op(op2) && U32.is_eq(s2,rB) && U32.is_eq(d2,rY) &&
        Bool.not(U32.is_eq(rB,rX)) && Bool.not(U32.is_eq(rB,rY)) && Bool.not(U32.is_eq(rA,rY)) &&
        w14a_sl_dead(rB,r3,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movq",[x188_reg(rX,64),x188_reg(rY,64)]}},
               Con{PInst{X187Instruction{op2,[x188_reg(rA,w2),x188_reg(rY,dw2)]}},r3}},
               afterBody,fnItems,acc)},
        u => None{})
    # movq rA, rB; op_imm c, rB; movq rB, rC (rB dead) -> movq rA, rC; op_imm c, rC
    case PInst{X187Instruction{+op1,Con{X187Imm{+lo,+hi},Con{X187Reg{+d1,+w1,False{}},Nil{}}}}}
         PInst{X187Instruction{op2,Con{X187Reg{+s2,64,False{}},Con{X187Reg{+rC,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_imm_alu_op(op1) && U32.is_eq(d1,rB) && agy_str_eq(op2,"movq") && U32.is_eq(s2,rB) &&
        Bool.not(U32.is_eq(rB,rC)) && w14a_sl_dead(rB,r3,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},
               Con{PInst{X187Instruction{op1,[X187Imm{lo,hi},x188_reg(rC,w1)]}},r3}},
               afterBody,fnItems,acc)},
        u => None{})
    # movq rA, rB; alu rX, rB; movq rB, rC (rB dead, rC != rX) -> movq rA, rC; alu rX, rC
    case PInst{X187Instruction{+op1,Con{X187Reg{+rX,+w1,False{}},Con{X187Reg{+d1,+dw1,False{}},Nil{}}}}}
         PInst{X187Instruction{op2,Con{X187Reg{+s2,64,False{}},Con{X187Reg{+rC,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_alu2_op(op1) && U32.is_eq(d1,rB) && agy_str_eq(op2,"movq") && U32.is_eq(s2,rB) &&
        Bool.not(U32.is_eq(rB,rC)) && Bool.not(U32.is_eq(rB,rX)) && Bool.not(U32.is_eq(rC,rX)) &&
        w14a_sl_dead(rB,r3,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},
               Con{PInst{X187Instruction{op1,[x188_reg(rX,w1),x188_reg(rC,dw1)]}},r3}},
               afterBody,fnItems,acc)},
        u => None{})
    # movq rA, rB; notl rB32; movq rB, rC (rB dead) -> movq rA, rC; notl rC32
    case PInst{X187Instruction{op1,Con{X187Reg{+d1,32,False{}},Nil{}}}}
         PInst{X187Instruction{op2,Con{X187Reg{+s2,64,False{}},Con{X187Reg{+rC,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"notl") && U32.is_eq(d1,rB) && agy_str_eq(op2,"movq") && U32.is_eq(s2,rB) &&
        Bool.not(U32.is_eq(rB,rC)) && w14a_sl_dead(rB,r3,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},
               Con{PInst{X187Instruction{"notl",[x188_reg(rC,32)]}},r3}},
               afterBody,fnItems,acc)},
        u => None{})
    case _ _: None{}

@unsafe
def w14a_sl_copy_2(+rA: U32, +rB: U32, i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1:
    # movq rA, rB; movq rB, rC (rB dead) -> movq rA, rC
    case PInst{X187Instruction{op1,Con{X187Reg{+s1,64,False{}},Con{X187Reg{+rC,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rB,rC)) &&
        w14a_sl_dead(rB,r2,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},r2},
               afterBody,fnItems,acc)},
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,
               w14a_is_alu2_op(op1) && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rB,rC)) &&
               w14a_sl_dead(rB,r2,afterBody,fnItems),
               v => Some{w14a_sl_copy_go(
                      Con{PInst{X187Instruction{op1,[x188_reg(rA,64),x188_reg(rC,64)]}},r2},
                      afterBody,fnItems,acc)},
               v => None{}))
    # movq rA, rB; alu32 rB32, rC32 (rB dead) -> alu32 rA32, rC32
    case PInst{X187Instruction{+op1,Con{X187Reg{+s1,32,False{}},Con{X187Reg{+rC,32,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_alu2_op(op1) && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rB,rC)) &&
        w14a_sl_dead(rB,r2,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{op1,[x188_reg(rA,32),x188_reg(rC,32)]}},r2},
               afterBody,fnItems,acc)},
        u => None{})
    # movq rA, rB; movl (base, rB, sc), rDst32 (rB dead) -> movl (base, rA, sc), rDst32
    case PInst{X187Instruction{op1,Con{X187Indexed{+b,+ix,+sc,+dp},Con{X187Reg{+rDst,32,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movl") && U32.is_eq(ix,rB) && Bool.not(U32.is_eq(b,rB)) &&
        Bool.not(U32.is_eq(rDst,rB)) && Bool.not(U32.is_eq(rA,4)) &&
        w14a_sl_dead(rB,r2,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movl",[X187Indexed{b,rA,sc,dp},x188_reg(rDst,32)]}},r2},
               afterBody,fnItems,acc)},
        u => None{})
    case _: None{}

@unsafe
def w14a_sl_copy_4(+rA: U32, +rB: U32, i1: X187Parsed, i2: X187Parsed, i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1 i2 i3:
    # movq rA, rB; op1 c1, rB; op2 c2, rB; movq rB, rA (rB dead) -> op1 c1, rA; op2 c2, rA
    case PInst{X187Instruction{+op1,Con{X187Imm{+lo1,+hi1},Con{X187Reg{+d1,+w1,False{}},Nil{}}}}}
         PInst{X187Instruction{+op2,Con{X187Imm{+lo2,+hi2},Con{X187Reg{+d2,+w2,False{}},Nil{}}}}}
         PInst{X187Instruction{op3,Con{X187Reg{+s3,64,False{}},Con{X187Reg{+d3,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_imm_alu_op(op1) && w14a_is_imm_alu_op(op2) && agy_str_eq(op3,"movq") &&
        U32.is_eq(d1,rB) && U32.is_eq(d2,rB) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
        Bool.not(U32.is_eq(rA,rB)) && w14a_sl_dead(rB,r4,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{op1,[X187Imm{lo1,hi1},x188_reg(rA,w1)]}},
               Con{PInst{X187Instruction{op2,[X187Imm{lo2,hi2},x188_reg(rA,w2)]}},r4}},
               afterBody,fnItems,acc)},
        u => None{})
    case _ _ _: None{}

# Deferred writeback fold: movq rA, rT; alu rX, rT; <mid not touching rA/rT>; movq rT, rA (rT dead) -> alu rX, rA; <mid>
@unsafe
def w14a_find_wb(+fuel: U32, +rA: U32, +rT: U32, items: List<&2,X187Parsed>,
    +midAcc: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match fuel items:
    case 0 _: None{}
    case _ Nil{}: None{}
    case _ Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_movq_pair(PInst{X187Instruction{op,args}},rT,rA) && w14a_sl_dead(rT,rest,afterBody,fnItems),
        u => Some{nt_append(X187Parsed,nt_reverse(X187Parsed,midAcc,[]),rest)},
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,
               Bool.not(w4b_args_read_reg(rA,args)) && Bool.not(w4b_args_read_reg(rT,args)),
               v => w14a_find_wb(U32.sub(fuel,1),rA,rT,rest,Con{PInst{X187Instruction{op,args}},midAcc},afterBody,fnItems),
               v => None{}))
    case _ _: None{}

@unsafe
def w14a_sl_copy_wb_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +op1: String, +rX: U32, +w1: U32,
    +rA: U32, +dw1: U32, +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match hit:
    case Some{rew}:
      Some{w14a_sl_copy_go(Con{PInst{X187Instruction{op1,[x188_reg(rX,w1),x188_reg(rA,dw1)]}},rew},
             afterBody,fnItems,acc)}
    case None{}: None{}

@unsafe
def w14a_sl_copy_wb(+rA: U32, +rT: U32, i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1:
    case PInst{X187Instruction{+op1,Con{X187Reg{+rX,+w1,False{}},Con{X187Reg{+d1,+dw1,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w14a_is_alu2_op(op1) && U32.is_eq(d1,rT) && Bool.not(U32.is_eq(rA,rT)) && Bool.not(U32.is_eq(rA,rX)),
        u => w14a_sl_copy_wb_apply(w14a_find_wb(8,rA,rT,r2,[],afterBody,fnItems),op1,rX,w1,rA,dw1,afterBody,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w14a_sl_copy_idx_ld(i0: X187Parsed, i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i0 i1:
    # movl (base, idx, sc), rT32; movq rT64, rDst64 (rT dead) -> movl (base, idx, sc), rDst32
    case PInst{X187Instruction{op0,Con{X187Indexed{+b,+ix,+sc,+dp},Con{X187Reg{+rT,32,False{}},Nil{}}}}}
         PInst{X187Instruction{op1,Con{X187Reg{+s1,64,False{}},Con{X187Reg{+rDst,64,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op0,"movl") && agy_str_eq(op1,"movq") && U32.is_eq(s1,rT) &&
        Bool.not(U32.is_eq(rT,rDst)) && w14a_sl_dead(rT,r2,afterBody,fnItems),
        u => Some{w14a_sl_copy_go(
               Con{PInst{X187Instruction{"movl",[X187Indexed{b,ix,sc,dp},x188_reg(rDst,32)]}},r2},
               afterBody,fnItems,acc)},
        u => None{})
    case _ _: None{}

@unsafe
def w14a_sl_copy_or(hit: Maybe<&2,List<&2,X187Parsed>>, fallback: Unit -> List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{res}: res
    case None{}: fallback(Unit{})

@unsafe
def w14a_sl_copy_movq(+op0: String, +rA: U32, +rB: U32, rest: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{+i1,Con{+i2,Con{+i3,+r4}}}:
      +i0 : X187Parsed = PInst{X187Instruction{op0,[x188_reg(rA,64),x188_reg(rB,64)]}}
      +r2 : List<&2,X187Parsed> = Con{i2,Con{i3,r4}}
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq"),
        v => w14a_sl_copy_or(w14a_sl_copy_2(rA,rB,i1,r2,afterBody,fnItems,acc),
          w => w14a_sl_copy_or(w14a_sl_copy_3(rA,rB,i1,i2,Con{i3,r4},afterBody,fnItems,acc),
            x => w14a_sl_copy_or(w14a_sl_copy_4(rA,rB,i1,i2,i3,r4,afterBody,fnItems,acc),
              y => w14a_sl_copy_or(w14a_sl_copy_wb(rA,rB,i1,r2,afterBody,fnItems,acc),
                z => w14a_sl_copy_go(Con{i1,r2},afterBody,fnItems,Con{i0,acc}))))),
        v => w14a_sl_copy_go(Con{i1,r2},afterBody,fnItems,Con{i0,acc}))
    case Con{+i1,Con{+i2,+r3}}:
      +i0 : X187Parsed = PInst{X187Instruction{op0,[x188_reg(rA,64),x188_reg(rB,64)]}}
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq"),
        v => w14a_sl_copy_or(w14a_sl_copy_2(rA,rB,i1,Con{i2,r3},afterBody,fnItems,acc),
          w => w14a_sl_copy_or(w14a_sl_copy_3(rA,rB,i1,i2,r3,afterBody,fnItems,acc),
            x => w14a_sl_copy_go(Con{i1,Con{i2,r3}},afterBody,fnItems,Con{i0,acc}))),
        v => w14a_sl_copy_go(Con{i1,Con{i2,r3}},afterBody,fnItems,Con{i0,acc}))
    case Con{+i1,+r2}:
      +i0 : X187Parsed = PInst{X187Instruction{op0,[x188_reg(rA,64),x188_reg(rB,64)]}}
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq"),
        v => w14a_sl_copy_or(w14a_sl_copy_2(rA,rB,i1,r2,afterBody,fnItems,acc),
          w => w14a_sl_copy_go(Con{i1,r2},afterBody,fnItems,Con{i0,acc})),
        v => w14a_sl_copy_go(Con{i1,r2},afterBody,fnItems,Con{i0,acc}))
    case Nil{}:
      nt_reverse(X187Parsed,Con{PInst{X187Instruction{op0,[x188_reg(rA,64),x188_reg(rB,64)]}},acc},[])

@unsafe
def w14a_sl_copy_go(body,afterBody,fnItems,acc):
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    # Drop self-move movq r, r
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},+rest}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq") && U32.is_eq(rA,rB),
        u => w14a_sl_copy_go(rest,afterBody,fnItems,acc),
        u => w14a_sl_copy_movq(op0,rA,rB,rest,afterBody,fnItems,acc))
    case Con{+i0,Con{+i1,+r2}}:
      w14a_sl_copy_or(w14a_sl_copy_idx_ld(i0,i1,r2,afterBody,fnItems,acc),
        u => w14a_sl_copy_go(Con{i1,r2},afterBody,fnItems,Con{i0,acc}))
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])

# Straight-line loop stack-slot temp promoter
@unsafe
def w14a_op_uses_slot(+d: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{5,disp}: U32.is_eq(disp,d)
    case _: False{}

@unsafe
def w14a_args_use_slot(+d: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w14a_op_uses_slot(d,a) || w14a_args_use_slot(d,rest)

@unsafe
def w14a_items_use_slot(+d: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}: w14a_args_use_slot(d,args) || w14a_items_use_slot(d,rest)
    case Con{_,rest}: w14a_items_use_slot(d,rest)

type W14ASlotSpan is Data:
  W14ASpanBad{}
  W14ASpanOk{+firstW: U32, +firstSrc: U32, +lastR: U32, +lastDst: U32, +reads: U32}

law w14a_slot_span_go:
  for +d: U32
  for body: List<&2,X187Parsed>
  for +idx: U32
  for st: W14ASlotSpan
  W14ASlotSpan

@unsafe
def w14a_slot_span_w(+d: U32, +sr: U32, +rest: List<&2,X187Parsed>, +idx: U32, st: W14ASlotSpan) -> W14ASlotSpan:
  match st:
    case W14ASpanOk{+fw,+fs,+lr,+ld,+rc}:
      nt_choose(W14ASlotSpan,U32.is_eq(fw,9999),
        w => w14a_slot_span_go(d,rest,U32.inc(idx),W14ASpanOk{idx,sr,lr,ld,rc}),
        w => W14ASpanBad{})
    case W14ASpanBad{}: W14ASpanBad{}

@unsafe
def w14a_slot_span_r(+d: U32, +dr: U32, +rest: List<&2,X187Parsed>, +idx: U32, st: W14ASlotSpan) -> W14ASlotSpan:
  match st:
    case W14ASpanOk{+fw,+fs,+lr,+ld,+rc}:
      nt_choose(W14ASlotSpan,U32.is_eq(fw,9999),
        w => W14ASpanBad{},
        w => w14a_slot_span_go(d,rest,U32.inc(idx),W14ASpanOk{fw,fs,idx,dr,U32.inc(rc)}))
    case W14ASpanBad{}: W14ASpanBad{}

@unsafe
def w14a_slot_span_inst(+d: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +idx: U32, +st: W14ASlotSpan) -> W14ASlotSpan:
  match args:
    case Con{X187Reg{+sr,64,False{}},Con{X187Mem{5,+md},Nil{}}}:
      nt_choose(W14ASlotSpan,U32.is_eq(md,d),
        u => nt_choose(W14ASlotSpan,agy_str_eq(op,"movq"),v => w14a_slot_span_w(d,sr,rest,idx,st),v => W14ASpanBad{}),
        u => w14a_slot_span_go(d,rest,U32.inc(idx),st))
    case Con{X187Mem{5,+md},Con{X187Reg{+dr,64,False{}},Nil{}}}:
      nt_choose(W14ASlotSpan,U32.is_eq(md,d),
        u => nt_choose(W14ASlotSpan,agy_str_eq(op,"movq"),v => w14a_slot_span_r(d,dr,rest,idx,st),v => W14ASpanBad{}),
        u => w14a_slot_span_go(d,rest,U32.inc(idx),st))
    case other:
      nt_choose(W14ASlotSpan,w14a_args_use_slot(d,other),
        u => W14ASpanBad{},
        u => w14a_slot_span_go(d,rest,U32.inc(idx),st))

@unsafe
def w14a_slot_span_go(d,body,idx,st):
  match body:
    case Nil{}: st
    case Con{PInst{X187Instruction{op,args}},rest}: w14a_slot_span_inst(d,op,args,rest,idx,st)
    case Con{_,rest}: w14a_slot_span_go(d,rest,U32.inc(idx),st)

@unsafe
def w14a_reg_saved_scan(+r: U32, pre: List<&2,X187Parsed>) -> Bool:
  match pre:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Mem{5,_},Nil{}}}}},rest}:
      (agy_str_eq(op,"movq") && U32.is_eq(sr,r)) || w14a_reg_saved_scan(r,rest)
    case Con{PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Nil{}}}},rest}:
      (agy_str_eq(op,"pushq") && U32.is_eq(sr,r)) || w14a_reg_saved_scan(r,rest)
    case Con{_,rest}: w14a_reg_saved_scan(r,rest)

@unsafe
def w14a_reg_saved_in(+r: U32, pre: List<&2,X187Parsed>) -> Bool:
  nt_choose(Bool,U32.is_eq(r,0) || U32.is_eq(r,1) || U32.is_eq(r,2) || U32.is_eq(r,6) ||
                 U32.is_eq(r,7) || U32.is_eq(r,8) || U32.is_eq(r,9) || U32.is_eq(r,10) || U32.is_eq(r,11),
    u => True{},
    u => w14a_reg_saved_scan(r,pre))

@unsafe
def w14a_reg_unused_range(+r: U32, body: List<&2,X187Parsed>, +idx: U32, +lo: U32, +hi: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{PInst{X187Instruction{_,+args}},+rest}:
      nt_choose(Bool,U32.is_gt(idx,lo) && U32.is_lt(idx,hi),
        u => Bool.not(w4b_args_read_reg(r,args)) && w14a_reg_unused_range(r,rest,U32.inc(idx),lo,hi),
        u => nt_choose(Bool,U32.is_ge(idx,hi),v => True{},v => w14a_reg_unused_range(r,rest,U32.inc(idx),lo,hi)))
    case Con{_,rest}: w14a_reg_unused_range(r,rest,U32.inc(idx),lo,hi)

@unsafe
def w14a_drop_n(+n: U32, xs: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match n xs:
    case 0 _: xs
    case _ Nil{}: []
    case _ Con{_,rest}: w14a_drop_n(U32.sub(n,1),rest)

@unsafe
def w14a_pick_free_reg(cands: List<&2,U32>, +fw: U32, +lr: U32, +lastDst: U32,
    +body: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +pre: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> U32:
  match cands:
    case Nil{}: 99
    case Con{+r,+rest}:
      +afterLast = w14a_drop_n(U32.inc(lr),body)
      +ok = w14a_reg_saved_in(r,pre) &&
            w14a_reg_unused_range(r,body,0,fw,lr) &&
            (U32.is_eq(r,lastDst) || w14a_sl_dead(r,afterLast,afterBody,fnItems))
      nt_choose(U32,ok,u => r,u => w14a_pick_free_reg(rest,fw,lr,lastDst,body,afterBody,pre,fnItems))

@unsafe
def w14a_find_temp_slots(body: List<&2,X187Parsed>, +acc: List<&2,U32>) -> List<&2,U32>:
  match body:
    case Nil{}: nt_reverse(U32,acc,[])
    case Con{PInst{X187Instruction{op,Con{X187Reg{_,64,False{}},Con{X187Mem{5,+d},Nil{}}}}},+rest}:
      nt_choose(List<&2,U32>,agy_str_eq(op,"movq") && U32.is_ge(d,2147483648) && U32.is_le(d,4294967255),
        u => w14a_find_temp_slots(rest,Con{d,acc}),
        u => w14a_find_temp_slots(rest,acc))
    case Con{_,rest}: w14a_find_temp_slots(rest,acc)

law w14a_try_promote_temp:
  for slots: List<&2,U32>
  for +body: List<&2,X187Parsed>
  for +afterBody: List<&2,X187Parsed>
  for +pre: List<&2,X187Parsed>
  for +post: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w14a_args_dst_eq(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Con{_,Con{X187Reg{dr,_,False{}},Nil{}}}: U32.is_eq(dr,r)
    case Con{X187Reg{dr,_,False{}},Nil{}}: U32.is_eq(dr,r)
    case _: False{}

@unsafe
def w14a_inst_writes_reg(+r: U32, +op: String, args: List<&2,X187Operand>) -> Bool:
  Bool.not(agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"testq") || agy_str_eq(op,"testl")) &&
    w14a_args_dst_eq(r,args)

@unsafe
def w14a_reg_unwritten_range(+r: U32, body: List<&2,X187Parsed>, +idx: U32, +lo: U32, +hi: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,U32.is_gt(idx,lo) && U32.is_lt(idx,hi),
        u => Bool.not(w14a_inst_writes_reg(r,op,args)) && w14a_reg_unwritten_range(r,rest,U32.inc(idx),lo,hi),
        u => nt_choose(Bool,U32.is_ge(idx,hi),v => True{},v => w14a_reg_unwritten_range(r,rest,U32.inc(idx),lo,hi)))
    case Con{_,rest}: w14a_reg_unwritten_range(r,rest,U32.inc(idx),lo,hi)

@unsafe
def w14a_try_promote_span(sp: W14ASlotSpan, +d: U32, +rest: List<&2,U32>, +body: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +pre: List<&2,X187Parsed>, +post: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match sp:
    case W14ASpanOk{+fw,+fs,+lr,+ld,+rc}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_gt(rc,0) && U32.is_lt(fw,lr),
        v =>
          +srcKeep = U32.is_lt(fs,16) && w14a_reg_unwritten_range(fs,body,0,fw,lr)
          +rFree = nt_choose(U32,srcKeep,
                     w => fs,
                     w => w14a_pick_free_reg([ld,0,11,10,14,3,6,9,2,1,7,8,13,15],fw,lr,ld,body,afterBody,pre,fnItems))
          nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_lt(rFree,16),
            w => Some{w5b_rew_items(d,rFree,False{},body,[])},
            w => w14a_try_promote_temp(rest,body,afterBody,pre,post,fnItems)),
        v => w14a_try_promote_temp(rest,body,afterBody,pre,post,fnItems))
    case W14ASpanBad{}: w14a_try_promote_temp(rest,body,afterBody,pre,post,fnItems)

@unsafe
def w14a_try_promote_temp(slots,body,afterBody,pre,post,fnItems):
  match slots:
    case Nil{}: None{}
    case Con{+d,+rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(w14a_items_use_slot(d,pre)) && Bool.not(w14a_items_use_slot(d,post)),
        u => w14a_try_promote_span(w14a_slot_span_go(d,body,0,W14ASpanOk{9999,99,0,99,0}),d,rest,body,afterBody,pre,post,fnItems),
        u => w14a_try_promote_temp(rest,body,afterBody,pre,post,fnItems))

law w14a_sl_rounds:
  for +fuel: U32
  for +lTop: String
  for +body: List<&2,X187Parsed>
  for +afterBody: List<&2,X187Parsed>
  for +pre: List<&2,X187Parsed>
  for +post: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14a_sl_rounds_step(res: Maybe<&2,List<&2,X187Parsed>>, +fuel: U32, +lTop: String, +b2: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +pre: List<&2,X187Parsed>, +post: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{+b3}:
      +fn3 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b3,afterBody)})
      w14a_sl_rounds(U32.sub(fuel,1),lTop,b3,afterBody,pre,post,fn3)
    case None{}: b2

@unsafe
def w14a_sl_rounds(fuel,lTop,body,afterBody,pre,post,fnItems):
  match fuel:
    case 0: w14a_sl_copy_go(body,afterBody,fnItems,[])
    case _:
      +b1 = w14a_sl_copy_go(body,afterBody,fnItems,[])
      +fn1 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b1,afterBody)})
      +b2 = w14a_sl_copy_go(b1,afterBody,fn1,[])
      +fn2 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b2,afterBody)})
      w14a_sl_rounds_step(w14a_try_promote_temp(w14a_find_temp_slots(b2,[]),b2,afterBody,pre,post,fn2),
        fuel,lTop,b2,afterBody,pre,post)

# Loop-carried stack slot -> %r12 if %r12 is unused in body and never read in post (except restore -16(%rbp))
@unsafe
def w14a_post_r12_safe(post: List<&2,X187Parsed>) -> Bool:
  match post:
    case Nil{}: True{}
    case Con{PInst{X187Instruction{op,Con{X187Mem{5,4294967280},Con{X187Reg{12,64,False{}},Nil{}}}}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"movq"),u => True{},u => False{})
    case Con{PInst{X187Instruction{_,args}},rest}:
      Bool.not(w4b_args_read_reg(12,args)) && w14a_post_r12_safe(rest)
    case Con{_,rest}: w14a_post_r12_safe(rest)

law w14a_slot_only_movq:
  for +d: U32
  for body: List<&2,X187Parsed>
  for +cnt: U32
  U32

@unsafe
def w14a_slot_only_movq_inst(+d: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>, +cnt: U32) -> U32:
  match args:
    case Con{X187Reg{_,64,False{}},Con{X187Mem{5,+md},Nil{}}}:
      nt_choose(U32,U32.is_eq(md,d),
        u => nt_choose(U32,agy_str_eq(op,"movq"),v => w14a_slot_only_movq(d,rest,U32.inc(cnt)),v => 0),
        u => w14a_slot_only_movq(d,rest,cnt))
    case Con{X187Mem{5,+md},Con{X187Reg{_,64,False{}},Nil{}}}:
      nt_choose(U32,U32.is_eq(md,d),
        u => nt_choose(U32,agy_str_eq(op,"movq"),v => w14a_slot_only_movq(d,rest,U32.inc(cnt)),v => 0),
        u => w14a_slot_only_movq(d,rest,cnt))
    case other:
      nt_choose(U32,w14a_args_use_slot(d,other),u => 0,u => w14a_slot_only_movq(d,rest,cnt))

@unsafe
def w14a_slot_only_movq(d,body,cnt):
  match body:
    case Nil{}: cnt
    case Con{PInst{X187Instruction{op,args}},rest}: w14a_slot_only_movq_inst(d,op,args,rest,cnt)
    case Con{_,rest}: w14a_slot_only_movq(d,rest,cnt)

@unsafe
def w14a_find_carried_slot(scan: List<&2,X187Parsed>, +body: List<&2,X187Parsed>,
    +pre: List<&2,X187Parsed>, +post: List<&2,X187Parsed>) -> U32:
  match scan:
    case Nil{}: 0
    case Con{PInst{X187Instruction{op,Con{X187Mem{5,+d},Con{X187Reg{_,64,False{}},Nil{}}}}},+rest}:
      nt_choose(U32,agy_str_eq(op,"movq") && U32.is_ge(d,2147483648) && U32.is_le(d,4294967255) &&
                    (w14a_items_use_slot(d,pre) || w14a_items_use_slot(d,post)) &&
                    U32.is_ge(w14a_slot_only_movq(d,body,0),2),
        u => d,
        u => w14a_find_carried_slot(rest,body,pre,post))
    case Con{_,rest}: w14a_find_carried_slot(rest,body,pre,post)

@unsafe
def w14a_rew_slot_to_slot(+dFrom: U32, +dTo: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{5,d}: nt_choose(X187Operand,U32.is_eq(d,dFrom),u => X187Mem{5,dTo},u => X187Mem{5,d})
    case other: other

@unsafe
def w14a_rew_s2s_args(+dFrom: U32, +dTo: U32, args: List<&2,X187Operand>) -> List<&2,X187Operand>:
  match args:
    case Nil{}: []
    case Con{a,rest}: Con{w14a_rew_slot_to_slot(dFrom,dTo,a),w14a_rew_s2s_args(dFrom,dTo,rest)}

@unsafe
def w14a_rew_s2s_items(+dFrom: U32, +dTo: U32, items: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PInst{X187Instruction{op,args}},rest}:
      w14a_rew_s2s_items(dFrom,dTo,rest,Con{PInst{X187Instruction{op,w14a_rew_s2s_args(dFrom,dTo,args)}},acc})
    case Con{h,rest}: w14a_rew_s2s_items(dFrom,dTo,rest,Con{h,acc})

@unsafe
def w14a_span_ok(sp: W14ASlotSpan) -> Bool:
  match sp:
    case W14ASpanOk{_,_,_,_,rc}: U32.is_gt(rc,0)
    case W14ASpanBad{}: False{}

@unsafe
def w14a_dedup_stores(body: List<&2,X187Parsed>, +fullBody: List<&2,X187Parsed>,
    +pre: List<&2,X187Parsed>, +post: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+r0,64,False{}},Con{X187Mem{5,+d1},Nil{}}}}},
         Con{PInst{X187Instruction{+op1,Con{X187Reg{+r1,64,False{}},Con{X187Mem{5,+d2},Nil{}}}}},+rest}}:
      +ok = agy_str_eq(op0,"movq") && agy_str_eq(op1,"movq") && U32.is_eq(r0,r1) && Bool.not(U32.is_eq(d1,d2)) &&
            U32.is_ge(d1,2147483648) && U32.is_ge(d2,2147483648) &&
            Bool.not(w14a_items_use_slot(d1,pre)) && Bool.not(w14a_items_use_slot(d1,post)) &&
            Bool.not(w14a_items_use_slot(d2,pre)) && Bool.not(w14a_items_use_slot(d2,post)) &&
            w14a_span_ok(w14a_slot_span_go(d1,fullBody,0,W14ASpanOk{9999,99,0,99,0})) &&
            w14a_span_ok(w14a_slot_span_go(d2,fullBody,0,W14ASpanOk{9999,99,0,99,0}))
      +i0 : X187Parsed = PInst{X187Instruction{op0,[x188_reg(r0,64),X187Mem{5,d1}]}}
      +i1 : X187Parsed = PInst{X187Instruction{op1,[x188_reg(r1,64),X187Mem{5,d2}]}}
      nt_choose(List<&2,X187Parsed>,ok,
        u => nt_append(X187Parsed,nt_reverse(X187Parsed,Con{i0,acc},[]),w14a_rew_s2s_items(d2,d1,rest,[])),
        u => w14a_dedup_stores(Con{i1,rest},fullBody,pre,post,Con{i0,acc}))
    case Con{h,rest}: w14a_dedup_stores(rest,fullBody,pre,post,Con{h,acc})

@unsafe
def w14a_sl_loop_opt_go(sp: W14ASLSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14ASLNo{}: items
    case W14ASLHit{+pre,+lTop,+body,+backJcc,+post}:
      +bodyDedup = w14a_dedup_stores(body,body,pre,post,[])
      +canR12 = Bool.not(w5b_reg_used(12,bodyDedup)) && w14a_reg_saved_in(12,pre) &&
                w14a_post_r12_safe(post) && Bool.not(w4b_has_any_branch_to(lTop,pre)) &&
                Bool.not(w4b_has_any_branch_to(lTop,post))
      +dCarry = nt_choose(U32,canR12,u => w14a_find_carried_slot(bodyDedup,bodyDedup,pre,post),u => 0)
      +hasCarry = Bool.not(U32.is_eq(dCarry,0))
      +body0 = nt_choose(List<&2,X187Parsed>,hasCarry,u => w5b_rew_items(dCarry,12,False{},bodyDedup,[]),u => bodyDedup)
      +pre2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                u => nt_append(X187Parsed,pre,[PInst{X187Instruction{"movq",[X187Mem{5,dCarry},x188_reg(12,64)]}}]),
                u => pre)
      +post2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                 u => Con{PInst{X187Instruction{"movq",[x188_reg(12,64),X187Mem{5,dCarry}]}},post},
                 u => post)
      +afterBody2 : List<&2,X187Parsed> = Con{backJcc,post2}
      +fn2 = nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,body0,afterBody2)})
      +bodyOpt = w14a_sl_rounds(8,lTop,body0,afterBody2,pre2,post2,fn2)
      nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,bodyOpt,afterBody2)})

@unsafe
def w14a_sl_loop_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w14a_sl_loop_opt_go(w14a_sl_find_loop(items,[],items),items)

# ---- Pass 4: General Multi-Branch Call-Free Loop Induction & Copy Cleanup ----

type W14AMBSplit is Data:
  W14AMBNo{}
  W14AMBHit{+pre: List<&2,X187Parsed>, +lTop: String, +body: List<&2,X187Parsed>, +post: List<&2,X187Parsed>}

@unsafe
def w14a_mb_is_back(+lTop: String, it: X187Parsed) -> Bool:
  match it:
    case PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}}:
      (agy_str_eq(op,"jne") || agy_str_eq(op,"jnz")) && agy_str_eq(t,lTop)
    case _: False{}

@unsafe
def w14a_mb_has_back(+lTop: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w14a_mb_is_back(lTop,h) || w14a_mb_has_back(lTop,rest)

@unsafe
def w14a_mb_ok_inst(it: X187Parsed) -> Bool:
  match it:
    case PLabel{_}: True{}
    case PInst{X187Instruction{op,_}}:
      Bool.not(agy_str_eq(op,"call") || agy_str_eq(op,"ret") || agy_str_eq(op,"pushq") ||
               agy_str_eq(op,"popq") || agy_str_eq(op,"rep_stosq"))
    case _: False{}

@unsafe
def w14a_mb_take(+fuel: U32, +lTop: String, items: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>,
    +pre: List<&2,X187Parsed>) -> W14AMBSplit:
  match fuel items:
    case 0 _: W14AMBNo{}
    case _ Nil{}: W14AMBNo{}
    case _ Con{+h,+rest}:
      nt_choose(W14AMBSplit,w14a_mb_is_back(lTop,h) && Bool.not(w14a_mb_has_back(lTop,rest)),
        u => W14AMBHit{pre,lTop,nt_reverse(X187Parsed,Con{h,acc},[]),rest},
        u => nt_choose(W14AMBSplit,w14a_mb_ok_inst(h),
               v => w14a_mb_take(U32.sub(fuel,1),lTop,rest,Con{h,acc},pre),
               v => W14AMBNo{}))

law w14a_mb_find:
  for items: List<&2,X187Parsed>
  for +preAcc: List<&2,X187Parsed>
  W14AMBSplit

@unsafe
def w14a_mb_find_step(sp: W14AMBSplit, +lTop: String, +rest: List<&2,X187Parsed>, +preAcc: List<&2,X187Parsed>) -> W14AMBSplit:
  match sp:
    case W14AMBHit{p,l,b,po}: W14AMBHit{p,l,b,po}
    case W14AMBNo{}: w14a_mb_find(rest,Con{PLabel{lTop},preAcc})

@unsafe
def w14a_mb_find(items,preAcc):
  match items:
    case Nil{}: W14AMBNo{}
    case Con{PLabel{+lTop},+rest}:
      nt_choose(W14AMBSplit,w14a_mb_has_back(lTop,rest),
        u => w14a_mb_find_step(w14a_mb_take(128,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[])),lTop,rest,preAcc),
        u => w14a_mb_find(rest,Con{PLabel{lTop},preAcc}))
    case Con{h,rest}: w14a_mb_find(rest,Con{h,preAcc})

# 4a: Replace leaq -1(%rCnt), %rNext + backedge (movq %rNext, %rCnt; [movq]; testq %rCnt, %rCnt; jne lTop)
#     with backedge ([movq]; subq $1, %rCnt; jne lTop)
@unsafe
def w14a_is_movq_pair(it: X187Parsed, +s: U32, +d: U32) -> Bool:
  match it:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq") && U32.is_eq(sr,s) && U32.is_eq(dr,d)
    case _: False{}

@unsafe
def w14a_is_other_movq(it: X187Parsed, +rCnt: U32, +rNext: U32) -> Bool:
  match it:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq") && Bool.not(U32.is_eq(sr,rCnt)) && Bool.not(U32.is_eq(dr,rCnt)) &&
      Bool.not(U32.is_eq(dr,rNext))
    case _: False{}

@unsafe
def w14a_item_no_pair(+r1: U32, +r2: U32, it: X187Parsed) -> Bool:
  match it:
    case PInst{X187Instruction{_,args}}:
      Bool.not(w4b_args_read_reg(r1,args)) && Bool.not(w4b_args_read_reg(r2,args))
    case _: True{}

@unsafe
def w14a_mb_cnt_ok(+lTop: String, +rCnt: U32, +rNext: U32, body: List<&2,X187Parsed>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{+i0,Con{+i1,Con{+i2,Con{+i3,+rest}}}}:
      nt_choose(Bool,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_other_movq(i1,rCnt,rNext) &&
                     w14a_is_testq_rr(i2,rCnt) && w14a_mb_is_back(lTop,i3),
        u => w14a_mb_cnt_ok(lTop,rCnt,rNext,rest),
        u => nt_choose(Bool,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_testq_rr(i1,rCnt) &&
                            w14a_mb_is_back(lTop,i2),
               v => w14a_mb_cnt_ok(lTop,rCnt,rNext,Con{i3,rest}),
               v => Bool.not(w14a_mb_is_back(lTop,i0)) && w14a_item_no_pair(rCnt,rNext,i0) &&
                    w14a_mb_cnt_ok(lTop,rCnt,rNext,Con{i1,Con{i2,Con{i3,rest}}})))
    case Con{+i0,Con{+i1,Con{+i2,+rest}}}:
      nt_choose(Bool,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_testq_rr(i1,rCnt) &&
                     w14a_mb_is_back(lTop,i2),
        u => w14a_mb_cnt_ok(lTop,rCnt,rNext,rest),
        u => Bool.not(w14a_mb_is_back(lTop,i0)) && w14a_item_no_pair(rCnt,rNext,i0) &&
             w14a_mb_cnt_ok(lTop,rCnt,rNext,Con{i1,Con{i2,rest}}))
    case Con{+i0,+rest}:
      Bool.not(w14a_mb_is_back(lTop,i0)) && w14a_item_no_pair(rCnt,rNext,i0) &&
      w14a_mb_cnt_ok(lTop,rCnt,rNext,rest)

@unsafe
def w14a_mb_cnt_rew(+lTop: String, +rCnt: U32, +rNext: U32, body: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,Con{+i2,Con{+i3,+rest}}}}:
      nt_choose(List<&2,X187Parsed>,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_other_movq(i1,rCnt,rNext) &&
                                    w14a_is_testq_rr(i2,rCnt) && w14a_mb_is_back(lTop,i3),
        u => w14a_mb_cnt_rew(lTop,rCnt,rNext,rest,
               Con{i3,Con{PInst{X187Instruction{"subq",[X187Imm{1,0},x188_reg(rCnt,64)]}},Con{i1,acc}}}),
        u => nt_choose(List<&2,X187Parsed>,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_testq_rr(i1,rCnt) &&
                                           w14a_mb_is_back(lTop,i2),
               v => w14a_mb_cnt_rew(lTop,rCnt,rNext,Con{i3,rest},
                      Con{i2,Con{PInst{X187Instruction{"subq",[X187Imm{1,0},x188_reg(rCnt,64)]}},acc}}),
               v => w14a_mb_cnt_rew(lTop,rCnt,rNext,Con{i1,Con{i2,Con{i3,rest}}},Con{i0,acc})))
    case Con{+i0,Con{+i1,Con{+i2,+rest}}}:
      nt_choose(List<&2,X187Parsed>,w14a_is_movq_pair(i0,rNext,rCnt) && w14a_is_testq_rr(i1,rCnt) &&
                                    w14a_mb_is_back(lTop,i2),
        u => w14a_mb_cnt_rew(lTop,rCnt,rNext,rest,
               Con{i2,Con{PInst{X187Instruction{"subq",[X187Imm{1,0},x188_reg(rCnt,64)]}},acc}}),
        u => w14a_mb_cnt_rew(lTop,rCnt,rNext,Con{i1,Con{i2,rest}},Con{i0,acc}))
    case Con{i0,rest}: w14a_mb_cnt_rew(lTop,rCnt,rNext,rest,Con{i0,acc})

@unsafe
def w14a_mb_opt_cnt(+lTop: String, +body: List<&2,X187Parsed>, +post: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{PInst{X187Instruction{op,Con{X187Mem{+rCnt,4294967295},Con{X187Reg{+rNext,64,False{}},Nil{}}}}},+rest}:
      nt_choose(List<&2,X187Parsed>,
        agy_str_eq(op,"leaq") && Bool.not(U32.is_eq(rCnt,rNext)) &&
        Bool.not(U32.is_eq(rCnt,4)) && Bool.not(U32.is_eq(rCnt,5)) &&
        Bool.not(U32.is_eq(rNext,4)) && Bool.not(U32.is_eq(rNext,5)) &&
        w4b_reg_dead(rNext,post,fnItems,64) && w14a_mb_cnt_ok(lTop,rCnt,rNext,rest),
        u => w14a_mb_cnt_rew(lTop,rCnt,rNext,rest,[]),
        u => body)
    case _: body

# 4b: In-place U32 induction decrement:
#     movq %rInd, %rT; subl $1, %rT32; movq %rT, %rC1; movq %rT, %rC2
#     where rInd is only written by movq %rC2, %rInd (never read elsewhere), rC1/rC2 never written again and dead in post
@unsafe
def w14a_args_not_dst(+rC1: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Con{_,Con{X187Reg{dr,_,False{}},Nil{}}}: Bool.not(U32.is_eq(dr,rC1))
    case Con{X187Reg{dr,_,False{}},Nil{}}: Bool.not(U32.is_eq(dr,rC1))
    case _: True{}

@unsafe
def w14a_mb_ind_ok_h(+rInd: U32, +rC1: U32, +rC2: U32, h: X187Parsed) -> Bool:
  match h:
    case PInst{X187Instruction{_,+args}}:
      Bool.not(w4b_args_read_reg(rInd,args)) && Bool.not(w4b_args_read_reg(rC2,args)) &&
      w14a_args_not_dst(rC1,args)
    case _: True{}

@unsafe
def w14a_mb_ind_ok(+rInd: U32, +rC1: U32, +rC2: U32, body: List<&2,X187Parsed>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{+h,+rest}:
      nt_choose(Bool,w14a_is_movq_pair(h,rC2,rInd),
        u => w14a_mb_ind_ok(rInd,rC1,rC2,rest),
        u => w14a_mb_ind_ok_h(rInd,rC1,rC2,h) && w14a_mb_ind_ok(rInd,rC1,rC2,rest))

@unsafe
def w14a_sub_reg_op(+fromR: U32, +toR: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Reg{r,w,False{}}:
      nt_choose(X187Operand,U32.is_eq(r,fromR),u => X187Reg{toR,w,False{}},u => X187Reg{r,w,False{}})
    case X187Mem{b,d}:
      nt_choose(X187Operand,U32.is_eq(b,fromR),u => X187Mem{toR,d},u => X187Mem{b,d})
    case X187Indexed{b,ix,sc,dp}:
      X187Indexed{nt_choose(U32,U32.is_eq(b,fromR),u => toR,u => b),
                  nt_choose(U32,U32.is_eq(ix,fromR),u => toR,u => ix),sc,dp}
    case other: other

@unsafe
def w14a_sub_reg_args(+fromR: U32, +toR: U32, args: List<&2,X187Operand>) -> List<&2,X187Operand>:
  match args:
    case Nil{}: []
    case Con{a,rest}: Con{w14a_sub_reg_op(fromR,toR,a),w14a_sub_reg_args(fromR,toR,rest)}

@unsafe
def w14a_mb_ind_rew_h(+rC1: U32, +rInd: U32, h: X187Parsed) -> X187Parsed:
  match h:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w14a_sub_reg_args(rC1,rInd,args)}}
    case other: other

@unsafe
def w14a_mb_ind_rew(+rInd: U32, +rC1: U32, +rC2: U32, body: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w14a_is_movq_pair(h,rC2,rInd),
        u => w14a_mb_ind_rew(rInd,rC1,rC2,rest,acc),
        u => w14a_mb_ind_rew(rInd,rC1,rC2,rest,Con{w14a_mb_ind_rew_h(rC1,rInd,h),acc}))

@unsafe
def w14a_mb_opt_ind_fold(+rInd: U32, +rT: U32, rew: List<&2,X187Parsed>,
    +post: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rew:
    case Con{PInst{X187Instruction{+ma,Con{X187Reg{+sa,32,False{}},Con{X187Reg{+da,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+mb,Con{X187Reg{+sb,32,False{}},Con{X187Reg{+db,32,False{}},Nil{}}}}},+rTail}}:
      nt_choose(List<&2,X187Parsed>,
        agy_str_eq(ma,"movl") && agy_str_eq(mb,"movl") && U32.is_eq(sa,rT) && U32.is_eq(sb,rT) &&
        w4b_reg_dead(rT,nt_append(X187Parsed,rTail,post),fnItems,64),
        v => Con{PInst{X187Instruction{"subl",[X187Imm{1,0},x188_reg(rInd,32)]}},
             Con{PInst{X187Instruction{"movl",[x188_reg(rInd,32),x188_reg(da,32)]}},
             Con{PInst{X187Instruction{"movl",[x188_reg(rInd,32),x188_reg(db,32)]}},rTail}}},
        v => Con{PInst{X187Instruction{"subl",[X187Imm{1,0},x188_reg(rInd,32)]}},
             Con{PInst{X187Instruction{"movq",[x188_reg(rInd,64),x188_reg(rT,64)]}},
             Con{PInst{X187Instruction{ma,[x188_reg(sa,32),x188_reg(da,32)]}},
             Con{PInst{X187Instruction{mb,[x188_reg(sb,32),x188_reg(db,32)]}},rTail}}}})
    case other:
      Con{PInst{X187Instruction{"subl",[X187Imm{1,0},x188_reg(rInd,32)]}},
      Con{PInst{X187Instruction{"movq",[x188_reg(rInd,64),x188_reg(rT,64)]}},other}}

@unsafe
def w14a_mb_opt_ind(+body: List<&2,X187Parsed>, +post: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{PInst{X187Instruction{op0,Con{X187Reg{+rInd,64,False{}},Con{X187Reg{+rT,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op1,Con{X187Imm{1,0},Con{X187Reg{+rT1,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+rT2,64,False{}},Con{X187Reg{+rC1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{+rT3,64,False{}},Con{X187Reg{+rC2,64,False{}},Nil{}}}}},+rest}}}}:
      +ok = agy_str_eq(op0,"movq") && agy_str_eq(op1,"subl") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"movq") &&
            U32.is_eq(rT1,rT) && U32.is_eq(rT2,rT) && U32.is_eq(rT3,rT) &&
            Bool.not(U32.is_eq(rInd,rT)) && Bool.not(U32.is_eq(rInd,rC1)) && Bool.not(U32.is_eq(rInd,rC2)) &&
            Bool.not(U32.is_eq(rC1,rC2)) && Bool.not(U32.is_eq(rInd,4)) && Bool.not(U32.is_eq(rInd,5)) &&
            w4b_reg_dead(rC1,post,fnItems,64) && w4b_reg_dead(rC2,post,fnItems,64) &&
            w14a_mb_ind_ok(rInd,rC1,rC2,rest)
      nt_choose(List<&2,X187Parsed>,ok,
        u => w14a_mb_opt_ind_fold(rInd,rT,w14a_mb_ind_rew(rInd,rC1,rC2,rest,[]),post,fnItems),
        u => body)
    case _: body

# 4c: Redundant movl %rA32, %rB32; jne L; ... L: subq $1, %rB64; jne L2
#     -> jne L; ... L: cmpl $1, %rA32; jne L2 (when L has only 1 branch targeting it & rB dead on all exits)
@unsafe
def w14a_count_branches_to(+lbl: String, items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      w14a_count_branches_to(lbl,rest,nt_choose(U32,String.starts_with(op,"j") && agy_str_eq(t,lbl),u => U32.inc(acc),u => acc))
    case Con{_,rest}: w14a_count_branches_to(lbl,rest,acc)

@unsafe
def w14a_mb_dead_at(found: Maybe<&2,List<&2,X187Parsed>>, +rB: U32, +fnItems: List<&2,X187Parsed>) -> Bool:
  match found:
    case Some{t2}: w4b_reg_dead(rB,t2,fnItems,64)
    case None{}: False{}

@unsafe
def w14a_mb_check_lbl(+lbl: String, +rB: U32, items: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{l},Con{PInst{X187Instruction{+op1,Con{X187Imm{1,0},Con{X187Reg{+d1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+op2,Con{X187Target{+l2},Nil{}}}},+rTail}}}:
      nt_choose(Bool,agy_str_eq(l,lbl),
        u => agy_str_eq(op1,"subq") && U32.is_eq(d1,rB) && (agy_str_eq(op2,"jne") || agy_str_eq(op2,"jnz")) &&
             w4b_reg_dead(rB,rTail,fnItems,64) && w14a_mb_dead_at(w4b_find_label(l2,fnItems),rB,fnItems),
        u => w14a_mb_check_lbl(lbl,rB,Con{PInst{X187Instruction{op1,[X187Imm{1,0},x188_reg(d1,64)]}},
               Con{PInst{X187Instruction{op2,[X187Target{l2}]}},rTail}},fnItems))
    case Con{_,rest}: w14a_mb_check_lbl(lbl,rB,rest,fnItems)

@unsafe
def w14a_mb_rew_lbl(+lbl: String, +rA: U32, items: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PLabel{+l},Con{+i1,+rest}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(l,lbl),
        u => nt_append(X187Parsed,nt_reverse(X187Parsed,
               Con{PInst{X187Instruction{"cmpl",[X187Imm{1,0},x188_reg(rA,32)]}},Con{PLabel{l},acc}},[]),rest),
        u => w14a_mb_rew_lbl(lbl,rA,Con{i1,rest},Con{PLabel{l},acc}))
    case Con{h,rest}: w14a_mb_rew_lbl(lbl,rA,rest,Con{h,acc})

@unsafe
def w14a_mb_opt_cmp(body: List<&2,X187Parsed>, +post: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+rA,32,False{}},Con{X187Reg{+rB,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+op1,Con{X187Target{+lbl},Nil{}}}},+rest}}:
      +ok = agy_str_eq(op0,"movl") && Bool.not(U32.is_eq(rA,rB)) &&
            (agy_str_eq(op1,"jne") || agy_str_eq(op1,"jnz")) &&
            U32.is_eq(w14a_count_branches_to(lbl,fnItems,0),1) &&
            w4b_reg_dead(rB,nt_append(X187Parsed,rest,post),fnItems,64) &&
            w14a_mb_check_lbl(lbl,rB,rest,fnItems)
      nt_choose(List<&2,X187Parsed>,ok,
        u => nt_append(X187Parsed,nt_reverse(X187Parsed,Con{PInst{X187Instruction{op1,[X187Target{lbl}]}},acc},[]),
               w14a_mb_rew_lbl(lbl,rA,rest,[])),
        u => w14a_mb_opt_cmp(Con{PInst{X187Instruction{op1,[X187Target{lbl}]}},rest},post,fnItems,
               Con{PInst{X187Instruction{op0,[x188_reg(rA,32),x188_reg(rB,32)]}},acc}))
    case Con{h,rest}: w14a_mb_opt_cmp(rest,post,fnItems,Con{h,acc})

@unsafe
def w14a_mb_loop_opt_go(sp: W14AMBSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14AMBNo{}: items
    case W14AMBHit{+pre,+lTop,+body,+post}:
      +b1 = w14a_mb_opt_cnt(lTop,body,post,items)
      +fn1 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b1,post)})
      +b2 = w14a_mb_opt_ind(b1,post,fn1)
      +fn2 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b2,post)})
      +b3 = w14a_mb_opt_cmp(b2,post,fn2,[])
      nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b3,post)})

@unsafe
def w14a_mb_loop_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w14a_mb_loop_opt_go(w14a_mb_find(items,[]),items)

# ---- Pass 5: General Branchless 4-Way Bit-Or Dispatch (s & 3 -> r0..r3 |= rBit) ----

@unsafe
def w14a_is_or_arm(i0: X187Parsed, i1: X187Parsed, i2: X187Parsed, +rBit: U32, +rT: U32) -> U32:
  match i0 i1 i2:
    case PInst{X187Instruction{op0,Con{X187Reg{+rK,64,False{}},Con{X187Reg{t0,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op1,Con{X187Reg{b1,64,False{}},Con{X187Reg{t1,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op2,Con{X187Reg{t2,64,False{}},Con{X187Reg{rK2,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op0,"movq") && agy_str_eq(op1,"orq") && agy_str_eq(op2,"movq") &&
                    U32.is_eq(t0,rT) && U32.is_eq(t1,rT) && U32.is_eq(t2,rT) &&
                    U32.is_eq(b1,rBit) && U32.is_eq(rK2,rK) && Bool.not(U32.is_eq(rK,rT)) &&
                    Bool.not(U32.is_eq(rK,rBit)),
        u => rK,u => 99)
    case _ _ _: 99

@unsafe
def w14a_is_jcc_lbl(it: X187Parsed, +wantOp: String) -> String:
  match it:
    case PInst{X187Instruction{+op,Con{X187Target{t},Nil{}}}}:
      +ok = agy_str_eq(op,wantOp) || (agy_str_eq(wantOp,"jne") && agy_str_eq(op,"jnz"))
      nt_choose(String,ok,u => t,u => "")
    case _: ""

@unsafe
def w14a_or4_arm3(+rIdx: U32, +rBit: U32, +rT: U32, +r0: U32, +r1: U32, +r2: U32,
    +l3: String, +lEnd: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{lb3},Con{a0,Con{a1,Con{a2,Con{PLabel{+lbEnd},+tail}}}}}:
      +r3 = w14a_is_or_arm(a0,a1,a2,rBit,rT)
      +ok = agy_str_eq(lb3,l3) && agy_str_eq(lbEnd,lEnd) && U32.is_lt(r3,16) &&
            Bool.not(U32.is_eq(r3,rIdx)) && Bool.not(U32.is_eq(r3,10)) &&
            U32.is_eq(w14a_count_branches_to(l3,fnItems,0),1) &&
            w4b_reg_dead(rIdx,tail,fnItems,64) && w4b_reg_dead(rT,tail,fnItems,64) &&
            w4b_reg_dead(10,tail,fnItems,64) && w14a_not_flag_reader(tail)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"andq",[X187Imm{3,0},x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"xorl",[x188_reg(10,32),x188_reg(10,32)]}},
                  Con{PInst{X187Instruction{"testq",[x188_reg(rIdx,64),x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(10,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"cmoveq",[x188_reg(rBit,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"orq",[x188_reg(rT,64),x188_reg(r0,64)]}},
                  Con{PInst{X187Instruction{"cmpq",[X187Imm{1,0},x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(10,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"cmoveq",[x188_reg(rBit,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"orq",[x188_reg(rT,64),x188_reg(r1,64)]}},
                  Con{PInst{X187Instruction{"cmpq",[X187Imm{2,0},x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(10,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"cmoveq",[x188_reg(rBit,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"orq",[x188_reg(rT,64),x188_reg(r2,64)]}},
                  Con{PInst{X187Instruction{"cmpq",[X187Imm{3,0},x188_reg(rIdx,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(10,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"cmoveq",[x188_reg(rBit,64),x188_reg(rT,64)]}},
                  Con{PInst{X187Instruction{"orq",[x188_reg(rT,64),x188_reg(r3,64)]}},
                  tail}}}}}}}}}}}}}}}}}}},
        u => None{})
    case _: None{}

@unsafe
def w14a_or4_arm2(+rIdx: U32, +rBit: U32, +rT: U32, +r0: U32, +r1: U32,
    +l2: String, +lEnd: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{lb2},Con{PInst{X187Instruction{opL,Con{X187Mem{rI2,4294967295},Con{X187Reg{+rT2,64,False{}},Nil{}}}}},
         Con{iTest,Con{iJne,Con{a0,Con{a1,Con{a2,Con{iJmp,+r3}}}}}}}}:
      +l3 = w14a_is_jcc_lbl(iJne,"jne")
      +r2 = w14a_is_or_arm(a0,a1,a2,rBit,rT)
      +ok = agy_str_eq(lb2,l2) && agy_str_eq(opL,"leaq") && U32.is_eq(rI2,rIdx) &&
            w14a_is_testq_rr(iTest,rT2) && Bool.not(String.is_empty(l3)) &&
            U32.is_lt(r2,16) && Bool.not(U32.is_eq(r2,rIdx)) && Bool.not(U32.is_eq(r2,10)) &&
            agy_str_eq(w14a_is_jcc_lbl(iJmp,"jmp"),lEnd) &&
            U32.is_eq(w14a_count_branches_to(l2,fnItems,0),1)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => w14a_or4_arm3(rIdx,rBit,rT,r0,r1,r2,l3,lEnd,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w14a_or4_arm1(+rIdx: U32, +rBit: U32, +rT: U32, +r0: U32, +l1: String, +lEnd: String,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{lb1},Con{PInst{X187Instruction{opS,Con{X187Imm{1,0},Con{X187Reg{rI1,64,False{}},Nil{}}}}},
         Con{iJne,Con{a0,Con{a1,Con{a2,Con{iJmp,+r2}}}}}}}:
      +l2 = w14a_is_jcc_lbl(iJne,"jne")
      +r1 = w14a_is_or_arm(a0,a1,a2,rBit,rT)
      +ok = agy_str_eq(lb1,l1) && agy_str_eq(opS,"subq") && U32.is_eq(rI1,rIdx) &&
            Bool.not(String.is_empty(l2)) && U32.is_lt(r1,16) &&
            Bool.not(U32.is_eq(r1,rIdx)) && Bool.not(U32.is_eq(r1,10)) &&
            agy_str_eq(w14a_is_jcc_lbl(iJmp,"jmp"),lEnd) &&
            U32.is_eq(w14a_count_branches_to(l1,fnItems,0),1)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => w14a_or4_arm2(rIdx,rBit,rT,r0,r1,l2,lEnd,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w14a_or4_match(+rIdx: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iTest,Con{iJne,Con{PInst{X187Instruction{op0,Con{X187Reg{+r0,64,False{}},Con{X187Reg{+rT,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op1,Con{X187Reg{+rBit,64,False{}},Con{X187Reg{t1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{t2,64,False{}},Con{X187Reg{r0b,64,False{}},Nil{}}}}},
         Con{iJmp,+r1}}}}}}:
      +l1 = w14a_is_jcc_lbl(iJne,"jne")
      +lEnd = w14a_is_jcc_lbl(iJmp,"jmp")
      +ok = w14a_is_testq_rr(iTest,rIdx) && Bool.not(String.is_empty(l1)) && Bool.not(String.is_empty(lEnd)) &&
            agy_str_eq(op0,"movq") && agy_str_eq(op1,"orq") && agy_str_eq(op2,"movq") &&
            U32.is_eq(t1,rT) && U32.is_eq(t2,rT) && U32.is_eq(r0b,r0) &&
            Bool.not(U32.is_eq(rIdx,rBit)) && Bool.not(U32.is_eq(rIdx,rT)) && Bool.not(U32.is_eq(rIdx,r0)) &&
            Bool.not(U32.is_eq(rIdx,10)) && Bool.not(U32.is_eq(rBit,10)) && Bool.not(U32.is_eq(rT,10)) &&
            Bool.not(U32.is_eq(r0,10)) && Bool.not(U32.is_eq(r0,rT)) && Bool.not(U32.is_eq(r0,rBit)) &&
            Bool.not(U32.is_eq(rT,rBit)) && U32.is_eq(w14a_count_branches_to(lEnd,fnItems,0),3)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => w14a_or4_arm1(rIdx,rBit,rT,r0,l1,lEnd,r1,fnItems),
        u => None{})
    case _: None{}

law w14a_or4_go:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14a_or4_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{rew}: w14a_or4_go(rew,fnItems,acc)
    case None{}: w14a_or4_go(rest,fnItems,Con{i0,acc})

@unsafe
def w14a_or4_go(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+rest}:
      +rIdx = w14a_is_andq_3(i0)
      nt_choose(List<&2,X187Parsed>,U32.is_lt(rIdx,16),
        u => w14a_or4_apply(w14a_or4_match(rIdx,rest,fnItems),i0,rest,fnItems,acc),
        u => w14a_or4_go(rest,fnItems,Con{i0,acc}))

@unsafe
def w14a_loop_opt(hasLoop: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLoop:
    case False{}: items
    case True{}:
      +t0 = w14a_or4_go(items,items,[])
      +t1 = w14a_cmov_table_go(t0,t0,[])
      +t2 = w14a_sl_loop_opt(t1)
      w14a_mb_loop_opt(t2)
"""


def apply_w14a_patches(text: str) -> str:
    # Start from W13-E baseline (which includes W12-G on top of wave11_unified)
    text = build_w13e.apply_w13e_patches(text)

    # 1. Add notl & negq to w5c_is_alu_c so w4b_reg_dead sees through them,
    #    and teach w5c_rd_inst_c_f that self-xor (xorl/xorq %r, %r) kills %r without reading it
    text = replace_exact(
        text,
        """    case 116: String.eq(op,"testl") || String.eq(op,"testq")
    case _: False{}""",
        """    case 110: String.eq(op,"notl") || String.eq(op,"negq")
    case 116: String.eq(op,"testl") || String.eq(op,"testq")
    case _: False{}""",
        "w5c_is_alu_c_notl_negq",
    )
    text = replace_exact(
        text,
        """    case 115: w5c_rd_setcc_if_f(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_wo_if_f(w4b_is_write_only_op(op),r,op,args,rest,fnItems,budget,hops,seen)""",
        """    case 115: w5c_rd_setcc_if_f(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,fnItems,budget,hops,seen)
    case 120: w14a_rd_xor(r,op,args,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_wo_if_f(w4b_is_write_only_op(op),r,op,args,rest,fnItems,budget,hops,seen)""",
        "w5c_rd_inst_c_f_self_xor",
    )
    text = replace_exact(
        text,
        """@unsafe
def w5c_rd_inst_c_f(""",
        """@unsafe
def w14a_rd_xor(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+s,+w1,False{}},Con{X187Reg{+d,+w2,False{}},Nil{}}}:
      nt_choose(Bool,(String.eq(op,"xorl") || String.eq(op,"xorq")) && U32.is_eq(s,d) && U32.is_eq(w1,w2) && U32.is_ge(w1,32),
        u => w5c_rd_kill_f(U32.is_eq(d,r),r,rest,fnItems,budget,hops,seen),
        u => w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,[X187Reg{s,w1,False{}},X187Reg{d,w2,False{}}],rest,fnItems,budget,hops,seen))
    case other: w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,other,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_inst_c_f(""",
        "insert_w14a_is_self_xor",
    )

    # 2. Generalize w13e_es_f19 to support 64-bit wide (negq) and register negq in x202o_dispatch
    text = replace_exact(
        text,
        """def w13e_es_f19(ok: Bool, +operand: X187Operand, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[code],False{},extra,operand,False{},[],offset)
    case False{}: x187_e_error()""",
        """def w13e_es_f19(ok: Bool, +operand: X187Operand, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[code],U32.is_eq(width,64),extra,operand,False{},[],offset)
    case False{}: x187_e_error()""",
        "w13e_es_f19_wide",
    )
    text = replace_exact(
        text,
        """    case 19: w13e_es_f19(x187_e_rm(operand,width,False{}),operand,code,extra,offset)""",
        """    case 19: w13e_es_f19(x187_e_rm(operand,width,False{}),operand,width,code,extra,offset)""",
        "x187_e_single_f19_wide",
    )
    text = replace_exact(
        text,
        """    case 110:
      nt_choose(X187Op,agy_str_eq(tail,"otl"),u => X187Op{19,32,247,2,0},u =>
      X187OpNone{})""",
        """    case 110:
      nt_choose(X187Op,agy_str_eq(tail,"otl"),u => X187Op{19,32,247,2,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"egq"),v => X187Op{19,64,247,3,0},v =>
      X187OpNone{}))""",
        "x202o_dispatch_negq",
    )

    # 3. Insert W14A_CODE right before w7_post_select_full and wire into w7_post_select_full & x191_frame_forward
    text = replace_exact(
        text,
        """@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>, +hasXmm: Bool, +hasNegRbp: Bool,
    +hasLbl: Bool, +hasImulq: Bool, +hasCall: Bool, +hasLoop: Bool) -> X188Seq:""",
        W14A_CODE + """
@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>, +hasXmm: Bool, +hasNegRbp: Bool,
    +hasLbl: Bool, +hasImulq: Bool, +hasCall: Bool, +hasLoop: Bool) -> X188Seq:""",
        "insert_w14a_code",
    )

    text = replace_exact(
        text,
        """  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(w13e_loop_opt(hasLoop,hasXmm,xmm),[])""",
        """  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(w14a_loop_opt(hasLoop,w13e_loop_opt(hasLoop,hasXmm,xmm)),[])""",
        "wire_w14a_loop_opt",
    )

    text = replace_exact(
        text,
        """  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && w7_len_gt(flat0,96) && Bool.not(hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),
    u => x188_finish(w4_peep_list(flat0,[])),
    u => w4_post_select(x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code))))""",
        """  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && w7_len_gt(flat0,96) && Bool.not(hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),
    u => nt_choose(X188Seq,w14a_has_rt_op(flat0),
           v => x188_finish(w4_peep_list(w4_peep_flat([x191_frame_forward_when(x191_frame_forward_enabled(),code)],[]),[])),
           v => x188_finish(w4_peep_list(flat0,[]))),
    u => w4_post_select(x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code))))""",
        "wire_w14a_rt_op_nonloop",
    )

    return text


def main() -> int:
    TMP.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    src = ORIG.read_text(encoding="utf-8")
    patched = apply_w14a_patches(src)
    COMP_OUT.write_text(patched, encoding="utf-8")
    diff = "".join(
        difflib.unified_diff(
            src.splitlines(keepends=True),
            patched.splitlines(keepends=True),
            fromfile="selfhost/build/agy/wave11_unified/compiler.bend",
            tofile="selfhost/build/agy/wave11_unified/compiler.bend (w14a)",
            n=3,
        )
    )
    PATCH_OUT.write_text(diff, encoding="utf-8")
    print(f"Wrote {COMP_OUT} ({len(patched):,} B) and {PATCH_OUT} ({len(diff):,} B)", flush=True)

    skip_check = "--skip-check" in sys.argv
    if not skip_check:
        t0 = time.perf_counter()
        r = subprocess.run(
            ["timeout", "180", "taskset", "-c", str(CPU), "bash", str(LOCKED_BUN), str(COMP_OUT), "--check-only"],
            capture_output=True, text=True, cwd=ROOT,
        )
        chk_ms = round((time.perf_counter() - t0) * 1000.0, 1)
        (TMP / "check_only.err").write_text(r.stdout + "\n" + r.stderr, encoding="utf-8")
        if r.returncode != 0 and "rely on unsafe or foreign code:" not in (r.stdout + r.stderr):
            print("CHECK FAILED:", r.stdout[:2000], r.stderr[:2000], flush=True)
            return r.returncode
        print(f"  --check-only PASS in {chk_ms} ms", flush=True)

    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", str(CPU), "flock", "/tmp/agy_bun_build.lock", "timeout", "180",
         str(ROOT / "selfhost/.assets/bin/bun"), str(ROOT / "bend2/main.ts"), str(COMP_OUT), "-o", str(API_OUT)],
        capture_output=True, text=True, cwd=ROOT,
    )
    comp_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    (TMP / "compile_js.err").write_text(r.stdout + "\n" + r.stderr, encoding="utf-8")
    if r.returncode != 0:
        print("COMPILE FAILED:", r.stdout[:2000], r.stderr[:2000], flush=True)
        return r.returncode
    print(f"  compiled {API_OUT} ({API_OUT.stat().st_size:,} B) in {comp_ms} ms", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

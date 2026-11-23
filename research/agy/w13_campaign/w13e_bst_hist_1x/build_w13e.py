#!/usr/bin/env python3
"""Build W13-E pure-Bend compiler from read-only wave11_unified/compiler.bend
(+ W12-G baseline patches), emit unified diff patch, run --check-only, and
compile to /tmp/agy_w13e/api_w13e.mjs.
"""
from __future__ import annotations

import difflib
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
sys.path.insert(0, str(ROOT / "research/agy/w12_campaign/w12g_7fam_1x"))
import build_w12g

ORIG = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
OUT_DIR = ROOT / "research/agy/w13_campaign/w13e_bst_hist_1x"
PATCH_OUT = OUT_DIR / "w13e_bst_hist_1x.patch"
TMP = Path("/tmp/agy_w13e")
COMP_OUT = TMP / "compiler_w13e.bend"
API_OUT = TMP / "api_w13e.mjs"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
CPU = 7


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return text.replace(old, new, 1)


W13E_X187_HELPERS = """
@unsafe
def w13e_es_f19(ok: Bool, +operand: X187Operand, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[code],False{},extra,operand,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w13e_ep_movqx(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(102,[15,110],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w13e_ep_pmulld(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(102,[15,56,64],False{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w13e_ep_pshift(src: X187Operand, +dst: X187Operand, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,0}:
      nt_choose(X187Encoded,U32.is_le(lo,255) && x187_e_reg(dst,128,True{}),
        u => x187_e_modrm(102,[15,114],False{},ext,dst,False{},[lo],offset),u => x187_e_error())
    case _: x187_e_error()

@unsafe
def w13e_ep_pshufd0(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(102,[15,112],False{},x187_e_index(dst),src,False{},[0],offset)
    case False{}: x187_e_error()

@unsafe
def w13e_ep_movdqu_st(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(243,[15,127],False{},x187_e_index(src),dst,False{},[],offset)
    case False{}: x187_e_error()
"""


W13E_LOOP_OPT_CODE = """
# ============================================================================
# W13-E: General Loop Optimizations (rep stosq zero, count.go row-hoist &
#        copy-prop, 4-wide SSE4.1 U32 contiguous array-fill vectorization)
# ============================================================================

@unsafe
def w13e_is_testq_self(item: X187Parsed) -> U32:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{+a,64,False{}},Con{X187Reg{+b,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"testq") && U32.is_eq(a,b),u => a,u => 99)
    case _: 99

@unsafe
def w13e_is_je_lbl(item: X187Parsed) -> String:
  match item:
    case PInst{X187Instruction{op,Con{X187Target{lbl},Nil{}}}}:
      nt_choose(String,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),u => lbl,u => "")
    case _: ""

@unsafe
def w13e_is_jne_lbl(item: X187Parsed) -> String:
  match item:
    case PInst{X187Instruction{op,Con{X187Target{lbl},Nil{}}}}:
      nt_choose(String,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),u => lbl,u => "")
    case _: ""

@unsafe
def w13e_is_label(item: X187Parsed) -> String:
  match item:
    case PLabel{lbl}: lbl
    case _: ""

@unsafe
def w13e_is_movq_rr(item: X187Parsed, +wantSrc: U32) -> U32:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{+s,64,False{}},Con{X187Reg{+d,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"movq") && U32.is_eq(s,wantSrc) && Bool.not(U32.is_eq(s,d)),u => d,u => 99)
    case _: 99

@unsafe
def w13e_is_addl_1(item: X187Parsed, +wantReg: U32) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Imm{1,0},Con{X187Reg{+d,32,False{}},Nil{}}}}}:
      agy_str_eq(op,"addl") && U32.is_eq(d,wantReg)
    case _: False{}

@unsafe
def w13e_is_subq_1(item: X187Parsed, +wantReg: U32) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Imm{1,0},Con{X187Reg{+d,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"subq") && U32.is_eq(d,wantReg)
    case _: False{}

@unsafe
def w13e_is_zero_reg(item: X187Parsed) -> U32:
  match item:
    case PInst{X187Instruction{op,Con{X187Imm{0,0},Con{X187Reg{+d,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"movabsq"),u => d,u => 99)
    case PInst{X187Instruction{op,Con{X187Reg{+a,32,False{}},Con{X187Reg{+b,32,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"xorl") && U32.is_eq(a,b),u => a,u => 99)
    case _: 99

@unsafe
def w13e_is_store32_idx(item: X187Parsed, +wantVal: U32, +wantIdx: U32) -> U32:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{+v,32,False{}},Con{X187Indexed{+base,+idx,4,0},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op,"movl") && U32.is_eq(v,wantVal) && U32.is_eq(idx,wantIdx),u => base,u => 99)
    case _: 99

@unsafe
def w13e_match_zero_loop(i0: X187Parsed, i1: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  +rCnt = w13e_is_testq_self(i0)
  +lTail = w13e_is_je_lbl(i1)
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,
    U32.is_lt(rCnt,16) && Bool.not(String.is_empty(lTail)),
    u => w13e_match_zero_b(rCnt,lTail,rest,fnItems),
    u => None{})

@unsafe
def w13e_match_zero_b(+rCnt: U32, +lTail: String, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{+lTop},Con{i3,Con{i4,Con{i5,Con{i6,Con{i7,Con{i8,Con{i9,Con{PLabel{+lTail2},Con{i11,Con{i12,+after}}}}}}}}}}}:
      w13e_match_zero_c(rCnt,lTail,lTop,i3,i4,i5,i6,i7,i8,i9,lTail2,i11,i12,after,fnItems)
    case _: None{}

@unsafe
def w13e_match_zero_c(+rCnt: U32, +lTail: String, +lTop: String, i3: X187Parsed, i4: X187Parsed,
    i5: X187Parsed, i6: X187Parsed, i7: X187Parsed, i8: X187Parsed, i9: X187Parsed,
    +lTail2: String, i11: X187Parsed, i12: X187Parsed, +after: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i3:
    case PInst{X187Instruction{op3,Con{X187Reg{+rIdx,64,False{}},Con{X187Reg{+rTmp,64,False{}},Nil{}}}}}:
      +rZero1 = w13e_is_zero_reg(i5)
      +rBase1 = w13e_is_store32_idx(i6,rZero1,rIdx)
      +rZero2 = w13e_is_zero_reg(i11)
      +rBase2 = w13e_is_store32_idx(i12,rZero2,rIdx)
      +ok = agy_str_eq(op3,"movq") && Bool.not(U32.is_eq(rIdx,rTmp)) &&
            Bool.not(U32.is_eq(rIdx,4)) && Bool.not(U32.is_eq(rIdx,rCnt)) &&
            w13e_is_addl_1(i4,rTmp) && U32.is_lt(rZero1,16) && U32.is_lt(rBase1,16) &&
            U32.is_eq(rBase1,rBase2) && U32.is_lt(rZero2,16) &&
            w13e_is_subq_1(i7,rCnt) && U32.is_eq(w13e_is_movq_rr(i8,rTmp),rIdx) &&
            agy_str_eq(w13e_is_jne_lbl(i9),lTop) && agy_str_eq(lTail,lTail2) &&
            w4b_reg_dead(rIdx,after,fnItems,64) && w4b_reg_dead(rCnt,after,fnItems,64) &&
            w4b_reg_dead(7,after,fnItems,64) && w4b_reg_dead(1,after,fnItems,64) &&
            w4b_reg_dead(0,after,fnItems,64)
      +lDone = lTail ++ "_zdone"
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{nt_append(X187Parsed,[
          PInst{X187Instruction{"leaq",[X187Indexed{rBase1,rIdx,4,0},x188_reg(10,64)]}},
          PInst{X187Instruction{"leaq",[X187Mem{rCnt,1},x188_reg(11,64)]}},
          PInst{X187Instruction{"movq",[x188_reg(10,64),x188_reg(7,64)]}},
          PInst{X187Instruction{"movq",[x188_reg(11,64),x188_reg(1,64)]}},
          PInst{X187Instruction{"shrq",[X187Imm{1,0},x188_reg(1,64)]}},
          PInst{X187Instruction{"xorl",[x188_reg(0,32),x188_reg(0,32)]}},
          PInst{X187Instruction{"rep_stosq",[]}},
          PInst{X187Instruction{"andl",[X187Imm{1,0},x188_reg(11,32)]}},
          PInst{X187Instruction{"je",[X187Target{lDone}]}},
          PInst{X187Instruction{"movl",[x188_reg(0,32),X187Mem{7,0}]}},
          PLabel{lDone}],after)},
        u => None{})
    case _: None{}

# ---- Pass B: count.go 10-instr -> 7-instr loop (dead copy + overflow-guarded row-base hoist) ----
@unsafe
def w13e_skip_label(items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Con{PLabel{_},rest}: rest
    case _: items

@unsafe
def w13e_match_count_c(+rCnt: U32, +lTail: String, +lTop: String,
    i3: X187Parsed, i4: X187Parsed, i5: X187Parsed, i6: X187Parsed,
    i7: X187Parsed, i8: X187Parsed, i9: X187Parsed, i10: X187Parsed,
    i11: X187Parsed, i12: X187Parsed, +origLoop: List<&2,X187Parsed>, +after: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i3 i5 i6 i7 i8 i9 i10:
    case PInst{X187Instruction{op3,Con{X187Imm{1,0},Con{X187Reg{+rJ,32,False{}},Nil{}}}}}
         PInst{X187Instruction{op5,Con{X187Reg{+rK1,64,False{}},Con{X187Reg{+rX,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op6,Con{X187Reg{+rK1b,64,False{}},Con{X187Reg{+rXb,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op7,Con{X187Reg{+rRow,64,False{}},Con{X187Reg{+rTmp,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op8,Con{X187Reg{+rXc,32,False{}},Con{X187Reg{+rTmpb,32,False{}},Nil{}}}}}
         PInst{X187Instruction{op9,Con{X187Imm{1,0},Con{X187Indexed{+rTbl,+rTmpc,4,0},Nil{}}}}}
         PInst{X187Instruction{op10,Con{X187Indexed{+rKeys,+rJcp,4,0},Con{X187Reg{+rXd,32,False{}},Nil{}}}}}:
      +rJcp0 = w13e_is_movq_rr(i4,rJ)
      +ok = agy_str_eq(op3,"addl") && U32.is_lt(rJcp0,16) && U32.is_eq(rJcp0,rJcp) &&
            Bool.not(U32.is_eq(rJ,4)) && Bool.not(U32.is_eq(rX,4)) && Bool.not(U32.is_eq(rRow,4)) &&
            agy_str_eq(op5,"cmpq") && agy_str_eq(op6,"cmovaeq") &&
            U32.is_eq(rK1,rK1b) && U32.is_eq(rX,rXb) && U32.is_eq(rX,rXc) && U32.is_eq(rX,rXd) &&
            agy_str_eq(op7,"movq") && agy_str_eq(op8,"addl") &&
            U32.is_eq(rTmp,rTmpb) && U32.is_eq(rTmp,rTmpc) &&
            agy_str_eq(op9,"addl") && agy_str_eq(op10,"movl") &&
            w13e_is_subq_1(i11,rCnt) && agy_str_eq(w13e_is_jne_lbl(i12),lTop) &&
            Bool.not(U32.is_eq(rTbl,10)) && Bool.not(U32.is_eq(rRow,10)) &&
            Bool.not(U32.is_eq(rK1,10)) && Bool.not(U32.is_eq(rX,10)) &&
            Bool.not(U32.is_eq(rKeys,10)) && Bool.not(U32.is_eq(rJ,10)) &&
            Bool.not(U32.is_eq(rCnt,10)) &&
            w4b_reg_dead(rJcp,w13e_skip_label(after),fnItems,64) && w4b_reg_dead(rTmp,w13e_skip_label(after),fnItems,64)
      +lFast = lTop ++ "_cfast"
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{nt_append(X187Parsed,[
          PInst{X187Instruction{"testq",[x188_reg(rCnt,64),x188_reg(rCnt,64)]}},
          PInst{X187Instruction{"je",[X187Target{lTail}]}},
          PInst{X187Instruction{"movq",[x188_reg(rRow,64),x188_reg(11,64)]}},
          PInst{X187Instruction{"addq",[x188_reg(rK1,64),x188_reg(11,64)]}},
          PInst{X187Instruction{"shrq",[X187Imm{32,0},x188_reg(11,64)]}},
          PInst{X187Instruction{"testq",[x188_reg(11,64),x188_reg(11,64)]}},
          PInst{X187Instruction{"jne",[X187Target{lTop}]}},
          PInst{X187Instruction{"leaq",[X187Indexed{rTbl,rRow,4,0},x188_reg(10,64)]}},
          PLabel{lFast},
          PInst{X187Instruction{"addl",[X187Imm{1,0},x188_reg(rJ,32)]}},
          PInst{X187Instruction{"cmpq",[x188_reg(rK1,64),x188_reg(rX,64)]}},
          PInst{X187Instruction{"cmovaeq",[x188_reg(rK1,64),x188_reg(rX,64)]}},
          PInst{X187Instruction{"addl",[X187Imm{1,0},X187Indexed{10,rX,4,0}]}},
          PInst{X187Instruction{"movl",[X187Indexed{rKeys,rJ,4,0},x188_reg(rX,32)]}},
          PInst{X187Instruction{"subq",[X187Imm{1,0},x188_reg(rCnt,64)]}},
          PInst{X187Instruction{"jne",[X187Target{lFast}]}},
          PInst{X187Instruction{"jmp",[X187Target{lTail}]}}],origLoop)},
        u => None{})
    case _ _ _ _ _ _ _: None{}

@unsafe
def w13e_match_count_b(+rCnt: U32, +lTail: String, +origLoop: List<&2,X187Parsed>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{+lTop},Con{i3,Con{i4,Con{i5,Con{i6,Con{i7,Con{i8,Con{i9,Con{i10,Con{i11,Con{i12,+after}}}}}}}}}}}:
      w13e_match_count_c(rCnt,lTail,lTop,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,origLoop,after,fnItems)
    case _: None{}

@unsafe
def w13e_match_count_loop(i0: X187Parsed, i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  +rCnt = w13e_is_testq_self(i0)
  +lTail = w13e_is_je_lbl(i1)
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,
    U32.is_lt(rCnt,16) && Bool.not(String.is_empty(lTail)),
    u => w13e_match_count_b(rCnt,lTail,rest,rest,fnItems),
    u => None{})

# ---- Pass C: General 4-Wide SSE4.1 Vectorizer for Contiguous U32 Array-Fill Loops ----
type W13EConstEnt is Data:
  W13ECImm{+val: U32, +xreg: U32}
  W13ECMem{+disp: U32, +xreg: U32}

type W13ERegMap is Data:
  W13ERegEnt{+gpr: U32, +xreg: U32}

type W13EVecState is Data:
  W13EVecOk{+rmap: List<&2,W13ERegMap>, +cmap: List<&2,W13EConstEnt>, +nextX: U32,
            +vbody: List<&2,X187Parsed>, +rStoreBase: U32, +rStoreVal: U32}
  W13EVecBad{}

@unsafe
def w13e_rmap_find(rmap: List<&2,W13ERegMap>, +g: U32) -> U32:
  match rmap:
    case Nil{}: 99
    case Con{W13ERegEnt{gg,xx},rest}:
      nt_choose(U32,U32.is_eq(gg,g),u => xx,u => w13e_rmap_find(rest,g))

@unsafe
def w13e_cmap_find_imm(cmap: List<&2,W13EConstEnt>, +v: U32) -> U32:
  match cmap:
    case Nil{}: 99
    case Con{W13ECImm{vv,xx},rest}:
      nt_choose(U32,U32.is_eq(vv,v),u => xx,u => w13e_cmap_find_imm(rest,v))
    case Con{_,rest}: w13e_cmap_find_imm(rest,v)

@unsafe
def w13e_cmap_find_mem(cmap: List<&2,W13EConstEnt>, +d: U32) -> U32:
  match cmap:
    case Nil{}: 99
    case Con{W13ECMem{dd,xx},rest}:
      nt_choose(U32,U32.is_eq(dd,d),u => xx,u => w13e_cmap_find_mem(rest,d))
    case Con{_,rest}: w13e_cmap_find_mem(rest,d)

@unsafe
def w13e_vec_get_reg(+g: U32, +rmap: List<&2,W13ERegMap>, +nextX: U32) -> U32:
  +f = w13e_rmap_find(rmap,g)
  nt_choose(U32,U32.is_lt(f,16),u => f,u => nt_choose(U32,U32.is_lt(nextX,15),v => nextX,v => 99))

@unsafe
def w13e_vec_add_reg(+g: U32, +x: U32, +rmap: List<&2,W13ERegMap>) -> List<&2,W13ERegMap>:
  nt_choose(List<&2,W13ERegMap>,U32.is_lt(w13e_rmap_find(rmap,g),16),u => rmap,u => Con{W13ERegEnt{g,x},rmap})

@unsafe
def w13e_vec_inc_x(+found: U32, +nextX: U32) -> U32:
  nt_choose(U32,U32.is_lt(found,16),u => nextX,u => U32.add(nextX,1))

@unsafe
def w13e_vec_step(item: X187Parsed, +rIdx: U32, +rCnt: U32, st: W13EVecState) -> W13EVecState:
  match st:
    case W13EVecBad{}: W13EVecBad{}
    case W13EVecOk{+rmap,+cmap,+nextX,+vbody,+rSB,+rSV}:
      nt_choose(W13EVecState,U32.is_lt(rSB,16),u => W13EVecBad{},u =>
        w13e_vec_inst(item,rIdx,rCnt,rmap,cmap,nextX,vbody))

@unsafe
def w13e_vec_inst(item: X187Parsed, +rIdx: U32, +rCnt: U32,
    +rmap: List<&2,W13ERegMap>, +cmap: List<&2,W13EConstEnt>,
    +nextX: U32, +vbody: List<&2,X187Parsed>) -> W13EVecState:
  match item:
    case PInst{X187Instruction{+op,Con{a,Con{b,Nil{}}}}}:
      w13e_vec_inst2(op,a,b,rIdx,rCnt,rmap,cmap,nextX,vbody)
    case _: W13EVecBad{}

@unsafe
def w13e_vec_inst2(+op: String, a: X187Operand, b: X187Operand, +rIdx: U32, +rCnt: U32,
    +rmap: List<&2,W13ERegMap>, +cmap: List<&2,W13EConstEnt>,
    +nextX: U32, +vbody: List<&2,X187Parsed>) -> W13EVecState:
  match a b:
    # movq/movl %rS, %rD
    case X187Reg{+s,sw,False{}} X187Reg{+d,dw,False{}}:
      nt_choose(W13EVecState,
        (agy_str_eq(op,"movq") || agy_str_eq(op,"movl")) &&
        Bool.not(U32.is_eq(d,rIdx)) && Bool.not(U32.is_eq(d,rCnt)),
        u =>
          +xs = w13e_rmap_find(rmap,s)
          +fd = w13e_rmap_find(rmap,d)
          +xd = w13e_vec_get_reg(d,rmap,nextX)
          nt_choose(W13EVecState,U32.is_lt(xs,16) && U32.is_lt(xd,15),
            v => W13EVecOk{w13e_vec_add_reg(d,xd,rmap),cmap,w13e_vec_inc_x(fd,nextX),
              Con{PInst{X187Instruction{"movdqa",[x188_xmm(xs),x188_xmm(xd)]}},vbody},99,99},
            v => W13EVecBad{}),
        u =>
          # reg-reg 32-bit ALU: addl, subl, xorl/xorq, andl/andq, orl/orq
          +vop = nt_choose(String,agy_str_eq(op,"addl"),v => "paddd",v =>
                 nt_choose(String,agy_str_eq(op,"subl"),w => "psubd",w =>
                 nt_choose(String,agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq"),z => "pxor",z =>
                 nt_choose(String,agy_str_eq(op,"andl") || agy_str_eq(op,"andq"),q => "pand",q =>
                 nt_choose(String,agy_str_eq(op,"orl") || agy_str_eq(op,"orq"),p => "por",p => "")))))
          +xs = w13e_rmap_find(rmap,s)
          +xd = w13e_rmap_find(rmap,d)
          nt_choose(W13EVecState,
            Bool.not(String.is_empty(vop)) && U32.is_lt(xs,16) && U32.is_lt(xd,16) &&
            Bool.not(U32.is_eq(d,rIdx)) && Bool.not(U32.is_eq(d,rCnt)),
            v => W13EVecOk{rmap,cmap,nextX,
              Con{PInst{X187Instruction{vop,[x188_xmm(xs),x188_xmm(xd)]}},vbody},99,99},
            v => W13EVecBad{}))
    # movq -disp(%rbp), %rD (loop-invariant scalar load)
    case X187Mem{5,+disp} X187Reg{+d,64,False{}}:
      nt_choose(W13EVecState,
        agy_str_eq(op,"movq") && Bool.not(U32.is_eq(d,rIdx)) && Bool.not(U32.is_eq(d,rCnt)),
        u =>
          +fm = w13e_cmap_find_mem(cmap,disp)
          +xm = nt_choose(U32,U32.is_lt(fm,16),v => fm,v => nextX)
          +nx1 = w13e_vec_inc_x(fm,nextX)
          +cm1 = nt_choose(List<&2,W13EConstEnt>,U32.is_lt(fm,16),v => cmap,v => Con{W13ECMem{disp,xm},cmap})
          +fd = w13e_rmap_find(rmap,d)
          +xd = w13e_vec_get_reg(d,rmap,nx1)
          +nx2 = w13e_vec_inc_x(fd,nx1)
          nt_choose(W13EVecState,U32.is_lt(xm,15) && U32.is_lt(xd,15),
            v => W13EVecOk{w13e_vec_add_reg(d,xd,rmap),cm1,nx2,
              Con{PInst{X187Instruction{"movdqa",[x188_xmm(xm),x188_xmm(xd)]}},vbody},99,99},
            v => W13EVecBad{}),
        u => W13EVecBad{})
    # imm-reg: addl, subl, imull, andl/andq, shll, shrl/shrq
    case X187Imm{+lo,0} X187Reg{+d,dw,False{}}:
      +xd = w13e_rmap_find(rmap,d)
      nt_choose(W13EVecState,
        U32.is_lt(xd,16) && Bool.not(U32.is_eq(d,rIdx)) && Bool.not(U32.is_eq(d,rCnt)),
        u =>
          nt_choose(W13EVecState,(agy_str_eq(op,"shll") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shrq")) && U32.is_lt(lo,32),
            v =>
              +sop = nt_choose(String,agy_str_eq(op,"shll"),w => "pslld",w => "psrld")
              W13EVecOk{rmap,cmap,nextX,
                Con{PInst{X187Instruction{sop,[X187Imm{lo,0},x188_xmm(xd)]}},vbody},99,99},
            v =>
              +vop = nt_choose(String,agy_str_eq(op,"addl"),w => "paddd",w =>
                     nt_choose(String,agy_str_eq(op,"subl"),z => "psubd",z =>
                     nt_choose(String,agy_str_eq(op,"imull"),q => "pmulld",q =>
                     nt_choose(String,agy_str_eq(op,"andl") || agy_str_eq(op,"andq"),p => "pand",p => ""))))
              +fc = w13e_cmap_find_imm(cmap,lo)
              +xc = nt_choose(U32,U32.is_lt(fc,16),w => fc,w => nextX)
              nt_choose(W13EVecState,Bool.not(String.is_empty(vop)) && U32.is_lt(xc,15),
                w =>
                  +cm1 = nt_choose(List<&2,W13EConstEnt>,U32.is_lt(fc,16),z => cmap,z => Con{W13ECImm{lo,xc},cmap})
                  W13EVecOk{rmap,cm1,w13e_vec_inc_x(fc,nextX),
                    Con{PInst{X187Instruction{vop,[x188_xmm(xc),x188_xmm(xd)]}},vbody},99,99},
                w => W13EVecBad{})),
        u => W13EVecBad{})
    # movl %rVal, (%rBase, %rIdx, 4) -> final store!
    case X187Reg{+v,32,False{}} X187Indexed{+base,+idx,4,0}:
      +xv = w13e_rmap_find(rmap,v)
      nt_choose(W13EVecState,
        agy_str_eq(op,"movl") && U32.is_eq(idx,rIdx) && U32.is_lt(xv,16) &&
        Bool.not(U32.is_eq(base,rIdx)) && Bool.not(U32.is_eq(base,rCnt)) &&
        Bool.not(U32.is_eq(base,0)) && Bool.not(U32.is_eq(base,10)) && Bool.not(U32.is_eq(base,11)),
        u => W13EVecOk{rmap,cmap,nextX,
          Con{PInst{X187Instruction{"movdqu_st",[x188_xmm(xv),X187Indexed{base,rIdx,4,0}]}},vbody},base,v},
        u => W13EVecBad{})
    case _ _: W13EVecBad{}

@unsafe
def w13e_vec_scan_body(items: List<&2,X187Parsed>, +rIdx: U32, +rCnt: U32,
    st: W13EVecState) -> W13EVecState:
  match items:
    case Nil{}: st
    case Con{h,rest}: w13e_vec_scan_body(rest,rIdx,rCnt,w13e_vec_step(h,rIdx,rCnt,st))

@unsafe
def w13e_vec_preheader_consts(cmap: List<&2,W13EConstEnt>, acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cmap:
    case Nil{}: acc
    case Con{W13ECImm{val,xreg},rest}:
      w13e_vec_preheader_consts(rest,
        Con{PInst{X187Instruction{"movl",[X187Imm{val,0},x188_reg(0,32)]}},
        Con{PInst{X187Instruction{"movd",[x188_reg(0,32),x188_xmm(xreg)]}},
        Con{PInst{X187Instruction{"pshufd0",[x188_xmm(xreg),x188_xmm(xreg)]}},acc}}})
    case Con{W13ECMem{disp,xreg},rest}:
      w13e_vec_preheader_consts(rest,
        Con{PInst{X187Instruction{"movl",[X187Mem{5,disp},x188_reg(0,32)]}},
        Con{PInst{X187Instruction{"movd",[x188_reg(0,32),x188_xmm(xreg)]}},
        Con{PInst{X187Instruction{"pshufd0",[x188_xmm(xreg),x188_xmm(xreg)]}},acc}}})

type W13ELoopSplit is Data:
  W13ELoopHit{+body: List<&2,X187Parsed>, +rIdx: U32, +rIdx1: U32, +rCnt: U32, +tail: List<&2,X187Parsed>}
  W13ELoopNo{}

law w13e_split_fill_loop:
  for +lTop: String
  for items: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  for +fuel: U32
  W13ELoopSplit

@unsafe
def w13e_split_fill_go(+lTop: String, items: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>, +fuel: U32) -> W13ELoopSplit:
  match items:
    case Con{PInst{X187Instruction{opS,Con{X187Imm{1,0},Con{X187Reg{+rCnt,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{+rIdx1,64,False{}},Con{X187Reg{+rIdx,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opJ,Con{X187Target{tLbl},Nil{}}}},+tail}}}:
      nt_choose(W13ELoopSplit,
        agy_str_eq(opS,"subq") && agy_str_eq(opM,"movq") &&
        (agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")) && agy_str_eq(tLbl,lTop) &&
        Bool.not(U32.is_eq(rIdx,rCnt)) && Bool.not(U32.is_eq(rIdx,4)) &&
        Bool.not(U32.is_eq(rIdx,0)) && Bool.not(U32.is_eq(rIdx,10)) && Bool.not(U32.is_eq(rIdx,11)) &&
        Bool.not(U32.is_eq(rCnt,0)) && Bool.not(U32.is_eq(rCnt,10)) && Bool.not(U32.is_eq(rCnt,11)),
        v => W13ELoopHit{nt_reverse(X187Parsed,acc,[]),rIdx,rIdx1,rCnt,tail},
        v => W13ELoopNo{})
    case Con{PLabel{_},_}: W13ELoopNo{}
    case Con{h,rest}: w13e_split_fill_loop(lTop,rest,Con{h,acc},U32.sub(fuel,1))
    case Nil{}: W13ELoopNo{}

@unsafe
def w13e_split_fill_loop(lTop,items,acc,fuel):
  nt_choose(W13ELoopSplit,U32.is_eq(fuel,0),u => W13ELoopNo{},u => w13e_split_fill_go(lTop,items,acc,fuel))

@unsafe
def w13e_check_idx_inc(body: List<&2,X187Parsed>, +rIdx: U32, +rIdx1: U32) -> Bool:
  match body:
    case Con{i0,Con{i1,_}}:
      U32.is_eq(w13e_is_movq_rr(i0,rIdx),rIdx1) && w13e_is_addl_1(i1,rIdx1)
    case _: False{}

@unsafe
def w13e_vec_emit(+lTop: String, +lTail: String, +origLoop: List<&2,X187Parsed>,
    +rIdx: U32, +rCnt: U32, +tail: List<&2,X187Parsed>, st: W13EVecState) -> Maybe<&2,List<&2,X187Parsed>>:
  match st:
    case W13EVecBad{}: None{}
    case W13EVecOk{rmap,cmap,nextX,vbody,rSB,rSV}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_lt(rSB,16),
        u =>
          +lVec = lTop ++ "_v4"
          +preConsts = w13e_vec_preheader_consts(cmap,[])
          +preInit : List<&2,X187Parsed> = [
            PInst{X187Instruction{"testq",[x188_reg(rCnt,64),x188_reg(rCnt,64)]}},
            PInst{X187Instruction{"je",[X187Target{lTail}]}},
            PInst{X187Instruction{"cmpq",[X187Imm{4,0},x188_reg(rCnt,64)]}},
            PInst{X187Instruction{"jb",[X187Target{lTop}]}},
            PInst{X187Instruction{"movq",[x188_reg(rIdx,64),x188_reg(10,64)]}},
            PInst{X187Instruction{"addq",[x188_reg(rCnt,64),x188_reg(10,64)]}},
            PInst{X187Instruction{"shrq",[X187Imm{32,0},x188_reg(10,64)]}},
            PInst{X187Instruction{"testq",[x188_reg(10,64),x188_reg(10,64)]}},
            PInst{X187Instruction{"jne",[X187Target{lTop}]}},
            PInst{X187Instruction{"movd",[x188_reg(rIdx,32),x188_xmm(0)]}},
            PInst{X187Instruction{"pshufd0",[x188_xmm(0),x188_xmm(0)]}},
            PInst{X187Instruction{"movabsq",[X187Imm{0,1},x188_reg(0,64)]}},
            PInst{X187Instruction{"movq_x",[x188_reg(0,64),x188_xmm(15)]}},
            PInst{X187Instruction{"movabsq",[X187Imm{2,3},x188_reg(0,64)]}},
            PInst{X187Instruction{"movq_x",[x188_reg(0,64),x188_xmm(1)]}},
            PInst{X187Instruction{"punpcklqdq",[x188_xmm(1),x188_xmm(15)]}},
            PInst{X187Instruction{"paddd",[x188_xmm(15),x188_xmm(0)]}},
            PInst{X187Instruction{"movl",[X187Imm{4,0},x188_reg(0,32)]}},
            PInst{X187Instruction{"movd",[x188_reg(0,32),x188_xmm(1)]}},
            PInst{X187Instruction{"pshufd0",[x188_xmm(1),x188_xmm(1)]}}]
          +vLoopTail : List<&2,X187Parsed> = [
            PInst{X187Instruction{"paddd",[x188_xmm(1),x188_xmm(0)]}},
            PInst{X187Instruction{"addq",[X187Imm{4,0},x188_reg(rIdx,64)]}},
            PInst{X187Instruction{"subq",[X187Imm{4,0},x188_reg(rCnt,64)]}},
            PInst{X187Instruction{"cmpq",[X187Imm{4,0},x188_reg(rCnt,64)]}},
            PInst{X187Instruction{"jae",[X187Target{lVec}]}},
            PInst{X187Instruction{"testq",[x188_reg(rCnt,64),x188_reg(rCnt,64)]}},
            PInst{X187Instruction{"je",[X187Target{lTail}]}}]
          +vSeq = nt_append(X187Parsed,preInit,
                  nt_append(X187Parsed,preConsts,
                  Con{PLabel{lVec},
                  nt_append(X187Parsed,nt_reverse(X187Parsed,vbody,[]),
                  nt_append(X187Parsed,vLoopTail,origLoop))}))
          Some{vSeq},
        u => None{})

@unsafe
def w13e_match_fill_vec_b(+lTop: String, +lTail: String, +origLoop: List<&2,X187Parsed>,
    +rCnt0: U32, split: W13ELoopSplit, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match split:
    case W13ELoopNo{}: None{}
    case W13ELoopHit{+body,+rIdx,+rIdx1,+rCnt,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(rCnt,rCnt0) && w13e_check_idx_inc(body,rIdx,rIdx1) &&
        w4b_reg_dead(0,tail,fnItems,64) && w4b_reg_dead(rIdx1,tail,fnItems,64),
        v => w13e_vec_emit(lTop,lTail,origLoop,rIdx,rCnt,tail,
               w13e_vec_scan_body(body,rIdx,rCnt,W13EVecOk{[W13ERegEnt{rIdx,0}],[],2,[],99,99})),
        v => None{})

@unsafe
def w13e_match_fill_vec_a(+rCnt0: U32, +lTail: String, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PLabel{+lTop},+afterTop}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_lt(rCnt0,16) && Bool.not(String.is_empty(lTail)),
        u => w13e_match_fill_vec_b(lTop,lTail,Con{PLabel{lTop},afterTop},rCnt0,
               w13e_split_fill_loop(lTop,afterTop,[],48),fnItems),
        u => None{})
    case _: None{}

@unsafe
def w13e_match_fill_vec(i0: X187Parsed, i1: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w13e_match_fill_vec_a(w13e_is_testq_self(i0),w13e_is_je_lbl(i1),rest,fnItems)

law w13e_loop_scan:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +hasXmm: Bool
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w13e_loop_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +hasXmm: Bool,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{rew}: nt_append(X187Parsed,nt_reverse(X187Parsed,acc,[]),rew)
    case None{}: w13e_loop_scan(Con{i1,rest},fnItems,hasXmm,Con{i0,acc})

@unsafe
def w13e_loop_scan(items,fnItems,hasXmm,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+rest}}:
      +h1 = w13e_match_zero_loop(i0,i1,rest,fnItems)
      +h2 = w4c_or_peep_opt(h1,u => w13e_match_count_loop(i0,i1,rest,fnItems))
      +h3 = w4c_or_peep_opt(h2,u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,hasXmm,
              v => None{},v => w13e_match_fill_vec(i0,i1,rest,fnItems)))
      w13e_loop_apply(h3,i0,i1,rest,fnItems,hasXmm,acc)
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])

@unsafe
def w13e_loop_opt(hasLoop: Bool, hasXmm: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLoop:
    case False{}: items
    case True{}: w13e_loop_scan(items,items,hasXmm,[])
"""

W13E_P113D_PASSES = """
# ============================================================================
# W13-E Step 2:
#   A. General Tiny Mul-Add Tail-Loop Inliner (w13e_muladd_loop intrinsic)
#   B. General Non-Escaping Small Stack Array<U32> Specialization (rep stosq)
# ============================================================================

# ---- A. Mul-Add Tail-Loop Detection & Inlining ----
type W13EMulAddInfo is Data:
  W13EMulAddNone{}
  W13EMulAddHit{+mulC: U32}

type W13EMulAddEnt is Data:
  W13EMulAddEnt{+name: String, +mulC: U32}

@unsafe
def w13e_ma_is_local(v: N111Value, +want: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,want)
    case _: False{}

@unsafe
def w13e_ma_is_const(v: N111Value, +want: U32) -> Bool:
  match v:
    case N111Const{lo,0}: U32.is_eq(lo,want)
    case _: False{}

@unsafe
def w13e_ma_check_mul(b: N111Value, +rest: List<&2,P113DStmt>, +pCnt: String, +pK: String, +pAcc: String,
    +cntNext: String, +dst: String, +accNext: String) -> W13EMulAddInfo:
  match b:
    case N111Const{+c,0}:
      nt_choose(W13EMulAddInfo,U32.is_ge(c,1) && U32.is_le(c,2147483647),
        w => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,dst,c,accNext),w => W13EMulAddNone{})
    case _: W13EMulAddNone{}

law w13e_ma_check_step:
  for stmts: List<&2,P113DStmt>
  for +pCnt: String
  for +pK: String
  for +pAcc: String
  for +cntNext: String
  for +mulTmp: String
  for +mulC: U32
  for +accNext: String
  W13EMulAddInfo

@unsafe
def w13e_ma_check_step(stmts,pCnt,pK,pAcc,cntNext,mulTmp,mulC,accNext):
  match stmts:
    case Con{P113DScalar{N111Bin{+dst,_,+op,+a,+b}},+rest}:
      nt_choose(W13EMulAddInfo,agy_str_eq(op,"sub") && w13e_ma_is_local(a,pCnt) && w13e_ma_is_const(b,1),
        u => w13e_ma_check_step(rest,pCnt,pK,pAcc,dst,mulTmp,mulC,accNext),u =>
      nt_choose(W13EMulAddInfo,agy_str_eq(op,"mul") && w13e_ma_is_local(a,pAcc),
        v => w13e_ma_check_mul(b,rest,pCnt,pK,pAcc,cntNext,dst,accNext),v =>
      nt_choose(W13EMulAddInfo,agy_str_eq(op,"and") && w13e_ma_is_const(b,4294967295),
        w => nt_choose(W13EMulAddInfo,w13e_ma_is_local(a,mulTmp),
               z => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,dst,mulC,accNext),
               z => nt_choose(W13EMulAddInfo,w13e_ma_is_local(a,accNext),
                      q => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,mulTmp,mulC,dst),
                      q => nt_choose(W13EMulAddInfo,w13e_ma_is_local(a,pAcc),
                             p => w13e_ma_check_step(rest,pCnt,pK,dst,cntNext,mulTmp,mulC,accNext),
                             p => nt_choose(W13EMulAddInfo,w13e_ma_is_local(a,pK),
                                    r => w13e_ma_check_step(rest,pCnt,dst,pAcc,cntNext,mulTmp,mulC,accNext),
                                    r => W13EMulAddNone{})))),w =>
      nt_choose(W13EMulAddInfo,agy_str_eq(op,"add") && Bool.not(String.is_empty(mulTmp)) &&
          ((w13e_ma_is_local(a,mulTmp) && w13e_ma_is_local(b,pK)) ||
           (w13e_ma_is_local(b,mulTmp) && w13e_ma_is_local(a,pK))),
        z => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,mulTmp,mulC,dst),z => W13EMulAddNone{}))))
    case Con{P113DScalar{N111Set{+dst,_,+src}},+rest}:
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(src,pAcc),
        u => w13e_ma_check_step(rest,pCnt,pK,dst,cntNext,mulTmp,mulC,accNext),u =>
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(src,pK),
        v => w13e_ma_check_step(rest,pCnt,dst,pAcc,cntNext,mulTmp,mulC,accNext),v =>
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(src,cntNext),
        w => w13e_ma_check_step(rest,pCnt,pK,pAcc,dst,mulTmp,mulC,accNext),w =>
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(src,mulTmp),
        z => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,dst,mulC,accNext),z =>
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(src,accNext),
        q => w13e_ma_check_step(rest,pCnt,pK,pAcc,cntNext,mulTmp,mulC,dst),q => W13EMulAddNone{})))))
    case Con{P113DAgain{Con{a0,Con{a1,Con{a2,Nil{}}}}},Nil{}}:
      nt_choose(W13EMulAddInfo,
        Bool.not(String.is_empty(cntNext)) && Bool.not(String.is_empty(accNext)) && U32.is_ge(mulC,1) &&
        w13e_ma_is_local(a0,cntNext) && w13e_ma_is_local(a1,pK) && w13e_ma_is_local(a2,accNext),
        u => W13EMulAddHit{mulC},u => W13EMulAddNone{})
    case _: W13EMulAddNone{}

@unsafe
def w13e_ma_is_ret(stmts: List<&2,P113DStmt>, +pAcc: String) -> Bool:
  match stmts:
    case Con{P113DResult{Con{v,Nil{}}},Nil{}}: w13e_ma_is_local(v,pAcc)
    case _: False{}

@unsafe
def w13e_ma_unwrap_ne(no: List<&2,P113DStmt>, +pCnt: String, +pK: String, +pAcc: String) -> W13EMulAddInfo:
  match no:
    case Con{P113DScalar{N111Bin{+c2,_,op2,a2,b2}},Con{P113DIf{cond2,+yes2,_},Nil{}}}:
      nt_choose(W13EMulAddInfo,agy_str_eq(op2,"ne") && w13e_ma_is_local(a2,pCnt) && w13e_ma_is_const(b2,0) && w13e_ma_is_local(cond2,c2),
        u => w13e_ma_check_step(yes2,pCnt,pK,pAcc,"","",0,""),
        u => w13e_ma_check_step(no,pCnt,pK,pAcc,"","",0,""))
    case _: w13e_ma_check_step(no,pCnt,pK,pAcc,"","",0,"")

@unsafe
def w13e_ma_check_body(body: List<&2,P113DStmt>, +pCnt: String, +pK: String, +pAcc: String) -> W13EMulAddInfo:
  match body:
    case Con{P113DIf{cond,+yes,no},Nil{}}:
      nt_choose(W13EMulAddInfo,w13e_ma_is_local(cond,pCnt) && w13e_ma_is_ret(no,pAcc),
        u => w13e_ma_check_step(yes,pCnt,pK,pAcc,"","",0,""),u => W13EMulAddNone{})
    case Con{P113DScalar{N111Bin{+cnd,_,op,a,b}},Con{P113DIf{cond,yes,+no},Nil{}}}:
      nt_choose(W13EMulAddInfo,agy_str_eq(op,"eq") && w13e_ma_is_local(a,pCnt) && w13e_ma_is_const(b,0) &&
          w13e_ma_is_local(cond,cnd) && w13e_ma_is_ret(yes,pAcc),
        u => w13e_ma_unwrap_ne(no,pCnt,pK,pAcc),u => W13EMulAddNone{})
    case _: W13EMulAddNone{}

@unsafe
def w13e_ma_check_fn(f: P113DFunction) -> W13EMulAddInfo:
  match f:
    case P113DFunction{_,Con{NC_Binding{_,pCnt,_},Con{NC_Binding{_,pK,_},Con{NC_Binding{_,pAcc,_},Nil{}}}},1,_,body}:
      w13e_ma_check_body(body,pCnt,pK,pAcc)
    case _: W13EMulAddNone{}

@unsafe
def w13e_ma_collect_one(info: W13EMulAddInfo, +name: String, +rest: List<&2,P113DFunction>,
    +acc: List<&2,W13EMulAddEnt>) -> List<&2,W13EMulAddEnt>:
  match info:
    case W13EMulAddHit{c}: w13e_ma_collect(rest,Con{W13EMulAddEnt{name,c},acc})
    case W13EMulAddNone{}: w13e_ma_collect(rest,acc)

law w13e_ma_collect:
  for fs: List<&2,P113DFunction>
  for acc: List<&2,W13EMulAddEnt>
  List<&2,W13EMulAddEnt>

@unsafe
def w13e_ma_collect(fs,acc):
  match fs:
    case Nil{}: acc
    case Con{P113DFunction{+name,ps,r,pub,b},rest}:
      w13e_ma_collect_one(w13e_ma_check_fn(P113DFunction{name,ps,r,pub,b}),name,rest,acc)

@unsafe
def w13e_ma_find(ents: List<&2,W13EMulAddEnt>, +target: String) -> U32:
  match ents:
    case Nil{}: 0
    case Con{W13EMulAddEnt{n,c},rest}:
      nt_choose(U32,agy_str_eq(n,target),u => c,u => w13e_ma_find(rest,target))

law w13e_ma_rew_body:
  for body: List<&2,P113DStmt>
  for +ents: List<&2,W13EMulAddEnt>
  List<&2,P113DStmt>

@unsafe
def w13e_ma_rew_body(body,ents):
  match body:
    case Nil{}: []
    case Con{P113DIf{cond,+yes,+no},+rest}:
      Con{P113DIf{cond,w13e_ma_rew_body(yes,ents),w13e_ma_rew_body(no,ents)},w13e_ma_rew_body(rest,ents)}
    case Con{P113DCall{Con{+dst,Nil{}},+target,Con{+a0,Con{+a1,Con{+a2,Nil{}}}}},+rest}:
      +c = w13e_ma_find(ents,target)
      nt_choose(List<&2,P113DStmt>,U32.is_gt(c,0),
        u => Con{P113DScalar{N111Call{dst,N111U64{},"w13e_muladd_loop",[
               N111Arg{N111U64{},a0},N111Arg{N111U64{},a1},N111Arg{N111U64{},a2},N111Arg{N111U32{},N111Const{c,0}}]}},
               w13e_ma_rew_body(rest,ents)},
        u => Con{P113DCall{[dst],target,[a0,a1,a2]},w13e_ma_rew_body(rest,ents)})
    case Con{h,rest}: Con{h,w13e_ma_rew_body(rest,ents)}

@unsafe
def w13e_ma_rew_fns(fs: List<&2,P113DFunction>, +ents: List<&2,W13EMulAddEnt>) -> List<&2,P113DFunction>:
  match fs:
    case Nil{}: []
    case Con{P113DFunction{name,params,res,pub,body},rest}:
      Con{P113DFunction{name,params,res,pub,w13e_ma_rew_body(body,ents)},w13e_ma_rew_fns(rest,ents)}

# ---- B. Non-Escaping Small Stack Array<U32> Specialization ----
@unsafe
def w13e_str_in(xs: List<&2,String>, +s: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: agy_str_eq(h,s) || w13e_str_in(rest,s)

@unsafe
def w13e_str_add(+xs: List<&2,String>, +s: String) -> List<&2,String>:
  nt_choose(List<&2,String>,w13e_str_in(xs,s),u => xs,u => Con{s,xs})

@unsafe
def w13e_str_del(xs: List<&2,String>, +s: String) -> List<&2,String>:
  match xs:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(h,s),u => w13e_str_del(rest,s),u => Con{h,w13e_str_del(rest,s)})

@unsafe
def w13e_str_del_many(xs: List<&2,String>, ds: List<&2,String>) -> List<&2,String>:
  match ds:
    case Nil{}: xs
    case Con{d,rest}: w13e_str_del_many(w13e_str_del(xs,d),rest)

@unsafe
def w13e_val_in(v: N111Value, +aset: List<&2,String>) -> Bool:
  match v:
    case N111Local{n}: w13e_str_in(aset,n)
    case _: False{}

@unsafe
def w13e_vals_in(vs: List<&2,N111Value>, +aset: List<&2,String>) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: w13e_val_in(v,aset) || w13e_vals_in(rest,aset)

@unsafe
def w13e_args_in(args: List<&2,N111Arg>, +aset: List<&2,String>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w13e_val_in(v,aset) || w13e_args_in(rest,aset)

@unsafe
def w13e_nth_str(xs: List<&2,String>, +i: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{h,rest}: nt_choose(String,U32.is_eq(i,0),u => h,u => w13e_nth_str(rest,U32.sub(i,1)))

@unsafe
def w13e_nth_param(ps: List<&2,NC_Binding>, +i: U32) -> String:
  match ps:
    case Nil{}: ""
    case Con{NC_Binding{_,n,_},rest}: nt_choose(String,U32.is_eq(i,0),u => n,u => w13e_nth_param(rest,U32.sub(i,1)))

@unsafe
def w13e_find_fn(fs: List<&2,P113DFunction>, +name: String) -> Maybe<&2,P113DFunction>:
  match fs:
    case Nil{}: None{}
    case Con{P113DFunction{+n,+ps,+r,+pub,+b},+rest}:
      nt_choose(Maybe<&2,P113DFunction>,agy_str_eq(n,name),
        u => Some{P113DFunction{n,ps,r,pub,b}},u => w13e_find_fn(rest,name))

@unsafe
def w13e_vals_single_idx(vs: List<&2,N111Value>, +aset: List<&2,String>, +idx: U32, +hit: U32) -> U32:
  match vs:
    case Nil{}: hit
    case Con{v,+rest}:
      nt_choose(U32,w13e_val_in(v,aset),
        u => nt_choose(U32,U32.is_eq(hit,99),v2 => w13e_vals_single_idx(rest,aset,U32.add(idx,1),idx),v2 => 98),
        u => w13e_vals_single_idx(rest,aset,U32.add(idx,1),hit))

type W13ESAChk is Data:
  W13ESABad{}
  W13ESAOk{+aset: List<&2,String>, +retIdx: U32, +live: Bool}

@unsafe
def w13e_sa_merge_ret(+r1: U32, +r2: U32) -> U32:
  nt_choose(U32,U32.is_eq(r1,100),u => r2,u =>
  nt_choose(U32,U32.is_eq(r2,100),v => r1,v =>
  nt_choose(U32,U32.is_eq(r1,r2),w => r1,w => 98)))

law w13e_sa_chk_body:
  for body: List<&2,P113DStmt>
  for +aset: List<&2,String>
  for +isRoot: Bool
  for +selfName: String
  for +paramIdx: U32
  for +fs: List<&2,P113DFunction>
  for +fuel: U32
  for +retIdx: U32
  W13ESAChk

@unsafe
def w13e_sa_chk_scalar(stmt: N111Stmt, +aset: List<&2,String>) -> Maybe<&2,List<&2,String>>:
  match stmt:
    case N111Set{+dst,_,+src}:
      nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(src,aset),
        u => Some{w13e_str_add(aset,dst)},u => Some{w13e_str_del(aset,dst)})
    case N111Bin{+dst,_,_,+l,+r}:
      nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(l,aset) || w13e_val_in(r,aset),
        u => None{},u => Some{w13e_str_del(aset,dst)})
    case N111Load{+dst,_,+base,_}:
      nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(base,aset),
        u => None{},u => Some{w13e_str_del(aset,dst)})
    case N111Store{_,+base,_,+val}:
      nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(base,aset) || w13e_val_in(val,aset),
        u => None{},u => Some{aset})
    case N111Offset{+dst,+base,+bytes}:
      nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(base,aset) || w13e_val_in(bytes,aset),
        u => None{},u => Some{w13e_str_del(aset,dst)})
    case N111Alloca{+dst,_,_}: Some{w13e_str_del(aset,dst)}
    case N111Call{+dst,_,+sym,args}:
      match args:
        case Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,+v},Nil{}}}:
          nt_choose(Maybe<&2,List<&2,String>>,agy_str_eq(sym,"p111_rt_sink") && agy_str_eq(st,"state") && w13e_val_in(v,aset),
            u => Some{w13e_str_del(aset,dst)},
            u => nt_choose(Maybe<&2,List<&2,String>>,w13e_val_in(N111Local{st},aset) || w13e_val_in(v,aset),v2 => None{},v2 => Some{w13e_str_del(aset,dst)}))
        case other:
          nt_choose(Maybe<&2,List<&2,String>>,w13e_args_in(other,aset),u => None{},u => Some{w13e_str_del(aset,dst)})
    case _: None{}

@unsafe
def w13e_sa_chk_callee(found: Maybe<&2,P113DFunction>, +argIdx: U32, +fs: List<&2,P113DFunction>, +fuel: U32) -> W13ESAChk:
  match found:
    case None{}: W13ESABad{}
    case Some{P113DFunction{+gName,+params,+res,_,body}}:
      +pName = w13e_nth_param(params,argIdx)
      nt_choose(W13ESAChk,Bool.not(String.is_empty(pName)) && U32.is_le(res,2) && U32.is_gt(fuel,0),
        u => w13e_sa_chk_body(body,[pName],False{},gName,argIdx,fs,U32.sub(fuel,1),100),
        u => W13ESABad{})

@unsafe
def w13e_str_inter(xs: List<&2,String>, +ys: List<&2,String>) -> List<&2,String>:
  match xs:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,String>,w13e_str_in(ys,h),u => Con{h,w13e_str_inter(rest,ys)},u => w13e_str_inter(rest,ys))

@unsafe
def w13e_str_diff(xs: List<&2,String>, +ys: List<&2,String>) -> List<&2,String>:
  match xs:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,String>,w13e_str_in(ys,h),u => w13e_str_diff(rest,ys),u => Con{h,w13e_str_diff(rest,ys)})

@unsafe
def w13e_stmt_uses_any(stmt: N111Stmt, +xs: List<&2,String>) -> Bool:
  match stmt:
    case N111Set{_,_,src}: w13e_val_in(src,xs)
    case N111Bin{_,_,_,l,r}: w13e_val_in(l,xs) || w13e_val_in(r,xs)
    case N111Load{_,_,base,_}: w13e_val_in(base,xs)
    case N111Store{_,base,_,val}: w13e_val_in(base,xs) || w13e_val_in(val,xs)
    case N111Offset{_,base,bytes}: w13e_val_in(base,xs) || w13e_val_in(bytes,xs)
    case N111Call{_,_,_,args}: w13e_args_in(args,xs)
    case _: False{}

@unsafe
def w13e_stmt_kill(stmt: N111Stmt, +xs: List<&2,String>) -> List<&2,String>:
  match stmt:
    case N111Set{dst,_,_}: w13e_str_del(xs,dst)
    case N111Bin{dst,_,_,_,_}: w13e_str_del(xs,dst)
    case N111Load{dst,_,_,_}: w13e_str_del(xs,dst)
    case N111Offset{dst,_,_}: w13e_str_del(xs,dst)
    case N111Alloca{dst,_,_}: w13e_str_del(xs,dst)
    case N111Call{dst,_,_,_}: w13e_str_del(xs,dst)
    case _: xs

law w13e_body_uses_any:
  for body: List<&2,P113DStmt>
  for +xs: List<&2,String>
  Bool

@unsafe
def w13e_body_uses_any(body,xs):
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{+s},rest}: w13e_stmt_uses_any(s,xs) || w13e_body_uses_any(rest,w13e_stmt_kill(s,xs))
    case Con{P113DIf{cond,yes,no},rest}:
      w13e_val_in(cond,xs) || w13e_body_uses_any(yes,xs) || w13e_body_uses_any(no,xs) || w13e_body_uses_any(rest,xs)
    case Con{P113DCall{dsts,_,args},rest}: w13e_vals_in(args,xs) || w13e_body_uses_any(rest,w13e_str_del_many(xs,dsts))
    case Con{P113DAgain{args},rest}: w13e_vals_in(args,xs) || w13e_body_uses_any(rest,xs)
    case Con{P113DResult{vals},rest}: w13e_vals_in(vals,xs) || w13e_body_uses_any(rest,xs)

@unsafe
def w13e_sa_scalar_del(stmt: N111Stmt, +aset: List<&2,String>) -> List<&2,String>:
  match stmt:
    case N111Set{+dst,_,src}:
      nt_choose(List<&2,String>,w13e_val_in(src,aset),u => w13e_str_add(aset,dst),u => w13e_str_del(aset,dst))
    case N111Bin{dst,_,_,_,_}: w13e_str_del(aset,dst)
    case N111Load{dst,_,_,_}: w13e_str_del(aset,dst)
    case N111Offset{dst,_,_}: w13e_str_del(aset,dst)
    case N111Alloca{dst,_,_}: w13e_str_del(aset,dst)
    case N111Call{dst,_,_,_}: w13e_str_del(aset,dst)
    case _: aset

@unsafe
def w13e_sa_chk_after_if(c1: W13ESAChk, c2: W13ESAChk, +rest: List<&2,P113DStmt>,
    +isRoot: Bool, +selfName: String, +paramIdx: U32, +fs: List<&2,P113DFunction>, +fuel: U32) -> W13ESAChk:
  match c1 c2:
    case W13ESAOk{+a1,r1,+l1} W13ESAOk{+a2,r2,+l2}:
      +rm = w13e_sa_merge_ret(r1,r2)
      nt_choose(W13ESAChk,U32.is_eq(rm,98),u => W13ESABad{},u =>
      nt_choose(W13ESAChk,l1 && l2,
        v =>
          +diff = nt_append(String,w13e_str_diff(a1,a2),w13e_str_diff(a2,a1))
          +ok = List.is_empty(&2,P113DStmt,rest) || Bool.not(w13e_body_uses_any(rest,diff))
          nt_choose(W13ESAChk,ok,w => w13e_sa_chk_body(rest,w13e_str_inter(a1,a2),isRoot,selfName,paramIdx,fs,fuel,rm),w => W13ESABad{}),
        v => nt_choose(W13ESAChk,l1,
          w => w13e_sa_chk_body(rest,a1,isRoot,selfName,paramIdx,fs,fuel,rm),
          w => nt_choose(W13ESAChk,l2,
            z => w13e_sa_chk_body(rest,a2,isRoot,selfName,paramIdx,fs,fuel,rm),
            z => W13ESAOk{[],rm,False{}}))))
    case _ _: W13ESABad{}

@unsafe
def w13e_sa_chk_step_sc(res: Maybe<&2,List<&2,String>>, +rest: List<&2,P113DStmt>,
    +isRoot: Bool, +selfName: String, +paramIdx: U32, +fs: List<&2,P113DFunction>,
    +fuel: U32, +retIdx: U32) -> W13ESAChk:
  match res:
    case None{}: W13ESABad{}
    case Some{as2}: w13e_sa_chk_body(rest,as2,isRoot,selfName,paramIdx,fs,fuel,retIdx)

@unsafe
def w13e_sa_chk_after_call(chk: W13ESAChk, +dsts: List<&2,String>, +rest: List<&2,P113DStmt>,
    +aset: List<&2,String>, +isRoot: Bool, +selfName: String, +paramIdx: U32,
    +fs: List<&2,P113DFunction>, +fuel: U32, +retIdx: U32) -> W13ESAChk:
  match chk:
    case W13ESABad{}: W13ESABad{}
    case W13ESAOk{_,rIdx,_}:
      +as1 = w13e_str_del_many(aset,dsts)
      +as2 = nt_choose(List<&2,String>,U32.is_lt(rIdx,nt_count(String,dsts)),
        w => w13e_str_add(as1,w13e_nth_str(dsts,rIdx)),w => as1)
      w13e_sa_chk_body(rest,as2,isRoot,selfName,paramIdx,fs,fuel,retIdx)

@unsafe
def w13e_sa_chk_body(body,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx):
  match body:
    case Nil{}: W13ESAOk{aset,retIdx,True{}}
    # Match get (op 72) + two loads from out
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{N111Call{+stDst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{72,0}},Con{N111Arg{_,N111Local{+b2}},Con{N111Arg{_,N111Const{2,0}},Con{N111Arg{_,N111Local{+o2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}}}},
         Con{P113DScalar{N111Load{+l0,N111U64{},N111Local{+o3},+off0}},
         Con{P113DScalar{N111Load{+l1,N111U64{},N111Local{+o4},+off1}},+rest}}}}}}:
      nt_choose(W13ESAChk,
        agy_str_eq(sym,"p113_rt_array_pair") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(out,o2) && agy_str_eq(out,o3) && agy_str_eq(out,o4) &&
        w13e_val_in(v0,aset) && Bool.not(w13e_val_in(v1,aset)) &&
        ((U32.is_eq(off0,0) && U32.is_eq(off1,8)) || (U32.is_eq(off0,8) && U32.is_eq(off1,0))),
        u =>
          +aOut = nt_choose(String,U32.is_eq(off0,0),v => l0,v => l1)
          +vOut = nt_choose(String,U32.is_eq(off0,0),v => l1,v => l0)
          w13e_sa_chk_body(rest,w13e_str_add(w13e_str_del(w13e_str_del(aset,vOut),stDst),aOut),
            isRoot,selfName,paramIdx,fs,fuel,retIdx),
        u => w13e_sa_chk_step_sc(w13e_sa_chk_scalar(N111Store{N111U64{},N111Local{b0},0,v0},aset),
          Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
          Con{P113DScalar{N111Alloca{out,16,8}},
          Con{P113DScalar{N111Call{stDst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{72,0}},N111Arg{N111Ptr{},N111Local{b2}},N111Arg{N111U32{},N111Const{2,0}},N111Arg{N111Ptr{},N111Local{o2}},N111Arg{N111U32{},N111Const{2,0}}]}},
          Con{P113DScalar{N111Load{l0,N111U64{},N111Local{o3},off0}},
          Con{P113DScalar{N111Load{l1,N111U64{},N111Local{o4},off1}},rest}}}}},
          isRoot,selfName,paramIdx,fs,fuel,retIdx))
    # Match get (op 72) + single load from out+8 (when p113k elided load out+0)
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{N111Call{+stDst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{72,0}},Con{N111Arg{_,N111Local{+b2}},Con{N111Arg{_,N111Const{2,0}},Con{N111Arg{_,N111Local{+o2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}}}},
         Con{P113DScalar{N111Load{+vOut,N111U64{},N111Local{+o3},8}},+rest}}}}}:
      nt_choose(W13ESAChk,
        agy_str_eq(sym,"p113_rt_array_pair") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(out,o2) && agy_str_eq(out,o3) &&
        w13e_val_in(v0,aset) && Bool.not(w13e_val_in(v1,aset)),
        u => w13e_sa_chk_body(rest,w13e_str_del(w13e_str_del(aset,vOut),stDst),
               isRoot,selfName,paramIdx,fs,fuel,retIdx),
        u => w13e_sa_chk_step_sc(w13e_sa_chk_scalar(N111Store{N111U64{},N111Local{b0},0,v0},aset),
          Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
          Con{P113DScalar{N111Alloca{out,16,8}},
          Con{P113DScalar{N111Call{stDst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{72,0}},N111Arg{N111Ptr{},N111Local{b2}},N111Arg{N111U32{},N111Const{2,0}},N111Arg{N111Ptr{},N111Local{o2}},N111Arg{N111U32{},N111Const{2,0}}]}},
          Con{P113DScalar{N111Load{vOut,N111U64{},N111Local{o3},8}},rest}}}},
          isRoot,selfName,paramIdx,fs,fuel,retIdx))
    # Match set (op 73)
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{N111Call{+dst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{73,0}},Con{N111Arg{_,N111Local{+b3}},Con{N111Arg{_,N111Const{3,0}},Nil{}}}}}}},+rest}}}}:
      nt_choose(W13ESAChk,
        agy_str_eq(sym,"p111_rt_op") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(b0,b3) &&
        w13e_val_in(v0,aset) && Bool.not(w13e_val_in(v1,aset)) && Bool.not(w13e_val_in(v2,aset)),
        u => w13e_sa_chk_body(rest,w13e_str_add(aset,dst),isRoot,selfName,paramIdx,fs,fuel,retIdx),
        u => w13e_sa_chk_step_sc(w13e_sa_chk_scalar(N111Store{N111U64{},N111Local{b0},0,v0},aset),
          Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
          Con{P113DScalar{N111Store{N111U64{},N111Local{b2},16,v2}},
          Con{P113DScalar{N111Call{dst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{73,0}},N111Arg{N111Ptr{},N111Local{b3}},N111Arg{N111U32{},N111Const{3,0}}]}},rest}}},
          isRoot,selfName,paramIdx,fs,fuel,retIdx))
    case Con{P113DScalar{N111Call{_,_,"p111_rt_fail",_}},_}:
      W13ESAOk{aset,100,False{}}
    case Con{P113DScalar{stmt},rest}:
      w13e_sa_chk_step_sc(w13e_sa_chk_scalar(stmt,aset),rest,isRoot,selfName,paramIdx,fs,fuel,retIdx)
    case Con{P113DIf{cond,+yes,+no},+rest}:
      nt_choose(W13ESAChk,w13e_val_in(cond,aset),u => W13ESABad{},u =>
        w13e_sa_chk_after_if(
          w13e_sa_chk_body(yes,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx),
          w13e_sa_chk_body(no,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx),
          rest,isRoot,selfName,paramIdx,fs,fuel))
    case Con{P113DCall{+dsts,+target,+args},+rest}:
      +aidx = w13e_vals_single_idx(args,aset,0,99)
      nt_choose(W13ESAChk,U32.is_eq(aidx,99),
        u => nt_choose(W13ESAChk,isRoot && agy_str_eq(target,selfName),v => W13ESABad{},
          v => w13e_sa_chk_body(rest,w13e_str_del_many(aset,dsts),isRoot,selfName,paramIdx,fs,fuel,retIdx)),
        u => nt_choose(W13ESAChk,U32.is_eq(aidx,98) || agy_str_eq(target,selfName),
          v => W13ESABad{},
          v => w13e_sa_chk_after_call(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,fuel),
            dsts,rest,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx)))
    case Con{P113DAgain{args},rest}:
      +aidx = w13e_vals_single_idx(args,aset,0,99)
      nt_choose(W13ESAChk,(isRoot && U32.is_eq(aidx,99)) || (Bool.not(isRoot) && U32.is_eq(aidx,paramIdx)),
        u => W13ESAOk{aset,retIdx,False{}},u => W13ESABad{})
    case Con{P113DResult{vals},rest}:
      +rIdx = w13e_vals_single_idx(vals,aset,0,99)
      nt_choose(W13ESAChk,U32.is_eq(rIdx,98),u => W13ESABad{},u =>
      nt_choose(W13ESAChk,isRoot,
        v => nt_choose(W13ESAChk,U32.is_eq(rIdx,99),w => W13ESAOk{aset,99,False{}},w => W13ESABad{}),
        v =>
          +rm = w13e_sa_merge_ret(retIdx,rIdx)
          nt_choose(W13ESAChk,U32.is_eq(rm,98),w => W13ESABad{},w => W13ESAOk{aset,rm,False{}})))

type W13ESACloneSpec is Data:
  W13ESACloneSpec{+origName: String, +cls: U32, +argIdx: U32}

@unsafe
def w13e_sa_clone_name(+origName: String, +cls: U32, +argIdx: U32) -> String:
  origName ++ "$sa" ++ U32.show(cls) ++ "_" ++ U32.show(argIdx)

@unsafe
def w13e_sa_spec_has(specs: List<&2,W13ESACloneSpec>, +n: String, +c: U32, +a: U32) -> Bool:
  match specs:
    case Nil{}: False{}
    case Con{W13ESACloneSpec{nn,cc,aa},rest}:
      (agy_str_eq(nn,n) && U32.is_eq(cc,c) && U32.is_eq(aa,a)) || w13e_sa_spec_has(rest,n,c,a)

type W13ESARew is Data:
  W13ESARew{+stmts: List<&2,P113DStmt>, +aset: List<&2,String>, +seq: U32, +specs: List<&2,W13ESACloneSpec>}

law w13e_sa_rew_body:
  for body: List<&2,P113DStmt>
  for +aset: List<&2,String>
  for +cls: U32
  for +seq: U32
  for +fs: List<&2,P113DFunction>
  for +specs: List<&2,W13ESACloneSpec>
  W13ESARew

@unsafe
def w13e_sa_rew_prepend(+gen: List<&2,P113DStmt>, rew: W13ESARew) -> W13ESARew:
  match rew:
    case W13ESARew{rs,as2,s2,sp2}: W13ESARew{nt_append(P113DStmt,gen,rs),as2,s2,sp2}

@unsafe
def w13e_sa_rew_cons(+h: P113DStmt, rew: W13ESARew) -> W13ESARew:
  match rew:
    case W13ESARew{rs,as2,s2,sp2}: W13ESARew{Con{h,rs},as2,s2,sp2}

@unsafe
def w13e_sa_chk_ret(chk: W13ESAChk) -> U32:
  match chk:
    case W13ESAOk{_,r,_}: r
    case W13ESABad{}: 99

@unsafe
def w13e_sa_rew_after_if3(cond: N111Value, +ys: List<&2,P113DStmt>, +ns: List<&2,P113DStmt>, r3: W13ESARew) -> W13ESARew:
  match r3:
    case W13ESARew{rs,a3,s3,sp3}: W13ESARew{Con{P113DIf{cond,ys,ns},rs},a3,s3,sp3}

@unsafe
def w13e_sa_branch_live(stmts: List<&2,P113DStmt>) -> Bool:
  match stmts:
    case Nil{}: True{}
    case Con{P113DResult{_},_}: False{}
    case Con{P113DAgain{_},_}: False{}
    case Con{P113DScalar{N111Call{_,_,"p111_rt_fail",_}},_}: False{}
    case Con{_,rest}: w13e_sa_branch_live(rest)

@unsafe
def w13e_sa_rew_after_if2(cond: N111Value, +ys: List<&2,P113DStmt>, +a1: List<&2,String>, r2: W13ESARew,
    +rest: List<&2,P113DStmt>, +cls: U32, +fs: List<&2,P113DFunction>) -> W13ESARew:
  match r2:
    case W13ESARew{+ns,+a2,s2,sp2}:
      +l1 = w13e_sa_branch_live(ys)
      +l2 = w13e_sa_branch_live(ns)
      +am = nt_choose(List<&2,String>,l1 && l2,u => w13e_str_inter(a1,a2),u =>
            nt_choose(List<&2,String>,l1,v => a1,v => a2))
      w13e_sa_rew_after_if3(cond,ys,ns,w13e_sa_rew_body(rest,am,cls,s2,fs,sp2))

@unsafe
def w13e_sa_rew_after_if(cond: N111Value, r1: W13ESARew, +no: List<&2,P113DStmt>, +aset0: List<&2,String>,
    +rest: List<&2,P113DStmt>, +cls: U32, +fs: List<&2,P113DFunction>) -> W13ESARew:
  match r1:
    case W13ESARew{ys,a1,s1,sp1}:
      w13e_sa_rew_after_if2(cond,ys,a1,w13e_sa_rew_body(no,aset0,cls,s1,fs,sp1),rest,cls,fs)

@unsafe
def w13e_sa_rew_body(body,aset,cls,seq,fs,specs):
  match body:
    case Nil{}: W13ESARew{[],aset,seq,specs}
    # Rewrite get (op 72) + two loads from out
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{N111Call{+stDst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{72,0}},Con{N111Arg{_,N111Local{+b2}},Con{N111Arg{_,N111Const{2,0}},Con{N111Arg{_,N111Local{+o2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}}}},
         Con{P113DScalar{N111Load{+l0,N111U64{},N111Local{+o3},+off0}},
         Con{P113DScalar{N111Load{+l1,N111U64{},N111Local{+o4},+off1}},+rest}}}}}}:
      nt_choose(W13ESARew,
        agy_str_eq(sym,"p113_rt_array_pair") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(out,o2) && agy_str_eq(out,o3) && agy_str_eq(out,o4) &&
        w13e_val_in(v0,aset) &&
        ((U32.is_eq(off0,0) && U32.is_eq(off1,8)) || (U32.is_eq(off0,8) && U32.is_eq(off1,0))),
        u =>
          +mask = U32.sub(U32.shln(1,U32.to_nat(cls)),1)
          +aOut = nt_choose(String,U32.is_eq(off0,0),v => l0,v => l1)
          +vOut = nt_choose(String,U32.is_eq(off0,0),v => l1,v => l0)
          +pfx = "w13e_sg_" ++ U32.show(seq) ++ "_"
          +mNm = pfx ++ "m"
          +bNm = pfx ++ "b"
          +pNm = pfx ++ "p"
          +gen : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{mNm,N111U64{},"and",v1,N111Const{mask,0}}},
            P113DScalar{N111Bin{bNm,N111U64{},"shl",N111Local{mNm},N111Const{2,0}}},
            P113DScalar{N111Offset{pNm,v0,N111Local{bNm}}},
            P113DScalar{N111Load{vOut,N111U32{},N111Local{pNm},0}},
            P113DScalar{N111Set{aOut,N111U64{},v0}}]
          w13e_sa_rew_prepend(gen,w13e_sa_rew_body(rest,w13e_str_add(w13e_str_del(w13e_str_del(aset,vOut),stDst),aOut),cls,U32.add(seq,1),fs,specs)),
        u => w13e_sa_rew_cons(P113DScalar{N111Store{N111U64{},N111Local{b0},0,v0}},
          w13e_sa_rew_body(Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
            Con{P113DScalar{N111Alloca{out,16,8}},
            Con{P113DScalar{N111Call{stDst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{72,0}},N111Arg{N111Ptr{},N111Local{b2}},N111Arg{N111U32{},N111Const{2,0}},N111Arg{N111Ptr{},N111Local{o2}},N111Arg{N111U32{},N111Const{2,0}}]}},
            Con{P113DScalar{N111Load{l0,N111U64{},N111Local{o3},off0}},
            Con{P113DScalar{N111Load{l1,N111U64{},N111Local{o4},off1}},rest}}}}},aset,cls,seq,fs,specs)))
    # Rewrite get (op 72) + single load from out+8
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{N111Call{+stDst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{72,0}},Con{N111Arg{_,N111Local{+b2}},Con{N111Arg{_,N111Const{2,0}},Con{N111Arg{_,N111Local{+o2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}}}},
         Con{P113DScalar{N111Load{+vOut,N111U64{},N111Local{+o3},8}},+rest}}}}}:
      nt_choose(W13ESARew,
        agy_str_eq(sym,"p113_rt_array_pair") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(out,o2) && agy_str_eq(out,o3) &&
        w13e_val_in(v0,aset),
        u =>
          +mask = U32.sub(U32.shln(1,U32.to_nat(cls)),1)
          +pfx = "w13e_sg_" ++ U32.show(seq) ++ "_"
          +mNm = pfx ++ "m"
          +bNm = pfx ++ "b"
          +pNm = pfx ++ "p"
          +gen : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{mNm,N111U64{},"and",v1,N111Const{mask,0}}},
            P113DScalar{N111Bin{bNm,N111U64{},"shl",N111Local{mNm},N111Const{2,0}}},
            P113DScalar{N111Offset{pNm,v0,N111Local{bNm}}},
            P113DScalar{N111Load{vOut,N111U32{},N111Local{pNm},0}}]
          w13e_sa_rew_prepend(gen,w13e_sa_rew_body(rest,w13e_str_del(w13e_str_del(aset,vOut),stDst),cls,U32.add(seq,1),fs,specs)),
        u => w13e_sa_rew_cons(P113DScalar{N111Store{N111U64{},N111Local{b0},0,v0}},
          w13e_sa_rew_body(Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
            Con{P113DScalar{N111Alloca{out,16,8}},
            Con{P113DScalar{N111Call{stDst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{72,0}},N111Arg{N111Ptr{},N111Local{b2}},N111Arg{N111U32{},N111Const{2,0}},N111Arg{N111Ptr{},N111Local{o2}},N111Arg{N111U32{},N111Const{2,0}}]}},
            Con{P113DScalar{N111Load{vOut,N111U64{},N111Local{o3},8}},rest}}}},aset,cls,seq,fs,specs)))
    # Rewrite set (op 73)
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{N111Call{+dst,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{73,0}},Con{N111Arg{_,N111Local{+b3}},Con{N111Arg{_,N111Const{3,0}},Nil{}}}}}}},+rest}}}}:
      nt_choose(W13ESARew,
        agy_str_eq(sym,"p111_rt_op") && agy_str_eq(st,"state") &&
        agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && agy_str_eq(b0,b3) && w13e_val_in(v0,aset),
        u =>
          +mask = U32.sub(U32.shln(1,U32.to_nat(cls)),1)
          +pfx = "w13e_ss_" ++ U32.show(seq) ++ "_"
          +mNm = pfx ++ "m"
          +bNm = pfx ++ "b"
          +pNm = pfx ++ "p"
          +gen : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{mNm,N111U64{},"and",v1,N111Const{mask,0}}},
            P113DScalar{N111Bin{bNm,N111U64{},"shl",N111Local{mNm},N111Const{2,0}}},
            P113DScalar{N111Offset{pNm,v0,N111Local{bNm}}},
            P113DScalar{N111Store{N111U32{},N111Local{pNm},0,v2}},
            P113DScalar{N111Set{dst,N111U64{},v0}}]
          w13e_sa_rew_prepend(gen,w13e_sa_rew_body(rest,w13e_str_add(aset,dst),cls,U32.add(seq,1),fs,specs)),
        u => w13e_sa_rew_cons(P113DScalar{N111Store{N111U64{},N111Local{b0},0,v0}},
          w13e_sa_rew_body(Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,v1}},
            Con{P113DScalar{N111Store{N111U64{},N111Local{b2},16,v2}},
            Con{P113DScalar{N111Call{dst,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{73,0}},N111Arg{N111Ptr{},N111Local{b3}},N111Arg{N111U32{},N111Const{3,0}}]}},rest}}},aset,cls,seq,fs,specs)))
    # Drop p111_rt_sink on stack array!
    case Con{P113DScalar{N111Call{+dst,+rt,+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,+v},Nil{}}}}},+rest}:
      nt_choose(W13ESARew,agy_str_eq(sym,"p111_rt_sink") && agy_str_eq(st,"state") && w13e_val_in(v,aset),
        u => w13e_sa_rew_body(rest,w13e_str_del(aset,dst),cls,seq,fs,specs),
        u => w13e_sa_rew_cons(P113DScalar{N111Call{dst,rt,sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U64{},v}]}},
          w13e_sa_rew_body(rest,w13e_str_del(aset,dst),cls,seq,fs,specs)))
    case Con{P113DScalar{+stmt},rest}:
      w13e_sa_rew_cons(P113DScalar{stmt},w13e_sa_rew_body(rest,w13e_sa_scalar_del(stmt,aset),cls,seq,fs,specs))
    case Con{P113DIf{cond,+yes,+no},+rest}:
      w13e_sa_rew_after_if(cond,w13e_sa_rew_body(yes,aset,cls,seq,fs,specs),no,aset,rest,cls,fs)
    case Con{P113DCall{+dsts,+target,+args},+rest}:
      +aidx = w13e_vals_single_idx(args,aset,0,99)
      nt_choose(W13ESARew,U32.is_lt(aidx,98),
        u =>
          +cName = w13e_sa_clone_name(target,cls,aidx)
          +sp1 = nt_choose(List<&2,W13ESACloneSpec>,w13e_sa_spec_has(specs,target,cls,aidx),
            v => specs,v => Con{W13ESACloneSpec{target,cls,aidx},specs})
          +rIdx = w13e_sa_chk_ret(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,3))
          +as1 = w13e_str_del_many(aset,dsts)
          +as2 = nt_choose(List<&2,String>,U32.is_lt(rIdx,nt_count(String,dsts)),
            v => w13e_str_add(as1,w13e_nth_str(dsts,rIdx)),v => as1)
          w13e_sa_rew_cons(P113DCall{dsts,cName,args},w13e_sa_rew_body(rest,as2,cls,seq,fs,sp1)),
        u => w13e_sa_rew_cons(P113DCall{dsts,target,args},w13e_sa_rew_body(rest,w13e_str_del_many(aset,dsts),cls,seq,fs,specs)))
    case Con{h,rest}:
      w13e_sa_rew_cons(h,w13e_sa_rew_body(rest,aset,cls,seq,fs,specs))

@unsafe
def w13e_sa_root_finish(+acc: List<&2,P113DStmt>, +initStmts: List<&2,P113DStmt>, rew: W13ESARew) -> Maybe<&2,W13ESARew>:
  match rew:
    case W13ESARew{rs,as2,s2,sp2}:
      Some{W13ESARew{nt_append(P113DStmt,nt_reverse(P113DStmt,acc,[]),nt_append(P113DStmt,initStmts,rs)),as2,s2,sp2}}

law w13e_sa_try_root_body:
  for body: List<&2,P113DStmt>
  for +fName: String
  for +fs: List<&2,P113DFunction>
  for +specs: List<&2,W13ESACloneSpec>
  for +acc: List<&2,P113DStmt>
  Maybe<&2,W13ESARew>

@unsafe
def w13e_sa_root_chk(chk: W13ESAChk, +arrVar: String, +cls: U32, +initVal: U32,
    +rest: List<&2,P113DStmt>, +fallback: List<&2,P113DStmt>, +s0: P113DStmt,
    +fName: String, +fs: List<&2,P113DFunction>, +specs: List<&2,W13ESACloneSpec>,
    +acc: List<&2,P113DStmt>) -> Maybe<&2,W13ESARew>:
  match chk:
    case W13ESABad{}: w13e_sa_try_root_body(fallback,fName,fs,specs,Con{s0,acc})
    case W13ESAOk{_,_,_}:
      +cnt = U32.shln(1,U32.to_nat(cls))
      +bytes = U32.mul(cnt,4)
      +bufNm = "w13e_sa_" ++ arrVar
      +initStmts : List<&2,P113DStmt> = [
        P113DScalar{N111Alloca{bufNm,bytes,16}},
        P113DScalar{N111Call{"w13e_sf_" ++ arrVar,N111U64{},"w13e_stack_fill32",[
          N111Arg{N111Ptr{},N111Local{bufNm}},
          N111Arg{N111U32{},N111Const{cnt,0}},
          N111Arg{N111U32{},N111Const{initVal,0}}]}},
        P113DScalar{N111Set{arrVar,N111U64{},N111Local{bufNm}}}]
      w13e_sa_root_finish(acc,initStmts,w13e_sa_rew_body(rest,[arrVar],cls,0,fs,specs))

@unsafe
def w13e_sa_root_if_no(hit: Maybe<&2,W13ESARew>, +cond: N111Value, +yes: List<&2,P113DStmt>,
    +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +fName: String, +fs: List<&2,P113DFunction>,
    +specs: List<&2,W13ESACloneSpec>, +acc: List<&2,P113DStmt>) -> Maybe<&2,W13ESARew>:
  match hit:
    case Some{W13ESARew{no2,as2,s2,sp2}}:
      Some{W13ESARew{nt_append(P113DStmt,nt_reverse(P113DStmt,acc,[]),Con{P113DIf{cond,yes,no2},rest}),as2,s2,sp2}}
    case None{}:
      w13e_sa_try_root_body(rest,fName,fs,specs,Con{P113DIf{cond,yes,no},acc})

@unsafe
def w13e_sa_root_if_yes(hit: Maybe<&2,W13ESARew>, +cond: N111Value, +yes: List<&2,P113DStmt>,
    +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +fName: String, +fs: List<&2,P113DFunction>,
    +specs: List<&2,W13ESACloneSpec>, +acc: List<&2,P113DStmt>) -> Maybe<&2,W13ESARew>:
  match hit:
    case Some{W13ESARew{yes2,as2,s2,sp2}}:
      Some{W13ESARew{nt_append(P113DStmt,nt_reverse(P113DStmt,acc,[]),Con{P113DIf{cond,yes2,no},rest}),as2,s2,sp2}}
    case None{}:
      w13e_sa_root_if_no(w13e_sa_try_root_body(no,fName,fs,specs,[]),cond,yes,no,rest,fName,fs,specs,acc)

@unsafe
def w13e_sa_try_root_body(body,fName,fs,specs,acc):
  match body:
    case Nil{}: None{}
    case Con{P113DIf{+cond,+yes,+no},+rest}:
      nt_choose(Maybe<&2,W13ESARew>,List.is_empty(&2,P113DStmt,rest),
        u => w13e_sa_root_if_yes(w13e_sa_try_root_body(yes,fName,fs,specs,[]),cond,yes,no,rest,fName,fs,specs,acc),
        u => w13e_sa_try_root_body(rest,fName,fs,specs,Con{P113DIf{cond,yes,no},acc}))
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,N111Const{+cls,0}}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,N111Const{+initVal,0}}},
         Con{P113DScalar{N111Call{+arrVar,N111U64{},+sym,Con{N111Arg{_,N111Local{+st}},Con{N111Arg{_,N111Const{71,0}},Con{N111Arg{_,N111Local{+b2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}},+rest}}}:
      +ok = agy_str_eq(sym,"p111_rt_op") && agy_str_eq(st,"state") &&
            agy_str_eq(b0,b1) && agy_str_eq(b0,b2) && U32.is_ge(cls,1) && U32.is_le(cls,10)
      +s0 : P113DStmt = P113DScalar{N111Store{N111U64{},N111Local{b0},0,N111Const{cls,0}}}
      +fb : List<&2,P113DStmt> = Con{P113DScalar{N111Store{N111U64{},N111Local{b1},8,N111Const{initVal,0}}},
            Con{P113DScalar{N111Call{arrVar,N111U64{},sym,[N111Arg{N111Ptr{},N111Local{st}},N111Arg{N111U32{},N111Const{71,0}},N111Arg{N111Ptr{},N111Local{b2}},N111Arg{N111U32{},N111Const{2,0}}]}},rest}}
      nt_choose(Maybe<&2,W13ESARew>,ok,
        u => w13e_sa_root_chk(w13e_sa_chk_body(rest,[arrVar],True{},fName,99,fs,3,100),arrVar,cls,initVal,rest,fb,s0,fName,fs,specs,acc),
        u => w13e_sa_try_root_body(fb,fName,fs,specs,Con{s0,acc}))
    case Con{h,rest}: w13e_sa_try_root_body(rest,fName,fs,specs,Con{h,acc})

law w13e_sa_build_clones:
  for todo: List<&2,W13ESACloneSpec>
  for +done: List<&2,W13ESACloneSpec>
  for +fs: List<&2,P113DFunction>
  for +acc: List<&2,P113DFunction>
  for +fuel: U32
  List<&2,P113DFunction>

@unsafe
def w13e_sa_clone_finish(+origName: String, +cls: U32, +argIdx: U32, +params: List<&2,NC_Binding>, +res: U32,
    rew: W13ESARew, +rest: List<&2,W13ESACloneSpec>, +done: List<&2,W13ESACloneSpec>,
    +fs: List<&2,P113DFunction>, +acc: List<&2,P113DFunction>, +fuel: U32) -> List<&2,P113DFunction>:
  match rew:
    case W13ESARew{rb,_,_,newSpecs}:
      +cFn : P113DFunction = P113DFunction{w13e_sa_clone_name(origName,cls,argIdx),params,res,False{},rb}
      w13e_sa_build_clones(nt_append(W13ESACloneSpec,newSpecs,rest),
        Con{W13ESACloneSpec{origName,cls,argIdx},done},fs,Con{cFn,acc},U32.sub(fuel,1))

@unsafe
def w13e_sa_clone_found(found: Maybe<&2,P113DFunction>, +origName: String, +cls: U32, +argIdx: U32,
    +rest: List<&2,W13ESACloneSpec>, +done: List<&2,W13ESACloneSpec>,
    +fs: List<&2,P113DFunction>, +acc: List<&2,P113DFunction>, +fuel: U32) -> List<&2,P113DFunction>:
  match found:
    case None{}: w13e_sa_build_clones(rest,Con{W13ESACloneSpec{origName,cls,argIdx},done},fs,acc,U32.sub(fuel,1))
    case Some{P113DFunction{_,+params,+res,_,body}}:
      +pName = w13e_nth_param(params,argIdx)
      w13e_sa_clone_finish(origName,cls,argIdx,params,res,w13e_sa_rew_body(body,[pName],cls,0,fs,[]),rest,done,fs,acc,fuel)

@unsafe
def w13e_sa_build_clones_go(todo: List<&2,W13ESACloneSpec>, +done: List<&2,W13ESACloneSpec>,
    +fs: List<&2,P113DFunction>, +acc: List<&2,P113DFunction>, +fuel: U32) -> List<&2,P113DFunction>:
  match todo:
    case Nil{}: acc
    case Con{W13ESACloneSpec{+origName,+cls,+argIdx},+rest}:
      nt_choose(List<&2,P113DFunction>,w13e_sa_spec_has(done,origName,cls,argIdx),
        v => w13e_sa_build_clones(rest,done,fs,acc,fuel),
        v => w13e_sa_clone_found(w13e_find_fn(fs,origName),origName,cls,argIdx,rest,done,fs,acc,fuel))

@unsafe
def w13e_sa_build_clones(todo,done,fs,acc,fuel):
  nt_choose(List<&2,P113DFunction>,U32.is_eq(fuel,0),u => acc,u => w13e_sa_build_clones_go(todo,done,fs,acc,fuel))

law w13e_sa_pass_fns:
  for cur: List<&2,P113DFunction>
  for +allFs: List<&2,P113DFunction>
  for +specs: List<&2,W13ESACloneSpec>
  for +acc: List<&2,P113DFunction>
  List<&2,P113DFunction>

@unsafe
def w13e_sa_pass_one(hit: Maybe<&2,W13ESARew>, +name: String, +params: List<&2,NC_Binding>, +res: U32, +pub: Bool,
    +body: List<&2,P113DStmt>, +rest: List<&2,P113DFunction>, +allFs: List<&2,P113DFunction>,
    +specs: List<&2,W13ESACloneSpec>, +acc: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match hit:
    case None{}: w13e_sa_pass_fns(rest,allFs,specs,Con{P113DFunction{name,params,res,pub,body},acc})
    case Some{W13ESARew{rb,_,_,sp2}}:
      w13e_sa_pass_fns(rest,allFs,sp2,Con{P113DFunction{name,params,res,pub,rb},acc})

@unsafe
def w13e_sa_pass_fns(cur,allFs,specs,acc):
  match cur:
    case Nil{}:
      +clones = w13e_sa_build_clones(specs,[],allFs,[],64)
      nt_append(P113DFunction,clones,nt_reverse(P113DFunction,acc,[]))
    case Con{P113DFunction{+name,+params,+res,+pub,+body},rest}:
      w13e_sa_pass_one(w13e_sa_try_root_body(body,name,allFs,specs,[]),name,params,res,pub,body,rest,allFs,specs,acc)

@unsafe
def w13e_opt_private_fns(+fs: List<&2,P113DFunction>, +mode: U32) -> List<&2,P113DFunction>:
  +ents = w13e_ma_collect(fs,[])
  +fs1 = nt_choose(List<&2,P113DFunction>,List.is_empty(&2,W13EMulAddEnt,ents),u => fs,u => w13e_ma_rew_fns(fs,ents))
  nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,2),u => w13e_sa_pass_fns(fs1,fs1,[],[]),u => fs1)

@unsafe
def w13e_opt_cursor(cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,P134Context{ids,idx,direct,ready,view,lookups,heap,+mode},next}:
      P134Private{w13e_opt_private_fns(fs,mode),P134Context{ids,idx,direct,ready,view,lookups,heap,mode},w13e_opt_cursor(next)}
    case P134Public{ss,c,next}: P134Public{ss,c,w13e_opt_cursor(next)}
    case P134Legacy{es,c,next}: P134Legacy{es,c,w13e_opt_cursor(next)}
    case p: p
"""

W13E_INTRINSIC_CODEGEN = """
@unsafe
def w13e_inline_muladd(+name: String, +args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match args code:
    case Con{N111Arg{_,cnt},Con{N111Arg{_,k},Con{N111Arg{_,acc},Con{N111Arg{_,N111Const{+mulC,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +lTop = x181_loop_label(frame) ++ "_ma_" ++ U32.show(next) ++ "_t"
      +lDone = x181_loop_label(frame) ++ "_ma_" ++ U32.show(next) ++ "_d"
      +seq = x188_many([
        x181_load(cnt,ids,frame,x188_reg(10,64)),
        x181_load(k,ids,frame,x188_reg(11,64)),
        x181_load(acc,ids,frame,x188_reg(0,64)),
        x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
        x188_i1("je",X187Target{lDone}),
        x188_label(lTop),
        x188_i2("imull",X187Imm{mulC,0},x188_reg(0,32)),
        x188_i2("addl",x188_reg(11,32),x188_reg(0,32)),
        x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),
        x188_i1("jne",X187Target{lTop}),
        x188_label(lDone),
        x181_store(name,frame,x188_reg(0,64))])
      X181Code{Con{seq,chunks},U32.add(next,2),terminal,error}
    case _ _: x181_error("w13e_muladd_loop bad args",code)

@unsafe
def w13e_inline_stack_fill(+args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match args:
    case Con{N111Arg{_,ptr},Con{N111Arg{_,N111Const{+cnt,0}},Con{N111Arg{_,N111Const{+initVal,0}},Nil{}}}}:
      +qwords = U32.shrn(cnt,1n)
      +seq = x188_many([
        x181_load(ptr,ids,frame,x188_reg(7,64)),
        x188_i2("movabsq",X187Imm{initVal,initVal},x188_reg(0,64)),
        x188_i2("movabsq",X187Imm{qwords,0},x188_reg(1,64)),
        x188_i0("rep_stosq")])
      x181_add(seq,code)
    case _: x181_error("w13e_stack_fill32 bad args",code)
"""


def apply_w13e_patches(text: str) -> str:
    # Start from W12-G baseline
    text = build_w12g.apply_patches(text)

    # 1. editdist notl: emit notl in x185_immediate and x185_physical_immediate for xor $0xffffffff
    #    (All U32.not operands are masked to 32-bit by p112_scalar_operands before xor 0xffffffff.)
    text = replace_exact(
        text,
        """      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>""",
        """      nt_choose(X188Seq,agy_str_eq(op,"xor") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i1("notl",x188_reg(10,32)),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>""",
        "x185_immediate_notl",
    )
    text = replace_exact(
        text,
        """          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}

@unsafe
def x181_binary""",
        """          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))))
    case _: X188Empty{}

@unsafe
def x181_binary""",
        "x185_immediate_notl_close",
    )

    text = replace_exact(
        text,
        """      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>""",
        """      nt_choose(X188Seq,agy_str_eq(op,"xor") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i1("notl",narrow),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>""",
        "x185_phys_immediate_notl",
    )
    text = replace_exact(
        text,
        """          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}

@unsafe
def x185_physical_selected""",
        """          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))))
    case _: X188Empty{}

@unsafe
def x185_physical_selected""",
        "x185_phys_immediate_notl_close",
    )

    # 2. x187 x86-64 encodings for notl, rep_stosq, and SSE2/SSE4.1 vector ops
    text = replace_exact(
        text,
        """@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match family:
    case 9: x187_e_branch(operand,code,extra,offset)
    case 8: w5c_es_f8(x187_e_reg(operand,64,False{}),operand,code)
    case 5: w5c_es_f5(x187_e_rm(operand,8,False{}),operand,code,offset)
    case _: x187_e_error()""",
        W13E_X187_HELPERS + """
@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match family:
    case 9: x187_e_branch(operand,code,extra,offset)
    case 8: w5c_es_f8(x187_e_reg(operand,64,False{}),operand,code)
    case 5: w5c_es_f5(x187_e_rm(operand,8,False{}),operand,code,offset)
    case 19: w13e_es_f19(x187_e_rm(operand,width,False{}),operand,code,extra,offset)
    case _: x187_e_error()""",
        "x187_e_single_notl",
    )

    text = replace_exact(
        text,
        """    case 18: w5c_ep_f18(x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),src,dst,offset)
    case _: x187_e_error()

@unsafe
def x187_e_selected(spec: X187Op, operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match spec operands:
    case X187Op{14,width,code,extra,prefix} Nil{}: x187_e_ok([195])""",
        """    case 18: w5c_ep_f18(x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),src,dst,offset)
    case 20: w13e_ep_movqx(x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),src,dst,offset)
    case 21: w13e_ep_pmulld(x187_e_reg(dst,128,True{}) && x187_e_rm(src,128,True{}),src,dst,offset)
    case 22: w13e_ep_pshift(src,dst,extra,offset)
    case 23: w13e_ep_pshufd0(x187_e_reg(dst,128,True{}) && x187_e_rm(src,128,True{}),src,dst,offset)
    case 24: w13e_ep_movdqu_st(x187_e_reg(src,128,True{}) && x187_e_rm(dst,128,True{}),src,dst,offset)
    case _: x187_e_error()

@unsafe
def x187_e_selected(spec: X187Op, operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match spec operands:
    case X187Op{14,width,code,extra,prefix} Nil{}:
      nt_choose(X187Encoded,U32.is_eq(code,171),u => x187_e_ok([243,72,171]),u => x187_e_ok([195]))""",
        "x187_e_pair_and_selected",
    )

    text = replace_exact(
        text,
        """      nt_choose(X187Op,agy_str_eq(tail,"ovb"),u => X187Op{2,8,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      X187OpNone{})))))))))""",
        """      nt_choose(X187Op,agy_str_eq(tail,"ovb"),u => X187Op{2,8,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovdqa"),u => X187Op{7,128,111,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovq_x"),u => X187Op{20,128,110,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovdqu_st"),u => X187Op{24,128,127,0,243},u =>
      X187OpNone{}))))))))))))""",
        "x202o_dispatch_m",
    )

    text = replace_exact(
        text,
        """    case 112:
      nt_choose(X187Op,agy_str_eq(tail,"opq"),u => X187Op{8,64,88,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ushq"),u => X187Op{8,64,80,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"xor"),u => X187Op{7,128,239,0,102},u =>
      X187OpNone{})))""",
        """    case 112:
      nt_choose(X187Op,agy_str_eq(tail,"opq"),u => X187Op{8,64,88,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ushq"),u => X187Op{8,64,80,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"xor"),u => X187Op{7,128,239,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"addd"),u => X187Op{7,128,254,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"subd"),u => X187Op{7,128,250,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"and"),u => X187Op{7,128,219,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"or"),u => X187Op{7,128,235,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"unpcklqdq"),u => X187Op{7,128,108,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"mulld"),u => X187Op{21,128,64,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"slld"),u => X187Op{22,128,114,6,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"srld"),u => X187Op{22,128,114,2,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"shufd0"),u => X187Op{23,128,112,0,102},u =>
      X187OpNone{}))))))))))))""",
        "x202o_dispatch_p",
    )

    text = replace_exact(
        text,
        """    case 114:
      nt_choose(X187Op,agy_str_eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"olw"),u => X187Op{3,32,0,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orw"),u => X187Op{3,32,0,1,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"oll"),u => X187Op{3,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orl"),u => X187Op{3,32,0,1,0},u =>
      X187OpNone{})))))""",
        """    case 110:
      nt_choose(X187Op,agy_str_eq(tail,"otl"),u => X187Op{19,32,247,2,0},u =>
      X187OpNone{})
    case 114:
      nt_choose(X187Op,agy_str_eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ep_stosq"),u => X187Op{14,0,171,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"olw"),u => X187Op{3,32,0,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orw"),u => X187Op{3,32,0,1,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"oll"),u => X187Op{3,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orl"),u => X187Op{3,32,0,1,0},u =>
      X187OpNone{}))))))""",
        "x202o_dispatch_n_r",
    )

    # 3. Wire w13e_loop_opt into w7_post_select_full
    text = replace_exact(
        text,
        """  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(xmm,[])""",
        """  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(w13e_loop_opt(hasLoop,hasXmm,xmm),[])""",
        "wire_w13e_loop_opt",
    )

    text = replace_exact(
        text,
        """@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>""",
        W13E_LOOP_OPT_CODE + """
@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>""",
        "insert_w13e_loop_opt",
    )

    # 4. Wire W13E_INTRINSIC_CODEGEN into x195s_original, x185_t_scalar, x190_l_scalar_ids
    text = replace_exact(
        text,
        """@unsafe
def x195s_original(stmt: N111Stmt, ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match stmt:
    case N111Call{name,typ,symbol,args}: x195s_previous(name,typ,symbol,args,ids,frame,code)
    case _: x181_error("sqrt specialization expected scalar call",code)""",
        W13E_INTRINSIC_CODEGEN + """
@unsafe
def x195s_original(stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match stmt:
    case N111Call{+name,typ,+symbol,+args}:
      nt_choose(X181Code,agy_str_eq(symbol,"w13e_muladd_loop"),
        u => w13e_inline_muladd(name,args,ids,frame,code),
        u => nt_choose(X181Code,agy_str_eq(symbol,"w13e_stack_fill32"),
          v => w13e_inline_stack_fill(args,ids,frame,code),
          v => x195s_previous(name,typ,symbol,args,ids,frame,code)))
    case _: x181_error("sqrt specialization expected scalar call",code)""",
        "wire_w13e_intrinsics_codegen",
    )

    text = replace_exact(
        text,
        """@unsafe
def x185_t_scalar(stmt: N111Stmt, scan: X185TScan) -> X185TScan:""",
        """@unsafe
def w13e_t_args(args: List<&2,N111Arg>, scan: X185TScan) -> X185TScan:
  match args:
    case Nil{}: scan
    case Con{N111Arg{_,v},rest}: w13e_t_args(rest,x185_t_read(v,scan))

@unsafe
def x185_t_scalar(stmt: N111Stmt, +scan: X185TScan) -> X185TScan:""",
        "add_w13e_t_args",
    )

    text = replace_exact(
        text,
        """    case N111Call{+name,typ,symbol,+args}:
      x186_t_inline_call(name,args,scan,x186_inline_op(N111Call{name,typ,symbol,args}))""",
        """    case N111Call{+name,typ,+symbol,+args}:
      nt_choose(X185TScan,agy_str_eq(symbol,"w13e_muladd_loop"),
        u => x185_t_next(x185_t_event(name,True{},w13e_t_args(args,scan))),
        u => x186_t_inline_call(name,args,scan,x186_inline_op(N111Call{name,typ,symbol,args})))""",
        "wire_w13e_muladd_transient",
    )

    text = replace_exact(
        text,
        """    case N111Call{name,typ,symbol,args}:
      x190_l_inline(x186_inline_op(stmt),x190_l_args(args,ids),x190_l_bit(name,ids),flow,env)""",
        """    case N111Call{+name,typ,+symbol,+args}:
      nt_choose(X190LFlow,agy_str_eq(symbol,"w13e_muladd_loop"),
        u => x190_l_event(x190_l_args(args,ids),x190_l_bit(name,ids),flow,env),
        u => x190_l_inline(x186_inline_op(N111Call{name,typ,symbol,args}),x190_l_args(args,ids),x190_l_bit(name,ids),flow,env))""",
        "wire_w13e_muladd_live",
    )

    # 5. Wire W13E_P113D_PASSES into agy_da_annotate
    text = replace_exact(
        text,
        """@unsafe
def agy_da_annotate(+prepared: P169Prepared) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +entries = nt_choose(List<&2,KDef>,String.is_empty(error),u => agy_da_scan_cursor(cursor,[]),u => [])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_da_cursor(entries,cursor),u => cursor),error}""",
        W13E_P113D_PASSES + """
@unsafe
def agy_da_annotate(+prepared: P169Prepared) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +c0 = nt_choose(P134Cursor,String.is_empty(error),u => w13e_opt_cursor(cursor),u => cursor)
      +entries = nt_choose(List<&2,KDef>,String.is_empty(error),u => agy_da_scan_cursor(c0,[]),u => [])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_da_cursor(entries,c0),u => c0),error}""",
        "wire_w13e_p113d_passes",
    )

    return text


def main() -> int:
    TMP.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    src = ORIG.read_text(encoding="utf-8")
    patched = apply_w13e_patches(src)
    COMP_OUT.write_text(patched, encoding="utf-8")
    diff = "".join(
        difflib.unified_diff(
            src.splitlines(keepends=True),
            patched.splitlines(keepends=True),
            fromfile="selfhost/build/agy/wave11_unified/compiler.bend",
            tofile="selfhost/build/agy/wave11_unified/compiler.bend (w13e)",
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

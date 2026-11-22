#!/usr/bin/env python3
"""Wave 5C Track W5C-R1: 100% general runtime optimizations.

Passes:
  1. General Post-Joint Transient Register Allocation (`w5c_post_joint_transient`
     in `x190_j_checked`): when joint graph-coloring regalloc hits its 32-candidate
     bitmask ceiling (`len(names) == 32`), run a sound post-joint linear-scan
     transient pass over all remaining `X181Stack` single-region locals using
     any transient registers (`%rdi/%rsi/%rdx/%r8/%r9`) whose joint-allocated
     occupants are either absent or strictly confined to disjoint single-region
     intervals (never live across `Again`, `params`, `setup`, branches, or calls).
  2. General x86-64 GPR Peepholes in `w5b_peep` (100% orthogonal to W5C-C1):
     - Load-bounce collapse: `movq d(%rbp), %r10/%r11; movq %r10/%r11, %rD`
       (scratch dead) -> `movq d(%rbp), %rD`.
     - 64-bit immediate ALU-bounce collapse: `movq %rA, %r10/%r11; addq/subq $c, %r10/%r11; movq %r10/%r11, %rA`
       (scratch dead) -> `addq/subq $c, %rA`.
     - Post-`movzbl` copy zero-ext elimination: `movzbl %r8, %rD32; movq %rD, %rB; movl %rB32, %rB32`
       -> `movzbl %r8, %rD32; movq %rD, %rB`.

Strictly 100% general — zero benchmark matchers, zero runtime edits,
zero touches to W5C-C1 surfaces (`w4b_reg_dead`, `w4b_copy_peep`,
`w4_post_select` skip-flags, `x187_e_single`/`x187_e_pair`).
"""

import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


PASS1_HELPERS = r"""# W5C-R1: General post-joint transient register allocation for overflow locals
# when joint graph-coloring reaches its 32-candidate bitmask cap.
type W5CIntv is Data:
  W5CIntv{+first: U32, +last: U32}

type W5CPJState is Data:
  W5CPJState{+ends: List<&2,U32>, +occ: List<&2,List<&2,W5CIntv>>}

def w5c_intv_disjoint(+first: U32, +last: U32, list: List<&2,W5CIntv>) -> Bool:
  match list:
    case Nil{}: True{}
    case Con{W5CIntv{a,b},rest}:
      (U32.is_lt(last,a) || U32.is_lt(b,first)) && w5c_intv_disjoint(first,last,rest)

@unsafe
def w5c_occ_add(occ: List<&2,List<&2,W5CIntv>>, +idx: U32, +intv: W5CIntv) -> List<&2,List<&2,W5CIntv>>:
  match occ:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,List<&2,W5CIntv>>,U32.is_eq(idx,0),
        u => Con{Con{intv,head},rest},
        u => Con{head,w5c_occ_add(rest,U32.sub(idx,1),intv)})

@unsafe
def w5c_pj_collect_one(+name: String, +color: U32, +bit: U32, +header: U32, +ranges: KDef, +st: W5CPJState) -> W5CPJState:
  match st:
    case W5CPJState{+ends,+occ}:
      nt_choose(W5CPJState,U32.is_ge(color,4) && U32.is_lt(color,9),
        u =>
          +k = U32.sub(color,4)
          +r = p111v_get(ranges,name)
          nt_choose(W5CPJState,U32.is_eq(U32.and(header,bit),0) && agy_str_eq(dk(r),"X185TRange"),
            v => W5CPJState{ends,w5c_occ_add(occ,k,W5CIntv{da(r),dx(r)})},
            v => W5CPJState{x185_t_end(ends,k,4294967295),occ}),
        u => st)

@unsafe
def w5c_pj_collect(names: List<&2,String>, +groups: List<&2,U32>, +header: U32,
    +ranges: KDef, +bit: U32, st: W5CPJState) -> W5CPJState:
  match names:
    case Nil{}: st
    case Con{+name,rest}:
      w5c_pj_collect(rest,groups,header,ranges,U32.shl(bit),
        w5c_pj_collect_one(name,x190_j_home(groups,bit,0),bit,header,ranges,st))

law w5c_pj_pick:
  for ends: List<&2,U32>
  for occ: List<&2,List<&2,W5CIntv>>
  for +first: U32
  for +last: U32
  for +index: U32
  U32

@unsafe
def w5c_pj_pick_step(+endPos: U32, +restE: List<&2,U32>, occ: List<&2,List<&2,W5CIntv>>,
    +first: U32, +last: U32, +index: U32) -> U32:
  match occ:
    case Nil{}: 5
    case Con{olist,+restO}:
      nt_choose(U32,U32.is_lt(endPos,first) && w5c_intv_disjoint(first,last,olist),
        u => index,
        u => w5c_pj_pick(restE,restO,first,last,U32.inc(index)))

@unsafe
def w5c_pj_pick(ends,occ,first,last,index):
  match ends:
    case Nil{}: 5
    case Con{endPos,restE}: w5c_pj_pick_step(endPos,restE,occ,first,last,index)

law w5c_pj_place:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  for +occ: List<&2,List<&2,W5CIntv>>
  for +maxSpan: U32
  X181Frame

@unsafe
def w5c_pj_chosen(+name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +occ: List<&2,List<&2,W5CIntv>>, +maxSpan: U32, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => w5c_pj_place(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last),occ,maxSpan),
    u => w5c_pj_place(rest,ranges,frame,ends,occ,maxSpan))

@unsafe
def w5c_pj_place(names,ranges,frame,ends,occ,maxSpan):
  match names:
    case Nil{}: frame
    case Con{+name,+rest}:
      match frame:
        case X181Frame{+slots,bytes,calls,params,symbol}:
          +range = p111v_get(ranges,name)
          +spanOk = U32.is_eq(maxSpan,0) || U32.is_le(U32.sub(dx(range),da(range)),maxSpan)
          nt_choose(X181Frame,agy_str_eq(dk(range),"X185TRange") &&
              agy_str_eq(dk(p111v_get(slots,name)),"X181Stack") && spanOk,
            u => w5c_pj_chosen(name,rest,ranges,frame,ends,occ,maxSpan,
              w5c_pj_pick(ends,occ,da(range),dx(range),0),dx(range)),
            u => w5c_pj_place(rest,ranges,frame,ends,occ,maxSpan))

@unsafe
def w5c_pj_run(frame: X181Frame, +ranges: KDef, allNames: List<&2,String>, +position: U32, st: W5CPJState) -> X181Frame:
  match st:
    case W5CPJState{ends,occ}:
      +cap = nt_choose(U32,U32.is_gt(position,256),u => 48,u => 0)
      w5c_pj_place(nt_reverse(String,allNames,[]),ranges,frame,ends,occ,cap)

@unsafe
def w5c_pj_apply(frame: X181Frame, +names: List<&2,String>, +groups: List<&2,U32>,
    +header: U32, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{+ranges,allNames,+position,region}:
      w5c_pj_run(frame,ranges,allNames,position,
        w5c_pj_collect(names,groups,header,ranges,1,W5CPJState{[0,0,0,0,0],[[],[],[],[],[]]}))

@unsafe
def w5c_post_joint_transient(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +groups: List<&2,U32>, +header: U32) -> X181Frame:
  nt_choose(X181Frame,x185_transient_enabled() && U32.is_eq(nt_count(String,names),32) &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => w5c_pj_apply(frame,names,groups,header,x185_t_body(body,
      X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0})),
    u => frame)

"""

PASS1_OLD = r"""@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups),
    u => x190_j_install(names,groups,1,frame),u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])))

@unsafe
def x190_j_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_j_graphed(frame,params,setup,body,registerBody,names,ids,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x190_allocate_legacy(frame,params,setup,body,registerBody))"""

PASS1_NEW = PASS1_HELPERS + r"""@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>, +header: U32) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups),
    u => w5c_post_joint_transient(x190_j_install(names,groups,1,frame),params,setup,body,names,groups,header),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, +header: U32, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])),header)

@unsafe
def x190_j_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_j_graphed(frame,params,setup,body,registerBody,names,ids,header,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x190_allocate_legacy(frame,params,setup,body,registerBody))"""


PASS2_HELPERS = r"""# W5C-R1: General x86-64 load-bounce & 64-bit imm ALU-bounce peepholes
@unsafe
def w5c_try_load_bounce(+d1: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{+rS,64,False{}},Con{X187Reg{+rD,64,False{}},Nil{}}}}},+tail}:
      +ok = (U32.is_eq(rA,10) || U32.is_eq(rA,11)) && agy_str_eq(op1,"movq") &&
            U32.is_eq(rS,rA) && Bool.not(U32.is_eq(rD,rA)) && w5b_reg_dead_fast(rA,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rD,64)]}},tail}},
        u => None{})
    case _: None{}

@unsafe
def w5c_is_imm(op: X187Operand) -> Bool:
  match op:
    case X187Imm{_,_}: True{}
    case _: False{}

@unsafe
def w5c_is_self_movl(inst: X187Parsed, +rD: U32) -> Bool:
  match inst:
    case PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}}:
      agy_str_eq(op1,"movl") && U32.is_eq(r1,rD) && U32.is_eq(r2,rD)
    case _: False{}

@unsafe
def w5c_movq_dst(inst: X187Parsed, +rD: U32) -> U32:
  match inst:
    case PInst{X187Instruction{op1,Con{X187Reg{r1,64,False{}},Con{X187Reg{r2,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op1,"movq") && U32.is_eq(r1,rD),u => r2,u => 99)
    case _: 99

@unsafe
def w5c_movzbl_copy(+rB: U32, +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tail:
    case Con{+i2,+tail2}:
      nt_choose(List<&2,X187Parsed>,U32.is_lt(rB,16) && w5c_is_self_movl(i2,rB),
        u => w5b_peep(Con{i1,tail2},fnItems,Con{i0,acc}),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case Nil{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_try_alu64_bounce(+rA: U32, +rB: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{+op1,Con{+imm,Con{X187Reg{+r1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+r2,64,False{}},Con{X187Reg{+r3,64,False{}},Nil{}}}}},+tail}}:
      +ok = (U32.is_eq(rB,10) || U32.is_eq(rB,11)) && Bool.not(U32.is_eq(rA,rB)) &&
            (agy_str_eq(op1,"addq") || agy_str_eq(op1,"subq")) && w5c_is_imm(imm) &&
            U32.is_eq(r1,rB) && agy_str_eq(op2,"movq") && U32.is_eq(r2,rB) && U32.is_eq(r3,rA) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{op1,[imm,x188_reg(rA,64)]}},tail}},
        u => None{})
    case _: None{}

"""

PASS2_OLD = r"""@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w5b_try_spill_bounce(rA,rB,rest,fnItems)))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)

@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op1,"movl") && U32.is_eq(r1,rD) && U32.is_eq(r2,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_movq(rA,rB,i0,rest,fnItems,acc),
        u => nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
          v => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
          v => w5b_peep(rest,fnItems,Con{i0,acc})))
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movzbl"),
        u => w5b_peep_movzbl(rD,i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_apply(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))"""

PASS2_NEW = PASS2_HELPERS + r"""@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w4c_or_peep_opt(w5b_try_spill_bounce(rA,rB,rest,fnItems),
            q => w5c_try_alu64_bounce(rA,rB,rest,fnItems))))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)

@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{+i1,+tail}:
      nt_choose(List<&2,X187Parsed>,w5c_is_self_movl(i1,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5c_movzbl_copy(w5c_movq_dst(i1,rD),i0,i1,rest,tail,fnItems,acc))
    case Nil{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_movq(rA,rB,i0,rest,fnItems,acc),
        u => nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
          v => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
          v => w5b_peep(rest,fnItems,Con{i0,acc})))
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movzbl"),
        u => w5b_peep_movzbl(rD,i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_apply(w4c_or_peep_opt(w5b_try_dup_square(d1,rA,rest,fnItems),
          v => w5c_try_load_bounce(d1,rA,rest,fnItems)),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))"""


def apply(src: str) -> str:
    out = replace_once(src, PASS1_OLD, PASS1_NEW, "pass1_post_joint_transient")
    if "def w5c_bp_movq_c(" in out:
        # Compose cleanly on top of W5C-C1's zero-closure w5b_peep + skip-unchanged w5c_bp_*_c
        out = replace_once(
            out,
            """@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w5b_try_spill_bounce(rA,rB,rest,fnItems)))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)""",
            PASS2_HELPERS + """@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w4c_or_peep_opt(w5b_try_spill_bounce(rA,rB,rest,fnItems),
            q => w5c_try_alu64_bounce(rA,rB,rest,fnItems))))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)""",
            "pass2_c1_movq",
        )
        out = replace_once(
            out,
            """@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      w5c_peep_mz_if(U32.is_eq(r1,rD) && U32.is_eq(r2,rD) && String.eq(op1,"movl"),i0,tail,rest,fnItems,acc)
    case _: w5b_peep(rest,fnItems,Con{i0,acc})""",
            """@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{+i1,+tail}:
      nt_choose(List<&2,X187Parsed>,w5c_is_self_movl(i1,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5c_movzbl_copy(w5c_movq_dst(i1,rD),i0,i1,rest,tail,fnItems,acc))
    case Nil{}: w5b_peep(rest,fnItems,Con{i0,acc})""",
            "pass2_c1_movzbl",
        )
        out = replace_once(
            out,
            """    case True{}: w5b_peep_apply(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc)""",
            """    case True{}: w5b_peep_apply(w4c_or_peep_opt(w5b_try_dup_square(d1,rA,rest,fnItems),
      v => w5c_try_load_bounce(d1,rA,rest,fnItems)),i0,rest,fnItems,acc)""",
            "pass2_c1_ds",
        )
        out = replace_once(
            out,
            """@unsafe
def w5c_bp_movq_c(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w5b_try_spill_bounce(rA,rB,rest,fnItems)))))
  w5c_bp_apply_c(h,i0,rest,fnItems,acc)""",
            """@unsafe
def w5c_bp_movq_c(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w4c_or_peep_opt(w5b_try_spill_bounce(rA,rB,rest,fnItems),
            q => w5c_try_alu64_bounce(rA,rB,rest,fnItems))))))
  w5c_bp_apply_c(h,i0,rest,fnItems,acc)""",
            "pass2_c1_movq_c",
        )
        out = replace_once(
            out,
            """@unsafe
def w5c_bp_movzbl_c(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      w5c_bp_mz_drop_c(U32.is_eq(r1,rD) && U32.is_eq(r2,rD) && String.eq(op1,"movl"),i0,tail,rest,fnItems,acc)
    case _: w5c_bp_c(rest,fnItems,Con{i0,acc})""",
            """@unsafe
def w5c_movzbl_copy_c(+rB: U32, +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match tail:
    case Con{+i2,+tail2}:
      nt_choose(W5BGprOut,U32.is_lt(rB,16) && w5c_is_self_movl(i2,rB),
        u => W5BGprChanged{w5b_peep(Con{i1,tail2},fnItems,Con{i0,acc})},
        u => w5c_bp_c(rest,fnItems,Con{i0,acc}))
    case Nil{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_movzbl_c(+rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match rest:
    case Con{+i1,+tail}:
      nt_choose(W5BGprOut,w5c_is_self_movl(i1,rD),
        u => W5BGprChanged{w5b_peep(tail,fnItems,Con{i0,acc})},
        u => w5c_movzbl_copy_c(w5c_movq_dst(i1,rD),i0,i1,rest,tail,fnItems,acc))
    case Nil{}: w5c_bp_c(rest,fnItems,Con{i0,acc})""",
            "pass2_c1_movzbl_c",
        )
        out = replace_once(
            out,
            """    case True{}: w5c_bp_apply_c(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc)""",
            """    case True{}: w5c_bp_apply_c(w4c_or_peep_opt(w5b_try_dup_square(d1,rA,rest,fnItems),
      v => w5c_try_load_bounce(d1,rA,rest,fnItems)),i0,rest,fnItems,acc)""",
            "pass2_c1_ds_c",
        )
    else:
        out = replace_once(out, PASS2_OLD, PASS2_NEW, "pass2_peepholes")
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    args = ap.parse_args()
    src_p = Path(args.src)
    dst_p = Path(args.dst)
    dst_p.parent.mkdir(parents=True, exist_ok=True)
    out = apply(src_p.read_text())
    dst_p.write_text(out)
    print(f"Wrote {dst_p} ({len(out)} bytes)")


if __name__ == "__main__":
    main()

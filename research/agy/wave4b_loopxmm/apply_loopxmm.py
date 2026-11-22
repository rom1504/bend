#!/usr/bin/env python3
"""Wave 4 Phase 2 Track W4-7: Call-Free Full-XMM (xmm2..15) Loop Allocator
+ Magic-Constant LICM + Copy-Forwarding Peephole + Bottom-Tested Loop Rotation.

100% general compiler passes — zero benchmark-specific pattern matchers.
Preserves exact IEEE-754 F32 semantics (no FMA contraction).
"""

import argparse
from pathlib import Path


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def apply_all(src_text: str, min_start_reg: int = 8) -> str:
    t = src_text

    # ------------------------------------------------------------------
    # PASS 1: Call-Free Full-XMM Loop Allocator (xmm2..xmm15) + Hot Consts
    # ------------------------------------------------------------------
    old_capped = """@unsafe
def x186_x_scanned_capped(scan: X186XScan) -> KDef:
  match scan:
    case X186XScan{X185TScan{ranges,names,position,region},canonical}:
      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),[0,0,0,0,0,0,0,0])"""

    new_capped = """@unsafe
def w4b_zeros(+n: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => [],u => Con{0,w4b_zeros(U32.sub(n,1))})

@unsafe
def x186_x_scanned_capped(scan: X186XScan, +tempRegs: U32) -> KDef:
  match scan:
    case X186XScan{X185TScan{ranges,names,position,region},canonical}:
      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),w4b_zeros(tempRegs))"""

    t = replace_exact(t, old_capped, new_capped, "x186_x_scanned_capped")

    old_homes_capped = """@unsafe
def x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: List<&2,U32>) -> KDef:
  x186_x_scanned_capped(w2b_x_scan(nodes,cidx,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))"""

    new_homes_capped = """@unsafe
def x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: List<&2,U32>, +tempRegs: U32) -> KDef:
  x186_x_scanned_capped(w2b_x_scan(nodes,cidx,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}),tempRegs)"""

    t = replace_exact(t, old_homes_capped, new_homes_capped, "x186_x_homes_capped")

    # Bump w2_dead_in fuel in w2_x_emit_branch_or_node from 64 to 512 so large loops
    # (like nbody loop3) fuse their loop-exit integer comparison & drop dominated n!=0 checks.
    old_branch_fuel = """    case Con{X186FloatPlain{P113DScalar{N111Bin{+c,+typ,+op,+left,+right}}},
         Con{X186FloatBranch{N111Local{+cb},+yes,+no},+rest}}:
      nt_choose(X181Code,agy_str_eq(c,cb) && Bool.not(String.is_empty(w2_int_inv(op))) &&
          w2_dead_in(c,yes,[rest],64) && w2_dead_in(c,no,[rest],64),"""

    new_branch_fuel = """    case Con{X186FloatPlain{P113DScalar{N111Bin{+c,+typ,+op,+left,+right}}},
         Con{X186FloatBranch{N111Local{+cb},+yes,+no},+rest}}:
      nt_choose(X181Code,agy_str_eq(c,cb) && Bool.not(String.is_empty(w2_int_inv(op))) &&
          w2_dead_in(c,yes,[rest],512) && w2_dead_in(c,no,[rest],512),"""

    t = replace_exact(t, old_branch_fuel, new_branch_fuel, "w2_x_emit_branch_or_node_fuel")

    old_dom_fuel = """          w2_dead_in(c2,yes2,[tail2],64),"""
    new_dom_fuel = """          w2_dead_in(c2,yes2,[tail2],512),"""
    t = replace_exact(t, old_dom_fuel, new_dom_fuel, "w2_skip_dom_ne_fuel")

    # Replace w2b_plan_after_carried + w4_xl_build_loop with dynamic xmm2..xmm15 partitioning
    # and hot-loop-only constant collection.
    old_build_loop = """@unsafe
def w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  match plan:
    case W2XLoopPlan{homes,pre,carried,active}:
      match carried:
        case Con{W4Carried{+cname,+cidx,+cxmm},Nil{}}:
          +st1 = w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
                   w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,U32.inc(cxmm)}))
          w4_xl_pick_more(tparams,0,cidx,tparams,nodes,ids,frame,st1,[W4Carried{cname,cidx,cxmm}])
        case _:
          w4_xl_alloc_plan(w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
            w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,10})))

@unsafe
def w4_xl_build_loop(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +probe = w2b_plan_after_carried(
             w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,W2XLAlloc{missing(),X188Empty{},10}),
             tparams,nodes,ids,frame)
  +cidxs = w4_carried_idxs(w4_plan_carried(probe))
  w2b_plan_after_carried(
    w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,
      W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidxs),X188Empty{},10}),
    tparams,nodes,ids,frame)"""

    new_build_loop = f"""law w4b_xl_hot_consts:
  for nodes: List<&2,X186FloatNode>
  for +acc: List<&2,U32>
  List<&2,U32>

@unsafe
def w4b_xl_hot_consts(nodes,acc):
  match nodes:
    case Nil{{}}: acc
    case Con{{X186FloatValues{{dest,+id,l,r}},+rest}}:
      nt_choose(List<&2,U32>,U32.is_eq(id,23),
        u => w4b_xl_hot_consts(rest,acc),
        u => w4b_xl_hot_consts(rest,w2_xl_add_const(r,w2_xl_add_const(l,acc))))
    case Con{{X186FloatBranch{{c,+y,+n}},+rest}}:
      +inRest = w2_xl_has_again(rest)
      +acc1 = nt_choose(List<&2,U32>,inRest || w2_xl_has_again(y),u => w4b_xl_hot_consts(y,acc),u => acc)
      +acc2 = nt_choose(List<&2,U32>,inRest || w2_xl_has_again(n),u => w4b_xl_hot_consts(n,acc1),u => acc1)
      w4b_xl_hot_consts(rest,acc2)
    case Con{{h,rest}}: w4b_xl_hot_consts(rest,acc)

@unsafe
def w4b_u32_len(xs: List<&2,U32>, +acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case Con{{_,rest}}: w4b_u32_len(rest,U32.inc(acc))

@unsafe
def w4b_xl_count_params(params: List<&2,String>, +idx: U32, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +acc: U32) -> U32:
  match params:
    case Nil{{}}: acc
    case Con{{+p,rest}}:
      +isInv = w2_xl_param_inv(p,idx,nodes) && w2_xl_float_used(p,nodes)
      +isCar = w4_xl_carried_ok(p,idx,False{{}},tparams,nodes)
      w4b_xl_count_params(rest,U32.inc(idx),tparams,nodes,
        nt_choose(U32,isInv || isCar,u => U32.inc(acc),u => acc))

@unsafe
def w4b_xl_start_reg(+tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>, +hotConsts: List<&2,U32>) -> U32:
  +need = U32.add(w4b_xl_count_params(tparams,0,tparams,nodes,0),w4b_u32_len(hotConsts,0))
  nt_choose(U32,U32.is_le(need,6),u => 10,u =>
    nt_choose(U32,U32.is_ge(need,{16 - min_start_reg}),u => {min_start_reg},u => U32.sub(16,need)))

@unsafe
def w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +hotConsts: List<&2,U32>, +startReg: U32, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  match plan:
    case W2XLoopPlan{{homes,pre,carried,active}}:
      match carried:
        case Con{{W4Carried{{+cname,+cidx,+cxmm}},Nil{{}}}}:
          +st1 = w2_xl_assign_consts(hotConsts,
                   w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{{homes,pre,U32.inc(cxmm)}}))
          w4_xl_pick_more(tparams,0,cidx,tparams,nodes,ids,frame,st1,[W4Carried{{cname,cidx,cxmm}}])
        case _:
          w4_xl_alloc_plan(w2_xl_assign_consts(hotConsts,
            w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{{homes,pre,startReg}})))

@unsafe
def w4_xl_build_loop(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +hotConsts = nt_reverse(U32,w4b_xl_hot_consts(nodes,[]),[])
  +startReg = w4b_xl_start_reg(tparams,nodes,hotConsts)
  +tempRegs = U32.sub(startReg,2)
  +probe = w2b_plan_after_carried(
             w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,W2XLAlloc{{missing(),X188Empty{{}},startReg}}),
             tparams,nodes,hotConsts,startReg,ids,frame)
  +cidxs = w4_carried_idxs(w4_plan_carried(probe))
  w2b_plan_after_carried(
    w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,
      W2XLAlloc{{x186_x_homes_capped(params,setup,nodes,cidxs,tempRegs),X188Empty{{}},startReg}}),
    tparams,nodes,hotConsts,startReg,ids,frame)"""

    t = replace_exact(t, old_build_loop, new_build_loop, "w4_xl_build_loop")

    # ------------------------------------------------------------------
    # PASS 2 + 3 + 4: Copy-Forwarding Peephole + Magic-Constant LICM
    #                 + Bottom-Tested Tail-Loop Rotation in w4_post_select
    # (Uses strictly shallow single-level matches — zero case-tree blowup!)
    # ------------------------------------------------------------------
    old_post_select = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat = w4_peep_flat([code],[])
  +peeped = x188_finish(w4_peep_list(flat,[]))
  w4_leaf_shrink(w4_peep_flat([peeped],[]),peeped)"""

    new_post_select = """# W4-7 Pass 2: General copy-forwarding & flag-reuse peephole.
@unsafe
def w4b_op_reads_reg(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,False{}}: U32.is_eq(i,r)
    case X187Mem{b,_}: U32.is_eq(b,r)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,r) || U32.is_eq(i,r)
    case _: False{}

@unsafe
def w4b_args_read_reg(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4b_op_reads_reg(r,a) || w4b_args_read_reg(r,rest)

@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"leaq") || agy_str_eq(op,"movzbl") || agy_str_eq(op,"movd")

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"addq") || agy_str_eq(op,"subl") || agy_str_eq(op,"subq") ||
  agy_str_eq(op,"imull") || agy_str_eq(op,"imulq") || agy_str_eq(op,"andl") || agy_str_eq(op,"andq") ||
  agy_str_eq(op,"orl") || agy_str_eq(op,"orq") || agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq") ||
  agy_str_eq(op,"shll") || agy_str_eq(op,"shlq") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shrq") ||
  agy_str_eq(op,"sarl") || agy_str_eq(op,"sarq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"cmpq") ||
  agy_str_eq(op,"testl") || agy_str_eq(op,"testq")

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"subl") || agy_str_eq(op,"imull") ||
  agy_str_eq(op,"andl") || agy_str_eq(op,"orl") || agy_str_eq(op,"xorl")

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  Bool

@unsafe
def w4b_find_label(+lbl: String, items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l,lbl),u => Some{rest},u => w4b_find_label(lbl,rest))
    case Con{_,rest}: w4b_find_label(lbl,rest)

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops)
    case None{}: False{}

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      nt_choose(Bool,w4b_op_reads_reg(r,src),w => False{},w =>
        nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),x => True{},
          x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)))
    case _:
      nt_choose(Bool,w4b_args_read_reg(r,args),w => False{},
        w => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}:
      nt_choose(Bool,U32.is_eq(hops,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(op,"jmp"),
          v => w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1)),
          v => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1)) &&
               w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1))))
    case _: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops),
              x => False{}))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,3)

# Shallow instruction extractors (keep bend.ts case trees O(1)).
type W4BRR is Data:
  W4BRRNone{}
  W4BRR{+op: String, +s: U32, +ws: U32, +d: U32, +wd: U32}

@unsafe
def w4b_as_rr(item: X187Parsed) -> W4BRR:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Reg{s,ws,False{}},Con{X187Reg{d,wd,False{}},Nil{}}}: W4BRR{op,s,ws,d,wd}
        case _: W4BRRNone{}
    case _: W4BRRNone{}

type W4BImmReg is Data:
  W4BImmRegNone{}
  W4BImmReg{+op: String, +lo: U32, +hi: U32, +r: U32, +w: U32}

@unsafe
def w4b_as_imm_reg(item: X187Parsed) -> W4BImmReg:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Imm{lo,hi},Con{X187Reg{r,w,False{}},Nil{}}}: W4BImmReg{op,lo,hi,r,w}
        case _: W4BImmRegNone{}
    case _: W4BImmRegNone{}

type W4BBranch is Data:
  W4BBranchNone{}
  W4BBranch{+op: String, +tgt: String}

@unsafe
def w4b_as_branch(item: X187Parsed) -> W4BBranch:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Target{tgt},Nil{}}: W4BBranch{op,tgt}
        case _: W4BBranchNone{}
    case _: W4BBranchNone{}

@unsafe
def w4b_is_ret(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Nil{}}}: agy_str_eq(op,"ret")
    case _: False{}

law w4b_copy_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

@unsafe
def w4b_copy_check_jcc(br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match br:
    case W4BBranch{jop,_}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_jz_jnz(jop),
        u => w4b_copy_peep(Con{i3,tail},fnItems,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BBranchNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_check_cmp(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
          U32.is_eq(cr,c) && U32.is_eq(cw,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BImmRegNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_after_sub(+c: U32, +rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{+i2,Con{+i3,+tail}}: w4b_copy_check_cmp(w4b_as_imm_reg(i2),c,i0,i1,i2,i3,tail,fnItems,out)
    case _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_pair_rr(r0: W4BRR, r1: W4BRR, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r0 r1:
    case W4BRR{+op0,+s,+ws,+t,+wt} W4BRR{+op1,+t2,+wt2,+d,+wd}:
      +isMov32 = agy_str_eq(op0,"movl") && U32.is_eq(ws,32) && U32.is_eq(wt,32)
      # movl %s32, %t32 ; movq %t64, %d64 -> movl %s32, %d32
      nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
          U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,24),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
        # movl %s32, %t32 ; alu32 %t32, %d32 -> alu32 %s32, %d32
        u => nt_choose(List<&2,X188Seq>,isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
            U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,24),
          v => w4b_copy_peep(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
          # subl %s32, %t32 ; movl %t32, %d32 ; cmpq $0, %d64 ; jz/jnz -> drop cmpq
          v => nt_choose(List<&2,X188Seq>,agy_str_eq(op0,"subl") && agy_str_eq(op1,"movl") &&
              U32.is_eq(wt,32) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
            w => w4b_copy_after_sub(d,rest,i0,i1,fnItems,out),
            # movl/alu32 _, %t32 ; movl %t32, %t32 -> drop redundant zero-extend
            w => nt_choose(List<&2,X188Seq>,(isMov32 || (w4b_is_alu32_rr(op0) && U32.is_eq(wt,32))) &&
                agy_str_eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
                U32.is_eq(t,t2) && U32.is_eq(t,d),
              x => w4b_copy_peep(rest,fnItems,Con{X188One{i0},out}),
              x => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})))))
    case _ _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_peep(items,fnItems,out):
  match items:
    case Nil{}: out
    case Con{+i0,Con{+i1,+rest}}: w4b_copy_pair_rr(w4b_as_rr(i0),w4b_as_rr(i1),i0,i1,rest,fnItems,out)
    case Con{h,rest}: w4b_copy_peep(rest,fnItems,Con{X188One{h},out})

# W4-7 Pass 3: General loop-invariant magic-constant hoisting (LICM) in call-free loops.
@unsafe
def w4b_bit(+r: U32) -> U32:
  U32.shln(1,U32.to_nat(r))

@unsafe
def w4b_op_reg_mask(op: X187Operand) -> U32:
  match op:
    case X187Reg{i,_,False{}}: w4b_bit(i)
    case X187Mem{b,_}: w4b_bit(b)
    case X187Indexed{b,i,_,_}: U32.or(w4b_bit(b),w4b_bit(i))
    case _: 0

@unsafe
def w4b_args_reg_mask(args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w4b_args_reg_mask(rest,U32.or(acc,w4b_op_reg_mask(a)))

@unsafe
def w4b_items_reg_mask(items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{_,args}},rest}: w4b_items_reg_mask(rest,w4b_args_reg_mask(args,acc))
    case Con{_,rest}: w4b_items_reg_mask(rest,acc)

@unsafe
def w4b_has_call(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,_}},rest}: agy_str_eq(op,"call") || w4b_has_call(rest)
    case Con{_,rest}: w4b_has_call(rest)

@unsafe
def w4b_branch_is_jmp(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: agy_str_eq(op,"jmp") && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_branch_is_any(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: String.starts_with(op,"j") && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_branch_is_cond(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: String.starts_with(op,"j") && Bool.not(agy_str_eq(op,"jmp")) && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_has_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_jmp(lbl,w4b_as_branch(h)) || w4b_has_jmp_to(lbl,rest)

@unsafe
def w4b_has_any_branch_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_any(lbl,w4b_as_branch(h)) || w4b_has_any_branch_to(lbl,rest)

@unsafe
def w4b_has_non_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_cond(lbl,w4b_as_branch(h)) || w4b_has_non_jmp_to(lbl,rest)

type W4BLoopSplit is Data:
  W4BLoopNone{}
  W4BLoopSplit{+before: List<&2,X187Parsed>, +lbl: String, +body: List<&2,X187Parsed>}

@unsafe
def w4b_find_loop(items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  match items:
    case Nil{}: W4BLoopNone{}
    case Con{PLabel{+lbl},+rest}:
      nt_choose(W4BLoopSplit,w4b_has_jmp_to(lbl,rest) && Bool.not(w4b_has_any_branch_to(lbl,before)),
        u => W4BLoopSplit{nt_reverse(X187Parsed,before,[]),lbl,rest},
        u => w4b_find_loop(rest,Con{PLabel{lbl},before}))
    case Con{h,rest}: w4b_find_loop(rest,Con{h,before})

@unsafe
def w4b_is_magic_pair(a: W4BImmReg, b: W4BRR) -> Maybe<&2,U32>:
  match a b:
    case W4BImmReg{op0,m,hi,r0,w0} W4BRR{op1,s,ws,d,wd}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op0,"movl") && U32.is_eq(hi,0) && U32.is_eq(r0,11) && U32.is_eq(w0,32) &&
          agy_str_eq(op1,"imulq") && U32.is_eq(s,11) && U32.is_eq(ws,64) && U32.is_eq(d,0) && U32.is_eq(wd,64) &&
          U32.is_ge(m,256),
        u => Some{m},u => None{})
    case _ _: None{}

law w4b_collect_magics:
  for items: List<&2,X187Parsed>
  for +acc: List<&2,U32>
  List<&2,U32>

@unsafe
def w4b_collect_magic_hit(hit: Maybe<&2,U32>, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +acc: List<&2,U32>) -> List<&2,U32>:
  match hit:
    case Some{+m}:
      nt_choose(List<&2,U32>,w2_xl_u32_in(m,acc),
        u => w4b_collect_magics(rest,acc),
        u => w4b_collect_magics(rest,Con{m,acc}))
    case None{}: w4b_collect_magics(Con{i1,rest},acc)

@unsafe
def w4b_collect_magics(items,acc):
  match items:
    case Nil{}: nt_reverse(U32,acc,[])
    case Con{i0,Con{+i1,+rest}}: w4b_collect_magic_hit(w4b_is_magic_pair(w4b_as_imm_reg(i0),w4b_as_rr(i1)),i1,rest,acc)
    case Con{_,rest}: w4b_collect_magics(rest,acc)

type W4BMagicMap is Data:
  W4BMagicEntry{+imm: U32, +reg: U32}

@unsafe
def w4b_free_regs(cands: List<&2,U32>, +mask: U32) -> List<&2,U32>:
  match cands:
    case Nil{}: []
    case Con{+r,+rest}:
      nt_choose(List<&2,U32>,U32.is_eq(U32.and(mask,w4b_bit(r)),0),
        u => Con{r,w4b_free_regs(rest,mask)},
        u => w4b_free_regs(rest,mask))

@unsafe
def w4b_pair_magics(ms: List<&2,U32>, rs: List<&2,U32>) -> List<&2,W4BMagicMap>:
  match ms rs:
    case Con{m,mr} Con{r,rr}: Con{W4BMagicEntry{m,r},w4b_pair_magics(mr,rr)}
    case _ _: []

@unsafe
def w4b_lookup_magic(+m: U32, mp: List<&2,W4BMagicMap>) -> Maybe<&2,U32>:
  match mp:
    case Nil{}: None{}
    case Con{W4BMagicEntry{imm,reg},rest}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(imm,m),u => Some{reg},u => w4b_lookup_magic(m,rest))

@unsafe
def w4b_hoist_inits(mp: List<&2,W4BMagicMap>) -> List<&2,X187Parsed>:
  match mp:
    case Nil{}: []
    case Con{W4BMagicEntry{m,r},rest}:
      Con{PInst{X187Instruction{"movl",[X187Imm{m,0},X187Reg{r,32,False{}}]}},w4b_hoist_inits(rest)}

law w4b_rewrite_magics:
  for items: List<&2,X187Parsed>
  for +mp: List<&2,W4BMagicMap>
  List<&2,X187Parsed>

@unsafe
def w4b_rewrite_magic_use(found: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +mp: List<&2,W4BMagicMap>) -> List<&2,X187Parsed>:
  match found:
    case Some{r}: Con{PInst{X187Instruction{"imulq",[X187Reg{r,64,False{}},X187Reg{0,64,False{}}]}},w4b_rewrite_magics(rest,mp)}
    case None{}: Con{i0,Con{i1,w4b_rewrite_magics(rest,mp)}}

@unsafe
def w4b_rewrite_magic_step(hit: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +mp: List<&2,W4BMagicMap>) -> List<&2,X187Parsed>:
  match hit:
    case Some{m}: w4b_rewrite_magic_use(w4b_lookup_magic(m,mp),i0,i1,rest,mp)
    case None{}: Con{i0,w4b_rewrite_magics(Con{i1,rest},mp)}

@unsafe
def w4b_rewrite_magics(items,mp):
  match items:
    case Nil{}: []
    case Con{+i0,Con{+i1,+rest}}:
      w4b_rewrite_magic_step(w4b_is_magic_pair(w4b_as_imm_reg(i0),w4b_as_rr(i1)),i0,i1,rest,mp)
    case Con{h,rest}: Con{h,w4b_rewrite_magics(rest,mp)}

@unsafe
def w4b_licm_finish(mp: List<&2,W4BMagicMap>, before: List<&2,X187Parsed>, lbl: String,
    body: List<&2,X187Parsed>, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match mp:
    case Nil{}: orig
    case Con{+h,+t}:
      nt_append(X187Parsed,before,
        nt_append(X187Parsed,w4b_hoist_inits(Con{h,t}),
          Con{PLabel{lbl},w4b_rewrite_magics(body,Con{h,t})}))

@unsafe
def w4b_licm_apply(split: W4BLoopSplit, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match split:
    case W4BLoopNone{}: orig
    case W4BLoopSplit{before,+lbl,+body}:
      +ms = w4b_collect_magics(body,[])
      +mask = w4b_items_reg_mask(body,0)
      +free = w4b_free_regs([8,9,1,2],mask)
      w4b_licm_finish(w4b_pair_magics(ms,free),before,lbl,body,orig)

@unsafe
def w4b_licm_magic(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  nt_choose(List<&2,X187Parsed>,w4b_has_call(items),u => items,u => w4b_licm_apply(w4b_find_loop(items,[]),items))

# W4-7 Pass 4: General bottom-tested tail-loop rotation.
type W4BExitSplit is Data:
  W4BExitNone{}
  W4BExitSplit{+exit: List<&2,X187Parsed>, +rest: List<&2,X187Parsed>}

@unsafe
def w4b_take_exit_ret(next: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match next:
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl),
        u => W4BExitSplit{nt_reverse(X187Parsed,Con{PInst{X187Instruction{"ret",[]}},acc},[]),rest},
        u => W4BExitNone{})
    case _: W4BExitNone{}

@unsafe
def w4b_take_exit_clean(items: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match items:
    case Nil{}: W4BExitNone{}
    case Con{PLabel{_},_}: W4BExitNone{}
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(W4BExitSplit,agy_str_eq(op,"ret"),
        u => w4b_take_exit_ret(rest,bodyLbl,acc),
        u => nt_choose(W4BExitSplit,agy_str_eq(op,"call") || String.starts_with(op,"j"),
          v => W4BExitNone{},
          v => w4b_take_exit_clean(rest,bodyLbl,Con{PInst{X187Instruction{op,args}},acc})))
    case _: W4BExitNone{}

@unsafe
def w4b_test_inst(+r: U32, +w: U32) -> X187Parsed:
  nt_choose(X187Parsed,U32.is_eq(w,64),
    u => PInst{X187Instruction{"testq",[X187Reg{r,64,False{}},X187Reg{r,64,False{}}]}},
    u => PInst{X187Instruction{"testl",[X187Reg{r,32,False{}},X187Reg{r,32,False{}}]}})

@unsafe
def w4b_rewrite_backedges(items: List<&2,X187Parsed>, +loopLbl: String, +bodyLbl: String,
    +exitLbl: String, +r: U32, +w: U32) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,Nil{}}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(loopLbl,w4b_as_branch(h)),
        u => [w4b_test_inst(r,w),PInst{X187Instruction{"jne",[X187Target{bodyLbl}]}}],
        u => [h])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(loopLbl,w4b_as_branch(h)),
        u => Con{w4b_test_inst(r,w),
               Con{PInst{X187Instruction{"jne",[X187Target{bodyLbl}]}},
                 Con{PInst{X187Instruction{"jmp",[X187Target{exitLbl}]}},
                   w4b_rewrite_backedges(rest,loopLbl,bodyLbl,exitLbl,r,w)}}},
        u => Con{h,w4b_rewrite_backedges(rest,loopLbl,bodyLbl,exitLbl,r,w)})

# Tail-duplicate a 1-instruction merge-backedge block (PLabel{m}; mov; test; jne body)
# into every `jmp m` inside the loop body, eliminating double jumps on branches.
@unsafe
def w4b_taildup_replace(items: List<&2,X187Parsed>, +mergeLbl: String, +mv: X187Parsed,
    +tst: X187Parsed, +jne: X187Parsed, +exitLbl: String) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(mergeLbl,w4b_as_branch(h)),
        u => Con{mv,Con{tst,Con{jne,Con{PInst{X187Instruction{"jmp",[X187Target{exitLbl}]}},
               w4b_taildup_replace(rest,mergeLbl,mv,tst,jne,exitLbl)}}}},
        u => Con{h,w4b_taildup_replace(rest,mergeLbl,mv,tst,jne,exitLbl)})

@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case _: body

@unsafe
def w4b_rotate_finish(exitSplit: W4BExitSplit, before: List<&2,X187Parsed>, +loopLbl: String,
    +bodyLbl: String, +r: U32, +w: U32, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match exitSplit:
    case W4BExitNone{}: orig
    case W4BExitSplit{exitBlk,loopBody}:
      +exitLbl = loopLbl ++ "_exit"
      +rew = w4b_rewrite_backedges(loopBody,loopLbl,bodyLbl,exitLbl,r,w)
      +rew2 = w4b_taildup_check(nt_reverse(X187Parsed,rew,[]),rew,exitLbl)
      nt_append(X187Parsed,before,
        Con{w4b_test_inst(r,w),
          Con{PInst{X187Instruction{"je",[X187Target{exitLbl}]}},
            Con{PLabel{bodyLbl},
              nt_append(X187Parsed,rew2,
                Con{PLabel{exitLbl},exitBlk})}}})

@unsafe
def w4b_rotate_check_hdr(cm: W4BImmReg, br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cm br:
    case W4BImmReg{cmpop,lo,hi,+r,+w} W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
        ((agy_str_eq(cmpop,"cmpq") && U32.is_eq(w,64)) || (agy_str_eq(cmpop,"cmpl") && U32.is_eq(w,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,r,w,orig),
        v => orig)
    case _ _: orig

@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{i0,Con{i1,afterHdr}}:
      w4b_rotate_check_hdr(w4b_as_imm_reg(i0),w4b_as_branch(i1),before,loopLbl,afterHdr,orig)
    case _: orig

@unsafe
def w4b_rotate_apply(split: W4BLoopSplit, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match split:
    case W4BLoopNone{}: orig
    case W4BLoopSplit{+before,+loopLbl,+body}:
      nt_choose(List<&2,X187Parsed>,w4b_has_non_jmp_to(loopLbl,body),u => orig,
        u => w4b_rotate_body(before,loopLbl,body,orig))

@unsafe
def w4b_rotate_loop(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4b_rotate_apply(w4b_find_loop(items,[]),items)

@unsafe
def w4b_wrap_items(items: List<&2,X187Parsed>, +acc: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(acc)
    case Con{h,rest}: w4b_wrap_items(rest,Con{X188One{h},acc})

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep3],[]),peep3)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  w4b_wrap_items(rot,[])"""

    t = replace_exact(t, old_post_select, new_post_select, "w4_post_select")

    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--src",
        default="selfhost/build/agy/wave4a_unified/compiler.bend",
        help="Input compiler.bend",
    )
    ap.add_argument(
        "--dst",
        default="selfhost/build/agy/wave4b_loopxmm/compiler.bend",
        help="Output compiler.bend",
    )
    ap.add_argument(
        "--min-start",
        type=int,
        default=8,
        help="Minimum starting XMM reg for loop allocator (default: 8 -> xmm8..15, keeping xmm2..7 for temps)",
    )
    args = ap.parse_args()

    src = Path(args.src)
    dst = Path(args.dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    out = apply_all(src.read_text(), min_start_reg=args.min_start)
    dst.write_text(out)
    print(f"Wrote {dst} ({len(out)} bytes, min_start_reg={args.min_start})")


if __name__ == "__main__":
    main()

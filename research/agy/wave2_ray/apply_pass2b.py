#!/usr/bin/env python3
"""Wave 2 Track A Pass 2b (composable on top of Pass 1 + Pass 2a):
  1. Fix dominated n!=0 pruning inside `no` branch of `eq` (eliminates redundant cmp $0 in Nat loops).
  2. General loop-invariant F32 param, loop-carried F32 param, and non-zero F32 constant hoisting
     into xmm10..xmm15 for call-free / sqrt-only self-tail loops (p37.numeric, nearest, nearest.t).
  3. Compact x197ms_previous cmov emission (xorl/movl/cmpq $imm instead of 10-byte movabsq).
  4. General arithmetic-shift-right (asr -> sarl $k) recognition before x185_dead_body (Mandelbrot mit).
"""
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return src.replace(old, new, 1)


XLOOP_HELPERS = """
# Wave2 Pass 2b: Loop-invariant / loop-carried F32 param & F32 constant hoisting into xmm10..xmm15.
type W2XLoopPlan is Data:
  W2XLoopPlan{+homes: KDef, +pre: X188Seq, +carried: String, +carriedIdx: U32, +carriedXmm: U32, +active: Bool}

@unsafe
def w2_xl_safe_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{d,t,sym,args}: String.eq(sym,"p111_rt_fail")
    case N111If{c,yes,no}: False{}
    case _: True{}

law w2_xl_safe_nodes:
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_safe_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_xl_safe_scalar(s)
    case P113DCall{ns,t,args}: False{}
    case P113DIf{c,y,n}: False{}
    case _: True{}

@unsafe
def w2_xl_safe_nodes(nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatPlain{s},rest}: w2_xl_safe_stmt(s) && w2_xl_safe_nodes(rest)
    case Con{X186FloatBranch{c,y,n},rest}: w2_xl_safe_nodes(y) && w2_xl_safe_nodes(n) && w2_xl_safe_nodes(rest)
    case Con{X186FloatValues{d,id,l,r},rest}: w2_xl_safe_nodes(rest)

law w2_xl_has_again:
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_has_again(nodes):
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatPlain{P113DAgain{vs}},rest}: True{}
    case Con{X186FloatBranch{c,y,n},rest}: w2_xl_has_again(y) || w2_xl_has_again(n) || w2_xl_has_again(rest)
    case Con{h,rest}: w2_xl_has_again(rest)

@unsafe
def w2_xl_same_local(found: Maybe<&2,N111Value>, name: String) -> Bool:
  match found:
    case Some{N111Local{x}}: String.eq(x,name)
    case _: False{}

law w2_xl_param_inv:
  for +name: String
  for +idx: U32
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_param_inv(name,idx,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,id,l,r},rest}:
      Bool.not(String.eq(dest,name)) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_param_inv(name,idx,y) && w2_xl_param_inv(name,idx,n) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w2_xl_same_local(w2_xl_nth(vals,idx),name) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_writes(name,stmt)) && w2_xl_param_inv(name,idx,rest)

law w2_xl_param_nowrite:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_param_nowrite(name,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,id,l,r},rest}:
      Bool.not(String.eq(dest,name)) && w2_xl_param_nowrite(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_param_nowrite(name,y) && w2_xl_param_nowrite(name,n) && w2_xl_param_nowrite(name,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_writes(name,stmt)) && w2_xl_param_nowrite(name,rest)

law w2_xl_float_used:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_float_used(name,nodes):
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatValues{dest,+id,l,r},rest}:
      (Bool.not(U32.is_eq(id,23)) && (w2_val_reads(name,l) || w2_val_reads(name,r))) || w2_xl_float_used(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_float_used(name,y) || w2_xl_float_used(name,n) || w2_xl_float_used(name,rest)
    case Con{h,rest}: w2_xl_float_used(name,rest)

law w2_xl_only_float:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_only_float(name,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,+id,l,r},rest}:
      (Bool.not(U32.is_eq(id,23)) || Bool.not(w2_val_reads(name,l))) && w2_xl_only_float(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      Bool.not(w2_val_reads(name,c)) && w2_xl_only_float(name,y) && w2_xl_only_float(name,n) && w2_xl_only_float(name,rest)
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w2_xl_only_float(name,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_reads(name,stmt)) && w2_xl_only_float(name,rest)

@unsafe
def w2_xl_u32_in(+x: U32, xs: List<&2,U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: U32.is_eq(h,x) || w2_xl_u32_in(x,rest)

@unsafe
def w2_xl_add_const(v: N111Value, +acc: List<&2,U32>) -> List<&2,U32>:
  match v:
    case N111Const{+lo,0}:
      nt_choose(List<&2,U32>,Bool.not(U32.is_eq(lo,0)) && Bool.not(w2_xl_u32_in(lo,acc)),
        u => Con{lo,acc},u => acc)
    case _: acc

law w2_xl_consts:
  for nodes: List<&2,X186FloatNode>
  for +acc: List<&2,U32>
  List<&2,U32>

@unsafe
def w2_xl_consts(nodes,acc):
  match nodes:
    case Nil{}: acc
    case Con{X186FloatValues{dest,+id,l,r},+rest}:
      nt_choose(List<&2,U32>,U32.is_eq(id,23),
        u => w2_xl_consts(rest,acc),
        u => w2_xl_consts(rest,w2_xl_add_const(r,w2_xl_add_const(l,acc))))
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_consts(rest,w2_xl_consts(n,w2_xl_consts(y,acc)))
    case Con{h,rest}: w2_xl_consts(rest,acc)

type W2XLAlloc is Data:
  W2XLAlloc{+homes: KDef, +pre: X188Seq, +nextReg: U32}

@unsafe
def w2_xl_assign_inv(params: List<&2,String>, +idx: U32, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +st: W2XLAlloc) -> W2XLAlloc:
  match params st:
    case Nil{} _: st
    case Con{+p,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLAlloc,U32.is_lt(reg,16) && w2_xl_param_inv(p,idx,nodes) && w2_xl_float_used(p,nodes),
        u => w2_xl_assign_inv(rest,U32.inc(idx),nodes,ids,frame,
               W2XLAlloc{p111v_put(homes,p,"X186Xmm",U32.sub(reg,2),0),
                 x188_cat(pre,x186_float_load(N111Local{p},ids,frame,x188_xmm(reg))),U32.inc(reg)}),
        u => w2_xl_assign_inv(rest,U32.inc(idx),nodes,ids,frame,st))

@unsafe
def w2_xl_assign_consts(cs: List<&2,U32>, +st: W2XLAlloc) -> W2XLAlloc:
  match cs st:
    case Nil{} _: st
    case Con{+lo,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLAlloc,U32.is_lt(reg,16),
        u => w2_xl_assign_consts(rest,
               W2XLAlloc{p111v_put(homes,"$w2c_" ++ U32.show(lo),"X186Xmm",U32.sub(reg,2),0),
                 x188_cat(pre,x188_cat(x188_i2("movl",X187Imm{lo,0},x188_reg(10,32)),
                   x188_i2("movd",x188_reg(10,32),x188_xmm(reg)))),U32.inc(reg)}),
        u => st)

@unsafe
def w2_xl_pick_carried(params: List<&2,String>, +idx: U32, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +st: W2XLAlloc) -> W2XLoopPlan:
  match params st:
    case Nil{} W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,"",0,0,True{}}
    case Con{+p,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLoopPlan,U32.is_lt(reg,16) && Bool.not(w2_xl_param_inv(p,idx,nodes)) &&
          w2_xl_param_nowrite(p,nodes) && w2_xl_float_used(p,nodes) && w2_xl_only_float(p,nodes),
        u => W2XLoopPlan{p111v_put(homes,p,"X186Xmm",U32.sub(reg,2),0),
               x188_cat(pre,x186_float_load(N111Local{p},ids,frame,x188_xmm(reg))),p,idx,reg,True{}},
        u => w2_xl_pick_carried(rest,U32.inc(idx),nodes,ids,frame,st))

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,String.eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def w2_xl_tail_params(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{state,rest}: w2_xl_tail_skip(rest)

@unsafe
def w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +tparams = w2_xl_tail_params(params)
  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),
    u => w2_xl_pick_carried(tparams,0,nodes,ids,frame,
           w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
             w2_xl_assign_inv(tparams,0,nodes,ids,frame,
               W2XLAlloc{x186_x_homes_capped(params,setup,nodes),X188Empty{},10}))),
    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},"",0,0,False{}})
"""

ASR_HELPERS = """
# Wave2 Pass 2b: General arithmetic shift right (asr -> sarl $k) recognition on P113DStmt.
# Tracks recent `s1 = shr(v, k)` (and copies `s1c = s1`) so intervening copies do not block matching.
@unsafe
def w2_asr_mask(+k: U32) -> U32:
  U32.sub(0,U32.shln(1,U32.to_nat(U32.sub(32,k))))

@unsafe
def w2_asr_val_local(v: N111Value) -> String:
  match v:
    case N111Local{name}: name
    case _: ""

@unsafe
def w2_asr_is_const(v: N111Value, +want: U32) -> Bool:
  match v:
    case N111Const{lo,0}: U32.is_eq(lo,want)
    case _: False{}

@unsafe
def w2_asr_head(names: List<&2,String>) -> Maybe<&2,String>:
  match names:
    case Con{m,rest2}: Some{m}
    case Nil{}: None{}

@unsafe
def w2_asr_match_sel(sel: Maybe<&2,X194Select>, +s2: String, +mask: U32) -> Maybe<&2,String>:
  match sel:
    case Some{X194Select{rest,typ,op,left,right,invert,X191SelectPlan{st,yes,no,names},removed}}:
      nt_choose(Maybe<&2,String>,
        String.eq(op,"eq") && String.eq(w2_asr_val_local(left),s2) && w2_asr_is_const(right,0) &&
        ((Bool.not(invert) && w2_asr_is_const(yes,0) && w2_asr_is_const(no,mask)) ||
         (invert && w2_asr_is_const(yes,mask) && w2_asr_is_const(no,0))),
        u => w2_asr_head(names),
        u => None{})
    case None{}: None{}

@unsafe
def w2_asr_sel_rest(sel: Maybe<&2,X194Select>) -> List<&2,P113DStmt>:
  match sel:
    case Some{X194Select{rest,typ,op,left,right,invert,plan,removed}}: rest
    case None{}: []

@unsafe
def w2_asr_rewrite_or(+rest: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32) -> List<&2,P113DStmt>:
  match rest:
    case Con{P113DScalar{N111Bin{dest,typ,op,+l,+r}},+tail}:
      nt_choose(List<&2,P113DStmt>,String.eq(op,"or") &&
          ((String.eq(w2_asr_val_local(l),s1) && String.eq(w2_asr_val_local(r),m)) ||
           (String.eq(w2_asr_val_local(l),m) && String.eq(w2_asr_val_local(r),s1))),
        u => Con{P113DScalar{N111Bin{dest,N111U32{},"sar",v,N111Const{k,0}}},tail},
        u => rest)
    case _: rest

@unsafe
def w2_asr_changed(rewritten: List<&2,P113DStmt>, sel_rest: List<&2,P113DStmt>) -> Bool:
  match rewritten sel_rest:
    case Con{P113DScalar{N111Bin{d1,t1,op1,a1,b1}},_} Con{P113DScalar{N111Bin{d2,t2,op2,a2,b2}},_}:
      String.eq(op1,"sar") && String.eq(op2,"or")
    case _ _: False{}

law w2_asr_body:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w2_asr_try(found: Maybe<&2,String>, +s1: String, +v: N111Value, +k: U32,
    +sel_rest: List<&2,P113DStmt>, +orig_head: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match found:
    case Some{m}:
      +rewritten = w2_asr_rewrite_or(sel_rest,s1,m,v,k)
      Con{orig_head,w2_asr_body(nt_choose(List<&2,P113DStmt>,w2_asr_changed(rewritten,sel_rest),
        u => rewritten,u => orig_tail))}
    case None{}: Con{orig_head,w2_asr_body(orig_tail)}

@unsafe
def w2_asr_after(+s1: String, +s2: String, +v1: N111Value, +k: U32, +after: List<&2,P113DStmt>,
    +h1: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +sel = x194_ps_pick(after)
  w2_asr_try(w2_asr_match_sel(sel,s2,w2_asr_mask(k)),s1,v1,k,w2_asr_sel_rest(sel),h1,orig_tail)

@unsafe
def w2_asr_triple(+h1: P113DStmt, +h2: P113DStmt, +h3: P113DStmt, +after: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match h1 h2 h3:
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Set{+s1c,t1c,N111Local{+s1ref}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}:
      nt_choose(List<&2,P113DStmt>,String.eq(op1,"shr") && String.eq(op2,"shr") &&
          String.eq(s1,s1ref) && U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1c,s2,v1,k,after,h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}
         _:
      nt_choose(List<&2,P113DStmt>,String.eq(op1,"shr") && String.eq(op2,"shr") &&
          U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1,s2,v1,k,Con{h3,after},h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case _ _ _: Con{h1,w2_asr_body(Con{h2,Con{h3,after}})}

@unsafe
def w2_asr_body(body):
  match body:
    case Nil{}: []
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_body(yes),w2_asr_body(no)},w2_asr_body(rest)}
    case Con{h1,Con{h2,Con{h3,after}}}: w2_asr_triple(h1,h2,h3,after)
    case Con{head,rest}: Con{head,w2_asr_body(rest)}
"""


def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()

    # 1. Fix w2_skip_dom_ne inside `no` branch of `eq`
    src = replace_exact(
        src,
        "        u => x186_x_emit_nodes(\n"
        "               nt_choose(List<&2,X186FloatNode>,String.eq(op,\"eq\") && List.is_empty(&2,X186FloatNode,no) && w2_nodes_term(yes),\n"
        "                 v => w2_skip_dom_ne(typ,left,right,rest),v => rest),\n"
        "               ids,frame,homes,\n"
        "               w2_emit_branch_custom(w2_int_branch_code(typ,op,left,right,w2_code_next(code),ids,frame),yes,no,ids,frame,homes,code)),",
        "        u => x186_x_emit_nodes(\n"
        "               nt_choose(List<&2,X186FloatNode>,String.eq(op,\"eq\") && List.is_empty(&2,X186FloatNode,no) && w2_nodes_term(yes),\n"
        "                 v => w2_skip_dom_ne(typ,left,right,rest),v => rest),\n"
        "               ids,frame,homes,\n"
        "               w2_emit_branch_custom(w2_int_branch_code(typ,op,left,right,w2_code_next(code),ids,frame),yes,\n"
        "                 nt_choose(List<&2,X186FloatNode>,String.eq(op,\"eq\"),v => w2_skip_dom_ne(typ,left,right,no),v => no),\n"
        "                 ids,frame,homes,code)),",
        "fix w2_skip_dom_ne inside no branch",
    )

    # 2. Add capped x186_x_homes_capped (8 temps xmm2..xmm9) and update x186_x_source to also check hoisted constants
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_homes(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:\n"
        "  x186_x_scanned(x186_x_scan(nodes,X186XScan{\n"
        "    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))",
        "@unsafe\ndef x186_x_scanned_capped(scan: X186XScan) -> KDef:\n"
        "  match scan:\n"
        "    case X186XScan{X185TScan{ranges,names,position,region},canonical}:\n"
        "      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),[0,0,0,0,0,0,0,0])\n\n"
        "@unsafe\ndef x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:\n"
        "  x186_x_scanned_capped(x186_x_scan(nodes,X186XScan{\n"
        "    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))\n\n"
        "@unsafe\ndef x186_x_homes(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:\n"
        "  x186_x_scanned(x186_x_scan(nodes,X186XScan{\n"
        "    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))",
        "add x186_x_homes_capped",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_source(value: N111Value, homes: KDef) -> Maybe<&2,X187Operand>:\n"
        "  match value:\n"
        "    case N111Local{name}: x186_x_home(name,homes)\n"
        "    case _: None{}",
        "@unsafe\ndef x186_x_source(value: N111Value, homes: KDef) -> Maybe<&2,X187Operand>:\n"
        "  match value:\n"
        "    case N111Local{name}: x186_x_home(name,homes)\n"
        "    case N111Const{lo,0}: x186_x_home(\"$w2c_\" ++ U32.show(lo),homes)\n"
        "    case _: None{}",
        "x186_x_source support hoisted constants",
    )

    # 2b. Do not cut XMM regions on pure integer N111Bin (only forbid its operands/dest from XMM)
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_plain(+stmt: P113DStmt, scan: X186XScan) -> X186XScan:\n"
        "  match stmt scan:\n"
        "    case P113DScalar{N111Set{+name,N111U64{},+value}} X186XScan{+ranges,+canonical}:\n"
        "      +good = x186_x_canonical(value,canonical)\n"
        "      X186XScan{x185_t_next(nt_choose(X185TScan,good,\n"
        "        u => x185_t_event(name,True{},x185_t_read(value,ranges)),\n"
        "        u => x185_t_forbid(name,x185_t_read(value,ranges)))),\n"
        "        p111v_put(canonical,name,\"X186Canonical\",nt_choose(U32,good,u => 1,u => 0),0)}\n"
        "    case _ X186XScan{ranges,canonical}:\n"
        "      X186XScan{x185_t_cut(x186_x_noncanonical(stmt,x185_t_stmt(stmt,x185_t_cut(ranges)))),missing()}",
        "@unsafe\ndef w2_x_forbid_val(value: N111Value, ranges: X185TScan) -> X185TScan:\n"
        "  match value:\n"
        "    case N111Local{name}: x185_t_forbid(name,ranges)\n"
        "    case _: ranges\n\n"
        "@unsafe\ndef x186_x_plain(+stmt: P113DStmt, scan: X186XScan) -> X186XScan:\n"
        "  match stmt scan:\n"
        "    case P113DScalar{N111Set{+name,N111U64{},+value}} X186XScan{+ranges,+canonical}:\n"
        "      +good = x186_x_canonical(value,canonical)\n"
        "      X186XScan{x185_t_next(nt_choose(X185TScan,good,\n"
        "        u => x185_t_event(name,True{},x185_t_read(value,ranges)),\n"
        "        u => x185_t_forbid(name,x185_t_read(value,ranges)))),\n"
        "        p111v_put(canonical,name,\"X186Canonical\",nt_choose(U32,good,u => 1,u => 0),0)}\n"
        "    case P113DScalar{N111Bin{+name,typ,op,+left,+right}} X186XScan{+ranges,+canonical}:\n"
        "      X186XScan{x185_t_next(x185_t_forbid(name,w2_x_forbid_val(right,w2_x_forbid_val(left,ranges)))),\n"
        "        p111v_put(canonical,name,\"X186Canonical\",0,0)}\n"
        "    case _ X186XScan{ranges,canonical}:\n"
        "      X186XScan{x185_t_cut(x186_x_noncanonical(stmt,x185_t_stmt(stmt,x185_t_cut(ranges)))),missing()}",
        "do not cut XMM region on pure integer N111Bin",
    )

    # 3. Insert w2_xl_nth + w2_xl_again_update before x186_x_emit_node, and XLOOP_HELPERS before x186_x_emit_frame
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_emit_node(+node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:",
        "@unsafe\ndef w2_xl_nth(vals: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:\n"
        "  match vals:\n"
        "    case Nil{}: None{}\n"
        "    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{v},u => w2_xl_nth(rest,U32.sub(idx,1)))\n\n"
        "@unsafe\ndef w2_xl_again_update(found: Maybe<&2,N111Value>, +xmm: U32, ids: N111Ids, frame: X181Frame, homes: KDef) -> X188Seq:\n"
        "  match found:\n"
        "    case Some{val}: x186_x_load(val,ids,frame,homes,x188_xmm(xmm))\n"
        "    case None{}: X188Empty{}\n\n"
        "@unsafe\ndef x186_x_emit_node(+node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:",
        "insert w2_xl_nth before x186_x_emit_node",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_emit_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:\n"
        "  x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,x186_x_homes(params,setup,nodes),\n"
        "    x181_add(x188_label(x181_loop_label(frame)),x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},\"\"}))))",
        XLOOP_HELPERS.strip() + "\n\n"
        "@unsafe\ndef w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,\n"
        "    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:\n"
        "  match plan:\n"
        "    case W2XLoopPlan{+homes,pre,carried,cidx,+cxmm,active}:\n"
        "      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),\n"
        "                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},\"\"}))\n"
        "      +homes2 = nt_choose(KDef,U32.is_gt(cxmm,0),\n"
        "                  u => p111v_put(homes,\"$w2_carried_xmm\",\"W2Carried\",cidx,cxmm),\n"
        "                  u => homes)\n"
        "      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))\n\n"
        "@unsafe\ndef x186_x_emit_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:\n"
        "  w2_xl_emit_with_plan(w2_xl_plan(params,setup,nodes,ids,frame),symbol,setup,nodes,ids,frame)",
        "hook w2_xl_plan into x186_x_emit_frame",
    )

    # Update x186_x_emit_node for P113DAgain when $w2_carried_xmm is present in homes!
    src = replace_exact(
        src,
        "    case X186FloatPlain{+stmt}:\n"
        "      match stmt:\n"
        "        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)\n"
        "        case _: x181_stmt(stmt,ids,frame,code)",
        "    case X186FloatPlain{+stmt}:\n"
        "      match stmt:\n"
        "        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)\n"
        "        case P113DAgain{+vals}:\n"
        "          +ce = p111v_get(homes,\"$w2_carried_xmm\")\n"
        "          +code2 = nt_choose(X181Code,String.eq(dk(ce),\"W2Carried\"),\n"
        "                     u => x181_add(w2_xl_again_update(w2_xl_nth(vals,da(ce)),dx(ce),ids,frame,homes),code),\n"
        "                     u => code)\n"
        "          x181_stmt(stmt,ids,frame,code2)\n"
        "        case _: x181_stmt(stmt,ids,frame,code)",
        "update carried XMM at P113DAgain",
    )

    # 4. Compact x197ms_previous (xorl/movl/cmpq $imm instead of 10-byte movabsq)
    src = replace_exact(
        src,
        "@unsafe\ndef x197ms_previous(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:\n"
        "  match plan:\n"
        "    case X194Select{rest,+typ,+op,left,right,invert,X191SelectPlan{+st,+yes,+no,names},removed}:\n"
        "      x188_many([x181_load(left,ids,frame,x188_reg(10,64)),\n"
        "        x181_load(right,ids,frame,x188_reg(11,64)),\n"
        "        x188_i2(x181_width(typ,\"cmpq\",\"cmpl\"),x188_width_reg(typ,11),x188_width_reg(typ,10)),\n"
        "        x181_load(nt_choose(N111Value,invert,u => no,u => yes),ids,frame,x188_reg(0,64)),x181_mask(st,x188_reg(0,32)),\n"
        "        x181_load(nt_choose(N111Value,invert,u => yes,u => no),ids,frame,x188_reg(11,64)),x181_mask(st,x188_reg(11,32)),\n"
        "        x188_i2(\"cmov\" ++ x181_condition(op) ++ x181_width(st,\"q\",\"l\"),x188_width_reg(st,0),x188_width_reg(st,11)),\n"
        "        x191_select_publish(names,frame)])",
        "@unsafe\ndef w2_cmov_load(value: N111Value, ids: N111Ids, frame: X181Frame, +regIdx: U32) -> X188Seq:\n"
        "  match value:\n"
        "    case N111Const{+lo,0}: x188_i2(\"movl\",X187Imm{lo,0},x188_reg(regIdx,32))\n"
        "    case _: x181_load(value,ids,frame,x188_reg(regIdx,64))\n\n"
        "@unsafe\ndef w2_cmov_cmp(+typ: N111Type, +left: N111Value, +right: N111Value, +ids: N111Ids, +frame: X181Frame) -> X188Seq:\n"
        "  +lh = w2_phys_val(left,frame)\n"
        "  +dst = w2_phys_dst(lh,typ)\n"
        "  +load_l = w2_phys_load(lh,left,ids,frame)\n"
        "  +imm = w2_int_cmp_imm(typ,right,dst)\n"
        "  x188_cat(load_l,\n"
        "    nt_choose(X188Seq,x188_empty(imm),\n"
        "      u => x188_cat(w2_cmov_load(right,ids,frame,11),x188_i2(x181_width(typ,\"cmpq\",\"cmpl\"),x188_width_reg(typ,11),dst)),\n"
        "      u => imm))\n\n"
        "@unsafe\ndef x197ms_previous(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:\n"
        "  match plan:\n"
        "    case X194Select{rest,+typ,+op,left,right,invert,X191SelectPlan{+st,+yes,+no,names},removed}:\n"
        "      x188_many([w2_cmov_cmp(typ,left,right,ids,frame),\n"
        "        w2_cmov_load(nt_choose(N111Value,invert,u => no,u => yes),ids,frame,0),x181_mask(st,x188_reg(0,32)),\n"
        "        w2_cmov_load(nt_choose(N111Value,invert,u => yes,u => no),ids,frame,11),x181_mask(st,x188_reg(11,32)),\n"
        "        x188_i2(\"cmov\" ++ x181_condition(op) ++ x181_width(st,\"q\",\"l\"),x188_width_reg(st,0),x188_width_reg(st,11)),\n"
        "        x191_select_publish(names,frame)])",
        "compact x197ms_previous",
    )

    # 5. General arithmetic shift right (asr -> sarl $k) recognition before x185_dead_body
    # Insert ASR_HELPERS right before x186_function_memory, and hook into x186_function_memory, x198n_normalized, x199s_memory
    src = replace_exact(
        src,
        "@unsafe\ndef x186_function_memory(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:\n"
        "  x185_function_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))),ids)",
        ASR_HELPERS.strip() + "\n\n"
        "@unsafe\ndef x186_function_memory(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:\n"
        "  x185_function_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    w2_asr_body(x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))),ids)",
        "hook w2_asr_body in x186_function_memory",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:\n"
        "  x185_function_copied(symbol,names,[],x198n_body(x185_dead_body([],\n"
        "    x185_copy_function(names,[],x186_expression_body([],\n"
        "      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body)))))),params),ids)",
        "@unsafe\ndef x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:\n"
        "  x185_function_copied(symbol,names,[],x198n_body(x185_dead_body([],\n"
        "    w2_asr_body(x185_copy_function(names,[],x186_expression_body([],\n"
        "      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body))))))),params),ids)",
        "hook w2_asr_body in x198n_normalized",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef x199s_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:\n"
        "  x199s_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))),ids)",
        "@unsafe\ndef x199s_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:\n"
        "  x199s_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    w2_asr_body(x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))),ids)",
        "hook w2_asr_body in x199s_memory",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(src)
    print(f"Wrote {out_path} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

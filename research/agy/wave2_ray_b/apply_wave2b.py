#!/usr/bin/env python3
"""Wave 2B Track A Super-Pass (composable cleanly on top of Wave 2A compiler_p2b.bend):
  1. Keep carried F32 value in XMM across P113DAgain (eliminates 7-cycle movd round-trip in p37.numeric).
  2. Float copy coalescing (w2_fc_coalesce) + commutative addss/mulss in x186_x_arithmetic.
  3. 100%-exact Unboxed Bool branch fast-path (2/4 insns vs 16/30 insns in nearest, nearest.t, trace).
  4. Direct Table-to-XMM (movd (%r11,%r10,8), %xmm) for x195t table lookups.
  5. Sound post-DCE arithmetic-shift-right (asr -> sarl $k) + second DCE pass (Mandelbrot mit).
"""
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return src.replace(old, new, 1)


COALESCE_AND_BOOL = """
# Wave2B: Float copy coalescing:
#   X186FloatValues{tmp, id, l, r} ; X186FloatPlain{P113DScalar{N111Set{dst, N111U64{}, N111Local{tmp}}}}
# when tmp is dead after -> X186FloatValues{dst, id, l, r} (eliminates redundant movaps).
law w2b_coalesce:
  for nodes: List<&2,X186FloatNode>
  for +params: List<&2,String>
  for +tail: List<&2,List<&2,X186FloatNode>>
  List<&2,X186FloatNode>

@unsafe
def w2b_coalesce(nodes,params,tail):
  match nodes:
    case Nil{}: []
    case Con{X186FloatValues{+tmp,+id,+l,+r},
         Con{X186FloatPlain{P113DScalar{N111Set{+dst,N111U64{},N111Local{+tmp2}}}},+rest}}:
      nt_choose(List<&2,X186FloatNode>,String.eq(tmp,tmp2) && Bool.not(w2_names_has(dst,params)) &&
          Bool.not(x181_register_reserved(dst)) && w2_dead_in(tmp,rest,tail,64),
        u => w2b_coalesce(Con{X186FloatValues{dst,id,l,r},rest},params,tail),
        u => Con{X186FloatValues{tmp,id,l,r},
               w2b_coalesce(Con{X186FloatPlain{P113DScalar{N111Set{dst,N111U64{},N111Local{tmp2}}}},rest},params,tail)})
    case Con{X186FloatBranch{c,y,n},+rest}:
      Con{X186FloatBranch{c,w2b_coalesce(y,params,Con{rest,tail}),w2b_coalesce(n,params,Con{rest,tail})},w2b_coalesce(rest,params,tail)}
    case Con{h,rest}: Con{h,w2b_coalesce(rest,params,tail)}

# Wave2B: Unboxed Bool branch fast-path for p112_special_bool (100% exact for all 64-bit values).
type W2BoolMatch is Data:
  W2BoolHit{+word: N111Value, +yes: List<&2,X186FloatNode>, +no: List<&2,X186FloatNode>, +rest: List<&2,X186FloatNode>}
  W2BoolMiss{}

law w2b_strip_true_check:
  for nodes: List<&2,X186FloatNode>
  for +word: N111Value
  List<&2,X186FloatNode>

@unsafe
def w2b_strip_true_check(nodes,word):
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{b1,t1,op1,+w1,N111Const{40,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{b2,t2,op2,N111Local{b1b},N111Const{8388607,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{bx,t3,op3,N111Local{b2b},N111Local{ex}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{mc,t4,op4,N111Local{raw},N111Local{bxb}}}},
         Con{X186FloatBranch{N111Local{mcb},+yes2,no2},+tail2}}}}}:
      nt_choose(List<&2,X186FloatNode>,
        String.eq(b1,"p112_b_bits") && String.eq(op1,"shr") && w2_val_eq(w1,word) &&
        String.eq(b2,"p112_b_bits") && String.eq(op2,"and") && String.eq(b1b,"p112_b_bits") &&
        String.eq(bx,"p112_b_boxed") && String.eq(op3,"eq") && String.eq(b2b,"p112_b_bits") && String.eq(ex,"p112_b_expected") &&
        String.eq(mc,"match_condition") && String.eq(op4,"or") && String.eq(raw,"p112_b_raw") && String.eq(bxb,"p112_b_boxed") &&
        String.eq(mcb,"match_condition"),
        u => nt_append(X186FloatNode,yes2,tail2),
        u => nodes)
    case Con{X186FloatPlain{P113DScalar{N111Set{s1,ts1,N111Local{s1b}}}},+more}:
      nt_choose(List<&2,X186FloatNode>,String.eq(s1,"p112_b_raw") && String.eq(s1b,"p112_b_raw"),
        u => w2b_strip_true_check(more,word),
        u => nodes)
    case _: nodes

@unsafe
def w2b_bool_match(nodes: List<&2,X186FloatNode>) -> W2BoolMatch:
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{raw,t0,op0,+w0,N111Const{1,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{b1,t1,op1,+w1,N111Const{40,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{b2,t2,op2,N111Local{b1b},N111Const{8388607,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{ex,t3,op3,N111CtorId{cname},N111Const{65536,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{bx,t4,op4,N111Local{b2b},N111Local{exb}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{mc,t5,op5,N111Local{rawb},N111Local{bxb}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{mc2,t6,op6,N111Local{mcb},N111Const{1,0}}}},
         Con{X186FloatBranch{N111Local{mc2b},+yes,+no},+rest}}}}}}}}:
      +no2 = w2b_strip_true_check(no,w0)
      nt_choose(W2BoolMatch,
        String.eq(raw,"p112_b_raw") && String.eq(op0,"eq") &&
        String.eq(b1,"p112_b_bits") && String.eq(op1,"shr") && w2_val_eq(w0,w1) &&
        String.eq(b2,"p112_b_bits") && String.eq(op2,"and") && String.eq(b1b,"p112_b_bits") &&
        String.eq(ex,"p112_b_expected") && String.eq(op3,"or") && String.eq(cname,"True") &&
        String.eq(bx,"p112_b_boxed") && String.eq(op4,"eq") && String.eq(b2b,"p112_b_bits") && String.eq(exb,"p112_b_expected") &&
        String.eq(mc,"match_condition") && String.eq(op5,"or") && String.eq(rawb,"p112_b_raw") && String.eq(bxb,"p112_b_boxed") &&
        String.eq(mc2,"match_condition") && String.eq(op6,"xor") && String.eq(mcb,"match_condition") && String.eq(mc2b,"match_condition") &&
        w2_dead_in("p112_b_raw",yes,[rest],64) && w2_dead_in("p112_b_raw",no2,[rest],64) &&
        w2_dead_in("p112_b_expected",yes,[rest],64) && w2_dead_in("p112_b_expected",no2,[rest],64) &&
        w2_dead_in("match_condition",yes,[rest],64) && w2_dead_in("match_condition",no2,[rest],64),
        u => W2BoolHit{w0,yes,no2,rest},
        u => W2BoolMiss{})
    case _: W2BoolMiss{}

@unsafe
def w2b_bool_cid_imm(ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,"True",index_hash("True",2166136261),32)
      nt_choose(U32,String.eq(dk(found),"N111Id"),u => U32.or(da(found),65536),u => 0)

@unsafe
def w2b_bool_fast_prefix(+word: N111Value, +l_no: U32, +l_yes: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(word,frame)
  +reg = w2_phys_dst(lh,N111U64{})
  +load_w = w2_phys_load(lh,word,ids,frame)
  +expected = w2b_bool_cid_imm(ids)
  x188_many([
    load_w,
    x188_i2("cmpq",X187Imm{0,0},reg),
    x188_i1("je",X187Target{x181_label(l_yes,frame)}),
    x188_i2("cmpq",X187Imm{1,0},reg),
    x188_i1("je",X187Target{x181_label(l_no,frame)}),
    x188_i2("movq",reg,x188_reg(10,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(10,32)),
    x188_i2("cmpl",X187Imm{expected,0},x188_reg(10,32)),
    x188_i1("je",X187Target{x181_label(l_no,frame)}),
    x188_label(x181_label(l_yes,frame))])

@unsafe
def w2b_emit_bool_fast(+word: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      # Use next = l_no, next+1 = l_end (standard x186_x_emit_yes), next+2 = l_yes!
      +prefix = w2b_bool_fast_prefix(word,next,U32.add(next,2),ids,frame)
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{prefix,chunks},U32.add(next,3),False{},error}))
"""


def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()

    # 1. Commutative addss/mulss in x186_x_arithmetic when right is already in target
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_arithmetic(+name: String, id: U32, +left: N111Value, +right: N111Value,\n"
        "    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:\n"
        "  +destination = x186_x_home(name,homes)\n"
        "  +target = x186_float_operand(destination,x188_xmm(0))\n"
        "  +source = x186_x_source(right,homes)\n"
        "  +direct = x186_x_direct(source,target)\n"
        "  x188_many([\n"
        "    nt_choose(X188Seq,direct,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),\n"
        "    x186_x_load(left,ids,frame,homes,target),\n"
        "    x188_i2(x185_float_arithmetic(id),\n"
        "      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),u => x188_xmm(1)),target),\n"
        "    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])",
        "@unsafe\ndef w2b_x_same_opt(source: Maybe<&2,X187Operand>, target: X187Operand) -> Bool:\n"
        "  match source:\n"
        "    case Some{op}: x188_operand_same(op,target)\n"
        "    case None{}: False{}\n\n"
        "@unsafe\ndef w2b_x_arith_emit(+name: String, id: U32, +left: N111Value, +right: N111Value,\n"
        "    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +destination: Maybe<&2,X187Operand>, +target: X187Operand) -> X188Seq:\n"
        "  +source = x186_x_source(right,homes)\n"
        "  +direct = x186_x_direct(source,target)\n"
        "  x188_many([\n"
        "    nt_choose(X188Seq,direct,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),\n"
        "    x186_x_load(left,ids,frame,homes,target),\n"
        "    x188_i2(x185_float_arithmetic(id),\n"
        "      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),u => x188_xmm(1)),target),\n"
        "    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])\n\n"
        "@unsafe\ndef x186_x_arithmetic(+name: String, +id: U32, +left: N111Value, +right: N111Value,\n"
        "    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:\n"
        "  +destination = x186_x_home(name,homes)\n"
        "  +target = x186_float_operand(destination,x188_xmm(0))\n"
        "  +comm = (U32.is_eq(id,26) || U32.is_eq(id,28)) && w2b_x_same_opt(x186_x_source(right,homes),target) &&\n"
        "          Bool.not(w2b_x_same_opt(x186_x_source(left,homes),target))\n"
        "  nt_choose(X188Seq,comm,\n"
        "    u => w2b_x_arith_emit(name,id,right,left,ids,frame,homes,destination,target),\n"
        "    u => w2b_x_arith_emit(name,id,left,right,ids,frame,homes,destination,target))",
        "commutative addss/mulss in x186_x_arithmetic",
    )

    # 2. Keep carried F32 value in XMM across P113DAgain:
    #    - Add w2b_x_scan_carried(nodes, cidx, scan) that does NOT forbid vals[cidx] on P113DAgain
    #    - In x186_x_emit_node P113DAgain, replace vals[cidx] with N111Local{carried} so x181_again skips GPR copy!
    src = replace_exact(
        src,
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
        "    case X186FloatPlain{+stmt}:\n"
        "      match stmt:\n"
        "        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)\n"
        "        case P113DAgain{+vals}:\n"
        "          +ce = p111v_get(homes,\"$w2_carried_xmm\")\n"
        "          +cn = p111v_get(homes,\"$w2_carried_name\")\n"
        "          +has_c = String.eq(dk(ce),\"W2Carried\")\n"
        "          +code2 = nt_choose(X181Code,has_c,\n"
        "                     u => x181_add(w2_xl_again_update(w2_xl_nth(vals,da(ce)),dx(ce),ids,frame,homes),code),\n"
        "                     u => code)\n"
        "          +stmt2 = nt_choose(P113DStmt,has_c,\n"
        "                     u => P113DAgain{w2b_replace_nth(vals,da(ce),N111Local{dk(cn)})},\n"
        "                     u => stmt)\n"
        "          x181_stmt(stmt2,ids,frame,code2)\n"
        "        case _: x181_stmt(stmt,ids,frame,code)",
        "skip GPR move for carried XMM param at P113DAgain",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef w2_xl_nth(vals: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:",
        "@unsafe\ndef w2b_replace_nth(vals: List<&2,N111Value>, +idx: U32, +repl: N111Value) -> List<&2,N111Value>:\n"
        "  match vals:\n"
        "    case Nil{}: []\n"
        "    case Con{v,+rest}:\n"
        "      nt_choose(List<&2,N111Value>,U32.is_eq(idx,0),u => Con{repl,rest},u => Con{v,w2b_replace_nth(rest,U32.sub(idx,1),repl)})\n\n"
        "@unsafe\ndef w2_xl_nth(vals: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:",
        "add w2b_replace_nth",
    )

    # Allow P113DAgain's carried arg to stay in XMM during x186_x_scan_capped!
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:\n"
        "  x186_x_scanned_capped(x186_x_scan(nodes,X186XScan{\n"
        "    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))",
        "@unsafe\ndef w2b_x_again_reads(vals: List<&2,N111Value>, +idx: U32, +cidx: U32, +ranges: X185TScan) -> X185TScan:\n"
        "  match vals:\n"
        "    case Nil{}: ranges\n"
        "    case Con{+v,rest}:\n"
        "      +r1 = nt_choose(X185TScan,U32.is_eq(idx,cidx),\n"
        "              u => x185_t_read(v,ranges),\n"
        "              u => w2_x_forbid_val(v,ranges))\n"
        "      w2b_x_again_reads(rest,U32.inc(idx),cidx,r1)\n\n"
        "law w2b_x_scan:\n"
        "  for nodes: List<&2,X186FloatNode>\n"
        "  for +cidx: U32\n"
        "  for scan: X186XScan\n"
        "  X186XScan\n\n"
        "@unsafe\ndef w2b_x_scan_node(node: X186FloatNode, +cidx: U32, +scan: X186XScan) -> X186XScan:\n"
        "  match node scan:\n"
        "    case X186FloatPlain{P113DAgain{vals}} X186XScan{ranges,canonical}:\n"
        "      X186XScan{x185_t_cut(x185_t_next(w2b_x_again_reads(vals,0,cidx,ranges))),missing()}\n"
        "    case X186FloatBranch{c,y,n} X186XScan{ranges,canonical}:\n"
        "      x186_x_cut(w2b_x_scan(n,cidx,x186_x_cut(w2b_x_scan(y,cidx,\n"
        "        X186XScan{x185_t_cut(x185_t_read(c,x185_t_cut(ranges))),missing()}))))\n"
        "    case _ _: x186_x_node(node,scan)\n\n"
        "@unsafe\ndef w2b_x_scan(nodes,cidx,scan):\n"
        "  match nodes:\n"
        "    case Nil{}: scan\n"
        "    case Con{h,rest}: w2b_x_scan(rest,cidx,w2b_x_scan_node(h,cidx,scan))\n\n"
        "@unsafe\ndef x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: U32) -> KDef:\n"
        "  x186_x_scanned_capped(w2b_x_scan(nodes,cidx,X186XScan{\n"
        "    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))",
        "allow carried P113DAgain arg to stay in XMM",
    )

    # Update w2_xl_plan to find carriedIdx first so x186_x_homes_capped knows it, and store $w2_carried_name
    src = replace_exact(
        src,
        "@unsafe\ndef w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,\n"
        "    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:\n"
        "  +tparams = w2_xl_tail_params(params)\n"
        "  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),\n"
        "    u => w2_xl_pick_carried(tparams,0,nodes,ids,frame,\n"
        "           w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),\n"
        "             w2_xl_assign_inv(tparams,0,nodes,ids,frame,\n"
        "               W2XLAlloc{x186_x_homes_capped(params,setup,nodes),X188Empty{},10}))),\n"
        "    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},\"\",0,0,False{}})\n\n"
        "@unsafe\ndef w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,\n"
        "    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:\n"
        "  match plan:\n"
        "    case W2XLoopPlan{+homes,pre,carried,cidx,+cxmm,active}:\n"
        "      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),\n"
        "                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},\"\"}))\n"
        "      +homes2 = nt_choose(KDef,U32.is_gt(cxmm,0),\n"
        "                  u => p111v_put(homes,\"$w2_carried_xmm\",\"W2Carried\",cidx,cxmm),\n"
        "                  u => homes)\n"
        "      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))",
        "@unsafe\ndef w2b_find_carried_idx(params: List<&2,String>, +idx: U32, +nodes: List<&2,X186FloatNode>) -> U32:\n"
        "  match params:\n"
        "    case Nil{}: 999999\n"
        "    case Con{+p,rest}:\n"
        "      nt_choose(U32,Bool.not(w2_xl_param_inv(p,idx,nodes)) && w2_xl_param_nowrite(p,nodes) &&\n"
        "          w2_xl_float_used(p,nodes) && w2_xl_only_float(p,nodes),\n"
        "        u => idx,u => w2b_find_carried_idx(rest,U32.inc(idx),nodes))\n\n"
        "@unsafe\ndef w2b_finish_plan(carried: String, cidx: U32, cxmm: U32, st: W2XLAlloc) -> W2XLoopPlan:\n"
        "  match st:\n"
        "    case W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,carried,cidx,cxmm,True{}}\n\n"
        "@unsafe\ndef w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,\n"
        "    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:\n"
        "  match plan:\n"
        "    case W2XLoopPlan{homes,pre,carried,cidx,+cxmm,active}:\n"
        "      +next_reg = nt_choose(U32,U32.is_gt(cxmm,0),u => U32.inc(cxmm),u => 10)\n"
        "      w2b_finish_plan(carried,cidx,cxmm,\n"
        "        w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),\n"
        "          w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,next_reg})))\n\n"
        "@unsafe\ndef w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,\n"
        "    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:\n"
        "  +tparams = w2_xl_tail_params(params)\n"
        "  +cidx_pre = w2b_find_carried_idx(tparams,0,nodes)\n"
        "  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),\n"
        "    u => w2b_plan_after_carried(\n"
        "           w2_xl_pick_carried(tparams,0,nodes,ids,frame,\n"
        "             W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidx_pre),X188Empty{},10}),\n"
        "           tparams,nodes,ids,frame),\n"
        "    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},\"\",0,0,False{}})\n\n"
        "@unsafe\ndef w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,\n"
        "    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:\n"
        "  match plan:\n"
        "    case W2XLoopPlan{+homes,pre,+carried,cidx,+cxmm,active}:\n"
        "      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),\n"
        "                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},\"\"}))\n"
        "      +homes2 = nt_choose(KDef,U32.is_gt(cxmm,0),\n"
        "                  u => p111v_put(p111v_put(homes,\"$w2_carried_xmm\",\"W2Carried\",cidx,cxmm),\"$w2_carried_name\",carried,0,0),\n"
        "                  u => homes)\n"
        "      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))",
        "pass cidx_pre to x186_x_homes_capped and store carried name",
    )

    # 3. Insert COALESCE_AND_BOOL right before w2_x_emit_branch_or_node, hook w2b_coalesce in x194fv_place,
    #    and hook w2b_bool_match in w2_x_emit_step_go!
    src = replace_exact(
        src,
        "@unsafe\ndef w2_x_emit_branch_or_node(",
        COALESCE_AND_BOOL.strip() + "\n\n@unsafe\ndef w2_x_emit_branch_or_node(",
        "insert COALESCE_AND_BOOL",
    )

    src = replace_exact(
        src,
        "  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,w2_fc_prune(w2_fc_nodes(nodes,missing()),[])),ids)",
        "  x186_f_place(symbol,params,setup,w2b_coalesce(x194fv_nodes(params,setup,w2_fc_prune(w2_fc_nodes(nodes,missing()),[])),params,[]),ids)",
        "hook w2b_coalesce after x194fv_nodes in x194fv_place",
    )

    src = replace_exact(
        src,
        "    case W2TblMiss{}: w2_x_emit_branch_or_node(nodes,ids,frame,homes,code)",
        "    case W2TblMiss{}: w2b_emit_bool_or_branch(w2b_bool_match(nodes),nodes,ids,frame,homes,code)",
        "hook w2b_bool_match in w2_x_emit_step_go",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef w2_x_emit_step_go(",
        "@unsafe\ndef w2b_emit_bool_or_branch(hit: W2BoolMatch, +nodes: List<&2,X186FloatNode>, +ids: N111Ids,\n"
        "    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:\n"
        "  match hit:\n"
        "    case W2BoolHit{word,yes,no,rest}:\n"
        "      x186_x_emit_nodes(rest,ids,frame,homes,w2b_emit_bool_fast(word,yes,no,ids,frame,homes,code))\n"
        "    case W2BoolMiss{}: w2_x_emit_branch_or_node(nodes,ids,frame,homes,code)\n\n"
        "@unsafe\ndef w2_x_emit_step_go(",
        "add w2b_emit_bool_or_branch",
    )

    # 4. Sound post-DCE w2_asr_body (keep h1, h2, h3, sel intact and ONLY rewrite dest = or(s1c, m) -> sar(v, k)
    #    when v is not written between h1 and or; run AFTER x185_dead_body followed by a second x185_dead_body!)
    src = replace_exact(
        src,
        "@unsafe\ndef w2_asr_try(found: Maybe<&2,String>, +s1: String, +v: N111Value, +k: U32,\n"
        "    +sel_rest: List<&2,P113DStmt>, +orig_head: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n"
        "  match found:\n"
        "    case Some{m}:\n"
        "      +rewritten = w2_asr_rewrite_or(sel_rest,s1,m,v,k)\n"
        "      Con{orig_head,w2_asr_body(nt_choose(List<&2,P113DStmt>,w2_asr_changed(rewritten,sel_rest),\n"
        "        u => rewritten,u => orig_tail))}\n"
        "    case None{}: Con{orig_head,w2_asr_body(orig_tail)}",
        "@unsafe\ndef w2_asr_v_written(v: N111Value, stmt: P113DStmt) -> Bool:\n"
        "  match v:\n"
        "    case N111Local{vname}: w2_dstmt_writes(vname,stmt)\n"
        "    case _: False{}\n\n"
        "law w2_asr_replace_or:\n"
        "  for +stmts: List<&2,P113DStmt>\n"
        "  for +s1: String\n"
        "  for +m: String\n"
        "  for +v: N111Value\n"
        "  for +k: U32\n"
        "  for +fuel: U32\n"
        "  List<&2,P113DStmt>\n\n"
        "@unsafe\ndef w2_asr_replace_head(+h: P113DStmt, +rest: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:\n"
        "  match h:\n"
        "    case P113DScalar{N111Bin{dest,typ,op,+l,+r}}:\n"
        "      nt_choose(List<&2,P113DStmt>,String.eq(op,\"or\") &&\n"
        "          ((String.eq(w2_asr_val_local(l),s1) && String.eq(w2_asr_val_local(r),m)) ||\n"
        "           (String.eq(w2_asr_val_local(l),m) && String.eq(w2_asr_val_local(r),s1))),\n"
        "        u => Con{P113DScalar{N111Bin{dest,N111U32{},\"sar\",v,N111Const{k,0}}},w2_asr_body(rest)},\n"
        "        u => nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),\n"
        "          z => Con{h,w2_asr_body(rest)},\n"
        "          z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))}))\n"
        "    case _: nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),\n"
        "      z => Con{h,w2_asr_body(rest)},\n"
        "      z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))})\n\n"
        "@unsafe\ndef w2_asr_replace_or_go(stmts: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:\n"
        "  match stmts:\n"
        "    case Nil{}: []\n"
        "    case Con{h,rest}: w2_asr_replace_head(h,rest,s1,m,v,k,fuel)\n\n"
        "@unsafe\ndef w2_asr_replace_or(stmts,s1,m,v,k,fuel):\n"
        "  nt_choose(List<&2,P113DStmt>,U32.is_eq(fuel,0),u => stmts,u => w2_asr_replace_or_go(stmts,s1,m,v,k,fuel))\n\n"
        "@unsafe\ndef w2_asr_try(found: Maybe<&2,String>, +s1: String, +v: N111Value, +k: U32,\n"
        "    +sel_rest: List<&2,P113DStmt>, +orig_head: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n"
        "  match found:\n"
        "    case Some{m}:\n"
        "      nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,orig_head),\n"
        "        u => Con{orig_head,w2_asr_body(orig_tail)},\n"
        "        u => Con{orig_head,w2_asr_replace_or(orig_tail,s1,m,v,k,24)})\n"
        "    case None{}: Con{orig_head,w2_asr_body(orig_tail)}",
        "sound w2_asr_try keeping intermediate stmts for DCE",
    )

    # Strip trivial N111U64 self-copies right before w2_asr_body (O(N), once per function!)
    src = replace_exact(
        src,
        "@unsafe\ndef w2_asr_body(body):",
        "law w2_asr_strip_self:\n"
        "  for body: List<&2,P113DStmt>\n"
        "  List<&2,P113DStmt>\n\n"
        "@unsafe\ndef w2_asr_strip_self(body):\n"
        "  match body:\n"
        "    case Nil{}: []\n"
        "    case Con{P113DScalar{N111Set{+a,N111U64{},N111Local{+b}}},+rest}:\n"
        "      nt_choose(List<&2,P113DStmt>,String.eq(a,b),u => w2_asr_strip_self(rest),\n"
        "        u => Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},w2_asr_strip_self(rest)})\n"
        "    case Con{P113DIf{c,yes,no},rest}:\n"
        "      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}\n"
        "    case Con{head,rest}: Con{head,w2_asr_strip_self(rest)}\n\n"
        "@unsafe\ndef w2_asr_body(body):",
        "add w2_asr_strip_self helper",
    )

    # Run w2_asr_body(w2_asr_strip_self(...)) AFTER x185_dead_body, followed by a second x185_dead_body!
    src = replace_exact(
        src,
        "  x185_function_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    w2_asr_body(x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))),ids)",
        "  x185_function_copied(symbol,params,setup,x185_dead_body(setup,w2_asr_body(w2_asr_strip_self(x185_dead_body(setup,\n"
        "    x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))))),ids)",
        "run w2_asr_body post-DCE in x186_function_memory",
    )

    src = replace_exact(
        src,
        "  x185_function_copied(symbol,names,[],x198n_body(x185_dead_body([],\n"
        "    w2_asr_body(x185_copy_function(names,[],x186_expression_body([],\n"
        "      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body))))))),params),ids)",
        "  x185_function_copied(symbol,names,[],x198n_body(x185_dead_body([],w2_asr_body(w2_asr_strip_self(x185_dead_body([],\n"
        "    x185_copy_function(names,[],x186_expression_body([],\n"
        "      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body))))))))),params),ids)",
        "run w2_asr_body post-DCE in x198n_normalized",
    )

    src = replace_exact(
        src,
        "  x199s_copied(symbol,params,setup,x185_dead_body(setup,\n"
        "    w2_asr_body(x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))),ids)",
        "  x199s_copied(symbol,params,setup,x185_dead_body(setup,w2_asr_body(w2_asr_strip_self(x185_dead_body(setup,\n"
        "    x185_copy_function(params,setup,x186_expression_body(setup,\n"
        "      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))))),ids)",
        "run w2_asr_body post-DCE in x199s_memory",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(src)
    print(f"Wrote {out_path} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

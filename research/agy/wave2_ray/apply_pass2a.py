#!/usr/bin/env python3
"""Wave 2 Track A Pass 2a (composable on top of Pass 1):
  1. Dead constant-set pruning after w2_fc_nodes (eliminates dead folded constant stores).
  2. Fused float-compare branches (ucomiss + jbe/jb) in x186_x_emit_nodes.
  3. Fused integer-compare branches + dominated negated-branch (n != 0) elimination in x186_x_emit_nodes.
  4. Branchless x195t table lookup + consecutive same-index multi-table clamp fusion in x186_x_emit_nodes.
"""
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return src.replace(old, new, 1)


PASS2A_DEAD_PRUNE = """
# Wave2 Pass 2a: Dead constant-set pruning on X186FloatNode.
@unsafe
def w2_val_reads(+name: String, value: N111Value) -> Bool:
  match value:
    case N111Local{local}: String.eq(local,name)
    case _: False{}

@unsafe
def w2_vals_reads(+name: String, values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{v,rest}: w2_val_reads(name,v) || w2_vals_reads(name,rest)

@unsafe
def w2_args_reads(+name: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{typ,v},rest}: w2_val_reads(name,v) || w2_args_reads(name,rest)

law w2_stmts_reads:
  for +name: String
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def w2_scalar_reads(+name: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{d,t,v}: w2_val_reads(name,v)
    case N111Bin{d,t,op,l,r}: w2_val_reads(name,l) || w2_val_reads(name,r)
    case N111Load{d,t,b,off}: w2_val_reads(name,b)
    case N111Store{t,b,off,v}: w2_val_reads(name,b) || w2_val_reads(name,v)
    case N111Offset{d,b,by}: w2_val_reads(name,b) || w2_val_reads(name,by)
    case N111Alloca{d,by,al}: False{}
    case N111Call{d,t,sym,args}: w2_args_reads(name,args)
    case N111If{c,yes,no}: w2_val_reads(name,c) || w2_stmts_reads(name,yes) || w2_stmts_reads(name,no)
    case N111Return{v}: w2_val_reads(name,v)

@unsafe
def w2_stmts_reads(name,body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: w2_scalar_reads(name,head) || w2_stmts_reads(name,rest)

@unsafe
def w2_scalar_writes(+name: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{d,t,v}: String.eq(d,name)
    case N111Bin{d,t,op,l,r}: String.eq(d,name)
    case N111Load{d,t,b,off}: String.eq(d,name)
    case N111Offset{d,b,by}: String.eq(d,name)
    case N111Alloca{d,by,al}: String.eq(d,name)
    case N111Call{d,t,sym,args}: String.eq(d,name)
    case _: False{}

@unsafe
def w2_names_has(+name: String, names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{n,rest}: String.eq(n,name) || w2_names_has(name,rest)

law w2_dstmts_reads:
  for +name: String
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w2_dstmt_reads(+name: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_scalar_reads(name,s)
    case P113DIf{c,yes,no}: w2_val_reads(name,c) || w2_dstmts_reads(name,yes) || w2_dstmts_reads(name,no)
    case P113DCall{names,target,args}: w2_vals_reads(name,args)
    case P113DResult{vals}: w2_vals_reads(name,vals)
    case P113DAgain{vals}: w2_vals_reads(name,vals)

@unsafe
def w2_dstmts_reads(name,body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: w2_dstmt_reads(name,head) || w2_dstmts_reads(name,rest)

@unsafe
def w2_dstmt_writes(+name: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_scalar_writes(name,s)
    case P113DCall{names,target,args}: w2_names_has(name,names)
    case _: False{}

@unsafe
def w2_dstmt_terminal(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DResult{vals}: True{}
    case P113DAgain{vals}: True{}
    case P113DScalar{N111Return{v}}: True{}
    case _: False{}

# Returns True if `name` is definitely NOT read before being overwritten or terminating,
# across `nodes` followed by outer continuation `tail` (with bounded fuel).
law w2_dead_in:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  for +tail: List<&2,List<&2,X186FloatNode>>
  for +fuel: U32
  Bool

@unsafe
def w2_dead_tail(+name: String, tail: List<&2,List<&2,X186FloatNode>>, +fuel: U32) -> Bool:
  match tail:
    case Nil{}: True{}
    case Con{head,rest}: w2_dead_in(name,head,rest,fuel)

@unsafe
def w2_dead_in_step(+name: String, nodes: List<&2,X186FloatNode>, +tail: List<&2,List<&2,X186FloatNode>>, +fuel: U32) -> Bool:
  match nodes:
    case Nil{}: w2_dead_tail(name,tail,U32.sub(fuel,1))
    case Con{X186FloatValues{dest,id,left,right},rest}:
      nt_choose(Bool,w2_val_reads(name,left) || w2_val_reads(name,right),v => False{},
        v => nt_choose(Bool,String.eq(dest,name),w => True{},
          w => w2_dead_in(name,rest,tail,U32.sub(fuel,1))))
    case Con{X186FloatBranch{cond,yes,no},+rest}:
      nt_choose(Bool,w2_val_reads(name,cond),v => False{},
        v => w2_dead_in(name,yes,Con{rest,tail},U32.sub(fuel,1)) &&
             w2_dead_in(name,no,Con{rest,tail},U32.sub(fuel,1)))
    case Con{X186FloatPlain{+stmt},rest}:
      nt_choose(Bool,w2_dstmt_reads(name,stmt),v => False{},
        v => nt_choose(Bool,w2_dstmt_terminal(stmt) || w2_dstmt_writes(name,stmt),w => True{},
          w => w2_dead_in(name,rest,tail,U32.sub(fuel,1))))

@unsafe
def w2_dead_in(name,nodes,tail,fuel):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u => w2_dead_in_step(name,nodes,tail,fuel))

law w2_fc_prune:
  for nodes: List<&2,X186FloatNode>
  for +tail: List<&2,List<&2,X186FloatNode>>
  List<&2,X186FloatNode>

@unsafe
def w2_fc_prune(nodes,tail):
  match nodes:
    case Nil{}: []
    case Con{X186FloatPlain{P113DScalar{N111Set{+dest,N111U64{},N111Const{+lo,+hi}}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,w2_dead_in(dest,rest,tail,128),
        u => w2_fc_prune(rest,tail),
        u => Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},N111Const{lo,hi}}}},w2_fc_prune(rest,tail)})
    case Con{X186FloatBranch{cond,yes,no},+rest}:
      Con{X186FloatBranch{cond,w2_fc_prune(yes,Con{rest,tail}),w2_fc_prune(no,Con{rest,tail})},w2_fc_prune(rest,tail)}
    case Con{head,rest}: Con{head,w2_fc_prune(rest,tail)}
"""


PASS2A_EMIT_HELPERS = """
# Wave2 Pass 2a: Fused float/int branches, dominated n!=0 elimination, and branchless table lookups in x186_x_emit_nodes.
@unsafe
def w2_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: String.eq(x,y)
    case N111Const{la,ha} N111Const{lb,hb}: U32.is_eq(la,lb) && U32.is_eq(ha,hb)
    case _ _: False{}

@unsafe
def w2_typ_eq(a: N111Type, b: N111Type) -> Bool:
  U32.is_eq(p111v_type(a),p111v_type(b))

@unsafe
def w2_nodes_term(nodes: List<&2,X186FloatNode>) -> Bool:
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatPlain{P113DResult{v}},Nil{}}: True{}
    case Con{X186FloatPlain{P113DAgain{v}},Nil{}}: True{}
    case Con{X186FloatPlain{P113DScalar{N111Return{v}}},Nil{}}: True{}
    case Con{X186FloatBranch{c,yes,no},Nil{}}: w2_nodes_term(yes) && w2_nodes_term(no)
    case Con{head,rest}: w2_nodes_term(rest)

@unsafe
def w2_fbranch_code(+id: U32, left: N111Value, right: N111Value, label: U32,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +swap = U32.is_eq(id,32) || U32.is_eq(id,33)
  +jcc = nt_choose(String,U32.is_eq(id,32) || U32.is_eq(id,34),u => "jbe",u => "jb")
  x188_many([
    x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x186_x_load(right,ids,frame,homes,x188_xmm(1)),
    nt_choose(X188Seq,swap,
      u => x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
      u => x188_i2("ucomiss",x188_xmm(1),x188_xmm(0))),
    x188_i1(jcc,X187Target{x181_label(label,frame)})])

@unsafe
def w2_emit_branch_custom(prefix: X188Seq, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{prefix,chunks},U32.add(next,2),False{},error}))

@unsafe
def w2_int_inv(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "jne",u =>
  nt_choose(String,String.eq(op,"ne"),u => "je",u =>
  nt_choose(String,String.eq(op,"ult"),u => "jae",u =>
  nt_choose(String,String.eq(op,"ule"),u => "ja",u =>
  nt_choose(String,String.eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,String.eq(op,"uge"),u => "jb",u =>
  nt_choose(String,String.eq(op,"slt"),u => "jge",u =>
  nt_choose(String,String.eq(op,"sle"),u => "jg",u =>
  nt_choose(String,String.eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,String.eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def w2_int_cmp_imm(+typ: N111Type, right: N111Value, +dst: X187Operand) -> X188Seq:
  match right:
    case N111Const{+lo,0}:
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647),
        u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{lo,0},dst),
        u => X188Empty{})
    case _: X188Empty{}

@unsafe
def w2_code_next(code: X181Code) -> U32:
  match code:
    case X181Code{chunks,next,terminal,error}: next

@unsafe
def w2_phys_dst(lh: X185Physical, +typ: N111Type) -> X187Operand:
  match lh:
    case X185Physical{wide,narrow,byte}: nt_choose(X187Operand,U32.is_eq(p111v_type(typ),1),u => narrow,u => wide)
    case _: x188_width_reg(typ,10)

@unsafe
def w2_phys_load(lh: X185Physical, left: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match lh:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(left,ids,frame,x188_reg(10,64))

@unsafe
def w2_phys_val(value: N111Value, frame: X181Frame) -> X185Physical:
  match value:
    case N111Local{name}: x185_physical_home(name,frame)
    case _: X185PhysicalNone{}

@unsafe
def w2_int_branch_code(+typ: N111Type, op: String, +left: N111Value, +right: N111Value,
    label: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(left,frame)
  +dst = w2_phys_dst(lh,typ)
  +load_l = w2_phys_load(lh,left,ids,frame)
  +imm = w2_int_cmp_imm(typ,right,dst)
  x188_many([load_l,
    nt_choose(X188Seq,x188_empty(imm),
      u => x188_cat(x181_load(right,ids,frame,x188_reg(11,64)),
             x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,11),dst)),
      u => imm),
    x188_i1(w2_int_inv(op),X187Target{x181_label(label,frame)})])

@unsafe
def w2_skip_dom_ne(+typ: N111Type, +left: N111Value, +right: N111Value,
    rest: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  match rest:
    case Con{X186FloatPlain{P113DScalar{N111Bin{+c2,+typ2,+op2,+l2,+r2}}},
         Con{X186FloatBranch{N111Local{+c2b},+yes2,no2},+tail2}}:
      nt_choose(List<&2,X186FloatNode>,String.eq(op2,"ne") && String.eq(c2,c2b) &&
          w2_typ_eq(typ,typ2) && w2_val_eq(left,l2) && w2_val_eq(right,r2) &&
          w2_dead_in(c2,yes2,[tail2],64),
        u => nt_append(X186FloatNode,yes2,tail2),
        u => rest)
    case _: rest

# Match x195t_load 5-node sequence and emit branchless clamp + consecutive multi-table reads.
type W2TblMatch is Data:
  W2TblHit{+dest: String, +sym: String, +val: N111Value, +last: U32, +rest: List<&2,X186FloatNode>}
  W2TblMiss{}

@unsafe
def w2_tbl_match(nodes: List<&2,X186FloatNode>) -> W2TblMatch:
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{inside,N111U64{},op,+val,N111Const{+last,0}}}},
         Con{X186FloatBranch{N111Local{inside2},
               Con{X186FloatPlain{P113DScalar{N111Set{idx1,N111U64{},+val2}}},Nil{}},
               Con{X186FloatPlain{P113DScalar{N111Set{idx2,N111U64{},N111Const{+last2,0}}}},Nil{}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{bytes,N111U64{},shlop,N111Local{idx3},N111Const{3,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Offset{addr,N111Symbol{sym},N111Local{bytes2}}}},
         Con{X186FloatPlain{P113DScalar{N111Load{dest,N111U64{},N111Local{addr2},0}}},rest}}}}}:
      nt_choose(W2TblMatch,
        String.eq(inside,"p195t_inside") && String.eq(inside2,"p195t_inside") &&
        String.eq(op,"ult") && String.eq(idx1,"p195t_index") && String.eq(idx2,"p195t_index") &&
        String.eq(idx3,"p195t_index") && String.eq(bytes,"p195t_bytes") && String.eq(bytes2,"p195t_bytes") &&
        String.eq(shlop,"shl") && String.eq(addr,"p195t_address") && String.eq(addr2,"p195t_address") &&
        U32.is_eq(last,last2) && w2_val_eq(val,val2),
        u => W2TblHit{dest,sym,val,last,rest},
        u => W2TblMiss{})
    case _: W2TblMiss{}

@unsafe
def w2_tbl_store(dest: String, sym: String, +frame: X181Frame) -> X188Seq:
  x188_many([
    x188_i2("leaq",X187Rip{sym,0,0},x188_reg(11,64)),
    x188_i2("movq",X187Indexed{11,10,8,0},x188_reg(11,64)),
    x181_store(dest,frame,x188_reg(11,64))])

@unsafe
def w2_tbl_clamp(val: N111Value, +last: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_many([
    x181_load(val,ids,frame,x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{last,0},x188_reg(10,64)),
    x188_i2("movl",X187Imm{last,0},x188_reg(11,32)),
    x188_i2("cmovaeq",x188_reg(11,64),x188_reg(10,64))])

law w2_tbl_chain:
  for +val: N111Value
  for +last: U32
  for +nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  for +code: X181Code
  X181Code

@unsafe
def w2_tbl_chain_go(hit: W2TblMatch, +val: N111Value, +last: U32, nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match hit:
    case W2TblHit{+dest,+sym,+val2,+last2,rest}:
      nt_choose(X181Code,U32.is_eq(last,last2) && w2_val_eq(val,val2),
        u => nt_choose(X181Code,w2_val_reads(dest,val),
          v => x186_x_emit_nodes(rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame),code)),
          v => w2_tbl_chain(val,last,rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame),code))),
        u => x186_x_emit_nodes(nodes,ids,frame,homes,code))
    case W2TblMiss{}: x186_x_emit_nodes(nodes,ids,frame,homes,code)

@unsafe
def w2_tbl_chain(val,last,nodes,ids,frame,homes,code):
  w2_tbl_chain_go(w2_tbl_match(nodes),val,last,nodes,ids,frame,homes,code)

@unsafe
def w2_x_emit_branch_or_node(nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  match nodes:
    case Con{X186FloatValues{+c1,+id,+left,+right},
         Con{X186FloatPlain{P113DScalar{N111Bin{+c2,typ,"eq",N111Local{+c1b},N111Const{1,0}}}},
         Con{X186FloatBranch{N111Local{+c2b},+yes,+no},+rest}}}:
      nt_choose(X181Code,U32.is_ge(id,32) && U32.is_le(id,35) && String.eq(c1,c1b) && String.eq(c2,c2b) &&
          w2_dead_in(c1,yes,[rest],64) && w2_dead_in(c1,no,[rest],64) &&
          w2_dead_in(c2,yes,[rest],64) && w2_dead_in(c2,no,[rest],64),
        u => x186_x_emit_nodes(rest,ids,frame,homes,
               w2_emit_branch_custom(w2_fbranch_code(id,left,right,w2_code_next(code),ids,frame,homes),yes,no,ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatPlain{P113DScalar{N111Bin{c2,typ,"eq",N111Local{c1b},N111Const{1,0}}}},
               Con{X186FloatBranch{N111Local{c2b},yes,no},rest}},ids,frame,homes,
               x186_x_emit_node(X186FloatValues{c1,id,left,right},ids,frame,homes,code)))
    case Con{X186FloatValues{+c1,+id,+left,+right},
         Con{X186FloatBranch{N111Local{+c1b},+yes,+no},+rest}}:
      nt_choose(X181Code,U32.is_ge(id,32) && U32.is_le(id,35) && String.eq(c1,c1b) &&
          w2_dead_in(c1,yes,[rest],64) && w2_dead_in(c1,no,[rest],64),
        u => x186_x_emit_nodes(rest,ids,frame,homes,
               w2_emit_branch_custom(w2_fbranch_code(id,left,right,w2_code_next(code),ids,frame,homes),yes,no,ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatBranch{N111Local{c1b},yes,no},rest},ids,frame,homes,
               x186_x_emit_node(X186FloatValues{c1,id,left,right},ids,frame,homes,code)))
    case Con{X186FloatPlain{P113DScalar{N111Bin{+c,+typ,+op,+left,+right}}},
         Con{X186FloatBranch{N111Local{+cb},+yes,+no},+rest}}:
      nt_choose(X181Code,String.eq(c,cb) && Bool.not(String.is_empty(w2_int_inv(op))) &&
          w2_dead_in(c,yes,[rest],64) && w2_dead_in(c,no,[rest],64),
        u => x186_x_emit_nodes(
               nt_choose(List<&2,X186FloatNode>,String.eq(op,"eq") && List.is_empty(&2,X186FloatNode,no) && w2_nodes_term(yes),
                 v => w2_skip_dom_ne(typ,left,right,rest),v => rest),
               ids,frame,homes,
               w2_emit_branch_custom(w2_int_branch_code(typ,op,left,right,w2_code_next(code),ids,frame),yes,no,ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatBranch{N111Local{cb},yes,no},rest},ids,frame,homes,
               x186_x_emit_node(X186FloatPlain{P113DScalar{N111Bin{c,typ,op,left,right}}},ids,frame,homes,code)))
    case Con{head,rest}:
      x186_x_emit_nodes(rest,ids,frame,homes,x186_x_emit_node(head,ids,frame,homes,code))
    case Nil{}: code

@unsafe
def w2_x_emit_step_go(hit: W2TblMatch, +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  match hit:
    case W2TblHit{+dest,+sym,+val,+last,rest}:
      +code1 = x181_add(x188_cat(w2_tbl_clamp(val,last,ids,frame),w2_tbl_store(dest,sym,frame)),code)
      nt_choose(X181Code,w2_val_reads(dest,val),
        u => x186_x_emit_nodes(rest,ids,frame,homes,code1),
        u => w2_tbl_chain(val,last,rest,ids,frame,homes,code1))
    case W2TblMiss{}: w2_x_emit_branch_or_node(nodes,ids,frame,homes,code)

@unsafe
def w2_x_emit_step(+nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  w2_x_emit_step_go(w2_tbl_match(nodes),nodes,ids,frame,homes,code)
"""


def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()

    # 1. Insert dead-prune helpers right before x186_x_emit_nodes (so w2_dead_in is in scope for BOTH x186_x_emit_nodes and x194fv_place!)
    src = replace_exact(
        src,
        "@unsafe\ndef x186_x_emit_nodes(nodes,ids,frame,homes,code):\n"
        "  match nodes code:\n"
        "    case Nil{} _: code\n"
        "    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:\n"
        "      nt_choose(X181Code,String.is_empty(error),u =>\n"
        "        nt_choose(X181Code,terminal,u => x181_error(\"x86 XMM plan statement after terminal\",code),\n"
        "          u => x186_x_emit_nodes(rest,ids,frame,homes,x186_x_emit_node(head,ids,frame,homes,code))),u => code)",
        PASS2A_DEAD_PRUNE.strip() + "\n\n" + PASS2A_EMIT_HELPERS.strip() + "\n\n"
        "@unsafe\ndef x186_x_emit_nodes(nodes,ids,frame,homes,code):\n"
        "  match nodes code:\n"
        "    case Nil{} _: code\n"
        "    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:\n"
        "      nt_choose(X181Code,String.is_empty(error),u =>\n"
        "        nt_choose(X181Code,terminal,u => x181_error(\"x86 XMM plan statement after terminal\",code),\n"
        "          u => w2_x_emit_step(Con{head,rest},ids,frame,homes,code)),u => code)",
        "hook Pass 2a into x186_x_emit_nodes",
    )

    # 2. Hook w2_fc_prune after w2_fc_nodes in x194fv_place
    src = replace_exact(
        src,
        "  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,w2_fc_nodes(nodes,missing())),ids)",
        "  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,w2_fc_prune(w2_fc_nodes(nodes,missing()),[])),ids)",
        "hook w2_fc_prune in x194fv_place",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(src)
    print(f"Wrote {out_path} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

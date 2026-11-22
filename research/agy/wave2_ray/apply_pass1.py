#!/usr/bin/env python3
"""Wave 2 Track A Pass 1:
  1. General F32 constant folding & propagation on X186FloatNode (U32.to_f32, F32.add/sub/mul/div/sqrt/to_u32)
     + pxor zero-load and 32-bit movl immediate float load.
  2. Dead call-setup elimination in x198qm_window (constant U32.div/mod).
  3. Dead comiss/movl cleanup in x192_float_to_u32_core.
Composable directly onto selfhost/build/agy/unified/compiler.bend.
"""
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return src.replace(old, new, 1)


FCONST_HELPERS = """
# Wave2 Track A: General F32 constant folding & propagation on X186FloatNode.
@unsafe
def w2_fc_kill_names(names: List<&2,String>, env: KDef) -> KDef:
  match names:
    case Nil{}: env
    case Con{name,rest}: w2_fc_kill_names(rest,p111v_put(env,name,"Absent",0,0))

@unsafe
def w2_fc_kill_scalar(stmt: N111Stmt, env: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p111v_put(env,name,"Absent",0,0)
    case N111Bin{name,typ,op,left,right}: p111v_put(env,name,"Absent",0,0)
    case N111Load{name,typ,base,offset}: p111v_put(env,name,"Absent",0,0)
    case N111Offset{name,base,bytes}: p111v_put(env,name,"Absent",0,0)
    case N111Alloca{name,bytes,align}: p111v_put(env,name,"Absent",0,0)
    case N111Call{name,typ,symbol,args}: p111v_put(env,name,"Absent",0,0)
    case N111If{condition,yes,no}: missing()
    case _: env

@unsafe
def w2_fc_kill_stmt(stmt: P113DStmt, env: KDef) -> KDef:
  match stmt:
    case P113DScalar{scalar}: w2_fc_kill_scalar(scalar,env)
    case P113DCall{names,target,args}: w2_fc_kill_names(names,env)
    case P113DIf{condition,yes,no}: missing()
    case _: env

@unsafe
def w2_fc_resolve(+value: N111Value, env: KDef) -> N111Value:
  match value:
    case N111Local{name}:
      +entry = p111v_get(env,name)
      nt_choose(N111Value,String.eq(dk(entry),"W2Const"),u => N111Const{da(entry),0},u => value)
    case _: value

@unsafe
def w2_fc_finite_some(+bits: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,j_private_float_finite(bits),u => Some{bits},u => None{})

@unsafe
def w2_fc_eval_unary(+id: U32, +a: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,U32.is_eq(id,23),u => Some{F32.bits(U32.to_f32(a))},u =>
    nt_choose(Maybe<&2,U32>,U32.is_eq(id,36),
      v => nt_choose(Maybe<&2,U32>,j_private_float_finite(a) && U32.is_lt(a,2147483648),
        w => w2_fc_finite_some(F32.bits(F32.sqrt(p126s_float(a)))),w => None{}),
      v => nt_choose(Maybe<&2,U32>,U32.is_eq(id,58),
        w => nt_choose(Maybe<&2,U32>,U32.is_lt(a,1333788672),
          z => Some{F32.to_u32(p126s_float(a))},z => Some{0}),
        w => None{})))

@unsafe
def w2_fc_eval_bin(+id: U32, +a: U32, +b: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,j_private_float_finite(a) && j_private_float_finite(b),
    u => nt_choose(Maybe<&2,U32>,U32.is_eq(id,26),v => w2_fc_finite_some(F32.bits(F32.add(p126s_float(a),p126s_float(b)))),
      v => nt_choose(Maybe<&2,U32>,U32.is_eq(id,27),w => w2_fc_finite_some(F32.bits(F32.sub(p126s_float(a),p126s_float(b)))),
      w => nt_choose(Maybe<&2,U32>,U32.is_eq(id,28),z => w2_fc_finite_some(F32.bits(F32.mul(p126s_float(a),p126s_float(b)))),
      z => nt_choose(Maybe<&2,U32>,U32.is_eq(id,29) && Bool.not(U32.is_eq(U32.and(b,2147483647),0)),
        q => w2_fc_finite_some(F32.bits(F32.div(p126s_float(a),p126s_float(b)))),q => None{})))),
    u => None{})

@unsafe
def w2_fc_try_fold(+id: U32, +left: N111Value, +right: N111Value) -> Maybe<&2,U32>:
  match left right:
    case N111Const{a,0} N111Const{b,0}:
      nt_choose(Maybe<&2,U32>,x200r_float_unary(id),u => w2_fc_eval_unary(id,a),u => w2_fc_eval_bin(id,a,b))
    case N111Const{a,0} _:
      nt_choose(Maybe<&2,U32>,x200r_float_unary(id),u => w2_fc_eval_unary(id,a),u => None{})
    case _ _: None{}

law w2_fc_nodes:
  for nodes: List<&2,X186FloatNode>
  for +env: KDef
  List<&2,X186FloatNode>

@unsafe
def w2_fc_after_fold(folded: Maybe<&2,U32>, +dest: String, id: U32, left: N111Value,
    right: N111Value, rest: List<&2,X186FloatNode>, +env: KDef) -> List<&2,X186FloatNode>:
  match folded:
    case Some{+bits}:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},N111Const{bits,0}}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"W2Const",bits,0))}
    case None{}:
      Con{X186FloatValues{dest,id,left,right},w2_fc_nodes(rest,p111v_put(env,dest,"Absent",0,0))}

@unsafe
def w2_fc_set(+dest: String, +val: N111Value, rest: List<&2,X186FloatNode>, +env: KDef) -> List<&2,X186FloatNode>:
  match val:
    case N111Const{lo,0}:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},N111Const{lo,0}}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"W2Const",lo,0))}
    case _:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},val}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"Absent",0,0))}

@unsafe
def w2_fc_nodes(nodes,env):
  match nodes:
    case Nil{}: []
    case Con{X186FloatValues{dest,+id,left,right},rest}:
      +l2 = w2_fc_resolve(left,env)
      +r2 = w2_fc_resolve(right,env)
      w2_fc_after_fold(w2_fc_try_fold(id,l2,r2),dest,id,l2,r2,rest,env)
    case Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},val}}},rest}:
      w2_fc_set(dest,w2_fc_resolve(val,env),rest,env)
    case Con{X186FloatBranch{condition,yes,no},rest}:
      Con{X186FloatBranch{condition,w2_fc_nodes(yes,env),w2_fc_nodes(no,env)},w2_fc_nodes(rest,missing())}
    case Con{X186FloatPlain{+stmt},rest}:
      Con{X186FloatPlain{stmt},w2_fc_nodes(rest,w2_fc_kill_stmt(stmt,env))}
"""


def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()

    # 1. Insert F32 constant folding helpers and hook into x194fv_place
    src = replace_exact(
        src,
        "@unsafe\ndef x194fv_place(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:\n"
        "  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,nodes),ids)",
        FCONST_HELPERS.strip() + "\n\n"
        "@unsafe\ndef x194fv_place(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:\n"
        "  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,w2_fc_nodes(nodes,missing())),ids)",
        "hook w2_fc_nodes in x194fv_place",
    )

    # 2. Fast constant float loads in x186_float_load_from (pxor for 0.0, movl for 32-bit imm)
    src = replace_exact(
        src,
        "@unsafe\ndef x186_float_load_from(source: Maybe<&2,X187Operand>, value: N111Value,\n"
        "    ids: N111Ids, frame: X181Frame, xmm: X187Operand) -> X188Seq:\n"
        "  match source:\n"
        "    case Some{operand}: x188_i2(\"movd\",operand,xmm)\n"
        "    case None{}: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2(\"movd\",x188_reg(10,32),xmm))",
        "@unsafe\ndef w2_float_const_load(value: N111Value, ids: N111Ids, frame: X181Frame, +xmm: X187Operand) -> X188Seq:\n"
        "  match value:\n"
        "    case N111Const{+lo,0}:\n"
        "      nt_choose(X188Seq,U32.is_eq(lo,0),u => x188_i2(\"pxor\",xmm,xmm),\n"
        "        u => x188_cat(x188_i2(\"movl\",X187Imm{lo,0},x188_reg(10,32)),x188_i2(\"movd\",x188_reg(10,32),xmm)))\n"
        "    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2(\"movd\",x188_reg(10,32),xmm))\n\n"
        "@unsafe\ndef x186_float_load_from(source: Maybe<&2,X187Operand>, value: N111Value,\n"
        "    ids: N111Ids, frame: X181Frame, xmm: X187Operand) -> X188Seq:\n"
        "  match source:\n"
        "    case Some{operand}: x188_i2(\"movd\",operand,xmm)\n"
        "    case None{}: w2_float_const_load(value,ids,frame,xmm)",
        "fast constant float load",
    )

    # 3. Dead call-setup elimination in x198qm_window / x198qm_calculate
    src = replace_exact(
        src,
        "@unsafe\ndef x198qm_calculate(+d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:\n"
        "  match plan:\n"
        "    case P198Shift{shift}:\n"
        "      x188_many([x188_i2(\"movl\",X187Mem{10,0},x188_reg(0,32)),\n"
        "        nt_choose(X188Seq,modulo,u => x188_i2(\"andl\",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),\n"
        "          u => x188_i2(\"shrl\",X187Imm{shift,0},x188_reg(0,32)))])\n"
        "    case P198Magic{m,s}:\n"
        "      x188_many([x188_i2(\"movl\",X187Mem{10,0},x188_reg(0,32)),\n"
        "        nt_choose(X188Seq,modulo,u => x188_i2(\"movl\",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),\n"
        "        x188_i2(\"movabsq\",X187Imm{m,0},x188_reg(11,64)),x188_i2(\"imulq\",x188_reg(11,64),x188_reg(0,64)),\n"
        "        x188_i2(\"shrq\",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,\n"
        "          u => x188_many([x188_i2(\"movabsq\",X187Imm{d,0},x188_reg(11,64)),x188_i2(\"imull\",x188_reg(11,32),x188_reg(0,32)),\n"
        "            x188_i2(\"subl\",x188_reg(0,32),x188_reg(10,32)),x188_i2(\"movl\",x188_reg(10,32),x188_reg(0,32))]),\n"
        "          u => X188Empty{})])\n"
        "    case P198NoQuot{}: X188Empty{}\n\n"
        "@unsafe\ndef x198qm_accept(+d: U32, +id: U32, +plan: P198Quot,\n"
        "    call: X188Seq, output: List<&2,X188Seq>) -> List<&2,X188Seq>:\n"
        "  match plan:\n"
        "    case P198NoQuot{}: Con{call,output}\n"
        "    case _: Con{x198qm_calculate(d,U32.is_eq(id,19),plan),output}\n\n"
        "@unsafe\ndef x198qm_window(+output: List<&2,X188Seq>, +call: X188Seq) -> List<&2,X188Seq>:\n"
        "  match output:\n"
        "    case Con{a,Con{b,Con{c,Con{ptr,Con{e,Con{opid,Con{state,+stores}}}}}}}:\n"
        "      match stores:\n"
        "        case Con{write,Con{literal,Con{address,rest}}}:\n"
        "          +arg = x198qm_lea(ptr,2)\n"
        "          +id = x198qm_imm(opid,6)\n"
        "          +d = x198qm_imm(literal,11)\n"
        "          nt_choose(List<&2,X188Seq>,x198qm_rr(a,\"xorl\",0,0,32) && x198qm_rr(b,\"movl\",1,1,32) &&\n"
        "            U32.is_eq(x198qm_imm(c,1),2) && x191_ff_private(arg) && U32.is_eq(arg,x198qm_lea(address,10)) &&\n"
        "            x198qm_rr(e,\"movl\",6,6,32) && (U32.is_eq(id,18) || U32.is_eq(id,19)) &&\n"
        "            x198qm_state(state) && x198qm_store(write),\n"
        "            u => x198qm_accept(d,id,p198q_plan(d),call,output),\n"
        "            u => Con{call,output})",
        "@unsafe\ndef x198qm_calculate(+arg: U32, +d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:\n"
        "  match plan:\n"
        "    case P198Shift{shift}:\n"
        "      x188_many([x188_i2(\"movl\",X187Mem{5,arg},x188_reg(0,32)),\n"
        "        nt_choose(X188Seq,modulo,u => x188_i2(\"andl\",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),\n"
        "          u => x188_i2(\"shrl\",X187Imm{shift,0},x188_reg(0,32)))])\n"
        "    case P198Magic{m,s}:\n"
        "      x188_many([x188_i2(\"movl\",X187Mem{5,arg},x188_reg(0,32)),\n"
        "        nt_choose(X188Seq,modulo,u => x188_i2(\"movl\",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),\n"
        "        x188_i2(\"movl\",X187Imm{m,0},x188_reg(11,32)),x188_i2(\"imulq\",x188_reg(11,64),x188_reg(0,64)),\n"
        "        x188_i2(\"shrq\",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,\n"
        "          u => x188_many([x188_i2(\"movl\",X187Imm{d,0},x188_reg(11,32)),x188_i2(\"imull\",x188_reg(11,32),x188_reg(0,32)),\n"
        "            x188_i2(\"subl\",x188_reg(0,32),x188_reg(10,32)),x188_i2(\"movl\",x188_reg(10,32),x188_reg(0,32))]),\n"
        "          u => X188Empty{})])\n"
        "    case P198NoQuot{}: X188Empty{}\n\n"
        "@unsafe\ndef x198qm_accept(+arg: U32, +d: U32, +id: U32, +plan: P198Quot,\n"
        "    call: X188Seq, output: List<&2,X188Seq>, rest: List<&2,X188Seq>) -> List<&2,X188Seq>:\n"
        "  match plan:\n"
        "    case P198NoQuot{}: Con{call,output}\n"
        "    case _: Con{x198qm_calculate(arg,d,U32.is_eq(id,19),plan),rest}\n\n"
        "@unsafe\ndef x198qm_window(+output: List<&2,X188Seq>, +call: X188Seq) -> List<&2,X188Seq>:\n"
        "  match output:\n"
        "    case Con{a,Con{b,Con{c,Con{ptr,Con{e,Con{opid,Con{state,+stores}}}}}}}:\n"
        "      match stores:\n"
        "        case Con{write,Con{literal,Con{address,rest}}}:\n"
        "          +arg = x198qm_lea(ptr,2)\n"
        "          +id = x198qm_imm(opid,6)\n"
        "          +d = x198qm_imm(literal,11)\n"
        "          nt_choose(List<&2,X188Seq>,x198qm_rr(a,\"xorl\",0,0,32) && x198qm_rr(b,\"movl\",1,1,32) &&\n"
        "            U32.is_eq(x198qm_imm(c,1),2) && x191_ff_private(arg) && U32.is_eq(arg,x198qm_lea(address,10)) &&\n"
        "            x198qm_rr(e,\"movl\",6,6,32) && (U32.is_eq(id,18) || U32.is_eq(id,19)) &&\n"
        "            x198qm_state(state) && x198qm_store(write),\n"
        "            u => x198qm_accept(arg,d,id,p198q_plan(d),call,output,rest),\n"
        "            u => Con{call,output})",
        "x198qm dead call-setup elimination",
    )

    # 4. Dead pxor+comiss and redundant movl in x192_float_to_u32_core
    src = replace_exact(
        src,
        "@unsafe\ndef x192_float_to_u32_core() -> X188Seq:\n"
        "  x188_many([x188_i2(\"pxor\",x188_xmm(1),x188_xmm(1)),\n"
        "    x188_i2(\"comiss\",x188_xmm(1),x188_xmm(0)),\n"
        "    x188_i2(\"movd\",x188_xmm(0),x188_reg(10,32)),\n"
        "    x188_i2(\"xorl\",x188_reg(11,32),x188_reg(11,32)),\n"
        "    x188_i2(\"cmpl\",X187Imm{1333788672,0},x188_reg(10,32)),\n"
        "    x188_i2(\"cmovael\",x188_reg(11,32),x188_reg(10,32)),\n"
        "    x188_i2(\"movd\",x188_reg(10,32),x188_xmm(0)),\n"
        "    x188_i2(\"cvttss2siq\",x188_xmm(0),x188_reg(10,64)),\n"
        "    x188_i2(\"movl\",x188_reg(10,32),x188_reg(10,32))])",
        "@unsafe\ndef x192_float_to_u32_core() -> X188Seq:\n"
        "  x188_many([x188_i2(\"movd\",x188_xmm(0),x188_reg(10,32)),\n"
        "    x188_i2(\"xorl\",x188_reg(11,32),x188_reg(11,32)),\n"
        "    x188_i2(\"cmpl\",X187Imm{1333788672,0},x188_reg(10,32)),\n"
        "    x188_i2(\"cmovael\",x188_reg(11,32),x188_reg(10,32)),\n"
        "    x188_i2(\"movd\",x188_reg(10,32),x188_xmm(0)),\n"
        "    x188_i2(\"cvttss2siq\",x188_xmm(0),x188_reg(10,64))])",
        "x192_float_to_u32_core dead comiss removal",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(src)
    print(f"Wrote {out_path} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

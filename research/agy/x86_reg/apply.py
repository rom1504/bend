#!/usr/bin/env python3
"""Patch p205-compiler.bend with AGY-004 x86 backend optimizations (individually toggleable for ablation)."""
import argparse
from pathlib import Path

BASE = Path("/home/ai/bend2_agy/selfhost/build/agy/bootstrap/p205-compiler.bend")

def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return src.replace(old, new, 1)

def apply_caps(src: str) -> str:
    # 1. Promote large recursive matches (e.g. Map.{ins,seek,pop,put}.go) from p111_ to p114r_
    src = replace_exact(
        src,
        "v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),512),",
        "v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),8192),",
        "p114h_plan cap 512->8192",
    )
    src = replace_exact(
        src,
        "&& p112f_safe(rest) && U32.is_le(p112f_size(rest),128),",
        "&& p112f_safe(rest) && U32.is_le(p112f_size(rest),2048),",
        "p112f_cont_result cap 128->2048",
    )
    src = replace_exact(
        src,
        "u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())",
        "u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],32)),u => p114h_refused())",
        "p114h_finish max cases 8->32",
    )
    # 2. Lift x190_liveness_frame and x190_joint_frame 256-stmt cap to 2048
    src = replace_exact(
        src,
        "def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:\n"
        "  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&",
        "def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:\n"
        "  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&",
        "x190_liveness_frame cap 256->2048",
    )
    src = replace_exact(
        src,
        "def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:\n"
        "  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&",
        "def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:\n"
        "  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&",
        "x190_joint_frame cap 256->2048",
    )
    # 3. Lift branch-pairs, CSE, and dead-write 4096-stmt caps to 16384 for large functions
    src = replace_exact(
        src,
        "nt_choose(KDef,reuse && U32.is_lt(p113i_size(body),4096),",
        "nt_choose(KDef,reuse && U32.is_lt(p113i_size(body),16384),",
        "x190_branch_facts_when cap 4096->16384",
    )
    src = replace_exact(
        src,
        "def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n"
        "  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&\n"
        "      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),",
        "def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n"
        "  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&\n"
        "      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),16384),",
        "x186_expression_body cap 4096->16384",
    )
    src = replace_exact(
        src,
        "def x185_dead_body(setup,body):\n"
        "  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&\n"
        "      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),",
        "def x185_dead_body(setup,body):\n"
        "  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&\n"
        "      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),16384),",
        "x185_dead_body cap 4096->16384",
    )
    return src

def apply_branch_cse(src: str) -> str:
    # 1. Propagate dominating CSE state into both arms of `if` (rest still resets to empty)
    src = replace_exact(
        src,
        "@unsafe\n"
        "def x186_e_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,\n"
        "    rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n"
        "  Con{P113DIf{condition,x186_e_body(yes,x186_e_empty()),x186_e_body(no,x186_e_empty())},x186_e_body(rest,x186_e_empty())}\n"
        "\n"
        "@unsafe\n"
        "def x186_e_body(body,state):\n"
        "  match body:\n"
        "    case Nil{}: []\n"
        "    case Con{P113DScalar{N111If{condition,yes,no}},rest}:\n"
        "      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest)\n"
        "    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest)",
        "@unsafe\n"
        "def x186_e_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,\n"
        "    rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:\n"
        "  Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}\n"
        "\n"
        "@unsafe\n"
        "def x186_e_body(body,state):\n"
        "  match body:\n"
        "    case Nil{}: []\n"
        "    case Con{P113DScalar{N111If{condition,yes,no}},rest}:\n"
        "      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)\n"
        "    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest,state)",
        "x186_e_if propagate dominating CSE state",
    )
    # 2. Emit immediate cmpq/cmpl $id, reg for N111CtorId and N111FuncId in fused branches
    src = replace_exact(
        src,
        "@unsafe\n"
        "def x190_branch_immediate_to(+typ: N111Type, value: N111Value, destination: X187Operand) -> X188Seq:\n"
        "  match value:\n"
        "    case N111Const{+lo,hi}:\n"
        "      nt_choose(X188Seq,U32.is_eq(hi,0) &&\n"
        "          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),\n"
        "        u => x188_i2(x181_width(typ,\"cmpq\",\"cmpl\"),X187Imm{lo,0},destination),\n"
        "        u => X188Empty{})\n"
        "    case _: X188Empty{}",
        "@unsafe\n"
        "def x190_branch_id_imm(+typ: N111Type, +found: KDef, destination: X187Operand) -> X188Seq:\n"
        "  nt_choose(X188Seq,String.eq(dk(found),\"N111Id\") && U32.is_le(da(found),2147483647),\n"
        "    u => x188_i2(x181_width(typ,\"cmpq\",\"cmpl\"),X187Imm{da(found),0},destination),\n"
        "    u => X188Empty{})\n"
        "\n"
        "@unsafe\n"
        "def x190_branch_immediate_to(+typ: N111Type, value: N111Value, +ids: N111Ids, destination: X187Operand) -> X188Seq:\n"
        "  match value ids:\n"
        "    case N111Const{+lo,hi} _:\n"
        "      nt_choose(X188Seq,U32.is_eq(hi,0) &&\n"
        "          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),\n"
        "        u => x188_i2(x181_width(typ,\"cmpq\",\"cmpl\"),X187Imm{lo,0},destination),\n"
        "        u => X188Empty{})\n"
        "    case N111CtorId{+name} N111Ids{functions,constructors}:\n"
        "      x190_branch_id_imm(typ,index_find(constructors,name,index_hash(name,2166136261),32),destination)\n"
        "    case N111FuncId{+name} N111Ids{functions,constructors}:\n"
        "      x190_branch_id_imm(typ,index_find(functions,name,index_hash(name,2166136261),32),destination)\n"
        "    case _ _: X188Empty{}",
        "x190_branch_immediate_to handle N111CtorId/N111FuncId",
    )
    src = replace_exact(
        src,
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x190_branch_immediate_to(typ,right,destination),u => X188Empty{})",
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x190_branch_immediate_to(typ,right,ids,destination),u => X188Empty{})",
        "x190_branch_test pass ids to x190_branch_immediate_to",
    )
    # 3. Also resolve N111CtorId/N111FuncId to N111Const for x185_immediate and x185_physical_immediate
    src = replace_exact(
        src,
        "def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:\n"
        "  match value:\n"
        "    case N111Const{+lo,+hi}:",
        "def x185_id_to_const(+value: N111Value, ids: N111Ids) -> N111Value:\n"
        "  match value ids:\n"
        "    case N111CtorId{+name} N111Ids{functions,constructors}:\n"
        "      +found = index_find(constructors,name,index_hash(name,2166136261),32)\n"
        "      nt_choose(N111Value,String.eq(dk(found),\"N111Id\"),u => N111Const{da(found),0},u => value)\n"
        "    case N111FuncId{+name} N111Ids{functions,constructors}:\n"
        "      +found = index_find(functions,name,index_hash(name,2166136261),32)\n"
        "      nt_choose(N111Value,String.eq(dk(found),\"N111Id\"),u => N111Const{da(found),0},u => value)\n"
        "    case _ _: value\n"
        "\n"
        "@unsafe\n"
        "def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:\n"
        "  match value:\n"
        "    case N111Const{+lo,+hi}:",
        "add x185_id_to_const helper",
    )
    src = replace_exact(
        src,
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x185_immediate(typ,op,right),u => X188Empty{})",
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x185_immediate(typ,op,x185_id_to_const(right,ids)),u => X188Empty{})",
        "x181_binary use x185_id_to_const",
    )
    src = replace_exact(
        src,
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),\n"
        "        u => x185_physical_immediate(typ,op,right,wide,narrow,byte),u => X188Empty{})",
        "+immediate = nt_choose(X188Seq,x185_machine_enabled(),\n"
        "        u => x185_physical_immediate(typ,op,x185_id_to_const(right,ids),wide,narrow,byte),u => X188Empty{})",
        "x185_physical_selected use x185_id_to_const",
    )
    return src

def apply_reg_pool(src: str, enable_rcx: bool, enable_r12: bool) -> str:
    if not enable_rcx and not enable_r12:
        return src

    if enable_rcx:
        # Support X185Transient index 5 -> rcx (reg 1, ABI arg 3)
        src = replace_exact(
            src,
            "def x185_transient_reg(index):\n"
            "  match index:\n"
            "    case 0: x188_reg(7,64)\n"
            "    case 1: x188_reg(6,64)\n"
            "    case 2: x188_reg(2,64)\n"
            "    case 3: x188_reg(8,64)\n"
            "    case _: x188_reg(9,64)",
            "def x185_transient_reg(index):\n"
            "  match index:\n"
            "    case 0: x188_reg(7,64)\n"
            "    case 1: x188_reg(6,64)\n"
            "    case 2: x188_reg(2,64)\n"
            "    case 3: x188_reg(8,64)\n"
            "    case 4: x188_reg(9,64)\n"
            "    case _: x188_reg(1,64)",
            "x185_transient_reg add rcx",
        )
        src = replace_exact(
            src,
            "def x185_physical_transient(index: U32) -> X185Physical:\n"
            "  match index:\n"
            "    case 0: x188_physical(7)\n"
            "    case 1: x188_physical(6)\n"
            "    case 2: x188_physical(2)\n"
            "    case 3: x188_physical(8)\n"
            "    case _: x188_physical(9)",
            "def x185_physical_transient(index: U32) -> X185Physical:\n"
            "  match index:\n"
            "    case 0: x188_physical(7)\n"
            "    case 1: x188_physical(6)\n"
            "    case 2: x188_physical(2)\n"
            "    case 3: x188_physical(8)\n"
            "    case 4: x188_physical(9)\n"
            "    case _: x188_physical(1)",
            "x185_physical_transient add rcx",
        )
        src = replace_exact(
            src,
            "def x190_l_abi(register: U32) -> U32:\n"
            "  match register:\n"
            "    case 0: 0\n"
            "    case 1: 1\n"
            "    case 2: 2\n"
            "    case 3: 4\n"
            "    case _: 5",
            "def x190_l_abi(register: U32) -> U32:\n"
            "  match register:\n"
            "    case 0: 0\n"
            "    case 1: 1\n"
            "    case 2: 2\n"
            "    case 3: 4\n"
            "    case 4: 5\n"
            "    case _: 3",
            "x190_l_abi add rcx->3",
        )
        src = replace_exact(
            src,
            "nt_choose(Maybe<&2,X187Operand>,(String.eq(dk(slot),\"X181Register\") || String.eq(dk(slot),\"X185Transient\")) && U32.is_lt(da(slot),5),",
            "nt_choose(Maybe<&2,X187Operand>,(String.eq(dk(slot),\"X181Register\") && U32.is_lt(da(slot),5)) || (String.eq(dk(slot),\"X185Transient\") && U32.is_lt(da(slot),6)),",
            "x186_float_home allow transient 5",
        )
        src = replace_exact(
            src,
            "nt_choose(U32,String.eq(dk(slot),\"X185Transient\") && U32.is_lt(da(slot),5),u => 2,u => 0))))",
            "nt_choose(U32,String.eq(dk(slot),\"X185Transient\") && U32.is_lt(da(slot),6),u => 2,u => 0))))",
            "x186_call_slot allow transient 5",
        )
        src = replace_exact(
            src,
            "(String.eq(dk(slot),\"X185Transient\") && U32.is_lt(da(slot),5))",
            "(String.eq(dk(slot),\"X185Transient\") && U32.is_lt(da(slot),6))",
            "x186_p_word_home allow transient 5",
        )

    if enable_r12:
        # Allow X181Register 0 (r12) as parallel-move destination when not holding "state"
        src = replace_exact(
            src,
            "  (String.eq(dk(slot),\"X181Register\") && U32.is_le(da(slot),4) &&\n"
            "    (Bool.not(destination) || U32.is_gt(da(slot),0))) ||",
            "  (String.eq(dk(slot),\"X181Register\") && U32.is_le(da(slot),4) &&\n"
            "    (Bool.not(destination) || Bool.not(String.eq(dn(slot),\"state\")))) ||",
            "x186_p_word_home allow r12 when not state",
        )

    rcx_flag = "True{}" if enable_rcx else "False{}"
    r12_flag = "True{}" if enable_r12 else "False{}"

    old_joint = """def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,U32.is_lt(color,4),u => U32.and(edges,U32.not(bit)),u => edges)

def x190_j_allowed(bit: U32, edges: U32, position: U32, +color: U32) -> Bool:
  nt_choose(Bool,U32.is_lt(color,4),u => True{},u =>
    U32.is_lt(color,9) && U32.is_eq(U32.and(bit,edges),0) && U32.is_ge(position,x190_l_abi(U32.sub(color,4))))

@unsafe
def x190_j_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}:
      nt_choose(U32,x190_j_allowed(bit,edges,position,color) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_j_pick(rest,bit,edges,position,U32.inc(color)))

def x190_caller_first_enabled() -> Bool: True{}

@unsafe
def x190_j_callers(groups: List<&2,U32>) -> List<&2,U32>:
  match groups:
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: rest
    case _: []

@unsafe
def x190_j_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, enabled: Bool) -> U32:
  +caller = nt_choose(U32,enabled,u => x190_j_pick(x190_j_callers(groups),bit,edges,position,4),u => 9)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,u => x190_j_pick(groups,bit,edges,position,0))

@unsafe
def x190_j_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> List<&2,U32>:
  match names rows:
    case Con{name,rest} Con{edges,more}:
      x190_j_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_j_choose(groups,bit,edges,x190_l_position(name,params,0),x190_caller_first_enabled()),bit))
    case _ _: groups"""

    new_joint = f"""def x190_j_rcx_enabled() -> Bool: {rcx_flag}
def x190_j_r12_enabled() -> Bool: {r12_flag}

def x190_j_is_const(value: N111Value) -> Bool:
  match value:
    case N111Const{{lo,hi}}: True{{}}
    case _: False{{}}

law x190_j_no_var_shift_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x190_j_no_var_shift_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Bin{{name,typ,+op,left,right}}:
      Bool.not(x181_shift(op)) || x190_j_is_const(right)
    case N111If{{condition,yes,no}}:
      x190_j_no_var_shift_body(x181_scalar_rows(yes)) && x190_j_no_var_shift_body(x181_scalar_rows(no))
    case _: True{{}}

@unsafe
def x190_j_no_var_shift_body(body):
  match body:
    case Nil{{}}: True{{}}
    case Con{{P113DScalar{{stmt}},rest}}: x190_j_no_var_shift_scalar(stmt) && x190_j_no_var_shift_body(rest)
    case Con{{P113DIf{{condition,yes,no}},rest}}:
      x190_j_no_var_shift_body(yes) && x190_j_no_var_shift_body(no) && x190_j_no_var_shift_body(rest)
    case Con{{head,rest}}: x190_j_no_var_shift_body(rest)

def x190_j_not_state_val(value: N111Value) -> Bool:
  match value:
    case N111Local{{name}}: Bool.not(String.eq(name,"state"))
    case _: True{{}}

def x190_j_not_state_vals(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{{}}: True{{}}
    case Con{{v,rest}}: x190_j_not_state_val(v) && x190_j_not_state_vals(rest)

def x190_j_not_state_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{{}}: True{{}}
    case Con{{N111Arg{{typ,v}},rest}}: x190_j_not_state_val(v) && x190_j_not_state_args(rest)

law x190_j_no_state_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x190_j_no_state_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{{name,typ,value}}: Bool.not(String.eq(name,"state")) && x190_j_not_state_val(value)
    case N111Bin{{name,typ,op,left,right}}: Bool.not(String.eq(name,"state")) && x190_j_not_state_val(left) && x190_j_not_state_val(right)
    case N111Load{{name,typ,base,offset}}: Bool.not(String.eq(name,"state")) && x190_j_not_state_val(base)
    case N111Store{{typ,base,offset,value}}: x190_j_not_state_val(base) && x190_j_not_state_val(value)
    case N111Offset{{name,base,bytes}}: Bool.not(String.eq(name,"state")) && x190_j_not_state_val(base) && x190_j_not_state_val(bytes)
    case N111Alloca{{name,bytes,align}}: Bool.not(String.eq(name,"state"))
    case N111Return{{value}}: x190_j_not_state_val(value)
    case N111If{{condition,yes,no}}: x190_j_not_state_val(condition) && x190_j_no_state_body(x181_scalar_rows(yes)) && x190_j_no_state_body(x181_scalar_rows(no))
    case N111Call{{name,typ,symbol,args}}: Bool.not(String.eq(name,"state")) && x190_j_not_state_args(args)

@unsafe
def x190_j_no_state_body(body):
  match body:
    case Nil{{}}: True{{}}
    case Con{{P113DScalar{{stmt}},rest}}: x190_j_no_state_scalar(stmt) && x190_j_no_state_body(rest)
    case Con{{P113DIf{{condition,yes,no}},rest}}:
      x190_j_not_state_val(condition) && x190_j_no_state_body(yes) && x190_j_no_state_body(no) && x190_j_no_state_body(rest)
    case Con{{P113DCall{{names,target,args}},rest}}: False{{}}
    case Con{{P113DResult{{values}},rest}}: x190_j_not_state_vals(values) && x190_j_no_state_body(rest)
    case Con{{P113DAgain{{values}},rest}}: x190_j_not_state_vals(values) && x190_j_no_state_body(rest)

def x190_j_is_public(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{{slots,bytes,calls,params,symbol}}: String.starts_with(symbol,"p111_FID_")

@unsafe
def x190_j_demote_state(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{{slots,+bytes,calls,params,symbol}}:
      +off = x181_frame_align(U32.add(bytes,8),8)
      X181Frame{{p111v_put(slots,"state","X181Stack",off,8),off,calls,params,symbol}}

def x190_j_r12_used(groups: List<&2,U32>, +index: U32) -> Bool:
  match groups:
    case Nil{{}}: False{{}}
    case Con{{mask,rest}}: nt_choose(Bool,U32.is_eq(index,10),u => Bool.not(U32.is_eq(mask,0)),u => x190_j_r12_used(rest,U32.inc(index)))

def x190_j_is_saved(+color: U32) -> Bool:
  U32.is_lt(color,4) || U32.is_eq(color,10)

def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,x190_j_is_saved(color),u => U32.and(edges,U32.not(bit)),u => edges)

def x190_j_allowed(bit: U32, edges: U32, position: U32, +color: U32, allowRcx: Bool, allowR12: Bool) -> Bool:
  nt_choose(Bool,U32.is_lt(color,4),u => True{{}},u =>
  nt_choose(Bool,U32.is_eq(color,10),v => allowR12,v =>
    (U32.is_lt(color,9) || (U32.is_eq(color,9) && allowRcx)) &&
      U32.is_eq(U32.and(bit,edges),0) && U32.is_ge(position,x190_l_abi(U32.sub(color,4)))))

@unsafe
def x190_j_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, +color: U32, +allowRcx: Bool, +allowR12: Bool) -> U32:
  match groups:
    case Nil{{}}: 11
    case Con{{mask,rest}}:
      nt_choose(U32,x190_j_allowed(bit,edges,position,color,allowRcx,allowR12) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_j_pick(rest,bit,edges,position,U32.inc(color),allowRcx,allowR12))

def x190_caller_first_enabled() -> Bool: True{{}}

@unsafe
def x190_j_callers(groups: List<&2,U32>) -> List<&2,U32>:
  match groups:
    case Con{{a,Con{{b,Con{{c,Con{{d,rest}}}}}}}}: rest
    case _: []

@unsafe
def x190_j_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, enabled: Bool, +allowRcx: Bool, +allowR12: Bool) -> U32:
  +caller = nt_choose(U32,enabled,u => x190_j_pick(x190_j_callers(groups),bit,edges,position,4,False{{}},False{{}}),u => 11)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,u => x190_j_pick(groups,bit,edges,position,0,allowRcx,allowR12))

@unsafe
def x190_j_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +allowRcx: Bool, +allowR12: Bool) -> List<&2,U32>:
  match names rows:
    case Con{{name,rest}} Con{{edges,more}}:
      x190_j_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_j_choose(groups,bit,edges,x190_l_position(name,params,0),x190_caller_first_enabled(),allowRcx,allowR12),bit),allowRcx,allowR12)
    case _ _: groups"""

    src = replace_exact(src, old_joint, new_joint, "x190_j core 11-color expansion")

    old_a_tail = """@unsafe
def x190_a_pick(groups: List<&2,U32>, +partners: U32, +bit: U32, +edges: U32, +position: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{+mask,rest}:
      nt_choose(U32,Bool.not(U32.is_eq(U32.and(mask,partners),0)) && x190_j_allowed(bit,edges,position,color) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_a_pick(rest,partners,bit,edges,position,U32.inc(color)))

@unsafe
def x190_a_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32, +position: U32) -> U32:
  +preferred = x190_a_pick(groups,partners,bit,edges,position,0)
  nt_choose(U32,U32.is_lt(preferred,9),u => preferred,
    u => x190_j_choose(groups,bit,edges,position,x190_caller_first_enabled()))

@unsafe
def x190_a_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x190_a_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,x190_l_position(name,params,0)),bit),affinities)
    case _ _: groups

@unsafe
def x190_j_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +seen: Bool) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && x190_j_allowed(bit,edges,position,color) &&
        U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0))) &&
          x190_j_valid_groups(rest,bit,edges,position,U32.inc(color),seen || here)

@unsafe
def x190_j_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),9)
    case Con{name,rest} Con{edges,more}:
      x190_j_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{}) &&
        x190_j_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def x190_j_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +color = x190_j_home(groups,bit,0)
      x190_j_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(color,4),
        u => x181_register_install(name,U32.inc(color),frame),u =>
          nt_choose(X181Frame,U32.is_lt(color,9),v => x185_t_install(name,U32.sub(color,4),frame),v => frame)))

# Every refusal returns through the complete previous allocator, including its
# saved-home selection. Never leave a fresh stack-only frame on a joint refusal.
@unsafe
def x190_allocate_legacy(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>) -> X181Frame:
  x190_liveness_frame(x181_register_frame(frame,registerBody),params,setup,body)

@unsafe
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
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])))"""

    new_a_tail = """@unsafe
def x190_a_pick(groups: List<&2,U32>, +partners: U32, +bit: U32, +edges: U32, +position: U32, +color: U32, +allowRcx: Bool, +allowR12: Bool) -> U32:
  match groups:
    case Nil{}: 11
    case Con{+mask,rest}:
      nt_choose(U32,Bool.not(U32.is_eq(U32.and(mask,partners),0)) && x190_j_allowed(bit,edges,position,color,allowRcx,allowR12) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_a_pick(rest,partners,bit,edges,position,U32.inc(color),allowRcx,allowR12))

@unsafe
def x190_a_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32, +position: U32, +allowRcx: Bool, +allowR12: Bool) -> U32:
  +preferred = x190_a_pick(groups,partners,bit,edges,position,0,allowRcx,allowR12)
  nt_choose(U32,U32.is_lt(preferred,11),u => preferred,
    u => x190_j_choose(groups,bit,edges,position,x190_caller_first_enabled(),allowRcx,allowR12))

@unsafe
def x190_a_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef, +allowRcx: Bool, +allowR12: Bool) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x190_a_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,x190_l_position(name,params,0),allowRcx,allowR12),bit),affinities,allowRcx,allowR12)
    case _ _: groups

@unsafe
def x190_j_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +seen: Bool, +allowRcx: Bool, +allowR12: Bool) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && x190_j_allowed(bit,edges,position,color,allowRcx,allowR12) &&
        U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0))) &&
          x190_j_valid_groups(rest,bit,edges,position,U32.inc(color),seen || here,allowRcx,allowR12)

@unsafe
def x190_j_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +allowRcx: Bool, +allowR12: Bool) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),11)
    case Con{name,rest} Con{edges,more}:
      x190_j_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{},allowRcx,allowR12) &&
        x190_j_valid(rest,more,params,U32.shl(bit),groups,allowRcx,allowR12)
    case _ _: False{}

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 11
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def x190_j_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +color = x190_j_home(groups,bit,0)
      x190_j_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(color,4),
        u => x181_register_install(name,U32.inc(color),frame),u =>
          nt_choose(X181Frame,U32.is_lt(color,10),v => x185_t_install(name,U32.sub(color,4),frame),
            v => nt_choose(X181Frame,U32.is_eq(color,10),w => x181_register_install(name,0,frame),w => frame))))

# Every refusal returns through the complete previous allocator, including its
# saved-home selection. Never leave a fresh stack-only frame on a joint refusal.
@unsafe
def x190_allocate_legacy(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>) -> X181Frame:
  x190_liveness_frame(x181_register_frame(frame,registerBody),params,setup,body)

@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>, +allowRcx: Bool, +allowR12: Bool) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups,allowRcx,allowR12),
    u => x190_j_install(names,groups,1,nt_choose(X181Frame,x190_j_r12_used(groups,0),v => x190_j_demote_state(frame),v => frame)),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      +allowRcx = x190_j_rcx_enabled() && x190_j_no_var_shift_body(setup) && x190_j_no_var_shift_body(body)
      +allowR12 = x190_j_r12_enabled() && Bool.not(x190_j_is_public(frame)) && x190_j_no_state_body(body)
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing())),allowRcx,allowR12),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0,0,0],allowRcx,allowR12)),allowRcx,allowR12)"""

    src = replace_exact(src, old_a_tail, new_a_tail, "x190_a + x190_j_checked 11-color expansion")
    return src

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", type=Path, default=BASE)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--caps", action="store_true", help="Lift p114h/x190/branch/CSE/dead caps")
    ap.add_argument("--rcx", action="store_true", help="Allow rcx in x190_j when no var shifts")
    ap.add_argument("--r12", action="store_true", help="Allow r12 in x190_j when state unused in body")
    ap.add_argument("--branch-cse", action="store_true", help="CSE across if arms + CtorId/FuncId cmp imm")
    ap.add_argument("--all", action="store_true", help="Enable all optimizations")
    a = ap.parse_args()
    if a.all:
        a.caps = a.rcx = a.r12 = a.branch_cse = True
    src = a.base.read_text()
    if a.caps:
        src = apply_caps(src)
    if a.branch_cse:
        src = apply_branch_cse(src)
    if a.rcx or a.r12:
        src = apply_reg_pool(src, a.rcx, a.r12)
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(src)
    print(f"Wrote {a.out} (caps={a.caps}, rcx={a.rcx}, r12={a.r12}, branch_cse={a.branch_cse})")

if __name__ == "__main__":
    main()

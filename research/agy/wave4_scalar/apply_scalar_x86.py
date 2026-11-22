#!/usr/bin/env python3
"""Wave 4 Phase 1 Track W4-4: General x86-64 Scalar Codegen, Peephole & Shrink-Wrap Optimizer.

Composable patcher transforming compiler.bend -> compiler.bend with 6 100% general passes:
  1. Spill-free U32.mod / U32.div + lea strength reduction (d in {3, 5, 9}) in x198qm.
  2. Power-of-2 multiply strength reduction (x * 2^k -> shl $k, x * 0 -> xorl) in x185_immediate / x185_physical_immediate.
  3. Machine peephole & branchless bool01 cleanup (self-movq drop, xor 1; xor 1 cancel,
     setcc+movzbl+imul -> branchless sub+and, sub 1; cmp 0; je/jne -> sub 1; je/jne).
  4. Unused state (%r12) elimination, direct incoming arg moves (no %rax bounce),
     and leaf function prologue/epilogue shrink-wrapping.
  5. General odd-parity progress certificate in x198o_progress_eval (gates speculative
     fixed-point guard on bijective/LCG recurrences like odd*x + odd) + 1-guard simplification.
  6. General scalar CSE expansion (cap 16->64, commutative lookup, U64 copy propagation)
     and higher joint-regalloc statement bound (256->512).
"""

import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave3b_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave4_scalar/compiler.bend")


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    count = src.count(old)
    if count != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {count}")
    return src.replace(old, new, 1)


def patch_1_u32_mod_div(src: str) -> str:
    """Pass 1: Spill-free U32.mod / U32.div + lea strength reduction for d in {3, 5, 9}."""
    old = """@unsafe
def x198qm_calculate(+arg: U32, +d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:
  match plan:
    case P198Shift{shift}:
      x188_many([x188_i2("movl",X187Mem{5,arg},x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("andl",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),
          u => x188_i2("shrl",X187Imm{shift,0},x188_reg(0,32)))])
    case P198Magic{m,s}:
      x188_many([x188_i2("movl",X187Mem{5,arg},x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("movl",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),
        x188_i2("movl",X187Imm{m,0},x188_reg(11,32)),x188_i2("imulq",x188_reg(11,64),x188_reg(0,64)),
        x188_i2("shrq",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,
          u => x188_many([x188_i2("movl",X187Imm{d,0},x188_reg(11,32)),x188_i2("imull",x188_reg(11,32),x188_reg(0,32)),
            x188_i2("subl",x188_reg(0,32),x188_reg(10,32)),x188_i2("movl",x188_reg(10,32),x188_reg(0,32))]),
          u => X188Empty{})])
    case P198NoQuot{}: X188Empty{}

@unsafe
def x198qm_accept(+arg: U32, +d: U32, +id: U32, +plan: P198Quot,
    call: X188Seq, output: List<&2,X188Seq>, rest: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match plan:
    case P198NoQuot{}: Con{call,output}
    case _: Con{x198qm_calculate(arg,d,U32.is_eq(id,19),plan),rest}"""

    new = """# W4-4 Pass 1: Spill-free U32.div/mod operand recovery + lea for d in {3, 5, 9}.
type W4QMDividend is Data:
  W4QMDividend{+src: X187Operand, +rest: List<&2,X188Seq>}

@unsafe
def w4_qm_store0_r11(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{11,64,False{}},X187Mem{10,0}]}}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w4_qm_load0_src(item: X188Seq) -> Maybe<&2,X187Operand>:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{+src,64,False{}},X187Reg{11,64,False{}}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq") && U32.is_lt(src,16) &&
          Bool.not(U32.is_eq(src,4) || U32.is_eq(src,5) || U32.is_eq(src,10) || U32.is_eq(src,11)),
        u => Some{x188_reg(src,32)},u => None{})
    case X188One{PInst{X187Instruction{op,[X187Mem{5,+disp},X187Reg{11,64,False{}}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq"),u => Some{X187Mem{5,disp}},u => None{})
    case _: None{}

@unsafe
def w4_qm_store0_direct(item: X188Seq) -> Maybe<&2,X187Operand>:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{+src,64,False{}},X187Mem{10,0}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq") && U32.is_lt(src,16) &&
          Bool.not(U32.is_eq(src,4) || U32.is_eq(src,5) || U32.is_eq(src,10)),
        u => Some{x188_reg(src,32)},u => None{})
    case _: None{}

@unsafe
def w4_qm_pick_load0(found: Maybe<&2,X187Operand>, +arg: U32, rest: List<&2,X188Seq>, rest2: List<&2,X188Seq>) -> W4QMDividend:
  match found:
    case Some{op}: W4QMDividend{op,rest2}
    case None{}: W4QMDividend{X187Mem{5,arg},rest}

@unsafe
def w4_qm_dividend(+arg: U32, +rest: List<&2,X188Seq>) -> W4QMDividend:
  match rest:
    case Con{s0,Con{l0,Con{a0,rest2}}}:
      nt_choose(W4QMDividend,w4_qm_store0_r11(s0) && U32.is_eq(x198qm_lea(a0,10),arg),
        u => w4_qm_pick_load0(w4_qm_load0_src(l0),arg,rest,rest2),
        u => nt_choose(W4QMDividend,U32.is_eq(x198qm_lea(l0,10),arg),
          v => w4_qm_pick_load0(w4_qm_store0_direct(s0),arg,rest,Con{a0,rest2}),
          v => W4QMDividend{X187Mem{5,arg},rest}))
    case Con{s0,Con{a0,rest2}}:
      nt_choose(W4QMDividend,U32.is_eq(x198qm_lea(a0,10),arg),
        u => w4_qm_pick_load0(w4_qm_store0_direct(s0),arg,rest,rest2),
        u => W4QMDividend{X187Mem{5,arg},rest})
    case _: W4QMDividend{X187Mem{5,arg},rest}

@unsafe
def w4_qm_mul_d(+d: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(d,3),u => x188_i2("leaq",X187Indexed{0,0,2,0},x188_reg(0,64)),u =>
  nt_choose(X188Seq,U32.is_eq(d,5),v => x188_i2("leaq",X187Indexed{0,0,4,0},x188_reg(0,64)),v =>
  nt_choose(X188Seq,U32.is_eq(d,9),w => x188_i2("leaq",X187Indexed{0,0,8,0},x188_reg(0,64)),w =>
    x188_many([x188_i2("movl",X187Imm{d,0},x188_reg(11,32)),x188_i2("imull",x188_reg(11,32),x188_reg(0,32))]))))

@unsafe
def x198qm_calculate(+srcOp: X187Operand, +d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:
  match plan:
    case P198Shift{shift}:
      x188_many([x188_i2("movl",srcOp,x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("andl",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),
          u => x188_i2("shrl",X187Imm{shift,0},x188_reg(0,32)))])
    case P198Magic{m,s}:
      x188_many([x188_i2("movl",srcOp,x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("movl",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),
        x188_i2("movl",X187Imm{m,0},x188_reg(11,32)),x188_i2("imulq",x188_reg(11,64),x188_reg(0,64)),
        x188_i2("shrq",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,
          u => x188_many([w4_qm_mul_d(d),
            x188_i2("subl",x188_reg(0,32),x188_reg(10,32)),x188_i2("movl",x188_reg(10,32),x188_reg(0,32))]),
          u => X188Empty{})])
    case P198NoQuot{}: X188Empty{}

@unsafe
def w4_qm_finish(div: W4QMDividend, +d: U32, +id: U32, +plan: P198Quot) -> List<&2,X188Seq>:
  match div:
    case W4QMDividend{srcOp,rest2}: Con{x198qm_calculate(srcOp,d,U32.is_eq(id,19),plan),rest2}

@unsafe
def x198qm_accept(+arg: U32, +d: U32, +id: U32, +plan: P198Quot,
    call: X188Seq, output: List<&2,X188Seq>, rest: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match plan:
    case P198NoQuot{}: Con{call,output}
    case _: w4_qm_finish(w4_qm_dividend(arg,rest),d,id,plan)"""

    return replace_exact(src, old, new, "Pass 1: x198qm spill-free + lea")


def patch_2_pow2_mul(src: str) -> str:
    """Pass 2: Power-of-2 multiply strength reduction (x * 2^k -> shl $k, x * 0 -> xorl)."""
    old1 = """@unsafe
def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_width_reg(typ,10)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,x188_reg(10,8)),
            x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))
    case _: X188Empty{}"""

    new1 = """@unsafe
def w4_pow2_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => w4_pow2_log(U32.shrn(d,1n),U32.inc(shift)))

@unsafe
def w4_mul_imm(+typ: N111Type, +lo: U32, +hi: U32, +left: X187Operand, +narrow: X187Operand) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  nt_choose(X188Seq,U32.is_eq(hi,0) && U32.is_eq(lo,0),
    u => x188_i2("xorl",narrow,narrow),u =>
  nt_choose(X188Seq,U32.is_eq(hi,0) && U32.is_ge(lo,2) && U32.is_eq(U32.and(lo,U32.sub(lo,1)),0),
    v => x188_i2("shl" ++ suffix,X187Imm{w4_pow2_log(lo,0),0},left),v =>
    X188Empty{}))

@unsafe
def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_width_reg(typ,10)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      +mulOpt = nt_choose(X188Seq,agy_str_eq(op,"mul"),m => w4_mul_imm(typ,lo,hi,left,x188_reg(10,32)),m => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(mulOpt)),m => mulOpt,m =>
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,x188_reg(10,8)),
            x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}"""

    src = replace_exact(src, old1, new1, "Pass 2a: x185_immediate pow2 mul")

    old2 = """@unsafe
def x185_physical_immediate(+typ: N111Type, +op: String, value: N111Value,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_physical_width(typ,wide,narrow)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))
    case _: X188Empty{}"""

    new2 = """@unsafe
def x185_physical_immediate(+typ: N111Type, +op: String, value: N111Value,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_physical_width(typ,wide,narrow)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      +mulOpt = nt_choose(X188Seq,agy_str_eq(op,"mul"),m => w4_mul_imm(typ,lo,hi,left,narrow),m => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(mulOpt)),m => mulOpt,m =>
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}"""

    return replace_exact(src, old2, new2, "Pass 2b: x185_physical_immediate pow2 mul")


def patch_3_and_4_peephole_and_shrinkwrap(src: str) -> str:
    """Pass 3 (Peephole & bool01) + Pass 4 (Unused state %r12 + direct incoming + leaf shrink-wrap)."""
    # 4a: Unused state (%r12) detection in x181_frame, x181_store_slot, x186_saves_tree
    old_frame = """@unsafe
def x181_frame(symbol,params,body):
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state","X181Register",0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  +framed = x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))
  agy_mark_bounded_frame(symbol,body,framed)"""

    new_frame = """# W4-4 Pass 4a: Detect whether "state" is ever referenced in a function body.
@unsafe
def w4_val_state(v: N111Value) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,"state")
    case _: False{}

@unsafe
def w4_vals_state(vs: List<&2,N111Value>) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: w4_val_state(v) || w4_vals_state(rest)

@unsafe
def w4_args_state(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w4_val_state(v) || w4_args_state(rest)

law w4_scalars_state:
  for ss: List<&2,N111Stmt>
  Bool

@unsafe
def w4_scalar_state(s: N111Stmt) -> Bool:
  match s:
    case N111Set{n,_,v}: agy_str_eq(n,"state") || w4_val_state(v)
    case N111Bin{n,_,_,l,r}: agy_str_eq(n,"state") || w4_val_state(l) || w4_val_state(r)
    case N111Offset{n,b,y}: agy_str_eq(n,"state") || w4_val_state(b) || w4_val_state(y)
    case N111Load{n,_,b,_}: agy_str_eq(n,"state") || w4_val_state(b)
    case N111Store{_,b,_,v}: w4_val_state(b) || w4_val_state(v)
    case N111Call{n,_,_,args}: agy_str_eq(n,"state") || w4_args_state(args)
    case N111Return{v}: w4_val_state(v)
    case N111If{c,yes,no}: w4_val_state(c) || w4_scalars_state(yes) || w4_scalars_state(no)
    case N111Alloca{n,_,_}: agy_str_eq(n,"state")

@unsafe
def w4_scalars_state(ss):
  match ss:
    case Nil{}: False{}
    case Con{h,t}: w4_scalar_state(h) || w4_scalars_state(t)

@unsafe
def w4_body_uses_state(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: w4_scalar_state(s) || w4_body_uses_state(rest)
    case Con{P113DIf{c,yes,no},rest}:
      w4_val_state(c) || w4_body_uses_state(yes) || w4_body_uses_state(no) || w4_body_uses_state(rest)
    case Con{P113DCall{_,_,_},rest}: True{}
    case Con{P113DResult{vs},rest}: w4_vals_state(vs) || w4_body_uses_state(rest)
    case Con{P113DAgain{vs},rest}: w4_vals_state(vs) || w4_body_uses_state(rest)

@unsafe
def x181_frame(symbol,params,body):
  +stateKind = nt_choose(String,w4_body_uses_state(body),u => "X181Register",u => "X181UnusedState")
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state",stateKind,0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  +framed = x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))
  agy_mark_bounded_frame(symbol,body,framed)"""

    src = replace_exact(src, old_frame, new_frame, "Pass 4a: unused state detection")

    old_store = """@unsafe
def x181_store_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",reg,X187Mem{5,U32.sub(0,da(slot))}),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Register"),
    u => x188_i2("movq",reg,x181_reg(da(slot))),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",reg,x185_transient_reg(da(slot))),
    v => x188_error("x181: invalid destination slot"))))"""

    new_store = """@unsafe
def x181_store_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181UnusedState"),u => X188Empty{},u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",reg,X187Mem{5,U32.sub(0,da(slot))}),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Register"),
    u => x188_i2("movq",reg,x181_reg(da(slot))),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",reg,x185_transient_reg(da(slot))),
    v => x188_error("x181: invalid destination slot")))))"""

    src = replace_exact(src, old_store, new_store, "Pass 4a: x181_store_slot unused state")

    old_saves = """          nt_choose(U32,agy_str_eq(kind,"X181Stack") || agy_str_eq(kind,"X181Buffer") ||
            agy_str_eq(kind,"X185Transient") || agy_str_eq(kind,"X186SavedMask") || agy_str_eq(kind,"Absent"),
            v => 0,v => 31))"""

    new_saves = """          nt_choose(U32,agy_str_eq(kind,"X181Stack") || agy_str_eq(kind,"X181Buffer") ||
            agy_str_eq(kind,"X185Transient") || agy_str_eq(kind,"X186SavedMask") ||
            agy_str_eq(kind,"X181UnusedState") || agy_str_eq(kind,"Absent"),
            v => 0,v => 31))"""

    src = replace_exact(src, old_saves, new_saves, "Pass 4a: x186_saves_tree unused state")

    # 4b: Direct incoming register moves in x181_incoming (no %rax bounce!)
    old_inc = """@unsafe
def x181_incoming(params: List<&2,String>, +n: U32, +frame: X181Frame, acc: List<&2,X188Seq>) -> X188Seq:
  match params:
    case Nil{}: x188_finish(acc)
    case Con{name,rest}:
      x181_incoming(rest,U32.inc(n),frame,Con{
        x188_cat(nt_choose(X188Seq,U32.is_lt(n,6),u => x188_i2("movq",x181_argreg(n),x188_reg(0,64)),
          u => x188_i2("movq",X187Mem{5,U32.add(16,U32.mul(U32.sub(n,6),8))},x188_reg(0,64))),
          x181_store(name,frame,x188_reg(0,64))),acc})"""

    new_inc = """@unsafe
def x181_incoming(params: List<&2,String>, +n: U32, +frame: X181Frame, acc: List<&2,X188Seq>) -> X188Seq:
  match params:
    case Nil{}: x188_finish(acc)
    case Con{+name,rest}:
      x181_incoming(rest,U32.inc(n),frame,Con{
        nt_choose(X188Seq,U32.is_lt(n,6),
          u => x181_store(name,frame,x181_argreg(n)),
          u => x188_cat(x188_i2("movq",X187Mem{5,U32.add(16,U32.mul(U32.sub(n,6),8))},x188_reg(0,64)),
            x181_store(name,frame,x188_reg(0,64)))),acc})"""

    src = replace_exact(src, old_inc, new_inc, "Pass 4b: direct x181_incoming")

    # 3 & 4c: Machine peephole + leaf shrink-wrapping hooked into x191_frame_forward
    old_ff = """@unsafe
def x191_frame_forward(code: X188Seq) -> X188Seq:
  x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code))"""

    new_ff = """# W4-4 Pass 3: General x86-64 machine peephole (self-movq, double xor 1, bool01*x, sub 1; cmp 0).
@unsafe
def w4_peep_is_jz_jnz(+op: String) -> Bool:
  agy_str_eq(op,"je") || agy_str_eq(op,"jne") || agy_str_eq(op,"jz") || agy_str_eq(op,"jnz")

@unsafe
def w4_peep_is_setcc(+op: String) -> Bool:
  String.starts_with(op,"set")

@unsafe
def w4_peep_flat(todo: List<&2,X188Seq>, acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match todo:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{X188Empty{},rest}: w4_peep_flat(rest,acc)
    case Con{X188Join{a,b},rest}: w4_peep_flat(Con{a,Con{b,rest}},acc)
    case Con{X188One{item},rest}: w4_peep_flat(rest,Con{item,acc})

@unsafe
def w4_peep_flags_kill_op(+op: String) -> Bool:
  x197d_flag_kill(op) || agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || agy_str_eq(op,"testb") ||
  agy_str_eq(op,"andl") || agy_str_eq(op,"andq") || agy_str_eq(op,"orl") || agy_str_eq(op,"orq") ||
  agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq") || agy_str_eq(op,"imull") || agy_str_eq(op,"imulq") ||
  agy_str_eq(op,"jmp") || agy_str_eq(op,"ret") || agy_str_eq(op,"call")

@unsafe
def w4_peep_flags_pass_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq") || agy_str_eq(op,"pushq") || agy_str_eq(op,"popq")

@unsafe
def w4_peep_flags_dead_list(items: List<&2,X187Parsed>, +budget: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{PLabel{_},_}: True{}
    case Con{PInst{X187Instruction{+op,_}},rest}:
      nt_choose(Bool,U32.is_eq(budget,0),u => False{},u =>
        nt_choose(Bool,w4_peep_flags_kill_op(op),v => True{},v =>
          nt_choose(Bool,w4_peep_flags_pass_op(op),w => w4_peep_flags_dead_list(rest,U32.sub(budget,1)),w => False{})))
    case _: False{}

law w4_peep_list:
  for items: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

@unsafe
def w4_peep_bool_mul(+r: U32, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{+sr,+sw,False{}},X187Reg{+dr,+dw,False{}}]}},+tail}:
      nt_choose(List<&2,X188Seq>,(agy_str_eq(mop,"imulq") || agy_str_eq(mop,"imull")) &&
          U32.is_eq(sr,r) && U32.is_eq(sw,dw) && Bool.not(U32.is_eq(sr,dr)) &&
          Bool.not(U32.is_eq(sr,11)) && Bool.not(U32.is_eq(dr,11)) &&
          w4_peep_flags_dead_list(tail,16),
        u => nt_choose(List<&2,X188Seq>,U32.is_eq(sw,64),
          v => w4_peep_list(tail,Con{x188_many([
            x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
            x188_i2("subq",x188_reg(sr,64),x188_reg(11,64)),
            x188_i2("andq",x188_reg(11,64),x188_reg(dr,64))]),out}),
          v => w4_peep_list(tail,Con{x188_many([
            x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
            x188_i2("subl",x188_reg(sr,32),x188_reg(11,32)),
            x188_i2("andl",x188_reg(11,32),x188_reg(dr,32))]),out})),
        u => w4_peep_list(rest,out))
    case _: w4_peep_list(rest,out)

@unsafe
def w4_peep_after_setcc(+r: U32, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}},
         Con{PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}},+tail}}:
      nt_choose(List<&2,X188Seq>,(agy_str_eq(x1,"xorl") || agy_str_eq(x1,"xorq")) &&
          (agy_str_eq(x2,"xorl") || agy_str_eq(x2,"xorq")) &&
          U32.is_eq(r1,r) && U32.is_eq(r2,r) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_bool_mul(r,tail,out),
        u => w4_peep_bool_mul(r,rest,out))
    case _: w4_peep_bool_mul(r,rest,out)

@unsafe
def w4_peep_sub_cmp(+rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed, +out: List<&2,X188Seq>,
    +subop: String, +cmpop: String, +r1: U32, +r2: U32, +w1: U32, +w2: U32) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+jop,[X187Target{tgt}]}},_}:
      nt_choose(List<&2,X188Seq>,((agy_str_eq(subop,"subq") && agy_str_eq(cmpop,"cmpq") && U32.is_eq(w1,64) && U32.is_eq(w2,64)) ||
          (agy_str_eq(subop,"subl") && agy_str_eq(cmpop,"cmpl") && U32.is_eq(w1,32) && U32.is_eq(w2,32))) &&
          U32.is_eq(r1,r2) && w4_peep_is_jz_jnz(jop),
        u => w4_peep_list(rest,Con{X188One{i0},out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_pair(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0 i1:
    case PInst{X187Instruction{+sop,[X187Reg{+sr,8,False{}}]}}
         PInst{X187Instruction{+mop,[X187Reg{+mr1,8,False{}},X187Reg{+mr2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_setcc(sop) && agy_str_eq(mop,"movzbl") &&
          U32.is_eq(sr,mr1) && U32.is_eq(mr1,mr2),
        u => w4_peep_after_setcc(sr,rest,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(x1,"xorq") && agy_str_eq(x2,"xorq") &&
          U32.is_eq(r1,r2) && U32.is_eq(w1,64) && U32.is_eq(w2,64) && w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+subop,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+cmpop,[X187Imm{0,0},X187Reg{+r2,+w2,False{}}]}}:
      w4_peep_sub_cmp(rest,i0,i1,out,subop,cmpop,r1,r2,w1,w2)
    case _ _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_list(items,out):
  match items:
    case Nil{}: out
    case Con{PInst{X187Instruction{+op,[X187Reg{+a,64,False{}},X187Reg{+b,64,False{}}]}},+rest}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movq") && U32.is_eq(a,b),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(rest,Con{X188One{PInst{X187Instruction{op,[X187Reg{a,64,False{}},X187Reg{b,64,False{}}]}}},out}))
    case Con{i0,Con{i1,rest}}: w4_peep_pair(i0,i1,rest,out)
    case Con{h,rest}: w4_peep_list(rest,Con{X188One{h},out})

# W4-4 Pass 4c: Leaf function prologue/epilogue shrink-wrapping.
# If a function makes 0 calls and never references %rbp or %rsp outside its
# standard prologue/epilogue, strip pushq %rbp; movq %rsp, %rbp; subq $N, %rsp
# (and replace callee-save frame slots with pushq/popq, or nothing if 0 saved).
type W4LeafPrologue is Data:
  W4LeafNone{}
  W4LeafPrologue{+prefix: List<&2,X187Parsed>, +saved: List<&2,U32>, +body: List<&2,X187Parsed>}

@unsafe
def w4_leaf_is_callee(+r: U32, +disp: U32) -> Bool:
  (U32.is_eq(r,12) && U32.is_eq(disp,4294967280)) ||
  (U32.is_eq(r,3)  && U32.is_eq(disp,4294967288)) ||
  (U32.is_eq(r,13) && U32.is_eq(disp,4294967272)) ||
  (U32.is_eq(r,14) && U32.is_eq(disp,4294967264)) ||
  (U32.is_eq(r,15) && U32.is_eq(disp,4294967256))

@unsafe
def w4_leaf_collect_saves(+items: List<&2,X187Parsed>, +prefix: List<&2,X187Parsed>, +saved: List<&2,U32>) -> W4LeafPrologue:
  match items:
    case Con{PInst{X187Instruction{+op,[X187Reg{+r,64,False{}},X187Mem{5,+disp}]}},+rest}:
      nt_choose(W4LeafPrologue,agy_str_eq(op,"movq") && w4_leaf_is_callee(r,disp),
        u => w4_leaf_collect_saves(rest,prefix,Con{r,saved}),
        u => W4LeafPrologue{prefix,nt_reverse(U32,saved,[]),Con{PInst{X187Instruction{op,[X187Reg{r,64,False{}},X187Mem{5,disp}]}},rest}})
    case _: W4LeafPrologue{prefix,nt_reverse(U32,saved,[]),items}

@unsafe
def w4_leaf_parse_prologue(items: List<&2,X187Parsed>, +prefix: List<&2,X187Parsed>) -> W4LeafPrologue:
  match items:
    case Con{PInst{X187Instruction{p1,[X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{p2,[X187Reg{4,64,False{}},X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{p3,[X187Imm{_,0},X187Reg{4,64,False{}}]}},rest}}}:
      nt_choose(W4LeafPrologue,agy_str_eq(p1,"pushq") && agy_str_eq(p2,"movq") && agy_str_eq(p3,"subq"),
        u => w4_leaf_collect_saves(rest,nt_reverse(X187Parsed,prefix,[]),[]),
        u => W4LeafNone{})
    case Con{PLabel{l},rest}: w4_leaf_parse_prologue(rest,Con{PLabel{l},prefix})
    case Con{PSection{s},rest}: w4_leaf_parse_prologue(rest,Con{PSection{s},prefix})
    case Con{PGlobal{g},rest}: w4_leaf_parse_prologue(rest,Con{PGlobal{g},prefix})
    case Con{PType{t,k},rest}: w4_leaf_parse_prologue(rest,Con{PType{t,k},prefix})
    case _: W4LeafNone{}

@unsafe
def w4_leaf_match_end(items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Con{PInst{X187Instruction{e1,[X187Reg{5,64,False{}},X187Reg{4,64,False{}}]}},
         Con{PInst{X187Instruction{e2,[X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{e3,Nil{}}},rest}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(e1,"movq") && agy_str_eq(e2,"popq") && agy_str_eq(e3,"ret"),
        u => Some{rest},u => None{})
    case _: None{}

@unsafe
def w4_leaf_match_restores(saved: List<&2,U32>, items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match saved items:
    case Nil{} _: w4_leaf_match_end(items)
    case Con{+r,sr} Con{PInst{X187Instruction{op,[X187Mem{5,+disp},X187Reg{+dr,64,False{}}]}},rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op,"movq") && U32.is_eq(dr,r) && w4_leaf_is_callee(r,disp),
        u => w4_leaf_match_restores(sr,rest),u => None{})
    case _ _: None{}

@unsafe
def w4_leaf_arg_bad(arg: X187Operand) -> Bool:
  match arg:
    case X187Reg{i,_,False{}}: U32.is_eq(i,4) || U32.is_eq(i,5)
    case X187Mem{b,_}: U32.is_eq(b,4) || U32.is_eq(b,5)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,4) || U32.is_eq(b,5) || U32.is_eq(i,4) || U32.is_eq(i,5)
    case _: False{}

@unsafe
def w4_leaf_args_bad(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4_leaf_arg_bad(a) || w4_leaf_args_bad(rest)

@unsafe
def w4_leaf_pushes(saved: List<&2,U32>) -> List<&2,X188Seq>:
  match saved:
    case Nil{}: []
    case Con{r,rest}: Con{x188_i1("pushq",x188_reg(r,64)),w4_leaf_pushes(rest)}

@unsafe
def w4_leaf_pops_rev(saved: List<&2,U32>, acc: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match saved:
    case Nil{}: acc
    case Con{r,rest}: w4_leaf_pops_rev(rest,Con{x188_i1("popq",x188_reg(r,64)),acc})

law w4_leaf_rewrite:
  for items: List<&2,X187Parsed>
  for +saved: List<&2,U32>
  for +epilogue: X188Seq
  for +out: List<&2,X188Seq>
  Maybe<&2,List<&2,X188Seq>>

@unsafe
def w4_leaf_rewrite_item(items: List<&2,X187Parsed>, +saved: List<&2,U32>, +epilogue: X188Seq, +out: List<&2,X188Seq>) -> Maybe<&2,List<&2,X188Seq>>:
  match items:
    case Nil{}: Some{out}
    case Con{PInst{X187Instruction{+op,+args}},rest}:
      nt_choose(Maybe<&2,List<&2,X188Seq>>,agy_str_eq(op,"call") || agy_str_eq(op,"ret") || w4_leaf_args_bad(args),
        u => None{},
        u => w4_leaf_rewrite(rest,saved,epilogue,Con{X188One{PInst{X187Instruction{op,args}}},out}))
    case Con{h,rest}: w4_leaf_rewrite(rest,saved,epilogue,Con{X188One{h},out})

@unsafe
def w4_leaf_rewrite_step(matched: Maybe<&2,List<&2,X187Parsed>>, items: List<&2,X187Parsed>,
    +saved: List<&2,U32>, +epilogue: X188Seq, +out: List<&2,X188Seq>) -> Maybe<&2,List<&2,X188Seq>>:
  match matched:
    case Some{rest}: w4_leaf_rewrite(rest,saved,epilogue,Con{epilogue,out})
    case None{}: w4_leaf_rewrite_item(items,saved,epilogue,out)

@unsafe
def w4_leaf_rewrite(items,saved,epilogue,out):
  match items:
    case Nil{}: Some{out}
    case Con{+h,+t}: w4_leaf_rewrite_step(w4_leaf_match_restores(saved,Con{h,t}),Con{h,t},saved,epilogue,out)

@unsafe
def w4_leaf_wrap_prefix(prefix: List<&2,X187Parsed>) -> List<&2,X188Seq>:
  match prefix:
    case Nil{}: []
    case Con{h,rest}: Con{X188One{h},w4_leaf_wrap_prefix(rest)}

@unsafe
def w4_leaf_finish(res: Maybe<&2,List<&2,X188Seq>>, original: X188Seq) -> X188Seq:
  match res:
    case Some{out}: x188_finish(out)
    case None{}: original

@unsafe
def w4_leaf_is_r12_init(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,[X187Reg{7,64,False{}},X187Reg{12,64,False{}}]}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w4_leaf_is_r12_restore(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,[X187Mem{5,4294967280},X187Reg{12,64,False{}}]}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w4_leaf_arg_uses_r12(arg: X187Operand) -> Bool:
  match arg:
    case X187Reg{12,_,False{}}: True{}
    case X187Mem{12,_}: True{}
    case X187Indexed{b,i,_,_}: U32.is_eq(b,12) || U32.is_eq(i,12)
    case _: False{}

@unsafe
def w4_leaf_args_use_r12(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4_leaf_arg_uses_r12(a) || w4_leaf_args_use_r12(rest)

@unsafe
def w4_leaf_item_uses_r12(h: X187Parsed) -> Bool:
  match h:
    case PInst{X187Instruction{_,args}}: w4_leaf_args_use_r12(args)
    case _: False{}

@unsafe
def w4_leaf_body_uses_r12(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{+h,+rest}:
      nt_choose(Bool,w4_leaf_is_r12_init(h) || w4_leaf_is_r12_restore(h),
        u => w4_leaf_body_uses_r12(rest),
        u => w4_leaf_item_uses_r12(h) || w4_leaf_body_uses_r12(rest))

@unsafe
def w4_leaf_drop_r12_list(saved: List<&2,U32>) -> List<&2,U32>:
  match saved:
    case Nil{}: []
    case Con{+r,+rest}: nt_choose(List<&2,U32>,U32.is_eq(r,12),u => w4_leaf_drop_r12_list(rest),u => Con{r,w4_leaf_drop_r12_list(rest)})

@unsafe
def w4_leaf_strip_r12_init(items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}: nt_choose(List<&2,X187Parsed>,w4_leaf_is_r12_init(h),u => w4_leaf_strip_r12_init(rest),u => Con{h,w4_leaf_strip_r12_init(rest)})

@unsafe
def w4_leaf_has_r12(saved: List<&2,U32>) -> Bool:
  match saved:
    case Nil{}: False{}
    case Con{r,rest}: U32.is_eq(r,12) || w4_leaf_has_r12(rest)

@unsafe
def w4_leaf_shrink_pro(pro: W4LeafPrologue, original: X188Seq) -> X188Seq:
  match pro:
    case W4LeafNone{}: original
    case W4LeafPrologue{prefix,+saved,+body}:
      +dropR12 = w4_leaf_has_r12(saved) && Bool.not(w4_leaf_body_uses_r12(body))
      +effSaved = nt_choose(List<&2,U32>,dropR12,u => w4_leaf_drop_r12_list(saved),u => saved)
      +effBody = nt_choose(List<&2,X187Parsed>,dropR12,u => w4_leaf_strip_r12_init(body),u => body)
      +epilogue = x188_many(nt_append(X188Seq,w4_leaf_pops_rev(effSaved,[]),[x188_i0("ret")]))
      +proSeq = x188_many(nt_append(X188Seq,w4_leaf_wrap_prefix(prefix),w4_leaf_pushes(effSaved)))
      w4_leaf_finish(w4_leaf_rewrite(effBody,saved,epilogue,[proSeq]),original)

@unsafe
def w4_leaf_shrink(items: List<&2,X187Parsed>, original: X188Seq) -> X188Seq:
  w4_leaf_shrink_pro(w4_leaf_parse_prologue(items,[]),original)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat = w4_peep_flat([code],[])
  +peeped = x188_finish(w4_peep_list(flat,[]))
  w4_leaf_shrink(w4_peep_flat([peeped],[]),peeped)

@unsafe
def x191_frame_forward(code: X188Seq) -> X188Seq:
  w4_post_select(x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code)))"""

    return replace_exact(src, old_ff, new_ff, "Pass 3 & 4c: peephole + leaf shrink-wrap")


def patch_5_gate_fixedpoint(src: str) -> str:
    """Pass 5: Parity-flipping progress certificate (gates x198o on LCGs) + 1-guard simplification."""
    old_emit = """@unsafe
def x198o_emit(prefix: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,prefix,Con{P113DScalar{N111Set{"p198a_same",N111U32{},N111Const{1,0}}},
    nt_append(P113DStmt,x198o_guards(params,values,fuel,counter),[P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}])})"""

    new_emit = """@unsafe
def w4_x198o_guards_opt(+guards: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match guards:
    case Con{P113DScalar{N111Bin{_,typ,op,l,r}},Con{_,Nil{}}}:
      [P113DScalar{N111Bin{"p198a_same",typ,op,l,r}},
       P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}]
    case _:
      Con{P113DScalar{N111Set{"p198a_same",N111U32{},N111Const{1,0}}},
        nt_append(P113DStmt,guards,[P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}])}

@unsafe
def x198o_emit(prefix: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,prefix,w4_x198o_guards_opt(x198o_guards(params,values,fuel,counter),params,values,fuel,counter))"""

    src = replace_exact(src, old_emit, new_emit, "Pass 5a: x198o single-guard simplification")

    old_prog = """type X198OProgress is Data:
  X198OProgress{+fact: X198NFact, +different: String}

type X198OProgressBinding is Data:
  X198OProgressBinding{+name: String, +value: X198OProgress}

type X198OProgressState is Data:
  X198OProgressState{+valid: Bool, +env: List<&2,X198OProgressBinding>}

@unsafe
def x198o_progress_get(+name: String, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match env:
    case Nil{}: X198OProgress{X198NUnknown{},""}
    case Con{X198OProgressBinding{key,+value},rest}: nt_choose(X198OProgress,agy_str_eq(name,key),u => value,u => x198o_progress_get(name,rest))

@unsafe
def x198o_progress_value(value: N111Value, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match value:
    case N111Const{lo,hi}: X198OProgress{X198NConst{lo,hi},""}
    case N111Local{name}: x198o_progress_get(name,env)
    case _: X198OProgress{X198NUnknown{},""}

@unsafe
def x198o_progress_initial(params: List<&2,NC_Binding>, +fuel: String) -> List<&2,X198OProgressBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198OProgressBinding{name,X198OProgress{nt_choose(X198NFact,agy_str_eq(name,fuel),u => X198NUnknown{},u => X198NAlias{name,True{}}),""}},x198o_progress_initial(rest,fuel)}

@unsafe
def x198o_progress_alias(value: X198NFact) -> String:
  match value:
    case X198NAlias{+name,narrow}: nt_choose(String,narrow,u => name,u => "")
    case _: ""

@unsafe
def x198o_progress_copy(value: X198OProgress, +typ: N111Type) -> X198OProgress:
  match value:
    case X198OProgress{fact,different}: X198OProgress{x198n_width(fact,typ),different}

@unsafe
def x198o_progress_diff(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact) -> String:
  nt_choose(String,U32.is_eq(p113k_width(typ),32),u =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && x198n_low_nonzero(right),v => x198o_progress_alias(left),v =>
      nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && x198n_low_nonzero(left),w => x198o_progress_alias(right),w => "")),u => "")

@unsafe
def x198o_progress_bin(+typ: N111Type, +op: String, left: X198OProgress, right: X198OProgress) -> X198OProgress:
  match left right:
    case X198OProgress{+a,ad} X198OProgress{+b,bd}:
      +x = x198n_width(a,typ)
      +y = x198n_width(b,typ)
      X198OProgress{x198n_bin(typ,op,x,y),x198o_progress_diff(typ,op,x,y)}"""

    new_prog = """# W4-4 Pass 5b: General parity-flipping progress certificate in x198o.
# Tracks `sameParity`: a U32 value with the exact same LSB as `param`.
# Multiplying by any odd constant preserves `sameParity`; adding/subbing/xoring
# any odd constant flips LSB -> `different = param` (mathematically zero fixed points in Z/2^32Z).
type X198OProgress is Data:
  X198OProgress{+fact: X198NFact, +different: String, +sameParity: String}

type X198OProgressBinding is Data:
  X198OProgressBinding{+name: String, +value: X198OProgress}

type X198OProgressState is Data:
  X198OProgressState{+valid: Bool, +env: List<&2,X198OProgressBinding>}

@unsafe
def w4_const_odd(f: X198NFact) -> Bool:
  match f:
    case X198NConst{lo,_}: U32.is_eq(U32.and(lo,1),1)
    case _: False{}

@unsafe
def w4_const_even(f: X198NFact) -> Bool:
  match f:
    case X198NConst{lo,_}: U32.is_eq(U32.and(lo,1),0)
    case _: False{}

@unsafe
def x198o_progress_get(+name: String, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match env:
    case Nil{}: X198OProgress{X198NUnknown{},"",""}
    case Con{X198OProgressBinding{key,+value},rest}: nt_choose(X198OProgress,agy_str_eq(name,key),u => value,u => x198o_progress_get(name,rest))

@unsafe
def x198o_progress_value(value: N111Value, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match value:
    case N111Const{lo,hi}: X198OProgress{X198NConst{lo,hi},"",""}
    case N111Local{name}: x198o_progress_get(name,env)
    case _: X198OProgress{X198NUnknown{},"",""}

@unsafe
def x198o_progress_initial(params: List<&2,NC_Binding>, +fuel: String) -> List<&2,X198OProgressBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      +isFuel = agy_str_eq(name,fuel)
      Con{X198OProgressBinding{name,X198OProgress{
        nt_choose(X198NFact,isFuel,u => X198NUnknown{},u => X198NAlias{name,True{}}),
        "",
        nt_choose(String,isFuel,u => "",u => name)}},x198o_progress_initial(rest,fuel)}

@unsafe
def x198o_progress_alias(value: X198NFact) -> String:
  match value:
    case X198NAlias{+name,narrow}: nt_choose(String,narrow,u => name,u => "")
    case _: ""

@unsafe
def x198o_progress_copy(value: X198OProgress, +typ: N111Type) -> X198OProgress:
  match value:
    case X198OProgress{fact,different,sp}: X198OProgress{x198n_width(fact,typ),different,sp}

@unsafe
def x198o_progress_diff(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact, +lsp: String, +rsp: String, +ld: String, +rd: String) -> String:
  +d0 = nt_choose(String,U32.is_eq(p113k_width(typ),32),u =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && x198n_low_nonzero(right),v => x198o_progress_alias(left),v =>
      nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && x198n_low_nonzero(left),w => x198o_progress_alias(right),w => "")),u => "")
  nt_choose(String,Bool.not(String.is_empty(d0)),u => d0,u =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_odd(right) && Bool.not(String.is_empty(lsp)),v => lsp,v =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_odd(left) && Bool.not(String.is_empty(rsp)),w => rsp,w =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_even(right) && Bool.not(String.is_empty(ld)),z => ld,z =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_even(left) && Bool.not(String.is_empty(rd)),q => rd,q => "")))))

@unsafe
def w4_progress_parity(+op: String, +left: X198NFact, +right: X198NFact, +lsp: String, +rsp: String) -> String:
  nt_choose(String,agy_str_eq(op,"mul") && w4_const_odd(right) && Bool.not(String.is_empty(lsp)),u => lsp,u =>
  nt_choose(String,agy_str_eq(op,"mul") && w4_const_odd(left) && Bool.not(String.is_empty(rsp)),v => rsp,v =>
  nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_even(right) && Bool.not(String.is_empty(lsp)),w => lsp,w =>
  nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_even(left) && Bool.not(String.is_empty(rsp)),z => rsp,z => ""))))

@unsafe
def x198o_progress_bin(+typ: N111Type, +op: String, left: X198OProgress, right: X198OProgress) -> X198OProgress:
  match left right:
    case X198OProgress{+a,+ad,+asp} X198OProgress{+b,+bd,+bsp}:
      +x = x198n_width(a,typ)
      +y = x198n_width(b,typ)
      X198OProgress{x198n_bin(typ,op,x,y),x198o_progress_diff(typ,op,x,y,asp,bsp,ad,bd),w4_progress_parity(op,x,y,asp,bsp)}"""

    src = replace_exact(src, old_prog, new_prog, "Pass 5b: x198o parity progress certificate")

    old_is = """@unsafe
def x198o_progress_is(value: X198OProgress, name: String) -> Bool:
  match value:
    case X198OProgress{fact,+different}: Bool.not(String.is_empty(different)) && agy_str_eq(different,name)"""

    new_is = """@unsafe
def x198o_progress_is(value: X198OProgress, name: String) -> Bool:
  match value:
    case X198OProgress{fact,+different,_}: Bool.not(String.is_empty(different)) && agy_str_eq(different,name)"""

    return replace_exact(src, old_is, new_is, "Pass 5b: x198o_progress_is pattern")


def patch_6_cse_and_regalloc(src: str) -> str:
    """Pass 6: General scalar CSE expansion (cap 16->64, commutative lookup, U64 copy) + regalloc bound 256->512."""
    old_cse_alias = """      X186ExprState{facts,nt_choose(List<&2,X186Alias>,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),16),
        u => Con{X186Alias{name,value},aliases},u => aliases)}"""

    new_cse_alias = """      X186ExprState{facts,nt_choose(List<&2,X186Alias>,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),64),
        u => Con{X186Alias{name,value},aliases},u => aliases)}"""

    src = replace_exact(src, old_cse_alias, new_cse_alias, "Pass 6a: CSE alias cap 16->64")

    old_cse_find = """@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,a,b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          agy_str_eq(op,operation) && x186_e_equal(left,a) && x186_e_equal(right,b),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))

@unsafe
def x186_e_insert(state: X186ExprState, +name: String, kind: U32, typ: N111Type, op: String,
    +left: N111Value, +right: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{+facts,aliases}:
      X186ExprState{nt_choose(List<&2,X186Expr>,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) &&
          U32.is_lt(nt_count(X186Expr,facts),16),
        u => Con{X186Expr{name,kind,typ,op,left,right},facts},u => facts),aliases}"""

    new_cse_find = """@unsafe
def w4_cse_comm(+op: String) -> Bool:
  agy_str_eq(op,"add") || agy_str_eq(op,"mul") || agy_str_eq(op,"and") ||
    agy_str_eq(op,"or") || agy_str_eq(op,"xor")

@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          agy_str_eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))

@unsafe
def x186_e_insert(state: X186ExprState, +name: String, kind: U32, typ: N111Type, op: String,
    +left: N111Value, +right: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{+facts,aliases}:
      X186ExprState{nt_choose(List<&2,X186Expr>,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) &&
          U32.is_lt(nt_count(X186Expr,facts),64),
        u => Con{X186Expr{name,kind,typ,op,left,right},facts},u => facts),aliases}"""

    src = replace_exact(src, old_cse_find, new_cse_find, "Pass 6b: CSE cap 16->64 + commutative")

    old_cse_found = """    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,typ,N111Local{source}})},
      x186_e_result_alias(state,name,typ,source)}"""

    new_cse_found = """    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,N111U64{},N111Local{source}})},
      x186_e_result_alias(state,name,N111U64{},source)}"""

    src = replace_exact(src, old_cse_found, new_cse_found, "Pass 6c: CSE U64 canonical copy")

    old_cse_set = """@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, value: N111Value, +state: X186ExprState) -> X186ExprStep:
  x186_e_set_state(state,stmt,name,typ,value)"""

    new_cse_set = """@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, +value: N111Value, +state: X186ExprState) -> X186ExprStep:
  nt_choose(X186ExprStep,U32.is_eq(p111v_type(typ),1),
    u => x186_e_expression(state,stmt,name,2,N111U32{},"zext32",value,N111Const{0,0}),
    u => x186_e_set_state(state,stmt,name,typ,value))"""

    src = replace_exact(src, old_cse_set, new_cse_set, "Pass 6c2: CSE U32 zext32")

    old_joint = """def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&"""

    new_joint = """def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512) &&"""

    src = replace_exact(src, old_joint, new_joint, "Pass 6d: x190_joint_frame bound 256->512")

    old_live = """def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&"""

    new_live = """def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512) &&"""

    return replace_exact(src, old_live, new_live, "Pass 6e: x190_liveness_frame bound 256->512")


def apply_all(src: str) -> str:
    src = patch_1_u32_mod_div(src)
    src = patch_2_pow2_mul(src)
    src = patch_3_and_4_peephole_and_shrinkwrap(src)
    src = patch_5_gate_fixedpoint(src)
    src = patch_6_cse_and_regalloc(src)
    return src


def main():
    ap = argparse.ArgumentParser(description="Apply Wave 4 Track W4-4 scalar x86-64 codegen optimizations")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    text = args.src.read_text()
    patched = apply_all(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(patched)
    print(f"Patched {args.src} -> {args.dst} ({len(text)} -> {len(patched)} bytes)")


if __name__ == "__main__":
    main()

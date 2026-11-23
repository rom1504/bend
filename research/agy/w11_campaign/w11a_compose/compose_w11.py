#!/usr/bin/env python3
"""Compose selfhost/build/agy/wave11_unified/compiler.bend from wave10_unified/compiler.bend (read-only).

Integrates all Wave 11 pure-Bend upgrades:
  1. P5-E Scoped nq_signature_user: restore Wave 8 $product.* specialization for all local/single-file
     defs (db(d) == False), scoping nq_signature_opaque strictly to imported P86Seed/Base defs (db(d) == True).
  2. P5-B -O2 Modular Hang & Collision Fix:
     (a) Exclude weak_set (imported P86Seed) stubs from p114r eligibility, call-site rewrites, and
         p114r emission in x86-module / --trace x86-module / --trace-slow x86-module.
     (b) Add p114r_FID_* to w10_is_mod_local_sym and w10_weak_add_def (plus $product.* belt-and-suspenders).
  3. P5-A m00 2-function match-bomb fix: flatten p186ch_expand and w2_asr_strip_self.
  4. P5-F m04 5-function -O2 cliff fix: flatten w5b_try_ror16, w5b_try_rol16, w5b_try_cmp_jcc,
     w5b_try_cmp_bounce, w5b_try_sel_bounce.
  5. P5-D Fast Pure-Bend x86-iface (fast_iface_emit.bend).
  6. P5-A String.order.go fast path (agy_sh_emit_strcmp for read/direct/owned).
  7. P5-F --trace-slow <ms> per-function profiler (trace_slow.bend).
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave10_unified/compiler.bend"
FAST_IFACE = ROOT / "research/agy/w10_mod_bend/p5_fast_iface/fast_iface_emit.bend"
TRACE_SLOW = ROOT / "research/agy/w10_mod_bend/p5_trace_slow/trace_slow.bend"
OUT_DIR = ROOT / "selfhost/build/agy/wave11_unified"
OUT = OUT_DIR / "compiler.bend"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------------------------
# 1. Scoped nq_signature_user (P5-E) & p113k_function pure-leaf exemption (W11-B)
# ---------------------------------------------------------------------------
OLD_P113K_FN = """@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +seed = w4c_seed_w32_facts(params,missing())
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),2048),
        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)"""

NEW_P113K_FN = """@unsafe
def w11_p113k_has_call(xs: List<&2,P113DStmt>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{P113DCall{_, _, _}, _}: True{}
    case Con{P113DIf{_, yes, no}, rest}:
      w11_p113k_has_call(yes) || w11_p113k_has_call(no) || w11_p113k_has_call(rest)
    case Con{_, rest}:
      w11_p113k_has_call(rest)

@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +sz = p113i_size(body)
      +ok = U32.is_lt(sz,2048) || (U32.is_lt(sz,16384) && Bool.not(w11_p113k_has_call(body)))
      +seed = w4c_seed_w32_facts(params,missing())
      nt_choose(P113DFunction,ok,
        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)"""

OLD_NQ_SIG_USER = """@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  nq_signature_opaque(name)"""

NEW_NQ_SIG_USER = """@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  nt_choose(KDef, db(d),
    u => nq_signature_opaque(name),
    u =>
      +arity = nd_arity(book, name)
      nt_choose(KDef, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))),
        v => nq_signature_tele(name, arity, nq_tele(book, dt(d), arity, 256, Nil{})),
        v => nq_signature_opaque(name)))"""


# ---------------------------------------------------------------------------
# 3. P5-A Flatten p186ch_expand & w2_asr_strip_self
# ---------------------------------------------------------------------------
OLD_P186CH = """@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+kind,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          u => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}"""

NEW_P186CH = """@unsafe
def w11_n111_is_u64(t: N111Type) -> Bool:
  match t:
    case N111U64{}: True{}
    case _: False{}

@unsafe
def w11_n111_is_ptr(t: N111Type) -> Bool:
  match t:
    case N111Ptr{}: True{}
    case _: False{}

@unsafe
def w11_n111_is_u32(t: N111Type) -> Bool:
  match t:
    case N111U32{}: True{}
    case _: False{}

@unsafe
def w11_val_local(v: N111Value) -> Maybe<&2,String>:
  match v:
    case N111Local{nm}: Some{nm}
    case _: None{}

@unsafe
def w11_val_const32(v: N111Value) -> Maybe<&2,U32>:
  match v:
    case N111Const{lo,hi}: nt_choose(Maybe<&2,U32>,U32.is_eq(hi,0),u => Some{lo},u => None{})
    case _: None{}

@unsafe
def w11_arg_ptr_local(a: N111Arg) -> Maybe<&2,String>:
  match a:
    case N111Arg{t,v}:
      nt_choose(Maybe<&2,String>,w11_n111_is_ptr(t),u => w11_val_local(v),u => None{})

@unsafe
def w11_arg_u32_const(a: N111Arg) -> Maybe<&2,U32>:
  match a:
    case N111Arg{t,v}:
      nt_choose(Maybe<&2,U32>,w11_n111_is_u32(t),u => w11_val_const32(v),u => None{})

@unsafe
def w11_arg_u64_val(a: N111Arg) -> Maybe<&2,N111Value>:
  match a:
    case N111Arg{t,v}:
      nt_choose(Maybe<&2,N111Value>,w11_n111_is_u64(t),u => Some{v},u => None{})

@unsafe
def w11_p186ch_take_a4(+stmt: N111Stmt, +dest: String, +word: N111Value, +buffer: String, m4: Maybe<&2,U32>) -> P114TExpansion:
  match m4:
    case Some{n}:
      nt_choose(P114TExpansion,U32.is_eq(n,1),
        u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_a3(+stmt: N111Stmt, +dest: String, +word: N111Value, m3: Maybe<&2,String>, a4: N111Arg) -> P114TExpansion:
  match m3:
    case Some{+buffer}:
      nt_choose(P114TExpansion,Bool.not(agy_str_eq(buffer,"state")),
        u => w11_p186ch_take_a4(stmt,dest,word,buffer,w11_arg_u32_const(a4)),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_a2(+stmt: N111Stmt, +dest: String, m2: Maybe<&2,N111Value>, a3: N111Arg, a4: N111Arg) -> P114TExpansion:
  match m2:
    case Some{word}: w11_p186ch_take_a3(stmt,dest,word,w11_arg_ptr_local(a3),a4)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_a1(+stmt: N111Stmt, +dest: String, m1: Maybe<&2,U32>, a2: N111Arg, a3: N111Arg, a4: N111Arg) -> P114TExpansion:
  match m1:
    case Some{k}:
      nt_choose(P114TExpansion,U32.is_eq(k,5),
        u => w11_p186ch_take_a2(stmt,dest,w11_arg_u64_val(a2),a3,a4),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take5(+stmt: N111Stmt, +dest: String, m0: Maybe<&2,String>, a1: N111Arg, a2: N111Arg, a3: N111Arg, a4: N111Arg) -> P114TExpansion:
  match m0:
    case Some{state}:
      nt_choose(P114TExpansion,agy_str_eq(state,"state"),
        u => w11_p186ch_take_a1(stmt,dest,w11_arg_u32_const(a1),a2,a3,a4),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_r4(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, a2: N111Arg, a3: N111Arg, r4: List<&2,N111Arg>) -> P114TExpansion:
  match r4:
    case Con{a4,Nil{}}: w11_p186ch_take5(stmt,dest,w11_arg_ptr_local(a0),a1,a2,a3,a4)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_r3(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, a2: N111Arg, r3: List<&2,N111Arg>) -> P114TExpansion:
  match r3:
    case Con{a3,r4}: w11_p186ch_take_r4(stmt,dest,a0,a1,a2,a3,r4)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_r2(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, r2: List<&2,N111Arg>) -> P114TExpansion:
  match r2:
    case Con{a2,r3}: w11_p186ch_take_r3(stmt,dest,a0,a1,a2,r3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take_r1(+stmt: N111Stmt, +dest: String, a0: N111Arg, r1: List<&2,N111Arg>) -> P114TExpansion:
  match r1:
    case Con{a1,r2}: w11_p186ch_take_r2(stmt,dest,a0,a1,r2)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take(+stmt: N111Stmt, +dest: String, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{a0,r1}: w11_p186ch_take_r1(stmt,dest,a0,r1)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_a3(+stmt: N111Stmt, +dest: String, +kind: U32, +buffer: String, m3: Maybe<&2,U32>) -> P114TExpansion:
  match m3:
    case Some{+n}:
      nt_choose(P114TExpansion,U32.is_eq(kind,5) && U32.is_eq(n,1),
        w => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
        w => nt_choose(P114TExpansion,U32.is_eq(n,0) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          z => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          z => P114TExpansion{[stmt],False{}}))
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_a2(+stmt: N111Stmt, +dest: String, +kind: U32, m2: Maybe<&2,String>, a3: N111Arg) -> P114TExpansion:
  match m2:
    case Some{+buffer}:
      nt_choose(P114TExpansion,Bool.not(agy_str_eq(buffer,"state")),
        u => w11_p186ch_ctor_a3(stmt,dest,kind,buffer,w11_arg_u32_const(a3)),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_a1(+stmt: N111Stmt, +dest: String, m1: Maybe<&2,U32>, a2: N111Arg, a3: N111Arg) -> P114TExpansion:
  match m1:
    case Some{kind}: w11_p186ch_ctor_a2(stmt,dest,kind,w11_arg_ptr_local(a2),a3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor4(+stmt: N111Stmt, +dest: String, m0: Maybe<&2,String>, a1: N111Arg, a2: N111Arg, a3: N111Arg) -> P114TExpansion:
  match m0:
    case Some{state}:
      nt_choose(P114TExpansion,agy_str_eq(state,"state"),
        u => w11_p186ch_ctor_a1(stmt,dest,w11_arg_u32_const(a1),a2,a3),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_r3(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, a2: N111Arg, r3: List<&2,N111Arg>) -> P114TExpansion:
  match r3:
    case Con{a3,Nil{}}: w11_p186ch_ctor4(stmt,dest,w11_arg_ptr_local(a0),a1,a2,a3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_r2(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, r2: List<&2,N111Arg>) -> P114TExpansion:
  match r2:
    case Con{a2,r3}: w11_p186ch_ctor_r3(stmt,dest,a0,a1,a2,r3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_r1(+stmt: N111Stmt, +dest: String, a0: N111Arg, r1: List<&2,N111Arg>) -> P114TExpansion:
  match r1:
    case Con{a1,r2}: w11_p186ch_ctor_r2(stmt,dest,a0,a1,r2)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor(+stmt: N111Stmt, +dest: String, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{a0,r1}: w11_p186ch_ctor_r1(stmt,dest,a0,r1)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,typ,+symbol,args}:
      nt_choose(P114TExpansion,w11_n111_is_u64(typ),
        u => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take"),
          v => w11_p186ch_take(stmt,dest,args),
          v => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor"),
            w => w11_p186ch_ctor(stmt,dest,args),
            w => P114TExpansion{[stmt],False{}})),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}"""


OLD_W2_ASR = """@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+a,N111U64{},N111Local{+b}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(a,b),u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},w2_asr_strip_self(rest)})
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case Con{P113DScalar{N111Bin{+d,+t,+op,N111Const{2,0},+x}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,N111Const{2,0},x}},w2_asr_strip_self(rest)})
    case Con{P113DScalar{N111Bin{+d,+t,+op,+x,N111Const{2,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,x,N111Const{2,0}}},w2_asr_strip_self(rest)})
    case Con{head,rest}: Con{head,w2_asr_strip_self(rest)}"""

NEW_W2_ASR = """@unsafe
def w11_val_is_const2(v: N111Value) -> Bool:
  match v:
    case N111Const{lo,hi}: U32.is_eq(lo,2) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def w11_val_local_eq(v: N111Value, +a: String) -> Bool:
  match v:
    case N111Local{b}: agy_str_eq(a,b)
    case _: False{}

@unsafe
def w11_asr_strip_scalar(+s: N111Stmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match s:
    case N111Set{+a,typ,val}:
      nt_choose(List<&2,P113DStmt>,w11_n111_is_u64(typ) && w11_val_local_eq(val,a),
        u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{s},w2_asr_strip_self(rest)})
    case N111Bin{+d,+t,+op,+left,+right}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul") && w11_val_is_const2(left),
        u => Con{P113DScalar{N111Bin{d,t,"add",right,right}},w2_asr_strip_self(rest)},
        u => nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul") && w11_val_is_const2(right),
          v => Con{P113DScalar{N111Bin{d,t,"add",left,left}},w2_asr_strip_self(rest)},
          v => Con{P113DScalar{s},w2_asr_strip_self(rest)}))
    case _: Con{P113DScalar{s},w2_asr_strip_self(rest)}

@unsafe
def w11_asr_strip_head(head: P113DStmt, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match head:
    case P113DScalar{s}: w11_asr_strip_scalar(s,rest)
    case P113DIf{c,yes,no}: Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case other: Con{other,w2_asr_strip_self(rest)}

@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: w11_asr_strip_head(head,rest)"""


# ---------------------------------------------------------------------------
# 4. P5-F Flatten 5 w5b_try_* matchers in m04
# ---------------------------------------------------------------------------
OLD_W5B_MATCHERS = """# Try 16-bit rotate pattern R1 (shr-first):
#   movq %rX, %rA; shrq $k, %rA; movq %rA, %rB; movq %rX, %rA; shll $(16-k), %rA32; orq %rB, %rA; andq $65535, %rA
@unsafe
def w5b_try_ror16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{ra3,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{ra4,w4,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shrq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"movq") &&
            (agy_str_eq(op4,"shll") || agy_str_eq(op4,"shlq")) &&
            agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2,rA) && U32.is_eq(rx3,rX) &&
            U32.is_eq(ra3,rA) && U32.is_eq(ra4,rA) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rorw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try 16-bit rotate pattern R2 (shl-first):
#   movq %rX, %rA; shlq $k, %rA; movl %rA32, %rA32; movq %rX, %rB; shrq $(16-k), %rB; orq %rB, %rA; andq $65535, %rA
@unsafe
def w5b_try_rol16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2a,32,False{}},Con{X187Reg{ra2b,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{rb4,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shlq") && agy_str_eq(op2,"movl") && agy_str_eq(op3,"movq") &&
            agy_str_eq(op4,"shrq") && agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2a,rA) && U32.is_eq(ra2b,rA) &&
            U32.is_eq(rx3,rX) && U32.is_eq(rb4,rB) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rolw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne -> cmp + j<cc>
@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    # Pattern B2a: setcc %rA8; movzbl %rA8,%rA32; xorl $1,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opX,"xorl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rx,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B2b: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; xorl $1,%rB32; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opX,"xorl") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) && U32.is_eq(rx,rB) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B1: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isE),[X187Target{lbl}]}},tail}}},
        u => None{})
    case _: None{}

# Try movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d -> cmpq %rB, %rA; setcc; movzbl
@unsafe
def w5b_try_cmp_bounce(+rA: U32, +rT1: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{+rB,64,False{}},Con{X187Reg{+rT2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{c1,64,False{}},Con{X187Reg{c2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opS,Con{X187Reg{rs,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},+tail}}}}:
      +ok = agy_str_eq(op1,"movq") && agy_str_eq(op2,"cmpq") && agy_str_eq(opZ,"movzbl") &&
            Bool.not(String.is_empty(w5b_set_cc(opS))) &&
            U32.is_eq(c1,rT2) && U32.is_eq(c2,rT1) && U32.is_eq(rs,rT1) &&
            U32.is_eq(rz1,rT1) && U32.is_eq(rz2,rT1) &&
            Bool.not(U32.is_eq(rT1,rT2)) && Bool.not(U32.is_eq(rB,rT1)) &&
            w5b_reg_dead_fast(rT2,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

# Try spill-bounce: movq %rS, %rT; movq %rT, d(%rbp) (rT in {10,11}, rT dead) -> movq %rS, d(%rbp)
@unsafe
def w5b_try_spill_bounce(+rS: U32, +rT: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{rt1,64,False{}},Con{X187Mem{5,+disp},Nil{}}}}},+tail}:
      +ok = agy_str_eq(op1,"movq") && U32.is_eq(rt1,rT) && (U32.is_eq(rT,10) || U32.is_eq(rT,11)) &&
            Bool.not(U32.is_eq(rS,rT)) && w5b_reg_dead_fast(rT,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[x188_reg(rS,64),X187Mem{5,disp}]}},tail}},
        u => None{})
    case _: None{}

# Try select-bounce: movq %r10, %rax; movq d(%rbp), %r10; movq %rN, %r11; testl %eax,%eax; cmovneq %r10,%r11; movq %r11, dst
#   (%rax,%r10,%r11,%rN dead) -> movq d(%rbp), %r11; testl %r10d,%r10d; cmovneq %r11,%rN; movq %rN, dst
@unsafe
def w5b_try_sel_bounce(+rA: U32, +rD: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{+srcY,Con{X187Reg{r10a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+rN,64,False{}},Con{X187Reg{r11a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{0,32,False{}},Con{X187Reg{0,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Reg{r10b,64,False{}},Con{X187Reg{r11b,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{r11c,64,False{}},Con{+dst,Nil{}}}}},+tail}}}}}:
      +ok = U32.is_eq(rA,10) && U32.is_eq(rD,0) &&
            agy_str_eq(op1,"movq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"testl") &&
            agy_str_eq(op4,"cmovneq") && agy_str_eq(op5,"movq") &&
            U32.is_eq(r10a,10) && U32.is_eq(r11a,11) && U32.is_eq(r10b,10) &&
            U32.is_eq(r11b,11) && U32.is_eq(r11c,11) &&
            Bool.not(U32.is_eq(rN,10)) && Bool.not(U32.is_eq(rN,11)) && Bool.not(U32.is_eq(rN,0)) &&
            w5b_reg_dead_fast(0,tail,fnItems) && w5b_reg_dead_fast(10,tail,fnItems) &&
            w5b_reg_dead_fast(11,tail,fnItems) && w5b_reg_dead_fast(rN,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[srcY,x188_reg(11,64)]}},
                  Con{PInst{X187Instruction{"testl",[x188_reg(10,32),x188_reg(10,32)]}},
                  Con{PInst{X187Instruction{"cmovneq",[x188_reg(11,64),x188_reg(rN,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},tail}}}}},
        u => None{})
    case _: None{}"""

NEW_W5B_MATCHERS = """# Shallow instruction-matching helpers (eliminates -O2 x187_pub cliff in m04)
@unsafe
def w11_some_u32_eq(m: Maybe<&2,U32>, +want: U32) -> Bool:
  match m:
    case Some{r}: U32.is_eq(r,want)
    case _: False{}

@unsafe
def w11_op_reg(op: X187Operand, +w: U32) -> Maybe<&2,U32>:
  match op:
    case X187Reg{r,rw,hi}:
      nt_choose(Maybe<&2,U32>,(U32.is_eq(w,0) || U32.is_eq(rw,w)) && Bool.not(hi),u => Some{r},u => None{})
    case _: None{}

@unsafe
def w11_op_reg_eq(op: X187Operand, +want: U32, +w: U32) -> Bool:
  w11_some_u32_eq(w11_op_reg(op,w),want)

@unsafe
def w11_op_imm32(op: X187Operand) -> Maybe<&2,U32>:
  match op:
    case X187Imm{lo,hi}: nt_choose(Maybe<&2,U32>,U32.is_eq(hi,0),u => Some{lo},u => None{})
    case _: None{}

@unsafe
def w11_op_target(op: X187Operand) -> Maybe<&2,String>:
  match op:
    case X187Target{lbl}: Some{lbl}
    case _: None{}

@unsafe
def w11_ops2_imm_reg(ops: List<&2,X187Operand>, +want_r: U32, +rw: U32) -> Maybe<&2,U32>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: nt_choose(Maybe<&2,U32>,w11_op_reg_eq(o1,want_r,rw),u => w11_op_imm32(o0),u => None{})
    case _: None{}

@unsafe
def w11_inst_imm_reg(item: X187Parsed, +want_op: String, +want_r: U32, +rw: U32) -> Maybe<&2,U32>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,want_op),u => w11_ops2_imm_reg(ops,want_r,rw),u => None{})
    case _: None{}

@unsafe
def w11_inst_imm_eq_reg(item: X187Parsed, +want_op: String, +want_imm: U32, +want_r: U32, +rw: U32) -> Bool:
  w11_some_u32_eq(w11_inst_imm_reg(item,want_op,want_r,rw),want_imm)

@unsafe
def w11_ops2_reg_dst(ops: List<&2,X187Operand>, +want_src: U32, +w1: U32, +w2: U32) -> Maybe<&2,U32>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: nt_choose(Maybe<&2,U32>,w11_op_reg_eq(o0,want_src,w1),u => w11_op_reg(o1,w2),u => None{})
    case _: None{}

@unsafe
def w11_inst_reg_dst(item: X187Parsed, +want_op: String, +want_src: U32, +w1: U32, +w2: U32) -> Maybe<&2,U32>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,want_op),u => w11_ops2_reg_dst(ops,want_src,w1,w2),u => None{})
    case _: None{}

@unsafe
def w11_inst_reg_reg_eq(item: X187Parsed, +want_op: String, +r1: U32, +w1: U32, +r2: U32, +w2: U32) -> Bool:
  w11_some_u32_eq(w11_inst_reg_dst(item,want_op,r1,w1,w2),r2)

@unsafe
def w11_ops2_src_reg(ops: List<&2,X187Operand>, +want_dst: U32, +w1: U32, +w2: U32) -> Maybe<&2,U32>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: nt_choose(Maybe<&2,U32>,w11_op_reg_eq(o1,want_dst,w2),u => w11_op_reg(o0,w1),u => None{})
    case _: None{}

@unsafe
def w11_inst_src_reg(item: X187Parsed, +want_op: String, +want_dst: U32, +w1: U32, +w2: U32) -> Maybe<&2,U32>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,want_op),u => w11_ops2_src_reg(ops,want_dst,w1,w2),u => None{})
    case _: None{}

@unsafe
def w11_ops2_any_reg(ops: List<&2,X187Operand>, +want_dst: U32, +w2: U32) -> Maybe<&2,X187Operand>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: nt_choose(Maybe<&2,X187Operand>,w11_op_reg_eq(o1,want_dst,w2),u => Some{o0},u => None{})
    case _: None{}

@unsafe
def w11_inst_any_reg(item: X187Parsed, +want_op: String, +want_dst: U32, +w2: U32) -> Maybe<&2,X187Operand>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,want_op),u => w11_ops2_any_reg(ops,want_dst,w2),u => None{})
    case _: None{}

@unsafe
def w11_ops2_reg_any(ops: List<&2,X187Operand>, +want_src: U32, +w1: U32) -> Maybe<&2,X187Operand>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: nt_choose(Maybe<&2,X187Operand>,w11_op_reg_eq(o0,want_src,w1),u => Some{o1},u => None{})
    case _: None{}

@unsafe
def w11_inst_reg_any(item: X187Parsed, +want_op: String, +want_src: U32, +w1: U32) -> Maybe<&2,X187Operand>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,want_op),u => w11_ops2_reg_any(ops,want_src,w1),u => None{})
    case _: None{}

type W11PairU32 is Data:
  W11PairU32{+a: U32, +b: U32}

type W11SetCC is Data:
  W11SetCC{+op: String, +reg: U32}

type W11Jcc is Data:
  W11Jcc{+isN: Bool, +lbl: String}

@unsafe
def w11_pair_some_u32(a: Maybe<&2,U32>, b: Maybe<&2,U32>) -> Maybe<&2,W11PairU32>:
  match a b:
    case Some{r0} Some{r1}: Some{W11PairU32{r0,r1}}
    case _ _: None{}

@unsafe
def w11_ops2_reg_reg(ops: List<&2,X187Operand>, +w1: U32, +w2: U32) -> Maybe<&2,W11PairU32>:
  match ops:
    case Con{o0,Con{o1,Nil{}}}: w11_pair_some_u32(w11_op_reg(o0,w1),w11_op_reg(o1,w2))
    case _: None{}

@unsafe
def w11_inst_reg_reg(item: X187Parsed, +want_op: String, +w1: U32, +w2: U32) -> Maybe<&2,W11PairU32>:
  match item:
    case PInst{X187Instruction{op,ops}}:
      nt_choose(Maybe<&2,W11PairU32>,agy_str_eq(op,want_op),u => w11_ops2_reg_reg(ops,w1,w2),u => None{})
    case _: None{}

@unsafe
def w11_tag_setcc(+op: String, mr: Maybe<&2,U32>) -> Maybe<&2,W11SetCC>:
  match mr:
    case Some{r}: Some{W11SetCC{op,r}}
    case _: None{}

@unsafe
def w11_ops1_setcc(+op: String, ops: List<&2,X187Operand>) -> Maybe<&2,W11SetCC>:
  match ops:
    case Con{o0,Nil{}}: w11_tag_setcc(op,w11_op_reg(o0,8))
    case _: None{}

@unsafe
def w11_inst_setcc(item: X187Parsed) -> Maybe<&2,W11SetCC>:
  match item:
    case PInst{X187Instruction{+op,ops}}:
      nt_choose(Maybe<&2,W11SetCC>,Bool.not(String.is_empty(w5b_set_cc(op))),u => w11_ops1_setcc(op,ops),u => None{})
    case _: None{}

@unsafe
def w11_tag_jcc(+isN: Bool, ml: Maybe<&2,String>) -> Maybe<&2,W11Jcc>:
  match ml:
    case Some{lbl}: Some{W11Jcc{isN,lbl}}
    case _: None{}

@unsafe
def w11_ops1_jcc(+isN: Bool, ops: List<&2,X187Operand>) -> Maybe<&2,W11Jcc>:
  match ops:
    case Con{o0,Nil{}}: w11_tag_jcc(isN,w11_op_target(o0))
    case _: None{}

@unsafe
def w11_inst_jcc(item: X187Parsed) -> Maybe<&2,W11Jcc>:
  match item:
    case PInst{X187Instruction{+op,ops}}:
      +isE = agy_str_eq(op,"je") || agy_str_eq(op,"jz")
      +isN = agy_str_eq(op,"jne") || agy_str_eq(op,"jnz")
      nt_choose(Maybe<&2,W11Jcc>,isE || isN,u => w11_ops1_jcc(isN,ops),u => None{})
    case _: None{}

# Try 16-bit rotate pattern R1 (shr-first)
@unsafe
def w11_rot16_s6(+rotOp: String, +rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i6,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i6,"andq",65535,rA,64) && w5b_reg_dead_fast(rB,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{rotOp,[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

@unsafe
def w11_rot16_s5(+rotOp: String, +rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i5,r6}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i5,"orq",rB,64,rA,64),
        u => w11_rot16_s6(rotOp,rX,rA,rB,k,r6,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_m(+rX: U32, +rA: U32, +rB: U32, +k: U32, m_opt: Maybe<&2,U32>, r5: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m_opt:
    case Some{m}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(U32.add(k,m),16),
        u => w11_rot16_s5("rorw",rX,rA,rB,k,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_maybe_u32_or(a: Maybe<&2,U32>, b: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match a:
    case Some{v}: Some{v}
    case _: b

@unsafe
def w11_ror16_s4(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i4,r5}:
      w11_ror16_m(rX,rA,rB,k,w11_maybe_u32_or(w11_inst_imm_reg(i4,"shll",rA,0),w11_inst_imm_reg(i4,"shlq",rA,0)),r5,fnItems)
    case _: None{}

@unsafe
def w11_ror16_s3(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i3,"movq",rX,64,rA,64),
        u => w11_ror16_s4(rX,rA,rB,k,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_rb(+rX: U32, +rA: U32, +k: U32, rb_opt: Maybe<&2,U32>, r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{+rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)),
        u => w11_ror16_s3(rX,rA,rB,k,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_s2(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}: w11_ror16_rb(rX,rA,k,w11_inst_reg_dst(i2,"movq",rA,64,64),r3,fnItems)
    case _: None{}

@unsafe
def w11_ror16_k(+rX: U32, +rA: U32, k_opt: Maybe<&2,U32>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match k_opt:
    case Some{+k}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_ge(k,1) && U32.is_le(k,15),
        u => w11_ror16_s2(rX,rA,k,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w5b_try_ror16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_ror16_k(rX,rA,w11_inst_imm_reg(i1,"shrq",rA,64),r2,fnItems)
    case _: None{}

# Try 16-bit rotate pattern R2 (shl-first)
@unsafe
def w11_rol16_m(+rX: U32, +rA: U32, +rB: U32, +k: U32, m_opt: Maybe<&2,U32>, r5: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m_opt:
    case Some{m}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(U32.add(k,m),16),
        u => w11_rot16_s5("rolw",rX,rA,rB,k,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_s4(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,r5}: w11_rol16_m(rX,rA,rB,k,w11_inst_imm_reg(i4,"shrq",rB,64),r5,fnItems)
    case _: None{}

@unsafe
def w11_rol16_rb(+rX: U32, +rA: U32, +k: U32, rb_opt: Maybe<&2,U32>, r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{+rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)),
        u => w11_rol16_s4(rX,rA,rB,k,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_s3(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}: w11_rol16_rb(rX,rA,k,w11_inst_reg_dst(i3,"movq",rX,64,64),r4,fnItems)
    case _: None{}

@unsafe
def w11_rol16_s2(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i2,"movl",rA,32,rA,32),
        u => w11_rol16_s3(rX,rA,k,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_k(+rX: U32, +rA: U32, k_opt: Maybe<&2,U32>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match k_opt:
    case Some{+k}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_ge(k,1) && U32.is_le(k,15),
        u => w11_rol16_s2(rX,rA,k,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w5b_try_rol16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_rol16_k(rX,rA,w11_inst_imm_reg(i1,"shlq",rA,64),r2,fnItems)
    case _: None{}

# Try cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne -> cmp + j<cc>
@unsafe
def w11_cmp_jcc_emit(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    j_opt: Maybe<&2,W11Jcc>, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match j_opt:
    case Some{W11Jcc{+isN,+lbl}}:
      +flip = nt_choose(Bool,inv,w => isN,w => Bool.not(isN))
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems),
        w => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}}},
        w => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_j(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iJ,tail}: w11_cmp_jcc_emit(cmpInst,cc,rA,rB,inv,w11_inst_jcc(iJ),tail,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_tail(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iT,rJ}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(iT,"testl",rB,32,rB,32),
        u => w11_cmp_jcc_j(cmpInst,cc,rA,rB,inv,rJ,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_b2a_rb(+cmpInst: X187Parsed, +cc: String, +rA: U32, rb_opt: Maybe<&2,U32>,
    r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{rB}: w11_cmp_jcc_tail(cmpInst,cc,rA,rB,True{},r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_b2a(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iM,r4}: w11_cmp_jcc_b2a_rb(cmpInst,cc,rA,w11_inst_reg_dst(iM,"movq",rA,64,64),r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_after_mov(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i3,+r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i3,"xorl",1,rB,32),
        v => w11_cmp_jcc_tail(cmpInst,cc,rA,rB,True{},r4,fnItems),
        v => w11_cmp_jcc_tail(cmpInst,cc,rA,rB,False{},Con{i3,r4},fnItems))
    case _: None{}

@unsafe
def w11_cmp_jcc_mov_rb(+cmpInst: X187Parsed, +cc: String, +rA: U32, rb_opt: Maybe<&2,U32>,
    r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{rB}: w11_cmp_jcc_after_mov(cmpInst,cc,rA,rB,r3,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_after_z(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i2,+r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i2,"xorl",1,rA,32),
        u => w11_cmp_jcc_b2a(cmpInst,cc,rA,r3,fnItems),
        u => w11_cmp_jcc_mov_rb(cmpInst,cc,rA,w11_inst_reg_dst(i2,"movq",rA,64,64),r3,fnItems))
    case _: None{}

@unsafe
def w11_cmp_jcc_s1(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i1,"movzbl",rA,8,rA,32),
        u => w11_cmp_jcc_after_z(cmpInst,cc,rA,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_s0(+cmpInst: X187Parsed, s_opt: Maybe<&2,W11SetCC>, r1: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s_opt:
    case Some{W11SetCC{opSet,rA}}: w11_cmp_jcc_s1(cmpInst,w5b_set_cc(opSet),rA,r1,fnItems)
    case _: None{}

@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i0,r1}: w11_cmp_jcc_s0(cmpInst,w11_inst_setcc(i0),r1,fnItems)
    case _: None{}

# Try movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d -> cmpq %rB, %rA; setcc; movzbl
@unsafe
def w11_cmp_bounce_s4(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32, +opS: String,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"movzbl",rT1,8,rT1,32) && w5b_reg_dead_fast(rT2,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s3_set(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    s_opt: Maybe<&2,W11SetCC>, r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s_opt:
    case Some{W11SetCC{opS,rs}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rs,rT1),
        u => w11_cmp_bounce_s4(rA,rT1,rB,rT2,opS,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s3(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}: w11_cmp_bounce_s3_set(rA,rT1,rB,rT2,w11_inst_setcc(i3),r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_bounce_s2(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i2,"cmpq",rT2,64,rT1,64),
        u => w11_cmp_bounce_s3(rA,rT1,rB,rT2,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s1(+rA: U32, +rT1: U32, rr_opt: Maybe<&2,W11PairU32>,
    r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr_opt:
    case Some{W11PairU32{+rB,+rT2}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rT1,rT2)) && Bool.not(U32.is_eq(rB,rT1)),
        u => w11_cmp_bounce_s2(rA,rT1,rB,rT2,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w5b_try_cmp_bounce(+rA: U32, +rT1: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_cmp_bounce_s1(rA,rT1,w11_inst_reg_reg(i1,"movq",64,64),r2,fnItems)
    case _: None{}

# Try spill-bounce: movq %rS, %rT; movq %rT, d(%rbp) (rT in {10,11}, rT dead) -> movq %rS, d(%rbp)
@unsafe
def w5b_try_spill_bounce(+rS: U32, +rT: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{rt1,64,False{}},Con{X187Mem{5,+disp},Nil{}}}}},+tail}:
      +ok = agy_str_eq(op1,"movq") && U32.is_eq(rt1,rT) && (U32.is_eq(rT,10) || U32.is_eq(rT,11)) &&
            Bool.not(U32.is_eq(rS,rT)) && w5b_reg_dead_fast(rT,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[x188_reg(rS,64),X187Mem{5,disp}]}},tail}},
        u => None{})
    case _: None{}

# Try select-bounce: movq %r10, %rax; movq d(%rbp), %r10; movq %rN, %r11; testl %eax,%eax; cmovneq %r10,%r11; movq %r11, dst
@unsafe
def w11_sel_bounce_dst(+srcY: X187Operand, +rN: U32, d_opt: Maybe<&2,X187Operand>,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match d_opt:
    case Some{dst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5b_reg_dead_fast(0,tail,fnItems) && w5b_reg_dead_fast(10,tail,fnItems) &&
        w5b_reg_dead_fast(11,tail,fnItems) && w5b_reg_dead_fast(rN,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"movq",[srcY,x188_reg(11,64)]}},
                  Con{PInst{X187Instruction{"testl",[x188_reg(10,32),x188_reg(10,32)]}},
                  Con{PInst{X187Instruction{"cmovneq",[x188_reg(11,64),x188_reg(rN,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},tail}}}}},
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s5(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i5,tail}: w11_sel_bounce_dst(srcY,rN,w11_inst_reg_any(i5,"movq",11,64),tail,fnItems)
    case _: None{}

@unsafe
def w11_sel_bounce_s4(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,r5}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"cmovneq",10,64,11,64),
        u => w11_sel_bounce_s5(srcY,rN,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s3(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i3,"testl",0,32,0,32),
        u => w11_sel_bounce_s4(srcY,rN,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_rn(+srcY: X187Operand, rn_opt: Maybe<&2,U32>, r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rn_opt:
    case Some{+rN}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(rN,10)) && Bool.not(U32.is_eq(rN,11)) && Bool.not(U32.is_eq(rN,0)),
        u => w11_sel_bounce_s3(srcY,rN,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s2(+srcY: X187Operand, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}: w11_sel_bounce_rn(srcY,w11_inst_src_reg(i2,"movq",11,64,64),r3,fnItems)
    case _: None{}

@unsafe
def w11_sel_bounce_src(src_opt: Maybe<&2,X187Operand>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match src_opt:
    case Some{srcY}: w11_sel_bounce_s2(srcY,r2,fnItems)
    case _: None{}

@unsafe
def w11_sel_bounce_s1(rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_sel_bounce_src(w11_inst_any_reg(i1,"movq",10,64),r2,fnItems)
    case _: None{}

@unsafe
def w5b_try_sel_bounce(+rA: U32, +rD: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rA,10) && U32.is_eq(rD,0),
    u => w11_sel_bounce_s1(rest,fnItems),
    u => None{})"""


# ---------------------------------------------------------------------------
# 6. P5-A String.order.go Fast Path (agy_sh_emit_strcmp)
# ---------------------------------------------------------------------------
OLD_AGY_SH_TRY_TAIL = """        # 6. p98_tag_eq / p98_tag_eq_read (arity 2)
                            c => agy_sh_try_tageq(function,ids,name,arity,sym,slow,snil,scon,chr))))))))))))"""

NEW_AGY_SH_STRCMP_AND_TAIL = """        # 6. String.order.go (arity 3) + p98_tag_eq / p98_tag_eq_read (arity 2)
                            c => agy_sh_try_order_or_tageq(function,ids,name,arity,sym,slow,snil,scon,chr))))))))))))"""

AGY_SH_STRCMP_DEFS = """@unsafe
def agy_sh_strcmp_loop(+pfx: String, +l_lt: String, +l_eq: String, +l_gt: String, +l_bail: String,
    +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +l_lp = pfx ++ "_lp"
  +l_anil = pfx ++ "_an"
  +l_adir = pfx ++ "_ad"
  +l_bdir = pfx ++ "_bd"
  +l_schr = pfx ++ "_sc"
  +scon_chk = U32.add(131072,scon_cid)
  x188_many([
    x188_label(l_lp),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_anil}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_gt}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_adir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_adir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_bdir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_bdir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("orq",x188_reg(3,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jnz",X187Target{l_schr}),
    x188_i2("cmpl",x188_reg(3,32),x188_reg(0,32)),
    x188_i1("jb",X187Target{l_lt}),
    x188_i1("ja",X187Target{l_gt}),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_schr),
    agy_sh_unpack_chr(pfx ++ "_c1",l_bail,chr_cid),
    x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    agy_sh_unpack_chr(pfx ++ "_c2",l_bail,chr_cid),
    x188_i2("cmpl",x188_reg(0,32),x188_reg(13,32)),
    x188_i1("jb",X187Target{l_lt}),
    x188_i1("ja",X187Target{l_gt}),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_anil),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_eq}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_lt})])

@unsafe
def agy_sh_emit_strcmp(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32,
    +lt_cid: U32, +eq_cid: U32, +gt_cid: U32, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_cm_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +lt_hi = U32.add(16777216,U32.mul(lt_cid,256))
  +eq_hi = U32.add(16777216,U32.mul(eq_cid,256))
  +gt_hi = U32.add(16777216,U32.mul(gt_cid,256))
  +l_lt = pfx ++ "_lt"
  +l_eq = pfx ++ "_eq"
  +l_gt = pfx ++ "_gt"
  +l_done = pfx ++ "_dn"
  +l_sk1 = pfx ++ "_s1"
  +l_sk2 = pfx ++ "_s2"
  +l_bail = pfx ++ "_bl"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movq",x188_reg(0,64),x188_reg(13,64)),
      x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
      x188_i2("movq",x188_reg(2,64),x188_reg(3,64)),
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk1}),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk1),
      x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk2}),
      x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
      x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk2),
      x188_i2("movq",x188_reg(13,64),x188_reg(0,64))]),
    u => X188Empty{})
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i2("movabsq",X187Imm{0,eq_hi},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{slow}),
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    agy_sh_chk_hot(lt_cid,slow),
    agy_sh_chk_hot(eq_cid,slow),
    agy_sh_chk_hot(gt_cid,slow),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(12,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(9,64)),
    agy_sh_strcmp_loop(pfx,l_lt,l_eq,l_gt,l_bail,scon,chr),
    x188_label(l_lt),
    x188_i2("movabsq",X187Imm{0,lt_hi},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_done}),
    x188_label(l_eq),
    x188_i2("movabsq",X187Imm{0,eq_hi},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_done}),
    x188_label(l_gt),
    x188_i2("movabsq",X187Imm{0,gt_hi},x188_reg(0,64)),
    x188_label(l_done),
    sink_seq,
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow}),
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_sh_try_order_or_tageq(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32, +chr: U32) -> Maybe<&2,X181Output>:
  +lt_c = agy_sh_cid(ids,"LT")
  +eq_c = agy_sh_cid(ids,"EQ")
  +gt_c = agy_sh_cid(ids,"GT")
  +ord_ok = U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
    U32.is_lt(lt_c,65536) && U32.is_lt(eq_c,65536) && U32.is_lt(gt_c,65536)
  nt_choose(Maybe<&2,X181Output>,ord_ok && agy_str_eq(name,"$p118borrow.read.String.order.go"),
    u => agy_sh_wrap(function,ids,agy_sh_emit_strcmp(sym,slow,snil,scon,chr,lt_c,eq_c,gt_c,False{}),slow),
    u => nt_choose(Maybe<&2,X181Output>,ord_ok &&
        (agy_str_eq(name,"$direct.String.order.go") || agy_str_eq(name,"$p128borrow.owned.String.order.go")),
      v => agy_sh_wrap(function,ids,agy_sh_emit_strcmp(sym,slow,snil,scon,chr,lt_c,eq_c,gt_c,True{}),slow),
      v => agy_sh_try_tageq(function,ids,name,arity,sym,slow,snil,scon,chr)))

"""


# ---------------------------------------------------------------------------
# 2. P5-B -O2 Modular Hang & Collision Fix
# ---------------------------------------------------------------------------
OLD_W10_VIS = """@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    agy_str_eq(name,"p111_FID_109_97_105_110_") ||
    agy_str_eq(name,"p113d_FID_109_97_105_110_") ||
    String.contains(name,"_126_")

@unsafe
def w10_weak_add_def(+name: String, +acc: KDef) -> KDef:
  +dname = "$direct." ++ name
  +rname = "$p118borrow.read." ++ name
  +oname = "$p128borrow.owned." ++ name
  +s1 = p111q_symbol(dname)
  +s2 = p113e_symbol(dname)
  +s3 = p111q_symbol(name)
  +s4 = p113e_symbol(name)
  +s5 = p113e_symbol(rname)
  +s6 = p113e_symbol(oname)
  +s7 = p111q_symbol(rname)
  +s8 = p111q_symbol(oname)
  +a1 = p111v_put(p111v_put(p111v_put(p111v_put(acc,s1,"W10Weak",1,0),s2,"W10Weak",1,0),s3,"W10Weak",1,0),s4,"W10Weak",1,0)
  +a2 = p111v_put(p111v_put(p111v_put(p111v_put(a1,s5,"W10Weak",1,0),s6,"W10Weak",1,0),s7,"W10Weak",1,0),s8,"W10Weak",1,0)
  p111v_put(p111v_put(p111v_put(a2,s2 ++ "__sh_slow","W10Weak",1,0),s5 ++ "__sh_slow","W10Weak",1,0),s6 ++ "__sh_slow","W10Weak",1,0)"""

NEW_W10_VIS = """@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p114r_FID_36_112_49_49_49_46_107_46_") ||
    agy_str_eq(name,"p111_FID_109_97_105_110_") ||
    agy_str_eq(name,"p113d_FID_109_97_105_110_") ||
    agy_str_eq(name,"p114r_FID_109_97_105_110_") ||
    String.contains(name,"_126_")

@unsafe
def w10_weak_add_def(+name: String, +acc: KDef) -> KDef:
  +dname = "$direct." ++ name
  +rname = "$p118borrow.read." ++ name
  +oname = "$p128borrow.owned." ++ name
  +pname = "$product." ++ name
  +s1 = p111q_symbol(dname)
  +s2 = p113e_symbol(dname)
  +s3 = p111q_symbol(name)
  +s4 = p113e_symbol(name)
  +s5 = p113e_symbol(rname)
  +s6 = p113e_symbol(oname)
  +s7 = p111q_symbol(rname)
  +s8 = p111q_symbol(oname)
  +s9 = p114r_symbol(dname)
  +s10 = p114r_symbol(name)
  +s11 = p113e_symbol(pname)
  +a1 = p111v_put(p111v_put(p111v_put(p111v_put(acc,s1,"W10Weak",1,0),s2,"W10Weak",1,0),s3,"W10Weak",1,0),s4,"W10Weak",1,0)
  +a2 = p111v_put(p111v_put(p111v_put(p111v_put(a1,s5,"W10Weak",1,0),s6,"W10Weak",1,0),s7,"W10Weak",1,0),s8,"W10Weak",1,0)
  +a3 = p111v_put(p111v_put(p111v_put(a2,s9,"W10Weak",1,0),s10,"W10Weak",1,0),s11,"W10Weak",1,0)
  p111v_put(p111v_put(p111v_put(a3,s2 ++ "__sh_slow","W10Weak",1,0),s5 ++ "__sh_slow","W10Weak",1,0),s6 ++ "__sh_slow","W10Weak",1,0)"""

W11_MOD_O2_HELPERS = """# Wave 11 (P5-B): Exclude imported weak_set stubs from -O2 p114r eligibility, call-site rewrites, and emission
@unsafe
def w11_seg_not_weak(+segment: N111Segment, +weak_set: KDef) -> Bool:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      Bool.not(w10_is_weak_sym(weak_set,p111q_symbol(name)))

@unsafe
def w11_p114h_filter_segs_mod(segs: List<&2,N111Segment>, +direct: KDef, +weak_set: KDef,
    +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+seg,+rest}:
      w11_p114h_filter_segs_mod(rest,direct,weak_set,
        nt_choose(List<&2,N111Segment>,agy_p114h_seg_eligible(seg,direct,missing()) && w11_seg_not_weak(seg,weak_set),
          u => Con{seg,acc},u => acc))

@unsafe
def w11_p114h_fixpoint_mod(+segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +hready: KDef, +fuel: U32, +weak_set: KDef) -> KDef:
  agy_p114h_fixpoint_loop(w11_p114h_filter_segs_mod(segs,direct,weak_set,[]),index,direct,ready,available,hready,fuel)

@unsafe
def w11_enrich_cursor_mod(cursor: P134Cursor, +available: KDef, +weak_set: KDef) -> P134Cursor:
  match cursor:
    case P134Private{fns,ctx,next}: P134Private{fns,ctx,w11_enrich_cursor_mod(next,available,weak_set)}
    case P134Legacy{es,ctx,next}: P134Legacy{es,ctx,w11_enrich_cursor_mod(next,available,weak_set)}
    case P134Public{+segs,P134Context{+ids,+index,+direct,+ready,+view,+lookups,+heap,+mode},+next}:
      nt_choose(P134Cursor,Bool.not(U32.is_eq(mode,0)) && x192h_regions_enabled(),
        u => P134Public{segs,P134Context{ids,index,direct,ready,
          agy_p124r_hview(ready,direct,w11_p114h_fixpoint_mod(segs,index,direct,ready,available,missing(),6,weak_set)),
          lookups,heap,mode},next},
        u => P134Public{segs,P134Context{ids,index,direct,ready,view,lookups,heap,mode},next})
    case other: other

@unsafe
def w11_program_public_mod(+segment: N111Segment, context: P134Context, +available: KDef, +weak_set: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      nt_choose(X181Output,w10_is_weak_sym(weak_set,p111q_symbol(name)),
        u => x181_program_join(X181Output{[],x181_program_scalars(body,available)},x181_segment(segment,ids)),
        u => x181_program_public(segment,context,available))

"""

OLD_W10_MOD_CURSOR = """    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build),weak_set)"""

NEW_W10_MOD_CURSOR = """    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Public{rest,context,next},available,x187_output(w11_program_public_mod(head,context,available,weak_set),build),weak_set)"""

OLD_W10_MOD_PREP = """          v => w10_module_cursor_io(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty(),weak_set),"""

NEW_W10_MOD_PREP = """          v => w10_module_cursor_io(w8_relocate_cursor(w11_enrich_cursor_mod(cursor,avail,weak_set),fid_base,mod_name),avail,x187_build_empty(),weak_set),"""

OLD_W8_TR_PUB = """    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))"""

NEW_W8_TR_PUB = """    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => nt_choose(X181Output,is_mod,
        v => w11_program_public_mod(head,ctx,avail,weak_set),
        v => x181_program_public(head,ctx,avail)))"""

OLD_W8_TR_ENR = """              +enr : P134Cursor = nt_choose(P134Cursor,fast,w => cursor,w => agy_enrich_cursor(cursor,avail))"""

NEW_W8_TR_ENR = """              +enr : P134Cursor = nt_choose(P134Cursor,fast,w => cursor,
                w => nt_choose(P134Cursor,is_mod,z => w11_enrich_cursor_mod(cursor,avail,weak_set),z => agy_enrich_cursor(cursor,avail)))"""

OLD_W8_DISPATCH = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        u => w8_tr_entry(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
          v => w10_merge_entry(rest),
          v => x181_entry_args(Con{head,rest})))
    case Nil{}: x181_entry_args(Nil{})"""

NEW_W8_DISPATCH = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace-slow"),
        u => ts_parse_thresh(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"--trace"),
          v => w8_tr_entry(rest),
          v => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
            w => w10_merge_entry(rest),
            w => x181_entry_args(Con{head,rest}))))
    case Nil{}: x181_entry_args(Nil{})"""


def main() -> None:
    text = SRC.read_text(encoding="utf-8")
    orig_len = len(text)

    # 1. Scoped nq_signature_user & p113k_function pure-leaf exemption
    text = replace_exact(text, OLD_NQ_SIG_USER, NEW_NQ_SIG_USER, "nq_signature_user")
    text = replace_exact(text, OLD_P113K_FN, NEW_P113K_FN, "p113k_function")

    # 3. P5-A flatten p186ch_expand & w2_asr_strip_self
    text = replace_exact(text, OLD_P186CH, NEW_P186CH, "p186ch_expand")
    text = replace_exact(text, OLD_W2_ASR, NEW_W2_ASR, "w2_asr_strip_self")

    # 4. P5-F flatten 5 w5b_try_* matchers
    text = replace_exact(text, OLD_W5B_MATCHERS, NEW_W5B_MATCHERS, "w5b_try_matchers")

    # 6. P5-A String.order.go fast path
    anchor_tageq = "@unsafe\ndef agy_sh_try_tageq("
    text = replace_exact(text, anchor_tageq, AGY_SH_STRCMP_DEFS + anchor_tageq, "agy_sh_strcmp_defs")
    text = replace_exact(text, OLD_AGY_SH_TRY_TAIL, NEW_AGY_SH_STRCMP_AND_TAIL, "agy_sh_try_tail")

    # 2. P5-B -O2 modular hang & collision fix
    text = replace_exact(text, OLD_W10_VIS, NEW_W10_VIS, "w10_vis")
    anchor_mod_cur = "law w10_module_cursor_io:"
    text = replace_exact(text, anchor_mod_cur, W11_MOD_O2_HELPERS + anchor_mod_cur, "w11_mod_o2_helpers")
    text = replace_exact(text, OLD_W10_MOD_CURSOR, NEW_W10_MOD_CURSOR, "w10_mod_cursor")
    text = replace_exact(text, OLD_W10_MOD_PREP, NEW_W10_MOD_PREP, "w10_mod_prep")
    text = replace_exact(text, OLD_W8_TR_PUB, NEW_W8_TR_PUB, "w8_tr_pub")
    text = replace_exact(text, OLD_W8_TR_ENR, NEW_W8_TR_ENR, "w8_tr_enr")

    # 5. P5-D Fast pure-Bend x86-iface
    start_marker = "# --- Dual 32-bit FNV-1a interface hasher (alpha-invariant, ignores spans & bodies) ---"
    end_marker = "@unsafe\ndef w8_module_entry("
    i0 = text.index(start_marker)
    i1 = text.index(end_marker, i0)
    fast_body = FAST_IFACE.read_text(encoding="utf-8").rstrip()
    text = text[:i0] + fast_body + "\n\n" + text[i1:]

    # 7. P5-F --trace-slow <ms> profiler (with P5-B modular -O2 fix wired in!)
    ts_body = TRACE_SLOW.read_text(encoding="utf-8").rstrip()
    ts_body = replace_exact(
        ts_body,
        """    +out : X181Output <- IO.pure(X181Output, nt_choose(X181Output, fast,
      u => x181_program_public_fast(head, ctx, avail),
      u => x181_program_public(head, ctx, avail)))""",
        """    +out : X181Output <- IO.pure(X181Output, nt_choose(X181Output, fast,
      u => x181_program_public_fast(head, ctx, avail),
      u => nt_choose(X181Output, is_mod,
        v => w11_program_public_mod(head, ctx, avail, weak_set),
        v => x181_program_public(head, ctx, avail))))""",
        "ts_emit_pub",
    )
    ts_body = replace_exact(
        ts_body,
        """              +enr : P134Cursor = nt_choose(P134Cursor, fast, w => cursor, w => agy_enrich_cursor(cursor, avail))""",
        """              +enr : P134Cursor = nt_choose(P134Cursor, fast, w => cursor,
                w => nt_choose(P134Cursor, is_mod, z => w11_enrich_cursor_mod(cursor, avail, weak_set), z => agy_enrich_cursor(cursor, avail)))""",
        "ts_run_prepared",
    )
    anchor_dispatch = "@unsafe\ndef w8_dispatch_args("
    text = replace_exact(text, anchor_dispatch, ts_body + "\n\n" + anchor_dispatch, "ts_insert")
    text = replace_exact(text, OLD_W8_DISPATCH, NEW_W8_DISPATCH, "w8_dispatch_args")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    print(f"Wrote {OUT}: {orig_len:,} B -> {len(text):,} B (+{len(text) - orig_len:,} B)", flush=True)


if __name__ == "__main__":
    main()

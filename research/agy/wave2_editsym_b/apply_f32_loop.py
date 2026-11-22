#!/usr/bin/env python3
"""Standalone composable patcher (composable on top of unified/compiler.bend + Track C):
AGY-W2B-F32LOOP: General XMM Loop-Carried F32 Recurrence + Constant Hoisting Pass.

General, sound compiler optimization for p113d_ tail-recursive F32+U32 recurrence loops:
1. Hooks into x181_direct for 3-param, 1-result functions `f(state, n, x, h) -> U32`.
2. After standard x185 normalization, symbolically parses the loop body (completely
   name-independent) into:
   - An arbitrary pure F32 expression DAG for `y = F(x)` using `f32_{add,sub,mul,div}`
     over `x` and F32 bit-pattern constants.
   - An arbitrary pure F32 expression DAG for `obs = G(x, y)` fed into `f32_to_u32`.
   - An arbitrary pure U32 expression DAG for `h' = H(h, to_u32(obs))` using
     `u32_{add,sub,mul,xor,and,or}` over `h`, `to_u32(obs)`, and U32 constants.
   - Loop backedge `AGAIN(n - 1, y, h')` and exit `n == 0 -> RESULT(h)`.
3. Emits a native x86 SSE loop:
   - Keeps `x` in `%xmm0` across all iterations (zero GPR<->XMM `movd` round-trips).
   - Hoists all F32 constants into XMM registers once before the loop.
   - Single `subq $1, %rsi; jne .Lloop` counter (eliminates redundant double `cmp $0`).
   - Exact IEEE-754 `f32_to_u32`: `movd %xmm1, %eax; cmpl $0x4f800000, %eax; jae .Lzero; cvttss2siq %xmm1, %rax`
     (bit-for-bit identical for all 2^32 F32 bit patterns including NaN, -0.0, <0, >=2^32).
"""
import sys
from pathlib import Path

F32LOOP_BEND = r'''
# ============================================================================
# AGY-W2B-F32LOOP: General XMM Loop-Carried F32 Recurrence + Constant Hoisting
# ============================================================================
# AST encoded in KTerm:
#   F32 exprs:
#     kt("FVarX", "", 0, 0, [])
#     kt("FConst", "", bits_u32, 0, [])
#     kt("FBin", sse_op, 0, 0, [left, right])   # addss / subss / mulss / divss
#   U32 exprs:
#     kt("UVarH", "", 0, 0, [])
#     kt("UObs", "", 0, 0, [])                  # f32_to_u32(obs_expr)
#     kt("UConst", "", val_u32, 0, [])
#     kt("UBin", alu_op, 0, 0, [left, right])   # addl / subl / imull / xorl / andl / orl
# Env entries in KDef:
#   kind = "F32Expr" -> dv = KTerm (F32 expr)
#   kind = "U32Expr" -> dv = KTerm (U32 expr)
#   kind = "FuelSub" -> da = 1 (n - 1)
#   kind = "Fuel"    -> da = 1 (n)

@unsafe
def agy_f32_put(env: KDef, +name: String, kind: String, expr: KTerm) -> KDef:
  +entry : KDef = KDef{name,kind,0,0,kt("None","",0,0,[]),expr,[],False{},False{}}
  index_set(env,entry,index_hash(name,2166136261),32)

@unsafe
def agy_f32_get(env: KDef, +name: String) -> KDef:
  index_find(env,name,index_hash(name,2166136261),32)

def agy_f32_sse_op(+op_id: U32) -> String:
  nt_choose(String,U32.is_eq(op_id,26),u => "addss",u =>
    nt_choose(String,U32.is_eq(op_id,27),v => "subss",v =>
      nt_choose(String,U32.is_eq(op_id,28),w => "mulss",w =>
        nt_choose(String,U32.is_eq(op_id,29),z => "divss",z => ""))))

def agy_f32_u32_op(+op: String) -> String:
  nt_choose(String,String.eq(op,"add"),u => "addl",u =>
    nt_choose(String,String.eq(op,"sub"),v => "subl",v =>
      nt_choose(String,String.eq(op,"mul"),w => "imull",w =>
        nt_choose(String,String.eq(op,"xor"),z => "xorl",z =>
          nt_choose(String,String.eq(op,"and"),q => "andl",q =>
            nt_choose(String,String.eq(op,"or"),r => "orl",r => ""))))))

@unsafe
def agy_f32_val_f(v: N111Value, env: KDef) -> Maybe<&2,KTerm>:
  match v:
    case N111Const{+lo,hi}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(hi,0),u => Some{kt("FConst","",lo,0,[])},u => None{})
    case N111Local{name}:
      +d = agy_f32_get(env,name)
      nt_choose(Maybe<&2,KTerm>,String.eq(dk(d),"F32Expr"),u => Some{dv(d)},u => None{})
    case _: None{}

@unsafe
def agy_f32_val_u(v: N111Value, env: KDef) -> Maybe<&2,KTerm>:
  match v:
    case N111Const{+lo,hi}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(hi,0),u => Some{kt("UConst","",lo,0,[])},u => None{})
    case N111Local{name}:
      +d = agy_f32_get(env,name)
      nt_choose(Maybe<&2,KTerm>,String.eq(dk(d),"U32Expr"),u => Some{dv(d)},u => None{})
    case _: None{}

@unsafe
def agy_f32_val_fuel(v: N111Value, env: KDef, +kind: String) -> Bool:
  match v:
    case N111Local{name}: String.eq(dk(agy_f32_get(env,name)),kind)
    case _: False{}

type AgyF32State is Data:
  AgyF32State{+env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>, +obs: Maybe<&2,KTerm>, +has_obs: Bool}

type AgyF32Plan is Data:
  AgyF32No{}
  AgyF32Yes{+y_expr: KTerm, +obs_expr: Maybe<&2,KTerm>, +h_expr: KTerm}

@unsafe
def agy_f32_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name))

@unsafe
def agy_f32_call_fbin2(+dst: String, +sse: String, r0: Maybe<&2,KTerm>, r1: Maybe<&2,KTerm>,
    params: List<&2,String>, +env: KDef, +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0 r1:
    case Some{e0} Some{e1}:
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"F32Expr",kt("FBin",sse,0,0,[e0,e1])),None{},None{},obs,has_obs}},
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_call_fbin(+dst: String, +sse: String, s0: Maybe<&2,N111Value>, s8: Maybe<&2,N111Value>,
    params: List<&2,String>, +env: KDef, +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match s0 s8:
    case Some{v0} Some{v1}:
      agy_f32_call_fbin2(dst,sse,agy_f32_val_f(v0,env),agy_f32_val_f(v1,env),params,env,obs,has_obs)
    case _ _: None{}

@unsafe
def agy_f32_call_tou32_2(+dst: String, r0: Maybe<&2,KTerm>, params: List<&2,String>,
    +env: KDef, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0:
    case Some{e0}:
      nt_choose(Maybe<&2,AgyF32State>,Bool.not(has_obs) && agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"U32Expr",kt("UObs","",0,0,[])),None{},None{},Some{e0},True{}}},
        u => None{})
    case None{}: None{}

@unsafe
def agy_f32_call_tou32(+dst: String, s0: Maybe<&2,N111Value>, params: List<&2,String>,
    +env: KDef, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match s0:
    case Some{v0}:
      agy_f32_call_tou32_2(dst,agy_f32_val_f(v0,env),params,env,has_obs)
    case None{}: None{}

@unsafe
def agy_f32_bin_u(+dst: String, +alu: String, r0: Maybe<&2,KTerm>, r1: Maybe<&2,KTerm>,
    params: List<&2,String>, +env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>,
    +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0 r1:
    case Some{e0} Some{e1}:
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"U32Expr",kt("UBin",alu,0,0,[e0,e1])),s0,s8,obs,has_obs}},
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_set_copy(+dst: String, +val: N111Value, params: List<&2,String>,
    +env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>,
    +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match val:
    case N111Local{src}:
      +d = agy_f32_get(env,src)
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params) &&
          (String.eq(dk(d),"F32Expr") || String.eq(dk(d),"U32Expr")),
        u => Some{AgyF32State{agy_f32_put(env,dst,dk(d),dv(d)),s0,s8,obs,has_obs}},
        u => None{})
    case _: None{}

@unsafe
def agy_f32_call_op(+dst: String, args: List<&2,N111Arg>, +params: List<&2,String>, +st: AgyF32State) -> Maybe<&2,AgyF32State>:
  match args st:
    case Con{N111Arg{_,N111Local{st_name}},Con{N111Arg{_,N111Const{+op_id,0}},Con{N111Arg{_,N111Local{buf}},Con{N111Arg{_,N111Const{+cnt,0}},Nil{}}}}}
         AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      +sse = agy_f32_sse_op(op_id)
      nt_choose(Maybe<&2,AgyF32State>,String.eq(st_name,"state") && String.eq(buf,"scratch"),
        u => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(cnt,2) && Bool.not(String.is_empty(sse)),
          v => agy_f32_call_fbin(dst,sse,s0,s8,params,env,obs,has_obs),
          v => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(op_id,58) && U32.is_eq(cnt,1),
            w => agy_f32_call_tou32(dst,s0,params,env,has_obs),
            w => None{})),
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_scalar(stmt: N111Stmt, +params: List<&2,String>, +st: AgyF32State) -> Maybe<&2,AgyF32State>:
  match stmt st:
    case N111Store{N111U64{},N111Local{buf},+off,+val} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      nt_choose(Maybe<&2,AgyF32State>,String.eq(buf,"scratch"),
        u => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(off,0),
          v => Some{AgyF32State{env,Some{val},s8,obs,has_obs}},
          v => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(off,8),
            w => Some{AgyF32State{env,s0,Some{val},obs,has_obs}},
            w => None{})),
        u => None{})
    case N111Call{dst,N111U64{},sym,args} _:
      nt_choose(Maybe<&2,AgyF32State>,String.eq(sym,"p111_rt_op"),
        u => agy_f32_call_op(dst,args,params,st),
        u => None{})
    case N111Set{dst,_,val} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      agy_f32_set_copy(dst,val,params,env,s0,s8,obs,has_obs)
    case N111Bin{+dst,typ,+op,+left,+right} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      +alu = agy_f32_u32_op(op)
      nt_choose(Maybe<&2,AgyF32State>,String.eq(op,"sub") && agy_f32_val_fuel(left,env,"Fuel") && x192_p_constant(right,1) && agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"FuelSub",kt("None","",0,0,[])),s0,s8,obs,has_obs}},
        u => nt_choose(Maybe<&2,AgyF32State>,Bool.not(String.is_empty(alu)),
          v => agy_f32_bin_u(dst,alu,agy_f32_val_u(left,env),agy_f32_val_u(right,env),params,env,s0,s8,obs,has_obs),
          v => None{}))
    case _ _: None{}

@unsafe
def agy_f32_finish_again(ry: Maybe<&2,KTerm>, rh: Maybe<&2,KTerm>, obs: Maybe<&2,KTerm>) -> AgyF32Plan:
  match ry rh:
    case Some{ye} Some{he}: AgyF32Yes{ye,obs,he}
    case _ _: AgyF32No{}

@unsafe
def agy_f32_again(values: List<&2,N111Value>, st: AgyF32State) -> AgyF32Plan:
  match values st:
    case Con{v0,Con{v1,Con{v2,Nil{}}}} AgyF32State{+env,s0,s8,obs,has_obs}:
      nt_choose(AgyF32Plan,agy_f32_val_fuel(v0,env,"FuelSub"),
        u => agy_f32_finish_again(agy_f32_val_f(v1,env),agy_f32_val_u(v2,env),obs),
        u => AgyF32No{})
    case _ _: AgyF32No{}

@unsafe
def agy_f32_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, st: Maybe<&2,AgyF32State>, +budget: U32) -> AgyF32Plan:
  match body st:
    case Con{P113DAgain{values},Nil{}} Some{cur}: agy_f32_again(values,cur)
    case Con{P113DScalar{stmt},rest} Some{cur}:
      nt_choose(AgyF32Plan,U32.is_gt(budget,0),
        u => agy_f32_walk(rest,params,agy_f32_scalar(stmt,params,cur),U32.sub(budget,1)),
        u => AgyF32No{})
    case _ _: AgyF32No{}

@unsafe
def agy_f32_seed(fuel: String, x: String, h: String) -> KDef:
  agy_f32_put(agy_f32_put(agy_f32_put(missing(),
    fuel,"Fuel",kt("None","",0,0,[])),
    x,"F32Expr",kt("FVarX","",0,0,[])),
    h,"U32Expr",kt("UVarH","",0,0,[]))

@unsafe
def agy_f32_positive(body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +x: String, +h: String) -> AgyF32Plan:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      nt_choose(AgyF32Plan,String.eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(cond,test) && agy_f32_free(test,params),
        u => agy_f32_walk(yes,params,Some{AgyF32State{agy_f32_seed(fuel,x,h),None{},None{},None{},False{}}},64),
        u => AgyF32No{})
    case _: AgyF32No{}

@unsafe
def agy_f32_result(body: List<&2,P113DStmt>, h: String) -> Bool:
  match body:
    case Con{P113DResult{Con{r0,Nil{}}},Nil{}}: x185_sf_source(r0,h)
    case _: False{}

@unsafe
def agy_f32_certify(+params: List<&2,String>, body: List<&2,P113DStmt>) -> AgyF32Plan:
  match params body:
    case Con{state,Con{+fuel,Con{+x,Con{+h,Nil{}}}}}
         Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      nt_choose(AgyF32Plan,String.eq(state,"state") && p113e_distinct(params) &&
          String.eq(op,"eq") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(cond,test) && agy_f32_free(test,params) && agy_f32_result(yes,h),
        u => agy_f32_positive(no,params,fuel,x,h),
        u => AgyF32No{})
    case _ _: AgyF32No{}

# ---- XMM constant collector & expression emitter ----
# XMM allocation:
#   %xmm0: x (loop-carried!)
#   %xmm1: scratch / y_next / obs
#   %xmm2..%xmm7: expression eval stack (depth up to 6)
#   %xmm8..%xmm15: hoisted F32 constants (up to 8 distinct constants!)

def agy_f32_find_const(cs: List<&2,U32>, +val: U32, +idx: U32) -> U32:
  match cs:
    case Nil{}: 99
    case Con{c,rest}: nt_choose(U32,U32.is_eq(c,val),u => idx,u => agy_f32_find_const(rest,val,U32.inc(idx)))

@unsafe
def agy_f32_collect_c(+e: KTerm, +cs: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,String.eq(tg(e),"FConst"),
    u => nt_choose(List<&2,U32>,U32.is_eq(agy_f32_find_const(cs,ix(e),0),99),v => Con{ix(e),cs},v => cs),
    u => nt_choose(List<&2,U32>,String.eq(tg(e),"FBin") && U32.is_eq(terms_len(ks(e)),2),
      v => agy_f32_collect_c(kid(e,1),agy_f32_collect_c(kid(e,0),cs)),
      v => cs))

@unsafe
def agy_f32_collect_opt(opt: Maybe<&2,KTerm>, cs: List<&2,U32>) -> List<&2,U32>:
  match opt:
    case None{}: cs
    case Some{e}: agy_f32_collect_c(e,cs)

def agy_f32_max(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_gt(a,b),u => a,u => b)

@unsafe
def agy_f32_depth(+e: KTerm) -> U32:
  nt_choose(U32,String.eq(tg(e),"FBin") && U32.is_eq(terms_len(ks(e)),2),
    u => U32.add(1,agy_f32_max(agy_f32_depth(kid(e,0)),agy_f32_depth(kid(e,1)))),
    u => 0)

@unsafe
def agy_f32_opt_depth(opt: Maybe<&2,KTerm>) -> U32:
  match opt:
    case None{}: 0
    case Some{e}: agy_f32_depth(e)

@unsafe
def agy_f32_hoist_consts(cs: List<&2,U32>, +reg: U32) -> X188Seq:
  match cs:
    case Nil{}: X188Empty{}
    case Con{bits,rest}:
      x188_many([
        x188_i2("movl",X187Imm{bits,0},x188_reg(0,32)),
        x188_i2("movd",x188_reg(0,32),x188_xmm(reg)),
        agy_f32_hoist_consts(rest,U32.inc(reg))])

# Emit U32 expr into dst_reg (0=eax, 8=r8d, 9=r9d, 10=r10d).
# Incoming: %ecx(1) = h, %edx(2) = obs_u32
def agy_f32_u_reg(+idx: U32) -> U32:
  nt_choose(U32,U32.is_eq(idx,0),u => 0,u =>
    nt_choose(U32,U32.is_eq(idx,1),v => 8,v =>
      nt_choose(U32,U32.is_eq(idx,2),w => 9,w => 10)))

@unsafe
def agy_f32_u_depth(+e: KTerm) -> U32:
  nt_choose(U32,String.eq(tg(e),"UBin") && U32.is_eq(terms_len(ks(e)),2),
    u => U32.add(1,agy_f32_max(agy_f32_u_depth(kid(e,0)),agy_f32_u_depth(kid(e,1)))),
    u => 0)

law agy_f32_emit_u:
  for +e: KTerm
  for +slot: U32
  X188Seq

@unsafe
def agy_f32_emit_ubin(+op: String, +l: KTerm, +r: KTerm, +slot: U32, +dr: U32) -> X188Seq:
  +sr = agy_f32_u_reg(U32.inc(slot))
  x188_many([
    agy_f32_emit_u(l,slot),
    agy_f32_emit_u(r,U32.inc(slot)),
    x188_i2(op,x188_reg(sr,32),x188_reg(dr,32))])

@unsafe
def agy_f32_emit_u(e,slot):
  +t = tg(e)
  +r = agy_f32_u_reg(slot)
  nt_choose(X188Seq,String.eq(t,"UVarH"),
    u => x188_i2("movl",x188_reg(1,32),x188_reg(r,32)),u =>
    nt_choose(X188Seq,String.eq(t,"UObs"),
      v => x188_i2("movl",x188_reg(2,32),x188_reg(r,32)),v =>
      nt_choose(X188Seq,String.eq(t,"UConst"),
        w => x188_i2("movl",X187Imm{ix(e),0},x188_reg(r,32)),w =>
        nt_choose(X188Seq,String.eq(t,"UBin") && U32.is_eq(terms_len(ks(e)),2),
          z => agy_f32_emit_ubin(nm(e),kid(e,0),kid(e,1),slot,r),
          z => X188Empty{}))))

# Reuse %xmm1 directly when obs shares subexpression ye!
@unsafe
def agy_f32_same(+a: KTerm, +b: KTerm) -> Bool:
  String.eq(tg(a),tg(b)) && String.eq(nm(a),nm(b)) && U32.is_eq(ix(a),ix(b)) &&
  nt_choose(Bool,String.eq(tg(a),"FBin") && U32.is_eq(terms_len(ks(a)),2) && U32.is_eq(terms_len(ks(b)),2),
    u => agy_f32_same(kid(a,0),kid(b,0)) && agy_f32_same(kid(a,1),kid(b,1)),
    u => True{})

@unsafe
def agy_f32_subst_y(+e: KTerm, +ye: KTerm) -> KTerm:
  nt_choose(KTerm,agy_f32_same(e,ye),
    u => kt("FVarY","",0,0,[]),
    u => nt_choose(KTerm,String.eq(tg(e),"FBin") && U32.is_eq(terms_len(ks(e)),2),
      v => kt("FBin",nm(e),0,0,[agy_f32_subst_y(kid(e,0),ye),agy_f32_subst_y(kid(e,1),ye)]),
      v => e))

@unsafe
def agy_f32_subst_opt(opt: Maybe<&2,KTerm>, ye: KTerm) -> Maybe<&2,KTerm>:
  match opt:
    case None{}: None{}
    case Some{e}: Some{agy_f32_subst_y(e,ye)}

law agy_f32_emit_f2:
  for +e: KTerm
  for +cs: List<&2,U32>
  for +dst: U32
  X188Seq

@unsafe
def agy_f32_emit_fbin2(+op: String, +l: KTerm, +r: KTerm, +cs: List<&2,U32>, +dst: U32) -> X188Seq:
  nt_choose(X188Seq,String.eq(tg(r),"FVarX"),
    u => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(0),x188_xmm(dst))),u =>
    nt_choose(X188Seq,String.eq(tg(r),"FVarY"),
      k => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(1),x188_xmm(dst))),k =>
      nt_choose(X188Seq,String.eq(tg(r),"FConst"),
        v => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(U32.add(8,agy_f32_find_const(cs,ix(r),0))),x188_xmm(dst))),v =>
        x188_many([
          agy_f32_emit_f2(l,cs,dst),
          agy_f32_emit_f2(r,cs,U32.inc(dst)),
          x188_i2(op,x188_xmm(U32.inc(dst)),x188_xmm(dst))]))))

@unsafe
def agy_f32_emit_f2(e,cs,dst):
  +t = tg(e)
  nt_choose(X188Seq,String.eq(t,"FVarX"),
    u => x188_i2("movaps",x188_xmm(0),x188_xmm(dst)),u =>
    nt_choose(X188Seq,String.eq(t,"FVarY"),
      k => x188_i2("movaps",x188_xmm(1),x188_xmm(dst)),k =>
      nt_choose(X188Seq,String.eq(t,"FConst"),
        v => x188_i2("movaps",x188_xmm(U32.add(8,agy_f32_find_const(cs,ix(e),0))),x188_xmm(dst)),v =>
        nt_choose(X188Seq,String.eq(t,"FBin") && U32.is_eq(terms_len(ks(e)),2),
          w => agy_f32_emit_fbin2(nm(e),kid(e,0),kid(e,1),cs,dst),
          w => X188Empty{}))))

@unsafe
def agy_f32_emit_obs2(obs: Maybe<&2,KTerm>, +cs: List<&2,U32>, +p: String) -> X188Seq:
  match obs:
    case None{}: X188Empty{}
    case Some{oe}:
      x188_many([
        agy_f32_emit_f2(oe,cs,2),
        x188_i2("movd",x188_xmm(2),x188_reg(2,32)),
        x188_i2("cmpl",X187Imm{1333788672,0},x188_reg(2,32)),
        x188_i1("jae",X187Target{p ++ "_oz"}),
        x188_i2("cvttss2siq",x188_xmm(2),x188_reg(2,64)),
        x188_i1("jmp",X187Target{p ++ "_od"}),
        x188_label(p ++ "_oz"),
        x188_i2("xorl",x188_reg(2,32),x188_reg(2,32)),
        x188_label(p ++ "_od")])

@unsafe
def agy_f32_emit_x86_v2(+symbol: String, +ye: KTerm, +obs2: Maybe<&2,KTerm>, +he: KTerm, +cs: List<&2,U32>) -> X181Output:
  +p = ".Lagyf32_" ++ symbol
  +code = x188_many([
    x188_i2("cmpq",X187Imm{0,0},x188_reg(6,64)),
    x188_i1("je",X187Target{p ++ "_done"}),
    x188_i2("movd",x188_reg(2,32),x188_xmm(0)),
    agy_f32_hoist_consts(cs,8),
    x188_label(p ++ "_loop"),
    agy_f32_emit_f2(ye,cs,1),
    agy_f32_emit_obs2(obs2,cs,p),
    x188_i2("movaps",x188_xmm(1),x188_xmm(0)),
    agy_f32_emit_u(he,0),
    x188_i2("movl",x188_reg(0,32),x188_reg(1,32)),
    x188_i2("subq",X187Imm{1,0},x188_reg(6,64)),
    x188_i1("jne",X187Target{p ++ "_loop"}),
    x188_label(p ++ "_done"),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i0("ret")])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    code,X188One{PSize{symbol}}])],""}

@unsafe
def agy_f32_emit_plan(+symbol: String, +function: P113DFunction, +ids: N111Ids, plan: AgyF32Plan) -> X181Output:
  match plan:
    case AgyF32No{}: x181_direct(function,ids)
    case AgyF32Yes{+ye,+obs,+he}:
      +obs2 = agy_f32_subst_opt(obs,ye)
      +cs = agy_f32_collect_opt(obs2,agy_f32_collect_c(ye,[]))
      +ok = U32.is_le(nt_count(U32,cs),8) && U32.is_le(agy_f32_depth(ye),5) &&
            U32.is_le(agy_f32_opt_depth(obs2),5) && U32.is_le(agy_f32_u_depth(he),3) &&
            Bool.not(String.eq(tg(he),"UVarH"))
      nt_choose(X181Output,ok,
        u => agy_f32_emit_x86_v2(symbol,ye,obs2,he,cs),
        u => x181_direct(function,ids))

@unsafe
def agy_f32_try_run(+function: P113DFunction, +symbol: String, +params: List<&2,String>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +cleaned = x185_dead_body([],
    x185_copy_function(params,[],x186_expression_body([],
      x190_local_values_body([],x192_predicate_body(x186_private_body(params,[],
        x185_prepare_body(params,[],x185_scratch_body(params,[],body))))))))
  agy_f32_emit_plan(symbol,function,ids,agy_f32_certify(params,cleaned))

@unsafe
def agy_f32_try_direct(+function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      nt_choose(X181Output,U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_f32_try_run(function,p113e_symbol(name),Con{"state",x181_param_names(params)},body,ids),
        u => x181_direct(function,ids))
'''

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return s.replace(old, new, 1)

def apply(src: str) -> str:
    # Fix forward defs before insertion: move agy_f32_call_fbin2 before agy_f32_call_fbin, etc.
    anchor = "@unsafe\ndef x185_array_function("
    src = once(src, anchor, F32LOOP_BEND + "\n\n" + anchor, "insert agy_f32loop")
    old_hook = "v => x185_array_selected(function,ids,heap),v => x181_direct(function,ids)))"
    new_hook = "v => x185_array_selected(function,ids,heap),v => agy_f32_try_direct(function,ids)))"
    src = once(src, old_hook, new_hook, "hook x185_array_function -> agy_f32_try_direct")
    return src

def main():
    src_path = Path(sys.argv[1])
    dst_path = Path(sys.argv[2])
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    dst_path.write_text(apply(src_path.read_text()))
    print(f"Patched {dst_path} ({dst_path.stat().st_size} bytes)")

if __name__ == "__main__":
    main()

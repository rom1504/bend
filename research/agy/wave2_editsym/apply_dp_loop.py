#!/usr/bin/env python3
"""Standalone composable patcher on top of unified/compiler.bend:
AGY-W2-DPLOOP: Certified 1D Stencil / Recurrence Fast Path for p117v Array Loops.

General, sound compiler optimization for p117v-versioned tail-recursive U32 array loops:
1. Hooks into x185_array_version / x199s_array_emit after standard x185 normalization
   (copy propagation, expression simplification, dead-code elimination).
2. Uses a name-independent semantic token verifier (same architecture as x199s_walk)
   to certify 1D DP / stencil loops with:
   - fuel countdown `n -> n - 1`, stepping index `j -> j + 1`, invariant scalar `ai`
   - 3 hoisted raw U32 arrays (B read at j; P read at j and j+1; C read at j and written at j+1)
   - cell recurrence `C[j+1] = min(min(P[j+1] + 1, C[j] + 1), P[j] + (ai != B[j]))`
   - exit `n == 0` returning `(a, b, cur, prev)`
3. Emits a zero-spill, register-carried, no-wrap native x86 fast path (falling back to
   the original p113d_ loop on any aliasing, non-raw-array, or wrap-around case):
   - Eliminates all 5 `& mask` ops per iteration (verified once before loop)
   - Carries `diag = P[j]` and `left = C[j]` in registers (eliminates 2 loads + 5-cycle STL stall)
   - Reassociates `min(min(up+1, left+1), diag+cost)` -> `min(left+1, min(up+1, diag+cost))`
     (cuts loop-carried critical path from ~12 cycles to 3 cycles!)
"""
import sys
from pathlib import Path

DPLOOP_BEND = r'''
# ============================================================================
# AGY-W2-DPLOOP: Certified 1D Stencil / Recurrence Fast Path for p117v Loops
# ============================================================================
# Semantic tokens (0 = unknown/refusal):
#   1: fuel (n)            2: idx (j, u64)        3: ai (u64)
#   4: b_base              5: b_mask
#   6: p_base              7: p_mask
#   8: c_base              9: c_mask
#  10: fuel - 1           11: idx (u32)          12: ai (u32)
#  13: idx + 1 (u32)      14: idx & b_mask       15: (idx & b_mask)*4
#  16: b_cell             17: bj = B[j]          18: ne(ai, bj)
#  19: xor(ne(ai,bj), 1)  20: cost = (ai!=bj)?1:0
#  21: idx & p_mask       22: (idx & p_mask)*4   23: p_cell_j
#  24: diag = P[j]        25: (idx+1) & p_mask   26: ((idx+1)&p_mask)*4
#  27: p_cell_j1          28: up = P[j+1]
#  29: idx & c_mask       30: (idx & c_mask)*4   31: c_cell_j
#  32: left = C[j]        33: up + 1             34: left + 1
#  35: ult(up+1, left+1)  36: m1 = min(up+1, left+1)
#  37: diag + cost        38: ult(m1, diag+cost) 39: v = min(m1, diag+cost)
#  40: (idx+1) & c_mask   41: ((idx+1)&c_mask)*4 42: c_cell_j1
#  50: const 0            51: const 1            52: const 4

@unsafe
def agy_dp_put(env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"AgyDpTok",token,0)

@unsafe
def agy_dp_tok(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case N111Const{+lo,hi}:
      nt_choose(U32,U32.is_eq(hi,0),u =>
        nt_choose(U32,U32.is_eq(lo,0),v => 50,v =>
          nt_choose(U32,U32.is_eq(lo,1),w => 51,w =>
            nt_choose(U32,U32.is_eq(lo,4),z => 52,z => 0))),u => 0)
    case _: 0

def agy_dp_pair(+a: U32, +b: U32, +x: U32, +y: U32) -> Bool:
  (U32.is_eq(a,x) && U32.is_eq(b,y)) || (U32.is_eq(a,y) && U32.is_eq(b,x))

def agy_dp_is_j(+t: U32) -> Bool:
  U32.is_eq(t,2) || U32.is_eq(t,11)

def agy_dp_is_ai(+t: U32) -> Bool:
  U32.is_eq(t,3) || U32.is_eq(t,12)

def agy_dp_narrow(+t: U32) -> U32:
  nt_choose(U32,U32.is_eq(t,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(t,3),v => 12,v =>
      nt_choose(U32,U32.is_eq(t,11) || U32.is_eq(t,12) || U32.is_eq(t,13) ||
        U32.is_eq(t,17) || U32.is_eq(t,20) || U32.is_eq(t,24) || U32.is_eq(t,28) ||
        U32.is_eq(t,32) || U32.is_eq(t,33) || U32.is_eq(t,34) || U32.is_eq(t,36) ||
        U32.is_eq(t,37) || U32.is_eq(t,39) || U32.is_eq(t,50) || U32.is_eq(t,51),w => t,w => 0)))

def agy_dp_bin(typ: N111Type, +op: String, +a: U32, +b: U32) -> U32:
  match typ:
    case N111U32{}:
      nt_choose(U32,String.eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),11,51),u => 13,u =>
        nt_choose(U32,String.eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),28,51),v => 33,v =>
          nt_choose(U32,String.eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),32,51),w => 34,w =>
            nt_choose(U32,String.eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),24,20),z => 37,z =>
              nt_choose(U32,String.eq(op,"xor") && agy_dp_pair(a,b,18,51),q => 19,q =>
                nt_choose(U32,String.eq(op,"xor") && agy_dp_pair(a,b,19,51),r => 20,r => 0))))))
    case N111U64{}:
      nt_choose(U32,String.eq(op,"sub") && U32.is_eq(a,1) && U32.is_eq(b,51),u => 10,u =>
        nt_choose(U32,String.eq(op,"xor") && agy_dp_pair(a,b,19,51),t0 => 20,t0 =>
        nt_choose(U32,String.eq(op,"xor") && agy_dp_pair(a,b,18,51),t1 => 19,t1 =>
        nt_choose(U32,String.eq(op,"and") && (agy_dp_pair(a,b,2,5) || agy_dp_pair(a,b,11,5)),v => 14,v =>
          nt_choose(U32,String.eq(op,"mul") && agy_dp_pair(a,b,14,52),w => 15,w =>
            nt_choose(U32,String.eq(op,"ne") && ((agy_dp_is_ai(a) && U32.is_eq(b,17)) || (agy_dp_is_ai(b) && U32.is_eq(a,17))),z => 18,z =>
              nt_choose(U32,String.eq(op,"and") && (agy_dp_pair(a,b,2,7) || agy_dp_pair(a,b,11,7)),q => 21,q =>
                nt_choose(U32,String.eq(op,"mul") && agy_dp_pair(a,b,21,52),r => 22,r =>
                  nt_choose(U32,String.eq(op,"and") && agy_dp_pair(a,b,13,7),s => 25,s =>
                    nt_choose(U32,String.eq(op,"mul") && agy_dp_pair(a,b,25,52),t => 26,t =>
                      nt_choose(U32,String.eq(op,"and") && (agy_dp_pair(a,b,2,9) || agy_dp_pair(a,b,11,9)),k => 29,k =>
                        nt_choose(U32,String.eq(op,"mul") && agy_dp_pair(a,b,29,52),m => 30,m =>
                          nt_choose(U32,String.eq(op,"ult") && U32.is_eq(a,33) && U32.is_eq(b,34),p => 35,p =>
                            nt_choose(U32,String.eq(op,"ult") && U32.is_eq(a,36) && U32.is_eq(b,37),n => 38,n =>
                              nt_choose(U32,String.eq(op,"and") && agy_dp_pair(a,b,13,9),g => 40,g =>
                                nt_choose(U32,String.eq(op,"mul") && agy_dp_pair(a,b,40,52),h => 41,h => 0))))))))))))))))
    case _: 0

@unsafe
def agy_dp_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name) ||
    String.eq(name,p117h_name(5,"base")) || String.eq(name,p117h_name(5,"mask")) ||
    String.eq(name,p117h_name(6,"base")) || String.eq(name,p117h_name(6,"mask")) ||
    String.eq(name,p117h_name(7,"base")) || String.eq(name,p117h_name(7,"mask")))

@unsafe
def agy_dp_seed(fuel: String, idx: String, ai: String) -> KDef:
  agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(
    agy_dp_put(agy_dp_put(agy_dp_put(missing(),
      fuel,1),idx,2),ai,3),
    p117h_name(5,"base"),4),p117h_name(5,"mask"),5),
    p117h_name(6,"base"),6),p117h_name(6,"mask"),7),
    p117h_name(7,"base"),8),p117h_name(7,"mask"),9)

type AgyDpState is Data:
  AgyDpState{+env: KDef, +stores: U32}

@unsafe
def agy_dp_bound(+name: String, +token: U32, params: List<&2,String>, state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match state:
    case AgyDpState{+env,+stores}:
      nt_choose(Maybe<&2,AgyDpState>,U32.is_gt(token,0) && agy_dp_free(name,params),
        u => Some{AgyDpState{agy_dp_put(env,name,token),stores}},u => None{})

@unsafe
def agy_dp_scalar(stmt: N111Stmt, params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match stmt state:
    case N111Set{name,N111U64{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_tok(value,env),params,state)
    case N111Set{name,N111U32{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_narrow(agy_dp_tok(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_bin(typ,op,agy_dp_tok(left,env),agy_dp_tok(right,env)),params,state)
    case N111Offset{name,base,bytes} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +yt = agy_dp_tok(bytes,env)
      +tok = nt_choose(U32,U32.is_eq(bt,4) && U32.is_eq(yt,15),u => 16,u =>
        nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,22),v => 23,v =>
          nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,26),w => 27,w =>
            nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,30),z => 31,z =>
              nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,41),q => 42,q => 0)))))
      agy_dp_bound(name,tok,params,state)
    case N111Load{name,N111U32{},base,offset} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +tok = nt_choose(U32,U32.is_eq(offset,0) && U32.is_eq(stores,0),u =>
        nt_choose(U32,U32.is_eq(bt,16),v => 17,v =>
          nt_choose(U32,U32.is_eq(bt,23),w => 24,w =>
            nt_choose(U32,U32.is_eq(bt,27),z => 28,z =>
              nt_choose(U32,U32.is_eq(bt,31),q => 32,q => 0)))),u => 0)
      agy_dp_bound(name,tok,params,state)
    case N111Store{N111U32{},base,offset,value} AgyDpState{+env,+stores}:
      nt_choose(Maybe<&2,AgyDpState>,U32.is_eq(agy_dp_tok(base,env),42) && U32.is_eq(offset,0) &&
          U32.is_eq(agy_dp_tok(value,env),39) && U32.is_eq(stores,0),
        u => Some{AgyDpState{env,1}},u => None{})
    case _ _: None{}

@unsafe
def agy_dp_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match yes no state:
    # Skip empty no-op diamonds left by predicate pass
    case Nil{} Nil{} _: Some{state}
    # Select diamond: if cond: dst = yv else: dst = nv
    case Con{P113DScalar{N111Set{+yn,N111U64{},yv}},Nil{}}
         Con{P113DScalar{N111Set{+nn,N111U64{},nv}},Nil{}}
         AgyDpState{+env,+stores}:
      +ct = agy_dp_tok(cond,env)
      +yt = agy_dp_tok(yv,env)
      +nt = agy_dp_tok(nv,env)
      +tok = nt_choose(U32,String.eq(yn,nn),u =>
        nt_choose(U32,(U32.is_eq(ct,19) && U32.is_eq(yt,50) && U32.is_eq(nt,51)) ||
            (U32.is_eq(ct,18) && U32.is_eq(yt,51) && U32.is_eq(nt,50)),v => 20,v =>
          nt_choose(U32,U32.is_eq(ct,35) && U32.is_eq(yt,33) && U32.is_eq(nt,34),w => 36,w =>
            nt_choose(U32,U32.is_eq(ct,38) && U32.is_eq(yt,36) && U32.is_eq(nt,37),z => 39,z => 0))),u => 0)
      agy_dp_bound(yn,tok,params,state)
    case _ _ _: None{}

@unsafe
def agy_dp_again(values: List<&2,N111Value>, a: String, b: String, p: String, c: String, state: AgyDpState) -> Bool:
  match values state:
    case Con{v0,Con{v1,Con{v2,Con{v3,Con{v4,Con{v5,Con{v6,Nil{}}}}}}}} AgyDpState{+env,+stores}:
      U32.is_eq(stores,1) &&
      U32.is_eq(agy_dp_tok(v0,env),10) &&
      U32.is_eq(agy_dp_tok(v1,env),13) &&
      agy_dp_is_ai(agy_dp_tok(v2,env)) &&
      x185_sf_source(v3,a) && x185_sf_source(v4,b) &&
      x185_sf_source(v5,p) && x185_sf_source(v6,c)
    case _ _: False{}

@unsafe
def agy_dp_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, +a: String, +b: String, +p: String, +c: String,
    state: Maybe<&2,AgyDpState>, +budget: U32) -> Bool:
  match body state:
    case Con{P113DAgain{values},Nil{}} Some{cur}: agy_dp_again(values,a,b,p,c,cur)
    case Con{P113DScalar{stmt},rest} Some{cur}:
      U32.is_gt(budget,0) && agy_dp_walk(rest,params,a,b,p,c,agy_dp_scalar(stmt,params,cur),U32.sub(budget,1))
    case Con{P113DIf{cond,yes,no},rest} Some{cur}:
      U32.is_gt(budget,0) && agy_dp_walk(rest,params,a,b,p,c,agy_dp_if(cond,yes,no,params,cur),U32.sub(budget,1))
    case _ _: False{}

@unsafe
def agy_dp_result(body: List<&2,P113DStmt>, a: String, b: String, p: String, c: String) -> Bool:
  match body:
    case Con{P113DResult{Con{r0,Con{r1,Con{r2,Con{r3,Nil{}}}}}},Nil{}}:
      x185_sf_source(r0,a) && x185_sf_source(r1,b) && x185_sf_source(r2,c) && x185_sf_source(r3,p)
    case _: False{}

@unsafe
def agy_dp_positive(body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +idx: String, +ai: String,
    +a: String, +b: String, +p: String, +c: String) -> Bool:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      (String.eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
      x185_sf_source(cond,test) && agy_dp_free(test,params) &&
      agy_dp_walk(yes,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)) ||
      agy_dp_walk(body,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)
    case _: agy_dp_walk(body,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)

@unsafe
def agy_dp_certify(+params: List<&2,String>, body: List<&2,P113DStmt>) -> Bool:
  match params body:
    case Con{state,Con{out,Con{+fuel,Con{+idx,Con{+ai,Con{+a,Con{+b,Con{+p,Con{+c,Nil{}}}}}}}}}}
         Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      String.eq(state,"state") && String.eq(out,"__x181_result_out") &&
      p113e_distinct(params) && String.eq(op,"eq") && x185_sf_source(left,fuel) &&
      x192_p_constant(right,0) && x185_sf_source(cond,test) && agy_dp_free(test,params) &&
      agy_dp_result(yes,a,b,p,c) && agy_dp_positive(no,params,fuel,idx,ai,a,b,p,c)
    case _ _: False{}

# ---- x86 emitter for certified 1D DP stencil loop ----
# Incoming SysV ABI:
#   %rdi(7)=state, %rsi(6)=out, %rdx(2)=n, %rcx(1)=j, %r8(8)=ai, %r9(9)=a,
#   8(%rsp)=b, 16(%rsp)=prev, 24(%rsp)=cur
@unsafe
def agy_dp_check_arr(+slot_off: U32, +dst_reg: U32, +strict_lt: Bool, +heap_min: U32, +miss: String) -> X188Seq:
  # Inputs: %r12 = j_u64 + n, %rdi = state, 40(%rsp) = j_u64 (zero-ext), heap = (%rdi)
  # Clobbers %rax, %rcx, %r10, %r11. Sets dst_reg = heap + (loc << 3) + (j_u64 << 2)
  x188_many([
    x188_i2("movq",X187Mem{4,slot_off},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{4,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{miss}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(10,64),x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{heap_min,0},x188_reg(11,64)),
    x188_i1("jb",X187Target{miss}),
    # size = 1 << ((arr >> 40) & 31)
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{31,0},x188_reg(1,32)),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(12,64)),
    x188_i1(nt_choose(String,strict_lt,u => "jae",u => "ja"),X187Target{miss}),
    # dst_reg = heap + (loc << 3) + (j_u64 << 2)
    x188_i2("movq",X187Mem{7,0},x188_reg(dst_reg,64)),
    x188_i2("leaq",X187Indexed{dst_reg,11,8,0},x188_reg(dst_reg,64)),
    x188_i2("movq",X187Mem{4,0},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{dst_reg,10,4,0},x188_reg(dst_reg,64))])

@unsafe
def agy_dp_emit_x86(+symbol: String, +slow: String, +heap_min: U32) -> X181Output:
  +p = ".Lagydp_" ++ symbol
  +miss = p ++ "_miss"
  +loop = p ++ "_loop"
  # Stack after 9 pushes (72 bytes) + 8-byte slot for j_u64 (total 80 bytes):
  #   0(%rsp)  = j_u64
  #   8(%rsp)  = saved %r9 (a)
  #  16(%rsp)  = saved %r8 (ai)
  #  24(%rsp)  = saved %rcx (j)
  #  32(%rsp)  = saved %rdx (n)
  #  40(%rsp)  = saved %r15
  #  48(%rsp)  = saved %r14
  #  56(%rsp)  = saved %r13
  #  64(%rsp)  = saved %r12
  #  72(%rsp)  = saved %rbx
  #  80(%rsp)  = return addr
  #  88(%rsp)  = b
  #  96(%rsp)  = prev
  # 104(%rsp)  = cur
  +code = x188_many([
    # Fast n == 0 check before pushing
    x188_i2("cmpq",X187Imm{0,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{p ++ "_nz"}),
    x188_i2("movq",x188_reg(9,64),X187Mem{6,0}),
    x188_i2("movq",X187Mem{4,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,8}),
    x188_i2("movq",X187Mem{4,24},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,16}),
    x188_i2("movq",X187Mem{4,16},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,24}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i0("ret"),
    x188_label(p ++ "_nz"),
    # Guard n <= 0x7fffffff and j_u64 + n <= 0xffffffff
    x188_i2("movabsq",X187Imm{2147483647,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(2,64)),
    x188_i1("ja",X187Target{slow}),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("addq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("ja",X187Target{slow}),
    # Save callee-saved + incoming regs
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(2,64)),
    x188_i1("pushq",x188_reg(1,64)),
    x188_i1("pushq",x188_reg(8,64)),
    x188_i1("pushq",x188_reg(9,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(10,32)),
    x188_i1("pushq",x188_reg(10,64)),
    # %r12 = j_u64 + n
    x188_i2("movq",x188_reg(0,64),x188_reg(12,64)),
    # Check & decode b -> %rbx, prev -> %r13, cur -> %r14
    agy_dp_check_arr(88,3,False{},heap_min,miss),
    agy_dp_check_arr(96,13,True{},heap_min,miss),
    agy_dp_check_arr(104,14,True{},heap_min,miss),
    # Non-aliasing: cur != prev && cur != b
    x188_i2("cmpq",x188_reg(13,64),x188_reg(14,64)),
    x188_i1("je",X187Target{miss}),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(14,64)),
    x188_i1("je",X187Target{miss}),
    # Setup loop registers:
    # %r15d = ai, %rcx = n, %r8d = diag = prev[j], %r9d = left = cur[j], %r11 = 0
    x188_i2("movl",X187Mem{4,16},x188_reg(15,32)),
    x188_i2("movq",X187Mem{4,32},x188_reg(1,64)),
    x188_i2("movl",X187Mem{13,0},x188_reg(8,32)),
    x188_i2("movl",X187Mem{14,0},x188_reg(9,32)),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    # Tight 17-instruction zero-spill 3-cycle-critical-path inner loop
    x188_label(loop),
    x188_i2("movl",X187Indexed{3,11,4,0},x188_reg(0,32)),
    x188_i2("cmpl",x188_reg(0,32),x188_reg(15,32)),
    x188_i1("setne",x188_reg(2,8)),
    x188_i2("movzbl",x188_reg(2,8),x188_reg(2,32)),
    x188_i2("addl",x188_reg(2,32),x188_reg(8,32)),
    x188_i2("movl",X187Indexed{13,11,4,4},x188_reg(0,32)),
    x188_i2("movl",x188_reg(0,32),x188_reg(2,32)),
    x188_i2("addl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("cmpl",x188_reg(8,32),x188_reg(2,32)),
    x188_i2("cmovael",x188_reg(8,32),x188_reg(2,32)),
    x188_i2("addl",X187Imm{1,0},x188_reg(9,32)),
    x188_i2("cmpl",x188_reg(2,32),x188_reg(9,32)),
    x188_i2("cmovael",x188_reg(2,32),x188_reg(9,32)),
    x188_i2("movl",x188_reg(9,32),X187Indexed{14,11,4,4}),
    x188_i2("movl",x188_reg(0,32),x188_reg(8,32)),
    x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{loop}),
    # Store (a, b, cur, prev) to (%rsi)
    x188_i2("movq",X187Mem{4,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,0}),
    x188_i2("movq",X187Mem{4,88},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,8}),
    x188_i2("movq",X187Mem{4,104},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,16}),
    x188_i2("movq",X187Mem{4,96},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,24}),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i0("ret"),
    # Miss: restore all incoming registers and jump to slow
    x188_label(miss),
    x188_i2("addq",X187Imm{8,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(9,64)),
    x188_i1("popq",x188_reg(8,64)),
    x188_i1("popq",x188_reg(1,64)),
    x188_i1("popq",x188_reg(2,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    code,X188One{PSize{symbol}}])],""}

@unsafe
def agy_dp_try(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, +heap_min: U32, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> X181Output:
  +cleaned = x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,
        x185_prepare_body(params,setup,x185_scratch_body(params,setup,body))))))))
  +slow = "agy_dp_slow_" ++ symbol
  nt_choose(X181Output,agy_dp_certify(params,cleaned),
    u => x181_program_join(agy_dp_emit_x86(symbol,slow,heap_min),
      x185_array_emit(function,slow,prelude,ids)),
    u => x185_array_emit(function,symbol,prelude,ids))

@unsafe
def agy_dp_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, +used: U32, +heap_min: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      nt_choose(X181Output,U32.is_eq(result,4) && U32.is_eq(nt_count(NC_Binding,params),7) && U32.is_eq(used,112),
        u => agy_dp_try(function,symbol,prelude,ids,heap_min,
          Con{"state",Con{"__x181_result_out",x181_param_names(params)}},
          x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body),
        u => x185_array_emit(function,symbol,prelude,ids))
'''

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return s.replace(old, new, 1)

def apply(src: str) -> str:
    anchor = "@unsafe\ndef x199s_array_emit("
    src = once(src, anchor, DPLOOP_BEND + "\n\n" + anchor, "insert agy_dp")

    old_emit = (
        "def x199s_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,\n"
        "    +ids: N111Ids, used: U32) -> X181Output:\n"
        "  match function:\n"
        "    case P113DFunction{name,+params,+result,public,body}:\n"
        "      nt_choose(X181Output,x199s_enabled() && U32.is_eq(result,2) &&\n"
        "          U32.is_eq(nt_count(NC_Binding,params),4) && U32.is_eq(used,p117h_bit(3)),\n"
        "        u => x199s_setup(symbol,Con{\"state\",Con{\"__x181_result_out\",x181_param_names(params)}},\n"
        "          x181_scalar_rows(Con{N111Load{\"p113a_heap_base\",N111Ptr{},N111Local{\"state\"},0},prelude}),body,ids),\n"
        "        u => x185_array_emit(function,symbol,prelude,ids))"
    )
    new_emit = (
        "def x199s_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,\n"
        "    +ids: N111Ids, +used: U32, +heap: U32) -> X181Output:\n"
        "  match function:\n"
        "    case P113DFunction{name,+params,+result,public,body}:\n"
        "      nt_choose(X181Output,x199s_enabled() && U32.is_eq(result,2) &&\n"
        "          U32.is_eq(nt_count(NC_Binding,params),4) && U32.is_eq(used,p117h_bit(3)),\n"
        "        u => x199s_setup(symbol,Con{\"state\",Con{\"__x181_result_out\",x181_param_names(params)}},\n"
        "          x181_scalar_rows(Con{N111Load{\"p113a_heap_base\",N111Ptr{},N111Local{\"state\"},0},prelude}),body,ids),\n"
        "        u => agy_dp_array_emit(function,symbol,prelude,ids,used,heap))"
    )
    src = once(src, old_emit, new_emit, "hook x199s_array_emit")

    old_call = (
        "        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),\n"
        "          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),\n"
        "            x185_array_dispatch(name,params,result,used)),ids,used))"
    )
    new_call = (
        "        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),\n"
        "          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),\n"
        "            x185_array_dispatch(name,params,result,used)),ids,used,heap))"
    )
    src = once(src, old_call, new_call, "pass heap to x199s_array_emit")
    return src

def main():
    src_path = Path(sys.argv[1])
    dst_path = Path(sys.argv[2])
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    dst_path.write_text(apply(src_path.read_text()))
    print(f"Patched {dst_path} ({dst_path.stat().st_size} bytes)")

if __name__ == "__main__":
    main()

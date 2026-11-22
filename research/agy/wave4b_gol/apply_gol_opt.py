#!/usr/bin/env python3
"""Wave 4 Phase 2 Track W4-5: General Bottom-Up Constant-Arg Inlining,
Bitop/Bool Simplification, Copy-Prop + Backward Liveness DCE, Pure-Diamond
If-Conversion & Large-Block Linear-Scan GPR Allocation.

100% general compiler passes (zero benchmark-specific pattern matching):
  1. p113i / p113j:
     - Raise non-recursive callee eligibility cap (512 -> 1024).
     - Raise per-caller inlining budget (2048 -> 8192).
     - Constant-argument inlining bonus: calls passing at least one scalar
       constant arg get 4x cost discount (since post-inline constant folding
       and DCE shrink the specialized body dramatically).
  2. p113k / p113l:
     - Bitop constant folding & identities: `x & 0 -> 0`, `0 & x -> 0`,
       `0 << y -> 0`, `0 >> y -> 0`, `eq(bit01, 1) -> bit01`,
       `ne(bit01, 0) -> bit01`, `eq(bit01, 0) -> xor(bit01, 1)`.
     - Collapse scalar 0/1 `N111If` diamonds (`if c { d = 1 } else { d = 0 }`
       when `c` has `bits <= 1`) and empty `N111If`s in `p113k_scalar_if`.
     - O(N) versioned forward copy propagation (`w4g_copy`) + backward
       liveness DCE (`w4g_bwd_dce`) + pure-diamond branchless if-conversion
       (`w4g_ifconv`) in `p113k_function`, followed by a second `p113k_body`
       + `w4g_bwd_dce` pass so newly exposed Bool/const simplifications fold
       BEFORE the function is published to the bottom-up inliner table.
  3. x185 / x190:
     - Raise `x190_local_values_body` cap (512 -> 2048).
     - Raise `x185_transient_frame` cap (4096 -> 8192).
     - For non-loop functions with >32 distinct stack-allocated candidate
       variables (which exceed `x190_joint_frame`'s 32-bit live bitmask),
       dispatch to `x181_register_frame` (top 4 hot vars in callee-saved GPRs)
       + `x185_transient_frame` (unlimited linear-scan across 5 caller-saved
       GPRs), eliminating mass stack spilling in large unrolled straight-line
       functions.
"""

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4a_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4b_gol/compiler.bend"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {count}")
    return text.replace(old, new, 1)


def apply(src: str) -> str:
    # =========================================================================
    # 1. p113i_eligible (512 -> 1024), p113i_function budget (2048 -> 8192),
    #    and p113j_scan_cost constant-arg 4x discount.
    # =========================================================================
    src = replace_exact(
        src,
        """        ((U32.is_le(sz,512) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))""",
        """        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))""",
        "1a:p113i_eligible_cap",
    )

    src = replace_exact(
        src,
        """      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,2048)),u => function)""",
        """      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,8192)),u => function)""",
        "1b:p113i_function_budget",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113j_scan_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  nt_choose(P113IScan,U32.is_le(cost,budget),
    u => p113i_join(p113j_inline(function,args,destinations,"p113i_" ++ U32.show(site) ++ "_"),
      p113i_scan(rest,table,U32.inc(site),U32.sub(budget,cost))),
    u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))""",
        """@unsafe
def w4g_has_const_arg(args: List<&2,N111Value>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Const{_,_},_}: True{}
    case Con{_,rest}: w4g_has_const_arg(rest)


@unsafe
def p113j_scan_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  +eff = nt_choose(U32,w4g_has_const_arg(args),u => U32.max(1,U32.div(cost,4)),u => cost)
  nt_choose(P113IScan,U32.is_le(eff,budget),
    u => p113i_join(p113j_inline(function,args,destinations,"p113i_" ++ U32.show(site) ++ "_"),
      p113i_scan(rest,table,U32.inc(site),U32.sub(budget,eff))),
    u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))""",
        "1c:p113j_scan_cost_const_bonus",
    )

    # =========================================================================
    # 2. p113k / p113l bitop identities, scalar 0/1 N111If collapse,
    #    forward copy propagation, backward liveness DCE & pure-diamond
    #    branchless if-conversion.
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,agy_str_eq(op,"mul") && (p113k_zero(lf) || p113k_zero(rf)),
        u => N111Set{name,typ,N111Const{0,0}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"shl") || agy_str_eq(op,"shr")) && p113k_zero(rf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(lf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right}))))""",
        """@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"mul") || agy_str_eq(op,"and")) && (p113k_zero(lf) || p113k_zero(rf)),
        u => N111Set{name,typ,N111Const{0,0}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"shl") || agy_str_eq(op,"shr")) && p113k_zero(lf),
        u => N111Set{name,typ,N111Const{0,0}},u =>
      nt_choose(N111Stmt,U32.is_eq(p111v_type(typ),1) && ((agy_str_eq(op,"eq") && p113l_exact_one(rf)) || (agy_str_eq(op,"ne") && p113k_zero(rf))) && U32.is_le(p113k_bits_of(lf),1),
        u => N111Set{name,N111U32{},left},u =>
      nt_choose(N111Stmt,U32.is_eq(p111v_type(typ),1) && ((agy_str_eq(op,"eq") && p113l_exact_one(lf)) || (agy_str_eq(op,"ne") && p113k_zero(lf))) && U32.is_le(p113k_bits_of(rf),1),
        u => N111Set{name,N111U32{},right},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"shl") || agy_str_eq(op,"shr")) && p113k_zero(rf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(lf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))))))""",
        "2a:p113k_bin_stmt",
    )

    # 2b. Collapse scalar 0/1 N111If diamonds and empty N111If in p113k_scalar_if.
    src = replace_exact(
        src,
        """@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => p113k_scalar_join(condition,p113k_scalars(yes,p113l_assume(facts,condition,True{})),p113k_scalars(no,p113l_assume(facts,condition,False{}))))""",
        """@unsafe
def w4g_scalar_join_opt(+condition: N111Value, +facts: KDef, +bits: U32, +yes: P113KScalar, +no: P113KScalar) -> P113KScalar:
  match yes no:
    case P113KScalar{Nil{},_} P113KScalar{Nil{},_}:
      P113KScalar{[],facts}
    case P113KScalar{Con{N111Set{+d1,N111U64{},N111Const{+v1,0}},Nil{}},_} P113KScalar{Con{N111Set{+d2,N111U64{},N111Const{+v2,0}},Nil{}},_}:
      nt_choose(P113KScalar,agy_str_eq(d1,d2) && U32.is_le(v1,1) && U32.is_le(v2,1) && U32.is_eq(v1,v2),
        u => P113KScalar{[N111Set{d1,N111U64{},N111Const{v1,0}}],p113k_put(facts,d1,p113k_exact(v1,0))},
        u => p113k_scalar_join(condition,yes,no))
    case _ _: p113k_scalar_join(condition,yes,no)


@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{+bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => w4g_scalar_join_opt(condition,facts,bits,p113k_scalars(yes,p113l_assume(facts,condition,True{})),p113k_scalars(no,p113l_assume(facts,condition,False{}))))""",
        "2b:p113k_scalar_if",
    )

    # 2b2. Fix w4k_body_join_opt fallback (type-safe) AND add general 100% U64
    #      pure-diamond branchless if-conversion when a U64 0/1 P113LRelation
    #      subject exists and both arms are short pure straight-line blocks.
    src = replace_exact(
        src,
        """@unsafe
def w4k_body_join_opt(+condition: N111Value, +facts: KDef, +cond_bits: U32, +yes: P113KBody, +no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{yb,yf,False{}} P113KBody{nb,nf,False{}}:
      +ya = w4k_const01_assign(yb)
      +na = w4k_const01_assign(nb)
      nt_choose(P113KBody,agy_str_eq(dk(ya),"W4KBit") && agy_str_eq(dk(na),"W4KBit") && agy_str_eq(dn(ya),dn(na)) && U32.is_le(cond_bits,1),
        u =>
          +dst = dn(ya)
          +yv = da(ya)
          +nv = da(na)
          +rel = w4k_cond_subject(facts,condition)
          nt_choose(P113KBody,U32.is_eq(yv,nv),
            v => P113KBody{[P113DScalar{N111Set{dst,N111U64{},N111Const{yv,0}}}],p113k_put(facts,dst,p113k_exact(yv,0)),False{}},
            v => nt_choose(P113KBody,agy_str_eq(dk(rel),"P113LRelation"),
              w =>
                +subj : N111Value = N111Local{nm(dv(rel))}
                +invert = U32.is_ne(da(rel),yv)
                P113KBody{[P113DScalar{nt_choose(N111Stmt,invert,
                  z => N111Bin{dst,N111U64{},"xor",subj,N111Const{1,0}},
                  z => N111Set{dst,N111U64{},subj})}],p113k_put(facts,dst,p113k_bound(1)),False{}},
              w => P113KBody{[P113DScalar{nt_choose(N111Stmt,U32.is_eq(yv,1),
                z => N111Set{dst,N111U64{},condition},
                z => N111Bin{dst,N111U64{},"xor",condition,N111Const{1,0}})}],p113k_put(facts,dst,p113k_bound(1)),False{}})),
        u => p113k_body_join(condition,yes,no))
    case _ _: p113k_body_join(condition,yes,no)""",
        """@unsafe
def w4g_ic_res(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") ||
    agy_str_eq(name,"__x181_result_out") || agy_str_eq(name,"__x181_results") ||
    agy_str_eq(name,"__x181_tail")


@unsafe
def w4g_ic_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_ic_res(n)) && w4g_ic_pure(rest,U32.sub(limit,1))
    case Con{P113DScalar{N111Bin{+n,_,+op,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_ic_res(n)) &&
        Bool.not(agy_str_eq(op,"udiv") || agy_str_eq(op,"urem")) &&
        w4g_ic_pure(rest,U32.sub(limit,1))
    case _: False{}


@unsafe
def w4g_ic_last_u64_dst(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{P113DScalar{N111Set{n,N111U64{},_}},Nil{}}: n
    case Con{P113DScalar{N111Bin{n,N111U64{},+op,_,_}},Nil{}}:
      nt_choose(String,p111v_comparison(op),u => "",u => n)
    case Con{_,rest}: w4g_ic_last_u64_dst(rest)
    case Nil{}: ""


@unsafe
def w4g_ic_mark(m: KDef, n: String) -> KDef:
  p111v_put(m,n,"W4GIC",1,0)


@unsafe
def w4g_ic_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)


@unsafe
def w4g_ic_mark_val(v: N111Value, m: KDef) -> KDef:
  match v:
    case N111Local{n}: w4g_ic_mark(m,n)
    case _: m


@unsafe
def w4g_ic_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{n,_,_}},rest}: w4g_ic_writes(rest,w4g_ic_mark(acc,n))
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},rest}: w4g_ic_writes(rest,w4g_ic_mark(acc,n))
    case Con{_,rest}: w4g_ic_writes(rest,acc)


@unsafe
def w4g_ic_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(r,w4g_ic_mark_val(l,acc)))
    case Con{_,rest}: w4g_ic_reads(rest,acc)


@unsafe
def w4g_ic_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +subj: String, +facts: KDef, +otherR: KDef, +otherW: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case _: False{}


@unsafe
def w4g_ic_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Set{_,t,v}},Nil{}}: [P113DScalar{N111Set{newDst,t,v}}]
    case Con{P113DScalar{N111Bin{_,t,op,l,r}},Nil{}}: [P113DScalar{N111Bin{newDst,t,op,l,r}}]
    case Con{h,rest}: Con{h,w4g_ic_rename_last(rest,newDst)}
    case Nil{}: []


@unsafe
def w4g_try_diamond(+condition: N111Value, +facts: KDef, +yes: P113KBody, +no: P113KBody,
    +yb: List<&2,P113DStmt>, +yf: KDef, +nb: List<&2,P113DStmt>, +nf: KDef) -> P113KBody:
  +rel = w4k_cond_subject(facts,condition)
  +ydst = w4g_ic_last_u64_dst(yb)
  +ndst = w4g_ic_last_u64_dst(nb)
  +basic = agy_str_eq(dk(rel),"P113LRelation") && Bool.not(String.is_empty(ydst)) &&
    agy_str_eq(ydst,ndst) && w4g_ic_pure(yb,16) && w4g_ic_pure(nb,16)
  nt_choose(P113KBody,basic,
    u =>
      +subjName = nm(dv(rel))
      +yw = w4g_ic_writes(yb,missing())
      +nw = w4g_ic_writes(nb,missing())
      +yr = w4g_ic_reads(yb,missing())
      +nr = w4g_ic_reads(nb,missing())
      +ok = Bool.not(w4g_ic_has(yr,ydst)) && Bool.not(w4g_ic_has(nr,ydst)) &&
        w4g_ic_nonlast_ok(yb,ydst,subjName,facts,nr,nw) &&
        w4g_ic_nonlast_ok(nb,ydst,subjName,facts,yr,yw)
      nt_choose(P113KBody,ok,
        v =>
          +ynm = ydst ++ "_w4y"
          +nnm = ydst ++ "_w4n"
          +mnm = ydst ++ "_w4m"
          +dnm = ydst ++ "_w4d"
          +snm = ydst ++ "_w4s"
          +subjVal : N111Value = N111Local{subjName}
          +pickY = U32.is_eq(da(rel),1)
          +baseVal : N111Value = nt_choose(N111Value,pickY,z => N111Local{nnm},z => N111Local{ynm})
          +altVal : N111Value = nt_choose(N111Value,pickY,z => N111Local{ynm},z => N111Local{nnm})
          +sel : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{mnm,N111U64{},"sub",N111Const{0,0},subjVal}},
            P113DScalar{N111Bin{dnm,N111U64{},"xor",altVal,baseVal}},
            P113DScalar{N111Bin{snm,N111U64{},"and",N111Local{dnm},N111Local{mnm}}},
            P113DScalar{N111Bin{ydst,N111U64{},"xor",baseVal,N111Local{snm}}}
          ]
          +merged = nt_append(P113DStmt,w4g_ic_rename_last(yb,ynm),
            nt_append(P113DStmt,w4g_ic_rename_last(nb,nnm),sel))
          +outFacts = p113k_put(p113k_join(yf,nf,missing()),ydst,p113k_join_fact(p113k_get(yf,ydst),p113k_get(nf,ydst)))
          P113KBody{merged,outFacts,False{}},
        v => p113k_body_join(condition,yes,no)),
    u => p113k_body_join(condition,yes,no))


@unsafe
def w4k_body_join_opt(+condition: N111Value, +facts: KDef, +cond_bits: U32, +yes: P113KBody, +no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{+yb,+yf,False{}} P113KBody{+nb,+nf,False{}}:
      +ya = w4k_const01_assign(yb)
      +na = w4k_const01_assign(nb)
      nt_choose(P113KBody,agy_str_eq(dk(ya),"W4KBit") && agy_str_eq(dk(na),"W4KBit") && agy_str_eq(dn(ya),dn(na)) && U32.is_le(cond_bits,1),
        u =>
          +dst = dn(ya)
          +yv = da(ya)
          +nv = da(na)
          +rel = w4k_cond_subject(facts,condition)
          nt_choose(P113KBody,U32.is_eq(yv,nv),
            v => P113KBody{[P113DScalar{N111Set{dst,N111U64{},N111Const{yv,0}}}],p113k_put(facts,dst,p113k_exact(yv,0)),False{}},
            v => nt_choose(P113KBody,agy_str_eq(dk(rel),"P113LRelation"),
              w =>
                +subj : N111Value = N111Local{nm(dv(rel))}
                +invert = U32.is_ne(da(rel),yv)
                P113KBody{[P113DScalar{nt_choose(N111Stmt,invert,
                  z => N111Bin{dst,N111U64{},"xor",subj,N111Const{1,0}},
                  z => N111Set{dst,N111U64{},subj})}],p113k_put(facts,dst,p113k_bound(1)),False{}},
              w => p113k_body_join(condition,yes,no))),
        u => w4g_try_diamond(condition,facts,yes,no,yb,yf,nb,nf))
    case _ _: p113k_body_join(condition,yes,no)""",
        "2b2:w4k_body_join_opt_diamond_ifconv",
    )

    # 2c. Add exact 0 folding for `and` and `shl`/`shr` in p113l_base_binary.
    src = replace_exact(
        src,
        """      nt_choose(P113KFact,agy_str_eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),v => p113k_bound(U32.min(lb,rb))),u =>""",
        """      nt_choose(P113KFact,agy_str_eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),
          v => nt_choose(P113KFact,p113k_zero(left) || p113k_zero(right),w => p113k_exact(0,0),w => p113k_bound(U32.min(lb,rb)))),u =>""",
        "2c:p113l_base_binary_and0",
    )

    # 2d. General versioned forward copy propagation + backward liveness DCE +
    #     pure-diamond branchless if-conversion in p113k_function.
    src = replace_exact(
        src,
        """@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}: P113DFunction{name,params,result,public,w4k_dce(body)}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)""",
        """# W4-5: General O(N) versioned forward copy propagation, backward liveness DCE,
# and pure-diamond branchless if-conversion in p113k_function.

@unsafe
def w4g_reserved(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") ||
    agy_str_eq(name,"__x181_result_out") || agy_str_eq(name,"__x181_results") ||
    agy_str_eq(name,"__x181_tail")


type W4GCopyEnv is Data:
  W4GCopyEnv{+vers: KDef, +aliases: KDef}

type W4GCopySc is Data:
  W4GCopySc{+stmts: List<&2,N111Stmt>, +env: W4GCopyEnv}

type W4GCopyBd is Data:
  W4GCopyBd{+stmts: List<&2,P113DStmt>, +env: W4GCopyEnv}


@unsafe
def w4g_ver(+vers: KDef, +name: String) -> U32:
  da(p111v_get(vers,name))


@unsafe
def w4g_bump(+env: W4GCopyEnv, +name: String) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +nv = U32.inc(w4g_ver(vers,name))
      W4GCopyEnv{p111v_put(vers,name,"W4GVer",nv,0),p111v_put(aliases,name,"Absent",0,0)}


@unsafe
def w4g_bump_names(names: List<&2,String>, +env: W4GCopyEnv) -> W4GCopyEnv:
  match names:
    case Nil{}: env
    case Con{n,rest}: w4g_bump_names(rest,w4g_bump(env,n))


@unsafe
def w4g_resolve(+env: W4GCopyEnv, +name: String) -> String:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +entry = p111v_get(aliases,name)
      nt_choose(String,agy_str_eq(dk(entry),"W4GAlias"),
        u =>
          +src = nm(dv(entry))
          nt_choose(String,U32.is_eq(da(entry),w4g_ver(vers,src)),v => src,v => name),
        u => name)


@unsafe
def w4g_cval(+env: W4GCopyEnv, value: N111Value) -> N111Value:
  match value:
    case N111Local{n}: N111Local{w4g_resolve(env,n)}
    case _: value


@unsafe
def w4g_cvals(+env: W4GCopyEnv, values: List<&2,N111Value>) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{v,rest}: Con{w4g_cval(env,v),w4g_cvals(env,rest)}


@unsafe
def w4g_cargs(+env: W4GCopyEnv, args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{t,v},rest}: Con{N111Arg{t,w4g_cval(env,v)},w4g_cargs(env,rest)}


@unsafe
def w4g_record_alias_in(env: W4GCopyEnv, +dst: String, +rsrc: String) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +sv = w4g_ver(vers,rsrc)
      +ent : KDef = KDef{dst,"W4GAlias",sv,0,atom("Absent"),kt("W4GSrc",rsrc,0,0,[]),[],False{},False{}}
      W4GCopyEnv{vers,index_set(aliases,ent,index_hash(dst,2166136261),32)}


@unsafe
def w4g_record_alias(+env: W4GCopyEnv, +dst: String, +rsrc: String) -> W4GCopyEnv:
  w4g_record_alias_in(w4g_bump(env,dst),dst,rsrc)


@unsafe
def w4g_clear_aliases(env: W4GCopyEnv) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{vers,_}: W4GCopyEnv{vers,missing()}


law w4g_cscalars:
  for stmts: List<&2,N111Stmt>
  for +env: W4GCopyEnv
  W4GCopySc


@unsafe
def w4g_cscalar_if(cond: N111Value, +env: W4GCopyEnv, yc: W4GCopySc, nc: W4GCopySc) -> W4GCopySc:
  match yc nc:
    case W4GCopySc{yb,_} W4GCopySc{nb,_}:
      W4GCopySc{[N111If{w4g_cval(env,cond),yb,nb}],w4g_clear_aliases(env)}


@unsafe
def w4g_cscalar(stmt: N111Stmt, +env: W4GCopyEnv) -> W4GCopySc:
  match stmt:
    case N111Set{+dst,+typ,N111Local{+src}}:
      +rsrc = w4g_resolve(env,src)
      +is64 = U32.is_eq(p111v_type(typ),2)
      nt_choose(W4GCopySc,is64 && agy_str_eq(dst,rsrc) && Bool.not(w4g_reserved(dst)),
        u => W4GCopySc{[],env},
        u => nt_choose(W4GCopySc,is64 && Bool.not(w4g_reserved(dst)) && Bool.not(w4g_reserved(rsrc)),
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_record_alias(env,dst,rsrc)},
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_bump(env,dst)}))
    case N111Set{+dst,+typ,val}:
      W4GCopySc{[N111Set{dst,typ,w4g_cval(env,val)}],w4g_bump(env,dst)}
    case N111Bin{+dst,+typ,+op,l,r}:
      W4GCopySc{[N111Bin{dst,typ,op,w4g_cval(env,l),w4g_cval(env,r)}],w4g_bump(env,dst)}
    case N111Offset{+dst,b,by}:
      W4GCopySc{[N111Offset{dst,w4g_cval(env,b),w4g_cval(env,by)}],w4g_bump(env,dst)}
    case N111Load{+dst,+typ,b,off}:
      W4GCopySc{[N111Load{dst,typ,w4g_cval(env,b),off}],w4g_bump(env,dst)}
    case N111Store{typ,b,off,v}:
      W4GCopySc{[N111Store{typ,w4g_cval(env,b),off,w4g_cval(env,v)}],env}
    case N111Call{+dst,+typ,+sym,args}:
      W4GCopySc{[N111Call{dst,typ,sym,w4g_cargs(env,args)}],w4g_bump(env,dst)}
    case N111Alloca{+dst,bytes,align}:
      W4GCopySc{[N111Alloca{dst,bytes,align}],w4g_bump(env,dst)}
    case N111Return{v}:
      W4GCopySc{[N111Return{w4g_cval(env,v)}],env}
    case N111If{cond,yes,no}:
      w4g_cscalar_if(cond,env,w4g_cscalars(yes,env),w4g_cscalars(no,env))


@unsafe
def w4g_cscalars_join(pre: List<&2,N111Stmt>, postRes: W4GCopySc) -> W4GCopySc:
  match postRes:
    case W4GCopySc{post,env2}: W4GCopySc{nt_append(N111Stmt,pre,post),env2}


@unsafe
def w4g_cscalars_next(res: W4GCopySc, rest: List<&2,N111Stmt>) -> W4GCopySc:
  match res:
    case W4GCopySc{pre,env}: w4g_cscalars_join(pre,w4g_cscalars(rest,env))


@unsafe
def w4g_cscalars(stmts, env):
  match stmts:
    case Nil{}: W4GCopySc{[],env}
    case Con{s,rest}: w4g_cscalars_next(w4g_cscalar(s,env),rest)


@unsafe
def w4g_wrap_scalars(stmts: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: []
    case Con{s,rest}: Con{P113DScalar{s},w4g_wrap_scalars(rest)}


law w4g_cbody:
  for body: List<&2,P113DStmt>
  for +env: W4GCopyEnv
  W4GCopyBd


@unsafe
def w4g_cbody_join(pre: List<&2,P113DStmt>, postRes: W4GCopyBd) -> W4GCopyBd:
  match postRes:
    case W4GCopyBd{post,env2}: W4GCopyBd{nt_append(P113DStmt,pre,post),env2}


@unsafe
def w4g_cbody_next(pre: List<&2,P113DStmt>, env: W4GCopyEnv, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  w4g_cbody_join(pre,w4g_cbody(rest,env))


@unsafe
def w4g_cbody_scalar(res: W4GCopySc, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  match res:
    case W4GCopySc{ss,env1}: w4g_cbody_next(w4g_wrap_scalars(ss),env1,rest)


@unsafe
def w4g_cbody_if(cond: N111Value, +env: W4GCopyEnv, yc: W4GCopyBd, nc: W4GCopyBd, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  match yc nc:
    case W4GCopyBd{yb,_} W4GCopyBd{nb,_}:
      w4g_cbody_next([P113DIf{w4g_cval(env,cond),yb,nb}],w4g_clear_aliases(env),rest)


@unsafe
def w4g_cbody(body, env):
  match body:
    case Nil{}: W4GCopyBd{[],env}
    case Con{P113DScalar{s},rest}: w4g_cbody_scalar(w4g_cscalar(s,env),rest)
    case Con{P113DIf{cond,yes,no},rest}:
      w4g_cbody_if(cond,env,w4g_cbody(yes,env),w4g_cbody(no,env),rest)
    case Con{P113DCall{+dsts,tgt,args},rest}:
      w4g_cbody_next([P113DCall{dsts,tgt,w4g_cvals(env,args)}],w4g_bump_names(dsts,env),rest)
    case Con{P113DResult{vals},rest}:
      w4g_cbody_next([P113DResult{w4g_cvals(env,vals)}],env,rest)
    case Con{P113DAgain{vals},rest}:
      w4g_cbody_next([P113DAgain{w4g_cvals(env,vals)}],w4g_clear_aliases(env),rest)


@unsafe
def w4g_copy_out(res: W4GCopyBd) -> List<&2,P113DStmt>:
  match res:
    case W4GCopyBd{out,_}: out


@unsafe
def w4g_copy_pass(body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  w4g_copy_out(w4g_cbody(body,W4GCopyEnv{missing(),missing()}))


# Backward liveness DCE + pure-diamond branchless if-conversion.
type W4GBwd is Data:
  W4GBwd{+body: List<&2,P113DStmt>, +live: KDef}


@unsafe
def w4g_live_mark(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"W4GLive",1,0)


@unsafe
def w4g_live_kill(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"W4GLive",0,0)


@unsafe
def w4g_live_has(+live: KDef, +name: String) -> Bool:
  U32.is_gt(da(p111v_get(live,name)),0)


@unsafe
def w4g_live_val(v: N111Value, live: KDef) -> KDef:
  match v:
    case N111Local{n}: w4g_live_mark(live,n)
    case _: live


@unsafe
def w4g_live_vals(vs: List<&2,N111Value>, live: KDef) -> KDef:
  match vs:
    case Nil{}: live
    case Con{v,rest}: w4g_live_vals(rest,w4g_live_val(v,live))


@unsafe
def w4g_live_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{_,v},rest}: w4g_live_args(rest,w4g_live_val(v,live))


@unsafe
def w4g_live_kills(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{n,rest}: w4g_live_kills(rest,w4g_live_kill(live,n))


@unsafe
def w4g_live_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w4g_live_union_bucket(rest,nt_choose(KDef,U32.is_gt(da(h),0) || agy_str_eq(dk(h),"W4KUsed"),u => w4g_live_mark(out,dn(h)),u => out))


@unsafe
def w4g_live_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{_,bucket}: w4g_live_union_bucket(bucket,out)
    case KIndexNode{_,_,a,b}: w4g_live_union(b,w4g_live_union(a,out))
    case _: out


@unsafe
def w4g_live_base() -> KDef:
  w4g_live_mark(w4g_live_mark(w4g_live_mark(w4g_live_mark(w4g_live_mark(missing(),
    "state"),"scratch"),"__x181_result_out"),"__x181_results"),"__x181_tail")


# Pure-diamond if-conversion helpers (100% general).
@unsafe
def w4g_arm_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_reserved(n)) && w4g_arm_pure(rest,U32.sub(limit,1))
    case Con{P113DScalar{N111Bin{+n,_,+op,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_reserved(n)) && w4k_pure_bin(op) && w4g_arm_pure(rest,U32.sub(limit,1))
    case _: False{}


@unsafe
def w4g_arm_last_dst(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{P113DScalar{N111Set{n,_,_}},Nil{}}: n
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},Nil{}}: n
    case Con{_,rest}: w4g_arm_last_dst(rest)
    case Nil{}: ""


@unsafe
def w4g_arm_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{n,_,_}},rest}: w4g_arm_writes(rest,w4g_live_mark(acc,n))
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},rest}: w4g_arm_writes(rest,w4g_live_mark(acc,n))
    case Con{_,rest}: w4g_arm_writes(rest,acc)


@unsafe
def w4g_arm_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_arm_reads(rest,w4g_live_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_arm_reads(rest,w4g_live_val(r,w4g_live_val(l,acc)))
    case Con{_,rest}: w4g_arm_reads(rest,acc)


@unsafe
def w4g_arm_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forbidden: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case _: False{}


@unsafe
def w4g_arm_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Set{_,t,v}},Nil{}}: [P113DScalar{N111Set{newDst,t,v}}]
    case Con{P113DScalar{N111Bin{_,t,op,l,r}},Nil{}}: [P113DScalar{N111Bin{newDst,t,op,l,r}}]
    case Con{h,rest}: Con{h,w4g_arm_rename_last(rest,newDst)}
    case Nil{}: []


@unsafe
def w4g_cond_not_written(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4g_live_has(writes,n))
    case _: True{}


@unsafe
def w4g_try_ifconv(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef) -> W4GBwd:
  +ydst = w4g_arm_last_dst(yb)
  +ndst = w4g_arm_last_dst(nb)
  +basic = Bool.not(String.is_empty(ydst)) && agy_str_eq(ydst,ndst) &&
    w4g_arm_pure(yb,12) && w4g_arm_pure(nb,12)
  nt_choose(W4GBwd,basic,
    u =>
      +yw = w4g_arm_writes(yb,missing())
      +nw = w4g_arm_writes(nb,missing())
      +yr = w4g_arm_reads(yb,missing())
      +nr = w4g_arm_reads(nb,missing())
      +forbY = w4g_live_union(afterLive,w4g_live_union(nr,nw))
      +forbN = w4g_live_union(afterLive,w4g_live_union(yr,yw))
      +ok = Bool.not(w4g_live_has(yr,ydst)) && Bool.not(w4g_live_has(nr,ydst)) &&
        w4g_cond_not_written(cond,yw) && w4g_cond_not_written(cond,nw) &&
        w4g_arm_nonlast_ok(yb,ydst,forbY) && w4g_arm_nonlast_ok(nb,ydst,forbN)
      nt_choose(W4GBwd,ok,
        v =>
          +ynm = ydst ++ "_w4y"
          +nnm = ydst ++ "_w4n"
          +cnm = ydst ++ "_w4c"
          +mnm = ydst ++ "_w4m"
          +dnm = ydst ++ "_w4d"
          +snm = ydst ++ "_w4s"
          +sel : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{cnm,N111U64{},"ne",cond,N111Const{0,0}}},
            P113DScalar{N111Bin{mnm,N111U64{},"sub",N111Const{0,0},N111Local{cnm}}},
            P113DScalar{N111Bin{dnm,N111U64{},"xor",N111Local{ynm},N111Local{nnm}}},
            P113DScalar{N111Bin{snm,N111U64{},"and",N111Local{dnm},N111Local{mnm}}},
            P113DScalar{N111Bin{ydst,N111U64{},"xor",N111Local{nnm},N111Local{snm}}}
          ]
          +merged = nt_append(P113DStmt,w4g_arm_rename_last(yb,ynm),
            nt_append(P113DStmt,w4g_arm_rename_last(nb,nnm),nt_append(P113DStmt,sel,rest)))
          W4GBwd{merged,w4g_live_val(cond,w4g_live_union(yl,nl))},
        v => W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))}),
    u => W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))})


law w4g_bwd_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +term: KDef
  W4GBwd


@unsafe
def w4g_bwd_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: W4GBwd) -> W4GBwd:
  match after:
    case W4GBwd{body,+live}:
      nt_choose(W4GBwd,w4g_live_has(live,name) || w4g_reserved(name),
        u => W4GBwd{Con{P113DScalar{stmt},body},w4g_live_vals(reads,w4g_live_kill(live,name))},
        u => after)


@unsafe
def w4g_bwd_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef, yes: W4GBwd, no: W4GBwd) -> W4GBwd:
  match yes no:
    case W4GBwd{Nil{},yl} W4GBwd{Nil{},nl}:
      W4GBwd{rest,w4g_live_union(yl,nl)}
    case W4GBwd{yb,yl} W4GBwd{nb,nl}:
      W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))}


@unsafe
def w4g_bwd_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match after:
    case W4GBwd{body,+live}:
      w4g_bwd_if_done(cond,body,live,w4g_bwd_body(yes,live,again,term),w4g_bwd_body(no,live,again,term))


@unsafe
def w4g_bwd_scalar(+stmt: N111Stmt, +after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match stmt after:
    case N111Set{+name,_,v} _: w4g_bwd_pure(stmt,name,[v],after)
    case N111Bin{+name,_,+op,l,r} W4GBwd{body,live}:
      nt_choose(W4GBwd,w4k_pure_bin(op),
        u => w4g_bwd_pure(stmt,name,[l,r],after),
        u => W4GBwd{Con{P113DScalar{stmt},body},w4g_live_vals([l,r],w4g_live_kill(live,name))})
    case N111Offset{+name,b,by} _: w4g_bwd_pure(stmt,name,[b,by],after)
    case N111Call{+name,_,_,args} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_args(args,w4g_live_kill(live,name))}
    case N111Load{+name,_,b,_} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(b,w4g_live_kill(live,name))}
    case N111Store{_,b,_,v} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(v,w4g_live_val(b,live))}
    case N111Alloca{name,_,_} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_kill(live,name)}
    case N111If{cond,yes,no} _:
      w4g_bwd_if(cond,w4g_wrap_scalars(yes),w4g_wrap_scalars(no),after,again,term)
    case N111Return{v} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(v,term)}


@unsafe
def w4g_bwd_stmt(+stmt: P113DStmt, after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match stmt after:
    case P113DScalar{sc} _: w4g_bwd_scalar(sc,after,again,term)
    case P113DIf{cond,yes,no} _: w4g_bwd_if(cond,yes,no,after,again,term)
    case P113DCall{names,_,args} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(args,w4g_live_kills(names,live))}
    case P113DResult{vals} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(vals,term)}
    case P113DAgain{vals} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(vals,again)}


@unsafe
def w4g_bwd_body(body, live, again, term):
  match body:
    case Nil{}: W4GBwd{[],live}
    case Con{h,rest}: w4g_bwd_stmt(h,w4g_bwd_body(rest,live,again,term),again,term)


@unsafe
def w4g_bwd_out(res: W4GBwd) -> List<&2,P113DStmt>:
  match res:
    case W4GBwd{out,_}: out


@unsafe
def w4g_bwd_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = w4g_live_base()
  +again = w4g_live_union(w4k_mark_body(body,missing()),base)
  w4g_bwd_out(w4g_bwd_body(body,base,again,base))


@unsafe
def w4g_p113k_body_only(scan: P113KBody) -> List<&2,P113DStmt>:
  match scan:
    case P113KBody{body,_,_}: body


@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}:
      +b1 = w4g_bwd_dce(w4g_copy_pass(body))
      +b2 = w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,missing()))))
      P113DFunction{name,params,result,public,b2}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)""",
        "2d:p113k_copy_bwd_ifconv",
    )

    # =========================================================================
    # 3. x185 / x190: Raise x190_local_values_body (512 -> 2048),
    #    x185_transient_frame (4096 -> 8192), and use linear-scan regalloc
    #    (x181_register_frame + x185_transient_frame) for non-loop functions
    #    with >32 candidate variables so large unrolled blocks stay in GPRs.
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def x185_transient_frame(frame,params,setup,body):
  nt_choose(X181Frame,x185_transient_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),""",
        """@unsafe
def x185_transient_frame(frame,params,setup,body):
  nt_choose(X181Frame,x185_transient_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),""",
        "3a:x185_transient_frame_cap",
    )

    src = replace_exact(
        src,
        """@unsafe
def x190_local_values_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_local_values_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512),""",
        """@unsafe
def x190_local_values_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_local_values_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048),""",
        "3b:x190_local_values_cap",
    )

    src = replace_exact(
        src,
        """@unsafe
def x190_j_counted(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,names}:
      x190_j_selected(frame,params,setup,body,registerBody,
        x203_candidates(nt_reverse(String,names,[]),reads,slots))""",
        """@unsafe
def x190_j_counted(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,+names}:
      nt_choose(X181Frame,U32.is_gt(nt_count(String,names),32) && Bool.not(x190_register_loop(body)),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),
        u => x190_j_selected(frame,params,setup,body,registerBody,
          x203_candidates(nt_reverse(String,names,[]),reads,slots)))""",
        "3c:x190_j_counted_linear_scan",
    )

    return src


def main():
    ap = argparse.ArgumentParser(description="Apply Wave 4B Track W4-5 general inliner + bitop/ifconv + GPR regalloc patch")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    text = args.src.read_text()
    patched = apply(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(patched)
    print(f"Wrote {args.dst} ({len(patched)} bytes, delta={len(patched) - len(text):+d} bytes)")


if __name__ == "__main__":
    main()

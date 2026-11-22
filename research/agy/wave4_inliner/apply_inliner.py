#!/usr/bin/env python3
"""Wave 4 Track W4-1: General Multi-Pass Inliner (p113i) + Post-Inline U32/F32
Constant Folder + Dead-Binding Elimination + Dead-RC & Scalar Bool Specialization.

100% general compiler passes (zero benchmark-specific pattern matching):
1. Remove whole-program p113a_enabled gate on p169o_certified so ordinary
   p113i inlining runs on all programs (including forked/array workloads).
2. In p169o_walk, allow non-borrow seeds (e.g. Bool.pick) and non-target
   blocked functions (where borrow plan is ineligible) to inline and publish
   to the inliner table while preserving observer borrow targets/workers.
3. Raise p113i site limit (16 -> 64, matching p113j_buffer_peel), budget
   (1024 -> 4096), callee size (512 -> 1024), caller size (2048 -> 8192),
   stack limit (16384 -> 32768), and p113k size cap (4096 -> 32768).
4. Allow 1-iteration peeling of small P113DAgain tail-recursive callees
   (size <= 160) by lowering P113DAgain to P113DCall to the callee.
5. General U32/U64 exact arithmetic constant folding (add, sub, mul, udiv,
   urem, mul-by-0/1, shift-by-0) in p113k.
6. General exact IEEE-754 F32 constant folding (u32_to_f32, f32_add, f32_sub,
   f32_mul, f32_div — exact single-precision rounding, no FMA) via scratch
   slot tracking in p113k.
7. General bits <= 56 dead-RC elimination (p111_rt_sink -> 0, p111_rt_keep -> v),
   scalar 0/1 Bool diamond collapse, and post-p113k dead pure-binding
   elimination (w4k_dce) so folded constant temps are dropped before x181-x188.
"""

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave3b_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4_inliner/compiler.bend"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {count}")
    return text.replace(old, new, 1)


def apply(src: str) -> str:
    # 1. Raise p113i_add saturation from 4096 to 32768.
    src = replace_exact(
        src,
        """@unsafe
def p113i_add(left: U32, right: U32) -> U32:
  U32.min(4096,U32.add(left,right))""",
        """@unsafe
def p113i_add(left: U32, right: U32) -> U32:
  U32.min(32768,U32.add(left,right))""",
        "p113i_add",
    )

    # 2. Allow larger non-recursive callees (<= 1024) and small P113DAgain tail-loop
    #    peeling (<= 160) in p113i_eligible.
    src = replace_exact(
        src,
        """@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),512) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p137qi_returns(body,result)""",
        """@unsafe
def w4i_returns_or_again(body: List<&2,P113DStmt>, +width: U32, +arity: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DAgain{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),arity)
    case Con{P113DIf{condition,yes,no},Nil{}}: w4i_returns_or_again(yes,width,arity) && w4i_returns_or_again(no,width,arity)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && w4i_returns_or_again(rest,width,arity)
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && w4i_returns_or_again(rest,width,arity)
    case Con{P113DCall{destinations,target,args},rest}: w4i_returns_or_again(rest,width,arity)
    case _: False{}


@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +sz = p113i_size(body)
      +arity = nt_count(NC_Binding,params)
      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,32) &&
        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&
        ((U32.is_le(sz,512) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))""",
        "p113i_eligible",
    )

    # 3. Raise site cap (16 -> 64), caller size (2048 -> 8192), budget (1024 -> 2048),
    #    and stack cap (16384 -> 32768).
    src = replace_exact(
        src,
        """@unsafe
def p113i_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,16),
        u => p113j_scan_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))


@unsafe
def p113i_table_function(+function: P113DFunction, +table: P113ITable) -> P113ITable:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(P113ITable,p113i_eligible(function),
        u => p113i_put(table,function,index_hash(name,2166136261),0),u => table)


@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),2048),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,1024)),u => function)

@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),16384),
        u => p113k_function(P113DFunction{name,params,result,public,body}),u => original)""",
        """@unsafe
def p113i_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,64),
        u => p113j_scan_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))


@unsafe
def p113i_table_function(+function: P113DFunction, +table: P113ITable) -> P113ITable:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(P113ITable,p113i_eligible(function),
        u => p113i_put(table,function,index_hash(name,2166136261),0),u => table)


@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,2048)),u => function)

@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),32768),
        u => p113k_function(P113DFunction{name,params,result,public,body}),u => original)""",
        "p113i_scan_stmt_and_function",
    )

    # 4. Expand P113DAgain as P113DCall to callee during inlining (1-iteration peeling)
    #    and raise p113j_buffer_peel limit from 16 to 64.
    src = replace_exact(
        src,
        """@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
        nt_append(P113DStmt,p113i_bind(params,args,prefix),p113j_expand(body,prefix,destinations)))""",
        """@unsafe
def w4i_expand(body: List<&2,P113DStmt>, +prefix: String, +destinations: List<&2,String>, +callee: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{P113DScalar{p112f_stmt(stmt,prefix)},w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),w4i_expand(yes,prefix,destinations,callee),w4i_expand(no,prefix,destinations,callee)},
        w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case Con{P113DAgain{values},rest}:
      [P113DCall{destinations,callee,p113j_values(values,prefix)}]


@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
        nt_append(P113DStmt,p113i_bind(params,args,prefix),w4i_expand(body,prefix,destinations,name)))""",
        "p113j_inline",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,16),u => False{},u =>
    nt_choose(Bool,String.starts_with(name,"p113i_" ++ U32.show(site) ++ "_local_"),
      v => p113j_buffer_origin(String.drop(name,nt_choose(Nat,U32.is_lt(site,10),w => 14n,w => 15n)),input),
      v => p113j_buffer_peel(name,input,U32.inc(site))))""",
        """@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,64),u => False{},u =>
    nt_choose(Bool,String.starts_with(name,"p113i_" ++ U32.show(site) ++ "_local_"),
      v => p113j_buffer_origin(String.drop(name,nt_choose(Nat,U32.is_lt(site,10),w => 14n,w => 15n)),input),
      v => p113j_buffer_peel(name,input,U32.inc(site))))""",
        "p113j_buffer_peel",
    )

    # 5. Strengthen p113k_bin_stmt with mul-by-0/1 and shift-by-0 identities.
    src = replace_exact(
        src,
        """@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add") || agy_str_eq(op,"sub")) && p113k_zero(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))""",
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
        "p113k_bin_stmt",
    )

    # 6. Collapse scalar 0/1 Bool diamonds in p113k_body_if, add post-p113k dead
    #    pure-binding elimination (w4k_dce), and raise p113k_function cap.
    src = replace_exact(
        src,
        """@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => p113k_body_join(condition,p113k_body(yes,p113l_assume(facts,condition,True{})),p113k_body(no,p113l_assume(facts,condition,False{}))))""",
        """@unsafe
def w4k_const01_assign(body: List<&2,P113DStmt>) -> KDef:
  match body:
    case Con{P113DScalar{N111Set{d,N111U64{},N111Const{+v,0}}},Nil{}}:
      nt_choose(KDef,U32.is_le(v,1),u => KDef{d,"W4KBit",v,0,atom("Absent"),atom("Absent"),[],False{},False{}},u => missing())
    case Con{P113DScalar{N111Set{r0,N111U64{},N111Const{v0,0}}},Con{P113DScalar{N111Set{d,N111U64{},N111Const{+v,0}}},Nil{}}}:
      nt_choose(KDef,U32.is_le(v,1) && String.starts_with(r0,"p113i_"),
        u => KDef{d,"W4KBit",v,1,atom("Absent"),kt("R0",r0,v0,0,[]),[],False{},False{}},u => missing())
    case _: missing()


@unsafe
def w4k_cond_subject(+facts: KDef, condition: N111Value) -> KDef:
  match condition:
    case N111Local{name}:
      +rel = p113l_relation(facts,name)
      nt_choose(KDef,agy_str_eq(dk(rel),"P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts,nm(dv(rel)))),1),
        u => rel,u => missing())
    case _: missing()


@unsafe
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
    case _ _: p113k_body_join(condition,yes,no)


@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{+bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => w4k_body_join_opt(condition,facts,bits,p113k_body(yes,p113l_assume(facts,condition,True{})),p113k_body(no,p113l_assume(facts,condition,False{}))))""",
        "p113k_body_if",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}: P113DFunction{name,params,result,public,body}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),4096),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)""",
        """@unsafe
def w4k_mark_val(value: N111Value, used: KDef) -> KDef:
  match value:
    case N111Local{+name}: index_set(used,KDef{name,"W4KUsed",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)
    case _: used


@unsafe
def w4k_mark_vals(values: List<&2,N111Value>, used: KDef) -> KDef:
  match values:
    case Nil{}: used
    case Con{v,rest}: w4k_mark_vals(rest,w4k_mark_val(v,used))


@unsafe
def w4k_mark_args(args: List<&2,N111Arg>, used: KDef) -> KDef:
  match args:
    case Nil{}: used
    case Con{N111Arg{typ,v},rest}: w4k_mark_args(rest,w4k_mark_val(v,used))


law w4k_mark_scalars:
  for body: List<&2,N111Stmt>
  for used: KDef
  KDef


@unsafe
def w4k_mark_scalar(stmt: N111Stmt, used: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,v}: w4k_mark_val(v,used)
    case N111Bin{name,typ,op,l,r}: w4k_mark_val(r,w4k_mark_val(l,used))
    case N111Call{name,typ,sym,args}: w4k_mark_args(args,used)
    case N111If{cond,yes,no}: w4k_mark_scalars(no,w4k_mark_scalars(yes,w4k_mark_val(cond,used)))
    case N111Load{name,typ,base,off}: w4k_mark_val(base,used)
    case N111Store{typ,base,off,v}: w4k_mark_val(v,w4k_mark_val(base,used))
    case N111Offset{name,base,bytes}: w4k_mark_val(bytes,w4k_mark_val(base,used))
    case N111Return{v}: w4k_mark_val(v,used)
    case _: used


@unsafe
def w4k_mark_scalars(body, used):
  match body:
    case Nil{}: used
    case Con{s,rest}: w4k_mark_scalars(rest,w4k_mark_scalar(s,used))


@unsafe
def w4k_mark_body(body: List<&2,P113DStmt>, used: KDef) -> KDef:
  match body:
    case Nil{}: used
    case Con{P113DScalar{s},rest}: w4k_mark_body(rest,w4k_mark_scalar(s,used))
    case Con{P113DIf{cond,yes,no},rest}: w4k_mark_body(rest,w4k_mark_body(no,w4k_mark_body(yes,w4k_mark_val(cond,used))))
    case Con{P113DCall{dsts,tgt,args},rest}: w4k_mark_body(rest,w4k_mark_vals(args,used))
    case Con{P113DResult{vals},rest}: w4k_mark_body(rest,w4k_mark_vals(vals,used))
    case Con{P113DAgain{vals},rest}: w4k_mark_body(rest,w4k_mark_vals(vals,used))


@unsafe
def w4k_is_used(+used: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(used,name)),"W4KUsed")


@unsafe
def w4k_pure_bin(+op: String) -> Bool:
  Bool.not(agy_str_eq(op,"udiv") || agy_str_eq(op,"urem"))


@unsafe
def w4k_dce_scalars(body: List<&2,N111Stmt>, +used: KDef) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{N111Set{+name,typ,v},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name),
        u => Con{N111Set{name,typ,v},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111Bin{+name,typ,+op,l,r},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{N111Bin{name,typ,op,l,r},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111If{cond,yes,no},rest}:
      Con{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)},w4k_dce_scalars(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_scalars(rest,used)}


@unsafe
def w4k_dce_body(body: List<&2,P113DStmt>, +used: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+name,typ,v}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name),
        u => Con{P113DScalar{N111Set{name,typ,v}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111Bin{+name,typ,+op,l,r}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{P113DScalar{N111Bin{name,typ,op,l,r}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111If{cond,yes,no}},rest}:
      Con{P113DScalar{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)}},w4k_dce_body(rest,used)}
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w4k_dce_body(yes,used),w4k_dce_body(no,used)},w4k_dce_body(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_body(rest,used)}


@unsafe
def w4k_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +b1 = w4k_dce_body(body,w4k_mark_body(body,missing()))
  w4k_dce_body(b1,w4k_mark_body(b1,missing()))


@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}: P113DFunction{name,params,result,public,w4k_dce(body)}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)""",
        "p113k_function",
    )

    # 7. Exact U32/U64 arithmetic constant folding in p113l_base_binary.
    src = replace_exact(
        src,
        """@unsafe
def p113l_base_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,p111v_comparison(op),u => p113k_compare(op,left,right),u =>
      nt_choose(P113KFact,agy_str_eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),v => p113k_bound(U32.min(lb,rb))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"or"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.or(ll,rl),U32.or(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"xor"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.xor(ll,rl),U32.xor(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,(agy_str_eq(op,"shr") || agy_str_eq(op,"shl")) && re && U32.is_eq(rh,0) && U32.is_lt(rl,width),
        u => p113k_shift(left,rl,agy_str_eq(op,"shr")),u =>
      nt_choose(P113KFact,agy_str_eq(op,"add"),u => p113k_bound(U32.min(width,U32.inc(U32.max(lb,rb)))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"mul"),u => p113k_bound(U32.min(width,U32.add(lb,rb))),
        u => p113k_bound(width))))))))""",
        """@unsafe
def w4k_add_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +s_lo = U32.add(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(s_lo,0),
    u => p113k_exact(s_lo,U32.add(U32.add(lh,rh),Bool.to_u32(U32.is_lt(s_lo,ll)))))


@unsafe
def w4k_sub_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +d_lo = U32.sub(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(d_lo,0),
    u => p113k_exact(d_lo,U32.sub(U32.sub(lh,rh),Bool.to_u32(U32.is_lt(ll,rl)))))


@unsafe
def w4k_mul_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32, +lb: U32, +rb: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(U32.mul(ll,rl),0),
    u => nt_choose(P113KFact,U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_le(ll,65535) && U32.is_le(rl,65535),
      v => p113k_exact(U32.mul(ll,rl),0),
      v => p113k_bound(U32.min(width,U32.add(lb,rb)))))


@unsafe
def p113l_base_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,p111v_comparison(op),u => p113k_compare(op,left,right),u =>
      nt_choose(P113KFact,agy_str_eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),v => p113k_bound(U32.min(lb,rb))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"or"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.or(ll,rl),U32.or(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"xor"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.xor(ll,rl),U32.xor(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,(agy_str_eq(op,"shr") || agy_str_eq(op,"shl")) && re && U32.is_eq(rh,0) && U32.is_lt(rl,width),
        u => p113k_shift(left,rl,agy_str_eq(op,"shr")),u =>
      nt_choose(P113KFact,agy_str_eq(op,"add"),
        u => nt_choose(P113KFact,le && re,v => w4k_add_exact(ll,lh,rl,rh,width),v => p113k_bound(U32.min(width,U32.inc(U32.max(lb,rb))))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"sub"),
        u => nt_choose(P113KFact,le && re,v => w4k_sub_exact(ll,lh,rl,rh,width),v => p113k_bound(width)),u =>
      nt_choose(P113KFact,agy_str_eq(op,"mul"),
        u => nt_choose(P113KFact,le && re,v => w4k_mul_exact(ll,lh,rl,rh,width,lb,rb),v => p113k_bound(U32.min(width,U32.add(lb,rb)))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"udiv"),
        u => nt_choose(P113KFact,le && re && U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_ne(rl,0),
          v => p113k_exact(U32.div(ll,rl),0),v => p113k_bound(lb)),u =>
      nt_choose(P113KFact,agy_str_eq(op,"urem"),
        u => nt_choose(P113KFact,le && re && U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_ne(rl,0),
          v => p113k_exact(U32.mod(ll,rl),0),v => p113k_bound(U32.min(lb,rb))),
        u => p113k_bound(width)))))))))))""",
        "p113l_base_binary",
    )

    # 8. Exact IEEE-754 F32 constant folding + dead-RC elimination in p113l_base_scalar.
    src = replace_exact(
        src,
        """@unsafe
def p113l_base_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,+typ,+symbol,+args}: P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p185k_call_fact(typ,symbol,args))}
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{typ,base,offset,value}: P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],facts}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}""",
        """@unsafe
def w4k_f32_scale_up(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_up(F32.mul(x,16.0),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_up(F32.mul(x,2.0),U32.sub(k,1))))


@unsafe
def w4k_f32_scale_down(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_down(F32.mul(x,0.0625),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_down(F32.mul(x,0.5),U32.sub(k,1))))


@unsafe
def w4k_bits_to_f32(+bits: U32) -> Maybe<&2,F32>:
  +sign = U32.shrn(bits,31n)
  +exp = U32.and(U32.shrn(bits,23n),255)
  +mant = U32.and(bits,8388607)
  nt_choose(Maybe<&2,F32>,U32.is_eq(exp,0) && U32.is_eq(mant,0),
    u => Some{nt_choose(F32,U32.is_eq(sign,0),v => 0.0,v => F32.neg(0.0))},u =>
  nt_choose(Maybe<&2,F32>,U32.is_ge(exp,1) && U32.is_le(exp,254),
    u =>
      +base = U32.to_f32(U32.or(8388608,mant))
      +mag = nt_choose(F32,U32.is_ge(exp,150),
        v => w4k_f32_scale_up(base,U32.sub(exp,150)),
        v => w4k_f32_scale_down(base,U32.sub(150,exp)))
      Some{nt_choose(F32,U32.is_eq(sign,0),v => mag,v => F32.neg(mag))},
    u => None{}))


@unsafe
def w4k_f32_bin_eval(+id: U32, ma: Maybe<&2,F32>, mb: Maybe<&2,F32>) -> Maybe<&2,U32>:
  match ma mb:
    case Some{+a} Some{+b}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,26),u => Some{F32.bits(F32.add(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,27),u => Some{F32.bits(F32.sub(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,28),u => Some{F32.bits(F32.mul(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,29),u => Some{F32.bits(F32.div(a,b))},u => None{}))))
    case _ _: None{}


@unsafe
def w4k_slot_key(+buf: String, +offset: U32) -> String:
  "@w4slot:" ++ buf ++ ":" ++ U32.show(offset)


@unsafe
def w4k_invalidate_ptr_args(args: List<&2,N111Arg>, +facts: KDef) -> KDef:
  match args:
    case Nil{}: facts
    case Con{N111Arg{N111Ptr{},N111Local{+buf}},+rest}:
      nt_choose(KDef,agy_str_eq(buf,"state"),
        u => w4k_invalidate_ptr_args(rest,facts),
        u => w4k_invalidate_ptr_args(rest,
          p113k_put(p113k_put(facts,w4k_slot_key(buf,0),p113k_bound(64)),w4k_slot_key(buf,8),p113k_bound(64))))
    case Con{_,rest}: w4k_invalidate_ptr_args(rest,facts)


@unsafe
def w4k_fold_u32_to_f32(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef, fact0: P113KFact) -> P113KScalar:
  match fact0:
    case P113KFact{b0,True{},+lo0,0}:
      +bits = F32.bits(U32.to_f32(lo0))
      P113KScalar{[N111Set{name,N111U64{},N111Const{bits,0}}],p113k_put(facts,name,p113k_exact(bits,0))}
    case _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_fold_f32_bin_done(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef, res: Maybe<&2,U32>) -> P113KScalar:
  match res:
    case Some{+bits}:
      P113KScalar{[N111Set{name,N111U64{},N111Const{bits,0}}],p113k_put(facts,name,p113k_exact(bits,0))}
    case None{}:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_fold_f32_bin(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +id: U32, +facts: KDef, fact0: P113KFact, fact1: P113KFact) -> P113KScalar:
  match fact0 fact1:
    case P113KFact{b0,True{},+lo0,0} P113KFact{b1,True{},+lo1,0}:
      w4k_fold_f32_bin_done(name,typ,symbol,args,facts,w4k_f32_bin_eval(id,w4k_bits_to_f32(lo0),w4k_bits_to_f32(lo1)))
    case _ _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_call_fold(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef) -> P113KScalar:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U64{},+val},Nil{}}}:
      +vf = p113k_value(val,facts)
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_sink") && agy_str_eq(state,"state") && U32.is_le(p113k_bits_of(vf),56),
        u => P113KScalar{[N111Set{name,N111U64{},N111Const{0,0}}],p113k_put(facts,name,p113k_exact(0,0))},u =>
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_keep") && agy_str_eq(state,"state") && U32.is_le(p113k_bits_of(vf),56),
        u => P113KScalar{[N111Set{name,N111U64{},p113k_replace(val,facts)}],p113k_put(facts,name,vf)},u =>
        P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buf}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}:
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && U32.is_eq(id,23) && U32.is_eq(count,1),
        u => w4k_fold_u32_to_f32(name,typ,symbol,args,facts,p113k_get(facts,w4k_slot_key(buf,0))),u =>
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && U32.is_ge(id,26) && U32.is_le(id,29) && U32.is_eq(count,2),
        u => w4k_fold_f32_bin(name,typ,symbol,args,id,facts,p113k_get(facts,w4k_slot_key(buf,0)),p113k_get(facts,w4k_slot_key(buf,8))),u =>
        P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}))
    case _ _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}


@unsafe
def w4k_store_facts(typ: N111Type, base: N111Value, +offset: U32, value: N111Value, +facts: KDef) -> KDef:
  match typ base:
    case N111U64{} N111Local{+buf}:
      nt_choose(KDef,U32.is_eq(offset,0) || U32.is_eq(offset,8),
        u => p113k_put(facts,w4k_slot_key(buf,offset),p113k_value(value,facts)),
        u => facts)
    case _ _: facts


@unsafe
def p113l_base_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,+typ,+symbol,+args}: w4k_call_fold(name,typ,symbol,args,facts)
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{+typ,+base,+offset,+value}:
      P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],w4k_store_facts(typ,base,offset,value,facts)}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}""",
        "p113l_base_scalar",
    )

    # 9. In p169o_walk, allow non-borrow seeds to publish to table (without modifying
    #    the seed itself) and allow non-target blocked functions to inline & publish.
    src = replace_exact(
        src,
        """@unsafe
def p169o_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p169o_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(head,table))))""",
        """@unsafe
def w4i_is_borrow_worker(+name: String) -> Bool:
  String.starts_with(name,"$p118borrow.") || String.starts_with(name,"$p128borrow.")


@unsafe
def p169o_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,
              nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && p113i_original_clean(head),
                w => p113i_table_function(head,table),w => table),Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(targets,name),
              v => p169o_walk(rest,seeds,blocked,targets,table,Con{p168t_target(head,table),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(head,table))))""",
        "p169o_walk",
    )

    # 10. Remove whole-program p113a_enabled gate on p169o_certified so ordinary
    #     p113i inlining runs on all programs (including forked/array workloads).
    src = replace_exact(
        src,
        """@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1) && p113a_enabled(certificate),u => 2,u => mode)""",
        """@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1),u => 2,u => mode)""",
        "p169o_certified",
    )

    return src


def main():
    ap = argparse.ArgumentParser(description="Apply Wave 4 Track W4-1 inliner + constant folder patch")
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

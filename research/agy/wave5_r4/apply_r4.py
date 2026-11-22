#!/usr/bin/env python3
"""Wave 5 Engine B Track W5-R4: General Nat.Suc Inline Fast-Path & Loop-Carried Product Unboxing.

100% general compiler passes on top of `wave4c_unified/compiler.bend`:
  1. Pass 1 (`w5_succ_expand` in `x186_late_char`):
     Expands `p111_rt_special_ctor(state, 4 [P111_SPECIAL_SUCC], buffer, 1)` inline with
     exact `NAT_IMM` (`(1<<48)-1`) overflow guard and slow-path fallback to `p111_rt_special_ctor`.
     Eliminates runtime calls inside `Nat`-counting loops (e.g. `1n+j` in cryptographic/hash/tree loops).
  2. Pass 2 (`w5_lcu_selected` wrapping `x185_array_selected`):
     General Loop-Carried Product Unboxing (up to 2 nested product levels) on single-result
     tail-recursive `P113DFunction`s with `P113DAgain`:
     When a loop parameter `p_k` is only inspected via `p111_rt_tag`/`p111_rt_take` (plus
     optional exit `P113DResult`/`p111_rt_sink`) and EVERY `P113DAgain` passes a fresh
     `p111_rt_ctor(state, C, buf, A)` of the same constructor `C` and arity `A` (`1 <= A <= 8`),
     splits the function into:
       - An untouched fallback `w5_lcu_fb_<depth>_<fid>`
       - A thin entry wrapper checking `p111_rt_tag(p_k) == C`, unpacking `p_k` once, and calling
       - An unboxed worker `$lcu<depth>.<name>` whose parameters are the unpacked fields,
         eliminating per-iteration heap ctor/take calls and exposing loop-invariant arrays
         directly to `p117v` array-header hoisting and `w4c_bce` bounds-check elimination.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4c_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5_r4/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_nat_succ_inline(src: str) -> str:
    """Pass 1: Inline fast-path for P111_SPECIAL_SUCC (kind == 4) with exact NAT_IMM guard."""
    old = """@unsafe
def x186_late_char(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        x186_late_registers(stmt,ids,site,bfMask,nt_choose(P114TExpansion,x186_transport_enabled(),
          v => p186rt_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))"""

    new = """# W5-R4 Pass 1: Inline fast-path for P111_SPECIAL_SUCC (kind == 4, arity 1)
# with exact NAT_IMM = (1<<48)-1 = 0x0000FFFFFFFFFFFF overflow guard -> slow fallback.
@unsafe
def w5_succ_args(+stmt: N111Stmt, +dest: String, +site: U32, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
         Con{N111Arg{N111U32{},N111Const{4,0}},
         Con{N111Arg{N111Ptr{},N111Local{+buffer}},
         Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}:
      nt_choose(P114TExpansion,agy_str_eq(state,"state") && Bool.not(agy_str_eq(buffer,"state")),
        u => P114TExpansion{[
          N111Load{p114t_name(site,"succ_in"),N111U64{},N111Local{buffer},0},
          N111Bin{p114t_name(site,"succ_ok"),N111U64{},"ult",p114t_local(site,"succ_in"),N111Const{4294967295,65535}},
          N111If{p114t_local(site,"succ_ok"),
            [N111Bin{dest,N111U64{},"add",p114t_local(site,"succ_in"),N111Const{1,0}}],
            [stmt]}],True{}},
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w5_succ_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,args}:
      nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor"),
        u => w5_succ_args(stmt,dest,site,args),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w5_late_succ(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        x186_late_registers(stmt,ids,site,bfMask,nt_choose(P114TExpansion,x186_transport_enabled(),
          v => p186rt_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x186_late_char(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        w5_late_succ(stmt,ids,site,bfMask,w5_succ_expand(stmt,site)))"""

    return replace_exact(src, old, new, "Pass 1: w5_succ_expand")


def patch_2_loop_carried_unbox(src: str) -> str:
    """Pass 2: General Loop-Carried Product Unboxing across P113DAgain before x185_array_selected."""
    old = """@unsafe
def x185_array_selected(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),
        u => x185_array_plain(function,ids,heap),
        u => x185_array_scanned(function,ids,heap,p117h_walk(body,count,
          P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()})))"""

    new = """# ============================================================================
# W5-R4 Pass 2: General Loop-Carried Product Unboxing across P113DAgain
# ============================================================================
type W5LcuCtor is Data:
  W5LcuNo{}
  W5LcuYes{+ctor: String, +arity: U32, +buf: String, +vals: List<&2,N111Value>, +aName: String}

type W5LcuScan is Data:
  W5LcuScan{+ok: Bool, +seen: Bool, +ctor: String, +arity: U32}

type W5LcuUse is Data:
  W5LcuUse{+ok: Bool, +seenTake: Bool}

type W5LcuCand is Data:
  W5LcuCandNo{}
  W5LcuCandYes{+idx: U32, +pName: String, +ctor: String, +arity: U32}

@unsafe
def w5_lcu_val_is(+name: String, v: N111Value) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,name)
    case _: False{}

@unsafe
def w5_lcu_vals_has(+name: String, vs: List<&2,N111Value>) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{h,rest}: w5_lcu_val_is(name,h) || w5_lcu_vals_has(name,rest)

@unsafe
def w5_lcu_args_has(+name: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w5_lcu_val_is(name,v) || w5_lcu_args_has(name,rest)

@unsafe
def w5_lcu_names_has(+name: String, ns: List<&2,String>) -> Bool:
  match ns:
    case Nil{}: False{}
    case Con{h,rest}: agy_str_eq(h,name) || w5_lcu_names_has(name,rest)

@unsafe
def w5_lcu_nth_val(vs: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:
  match vs:
    case Nil{}: None{}
    case Con{h,rest}:
      nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{h},u => w5_lcu_nth_val(rest,U32.sub(idx,1)))

@unsafe
def w5_lcu_local_opt(mv: Maybe<&2,N111Value>) -> String:
  match mv:
    case Some{N111Local{n}}: n
    case _: ""

# Match `N111Call{dest, N111U64{}, "p111_rt_ctor", [state, N111CtorId{C}, N111Local{buf}, N111Const{A, 0}]}`
@unsafe
def w5_lcu_match_ctor_args(+aName: String, args: List<&2,N111Arg>) -> W5LcuCtor:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+st}},
         Con{N111Arg{N111U32{},N111CtorId{+c}},
         Con{N111Arg{N111Ptr{},N111Local{+buf}},
         Con{N111Arg{N111U32{},N111Const{+a,0}},Nil{}}}}}:
      nt_choose(W5LcuCtor,agy_str_eq(st,"state") && Bool.not(agy_str_eq(buf,"state")) && U32.is_ge(a,1) && U32.is_le(a,8),
        u => W5LcuYes{c,a,buf,[],aName},
        u => W5LcuNo{})
    case _: W5LcuNo{}

@unsafe
def w5_lcu_match_ctor_stmt(+wantName: String, stmt: P113DStmt) -> W5LcuCtor:
  match stmt:
    case P113DScalar{N111Call{+dest,N111U64{},+sym,args}}:
      nt_choose(W5LcuCtor,agy_str_eq(dest,wantName) && agy_str_eq(sym,"p111_rt_ctor"),
        u => w5_lcu_match_ctor_args(dest,args),
        u => W5LcuNo{})
    case _: W5LcuNo{}

# Collect `arity` consecutive `Store(buf, 8*i, v_i)` immediately preceding the ctor call (given reversed prefix).
@unsafe
def w5_lcu_collect_stores(revPrefix: List<&2,P113DStmt>, +buf: String, +wantOff: U32, +acc: List<&2,N111Value>) -> Maybe<&2,List<&2,N111Value>>:
  match revPrefix:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b},+off,+v}},rest}:
      nt_choose(Maybe<&2,List<&2,N111Value>>,agy_str_eq(b,buf) && U32.is_eq(off,wantOff),
        u => nt_choose(Maybe<&2,List<&2,N111Value>>,U32.is_eq(wantOff,0),
          w => Some{Con{v,acc}},
          w => w5_lcu_collect_stores(rest,buf,U32.sub(wantOff,8),Con{v,acc})),
        u => None{})
    case _: None{}

@unsafe
def w5_lcu_drop_n(xs: List<&2,P113DStmt>, +n: U32) -> List<&2,P113DStmt>:
  match xs:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => Con{h,rest},u => w5_lcu_drop_n(rest,U32.sub(n,1)))

@unsafe
def w5_lcu_finish_ctor_vals(+c: String, +a: U32, +buf: String, +aName: String, mv: Maybe<&2,List<&2,N111Value>>) -> W5LcuCtor:
  match mv:
    case Some{vs}: W5LcuYes{c,a,buf,vs,aName}
    case None{}: W5LcuNo{}

@unsafe
def w5_lcu_finish_ctor(mc: W5LcuCtor, revBeforeCtor: List<&2,P113DStmt>) -> W5LcuCtor:
  match mc:
    case W5LcuYes{+c,+a,+buf,_,+aName}:
      w5_lcu_finish_ctor_vals(c,a,buf,aName,w5_lcu_collect_stores(revBeforeCtor,buf,U32.mul(U32.sub(a,1),8),[]))
    case W5LcuNo{}: W5LcuNo{}

@unsafe
def w5_lcu_ctor_before_again(revPrefix: List<&2,P113DStmt>, +aName: String) -> W5LcuCtor:
  match revPrefix:
    case Nil{}: W5LcuNo{}
    case Con{s0,rest}:
      nt_choose(W5LcuCtor,String.is_empty(aName),u => W5LcuNo{},
        u => w5_lcu_finish_ctor(w5_lcu_match_ctor_stmt(aName,s0),rest))

@unsafe
def w5_lcu_merge_scan_mc(+cur: W5LcuScan, +seen: Bool, +c0: String, +a0: U32, mc: W5LcuCtor) -> W5LcuScan:
  match mc:
    case W5LcuNo{}: W5LcuScan{False{},seen,c0,a0}
    case W5LcuYes{+c,+a,_,_,_}:
      nt_choose(W5LcuScan,Bool.not(seen),
        w => W5LcuScan{True{},True{},c,a},
        w => nt_choose(W5LcuScan,agy_str_eq(c0,c) && U32.is_eq(a0,a),
          z => cur,
          z => W5LcuScan{False{},True{},c0,a0}))

@unsafe
def w5_lcu_merge_scan(+cur: W5LcuScan, mc: W5LcuCtor) -> W5LcuScan:
  match cur:
    case W5LcuScan{+ok,+seen,+c0,+a0}:
      nt_choose(W5LcuScan,Bool.not(ok),u => cur,u => w5_lcu_merge_scan_mc(cur,seen,c0,a0,mc))

law w5_lcu_scan_agains:
  for body: List<&2,P113DStmt>
  for +revPrefix: List<&2,P113DStmt>
  for +idx: U32
  for +acc: W5LcuScan
  W5LcuScan

@unsafe
def w5_lcu_scan_agains(body,revPrefix,idx,acc):
  match body:
    case Nil{}: acc
    case Con{P113DAgain{vals},rest}:
      +aName = w5_lcu_local_opt(w5_lcu_nth_val(vals,idx))
      +acc2 = w5_lcu_merge_scan(acc,w5_lcu_ctor_before_again(revPrefix,aName))
      w5_lcu_scan_agains(rest,[],idx,acc2)
    case Con{P113DIf{_,yes,no},rest}:
      +a1 = w5_lcu_scan_agains(yes,[],idx,acc)
      +a2 = w5_lcu_scan_agains(no,[],idx,a1)
      w5_lcu_scan_agains(rest,[],idx,a2)
    case Con{s,rest}:
      w5_lcu_scan_agains(rest,Con{s,revPrefix},idx,acc)

# Check whether every use of `pName` in `body` is admissible (tag/take/sink/result only, never reassigned).
@unsafe
def w5_lcu_is_tag_args(+pName: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{st}},Con{N111Arg{N111U64{},N111Local{w}},Nil{}}}:
      agy_str_eq(st,"state") && agy_str_eq(w,pName)
    case _: False{}

@unsafe
def w5_lcu_is_tag_call(+pName: String, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_tag") && w5_lcu_is_tag_args(pName,args)

@unsafe
def w5_lcu_is_take_args(+pName: String, +arity: U32, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{st}},
         Con{N111Arg{N111U64{},N111Local{w}},
         Con{N111Arg{N111Ptr{},N111Local{buf}},
         Con{N111Arg{N111U32{},N111Const{a,0}},Nil{}}}}}:
      agy_str_eq(st,"state") && agy_str_eq(w,pName) && Bool.not(agy_str_eq(buf,"state")) && U32.is_eq(a,arity)
    case _: False{}

@unsafe
def w5_lcu_is_take_call(+pName: String, +arity: U32, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_take") && w5_lcu_is_take_args(pName,arity,args)

@unsafe
def w5_lcu_is_sink_call(+pName: String, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_sink") && w5_lcu_is_tag_args(pName,args)

law w5_lcu_check_n111_list:
  for xs: List<&2,N111Stmt>
  for +pName: String
  for +arity: U32
  for +acc: W5LcuUse
  W5LcuUse

@unsafe
def w5_lcu_use_fail(u: W5LcuUse) -> W5LcuUse:
  match u:
    case W5LcuUse{_,st}: W5LcuUse{False{},st}

@unsafe
def w5_lcu_use_take(u: W5LcuUse) -> W5LcuUse:
  match u:
    case W5LcuUse{ok,_}: W5LcuUse{ok,True{}}

@unsafe
def w5_lcu_check_n111(stmt: N111Stmt, +pName: String, +arity: U32, +acc: W5LcuUse) -> W5LcuUse:
  match stmt:
    case N111Set{d,_,v}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111Bin{d,_,_,l,r}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,l) || w5_lcu_val_is(pName,r),u => w5_lcu_use_fail(acc),u => acc)
    case N111Load{d,_,b,_}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,b),u => w5_lcu_use_fail(acc),u => acc)
    case N111Store{_,b,_,v}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,b) || w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111Offset{d,b,by}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,b) || w5_lcu_val_is(pName,by),u => w5_lcu_use_fail(acc),u => acc)
    case N111Alloca{d,_,_}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName),u => w5_lcu_use_fail(acc),u => acc)
    case N111Return{v}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111If{c,yes,no}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,c),u => w5_lcu_use_fail(acc),
        u => w5_lcu_check_n111_list(no,pName,arity,w5_lcu_check_n111_list(yes,pName,arity,acc)))
    case N111Call{+d,_,+sym,+args}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName),u => w5_lcu_use_fail(acc),
        u => nt_choose(W5LcuUse,Bool.not(w5_lcu_args_has(pName,args)),w => acc,
          w => nt_choose(W5LcuUse,w5_lcu_is_take_call(pName,arity,sym,args),z => w5_lcu_use_take(acc),
            z => nt_choose(W5LcuUse,w5_lcu_is_tag_call(pName,sym,args) || w5_lcu_is_sink_call(pName,sym,args),
              q => acc,q => w5_lcu_use_fail(acc)))))
    case _: acc

@unsafe
def w5_lcu_check_n111_list(xs,pName,arity,acc):
  match xs:
    case Nil{}: acc
    case Con{h,rest}: w5_lcu_check_n111_list(rest,pName,arity,w5_lcu_check_n111(h,pName,arity,acc))

@unsafe
def w5_lcu_check_body(body: List<&2,P113DStmt>, +pName: String, +arity: U32, +acc: W5LcuUse) -> W5LcuUse:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{s},rest}: w5_lcu_check_body(rest,pName,arity,w5_lcu_check_n111(s,pName,arity,acc))
    case Con{P113DIf{c,yes,no},+rest}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,c),u => w5_lcu_use_fail(acc),
        u => w5_lcu_check_body(rest,pName,arity,
          w5_lcu_check_body(no,pName,arity,w5_lcu_check_body(yes,pName,arity,acc))))
    case Con{P113DCall{ds,_,args},+rest}:
      nt_choose(W5LcuUse,w5_lcu_names_has(pName,ds) || w5_lcu_vals_has(pName,args),
        u => w5_lcu_use_fail(acc),u => w5_lcu_check_body(rest,pName,arity,acc))
    case Con{P113DAgain{vals},+rest}:
      nt_choose(W5LcuUse,w5_lcu_vals_has(pName,vals),
        u => w5_lcu_use_fail(acc),u => w5_lcu_check_body(rest,pName,arity,acc))
    case Con{P113DResult{vals},rest}:
      w5_lcu_check_body(rest,pName,arity,acc)

@unsafe
def w5_lcu_check_use_res(+idx: U32, +pName: String, +ctor: String, +arity: U32, ures: W5LcuUse) -> W5LcuCand:
  match ures:
    case W5LcuUse{uok,seenTake}:
      nt_choose(W5LcuCand,uok && seenTake,w => W5LcuCandYes{idx,pName,ctor,arity},w => W5LcuCandNo{})

@unsafe
def w5_lcu_check_scan_res(+idx: U32, +pName: String, +nParams: U32, +body: List<&2,P113DStmt>, scan: W5LcuScan) -> W5LcuCand:
  match scan:
    case W5LcuScan{ok,seen,+ctor,+arity}:
      nt_choose(W5LcuCand,ok && seen && U32.is_le(U32.sub(U32.add(nParams,arity),1),16),
        u => w5_lcu_check_use_res(idx,pName,ctor,arity,w5_lcu_check_body(body,pName,arity,W5LcuUse{True{},False{}})),
        u => W5LcuCandNo{})

@unsafe
def w5_lcu_check_param(+idx: U32, +pName: String, +nParams: U32, +body: List<&2,P113DStmt>) -> W5LcuCand:
  w5_lcu_check_scan_res(idx,pName,nParams,body,w5_lcu_scan_agains(body,[],idx,W5LcuScan{True{},False{},"",0}))

law w5_lcu_find_param:
  for params: List<&2,NC_Binding>
  for +idx: U32
  for +nParams: U32
  for +body: List<&2,P113DStmt>
  W5LcuCand

@unsafe
def w5_lcu_find_param_res(cand: W5LcuCand, rest: List<&2,NC_Binding>, +idx: U32, +nParams: U32, +body: List<&2,P113DStmt>) -> W5LcuCand:
  match cand:
    case W5LcuCandYes{i,pn,c,a}: W5LcuCandYes{i,pn,c,a}
    case W5LcuCandNo{}: w5_lcu_find_param(rest,U32.inc(idx),nParams,body)

@unsafe
def w5_lcu_find_param(params,idx,nParams,body):
  match params:
    case Nil{}: W5LcuCandNo{}
    case Con{NC_Binding{_,pName,_},rest}:
      w5_lcu_find_param_res(w5_lcu_check_param(idx,pName,nParams,body),rest,idx,nParams,body)

# Helpers for generating field names, bindings, stores, loads, and spliced lists
@unsafe
def w5_lcu_field_name(+depth: U32, +i: U32) -> String:
  "w5_lcu_" ++ U32.show(depth) ++ "_" ++ U32.show(i)

@unsafe
def w5_lcu_field_bindings(+depth: U32, +i: U32, +arity: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,arity),u => [],
    u => Con{NC_Binding{0,w5_lcu_field_name(depth,i),N_W64{}},w5_lcu_field_bindings(depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_stores(+buf: String, +depth: U32, +i: U32, +arity: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(i,arity),u => [],
    u => Con{P113DScalar{N111Store{N111U64{},N111Local{buf},U32.mul(i,8),N111Local{w5_lcu_field_name(depth,i)}}},
             w5_lcu_field_stores(buf,depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_loads(+buf: String, +depth: U32, +i: U32, +arity: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(i,arity),u => [],
    u => Con{P113DScalar{N111Load{w5_lcu_field_name(depth,i),N111U64{},N111Local{buf},U32.mul(i,8)}},
             w5_lcu_field_loads(buf,depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_args(+depth: U32, +i: U32, +arity: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(i,arity),u => [],
    u => Con{N111Arg{N111U64{},N111Local{w5_lcu_field_name(depth,i)}},w5_lcu_field_args(depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_splice_params(params: List<&2,NC_Binding>, +idx: U32, +ins: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  match params:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,NC_Binding>,U32.is_eq(idx,0),
        u => nt_append(NC_Binding,ins,rest),
        u => Con{h,w5_lcu_splice_params(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_splice_vals(vals: List<&2,N111Value>, +idx: U32, +ins: List<&2,N111Value>) -> List<&2,N111Value>:
  match vals:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,N111Value>,U32.is_eq(idx,0),
        u => nt_append(N111Value,ins,rest),
        u => Con{h,w5_lcu_splice_vals(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_splice_args(params: List<&2,NC_Binding>, +idx: U32, +ins: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{_,word,_},+rest}:
      nt_choose(List<&2,N111Arg>,U32.is_eq(idx,0),
        u => nt_append(N111Arg,ins,x185_array_arguments(rest)),
        u => Con{N111Arg{N111U64{},N111Local{word}},w5_lcu_splice_args(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_materialize(+dest: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  +buf = "w5_lcu_box_" ++ U32.show(depth)
  Con{P113DScalar{N111Alloca{buf,U32.mul(arity,8),8}},
    nt_append(P113DStmt,w5_lcu_field_stores(buf,depth,0,arity),
      [P113DScalar{N111Call{dest,N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{ctor}},N111Arg{N111Ptr{},N111Local{buf}},p111_u32(arity)]}}])}

# Fold consecutive `Load(dst, N111U64{}, tbuf, 8*i)` right after a rewritten `p111_rt_take` into `Set(dst, f_i)`
@unsafe
def w5_lcu_count_loads(rest: List<&2,P113DStmt>, +tbuf: String, +arity: U32, +acc: U32) -> U32:
  match rest:
    case Con{P113DScalar{N111Load{_,N111U64{},N111Local{+b},+off}},more}:
      +fidx = U32.div(off,8)
      nt_choose(U32,agy_str_eq(b,tbuf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(fidx,arity),
        u => w5_lcu_count_loads(more,tbuf,arity,U32.inc(acc)),
        u => acc)
    case _: acc

@unsafe
def w5_lcu_fold_loads(rest: List<&2,P113DStmt>, +tbuf: String, +arity: U32, +depth: U32, +revOut: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match rest:
    case Con{P113DScalar{N111Load{+dst,N111U64{},N111Local{+b},+off}},+more}:
      +fidx = U32.div(off,8)
      nt_choose(List<&2,P113DStmt>,agy_str_eq(b,tbuf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(fidx,arity),
        u => w5_lcu_fold_loads(more,tbuf,arity,depth,Con{P113DScalar{N111Set{dst,N111U64{},N111Local{w5_lcu_field_name(depth,fidx)}}},revOut}),
        u => nt_append(P113DStmt,nt_reverse(P113DStmt,revOut,[]),Con{P113DScalar{N111Load{dst,N111U64{},N111Local{b},off}},more}))
    case other: nt_append(P113DStmt,nt_reverse(P113DStmt,revOut,[]),other)

@unsafe
def w5_lcu_take_buf(args: List<&2,N111Arg>) -> String:
  match args:
    case Con{_,Con{_,Con{N111Arg{_,N111Local{buf}},_}}}: buf
    case _: ""

@unsafe
def w5_lcu_prepend_rev(xs: List<&2,P113DStmt>, revAcc: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match xs:
    case Nil{}: revAcc
    case Con{h,rest}: w5_lcu_prepend_rev(rest,Con{h,revAcc})

law w5_lcu_rewrite:
  for body: List<&2,P113DStmt>
  for +revAcc: List<&2,P113DStmt>
  for +idx: U32
  for +pName: String
  for +ctor: String
  for +arity: U32
  for +depth: U32
  List<&2,P113DStmt>

@unsafe
def w5_lcu_rewrite_again_mc(mc: W5LcuCtor, +vals: List<&2,N111Value>, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  match mc:
    case W5LcuYes{_,+a,_,+fvs,_}:
      +trimmed = w5_lcu_drop_n(revAcc,U32.inc(a))
      w5_lcu_rewrite(rest,Con{P113DAgain{w5_lcu_splice_vals(vals,idx,fvs)},trimmed},idx,pName,ctor,arity,depth)
    case W5LcuNo{}:
      w5_lcu_rewrite(rest,Con{P113DAgain{vals},revAcc},idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite_again(+vals: List<&2,N111Value>, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  +aName = w5_lcu_local_opt(w5_lcu_nth_val(vals,idx))
  w5_lcu_rewrite_again_mc(w5_lcu_ctor_before_again(revAcc,aName),vals,rest,revAcc,idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite_scalar(+s: N111Stmt, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  match s:
    case N111Call{+dest,N111U64{},+sym,+args}:
      nt_choose(List<&2,P113DStmt>,w5_lcu_is_tag_call(pName,sym,args),
        u => w5_lcu_rewrite(rest,Con{P113DScalar{N111Set{dest,N111U64{},N111CtorId{ctor}}},revAcc},idx,pName,ctor,arity,depth),
        u => nt_choose(List<&2,P113DStmt>,w5_lcu_is_take_call(pName,arity,sym,args),
          w =>
            +tbuf = w5_lcu_take_buf(args)
            +nld = w5_lcu_count_loads(rest,tbuf,arity,0)
            +pre : List<&2,P113DStmt> = nt_choose(List<&2,P113DStmt>,U32.is_ge(nld,arity),
              q => revAcc,
              q => w5_lcu_prepend_rev(w5_lcu_field_stores(tbuf,depth,0,arity),revAcc))
            +rev1 : List<&2,P113DStmt> = Con{P113DScalar{N111Set{dest,N111U64{},N111Const{1,0}}},pre}
            w5_lcu_rewrite(w5_lcu_fold_loads(rest,tbuf,arity,depth,[]),rev1,idx,pName,ctor,arity,depth),
          w => nt_choose(List<&2,P113DStmt>,w5_lcu_is_sink_call(pName,sym,args),
            z =>
              +mat = w5_lcu_materialize("w5_lcu_sink_" ++ U32.show(depth),ctor,arity,depth)
              +sinkCall : P113DStmt = P113DScalar{N111Call{dest,N111U64{},"p111_rt_sink",[p111_state(),N111Arg{N111U64{},N111Local{"w5_lcu_sink_" ++ U32.show(depth)}}]}}
              w5_lcu_rewrite(rest,Con{sinkCall,w5_lcu_prepend_rev(mat,revAcc)},idx,pName,ctor,arity,depth),
            z => w5_lcu_rewrite(rest,Con{P113DScalar{s},revAcc},idx,pName,ctor,arity,depth))))
    case _: w5_lcu_rewrite(rest,Con{P113DScalar{s},revAcc},idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite(body,revAcc,idx,pName,ctor,arity,depth):
  match body:
    case Nil{}: nt_reverse(P113DStmt,revAcc,[])
    case Con{P113DScalar{s},rest}: w5_lcu_rewrite_scalar(s,rest,revAcc,idx,pName,ctor,arity,depth)
    case Con{P113DIf{c,yes,no},rest}:
      +ny = w5_lcu_rewrite(yes,[],idx,pName,ctor,arity,depth)
      +nn = w5_lcu_rewrite(no,[],idx,pName,ctor,arity,depth)
      w5_lcu_rewrite(rest,Con{P113DIf{c,ny,nn},revAcc},idx,pName,ctor,arity,depth)
    case Con{P113DAgain{vals},rest}:
      w5_lcu_rewrite_again(vals,rest,revAcc,idx,pName,ctor,arity,depth)
    case Con{P113DResult{+vals},+rest}:
      nt_choose(List<&2,P113DStmt>,w5_lcu_vals_has(pName,vals),
        u =>
          +rName = "w5_lcu_res_" ++ U32.show(depth)
          +mat = w5_lcu_materialize(rName,ctor,arity,depth)
          w5_lcu_rewrite(rest,Con{P113DResult{[N111Local{rName}]},w5_lcu_prepend_rev(mat,revAcc)},idx,pName,ctor,arity,depth),
        u => w5_lcu_rewrite(rest,Con{P113DResult{vals},revAcc},idx,pName,ctor,arity,depth))
    case Con{h,rest}:
      w5_lcu_rewrite(rest,Con{h,revAcc},idx,pName,ctor,arity,depth)

@unsafe
def x185_array_selected_core(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),
        u => x185_array_plain(function,ids,heap),
        u => x185_array_scanned(function,ids,heap,p117h_walk(body,count,
          P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()})))

law w5_lcu_selected:
  for +function: P113DFunction
  for +ids: N111Ids
  for +heap: U32
  for +depth: U32
  X181Output

@unsafe
def w5_lcu_apply(+function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +public: Bool, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +heap: U32, +depth: U32, cand: W5LcuCand) -> X181Output:
  match cand:
    case W5LcuCandNo{}: x185_array_selected_core(function,ids,heap)
    case W5LcuCandYes{+idx,+pName,+ctor,+arity}:
      +wName = "$lcu" ++ U32.show(depth) ++ "." ++ name
      +wSym = p113e_symbol(wName)
      +fbSym = "w5_lcu_fb_" ++ U32.show(depth) ++ "_" ++ nt_fid(name)
      +wParams = w5_lcu_splice_params(params,idx,w5_lcu_field_bindings(depth,0,arity))
      +wBody0 = w5_lcu_rewrite(body,[],idx,pName,ctor,arity,depth)
      +wBody1 = w4g_bwd_dce(w4g_copy_pass(wBody0))
      +workerFn : P113DFunction = P113DFunction{wName,wParams,1,False{},wBody1}
      +bufName = "w5_lcu_in_" ++ U32.show(depth)
      +wrapYes : List<&2,P113DStmt> = nt_append(P113DStmt,[
        P113DScalar{N111Alloca{bufName,U32.mul(arity,8),8}},
        P113DScalar{N111Call{"w5_lcu_ign",N111U64{},"p111_rt_take",[p111_state(),N111Arg{N111U64{},N111Local{pName}},N111Arg{N111Ptr{},N111Local{bufName}},p111_u32(arity)]}}],
        nt_append(P113DStmt,w5_lcu_field_loads(bufName,depth,0,arity),[
          P113DScalar{N111Call{"w5_lcu_out",N111U64{},wSym,Con{p111_state(),w5_lcu_splice_args(params,idx,w5_lcu_field_args(depth,0,arity))}}},
          P113DResult{[N111Local{"w5_lcu_out"}]}]))
      +wrapNo : List<&2,P113DStmt> = [
        P113DScalar{N111Call{"w5_lcu_fb",N111U64{},fbSym,Con{p111_state(),x185_array_arguments(params)}}},
        P113DResult{[N111Local{"w5_lcu_fb"}]}]
      +wrapBody : List<&2,P113DStmt> = [
        P113DScalar{N111Call{"w5_lcu_tag",N111U64{},"p111_rt_tag",[p111_state(),N111Arg{N111U64{},N111Local{pName}}]}},
        P113DScalar{N111Bin{"w5_lcu_ok",N111U64{},"eq",N111Local{"w5_lcu_tag"},N111CtorId{ctor}}},
        P113DIf{N111Local{"w5_lcu_ok"},wrapYes,wrapNo}]
      +wrapFn : P113DFunction = P113DFunction{name,params,1,public,wrapBody}
      x181_program_join(
        x185_array_emit(p113a_function(function,heap),fbSym,[],ids),
        x181_program_join(
          w5_lcu_selected(workerFn,ids,heap,U32.inc(depth)),
          x185_array_emit(wrapFn,p113e_symbol(name),[],ids)))

@unsafe
def w5_lcu_selected(function,ids,heap,depth):
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +nParams = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_lt(depth,2) && U32.is_eq(result,1) && U32.is_le(nParams,12) &&
          U32.is_le(p113i_size(body),1024) && x190_register_loop(body),
        u => w5_lcu_apply(function,name,params,public,body,ids,heap,depth,w5_lcu_find_param(params,0,nParams,body)),
        u => x185_array_selected_core(function,ids,heap))

@unsafe
def x185_array_selected(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  w5_lcu_selected(function,ids,heap,0)"""

    return replace_exact(src, old, new, "Pass 2: w5_lcu_selected")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    src = patch_1_nat_succ_inline(src)
    src = patch_2_loop_carried_unbox(src)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(src)
    print(f"Wrote W5-R4 compiler: {args.dst} ({len(src)} bytes)")


if __name__ == "__main__":
    main()

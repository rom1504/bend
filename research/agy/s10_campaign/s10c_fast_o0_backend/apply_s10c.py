#!/usr/bin/env python3
"""S10-C: Pure-Bend Fast -O0 Backend Patch (`x86-object-fast` & `x86-module-fast`).

Idempotent patch against `selfhost/build/agy/wave15_unified/compiler.bend` (or `k10_wave15/m09.bend`).
Zero edits to `-O2` (`x86-object` / `x86-module` / `x86` / `x86-shard` / `x86-iface`) codegen semantics.

Three pure-Bend -O0 backend pillars:
  1. `s10c_priv_emit_fast`: Fused direct-to-`X187Build` emitter for private `P113DFunction`s
     (handles all 5 `P113DStmt` forms directly onto `X187Build` bytes, eliminating `X188Seq` /
     `X187Parsed` / `w10f_output_fn` / `x187_encode` overhead).
  2. `s10c_plan_fast`: Stub-aware + CPS-pruned + O(1)-bangMap + 1-round-dedup `-O0` lowering
     in `x198pw_plan_fast` (skips upstream `.p130` stubs in `p128br_scan`, `p113pl`, `p126sc`,
     `p113d_passes`, and `x187_priv`, while preserving exact `$direct.*` + `p111_FID_*` ABI).
  3. `s10c_elf_finish_io`: Fast `-O0` ELF finisher with 8x-unrolled byte reverse/fixup span,
     zero redundant `x188_symbol_count` / `x201e_checked_size` scans, and single-pass symbol
     partition + single-hash ELF symtab/strtab emission.
"""
from __future__ import annotations

import argparse
from pathlib import Path

MARKER = "# === S10-C: Fast -O0 Backend ==="

S10C_LAWS = """
# === S10-C: Fast -O0 Backend Forward Laws ===
law s10c_priv_emit_fast:
  for +function: P113DFunction
  for context: P134Context
  for +available: KDef
  for +build: X187Build
  X187Build

law s10c_pub_emit_fast:
  for +segment: N111Segment
  for context: P134Context
  for +available: KDef
  for +build: X187Build
  X187Build

law s10c_plan_fast:
  for plan: P86Plan
  P169Prepared

law s10c_elf_finish_io:
  for +build: X187Build
  for +is_mod: Bool
  for +weak_set: KDef
  IO(U32)
"""

S10C_IMPL = """
# === S10-C: Fast -O0 Backend ===

# --- Pillar 1: Fused Direct-to-X187Build Private Function Emitter (`s10c_priv_emit_fast`) ---

@unsafe
def s10c_b_xorl_eax(+build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217720),
        u => X187Build{1,Con{192,Con{49,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def s10c_b_incoming(params: List<&2,String>, +n: U32, +frame: X181Frame, +build: X187Build) -> X187Build:
  match params:
    case Nil{}: build
    case Con{+name,+rest}:
      +b1 = nt_choose(X187Build,U32.is_lt(n,6),
        u => w13c_store_reg(name,frame,w13c_argreg_num(n),build),
        u => w13c_store_reg(name,frame,0,w13c_b_movq_mr(5,U32.add(16,U32.mul(U32.sub(n,6),8)),0,build)))
      s10c_b_incoming(rest,U32.inc(n),frame,b1)

@unsafe
def s10c_call_vals(vals: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +index: U32, +build: X187Build) -> X187Build:
  match vals:
    case Nil{}: build
    case Con{+val,+rest}:
      nt_choose(X187Build,U32.is_lt(index,6),
        u => s10c_call_vals(rest,ids,frame,U32.inc(index),w13c_load_val(val,ids,frame,w13c_argreg_num(index),build)),
        u =>
          +b1 = w13c_load_val(val,ids,frame,10,build)
          +b2 = w13c_b_movq_rm(10,4,U32.mul(U32.sub(index,6),8),b1)
          s10c_call_vals(rest,ids,frame,U32.inc(index),b2))

@unsafe
def s10c_load_results(names: List<&2,String>, +offset: U32, +frame: X181Frame, +build: X187Build) -> X187Build:
  match names:
    case Nil{}: build
    case Con{+name,+rest}:
      +b1 = w13c_b_movq_mr(11,offset,0,build)
      s10c_load_results(rest,U32.add(offset,8),frame,w13c_store_reg(name,frame,0,b1))

@unsafe
def s10c_store_results(vals: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, +build: X187Build) -> X187Build:
  match vals:
    case Nil{}: build
    case Con{+val,+rest}:
      +b1 = w13c_load_val(val,ids,frame,10,build)
      s10c_store_results(rest,U32.add(offset,8),ids,frame,w13c_b_movq_rm(10,11,offset,b1))

@unsafe
def s10c_tail_moves(params: List<&2,String>, +offset: U32, +frame: X181Frame, +build: X187Build) -> X187Build:
  match params:
    case Nil{}: build
    case Con{+name,+rest}:
      +b1 = w13c_b_movq_mr(11,offset,0,build)
      s10c_tail_moves(rest,U32.add(offset,8),frame,w13c_store_reg(name,frame,0,b1))

law s10c_emit_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +uses_state: Bool
  for +st: W13cSt
  W13cSt

@unsafe
def s10c_emit_if_no(+lbl_end: String, +yt: Bool, st_no: W13cSt) -> W13cSt:
  match st_no:
    case W13cSt{+bn,+lsn,+lrn,+nn,+nt}:
      nt_choose(W13cSt,yt && nt,
        u => W13cSt{bn,lsn,lrn,nn,True{}},
        u => w13c_def_lbl(lbl_end,W13cSt{bn,lsn,lrn,nn,False{}}))

@unsafe
def s10c_emit_if_yes(+lbl_else: String, +lbl_end: String, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, st_yes: W13cSt) -> W13cSt:
  match st_yes:
    case W13cSt{+by,+lsy,+lry,+ny,+yt}:
      +st_mid = w13c_def_lbl(lbl_else,nt_choose(W13cSt,yt,
        u => W13cSt{by,lsy,lry,ny,False{}},
        u => w13c_emit_jmp_lbl(lbl_end,W13cSt{by,lsy,lry,ny,False{}})))
      s10c_emit_if_no(lbl_end,yt,s10c_emit_stmts(no,ids,frame,uses_state,st_mid))

@unsafe
def s10c_emit_if(+cond: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +lbl_else = w13c_lbl(next)
      +lbl_end = w13c_lbl(U32.inc(next))
      +b1 = w13c_load_val(cond,ids,frame,10,build)
      +st1 = w13c_emit_test_jz(lbl_else,W13cSt{b1,lsyms,lrelocs,U32.add(next,2),False{}})
      s10c_emit_if_yes(lbl_else,lbl_end,no,ids,frame,uses_state,s10c_emit_stmts(yes,ids,frame,uses_state,st1))

@unsafe
def s10c_emit_dcall(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>,
    +ids: N111Ids, +frame: X181Frame, +st: W13cSt) -> W13cSt:
  match destinations st:
    case Con{+name,Nil{}} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      +b0 = w13c_load_local("state",frame,7,build)
      +b1 = s10c_call_vals(args,ids,frame,1,b0)
      +b2 = w13c_b_xorl_eax_call(p113e_symbol(target),b1)
      W13cSt{w13c_store_reg(name,frame,0,b2),lsyms,lrelocs,next,term}
    case _ W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      +b0 = w13c_load_local("state",frame,7,build)
      +b1 = w13c_load_local("__x181_results",frame,6,b0)
      +b2 = s10c_call_vals(args,ids,frame,2,b1)
      +b3 = w13c_b_xorl_eax_call(p113e_symbol(target),b2)
      +b4 = w13c_load_local("__x181_results",frame,11,b3)
      W13cSt{s10c_load_results(destinations,0,frame,b4),lsyms,lrelocs,next,term}

@unsafe
def s10c_emit_dresult(+values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match values st:
    case Con{+head,Nil{}} W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +b1 = w13c_load_val(head,ids,frame,0,build)
      W13cSt{w13c_b_epilogue(uses_state,b1),lsyms,lrelocs,next,True{}}
    case _ W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +b0 = w13c_load_local("__x181_result_out",frame,11,build)
      +b1 = s10c_store_results(values,0,ids,frame,b0)
      +b2 = s10c_b_xorl_eax(b1)
      W13cSt{w13c_b_epilogue(uses_state,b2),lsyms,lrelocs,next,True{}}

@unsafe
def s10c_emit_dagain(+values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +b0 = w13c_load_local("__x181_tail",frame,11,build)
      +b1 = s10c_store_results(values,0,ids,frame,b0)
      +b2 = s10c_tail_moves(x181_tail_args(frame),0,frame,b1)
      w13c_emit_jmp_lbl(".L#loop",W13cSt{b2,lsyms,lrelocs,next,True{}})

@unsafe
def s10c_emit_scalar(stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match stmt st:
    case N111Call{+name,+typ,+sym,+args} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,agy_str_eq(sym,"p111_rt_ctor"),
        u => w13c_emit_call_ctor0(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term),u =>
      nt_choose(W13cSt,w13c_call_is_special(sym),
        u => w13c_apply_code(agy_rt_inline_try(name,typ,sym,args,ids,frame,X181Code{[],next,term,""}),W13cSt{build,lsyms,lrelocs,next,term}),
        u => w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term)))
    case N111If{cond,yes,no} W13cSt{build,lsyms,lrelocs,next,term}:
      s10c_emit_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),ids,frame,uses_state,W13cSt{build,lsyms,lrelocs,next,term})
    case other W13cSt{build,lsyms,lrelocs,next,term}:
      w13c_emit_scalar(other,ids,frame,uses_state,W13cSt{build,lsyms,lrelocs,next,term})

@unsafe
def s10c_emit_one(head: P113DStmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match head:
    case P113DScalar{scalar}: s10c_emit_scalar(scalar,ids,frame,uses_state,st)
    case P113DIf{cond,yes,no}: s10c_emit_if(cond,yes,no,ids,frame,uses_state,st)
    case P113DCall{dests,target,args}: s10c_emit_dcall(dests,target,args,ids,frame,st)
    case P113DResult{values}: s10c_emit_dresult(values,ids,frame,uses_state,st)
    case P113DAgain{values}: s10c_emit_dagain(values,ids,frame,st)

@unsafe
def s10c_emit_stmts(body, ids, frame, uses_state, st):
  match body st:
    case Nil{} _: st
    case Con{head,rest} W13cSt{X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,SNil{}},lsyms,lrelocs,next,False{}}:
      s10c_emit_stmts(rest,ids,frame,uses_state,s10c_emit_one(head,ids,frame,uses_state,
        W13cSt{X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,""},lsyms,lrelocs,next,False{}}))
    case Con{_,_} W13cSt{X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,SNil{}},lsyms,lrelocs,next,True{}}:
      W13cSt{x187_build_error("x86 statement after terminal",X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,""}),lsyms,lrelocs,next,True{}}
    case Con{_,_} _: st

@unsafe
def s10c_priv_emit_framed(+sym: String, +rest_params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +uses_state: Bool, +build: X187Build, +frame: X181Frame) -> X187Build:
  match frame:
    case X181Frame{_,+bytes,+calls,_,_}:
      +frame_sz = U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48)
      +b0 = w13c_b_prologue(sym,frame_sz,uses_state,build)
      +b1 = s10c_b_incoming(rest_params,1,frame,b0)
      +st0 = w13c_def_lbl(".L#loop",W13cSt{b1,missing(),[],0,False{}})
      w13c_pub_emit_done(sym,s10c_emit_stmts(body,ids,frame,uses_state,st0))

@unsafe
def s10c_priv_emit_body(+sym: String, +names: List<&2,String>, +rest_params: List<&2,String>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, +build: X187Build) -> X187Build:
  +uses_state = w4_body_uses_state(body)
  +stateKind = nt_choose(String,uses_state,u => "X181Register",u => "X181UnusedState")
  +savedMask = nt_choose(U32,uses_state,u => 1,u => 0)
  +s0 = p111v_put(p111v_put(missing(),"state",stateKind,0,8),"__x181_saved_mask","X186SavedMask",savedMask,0)
  +init : X181Frame = X181Frame{s0,40,0,names,sym}
  +homes = x181_frame_names(rest_params,init)
  +f1 = x181_frame_buffer("scratch",2048,16,homes)
  +f2 = x181_frame_buffer("__x181_results",64,16,f1)
  +tbytes = U32.mul(nt_count(String,names),8)
  +f3 = x181_frame_buffer("__x181_tail",tbytes,8,f2)
  s10c_priv_emit_framed(sym,rest_params,body,ids,uses_state,build,x181_frame_stmts(body,f3))

@unsafe
def s10c_priv_emit_late(+sym: String, +names: List<&2,String>, +rest_params: List<&2,String>,
    +ids: N111Ids, +build: X187Build, late: P113ABody) -> X187Build:
  match late:
    case P113ABody{ready,_}: s10c_priv_emit_body(sym,names,rest_params,ready,ids,build)

@unsafe
def s10c_priv_emit_go(+function: P113DFunction, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match function context:
    case P113DFunction{+name,+params,+result,public,+body} P134Context{+ids,index,direct,+ready,view,lookups,heap,mode}:
      +pnames = x181_param_names(params)
      +rest_params : List<&2,String> = nt_choose(List<&2,String>,U32.is_eq(result,1),u => pnames,u => Con{"__x181_result_out",pnames})
      +names : List<&2,String> = Con{"state",rest_params}
      +error = p111_first(x181_program_stmts(body,available),p111_first(x181_hygiene_names(pnames),x181_hygiene_stmts(body)))
      nt_choose(X187Build,String.is_empty(error),
        u =>
          +sym = p113e_symbol(name)
          +b_fn = s10c_priv_emit_body(sym,names,rest_params,body,ids,build)
          nt_choose(X187Build,x181_forward_selected(name,ready),
            w => w10f_output_fn(x181_forward(function,ready),b_fn),
            w => b_fn),
        u => x187_build_error(error,build))

@unsafe
def s10c_priv_emit_fast(function, context, available, build):
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => s10c_priv_emit_go(function,context,available,build),
    u => build)

@unsafe
def s10c_pub_emit_framed(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +uses_state: Bool, +build: X187Build, +frame: X181Frame) -> X187Build:
  match frame:
    case X181Frame{_,+bytes,+calls,_,_}:
      +frame_sz = U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48)
      +b0 = w13c_b_prologue(sym,frame_sz,uses_state,build)
      w13c_pub_emit_done(sym,s10c_emit_stmts(body,ids,frame,uses_state,W13cSt{b0,missing(),[],0,False{}}))

@unsafe
def s10c_pub_emit_body(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +build: X187Build) -> X187Build:
  +uses_state = w4_body_uses_state(body)
  +stateKind = nt_choose(String,uses_state,u => "X181Register",u => "X181UnusedState")
  +savedMask = nt_choose(U32,uses_state,u => 1,u => 0)
  +s0 = p111v_put(p111v_put(missing(),"state",stateKind,0,8),"__x181_saved_mask","X186SavedMask",savedMask,0)
  +init : X181Frame = X181Frame{s0,40,0,["state"],""}
  +f1 = x181_frame_buffer("scratch",2048,16,init)
  +f2 = x181_frame_buffer("__x181_results",64,16,f1)
  +f3 = x181_frame_buffer("__x181_tail",8,8,f2)
  s10c_pub_emit_framed(sym,body,ids,uses_state,build,x181_frame_stmts(body,f3))

@unsafe
def s10c_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)
      nt_choose(X187Build,String.is_empty(error),
        v =>
          +sym = p111q_symbol(name)
          nt_choose(X187Build,x202k_shape(body),
            w => w13c_emit_x202k(sym,build),
            w => s10c_pub_emit_body(sym,x181_scalar_rows(body),ids,build)),
        v => x187_build_error(error,build))

@unsafe
def s10c_pub_emit_fast(segment, context, available, build):
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => s10c_pub_emit_seg(segment,context,available,build),
    u => build)


# --- Pillar 2: Stub-Aware + CPS-Pruned + O(1)-BangMap `-O0` Lowering (`s10c_plan_fast`) ---

type S10cSplit is Data:
  S10cSplit{+ready: KDef, +cps: KDef, +active: List<&2,String>}

@unsafe
def s10c_drop_stubs(+book: List<&2,KDef>, names: List<&2,String>, +acc: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,U32.is_eq(w10_if_stub_kind(book,name),0),
        u => s10c_drop_stubs(book,rest,Con{name,acc}),
        u => s10c_drop_stubs(book,rest,acc))

@unsafe
def s10c_stub_sig(+pub: String, +arity: U32) -> KDef:
  KDef{pub,"P113Direct",arity,1,atom("Absent"),kt("P113Public","",1,0,[]),[],False{},False{}}

@unsafe
def s10c_split_stubs(+book: List<&2,KDef>, names: List<&2,String>, +ready: KDef, +cps: KDef, +active: List<&2,String>) -> S10cSplit:
  match names:
    case Nil{}: S10cSplit{ready,cps,nt_reverse(String,active,[])}
    case Con{+name,+rest}:
      +sk = w10_if_stub_kind(book,name)
      nt_choose(S10cSplit,U32.is_ge(sk,1000),
        u => s10c_split_stubs(book,rest,p113e_insert(ready,s10c_stub_sig(p113d_public(book,name),U32.sub(sk,1000))),cps,active),
        u => nt_choose(S10cSplit,U32.is_eq(sk,2),
          v => s10c_split_stubs(book,rest,ready,p111v_put(cps,name,"W7Rem",1,0),active),
          v => s10c_split_stubs(book,rest,ready,cps,Con{name,active})))

@unsafe
def s10c_p164a_allowed_fast(+book: List<&2,KDef>, +source: String, +bangMap: KDef, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  +isBang = Bool.not(agy_str_eq(dk(w5c3_find(bangMap,source,index_hash(source,2166136261))),"Absent"))
  agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || isBang) &&
    U32.is_le(arity,64) && agy_str_eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),1)

@unsafe
def s10c_p167l_cat_name(+book: List<&2,KDef>, +name: String, +bangMap: KDef, +ready: KDef, +catalogue: P167Catalogue) -> P167Catalogue:
  +arity = nd_arity(book,name)
  +allowed = s10c_p164a_allowed_fast(book,name,bangMap,ready)
  +worker = p167l_catalogue_put(p113d_public(book,name),name,"P167Worker",arity,allowed,catalogue)
  nt_choose(P167Catalogue,U32.is_eq(arity,0),u => worker,
    u => p167l_catalogue_put(nc_ref_name(book,name),name,"P167Factory",arity,allowed,worker))

@unsafe
def s10c_p167l_catalogue(+book: List<&2,KDef>, names: List<&2,String>, +bangMap: KDef, +ready: KDef, catalogue: P167Catalogue) -> P167Catalogue:
  match names:
    case Nil{}: catalogue
    case Con{+name,rest}:
      s10c_p167l_catalogue(book,rest,bangMap,ready,s10c_p167l_cat_name(book,name,bangMap,ready,catalogue))

@unsafe
def s10c_p167l_finish_fast(+source: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, built: P167Built) -> P167Lowered:
  match built:
    case P167Built{+segments,present,adapters,fresh,families,factories,wrappers,demands,+error}:
      +ordered = nt_reverse(N111Segment,segments,[])
      +pruned = nt_choose(List<&2,N111Segment>,String.is_empty(error),
        u => w6_dedup_round(ordered,2),
        u => ordered)
      p167l_finished(nodes,functions,adapters,
        [nt_count(String,names),nt_count(P113DFunction,functions),families,factories,wrappers,nt_count(N111Segment,pruned),demands],
        p140or_finish(source,names,constructors,P111Book{pruned,fresh,error}))

@unsafe
def s10c_p167l_catalogued_fast(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +functions: List<&2,P113DFunction>, catalogue: P167Catalogue) -> P167Lowered:
  match catalogue:
    case P167Catalogue{index,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => s10c_p167l_finish_fast(source,names,constructors,nodes,functions,
          p167l_loop(P167Context{book,index,bangs},
            p167l_demand(nc_ref_name(book,"main"),p167l_function_demands(functions,P167Demand{[],missing(),0})),
            P167Built{[],missing(),missing(),0,0,0,0,0,""})),
        u => p167l_fail(error))

@unsafe
def s10c_p168_selected_split(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, split: S10cSplit) -> P167Lowered:
  match split:
    case S10cSplit{+ready_stubs,+cps,+active}:
      +pruned = w14a_prune_active(book,active,bangs,cps)
      +raw = w13d_p113pl_candidates_fast(book,pruned,bangs)
      +fns0 = p113d_passes(p126sc_candidates(raw),ready_stubs,nt_reverse(P113DFunction,workers,[]),32)
      +all_ready = p113e_signatures(fns0,ready_stubs)
      +bangMap = w8_bangs_index(bangs,missing())
      s10c_p167l_catalogued_fast(source,book,names,constructors,nodes,bangs,p167l_private(fns0),
        s10c_p167l_catalogue(book,names,bangMap,all_ready,P167Catalogue{missing(),""}))

@unsafe
def s10c_p168_seed_verified_fast(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u =>
      +ready0 = p113e_signatures(workers,missing())
      +rem = p167ob_remaining(book,names,bangs,ready0)
      s10c_p168_selected_split(source,book,names,constructors,nodes,bangs,workers,
        s10c_split_stubs(book,rem,ready0,w14d_cps_seed(),[])),
    u => p167l_fail("early scalar observer verification: " ++ error))

@unsafe
def s10c_p168_scanned_fast(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => s10c_p168_seed_verified_fast(source,book,names,constructors,nodes,bangs,workers,
          p167ob_seed_verify(constructors,workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))

@unsafe
def s10c_p168_prepared_fast(source: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => s10c_p168_scanned_fast(source,book,names,constructors,nodes,bangs,
          p128br_scan(book,s10c_drop_stubs(book,no_candidate_names(book,names,bangs),[]),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def s10c_p168_fast(+request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v =>
            +ctors = nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))
            s10c_p168_prepared_fast(source,names,ctors,p112s_prepare(book,names,ctors)),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error))

@unsafe
def s10c_p169np_admitted_fast(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => w13d_p169s_lowered_fast(s10c_p168_fast(request)),
    u => p169s_fail("compile: " ++ error))

@unsafe
def s10c_plan_fast(plan):
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      s10c_p169np_admitted_fast(request,p111_runtime_admission(request))


# --- Pillar 3: Fast 8x-Unrolled + Single-Pass Symbol ELF Finisher (`s10c_elf_finish_io`) ---

@unsafe
def s10c_rev_u32(xs: List<&2,U32>, acc: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Con{a,Con{b,Con{c,Con{d,Con{e,Con{f,Con{g,Con{h,rest}}}}}}}}:
      s10c_rev_u32(rest,Con{h,Con{g,Con{f,Con{e,Con{d,Con{c,Con{b,Con{a,acc}}}}}}}})
    case Con{a,Con{b,Con{c,Con{d,rest}}}}:
      s10c_rev_u32(rest,Con{d,Con{c,Con{b,Con{a,acc}}}})
    case Con{a,rest}:
      s10c_rev_u32(rest,Con{a,acc})
    case Nil{}: acc

law s10c_x201f_apply:
  for +raw: List<&2,U32>
  for +patches: List<&2,X187Relocation>
  for end: U32
  for +acc: List<&2,U32>
  X187Encoded

law s10c_x201f_span:
  for +count: U32
  for +raw: List<&2,U32>
  for +patches: List<&2,X187Relocation>
  for +offset: U32
  for +word: U32
  for +acc: List<&2,U32>
  X187Encoded

@unsafe
def s10c_x201f_span8(+count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match raw:
    case Con{a,Con{b,Con{c,Con{d,Con{e,Con{f,Con{g,Con{h,rest}}}}}}}}:
      s10c_x201f_span(U32.sub(count,8),rest,patches,offset,word,
        Con{h,Con{g,Con{f,Con{e,Con{d,Con{c,Con{b,Con{a,acc}}}}}}}})
    case _: X187Encoded{[],[],"local branch fixup outside text"}

@unsafe
def s10c_x201f_span_small(count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match count raw:
    case 0 Con{0,Con{0,Con{0,Con{0,rest}}}}:
      s10c_x201f_apply(rest,patches,offset,
        Con{U32.and(word,255),
        Con{U32.and(U32.shrn(word,8n),255),
        Con{U32.and(U32.shrn(word,16n),255),
        Con{U32.shrn(word,24n),acc}}}})
    case 0 _: X187Encoded{[],[],"invalid local branch placeholder"}
    case _ Nil{}: X187Encoded{[],[],"local branch fixup outside text"}
    case _ Con{head,rest}: s10c_x201f_span(U32.sub(count,1),rest,patches,offset,word,Con{head,acc})

@unsafe
def s10c_x201f_span(count, raw, patches, offset, word, acc):
  nt_choose(X187Encoded,U32.is_ge(count,8),
    u => s10c_x201f_span8(count,raw,patches,offset,word,acc),
    u => s10c_x201f_span_small(count,raw,patches,offset,word,acc))

@unsafe
def s10c_x201f_apply(raw, patches, end, acc):
  match patches:
    case Nil{}: X187Encoded{s10c_rev_u32(raw,acc),[],""}
    case Con{X187Relocation{s,+offset,k,n,word,hi},rest}:
      s10c_x201f_span(U32.sub(U32.sub(end,offset),4),raw,rest,offset,word,acc)

@unsafe
def s10c_x201f_selected(+raw: List<&2,U32>, patches: List<&2,X187Relocation>, +size: U32,
    +plan: List<&2,X187Relocation>) -> X187Encoded:
  match plan:
    case Nil{}: x188_fixup_bytes(s10c_rev_u32(raw,[]),patches,0,[])
    case Con{_,_}: s10c_x201f_apply(raw,plan,size,[])

type S10cSymParts is Data:
  S10cSymParts{+locals: List<&2,X187Symbol>, +globals: List<&2,X187Symbol>, +error: String}

law s10c_part_syms:
  for names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +is_mod: Bool
  for +locs: List<&2,X187Symbol>
  for +globs: List<&2,X187Symbol>
  S10cSymParts

@unsafe
def s10c_part_sym_one(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +is_mod: Bool, +locs: List<&2,X187Symbol>, +globs: List<&2,X187Symbol>, +symbol: KDef) -> S10cSymParts:
  match symbol:
    case KDef{n,k,+section,+value,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(S10cSymParts,Bool.not(defined) && String.starts_with(name,".L"),
        u => S10cSymParts{[],[],"undefined local label: " ++ name},
        u =>
          +sym_global : Bool = nt_choose(Bool,is_mod && defined && w10_is_mod_local_sym(name),
            v => False{},
            v => global || Bool.not(defined))
          nt_choose(S10cSymParts,w7c_elf_sym_nums_valid(section,value,size,sym_global,kind,sizes),
            v => nt_choose(S10cSymParts,sym_global,
              w => s10c_part_syms(rest,index,escaped,sizes,is_mod,locs,Con{X187Symbol{name,section,value,size,True{},kind},globs}),
              w => nt_choose(S10cSymParts,String.starts_with(name,".L") && agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),
                z => s10c_part_syms(rest,index,escaped,sizes,is_mod,locs,globs),
                z => s10c_part_syms(rest,index,escaped,sizes,is_mod,Con{X187Symbol{name,section,value,size,False{},kind},locs},globs))),
            v => S10cSymParts{[],[],"invalid or duplicate ELF symbol"}))
    case _: S10cSymParts{[],[],"invalid final object symbol"}

@unsafe
def s10c_part_syms(names, index, escaped, sizes, is_mod, locs, globs):
  match names:
    case Nil{}: S10cSymParts{locs,globs,""}
    case Con{+name,rest}:
      s10c_part_sym_one(name,rest,index,escaped,sizes,is_mod,locs,globs,p111v_get(index,name))

@unsafe
def s10c_elf_sym_add_h(+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32,
    +is_mod: Bool, +weak_set: KDef, +index: KDef, +count: U32, +firstGlobal: U32, +table: List<&2,U32>,
    +strings: List<&2,U32>, +stringSize: U32, +error: String, asc: W7cAscii) -> X187ElfSymbols:
  match asc:
    case W7cAscii{ok,+strBytes,+nlen}:
      +length = U32.inc(nlen)
      +h = index_hash(name,2166136261)
      +bind : U32 = nt_choose(U32,global,
        u => nt_choose(U32,is_mod && Bool.not(U32.is_eq(section,0)) && w10_is_weak_sym(weak_set,name),
          v => 32,
          v => 16),
        u => 0)
      nt_choose(X187ElfSymbols,ok && String.is_empty(error) &&
          agy_str_eq(dk(w5c3_find(index,name,h)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p131i_insert(index,KDef{name,"X187Symbol",count,0,atom("Absent"),atom("Absent"),[],False{},False{}},h),
          U32.inc(count),firstGlobal,
          w7c_elf_sym_push(stringSize,U32.add(kind,bind),section,value,size,table),
          Con{0,strBytes},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})

@unsafe
def s10c_elf_emit_syms(items: List<&2,X187Symbol>, +is_mod: Bool, +weak_set: KDef, +state: X187ElfSymbols) -> X187ElfSymbols:
  match items:
    case Nil{}: state
    case Con{X187Symbol{+name,+section,+value,+size,+global,+kind},rest}:
      match state:
        case X187ElfSymbols{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}:
          s10c_elf_emit_syms(rest,is_mod,weak_set,
            s10c_elf_sym_add_h(name,section,value,size,global,kind,is_mod,weak_set,
              index,count,firstGlobal,table,strings,stringSize,error,
              w7c_elf_ascii_valid(name,strings,0)))

@unsafe
def s10c_elf_emit_globals(items: List<&2,X187Symbol>, +is_mod: Bool, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match state:
    case X187ElfSymbols{index,+count,firstGlobal,table,strings,stringSize,error}:
      s10c_elf_emit_syms(items,is_mod,weak_set,X187ElfSymbols{index,count,count,table,strings,stringSize,error})

@unsafe
def s10c_x202p_elf_emit(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> IO(U32):
  match rr:
    case W7cRelocBad{}: IO.die(U32,1,"invalid ELF relocation")
    case W7cRelocOk{W7RelocParts{r1,+n1,r2,+n2,r3,+n3}}:
      +sectionNames = s10c_rev_u32(x187_elf_ascii(
          "\0.text\0.rodata\0.data\0.rela.text\0.rela.rodata\0.rela.data\0.symtab\0.strtab\0.shstrtab\0.note.GNU-stack\0",[]),[])
      x202t_plan([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,s10c_rev_u32(r1,[])},
        X187ElfSection{32,4,0,8,24,7,2,s10c_rev_u32(r2,[])},
        X187ElfSection{45,4,0,8,24,7,3,s10c_rev_u32(r3,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,s10c_rev_u32(table,[])},
        X187ElfSection{64,3,0,1,0,0,0,s10c_rev_u32(strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,sectionNames},
        X187ElfSection{82,1,0,1,0,0,0,[]}],
        x202t_sizes(X187ElfSizes{ts,rs,ds},X187ElfSizes{n1,n2,n3},count,stringSize,98),64,[],x187_elf_zero(64,[]))

@unsafe
def s10c_elf_finish_syms_go(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    relocations: List<&2,X187Relocation>, +sizes: X187ElfSizes, +ts: U32, +rs: U32, +ds: U32,
    syms1: X187ElfSymbols) -> IO(U32):
  match syms1:
    case X187ElfSymbols{+sidx,+count,+firstGlobal,table,strings,+stringSize,+serr}:
      nt_choose(IO(U32),String.is_empty(serr),
        v => s10c_x202p_elf_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,sidx,0,[],0,[],0,[],0)),
        v => IO.die(U32,1,serr))

@unsafe
def s10c_elf_finish_syms(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    relocations: List<&2,X187Relocation>, +sizes: X187ElfSizes, +is_mod: Bool, +weak_set: KDef,
    parts: S10cSymParts) -> IO(U32):
  match sizes parts:
    case X187ElfSizes{+ts,+rs,+ds} S10cSymParts{locs,globs,+err}:
      nt_choose(IO(U32),String.is_empty(err),
        u =>
          +syms0 = s10c_elf_emit_syms(locs,is_mod,weak_set,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})
          +syms1 = s10c_elf_emit_globals(globs,is_mod,weak_set,syms0)
          s10c_elf_finish_syms_go(text,rodata,data,relocations,sizes,ts,rs,ds,syms1),
        u => IO.die(U32,1,err))

@unsafe
def s10c_elf_finish_patched(names: List<&2,String>, index: KDef, escaped: KDef, +sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>,
    patched: X187Encoded, +is_mod: Bool, +weak_set: KDef) -> IO(U32):
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10c_elf_finish_syms(bytes,rodata,data,relocations,sizes,is_mod,weak_set,
          s10c_part_syms(names,index,escaped,sizes,is_mod,[],[])),
        u => IO.die(U32,1,error))

@unsafe
def s10c_elf_finish_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +is_mod: Bool, +weak_set: KDef) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10c_elf_finish_patched(names,index,escaped,sizes,rodata,data,relocations,
          s10c_x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),is_mod,weak_set),
        u => IO.die(U32,1,error))

@unsafe
def s10c_elf_finish_io(build, is_mod, weak_set):
  match build:
    case X187Build{s,t,r,d,+ts,+rs,+ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(ts,67108864) && U32.is_le(rs,67108864) && U32.is_le(ds,67108864),
          v => s10c_elf_finish_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,s10c_rev_u32(r,[]),s10c_rev_u32(d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),is_mod,weak_set),
          v => IO.die(U32,1,"invalid or oversized ELF section bytes")),
        u => IO.die(U32,1,error))
"""

REPLACEMENTS = [
    # 1. Forward laws before x187_cursor_fast_good
    (
        "@unsafe\ndef x187_cursor_fast_good(",
        S10C_LAWS + "\n@unsafe\ndef x187_cursor_fast_good(",
    ),
    # 2. x187_cursor_fast_good private emit
    (
        "      x187_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build))",
        "      x187_cursor_fast(P134Private{rest,context,next},available,s10c_priv_emit_fast(head,context,available,build))",
    ),
    # 3. x198pw_plan_fast -> s10c_plan_fast
    (
        """@unsafe
def x198pw_plan_fast(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      w13d_p169np_admitted_fast(request,p111_runtime_admission(request))""",
        """@unsafe
def x198pw_plan_fast(plan: P86Plan) -> P169Prepared:
  s10c_plan_fast(plan)""",
    ),
    # 4. w10_module_cursor_fast_good private emit
    (
        "      w10_module_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast(P134Private{rest,context,next},available,s10c_priv_emit_fast(head,context,available,build),weak_set)",
    ),
    # 4b. -O0 w13c_pub_emit_fast -> s10c_pub_emit_fast (skips x185_late_stmts + 152B sink/keep bloat)
    (
        """@unsafe
def w13c_pub_emit_fast(segment, context, available, build):
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => w13c_pub_emit_seg(segment,context,available,build),
    u => build)""",
        """@unsafe
def w13c_pub_emit_fast(segment, context, available, build):
  s10c_pub_emit_fast(segment,context,available,build)""",
    ),
    # 5. w10_module_cursor_fast_io_good private emit & ELF finish
    (
        "      w10_module_cursor_fast_io(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast_io(P134Private{rest,context,next},available,s10c_priv_emit_fast(head,context,available,build),weak_set)",
    ),
    (
        """      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)""",
        """      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: s10c_elf_finish_io(build,True{},weak_set)""",
    ),
    # 6. Insert S10-C implementation right before Wave 8 trace section
    (
        "# Wave 8: Pure-Bend live build tracing & stage profiler (`--trace`).",
        S10C_IMPL + "\n# Wave 8: Pure-Bend live build tracing & stage profiler (`--trace`).",
    ),
    # 7. w8_tr_emit_priv fast path -> s10c_priv_emit_fast (keeps -O2 untouched)
    (
        """    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = w10f_output_fn(out,build)""",
        """    +b2 : X187Build = nt_choose(X187Build,fast,
      u => s10c_priv_emit_fast(head,ctx,avail,build),
      u => w10f_output_fn(x181_program_private(head,ctx,avail),build))""",
    ),
    # 8. w8_tr_emit_good ELF finish when fast == True (keeps -O2 untouched)
    (
        """        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => w10_x202p_x201f_finish(build,weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(),build)))""",
        """        +rc : U32 <- nt_choose(IO(U32),fast,
          u => nt_choose(IO(U32),is_mod,
            v => s10c_elf_finish_io(build,True{},weak_set),
            v => s10c_elf_finish_io(x187_build_seq(x181_program_main(),build),False{},missing())),
          u => nt_choose(IO(U32),is_mod,
            v => w10_x202p_x201f_finish(build,weak_set),
            v => x202p_x201f_finish(x187_build_seq(x181_program_main(),build))))""",
    ),
    # 9. ts_emit_priv fast path -> s10c_priv_emit_fast (keeps -O2 untouched)
    (
        """    +out : X181Output <- IO.pure(X181Output, nt_choose(X181Output, fast,
      u => x181_program_private_fast(head, ctx, avail),
      u => x181_program_private(head, ctx, avail)))
    +b2 : X187Build <- IO.pure(X187Build, w10f_output_fn(out, build))""",
        """    +b2 : X187Build <- IO.pure(X187Build, nt_choose(X187Build, fast,
      u => s10c_priv_emit_fast(head, ctx, avail, build),
      u => w10f_output_fn(x181_program_private(head, ctx, avail), build)))""",
    ),
    # 10. ts_emit_good ELF finish when fast == True (keeps -O2 untouched)
    (
        """        +rc : U32 <- nt_choose(IO(U32), is_mod,
          u => w10_x202p_x201f_finish(build, weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(), build)))""",
        """        +rc : U32 <- nt_choose(IO(U32), fast,
          u => nt_choose(IO(U32), is_mod,
            v => s10c_elf_finish_io(build, True{}, weak_set),
            v => s10c_elf_finish_io(x187_build_seq(x181_program_main(), build), False{}, missing())),
          u => nt_choose(IO(U32), is_mod,
            v => w10_x202p_x201f_finish(build, weak_set),
            v => x202p_x201f_finish(x187_build_seq(x181_program_main(), build))))""",
    ),
]


def patch_text(src: str) -> tuple[str, bool]:
    if MARKER in src:
        return src, False
    out = src
    for idx, (old, new) in enumerate(REPLACEMENTS, 1):
        count = out.count(old)
        if count != 1:
            raise RuntimeError(f"S10-C patch hunk #{idx} matched {count} times (expected 1): {old[:80]!r}")
        out = out.replace(old, new, 1)
    return out, True


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-C fast -O0 backend patch.")
    ap.add_argument("input", type=Path, help="Input compiler.bend or m09.bend")
    ap.add_argument("-o", "--output", type=Path, default=None, help="Output file (defaults to overwriting input)")
    args = ap.parse_args()
    src = args.input.read_text(encoding="utf-8")
    patched, changed = patch_text(src)
    dst = args.output or args.input
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(patched, encoding="utf-8")
    status = "APPLIED" if changed else "ALREADY_APPLIED"
    print(f"[S10-C] {status}: {args.input} -> {dst} ({len(patched):,} bytes)")


if __name__ == "__main__":
    main()

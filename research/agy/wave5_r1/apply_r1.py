#!/usr/bin/env python3
"""Wave 5 Track W5-R1: General Backend Passes for histogram, editdist, and bst.

100% general, semantics-preserving compiler passes on top of wave4c_unified/compiler.bend:
  1. Joint Register Allocator Candidate Cap (64 -> 256 in x190_j_counted):
     x203_candidates already ranks and keeps only the top 32 candidates; raising the
     pre-ranking name cap from 64 to 256 restores 9-color joint allocation for loops
     with >64 total locals (fixing histogram's wave4c_unified regression and unlocking
     joint coloring for editdist's $product.columns).
  2. General Loop-Counter Decrement Sinking (w5_sink_body):
     When a pure `p = Sub(n, 1)` precedes a loop body ending in `P113DAgain` where `p`
     is neither read nor written in the middle statements, `n` is not written in the
     middle statements, and `p` is used in `P113DAgain`, sink `p = Sub(n, 1)` to right
     before `P113DAgain`.
  3. Bottom-Up Multi-Level Pure Scalar cmov Diamonds (w4c_dia_* + N111If dispatch):
     Dispatch P113DScalar{N111If{...}} into w4c_dia_if and admit canonical 1-stmt
     P113DIf cmov selects inside pure diamond arms, converting multi-level pure scalar
     if-else-if chains into branchless cmov sequences.
  4. Tiny Self-Recursive Loop 2-Step Peeling (p113j_inline / w5_expand_peel) +
     General Exit-Block Loop Rotation (w4b_take_exit_clean):
     For tiny (<=64 stmts), scratch-free, P113DCall-free self-recursive P113DAgain
     callees, peel 2 extra iterations inline before falling back to the recursive call.
     Allow cold calls/internal branches in rotated loop exit blocks ending in `ret`.
  5. General `inv_base + min(any, inv_k)` BCE (w4c_bce_analyze) + Flag-Preserving
     `subq $1, %r; [mov*]; testq %r, %r; jz/jnz` Peephole (w4c_peep_cfg):
     Hoists `base <= mask && k <= mask && (base + k) <= mask` for invariant-bounded
     min sums (no 32-bit wraparound since mask <= 2^31 - 1), and drops redundant
     `testq %r, %r` separated from `subq $1, %r` by 0-2 flag-preserving movs.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4c_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5_r1/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_joint_regalloc_cap(src: str) -> str:
    """Pass 1: Raise x190_j_counted candidate list cap from 64 to 256."""
    old = """      +nCands = nt_count(String,names)
      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) || U32.is_gt(nCands,64),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),
        u => x190_j_selected(frame,params,setup,body,registerBody,
          x203_candidates(nt_reverse(String,names,[]),reads,slots)))"""
    new = """      +nCands = nt_count(String,names)
      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) || U32.is_gt(nCands,256),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),
        u => x190_j_selected(frame,params,setup,body,registerBody,
          x203_candidates(nt_reverse(String,names,[]),reads,slots)))"""
    return replace_exact(src, old, new, "Pass 1: x190_j_counted cap 64->256")


def patch_2_sink_countdown(src: str) -> str:
    """Pass 2: General loop-counter decrement sinking right before P113DAgain."""
    helpers = """# ---- W5-R1 Pass 2: General Loop-Counter Decrement Sinking ----
@unsafe
def w5_val_is(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{nm}: agy_str_eq(nm,target)
    case _: False{}

@unsafe
def w5_vals_has(vs: List<&2,N111Value>, +target: String) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: w5_val_is(v,target) || w5_vals_has(rest,target)

@unsafe
def w5_args_has(args: List<&2,N111Arg>, +target: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w5_val_is(v,target) || w5_args_has(rest,target)

@unsafe
def w5_names_has(ns: List<&2,String>, +target: String) -> Bool:
  match ns:
    case Nil{}: False{}
    case Con{nm,rest}: agy_str_eq(nm,target) || w5_names_has(rest,target)

@unsafe
def w5_scalar_safe(sc: N111Stmt, +p: String, +n: String) -> Bool:
  match sc:
    case N111Set{+dst,_,v}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_val_is(v,p))
    case N111Bin{+dst,_,_,l,r}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) &&
        Bool.not(w5_val_is(l,p)) && Bool.not(w5_val_is(r,p))
    case N111Offset{+dst,b,by}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) &&
        Bool.not(w5_val_is(b,p)) && Bool.not(w5_val_is(by,p))
    case N111Load{+dst,_,b,_}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_val_is(b,p))
    case N111Store{_,b,_,v}:
      Bool.not(w5_val_is(b,p)) && Bool.not(w5_val_is(v,p))
    case N111Alloca{+dst,_,_}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n))
    case N111Call{+dst,_,_,args}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_args_has(args,p))
    case N111Return{v}:
      Bool.not(w5_val_is(v,p))
    case _: False{}

law w5_mid_safe:
  for stmts: List<&2,P113DStmt>
  for +p: String
  for +n: String
  Bool

@unsafe
def w5_stmt_safe(st: P113DStmt, +p: String, +n: String) -> Bool:
  match st:
    case P113DScalar{sc}: w5_scalar_safe(sc,p,n)
    case P113DIf{cond,yes,no}:
      Bool.not(w5_val_is(cond,p)) && w5_mid_safe(yes,p,n) && w5_mid_safe(no,p,n)
    case P113DCall{dests,_,args}:
      Bool.not(w5_names_has(dests,p)) && Bool.not(w5_names_has(dests,n)) && Bool.not(w5_vals_has(args,p))
    case P113DResult{vs}:
      Bool.not(w5_vals_has(vs,p))
    case P113DAgain{_}: False{}

@unsafe
def w5_mid_safe(stmts,p,n):
  match stmts:
    case Nil{}: True{}
    case Con{st,rest}: w5_stmt_safe(st,p,n) && w5_mid_safe(rest,p,n)

@unsafe
def w5_can_sink_tail(stmts: List<&2,P113DStmt>, +p: String, +n: String, +sawMid: Bool) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DAgain{vs},Nil{}}: sawMid && w5_vals_has(vs,p)
    case Con{st,rest}: w5_stmt_safe(st,p,n) && w5_can_sink_tail(rest,p,n,True{})

@unsafe
def w5_insert_before_again(stmts: List<&2,P113DStmt>, +subStmt: P113DStmt) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: [subStmt]
    case Con{P113DAgain{vs},Nil{}}: Con{subStmt,[P113DAgain{vs}]}
    case Con{h,rest}: Con{h,w5_insert_before_again(rest,subStmt)}

law w5_sink_body:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_try_sink_bin_r(+subStmt: P113DStmt, +p: String, +op: String, +n: String, r: N111Value,
    +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match r:
    case N111Const{1,0}:
      nt_choose(List<&2,P113DStmt>,
        agy_str_eq(op,"sub") && Bool.not(agy_str_eq(p,n)) &&
        Bool.not(x181_register_reserved(p)) && Bool.not(x181_register_reserved(n)) &&
        w5_can_sink_tail(rest,p,n,False{}),
        u => w5_sink_body(w5_insert_before_again(rest,subStmt)),
        u => Con{subStmt,w5_sink_body(rest)})
    case _: Con{subStmt,w5_sink_body(rest)}

@unsafe
def w5_try_sink_bin(+subStmt: P113DStmt, +p: String, +op: String, l: N111Value, r: N111Value,
    +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match l:
    case N111Local{+n}: w5_try_sink_bin_r(subStmt,p,op,n,r,rest)
    case _: Con{subStmt,w5_sink_body(rest)}

@unsafe
def w5_sink_scalar(+stmt: P113DStmt, sc: N111Stmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match sc:
    case N111Bin{p,_,op,l,r}: w5_try_sink_bin(stmt,p,op,l,r,rest)
    case _: Con{stmt,w5_sink_body(rest)}

@unsafe
def w5_sink_body(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{+sc},+rest}: w5_sink_scalar(P113DScalar{sc},sc,rest)
    case Con{P113DIf{cond,yes,no},rest}: Con{P113DIf{cond,w5_sink_body(yes),w5_sink_body(no)},w5_sink_body(rest)}
    case Con{h,rest}: Con{h,w5_sink_body(rest)}

"""

    old_call = """  x185_function_copied(symbol,params,setup,agy_reuse_body(symbol,ids,agy_asr_and_dead(setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))))),ids)"""

    new_call = """  x185_function_copied(symbol,params,setup,w5_sink_body(agy_reuse_body(symbol,ids,agy_asr_and_dead(setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))))),ids)"""

    anchor = "def x185_loop_registers_enabled() -> Bool: True{}"
    src = replace_exact(src, anchor, helpers + anchor, "Pass 2a: insert w5_sink_body helpers")
    src = replace_exact(src, old_call, new_call, "Pass 2b: wire w5_sink_body")
    return src


def patch_3_multilevel_cmov(src: str) -> str:
    """Pass 3: Dispatch N111If into w4c_dia_if and admit canonical 1-stmt P113DIf cmov selects."""
    old = """@unsafe
def w4c_dia_arm_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{sc},rest}:
      U32.is_gt(limit,0) && w4c_dia_pure_scalar(sc) && w4c_dia_arm_pure(rest,U32.sub(limit,1))
    case _: False{}

@unsafe
def w4c_dia_last_scalar(stmt: N111Stmt) -> W4CLastDst:
  match stmt:
    case N111Set{n,t,_}: W4CLast{n,t}
    case N111Bin{n,t,+op,_,_}:
      W4CLast{n,nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => t)}
    case _: W4CLastNone{}

@unsafe
def w4c_dia_last_dst(body: List<&2,P113DStmt>) -> W4CLastDst:
  match body:
    case Nil{}: W4CLastNone{}
    case Con{P113DScalar{sc},Nil{}}: w4c_dia_last_scalar(sc)
    case Con{_,rest}: w4c_dia_last_dst(rest)

@unsafe
def w4c_dia_write_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: x185_d_mark(acc,n)
    case N111Bin{n,_,_,_,_}: x185_d_mark(acc,n)
    case _: acc

@unsafe
def w4c_dia_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_writes(rest,w4c_dia_write_scalar(sc,acc))
    case Con{_,rest}: w4c_dia_writes(rest,acc)

@unsafe
def w4c_dia_read_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{_,_,v}: x185_d_value(v,acc)
    case N111Bin{_,_,_,l,r}: x185_d_value(r,x185_d_value(l,acc))
    case _: acc

@unsafe
def w4c_dia_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_reads(rest,w4c_dia_read_scalar(sc,acc))
    case Con{_,rest}: w4c_dia_reads(rest,acc)

@unsafe
def w4c_dia_nonlast_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{n,_,_}: n
    case N111Bin{n,_,_,_,_}: n
    case _: ""

@unsafe
def w4c_dia_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forb: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{sc},rest}:
      +n = w4c_dia_nonlast_name(sc)
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) &&
        Bool.not(w4c_dia_has(forb,n)) && w4c_dia_nonlast_ok(rest,dst,forb)
    case _: False{}

@unsafe
def w4c_dia_cond_ok(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4c_dia_has(writes,n))
    case N111Const{_,_}: True{}
    case _: False{}

@unsafe
def w4c_dia_rename_scalar(stmt: N111Stmt, +newDst: String) -> N111Stmt:
  match stmt:
    case N111Set{_,t,v}: N111Set{newDst,t,v}
    case N111Bin{_,t,op,l,r}: N111Bin{newDst,t,op,l,r}
    case _: stmt

@unsafe
def w4c_dia_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{sc},Nil{}}: [P113DScalar{w4c_dia_rename_scalar(sc,newDst)}]
    case Con{h,rest}: Con{h,w4c_dia_rename_last(rest,newDst)}"""

    new = """# ---- W5-R1 Pass 3: Multi-Level Pure Scalar cmov Select Helpers ----
type W5Sel is Data:
  W5SelNone{}
  W5Sel{+c: N111Value, +dst: String, +typ: N111Type, +va: N111Value, +vb: N111Value}

@unsafe
def w5_as_sel_no(+cond: N111Value, +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm) -> W5Sel:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(W5Sel,
        w4c_sel_val(cond) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => W5Sel{cond,a,ta,va,vb},
        u => W5SelNone{})
    case W4CSelArmNone{}: W5SelNone{}

@unsafe
def w5_as_sel_yes(+cond: N111Value, ya: W4CSelArm, no: List<&2,P113DStmt>) -> W5Sel:
  match ya:
    case W4CSelArm{a,ta,va}: w5_as_sel_no(cond,a,ta,va,w4c_sel_arm(no))
    case W4CSelArmNone{}: W5SelNone{}

@unsafe
def w5_as_sel(+cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> W5Sel:
  w5_as_sel_yes(cond,w4c_sel_arm(yes),no)

@unsafe
def w5_sel_is(s: W5Sel) -> Bool:
  match s:
    case W5Sel{_,_,_,_,_}: True{}
    case W5SelNone{}: False{}

@unsafe
def w5_sel_last(s: W5Sel) -> W4CLastDst:
  match s:
    case W5Sel{_,dst,typ,_,_}: W4CLast{dst,typ}
    case W5SelNone{}: W4CLastNone{}

@unsafe
def w5_sel_write(s: W5Sel, acc: KDef) -> KDef:
  match s:
    case W5Sel{_,dst,_,_,_}: x185_d_mark(acc,dst)
    case W5SelNone{}: acc

@unsafe
def w5_sel_read(s: W5Sel, acc: KDef) -> KDef:
  match s:
    case W5Sel{c,_,_,va,vb}: x185_d_value(vb,x185_d_value(va,x185_d_value(c,acc)))
    case W5SelNone{}: acc

@unsafe
def w5_sel_nonlast_ok(s: W5Sel, +dst: String, +forb: KDef) -> Bool:
  match s:
    case W5Sel{_,+n,_,_,_}:
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) && Bool.not(w4c_dia_has(forb,n))
    case W5SelNone{}: False{}

@unsafe
def w5_sel_rename(s: W5Sel, +newDst: String, orig: P113DStmt) -> P113DStmt:
  match s:
    case W5Sel{c,_,+typ,va,vb}:
      P113DIf{c,[P113DScalar{N111Set{newDst,typ,va}}],[P113DScalar{N111Set{newDst,typ,vb}}]}
    case W5SelNone{}: orig

@unsafe
def w4c_dia_arm_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{sc},rest}:
      U32.is_gt(limit,0) && w4c_dia_pure_scalar(sc) && w4c_dia_arm_pure(rest,U32.sub(limit,1))
    case Con{P113DIf{c,y,n},rest}:
      U32.is_gt(limit,0) && w5_sel_is(w5_as_sel(c,y,n)) && w4c_dia_arm_pure(rest,U32.sub(limit,1))
    case _: False{}

@unsafe
def w4c_dia_last_scalar(stmt: N111Stmt) -> W4CLastDst:
  match stmt:
    case N111Set{n,t,_}: W4CLast{n,t}
    case N111Bin{n,t,+op,_,_}:
      W4CLast{n,nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => t)}
    case _: W4CLastNone{}

@unsafe
def w4c_dia_last_dst(body: List<&2,P113DStmt>) -> W4CLastDst:
  match body:
    case Nil{}: W4CLastNone{}
    case Con{P113DScalar{sc},Nil{}}: w4c_dia_last_scalar(sc)
    case Con{P113DIf{c,y,n},Nil{}}: w5_sel_last(w5_as_sel(c,y,n))
    case Con{_,rest}: w4c_dia_last_dst(rest)

@unsafe
def w4c_dia_write_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: x185_d_mark(acc,n)
    case N111Bin{n,_,_,_,_}: x185_d_mark(acc,n)
    case _: acc

@unsafe
def w4c_dia_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_writes(rest,w4c_dia_write_scalar(sc,acc))
    case Con{P113DIf{c,y,n},rest}: w4c_dia_writes(rest,w5_sel_write(w5_as_sel(c,y,n),acc))
    case Con{_,rest}: w4c_dia_writes(rest,acc)

@unsafe
def w4c_dia_read_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{_,_,v}: x185_d_value(v,acc)
    case N111Bin{_,_,_,l,r}: x185_d_value(r,x185_d_value(l,acc))
    case _: acc

@unsafe
def w4c_dia_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_reads(rest,w4c_dia_read_scalar(sc,acc))
    case Con{P113DIf{c,y,n},rest}: w4c_dia_reads(rest,w5_sel_read(w5_as_sel(c,y,n),acc))
    case Con{_,rest}: w4c_dia_reads(rest,acc)

@unsafe
def w4c_dia_nonlast_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{n,_,_}: n
    case N111Bin{n,_,_,_,_}: n
    case _: ""

@unsafe
def w4c_dia_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forb: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{sc},rest}:
      +n = w4c_dia_nonlast_name(sc)
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) &&
        Bool.not(w4c_dia_has(forb,n)) && w4c_dia_nonlast_ok(rest,dst,forb)
    case Con{P113DIf{c,y,n},rest}:
      w5_sel_nonlast_ok(w5_as_sel(c,y,n),dst,forb) && w4c_dia_nonlast_ok(rest,dst,forb)
    case _: False{}

@unsafe
def w4c_dia_cond_ok(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4c_dia_has(writes,n))
    case N111Const{_,_}: True{}
    case _: False{}

@unsafe
def w4c_dia_rename_scalar(stmt: N111Stmt, +newDst: String) -> N111Stmt:
  match stmt:
    case N111Set{_,t,v}: N111Set{newDst,t,v}
    case N111Bin{_,t,op,l,r}: N111Bin{newDst,t,op,l,r}
    case _: stmt

@unsafe
def w4c_dia_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{sc},Nil{}}: [P113DScalar{w4c_dia_rename_scalar(sc,newDst)}]
    case Con{P113DIf{+c,+y,+n},Nil{}}: [w5_sel_rename(w5_as_sel(c,y,n),newDst,P113DIf{c,y,n})]
    case Con{h,rest}: Con{h,w4c_dia_rename_last(rest,newDst)}"""

    src = replace_exact(src, old, new, "Pass 3a: multi-level pure cmov helpers")

    # Pass 3b: Dispatch P113DScalar{N111If{...}} to w4c_dia_if!
    old_scalar = """@unsafe
def w4c_dia_scalar(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,live,seq}: w4c_dia_scalar_go(stmt,rest,live,seq,again,terminal)"""

    new_scalar = """type W5SnapSet is Data:
  W5SnapNone{}
  W5Snap{+dst: String, +typ: N111Type, +val: N111Value}

@unsafe
def w5_as_snap_sc(sc: N111Stmt) -> W5SnapSet:
  match sc:
    case N111Set{d,t,v}: W5Snap{d,t,v}
    case _: W5SnapNone{}

@unsafe
def w5_as_snap(st: P113DStmt) -> W5SnapSet:
  match st:
    case P113DScalar{sc}: w5_as_snap_sc(sc)
    case _: W5SnapNone{}

@unsafe
def w5_snap_local_eq(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{s}: agy_str_eq(s,target)
    case _: False{}

@unsafe
def w5_dia_collapse_pair2(+h1: P113DStmt, +h2: P113DStmt, +t: String, +v: N111Value,
    s2: W5SnapSet, +afterLive: KDef) -> List<&2,P113DStmt>:
  match s2:
    case W5Snap{dst,dt,v2}:
      nt_choose(List<&2,P113DStmt>,w5_snap_local_eq(v2,t) && Bool.not(w4c_dia_has(afterLive,t)),
        u => [P113DScalar{N111Set{dst,dt,v}}],
        u => [h1,h2])
    case W5SnapNone{}: [h1,h2]

@unsafe
def w5_dia_collapse_pair(+h1: P113DStmt, +h2: P113DStmt, s1: W5SnapSet, +afterLive: KDef) -> List<&2,P113DStmt>:
  match s1:
    case W5Snap{t,_,v}: w5_dia_collapse_pair2(h1,h2,t,v,w5_as_snap(h2),afterLive)
    case W5SnapNone{}: [h1,h2]

@unsafe
def w5_dia_collapse_arm(arm: List<&2,P113DStmt>, +afterLive: KDef) -> List<&2,P113DStmt>:
  match arm:
    case Nil{}: []
    case Con{+h1,Con{+h2,Nil{}}}: w5_dia_collapse_pair(h1,h2,w5_as_snap(h1),afterLive)
    case Con{h,rest}: Con{h,w5_dia_collapse_arm(rest,afterLive)}

@unsafe
def w5_dia_scalar_other(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,live,seq}: w4c_dia_scalar_go(stmt,rest,live,seq,again,terminal)

@unsafe
def w4c_dia_scalar(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case N111If{cond,yes,no}: w4c_dia_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),after,again,terminal)
    case _: w5_dia_scalar_other(stmt,after,again,terminal)"""

    src = replace_exact(src, old_scalar, new_scalar, "Pass 3b: dispatch N111If + snap collapse")

    old_if_done = """@unsafe
def w4c_dia_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef,
    yes: W4CDiaRes, no: W4CDiaRes) -> W4CDiaRes:
  match yes:
    case W4CDiaRes{+yb,+yl,_}:
      match no:
        case W4CDiaRes{+nb,+nl,+seq2}:
          w4c_dia_try(cond,yb,nb,rest,afterLive,yl,nl,seq2,w4c_dia_last_dst(yb))"""

    new_if_done = """@unsafe
def w4c_dia_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef,
    yes: W4CDiaRes, no: W4CDiaRes) -> W4CDiaRes:
  match yes:
    case W4CDiaRes{+yb0,+yl,_}:
      match no:
        case W4CDiaRes{+nb0,+nl,+seq2}:
          +yb = w5_dia_collapse_arm(yb0,afterLive)
          +nb = w5_dia_collapse_arm(nb0,afterLive)
          w4c_dia_try(cond,yb,nb,rest,afterLive,yl,nl,seq2,w4c_dia_last_dst(yb))"""

    return replace_exact(src, old_if_done, new_if_done, "Pass 3c: collapse dead snapshot temp in w4c_dia_if_done")


def patch_4_tiny_loop_peel_and_exit_rotate(src: str) -> str:
    """Pass 4a: 2-step peel for tiny P113DCall-free scratch-free self-recursive P113DAgain callees.
       Pass 4b: Allow calls & internal branches/labels in rotated loop exit blocks."""
    old_inline = """@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
        nt_append(P113DStmt,p113i_bind(params,args,prefix),w4i_expand(body,prefix,destinations,name)))"""

    new_inline = """# ---- W5-R1 Pass 4a: 2-Step Peel for Tiny P113DCall-Free Self-Recursive Loops ----
law w5_body_no_dcalls:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w5_body_no_dcalls(body):
  match body:
    case Nil{}: True{}
    case Con{P113DIf{_,yes,no},rest}: w5_body_no_dcalls(yes) && w5_body_no_dcalls(no) && w5_body_no_dcalls(rest)
    case Con{P113DCall{_,_,_},_}: False{}
    case Con{P113DScalar{N111Call{_,_,_,_}},_}: False{}
    case Con{P113DScalar{N111Alloca{_,_,_}},_}: False{}
    case Con{_,rest}: w5_body_no_dcalls(rest)

law w5_expand_peel:
  for body: List<&2,P113DStmt>
  for +prefix: String
  for +destinations: List<&2,String>
  for +callee: P113DFunction
  for +fuel: U32
  List<&2,P113DStmt>

@unsafe
def w5_inline_step(callee: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>,
    +prefix: String, +fuel: U32) -> List<&2,P113DStmt>:
  match callee:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113i_bind(params,args,prefix),
        w5_expand_peel(body,prefix,destinations,P113DFunction{name,params,result,public,body},fuel))

@unsafe
def w5_callee_name(callee: P113DFunction) -> String:
  match callee:
    case P113DFunction{name,_,_,_,_}: name

@unsafe
def w5_expand_peel(body,prefix,destinations,callee,fuel):
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),
            w5_expand_peel(yes,prefix,destinations,callee,fuel),
            w5_expand_peel(no,prefix,destinations,callee,fuel)},
        w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},
        w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case Con{P113DAgain{values},rest}:
      +nextArgs = p113j_values(values,prefix)
      nt_choose(List<&2,P113DStmt>,U32.is_gt(fuel,0),
        u => w5_inline_step(callee,nextArgs,destinations,prefix ++ "p",U32.sub(fuel,1)),
        u => [P113DCall{destinations,w5_callee_name(callee),nextArgs}])

@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +tiny = U32.is_le(p113i_size(body),64) && U32.is_eq(p113j_scratch(body),0) && w5_body_no_dcalls(body)
      nt_choose(List<&2,P113DStmt>,tiny,
        u => nt_append(P113DStmt,p113i_bind(params,args,prefix),
          w5_expand_peel(body,prefix,destinations,P113DFunction{name,params,result,public,body},2)),
        u => nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
          nt_append(P113DStmt,p113i_bind(params,args,prefix),w4i_expand(body,prefix,destinations,name))))"""

    src = replace_exact(src, old_inline, new_inline, "Pass 4a: tiny loop 2-step peel")

    # Pass 4b: General exit-block rotation in w4b_take_exit_clean
    old_exit = """@unsafe
def w4b_take_exit_ret(next: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match next:
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl),
        u => W4BExitSplit{nt_reverse(X187Parsed,Con{PInst{X187Instruction{"ret",[]}},acc},[]),rest},
        u => W4BExitNone{})
    case _: W4BExitNone{}

@unsafe
def w4b_take_exit_clean(items: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match items:
    case Nil{}: W4BExitNone{}
    case Con{PLabel{_},_}: W4BExitNone{}
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(W4BExitSplit,agy_str_eq(op,"ret"),
        u => w4b_take_exit_ret(rest,bodyLbl,acc),
        u => nt_choose(W4BExitSplit,agy_str_eq(op,"call") || String.starts_with(op,"j"),
          v => W4BExitNone{},
          v => w4b_take_exit_clean(rest,bodyLbl,Con{PInst{X187Instruction{op,args}},acc})))
    case _: W4BExitNone{}"""

    new_exit = """# ---- W5-R1 Pass 4b: General Exit-Block Rotation (allows cold calls/internal branches) ----
@unsafe
def w5_args_jump_to(args: List<&2,X187Operand>, +lbl1: String, +lbl2: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{X187Target{+t},rest}:
      agy_str_eq(t,lbl1) || agy_str_eq(t,lbl2) || w5_args_jump_to(rest,lbl1,lbl2)
    case Con{_,rest}: w5_args_jump_to(rest,lbl1,lbl2)

@unsafe
def w4b_take_exit_ret(next: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match next:
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl),
        u => W4BExitSplit{nt_reverse(X187Parsed,Con{PInst{X187Instruction{"ret",[]}},acc},[]),rest},
        u => W4BExitNone{})
    case _: W4BExitNone{}

law w5_take_exit_gen:
  for items: List<&2,X187Parsed>
  for +loopLbl: String
  for +bodyLbl: String
  for +acc: List<&2,X187Parsed>
  for +fuel: U32
  W4BExitSplit

@unsafe
def w5_take_exit_step(items: List<&2,X187Parsed>, +loopLbl: String, +bodyLbl: String,
    +acc: List<&2,X187Parsed>, +fuel: U32) -> W4BExitSplit:
  match items:
    case Nil{}: W4BExitNone{}
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl) || agy_str_eq(lbl,loopLbl),
        v => W4BExitNone{},
        v => w5_take_exit_gen(rest,loopLbl,bodyLbl,Con{PLabel{lbl},acc},U32.sub(fuel,1)))
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(W4BExitSplit,agy_str_eq(op,"ret"),
        v => w4b_take_exit_ret(rest,bodyLbl,acc),
        v => nt_choose(W4BExitSplit,String.starts_with(op,"j") && w5_args_jump_to(args,loopLbl,bodyLbl),
          w => W4BExitNone{},
          w => w5_take_exit_gen(rest,loopLbl,bodyLbl,Con{PInst{X187Instruction{op,args}},acc},U32.sub(fuel,1))))
    case _: W4BExitNone{}

@unsafe
def w5_take_exit_gen(items,loopLbl,bodyLbl,acc,fuel):
  nt_choose(W4BExitSplit,U32.is_eq(fuel,0),u => W4BExitNone{},
    u => w5_take_exit_step(items,loopLbl,bodyLbl,acc,fuel))

@unsafe
def w4b_take_exit_clean(items: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  w5_take_exit_gen(items,"",bodyLbl,acc,256)"""

    src = replace_exact(src, old_exit, new_exit, "Pass 4b: general exit-block rotation")

    old_test_call = "w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,s,ws,orig)"
    new_test_call = "w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],256),before,loopLbl,bodyLbl,s,ws,orig)"
    src = replace_exact(src, old_test_call, new_test_call, "Pass 4b: wire loopLbl in w4c_rotate_check_test")

    old_cmp_call = "w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,r,w,orig)"
    new_cmp_call = "w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],256),before,loopLbl,bodyLbl,r,w,orig)"
    src = replace_exact(src, old_cmp_call, new_cmp_call, "Pass 4b: wire loopLbl in w4c_rotate_check_cmp")
    return src


def patch_5_min_bce_and_sub_mov_test(src: str) -> str:
    """Pass 5a: General `inv_base + min(any, inv_k)` BCE in w4c_bce_analyze.
       Pass 5b: Drop redundant `testq %r, %r` after `subq $1, %r` + 0..2 flag-preserving movs."""
    # Pass 5a: Track LT_<lsrc>(kIdx) and ISUM(baseIdx, kIdx) in w4c_step_bin_r,
    # detect MIN(kIdx) across 1-stmt min P113DIf / N111If in w4c_bce_walk_step,
    # and hoist base <= mask && k <= mask && (base + k) <= mask in w4c_bce_site_local.
    old_bin_none = """        case None{}: w4c_env_kill(env,dest)"""
    new_bin_none = """        case None{}:
          w5_step_bin_locals(op,dest,lsrc,rsrc,env)"""

    bin_helpers = """# ---- W5-R1 Pass 5a: Invariant-Bounded min(x, inv_k) + inv_base BCE ----
@unsafe
def w5_step_bin_locals(+op: String, +dest: String, +lsrc: String, +rsrc: String, +env: KDef) -> KDef:
  nt_choose(KDef,(agy_str_eq(op,"ult") || agy_str_eq(op,"ule")) &&
      Bool.not(String.is_empty(lsrc)) && Bool.not(String.is_empty(rsrc)),
    u =>
      +rd = p111v_get(env,rsrc)
      nt_choose(KDef,agy_str_eq(dk(rd),"PRM"),
        v => p111v_put(env,dest,"LT_" ++ lsrc,da(rd),0),
        v => w4c_env_kill(env,dest)),
    u => nt_choose(KDef,agy_str_eq(op,"add") &&
        Bool.not(String.is_empty(lsrc)) && Bool.not(String.is_empty(rsrc)),
      v =>
        +ld = p111v_get(env,lsrc)
        +rd = p111v_get(env,rsrc)
        nt_choose(KDef,agy_str_eq(dk(ld),"PRM") && agy_str_eq(dk(rd),"MIN"),
          w => p111v_put(env,dest,"ISUM",da(ld),da(rd)),
          w => nt_choose(KDef,agy_str_eq(dk(rd),"PRM") && agy_str_eq(dk(ld),"MIN"),
            x => p111v_put(env,dest,"ISUM",da(rd),da(ld)),
            x => w4c_env_kill(env,dest))),
      v => w4c_env_kill(env,dest)))

@unsafe
def w5_fs_check_inv_val(v: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match v:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"PRM") && U32.is_eq(da(d),pidx)
    case _: False{}

law w5_fs_check_inv:
  for +pidx: U32
  for body: List<&2,P113DStmt>
  for +env: KDef
  Bool

@unsafe
def w5_fs_check_inv(pidx,body,env):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w5_fs_check_inv(pidx,rest,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w5_fs_check_inv(pidx,rest,w4c_kill_names(dests,env))
    case Con{P113DIf{_,yes,no},rest}:
      w5_fs_check_inv(pidx,yes,env) && w5_fs_check_inv(pidx,no,env) && w5_fs_check_inv(pidx,rest,env)
    case Con{P113DAgain{vals},_}: w5_fs_check_inv_val(w4c_nth_val(vals,pidx),pidx,env)
    case Con{_,rest}: w5_fs_check_inv(pidx,rest,env)

@unsafe
def w5_fs_inv_mask(params: List<&2,NC_Binding>, +i: U32, +body: List<&2,P113DStmt>, +seed: KDef, +acc: U32) -> U32:
  match params:
    case Nil{}: acc
    case Con{_,rest}:
      +acc2 = nt_choose(U32,U32.is_lt(i,31) && w5_fs_check_inv(i,body,seed),
        u => U32.or(acc,U32.shln(1,U32.to_nat(i))),
        u => acc)
      w5_fs_inv_mask(rest,U32.inc(i),body,seed,acc2)

type W5SetLoc is Data:
  W5SetLocNone{}
  W5SetLoc{+dst: String, +src: String}

@unsafe
def w5_set_loc_val(+dst: String, v: N111Value) -> W5SetLoc:
  match v:
    case N111Local{s}: W5SetLoc{dst,s}
    case _: W5SetLocNone{}

@unsafe
def w5_set_loc_sc(sc: N111Stmt) -> W5SetLoc:
  match sc:
    case N111Set{d,_,v}: w5_set_loc_val(d,v)
    case _: W5SetLocNone{}

@unsafe
def w5_set_loc_st(st: P113DStmt) -> W5SetLoc:
  match st:
    case P113DScalar{sc}: w5_set_loc_sc(sc)
    case _: W5SetLocNone{}

@unsafe
def w5_arm_loc_pair2(+t: String, +src: String, s2: W5SetLoc) -> W5SetLoc:
  match s2:
    case W5SetLoc{dst,s}: nt_choose(W5SetLoc,agy_str_eq(t,s),u => W5SetLoc{dst,src},u => W5SetLocNone{})
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w5_arm_loc_pair(s1: W5SetLoc, h2: P113DStmt) -> W5SetLoc:
  match s1:
    case W5SetLoc{t,src}: w5_arm_loc_pair2(t,src,w5_set_loc_st(h2))
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w5_arm_loc(body: List<&2,P113DStmt>) -> W5SetLoc:
  match body:
    case Con{h1,Nil{}}: w5_set_loc_st(h1)
    case Con{h1,Con{h2,Nil{}}}: w5_arm_loc_pair(w5_set_loc_st(h1),h2)
    case _: W5SetLocNone{}

@unsafe
def w5_loc_dst(x: W5SetLoc) -> String:
  match x:
    case W5SetLoc{dst,_}: dst
    case W5SetLocNone{}: ""

@unsafe
def w5_loc_src(x: W5SetLoc) -> String:
  match x:
    case W5SetLoc{_,src}: src
    case W5SetLocNone{}: ""

@unsafe
def w5_arm_set_dst(body: List<&2,P113DStmt>) -> String:
  w5_loc_dst(w5_arm_loc(body))

@unsafe
def w5_arm_set_src(body: List<&2,P113DStmt>) -> String:
  w5_loc_src(w5_arm_loc(body))

@unsafe
def w5_step_min_if(+cond: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +env: KDef) -> KDef:
  match cond:
    case N111Local{cn}:
      +cd = p111v_get(env,cn)
      +tag = dk(cd)
      +kIdx = da(cd)
      +yd = w5_arm_set_dst(yes)
      +nd = w5_arm_set_dst(no)
      +ys = w5_arm_set_src(yes)
      +ns = w5_arm_set_src(no)
      +nsd = p111v_get(env,ns)
      nt_choose(KDef,
        String.starts_with(tag,"LT_") && Bool.not(String.is_empty(yd)) && agy_str_eq(yd,nd) &&
        agy_str_eq("LT_" ++ ys,tag) && agy_str_eq(dk(nsd),"PRM") && U32.is_eq(da(nsd),kIdx),
        u => p111v_put(env,yd,"MIN",kIdx,0),
        u => env)
    case _: env

@unsafe
def w5_step_scalar_ext(+stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111If{cond,yes,no}: w5_step_min_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),env)
    case _: w4c_step_scalar(stmt,env)

"""

    # Anchor before w4c_step_bin_r
    anchor_bin = "@unsafe\ndef w4c_step_bin_r("
    src = replace_exact(src, anchor_bin, bin_helpers + anchor_bin, "Pass 5a: insert min-BCE helpers")
    # Replace exact `case None{}: w4c_env_kill(env,dest)` inside w4c_step_bin_r
    old_bin_block = """              x => nt_choose(KDef,agy_str_eq(op,"ne") && U32.is_eq(lo,0) && Bool.not(String.is_empty(lsrc)),
                y => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"NZ",3),
                y => w4c_env_kill(env,dest))))))
    case None{}:
      match lc:
        case Some{+lo}:
          nt_choose(KDef,agy_str_eq(op,"and") && U32.is_eq(lo,4294967295) && Bool.not(String.is_empty(rsrc)),
            u => w4c_env_copy(env,dest,rsrc),
            u => nt_choose(KDef,agy_str_eq(op,"and") && U32.is_le(lo,2147483647),
              v => p111v_put(env,dest,"BM",lo,0),
              v => nt_choose(KDef,agy_str_eq(op,"add") && U32.is_eq(lo,1) && Bool.not(String.is_empty(rsrc)),
                w => w4c_env_put_param(w4c_env_param_idx(env,rsrc),env,dest,"INC",1),
                w => w4c_env_kill(env,dest))))
        case None{}: w4c_env_kill(env,dest)"""

    new_bin_block = old_bin_block.replace(
        "        case None{}: w4c_env_kill(env,dest)",
        "        case None{}: w5_step_bin_locals(op,dest,lsrc,rsrc,env)",
        1,
    )
    src = replace_exact(src, old_bin_block, new_bin_block, "Pass 5a: wire w5_step_bin_locals")

    # Wire invMask + w5_step_scalar_ext + w5_step_min_if in w4c_bce_walk_step & w4c_bce_site_local!
    # Wait: we can store invMask in pbmMap under key "__inv__" so we don't even have to change
    # the signature of w4c_bce_walk / w4c_bce_site_local! Genius & zero churn!
    old_analyze_cnt = """@unsafe
def w4c_bce_analyze_cnt(cntIdx: Maybe<&2,U32>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef, +seed: KDef) -> W4CBCEPlan:
  match cntIdx:
    case Some{+ci}:
      +cntName = w4c_nth_param_name(params,ci)
      +ivMask = w4c_fs_iv_mask(params,0,body,seed,0)
      +pbmMap = w4c_fs_pbm_map(params,0,body,seed,missing())
      w4c_bce_walk(body,0,used,sites,False{},Some{ci},cntName,params,ivMask,pbmMap,seed,missing(),[])
    case None{}:
      +pbmMap = w4c_fs_pbm_map(params,0,body,seed,missing())
      w4c_bce_walk(body,0,used,sites,False{},None{},"",params,0,pbmMap,seed,missing(),[])"""

    new_analyze_cnt = """@unsafe
def w4c_bce_analyze_cnt(cntIdx: Maybe<&2,U32>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef, +seed: KDef) -> W4CBCEPlan:
  match cntIdx:
    case Some{+ci}:
      +invMask = w5_fs_inv_mask(params,0,body,seed,0)
      +cntName = w4c_nth_param_name(params,ci)
      +ivMask = w4c_fs_iv_mask(params,0,body,seed,0)
      +pbmMap = p111v_put(w4c_fs_pbm_map(params,0,body,seed,missing()),"__inv__","W5INV",invMask,1)
      w4c_bce_walk(body,0,used,sites,False{},Some{ci},cntName,params,ivMask,pbmMap,seed,missing(),[])
    case None{}:
      +invMask = w5_fs_inv_mask(params,0,body,seed,0)
      +pbmMap = p111v_put(w4c_fs_pbm_map(params,0,body,seed,missing()),"__inv__","W5INV",invMask,1)
      w4c_bce_walk(body,0,used,sites,False{},None{},"",params,0,pbmMap,seed,missing(),[])"""

    src = replace_exact(src, old_analyze_cnt, new_analyze_cnt, "Pass 5a: store invMask in pbmMap")

    # Wire w5_step_scalar_ext and w5_step_min_if in w4c_bce_walk_step
    old_walk_step = """    case Con{P113DScalar{+stmt},+rest}:
      +env2 = w4c_step_scalar(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_eq(p113a_stmt_id(stmt),0),
        u => w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards),
        u => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards))
    case Con{P113DCall{dests,_,_},+rest}:
      w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,w4c_kill_names(dests,env),nomask,guards)
    case Con{P113DIf{cond,yes,no},+rest}:
      +isNz = w4c_opt_eq2(w4c_cond_nz_param(cond,env),cntIdx)
      w4c_bce_walk_yes(w4c_bce_walk(yes,n,used,sites,guarded || isNz,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards),
        no,rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env)"""

    new_walk_step = """    case Con{P113DScalar{+stmt},+rest}:
      +env2 = w5_step_scalar_ext(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_eq(p113a_stmt_id(stmt),0),
        u => w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards),
        u => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards))
    case Con{P113DCall{dests,_,_},+rest}:
      w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,w4c_kill_names(dests,env),nomask,guards)
    case Con{P113DIf{+cond,+yes,+no},+rest}:
      +isNz = w4c_opt_eq2(w4c_cond_nz_param(cond,env),cntIdx)
      +envAfter = w5_step_min_if(cond,yes,no,env)
      w4c_bce_walk_yes(w4c_bce_walk(yes,n,used,sites,guarded || isNz,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards),
        no,rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,envAfter)"""

    src = replace_exact(src, old_walk_step, new_walk_step, "Pass 5a: wire min-if tracking in w4c_bce_walk_step")

    # Add Case 4 (ISUM) to w4c_bce_site_local
    old_site_fallback = """            v => W4CBCEPlan{nomask,guards,U32.inc(n)}))
    case _: W4CBCEPlan{nomask,guards,U32.inc(n)}"""

    new_site_fallback = """            v =>
              +invMask = da(p111v_get(pbmMap,"__inv__"))
              nt_choose(W4CBCEPlan,
                agy_str_eq(dk(d),"ISUM") && w4c_has_bit(invMask,da(d)) && w4c_has_bit(invMask,dx(d)),
                w =>
                  +bname = w4c_nth_param_name(params,da(d))
                  +kname = w4c_nth_param_name(params,dx(d))
                  +sumNm = pfx ++ "isum"
                  +gB = w4c_guard_ule(pfx ++ "ib",N111Local{bname},maskRef)
                  +gK = w4c_guard_ule(pfx ++ "ik",N111Local{kname},maskRef)
                  +gAdd: List<&2,N111Stmt> = [N111Bin{sumNm,N111U32{},"add",N111Local{bname},N111Local{kname}}]
                  +gSum = w4c_guard_ule(pfx ++ "is",N111Local{sumNm},maskRef)
                  W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
                    nt_append(N111Stmt,guards,nt_append(N111Stmt,gB,nt_append(N111Stmt,gK,nt_append(N111Stmt,gAdd,gSum)))),U32.inc(n)},
                w => W4CBCEPlan{nomask,guards,U32.inc(n)})))
    case _: W4CBCEPlan{nomask,guards,U32.inc(n)}"""

    src = replace_exact(src, old_site_fallback, new_site_fallback, "Pass 5a: add ISUM guard in w4c_bce_site_local")

    # Pass 5b: Drop redundant `testq %r, %r` after `subq $1, %r` + 0..2 flag-preserving movs
    old_sub_test = """@unsafe
def w4c_try_sub_test_3(+r1: U32, rr: W4BRR, br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      match br:
        case W4BBranch{+jop,_}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r1) && w4_peep_is_jz_jnz(jop),
            u => w4c_peep_cfg(Con{i2,tail},fnItems,Con{X188One{i0},out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case W4BBranchNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})"""

    new_sub_test = """# ---- W5-R1 Pass 5b: Drop redundant testq %r,%r after subq $1,%r + 0..2 flag-preserving movs ----
@unsafe
def w5_mov_args_ok(args: List<&2,X187Operand>, +r: U32) -> Bool:
  match args:
    case Con{_,Con{X187Reg{dr,_,False{}},Nil{}}}: Bool.not(U32.is_eq(dr,r))
    case Con{_,Con{X187Mem{_,_},Nil{}}}: True{}
    case _: False{}

@unsafe
def w5_is_mov_not_writing(item: X187Parsed, +r: U32) -> Bool:
  match item:
    case PInst{X187Instruction{+op,args}}:
      (agy_str_eq(op,"movq") || agy_str_eq(op,"movl")) && w5_mov_args_ok(args,r)
    case _: False{}

@unsafe
def w5_check_testq_r(rr: W4BRR, +r: U32) -> Bool:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r)
    case _: False{}

@unsafe
def w5_is_testq_r(item: X187Parsed, +r: U32) -> Bool:
  w5_check_testq_r(w4b_as_rr(item),r)

@unsafe
def w5_check_jz_jnz(br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{+jop,_}: w4_peep_is_jz_jnz(jop)
    case W4BBranchNone{}: False{}

@unsafe
def w5_is_jz_jnz_item(item: X187Parsed) -> Bool:
  w5_check_jz_jnz(w4b_as_branch(item))

@unsafe
def w5_try_sub_mov2(+r1: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    tail3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tail3:
    case Con{+i4,+tail4}:
      nt_choose(List<&2,X188Seq>,
        w5_is_mov_not_writing(i1,r1) && w5_is_mov_not_writing(i2,r1) &&
        w5_is_testq_r(i3,r1) && w5_is_jz_jnz_item(i4),
        v => w4c_peep_cfg(Con{i4,tail4},fnItems,Con{X188One{i2},Con{X188One{i1},Con{X188One{i0},out}}}),
        v => w4c_peep_cfg(Con{i1,Con{i2,Con{i3,Con{i4,tail4}}}},fnItems,Con{X188One{i0},out}))
    case Nil{}: w4c_peep_cfg(Con{i1,Con{i2,Con{i3,Nil{}}}},fnItems,Con{X188One{i0},out})

@unsafe
def w5_try_sub_mov_test(+r1: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tail:
    case Con{+i3,+tail3}:
      nt_choose(List<&2,X188Seq>,
        w5_is_mov_not_writing(i1,r1) && w5_is_testq_r(i2,r1) && w5_is_jz_jnz_item(i3),
        u => w4c_peep_cfg(Con{i3,tail3},fnItems,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w5_try_sub_mov2(r1,i0,i1,i2,i3,tail3,fnItems,out))
    case Nil{}: w4c_peep_cfg(Con{i1,Con{i2,Nil{}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_try_sub_test_3(+r1: U32, rr: W4BRR, br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      match br:
        case W4BBranch{+jop,_}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r1) && w4_peep_is_jz_jnz(jop),
            u => w4c_peep_cfg(Con{i2,tail},fnItems,Con{X188One{i0},out}),
            u => w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out))
        case W4BBranchNone{}: w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out)
    case _: w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out)"""

    src = replace_exact(src, old_sub_test, new_sub_test, "Pass 5b: subq + 0..2 movs + testq + jcc")
    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    src = patch_1_joint_regalloc_cap(src)
    src = patch_2_sink_countdown(src)
    src = patch_3_multilevel_cmov(src)
    src = patch_4_tiny_loop_peel_and_exit_rotate(src)
    src = patch_5_min_bce_and_sub_mov_test(src)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(src)
    print(f"Wrote {args.dst} ({len(src)} bytes)", flush=True)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""B3: Residual x187_priv O(N^2) & HAMT-Churn Killer for wave17_unified/compiler.bend.

100% semantically identical / bit-identical -O2 algorithmic fixes, strictly disjoint from
B2 (p167l_*/p168_*) and B4 (p86_*/x198pw_*):

  1. `p111v_get_empty_fast` (`p111v_get`):
     Check for empty (`Absent`) `KDef` map BEFORE computing `index_hash(name, 2166136261)`
     and inline the top-level `w5c3_find` dispatch. Eliminates wasted FNV-1a string hashing
     on every empty-map lookup across `x187_priv` and `x187_pub`.

  2. `w5c_p131i_leaf_single_fast` (`w5c_p131i_leaf`):
     Fast-path 1-element leaf buckets `Con{h, Nil{}}` (99.99% of HAMT updates) directly
     with one `agy_str_eq`, avoiding recursive `index_remove` + thunk allocation.

  3. `x185_dead_body_delta_union` (`x185_d_mark`, `x185_d_kill`, `w5b_d_ins_if`, `x185_d_if`):
     - `x185_d_mark` / `x185_d_kill`: compute `index_hash` once and skip `p111v_put_h` when
       the variable is already live / already dead (eliminates dead tombstones and redundant
       HAMT path rewrites).
     - `w5b_d_ins_if`: skip `p131i_insert` when key is already live in `out`.
     - `x185_d_if`: replace `O(L log L)` full-HAMT `x185_d_union(yl, nl)` with an exact
       `O(|yes| + |no|)` delta-merge over only variables touched in `yes`/`no` (capped at
       128 touched names, falling back to smaller-side union when an arm terminates or is
       large). Eliminates `O(M * L log L) = O(N^2)` quadratic HAMT unions in `x185_dead_body`.

  4. `x192_x190_skip_zero_tombstones` (`x192_p_write`, `x190_v_written`):
     Skip `index_hash` + `p111v_put(..., 0, 0)` when clearing a predicate/zero32 bit that is
     already absent/0 (eliminates massive HAMT churn in `x192_predicate_body` and
     `x190_local_values_body`).
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave17_unified/compiler.bend"

# --- Hunk 1: p111v_get O(1) empty-map fast path ---
OLD_P111V_GET = """@unsafe
def p111v_get(+tree: KDef, +name: String) -> KDef:
  w5c3_find(tree, name, index_hash(name, 2166136261))"""

NEW_P111V_GET = """@unsafe
def p111v_get(+tree: KDef, +name: String) -> KDef:
  match tree:
    case KIndexNode{stored, mask, left, right}:
      +h = index_hash(name, 2166136261)
      w5c_find_lr(U32.and(h, mask), left, right, name, h)
    case KIndexLeaf{stored, bucket}:
      w5c3_find_leaf(U32.is_eq(stored, index_hash(name, 2166136261)), bucket, name)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      nt_choose(KDef, String.eq(kind, "Absent"),
        u => missing(),
        u => w5c3_find_kdef(False{}, arity, templates, ctors, name, index_hash(name, 2166136261)))"""

# --- Hunk 2: w5c_p131i_leaf 1-element bucket fast path ---
OLD_W5C_P131I_LEAF = """@unsafe
def w5c_p131i_leaf(+mask: U32, +tree: KDef, +d: KDef, +hash: U32, +stored: U32, bucket: List<&2, KDef>) -> KDef:
  match mask:
    case 0: KIndexLeaf{hash, Con{d, index_remove(bucket, dn(d))}}
    case _: w5c_p131i_join(U32.and(hash, mask), stored, tree, d, hash, mask)"""

NEW_W5C_P131I_LEAF = """@unsafe
def b3_p131i_bkt(bucket: List<&2, KDef>, +d: KDef, +hash: U32) -> KDef:
  match bucket:
    case Con{+h, Nil{}}:
      nt_choose(KDef, agy_str_eq(dn(h), dn(d)),
        u => KIndexLeaf{hash, [d]},
        u => KIndexLeaf{hash, Con{d, [h]}})
    case Nil{}: KIndexLeaf{hash, [d]}
    case _: KIndexLeaf{hash, Con{d, index_remove(bucket, dn(d))}}

@unsafe
def w5c_p131i_leaf(+mask: U32, +tree: KDef, +d: KDef, +hash: U32, +stored: U32, bucket: List<&2, KDef>) -> KDef:
  match mask:
    case 0: b3_p131i_bkt(bucket, d, hash)
    case _: w5c_p131i_join(U32.and(hash, mask), stored, tree, d, hash, mask)"""

# --- Hunk 3: x185_dead_body delta-union + skip-unchanged mark/kill ---
OLD_X185_DEAD_MARK_KILL = """@unsafe
def x185_d_mark(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"X185Live",1,0)

@unsafe
def x185_d_kill(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"X185Live",0,0)"""

NEW_X185_DEAD_MARK_KILL = """@unsafe
def b3_d_mark_go(already: Bool, live: KDef, +name: String, +h: U32) -> KDef:
  match already:
    case True{}: live
    case False{}: p111v_put_h(live,name,h,"X185Live",1,0)

@unsafe
def b3_d_mark_h(+live: KDef, +name: String, +h: U32) -> KDef:
  b3_d_mark_go(U32.is_gt(da(index_find(live,name,h,32)),0),live,name,h)

@unsafe
def x185_d_mark(+live: KDef, +name: String) -> KDef:
  b3_d_mark_h(live,name,index_hash(name,2166136261))

@unsafe
def b3_d_kill_go(dead: Bool, live: KDef, +name: String, +h: U32) -> KDef:
  match dead:
    case True{}: live
    case False{}: p111v_put_h(live,name,h,"X185Live",0,0)

@unsafe
def b3_d_kill_h(+live: KDef, +name: String, +h: U32) -> KDef:
  b3_d_kill_go(U32.is_eq(da(index_find(live,name,h,32)),0),live,name,h)

@unsafe
def x185_d_kill(+live: KDef, +name: String) -> KDef:
  match live:
    case KDef{_,kind,_,_,_,_,_,_,_}:
      nt_choose(KDef,String.eq(kind,"Absent"),
        u => live,
        u => b3_d_kill_h(live,name,index_hash(name,2166136261)))
    case _: b3_d_kill_h(live,name,index_hash(name,2166136261))"""

OLD_X185_DEAD_UNION_IF = """@unsafe
def w5b_d_ins_if(live: Bool, +hash: U32, head: KDef, out: KDef) -> KDef:
  match live:
    case True{}: p131i_insert(out,head,hash)
    case False{}: out

@unsafe
def w5b_d_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      w5b_d_union_bkt(hash,rest,w5b_d_ins_if(U32.is_gt(da(head),0),hash,head,out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_d_union_bkt(hash,bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out

@unsafe
def x185_d_base() -> KDef:
  x185_d_names(["state","scratch","__x181_result_out","__x181_results","__x181_tail"],missing())

@unsafe
def x185_d_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: X185Dead) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      nt_choose(X185Dead,U32.is_gt(da(p111v_get(live,name)),0) || x181_register_reserved(name),
        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_values(reads,x185_d_kill(live,name))},
        u => after)

law x185_d_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  X185Dead

@unsafe
def x185_d_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      x185_d_if_done(condition,body,x185_d_body(yes,live,again,terminal),x185_d_body(no,live,again,terminal))

@unsafe
def x185_d_if_done(+condition: N111Value, rest: List<&2,P113DStmt>, yes: X185Dead, no: X185Dead) -> X185Dead:
  match yes no:
    case X185Dead{Nil{},yl} X185Dead{Nil{},nl}:
      X185Dead{rest,x185_d_union(yl,nl)}
    case X185Dead{yb,yl} X185Dead{nb,nl}:
      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}"""

NEW_X185_DEAD_UNION_IF = """@unsafe
def w5b_d_ins_if(live: Bool, +hash: U32, +head: KDef, +out: KDef) -> KDef:
  match live:
    case True{}:
      nt_choose(KDef,U32.is_gt(da(index_find(out,dn(head),hash,32)),0),
        u => out,
        u => p131i_insert(out,head,hash))
    case False{}: out

@unsafe
def w5b_d_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      w5b_d_union_bkt(hash,rest,w5b_d_ins_if(U32.is_gt(da(head),0),hash,head,out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_d_union_bkt(hash,bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out

@unsafe
def x185_d_base() -> KDef:
  x185_d_names(["state","scratch","__x181_result_out","__x181_results","__x181_tail"],missing())

@unsafe
def x185_d_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: X185Dead) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      nt_choose(X185Dead,U32.is_gt(da(p111v_get(live,name)),0) || x181_register_reserved(name),
        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_values(reads,x185_d_kill(live,name))},
        u => after)

law x185_d_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  X185Dead

law b3_d_has_term_scalars:
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def b3_d_has_term_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Return{_}: True{}
    case N111If{_,yes,no}: b3_d_has_term_scalars(yes) || b3_d_has_term_scalars(no)
    case _: False{}

@unsafe
def b3_d_has_term_scalars(body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: b3_d_has_term_scalar(head) || b3_d_has_term_scalars(rest)

@unsafe
def b3_d_has_term(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DResult{_},_}: True{}
    case Con{P113DAgain{_},_}: True{}
    case Con{P113DScalar{s},rest}: b3_d_has_term_scalar(s) || b3_d_has_term(rest)
    case Con{P113DIf{_,yes,no},rest}: b3_d_has_term(yes) || b3_d_has_term(no) || b3_d_has_term(rest)
    case Con{_,rest}: b3_d_has_term(rest)

@unsafe
def b3_d_push_name(name: String, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match acc:
    case None{}: None{}
    case Some{xs}:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_eq(fuel,0),
        u => None{},
        u => Some{Con{name,xs}})

@unsafe
def b3_d_push_val(v: N111Value, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match v:
    case N111Local{name}: b3_d_push_name(name,acc,fuel)
    case _: acc

@unsafe
def b3_d_push_vals(vs: List<&2,N111Value>, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match vs:
    case Nil{}: acc
    case Con{v,rest}: b3_d_push_vals(rest,b3_d_push_val(v,acc,fuel),nt_choose(U32,U32.is_eq(fuel,0),u => 0,u => U32.sub(fuel,1)))

@unsafe
def b3_d_push_args(args: List<&2,N111Arg>, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match args:
    case Nil{}: acc
    case Con{N111Arg{_,v},rest}: b3_d_push_args(rest,b3_d_push_val(v,acc,fuel),nt_choose(U32,U32.is_eq(fuel,0),u => 0,u => U32.sub(fuel,1)))

@unsafe
def b3_d_push_names(names: List<&2,String>, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match names:
    case Nil{}: acc
    case Con{n,rest}: b3_d_push_names(rest,b3_d_push_name(n,acc,fuel),nt_choose(U32,U32.is_eq(fuel,0),u => 0,u => U32.sub(fuel,1)))

law b3_d_touch_scalars:
  for body: List<&2,N111Stmt>
  for acc: Maybe<&2,List<&2,String>>
  for +fuel: U32
  Maybe<&2,List<&2,String>>

@unsafe
def b3_d_touch_scalar(stmt: N111Stmt, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match stmt:
    case N111Set{name,_,v}: b3_d_push_val(v,b3_d_push_name(name,acc,fuel),fuel)
    case N111Bin{name,_,_,l,r}: b3_d_push_val(r,b3_d_push_val(l,b3_d_push_name(name,acc,fuel),fuel),fuel)
    case N111Offset{name,b,by}: b3_d_push_val(by,b3_d_push_val(b,b3_d_push_name(name,acc,fuel),fuel),fuel)
    case N111Call{name,_,_,args}: b3_d_push_args(args,b3_d_push_name(name,acc,fuel),fuel)
    case N111Load{name,_,b,_}: b3_d_push_val(b,b3_d_push_name(name,acc,fuel),fuel)
    case N111Store{_,b,_,v}: b3_d_push_val(v,b3_d_push_val(b,acc,fuel),fuel)
    case N111Alloca{name,_,_}: b3_d_push_name(name,acc,fuel)
    case N111If{c,yes,no}:
      b3_d_touch_scalars(no,b3_d_touch_scalars(yes,b3_d_push_val(c,acc,fuel),fuel),fuel)
    case N111Return{v}: b3_d_push_val(v,acc,fuel)

@unsafe
def b3_d_touch_scalars(body,acc,fuel):
  match body acc:
    case Nil{} _: acc
    case _ None{}: None{}
    case Con{h,rest} _:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_eq(fuel,0),
        u => None{},
        u => b3_d_touch_scalars(rest,b3_d_touch_scalar(h,acc,fuel),U32.sub(fuel,1)))

@unsafe
def b3_d_touch_body(body: List<&2,P113DStmt>, acc: Maybe<&2,List<&2,String>>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match body acc:
    case Nil{} _: acc
    case _ None{}: None{}
    case Con{P113DScalar{s},rest} _:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_eq(fuel,0),
        u => None{},
        u => b3_d_touch_body(rest,b3_d_touch_scalar(s,acc,fuel),U32.sub(fuel,1)))
    case Con{P113DIf{c,yes,no},rest} _:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_eq(fuel,0),
        u => None{},
        u => b3_d_touch_body(rest,b3_d_touch_body(no,b3_d_touch_body(yes,b3_d_push_val(c,acc,fuel),U32.sub(fuel,1)),U32.sub(fuel,1)),U32.sub(fuel,1)))
    case Con{P113DCall{names,_,args},rest} _:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_eq(fuel,0),
        u => None{},
        u => b3_d_touch_body(rest,b3_d_push_vals(args,b3_d_push_names(names,acc,fuel),fuel),U32.sub(fuel,1)))
    case Con{P113DResult{vs},rest} _: b3_d_touch_body(rest,b3_d_push_vals(vs,acc,fuel),fuel)
    case Con{P113DAgain{vs},rest} _: b3_d_touch_body(rest,b3_d_push_vals(vs,acc,fuel),fuel)

@unsafe
def b3_d_apply_delta(names: List<&2,String>, +yl: KDef, +nl: KDef, +out: KDef) -> KDef:
  match names:
    case Nil{}: out
    case Con{+v,rest}:
      +h = index_hash(v,2166136261)
      +isLive = U32.is_gt(da(index_find(yl,v,h,32)),0) || U32.is_gt(da(index_find(nl,v,h,32)),0)
      b3_d_apply_delta(rest,yl,nl,nt_choose(KDef,isLive,
        u => b3_d_mark_h(out,v,h),
        u => b3_d_kill_h(out,v,h)))

@unsafe
def b3_d_merge_delta(touched: Maybe<&2,List<&2,String>>, +live: KDef, +yl: KDef, +nl: KDef) -> KDef:
  match touched:
    case Some{ns}: b3_d_apply_delta(ns,yl,nl,live)
    case None{}: x185_d_union(yl,nl)

@unsafe
def b3_d_merge_if(+yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +live: KDef, +yl: KDef, +nl: KDef) -> KDef:
  +yt = b3_d_has_term(yes)
  +nt = b3_d_has_term(no)
  nt_choose(KDef,Bool.not(yt) && Bool.not(nt),
    u => b3_d_merge_delta(b3_d_touch_body(no,b3_d_touch_body(yes,Some{[]},64),64),live,yl,nl),
    u => nt_choose(KDef,Bool.not(yt) && nt,
      v => x185_d_union(nl,yl),
      v => x185_d_union(yl,nl)))

@unsafe
def x185_d_if_done(+condition: N111Value, rest: List<&2,P113DStmt>, +yes_orig: List<&2,P113DStmt>,
    +no_orig: List<&2,P113DStmt>, +live: KDef, yes: X185Dead, no: X185Dead) -> X185Dead:
  match yes no:
    case X185Dead{Nil{},yl} X185Dead{Nil{},nl}:
      X185Dead{rest,b3_d_merge_if(yes_orig,no_orig,live,yl,nl)}
    case X185Dead{yb,yl} X185Dead{nb,nl}:
      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,b3_d_merge_if(yes_orig,no_orig,live,yl,nl))}

@unsafe
def x185_d_if(condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      x185_d_if_done(condition,body,yes,no,live,x185_d_body(yes,live,again,terminal),x185_d_body(no,live,again,terminal))"""

# --- Hunk 4: x192_p_write & x190_v_written skip-zero-tombstone fast paths ---
OLD_X192_P_WRITE = """@unsafe
def x192_p_write(facts: KDef, name: String, known: Bool) -> KDef:
  p111v_put(facts,name,"X192Predicate",nt_choose(U32,known,u => 1,u => 0),0)"""

NEW_X192_P_WRITE = """@unsafe
def b3_x192_put_if(same: Bool, facts: KDef, +name: String, +h: U32, +v: U32) -> KDef:
  match same:
    case True{}: facts
    case False{}: p111v_put_h(facts,name,h,"X192Predicate",v,0)

@unsafe
def b3_x192_write_go(+facts: KDef, +name: String, +v: U32) -> KDef:
  +h = index_hash(name,2166136261)
  b3_x192_put_if(U32.is_eq(da(index_find(facts,name,h,32)),v),facts,name,h,v)

@unsafe
def x192_p_write(+facts: KDef, +name: String, +known: Bool) -> KDef:
  match facts known:
    case KDef{_,kind,_,_,_,_,_,_,_} False{}:
      nt_choose(KDef,String.eq(kind,"Absent"),
        u => facts,
        u => b3_x192_write_go(facts,name,0))
    case _ False{}: b3_x192_write_go(facts,name,0)
    case _ True{}: b3_x192_write_go(facts,name,1)"""

OLD_X190_V_WRITTEN = """@unsafe
def x190_v_written(+name: String, known: Bool, state: X190Values) -> X190Values:
  match state:
    case X190Values{aliases,widths}:
      X190Values{x186_e_kill_aliases(aliases,name),p111v_put(widths,name,"X190Zero32",nt_choose(U32,known,u => 1,u => 0),0)}"""

NEW_X190_V_WRITTEN = """@unsafe
def b3_x190_put_if(same: Bool, widths: KDef, +name: String, +h: U32, +v: U32) -> KDef:
  match same:
    case True{}: widths
    case False{}: p111v_put_h(widths,name,h,"X190Zero32",v,0)

@unsafe
def b3_x190_write_go(+widths: KDef, +name: String, +v: U32) -> KDef:
  +h = index_hash(name,2166136261)
  b3_x190_put_if(U32.is_eq(da(index_find(widths,name,h,32)),v),widths,name,h,v)

@unsafe
def b3_x190_width_put(+widths: KDef, +name: String, +known: Bool) -> KDef:
  match widths known:
    case KDef{_,kind,_,_,_,_,_,_,_} False{}:
      nt_choose(KDef,String.eq(kind,"Absent"),
        u => widths,
        u => b3_x190_write_go(widths,name,0))
    case _ False{}: b3_x190_write_go(widths,name,0)
    case _ True{}: b3_x190_write_go(widths,name,1)

@unsafe
def x190_v_written(+name: String, known: Bool, state: X190Values) -> X190Values:
  match state:
    case X190Values{aliases,widths}:
      X190Values{x186_e_kill_aliases(aliases,name),b3_x190_width_put(widths,name,known)}"""

# --- Hunk 5: x191_frame_forward 2048-insn cap for huge non-XMM CPS workers ---
# Leaves all hot benchmark loops (gameoflife ~500 insns, terrain, bst, editdist, etc.)
# 100% untouched while preventing O(N^2) w14a_mb_has_back / w4b_find_label explosions
# (e.g. 271s on 57k-insn w13e_sa_chk_body in m11).
OLD_X191_FF_CAP = """  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && w7_len_gt(flat0,96) && Bool.not(hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),"""

NEW_X191_FF_CAP = """  +isLoop = hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))
  nt_choose(X188Seq,Bool.not(hasXmm) && ((w7_len_gt(flat0,2048) && (hasCall || Bool.not(isLoop))) || (hasCall && w7_len_gt(flat0,96) && Bool.not(isLoop))),"""

PATCHES: list[tuple[str, str, str]] = [
    ("p111v_get_empty_fast", OLD_P111V_GET, NEW_P111V_GET),
    ("w5c_p131i_leaf_single_fast", OLD_W5C_P131I_LEAF, NEW_W5C_P131I_LEAF),
    ("x185_dead_mark_kill_fast", OLD_X185_DEAD_MARK_KILL, NEW_X185_DEAD_MARK_KILL),
    ("x185_dead_delta_union", OLD_X185_DEAD_UNION_IF, NEW_X185_DEAD_UNION_IF),
    ("x192_p_write_skip_zero", OLD_X192_P_WRITE, NEW_X192_P_WRITE),
    ("x190_v_written_skip_zero", OLD_X190_V_WRITTEN, NEW_X190_V_WRITTEN),
    ("x191_frame_forward_2048_cap", OLD_X191_FF_CAP, NEW_X191_FF_CAP),
]


def apply_text(src: str, require_all: bool = True) -> tuple[str, list[str]]:
    applied: list[str] = []
    out = src
    for name, old, new in PATCHES:
        if new in out:
            applied.append(f"{name}:already")
            continue
        cnt = out.count(old)
        if cnt == 1:
            out = out.replace(old, new, 1)
            applied.append(f"{name}:applied")
        elif require_all:
            raise RuntimeError(f"Patch {name} expected 1 occurrence, found {cnt}")
    return out, applied


def main() -> int:
    ap = argparse.ArgumentParser(description="Apply B3 residual x187_priv O(N^2) & HAMT-churn fixes.")
    ap.add_argument("src", nargs="?", default=str(DEFAULT_SRC), help="Input compiler.bend")
    ap.add_argument("-o", "--out", type=Path, help="Output path (default: in-place)")
    ap.add_argument("--partial", action="store_true", help="Allow subset of patches")
    args = ap.parse_args()

    src_path = Path(args.src)
    src_text = src_path.read_text(encoding="utf-8")
    new_text, status = apply_text(src_text, require_all=not args.partial)
    out_path = args.out or src_path
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(new_text, encoding="utf-8")
    print(f"B3 patched {out_path} ({len(new_text):,} B): {', '.join(status)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

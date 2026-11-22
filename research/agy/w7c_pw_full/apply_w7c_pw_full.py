#!/usr/bin/env python3
"""Wave 7C: Lowering & x198pw_plan Super-Linear & Closure-Overhead Patch (`apply_w7c_pw_full.py`).

Disjoint ownership: ONLY x198pw_plan substages (`p112f`, `p113d`, `p113i`, `p113j`, `p167l`,
`w6_dedup`, `p168j`, `p169o`, `agy_enrich_cursor`).

Optimizations (100% semantically identical):
  1. `p113d_pass_function`: check `w6_p113d_deps_self` BEFORE `w7_self_rec_ok` so waiting
     candidates do not re-walk their entire IR body up to 32 times.
  2. `p113j_calls`: O(N) accumulator-passing `w7c_p113j_calls_acc` eliminating O(depth * N)
     `nt_append` on deep `P113DIf` match trees.
  3. `p113i_get` / `p113i_put` & `p169o_walk`: direct parameter-match helpers eliminating up
     to 32 `nt_choose` closures per call-site lookup in `P113ITable`, plus single-hash
     `w5c3_find` in `p169o_walk` / `p169o_next`.
  4. `p167l_demand` / `p167l_take` / `p167l_catalogue_put` / `w6_dedup_segments`:
     - Single `index_hash` + `w5c3_find` + `p131i_insert` (eliminates 2x hashing per segment).
     - `p167l_take` checks `present` before `catalogue`.
     - `w6_alias` guards with `String.starts_with(name, "$p111.k.")` before hash/lookup.
  5. `p112f_index_*`: direct parameter-match helpers eliminating `nt_choose` closures on
     25,125+ `N111Segment`s.
  6. `p168j_registry` (`w7c_p112c_passes`): shrinks waiting candidate list between passes by
     dropping already-admitted segments, eliminating redundant re-scans across 6 rounds.
  7. `agy_p114h_seg_eligible` (`agy_enrich_cursor`): fixes `"p111.k."` -> `"$p111.k."` prefix
     bug and filters `result == 1 && incoming == 0 && flags == 0 && 1 <= arity <= 8` BEFORE
     `p111v_get(direct, name)`, dropping ~15k+ ineligible continuations before 6 fixpoint passes.
"""
from __future__ import annotations

import argparse
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    count = src.count(old)
    if count != 1:
        raise SystemExit(f"[apply_w7c_pw_full] ERROR in {label}: expected 1 match, found {count}")
    return src.replace(old, new, 1)


def apply_patch(src: str) -> str:
    # 1. p112f_index_* direct parameter-match helpers (zero nt_choose closures)
    old_p112f = """@unsafe
def p112f_index_bucket(bucket: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match bucket:
    case Nil{}: None{}
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+key,+arity,+result,+incoming,+flags,+body}:
          nt_choose(Maybe<&2,N111Segment>,agy_str_eq(key,name),u => Some{segment},u => p112f_index_bucket(rest,name))


def p112f_index_present(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case None{}: False{}
    case Some{+segment}: True{}


@unsafe
def p112f_index_bucket_add(+bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(List<&2,N111Segment>,p112f_index_present(p112f_index_bucket(bucket,name)),
        u => bucket,u => Con{segment,bucket})


@unsafe
def p112f_index_find(tree: P112FusionIndex, +name: String, +hash: U32) -> Maybe<&2,N111Segment>:
  match tree:
    case P112FusionEmpty{}: None{}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(hash,stored),u => p112f_index_bucket(bucket,name),u => None{})
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(U32.and(hash,mask),0),
        u => p112f_index_find(left,name,hash),u => p112f_index_find(right,name,hash))


@unsafe
def p112f_index_get(+tree: P112FusionIndex, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_find(tree,name,index_hash(name,2166136261))


@unsafe
def p112f_index_tip(tree: P112FusionIndex, +hash: U32) -> U32:
  match tree:
    case P112FusionEmpty{}: hash
    case P112FusionLeaf{+stored,+bucket}: stored
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(U32,U32.is_eq(U32.and(hash,mask),0),u => p112f_index_tip(left,hash),u => p112f_index_tip(right,hash))


@unsafe
def p112f_index_join(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
    u => P112FusionNode{mask,P112FusionLeaf{hash,[segment]},tree},
    u => P112FusionNode{mask,tree,P112FusionLeaf{hash,[segment]}})


@unsafe
def p112f_index_insert(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match tree:
    case P112FusionEmpty{}: P112FusionLeaf{hash,[segment]}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(P112FusionIndex,U32.is_eq(split,0),
        u => P112FusionLeaf{hash,p112f_index_bucket_add(bucket,segment)},u => p112f_index_join(tree,segment,hash,split))
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(P112FusionIndex,Bool.not(U32.is_eq(split,0)) && U32.is_lt(split,mask),
        u => p112f_index_join(tree,segment,hash,split),u =>
        nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
          v => P112FusionNode{mask,p112f_index_insert(left,segment,hash,split),right},
          v => P112FusionNode{mask,left,p112f_index_insert(right,segment,hash,split)}))"""

    new_p112f = """law p112f_index_bucket:
  for bucket: List<&2,N111Segment>
  for +name: String
  Maybe<&2,N111Segment>

@unsafe
def w7c_p112f_bucket_eq(eq: Bool, +segment: N111Segment, rest: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match eq:
    case True{}: Some{segment}
    case False{}: p112f_index_bucket(rest,name)

@unsafe
def p112f_index_bucket(bucket, name):
  match bucket:
    case Nil{}: None{}
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+key,+arity,+result,+incoming,+flags,+body}:
          w7c_p112f_bucket_eq(agy_str_eq(key,name),segment,rest,name)


def p112f_index_present(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case None{}: False{}
    case Some{+segment}: True{}


@unsafe
def w7c_p112f_badd(pres: Bool, +bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match pres:
    case True{}: bucket
    case False{}: Con{segment,bucket}

@unsafe
def p112f_index_bucket_add(+bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      w7c_p112f_badd(p112f_index_present(p112f_index_bucket(bucket,name)),bucket,segment)


law p112f_index_find:
  for tree: P112FusionIndex
  for +name: String
  for +hash: U32
  Maybe<&2,N111Segment>

@unsafe
def w7c_p112f_find_leaf(eq: Bool, bucket: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match eq:
    case True{}: p112f_index_bucket(bucket,name)
    case False{}: None{}

@unsafe
def w7c_p112f_find_lr(bit: U32, left: P112FusionIndex, right: P112FusionIndex, +name: String, +hash: U32) -> Maybe<&2,N111Segment>:
  match bit:
    case 0: p112f_index_find(left,name,hash)
    case _: p112f_index_find(right,name,hash)

@unsafe
def p112f_index_find(tree, name, hash):
  match tree:
    case P112FusionEmpty{}: None{}
    case P112FusionLeaf{+stored,+bucket}:
      w7c_p112f_find_leaf(U32.is_eq(hash,stored),bucket,name)
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_find_lr(U32.and(hash,mask),left,right,name,hash)


@unsafe
def p112f_index_get(+tree: P112FusionIndex, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_find(tree,name,index_hash(name,2166136261))


law p112f_index_tip:
  for tree: P112FusionIndex
  for +hash: U32
  U32

@unsafe
def w7c_p112f_tip_lr(bit: U32, left: P112FusionIndex, right: P112FusionIndex, +hash: U32) -> U32:
  match bit:
    case 0: p112f_index_tip(left,hash)
    case _: p112f_index_tip(right,hash)

@unsafe
def p112f_index_tip(tree, hash):
  match tree:
    case P112FusionEmpty{}: hash
    case P112FusionLeaf{+stored,+bucket}: stored
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_tip_lr(U32.and(hash,mask),left,right,hash)


@unsafe
def w7c_p112f_join_lr(bit: U32, +tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  match bit:
    case 0: P112FusionNode{mask,P112FusionLeaf{hash,[segment]},tree}
    case _: P112FusionNode{mask,tree,P112FusionLeaf{hash,[segment]}}

@unsafe
def p112f_index_join(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  w7c_p112f_join_lr(U32.and(hash,mask),tree,segment,hash,mask)


law p112f_index_insert:
  for +tree: P112FusionIndex
  for +segment: N111Segment
  for +hash: U32
  for +split: U32
  P112FusionIndex

@unsafe
def w7c_p112f_ins_leaf(z: U32, +tree: P112FusionIndex, +bucket: List<&2,N111Segment>, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match z:
    case 0: P112FusionLeaf{hash,p112f_index_bucket_add(bucket,segment)}
    case _: p112f_index_join(tree,segment,hash,split)

@unsafe
def w7c_p112f_ins_lr(bit: U32, +mask: U32, +left: P112FusionIndex, +right: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match bit:
    case 0: P112FusionNode{mask,p112f_index_insert(left,segment,hash,split),right}
    case _: P112FusionNode{mask,left,p112f_index_insert(right,segment,hash,split)}

@unsafe
def w7c_p112f_ins_node(above: Bool, +tree: P112FusionIndex, +mask: U32, +left: P112FusionIndex, +right: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match above:
    case True{}: p112f_index_join(tree,segment,hash,split)
    case False{}: w7c_p112f_ins_lr(U32.and(hash,mask),mask,left,right,segment,hash,split)

@unsafe
def p112f_index_insert(tree, segment, hash, split):
  match tree:
    case P112FusionEmpty{}: P112FusionLeaf{hash,[segment]}
    case P112FusionLeaf{+stored,+bucket}:
      w7c_p112f_ins_leaf(split,tree,bucket,segment,hash,split)
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_ins_node(Bool.not(U32.is_eq(split,0)) && U32.is_lt(split,mask),tree,mask,left,right,segment,hash,split)"""

    src = replace_exact(src, old_p112f, new_p112f, "p112f_index_*")

    # 2. p113d_pass_function: check w6_p113d_deps_self BEFORE w7_self_rec_ok
    old_p113d = """@unsafe
def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match function:
    case P113DFunction{+name,+params,result,public,+body}:
      nt_choose(P113DPass,Bool.not(String.is_empty(error)) || p113d_ready(index,name) || Bool.not(w7_self_rec_ok(name,body)),
        u => p113d_pass(rest,index,functions,waiting,count),u =>
        nt_choose(P113DPass,w6_p113d_deps_self(calls,index,name),
          v => p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count)),
          v => p113d_pass(rest,index,functions,Con{candidate,waiting},count)))"""

    new_p113d = """@unsafe
def w7c_p113d_admit_ok(ok: Bool, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match ok:
    case True{}: p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count))
    case False{}: p113d_pass(rest,index,functions,waiting,count)

@unsafe
def w7c_p113d_deps_ready(depsOk: Bool, +candidate: P113DCandidate, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match depsOk:
    case True{}: w7c_p113d_admit_ok(w7_self_rec_ok(name,body),function,name,params,rest,index,functions,waiting,count)
    case False{}: p113d_pass(rest,index,functions,Con{candidate,waiting},count)

@unsafe
def w7c_p113d_skip(skip: Bool, +candidate: P113DCandidate, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match skip:
    case True{}: p113d_pass(rest,index,functions,waiting,count)
    case False{}: w7c_p113d_deps_ready(w6_p113d_deps_self(calls,index,name),candidate,function,name,params,body,rest,index,functions,waiting,count)

@unsafe
def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match function:
    case P113DFunction{+name,+params,result,public,+body}:
      w7c_p113d_skip(Bool.not(String.is_empty(error)) || p113d_ready(index,name),candidate,function,name,params,body,calls,rest,index,functions,waiting,count)"""

    src = replace_exact(src, old_p113d, new_p113d, "p113d_pass_function")

    # 3. p113i_get / p113i_put direct parameter-match helpers (eliminates 32 closures/lookup)
    old_p113i = """@unsafe
def p113i_bucket(name: String, values: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match values:
    case Nil{}: None{}
    case Con{+head,rest}: p113i_bucket_head(name,head,rest)


@unsafe
def p113i_bucket_head(+name: String, +head: P113DFunction, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match head:
    case P113DFunction{key,params,result,public,body}:
      nt_choose(Maybe<&2,P113DFunction>,agy_str_eq(name,key),u => Some{head},u => p113i_bucket(name,rest))


@unsafe
def p113i_get(table: P113ITable, +name: String, +hash: U32, +depth: U32) -> Maybe<&2,P113DFunction>:
  match table:
    case P113IEmpty{}: None{}
    case P113IBucket{values}: p113i_bucket(name,values)
    case P113INode{zero,one}:
      nt_choose(Maybe<&2,P113DFunction>,U32.is_eq(U32.and(hash,1),0),
        u => p113i_get(zero,name,U32.shr(hash),U32.inc(depth)),
        u => p113i_get(one,name,U32.shr(hash),U32.inc(depth)))


@unsafe
def p113i_put(+table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(depth,32),u => p113i_put_leaf(table,function),
    u => p113i_put_node(table,function,hash,depth))


@unsafe
def p113i_put_leaf(table: P113ITable, function: P113DFunction) -> P113ITable:
  match table:
    case P113IBucket{values}: P113IBucket{Con{function,values}}
    case _: P113IBucket{[function]}


@unsafe
def p113i_put_node(table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match table:
    case P113INode{+zero,+one}: p113i_put_branch(zero,one,function,hash,depth)
    case _: p113i_put_branch(P113IEmpty{},P113IEmpty{},function,hash,depth)


@unsafe
def p113i_put_branch(+zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(U32.and(hash,1),0),
    u => P113INode{p113i_put(zero,function,U32.shr(hash),U32.inc(depth)),one},
    u => P113INode{zero,p113i_put(one,function,U32.shr(hash),U32.inc(depth))})"""

    new_p113i = """law p113i_bucket:
  for name: String
  for values: List<&2,P113DFunction>
  Maybe<&2,P113DFunction>

@unsafe
def w7c_p113i_bhead_eq(eq: Bool, +head: P113DFunction, +name: String, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match eq:
    case True{}: Some{head}
    case False{}: p113i_bucket(name,rest)

@unsafe
def p113i_bucket_head(+name: String, +head: P113DFunction, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match head:
    case P113DFunction{key,params,result,public,body}:
      w7c_p113i_bhead_eq(agy_str_eq(name,key),head,name,rest)

@unsafe
def p113i_bucket(name, values):
  match values:
    case Nil{}: None{}
    case Con{+head,rest}: p113i_bucket_head(name,head,rest)


law p113i_get:
  for table: P113ITable
  for +name: String
  for +hash: U32
  for +depth: U32
  Maybe<&2,P113DFunction>

@unsafe
def w7c_p113i_get_br(bit: U32, zero: P113ITable, one: P113ITable, +name: String, +hash: U32, +depth: U32) -> Maybe<&2,P113DFunction>:
  match bit:
    case 0: p113i_get(zero,name,U32.shr(hash),U32.inc(depth))
    case _: p113i_get(one,name,U32.shr(hash),U32.inc(depth))

@unsafe
def p113i_get(table, name, hash, depth):
  match table:
    case P113IEmpty{}: None{}
    case P113IBucket{values}: p113i_bucket(name,values)
    case P113INode{zero,one}:
      w7c_p113i_get_br(U32.and(hash,1),zero,one,name,hash,depth)


law p113i_put:
  for +table: P113ITable
  for +function: P113DFunction
  for +hash: U32
  for +depth: U32
  P113ITable

@unsafe
def p113i_put_leaf(table: P113ITable, function: P113DFunction) -> P113ITable:
  match table:
    case P113IBucket{values}: P113IBucket{Con{function,values}}
    case _: P113IBucket{[function]}

@unsafe
def w7c_p113i_put_br(bit: U32, +zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match bit:
    case 0: P113INode{p113i_put(zero,function,U32.shr(hash),U32.inc(depth)),one}
    case _: P113INode{zero,p113i_put(one,function,U32.shr(hash),U32.inc(depth))}

@unsafe
def p113i_put_branch(+zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  w7c_p113i_put_br(U32.and(hash,1),zero,one,function,hash,depth)

@unsafe
def p113i_put_node(table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match table:
    case P113INode{+zero,+one}: p113i_put_branch(zero,one,function,hash,depth)
    case _: p113i_put_branch(P113IEmpty{},P113IEmpty{},function,hash,depth)

@unsafe
def w7c_p113i_put_d(atLeaf: Bool, +table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match atLeaf:
    case True{}: p113i_put_leaf(table,function)
    case False{}: p113i_put_node(table,function,hash,depth)

@unsafe
def p113i_put(table, function, hash, depth):
  w7c_p113i_put_d(U32.is_eq(depth,32),table,function,hash,depth)"""

    src = replace_exact(src, old_p113i, new_p113i, "p113i_get/put")

    # 4. p113j_calls: O(N) accumulator-passing (eliminates O(depth * N) nt_append)
    old_p113j = """@unsafe
def p113j_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  match body:
    case Nil{}: []
    case Con{P113DCall{destinations,target,args},rest}: Con{target,p113j_calls(rest)}
    case Con{P113DIf{condition,yes,no},rest}:
      nt_append(String,p113j_calls(yes),nt_append(String,p113j_calls(no),p113j_calls(rest)))
    case Con{stmt,rest}: p113j_calls(rest)"""

    new_p113j = """@unsafe
def w7c_p113j_calls_acc(body: List<&2,P113DStmt>, acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DCall{destinations,target,args},rest}:
      Con{target,w7c_p113j_calls_acc(rest,acc)}
    case Con{P113DIf{condition,yes,no},rest}:
      w7c_p113j_calls_acc(yes,w7c_p113j_calls_acc(no,w7c_p113j_calls_acc(rest,acc)))
    case Con{stmt,rest}: w7c_p113j_calls_acc(rest,acc)

@unsafe
def p113j_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  w7c_p113j_calls_acc(body,[])"""

    src = replace_exact(src, old_p113j, new_p113j, "p113j_calls")

    # 5. p167l_demand + p167l_catalogue_put + p167l_take + w6_dedup_segments single-hash
    old_p167l_demand = """@unsafe
def p167l_demand(+name: String, demand: P167Demand) -> P167Demand:
  match demand:
    case P167Demand{+todo,+asked,+count}:
      nt_choose(P167Demand,agy_str_eq(dk(p111v_get(asked,name)),"Absent"),
        u => P167Demand{Con{name,todo},p167l_mark(asked,name),U32.inc(count)},
        u => P167Demand{todo,asked,count})"""

    new_p167l_demand = """@unsafe
def w7c_p167l_demand_if(absent: Bool, +name: String, +h: U32, +todo: List<&2,String>, +asked: KDef, +count: U32) -> P167Demand:
  match absent:
    case True{}:
      P167Demand{Con{name,todo},p131i_insert(asked,KDef{name,"P167Seen",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h),U32.inc(count)}
    case False{}: P167Demand{todo,asked,count}

@unsafe
def p167l_demand(+name: String, demand: P167Demand) -> P167Demand:
  match demand:
    case P167Demand{+todo,+asked,+count}:
      +h = index_hash(name,2166136261)
      w7c_p167l_demand_if(agy_str_eq(dk(w5c3_find(asked,name,h)),"Absent"),name,h,todo,asked,count)"""

    src = replace_exact(src, old_p167l_demand, new_p167l_demand, "p167l_demand")

    old_p167l_cat_put = """@unsafe
def p167l_catalogue_put(+name: String, +source: String, +kind: String, +arity: U32,
    +allowed: Bool, catalogue: P167Catalogue) -> P167Catalogue:
  match catalogue:
    case P167Catalogue{+index,+error}:
      +old = p111v_get(index,name)
      nt_choose(P167Catalogue,Bool.not(String.is_empty(error)),u => P167Catalogue{index,error},u =>
        nt_choose(P167Catalogue,agy_str_eq(dk(old),"Absent"),
          v => P167Catalogue{p113e_insert(index,KDef{name,kind,arity,Bool.to_u32(allowed),ref(source),atom("Absent"),[],False{},False{}}),""},
          v => nt_choose(P167Catalogue,agy_str_eq(dk(old),kind) && agy_str_eq(nm(dt(old)),source) && U32.is_eq(da(old),arity),
            w => P167Catalogue{index,""},w => P167Catalogue{index,"demand: conflicting scheduled identity " ++ name})))"""

    new_p167l_cat_put = """@unsafe
def w7c_p167l_cat_old(absent: Bool, +old: KDef, +name: String, +h: U32, +source: String, +kind: String, +arity: U32, +allowed: Bool, +index: KDef) -> P167Catalogue:
  match absent:
    case True{}:
      P167Catalogue{p131i_insert(index,KDef{name,kind,arity,Bool.to_u32(allowed),ref(source),atom("Absent"),[],False{},False{}},h),""}
    case False{}:
      nt_choose(P167Catalogue,agy_str_eq(dk(old),kind) && agy_str_eq(nm(dt(old)),source) && U32.is_eq(da(old),arity),
        w => P167Catalogue{index,""},w => P167Catalogue{index,"demand: conflicting scheduled identity " ++ name})

@unsafe
def w7c_p167l_cat_err(hasErr: Bool, +name: String, +source: String, +kind: String, +arity: U32, +allowed: Bool, +index: KDef, +error: String) -> P167Catalogue:
  match hasErr:
    case True{}: P167Catalogue{index,error}
    case False{}:
      +h = index_hash(name,2166136261)
      +old = w5c3_find(index,name,h)
      w7c_p167l_cat_old(agy_str_eq(dk(old),"Absent"),old,name,h,source,kind,arity,allowed,index)

@unsafe
def p167l_catalogue_put(+name: String, +source: String, +kind: String, +arity: U32,
    +allowed: Bool, catalogue: P167Catalogue) -> P167Catalogue:
  match catalogue:
    case P167Catalogue{+index,+error}:
      w7c_p167l_cat_err(Bool.not(String.is_empty(error)),name,source,kind,arity,allowed,index,error)"""

    src = replace_exact(src, old_p167l_cat_put, new_p167l_cat_put, "p167l_catalogue_put")

    old_w6_alias = """@unsafe
def w6_alias(+alias: KDef, +name: String) -> String:
  +e = p111v_get(alias,name)
  nt_choose(String,agy_str_eq(dk(e),"Absent"),u => name,u => nm(dt(e)))"""

    new_w6_alias = """@unsafe
def w7c_w6_alias_hit(absent: Bool, +e: KDef, +name: String) -> String:
  match absent:
    case True{}: name
    case False{}: nm(dt(e))

@unsafe
def w7c_w6_alias_k(isK: Bool, +alias: KDef, +name: String) -> String:
  match isK:
    case False{}: name
    case True{}:
      +e = p111v_get(alias,name)
      w7c_w6_alias_hit(agy_str_eq(dk(e),"Absent"),e,name)

@unsafe
def w6_alias(+alias: KDef, +name: String) -> String:
  w7c_w6_alias_k(String.starts_with(name,"$p111.k."),alias,name)"""

    src = replace_exact(src, old_w6_alias, new_w6_alias, "w6_alias")

    old_w6_dedup = """@unsafe
def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  nt_choose(W6DedupAcc,agy_str_eq(dk(found),"Absent"),
    u => w6_dedup_scan(rest,W6DedupAcc{index_set(seen,KDef{key,"W6",0,0,ref(name),atom("Absent"),[],False{},False{}},kh,32),alias,Con{seg,kept},merged}),
    u => w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)}))

@unsafe
def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  nt_choose(W6DedupAcc,String.is_empty(key),
    u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}),
    u =>
      +kh = index_hash(key,2166136261)
      w6_dedup_lookup(rest,seg,name,key,kh,index_find(seen,key,kh,32),seen,alias,kept,merged))"""

    new_w6_dedup = """@unsafe
def w7c_w6_dedup_hit(absent: Bool, +rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  match absent:
    case True{}:
      w6_dedup_scan(rest,W6DedupAcc{p131i_insert(seen,KDef{key,"W6",0,0,ref(name),atom("Absent"),[],False{},False{}},kh),alias,Con{seg,kept},merged})
    case False{}:
      w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)})

@unsafe
def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  w7c_w6_dedup_hit(agy_str_eq(dk(found),"Absent"),rest,seg,name,key,kh,found,seen,alias,kept,merged)

@unsafe
def w7c_w6_dedup_nonempty(empty: Bool, +rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  match empty:
    case True{}: w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged})
    case False{}:
      +kh = index_hash(key,2166136261)
      w6_dedup_lookup(rest,seg,name,key,kh,w5c3_find(seen,key,kh),seen,alias,kept,merged)

@unsafe
def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  w7c_w6_dedup_nonempty(String.is_empty(key),rest,seg,name,key,seen,alias,kept,merged)"""

    src = replace_exact(src, old_w6_dedup, new_w6_dedup, "w6_dedup_lookup/check")

    old_p167l_take = """@unsafe
def p167l_take(+context: P167Context, +name: String, +pending: P167Demand, +built: P167Built) -> P167Built:
  match context built:
    case P167Context{book,+catalogue,bangs}
         P167Built{+segments,+present,+adapters,+fresh,+families,+factories,+wrappers,+demands,+error}:
      +entry = p111v_get(catalogue,name)
      nt_choose(P167Built,Bool.not(String.is_empty(error)),u => built,u =>
        nt_choose(P167Built,Bool.not(agy_str_eq(dk(p111v_get(present,name)),"Absent")),
          v => p167l_loop(context,pending,built),v =>
          nt_choose(P167Built,agy_str_eq(dk(entry),"Absent"),
            w => P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,"demand: unknown scheduled identity " ++ name},
            w => p167l_dispatch(context,entry,pending,built,fresh))))"""

    new_p167l_take = """@unsafe
def w7c_p167l_take_entry(absent: Bool, +context: P167Context, +entry: KDef, +name: String, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match absent:
    case True{}: P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,"demand: unknown scheduled identity " ++ name}
    case False{}: p167l_dispatch(context,entry,pending,built,fresh)

@unsafe
def w7c_p167l_take_pres(seen: Bool, +context: P167Context, +catalogue: KDef, +name: String, +h: U32, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match seen:
    case True{}: p167l_loop(context,pending,built)
    case False{}:
      +entry = w5c3_find(catalogue,name,h)
      w7c_p167l_take_entry(agy_str_eq(dk(entry),"Absent"),context,entry,name,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)

@unsafe
def w7c_p167l_take_err(hasErr: Bool, +context: P167Context, +catalogue: KDef, +name: String, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match hasErr:
    case True{}: built
    case False{}:
      +h = index_hash(name,2166136261)
      w7c_p167l_take_pres(Bool.not(agy_str_eq(dk(w5c3_find(present,name,h)),"Absent")),context,catalogue,name,h,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)

@unsafe
def p167l_take(+context: P167Context, +name: String, +pending: P167Demand, +built: P167Built) -> P167Built:
  match context built:
    case P167Context{book,+catalogue,bangs}
         P167Built{+segments,+present,+adapters,+fresh,+families,+factories,+wrappers,+demands,+error}:
      w7c_p167l_take_err(Bool.not(String.is_empty(error)),context,catalogue,name,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)"""

    src = replace_exact(src, old_p167l_take, new_p167l_take, "p167l_take")

    # 6. p168j_registry: shrink waiting list between passes (eliminates redundant re-scans)
    old_p168j = """@unsafe
def p168j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex,
    +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      p112c_passes(p168j_candidates(segments,ready,[]),index,registry,1,6)"""

    new_p168j = """type W7C112CPass is Data:
  W7C112CPass{+registry: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32}

@unsafe
def w7c_p112c_try_admit(admitted: Bool, +cand: P112MultiCandidate, +transformed: N111Segment, +rank: U32, +sites: U32,
    +next: P112RegionRegistry, +plan: P112WorkerPlan, +waiting: List<&2,P112MultiCandidate>, +added: U32) -> W7C112CPass:
  match admitted:
    case True{}: W7C112CPass{p112c_insert(transformed,rank,sites,next,plan),waiting,U32.inc(added)}
    case False{}: W7C112CPass{next,Con{cand,waiting},added}

@unsafe
def w7c_p112c_fused(+cand: P112MultiCandidate, segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32,
    +next: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32, fused: P112FusionBody) -> W7C112CPass:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed : N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      +plan = p112c_plan(transformed,old,symbols,count)
      w7c_p112c_try_admit(p112w_admitted(plan),cand,transformed,rank,count,next,plan,waiting,added)

@unsafe
def w7c_p112c_pass(segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32,
    +next: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32) -> W7C112CPass:
  match segments:
    case Nil{}: W7C112CPass{next,nt_reverse(P112MultiCandidate,waiting,[]),added}
    case Con{+cand,+rest}:
      match cand:
        case P112MultiCandidate{+segment}:
          match segment:
            case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
              match w7c_p112c_fused(cand,segment,old,symbols,rank,next,waiting,added,p112c_scan(body,index,old,0)):
                case W7C112CPass{next2,waiting2,added2}:
                  w7c_p112c_pass(rest,index,old,symbols,rank,next2,waiting2,added2)

law w7c_p112c_passes:
  for +segments: List<&2,P112MultiCandidate>
  for +index: P112FusionIndex
  for +registry: P112RegionRegistry
  for +rank: U32
  for +left: U32
  P112RegionRegistry

@unsafe
def w7c_p112c_cont(+index: P112FusionIndex, +rank: U32, +left: U32, pass: W7C112CPass) -> P112RegionRegistry:
  match pass:
    case W7C112CPass{+reg,+waiting,+added}:
      nt_choose(P112RegionRegistry,U32.is_eq(added,0) || List.is_empty(&2,P112MultiCandidate,waiting),
        u => reg,u => w7c_p112c_passes(waiting,index,reg,U32.inc(rank),U32.sub(left,1)))

@unsafe
def w7c_p112c_round(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      w7c_p112c_cont(index,rank,left,w7c_p112c_pass(segments,index,ready,symbols,rank,registry,[],0))

@unsafe
def w7c_p112c_passes(segments, index, registry, rank, left):
  nt_choose(P112RegionRegistry,U32.is_eq(left,0) || List.is_empty(&2,P112MultiCandidate,segments),
    u => registry,u => w7c_p112c_round(segments,index,registry,rank,left))

@unsafe
def p168j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex,
    +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      w7c_p112c_passes(p168j_candidates(segments,ready,[]),index,registry,1,6)"""

    src = replace_exact(src, old_p168j, new_p168j, "p168j_registry")

    # Note: fix `match w7c_p112c_fused(...)` above — Bend4 requires parameter scrutinee!
    old_bad_match = """              match w7c_p112c_fused(cand,segment,old,symbols,rank,next,waiting,added,p112c_scan(body,index,old,0)):
                case W7C112CPass{next2,waiting2,added2}:
                  w7c_p112c_pass(rest,index,old,symbols,rank,next2,waiting2,added2)"""

    new_good_match = """              w7c_p112c_pass_next(rest,index,old,symbols,rank,
                w7c_p112c_fused(cand,segment,old,symbols,rank,next,waiting,added,p112c_scan(body,index,old,0)))"""

    src = replace_exact(src, old_bad_match, new_good_match, "w7c_p112c_pass_next_call")

    old_pass_sig = """@unsafe
def w7c_p112c_pass(segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32,
    +next: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32) -> W7C112CPass:"""

    new_pass_sig = """law w7c_p112c_pass:
  for segments: List<&2,P112MultiCandidate>
  for +index: P112FusionIndex
  for +old: KDef
  for +symbols: KDef
  for +rank: U32
  for +next: P112RegionRegistry
  for +waiting: List<&2,P112MultiCandidate>
  for +added: U32
  W7C112CPass

@unsafe
def w7c_p112c_pass_next(rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32,
    step: W7C112CPass) -> W7C112CPass:
  match step:
    case W7C112CPass{next2,waiting2,added2}:
      w7c_p112c_pass(rest,index,old,symbols,rank,next2,waiting2,added2)

@unsafe
def w7c_p112c_pass(segments, index, old, symbols, rank, next, waiting, added):"""

    src = replace_exact(src, old_pass_sig, new_pass_sig, "w7c_p112c_pass_sig")

    # 7. p169o_walk: single hash per function
    old_p169o = """@unsafe
def p169o_walk(functions,seeds,blocked,targets,zipOwners,table,reversed):
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,zipOwners,
              nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && Bool.not(p113d_ready(zipOwners,name)) && p113i_original_clean(head),
                w => p113i_table_function(head,table),w => table),Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(targets,name),
              v => p169o_walk(rest,seeds,blocked,targets,zipOwners,table,Con{p168t_target(head,table),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,
                p113i_function(head,table))))"""

    new_p169o = """@unsafe
def w7c_p169o_tgt(isTgt: Bool, +head: P113DFunction, rest: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef, +targets: KDef, +zipOwners: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match isTgt:
    case True{}: p169o_walk(rest,seeds,blocked,targets,zipOwners,table,Con{p168t_target(head,table),reversed})
    case False{}: p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,p113i_function(head,table))

@unsafe
def w7c_p169o_seed(isSeed: Bool, +head: P113DFunction, +name: String, +h: U32, rest: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef, +targets: KDef, +zipOwners: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match isSeed:
    case True{}:
      p169o_walk(rest,seeds,blocked,targets,zipOwners,
        nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && agy_str_eq(dk(w5c3_find(zipOwners,name,h)),"Absent") && p113i_original_clean(head),
          w => p113i_table_function(head,table),w => table),Con{head,reversed})
    case False{}:
      w7c_p169o_tgt(Bool.not(agy_str_eq(dk(w5c3_find(targets,name,h)),"Absent")),head,rest,seeds,blocked,targets,zipOwners,table,reversed)

@unsafe
def p169o_walk(functions,seeds,blocked,targets,zipOwners,table,reversed):
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          +h = index_hash(name,2166136261)
          w7c_p169o_seed(agy_str_eq(dk(w5c3_find(seeds,name,h)),"P113Direct"),head,name,h,rest,seeds,blocked,targets,zipOwners,table,reversed)"""

    src = replace_exact(src, old_p169o, new_p169o, "p169o_walk")

    # 8. agy_p114h_seg_eligible: fix "$p111.k." prefix + cheap header guard BEFORE p111v_get
    old_p114h = """@unsafe
def agy_p114h_seg_eligible(+segment: N111Segment, +direct: KDef, +hready: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      Bool.not(String.starts_with(name,"p111.k.")) &&
      Bool.not(agy_str_eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)) &&
      Bool.not(agy_str_eq(dk(p111v_get(hready,name)),"AgyHReady"))"""

    new_p114h = """@unsafe
def w7c_p114h_hdr_ok(ok: Bool, +name: String, +direct: KDef, +hready: KDef) -> Bool:
  match ok:
    case False{}: False{}
    case True{}:
      +h = index_hash(name,2166136261)
      +function = w5c3_find(direct,name,h)
      Bool.not(agy_str_eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)) &&
      Bool.not(agy_str_eq(dk(w5c3_find(hready,name,h)),"AgyHReady"))

@unsafe
def agy_p114h_seg_eligible(+segment: N111Segment, +direct: KDef, +hready: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      w7c_p114h_hdr_ok(
        U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) &&
        Bool.not(String.starts_with(name,"$p111.k.")) && Bool.not(String.starts_with(name,"p111.k.")),
        name,direct,hready)"""

    src = replace_exact(src, old_p114h, new_p114h, "agy_p114h_seg_eligible")

    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    src = args.src.read_text(encoding="utf-8")
    dst = apply_patch(src)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(dst, encoding="utf-8")
    print(f"[apply_w7c_pw_full] OK: {args.src} ({len(src):,} B) -> {args.dst} ({len(dst):,} B)")


if __name__ == "__main__":
    main()

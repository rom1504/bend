#!/usr/bin/env python3
"""Wave 5B C1: Backend & RegAlloc Compile-Speed Killer.

Composable, 100% bit-exact backend compile-time optimizations on top of
wave5a_unified/compiler.bend:

  1. agy_f32_try_direct fast pre-guard: skip 8-pass optimization pipeline when
     body lacks both P113DAgain and p111_rt_op call (~760 ms saved).
  2. CSE (x186_*) zero-closure Patricia tries + in-place trie pruning in
     x186_e_written (skip unchanged rebuilds; prune leaves without re-hashing)
     (~1.2 s saved).
  3. w4b_reg_dead + w4b_copy_peep + w5_gpr_peep + w4b_has_*_to:
     - O(log L) Patricia trie W5BLblTrie for label lookup in w4b_reg_dead
     - Zero-closure w4b_reg_dead + O(1) first-char dispatch for op classifiers
     - Direct 1-scrutinee instruction pre-filtering in w4b_copy_peep & w5_gpr_peep
     - Idempotent skip-if-unchanged for 2nd pass of w4b_copy_peep
     - Zero-allocation w4b_has_jmp_to / w4b_has_any_branch_to / w4b_has_non_jmp_to
  4. x190_l_edges zero-closure + early-exit fast path in RegAlloc liveness.
  5. x185_d_union zero-closure hash-preserving KDef insertion + x185_copy_write
     saturation fast-skip.
  6. x187_e_prefix / x187_e_mem / x187_build_seq_work zero-closure fast encoding.

Usage:
  python3 -B research/agy/wave5b_c1/apply_w5b_c1.py \
    --src selfhost/build/agy/wave5a_unified/compiler.bend \
    --dst selfhost/build/agy/wave5b_c1/compiler.bend
"""

import argparse
from pathlib import Path


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def replace_optional(text: str, old: str, new: str, label: str, require: str = "") -> str:
    if require and require not in text:
        print(f"  [W5B-C1] skipping {label} (missing prerequisite {require})")
        return text
    cnt = text.count(old)
    if cnt == 0:
        print(f"  [W5B-C1] skipping {label} (upgraded by earlier pass)")
        return text
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def apply_patches(src: str) -> str:
    # ------------------------------------------------------------------
    # 1. agy_f32_try_direct fast pre-guard
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def agy_f32_try_direct(+function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      nt_choose(X181Output,U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_f32_try_run(function,p113e_symbol(name),Con{"state",x181_param_names(params)},body,ids),
        u => x181_direct(function,ids))""",
        """@unsafe
def w5b_or_if(b: Bool, +bit: U32, +acc: U32) -> U32:
  match b:
    case True{}: U32.or(acc,bit)
    case False{}: acc

law w5b_f32_scan_scalars:
  for body: List<&2,N111Stmt>
  for +acc: U32
  U32

@unsafe
def w5b_f32_sc_cont(+a1: U32, rest: List<&2,N111Stmt>) -> U32:
  match a1:
    case 3: 3
    case _: w5b_f32_scan_scalars(rest,a1)

@unsafe
def w5b_f32_scan_scalar(stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111Call{_,_,sym,_}: w5b_or_if(String.eq(sym,"p111_rt_op"),2,acc)
    case N111If{_,yes,no}: w5b_f32_sc_cont(w5b_f32_scan_scalars(yes,acc),no)
    case _: acc

@unsafe
def w5b_f32_scan_scalars(body, acc):
  match body:
    case Nil{}: acc
    case Con{s,rest}: w5b_f32_sc_cont(w5b_f32_scan_scalar(s,acc),rest)

law w5b_f32_scan_body:
  for body: List<&2,P113DStmt>
  for +acc: U32
  U32

@unsafe
def w5b_f32_bd_cont(+a1: U32, rest: List<&2,P113DStmt>) -> U32:
  match a1:
    case 3: 3
    case _: w5b_f32_scan_body(rest,a1)

@unsafe
def w5b_f32_scan_step(st: P113DStmt, rest: List<&2,P113DStmt>, +acc: U32) -> U32:
  match st:
    case P113DAgain{_}: w5b_f32_bd_cont(U32.or(acc,1),rest)
    case P113DScalar{s}: w5b_f32_bd_cont(w5b_f32_scan_scalar(s,acc),rest)
    case P113DIf{_,yes,no}: w5b_f32_bd_cont(w5b_f32_bd_cont(w5b_f32_scan_body(yes,acc),no),rest)
    case _: w5b_f32_scan_body(rest,acc)

@unsafe
def w5b_f32_scan_body(body, acc):
  match body:
    case Nil{}: acc
    case Con{st,rest}: w5b_f32_scan_step(st,rest,acc)

@unsafe
def w5b_f32_dispatch(ok: Bool, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  match ok:
    case True{}: agy_f32_try_run(function,p113e_symbol(name),Con{"state",x181_param_names(params)},body,ids)
    case False{}: x181_direct(function,ids)

@unsafe
def agy_f32_try_direct(+function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      w5b_f32_dispatch(
        U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3) && U32.is_eq(w5b_f32_scan_body(body,0),3),
        function,name,params,body,ids)""",
        "agy_f32_try_direct_preguard",
    )

    # ------------------------------------------------------------------
    # 2. CSE (x186_*): zero-closure tries + in-place prune + skip unchanged
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x186_expr_hash(+kind: U32, +tid: U32, +op: String, +left: N111Value, +right: N111Value) -> U32:
  +hl = x186_val_hash(left)
  +hr = x186_val_hash(right)
  +ho = index_hash(op,U32.add(U32.mul(kind,131),tid))
  nt_choose(U32,U32.is_eq(kind,0) && w4_cse_comm(op),
    u => U32.xor(U32.mul(ho,16777619),U32.xor(U32.add(hl,hr),U32.mul(U32.xor(hl,hr),33554467))),
    u => U32.mul(U32.xor(U32.mul(U32.xor(ho,hl),16777619),hr),16777619))

@unsafe
def x186_ft_find(trie: X186FactTrie, +h: U32) -> List<&2,X186Expr>:
  match trie:
    case X186FTNil{}: []
    case X186FTLeaf{stored,items}: nt_choose(List<&2,X186Expr>,U32.is_eq(stored,h),u => items,u => [])
    case X186FTNode{stored,mask,l,r}:
      nt_choose(List<&2,X186Expr>,U32.is_eq(U32.and(h,mask),0),u => x186_ft_find(l,h),u => x186_ft_find(r,h))

@unsafe
def x186_ft_join(+trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  nt_choose(X186FactTrie,U32.is_eq(U32.and(h,mask),0),
    u => X186FTNode{stored,mask,X186FTLeaf{h,[item]},trie},
    u => X186FTNode{stored,mask,trie,X186FTLeaf{h,[item]}})

@unsafe
def x186_ft_insert(+trie: X186FactTrie, +item: X186Expr, +h: U32) -> X186FactTrie:
  match trie:
    case X186FTNil{}: X186FTLeaf{h,[item]}
    case X186FTLeaf{stored,items}:
      +mask = index_split_bit(U32.xor(h,stored))
      nt_choose(X186FactTrie,U32.is_eq(mask,0),
        u => X186FTLeaf{h,Con{item,items}},
        u => x186_ft_join(trie,item,h,stored,mask))
    case X186FTNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      nt_choose(X186FactTrie,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),
        u => nt_choose(X186FactTrie,U32.is_eq(U32.and(h,split),0),
          v => X186FTNode{stored,split,x186_ft_insert(l,item,h),r},
          v => X186FTNode{stored,split,l,x186_ft_insert(r,item,h)}),
        u => x186_ft_join(trie,item,h,stored,index_split_bit(diff)))

@unsafe
def x186_ft_rebuild(facts: List<&2,X186Expr>) -> X186FactTrie:
  match facts:
    case Nil{}: X186FTNil{}
    case Con{+f,rest}:
      match f:
        case X186Expr{name,kind,typ,op,left,right}:
          x186_ft_insert(x186_ft_rebuild(rest),f,x186_expr_hash(kind,p111v_type(typ),op,left,right))

@unsafe
def x186_at_find(trie: X186AliasTrie, +h: U32) -> List<&2,X186Alias>:
  match trie:
    case X186ATNil{}: []
    case X186ATLeaf{stored,items}: nt_choose(List<&2,X186Alias>,U32.is_eq(stored,h),u => items,u => [])
    case X186ATNode{stored,mask,l,r}:
      nt_choose(List<&2,X186Alias>,U32.is_eq(U32.and(h,mask),0),u => x186_at_find(l,h),u => x186_at_find(r,h))

@unsafe
def x186_at_join(+trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  nt_choose(X186AliasTrie,U32.is_eq(U32.and(h,mask),0),
    u => X186ATNode{stored,mask,X186ATLeaf{h,[item]},trie},
    u => X186ATNode{stored,mask,trie,X186ATLeaf{h,[item]}})

@unsafe
def x186_at_insert(+trie: X186AliasTrie, +item: X186Alias, +h: U32) -> X186AliasTrie:
  match trie:
    case X186ATNil{}: X186ATLeaf{h,[item]}
    case X186ATLeaf{stored,items}:
      +mask = index_split_bit(U32.xor(h,stored))
      nt_choose(X186AliasTrie,U32.is_eq(mask,0),
        u => X186ATLeaf{h,Con{item,items}},
        u => x186_at_join(trie,item,h,stored,mask))
    case X186ATNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      nt_choose(X186AliasTrie,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),
        u => nt_choose(X186AliasTrie,U32.is_eq(U32.and(h,split),0),
          v => X186ATNode{stored,split,x186_at_insert(l,item,h),r},
          v => X186ATNode{stored,split,l,x186_at_insert(r,item,h)}),
        u => x186_at_join(trie,item,h,stored,index_split_bit(diff)))

@unsafe
def x186_at_rebuild(aliases: List<&2,X186Alias>) -> X186AliasTrie:
  match aliases:
    case Nil{}: X186ATNil{}
    case Con{+a,rest}:
      match a:
        case X186Alias{name,val}:
          x186_at_insert(x186_at_rebuild(rest),a,index_hash(name,2166136261))

@unsafe
def x186_m_add_name(+m: KDef, +name: String) -> KDef:
  +h = index_hash(name,2166136261)
  nt_choose(KDef,agy_str_eq(dk(index_find(m,name,h,32)),"X186M"),
    u => m,
    u => p131i_insert(m,KDef{name,"X186M",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h))""",
        """@unsafe
def w5b_expr_hash_mix(comm: Bool, +ho: U32, +hl: U32, +hr: U32) -> U32:
  match comm:
    case True{}: U32.xor(U32.mul(ho,16777619),U32.xor(U32.add(hl,hr),U32.mul(U32.xor(hl,hr),33554467)))
    case False{}: U32.mul(U32.xor(U32.mul(U32.xor(ho,hl),16777619),hr),16777619)

@unsafe
def x186_expr_hash(+kind: U32, +tid: U32, +op: String, +left: N111Value, +right: N111Value) -> U32:
  +hl = x186_val_hash(left)
  +hr = x186_val_hash(right)
  +ho = index_hash(op,U32.add(U32.mul(kind,131),tid))
  w5b_expr_hash_mix(U32.is_eq(kind,0) && w4_cse_comm(op),ho,hl,hr)

law x186_ft_find:
  for trie: X186FactTrie
  for +h: U32
  List<&2,X186Expr>

@unsafe
def w5b_ft_find_leaf(eq: Bool, items: List<&2,X186Expr>) -> List<&2,X186Expr>:
  match eq:
    case True{}: items
    case False{}: []

@unsafe
def w5b_ft_find_br(bit: U32, l: X186FactTrie, r: X186FactTrie, +h: U32) -> List<&2,X186Expr>:
  match bit:
    case 0: x186_ft_find(l,h)
    case _: x186_ft_find(r,h)

@unsafe
def x186_ft_find(trie, h):
  match trie:
    case X186FTNil{}: []
    case X186FTLeaf{stored,items}: w5b_ft_find_leaf(U32.is_eq(stored,h),items)
    case X186FTNode{stored,mask,l,r}: w5b_ft_find_br(U32.and(h,mask),l,r,h)

@unsafe
def w5b_ft_join_br(bit: U32, +trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  match bit:
    case 0: X186FTNode{stored,mask,X186FTLeaf{h,[item]},trie}
    case _: X186FTNode{stored,mask,trie,X186FTLeaf{h,[item]}}

@unsafe
def x186_ft_join(+trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  w5b_ft_join_br(U32.and(h,mask),trie,item,h,stored,mask)

law x186_ft_insert:
  for +trie: X186FactTrie
  for +item: X186Expr
  for +h: U32
  X186FactTrie

@unsafe
def w5b_ft_ins_leaf(+mask: U32, +trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, items: List<&2,X186Expr>) -> X186FactTrie:
  match mask:
    case 0: X186FTLeaf{h,Con{item,items}}
    case _: x186_ft_join(trie,item,h,stored,mask)

@unsafe
def w5b_ft_ins_side(bit: U32, +stored: U32, +split: U32, l: X186FactTrie, r: X186FactTrie, +item: X186Expr, +h: U32) -> X186FactTrie:
  match bit:
    case 0: X186FTNode{stored,split,x186_ft_insert(l,item,h),r}
    case _: X186FTNode{stored,split,l,x186_ft_insert(r,item,h)}

@unsafe
def w5b_ft_ins_node(below: U32, +trie: X186FactTrie, +stored: U32, +split: U32, l: X186FactTrie, r: X186FactTrie,
    +item: X186Expr, +h: U32, +diff: U32) -> X186FactTrie:
  match below:
    case 0: w5b_ft_ins_side(U32.and(h,split),stored,split,l,r,item,h)
    case _: x186_ft_join(trie,item,h,stored,index_split_bit(diff))

@unsafe
def x186_ft_insert(trie, item, h):
  match trie:
    case X186FTNil{}: X186FTLeaf{h,[item]}
    case X186FTLeaf{stored,items}:
      w5b_ft_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,item,h,stored,items)
    case X186FTNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5b_ft_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,item,h,diff)

@unsafe
def x186_ft_rebuild(facts: List<&2,X186Expr>) -> X186FactTrie:
  match facts:
    case Nil{}: X186FTNil{}
    case Con{+f,rest}:
      match f:
        case X186Expr{name,kind,typ,op,left,right}:
          x186_ft_insert(x186_ft_rebuild(rest),f,x186_expr_hash(kind,p111v_type(typ),op,left,right))

law x186_at_find:
  for trie: X186AliasTrie
  for +h: U32
  List<&2,X186Alias>

@unsafe
def w5b_at_find_leaf(eq: Bool, items: List<&2,X186Alias>) -> List<&2,X186Alias>:
  match eq:
    case True{}: items
    case False{}: []

@unsafe
def w5b_at_find_br(bit: U32, l: X186AliasTrie, r: X186AliasTrie, +h: U32) -> List<&2,X186Alias>:
  match bit:
    case 0: x186_at_find(l,h)
    case _: x186_at_find(r,h)

@unsafe
def x186_at_find(trie, h):
  match trie:
    case X186ATNil{}: []
    case X186ATLeaf{stored,items}: w5b_at_find_leaf(U32.is_eq(stored,h),items)
    case X186ATNode{stored,mask,l,r}: w5b_at_find_br(U32.and(h,mask),l,r,h)

@unsafe
def w5b_at_join_br(bit: U32, +trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  match bit:
    case 0: X186ATNode{stored,mask,X186ATLeaf{h,[item]},trie}
    case _: X186ATNode{stored,mask,trie,X186ATLeaf{h,[item]}}

@unsafe
def x186_at_join(+trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  w5b_at_join_br(U32.and(h,mask),trie,item,h,stored,mask)

law x186_at_insert:
  for +trie: X186AliasTrie
  for +item: X186Alias
  for +h: U32
  X186AliasTrie

@unsafe
def w5b_at_ins_leaf(+mask: U32, +trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, items: List<&2,X186Alias>) -> X186AliasTrie:
  match mask:
    case 0: X186ATLeaf{h,Con{item,items}}
    case _: x186_at_join(trie,item,h,stored,mask)

@unsafe
def w5b_at_ins_side(bit: U32, +stored: U32, +split: U32, l: X186AliasTrie, r: X186AliasTrie, +item: X186Alias, +h: U32) -> X186AliasTrie:
  match bit:
    case 0: X186ATNode{stored,split,x186_at_insert(l,item,h),r}
    case _: X186ATNode{stored,split,l,x186_at_insert(r,item,h)}

@unsafe
def w5b_at_ins_node(below: U32, +trie: X186AliasTrie, +stored: U32, +split: U32, l: X186AliasTrie, r: X186AliasTrie,
    +item: X186Alias, +h: U32, +diff: U32) -> X186AliasTrie:
  match below:
    case 0: w5b_at_ins_side(U32.and(h,split),stored,split,l,r,item,h)
    case _: x186_at_join(trie,item,h,stored,index_split_bit(diff))

@unsafe
def x186_at_insert(trie, item, h):
  match trie:
    case X186ATNil{}: X186ATLeaf{h,[item]}
    case X186ATLeaf{stored,items}:
      w5b_at_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,item,h,stored,items)
    case X186ATNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5b_at_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,item,h,diff)

@unsafe
def x186_at_rebuild(aliases: List<&2,X186Alias>) -> X186AliasTrie:
  match aliases:
    case Nil{}: X186ATNil{}
    case Con{+a,rest}:
      match a:
        case X186Alias{name,val}:
          x186_at_insert(x186_at_rebuild(rest),a,index_hash(name,2166136261))

@unsafe
def w5b_m_add_if(has: Bool, +m: KDef, +name: String, +h: U32) -> KDef:
  match has:
    case True{}: m
    case False{}: p131i_insert(m,KDef{name,"X186M",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h)

@unsafe
def x186_m_add_name(+m: KDef, +name: String) -> KDef:
  +h = index_hash(name,2166136261)
  w5b_m_add_if(String.eq(dk(index_find(m,name,h,32)),"X186M"),m,name,h)""",
        "x186_trie_zero_closure",
    )

    src = replace_exact(
        src,
        """@unsafe
def x186_e_alias(aliases: List<&2,X186Alias>, +name: String) -> N111Value:
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}:
      nt_choose(N111Value,agy_str_eq(name,other),u => value,u => x186_e_alias(rest,name))""",
        """law x186_e_alias:
  for aliases: List<&2,X186Alias>
  for +name: String
  N111Value

@unsafe
def w5b_e_alias_if(eq: Bool, value: N111Value, rest: List<&2,X186Alias>, +name: String) -> N111Value:
  match eq:
    case True{}: value
    case False{}: x186_e_alias(rest,name)

@unsafe
def x186_e_alias(aliases, name):
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}: w5b_e_alias_if(String.eq(name,other),value,rest,name)""",
        "x186_e_alias_zero_closure",
    )

    src = replace_exact(
        src,
        """@unsafe
def x186_e_written(+state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,U32.is_eq(fc,0) && U32.is_eq(ac,0),
        u => state,
        u => nt_choose(X186ExprState,agy_str_eq(dk(index_find(mentioned,name,index_hash(name,2166136261),32)),"X186M"),
          v =>
            +nf = x186_e_kill_facts(facts,name)
            +na = x186_e_kill_aliases(aliases,name)
            X186ExprState{nf,na,nt_count(X186Expr,nf),nt_count(X186Alias,na),mentioned,x186_ft_rebuild(nf),x186_at_rebuild(na)},
          v => state))""",
        """@unsafe
def w5b_ft_node(stored: U32, split: U32, l: X186FactTrie, r: X186FactTrie) -> X186FactTrie:
  match l:
    case X186FTNil{}: r
    case _:
      match r:
        case X186FTNil{}: l
        case _: X186FTNode{stored,split,l,r}

@unsafe
def w5b_ft_leaf_wrap(stored: U32, ni: List<&2,X186Expr>) -> X186FactTrie:
  match ni:
    case Nil{}: X186FTNil{}
    case _: X186FTLeaf{stored,ni}

@unsafe
def w5b_ft_prune(trie: X186FactTrie, +name: String) -> X186FactTrie:
  match trie:
    case X186FTNil{}: X186FTNil{}
    case X186FTLeaf{stored,items}: w5b_ft_leaf_wrap(stored,x186_e_kill_facts(items,name))
    case X186FTNode{stored,split,l,r}: w5b_ft_node(stored,split,w5b_ft_prune(l,name),w5b_ft_prune(r,name))

@unsafe
def w5b_at_node(stored: U32, split: U32, l: X186AliasTrie, r: X186AliasTrie) -> X186AliasTrie:
  match l:
    case X186ATNil{}: r
    case _:
      match r:
        case X186ATNil{}: l
        case _: X186ATNode{stored,split,l,r}

@unsafe
def w5b_at_leaf_wrap(stored: U32, ni: List<&2,X186Alias>) -> X186AliasTrie:
  match ni:
    case Nil{}: X186ATNil{}
    case _: X186ATLeaf{stored,ni}

@unsafe
def w5b_at_prune(trie: X186AliasTrie, +name: String) -> X186AliasTrie:
  match trie:
    case X186ATNil{}: X186ATNil{}
    case X186ATLeaf{stored,items}: w5b_at_leaf_wrap(stored,x186_e_kill_aliases(items,name))
    case X186ATNode{stored,split,l,r}: w5b_at_node(stored,split,w5b_at_prune(l,name),w5b_at_prune(r,name))

@unsafe
def w5b_ft_prune_if(same: Bool, ft: X186FactTrie, +name: String) -> X186FactTrie:
  match same:
    case True{}: ft
    case False{}: w5b_ft_prune(ft,name)

@unsafe
def w5b_at_prune_if(same: Bool, at: X186AliasTrie, +name: String) -> X186AliasTrie:
  match same:
    case True{}: at
    case False{}: w5b_at_prune(at,name)

@unsafe
def w5b_e_written_hit(hit: Bool, +state: X186ExprState, facts: List<&2,X186Expr>, aliases: List<&2,X186Alias>,
    +fc: U32, +ac: U32, mentioned: KDef, ft: X186FactTrie, at: X186AliasTrie, +name: String) -> X186ExprState:
  match hit:
    case False{}: state
    case True{}:
      +nf = x186_e_kill_facts(facts,name)
      +na = x186_e_kill_aliases(aliases,name)
      +nfc = nt_count(X186Expr,nf)
      +nac = nt_count(X186Alias,na)
      X186ExprState{nf,na,nfc,nac,mentioned,
        w5b_ft_prune_if(U32.is_eq(nfc,fc),ft,name),
        w5b_at_prune_if(U32.is_eq(nac,ac),at,name)}

@unsafe
def w5b_e_written_nonempty(empty: Bool, +state: X186ExprState, facts: List<&2,X186Expr>, aliases: List<&2,X186Alias>,
    +fc: U32, +ac: U32, +mentioned: KDef, ft: X186FactTrie, at: X186AliasTrie, +name: String) -> X186ExprState:
  match empty:
    case True{}: state
    case False{}:
      w5b_e_written_hit(
        String.eq(dk(index_find(mentioned,name,index_hash(name,2166136261),32)),"X186M"),
        state,facts,aliases,fc,ac,mentioned,ft,at,name)

@unsafe
def x186_e_written(+state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,+fc,+ac,mentioned,ft,at}:
      w5b_e_written_nonempty(U32.is_eq(fc,0) && U32.is_eq(ac,0),state,facts,aliases,fc,ac,mentioned,ft,at,name)""",
        "x186_e_written_inplace_prune",
    )

    # ------------------------------------------------------------------
    # 3. x190_l_edges zero-closure + fast skip
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x190_l_edges(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{old,rest}:
      +a = nt_choose(U32,U32.is_eq(U32.and(bit,before),0),u => 0,u => before)
      +b = nt_choose(U32,U32.is_eq(U32.and(bit,after),0),u => 0,u => U32.or(after,writes))
      +c = nt_choose(U32,U32.is_eq(U32.and(bit,writes),0),u => 0,u => after)
      Con{U32.or(old,U32.and(U32.or(a,U32.or(b,c)),U32.not(bit))),
        x190_l_edges(rest,U32.shl(bit),before,after,writes)}""",
        """@unsafe
def w5b_u32_if_nz(cond: U32, val: U32) -> U32:
  match cond:
    case 0: 0
    case _: val

@unsafe
def w5b_l_edges_row(hit: U32, +old: U32, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32) -> U32:
  match hit:
    case 0: old
    case _:
      +a = w5b_u32_if_nz(U32.and(bit,before),before)
      +b = w5b_u32_if_nz(U32.and(bit,after),aw)
      +c = w5b_u32_if_nz(U32.and(bit,writes),after)
      U32.or(old,U32.and(U32.or(a,U32.or(b,c)),U32.not(bit)))

@unsafe
def w5b_l_edges_go(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32, +any: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{old,rest}:
      Con{w5b_l_edges_row(U32.and(bit,any),old,bit,before,after,writes,aw),
        w5b_l_edges_go(rest,U32.shl(bit),before,after,writes,aw,any)}

@unsafe
def w5b_l_edges_start(+any: U32, rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32) -> List<&2,U32>:
  match any:
    case 0: rows
    case _: w5b_l_edges_go(rows,bit,before,after,writes,aw,any)

@unsafe
def x190_l_edges(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32) -> List<&2,U32>:
  +aw = U32.or(after,writes)
  w5b_l_edges_start(U32.or(before,aw),rows,bit,before,after,writes,aw)""",
        "x190_l_edges_fast",
    )

    # ------------------------------------------------------------------
    # 4. x185_d_union hash-preserving zero-closure + x185_copy_write saturate skip
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  +h = index_hash(name,2166136261)
  index_set(counts,KDef{name,"X185Writes",U32.min(2,U32.inc(da(index_find(counts,name,h,32)))),0,
    atom("Absent"),atom("Absent"),[],False{},False{}},h,32)""",
        """@unsafe
def w5b_copy_write_go(sat: Bool, +cur: U32, +name: String, +counts: KDef, +h: U32) -> KDef:
  match sat:
    case True{}: counts
    case False{}:
      index_set(counts,KDef{name,"X185Writes",U32.inc(cur),0,
        atom("Absent"),atom("Absent"),[],False{},False{}},h,32)

@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  +h = index_hash(name,2166136261)
  +cur = da(index_find(counts,name,h,32))
  w5b_copy_write_go(U32.is_ge(cur,2),cur,name,counts,h)""",
        "x185_copy_write_fast",
    )

    src = replace_exact(
        src,
        """@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:""",
        """@unsafe
def w5b_d_ins_if(live: Bool, +hash: U32, head: KDef, out: KDef) -> KDef:""",
        "noop_placeholder",
    ) if False else src

    src = replace_exact(
        src,
        """@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      x185_d_union_bucket(rest,nt_choose(KDef,U32.is_gt(da(head),0),u => x185_d_mark(out,dn(head)),u => out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: x185_d_union_bucket(bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out""",
        """@unsafe
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
def w5b_d_mark_if(live: Bool, head: KDef, out: KDef) -> KDef:
  match live:
    case True{}: x185_d_mark(out,dn(head))
    case False{}: out

@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      x185_d_union_bucket(rest,w5b_d_mark_if(U32.is_gt(da(head),0),head,out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_d_union_bkt(hash,bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out""",
        "x185_d_union_hash_preserving",
    )

    # ------------------------------------------------------------------
    # 4b. w4g_live_union hash-preserving zero-closure + x181_reads_record zero-closure
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
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
    case _: out""",
        """@unsafe
def w5b_w4g_ins_if(live: Bool, +hash: U32, h: KDef, out: KDef) -> KDef:
  match live:
    case True{}: p131i_insert(out,KDef{dn(h),"W4GLive",1,0,atom("Absent"),atom("Absent"),[],False{},False{}},hash)
    case False{}: out

@unsafe
def w5b_w4g_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w5b_w4g_union_bkt(hash,rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),hash,h,out))

@unsafe
def w4g_live_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w4g_live_union_bucket(rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),index_hash(dn(h),2166136261),h,out))

@unsafe
def w4g_live_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_w4g_union_bkt(hash,bucket,out)
    case KIndexNode{_,_,a,b}: w4g_live_union(b,w4g_live_union(a,out))
    case _: out""",
        "w4g_live_union_hash_preserving",
    )

    src = replace_exact(
        src,
        """def x181_read_increment(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,4294967295),u => count,u => U32.inc(count))

# The ordered list grows once per distinct name. Every subsequent read updates
# the indexed count, without searching the name list or any candidate list.
@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +h = index_hash(name,2166136261)
      +old = index_find(counts,name,h,32)
      +fresh = p88_string_eq(dk(old),"Absent")
      X181ReadCounts{index_set(counts,KDef{name,"X181Reads",
        nt_choose(U32,fresh,u => 1,u => x181_read_increment(da(old))),0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        nt_choose(List<&2,String>,fresh,u => Con{name,reversedNames},u => reversedNames)}

@unsafe
def x181_reads_name(+name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  nt_choose(X181ReadCounts,x181_register_reserved(name),
    u => counts,u => x181_reads_record(name,counts))""",
        """def x181_read_increment(+count: U32) -> U32:
  match count:
    case 4294967295: 4294967295
    case _: U32.inc(count)

@unsafe
def w5b_reads_rec_go(fresh: Bool, +name: String, +counts: KDef, +reversedNames: List<&2,String>, +h: U32, +old: KDef) -> X181ReadCounts:
  match fresh:
    case True{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",1,0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        Con{name,reversedNames}}
    case False{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",x181_read_increment(da(old)),0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        reversedNames}

@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +h = index_hash(name,2166136261)
      +old = index_find(counts,name,h,32)
      w5b_reads_rec_go(String.eq(dk(old),"Absent"),name,counts,reversedNames,h,old)

@unsafe
def w5b_reads_name_go(res: Bool, +name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  match res:
    case True{}: counts
    case False{}: x181_reads_record(name,counts)

@unsafe
def x181_reads_name(+name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  w5b_reads_name_go(x181_register_reserved(name),name,counts)""",
        "x181_reads_record_zero_closure",
    )

    # ------------------------------------------------------------------
    # 5. w4b_is_write_only_op / w4b_is_simple_alu / w4b_reg_dead + W5BLblTrie
    #    + w4b_copy_peep + w4b_has_*_to + w5_gpr_peep + w4_post_select
    # ------------------------------------------------------------------
    src = replace_optional(
        src,
        """@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"leaq") || agy_str_eq(op,"movzbl") || agy_str_eq(op,"movd")

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"addq") || agy_str_eq(op,"subl") || agy_str_eq(op,"subq") ||
  agy_str_eq(op,"imull") || agy_str_eq(op,"imulq") || agy_str_eq(op,"andl") || agy_str_eq(op,"andq") ||
  agy_str_eq(op,"orl") || agy_str_eq(op,"orq") || agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq") ||
  agy_str_eq(op,"shll") || agy_str_eq(op,"shlq") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shrq") ||
  agy_str_eq(op,"sarl") || agy_str_eq(op,"sarq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"cmpq") ||
  agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || String.starts_with(op,"cmov") ||
  String.starts_with(op,"set")

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"subl") || agy_str_eq(op,"imull") ||
  agy_str_eq(op,"andl") || agy_str_eq(op,"orl") || agy_str_eq(op,"xorl")

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  Bool

@unsafe
def w4b_find_label(+lbl: String, items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l,lbl),u => Some{rest},u => w4b_find_label(lbl,rest))
    case Con{_,rest}: w4b_find_label(lbl,rest)

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops)
    case None{}: False{}

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      nt_choose(Bool,w4b_op_reads_reg(r,src),w => False{},w =>
        nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),x => True{},
          x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)))
    case _:
      nt_choose(Bool,w4b_args_read_reg(r,args),w => False{},
        w => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}:
      nt_choose(Bool,U32.is_eq(hops,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(op,"jmp"),
          v => w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1)),
          v => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1)) &&
               w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1))))
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),u => True{},
        u => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))
    case _: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,agy_str_eq(op,"popq"),p => w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops),p =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops),
              x => False{})))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,4)""",
        """# W5B-C1: O(1) first-char opcode classifiers + O(log L) W5BLblTrie + zero-closure w4b_reg_dead
@unsafe
def w5b_is_wo_c(u: U32, +op: String) -> Bool:
  match u:
    case 109: String.eq(op,"movq") || String.eq(op,"movl") || String.eq(op,"movabsq") || String.eq(op,"movzbl") || String.eq(op,"movd")
    case 108: String.eq(op,"leaq")
    case _: False{}

@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5b_is_wo_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5b_is_alu_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"addq") || String.eq(op,"andl") || String.eq(op,"andq")
    case 115: String.eq(op,"subl") || String.eq(op,"subq") || String.eq(op,"shll") || String.eq(op,"shlq") || String.eq(op,"shrl") || String.eq(op,"shrq") || String.eq(op,"sarl") || String.eq(op,"sarq") || String.starts_with(op,"set")
    case 105: String.eq(op,"imull") || String.eq(op,"imulq")
    case 111: String.eq(op,"orl") || String.eq(op,"orq")
    case 120: String.eq(op,"xorl") || String.eq(op,"xorq")
    case 99: String.eq(op,"cmpl") || String.eq(op,"cmpq") || String.starts_with(op,"cmov")
    case 116: String.eq(op,"testl") || String.eq(op,"testq")
    case _: False{}

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5b_is_alu_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5b_is_alu32_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"andl")
    case 115: String.eq(op,"subl")
    case 105: String.eq(op,"imull")
    case 111: String.eq(op,"orl")
    case 120: String.eq(op,"xorl")
    case _: False{}

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5b_is_alu32_c(Char.to_u32(c),op)
    case SNil{}: False{}

type W5BLblEntry is Data:
  W5BLblEntry{+lbl: String, +tail: List<&2,X187Parsed>}

type W5BLblTrie is Data:
  W5BLNil{}
  W5BLLeaf{+h: U32, +items: List<&2,W5BLblEntry>}
  W5BLNode{+h: U32, +mask: U32, +l: W5BLblTrie, +r: W5BLblTrie}

law w5b_lbl_bkt_find:
  for items: List<&2,W5BLblEntry>
  for +lbl: String
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5b_lbl_bkt_if(eq: Bool, t: List<&2,X187Parsed>, rest: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{t}
    case False{}: w5b_lbl_bkt_find(rest,lbl)

@unsafe
def w5b_lbl_bkt_find(items, lbl):
  match items:
    case Nil{}: None{}
    case Con{W5BLblEntry{k,t},rest}: w5b_lbl_bkt_if(String.eq(k,lbl),t,rest,lbl)

law w5b_lbl_find:
  for trie: W5BLblTrie
  for +lbl: String
  for +h: U32
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5b_lbl_find_leaf(eq: Bool, items: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: w5b_lbl_bkt_find(items,lbl)
    case False{}: None{}

@unsafe
def w5b_lbl_find_br(bit: U32, l: W5BLblTrie, r: W5BLblTrie, +lbl: String, +h: U32) -> Maybe<&2,List<&2,X187Parsed>>:
  match bit:
    case 0: w5b_lbl_find(l,lbl,h)
    case _: w5b_lbl_find(r,lbl,h)

@unsafe
def w5b_lbl_find(trie, lbl, h):
  match trie:
    case W5BLNil{}: None{}
    case W5BLLeaf{stored,items}: w5b_lbl_find_leaf(U32.is_eq(stored,h),items,lbl)
    case W5BLNode{stored,mask,l,r}: w5b_lbl_find_br(U32.and(h,mask),l,r,lbl,h)

@unsafe
def w5b_lbl_join_br(bit: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,mask,W5BLLeaf{h,[entry]},trie}
    case _: W5BLNode{stored,mask,trie,W5BLLeaf{h,[entry]}}

@unsafe
def w5b_lbl_join(+trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  w5b_lbl_join_br(U32.and(h,mask),trie,entry,h,stored,mask)

law w5b_lbl_insert:
  for +trie: W5BLblTrie
  for +entry: W5BLblEntry
  for +h: U32
  W5BLblTrie

@unsafe
def w5b_lbl_ins_leaf(+mask: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, items: List<&2,W5BLblEntry>) -> W5BLblTrie:
  match mask:
    case 0: W5BLLeaf{h,Con{entry,items}}
    case _: w5b_lbl_join(trie,entry,h,stored,mask)

@unsafe
def w5b_lbl_ins_side(bit: U32, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie, +entry: W5BLblEntry, +h: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,split,w5b_lbl_insert(l,entry,h),r}
    case _: W5BLNode{stored,split,l,w5b_lbl_insert(r,entry,h)}

@unsafe
def w5b_lbl_ins_node(below: U32, +trie: W5BLblTrie, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie,
    +entry: W5BLblEntry, +h: U32, +diff: U32) -> W5BLblTrie:
  match below:
    case 0: w5b_lbl_ins_side(U32.and(h,split),stored,split,l,r,entry,h)
    case _: w5b_lbl_join(trie,entry,h,stored,index_split_bit(diff))

@unsafe
def w5b_lbl_insert(trie, entry, h):
  match trie:
    case W5BLNil{}: W5BLLeaf{h,[entry]}
    case W5BLLeaf{stored,items}: w5b_lbl_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,entry,h,stored,items)
    case W5BLNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5b_lbl_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,entry,h,diff)

@unsafe
def w5b_lbl_build(items: List<&2,X187Parsed>) -> W5BLblTrie:
  match items:
    case Nil{}: W5BLNil{}
    case Con{PLabel{+l},+rest}:
      w5b_lbl_insert(w5b_lbl_build(rest),W5BLblEntry{l,rest},index_hash(l,2166136261))
    case Con{_,rest}: w5b_lbl_build(rest)

law w5b_reg_dead_step_t:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +budget: U32
  for +hops: U32
  Bool

@unsafe
def w5b_reg_dead_at_lbl_t(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +lbls: W5BLblTrie,
    +budget: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w5b_reg_dead_step_t(r,atTgt,lbls,budget,hops)
    case None{}: False{}

@unsafe
def w5b_rd_cont_t(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w5b_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops)

@unsafe
def w5b_rd_kill_or_cont_t(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w5b_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops)

@unsafe
def w5b_rd_wr_if_t(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5b_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops)

@unsafe
def w5b_reg_dead_write_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5b_rd_wr_if_t(w4b_op_reads_reg(r,src),dr,dw,r,rest,lbls,budget,hops)
    case _: w5b_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops)

@unsafe
def w5b_rd_br_both_t(ok: Bool, +r: U32, +tgt: String, +lbls: W5BLblTrie, +nb: U32, +nh: U32) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w5b_reg_dead_at_lbl_t(r,w5b_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh)

@unsafe
def w5b_rd_br_jmp_t(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +nb: U32, +nh: U32) -> Bool:
  match isJmp:
    case True{}: w5b_reg_dead_at_lbl_t(r,w5b_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh)
    case False{}: w5b_rd_br_both_t(w5b_reg_dead_step_t(r,rest,lbls,nb,nh),r,tgt,lbls,nb,nh)

@unsafe
def w5b_rd_br_hops_t(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32) -> Bool:
  match hops:
    case 0: False{}
    case _: w5b_rd_br_jmp_t(String.eq(op,"jmp"),r,tgt,rest,lbls,U32.sub(budget,1),U32.sub(hops,1))

@unsafe
def w5b_reg_dead_branch_t(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5b_rd_br_hops_t(hops,r,op,tgt,rest,lbls,budget)
    case _: False{}

@unsafe
def w5b_reg_dead_pop_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5b_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops)
    case _: False{}

@unsafe
def w5b_rd_alu_if_t(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5b_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops)

@unsafe
def w5b_rd_wo_if_t(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match isWo:
    case True{}: w5b_reg_dead_write_t(r,args,rest,lbls,budget,hops)
    case False{}: w5b_rd_alu_if_t(w4b_is_simple_alu(op),r,args,rest,lbls,budget,hops)

@unsafe
def w5b_rd_ret_if_t(isRet: Bool, +r: U32) -> Bool:
  match isRet:
    case True{}: Bool.not(U32.is_eq(r,0))
    case False{}: False{}

@unsafe
def w5b_rd_pop_if_t(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match isPop:
    case True{}: w5b_reg_dead_pop_t(r,args,rest,lbls,budget,hops)
    case False{}: False{}

@unsafe
def w5b_rd_inst_c_t(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match u:
    case 114: w5b_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5b_rd_pop_if_t(String.eq(op,"popq"),r,args,rest,lbls,budget,hops)
    case 106: w5b_reg_dead_branch_t(r,op,args,rest,lbls,budget,hops)
    case _: w5b_rd_wo_if_t(w4b_is_write_only_op(op),r,op,args,rest,lbls,budget,hops)

@unsafe
def w5b_reg_dead_inst_t(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match op:
    case SCon{c,_}: w5b_rd_inst_c_t(Char.to_u32(c),r,op,args,rest,lbls,budget,hops)
    case SNil{}: False{}

@unsafe
def w5b_reg_dead_go_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w5b_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{op,args}},rest}: w5b_reg_dead_inst_t(r,op,args,rest,lbls,budget,hops)
    case _: False{}

@unsafe
def w5b_reg_dead_step_t(r,items,lbls,budget,hops):
  match budget:
    case 0: False{}
    case _: w5b_reg_dead_go_t(r,items,lbls,budget,hops)

@unsafe
def w5b_reg_dead_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32) -> Bool:
  w5b_reg_dead_step_t(r,items,lbls,budget,4)

law w4b_find_label:
  for +lbl: String
  for items: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5b_find_lbl_if(eq: Bool, rest: List<&2,X187Parsed>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{rest}
    case False{}: w4b_find_label(lbl,rest)

@unsafe
def w4b_find_label(lbl, items):
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}: w5b_find_lbl_if(String.eq(l,lbl),rest,lbl)
    case Con{_,rest}: w4b_find_label(lbl,rest)

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  Bool

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops)
    case None{}: False{}

@unsafe
def w5b_rd_cont_f(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)

@unsafe
def w5b_rd_kill_f(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)

@unsafe
def w5b_rd_wr_if_f(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5b_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops)

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5b_rd_wr_if_f(w4b_op_reads_reg(r,src),dr,dw,r,rest,fnItems,budget,hops)
    case _: w5b_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops)

@unsafe
def w5b_rd_br_both_f(ok: Bool, +r: U32, +tgt: String, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh)

@unsafe
def w5b_rd_br_jmp_f(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32) -> Bool:
  match isJmp:
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh)
    case False{}: w5b_rd_br_both_f(w4b_reg_dead_step(r,rest,fnItems,nb,nh),r,tgt,fnItems,nb,nh)

@unsafe
def w5b_rd_br_hops_f(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  match hops:
    case 0: False{}
    case _: w5b_rd_br_jmp_f(String.eq(op,"jmp"),r,tgt,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1))

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5b_rd_br_hops_f(hops,r,op,tgt,rest,fnItems,budget)
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5b_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops)
    case _: False{}

@unsafe
def w5b_rd_alu_if_f(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5b_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops)

@unsafe
def w5b_rd_wo_if_f(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match isWo:
    case True{}: w4b_reg_dead_write(r,args,rest,fnItems,budget,hops)
    case False{}: w5b_rd_alu_if_f(w4b_is_simple_alu(op),r,args,rest,fnItems,budget,hops)

@unsafe
def w5b_rd_pop_if_f(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match isPop:
    case True{}: w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops)
    case False{}: False{}

@unsafe
def w5b_rd_inst_c_f(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match u:
    case 114: w5b_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5b_rd_pop_if_f(String.eq(op,"popq"),r,args,rest,fnItems,budget,hops)
    case 106: w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops)
    case _: w5b_rd_wo_if_f(w4b_is_write_only_op(op),r,op,args,rest,fnItems,budget,hops)

@unsafe
def w5b_rd_inst_f(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match op:
    case SCon{c,_}: w5b_rd_inst_c_f(Char.to_u32(c),r,op,args,rest,fnItems,budget,hops)
    case SNil{}: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{op,args}},rest}: w5b_rd_inst_f(r,op,args,rest,fnItems,budget,hops)
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  match budget:
    case 0: False{}
    case _: w4b_reg_dead_go(r,items,fnItems,budget,hops)

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,4)""",
        "w4b_reg_dead_fast_and_lbltrie",
    )

    # Direct-match w4b_copy_peep with W5BLblTrie + changed flag (100% param scrutinees)
    src = replace_optional(
        src,
        """@unsafe
def w4b_copy_peep(items,fnItems,out):
  match items:
    case Nil{}: out
    case Con{+i0,Con{+i1,+rest}}: w4b_copy_pair_rr(w4b_as_rr(i0),w4b_as_rr(i1),i0,i1,rest,fnItems,out)
    case Con{h,rest}: w4b_copy_peep(rest,fnItems,Con{X188One{h},out})""",
        """type W5BPeepOut is Data:
  W5BPeepOut{+changed: Bool, +seq: List<&2,X188Seq>}

law w5b_copy_peep_t:
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +out: List<&2,X188Seq>
  for +changed: Bool
  W5BPeepOut

@unsafe
def w5b_cp_jcc_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(Con{i3,tail},lbls,Con{X188One{i1},Con{X188One{i0},out}},True{})
    case False{}: w5b_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_copy_check_jcc_t(br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match br:
    case W4BBranch{jop,_}: w5b_cp_jcc_if(w4_peep_is_jz_jnz(jop),i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BBranchNone{}: w5b_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sf4_if(ok: Bool, +a: U32, +b: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(Con{PInst{X187Instruction{"subl",[X187Reg{a,32,False{}},X187Reg{b,32,False{}}]}},tail},lbls,out,True{})
    case False{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sub_fold4_t(r4: W4BRR, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r4:
    case W4BRR{op4,s4,ws4,d4,wd4}:
      +ok = String.eq(op4,"movq") && U32.is_eq(s4,a) && U32.is_eq(ws4,64) && U32.is_eq(d4,b) && U32.is_eq(wd4,64) &&
            Bool.not(U32.is_eq(a,b) || U32.is_eq(t,a) || U32.is_eq(t,b) || U32.is_eq(t,11) || U32.is_eq(a,11) || U32.is_eq(b,11)) &&
            w5b_reg_dead_t(t,tail,lbls,36) && w5b_reg_dead_t(a,tail,lbls,36) && w5b_reg_dead_t(11,tail,lbls,36)
      w5b_sf4_if(ok,a,b,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sf3_if(ok: Bool, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_sub_fold4_t(w4b_as_rr(i4),b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sub_fold3_t(r3: W4BRR, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r3:
    case W4BRR{op3,s3,ws3,d3,wd3}:
      w5b_sf3_if(String.eq(op3,"subl") && U32.is_eq(s3,11) && U32.is_eq(ws3,32) && U32.is_eq(d3,a) && U32.is_eq(wd3,32),
        i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sf2_if(ok: Bool, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_sub_fold3_t(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sub_fold2_t(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      w5b_sf2_if(String.eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_sub_fold_t(+b: U32, +t: U32, +a: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{i2,Con{i3,Con{i4,tail}}}:
      w5b_sub_fold2_t(w4b_as_rr(i2),i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case _: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_cp_chk_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_check_jcc_t(w4b_as_branch(i3),i0,i1,i2,i3,tail,lbls,out,chg)
    case False{}: w5b_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_copy_check_test_t(tr: W4BRR, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match tr:
    case W4BRR{top,s,ws,d,wd}:
      w5b_cp_chk_if(String.eq(top,"testq") && U32.is_eq(s,c) && U32.is_eq(d,c) && U32.is_eq(ws,64) && U32.is_eq(wd,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BRRNone{}: w5b_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_copy_check_cmp_t(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      w5b_cp_chk_if(String.eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) && U32.is_eq(cr,c) && U32.is_eq(cw,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BImmRegNone{}: w5b_copy_check_test_t(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)

@unsafe
def w5b_copy_after_sub_t(+c: U32, +rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{+i2,Con{+i3,+tail}}: w5b_copy_check_cmp_t(w4b_as_imm_reg(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)
    case _: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_cp_r6(ok: Bool, +s: U32, +t: U32, +t2: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_sub_fold_t(s,t,t2,i0,i1,rest,lbls,out,chg)
    case False{}: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_cp_r5(ok: Bool, +isMov32: Bool, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(rest,lbls,Con{X188One{i0},out},True{})
    case False{}:
      w5b_cp_r6(isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) && U32.is_eq(d,11),
        s,t,t2,i0,i1,rest,lbls,out,chg)

@unsafe
def w5b_cp_r4(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_after_sub_t(d,rest,i0,i1,lbls,out,chg)
    case False{}:
      w5b_cp_r5(String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
          U32.is_eq(t,t2) && U32.is_eq(t,d) && (isMov32 || w4b_is_alu32_rr(op0)),
        isMov32,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5b_cp_r3(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(Con{PInst{X187Instruction{op0,[X187Reg{t,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      w5b_cp_r4(String.eq(op0,"subl") && String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
        isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5b_cp_r2(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok3 = U32.is_eq(ws,32) && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && U32.is_eq(s,d) && Bool.not(U32.is_eq(t,d)) &&
             (String.eq(op0,"addl") || String.eq(op0,"imull") || String.eq(op0,"andl") || String.eq(op0,"orl") || String.eq(op0,"xorl")) &&
             w5b_reg_dead_t(t,rest,lbls,36)
      w5b_cp_r3(ok3,isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5b_cp_r1(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5b_copy_peep_t(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok2 = isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5b_reg_dead_t(t,rest,lbls,36)
      w5b_cp_r2(ok2,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5b_copy_pair_t(+op0: String, +s: U32, +ws: U32, +t: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match i1:
    case PInst{X187Instruction{+op1,Con{X187Reg{+t2,+wt2,False{}},Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      +isMov32 = String.eq(op0,"movl") && U32.is_eq(ws,32)
      +ok1 = isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5b_reg_dead_t(t,rest,lbls,36)
      w5b_cp_r1(ok1,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)
    case _: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5b_copy_i0(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +changed: Bool) -> W5BPeepOut:
  match i0:
    case PInst{X187Instruction{+op0,Con{X187Reg{+s,+ws,False{}},Con{X187Reg{+t,32,False{}},Nil{}}}}}:
      w5b_copy_pair_t(op0,s,ws,t,i0,i1,rest,lbls,out,changed)
    case _: w5b_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},changed)

@unsafe
def w5b_copy_peep_t(items,lbls,out,changed):
  match items:
    case Nil{}: W5BPeepOut{changed,out}
    case Con{+i0,Con{+i1,+rest}}: w5b_copy_i0(i0,i1,rest,lbls,out,changed)
    case Con{h,rest}: w5b_copy_peep_t(rest,lbls,Con{X188One{h},out},changed)

@unsafe
def w5b_peep_seq(res: W5BPeepOut) -> List<&2,X188Seq>:
  match res:
    case W5BPeepOut{_,seq}: seq

@unsafe
def w4b_copy_peep(items,fnItems,out):
  w5b_peep_seq(w5b_copy_peep_t(items,w5b_lbl_build(fnItems),out,False{}))""",
        "w4b_copy_peep_fast",
        require="W5BLblTrie",
    )

    # Zero-allocation w4b_has_jmp_to / w4b_has_any_branch_to / w4b_has_non_jmp_to
    src = replace_exact(
        src,
        """@unsafe
def w4b_has_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_jmp(lbl,w4b_as_branch(h)) || w4b_has_jmp_to(lbl,rest)

@unsafe
def w4b_has_any_branch_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_any(lbl,w4b_as_branch(h)) || w4b_has_any_branch_to(lbl,rest)

@unsafe
def w4b_has_non_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4b_branch_is_cond(lbl,w4b_as_branch(h)) || w4b_has_non_jmp_to(lbl,rest)""",
        """@unsafe
def w4b_has_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.eq(op,"jmp")) || w4b_has_jmp_to(lbl,rest)
    case Con{_,rest}: w4b_has_jmp_to(lbl,rest)

@unsafe
def w4b_has_any_branch_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.starts_with(op,"j")) || w4b_has_any_branch_to(lbl,rest)
    case Con{_,rest}: w4b_has_any_branch_to(lbl,rest)

@unsafe
def w4b_has_non_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.starts_with(op,"j") && Bool.not(String.eq(op,"jmp"))) || w4b_has_non_jmp_to(lbl,rest)
    case Con{_,rest}: w4b_has_non_jmp_to(lbl,rest)""",
        "w4b_has_branch_zero_alloc",
    )

    # Direct-match w5_gpr_step + idempotent 2nd pass skip in w4_post_select
    src = replace_optional(
        src,
        """@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_gpr_try_ld(w5_as_load_rbp(i0),i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_gpr_try_rr(w4b_as_rr(i0),i0,i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_gpr_try_imm(w4b_as_imm_reg(i0),i1,r2,fnItems,acc),
        w => w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc}))))""",
        """@unsafe
def w5b_gpr_or(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{out}: out
    case None{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_ld_if(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match neg:
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5b_gpr_or(w5_g1_b(disp,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),i0,i1,r2,fnItems,acc)
        case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_rr64_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5b_gpr_or(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_try_movq_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Mem{5,disp}: w5b_gpr_ld_if(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5b_gpr_rr64_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_rr32_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5b_gpr_or(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_try_movl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Reg{+rA,32,False{}}: w5b_gpr_rr32_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_try_xorl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Imm{1,0}: w5b_gpr_or(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op64(isMovq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5b_gpr_try_movq_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op32_xor(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isXor:
    case True{}: w5b_gpr_try_xorl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op32(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovl:
    case True{}: w5b_gpr_try_movl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5b_gpr_op32_xor(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_wd(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match wd:
    case 64: w5b_gpr_op64(String.eq(op,"movq"),src,d,i0,i1,r2,fnItems,acc)
    case 32: w5b_gpr_op32(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5b_gpr_wd(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})""",
        "w5_gpr_step_direct",
    )

    src = replace_optional(
        src,
        """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f2 = w5_flat_rev_seq(w4b_copy_peep(f1,f1,[]),[])
  +f3 = w5_flat_rev_seq(w4b_copy_peep(f2,f2,[]),[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +f5 = w5_run_rot(hasLbl,licm)
  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,g3)
  w4b_wrap_items(xmm,[])""",
        """@unsafe
def w5b_lbl_build_if(hasLbl: Bool, items: List<&2,X187Parsed>) -> W5BLblTrie:
  match hasLbl:
    case True{}: w5b_lbl_build(items)
    case False{}: W5BLNil{}

@unsafe
def w5b_copy_peep2(r1: W5BPeepOut, +hasLbl: Bool, f1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BPeepOut{False{},_}: f1
    case W5BPeepOut{True{},seq2}:
      +f2 = w5_flat_rev_seq(seq2,[])
      w5_flat_rev_seq(w5b_peep_seq(w5b_copy_peep_t(f2,w5b_lbl_build_if(hasLbl,f2),[],False{})),[])

type W5BGprOut is Data:
  W5BGprUnchanged{}
  W5BGprChanged{+out: List<&2,X187Parsed>}

law w5b_gpr_peep_c:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  W5BGprOut

@unsafe
def w5b_gpr_or_c(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match res:
    case Some{out}: W5BGprChanged{out}
    case None{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_ld_c(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match neg:
    case False{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5b_gpr_or_c(w5_g1_b(disp,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),i0,i1,r2,fnItems,acc)
        case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_rr64_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5b_gpr_or_c(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_movq_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Mem{5,disp}: w5b_gpr_ld_c(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5b_gpr_rr64_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_rr32_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5b_gpr_or_c(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_movl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Reg{+rA,32,False{}}: w5b_gpr_rr32_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_xorl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Imm{1,0}: w5b_gpr_or_c(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op64_c(isMovq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovq:
    case True{}: w5b_gpr_movq_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op32_xor_c(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isXor:
    case True{}: w5b_gpr_xorl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_op32_c(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovl:
    case True{}: w5b_gpr_movl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5b_gpr_op32_xor_c(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5b_gpr_wd_c(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match wd:
    case 64: w5b_gpr_op64_c(String.eq(op,"movq"),src,d,i0,i1,r2,fnItems,acc)
    case 32: w5b_gpr_op32_c(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_step_c(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5b_gpr_wd_c(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5b_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5b_gpr_peep_c(items,fnItems,acc):
  match items:
    case Nil{}: W5BGprUnchanged{}
    case Con{+i0,Con{+i1,+r2}}: w5b_gpr_step_c(i0,i1,r2,fnItems,acc)
    case Con{_,Nil{}}: W5BGprUnchanged{}

@unsafe
def w5b_gpr_pass3(r2: W5BGprOut, g1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r2:
    case W5BGprUnchanged{}: g1
    case W5BGprChanged{+g2}: w5_gpr_peep(g2,g2,[])

@unsafe
def w5b_gpr_pass2(r1: W5BGprOut, f5: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BGprUnchanged{}: f5
    case W5BGprChanged{+g1}: w5b_gpr_pass3(w5b_gpr_peep_c(g1,g1,[]),g1)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f3 = w5b_copy_peep2(w5b_copy_peep_t(f1,w5b_lbl_build_if(hasLbl,f1),[],False{}),hasLbl,f1)
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +f5 = w5_run_rot(hasLbl,licm)
  +g3 = w5b_gpr_pass2(w5b_gpr_peep_c(f5,f5,[]),f5)
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,g3)
  w4b_wrap_items(xmm,[])""",
        "w4_post_select_skip_unchanged_copy_and_gpr_peep",
        require="W5BLblTrie",
    )

    # ------------------------------------------------------------------
    # 5b. w4_peep_list zero-closure
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w4_peep_list(items,out):
  match items:
    case Nil{}: out
    case Con{PInst{X187Instruction{+op,[X187Reg{+a,64,False{}},X187Reg{+b,64,False{}}]}},+rest}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movq") && U32.is_eq(a,b),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(rest,Con{X188One{PInst{X187Instruction{op,[X187Reg{a,64,False{}},X187Reg{b,64,False{}}]}}},out}))
    case Con{i0,Con{i1,rest}}: w4_peep_pair(i0,i1,rest,out)
    case Con{h,rest}: w4_peep_list(rest,Con{X188One{h},out})""",
        """@unsafe
def w5b_peep_selfmov(drop: Bool, +op: String, +a: U32, +b: U32, rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match drop:
    case True{}: w4_peep_list(rest,out)
    case False{}: w4_peep_list(rest,Con{X188One{PInst{X187Instruction{op,[X187Reg{a,64,False{}},X187Reg{b,64,False{}}]}}},out})

@unsafe
def w4_peep_list(items,out):
  match items:
    case Nil{}: out
    case Con{PInst{X187Instruction{+op,[X187Reg{+a,64,False{}},X187Reg{+b,64,False{}}]}},+rest}:
      w5b_peep_selfmov(U32.is_eq(a,b) && String.eq(op,"movq"),op,a,b,rest,out)
    case Con{i0,Con{i1,rest}}: w4_peep_pair(i0,i1,rest,out)
    case Con{h,rest}: w4_peep_list(rest,Con{X188One{h},out})""",
        "w4_peep_list_zero_closure",
    )

    # ------------------------------------------------------------------
    # 6b. x187_build_bytes / x187_build_encoded / x188_branch_encoded / x187_build_parsed zero-closure
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      +count = nt_count(U32,bytes)
      nt_choose(X187Build,U32.is_gt(count,33554432) || U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),
        u => x187_build_error("x86 object section exceeds 32 MiB bound",build),u =>
      nt_choose(X187Build,U32.is_eq(section,1),
        v => X187Build{section,nt_reverse(U32,bytes,t),r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error},v =>
      nt_choose(X187Build,U32.is_eq(section,2),
        w => X187Build{section,t,nt_reverse(U32,bytes,r),d,ts,U32.add(rs,count),ds,symbols,names,relocs,error},w =>
      nt_choose(X187Build,U32.is_eq(section,3),
        z => X187Build{section,t,r,nt_reverse(U32,bytes,d),ts,rs,U32.add(ds,count),symbols,names,relocs,error},
        z => x187_build_error("invalid object section",build)))))""",
        """@unsafe
def w5b_bb_sec(section: U32, +bytes: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match section:
    case 1: X187Build{1,nt_reverse(U32,bytes,t),r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error}
    case 2: X187Build{2,t,nt_reverse(U32,bytes,r),d,ts,U32.add(rs,count),ds,symbols,names,relocs,error}
    case 3: X187Build{3,t,r,nt_reverse(U32,bytes,d),ts,rs,U32.add(ds,count),symbols,names,relocs,error}
    case _: x187_build_error("invalid object section",build)

@unsafe
def w5b_bb_ok(oob: Bool, +section: U32, +bytes: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match oob:
    case True{}: x187_build_error("x86 object section exceeds 32 MiB bound",build)
    case False{}: w5b_bb_sec(section,bytes,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error)

@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      +count = nt_count(U32,bytes)
      w5b_bb_ok(U32.is_gt(count,33554432) || U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),
        section,bytes,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error)""",
        "x187_build_bytes_zero_closure",
    )

    src = replace_exact(
        src,
        """@unsafe
def x187_build_encoded(+encoded: X187Encoded, +build: X187Build) -> X187Build:
  match encoded:
    case X187Encoded{bytes,relocs,+error}:
      nt_choose(X187Build,String.is_empty(error),u => x187_build_relocations(relocs,x187_build_bytes(bytes,build)),
        u => x187_build_error(error,build))""",
        """@unsafe
def w5b_be_if(ok: Bool, bytes: List<&2,U32>, relocs: List<&2,X187Relocation>, error: String, +build: X187Build) -> X187Build:
  match ok:
    case True{}: x187_build_relocations(relocs,x187_build_bytes(bytes,build))
    case False{}: x187_build_error(error,build)

@unsafe
def x187_build_encoded(+encoded: X187Encoded, +build: X187Build) -> X187Build:
  match encoded:
    case X187Encoded{bytes,relocs,+error}:
      w5b_be_if(String.is_empty(error),bytes,relocs,error,build)""",
        "x187_build_encoded_zero_closure",
    )

    src = replace_exact(
        src,
        """    case PInst{instruction}:
      nt_choose(X187Build,U32.is_eq(x187_build_section(build),1),
        v => x188_build_instruction(instruction,build),
        v => x187_build_error("instruction outside text",build))""",
        """    case PInst{instruction}:
      w5b_bp_inst(x187_build_section(build),instruction,build)""",
        "x187_build_parsed_inst_zero_closure",
    )

    src = replace_exact(
        src,
        """@unsafe
def x187_build_parsed(+parsed: X187Parsed, +build: X187Build) -> X187Build:""",
        """@unsafe
def w5b_bp_inst(sec: U32, +instruction: X187Instruction, +build: X187Build) -> X187Build:
  match sec:
    case 1: x188_build_instruction(instruction,build)
    case _: x187_build_error("instruction outside text",build)

@unsafe
def x187_build_parsed(+parsed: X187Parsed, +build: X187Build) -> X187Build:""",
        "x187_build_parsed_inst_helper",
    )

    # ------------------------------------------------------------------
    # 6. x187_e_prefix / x187_e_mem / x187_build_seq_work zero-closure
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x187_e_prefix(+legacy: U32, wide: Bool, reg: U32, +operand: X187Operand, force: Bool) -> List<&2,U32>:
  +rex = U32.add(64,U32.add(nt_choose(U32,wide,u => 8,u => 0),U32.add(
    nt_choose(U32,U32.is_ge(reg,8),u => 4,u => 0),U32.add(x191_e_rex_x(operand),
      nt_choose(U32,U32.is_ge(x187_e_index(operand),8),u => 1,u => 0)))))
  nt_append(U32,nt_choose(List<&2,U32>,U32.is_eq(legacy,0),u => [],u => [legacy]),
    nt_choose(List<&2,U32>,U32.is_gt(rex,64) || force,u => [rex],u => []))

@unsafe
def x187_e_mem(+base: U32, +disp: U32, +reg: U32) -> List<&2,U32>:
  +low = U32.mod(base,8)
  +mode = nt_choose(U32,U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5)),u => 0,u =>
    nt_choose(U32,U32.is_le(disp,127) || U32.is_ge(disp,4294967168),v => 1,v => 2))
  Con{U32.add(U32.mul(mode,64),U32.add(U32.mul(U32.mod(reg,8),8),low)),
    nt_append(U32,nt_choose(List<&2,U32>,U32.is_eq(low,4),u => [36],u => []),
      nt_choose(List<&2,U32>,U32.is_eq(mode,0),u => [],u =>
        x187_e_le(disp,nt_choose(U32,U32.is_eq(mode,1),v => 1,v => 4))))}""",
        """@unsafe
def w5b_b2u(b: Bool, v: U32) -> U32:
  match b:
    case True{}: v
    case False{}: 0

@unsafe
def w5b_e_prefix_tail(+legacy: U32, tail: List<&2,U32>) -> List<&2,U32>:
  match legacy:
    case 0: tail
    case _: Con{legacy,tail}

@unsafe
def w5b_e_prefix_rex(emitRex: Bool, +legacy: U32, +rex: U32) -> List<&2,U32>:
  match emitRex:
    case True{}: w5b_e_prefix_tail(legacy,[rex])
    case False{}: w5b_e_prefix_tail(legacy,[])

@unsafe
def x187_e_prefix(+legacy: U32, wide: Bool, reg: U32, +operand: X187Operand, force: Bool) -> List<&2,U32>:
  +rex = U32.add(64,U32.add(w5b_b2u(wide,8),U32.add(
    w5b_b2u(U32.is_ge(reg,8),4),U32.add(x191_e_rex_x(operand),
      w5b_b2u(U32.is_ge(x187_e_index(operand),8),1)))))
  w5b_e_prefix_rex(U32.is_gt(rex,64) || force,legacy,rex)

@unsafe
def w5b_e_mem_mode2(short: Bool) -> U32:
  match short:
    case True{}: 1
    case False{}: 2

@unsafe
def w5b_e_mem_mode(zero: Bool, +disp: U32) -> U32:
  match zero:
    case True{}: 0
    case False{}: w5b_e_mem_mode2(U32.is_le(disp,127) || U32.is_ge(disp,4294967168))

@unsafe
def w5b_e_mem_disp(+mode: U32, +disp: U32) -> List<&2,U32>:
  match mode:
    case 0: []
    case 1: x187_e_le(disp,1)
    case _: x187_e_le(disp,4)

@unsafe
def w5b_e_mem_sib(low: U32, dtail: List<&2,U32>) -> List<&2,U32>:
  match low:
    case 4: Con{36,dtail}
    case _: dtail

@unsafe
def x187_e_mem(+base: U32, +disp: U32, +reg: U32) -> List<&2,U32>:
  +low = U32.mod(base,8)
  +mode = w5b_e_mem_mode(U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5)),disp)
  Con{U32.add(U32.mul(mode,64),U32.add(U32.mul(U32.mod(reg,8),8),low)),
    w5b_e_mem_sib(low,w5b_e_mem_disp(mode,disp))}""",
        "x187_e_prefix_mem_zero_closure",
    )

    src = replace_exact(
        src,
        """@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_seq_next(todo,build,count),u => build)

@unsafe
def x187_build_seq_next(todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match todo:
    case Nil{}: build
    case Con{head,rest}:
      nt_choose(X187Build,U32.is_lt(count,67108864),
        u => x187_build_seq_item(head,rest,build,U32.inc(count)),
        u => x187_build_error("x86 object fragment count exceeds bound",build))""",
        """@unsafe
def w5b_seq_work_if(ok: Bool, todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: x187_build_seq_next(todo,build,count)
    case False{}: build

@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  w5b_seq_work_if(String.is_empty(x187_build_message(build)),todo,build,count)

@unsafe
def w5b_seq_next_if(ok: Bool, head: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: x187_build_seq_item(head,rest,build,U32.inc(count))
    case False{}: x187_build_error("x86 object fragment count exceeds bound",build)

@unsafe
def x187_build_seq_next(todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match todo:
    case Nil{}: build
    case Con{head,rest}: w5b_seq_next_if(U32.is_lt(count,67108864),head,rest,build,count)""",
        "x187_build_seq_work_zero_closure",
    )

    # ------------------------------------------------------------------
    # 7. x187_e_single / x187_e_pair / x187_encode_spec / x187_encode O(1) match family
    # ------------------------------------------------------------------
    src = replace_optional(
        src,
        """@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,9),u => x187_e_branch(operand,code,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,8),u => nt_choose(X187Encoded,x187_e_reg(operand,64,False{}),v =>
    x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))])),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,5) && x187_e_rm(operand,8,False{}),u =>
    x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset),u => x187_e_error())))

@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,1),u => x187_e_alu(src,dst,width,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,2),u => x187_e_mov(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,15),u => x187_e_movabs(src,dst),u =>
  nt_choose(X187Encoded,U32.is_eq(family,3),u => x187_e_shift(src,dst,width,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,4),u => x187_e_imul(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,6),u => nt_choose(X187Encoded,x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),v =>
    x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,7),u => x187_e_sse(src,dst,prefix,code,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,10),u => x187_e_movd(src,dst,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,11),u => nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),v =>
    x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,12),u => nt_choose(X187Encoded,x187_e_reg(dst,64,False{}) &&
    x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),v =>
      x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,13),u => x187_e_test(src,dst,width,offset),u =>
    nt_choose(X187Encoded,U32.is_eq(family,16),v => x191cm_pair(src,dst,width,code,offset),v => x187_e_error()))))))))))))""",
        """@unsafe
def w5b_es_f8(ok: Bool, +operand: X187Operand, +code: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))]))
    case False{}: x187_e_error()

@unsafe
def w5b_es_f5(ok: Bool, +operand: X187Operand, +code: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset)
    case False{}: x187_e_error()

@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match family:
    case 9: x187_e_branch(operand,code,extra,offset)
    case 8: w5b_es_f8(x187_e_reg(operand,64,False{}),operand,code)
    case 5: w5b_es_f5(x187_e_rm(operand,8,False{}),operand,code,offset)
    case _: x187_e_error()

@unsafe
def w5b_ep_f6(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset)
    case False{}: x187_e_error()

@unsafe
def w5b_ep_f11(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w5b_ep_f12(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  match family:
    case 1: x187_e_alu(src,dst,width,extra,offset)
    case 2: x187_e_mov(src,dst,width,offset)
    case 15: x187_e_movabs(src,dst)
    case 3: x187_e_shift(src,dst,width,extra,offset)
    case 4: x187_e_imul(src,dst,width,offset)
    case 6: w5b_ep_f6(x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),src,dst,offset)
    case 7: x187_e_sse(src,dst,prefix,code,offset)
    case 10: x187_e_movd(src,dst,offset)
    case 11: w5b_ep_f11(x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),src,dst,offset)
    case 12: w5b_ep_f12(x187_e_reg(dst,64,False{}) && x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),src,dst,offset)
    case 13: x187_e_test(src,dst,width,offset)
    case 16: x191cm_pair(src,dst,width,code,offset)
    case _: x187_e_error()""",
        "x187_e_single_pair_match_family",
    )

    src = replace_exact(
        src,
        """@unsafe
def x187_encode_spec(spec: X187Op, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match spec:
    case X187Op{+family,width,code,extra,prefix}:
      nt_choose(X187Encoded,U32.is_eq(family,17),
        u => x192_float_cvtt_operands(operands,offset),
        u => x187_e_selected(X187Op{family,width,code,extra,prefix},operands,offset))
    case X187OpNone{}: x187_e_error()

@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      nt_choose(X187Encoded,U32.is_le(offset,4294967280),
        u => x187_encode_spec(x187_e_spec(op),operands,offset),u => x187_e_error())""",
        """@unsafe
def w5b_enc_spec_f(family: U32, width: U32, code: U32, extra: U32, prefix: U32,
    +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match family:
    case 17: x192_float_cvtt_operands(operands,offset)
    case _: x187_e_selected(X187Op{family,width,code,extra,prefix},operands,offset)

@unsafe
def x187_encode_spec(spec: X187Op, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match spec:
    case X187Op{family,width,code,extra,prefix}: w5b_enc_spec_f(family,width,code,extra,prefix,operands,offset)
    case X187OpNone{}: x187_e_error()

@unsafe
def w5b_enc_off_ok(ok: Bool, +op: String, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_encode_spec(x187_e_spec(op),operands,offset)
    case False{}: x187_e_error()

@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      w5b_enc_off_ok(U32.is_le(offset,4294967280),op,operands,offset)""",
        "x187_encode_zero_closure",
    )

    # ------------------------------------------------------------------
    # 8. x185_t_event zero-closure
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x185_t_event(+name: String, +write: Bool, +scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{+ranges,+names,+position,+region}:
      +old = p111v_get(ranges,name)
      nt_choose(X185TScan,x181_register_reserved(name),u => scan,u =>
        nt_choose(X185TScan,agy_str_eq(dk(old),"Absent"),
          v => nt_choose(X185TScan,write,
            w => X185TScan{x185_t_range(name,position,position,region,ranges),Con{name,names},position,region},
            w => x185_t_forbid(name,scan)),
          v => nt_choose(X185TScan,agy_str_eq(dk(old),"X185TRange"),
            w => nt_choose(X185TScan,U32.is_eq(ix(dt(old)),region),
              z => X185TScan{x185_t_range(name,da(old),position,region,ranges),names,position,region},
              z => x185_t_forbid(name,scan)),w => scan)))""",
        """@unsafe
def w5b_te_wr(write: Bool, +name: String, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match write:
    case True{}: X185TScan{x185_t_range(name,position,position,region,ranges),Con{name,names},position,region}
    case False{}: x185_t_forbid(name,scan)

@unsafe
def w5b_te_same_reg(same: Bool, +name: String, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match same:
    case True{}: X185TScan{x185_t_range(name,da(old),position,region,ranges),names,position,region}
    case False{}: x185_t_forbid(name,scan)

@unsafe
def w5b_te_is_rng(isRng: Bool, +name: String, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match isRng:
    case True{}: w5b_te_same_reg(U32.is_eq(ix(dt(old)),region),name,old,ranges,names,position,region,scan)
    case False{}: scan

@unsafe
def w5b_te_absent(isAbs: Bool, +name: String, +write: Bool, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match isAbs:
    case True{}: w5b_te_wr(write,name,ranges,names,position,region,scan)
    case False{}: w5b_te_is_rng(String.eq(dk(old),"X185TRange"),name,old,ranges,names,position,region,scan)

@unsafe
def w5b_te_res(res: Bool, +name: String, +write: Bool, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match res:
    case True{}: scan
    case False{}:
      +old = p111v_get(ranges,name)
      w5b_te_absent(String.eq(dk(old),"Absent"),name,write,old,ranges,names,position,region,scan)

@unsafe
def x185_t_event(+name: String, +write: Bool, +scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{+ranges,+names,+position,+region}:
      w5b_te_res(x181_register_reserved(name),name,write,ranges,names,position,region,scan)""",
        "x185_t_event_zero_closure",
    )

    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, type=Path)
    ap.add_argument("--dst", required=True, type=Path)
    args = ap.parse_args()

    src_text = args.src.read_text()
    out_text = apply_patches(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out_text)
    print(f"Wrote {args.dst} ({len(out_text)} bytes)", flush=True)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Wave 5 C1: Backend Compile-Time Profiler & O(N^2) Killer.

Composable, 100% bit-exact compile-time optimizations on top of wave4c_unified/compiler.bend:
  1. Native O(1) String.eq for agy_str_eq and p88_string_eq (compiles to JS `===`).
  2. Zero-closure 1-scrutinee Bool-dispatch helpers in core hash trie
     (index_find, index_bucket, index_tip, index_join, index_insert).
  3. Zero-closure 1-scrutinee Bool-dispatch helpers in CSE hot loops
     (x186_e_kill_facts, x186_e_kill_aliases, x186_e_find).
  4. Single-pass w5_scan_flags pre-guards + zero-roundtrip w5_flat_rev_seq in w4_post_select.
  5. Eliminate O(N^2 log N) W4CMap trie rebuilds in w4c_xmm_opt (w4c_fwd_try, w4c_slot_written,
     w4c_slot_touched, w4c_inst_writes_slot) and skip XMM/loop/LICM passes when absent.

Usage:
  python3 -B research/agy/wave5_compile/apply_compile_fast.py \
    --src selfhost/build/agy/wave4c_unified/compiler.bend \
    --dst selfhost/build/agy/wave5_c1/compiler.bend
"""

import argparse
from pathlib import Path


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def replace_optional(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt == 1:
        return text.replace(old, new, 1)
    if cnt == 0:
        print(f"[{label}] already upgraded by earlier pass, skipping", flush=True)
        return text
    raise ValueError(f"[{label}] expected 0 or 1 match, found {cnt}")


def apply_patches(src: str) -> str:
    # 1. Native O(1) String.eq for p88_string_eq and agy_str_eq
    src = replace_exact(
        src,
        """def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

@unsafe
def agy_str_eq_go(same: Bool, a: String, b: String) -> Bool:
  match same:
    case False{}: False{}
    case True{}:
      match a b:
        case SNil{} SNil{}: True{}
        case SCon{h1, t1} SCon{h2, t2}:
          agy_str_eq_go(U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)), t1, t2)
        case _ _: False{}

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(agy_str_eq_go(True{}, a, b), a, b)""",
        """def p88_string_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)""",
        "native_string_eq",
    )

    # 1b. Native O(1) String.eq for p98_tag_eq_read
    src = replace_exact(
        src,
        """def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq_go("Lam", key, True{})
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq_go("Lit", key, True{})""",
        """def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      String.eq(tag, key)
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      String.eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      String.eq("Lit", key)""",
        "native_p98_tag_eq",
    )

    # 1c. Zero-closure + single-lookup + hash-reusing p113k_join (optional if W5-C2 Patricia trie already replaced it)
    src = replace_optional(
        src,
        """@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record(head,right,out))


@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +found = p111v_get(right,name)
  nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
    u => p113k_put(out,name,p113k_join_fact(P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},p113k_get(right,name))),
    u => out)


@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p113k_join_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p113k_join(b,right,p113k_join(a,right,out))
    case _: out""",
        """@unsafe
def w5_p113k_join_hit(ok: Bool, +name: String, +record: KDef, +found: KDef, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}:
      p113k_put(out,name,p113k_join_fact(
        P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
        P113KFact{da(found),U32.is_eq(dx(found),1),ix(dv(found)),qt(dv(found))}))

@unsafe
def w5_p113k_join_rec_h(+hash: U32, +record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +found = index_find(right,name,hash,32)
  w5_p113k_join_hit(String.eq(dk(found),"P113KFact"),name,record,found,out)

@unsafe
def w5_p113k_join_bkt_h(+hash: U32, bucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: w5_p113k_join_bkt_h(hash,rest,right,w5_p113k_join_rec_h(hash,head,right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +hash = index_hash(name,2166136261)
  w5_p113k_join_rec_h(hash,record,right,out)

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record(head,right,out))

@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5_p113k_join_bkt_h(hash,bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p113k_join(b,right,p113k_join(a,right,out))
    case _: out""",
        "fast_p113k_join",
    )

    # 1d. Zero-closure p131i_insert (4.8s -> ~0.3s!)
    src = replace_exact(
        src,
        """@unsafe
def p131i_insert(+tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      kc(KDef, U32.is_eq(mask, 0),
        u => index_leaf(d, hash, bucket),
        u => index_join(tree, d, hash, mask))
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      kc(KDef, U32.is_eq(split, 0),
        u => p131i_original_set(tree, d, hash, 32),
        u => kc(KDef, U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash))),
          v => index_join(tree, d, hash, index_split_bit(diff))))""",
        """law p131i_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  KDef

@unsafe
def w5_p131i_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def w5_p131i_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, p131i_insert(left, d, hash), right)
    case False{}: index_node(stored, split, left, p131i_insert(right, d, hash))

@unsafe
def w5_p131i_in(inSub: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match inSub:
    case True{}: w5_p131i_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash)
    case False{}: index_join(tree, d, hash, index_split_bit(diff))

@unsafe
def w5_p131i_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match isZero:
    case True{}: p131i_original_set(tree, d, hash, 32)
    case False{}: w5_p131i_in(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0), tree, stored, split, left, right, d, hash, diff)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      w5_p131i_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      w5_p131i_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, diff)""",
        "zero_closure_p131i_insert",
    )

    # 2. Zero-closure core hash trie: index_find & index_bucket
    src = replace_exact(
        src,
        """@unsafe
def index_find(+tree: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      kc(KDef, p88_string_eq(kind, "Absent"), u => missing(),
        u => kc(KDef, U32.is_eq(templates, 0),
          v => kc(KDef, U32.is_eq(arity, hash),
            w => index_bucket(ctors, name), w => missing()),
          v => index_find(index_child_list(ctors,
            Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(stored, hash),
        u => index_bucket(bucket, name), u => missing())
    case KIndexNode{stored, +mask, +left, +right}:
      kc(KDef, U32.is_eq(mask, 0),
        u => kc(KDef, U32.is_eq(stored, hash),
          v => index_bucket([left, right], name), v => missing()),
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_find(left, name, hash, bits),
          v => index_find(right, name, hash, bits)))

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, agy_str_eq(dn(h), name), u => h, u => index_bucket(rest, name))""",
        """law index_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  for +bits: U32
  KDef

@unsafe
def w5_idx_bucket_if(ok: Bool, bucket: List<&2, KDef>, +name: String) -> KDef:
  match ok:
    case True{}: index_bucket(bucket, name)
    case False{}: missing()

@unsafe
def w5_idx_find_branch(goLeft: Bool, left: KDef, right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match goLeft:
    case True{}: index_find(left, name, hash, bits)
    case False{}: index_find(right, name, hash, bits)

@unsafe
def w5_idx_find_node(isLeaf: Bool, +stored: U32, +mask: U32, +left: KDef, +right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(stored, hash), [left, right], name)
    case False{}: w5_idx_find_branch(U32.is_eq(U32.and(hash, mask), 0), left, right, name, hash, bits)

@unsafe
def w5_idx_find_kdef_t(isLeaf: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name)
    case False{}: index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)

@unsafe
def w5_idx_find_kdef(isAbs: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isAbs:
    case True{}: missing()
    case False{}: w5_idx_find_kdef_t(U32.is_eq(templates, 0), arity, templates, ctors, name, hash, bits)

@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5_idx_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash, bits)
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, +mask, +left, +right}:
      w5_idx_find_node(U32.is_eq(mask, 0), stored, mask, left, right, name, hash, bits)

@unsafe
def w5_idx_bkt_hit(hit: Bool, h: KDef, rest: List<&2, KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: index_bucket(rest, name)

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{+h, rest}:
      w5_idx_bkt_hit(String.eq(dn(h), name), h, rest, name)""",
        "zero_closure_index_find_bucket",
    )

    # 2b. Zero-closure index_tip, index_join, index_insert
    src = replace_exact(
        src,
        """@unsafe
def index_tip(
  +tree: KDef,
  +hash: U32,
) -> KDef:
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kc(KDef, U32.is_eq(templates, 0), u => tree,
        u => index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash))
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      kc(KDef, U32.is_eq(mask, 0), u => tree,
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_tip(left, hash), v => index_tip(right, hash)))""",
        """law index_tip:
  for +tree: KDef
  for +hash: U32
  KDef

@unsafe
def w5_idx_tip_br(goLeft: Bool, left: KDef, right: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_tip(left, hash)
    case False{}: index_tip(right, hash)

@unsafe
def w5_idx_tip_node(isLeaf: Bool, +tree: KDef, +mask: U32, left: KDef, right: KDef, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: w5_idx_tip_br(U32.is_eq(U32.and(hash, mask), 0), left, right, hash)

@unsafe
def w5_idx_tip_kdef(isLeaf: Bool, +tree: KDef, +templates: U32, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash)

@unsafe
def index_tip(tree, hash):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      w5_idx_tip_kdef(U32.is_eq(templates, 0), tree, templates, hash)
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      w5_idx_tip_node(U32.is_eq(mask, 0), tree, mask, left, right, hash)""",
        "zero_closure_index_tip",
    )

    src = replace_exact(
        src,
        """@unsafe
def index_join(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
    u => index_node(da(tree), mask, index_leaf(d, hash, Nil{}), tree),
    u => index_node(da(tree), mask, tree, index_leaf(d, hash, Nil{})))

# Module: src/core/index.bend:203
@unsafe
def index_insert(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(mask, 0),
        u => index_leaf(d, hash, bucket), u => index_join(tree, d, hash, mask))
    case KIndexNode{stored, split, left, right}:
      kc(KDef, U32.is_eq(split, 0), u => index_insert_legacy(tree, d, hash, mask),
      u => kc(KDef, Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split),
        u => index_join(tree, d, hash, mask),
        u => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
          u => index_node(stored, split, index_insert(left, d, hash, mask), right),
          u => index_node(stored, split, left, index_insert(right, d, hash, mask)))))""",
        """@unsafe
def w5_idx_join_if(goLeft: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(da(tree), mask, index_leaf(d, hash, Nil{}), tree)
    case False{}: index_node(da(tree), mask, tree, index_leaf(d, hash, Nil{}))

@unsafe
def index_join(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  w5_idx_join_if(U32.is_eq(U32.and(hash, mask), 0), tree, d, hash, mask)

law index_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

law index_insert_legacy:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

@unsafe
def w5_idx_ins_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def w5_idx_ins_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, index_insert(left, d, hash, mask), right)
    case False{}: index_node(stored, split, left, index_insert(right, d, hash, mask))

@unsafe
def w5_idx_ins_split(doJoin: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match doJoin:
    case True{}: index_join(tree, d, hash, mask)
    case False{}: w5_idx_ins_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash, mask)

@unsafe
def w5_idx_ins_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match isZero:
    case True{}: index_insert_legacy(tree, d, hash, mask)
    case False{}: w5_idx_ins_split(Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:203
@unsafe
def index_insert(tree, d, hash, mask):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      w5_idx_ins_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      w5_idx_ins_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, mask)""",
        "zero_closure_index_join_insert",
    )

    # Also update index_insert_legacy header since it now has a law above
    src = replace_exact(
        src,
        """# Module: src/core/index.bend:224
@unsafe
def index_insert_legacy(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:""",
        """# Module: src/core/index.bend:224
@unsafe
def index_insert_legacy(tree, d, hash, mask):""",
        "index_insert_legacy_hdr",
    )

    # 3. Zero-closure CSE hot loops: x186_e_kill_facts, x186_e_kill_aliases, x186_e_find (optional if W5-C2 X186FactTrie replaced them)
    src = replace_optional(
        src,
        """@unsafe
def x186_e_kill_facts(facts: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          nt_choose(List<&2,X186Expr>,agy_str_eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),
            u => x186_e_kill_facts(rest,name),u => Con{fact,x186_e_kill_facts(rest,name)})

@unsafe
def x186_e_kill_aliases(aliases: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          nt_choose(List<&2,X186Alias>,agy_str_eq(result,name) || x185_sf_source(value,name),
            u => x186_e_kill_aliases(rest,name),u => Con{alias,x186_e_kill_aliases(rest,name)})""",
        """law x186_e_kill_facts:
  for facts: List<&2,X186Expr>
  for +name: String
  List<&2,X186Expr>

@unsafe
def w5_kill_fact_if(drop: Bool, fact: X186Expr, rest: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match drop:
    case True{}: x186_e_kill_facts(rest,name)
    case False{}: Con{fact,x186_e_kill_facts(rest,name)}

@unsafe
def x186_e_kill_facts(facts, name):
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          w5_kill_fact_if(String.eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),fact,rest,name)

law x186_e_kill_aliases:
  for aliases: List<&2,X186Alias>
  for +name: String
  List<&2,X186Alias>

@unsafe
def w5_kill_alias_if(drop: Bool, alias: X186Alias, rest: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match drop:
    case True{}: x186_e_kill_aliases(rest,name)
    case False{}: Con{alias,x186_e_kill_aliases(rest,name)}

@unsafe
def x186_e_kill_aliases(aliases, name):
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          w5_kill_alias_if(String.eq(result,name) || x185_sf_source(value,name),alias,rest,name)""",
        "zero_closure_x186_kill",
    )

    src = replace_optional(
        src,
        """@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          agy_str_eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))""",
        """law x186_e_find:
  for facts: List<&2,X186Expr>
  for +kind: U32
  for +typ: N111Type
  for +op: String
  for +left: N111Value
  for +right: N111Value
  Maybe<&2,String>

@unsafe
def w5_e_find_if(hit: Bool, name: String, rest: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match hit:
    case True{}: Some{name}
    case False{}: x186_e_find(rest,kind,typ,op,left,right)

@unsafe
def x186_e_find(facts, kind, typ, op, left, right):
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      w5_e_find_if(U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          String.eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        name,rest,kind,typ,op,left,right)""",
        "zero_closure_x186_find",
    )

    # 4. Eliminate O(N^2 log N) W4CMap trie rebuilds in w4c_xmm_opt
    src = replace_exact(
        src,
        """# Check if slot is written anywhere in items
@unsafe
def w4c_slot_written(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_count_writes(items,W4CMEmpty{}),disp),0)

@unsafe
def w4c_slot_touched(+disp: U32, +items: List<&2,X187Parsed>) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_count_reads(items,W4CMEmpty{}),disp),0) ||
  U32.is_gt(w4c_get_cnt(w4c_count_writes(items,W4CMEmpty{}),disp),0)""",
        """# Direct O(N) early-exit slot checks (ZERO W4CMap trie allocations!)
@unsafe
def w5_op_is_slot(+disp: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,d}: U32.is_eq(b,5) && U32.is_eq(d,disp)
    case _: False{}

@unsafe
def w5_args_touch_slot(+disp: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w5_op_is_slot(disp,a) || w5_args_touch_slot(disp,rest)

@unsafe
def w5_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{_,Con{X187Mem{b,d},Nil{}}}}}:
      U32.is_eq(b,5) && U32.is_eq(d,disp) &&
      Bool.not(String.eq(op,"cmpq") || String.eq(op,"cmpl") || String.eq(op,"testq") || String.eq(op,"testl") || String.eq(op,"ucomiss"))
    case _: False{}

@unsafe
def w4c_slot_written(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w5_inst_writes_slot(disp,h) || w4c_slot_written(disp,rest)

@unsafe
def w4c_slot_touched(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}: w5_args_touch_slot(disp,args) || w4c_slot_touched(disp,rest)
    case Con{_,rest}: w4c_slot_touched(disp,rest)""",
        "fast_w4c_slot_checks",
    )

    src = replace_exact(
        src,
        """@unsafe
def w4c_fwd_try(+src: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      +restReads = w4c_get_cnt(w4c_count_reads(rest,W4CMEmpty{}),d)
      +ok = Bool.not(U32.is_eq(src,d)) && U32.is_eq(w4c_get_cnt(totW,d),1) &&
            U32.is_eq(restReads,w4c_get_cnt(totR,d)) && Bool.not(w4c_slot_written(src,rest))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_fwd_bb(w4c_replace_slot(d,src,rest),totR,totW,acc),
        u => w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc}))
    case _: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})""",
        """@unsafe
def w5_inc_if(b: Bool, +x: U32) -> U32:
  match b:
    case True{}: U32.inc(x)
    case False{}: x

@unsafe
def w5_count_slot_reads_args(+disp: U32, args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w5_count_slot_reads_args(disp,rest,w5_inc_if(w5_op_is_slot(disp,a),acc))

law w5_count_slot_reads:
  for +disp: U32
  for items: List<&2,X187Parsed>
  for +acc: U32
  U32

@unsafe
def w5_count_slot_reads_wo(isWo: Bool, +disp: U32, +src: X187Operand, +b: U32, +d: U32, rest: List<&2,X187Parsed>, +acc: U32) -> U32:
  match isWo:
    case True{}: w5_count_slot_reads(disp,rest,w5_inc_if(w5_op_is_slot(disp,src),acc))
    case False{}:
      +a1 = w5_inc_if(w5_op_is_slot(disp,src),acc)
      w5_count_slot_reads(disp,rest,w5_inc_if(U32.is_eq(b,5) && U32.is_eq(d,disp),a1))

@unsafe
def w5_count_slot_reads(disp, items, acc):
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{+op,+args}},rest}:
      match args:
        case Con{+src,Con{X187Mem{+b,+d},Nil{}}}:
          w5_count_slot_reads_wo(w4c_is_write_only_mem(op),disp,src,b,d,rest,acc)
        case _: w5_count_slot_reads(disp,rest,w5_count_slot_reads_args(disp,args,acc))
    case Con{_,rest}: w5_count_slot_reads(disp,rest,acc)

@unsafe
def w5_fwd_do(ok: Bool, +src: U32, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ok:
    case True{}: w4c_fwd_bb(w4c_replace_slot(d,src,rest),totR,totW,acc)
    case False{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w5_fwd_check(cand: Bool, +src: U32, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cand:
    case False{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})
    case True{}:
      w5_fwd_do(U32.is_eq(w5_count_slot_reads(d,rest,0),w4c_get_cnt(totR,d)) && Bool.not(w4c_slot_written(src,rest)),
        src,d,i0,i1,rest,totR,totW,acc)

@unsafe
def w4c_fwd_try(+src: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      w5_fwd_check(Bool.not(U32.is_eq(src,d)) && U32.is_eq(w4c_get_cnt(totW,d),1),src,d,i0,i1,rest,totR,totW,acc)
    case _: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})""",
        "fast_w4c_fwd_try",
    )

    src = replace_exact(
        src,
        """@unsafe
def w4c_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_inst_writes(item,W4CMEmpty{}),disp),0)""",
        """@unsafe
def w4c_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  w5_inst_writes_slot(disp,item)""",
        "fast_w4c_inst_writes_slot",
    )

    # 5. Pre-guarded + zero-roundtrip w4_post_select & w4c_xmm_opt
    old_w4_post_block = """@unsafe
def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])
  nt_choose(List<&2,X187Parsed>,w4c_has_leaq_rbp(p1),
    u => p1,
    u => w4c_xmm_opt_nolea(p1))

@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  w4c_dead_slot_elim(p8)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])
  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))
  +f5 = w4_peep_flat([peep5],[])
  +xmm = w4c_xmm_opt(f5)
  w4b_wrap_items(xmm,[])"""

    new_w4_post_block = """# W5-C1: Single-pass bitmask scanner + zero-roundtrip sequence flattener + guarded post-select
@unsafe
def w5_bit_if(b: Bool, +bit: U32, +acc: U32) -> U32:
  match b:
    case True{}: U32.or(acc,bit)
    case False{}: acc

@unsafe
def w5_op_flags(op: X187Operand) -> U32:
  match op:
    case X187Reg{_,_,True{}}: 1
    case X187Mem{b,d}: w5_bit_if(w4c_is_neg_rbp(b,d),2,0)
    case _: 0

@unsafe
def w5_args_flags(args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w5_args_flags(rest,U32.or(acc,w5_op_flags(a)))

@unsafe
def w5_scan_flags(items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PLabel{_},rest}: w5_scan_flags(rest,U32.or(acc,4))
    case Con{PInst{X187Instruction{+op,args}},rest}:
      +f1 = w5_bit_if(String.eq(op,"imulq"),8,acc)
      +f2 = w5_bit_if(String.eq(op,"call"),16,f1)
      w5_scan_flags(rest,w5_args_flags(args,f2))
    case Con{_,rest}: w5_scan_flags(rest,acc)

@unsafe
def w5_flat_rev_seq(todo: List<&2,X188Seq>, acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match todo:
    case Nil{}: acc
    case Con{X188Empty{},rest}: w5_flat_rev_seq(rest,acc)
    case Con{X188Join{a,b},rest}: w5_flat_rev_seq(Con{b,Con{a,rest}},acc)
    case Con{X188One{item},rest}: w5_flat_rev_seq(rest,Con{item,acc})

@unsafe
def w5_xmm_opt_noxmm_go(hasLea: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLea:
    case True{}: items
    case False{}:
      +p2 = w4c_copy_slot_fwd(items)
      +p4 = w4c_backedge_coalesce(p2)
      w4c_dead_slot_elim(p4)

@unsafe
def w5_xmm_opt_noxmm(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w5_xmm_opt_noxmm_go(w4c_has_leaq_rbp(items),items)

@unsafe
def w5_xmm_opt_go(hasLea: Bool, +p1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLea:
    case True{}: p1
    case False{}: w4c_xmm_opt_nolea(p1)

@unsafe
def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])
  w5_xmm_opt_go(w4c_has_leaq_rbp(p1),p1)

@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  w4c_dead_slot_elim(p8)

@unsafe
def w5_run_licm(doLicm: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match doLicm:
    case True{}: w4b_licm_magic(items)
    case False{}: items

@unsafe
def w5_run_rot(hasLbl: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLbl:
    case False{}: items
    case True{}:
      +rot = w4b_rotate_loop(items)
      +rot2 = w5_flat_rev_seq(w4b_copy_peep(rot,rot,[]),[])
      w5_flat_rev_seq(w4c_peep_cfg(rot2,rot2,[]),[])

@unsafe
def w5_run_xmm_rbp(hasNegRbp: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasNegRbp:
    case True{}: w5_xmm_opt_noxmm(items)
    case False{}: items

@unsafe
def w5_run_xmm(hasXmm: Bool, +hasNegRbp: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasXmm:
    case True{}: w4c_xmm_opt(items)
    case False{}: w5_run_xmm_rbp(hasNegRbp,items)

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
  +f2 = w5_flat_rev_seq(w4b_copy_peep(f1,f1,[]),[])
  +f3 = w5_flat_rev_seq(w4b_copy_peep(f2,f2,[]),[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +f5 = w5_run_rot(hasLbl,licm)
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,f5)
  w4b_wrap_items(xmm,[])"""

    if old_w4_post_block in src:
        src = replace_exact(src, old_w4_post_block, new_w4_post_block, "guarded_w4_post_select")
    else:
        # Composing on top of W5-R2 (w5_xmm_fold + w5_gpr_peep) and/or W5-R3 (disjoint-buf w4c_xmm_opt_nolea)
        old_r2_post = """@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  +p9 = w4c_dead_slot_elim(p8)
  +p10 = w5_xmm_fold(p9,p9,[])
  w5_xmm_fold(p10,p10,[])

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])
  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))
  +f5 = w4_peep_flat([peep5],[])
  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +xmm = w4c_xmm_opt(g3)
  w4b_wrap_items(xmm,[])"""
        # Drop duplicate w4c_xmm_opt (already defined earlier before W5_PASSES!) and preserve w5_xmm_fold + w5_gpr_peep
        new_r2_post = new_w4_post_block.replace(
            """@unsafe
def w5_xmm_opt_go(hasLea: Bool, +p1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLea:
    case True{}: p1
    case False{}: w4c_xmm_opt_nolea(p1)

@unsafe
def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])
  w5_xmm_opt_go(w4c_has_leaq_rbp(p1),p1)

""", ""
        ).replace(
            "  w4c_dead_slot_elim(p8)",
            "  +p9 = w4c_dead_slot_elim(p8)\n  +p10 = w5_xmm_fold(p9,p9,[])\n  w5_xmm_fold(p10,p10,[])"
        ).replace(
            "  +xmm = w5_run_xmm(hasXmm,hasNegRbp,f5)",
            "  +g1 = w5_gpr_peep(f5,f5,[])\n  +g2 = w5_gpr_peep(g1,g1,[])\n  +g3 = w5_gpr_peep(g2,g2,[])\n  +xmm = w5_run_xmm(hasXmm,hasNegRbp,g3)"
        )
        src = replace_exact(src, old_r2_post, new_r2_post, "guarded_w4_post_select (W5-R2+R3)")

    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, type=Path)
    ap.add_argument("--dst", required=True, type=Path)
    args = ap.parse_args()
    text = args.src.read_text()
    out = apply_patches(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"Patched {args.src} -> {args.dst} ({len(text)} -> {len(out)} bytes)")


if __name__ == "__main__":
    main()

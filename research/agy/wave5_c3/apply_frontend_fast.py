#!/usr/bin/env python3
"""Wave 5 Track W5-C3: Frontend / Lowering / Verifier / Core-Insert Compile-Speed Patcher.

100% orthogonal to W5-C1 (apply_compile_fast.py) and W5-C2 (apply_struct_fast.py).
Zero overlap with p88_string_eq/agy_str_eq/p98_tag_eq_read/index_find/index_bucket/
index_tip/index_join/index_insert/index_remove/p113k_*/x186_e_*/x187_*/w4_post_select/w4c_*.

Six 100% bit-exact optimizations (strictly 1-scrutinee parameter matches, zero closures):
  1. p98_tag_eq: direct KTerm match + native O(1) String.eq (skips p98_tag_eq_read/finish).
  2. p131i_insert / p131i_original_set: zero-closure direct parameter match + String.eq.
  3. nd_native_call / nd_native_head / nd_native_saturated / nd_head / nd_args:
     zero-closure parameter match + direct U32 arg-count (no intermediate List).
  4. p111v_* (universal hash-map get + N111 IR verifier):
     - Zero-closure w5c3_find / w5c3_bucket using String.eq in p111v_get.
     - Direct O(min(|L|,|R|)) Patricia-tree p111v_intersection (zero re-hashing/rebuilds).
     - Zero-closure + String.eq + single-hash/single-lookup across p111v_*.
  5. p205u_refs / p205u_vars + p205v_* (44.2% of p86_plan frontend time):
     - Early-exit p205u_refs_fields / p205u_vars_fields at >= 2 and w5c3_has_var at >= 1.
     - Guard p205v_fold_bool on Bool.and/Bool.or BEFORE inspecting arg values.
     - Guard p205v_words on non-empty/range-cmp op BEFORE calling p205v_range.
     - Compute nd_native_call once in p205v_pure_call; zero-closure + String.eq throughout.
  6. w2d_walk* (13.8% of p86_plan frontend time):
     - Zero-closure parameter match + String.eq throughout w2d_walk / w2d_walk_call.
"""

import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave4c_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave5_c3/compiler.bend")


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"Patch {label!r}: expected 1 match, found {n}")
    return text.replace(old, new, 1)


def apply_patches(src: str) -> str:
    if "# AGY-W5-C3-FRONTEND" in src:
        return src

    # 1. p98_tag_eq: direct KTerm match + native O(1) String.eq (leaves p98_tag_eq_read untouched)
    src = replace_exact(
        src,
        """def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)""",
        """# AGY-W5-C3-FRONTEND
def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  match term:
    case KTerm{tag, _, _, _, _, _, _, _}: String.eq(tag, key)
    case KLambda{_, _, _, _, _, _, _, _}: String.eq("Lam", key)
    case KLiteral{_, _, _, _, _}: String.eq("Lit", key)""",
        "fast_p98_tag_eq",
    )

    # 2. p131i_insert & p131i_original_set: zero-closure direct parameter match
    # (Skip gracefully if already patched by W5-C1 for clean C1+C3 composability)
    old_p131i = """@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  kc(KDef, p88_string_eq(dk(tree), "Absent"), u => index_leaf(d, hash, Nil{}),
    u => index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash))))))


@unsafe
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
          v => index_join(tree, d, hash, index_split_bit(diff))))"""
    if old_p131i in src:
        src = replace_exact(
            src,
            old_p131i,
            """@unsafe
def w5c3_orig_set_if(is_abs: Bool, +tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match is_abs:
    case True{}: index_leaf(d, hash, Nil{})
    case False{}: index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash)))))

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  w5c3_orig_set_if(String.eq(dk(tree), "Absent"), tree, d, hash)

@unsafe
def w5c3_ins_leaf_if(same: Bool, +tree: KDef, +bucket: List<&2,KDef>, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match same:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

law p131i_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  KDef

@unsafe
def w5c3_ins_go_left(go_left: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match go_left:
    case True{}: index_node(stored, split, p131i_insert(left, d, hash), right)
    case False{}: index_node(stored, split, left, p131i_insert(right, d, hash))

@unsafe
def w5c3_ins_prefix_if(in_sub: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match in_sub:
    case True{}: w5c3_ins_go_left(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash)
    case False{}: index_join(tree, d, hash, index_split_bit(diff))

@unsafe
def w5c3_ins_node_if(zero_split: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match zero_split:
    case True{}: p131i_original_set(tree, d, hash, 32)
    case False{}: w5c3_ins_prefix_if(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0), tree, stored, split, left, right, d, hash, diff)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      w5c3_ins_leaf_if(U32.is_eq(mask, 0), tree, bucket, d, hash, mask)
    case KIndexNode{+stored, +split, left, right}:
      +diff = U32.xor(hash, stored)
      w5c3_ins_node_if(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, diff)""",
            "fast_p131i_insert",
        )

    # 3. nd_native_call / nd_head / nd_args: zero-closure parameter match + direct arg count
    src = replace_exact(
        src,
        """# Module: src/back/native/direct.bend:11
@unsafe
def nd_native_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  nt_choose(String, p98_tag_eq(t, "App"),
    u => nd_native_head(book, t, nd_head(t)), u => "")

# Module: src/back/native/direct.bend:16
@unsafe
def nd_native_head(+book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  nt_choose(String, p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)),
    u => nt_choose(String, nc_native_def(lookup(book, nm(head))),
      v => nd_native_saturated(t, nc_primitive_name(nm(head))), v => ""), u => "")

# Module: src/back/native/direct.bend:22
@unsafe
def nd_native_saturated(+t: KTerm, +name: String) -> String:
  nt_choose(String, U32.is_eq(terms_len(nd_args(t, Nil{})), nc_primitive_arity(name)), u => name, u => "")""",
        """@unsafe
def w5c3_str_if(cond: Bool, +yes: String) -> String:
  match cond:
    case True{}: yes
    case False{}: ""

law w5c3_nd_arg_count:
  for +t: KTerm
  for +acc: U32
  U32

@unsafe
def w5c3_nd_arg_count_if(is_app: Bool, +t: KTerm, +acc: U32) -> U32:
  match is_app:
    case True{}: w5c3_nd_arg_count(kid(t, 0), U32.inc(acc))
    case False{}: acc

@unsafe
def w5c3_nd_arg_count(t, acc):
  w5c3_nd_arg_count_if(p98_tag_eq(t, "App"), t, acc)

@unsafe
def w5c3_nd_call_if(is_app: Bool, +book: List<&2, KDef>, +t: KTerm) -> String:
  match is_app:
    case True{}: nd_native_head(book, t, nd_head(t))
    case False{}: ""

# Module: src/back/native/direct.bend:11
@unsafe
def nd_native_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  w5c3_nd_call_if(p98_tag_eq(t, "App"), book, t)

@unsafe
def w5c3_nd_head_nat(is_nat: Bool, +t: KTerm, +hname: String) -> String:
  match is_nat:
    case True{}: nd_native_saturated(t, nc_primitive_name(hname))
    case False{}: ""

@unsafe
def w5c3_nd_head_if(is_ref: Bool, +book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  match is_ref:
    case True{}:
      +hname = nm(head)
      w5c3_nd_head_nat(nc_native_def(lookup(book, hname)), t, hname)
    case False{}: ""

# Module: src/back/native/direct.bend:16
@unsafe
def nd_native_head(+book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  w5c3_nd_head_if(p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)), book, t, head)

# Module: src/back/native/direct.bend:22
@unsafe
def nd_native_saturated(+t: KTerm, +name: String) -> String:
  w5c3_str_if(U32.is_eq(w5c3_nd_arg_count(t, 0), nc_primitive_arity(name)), name)""",
        "fast_nd_native_call",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/direct.bend:66
@unsafe
def nd_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(t, "App"), u => nd_head(kid(t, 0)), u => t)

# Module: src/back/native/direct.bend:70
@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, p98_tag_eq(t, "App"), u => nd_args(kid(t, 0), Con{kid(t, 1), acc}), u => acc)""",
        """@unsafe
def w5c3_nd_head_step(is_app: Bool, +t: KTerm) -> KTerm:
  match is_app:
    case True{}: nd_head(kid(t, 0))
    case False{}: t

# Module: src/back/native/direct.bend:66
@unsafe
def nd_head(+t: KTerm) -> KTerm:
  w5c3_nd_head_step(p98_tag_eq(t, "App"), t)

@unsafe
def w5c3_nd_args_step(is_app: Bool, +t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  match is_app:
    case True{}: nd_args(kid(t, 0), Con{kid(t, 1), acc})
    case False{}: acc

# Module: src/back/native/direct.bend:70
@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  w5c3_nd_args_step(p98_tag_eq(t, "App"), t, acc)""",
        "fast_nd_head_args",
    )

    # 4. p111v_* (universal hash-map get + N111 IR verifier + Patricia-tree intersection)
    src = replace_exact(
        src,
        """@unsafe
def p111v_get(+tree: KDef, +name: String) -> KDef:
  index_find(tree,name,index_hash(name,2166136261),32)

@unsafe
def p111v_put(+tree: KDef, +name: String, +kind: String, +width: U32, +capacity: U32) -> KDef:
  index_set(tree,KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

def p111v_type(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 1
    case N111U64{}: 2
    case N111Ptr{}: 3

@unsafe
def p111v_name_chars(+name: String, +n: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(n,0)
    case SCon{h,t}:
      +c = Char.to_u32(h)
      U32.is_lt(n,128) && ((U32.is_ge(c,65) && U32.is_le(c,90)) ||
        (U32.is_ge(c,97) && U32.is_le(c,122)) || U32.is_eq(c,95) ||
        (U32.is_gt(n,0) && U32.is_ge(c,48) && U32.is_le(c,57))) && p111v_name_chars(t,U32.inc(n))

@unsafe
def p111v_raw_name_chars(+name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{head,rest}: U32.is_lt(count,4096) && Bool.not(U32.is_eq(Char.to_u32(head),0)) && p111v_raw_name_chars(rest,U32.inc(count))

@unsafe
def p111v_raw_name(+name: String) -> Bool:
  p111v_raw_name_chars(name,0)

@unsafe
def p111v_comparison(+op: String) -> Bool:
  agy_str_eq(op,"eq") || agy_str_eq(op,"ne") || agy_str_eq(op,"ult") || agy_str_eq(op,"ule") ||
  agy_str_eq(op,"ugt") || agy_str_eq(op,"uge") || agy_str_eq(op,"slt") || agy_str_eq(op,"sle") ||
  agy_str_eq(op,"sgt") || agy_str_eq(op,"sge")

@unsafe
def p111v_operator(+op: String) -> Bool:
  p111v_comparison(op) || agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"mul") ||
  agy_str_eq(op,"and") || agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"shl") ||
  agy_str_eq(op,"shr") || agy_str_eq(op,"sar")

@unsafe
def p111v_decl(+name: String, +width: U32, +capacity: U32, +alloca: Bool, +scan: P111VScan) -> P111VScan:
  match scan:
    case P111VScan{+index,+error,+count}:
      +old = p111v_get(index,name)
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,Bool.not(p111v_name_chars(name,0)) || agy_str_eq(name,"state"),u => P111VScan{index,"invalid/reserved local name: " ++ name,count},u =>
      nt_choose(P111VScan,Bool.not(agy_str_eq(dk(old),"Absent")) && (alloca || agy_str_eq(dk(old),"alloca") || Bool.not(U32.is_eq(da(old),width))),
        u => P111VScan{index,"local width/allocation changes: " ++ name,count},
        u => P111VScan{p111v_put(index,name,nt_choose(String,alloca,v => "alloca",v => "local"),width,capacity),"",
          nt_choose(U32,agy_str_eq(dk(old),"Absent"),v => U32.inc(count),v => count)})))

@unsafe
def p111v_schema_stmt(+stmt: N111Stmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case N111Set{name,typ,value}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Bin{name,typ,op,left,right}: p111v_decl(name,nt_choose(U32,p111v_comparison(op),u => 1,u => p111v_type(typ)),0,False{},scan)
    case N111Call{name,typ,symbol,args}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Load{name,typ,base,offset}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Offset{name,base,bytes}: p111v_decl(name,3,0,False{},scan)
    case N111Alloca{name,bytes,align}: p111v_decl(name,3,bytes,True{},scan)
    case N111If{condition,yes,no}: p111v_schema(no,p111v_schema(yes,scan))
    case _: scan

@unsafe
def p111v_schema(+body: List<&2,N111Stmt>, +scan: P111VScan) -> P111VScan:
  match body scan:
    case Nil{} _: scan
    case Con{head,rest} P111VScan{index,+error,+count}:
      nt_choose(P111VScan,String.is_empty(error) && U32.is_le(count,65535),u => p111v_schema(rest,p111v_schema_stmt(head,scan)),
        u => P111VScan{index,nt_choose(String,String.is_empty(error),v => "too many segment locals",v => error),count})

@unsafe
def p111v_value(+value: N111Value, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match value ids:
    case N111Local{name} _:
      +found = p111v_get(live,name)
      Bool.not(agy_str_eq(dk(found),"Absent")) && U32.is_eq(da(found),width)
    case N111Const{lo,hi} _:
      nt_choose(Bool,U32.is_eq(width,1),u => U32.is_eq(hi,0),u =>
        nt_choose(Bool,U32.is_eq(width,3),v => U32.is_eq(lo,0) && U32.is_eq(hi,0),v => U32.is_eq(width,2)))
    case N111FuncId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(agy_str_eq(dk(p111v_get(functions,name)),"Absent"))
    case N111CtorId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(agy_str_eq(dk(p111v_get(constructors,name)),"Absent"))
    case N111Symbol{name} _: False{}

@unsafe
def p111v_assign(+name: String, +schema: KDef, +live: KDef) -> KDef:
  +found = p111v_get(schema,name)
  p111v_put(live,name,dk(found),da(found),dx(found))

@unsafe
def p111v_step(+ok: Bool, +name: String, +schema: KDef, +live: KDef, +message: String) -> P111VFlow:
  nt_choose(P111VFlow,ok,u => P111VFlow{nt_choose(KDef,String.is_empty(name),v => live,v => p111v_assign(name,schema,live)),False{},""},
    u => P111VFlow{live,False{},message})

@unsafe
def p111v_capacity(+value: N111Value, +live: KDef) -> U32:
  match value:
    case N111Local{name}: dx(p111v_get(live,name))
    case _: 0

@unsafe
def p111v_memory(+base: N111Value, +offset: U32, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  +bytes = nt_choose(U32,U32.is_eq(width,1),u => 4,u => 8)
  +capacity = p111v_capacity(base,live)
  p111v_value(base,3,live,ids) && U32.is_ge(capacity,bytes) &&
    U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)

@unsafe
def p111v_intersection_bucket(+bucket: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      +found = p111v_get(other,dn(head))
      p111v_intersection_bucket(rest,other,nt_choose(KDef,agy_str_eq(dk(found),"Absent"),u => out,
        u => p111v_put(out,dn(head),dk(head),da(head),nt_choose(U32,U32.is_eq(dx(head),dx(found)),v => dx(head),v => 0))))

@unsafe
def p111v_intersection(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p111v_intersection_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p111v_intersection(b,right,p111v_intersection(a,right,out))
    case _: out

@unsafe
def p111v_join(+yes: P111VFlow, +no: P111VFlow) -> P111VFlow:
  match yes no:
    case P111VFlow{+yl,yt,+ye} P111VFlow{nl,+nt,+ne}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(ye)),u => yes,u =>
      nt_choose(P111VFlow,Bool.not(String.is_empty(ne)),u => no,u =>
      nt_choose(P111VFlow,yt,u => nt_choose(P111VFlow,nt,v => P111VFlow{yl,True{},""},v => no),u =>
      nt_choose(P111VFlow,nt,u => yes,u => P111VFlow{p111v_intersection(yl,nl,missing()),False{},""}))))

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.
@unsafe
def p111v_signature(+symbol: String) -> List<&2,U32>:
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_keep"),u => [3,2],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_sink"),u => [3,2],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_ctor"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_take"),u => [3,2,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_closure"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_tag"),u => [3,2],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_frame"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_jump"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_return"),u => [3,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_apply"),u => [3,2,2],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_stack_pop"),u => [3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_stack_get"),u => [3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_reg_get"),u => [3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_fail"),u => [3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_op"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_special_ctor"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_special_test"),u => [3,1,2],u =>
  nt_choose(List<&2,U32>,agy_str_eq(symbol,"p111_rt_special_take"),u => [3,1,2,3,1],u => []))))))))))))))))))

def p111v_primitive_arities() -> List<&2,U32>:
  [0,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2,2,2,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,2,2,2,1,2,2,2,2,2,2,2,3,3,1,1,3,3,3,3,3,3,3,4,3,1]

@unsafe
def p111v_at(+values: List<&2,U32>, +index: U32) -> U32:
  match values:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,U32.is_eq(index,0),u => head,u => p111v_at(rest,U32.sub(index,1)))

@unsafe
def p111v_arg(+args: List<&2,N111Arg>, +index: U32) -> N111Value:
  match args:
    case Nil{}: N111Symbol{"invalid"}
    case Con{N111Arg{typ,value},rest}: nt_choose(N111Value,U32.is_eq(index,0),u => value,u => p111v_arg(rest,U32.sub(index,1)))

def p111v_literal(value: N111Value) -> U32:
  match value:
    case N111Const{lo,hi}: nt_choose(U32,U32.is_eq(hi,0),u => lo,u => 4294967295)
    case _: 4294967295

@unsafe
def p111v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: KDef, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p111v_value(value,width,live,ids) && p111v_args(rest,more,live,ids)
    case _ _: False{}

@unsafe
def p111v_target(+value: N111Value, +ids: N111Ids, +constructor: Bool) -> KDef:
  match value ids:
    case N111CtorId{name} N111Ids{functions,constructors}:
      nt_choose(KDef,constructor,u => p111v_get(constructors,name),u => missing())
    case N111FuncId{name} N111Ids{functions,constructors}:
      nt_choose(KDef,constructor,u => missing(),u => p111v_get(functions,name))
    case _ _: missing()

@unsafe
def p111v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: KDef) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p111v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

@unsafe
def p111v_counted_call(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  +count = p111v_literal(p111v_arg(args,3))
  +target = p111v_target(p111v_arg(args,1),ids,agy_str_eq(symbol,"p111_rt_ctor"))
  p111v_buffer(args,2,count,live) &&
    nt_choose(Bool,agy_str_eq(symbol,"p111_rt_ctor"),u => Bool.not(agy_str_eq(dk(target),"Absent")) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,agy_str_eq(symbol,"p111_rt_jump"),u => Bool.not(agy_str_eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,agy_str_eq(symbol,"p111_rt_closure"),u => Bool.not(agy_str_eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target)),u =>
    nt_choose(Bool,agy_str_eq(symbol,"p111_rt_frame"),u => Bool.not(agy_str_eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target)),u => True{}))))

@unsafe
def p111v_special_arity(+kind: U32) -> U32:
  nt_choose(U32,U32.is_gt(kind,0) && U32.is_lt(kind,10),u => p111v_at([0,0,0,0,1,1,1,1,1,2],kind),u => 4294967295)

@unsafe
def p111v_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +id = p111v_literal(p111v_arg(args,1))
  +count = p111v_literal(p111v_arg(args,3))
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_ctor") || agy_str_eq(symbol,"p111_rt_take") || agy_str_eq(symbol,"p111_rt_closure") || agy_str_eq(symbol,"p111_rt_frame") || agy_str_eq(symbol,"p111_rt_jump"),
    u => p111v_counted_call(symbol,args,live,ids),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_return"),u => U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p111v_buffer(args,1,result,live),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_reg_get"),u => U32.is_lt(id,nt_choose(U32,U32.is_gt(incoming,0),v => incoming,v => arity)),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_stack_get"),u => U32.is_gt(incoming,0) && U32.is_lt(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_stack_pop"),u => U32.is_gt(incoming,0) && U32.is_eq(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_op"),u => U32.is_gt(id,0) && U32.is_lt(id,87) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p111v_buffer(args,2,count,live),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_special_ctor"),u => U32.is_eq(count,p111v_special_arity(id)) && p111v_buffer(args,2,count,live),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_special_take"),u => U32.is_eq(p111v_literal(p111v_arg(args,4)),p111v_special_arity(id)) && p111v_buffer(args,3,p111v_literal(p111v_arg(args,4)),live),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_special_test"),u => U32.is_gt(id,0) && U32.is_lt(id,10),u =>
  nt_choose(Bool,agy_str_eq(symbol,"p111_rt_fail"),u => U32.is_gt(id,0) && U32.is_le(id,8),u => True{}))))))))))

def p111v_state_argument(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: p88_string_eq(name,"state")
    case _: False{}

@unsafe
def p111v_call(+symbol: String, +typ: N111Type, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +sig = p111v_signature(symbol)
  Bool.not(U32.is_eq(nt_count(U32,sig),0)) && U32.is_eq(p111v_type(typ),2) &&
    p111v_state_argument(args) && p111v_args(args,sig,live,ids) && p111v_contract(symbol,args,live,ids,arity,incoming,result)

@unsafe
def p111v_offset(+name: String, +base: N111Value, +bytes: N111Value, +live: KDef, +ids: N111Ids) -> P111VFlow:
  +offset = p111v_literal(bytes)
  +capacity = p111v_capacity(base,live)
  nt_choose(P111VFlow,p111v_value(base,3,live,ids) && p111v_value(bytes,2,live,ids) && U32.is_le(offset,capacity),
    u => P111VFlow{p111v_put(live,name,"local",3,U32.sub(capacity,offset)),False{},""},
    u => P111VFlow{live,False{},"unbounded or ill-typed pointer offset"})

@unsafe
def p111v_stmt(+stmt: N111Stmt, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match stmt:
    case N111Set{name,typ,value}: p111v_step(p111v_value(value,p111v_type(typ),live,ids),name,schema,live,"ill-typed or undefined assignment")
    case N111Bin{name,typ,op,left,right}:
      +width = p111v_type(typ)
      p111v_step(U32.is_le(width,2) && p111v_operator(op) && p111v_value(left,width,live,ids) && p111v_value(right,width,live,ids),name,schema,live,"invalid binary operation or operand")
    case N111Call{name,typ,symbol,args}:
      p111v_step(p111v_call(symbol,typ,args,live,ids,arity,incoming,result),name,schema,live,"runtime import signature/count/capacity mismatch: " ++ symbol)
    case N111If{condition,yes,no}:
      nt_choose(P111VFlow,p111v_value(condition,1,live,ids),
        u => p111v_join(p111v_body(yes,schema,P111VFlow{live,False{},""},ids,arity,incoming,result),p111v_body(no,schema,P111VFlow{live,False{},""},ids,arity,incoming,result)),
        u => P111VFlow{live,False{},"condition must be a definitely assigned U32"})
    case N111Return{value}:
      nt_choose(P111VFlow,p111v_value(value,2,live,ids),u => P111VFlow{live,True{},""},u => P111VFlow{live,False{},"segment return must be U64"})
    case N111Load{name,typ,base,offset}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids),name,schema,live,"unbounded, unaligned or ill-typed load")
    case N111Store{typ,base,offset,value}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids) && p111v_value(value,p111v_type(typ),live,ids),"",schema,live,"unbounded, unaligned or ill-typed store")
    case N111Offset{name,base,bytes}: p111v_offset(name,base,bytes,live,ids)
    case N111Alloca{name,bytes,align}:
      p111v_step(U32.is_gt(bytes,0) && U32.is_le(bytes,2048) && (U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16)),name,schema,live,"unsupported stack allocation size/alignment")

@unsafe
def p111v_body(+body: List<&2,N111Stmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P111VFlow{live,terminal,+error}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
      nt_choose(P111VFlow,terminal,u => P111VFlow{live,True{},"statement follows terminal path"},u =>
        p111v_body(rest,schema,p111v_stmt(head,schema,live,ids,arity,incoming,result),ids,arity,incoming,result)))

@unsafe
def p111v_functions(+segments: List<&2,N111Segment>, +scan: P111VScan) -> P111VScan:
  match segments scan:
    case Nil{} _: scan
    case Con{N111Segment{+name,+arity,result,+incoming,flags,body},rest} P111VScan{+index,+error,+count}:
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,U32.is_ge(count,65532),u => P111VScan{index,"segment count exceeds 16-bit FID capacity with four runtime IDs",count},u =>
      nt_choose(P111VScan,Bool.not(p111v_raw_name(name)) || Bool.not(agy_str_eq(dk(p111v_get(index,name)),"Absent")),
        u => P111VScan{index,"invalid/duplicate segment name: " ++ name,count},u =>
      nt_choose(P111VScan,U32.is_gt(arity,255) || U32.is_gt(result,255) || U32.is_gt(incoming,arity) || U32.is_gt(flags,255),
        u => P111VScan{index,"segment metadata exceeds ABI capacity: " ++ name,count},u =>
        p111v_functions(rest,P111VScan{p111v_put(index,name,"function",arity,incoming),"",U32.inc(count)})))))

@unsafe
def p111v_constructors(+constructors: List<&2,N_Constructor>, +scan: P111VScan) -> P111VScan:
  match constructors scan:
    case Nil{} _: scan
    case Con{N_Constructor{+name,+arity,hot},rest} P111VScan{+index,+error,+count}:
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,U32.is_ge(count,65535),u => P111VScan{index,"constructor count exceeds 16-bit CID capacity",count},u =>
      nt_choose(P111VScan,Bool.not(p111v_raw_name(name)) || Bool.not(agy_str_eq(dk(p111v_get(index,name)),"Absent")),
        u => P111VScan{index,"invalid/duplicate constructor name: " ++ name,count},u =>
      nt_choose(P111VScan,U32.is_gt(arity,255),u => P111VScan{index,"constructor arity exceeds ABI capacity: " ++ name,count},u =>
        p111v_constructors(rest,P111VScan{p111v_put(index,name,"constructor",arity,0),"",U32.inc(count)})))))

@unsafe
def p111v_segment_flow(+body: List<&2,N111Stmt>, +schema: P111VScan, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match schema:
    case P111VScan{index,+error,+count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        p111v_finish(p111v_body(body,index,P111VFlow{seed,False{},""},ids,arity,incoming,result)))

@unsafe
def p111v_finish(flow: P111VFlow) -> String:
  match flow:
    case P111VFlow{live,terminal,+error}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,terminal,v => "",v => "segment has a nonterminal path"))""",
        """@unsafe
def w5c3_u32_if(cond: Bool, +yes: U32, +no: U32) -> U32:
  match cond:
    case True{}: yes
    case False{}: no

@unsafe
def w5c3_str2_if(cond: Bool, +yes: String, +no: String) -> String:
  match cond:
    case True{}: yes
    case False{}: no

@unsafe
def w5c3_bucket_hit(hit: Bool, +h: KDef, rest: List<&2,KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: w5c3_bucket(rest, name)

@unsafe
def w5c3_bucket(ds: List<&2,KDef>, +name: String) -> KDef:
  match ds:
    case Nil{}: missing()
    case Con{+h, rest}: w5c3_bucket_hit(String.eq(dn(h), name), h, rest, name)

law w5c3_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  KDef

@unsafe
def w5c3_find_leaf(eq: Bool, bucket: List<&2,KDef>, +name: String) -> KDef:
  match eq:
    case True{}: w5c3_bucket(bucket, name)
    case False{}: missing()

@unsafe
def w5c3_find_lr(go_left: Bool, +left: KDef, +right: KDef, +name: String, +hash: U32) -> KDef:
  match go_left:
    case True{}: w5c3_find(left, name, hash)
    case False{}: w5c3_find(right, name, hash)

@unsafe
def w5c3_find_node(zero_mask: Bool, +stored: U32, +mask: U32, +left: KDef, +right: KDef, +name: String, +hash: U32) -> KDef:
  match zero_mask:
    case True{}: w5c3_find_leaf(U32.is_eq(stored, hash), [left, right], name)
    case False{}: w5c3_find_lr(U32.is_eq(U32.and(hash, mask), 0), left, right, name, hash)

@unsafe
def w5c3_find_kdef_t0(t0: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match t0:
    case True{}: w5c3_find_leaf(U32.is_eq(arity, hash), ctors, name)
    case False{}: w5c3_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash)

@unsafe
def w5c3_find_kdef(is_abs: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match is_abs:
    case True{}: missing()
    case False{}: w5c3_find_kdef_t0(U32.is_eq(templates, 0), arity, templates, ctors, name, hash)

@unsafe
def w5c3_find(tree, name, hash):
  match tree:
    case KIndexLeaf{stored, bucket}: w5c3_find_leaf(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, +mask, +left, +right}: w5c3_find_node(U32.is_eq(mask, 0), stored, mask, left, right, name, hash)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5c3_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash)

@unsafe
def p111v_get(+tree: KDef, +name: String) -> KDef:
  w5c3_find(tree, name, index_hash(name, 2166136261))

@unsafe
def p111v_put_h(+tree: KDef, +name: String, +hash: U32, +kind: String, +width: U32, +capacity: U32) -> KDef:
  p131i_insert(tree, KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}}, hash)

@unsafe
def p111v_put(+tree: KDef, +name: String, +kind: String, +width: U32, +capacity: U32) -> KDef:
  p131i_insert(tree, KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}}, index_hash(name,2166136261))

def p111v_type(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 1
    case N111U64{}: 2
    case N111Ptr{}: 3

@unsafe
def p111v_name_chars(+name: String, +n: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(n,0)
    case SCon{h,t}:
      +c = Char.to_u32(h)
      U32.is_lt(n,128) && ((U32.is_ge(c,65) && U32.is_le(c,90)) ||
        (U32.is_ge(c,97) && U32.is_le(c,122)) || U32.is_eq(c,95) ||
        (U32.is_gt(n,0) && U32.is_ge(c,48) && U32.is_le(c,57))) && p111v_name_chars(t,U32.inc(n))

@unsafe
def p111v_raw_name_chars(+name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{head,rest}: U32.is_lt(count,4096) && Bool.not(U32.is_eq(Char.to_u32(head),0)) && p111v_raw_name_chars(rest,U32.inc(count))

@unsafe
def p111v_raw_name(+name: String) -> Bool:
  p111v_raw_name_chars(name,0)

@unsafe
def p111v_comparison(+op: String) -> Bool:
  String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") || String.eq(op,"ule") ||
  String.eq(op,"ugt") || String.eq(op,"uge") || String.eq(op,"slt") || String.eq(op,"sle") ||
  String.eq(op,"sgt") || String.eq(op,"sge")

@unsafe
def p111v_operator(+op: String) -> Bool:
  p111v_comparison(op) || String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
  String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") ||
  String.eq(op,"shr") || String.eq(op,"sar")

@unsafe
def w5c3_decl_check(bad_change: Bool, is_abs: Bool, +index: KDef, +name: String, +h: U32, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match bad_change:
    case True{}: P111VScan{index,"local width/allocation changes: " ++ name,count}
    case False{}:
      P111VScan{p111v_put_h(index,name,h,w5c3_str2_if(alloca,"alloca","local"),width,capacity),"",w5c3_u32_if(is_abs,U32.inc(count),count)}

@unsafe
def w5c3_decl_name(bad_name: Bool, +index: KDef, +name: String, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match bad_name:
    case True{}: P111VScan{index,"invalid/reserved local name: " ++ name,count}
    case False{}:
      +h = index_hash(name, 2166136261)
      +old = w5c3_find(index, name, h)
      +is_abs = String.eq(dk(old),"Absent")
      w5c3_decl_check(Bool.not(is_abs) && (alloca || String.eq(dk(old),"alloca") || Bool.not(U32.is_eq(da(old),width))),
        is_abs, index, name, h, width, capacity, alloca, count)

@unsafe
def w5c3_decl_err(has_err: Bool, +scan: P111VScan, +index: KDef, +name: String, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_decl_name(Bool.not(p111v_name_chars(name,0)) || String.eq(name,"state"), index, name, width, capacity, alloca, count)

@unsafe
def p111v_decl(+name: String, +width: U32, +capacity: U32, +alloca: Bool, +scan: P111VScan) -> P111VScan:
  match scan:
    case P111VScan{+index,+error,+count}:
      w5c3_decl_err(Bool.not(String.is_empty(error)), scan, index, name, width, capacity, alloca, count)

@unsafe
def p111v_schema_stmt(+stmt: N111Stmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case N111Set{name,typ,value}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Bin{name,typ,op,left,right}: p111v_decl(name,w5c3_u32_if(p111v_comparison(op),1,p111v_type(typ)),0,False{},scan)
    case N111Call{name,typ,symbol,args}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Load{name,typ,base,offset}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Offset{name,base,bytes}: p111v_decl(name,3,0,False{},scan)
    case N111Alloca{name,bytes,align}: p111v_decl(name,3,bytes,True{},scan)
    case N111If{condition,yes,no}: p111v_schema(no,p111v_schema(yes,scan))
    case _: scan

@unsafe
def w5c3_schema_step(ok: Bool, +head: N111Stmt, rest: List<&2,N111Stmt>, +scan: P111VScan, +index: KDef, +error: String, +count: U32) -> P111VScan:
  match ok:
    case True{}: p111v_schema(rest,p111v_schema_stmt(head,scan))
    case False{}: P111VScan{index,w5c3_str2_if(String.is_empty(error),"too many segment locals",error),count}

@unsafe
def p111v_schema(+body: List<&2,N111Stmt>, +scan: P111VScan) -> P111VScan:
  match body:
    case Nil{}: scan
    case Con{head,rest}:
      match scan:
        case P111VScan{index,+error,+count}:
          w5c3_schema_step(String.is_empty(error) && U32.is_le(count,65535), head, rest, scan, index, error, count)

@unsafe
def w5c3_val_const(w1: Bool, w3: Bool, +width: U32, +lo: U32, +hi: U32) -> Bool:
  match w1:
    case True{}: U32.is_eq(hi,0)
    case False{}:
      match w3:
        case True{}: U32.is_eq(lo,0) && U32.is_eq(hi,0)
        case False{}: U32.is_eq(width,2)

@unsafe
def p111v_value(+value: N111Value, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match value:
    case N111Local{name}:
      +found = p111v_get(live,name)
      Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),width)
    case N111Const{lo,hi}:
      w5c3_val_const(U32.is_eq(width,1), U32.is_eq(width,3), width, lo, hi)
    case N111FuncId{name}:
      match ids:
        case N111Ids{functions,_}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(functions,name)),"Absent"))
    case N111CtorId{name}:
      match ids:
        case N111Ids{_,constructors}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(constructors,name)),"Absent"))
    case N111Symbol{name}: False{}

@unsafe
def p111v_assign(+name: String, +schema: KDef, +live: KDef) -> KDef:
  +h = index_hash(name, 2166136261)
  +found = w5c3_find(schema, name, h)
  p111v_put_h(live, name, h, dk(found), da(found), dx(found))

@unsafe
def w5c3_step_name(empty: Bool, +name: String, +schema: KDef, +live: KDef) -> P111VFlow:
  match empty:
    case True{}: P111VFlow{live,False{},""}
    case False{}: P111VFlow{p111v_assign(name,schema,live),False{},""}

@unsafe
def p111v_step(+ok: Bool, +name: String, +schema: KDef, +live: KDef, +message: String) -> P111VFlow:
  match ok:
    case True{}: w5c3_step_name(String.is_empty(name), name, schema, live)
    case False{}: P111VFlow{live,False{},message}

@unsafe
def p111v_capacity(+value: N111Value, +live: KDef) -> U32:
  match value:
    case N111Local{name}: dx(p111v_get(live,name))
    case _: 0

@unsafe
def p111v_memory(+base: N111Value, +offset: U32, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match base:
    case N111Local{name}:
      +bytes = w5c3_u32_if(U32.is_eq(width,1),4,8)
      +found = p111v_get(live, name)
      +capacity = dx(found)
      Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),3) &&
        U32.is_ge(capacity,bytes) && U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)
    case _: False{}

# Direct O(min(|L|,|R|)) Patricia-tree intersection for p111v_intersection (zero re-hashing)
law w5c3_find_bucket:
  for +tree: KDef
  for +hash: U32
  List<&2,KDef>

@unsafe
def w5c3_fb_leaf(eq: Bool, rb: List<&2,KDef>) -> List<&2,KDef>:
  match eq:
    case True{}: rb
    case False{}: Nil{}

@unsafe
def w5c3_fb_lr(go_left: Bool, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match go_left:
    case True{}: w5c3_find_bucket(ra, hash)
    case False{}: w5c3_find_bucket(rb, hash)

@unsafe
def w5c3_fb_pref(ok: Bool, +rm: U32, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match ok:
    case False{}: Nil{}
    case True{}: w5c3_fb_lr(U32.is_eq(U32.and(hash, rm), 0), ra, rb, hash)

@unsafe
def w5c3_fb_node(z: Bool, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match z:
    case True{}: w5c3_fb_leaf(U32.is_eq(rh, hash), [ra, rb])
    case False{}: w5c3_fb_pref(U32.is_eq(U32.and(U32.xor(hash, rh), U32.sub(rm, 1)), 0), rm, ra, rb, hash)

@unsafe
def w5c3_find_bucket(tree, hash):
  match tree:
    case KIndexLeaf{rh, rb}: w5c3_fb_leaf(U32.is_eq(rh, hash), rb)
    case KIndexNode{rh, +rm, +ra, +rb}: w5c3_fb_node(U32.is_eq(rm, 0), rh, rm, ra, rb, hash)
    case _: Nil{}

law w5c3_inter_buckets:
  for lb: List<&2,KDef>
  for +rb: List<&2,KDef>
  List<&2,KDef>

@unsafe
def w5c3_ib_step(is_abs: Bool, +head: KDef, +found: KDef, rest: List<&2,KDef>, +rb: List<&2,KDef>) -> List<&2,KDef>:
  match is_abs:
    case True{}: w5c3_inter_buckets(rest, rb)
    case False{}:
      +cap = w5c3_u32_if(U32.is_eq(dx(head), dx(found)), dx(head), 0)
      Con{KDef{dn(head), dk(head), da(head), cap, atom("Absent"), atom("Absent"), [], False{}, False{}}, w5c3_inter_buckets(rest, rb)}

@unsafe
def w5c3_inter_buckets(lb, rb):
  match lb:
    case Nil{}: Nil{}
    case Con{+head, rest}:
      +found = w5c3_bucket(rb, dn(head))
      w5c3_ib_step(String.eq(dk(found), "Absent"), head, found, rest, rb)

@unsafe
def w5c3_leaf_from(+h: U32, res: List<&2,KDef>) -> KDef:
  match res:
    case Nil{}: missing()
    case Con{_, _}: KIndexLeaf{h, res}

@unsafe
def w5c3_inter_leaf_rb(rb: List<&2,KDef>, +lh: U32, +lb: List<&2,KDef>) -> KDef:
  match rb:
    case Nil{}: missing()
    case Con{_, _}: w5c3_leaf_from(lh, w5c3_inter_buckets(lb, rb))

@unsafe
def w5c3_inter_leaf(+lh: U32, +lb: List<&2,KDef>, +right: KDef) -> KDef:
  w5c3_inter_leaf_rb(w5c3_find_bucket(right, lh), lh, lb)

@unsafe
def w5c3_comb_b(b_abs: Bool, +lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  match b_abs:
    case True{}: ia
    case False{}: KIndexNode{lh, lm, ia, ib}

@unsafe
def w5c3_comb_a(a_abs: Bool, +lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  match a_abs:
    case True{}: ib
    case False{}: w5c3_comb_b(String.eq(dk(ib), "Absent"), lh, lm, ia, ib)

@unsafe
def w5c3_inter_combine(+lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  w5c3_comb_a(String.eq(dk(ia), "Absent"), lh, lm, ia, ib)

law w5c3_inter_slow_bucket:
  for +bucket: List<&2,KDef>
  for +other: KDef
  for +out: KDef
  KDef

@unsafe
def w5c3_isb_step(is_abs: Bool, +head: KDef, +found: KDef, +h: U32, rest: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: w5c3_inter_slow_bucket(rest, other, out)
    case False{}:
      +cap = w5c3_u32_if(U32.is_eq(dx(head), dx(found)), dx(head), 0)
      w5c3_inter_slow_bucket(rest, other, p111v_put_h(out, dn(head), h, dk(head), da(head), cap))

@unsafe
def w5c3_inter_slow_bucket(bucket, other, out):
  match bucket:
    case Nil{}: out
    case Con{+head, rest}:
      +h = index_hash(dn(head), 2166136261)
      +found = w5c3_find(other, dn(head), h)
      w5c3_isb_step(String.eq(dk(found), "Absent"), head, found, h, rest, other, out)

@unsafe
def w5c3_inter_slow(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash, bucket}: w5c3_inter_slow_bucket(bucket, right, out)
    case KIndexNode{hash, mask, a, b}: w5c3_inter_slow(b, right, w5c3_inter_slow(a, right, out))
    case _: out

law w5c3_inter_tree:
  for +left: KDef
  for +right: KDef
  KDef

@unsafe
def w5c3_in_eq_pref(ok: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_inter_combine(lh, lm, w5c3_inter_tree(la, ra), w5c3_inter_tree(lb, rb))

@unsafe
def w5c3_in_side(go_left: Bool, +a: KDef, +b: KDef, +other: KDef) -> KDef:
  match go_left:
    case True{}: w5c3_inter_tree(a, other)
    case False{}: w5c3_inter_tree(b, other)

@unsafe
def w5c3_in_side_r(go_left: Bool, +left: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match go_left:
    case True{}: w5c3_inter_tree(left, ra)
    case False{}: w5c3_inter_tree(left, rb)

@unsafe
def w5c3_in_lt_pref(ok: Bool, +rh: U32, +lm: U32, +la: KDef, +lb: KDef, +right: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_in_side(U32.is_eq(U32.and(rh, lm), 0), la, lb, right)

@unsafe
def w5c3_in_gt_pref(ok: Bool, +lh: U32, +rm: U32, +left: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_in_side_r(U32.is_eq(U32.and(lh, rm), 0), left, ra, rb)

@unsafe
def w5c3_in_cmp(lt: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match lt:
    case True{}: w5c3_in_lt_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right)
    case False{}: w5c3_in_gt_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, rm, left, ra, rb)

@unsafe
def w5c3_in_eq(eq: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match eq:
    case True{}: w5c3_in_eq_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), lh, lm, la, lb, ra, rb)
    case False{}: w5c3_in_cmp(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right)

@unsafe
def w5c3_in_nn(z: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match z:
    case True{}: w5c3_inter_slow(left, right, missing())
    case False{}: w5c3_in_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right)

@unsafe
def w5c3_inter_node_lb(lb2: List<&2,KDef>, +rh: U32, +rb: List<&2,KDef>) -> KDef:
  match lb2:
    case Nil{}: missing()
    case Con{_, _}: w5c3_leaf_from(rh, w5c3_inter_buckets(lb2, rb))

@unsafe
def w5c3_inter_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef) -> KDef:
  match right:
    case KIndexLeaf{+rh, rb}: w5c3_inter_node_lb(w5c3_find_bucket(left, rh), rh, rb)
    case KIndexNode{rh, +rm, +ra, +rb}:
      w5c3_in_nn(U32.is_eq(lm, 0) || U32.is_eq(rm, 0), lh, lm, la, lb, left, rh, rm, ra, rb, right)
    case _: missing()

@unsafe
def w5c3_inter_tree(left, right):
  match left:
    case KIndexLeaf{lh, lb}: w5c3_inter_leaf(lh, lb, right)
    case KIndexNode{lh, lm, la, lb}: w5c3_inter_node(lh, lm, la, lb, left, right)
    case _: missing()

@unsafe
def p111v_intersection_bucket(+bucket: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  w5c3_inter_slow_bucket(bucket, other, out)

@unsafe
def w5c3_inter_dispatch(is_abs: Bool, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: w5c3_inter_tree(left, right)
    case False{}: w5c3_inter_slow(left, right, out)

@unsafe
def p111v_intersection(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c3_inter_dispatch(String.eq(dk(out), "Absent"), left, right, out)

@unsafe
def w5c3_join_terms(yt: Bool, nt: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, +nl: KDef) -> P111VFlow:
  match yt:
    case True{}:
      match nt:
        case True{}: P111VFlow{yl,True{},""}
        case False{}: no
    case False{}:
      match nt:
        case True{}: yes
        case False{}: P111VFlow{w5c3_inter_tree(yl,nl),False{},""}

@unsafe
def w5c3_join_no_err(has_ne: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, yt: Bool, +nl: KDef, nt: Bool) -> P111VFlow:
  match has_ne:
    case True{}: no
    case False{}: w5c3_join_terms(yt, nt, yes, no, yl, nl)

@unsafe
def w5c3_join_yes_err(has_ye: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, yt: Bool) -> P111VFlow:
  match has_ye:
    case True{}: yes
    case False{}:
      match no:
        case P111VFlow{nl,+nt,+ne}: w5c3_join_no_err(Bool.not(String.is_empty(ne)), yes, no, yl, yt, nl, nt)

@unsafe
def p111v_join(+yes: P111VFlow, +no: P111VFlow) -> P111VFlow:
  match yes:
    case P111VFlow{+yl,yt,+ye}: w5c3_join_yes_err(Bool.not(String.is_empty(ye)), yes, no, yl, yt)

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.
@unsafe
def w5c3_sig17(m: Bool) -> List<&2,U32>:
  match m:
    case True{}: [3,1,2,3,1]
    case False{}: []

@unsafe
def w5c3_sig16(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1,2]
    case False{}: w5c3_sig17(String.eq(s,"p111_rt_special_take"))

@unsafe
def w5c3_sig15(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1,3,1]
    case False{}: w5c3_sig16(String.eq(s,"p111_rt_special_test"), s)

@unsafe
def w5c3_sig14(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1]
    case False{}: w5c3_sig15(String.eq(s,"p111_rt_op") || String.eq(s,"p111_rt_special_ctor"), s)

@unsafe
def w5c3_sig10(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2,2]
    case False{}: w5c3_sig14(String.eq(s,"p111_rt_stack_pop") || String.eq(s,"p111_rt_stack_get") || String.eq(s,"p111_rt_reg_get") || String.eq(s,"p111_rt_fail"), s)

@unsafe
def w5c3_sig9(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,3,1]
    case False{}: w5c3_sig10(String.eq(s,"p111_rt_apply"), s)

@unsafe
def w5c3_sig4(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2,3,1]
    case False{}: w5c3_sig9(String.eq(s,"p111_rt_return"), s)

@unsafe
def w5c3_sig3(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1,3,1]
    case False{}: w5c3_sig4(String.eq(s,"p111_rt_take"), s)

@unsafe
def w5c3_sig1(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2]
    case False{}: w5c3_sig3(String.eq(s,"p111_rt_ctor") || String.eq(s,"p111_rt_closure") || String.eq(s,"p111_rt_frame") || String.eq(s,"p111_rt_jump"), s)

@unsafe
def p111v_signature(+symbol: String) -> List<&2,U32>:
  w5c3_sig1(String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink") || String.eq(symbol,"p111_rt_tag"), symbol)

def p111v_primitive_arities() -> List<&2,U32>:
  [0,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2,2,2,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,2,2,2,1,2,2,2,2,2,2,2,3,3,1,1,3,3,3,3,3,3,3,4,3,1]

@unsafe
def w5c3_at_step(z: Bool, +head: U32, rest: List<&2,U32>, +index: U32) -> U32:
  match z:
    case True{}: head
    case False{}: p111v_at(rest,U32.sub(index,1))

@unsafe
def p111v_at(+values: List<&2,U32>, +index: U32) -> U32:
  match values:
    case Nil{}: 4294967295
    case Con{head,rest}: w5c3_at_step(U32.is_eq(index,0), head, rest, index)

@unsafe
def w5c3_arg_step(z: Bool, +value: N111Value, rest: List<&2,N111Arg>, +index: U32) -> N111Value:
  match z:
    case True{}: value
    case False{}: p111v_arg(rest,U32.sub(index,1))

@unsafe
def p111v_arg(+args: List<&2,N111Arg>, +index: U32) -> N111Value:
  match args:
    case Nil{}: N111Symbol{"invalid"}
    case Con{N111Arg{typ,value},rest}: w5c3_arg_step(U32.is_eq(index,0), value, rest, index)

def w5c3_lit_ok(z: Bool, lo: U32) -> U32:
  match z:
    case True{}: lo
    case False{}: 4294967295

def p111v_literal(value: N111Value) -> U32:
  match value:
    case N111Const{lo,hi}: w5c3_lit_ok(U32.is_eq(hi,0), lo)
    case _: 4294967295

@unsafe
def p111v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: KDef, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p111v_value(value,width,live,ids) && p111v_args(rest,more,live,ids)
    case _ _: False{}

@unsafe
def p111v_target(+value: N111Value, +ids: N111Ids, +constructor: Bool) -> KDef:
  match value:
    case N111CtorId{name}:
      match ids:
        case N111Ids{_,constructors}:
          match constructor:
            case True{}: p111v_get(constructors,name)
            case False{}: missing()
    case N111FuncId{name}:
      match ids:
        case N111Ids{functions,_}:
          match constructor:
            case True{}: missing()
            case False{}: p111v_get(functions,name)
    case _: missing()

@unsafe
def p111v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: KDef) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p111v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

@unsafe
def w5c3_cc_frame(m: Bool, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target))
    case False{}: True{}

@unsafe
def w5c3_cc_clo(m: Bool, +symbol: String, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target))
    case False{}: w5c3_cc_frame(String.eq(symbol,"p111_rt_frame"), target, count)

@unsafe
def w5c3_cc_jump(m: Bool, +symbol: String, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target))
    case False{}: w5c3_cc_clo(String.eq(symbol,"p111_rt_closure"), symbol, target, count)

@unsafe
def w5c3_cc_ctor(is_ctor: Bool, +symbol: String, +target: KDef, +count: U32) -> Bool:
  match is_ctor:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(count,da(target))
    case False{}: w5c3_cc_jump(String.eq(symbol,"p111_rt_jump"), symbol, target, count)

@unsafe
def p111v_counted_call(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  +count = p111v_literal(p111v_arg(args,3))
  +is_ctor = String.eq(symbol,"p111_rt_ctor")
  +target = p111v_target(p111v_arg(args,1),ids,is_ctor)
  p111v_buffer(args,2,count,live) && w5c3_cc_ctor(is_ctor, symbol, target, count)

@unsafe
def w5c3_spec_arity_if(ok: Bool, +kind: U32) -> U32:
  match ok:
    case True{}: p111v_at([0,0,0,0,1,1,1,1,1,2],kind)
    case False{}: 4294967295

@unsafe
def p111v_special_arity(+kind: U32) -> U32:
  w5c3_spec_arity_if(U32.is_gt(kind,0) && U32.is_lt(kind,10), kind)

@unsafe
def w5c3_ctr_fail(m: Bool, +args: List<&2,N111Arg>) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      U32.is_gt(id,0) && U32.is_le(id,8)
    case False{}: True{}

@unsafe
def w5c3_ctr_stest(m: Bool, +symbol: String, +args: List<&2,N111Arg>) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      U32.is_gt(id,0) && U32.is_lt(id,10)
    case False{}: w5c3_ctr_fail(String.eq(symbol,"p111_rt_fail"), args)

@unsafe
def w5c3_ctr_stake(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +cnt = p111v_literal(p111v_arg(args,4))
      U32.is_eq(cnt,p111v_special_arity(id)) && p111v_buffer(args,3,cnt,live)
    case False{}: w5c3_ctr_stest(String.eq(symbol,"p111_rt_special_test"), symbol, args)

@unsafe
def w5c3_ctr_sctor(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +count = p111v_literal(p111v_arg(args,3))
      U32.is_eq(count,p111v_special_arity(id)) && p111v_buffer(args,2,count,live)
    case False{}: w5c3_ctr_stake(String.eq(symbol,"p111_rt_special_take"), symbol, args, live)

@unsafe
def w5c3_ctr_op(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +count = p111v_literal(p111v_arg(args,3))
      U32.is_gt(id,0) && U32.is_lt(id,87) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p111v_buffer(args,2,count,live)
    case False{}: w5c3_ctr_sctor(String.eq(symbol,"p111_rt_special_ctor"), symbol, args, live)

@unsafe
def w5c3_ctr_spop(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_gt(incoming,0) && U32.is_eq(p111v_literal(p111v_arg(args,1)),U32.sub(arity,incoming))
    case False{}: w5c3_ctr_op(String.eq(symbol,"p111_rt_op"), symbol, args, live)

@unsafe
def w5c3_ctr_sget(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_gt(incoming,0) && U32.is_lt(p111v_literal(p111v_arg(args,1)),U32.sub(arity,incoming))
    case False{}: w5c3_ctr_spop(String.eq(symbol,"p111_rt_stack_pop"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_rget(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_lt(p111v_literal(p111v_arg(args,1)),w5c3_u32_if(U32.is_gt(incoming,0),incoming,arity))
    case False{}: w5c3_ctr_sget(String.eq(symbol,"p111_rt_stack_get"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_ret(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  match m:
    case True{}: U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p111v_buffer(args,1,result,live)
    case False{}: w5c3_ctr_rget(String.eq(symbol,"p111_rt_reg_get"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_counted(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  match m:
    case True{}: p111v_counted_call(symbol,args,live,ids)
    case False{}: w5c3_ctr_ret(String.eq(symbol,"p111_rt_return"), symbol, args, live, arity, incoming, result)

@unsafe
def p111v_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  w5c3_ctr_counted(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_frame") || String.eq(symbol,"p111_rt_jump"),
    symbol, args, live, ids, arity, incoming, result)

def p111v_state_argument(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state")
    case _: False{}

@unsafe
def p111v_call(+symbol: String, +typ: N111Type, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +sig = p111v_signature(symbol)
  Bool.not(List.is_empty(&2,U32,sig)) && U32.is_eq(p111v_type(typ),2) &&
    p111v_state_argument(args) && p111v_args(args,sig,live,ids) && p111v_contract(symbol,args,live,ids,arity,incoming,result)

@unsafe
def w5c3_offset_if(ok: Bool, +name: String, +live: KDef, +capacity: U32, +offset: U32) -> P111VFlow:
  match ok:
    case True{}: P111VFlow{p111v_put(live,name,"local",3,U32.sub(capacity,offset)),False{},""}
    case False{}: P111VFlow{live,False{},"unbounded or ill-typed pointer offset"}

@unsafe
def p111v_offset(+name: String, +base: N111Value, +bytes: N111Value, +live: KDef, +ids: N111Ids) -> P111VFlow:
  match base:
    case N111Local{bname}:
      +offset = p111v_literal(bytes)
      +found = p111v_get(live, bname)
      +capacity = dx(found)
      w5c3_offset_if(Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),3) && p111v_value(bytes,2,live,ids) && U32.is_le(offset,capacity),
        name, live, capacity, offset)
    case _: P111VFlow{live,False{},"unbounded or ill-typed pointer offset"}

@unsafe
def w5c3_stmt_if(ok: Bool, yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match ok:
    case True{}: p111v_join(p111v_body(yes,schema,P111VFlow{live,False{},""},ids,arity,incoming,result),p111v_body(no,schema,P111VFlow{live,False{},""},ids,arity,incoming,result))
    case False{}: P111VFlow{live,False{},"condition must be a definitely assigned U32"}

@unsafe
def w5c3_stmt_ret(ok: Bool, +live: KDef) -> P111VFlow:
  match ok:
    case True{}: P111VFlow{live,True{},""}
    case False{}: P111VFlow{live,False{},"segment return must be U64"}

@unsafe
def p111v_stmt(+stmt: N111Stmt, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match stmt:
    case N111Set{name,typ,value}: p111v_step(p111v_value(value,p111v_type(typ),live,ids),name,schema,live,"ill-typed or undefined assignment")
    case N111Bin{name,typ,op,left,right}:
      +width = p111v_type(typ)
      p111v_step(U32.is_le(width,2) && p111v_operator(op) && p111v_value(left,width,live,ids) && p111v_value(right,width,live,ids),name,schema,live,"invalid binary operation or operand")
    case N111Call{name,typ,symbol,args}:
      p111v_step(p111v_call(symbol,typ,args,live,ids,arity,incoming,result),name,schema,live,"runtime import signature/count/capacity mismatch: " ++ symbol)
    case N111If{condition,yes,no}:
      w5c3_stmt_if(p111v_value(condition,1,live,ids), yes, no, schema, live, ids, arity, incoming, result)
    case N111Return{value}:
      w5c3_stmt_ret(p111v_value(value,2,live,ids), live)
    case N111Load{name,typ,base,offset}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids),name,schema,live,"unbounded, unaligned or ill-typed load")
    case N111Store{typ,base,offset,value}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids) && p111v_value(value,p111v_type(typ),live,ids),"",schema,live,"unbounded, unaligned or ill-typed store")
    case N111Offset{name,base,bytes}: p111v_offset(name,base,bytes,live,ids)
    case N111Alloca{name,bytes,align}:
      p111v_step(U32.is_gt(bytes,0) && U32.is_le(bytes,2048) && (U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16)),name,schema,live,"unsupported stack allocation size/alignment")

@unsafe
def w5c3_body_term(terminal: Bool, +head: N111Stmt, rest: List<&2,N111Stmt>, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match terminal:
    case True{}: P111VFlow{live,True{},"statement follows terminal path"}
    case False{}: p111v_body(rest,schema,p111v_stmt(head,schema,live,ids,arity,incoming,result),ids,arity,incoming,result)

@unsafe
def w5c3_body_err(has_err: Bool, +flow: P111VFlow, +head: N111Stmt, rest: List<&2,N111Stmt>, +schema: KDef, +live: KDef, terminal: Bool, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match has_err:
    case True{}: flow
    case False{}: w5c3_body_term(terminal, head, rest, schema, live, ids, arity, incoming, result)

@unsafe
def p111v_body(+body: List<&2,N111Stmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match body:
    case Nil{}: flow
    case Con{head,rest}:
      match flow:
        case P111VFlow{live,terminal,+error}:
          w5c3_body_err(Bool.not(String.is_empty(error)), flow, head, rest, schema, live, terminal, ids, arity, incoming, result)

@unsafe
def w5c3_fn_abi(bad: Bool, +name: String, +h: U32, +arity: U32, +incoming: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"segment metadata exceeds ABI capacity: " ++ name,count}
    case False{}: p111v_functions(rest,P111VScan{p111v_put_h(index,name,h,"function",arity,incoming),"",U32.inc(count)})

@unsafe
def w5c3_fn_dup(bad: Bool, +name: String, +h: U32, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"invalid/duplicate segment name: " ++ name,count}
    case False{}: w5c3_fn_abi(U32.is_gt(arity,255) || U32.is_gt(result,255) || U32.is_gt(incoming,arity) || U32.is_gt(flags,255), name, h, arity, incoming, rest, index, count)

@unsafe
def w5c3_fn_cap(full: Bool, +name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match full:
    case True{}: P111VScan{index,"segment count exceeds 16-bit FID capacity with four runtime IDs",count}
    case False{}:
      +h = index_hash(name, 2166136261)
      w5c3_fn_dup(Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(w5c3_find(index,name,h)),"Absent")), name, h, arity, result, incoming, flags, rest, index, count)

@unsafe
def w5c3_fn_err(has_err: Bool, +scan: P111VScan, +name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_fn_cap(U32.is_ge(count,65532), name, arity, result, incoming, flags, rest, index, count)

@unsafe
def p111v_functions(+segments: List<&2,N111Segment>, +scan: P111VScan) -> P111VScan:
  match segments:
    case Nil{}: scan
    case Con{N111Segment{+name,+arity,result,+incoming,flags,body},rest}:
      match scan:
        case P111VScan{+index,+error,+count}:
          w5c3_fn_err(Bool.not(String.is_empty(error)), scan, name, arity, result, incoming, flags, rest, index, count)

@unsafe
def w5c3_ct_abi(bad: Bool, +name: String, +h: U32, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"constructor arity exceeds ABI capacity: " ++ name,count}
    case False{}: p111v_constructors(rest,P111VScan{p111v_put_h(index,name,h,"constructor",arity,0),"",U32.inc(count)})

@unsafe
def w5c3_ct_dup(bad: Bool, +name: String, +h: U32, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"invalid/duplicate constructor name: " ++ name,count}
    case False{}: w5c3_ct_abi(U32.is_gt(arity,255), name, h, arity, rest, index, count)

@unsafe
def w5c3_ct_cap(full: Bool, +name: String, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match full:
    case True{}: P111VScan{index,"constructor count exceeds 16-bit CID capacity",count}
    case False{}:
      +h = index_hash(name, 2166136261)
      w5c3_ct_dup(Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(w5c3_find(index,name,h)),"Absent")), name, h, arity, rest, index, count)

@unsafe
def w5c3_ct_err(has_err: Bool, +scan: P111VScan, +name: String, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_ct_cap(U32.is_ge(count,65535), name, arity, rest, index, count)

@unsafe
def p111v_constructors(+constructors: List<&2,N_Constructor>, +scan: P111VScan) -> P111VScan:
  match constructors:
    case Nil{}: scan
    case Con{N_Constructor{+name,+arity,hot},rest}:
      match scan:
        case P111VScan{+index,+error,+count}:
          w5c3_ct_err(Bool.not(String.is_empty(error)), scan, name, arity, rest, index, count)

@unsafe
def w5c3_seg_flow_if(has_err: Bool, +error: String, +body: List<&2,N111Stmt>, +index: KDef, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match has_err:
    case True{}: error
    case False{}: p111v_finish(p111v_body(body,index,P111VFlow{seed,False{},""},ids,arity,incoming,result))

@unsafe
def p111v_segment_flow(+body: List<&2,N111Stmt>, +schema: P111VScan, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match schema:
    case P111VScan{index,+error,+count}:
      w5c3_seg_flow_if(Bool.not(String.is_empty(error)), error, body, index, seed, ids, arity, incoming, result)

@unsafe
def w5c3_finish_if(has_err: Bool, +error: String, terminal: Bool) -> String:
  match has_err:
    case True{}: error
    case False{}:
      match terminal:
        case True{}: ""
        case False{}: "segment has a nonterminal path"

@unsafe
def p111v_finish(flow: P111VFlow) -> String:
  match flow:
    case P111VFlow{live,terminal,+error}: w5c3_finish_if(Bool.not(String.is_empty(error)), error, terminal)""",
        "fast_p111v_verifier",
    )

    # 5. p205u_refs / p205u_vars early exit + zero-closure
    src = replace_exact(
        src,
        """@unsafe
def p205u_refs(+t: KTerm, +name: String) -> U32:
  kc(U32,p98_tag_eq(t,"Ref"),u => nt_bool(agy_str_eq(nm(t),name)),u => p205u_refs_fields(ks(t),name))
@unsafe
def p205u_refs_fields( +xs: List<&2,KTerm>, +name: String) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}: U32.min(2,U32.add(p205u_refs(x,name),p205u_refs_fields(rest,name)))
@unsafe
def p205u_vars(+t: KTerm, +id: U32) -> U32:
  kc(U32,p98_tag_eq(t,"Var"),u => nt_bool(U32.is_eq(ix(t),id)),u => p205u_vars_fields(ks(t),id))
@unsafe
def p205u_vars_fields( +xs: List<&2,KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}: U32.min(2,U32.add(p205u_vars(x,id),p205u_vars_fields(rest,id)))""",
        """@unsafe
def w5c3_b2u(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

@unsafe
def w5c3_refs_if(is_ref: Bool, +t: KTerm, +name: String) -> U32:
  match is_ref:
    case True{}: w5c3_b2u(String.eq(nm(t),name))
    case False{}: p205u_refs_fields(ks(t),name)

@unsafe
def p205u_refs(+t: KTerm, +name: String) -> U32:
  w5c3_refs_if(p98_tag_eq(t,"Ref"), t, name)

@unsafe
def w5c3_refs_rest(sat: Bool, +c: U32, rest: List<&2,KTerm>, +name: String) -> U32:
  match sat:
    case True{}: 2
    case False{}: U32.min(2,U32.add(c,p205u_refs_fields(rest,name)))

@unsafe
def p205u_refs_fields(+xs: List<&2,KTerm>, +name: String) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}:
      +c = p205u_refs(x,name)
      w5c3_refs_rest(U32.is_ge(c,2), c, rest, name)

@unsafe
def w5c3_vars_if(is_var: Bool, +t: KTerm, +id: U32) -> U32:
  match is_var:
    case True{}: w5c3_b2u(U32.is_eq(ix(t),id))
    case False{}: p205u_vars_fields(ks(t),id)

@unsafe
def p205u_vars(+t: KTerm, +id: U32) -> U32:
  w5c3_vars_if(p98_tag_eq(t,"Var"), t, id)

@unsafe
def w5c3_vars_rest(sat: Bool, +c: U32, rest: List<&2,KTerm>, +id: U32) -> U32:
  match sat:
    case True{}: 2
    case False{}: U32.min(2,U32.add(c,p205u_vars_fields(rest,id)))

@unsafe
def p205u_vars_fields(+xs: List<&2,KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}:
      +c = p205u_vars(x,id)
      w5c3_vars_rest(U32.is_ge(c,2), c, rest, id)

law w5c3_has_var:
  for +t: KTerm
  for +id: U32
  Bool

@unsafe
def w5c3_hv_step(hit: Bool, rest: List<&2,KTerm>, +id: U32) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: w5c3_has_var_fields(rest,id)

@unsafe
def w5c3_has_var_fields(xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: w5c3_hv_step(w5c3_has_var(x,id), rest, id)

@unsafe
def w5c3_hv_if(is_var: Bool, +t: KTerm, +id: U32) -> Bool:
  match is_var:
    case True{}: U32.is_eq(ix(t),id)
    case False{}: w5c3_has_var_fields(ks(t),id)

@unsafe
def w5c3_has_var(t, id):
  w5c3_hv_if(p98_tag_eq(t,"Var"), t, id)""",
        "fast_p205u_refs_vars",
    )

    # 6. p205v_* (44.2% of p86_plan): guard op/bool-fold, single nd_native_call, zero-closure + String.eq
    src = replace_exact(
        src,
        """@unsafe
def p205v_allowed(+t: KTerm) -> Bool:
  +tag = tg(t)
  (agy_str_eq(tag,"Var") || agy_str_eq(tag,"Ref") || core_literal(t) || agy_str_eq(tag,"Ctr") ||
    agy_str_eq(tag,"App") || agy_str_eq(tag,"Lam") || agy_str_eq(tag,"Let") || agy_str_eq(tag,"Bind") ||
    agy_str_eq(tag,"Mat") || agy_str_eq(tag,"Efq")) && p205v_allowed_fields(ks(t))""",
        """@unsafe
def p205v_allowed(+t: KTerm) -> Bool:
  +tag = tg(t)
  (String.eq(tag,"Var") || String.eq(tag,"Ref") || core_literal(t) || String.eq(tag,"Ctr") ||
    String.eq(tag,"App") || String.eq(tag,"Lam") || String.eq(tag,"Let") || String.eq(tag,"Bind") ||
    String.eq(tag,"Mat") || String.eq(tag,"Efq")) && p205v_allowed_fields(ks(t))""",
        "fast_p205v_allowed",
    )

    src = replace_exact(
        src,
        """@unsafe
def p205v_bool(+b: Bool) -> KTerm:
  kt("Ctr",kc(String,b,u => "True",u => "False"),0,1,[])
@unsafe
def p205v_binary(+op: String, +a: U32, +b: U32) -> KTerm:
  kc(KTerm,agy_str_eq(op,"u32_is_eq"),u => p205v_bool(U32.is_eq(a,b)),u =>
  kc(KTerm,agy_str_eq(op,"u32_is_ne"),v => p205v_bool(U32.is_ne(a,b)),v =>
  kc(KTerm,agy_str_eq(op,"u32_is_lt"),w => p205v_bool(U32.is_lt(a,b)),w =>
  kc(KTerm,agy_str_eq(op,"u32_is_le"),x => p205v_bool(U32.is_le(a,b)),x =>
  kc(KTerm,agy_str_eq(op,"u32_is_gt"),y => p205v_bool(U32.is_gt(a,b)),y =>
  kc(KTerm,agy_str_eq(op,"u32_is_ge"),z => p205v_bool(U32.is_ge(a,b)),z => p205v_arithmetic(op,a,b)))))))
@unsafe
def p205v_arithmetic(+op: String, +a: U32, +b: U32) -> KTerm:
  kc(KTerm,agy_str_eq(op,"u32_add"),u => KLiteral{"U32",U32.add(a,b),"",0,0},u =>
  kc(KTerm,agy_str_eq(op,"u32_sub"),v => KLiteral{"U32",U32.sub(a,b),"",0,0},v =>
  kc(KTerm,agy_str_eq(op,"u32_mul"),w => KLiteral{"U32",U32.mul(a,b),"",0,0},w =>
  kc(KTerm,agy_str_eq(op,"u32_xor"),x => KLiteral{"U32",U32.xor(a,b),"",0,0},x =>
  kc(KTerm,agy_str_eq(op,"u32_and"),y => KLiteral{"U32",U32.and(a,b),"",0,0},y =>
  kc(KTerm,agy_str_eq(op,"u32_or"),z => KLiteral{"U32",U32.or(a,b),"",0,0},z => atom("Absent")))))))""",
        """@unsafe
def p205v_bool(+b: Bool) -> KTerm:
  match b:
    case True{}: kt("Ctr","True",0,1,[])
    case False{}: kt("Ctr","False",0,1,[])

@unsafe
def w5c3_ar_or(m: Bool, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.or(a,b),"",0,0}
    case False{}: atom("Absent")

@unsafe
def w5c3_ar_and(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.and(a,b),"",0,0}
    case False{}: w5c3_ar_or(String.eq(op,"u32_or"), a, b)

@unsafe
def w5c3_ar_xor(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.xor(a,b),"",0,0}
    case False{}: w5c3_ar_and(String.eq(op,"u32_and"), op, a, b)

@unsafe
def w5c3_ar_mul(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.mul(a,b),"",0,0}
    case False{}: w5c3_ar_xor(String.eq(op,"u32_xor"), op, a, b)

@unsafe
def w5c3_ar_sub(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.sub(a,b),"",0,0}
    case False{}: w5c3_ar_mul(String.eq(op,"u32_mul"), op, a, b)

@unsafe
def w5c3_ar_add(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.add(a,b),"",0,0}
    case False{}: w5c3_ar_sub(String.eq(op,"u32_sub"), op, a, b)

@unsafe
def p205v_arithmetic(+op: String, +a: U32, +b: U32) -> KTerm:
  w5c3_ar_add(String.eq(op,"u32_add"), op, a, b)

@unsafe
def w5c3_bin_ge(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_ge(a,b))
    case False{}: p205v_arithmetic(op,a,b)

@unsafe
def w5c3_bin_gt(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_gt(a,b))
    case False{}: w5c3_bin_ge(String.eq(op,"u32_is_ge"), op, a, b)

@unsafe
def w5c3_bin_le(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_le(a,b))
    case False{}: w5c3_bin_gt(String.eq(op,"u32_is_gt"), op, a, b)

@unsafe
def w5c3_bin_lt(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_lt(a,b))
    case False{}: w5c3_bin_le(String.eq(op,"u32_is_le"), op, a, b)

@unsafe
def w5c3_bin_ne(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_ne(a,b))
    case False{}: w5c3_bin_lt(String.eq(op,"u32_is_lt"), op, a, b)

@unsafe
def w5c3_bin_eq(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_eq(a,b))
    case False{}: w5c3_bin_ne(String.eq(op,"u32_is_ne"), op, a, b)

@unsafe
def p205v_binary(+op: String, +a: U32, +b: U32) -> KTerm:
  w5c3_bin_eq(String.eq(op,"u32_is_eq"), op, a, b)""",
        "fast_p205v_binary",
    )

    src = replace_exact(
        src,
        """@unsafe
def p205v_pure_op(+op: String) -> Bool:
  agy_str_eq(op,"u32_add") || agy_str_eq(op,"u32_sub") || agy_str_eq(op,"u32_mul") ||
  agy_str_eq(op,"u32_xor") || agy_str_eq(op,"u32_and") || agy_str_eq(op,"u32_or") ||
  agy_str_eq(op,"u32_shln") || agy_str_eq(op,"u32_shrn") ||
  agy_str_eq(op,"u32_is_eq") || agy_str_eq(op,"u32_is_ne") || agy_str_eq(op,"u32_is_lt") ||
  agy_str_eq(op,"u32_is_le") || agy_str_eq(op,"u32_is_gt") || agy_str_eq(op,"u32_is_ge") ||
  agy_str_eq(op,"u32_inc") || agy_str_eq(op,"u32_dec")

@unsafe
def p205v_pure_nonzero_mod(+op: String, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Con{_,Con{b,Nil{}}}:
      agy_str_eq(op,"u32_mod") && p205v_range_ok(p205v_range_mod(j_u32(b)))
    case _: False{}

@unsafe
def p205v_pure_def(+book: List<&2,KDef>, +name: String, +fuel: U32) -> Bool:
  +d = lookup(book,name)
  kc(Bool,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(p205u_refs(dv(d),name),0) && p205u_room([dv(d)],128),
    u => p205v_pure(book,p205u_clean(dv(d)),fuel),u => False{})

@unsafe
def p205v_pure_call(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  kc(Bool,p98_tag_eq(call,"Call") && p205v_pure_list(book,ks(call),fuel),u =>
    p205v_pure_op(nd_native_call(book,t)) ||
    p205v_pure_nonzero_mod(nd_native_call(book,t),ks(call)) ||
    agy_str_eq(nm(call),"Bool.and") || agy_str_eq(nm(call),"Bool.or") ||
    p205v_pure_def(book,nm(call),fuel),
    u => False{})

@unsafe
def p205v_pure_go(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +tag = tg(t)
  kc(Bool,agy_str_eq(tag,"Var") || agy_str_eq(tag,"Ref") || core_literal(t),u => True{},u =>
  kc(Bool,agy_str_eq(tag,"Ctr") || agy_str_eq(tag,"Lam") || agy_str_eq(tag,"Let") || agy_str_eq(tag,"Bind"),
    v => p205v_pure_list(book,ks(t),fuel),v =>
  kc(Bool,agy_str_eq(tag,"App"),w => p205v_pure_call(book,t,j_call_spine(t,[]),fuel),w => False{})))

@unsafe
def p205v_pure(book, t, fuel):
  kc(Bool,U32.is_eq(fuel,0),u => False{},u =>
    p205v_pure_go(book,j_strip(t),U32.sub(fuel,1)))

@unsafe
def p205v_bool_val(+t: KTerm) -> U32:
  +s = j_strip(t)
  kc(U32,p98_tag_eq(s,"Ctr") && List.is_empty(&2,KTerm,ks(s)),u =>
    kc(U32,agy_str_eq(nm(s),"True"),v => 2,v =>
    kc(U32,agy_str_eq(nm(s),"False"),w => 1,w => 0)),u => 0)

@unsafe
def p205v_fold_bool(+book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  +ba = p205v_bool_val(a)
  +bb = p205v_bool_val(b)
  kc(KTerm,agy_str_eq(name,"Bool.and"),u =>
    kc(KTerm,U32.is_eq(ba,2),v => b,v =>
    kc(KTerm,U32.is_eq(ba,1) && p205v_pure(book,b,16),w => p205v_bool(False{}),w =>
    kc(KTerm,U32.is_eq(bb,2),x => a,x =>
    kc(KTerm,U32.is_eq(bb,1) && p205v_pure(book,a,16),y => p205v_bool(False{}),y => atom("Absent"))))),u =>
  kc(KTerm,agy_str_eq(name,"Bool.or"),u =>
    kc(KTerm,U32.is_eq(ba,1),v => b,v =>
    kc(KTerm,U32.is_eq(ba,2) && p205v_pure(book,b,16),w => p205v_bool(True{}),w =>
    kc(KTerm,U32.is_eq(bb,1),x => a,x =>
    kc(KTerm,U32.is_eq(bb,2) && p205v_pure(book,a,16),y => p205v_bool(True{}),y => atom("Absent"))))),u => atom("Absent")))

@unsafe
def p205v_words(+book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  match a b:
    case Some{x} Some{y}: p205v_binary(op,x,y)
    case _ _: p205v_range_cmp(op,p205v_range(book,at,8),p205v_range(book,bt,8))

@unsafe
def p205v_fold(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Con{a,Con{b,Nil{}}}:
      +bf = p205v_fold_bool(book,nm(call),a,b)
      kc(KTerm,p98_tag_eq(bf,"Absent"),u => p205v_words(book,nd_native_call(book,t),a,b,j_u32(a),j_u32(b)),u => bf)
    case _: atom("Absent")""",
        """@unsafe
def p205v_pure_op(+op: String) -> Bool:
  String.eq(op,"u32_add") || String.eq(op,"u32_sub") || String.eq(op,"u32_mul") ||
  String.eq(op,"u32_xor") || String.eq(op,"u32_and") || String.eq(op,"u32_or") ||
  String.eq(op,"u32_shln") || String.eq(op,"u32_shrn") ||
  String.eq(op,"u32_is_eq") || String.eq(op,"u32_is_ne") || String.eq(op,"u32_is_lt") ||
  String.eq(op,"u32_is_le") || String.eq(op,"u32_is_gt") || String.eq(op,"u32_is_ge") ||
  String.eq(op,"u32_inc") || String.eq(op,"u32_dec")

@unsafe
def p205v_pure_nonzero_mod(+op: String, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Con{_,Con{b,Nil{}}}: String.eq(op,"u32_mod") && p205v_range_ok(p205v_range_mod(j_u32(b)))
    case _: False{}

@unsafe
def w5c3_pure_def_if(ok: Bool, +book: List<&2,KDef>, +d: KDef, +fuel: U32) -> Bool:
  match ok:
    case True{}: p205v_pure(book,dv(d),fuel)
    case False{}: False{}

@unsafe
def p205v_pure_def(+book: List<&2,KDef>, +name: String, +fuel: U32) -> Bool:
  +d = lookup(book,name)
  w5c3_pure_def_if(String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(p205u_refs(dv(d),name),0) && p205u_room([dv(d)],128), book, d, fuel)

@unsafe
def w5c3_pure_call_op(empty_op: Bool, +book: List<&2,KDef>, +op: String, +cname: String, +args: List<&2,KTerm>, +fuel: U32) -> Bool:
  match empty_op:
    case False{}: p205v_pure_op(op) || p205v_pure_nonzero_mod(op,args) || p205v_pure_def(book,cname,fuel)
    case True{}: p205v_pure_def(book,cname,fuel)

@unsafe
def w5c3_pure_call_bool(is_bool: Bool, +book: List<&2,KDef>, +t: KTerm, +cname: String, +args: List<&2,KTerm>, +fuel: U32) -> Bool:
  match is_bool:
    case True{}: p205v_pure_list(book,args,fuel)
    case False{}:
      +op = nd_native_call(book,t)
      w5c3_pure_call_op(String.is_empty(op), book, op, cname, args, fuel) && p205v_pure_list(book,args,fuel)

@unsafe
def w5c3_pure_call_if(is_call: Bool, +book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  match is_call:
    case False{}: False{}
    case True{}:
      +args = ks(call)
      +cname = nm(call)
      w5c3_pure_call_bool(String.eq(cname,"Bool.and") || String.eq(cname,"Bool.or"), book, t, cname, args, fuel)

@unsafe
def p205v_pure_call(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  w5c3_pure_call_if(p98_tag_eq(call,"Call"), book, t, call, fuel)

@unsafe
def w5c3_pure_app(is_app: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match is_app:
    case True{}: p205v_pure_call(book,t,j_call_spine(t,[]),fuel)
    case False{}: False{}

@unsafe
def w5c3_pure_kids(has_kids: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match has_kids:
    case True{}: p205v_pure_list(book,ks(t),fuel)
    case False{}: w5c3_pure_app(String.eq(tag,"App"), book, t, fuel)

@unsafe
def w5c3_pure_leaf(is_leaf: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match is_leaf:
    case True{}: True{}
    case False{}: w5c3_pure_kids(String.eq(tag,"Ctr") || String.eq(tag,"Lam") || String.eq(tag,"Let") || String.eq(tag,"Bind"), tag, book, t, fuel)

@unsafe
def p205v_pure_go(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +tag = tg(t)
  w5c3_pure_leaf(String.eq(tag,"Var") || String.eq(tag,"Ref") || core_literal(t), tag, book, t, fuel)

@unsafe
def w5c3_pure_fuel(z: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match z:
    case True{}: False{}
    case False{}: p205v_pure_go(book,j_strip(t),U32.sub(fuel,1))

@unsafe
def p205v_pure(book, t, fuel):
  w5c3_pure_fuel(U32.is_eq(fuel,0), book, t, fuel)

@unsafe
def w5c3_bval_false(m: Bool) -> U32:
  match m:
    case True{}: 1
    case False{}: 0

@unsafe
def w5c3_bval_true(m: Bool, +n: String) -> U32:
  match m:
    case True{}: 2
    case False{}: w5c3_bval_false(String.eq(n,"False"))

@unsafe
def w5c3_bval_ctr(ok: Bool, +s: KTerm) -> U32:
  match ok:
    case False{}: 0
    case True{}:
      +n = nm(s)
      w5c3_bval_true(String.eq(n,"True"), n)

@unsafe
def p205v_bool_val(+t: KTerm) -> U32:
  +s = j_strip(t)
  w5c3_bval_ctr(p98_tag_eq(s,"Ctr") && List.is_empty(&2,KTerm,ks(s)), s)

@unsafe
def w5c3_fb_and4(m: Bool) -> KTerm:
  match m:
    case True{}: p205v_bool(False{})
    case False{}: atom("Absent")

@unsafe
def w5c3_fb_and3(m: Bool, +book: List<&2,KDef>, +a: KTerm, +bb: U32) -> KTerm:
  match m:
    case True{}: a
    case False{}: w5c3_fb_and4(U32.is_eq(bb,1) && p205v_pure(book,a,16))

@unsafe
def w5c3_fb_and2(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}: p205v_bool(False{})
    case False{}:
      +bb = p205v_bool_val(b)
      w5c3_fb_and3(U32.is_eq(bb,2), book, a, bb)

@unsafe
def w5c3_fb_and1(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm, +ba: U32) -> KTerm:
  match m:
    case True{}: b
    case False{}: w5c3_fb_and2(U32.is_eq(ba,1) && p205v_pure(book,b,16), book, a, b)

@unsafe
def w5c3_fb_or4(m: Bool) -> KTerm:
  match m:
    case True{}: p205v_bool(True{})
    case False{}: atom("Absent")

@unsafe
def w5c3_fb_or3(m: Bool, +book: List<&2,KDef>, +a: KTerm, +bb: U32) -> KTerm:
  match m:
    case True{}: a
    case False{}: w5c3_fb_or4(U32.is_eq(bb,2) && p205v_pure(book,a,16))

@unsafe
def w5c3_fb_or2(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}: p205v_bool(True{})
    case False{}:
      +bb = p205v_bool_val(b)
      w5c3_fb_or3(U32.is_eq(bb,1), book, a, bb)

@unsafe
def w5c3_fb_or1(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm, +ba: U32) -> KTerm:
  match m:
    case True{}: b
    case False{}: w5c3_fb_or2(U32.is_eq(ba,2) && p205v_pure(book,b,16), book, a, b)

@unsafe
def w5c3_fb_or(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case False{}: atom("Absent")
    case True{}:
      +ba = p205v_bool_val(a)
      w5c3_fb_or1(U32.is_eq(ba,1), book, a, b, ba)

@unsafe
def w5c3_fb_and(m: Bool, +book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}:
      +ba = p205v_bool_val(a)
      w5c3_fb_and1(U32.is_eq(ba,2), book, a, b, ba)
    case False{}: w5c3_fb_or(String.eq(name,"Bool.or"), book, a, b)

@unsafe
def p205v_fold_bool(+book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  w5c3_fb_and(String.eq(name,"Bool.and"), book, name, a, b)

@unsafe
def w5c3_is_range_cmp_op(+op: String) -> Bool:
  String.eq(op,"u32_is_le") || String.eq(op,"u32_is_lt") || String.eq(op,"u32_is_ge") ||
  String.eq(op,"u32_is_gt") || String.eq(op,"u32_is_eq") || String.eq(op,"u32_is_ne")

@unsafe
def w5c3_words_rcmp(ok: Bool, +book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm) -> KTerm:
  match ok:
    case True{}: p205v_range_cmp(op,p205v_range(book,at,8),p205v_range(book,bt,8))
    case False{}: atom("Absent")

@unsafe
def w5c3_words_nonempty(empty: Bool, +book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  match empty:
    case True{}: atom("Absent")
    case False{}:
      match a b:
        case Some{x} Some{y}: p205v_binary(op,x,y)
        case _ _: w5c3_words_rcmp(w5c3_is_range_cmp_op(op), book, op, at, bt)

@unsafe
def p205v_words(+book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  w5c3_words_nonempty(String.is_empty(op), book, op, at, bt, a, b)

@unsafe
def w5c3_fold_op(empty: Bool, +book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm) -> KTerm:
  match empty:
    case True{}: atom("Absent")
    case False{}: p205v_words(book,op,a,b,j_u32(a),j_u32(b))

@unsafe
def w5c3_fold_bf(is_abs: Bool, +book: List<&2,KDef>, +t: KTerm, +a: KTerm, +b: KTerm, +bf: KTerm) -> KTerm:
  match is_abs:
    case True{}:
      +op = nd_native_call(book,t)
      w5c3_fold_op(String.is_empty(op), book, op, a, b)
    case False{}: bf

@unsafe
def p205v_fold(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Con{a,Con{b,Nil{}}}:
      +bf = p205v_fold_bool(book,nm(call),a,b)
      w5c3_fold_bf(p98_tag_eq(bf,"Absent"), book, t, a, b, bf)
    case _: atom("Absent")""",
        "fast_p205v_pure_and_fold",
    )

    src = replace_exact(
        src,
        """@unsafe
def p205v_field_next(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      kc(P205UFields,ok,u => p205u_field_join(term,True{},p205v_fields(book,rest,next,steps,fuel)),u => P205UFields{[],next,steps,False{}})

@unsafe
def p205v_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205v_field_next(book,rest,fuel,p205v_eval(book,x,next,steps,fuel))

@unsafe
def p205v_mat_spine(+t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  kc(P205UFields,p98_tag_eq(t,"App"),
    u => p205v_mat_spine(kid(t,0),Con{kid(t,1),args}),
    u => P205UFields{Con{t,args},0,0,True{}})

@unsafe
def p205v_try_beta(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +sp: P205UFields) -> P205UResult:
  match sp:
    case P205UFields{Con{hd,args},_,_,_}:
      +h = j_strip(hd)
      kc(P205UResult,(p98_tag_eq(h,"Lam") && U32.is_ne(qt(h),0) && U32.is_ne(qt(h),3)) ||
        (p98_tag_eq(h,"Mat") && U32.is_eq(ix(h),0) && U32.is_eq(terms_len(ks(h)),2) &&
          Bool.not(List.is_empty(&2,KTerm,args)) && p98_tag_eq(j_strip(p205u_at(args,0)),"Ctr")),
        u => p205v_apply(book,h,args,next,U32.inc(steps),fuel),
        u => P205UResult{t,next,steps,True{}})
    case _: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_let_step(+book: List<&2,KDef>, +t: KTerm, +b: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  +rhs = kid(b,0)
  +bid = ix(b)
  kc(P205UResult,p205v_static(j_strip(rhs)),
    u => p205v_eval(book,subst(body,bid,j_strip(rhs)),next,U32.inc(steps),fuel),u =>
  kc(P205UResult,U32.is_eq(p205u_vars(body,bid),0) && p205v_pure(book,rhs,16),
    v => p205v_eval(book,body,next,U32.inc(steps),fuel),v =>
    P205UResult{t,next,steps,True{}}))""",
        """@unsafe
def p205v_field_next(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      match ok:
        case True{}: p205u_field_join(term,True{},p205v_fields(book,rest,next,steps,fuel))
        case False{}: P205UFields{[],next,steps,False{}}

@unsafe
def p205v_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205v_field_next(book,rest,fuel,p205v_eval(book,x,next,steps,fuel))

@unsafe
def w5c3_mspine_if(is_app: Bool, +t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  match is_app:
    case True{}: p205v_mat_spine(kid(t,0),Con{kid(t,1),args})
    case False{}: P205UFields{Con{t,args},0,0,True{}}

@unsafe
def p205v_mat_spine(+t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  w5c3_mspine_if(p98_tag_eq(t,"App"), t, args)

@unsafe
def w5c3_beta_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +h: KTerm, +args: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match ok:
    case True{}: p205v_apply(book,h,args,next,U32.inc(steps),fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_try_beta(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +sp: P205UFields) -> P205UResult:
  match sp:
    case P205UFields{Con{hd,args},_,_,_}:
      +h = j_strip(hd)
      w5c3_beta_if((p98_tag_eq(h,"Lam") && U32.is_ne(qt(h),0) && U32.is_ne(qt(h),3)) ||
        (p98_tag_eq(h,"Mat") && U32.is_eq(ix(h),0) && U32.is_eq(terms_len(ks(h)),2) &&
          Bool.not(List.is_empty(&2,KTerm,args)) && p98_tag_eq(j_strip(p205u_at(args,0)),"Ctr")),
        book, t, h, args, next, steps, fuel)
    case _: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_let_dead(dead: Bool, +book: List<&2,KDef>, +t: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match dead:
    case True{}: p205v_eval(book,body,next,U32.inc(steps),fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_let_stat(st: Bool, +book: List<&2,KDef>, +t: KTerm, +rhs: KTerm, +srhs: KTerm, +bid: U32, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match st:
    case True{}: p205v_eval(book,subst(body,bid,srhs),next,U32.inc(steps),fuel)
    case False{}: w5c3_let_dead(Bool.not(w5c3_has_var(body,bid)) && p205v_pure(book,rhs,16), book, t, body, next, steps, fuel)

@unsafe
def p205v_let_step(+book: List<&2,KDef>, +t: KTerm, +b: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  +rhs = kid(b,0)
  +bid = ix(b)
  +srhs = j_strip(rhs)
  w5c3_let_stat(p205v_static(srhs), book, t, rhs, srhs, bid, body, next, steps, fuel)""",
        "fast_p205v_beta_let",
    )

    src = replace_exact(
        src,
        """@unsafe
def p205v_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  kc(P205UResult,p205v_allowed(body) && U32.is_eq(p205u_refs(body,dn(d)),0),u =>
    p205v_typed(p205v_fresh(book,t,ks(call),steps,fuel,f_fresh_term(body,[],next)),p205v_after_args(book,dt(d),terms_len(ks(call)))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_def(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  kc(P205UResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && p205u_room([dv(d)],512) && p205v_result_type(book,dt(d)),u =>
      p205v_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_folded(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(folded,"Absent"),u =>
    kc(P205UResult,p205v_any_with_range(book,ks(call)),v => p205v_def(book,t,next,steps,fuel,call,lookup(book,nm(call))),v => P205UResult{t,next,steps,True{}}),u =>
    P205UResult{folded,next,U32.inc(steps),True{}})
@unsafe
def p205v_call(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5),u =>
    p205v_folded(book,t,next,steps,fuel,call,p205v_fold(book,t,call,ks(call))),
    u => p205v_try_beta(book,t,next,steps,fuel,p205v_mat_spine(t,[])))

@unsafe
def p205v_after(+book: List<&2,KDef>, +old: KTerm, +fuel: U32, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}:
      +t = k_with_children(old,terms)
      kc(P205UResult,ok && p98_tag_eq(t,"App"),u => p205v_call(book,t,next,steps,fuel,j_call_spine(t,[])),u =>
        kc(P205UResult,ok && p98_tag_eq(t,"Let") && U32.is_eq(terms_len(ks(t)),2) &&
          p98_tag_eq(kid(t,0),"Bind") && U32.is_eq(terms_len(ks(kid(t,0))),1),v =>
            p205v_let_step(book,t,kid(t,0),kid(t,1),next,steps,fuel),v => P205UResult{t,next,steps,ok}))

@unsafe
def p205v_eval(book, t, next, steps, fuel):
  kc(P205UResult,U32.is_eq(fuel,0) || U32.is_ge(steps,4096),u => P205UResult{t,next,steps,False{}},u =>
    p205v_after(book,t,U32.sub(fuel,1),p205v_fields(book,ks(t),next,steps,U32.sub(fuel,1))))""",
        """@unsafe
def w5c3_p205v_body_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_typed(p205v_fresh(book,t,ks(call),steps,fuel,f_fresh_term(body,[],next)),p205v_after_args(book,dt(d),terms_len(ks(call))))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  w5c3_p205v_body_if(p205v_allowed(body) && U32.is_eq(p205u_refs(body,dn(d)),0), book, t, next, steps, fuel, call, d, body)

@unsafe
def w5c3_p205v_def_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  match ok:
    case True{}: p205v_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d)))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_def(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  w5c3_p205v_def_if(String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && p205u_room([dv(d)],512) && p205v_result_type(book,dt(d)), book, t, next, steps, fuel, call, d)

@unsafe
def w5c3_p205v_any_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_def(book,t,next,steps,fuel,call,lookup(book,nm(call)))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_p205v_folded_if(is_abs: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  match is_abs:
    case True{}: w5c3_p205v_any_if(p205v_any_with_range(book,ks(call)), book, t, next, steps, fuel, call)
    case False{}: P205UResult{folded,next,U32.inc(steps),True{}}

@unsafe
def p205v_folded(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  w5c3_p205v_folded_if(p98_tag_eq(folded,"Absent"), book, t, next, steps, fuel, call, folded)

@unsafe
def w5c3_p205v_call_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_folded(book,t,next,steps,fuel,call,p205v_fold(book,t,call,ks(call)))
    case False{}: p205v_try_beta(book,t,next,steps,fuel,p205v_mat_spine(t,[]))

@unsafe
def p205v_call(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  w5c3_p205v_call_if(p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5), book, t, next, steps, fuel, call)

@unsafe
def w5c3_after_let(is_let: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match is_let:
    case True{}: p205v_let_step(book,t,kid(t,0),kid(t,1),next,steps,fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_after_app(is_app: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match is_app:
    case True{}: p205v_call(book,t,next,steps,fuel,j_call_spine(t,[]))
    case False{}:
      w5c3_after_let(p98_tag_eq(t,"Let") && U32.is_eq(terms_len(ks(t)),2) &&
        p98_tag_eq(kid(t,0),"Bind") && U32.is_eq(terms_len(ks(kid(t,0))),1), book, t, next, steps, fuel)

@unsafe
def p205v_after(+book: List<&2,KDef>, +old: KTerm, +fuel: U32, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}:
      match ok:
        case False{}: P205UResult{k_with_children(old,terms),next,steps,False{}}
        case True{}:
          +t = k_with_children(old,terms)
          w5c3_after_app(p98_tag_eq(t,"App"), book, t, next, steps, fuel)

@unsafe
def w5c3_eval_kids(+kids: List<&2,KTerm>, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +f1: U32) -> P205UResult:
  match kids:
    case Nil{}: P205UResult{t,next,steps,True{}}
    case Con{_,_}: p205v_after(book,t,f1,p205v_fields(book,kids,next,steps,f1))

@unsafe
def w5c3_eval_if(stop: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match stop:
    case True{}: P205UResult{t,next,steps,False{}}
    case False{}: w5c3_eval_kids(ks(t), book, t, next, steps, U32.sub(fuel,1))

@unsafe
def p205v_eval(book, t, next, steps, fuel):
  w5c3_eval_if(U32.is_eq(fuel,0) || U32.is_ge(steps,4096), book, t, next, steps, fuel)""",
        "fast_p205v_eval",
    )

    # 6b. p205u_children: zero-closure parameter match (used in p205u_room)
    src = replace_exact(
        src,
        """@unsafe
def p205u_children(+t: KTerm) -> List<&2,KTerm>:
  kc(List<&2,KTerm>,p98_tag_eq(t,"Ann"),u => [kid(t,0)],u =>
    kc(List<&2,KTerm>,p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"),v => [],v => ks(t)))""",
        """@unsafe
def w5c3_p205u_ch_leaf(is_leaf: Bool, +t: KTerm) -> List<&2,KTerm>:
  match is_leaf:
    case True{}: []
    case False{}: ks(t)

@unsafe
def w5c3_p205u_ch_ann(is_ann: Bool, +t: KTerm) -> List<&2,KTerm>:
  match is_ann:
    case True{}: [kid(t,0)]
    case False{}: w5c3_p205u_ch_leaf(p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"), t)

@unsafe
def p205u_children(+t: KTerm) -> List<&2,KTerm>:
  w5c3_p205u_ch_ann(p98_tag_eq(t,"Ann"), t)""",
        "fast_p205u_children",
    )

    # 7. w2d_walk* (13.8% of p86_plan): zero-closure parameter match + String.eq
    src = replace_exact(
        src,
        """@unsafe
def w2d_is_fusable_prod(+prod: KTerm) -> Bool:
  +s = j_strip(prod)
  (p98_tag_eq(s,"Ctr") && (agy_str_eq(nm(s),"SCon") || agy_str_eq(nm(s),"SNil"))) ||
  p98_tag_eq(s,"Let") || p98_tag_eq(s,"App")""",
        """@unsafe
def w2d_is_fusable_prod(+prod: KTerm) -> Bool:
  +s = j_strip(prod)
  (p98_tag_eq(s,"Ctr") && (String.eq(nm(s),"SCon") || String.eq(nm(s),"SNil"))) ||
  p98_tag_eq(s,"Let") || p98_tag_eq(s,"App")""",
        "fast_w2d_fusable",
    )

    src = replace_exact(
        src,
        """@unsafe
def w2d_walk_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  kc(W2State,p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2) && w2d_is_fusable_prod(p205u_at(ks(call),0)),
    u => w2d_walk_check_fold(ctx,added,next,t,call,w2d_check_fold(ctx,lookup(ctx,nm(call))),fuel),
    u => w2d_walk_children(ctx,added,next,t,ks(t),fuel))

@unsafe
def w2d_walk(ctx, added, next, t, fuel):
  kc(W2State,U32.is_eq(fuel,0),u => W2State{ctx,added,next,t,False{}},u =>
  kc(W2State,p98_tag_eq(t,"Ann"),
    a => w2d_walk_ann(ctx,added,next,t,U32.sub(fuel,1)),u =>
  kc(W2State,p98_tag_eq(t,"App"),
    v => w2d_walk_call(ctx,added,next,t,j_call_spine(t,[]),U32.sub(fuel,1)),
    v => w2d_walk_children(ctx,added,next,t,ks(t),U32.sub(fuel,1)))))

@unsafe
def w2d_walk_ann_res(+orig: KTerm, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,t2,ch2}:
      W2State{ctx2,added2,next2,kc(KTerm,ch2,u => kt("Ann","",0,0,[t2,kid(orig,1)]),u => orig),ch2}""",
        """@unsafe
def w5c3_w2d_call_if(ok: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  match ok:
    case True{}: w2d_walk_check_fold(ctx,added,next,t,call,w2d_check_fold(ctx,lookup(ctx,nm(call))),fuel)
    case False{}: w2d_walk_children(ctx,added,next,t,ks(t),fuel)

@unsafe
def w2d_walk_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  w5c3_w2d_call_if(p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2) && w2d_is_fusable_prod(p205u_at(ks(call),0)),
    ctx, added, next, t, call, fuel)

@unsafe
def w5c3_w2d_app(is_app: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +f1: U32) -> W2State:
  match is_app:
    case True{}: w2d_walk_call(ctx,added,next,t,j_call_spine(t,[]),f1)
    case False{}: w2d_walk_children(ctx,added,next,t,ks(t),f1)

@unsafe
def w5c3_w2d_ann(is_ann: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +f1: U32) -> W2State:
  match is_ann:
    case True{}: w2d_walk_ann(ctx,added,next,t,f1)
    case False{}: w5c3_w2d_app(p98_tag_eq(t,"App"), ctx, added, next, t, f1)

@unsafe
def w5c3_w2d_fuel(z: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +fuel: U32) -> W2State:
  match z:
    case True{}: W2State{ctx,added,next,t,False{}}
    case False{}: w5c3_w2d_ann(p98_tag_eq(t,"Ann"), ctx, added, next, t, U32.sub(fuel,1))

@unsafe
def w2d_walk(ctx, added, next, t, fuel):
  w5c3_w2d_fuel(U32.is_eq(fuel,0), ctx, added, next, t, fuel)

@unsafe
def w5c3_w2d_ann_out(ch2: Bool, +orig: KTerm, +t2: KTerm) -> KTerm:
  match ch2:
    case True{}: kt("Ann","",0,0,[t2,kid(orig,1)])
    case False{}: orig

@unsafe
def w2d_walk_ann_res(+orig: KTerm, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,t2,ch2}:
      W2State{ctx2,added2,next2,w5c3_w2d_ann_out(ch2, orig, t2),ch2}""",
        "fast_w2d_walk",
    )

    return src


def main():
    ap = argparse.ArgumentParser(description="Apply Wave 5 W5-C3 frontend/lowering/verifier speedups")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    out = apply_patches(args.src.read_text())
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"Patched W5-C3 -> {args.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()

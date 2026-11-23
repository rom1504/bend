#!/usr/bin/env python3
"""
Wave 8 surgical patch for `x198pw_plan` 3.33 MB bottlenecks (`w8_pw_3mb`):
1. `p113pl_candidates` (>32.4s, killed by 180s timeout on 3.33 MB):
   - Eliminates 17-deep nested `nt_choose` closure chain in `p118t_original_live`
     (up to 34 closure allocations per AST node on top of 3.65 GB live V8 heap).
   - Eliminates 5-deep nested `nt_choose` chain in `p113pl_app`.
   - Guards `j_fusion_def` BEFORE `j_fusion_after`/`j_call_spine` in `p121f_plan`
     and `p121c_admitted`.
   - Pre-indexes `bangs` into a `KDef` hash trie once in `p113pl_candidates`
     (O(1) `w5c3_find` instead of O(|bangs|) linear `nb_contains` per def) and
     makes `p113pl_candidates` tail-recursive with direct `match`.
2. `p112s_prepare` (16.25s on 3.33 MB, 151x blowup from 107.7ms on 679 KB):
   - Eliminates all `nt_choose` closures in `p112s_term`, `p112s_rebuild`,
     `p112s_constructor`, `p112s_intern`, and `p112s_defs`.
   - Replaces `index_find(..., 32)` / `index_set(..., 32)` in `p112s_intern`
     and `p112s_node_index` with `w5c3_find` / `p131i_insert`.

Usage:
  python3 research/agy/w8_pw_3mb/apply_w8_pw_3mb.py --src <in.bend> --dst <out.bend>
"""
import argparse
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def apply_patch(src: str) -> str:
    # 1. p112s_intern, p112s_constructor, p112s_rebuild, p112s_term, p112s_defs, p112s_node_index
    old_p112s_intern = """@unsafe
def p112s_intern(+term: KTerm, +fields: List<&2,P112SWord>, image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{+size,+nodes,+index,+error}:
      +key = nc_ctor_codes(nm(term)) ++ ":" ++ p112s_fields_key(fields)
      +hash = index_hash(key,2166136261)
      +old = index_find(index,key,hash,32)
      +count = nt_count(P112SWord,fields)
      nt_choose(P112STerm,agy_str_eq(dk(old),"P112StaticIntern"),
        u => P112STerm{p112s_marker(P112SBox{nm(term),da(old)}),P112SImage{size,nodes,index,error}},u =>
      nt_choose(P112STerm,U32.is_le(size,65536) && U32.is_le(count,U32.sub(65536,size)),
        u => P112STerm{p112s_marker(P112SBox{nm(term),size}),P112SImage{U32.add(size,count),Con{P112SNode{size,nm(term),fields},nodes},index_set(index,KDef{key,"P112StaticIntern",size,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},hash,32),error}},
        u => P112STerm{term,P112SImage{size,nodes,index,error}}))"""

    new_p112s_intern = """@unsafe
def w8_p112s_intern_fit(fits: Bool, +term: KTerm, +fields: List<&2,P112SWord>, +key: String, +hash: U32, +count: U32, +size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String) -> P112STerm:
  match fits:
    case True{}:
      P112STerm{p112s_marker(P112SBox{nm(term),size}),P112SImage{U32.add(size,count),Con{P112SNode{size,nm(term),fields},nodes},p131i_insert(index,KDef{key,"P112StaticIntern",size,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},hash),error}}
    case False{}:
      P112STerm{term,P112SImage{size,nodes,index,error}}

@unsafe
def w8_p112s_intern_hit(hit: Bool, +old: KDef, +term: KTerm, +fields: List<&2,P112SWord>, +key: String, +hash: U32, +size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String) -> P112STerm:
  match hit:
    case True{}:
      P112STerm{p112s_marker(P112SBox{nm(term),da(old)}),P112SImage{size,nodes,index,error}}
    case False{}:
      +count = nt_count(P112SWord,fields)
      w8_p112s_intern_fit(U32.is_le(size,65536) && U32.is_le(count,U32.sub(65536,size)),term,fields,key,hash,count,size,nodes,index,error)

@unsafe
def p112s_intern(+term: KTerm, +fields: List<&2,P112SWord>, image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{+size,+nodes,+index,+error}:
      +key = nc_ctor_codes(nm(term)) ++ ":" ++ p112s_fields_key(fields)
      +hash = index_hash(key,2166136261)
      +old = w5c3_find(index,key,hash)
      w8_p112s_intern_hit(agy_str_eq(dk(old),"P112StaticIntern"),old,term,fields,key,hash,size,nodes,index,error)"""

    src = replace_exact(src, old_p112s_intern, new_p112s_intern, "p112s_intern")

    old_p112s_ctor = """@unsafe
def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  nt_choose(P112STerm,agy_str_eq(tg(term),"NWord"),u => P112STerm{term,image},u =>
    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>
      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => p112s_intern(term,p112s_fields(ks(term)),image)),
      u => P112STerm{term,image}))"""

    new_p112s_ctor = """@unsafe
def w8_p112s_ctor_pack(isPacked: Bool, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isPacked:
    case True{}: p112s_packed(term,ks(term),image)
    case False{}: p112s_intern(term,p112s_fields(ks(term)),image)

@unsafe
def w8_p112s_ctor_ok(ok: Bool, +term: KTerm, +image: P112SImage) -> P112STerm:
  match ok:
    case True{}: w8_p112s_ctor_pack(ns_packed(term),term,image)
    case False{}: P112STerm{term,image}

@unsafe
def w8_p112s_ctor_word(isWord: Bool, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isWord:
    case True{}: P112STerm{term,image}
    case False{}: w8_p112s_ctor_ok(ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),term,image)

@unsafe
def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  w8_p112s_ctor_word(agy_str_eq(tg(term),"NWord"),constructors,term,image)"""

    if old_p112s_ctor in src:
        src = replace_exact(src, old_p112s_ctor, new_p112s_ctor, "p112s_constructor")

    old_p112s_rebuild_term = """@unsafe
def p112s_rebuild(+constructors: KDef, +original: KTerm, children: P112STerms) -> P112STerm:
  match children:
    case P112STerms{kids,+image}:
      +term = k_rebuild(original,nm(original),ix(original),qt(original),kids,rm(original),kb(original),ke(original))
      nt_choose(P112STerm,agy_str_eq(tg(term),"Ctr"),u => p112s_constructor(constructors,ns_static_scalar(term),image),u => P112STerm{term,image})


@unsafe
def p112s_stale(image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{size,nodes,index,error}: P112STerm{{KTerm{"NativeStaticInput", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},P112SImage{size,nodes,index,p111_first(error,"static atom present before fresh preparation")}}


@unsafe
def p112s_term(constructors,term,image):
  nt_choose(P112STerm,agy_str_eq(tg(term),"NStatic") || agy_str_eq(tg(term),"NWPattern"),u => p112s_stale(image),u =>
    nt_choose(P112STerm,agy_str_eq(tg(term),"NWord") || agy_str_eq(tg(term),"Var") || agy_str_eq(tg(term),"Ref"),
      u => P112STerm{term,image},u => p112s_rebuild(constructors,term,p112s_terms(constructors,ks(term),image))))


@unsafe
def p112s_defs(+book: List<&2,KDef>, +constructors: KDef, names: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match names:
    case Nil{}: P112SDefs{facts,image}
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(P112SDefs,agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),
        u => p112s_def_step(book,constructors,rest,name,facts,p112s_term(constructors,nc_compact(nc_definition(book,definition,0)),image)),
        u => p112s_defs(book,constructors,rest,facts,image))"""

    new_p112s_rebuild_term = """@unsafe
def w8_p112s_rebuild_ctr(isCtr: Bool, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isCtr:
    case True{}: p112s_constructor(constructors,ns_static_scalar(term),image)
    case False{}: P112STerm{term,image}

@unsafe
def p112s_rebuild(+constructors: KDef, +original: KTerm, children: P112STerms) -> P112STerm:
  match children:
    case P112STerms{kids,+image}:
      +term = k_rebuild(original,nm(original),ix(original),qt(original),kids,rm(original),kb(original),ke(original))
      w8_p112s_rebuild_ctr(agy_str_eq(tg(term),"Ctr"),constructors,term,image)


@unsafe
def p112s_stale(image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{size,nodes,index,error}: P112STerm{{KTerm{"NativeStaticInput", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},P112SImage{size,nodes,index,p111_first(error,"static atom present before fresh preparation")}}


@unsafe
def w8_p112s_term_leaf(isLeaf: Bool, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isLeaf:
    case True{}: P112STerm{term,image}
    case False{}: p112s_rebuild(constructors,term,p112s_terms(constructors,ks(term),image))

@unsafe
def w8_p112s_term_stale(isStale: Bool, +tag: String, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isStale:
    case True{}: p112s_stale(image)
    case False{}: w8_p112s_term_leaf(agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"Ref"),constructors,term,image)

@unsafe
def p112s_term(constructors,term,image):
  +tag = tg(term)
  w8_p112s_term_stale(agy_str_eq(tag,"NStatic") || agy_str_eq(tag,"NWPattern"),tag,constructors,term,image)


@unsafe
def w8_p112s_def_ok(ok: Bool, +book: List<&2,KDef>, +constructors: KDef, +name: String, +definition: KDef, +rest: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match ok:
    case True{}: p112s_def_step(book,constructors,rest,name,facts,p112s_term(constructors,nc_compact(nc_definition(book,definition,0)),image))
    case False{}: p112s_defs(book,constructors,rest,facts,image)

@unsafe
def p112s_defs(+book: List<&2,KDef>, +constructors: KDef, names: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match names:
    case Nil{}: P112SDefs{facts,image}
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      w8_p112s_def_ok(agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),book,constructors,name,definition,rest,facts,image)"""

    src = replace_exact(src, old_p112s_rebuild_term, new_p112s_rebuild_term, "p112s_rebuild_term_defs")

    old_p112s_node_index = """@unsafe
def p112s_node_index(nodes: List<&2,P112SNode>, index: KDef) -> KDef:
  match nodes:
    case Nil{}: index
    case Con{P112SNode{+offset,name,fields},rest}:
      +key = U32.show(offset)
      p112s_node_index(rest,index_set(index,KDef{key,"P112StaticNode",offset,nt_count(P112SWord,fields),atom(name),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(key,2166136261),32))"""

    new_p112s_node_index = """@unsafe
def p112s_node_index(nodes: List<&2,P112SNode>, index: KDef) -> KDef:
  match nodes:
    case Nil{}: index
    case Con{P112SNode{+offset,name,fields},rest}:
      +key = U32.show(offset)
      p112s_node_index(rest,p131i_insert(index,KDef{key,"P112StaticNode",offset,nt_count(P112SWord,fields),atom(name),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(key,2166136261)))"""

    src = replace_exact(src, old_p112s_node_index, new_p112s_node_index, "p112s_node_index")

    # 2. p113pl_app: eliminate 5-deep nt_choose closures
    old_p113pl_app = """@unsafe
def p113pl_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,agy_str_eq(tg(head),"Efq"),
    u => p113pl_live(book,head,env,target,n),u =>
  nt_choose(P113DCode,String.is_empty(prim),
    u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Lam"),u => p113pl_lower(book,nd_beta(head,args),env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nq_match_args(args),
      v => p113pl_lower(book,nd_match_sequence(head,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113d_fail("product higher-order matcher",n)),u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Ref"),u => p113pl_ref_app(book,head,args,env,target,n),
    u => p113d_fail("product dynamic call",n)))),u => p113pl_lower(book,nc_sequence("NOp",prim,args,[],n),env,target,U32.add(n,terms_len(args)))))"""

    new_p113pl_app = """@unsafe
def w8_p113pl_app_ref(isRef: Bool, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isRef:
    case True{}: p113pl_ref_app(book,head,args,env,target,n)
    case False{}: p113d_fail("product dynamic call",n)

@unsafe
def w8_p113pl_app_mat_ok(ok: Bool, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match ok:
    case True{}: p113pl_lower(book,nd_match_sequence(head,args,[],n),env,target,U32.add(n,terms_len(args)))
    case False{}: p113d_fail("product higher-order matcher",n)

@unsafe
def w8_p113pl_app_mat(isMat: Bool, +htag: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isMat:
    case True{}: w8_p113pl_app_mat_ok(U32.is_eq(terms_len(args),1) || nq_match_args(args),book,head,args,env,target,n)
    case False{}: w8_p113pl_app_ref(agy_str_eq(htag,"Ref"),book,head,args,env,target,n)

@unsafe
def w8_p113pl_app_lam(isLam: Bool, +htag: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isLam:
    case True{}: p113pl_lower(book,nd_beta(head,args),env,target,n)
    case False{}: w8_p113pl_app_mat(agy_str_eq(htag,"Mat"),htag,book,head,args,env,target,n)

@unsafe
def w8_p113pl_app_prim(noPrim: Bool, +htag: String, +prim: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match noPrim:
    case True{}: w8_p113pl_app_lam(agy_str_eq(htag,"Lam"),htag,book,head,args,env,target,n)
    case False{}: p113pl_lower(book,nc_sequence("NOp",prim,args,[],n),env,target,U32.add(n,terms_len(args)))

@unsafe
def w8_p113pl_app_efq(isEfq: Bool, +htag: String, +book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isEfq:
    case True{}: p113pl_live(book,head,env,target,n)
    case False{}:
      +prim = nd_native_call(book,t)
      w8_p113pl_app_prim(String.is_empty(prim),htag,prim,book,head,args,env,target,n)

@unsafe
def p113pl_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +htag = tg(head)
  +args = nd_args(t,[])
  w8_p113pl_app_efq(agy_str_eq(htag,"Efq"),htag,book,t,head,args,env,target,n)"""

    src = replace_exact(src, old_p113pl_app, new_p113pl_app, "p113pl_app")

    # 3. p113pl_candidates: pre-index bangs in hash trie + tail-recursive accumulator + direct match
    old_p113pl_cands = """@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +info = lookup(signatures,name)
      nt_choose(List<&2,P113DCandidate>,agy_str_eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),64),
        u => nt_append(P113DCandidate,p121f_selected(book,name,signatures,p121f_plan(book,definition)),
          nt_choose(List<&2,P113DCandidate>,agy_str_eq(tg(dv(info)),"NQSig"),
            v => Con{p113pl_flat_candidate(book,name,signatures),p113pl_candidates(book,rest,bangs,signatures)},
            v => p113pl_candidates(book,rest,bangs,signatures))),
        u => p113pl_candidates(book,rest,bangs,signatures))"""

    new_p113pl_cands = """@unsafe
def w8_bangs_index(bangs: List<&2,String>, acc: KDef) -> KDef:
  match bangs:
    case Nil{}: acc
    case Con{+b,rest}:
      +h = index_hash(b,2166136261)
      w8_bangs_index(rest,p131i_insert(acc,KDef{b,"Bang",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},h))

@unsafe
def w8_push_rev(xs: List<&2,P113DCandidate>, acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match xs:
    case Nil{}: acc
    case Con{h,t}: w8_push_rev(t,Con{h,acc})

law w8_p113pl_cands_loop:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  for +bangMap: KDef
  for +signatures: List<&2,KDef>
  for +acc: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

@unsafe
def w8_p113pl_cands_flat(isFlat: Bool, +book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangMap: KDef, +signatures: List<&2,KDef>, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match isFlat:
    case True{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,Con{p113pl_flat_candidate(book,name,signatures),acc})
    case False{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,acc)

@unsafe
def w8_p113pl_cands_ok(ok: Bool, +book: List<&2,KDef>, +name: String, +definition: KDef, +rest: List<&2,String>, +bangMap: KDef, +signatures: List<&2,KDef>, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match ok:
    case True{}:
      +sel = p121f_selected(book,name,signatures,p121f_plan(book,definition))
      +acc1 = w8_push_rev(sel,acc)
      +info = lookup(signatures,name)
      w8_p113pl_cands_flat(agy_str_eq(tg(dv(info)),"NQSig"),book,name,rest,bangMap,signatures,acc1)
    case False{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,acc)

@unsafe
def w8_p113pl_cands_loop(book,names,bangMap,signatures,acc):
  match names:
    case Nil{}: nt_reverse(P113DCandidate,acc,[])
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +bh = index_hash(name,2166136261)
      +isBang = Bool.not(agy_str_eq(dk(w5c3_find(bangMap,name,bh)),"Absent"))
      w8_p113pl_cands_ok(agy_str_eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || isBang) && U32.is_le(nd_arity(book,name),64),
        book,name,definition,rest,bangMap,signatures,acc)

@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  w8_p113pl_cands_loop(book,names,w8_bangs_index(bangs,missing()),signatures,[])"""

    src = replace_exact(src, old_p113pl_cands, new_p113pl_cands, "p113pl_candidates")

    # 4. p118t_original_live: eliminate 17-deep nested nt_choose closures (up to 34 closures per AST node!)
    old_p118t_live = """@unsafe
def p118t_original_live(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +tag = tg(t)
  nt_choose(P113DCode,agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"NStatic"),u => p113pl_boxed(p113d_value(book,t,env),target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NQBundle"),u => p113pl_output(kt("NQShape",nm(t),terms_len(ks(t)),0,[]),p111_values(ks(t),env),target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NQBox"),u => p113pl_boxed(p111_constructor(nm(t),p111_values(ks(t),env)),target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ref"),u => p113pl_ref(book,t,env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Loc") || agy_str_eq(tag,"Src") || agy_str_eq(tag,"Cut") || agy_str_eq(tag,"Slf") || agy_str_eq(tag,"Ins"),u => p113pl_lower(book,kid(t,0),env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"App"),u => p113pl_app(book,t,env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Let") || agy_str_eq(tag,"NSeqLet"),u => p113pl_lets(book,ks(t),env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NNatAdd"),u => p113pl_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,target,U32.inc(n)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NNatSum"),u => p113pl_nat(p111_values(ks(t),env),target,n,U32.read(nm(t))),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ctr"),u => p113pl_ctor(book,t,env,target,n,nc_literal(t)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NCtr") || agy_str_eq(tag,"NOp"),u => p113pl_operation(book,t,env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NPCall"),u => p113pl_call(book,nm(t),ks(t),env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NCall"),u => p113pl_call_result(nm(t),p111_values(ks(t),env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"All") || agy_str_eq(tag,"Qua") || agy_str_eq(tag,"ADT") || agy_str_eq(tag,"Eql"),u => p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{0,0}],target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NMatch"),u => p113pl_match(book,t,env,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Efq"),u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Rwt"),u => p113pl_lower(book,kid(t,2),env,target,n),
    u => p113d_fail("product unsupported core node " ++ tag,n))))))))))))))))))"""

    new_p118t_live = """@unsafe
def w8_pl_live_16(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,kid(t,2),env,target,n)
    case False{}: p113d_fail("product unsupported core node " ++ tag,n)

@unsafe
def w8_pl_live_15(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n))
    case False{}: w8_pl_live_16(agy_str_eq(tag,"Rwt"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_14(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_match(book,t,env,target,n)
    case False{}: w8_pl_live_15(agy_str_eq(tag,"Efq"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_13(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{0,0}],target,n)
    case False{}: w8_pl_live_14(agy_str_eq(tag,"NMatch"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_12(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_call_result(nm(t),p111_values(ks(t),env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n)
    case False{}: w8_pl_live_13(agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"All") || agy_str_eq(tag,"Qua") || agy_str_eq(tag,"ADT") || agy_str_eq(tag,"Eql"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_11(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_call(book,nm(t),ks(t),env,target,n)
    case False{}: w8_pl_live_12(agy_str_eq(tag,"NCall"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_10(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_operation(book,t,env,target,n)
    case False{}: w8_pl_live_11(agy_str_eq(tag,"NPCall"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_9(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_ctor(book,t,env,target,n,nc_literal(t))
    case False{}: w8_pl_live_10(agy_str_eq(tag,"NCtr") || agy_str_eq(tag,"NOp"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_8(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_nat(p111_values(ks(t),env),target,n,U32.read(nm(t)))
    case False{}: w8_pl_live_9(agy_str_eq(tag,"Ctr"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_7(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,target,U32.inc(n))
    case False{}: w8_pl_live_8(agy_str_eq(tag,"NNatSum"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_6(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lets(book,ks(t),env,target,n)
    case False{}: w8_pl_live_7(agy_str_eq(tag,"NNatAdd"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_5(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_app(book,t,env,target,n)
    case False{}: w8_pl_live_6(agy_str_eq(tag,"Let") || agy_str_eq(tag,"NSeqLet"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_4(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,kid(t,0),env,target,n)
    case False{}: w8_pl_live_5(agy_str_eq(tag,"App"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_3(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_ref(book,t,env,target,n)
    case False{}: w8_pl_live_4(agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Loc") || agy_str_eq(tag,"Src") || agy_str_eq(tag,"Cut") || agy_str_eq(tag,"Slf") || agy_str_eq(tag,"Ins"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_2(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_boxed(p111_constructor(nm(t),p111_values(ks(t),env)),target,n)
    case False{}: w8_pl_live_3(agy_str_eq(tag,"Ref"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_1(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_output(kt("NQShape",nm(t),terms_len(ks(t)),0,[]),p111_values(ks(t),env),target,n)
    case False{}: w8_pl_live_2(agy_str_eq(tag,"NQBox"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_0(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_boxed(p113d_value(book,t,env),target,n)
    case False{}: w8_pl_live_1(agy_str_eq(tag,"NQBundle"),tag,book,t,env,target,n)

@unsafe
def p118t_original_live(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +tag = tg(t)
  w8_pl_live_0(agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"NStatic"),tag,book,t,env,target,n)"""

    src = replace_exact(src, old_p118t_live, new_p118t_live, "p118t_original_live")

    # 5. p121f_plan & p121c_admitted: guard j_fusion_def BEFORE j_fusion_after / j_call_spine
    old_p121f_plan = """@unsafe
def p121f_plan(+book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  +body = j_fusion_after(dv(d),da(d))
  +r = j_call_spine(body,[])
  +m = j_call_spine(kid(r,0),[])
  nt_choose(P121FPlan,j_fusion_def(d,da(d)) && U32.is_gt(da(d),0) && U32.is_le(da(d),8) &&
    agy_str_eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
    agy_str_eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1),
    u => nt_choose(P121FPlan,p121f_bounded(dv(d)),v => p121f_prefix(book,dv(d),dt(d),[],[],0,da(d)),v => P121FNone{}),u => P121FNone{})"""

    new_p121f_plan = """@unsafe
def w8_p121f_plan_ok(ok: Bool, +book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  match ok:
    case True{}:
      +body = j_fusion_after(dv(d),da(d))
      +r = j_call_spine(body,[])
      +m = j_call_spine(kid(r,0),[])
      nt_choose(P121FPlan,agy_str_eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
        agy_str_eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1) && p121f_bounded(dv(d)),
        v => p121f_prefix(book,dv(d),dt(d),[],[],0,da(d)),v => P121FNone{})
    case False{}: P121FNone{}

@unsafe
def p121f_plan(+book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  w8_p121f_plan_ok(U32.is_gt(da(d),0) && U32.is_le(da(d),8) && j_fusion_def(d,da(d)),book,d)"""

    src = replace_exact(src, old_p121f_plan, new_p121f_plan, "p121f_plan")

    old_p121c_admitted = """@unsafe
def p121c_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +call = j_call_spine(j_fusion_after(dv(d),2),[])
  +count = j_call_spine(kid(call,0),[])
  nt_choose(Bool,j_fusion_def(d,2) && agy_str_eq(tg(call),"Call") && U32.is_eq(terms_len(ks(call)),2) &&
    j_fusion_call(count,"U32.to_nat",1),u =>
    p121f_bounded(dv(d)) && p121c_signature(book,dt(d),2) &&
    agy_str_eq(tg(j_fusion_binder(dv(d),0)),"Lam") && agy_str_eq(tg(j_fusion_binder(dv(d),1)),"Lam") &&
    j_primitive_call(book,count) &&
    j_fusion_scalar(book,kid(count,0),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
    j_fusion_scalar(book,kid(call,1),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
    p121f_bounded(dv(lookup(book,nm(call)))) && p121c_factory(book,lookup(book,nm(call))),u => False{})"""

    new_p121c_admitted = """@unsafe
def w8_p121c_admitted_ok(ok: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match ok:
    case False{}: False{}
    case True{}:
      +call = j_call_spine(j_fusion_after(dv(d),2),[])
      +count = j_call_spine(kid(call,0),[])
      nt_choose(Bool,agy_str_eq(tg(call),"Call") && U32.is_eq(terms_len(ks(call)),2) &&
        j_fusion_call(count,"U32.to_nat",1),u =>
        p121f_bounded(dv(d)) && p121c_signature(book,dt(d),2) &&
        agy_str_eq(tg(j_fusion_binder(dv(d),0)),"Lam") && agy_str_eq(tg(j_fusion_binder(dv(d),1)),"Lam") &&
        j_primitive_call(book,count) &&
        j_fusion_scalar(book,kid(count,0),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
        j_fusion_scalar(book,kid(call,1),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
        p121f_bounded(dv(lookup(book,nm(call)))) && p121c_factory(book,lookup(book,nm(call))),u => False{})

@unsafe
def p121c_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  w8_p121c_admitted_ok(j_fusion_def(d,2),book,d)"""

    src = replace_exact(src, old_p121c_admitted, new_p121c_admitted, "p121c_admitted")

    return src


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    args = ap.parse_args()
    text = Path(args.src).read_text(encoding="utf-8")
    out = apply_patch(text)
    Path(args.dst).write_text(out, encoding="utf-8")
    print(f"apply_w8_pw_3mb: OK ({len(text)} -> {len(out)} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

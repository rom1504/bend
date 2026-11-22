#!/usr/bin/env python3
"""Wave 7C Check & Parse Optimization (`w7c_check_parse`).

Targets `check_program` (Stage 5) and `f_prefix_complete_source` (Stage 3) on
`selfhost/build/agy/wave7_unified/compiler.bend`:
  1. Stage 5 O(N^2) elimination:
     - `p143cb_resume_state`: O(1)/def `w7c_declare_cached` updates only BookCache
       [name_tree, ctor_tree] (zero `index_remove`, zero wasted list cells since
       `base_prefix_world_order` discards the tail anyway).
     - `p143cp_logged` & `p156cp_put`: preserve `ctor_tree` in BookCache and log
       all non-BookCache defs without mid-loop `p143cp_canon` or `index_remove`
       (canonicalized once at the end by `p143cp_result`).
     - `p171s_seed` & `p171s_cached`: initialize and maintain `ctor_tree` in
       `seen`'s BookCache in O(1) without `index_put_rest`/`index_remove`.
  2. Stage 5 fast direct-recursive `p177s_entry` (`subst`) with depth-512
     fallback to `p177s_loop` (eliminates state-machine frames & list reversals).
  3. Stage 3 fast `f_pattern_value` (O(1) when `begin == 0`, zero-closure
     otherwise), inlined `f_pattern_sub` (0/1/2-child fast paths, no
     `k_with_children`), and direct 1-pass `f_context_lower` (no `deferred`
     check, no `built` reversal, no `k_with_children`).
"""
from __future__ import annotations

import argparse
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise SystemExit(f"[apply_w7c_check_parse] Expected 1 occurrence for {label}, found {cnt}")
    return src.replace(old, new, 1)


def apply_patches(src: str) -> str:
    # -------------------------------------------------------------------------
    # 1. Stage 3: f_pattern_sub / f_pattern_value fast paths
    # -------------------------------------------------------------------------
    old_pat = """@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KLiteral{_, _, _, _, _}:
      t
    case KLambda{name, lid, quant, kids, rem, ob, oe, pres}:
      KLambda{name, lid, quant, f_pattern_subs(kids, id, value), rem, ob, oe, pres}
    case KTerm{tag, name, tid, quant, kids, rem, ob, oe}:
      w7_pat_sub_var(U32.is_eq(tid, id) && f_eq(tag, "Var"), t, kids, id, value)

# Module: src/front/elaborate.bend:194
@unsafe
def f_pattern_subs(+terms: List<&2,KTerm>, +id: U32, +value: KTerm) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_sub(head, id, value), f_pattern_subs(rest, id, value)}

# Module: src/front/elaborate.bend:200
@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd)}
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd), present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      f_choose(KTerm, U32.is_gt(begin, 0), u => k_with_span(t, begin, end), u => t)"""

    new_pat = """@unsafe
def w7c_pat_sub_term(hit: Bool, +tag: String, +name: String, +tid: U32, +quant: U32, +kids: List<&2,KTerm>, +rem: List<&2,String>, +ob: U32, +oe: U32, +t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match hit:
    case True{}:
      f_pattern_value(value, ob, oe)
    case False{}:
      match kids:
        case Nil{}:
          t
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Nil{}}, rem, ob, oe}
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Con{f_pattern_sub(k1, id, value), Nil{}}}, rem, ob, oe}
                case Con{_, _}:
                  KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Con{f_pattern_sub(k1, id, value), f_pattern_subs(r1, id, value)}}, rem, ob, oe}

@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KLiteral{_, _, _, _, _}:
      t
    case KLambda{name, lid, quant, kids, rem, ob, oe, pres}:
      match kids:
        case Nil{}: t
        case Con{k0, r0}:
          match r0:
            case Nil{}: KLambda{name, lid, quant, Con{f_pattern_sub(k0, id, value), Nil{}}, rem, ob, oe, pres}
            case Con{_, _}: KLambda{name, lid, quant, Con{f_pattern_sub(k0, id, value), f_pattern_subs(r0, id, value)}, rem, ob, oe, pres}
    case KTerm{tag, name, tid, quant, kids, rem, ob, oe}:
      w7c_pat_sub_term(U32.is_eq(tid, id) && f_eq(tag, "Var"), tag, name, tid, quant, kids, rem, ob, oe, t, id, value)

# Module: src/front/elaborate.bend:194
@unsafe
def f_pattern_subs(+terms: List<&2,KTerm>, +id: U32, +value: KTerm) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_sub(head, id, value), f_pattern_subs(rest, id, value)}

@unsafe
def w7c_pat_val_pos(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      match kids:
        case Nil{}: KTerm{tag, name, id, quant, Nil{}, removed, begin, end}
        case Con{_, _}: KTerm{tag, name, id, quant, w7c_pat_vals_pos(kids, begin, end), removed, begin, end}
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      match kids:
        case Nil{}: KLambda{name, id, quant, Nil{}, removed, begin, end, present}
        case Con{_, _}: KLambda{name, id, quant, w7c_pat_vals_pos(kids, begin, end), removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, begin, end}

@unsafe
def w7c_pat_vals_pos(+terms: List<&2,KTerm>, +begin: U32, +end: U32) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{w7c_pat_val_pos(head, begin, end), w7c_pat_vals_pos(rest, begin, end)}

@unsafe
def w7c_pat_val_branch(pos: Bool, +t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match pos:
    case True{}: w7c_pat_val_pos(t, begin, end)
    case False{}: t

# Module: src/front/elaborate.bend:200
@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  w7c_pat_val_branch(U32.is_gt(begin, 0), t, begin, end)"""

    src = replace_exact(src, old_pat, new_pat, "f_pattern_sub + f_pattern_value")

    # -------------------------------------------------------------------------
    # 2. Stage 3: direct 1-pass f_context_lower
    # -------------------------------------------------------------------------
    old_lower = """@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  match term:
    case KLiteral{_, _, _, _, _}:
      term
    case KLambda{_, _, _, kids, _, _, _, _}:
      match kids:
        case Nil{}: term
        case Con{_, _}: f_context_material_children(term, kids, Nil{}, True{})
    case KTerm{tag, _, _, _, kids, _, _, _}:
      match kids:
        case Nil{}: term
        case Con{_, _}: f_context_material_children(term, kids, Nil{}, True{})"""

    new_lower = """@unsafe
def w7c_lower_1_lam(stop: Bool, +name: String, +id: U32, +quant: U32, +r0: KTerm, +rem: List<&2,String>, +b: U32, +e: U32, +pres: Bool) -> KTerm:
  match stop:
    case True{}: r0
    case False{}: KLambda{name, id, quant, Con{r0, Nil{}}, rem, b, e, pres}

@unsafe
def w7c_lower_1_term(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r0
    case False{}: KTerm{tag, name, id, quant, Con{r0, Nil{}}, rem, b, e}

@unsafe
def w7c_lower_2_b(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +r1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r1
    case False{}: KTerm{tag, name, id, quant, Con{r0, Con{r1, Nil{}}}, rem, b, e}

@unsafe
def w7c_lower_2_a(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +k1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r0
    case False{}:
      +r1 = f_context_lower(k1)
      w7c_lower_2_b(f_context_stop(r1), tag, name, id, quant, r0, r1, rem, b, e)

@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  match term:
    case KLiteral{_, _, _, _, _}:
      term
    case KLambda{name, id, quant, kids, rem, b, e, pres}:
      match kids:
        case Nil{}: term
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +h0 = f_context_lower(k0)
              w7c_lower_1_lam(f_context_stop(h0), name, id, quant, h0, rem, b, e, pres)
            case Con{_, _}:
              f_context_material_children(term, kids, Nil{}, True{})
    case KTerm{tag, name, id, quant, kids, rem, b, e}:
      match kids:
        case Nil{}: term
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +h0 = f_context_lower(k0)
              w7c_lower_1_term(f_context_stop(h0), tag, name, id, quant, h0, rem, b, e)
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  +h0 = f_context_lower(k0)
                  w7c_lower_2_a(f_context_stop(h0), tag, name, id, quant, h0, k1, rem, b, e)
                case Con{_, _}:
                  f_context_material_children(term, kids, Nil{}, True{})"""

    src = replace_exact(src, old_lower, new_lower, "f_context_lower")

    # -------------------------------------------------------------------------
    # 3. Stage 5: p143cp_logged preserves ctor_tree
    # -------------------------------------------------------------------------
    old_logged = """@unsafe
def p143cp_logged(+cache: KDef, rest: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
    [index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32)],
    True{},False{}},Con{definition,rest}}"""

    new_logged = """@unsafe
def p143cp_logged(+cache: KDef, rest: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
    Con{index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32), Con{w7_book_put_ctors(cache, definition), Nil{}}},
    True{},False{}},Con{definition,rest}}"""

    src = replace_exact(src, old_logged, new_logged, "p143cp_logged")

    # -------------------------------------------------------------------------
    # 4. Stage 5: p143cb_resume_state O(1)/def w7c_declare_cached
    # -------------------------------------------------------------------------
    old_resume = """@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p156cp_start(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)"""

    new_resume = """@unsafe
def w7c_decl_def(isForeign: Bool, +d: KDef) -> KDef:
  match isForeign:
    case True{}: d
    case False{}: declared(d)

@unsafe
def w7c_ctor_add_if_adt(isAdt: Bool, +d: KDef, +ctors: KDef) -> KDef:
  match isAdt:
    case True{}: w7_ctor_index_add(dc(d), ctors)
    case False{}: ctors

@unsafe
def w7c_declare_loop(+todo: List<&2,KDef>, +names: KDef, +ctors: KDef) -> List<&2,KDef>:
  match todo:
    case Nil{}: Con{names, Con{ctors, Nil{}}}
    case Con{d, rest}:
      +d2 = w7c_decl_def(p98_tag_eq(dv(d), "Foreign"), d)
      w7c_declare_loop(rest, index_set(names, d2, index_hash(dn(d2), 2166136261), 32), w7c_ctor_add_if_adt(p88_string_eq(dk(d2), "ADT"), d2, ctors))

@unsafe
def w7c_init_ctors(+dc_list: List<&2,KDef>, +rows: List<&2,KDef>) -> KDef:
  match dc_list:
    case Nil{}: w7_ctor_index_build(rows)
    case Con{_, tail}:
      match tail:
        case Nil{}: w7_ctor_index_build(rows)
        case Con{ctors, _}: ctors

@unsafe
def w7c_declare_head(isCache: Bool, +todo: List<&2,KDef>, +cache: KDef, +rows: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match isCache:
    case True{}:
      Con{KDef{dn(cache), dk(cache), da(cache), 0,
        {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm}, {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
        w7c_declare_loop(todo, index_first(dc(cache)), w7c_init_ctors(dc(cache), rows)),
        True{}, False{}}, rows}
    case False{}:
      check_declarations(todo, done)

@unsafe
def w7c_declare_cached(+todo: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match done:
    case Nil{}: check_declarations(todo, done)
    case Con{cache, rows}:
      w7c_declare_head(p88_string_eq(dk(cache), "BookCache"), todo, cache, rows, done)

@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = w7c_declare_cached(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p156cp_start(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)"""

    src = replace_exact(src, old_resume, new_resume, "p143cb_resume_state")

    # -------------------------------------------------------------------------
    # 5. Stage 5: p156cp_put logs ALL non-BookCache defs (no mid-loop canon/remove)
    # -------------------------------------------------------------------------
    old_p156_put = """@unsafe
def p156cp_put(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match book:
    case Nil{}: p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),False{})
    case Con{+cache,+tail}:
      nt_choose(DChecking,p88_string_eq(dk(cache),"BookCache") &&
        p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
        u => p156cp_stored(rest,seen,definition,term,world,p143cp_logged(cache,tail,definition),True{}),
        u => p156cp_stored(rest,seen,definition,term,world,
          book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{}))"""

    new_p156_put = """@unsafe
def w7c_p156cp_put_cached(canLog: Bool, +rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +cache: KDef, +tail: List<&2,KDef>, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match canLog:
    case True{}:
      p156cp_stored(rest,seen,definition,term,world,p143cp_logged(cache,tail,definition),True{})
    case False{}:
      p156cp_stored(rest,seen,definition,term,world,
        book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{})

@unsafe
def p156cp_put(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match book:
    case Nil{}: p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),False{})
    case Con{+cache,+tail}:
      w7c_p156cp_put_cached(p88_string_eq(dk(cache),"BookCache") && Bool.not(p88_string_eq(dk(definition),"BookCache")),
        rest,seen,definition,term,world,cache,tail,book,dirty)"""

    src = replace_exact(src, old_p156_put, new_p156_put, "p156cp_put")

    # -------------------------------------------------------------------------
    # 6. Stage 5: p171s_seed & p171s_cached O(1) ctor_tree, zero index_remove
    # -------------------------------------------------------------------------
    old_p171s = """@unsafe
def p171s_seed(seen):
  match seen:
    case Nil{}: seen
    case Con{+cache,tail}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{cache,p171s_constructor_rows(tail)},u => seen)

@unsafe
def p171s_cached(+cache: KDef, +rows: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  +rest = index_put_rest(cache,rows,dn(definition))
  Con{KDef{dn(cache),dk(cache),da(cache),0,atom("Absent"),atom("Absent"),
    [index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32)],True{},False{}},
    nt_choose(List<&2,KDef>,defs_empty(dc(definition)),u => rest,u => Con{definition,rest})}

@unsafe
def p171s_put(seen,definition):
  match seen:
    case Nil{}: book_put(seen,definition)
    case Con{+cache,+rows}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => p171s_cached(cache,rows,definition),u => book_put(seen,definition))"""

    new_p171s = """@unsafe
def w7c_p171s_seed_step(isCache: Bool, +cache: KDef, +tail: List<&2,KDef>, +seen: List<&2,KDef>) -> List<&2,KDef>:
  match isCache:
    case True{}:
      +ctor_rows = p171s_constructor_rows(tail)
      Con{KDef{dn(cache),dk(cache),da(cache),0,
        {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
        Con{index_first(dc(cache)), Con{w7_ctor_index_build(ctor_rows), Nil{}}},True{},False{}}, ctor_rows}
    case False{}:
      seen

@unsafe
def p171s_seed(seen):
  match seen:
    case Nil{}: seen
    case Con{+cache,tail}:
      w7c_p171s_seed_step(p88_string_eq(dk(cache),"BookCache"), cache, tail, seen)

@unsafe
def p171s_cached(+cache: KDef, +rows: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
    Con{index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32), Con{w7_book_put_ctors(cache, definition), Nil{}}},True{},False{}},
    rows}

@unsafe
def w7c_p171s_put_step(isCache: Bool, +cache: KDef, +rows: List<&2,KDef>, +seen: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  match isCache:
    case True{}: p171s_cached(cache, rows, definition)
    case False{}: book_put(seen, definition)

@unsafe
def p171s_put(seen,definition):
  match seen:
    case Nil{}: book_put(seen,definition)
    case Con{+cache,+rows}:
      w7c_p171s_put_step(p88_string_eq(dk(cache),"BookCache"), cache, rows, seen, definition)"""

    src = replace_exact(src, old_p171s, new_p171s, "p171s_seed + p171s_cached + p171s_put")

    # -------------------------------------------------------------------------
    # 7. Stage 5: fast direct-recursive p177s_entry with depth-512 fallback
    # -------------------------------------------------------------------------
    old_p177s = """@unsafe
def p177s_entry(t,id,value):
  p177s_loop(0,t,Nil{},id,value,Nil{})"""

    new_p177s = """law w7c_subst:
  for +t: KTerm
  for +id: U32
  for +value: KTerm
  for +depth: U32
  KTerm

@unsafe
def w7c_subst_list(+ts: List<&2,KTerm>, +id: U32, +value: KTerm, +depth: U32) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{w7c_subst(h, id, value, depth), w7c_subst_list(rest, id, value, depth)}

@unsafe
def w7c_subst_beta(isLam: Bool, +r0: KTerm, +r1: KTerm, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isLam:
    case True{}:
      w7c_subst(kid(r0, 0), ix(r0), r1, depth)
    case False{}:
      KTerm{"App", "", 0, 0, Con{r0, Con{r1, Nil{}}}, Nil{}, b, e}

@unsafe
def w7c_subst_app2(isApp: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +r0: KTerm, +r1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(r0, "Lam"), r0, r1, b, e, depth)
    case False{}:
      KTerm{tag, name, n, quant, Con{r0, Con{r1, Nil{}}}, rem, b, e}

@unsafe
def w7c_subst_app_gen(isApp: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +rkids: List<&2,KTerm>, +rem: List<&2,String>, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(terms_at(rkids, 0), "Lam"), terms_at(rkids, 0), terms_at(rkids, 1), b, e, depth)
    case False{}:
      KTerm{tag, name, n, quant, rkids, rem, b, e}

@unsafe
def w7c_subst_app_nil(isApp: Bool, +t: KTerm, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(terms_at(Nil{}, 0), "Lam"), terms_at(Nil{}, 0), terms_at(Nil{}, 1), b, e, depth)
    case False{}:
      t

@unsafe
def w7c_subst_var(isVar: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +kids: List<&2,KTerm>, +rem: List<&2,String>, +b: U32, +e: U32, +t: KTerm, +id: U32, +value: KTerm, +d1: U32) -> KTerm:
  match isVar:
    case True{}:
      value
    case False{}:
      match kids:
        case Nil{}:
          w7c_subst_app_nil(p88_string_eq(tag, "App"), t, b, e, d1)
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +s0 = w7c_subst(k0, id, value, d1)
              w7c_subst_app_gen(p88_string_eq(tag, "App"), tag, name, n, quant, Con{s0, Nil{}}, rem, b, e, d1)
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  +s0 = w7c_subst(k0, id, value, d1)
                  +s1 = w7c_subst(k1, id, value, d1)
                  w7c_subst_app2(p88_string_eq(tag, "App"), tag, name, n, quant, s0, s1, rem, b, e, d1)
                case Con{_, _}:
                  +s0 = w7c_subst(k0, id, value, d1)
                  +s1 = w7c_subst(k1, id, value, d1)
                  w7c_subst_app_gen(p88_string_eq(tag, "App"), tag, name, n, quant, Con{s0, Con{s1, w7c_subst_list(r1, id, value, d1)}}, rem, b, e, d1)

@unsafe
def w7c_subst_go(deep: Bool, +t: KTerm, +id: U32, +value: KTerm, +d1: U32) -> KTerm:
  match deep:
    case True{}:
      p177s_loop(0, t, Nil{}, id, value, Nil{})
    case False{}:
      match t:
        case KLiteral{_, _, _, _, _}:
          t
        case KLambda{name, n, quant, kids, rem, b, e, pres}:
          match kids:
            case Nil{}: t
            case Con{k0, r0}:
              match r0:
                case Nil{}: KLambda{name, n, quant, Con{w7c_subst(k0, id, value, d1), Nil{}}, rem, b, e, pres}
                case Con{_, _}: KLambda{name, n, quant, Con{w7c_subst(k0, id, value, d1), w7c_subst_list(r0, id, value, d1)}, rem, b, e, pres}
        case KTerm{tag, name, n, quant, kids, rem, b, e}:
          w7c_subst_var(U32.is_eq(n, id) && p88_string_eq(tag, "Var"), tag, name, n, quant, kids, rem, b, e, t, id, value, d1)

@unsafe
def w7c_subst(t, id, value, depth):
  w7c_subst_go(U32.is_ge(depth, 512), t, id, value, U32.add(depth, 1))

@unsafe
def p177s_entry(t,id,value):
  w7c_subst(t,id,value,0)"""

    src = replace_exact(src, old_p177s, new_p177s, "p177s_entry")

    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    src = args.src.read_text()
    out = apply_patches(src)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"[apply_w7c_check_parse] wrote {args.dst} ({len(out):,} bytes, delta {len(out) - len(src):+,} bytes)")


if __name__ == "__main__":
    main()

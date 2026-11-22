#!/usr/bin/env python3
"""Patch wave7_unified/compiler.bend to optimize nr_prepare_annotated / p144o_prepare_annotated:
1. O(1) hash-trie membership (`p142j_member`) for owned constructors in `p144o_owned_context`
   and `p144o_constructors` instead of O(C) `nb_contains` linked-list scans on every Ctr/Mat.
2. Zero-allocation recursive `norm_max_book` (`w7c_norm_max_defs` / `w7c_norm_max_term`)
   eliminating millions of temporary `norm_join` / `norm_defs_join` Cons allocations.
3. Eliminate redundant `lookup(book, name)` + `nc_native_def`/`nc_foreign` checks in
   `p143nr_visit` and fuse `nc_refs` + `nt_append` into `w7c_refs_push`.
"""
import argparse
from pathlib import Path

OLD_NORM_MAX_BOOK = """@unsafe
def norm_max_book(book):
  norm_max_defs(book, 0)"""

NEW_NORM_MAX_BOOK = """@unsafe
def w7c_norm_max_terms(ts: List<&2, KTerm>, +bound: U32) -> U32:
  match ts:
    case Nil{}: bound
    case Con{h, rest}:
      w7c_norm_max_terms(rest, w7c_norm_max_term(h, bound))

@unsafe
def w7c_norm_max_term(+t: KTerm, +bound: U32) -> U32:
  w7c_norm_max_terms(ks(t), U32.max(bound, ix(t)))

@unsafe
def w7c_norm_max_defs(ds: List<&2, KDef>, +bound: U32) -> U32:
  match ds:
    case Nil{}: bound
    case Con{+h, rest}:
      +b1 = w7c_norm_max_term(dt(h), bound)
      +b2 = w7c_norm_max_term(dv(h), b1)
      +b3 = w7c_norm_max_defs(dc(h), b2)
      w7c_norm_max_defs(rest, b3)

@unsafe
def norm_max_book(book):
  w7c_norm_max_defs(book, 0)"""

OLD_P143NR_VISIT = """@unsafe
def p143nr_visit(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book,d,0)
  +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name,"NativeErasedBody",nd_arity_plain(book,name),1,{KTerm{"Absent","",0,0,[],[],0,0}:KTerm},body,[],False{},False{}},facts},u => facts)
  p143nr_walk(book,nt_append(String,nc_refs(body),todo),Con{name,done},more,seen)"""

NEW_P143NR_VISIT = """@unsafe
def w7c_refs_list(ts: List<&2, KTerm>, +acc: List<&2, String>) -> List<&2, String>:
  match ts:
    case Nil{}: acc
    case Con{h, rest}: w7c_refs_list(rest, w7c_refs_term(h, acc))

@unsafe
def w7c_refs_term(+t: KTerm, +acc: List<&2, String>) -> List<&2, String>:
  +acc1 = nt_choose(List<&2, String>, p98_tag_eq(t, "Ref"), u => Con{nm(t), acc}, u => acc)
  w7c_refs_list(ks(t), acc1)

@unsafe
def p143nr_visit(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book,d,0)
  +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name,"NativeErasedBody",U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d))),1,{KTerm{"Absent","",0,0,[],[],0,0}:KTerm},body,[],False{},False{}},facts},u => facts)
  p143nr_walk(book,nt_reverse(String,w7c_refs_term(body,Nil{}),todo),Con{name,done},more,seen)"""

OLD_P144O_BLOCK = """@unsafe
def p144o_specs(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      Con{N_Constructor{p144o_identity(book,facts,dn(child)),nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        p144o_specs(book,rest,params,facts)}


@unsafe
def p144o_constructors(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,p144o_specs(book,dc(definition),da(definition),facts),p144o_constructors(book,rest,facts)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},p144o_constructors(book,rest,facts)},
          v => p144o_constructors(book,rest,facts)))

@unsafe
def p144o_term(term: KTerm) -> P144OFacts:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(P144OFacts,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => P144OFacts{names,True{}},u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_payload(context: KDef) -> P144OFacts:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(P144OFacts,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_term(typ),u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_ctor_carrier(+context: KDef, facts: P144OFacts) -> KDef:
  match context facts:
    case KDef{+name,+kind,+arity,+templates,+typ,+value,+children,+native,+uns} P144OFacts{+names,valid}:
      nt_choose(KDef,valid && p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns) && p98_tag_eq(typ,"Absent"),
        u => KDef{name,kind,arity,templates,KTerm{"P144Ownership","",0,1,[],names,0,0},value,children,native,uns},
        u => context)
    case _ _: context


@unsafe
def p144o_view(+book: List<&2,KDef>, +facts: P144OFacts) -> List<&2,KDef>:
  match book:
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
          [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,
            KTerm{"NativeImage","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
            [missing(),p144o_ctor_carrier(nc_ctor_prepare(book),facts)],False{},False{}}],db(cache),du(cache)},rest},
        u => book)
    case Nil{}: []


@unsafe
def p144o_owned(+book: List<&2,KDef>, name: String) -> Bool:
  p144o_owned_context(book,name,nc_ctor_context(book))

# The hot query returns Bool directly: no intermediate P144OFacts result box.

@unsafe
def p144o_owned_context(+book: List<&2,KDef>, +query: String, context: KDef) -> Bool:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(Bool,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_owned_term(book,query,typ),u => p144o_original(book,query))
    case _: p144o_original(book,query)"""

NEW_P144O_BLOCK = """@unsafe
def w7c_p144o_specs_set(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +owned_set: KDef) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      +cname = dn(child)
      +ident = nt_choose(String,p142j_member(owned_set,cname,index_hash(cname,2166136261)),u => cname,u => nc_ctor_encode(cname))
      Con{N_Constructor{ident,nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        w7c_p144o_specs_set(book,rest,params,owned_set)}

@unsafe
def w7c_p144o_constructors_set(+book: List<&2,KDef>, definitions: List<&2,KDef>, +owned_set: KDef) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,w7c_p144o_specs_set(book,dc(definition),da(definition),owned_set),w7c_p144o_constructors_set(book,rest,owned_set)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},w7c_p144o_constructors_set(book,rest,owned_set)},
          v => w7c_p144o_constructors_set(book,rest,owned_set)))

@unsafe
def p144o_specs(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      Con{N_Constructor{p144o_identity(book,facts,dn(child)),nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        p144o_specs(book,rest,params,facts)}


@unsafe
def p144o_constructors(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match facts:
    case P144OFacts{+names,valid}:
      match valid:
        case True{}: w7c_p144o_constructors_set(book,definitions,p142j_members(names,missing()))
        case False{}: p144o_constructors_fallback(book,definitions,facts)

@unsafe
def p144o_constructors_fallback(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,p144o_specs(book,dc(definition),da(definition),facts),p144o_constructors_fallback(book,rest,facts)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},p144o_constructors_fallback(book,rest,facts)},
          v => p144o_constructors_fallback(book,rest,facts)))

@unsafe
def p144o_term(term: KTerm) -> P144OFacts:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(P144OFacts,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => P144OFacts{names,True{}},u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_payload(context: KDef) -> P144OFacts:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(P144OFacts,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_term(typ),u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_ctor_carrier(+context: KDef, facts: P144OFacts) -> KDef:
  match context facts:
    case KDef{+name,+kind,+arity,+templates,+typ,+value,+children,+native,+uns} P144OFacts{+names,valid}:
      nt_choose(KDef,valid && p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns) && p98_tag_eq(typ,"Absent"),
        u => KDef{name,kind,arity,templates,KTerm{"P144Ownership","",0,1,[],names,0,0},value,
          Con{index_first(children),Con{p142j_members(names,missing()),Nil{}}},native,uns},
        u => context)
    case _ _: context


@unsafe
def p144o_view(+book: List<&2,KDef>, +facts: P144OFacts) -> List<&2,KDef>:
  match book:
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
          [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,
            KTerm{"NativeImage","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
            [missing(),p144o_ctor_carrier(nc_ctor_prepare(book),facts)],False{},False{}}],db(cache),du(cache)},rest},
        u => book)
    case Nil{}: []


@unsafe
def p144o_owned(+book: List<&2,KDef>, name: String) -> Bool:
  p144o_owned_context(book,name,nc_ctor_context(book))

# The hot query returns Bool directly via O(1) hash-trie membership when attached.

@unsafe
def w7c_p144o_owned_children(+book: List<&2,KDef>, +query: String, +typ: KTerm, children: List<&2,KDef>) -> Bool:
  match children:
    case Con{_, Con{owned_set, _}}:
      nt_choose(Bool,p98_tag_eq(typ,"P144Ownership"),
        u => p142j_member(owned_set,query,index_hash(query,2166136261)),
        u => p144o_owned_term(book,query,typ))
    case _: p144o_owned_term(book,query,typ)

@unsafe
def p144o_owned_context(+book: List<&2,KDef>, +query: String, context: KDef) -> Bool:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(Bool,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => w7c_p144o_owned_children(book,query,typ,children),u => p144o_original(book,query))
    case _: p144o_original(book,query)"""


def apply_patch(src_text: str) -> str:
    replacements = [
        ("norm_max_book", OLD_NORM_MAX_BOOK, NEW_NORM_MAX_BOOK),
        ("p143nr_visit", OLD_P143NR_VISIT, NEW_P143NR_VISIT),
        ("p144o_block", OLD_P144O_BLOCK, NEW_P144O_BLOCK),
    ]
    out = src_text
    for label, old, new in replacements:
        count = out.count(old)
        if count != 1:
            raise SystemExit(f"ERROR: expected 1 occurrence of {label}, found {count}")
        out = out.replace(old, new, 1)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    args = ap.parse_args()
    src_path = Path(args.src)
    dst_path = Path(args.dst)
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    patched = apply_patch(src_path.read_text(encoding="utf-8"))
    dst_path.write_text(patched, encoding="utf-8")
    print(f"w7c_nr_prepare: patched {src_path} -> {dst_path} ({len(patched)} bytes)")


if __name__ == "__main__":
    main()

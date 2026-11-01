# Phase152 experimental overlay. Replace only nbc_definition and p113_value_kind.
# Original source admission runs before prepared facts are inspected. The only
# accepted body difference is nullary Ctr -> authenticated packed NStatic.
# No selector/name recognizer, raw marker admission, new IR, or verifier bypass.
@unsafe
def p152c_nullary(+constructors: KDef, +term: KTerm) -> Bool:
  p98_tag_eq(term,"NStatic") && U32.is_eq(qt(term),1) && U32.is_eq(ix(term),0) &&
    List.is_empty(&2,KTerm,ks(term)) && p112s_constructor_ok(constructors,nm(term),0)

@unsafe
def p152c_immediate(+book: List<&2,KDef>, +term: KTerm) -> Bool:
  p98_tag_eq(dt(ns_context(book)),"P112StaticImage") && p152c_nullary(p112s_context_ctors(book),term)

@unsafe
def p152c_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: String.eq(x,y) && p152c_strings(xs,ys)
    case _ _: False{}

def p152c_variant(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KLambda{a0,a1,a2,a3,a4,a5,a6,a7} KLambda{b0,b1,b2,b3,b4,b5,b6,b7}: Bool.not(Bool.xor(a7,b7))
    case _ _: False{}

@unsafe
def p152c_pair(+constructors: KDef, +source: KTerm, +prepared: KTerm) -> Bool:
  nt_choose(Bool,p98_tag_eq(prepared,"NStatic"),
    u => p98_tag_eq(source,"Ctr") && String.eq(nm(source),nm(prepared)) &&
      List.is_empty(&2,KTerm,ks(source)) && p152c_nullary(constructors,prepared),
    u => p152c_variant(source,prepared) && String.eq(tg(source),tg(prepared)) &&
      String.eq(nm(source),nm(prepared)) && U32.is_eq(ix(source),ix(prepared)) &&
      U32.is_eq(qt(source),qt(prepared)) && U32.is_eq(kb(source),kb(prepared)) &&
      U32.is_eq(ke(source),ke(prepared)) && p152c_strings(rm(source),rm(prepared)) &&
      p152c_pairs(constructors,ks(source),ks(prepared)))

@unsafe
def p152c_pairs(+constructors: KDef, a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p152c_pair(constructors,x,y) && p152c_pairs(constructors,xs,ys)
    case _ _: False{}

# Same-name freshly prepared fact with its retained erased source. A bounded
# correspondence check rejects stale substitutions, fields, boxes and scalars.
# Actual factory preparation already blocked effects before producing markers.
@unsafe
def p152c_fact(+book: List<&2,KDef>, +name: String, +source: KTerm, +fact: KDef) -> KTerm:
  +prior = index_first(dc(fact))
  nt_choose(KTerm,p98_tag_eq(dt(ns_context(book)),"P112StaticImage") &&
    String.eq(dk(fact),"NativeStaticBody") && String.eq(dn(fact),name) &&
    String.eq(dk(prior),"NativeErasedBody") && String.eq(dn(prior),name) &&
    U32.is_gt(nq_layout_remaining([dv(fact)],33),0),
    u => nt_choose(KTerm,p152c_pair(p112s_context_ctors(book),source,dv(fact)),
      v => dv(fact),v => source),u => source)

# These are the incumbent nbc_select gates, applied to the original compact
# body. The leaf-only substitution changes neither binders nor evaluation order.
@unsafe
def p152c_select(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0),u =>
    nt_choose(KTerm,nbc_closed(body,[]) && nbc_match_list([body]),u =>
      nt_choose(KTerm,nbc_applicable(body,args),u =>
        nt_choose(KTerm,nd_comb_fresh(body,args,env,n,64),
          u => nbc_filled(f_fresh_term(p152c_fact(book,name,body,ns_body(book,name)),[],nc_id(U32.add(n,63))),args,n),
          u => atom("Absent")),u => atom("Absent")),u => atom("Absent")),u => atom("Absent"))

@unsafe
def p152c_source(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0) && nbc_closed(body,[]),
    u => p152c_select(book,name,nc_compact(body),args,env,n,count),u => atom("Absent"))

@unsafe
def nbc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => p152c_source(book,dn(d),nc_source_body(book,d,n),args,env,n,count),u => atom("Absent"))

# Preserve the exact previous classifier on every other case. N_Imm64 retains
# the constructor tag in the full U64 word; N_W32 would truncate that tag.
@unsafe
def p152c_prior_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"Ctr") || p98_tag_eq(value,"NCtr"),
    u => nt_choose(N_WordKind,p113n_constructor(book,nm(value),terms_len(ks(value))),v => N_Imm64{},v => p113n_original_value_kind(book,value,env)),
    u => p113n_original_value_kind(book,value,env))

@unsafe
def p113_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"NStatic"),
    u => nt_choose(N_WordKind,p152c_immediate(book,value),v => N_Imm64{},v => p152c_prior_kind(book,value,env)),
    u => p152c_prior_kind(book,value,env))

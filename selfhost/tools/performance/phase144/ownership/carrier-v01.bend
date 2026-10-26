# A private request-local carrier, not authority for arbitrary forged books.
# Only the previously-Absent NativeCtorIndex type field is populated. Existing
# first constructor-index child and all lookup/type-normalization facts remain.
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
    case _: p144o_original(book,query)

@unsafe
def p144o_owned_term(+book: List<&2,KDef>, +query: String, term: KTerm) -> Bool:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(Bool,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => nb_contains(names,query),u => p144o_original(book,query))
    case _: p144o_original(book,query)

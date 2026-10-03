
# Count every copied callee body at every call occurrence, rather than unique
# graph nodes. Fuel bounds total inline expansion and refuses before emission.
@unsafe
def j_direct_expand_def(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && Bool.not(has_name(active, dn(d))), u =>
    kc(Maybe<&2,U32>, db(d), u => Some{U32.sub(fuel, 1)},
      u => j_direct_expand_term(book, dv(d), Con{dn(d), active}, U32.sub(fuel, 1))), u => None{})

@unsafe
def j_direct_expand_term(+book: List<&2,KDef>, +t: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +spine = j_call_spine(t, Nil{})
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    kc(Maybe<&2,U32>, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") &&
      String.eq(dk(d), "Def") && U32.is_gt(da(d), 0) &&
      Bool.not(j_primitive_call(book, spine)) && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
      j_direct_expand_after(book, d, active,
        j_direct_expand_terms(book, ks(spine), active, U32.sub(fuel, 1))),
      u => j_direct_expand_terms(book, ks(t), active, U32.sub(fuel, 1))), u => None{})

@unsafe
def j_direct_expand_terms(+book: List<&2,KDef>, +ts: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match ts:
    case Nil{}: Some{fuel}
    case Con{t, rest}: j_direct_expand_more(book, rest, active, j_direct_expand_term(book, t, active, fuel))

@unsafe
def j_direct_expand_more(+book: List<&2,KDef>, +ts: List<&2,KTerm>, +active: List<&2,String>, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{fuel}: j_direct_expand_terms(book, ts, active, fuel)

@unsafe
def j_direct_expand_after(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{fuel}: j_direct_expand_def(book, d, active, fuel)

# Replace ONLY p156cp_put. A cached dirty tail contains obsolete childless
# definitions, never obsolete constructor-bearing owners. Ordinary book_put
# removes all rows for the updated owner before prepending its replacement.
# Keep the dirty bit for remaining unrelated childless rows; the existing
# p143cp_result still canonicalizes every outward success/failure world.
@unsafe
def p156cp_put(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match book:
    case Nil{}: p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),False{})
    case Con{+cache,+tail}:
      nt_choose(DChecking,p88_string_eq(dk(cache),"BookCache") &&
        p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
        u => p156cp_stored(rest,seen,definition,term,world,p143cp_logged(cache,tail,definition),True{}),
        u => nt_choose(DChecking,dirty && p88_string_eq(dk(cache),"BookCache") && Bool.not(p88_string_eq(dk(definition),"BookCache")),
          u => p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),True{}),
          u => p156cp_stored(rest,seen,definition,term,world,
            book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{})))

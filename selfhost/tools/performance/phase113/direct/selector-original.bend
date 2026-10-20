# Exact original direct saturated-call fallback, renamed only.
@unsafe
def p113db_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("direct: partial or bang call",n),
    u => p113d_lower(book,nc_sequence("NCall",p113d_public(book,nm(head)),args,[],n),env,owner,target,U32.add(n,terms_len(args))))

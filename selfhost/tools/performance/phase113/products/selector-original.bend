# Exact product baseline declaration, renamed for optional delegation.
@unsafe
def p113pb_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("product partial or bang call",n),
    u => p113pl_lower(book,nc_sequence("NPCall",nm(head),args,[],n),env,target,U32.add(n,terms_len(args))))


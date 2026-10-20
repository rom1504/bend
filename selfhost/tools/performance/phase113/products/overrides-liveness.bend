@unsafe
def p113pl_lower(book,t,env,target,n):
  nt_choose(P113DCode,String.eq(tg(t),"Let") || String.eq(tg(t),"NSeqLet"),
    u => p113px_lower(book,p112_liveness_terms(ks(t)),env,target,n),
    u => p113px_other(book,t,env,target,n))

@unsafe
def p113pl_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_live(book,p112_liveness_terms(terms),env,target,n)

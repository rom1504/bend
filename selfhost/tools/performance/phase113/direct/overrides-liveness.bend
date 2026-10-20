@unsafe
def p113d_lower(book,t,env,owner,target,n):
  nt_choose(P113DCode,String.eq(tg(t),"Let") || String.eq(tg(t),"NSeqLet"),
    u => p113dl_lower(book,p112_liveness_terms(ks(t)),env,owner,target,n),
    u => p113dl_other(book,t,env,owner,target,n))

@unsafe
def p113d_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_live(book,p112_liveness_terms(terms),env,owner,target,n)

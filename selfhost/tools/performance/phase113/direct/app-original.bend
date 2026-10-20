# Exact diagnostic scalar application fallback, renamed only.
@unsafe
def p113da_original_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,Bool.not(String.is_empty(prim)),
    u => p113d_lower(book,nc_sequence("NOp",prim,args,[],n),env,owner,target,U32.add(n,terms_len(args))),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Lam"),u => p113d_lower(book,nd_beta(head,args),env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nd_match_vars(args),
      v => p113d_lower(book,nd_match_sequence(head,args,[],n),env,owner,target,U32.add(n,terms_len(args))),
      v => p113d_fail("direct: higher-order matcher",n)),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Ref"),u => p113d_ref_app(book,head,args,env,owner,target,n),
    u => p113d_fail("direct: dynamic call head=" ++ tg(head) ++ ":" ++ nm(head),n)))))

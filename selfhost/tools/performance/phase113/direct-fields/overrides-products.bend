# Exact product baseline declaration, renamed for optional delegation.
@unsafe
def p113pm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word: N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113pl_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),target,U32.add(n,count))
  +no = p113pl_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,target,p113d_fresh(yes))
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt") || nw_applicable(mat),
    u => p113d_fail("product effect or specialized Word match",n),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p111_take(nm(mat),word,count,n),yes),no)))


@unsafe
def p113pl_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  nt_choose(P113DCode,String.eq(tg(arg),"NQBundle"),
    u => nt_choose(P113DCode,String.eq(nm(mat),nm(arg)) && U32.is_eq(ix(mat),U32.inc(terms_len(ks(arg)))),
      v => p113pl_lower(book,nd_reapply(kid(mat,0),nt_append(KTerm,ks(arg),nd_match_rest(t))),
        nt_append(NC_Binding,nq_remove_fields(env,ks(arg)),p113df_bundle_env(mat,arg,env)),target,n),
      v => p113pl_lower(book,nc_mklet(nc_id(n),kt("NQBox",nm(arg),0,0,ks(arg)),
        kt("NMatch","",0,0,Con{mat,Con{var("",nc_id(n)),nd_match_rest(t)}})),env,target,U32.inc(n))),
    u => p113pl_match_boxed(book,t,env,target,n))


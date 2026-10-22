# Exact parent fallbacks, with only declaration names changed.
@unsafe
def p126ci_old_generic(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word : N111Value = N111Local{nc_word(ix(arg), env)}
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = p111_lower(book, nd_reapply(nc_field_apps(kid(mat, 0), count, 0, n), nd_match_rest(t)), nt_append(NC_Binding, nc_remove_env(env, ix(arg)), p111_field_env(count, 0, n)), U32.add(n, count))
  +miss = p111_lower(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, p111_fresh(hit))
  +branch = nt_append(N111Stmt, p111_test(nm(mat), word), [N111If{N111Local{"match_condition"}, nt_append(N111Stmt, p111_take(nm(mat), word, count, n), p111_body(hit)), p111_body(miss)}])
  P111Code{p111_guard_io(nm(mat), word, branch), nt_append(N111Segment, p111_segments(hit), p111_segments(miss)), p111_fresh(miss), p111_first(p111_error(hit), p111_error(miss))}

@unsafe
def p126ci_old_product(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
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
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),no)))

@unsafe
def p126ci_generic_hit(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +hit = p111_lower(book,arg,env,n)
  +miss = p111_lower(book,app(kid(mat,1),arg),env,p111_fresh(hit))
  +branch = nt_append(N111Stmt,p111_test(nm(mat),word),[N111If{N111Local{"match_condition"},p111_body(hit),p111_body(miss)}])
  P111Code{branch,nt_append(N111Segment,p111_segments(hit),p111_segments(miss)),p111_fresh(miss),p111_first(p111_error(hit),p111_error(miss))}

@unsafe
def p112m_original_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,p126ci_match(book,t),u => p126ci_generic_hit(book,t,env,n),u => p126ci_old_generic(book,t,env,n))

@unsafe
def p126ci_product_hit(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +hit = p113pl_lower(book,arg,env,target,n)
  +miss = p113pl_lower(book,app(kid(mat,1),arg),env,target,p113d_fresh(hit))
  p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},hit,miss))

@unsafe
def p113pm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,Bool.not(p113p_known(p113pl_shape(target))) && p126ci_match(book,t),
    u => p126ci_product_hit(book,t,env,target,n),u => p126ci_old_product(book,t,env,target,n))

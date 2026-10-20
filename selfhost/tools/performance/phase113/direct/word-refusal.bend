# Exact first scalar match, renamed only for conservative delegation.
@unsafe
def p113dm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p111_field_env(count,0,n)),owner,target,U32.add(n,count))
  +no = p113d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p113d_fresh(yes))
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt"),
    u => p113d_fail("direct: effect match",n),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p111_take(nm(mat),word,count,n),yes),no)))

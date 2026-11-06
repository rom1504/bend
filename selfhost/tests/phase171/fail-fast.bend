# Experimental candidate-only failure propagation. Successful lowering is unchanged.
# Failed partial body/calls/fresh are intentionally not an inspection API oracle.
# Preserve candidate names, signatures, count and order for p126sc prefilter metadata.

@unsafe
def p113d_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113d_lower(book,body,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first)))),u => first)

@unsafe
def p113dl_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113dl_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first)))),u => first)

@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,nc_uses(body)),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_env(env,body),params),target,p113d_fresh(first)))),u => first)

@unsafe
def p113pl_bind_boxed(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113pl_lower(book,body,nt_append(NC_Binding,nc_live_uses(env,uses),[p113_binding(book,id,value,env)]),target,p113d_fresh(first)))),u => first)

@unsafe
def p113px_boxed(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113px_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),target,p113d_fresh(first)))),u => first)

@unsafe
def p113dm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113dm_join(row,base,yes,p113dm_rows(book,rows,env,owner,target,base,p113d_fresh(yes))),u => yes)

@unsafe
def p113pm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113pm_join(row,base,yes,p113pm_rows(book,rows,env,target,base,p113d_fresh(yes))),u => yes)

@unsafe
def p113dm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt"),
    u => p113d_fail("direct: effect match",n),
    u => p171ff_direct_match(book,t,env,owner,target,n,mat))

@unsafe
def p113pm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt") || nw_applicable(mat),
    u => p113d_fail("product effect or specialized Word match",n),
    u => p171ff_product_match(book,t,env,target,n,mat))

@unsafe
def p171ff_direct_match(book,t,env,owner,target,n,mat):
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),owner,target,U32.add(n,count))
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),p113d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p113d_fresh(yes)))),u => yes)

@unsafe
def p171ff_product_match(book,t,env,target,n,mat):
  +arg = kid(t,1)
  +word: N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113pl_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),target,U32.add(n,count))
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),p113pl_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,target,p113d_fresh(yes)))),u => yes)

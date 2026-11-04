# Isolated Phase156 override: replace exactly p113pl_bind_flat.
@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  +uses = nt_choose(NU_Set,List.is_empty(&2,NC_Binding,env),u => NU_Empty{},u => nc_uses(body))
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_uses(env,uses),params),target,p113d_fresh(first))))

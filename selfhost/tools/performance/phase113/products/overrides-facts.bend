# Optional companion to the separately admitted Phase113 checked facts layer.
@unsafe
def p113pl_bind_boxed(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],atom("Absent")),n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113pl_lower(book,body,nt_append(NC_Binding,nc_live_uses(env,uses),[p113_binding(book,id,value,env)]),target,p113d_fresh(first))))

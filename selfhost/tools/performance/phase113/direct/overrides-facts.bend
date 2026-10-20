# Optional checked result facts; all other ownership/destination code is exact.
@unsafe
def p113d_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113d_lower(book,body,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first))))

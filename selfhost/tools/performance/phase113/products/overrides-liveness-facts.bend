# Optional exact boxed-liveness consumer with checked result-kind facts.
@unsafe
def p113px_boxed(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],atom("Absent")),n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113px_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),target,p113d_fresh(first))))

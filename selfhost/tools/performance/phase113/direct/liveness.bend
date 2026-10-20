# Optional compile-cost adapter. Reuse the qualified suffix-use plan verbatim;
# only its consumer differs because a direct local replaces a runtime frame.
@unsafe
def p113dl_partition(+book: List<&2,KDef>, +plan: P112Liveness, +owner: String, +target: P113DTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113dl_live(book,plan,live,owner,target,n))

@unsafe
def p113dl_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_partition(book,plan,owner,target,n,p111_partition(env,p112_liveness_uses(plan)))

@unsafe
def p113dl_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113dl_lower(book,rest,nt_append(NC_Binding,held,[nk_binding(id,value,env)]),owner,target,p113d_fresh(first))))

@unsafe
def p113dl_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("direct: empty let",n)
    case P112LivenessLeaf{term,uses}: p113d_live(book,term,env,owner,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113dl_let(book,value,rest,env,id,owner,target,n)

@unsafe
def p113dl_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113d_live(book,t,[],owner,target,n)
    case Con{head,rest}: p113d_partition(book,t,owner,target,n,p111_partition(Con{head,rest},nc_uses(t)))

# Consume the unchanged persistent suffix-use plan for ordinary boxed lets.
# Only a genuine flat binding reconstructs a suffix for the mature bundle
# substitution. Following that substitution, p113pl_lower prepares fresh uses.
@unsafe
def p113px_terms(plan: P112Liveness) -> List<&2,KTerm>:
  match plan:
    case P112LivenessEmpty{}: []
    case P112LivenessLeaf{term,uses}: [term]
    case P112LivenessLet{value,id,uses,rest}: Con{kt("Bind","",id,1,[value]),p113px_terms(rest)}

@unsafe
def p113px_partition(+book: List<&2,KDef>, +plan: P112Liveness, +target: P113PTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113px_live(book,plan,live,target,n))

@unsafe
def p113px_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_partition(book,plan,target,n,p111_partition(env,p112_liveness_uses(plan)))

@unsafe
def p113px_boxed(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],atom("Absent")),n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113px_lower(book,rest,nt_append(NC_Binding,held,[nk_binding(id,value,env)]),target,p113d_fresh(first))))

@unsafe
def p113px_known(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +body = kt("NSeqLet","",0,0,p113px_terms(rest))
  nt_choose(P113DCode,p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))

@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))

@unsafe
def p113px_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("product empty let",n)
    case P112LivenessLeaf{term,uses}: p113pl_live(book,term,env,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113px_let(book,value,rest,env,id,target,n)

@unsafe
def p113px_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113pl_live(book,t,[],target,n)
    case Con{head,rest}: p113pl_partition(book,t,target,n,p111_partition(Con{head,rest},nc_uses(t)))

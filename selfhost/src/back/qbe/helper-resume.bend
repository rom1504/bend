

@unsafe
def p124r_view(ready: KDef, direct: KDef) -> KDef:
  KDef{"","P124Callables",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[ready,direct],False{},False{}}


@unsafe
def p124r_is_view(view: KDef) -> Bool:
  String.eq(dk(view),"P124Callables")


@unsafe
def p124r_legacy(+ready: KDef, +name: String) -> P124Callable:
  +count = da(p111v_get(ready,name))
  nt_choose(P124Callable,p112w_ready(ready,name) && U32.is_le(count,8),
    u => P124Callable{True{},count,p112w_symbol(name)},u => P124Callable{False{},0,""})


@unsafe
def p124r_complete(+ready: KDef, +name: String, +function: KDef) -> P124Callable:
  +count = da(function)
  nt_choose(P124Callable,String.eq(dk(function),"P113Direct") && U32.is_eq(dx(function),1) &&
    U32.is_eq(ix(dv(function)),1) && U32.is_le(count,8),
    u => P124Callable{True{},count,p113e_symbol(name)},u => p124r_legacy(ready,name))


@unsafe
def p124r_lookup_children(children: List<&2,KDef>, +name: String) -> P124Callable:
  match children:
    case Con{ready,Con{direct,Nil{}}}: p124r_complete(ready,name,p111v_get(direct,name))
    case _: P124Callable{False{},0,""}


@unsafe
def p124r_lookup(view: KDef, name: String) -> P124Callable:
  p124r_lookup_children(dc(view),name)



def p124r_valid(callable: P124Callable) -> Bool:
  match callable:
    case P124Callable{valid,arity,symbol}: valid


@unsafe
def p124r_known(+ready: KDef, +name: String) -> Bool:
  nt_choose(Bool,p124r_is_view(ready),u => p124r_valid(p124r_lookup(ready,name)),u => p112w_ready(ready,name))

# Original tail remains the independent arity/transport check. Every argument is
# loaded before the call, so neither helper scratch nor captures can clobber it.

@unsafe
def p124r_call_nodes(body: List<&2,N111Stmt>, +count: U32, symbol: String) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114r_without_transition(body),nt_append(N111Stmt,p114h_call_loads(count,0),[
    N111Call{"p114h_call_result",N111U64{},symbol,Con{p111_state(),p114h_call_args(count,0)}}]))


@unsafe
def p124r_terminal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef,
    +target: String, callable: P124Callable) -> P114GBody:
  match callable:
    case P124Callable{valid,+count,+symbol}:
      nt_choose(P114GBody,valid && Bool.not(String.eq(owner,target)) && p112t_tail(body,target,count,0),
        u => P114GBody{True{},[],p114h_scalars(p124r_call_nodes(body,count,symbol),[P114RResult{N111Local{"p114h_call_result"}}])},
        u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))

# Discovery does not prove admission: p114r_arguments checks the complete exact
# argument stores and terminal jump independently before a node is constructed.

@unsafe
def p124r_target(body: List<&2,N111Stmt>) -> String:
  match body:
    case Nil{}: ""
    case Con{+stmt,+rest}:
      +target = p112w_target(Con{stmt,rest})
      nt_choose(String,String.is_empty(target),u =>
        nt_choose(String,p112t_scalar_safe(stmt),v => p124r_target(rest),v => ""),u => target)


@unsafe
def p124r_resume_found(+body: List<&2,N111Stmt>, +tail: List<&2,N111Stmt>, +owner: String,
    +name: String, +captures: U32, +target: String, callable: P124Callable) -> P114GBody:
  match callable:
    case P124Callable{valid,+count,+symbol}:
      nt_choose(P114GBody,valid && Bool.not(String.eq(owner,target)) && p114r_arguments(tail,target,count),
        u => P114GBody{True{},[P114GFrame{name,captures}],[P114RResumeReady{
          p114r_prefix(body,U32.inc(captures)),p124r_call_nodes(tail,count,symbol),N111Local{"p114h_call_result"}}]},
        u => P114GBody{False{},[],[]})


@unsafe
def p124r_resume_target(body: List<&2,N111Stmt>, tail: List<&2,N111Stmt>, owner: String,
    name: String, captures: U32, ready: KDef, +target: String) -> P114GBody:
  p124r_resume_found(body,tail,owner,name,captures,target,p124r_lookup(ready,target))


@unsafe
def p124r_resume(+body: List<&2,N111Stmt>, +tail: List<&2,N111Stmt>, +owner: String,
    +name: String, +captures: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready) && U32.is_le(captures,8),
    u => p124r_resume_target(body,tail,owner,name,captures,ready,p124r_target(tail)),
    u => P114GBody{False{},[],[]})



@unsafe
def p124r_original_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P114GBody,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && U32.is_le(count,8) && p112t_tail(body,target,count,0),
    u => p114h_call(body,target,count),u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))


@unsafe
def p124r_public_extended(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))


@unsafe
def p124r_public_g(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +old: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,old),
        u => p124r_public_extended(segment,index,ids,ready,p114h_plan(segment,index,view)))


@unsafe
def p124r_public_r(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p124r_public_g(segment,index,ids,ready,view,p114g_plan(segment,index,ready)))


@unsafe
def p124r_public_h(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p124r_public_r(segment,index,ids,ready,view,p114r_plan(segment,index)))


@unsafe
def p124r_public(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +view: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),
        u => p124r_public_h(segment,index,ids,ready,view,p114h_plan(segment,index,ready)))


@unsafe
def p124r_public_chunks(segments: List<&2,N111Segment>, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +view: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p124r_public_chunks(rest,direct,index,ids,ready,view,
      Con{p124r_public(segment,direct,index,ids,ready,view),acc})

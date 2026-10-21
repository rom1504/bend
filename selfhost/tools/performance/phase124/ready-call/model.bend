# Phase124: verified ready helper calls returning into an existing local
# continuation table. Derived emission only; original graph/catalogue verification
# remains unchanged. This file is an overlay, not a standalone compiler.


type P114RStmt is Data:
  P114RScalar{+stmt: N111Stmt}
  P114RIf{+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>}
  P114RDescend{+frame: List<&2,N111Stmt>, +arguments: List<&2,N111Stmt>}
  P114RAgain{+arguments: List<&2,N111Stmt>}
  P114RResult{+value: N111Value}
  P114RFailure{+body: List<&2,N111Stmt>}
  P114RResumeReady{+frame: List<&2,N111Stmt>, +call: List<&2,N111Stmt>, +result: N111Value}

type P124Callable is Data:
  P124Callable{+valid: Bool, +arity: U32, +symbol: String}

@unsafe
def p124r_view(ready: KDef, direct: KDef) -> KDef:
  KDef{"","P124Callables",0,0,atom("Absent"),atom("Absent"),[ready,direct],False{},False{}}

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
      nt_choose(String,Bool.not(String.is_empty(target)),u => target,u =>
        nt_choose(String,p112t_scalar_safe(stmt),v => p124r_target(rest),v => ""))

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
def p114h_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready),
    u => p124r_terminal(body,owner,arity,ready,target,p124r_lookup(ready,target)),
    u => p124r_original_target(body,owner,arity,ready,target))


@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p114r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => p124r_resume(body,tail,owner,name,count,ready))
    case None{}: p114h_scan_next(body,owner,arity,ready)

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) && Bool.not(p124r_known(ready,name)) &&
        U32.is_le(p112f_size(body),512) && p112f_clean(body) && p114h_clean_segment(segment),
        u => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),u => p114h_refused())

@unsafe
def p114h_rename_stmt(stmt: P114RStmt, +prefix: String) -> P114RStmt:
  match stmt:
    case P114RScalar{scalar}: P114RScalar{p112f_stmt(scalar,prefix)}
    case P114RIf{condition,yes,no}: P114RIf{p112f_value(condition,prefix),p114h_rename(yes,prefix),p114h_rename(no,prefix)}
    case P114RDescend{frame,arguments}: P114RDescend{p112f_rename(frame,prefix),p112f_rename(arguments,prefix)}
    case P114RAgain{arguments}: P114RAgain{p112f_rename(arguments,prefix)}
    case P114RResult{value}: P114RResult{p112f_value(value,prefix)}
    case P114RFailure{body}: P114RFailure{p112f_rename(body,prefix)}
    case P114RResumeReady{frame,call,result}: P114RResumeReady{p112f_rename(frame,prefix),p112f_rename(call,prefix),p112f_value(result,prefix)}

@unsafe
def p114r_stmt(stmt: P114RStmt, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P114RIf{condition,yes,no}: p114r_if(condition,yes,no,params,ids,code)
    case P114RDescend{frame,arguments}:
      p114r_again(arguments,params,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114r_again(arguments,params,ids,code)
    case P114RResult{value}:
      p114r_jump("@p114r_unwind",p111q_line("%p114r_value =l copy " ++ p111q_value(value,ids) ++ "\n",code))
    case P114RFailure{body}: p111q_stmts(body,ids,code)
    case P114RResumeReady{frame,call,result}: p111q_problem("ready resume outside table region",code)

@unsafe
def p114h_stmt(+stmt: P114RStmt, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RIf{condition,yes,no}: p114h_if(condition,yes,no,params,buffer,ids,code)
    case P114RDescend{frame,arguments}:
      p114h_again(arguments,params,buffer,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114h_again(arguments,params,buffer,ids,code)
    case P114RResumeReady{frame,call,result}:
      p114r_stmt(P114RResult{result},params,ids,p111q_stmts(call,ids,
        p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code))))
    case _: p114r_stmt(stmt,params,ids,code)

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

@unsafe
def p113e_public_chunks(segments: List<&2,N111Segment>, +direct: KDef, index: P112FusionIndex,
    ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  p124r_public_chunks(segments,direct,index,ids,ready,p124r_view(ready,direct),acc)


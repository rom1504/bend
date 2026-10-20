def p114h_refused() -> P114HPlan:
  P114HPlan{False{},[],[],[]}

def p114h_scalars(body: List<&2,N111Stmt>, tail: List<&2,P114RStmt>) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: tail
    case Con{stmt,rest}: Con{P114RScalar{stmt},p114h_scalars(rest,tail)}

@unsafe
def p114h_call_name(index: U32) -> String:
  "p114h_arg_" ++ U32.show(index)

@unsafe
def p114h_call_loads(+count: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,index),u => [],u =>
    Con{N111Load{p114h_call_name(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)},p114h_call_loads(count,U32.inc(index))})

@unsafe
def p114h_call_args(+count: U32, +index: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{p114h_call_name(index)}},p114h_call_args(count,U32.inc(index))})

# Exact terminal stores have already been checked. Snapshot every argument
# before the private call, preserving the owning single-Term result boundary.
@unsafe
def p114h_call(+body: List<&2,N111Stmt>, target: String, +count: U32) -> P114GBody:
  P114GBody{True{},[],p114h_scalars(p114r_prefix(body,count),
    p114h_scalars(p114h_call_loads(count,0),[
      P114RScalar{N111Call{"p114h_call_result",N111U64{},p112w_symbol(target),Con{p111_state(),p114h_call_args(count,0)}}},
      P114RResult{N111Local{"p114h_call_result"}}]))}

@unsafe
def p114h_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112t_failure(body),u => P114GBody{True{},[],[P114RFailure{body}]},
    u => p114h_scan_normal(body,owner,arity,ready))

@unsafe
def p114h_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112w_result(body),
    u => P114GBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114GBody,p112t_tail(body,owner,arity,0),
    u => P114GBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114h_scan_target(body,owner,arity,ready,p112w_target(body))))

@unsafe
def p114h_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P114GBody,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && U32.is_le(count,8) && p112t_tail(body,target,count,0),
    u => p114h_call(body,target,count),u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))

@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p114r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => P114GBody{False{},[],[]})
    case None{}: p114h_scan_next(body,owner,arity,ready)

@unsafe
def p114h_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  match body:
    case Nil{}: P114GBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114g_branch(condition,p114h_scan(yes,owner,arity,ready),p114h_scan(no,owner,arity,ready),p114h_scan(rest,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P114GBody,p112t_scalar_safe(stmt),
        u => p114g_prepend(stmt,p114h_scan_normal(rest,owner,arity,ready)),
        u => p114g_prepend(stmt,p114h_scan(rest,owner,arity,ready)))

# A missing case has an impossible capture count; real layouts are 0..8.
@unsafe
def p114h_count(cases: List<&2,P114HCase>, +name: String) -> U32:
  match cases:
    case Nil{}: 4294967295
    case Con{P114HCase{key,captures,result,pop,body},rest}:
      nt_choose(U32,String.eq(key,name),u => nt_count(String,captures),u => p114h_count(rest,name))

@unsafe
def p114h_close(pending: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, +cases: List<&2,P114HCase>, +left: U32) -> P114HClosed:
  match pending:
    case Nil{}: P114HClosed{True{},nt_reverse(P114HCase,cases,[])}
    case Con{P114GFrame{+name,count},rest}:
      p114h_close_seen(name,count,rest,owner,arity,index,ready,cases,left,p114h_count(cases,name))

@unsafe
def p114h_close_seen(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, +seen: U32) -> P114HClosed:
  nt_choose(P114HClosed,U32.is_eq(seen,4294967295),u =>
    nt_choose(P114HClosed,U32.is_gt(left,0),
      v => p114h_close_found(name,count,rest,owner,arity,index,ready,cases,U32.sub(left,1),p112f_index_get(index,name)),
      v => P114HClosed{False{},[]}),u =>
    nt_choose(P114HClosed,U32.is_eq(seen,count),
      v => p114h_close(rest,owner,arity,index,ready,cases,left),v => P114HClosed{False{},[]}))

@unsafe
def p114h_close_found(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, found: Maybe<&2,N111Segment>) -> P114HClosed:
  match found:
    case Some{+segment}:
      nt_choose(P114HClosed,p114h_clean_segment(segment),
        u => p114h_close_cont(name,rest,owner,arity,index,ready,cases,left,p112f_cont(segment,count)),
        u => P114HClosed{False{},[]})
    case None{}: P114HClosed{False{},[]}

@unsafe
def p114h_close_cont(+name: String, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, cont: Maybe<&2,P112FusionCont>) -> P114HClosed:
  match cont:
    case Some{P112FusionCont{captures,result,pop,body}}:
      p114h_close_scanned(name,captures,result,pop,rest,owner,arity,index,ready,cases,left,p114h_scan(body,owner,arity,ready))
    case None{}: P114HClosed{False{},[]}

@unsafe
def p114h_close_scanned(+name: String, +captures: List<&2,String>, +result: String, +pop: String,
    +rest: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef,
    +cases: List<&2,P114HCase>, +left: U32, scanned: P114GBody) -> P114HClosed:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114HClosed,valid,u => p114h_close(nt_append(P114GFrame,frames,rest),owner,arity,index,ready,
        Con{P114HCase{name,captures,result,pop,body},cases},left),u => P114HClosed{False{},[]})

def p114h_closed(params: List<&2,String>, body: List<&2,P114RStmt>, closed: P114HClosed) -> P114HPlan:
  match closed:
    case P114HClosed{valid,cases}: P114HPlan{valid,params,body,cases}

@unsafe
def p114h_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114HPlan:
  match scanned:
    case P114GBody{valid,+frames,body}:
      nt_choose(P114HPlan,valid && U32.is_gt(nt_count(P114GFrame,frames),0),
        u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())

@unsafe
def p114h_prelude(+owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef, prelude: P112TailPrelude) -> P114HPlan:
  match prelude:
    case P112TailPrelude{valid,params,prefix,body}:
      nt_choose(P114HPlan,valid,u => p114h_finish(params,owner,arity,index,ready,p114h_scan(body,owner,arity,ready)),u => p114h_refused())

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) && Bool.not(p112w_ready(ready,name)) &&
        U32.is_le(p112f_size(body),512) && p112f_clean(body) && p114h_clean_segment(segment),
        u => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),u => p114h_refused())

def p114h_valid(plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}: valid

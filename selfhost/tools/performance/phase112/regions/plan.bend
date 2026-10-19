@unsafe
def p112r_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112r_failure(body,symbols,sites),u => P112WorkerBody{True{},0,p112w_failure_nodes(body)},
    u => p112r_normal(body,owner,arity,ready,symbols,sites))

@unsafe
def p112r_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  +buffer = p112r_head_buffer(body)
  nt_choose(P112WorkerBody,p112r_buffer(buffer,sites) && p112r_tail(body,owner,arity,0,buffer),
    u => P112WorkerBody{True{},0,p112r_exit(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112r_result(body,sites),u => P112WorkerBody{True{},0,p112r_exit(body,1,P112WorkerResult{})},
      u => p112r_scan_target(body,owner,arity,ready,symbols,sites,buffer,p112r_target(body,sites))))

@unsafe
def p112r_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +buffer: String, +target: String) -> P112WorkerBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P112WorkerBody,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && p112r_buffer(buffer,sites) && p112r_tail(body,target,count,0,buffer),
    u => P112WorkerBody{True{},1,p112r_exit(body,count,P112WorkerCall{target,count})},
    u => p112r_next(body,owner,arity,ready,symbols,sites))

@unsafe
def p112r_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{+condition,+yes,+no},+rest}:
      p112r_yes(condition,no,rest,owner,arity,ready,symbols,sites,p112r_scan(yes,owner,arity,ready,symbols,sites))
    case Con{+stmt,+rest}:
      nt_choose(P112WorkerBody,p112r_scalar(stmt,symbols,sites),
        u => p112e_worker_scalar(stmt,p112r_normal(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})

@unsafe
def p112r_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(yes),
    u => p112r_no(condition,rest,owner,arity,ready,symbols,sites,yes,p112r_scan(no,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})

@unsafe
def p112r_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody, +no: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(no),
    u => p112r_rest(condition,yes,no,p112r_scan(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})

@unsafe
def p112r_rest(+condition: N111Value, +yes: P112WorkerBody, +no: P112WorkerBody, +rest: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(rest),u => p112w_branch(condition,yes,no,rest),u => P112WorkerBody{False{},0,[]})

@unsafe
def p112r_prelude(+owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, prelude: P112TailPrelude) -> P112WorkerPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,+prefix,+body}:
      nt_choose(P112WorkerPlan,valid,u => p112w_finish(params,p112r_scan(body,owner,arity,ready,symbols,sites)),u => P112WorkerPlan{False{},0,[],[]})

# Internal planner: segment and site count must come from p112r_fused below.
@unsafe
def p112r_plan(segment: N111Segment, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,8) && U32.is_le(sites,8),
        u => p112r_prelude(name,arity,ready,symbols,sites,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})

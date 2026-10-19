# Only refusal evaluation order changes. Successful private plan nodes and
# source-order runtime instructions are identical to the frozen planner.
@unsafe
def p112t_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  match body:
    case Nil{}: P112TailBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112e_tail_yes(condition,no,rest,owner,arity,p112t_scan(yes,owner,arity))
    case Con{+stmt,+rest}:
      nt_choose(P112TailBody,p112t_scalar_safe(stmt),
        u => p112e_tail_scalar(stmt,p112t_scan_normal(rest,owner,arity)),u => P112TailBody{False{},0,[]})

@unsafe
def p112w_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112e_worker_yes(condition,no,rest,owner,arity,ready,p112w_scan(yes,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P112WorkerBody,p112t_scalar_safe(stmt),
        u => p112e_worker_scalar(stmt,p112e_worker_normal(rest,owner,arity,ready)),u => P112WorkerBody{False{},0,[]})

# A worker already admitted in an earlier immutable pass keeps its exact rank;
# no subsequent pass needs to reconstruct its plan merely to discard it.
@unsafe
def p112w_add(+segment: N111Segment, +old: KDef, +rank: U32, +next: KDef) -> KDef:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(KDef,p112w_ready(old,name),u => next,u =>
        nt_choose(KDef,p112w_admitted(p112w_plan(segment,old)),
          v => p111v_put(next,name,"P112Worker",arity,rank),v => next))

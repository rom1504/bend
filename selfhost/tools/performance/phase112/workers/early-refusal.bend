# Pure planner short circuit. Invalid plan payloads are never emitted; canonical
# invalid bodies avoid scanning/copying suffixes after a mandatory refusal.
def p112e_tail_valid(body: P112TailBody) -> Bool:
  match body:
    case P112TailBody{valid,loops,nodes}: valid

def p112e_worker_valid(body: P112WorkerBody) -> Bool:
  match body:
    case P112WorkerBody{valid,calls,nodes}: valid

@unsafe
def p112e_tail_scalar(+stmt: N111Stmt, tail: P112TailBody) -> P112TailBody:
  match tail:
    case P112TailBody{+valid,+loops,+body}:
      nt_choose(P112TailBody,valid,u => P112TailBody{True{},loops,Con{P112TailScalar{stmt},body}},
        u => P112TailBody{False{},0,[]})

@unsafe
def p112e_worker_scalar(+stmt: N111Stmt, tail: P112WorkerBody) -> P112WorkerBody:
  match tail:
    case P112WorkerBody{+valid,+calls,+body}:
      nt_choose(P112WorkerBody,valid,u => P112WorkerBody{True{},calls,Con{P112WorkerScalar{stmt},body}},
        u => P112WorkerBody{False{},0,[]})

@unsafe
def p112e_tail_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>,
  +owner: String, +arity: U32, +yes: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(yes),
    u => p112e_tail_no(condition,rest,owner,arity,yes,p112t_scan(no,owner,arity)),
    u => P112TailBody{False{},0,[]})

@unsafe
def p112e_tail_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32,
  +yes: P112TailBody, +no: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(no),
    u => p112e_tail_rest(condition,yes,no,p112t_scan(rest,owner,arity)),u => P112TailBody{False{},0,[]})

@unsafe
def p112e_tail_rest(+condition: N111Value, +yes: P112TailBody, +no: P112TailBody, +rest: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(rest),u => p112t_branch(condition,yes,no,rest),u => P112TailBody{False{},0,[]})

@unsafe
def p112e_worker_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>,
  +owner: String, +arity: U32, +ready: KDef, +yes: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(yes),
    u => p112e_worker_no(condition,rest,owner,arity,ready,yes,p112w_scan(no,owner,arity,ready)),
    u => P112WorkerBody{False{},0,[]})

@unsafe
def p112e_worker_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32,
  +ready: KDef, +yes: P112WorkerBody, +no: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(no),
    u => p112e_worker_rest(condition,yes,no,p112w_scan(rest,owner,arity,ready)),u => P112WorkerBody{False{},0,[]})

@unsafe
def p112e_worker_rest(+condition: N111Value, +yes: P112WorkerBody, +no: P112WorkerBody, +rest: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(rest),u => p112w_branch(condition,yes,no,rest),u => P112WorkerBody{False{},0,[]})

# Ordinary worker recursion intentionally bypasses only the block-entry failure
# scan, just as the frozen fail-stop planner does. Branches re-enter full scan.
@unsafe
def p112e_worker_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_tail(body,owner,arity,0),
    u => P112WorkerBody{True{},0,p112w_nodes(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112w_result(body),
      u => P112WorkerBody{True{},0,p112w_nodes(body,1,P112WorkerResult{})},u =>
      p112w_scan_target(body,owner,arity,ready,p112w_target(body))))

# Exact optional overrides. No Reply value is converted to a Term on a returning
# execution: the copied failure suffix stops the admitted CPU process.
@unsafe
def p112w_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_failure(body),u => P112WorkerBody{True{},0,p112w_failure_nodes(body)},u =>
    p112w_scan_normal(body,owner,arity,ready))

@unsafe
def p112w_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112w_branch(condition,p112w_scan(yes,owner,arity,ready),p112w_scan(no,owner,arity,ready),p112w_scan(rest,owner,arity,ready))
    case Con{stmt,rest}: p112w_prepend(stmt,p112w_scan_normal(rest,owner,arity,ready))

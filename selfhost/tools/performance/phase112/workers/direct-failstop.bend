# OPTIONAL exact-runtime profile. CPU runtime04 err_post delegates to err_fail,
# which flushes stdout, prints the diagnostic and calls _exit(1). The copied
# machine return after p111_rt_fail is therefore unreachable. DEVICE does return
# from err_post and is explicitly outside this profile's admission.
def p112w_failure_nodes(body: List<&2,N111Stmt>) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_failure_nodes(rest)}

@unsafe
def p112w_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_tail(body,owner,arity,0),
    u => P112WorkerBody{True{},0,p112w_nodes(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112w_result(body),
      u => P112WorkerBody{True{},0,p112w_nodes(body,1,P112WorkerResult{})},u =>
      p112w_scan_target(body,owner,arity,ready,p112w_target(body))))

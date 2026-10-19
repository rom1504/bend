# Exact replacements from the frozen first planner. A block is entered through
# scan; its ordinary scalar tail is scanned through scan_normal.
@unsafe
def p112t_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_failure(body),u => P112TailBody{True{},0,p112t_scalars(body)},u =>
    p112t_scan_normal(body,owner,arity))

@unsafe
def p112t_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  match body:
    case Nil{}: P112TailBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112t_branch(condition,p112t_scan(yes,owner,arity),p112t_scan(no,owner,arity),p112t_scan(rest,owner,arity))
    case Con{stmt,rest}: p112t_prepend_scalar(stmt,p112t_scan_normal(rest,owner,arity))

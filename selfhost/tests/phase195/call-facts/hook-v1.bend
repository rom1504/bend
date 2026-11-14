# Sole replacement; the original matcher, Set/width logic and per-write kills
# remain authoritative. Only call transfer differs from the branch-only hook.
@unsafe
def x190_v_plain(body: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x195bf_if(x190_v_value(condition,state),yes,no,rest,state)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x195bf_if(x190_v_value(condition,state),x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)
    case Con{P113DScalar{stmt},rest}: x190_v_after(rest,x195cf_scalar(stmt,state))
    case Con{P113DCall{+names,target,args},rest}:
      Con{P113DCall{names,target,x190_v_values(args,state)},x190_v_body(rest,x195cf_after_call(names,state))}
    case Con{P113DResult{values},rest}: Con{P113DResult{x190_v_values(values,state)},x190_v_body(rest,x190_v_empty())}
    case Con{P113DAgain{values},rest}: Con{P113DAgain{x190_v_values(values,state)},x190_v_body(rest,x190_v_empty())}

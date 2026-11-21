# The same register read arrives as a runtime call before late expansion.
# Normalize just that operand through the existing expander and require the
# original complete continuation contract before selecting its typed template.
@unsafe
def x204_expanded_tail(expanded: List<&2,N111Stmt>, rest: List<&2,N111Stmt>, saved: String) -> Bool:
  match expanded:
    case Con{load,Nil{}}: x202k_tail(Con{load,rest},saved)
    case _: False{}

@unsafe
def x204_source_tail(+rows: List<&2,N111Stmt>, +saved: String) -> Bool:
  match rows:
    case Con{N111Call{name,typ,symbol,args},rest}:
      +call: N111Stmt = N111Call{name,typ,symbol,args}
      x185_late_enabled() && x202k_index(call,"p111_rt_reg_get",0) &&
        x204_expanded_tail(p112a_expand(3,call),rest,saved)
    case _: x202k_tail(rows,saved)

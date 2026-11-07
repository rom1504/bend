# Only the source-checked driver with freshly produced annotate_selected terms
# calls this private consumer. Public/raw erasure and preparation are unchanged.
@unsafe
def p86_plan_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  +error = jl_checked_error(context,annotated,["main"],stops)
  nt_choose(P86Plan,String.is_empty(error),
    u => P86PlanReady{p175sf_prepare(context,annotated),verdict},
    u => P86PlanError{"compile: " ++ error})

# A residual applied Efq is the final miss of a checked exhaustive matcher.
# The generic p111_slow_app first evaluates its callee; runtime04 CPU fail-stop
# exits there before evaluating arguments. Preserve that exact order here.
@unsafe
def p113d_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  nt_choose(P113DCode,String.eq(tg(head),"Efq"),
    u => p113d_live(book,head,env,owner,target,n),
    u => p113da_original_app(book,t,env,owner,target,n))

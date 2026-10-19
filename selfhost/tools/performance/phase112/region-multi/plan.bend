# Restore the already qualified wide32 Term ABI independently of the unchanged
# eight-argument limit on individual continuation-fusion sites.
@unsafe
def p112c_plan(segment: N111Segment, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32) && U32.is_le(sites,8),
        u => p112r_prelude(name,arity,ready,symbols,sites,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})

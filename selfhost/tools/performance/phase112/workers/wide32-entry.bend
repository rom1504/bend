# OPTIONAL bounded ABI profile. Only the owned argument limit changes; exact
# prelude, incoming/result/flags, 3 admission ranks and lifetime rules remain.
@unsafe
def p112w_plan(segment: N111Segment, +ready: KDef) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32),
        u => p112w_prelude(name,arity,ready,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})

# Descriptor FIDs and original continuations stay intact. A generic caller can
# enter this wrapper exactly as before; internal recursive edges stay local.
@unsafe
def p114r_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

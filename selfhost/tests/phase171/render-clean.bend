# The only original override is p124r_public. Private helpers are reachable
# only after the exact original segment's p112f_clean predicate succeeds.
# Continuation hygiene, readiness, limits and selection order remain unchanged.

@unsafe
def p171rc_h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114HPlan,p124r_known(ready,name),v => p114h_refused(),
          v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),512),
            w => nt_choose(P114HPlan,p114h_clean_segment(segment),
              x => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),x => p114h_refused()),
            w => p114h_refused())),u => p114h_refused())

@unsafe
def p171rc_r_plan(segment: N111Segment, +index: P112FusionIndex) -> P114RPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114RPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => p114r_prelude(name,arity,index,p112t_prelude(body,arity)),u => p114r_refused())

@unsafe
def p171rc_g_plan(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114GPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114GPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114GPlan,p112w_ready(ready,name),v => p114g_refused(),
          v => p114g_prelude(name,arity,index,ready,p112t_prelude(body,arity))),u => p114g_refused())

@unsafe
def p171rc_extended(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_scan(body,index,ready,0)))

@unsafe
def p171rc_g(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +plan: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,plan),
        u => p171rc_extended(segment,index,ids,ready,p171rc_h_plan(segment,index,view)))

@unsafe
def p171rc_r(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +plan: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,plan),
        u => p171rc_g(segment,index,ids,ready,view,p171rc_g_plan(segment,index,ready)))

@unsafe
def p171rc_h(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p171rc_r(segment,index,ids,ready,view,p171rc_r_plan(segment,index)))

@unsafe
def p171rc_enter(segment,index,ids,ready,view):
  match segment:
    case N111Segment{name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
        u => nt_choose(String,p112f_clean(body),
          v => p171rc_h(segment,index,ids,ready,view,p171rc_h_plan(segment,index,ready)),
          v => p112w_public_segment(segment,ids,ready)),
        u => p112w_public_segment(segment,ids,ready))

@unsafe
def p124r_public(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +view: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),
        u => p171rc_enter(segment,index,ids,ready,view))

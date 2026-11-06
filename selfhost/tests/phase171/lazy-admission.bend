# Phase171 experiment: preserve every admission condition, but do not inspect
# entire bodies or query readiness after cheap metadata has already refused.
# Bool conjunction is eager. nt_choose keeps the skipped work inside a closure.
# These are producer/planner changes; no final verifier is replaced.

@unsafe
def p114r_plan(segment: N111Segment, +index: P112FusionIndex) -> P114RPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114RPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114RPlan,p112f_clean(body),
          v => p114r_prelude(name,arity,index,p112t_prelude(body,arity)),v => p114r_refused()),
        u => p114r_refused())

@unsafe
def p114g_plan(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114GPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114GPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114GPlan,p112w_ready(ready,name),v => p114g_refused(),
          v => nt_choose(P114GPlan,p112f_clean(body),
            w => p114g_prelude(name,arity,index,ready,p112t_prelude(body,arity)),w => p114g_refused())),
        u => p114g_refused())

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114HPlan,p124r_known(ready,name),v => p114h_refused(),
          v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),512),
            w => nt_choose(P114HPlan,p112f_clean(body),
              x => nt_choose(P114HPlan,p114h_clean_segment(segment),
                y => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),y => p114h_refused()),
              x => p114h_refused()),w => p114h_refused())),
        u => p114h_refused())

@unsafe
def p112c_plan_index(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P112FusionBody:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0),
        u => nt_choose(P112FusionBody,p112f_clean(body),
          v => p112c_scan(body,index,ready,0),v => P112FusionBody{body,0,0}),
        u => P112FusionBody{body,0,0})

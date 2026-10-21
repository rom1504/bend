# H already rejected on the same immutable segment/index/ready. Preserve R/G
# admission and precedence, then take the existing generic fallback directly.
@unsafe
def p115n_public_g(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,old),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

@unsafe
def p115n_public_r(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p115n_public_g(segment,index,ids,ready,p114g_plan(segment,index,ready)))

@unsafe
def p114hf_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p115n_public_r(segment,index,ids,ready,p114r_plan(segment,index)))

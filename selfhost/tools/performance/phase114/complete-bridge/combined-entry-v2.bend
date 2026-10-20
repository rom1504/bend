# Optional final adapter only: direct -> narrow04 -> G02 -> H01 -> bridge.
# Frozen isolated bridge01 and table01 modules remain unchanged.
@unsafe
def p114b_table(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p114b_fused(segment,direct,ids,ready,p112c_plan_index(segment,index,ready)))

@unsafe
def p114b_combined_general(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +plan: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,plan),
        u => p114b_table(segment,direct,index,ids,ready,p114h_plan(segment,index,ready)))

@unsafe
def p114b_combined_narrow(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +plan: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,plan),
        u => p114b_combined_general(segment,direct,index,ids,ready,p114g_plan(segment,index,ready)))

@unsafe
def p113e_public_chunk(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p114b_combined_narrow(segment,direct,index,ids,ready,p114r_plan(segment,index)))

# Preserve transport namespace protection and also reserve bridge locals.
@unsafe
def p114t_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114t_") || String.starts_with(name,"p114b_"))

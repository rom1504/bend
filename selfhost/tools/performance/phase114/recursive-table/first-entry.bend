# Optional precedence ablation. Existing R/G and generic routes remain fallback;
# a refused H plan may be checked again by the unchanged old fallback chain.
@unsafe
def p114hf_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p114h_public_r(segment,index,ids,ready,p114r_plan(segment,index)))

@unsafe
def p113e_public_chunk(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p114hf_planned(segment,index,ids,ready,p114h_plan(segment,index,ready)))

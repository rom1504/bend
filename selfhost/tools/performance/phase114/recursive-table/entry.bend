# Existing complete, narrow and singleton-general routes retain precedence.
@unsafe
def p113e_public_chunk(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p114h_public_r(segment,index,ids,ready,p114r_plan(segment,index)))

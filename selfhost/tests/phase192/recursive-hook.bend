# Experimental public renderer hook. Preserve generic mode and complete direct
# worker precedence; the shared H planner owns every semantic admission rule.
@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,+direct,ready,view,lookups,heap,mode}:
      +function = p111v_get(direct,name)
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},
        nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) &&
          Bool.not(String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)),
          u => x192h_public(segment,index,ids,ready,available),u => x181_segment(segment,ids)))

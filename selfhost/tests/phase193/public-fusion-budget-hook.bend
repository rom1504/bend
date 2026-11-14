
@unsafe
def x193f_plan(+segment: N111Segment, index: P112FusionIndex, +ready: KDef,
    available: KDef, fusion: Bool, tail: Bool) -> X193FBody:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      nt_choose(X193FBody,x193f_clean(body),u =>
        x193f_checked(x193fb_candidate(segment,ready,tail,x193f_fused(segment,index,ready,fusion)),available),
        u => X193FBody{body,0,"public helper reserved local collision"})

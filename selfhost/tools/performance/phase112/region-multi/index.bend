@unsafe
def p112c_freeze(+segment: N111Segment, +rank: U32, +sites: U32, +next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,p112w_admitted(plan),u => p112c_insert(segment,rank,sites,next,plan),u => next)

@unsafe
def p112c_insert(+segment: N111Segment, +rank: U32, +sites: U32, next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  match segment next:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,rank),p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,rank),
        Con{P112RegionEntry{segment,plan,rank,sites},entries},U32.inc(workers),U32.add(fusions,sites)}

@unsafe
def p112c_fused(segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry, fused: P112FusionBody) -> P112RegionRegistry:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      p112c_freeze(transformed,rank,count,next,p112c_plan(transformed,old,symbols,count))

# This helper receives only a qualified typed candidate from p112c_candidates.
@unsafe
def p112c_add(+segment: N111Segment, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry) -> P112RegionRegistry:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112RegionRegistry,p112w_ready(old,name),u => next,u =>
        p112c_fused(segment,old,symbols,rank,next,p112c_scan(body,index,old,0)))

# old and symbols are immutable for the entire pass; next is only accumulated.
@unsafe
def p112c_pass(segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, next: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: next
    case Con{P112MultiCandidate{+segment},+rest}: p112c_pass(rest,index,old,symbols,rank,p112c_add(segment,index,old,symbols,rank,next))

@unsafe
def p112c_passes(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,U32.is_eq(left,0),u => registry,u => p112c_round(segments,index,registry,rank,left))

@unsafe
def p112c_round(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112c_continue(segments,index,rank,left,workers,p112c_pass(segments,index,ready,symbols,rank,registry))

@unsafe
def p112c_continue(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +rank: U32, +left: U32, +previous: U32, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      nt_choose(P112RegionRegistry,U32.is_eq(workers,previous),u => registry,u => p112c_passes(segments,index,registry,U32.inc(rank),U32.sub(left,1)))

@unsafe
def p112c_candidate(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Bool,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32),
        u => p112f_clean(body),u => False{})

# Metadata and original hygiene are checked once, even when no site is fused.
@unsafe
def p112c_candidates(segments: List<&2,N111Segment>, +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
        u => p112c_candidates(rest,Con{P112MultiCandidate{segment},acc}),u => p112c_candidates(rest,acc))

@unsafe
def p112c_index_with(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P112RegionRegistry:
  p112c_passes(p112c_candidates(segments,[]),index,P112RegionRegistry{missing(),missing(),[],0,0},1,6)

@unsafe
def p112c_index(+segments: List<&2,N111Segment>) -> P112RegionRegistry:
  p112c_index_with(segments,p112f_index(segments))

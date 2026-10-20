@unsafe
def p114g_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

# Retain the qualified narrow path byte-for-byte where it already applies.
@unsafe
def p114g_public_pick(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p114g_public_planned(segment,index,ids,ready,p114g_plan(segment,index,ready)))

@unsafe
def p114g_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef) -> List<&2,String>:
  match segments:
    case Nil{}: []
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,+body}:
          nt_choose(List<&2,String>,p114g_hygiene(body,index,p114g_plan(segment,index,ready)),
            u => Con{name,p114g_entries(rest,index,ready)},u => p114g_entries(rest,index,ready))

@unsafe
def p114g_inspect_registry(+segments: List<&2,N111Segment>, +index: P112FusionIndex, registry: P112RegionRegistry) -> P114RInspection:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}: P114RInspection{p114g_entries(segments,index,ready),""}

@unsafe
def p114g_inspect_index(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P114RInspection:
  p114g_inspect_registry(segments,index,p112c_index_with(segments,index))

@unsafe
def p114g_inspect_program(+program: P113AProgram, +error: String) -> P114RInspection:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      nt_choose(P114RInspection,String.is_empty(error),
        u => p114g_inspect_index(segments,p112f_index(segments)),u => P114RInspection{[],error})

@unsafe
def p114g_inspect_lowered(lowered: P113ALowering) -> P114RInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p114g_inspect_program(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))

@unsafe
def p114g_inspect_request(request: NR_Request) -> P114RInspection:
  p114g_inspect_lowered(p113a_lower_request(request))

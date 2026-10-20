@unsafe
def p114h_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

@unsafe
def p114h_public_g(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,old),
        u => p114h_public_planned(segment,index,ids,ready,p114h_plan(segment,index,ready)))

@unsafe
def p114h_public_r(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p114h_public_g(segment,index,ids,ready,p114g_plan(segment,index,ready)))

def p114h_case_names(cases: List<&2,P114HCase>) -> List<&2,String>:
  match cases:
    case Nil{}: []
    case Con{P114HCase{name,captures,result,pop,body},rest}: Con{name,p114h_case_names(rest)}

@unsafe
def p114h_inspect_entry(+name: String, +tail: List<&2,P114HEntry>, plan: P114HPlan) -> List<&2,P114HEntry>:
  match plan:
    case P114HPlan{valid,params,body,cases}:
      nt_choose(List<&2,P114HEntry>,valid,u => Con{P114HEntry{name,p114h_case_names(cases)},tail},u => tail)

@unsafe
def p114h_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef) -> List<&2,P114HEntry>:
  match segments:
    case Nil{}: []
    case Con{+segment,rest}:
      match segment:
        case N111Segment{name,arity,result,incoming,flags,body}:
          p114h_inspect_entry(name,p114h_entries(rest,index,ready),p114h_plan(segment,index,ready))

@unsafe
def p114h_inspect_registry(+segments: List<&2,N111Segment>, +index: P112FusionIndex, registry: P112RegionRegistry) -> P114HInspection:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}: P114HInspection{p114h_entries(segments,index,ready),""}

@unsafe
def p114h_inspect_index(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P114HInspection:
  p114h_inspect_registry(segments,index,p112c_index_with(segments,index))

@unsafe
def p114h_inspect_program(+program: P113AProgram, +error: String) -> P114HInspection:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      nt_choose(P114HInspection,String.is_empty(error),
        u => p114h_inspect_index(segments,p112f_index(segments)),u => P114HInspection{[],error})

@unsafe
def p114h_inspect_lowered(lowered: P113ALowering) -> P114HInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p114h_inspect_program(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))

@unsafe
def p114h_inspect_request(request: NR_Request) -> P114HInspection:
  p114h_inspect_lowered(p113a_lower_request(request))

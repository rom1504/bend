# This entry accepts the same checked NR_Request as the maintained backend.
# A mixed original is authenticated before the ordinary optimizer can use it.
@unsafe
def p164h_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, emission: P111Emission) -> P111Emission:
  match emission:
    # The reused late pipeline returns this variant only for errors. Refuse a
    # future materialized success rather than bypassing final mixed obligations.
    case P111Emission{chunks,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => P111Emission{[],"hybrid unexpected materialized success"},u => P111Emission{[],error})
    case P134Planned{plan}: p164h_final_plan(book,bangs,adapters,plan)

@unsafe
def p164h_final_plan(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef, +plan: P134EmissionPlan) -> P111Emission:
  match plan:
    case P134Admitted{program}: p164h_final_error(plan,p164v_final(book,bangs,adapters,program))
    case _: P111Emission{[],"hybrid unexpected non-admitted final plan"}

@unsafe
def p164h_final_error(+plan: P134EmissionPlan, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{plan},u => P111Emission{[],"hybrid final verification: " ++ error})

@unsafe
def p164h_functions(+request: NR_Request, +book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +raw: List<&2,P113DCandidate>, +original: P112StaticProgram, +functions: List<&2,P113DFunction>, +ids: N111Ids, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u =>
    p164h_final(book,bangs,adapters,p146c_finish(request,p113a_certificate(request),raw,
      p114s_ranges_lowered(p114s_inline_lowered(P114SLowered{P114SBoundary{original,ids,functions,True{}},""})))),
    u => P111Emission{[],"hybrid direct verification: " ++ error})

@unsafe
def p164h_original(+request: NR_Request, +book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +raw: List<&2,P113DCandidate>, program: P113DProgram, +error: String) -> P111Emission:
  match program:
    case P113DProgram{+original,+functions}:
      +ids : N111Ids = p114s_ids(original)
      nt_choose(P111Emission,String.is_empty(error),u =>
        p164h_functions(request,book,bangs,adapters,raw,original,functions,ids,p147d_functions(functions,ids,missing())),
        u => P111Emission{[],"hybrid original verification: " ++ error})

@unsafe
def p164h_lowered(+request: NR_Request, +book: List<&2,KDef>, +bangs: List<&2,String>, lowered: P164HLowering) -> P111Emission:
  match lowered:
    case P164HLowering{P113DLowered{+program,+error},+raw,+adapters,omitted}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p164h_original(request,book,bangs,adapters,raw,program,p164v_original(book,bangs,program,adapters)),
        u => P111Emission{[],"hybrid lowering: " ++ error})

@unsafe
def p164h_admitted(+request: NR_Request, +error: String) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p164h_lowered(request,book,nc_bangs_names(book,names),p164l_request(request)),
        u => P111Emission{[],error})

@unsafe
def p164h_emit_request(+request: NR_Request) -> P111Emission:
  p164h_admitted(request,p111_runtime_admission(request))

@unsafe
def p164h_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{request,verdict}: p164h_emit_request(request)

@unsafe
def p164h_adapters(segments: List<&2,N111Segment>, count: U32) -> U32:
  match segments:
    case Nil{}: count
    case Con{head,rest}: p164h_adapters(rest,U32.add(count,Bool.to_u32(p164a_shape(head))))

@unsafe
def p164h_summary(emission: P111Emission) -> String:
  match emission:
    case P111Emission{chunks,error}: "error=" ++ error
    case P134Planned{plan}: p164h_summary_plan(plan)

@unsafe
def p164h_summary_plan(plan: P134EmissionPlan) -> String:
  match plan:
    case P134Admitted{P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},+functions},certificate}}:
      "segments=" ++ U32.show(nt_count(N111Segment,segments)) ++
      ";adapters=" ++ U32.show(p164h_adapters(segments,0)) ++
      ";generic=" ++ U32.show(nt_count(N111Segment,p164a_generic(segments,[]))) ++
      ";direct=" ++ U32.show(nt_count(P113DFunction,functions)) ++
      ";arrays=" ++ U32.show(Bool.to_u32(p113a_enabled(certificate))) ++
      ";live=" ++ U32.show(Bool.to_u32(Bool.not(List.is_empty(&2,P113DFunction,functions)) &&
        p118z_segments(p164a_generic(segments,[])) && p118z_functions(functions)))
    case _: "error=unexpected plan"

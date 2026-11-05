# Optional attribution control: same lowering, scalar facts, actual final gates
# and checked live transport; only the renderer uses the existing region registry.
@unsafe
def p168r_emitted(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => P111Emission{p167live_chunks(program),""},
    u => P111Emission{[],"early scalar region final IR: " ++ error})

@unsafe
def p168r_lowered(request: NR_Request, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p168r_emitted(program,p167ob_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"early scalar region lowering: " ++ error})

@unsafe
def p168r_admitted(+mode: U32, +request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p168r_lowered(request,p168_request_mode(mode,request)),
    u => P111Emission{[],"early scalar region runtime: " ++ error})

@unsafe
def p168r_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      nt_choose(P111Emission,U32.is_le(mode,1),
        u => p168r_admitted(mode,request,p111_runtime_admission(request)),
        u => P111Emission{[],"early scalar region mode must be 0 or 1"})

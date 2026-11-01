# Experimental policy codes: bit0 skips inlining, bit1 skips optional helpers,
# bits2..3 select current/H-only/generic region emission. This module changes
# no default caller. All successful programs retain the final verifier.

def p149p_valid(code: U32) -> Bool:
  U32.is_lt(code,12)

def p149p_enabled(code: U32, bit: U32) -> Bool:
  U32.is_eq(U32.and(code,bit),0)

def p149p_regions(code: U32) -> U32:
  U32.shr(U32.shr(code))

@unsafe
def p149p_inline(code: U32, +boundary: P114SBoundary) -> P114SBoundary:
  nt_choose(P114SBoundary,p149p_enabled(code,1),
    u => p114s_inline(boundary),u => boundary)

@unsafe
def p149p_inline_lowered(code: U32, lowered: P114SLowered) -> P114SLowered:
  match lowered:
    case P114SLowered{boundary,error}: P114SLowered{p149p_inline(code,boundary),error}

@unsafe
def p149p_prepare(code: U32, request: NR_Request, raw: List<&2,P113DCandidate>, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p149p_enabled(code,2),
    u => p128raw_prepare(request,raw,original),
    u => P134Planned{P134Admitted{original}})

@unsafe
def p149p_verified(code: U32, request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p149p_prepare(code,request,raw,original),
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p149p_closed(+code: U32, +request: NR_Request, +raw: List<&2,P113DCandidate>,
    ids: N111Ids, valid: Bool, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error) && valid,
        u => p149p_verified(code,request,raw,program,p146c_verify(program,ids)),
        u => p149p_lowered(code,request,raw,P113ALowered{program,error}))

@unsafe
def p149p_lowered(code: U32, request: NR_Request, raw: List<&2,P113DCandidate>, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p149p_verified(code,request,raw,program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})

@unsafe
def p149p_finish(code: U32, request: NR_Request, certificate: P113ACertificate,
    raw: List<&2,P113DCandidate>, +lowered: P114SLowered) -> P111Emission:
  match lowered:
    case P114SLowered{P114SBoundary{original,ids,functions,valid},error}:
      p149p_closed(code,request,raw,ids,valid,p113a_finish(certificate,p114s_close_lowered(lowered)))

@unsafe
def p149p_session(+code: U32, request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p149p_finish(code,request,certificate,raw,
        p114s_ranges_lowered(p149p_inline_lowered(code,p114s_open_lowered(lowered))))

@unsafe
def p149p_emit_admitted(+code: U32, +request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,p149p_valid(code),
    u => nt_choose(P111Emission,U32.is_eq(U32.and(code,3),0),
      v => p128raw_emit_admitted(request,error),
      v => nt_choose(P111Emission,String.is_empty(error),
        w => p149p_session(code,request,p113a_certificate(request),p128raw_lower_request(request)),
        w => P111Emission{[],"compile: " ++ error})),
    u => P111Emission{[],"invalid optimization policy"})

@unsafe
def p149p_plan(code: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p149p_emit_admitted(code,request,p111_runtime_admission(request))

@unsafe
def p149p_prepared(code: U32, +path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p149p_plan(code,p86_plan(seed,path,source))

@unsafe
def p149p_compile_source(+code: U32, +path: String, +source: String, +base_path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  nt_choose(P111Emission,p149p_valid(code),
    u => p149p_prepared(code,path,source,nt_choose(P86Preparation,cached,
      v => p88_cache_prepare(base_path,base,carrier,stamp),v => p86_prepare(base_path,base))),
    u => P111Emission{[],"invalid optimization policy"})

# Counterarchitecture: a demanded genuine generic family is the sole body IR.
# No p113pl_candidates/p113d_passes or private-body optimization is invoked.
# The empty direct list grants no exemption from independent generic checking.

@unsafe
def p167single_prepared(source: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167l_functions(source,book,names,constructors,nodes,nc_bangs_names(book,names),[]),
        u => p167l_fail("single generic static preparation: " ++ error))

@unsafe
def p167single_catalogued(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p167single_prepared(source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p167single_request(request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167single_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => p167l_fail("single generic request: " ++ error))

# Mode 0 calls the genuine per-segment scalar emitter. Mode 1 intentionally
# retains the inherited p112c registry hidden behind p111q_segment_chunks.
# Both existing lowered-result entries independently check actual final IR.
@unsafe
def p167single_lowered(+mode: U32, +request: NR_Request, +lowered: P167Lowered) -> P111Emission:
  nt_choose(P111Emission,U32.is_eq(mode,0),
    u => p167plain_lowered(request,False{},lowered),
    u => nt_choose(P111Emission,U32.is_eq(mode,1),
      v => p167e_lowered(request,lowered),
      v => P111Emission{[],"single generic mode must be 0 or 1"}))

@unsafe
def p167single_admitted(+mode: U32, +request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p167single_lowered(mode,request,p167single_request(request)),
    u => P111Emission{[],"single generic runtime: " ++ error})

@unsafe
def p167single_mode(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      nt_choose(P111Emission,U32.is_le(mode,1),
        u => p167single_admitted(mode,request,p111_runtime_admission(request)),
        u => P111Emission{[],"single generic mode must be 0 or 1"})

@unsafe
def p167single_plan(plan: P86Plan) -> P111Emission:
  p167single_mode(0,plan)

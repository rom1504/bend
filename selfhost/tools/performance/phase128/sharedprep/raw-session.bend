# Request-local raw candidate reuse. No existing declaration is overridden.
# Keep the exact pre-SCC candidates: the original late closure does not rerun
# SCC conversion and must retain candidates blocked during initial admission.

type P128RawLowering is Data:
  P128RawLowering{+lowered: P113DLowering, +raw: List<&2,P113DCandidate>}

@unsafe
def p128raw_plan_finish(original: P112SResult, +raw: List<&2,P113DCandidate>) -> P128RawLowering:
  P128RawLowering{p113d_finish(original,
    p113d_passes(p126sc_candidates(raw),missing(),[],32)),raw}

@unsafe
def p128raw_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P128RawLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P128RawLowering,String.is_empty(error),u =>
        p128raw_plan_finish(p112s_finish(nodes,p111_finish(source,names,
          p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),
          p113pl_candidates(book,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0))),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})

@unsafe
def p128raw_lower_request(request: NR_Request) -> P128RawLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P128RawLowering,String.is_empty(error),u =>
        p128raw_prepared(source,names,p112s_prepare(book,names,
          nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})

@unsafe
def p128raw_close(raw: List<&2,P113DCandidate>, original: P113AProgram, +added: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      p126bp_complete(static,certificate,
        p113d_passes(raw,p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32))

@unsafe
def p128raw_workers(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      nt_choose(P111Emission,String.is_empty(checked),
        u => nt_choose(P111Emission,p126bp_has_flat(added),
          v => p128raw_close(raw,original,added),v => p118b_compose(original,workers)),
        u => P111Emission{[],"flat observer workers: " ++ checked})

@unsafe
def p128raw_integrated(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error) && p126bp_has_flat(functions),
        u => p128raw_workers(raw,original,workers),u => p118e_emit_workers(original,workers))

@unsafe
def p128raw_borrow(request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p128raw_integrated(raw,original,
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))

@unsafe
def p128raw_permitted(+request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +hot = nh_definitions(book,names,[])
      p128raw_borrow(request,raw,p118e_cold(original,book,source,hot))

@unsafe
def p128raw_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p128raw_permitted(request,raw,original),u =>
        nt_choose(P111Emission,p118i_permission(request),
          v => p128raw_borrow(request,raw,original),v => P111Emission{p113a_admitted_chunks(original),""}))

@unsafe
def p128raw_verified(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p128raw_prepare(request,raw,original),
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p128raw_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p128raw_verified(request,raw,program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})

@unsafe
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p128raw_lowered(request,raw,p113a_finish(certificate,
        p114s_close_lowered(p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered))))))

@unsafe
def p128raw_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u =>
    p128raw_session_finish(request,p113a_certificate(request),p128raw_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})

@unsafe
def p128raw_emit_request(+request: NR_Request) -> P111Emission:
  p128raw_emit_admitted(request,p111_runtime_admission(request))

@unsafe
def p128raw_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{request,verdict}: p128raw_emit_request(request)

@unsafe
def p128raw_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p128raw_emit_plan(p86_plan(seed,path,source))

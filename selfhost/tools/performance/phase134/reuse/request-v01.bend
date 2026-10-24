# Optional complete-request adapter for the isolated memo. All preparation,
# private-worker planning, global admission and final verification stay intact.
# No production entry point is overridden.

type P134URRaw is Data:
  P134URRaw{+raw: P128RawLowering, +slots: List<&2,P134URSlot>, +stats: P134URStats}

type P134UREmission is Data:
  P134UREmission{+emission: P111Emission, +slots: List<&2,P134URSlot>, +stats: P134URStats}

@unsafe
def p134ur_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared, +prior: List<&2,P134URSlot>) -> P134URRaw:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P134URRaw,String.is_empty(error),u =>
        p134ur_prepared_success(source,names,book,nodes,
          p134ur_run(book,names,nc_bangs_names(book,names),0,prior)),
        u => P134URRaw{P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]},[],P134URStats{0,0,0,0,0}})

@unsafe
def p134ur_prepared_success(+source: List<&2,KDef>, +names: List<&2,String>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, cached: P134URResult) -> P134URRaw:
  match cached:
    case P134URResult{compiled,slots,stats}:
      P134URRaw{p128raw_plan_finish(p112s_finish(nodes,p111_finish(source,names,compiled)),
        p113pl_candidates(book,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0))),slots,stats}

@unsafe
def p134ur_lower_request(request: NR_Request, +prior: List<&2,P134URSlot>) -> P134URRaw:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P134URRaw,String.is_empty(error),u =>
        p134ur_prepared(source,names,p112s_prepare(book,names,
          nc_add_ctors(nc_default_ctors(),nc_constructors(source,source))),prior),
        u => P134URRaw{P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]},[],P134URStats{0,0,0,0,0}})

@unsafe
def p134ur_emit_raw(+request: NR_Request, raw: P134URRaw) -> P134UREmission:
  match raw:
    case P134URRaw{lowered,slots,stats}:
      P134UREmission{p128raw_session_finish(request,p113a_certificate(request),lowered),slots,stats}

@unsafe
def p134ur_emit_admitted(+request: NR_Request, +prior: List<&2,P134URSlot>, +error: String) -> P134UREmission:
  nt_choose(P134UREmission,String.is_empty(error),
    u => p134ur_emit_raw(request,p134ur_lower_request(request,prior)),
    u => P134UREmission{P111Emission{[],"compile: " ++ error},[],P134URStats{0,0,0,0,0}})

@unsafe
def p134ur_emit_request(+request: NR_Request, prior: List<&2,P134URSlot>) -> P134UREmission:
  p134ur_emit_admitted(request,prior,p111_runtime_admission(request))

@unsafe
def p134ur_request_inventory(request: NR_Request) -> List<&2,U32>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p134ur_prepared_inventory(names,p112s_prepare(book,names,
        nc_add_ctors(nc_default_ctors(),nc_constructors(source,source))))

@unsafe
def p134ur_prepared_inventory(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,U32>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,U32>,String.is_empty(error),u => p134ur_inventory(book,names,0,0),u => [])

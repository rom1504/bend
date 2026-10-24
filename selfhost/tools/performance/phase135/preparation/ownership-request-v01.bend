type P135COLowering is Data:
  P135COLowering{+session: P128RawLowering, +cache: P135COCache, +hit: Bool}

type P135COEmission is Data:
  P135COEmission{+emission: P111Emission, +cache: P135COCache, +hit: Bool}

@unsafe
def p135co_lower_book(source: List<&2,KDef>, names: List<&2,String>, nodes: List<&2,P112SNode>, error: String, prepared: P135COBook) -> P135COLowering:
  match prepared:
    case P135COBook{book,cache,hit}:
      P135COLowering{p128raw_prepared(source,names,P112SPrepared{book,nodes,error}),cache,hit}

@unsafe
def p135co_prepared(+source: List<&2,KDef>, +names: List<&2,String>, +prior: P135COCache, +prepared: P112SPrepared) -> P135COLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P135COLowering,String.is_empty(error),
        u => p135co_lower_book(source,names,nodes,error,p135co_prepare_book(book,prior)),
        u => P135COLowering{p128raw_prepared(source,names,prepared),p135co_empty(),False{}})

@unsafe
def p135co_lower_request(request: NR_Request, +prior: P135COCache) -> P135COLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P135COLowering,String.is_empty(error),
        u => p135co_prepared(source,names,prior,p112s_prepare(book,names,
          nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P135COLowering{P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]},p135co_empty(),False{}})

@unsafe
def p135co_emitted(request: NR_Request, certificate: P113ACertificate, lower: P135COLowering) -> P135COEmission:
  match lower:
    case P135COLowering{session,cache,hit}:
      P135COEmission{p134e_collect(p128raw_session_finish(request,certificate,session)),cache,hit}

@unsafe
def p135co_emit(+request: NR_Request, +error: String, +prior: P135COCache) -> P135COEmission:
  nt_choose(P135COEmission,String.is_empty(error),
    u => p135co_emitted(request,p113a_certificate(request),p135co_lower_request(request,prior)),
    u => P135COEmission{P111Emission{[],"compile: " ++ error},p135co_empty(),False{}})

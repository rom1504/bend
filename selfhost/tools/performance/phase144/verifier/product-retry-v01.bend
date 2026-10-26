# Isolated diagnostic/prototype. No existing declaration is overridden.
# Reuse mature C's withdrawn-signature policy; retain original QBE workers.
# Final independent verification remains in p128raw_session_finish and emission.

type P144PFTrace is Data:
  P144PFTrace{+before: P128RawLowering, +after: P128RawLowering,
    +withdrawn: List<&2,String>, +attempts: List<&2,P113DCandidate>}

@unsafe
def p144pf_names(functions: List<&2,P113DFunction>) -> List<&2,String>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{name,p144pf_names(rest)}

# Exact source-reference filter from the mature C retry. This does not prove
# candidate readiness: the original dependency closure still decides that.
@unsafe
def p144pf_affected(+book: List<&2,KDef>, +name: String, removed: List<&2,String>) -> Bool:
  nf_retry_refs(nc_refs(nc_compact_definition(book,lookup(book,name),0)),removed)

@unsafe
def p144pf_retry(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>,
    +ready: KDef, +signatures: List<&2,KDef>, +removed: List<&2,String>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) &&
        U32.is_le(nd_arity(book,name),32) &&
        Bool.not(p113d_ready(ready,p113d_public(book,name))),
        u => nt_choose(List<&2,P113DCandidate>,p144pf_affected(book,name,removed),
          v => Con{p113pl_boxed_candidate(book,name,signatures),p144pf_retry(book,rest,bangs,ready,signatures,removed)},
          v => p144pf_retry(book,rest,bangs,ready,signatures,removed)),
        u => p144pf_retry(book,rest,bangs,ready,signatures,removed))

# Keep the original admission order. Do not rerun tail-SCC construction: its
# fresh worker namespace would need a separate global collision contract.
@unsafe
def p144pf_admit(+before: P128RawLowering, original: P112StaticProgram,
    +functions: List<&2,P113DFunction>, raw: List<&2,P113DCandidate>,
    ready: KDef, removed: List<&2,String>, +attempts: List<&2,P113DCandidate>) -> P144PFTrace:
  P144PFTrace{before,
    P128RawLowering{P113DLowered{P113DProgram{original,
      p113d_passes(attempts,ready,nt_reverse(P113DFunction,functions,[]),32)},""},raw},
    removed,attempts}

@unsafe
def p144pf_restricted(+book: List<&2,KDef>, names: List<&2,String>, bangs: List<&2,String>,
    +before: P128RawLowering, original: P112StaticProgram, +functions: List<&2,P113DFunction>,
    raw: List<&2,P113DCandidate>, signatures: List<&2,KDef>, +removed: List<&2,String>) -> P144PFTrace:
  +ready = p113e_signatures(functions,missing())
  p144pf_admit(before,original,functions,raw,ready,removed,
    p144pf_retry(book,names,bangs,ready,book_cached(signatures,0),removed))

@unsafe
def p144pf_removed(+book: List<&2,KDef>, names: List<&2,String>, bangs: List<&2,String>,
    signatures: List<&2,KDef>, +before: P128RawLowering, original: P112StaticProgram,
    functions: List<&2,P113DFunction>, raw: List<&2,P113DCandidate>,
    admitted: List<&2,String>, +removed: List<&2,String>) -> P144PFTrace:
  nt_choose(P144PFTrace,List.is_empty(&2,String,removed),
    u => P144PFTrace{before,before,[],[]},
    u => p144pf_restricted(book,names,bangs,before,original,functions,raw,
      nf_ready_signatures(signatures,admitted),removed))

@unsafe
def p144pf_named(+book: List<&2,KDef>, names: List<&2,String>, bangs: List<&2,String>,
    +signatures: List<&2,KDef>, before: P128RawLowering, original: P112StaticProgram,
    functions: List<&2,P113DFunction>, raw: List<&2,P113DCandidate>, +admitted: List<&2,String>) -> P144PFTrace:
  p144pf_removed(book,names,bangs,signatures,before,original,functions,raw,
    admitted,nf_removed_signatures(signatures,admitted))

@unsafe
def p144pf_ready(+book: List<&2,KDef>, names: List<&2,String>, bangs: List<&2,String>,
    +signatures: List<&2,KDef>, +before: P128RawLowering) -> P144PFTrace:
  match before:
    case P128RawLowering{P113DLowered{P113DProgram{original,+functions},+error},raw}:
      nt_choose(P144PFTrace,Bool.not(String.is_empty(error)),
        u => P144PFTrace{before,before,[],[]},u =>
        p144pf_named(book,names,bangs,signatures,before,original,functions,raw,p144pf_names(functions)))

# Same integrated preparation and generic lowering, evaluated once. The only
# added policy is an ordinary boxed retry after initial QBE dependency closure.
@unsafe
def p144pf_candidates(+source: List<&2,KDef>, +book: List<&2,KDef>, nodes: List<&2,P112SNode>,
    +names: List<&2,String>, constructors: List<&2,N_Constructor>, +bangs: List<&2,String>,
    +signatures: List<&2,KDef>) -> P144PFTrace:
  p144pf_ready(book,names,bangs,signatures,
    p128raw_plan_finish(p112s_finish(nodes,p140or_finish(source,names,constructors,
      p111_compile_defs(book,names,bangs,0,[]))),p113pl_candidates(book,names,bangs,signatures)))

@unsafe
def p144pf_error(error: String) -> P144PFTrace:
  +lowered : P128RawLowering = P128RawLowering{P113DLowered{
    P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]}
  P144PFTrace{lowered,lowered,[],[]}

@unsafe
def p144pf_prepared(source: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P144PFTrace:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(P144PFTrace,String.is_empty(error),
        u => p144pf_candidates(source,book,nodes,names,constructors,nc_bangs_names(book,names),
          book_cached(nq_signatures(book,names),0)),
        u => p144pf_error(error))

@unsafe
def p144pf_catalogued(source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P144PFTrace:
  p144pf_prepared(source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p144pf_probe(request: NR_Request) -> P144PFTrace:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P144PFTrace,String.is_empty(error),
        u => p144pf_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => p144pf_error(error))

@unsafe
def p144pf_after(trace: P144PFTrace) -> P128RawLowering:
  match trace:
    case P144PFTrace{before,after,withdrawn,attempts}: after

@unsafe
def p144pf_lower_request(request: NR_Request) -> P128RawLowering:
  p144pf_after(p144pf_probe(request))

@unsafe
def p144pf_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p128raw_session_finish(request,p113a_certificate(request),p144pf_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})

@unsafe
def p144pf_emit_request(+request: NR_Request) -> P111Emission:
  p144pf_emit_admitted(request,p111_runtime_admission(request))

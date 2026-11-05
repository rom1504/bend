# Additive Phase168 route. Source plans are classified once before raw admission.
# General observers seed admission; real owned scalar fallbacks are retained for
# the unchanged guarded borrowed path. No region registry or late global pipeline.

# Use the maintained bounded inliner only on ordinary admitted bodies. Existing
# general observer seeds stay byte-for-byte and are not inlining-table entries.
@unsafe
def p168_inline(functions: List<&2,P113DFunction>, +seeds: KDef,
    +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p168_inline(rest,seeds,table,Con{head,reversed}),
            u => p168_inline_next(head,rest,seeds,table,reversed,p113i_function(head,table)))

@unsafe
def p168_inline_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    +table: P113ITable, reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p168_inline(rest,seeds,nt_choose(P113ITable,p113i_original_clean(original),
    u => p113i_table_function(function,table),u => table),Con{function,reversed})

# Reuse cached NO_Plans. Only genuine independently checkable leaf fallbacks
# enter p128bs_find; unavailable/nonleaf owners remain for the consumer retry.
@unsafe
def p168_scalars(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    functions: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{+plan,rest}:
      p168_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,p128bs_eligible(book,plan),
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))

@unsafe
def p168_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p168_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})

@unsafe
def p168_stats(lowered: P167Lowered, extra: List<&2,U32>) -> P167Lowered:
  match lowered:
    case P167Lowered{program,adapters,error,stats}:
      P167Lowered{program,adapters,error,nt_append(U32,stats,extra)}

@unsafe
def p168_finished(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, patches: P128BRPatches) -> P167Lowered:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_finish_functions(source,book,names,constructors,nodes,bangs,
          nt_append(U32,stats,[nt_count(P128BRPatch,edits)]),p128br_apply(functions,edits)),
        u => p167l_fail("early scalar consumer retry: " ++ error))

@unsafe
def p168_finish_functions(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_stats(p167l_functions(source,book,names,constructors,nodes,bangs,functions),
    nt_append(U32,stats,[nt_count(P113DFunction,functions)]))

@unsafe
def p168_retry(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>,
    +retry: List<&2,NO_Plan>) -> P167Lowered:
  p168_finished(source,book,names,constructors,nodes,bangs,
    nt_append(U32,stats,[nt_count(P128BRHelper,helpers),nt_count(NO_Plan,retry)]),functions,
    p128br_retry_plans(book,retry,functions,helpers))

@unsafe
def p168_scalar_verified(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, +added: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_retry(source,book,names,constructors,nodes,bangs,
      nt_append(U32,stats,[nt_count(P113DFunction,added)]),
      nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing()))),helpers,retry),
    u => p167l_fail("early scalar closed-worker verification: " ++ error))

@unsafe
def p168_scalar_result(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+added,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scalar_verified(source,book,names,constructors,nodes,bangs,stats,functions,added,helpers,retry,
          p167ob_seed_verify(constructors,added)),
        u => p167l_fail("early scalar production: " ++ error))

@unsafe
def p168_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p168_scalars(book,retry,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))

@unsafe
def p168_closed(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_inlined(source,book,names,constructors,nodes,bangs,
    nt_append(U32,stats,[nt_count(P113DFunction,functions)]),helpers,retry,
    nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,1),
      u => p168_inline(functions,seeds,P113IEmpty{},[]),u => functions))

@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32))

@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,
    p113pl_candidates(book,remaining,bangs,book_cached(nq_signatures(book,names),0)))

@unsafe
def p168_seed_verified(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_selected(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
      p167ob_remaining(book,names,bangs,p113e_signatures(workers,missing()))),
    u => p167l_fail("early scalar observer verification: " ++ error))

@unsafe
def p168_scanned(mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_seed_verified(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
          p167ob_seed_verify(constructors,workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))

@unsafe
def p168_prepared(mode: U32, source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scanned(mode,source,book,names,constructors,nodes,bangs,
          p128br_scan(book,no_candidate_names(book,names,bangs),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p168_request_mode(+mode: U32, +request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,U32.is_gt(mode,1),u => p167l_fail("early scalar mode must be 0 or 1"),u =>
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v => p168_catalogued(mode,source,book,names,nc_add_ctors(nc_default_ctors(),
            p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error)))

@unsafe
def p168_request(request: NR_Request) -> P167Lowered:
  p168_request_mode(0,request)

@unsafe
def p168_admitted(mode: U32, +request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p167ob_lowered(request,p168_request_mode(mode,request)),
    u => P111Emission{[],"early scalar runtime: " ++ error})

@unsafe
def p168_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      nt_choose(P111Emission,U32.is_le(mode,1),
        u => p168_admitted(mode,request,p111_runtime_admission(request)),
        u => P111Emission{[],"early scalar mode must be 0 or 1"})

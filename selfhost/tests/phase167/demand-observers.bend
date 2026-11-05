# General observer-first experiment. Source permission and the unchanged
# source-derived observer/root-retention analysis precede any seeded admission.
# No source name is special-cased, and no fictitious scheduler header is made.

@unsafe
def p167ob_permission(+request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      nt_choose(Bool,ns_definitions(book,names),u => True{},u => p118i_permission(request))

# Private early checking claims no scheduler ABI. Real constructors are checked
# independently; empty FIDs reject any seed needing an unmaterialized identity.
# Source-derived owning wrappers keep their original public marker only while
# selecting exact source/arity substitutions; every final function is private.
@unsafe
def p167ob_seed_checked(+constructors: List<&2,N_Constructor>, +functions: List<&2,P113DFunction>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      +ids : N111Ids = N111Ids{missing(),ns_ctor_index(constructors,missing())}
      nt_choose(String,String.is_empty(error),
        u => p118b_verify_projected(ids,p118b_project_functions(p167l_private(functions),ids)),
        u => error)

@unsafe
def p167ob_seed_verify(+constructors: List<&2,N_Constructor>, functions: List<&2,P113DFunction>) -> String:
  p167ob_seed_checked(constructors,functions,p111v_constructors(constructors,P111VScan{missing(),"",0}))

# Skip a raw source candidate only if the independently checked source worker
# supplies its exact ordinary boxed ABI. Other source names retain old lowering.
@unsafe
def p167ob_remaining(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +ready: KDef) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,p164a_allowed(book,name,bangs,ready),
        u => p167ob_remaining(book,rest,bangs,ready),
        u => Con{name,p167ob_remaining(book,rest,bangs,ready)})

@unsafe
def p167ob_stats(lowered: P167Lowered, selected: U32, +seeds: U32, remaining: U32,
    raw_count: U32, +final_count: U32) -> P167Lowered:
  match lowered:
    case P167Lowered{program,adapters,error,stats}:
      P167Lowered{program,adapters,error,nt_append(U32,stats,
        [selected,seeds,remaining,raw_count,final_count,U32.sub(final_count,seeds)])}

@unsafe
def p167ob_closed(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, seeds: U32, raw_count: U32, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p167ob_stats(p167l_functions(source,book,names,constructors,nodes,bangs,functions),
    U32.sub(nt_count(String,names),remaining),seeds,remaining,raw_count,nt_count(P113DFunction,functions))

@unsafe
def p167ob_candidates(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    remaining: U32, +workers: List<&2,P113DFunction>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  p167ob_closed(source,book,names,constructors,nodes,bangs,remaining,nt_count(P113DFunction,workers),
    nt_count(P113DCandidate,raw),p113d_passes(p126sc_candidates(raw),p113e_signatures(workers,missing()),
      nt_reverse(P113DFunction,workers,[]),32))

@unsafe
def p167ob_selected(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, +remaining: List<&2,String>) -> P167Lowered:
  p167ob_candidates(source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,
    p113pl_candidates(book,remaining,bangs,book_cached(nq_signatures(book,names),0)))

@unsafe
def p167ob_verified_seed(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p167ob_selected(source,book,names,constructors,nodes,bangs,workers,
      p167ob_remaining(book,names,bangs,p113e_signatures(workers,missing()))),
    u => p167l_fail("observer seed verification: " ++ error))

@unsafe
def p167ob_workers(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>, workers: P118BWorkers) -> P167Lowered:
  match workers:
    case P118BWorkers{+functions,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167ob_verified_seed(source,book,names,constructors,nodes,bangs,functions,
          p167ob_seed_verify(constructors,functions)),
        u => p167l_fail("observer worker production: " ++ error))

@unsafe
def p167ob_prepared(source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167ob_workers(source,book,names,constructors,nodes,bangs,
          p118e_workers(book,no_candidate_names(book,names,bangs),[])),
        u => p167l_fail("observer static preparation: " ++ error))

@unsafe
def p167ob_catalogued(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p167ob_prepared(source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p167ob_request(+request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v => p167ob_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
            p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("observer first: source permission refused")),
        u => p167l_fail("observer first request: " ++ error))

# Keep actual generic/static/adapter admission, then use the maintained borrowed
# projection checker on ALL actual final private workers and actual final IDs.
# Projection does not establish source lifetime permission; p167ob_request does.
@unsafe
def p167ob_direct(+program: P113DProgram, +error: String) -> String:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},+functions}:
      nt_choose(String,String.is_empty(error),u =>
        nt_choose(String,p167v_private(functions),
          v => p118b_verify_functions(functions,original),
          v => "observer first final worker must be private"),u => error)

@unsafe
def p167ob_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, +program: P113DProgram) -> String:
  p167ob_direct(program,p167v_original(book,bangs,program,adapters))

@unsafe
def p167ob_emitted(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p167plain_chunks(program,True{}),""},
    u => P111Emission{[],"observer first final IR: " ++ error})

@unsafe
def p167ob_lowered(request: NR_Request, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p167ob_emitted(program,p167ob_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"observer first lowering: " ++ error})

@unsafe
def p167ob_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p167ob_lowered(request,p167ob_request(request)),
    u => P111Emission{[],"observer first runtime: " ++ error})

@unsafe
def p167ob_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      nt_choose(P111Emission,U32.is_eq(mode,0),
        u => p167ob_admitted(request,p111_runtime_admission(request)),
        u => P111Emission{[],"observer first mode must be 0 (plain plus checked live)"})

# Finite import-contract controls only; malformed pointer bodies are never run.
def p167ob_control_worker(constructor: String, count: U32) -> P113DFunction:
  P113DFunction{"borrow.control",[NC_Binding{0,"root",N_W64{}}],1,False{},[
    P113DScalar{N111Call{"borrowed",N111U64{},"p118_rt_borrow_fields",[
      N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U64{},N111Local{"root"}},
      N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111CtorId{constructor}},
      N111Arg{N111U32{},N111Const{count,0}}]}},P113DResult{[N111Local{"borrowed"}]}]}

@unsafe
def p167ob_controls() -> List<&2,String>:
  +ctors : List<&2,N_Constructor> = [N_Constructor{"Pair",2,True{}}]
  [p167c_row("observer-seed-valid-projection",String.is_empty(p167ob_seed_verify(ctors,[p167ob_control_worker("Pair",2)]))),
   p167c_row("observer-seed-count-refused",Bool.not(String.is_empty(p167ob_seed_verify(ctors,[p167ob_control_worker("Pair",3)])))),
   p167c_row("observer-seed-unknown-ctor-refused",Bool.not(String.is_empty(p167ob_seed_verify(ctors,[p167ob_control_worker("Unknown",2)])))),
   p167c_row("observer-seed-duplicate-ctor-refused",Bool.not(String.is_empty(p167ob_seed_verify(
     [N_Constructor{"Pair",2,True{}},N_Constructor{"Pair",2,True{}}],[p167ob_control_worker("Pair",2)])))),
   p167c_row("observer-final-missing-worker-refused",Bool.not(String.is_empty(p167ob_final(
     p167c_book(),[],p167c_adapters(),p167c_program([p167c_segment()],[],[],[])))))]

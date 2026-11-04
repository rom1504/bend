# Phase156 isolated actual-checker overlay. Exactly two maintained declarations
# are replaced below: p143cp_seed_ready and p143cb_resume_state.
# dirty=False means the current book equals its original canonical projection.
# Start conservatively True; ordinary checking preserves established cleanliness.
# Original checking, guards, suffix schedule, failure translation and final
# p143cp_result canonicalization remain untouched. No KWorld layout change.

@unsafe
def p156cp_continue(rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    world: KWorld, dirty: Bool) -> DChecking:
  p156cp_walk(rest,world,book_put(seen,definition),dirty)

@unsafe
def p156cp_stored(rest: List<&2,P143CEvent>, seen: List<&2,KDef>, +definition: KDef,
    term: KTerm, world: KWorld, book: List<&2,KDef>, dirty: Bool) -> DChecking:
  p156cp_continue(rest,seen,definition,
    kw_put_checked(kw_with_book(world,book),dg_event_output(definition,term)),dirty)

@unsafe
def p156cp_put(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match book:
    case Nil{}: p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),False{})
    case Con{+cache,+tail}:
      nt_choose(DChecking,p88_string_eq(dk(cache),"BookCache") &&
        p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
        u => p156cp_stored(rest,seen,definition,term,world,p143cp_logged(cache,tail,definition),True{}),
        u => p156cp_stored(rest,seen,definition,term,world,
          book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{}))

@unsafe
def p156cp_publish(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +result: KChecking, +dirty: Bool) -> DChecking:
  nt_choose(DChecking,p88_string_eq(dk(next),"Absent"),
    u => p156cp_put(rest,seen,definition,ct(result),rw(result),kw_book(rw(result)),dirty),
    u => p156cp_continue(rest,seen,definition,rw(result),dirty))

@unsafe
def p156cp_next(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +dirty: Bool, +result: KChecking) -> DChecking:
  nt_choose(DChecking,good(result),
    u => p156cp_publish(rest,seen,definition,next,result,dirty),
    u => dg_event_failed(result,dn(definition)))

@unsafe
def p156cp_guard(+rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>,
    +definition: KDef, +next: KDef, +dirty: Bool, +guard: String) -> DChecking:
  nt_choose(DChecking,p88_string_eq(guard,""),
    u => p156cp_next(rest,seen,definition,next,dirty,
      check_definition_world(world,p143cs_mode(definition,next),0)),
    u => DChecking{bad(world,dn(definition) ++ ": " ++ guard),dg_no_report(dn(definition),guard)})

@unsafe
def p156cp_walk(events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match events:
    case Nil{}: DChecking{bad(world,""),dg_no_report("","")}
    case Con{P143CEvent{+definition,+next},+rest}:
      p156cp_guard(rest,world,seen,definition,next,dirty,
        event_error(seen,definition,lookup(seen,dn(definition))))

# Starting dirty conservatively avoids trusting arbitrary initial raw ordering.
# False logging keeps the complete original loop, without extra candidate work.
@unsafe
def p156cp_start(+events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, logging: Bool) -> DChecking:
  nt_choose(DChecking,logging,
    u => p156cp_walk(events,world,seen,True{}),
    u => p143cp_walk(events,world,seen,False{}))

# Exact original initializers retained as independent reference exports. They
# still execute the original scheduled checker loop, including repeated canon.
@unsafe
def p156cp_reference_seed_ready(+book: List<&2,KDef>, bound: U32, +logging: Bool, +seed: List<&2,KDef>) -> DChecking:
  p143cp_result(p143cp_walk(p143cs_plan(book),
    kw_seed(check_declarations(book,seed),bound),seed,logging),logging)

@unsafe
def p156cp_reference_seed(+book: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  nt_choose(DChecking,p143cp_regular(book),
    u => p156cp_reference_seed_ready(book,bound,logging,book_cached([],bound)),
    u => dg_check_seed(book,bound))

@unsafe
def p156cp_reference_check(+book: List<&2,KDef>, logging: Bool) -> DChecking:
  p156cp_reference_seed(book,norm_max_book(book),logging)

@unsafe
def p156cp_reference_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p143cp_walk(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)

@unsafe
def p156cp_reference_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>,
    +bound: U32, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      nt_choose(DChecking,p143cp_regular(suffix) && base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
        u => p156cp_reference_resume_state(state,saved,checked,seen,suffix,bound,logging),
        u => base_prefix_world_check_admitted(prepared,prefix,suffix,bound))

@unsafe
def p156cp_reference_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DChecking,ready && String.is_empty(error) && base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => p156cp_reference_admitted(prepared,prefix,suffix,bound,logging),
        u => dg_check_world(book))

@unsafe
def p156cp_reference_load(+prepared: KBasePreparedWorld, load: FPrefixLoad, +logging: Bool) -> DChecking:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}: p156cp_reference_book(prepared,book,error,prefix,suffix,ready,logging)

# Replacement 1; signature and every entry/finalization operation are unchanged.
@unsafe
def p143cp_seed_ready(+book: List<&2,KDef>, bound: U32, +logging: Bool, +seed: List<&2,KDef>) -> DChecking:
  p143cp_result(p156cp_start(p143cs_plan(book),
    kw_seed(check_declarations(book,seed),bound),seed,logging),logging)

# Replacement 2; retain Base ordering, bounds, fresh state, checked bodies and
# the caller's existing prepared-world/hash-disjoint admission unchanged.
@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p156cp_start(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)

# Load-only copies of p86_plan's unchanged ancestor chain. Stop before checking,
# ownership, annotation and erasure; external IO provides exact Base/source text.
type P156CLoadResult is Data:
  P156CLoadError{+error: String}
  P156CLoadReady{+load: FPrefixLoad}

@unsafe
def p156cp_loaded(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P156CLoadResult:
  match seed completion:
    case P86Seed{+base,book,+fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      P156CLoadReady{f_prefix_graph_trace(carrier,[source,base],fresh)}

@unsafe
def p156cp_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P156CLoadResult:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      match parsed:
        case FResult{defs,+error,imports}:
          kc(P156CLoadResult,String.is_empty(error),
            u => p156cp_loaded(seed,source,f_prefix_complete_source(source,"",header,[source,base],carrier,f_path_dir(f_source_path(source)))),
            u => P156CLoadError{"parse: " ++ error})

@unsafe
def p156cp_load_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P156CLoadResult:
  match seed:
    case P86Seed{+base,+book,fresh,+ready,world}:
      p156cp_seeded(seed,source,header,
        f_prefix_complete_ready_seed(base,"",f_prefix_graph_empty(),f_source_path(base),f_source_text(base),book,ready))

@unsafe
def p156cp_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P156CLoadResult:
  kc(P156CLoadResult,String.is_empty(error),u => p156cp_load_seed(seed,source,header),u => P156CLoadError{"load: " ++ error})

@unsafe
def p156cp_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P156CLoadResult:
  match header:
    case FHeader{imports,+error,body,line,offset}:
      kc(P156CLoadResult,String.is_empty(error),
        u => p156cp_imported(seed,source,header,p86_import_error(imports,False{})),
        u => P156CLoadError{"parse: " ++ error})

@unsafe
def p156cp_load(+seed: P86Seed, +path: String, +text: String) -> P156CLoadResult:
  match seed:
    case P86Seed{+base,book,fresh,ready,world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path,path,text},begin,U32.add(U32.add(begin,p86_width(text,0)),1))
      p156cp_header(seed,source,f_source_header(source))

@unsafe
def p156cp_enabled(load: FPrefixLoad) -> Bool:
  match load:
    case FPrefixLoad{trace,prefix,suffix,eligible}: p143cg_enough(suffix,256)

# Caller first requires P156CLoadReady and an empty trace.result.error, exactly
# the parse guard in p86_plan_loaded. Selection then mirrors its unchanged gate.
@unsafe
def p156cp_route(+prepared: KBasePreparedWorld, +load: FPrefixLoad, changed: Bool) -> DChecking:
  nt_choose(DChecking,p156cp_enabled(load),
    u => nt_choose(DChecking,changed,u => p143cb_check_load(prepared,load,True{}),u => p156cp_reference_load(prepared,load,True{})),
    u => base_prefix_check_world_load(prepared,load))

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

@unsafe
def p156cp_start(+events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, logging: Bool) -> DChecking:
  nt_choose(DChecking,logging,
    u => p156cp_walk(events,world,seen,True{}),
    u => p143cp_walk(events,world,seen,False{}))

@unsafe
def p143cp_seed_ready(+book: List<&2,KDef>, bound: U32, +logging: Bool, +seed: List<&2,KDef>) -> DChecking:
  p143cp_result(p156cp_start(p143cs_plan(book),
    kw_seed(check_declarations(book,seed),bound),seed,logging),logging)

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



@unsafe
def p143cs_build(todo: List<&2,KDef>) -> P143CSchedule:
  match todo:
    case Nil{}: P143CSchedule{missing(),[]}
    case Con{head,rest}: p143cs_step(head,p143cs_build(rest))


@unsafe
def p143cs_step(+head: KDef, tail: P143CSchedule) -> P143CSchedule:
  match tail:
    case P143CSchedule{+index,events}:
      +next = index_find(index,dn(head),index_hash(dn(head),2166136261),32)
      P143CSchedule{
        nt_choose(KDef,p88_string_eq(dk(head),"BookCache"),
          u => index_first(dc(head)),
          u => index_set(index,head,index_hash(dn(head),2166136261),32)),
        Con{P143CEvent{head,next},events}}


@unsafe
def p143cs_plan(todo: List<&2,KDef>) -> List<&2,P143CEvent>:
  p143cs_events(p143cs_build(todo))


def p143cs_events(plan: P143CSchedule) -> List<&2,P143CEvent>:
  match plan:
    case P143CSchedule{index,events}: events


@unsafe
def p143cs_mode(+definition: KDef, next: KDef) -> KDef:
  nt_choose(KDef,p88_string_eq(dk(definition),"Def") && p98_tag_eq(dv(definition),"Absent"),
    u => signature_fill_mode(definition,next),u => definition)

@unsafe
def p143cp_canon(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(head),"BookCache"),
        u => Con{head,book_final_fast(List.reverse(&2,KDef,rest),[])},
        u => book_final_fast(List.reverse(&2,KDef,Con{head,rest}),[]))


@unsafe
def p143cp_childless(+definition: KDef) -> Bool:
  p88_string_eq(dk(definition),"Def") && defs_empty(dc(definition))


@unsafe
def p143cp_put(+book: List<&2,KDef>, +definition: KDef, +logging: Bool) -> List<&2,KDef>:
  nt_choose(List<&2,KDef>,logging,
    u => p143cp_put_log(book,definition),u => book_put(book,definition))


@unsafe
def p143cp_put_log(+book: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: book_put(book,definition)
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache") &&
        p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
        u => p143cp_logged(cache,rest,definition),
        u => book_put(p143cp_canon(book),definition))


@unsafe
def p143cp_logged(+cache: KDef, rest: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
    [index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32)],
    True{},False{}},Con{definition,rest}}


@unsafe
def p143cp_world(world: KWorld) -> KWorld:
  match world:
    case KWorld{book,memo,fresh,checked}: KWorld{p143cp_canon(book),memo,fresh,checked}


@unsafe
def p143cp_result(checked: DChecking, logging: Bool) -> DChecking:
  match checked logging:
    case DChecking{KChecking{term,typ,uses,error,world,consumed},diagnostic} True{}:
      DChecking{KChecking{term,typ,uses,error,p143cp_world(world),consumed},diagnostic}
    case result False{}: result


@unsafe
def p143cp_walk(events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +logging: Bool) -> DChecking:
  match events:
    case Nil{}: DChecking{bad(world,""),dg_no_report("","")}
    case Con{P143CEvent{+definition,+next},+rest}:
      p143cp_guard(rest,world,seen,definition,next,logging,
        event_error(seen,definition,lookup(seen,dn(definition))))


@unsafe
def p143cp_guard(+rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>,
    +definition: KDef, +next: KDef, +logging: Bool, +guard: String) -> DChecking:
  nt_choose(DChecking,p88_string_eq(guard,""),
    u => p143cp_next(rest,seen,definition,next,logging,
      check_definition_world(world,p143cs_mode(definition,next),0)),
    u => DChecking{bad(world,dn(definition) ++ ": " ++ guard),dg_no_report(dn(definition),guard)})


@unsafe
def p143cp_next(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +logging: Bool, +result: KChecking) -> DChecking:
  nt_choose(DChecking,good(result),
    u => p143cp_walk(rest,p143cp_publish(definition,next,result,logging),book_put(seen,definition),logging),
    u => dg_event_failed(result,dn(definition)))


@unsafe
def p143cp_publish(+definition: KDef, next: KDef, +result: KChecking, logging: Bool) -> KWorld:
  nt_choose(KWorld,p88_string_eq(dk(next),"Absent"),
    u => kw_put_checked(kw_with_book(rw(result),p143cp_put(kw_book(rw(result)),definition,logging)),
      dg_event_output(definition,ct(result))),
    u => rw(result))

# Source events are normal KDefs, not implementation cache/index records. This
# also keeps initial materialization semantics explicit for arbitrary API tests.

@unsafe
def p143cp_regular(todo: List<&2,KDef>) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{KDef{name,+kind,arity,templates,typ,value,ctors,native,unsafe},rest}:
      Bool.not(p88_string_eq(kind,"BookCache")) && p143cp_regular(rest)
    case Con{other,rest}: False{}


@unsafe
def p143cp_seed(+book: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  nt_choose(DChecking,p143cp_regular(book),
    u => p143cp_seed_ready(book,bound,logging,book_cached([],bound)),
    u => dg_check_seed(book,bound))


@unsafe
def p143cp_seed_ready(+book: List<&2,KDef>, bound: U32, +logging: Bool, +seed: List<&2,KDef>) -> DChecking:
  p143cp_result(p143cp_walk(p143cs_plan(book),
    kw_seed(check_declarations(book,seed),bound),seed,logging),logging)


@unsafe
def p143cp_check(+book: List<&2,KDef>, logging: Bool) -> DChecking:
  p143cp_seed(book,norm_max_book(book),logging)

# Publication-only ceiling: callers provide the real declaration/publication
# stream. It includes canonicalization, index updates and dropped intermediates.

@unsafe
def p143cp_replay(+book: List<&2,KDef>, updates: List<&2,KDef>, +logging: Bool) -> List<&2,KDef>:
  match updates:
    case Nil{}: nt_choose(List<&2,KDef>,logging,u => p143cp_canon(book),u => book)
    case Con{definition,rest}: p143cp_replay(p143cp_put(book,definition,logging),rest,logging)


@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p156cp_start(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)


@unsafe
def p143cb_resume(prepared: KBasePreparedWorld, suffix: List<&2,KDef>, bound: U32, logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,prefix,final,book,checked,seen,todos,checkedBound}:
      p143cb_resume_state(state,book,checked,seen,suffix,bound,logging)


@unsafe
def p143cb_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>,
    +bound: U32, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      nt_choose(DChecking,p143cp_regular(suffix) &&
        base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
        u => p143cb_resume(prepared,suffix,bound,logging),
        u => base_prefix_world_check_admitted(prepared,prefix,suffix,bound))


@unsafe
def p143cb_check_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DChecking,ready && String.is_empty(error) &&
        base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => p143cb_admitted(prepared,prefix,suffix,bound,logging),
        u => dg_check_world(book))


@unsafe
def p143cb_check_load(+prepared: KBasePreparedWorld, load: FPrefixLoad, +logging: Bool) -> DChecking:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p143cb_check_book(prepared,book,error,prefix,suffix,ready,logging)


@unsafe
def p143cb_program_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool,
    +origins: List<&2,DOrigin>, +logging: Bool) -> DResult:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DResult,ready && String.is_empty(error) &&
        base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => driver_program_checked_prefix(suffix,todos,origins,
          p143cb_admitted(prepared,prefix,suffix,bound,logging)),
        u => driver_program_checked(book,origins,dg_check_world(book)))


@unsafe
def p143cb_program(load: FPrefixLoad, +origins: List<&2,DOrigin>, +prepared: KBasePreparedWorld,
    +logging: Bool) -> DResult:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p143cb_program_book(prepared,book,error,prefix,suffix,ready,origins,logging)

# This optional private planner boundary reproduces p86_plan_loaded. A future
# qualified hook can delegate only that one entry here; dg_check_events and the
# original prepared-Base checker remain independent reference implementations.

@unsafe
def p143cb_plan_loaded(+seed: P86Seed, +load: FPrefixLoad, +logging: Bool) -> P86Plan:
  match seed load:
    case P86Seed{base,book,fresh,ready,+world} FPrefixLoad{trace,prefix,suffix,eligible}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{+original,+error,imports}:
              nt_choose(P86Plan,String.is_empty(error),
                u => p86_plan_checked(load,world,original,p143cb_program(load,[],world,logging)),
                u => P86PlanError{"parse: " ++ error})

@unsafe
def p143cg_enough(definitions: List<&2,KDef>, left: U32) -> Bool:
  match definitions left:
    case _ 0: True{}
    case Nil{} _: False{}
    case Con{definition,rest} +n:
      p143cg_enough(rest,nt_choose(U32,p143cp_childless(definition),
        u => U32.sub(n,1),u => n))

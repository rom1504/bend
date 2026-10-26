# Experimental private checker loop. Original check/infer/normalization bodies
# are unchanged. The only delayed rows are childless Def replacements.
# Entry creates its own canonical cached world; internal workers are not an API
# admitting arbitrary caller-supplied BookCache/index pairs.

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

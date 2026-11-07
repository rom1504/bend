
law p171s_put:
  for +seen: List<&2,KDef>
  for +definition: KDef
  List<&2,KDef>

# These are the only two maintained declarations overridden in the experiment.
@unsafe
def p156cp_continue(rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    world: KWorld, dirty: Bool) -> DChecking:
  p156cp_walk(rest,world,p171s_put(seen,definition),dirty)



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
# Inserted immediately before the first replacement's lexical use.
law p171s_seed:
  for +seen: List<&2,KDef>
  List<&2,KDef>

@unsafe
def p156cp_start(+events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, logging: Bool) -> DChecking:
  nt_choose(DChecking,logging,
    u => p156cp_walk(events,world,p171s_seed(seen),True{}),
    u => p143cp_walk(events,world,seen,False{}))
# Experimental private event-history representation, not a public Book change.
# p156cp's `seen` is observed only by lookup, compare and constructor_names.
# Keep its authoritative index/bound, but retain raw rows only when they carry
# constructors. The published/checking KWorld and its ordered book are unchanged.
# A raw public book remains on the original path until a real cache is present.

@unsafe
def p171s_constructor_rows(rows: List<&2,KDef>) -> List<&2,KDef>:
  match rows:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,KDef>,defs_empty(dc(head)),
        u => p171s_constructor_rows(rest),u => Con{head,p171s_constructor_rows(rest)})

@unsafe
def p171s_seed(seen):
  match seen:
    case Nil{}: seen
    case Con{+cache,tail}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{cache,p171s_constructor_rows(tail)},u => seen)

@unsafe
def p171s_cached(+cache: KDef, +rows: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  +rest = index_put_rest(cache,rows,dn(definition))
  Con{KDef{dn(cache),dk(cache),da(cache),0,atom("Absent"),atom("Absent"),
    [index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32)],True{},False{}},
    nt_choose(List<&2,KDef>,defs_empty(dc(definition)),u => rest,u => Con{definition,rest})}

@unsafe
def p171s_put(seen,definition):
  match seen:
    case Nil{}: book_put(seen,definition)
    case Con{+cache,+rows}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => p171s_cached(cache,rows,definition),u => book_put(seen,definition))

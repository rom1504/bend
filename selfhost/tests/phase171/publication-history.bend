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

# These are the only two maintained declarations overridden in the experiment.
@unsafe
def p156cp_continue(rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    world: KWorld, dirty: Bool) -> DChecking:
  p156cp_walk(rest,world,p171s_put(seen,definition),dirty)

@unsafe
def p156cp_start(+events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, logging: Bool) -> DChecking:
  nt_choose(DChecking,logging,
    u => p156cp_walk(events,world,p171s_seed(seen),True{}),
    u => p143cp_walk(events,world,seen,False{}))

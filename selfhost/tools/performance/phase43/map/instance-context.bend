# Request-local contextual rows. These are not source definitions and never
# participate in ordinary lookup/exact_def. Each row retains its source Def.
type JInstances is Data:
  JInstances{+rows: List<&2,KDef>, +sources: List<&2,KDef>, +fuel: U32, +valid: Bool}

@unsafe
def j_instances_rows(+s: JInstances) -> List<&2,KDef>:
  match s:
    case JInstances{rows, sources, fuel, valid}: rows

@unsafe
def j_instances_sources(+s: JInstances) -> List<&2,KDef>:
  match s:
    case JInstances{rows, sources, fuel, valid}: sources

@unsafe
def j_instances_fuel(+s: JInstances) -> U32:
  match s:
    case JInstances{rows, sources, fuel, valid}: fuel

@unsafe
def j_instances_valid(+s: JInstances) -> Bool:
  match s:
    case JInstances{rows, sources, fuel, valid}: valid

@unsafe
def j_instances_fail(+s: JInstances) -> JInstances:
  JInstances{j_instances_rows(s), j_instances_sources(s), 0, False{}}

@unsafe
def j_instances_has(+rows: List<&2,KDef>, +fact: KDef) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{h, rest}: j_erased_instance_same(h, fact) || j_instances_has(rest, fact)

@unsafe
def j_instances_source_has(+ds: List<&2,KDef>, +d: KDef) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{h, rest}: exact_def(h, d) || j_instances_source_has(rest, d)

@unsafe
def j_instances_collect(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +s: JInstances) -> JInstances:
  match todo:
    case Nil{}: s
    case Con{t, rest}:
      kc(JInstances, j_instances_valid(s) && U32.is_gt(j_instances_fuel(s), 0), u =>
        j_instances_node(book, t, rest, JInstances{j_instances_rows(s), j_instances_sources(s), U32.sub(j_instances_fuel(s), 1), True{}}), u => j_instances_fail(s))

@unsafe
def j_instances_node(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +s: JInstances) -> JInstances:
  kc(JInstances, String.eq(tg(t), "Ann"), u => j_instances_collect(book, Con{kid(t, 0), rest}, s), u =>
    kc(JInstances, String.eq(tg(t), "App"), u => j_instances_call(book, j_call_spine(t, Nil{}), rest, s), u =>
      j_instances_collect(book, List.append(&2,KTerm, ks(t), rest), s)))

@unsafe
def j_instances_call(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +s: JInstances) -> JInstances:
  +d = lookup(book, nm(spine))
  +head = wnf(book, dt(d))
  kc(JInstances, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)) && U32.is_le(da(d), 32), u =>
    kc(JInstances, String.eq(tg(head), "All") && U32.is_eq(qt(head), 0), u =>
      j_instances_fact(book, spine, rest, s, j_erased_instance(book, Nil{}, spine)), u =>
      kc(JInstances, db(d) || j_instances_source_has(j_instances_sources(s), d), u =>
        j_instances_collect(book, List.append(&2,KTerm, ks(spine), rest), s), u =>
        kc(JInstances, j_pure_signature(book, dt(d), da(d)) && U32.is_lt(j_region_def_count(j_instances_sources(s)), 64), u =>
          j_instances_collect(book, Con{dv(d), List.append(&2,KTerm, ks(spine), rest)},
            JInstances{j_instances_rows(s), Con{d, j_instances_sources(s)}, j_instances_fuel(s), True{}}), u => j_instances_fail(s)))), u => j_instances_fail(s))

@unsafe
def j_instances_fact(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +s: JInstances, +r: Maybe<&2,KDef>) -> JInstances:
  match r:
    case None{}: j_instances_fail(s)
    case Some{fact}:
      kc(JInstances, j_instances_has(j_instances_rows(s), fact), u =>
        j_instances_collect(book, List.append(&2,KTerm, ks(spine), rest), s), u =>
        kc(JInstances, U32.is_lt(j_region_def_count(j_instances_rows(s)), 32), u =>
          j_instances_collect(book, Con{dv(fact), List.append(&2,KTerm, ks(spine), rest)},
            JInstances{Con{fact, j_instances_rows(s)}, j_instances_sources(s), j_instances_fuel(s), True{}}), u => j_instances_fail(s)))

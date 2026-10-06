# Shared tail-call facts for the direct emitter. Analyze only the current
# function's returned computation: constructing a closure does not execute it.
# Exhausted traversal or an absent emitted target rejects the entire plan.
type JDCallScan is Data:
  JDCallScan{+edges: List<&2,KTerm>, +unknown: Bool, +fuel: U32, +valid: Bool}

type JDCallGraph is Data:
  JDCallGraph{+forward: KDef, +reverse: KDef, +seeds: List<&2,KTerm>}

type JDCallGroups is Data:
  JDCallGroups{+index: KDef, +keys: List<&2,KTerm>}

@unsafe
def jd_calls_bad(+s: JDCallScan) -> JDCallScan:
  match s:
    case JDCallScan{edges, unknown, fuel, valid}: JDCallScan{edges, unknown, fuel, False{}}

@unsafe
def jd_calls_edge(+s: JDCallScan, +name: String) -> JDCallScan:
  match s:
    case JDCallScan{edges, unknown, fuel, valid}: JDCallScan{Con{kt("Ref", name, 0, 0, Nil{}), edges}, unknown, fuel, valid}

@unsafe
def jd_calls_unknown(+s: JDCallScan) -> JDCallScan:
  match s:
    case JDCallScan{edges, unknown, fuel, valid}: JDCallScan{edges, True{}, fuel, valid}

@unsafe
def jd_calls_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: U32, +s: JDCallScan) -> JDCallScan:
  match s:
    case JDCallScan{edges, unknown, fuel, valid}:
      kc(JDCallScan, valid && U32.is_gt(fuel, 0),
        u => jd_calls_node(book, env, t, ty, args, JDCallScan{edges, unknown, U32.sub(fuel, 1), valid}),
        u => JDCallScan{edges, unknown, fuel, False{}})

@unsafe
def jd_calls_node(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(t), "Ann"), u => jd_calls_body(book, env, kid(t, 0), kid(t, 1), args, s), u =>
  kc(JDCallScan, String.eq(tg(t), "Rwt"), u => jd_calls_body(book, env, kid(t, 2), ty, args, s), u =>
  kc(JDCallScan, String.eq(tg(t), "Let"), u => jd_calls_body(book, j_context(book, env, ks(t)), j_body(ks(t)), ty, args, s), u =>
  kc(JDCallScan, String.eq(tg(t), "Lam"), u => jd_calls_lambda(book, env, t, wnf(book, ty), args, s), u =>
  kc(JDCallScan, String.eq(tg(t), "Mat"), u => kc(JDCallScan, U32.is_eq(args, 0), v => s,
    v => jd_calls_match(book, env, t, wnf(book, ty), args, s)), u =>
  kc(JDCallScan, String.eq(tg(t), "Efq"), u => s, u =>
  kc(JDCallScan, U32.is_gt(args, 0), u => jd_calls_unknown(s), u =>
  kc(JDCallScan, String.eq(tg(t), "App") || String.eq(tg(t), "Ref"),
    u => jd_calls_application(book, env, t, j_call_spine(t, Nil{}), s), u => s))))))))

@unsafe
def jd_calls_lambda(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(ty), "All"), u =>
    kc(JDCallScan, U32.is_eq(qt(ty), 0) || U32.is_gt(args, 0), v =>
      jd_calls_body(book, jd_bind_env(env, ix(t), kid(ty, 0)), kid(t, 0),
        j_app_type(ty, var(nm(t), ix(t))), kc(U32, U32.is_eq(qt(ty), 0), w => args, w => U32.sub(args, 1)), s),
      v => s), u => jd_calls_bad(s))

@unsafe
def jd_calls_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)),
    u => jd_calls_match_type(book, env, t, ty, wnf(book, kid(ty, 0)), args, s), u => jd_calls_bad(s))

@unsafe
def jd_calls_match_type(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +args: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(domain), "ADT"), u =>
    jd_calls_match_ctor(book, env, t, ty, domain, args, s, j_layout_ctor(book, domain, nm(t))), u => jd_calls_bad(s))

@unsafe
def jd_calls_match_ctor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +args: U32, +s: JDCallScan, +ctor: KDef) -> JDCallScan:
  kc(JDCallScan, String.eq(dk(ctor), "Ctr"), u =>
    jd_calls_match_tel(book, env, t, ty, domain, args, s, j_specialize(book, dt(ctor), ks(domain))), u => jd_calls_bad(s))

@unsafe
def jd_calls_match_tel(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +args: U32, +s: JDCallScan, +tel: KTerm) -> JDCallScan:
  kc(JDCallScan, jd_native_layout(book, domain) && String.eq(nm(domain), "Nat"), u =>
    jd_calls_word_rows(book, env, U32.sub(args, 1), s, jd_nat_rows(book, t, ty, 0)),
    u => jd_calls_match_other(book, env, t, ty, domain, args, s, tel))

@unsafe
def jd_calls_match_other(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +args: U32, +s: JDCallScan, +tel: KTerm) -> JDCallScan:
  +arm = kc(JDCallScan, jd_native_layout(book, domain) &&
    (String.eq(nm(domain), "U32") || String.eq(nm(domain), "F32")) && j_u32_native_book(book),
    u => jd_calls_word_rows(book, env, U32.sub(args, 1), s,
      jd_word_rows(book, j_strip(kid(t, 0)), j_arm_tel(book, tel, kid(ty, 1)), 0, 0,
        JDWordCover{atom("Absent"), 0, Nil{}})),
    u => jd_calls_match_arm(book, env, kid(t, 0), j_arm_tel(book, tel, kid(ty, 1)),
      U32.sub(args, 1), jd_calls_fields(tel, 64), s))
  kc(JDCallScan, U32.is_eq(j_constructor_count(book, domain), 1) ||
    (jd_native_layout(book, domain) && String.eq(jd_match_test(nm(domain), nm(t), "x"), "")),
    u => arm, u => jd_calls_body(book, env, kid(t, 1), ty, args, arm))

@unsafe
def jd_calls_match_arm(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +rest: U32, +fields: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, U32.is_lt(fields, 65),
    u => jd_calls_body(book, env, t, ty, U32.add(rest, fields), s), u => jd_calls_bad(s))

@unsafe
def jd_calls_fields(+tel: KTerm, +fuel: U32) -> U32:
  kc(U32, String.eq(tg(tel), "All"), u => kc(U32, U32.is_gt(fuel, 0), v =>
    U32.add(kc(U32, U32.is_eq(qt(tel), 0), w => 0, w => 1), jd_calls_fields(kid(tel, 1), U32.sub(fuel, 1))),
    v => 65536), u => 0)

# Consume exactly the rows emitted by the numeric matcher. Rewalking the
# source bit tree would retain discarded inherited defaults and could invent
# a bounce edge (and observable run_loop demand) absent from the generated body.
@unsafe
def jd_calls_word_rows(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: U32,
  +s: JDCallScan, +rows: List<&2,JDWordRow>) -> JDCallScan:
  match rows:
    case Nil{}: s
    case Con{row, more}: jd_calls_word_row(book, env, rest, s, row, more)

@unsafe
def jd_calls_word_row(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: U32,
  +s: JDCallScan, +row: JDWordRow, +more: List<&2,JDWordRow>) -> JDCallScan:
  match row:
    case JDWordRow{term, typ, depth, value, fields}:
      jd_calls_word_rows(book, env, rest,
        jd_calls_body(book, env, term, typ, U32.add(fields, rest), s), more)

@unsafe
def jd_calls_application(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +spine: KTerm, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(spine), "Call"),
    u => jd_calls_named(book, lookup(book, nm(spine)), ks(spine), s), u =>
    kc(JDCallScan, String.eq(tg(t), "App"), u =>
      jd_calls_unknown_type(wnf(book, j_type(book, env, kid(t, 0))), s), u => jd_calls_bad(s)))

@unsafe
def jd_calls_unknown_type(+ty: KTerm, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(ty), "All"), u =>
    kc(JDCallScan, U32.is_eq(qt(ty), 0), v => s, v => jd_calls_unknown(s)), u => jd_calls_bad(s))

@unsafe
def jd_calls_named(+book: List<&2,KDef>, +d: KDef, +xs: List<&2,KTerm>, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(dk(d), "ADT"), u => s, u =>
  kc(JDCallScan, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0), u =>
    jd_calls_saturated(book, d, xs, dt(d), jd_arity(book, d), s), u => jd_calls_bad(s)))

@unsafe
def jd_calls_saturated(+book: List<&2,KDef>, +d: KDef, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, U32.is_eq(left, 0), u =>
    kc(JDCallScan, List.is_empty(&2,KTerm, xs),
      v => kc(JDCallScan, jd_native_known(book, d), w => s, w => jd_calls_edge(s, dn(d))),
      v => jd_calls_extra(book, xs, ty, s)),
    u => jd_calls_saturated_next(book, d, xs, wnf(book, ty), left, s))

@unsafe
def jd_calls_saturated_next(+book: List<&2,KDef>, +d: KDef, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32, +s: JDCallScan) -> JDCallScan:
  match xs:
    case Nil{}: kc(JDCallScan, U32.is_eq(jd_live_arity(book, ty, left), 0),
      u => kc(JDCallScan, jd_native_known(book, d), v => s, v => jd_calls_edge(s, dn(d))), u => s)
    case Con{x, rest}: kc(JDCallScan, String.eq(tg(ty), "All"), u =>
      jd_calls_saturated(book, d, rest, j_app_type(ty, x), U32.sub(left, 1), s), u => jd_calls_bad(s))

@unsafe
def jd_calls_extra(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +ty: KTerm, +s: JDCallScan) -> JDCallScan:
  match xs:
    case Nil{}: s
    case Con{x, rest}: jd_calls_extra_type(book, x, rest, wnf(book, ty), s)

@unsafe
def jd_calls_extra_type(+book: List<&2,KDef>, +x: KTerm, +rest: List<&2,KTerm>, +ty: KTerm, +s: JDCallScan) -> JDCallScan:
  kc(JDCallScan, String.eq(tg(ty), "All"), u =>
    kc(JDCallScan, List.is_empty(&2,KTerm, rest) && Bool.not(U32.is_eq(qt(ty), 0)),
      v => jd_calls_unknown(s), v => jd_calls_extra(book, rest, j_app_type(ty, x), s)), u => jd_calls_bad(s))

# One source scan per emitted definition. Keep the existing 8192-tail-node
# per-definition budget; graph processing below visits each edge
# a constant number of times and retains no per-definition reachable set.
@unsafe
def jd_calls_rows(+book: List<&2,KDef>, +defs: List<&2,KDef>, +left: U32) -> Maybe<&2,List<&2,KDef>>:
  match defs:
    case Nil{}: Some{Nil{}}
    case Con{d, rest}:
      kc(Maybe<&2,List<&2,KDef>>, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
        (Bool.not(String.eq(tg(dv(d)), "Absent")) || jd_native_known(book, d)), u =>
        kc(Maybe<&2,List<&2,KDef>>, U32.is_gt(left, 0), v =>
          jd_calls_row_done(dn(d), kc(JDCallScan, jd_native_known(book, d) || String.eq(tg(j_strip(dv(d))), "Foreign"),
            w => JDCallScan{Nil{}, False{}, 8192, True{}},
            w => jd_calls_body(book, Nil{}, dv(d), dt(d), jd_live_arity(book, dt(d), jd_arity(book, d)), JDCallScan{Nil{}, False{}, 8192, True{}})),
            jd_calls_rows(book, rest, U32.sub(left, 1))), v => None{}),
        u => jd_calls_rows(book, rest, left))

@unsafe
def jd_calls_row_done(+name: String, +s: JDCallScan, +more: Maybe<&2,List<&2,KDef>>) -> Maybe<&2,List<&2,KDef>>:
  match s:
    case JDCallScan{edges, unknown, fuel, valid}:
      kc(Maybe<&2,List<&2,KDef>>, valid, u => jd_calls_row_cons(
        KDef{name, "JDCall", kc(U32, unknown, v => 1, v => 0), 0, atom("Absent"), kt("JDCall", name, 0, 0, edges), Nil{}, False{}, False{}}, more),
        u => None{})

@unsafe
def jd_calls_row_cons(+row: KDef, +more: Maybe<&2,List<&2,KDef>>) -> Maybe<&2,List<&2,KDef>>:
  match more:
    case None{}: None{}
    case Some{rows}: Some{Con{row, rows}}

# Validate once, then use persistent exact-name indexes. The only retained
# result is a per-name component/id/bounce fact plus one list per component.
@unsafe
def jd_calls_get(+index: KDef, +name: String) -> KDef:
  index_find(index, name, index_hash(name, 2166136261), 32)

@unsafe
def jd_calls_put(+index: KDef, +row: KDef) -> KDef:
  index_set(index, row, index_hash(dn(row), 2166136261), 32)

@unsafe
def jd_calls_index(+rows: List<&2,KDef>, +left: U32, +index: KDef) -> Maybe<&2,KDef>:
  match rows:
    case Nil{}: Some{index}
    case Con{row, rest}: kc(Maybe<&2,KDef>, U32.is_gt(left, 0) &&
      String.eq(dk(row), "JDCall") && String.eq(tg(dv(row)), "JDCall") &&
      String.eq(dk(jd_calls_get(index, dn(row))), "Absent"), u =>
        jd_calls_index(rest, U32.sub(left, 1), jd_calls_put(index, row)), u => None{})

# Reverse edges are accumulated once. Duplicate edges remain legal and count
# against the explicit edge budget; every target must name an admitted row.
@unsafe
def jd_calls_reverse(+forward: KDef, +rows: List<&2,KDef>, +reverse: KDef,
  +seeds: List<&2,KTerm>, +fuel: U32) -> Maybe<&2,JDCallGraph>:
  match rows:
    case Nil{}: Some{JDCallGraph{forward, reverse, seeds}}
    case Con{row, rest}: jd_calls_reverse_edges(forward, rest, dn(row), ks(dv(row)), reverse,
      kc(List<&2,KTerm>, U32.is_eq(da(row), 1), u => Con{ref(dn(row)), seeds}, u => seeds), fuel)

@unsafe
def jd_calls_reverse_edges(+forward: KDef, +rows: List<&2,KDef>, +source: String,
  +edges: List<&2,KTerm>, +reverse: KDef, +seeds: List<&2,KTerm>, +fuel: U32) -> Maybe<&2,JDCallGraph>:
  match edges:
    case Nil{}: jd_calls_reverse(forward, rows, reverse, seeds, fuel)
    case Con{edge, rest}: kc(Maybe<&2,JDCallGraph>, U32.is_gt(fuel, 0) && String.eq(tg(edge), "Ref") &&
      String.eq(dk(jd_calls_get(forward, nm(edge))), "JDCall"), u =>
        jd_calls_reverse_edges(forward, rows, source, rest,
          jd_calls_put(reverse, KDef{nm(edge), "JDReverse", 0, 0, atom("Absent"),
            kt("JDReverse", nm(edge), 0, 0, Con{ref(source), ks(dv(jd_calls_get(reverse, nm(edge))))}),
            Nil{}, False{}, False{}}), seeds, U32.sub(fuel, 1)), u => None{})

@unsafe
def jd_calls_roots(+rows: List<&2,KDef>, +done: List<&2,KTerm>) -> List<&2,KTerm>:
  match rows:
    case Nil{}: done
    case Con{row, rest}: jd_calls_roots(rest, Con{ref(dn(row)), done})

# First Kosaraju pass: explicit exit frames record reverse finishing order.
# Each row is expanded once; an edge to an already entered row adds no frame.
@unsafe
def jd_calls_finish(+forward: KDef, +todo: List<&2,KTerm>, +seen: KDef,
  +order: List<&2,KTerm>) -> List<&2,KTerm>:
  match todo:
    case Nil{}: order
    case Con{step, rest}: kc(List<&2,KTerm>, String.eq(tg(step), "JDExit"), u =>
      jd_calls_finish(forward, rest, seen, Con{ref(nm(step)), order}), u =>
      kc(List<&2,KTerm>, String.eq(dk(jd_calls_get(seen, nm(step))), "Absent"), v =>
        jd_calls_finish_row(forward, rest, seen, order, jd_calls_get(forward, nm(step))), v =>
        jd_calls_finish(forward, rest, seen, order)))

@unsafe
def jd_calls_finish_row(+forward: KDef, +rest: List<&2,KTerm>, +seen: KDef,
  +order: List<&2,KTerm>, +row: KDef) -> List<&2,KTerm>:
  jd_calls_finish(forward, List.reverse.go(&2,KTerm, ks(dv(row)),
    Con{kt("JDExit", dn(row), 0, 0, Nil{}), rest}), jd_calls_put(seen, row), order)

# This explicit worklist serves both reversed-component marking and the one
# backwards propagation from unknown-call seeds. Neither needs a closure matrix.
@unsafe
def jd_calls_mark(+reverse: KDef, +todo: List<&2,KTerm>, +seen: KDef, +key: String) -> KDef:
  match todo:
    case Nil{}: seen
    case Con{step, rest}: kc(KDef, String.eq(dk(jd_calls_get(seen, nm(step))), "Absent"), u =>
      jd_calls_mark(reverse, List.reverse.go(&2,KTerm, ks(dv(jd_calls_get(reverse, nm(step)))), rest),
        jd_calls_put(seen, KDef{nm(step), "JDMark", 0, 0, atom("Absent"), ref(key), Nil{}, False{}, False{}}), key),
      u => jd_calls_mark(reverse, rest, seen, key))

@unsafe
def jd_calls_partition(+reverse: KDef, +order: List<&2,KTerm>, +labels: KDef) -> KDef:
  match order:
    case Nil{}: labels
    case Con{step, rest}: kc(KDef, String.eq(dk(jd_calls_get(labels, nm(step))), "Absent"), u =>
      jd_calls_partition(reverse, rest, jd_calls_mark(reverse, [step], labels, nm(step))), u =>
      jd_calls_partition(reverse, rest, labels))

# The DFS representative is private. Scan the original rows backwards and cons
# each name, so members and their eventual leader match selected source order.
@unsafe
def jd_calls_groups(+rows: List<&2,KDef>, +labels: KDef, +groups: KDef,
  +keys: List<&2,KTerm>) -> JDCallGroups:
  match rows:
    case Nil{}: JDCallGroups{groups, keys}
    case Con{row, rest}: jd_calls_group_row(rest, labels, groups, keys, dn(row),
      nm(dv(jd_calls_get(labels, dn(row)))))

@unsafe
def jd_calls_group_row(+rest: List<&2,KDef>, +labels: KDef, +groups: KDef,
  +keys: List<&2,KTerm>, +name: String, +key: String) -> JDCallGroups:
  jd_calls_group_old(rest, labels, groups, keys, name, key, jd_calls_get(groups, key))

@unsafe
def jd_calls_group_old(+rest: List<&2,KDef>, +labels: KDef, +groups: KDef,
  +keys: List<&2,KTerm>, +name: String, +key: String, +old: KDef) -> JDCallGroups:
  jd_calls_groups(rest, labels, jd_calls_put(groups,
    KDef{key, "JDGroup", 0, 0, atom("Absent"),
      kt("JDGroup", name, 0, 0, Con{ref(name), ks(dv(old))}), Nil{}, False{}, False{}}),
    kc(List<&2,KTerm>, String.eq(dk(old), "Absent"), u => Con{ref(key), keys}, u => keys))

@unsafe
def jd_calls_fact_members(+members: List<&2,KTerm>, +leader: String, +at: U32,
  +bounces: KDef, +facts: KDef) -> KDef:
  match members:
    case Nil{}: facts
    case Con{member, rest}: jd_calls_fact_members(rest, leader, U32.inc(at), bounces,
      jd_calls_put(facts, KDef{nm(member), "JDCall", 0, 0, kt("JDComponent", leader, at, 0, Nil{}),
        kt("JDCall", nm(member), kc(U32, String.eq(dk(jd_calls_get(bounces, nm(member))), "JDMark"),
          u => 1, u => 0), 0, Nil{}), Nil{}, False{}, False{}}))

@unsafe
def jd_calls_install(+book: List<&2,KDef>, +keys: List<&2,KTerm>, +groups: KDef,
  +bounces: KDef, +facts: KDef, +ordered: KDef) -> List<&2,KDef>:
  match keys:
    case Nil{}: jd_calls_tables(book, True{}, facts, ordered)
    case Con{key, rest}: jd_calls_install_group(book, rest, groups, bounces, facts, ordered,
      jd_calls_get(groups, nm(key)))

@unsafe
def jd_calls_install_group(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +groups: KDef,
  +bounces: KDef, +facts: KDef, +ordered: KDef, +group: KDef) -> List<&2,KDef>:
  jd_calls_install(book, rest, groups, bounces,
    jd_calls_fact_members(ks(dv(group)), nm(dv(group)), 0, bounces, facts),
    jd_calls_put(ordered, KDef{nm(dv(group)), "JDGroup", 0, 0, atom("Absent"),
      dv(group), Nil{}, False{}, False{}}))

# Install one metadata row, avoiding a book-list replacement per graph vertex.
# dc[0] is the per-name fact index; dc[1] owns the one ordered list per SCC.
@unsafe
def jd_calls_tables(+book: List<&2,KDef>, +valid: Bool, +facts: KDef, +groups: KDef) -> List<&2,KDef>:
  book_put(book, KDef{"$JD.Calls", "JDCalls", kc(U32, valid, u => 1, u => 0), 0,
    atom("Absent"), atom("Absent"), [facts, groups], False{}, False{}})

@unsafe
def jd_calls_status(+book: List<&2,KDef>, +valid: Bool) -> List<&2,KDef>:
  jd_calls_tables(book, valid, missing(), missing())

@unsafe
def jd_definition_budget() -> U32:
  4096

@unsafe
def jd_calls_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  jd_calls_context_rows(book, jd_calls_rows(book, defs, jd_definition_budget()))

# Source selection and exact emitted reach share one definition budget. Keep
# the total edge ceiling independent: increasing vertices does not increase
# allowed edge occurrences. Diagnostic callers can supply explicit budgets.
@unsafe
def jd_calls_context_rows(+book: List<&2,KDef>, +rows: Maybe<&2,List<&2,KDef>>) -> List<&2,KDef>:
  jd_calls_context_bounded(book, rows, jd_definition_budget(), 4194304)

@unsafe
def jd_calls_context_bounded(+book: List<&2,KDef>, +rows: Maybe<&2,List<&2,KDef>>,
  +vertices: U32, +edges: U32) -> List<&2,KDef>:
  match rows:
    case None{}: jd_calls_status(book, False{})
    case Some{values}: jd_calls_context_indexed(book, values, edges, jd_calls_index(values, vertices, missing()))

@unsafe
def jd_calls_context_indexed(+book: List<&2,KDef>, +rows: List<&2,KDef>, +edges: U32,
  +index: Maybe<&2,KDef>) -> List<&2,KDef>:
  match index:
    case None{}: jd_calls_status(book, False{})
    case Some{forward}: jd_calls_context_graph(book, rows,
      jd_calls_reverse(forward, rows, missing(), Nil{}, edges))

@unsafe
def jd_calls_context_graph(+book: List<&2,KDef>, +rows: List<&2,KDef>,
  +graph: Maybe<&2,JDCallGraph>) -> List<&2,KDef>:
  match graph:
    case None{}: jd_calls_status(book, False{})
    case Some{JDCallGraph{forward, reverse, seeds}}:
      jd_calls_context_parts(book, rows, reverse, seeds,
        jd_calls_partition(reverse, jd_calls_finish(forward, jd_calls_roots(rows, Nil{}), missing(), Nil{}), missing()))

@unsafe
def jd_calls_context_parts(+book: List<&2,KDef>, +rows: List<&2,KDef>, +reverse: KDef,
  +seeds: List<&2,KTerm>, +labels: KDef) -> List<&2,KDef>:
  jd_calls_context_groups(book, jd_calls_mark(reverse, seeds, missing(), ""),
    jd_calls_groups(List.reverse(&2,KDef, rows), labels, missing(), Nil{}))

@unsafe
def jd_calls_context_groups(+book: List<&2,KDef>, +bounces: KDef, +groups: JDCallGroups) -> List<&2,KDef>:
  match groups:
    case JDCallGroups{index, keys}: jd_calls_install(book, keys, index, bounces, missing(), missing())

@unsafe
def jd_calls_valid(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(da(lookup(book, "$JD.Calls")), 1)

@unsafe
def jd_calls_fact(+book: List<&2,KDef>, +name: String) -> KDef:
  jd_calls_get(index_first(dc(lookup(book, "$JD.Calls"))), name)

@unsafe
def jd_may_bounce(+book: List<&2,KDef>, +name: String) -> Bool:
  U32.is_eq(ix(dv(jd_calls_fact(book, name))), 1)

# Mutual named transfers are emitted as component-loop transitions. Only
# reachable unknown closure tails seed bounce forcing; cycles alone do not.
@unsafe
def jd_component(+book: List<&2,KDef>, +name: String) -> List<&2,String>:
  jd_calls_component_members(index_child(lookup(book, "$JD.Calls"), True{}), dt(jd_calls_fact(book, name)))

@unsafe
def jd_calls_component_members(+groups: KDef, +fact: KTerm) -> List<&2,String>:
  kc(List<&2,String>, String.eq(tg(fact), "JDComponent"),
    u => jd_calls_member_names(ks(dv(jd_calls_get(groups, nm(fact))))), u => Nil{})

@unsafe
def jd_calls_member_names(+members: List<&2,KTerm>) -> List<&2,String>:
  match members:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nm(h), jd_calls_member_names(rest)}

@unsafe
def jd_component_id(+book: List<&2,KDef>, +name: String) -> U32:
  jd_calls_component_id(dt(jd_calls_fact(book, name)))

@unsafe
def jd_calls_component_id(+fact: KTerm) -> U32:
  kc(U32, String.eq(tg(fact), "JDComponent"), u => ix(fact), u => 4294967295)

@unsafe
def jd_same_component(+book: List<&2,KDef>, +left: String, +right: String) -> Bool:
  jd_calls_same_component(dt(jd_calls_fact(book, left)), dt(jd_calls_fact(book, right)))

@unsafe
def jd_calls_same_component(+left: KTerm, +right: KTerm) -> Bool:
  String.eq(tg(left), "JDComponent") && String.eq(tg(right), "JDComponent") && String.eq(nm(left), nm(right))

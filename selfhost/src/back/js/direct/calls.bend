# Shared tail-call facts for the direct emitter. Analyze only the current
# function's returned computation: constructing a closure does not execute it.
# Exhausted traversal or an absent emitted target rejects the entire plan.
type JDCallScan is Data:
  JDCallScan{+edges: List<&2,KTerm>, +unknown: Bool, +fuel: U32, +valid: Bool}

type JDCallReach is Data:
  JDCallReach{+names: List<&2,KTerm>, +seen: KDef}

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
    kc(JDCallScan, List.is_empty(&2,KTerm, xs), v => jd_calls_edge(s, dn(d)),
      v => jd_calls_extra(book, xs, ty, s)),
    u => jd_calls_saturated_next(book, d, xs, wnf(book, ty), left, s))

@unsafe
def jd_calls_saturated_next(+book: List<&2,KDef>, +d: KDef, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32, +s: JDCallScan) -> JDCallScan:
  match xs:
    case Nil{}: kc(JDCallScan, U32.is_eq(jd_live_arity(book, ty, left), 0),
      u => jd_calls_edge(s, dn(d)), u => s)
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

# One source scan per emitted definition, then reachability over compact edges.
# At most 512 definitions, 8192 tail nodes/definition, and 65536 queued edges
# per reachability walk. Indexed seen/row maps avoid repeated source traversal;
# closure sets and their indexes are reused for component and bounce queries.
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

@unsafe
def jd_calls_reach(+rows: List<&2,KDef>, +todo: List<&2,KTerm>, +seen: KDef, +out: List<&2,KTerm>, +fuel: U32) -> Maybe<&2,JDCallReach>:
  match todo:
    case Nil{}: Some{JDCallReach{out, seen}}
    case Con{h, rest}:
      kc(Maybe<&2,JDCallReach>, U32.is_gt(fuel, 0), u =>
        kc(Maybe<&2,JDCallReach>, String.eq(dk(index_find(seen, nm(h), index_hash(nm(h), 2166136261), 32)), "Absent"), v =>
          jd_calls_reach_row(rows, rest, seen, out, U32.sub(fuel, 1), lookup(rows, nm(h))),
          v => jd_calls_reach(rows, rest, seen, out, U32.sub(fuel, 1))), u => None{})

@unsafe
def jd_calls_reach_row(+rows: List<&2,KDef>, +rest: List<&2,KTerm>, +seen: KDef, +out: List<&2,KTerm>, +fuel: U32, +row: KDef) -> Maybe<&2,JDCallReach>:
  kc(Maybe<&2,JDCallReach>, String.eq(dk(row), "JDCall"), u =>
    jd_calls_reach(rows, List.append(&2,KTerm, ks(dv(row)), rest), index_set(seen, row, index_hash(dn(row), 2166136261), 32),
      Con{kt("Ref", dn(row), 0, 0, Nil{}), out}, fuel), u => None{})

@unsafe
def jd_calls_close(+rows: List<&2,KDef>, +todo: List<&2,KDef>) -> Maybe<&2,List<&2,KDef>>:
  match todo:
    case Nil{}: Some{Nil{}}
    case Con{row, rest}: jd_calls_close_one(row,
      jd_calls_reach(rows, [kt("Ref", dn(row), 0, 0, Nil{})], missing(), Nil{}, 65536), jd_calls_close(rows, rest))

@unsafe
def jd_calls_close_one(+row: KDef, +reach: Maybe<&2,JDCallReach>, +more: Maybe<&2,List<&2,KDef>>) -> Maybe<&2,List<&2,KDef>>:
  match reach:
    case None{}: None{}
    case Some{JDCallReach{names, seen}}:
      jd_calls_row_cons(KDef{dn(row), "JDCall", da(row), 0, atom("Absent"), kt("JDCall", dn(row), 0, 0, names), [seen], False{}, False{}}, more)

@unsafe
def jd_calls_has(+row: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(index_first(dc(row)), name, index_hash(name, 2166136261), 32)), "JDCall")

# Both reachability directions identify exactly one strongly connected
# component. Preserve selected-definition order to give every member the same
# dense program-counter layout. Singleton components include their own name.
@unsafe
def jd_calls_members(+row: KDef, +todo: List<&2,KDef>) -> List<&2,KTerm>:
  match todo:
    case Nil{}: Nil{}
    case Con{other, rest}:
      kc(List<&2,KTerm>, String.eq(dk(other), "JDCall") &&
        jd_calls_has(row, dn(other)) && jd_calls_has(other, dn(row)), u =>
        Con{kt("Ref", dn(other), 0, 0, Nil{}), jd_calls_members(row, rest)},
        u => jd_calls_members(row, rest))

@unsafe
def jd_calls_member_id(+members: List<&2,KTerm>, +name: String, +at: U32) -> U32:
  match members:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, String.eq(nm(h), name), u => at,
      u => jd_calls_member_id(rest, name, U32.inc(at)))

@unsafe
def jd_calls_component_type(+members: List<&2,KTerm>, +name: String) -> KTerm:
  match members:
    case Nil{}: atom("Absent")
    case Con{h, rest}: kt("JDComponent", nm(h), jd_calls_member_id(members, name, 0), 0, members)

@unsafe
def jd_calls_components(+rows: List<&2,KDef>, +todo: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: Nil{}
    case Con{row, rest}:
      Con{KDef{dn(row), "JDCall", da(row), 0,
        jd_calls_component_type(jd_calls_members(row, rows), dn(row)), dv(row), dc(row), False{}, False{}},
        jd_calls_components(rows, rest)}

@unsafe
def jd_calls_bounces(+rows: List<&2,KDef>, +names: List<&2,KTerm>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{h, rest}: jd_calls_bounces_row(rows, lookup(rows, nm(h)), rest)

@unsafe
def jd_calls_bounces_row(+rows: List<&2,KDef>, +row: KDef, +rest: List<&2,KTerm>) -> Bool:
  kc(Bool, U32.is_eq(da(row), 1),
    u => True{}, u => jd_calls_bounces(rows, rest))

@unsafe
def jd_calls_install(+book: List<&2,KDef>, +rows: List<&2,KDef>, +todo: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: jd_calls_status(book, True{})
    case Con{row, rest}: jd_calls_install(book_put(book,
      KDef{"$JD.Call:" ++ dn(row), "JDCall", 0, 0, dt(row),
        kt("JDCall", dn(row), kc(U32, jd_calls_bounces(rows, ks(dv(row))), u => 1, u => 0), 0, ks(dv(row))), dc(row), False{}, False{}}), rows, rest)

@unsafe
def jd_calls_status(+book: List<&2,KDef>, +valid: Bool) -> List<&2,KDef>:
  book_put(book, KDef{"$JD.Calls", "JDCalls", kc(U32, valid, u => 1, u => 0), 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}})

@unsafe
def jd_calls_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  jd_calls_context_rows(book, jd_calls_rows(book, defs, 512))

@unsafe
def jd_calls_context_rows(+book: List<&2,KDef>, +rows: Maybe<&2,List<&2,KDef>>) -> List<&2,KDef>:
  match rows:
    case None{}: jd_calls_status(book, False{})
    case Some{values}: jd_calls_context_closed(book, jd_calls_close(book_cached(values, 0), values))

@unsafe
def jd_calls_context_closed(+book: List<&2,KDef>, +rows: Maybe<&2,List<&2,KDef>>) -> List<&2,KDef>:
  match rows:
    case None{}: jd_calls_status(book, False{})
    case Some{values}: jd_calls_context_components(book, jd_calls_components(book_cached(values, 0), values))

@unsafe
def jd_calls_context_components(+book: List<&2,KDef>, +rows: List<&2,KDef>) -> List<&2,KDef>:
  jd_calls_install(book, book_cached(rows, 0), rows)

@unsafe
def jd_calls_valid(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(da(lookup(book, "$JD.Calls")), 1)

@unsafe
def jd_may_bounce(+book: List<&2,KDef>, +name: String) -> Bool:
  U32.is_eq(ix(dv(lookup(book, "$JD.Call:" ++ name))), 1)

# Mutual named transfers are emitted as component-loop transitions. Only
# reachable unknown closure tails seed bounce forcing; cycles alone do not.
@unsafe
def jd_component(+book: List<&2,KDef>, +name: String) -> List<&2,String>:
  jd_calls_member_names(ks(dt(lookup(book, "$JD.Call:" ++ name))))

@unsafe
def jd_calls_member_names(+members: List<&2,KTerm>) -> List<&2,String>:
  match members:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nm(h), jd_calls_member_names(rest)}

@unsafe
def jd_component_id(+book: List<&2,KDef>, +name: String) -> U32:
  jd_calls_component_id(dt(lookup(book, "$JD.Call:" ++ name)))

@unsafe
def jd_calls_component_id(+fact: KTerm) -> U32:
  kc(U32, String.eq(tg(fact), "JDComponent"), u => ix(fact), u => 4294967295)

@unsafe
def jd_same_component(+book: List<&2,KDef>, +left: String, +right: String) -> Bool:
  jd_calls_same_component(dt(lookup(book, "$JD.Call:" ++ left)), dt(lookup(book, "$JD.Call:" ++ right)))

@unsafe
def jd_calls_same_component(+left: KTerm, +right: KTerm) -> Bool:
  String.eq(tg(left), "JDComponent") && String.eq(tg(right), "JDComponent") && String.eq(nm(left), nm(right))

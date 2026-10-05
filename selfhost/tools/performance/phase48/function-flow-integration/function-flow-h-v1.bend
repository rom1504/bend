# Experimental checked-source function flow. Never replace the provenance book.
# The owner must add dependencies to the original public identity fence and must
# run complete first-order admission on the result. No public closure ABI changes.
type JFunctionFlow is Data:
  JFunctionFlow{+term: KTerm, +next: U32, +steps: U32, +dependencies: List<&2,String>, +valid: Bool}

type JFFState is Data:
  JFFState{+next: U32, +steps: U32, +dependencies: List<&2,String>, +valid: Bool}

type JFFResult is Data:
  JFFResult{+term: KTerm, +state: JFFState}

type JFFTerms is Data:
  JFFTerms{+terms: List<&2,KTerm>, +state: JFFState}

# fresh must exceed EVERY original binder ID in the request's book and context.
# Returning invalid means discard all rewritten syntax and use the old planner.
@unsafe
def j_function_flow(+book: List<&2,KDef>, +t: KTerm, +fresh: U32) -> JFunctionFlow:
  kc(JFunctionFlow, jff_bounded([t], 8192),
    u => jff_finish(t, jff_walk(book, t, JFFState{fresh, 0, Nil{}, True{}}, 128)),
    u => JFunctionFlow{t, fresh, 0, Nil{}, False{}})

@unsafe
def jff_finish(+original: KTerm, +r: JFFResult) -> JFunctionFlow:
  match r:
    case JFFResult{t, JFFState{next, steps, deps, valid}}:
      kc(JFunctionFlow, valid && jff_bounded([t], 32768),
        u => JFunctionFlow{t, next, steps, deps, True{}},
        u => JFunctionFlow{original, next, steps, Nil{}, False{}})

@unsafe
def jff_walk(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  match s:
    case JFFState{next, steps, deps, valid}:
      kc(JFFResult, valid && U32.is_gt(depth, 0),
        u => jff_node(book, t, s, U32.sub(depth, 1)),
        u => JFFResult{t, JFFState{next, steps, deps, False{}}})

@unsafe
def jff_node(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  kc(JFFResult, String.eq(tg(t), "App"),
    u => jff_application(book, t, jff_walk(book, kid(t, 0), s, depth), depth),
    u => jff_children(book, t, jff_terms(book, ks(t), s, depth), depth))

@unsafe
def jff_terms(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +s: JFFState, +depth: U32) -> JFFTerms:
  match xs:
    case Nil{}: JFFTerms{Nil{}, s}
    case Con{h, rest}: jff_terms_head(book, rest, jff_walk(book, h, s, depth), depth)

@unsafe
def jff_terms_head(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +r: JFFResult, +depth: U32) -> JFFTerms:
  match r:
    case JFFResult{t, s}: jff_terms_tail(t, jff_terms(book, rest, s, depth))

@unsafe
def jff_terms_tail(+t: KTerm, +r: JFFTerms) -> JFFTerms:
  match r:
    case JFFTerms{ts, s}: JFFTerms{Con{t, ts}, s}

@unsafe
def jff_children(+book: List<&2,KDef>, +t: KTerm, +r: JFFTerms, +depth: U32) -> JFFResult:
  match r:
    case JFFTerms{ts, s}: jff_let(book, k_with_children(t, ts), s, depth)

# Only singleton sequential Let is transported. Parallel RHS scope is unchanged.
# A known closure initializer is allocation-only; capture expressions remain in
# preceding ordinary Lets. Function escapes stay in syntax and fail JPure later.
@unsafe
def jff_let(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  kc(JFFResult, String.eq(tg(t), "Ann") && String.eq(tg(kid(t, 0)), "Let") && U32.is_eq(terms_len(ks(kid(t, 0))), 2),
    u => jff_expand(book, k_with_children(kid(t, 0), [kid(kid(t, 0), 0),
      k_with_children(t, [kid(kid(t, 0), 1), kid(t, 1)])]), s, depth, ""), u =>
  kc(JFFResult, String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 2) &&
    String.eq(tg(kid(t, 0)), "Bind"),
    u => jff_let_rhs(book, t, s, depth),
    u => JFFResult{t, s}))

@unsafe
def jff_let_rhs(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  +rhs = kid(kid(t, 0), 0)
  kc(JFFResult, Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && String.eq(tg(rhs), "Let") && U32.is_eq(terms_len(ks(rhs)), 2),
    u => jff_expand(book, k_with_children(rhs, [kid(rhs, 0), k_with_children(t,
      [k_with_children(kid(t, 0), [kid(rhs, 1)]), kid(t, 1)])]), s, depth, ""),
    u => jff_let_known(book, t, s, depth, jff_known(book, rhs)))

@unsafe
def jff_let_known(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32, +known: KTerm) -> JFFResult:
  kc(JFFResult, jff_lambda(known),
    u => jff_transport(book, t, known, s, depth), u => JFFResult{t, s})

@unsafe
def jff_transport(+book: List<&2,KDef>, +t: KTerm, +known: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  # Every occurrence substitutes only an inert closure value, never its body.
  kc(JFFResult, jff_subst_ok(kid(t, 1), ix(kid(t, 0)), known),
    u => jff_expand(book, subst(kid(t, 1), ix(kid(t, 0)), known), s, depth, jff_reference(kid(kid(t, 0), 0))),
    u => jff_fail(t, s))

@unsafe
def jff_known(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(j_strip(t)), "Ref"),
    u => jff_definition(lookup(book, nm(j_strip(t)))), u => t)

@unsafe
def jff_definition(+d: KDef) -> KTerm:
  kc(KTerm, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(db(d)),
    u => kc(KTerm, String.eq(tg(j_strip(dv(d))), "Lam"),
      u => kt("Ann", "", 0, 0, [dv(d), dt(d)]), u => atom("Absent")),
    u => atom("Absent"))

@unsafe
def jff_lambda(+t: KTerm) -> Bool:
  String.eq(tg(t), "Ann") && String.eq(tg(j_strip(kid(t, 0))), "Lam") &&
    String.eq(tg(kid(t, 1)), "All")

@unsafe
def jff_application(+book: List<&2,KDef>, +original: KTerm, +r: JFFResult, +depth: U32) -> JFFResult:
  match r:
    case JFFResult{callee, s}:
      # Factory-prefix execution stays before the subsequent application actual.
      kc(JFFResult, String.eq(tg(callee), "Let") && U32.is_eq(terms_len(ks(callee)), 2),
        u => jff_expand(book, k_with_children(callee, [kid(callee, 0),
          k_with_children(original, [kid(callee, 1), kid(original, 1)])]), s, depth, ""),
        u => jff_apply_known(book, original, callee, s, depth, jff_known(book, callee)))

@unsafe
def jff_apply_known(+book: List<&2,KDef>, +original: KTerm, +callee: KTerm, +s: JFFState, +depth: U32, +known: KTerm) -> JFFResult:
  kc(JFFResult, jff_lambda(known),
    u => jff_beta_prepare(book, original, known, s, depth, jff_reference(callee)),
    u => jff_apply_unknown(original, callee, jff_walk(book, kid(original, 1), s, depth)))

@unsafe
def jff_apply_unknown(+original: KTerm, +callee: KTerm, +r: JFFResult) -> JFFResult:
  match r:
    case JFFResult{arg, s}: JFFResult{k_with_children(original, [callee, arg]), s}

# Clone every bound ID before copying a body. Free captured IDs remain unchanged.
@unsafe
def jff_beta_prepare(+book: List<&2,KDef>, +original: KTerm, +known: KTerm, +s: JFFState, +depth: U32, +dependency: String) -> JFFResult:
  match s:
    case JFFState{next, steps, deps, valid}:
      kc(JFFResult, valid && U32.is_lt(steps, 64),
        u => kc(JFFResult, jff_bounded([known], 2048),
          u => jff_beta_size(book, original, known, s, depth, dependency, jff_max([known], 0)),
          u => JFFResult{original, JFFState{next, steps, deps, False{}}}),
        u => JFFResult{original, JFFState{next, steps, deps, False{}}})

@unsafe
def jff_beta_size(+book: List<&2,KDef>, +original: KTerm, +known: KTerm, +s: JFFState, +depth: U32, +dependency: String, +highest: U32) -> JFFResult:
  match s:
    case JFFState{next, steps, deps, valid}:
      kc(JFFResult, U32.is_lt(next, U32.sub(4294967295, highest)),
        u => jff_beta(book, original, jff_copy(known, jff_binders([known]), next),
          JFFState{U32.add(next, U32.inc(highest)), U32.inc(steps), jff_dependency(deps, dependency), valid}, depth),
        u => JFFResult{original, JFFState{next, steps, deps, False{}}})

@unsafe
def jff_beta(+book: List<&2,KDef>, +original: KTerm, +known: KTerm, +s: JFFState, +depth: U32) -> JFFResult:
  +lam = j_strip(kid(known, 0))
  +ty = kid(known, 1)
  +arg = kid(original, 1)
  kc(JFFResult, U32.is_eq(qt(ty), 0),
    u => kc(JFFResult, j_callback_runtime_absent(kid(lam, 0), ix(lam), 2048) && jff_subst_ok(kid(lam, 0), ix(lam), arg) && jff_subst_ok(kid(ty, 1), ix(ty), arg),
      u => jff_walk(book, jff_body(lam, ty, arg, True{}), s, depth),
      u => jff_fail(original, s)),
    u => jff_beta_live(book, lam, ty, arg, s, depth, jff_known(book, arg)))

@unsafe
def jff_beta_live(+book: List<&2,KDef>, +lam: KTerm, +ty: KTerm, +arg: KTerm, +s: JFFState, +depth: U32, +knownArg: KTerm) -> JFFResult:
  kc(JFFResult, jff_lambda(knownArg),
    u => kc(JFFResult, jff_subst_ok(kid(lam, 0), ix(lam), knownArg) && jff_subst_ok(kid(ty, 1), ix(ty), knownArg),
      u => jff_expand(book, jff_body(lam, ty, knownArg, True{}), s, depth, jff_reference(arg)),
      u => jff_fail(lam, s)),
    u => jff_walk(book, kt("Let", "", 0, 0,
      [kt("Bind", nm(lam), ix(lam), qt(ty), [kt("Ann", "", 0, 0, [arg, kid(ty, 0)])]), jff_body(lam, ty, var(nm(lam), ix(lam)), False{})]), s, depth))

@unsafe
def jff_expand(+book: List<&2,KDef>, +t: KTerm, +s: JFFState, +depth: U32, +dependency: String) -> JFFResult:
  match s:
    case JFFState{next, steps, deps, valid}:
      kc(JFFResult, valid && U32.is_lt(steps, 64),
        u => kc(JFFResult, jff_bounded([t], 32768),
          u => jff_walk(book, t, JFFState{next, U32.inc(steps), jff_dependency(deps, dependency), valid}, depth),
          u => jff_fail(t, s)),
        u => jff_fail(t, s))

@unsafe
def jff_fail(+t: KTerm, +s: JFFState) -> JFFResult:
  match s:
    case JFFState{next, steps, deps, valid}: JFFResult{t, JFFState{next, steps, deps, False{}}}

@unsafe
def jff_dependency(+deps: List<&2,String>, +name: String) -> List<&2,String>:
  kc(List<&2,String>, String.eq(name, "") || has_name(deps, name), u => deps, u => Con{name, deps})

@unsafe
def jff_max(+todo: List<&2,KTerm>, +highest: U32) -> U32:
  match todo:
    case Nil{}: highest
    case Con{h, rest}: jff_max(List.append(&2,KTerm, ks(h), rest), U32.max(highest, ix(h)))

@unsafe
def jff_binders(+todo: List<&2,KTerm>) -> List<&2,KTerm>:
  match todo:
    case Nil{}: Nil{}
    case Con{h, rest}:
      kc(List<&2,KTerm>, String.eq(tg(h), "Lam") || String.eq(tg(h), "All") || String.eq(tg(h), "Bind"),
        u => Con{h, jff_binders(List.append(&2,KTerm, ks(h), rest))},
        u => jff_binders(List.append(&2,KTerm, ks(h), rest)))

@unsafe
def jff_has_id(+ids: List<&2,KTerm>, +id: U32) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{h, rest}: kc(Bool, U32.is_eq(ix(h), id), u => True{}, u => jff_has_id(rest, id))

@unsafe
def jff_copy(+t: KTerm, +ids: List<&2,KTerm>, +offset: U32) -> KTerm:
  jff_copy_node(t, jff_copy_terms(ks(t), ids, offset),
    kc(U32, (String.eq(tg(t), "Var") || String.eq(tg(t), "Lam") || String.eq(tg(t), "All") || String.eq(tg(t), "Bind")) &&
      jff_has_id(ids, ix(t)), u => U32.add(ix(t), offset), u => ix(t)))

@unsafe
def jff_copy_node(+t: KTerm, +kids: List<&2,KTerm>, +id2: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, begin, end}: KTerm{tag, name, id2, quant, kids, removed, begin, end}
    case KLambda{name, id, quant, oldKids, removed, begin, end, present}: KLambda{name, id2, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, begin, end}: t

@unsafe
def jff_copy_terms(+ts: List<&2,KTerm>, +ids: List<&2,KTerm>, +offset: U32) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{jff_copy(h, ids, offset), jff_copy_terms(rest, ids, offset)}

@unsafe
def jff_reference(+t: KTerm) -> String:
  kc(String, String.eq(tg(j_strip(t)), "Ref"), u => nm(j_strip(t)), u => "")

@unsafe
def jff_body(+lam: KTerm, +ty: KTerm, +actual: KTerm, +replace: Bool) -> KTerm:
  kt("Ann", "", 0, 0, [kc(KTerm, replace,
    u => subst(kid(lam, 0), ix(lam), actual), u => kid(lam, 0)),
    subst(kid(ty, 1), ix(ty), actual)])

# Count annotation/type children too: cloning and renaming visit those children.
@unsafe
def jff_bounded(+todo: List<&2,KTerm>, +left: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{h, rest}: kc(Bool, U32.is_gt(left, 0),
      u => jff_bounded(List.append(&2,KTerm, ks(h), rest), U32.sub(left, 1)),
      u => False{})

# Fence allocation BEFORE eager substitution. Bounds count annotation children.
@unsafe
def jff_subst_ok(+body: KTerm, +id: U32, +value: KTerm) -> Bool:
  kc(Bool, jff_bounded([body], 32768) && jff_bounded([value], 2048),
    u => U32.is_le(U32.add(jff_nodes([body], 0),
      U32.mul(jff_occurrences([body], id, 0), jff_nodes([value], 0))), 32768),
    u => False{})

@unsafe
def jff_nodes(+todo: List<&2,KTerm>, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{h, rest}: jff_nodes(List.append(&2,KTerm, ks(h), rest), U32.inc(count))

@unsafe
def jff_occurrences(+todo: List<&2,KTerm>, +id: U32, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{h, rest}: jff_occurrences(List.append(&2,KTerm, ks(h), rest), id,
      kc(U32, String.eq(tg(h), "Var") && U32.is_eq(ix(h), id), u => U32.inc(count), u => count))

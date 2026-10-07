# Ordered expressions are emitted only inside an existing statement scope.
# Exact saturated named calls, closure applications, constructors and Lets
# propagate prefixes. Closure bodies keep their original separate statement scope.
# Like pinned js_call, collect every child prefix first. Only native calls then
# hold their pending non-atomic actuals before template lookup/coercion. Ordinary
# calls retain pending actual expressions after all child prefixes have run.
type JDOrdered is Data:
  JDOrdered{+prefix: String, +value: String, +next: U32}

type JDOrderedArgs is Data:
  JDOrderedArgs{+prefix: String, +values: List<&2,String>, +next: U32}

@unsafe
def jd_ordered_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +next: U32) -> JDOrdered:
  jd_ordered_node(book, env, t, ty, tail, next)

@unsafe
def jd_ordered_node(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +next: U32) -> JDOrdered:
  kc(JDOrdered, String.eq(tg(t), "Ann"),
    u => jd_ordered_expr(book, env, kid(t, 0), kid(t, 1), tail, next), u =>
  kc(JDOrdered, String.eq(tg(t), "Rwt"),
    u => jd_ordered_expr(book, env, kid(t, 2), ty, tail, next), u =>
  kc(JDOrdered, String.eq(tg(t), "Let"),
    u => jd_ordered_let(book, env, t, ty, tail, next), u =>
  kc(JDOrdered, String.eq(tg(t), "Ctr") || core_literal(t),
    u => jd_ordered_ctor(book, env, t, ty, tail, next), u =>
  kc(JDOrdered, String.eq(tg(t), "App") || String.eq(tg(t), "Ref"),
    u => jd_ordered_spine(book, env, t, ty, tail, next, j_call_spine(t, Nil{})),
    u => jd_ordered_leaf(book, env, t, ty, tail, next))))))

@unsafe
def jd_ordered_spine(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +next: U32, +spine: KTerm) -> JDOrdered:
  kc(JDOrdered, String.eq(tg(spine), "Call"),
    u => jd_ordered_named(book, env, t, ty, tail, next, ks(spine), lookup(book, nm(spine))),
    u => jd_ordered_unknown(book, env, t, tail, next, wnf(book, j_type(book, env, kid(t, 0)))))

# CLO_APPLY follows pinned js_call: child prefixes run first, then the callee
# and argument remain pending expressions. An erased application never lowers
# its argument, and its callee retains the old non-tail expression behavior.
@unsafe
def jd_ordered_unknown(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +tail: Bool, +next: U32, +ty: KTerm) -> JDOrdered:
  kc(JDOrdered, String.eq(tg(t), "App") && String.eq(tg(ty), "All"), u =>
    kc(JDOrdered, U32.is_eq(qt(ty), 0),
      v => jd_ordered_expr(book, env, kid(t, 0), ty, False{}, next),
      v => jd_ordered_unknown_head(book, env, kid(t, 1), kid(ty, 0), tail,
        jd_ordered_expr(book, env, kid(t, 0), ty, False{}, next))),
    u => JDOrdered{"", jd_fail("unknown application lacks its checked function type"), next})

@unsafe
def jd_ordered_unknown_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +arg: KTerm, +ty: KTerm, +tail: Bool, +callee: JDOrdered) -> JDOrdered:
  match callee:
    case JDOrdered{prefix, value, next}:
      jd_ordered_unknown_done(prefix, value, tail,
        jd_ordered_expr(book, env, arg, ty, False{}, next))

@unsafe
def jd_ordered_unknown_done(+prefix: String, +callee: String, +tail: Bool, +arg: JDOrdered) -> JDOrdered:
  match arg:
    case JDOrdered{more, value, next}:
      JDOrdered{prefix ++ more, kc(String, tail,
        u => "run_tail(" ++ callee ++ "," ++ value ++ ")",
        u => "(" ++ callee ++ ")(" ++ value ++ ")"), next}

@unsafe
def jd_ordered_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +next: U32, +xs: List<&2,KTerm>, +d: KDef) -> JDOrdered:
  kc(JDOrdered, jd_choice_named(book, d, xs),
    u => jd_choice_ordered(book, env, xs, next), u =>
  kc(JDOrdered, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    (Bool.not(String.eq(tg(dv(d)), "Absent")) || jd_native_known(book, d)), u =>
      kc(JDOrdered, U32.is_eq(terms_len(xs), jd_arity(book, d)),
        v => jd_ordered_call(book, jd_owner(env), dn(d), tail, jd_ordered_args(book, env, xs, dt(d), next)),
        v => kc(JDOrdered, U32.is_lt(terms_len(xs), jd_arity(book, d)),
          w => jd_ordered_eta(book, jd_owner(env), dn(d), jd_ordered_after(book, xs, dt(d)),
            U32.sub(jd_arity(book, d), terms_len(xs)), terms_len(env), tail,
            jd_ordered_args(book, env, xs, dt(d), next)),
          w => jd_ordered_unknown(book, env, t, tail, next, wnf(book, j_type(book, env, kid(t, 0)))))),
    u => jd_ordered_leaf(book, env, t, ty, tail, next)))

# Eta expansion keeps supplied prefixes and expressions in the eventual fully
# applied closure. No provided computation runs merely to allocate the closure.
# An erased-only suffix introduces no closure and therefore runs immediately.
@unsafe
def jd_ordered_after(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +ty: KTerm) -> KTerm:
  match xs:
    case Nil{}: ty
    case Con{x, rest}: jd_ordered_after(book, rest, j_app_type(wnf(book, ty), x))

@unsafe
def jd_ordered_eta(+book: List<&2,KDef>, +owner: String, +name: String, +ty: KTerm, +left: U32, +at: U32, +tail: Bool, +args: JDOrderedArgs) -> JDOrdered:
  kc(JDOrdered, U32.is_eq(left, 0), u => jd_ordered_call(book, owner, name, tail, args),
    u => jd_ordered_eta_type(book, owner, name, wnf(book, ty), left, at, tail, args))

@unsafe
def jd_ordered_eta_type(+book: List<&2,KDef>, +owner: String, +name: String, +ty: KTerm, +left: U32, +at: U32, +tail: Bool, +args: JDOrderedArgs) -> JDOrdered:
  kc(JDOrdered, String.eq(tg(ty), "All"), u =>
    kc(JDOrdered, U32.is_eq(qt(ty), 0),
      v => jd_ordered_eta(book, owner, name, j_app_type(ty, atom("Absent")), U32.sub(left, 1), at, tail, args),
      v => jd_ordered_eta_wrap(at, jd_ordered_eta(book, "", name, kid(ty, 1), U32.sub(left, 1), U32.inc(at), True{},
        jd_ordered_eta_arg(args, "$eta" ++ U32.show(at))))),
    u => JDOrdered{"", jd_fail("partial direct call lacks telescope"), 0})

@unsafe
def jd_ordered_eta_arg(+args: JDOrderedArgs, +value: String) -> JDOrderedArgs:
  match args:
    case JDOrderedArgs{prefix, values, next}: JDOrderedArgs{prefix, List.append(&2,String, values, [value]), next}

@unsafe
def jd_ordered_eta_wrap(+at: U32, +body: JDOrdered) -> JDOrdered:
  match body:
    case JDOrdered{prefix, value, next}:
      JDOrdered{"", "jd_clo(($eta" ++ U32.show(at) ++ ")=>{" ++ prefix ++ "return " ++ value ++ ";})", next}

@unsafe
def jd_ordered_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +next: U32) -> JDOrdered:
  JDOrdered{"", kc(String, String.eq(tg(t), "App") || String.eq(tg(t), "Ref"),
    u => jd_application(book, env, t, tail, j_call_spine(t, Nil{})),
    u => jd_expr(book, env, t, ty)), next}

@unsafe
def jd_ordered_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +next: U32) -> JDOrderedArgs:
  match xs:
    case Nil{}: JDOrderedArgs{"", Nil{}, next}
    case Con{x, rest}: jd_ordered_arg_type(book, env, x, rest, wnf(book, ty), next)

@unsafe
def jd_ordered_arg_type(+book: List<&2,KDef>, +env: List<&2,KTerm>, +x: KTerm, +rest: List<&2,KTerm>, +ty: KTerm, +next: U32) -> JDOrderedArgs:
  kc(JDOrderedArgs, String.eq(tg(ty), "All"), u =>
    kc(JDOrderedArgs, U32.is_eq(qt(ty), 0),
      v => jd_ordered_args(book, env, rest, j_app_type(ty, x), next),
      v => jd_ordered_arg_head(book, env, rest, j_app_type(ty, x),
        jd_ordered_expr(book, env, x, kid(ty, 0), False{}, next))),
    u => JDOrderedArgs{"", [jd_fail("ordered actual lacks checked telescope")], next})

@unsafe
def jd_ordered_hold(+r: JDOrdered) -> JDOrdered:
  match r:
    case JDOrdered{prefix, value, next}:
      kc(JDOrdered, jd_inline_atom(value), u => r,
        u => JDOrdered{prefix ++ "const $ord" ++ U32.show(next) ++ "=" ++ value ++ ";",
          "$ord" ++ U32.show(next), U32.inc(next)})

@unsafe
def jd_ordered_arg_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,KTerm>, +ty: KTerm, +head: JDOrdered) -> JDOrderedArgs:
  match head:
    case JDOrdered{prefix, value, next}:
      jd_ordered_arg_join(prefix, value, jd_ordered_args(book, env, rest, ty, next))

@unsafe
def jd_ordered_arg_join(+prefix: String, +value: String, +rest: JDOrderedArgs) -> JDOrderedArgs:
  match rest:
    case JDOrderedArgs{more, values, next}: JDOrderedArgs{prefix ++ more, Con{value, values}, next}

@unsafe
def jd_ordered_call(+book: List<&2,KDef>, +owner: String, +name: String, +tail: Bool, +r: JDOrderedArgs) -> JDOrdered:
  match r:
    case JDOrderedArgs{prefix, values, next}:
      +code = jd_intrinsic(book, name, values)
      kc(JDOrdered, String.eq(code, ""),
        u => JDOrdered{prefix, jd_call(book, owner, name, values, tail), next},
        u => jd_ordered_native(book, name, jd_ordered_holds(values, prefix, next)))

@unsafe
def jd_ordered_holds(+values: List<&2,String>, +prefix: String, +next: U32) -> JDOrderedArgs:
  match values:
    case Nil{}: JDOrderedArgs{prefix, Nil{}, next}
    case Con{value, rest}: jd_ordered_hold_head(rest, jd_ordered_hold(JDOrdered{prefix, value, next}))

@unsafe
def jd_ordered_hold_head(+rest: List<&2,String>, +head: JDOrdered) -> JDOrderedArgs:
  match head:
    case JDOrdered{prefix, value, next}:
      jd_ordered_arg_join(prefix, value, jd_ordered_holds(rest, "", next))

@unsafe
def jd_ordered_native(+book: List<&2,KDef>, +name: String, +r: JDOrderedArgs) -> JDOrdered:
  match r:
    case JDOrderedArgs{prefix, values, next}:
      JDOrdered{prefix, "(" ++ jd_intrinsic(book, name, values) ++ ")", next}

# Return scopes and parallel Let scopes own disjoint ordinal namespaces.
# The old demanded-use gate precedes all RHS lowering, including its prefixes.
@unsafe
def jd_doc_ordered_return(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> JDText:
  jd_doc_ordered_return_done(jd_ordered_expr(book, env, t, ty, jd_tail_position(env), 0))

@unsafe
def jd_doc_ordered_return_done(+r: JDOrdered) -> JDText:
  match r:
    case JDOrdered{prefix, value, next}: kc(JDText, String.eq(prefix, ""), u => jd_text_raw("return " ++ value ++ ";"), u => jd_text_raw("{" ++ prefix ++ "return " ++ value ++ ";}"))

@unsafe
def jd_doc_ordered_lets(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +at: U32, +body: JDText, +next: U32) -> JDText:
  match xs:
    case Nil{}: jd_text_literal("", 0)
    case Con{x, Nil{}}: jd_text_literal("", 0)
    case Con{x, rest}: kc(JDText, jd_text_used(body, ix(x)), u => jd_doc_ordered_let_done(book, env, rest, at, body, kc(JDOrdered, U32.is_eq(qt(x), 0), v => JDOrdered{"", "null", next},
            v => jd_ordered_expr(book, env, kid(x, 0), j_type(book, env, kid(x, 0)), False{}, next))), u => jd_doc_ordered_lets(book, env, rest, U32.inc(at), body, next))

@unsafe
def jd_doc_ordered_let_done(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,KTerm>, +at: U32, +body: JDText, +r: JDOrdered) -> JDText:
  match r:
    case JDOrdered{prefix, value, next}: jd_text_many([jd_text_raw(prefix ++ "const $let" ++ U32.show(at) ++ "=" ++ value ++ ";"), jd_doc_ordered_lets(book, env, rest, U32.inc(at), body, next)])
# The caller proves complete live saturation and no surplus actuals. A missing
# erased-only suffix needs no runtime value; lower every supplied live actual.
@unsafe
def jd_doc_ordered_transfer(+book: List<&2,KDef>, +env: List<&2,KTerm>, +target: String, +xs: List<&2,KTerm>) -> JDText:
  jd_doc_ordered_transfer_done(book, jd_owner(env), target, jd_ordered_args(book, env, xs, dt(lookup(book, target)), 0))

@unsafe
def jd_doc_ordered_transfer_done(+book: List<&2,KDef>, +owner: String, +target: String, +r: JDOrderedArgs) -> JDText:
  match r:
    case JDOrderedArgs{prefix, values, next}: kc(JDText, String.eq(prefix, ""), u => jd_doc_transfer_args(book, owner, target, values), u => jd_text_many([jd_text_raw("{" ++ prefix), jd_doc_transfer_args(book, owner, target, values), jd_text_literal("}", 1)]))

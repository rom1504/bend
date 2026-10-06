# Literal continuations of a structurally proved Boolean selector. Names never
# identify the operation. Ordinary calls reject before any type normalization.
# This uses the direct backend's ordinary source-value/standard-builtin domain;
# private closure wrappers, tail packets and their reflective identity are not ABI.
@unsafe
def jd_choice_call(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  kc(Bool, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), 4),
    u => jd_choice_named(book, lookup(book, nm(spine)), ks(spine)), u => False{})

@unsafe
def jd_choice_named(+book: List<&2,KDef>, +d: KDef, +xs: List<&2,KTerm>) -> Bool:
  kc(Bool, U32.is_eq(terms_len(xs), 4), u =>
    kc(Bool, String.eq(tg(j_strip(terms_at(xs, 2))), "Lam") &&
      String.eq(tg(j_strip(terms_at(xs, 3))), "Lam") &&
      Bool.not(U32.is_eq(qt(j_strip(terms_at(xs, 2))), 0)) &&
      Bool.not(U32.is_eq(qt(j_strip(terms_at(xs, 3))), 0)), v =>
      kc(Bool, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && U32.is_eq(da(d), 4),
        w => kc(Bool, j_choice_definition(book, d),
          z => jd_choice_signature(book, dt(d), 0), z => False{}), w => False{}),
      v => False{}), u => False{})

@unsafe
def jd_choice_signature(+book: List<&2,KDef>, +ty: KTerm, +at: U32) -> Bool:
  kc(Bool, U32.is_eq(at, 4), u => True{},
    u => jd_choice_domain(book, wnf(book, ty), at))

@unsafe
def jd_choice_domain(+book: List<&2,KDef>, +ty: KTerm, +at: U32) -> Bool:
  kc(Bool, String.eq(tg(ty), "All"), u =>
    kc(Bool, kc(Bool, U32.is_eq(at, 0),
      v => U32.is_eq(qt(ty), 0) && String.eq(tg(wnf(book, kid(ty, 0))), "Typ"),
      v => Bool.not(U32.is_eq(qt(ty), 0)) &&
        kc(Bool, U32.is_eq(at, 1),
          w => jd_choice_owner(book, kid(ty, 0), "Bool"),
          w => jd_choice_callback(book, wnf(book, kid(ty, 0))))),
      v => jd_choice_signature(book, kid(ty, 1), U32.inc(at)), v => False{}), u => False{})

@unsafe
def jd_choice_owner(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  jd_choice_owner_head(book, wnf(book, ty), name)

@unsafe
def jd_choice_owner_head(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), name) &&
    List.is_empty(&2,KTerm, ks(ty)) && db(lookup(book, name))

@unsafe
def jd_choice_callback(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)),
    u => jd_choice_owner(book, kid(ty, 0), "Unit"), u => False{})

# Non-tail expression sites keep one local expression scope. A tail site uses
# the surrounding return continuation, so selected recursive edges can transfer
# through the existing SCC loop. Conditions/prefixes are demanded exactly once.
@unsafe
def jd_choice_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>) -> String:
  "(()=>{" ++ jd_choice_body(book, jd_expression_env(env), xs) ++ "})()"

@unsafe
def jd_choice_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>) -> String:
  jd_choice_done(book, env, xs, jd_ordered_expr(book, env, terms_at(xs, 1),
    j_type(book, env, terms_at(xs, 1)), False{}, 0))

@unsafe
def jd_choice_done(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +condition: JDOrdered) -> String:
  match condition:
    case JDOrdered{prefix, value, next}:
      "{" ++ prefix ++ jd_choice_branches(book, env, xs, value) ++ "}"

# A surrounding ordered expression owns the condition's prefixes. Keep them
# outside the pending choice value, before the prefixes of later siblings.
@unsafe
def jd_choice_ordered(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +next: U32) -> JDOrdered:
  jd_choice_ordered_done(book, env, xs, jd_ordered_expr(book, env, terms_at(xs, 1),
    j_type(book, env, terms_at(xs, 1)), False{}, next))

@unsafe
def jd_choice_ordered_done(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +condition: JDOrdered) -> JDOrdered:
  match condition:
    case JDOrdered{prefix, value, next}:
      JDOrdered{prefix, "(()=>{" ++ jd_choice_branches(book, jd_expression_env(env), xs, value) ++ "})()", next}

@unsafe
def jd_choice_branches(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +value: String) -> String:
  "/* direct literal choice */if(" ++ value ++ "){" ++
    jd_choice_arm(book, env, terms_at(xs, 2)) ++ "}else{" ++
    jd_choice_arm(book, env, terms_at(xs, 3)) ++ "}"

@unsafe
def jd_choice_arm(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> String:
  jd_body(book, env, t, j_type(book, env, t), ["({$:\"Unit\"})"])

# The scanner uses the identical admission decision. Both possible selected
# bodies are tails of the caller; the condition remains an ordinary non-tail
# computation. These scans consume the existing per-body fuel.
@unsafe
def jd_choice_calls(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +s: JDCallScan) -> JDCallScan:
  jd_calls_body(book, env, terms_at(xs, 3), j_type(book, env, terms_at(xs, 3)), 1,
    jd_calls_body(book, env, terms_at(xs, 2), j_type(book, env, terms_at(xs, 2)), 1, s))

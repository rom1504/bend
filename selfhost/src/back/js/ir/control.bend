# Structural control lowering after j_choice_call proves the original choice
# definition and both literal thunks. This does not introduce a new recognizer.
# The condition runs once; only the selected branch evaluates its Unit argument
# and body. Branch Let nodes make that ordinary scope available to shared passes.
@unsafe
def jir_lower_choice(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +tail: Bool) -> JIRExpr:
  +args = ks(spine)
  +conditionType = wnf(book, j_app_type(wnf(book, dt(lookup(book, nm(spine)))), terms_at(args, 0)))
  +branchType = wnf(book, j_app_type(conditionType, terms_at(args, 1)))
  JIRChoice{
    jir_lower(book, env, terms_at(args, 1), kid(conditionType, 0), False{}),
    jir_lower_choice_branch(book, env, j_strip(terms_at(args, 2)), wnf(book, kid(branchType, 0)), tail),
    jir_lower_choice_branch(book, env, j_strip(terms_at(args, 3)),
      wnf(book, kid(wnf(book, j_app_type(branchType, terms_at(args, 2))), 0)), tail)}

@unsafe
def jir_lower_choice_branch(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> JIRExpr:
  +erased = U32.is_eq(qt(ty), 0)
  JIRLet{[JIRParam{ix(t), erased}],
    [kc(JIRExpr, erased, u => JIRNull{}, u => JIRConstruct{"Unit", Nil{}, False{}})],
    jir_lower(book, Con{kt("Env", "", ix(t), 0, [kid(ty, 0)]), env}, kid(t, 0),
      subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), tail)}

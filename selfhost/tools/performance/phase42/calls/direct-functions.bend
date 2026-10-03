
# Bounded acyclic helpers reuse the complete original typed graph. They are
# callable only behind its full runtime guard or inside an inherited graph.
@unsafe
def j_direct_plan(+book: List<&2,KDef>, +d: KDef) -> JPure:
  kc(JPure, j_pure_eligible(book, d) &&
    (db(d) || (j_u32_bounded([dv(d)], 256) && Bool.not(j_l_deep(dv(d), 0)) &&
      j_direct_prefix(book, dv(d), dt(d), 0))), u =>
    j_direct_checked(book, d, j_pure_graph(book, d, JPure{Nil{}, 8192, True{}})),
    u => JPure{Nil{}, 0, False{}})

@unsafe
def j_direct_checked(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> JPure:
  kc(JPure, j_pure_valid(pure), u =>
    kc(JPure, j_direct_visit(book, j_pure_defs(pure), d, Nil{}, 0), u => pure,
      u => JPure{Nil{}, 0, False{}}), u => pure)

# Every path is bounded and refuses a repeated active definition. Completed
# siblings may share callees; there is no recursive native helper stack.
@unsafe
def j_direct_visit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32) -> Bool:
  kc(Bool, U32.is_lt(depth, 16) && Bool.not(has_name(active, dn(d))), u =>
    kc(Bool, db(d), u => j_pure_bool_native(book, d), u =>
      kc(Bool, j_u32_bounded([dv(d)], 256) && Bool.not(j_l_deep(dv(d), 0)) &&
        j_direct_prefix(book, dv(d), dt(d), 0), u =>
        j_direct_edges(book, graph, graph, d, Con{dn(d), active}, U32.inc(depth)), u => False{})), u => False{})

@unsafe
def j_direct_edges(+book: List<&2,KDef>, +graph: List<&2,KDef>, +rest: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32) -> Bool:
  match rest:
    case Nil{}: True{}
    case Con{callee, more}:
      kc(Bool, U32.is_gt(j_component_refs([dv(d)], dn(callee), 8192, 0), 0), u =>
        j_direct_visit(book, graph, callee, active, depth) &&
          j_direct_edges(book, graph, more, d, active, depth),
        u => j_direct_edges(book, graph, more, d, active, depth))

# JPure independently validates all expressions, argument/result types and
# complete match coverage. This test limits the emitter to its original finite
# prefix layouts; native Nat matchers keep their existing structural workers.
@unsafe
def j_direct_prefix(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(Bool, U32.is_lt(depth, 32), u =>
    kc(Bool, String.eq(tg(body), "Lam"), u =>
      String.eq(tg(head), "All") && j_direct_prefix(book, kid(body, 0),
        subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.inc(depth)), u =>
    kc(Bool, String.eq(tg(body), "Mat"), u =>
      j_direct_match(book, body, head, U32.inc(depth)), u =>
    kc(Bool, String.eq(tg(body), "Efq"), u => True{},
      u => Bool.not(String.eq(tg(head), "All"))))), u => False{})

@unsafe
def j_direct_match(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +arg = wnf(book, kid(ty, 0))
  +owner = lookup(book, nm(arg))
  String.eq(tg(ty), "All") &&
    (j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) ||
      (Bool.not(db(owner)) && j_pure_type(book, arg))) &&
    j_direct_prefix(book, kid(t, 0), j_arm_type(book, ty, nm(t)), depth) &&
    j_direct_prefix(book, kid(t, 1), ty, depth)

@unsafe
def j_direct_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  j_direct_guarded(book, env, spine, generic, j_direct_plan(book, lookup(book, nm(spine))))

@unsafe
def j_direct_guarded(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "(regionProof!==null&&regionProofCovers([" ++ j_region_names(j_pure_defs(pure)) ++ "])?" ++
      j_direct_emit_call(book, env, kt("JDirectCall", nm(spine), 0, 0, ks(spine))) ++ ":" ++ generic ++ ")",
    u => j_component_named(book, env, spine, generic))

# Rewritten nodes are private emitter plans. A typed annotation preserves
# result inference when an original parallel let binds a direct helper call.
@unsafe
def j_direct_result(+book: List<&2,KDef>, +ty: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: wnf(book, ty)
    case Con{arg, rest}: j_direct_result(book, j_app_type(wnf(book, ty), arg), rest)

@unsafe
def j_direct_term(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  +spine = j_call_spine(t, Nil{})
  kc(KTerm, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") &&
    Bool.not(j_primitive_call(book, spine)) &&
    U32.is_eq(terms_len(ks(spine)), da(lookup(book, nm(spine)))), u =>
    j_region_annotate(kt("JDirectCall", nm(spine), 0, 0, j_direct_terms(book, ks(spine))),
      j_direct_result(book, dt(lookup(book, nm(spine))), ks(spine))), u =>
    k_with_children(t, j_direct_terms(book, ks(t))))

@unsafe
def j_direct_terms(+book: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_direct_term(book, t), j_direct_terms(book, rest)}

@unsafe
def j_direct_emit_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> String:
  +d = lookup(book, nm(t))
  kc(String, db(d), u =>
    "(($p0,$p1)=>$p0!==$p1)(" ++ j_apply_args(book, env, ks(t), dt(d)) ++ ")", u =>
    "((" ++ j_region_parameters(0, da(d)) ++ ")=>{/* private acyclic helper */" ++
      j_finite_emit(book, Nil{}, j_direct_term(book, dv(d)), dt(d), j_finite_slots(0, da(d))) ++
      "})(" ++ j_apply_args(book, env, ks(t), dt(d)) ++ ")")

# The worker-context owner has independently established this exact source
# closure. A helper can omit only its own redundant boundary, never a root's.
@unsafe
def j_direct_call_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +t: KTerm) -> KTerm:
  +spine = j_call_spine(t, Nil{})
  kc(KTerm, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") &&
    String.eq(dk(lookup(context, nm(spine))), "Def") &&
    exact_def(lookup(context, nm(spine)), lookup(book, nm(spine))) &&
    U32.is_eq(terms_len(ks(spine)), da(lookup(book, nm(spine)))), u =>
    j_direct_covered_term(book, context, t, spine, j_direct_plan(book, lookup(book, nm(spine)))), u => t)

@unsafe
def j_direct_covered_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +t: KTerm, +spine: KTerm, +pure: JPure) -> KTerm:
  kc(KTerm, j_pure_valid(pure), u =>
    kc(KTerm, j_covered_defs(book, context, j_pure_defs(pure)), u =>
      j_region_annotate(kt("JDirectCall", nm(spine), 0, 0, ks(spine)),
        j_direct_result(book, dt(lookup(book, nm(spine))), ks(spine))), u => t), u => t)

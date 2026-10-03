# Acyclic private selectors reuse the original typed Lam/Mat prefix. Values
# originate in a wholly guarded scalar graph and are already fully forced.
# No helper calls, recursive workers, native constructors or new IR are added.
@unsafe
def j_finite_match(+t: KTerm) -> Bool:
  +body = j_strip(t)
  kc(Bool, String.eq(tg(body), "Mat"), u => True{}, u => j_finite_matches(ks(body)))

@unsafe
def j_finite_matches(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, rest}: kc(Bool, j_finite_match(h), u => True{}, u => j_finite_matches(rest))

@unsafe
def j_finite_ready(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) && U32.is_eq(dx(d), 0), u =>
    kc(Bool, j_u32_bounded([dv(d)], 256), u =>
    kc(Bool, j_finite_match(dv(d)), u =>
    kc(Bool, j_region_capture_eligible(book, d) && j_pure_signature(book, dt(d), da(d)), u =>
    kc(Bool, j_finite_prefix(book, Nil{}, dv(d), dt(d), 0), u =>
      j_pure_valid(j_pure_prefix(book, Nil{}, dv(d), dt(d), 0, JPure{Nil{}, 1024, True{}})),
      u => False{}), u => False{}), u => False{}), u => False{}), u => False{})

@unsafe
def j_finite_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(Bool, U32.is_lt(depth, 32), u =>
    kc(Bool, String.eq(tg(body), "Lam"), u =>
      String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && String.eq(j_l_name(body), "") &&
        j_finite_prefix(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.inc(depth)), u =>
    kc(Bool, String.eq(tg(body), "Mat"), u =>
      j_finite_arm(book, env, body, head, depth), u =>
    kc(Bool, String.eq(tg(body), "Efq"), u => True{}, u =>
      Bool.not(String.eq(tg(head), "All")) && j_finite_expr(book, env, body, head, depth)))), u => False{})

@unsafe
def j_finite_arm(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +arg = wnf(book, kid(ty, 0))
  +owner = lookup(book, nm(arg))
  +c = lookup(dc(owner), nm(t))
  String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) && String.eq(j_l_name(t), "") &&
    U32.is_eq(terms_len(ks(t)), 2) && String.eq(dk(c), "Ctr") &&
    (j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) || (Bool.not(db(owner)) && Bool.not(db(c)) && j_pure_type(book, arg))) &&
    j_finite_prefix(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), U32.inc(depth)) &&
    j_finite_prefix(book, env, kid(t, 1), ty, U32.inc(depth))

# The independent typed prefix proof validates variables, annotations and
# complete branch coverage. This additional test admits only total leaf work.
@unsafe
def j_finite_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(Bool, U32.is_lt(depth, 32), u =>
    kc(Bool, String.eq(tg(body), "Var") || String.eq(tg(body), "Lit"), u => True{}, u =>
    kc(Bool, String.eq(tg(body), "Ctr"), u =>
      j_finite_ctor(book, env, body, head, depth), u =>
    kc(Bool, String.eq(tg(body), "App"), u =>
      j_finite_primitive(book, env, j_call_spine(body, Nil{}), depth), u => False{}))), u => False{})

@unsafe
def j_finite_ctor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +depth: U32) -> Bool:
  +owner = lookup(book, nm(ty))
  +c = lookup(dc(owner), nm(t))
  String.eq(dk(c), "Ctr") && U32.is_eq(terms_len(ks(t)), da(c)) &&
    (j_primitive_type(book, ty, "Bool") || j_list_ground_type(book, ty) || (Bool.not(db(owner)) && Bool.not(db(c)))) &&
    j_finite_values(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), U32.inc(depth))

@unsafe
def j_finite_primitive(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +depth: U32) -> Bool:
  j_primitive_call(book, spine) && j_finite_values(book, env, ks(spine), dt(lookup(book, nm(spine))), U32.inc(depth))

@unsafe
def j_finite_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +depth: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}:
      +head = wnf(book, ty)
      String.eq(tg(head), "All") && j_finite_expr(book, env, h, kid(head, 0), depth) &&
        j_finite_values(book, env, rest, j_app_type(head, h), depth)

# Capture all actual arguments before introducing the callee's fresh binders.
# A complete private prefix can inspect only inert owned fields before later
# parameters; its matches cannot throw or call a host hook in an active proof.
@unsafe
def j_finite_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  kc(String, String.eq(tg(spine), "Call"), u => j_finite_named(book, env, spine, generic), u => generic)

@unsafe
def j_finite_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  +d = lookup(book, nm(spine))
  kc(String, U32.is_eq(terms_len(ks(spine)), da(d)), u => kc(String, j_finite_ready(book, d), u =>
    "(regionProof!==null&&regionProofCovers([" ++ j_quote(dn(d)) ++ "])?((" ++ j_region_parameters(0, da(d)) ++ ")=>{/* private finite selector */" ++
      j_finite_emit(book, Nil{}, dv(d), dt(d), j_finite_slots(0, da(d))) ++ "})(" ++
      j_apply_args(book, env, ks(spine), dt(d)) ++ "):" ++ generic ++ ")", u => j_direct_named(book, env, spine, generic)), u => generic)

@unsafe
def j_finite_slots(+at: U32, +total: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => Nil{}, u =>
    Con{"$p" ++ U32.show(at), j_finite_slots(U32.inc(at), total)})

@unsafe
def j_finite_fields(+value: String, +at: U32, +total: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => rest, u =>
    Con{"(" ++ value ++ ").a[" ++ U32.show(at) ++ "]", j_finite_fields(value, U32.inc(at), total, rest)})

@unsafe
def j_finite_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> String:
  match args:
    case Nil{}: "return " ++ j_expr(book, env, j_strip(t), wnf(book, ty), False{}) ++ ";"
    case Con{arg, rest}:
      +body = j_strip(t)
      +head = wnf(book, ty)
      kc(String, String.eq(tg(body), "Lam"), u =>
        "const " ++ j_local(ix(body)) ++ "=" ++ arg ++ ";" ++
        j_finite_emit(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), rest), u =>
      kc(String, String.eq(tg(body), "Mat"), u =>
        j_finite_emit_match(book, env, body, head, arg, rest), u => "return bad('private finite sum invariant');"))

@unsafe
def j_finite_emit_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>) -> String:
  +input = wnf(book, kid(ty, 0))
  +c = lookup(dc(lookup(book, nm(input))), nm(t))
  "if(" ++ kc(String, j_primitive_type(book, input, "Bool"),
    u => "(" ++ arg ++ ")===" ++ kc(String, String.eq(nm(t), "True"), u => "true", u => "false"),
    u => "(" ++ arg ++ ").$===" ++ j_quote(nm(t))) ++ "){" ++
    j_finite_emit(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), j_flat_fields(book, input, arg, 0, da(c), rest)) ++ "}else{" ++
    j_finite_emit(book, env, kid(t, 1), ty, Con{arg, rest}) ++ "}"

# Generic residual functions can use these selectors without a new recursive
# worker: open a proof only for a complete scalar root with useful selectors.
# Scalar-only selectors do not justify another full host/dependency boundary.
@unsafe
def j_finite_useful(+book: List<&2,KDef>, +ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}:
      kc(Bool, j_region_signature(book, dt(d), da(d)), u => j_finite_useful(book, rest), u =>
        kc(Bool, j_finite_ready(book, d), u => True{}, u => j_finite_useful(book, rest)))

@unsafe
def j_finite_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) && U32.is_eq(dx(d), 0), u =>
    kc(String, j_u32_bounded([dv(d)], 512), u =>
    kc(String, j_region_capture_eligible(book, d) && j_region_signature(book, dt(d), da(d)) &&
    U32.is_eq(j_nat_loop_count(dv(d), 0), da(d)) && j_nat_loop_distinct(dv(d), Nil{}) &&
    Bool.not(j_l_deep(dv(d), 0)), u =>
    j_finite_root_done(book, d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}})), u => ""), u => ""), u => "")

@unsafe
def j_finite_root_done(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u => kc(String, j_finite_useful(book, j_pure_defs(pure)), u =>
    "(()=>{const $guards=[" ++ j_region_names(j_pure_defs(pure)) ++ "];return fn(" ++ U32.show(da(d)) ++
    ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&regionProof===null&&regionHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++ "&&localGuard($guards)){/* private finite root */" ++
    "const $previousProof=regionProofOpen($guards);try{return force((()=>{" ++ j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++
    "})());}finally{regionProofClose($previousProof);}}" ++ j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()", u => ""), u => "")

@unsafe
def j_finite_global(+book: List<&2,KDef>, +d: KDef, +worker: String) -> String:
  kc(String, String.eq(worker, ""), u =>
    kc(String, j_l_deep(dv(d), 0), u => j_l_definition(book, d, j_l_mark(dv(d), "r", 0)), u => j_l_global(book, d, dv(d))),
    u => j_l_global_worker(book, d, dv(d), worker))

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
    kc(JPure, j_region_local_ok(j_direct_expand_def(book, d, Nil{}, 2048)), u =>
      kc(JPure, j_direct_visit(book, j_pure_defs(pure), d, Nil{}, 0), u => pure,
        u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => pure)

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
  j_direct_guarded(book, env, spine, generic, j_direct_cached(book, nm(spine)))

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
  kc(KTerm, String.eq(tg(t), "Ann"), u =>
    k_with_children(t, [j_direct_term(book, kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") &&
    String.eq(dk(lookup(book, nm(spine))), "Def") &&
    U32.is_gt(da(lookup(book, nm(spine))), 0) && Bool.not(j_primitive_call(book, spine)) &&
    U32.is_eq(terms_len(ks(spine)), da(lookup(book, nm(spine)))), u =>
    j_region_annotate(kt("JDirectCall", nm(spine), 0, 0, j_direct_terms(book, ks(spine))),
      j_direct_result(book, dt(lookup(book, nm(spine))), ks(spine))), u =>
    k_with_children(t, j_direct_terms(book, ks(t)))))

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
      j_finite_emit(book, Nil{}, j_owned_term(j_direct_term(book, dv(d))), dt(d), j_finite_slots(0, da(d))) ++
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
    j_direct_covered_term(book, context, t, spine, j_direct_cached(book, nm(spine))), u => t)

@unsafe
def j_direct_covered_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +t: KTerm, +spine: KTerm, +pure: JPure) -> KTerm:
  kc(KTerm, j_pure_valid(pure), u =>
    kc(KTerm, j_covered_defs(book, context, j_pure_defs(pure)), u =>
      j_region_annotate(kt("JDirectCall", nm(spine), 0, 0, ks(spine)),
        j_direct_result(book, dt(lookup(book, nm(spine))), ks(spine))), u => t), u => t)

# Count every copied callee body at every call occurrence, rather than unique
# graph nodes. Fuel bounds total inline expansion and refuses before emission.
@unsafe
def j_direct_expand_def(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && Bool.not(has_name(active, dn(d))), u =>
    kc(Maybe<&2,U32>, db(d), u => Some{U32.sub(fuel, 1)},
      u => j_direct_expand_term(book, dv(d), Con{dn(d), active}, U32.sub(fuel, 1))), u => None{})

@unsafe
def j_direct_expand_term(+book: List<&2,KDef>, +t: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +spine = j_call_spine(t, Nil{})
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    kc(Maybe<&2,U32>, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") &&
      String.eq(dk(d), "Def") && U32.is_gt(da(d), 0) &&
      Bool.not(j_primitive_call(book, spine)) && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
      j_direct_expand_after(book, d, active,
        j_direct_expand_terms(book, ks(spine), active, U32.sub(fuel, 1))),
      u => j_direct_expand_terms(book, ks(t), active, U32.sub(fuel, 1))), u => None{})

@unsafe
def j_direct_expand_terms(+book: List<&2,KDef>, +ts: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match ts:
    case Nil{}: Some{fuel}
    case Con{t, rest}: j_direct_expand_more(book, rest, active, j_direct_expand_term(book, t, active, fuel))

@unsafe
def j_direct_expand_more(+book: List<&2,KDef>, +ts: List<&2,KTerm>, +active: List<&2,String>, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{fuel}: j_direct_expand_terms(book, ts, active, fuel)

@unsafe
def j_direct_expand_after(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{fuel}: j_direct_expand_def(book, d, active, fuel)

# Bounded purity proof for residual generic calls. This validates source terms,
# not private lowering plans. No failed lowering is treated as a purity proof.
type JPure is Data:
  JPure{+defs: List<&2,KDef>, +fuel: U32, +valid: Bool}

@unsafe
def j_pure_defs(+s: JPure) -> List<&2,KDef>:
  match s:
    case JPure{ds, fuel, valid}: ds

@unsafe
def j_pure_fuel(+s: JPure) -> U32:
  match s:
    case JPure{ds, fuel, valid}: fuel

@unsafe
def j_pure_valid(+s: JPure) -> Bool:
  match s:
    case JPure{ds, fuel, valid}: valid

@unsafe
def j_pure_fail(+s: JPure) -> JPure:
  JPure{j_pure_defs(s), 0, False{}}

@unsafe
def j_pure_tick(+s: JPure) -> JPure:
  JPure{j_pure_defs(s), U32.sub(j_pure_fuel(s), 1), j_pure_valid(s)}

# Closed recursive tagged ADTs: no parameters, native arrays, functions, foreign
# representations or dependent fields. An active owner still has every one of
# its constructors checked by the pending outer visit.
@unsafe
def j_pure_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_region_local_ok(j_pure_type_check(book, ty, Nil{}, 512))

@unsafe
def j_pure_type_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_type_head(book, wnf(book, ty), active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_pure_type_head(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, nm(ty))
  +kind = wnf(book, dt(owner))
  kc(Maybe<&2,U32>, j_region_scalar(book, ty) || j_list_ground_type(book, ty) || j_string_char_type(book, ty) || j_string_string(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, ty), u => j_pure_map_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, ty), u => j_pure_sigma_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, String.eq(tg(ty), "ADT") && U32.is_eq(terms_len(ks(ty)), 0) && List.is_empty(&2, String, rm(ty)) &&
      String.eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
      String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) && String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2), u =>
      kc(Maybe<&2,U32>, has_name(active, nm(ty)), u => Some{fuel}, u =>
        kc(Maybe<&2,U32>, Bool.not(List.is_empty(&2, KDef, dc(owner))) && U32.is_le(j_region_def_count(dc(owner)), 32), u =>
          j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{})))))

@unsafe
def j_pure_type_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +owner: String, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match cs:
    case Nil{}: Some{fuel}
    case Con{c, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && String.eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 32), u =>
        j_pure_type_ctor_next(book, rest, owner, active, j_pure_type_fields(book, dt(c), owner, da(c), active, U32.sub(fuel, 1))), u => None{})

@unsafe
def j_pure_type_ctor_next(+book: List<&2,KDef>, +rest: List<&2,KDef>, +owner: String, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_ctors(book, rest, owner, active, fuel)
    case None{}: None{}

@unsafe
def j_pure_type_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +head = wnf(book, ty)
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, String.eq(tg(head), "ADT") && String.eq(nm(head), owner) && U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)),
      u => Some{fuel}, u => None{}), u =>
    kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
      j_pure_type_field_next(book, kid(head, 1), owner, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(head, 0), active, U32.sub(fuel, 1))), u => None{}))

@unsafe
def j_pure_type_field_next(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_fields(book, ty, owner, left, active, fuel)
    case None{}: None{}

@unsafe
def j_pure_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_pure_type(book, head), u =>
    kc(Bool, U32.is_le(left, 32) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)),
      u => j_pure_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Only this residual native escapes ordinary primitive expression lowering.
@unsafe
def j_pure_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  j_pure_bool_native(book, d) || j_pure_nat_native(book, d) || (String.eq(dn(d), "F32.to_u32") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 1) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) && String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "F32") && j_primitive_type(book, wnf(book, kid(ty, 1)), "U32"))

# The residual call keeps its ordinary native ABI; only its closed signature
# and immutable captured descriptor can participate in a private root proof.
@unsafe
def j_pure_bool_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  String.eq(dn(d), "Bool.xor") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) && String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Bool") && String.eq(tg(rest), "All") && Bool.not(U32.is_eq(qt(rest), 0)) &&
    j_primitive_type(book, wnf(book, kid(rest, 0)), "Bool") && j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool")

@unsafe
def j_pure_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  j_string_literal(book, d) || (String.eq(dk(d), "Def") && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(dx(d), 0) &&
    j_pure_signature(book, dt(d), da(d)) &&
    kc(Bool, db(d), u => j_pure_native(book, d), u =>
      (String.eq(tg(j_strip(dv(d))), "Lam") || String.eq(tg(j_strip(dv(d))), "Mat")) && j_u32_bounded([dv(d)], 8192)))

@unsafe
def j_pure_add(+d: KDef, +s: JPure) -> JPure:
  kc(JPure, String.eq(dk(lookup(j_pure_defs(s), dn(d))), "Def"), u => s, u =>
    kc(JPure, U32.is_lt(j_region_def_count(j_pure_defs(s)), 32),
      u => JPure{Con{d, j_pure_defs(s)}, j_pure_fuel(s), j_pure_valid(s)}, u => j_pure_fail(s)))

# Validate the complete own body into a separate callee list before reserving
# a graph node. Backedges can then stop without skipping any body obligation.
@unsafe
def j_pure_graph(+book: List<&2,KDef>, +d: KDef, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0), u =>
    kc(JPure, String.eq(dk(lookup(j_pure_defs(s), dn(d))), "Def"), u => s, u =>
      kc(JPure, j_pure_eligible(book, d), u =>
        kc(JPure, db(d), u => j_pure_add(d, j_pure_tick(s)), u =>
          j_pure_graph_body(book, d, s, j_pure_prefix(book, Nil{}, dv(d), dt(d), 0, JPure{Nil{}, U32.sub(j_pure_fuel(s), 1), True{}}))), u => j_pure_fail(s))), u => j_pure_fail(s))

@unsafe
def j_pure_graph_body(+book: List<&2,KDef>, +d: KDef, +s: JPure, +body: JPure) -> JPure:
  kc(JPure, j_pure_valid(body), u =>
    j_pure_graph_callees(book, j_pure_defs(body), j_pure_add(d, JPure{j_pure_defs(s), j_pure_fuel(body), True{}})), u => j_pure_fail(s))

@unsafe
def j_pure_graph_callees(+book: List<&2,KDef>, +ds: List<&2,KDef>, +s: JPure) -> JPure:
  match ds:
    case Nil{}: s
    case Con{d, rest}:
      kc(JPure, j_pure_valid(s), u => j_pure_graph_callees(book, rest, j_pure_graph(book, d, s)), u => s)

@unsafe
def j_pure_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128), u =>
    kc(JPure, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)), u =>
      kc(JPure, String.eq(tg(body), "Lam") && String.eq(j_l_name(body), ""), u =>
        j_pure_prefix(book, Con{kt("Env", "", ix(body), 0, [wnf(book, kid(head, 0))]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.inc(level), j_pure_tick(s)), u =>
        kc(JPure, String.eq(tg(body), "Mat") && String.eq(j_l_name(body), ""), u =>
          j_pure_match(book, env, body, head, dc(lookup(book, nm(wnf(book, kid(head, 0))))), U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s))),
      u => j_pure_expr(book, env, body, head, level, s)), u => j_pure_fail(s))

@unsafe
def j_pure_remove(+ds: List<&2,KDef>, +name: String) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, String.eq(dn(d), name), u => rest, u => Con{d, j_pure_remove(rest, name)})

# Complete constructor coverage avoids speculative work before a refutable
# prefix could throw. Default lambdas retain their original typed input.
@unsafe
def j_pure_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +remaining: List<&2,KDef>, +level: U32, +s: JPure) -> JPure:
  +body = j_strip(t)
  +c = lookup(remaining, nm(body))
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128), u =>
    kc(JPure, String.eq(tg(body), "Mat") && String.eq(dk(c), "Ctr") && U32.is_eq(terms_len(ks(body)), 2), u =>
      j_pure_match_next(book, env, body, ty, j_pure_remove(remaining, nm(body)), U32.inc(level),
        j_pure_prefix(book, env, kid(body, 0), j_arm_type(book, ty, nm(body)), U32.inc(level), j_pure_tick(s))), u =>
      kc(JPure, String.eq(tg(body), "Efq") && U32.is_eq(terms_len(ks(body)), 0) && List.is_empty(&2, KDef, remaining), u => j_pure_tick(s), u =>
        kc(JPure, String.eq(tg(body), "Lam"), u => j_pure_prefix(book, env, body, ty, U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s)))), u => j_pure_fail(s))

@unsafe
def j_pure_match_next(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +remaining: List<&2,KDef>, +level: U32, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s), u => j_pure_match(book, env, kid(t, 1), ty, remaining, level, s), u => s)

@unsafe
def j_pure_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128) && j_pure_type(book, ty), u =>
    j_pure_expr_on(book, env, t, wnf(book, ty), U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s))

@unsafe
def j_pure_expr_on(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  kc(JPure, String.eq(tg(t), "Ann"), u =>
    kc(JPure, j_pure_type(book, kid(t, 1)) && j_pure_same_closed(book, kid(t, 1), ty, 64), u =>
      j_pure_expr(book, env, kid(t, 0), ty, level, s), u => j_pure_fail(s)), u =>
  kc(JPure, String.eq(tg(t), "Var"), u =>
    kc(JPure, j_pure_type(book, j_env(env, ix(t))) && j_pure_same_closed(book, j_env(env, ix(t)), ty, 64), u => s, u => j_pure_fail(s)), u =>
  kc(JPure, String.eq(tg(t), "Ref"), u =>
    kc(JPure, j_string_literal(book, lookup(book, nm(t))) && j_pure_same_closed(book, dt(lookup(book, nm(t))), ty, 64), u => j_pure_add(lookup(book, nm(t)), s), u => j_pure_fail(s)), u =>
  kc(JPure, String.eq(tg(t), "Lit"), u =>
    kc(JPure, String.eq(nm(t), nm(ty)) && String.contains("|U32|Nat|F32|String|Char|", "|" ++ nm(t) ++ "|"), u => s, u => j_pure_fail(s)), u =>
  kc(JPure, String.eq(tg(t), "Ctr"), u => j_pure_constructor(book, env, t, ty, level, s), u =>
  kc(JPure, String.eq(tg(t), "Let"), u =>
    j_pure_bindings(book, env, j_context(book, env, ks(t)), ks(t), ty, level, s), u =>
  kc(JPure, String.eq(tg(t), "App"), u => j_pure_call(book, env, j_call_spine(t, Nil{}), ty, level, s), u => j_pure_fail(s))))))))

@unsafe
def j_pure_constructor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +c = lookup(dc(lookup(book, nm(ty))), nm(t))
  kc(JPure, String.eq(dk(c), "Ctr") && U32.is_eq(terms_len(ks(t)), da(c)),
    u => j_pure_args(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), ty, level, s), u => j_pure_fail(s))

@unsafe
def j_pure_bindings(+book: List<&2,KDef>, +env: List<&2,KTerm>, +bodyEnv: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  match xs:
    case Nil{}: j_pure_fail(s)
    case Con{body, Nil{}}: j_pure_expr(book, bodyEnv, body, ty, level, s)
    case Con{bind, rest}:
      kc(JPure, j_pure_valid(s) && String.eq(tg(bind), "Bind") && Bool.not(U32.is_eq(qt(bind), 0)) && U32.is_eq(terms_len(ks(bind)), 1), u =>
        j_pure_bindings(book, env, bodyEnv, rest, ty, level,
          j_pure_expr(book, env, kid(bind, 0), j_region_type(book, env, kid(bind, 0)), level, s)), u => j_pure_fail(s))

@unsafe
def j_pure_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +d = lookup(book, nm(spine))
  kc(JPure, String.eq(tg(spine), "Call") && (U32.is_gt(da(d), 0) || j_string_literal(book, d)) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(JPure, j_primitive_call(book, spine), u => j_pure_args(book, env, ks(spine), dt(d), ty, level, s), u =>
      kc(JPure, j_pure_eligible(book, d), u => j_pure_args(book, env, ks(spine), dt(d), ty, level, j_pure_add(d, s)), u => j_pure_fail(s))), u => j_pure_fail(s))

@unsafe
def j_pure_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +result: KTerm, +level: U32, +s: JPure) -> JPure:
  j_pure_args_head(book, env, xs, wnf(book, ty), result, level, s)

@unsafe
def j_pure_args_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +head: KTerm, +result: KTerm, +level: U32, +s: JPure) -> JPure:
  match xs:
    case Nil{}:
      kc(JPure, j_pure_type(book, head) && j_pure_same_closed(book, head, result, 64), u => s, u => j_pure_fail(s))
    case Con{h, rest}:
      kc(JPure, j_pure_valid(s) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)), u =>
        j_pure_args(book, env, rest, j_app_type(head, h), result, level,
          j_pure_expr(book, env, h, kid(head, 0), level, s)), u => j_pure_fail(s))

# The direct plan and purity proof are independent. A refused direct plan is
# discarded, including its tentative helpers and fuel; the residual proof starts
# from the original state and must establish every reachable body obligation.
@unsafe
def j_region_try_helper(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +original: JRegionBuild, +direct: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(direct), u =>
    j_region_call_helper(book, env, spine, ty, active, depth, level, direct), u =>
    kc(JRegionBuild, j_pure_signature(book, dt(lookup(book, nm(spine))), terms_len(ks(spine))), u =>
      j_region_residual_proved(book, env, spine, ty, active, depth, level, original,
        j_pure_graph(book, lookup(book, nm(spine)), JPure{Nil{}, j_region_fuel(original), True{}})), u => j_region_fail(original)))

@unsafe
def j_region_residual_proved(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +original: JRegionBuild, +pure: JPure) -> JRegionBuild:
  kc(JRegionBuild, j_pure_valid(pure), u =>
    j_region_call_helper(book, env, spine, ty, active, depth, level,
      j_region_residual_merge(j_pure_defs(pure), JRegionBuild{j_region_term(original), j_region_helpers(original), j_pure_fuel(pure), True{}})), u => j_region_fail(original))

@unsafe
def j_region_residual_merge(+ds: List<&2,KDef>, +s: JRegionBuild) -> JRegionBuild:
  match ds:
    case Nil{}: s
    case Con{d, rest}:
      kc(JRegionBuild, j_region_valid(s), u =>
        kc(JRegionBuild, String.eq(dk(lookup(j_region_helpers(s), dn(d))), "Def"), u => j_region_residual_merge(rest, s), u =>
          kc(JRegionBuild, U32.is_lt(j_region_def_count(j_region_helpers(s)), 32), u =>
            j_region_residual_merge(rest, JRegionBuild{j_region_term(s),
              Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), kt("JResidual", "", 0, 0, [dv(d)]), dc(d), db(d), du(d)}, j_region_helpers(s)},
              j_region_fuel(s), True{}}), u => j_region_fail(s))), u => s)

@unsafe
def j_region_has_residual(+ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: String.eq(tg(dv(d)), "JResidual") || j_region_has_residual(rest)


# Exact planner results belong to one immutable JS emission request. The first
# BookCache child stays the original source index; the second is private facts.
# Logical planners still accept arbitrary definitions and never use name-only
# facts. Cached entry points always obtain the original definition by lookup.
@unsafe
def j_component_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, False{})
  kc(JPure, String.eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_component_plan(book, lookup(book, name)))

@unsafe
def j_direct_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, True{})
  kc(JPure, String.eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_direct_plan(book, lookup(book, name)))

@unsafe
def j_plan_lookup(+book: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{cache, rest}:
      kc(KDef, String.eq(dk(cache), "BookCache"),
        u => j_plan_payload(dc(cache), name, direct), u => missing())

@unsafe
def j_plan_payload(+children: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match children:
    case Nil{}: missing()
    case Con{source, rest}:
      +payload = index_first(rest)
      kc(KDef, String.eq(dk(payload), "JSPlanContext") && String.eq(dn(payload), "$js.plans"),
        u => j_plan_index(dc(payload), name, direct), u => missing())

@unsafe
def j_plan_index(+indexes: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match indexes:
    case Nil{}: missing()
    case Con{component, rest}:
      index_find(kc(KDef, direct, u => index_first(rest), u => component), name, index_hash(name, 2166136261), 32)

@unsafe
def j_plan_fact(+name: String, +pure: JPure) -> KDef:
  KDef{name, "JSPlanFact", j_pure_fuel(pure), 0, atom("Absent"), atom("Absent"), j_pure_defs(pure), j_pure_valid(pure), False{}}

# Strip any prior facts before preparing a fresh request. Source lookup and
# maximum binder identity remain exactly those of the incoming BookCache.
@unsafe
def j_plan_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, String.eq(dk(cache), "BookCache"), u =>
        j_plan_prepare(KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache))], db(cache), du(cache)}, rest, defs), u => book)

@unsafe
def j_plan_prepare(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  +source = {Con{cache, rest} : List<&2,KDef>}
  +components = j_plan_components(source, defs, book_cached(Nil{}, 0))
  +directs = j_plan_directs(source, j_plan_needed(source, defs, book_cached(Nil{}, 0)), book_cached(Nil{}, 0))
  Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
    [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, atom("Absent"), atom("Absent"),
      [index_first(dc(index_first(components))), index_first(dc(index_first(directs)))], False{}, False{}}], db(cache), du(cache)}, rest}

# Only definitions whose ordinary emitter already asks for a component plan.
# Duplicate selected names share the canonical original definition once.
@unsafe
def j_plan_emitted(+d: KDef) -> Bool:
  String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(dv(d)), "Absent")) && Bool.not(String.eq(tg(dv(d)), "Foreign"))

@unsafe
def j_plan_components(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_components(book, rest, kc(List<&2,KDef>, j_plan_emitted(d) && String.eq(dk(lookup(done, dn(d))), "Absent"),
        u => book_put(done, j_plan_fact(dn(d), j_component_plan(book, lookup(book, dn(d))))), u => done))

# The scan gathers saturated nonprimitive source call targets. Its bound only
# limits reuse: every uncollected target still runs the unchanged logical plan.
@unsafe
def j_plan_needed(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_needed(book, rest, kc(List<&2,KDef>, j_plan_emitted(d),
        u => j_plan_scan(book, [dv(d)], 8192, done), u => done))

@unsafe
def j_plan_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32, +done: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: done
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_plan_scan(book, List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1),
          kc(List<&2,KDef>, String.eq(tg(t), "App"),
            u => j_plan_call(book, j_call_spine(t, Nil{}), done), u => done)), u => done)

@unsafe
def j_plan_call(+book: List<&2,KDef>, +spine: KTerm, +done: List<&2,KDef>) -> List<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(List<&2,KDef>, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) && Bool.not(j_primitive_call(book, spine)) &&
    String.eq(dk(lookup(done, dn(d))), "Absent"), u => book_put(done, d), u => done)

@unsafe
def j_plan_directs(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_directs(book, rest, kc(List<&2,KDef>, String.eq(dk(d), "Def"),
        u => book_put(done, j_plan_fact(dn(d), j_direct_plan(book, lookup(book, dn(d))))), u => done))

# Exact closed native containers. The root graph proves ownership separately;
# these predicates never grant public entry and do not change U32 List selectors.
@unsafe
def j_pure_native_ctor(+c: KDef, +name: String, +arity: U32) -> Bool:
  String.eq(dk(c), "Ctr") && db(c) && String.eq(dn(c), name) && U32.is_eq(da(c), arity) && U32.is_eq(dx(c), 0)

@unsafe
def j_pure_list_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "List")
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "List") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && String.eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 2) &&
    j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "Nil"), "Nil", 0) && j_pure_native_ctor(lookup(dc(owner), "Con"), "Con", 2)

@unsafe
def j_pure_shape_bound(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0), u =>
      j_pure_shape_bound(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

@unsafe
def j_pure_sigma_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Sigma")
  +family = kid(ty, 3)
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Sigma") && U32.is_eq(terms_len(ks(ty)), 4) &&
    List.is_empty(&2, String, rm(ty)) && String.eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 4) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 1) &&
    String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 1) && List.is_empty(&2, KTerm, ks(kid(ty, 0))) &&
    String.eq(tg(kid(ty, 1)), "Qua") && U32.is_eq(qt(kid(ty, 1)), 1) && List.is_empty(&2, KTerm, ks(kid(ty, 1))) &&
    String.eq(tg(family), "Lam") && U32.is_eq(qt(family), 1) && U32.is_eq(terms_len(ks(family)), 1) &&
    List.is_empty(&2, String, rm(family)) && j_pure_shape_bound([family], 256) &&
    U32.is_eq(j_region_counter_uses([kid(family, 0)], ix(family), 0), 0) &&
    j_pure_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "Tuple"), "Tuple", 2)

@unsafe
def j_pure_sigma_kind(+ty: KTerm) -> Bool:
  +q = kid(ty, 0)
  String.eq(tg(ty), "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    kc(Bool, String.eq(tg(q), "Qua"), u => U32.is_eq(qt(q), 1) && List.is_empty(&2, KTerm, ks(q)), u =>
      String.eq(tg(q), "Min") && U32.is_eq(terms_len(ks(q)), 2) &&
      String.eq(tg(kid(q, 0)), "Qua") && U32.is_eq(qt(kid(q, 0)), 1) && List.is_empty(&2, KTerm, ks(kid(q, 0))) &&
      String.eq(tg(kid(q, 1)), "Qua") && U32.is_eq(qt(kid(q, 1)), 1) && List.is_empty(&2, KTerm, ks(kid(q, 1))))

@unsafe
def j_pure_closed_list(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_list_head(book, head) && j_pure_type(book, head)

@unsafe
def j_pure_closed_sigma(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_sigma_head(book, head) && j_pure_type(book, head)

# Parameterless canonical user/scalar owners need no alpha comparison. List and
# independent Sigma compare their complete normalized specialization recursively.
@unsafe
def j_pure_same_closed(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Bool:
  j_region_local_ok(j_pure_same_check(book, a, b, fuel))

@unsafe
def j_pure_same_check(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u => j_pure_same_heads(book, wnf(book, a), wnf(book, b), U32.sub(fuel, 1)), u => None{})

@unsafe
def j_pure_same_heads(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, String.eq(nm(a), "Map") || String.eq(nm(b), "Map"), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(nm(a), "List") || String.eq(nm(b), "List"), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, a) && j_pure_list_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(nm(a), "Sigma") || String.eq(nm(b), "Sigma"), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b), u =>
      j_pure_same_next(book, kid(kid(a, 3), 0), kid(kid(b, 3), 0),
        j_pure_same_check(book, kid(a, 2), kid(b, 2), fuel)), u => None{}), u =>
    kc(Maybe<&2,U32>, String.eq(tg(a), "ADT") && String.eq(tg(b), "ADT") && String.eq(nm(a), nm(b)) &&
      List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)) &&
      List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{}))))

@unsafe
def j_pure_same_next(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case Some{fuel}: j_pure_same_check(book, a, b, fuel)
    case None{}: None{}

# Native constructors retain exact field quantities and complete terminal type.
# A List tail is checked against its current specialization, not recursively
# re-expanded. Its element already consumes the shared type-proof budget.
@unsafe
def j_pure_closed_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_closed_fields_head(book, wnf(book, tel), expected, left, active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_pure_closed_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) &&
    j_pure_same_closed(book, kid(tel, 0), j_pure_closed_field(expected, left), 64), u =>
    kc(Maybe<&2,U32>, String.eq(nm(expected), "List") && U32.is_eq(left, 1), u =>
      kc(Maybe<&2,U32>, j_pure_same_closed(book, kid(tel, 0), expected, 64), u =>
        j_pure_closed_fields(book, kid(tel, 1), expected, 0, active, fuel), u => None{}), u =>
      j_pure_closed_fields_next(book, kid(tel, 1), expected, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(tel, 0), active, fuel))), u => None{}))

@unsafe
def j_pure_closed_field(+ty: KTerm, +left: U32) -> KTerm:
  kc(KTerm, String.eq(nm(ty), "List"), u => kc(KTerm, U32.is_eq(left, 2), u => kid(ty, 1), u => ty), u =>
    kc(KTerm, U32.is_eq(left, 2), u => kid(ty, 2), u => kid(kid(ty, 3), 0)))

@unsafe
def j_pure_closed_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_closed_fields(book, tel, expected, left, active, fuel)
    case None{}: None{}

@unsafe
def j_pure_list_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "List")
  j_pure_closed_fields_next(book, j_specialize(book, dt(lookup(dc(owner), "Con")), ks(ty)), ty, 2, active,
    j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Nil")), ks(ty)), ty, 0, active, fuel))

@unsafe
def j_pure_sigma_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "Sigma")
  j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Tuple")), ks(ty)), ty, 2, active, fuel)

# Residual Nat addition keeps its original checkedNat runtime call and range
# errors. Native registration captures exactly that immutable descriptor; no
# direct/flat native emitter is widened by this source-signature proof.
@unsafe
def j_pure_nat_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  String.eq(dn(d), "Nat.add") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) && String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 1) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) &&
    j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat")

# Proposed exact proofs; integrate only with all runtime/capture consumers.
@unsafe
def j_string_owner(+book: List<&2,KDef>, +ty: KTerm, +name: String, +count: U32) -> Bool:
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(nm(ty), name) && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty)),
    u => j_string_owner_header(book, name, count), u => False{})

@unsafe
def j_string_owner_header(+book: List<&2,KDef>, +name: String, +count: U32) -> Bool:
  +owner = lookup(book, name)
  +kind = wnf(book, dt(owner))
  String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), count) && String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) && List.is_empty(&2, KTerm, ks(kid(kind, 0)))

@unsafe
def j_string_char_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_string_owner(book, ty, "Char", 1), u => j_string_char_type_fields(book), u => False{})

@unsafe
def j_string_char_type_fields(+book: List<&2,KDef>) -> Bool:
  +c = lookup(dc(lookup(book, "Char")), "Chr")
  +tel = wnf(book, dt(c))
  j_pure_native_ctor(c, "Chr", 1) &&
    String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) && U32.is_eq(terms_len(ks(tel)), 2) &&
    j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") && j_string_owner(book, wnf(book, kid(tel, 1)), "Char", 1)

@unsafe
def j_string_string(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_string_owner(book, ty, "String", 2), u => j_string_string_fields(book), u => False{})

@unsafe
def j_string_string_fields(+book: List<&2,KDef>) -> Bool:
  +cs = dc(lookup(book, "String"))
  +nil = lookup(cs, "SNil")
  +con = lookup(cs, "SCon")
  +tel = wnf(book, dt(con))
  +rest = wnf(book, kid(tel, 1))
  j_pure_native_ctor(nil, "SNil", 0) && j_pure_native_ctor(con, "SCon", 2) &&
    j_string_owner(book, wnf(book, dt(nil)), "String", 2) && String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) &&
    U32.is_eq(terms_len(ks(tel)), 2) && j_string_char_type(book, wnf(book, kid(tel, 0))) &&
    String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) && U32.is_eq(terms_len(ks(rest)), 2) &&
    j_string_owner(book, wnf(book, kid(rest, 0)), "String", 2) && j_string_owner(book, wnf(book, kid(rest, 1)), "String", 2)

@unsafe
def j_string_literal(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0),
    u => j_string_literal_body(book, d), u => False{})

@unsafe
def j_string_literal_body(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +body = j_strip(dv(d))
  +head = wnf(book, dt(d))
  kc(Bool, String.eq(tg(body), "Lit") && String.eq(nm(body), nm(head)) &&
    String.contains("|U32|Nat|F32|String|Char|", "|" ++ nm(body) ++ "|") && j_u32_bounded([body], 256),
      u => j_pure_type(book, head), u => False{})

# Conservatively mark every syntactic String/Char/native constructor occurrence;
# unknown/fuel exhaustion marks the host family too, never silently ignores it.
@unsafe
def j_string_uses(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || String.contains("|String|Char|SNil|SCon|Chr|", "|" ++ nm(t) ++ "|"), u => True{}, u =>
        j_string_uses(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)))

# Bounded normalized typed-family walk. The flat queue shares one work budget;
# the seen owner set avoids recursive/copy expansion. Unknown/exhaustion=>true.
@unsafe
def j_string_family(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{ty, rest}:
      kc(Bool, U32.is_eq(fuel, 0), u => True{}, u =>
        j_string_family_head(book, wnf(book, ty), rest, seen, U32.sub(fuel, 1)))

@unsafe
def j_string_family_head(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  kc(Bool, String.eq(nm(ty), "String") || String.eq(nm(ty), "Char"), u => True{}, u =>
  kc(Bool, j_region_scalar(book, ty), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "All"), u => j_string_family(book, Con{kid(ty, 0), Con{kid(ty, 1), todo}}, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "Qua") && List.is_empty(&2, KTerm, ks(ty)), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "Lam") && U32.is_eq(terms_len(ks(ty)), 1), u => j_string_family(book, Con{kid(ty, 0), todo}, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(dk(lookup(book, nm(ty))), "ADT"), u =>
    kc(Bool, has_name(seen, nm(ty)), u => j_string_family(book, List.append(&2, KTerm, ks(ty), todo), seen, fuel), u =>
      j_string_family(book, j_string_family_ctors(book, dc(lookup(book, nm(ty))), ks(ty), List.append(&2, KTerm, ks(ty), todo)), Con{nm(ty), seen}, fuel)), u => True{}))))))

@unsafe
def j_string_family_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +args: List<&2,KTerm>, +todo: List<&2,KTerm>) -> List<&2,KTerm>:
  match cs:
    case Nil{}: todo
    case Con{c, rest}: Con{j_specialize(book, dt(c), args), j_string_family_ctors(book, rest, args, todo)}

# Exact native Map<&2,scalar> specialization. Constructor rows are validated;
# owner names alone never grant shape/ownership or public argument permission.
@unsafe
def j_pure_map_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Map")
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Map") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && j_region_scalar(book, kid(ty, 1)) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "MTip"), "MTip", 0) &&
    j_pure_native_ctor(lookup(dc(owner), "MLeaf"), "MLeaf", 2) &&
    j_pure_native_ctor(lookup(dc(owner), "MNode"), "MNode", 3)

@unsafe
def j_pure_closed_map(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_map_head(book, head) && j_pure_type(book, head)

@unsafe
def j_pure_map_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_map_fields_head(book, wnf(book, tel), expected, fields, active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_pure_map_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match fields:
    case Nil{}:
      kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{})
    case Con{h, rest}:
      kc(Maybe<&2,U32>, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) &&
        j_pure_same_closed(book, kid(tel, 0), h, 64), u =>
        kc(Maybe<&2,U32>, j_pure_same_closed(book, h, expected, 64), u =>
          j_pure_map_fields(book, kid(tel, 1), expected, rest, active, fuel), u =>
          j_pure_map_fields_next(book, kid(tel, 1), expected, rest, active,
            j_pure_type_check(book, h, active, fuel))), u => None{})

@unsafe
def j_pure_map_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}: j_pure_map_fields(book, tel, expected, fields, active, fuel)

@unsafe
def j_pure_map_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Map"))
  j_pure_map_leaf(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "MTip")), ks(ty)), ty, Nil{}, active, fuel))

@unsafe
def j_pure_map_leaf(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MLeaf")
      j_pure_map_node(book, ty, active,
        j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
          [kt("ADT", "String", 0, 0, Nil{}), kid(ty, 1)], active, fuel))

@unsafe
def j_pure_map_node(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MNode")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
        [kt("ADT", "Nat", 0, 0, Nil{}), ty, ty], active, fuel)

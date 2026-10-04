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
  kc(Maybe<&2,U32>, j_region_scalar(book, ty) || j_map_cmp_type(book, ty) || j_list_ground_type(book, ty) || j_string_char_type(book, ty) || j_string_string(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, ty), u => j_map_maybe_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, ty), u => j_pure_map_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, ty), u => j_pure_sigma_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, String.eq(tg(ty), "ADT") && U32.is_eq(terms_len(ks(ty)), 0) && List.is_empty(&2, String, rm(ty)) &&
      String.eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
      String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) && String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2), u =>
      kc(Maybe<&2,U32>, has_name(active, nm(ty)), u => Some{fuel}, u =>
        kc(Maybe<&2,U32>, Bool.not(List.is_empty(&2, KDef, dc(owner))) && U32.is_le(j_region_def_count(dc(owner)), 32), u =>
          j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{}))))))

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
  j_pure_bool_native(book, d) || j_pure_nat_native(book, d) || j_map_native_binary(book, d) || j_map_native_string(book, d) || (String.eq(dn(d), "F32.to_u32") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 1) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) && String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "F32") && j_primitive_type(book, wnf(book, kid(ty, 1)), "U32"))

# The residual call keeps its ordinary native ABI; only its closed signature
# and immutable captured descriptor can participate in a private root proof.
@unsafe
def j_pure_bool_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, (String.eq(dn(d), "Bool.xor") || String.eq(dn(d), "Bool.and")) &&
    String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")),
    u => kc(Bool, String.eq(dn(d), "Bool.xor"),
      u => j_pure_bool_native_signature(book, wnf(book, dt(d))),
      u => kc(Bool, j_pure_bool_and_body(j_strip(dv(d))),
        u => j_pure_bool_native_signature(book, wnf(book, dt(d))), u => False{})), u => False{})

@unsafe
def j_pure_bool_native_signature(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Bool"),
    u => j_pure_bool_native_result(book, wnf(book, kid(ty, 1))), u => False{})

@unsafe
def j_pure_bool_native_result(+book: List<&2,KDef>, +rest: KTerm) -> Bool:
  kc(Bool, String.eq(tg(rest), "All") && Bool.not(U32.is_eq(qt(rest), 0)),
    u => j_primitive_type(book, wnf(book, kid(rest, 0)), "Bool") &&
      j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool"), u => False{})

@unsafe
def j_pure_bool_and_node(+t: KTerm, +tag: String, +name: String, +arity: U32, +quantity: U32) -> Bool:
  String.eq(tg(t), tag) && String.eq(nm(t), name) && U32.is_eq(qt(t), quantity) &&
    U32.is_eq(terms_len(ks(t)), arity) && List.is_empty(&2, String, rm(t))

@unsafe
def j_pure_bool_and_body(+t: KTerm) -> Bool:
  kc(Bool, j_pure_bool_and_node(t, "Mat", "False", 2, 1),
    u => j_pure_bool_and_false(j_strip(kid(t, 0))) && j_pure_bool_and_true(j_strip(kid(t, 1))), u => False{})

@unsafe
def j_pure_bool_and_false(+t: KTerm) -> Bool:
  kc(Bool, String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) && List.is_empty(&2, String, rm(t)),
    u => j_pure_bool_and_node(j_strip(kid(t, 0)), "Ctr", "False", 0, 1), u => False{})

@unsafe
def j_pure_bool_and_true(+t: KTerm) -> Bool:
  kc(Bool, j_pure_bool_and_node(t, "Mat", "True", 2, 1),
    u => j_pure_bool_and_identity(j_strip(kid(t, 0))) && j_pure_bool_and_node(j_strip(kid(t, 1)), "Efq", "", 0, 0), u => False{})

@unsafe
def j_pure_bool_and_identity(+t: KTerm) -> Bool:
  kc(Bool, String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) && List.is_empty(&2, String, rm(t)),
    u => j_pure_bool_and_node(j_strip(kid(t, 0)), "Var", nm(t), 0, 1) && U32.is_eq(ix(j_strip(kid(t, 0))), ix(t)), u => False{})

@unsafe
def j_pure_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  j_string_literal(book, d) || (String.eq(dk(d), "Def") && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(dx(d), 0) &&
    j_pure_signature(book, dt(d), da(d)) &&
    kc(Bool, db(d), u => j_pure_native(book, d), u =>
      (String.eq(tg(j_strip(dv(d))), "Lam") || String.eq(tg(j_strip(dv(d))), "Mat")) && j_u32_bounded([dv(d)], 8192)))

@unsafe
def j_pure_add(+d: KDef, +s: JPure) -> JPure:
  kc(JPure, String.eq(dk(lookup(j_pure_defs(s), dn(d))), "Def"), u => s, u =>
    kc(JPure, U32.is_lt(j_region_def_count(j_pure_defs(s)), j_instance_pure_capacity(d, j_pure_defs(s))),
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
    String.eq(tg(kid(ty, 0)), "Qua") && (U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 0)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 0))) &&
    String.eq(tg(kid(ty, 1)), "Qua") && (U32.is_eq(qt(kid(ty, 1)), 1) || U32.is_eq(qt(kid(ty, 1)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 1))) &&
    String.eq(tg(family), "Lam") && U32.is_eq(qt(family), 1) && U32.is_eq(terms_len(ks(family)), 1) &&
    List.is_empty(&2, String, rm(family)) && j_pure_shape_bound([family], 256) &&
    U32.is_eq(j_region_counter_uses([kid(family, 0)], ix(family), 0), 0) &&
    j_map_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty))), qt(kid(ty, 0)), qt(kid(ty, 1))) &&
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
  kc(Maybe<&2,U32>, String.eq(nm(a), "Maybe") || String.eq(nm(b), "Maybe"), u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, a) && j_map_maybe_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(nm(a), "Map") || String.eq(nm(b), "Map"), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(nm(a), "List") || String.eq(nm(b), "List"), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, a) && j_pure_list_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, String.eq(nm(a), "Sigma") || String.eq(nm(b), "Sigma"), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b) &&
      U32.is_eq(qt(kid(a, 0)), qt(kid(b, 0))) && U32.is_eq(qt(kid(a, 1)), qt(kid(b, 1))), u =>
      j_pure_same_next(book, kid(kid(a, 3), 0), kid(kid(b, 3), 0),
        j_pure_same_check(book, kid(a, 2), kid(b, 2), fuel)), u => None{}), u =>
    kc(Maybe<&2,U32>, String.eq(tg(a), "ADT") && String.eq(tg(b), "ADT") && String.eq(nm(a), nm(b)) &&
      List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)) &&
      List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))))

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

# Staged bounded contextual specialization. Facts remain separate from source
# KDefs/JPure; no fact is accepted by ordinary exact_def or name-only lookup.
# da=frozen erased-prefix length; dx=original runtime arity. The eventual clone
# adapter analyzes dx-da live slots; the unchanged public ABI keeps null prefix slots.
@unsafe
def j_erased_closed_arg(+book: List<&2,KDef>, +arg: KTerm) -> Bool:
  +head = wnf(book, arg)
  kc(Bool, String.eq(tg(head), "Qua"), u =>
    (U32.is_eq(qt(head), 1) || U32.is_eq(qt(head), 2)) && List.is_empty(&2,KTerm, ks(head)) && List.is_empty(&2,String, rm(head)), u =>
    j_pure_type(book, head) && j_pure_shape_bound([head], 256))

@unsafe
def j_erased_runtime_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match todo:
    case Nil{}: Some{fuel}
    case Con{t, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && Bool.not(String.eq(tg(t), "Var") && U32.is_eq(ix(t), binder)), u =>
        kc(Maybe<&2,U32>, String.eq(tg(t), "Ann"), u =>
          j_erased_runtime_scan(book, Con{kid(t, 0), rest}, binder, U32.sub(fuel, 1)), u =>
        kc(Maybe<&2,U32>, String.eq(tg(t), "App"), u =>
          j_erased_runtime_call(book, j_call_spine(t, Nil{}), rest, binder, U32.sub(fuel, 1)), u =>
          j_erased_runtime_scan(book, List.append(&2,KTerm, ks(t), rest), binder, U32.sub(fuel, 1)))), u => None{})

@unsafe
def j_erased_runtime_call(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,U32>, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)) && U32.is_le(da(d), 32), u =>
    j_erased_runtime_args(book, ks(spine), dt(d), rest, binder, fuel), u => None{})

@unsafe
def j_erased_runtime_args(+book: List<&2,KDef>, +args: List<&2,KTerm>, +ty: KTerm, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match args:
    case Nil{}: j_erased_runtime_scan(book, todo, binder, fuel)
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && String.eq(tg(head), "All"), u =>
        j_erased_runtime_args(book, rest, j_app_type(head, h),
          kc(List<&2,KTerm>, U32.is_eq(qt(head), 0), u => todo, u => Con{h, todo}), binder, U32.sub(fuel, 1)), u => None{})

# Match j_def's unconditional source-emission path. Native intrinsics may retain
# a runtime override; they are not source-body instances or source aliases.
@unsafe
def j_instance_source_definition(+d: KDef) -> Bool:
  String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(dv(d)), "Absent")) && Bool.not(String.eq(tg(dv(d)), "Foreign")) &&
    (Bool.not(db(d)) || Bool.not(j_intrinsic(dn(d))))

@unsafe
def j_erased_instance(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm) -> Maybe<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,KDef>, String.eq(tg(spine), "Call") && j_instance_source_definition(d) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)) && j_u32_bounded([dv(d)], 4096), u =>
    j_erased_instance_step(book, env, d, dv(d), dt(d), ks(spine), Nil{}, 0, 8192), u => None{})

@unsafe
def j_erased_instance_step(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  # The typed All determines erasure; the library pipeline normalizes Lam qty.
  # Runtime absence below proves that substituting this binder is type-only.
  +head = wnf(book, ty)
  +term = j_strip(body)
  kc(Maybe<&2,KDef>, String.eq(tg(head), "All") && U32.is_eq(qt(head), 0), u =>
    kc(Maybe<&2,KDef>, U32.is_lt(prefix, 4) && U32.is_gt(fuel, 0) && String.eq(tg(term), "Lam") && String.eq(j_l_name(term), ""), u =>
      j_erased_instance_arg(book, env, original, term, head, args, slots, prefix, fuel), u => None{}), u =>
    kc(Maybe<&2,KDef>, U32.is_gt(prefix, 0) && j_pure_signature(book, head, U32.sub(da(original), prefix)) &&
      U32.is_eq(terms_len(args), U32.sub(da(original), prefix)), u =>
      Some{KDef{dn(original), "JErasedInstance", prefix, da(original), head, body, Con{original, slots}, True{}, False{}}}, u => None{}))

# check_fits uses compare(actual, expected, True); norm_cmp_kind allows Data
# (Qua2) to fit Type (Qua1). Only closed, normalized literal kind quantities are
# admitted here, with reverse1->2 refused. Ground argument/value proofs stay exact.
@unsafe
def j_erased_kind_fits(+book: List<&2,KDef>, +actual: KTerm, +expected: KTerm) -> Bool:
  exact_term(actual, expected) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 1) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 2))

@unsafe
def j_erased_closed_kind(+book: List<&2,KDef>, +ty: KTerm, +q: U32) -> Bool:
  kc(Bool, String.eq(tg(ty), "Typ") && String.eq(nm(ty), "") && U32.is_eq(ix(ty), 0) && U32.is_eq(qt(ty), 0) &&
    U32.is_eq(terms_len(ks(ty)), 1) && List.is_empty(&2,String, rm(ty)),
    u => j_erased_kind_quantity(wnf(book, kid(ty, 0)), q), u => False{})

@unsafe
def j_erased_kind_quantity(+q: KTerm, +expected: U32) -> Bool:
  String.eq(tg(q), "Qua") && String.eq(nm(q), "") && U32.is_eq(ix(q), 0) && U32.is_eq(qt(q), expected) &&
    List.is_empty(&2,KTerm, ks(q)) && List.is_empty(&2,String, rm(q))

@unsafe
def j_erased_instance_arg(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  match args:
    case Nil{}: None{}
    case Con{h, rest}:
      kc(Maybe<&2,KDef>, j_erased_closed_arg(book, h) &&
        j_erased_kind_fits(book, wnf(book, j_erased_arg_type(book, wnf(book, h))), wnf(book, kid(ty, 0))), u =>
        j_erased_instance_scanned(book, env, original, body, ty, wnf(book, h), rest, slots, prefix,
          j_erased_runtime_scan(book, [kid(body, 0)], ix(body), U32.sub(fuel, 1))), u => None{})

@unsafe
def j_erased_instance_scanned(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +arg: KTerm, +rest: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +r: Maybe<&2,U32>) -> Maybe<&2,KDef>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +slot: KDef = KDef{"", "JErasedSlot", ix(ty), ix(body), kid(ty, 0), arg, Nil{}, False{}, False{}}
      j_erased_instance_step(book, env, original, subst(kid(body, 0), ix(body), arg), j_app_type(ty, arg), rest,
        List.append(&2,KDef, slots, [slot]), U32.inc(prefix), fuel)

@unsafe
def j_erased_instance_same(+a: KDef, +b: KDef) -> Bool:
  String.eq(dk(a), "JErasedInstance") && String.eq(dk(b), "JErasedInstance") &&
    U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && exact_defs(dc(a), dc(b)) &&
    exact_term(dt(a), dt(b)) && exact_term(dv(a), dv(b))


@unsafe
def j_erased_arg_type(+book: List<&2,KDef>, +arg: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(arg), "Qua"), u => atom("Qnt"), u =>
    kc(KTerm, String.eq(tg(arg), "ADT"), u => tele_fill(book, dt(lookup(book, nm(arg))), ks(arg)), u => atom("Absent")))

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
      kc(JInstances, U32.is_gt(j_instances_fuel(s), 8192), u =>
        j_instances_fact(book, spine, rest, JInstances{j_instances_rows(s), j_instances_sources(s), U32.sub(j_instances_fuel(s), 8192), True{}}, j_erased_instance(book, Nil{}, spine)), u => j_instances_fail(s)), u =>
      kc(JInstances, Bool.not(j_instance_source_definition(d)) || j_instances_source_has(j_instances_sources(s), d), u =>
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
        j_instances_collect(book, List.append(&2,KTerm, j_instance_drop(ks(spine), da(fact)), rest), s), u =>
        kc(JInstances, U32.is_lt(j_region_def_count(j_instances_rows(s)), 32), u =>
          j_instances_collect(book, Con{dv(fact), List.append(&2,KTerm, j_instance_drop(ks(spine), da(fact)), rest)},
            JInstances{Con{fact, j_instances_rows(s)}, j_instances_sources(s), j_instances_fuel(s), True{}}), u => j_instances_fail(s)))

# Source book remains canonical. A separate, explicitly audited analysis view
# contains uniquely named private definitions with exact instance provenance.
# All private calls use LIVE argument slots; original/null-prefix ABI survives
# solely in the unchanged generic/public path and boundary facts.
@unsafe
def j_instance_original(+fact: KDef) -> KDef:
  index_first(dc(fact))

@unsafe
def j_instance_name(+at: U32) -> String:
  "$instance." ++ U32.show(at)

@unsafe
def j_instance_alias(+d: KDef) -> KDef:
  KDef{dn(d), "JErasedInstance", 0, da(d), dt(d), dv(d), [d], True{}, False{}}

@unsafe
def j_instance_aliases(+ds: List<&2,KDef>, +tail: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: tail
    case Con{d, rest}: Con{j_instance_alias(d), j_instance_aliases(rest, tail)}

@unsafe
def j_instance_fact_exact(+book: List<&2,KDef>, +fact: KDef) -> Bool:
  +original = j_instance_original(fact)
  String.eq(dk(fact), "JErasedInstance") && db(fact) &&
    exact_def(original, lookup(book, dn(original))) && U32.is_eq(dx(fact), da(original)) && U32.is_le(da(fact), dx(fact)) &&
    kc(Bool, U32.is_eq(da(fact), 0), u => exact_def(fact, j_instance_alias(original)), u =>
      j_instance_fact_replay(book, fact, j_erased_instance(book, Nil{},
        kt("Call", dn(original), 0, 0, List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), j_instance_placeholders(U32.sub(da(original), da(fact))))))))

@unsafe
def j_instance_fact_replay(+book: List<&2,KDef>, +fact: KDef, +r: Maybe<&2,KDef>) -> Bool:
  match r:
    case None{}: False{}
    case Some{again}: j_erased_instance_same(fact, again)

@unsafe
def j_instance_slot_args(+slots: List<&2,KDef>) -> List<&2,KTerm>:
  match slots:
    case Nil{}: Nil{}
    case Con{slot, rest}: Con{dv(slot), j_instance_slot_args(rest)}

@unsafe
def j_instance_placeholders(+left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => Nil{}, u => Con{atom("Absent"), j_instance_placeholders(U32.sub(left, 1))})

@unsafe
def j_instance_fact_index(+rows: List<&2,KDef>, +fact: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, j_erased_instance_same(h, fact), u => at, u => j_instance_fact_index(rest, fact, U32.inc(at)))

@unsafe
def j_instance_source_index(+rows: List<&2,KDef>, +d: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, U32.is_eq(da(h), 0) && exact_def(j_instance_original(h), d), u => at,
      u => j_instance_source_index(rest, d, U32.inc(at)))

@unsafe
def j_instance_drop(+args: List<&2,KTerm>, +left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => args, u =>
    kc(List<&2,KTerm>, List.is_empty(&2,KTerm, args), u => Nil{}, u => j_instance_drop(j_instance_tail_terms(args), U32.sub(left, 1))))

@unsafe
def j_instance_rewrite(+book: List<&2,KDef>, +rows: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => k_with_children(t, [j_instance_rewrite(book, rows, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, String.eq(tg(t), "App"), u => j_instance_rewrite_call(book, rows, t, j_call_spine(t, Nil{})), u =>
      k_with_children(t, j_instance_rewrites(book, rows, ks(t)))))

@unsafe
def j_instance_rewrites(+book: List<&2,KDef>, +rows: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_rewrite(book, rows, t), j_instance_rewrites(book, rows, rest)}

@unsafe
def j_instance_rewrite_call(+book: List<&2,KDef>, +rows: List<&2,KDef>, +original: KTerm, +spine: KTerm) -> KTerm:
  +d = lookup(book, nm(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(KTerm, U32.is_eq(qt(wnf(book, dt(d))), 0) && String.eq(tg(wnf(book, dt(d))), "All"), u =>
      j_instance_rewrite_fact(book, rows, spine, j_erased_instance(book, Nil{}, spine)), u =>
      j_instance_rewrite_live(book, rows, spine, j_instance_source_index(rows, d, 0), 0)), u => atom("Absent"))

@unsafe
def j_instance_rewrite_fact(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +r: Maybe<&2,KDef>) -> KTerm:
  match r:
    case None{}: atom("Absent")
    case Some{fact}:
      +at = j_instance_fact_index(rows, fact, 0)
      kc(KTerm, U32.is_eq(at, 4294967295), u => atom("Absent"), u =>
        kc(KTerm, U32.is_eq(da(fact), dx(fact)), u =>
          kc(KTerm, U32.is_eq(terms_len(ks(j_strip(dv(fact)))), 0) &&
            (String.eq(tg(j_strip(dv(fact))), "Ctr") || String.eq(tg(j_strip(dv(fact))), "Lit")),
            u => dv(fact), u => atom("Absent")), u =>
          j_instance_rewrite_live(book, rows, spine, at, da(fact))))

@unsafe
def j_instance_rewrite_live(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +at: U32, +prefix: U32) -> KTerm:
  +args = j_instance_rewrites(book, rows, j_instance_drop(ks(spine), prefix))
  kc(KTerm, U32.is_eq(at, 4294967295), u => j_region_app(ref(nm(spine)), args), u => j_region_app(ref(j_instance_name(at)), args))

@unsafe
def j_instance_view_defs(+book: List<&2,KDef>, +rows: List<&2,KDef>, +todo: List<&2,KDef>, +at: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: Nil{}
    case Con{fact, rest}:
      +body = j_instance_rewrite(book, rows, dv(fact))
      Con{KDef{j_instance_name(at), "Def", U32.sub(dx(fact), da(fact)), 0, dt(fact),
        body, [fact, j_instance_edge_row(body)], False{}, du(j_instance_original(fact))},
        j_instance_view_defs(book, rows, rest, U32.inc(at))}

@unsafe
def j_instance_tail_defs(+ds: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

@unsafe
def j_instance_tail_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

@unsafe
def j_instance_attach(+book: List<&2,KDef>, +rows: List<&2,KDef>, +sources: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, String.eq(dk(cache), "BookCache"), u =>
        Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, atom("Absent"), atom("Absent"),
            [missing(), missing(), KDef{"$js.instances", "JSInstanceContext", 0, 0, atom("Absent"), atom("Absent"),
              [KDef{"rows", "JSInstanceRows", 0, 0, atom("Absent"), atom("Absent"), rows, True{}, False{}},
               KDef{"sources", "JSInstanceSources", 0, 0, atom("Absent"), atom("Absent"), sources, True{}, False{}}], True{}, False{}}], False{}, False{}}], db(cache), du(cache)}, rest}, u => book)

@unsafe
def j_instance_all_exact(+book: List<&2,KDef>, +rows: List<&2,KDef>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{fact, rest}: j_instance_fact_exact(book, fact) && j_instance_all_exact(book, rest)

@unsafe
def j_instance_view_context(+view: List<&2,KDef>, +d: KDef, +pure: JPure) -> Bool:
  j_pure_valid(pure) && j_component_prefix(view, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0)

@unsafe
def j_instance_clones_ready(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, U32.is_eq(da(d), 0), u =>
        U32.is_eq(terms_len(ks(j_strip(dv(d)))), 0) &&
          (String.eq(tg(j_strip(dv(d))), "Ctr") || String.eq(tg(j_strip(dv(d))), "Lit")) && j_instance_clones_ready(view, rest), u =>
        j_pure_valid(j_pure_graph(view, d, JPure{Nil{}, 131072, True{}})) && j_instance_clones_ready(view, rest))

# Covered emission requires exact Def membership in the private view plus a
# provenance fact. Uncovered private instance names become Absent and fail the
# pre-emission audit; there is no G[private-name] fallback.
@unsafe
def j_instance_cover(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => k_with_children(t, [j_instance_cover(view, defs, owner, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, String.eq(tg(t), "App"), u =>
      j_instance_cover_app(view, defs, owner, j_call_spine(t, Nil{})), u =>
      k_with_children(t, j_instance_covers(view, defs, owner, ks(t)))))

@unsafe
def j_instance_covers(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_cover(view, defs, owner, t), j_instance_covers(view, defs, owner, rest)}

@unsafe
def j_instance_cover_app(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +spine: KTerm) -> KTerm:
  +d = lookup(view, nm(spine))
  +known = lookup(defs, nm(spine))
  +args = j_instance_covers(view, defs, owner, ks(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(args), da(d)), u =>
    kc(KTerm, String.starts_with(nm(spine), "$instance."), u =>
      kc(KTerm, exact_def(d, known) && String.eq(dk(index_first(dc(d))), "JErasedInstance"), u =>
        kc(KTerm, String.eq(nm(spine), owner), u => j_region_app(ref(owner), args), u =>
          kc(KTerm, U32.is_gt(j_component_refs(ks(spine), owner, 8192, 0), 0), u =>
            kc(KTerm, j_instance_emit_ready(view, d), u => j_region_app(ref(nm(spine)), args), u => atom("Absent")), u =>
          kc(KTerm, j_instance_emit_ready(view, d), u => j_region_annotate(kt("JCall", nm(spine), 0, 1, args), j_covered_result(dt(d), args)), u => j_instance_residual(view, d, args)))), u => atom("Absent")), u =>
      j_region_app(ref(nm(spine)), args)), u => atom("Absent"))

@unsafe
def j_instance_no_absent(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0) && Bool.not(String.eq(tg(t), "Absent")),
      u => j_instance_no_absent(List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

@unsafe
def j_instance_covered_audit(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> Bool:
  match rest:
    case Nil{}: True{}
    case Con{d, more}: j_instance_no_absent([j_instance_cover(view, defs, dn(d), dv(d))], 16384) && j_instance_covered_audit(view, defs, more)

@unsafe
def j_instance_declarations(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> String:
  match rest:
    case Nil{}: ""
    case Con{d, more}: kc(String, j_instance_emit_ready(view, d), u =>
      j_component_stack_declaration(view, d, j_owned_term(j_instance_cover(view, defs, dn(d), dv(d))), "$tree"), u => "") ++
      j_instance_declarations(view, defs, more)

@unsafe
def j_instance_guards(+rows: List<&2,KDef>) -> String:
  match rows:
    case Nil{}: ""
    case Con{fact, rest}: j_quote(dn(j_instance_original(fact))) ++ "," ++ j_instance_guards(rest)

@unsafe
def j_instance_capture(+rows: List<&2,KDef>) -> String:
  match rows:
    case Nil{}: ""
    case Con{fact, rest}: "scalarCapture(" ++ j_quote(dn(j_instance_original(fact))) ++ ",G[" ++ j_quote(dn(j_instance_original(fact))) ++ "]);" ++ j_instance_capture(rest)

# Profitability prefilter only: keep existing erased calls, also consider exact
# source-call edges. Primitive/literal-only leaves do not duplicate private graphs.
# Exact source aliases still pass the complete collector, provenance and JPure gates.
@unsafe
def j_instance_has_graph_call(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        j_instance_has_graph_call_node(book, t, rest, fuel, j_call_spine(t, Nil{})), u => False{})

@unsafe
def j_instance_has_graph_call_node(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +spine: KTerm) -> Bool:
  +d = lookup(book, nm(spine))
  kc(Bool, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) &&
    ((j_instance_source_definition(d) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32)) ||
      (String.eq(tg(wnf(book, dt(d))), "All") && U32.is_eq(qt(wnf(book, dt(d))), 0))),
    u => True{}, u => j_instance_has_graph_call(book, List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)))

@unsafe
def j_instance_root_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_region_scalar(book, head) || j_string_string(book, head), u =>
    kc(Bool, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_region_scalar(book, kid(head, 0)),
      u => j_instance_root_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Native String results are immutable values already produced by the private
# component emitter. Arguments remain scalar; object/array/closure results do
# not enter through this boundary. Graph, layout and host guards still apply.
# The public fixed-arity wrapper and its generic fallback both consume exactly
# the contiguous leading lambda prefix. A matcher between arguments keeps its
# original public descriptor/demand boundary, but may still be a private callee.
@unsafe
def j_instance_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_instance_source_definition(d) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) &&
    U32.is_eq(j_lambda_count(dv(d)), da(d)) && j_instance_root_signature(book, dt(d), da(d)) &&
    j_instance_has_graph_call(book, [dv(d)], 2048), u =>
      j_instance_root_collect(book, d, j_instances_collect(book, [dv(d)], JInstances{Nil{}, [d], 1048576, True{}})), u => "")

@unsafe
def j_instance_root_collect(+book: List<&2,KDef>, +d: KDef, +s: JInstances) -> String:
  # Native-source public roots require real contextual specialization.
  # New alias-only public wrappers need non-native provenance; their guarded
  # entry cost is unsuitable for small reusable prelude helpers. Such helpers
  # remain eligible as private callees within every complete worker graph.
  kc(String, j_instances_valid(s) && Bool.not(List.is_empty(&2,KDef, j_instances_sources(s))) &&
    (Bool.not(db(d)) || Bool.not(List.is_empty(&2,KDef, j_instances_rows(s)))), u =>
    j_instance_root_rows(book, d, j_instance_aliases(j_instances_sources(s), j_instances_rows(s))), u => "")

@unsafe
def j_instance_root_rows(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>) -> String:
  kc(String, j_instance_all_exact(book, rows) && U32.is_le(j_region_def_count(rows), 96), u =>
    j_instance_root_raw(book, d, rows, j_instance_view_defs(book, rows, rows, 0)), u => "")

@unsafe
def j_instance_root_view(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, defs, j_instance_attach(book, rows, j_instances_sources(JInstances{Nil{}, [d], 0, True{}})))
  +at = j_instance_source_index(rows, d, 0)
  +pure = j_pure_graph(view, lookup(view, j_instance_name(at)), JPure{Nil{}, 131072, True{}})
  kc(String, j_pure_valid(pure) && j_instance_covered_audit(view, defs, defs) && j_instance_erased_emitted(view, defs), u =>
    j_instance_root_emit(book, view, d, rows, defs, at, pure), u => "")

# Guard dependencies consume the same successful proof used for admission.
# The raw-view proof remains separate because emission metadata changes its book.
@unsafe
def j_instance_root_emit(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>, +at: U32, +pure: JPure) -> String:
  kc(String, U32.is_eq(at, 4294967295) || Bool.not(j_instance_emit_ready(view, lookup(view, j_instance_name(at)))), u => "", u =>
    j_instance_root_guarded(book, d, rows, at, pure, j_instance_declarations(view, defs, defs)))

# Both private backends share the identical public wrapper and complete graph
# guard. Only declaration lowering differs; a private machine adds no new entry.
@unsafe
def j_instance_root_guarded(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +at: U32, +pure: JPure, +declarations: String) -> String:
  j_instance_root_guarded_mode(book, d, rows, at, pure, declarations, False{})

@unsafe
def j_instance_root_guarded_mode(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +at: U32, +pure: JPure,
  +declarations: String, +numberNat: Bool) -> String:
    "(()=>{" ++ declarations ++ "const $guards=[" ++ j_instance_guards(rows) ++ j_instance_primitive_guards() ++ j_instance_native_guards(j_pure_defs(pure)) ++ "];return " ++
    "fn(" ++ U32.show(da(d)) ++ ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&regionProof===null&&regionHostGuard()&&stringHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards)){/* private contextual instances */" ++
      kc(String, numberNat, u => jw_nat_inputs(book, dt(d), 0, da(d)), u => "") ++ "return " ++
      kc(String, numberNat && jw_nat_result(book, dt(d), da(d)), u => "BigInt(", u => "") ++
      j_region_name(j_instance_name(at)) ++ "$tree(" ++ j_region_vector_names("$s", 0, da(d)) ++ ")" ++
      kc(String, numberNat && jw_nat_result(book, dt(d), da(d)), u => ")", u => "") ++ ";}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()"


@unsafe
def j_instance_emit_ready(+view: List<&2,KDef>, +d: KDef) -> Bool:
  +cap = index_first(j_instance_tail_defs(j_instance_tail_defs(dc(d))))
  String.eq(dn(cap), "$js.instance.emission") && String.eq(dk(cap), "JSInstanceEmission") && db(cap)

@unsafe
def j_instance_residual(+view: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>) -> KTerm:
  +fact = index_first(dc(d))
  +original = j_instance_original(fact)
  +full = List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), args)
  j_region_annotate(kt("JGeneric", dn(original), 0, 0, full), j_covered_result(dt(original), full))

# Conservative complete inline primitive-family fence. Exact used call types
# are still proved by j_primitive_definition; irrelevant native mutations may
# refuse the private entry and retain ordinary generic behavior.
@unsafe
def j_instance_primitive_guards() -> String:
  "\"U32.add\",\"U32.sub\",\"U32.mul\",\"U32.div\",\"U32.mod\",\"U32.and\",\"U32.or\",\"U32.xor\",\"U32.inc\",\"U32.not\",\"U32.shl\",\"U32.shr\",\"U32.shln\",\"U32.shrn\",\"U32.is_zero\",\"U32.is_eq\",\"U32.is_ne\",\"U32.is_lt\",\"U32.is_le\",\"U32.is_gt\",\"U32.is_ge\",\"U32.to_nat\",\"U32.from_nat\",\"U32.to_f32\",\"F32.add\",\"F32.sub\",\"F32.mul\",\"F32.div\",\"F32.mod\",\"F32.neg\",\"F32.is_eq\",\"F32.is_ne\",\"F32.is_lt\",\"F32.is_le\",\"F32.is_gt\",\"F32.is_ge\",\"F32.sqrt\",\"F32.exp\",\"F32.log\",\"F32.log2\",\"F32.log10\",\"F32.sin\",\"F32.cos\",\"F32.tan\",\"F32.asin\",\"F32.acos\",\"F32.atan\",\"F32.sinh\",\"F32.cosh\",\"F32.tanh\",\"F32.floor\",\"F32.ceil\",\"F32.trunc\",\"F32.abs\","

@unsafe
def j_instance_native_guards(+graph: List<&2,KDef>) -> String:
  match graph:
    case Nil{}: ""
    case Con{d, rest}: kc(String, String.starts_with(dn(d), "$instance."), u => "", u => j_quote(dn(d)) ++ ",") ++ j_instance_native_guards(rest)

@unsafe
def j_instance_erased_emitted(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{d, rest}: (U32.is_gt(da(index_first(dc(d))), 0) && j_instance_emit_ready(view, d)) || j_instance_erased_emitted(view, rest)


@unsafe
def j_instance_edge_row(+body: KTerm) -> KDef:
  KDef{"$js.instance.edges", "JSInstanceEdges", 0, 0, atom("Absent"), atom("Absent"), j_instance_edges([body], Nil{}, 16384), True{}, False{}}

@unsafe
def j_instance_edges(+todo: List<&2,KTerm>, +names: List<&2,KDef>, +fuel: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: names
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_instance_edges(List.append(&2,KTerm, ks(t), rest),
          kc(List<&2,KDef>, String.eq(tg(t), "Ref") && String.starts_with(nm(t), "$instance.") && String.eq(dk(lookup(names, nm(t))), "Absent"),
            u => Con{KDef{nm(t), "JSInstanceEdge", 0, 0, atom("Absent"), atom("Absent"), Nil{}, True{}, False{}}, names}, u => names), U32.sub(fuel, 1)), u => [missing()])

# Metadata occupies fixed slots after provenance; original source names cannot
# shadow rows. Unexpected rows fail closed as an invalid graph edge.
@unsafe
def j_instance_edges_checked(+d: KDef) -> List<&2,KDef>:
  +row = index_first(j_instance_tail_defs(dc(d)))
  kc(List<&2,KDef>, String.eq(dn(row), "$js.instance.edges") && String.eq(dk(row), "JSInstanceEdges"),
    u => dc(row), u => [missing()])

@unsafe
def j_instance_cycle(+view: List<&2,KDef>, +todo: List<&2,KDef>, +root: String, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{edge, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || Bool.not(String.eq(dk(edge), "JSInstanceEdge")) || String.eq(dn(edge), root), u => True{}, u =>
        kc(Bool, has_name(seen, dn(edge)), u => j_instance_cycle(view, rest, root, seen, U32.sub(fuel, 1)), u =>
          j_instance_cycle(view, List.append(&2,KDef, j_instance_edges_checked(lookup(view, dn(edge))), rest), root,
            Con{dn(edge), seen}, U32.sub(fuel, 1))))

@unsafe
def j_instance_caps(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      +ready = U32.is_gt(da(d), 0) && j_component_prefix(view, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0) &&
        Bool.not(j_instance_cycle(view, index_remove(j_instance_edges_checked(d), dn(d)), dn(d), Nil{}, 8192))
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d),
        List.append(&2,KDef, dc(d), [KDef{"$js.instance.emission", "JSInstanceEmission", 0, 0, atom("Absent"), atom("Absent"), Nil{}, ready, False{}}]), db(d), du(d)},
        j_instance_caps(view, rest)}

@unsafe
def j_instance_root_raw(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +raw: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, raw, j_instance_attach(book, rows, [d]))
  +at = j_instance_source_index(rows, d, 0)
  +pure = j_pure_graph(view, lookup(view, j_instance_name(at)), JPure{Nil{}, 131072, True{}})
  kc(String, j_pure_valid(pure) && Bool.not(U32.is_eq(at, 4294967295)), u =>
    j_instance_root_workers(book, view, d, rows, raw, at, pure, j_worker_emission(view, raw)), u => "")

@unsafe
def j_instance_root_workers(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +raw: List<&2,KDef>,
  +at: U32, +pure: JPure, +emission: JWEmission) -> String:
  match emission:
    case JWEmission{declarations, numberNat}:
      kc(String, Bool.not(String.eq(declarations, "")),
        u => j_instance_root_guarded_mode(book, d, rows, at, pure, declarations, numberNat),
        u => j_instance_root_view(book, d, rows, j_instance_caps(view, raw)))

# Exact native scalar-key components needed by closed Map graphs. These proof
# rows do not create public argument admission or change residual native code.
@unsafe
def j_map_cmp_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Cmp")
  +kind = wnf(book, dt(owner))
  j_map_cmp_nominal(ty) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "LT"), "LT", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "EQ"), "EQ", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "GT"), "GT", ty)

# ADT quant0/1 is source-node metadata, not a Cmp quantity parameter. The
# canonical owner has no parameters; constructors must terminate at this exact
# nominal zeroarity type. No recursive type proof or metadata-erasing rewrite.
@unsafe
def j_map_cmp_nominal(+ty: KTerm) -> Bool:
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Cmp") && U32.is_eq(ix(ty), 0) &&
    (U32.is_eq(qt(ty), 0) || U32.is_eq(qt(ty), 1)) &&
    List.is_empty(&2,KTerm, ks(ty)) && List.is_empty(&2,String, rm(ty))

@unsafe
def j_map_cmp_ctor(+book: List<&2,KDef>, +c: KDef, +name: String, +ty: KTerm) -> Bool:
  j_pure_native_ctor(c, name, 0) && j_map_cmp_nominal(ty) && j_map_cmp_nominal(wnf(book, dt(c)))

@unsafe
def j_map_maybe_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Maybe")
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Maybe") && U32.is_eq(terms_len(ks(ty)), 2) && List.is_empty(&2,String, rm(ty)) &&
    String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) && List.is_empty(&2,KTerm, ks(kid(ty, 0))) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 2) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "None"), "None", 0) && j_pure_native_ctor(lookup(dc(owner), "Some"), "Some", 1)

@unsafe
def j_map_maybe_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Maybe"))
  j_map_maybe_some(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "None")), ks(ty)), ty, Nil{}, active, fuel))

@unsafe
def j_map_maybe_some(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Maybe")), "Some")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty, [kid(ty, 1)], active, fuel)

@unsafe
def j_map_closed_maybe(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_map_maybe_head(book, head) && j_pure_type(book, head)

@unsafe
def j_map_sigma_quantity(+ty: KTerm) -> U32:
  kc(U32, U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 1)), 1), u => 1, u => 2)

@unsafe
def j_map_sigma_kind(+ty: KTerm, +qa: U32, +qb: U32) -> Bool:
  +q = kid(ty, 0)
  String.eq(tg(ty), "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    kc(Bool, String.eq(tg(q), "Qua"), u => U32.is_eq(qt(q), kc(U32, U32.is_eq(qa, 1) || U32.is_eq(qb, 1), u => 1, u => 2)) && List.is_empty(&2,KTerm, ks(q)), u =>
      String.eq(tg(q), "Min") && U32.is_eq(terms_len(ks(q)), 2) && String.eq(tg(kid(q, 0)), "Qua") && U32.is_eq(qt(kid(q, 0)), qa) &&
      List.is_empty(&2,KTerm, ks(kid(q, 0))) && String.eq(tg(kid(q, 1)), "Qua") && U32.is_eq(qt(kid(q, 1)), qb) && List.is_empty(&2,KTerm, ks(kid(q, 1))))

@unsafe
def j_map_closed_field_quantity(+ty: KTerm, +left: U32) -> U32:
  # Canonical Tuple fields are affine binders; the type parameters affect kind.
  1

@unsafe
def j_map_native_binary(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) && Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) &&
    String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 1) && String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) &&
    kc(Bool, String.eq(dn(d), "U32.cmp"), u =>
      j_primitive_type(book, wnf(book, kid(ty, 0)), "U32") && j_primitive_type(book, wnf(book, kid(rest, 0)), "U32") && j_map_cmp_type(book, wnf(book, kid(rest, 1))), u =>
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") &&
      kc(Bool, String.eq(dn(d), "Nat.sub"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat"), u =>
      kc(Bool, String.eq(dn(d), "Nat.is_lt"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool"), u =>
      String.eq(dn(d), "Nat.divmod") && j_map_native_divmod_result(book, wnf(book, kid(rest, 1))))))

# Residual String.append keeps runtime fn/call ABI and native snapshot guards.
@unsafe
def j_map_native_string(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, String.eq(dn(d), "String.append") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")),
    u => j_map_native_string_signature(book, wnf(book, dt(d))), u => False{})

@unsafe
def j_map_native_string_signature(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 1) && j_string_string(book, wnf(book, kid(ty, 0))),
    u => j_map_native_string_result(book, wnf(book, kid(ty, 1))), u => False{})

@unsafe
def j_map_native_string_result(+book: List<&2,KDef>, +rest: KTerm) -> Bool:
  String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) &&
    j_string_string(book, wnf(book, kid(rest, 0))) && j_string_string(book, wnf(book, kid(rest, 1)))

@unsafe
def j_map_native_divmod_result(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_pure_closed_sigma(book, ty) && j_primitive_type(book, wnf(book, kid(ty, 2)), "Nat") &&
    j_primitive_type(book, wnf(book, kid(kid(ty, 3), 0)), "Nat")

@unsafe
def j_instance_public_capture(+d: KDef) -> Bool:
  j_instance_source_definition(d) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) &&
    (String.eq(tg(j_strip(dv(d))), "Lam") || String.eq(tg(j_strip(dv(d))), "Mat"))

@unsafe
def j_instance_pure_capacity(+d: KDef, +ds: List<&2,KDef>) -> U32:
  kc(U32, String.eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(ds), u => 128, u => 32)

@unsafe
def j_instance_pure_rows(+ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: String.eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(rest)

# A source child reconstructed from inert projected fields remains private.
# Full graph/type proof independently validates constructor identity and fields.
@unsafe
def j_instance_child_fields(+env: List<&2,KTerm>, +ts: List<&2,KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{t, rest}: String.eq(tg(j_strip(t)), "Var") && String.eq(j_component_origin(env, ix(j_strip(t))), "@child") && j_instance_child_fields(env, rest)

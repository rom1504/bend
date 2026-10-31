
# Module: src/back/js/jpure.bend:3
type JPure is Data:
  JPure{+defs: List<&2,KDef>, +fuel: U32, +valid: Bool}

# Module: src/back/js/jpure.bend:853
type JInstances is Data:
  JInstances{+rows: List<&2,KDef>, +sources: List<&2,KDef>, +fuel: U32, +valid: Bool}

# Module: src/back/js/jpure.bend:7
@unsafe
def j_pure_defs(+s: JPure) -> List<&2,KDef>:
  match s:
    case JPure{ds, fuel, valid}: ds

# Module: src/back/js/jpure.bend:12
@unsafe
def j_pure_fuel(+s: JPure) -> U32:
  match s:
    case JPure{ds, fuel, valid}: fuel

# Module: src/back/js/jpure.bend:17
@unsafe
def j_pure_valid(+s: JPure) -> Bool:
  match s:
    case JPure{ds, fuel, valid}: valid

# Module: src/back/js/jpure.bend:22
@unsafe
def j_pure_fail(+s: JPure) -> JPure:
  JPure{j_pure_defs(s), 0, False{}}

# Module: src/back/js/jpure.bend:26
@unsafe
def j_pure_tick(+s: JPure) -> JPure:
  JPure{j_pure_defs(s), U32.sub(j_pure_fuel(s), 1), j_pure_valid(s)}

# Closed recursive tagged ADTs: no parameters, native arrays, functions, foreign
# representations or dependent fields. An active owner still has every one of
# its constructors checked by the pending outer visit.

# Module: src/back/js/jpure.bend:33
@unsafe
def j_pure_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_region_local_ok(j_pure_type_check(book, ty, Nil{}, 512))

# Module: src/back/js/jpure.bend:37
@unsafe
def j_pure_type_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_type_head(book, wnf(book, ty), active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:42
@unsafe
def j_pure_type_head(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, nm(ty))
  +kind = wnf(book, dt(owner))
  kc(Maybe<&2,U32>, j_region_scalar(book, ty) || j_map_cmp_type(book, ty) || j_list_ground_type(book, ty) || j_string_char_type(book, ty) || j_string_string(book, ty) || j_pure_unit_type(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, ty), u => j_map_maybe_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, ty), u => j_pure_map_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, ty), u => j_pure_sigma_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(ty, "ADT") && U32.is_eq(terms_len(ks(ty)), 0) && List.is_empty(&2, String, rm(ty)) &&
      p88_string_eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
      p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) && p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2), u =>
      kc(Maybe<&2,U32>, has_name(active, nm(ty)), u => Some{fuel}, u =>
        kc(Maybe<&2,U32>, Bool.not(List.is_empty(&2, KDef, dc(owner))) && U32.is_le(j_region_def_count(dc(owner)), 32), u =>
          j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{}))))))

# Module: src/back/js/jpure.bend:58
@unsafe
def j_pure_type_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +owner: String, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match cs:
    case Nil{}: Some{fuel}
    case Con{c, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && p88_string_eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 32), u =>
        j_pure_type_ctor_next(book, rest, owner, active, j_pure_type_fields(book, dt(c), owner, da(c), active, U32.sub(fuel, 1))), u => None{})

# Module: src/back/js/jpure.bend:66
@unsafe
def j_pure_type_ctor_next(+book: List<&2,KDef>, +rest: List<&2,KDef>, +owner: String, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_ctors(book, rest, owner, active, fuel)
    case None{}: None{}

# Module: src/back/js/jpure.bend:72
@unsafe
def j_pure_type_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +head = wnf(book, ty)
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), owner) && U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)),
      u => Some{fuel}, u => None{}), u =>
    kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
      j_pure_type_field_next(book, kid(head, 1), owner, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(head, 0), active, U32.sub(fuel, 1))), u => None{}))

# Module: src/back/js/jpure.bend:82
@unsafe
def j_pure_type_field_next(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_fields(book, ty, owner, left, active, fuel)
    case None{}: None{}

# Module: src/back/js/jpure.bend:88
@unsafe
def j_pure_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_pure_type(book, head), u =>
    kc(Bool, U32.is_le(left, 32) && p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)),
      u => j_pure_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Only this residual native escapes ordinary primitive expression lowering.

# Module: src/back/js/jpure.bend:96
@unsafe
def j_pure_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  j_pure_bool_native(book, d) || j_pure_nat_native(book, d) || j_map_native_binary(book, d) || j_map_native_string(book, d) || (p88_string_eq(dn(d), "F32.to_u32") && p88_string_eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 1) && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) && p98_tag_eq(ty, "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "F32") && j_primitive_type(book, wnf(book, kid(ty, 1)), "U32"))

# The residual call keeps its ordinary native ABI; only its closed signature
# and immutable captured descriptor can participate in a private root proof.

# Module: src/back/js/jpure.bend:105
@unsafe
def j_pure_bool_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, (p88_string_eq(dn(d), "Bool.xor") || p88_string_eq(dn(d), "Bool.and")) &&
    p88_string_eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")),
    u => kc(Bool, p88_string_eq(dn(d), "Bool.xor"),
      u => j_pure_bool_native_signature(book, wnf(book, dt(d))),
      u => kc(Bool, j_pure_bool_and_body(j_strip(dv(d))),
        u => j_pure_bool_native_signature(book, wnf(book, dt(d))), u => False{})), u => False{})

# Module: src/back/js/jpure.bend:115
@unsafe
def j_pure_bool_native_signature(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(ty, "All") && Bool.not(U32.is_eq(qt(ty), 0)) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Bool"),
    u => j_pure_bool_native_result(book, wnf(book, kid(ty, 1))), u => False{})

# Module: src/back/js/jpure.bend:121
@unsafe
def j_pure_bool_native_result(+book: List<&2,KDef>, +rest: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(rest, "All") && Bool.not(U32.is_eq(qt(rest), 0)),
    u => j_primitive_type(book, wnf(book, kid(rest, 0)), "Bool") &&
      j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool"), u => False{})

# Module: src/back/js/jpure.bend:127
@unsafe
def j_pure_bool_and_node(+t: KTerm, +tag: String, +name: String, +arity: U32, +quantity: U32) -> Bool:
  p98_tag_eq(t, tag) && p88_string_eq(nm(t), name) && U32.is_eq(qt(t), quantity) &&
    U32.is_eq(terms_len(ks(t)), arity) && List.is_empty(&2, String, rm(t))

# Module: src/back/js/jpure.bend:132
@unsafe
def j_pure_bool_and_body(+t: KTerm) -> Bool:
  kc(Bool, j_pure_bool_and_node(t, "Mat", "False", 2, 1),
    u => j_pure_bool_and_false(j_strip(kid(t, 0))) && j_pure_bool_and_true(j_strip(kid(t, 1))), u => False{})

# Module: src/back/js/jpure.bend:137
@unsafe
def j_pure_bool_and_false(+t: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(t, "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) && List.is_empty(&2, String, rm(t)),
    u => j_pure_bool_and_node(j_strip(kid(t, 0)), "Ctr", "False", 0, 1), u => False{})

# Module: src/back/js/jpure.bend:142
@unsafe
def j_pure_bool_and_true(+t: KTerm) -> Bool:
  kc(Bool, j_pure_bool_and_node(t, "Mat", "True", 2, 1),
    u => j_pure_bool_and_identity(j_strip(kid(t, 0))) && j_pure_bool_and_node(j_strip(kid(t, 1)), "Efq", "", 0, 0), u => False{})

# Module: src/back/js/jpure.bend:147
@unsafe
def j_pure_bool_and_identity(+t: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(t, "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) && List.is_empty(&2, String, rm(t)),
    u => j_pure_bool_and_node(j_strip(kid(t, 0)), "Var", nm(t), 0, 1) && U32.is_eq(ix(j_strip(kid(t, 0))), ix(t)), u => False{})

# Module: src/back/js/jpure.bend:152
@unsafe
def j_pure_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  j_string_literal(book, d) || (p88_string_eq(dk(d), "Def") && U32.is_le(da(d), 32) && U32.is_eq(dx(d), 0) &&
    j_pure_signature(book, dt(d), da(d)) &&
    kc(Bool, db(d), u => j_pure_native(book, d), u =>
      (U32.is_eq(da(d), 0) || p98_tag_eq(j_strip(dv(d)), "Lam") || p98_tag_eq(j_strip(dv(d)), "Mat")) && j_u32_bounded([dv(d)], 8192)))

# Module: src/back/js/jpure.bend:159
@unsafe
def j_pure_add(+d: KDef, +s: JPure) -> JPure:
  kc(JPure, p88_string_eq(dk(lookup(j_pure_defs(s), dn(d))), "Def"), u => s, u =>
    kc(JPure, U32.is_lt(j_region_def_count(j_pure_defs(s)), j_instance_pure_capacity(d, j_pure_defs(s))),
      u => JPure{Con{d, j_pure_defs(s)}, j_pure_fuel(s), j_pure_valid(s)}, u => j_pure_fail(s)))

# Validate the complete own body into a separate callee list before reserving
# a graph node. Backedges can then stop without skipping any body obligation.

# Module: src/back/js/jpure.bend:167
@unsafe
def j_pure_graph(+book: List<&2,KDef>, +d: KDef, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0), u =>
    kc(JPure, p88_string_eq(dk(lookup(j_pure_defs(s), dn(d))), "Def"), u => s, u =>
      kc(JPure, j_pure_eligible(book, d), u =>
        kc(JPure, db(d), u => j_pure_add(d, j_pure_tick(s)), u =>
          j_pure_graph_body(book, d, s, j_pure_prefix(book, Nil{}, dv(d), dt(d), 0, JPure{Nil{}, U32.sub(j_pure_fuel(s), 1), True{}}))), u => j_pure_fail(s))), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:175
@unsafe
def j_pure_graph_body(+book: List<&2,KDef>, +d: KDef, +s: JPure, +body: JPure) -> JPure:
  kc(JPure, j_pure_valid(body), u =>
    j_pure_graph_callees(book, j_pure_defs(body), j_pure_add(d, JPure{j_pure_defs(s), j_pure_fuel(body), True{}})), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:180
@unsafe
def j_pure_graph_callees(+book: List<&2,KDef>, +ds: List<&2,KDef>, +s: JPure) -> JPure:
  match ds:
    case Nil{}: s
    case Con{d, rest}:
      kc(JPure, j_pure_valid(s), u => j_pure_graph_callees(book, rest, j_pure_graph(book, d, s)), u => s)

# Module: src/back/js/jpure.bend:187
@unsafe
def j_pure_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128), u =>
    kc(JPure, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)), u =>
      kc(JPure, p98_tag_eq(body, "Lam") && p88_string_eq(j_l_name(body), ""), u =>
        j_pure_prefix(book, Con{kt("Env", "", ix(body), 0, [wnf(book, kid(head, 0))]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.inc(level), j_pure_tick(s)), u =>
        kc(JPure, p98_tag_eq(body, "Mat") && p88_string_eq(j_l_name(body), ""), u =>
          j_pure_match(book, env, body, head, dc(lookup(book, nm(wnf(book, kid(head, 0))))), U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s))),
      u => j_pure_expr(book, env, body, head, level, s)), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:200
@unsafe
def j_pure_remove(+ds: List<&2,KDef>, +name: String) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, p88_string_eq(dn(d), name), u => rest, u => Con{d, j_pure_remove(rest, name)})

# Complete constructor coverage avoids speculative work before a refutable
# prefix could throw. Default lambdas retain their original typed input.

# Module: src/back/js/jpure.bend:208
@unsafe
def j_pure_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +remaining: List<&2,KDef>, +level: U32, +s: JPure) -> JPure:
  +body = j_strip(t)
  +c = lookup(remaining, nm(body))
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128), u =>
    kc(JPure, p98_tag_eq(body, "Mat") && p88_string_eq(dk(c), "Ctr") && U32.is_eq(terms_len(ks(body)), 2), u =>
      j_pure_match_next(book, env, body, ty, j_pure_remove(remaining, nm(body)), U32.inc(level),
        j_pure_prefix(book, env, kid(body, 0), j_arm_type(book, ty, nm(body)), U32.inc(level), j_pure_tick(s))), u =>
      kc(JPure, p98_tag_eq(body, "Efq") && U32.is_eq(terms_len(ks(body)), 0) && List.is_empty(&2, KDef, remaining), u => j_pure_tick(s), u =>
        kc(JPure, p98_tag_eq(body, "Lam"), u => j_pure_prefix(book, env, body, ty, U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s)))), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:219
@unsafe
def j_pure_match_next(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +remaining: List<&2,KDef>, +level: U32, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s), u => j_pure_match(book, env, kid(t, 1), ty, remaining, level, s), u => s)

# Module: src/back/js/jpure.bend:223
@unsafe
def j_pure_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  kc(JPure, j_pure_valid(s) && U32.is_gt(j_pure_fuel(s), 0) && U32.is_lt(level, 128) && j_pure_type(book, ty), u =>
    j_pure_expr_on(book, env, t, wnf(book, ty), U32.inc(level), j_pure_tick(s)), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:228
@unsafe
def j_pure_expr_on(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  kc(JPure, p98_tag_eq(t, "Ann"), u =>
    kc(JPure, j_pure_type(book, kid(t, 1)) && j_pure_same_closed(book, kid(t, 1), ty, 64), u =>
      j_pure_expr(book, env, kid(t, 0), ty, level, s), u => j_pure_fail(s)), u =>
  kc(JPure, p98_tag_eq(t, "Var"), u =>
    kc(JPure, j_pure_type(book, j_env(env, ix(t))) && j_pure_same_closed(book, j_env(env, ix(t)), ty, 64), u => s, u => j_pure_fail(s)), u =>
  kc(JPure, p98_tag_eq(t, "Ref"), u =>
    kc(JPure, j_string_literal(book, lookup(book, nm(t))) && j_pure_same_closed(book, dt(lookup(book, nm(t))), ty, 64),
      u => j_pure_add(lookup(book, nm(t)), s),
      u => j_pure_call(book, env, kt("Call", nm(t), 0, 0, Nil{}), ty, level, s)), u =>
  kc(JPure, p98_tag_eq(t, "Lit"), u =>
    kc(JPure, p88_string_eq(nm(t), nm(ty)) && String.contains("|U32|Nat|F32|String|Char|", "|" ++ nm(t) ++ "|"), u => s, u => j_pure_fail(s)), u =>
  kc(JPure, p98_tag_eq(t, "Ctr"), u => j_pure_constructor(book, env, t, ty, level, s), u =>
  kc(JPure, p98_tag_eq(t, "Let"), u =>
    j_pure_bindings(book, env, j_context(book, env, ks(t)), ks(t), ty, level, s), u =>
  kc(JPure, p98_tag_eq(t, "App"), u => j_pure_call(book, env, j_call_spine(t, Nil{}), ty, level, s), u => j_pure_fail(s))))))))

# Module: src/back/js/jpure.bend:246
@unsafe
def j_pure_constructor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +c = lookup(dc(lookup(book, nm(ty))), nm(t))
  kc(JPure, p88_string_eq(dk(c), "Ctr") && U32.is_eq(terms_len(ks(t)), da(c)),
    u => j_pure_args(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), ty, level, s), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:252
@unsafe
def j_pure_bindings(+book: List<&2,KDef>, +env: List<&2,KTerm>, +bodyEnv: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  match xs:
    case Nil{}: j_pure_fail(s)
    case Con{body, Nil{}}: j_pure_expr(book, bodyEnv, body, ty, level, s)
    case Con{bind, rest}:
      kc(JPure, j_pure_valid(s) && p98_tag_eq(bind, "Bind") && Bool.not(U32.is_eq(qt(bind), 0)) && U32.is_eq(terms_len(ks(bind)), 1), u =>
        j_pure_bindings(book, env, bodyEnv, rest, ty, level,
          j_pure_expr(book, env, kid(bind, 0), j_region_type(book, env, kid(bind, 0)), level, s)), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:262
@unsafe
def j_pure_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +level: U32, +s: JPure) -> JPure:
  +d = lookup(book, nm(spine))
  kc(JPure, p98_tag_eq(spine, "Call") && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(JPure, j_primitive_call(book, spine), u => j_pure_args(book, env, ks(spine), dt(d), ty, level, s), u =>
      kc(JPure, j_pure_eligible(book, d), u => j_pure_args(book, env, ks(spine), dt(d), ty, level, j_pure_add(d, s)), u => j_pure_fail(s))), u => j_pure_fail(s))

# Module: src/back/js/jpure.bend:269
@unsafe
def j_pure_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +result: KTerm, +level: U32, +s: JPure) -> JPure:
  j_pure_args_head(book, env, xs, wnf(book, ty), result, level, s)

# Module: src/back/js/jpure.bend:273
@unsafe
def j_pure_args_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +head: KTerm, +result: KTerm, +level: U32, +s: JPure) -> JPure:
  match xs:
    case Nil{}:
      kc(JPure, j_pure_type(book, head) && j_pure_same_closed(book, head, result, 64), u => s, u => j_pure_fail(s))
    case Con{h, rest}:
      kc(JPure, j_pure_valid(s) && p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_pure_type(book, kid(head, 0)), u =>
        j_pure_args(book, env, rest, j_app_type(head, h), result, level,
          j_pure_expr(book, env, h, kid(head, 0), level, s)), u => j_pure_fail(s))

# The direct plan and purity proof are independent. A refused direct plan is
# discarded, including its tentative helpers and fuel; the residual proof starts
# from the original state and must establish every reachable body obligation.

# Module: src/back/js/jpure.bend:286
@unsafe
def j_region_try_helper(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +original: JRegionBuild, +direct: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(direct), u =>
    j_region_call_helper(book, env, spine, ty, active, depth, level, direct), u =>
    kc(JRegionBuild, j_pure_signature(book, dt(lookup(book, nm(spine))), terms_len(ks(spine))), u =>
      j_region_residual_proved(book, env, spine, ty, active, depth, level, original,
        j_pure_graph(book, lookup(book, nm(spine)), JPure{Nil{}, j_region_fuel(original), True{}})), u => j_region_fail(original)))

# Module: src/back/js/jpure.bend:294
@unsafe
def j_region_residual_proved(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +original: JRegionBuild, +pure: JPure) -> JRegionBuild:
  kc(JRegionBuild, j_pure_valid(pure), u =>
    j_region_call_helper(book, env, spine, ty, active, depth, level,
      j_region_residual_merge(j_pure_defs(pure), JRegionBuild{j_region_term(original), j_region_helpers(original), j_pure_fuel(pure), True{}})), u => j_region_fail(original))

# Module: src/back/js/jpure.bend:300
@unsafe
def j_region_residual_merge(+ds: List<&2,KDef>, +s: JRegionBuild) -> JRegionBuild:
  match ds:
    case Nil{}: s
    case Con{d, rest}:
      kc(JRegionBuild, j_region_valid(s), u =>
        kc(JRegionBuild, p88_string_eq(dk(lookup(j_region_helpers(s), dn(d))), "Def"), u => j_region_residual_merge(rest, s), u =>
          kc(JRegionBuild, U32.is_lt(j_region_def_count(j_region_helpers(s)), 32), u =>
            j_region_residual_merge(rest, JRegionBuild{j_region_term(s),
              Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), kt("JResidual", "", 0, 0, [dv(d)]), dc(d), db(d), du(d)}, j_region_helpers(s)},
              j_region_fuel(s), True{}}), u => j_region_fail(s))), u => s)

# Module: src/back/js/jpure.bend:312
@unsafe
def j_region_has_residual(+ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: p98_tag_eq(dv(d), "JResidual") || j_region_has_residual(rest)


# Exact planner results belong to one immutable JS emission request. The first
# BookCache child stays the original source index; the second is private facts.
# Logical planners still accept arbitrary definitions and never use name-only
# facts. Cached entry points always obtain the original definition by lookup.

# Module: src/back/js/jpure.bend:323
@unsafe
def j_component_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, False{})
  kc(JPure, p88_string_eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_component_plan(book, lookup(book, name)))

# Module: src/back/js/jpure.bend:330
@unsafe
def j_direct_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, True{})
  kc(JPure, p88_string_eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_direct_plan(book, lookup(book, name)))

# Module: src/back/js/jpure.bend:337
@unsafe
def j_plan_lookup(+book: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{cache, rest}:
      kc(KDef, p88_string_eq(dk(cache), "BookCache"),
        u => j_plan_payload(dc(cache), name, direct), u => missing())

# Module: src/back/js/jpure.bend:345
@unsafe
def j_plan_payload(+children: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match children:
    case Nil{}: missing()
    case Con{source, rest}:
      +payload = index_first(rest)
      kc(KDef, p88_string_eq(dk(payload), "JSPlanContext") && p88_string_eq(dn(payload), "$js.plans"),
        u => j_plan_index(dc(payload), name, direct), u => missing())

# Module: src/back/js/jpure.bend:354
@unsafe
def j_plan_index(+indexes: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match indexes:
    case Nil{}: missing()
    case Con{component, rest}:
      index_find(kc(KDef, direct, u => index_first(rest), u => component), name, index_hash(name, 2166136261), 32)

# Module: src/back/js/jpure.bend:361
@unsafe
def j_plan_fact(+name: String, +pure: JPure) -> KDef:
  KDef{name, "JSPlanFact", j_pure_fuel(pure), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, j_pure_defs(pure), j_pure_valid(pure), False{}}

# Strip any prior facts before preparing a fresh request. Source lookup and
# maximum binder identity remain exactly those of the incoming BookCache.

# Module: src/back/js/jpure.bend:367
@unsafe
def j_plan_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(cache), "BookCache"), u =>
        j_plan_prepare(KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache))], db(cache), du(cache)}, rest, defs), u => book)

# Module: src/back/js/jpure.bend:375
@unsafe
def j_plan_prepare(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  +source = {Con{cache, rest} : List<&2,KDef>}
  +components = j_plan_components(source, defs, book_cached(Nil{}, 0))
  +directs = j_plan_directs(source, j_plan_needed(source, defs, book_cached(Nil{}, 0)), book_cached(Nil{}, 0))
  Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
    [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
      [index_first(dc(index_first(components))), index_first(dc(index_first(directs)))], False{}, False{}}], db(cache), du(cache)}, rest}

# Only definitions whose ordinary emitter already asks for a component plan.
# Duplicate selected names share the canonical original definition once.

# Module: src/back/js/jpure.bend:386
@unsafe
def j_plan_emitted(+d: KDef) -> Bool:
  p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(dv(d), "Absent")) && Bool.not(p98_tag_eq(dv(d), "Foreign"))

# Module: src/back/js/jpure.bend:391
@unsafe
def j_plan_components(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_components(book, rest, kc(List<&2,KDef>, j_plan_emitted(d) && p88_string_eq(dk(lookup(done, dn(d))), "Absent"),
        u => book_put(done, j_plan_fact(dn(d), j_component_plan(book, lookup(book, dn(d))))), u => done))

# The scan gathers saturated nonprimitive source call targets. Its bound only
# limits reuse: every uncollected target still runs the unchanged logical plan.

# Module: src/back/js/jpure.bend:401
@unsafe
def j_plan_needed(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_needed(book, rest, kc(List<&2,KDef>, j_plan_emitted(d),
        u => j_plan_scan(book, [dv(d)], 8192, done), u => done))

# Module: src/back/js/jpure.bend:409
@unsafe
def j_plan_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32, +done: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: done
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_plan_scan(book, List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1),
          kc(List<&2,KDef>, p98_tag_eq(t, "App"),
            u => j_plan_call(book, j_call_spine(t, Nil{}), done), u => done)), u => done)

# Module: src/back/js/jpure.bend:419
@unsafe
def j_plan_call(+book: List<&2,KDef>, +spine: KTerm, +done: List<&2,KDef>) -> List<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(List<&2,KDef>, p98_tag_eq(spine, "Call") && p88_string_eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) && Bool.not(j_primitive_call(book, spine)) &&
    p88_string_eq(dk(lookup(done, dn(d))), "Absent"), u => book_put(done, d), u => done)

# Module: src/back/js/jpure.bend:426
@unsafe
def j_plan_directs(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_directs(book, rest, kc(List<&2,KDef>, p88_string_eq(dk(d), "Def"),
        u => book_put(done, j_plan_fact(dn(d), j_direct_plan(book, lookup(book, dn(d))))), u => done))

# Exact closed native containers. The root graph proves ownership separately;
# these predicates never grant public entry and do not change U32 List selectors.

# Module: src/back/js/jpure.bend:436
@unsafe
def j_pure_native_ctor(+c: KDef, +name: String, +arity: U32) -> Bool:
  p88_string_eq(dk(c), "Ctr") && db(c) && p88_string_eq(dn(c), name) && U32.is_eq(da(c), arity) && U32.is_eq(dx(c), 0)

# Module: src/back/js/jpure.bend:440
@unsafe
def j_pure_list_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "List")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "List") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 2) &&
    j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "Nil"), "Nil", 0) && j_pure_native_ctor(lookup(dc(owner), "Con"), "Con", 2)

# Module: src/back/js/jpure.bend:450
@unsafe
def j_pure_shape_bound(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0), u =>
      j_pure_shape_bound(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

# Module: src/back/js/jpure.bend:457
@unsafe
def j_pure_sigma_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Sigma")
  +family = kid(ty, 3)
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Sigma") && U32.is_eq(terms_len(ks(ty)), 4) &&
    List.is_empty(&2, String, rm(ty)) && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 4) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 1) &&
    p98_tag_eq(kid(ty, 0), "Qua") && (U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 0)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 0))) &&
    p98_tag_eq(kid(ty, 1), "Qua") && (U32.is_eq(qt(kid(ty, 1)), 1) || U32.is_eq(qt(kid(ty, 1)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 1))) &&
    p98_tag_eq(family, "Lam") && U32.is_eq(qt(family), 1) && U32.is_eq(terms_len(ks(family)), 1) &&
    List.is_empty(&2, String, rm(family)) && j_pure_shape_bound([family], 256) &&
    U32.is_eq(j_region_counter_uses([kid(family, 0)], ix(family), 0), 0) &&
    j_map_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty))), qt(kid(ty, 0)), qt(kid(ty, 1))) &&
    j_pure_native_ctor(lookup(dc(owner), "Tuple"), "Tuple", 2)

# Module: src/back/js/jpure.bend:472
@unsafe
def j_pure_closed_list(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_list_head(book, head) && j_pure_type(book, head)

# Module: src/back/js/jpure.bend:477
@unsafe
def j_pure_closed_sigma(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_sigma_head(book, head) && j_pure_type(book, head)

# Parameterless canonical user/scalar owners need no alpha comparison. List and
# independent Sigma compare their complete normalized specialization recursively.

# Module: src/back/js/jpure.bend:484
@unsafe
def j_pure_same_closed(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Bool:
  j_region_local_ok(j_pure_same_check(book, a, b, fuel))

# Module: src/back/js/jpure.bend:488
@unsafe
def j_pure_same_check(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u => j_pure_same_heads(book, wnf(book, a), wnf(book, b), U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:492
@unsafe
def j_pure_same_heads(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Maybe") || p88_string_eq(nm(b), "Maybe"), u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, a) && j_map_maybe_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Map") || p88_string_eq(nm(b), "Map"), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "List") || p88_string_eq(nm(b), "List"), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, a) && j_pure_list_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Sigma") || p88_string_eq(nm(b), "Sigma"), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b) &&
      U32.is_eq(qt(kid(a, 0)), qt(kid(b, 0))) && U32.is_eq(qt(kid(a, 1)), qt(kid(b, 1))), u =>
      j_pure_same_next(book, kid(kid(a, 3), 0), kid(kid(b, 3), 0),
        j_pure_same_check(book, kid(a, 2), kid(b, 2), fuel)), u => None{}), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(a, "ADT") && p98_tag_eq(b, "ADT") && p88_string_eq(nm(a), nm(b)) &&
      List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)) &&
      List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))))

# Module: src/back/js/jpure.bend:512
@unsafe
def j_pure_same_next(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case Some{fuel}: j_pure_same_check(book, a, b, fuel)
    case None{}: None{}

# Native constructors retain exact field quantities and complete terminal type.
# A List tail is checked against its current specialization, not recursively
# re-expanded. Its element already consumes the shared type-proof budget.

# Module: src/back/js/jpure.bend:521
@unsafe
def j_pure_closed_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_closed_fields_head(book, wnf(book, tel), expected, left, active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:526
@unsafe
def j_pure_closed_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{}), u =>
  kc(Maybe<&2,U32>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
    j_pure_same_closed(book, kid(tel, 0), j_pure_closed_field(expected, left), 64), u =>
    kc(Maybe<&2,U32>, p88_string_eq(nm(expected), "List") && U32.is_eq(left, 1), u =>
      kc(Maybe<&2,U32>, j_pure_same_closed(book, kid(tel, 0), expected, 64), u =>
        j_pure_closed_fields(book, kid(tel, 1), expected, 0, active, fuel), u => None{}), u =>
      j_pure_closed_fields_next(book, kid(tel, 1), expected, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(tel, 0), active, fuel))), u => None{}))

# Module: src/back/js/jpure.bend:538
@unsafe
def j_pure_closed_field(+ty: KTerm, +left: U32) -> KTerm:
  kc(KTerm, p88_string_eq(nm(ty), "List"), u => kc(KTerm, U32.is_eq(left, 2), u => kid(ty, 1), u => ty), u =>
    kc(KTerm, U32.is_eq(left, 2), u => kid(ty, 2), u => kid(kid(ty, 3), 0)))

# Module: src/back/js/jpure.bend:543
@unsafe
def j_pure_closed_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_closed_fields(book, tel, expected, left, active, fuel)
    case None{}: None{}

# Module: src/back/js/jpure.bend:549
@unsafe
def j_pure_list_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "List")
  j_pure_closed_fields_next(book, j_specialize(book, dt(lookup(dc(owner), "Con")), ks(ty)), ty, 2, active,
    j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Nil")), ks(ty)), ty, 0, active, fuel))

# Module: src/back/js/jpure.bend:555
@unsafe
def j_pure_sigma_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "Sigma")
  j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Tuple")), ks(ty)), ty, 2, active, fuel)

# Residual Nat addition keeps its original checkedNat runtime call and range
# errors. Native registration captures exactly that immutable descriptor; no
# direct/flat native emitter is widened by this source-signature proof.

# Module: src/back/js/jpure.bend:563
@unsafe
def j_pure_nat_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  p88_string_eq(dn(d), "Nat.add") && p88_string_eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) && p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 1) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && p98_tag_eq(rest, "All") && U32.is_eq(qt(rest), 1) &&
    j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat")

# Proposed exact proofs; integrate only with all runtime/capture consumers.

# Module: src/back/js/jpure.bend:573
@unsafe
def j_string_owner(+book: List<&2,KDef>, +ty: KTerm, +name: String, +count: U32) -> Bool:
  kc(Bool, p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), name) && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty)),
    u => j_string_owner_header(book, name, count), u => False{})

# Module: src/back/js/jpure.bend:578
@unsafe
def j_string_owner_header(+book: List<&2,KDef>, +name: String, +count: U32) -> Bool:
  +owner = lookup(book, name)
  +kind = wnf(book, dt(owner))
  p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), count) && p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) && List.is_empty(&2, KTerm, ks(kid(kind, 0)))

# Module: src/back/js/jpure.bend:586
@unsafe
def j_string_char_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_string_owner(book, ty, "Char", 1), u => j_string_char_type_fields(book), u => False{})

# Module: src/back/js/jpure.bend:590
@unsafe
def j_string_char_type_fields(+book: List<&2,KDef>) -> Bool:
  +c = lookup(dc(lookup(book, "Char")), "Chr")
  +tel = wnf(book, dt(c))
  j_pure_native_ctor(c, "Chr", 1) &&
    p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) && U32.is_eq(terms_len(ks(tel)), 2) &&
    j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") && j_string_owner(book, wnf(book, kid(tel, 1)), "Char", 1)

# Module: src/back/js/jpure.bend:598
@unsafe
def j_string_string(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_string_owner(book, ty, "String", 2), u => j_string_string_fields(book), u => False{})

# Module: src/back/js/jpure.bend:602
@unsafe
def j_string_string_fields(+book: List<&2,KDef>) -> Bool:
  +cs = dc(lookup(book, "String"))
  +nil = lookup(cs, "SNil")
  +con = lookup(cs, "SCon")
  +tel = wnf(book, dt(con))
  +rest = wnf(book, kid(tel, 1))
  j_pure_native_ctor(nil, "SNil", 0) && j_pure_native_ctor(con, "SCon", 2) &&
    j_string_owner(book, wnf(book, dt(nil)), "String", 2) && p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
    U32.is_eq(terms_len(ks(tel)), 2) && j_string_char_type(book, wnf(book, kid(tel, 0))) &&
    p98_tag_eq(rest, "All") && U32.is_eq(qt(rest), 1) && U32.is_eq(terms_len(ks(rest)), 2) &&
    j_string_owner(book, wnf(book, kid(rest, 0)), "String", 2) && j_string_owner(book, wnf(book, kid(rest, 1)), "String", 2)

# Module: src/back/js/jpure.bend:615
@unsafe
def j_string_literal(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, p88_string_eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0),
    u => j_string_literal_body(book, d), u => False{})

# Module: src/back/js/jpure.bend:620
@unsafe
def j_string_literal_body(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +body = j_strip(dv(d))
  +head = wnf(book, dt(d))
  kc(Bool, p98_tag_eq(body, "Lit") && p88_string_eq(nm(body), nm(head)) &&
    String.contains("|U32|Nat|F32|String|Char|", "|" ++ nm(body) ++ "|") && j_u32_bounded([body], 256),
      u => j_pure_type(book, head), u => False{})

# Conservatively mark every syntactic String/Char/native constructor occurrence;
# unknown/fuel exhaustion marks the host family too, never silently ignores it.

# Module: src/back/js/jpure.bend:630
@unsafe
def j_string_uses(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || String.contains("|String|Char|SNil|SCon|Chr|", "|" ++ nm(t) ++ "|"), u => True{}, u =>
        j_string_uses(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)))

# Bounded normalized typed-family walk. The flat queue shares one work budget;
# the seen owner set avoids recursive/copy expansion. Unknown/exhaustion=>true.

# Module: src/back/js/jpure.bend:640
@unsafe
def j_string_family(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{ty, rest}:
      kc(Bool, U32.is_eq(fuel, 0), u => True{}, u =>
        j_string_family_head(book, wnf(book, ty), rest, seen, U32.sub(fuel, 1)))

# Module: src/back/js/jpure.bend:648
@unsafe
def j_string_family_head(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  kc(Bool, p88_string_eq(nm(ty), "String") || p88_string_eq(nm(ty), "Char"), u => True{}, u =>
  kc(Bool, j_region_scalar(book, ty), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, p98_tag_eq(ty, "All"), u => j_string_family(book, Con{kid(ty, 0), Con{kid(ty, 1), todo}}, seen, fuel), u =>
  kc(Bool, p98_tag_eq(ty, "Qua") && List.is_empty(&2, KTerm, ks(ty)), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, p98_tag_eq(ty, "Lam") && U32.is_eq(terms_len(ks(ty)), 1), u => j_string_family(book, Con{kid(ty, 0), todo}, seen, fuel), u =>
  kc(Bool, p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT"), u =>
    kc(Bool, has_name(seen, nm(ty)), u => j_string_family(book, List.append(&2, KTerm, ks(ty), todo), seen, fuel), u =>
      j_string_family(book, j_string_family_ctors(book, dc(lookup(book, nm(ty))), ks(ty), List.append(&2, KTerm, ks(ty), todo)), Con{nm(ty), seen}, fuel)), u => True{}))))))

# Module: src/back/js/jpure.bend:659
@unsafe
def j_string_family_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +args: List<&2,KTerm>, +todo: List<&2,KTerm>) -> List<&2,KTerm>:
  match cs:
    case Nil{}: todo
    case Con{c, rest}: Con{j_specialize(book, dt(c), args), j_string_family_ctors(book, rest, args, todo)}

# Exact native Map<&2,scalar-or-Unit> specialization. Constructor rows are validated;
# owner names alone never grant shape/ownership or public argument permission.

# Module: src/back/js/jpure.bend:667
@unsafe
def j_pure_map_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Map")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Map") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && (j_region_scalar(book, kid(ty, 1)) || j_pure_unit_type(book, kid(ty, 1))) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "MTip"), "MTip", 0) &&
    j_pure_native_ctor(lookup(dc(owner), "MLeaf"), "MLeaf", 2) &&
    j_pure_native_ctor(lookup(dc(owner), "MNode"), "MNode", 3)

# Module: src/back/js/jpure.bend:679
@unsafe
def j_pure_closed_map(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_map_head(book, head) && j_pure_type(book, head)

# Module: src/back/js/jpure.bend:684
@unsafe
def j_pure_map_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_map_fields_head(book, wnf(book, tel), expected, fields, active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:689
@unsafe
def j_pure_map_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match fields:
    case Nil{}:
      kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{})
    case Con{h, rest}:
      kc(Maybe<&2,U32>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
        j_pure_same_closed(book, kid(tel, 0), h, 64), u =>
        kc(Maybe<&2,U32>, j_pure_same_closed(book, h, expected, 64), u =>
          j_pure_map_fields(book, kid(tel, 1), expected, rest, active, fuel), u =>
          j_pure_map_fields_next(book, kid(tel, 1), expected, rest, active,
            j_pure_type_check(book, h, active, fuel))), u => None{})

# Module: src/back/js/jpure.bend:702
@unsafe
def j_pure_map_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}: j_pure_map_fields(book, tel, expected, fields, active, fuel)

# Module: src/back/js/jpure.bend:708
@unsafe
def j_pure_map_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Map"))
  j_pure_map_leaf(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "MTip")), ks(ty)), ty, Nil{}, active, fuel))

# Module: src/back/js/jpure.bend:714
@unsafe
def j_pure_map_leaf(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MLeaf")
      j_pure_map_node(book, ty, active,
        j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
          [kt("ADT", "String", 0, 0, Nil{}), kid(ty, 1)], active, fuel))

# Module: src/back/js/jpure.bend:724
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

# Module: src/back/js/jpure.bend:737
@unsafe
def j_erased_closed_arg(+book: List<&2,KDef>, +arg: KTerm) -> Bool:
  +head = wnf(book, arg)
  kc(Bool, p98_tag_eq(head, "Qua"), u =>
    (U32.is_eq(qt(head), 1) || U32.is_eq(qt(head), 2)) && List.is_empty(&2,KTerm, ks(head)) && List.is_empty(&2,String, rm(head)), u =>
    j_pure_type(book, head) && j_pure_shape_bound([head], 256))

# Module: src/back/js/jpure.bend:744
@unsafe
def j_erased_runtime_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match todo:
    case Nil{}: Some{fuel}
    case Con{t, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && Bool.not(p98_tag_eq(t, "Var") && U32.is_eq(ix(t), binder)), u =>
        kc(Maybe<&2,U32>, p98_tag_eq(t, "Ann"), u =>
          j_erased_runtime_scan(book, Con{kid(t, 0), rest}, binder, U32.sub(fuel, 1)), u =>
        kc(Maybe<&2,U32>, p98_tag_eq(t, "App"), u =>
          j_erased_runtime_call(book, j_call_spine(t, Nil{}), rest, binder, U32.sub(fuel, 1)), u =>
          j_erased_runtime_scan(book, List.append(&2,KTerm, ks(t), rest), binder, U32.sub(fuel, 1)))), u => None{})

# Module: src/back/js/jpure.bend:756
@unsafe
def j_erased_runtime_call(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,U32>, p98_tag_eq(spine, "Call") && p88_string_eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)) && U32.is_le(da(d), 32), u =>
    j_erased_runtime_args(book, ks(spine), dt(d), rest, binder, fuel), u => None{})

# Module: src/back/js/jpure.bend:762
@unsafe
def j_erased_runtime_args(+book: List<&2,KDef>, +args: List<&2,KTerm>, +ty: KTerm, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match args:
    case Nil{}: j_erased_runtime_scan(book, todo, binder, fuel)
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && p98_tag_eq(head, "All"), u =>
        j_erased_runtime_args(book, rest, j_app_type(head, h),
          kc(List<&2,KTerm>, U32.is_eq(qt(head), 0), u => todo, u => Con{h, todo}), binder, U32.sub(fuel, 1)), u => None{})

# Match j_def's unconditional source-emission path. Native intrinsics may retain
# a runtime override; they are not source-body instances or source aliases.

# Module: src/back/js/jpure.bend:774
@unsafe
def j_instance_source_definition(+d: KDef) -> Bool:
  p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(dv(d), "Absent")) && Bool.not(p98_tag_eq(dv(d), "Foreign")) &&
    (Bool.not(db(d)) || Bool.not(j_intrinsic(dn(d))))

# Module: src/back/js/jpure.bend:780
@unsafe
def j_erased_instance(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm) -> Maybe<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,KDef>, p98_tag_eq(spine, "Call") && j_instance_source_definition(d) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)) && j_u32_bounded([dv(d)], 4096), u =>
    j_erased_instance_step(book, env, d, dv(d), dt(d), ks(spine), Nil{}, 0, 8192), u => None{})

# Module: src/back/js/jpure.bend:787
@unsafe
def j_erased_instance_step(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  # The typed All determines erasure; the library pipeline normalizes Lam qty.
  # Runtime absence below proves that substituting this binder is type-only.
  +head = wnf(book, ty)
  +term = j_strip(body)
  kc(Maybe<&2,KDef>, p98_tag_eq(head, "All") && U32.is_eq(qt(head), 0), u =>
    kc(Maybe<&2,KDef>, U32.is_lt(prefix, 4) && U32.is_gt(fuel, 0) && p98_tag_eq(term, "Lam") && p88_string_eq(j_l_name(term), ""), u =>
      j_erased_instance_arg(book, env, original, term, head, args, slots, prefix, fuel), u => None{}), u =>
    kc(Maybe<&2,KDef>, U32.is_gt(prefix, 0) && j_pure_signature(book, head, U32.sub(da(original), prefix)) &&
      U32.is_eq(terms_len(args), U32.sub(da(original), prefix)), u =>
      Some{KDef{dn(original), "JErasedInstance", prefix, da(original), head, body, Con{original, slots}, True{}, False{}}}, u => None{}))

# check_fits uses compare(actual, expected, True); norm_cmp_kind allows Data
# (Qua2) to fit Type (Qua1). Only closed, normalized literal kind quantities are
# admitted here, with reverse1->2 refused. Ground argument/value proofs stay exact.

# Module: src/back/js/jpure.bend:803
@unsafe
def j_erased_kind_fits(+book: List<&2,KDef>, +actual: KTerm, +expected: KTerm) -> Bool:
  exact_term(actual, expected) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 1) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 2))

# Module: src/back/js/jpure.bend:810
@unsafe
def j_erased_closed_kind(+book: List<&2,KDef>, +ty: KTerm, +q: U32) -> Bool:
  kc(Bool, p98_tag_eq(ty, "Typ") && p88_string_eq(nm(ty), "") && U32.is_eq(ix(ty), 0) && U32.is_eq(qt(ty), 0) &&
    U32.is_eq(terms_len(ks(ty)), 1) && List.is_empty(&2,String, rm(ty)),
    u => j_erased_kind_quantity(wnf(book, kid(ty, 0)), q), u => False{})

# Module: src/back/js/jpure.bend:816
@unsafe
def j_erased_kind_quantity(+q: KTerm, +expected: U32) -> Bool:
  p98_tag_eq(q, "Qua") && p88_string_eq(nm(q), "") && U32.is_eq(ix(q), 0) && U32.is_eq(qt(q), expected) &&
    List.is_empty(&2,KTerm, ks(q)) && List.is_empty(&2,String, rm(q))

# Module: src/back/js/jpure.bend:821
@unsafe
def j_erased_instance_arg(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  match args:
    case Nil{}: None{}
    case Con{h, rest}:
      kc(Maybe<&2,KDef>, j_erased_closed_arg(book, h) &&
        j_erased_kind_fits(book, wnf(book, j_erased_arg_type(book, wnf(book, h))), wnf(book, kid(ty, 0))), u =>
        j_erased_instance_scanned(book, env, original, body, ty, wnf(book, h), rest, slots, prefix,
          j_erased_runtime_scan(book, [kid(body, 0)], ix(body), U32.sub(fuel, 1))), u => None{})

# Module: src/back/js/jpure.bend:831
@unsafe
def j_erased_instance_scanned(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +arg: KTerm, +rest: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +r: Maybe<&2,U32>) -> Maybe<&2,KDef>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +slot: KDef = KDef{"", "JErasedSlot", ix(ty), ix(body), kid(ty, 0), arg, Nil{}, False{}, False{}}
      j_erased_instance_step(book, env, original, subst(kid(body, 0), ix(body), arg), j_app_type(ty, arg), rest,
        List.append(&2,KDef, slots, [slot]), U32.inc(prefix), fuel)

# Module: src/back/js/jpure.bend:840
@unsafe
def j_erased_instance_same(+a: KDef, +b: KDef) -> Bool:
  p88_string_eq(dk(a), "JErasedInstance") && p88_string_eq(dk(b), "JErasedInstance") &&
    U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && exact_defs(dc(a), dc(b)) &&
    exact_term(dt(a), dt(b)) && exact_term(dv(a), dv(b))

# Module: src/back/js/jpure.bend:847
@unsafe
def j_erased_arg_type(+book: List<&2,KDef>, +arg: KTerm) -> KTerm:
  kc(KTerm, p98_tag_eq(arg, "Qua"), u => {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u =>
    kc(KTerm, p98_tag_eq(arg, "ADT"), u => tele_fill(book, dt(lookup(book, nm(arg))), ks(arg)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Request-local contextual rows. These are not source definitions and never
# participate in ordinary lookup/exact_def. Each row retains its source Def.

# Module: src/back/js/jpure.bend:857
@unsafe
def j_instances_rows(+s: JInstances) -> List<&2,KDef>:
  match s:
    case JInstances{rows, sources, fuel, valid}: rows

# Module: src/back/js/jpure.bend:862
@unsafe
def j_instances_sources(+s: JInstances) -> List<&2,KDef>:
  match s:
    case JInstances{rows, sources, fuel, valid}: sources

# Module: src/back/js/jpure.bend:867
@unsafe
def j_instances_fuel(+s: JInstances) -> U32:
  match s:
    case JInstances{rows, sources, fuel, valid}: fuel

# Module: src/back/js/jpure.bend:872
@unsafe
def j_instances_valid(+s: JInstances) -> Bool:
  match s:
    case JInstances{rows, sources, fuel, valid}: valid

# Module: src/back/js/jpure.bend:877
@unsafe
def j_instances_fail(+s: JInstances) -> JInstances:
  JInstances{j_instances_rows(s), j_instances_sources(s), 0, False{}}

# Module: src/back/js/jpure.bend:881
@unsafe
def j_instances_has(+rows: List<&2,KDef>, +fact: KDef) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{h, rest}: j_erased_instance_same(h, fact) || j_instances_has(rest, fact)

# Module: src/back/js/jpure.bend:887
@unsafe
def j_instances_source_has(+ds: List<&2,KDef>, +d: KDef) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{h, rest}: exact_def(h, d) || j_instances_source_has(rest, d)

# Module: src/back/js/jpure.bend:893
@unsafe
def j_instances_collect(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +s: JInstances) -> JInstances:
  match todo:
    case Nil{}: s
    case Con{t, rest}:
      kc(JInstances, j_instances_valid(s) && U32.is_gt(j_instances_fuel(s), 0), u =>
        j_instances_node(book, t, rest, JInstances{j_instances_rows(s), j_instances_sources(s), U32.sub(j_instances_fuel(s), 1), True{}}), u => j_instances_fail(s))

# Module: src/back/js/jpure.bend:901
@unsafe
def j_instances_node(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +s: JInstances) -> JInstances:
  kc(JInstances, p98_tag_eq(t, "Ann"), u => j_instances_collect(book, Con{kid(t, 0), rest}, s), u =>
    kc(JInstances, p98_tag_eq(t, "App"), u => j_instances_call(book, j_call_spine(t, Nil{}), rest, s), u =>
      kc(JInstances, p98_tag_eq(t, "Ref") && j_instance_nullary_source(book, lookup(book, nm(t))),
        u => j_instances_call(book, kt("Call", nm(t), 0, 0, Nil{}), rest, s),
        u => j_instances_collect(book, List.append(&2,KTerm, ks(t), rest), s))))

# A nonliteral zero-arity source Ref is a demanded computation, not a closure.

# Module: src/back/js/jpure.bend:910
@unsafe
def j_instance_nullary_source(+book: List<&2,KDef>, +d: KDef) -> Bool:
  U32.is_eq(da(d), 0) && j_instance_source_definition(d) && Bool.not(j_string_literal(book, d))

# Module: src/back/js/jpure.bend:914
@unsafe
def j_instances_call(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +s: JInstances) -> JInstances:
  +d = lookup(book, nm(spine))
  +head = wnf(book, dt(d))
  kc(JInstances, p98_tag_eq(spine, "Call") && p88_string_eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)) && U32.is_le(da(d), 32), u =>
    kc(JInstances, p98_tag_eq(head, "All") && U32.is_eq(qt(head), 0), u =>
      kc(JInstances, U32.is_gt(j_instances_fuel(s), 8192), u =>
        j_instances_fact(book, spine, rest, JInstances{j_instances_rows(s), j_instances_sources(s), U32.sub(j_instances_fuel(s), 8192), True{}}, j_erased_instance(book, Nil{}, spine)), u => j_instances_fail(s)), u =>
      kc(JInstances, Bool.not(j_instance_source_definition(d)) || j_instances_source_has(j_instances_sources(s), d), u =>
        j_instances_collect(book, List.append(&2,KTerm, ks(spine), rest), s), u =>
        kc(JInstances, j_pure_signature(book, dt(d), da(d)) && U32.is_lt(j_region_def_count(j_instances_sources(s)), 64), u =>
          j_instances_collect(book, Con{dv(d), List.append(&2,KTerm, ks(spine), rest)},
            JInstances{j_instances_rows(s), Con{d, j_instances_sources(s)}, j_instances_fuel(s), True{}}), u => j_instances_fail(s)))), u => j_instances_fail(s))

# Module: src/back/js/jpure.bend:928
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

# Module: src/back/js/jpure.bend:943
@unsafe
def j_instance_original(+fact: KDef) -> KDef:
  index_first(dc(fact))

# Module: src/back/js/jpure.bend:947
@unsafe
def j_instance_name(+at: U32) -> String:
  "$instance." ++ U32.show(at)

# Module: src/back/js/jpure.bend:951
@unsafe
def j_instance_alias(+d: KDef) -> KDef:
  KDef{dn(d), "JErasedInstance", 0, da(d), dt(d), dv(d), [d], True{}, False{}}

# Module: src/back/js/jpure.bend:955
@unsafe
def j_instance_aliases(+ds: List<&2,KDef>, +tail: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: tail
    case Con{d, rest}: Con{j_instance_alias(d), j_instance_aliases(rest, tail)}

# Module: src/back/js/jpure.bend:961
@unsafe
def j_instance_fact_exact(+book: List<&2,KDef>, +fact: KDef) -> Bool:
  +original = j_instance_original(fact)
  p88_string_eq(dk(fact), "JErasedInstance") && db(fact) &&
    exact_def(original, lookup(book, dn(original))) && U32.is_eq(dx(fact), da(original)) && U32.is_le(da(fact), dx(fact)) &&
    kc(Bool, U32.is_eq(da(fact), 0), u => exact_def(fact, j_instance_alias(original)), u =>
      j_instance_fact_replay(book, fact, j_erased_instance(book, Nil{},
        kt("Call", dn(original), 0, 0, List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), j_instance_placeholders(U32.sub(da(original), da(fact))))))))

# Module: src/back/js/jpure.bend:970
@unsafe
def j_instance_fact_replay(+book: List<&2,KDef>, +fact: KDef, +r: Maybe<&2,KDef>) -> Bool:
  match r:
    case None{}: False{}
    case Some{again}: j_erased_instance_same(fact, again)

# Module: src/back/js/jpure.bend:976
@unsafe
def j_instance_slot_args(+slots: List<&2,KDef>) -> List<&2,KTerm>:
  match slots:
    case Nil{}: Nil{}
    case Con{slot, rest}: Con{dv(slot), j_instance_slot_args(rest)}

# Module: src/back/js/jpure.bend:982
@unsafe
def j_instance_placeholders(+left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => Nil{}, u => Con{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, j_instance_placeholders(U32.sub(left, 1))})

# Module: src/back/js/jpure.bend:986
@unsafe
def j_instance_fact_index(+rows: List<&2,KDef>, +fact: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, j_erased_instance_same(h, fact), u => at, u => j_instance_fact_index(rest, fact, U32.inc(at)))

# Module: src/back/js/jpure.bend:992
@unsafe
def j_instance_source_index(+rows: List<&2,KDef>, +d: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, U32.is_eq(da(h), 0) && exact_def(j_instance_original(h), d), u => at,
      u => j_instance_source_index(rest, d, U32.inc(at)))

# Module: src/back/js/jpure.bend:999
@unsafe
def j_instance_drop(+args: List<&2,KTerm>, +left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => args, u =>
    kc(List<&2,KTerm>, List.is_empty(&2,KTerm, args), u => Nil{}, u => j_instance_drop(j_instance_tail_terms(args), U32.sub(left, 1))))

# Module: src/back/js/jpure.bend:1004
@unsafe
def j_instance_rewrite(+book: List<&2,KDef>, +rows: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "Ann"), u => k_with_children(t, [j_instance_rewrite(book, rows, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, p98_tag_eq(t, "App"), u => j_instance_rewrite_call(book, rows, t, j_call_spine(t, Nil{})), u =>
      kc(KTerm, p98_tag_eq(t, "Ref") && j_instance_nullary_source(book, lookup(book, nm(t))),
        u => j_instance_rewrite_call(book, rows, t, kt("Call", nm(t), 0, 0, Nil{})),
        u => k_with_children(t, j_instance_rewrites(book, rows, ks(t))))))

# Module: src/back/js/jpure.bend:1012
@unsafe
def j_instance_rewrites(+book: List<&2,KDef>, +rows: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_rewrite(book, rows, t), j_instance_rewrites(book, rows, rest)}

# Module: src/back/js/jpure.bend:1018
@unsafe
def j_instance_rewrite_call(+book: List<&2,KDef>, +rows: List<&2,KDef>, +original: KTerm, +spine: KTerm) -> KTerm:
  +d = lookup(book, nm(spine))
  kc(KTerm, p98_tag_eq(spine, "Call") && p88_string_eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(KTerm, U32.is_eq(qt(wnf(book, dt(d))), 0) && p98_tag_eq(wnf(book, dt(d)), "All"), u =>
      j_instance_rewrite_fact(book, rows, spine, j_erased_instance(book, Nil{}, spine)), u =>
      j_instance_rewrite_live(book, rows, spine, j_instance_source_index(rows, d, 0), 0)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/js/jpure.bend:1026
@unsafe
def j_instance_rewrite_fact(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +r: Maybe<&2,KDef>) -> KTerm:
  match r:
    case None{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Some{fact}:
      +at = j_instance_fact_index(rows, fact, 0)
      kc(KTerm, U32.is_eq(at, 4294967295), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u =>
        kc(KTerm, U32.is_eq(da(fact), dx(fact)), u =>
          kc(KTerm, U32.is_eq(terms_len(ks(j_strip(dv(fact)))), 0) &&
            (p98_tag_eq(j_strip(dv(fact)), "Ctr") || p98_tag_eq(j_strip(dv(fact)), "Lit")),
            u => dv(fact), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u =>
          j_instance_rewrite_live(book, rows, spine, at, da(fact))))

# Module: src/back/js/jpure.bend:1039
@unsafe
def j_instance_rewrite_live(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +at: U32, +prefix: U32) -> KTerm:
  +args = j_instance_rewrites(book, rows, j_instance_drop(ks(spine), prefix))
  kc(KTerm, U32.is_eq(at, 4294967295), u => j_region_app(ref(nm(spine)), args), u => j_region_app(ref(j_instance_name(at)), args))

# Module: src/back/js/jpure.bend:1044
@unsafe
def j_instance_view_defs(+book: List<&2,KDef>, +rows: List<&2,KDef>, +todo: List<&2,KDef>, +at: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: Nil{}
    case Con{fact, rest}:
      +body = j_instance_rewrite(book, rows, dv(fact))
      Con{KDef{j_instance_name(at), "Def", U32.sub(dx(fact), da(fact)), 0, dt(fact),
        body, [fact, j_instance_edge_row(body)], False{}, du(j_instance_original(fact))},
        j_instance_view_defs(book, rows, rest, U32.inc(at))}

# Module: src/back/js/jpure.bend:1054
@unsafe
def j_instance_tail_defs(+ds: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

# Module: src/back/js/jpure.bend:1060
@unsafe
def j_instance_tail_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

# Module: src/back/js/jpure.bend:1066
@unsafe
def j_instance_attach(+book: List<&2,KDef>, +rows: List<&2,KDef>, +sources: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(cache), "BookCache"), u =>
        Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
            [missing(), missing(), KDef{"$js.instances", "JSInstanceContext", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
              [KDef{"rows", "JSInstanceRows", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, rows, True{}, False{}},
               KDef{"sources", "JSInstanceSources", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, sources, True{}, False{}}], True{}, False{}}], False{}, False{}}], db(cache), du(cache)}, rest}, u => book)

# Module: src/back/js/jpure.bend:1078
@unsafe
def j_instance_all_exact(+book: List<&2,KDef>, +rows: List<&2,KDef>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{fact, rest}: j_instance_fact_exact(book, fact) && j_instance_all_exact(book, rest)

# Covered emission requires exact Def membership in the private view plus a
# provenance fact. Uncovered private instance names become Absent and fail the
# pre-emission audit; there is no G[private-name] fallback.

# Module: src/back/js/jpure.bend:1087
@unsafe
def j_instance_cover(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +t: KTerm) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "Ann"), u => k_with_children(t, [j_instance_cover(view, defs, owner, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, p98_tag_eq(t, "App"), u =>
      j_instance_cover_app(view, defs, owner, j_call_spine(t, Nil{})), u =>
      k_with_children(t, j_instance_covers(view, defs, owner, ks(t)))))

# Module: src/back/js/jpure.bend:1094
@unsafe
def j_instance_covers(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_cover(view, defs, owner, t), j_instance_covers(view, defs, owner, rest)}

# Module: src/back/js/jpure.bend:1100
@unsafe
def j_instance_cover_app(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +spine: KTerm) -> KTerm:
  +d = lookup(view, nm(spine))
  +known = lookup(defs, nm(spine))
  +args = j_instance_covers(view, defs, owner, ks(spine))
  kc(KTerm, p98_tag_eq(spine, "Call") && U32.is_eq(terms_len(args), da(d)), u =>
    kc(KTerm, String.starts_with(nm(spine), "$instance."), u =>
      kc(KTerm, exact_def(d, known) && p88_string_eq(dk(index_first(dc(d))), "JErasedInstance"), u =>
        kc(KTerm, p88_string_eq(nm(spine), owner), u => j_region_app(ref(owner), args), u =>
          kc(KTerm, U32.is_gt(j_component_refs(ks(spine), owner, 8192, 0), 0), u =>
            kc(KTerm, j_instance_emit_ready(view, d), u => j_region_app(ref(nm(spine)), args), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u =>
          kc(KTerm, j_instance_emit_ready(view, d), u => j_region_annotate(kt("JCall", nm(spine), 0, 1, args), j_covered_result(dt(d), args)), u => j_instance_residual(view, d, args)))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u =>
      j_region_app(ref(nm(spine)), args)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/js/jpure.bend:1114
@unsafe
def j_instance_no_absent(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0) && Bool.not(p98_tag_eq(t, "Absent")),
      u => j_instance_no_absent(List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

# Module: src/back/js/jpure.bend:1121
@unsafe
def j_instance_covered_audit(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> Bool:
  match rest:
    case Nil{}: True{}
    case Con{d, more}: j_instance_no_absent([j_instance_cover(view, defs, dn(d), dv(d))], 16384) && j_instance_covered_audit(view, defs, more)

# Module: src/back/js/jpure.bend:1127
@unsafe
def j_instance_declarations(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> String:
  match rest:
    case Nil{}: ""
    case Con{d, more}: kc(String, j_instance_emit_ready(view, d), u =>
      j_component_stack_declaration(view, d, j_owned_term(j_instance_cover(view, defs, dn(d), dv(d))), "$tree"), u => "") ++
      j_instance_declarations(view, defs, more)

# Module: src/back/js/jpure.bend:1135
@unsafe
def j_instance_guards(+rows: List<&2,KDef>) -> String:
  match rows:
    case Nil{}: ""
    case Con{fact, rest}: j_quote(dn(j_instance_original(fact))) ++ "," ++ j_instance_guards(rest)

# Profitability prefilter only: keep existing erased calls, also consider exact
# source-call edges. Primitive/literal-only leaves do not duplicate private graphs.
# Exact source aliases still pass the complete collector, provenance and JPure gates.

# Module: src/back/js/jpure.bend:1144
@unsafe
def j_instance_has_graph_call(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        j_instance_has_graph_call_node(book, t, rest, fuel, j_call_spine(t, Nil{})), u => False{})

# Module: src/back/js/jpure.bend:1152
@unsafe
def j_instance_has_graph_call_node(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +spine: KTerm) -> Bool:
  +d = lookup(book, nm(spine))
  kc(Bool, (p98_tag_eq(t, "App") || (p98_tag_eq(t, "Ref") && j_instance_nullary_source(book, d))) &&
    p98_tag_eq(spine, "Call") && p88_string_eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) &&
    ((j_instance_source_definition(d) && U32.is_le(da(d), 32)) ||
      (p98_tag_eq(wnf(book, dt(d)), "All") && U32.is_eq(qt(wnf(book, dt(d))), 0))),
    u => True{}, u => j_instance_has_graph_call(book, List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)))

# Module: src/back/js/jpure.bend:1162
@unsafe
def j_instance_root_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_region_scalar(book, head) || j_string_string(book, head), u =>
    kc(Bool, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_region_scalar(book, kid(head, 0)),
      u => j_instance_root_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Native String results are immutable values already produced by the private
# component emitter. Arguments remain scalar; object/array/closure results do
# not enter through this boundary. Graph, layout and host guards still apply.
# The public fixed-arity wrapper and its generic fallback both consume exactly
# the contiguous leading lambda prefix. A matcher between arguments keeps its
# original public descriptor/demand boundary, but may still be a private callee.

# Module: src/back/js/jpure.bend:1176
@unsafe
def j_instance_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_instance_source_definition(d) && U32.is_le(da(d), 8) &&
    U32.is_eq(j_lambda_count(dv(d)), da(d)) && j_instance_root_signature(book, dt(d), da(d)) &&
    Bool.not(j_string_literal(book, d)) && j_instance_has_graph_call(book, [dv(d)], 2048), u =>
      j_instance_root_collect(book, d, j_instances_collect(book, [dv(d)], JInstances{Nil{}, [d], 1048576, True{}})), u => "")

# Module: src/back/js/jpure.bend:1183
@unsafe
def j_instance_root_collect(+book: List<&2,KDef>, +d: KDef, +s: JInstances) -> String:
  # Native-source public roots require real contextual specialization.
  # New alias-only public wrappers need non-native provenance; their guarded
  # entry cost is unsuitable for small reusable prelude helpers. Such helpers
  # remain eligible as private callees within every complete worker graph.
  kc(String, j_instances_valid(s) && Bool.not(List.is_empty(&2,KDef, j_instances_sources(s))) &&
    (Bool.not(db(d)) || Bool.not(List.is_empty(&2,KDef, j_instances_rows(s)))), u =>
    j_instance_root_rows(book, d, j_instance_aliases(j_instances_sources(s), j_instances_rows(s))), u => "")

# Module: src/back/js/jpure.bend:1193
@unsafe
def j_instance_root_rows(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>) -> String:
  kc(String, j_instance_all_exact(book, rows) && U32.is_le(j_region_def_count(rows), 96), u =>
    j_instance_root_raw(book, d, rows, j_instance_view_defs(book, rows, rows, 0)), u => "")

# Module: src/back/js/jpure.bend:1198
@unsafe
def j_instance_root_view(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, defs, j_instance_attach(book, rows, j_instances_sources(JInstances{Nil{}, [d], 0, True{}})))
  +at = j_instance_source_index(rows, d, 0)
  +pure = j_pure_graph(view, lookup(view, j_instance_name(at)), JPure{Nil{}, 131072, True{}})
  kc(String, j_pure_valid(pure) && j_instance_covered_audit(view, defs, defs) && j_instance_erased_emitted(view, defs), u =>
    j_instance_root_emit(book, view, d, rows, defs, at, pure), u => "")

# Guard dependencies consume the same successful proof used for admission.
# The raw-view proof remains separate because emission metadata changes its book.

# Module: src/back/js/jpure.bend:1208
@unsafe
def j_instance_root_emit(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>, +at: U32, +pure: JPure) -> String:
  kc(String, U32.is_eq(at, 4294967295) || Bool.not(j_instance_emit_ready(view, lookup(view, j_instance_name(at)))), u => "", u =>
    j_instance_root_guarded(book, d, rows, at, pure, j_instance_declarations(view, defs, defs)))

# Both private backends share the identical public wrapper and complete graph
# guard. Only declaration lowering differs; a private machine adds no new entry.

# Module: src/back/js/jpure.bend:1215
@unsafe
def j_instance_root_guarded(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +at: U32, +pure: JPure, +declarations: String) -> String:
  j_instance_root_guarded_mode(book, d, rows, at, pure, declarations, False{})

# Slots are read before the fresh host/String fence; only inert scalar input checks
# intervene before localGuard, so its String-family scan may reuse that entry proof.

# Module: src/back/js/jpure.bend:1221
@unsafe
def j_instance_root_guarded_mode(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +at: U32, +pure: JPure,
  +declarations: String, +numberNat: Bool) -> String:
    "(()=>{" ++ declarations ++ "const $guards=[" ++ j_instance_guards(rows) ++ j_instance_primitive_capabilities(rows, pure) ++ j_instance_native_guards(j_pure_defs(pure)) ++ "];return " ++
    "fn(" ++ U32.show(da(d)) ++ ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&regionProof===null&&regionHostGuard()&&stringHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards,stringHostChecked)){/* private contextual instances */" ++
      kc(String, numberNat, u => jw_nat_inputs(book, dt(d), 0, da(d)), u => "") ++ "return " ++
      kc(String, numberNat && jw_nat_result(book, dt(d), da(d)), u => "BigInt(", u => "") ++
      j_region_name(j_instance_name(at)) ++ "$tree(" ++ j_region_vector_names("$s", 0, da(d)) ++ ")" ++
      kc(String, numberNat && jw_nat_result(book, dt(d), da(d)), u => ")", u => "") ++ ";}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}" ++
    kc(String, U32.is_eq(da(d), 0), u => ",false,true", u => "") ++ "));})()"

# Module: src/back/js/jpure.bend:1236
@unsafe
def j_instance_emit_ready(+view: List<&2,KDef>, +d: KDef) -> Bool:
  +cap = index_first(j_instance_tail_defs(j_instance_tail_defs(dc(d))))
  p88_string_eq(dn(cap), "$js.instance.emission") && p88_string_eq(dk(cap), "JSInstanceEmission") && db(cap)

# Module: src/back/js/jpure.bend:1241
@unsafe
def j_instance_residual(+view: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>) -> KTerm:
  +fact = index_first(dc(d))
  +original = j_instance_original(fact)
  +full = List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), args)
  j_region_annotate(kt("JGeneric", dn(original), 0, 0, full), j_covered_result(dt(original), full))

# Conservative complete inline primitive-family fence. Exact used call types
# are still proved by j_primitive_definition; irrelevant native mutations may
# refuse the private entry and retain ordinary generic behavior.

# Module: src/back/js/jpure.bend:1251
@unsafe
def j_instance_primitive_guards() -> String:
  "\"U32.add\",\"U32.sub\",\"U32.mul\",\"U32.div\",\"U32.mod\",\"U32.and\",\"U32.or\",\"U32.xor\",\"U32.inc\",\"U32.not\",\"U32.shl\",\"U32.shr\",\"U32.shln\",\"U32.shrn\",\"U32.is_zero\",\"U32.is_eq\",\"U32.is_ne\",\"U32.is_lt\",\"U32.is_le\",\"U32.is_gt\",\"U32.is_ge\",\"U32.to_nat\",\"U32.from_nat\",\"U32.to_f32\",\"F32.add\",\"F32.sub\",\"F32.mul\",\"F32.div\",\"F32.mod\",\"F32.neg\",\"F32.is_eq\",\"F32.is_ne\",\"F32.is_lt\",\"F32.is_le\",\"F32.is_gt\",\"F32.is_ge\",\"F32.sqrt\",\"F32.exp\",\"F32.log\",\"F32.log2\",\"F32.log10\",\"F32.sin\",\"F32.cos\",\"F32.tan\",\"F32.asin\",\"F32.acos\",\"F32.atan\",\"F32.sinh\",\"F32.cosh\",\"F32.tanh\",\"F32.floor\",\"F32.ceil\",\"F32.trunc\",\"F32.abs\","

# Module: src/back/js/jpure.bend:1255
@unsafe
def j_instance_native_guards(+graph: List<&2,KDef>) -> String:
  match graph:
    case Nil{}: ""
    case Con{d, rest}: kc(String, String.starts_with(dn(d), "$instance."), u => "", u => j_quote(dn(d)) ++ ",") ++ j_instance_native_guards(rest)

# Module: src/back/js/jpure.bend:1261
@unsafe
def j_instance_erased_emitted(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{d, rest}: (U32.is_gt(da(index_first(dc(d))), 0) && j_instance_emit_ready(view, d)) || j_instance_erased_emitted(view, rest)

# Module: src/back/js/jpure.bend:1268
@unsafe
def j_instance_edge_row(+body: KTerm) -> KDef:
  KDef{"$js.instance.edges", "JSInstanceEdges", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, j_instance_edges([body], Nil{}, 16384), True{}, False{}}

# Module: src/back/js/jpure.bend:1272
@unsafe
def j_instance_edges(+todo: List<&2,KTerm>, +names: List<&2,KDef>, +fuel: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: names
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_instance_edges(List.append(&2,KTerm, ks(t), rest),
          kc(List<&2,KDef>, p98_tag_eq(t, "Ref") && String.starts_with(nm(t), "$instance.") && p88_string_eq(dk(lookup(names, nm(t))), "Absent"),
            u => Con{KDef{nm(t), "JSInstanceEdge", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}}, names}, u => names), U32.sub(fuel, 1)), u => [missing()])

# Metadata occupies fixed slots after provenance; original source names cannot
# shadow rows. Unexpected rows fail closed as an invalid graph edge.

# Module: src/back/js/jpure.bend:1284
@unsafe
def j_instance_edges_checked(+d: KDef) -> List<&2,KDef>:
  +row = index_first(j_instance_tail_defs(dc(d)))
  kc(List<&2,KDef>, p88_string_eq(dn(row), "$js.instance.edges") && p88_string_eq(dk(row), "JSInstanceEdges"),
    u => dc(row), u => [missing()])

# Module: src/back/js/jpure.bend:1290
@unsafe
def j_instance_cycle(+view: List<&2,KDef>, +todo: List<&2,KDef>, +root: String, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{edge, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || Bool.not(p88_string_eq(dk(edge), "JSInstanceEdge")) || p88_string_eq(dn(edge), root), u => True{}, u =>
        kc(Bool, has_name(seen, dn(edge)), u => j_instance_cycle(view, rest, root, seen, U32.sub(fuel, 1)), u =>
          j_instance_cycle(view, List.append(&2,KDef, j_instance_edges_checked(lookup(view, dn(edge))), rest), root,
            Con{dn(edge), seen}, U32.sub(fuel, 1))))

# Module: src/back/js/jpure.bend:1300
@unsafe
def j_instance_caps(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      +ready = U32.is_gt(da(d), 0) && j_component_prefix(view, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0) &&
        Bool.not(j_instance_cycle(view, index_remove(j_instance_edges_checked(d), dn(d)), dn(d), Nil{}, 8192))
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d),
        List.append(&2,KDef, dc(d), [KDef{"$js.instance.emission", "JSInstanceEmission", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, ready, False{}}]), db(d), du(d)},
        j_instance_caps(view, rest)}

# Module: src/back/js/jpure.bend:1311
@unsafe
def j_instance_root_raw(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +raw: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, raw, j_instance_attach(book, rows, [d]))
  +at = j_instance_source_index(rows, d, 0)
  +pure = j_pure_graph(view, lookup(view, j_instance_name(at)), JPure{Nil{}, 131072, True{}})
  kc(String, j_pure_valid(pure) && Bool.not(U32.is_eq(at, 4294967295)), u =>
    j_instance_root_workers(book, view, d, rows, raw, at, pure, j_worker_emission(view, raw)), u => "")

# Module: src/back/js/jpure.bend:1319
@unsafe
def j_instance_root_workers(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +raw: List<&2,KDef>,
  +at: U32, +pure: JPure, +emission: JWEmission) -> String:
  match emission:
    case JWEmission{declarations, numberNat, recursive}:
      kc(String, recursive || j_instance_has_contextual_rows(rows), u =>
        kc(String, p88_string_eq(declarations, ""),
          u => kc(String, j_instance_has_computed_nullary(rows), u => "",
            u => j_instance_root_view(book, d, rows, j_instance_caps(view, raw))),
          u => j_instance_root_guarded_mode(book, d, rows, at, pure, declarations, numberNat)), u => "")

# Legacy coverage handles App spines only. Refused workers with any nullary
# source row keep ordinary source emission, never private G loads.

# Module: src/back/js/jpure.bend:1332
@unsafe
def j_instance_has_computed_nullary(+rows: List<&2,KDef>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{row, rest}:
      +original = j_instance_original(row)
      U32.is_eq(da(original), 0) || j_instance_has_computed_nullary(rest)

# Alias rows have an erased prefix of zero; real contextual rows have consumed
# at least one erased argument. Their historical admission remains unchanged.
# A new alias-only public guard requires recursive work to amortize its entry.

# Module: src/back/js/jpure.bend:1343
@unsafe
def j_instance_has_contextual_rows(+rows: List<&2,KDef>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{row, rest}: U32.is_gt(da(row), 0) || j_instance_has_contextual_rows(rest)

# Exact native scalar-key components needed by closed Map graphs. These proof
# rows do not create public argument admission or change residual native code.

# Module: src/back/js/jpure.bend:1351
@unsafe
def j_map_cmp_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Cmp")
  +kind = wnf(book, dt(owner))
  j_map_cmp_nominal(ty) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "LT"), "LT", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "EQ"), "EQ", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "GT"), "GT", ty)

# ADT quant0/1 is source-node metadata, not a Cmp quantity parameter. The
# canonical owner has no parameters; constructors must terminate at this exact
# nominal zeroarity type. No recursive type proof or metadata-erasing rewrite.

# Module: src/back/js/jpure.bend:1366
@unsafe
def j_map_cmp_nominal(+ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Cmp") && U32.is_eq(ix(ty), 0) &&
    (U32.is_eq(qt(ty), 0) || U32.is_eq(qt(ty), 1)) &&
    List.is_empty(&2,KTerm, ks(ty)) && List.is_empty(&2,String, rm(ty))

# Module: src/back/js/jpure.bend:1372
@unsafe
def j_map_cmp_ctor(+book: List<&2,KDef>, +c: KDef, +name: String, +ty: KTerm) -> Bool:
  j_pure_native_ctor(c, name, 0) && j_map_cmp_nominal(ty) && j_map_cmp_nominal(wnf(book, dt(c)))

# Module: src/back/js/jpure.bend:1376
@unsafe
def j_map_maybe_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Maybe")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Maybe") && U32.is_eq(terms_len(ks(ty)), 2) && List.is_empty(&2,String, rm(ty)) &&
    p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) && List.is_empty(&2,KTerm, ks(kid(ty, 0))) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 2) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "None"), "None", 0) && j_pure_native_ctor(lookup(dc(owner), "Some"), "Some", 1)

# Module: src/back/js/jpure.bend:1385
@unsafe
def j_map_maybe_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Maybe"))
  j_map_maybe_some(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "None")), ks(ty)), ty, Nil{}, active, fuel))

# Module: src/back/js/jpure.bend:1391
@unsafe
def j_map_maybe_some(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Maybe")), "Some")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty, [kid(ty, 1)], active, fuel)

# Module: src/back/js/jpure.bend:1399
@unsafe
def j_map_closed_maybe(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_map_maybe_head(book, head) && j_pure_type(book, head)

# Module: src/back/js/jpure.bend:1404
@unsafe
def j_map_sigma_kind(+ty: KTerm, +qa: U32, +qb: U32) -> Bool:
  +q = kid(ty, 0)
  p98_tag_eq(ty, "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    kc(Bool, p98_tag_eq(q, "Qua"), u => U32.is_eq(qt(q), kc(U32, U32.is_eq(qa, 1) || U32.is_eq(qb, 1), u => 1, u => 2)) && List.is_empty(&2,KTerm, ks(q)), u =>
      p98_tag_eq(q, "Min") && U32.is_eq(terms_len(ks(q)), 2) && p98_tag_eq(kid(q, 0), "Qua") && U32.is_eq(qt(kid(q, 0)), qa) &&
      List.is_empty(&2,KTerm, ks(kid(q, 0))) && p98_tag_eq(kid(q, 1), "Qua") && U32.is_eq(qt(kid(q, 1)), qb) && List.is_empty(&2,KTerm, ks(kid(q, 1))))

# Module: src/back/js/jpure.bend:1412
@unsafe
def j_map_native_binary(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  p88_string_eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) &&
    p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 1) && p98_tag_eq(rest, "All") && U32.is_eq(qt(rest), 1) &&
    kc(Bool, p88_string_eq(dn(d), "U32.cmp"), u =>
      j_primitive_type(book, wnf(book, kid(ty, 0)), "U32") && j_primitive_type(book, wnf(book, kid(rest, 0)), "U32") && j_map_cmp_type(book, wnf(book, kid(rest, 1))), u =>
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") &&
      kc(Bool, p88_string_eq(dn(d), "Nat.sub"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat"), u =>
      kc(Bool, p88_string_eq(dn(d), "Nat.is_lt"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool"), u =>
      p88_string_eq(dn(d), "Nat.divmod") && j_map_native_divmod_result(book, wnf(book, kid(rest, 1))))))

# Residual String.append keeps runtime fn/call ABI and native snapshot guards.

# Module: src/back/js/jpure.bend:1426
@unsafe
def j_map_native_string(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, p88_string_eq(dn(d), "String.append") && p88_string_eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")),
    u => j_map_native_string_signature(book, wnf(book, dt(d))), u => False{})

# Module: src/back/js/jpure.bend:1432
@unsafe
def j_map_native_string_signature(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 1) && j_string_string(book, wnf(book, kid(ty, 0))),
    u => j_map_native_string_result(book, wnf(book, kid(ty, 1))), u => False{})

# Module: src/back/js/jpure.bend:1437
@unsafe
def j_map_native_string_result(+book: List<&2,KDef>, +rest: KTerm) -> Bool:
  p98_tag_eq(rest, "All") && U32.is_eq(qt(rest), 1) &&
    j_string_string(book, wnf(book, kid(rest, 0))) && j_string_string(book, wnf(book, kid(rest, 1)))

# Module: src/back/js/jpure.bend:1442
@unsafe
def j_map_native_divmod_result(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_pure_closed_sigma(book, ty) && j_primitive_type(book, wnf(book, kid(ty, 2)), "Nat") &&
    j_primitive_type(book, wnf(book, kid(kid(ty, 3), 0)), "Nat")

# Module: src/back/js/jpure.bend:1447
@unsafe
def j_instance_public_capture(+d: KDef) -> Bool:
  j_instance_source_definition(d) && U32.is_le(da(d), 32) &&
    (U32.is_eq(da(d), 0) || p98_tag_eq(j_strip(dv(d)), "Lam") || p98_tag_eq(j_strip(dv(d)), "Mat"))

# Module: src/back/js/jpure.bend:1452
@unsafe
def j_instance_pure_capacity(+d: KDef, +ds: List<&2,KDef>) -> U32:
  kc(U32, p88_string_eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(ds), u => 128, u => 32)

# Module: src/back/js/jpure.bend:1456
@unsafe
def j_instance_pure_rows(+ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: p88_string_eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(rest)

# A source child reconstructed from inert projected fields remains private.
# Full graph/type proof independently validates constructor identity and fields.

# Module: src/back/js/jpure.bend:1464
@unsafe
def j_instance_child_fields(+env: List<&2,KTerm>, +ts: List<&2,KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{t, rest}: p98_tag_eq(j_strip(t), "Var") && p88_string_eq(j_component_origin(env, ix(j_strip(t))), "@child") && j_instance_child_fields(env, rest)

# Primitive fences come from the complete successful source graph, before IR
# folding or private capture rewriting can remove operation provenance. Original
# contextual source bodies are scanned too; erased/type references may overfence.
# Every child/branch is visited once under one aggregate budget. Uncertainty keeps
# the historical all-family fence; native, source and host guards are unchanged.

# Module: src/back/js/jpure.bend:1475
@unsafe
def j_instance_primitive_capabilities(+rows: List<&2,KDef>, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure) && Bool.not(List.is_empty(&2,KDef, j_pure_defs(pure))), u =>
    j_instance_primitive_cap_result(j_instance_primitive_cap_scan(
      List.append(&2,KTerm, j_instance_primitive_cap_sources(rows), j_instance_primitive_cap_bodies(j_pure_defs(pure))),
      Nil{}, 131072)), u => j_instance_primitive_guards())

# Module: src/back/js/jpure.bend:1482
@unsafe
def j_instance_primitive_cap_sources(+rows: List<&2,KDef>) -> List<&2,KTerm>:
  match rows:
    case Nil{}: Nil{}
    case Con{fact, rest}: Con{dv(j_instance_original(fact)), j_instance_primitive_cap_sources(rest)}

# Module: src/back/js/jpure.bend:1488
@unsafe
def j_instance_primitive_cap_bodies(+defs: List<&2,KDef>) -> List<&2,KTerm>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{dv(d), j_instance_primitive_cap_bodies(rest)}

# Module: src/back/js/jpure.bend:1494
@unsafe
def j_instance_primitive_cap_scan(+todo: List<&2,KTerm>, +names: List<&2,String>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match todo:
    case Nil{}: Some{List.reverse(&2,String, names)}
    case Con{t, rest}:
      kc(Maybe<&2,List<&2,String>>, U32.is_gt(fuel, 0), u =>
        j_instance_primitive_cap_scan(List.append(&2,KTerm, ks(t), rest),
          kc(List<&2,String>, j_primitive_known(nm(t)) && Bool.not(has_name(names, nm(t))),
            u => Con{nm(t), names}, u => names), U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:1504
@unsafe
def j_instance_primitive_cap_result(+r: Maybe<&2,List<&2,String>>) -> String:
  match r:
    case None{}: j_instance_primitive_guards()
    case Some{names}: j_instance_primitive_cap_print(names)

# Module: src/back/js/jpure.bend:1510
@unsafe
def j_instance_primitive_cap_print(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name, rest}: j_quote(name) ++ "," ++ j_instance_primitive_cap_print(rest)

# Unit stays an internal nullary tagged value. This exact native owner proof
# neither widens scalar public roots nor admits arbitrary Map payload ADTs.

# Module: src/back/js/jpure.bend:1518
@unsafe
def j_pure_unit_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_string_owner(book, wnf(book, ty), "Unit", 1), u =>
    j_pure_unit_constructor(book, lookup(dc(lookup(book, "Unit")), "Unit")), u => False{})

# Module: src/back/js/jpure.bend:1523
@unsafe
def j_pure_unit_constructor(+book: List<&2,KDef>, +c: KDef) -> Bool:
  j_pure_native_ctor(c, "Unit", 0) && j_string_owner(book, wnf(book, dt(c)), "Unit", 1)

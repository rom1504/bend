# Compile an already proved instance graph. This is not an admission proof:
# callers retain the complete JPure graph, exact instance facts and host guards.
@unsafe
def jw_functions(+book: List<&2,KDef>, +defs: List<&2,KDef>, +todo: List<&2,KDef>) -> List<&2,JWFunction>:
  match todo:
    case Nil{}: Nil{}
    case Con{d, rest}:
      +body = jw_prefix(book, defs, Nil{}, dv(d), dt(d), jw_slots(0, da(d)), da(d), 0)
      Con{JWFunction{dn(d), da(d), jw_code(body), jw_valid(body)}, jw_functions(book, defs, rest)}

@unsafe
def jw_slots(+at: U32, +total: U32) -> List<&2,JWValue>:
  kc(List<&2,JWValue>, U32.is_eq(at, total), u => Nil{}, u => Con{JWSlot{at}, jw_slots(U32.inc(at), total)})

@unsafe
def jw_types(+env: List<&2,JWBinding>) -> List<&2,KTerm>:
  match env:
    case Nil{}: Nil{}
    case Con{JWBinding{id, value, typ}, rest}: Con{kt("Env", "", id, 0, [typ]), jw_types(rest)}

@unsafe
def jw_lookup(+env: List<&2,JWBinding>, +id: U32, +next: U32) -> JWLower:
  match env:
    case Nil{}: jw_fail()
    case Con{JWBinding{key, value, typ}, rest}:
      kc(JWLower, U32.is_eq(id, key), u => JWLower{Nil{}, value, next, True{}}, u => jw_lookup(rest, id, next))

@unsafe
def jw_target(+defs: List<&2,KDef>, +name: String, +at: U32) -> U32:
  match defs:
    case Nil{}: 4294967295
    case Con{d, rest}: kc(U32, String.eq(dn(d), name), u => at, u => jw_target(rest, name, U32.inc(at)))

# Supplied values are already fully demanded. Prefixes contain only binders and
# exhaustive typed matches by JPure; there is no computed initializer to hoist.
@unsafe
def jw_prefix(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +t: KTerm, +ty: KTerm,
  +args: List<&2,JWValue>, +next: U32, +depth: U32) -> JWLower:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JWLower, U32.is_lt(depth, 128), u =>
    kc(JWLower, String.eq(tg(body), "Efq"), u => JWLower{[JWImpossible{}], JWLiteral{"null"}, next, True{}}, u =>
      jw_prefix_args(book, defs, env, body, head, args, next, U32.inc(depth))), u => jw_fail())

@unsafe
def jw_prefix_args(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +body: KTerm, +ty: KTerm,
  +args: List<&2,JWValue>, +next: U32, +depth: U32) -> JWLower:
  match args:
    case Nil{}:
      +r = jw_expr(book, defs, env, body, ty, next, depth)
      JWLower{List.append(&2,JWInstruction, jw_code(r), [JWReturn{jw_value(r)}]), jw_value(r), jw_next(r), jw_valid(r)}
    case Con{arg, rest}:
      kc(JWLower, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)), u =>
        kc(JWLower, String.eq(tg(body), "Lam") && String.eq(j_l_name(body), ""), u =>
          jw_prefix(book, defs, Con{JWBinding{ix(body), arg, kid(ty, 0)}, env}, kid(body, 0),
            subst(kid(ty, 1), ix(ty), var(nm(body), ix(body))), rest, next, depth), u =>
          jw_match(book, defs, env, body, ty, arg, rest, next, depth)), u => jw_fail())

@unsafe
def jw_layout(+book: List<&2,KDef>, +ty: KTerm) -> String:
  kc(String, j_primitive_type(book, ty, "Bool"), u => "bool", u =>
  kc(String, j_primitive_type(book, ty, "Nat"), u => "nat", u =>
  kc(String, j_string_string(book, ty), u => "string", u =>
  kc(String, j_string_char_type(book, ty), u => "char", u =>
  kc(String, j_pure_closed_sigma(book, ty), u => "tuple", u =>
    kc(String, String.eq(tg(ty), "ADT") && Bool.not(j_primitive_type(book, ty, "U32") || j_primitive_type(book, ty, "F32")) &&
      j_pure_type(book, ty), u => "tagged", u => ""))))))

@unsafe
def jw_match(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +t: KTerm, +ty: KTerm,
  +arg: JWValue, +rest: List<&2,JWValue>, +next: U32, +depth: U32) -> JWLower:
  +input = wnf(book, kid(ty, 0))
  +layout = jw_layout(book, input)
  +c = lookup(dc(lookup(book, nm(input))), nm(t))
  kc(JWLower, String.eq(tg(t), "Mat") && String.eq(j_l_name(t), "") && String.eq(dk(c), "Ctr") &&
    Bool.not(String.eq(layout, "")), u =>
    jw_match_fields(book, defs, env, t, ty, layout, arg, rest, next, depth, jw_fields(layout, arg, 0, da(c), next)), u => jw_fail())

@unsafe
def jw_fields(+layout: String, +arg: JWValue, +at: U32, +total: U32, +next: U32) -> JWArgs:
  kc(JWArgs, U32.is_eq(at, total), u => JWArgs{Nil{}, Nil{}, next, True{}}, u =>
    jw_args_join(jw_store(Nil{}, JWProject{layout, arg, at}, next, True{}), jw_fields(layout, arg, U32.inc(at), total, U32.inc(next))))

@unsafe
def jw_match_fields(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +t: KTerm, +ty: KTerm,
  +layout: String, +arg: JWValue, +rest: List<&2,JWValue>, +next: U32, +depth: U32, +fields: JWArgs) -> JWLower:
  match fields:
    case JWArgs{code, values, after, valid}:
      jw_match_done(layout, nm(t), arg,
        jw_binding_join(JWLower{code, JWLiteral{"null"}, after, valid},
          jw_prefix(book, defs, env, kid(t, 0), j_arm_type(book, ty, nm(t)), List.append(&2,JWValue, values, rest), after, depth)),
        jw_prefix(book, defs, env, kid(t, 1), ty, Con{arg, rest}, next, depth))

@unsafe
def jw_match_done(+layout: String, +name: String, +arg: JWValue, +yes: JWLower, +no: JWLower) -> JWLower:
  JWLower{[JWCase{layout, name, arg, jw_code(yes), jw_code(no)}], JWLiteral{"null"},
    U32.max(jw_next(yes), jw_next(no)), jw_valid(yes) && jw_valid(no)}

# Every nontrivial expression result gets a stable register. Later calls cannot
# duplicate or reorder its computation, and parallel-let RHS scopes stay outer.
@unsafe
def jw_expr(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +t: KTerm, +ty: KTerm,
  +next: U32, +depth: U32) -> JWLower:
  +body = j_strip(t)
  kc(JWLower, U32.is_lt(depth, 128), u =>
  kc(JWLower, String.eq(tg(body), "Var"), u => jw_lookup(env, ix(body), next), u =>
  kc(JWLower, core_literal(body), u =>
    kc(JWLower, j_literal_owner(book, wnf(book, ty)), u => JWLower{Nil{}, jw_literal(book, body), next, True{}}, u => jw_fail()), u =>
  kc(JWLower, String.eq(tg(body), "Ref") && Bool.not(String.starts_with(nm(body), "$instance.")) && j_string_literal(book, lookup(book, nm(body))), u =>
    jw_store(Nil{}, JWGlobal{nm(body), jw_layout(book, wnf(book, dt(lookup(book, nm(body)))))}, next, True{}), u =>
  kc(JWLower, String.eq(tg(body), "Ref") && String.starts_with(nm(body), "$instance.") &&
    String.eq(dk(lookup(defs, nm(body))), "Def") && U32.is_eq(da(lookup(defs, nm(body))), 0),
    u => jw_call(book, defs, env, kt("Call", nm(body), 0, 0, Nil{}), next, U32.inc(depth)), u =>
  kc(JWLower, String.eq(tg(body), "Let"), u =>
    jw_bindings(book, defs, env, env, ks(body), ty, next, U32.inc(depth)), u =>
  kc(JWLower, String.eq(tg(body), "Ctr"), u =>
    jw_construct(book, defs, env, body, wnf(book, ty), next, U32.inc(depth)), u =>
  kc(JWLower, String.eq(tg(body), "App"), u =>
    jw_call(book, defs, env, j_call_spine(body, Nil{}), next, U32.inc(depth)), u => jw_fail()))))))), u => jw_fail())

# Both parsers bound compact Nat literal payloads to U32. Larger runtime Nats
# remain computations, so the typed leaf neither parses text nor narrows them.
@unsafe
def jw_literal(+book: List<&2,KDef>, +t: KTerm) -> JWValue:
  kc(JWValue, core_nat(t), u => JWNat{kl_number(t)}, u => JWLiteral{jir_emit(book, jir_lower_literal(t))})

@unsafe
def jw_store(+code: List<&2,JWInstruction>, +value: JWValue, +next: U32, +valid: Bool) -> JWLower:
  JWLower{List.append(&2,JWInstruction, code, [JWAssign{next, value}]), JWSlot{next}, U32.inc(next), valid}

@unsafe
def jw_construct(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +t: KTerm, +ty: KTerm,
  +next: U32, +depth: U32) -> JWLower:
  +c = lookup(dc(lookup(book, nm(ty))), nm(t))
  jw_construct_done(jw_layout(book, ty), nm(t), jw_args(book, defs, env, ks(t), j_specialize(book, dt(c), ks(ty)), next, depth))

@unsafe
def jw_construct_done(+layout: String, +name: String, +r: JWArgs) -> JWLower:
  match r:
    case JWArgs{code, values, next, valid}: jw_store(code, JWConstruct{layout, name, values}, next, valid)

# Private tagged fields cannot enter an ordinary native ABI. The only tagged
# native result admitted here is exact Cmp: every constructor is nullary and its
# public .$ tag is compatible. Nat.divmod retains its native scalar pair.
# Keep this fence even if the broader JPure native whitelist is later extended.
@unsafe
def jw_native_boundary(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u =>
    jw_native_scalar(book, head) || j_map_cmp_type(book, head) || j_map_native_divmod_result(book, head), u =>
    String.eq(tg(head), "All") && jw_native_scalar(book, wnf(book, kid(head, 0))) &&
      jw_native_boundary(book, kid(head, 1), U32.sub(left, 1)))

@unsafe
def jw_native_scalar(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_region_scalar(book, ty) || j_string_string(book, ty) || j_string_char_type(book, ty)

@unsafe
def jw_call(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +spine: KTerm,
  +next: U32, +depth: U32) -> JWLower:
  +d = lookup(book, nm(spine))
  kc(JWLower, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    jw_call_done(nm(spine), jw_target(defs, nm(spine), 0), j_primitive_call(book, spine),
      db(d) && jw_native_boundary(book, dt(d), da(d)),
      jw_args(book, defs, env, ks(spine), dt(d), next, depth)), u => jw_fail())

@unsafe
def jw_call_done(+name: String, +target: U32, +primitive: Bool, +native: Bool, +r: JWArgs) -> JWLower:
  match r:
    case JWArgs{code, values, next, valid}:
      kc(JWLower, primitive, u => jw_store(code, JWPrimitive{name, values}, next, valid), u =>
      kc(JWLower, Bool.not(U32.is_eq(target, 4294967295)), u =>
        JWLower{List.append(&2,JWInstruction, code, [JWDirectCall{next, target, values}]), JWSlot{next}, U32.inc(next), valid}, u =>
        kc(JWLower, native, u => jw_store(code, JWNative{name, values}, next, valid), u => jw_fail())))

@unsafe
def jw_args(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +args: List<&2,KTerm>, +ty: KTerm,
  +next: U32, +depth: U32) -> JWArgs:
  match args:
    case Nil{}: JWArgs{Nil{}, Nil{}, next, True{}}
    case Con{arg, rest}:
      +head = wnf(book, ty)
      jw_args_next(book, defs, env, rest, j_app_type(head, arg), depth,
        jw_expr(book, defs, env, arg, kid(head, 0), next, depth))

@unsafe
def jw_args_next(+book: List<&2,KDef>, +defs: List<&2,KDef>, +env: List<&2,JWBinding>, +rest: List<&2,KTerm>, +ty: KTerm,
  +depth: U32, +first: JWLower) -> JWArgs:
  kc(JWArgs, jw_valid(first), u => jw_args_join(first, jw_args(book, defs, env, rest, ty, jw_next(first), depth)),
    u => JWArgs{Nil{}, Nil{}, 0, False{}})

@unsafe
def jw_args_join(+first: JWLower, +rest: JWArgs) -> JWArgs:
  match rest:
    case JWArgs{code, values, next, valid}:
      JWArgs{List.append(&2,JWInstruction, jw_code(first), code), Con{jw_value(first), values}, next, valid}

@unsafe
def jw_bindings(+book: List<&2,KDef>, +defs: List<&2,KDef>, +outer: List<&2,JWBinding>, +bodyEnv: List<&2,JWBinding>,
  +xs: List<&2,KTerm>, +ty: KTerm, +next: U32, +depth: U32) -> JWLower:
  match xs:
    case Nil{}: jw_fail()
    case Con{body, Nil{}}: jw_expr(book, defs, bodyEnv, body, ty, next, depth)
    case Con{binding, rest}:
      +bindingType = j_region_type(book, jw_types(outer), kid(binding, 0))
      jw_binding_next(book, defs, outer, bodyEnv, binding, rest, bindingType, ty, depth,
        jw_expr(book, defs, outer, kid(binding, 0), bindingType, next, depth))

@unsafe
def jw_binding_next(+book: List<&2,KDef>, +defs: List<&2,KDef>, +outer: List<&2,JWBinding>, +bodyEnv: List<&2,JWBinding>,
  +binding: KTerm, +rest: List<&2,KTerm>, +bindingType: KTerm, +ty: KTerm, +depth: U32, +first: JWLower) -> JWLower:
  kc(JWLower, jw_valid(first), u => jw_binding_join(first,
    jw_bindings(book, defs, outer, Con{JWBinding{ix(binding), jw_value(first), bindingType}, bodyEnv}, rest, ty, jw_next(first), depth)), u => jw_fail())

@unsafe
def jw_binding_join(+first: JWLower, +rest: JWLower) -> JWLower:
  JWLower{List.append(&2,JWInstruction, jw_code(first), jw_code(rest)), jw_value(rest), jw_next(rest), jw_valid(rest)}

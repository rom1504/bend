
# Module: src/back/js/ir/lower.bend:4
@unsafe
def jir_lower(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> JIRExpr:
  kc(JIRExpr, (p98_tag_eq(t, "Lam") || p98_tag_eq(t, "Mat")) && Bool.not(p88_string_eq(j_l_name(t), "")),
    u => JIRLegacy{env, t, ty, tail}, u => jir_lower_node(book, env, t, ty, tail, tg(t)))

# Module: src/back/js/ir/lower.bend:9
@unsafe
def jir_lower_node(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +tag: String) -> JIRExpr:
  kc(JIRExpr, p88_string_eq(tag, "Var"), u => JIRLocal{ix(t)}, u =>
  kc(JIRExpr, p88_string_eq(tag, "Ref"), u => JIRGlobal{nm(t)}, u =>
  kc(JIRExpr, p88_string_eq(tag, "Ann"), u => jir_lower(book, env, kid(t, 0), kid(t, 1), tail), u =>
  kc(JIRExpr, p88_string_eq(tag, "Rwt"), u => jir_lower(book, env, kid(t, 2), ty, tail), u =>
  kc(JIRExpr, p88_string_eq(tag, "App"), u => jir_lower_apply(book, env, t, ty, tail, j_call_spine(t, Nil{})), u =>
  kc(JIRExpr, p88_string_eq(tag, "Let"), u => jir_lower_let(book, env, ks(t), ty, tail), u =>
  kc(JIRExpr, p88_string_eq(tag, "Lam"), u => jir_lower_lambdas(book, env, t, wnf(book, ty), Nil{}), u =>
  kc(JIRExpr, p88_string_eq(tag, "Mat"), u => jir_lower_match(book, env, t, wnf(book, ty)), u =>
  kc(JIRExpr, p88_string_eq(tag, "Ctr") || core_literal(t), u => jir_lower_constructor(book, env, t, ty, tail),
    u => JIRLegacy{env, t, ty, tail})))))))))

# Primitive and choice lowering retain their existing provenance proofs. The
# residual application is structural IR even when an inherited private-call
# plan surrounds it. A source name alone does not authorize direct execution.

# Module: src/back/js/ir/lower.bend:25
@unsafe
def jir_lower_apply(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +spine: KTerm) -> JIRExpr:
  kc(JIRExpr, j_primitive_call(book, spine), u => jir_lower_primitive(book, env, spine), u =>
  kc(JIRExpr, j_choice_call(book, spine), u => jir_lower_choice(book, env, spine, tail), u =>
    jir_lower_call_plan(env, spine, jir_lower_apply_generic(book, env, t, tail,
      wnf(book, j_type(book, env, kid(t, 0))), spine))))

# Module: src/back/js/ir/lower.bend:32
@unsafe
def jir_lower_call_plan(+env: List<&2,KTerm>, +spine: KTerm, +fallback: JIRExpr) -> JIRExpr:
  kc(JIRExpr, p98_tag_eq(spine, "Call"),
    u => JIRCallPlan{env, spine, fallback}, u => fallback)

# Only the proven leading-lambda prefix may collect arguments. A matcher or
# intermediate computation completes before arguments in the next chunk run.

# Module: src/back/js/ir/lower.bend:39
@unsafe
def jir_lower_apply_generic(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +tail: Bool, +fty: KTerm, +spine: KTerm) -> JIRExpr:
  kc(JIRExpr, p98_tag_eq(spine, "Call") && U32.is_gt(terms_len(ks(spine)), 1) &&
    U32.is_le(terms_len(ks(spine)), j_call_arity(lookup(book, nm(spine)))),
    u => JIRApply{JIRGlobal{nm(spine)}, jir_lower_args(book, env, ks(spine), dt(lookup(book, nm(spine)))), tail},
    u => JIRApply{jir_lower(book, env, kid(t, 0), fty, False{}),
      [jir_lower_argument(book, env, kid(t, 1), fty, False{})], tail})

# Module: src/back/js/ir/lower.bend:47
@unsafe
def jir_lower_argument(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> JIRExpr:
  kc(JIRExpr, p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 0),
    u => JIRNull{}, u => jir_lower(book, env, t, kid(ty, 0), tail))

# Module: src/back/js/ir/lower.bend:52
@unsafe
def jir_lower_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm) -> List<&2,JIRExpr>:
  match args:
    case Nil{}: Nil{}
    case Con{arg, rest}:
      +head = wnf(book, ty)
      Con{jir_lower_argument(book, env, arg, head, False{}),
        jir_lower_args(book, env, rest, j_app_type(head, arg))}

# All right-hand sides use the outer scope. The introduced scope exists only
# for the body, including source fixtures that deliberately reuse binder IDs.

# Module: src/back/js/ir/lower.bend:63
@unsafe
def jir_lower_let(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +tail: Bool) -> JIRExpr:
  JIRLet{jir_lower_bindings(xs), jir_lower_values(book, env, xs),
    jir_lower(book, j_context(book, env, xs), j_body(xs), ty, tail)}

# Module: src/back/js/ir/lower.bend:68
@unsafe
def jir_lower_bindings(+xs: List<&2,KTerm>) -> List<&2,JIRParam>:
  match xs:
    case Nil{}: Nil{}
    case Con{last, Nil{}}: Nil{}
    case Con{binding, rest}: Con{JIRParam{ix(binding), U32.is_eq(qt(binding), 0)}, jir_lower_bindings(rest)}

# Module: src/back/js/ir/lower.bend:75
@unsafe
def jir_lower_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>) -> List<&2,JIRExpr>:
  match xs:
    case Nil{}: Nil{}
    case Con{last, Nil{}}: Nil{}
    case Con{binding, rest}:
      Con{kc(JIRExpr, U32.is_eq(qt(binding), 0), u => JIRNull{},
        u => jir_lower(book, env, kid(binding, 0), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{})),
        jir_lower_values(book, env, rest)}

# Public descriptors retain erased null ABI slots and the same leading arity.
# Every grouped parameter gets its own immutable lexical binding.

# Module: src/back/js/ir/lower.bend:87
@unsafe
def jir_lower_lambdas(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +params: List<&2,JIRParam>) -> JIRExpr:
  kc(JIRExpr, p98_tag_eq(t, "Ann"), u => jir_lower_lambdas(book, env, kid(t, 0), kid(t, 1), params), u =>
  kc(JIRExpr, p98_tag_eq(t, "Lam"), u => jir_lower_lambda_bind(book, env, t, wnf(book, ty), params),
    u => JIRLambda{List.reverse(&2,JIRParam, params), jir_lower(book, env, t, ty, True{})}))

# Module: src/back/js/ir/lower.bend:93
@unsafe
def jir_lower_lambda_bind(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +params: List<&2,JIRParam>) -> JIRExpr:
  jir_lower_lambdas(book, Con{kt("Env", "", ix(t), 0, [kid(ty, 0)]), env}, kid(t, 0),
    subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))),
    Con{JIRParam{ix(t), p98_tag_eq(ty, "All") && U32.is_eq(qt(ty), 0)}, params})

# Match arms remain delayed values. A one-constructor matcher never evaluates
# or emits its unreachable fallback, matching the established runtime boundary.

# Module: src/back/js/ir/lower.bend:101
@unsafe
def jir_lower_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> JIRExpr:
  +single = U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1)
  JIRMatch{nm(t), single, jir_lower(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), False{}),
    kc(JIRExpr, single, u => JIRNull{}, u => jir_lower(book, env, kid(t, 1), ty, False{}))}

# Private layout selection remains its existing proof-owned adapter. Ordinary
# construction and compact literals instead expose their complete operands to
# passes. Literal provenance is checked before representing a primitive value:
# user constructors with primitive names must keep their public tagged layout.

# Module: src/back/js/ir/lower.bend:111
@unsafe
def jir_lower_constructor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> JIRExpr:
  kc(JIRExpr, has_name(rm(t), "$private.owned.ctor"), u => JIRLegacy{env, t, ty, tail}, u =>
  kc(JIRExpr, core_literal(t), u =>
    kc(JIRExpr, j_literal_owner(book, wnf(book, ty)), u => jir_lower_literal(t),
      u => jir_lower_constructor_fields(book, env, t, ty, tail)), u =>
    jir_lower_constructor_literal(book, env, t, ty, tail, j_literal_typed(book, t, ty))))

# Module: src/back/js/ir/lower.bend:119
@unsafe
def jir_lower_constructor_literal(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool, +literal: String) -> JIRExpr:
  kc(JIRExpr, p88_string_eq(literal, ""),
    u => jir_lower_constructor_fields(book, env, t, ty, tail), u => JIRLegacy{env, t, ty, tail})

# Module: src/back/js/ir/lower.bend:124
@unsafe
def jir_lower_constructor_fields(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: Bool) -> JIRExpr:
  JIRConstruct{nm(t), jir_lower_fields(book, env, ks(t),
    j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))), tail), tail}

# Module: src/back/js/ir/lower.bend:129
@unsafe
def jir_lower_literal(+t: KTerm) -> JIRExpr:
  kc(JIRExpr, core_nat(t), u => JIRNat{kl_number(t)}, u =>
  kc(JIRExpr, p88_string_eq(nm(t), "String"), u => JIRString{kl_text(t)},
    u => JIRWord{kl_number(t), p88_string_eq(nm(t), "F32")}))

# Unlike function-spine analysis, constructor telescope traversal does not
# normalize an additional type at every field. It preserves the exact existing
# specialized telescope and never lowers an erased source expression.

# Module: src/back/js/ir/lower.bend:138
@unsafe
def jir_lower_fields(+book: List<&2,KDef>, +env: List<&2,KTerm>, +fields: List<&2,KTerm>, +tel: KTerm, +tail: Bool) -> List<&2,JIRExpr>:
  match fields:
    case Nil{}: Nil{}
    case Con{field, rest}:
      Con{jir_lower_argument(book, env, field, tel, tail),
        jir_lower_fields(book, env, rest, j_app_type(tel, field), tail)}

# Operation selection is separate from printing: the caller has established
# exact native definition identity, saturation and the complete live telescope.
# Literal shifts retain the prior no-coercion rule for counts above 31.

# Module: src/back/js/ir/lower.bend:149
@unsafe
def jir_lower_primitive(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm) -> JIRExpr:
  +name = nm(spine)
  +a = jir_lower(book, env, kid(spine, 0), kt("ADT", j_primitive_input(name, 0), 0, 0, Nil{}), False{})
  +count = j_strip(kid(spine, 1))
  kc(JIRExpr, (p88_string_eq(name, "U32.shln") || p88_string_eq(name, "U32.shrn")) && core_nat(count),
    u => JIRShift{name, a, kl_number(count)},
    u => JIRPrimitive{name, a, kc(JIRExpr, U32.is_eq(j_primitive_arity(name), 2),
      u => jir_lower(book, env, kid(spine, 1), kt("ADT", j_primitive_input(name, 1), 0, 0, Nil{}), False{}),
      u => JIRNull{})})

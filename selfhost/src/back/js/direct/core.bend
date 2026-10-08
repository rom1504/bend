# General direct lowering of checked, annotated KTerm. Named functions take
# live positional arguments; first-class functions are native unary closures.
@unsafe
def jd_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  jd_expr_node(book, env, t, ty, tg(t))

@unsafe
def jd_expr_node(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tag: String) -> String:
  kc(String, String.eq(tag, "Ann"), u => jd_expr(book, env, kid(t, 0), kid(t, 1)), u =>
  kc(String, String.eq(tag, "Rwt"), u => jd_expr(book, env, kid(t, 2), ty), u =>
  kc(String, String.eq(tag, "Var"), u => jd_var(env, ix(t)), u =>
  kc(String, String.eq(tag, "Ref") || String.eq(tag, "App"),
    u => jd_application(book, env, t, False{}, j_call_spine(t, Nil{})), u =>
  kc(String, String.eq(tag, "Ctr") || core_literal(t), u => jd_ctor(book, env, t, ty), u =>
  kc(String, String.eq(tag, "Lam") || String.eq(tag, "Mat") || String.eq(tag, "Efq"),
    u => jd_closure(book, jd_without_owner(env), t, wnf(book, ty)), u =>
  kc(String, String.eq(tag, "Let"),
    u => "(()=>{" ++ jd_body(book, jd_expression_env(env), t, ty, Nil{}) ++ "})()", u =>
  kc(String, String.eq(tag, "Typ") || String.eq(tag, "ADT") || String.eq(tag, "All") || String.eq(tag, "Qua") || String.eq(tag, "Min") || String.eq(tag, "Rfl"),
    u => "null", u => jd_fail("unsupported direct expression: " ++ tag)))))))))

# An erased lambda is absent at runtime, including when it is the only prefix.
@unsafe
def jd_closure(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, String.eq(tg(t), "Lam") && String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 0),
    u => "(()=>{" ++ jd_body(book, jd_expression_env(env), t, ty, Nil{}) ++ "})()", u =>
    "jd_clo(($arg)=>{" ++ jd_body(book, env, t, ty, ["$arg"]) ++ "})")

@unsafe
def jd_application(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +tail: Bool, +spine: KTerm) -> String:
  kc(String, jd_choice_call(book, spine), u => jd_choice_expr(book, env, ks(spine)), u =>
  kc(String, String.eq(tg(spine), "Call"), u =>
    jd_named(book, env, lookup(book, nm(spine)), ks(spine), tail), u =>
    jd_unknown(book, env, t, tail, wnf(book, j_type(book, env, kid(t, 0))))))

@unsafe
def jd_unknown(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +tail: Bool, +ty: KTerm) -> String:
  kc(String, String.eq(tg(t), "App") && String.eq(tg(ty), "All"), u =>
    kc(String, U32.is_eq(qt(ty), 0), u => jd_expr(book, env, kid(t, 0), ty), u =>
      kc(String, tail, u => "run_tail(" ++ jd_expr(book, env, kid(t, 0), ty) ++ "," ++
          jd_expr(book, env, kid(t, 1), kid(ty, 0)) ++ ")",
        u => "(" ++ jd_expr(book, env, kid(t, 0), ty) ++ ")(" ++ jd_expr(book, env, kid(t, 1), kid(ty, 0)) ++ ")")),
    u => jd_fail("unknown application lacks its checked function type"))

@unsafe
def jd_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +tail: Bool) -> String:
  kc(String, String.eq(dk(d), "ADT"), u => "null", u =>
  kc(String, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    (Bool.not(String.eq(tg(dv(d)), "Absent")) || jd_native_known(book, d)), u =>
    jd_named_args(book, env, d, tail, jd_arguments(book, env, xs, dt(d), jd_emitted_arity(book, d))),
    u => jd_fail("unknown direct definition: " ++ name_key(dn(d)))))

@unsafe
def jd_arguments(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32) -> JDArgs:
  kc(JDArgs, U32.is_eq(left, 0), u => JDArgs{Nil{}, xs, ty, 0},
    u => jd_arguments_more(book, env, xs, wnf(book, ty), left))

@unsafe
def jd_arguments_more(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32) -> JDArgs:
  match xs:
    case Nil{}: JDArgs{Nil{}, Nil{}, ty, left}
    case Con{x, rest}:
      jd_arguments_join(kc(String, U32.is_eq(qt(ty), 0), u => "", u => jd_expr(book, env, x, kid(ty, 0))),
        jd_arguments(book, env, rest, j_app_type(ty, x), U32.sub(left, 1)))

@unsafe
def jd_arguments_join(+value: String, +r: JDArgs) -> JDArgs:
  match r:
    case JDArgs{values, rest, ty, missing}:
      JDArgs{kc(List<&2,String>, String.eq(value, ""), u => values, u => Con{value, values}), rest, ty, missing}

@unsafe
def jd_named_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +d: KDef, +tail: Bool, +r: JDArgs) -> String:
  match r:
    case JDArgs{values, rest, ty, missing}:
      kc(String, U32.is_eq(missing, 0), u =>
        kc(String, List.is_empty(&2,KTerm, rest), u => jd_call(book, jd_owner(env), dn(d), values, tail),
          u => jd_over(book, env, jd_call(book, jd_owner(env), dn(d), values, False{}), rest, ty, tail)),
        u => jd_eta(book, jd_owner(env), dn(d), values, ty, missing, terms_len(env), tail))

# As in upstream call_eta, a missing named formal eta-expands the source call;
# already supplied expressions remain in the eventual body, not an eager bind.
@unsafe
def jd_eta(+book: List<&2,KDef>, +owner: String, +name: String, +values: List<&2,String>, +ty: KTerm, +left: U32, +at: U32, +tail: Bool) -> String:
  kc(String, U32.is_eq(left, 0), u => jd_call(book, owner, name, values, tail),
    u => jd_eta_head(book, owner, name, values, wnf(book, ty), left, at, tail))

@unsafe
def jd_eta_head(+book: List<&2,KDef>, +owner: String, +name: String, +values: List<&2,String>, +ty: KTerm, +left: U32, +at: U32, +tail: Bool) -> String:
  kc(String, String.eq(tg(ty), "All"), u =>
    kc(String, U32.is_eq(qt(ty), 0),
      u => jd_eta(book, owner, name, values, j_app_type(ty, atom("Absent")), U32.sub(left, 1), at, tail),
      u => "jd_clo(($eta" ++ U32.show(at) ++ ")=>{" ++ "return " ++
        jd_eta(book, "", name, List.append(&2,String, values, ["$eta" ++ U32.show(at)]),
          kid(ty, 1), U32.sub(left, 1), U32.inc(at), True{}) ++ ";})"),
    u => jd_fail("partial direct call lacks telescope"))

@unsafe
def jd_call(+book: List<&2,KDef>, +owner: String, +name: String, +values: List<&2,String>, +tail: Bool) -> String:
  kc(String, jd_inline_atoms(values),
    u => jd_call_inline(book, owner, name, values, tail, jd_intrinsic(book, name, values)),
    u => jd_call_plain(book, owner, name, values, tail))

@unsafe
def jd_call_inline(+book: List<&2,KDef>, +owner: String, +name: String, +values: List<&2,String>, +tail: Bool, +code: String) -> String:
  kc(String, String.eq(code, ""), u => jd_call_plain(book, owner, name, values, tail),
    u => "(" ++ code ++ ")")

@unsafe
def jd_call_plain(+book: List<&2,KDef>, +owner: String, +name: String, +values: List<&2,String>, +tail: Bool) -> String:
  "(" ++ jd_ref(name) ++ kc(String, Bool.not(tail) && jd_may_bounce(book, name),
      u => "jd_run(" ++ jd_name(name) ++ "(" ++ jd_join(values) ++ "))",
      u => jd_name(name) ++ "(" ++ jd_join(values) ++ ")") ++ ")"

# A bounded experimental classifier for exact emitter-owned operand forms.
# Views, projections, calls, globals and compound expressions remain calls.
# Keep the original strings: their JD_USE metadata still controls local demand.
@unsafe
def jd_inline_atoms(+values: List<&2,String>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{x, rest}: kc(Bool, jd_inline_atom(x), u => jd_inline_atoms(rest), u => False{})

@unsafe
def jd_inline_atom(+value: String) -> Bool:
  kc(Bool, String.starts_with(value, "(\n/*JD_USE:"),
    u => jd_inline_marked(String.drop(value, 11n), ""), u =>
  kc(Bool, String.starts_with(value, "$eta"), u => jd_inline_digits(String.drop(value, 4n)), u =>
  kc(Bool, String.starts_with(value, "$a"), u => jd_inline_digits(String.drop(value, 2n)), u =>
    String.eq(value, "true") || String.eq(value, "false") || String.eq(value, "null") || jd_inline_digits(value))))

@unsafe
def jd_inline_marked(+text: String, +id: String) -> Bool:
  match text:
    case SNil{}: False{}
    case SCon{h, rest}:
      kc(Bool, U32.is_ge(Char.to_u32(h), 48) && U32.is_le(Char.to_u32(h), 57),
        u => jd_inline_marked(rest, id ++ SCon{h, SNil{}}),
        u => Bool.not(String.eq(id, "")) && String.eq(text, "*/$x" ++ id ++ ")"))

@unsafe
def jd_inline_digits(+text: String) -> Bool:
  match text:
    case SNil{}: False{}
    case SCon{h, rest}:
      kc(Bool, U32.is_ge(Char.to_u32(h), 48) && U32.is_le(Char.to_u32(h), 57),
        u => kc(Bool, String.eq(rest, ""), v => True{}, v => jd_inline_digits(rest)), u => False{})

@unsafe
def jd_over(+book: List<&2,KDef>, +env: List<&2,KTerm>, +value: String, +xs: List<&2,KTerm>, +ty: KTerm, +tail: Bool) -> String:
  match xs:
    case Nil{}: value
    case Con{x, rest}: jd_over_head(book, env, value, x, rest, wnf(book, ty), tail)

@unsafe
def jd_over_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +value: String, +x: KTerm, +rest: List<&2,KTerm>, +ty: KTerm, +tail: Bool) -> String:
  kc(String, String.eq(tg(ty), "All"), u =>
    kc(String, U32.is_eq(qt(ty), 0), u => jd_over(book, env, value, rest, j_app_type(ty, x), tail), u =>
      kc(String, tail && List.is_empty(&2,KTerm, rest),
        u => "run_tail(" ++ value ++ "," ++ jd_expr(book, env, x, kid(ty, 0)) ++ ")",
        u => jd_over(book, env, "(" ++ value ++ ")(" ++ jd_expr(book, env, x, kid(ty, 0)) ++ ")",
          rest, j_app_type(ty, x), tail))),
    u => jd_fail("overapplication lacks checked function result"))

@unsafe
def jd_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> String:
  jd_text_render(jd_doc_body(book, env, t, ty, args))

@unsafe
def jd_doc_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> JDText:
  kc(JDText, String.eq(tg(t), "Ann"), u => jd_doc_body(book, env, kid(t, 0), kid(t, 1), args), u => kc(JDText, String.eq(tg(t), "Rwt"), u => jd_doc_body(book, env, kid(t, 2), ty, args), u => kc(JDText, String.eq(tg(t), "Efq"), u => jd_text_literal("throw \"bend: runtime fail-stop\";", 32), u => kc(JDText, String.eq(tg(t), "Lam"), u => jd_doc_body_lambda(book, env, t, wnf(book, ty), args), u => kc(JDText, String.eq(tg(t), "Mat"), u => kc(JDText, List.is_empty(&2,String, args), u => jd_text_raw("return " ++ jd_expr(book, env, t, ty) ++ ";"), u => jd_doc_match(book, env, t, wnf(book, ty), args)), u => kc(JDText, String.eq(tg(t), "Let"), u => jd_doc_body_let(book, env, ks(t), ty, args), u => kc(JDText, List.is_empty(&2,String, args), u => jd_doc_return(book, env, t, ty, j_call_spine(t, Nil{})), u => jd_doc_body_apply(book, env, t, ty, args))))))))

@unsafe
def jd_doc_body_lambda(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> JDText:
  kc(JDText, String.eq(tg(ty), "All"), u => kc(JDText, U32.is_eq(qt(ty), 0), u => jd_text_many([jd_text_raw("const " ++ jd_local(ix(t)) ++ "=null;"), jd_doc_body(book, jd_bind_env(env, ix(t), kid(ty, 0)), kid(t, 0), j_app_type(ty, var(nm(t), ix(t))), args)]), u => jd_doc_body_live_lambda(book, env, t, ty, args)), u => jd_text_raw("return " ++ jd_fail("lambda lacks checked function type") ++ ";"))

@unsafe
def jd_doc_body_live_lambda(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> JDText:
  match args:
    case Nil{}: jd_text_raw("return " ++ jd_expr(book, env, t, ty) ++ ";")
    case Con{x, rest}: kc(JDText, jd_is_view(x), u => jd_doc_body(book, Con{jd_view_binding(ix(t), kid(ty, 0), x), env}, kid(t, 0), j_app_type(ty, var(nm(t), ix(t))), rest), u => jd_doc_body_bound(ix(t), x, jd_doc_body(book, jd_bind_env(env, ix(t), kid(ty, 0)), kid(t, 0), j_app_type(ty, var(nm(t), ix(t))), rest)))

@unsafe
def jd_doc_body_bound(+id: U32, +value: String, +body: JDText) -> JDText:
  jd_text_many([jd_text_raw(kc(String, jd_text_used(body, id),
    u => "const " ++ jd_local(id) ++ "=" ++ value ++ ";", u => "")), body])

@unsafe
def jd_doc_body_apply(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> JDText:
  jd_text_raw("return " ++ jd_apply_strings(jd_expr(book, env, t, ty), args, jd_tail_position(env)) ++ ";")

@unsafe
def jd_apply_strings(+value: String, +args: List<&2,String>, +tail: Bool) -> String:
  match args:
    case Nil{}: value
    case Con{x, Nil{}}: kc(String, tail, u => "run_tail(" ++ value ++ "," ++ x ++ ")", u => "(" ++ value ++ ")(" ++ x ++ ")")
    case Con{x, rest}: jd_apply_strings("(" ++ value ++ ")(" ++ x ++ ")", rest, tail)

@unsafe
def jd_doc_body_let(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +args: List<&2,String>) -> JDText:
  jd_doc_body_let_render(book, env, xs, jd_doc_body(book, j_context(book, env, xs), j_body(xs), ty, args))

@unsafe
def jd_doc_body_let_render(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +body: JDText) -> JDText:
  jd_text_many([jd_text_literal("{", 1), jd_doc_let_values(book, env, xs, 0, body), jd_text_literal("{", 1), jd_doc_let_bindings(xs, 0, body), body, jd_text_literal("}}", 2)])

@unsafe
def jd_doc_let_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +at: U32, +body: JDText) -> JDText:
  jd_doc_ordered_lets(book, env, xs, at, body, 0)

@unsafe
def jd_doc_let_bindings(+xs: List<&2,KTerm>, +at: U32, +body: JDText) -> JDText:
  match xs:
    case Nil{}: jd_text_literal("", 0)
    case Con{x, Nil{}}: jd_text_literal("", 0)
    case Con{x, rest}: jd_text_many([jd_text_raw(kc(String, jd_text_used(body, ix(x)), u =>
      "const " ++ jd_local(ix(x)) ++ "=$let" ++ U32.show(at) ++ ";", u => "")), jd_doc_let_bindings(rest, U32.inc(at), body)])

@unsafe
def jd_doc_return(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +spine: KTerm) -> JDText:
  kc(JDText, jd_choice_call(book, spine), u => jd_doc_choice_body(book, env, ks(spine)), u => kc(JDText, String.eq(tg(spine), "Call") && Bool.not(String.eq(jd_owner(env), "")) &&
    jd_same_component(book, nm(spine), jd_owner(env)), u => jd_doc_return_self(book, env, t, ty, spine, jd_argument_shape(book, ks(spine), dt(lookup(book, nm(spine))), jd_emitted_arity(book, lookup(book, nm(spine))))), u => jd_doc_return_regular(book, env, t, ty, spine)))

# Tail-transfer admission consumes only the telescope remainder, never rendered
# argument values. Lower each actual later in the selected ordered emitter.
@unsafe
def jd_argument_shape(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32) -> JDArgs:
  kc(JDArgs, U32.is_eq(left, 0), u => JDArgs{Nil{}, xs, ty, 0},
    u => jd_argument_shape_more(book, xs, wnf(book, ty), left))

@unsafe
def jd_argument_shape_more(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +ty: KTerm, +left: U32) -> JDArgs:
  match xs:
    case Nil{}: JDArgs{Nil{}, Nil{}, ty, left}
    case Con{x, rest}: jd_argument_shape(book, rest, j_app_type(ty, x), U32.sub(left, 1))

@unsafe
def jd_doc_return_self(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +spine: KTerm, +r: JDArgs) -> JDText:
  match r:
    case JDArgs{values, rest, result, missing}: kc(JDText, List.is_empty(&2,KTerm, rest) && U32.is_eq(jd_live_arity(book, result, missing), 0), u => jd_doc_ordered_transfer(book, env, nm(spine), ks(spine)), u => jd_doc_return_regular(book, env, t, ty, spine))

@unsafe
def jd_doc_return_regular(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +spine: KTerm) -> JDText:
  jd_doc_ordered_return(book, env, t, ty)

@unsafe
def jd_doc_transfer_args(+book: List<&2,KDef>, +owner: String, +target: String, +values: List<&2,String>) -> JDText:
  jd_text_many([jd_text_raw("{" ++ jd_ref(target)), jd_doc_self_temps(values, 0), jd_doc_self_stores(values, 0), jd_text_raw(kc(String, String.eq(owner, target), u => "",
      u => "$pc=" ++ U32.show(jd_component_id(book, target)) ++ ";") ++ "continue;}")])

@unsafe
def jd_doc_self_temps(+values: List<&2,String>, +at: U32) -> JDText:
  match values:
    case Nil{}: jd_text_literal("", 0)
    case Con{x, rest}: jd_text_many([jd_text_raw("const $next" ++ U32.show(at) ++ "=" ++ x ++ ";"), jd_doc_self_temps(rest, U32.inc(at))])

@unsafe
def jd_doc_self_stores(+values: List<&2,String>, +at: U32) -> JDText:
  match values:
    case Nil{}: jd_text_literal("", 0)
    case Con{x, rest}: jd_text_many([jd_text_raw("$a" ++ U32.show(at) ++ "=$next" ++ U32.show(at) ++ ";"), jd_doc_self_stores(rest, U32.inc(at))])

@unsafe
def jd_doc_definition(+book: List<&2,KDef>, +d: KDef) -> JDText:
  kc(JDText, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    (Bool.not(String.eq(tg(dv(d)), "Absent")) || jd_native_known(book, d)), u => kc(JDText, String.eq(tg(j_strip(dv(d))), "Foreign"), u => jd_text_raw(jd_foreign_def(book, d)), u => jd_doc_definition_params(book, d, jd_params(book, dt(d), jd_emitted_arity(book, d), 0))), u => jd_text_literal("", 0))

@unsafe
def jd_doc_definition_params(+book: List<&2,KDef>, +d: KDef, +params: List<&2,String>) -> JDText:
  jd_doc_definition_native(book, d, params, jd_primitive_candidate_emit(book, d, params))

@unsafe
def jd_doc_definition_native(+book: List<&2,KDef>, +d: KDef, +params: List<&2,String>, +native: String) -> JDText:
  kc(JDText, String.eq(native, ""), u => jd_doc_definition_loop(book, d, params, jd_component(book, dn(d))), u => jd_text_raw("function " ++ jd_name(dn(d)) ++ "(" ++ jd_join(params) ++ "){return " ++ native ++ ";}\n"))
# A mutual tail component owns one private dispatcher. Named entry wrappers
# retain the existing maximum-width parameter ABI and pass an inert initial PC.
# The leader explicitly retains every member before emitted reach is filtered;
# rebuilding call facts therefore keeps the same complete ordered component.
@unsafe
def jd_doc_definition_loop(+book: List<&2,KDef>, +d: KDef, +params: List<&2,String>, +members: List<&2,String>) -> JDText:
  kc(JDText, U32.is_gt(jd_string_len(members), 1), u => jd_doc_component_definition(book, d, members), u => jd_text_many([jd_text_raw("function " ++ jd_name(dn(d)) ++ "(" ++ jd_join(params) ++ "){for(;;){"), jd_doc_body(book, [kt("$JD.Owner", dn(d), 4294967295, 0, Nil{})], dv(d), dt(d), params), jd_text_literal("}}\n", 3)]))

@unsafe
def jd_doc_component_definition(+book: List<&2,KDef>, +d: KDef, +members: List<&2,String>) -> JDText:
  match members:
    case Nil{}: jd_text_raw(jd_fail("empty direct tail component"))
    case Con{leader, rest}: jd_doc_component_shared(book, d, members, leader, jd_width_params(jd_component_width(book, members), 0))

@unsafe
def jd_doc_component_shared(+book: List<&2,KDef>, +d: KDef, +members: List<&2,String>,
  +leader: String, +params: List<&2,String>) -> JDText:
  jd_text_many([kc(JDText, String.eq(dn(d), leader), u => jd_text_many([jd_text_raw("function " ++ jd_name(leader) ++ "$scc(" ++ jd_join(Con{"$pc", params}) ++ "){"), jd_doc_component_refs(members), jd_text_literal("for(;;)switch($pc){", 19), jd_doc_component_cases(book, members, 0), jd_text_literal("}}\n", 3)]), u => jd_text_literal("", 0)), jd_text_raw("function " ++ jd_name(dn(d)) ++ "(" ++ jd_join(params) ++ "){return (" ++ jd_ref(leader) ++ jd_name(leader) ++ "$scc(" ++ jd_join(Con{U32.show(jd_component_id(book, dn(d))), params}) ++ "));}\n")])

@unsafe
def jd_doc_component_refs(+members: List<&2,String>) -> JDText:
  match members:
    case Nil{}: jd_text_literal("", 0)
    case Con{name, rest}: jd_text_many([jd_text_raw(jd_ref(name)), jd_doc_component_refs(rest)])

@unsafe
def jd_component_width(+book: List<&2,KDef>, +members: List<&2,String>) -> U32:
  match members:
    case Nil{}: 0
    case Con{name, rest}: U32.max(jd_live_arity(book, dt(lookup(book, name)), jd_emitted_arity(book, lookup(book, name))),
      jd_component_width(book, rest))

@unsafe
def jd_doc_component_cases(+book: List<&2,KDef>, +members: List<&2,String>, +at: U32) -> JDText:
  match members:
    case Nil{}: jd_text_literal("", 0)
    case Con{name, rest}: jd_text_many([jd_text_raw("case " ++ U32.show(at) ++ ":{"), jd_doc_component_case(book, lookup(book, name)), jd_text_literal("}", 1), jd_doc_component_cases(book, rest, U32.inc(at))])

@unsafe
def jd_doc_component_case(+book: List<&2,KDef>, +d: KDef) -> JDText:
  jd_doc_body(book, [kt("$JD.Owner", dn(d), 4294967295, 0, Nil{})], dv(d), dt(d), jd_params(book, dt(d), jd_emitted_arity(book, d), 0))

@unsafe
def jd_definitions(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  jd_text_render(jd_doc_definitions(book, defs))

@unsafe
def jd_doc_definitions(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> JDText:
  match defs:
    case Nil{}: jd_text_literal("", 0)
    case Con{d, rest}: jd_text_many([jd_doc_definition(book, d), jd_doc_definitions(book, rest)])

@unsafe
def jd_library_selected(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  jd_library_context(jd_calls_context(jd_selected_context(book, defs), defs), defs)

# Component emission looks up bodies by name. Overlay the annotated selected
# definitions while retaining the original cached context and provenance.
@unsafe
def jd_selected_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  book_put_many(book, defs)

@unsafe
def jd_library_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  kc(String, jd_calls_valid(book), u =>
    "// Direct JavaScript prototype: native functions and live arguments.\n" ++ jd_definitions(book, defs) ++ jd_exports(book, defs),
    u => jd_fail("direct tail-call analysis refused"))

@unsafe
def jd_library(+book: List<&2,KDef>) -> String:
  jd_library_selected(book_context(book), book)

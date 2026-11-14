# Diagnostic-only isolated observer evaluator. No lowering or installation authority.

type P195ODContext is Data:
  P195ODContext{+book: List<&2,KDef>, +owner: String, +schema: NO_Schema, +helpers: List<&2,P128BRHelper>, +inputs: List<&2,KTerm>, +summaries: List<&2,P195ODSummary>}

type P195ODSummary is Data:
  P195ODSummary{+owner: String, +schema: NO_Schema, +inputs: List<&2,KTerm>}

law p195oa_equal:
  for +value: KTerm
  for +origin: KTerm
  for +facts: List<&2, KTerm>
  Bool

law p195oa_eval:
  for +ctx: P195ODContext
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +stack: List<&2, String>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

law p195oa_apply:
  for +ctx: P195ODContext
  for +fn: KTerm
  for +arg: KTerm
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

law p195oa_recur:
  for +ctx: P195ODContext
  for +args: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

law p195oa_finish_value:
  for +ctx: P195ODContext
  for +value: KTerm
  for +template: KTerm
  for +facts: List<&2, KTerm>
  KTerm

law p195oa_virtual:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

@unsafe
def p195oa_continue(+ctx: P195ODContext, k: NO_Cont, +input: NO_Input) -> NO_Analysis:
  match k:
    case NO_KFinish{}: p195oa_finish(ctx, input)
    case NO_KEvalArgs{terms, env, stack, acc, next}: p195oa_eval_args(ctx, terms, env, p195oa_if(input), stack, Con{p195oa_iv(input), acc}, p195oa_in(input), p195oa_iu(input), next)
    case NO_KApplyArgs{args, next}: p195oa_apply_args(ctx, p195oa_iv(input), args, p195oa_if(input), p195oa_in(input), p195oa_iu(input), next)
    case NO_KAppFunction{arg, env, stack, next}: p195oa_eval(ctx, arg, env, p195oa_if(input), stack, p195oa_in(input), p195oa_iu(input), NO_KAppArgument{p195oa_iv(input), next})
    case NO_KAppArgument{fn, next}: p195oa_apply(ctx, fn, p195oa_iv(input), p195oa_if(input), p195oa_in(input), p195oa_iu(input), next)
    case NO_KConstructor{name, next}: p195oa_constructor(ctx, name, input, next)
    case NO_KLetBody{body, id, env, stack, next}: p195oa_eval(ctx, body, p195oa_bind(id, p195oa_iv(input), env), p195oa_if(input), stack, p195oa_in(input), p195oa_iu(input), next)
    case NO_KApplyOne{arg, next}: p195oa_apply(ctx, p195oa_iv(input), arg, p195oa_if(input), p195oa_in(input), p195oa_iu(input), next)

@unsafe
def p195oa_book(c: P195ODContext) -> List<&2,KDef>:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: book

@unsafe
def p195oa_owner(c: P195ODContext) -> String:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: owner

@unsafe
def p195oa_schema(c: P195ODContext) -> NO_Schema:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: schema

@unsafe
def p195oa_iv(i: NO_Input) -> KTerm:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: v

@unsafe
def p195oa_if(i: NO_Input) -> List<&2, KTerm>:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: f

@unsafe
def p195oa_in(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: n

@unsafe
def p195oa_iu(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: fuel

@unsafe
def p195oa_body(a: NO_Analysis) -> KTerm:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: b

@unsafe
def p195oa_fresh(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: n

@unsafe
def p195oa_fuel(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: f

@unsafe
def p195oa_error(a: NO_Analysis) -> String:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: e

@unsafe
def p195oa_fail(msg: String, n: U32, fuel: U32) -> NO_Analysis:
  NO_Analysis{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, n, fuel, msg}

@unsafe
def p195oa_atom(+ty: String, +origin: KTerm, +value: KTerm) -> KTerm:
  kt("OA", ty, 0, 0, [origin, value])

@unsafe
def p195oa_origin(+value: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(value, "OA"), u => kid(value, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

@unsafe
def p195oa_env(+id: U32, xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+x, +rest}: nt_choose(KTerm, U32.is_eq(ix(x), id), u => kid(x, 0), u => p195oa_env(id, rest))

@unsafe
def p195oa_bind(id: U32, value: KTerm, env: List<&2, KTerm>) -> List<&2, KTerm>:
  Con{kt("OBind", "", id, 0, [value]), env}

@unsafe
def p195oa_spec(+name: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}:
          nt_choose(Maybe<&2, NO_Spec>, p88_string_eq(name, ctor), u => Some{spec}, u => p195oa_spec(name, rest))

@unsafe
def p195oa_fact(+origin: KTerm, facts: List<&2, KTerm>) -> KTerm:
  match facts:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+f, +rest}: nt_choose(KTerm, norm_exact(origin, kid(f, 0)), u => kid(f, 1), u => p195oa_fact(origin, rest))

@unsafe
def p195oa_equal_fields(values: List<&2, KTerm>, origins: List<&2, KTerm>, +facts: List<&2, KTerm>) -> Bool:
  match values, origins:
    case Nil{}, Nil{}: True{}
    case Con{+v, +vs}, Con{+o, +os}: p195oa_equal(v, o, facts) && p195oa_equal_fields(vs, os, facts)
    case _, _: False{}

@unsafe
def p195oa_equal(value, origin, facts):
  +shape = p195oa_fact(origin, facts)
  nt_choose(Bool, p98_tag_eq(value, "OA"), u => norm_exact(p195oa_origin(value), origin), u =>
    p98_tag_eq(value, "OC") && p98_tag_eq(shape, "OC") && p88_string_eq(nm(value), nm(shape)) && p195oa_equal_fields(ks(value), ks(shape), facts))

@unsafe
def p195oa_prepend(+statement: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}: NO_Analysis{kt("NO_Let", "", ix(statement), 0, [kid(statement, 0), body]), n, fuel, error}

@unsafe
def p195oa_names(names: List<&2, String>) -> List<&2, KTerm>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}: Con{ref(name), p195oa_names(rest)}

@unsafe
def p195oa_unames(names: List<&2, KTerm>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{nm(h), p195oa_unames(rest)}

@unsafe
def p195oa_eval_args(+ctx: P195ODContext, ts: List<&2, KTerm>, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match ts:
    case Nil{}: p195oa_continue(ctx, k, NO_Input{kt("OArgs", "", 0, 0, nt_reverse(KTerm, acc, Nil{})), facts, n, fuel})
    case Con{+h, +rest}: p195oa_eval(ctx, h, env, facts, stack, n, fuel, NO_KEvalArgs{rest, env, stack, acc, k})

@unsafe
def p195oa_apply_args(+ctx: P195ODContext, +fn: KTerm, args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match args:
    case Nil{}: p195oa_continue(ctx, k, NO_Input{fn, facts, n, fuel})
    case Con{+arg, +rest}: p195oa_apply(ctx, fn, arg, facts, n, fuel, NO_KApplyArgs{rest, k})

@unsafe
def p195oa_eval(ctx, t, env, facts, stack, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0) || U32.is_ge(n, 294967200), u => p195oa_fail("observer: candidate budget or fresh range", n, fuel), u => p195oa_eval_step(ctx, t, env, facts, stack, n, U32.sub(fuel, 1), k))

@unsafe
def p195oa_eval_step(+ctx: P195ODContext, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +tag = tg(t)
  nt_choose(NO_Analysis, p88_string_eq(tag, "Var"), u => nt_choose(NO_Analysis, p98_tag_eq(p195oa_env(ix(t), env), "Absent"), v => p195oa_fail("observer: unbound source variable", n, fuel), v => p195oa_continue(ctx, k, NO_Input{p195oa_env(ix(t), env), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, core_literal(t), u => p195oa_literal(ctx, t, env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Lam") || p88_string_eq(tag, "Mat"), u => p195oa_continue(ctx, k, NO_Input{kt(nt_choose(String, p88_string_eq(tag, "Lam"), v => "OL", v => "OM"), "", 0, 0, [t, kt("OEnv", "", 0, 0, env), kt("OStack", "", 0, 0, p195oa_names(stack))]), facts, n, fuel}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ref"), u => nt_choose(NO_Analysis, U32.is_eq(qt(t), 3) || U32.is_eq(nd_arity(p195oa_book(ctx), nm(t)), 0), v => p195oa_fail("observer: bang or demanded zero-arity reference", n, fuel), v => p195oa_continue(ctx, k, NO_Input{kt("OR", nm(t), 0, 0, [kt("OStack", "", 0, 0, p195oa_names(stack))]), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "App"), u => p195oa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, NO_KAppFunction{kid(t, 1), env, stack, k}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ctr"), u => nt_choose(NO_Analysis, no_literal_demanding_ctor(nm(t)), v => p195oa_fail("observer: demanding scalar constructor", n, fuel), v => p195oa_eval_args(ctx, ks(t), env, facts, stack, Nil{}, n, fuel, NO_KConstructor{nm(t), k})), u =>
  nt_choose(NO_Analysis, nb_contains(["Ann", "Loc", "Src", "Cut", "Slf", "Ins"], tag), u => p195oa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Efq"), u => NO_Analysis{kt("NO_Error", "ERR_FIDS", 0, 0, Nil{}), n, fuel, ""}, u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Let") && U32.is_eq(terms_len(ks(t)), 2) && p98_tag_eq(kid(t, 0), "Bind"), u => p195oa_eval(ctx, kid(kid(t, 0), 0), env, facts, stack, n, fuel, NO_KLetBody{kid(t, 1), ix(kid(t, 0)), env, stack, k}), u => p195oa_fail("observer: unsupported evaluated core " ++ tag, n, fuel))))))))))

@unsafe
def p195oa_value_type(+ctx: P195ODContext, +v: KTerm) -> String:
  nt_choose(String, p98_tag_eq(v, "OA"), u => nm(v), u => p195oa_ctor_type(p195oa_spec(nm(v), no_schema_specs(p195oa_schema(ctx)))))

@unsafe
def p195oa_ctor_type(spec: Maybe<&2, NO_Spec>) -> String:
  match spec:
    case None{}: ""
    case Some{NO_Spec{+layout, +owner, +fields}}: owner

@unsafe
def p195oa_scalar(+ctx: P195ODContext, +v: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(v, "OA") && nol_scalar(p195oa_book(ctx), kt("ADT", nm(v), 0, 0, Nil{})), u => kid(v, 1), u =>
    nt_choose(KTerm, p98_tag_eq(v, "OC"), w => p195oa_scalar_ctor(ctx, v, p195oa_spec(nm(v), no_schema_specs(p195oa_schema(ctx)))), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

@unsafe
def p195oa_scalar_ctor(+ctx: P195ODContext, +v: KTerm, spec: Maybe<&2, NO_Spec>) -> KTerm:
  match spec:
    case None{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}}:
      nt_choose(KTerm, p88_string_eq(storage, "Char") && U32.is_eq(terms_len(ks(v)), 1) && p88_string_eq(p195oa_value_type(ctx, kid(v, 0)), "U32"), u => p195oa_scalar(ctx, kid(v, 0)), u =>
        nt_choose(KTerm, p88_string_eq(storage, "Nullary") && List.is_empty(&2, KTerm, ks(v)) && nol_scalar(p195oa_book(ctx), kt("ADT", owner, 0, 0, Nil{})), w => kt("NCtr", ctor, 0, 0, Nil{}), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

@unsafe
def p195oa_scalars(+ctx: P195ODContext, values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{p195oa_scalar(ctx, h), p195oa_scalars(ctx, rest)}

@unsafe
def p195oa_no_absent(values: List<&2, KTerm>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{+h, +rest}: Bool.not(p98_tag_eq(h, "Absent")) && p195oa_no_absent(rest)

@unsafe
def p195oa_call_result(+ctx: P195ODContext, +ty: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => p195oa_call_types(ctx, nq_layout_type(p195oa_book(ctx), ty), args, U32.sub(fuel, 1)))

@unsafe
def p195oa_call_types(+ctx: P195ODContext, +head: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: nt_choose(KTerm, nol_scalar(p195oa_book(ctx), head), u => head, u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{+v, +rest}:
      +want = nq_layout_type(p195oa_book(ctx), kid(head, 0))
      nt_choose(KTerm, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && nol_scalar(p195oa_book(ctx), want) && p88_string_eq(p195oa_value_type(ctx, v), nm(want)), u => p195oa_call_result(ctx, kid(head, 1), rest, fuel), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

@unsafe
def p195oa_primitive(+ctx: P195ODContext, +name: String, +args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +words = p195oa_scalars(ctx, args)
  +result = p195oa_call_result(ctx, dt(lookup(p195oa_book(ctx), name)), args, 8)
  +id = nc_id(n)
  nt_choose(NO_Analysis, p195oa_no_absent(words) && Bool.not(p98_tag_eq(result, "Absent")),
    u => p195oa_prepend(kt("NO_Let", "", id, 0, [kt("NOp", nc_primitive_name(name), 0, 0, words)]), p195oa_continue(ctx, k, NO_Input{p195oa_atom(nm(result), kt("OUnique", "", id, 0, Nil{}), var("", id)), facts, U32.inc(n), fuel})),
    u => p195oa_fail("observer: scalar primitive type", n, fuel))

@unsafe
def p195oa_apply(ctx, fn, arg, facts, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0), u => p195oa_fail("observer: candidate budget", n, fuel), u => p195oa_apply_step(ctx, fn, arg, facts, n, U32.sub(fuel, 1), k))

@unsafe
def p195oa_apply_step(+ctx: P195ODContext, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OL"), u => p195oa_eval(ctx, kid(kid(fn, 0), 0), p195oa_bind(ix(kid(fn, 0)), arg, ks(kid(fn, 1))), facts, p195oa_unames(ks(kid(fn, 2))), n, fuel, k), u =>
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OM"), u => p195oa_match(ctx, fn, arg, facts, n, fuel, k), u =>
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OR"), u => p195oa_reference(ctx, nm(fn), List.append(&2, KTerm, p195oa_tail(ks(fn)), [arg]), facts, p195oa_unames(ks(kid(fn, 0))), n, fuel, k), u => p195oa_fail("observer: dynamic application", n, fuel))))

@unsafe
def p195oa_field_values(+owner: String, +ctor: String, +origin: KTerm, fields: List<&2, String>, +i: U32, +n: U32) -> List<&2, KTerm>:
  match fields:
    case Nil{}: Nil{}
    case Con{+ty, +rest}: Con{p195oa_atom(ty, kt("OField", ctor, i, 0, [origin, ref(owner)]), var("", nc_id(n))), p195oa_field_values(owner, ctor, origin, rest, U32.inc(i), U32.inc(n))}

@unsafe
def p195oa_origins(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{p195oa_origin(h), p195oa_origins(rest)}

@unsafe
def p195oa_value_words(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{kid(h, 1), p195oa_value_words(rest)}

@unsafe
def p195oa_match(+ctx: P195ODContext, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn, 0)
  nt_choose(NO_Analysis, p98_tag_eq(arg, "OC"),
    u => nt_choose(NO_Analysis, p88_string_eq(nm(mat), nm(arg)),
      v => nt_choose(NO_Analysis, U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))), w => p195oa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), facts, p195oa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyArgs{ks(arg), k}), w => p195oa_fail("observer: virtual constructor arity", n, fuel)),
      v => p195oa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, p195oa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyOne{arg, k})),
    u => p195oa_match_spec(ctx, fn, arg, facts, n, fuel, k, p195oa_spec(nm(mat), no_schema_specs(p195oa_schema(ctx)))))

@unsafe
def p195oa_match_spec(+ctx: P195ODContext, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont, spec: Maybe<&2, NO_Spec>) -> NO_Analysis:
  match spec:
    case None{}: p195oa_fail("observer: matcher representation", n, fuel)
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +types}}:
      nt_choose(NO_Analysis, p98_tag_eq(arg, "OA") && p88_string_eq(nm(arg), owner) && U32.is_eq(ix(kid(fn, 0)), U32.inc(width)),
        u => p195oa_match_fields(ctx, fn, arg, facts, key, p195oa_field_values(owner, ctor, p195oa_origin(arg), types, 0, n), U32.add(n, width), fuel, k), u => p195oa_fail("observer: matcher type or width", n, fuel))

@unsafe
def p195oa_match_join(key: String, word: KTerm, fields: List<&2, KTerm>, yes: NO_Analysis, +no: NO_Analysis) -> NO_Analysis:
  NO_Analysis{kt("NO_Match", key, 0, 0, [word, kt("NO_Fields", "", 0, 0, p195oa_value_words(fields)), p195oa_body(yes), p195oa_body(no)]), p195oa_fresh(no), p195oa_fuel(no), p195oa_error(no)}

@unsafe
def p195oa_tail(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{+x, +rest}: rest

@unsafe
def p195oa_entry_values(params: List<&2, KTerm>, +i: U32) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{p195oa_atom(nm(p), kt("OArg", "", i, 0, Nil{}), p), p195oa_entry_values(rest, U32.inc(i))}

@unsafe
def p195oa_param_origin(+id: U32, params: List<&2, KTerm>, +i: U32) -> KTerm:
  match params:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+p, +rest}: nt_choose(KTerm, U32.is_eq(ix(p), id), u => kt("OArg", "", i, 0, Nil{}), u => p195oa_param_origin(id, rest, U32.inc(i)))

@unsafe
def p195oa_finish_fields(+ctx: P195ODContext, values: List<&2, KTerm>, templates: List<&2, KTerm>, +facts: List<&2, KTerm>) -> KTerm:
  match values, templates:
    case Nil{}, Nil{}: kt("OResult", "", 0, 0, Nil{})
    case Con{+v, +vs}, Con{+t, +ts}: p195oa_finish_merge(p195oa_finish_value(ctx, v, t, facts), p195oa_finish_fields(ctx, vs, ts, facts))
    case _, _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def p195oa_finish_merge(+a: KTerm, +b: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(a, "OResult") && p98_tag_eq(b, "OResult"), u => kt("OResult", "", 0, 0, nt_append(KTerm, ks(a), ks(b))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

@unsafe
def p195oa_below(+origin: KTerm, +want: KTerm) -> Bool:
  nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>
    nt_choose(Bool, p98_tag_eq(origin, "OField"), v => p195oa_below(kid(origin, 0), want), v => False{}))

@unsafe
def p195oa_root_param(+ctx: P195ODContext, +p: KTerm) -> Bool:
  Bool.not(nol_scalar(p195oa_book(ctx), kt("ADT", nm(p), 0, 0, Nil{})))

@unsafe
def p195oa_loop_valid(+ctx: P195ODContext, params: List<&2, KTerm>, args: List<&2, KTerm>, +i: U32, +strict: Bool) -> Bool:
  match params, args:
    case Nil{}, Nil{}: strict
    case Con{+p, +ps}, Con{+a, +rest}:
      nt_choose(Bool, p195oa_root_param(ctx, p),
        u => p98_tag_eq(a, "OA") && p88_string_eq(nm(a), nm(p)) && p195oa_below(p195oa_origin(a), kt("OArg", "", i, 0, Nil{})) && p195oa_loop_valid(ctx, ps, rest, U32.inc(i), strict || p98_tag_eq(p195oa_origin(a), "OField")),
        u => p88_string_eq(p195oa_value_type(ctx, a), nm(p)) && Bool.not(p98_tag_eq(p195oa_scalar(ctx, a), "Absent")) && p195oa_loop_valid(ctx, ps, rest, U32.inc(i), strict))
    case _, _: False{}

@unsafe
def p195oa_loop_words(+ctx: P195ODContext, params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: Con{nt_choose(KTerm, p195oa_root_param(ctx, p), u => kid(a, 1), u => p195oa_scalar(ctx, a)), p195oa_loop_words(ctx, ps, rest)}
    case _, _: Nil{}

@unsafe
def p195oa_actuals(params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: p195oa_bind(ix(p), a, p195oa_actuals(ps, rest))
    case _, _: Nil{}

@unsafe
def p195oa_virtual_fields(ts: List<&2, KTerm>, +env: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{p195oa_virtual(h, env), p195oa_virtual_fields(rest, env)}

@unsafe
def p195oa_literal(+ctx: P195ODContext, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +lit = no_literal_typed(p195oa_book(ctx), t)
  +step = no_literal_string_step(p195oa_book(ctx), t)
  nt_choose(NO_Analysis, p98_tag_eq(lit, "NO_TypedWord"), u => p195oa_continue(ctx, k, NO_Input{p195oa_atom(nm(lit), kt("OConst", nm(lit), ix(lit), 0, Nil{}), kid(lit, 0)), facts, n, fuel}), u =>
    nt_choose(NO_Analysis, p98_tag_eq(step, "Absent"), v => p195oa_fail("observer: unsupported literal", n, fuel), v => p195oa_eval(ctx, step, env, facts, stack, n, fuel, k)))

@unsafe
def p195oa_constructor(+ctx: P195ODContext, +name: String, +input: NO_Input, +k: NO_Cont) -> NO_Analysis:
  +args = ks(p195oa_iv(input))
  +valid = Bool.not(p88_string_eq(name, "Chr")) || (U32.is_eq(terms_len(args), 1) && p88_string_eq(p195oa_value_type(ctx, terms_at(args, 0)), "U32"))
  nt_choose(NO_Analysis, valid, u => p195oa_continue(ctx, k, NO_Input{kt("OC", name, 0, 0, args), p195oa_if(input), p195oa_in(input), p195oa_iu(input)}), u => p195oa_fail("observer: Char constructor type", p195oa_in(input), p195oa_iu(input)))

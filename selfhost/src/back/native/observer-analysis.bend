# Source-only proposal. Not installed or compiler-validated.
# KTerm virtual values are compiler-owned: OA atom, OC constructor,
# OL/OM lexical closures, OR named partially-applied reference.
# Runtime binders use nc_id(counter); source binder IDs only key lexical envs.
type NO_Context is Data:
  NO_Context{+book: List<&2, KDef>, +owner: String, +schema: NO_Schema}

type NO_Input is Data:
  NO_Input{+value: KTerm, +facts: List<&2, KTerm>, +fresh: U32, +fuel: U32}

type NO_Analysis is Data:
  NO_Analysis{+body: KTerm, +fresh: U32, +fuel: U32, +error: String}

@unsafe
def noa_book(c: NO_Context) -> List<&2, KDef>:
  match c:
    case NO_Context{+b, +o, +s}: b

@unsafe
def noa_owner(c: NO_Context) -> String:
  match c:
    case NO_Context{+b, +o, +s}: o

@unsafe
def noa_schema(c: NO_Context) -> NO_Schema:
  match c:
    case NO_Context{+b, +o, +s}: s

@unsafe
def noa_iv(i: NO_Input) -> KTerm:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: v

@unsafe
def noa_if(i: NO_Input) -> List<&2, KTerm>:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: f

@unsafe
def noa_in(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: n

@unsafe
def noa_iu(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: fuel

@unsafe
def noa_body(a: NO_Analysis) -> KTerm:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: b

@unsafe
def noa_fresh(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: n

@unsafe
def noa_fuel(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: f

@unsafe
def noa_error(a: NO_Analysis) -> String:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: e

@unsafe
def noa_fail(msg: String, n: U32, fuel: U32) -> NO_Analysis:
  NO_Analysis{atom("Absent"), n, fuel, msg}

@unsafe
def noa_atom(+ty: String, +origin: KTerm, +value: KTerm) -> KTerm:
  kt("OA", ty, 0, 0, [origin, value])

@unsafe
def noa_origin(+value: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(value), "OA"), u => kid(value, 0), u => atom("Absent"))

@unsafe
def noa_env(+id: U32, xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{+x, +rest}: nt_choose(KTerm, U32.is_eq(ix(x), id), u => kid(x, 0), u => noa_env(id, rest))

@unsafe
def noa_bind(id: U32, value: KTerm, env: List<&2, KTerm>) -> List<&2, KTerm>:
  Con{kt("OBind", "", id, 0, [value]), env}

@unsafe
def noa_spec(+name: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}:
          nt_choose(Maybe<&2, NO_Spec>, String.eq(name, ctor), u => Some{spec}, u => noa_spec(name, rest))

@unsafe
def noa_fact(+origin: KTerm, facts: List<&2, KTerm>) -> KTerm:
  match facts:
    case Nil{}: atom("Absent")
    case Con{+f, +rest}: nt_choose(KTerm, norm_exact(origin, kid(f, 0)), u => kid(f, 1), u => noa_fact(origin, rest))

law noa_equal:
  for +value: KTerm
  for +origin: KTerm
  for +facts: List<&2, KTerm>
  Bool

@unsafe
def noa_equal_fields(values: List<&2, KTerm>, origins: List<&2, KTerm>, +facts: List<&2, KTerm>) -> Bool:
  match values, origins:
    case Nil{}, Nil{}: True{}
    case Con{+v, +vs}, Con{+o, +os}: noa_equal(v, o, facts) && noa_equal_fields(vs, os, facts)
    case _, _: False{}

@unsafe
def noa_equal(value, origin, facts):
  +shape = noa_fact(origin, facts)
  nt_choose(Bool, String.eq(tg(value), "OA"), u => norm_exact(noa_origin(value), origin), u =>
    String.eq(tg(value), "OC") && String.eq(tg(shape), "OC") && String.eq(nm(value), nm(shape)) && noa_equal_fields(ks(value), ks(shape), facts))

@unsafe
def noa_prepend(+statement: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}: NO_Analysis{kt("NO_Let", "", ix(statement), 0, [kid(statement, 0), body]), n, fuel, error}

law noa_eval:
  for +ctx: NO_Context
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +stack: List<&2, String>
  for +n: U32
  for +fuel: U32
  for +k: NO_Input -> NO_Analysis
  NO_Analysis

law noa_apply:
  for +ctx: NO_Context
  for +fn: KTerm
  for +arg: KTerm
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Input -> NO_Analysis
  NO_Analysis

@unsafe
def noa_names(names: List<&2, String>) -> List<&2, KTerm>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}: Con{ref(name), noa_names(rest)}

@unsafe
def noa_unames(names: List<&2, KTerm>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{nm(h), noa_unames(rest)}

@unsafe
def noa_eval_args(+ctx: NO_Context, ts: List<&2, KTerm>, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  match ts:
    case Nil{}: k(NO_Input{kt("OArgs", "", 0, 0, nt_reverse(KTerm, acc, Nil{})), facts, n, fuel})
    case Con{+h, +rest}: noa_eval(ctx, h, env, facts, stack, n, fuel, +i => noa_eval_args(ctx, rest, env, noa_if(i), stack, Con{noa_iv(i), acc}, noa_in(i), noa_iu(i), k))

@unsafe
def noa_apply_args(+ctx: NO_Context, +fn: KTerm, args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  match args:
    case Nil{}: k(NO_Input{fn, facts, n, fuel})
    case Con{+arg, +rest}: noa_apply(ctx, fn, arg, facts, n, fuel, +i => noa_apply_args(ctx, noa_iv(i), rest, noa_if(i), noa_in(i), noa_iu(i), k))

@unsafe
def noa_eval(ctx, t, env, facts, stack, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0) || U32.is_ge(n, 294967200), u => noa_fail("observer: candidate budget or fresh range", n, fuel), u => noa_eval_step(ctx, t, env, facts, stack, n, U32.sub(fuel, 1), k))

@unsafe
def noa_eval_step(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +tag = tg(t)
  nt_choose(NO_Analysis, String.eq(tag, "Var"), u => nt_choose(NO_Analysis, String.eq(tg(noa_env(ix(t), env)), "Absent"), v => noa_fail("observer: unbound source variable", n, fuel), v => k(NO_Input{noa_env(ix(t), env), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, core_literal(t), u => noa_literal(ctx, t, env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, String.eq(tag, "Lam") || String.eq(tag, "Mat"), u => k(NO_Input{kt(nt_choose(String, String.eq(tag, "Lam"), v => "OL", v => "OM"), "", 0, 0, [t, kt("OEnv", "", 0, 0, env), kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel}), u =>
  nt_choose(NO_Analysis, String.eq(tag, "Ref"), u => nt_choose(NO_Analysis, U32.is_eq(qt(t), 3) || U32.is_eq(nd_arity(noa_book(ctx), nm(t)), 0), v => noa_fail("observer: bang or demanded zero-arity reference", n, fuel), v => k(NO_Input{kt("OR", nm(t), 0, 0, [kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, String.eq(tag, "App"), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, +f => noa_eval(ctx, kid(t, 1), env, noa_if(f), stack, noa_in(f), noa_iu(f), +a => noa_apply(ctx, noa_iv(f), noa_iv(a), noa_if(a), noa_in(a), noa_iu(a), k))), u =>
  nt_choose(NO_Analysis, String.eq(tag, "Ctr"), u => nt_choose(NO_Analysis, no_literal_demanding_ctor(nm(t)), v => noa_fail("observer: demanding scalar constructor", n, fuel), v => noa_eval_args(ctx, ks(t), env, facts, stack, Nil{}, n, fuel, +i => noa_constructor(ctx, nm(t), i, k))), u =>
  nt_choose(NO_Analysis, nb_contains(["Ann", "Loc", "Src", "Cut", "Slf", "Ins"], tag), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, String.eq(tag, "Efq"), u => NO_Analysis{kt("NO_Error", "ERR_FIDS", 0, 0, Nil{}), n, fuel, ""}, u =>
  nt_choose(NO_Analysis, String.eq(tag, "Let") && U32.is_eq(terms_len(ks(t)), 2) && String.eq(tg(kid(t, 0)), "Bind"), u => noa_eval(ctx, kid(kid(t, 0), 0), env, facts, stack, n, fuel, +i => noa_eval(ctx, kid(t, 1), noa_bind(ix(kid(t, 0)), noa_iv(i), env), noa_if(i), stack, noa_in(i), noa_iu(i), k)), u => noa_fail("observer: unsupported evaluated core " ++ tag, n, fuel))))))))))

@unsafe
def noa_value_type(+ctx: NO_Context, +v: KTerm) -> String:
  nt_choose(String, String.eq(tg(v), "OA"), u => nm(v), u => noa_ctor_type(noa_spec(nm(v), no_schema_specs(noa_schema(ctx)))))

@unsafe
def noa_ctor_type(spec: Maybe<&2, NO_Spec>) -> String:
  match spec:
    case None{}: ""
    case Some{NO_Spec{+layout, +owner, +fields}}: owner

@unsafe
def noa_scalar(+ctx: NO_Context, +v: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(v), "OA") && nol_scalar(noa_book(ctx), kt("ADT", nm(v), 0, 0, Nil{})), u => kid(v, 1), u =>
    nt_choose(KTerm, String.eq(tg(v), "OC"), w => noa_scalar_ctor(ctx, v, noa_spec(nm(v), no_schema_specs(noa_schema(ctx)))), w => atom("Absent")))

@unsafe
def noa_scalar_ctor(+ctx: NO_Context, +v: KTerm, spec: Maybe<&2, NO_Spec>) -> KTerm:
  match spec:
    case None{}: atom("Absent")
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}}:
      nt_choose(KTerm, String.eq(storage, "Char") && U32.is_eq(terms_len(ks(v)), 1) && String.eq(noa_value_type(ctx, kid(v, 0)), "U32"), u => noa_scalar(ctx, kid(v, 0)), u =>
        nt_choose(KTerm, String.eq(storage, "Nullary") && List.is_empty(&2, KTerm, ks(v)) && nol_scalar(noa_book(ctx), kt("ADT", owner, 0, 0, Nil{})), w => kt("NCtr", ctor, 0, 0, Nil{}), w => atom("Absent")))

@unsafe
def noa_scalars(+ctx: NO_Context, values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_scalar(ctx, h), noa_scalars(ctx, rest)}

@unsafe
def noa_no_absent(values: List<&2, KTerm>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{+h, +rest}: Bool.not(String.eq(tg(h), "Absent")) && noa_no_absent(rest)

@unsafe
def noa_call_result(+ctx: NO_Context, +ty: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => atom("Absent"), u => noa_call_types(ctx, nq_layout_type(noa_book(ctx), ty), args, U32.sub(fuel, 1)))

@unsafe
def noa_call_types(+ctx: NO_Context, +head: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: nt_choose(KTerm, nol_scalar(noa_book(ctx), head), u => head, u => atom("Absent"))
    case Con{+v, +rest}:
      +want = nq_layout_type(noa_book(ctx), kid(head, 0))
      nt_choose(KTerm, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && nol_scalar(noa_book(ctx), want) && String.eq(noa_value_type(ctx, v), nm(want)), u => noa_call_result(ctx, kid(head, 1), rest, fuel), u => atom("Absent"))

@unsafe
def noa_primitive(+ctx: NO_Context, +name: String, +args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +words = noa_scalars(ctx, args)
  +result = noa_call_result(ctx, dt(lookup(noa_book(ctx), name)), args, 8)
  +id = nc_id(n)
  nt_choose(NO_Analysis, noa_no_absent(words) && Bool.not(String.eq(tg(result), "Absent")),
    u => noa_prepend(kt("NO_Let", "", id, 0, [kt("NOp", nc_primitive_name(name), 0, 0, words)]), k(NO_Input{noa_atom(nm(result), kt("OUnique", "", id, 0, Nil{}), var("", id)), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: scalar primitive type", n, fuel))

law noa_recur:
  for +ctx: NO_Context
  for +args: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Input -> NO_Analysis
  NO_Analysis

@unsafe
def noa_apply(ctx, fn, arg, facts, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0), u => noa_fail("observer: candidate budget", n, fuel), u => noa_apply_step(ctx, fn, arg, facts, n, U32.sub(fuel, 1), k))

@unsafe
def noa_apply_step(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  nt_choose(NO_Analysis, String.eq(tg(fn), "OL"), u => noa_eval(ctx, kid(kid(fn, 0), 0), noa_bind(ix(kid(fn, 0)), arg, ks(kid(fn, 1))), facts, noa_unames(ks(kid(fn, 2))), n, fuel, k), u =>
  nt_choose(NO_Analysis, String.eq(tg(fn), "OM"), u => noa_match(ctx, fn, arg, facts, n, fuel, k), u =>
  nt_choose(NO_Analysis, String.eq(tg(fn), "OR"), u => noa_reference(ctx, nm(fn), List.append(&2, KTerm, noa_tail(ks(fn)), [arg]), facts, noa_unames(ks(kid(fn, 0))), n, fuel, k), u => noa_fail("observer: dynamic application", n, fuel))))

@unsafe
def noa_reference(+ctx: NO_Context, +name: String, +args: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +arity = nd_arity(noa_book(ctx), name)
  +d = lookup(noa_book(ctx), name)
  nt_choose(NO_Analysis, U32.is_lt(terms_len(args), arity), u => k(NO_Input{kt("OR", name, 0, 0, Con{kt("OStack", "", 0, 0, noa_names(stack)), args}), facts, n, fuel}), u =>
  nt_choose(NO_Analysis, Bool.not(U32.is_eq(terms_len(args), arity)), u => noa_fail("observer: saturation", n, fuel), u =>
  nt_choose(NO_Analysis, String.eq(name, noa_owner(ctx)), u => noa_recur(ctx, args, facts, n, fuel, k), u =>
  nt_choose(NO_Analysis, nc_native_def(d) && nd_scalar_known(nc_primitive_name(name)), u => noa_primitive(ctx, name, args, facts, n, fuel, k), u =>
  nt_choose(NO_Analysis, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack, name)) && U32.is_lt(nt_count(String, stack), 8),
    u => noa_eval(ctx, nc_definition_plain(noa_book(ctx), d, n), Nil{}, facts, Con{name, stack}, n, fuel, +i => noa_apply_args(ctx, noa_iv(i), args, noa_if(i), noa_in(i), noa_iu(i), k)),
    u => noa_fail("observer: helper effect, cycle or depth", n, fuel))))))

@unsafe
def noa_field_values(+owner: String, +ctor: String, +origin: KTerm, fields: List<&2, String>, +i: U32, +n: U32) -> List<&2, KTerm>:
  match fields:
    case Nil{}: Nil{}
    case Con{+ty, +rest}: Con{noa_atom(ty, kt("OField", ctor, i, 0, [origin, ref(owner)]), var("", nc_id(n))), noa_field_values(owner, ctor, origin, rest, U32.inc(i), U32.inc(n))}

@unsafe
def noa_origins(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_origin(h), noa_origins(rest)}

@unsafe
def noa_value_words(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{kid(h, 1), noa_value_words(rest)}

@unsafe
def noa_match(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +mat = kid(fn, 0)
  nt_choose(NO_Analysis, String.eq(tg(arg), "OC"),
    u => nt_choose(NO_Analysis, String.eq(nm(mat), nm(arg)),
      v => nt_choose(NO_Analysis, U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))), w => noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, +i => noa_apply_args(ctx, noa_iv(i), ks(arg), noa_if(i), noa_in(i), noa_iu(i), k)), w => noa_fail("observer: virtual constructor arity", n, fuel)),
      v => noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, +i => noa_apply(ctx, noa_iv(i), arg, noa_if(i), noa_in(i), noa_iu(i), k))),
    u => noa_match_spec(ctx, fn, arg, facts, n, fuel, k, noa_spec(nm(mat), no_schema_specs(noa_schema(ctx)))))

@unsafe
def noa_match_spec(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis, spec: Maybe<&2, NO_Spec>) -> NO_Analysis:
  match spec:
    case None{}: noa_fail("observer: matcher representation", n, fuel)
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +types}}:
      nt_choose(NO_Analysis, String.eq(tg(arg), "OA") && String.eq(nm(arg), owner) && U32.is_eq(ix(kid(fn, 0)), U32.inc(width)),
        u => noa_match_fields(ctx, fn, arg, facts, key, noa_field_values(owner, ctor, noa_origin(arg), types, 0, n), U32.add(n, width), fuel, k), u => noa_fail("observer: matcher type or width", n, fuel))

@unsafe
def noa_match_fields(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +key: String, +fields: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +mat = kid(fn, 0)
  +yesfacts = {Con{kt("OFact", "", 0, 0, [noa_origin(arg), kt("OC", nm(mat), 0, 0, noa_origins(fields))]), facts}: List<&2, KTerm>}
  +yes = noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), yesfacts, noa_unames(ks(kid(fn, 2))), n, fuel, +i => noa_apply_args(ctx, noa_iv(i), fields, noa_if(i), noa_in(i), noa_iu(i), k))
  nt_choose(NO_Analysis, String.eq(noa_error(yes), ""),
    u => noa_match_join(key, kid(arg, 1), fields, yes, noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), noa_fresh(yes), noa_fuel(yes), +i => noa_apply(ctx, noa_iv(i), arg, noa_if(i), noa_in(i), noa_iu(i), k))), u => yes)

@unsafe
def noa_match_join(key: String, word: KTerm, fields: List<&2, KTerm>, yes: NO_Analysis, +no: NO_Analysis) -> NO_Analysis:
  NO_Analysis{kt("NO_Match", key, 0, 0, [word, kt("NO_Fields", "", 0, 0, noa_value_words(fields)), noa_body(yes), noa_body(no)]), noa_fresh(no), noa_fuel(no), noa_error(no)}

@unsafe
def noa_tail(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{+x, +rest}: rest

@unsafe
def noa_entry_values(params: List<&2, KTerm>, +i: U32) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{noa_atom(nm(p), kt("OArg", "", i, 0, Nil{}), p), noa_entry_values(rest, U32.inc(i))}

@unsafe
def noa_param_origin(+id: U32, params: List<&2, KTerm>, +i: U32) -> KTerm:
  match params:
    case Nil{}: atom("Absent")
    case Con{+p, +rest}: nt_choose(KTerm, U32.is_eq(ix(p), id), u => kt("OArg", "", i, 0, Nil{}), u => noa_param_origin(id, rest, U32.inc(i)))

law noa_finish_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +template: KTerm
  for +facts: List<&2, KTerm>
  KTerm

@unsafe
def noa_finish_fields(+ctx: NO_Context, values: List<&2, KTerm>, templates: List<&2, KTerm>, +facts: List<&2, KTerm>) -> KTerm:
  match values, templates:
    case Nil{}, Nil{}: kt("OResult", "", 0, 0, Nil{})
    case Con{+v, +vs}, Con{+t, +ts}: noa_finish_merge(noa_finish_value(ctx, v, t, facts), noa_finish_fields(ctx, vs, ts, facts))
    case _, _: atom("Absent")

@unsafe
def noa_finish_merge(+a: KTerm, +b: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(a), "OResult") && String.eq(tg(b), "OResult"), u => kt("OResult", "", 0, 0, nt_append(KTerm, ks(a), ks(b))), u => atom("Absent"))

@unsafe
def noa_finish_value(ctx, value, template, facts):
  nt_choose(KTerm, String.eq(tg(template), "Var"), u =>
    nt_choose(KTerm, U32.is_eq(ix(template), no_schema_result(noa_schema(ctx))),
      v => nt_choose(KTerm, String.eq(noa_value_type(ctx, value), no_schema_observation(noa_schema(ctx))) && Bool.not(String.eq(tg(noa_scalar(ctx, value)), "Absent")), w => kt("OResult", "", 0, 0, [noa_scalar(ctx, value)]), w => atom("Absent")),
      v => nt_choose(KTerm, noa_equal(value, noa_param_origin(ix(template), no_schema_params(noa_schema(ctx)), 0), facts), w => kt("OResult", "", 0, 0, Nil{}), w => atom("Absent"))), u =>
    nt_choose(KTerm, String.eq(tg(template), "Ctr") && String.eq(tg(value), "OC") && String.eq(nm(template), nm(value)), v => noa_finish_fields(ctx, ks(value), ks(template), facts), v => atom("Absent")))

@unsafe
def noa_finish(+ctx: NO_Context, +input: NO_Input) -> NO_Analysis:
  +result = noa_finish_value(ctx, noa_iv(input), no_schema_wrapper(noa_schema(ctx)), noa_if(input))
  nt_choose(NO_Analysis, String.eq(tg(result), "OResult") && U32.is_eq(terms_len(ks(result)), 1), u => NO_Analysis{kt("NO_Return", "", 0, 0, ks(result)), noa_in(input), noa_iu(input), ""}, u => noa_fail("observer: returned root or observation unproved", noa_in(input), noa_iu(input)))

@unsafe
def noa_below(+origin: KTerm, +want: KTerm) -> Bool:
  nt_choose(Bool, norm_exact(origin, want), u => True{}, u => String.eq(tg(origin), "OField") && noa_below(kid(origin, 0), want))

@unsafe
def noa_root_param(+ctx: NO_Context, +p: KTerm) -> Bool:
  Bool.not(nol_scalar(noa_book(ctx), kt("ADT", nm(p), 0, 0, Nil{})))

@unsafe
def noa_loop_valid(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>, +i: U32, +strict: Bool) -> Bool:
  match params, args:
    case Nil{}, Nil{}: strict
    case Con{+p, +ps}, Con{+a, +rest}:
      nt_choose(Bool, noa_root_param(ctx, p),
        u => String.eq(tg(a), "OA") && String.eq(nm(a), nm(p)) && noa_below(noa_origin(a), kt("OArg", "", i, 0, Nil{})) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict || String.eq(tg(noa_origin(a)), "OField")),
        u => String.eq(noa_value_type(ctx, a), nm(p)) && Bool.not(String.eq(tg(noa_scalar(ctx, a)), "Absent")) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict))
    case _, _: False{}

@unsafe
def noa_loop_words(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: Con{nt_choose(KTerm, noa_root_param(ctx, p), u => kid(a, 1), u => noa_scalar(ctx, a)), noa_loop_words(ctx, ps, rest)}
    case _, _: Nil{}

@unsafe
def noa_actuals(params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: noa_bind(ix(p), a, noa_actuals(ps, rest))
    case _, _: Nil{}

law noa_virtual:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

@unsafe
def noa_virtual_fields(ts: List<&2, KTerm>, +env: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_virtual(h, env), noa_virtual_fields(rest, env)}

@unsafe
def noa_virtual(t, env):
  nt_choose(KTerm, String.eq(tg(t), "Var"), u => noa_env(ix(t), env), u => kt("OC", nm(t), 0, 0, noa_virtual_fields(ks(t), env)))

@unsafe
def noa_recur(ctx, args, facts, n, fuel, k):
  +schema = noa_schema(ctx)
  +params = no_schema_params(schema)
  +marker = var("", nc_id(n))
  +observation = noa_atom(no_schema_observation(schema), kt("ORecursive", "", nc_id(n), 0, Nil{}), marker)
  +env = noa_bind(no_schema_result(schema), observation, noa_actuals(params, args))
  nt_choose(NO_Analysis, noa_loop_valid(ctx, params, args, 0, False{}),
    u => noa_recur_done(ctx, args, marker, k(NO_Input{noa_virtual(no_schema_wrapper(schema), env), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: recursive cursor or scalar slot", n, fuel))

@unsafe
def noa_recur_done(+ctx: NO_Context, +args: List<&2, KTerm>, +marker: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}:
      nt_choose(NO_Analysis, String.eq(error, "") && String.eq(tg(body), "NO_Return") && U32.is_eq(terms_len(ks(body)), 1) && norm_exact(kid(body, 0), marker),
        u => NO_Analysis{kt("NO_Loop", "", 0, 0, noa_loop_words(ctx, no_schema_params(noa_schema(ctx)), args)), n, fuel, ""},
        u => noa_fail(nt_choose(String, String.eq(error, ""), v => "observer: non-tail or discarded recursive result", v => error), n, fuel))

# Public query entry: permission must be supplied by the checked host path.
# It is deliberately not read from any user-controlled book definition.
@unsafe
def noa_analyze(+book: List<&2, KDef>, +name: String, +schema: NO_Schema, +permission: Bool) -> NO_Analysis:
  nt_choose(NO_Analysis, permission && String.eq(no_schema_error(schema), ""),
    u => noa_analyze_ready(NO_Context{book, name, schema}),
    u => noa_fail("observer: absent checked permission or schema", no_schema_fresh(schema), 4096))

@unsafe
def noa_analyze_ready(+ctx: NO_Context) -> NO_Analysis:
  +schema = noa_schema(ctx)
  +params = noa_entry_values(no_schema_params(schema), 0)
  +body = nc_definition_plain(noa_book(ctx), lookup(noa_book(ctx), noa_owner(ctx)), no_schema_fresh(schema))
  noa_eval(ctx, body, Nil{}, Nil{}, Nil{}, no_schema_fresh(schema), 4096, +i => noa_apply_args(ctx, noa_iv(i), params, noa_if(i), noa_in(i), noa_iu(i), +j => noa_finish(ctx, j)))

@unsafe
def noa_literal(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +lit = no_literal_typed(noa_book(ctx), t)
  +step = no_literal_string_step(noa_book(ctx), t)
  nt_choose(NO_Analysis, String.eq(tg(lit), "NO_TypedWord"), u => k(NO_Input{noa_atom(nm(lit), kt("OConst", nm(lit), ix(lit), 0, Nil{}), kid(lit, 0)), facts, n, fuel}), u =>
    nt_choose(NO_Analysis, Bool.not(String.eq(tg(step), "Absent")), v => noa_eval(ctx, step, env, facts, stack, n, fuel, k), v => noa_fail("observer: unsupported literal", n, fuel)))

@unsafe
def noa_constructor(+ctx: NO_Context, +name: String, +input: NO_Input, +k: NO_Input -> NO_Analysis) -> NO_Analysis:
  +args = ks(noa_iv(input))
  +valid = Bool.not(String.eq(name, "Chr")) || (U32.is_eq(terms_len(args), 1) && String.eq(noa_value_type(ctx, terms_at(args, 0)), "U32"))
  nt_choose(NO_Analysis, valid, u => k(NO_Input{kt("OC", name, 0, 0, args), noa_if(input), noa_in(input), noa_iu(input)}), u => noa_fail("observer: Char constructor type", noa_in(input), noa_iu(input)))

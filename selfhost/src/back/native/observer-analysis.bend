
# Module: src/back/native/observer-analysis.bend:5
type NO_Context is Data:
  NO_Context{+book: List<&2,KDef>, +owner: String, +schema: NO_Schema, +helpers: List<&2,P128BRHelper>}

type NO_Input is Data:
  NO_Input{+value: KTerm, +facts: List<&2, KTerm>, +fresh: U32, +fuel: U32}

# Module: src/back/native/observer-analysis.bend:11
type NO_Analysis is Data:
  NO_Analysis{+body: KTerm, +fresh: U32, +fuel: U32, +error: String}

# Symbolic branches reuse the remaining computation. Store its environment as
# Data: native affine closures cannot be shared by ordinary reference counting.
# The analysis context is constant and stays outside these continuation frames.

# Module: src/back/native/observer-analysis.bend:17
type NO_Cont is Data:
  NO_KFinish{}
  NO_KEvalArgs{+terms: List<&2, KTerm>, +env: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +next: NO_Cont}
  NO_KApplyArgs{+args: List<&2, KTerm>, +next: NO_Cont}
  NO_KAppFunction{+arg: KTerm, +env: List<&2, KTerm>, +stack: List<&2, String>, +next: NO_Cont}
  NO_KAppArgument{+fn: KTerm, +next: NO_Cont}
  NO_KConstructor{+name: String, +next: NO_Cont}
  NO_KLetBody{+body: KTerm, +id: U32, +env: List<&2, KTerm>, +stack: List<&2, String>, +next: NO_Cont}
  NO_KApplyOne{+arg: KTerm, +next: NO_Cont}

# Module: src/back/native/observer-analysis.bend:131
law noa_equal:
  for +value: KTerm
  for +origin: KTerm
  for +facts: List<&2, KTerm>
  Bool

# Module: src/back/native/observer-analysis.bend:155
law noa_eval:
  for +ctx: NO_Context
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +stack: List<&2, String>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:166
law noa_apply:
  for +ctx: NO_Context
  for +fn: KTerm
  for +arg: KTerm
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:273
law noa_recur:
  for +ctx: NO_Context
  for +args: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:369
law noa_finish_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +template: KTerm
  for +facts: List<&2, KTerm>
  KTerm

# Module: src/back/native/observer-analysis.bend:430
law noa_virtual:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

# Module: src/back/native/observer-analysis.bend:28
@unsafe
def noa_continue(+ctx: NO_Context, k: NO_Cont, +input: NO_Input) -> NO_Analysis:
  match k:
    case NO_KFinish{}: noa_finish(ctx, input)
    case NO_KEvalArgs{terms, env, stack, acc, next}: noa_eval_args(ctx, terms, env, noa_if(input), stack, Con{noa_iv(input), acc}, noa_in(input), noa_iu(input), next)
    case NO_KApplyArgs{args, next}: noa_apply_args(ctx, noa_iv(input), args, noa_if(input), noa_in(input), noa_iu(input), next)
    case NO_KAppFunction{arg, env, stack, next}: noa_eval(ctx, arg, env, noa_if(input), stack, noa_in(input), noa_iu(input), NO_KAppArgument{noa_iv(input), next})
    case NO_KAppArgument{fn, next}: noa_apply(ctx, fn, noa_iv(input), noa_if(input), noa_in(input), noa_iu(input), next)
    case NO_KConstructor{name, next}: noa_constructor(ctx, name, input, next)
    case NO_KLetBody{body, id, env, stack, next}: noa_eval(ctx, body, noa_bind(id, noa_iv(input), env), noa_if(input), stack, noa_in(input), noa_iu(input), next)
    case NO_KApplyOne{arg, next}: noa_apply(ctx, noa_iv(input), arg, noa_if(input), noa_in(input), noa_iu(input), next)

# Module: src/back/native/observer-analysis.bend:40
@unsafe
def noa_book(c: NO_Context) -> List<&2,KDef>:
  match c:
    case NO_Context{book,owner,schema,helpers}: book

@unsafe
def noa_owner(c: NO_Context) -> String:
  match c:
    case NO_Context{book,owner,schema,helpers}: owner

@unsafe
def noa_schema(c: NO_Context) -> NO_Schema:
  match c:
    case NO_Context{book,owner,schema,helpers}: schema

@unsafe
def noa_iv(i: NO_Input) -> KTerm:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: v

# Module: src/back/native/observer-analysis.bend:60
@unsafe
def noa_if(i: NO_Input) -> List<&2, KTerm>:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: f

# Module: src/back/native/observer-analysis.bend:65
@unsafe
def noa_in(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: n

# Module: src/back/native/observer-analysis.bend:70
@unsafe
def noa_iu(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: fuel

# Module: src/back/native/observer-analysis.bend:75
@unsafe
def noa_body(a: NO_Analysis) -> KTerm:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: b

# Module: src/back/native/observer-analysis.bend:80
@unsafe
def noa_fresh(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: n

# Module: src/back/native/observer-analysis.bend:85
@unsafe
def noa_fuel(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: f

# Module: src/back/native/observer-analysis.bend:90
@unsafe
def noa_error(a: NO_Analysis) -> String:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: e

# Module: src/back/native/observer-analysis.bend:95
@unsafe
def noa_fail(msg: String, n: U32, fuel: U32) -> NO_Analysis:
  NO_Analysis{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, n, fuel, msg}

# Module: src/back/native/observer-analysis.bend:99
@unsafe
def noa_atom(+ty: String, +origin: KTerm, +value: KTerm) -> KTerm:
  kt("OA", ty, 0, 0, [origin, value])

# Module: src/back/native/observer-analysis.bend:103
@unsafe
def noa_origin(+value: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(value, "OA"), u => kid(value, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/observer-analysis.bend:107
@unsafe
def noa_env(+id: U32, xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+x, +rest}: nt_choose(KTerm, U32.is_eq(ix(x), id), u => kid(x, 0), u => noa_env(id, rest))

# Module: src/back/native/observer-analysis.bend:113
@unsafe
def noa_bind(id: U32, value: KTerm, env: List<&2, KTerm>) -> List<&2, KTerm>:
  Con{kt("OBind", "", id, 0, [value]), env}

# Module: src/back/native/observer-analysis.bend:117
@unsafe
def noa_spec(+name: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}:
          nt_choose(Maybe<&2, NO_Spec>, p88_string_eq(name, ctor), u => Some{spec}, u => noa_spec(name, rest))

# Module: src/back/native/observer-analysis.bend:126
@unsafe
def noa_fact(+origin: KTerm, facts: List<&2, KTerm>) -> KTerm:
  match facts:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+f, +rest}: nt_choose(KTerm, norm_exact(origin, kid(f, 0)), u => kid(f, 1), u => noa_fact(origin, rest))

# Module: src/back/native/observer-analysis.bend:138
@unsafe
def noa_equal_fields(values: List<&2, KTerm>, origins: List<&2, KTerm>, +facts: List<&2, KTerm>) -> Bool:
  match values, origins:
    case Nil{}, Nil{}: True{}
    case Con{+v, +vs}, Con{+o, +os}: noa_equal(v, o, facts) && noa_equal_fields(vs, os, facts)
    case _, _: False{}

# Module: src/back/native/observer-analysis.bend:145
@unsafe
def noa_equal(value, origin, facts):
  +shape = noa_fact(origin, facts)
  nt_choose(Bool, p98_tag_eq(value, "OA"), u => norm_exact(noa_origin(value), origin), u =>
    p98_tag_eq(value, "OC") && p98_tag_eq(shape, "OC") && p88_string_eq(nm(value), nm(shape)) && noa_equal_fields(ks(value), ks(shape), facts))

# Module: src/back/native/observer-analysis.bend:151
@unsafe
def noa_prepend(+statement: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}: NO_Analysis{kt("NO_Let", "", ix(statement), 0, [kid(statement, 0), body]), n, fuel, error}

# Module: src/back/native/observer-analysis.bend:177
@unsafe
def noa_names(names: List<&2, String>) -> List<&2, KTerm>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}: Con{ref(name), noa_names(rest)}

# Module: src/back/native/observer-analysis.bend:183
@unsafe
def noa_unames(names: List<&2, KTerm>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{nm(h), noa_unames(rest)}

# Module: src/back/native/observer-analysis.bend:189
@unsafe
def noa_eval_args(+ctx: NO_Context, ts: List<&2, KTerm>, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match ts:
    case Nil{}: noa_continue(ctx, k, NO_Input{kt("OArgs", "", 0, 0, nt_reverse(KTerm, acc, Nil{})), facts, n, fuel})
    case Con{+h, +rest}: noa_eval(ctx, h, env, facts, stack, n, fuel, NO_KEvalArgs{rest, env, stack, acc, k})

# Module: src/back/native/observer-analysis.bend:195
@unsafe
def noa_apply_args(+ctx: NO_Context, +fn: KTerm, args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match args:
    case Nil{}: noa_continue(ctx, k, NO_Input{fn, facts, n, fuel})
    case Con{+arg, +rest}: noa_apply(ctx, fn, arg, facts, n, fuel, NO_KApplyArgs{rest, k})

# Module: src/back/native/observer-analysis.bend:201
@unsafe
def noa_eval(ctx, t, env, facts, stack, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0) || U32.is_ge(n, 294967200), u => noa_fail("observer: candidate budget or fresh range", n, fuel), u => noa_eval_step(ctx, t, env, facts, stack, n, U32.sub(fuel, 1), k))

# Module: src/back/native/observer-analysis.bend:205
@unsafe
def noa_eval_step(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +tag = tg(t)
  nt_choose(NO_Analysis, p88_string_eq(tag, "Var"), u => nt_choose(NO_Analysis, p98_tag_eq(noa_env(ix(t), env), "Absent"), v => noa_fail("observer: unbound source variable", n, fuel), v => noa_continue(ctx, k, NO_Input{noa_env(ix(t), env), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, core_literal(t), u => noa_literal(ctx, t, env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Lam") || p88_string_eq(tag, "Mat"), u => noa_continue(ctx, k, NO_Input{kt(nt_choose(String, p88_string_eq(tag, "Lam"), v => "OL", v => "OM"), "", 0, 0, [t, kt("OEnv", "", 0, 0, env), kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ref"), u => nt_choose(NO_Analysis, U32.is_eq(qt(t), 3) || U32.is_eq(nd_arity(noa_book(ctx), nm(t)), 0), v => noa_fail("observer: bang or demanded zero-arity reference", n, fuel), v => noa_continue(ctx, k, NO_Input{kt("OR", nm(t), 0, 0, [kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "App"), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, NO_KAppFunction{kid(t, 1), env, stack, k}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ctr"), u => nt_choose(NO_Analysis, no_literal_demanding_ctor(nm(t)), v => noa_fail("observer: demanding scalar constructor", n, fuel), v => noa_eval_args(ctx, ks(t), env, facts, stack, Nil{}, n, fuel, NO_KConstructor{nm(t), k})), u =>
  nt_choose(NO_Analysis, nb_contains(["Ann", "Loc", "Src", "Cut", "Slf", "Ins"], tag), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Efq"), u => NO_Analysis{kt("NO_Error", "ERR_FIDS", 0, 0, Nil{}), n, fuel, ""}, u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Let") && U32.is_eq(terms_len(ks(t)), 2) && p98_tag_eq(kid(t, 0), "Bind"), u => noa_eval(ctx, kid(kid(t, 0), 0), env, facts, stack, n, fuel, NO_KLetBody{kid(t, 1), ix(kid(t, 0)), env, stack, k}), u => noa_fail("observer: unsupported evaluated core " ++ tag, n, fuel))))))))))

# Module: src/back/native/observer-analysis.bend:218
@unsafe
def noa_value_type(+ctx: NO_Context, +v: KTerm) -> String:
  nt_choose(String, p98_tag_eq(v, "OA"), u => nm(v), u => noa_ctor_type(noa_spec(nm(v), no_schema_specs(noa_schema(ctx)))))

# Module: src/back/native/observer-analysis.bend:222
@unsafe
def noa_ctor_type(spec: Maybe<&2, NO_Spec>) -> String:
  match spec:
    case None{}: ""
    case Some{NO_Spec{+layout, +owner, +fields}}: owner

# Module: src/back/native/observer-analysis.bend:228
@unsafe
def noa_scalar(+ctx: NO_Context, +v: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(v, "OA") && nol_scalar(noa_book(ctx), kt("ADT", nm(v), 0, 0, Nil{})), u => kid(v, 1), u =>
    nt_choose(KTerm, p98_tag_eq(v, "OC"), w => noa_scalar_ctor(ctx, v, noa_spec(nm(v), no_schema_specs(noa_schema(ctx)))), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/observer-analysis.bend:233
@unsafe
def noa_scalar_ctor(+ctx: NO_Context, +v: KTerm, spec: Maybe<&2, NO_Spec>) -> KTerm:
  match spec:
    case None{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}}:
      nt_choose(KTerm, p88_string_eq(storage, "Char") && U32.is_eq(terms_len(ks(v)), 1) && p88_string_eq(noa_value_type(ctx, kid(v, 0)), "U32"), u => noa_scalar(ctx, kid(v, 0)), u =>
        nt_choose(KTerm, p88_string_eq(storage, "Nullary") && List.is_empty(&2, KTerm, ks(v)) && nol_scalar(noa_book(ctx), kt("ADT", owner, 0, 0, Nil{})), w => kt("NCtr", ctor, 0, 0, Nil{}), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/observer-analysis.bend:241
@unsafe
def noa_scalars(+ctx: NO_Context, values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_scalar(ctx, h), noa_scalars(ctx, rest)}

# Module: src/back/native/observer-analysis.bend:247
@unsafe
def noa_no_absent(values: List<&2, KTerm>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{+h, +rest}: Bool.not(p98_tag_eq(h, "Absent")) && noa_no_absent(rest)

# Module: src/back/native/observer-analysis.bend:253
@unsafe
def noa_call_result(+ctx: NO_Context, +ty: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => noa_call_types(ctx, nq_layout_type(noa_book(ctx), ty), args, U32.sub(fuel, 1)))

# Module: src/back/native/observer-analysis.bend:257
@unsafe
def noa_call_types(+ctx: NO_Context, +head: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: nt_choose(KTerm, nol_scalar(noa_book(ctx), head), u => head, u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{+v, +rest}:
      +want = nq_layout_type(noa_book(ctx), kid(head, 0))
      nt_choose(KTerm, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && nol_scalar(noa_book(ctx), want) && p88_string_eq(noa_value_type(ctx, v), nm(want)), u => noa_call_result(ctx, kid(head, 1), rest, fuel), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/observer-analysis.bend:265
@unsafe
def noa_primitive(+ctx: NO_Context, +name: String, +args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +words = noa_scalars(ctx, args)
  +result = noa_call_result(ctx, dt(lookup(noa_book(ctx), name)), args, 8)
  +id = nc_id(n)
  nt_choose(NO_Analysis, noa_no_absent(words) && Bool.not(p98_tag_eq(result, "Absent")),
    u => noa_prepend(kt("NO_Let", "", id, 0, [kt("NOp", nc_primitive_name(name), 0, 0, words)]), noa_continue(ctx, k, NO_Input{noa_atom(nm(result), kt("OUnique", "", id, 0, Nil{}), var("", id)), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: scalar primitive type", n, fuel))

# Module: src/back/native/observer-analysis.bend:283
@unsafe
def noa_apply(ctx, fn, arg, facts, n, fuel, k):
  nt_choose(NO_Analysis, U32.is_eq(fuel, 0), u => noa_fail("observer: candidate budget", n, fuel), u => noa_apply_step(ctx, fn, arg, facts, n, U32.sub(fuel, 1), k))

# Module: src/back/native/observer-analysis.bend:287
@unsafe
def noa_apply_step(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OL"), u => noa_eval(ctx, kid(kid(fn, 0), 0), noa_bind(ix(kid(fn, 0)), arg, ks(kid(fn, 1))), facts, noa_unames(ks(kid(fn, 2))), n, fuel, k), u =>
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OM"), u => noa_match(ctx, fn, arg, facts, n, fuel, k), u =>
  nt_choose(NO_Analysis, p98_tag_eq(fn, "OR"), u => noa_reference(ctx, nm(fn), List.append(&2, KTerm, noa_tail(ks(fn)), [arg]), facts, noa_unames(ks(kid(fn, 0))), n, fuel, k), u => noa_fail("observer: dynamic application", n, fuel))))

# Module: src/back/native/observer-analysis.bend:293
@unsafe
def noa_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +arity = nd_arity(noa_book(ctx),name)
  +d = lookup(noa_book(ctx),name)
  nt_choose(NO_Analysis,U32.is_lt(terms_len(args),arity),u => noa_continue(ctx,k,NO_Input{kt("OR",name,0,0,Con{kt("OStack","",0,0,noa_names(stack)),args}),facts,n,fuel}),u =>
  nt_choose(NO_Analysis,U32.is_eq(terms_len(args),arity),u =>
  nt_choose(NO_Analysis,String.eq(name,noa_owner(ctx)),u => noa_recur(ctx,args,facts,n,fuel,k),u =>
  nt_choose(NO_Analysis,nt_choose(Bool,nc_native_def(d),v => nd_scalar_known(nc_primitive_name(name)),v => False{}),
    u => noa_primitive(ctx,name,args,facts,n,fuel,k),
    u => p128br_reference(ctx,name,args,facts,stack,n,fuel,k,p128br_lookup(name,p128br_helpers(ctx))))),u => noa_fail("observer: saturation",n,fuel)))

@unsafe
def noa_field_values(+owner: String, +ctor: String, +origin: KTerm, fields: List<&2, String>, +i: U32, +n: U32) -> List<&2, KTerm>:
  match fields:
    case Nil{}: Nil{}
    case Con{+ty, +rest}: Con{noa_atom(ty, kt("OField", ctor, i, 0, [origin, ref(owner)]), var("", nc_id(n))), noa_field_values(owner, ctor, origin, rest, U32.inc(i), U32.inc(n))}

# Module: src/back/native/observer-analysis.bend:311
@unsafe
def noa_origins(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_origin(h), noa_origins(rest)}

# Module: src/back/native/observer-analysis.bend:317
@unsafe
def noa_value_words(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{kid(h, 1), noa_value_words(rest)}

# Module: src/back/native/observer-analysis.bend:323
@unsafe
def noa_match(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn, 0)
  nt_choose(NO_Analysis, p98_tag_eq(arg, "OC"),
    u => nt_choose(NO_Analysis, p88_string_eq(nm(mat), nm(arg)),
      v => nt_choose(NO_Analysis, U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))), w => noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyArgs{ks(arg), k}), w => noa_fail("observer: virtual constructor arity", n, fuel)),
      v => noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyOne{arg, k})),
    u => noa_match_spec(ctx, fn, arg, facts, n, fuel, k, noa_spec(nm(mat), no_schema_specs(noa_schema(ctx)))))

# Module: src/back/native/observer-analysis.bend:332
@unsafe
def noa_match_spec(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont, spec: Maybe<&2, NO_Spec>) -> NO_Analysis:
  match spec:
    case None{}: noa_fail("observer: matcher representation", n, fuel)
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +types}}:
      nt_choose(NO_Analysis, p98_tag_eq(arg, "OA") && p88_string_eq(nm(arg), owner) && U32.is_eq(ix(kid(fn, 0)), U32.inc(width)),
        u => noa_match_fields(ctx, fn, arg, facts, key, noa_field_values(owner, ctor, noa_origin(arg), types, 0, n), U32.add(n, width), fuel, k), u => noa_fail("observer: matcher type or width", n, fuel))

# Module: src/back/native/observer-analysis.bend:340
@unsafe
def noa_match_fields(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +key: String, +fields: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn, 0)
  +yesfacts = {Con{kt("OFact", "", 0, 0, [noa_origin(arg), kt("OC", nm(mat), 0, 0, noa_origins(fields))]), facts}: List<&2, KTerm>}
  +yes = noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), yesfacts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyArgs{fields, k})
  nt_choose(NO_Analysis, p88_string_eq(noa_error(yes), ""),
    u => noa_match_join(key, kid(arg, 1), fields, yes, noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), noa_fresh(yes), noa_fuel(yes), NO_KApplyOne{arg, k})), u => yes)

# Module: src/back/native/observer-analysis.bend:348
@unsafe
def noa_match_join(key: String, word: KTerm, fields: List<&2, KTerm>, yes: NO_Analysis, +no: NO_Analysis) -> NO_Analysis:
  NO_Analysis{kt("NO_Match", key, 0, 0, [word, kt("NO_Fields", "", 0, 0, noa_value_words(fields)), noa_body(yes), noa_body(no)]), noa_fresh(no), noa_fuel(no), noa_error(no)}

# Module: src/back/native/observer-analysis.bend:352
@unsafe
def noa_tail(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{+x, +rest}: rest

# Module: src/back/native/observer-analysis.bend:358
@unsafe
def noa_entry_values(params: List<&2, KTerm>, +i: U32) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{noa_atom(nm(p), kt("OArg", "", i, 0, Nil{}), p), noa_entry_values(rest, U32.inc(i))}

# Module: src/back/native/observer-analysis.bend:364
@unsafe
def noa_param_origin(+id: U32, params: List<&2, KTerm>, +i: U32) -> KTerm:
  match params:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+p, +rest}: nt_choose(KTerm, U32.is_eq(ix(p), id), u => kt("OArg", "", i, 0, Nil{}), u => noa_param_origin(id, rest, U32.inc(i)))

# Module: src/back/native/observer-analysis.bend:377
@unsafe
def noa_finish_fields(+ctx: NO_Context, values: List<&2, KTerm>, templates: List<&2, KTerm>, +facts: List<&2, KTerm>) -> KTerm:
  match values, templates:
    case Nil{}, Nil{}: kt("OResult", "", 0, 0, Nil{})
    case Con{+v, +vs}, Con{+t, +ts}: noa_finish_merge(noa_finish_value(ctx, v, t, facts), noa_finish_fields(ctx, vs, ts, facts))
    case _, _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/back/native/observer-analysis.bend:384
@unsafe
def noa_finish_merge(+a: KTerm, +b: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(a, "OResult") && p98_tag_eq(b, "OResult"), u => kt("OResult", "", 0, 0, nt_append(KTerm, ks(a), ks(b))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/observer-analysis.bend:388
@unsafe
def noa_finish_value(ctx, value, template, facts):
  nt_choose(KTerm, p98_tag_eq(template, "Var"), u =>
    nt_choose(KTerm, U32.is_eq(ix(template), no_schema_result(noa_schema(ctx))),
      v => nt_choose(KTerm, p88_string_eq(noa_value_type(ctx, value), no_schema_observation(noa_schema(ctx))) && Bool.not(p98_tag_eq(noa_scalar(ctx, value), "Absent")), w => kt("OResult", "", 0, 0, [noa_scalar(ctx, value)]), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
      v => nt_choose(KTerm, noa_equal(value, noa_param_origin(ix(template), no_schema_params(noa_schema(ctx)), 0), facts), w => kt("OResult", "", 0, 0, Nil{}), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})), u =>
    nt_choose(KTerm, p98_tag_eq(template, "Ctr") && p98_tag_eq(value, "OC") && p88_string_eq(nm(template), nm(value)), v => noa_finish_fields(ctx, ks(value), ks(template), facts), v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/observer-analysis.bend:396
@unsafe
def noa_finish(+ctx: NO_Context, +input: NO_Input) -> NO_Analysis:
  +result = noa_finish_value(ctx, noa_iv(input), no_schema_wrapper(noa_schema(ctx)), noa_if(input))
  nt_choose(NO_Analysis, p98_tag_eq(result, "OResult") && U32.is_eq(terms_len(ks(result)), 1), u => NO_Analysis{kt("NO_Return", "", 0, 0, ks(result)), noa_in(input), noa_iu(input), ""}, u => noa_fail("observer: returned root or observation unproved", noa_in(input), noa_iu(input)))

# Module: src/back/native/observer-analysis.bend:401
@unsafe
def noa_below(+origin: KTerm, +want: KTerm) -> Bool:
  nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>
    nt_choose(Bool, p98_tag_eq(origin, "OField"), v => noa_below(kid(origin, 0), want), v => False{}))

# Module: src/back/native/observer-analysis.bend:405
@unsafe
def noa_root_param(+ctx: NO_Context, +p: KTerm) -> Bool:
  Bool.not(nol_scalar(noa_book(ctx), kt("ADT", nm(p), 0, 0, Nil{})))

# Module: src/back/native/observer-analysis.bend:409
@unsafe
def noa_loop_valid(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>, +i: U32, +strict: Bool) -> Bool:
  match params, args:
    case Nil{}, Nil{}: strict
    case Con{+p, +ps}, Con{+a, +rest}:
      nt_choose(Bool, noa_root_param(ctx, p),
        u => p98_tag_eq(a, "OA") && p88_string_eq(nm(a), nm(p)) && noa_below(noa_origin(a), kt("OArg", "", i, 0, Nil{})) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict || p98_tag_eq(noa_origin(a), "OField")),
        u => p88_string_eq(noa_value_type(ctx, a), nm(p)) && Bool.not(p98_tag_eq(noa_scalar(ctx, a), "Absent")) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict))
    case _, _: False{}

# Module: src/back/native/observer-analysis.bend:419
@unsafe
def noa_loop_words(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: Con{nt_choose(KTerm, noa_root_param(ctx, p), u => kid(a, 1), u => noa_scalar(ctx, a)), noa_loop_words(ctx, ps, rest)}
    case _, _: Nil{}

# Module: src/back/native/observer-analysis.bend:425
@unsafe
def noa_actuals(params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: noa_bind(ix(p), a, noa_actuals(ps, rest))
    case _, _: Nil{}

# Module: src/back/native/observer-analysis.bend:436
@unsafe
def noa_virtual_fields(ts: List<&2, KTerm>, +env: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_virtual(h, env), noa_virtual_fields(rest, env)}

# Module: src/back/native/observer-analysis.bend:442
@unsafe
def noa_virtual(t, env):
  nt_choose(KTerm, p98_tag_eq(t, "Var"), u => noa_env(ix(t), env), u => kt("OC", nm(t), 0, 0, noa_virtual_fields(ks(t), env)))

# Module: src/back/native/observer-analysis.bend:446
@unsafe
def noa_recur(ctx, args, facts, n, fuel, k):
  +schema = noa_schema(ctx)
  +params = no_schema_params(schema)
  +marker = var("", nc_id(n))
  +observation = noa_atom(no_schema_observation(schema), kt("ORecursive", "", nc_id(n), 0, Nil{}), marker)
  +env = noa_bind(no_schema_result(schema), observation, noa_actuals(params, args))
  nt_choose(NO_Analysis, noa_loop_valid(ctx, params, args, 0, False{}),
    u => noa_recur_done(ctx, args, marker, noa_continue(ctx, k, NO_Input{noa_virtual(no_schema_wrapper(schema), env), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: recursive cursor or scalar slot", n, fuel))

# Module: src/back/native/observer-analysis.bend:457
@unsafe
def noa_recur_done(+ctx: NO_Context, +args: List<&2, KTerm>, +marker: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}:
      nt_choose(NO_Analysis, p88_string_eq(error, "") && p98_tag_eq(body, "NO_Return") && U32.is_eq(terms_len(ks(body)), 1) && norm_exact(kid(body, 0), marker),
        u => NO_Analysis{kt("NO_Loop", "", 0, 0, noa_loop_words(ctx, no_schema_params(noa_schema(ctx)), args)), n, fuel, ""},
        u => noa_fail(nt_choose(String, p88_string_eq(error, ""), v => "observer: non-tail or discarded recursive result", v => error), n, fuel))

# Public query entry: permission must be supplied by the checked host path.
# It is deliberately not read from any user-controlled book definition.

# Module: src/back/native/observer-analysis.bend:467
@unsafe
def noa_analyze(+book: List<&2,KDef>, +name: String, +schema: NO_Schema, +permission: Bool) -> NO_Analysis:
  nt_choose(NO_Analysis,permission && String.is_empty(no_schema_error(schema)),
    u => noa_analyze_ready(NO_Context{book,name,schema,[]}),
    u => noa_fail("observer: absent checked permission or schema",no_schema_fresh(schema),4096))

@unsafe
def noa_analyze_ready(+ctx: NO_Context) -> NO_Analysis:
  +schema = noa_schema(ctx)
  +params = noa_entry_values(no_schema_params(schema), 0)
  +body = nc_source_body(noa_book(ctx), lookup(noa_book(ctx), noa_owner(ctx)), no_schema_fresh(schema))
  noa_eval(ctx, body, Nil{}, Nil{}, Nil{}, no_schema_fresh(schema), 4096, NO_KApplyArgs{params, NO_KFinish{}})

# Module: src/back/native/observer-analysis.bend:480
@unsafe
def noa_literal(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +lit = no_literal_typed(noa_book(ctx), t)
  +step = no_literal_string_step(noa_book(ctx), t)
  nt_choose(NO_Analysis, p98_tag_eq(lit, "NO_TypedWord"), u => noa_continue(ctx, k, NO_Input{noa_atom(nm(lit), kt("OConst", nm(lit), ix(lit), 0, Nil{}), kid(lit, 0)), facts, n, fuel}), u =>
    nt_choose(NO_Analysis, p98_tag_eq(step, "Absent"), v => noa_fail("observer: unsupported literal", n, fuel), v => noa_eval(ctx, step, env, facts, stack, n, fuel, k)))

# Module: src/back/native/observer-analysis.bend:487
@unsafe
def noa_constructor(+ctx: NO_Context, +name: String, +input: NO_Input, +k: NO_Cont) -> NO_Analysis:
  +args = ks(noa_iv(input))
  +valid = Bool.not(p88_string_eq(name, "Chr")) || (U32.is_eq(terms_len(args), 1) && p88_string_eq(noa_value_type(ctx, terms_at(args, 0)), "U32"))
  nt_choose(NO_Analysis, valid, u => noa_continue(ctx, k, NO_Input{kt("OC", name, 0, 0, args), noa_if(input), noa_in(input), noa_iu(input)}), u => noa_fail("observer: Char constructor type", noa_in(input), noa_iu(input)))

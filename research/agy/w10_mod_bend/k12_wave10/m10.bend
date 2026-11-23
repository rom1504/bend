# Module m10 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=600 laws=80 sccs=191 deps=[m00,m01,m02,m03,m04,m05,m06,m07,m08,m09] cross_imports=650 fid_base=51200..56319

law check_ctors:
  for +e: KEnv
  for +d: KDef
  for +ctrs: List<&2, KDef>
  for +kind: KTerm
  KChecking

# Module: src/check/kernel.bend:354
law check_ctors_next:
  for +e: KEnv
  for +d: KDef
  for +rest: List<&2, KDef>
  for +kind: KTerm
  for +err: KChecking
  KChecking

# Module: src/check/kernel.bend:362
law check_ctor_tel:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:373
law check_ctor_head:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:384
law check_ctor_domain:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:396
law f_args:
  for +ts: FInput
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/parser.bend:12
law f_arg_next:
  for +p: FParsed
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/parser.bend:18
law f_expr:
  for +ts: FInput
  for +min: U32
  FParsed

# Module: src/front/parser.bend:23
law f_atom:
  for +ts: FInput
  FParsed

# Module: src/front/parser.bend:27
law f_grade:
  for +ts: FInput
  FParsed

# Module: src/front/parser.bend:44
law f_all:
  for +ts: FInput
  for +exi: Bool
  FParsed

# Module: src/front/parser.bend:49
law f_all_domain:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:57
law f_group:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:70
law f_brace:
  for +ts: FInput
  FParsed

# Module: src/front/parser.bend:83
law f_brace_left:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:87
law f_equation:
  for +a: KTerm
  for +neg: Bool
  for +opBegin: U32
  for +opEnd: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:95
law f_grow:
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/parser.bend:109
law f_grow_args:
  for +n: KTerm
  for +op: String
  for +min: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:116
law f_matcher:
  for +ts: FInput
  FParsed

# Module: src/front/parser.bend:124
law f_matcher_head:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:128
law f_matcher_arm:
  for +name: String
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:133
law f_atom_name:
  for +ts: FInput
  FParsed

# Module: src/front/parser.bend:246
law f_atom_nat_start:
  for +ts: FInput
  for +lit: KTerm
  FParsed

# Module: src/front/parser.bend:250
law f_rhs:
  for +ts: FInput
  for +op: String
  for +min: U32
  FParsed

# Module: src/front/parser.bend:519
law f_tele:
  for +ts0: FInput
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:39
law f_tele_at:
  for +ts: FInput
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:45
law f_tele_type:
  for +binder: KTerm
  for +temp: Bool
  for +p: FParsed
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:71
law f_body:
  for +ts: FInput
  FParsed

# Module: src/front/declarations.bend:184
law f_statement:
  for +p: FParsed
  for +begin: U32
  for +column: U32
  FParsed

# Module: src/front/declarations.bend:190
law f_let_value:
  for +pat: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:195
law f_match_heads:
  for +ts: FInput
  for +indent: U32
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:201
law f_match_head:
  for +p: FParsed
  for +indent: U32
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:207
law f_case_pats:
  for +ts: FInput
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  for +start: FInput
  FParsed

# Module: src/front/declarations.bend:216
law f_case_pat:
  for +p: FParsed
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  for +start: FInput
  FParsed

# Module: src/front/declarations.bend:225
law f_case_body:
  for +p: FParsed
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:303
law f_body_context:
  for +ts: FInput
  for +outer: U32
  FParsed

# Module: src/front/declarations.bend:605
law f_body_context_at:
  for +ts: FInput
  for +outer: U32
  FParsed

# Module: src/front/declarations.bend:610
law f_match_begin:
  for +ts: FInput
  for +outer: U32
  for +heads: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:632
law f_erased_local:
  for +ts: FInput
  for +begin: U32
  for +column: U32
  FParsed

# Module: src/front/sugar.bend:289
law f_array:
  for +ts: FInput
  FParsed

# Module: src/front/literals_arrays.bend:20
law f_array_first:
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:24
law f_array_type:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:29
law f_index:
  for +n: KTerm
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:47
law f_index_value:
  for +n: KTerm
  for +idx: KTerm
  for +end: U32
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:55
law f_parallel_pat:
  for +p: FParsed
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:8
law f_parallel_values:
  for +ts: FInput
  for +pats: List<&2, KTerm>
  for +left: U32
  for +vals: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:15
law f_parallel_value:
  for +p: FParsed
  for +pats: List<&2, KTerm>
  for +left: U32
  for +vals: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:22
law f_statement_more:
  for +p: FParsed
  FParsed

# Module: src/front/parallel.bend:42
law f_typed_let_try:
  for +n: KTerm
  for +old: FInput
  for +p: FParsed
  for +begin: U32
  FParsed

# Module: src/front/fresh_work.bend:12
law f_validate_param:
  for +ts: FInput
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/validate.bend:136
law f_bang:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  FParsed

# Module: src/front/validate.bend:194
law fpe_source_render:
  for +legacy: String
  for +error: KTerm
  for +source: KTerm
  String

# Module: src/load/seed.bend:9
@unsafe
def w7_br_196(w7_c: Bool, +d: KDef, +e: KEnv, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_foreign(rw(r), d, cd(e))
    case False{}:
      check_definition_body(rw(r), d, cd(e))

@unsafe
def w7_br_197(w7_c: Bool, +d: KDef, +e: KEnv, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      r
    case False{}:
      w7_br_196(p98_tag_eq(dv(d), "Foreign"), d, e, r)

@unsafe
def w7_br_203(w7_c: Bool, +e: KEnv, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      check_ctors(e, d, dc(d), dt(d))
    case False{}:
      check_adt_kind(e, d, dt(d), Nil{})

@unsafe
def check_adt_kind(+e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, check_adt_kind_head(e, d, wnf(cb(e), tel), ctx))

# Module: src/check/kernel.bend:1049
@unsafe
def w7_br_204(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  match w7_c:
    case True{}:
      check_ctors(e, d, dc(d), dt(d))
    case False{}:
      dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), "datatype declaration must return a kind", dg_text("a kind (type " ++ name_key(dn(d)) ++ "<..> is Kind(g))"), tel))

@unsafe
def w7_br_205(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  match w7_c:
    case True{}:
      check_adt_kind(e, d, kid(tel, 1), ctx_bind(ctx, ix(tel), qt(tel), nm(tel), kid(tel, 0)))
    case False{}:
      w7_br_204(p98_tag_eq(tel, "Typ"), e, d, tel, ctx)

@unsafe
def check_adt_kind_head(+e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  w7_br_205(p98_tag_eq(tel, "All"), e, d, tel, ctx)

# Module: src/check/kernel.bend:1053
@unsafe
def check_ctors(e, d, ctrs, kind):
  match ctrs:
    case Nil{}:
      bad(cw(e), "")
    case Con{h, t}:
      check_ctors_next(e, d, t, kind, check_ctor_tel(KEnv{cw(e), dn(h), ref(dn(h)), 0, Nil{}, cu(e), cd(e)}, d, dt(h), kind, da(d), da(h), Nil{}, Nil{}))

# Module: src/check/kernel.bend:1061
@unsafe
def w7_br_206(w7_c: Bool, +e: KEnv, +d: KDef, +rest: List<&2, KDef>, +kind: KTerm, +err: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_ctors(ke_world(e, rw(err)), d, rest, kind)
    case False{}:
      err

@unsafe
def check_ctors_next(e, d, rest, kind, err):
  w7_br_206(good(err), e, d, rest, kind, err)

# Module: src/check/kernel.bend:1065
@unsafe
def w7_br_208(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +kind: KTerm, +params: U32, +fields: U32, +ctx: List<&2, KTerm>, +args: List<&2, KTerm>) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_207(compare(cb(e), tel, kt("ADT", dn(d), 0, 0, args), False{}), e, d, tel, ctx)
    case False{}:
      check_ctor_head(e, d, wnf(cb(e), tel), kind, params, fields, ctx, args)

@unsafe
def check_ctor_tel(e, d, tel, kind, params, fields, ctx, args):
  w7_br_208(U32.is_eq(U32.add(params, fields), 0), e, d, tel, kind, params, fields, ctx, args)

# Module: src/check/kernel.bend:1069
@unsafe
def w7_br_209(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +kind: KTerm, +params: U32, +fields: U32, +ctx: List<&2, KTerm>, +args: List<&2, KTerm>) -> KChecking:
  match w7_c:
    case True{}:
      check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, check(e, ctx, kid(tel, 0), 0, kc(KTerm, U32.is_eq(params, 0) && U32.is_eq(qt(tel), 1), u => kind, u => typ(qt(tel)))))
    case False{}:
      bad(cw(e), "constructor telescope missing a binder")

@unsafe
def check_ctor_head(e, d, tel, kind, params, fields, ctx, args):
  w7_br_209(p98_tag_eq(tel, "All"), e, d, tel, kind, params, fields, ctx, args)

# Module: src/check/kernel.bend:1073
@unsafe
def w7_br_210(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +kind: KTerm, +params: U32, +fields: U32, +ctx: List<&2, KTerm>, +args: List<&2, KTerm>, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_ctor_tel(ke_world(e, rw(r)), d, kid(tel, 1), kc(KTerm, U32.is_eq(params, 0), u => kind, u => subst(kid(wnf(kw_book(rw(r)), kind), 1), ix(wnf(kw_book(rw(r)), kind)), var(nm(tel), ix(tel)))), kc(U32, U32.is_eq(params, 0), u => 0, u => U32.sub(params, 1)), kc(U32, U32.is_eq(params, 0), u => U32.sub(fields, 1), u => fields), ctx_bind(ctx, ix(tel), qt(tel), nm(tel), kid(tel, 0)), kc(List<&2, KTerm>, U32.is_eq(params, 0), u => args, u => norm_join(args, Con{var(nm(tel), ix(tel)), Nil{}})))
    case False{}:
      r

@unsafe
def check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, r):
  w7_br_210(good(r), e, d, tel, kind, params, fields, ctx, args, r)

# Module: src/check/kernel.bend:1077
@unsafe
def f_context_grow(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => p, u => f_grow_existing(p, min))

# Module: src/front/contextual.bend:82
@unsafe
def f_context_let(+pattern: KTerm, +value: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +spaced = f_space(input)
          +semi = p88_string_eq(f_tx(spaced), ";")
          f_context_let_open(value, env, f_context_pattern(pattern, f_choose(FInput, semi, u => f_tl(spaced), u => spaced), f_choose(U32, semi, u => f_end(spaced), u => f_begin(spaced))))

# Module: src/front/contextual.bend:138
@unsafe
def f_context_let_open(+value: KTerm, +outer: List<&2,KTerm>, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{pattern, input}:
      f_choose(FParsed, f_context_stop(pattern), u => opened, u => f_context_let_done(pattern, value, outer, f_body(input)))

# Module: src/front/contextual.bend:144
@unsafe
def f_context_case(+input: FInput, +indent: U32, +heads: List<&2,KTerm>, +rows: List<&2,KTerm>, +patterns: List<&2,KTerm>) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_context_case_open(indent, heads, rows, env, f_context_patterns(kt("Patterns", "", 0, 1, Nil{}), patterns, f_tl(input), f_end(input), Nil{}))

# Module: src/front/contextual.bend:201
@unsafe
def f_context_case_open(+indent: U32, +heads: List<&2,KTerm>, +rows: List<&2,KTerm>, +outer: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{patterns, rest}: f_choose(FParsed, f_context_stop(patterns), u => parsed, u => f_case_body(f_context_close_done(f_body_context(rest, U32.add(indent, 1)), outer), indent, heads, rows, ks(patterns)))

# Module: src/front/contextual.bend:206
@unsafe
def f_context_group_done(+parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_choose(FParsed, f_eq(f_tx(rest), ":"), u => f_group_namespace(term, f_expr(f_tl(rest), 0)), u => f_expect(parsed, ")")))

# Module: src/front/contextual.bend:230
@unsafe
def f_context_definition(+name: String, +pars: List<&2,KTerm>, +ty: KTerm, +p: FParsed, +scope: FParseScope) -> FParsed:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      f_context_definition_start(pars, ty, p, f_context_declare(KDef{name, "Def", terms_len(pars), f_choose(U32, f_def_fillable(f_decl_prior(name, scope)), u => dx(f_decl_prior(name, scope)), u => f_templates(pars)), ty, atom("Absent"), Nil{}, False{}, False{}}, scope))

# Module: src/front/contextual.bend:278

@unsafe
def f_context_definition_start(+pars: List<&2,KTerm>, +ty: KTerm, +p: FParsed, +scope: FParseScope) -> FParsed:
  match p:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => p,
        u => f_context_definition_input(pars, ty, rest, scope))

# Module: src/front/contextual.bend:285
@unsafe
def f_context_definition_input(+pars: List<&2,KTerm>, +ty: KTerm, +input: FInput, +scope: FParseScope) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{old, env, next}:
          +variables = f_vars(pars)
          f_context_definition_done(f_context_flat(f_body(FInput{tokens, FParseContext{scope, env, next}}), variables))

# Module: src/front/contextual.bend:294
@unsafe
def f_context_tele(+binder: KTerm, +temp: Bool, +ty: KTerm, +end: String, +acc: List<&2,KTerm>, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{bound, input}:
      f_tele(f_choose(FInput, f_eq(f_tx(input), ","), u => f_tl(input), u => input), end, Con{kt_span(f_choose(String, temp, u => "Template", u => "Bind"), nm(bound), ix(bound), qt(binder), [ty], kb(binder), ke(binder)), acc})

# Module: src/front/contextual.bend:317
@unsafe
def f_binary_start(+term: KTerm, +input: FInput, +min: U32) -> FParsed:
  +op = f_tx(input)
  f_choose(FParsed, f_eq(op, "=>"),
    u => f_context_lambda(term, f_tl(input), min, f_end(input)),
    u => f_context_binary(term, op, f_begin(input), f_end(input), min, f_rhs(f_tl(input), op, f_choose(U32, f_eq(op, "=>") || f_eq(op, "->") || f_eq(op, "<>") || f_eq(op, "&") || f_eq(op, "|"), u => U32.sub(f_prec(op), 1), u => f_prec(op)))))

# Module: src/front/contextual.bend:343
@unsafe
def f_context_lambda(+term: KTerm, +input: FInput, +min: U32, +cursor: U32) -> FParsed:
  +syntax = f_context_syntax(term)
  f_choose(FParsed, f_eq(tg(syntax), "Var"),
    u => f_context_lambda_open(f_context_outer(input), min, f_context_open(syntax, input)),
    u => f_context_error_at(fpe_point_at(k_with_span(term, cursor, cursor), "a lambda binder must be a non-reserved name", "a lambda binder (one name: k => body)"), input, cursor))

# Module: src/front/contextual.bend:350
@unsafe
def f_context_lambda_open(+outer: List<&2,KTerm>, +min: U32, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{binder, input}:
      f_grow(f_context_close_done(f_context_flat(f_body(input), [binder]), outer), min)

# Module: src/front/contextual.bend:356
@unsafe
def f_context_all(+name: String, +q: U32, +exi: Bool, +domain: KTerm, +input: FInput) -> FParsed:
  f_context_all_open(q, exi, domain, f_context_outer(input), f_context_open(kt("Var", name, 0, q, Nil{}), input))

# Module: src/front/contextual.bend:360
@unsafe
def f_context_all_open(+q: U32, +exi: Bool, +domain: KTerm, +outer: List<&2,KTerm>, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{binder, input}:
      f_context_close_done(f_all_body(nm(binder), ix(binder), q, exi, domain, f_expr(input, 0)), outer)

# Module: src/front/contextual.bend:366
@unsafe
def f_context_binary(+a: KTerm, +op: String, +opBegin: U32, +opEnd: U32, +min: U32, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{b, input}:
      f_choose(FParsed, f_context_stop(b), u => parsed,
          u => f_choose(FParsed, f_eq(op, "->"),
            u => f_context_arrow(a, b, min, f_context_open(kt("Var", "_", 0, 1, Nil{}), input)),
            u => f_choose(FParsed, f_eq(op, "<"), u => f_context_less(a, b, opBegin, opEnd, min, input),
              u => f_grow(FParsed{f_binary_plain(a, op, b, opBegin, opEnd, kb(a), f_begin(f_space(input)), input), input}, min))))

# Module: src/front/contextual.bend:376
@unsafe
def f_context_arrow(+a: KTerm, +b: KTerm, +min: U32, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{binder, input}: f_grow(FParsed{kt_span("All", "_", ix(binder), 1, [a, b], kb(a), f_begin(f_space(input))), input}, min)

# Module: src/front/contextual.bend:381
@unsafe
def f_context_call(+term: KTerm, +input: FInput, +min: U32) -> FParsed:
  +head = f_context_call_head(term)
  f_choose(FParsed, f_eq(f_tx(input), "("),
      u => f_context_call_input(head, f_tl(input), min),
      u => f_context_family(head, min, f_family_first(f_space(f_tl(input)))))

# Module: src/front/contextual.bend:388
@unsafe
def f_context_call_input(+head: KTerm, +input: FInput, +min: U32) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              +count = f_choose(U32, f_eq(tg(head), "Ref"), u => dx(index_find(index, nm(head), index_hash(nm(head), 2166136261), 32)), u => 0)
              f_grow_args(head, "(", min, f_context_templates(head, f_space(input), count, count, Nil{}))

# Module: src/front/contextual.bend:399

@unsafe
def w7_br_308(w7_c: Bool, +head: KTerm, +input: FInput, +count: U32, +left: U32, +acc: List<&2,KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(input, "too many template arguments", "a term (" ++ name_key(nm(head)) ++ " takes " ++ U32.show(count) ++ " ~)")
    case False{}:
      f_context_template_next(head, count, U32.sub(left, 1), acc, f_expr(f_tl(input), 0))

@unsafe
def w7_br_309(w7_c: Bool, +head: KTerm, +input: FInput, +count: U32, +left: U32, +acc: List<&2,KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      w7_br_308(U32.is_eq(left, 0), head, input, count, left, acc)
    case False{}:
      f_args(input, ")", acc)

@unsafe
def f_context_templates(+head: KTerm, +input: FInput, +count: U32, +left: U32, +acc: List<&2,KTerm>) -> FParsed:
  w7_br_309(U32.is_gt(count, 0) && f_eq(f_tx(input), "~"), head, input, count, left, acc)

# Module: src/front/contextual.bend:407
@unsafe
def f_context_template_next(+head: KTerm, +count: U32, +left: U32, +acc: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, input}:
      +spaced = f_space(input)
      f_choose(FParsed, f_context_stop(term), u => parsed,
        u => f_context_templates(head, f_space(f_choose(FInput, f_eq(f_tx(spaced), ","), u => f_tl(spaced), u => spaced)), count, left, Con{term, acc}))

# Module: src/front/contextual.bend:415
@unsafe
def f_context_family(+head: KTerm, +min: U32, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{args, input}:
      f_choose(FParsed, f_context_stop(args), u => parsed, u => f_context_family_input(head, min, args, input))

# Module: src/front/contextual.bend:421
@unsafe
def f_context_family_input(+head: KTerm, +min: U32, +args: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              f_grow(FParsed{f_adt(kt_span("ADT", nm(head), ix(head), qt(head), ks(args), kb(head), ke(args)), ks(args), p144p_find(nm(head), prior, p144p_view)), input}, min)

# Module: src/front/contextual.bend:431

@unsafe
def f_context_named_pattern(+term: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  w7_br_310(f_eq(tg(f_context_syntax(term)), "Var"), term, input, cursor)

# Module: src/front/contextual.bend:436
@unsafe
def f_context_typed_value(+pattern: KTerm, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{value, input}:
      +spaced = f_space(input)
      +rest = f_choose(FInput, f_eq(f_tx(spaced), ";"), u => f_tl(spaced), u => spaced)
      f_choose(FParsed, f_context_stop(value), u => parsed,
        u => f_context_let_open(value, f_context_outer(input), f_context_named_pattern(pattern, rest, f_previous_end(rest))))

# Module: src/front/contextual.bend:445
@unsafe
def f_context_parallel(+patterns: List<&2,KTerm>, +values: List<&2,KTerm>, +input: FInput) -> FParsed:
  +spaced = f_space(input)
  +rest = f_choose(FInput, f_eq(f_tx(spaced), ";"), u => f_tl(spaced), u => spaced)
  f_context_parallel_open(patterns, values, rest, f_context_outer(input), f_begin(f_space(rest)), Nil{})

# Module: src/front/contextual.bend:451
@unsafe
def f_context_parallel_open(+patterns: List<&2,KTerm>, +values: List<&2,KTerm>, +input: FInput, +outer: List<&2,KTerm>, +cursor: U32, +acc: List<&2,KTerm>) -> FParsed:
  match patterns:
    case Nil{}: f_parallel_body(List.reverse(&2,KTerm,acc), values, f_context_close_done(f_body(input), outer))
    case Con{pattern, rest}: f_context_parallel_next(rest, values, outer, cursor, acc, f_context_named_pattern(pattern, input, cursor))

# Module: src/front/contextual.bend:457
@unsafe
def f_context_parallel_next(+patterns: List<&2,KTerm>, +values: List<&2,KTerm>, +outer: List<&2,KTerm>, +cursor: U32, +acc: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{pattern, input}: f_choose(FParsed, f_context_stop(pattern), u => parsed, u => f_context_parallel_open(patterns, values, input, outer, cursor, Con{pattern, acc}))

# Completed roots cross the existing loader boundary without a second scope walk.

# Module: src/front/contextual.bend:463
@unsafe
def w7_br_314(w7_c: Bool, +term: KTerm, +input: FInput, +column: U32, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_statement_more(FParsed{term, input})
    case False{}:
      f_context_write_more(term, input, column, f_context_write(term, begin, input))

@unsafe
def f_context_statement_more(+term: KTerm, +input: FInput, +column: U32, +begin: U32) -> FParsed:
  w7_br_314(f_binding_head(input), term, input, column, begin)

# Module: src/front/contextual.bend:536
@unsafe
def f_context_write_more(+term: KTerm, +input: FInput, +column: U32, +binder: KTerm) -> FParsed:
  +spaced = f_space(input)
  f_choose(FParsed, Bool.not(f_eq(tg(binder), "Absent")) && (f_eq(f_tx(spaced), ";") || (Bool.not(f_eq(f_tx(spaced), "<eof>")) && U32.is_eq(f_col(spaced), column))),
    u => f_context_let(binder, term, input), u => FParsed{term, input})

# Module: src/front/contextual.bend:542
@unsafe
def f_context_less(+head: KTerm, +first: KTerm, +opBegin: U32, +opEnd: U32, +min: U32, +input: FInput) -> FParsed:
  +spaced = f_space(input)
  +token = f_tx(spaced)
  f_choose(FParsed, U32.is_eq(ke(head), opBegin) && (f_eq(token, "&") || f_eq(token, "|") || f_eq(token, "->")),
    u => fpe_error(spaced, "a compound type argument takes parentheses", "'>' or ',' (a compound type argument takes parens: F<(A & B)>)"),
    u => f_choose(FParsed, f_eq(token, ">") || f_eq(token, ">>") || f_eq(token, ","),
      u => f_choose(FParsed, f_eq(tg(f_context_syntax(head)), "Var") || f_eq(tg(head), "Ref"),
        u => f_context_family(f_context_call_head(head), min, f_family_range(f_args(f_choose(FInput, f_eq(token, ","), u => f_tl(spaced), u => spaced), ">", [first]), f_begin(spaced))),
        u => fpe_error(spaced, "expected a family name", "a family name before <..> (a comparison here needs parens)")),
      u => f_grow(FParsed{f_binary_plain(head, "<", first, opBegin, opEnd, kb(head), f_begin(spaced), input), input}, min)))

# Module: src/front/contextual.bend:554
@unsafe
def f_args_base(
  +ts: FInput,
  +end: String,
  +acc: List<&2, KTerm>,
) -> FParsed:
  +spaced = f_space(ts)
  f_choose(FParsed, f_eq(f_tx(spaced), ";"), u => fpe_error(spaced, f_choose(String, f_eq(end, "]"), u => "expected term; a list does not use semicolon separators", u => "expected term; arguments do not use semicolon separators"), "a term"), u => f_choose(FParsed, f_eq(f_tx(spaced), end), u => FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), f_tl(spaced)}, u => f_arg_next(f_expr(spaced, 0), end, acc)))

# Module: src/front/parser.bend:198
@unsafe
def f_arg_next(p, end, acc):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_args(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), end, Con{n, acc}))

# Module: src/front/parser.bend:204
@unsafe
def f_expr(ts, min):
  f_grow(f_atom(f_skip(ts)), min)

# Module: src/front/parser.bend:208
@unsafe
def w7_atom_ident_ok(isId: Bool, +ts: FInput) -> FParsed:
  match isId:
    case True{}:
      f_atom_name(ts)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_word_res(isRes: Bool, +word: String, +ts: FInput) -> FParsed:
  match isRes:
    case True{}:
      w7_atom_ret_err(f_eq(word, "return"), ts)
    case False{}:
      w7_atom_ident_ok(f_ascii_alpha(f_head(word)) || f_ascii_digit(f_head(word)) || Char.is_eq(f_head(word), '_'), ts)

@unsafe
def w7_atom_is_type(isT: Bool, +ts: FInput) -> FParsed:
  match isT:
    case True{}:
      FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, 1, Nil{})]), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_data(isD: Bool, +ts: FInput) -> FParsed:
  match isD:
    case True{}:
      FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, 2, Nil{})]), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_quant(isQ: Bool, +ts: FInput) -> FParsed:
  match isQ:
    case True{}:
      FParsed{kt("Qnt", "", 0, 0, Nil{}), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_kind(isK: Bool, +ts: FInput) -> FParsed:
  match isK:
    case True{}:
      f_kind_wrap(f_expect(f_expr(f_tl(f_tl(ts)), 0), ")"))
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_word_c0(c0: U32, +word: String, +ts: FInput) -> FParsed:
  match c0:
    case 84:
      w7_atom_is_type(f_eq(word, "Type"), ts)
    case 68:
      w7_atom_is_data(f_eq(word, "Data"), ts)
    case 81:
      w7_atom_is_quant(f_eq(word, "Quant"), ts)
    case 75:
      w7_atom_is_kind(f_eq(word, "Kind"), ts)
    case _:
      w7_atom_word_res(f_reserved(word), word, ts)

@unsafe
def w7_atom_bslash(isLbr: Bool, +ts: FInput) -> FParsed:
  match isLbr:
    case True{}:
      f_matcher(f_tl(f_tl(ts)))
    case False{}:
      fpe_error(f_tl(ts), "expected {", "'{'")

@unsafe
def w7_atom_plus1(isP: Bool, +ts: FInput) -> FParsed:
  match isP:
    case True{}:
      f_mark(f_expr(f_tl(ts), 12), 2)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_plus(isPP: Bool, +word: String, +ts: FInput) -> FParsed:
  match isPP:
    case True{}:
      f_atom_base(f_prepend(FToken{"+", f_line(ts), f_col(ts), 0, f_begin(ts), f_cursor_add(f_begin(ts), 1), f_previous_end(ts)}, f_prepend(FToken{"+", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts))))
    case False{}:
      w7_atom_plus1(f_eq(word, "+") || f_eq(word, "+bind"), ts)

@unsafe
def w7_atom_lp(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_group(f_body(f_tl(ts)))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_lb(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_brace(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_ls(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_array(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_at(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_all(f_tl(ts), False{})
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_amp(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_grade(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_bslash_chk(isBs: Bool, +ts: FInput) -> FParsed:
  match isBs:
    case True{}:
      w7_atom_bslash(f_eq(f_tx(f_tl(ts)), "{"), ts)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_punct_c0(c0: U32, +word: String, +ts: FInput) -> FParsed:
  match c0:
    case 40:
      w7_atom_lp(f_eq(word, "("), ts)
    case 123:
      w7_atom_lb(f_eq(word, "{"), ts)
    case 91:
      w7_atom_ls(f_eq(word, "["), ts)
    case 64:
      w7_atom_at(f_eq(word, "@"), ts)
    case 38:
      w7_atom_amp(f_eq(word, "&"), ts)
    case 43:
      w7_atom_plus(f_eq(word, "++"), word, ts)
    case 63:
      w7_atom_q(f_eq(word, "?"), ts)
    case 92:
      w7_atom_bslash_chk(f_eq(word, "\\"), ts)
    case _:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_kind(kind: U32, +word: String, +ts: FInput) -> FParsed:
  match kind:
    case 1:
      w7_atom_word_c0(w7_char0(word), word, ts)
    case 2:
      FParsed{kt("Literal", word, 0, 1, Nil{}), f_tl(ts)}
    case _:
      w7_atom_punct_c0(w7_char0(word), word, ts)

@unsafe
def w7_grow_base_err(isErr: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match isErr:
    case True{}:
      FParsed{n, ts}
    case False{}:
      p175p_grow_word(n, ts, min, f_tx(ts))

@unsafe
def w7_grow_ex_nl(isNl: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match isNl:
    case True{}:
      p175p_grow_newline(n, ts, min, f_skip(ts))
    case False{}:
      p175p_grow_suffix(n, ts, min, word)

@unsafe
def f_atom_base(
  +ts: FInput,
) -> FParsed:
  w7_atom_kind(f_kind_token(ts), f_tx(ts), ts)

# A constructor brace belongs to the raw name only when lexically adjacent.
# General term growth must not absorb the next independent braced value.

# Module: src/front/parser.bend:234
@unsafe
def w7_br_315(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_atom_nat_start(ts, f_literal(f_tx(ts)))
    case False{}:
      FParsed{kt("Literal", f_tx(ts), f_atid(ts), 1, Nil{}), f_tl(ts)}

@unsafe
def w7_br_316(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_atom_constructor(f_tx(ts), f_atid(ts), f_args(f_tl(f_tl(ts)), "}", Nil{}))
    case False{}:
      f_context_atom_name(ts)

@unsafe
def w7_br_317(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(ts, "invalid name", "a name (words joined by dots, got '" ++ f_tx(ts) ++ "')")
    case False{}:
      w7_br_316(f_eq(f_tx(f_tl(ts)), "{") && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts))))), ts)

@unsafe
def w7_br_318(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      w7_br_315(String.ends_with(f_tx(ts), "n") && f_eq(f_tx(f_tl(ts)), "+") && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts))))), ts)
    case False{}:
      w7_br_317(Bool.not(f_valid_name(f_tx(ts))), ts)

@unsafe
def f_atom_name(ts):
  w7_br_318(Char.is_digit(f_head(f_tx(ts))), ts)

# Immediate n+ is part of the numeric atom, at every surrounding precedence.

# Module: src/front/parser.bend:256
@unsafe
def w7_br_319(w7_c: Bool, +ts: FInput, +lit: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{lit, f_empty(ts)}
    case False{}:
      f_atom_nat_plus(lit, f_expr(f_tl(f_tl(ts)), 0))

@unsafe
def f_atom_nat_start(ts, lit):
  w7_br_319(f_eq(tg(lit), "Error"), ts, lit)

# Module: src/front/parser.bend:260
@unsafe
def w7_br_320(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "0"), u => 0, u => f_choose(U32, f_eq(f_tx(ts), "1"), u => 1, u => 2)), Nil{}), f_tl(ts)}
    case False{}:
      f_all(ts, True{})

@unsafe
def f_grade(ts):
  w7_br_320(f_eq(f_tx(ts), "0") || f_eq(f_tx(ts), "1") || f_eq(f_tx(ts), "2"), ts)

# Module: src/front/parser.bend:296
@unsafe
def w7_br_324(w7_c: Bool, +ts: FInput, +exi: Bool) -> FParsed:
  match w7_c:
    case True{}:
      fpe_name_error(f_choose(FInput, f_eq(f_tx(ts), "~"), u => ts, u => f_unmark(ts)))
    case False{}:
      f_all_domain(f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), exi, f_expect(f_expr_after(f_expect(FParsed{atom("Absent"), f_tl(f_unmark(ts))}, ":"), 1), "->"))

@unsafe
def f_all(ts, exi):
  w7_br_324(Bool.not(f_valid_name(f_tx(f_unmark(ts)))) || f_eq(f_tx(ts), "~"), ts, exi)

# Module: src/front/parser.bend:312
@unsafe
def f_all_domain(name, id, q, exi, p):
  match p:
    case FParsed{a, ts}:
      f_choose(FParsed, f_eq(tg(a), "Error"), u => FParsed{a, ts}, u => f_context_all(name, q, exi, a, ts))

# Module: src/front/parser.bend:318
@unsafe
def f_group(p):
  match p:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => p, u => f_choose(FParsed, p88_string_eq(f_tx(rest), ",") && Bool.not(p98_tag_eq(term, "Local") || p98_tag_eq(term, "Parallel") || p98_tag_eq(term, "Match")), u => f_group_existing(p), u => f_context_group_done(f_context_flat(p, Nil{}))))

# Module: src/front/parser.bend:330
@unsafe
def f_group_existing(+p: FParsed) -> FParsed:
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ","), u => f_tuple(n, f_group(f_body(f_tl(ts)))), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_group_namespace(n, f_expect(f_expr(f_tl(ts), 0), ")")), u => f_expect(FParsed{n, ts}, ")")))

# Module: src/front/parser.bend:336
@unsafe
def w7_br_325(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_expect(FParsed{kt("Rfl", "", 0, 1, Nil{}), f_tl(ts)}, "}")
    case False{}:
      f_brace_left(f_expr(ts, 0))

@unsafe
def f_brace(ts):
  w7_br_325(f_eq(f_tx(ts), "=="), ts)

# Module: src/front/parser.bend:371
@unsafe
def f_brace_left(p):
  match p:
    case FParsed{+a, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "==") || f_eq(f_tx(ts), "!="), u => f_equation(a, f_eq(f_tx(ts), "!="), f_begin(ts), f_end(ts), f_expect(f_expr(f_tl(ts), 0), ":")), u => f_group_ann(a, f_expect(f_expr_after(f_expect(FParsed{a, ts}, ":"), 0), "}")))

# Module: src/front/parser.bend:377
@unsafe
def f_equation(a, neg, opBegin, opEnd, p):
  match p:
    case FParsed{b, ts}:
      f_choose(FParsed, f_eq(tg(b), "Error"), u => FParsed{b, ts}, u => f_equation_type(a, b, neg, opBegin, opEnd, f_expect(f_expr(ts, 0), "}")))

# Module: src/front/parser.bend:383
law p175p_grow_word:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed
# Separate overlay: use original f_prec unless the precedence experiment is
# explicitly combined. Preserve parser calls, cursor values and failure paths.
@unsafe
def f_grow_base(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{n,ts}:
      w7_grow_base_err(f_eq(tg(n), "Error"), n, ts, min)

# The first angle argument is parsed at comparison precedence. Compound type
# operators need explicit parentheses; later comma arguments retain full terms.

# Module: src/front/parser.bend:422
@unsafe
def w7_br_338(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_args(ts, ">", Nil{})
    case False{}:
      f_family_first_done(f_expr(ts, 5))

@unsafe
def f_family_first(+ts: FInput) -> FParsed:
  w7_br_338(f_eq(f_tx(ts), ">") || f_eq(f_tx(ts), ">>"), ts)

# Module: src/front/parser.bend:426
@unsafe
def f_family_first_done(+p: FParsed) -> FParsed:
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts},
        u => f_choose(FParsed, f_eq(f_tx(f_space(ts)), "&") || f_eq(f_tx(f_space(ts)), "|") || f_eq(f_tx(f_space(ts)), "->"),
          u => fpe_error(f_space(ts), "a compound type argument takes parentheses", "'>' or ',' (a compound type argument takes parens: F<(A & B)>)"),
          u => f_family_range(f_arg_next(FParsed{n, ts}, ">", Nil{}), f_begin(f_space(ts)))))

# Module: src/front/parser.bend:435
@unsafe
def f_grow_args(n, op, min, p):
  match p:
    case FParsed{+args, ts}:
      f_choose(FParsed, f_context_stop(args), u => FParsed{args, ts}, u => f_grow(FParsed{f_choose(KTerm, f_eq(op, "("), u => f_app_span(n, ks(args), kb(n), f_previous_end(ts)), u => kt_span("ADT", nm(n), ix(n), qt(n), ks(args), kb(n), f_choose(U32, U32.is_gt(ke(args), 0), u => ke(args), u => f_previous_end(ts)))), ts}, min))

# Module: src/front/parser.bend:441
@unsafe
def w7_br_362(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{kt("Efq", "", 0, 1, Nil{}), f_tl(ts)}
    case False{}:
      f_matcher_head(f_expr(ts, 0))

@unsafe
def f_matcher(ts):
  w7_br_362(f_eq(f_tx(ts), "}"), ts)

# Module: src/front/parser.bend:457
@unsafe
def f_matcher_named(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens,FParseContext{scope,env,next}}:
      +resolved = f_context_resolve_table(term,scope,True{})
      f_choose(FParsed,f_context_stop(resolved),u => FParsed{resolved,input},
        u => f_matcher_arm(nm(resolved),f_expr(f_tl(input),0)))

@unsafe
def f_matcher_head(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, (f_eq(tg(n), "Ref") || f_eq(tg(n), "FName") || f_eq(tg(n), "Var")) && f_eq(f_tx(ts), ":"), u => f_matcher_named(n, ts), u => f_expect(FParsed{n, ts}, "}"))

# Module: src/front/parser.bend:463
@unsafe
def f_matcher_arm(name, p):
  match p:
    case FParsed{n, ts}:
      f_matcher_tail(name, n, f_matcher(f_skip(ts)))

# Module: src/front/parser.bend:469
@unsafe
def w7_br_363(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_rewrite(f_tl(ts), f_begin(ts))
    case False{}:
      f_atom_base(ts)

@unsafe
def w7_br_364(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_do_start(f_tl(ts), f_begin(ts))
    case False{}:
      w7_br_363(f_eq(f_tx(ts), "%"), ts)

@unsafe
def f_atom_raw(+ts: FInput) -> FParsed:
  w7_br_364(f_eq(f_tx(ts), "do"), ts)

# Module: src/front/parser.bend:480
@unsafe
def f_args(ts, end, acc):
  f_args_existing(ts, end, acc)

# Module: src/front/parser.bend:484
@unsafe
def w7_br_365(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2,KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), f_prepend(FToken{">", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts))}
    case False{}:
      f_args_base(ts, end, acc)

@unsafe
def f_args_existing(+ts: FInput, +end: String, +acc: List<&2,KTerm>) -> FParsed:
  w7_br_365(f_eq(end, ">") && f_eq(f_tx(ts), ">>"), ts, end, acc)

# Module: src/front/parser.bend:488
@unsafe
def f_grow(p, min):
  f_context_grow(p, min)
law p175p_grow_newline:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +skipped: FInput
  FParsed
law p175p_grow_suffix:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed

@unsafe
def f_grow_existing(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{n,ts}:
      +word = f_tx(ts)
      w7_grow_ex_nl(f_eq(word, "\n"), n, ts, min, word)

# Module: src/front/parser.bend:514
@unsafe
def w7_br_366(w7_c: Bool, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_body(ts)
    case False{}:
      f_expr(ts, min)

@unsafe
def f_rhs(ts, op, min):
  w7_br_366(f_eq(op, "=>"), ts, min)


# P5-011 rejection-only rendering; raw errors retain their legacy text for fallback.

# Module: src/front/parser.bend:550
@unsafe
def f_expr_after(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{n, ts}: f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_expr(ts, min))

# Module: src/front/parser.bend:605
@unsafe
def f_atom(ts):
  f_context_atom_done(f_atom_existing(ts))

# Module: src/front/parser.bend:620
@unsafe
def f_atom_existing(+ts: FInput) -> FParsed:
  f_locate(f_atom_raw(ts), f_begin(ts), f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind") || f_eq(f_tx(ts), "++"), f_eq(f_tx(ts), "@") || (f_eq(f_tx(ts), "&") && Bool.not(f_eq(f_tx(f_tl(ts)), "0") || f_eq(f_tx(f_tl(ts)), "1") || f_eq(f_tx(f_tl(ts)), "2"))) || f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind") || (String.ends_with(f_tx(ts), "n") && f_eq(f_tx(f_tl(ts)), "+")), f_eq(f_tx(ts), "[") || f_eq(f_tx(ts), "(") || f_eq(f_tx(ts), "&") || f_eq(f_tx(ts), "\\"))

# Module: src/front/parser.bend:624
@unsafe
def w7_br_384(w7_c: Bool, +source: String, +start: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_origin_render(source, start, fpe_match_resolved(source, start, error))
    case False{}:
      fpe_origin_plain(source, start, error)

@unsafe
def fpe_origin_render(+source: String, +start: U32, +error: KTerm) -> String:
  w7_br_384(f_eq(tg(kid(error, 0)), "ParseMatch"), source, start, error)

# Module: src/front/parser.bend:682
@unsafe
def w7_br_388(w7_c: Bool, +source: String, +start: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_render(source, error)
    case False{}:
      w7_br_387(U32.is_gt(start, 0) && U32.is_ge(kb(error), start) && U32.is_ge(ke(error), kb(error)) && U32.is_le(U32.sub(ke(error), start), dg_width(source)), source, start, error)

@unsafe
def fpe_origin_plain(+source: String, +start: U32, +error: KTerm) -> String:
  w7_br_388(U32.is_eq(kb(error), 0), source, start, error)

# Module: src/front/parser.bend:692
@unsafe
def fpe_finish_indexed(+start: U32, +source: String, +raw: FRawResult) -> FResult:
  match raw:
    case FRawResult{book, error, imports}: FResult{book, fpe_origin_render(source, start, error), imports}

# Module: src/front/parser.bend:697
@unsafe
def f_tele(ts0, end, acc):
  f_tele_at(f_skip(ts0), end, acc)

# Module: src/front/declarations.bend:323
@unsafe
def w7_br_391(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{kt("Tele", "", 0, 0, List.reverse(&2, KTerm, acc)), f_tl(ts)}
    case False{}:
      f_validate_param(ts, end, acc)

@unsafe
def f_tele_at(ts, end, acc):
  w7_br_391(f_eq(f_tx(ts), end), ts, end, acc)

# Module: src/front/declarations.bend:327
@unsafe
def w7_br_392(w7_c: Bool, +binder: KTerm, +temp: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_tele_type(kt_span(tg(binder), nm(binder), ix(binder), 0, Nil{}, kb(binder), ke(binder)), temp, FParsed{k_with_span(atom("Qnt"), kb(binder), ke(binder)), ts}, end, acc)
    case False{}:
      fpe_error(ts, "expected : (a marked parameter requires its type)", "':'")

@unsafe
def w7_br_393(w7_c: Bool, +binder: KTerm, +temp: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_tele_type(binder, temp, f_expr(f_tl(ts), 0), end, acc)
    case False{}:
      w7_br_392(U32.is_eq(qt(binder), 1) && Bool.not(temp), binder, temp, ts, end, acc)

@unsafe
def f_tele_binder(
  +binder: KTerm,
  +temp: Bool,
  +ts: FInput,
  +end: String,
  +acc: List<&2, KTerm>,
) -> FParsed:
  w7_br_393(f_eq(f_tx(ts), ":"), binder, temp, ts, end, acc)

# Module: src/front/declarations.bend:337
@unsafe
def f_tele_type(binder, temp, p, end, acc):
  match p:
    case FParsed{ty, ts}:
      f_choose(FParsed, f_context_stop(ty), u => p, u => f_context_tele(binder, temp, ty, end, acc, f_context_open(binder, ts)))

# Module: src/front/declarations.bend:343
@unsafe
def f_body(ts):
  f_body_context(ts, 0)

# Module: src/front/declarations.bend:509
@unsafe
def w7_br_394(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_locate(f_match_heads(f_tl(ts), f_col(ts), Nil{}), f_begin(ts), False{}, True{}, False{})
    case False{}:
      f_statement(f_expr(ts, 0), f_begin(ts), f_col(ts))

@unsafe
def w7_br_395(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_erased_local(f_tl(ts), f_begin(ts), f_col(ts))
    case False{}:
      w7_br_394(f_eq(f_tx(ts), "match"), ts)

@unsafe
def f_body_at(
  +ts: FInput,
) -> FParsed:
  w7_br_395(f_eq(f_tx(ts), "-"), ts)

# Module: src/front/declarations.bend:515
@unsafe
def f_statement(p, begin, column):
  match p:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => p, u => f_statement_existing(p, begin, column))

# Module: src/front/declarations.bend:520
@unsafe
def f_statement_existing(+p: FParsed, +begin: U32, +column: U32) -> FParsed:
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "="), u => f_let_value(n, f_expr(f_tl(ts), 0)), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_typed_let_try(n, ts, f_expr(f_tl(ts), 0), begin), u => f_context_statement_more(n, ts, column, begin)))

# Module: src/front/declarations.bend:526
@unsafe
def f_let_value(pat, p):
  match p:
    case FParsed{v, ts}:
      f_choose(FParsed, f_context_stop(v), u => FParsed{v, ts}, u => f_context_let(pat, v, ts))

# Module: src/front/declarations.bend:542
@unsafe
def w7_br_396(w7_c: Bool, +ts: FInput, +indent: U32, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_match_begin(f_skip(f_tl(ts)), indent, List.reverse(&2, KTerm, acc))
    case False{}:
      f_match_head(f_expr(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, acc)

@unsafe
def w7_br_397(w7_c: Bool, +ts: FInput, +indent: U32, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(ts, "expected term", "a term")
    case False{}:
      w7_br_396(f_eq(f_tx(ts), ":"), ts, indent, acc)

@unsafe
def f_match_heads(ts, indent, acc):
  w7_br_397(List.is_empty(&2, KTerm, acc) && (f_eq(f_tx(ts), ":") || f_eq(f_tx(ts), ",")), ts, indent, acc)

# Module: src/front/declarations.bend:546
@unsafe
def f_match_head(p, indent, acc):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_match_heads(ts, indent, Con{f_context_head(n), acc}))

# Module: src/front/declarations.bend:552
@unsafe
def w7_br_398(w7_c: Bool, +ts: FInput, +indent: U32, +heads: List<&2, KTerm>, +rows: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_case_pats(f_tl(ts), indent, heads, rows, Nil{}, f_skip(f_tl(ts)))
    case False{}:
      FParsed{kt("Match", "", 0, 1, Con{kt("Heads", "", 0, 1, heads), List.reverse(&2, KTerm, rows)}), ts}

@unsafe
def f_match_cases(
  +ts: FInput,
  +indent: U32,
  +heads: List<&2, KTerm>,
  +rows: List<&2, KTerm>,
) -> FParsed:
  w7_br_398(f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), indent), ts, indent, heads, rows)

# Module: src/front/declarations.bend:561
@unsafe
def w7_br_399(w7_c: Bool, +ts: FInput, +indent: U32, +heads: List<&2, KTerm>, +rows: List<&2, KTerm>, +pats: List<&2, KTerm>, +start: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_context_case(ts, indent, heads, rows, List.reverse(&2, KTerm, pats))
    case False{}:
      fpe_span(start, ts, "one pattern is required per match scrutinee", U32.show(terms_len(heads)) ++ " patterns (one per scrutinee)", "")

@unsafe
def w7_br_400(w7_c: Bool, +ts: FInput, +indent: U32, +heads: List<&2, KTerm>, +rows: List<&2, KTerm>, +pats: List<&2, KTerm>, +start: FInput) -> FParsed:
  match w7_c:
    case True{}:
      w7_br_399(U32.is_eq(terms_len(pats), terms_len(heads)), ts, indent, heads, rows, pats, start)
    case False{}:
      f_case_pat(f_expr(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, heads, rows, pats, start)

@unsafe
def w7_br_401(w7_c: Bool, +ts: FInput, +indent: U32, +heads: List<&2, KTerm>, +rows: List<&2, KTerm>, +pats: List<&2, KTerm>, +start: FInput) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(ts, "expected term", "a term")
    case False{}:
      w7_br_400(f_eq(f_tx(ts), ":"), ts, indent, heads, rows, pats, start)

@unsafe
def f_case_pats(ts, indent, heads, rows, pats, start):
  w7_br_401(List.is_empty(&2, KTerm, pats) && (f_eq(f_tx(ts), ":") || f_eq(f_tx(ts), ",")), ts, indent, heads, rows, pats, start)

# Module: src/front/declarations.bend:565
@unsafe
def f_case_pat(p, indent, heads, rows, pats, start):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_case_pats(ts, indent, heads, rows, Con{n, pats}, start))

# Module: src/front/declarations.bend:571
@unsafe
def f_case_body(p, indent, heads, rows, pats):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_match_cases(f_skip(ts), indent, heads, Con{kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, pats), n]), rows}))

# Module: src/front/declarations.bend:578
@unsafe
def f_body_context(ts, outer):
  f_body_context_at(f_skip(ts), outer)

# Module: src/front/declarations.bend:621
@unsafe
def f_body_context_at(ts, outer):
  f_body_context_existing(ts, outer)

# Module: src/front/declarations.bend:625
@unsafe
def w7_br_402(w7_c: Bool, +ts: FInput, +outer: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_locate(f_match_heads(f_tl(ts), outer, Nil{}), f_begin(ts), False{}, True{}, False{})
    case False{}:
      f_body_at(ts)

@unsafe
def f_body_context_existing(+ts: FInput, +outer: U32) -> FParsed:
  w7_br_402(f_eq(f_tx(ts), "match"), ts, outer)

# Module: src/front/declarations.bend:629
@unsafe
def w7_br_403(w7_c: Bool, +ts: FInput, +heads: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_match_cases(ts, U32.sub(f_col(ts), 1), heads, Nil{})
    case False{}:
      FParsed{kt("Match", "", 0, 1, [kt("Heads", "", 0, 1, heads)]), ts}

@unsafe
def f_match_begin(ts, outer, heads):
  w7_br_403(f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), outer), ts, heads)

# Module: src/front/declarations.bend:637
@unsafe
def f_do_start(+ts: FInput, +begin: U32) -> FParsed:
  f_do_named(f_space(ts), begin)

# Module: src/front/sugar.bend:33
@unsafe
def w7_br_429(w7_c: Bool, +ts: FInput, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_parameters(f_tx(ts), f_space(f_tl(ts)), begin)
    case False{}:
      fpe_name_error(ts)

@unsafe
def f_do_named(+ts: FInput, +begin: U32) -> FParsed:
  w7_br_429(f_valid_name(f_tx(ts)), ts, begin)

# Module: src/front/sugar.bend:37
@unsafe
def w7_br_430(w7_c: Bool, +name: String, +ts: FInput, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_parameters_resolved(name, ts, begin, f_do_header_name(name, ts))
    case False{}:
      fpe_error(ts, "expected <", "'<'")

@unsafe
def f_do_parameters(+name: String, +ts: FInput, +begin: U32) -> FParsed:
  w7_br_430(f_eq(f_tx(ts), "<>") || f_eq(f_tx(ts), "<"), name, ts, begin)

# Module: src/front/sugar.bend:42
@unsafe
def w7_br_431(w7_c: Bool, +name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      f_do_types(name, FParsed{kt("Args", "", 0, 1, Nil{}), f_tl(ts)}, begin, resolved)
    case False{}:
      f_do_parameters_open(name, f_space(f_tl(ts)), begin, resolved)

@unsafe
def w7_br_432(w7_c: Bool, +name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{resolved, ts}
    case False{}:
      w7_br_431(f_eq(f_tx(ts), "<>"), name, ts, begin, resolved)

@unsafe
def f_do_parameters_resolved(+name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  w7_br_432(f_context_stop(resolved), name, ts, begin, resolved)

# Module: src/front/sugar.bend:54
@unsafe
def w7_br_433(w7_c: Bool, +name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      f_do_types(name, FParsed{kt("Args", "", 0, 1, Nil{}), f_tl(ts)}, begin, resolved)
    case False{}:
      f_do_types(name, f_args(ts, ">", Nil{}), begin, resolved)

@unsafe
def w7_br_434(w7_c: Bool, +name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(ts, "expected term", "a term")
    case False{}:
      w7_br_433(f_eq(f_tx(ts), ">") || f_eq(f_tx(ts), ">op"), name, ts, begin, resolved)

@unsafe
def f_do_parameters_open(+name: String, +ts: FInput, +begin: U32, +resolved: KTerm) -> FParsed:
  w7_br_434(f_eq(f_tx(ts), ";"), name, ts, begin, resolved)

# Module: src/front/sugar.bend:58
@unsafe
def f_do_types(+name: String, +p: FParsed, +begin: U32, +resolved: KTerm) -> FParsed:
  match p:
    case FParsed{types, ts}:
      f_choose(FParsed, f_context_stop(types), u => p, u => f_do_header(kt_span("ADT", name, 0, 1, ks(types), begin, f_previous_end(ts)), f_space(ts), resolved))

# Module: src/front/sugar.bend:70
@unsafe
def f_do_header(+monad: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_do_header_resolved(monad, input, scope, resolved)

# Module: src/front/sugar.bend:77
@unsafe
def f_do_header_resolved(+monad: KTerm, +input: FInput, +scope: FParseScope, +resolved: KTerm) -> FParsed:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      f_do_types_at(f_choose(KTerm, f_eq(dk(p144p_find(nm(resolved), prior, p144p_view)), "ADT"), u => f_adt(monad, ks(monad), p144p_find(nm(resolved), prior, p144p_view)), u => monad), input)

# Module: src/front/sugar.bend:83

@unsafe
def w7_br_435(w7_c: Bool, +monad: KTerm, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_do(monad, f_space(f_tl(ts)), f_col(f_space(f_tl(ts))))
    case False{}:
      fpe_error(ts, "expected :", "':'")

@unsafe
def f_do_types_at(+monad: KTerm, +ts: FInput) -> FParsed:
  w7_br_435(f_eq(f_tx(ts), ":"), monad, ts)

# Module: src/front/sugar.bend:87
@unsafe
def w7_br_436(w7_c: Bool, +monad: KTerm, +ts: FInput, +indent: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_return(monad, f_atid(ts), f_begin(ts), f_expr(f_tl(ts), 0))
    case False{}:
      f_do_statement(monad, f_expr(ts, 0), indent, f_begin(ts))

@unsafe
def f_do(+monad: KTerm, +ts: FInput, +indent: U32) -> FParsed:
  w7_br_436(f_eq(f_tx(ts), "return"), monad, ts, indent)

# Module: src/front/sugar.bend:91
@unsafe
def f_do_statement(+monad: KTerm, +p: FParsed, +indent: U32, +begin: U32) -> FParsed:
  match p:
    case FParsed{n, ts}:
      f_choose(FParsed, f_context_stop(n), u => p, u => f_do_statement_at(monad, n, f_space(ts), indent, begin))

# Module: src/front/sugar.bend:107
@unsafe
def w7_br_437(w7_c: Bool, +monad: KTerm, +n: KTerm, +ts: FInput, +indent: U32, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_value(monad, kt_span("Var", "_", 0, 1, Nil{}, 0, 0), n, False{}, f_expr(f_tl(ts), 0), indent, begin)
    case False{}:
      f_do_result(kt_span("FDo", nm(monad), ix(n), 0, [monad, n], kb(n), ke(n)), ts)

@unsafe
def w7_br_438(w7_c: Bool, +monad: KTerm, +n: KTerm, +ts: FInput, +indent: U32, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_step(monad, n, ts, indent, begin)
    case False{}:
      w7_br_437(f_eq(f_tx(ts), "<-"), monad, n, ts, indent, begin)

@unsafe
def w7_br_439(w7_c: Bool, +monad: KTerm, +n: KTerm, +ts: FInput, +indent: U32, +begin: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_do_annotated(monad, n, f_expr(f_tl(ts), 1), indent, begin)
    case False{}:
      w7_br_438(f_eq(f_tx(ts), ";") || (U32.is_eq(f_col(ts), indent) && Bool.not(f_eq(f_tx(ts), "<eof>"))), monad, n, ts, indent, begin)

@unsafe
def f_do_statement_at(+monad: KTerm, +n: KTerm, +ts: FInput, +indent: U32, +begin: U32) -> FParsed:
  w7_br_439(f_eq(f_tx(ts), ":") && f_do_var(n, ts), monad, n, ts, indent, begin)

# Module: src/front/sugar.bend:117
@unsafe
def f_do_step(+monad: KTerm, +value: KTerm, +input: FInput, +indent: U32, +begin: U32) -> FParsed:
  f_do_step_type(monad, value, indent, begin, f_context_name(k_with_span(ref("Unit"), kb(value), ke(value)), input))

# Module: src/front/sugar.bend:121
@unsafe
def f_do_step_type(+monad: KTerm, +value: KTerm, +indent: U32, +begin: U32, +p: FParsed) -> FParsed:
  match p:
    case FParsed{ty, ts}:
      f_choose(FParsed, f_context_stop(ty), u => p, u => f_do_value(monad, kt_span("Var", "_", 0, 1, Nil{}, 0, 0), ty, False{}, FParsed{value, ts}, indent, begin))

# Module: src/front/sugar.bend:127
@unsafe
def f_do_annotated(+monad: KTerm, +binder: KTerm, +p: FParsed, +indent: U32, +begin: U32) -> FParsed:
  match p:
    case FParsed{ty, raw}:
      +ts = f_space(raw)
      f_choose(FParsed, f_context_stop(ty), u => p, u => f_choose(FParsed, f_eq(f_tx(ts), "=") || f_eq(f_tx(ts), "<-"), u => f_do_value(monad, binder, ty, f_eq(f_tx(ts), "="), f_expr(f_tl(ts), 0), indent, begin), u => fpe_error(ts, "expected <-", "'<-'")))

# Module: src/front/sugar.bend:134
@unsafe
def f_do_value(+monad: KTerm, +binder: KTerm, +ty: KTerm, +pure: Bool, +p: FParsed, +indent: U32, +begin: U32) -> FParsed:
  match p:
    case FParsed{v, raw}:
      +ts = f_space(raw)
      +semi = f_eq(f_tx(ts), ";")
      +end = f_choose(U32, semi, u => f_end(ts), u => f_begin(ts))
      f_choose(FParsed, f_context_stop(v), u => p, u => f_do_open(monad, binder, ty, pure, v, end, indent, begin, f_space(f_choose(FInput, semi, u => f_tl(ts), u => ts))))

# Module: src/front/sugar.bend:143
@unsafe
def f_do_open(+monad: KTerm, +binder: KTerm, +ty: KTerm, +pure: Bool, +value: KTerm, +end: U32, +indent: U32, +begin: U32, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_do_opened(monad, ty, pure, value, begin, end, indent, env, f_context_open(binder, input))

# Module: src/front/sugar.bend:150
@unsafe
def f_do_opened(+monad: KTerm, +ty: KTerm, +pure: Bool, +value: KTerm, +begin: U32, +end: U32, +indent: U32, +outer: List<&2,KTerm>, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{binder, input}:
      f_choose(FParsed, f_context_stop(binder), u => opened, u => f_do_tail(monad, binder, ty, pure, value, begin, end, f_context_close_done(f_do(monad, input, indent), outer)))

# Module: src/front/sugar.bend:156
@unsafe
def f_rewrite(+ts: FInput, +begin: U32) -> FParsed:
  f_rewrite_head(f_expr(ts, 0), begin)

# Module: src/front/sugar.bend:207
@unsafe
def f_rewrite_head(+p: FParsed, +begin: U32) -> FParsed:
  match p:
    case FParsed{e, raw}:
      +ts = f_space(raw)
      f_choose(FParsed, f_context_stop(e), u => p,
        u => f_choose(FParsed, f_eq(f_tx(ts), "@"),
          u => f_choose(FParsed, f_eq(tg(e), "FName") || f_eq(tg(e), "Var"),
            u => f_rewrite_proof(e, begin, f_expect(f_expr(f_tl(ts), 0), ":")),
            u => fpe_error(f_tl(ts), "expected a rewrite binder", "a name before @ (a rewrite binder is one name: %e@E : P)")),
          u => f_rewrite_proof(kt_span("Var", "", ix(e), 1, Nil{}, kb(e), ke(e)), begin, f_expect(FParsed{e, ts}, ":"))))

# Module: src/front/sugar.bend:219
@unsafe
def f_rewrite_proof(+binder: KTerm, +begin: U32, +p: FParsed) -> FParsed:
  match p:
    case FParsed{e, input}:
      f_choose(FParsed, f_context_stop(e), u => p, u => f_rewrite_open(binder, begin, e, input))

# Module: src/front/sugar.bend:225
@unsafe
def f_rewrite_open(+binder: KTerm, +begin: U32, +proof: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_rewrite_opened(binder, begin, proof, next, env, f_context_open(kt_span("Var", nm(binder), 0, 1, Nil{}, kb(binder), ke(binder)), FInput{tokens, FParseContext{scope, Con{kt("RewriteVar", "_", next, 1, Nil{}), env}, U32.add(next, 1)}}))

# Module: src/front/sugar.bend:233
@unsafe
def f_rewrite_opened(+origin: KTerm, +begin: U32, +proof: KTerm, +xi: U32, +outer: List<&2,KTerm>, +p: FParsed) -> FParsed:
  match p:
    case FParsed{binder, input}:
      f_rewrite_context_motive(origin, begin, proof, xi, binder, f_context_close_done(f_expr(input, 0), outer))

# Module: src/front/sugar.bend:239
@unsafe
def f_rewrite_context_motive(+origin: KTerm, +begin: U32, +proof: KTerm, +xi: U32, +binder: KTerm, +p: FParsed) -> FParsed:
  match p:
    case FParsed{motive, raw}:
      +ts = f_space(raw)
      f_choose(FParsed, f_context_stop(motive), u => p,
        u => f_rewrite_context_body(origin, begin, proof, xi, binder, motive, f_context_flat(f_body(f_choose(FInput, f_eq(f_tx(ts), ";"), u => f_tl(ts), u => ts)), Nil{})))

# Module: src/front/sugar.bend:247
@unsafe
def w7_br_440(w7_c: Bool, +ts: FInput, +begin: U32, +column: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_statement(FParsed{kt_span("Var", f_tx(ts), f_atid(ts), 0, Nil{}, begin, f_end(ts)), f_tl(ts)}, begin, column)
    case False{}:
      fpe_error(ts, "expected a name", "a name")

@unsafe
def f_erased_local(ts, begin, column):
  w7_br_440(f_valid_name(f_tx(ts)), ts, begin, column)

# Module: src/front/sugar.bend:283
@unsafe
def w7_br_441(w7_c: Bool, +n: KTerm, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_let_value(kt("Ref", nm(n), ix(n), 1, Nil{}), FParsed{kid(n, 0), ts})
    case False{}:
      FParsed{kid(n, 0), ts}

@unsafe
def f_write_statement(
  +n: KTerm,
  +ts: FInput,
) -> FParsed:
  w7_br_441((f_eq(f_tx(ts), ";") || U32.is_eq(f_col(f_skip(ts)), U32.and(ix(n), 65535))) && Bool.not(f_eq(f_tx(f_skip(ts)), "<eof>")), n, ts)

# Module: src/front/sugar.bend:295
@unsafe
def w7_br_457(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{kt("Ctr", f_context_own("Nil", ts, True{}), 0, 1, Nil{}), f_tl(ts)}
    case False{}:
      f_array_first(f_expr(ts, 0))

@unsafe
def w7_br_458(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      f_err(ts, "expected term; a list does not use semicolon separators")
    case False{}:
      w7_br_457(f_eq(f_tx(ts), "]"), ts)

@unsafe
def f_array(ts):
  w7_br_458(f_eq(f_tx(ts), ";"), ts)

# Module: src/front/literals_arrays.bend:81
@unsafe
def f_array_first(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_array_type(n, f_expr(f_tl(ts), 12)), u => f_list(f_args(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), "]", [n]))))

# Module: src/front/literals_arrays.bend:87
@unsafe
def f_array_type(n, p):
  match p:
    case FParsed{+ty, +ts}:
      +rest = f_space(ts)
      f_choose(FParsed, f_eq(tg(ty), "Error"), u => FParsed{ty, ts}, u => f_choose(FParsed, f_eq(f_tx(rest), "*") || f_eq(f_tx(rest), "^"), u => f_array_size(n, ty, f_eq(f_tx(rest), "*"), f_expr(f_tl(rest), 0)), u => fpe_error(rest, "expected * or ^ after array element type", "'^'")))

# Module: src/front/literals_arrays.bend:94
@unsafe
def f_index(n, p, min):
  match p:
    case FParsed{idx, ts}:
      f_choose(FParsed, f_context_stop(idx), u => p, u => f_index_ready(n, f_context_namespace(idx, ref(f_context_own("U32", ts, False{})), ts), ts, min))

# Module: src/front/literals_arrays.bend:110
@unsafe
def w7_br_461(w7_c: Bool, +n: KTerm, +idx: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_index_value(n, idx, f_previous_end(ts), f_expr(f_tl(ts), 2), min)
    case False{}:
      f_grow(FParsed{f_app_span(k_with_span(ref(f_context_own("Array.get", ts, False{})), kb(n), f_previous_end(ts)), [k_with_span(ref(f_context_own("U32", ts, False{})), kb(n), f_previous_end(ts)), n, idx], kb(n), f_previous_end(ts)), ts}, min)

@unsafe
def w7_br_462(w7_c: Bool, +n: KTerm, +idx: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{idx, ts}
    case False{}:
      w7_br_461(f_eq(f_tx(ts), "<-"), n, idx, ts, min)

@unsafe
def f_index_ready(+n: KTerm, +idx: KTerm, +ts: FInput, +min: U32) -> FParsed:
  w7_br_462(f_context_stop(idx), n, idx, ts, min)

# Module: src/front/literals_arrays.bend:115
@unsafe
def f_index_value(n, idx, end, p, min):
  match p:
    case FParsed{v, ts}:
      f_choose(FParsed, f_context_stop(v), u => p,
        u => f_grow(FParsed{f_app_span(k_with_span(ref(f_context_own("Array.set", ts, False{})), kb(n), end), [k_with_span(ref(f_context_own("U32", ts, False{})), kb(n), end), n, idx, v], kb(n), end), ts}, min))

# Module: src/front/literals_arrays.bend:122
@unsafe
def w7_br_484(w7_c: Bool, +ts: FInput, +pats: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_parallel_pat(f_expr(ts, 0), pats)
    case False{}:
      fpe_error(ts, "expected =", "'='")

@unsafe
def w7_br_485(w7_c: Bool, +ts: FInput, +pats: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_parallel_values(f_tl(ts), List.reverse(&2, KTerm, pats), terms_len(pats), Nil{})
    case False{}:
      w7_br_484(f_binding_head(ts), ts, pats)

@unsafe
def f_parallel(
  +ts: FInput,
  +pats: List<&2, KTerm>,
) -> FParsed:
  w7_br_485(f_eq(f_tx(ts), "="), ts, pats)

# Module: src/front/parallel.bend:57
@unsafe
def f_parallel_pat(p, pats):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_parallel(ts, Con{n, pats}))

# Module: src/front/parallel.bend:63
@unsafe
def w7_br_486(w7_c: Bool, +ts: FInput, +pats: List<&2, KTerm>, +left: U32, +vals: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      f_context_parallel(pats, List.reverse(&2, KTerm, vals), ts)
    case False{}:
      f_parallel_value(f_expr(ts, 0), pats, left, vals)

@unsafe
def f_parallel_values(ts, pats, left, vals):
  w7_br_486(U32.is_eq(left, 0), ts, pats, left, vals)

# Module: src/front/parallel.bend:67
@unsafe
def f_parallel_value(p, pats, left, vals):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_parallel_values(ts, pats, U32.sub(left, 1), Con{n, vals}))

# Module: src/front/parallel.bend:73
@unsafe
def f_statement_more(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Write"), u => f_write_statement(n, ts), u => f_choose(FParsed, f_binding_head(ts), u => f_parallel(ts, [n]), u => FParsed{n, ts}))

# Module: src/front/parallel.bend:97
@unsafe
def f_typed_let_try(n, old, p, begin):
  match p:
    case FParsed{ty, ts}:
      f_choose(FParsed, f_context_stop(ty), u => p, u => f_choose(FParsed, f_eq(f_tx(ts), "="),
        u => f_context_typed_value(n, f_let_ann(ty, f_expr(f_tl(ts), 0), begin)),
        u => FParsed{n, f_context_rewind(old, ts)}))

# Module: src/front/parallel.bend:105
@unsafe
def w7_br_503(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_error(ts, "only leading parameters may use ~", "a plain binder (only leading binders take ~)")
    case False{}:
      f_tele_binder(kt_span("Bind", f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), Nil{}, f_begin(f_unmark(ts)), f_end(f_unmark(ts))), f_eq(f_tx(ts), "~"), f_tl(f_unmark(ts)), end, acc)

@unsafe
def w7_br_504(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_word(f_unmark(ts), "duplicate constructor field", "a fresh field name (duplicate declaration: " ++ f_tx(f_unmark(ts)) ++ ")")
    case False{}:
      w7_br_503(f_eq(f_tx(ts), "~") && U32.is_lt(f_templates(acc), terms_len(acc)), ts, end, acc)

@unsafe
def w7_br_505(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_name_error(f_choose(FInput, f_eq(f_tx(ts), "->"), u => f_prepend(FToken{">", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts)), u => f_unmark(ts)))
    case False{}:
      w7_br_504(f_eq(end, "}") && f_named_field(f_tx(f_unmark(ts)), acc), ts, end, acc)

@unsafe
def w7_br_506(w7_c: Bool, +ts: FInput, +end: String, +acc: List<&2, KTerm>) -> FParsed:
  match w7_c:
    case True{}:
      fpe_name_error(ts)
    case False{}:
      w7_br_505(Bool.not(f_valid_name(f_tx(f_unmark(ts)))), ts, end, acc)

@unsafe
def f_validate_param(ts, end, acc):
  w7_br_506(f_eq(f_tx(ts), "~") && Bool.not(f_eq(end, ")")), ts, end, acc)

# Module: src/front/validate.bend:130
@unsafe
def w7_br_508(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_grow(FParsed{kt_span("Ref", nm(n), ix(n), 3, ks(n), kb(n), ke(n)), f_tl(ts)}, min)
    case False{}:
      fpe_error(ts, "! must follow a named definition and precede call parentheses", "a named def before ! (only f!(..) offloads)")

@unsafe
def f_bang(n, ts, min):
  w7_br_508(f_eq(tg(n), "Ref") && f_eq(f_tx(f_tl(ts)), "("), n, ts, min)

# Module: src/front/validate.bend:203
@unsafe
def w7_br_528(w7_c: Bool, +error: KTerm, +source: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_origin_render(nm(source), kb(source), error)
    case False{}:
      fpe_render(nm(source), error)

@unsafe
def w7_br_529(w7_c: Bool, +legacy: String, +error: KTerm, +source: KTerm) -> String:
  match w7_c:
    case True{}:
      w7_br_528(U32.is_gt(kb(source), 0), error, source)
    case False{}:
      legacy

@unsafe
def fpe_source_render(legacy, error, source):
  w7_br_529(f_eq(tg(source), "ParseSource"), legacy, error, source)

# Canonical module namespaces are relative to the entry's real directory.
# Reaching a file through another spelling therefore cannot create another name.

# Module: src/load/graph.bend:415
@unsafe
def j_compile_error(
  +book: List<&2, KDef>,
) -> String:
  w7_br_597(p88_string_eq(dk(lookup(book, "IO")), "Absent"), book)

# Module: src/back/js/validate.bend:17
@unsafe
def w7_br_784(w7_c: Bool, +book: List<&2, KDef>, +name: String) -> NO_Plan:
  match w7_c:
    case True{}:
      no_plan_checked(book, name, lookup(book, name))
    case False{}:
      no_plan_refuse(name, "observer: no checked host permission")

@unsafe
def no_observer_plan(+book: List<&2, KDef>, +name: String, +permission: Bool) -> NO_Plan:
  w7_br_784(permission, book, name)

# Module: src/back/native/observer-plan.bend:41
@unsafe
def w7_br_785(w7_c: Bool, +book: List<&2, KDef>, +name: String, +d: KDef) -> NO_Plan:
  match w7_c:
    case True{}:
      no_plan_schema_ready(book, name, no_schema(book, d, 0))
    case False{}:
      no_plan_refuse(name, "observer: owner, effect or arity")

@unsafe
def no_plan_checked(+book: List<&2, KDef>, +name: String, +d: KDef) -> NO_Plan:
  w7_br_785(p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)) && U32.is_le(nd_arity(book, name), 4), book, name, d)

# Module: src/back/native/observer-plan.bend:46
@unsafe
def no_plan_schema_ready(+book: List<&2, KDef>, +name: String, +schema: NO_Schema) -> NO_Plan:
  w7_br_786(p88_string_eq(no_schema_error(schema), ""), book, name, schema)

# Module: src/back/native/observer-plan.bend:52
@unsafe
def w7_br_819(w7_c: Bool, +context: List<&2,KDef>, +raw: KDef, +first: KTerm, +checked: KDef) -> KDef:
  match w7_c:
    case True{}:
      p205u_check(context,raw,first)
    case False{}:
      checked

@unsafe
def p205u_scalar_checked(+context: List<&2,KDef>, +raw: KDef, +first: KTerm, +checked: KDef) -> KDef:
  w7_br_819(agy_str_eq(dk(checked),"Absent"), context, raw, first, checked)

@unsafe
def w7_br_820(w7_c: Bool, +context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  match w7_c:
    case True{}:
      missing()
    case False{}:
      p205z_unfold_check(p205z_advance(context,dg_event_output(raw,body)),dg_event_output(raw,body))

@unsafe
def p205u_check(+context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  w7_br_820(p98_tag_eq(body,"Absent"), context, raw, body)
@unsafe
def p205z_unfold_check(+context: List<&2,KDef>, +change: KDef) -> KDef:
  p205u_checked(context,change,check_definition_body(kw_initial(context),change,0))

@unsafe
def w7_br_822(w7_c: Bool, +context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  match w7_c:
    case True{}:
      missing()
    case False{}:
      p205_recheck(p205z_advance(context,dg_event_output(raw,body)),dg_event_output(raw,body))

@unsafe
def p205_checked_body(+context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  w7_br_822(p98_tag_eq(body,"Absent"), context, raw, body)

@unsafe
def p205_recheck(+context: List<&2,KDef>, +changed: KDef) -> KDef:
  +result = check_definition_body(kw_initial(context),changed,0)
  kc(KDef,good(result),u => ka_def(context,dg_event_output(changed,ct(result))),u => missing())

@unsafe
def p205_update(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  p205_checked_body(context,raw,p205_tail(context,dv(raw)))

@unsafe
def p205_decls(+context: List<&2,KDef>, defs: List<&2,KDef>, +edits: KDef) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{+d,rest}:
      +change = kc(KDef,agy_str_eq(dk(d),"Def") && Bool.not(db(d)) && U32.is_eq(dx(d),0) &&
        p205_returns_string(dt(d)),u => p205_update(context,lookup(context,dn(d))),u => missing())
      p205_decls(p205z_advance(context,change),rest,kc(KDef,agy_str_eq(dk(change),"Absent"),u => edits,u =>
        index_set(edits,change,index_hash(dn(change),2166136261),32)))

@unsafe
def ctfe_try_finish(+context: List<&2, KDef>, +raw: KDef, +owner: String, r: CtfeRes) -> KDef:
  match r:
    case CtfeRes{val, rem}:
      +lit = ctfe_reify(owner, val)
      kc(KDef, p98_tag_eq(lit, "Absent"), v => missing(), v => p205u_check(context, raw, lit))

@unsafe
def ctfe_try_def(+context: List<&2, KDef>, +raw: KDef) -> KDef:
  +owner = kc(String, U32.is_eq(da(raw), 0) && Bool.not(ctfe_already_lit(dv(raw))),
    u => ctfe_ground_owner(dt(raw)), u => "")
  kc(KDef, String.is_empty(owner), u => missing(),
    u => ctfe_try_finish(context, raw, owner, ctfe_eval(context, [], dv(raw), 262144)))

@unsafe
def agy_abs_commit_go(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> AgyAbsResult:
  +new_sbr = agy_abs_build_sbr(arity,p_lam,r_lams,st_idx,m2)
  +new_body = kt("Mat","Zero",0,1,[zbr,kt("Mat","Succ",0,1,[new_sbr,atom("Efq")])])
  +cand_def = dg_event_output(raw,new_body)
  +ctx_chk = p205z_advance(ctx,cand_def)
  agy_abs_commit_checked(ctx,ctx_chk,orig_d,cand_def,rest,check_definition_body(kw_initial(ctx_chk),cand_def,0))

@unsafe
def agy_abs_commit(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +walk_res: AgyAbsWalk) -> AgyAbsResult:
  match walk_res:
    case AgyAbsWalk{m2,hit,ok}:
      kc(AgyAbsResult,hit && ok,
        u => agy_abs_commit_go(ctx,orig_d,raw,rest,arity,zbr,p_lam,r_lams,st_idx,m2),
        u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_inline_peeled(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +sargs: List<&2,KTerm>, +peel: AgyAbsPeel) -> AgyAbsResult:
  match peel:
    case AgyAbsPeel{slams,smat,ok}:
      kc(AgyAbsResult,ok,
        v => agy_abs_commit(ctx,orig_d,raw,rest,arity,zbr,p_lam,r_lams,st_idx,
          agy_abs_walk(ctx,agy_abs_subst_lams(smat,slams,sargs),agy_abs_hole(0),[0],1,fname,p_lam,r_lams,st_idx)),
        v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_inline_fresh(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +step_arity: U32, +sargs: List<&2,KTerm>, +ff: FFresh) -> AgyAbsResult:
  match ff:
    case FFresh{fresh_step,_}:
      agy_abs_inline_peeled(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,sargs,agy_abs_peel(fresh_step,U32.sub(step_arity,1)))

@unsafe
def agy_abs_inline_step(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +step_def: KDef, +sargs: List<&2,KTerm>) -> AgyAbsResult:
  +step_clean = p205u_clean(dv(step_def))
  +step_arity = da(step_def)
  kc(AgyAbsResult,U32.is_eq(p205u_refs(step_clean,fname),0) && U32.is_eq(p205u_refs(step_clean,dn(step_def)),0),
    u => agy_abs_inline_fresh(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,step_arity,sargs,f_fresh_term(step_clean,Nil{},U32.inc(norm_book_bound(ctx)))),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_check_one(+context: List<&2,KDef>, +d: KDef) -> KDef:
  +res = check_definition_body(kw_initial(context),d,0)
  kc(KDef,good(res),u => ka_def(context,dg_event_output(d,ct(res))),u => missing())

@unsafe
def agy_bf_commit_call(+orig_ctx: List<&2,KDef>, +ctx3: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +dname: String, +arity: U32, +bid: U32, +chk_orig: KDef, +chk_loop: KDef, +chk_dh: KDef) -> AgyBFResult:
  +disp_def = agy_bf_build_dispatch(raw,dname,arity,bid)
  +ctx4 = p205z_advance(ctx3,disp_def)
  +chk_disp = agy_bf_check_one(ctx4,disp_def)
  kc(AgyBFResult,agy_str_eq(dk(chk_disp),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => AgyBFResult{p205z_advance(ctx4,chk_disp),Con{chk_orig,Con{chk_loop,Con{chk_dh,Con{chk_disp,rest}}}},True{}})

@unsafe
def agy_bf_commit_disp(+orig_ctx: List<&2,KDef>, +ctx2: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +hname: String, +oname: String, +dname: String, +arity: U32, +bid: U32, +chk_orig: KDef, +chk_loop: KDef) -> AgyBFResult:
  +dh_def = agy_bf_build_disp_helper(dname,dt(raw),hname,oname,arity,bid)
  +ctx3 = agy_bf_add_def(ctx2,dh_def)
  +chk_dh = agy_bf_check_one(ctx3,dh_def)
  kc(AgyBFResult,agy_str_eq(dk(chk_dh),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => agy_bf_commit_call(orig_ctx,agy_bf_add_def(ctx2,chk_dh),orig_d,raw,rest,dname,arity,bid,chk_orig,chk_loop,chk_dh))

@unsafe
def agy_bf_commit_loop(+orig_ctx: List<&2,KDef>, +ctx1: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +hname: String, +oname: String, +dname: String, +arity: U32, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32, +chk_orig: KDef) -> AgyBFResult:
  +loop_def = agy_bf_build_loop(hname,dt(raw),arity,lams0,base_expr,step,bid)
  +ctx2 = agy_bf_add_def(ctx1,loop_def)
  +chk_loop = agy_bf_check_one(ctx2,loop_def)
  kc(AgyBFResult,agy_str_eq(dk(chk_loop),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => agy_bf_commit_disp(orig_ctx,agy_bf_add_def(ctx1,chk_loop),orig_d,raw,rest,hname,oname,dname,arity,bid,chk_orig,chk_loop))

@unsafe
def agy_bf_commit(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +hname: String, +oname: String, +dname: String, +arity: U32, +clean: KTerm, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32) -> AgyBFResult:
  +orig_def = {KDef{oname,"Def",arity,0,dt(raw),agy_bf_rename_ref(clean,fname,oname),[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(context,orig_def)
  +chk_orig = agy_bf_check_one(ctx1,orig_def)
  kc(AgyBFResult,agy_str_eq(dk(chk_orig),"Absent"),
    u => AgyBFResult{context,Con{orig_d,rest},False{}},
    u => agy_bf_commit_loop(context,agy_bf_add_def(context,chk_orig),orig_d,raw,rest,hname,oname,dname,arity,lams0,base_expr,step,bid,chk_orig))

@unsafe
def w5c3_fb_and(m: Bool, +book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}:
      +ba = p205v_bool_val(a)
      w5c3_fb_and1(U32.is_eq(ba,2), book, a, b, ba)
    case False{}: w5c3_fb_or(String.eq(name,"Bool.or"), book, a, b)

@unsafe
def p205v_fold_bool(+book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  w5c3_fb_and(String.eq(name,"Bool.and"), book, name, a, b)

@unsafe
def w5c3_fold_bf(is_abs: Bool, +book: List<&2,KDef>, +t: KTerm, +a: KTerm, +b: KTerm, +bf: KTerm) -> KTerm:
  match is_abs:
    case True{}:
      +op = nd_native_call(book,t)
      w5c3_fold_op(String.is_empty(op), book, op, a, b)
    case False{}: bf

@unsafe
def p205v_fold(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Con{a,Con{b,Nil{}}}:
      +bf = p205v_fold_bool(book,nm(call),a,b)
      w5c3_fold_bf(p98_tag_eq(bf,"Absent"), book, t, a, b, bf)
    case _: atom("Absent")

law p205v_eval:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

law p205v_apply:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +args: List<&2,KTerm>
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

@unsafe
def p205v_field_next(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      match ok:
        case True{}: p205u_field_join(term,True{},p205v_fields(book,rest,next,steps,fuel))
        case False{}: P205UFields{[],next,steps,False{}}

@unsafe
def p205v_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205v_field_next(book,rest,fuel,p205v_eval(book,x,next,steps,fuel))

@unsafe
def w5c3_beta_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +h: KTerm, +args: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match ok:
    case True{}: p205v_apply(book,h,args,next,U32.inc(steps),fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_try_beta(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +sp: P205UFields) -> P205UResult:
  match sp:
    case P205UFields{Con{hd,args},_,_,_}:
      +h = j_strip(hd)
      w5c3_beta_if((p98_tag_eq(h,"Lam") && U32.is_ne(qt(h),0) && U32.is_ne(qt(h),3)) ||
        (p98_tag_eq(h,"Mat") && U32.is_eq(ix(h),0) && U32.is_eq(terms_len(ks(h)),2) &&
          Bool.not(List.is_empty(&2,KTerm,args)) && p98_tag_eq(j_strip(p205u_at(args,0)),"Ctr")),
        book, t, h, args, next, steps, fuel)
    case _: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_let_dead(dead: Bool, +book: List<&2,KDef>, +t: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match dead:
    case True{}: p205v_eval(book,body,next,U32.inc(steps),fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_let_stat(st: Bool, +book: List<&2,KDef>, +t: KTerm, +rhs: KTerm, +srhs: KTerm, +bid: U32, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match st:
    case True{}: p205v_eval(book,subst(body,bid,srhs),next,U32.inc(steps),fuel)
    case False{}: w5c3_let_dead(Bool.not(w5c3_has_var(body,bid)) && p205v_pure(book,rhs,16), book, t, body, next, steps, fuel)

@unsafe
def p205v_let_step(+book: List<&2,KDef>, +t: KTerm, +b: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  +rhs = kid(b,0)
  +bid = ix(b)
  +srhs = j_strip(rhs)
  w5c3_let_stat(p205v_static(srhs), book, t, rhs, srhs, bid, body, next, steps, fuel)

@unsafe
def p205v_fresh(+book: List<&2,KDef>, +old: KTerm, +args: List<&2,KTerm>, +steps: U32, +fuel: U32, +fresh: FFresh) -> P205UResult:
  match fresh:
    case FFresh{body,next}: p205v_apply(book,body,args,next,U32.inc(steps),fuel)
@unsafe
def w5c3_p205v_body_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_typed(p205v_fresh(book,t,ks(call),steps,fuel,f_fresh_term(body,[],next)),p205v_after_args(book,dt(d),terms_len(ks(call))))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  w5c3_p205v_body_if(p205v_allowed(body) && U32.is_eq(p205u_refs(body,dn(d)),0), book, t, next, steps, fuel, call, d, body)

@unsafe
def w5c3_p205v_def_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  match ok:
    case True{}: p205v_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d)))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_def(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  w5c3_p205v_def_if(String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && p205u_room([dv(d)],512) && p205v_result_type(book,dt(d)), book, t, next, steps, fuel, call, d)

@unsafe
def w5c3_p205v_any_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_def(book,t,next,steps,fuel,call,lookup(book,nm(call)))
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_p205v_folded_if(is_abs: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  match is_abs:
    case True{}: w5c3_p205v_any_if(p205v_any_with_range(book,ks(call)), book, t, next, steps, fuel, call)
    case False{}: P205UResult{folded,next,U32.inc(steps),True{}}

@unsafe
def p205v_folded(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  w5c3_p205v_folded_if(p98_tag_eq(folded,"Absent"), book, t, next, steps, fuel, call, folded)

@unsafe
def w5c3_p205v_call_if(ok: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  match ok:
    case True{}: p205v_folded(book,t,next,steps,fuel,call,p205v_fold(book,t,call,ks(call)))
    case False{}: p205v_try_beta(book,t,next,steps,fuel,p205v_mat_spine(t,[]))

@unsafe
def p205v_call(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  w5c3_p205v_call_if(p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5), book, t, next, steps, fuel, call)

@unsafe
def w5c3_after_let(is_let: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match is_let:
    case True{}: p205v_let_step(book,t,kid(t,0),kid(t,1),next,steps,fuel)
    case False{}: P205UResult{t,next,steps,True{}}

@unsafe
def w5c3_after_app(is_app: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match is_app:
    case True{}: p205v_call(book,t,next,steps,fuel,j_call_spine(t,[]))
    case False{}:
      w5c3_after_let(p98_tag_eq(t,"Let") && U32.is_eq(terms_len(ks(t)),2) &&
        p98_tag_eq(kid(t,0),"Bind") && U32.is_eq(terms_len(ks(kid(t,0))),1), book, t, next, steps, fuel)

@unsafe
def p205v_after(+book: List<&2,KDef>, +old: KTerm, +fuel: U32, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}:
      match ok:
        case False{}: P205UResult{k_with_children(old,terms),next,steps,False{}}
        case True{}:
          +t = k_with_children(old,terms)
          w5c3_after_app(p98_tag_eq(t,"App"), book, t, next, steps, fuel)

@unsafe
def w5c3_eval_kids(+kids: List<&2,KTerm>, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +f1: U32) -> P205UResult:
  match kids:
    case Nil{}: P205UResult{t,next,steps,True{}}
    case Con{_,_}: p205v_after(book,t,f1,p205v_fields(book,kids,next,steps,f1))

@unsafe
def w5c3_eval_if(stop: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match stop:
    case True{}: P205UResult{t,next,steps,False{}}
    case False{}: w5c3_eval_kids(ks(t), book, t, next, steps, U32.sub(fuel,1))

@unsafe
def p205v_eval(book, t, next, steps, fuel):
  w5c3_eval_if(U32.is_eq(fuel,0) || U32.is_ge(steps,4096), book, t, next, steps, fuel)

# Distribute remaining args (when at least one is static) into each arm of a Mat on a dynamic scrutinee.
law p205v_dist_mat:
  for +book: List<&2,KDef>
  for +m: KTerm
  for +rest: List<&2,KTerm>
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

@unsafe
def w7_br_910(w7_c: Bool, +book: List<&2,KDef>, +br: KTerm, +k: U32, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      p205v_dist_arm_wrap(br,p205v_dist_arm(book,kid(br,0),U32.sub(k,1),rest,next,steps,fuel))
    case False{}:
      P205UResult{br,next,steps,False{}}

@unsafe
def w7_br_911(w7_c: Bool, +book: List<&2,KDef>, +br: KTerm, +k: U32, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      p205v_apply(book,br,rest,next,steps,fuel)
    case False{}:
      w7_br_910(p98_tag_eq(br,"Lam"), book, br, k, rest, next, steps, fuel)

@unsafe
def p205v_dist_arm(+book: List<&2,KDef>, +br: KTerm, +k: U32, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  w7_br_911(U32.is_eq(k,0), book, br, k, rest, next, steps, fuel)

@unsafe
def p205v_dist_mat_br(+book: List<&2,KDef>, +m: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +r1: P205UResult) -> P205UResult:
  match r1:
    case P205UResult{br2,next,steps,ok}:
      kc(P205UResult,ok,
        u => p205v_dist_mat_alt(m,br2,p205v_dist_mat(book,kid(m,1),rest,next,steps,fuel)),
        u => P205UResult{m,next,steps,False{}})

@unsafe
def w7_br_912(w7_c: Bool, +book: List<&2,KDef>, +m: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      p205v_dist_mat_br(book,m,rest,fuel, p205v_dist_arm(book,kid(m,0),da(j_find_ctor(book,nm(m))),rest,next,steps,fuel))
    case False{}:
      P205UResult{m,next,steps,False{}}

@unsafe
def w7_br_913(w7_c: Bool, +book: List<&2,KDef>, +m: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      P205UResult{m,next,steps,True{}}
    case False{}:
      w7_br_912(p98_tag_eq(m,"Mat") && U32.is_eq(ix(m),0) && U32.is_eq(terms_len(ks(m)),2), book, m, rest, next, steps, fuel)

@unsafe
def p205v_dist_mat(book, m, rest, next, steps, fuel):
  w7_br_913(p98_tag_eq(m,"Efq"), book, m, rest, next, steps, fuel)

@unsafe
def p205v_apply(book, body, args, next, steps, fuel):
  match args:
    case Nil{}: p205v_eval(book,body,next,steps,fuel)
    case Con{arg,rest}:
      +sa = j_strip(arg)
      kc(P205UResult,p98_tag_eq(body,"Lam") && U32.is_ne(qt(body),0) && U32.is_ne(qt(body),3),u =>
        kc(P205UResult,p205v_static(sa) || p98_tag_eq(sa,"Var") || (p205v_has_range(book,sa) && p205u_room([sa],16) && p205v_pure(book,sa,8)),
          v => p205v_apply(book,subst(kid(body,0),ix(body),sa),rest,next,steps,fuel),v =>
          kc(P205UResult,U32.is_eq(p205u_vars(kid(body,0),ix(body)),0) && p205v_pure(book,sa,16),
            w => p205v_apply(book,kid(body,0),rest,next,steps,fuel),
            w => p205u_bound(book,body,arg,p205v_apply(book,kid(body,0),rest,next,steps,fuel)))),u =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && U32.is_eq(ix(body),0) && U32.is_eq(terms_len(ks(body)),2) && p98_tag_eq(sa,"Ctr"),v =>
        kc(P205UResult,agy_str_eq(nm(body),nm(sa)),w => p205v_apply(book,kid(body,0),nt_append(KTerm,ks(sa),rest),next,steps,fuel),w =>
          p205v_apply(book,kid(body,1),args,next,steps,fuel)),v =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && U32.is_eq(ix(body),0) && U32.is_eq(terms_len(ks(body)),2) &&
        Bool.not(List.is_empty(&2,KTerm,rest)) && p205v_any(rest),
        w => p205v_dist_wrap(nd_reapply(body,args),arg,p205v_dist_mat(book,body,rest,next,U32.inc(steps),fuel)),
        w => P205UResult{nd_reapply(body,args),next,steps,True{}})))

@unsafe
def w7_br_914(w7_c: Bool, +book: List<&2,KDef>, +first: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205v_finish(first,p205v_eval(book,first,U32.inc(U32.max(norm_book_bound(book),norm_max_term(first))),0,1024))
    case False{}:
      first

@unsafe
def w7_br_915(w7_c: Bool, +book: List<&2,KDef>, +first: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      first
    case False{}:
      w7_br_914(j_u32_native_book(book) && U32.is_lt(U32.max(norm_book_bound(book),norm_max_term(first)),4294800000), book, first)

@unsafe
def w2d_emit_unboxed_outer(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32, +next: U32, +chk_i: KDef) -> W2State:
  +ctx1 = agy_bf_add_def(ctx,chk_i)
  +new_body = w2d_rewrite_to_inner(raw_body,hname,cname,iname,ar)
  +hdef2 = dg_event_output(hdef,new_body)
  +ctx2 = agy_bf_add_def(ctx1,hdef2)
  +chk_h = agy_bf_check_one(ctx2,hdef2)
  kc(W2State,agy_str_eq(dk(chk_h),"Absent"),
    u => W2State{ctx,added,next,atom("Absent"),False{}},
    u => W2State{agy_bf_add_def(ctx1,chk_h),Con{chk_h,Con{chk_i,added}},next,atom("Absent"),True{}})

@unsafe
def w2d_emit_unboxed(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +cname: String, +iname: String, +fty: KTerm, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +hid: U32, +h_next: KTerm, +rargs: List<&2,KTerm>) -> W2State:
  +zvs = agy_bf_fresh_lams(U32.sub(ar,1),next,0)
  +z_body = agy_bf_wrap_vars(zvs,w2d_last(zvs))
  +s_lams = nt_append(KTerm,w2d_init(lams1),[agy_bf_lam("$w2h",hid,2,atom("Absent"))])
  +rec_call = agy_bf_apps(ref(iname),nt_append(KTerm,rargs,[h_next]))
  +s_body = agy_bf_wrap_lams(s_lams,w2d_wrap_lets(bs,rec_call))
  +ibody = kt("Mat","Zero",0,0,[z_body,kt("Mat","Succ",0,0,[s_body,atom("Efq")])])
  +ity = w2d_builder_fused_ty(dt(hdef),ar,fty)
  +idef = {KDef{iname,"Def",ar,0,ity,ibody,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,idef)
  +chk_i = agy_bf_check_one(ctx1,idef)
  kc(W2State,agy_str_eq(dk(chk_i),"Absent"),
    u => W2State{ctx,added,U32.add(next,16),atom("Absent"),False{}},
    u => w2d_emit_unboxed_outer(ctx,added,hdef,raw_body,hname,cname,iname,ar,U32.add(next,16),chk_i))

@unsafe
def w2d_try_unbox_arm(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +tapp: KTerm, +acc_id: U32, +arm: W2UnboxArm) -> W2State:
  match arm:
    case W2UnboxArm{cname,hid,h_next,rargs,True{}}:
      +fty = w2d_ctor_field_ty(ctx,cname)
      +iname = hname ++ "$c"
      kc(W2State,Bool.not(p98_tag_eq(fty,"Absent")) && agy_str_eq(dk(lookup(ctx,iname)),"Absent"),
        u => w2d_emit_unboxed(ctx,added,hdef,raw_body,hname,cname,iname,fty,ar,next,zbr,lams1,bs,hid,h_next,rargs),
        u => W2State{ctx,added,next,atom("Absent"),False{}})
    case _: W2State{ctx,added,next,atom("Absent"),False{}}

@unsafe
def w2d_try_unbox_tuple_lets(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +lm: KTerm, +lacc: KTerm, +wl: W2Lets) -> W2State:
  match wl:
    case W2Lets{bs,inner}:
      +tbody = j_strip(inner)
      kc(W2State,p98_tag_eq(tbody,"App") && agy_bf_is_var(kid(tbody,1),ix(lm)),
        u => w2d_try_unbox_arm(ctx,added,hdef,raw_body,hname,ar,next,zbr,nt_append(KTerm,lams1,[lm]),bs,tbody,ix(lacc),
          w2d_find_self_arm(kid(tbody,0),hname,ar,ix(lacc))),
        u => W2State{ctx,added,next,atom("Absent"),False{}})

@unsafe
def w2d_reduce_step_raw(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +raw: FFresh) -> FFresh:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,512)
      +e1 = p205v_finish(e0,ev)
      +e2 = w2d_hoist_fst_ann(ctx,e1,st_ty,acc_ty)
      FFresh{e2,U32.inc(U32.max(n2,norm_max_term(e2)))}

@unsafe
def w2d_reduce_step_fr(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +ch: KTerm, +st: KTerm, +fr: FFresh) -> FFresh:
  match fr:
    case FFresh{sf,n1}:
      w2d_reduce_step_raw(ctx,st_ty,acc_ty,kc(FFresh,w2d_is_small_mat(st),
        u => w2d_push_into_mat(app(sf,ch),st,n1),
        u => FFresh{app(app(sf,ch),st),n1}))

@unsafe
def w2d_inline_char_fr(+ctx: List<&2,KDef>, +orig: KTerm, +args: List<&2,KTerm>, +fr: FFresh) -> FFresh:
  match fr:
    case FFresh{fb,n1}: w2d_inline_char_res(orig,p205v_apply(ctx,fb,args,n1,0,256))

@unsafe
def w7_br_933(w7_c: Bool, +ctx: List<&2,KDef>, +sc: KTerm, +call: KTerm, +d: KDef, +next: U32) -> FFresh:
  match w7_c:
    case True{}:
      w2d_inline_char_fr(ctx,sc,ks(call),f_fresh_term(p205u_clean(dv(d)),[],next))
    case False{}:
      FFresh{sc,next}

@unsafe
def w2d_lift_closed_mat_build(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +dom_ty: KTerm, +ret_ty: KTerm, +m: KTerm, +arg: KTerm) -> W2State:
  +ty = all(1,"$w2x",0,dom_ty,ret_ty)
  +hdef = {KDef{hname,"Def",1,0,ty,j_strip(m),[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,agy_str_eq(dk(chk),"Absent"),
    u => W2State{ctx,added,0,app(m,arg),False{}},
    u => W2State{agy_bf_add_def(ctx,chk),Con{chk,added},0,app(ref(hname),arg),True{}})

@unsafe
def w7_br_935(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +dom_ty: KTerm, +ret_ty: KTerm, +m: KTerm, +arg: KTerm) -> W2State:
  match w7_c:
    case True{}:
      W2State{ctx,added,0,app(m,arg),False{}}
    case False{}:
      w2d_lift_closed_mat_build(ctx,added,hname,dom_ty,ret_ty,m,arg)

@unsafe
def w2d_lift_closed_mat(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +dom_ty: KTerm, +ret_ty: KTerm, +m: KTerm, +arg: KTerm) -> W2State:
  w7_br_935(Bool.not(agy_str_eq(dk(lookup(ctx,hname)),"Absent")), ctx, added, hname, dom_ty, ret_ty, m, arg)

# Lift a 2-arg Mat with 1 free var `acc_id` (e.g. op.pick fused with step on Gap{}) to a top-level 3-arg Def!
@unsafe
def w2d_lift_mat2_build(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  +d0 = w2d_ctor_owner_ty(ctx,nm(mat))
  +d1 = w2d_ctor_owner_ty(ctx,nm(j_strip(kid(mat,0))))
  +ty = all(1,"$w2b0",0,d0,all(1,"$w2b1",0,d1,all(2,"$w2acc",acc_id,acc_ty,acc_ty)))
  +body = w2d_mat_add_lam(mat,acc_id)
  +hdef = {KDef{hname,"Def",3,0,ty,body,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,agy_str_eq(dk(chk),"Absent"),
    u => W2State{ctx,added,0,app(app(w2d_ann_mat(ctx,mat,acc_ty,acc_ty),a0),a1),False{}},
    u => W2State{agy_bf_add_def(ctx,chk),Con{chk,added},0,app(app(app(ref(hname),a0),a1),acc_arg),True{}})

@unsafe
def w7_br_936(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  match w7_c:
    case True{}:
      W2State{ctx,added,0,app(app(w2d_ann_mat(ctx,mat,acc_ty,acc_ty),a0),a1),False{}}
    case False{}:
      w2d_lift_mat2_build(ctx,added,hname,mat,a0,a1,acc_id,acc_ty,acc_arg)

@unsafe
def w2d_lift_mat2_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  w7_br_936(Bool.not(agy_str_eq(dk(lookup(ctx,hname)),"Absent")), ctx, added, hname, mat, a0, a1, acc_id, acc_ty, acc_arg)

@unsafe
def w2d_lift_mat2_acc(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +m_expr: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  +s = j_strip(m_expr)
  kc(W2State,p98_tag_eq(s,"App") && p98_tag_eq(j_strip(kid(s,0)),"App") && p98_tag_eq(j_strip(kid(j_strip(kid(s,0)),0)),"Mat"),
    u => w2d_lift_mat2_go(ctx,added,hname,j_strip(kid(j_strip(kid(s,0)),0)),kid(j_strip(kid(s,0)),1),kid(s,1),acc_id,acc_ty,acc_arg),
    u => W2State{ctx,added,0,m_expr,False{}})

@unsafe
def w2d_push_nil_raw(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +raw: FFresh) -> W2State:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,256)
      +e1 = p205v_finish(e0,ev)
      W2State{ctx,added,U32.inc(U32.max(n2,norm_max_term(e1))),w2d_rebind_senv(senv,e1),True{}}

@unsafe
def w2d_push_nil_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +st: KTerm, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{nf,n1}:
      w2d_push_nil_raw(ctx,added,senv,kc(FFresh,w2d_is_small_mat(st),
        u => w2d_push_into_mat(nf,st,n1),
        u => FFresh{app(nf,st),n1}))

@unsafe
def w2d_try_def_res(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +r: W2State) -> AgyBFResult:
  match r:
    case W2State{ctx2,added2,_,term2,True{}}:
      +cand_d = dg_event_output(raw,term2)
      +ctx3 = p205z_advance(ctx2,cand_d)
      +chk = agy_bf_check_one(ctx3,cand_d)
      kc(AgyBFResult,agy_str_eq(dk(chk),"Absent"),
        u => AgyBFResult{ctx,Con{orig_d,rest},False{}},
        u => AgyBFResult{p205z_advance(ctx3,chk),nt_append(KDef,nt_reverse(KDef,added2,[]),Con{chk,rest}),True{}})
    case _: AgyBFResult{ctx,Con{orig_d,rest},False{}}

law p111_lower:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

law p111_live:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

@unsafe
def p111_lower_partition(+book: List<&2, KDef>, +t: KTerm, +n: U32, parts: P111Partition) -> P111Code:
  match parts:
    case P111Partition{+live, +drop}: p111_prepend(drop, p111_live(book, t, live, n))

@unsafe
def p111_lower(book, t, env, n):
  nt_choose(P111Code, p98_tag_eq(t, "Let") || p98_tag_eq(t, "NSeqLet"),
    u => p112_liveness_lower(book, p112_liveness_terms(ks(t)), env, n),
    u => p112_liveness_other(book, t, env, n))

@unsafe
def p111_lets(+book: List<&2, KDef>, terms: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p112_liveness_live(book, p112_liveness_terms(terms), env, n)

@unsafe
def p111_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +name = p111_name(n)
  +params = nt_append(NC_Binding, env, [nc_binding(ix(t))])
  +body = p111_lower(book, kid(t, 0), params, U32.inc(n))
  +seg : N111Segment = p111_segment(name, params, 0, 0, p111_body(body))
  +result = p111_prepend(nt_append(N111Stmt, p111_store(p111_env_words(env), 0), [N111Call{"value", N111U64{}, "p111_rt_closure", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(NC_Binding, env))]}]), p111_return(N111Local{"value"}, p111_fresh(body)))
  P111Code{p111_body(result), Con{seg, p111_segments(body)}, p111_fresh(body), p111_error(body)}

@unsafe
def p111_slow_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +f = nc_id(n)
  +a = nc_id(U32.inc(n))
  p111_lower(book, nc_mklet(f, kid(t, 0), nc_mklet(a, kid(t, 1), kt("NApply", "", 0, 0, [var("", f), var("", a)]))), env, U32.add(n, 2))

@unsafe
def p111_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  +prim = nd_native_call(book, t)
  nt_choose(P111Code, agy_str_eq(prim, ""),
    u =>
  nt_choose(P111Code, agy_str_eq(tg(head), "Lam"), u => p111_lower(book, nd_beta(head, args), env, n), u =>
  nt_choose(P111Code, agy_str_eq(tg(head), "Mat"),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), 1) || nd_match_vars(args),
      v => p111_lower(book, nd_match_sequence(head, args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)), u =>
  nt_choose(P111Code, agy_str_eq(tg(head), "Ref"),
    u => p111_ref_app(book, t, head, args, env, n),
    u => p111_slow_app(book, t, env, n)))), u => p111_lower(book, nc_sequence("NOp", prim, args, Nil{}, n), env, U32.add(n, terms_len(args))))

@unsafe
def p111_ref_app(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p113dc_generic(book,t,head,args,env,n)

@unsafe
def p111_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p112m_match_apply(book,t,env,n)

@unsafe
def p111_match_value(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p111_lambda(book, k_lam("", nc_id(n), 1, [kt("NMatch", "", 0, 0, [t, var("", nc_id(n))])], 0, 0, False{}), env, U32.inc(n))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-dispatch.bend
@unsafe
def p111_lower_ctor(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +value}:
      nt_choose(P111Code, valid, u => p111_return(N111Const{value, 0}, n),
        u => p111_lower(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t)))))

@unsafe
def p111_live(book,t,env,n):
  nt_choose(P111Code,agy_str_eq(tg(t),"NStatic"),u => p111_value_return(p112s_value(book,t),n),
    u => p112s_live_fallback(book,t,env,n))

@unsafe
def p111_extend(+book: List<&2, KDef>, +body: KTerm, +base: P111Code, +name: String, +arity: U32) -> P111Code:
  +params = nk_typed_bindings(nd_entry_params(arity, p111_fresh(base)), nf_worker_kinds(book, name, arity))
  nt_choose(P111Code, U32.is_eq(arity, 0), u => base,
    u => p111_entry_join(base, p111_lower(book, nd_reapply(body, nd_entry_args(params)), params, U32.add(p111_fresh(base), arity)), nc_ref_name(book, name), params))

@unsafe
def p111_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +bang: Bool) -> P111Code:
  +d = lookup(book, name)
  +arity = nd_arity(book, name)
  +typed = jd_live_arity(book, dt(d), jd_arity(book, d))
  +eta = Bool.not(bang || nc_native_def(d) || nc_foreign(d)) && U32.is_gt(typed, 0) && U32.is_eq(typed, arity)
  +params = nd_entry_params(arity, n)
  +factory = nt_choose(P111Code, eta,
    u => p111_lower(book, nd_eta_body(params, kt("NCall", nd_name(nc_ref_name(book, name)), 0, 0, nd_entry_args(params))), Nil{}, U32.add(n, arity)),
    u => p111_lower(book, body, Nil{}, n))
  p111_extend(book, body, factory, name, arity)

@unsafe
def p112_liveness_lower_partition(+book: List<&2, KDef>, +plan: P112Liveness, +n: U32, parts: P111Partition) -> P111Code:
  match parts:
    case P111Partition{+live, +drop}: p111_prepend(drop, p112_liveness_live(book, plan, live, n))


@unsafe
def p112_liveness_lower(+book: List<&2, KDef>, +plan: P112Liveness, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p112_liveness_lower_partition(book, plan, n, p111_partition(env, p112_liveness_uses(plan)))


@unsafe
def p112_liveness_value(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = p112_liveness_uses(rest)
      +held = nc_live_uses(env, uses)
      +body = p112_liveness_lower(book, rest, nt_append(NC_Binding, held, [p113_binding(book, id, value, env)]), n)
      nt_choose(P111Code, agy_str_eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), body),
        u => p111_fail(error, n))

@unsafe
def p112_liveness_cut(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = p112_liveness_uses(rest)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [p113_binding(book, id, value, env)])
  +body = p112_liveness_lower(book, rest, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(body))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(body))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(body), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(body), p111_error(val))}

@unsafe
def p112_liveness_ctor(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +word}:
      nt_choose(P111Code, valid,
        u => p112_liveness_value(book, value, rest, env, id, n, P111ValueCode{Nil{}, N111Const{word, 0}, ""}),
        u => p112_liveness_lower(book, p112_liveness_args("NCtr", nm(value), ks(value), Nil{}, n, id, rest), env, U32.add(n, terms_len(ks(value)))))


@unsafe
def p112_liveness_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +n: U32) -> P111Code:
  nt_choose(P111Code,agy_str_eq(tg(value),"NStatic"),u => p112_liveness_value(book,value,rest,env,id,n,p112s_value(book,value)),
    u => p112s_liveness_fallback(book,value,rest,env,id,n))

@unsafe
def p112_liveness_live(+book: List<&2, KDef>, plan: P112Liveness, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match plan:
    case P112LivenessEmpty{}: p111_fail("empty native let", n)
    case P112LivenessLeaf{+term, uses}: p111_live(book, term, env, n)
    case P112LivenessLet{+value, +id, uses, +rest}: p112_liveness_let(book, value, rest, env, id, n)

# Entry dispatch prepares a sequence once before its first partition, avoiding
# the original whole-sequence scan followed by scans of every shrinking suffix.


@unsafe
def p112_liveness_other(+book: List<&2, KDef>, +t: KTerm, env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match env:
    case Nil{}: p111_live(book, t, Nil{}, n)
    case Con{+head, +rest}: p111_lower_partition(book, t, n, p111_partition(Con{head, rest}, nc_uses(t)))


law p112s_live_fallback:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code


@unsafe
def p112s_live_fallback(book, t, env, n):
  +tag = tg(t)
  nt_choose(P111Code, agy_str_eq(tag, "NWord") || agy_str_eq(tag, "Var"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Ref"), u => p111_jump(nc_ref_name(book, nm(t)), Nil{}, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Loc") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Cut") || agy_str_eq(tag, "Slf") || agy_str_eq(tag, "Ins"), u => p111_lower(book, kid(t, 0), env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Lam"), u => p111_lambda(book, t, env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "App"), u => p111_app(book, t, env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Let") || agy_str_eq(tag, "NSeqLet"), u => p111_lets(book, ks(t), env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NNatAdd"), u => p111_lower(book, nc_sequence("NNatSum", nm(t), ks(t), Nil{}, n), env, U32.inc(n)), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NNatSum"), u => p111_nat_sum_finish(p111_values(ks(t), env), n, U32.read(nm(t))), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Ctr"), u => p111_lower_ctor(book, t, env, n, nc_literal(t)), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NCtr") || agy_str_eq(tag, "NOp"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NApply"), u => p111_apply(p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NCall"), u => p111_jump(nm(t), p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Rfl") || agy_str_eq(tag, "Typ") || agy_str_eq(tag, "All") || agy_str_eq(tag, "Qua") || agy_str_eq(tag, "ADT") || agy_str_eq(tag, "Eql"), u => p111_return(N111Const{0, 0}, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Mat"), u => p111_match_value(book, t, env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "NMatch"), u => p111_match_apply(book, t, env, n), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Efq"), u => P111Code{[N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(4)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}, u =>
  nt_choose(P111Code, agy_str_eq(tag, "Rwt"), u => p111_lower(book, kid(t, 2), env, n), u =>
    p111_fail("structured native lowering does not support core node " ++ tag, n))))))))))))))))))


@unsafe
def p112b_original_ref_app(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code, U32.is_eq(qt(head), 3), u => p111_slow_app(book, t, env, n),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), nd_arity(book, nm(head))),
      v => p111_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)))


@unsafe
def p112b_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,p98_tag_eq(selected,"Absent"),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,U32.add(n,64)))


@unsafe
def p112b_ref_app(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,U32.is_eq(qt(head),3),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => nt_choose(P111Code,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P111Code,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p112b_selected(book,t,head,args,env,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p112b_original_ref_app(book,t,head,args,env,n)),
      v => p112b_original_ref_app(book,t,head,args,env,n)))


@unsafe
def p112m_original_match_apply(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word : N111Value = N111Local{nc_word(ix(arg), env)}
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = p111_lower(book, nd_reapply(nc_field_apps(kid(mat, 0), count, 0, n), nd_match_rest(t)), nt_append(NC_Binding, nc_remove_env(env, ix(arg)), p111_field_env(count, 0, n)), U32.add(n, count))
  +miss = p111_lower(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, p111_fresh(hit))
  +branch = nt_append(N111Stmt, p111_test(nm(mat), word), [N111If{N111Local{"match_condition"}, nt_append(N111Stmt, p111_take(nm(mat), word, count, n), p111_body(hit)), p111_body(miss)}])
  P111Code{p111_guard_io(nm(mat), word, branch), nt_append(N111Segment, p111_segments(hit), p111_segments(miss)), p111_fresh(miss), p111_first(p111_error(hit), p111_error(miss))}


@unsafe
def p112m_row_code(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +base: U32, +fresh: U32) -> P111Code:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p111_prepend(prefix,p111_lower(book,kid(row,0),bindings,fresh))


law p112m_emit:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +base: U32
  for +fresh: U32
  P111Code


@unsafe
def p112m_emit_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +base: U32, +yes: P111Code) -> P111Code:
  p112m_join(row,base,yes,p112m_emit(book,rows,env,base,p111_fresh(yes)))


@unsafe
def p112m_emit(book,rows,env,base,fresh):
  match rows:
    case Nil{}: P111Code{[N111Call{"reply",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]},N111Return{N111Local{"reply"}}],[],fresh,""}
    case Con{+row,more}: p112m_emit_more(book,row,more,env,base,p112m_row_code(book,row,env,base,fresh))


@unsafe
def p112m_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, plan: NW_Rows) -> P111Code:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P111Code,valid,
        u => p111_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p112m_emit(book,rows,nc_remove_env(env,ix(kid(t,1))),n,U32.add(n,3))),
        u => p112m_original_match_apply(book,t,env,n))


@unsafe
def p112m_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, recognized: NW_Rows) -> P111Code:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P111Code,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p112m_planned(book,t,env,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p112m_original_match_apply(book,t,env,n))


@unsafe
def p112m_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,nw_applicable(kid(t,0)) && U32.is_lt(n,4294967293),
    u => nt_choose(P111Code,p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p112m_recognized(book,t,env,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p112m_original_match_apply(book,t,env,n)),
    u => p112m_original_match_apply(book,t,env,n))


@unsafe
def p112s_liveness_fallback(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, agy_str_eq(tag, "Var") || agy_str_eq(tag, "NWord") || agy_str_eq(tag, "NCtr") || agy_str_eq(tag, "NOp"),
    u => p112_liveness_value(book, value, rest, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, agy_str_eq(tag, "Ctr"), u => p112_liveness_ctor(book, value, rest, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, agy_str_eq(prim, ""),
    u => p112_liveness_cut(book, value, rest, env, id, n),
    u => p112_liveness_lower(book, p112_liveness_args("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, rest), env, U32.add(n, terms_len(nd_args(value, Nil{})))))))


law p113d_lower:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  P113DCode


law p113d_live:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  P113DCode


@unsafe
def p113d_partition(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P113DTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113d_live(book,t,live,owner,target,n))


@unsafe
def p113d_lower(book,t,env,owner,target,n):
  nt_choose(P113DCode,agy_str_eq(tg(t),"Let") || agy_str_eq(tg(t),"NSeqLet"),
    u => p113dl_lower(book,p112_liveness_terms(ks(t)),env,owner,target,n),
    u => p113dl_other(book,t,env,owner,target,n))

@unsafe
def p113d_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_live(book,p112_liveness_terms(terms),env,owner,target,n)

@unsafe
def p113d_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dc_direct(book,head,args,env,owner,target,n)

@unsafe
def p113d_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  nt_choose(P113DCode,agy_str_eq(tg(head),"Efq"),
    u => p113d_live(book,head,env,owner,target,n),
    u => p113da_original_app(book,t,env,owner,target,n))

@unsafe
def p113d_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dm_match(book,t,env,owner,target,n)

@unsafe
def p113d_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P113DCode,valid,u => p113d_result(N111Const{word,0},target,n),
        u => p113d_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,owner,target,U32.add(n,terms_len(ks(t)))))


@unsafe
def p113d_live(book,t,env,owner,target,n):
  +tag = tg(t)
  nt_choose(P113DCode,agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"NStatic"),u => p113d_emitted(target,n,p113d_value(book,t,env)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ref"),u => p113d_ref(book,t,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Loc") || agy_str_eq(tag,"Src") || agy_str_eq(tag,"Cut") || agy_str_eq(tag,"Slf") || agy_str_eq(tag,"Ins"),u => p113d_lower(book,kid(t,0),env,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"App"),u => p113d_app(book,t,env,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Let") || agy_str_eq(tag,"NSeqLet"),u => p113d_lets(book,ks(t),env,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NNatAdd"),u => p113d_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,owner,target,U32.inc(n)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NNatSum"),u => p113d_nat(p111_values(ks(t),env),target,n,U32.read(nm(t))),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Ctr"),u => p113d_ctor(book,t,env,owner,target,n,nc_literal(t)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NCtr") || agy_str_eq(tag,"NOp"),u => p113d_emitted(target,n,p113d_value(book,t,env)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NCall"),u => p113d_call(nm(t),p111_values(ks(t),env),owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"All") || agy_str_eq(tag,"Qua") || agy_str_eq(tag,"ADT") || agy_str_eq(tag,"Eql"),u => p113d_result(N111Const{0,0},target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"NMatch"),u => p113d_match(book,t,env,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Efq"),u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},target,n)),u =>
  nt_choose(P113DCode,agy_str_eq(tag,"Rwt"),u => p113d_lower(book,kid(t,2),env,owner,target,n),
    u => p113d_fail("direct: unsupported core node " ++ tag,n)))))))))))))))


law p171ff_direct_match:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  for +mat: KTerm
  P113DCode

@unsafe
def p113dm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  nt_choose(P113DCode,agy_str_eq(nm(mat),"Emit") || agy_str_eq(nm(mat),"Halt"),
    u => p113d_fail("direct: effect match",n),
    u => p171ff_direct_match(book,t,env,owner,target,n,mat))

@unsafe
def p113da_original_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,String.is_empty(prim),
    u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Lam"),u => p113d_lower(book,nd_beta(head,args),env,owner,target,n),u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nd_match_vars(args),
      v => p113d_lower(book,nd_match_sequence(head,args,[],n),env,owner,target,U32.add(n,terms_len(args))),
      v => p113d_fail("direct: higher-order matcher",n)),u =>
  nt_choose(P113DCode,agy_str_eq(tg(head),"Ref"),u => p113d_ref_app(book,head,args,env,owner,target,n),
    u => p113d_fail("direct: dynamic call head=" ++ tg(head) ++ ":" ++ nm(head),n)))),u => p113d_lower(book,nc_sequence("NOp",prim,args,[],n),env,owner,target,U32.add(n,terms_len(args))))


@unsafe
def p113dl_partition(+book: List<&2,KDef>, +plan: P112Liveness, +owner: String, +target: P113DTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113dl_live(book,plan,live,owner,target,n))


@unsafe
def p113dl_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_partition(book,plan,owner,target,n,p111_partition(env,p112_liveness_uses(plan)))

@unsafe
def p113dl_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113dl_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first)))),u => first)

@unsafe
def p113dl_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("direct: empty let",n)
    case P112LivenessLeaf{term,uses}: p113d_live(book,term,env,owner,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113dl_let(book,value,rest,env,id,owner,target,n)


@unsafe
def p113dl_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113d_live(book,t,[],owner,target,n)
    case Con{head,rest}: p113d_partition(book,t,owner,target,n,p111_partition(Con{head,rest},nc_uses(t)))


@unsafe
def p113dm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +base: U32, +fresh: U32) -> P113DCode:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p113d_prepend(prefix,p113d_lower(book,kid(row,0),bindings,owner,target,fresh))


law p113dm_rows:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +base: U32
  for +fresh: U32
  P113DCode


@unsafe
def p113dm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113dm_join(row,base,yes,p113dm_rows(book,rows,env,owner,target,base,p113d_fresh(yes))),u => yes)


@unsafe
def p113dm_rows(book,rows,env,owner,target,base,fresh):
  match rows:
    case Nil{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},target,fresh))
    case Con{+row,more}: p113dm_more(book,row,more,env,owner,target,base,p113dm_row(book,row,env,owner,target,base,fresh))


@unsafe
def p113dm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, plan: NW_Rows) -> P113DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P113DCode,valid,
        u => p113d_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p113dm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),owner,target,n,U32.add(n,3))),
        u => p113d_fail("direct: escaping Word tail retains generic recovery",n))


@unsafe
def p113dm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, recognized: NW_Rows) -> P113DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P113DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p113dm_planned(book,t,env,owner,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p113d_fail("direct: unrecognized Word rows retain generic recovery",n))


@unsafe
def p113dm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P113DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p113dm_recognized(book,t,env,owner,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p113d_fail("direct: Word row freshness refusal",n)),
    u => p113dm_original_match(book,t,env,owner,target,n))


@unsafe
def p113db_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("direct: partial or bang call",n),
    u => p113d_lower(book,nc_sequence("NCall",p113d_public(book,nm(head)),args,[],n),env,owner,target,U32.add(n,terms_len(args))))


@unsafe
def p113db_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,p98_tag_eq(selected,"Absent"),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,U32.add(n,64)))


@unsafe
def p113db_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => nt_choose(P113DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P113DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p113db_selected(book,head,args,env,owner,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p113db_original_ref_app(book,head,args,env,owner,target,n)),
      v => p113db_original_ref_app(book,head,args,env,owner,target,n)))


@unsafe
def p113e_function(+function: P113DFunction, +ids: N111Ids, +ready: KDef) -> String:
  match function ids:
    case P113DFunction{+name,+params,+result,+public,+body} N111Ids{+original,constructors}:
      +old = p111v_get(original,name)
      nt_choose(String,Bool.not(p111v_raw_name(name)) || Bool.not(agy_str_eq(dk(p111v_get(ready,name)),"Absent")),u => "invalid/duplicate direct function identity",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),255) || U32.is_lt(result,1) || U32.is_gt(result,8),u => "direct signature exceeds ABI boundary",u =>
      nt_choose(String,public && (agy_str_eq(dk(old),"Absent") || Bool.not(U32.is_eq(nt_count(NC_Binding,params),da(old))) || Bool.not(U32.is_eq(result,1)) || Bool.not(U32.is_eq(dx(old),0)) || Bool.not(U32.is_eq(ix(dv(old)),0)) || Bool.not(U32.is_eq(qt(dv(old)),1))),
        u => "public direct wrapper does not preserve original scalar ABI",
        u => p113e_seeded(body,ids,p113e_insert(ready,p113e_signature(function)),nt_count(NC_Binding,params),result,p113e_seed(params)))))


@unsafe
def p113e_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef) -> String:
  match functions:
    case Nil{}: ""
    case Con{+function,rest}:
      +error = p113e_function(function,ids,ready)
      nt_choose(String,String.is_empty(error),u => p113e_functions(rest,ids,p113e_insert(ready,p113e_signature(function))),u => error)


law p113pl_lower:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  P113DCode


law p113pl_live:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  P113DCode


@unsafe
def p113pl_partition(+book: List<&2,KDef>, +t: KTerm, +target: P113PTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113pl_live(book,t,live,target,n))


@unsafe
def w5c2_pl_lower_if(is_let: Bool, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match is_let:
    case True{}: p113px_lower(book, p112_liveness_terms(ks(t)), env, target, n)
    case False{}: p113px_other(book, t, env, target, n)

@unsafe
def p113pl_lower(book,t,env,target,n):
  +tag = tg(t)
  w5c2_pl_lower_if(String.eq(tag, "Let") || String.eq(tag, "NSeqLet"), book, t, env, target, n)

@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = w4c_bundle_params_kinds(ix(shape),n,qt(shape),0)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,nc_uses(body)),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_env(env,body),params),target,p113d_fresh(first)))),u => first)

@unsafe
def p113pl_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_live(book,p112_liveness_terms(terms),env,target,n)

@unsafe
def p113pl_call(+book: List<&2,KDef>, +name: String, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +info = lookup(p113pl_signatures(target),name)
  nt_choose(P113DCode,agy_str_eq(tg(dv(info)),"NQSig") && nq_args_fit(ks(dv(info)),args),
    u => p113pl_call_result(nm(dv(info)),p113p_words(ks(dv(info)),args,env),dt(info),target,n),
    u => nt_choose(P113DCode,nq_has_bundle(args),
      v => p113pl_lower(book,nq_opaque_args("NPCall",name,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113pl_call_result(p113d_public(book,name),p111_values(args,env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n)))


@unsafe
def p113pl_ref(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("product escaping or bang reference",n),
    u => p113pl_call(book,nm(t),[],env,target,n))


@unsafe
def p113pl_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113dc_product(book,head,args,env,target,n)

@unsafe
def w8_p113pl_app_ref(isRef: Bool, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isRef:
    case True{}: p113pl_ref_app(book,head,args,env,target,n)
    case False{}: p113d_fail("product dynamic call",n)

@unsafe
def w8_p113pl_app_mat_ok(ok: Bool, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match ok:
    case True{}: p113pl_lower(book,nd_match_sequence(head,args,[],n),env,target,U32.add(n,terms_len(args)))
    case False{}: p113d_fail("product higher-order matcher",n)

@unsafe
def w8_p113pl_app_mat(isMat: Bool, +htag: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isMat:
    case True{}: w8_p113pl_app_mat_ok(U32.is_eq(terms_len(args),1) || nq_match_args(args),book,head,args,env,target,n)
    case False{}: w8_p113pl_app_ref(agy_str_eq(htag,"Ref"),book,head,args,env,target,n)

@unsafe
def w8_p113pl_app_lam(isLam: Bool, +htag: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isLam:
    case True{}: p113pl_lower(book,nd_beta(head,args),env,target,n)
    case False{}: w8_p113pl_app_mat(agy_str_eq(htag,"Mat"),htag,book,head,args,env,target,n)

@unsafe
def w8_p113pl_app_prim(noPrim: Bool, +htag: String, +prim: String, +book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match noPrim:
    case True{}: w8_p113pl_app_lam(agy_str_eq(htag,"Lam"),htag,book,head,args,env,target,n)
    case False{}: p113pl_lower(book,nc_sequence("NOp",prim,args,[],n),env,target,U32.add(n,terms_len(args)))

@unsafe
def w8_p113pl_app_efq(isEfq: Bool, +htag: String, +book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match isEfq:
    case True{}: p113pl_live(book,head,env,target,n)
    case False{}:
      +prim = nd_native_call(book,t)
      w8_p113pl_app_prim(String.is_empty(prim),htag,prim,book,head,args,env,target,n)

@unsafe
def p113pl_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +htag = tg(head)
  +args = nd_args(t,[])
  w8_p113pl_app_efq(agy_str_eq(htag,"Efq"),htag,book,t,head,args,env,target,n)


@unsafe
def p113pl_match_boxed(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113pm_match(book,t,env,target,n)

@unsafe
def p113pl_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  nt_choose(P113DCode,agy_str_eq(tg(arg),"NQBundle"),
    u => nt_choose(P113DCode,agy_str_eq(nm(mat),nm(arg)) && U32.is_eq(ix(mat),U32.inc(terms_len(ks(arg)))),
      v => p113pl_lower(book,nd_reapply(kid(mat,0),nt_append(KTerm,ks(arg),nd_match_rest(t))),
        nt_append(NC_Binding,nq_remove_fields(env,ks(arg)),p113df_bundle_env(mat,arg,env)),target,n),
      v => p113pl_lower(book,nc_mklet(nc_id(n),kt("NQBox",nm(arg),0,0,ks(arg)),
        kt("NMatch","",0,0,Con{mat,Con{var("",nc_id(n)),nd_match_rest(t)}})),env,target,U32.inc(n))),
    u => p113pl_match_boxed(book,t,env,target,n))

@unsafe
def p113pl_operation(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nq_has_bundle(ks(t)),
    u => p113pl_lower(book,nq_opaque_args(tg(t),nm(t),ks(t),[],n),env,target,U32.add(n,terms_len(ks(t)))),
    u => nt_choose(P113DCode,agy_str_eq(tg(t),"NCtr"),
      v => p113pl_emitted(target,n,p113p_constructor(nm(t),p111_values(ks(t),env),p113pl_shape(target))),
      v => p113pl_emitted(target,U32.inc(n),p113p_primitive(nm(t),p111_values(ks(t),env),p113pl_shape(target),n))))


@unsafe
def p113pl_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  nt_choose(P113DCode,p118t_eligible(t,target,n),u =>
    p113pl_lower(book,ntr_sequence(nm(t),terms_len(ntr_prefix(ks(t))),
      nt_append(KTerm,ntr_prefix(ks(t)),nd_args(ntr_last(ks(t)),[])),[],n),
      env,target,U32.add(n,U32.add(terms_len(ntr_prefix(ks(t))),ix(p113pl_shape(target))))),
    u => p118t_original_ctor(book,t,env,target,n,literal))

@unsafe
def w5c2_pl_live_if(is_ntr: Bool, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match is_ntr:
    case True{}: p118t_extend(t, env, target, n)
    case False{}: p118t_original_live(book, t, env, target, n)

@unsafe
def p113pl_live(book,t,env,target,n):
  w5c2_pl_live_if(p98_tag_eq(t, "NTRCons"), book, t, env, target, n)

@unsafe
def p113pl_boxed_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  p126s_candidate(book,name,signatures,p126s_plan(book,lookup(book,name)))

@unsafe
def p113pl_flat_entry(+book: List<&2,KDef>, +name: String, +info: KDef, +signatures: List<&2,KDef>, entry: NQ_Entry) -> P113DCandidate:
  match entry:
    case NQ_Entry{params,+args,+fresh}:
      +typed = nk_typed_bindings(params,nf_expand_kinds(ks(dv(info)),nf_worker_kinds(book,name,da(info))))
      +route = nm(dv(info))
      +shape = dt(info)
      +body = nc_compact_definition(book,lookup(book,name),fresh)
      p113pl_candidate_code(route,typed,shape,False{},
        p113pl_lower(book,nd_reapply(body,args),typed,P113PTarget{[],shape,True{},route,signatures},fresh))


@unsafe
def p113pl_flat_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +info = lookup(signatures,name)
  p113pl_flat_entry(book,name,info,signatures,nq_entry(ks(dv(info)),0,da(info)))


law p171ff_product_match:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  for +mat: KTerm
  P113DCode

@unsafe
def p113pm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  nt_choose(P113DCode,agy_str_eq(nm(mat),"Emit") || agy_str_eq(nm(mat),"Halt") || nw_applicable(mat),
    u => p113d_fail("product effect or specialized Word match",n),
    u => p171ff_product_match(book,t,env,target,n,mat))

@unsafe
def p113pm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +fresh: U32) -> P113DCode:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p113d_prepend(prefix,p113pl_lower(book,kid(row,0),bindings,target,fresh))


law p113pm_rows:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +base: U32
  for +fresh: U32
  P113DCode


@unsafe
def p113pm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113pm_join(row,base,yes,p113pm_rows(book,rows,env,target,base,p113d_fresh(yes))),u => yes)


@unsafe
def p113pm_rows(book,rows,env,target,base,fresh):
  match rows:
    case Nil{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,fresh))
    case Con{+row,more}: p113pm_more(book,row,more,env,target,base,p113pm_row(book,row,env,target,base,fresh))


@unsafe
def p113pm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, plan: NW_Rows) -> P113DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P113DCode,valid,
        u => p113d_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p113pm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),target,n,U32.add(n,3))),
        u => p113d_fail("product: escaping Word tail retains generic recovery",n))


@unsafe
def p113pm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, recognized: NW_Rows) -> P113DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P113DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p113pm_planned(book,t,env,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p113d_fail("product: unrecognized Word rows retain generic recovery",n))


@unsafe
def p113pm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P113DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p113pm_recognized(book,t,env,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p113d_fail("product: Word row freshness refusal",n)),
    u => p113pm_original_match(book,t,env,target,n))


@unsafe
def p113pb_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("product partial or bang call",n),
    u => p113pl_lower(book,nc_sequence("NPCall",nm(head),args,[],n),env,target,U32.add(n,terms_len(args))))


@unsafe
def p113pb_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,p98_tag_eq(selected,"Absent"),
    u => p113pb_original_ref_app(book,head,args,env,target,n),
    u => p113pl_lower(book,selected,env,target,U32.add(n,64)))


@unsafe
def p113pb_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3),
    u => p113pb_original_ref_app(book,head,args,env,target,n),
    u => nt_choose(P113DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P113DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p113pb_selected(book,head,args,env,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p113pb_original_ref_app(book,head,args,env,target,n)),
      v => p113pb_original_ref_app(book,head,args,env,target,n)))


@unsafe
def p113px_partition(+book: List<&2,KDef>, +plan: P112Liveness, +target: P113PTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113px_live(book,plan,live,target,n))


@unsafe
def p113px_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_partition(book,plan,target,n,p111_partition(env,p112_liveness_uses(plan)))

@unsafe
def p113px_boxed(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113px_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),target,p113d_fresh(first)))),u => first)

@unsafe
def p113px_known(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +body = kt("NSeqLet","",0,0,p113px_terms(rest))
  nt_choose(P113DCode,p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => nt_choose(P113DCode,agy_str_eq(tg(value),"NQBundle") && p113df_vars(ks(value)),
      v => p113pl_lower(book,subst(body,id,value),env,target,n),
      v => p113px_boxed(book,value,rest,env,id,target,n)))


@unsafe
def w5c2_px_let_known(kn: Bool, +book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  match kn:
    case True{}: p113px_known(book,value,rest,env,id,target,n,shape)
    case False{}: p113px_boxed(book,value,rest,env,id,target,n)

@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = w5c2_px_let_shape(p98_tag_eq(value,"NPCall"), book, value, target)
  w5c2_px_let_known(p113p_known(shape), book, value, rest, env, id, target, n, shape)

@unsafe
def p113px_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("product empty let",n)
    case P112LivenessLeaf{term,uses}: p113pl_live(book,term,env,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113px_let(book,value,rest,env,id,target,n)


@unsafe
def p113px_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113pl_live(book,t,[],target,n)
    case Con{head,rest}: p113pl_partition(book,t,target,n,p111_partition(Con{head,rest},nc_uses(t)))


law w7_p113k_once:
  for +function: P113DFunction
  P113DFunction

@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,+next,budget}:
      nt_choose(P113DFunction,U32.is_eq(next,0),
        u => w7_p113k_once(original),
        u => nt_choose(P113DFunction,U32.is_le(p113i_stack(body),32768),
          v => p113k_function(P113DFunction{name,params,result,public,body}),v => original))

@unsafe
def p113dc_generic_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,agy_str_eq(tg(selected),"Absent"),
    u => p112b_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,p113dc_next(book,head,n)))


@unsafe
def p113dc_generic(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p113dc_generic_selected(book,t,head,args,env,n,p113dc_plan(book,head,args,env,n))


@unsafe
def p113dc_direct_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,agy_str_eq(tg(selected),"Absent"),
    u => p113db_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,p113dc_next(book,head,n)))


@unsafe
def p113dc_direct(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dc_direct_selected(book,head,args,env,owner,target,n,p113dc_plan(book,head,args,env,n))


@unsafe
def p113dc_product_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,agy_str_eq(tg(selected),"Absent"),
    u => p113pb_ref_app(book,head,args,env,target,n),
    u => p113pl_lower(book,selected,env,target,p113dc_next(book,head,n)))


@unsafe
def p113dc_product(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113dc_product_selected(book,head,args,env,target,n,p113dc_plan(book,head,args,env,n))


@unsafe
def p113k_scalar_next(result: P113KScalar, rest: List<&2,N111Stmt>) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: p113k_scalar_append(body,p113k_scalars(rest,facts))


@unsafe
def p113k_scalars(body: List<&2,N111Stmt>, facts: KDef) -> P113KScalar:
  match body:
    case Nil{}: P113KScalar{[],facts}
    case Con{stmt,rest}: p113k_scalar_next(p113k_scalar(stmt,facts),rest)


@unsafe
def w5c2_sc_if_lo(lo0: Bool, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef) -> P113KScalar:
  match lo0:
    case True{}: p113k_scalars(no, facts)
    case False{}: p113k_scalars(yes, facts)

@unsafe
def w5c2_sc_if_ex(exact: Bool, +bits: U32, +lo: U32, +condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef) -> P113KScalar:
  match exact:
    case True{}: w5c2_sc_if_lo(U32.is_eq(lo, 0), yes, no, facts)
    case False{}: w4g_scalar_join_opt(condition, facts, bits, p113k_scalars(yes, p113l_assume(facts, condition, True{})), p113k_scalars(no, p113l_assume(facts, condition, False{})))

@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{+bits,exact,+lo,_}:
      w5c2_sc_if_ex(exact, bits, lo, condition, yes, no, facts)

@unsafe
def p113k_scalar(+stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  p113l_scalar_done(stmt,facts,p113l_base_scalar(stmt,facts))

@unsafe
def w5c2_body_next_if(term: Bool, +result: P113KBody, +body: List<&2,P113DStmt>, +facts: KDef, +rest: List<&2,P113DStmt>) -> P113KBody:
  match term:
    case True{}: result
    case False{}: p113k_body_append(body, p113k_body(rest, facts))

@unsafe
def p113k_body_next(+result: P113KBody, +rest: List<&2,P113DStmt>) -> P113KBody:
  match result:
    case P113KBody{+body, +facts, terminal}:
      w5c2_body_next_if(terminal, result, body, facts, rest)


@unsafe
def p113k_body(body: List<&2,P113DStmt>, facts: KDef) -> P113KBody:
  match body:
    case Nil{}: P113KBody{[],facts,False{}}
    case Con{stmt,rest}: p113k_body_next(p113k_stmt(stmt,facts),rest)


@unsafe
def w4k_body_join_opt(+condition: N111Value, +facts: KDef, +cond_bits: U32, +yes: P113KBody, +no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{+yb,+yf,False{}} P113KBody{+nb,+nf,False{}}:
      +ya = w4k_const01_assign(yb)
      +na = w4k_const01_assign(nb)
      nt_choose(P113KBody,agy_str_eq(dk(ya),"W4KBit") && agy_str_eq(dk(na),"W4KBit") && agy_str_eq(dn(ya),dn(na)) && U32.is_le(cond_bits,1),
        u =>
          +dst = dn(ya)
          +yv = da(ya)
          +nv = da(na)
          +rel = w4k_cond_subject(facts,condition)
          nt_choose(P113KBody,U32.is_eq(yv,nv),
            v => P113KBody{[P113DScalar{N111Set{dst,N111U64{},N111Const{yv,0}}}],p113k_put(facts,dst,p113k_exact(yv,0)),False{}},
            v => nt_choose(P113KBody,agy_str_eq(dk(rel),"P113LRelation"),
              w =>
                +subj : N111Value = N111Local{nm(dv(rel))}
                +invert = U32.is_ne(da(rel),yv)
                P113KBody{[P113DScalar{nt_choose(N111Stmt,invert,
                  z => N111Bin{dst,N111U64{},"xor",subj,N111Const{1,0}},
                  z => N111Set{dst,N111U64{},subj})}],p113k_put(facts,dst,p113k_bound(1)),False{}},
              w => p113k_body_join(condition,yes,no))),
        u => w4g_try_diamond(condition,facts,yes,no,yb,yf,nb,nf))
    case _ _: p113k_body_join(condition,yes,no)


@unsafe
def w5c2_body_if_lo(lo0: Bool, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef) -> P113KBody:
  match lo0:
    case True{}: p113k_body(no, facts)
    case False{}: p113k_body(yes, facts)

@unsafe
def w5c2_body_if_ex(exact: Bool, +bits: U32, +lo: U32, +condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef) -> P113KBody:
  match exact:
    case True{}: w5c2_body_if_lo(U32.is_eq(lo, 0), yes, no, facts)
    case False{}: w4k_body_join_opt(condition, facts, bits, p113k_body(yes, p113l_assume(facts, condition, True{})), p113k_body(no, p113l_assume(facts, condition, False{})))

@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{+bits, exact, +lo, _}:
      w5c2_body_if_ex(exact, bits, lo, condition, yes, no, facts)

@unsafe
def p113k_stmt(stmt: P113DStmt, +facts: KDef) -> P113KBody:
  match stmt:
    case P113DScalar{scalar}: p113k_scalar_body(p113k_scalar(scalar,facts))
    case P113DIf{+condition,yes,no}: p113k_body_if(condition,yes,no,facts,p113k_value(condition,facts))
    case P113DCall{+destinations,target,args}: P113KBody{[P113DCall{destinations,target,p113k_values(args,facts)}],p113k_kill(destinations,facts),False{}}
    case P113DResult{values}: P113KBody{[P113DResult{p113k_values(values,facts)}],facts,True{}}
    case P113DAgain{values}: P113KBody{[P113DAgain{p113k_values(values,facts)}],facts,True{}}


@unsafe
def p113k_function_done(name: String, +params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}:
      +b1 = w4g_bwd_dce(w4g_copy_pass(body))
      +b2 = nt_choose(List<&2,P113DStmt>,U32.is_le(p113i_size(b1),128),
        u => w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,w4c_seed_w32_facts(params,missing()))))),
        u => b1)
      P113DFunction{name,params,result,public,b2}

@unsafe
def w7_p113k_once(function):
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +seed = w4c_seed_w32_facts(params,missing())
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),2048),
        u => w7_p113k_once_done(name,params,result,public,p113k_body(body,seed)),u => function)

@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +seed = w4c_seed_w32_facts(params,missing())
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),2048),
        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)


@unsafe
def p113l_base_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,+typ,+symbol,+args}: w4k_call_fold(name,typ,symbol,args,facts)
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{+typ,+base,+offset,+value}:
      P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],w4k_store_facts(typ,base,offset,value,facts)}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}


@unsafe
def p113l_scalar_done(stmt: N111Stmt, before: KDef, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{body,p113l_record(stmt,before,facts)}


@unsafe
def p118t_original_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P113DCode,valid,u => p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{word,0}],target,n),
        u => p113pl_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,target,U32.add(n,terms_len(ks(t)))))


@unsafe
def w8_pl_live_16(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,kid(t,2),env,target,n)
    case False{}: p113d_fail("product unsupported core node " ++ tag,n)

@unsafe
def w8_pl_live_15(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n))
    case False{}: w8_pl_live_16(agy_str_eq(tag,"Rwt"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_14(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_match(book,t,env,target,n)
    case False{}: w8_pl_live_15(agy_str_eq(tag,"Efq"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_13(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{0,0}],target,n)
    case False{}: w8_pl_live_14(agy_str_eq(tag,"NMatch"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_12(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_call_result(nm(t),p111_values(ks(t),env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n)
    case False{}: w8_pl_live_13(agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"All") || agy_str_eq(tag,"Qua") || agy_str_eq(tag,"ADT") || agy_str_eq(tag,"Eql"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_11(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_call(book,nm(t),ks(t),env,target,n)
    case False{}: w8_pl_live_12(agy_str_eq(tag,"NCall"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_10(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_operation(book,t,env,target,n)
    case False{}: w8_pl_live_11(agy_str_eq(tag,"NPCall"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_9(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_ctor(book,t,env,target,n,nc_literal(t))
    case False{}: w8_pl_live_10(agy_str_eq(tag,"NCtr") || agy_str_eq(tag,"NOp"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_8(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_nat(p111_values(ks(t),env),target,n,U32.read(nm(t)))
    case False{}: w8_pl_live_9(agy_str_eq(tag,"Ctr"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_7(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,target,U32.inc(n))
    case False{}: w8_pl_live_8(agy_str_eq(tag,"NNatSum"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_6(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lets(book,ks(t),env,target,n)
    case False{}: w8_pl_live_7(agy_str_eq(tag,"NNatAdd"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_5(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_app(book,t,env,target,n)
    case False{}: w8_pl_live_6(agy_str_eq(tag,"Let") || agy_str_eq(tag,"NSeqLet"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_4(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_lower(book,kid(t,0),env,target,n)
    case False{}: w8_pl_live_5(agy_str_eq(tag,"App"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_3(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_ref(book,t,env,target,n)
    case False{}: w8_pl_live_4(agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Loc") || agy_str_eq(tag,"Src") || agy_str_eq(tag,"Cut") || agy_str_eq(tag,"Slf") || agy_str_eq(tag,"Ins"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_2(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_boxed(p111_constructor(nm(t),p111_values(ks(t),env)),target,n)
    case False{}: w8_pl_live_3(agy_str_eq(tag,"Ref"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_1(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_output(kt("NQShape",nm(t),terms_len(ks(t)),0,[]),p111_values(ks(t),env),target,n)
    case False{}: w8_pl_live_2(agy_str_eq(tag,"NQBox"),tag,book,t,env,target,n)

@unsafe
def w8_pl_live_0(c: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match c:
    case True{}: p113pl_boxed(p113d_value(book,t,env),target,n)
    case False{}: w8_pl_live_1(agy_str_eq(tag,"NQBundle"),tag,book,t,env,target,n)

@unsafe
def p118t_original_live(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +tag = tg(t)
  w8_pl_live_0(agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"NStatic"),tag,book,t,env,target,n)

@unsafe
def p118t_retry(+book: List<&2,KDef>, +name: String, +old: P113DCandidate) -> List<&2,P113DCandidate>:
  match old:
    case P113DCandidate{P113DFunction{+owner,+params,result,public,body},+error,calls}:
      +arity = nt_count(NC_Binding,params)
      nt_choose(List<&2,P113DCandidate>,agy_str_eq(error,"product non-tail self call") &&
        Bool.not(String.starts_with(name,"$")) && U32.is_ge(arity,1) && U32.is_le(arity,8),u =>
        p118t_retry_body(book,name,owner,params,old,nc_compact_definition(book,lookup(book,name),0)),u => [old])


@unsafe
def p118t_retry_body(+book: List<&2,KDef>, +name: String, +owner: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, +body: KTerm) -> List<&2,P113DCandidate>:
  +arity = nt_count(NC_Binding,params)
  nt_choose(List<&2,P113DCandidate>,U32.is_gt(nq_layout_remaining([body],513),0),u =>
    p118t_ready(owner,params,old,p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,
      P113PTarget{[],kt("P118TRMC",name,arity,0,[]),True{},owner,[]},arity)),u => [old])


@unsafe
def p118b_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  +wrapper = no_schema_wrapper(schema)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  String.is_empty(no_plan_error(plan)) &&
    agy_str_eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    U32.is_gt(nt_count(U32,roots),0) &&
    U32.is_le(nt_count(U32,roots),2) && Bool.not(agy_str_eq(tg(wrapper),"Var")) &&
    p118b_root_once(wrapper,no_schema_params(schema),roots,0) &&
    U32.is_eq(nq_uses(wrapper,result),1) && no_wrapper_once(wrapper,env) &&
    U32.is_le(no_wrapper_nodes(book,wrapper,env,2),2) &&
    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))

@unsafe
def p118b_verify_projected(+ids: N111Ids, workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p113e_functions(functions,ids,missing()),u => error)


@unsafe
def p118b_verify_functions(+functions: List<&2,P113DFunction>, +original: P111Program) -> String:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +ids : N111Ids = N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}
      p118b_verify_projected(ids,p118b_project_functions(functions,ids))


@unsafe
def w8_p121f_plan_ok(ok: Bool, +book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  match ok:
    case True{}:
      +body = j_fusion_after(dv(d),da(d))
      +r = j_call_spine(body,[])
      +m = j_call_spine(kid(r,0),[])
      nt_choose(P121FPlan,agy_str_eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
        agy_str_eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1) && p121f_bounded(dv(d)),
        v => p121f_prefix(book,dv(d),dt(d),[],[],0,da(d)),v => P121FNone{})
    case False{}: P121FNone{}

@unsafe
def p121f_plan(+book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  w8_p121f_plan_ok(U32.is_gt(da(d),0) && U32.is_le(da(d),8) && j_fusion_def(d,da(d)),book,d)


@unsafe
def p121f_expr(+book: List<&2,KDef>, +term: KTerm, +env: List<&2,NC_Binding>, +dest: String, +n: U32) -> P113DCode:
  p113d_lower(book,nc_compact(nc_erase(book,term)),env,"$p121.scalar",P113DLocal{dest},n)


@unsafe
def p121f_step(+book: List<&2,KDef>, +p: KDef, +f: KDef, +m: KDef, +r: KDef) -> P113DCode:
  +ps = j_fusion_link(p)
  +pb = j_fusion_after(ps,2)
  +pc = j_call_spine(kid(pb,1),[])
  +fs = j_fusion_link(f)
  +fc = j_call_spine(j_fusion_unlet(j_fusion_after(fs,2),8),[])
  +ms = j_fusion_link(m)
  +rs = j_fusion_link(r)
  +rc = j_call_spine(j_fusion_after(rs,3),[])
  +head = p121f_expr(book,kid(pb,0),[p121f_env(j_fusion_binder(ps,1),"p121_seed")],"p121_head",1000)
  +next = p121f_expr(book,kid(pc,1),[p121f_env(j_fusion_binder(ps,1),"p121_seed")],"p121_next_seed",p113d_fresh(head))
  +pred = p121f_expr(book,kid(fc,2),[p121f_env(j_fusion_binder(fs,0),"p121_head")],"p121_pred",p113d_fresh(next))
  +mapped = p121f_expr(book,kid(j_fusion_after(ms,2),0),[p121f_env(j_fusion_binder(ms,0),"p121_head")],"p121_mapped",p113d_fresh(pred))
  +folded = p121f_expr(book,kid(rc,1),[p121f_env(j_fusion_binder(rs,0),"p121_mapped"),p121f_env(j_fusion_binder(rs,2),"p121_acc")],"p121_next_acc",p113d_fresh(mapped))
  p113d_join(head,p113d_join(next,p113d_join(pred,
    p113d_prepend([N111Bin{"p121_next_n",N111U64{},"sub",p121f_ref("p121_n"),N111Const{1,0}},
      N111Bin{"p121_keep",N111U64{},"ne",p121f_ref("p121_pred"),N111Const{0,0}}],
      p113d_branch(p121f_ref("p121_keep"),p113d_join(mapped,p113d_join(folded,p121f_again("p121_next_acc"))),p121f_again("p121_acc"))))))


@unsafe
def p121f_loop(book: List<&2,KDef>, p: KDef, f: KDef, m: KDef, r: KDef) -> P113DCode:
  p113d_prepend([N111Bin{"p121_nonzero",N111U64{},"ne",p121f_ref("p121_n"),N111Const{0,0}}],
    p113d_branch(p121f_ref("p121_nonzero"),p121f_step(book,p,f,m,r),
      P113DCode{[P113DResult{[p121f_ref("p121_acc")]}],9000,"",[]}))


@unsafe
def p121f_functions(+book: List<&2,KDef>, +name: String, plan: P121FPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P121FNone{}: []
    case P121FPlan{+params,p,f,m,r,count,seed,initial}:
      +private = "$p121.stream." ++ name
      +loop = p121f_loop(book,p,f,m,r)
      +count_code = p121f_expr(book,count,params,"p121_count",1000)
      +seed_code = p121f_expr(book,seed,params,"p121_seed0",p113d_fresh(count_code))
      +initial_code = p121f_expr(book,initial,params,"p121_acc0",p113d_fresh(seed_code))
      +entry = p113d_join(count_code,p113d_join(seed_code,p113d_join(initial_code,
        P113DCode{[P113DCall{["p121_result"],private,[p121f_ref("p121_count"),p121f_ref("p121_seed0"),p121f_ref("p121_acc0")]},
          P113DResult{[p121f_ref("p121_result")]}],p113d_fresh(initial_code),"",[private]})))
      [P113DCandidate{P113DFunction{private,[NC_Binding{0,"p121_n",N_W32{}},NC_Binding{1,"p121_seed",N_W32{}},
        NC_Binding{2,"p121_acc",N_W32{}}],1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
       P113DCandidate{P113DFunction{p113d_public(book,name),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]

# A fold arm interprets either one word, or two recursive subtrees.
# Names of the fold, datatype and constructors come from checked definitions.
@unsafe
def p198e_action_arm(+book: List<&2,KDef>, +arm: P198EArm, +fresh: U32) -> P113DCode:
  match arm:
    case P198EArm{op,left,value,seed}:
      p113d_join(p121f_expr(book,value,[p121f_env(seed,"ebranch")],"esibling",fresh),p198e_action(op,left))
    case _: p113d_fail("missing proved word algebra arm",fresh)

@unsafe
def p198e_loop(+book: List<&2,KDef>, +step: KTerm, +base: KTerm, +basevar: KTerm, +next: KTerm,
    +key: KTerm, +branch: KTerm, +a: P198EArm, +b: P198EArm, +c: P198EArm) -> P113DCode:
  +env : List<&2,NC_Binding> = [p121f_env(step,"eseed")]
  +advance = p121f_expr(book,next,env,"enext",1000)
  +choice = p121f_expr(book,key,env,"ekey",p113d_fresh(advance))
  +argument = p121f_expr(book,branch,env,"ebranch",p113d_fresh(choice))
  +arms = p113d_prepend([p198e_bin("epred","sub",p121f_ref("ecount"),N111Const{1,0}),
      p198e_bin("ezero","eq",p121f_ref("ekey"),N111Const{0,0})],
    p113d_branch(p121f_ref("ezero"),p198e_action_arm(book,a,p113d_fresh(argument)),
      p113d_prepend([p198e_bin("eone","eq",p121f_ref("ekey"),N111Const{1,0})],
        p113d_branch(p121f_ref("eone"),p198e_action_arm(book,b,p113d_fresh(argument)),p198e_action_arm(book,c,p113d_fresh(argument))))))
  +leaf = p113d_join(p121f_expr(book,base,[p121f_env(basevar,"eseed")],"eleaf",1000),
    p113d_prepend([p198e_bin("efactor","mul",p121f_ref("em"),p121f_ref("eleaf")),
      p198e_bin("efinal","add",p121f_ref("efactor"),p121f_ref("ebias")),p198e_mask("eanswer","efinal")],
      P113DCode{[P113DResult{[p121f_ref("eanswer")]}],90000,"",[]}))
  p113d_prepend([p198e_bin("emore","ne",p121f_ref("ecount"),N111Const{0,0})],
    p113d_branch(p121f_ref("emore"),p113d_join(advance,p113d_join(choice,p113d_join(argument,arms))),leaf))

@unsafe
def p198e_candidates(+book: List<&2,KDef>, +name: String, plan: P198EPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P198EReady{+params,n,seed,step,base,basevar,next,key,branch,a,b,c}:
      +worker = "$p198.algebra." ++ name
      +loop = p198e_loop(book,step,base,basevar,next,key,branch,a,b,c)
      +ncode = p121f_expr(book,n,params,"en0",1000)
      +scode = p121f_expr(book,seed,params,"es0",p113d_fresh(ncode))
      +entry = p113d_join(ncode,p113d_join(scode,P113DCode{[
        P113DCall{["eresult"],worker,[p121f_ref("en0"),p121f_ref("es0"),N111Const{1,0},N111Const{0,0}]},
        P113DResult{[p121f_ref("eresult")]}],p113d_fresh(scode),"",[worker]}))
      [P113DCandidate{P113DFunction{worker,[NC_Binding{0,"ecount",N_W32{}},NC_Binding{1,"eseed",N_W32{}},
         NC_Binding{2,"em",N_W32{}},NC_Binding{3,"ebias",N_W32{}}],1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
       P113DCandidate{P113DFunction{p113d_public(book,name),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]
    case _: []

@unsafe
def p121c_step(+book: List<&2,KDef>, +factory: KDef) -> P113DCode:
  +s = j_fusion_link(factory)
  +pred = j_fusion_binder(s,0)
  +body = j_fusion_after(s,1)
  +binding = kid(body,0)
  +call = j_call_spine(kid(body,1),[])
  +leaf = j_strip(kid(call,3))
  +capture = p121f_expr(book,j_callback_capture_u32(kid(binding,0)),
    [p121f_env(pred,"p121_predecessor")],"p121_capture",1000)
  +value = p121f_expr(book,kid(leaf,0),
    [p121f_env(binding,"p121_capture"),p121f_env(leaf,"p121_value")],"p121_next_value",p113d_fresh(capture))
  p113d_prepend([N111Bin{"p121_predecessor",N111U64{},"sub",p121f_ref("p121_n"),N111Const{1,0}}],
    p113d_join(capture,p113d_join(value,P113DCode{[
      P113DAgain{[p121f_ref("p121_predecessor"),p121f_ref("p121_next_value")]}],p113d_fresh(value),"",[]})))


@unsafe
def p121c_functions(+book: List<&2,KDef>, +d: KDef) -> List<&2,P113DCandidate>:
  +call = j_call_spine(j_fusion_after(dv(d),2),[])
  +count = j_call_spine(kid(call,0),[])
  +private = "$p121.callback." ++ dn(d)
  +params : List<&2,NC_Binding> = [p121f_env(j_fusion_binder(dv(d),0),"p121_arg0"),p121f_env(j_fusion_binder(dv(d),1),"p121_arg1")]
  +loop = p113d_prepend([N111Bin{"p121_nonzero",N111U64{},"ne",p121f_ref("p121_n"),N111Const{0,0}}],
    p113d_branch(p121f_ref("p121_nonzero"),p121c_step(book,lookup(book,nm(call))),
      P113DCode{[P113DResult{[p121f_ref("p121_value")]}],0,"",[]}))
  +count_code = p121f_expr(book,kid(count,0),params,"p121_count",1000)
  +seed_code = p121f_expr(book,kid(call,1),params,"p121_initial",p113d_fresh(count_code))
  +entry = p113d_join(count_code,p113d_join(seed_code,P113DCode{[
    P113DCall{["p121_result"],private,[p121f_ref("p121_count"),p121f_ref("p121_initial")]},
    P113DResult{[p121f_ref("p121_result")]}],p113d_fresh(seed_code),"",[private]}))
  [P113DCandidate{P113DFunction{private,[NC_Binding{0,"p121_n",N_W32{}},NC_Binding{1,"p121_value",N_W32{}}],
    1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
   P113DCandidate{P113DFunction{p113d_public(book,dn(d)),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]

@unsafe
def p125p_previous_selected(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P121FNone{}:
      +d = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,p121c_admitted(book,d),u => p121c_functions(book,d),
        u => p118t_retry(book,name,p113pl_boxed_candidate(book,name,signatures)))
    case _: p121f_functions(book,name,plan)


@unsafe
def p126s_original_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113pl_candidate_code(owner,params,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{},
    p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,P113PTarget{[],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{},owner,signatures},arity))


@unsafe
def p126s_candidate_params(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, +values: List<&2,U32>, params: List<&2,NC_Binding>) -> P113DCandidate:
  match params:
    case [NC_Binding{+id,+word,+kind}]:
      P113DCandidate{P113DFunction{p113d_public(book,name),[NC_Binding{id,word,kind}],1,True{},p126s_decision(word,values,0)},"",[]}
    case _: p126s_original_candidate(book,name,signatures)


@unsafe
def p126s_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: Maybe<&2,List<&2,U32>>) -> P113DCandidate:
  match plan:
    case None{}: p126s_original_candidate(book,name,signatures)
    case Some{+values}:
      nt_choose(P113DCandidate,U32.is_ge(nt_count(U32,values),4),u =>
        p126s_candidate_params(book,name,signatures,values,nk_typed_bindings(nd_entry_params(1,0),nf_worker_kinds(book,name,1))),
        u => p126s_original_candidate(book,name,signatures))

@unsafe
def p128bs_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  nt_choose(Bool,String.is_empty(no_plan_error(plan)),
    u => p169e_shape(book,plan,no_plan_schema(plan)),u => False{})


@unsafe
def p128br_residual_error(+plan: NO_Plan) -> String:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  nc_error(no_emit(p128br_project_residual(noa_body(no_plan_analysis(plan)),params),
    params,params,no_schema_specs_layouts(no_schema_specs(schema)),0))

@unsafe
def p128br_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +wrapper = no_schema_wrapper(schema)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  String.is_empty(no_plan_error(plan)) && agy_str_eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    agy_str_eq(nm(wrapper),no_schema_observation(schema)) &&
    nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    agy_str_eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    agy_str_eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent") &&
    String.is_empty(p128br_residual_error(plan)) &&
    String.is_empty(p113d_error(p118b_lower(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))


@unsafe
def p128br_candidate(+book: List<&2,KDef>, +name: String, +original: List<&2,P113DFunction>, +plan: NO_Plan) -> P128BRPatches:
  nt_choose(P128BRPatches,p128br_eligible(book,plan),
    u => p128br_patch(p113d_public(book,name),p128br_find(book,name,plan,original)),
    u => P128BRPatches{[],""})


@unsafe
def p128bl_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  p131rg_fallback(book,ty,
    nt_choose(P128BLNode,nol_owner(book,ty) && (Bool.not(db(owner)) ||
      agy_str_eq(nm(ty),"String") || agy_str_eq(nm(ty),"List")),
      u => p128bl_ctors(book,ty,dc(owner)),
      u => P128BLNode{[],[],"nested observer: unknown or native non-boxed owner"}))

@unsafe
def p128bl_graph(+book: List<&2,KDef>, todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32) -> P128BLGraph:
  match todo:
    case Nil{}: P128BLGraph{types,specs,""}
    case Con{+raw,+rest}:
      +ty = nq_layout_type(book,raw)
      nt_choose(P128BLGraph,U32.is_eq(fuel,0),u => P128BLGraph{[],[],"nested observer: layout budget"},
        u => nt_choose(P128BLGraph,nol_scalar(book,ty),
          v => p128bl_graph(book,rest,types,specs,U32.sub(fuel,1)),
          v => p128bl_seen(book,ty,rest,types,specs,U32.sub(fuel,1),p128bl_type(nm(ty),types))))


@unsafe
def p128bl_seen(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, +previous: KTerm) -> P128BLGraph:
  nt_choose(P128BLGraph,agy_str_eq(tg(previous),"Absent"),
    u => p128bl_extend(book,ty,todo,types,specs,fuel,p128bl_node(book,ty)),
    u => nt_choose(P128BLGraph,norm_exact(previous,ty),
      v => p128bl_graph(book,todo,types,specs,fuel),
      v => P128BLGraph{[],[],"nested observer: conflicting instantiations of " ++ nm(ty)}))


@unsafe
def p128bl_extend(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, node: P128BLNode) -> P128BLGraph:
  match node:
    case P128BLNode{added,children,+error}:
      nt_choose(P128BLGraph,String.is_empty(error),
        u => p128bl_graph(book,nt_append(KTerm,children,todo),Con{ty,types},nt_append(NO_Spec,added,specs),fuel),
        u => P128BLGraph{[],[],error})


@unsafe
def p128bl_result(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(terms_len(params),arity) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    Bool.not(nq_layout_dep(ty,seen)) && nol_scalar(book,ty),
    u => p128bl_finish(book,nt_reverse(KTerm,params,[]),nt_reverse(U32,roots,[]),fresh,ty,p128bl_graph(book,types,[],[],64)),
    u => nol_failure("nested observer: scalar result or root count",fresh))


@unsafe
def p128bl_params(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(fuel,0),u => nol_failure("nested observer: telescope budget",fresh),
    u => p128bl_head(book,nq_layout_type(book,ty),params,roots,types,seen,fresh,U32.sub(fuel,1),arity))


@unsafe
def p128bl_head(+book: List<&2,KDef>, +head: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,agy_str_eq(tg(head),"All"),
    u => nt_choose(NO_Schema,U32.is_eq(qt(head),0),
      v => p128bl_params(book,kid(head,1),params,roots,types,Con{ix(head),seen},fresh,fuel,arity),
      v => p128bl_param(book,head,nq_layout_type(book,kid(head,0)),params,roots,types,seen,fresh,fuel,arity)),
    u => p128bl_result(book,head,params,roots,types,seen,fresh,arity))


@unsafe
def p128bl_param(+book: List<&2,KDef>, +head: KTerm, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +scalar = nol_scalar(book,ty)
  nt_choose(NO_Schema,nol_owner(book,ty) && Bool.not(nq_layout_dep(ty,seen)) && U32.is_lt(terms_len(params),arity),
    u => p128bl_params(book,kid(head,1),Con{var(nm(ty),nc_id(fresh)),params},
      nt_choose(List<&2,U32>,scalar,v => roots,v => Con{terms_len(params),roots}),
      nt_choose(List<&2,KTerm>,scalar,v => types,v => Con{ty,types}),
      Con{ix(head),seen},U32.inc(fresh),fuel,arity),
    u => nol_failure("nested observer: unsupported or dependent parameter",fresh))


@unsafe
def p128bl_schema(+book: List<&2,KDef>, +owner: String) -> NO_Schema:
  +d = lookup(book,owner)
  nt_choose(NO_Schema,agy_str_eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book,owner),4),
    u => p128bl_params(book,dt(d),[],[],[],[],0,32,nd_arity(book,owner)),
    u => nol_failure("nested observer: unsupported owner",0))

@unsafe
def p167l_factory(+book: List<&2,KDef>, +source: String, +n: U32, +arity: U32) -> P111Code:
  +definition = lookup(book,source)
  +typed = jd_live_arity(book,dt(definition),jd_arity(book,definition))
  +params = nd_entry_params(arity,U32.add(n,1024))
  nt_choose(P111Code,U32.is_gt(typed,0) && U32.is_eq(typed,arity),
    u => p111_lower(book,nd_eta_body(params,kt("NCall",nd_name(nc_ref_name(book,source)),0,0,nd_entry_args(params))),[],U32.add(U32.add(n,1024),arity)),
    u => p111_lower(book,nc_compact_definition(book,definition,n),[],U32.add(n,1024)))



@unsafe
def p167l_family(+book: List<&2,KDef>, +source: String, +n: U32, +bangs: List<&2,String>) -> P111Code:
  p111_entry(book,nc_compact_definition(book,lookup(book,source),n),source,U32.add(n,1024),nb_contains(bangs,source))



@unsafe
def p167l_accept(+context: P167Context, +segments: List<&2,N111Segment>, +fresh: U32,
    +pending: P167Demand, built: P167Built, +kind: U32, +source: String, +owner: String,
    +arity: U32, +error: String) -> P167Built:
  match built:
    case P167Built{+acc,+present,+adapters,oldfresh,+families,+factories,+wrappers,demands,old_error}:
      nt_choose(P167Built,String.is_empty(error),
        u => p167l_loop(context,p167l_segment_demands(segments,pending),
          P167Built{nt_reverse(N111Segment,segments,acc),p167l_present(segments,present),
            nt_choose(KDef,U32.is_eq(kind,2),v => p164a_put(adapters,source,owner,arity),v => adapters),
            fresh,U32.add(families,Bool.to_u32(U32.is_eq(kind,0))),
            U32.add(factories,Bool.to_u32(U32.is_eq(kind,1))),
            U32.add(wrappers,Bool.to_u32(U32.is_eq(kind,2))),0,""}),
        u => P167Built{acc,present,adapters,fresh,families,factories,wrappers,0,error})



@unsafe
def p167l_code(+context: P167Context, +source: String, +owner: String, +arity: U32,
    +kind: U32, pending: P167Demand, built: P167Built, code: P111Code) -> P167Built:
  match context code:
    case P167Context{+book,catalogue,+bangs} P111Code{body,segments,fresh,error}:
      p167l_accept(context,p111_mark_segments(
        Con{p111_segment(nc_ref_name(book,source),[],0,0,body),segments},
        nb_contains(bangs,source)),fresh,pending,built,kind,source,owner,arity,error)




# === AGY-W6: Demand-Split Non-Direct Dispatch + Alpha-Equivalent $p111.k.* Deduplication ===

@unsafe
def w6_worker_code(+context: P167Context, +source: String, +owner: String, +arity: U32,
    +params: List<&2,NC_Binding>, pending: P167Demand, built: P167Built, code: P111Code) -> P167Built:
  match context code:
    case P167Context{+book,catalogue,+bangs} P111Code{body,segments,fresh,error}:
      p167l_accept(context,p111_mark_segments(
        Con{p111_segment(owner,params,0,0,body),segments},
        nb_contains(bangs,source)),fresh,pending,built,0,source,owner,arity,error)

@unsafe
def w6_worker_non_direct(+context: P167Context, +source: String, +owner: String, +arity: U32,
    pending: P167Demand, built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +n0 = U32.add(fresh,1024)
      +body = nc_compact_definition(book,lookup(book,source),fresh)
      +params = nk_typed_bindings(nd_entry_params(arity,n0),nf_worker_kinds(book,source,arity))
      w6_worker_code(context,source,owner,arity,params,pending,built,
        p111_lower(book,nd_reapply(body,nd_entry_args(params)),params,U32.add(n0,arity)))

@unsafe
def w6_factory_non_direct(+book: List<&2,KDef>, +source: String, +n: U32, +arity: U32, +bangs: List<&2,String>) -> P111Code:
  +d = lookup(book,source)
  +bang = nb_contains(bangs,source)
  +typed = jd_live_arity(book,dt(d),jd_arity(book,d))
  +eta = Bool.not(bang || nc_native_def(d) || nc_foreign(d)) && U32.is_gt(typed,0) && U32.is_eq(typed,arity)
  +params = nd_entry_params(arity,U32.add(n,1024))
  nt_choose(P111Code,eta,
    u => p111_lower(book,nd_eta_body(params,kt("NCall",nd_name(nc_ref_name(book,source)),0,0,nd_entry_args(params))),[],U32.add(U32.add(n,1024),arity)),
    u => p111_lower(book,nc_compact_definition(book,d,n),[],U32.add(n,1024)))

@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      +arity = da(entry)
      nt_choose(P167Built,U32.is_eq(dx(entry),0),
        u => nt_choose(P167Built,U32.is_eq(arity,0),
          v => p167l_code(context,source,owner,0,0,pending,built,p167l_family(book,source,fresh,bangs)),
          v => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
            w => p167l_code(context,source,owner,arity,1,pending,built,w6_factory_non_direct(book,source,fresh,arity,bangs)),
            w => w6_worker_non_direct(context,source,owner,arity,pending,built,fresh))),
        u => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
          v => p167l_code(context,source,owner,arity,1,pending,built,p167l_factory(book,source,fresh,arity)),
          v => p167l_accept(context,[p164a_segment(owner,arity)],fresh,pending,built,2,source,owner,arity,"")))



@unsafe
def w7c_p167l_take_entry(absent: Bool, +context: P167Context, +entry: KDef, +name: String, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match absent:
    case True{}: P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,"demand: unknown scheduled identity " ++ name}
    case False{}: p167l_dispatch(context,entry,pending,built,fresh)

@unsafe
def w7c_p167l_take_pres(seen: Bool, +context: P167Context, +catalogue: KDef, +name: String, +h: U32, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match seen:
    case True{}: p167l_loop(context,pending,built)
    case False{}:
      +entry = w5c3_find(catalogue,name,h)
      w7c_p167l_take_entry(agy_str_eq(dk(entry),"Absent"),context,entry,name,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)

@unsafe
def w7c_p167l_take_err(hasErr: Bool, +context: P167Context, +catalogue: KDef, +name: String, +pending: P167Demand, +built: P167Built,
    +segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef, +fresh: U32, +families: U32, +factories: U32, +wrappers: U32, +demands: U32) -> P167Built:
  match hasErr:
    case True{}: built
    case False{}:
      +h = index_hash(name,2166136261)
      w7c_p167l_take_pres(Bool.not(agy_str_eq(dk(w5c3_find(present,name,h)),"Absent")),context,catalogue,name,h,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)

@unsafe
def p167l_take(+context: P167Context, +name: String, +pending: P167Demand, +built: P167Built) -> P167Built:
  match context built:
    case P167Context{book,+catalogue,bangs}
         P167Built{+segments,+present,+adapters,+fresh,+families,+factories,+wrappers,+demands,+error}:
      w7c_p167l_take_err(Bool.not(String.is_empty(error)),context,catalogue,name,pending,built,segments,present,adapters,fresh,families,factories,wrappers,demands)



@unsafe
def p167l_loop(+context: P167Context, pending: P167Demand, built: P167Built) -> P167Built:
  match pending:
    case P167Demand{Nil{},asked,count}: p167l_complete(built,count)
    case P167Demand{Con{name,rest},asked,count}:
      p167l_take(context,name,P167Demand{rest,asked,count},built)



@unsafe
def p167l_catalogued(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +functions: List<&2,P113DFunction>, catalogue: P167Catalogue) -> P167Lowered:
  match catalogue:
    case P167Catalogue{index,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167l_finish(source,names,constructors,nodes,functions,
          p167l_loop(P167Context{book,index,bangs},
            p167l_demand(nc_ref_name(book,"main"),p167l_function_demands(functions,P167Demand{[],missing(),0})),
            P167Built{[],missing(),missing(),0,0,0,0,0,""})),
        u => p167l_fail(error))



@unsafe
def p167v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +entry = p111v_get(adapters,name)
      nt_choose(String,agy_str_eq(dk(entry),"Absent"),u => p111v_segment(segment,ids),u =>
        nt_choose(String,agy_str_eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
          v => "",v => "demand adapter body/header mismatch: " ++ name))



@unsafe
def p167v_segments(segments: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef) -> String:
  match segments:
    case Nil{}: ""
    case Con{head,rest}:
      p167v_segment_done(rest,ids,adapters,p167v_one(head,ids,adapters))



@unsafe
def p167v_segment_done(+rest: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u => p167v_segments(rest,ids,adapters),u => error)



@unsafe
def p167v_scans(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef,
    functions: P111VScan, constructors: P111VScan) -> String:
  match program functions constructors:
    case P113DProgram{+original,+direct} P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(String,Bool.not(String.is_empty(fe)),u => fe,u =>
      nt_choose(String,Bool.not(String.is_empty(ce)),u => ce,u =>
      nt_choose(String,agy_str_eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => "program requires a direct, zero-argument main segment",u =>
        p167v_catalogued(original,N111Ids{fs,cs},adapters,
          p167v_obligations(adapters,book,bangs,fs,p113e_signatures(direct,missing()))))))



@unsafe
def p167v_catalogued(+original: P112StaticProgram, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  match original:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      nt_choose(String,String.is_empty(error),u =>
        p111_first(p167v_segments(segments,ids,adapters),p112s_image_error(original)),u => error)



@unsafe
def p167v_original(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef) -> String:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions}:
      p167v_scans(book,bangs,program,adapters,p111v_functions(segments,P111VScan{missing(),"",0}),
        p111v_constructors(ctors,P111VScan{missing(),"",0}))



# All final workers are private. Public entry behavior is the independently
# authenticated actual adapter, not an emitter's choice to replace a generic body.
@unsafe
def p167ob_seed_checked(+constructors: List<&2,N_Constructor>, +functions: List<&2,P113DFunction>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      +ids : N111Ids = N111Ids{missing(),ns_ctor_index(constructors,missing())}
      nt_choose(String,String.is_empty(error),
        u => p118b_verify_projected(ids,p118b_project_functions(p167l_private(functions),ids)),
        u => error)



@unsafe
def p167ob_seed_verify(+constructors: List<&2,N_Constructor>, functions: List<&2,P113DFunction>) -> String:
  p167ob_seed_checked(constructors,functions,p111v_constructors(constructors,P111VScan{missing(),"",0}))



# Skip a raw source candidate only if the independently checked source worker
# supplies its exact ordinary boxed ABI. Other source names retain old lowering.
@unsafe
def p167ob_direct(+program: P113DProgram, +error: String) -> String:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},+functions}:
      nt_choose(String,String.is_empty(error),u =>
        nt_choose(String,p167v_private(functions),
          v => p118b_verify_functions(functions,original),
          v => "observer first final worker must be private"),u => error)



@unsafe
def p167ob_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, +program: P113DProgram) -> String:
  p167ob_direct(program,p167v_original(book,bangs,program,adapters))



# Reuse cached NO_Plans. Only genuine independently checkable leaf fallbacks
# enter p128bs_find; unavailable/nonleaf owners remain for the consumer retry.
@unsafe
def p168_scalars(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    functions: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{+plan,rest}:
      p168_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,p128bs_eligible(book,plan),
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))



@unsafe
def p168_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p168_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})



@unsafe
def p169s_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, live: Bool) -> P169Prepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => 1)
      +cap_flags = U32.or(nt_choose(U32,live,u => 4,u => 0),nt_choose(U32,p118c_has_cold(tables),u => 8,u => 0))
      +tables = w7_patch_prog_tables(tables,False{},cap_flags)
      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,tables,
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))



# Sole override. Keep actual source/generic/static/adapter/private and complete
# borrowed/direct verification. Extra namespace checks precede mode2 emission.
@unsafe
def p169q_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>) -> List<&2,P169ScalarPlan>:
  match plans:
    case Nil{}: []
    case Con{+plan,rest}:
      Con{P169ScalarPlan{plan,p128bs_eligible(book,plan)},p169q_plans(book,rest)}



@unsafe
def p169e_emit(+plan: NO_Plan, +schema: NO_Schema) -> Bool:
  +params = no_plan_params(no_schema_params(schema))
  String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
    no_schema_specs_layouts(no_schema_specs(schema)),0)))



@unsafe
def p169e_names(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema) -> Bool:
  nt_choose(Bool,agy_str_eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent"),
    u => nt_choose(Bool,agy_str_eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent"),
      v => p169e_emit(plan,schema),v => False{}),u => False{})



@unsafe
def p169e_roots(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema, +wrapper: KTerm) -> Bool:
  +count = nt_count(U32,no_schema_roots(schema))
  nt_choose(Bool,U32.is_ge(count,1) && U32.is_le(count,2),
    u => nt_choose(Bool,nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])),
      v => p169e_names(book,plan,schema),v => False{}),u => False{})



@unsafe
def p169e_shape(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema) -> Bool:
  +wrapper = no_schema_wrapper(schema)
  nt_choose(Bool,agy_str_eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    agy_str_eq(nm(wrapper),no_schema_observation(schema)),
    u => p169e_roots(book,plan,schema,wrapper),u => False{})

@unsafe
def p169a_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +live: Bool, arrays: Bool) -> P169Prepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +enabled = arrays && Bool.not(List.is_empty(&2,P113DFunction,functions))
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,enabled,v => 2,v => 1))
      +cap_flags = U32.or(nt_choose(U32,live,u => 4,u => 0),nt_choose(U32,p118c_has_cold(tables),u => 8,u => 0))
      +tables = w7_patch_prog_tables(tables,enabled,cap_flags)
      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,tables,
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))



@unsafe
def p169c_output(admitted: P113AProgram, +live: Bool) -> P169Prepared:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{+original,+nodes},+view},certificate}:
      nt_choose(P169Prepared,p113a_enabled(certificate),
        u => p169a_seeded(original,nodes,view,live,True{}),
        u => p169s_seeded(original,nodes,view,live))



@unsafe
def p169c_emitted(request: NR_Request, admitted: P113AProgram, live: Bool,
    +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169c_output(p169c_selected(request,admitted),live),
    u => p169s_fail("adapter imports view verification: " ++ error))

@unsafe
def p171ff_direct_match(book,t,env,owner,target,n,mat):
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),owner,target,U32.add(n,count))
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),p113d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p113d_fresh(yes)))),u => yes)

@unsafe
def p171ff_product_match(book,t,env,target,n,mat):
  +arg = kid(t,1)
  +word: N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113pl_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),target,U32.add(n,count))
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),p113pl_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,target,p113d_fresh(yes)))),u => yes)
# Experimental private event-history representation, not a public Book change.
# p156cp's `seen` is observed only by lookup, compare and constructor_names.
# Keep its authoritative index/bound, but retain raw rows only when they carry
# constructors. The published/checking KWorld and its ordered book are unchanged.
# A raw public book remains on the original path until a real cache is present.

@unsafe
def p171sc_result(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(terms_len(params),arity) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    Bool.not(nq_layout_dep(ty,seen)) && nol_scalar(book,ty),
    u => p171sc_finish(book,nt_reverse(KTerm,params,[]),nt_reverse(U32,roots,[]),fresh,ty,p128bl_graph(book,types,[],[],64)),
    u => nol_failure("nested observer: scalar result or root count",fresh))
# These private signatures precede their recursive definitions.
law p171sc_params:
  for +book: List<&2,KDef>
  for +ty: KTerm
  for +params: List<&2,KTerm>
  for +roots: List<&2,U32>
  for +types: List<&2,KTerm>
  for +seen: List<&2,U32>
  for +fresh: U32
  for +fuel: U32
  for +arity: U32
  NO_Schema

@unsafe
def p171sc_param(+book: List<&2,KDef>, +head: KTerm, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +scalar = nol_scalar(book,ty)
  nt_choose(NO_Schema,nol_owner(book,ty) && Bool.not(nq_layout_dep(ty,seen)) && U32.is_lt(terms_len(params),arity),
    u => p171sc_params(book,kid(head,1),Con{var(nm(ty),nc_id(fresh)),params},
      nt_choose(List<&2,U32>,scalar,v => roots,v => Con{terms_len(params),roots}),
      nt_choose(List<&2,KTerm>,scalar,v => types,v => Con{ty,types}),
      Con{ix(head),seen},U32.inc(fresh),fuel,arity),
    u => nol_failure("nested observer: unsupported or dependent parameter",fresh))

@unsafe
def p171sc_head(+book: List<&2,KDef>, +head: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,agy_str_eq(tg(head),"All"),
    u => nt_choose(NO_Schema,U32.is_eq(qt(head),0),
      v => p171sc_params(book,kid(head,1),params,roots,types,Con{ix(head),seen},fresh,fuel,arity),
      v => p171sc_param(book,head,nq_layout_type(book,kid(head,0)),params,roots,types,seen,fresh,fuel,arity)),
    u => p171sc_result(book,head,params,roots,types,seen,fresh,arity))

@unsafe
def p171sc_params(book,ty,params,roots,types,seen,fresh,fuel,arity):
  nt_choose(NO_Schema,U32.is_eq(fuel,0),u => nol_failure("nested observer: telescope budget",fresh),
    u => p171sc_head(book,nq_layout_type(book,ty),params,roots,types,seen,fresh,U32.sub(fuel,1),arity))

@unsafe
def p171sc_schema(+book: List<&2,KDef>, +owner: String) -> NO_Schema:
  +d = lookup(book,owner)
  nt_choose(NO_Schema,agy_str_eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book,owner),4),
    u => p171sc_params(book,dt(d),[],[],[],[],0,32,nd_arity(book,owner)),
    u => nol_failure("nested observer: unsupported owner",0))

@unsafe
def p171sc_local_ready(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    +catalogue: Maybe<&2,List<&2,NO_Spec>>, +local: NO_Schema) -> P171SCPlan:
  nt_choose(P171SCPlan,String.is_empty(no_schema_error(local)),
    u => p171sc_catalogue(book,owner,helpers,local,catalogue),
    u => P171SCPlan{NO_Plan{owner,local,noa_fail(no_schema_error(local),no_schema_fresh(local),4096),no_schema_error(local)},catalogue})

law p175p_grow_operator:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed

@unsafe
def w7_br_984(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      p175p_grow_operator(n,ts,min,word)
    case False{}:
      FParsed{n,ts}

@unsafe
def w7_br_985(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      f_context_call(n,ts,min)
    case False{}:
      w7_br_984(U32.is_gt(f_prec(word),min) || (f_eq(word,"<") && U32.is_eq(ke(n),f_begin(ts))), n, ts, min, word)

@unsafe
def p175p_grow_word(n,ts,min,word):
  w7_br_985(f_eq(word,"("), n, ts, min, word)
law p175p_grow_sign:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  for +next: FInput
  FParsed
law p175p_grow_shift:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed

@unsafe
def w7_br_986(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      p175p_grow_sign(n,ts,min,word,f_tl(ts))
    case False{}:
      p175p_grow_shift(n,ts,min,word)

@unsafe
def p175p_grow_operator(n,ts,min,word):
  w7_br_986(f_eq(word,"%") || f_eq(word,"-"), n, ts, min, word)

@unsafe
def w7_br_987(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{n,ts}
    case False{}:
      p175p_grow_shift(n,ts,min,word)

@unsafe
def p175p_grow_sign(n,ts,min,word,next):
  w7_br_987(U32.is_eq(f_col(next),U32.add(f_col(ts),1)) && Char.is_alpha(f_head(f_tx(next))), n, ts, min, word)
@unsafe
def w7_br_988(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{n,ts}
    case False{}:
      f_binary_start(n,ts,min)

@unsafe
def w7_br_989(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{n,ts}
    case False{}:
      w7_br_988(f_eq(word,">>") && p175p_shift_end(f_tx(f_tl(ts))), n, ts, min)

@unsafe
def p175p_grow_shift(n,ts,min,word):
  w7_br_989(f_eq(word,">"), n, ts, min, word)

@unsafe
def p175p_grow_newline(n,ts,min,skipped):
  +word = f_tx(skipped)
  f_choose(FParsed,U32.is_gt(f_prec(word),0) && Bool.not((f_eq(word,"%") || f_eq(word,"-")) && U32.is_eq(f_col(f_tl(skipped)),U32.add(f_col(skipped),1))),
    u => f_grow_base(FParsed{n,skipped},min),
    u => p175p_grow_suffix(n,ts,min,"\n"))
law p175p_grow_bang:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +next: FInput
  FParsed

@unsafe
def w7_br_990(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_index(n,f_expect(f_expr(f_tl(ts),0),"]"),min)
    case False{}:
      f_grow_base(FParsed{n,ts},min)

@unsafe
def w7_br_991(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match w7_c:
    case True{}:
      p175p_grow_bang(n,ts,min,f_tl(ts))
    case False{}:
      w7_br_990(f_eq(word,"["), n, ts, min)

@unsafe
def p175p_grow_suffix(n,ts,min,word):
  w7_br_991(f_eq(word,"!"), n, ts, min, word)

@unsafe
def w7_br_992(w7_c: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_bang(f_context_call_head(n),ts,min)
    case False{}:
      f_grow_base(FParsed{n,ts},min)

@unsafe
def p175p_grow_bang(n,ts,min,next):
  w7_br_992(f_eq(f_tx(next),"(") && U32.is_eq(f_line(ts),f_line(next)) && U32.is_eq(f_col(next),U32.add(f_col(ts),1)), n, ts, min)
# Exact ordered first non-native names. Reuse the existing collision-safe set.
# Native rows must not mark their names: a later ordinary row may still be own.
@unsafe
def x185_fact_body(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_fact_enabled() && U32.is_lt(p113i_size(body),4096) && Bool.not(x185_fact_returns(body)),
    u => x185_fact_result(p113k_body(body,missing())),u => body)

@unsafe
def agy_x185_fact_and_copy(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_fact_enabled() && U32.is_lt(p113i_size(body),4096) && Bool.not(x185_fact_returns(body)),
    u => x185_copy_function(params,setup,x185_fact_result(p113k_body(body,missing()))),
    u => body)

@unsafe
def x185_prepare_body(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x185_dead_body(setup,agy_x185_fact_and_copy(params,setup,x185_copy_function(params,setup,body)))
# Transient machine homes, after the existing callee-saved placement. Every
# admitted name is confined to one call-free region and starts with a write.
# All reads AND writes extend its interval; no value is spilled or moved when
# a home is reused. Parameters/setup definitions retain their original homes.
@unsafe
def x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: List<&2,U32>, +tempRegs: U32) -> KDef:
  x186_x_scanned_capped(w2b_x_scan(nodes,cidx,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}),tempRegs)

law x186_x_emit_nodes:
  for nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  for +code: X181Code
  X181Code

@unsafe
def x186_x_emit_if(condition: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x186_x_emit_yes(+label: U32, no: List<&2,X186FloatNode>, ids: N111Ids,
    +frame: X181Frame, homes: KDef, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x186_x_emit_nodes(no,ids,frame,homes,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x186_x_emit_node(+node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match node:
    case X186FloatValues{+name,+id,+left,+right}:
      nt_choose(X181Code,U32.is_eq(id,36),u => x200r_sqrt_emit(name,left,ids,frame,homes,code),
        u => x181_add(x186_x_float(name,id,left,right,ids,frame,homes),code))
    case X186FloatPlain{+stmt}:
      match stmt:
        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)
        case P113DAgain{+vals}:
          +cnt = da(p111v_get(homes,"$w4_carried_count"))
          +code2 = nt_choose(X181Code,U32.is_gt(cnt,0),
                     u => x181_add(w4_xl_again_updates(0,cnt,vals,ids,frame,homes),code),
                     u => code)
          +stmt2 = nt_choose(P113DStmt,U32.is_gt(cnt,0),
                     u => P113DAgain{w4_xl_again_rewrite(0,cnt,vals,homes)},
                     u => stmt)
          x181_stmt(stmt2,ids,frame,code2)
        case _: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_x_emit_if(condition,yes,no,ids,frame,homes,code)
# Wave2 Pass 2a: Dead constant-set pruning on X186FloatNode.
@unsafe
def w2_emit_branch_custom(prefix: X188Seq, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{prefix,chunks},U32.add(next,2),False{},error}))

law w2_tbl_chain:
  for +val: N111Value
  for +last: U32
  for +nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  for +code: X181Code
  X181Code

@unsafe
def w2_tbl_chain_go(hit: W2TblMatch, +val: N111Value, +last: U32, nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match hit:
    case W2TblHit{+dest,+sym,+val2,+last2,rest}:
      nt_choose(X181Code,U32.is_eq(last,last2) && w2_val_eq(val,val2),
        u => nt_choose(X181Code,w2_val_reads(dest,val),
          v => x186_x_emit_nodes(rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame,homes),code)),
          v => w2_tbl_chain(val,last,rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame,homes),code))),
        u => x186_x_emit_nodes(nodes,ids,frame,homes,code))
    case W2TblMiss{}: x186_x_emit_nodes(nodes,ids,frame,homes,code)

@unsafe
def w2_tbl_chain(val,last,nodes,ids,frame,homes,code):
  w2_tbl_chain_go(w2_tbl_match(nodes),val,last,nodes,ids,frame,homes,code)

# Wave2B: Float copy coalescing:
#   X186FloatValues{tmp, id, l, r} ; X186FloatPlain{P113DScalar{N111Set{dst, N111U64{}, N111Local{tmp}}}}
# when tmp is dead after -> X186FloatValues{dst, id, l, r} (eliminates redundant movaps).
@unsafe
def w2b_emit_bool_fast(+word: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      # Use next = l_no, next+1 = l_end (standard x186_x_emit_yes), next+2 = l_yes!
      +prefix = w2b_bool_fast_prefix(word,next,U32.add(next,2),ids,frame)
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{prefix,chunks},U32.add(next,3),False{},error}))

@unsafe
def w2_x_emit_branch_or_node(nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  match nodes:
    case Con{X186FloatValues{+c1,+id,+left,+right},
         Con{X186FloatPlain{P113DScalar{N111Bin{+c2,typ,"eq",N111Local{+c1b},N111Const{1,0}}}},
         Con{X186FloatBranch{N111Local{+c2b},+yes,+no},+rest}}}:
      nt_choose(X181Code,U32.is_ge(id,32) && U32.is_le(id,35) && agy_str_eq(c1,c1b) && agy_str_eq(c2,c2b) &&
          w2_dead_in(c1,yes,[rest],64) && w2_dead_in(c1,no,[rest],64) &&
          w2_dead_in(c2,yes,[rest],64) && w2_dead_in(c2,no,[rest],64),
        u => x186_x_emit_nodes(rest,ids,frame,homes,
               w2_emit_branch_custom(w2_fbranch_code(id,left,right,w2_code_next(code),ids,frame,homes),yes,no,ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatPlain{P113DScalar{N111Bin{c2,typ,"eq",N111Local{c1b},N111Const{1,0}}}},
               Con{X186FloatBranch{N111Local{c2b},yes,no},rest}},ids,frame,homes,
               x186_x_emit_node(X186FloatValues{c1,id,left,right},ids,frame,homes,code)))
    case Con{X186FloatValues{+c1,+id,+left,+right},
         Con{X186FloatBranch{N111Local{+c1b},+yes,+no},+rest}}:
      nt_choose(X181Code,U32.is_ge(id,32) && U32.is_le(id,35) && agy_str_eq(c1,c1b) &&
          w2_dead_in(c1,yes,[rest],64) && w2_dead_in(c1,no,[rest],64),
        u => x186_x_emit_nodes(rest,ids,frame,homes,
               w2_emit_branch_custom(w2_fbranch_code(id,left,right,w2_code_next(code),ids,frame,homes),yes,no,ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatBranch{N111Local{c1b},yes,no},rest},ids,frame,homes,
               x186_x_emit_node(X186FloatValues{c1,id,left,right},ids,frame,homes,code)))
    case Con{X186FloatPlain{P113DScalar{N111Bin{+c,+typ,+op,+left,+right}}},
         Con{X186FloatBranch{N111Local{+cb},+yes,+no},+rest}}:
      nt_choose(X181Code,agy_str_eq(c,cb) && Bool.not(String.is_empty(w2_int_inv(op))) &&
          w2_dead_in(c,yes,[rest],512) && w2_dead_in(c,no,[rest],512),
        u => x186_x_emit_nodes(
               nt_choose(List<&2,X186FloatNode>,agy_str_eq(op,"eq") && List.is_empty(&2,X186FloatNode,no) && w2_nodes_term(yes),
                 v => w2_skip_dom_ne(typ,left,right,rest),v => rest),
               ids,frame,homes,
               w2_emit_branch_custom(w2_int_branch_code(typ,op,left,right,w2_code_next(code),ids,frame),yes,
                 nt_choose(List<&2,X186FloatNode>,agy_str_eq(op,"eq"),v => w2_skip_dom_ne(typ,left,right,no),v => no),
                 ids,frame,homes,code)),
        u => x186_x_emit_nodes(Con{X186FloatBranch{N111Local{cb},yes,no},rest},ids,frame,homes,
               x186_x_emit_node(X186FloatPlain{P113DScalar{N111Bin{c,typ,op,left,right}}},ids,frame,homes,code)))
    case Con{head,rest}:
      x186_x_emit_nodes(rest,ids,frame,homes,x186_x_emit_node(head,ids,frame,homes,code))
    case Nil{}: code

@unsafe
def w2b_emit_bool_or_branch(hit: W2BoolMatch, +nodes: List<&2,X186FloatNode>, +ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match hit:
    case W2BoolHit{word,yes,no,rest}:
      x186_x_emit_nodes(rest,ids,frame,homes,w2b_emit_bool_fast(word,yes,no,ids,frame,homes,code))
    case W2BoolMiss{}: w2_x_emit_branch_or_node(nodes,ids,frame,homes,code)

@unsafe
def w2_x_emit_step_go(hit: W2TblMatch, +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  match hit:
    case W2TblHit{+dest,+sym,+val,+last,rest}:
      +code1 = x181_add(x188_cat(w2_tbl_clamp(val,last,ids,frame),w2_tbl_store(dest,sym,frame,homes)),code)
      nt_choose(X181Code,w2_val_reads(dest,val),
        u => x186_x_emit_nodes(rest,ids,frame,homes,code1),
        u => w2_tbl_chain(val,last,rest,ids,frame,homes,code1))
    case W2TblMiss{}: w2b_emit_bool_or_branch(w2b_bool_match(nodes),nodes,ids,frame,homes,code)

@unsafe
def w2_x_emit_step(+nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame,
    +homes: KDef, +code: X181Code) -> X181Code:
  w2_x_emit_step_go(w2_tbl_match(nodes),nodes,ids,frame,homes,code)

@unsafe
def x186_x_emit_nodes(nodes,ids,frame,homes,code):
  match nodes code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 XMM plan statement after terminal",code),
          u => w2_x_emit_step(Con{head,rest},ids,frame,homes,code)),u => code)

# Wave2 Pass 2b: Loop-invariant / loop-carried F32 param & F32 constant hoisting into xmm10..xmm15.
@unsafe
def w4_xl_build_loop(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +hotConsts = nt_reverse(U32,w4b_xl_hot_consts(nodes,[]),[])
  +startReg = w4b_xl_start_reg(tparams,nodes,hotConsts)
  +tempRegs = U32.sub(startReg,2)
  +probe = w2b_plan_after_carried(
             w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,W2XLAlloc{missing(),X188Empty{},startReg}),
             tparams,nodes,hotConsts,startReg,ids,frame)
  +cidxs = w4_carried_idxs(w4_plan_carried(probe))
  w2b_plan_after_carried(
    w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,
      W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidxs,tempRegs),X188Empty{},startReg}),
    tparams,nodes,hotConsts,startReg,ids,frame)

@unsafe
def w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +tparams = w2_xl_tail_params(params)
  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),
    u => w4_xl_build_loop(params,setup,tparams,nodes,ids,frame),
    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},[],False{}})

@unsafe
def w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  match plan:
    case W2XLoopPlan{+homes,pre,+carried,active}:
      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),
                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))
      +homes2 = w4_xl_store_carried(carried,0,homes)
      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))

@unsafe
def x186_x_emit_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  w2_xl_emit_with_plan(w2_xl_plan(params,setup,nodes,ids,frame),symbol,setup,nodes,ids,frame)

@unsafe
def x186_x_select_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  nt_choose(X181Output,x186_xmm_enabled(),u => x186_x_emit_frame(symbol,params,setup,nodes,ids,frame),
    u => x186_f_emit_frame(symbol,setup,nodes,ids,frame))
# Rename only float definitions overwritten within the same closed region.
# A bounded suffix certificate guarantees the original destination is rewritten
# before any ordinary operation/control edge can observe it. No publication is
# removed at a boundary; final writes retain their original names and full words.
@unsafe
def x190_l_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_l_graphed(frame,params,setup,body,names,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x185_transient_frame(frame,params,setup,body))

@unsafe
def x190_l_selected(+frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x190_l_solved(frame,params,setup,body,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))

# Both callers supply a distinct, encounter-ordered name list from X181ReadCounts.
@unsafe
def x190_l_counted(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,names}:
      x190_l_selected(frame,params,setup,body,x203_candidates(nt_reverse(String,names,[]),reads,slots))

@unsafe
def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_l_counted(frame,params,setup,body,x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]}))),
    u => x185_transient_frame(frame,params,setup,body))

# Optional joint coloring starts from x181_frame, before fixed placement.
# Colors 0..3 are saved homes 1..4; colors 4..8 are the five caller homes.
# The same graph controls both pools. A self edge is a call-clobber marker,
# removed only when considering a callee-saved color; all other edges survive.
@unsafe
def x190_allocate_legacy(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>) -> X181Frame:
  x190_liveness_frame(x181_register_frame(frame,registerBody),params,setup,body)

# W5C-R1: General post-joint transient register allocation for overflow locals
# when joint graph-coloring reaches its 32-candidate bitmask cap.
@unsafe
def x191_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x199s_done(symbol,x190_stmts(body,facts,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))),
    U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) && x190_register_loop(body),frame)


@unsafe
def x185_function_frame(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x186_function_saved(symbol,setup,body,ids,x186_saves_frame(frame))

@unsafe
def x186_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x190_stmts(body,x190_branch_facts(x190_frame_params(frame),setup,body),ids,frame,x181_add(X188One{PLabel{x181_loop_label(frame)}},
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x198pw_annotate(+r: NR_Request,+prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_ro_annotate(r,x198pw_ready(x198pw_owners(scope,book,[]),prepared))

@unsafe
def agy_fl_family(+book: List<&2,KDef>, +owner: String, +ty: String, +leaf: String, +node: String) -> AgyFlowPlan:
  +r0 = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(
    missing(),"self",owner),"leaf",leaf),"node",node),"zero","Zero"),"succ","Succ")
  +s1 = x198pw_def(book,"self",3,agy_fl_pat_z_leaf(),X198PWState{r0,missing()})
  +s2 = x198pw_def(book,"self",3,agy_fl_pat_z_node(),s1)
  +s3 = x198pw_def(book,"self",3,agy_fl_pat_s_leaf(),s2)
  +s4 = x198pw_def(book,"self",3,agy_fl_pat_s_node(),s3)
  +s5 = x198pw_def(book,"wn",2,agy_fl_pat_wn_leaf(),s4)
  +s6 = x198pw_def(book,"wn",2,agy_fl_pat_wn_node(),s5)
  agy_fl_finish(book,owner,ty,s6)

@unsafe
def agy_fl_try_ctors(+book: List<&2,KDef>, +owner: String, +ty: String, cs: List<&2,KDef>) -> AgyFlowPlan:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(AgyFlowPlan,x198pw_ctor(a,dn(a),["U32"],ty) && x198pw_ctor(b,dn(b),[ty,ty],ty),
        u => agy_fl_family(book,owner,ty,dn(a),dn(b)),
        u => nt_choose(AgyFlowPlan,x198pw_ctor(b,dn(b),["U32"],ty) && x198pw_ctor(a,dn(a),[ty,ty],ty),
          v => agy_fl_family(book,owner,ty,dn(b),dn(a)),
          v => AgyFlowNone{}))
    case _: AgyFlowNone{}

@unsafe
def agy_fl_checked_plan(+book: List<&2,KDef>, +d: KDef) -> AgyFlowPlan:
  +t = dt(d)
  +ty = nm(kid(kid(kid(t,1),1),0))
  +adt = lookup(book,ty)
  nt_choose(AgyFlowPlan,x198pw_tel(t,["Nat","Bool",ty],ty) &&
      agy_str_eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) && U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_fl_try_ctors(book,dn(d),ty,dc(adt)),
    u => AgyFlowNone{})

@unsafe
def agy_fl_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,AgyFlowPlan>) -> List<&2,AgyFlowPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_fl_owners(rest,book,nt_choose(List<&2,AgyFlowPlan>,
        agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)) &&
        agy_str_eq(tg(dt(d)),"All") && agy_str_eq(tg(kid(dt(d),1)),"All") && agy_str_eq(tg(kid(kid(dt(d),1),1)),"All"),
        u => agy_fl_add(agy_fl_checked_plan(book,d),acc),u => acc))

@unsafe
def agy_fl_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_fl_ready(agy_fl_owners(scope,book,[]),prepared)

@unsafe
def agy_da_check_done(+name: String, +params: List<&2,NC_Binding>, +result: U32,
    +heap: U32, +u: U32, done: P113DFunction) -> Bool:
  match done:
    case P113DFunction{_,_,_,_,+body}:
      +pnames : List<&2,String> = Con{"state",Con{"__x181_result_out",x181_param_names(params)}}
      +prel = nt_append(N111Stmt,p117h_prelude(params,1,u,heap),x185_array_dispatch(name,params,result,u))
      +setup = x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prel})
      +cleaned = x185_dead_body(setup,
        x185_copy_function(pnames,setup,x186_expression_body(setup,
          x190_local_values_body(setup,x192_predicate_body(x186_private_body(pnames,setup,
            x185_prepare_body(pnames,setup,x185_scratch_body(pnames,setup,body))))))))
      agy_da_has_scan4(x199s_select(pnames,cleaned))

@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  w7_seq_after_one(String.is_empty(x187_build_message(build)),todo,build,count)

@unsafe
def x187_build_seq(seq: X188Seq, +build: X187Build) -> X187Build:
  w7_seq_after_one(String.is_empty(x187_build_message(build)),[seq],build,0)

@unsafe
def x187_build_chunks(+chunks: List<&2,X188Seq>, +build: X187Build) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_chunks_good(chunks,build),u => build)

@unsafe
def x187_build_chunks_good(+chunks: List<&2,X188Seq>, +build: X187Build) -> X187Build:
  match chunks:
    case Nil{}: build
    case Con{head,rest}: x187_build_chunks(rest,x187_build_seq(head,build))

# Relocations arrive in reverse creation order. Prepending selected patches
# restores monotonically increasing text offsets, even across section switches.
# Remaining references form the exact escape set for local symbol retention.
@unsafe
def x187_output(+output: X181Output, +build: X187Build) -> X187Build:
  match output:
    case X181Output{chunks,+error}:
      nt_choose(X187Build,String.is_empty(error),u => x187_build_chunks(chunks,build),u => x187_build_error(error,build))

# Consume a function at a time; do not collect a complete assembly program.
@unsafe
def x181_function_fast(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(body),
    u => x181_function_fast_late(symbol,params,ids,x185_late_stmts(body,ids,0)),
    u => x181_function_fast_emit(symbol,params,body,ids))

@unsafe
def w9_private_fast_sh(sh: Maybe<&2,X181Output>, +function: P113DFunction, +symbol: String,
    +names: List<&2,String>, +body: List<&2,P113DStmt>, +ids: N111Ids, +ready: KDef) -> X181Output:
  match sh:
    case Some{out}: x181_program_join(out,x181_forward(function,ready))
    case None{}: x181_program_join(x181_function_fast(symbol,names,body,ids),x181_forward(function,ready))

@unsafe
def w7c_public_fast(+symbol: String, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_body_names(body),
    u => w7c_public_fast_late(symbol,["state"],ids,x185_late_stmts(body,ids,0)),
    u => w7c_public_fast_emit(symbol,["state"],body,ids))

@unsafe
def x181_program_public_fast(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)
      nt_choose(X181Output,String.is_empty(error),
        u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),
          v => w7c_public_fast(p111q_symbol(name),x181_scalar_rows(body),ids)),
        u => X181Output{[],error})

law w10f_output_fn:
  for +output: X181Output
  for +build: X187Build
  X187Build

@unsafe
def x202p_x201f_finish(+build: X187Build) -> IO(U32):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        nt_choose(IO(U32),x188_symbol_count(names,0,1),v =>
          x202p_x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => IO.die(U32,1,"invalid or duplicate ELF symbol")),
        u => IO.die(U32,1,error))

@unsafe
def agy_parcg_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          agy_parcg_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

@unsafe
def agy_parcg_prepare_cursor(+prepared: P169Prepared) -> AgyParCgReady:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(AgyParCgReady,String.is_empty(error),u =>
        +avail = x181_cursor_index(cursor,missing())
        AgyParCgReady{agy_enrich_cursor(cursor,avail),avail,""},
        u => AgyParCgReady{cursor,missing(),error})

@unsafe
def agy_parcg_native_finish(+build: X187Build) -> IO(U32):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        nt_choose(IO(U32),x188_symbol_count(names,0,1),v =>
          agy_parcg_native_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => IO.die(U32,1,"invalid or duplicate ELF symbol")),
        u => IO.die(U32,1,error))

@unsafe
def w10_merge_run(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> IO(U32):
  nt_choose(IO(U32),Bool.not(String.is_empty(entry_mod)) && w10_merge_names_ok(mods),
    u => x202p_x201f_finish(x187_build_seq(w10_merge_seq(entry_mod,first_mod,mods),x187_build_empty())),
    u => IO.die(U32,2,"x86-merge-obj: module names must be non-empty"))

@unsafe
def w10_merge_entry(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+entry_mod,Con{+first_mod,+more_mods}}:
      w10_merge_run(entry_mod,first_mod,Con{first_mod,more_mods})
    case _: IO.die(U32,2,"usage: x86-merge-obj ENTRY_MOD MOD0 [MOD1 ...]")

# === WAVE 10 M2: Pure-Bend ELF64 Symbol Visibility (reconciled with w9_elf_fast) ===
# Wave 10 Phase 1 (M2): Pure-Bend ELF64 Symbol Visibility for `x86-module`.
# Eliminates `objcopy -L` and `objcopy -W` completely by emitting proper ELF64
# symbol bindings (`STB_LOCAL=0`, `STB_GLOBAL=1`, `STB_WEAK=2`) with exact
# local-before-nonlocal `.symtab` ordering and `.symtab` `sh_info` directly
# inside the self-hosted Bend ELF builder.
#
# Visibility rules for defined (`section != 0`) symbols in `x86-module` mode:
#   1. `STB_LOCAL` (binding=0, index < sh_info):
#        - `.L*` local labels (existing)
#        - `$p111.k.*` module-private CPS continuations
#          (`p111_FID_36_112_49_49_49_46_107_46_*` / `p113d_FID_36_112_49_49_49_46_107_46_*`)
#        - per-module `def main` (`p111_FID_109_97_105_110_` / `p113d_FID_109_97_105_110_`)
#        - non-exported data tables (`p111_cid_*`, `p111_static_image`, etc.)
#   2. `STB_WEAK` (binding=2, index >= sh_info):
#        - Any defined function symbol originating from the imported `P86Seed.book`
#          (Base helpers such as `U32.*`, `List.*`, `String.*` AND imported module
#          interface stubs). Strong `STB_GLOBAL` definitions in the owning module
#          always override `STB_WEAK` stubs regardless of link order, and duplicate
#          `STB_WEAK` Base helpers merge cleanly in GNU `ld`.
#   3. `STB_GLOBAL` (binding=1, index >= sh_info):
#        - Module-owned definitions (defined in the module's own source, not in `seed.book`)
#        - Module table exports (`p111_mod_<M>_fid_base`, `p111_mod_<M>_program`,
#          `p111_mod_<M>_p111_segments`, `p111_mod_<M>_p111_fid_*`)
#        - Undefined external references (`section == 0`)
#   4. C `main` (`x181_program_main`) is omitted in `x86-module` mode (provided by
#      the link merge driver `p111_link_merge.c`).

@unsafe
def w10f_fn_parsed(+parsed: X187Parsed, +st: W10fFnBuild) -> W10fFnBuild:
  match parsed st:
    case PLabel{+name} W10fFnBuild{+build,+lsyms,+lrelocs}:
      nt_choose(W10fFnBuild,String.starts_with(name,".L") && U32.is_eq(x187_build_section(build),1),
        u => w10f_fn_label_local(name,x187_build_offset(build),build,lsyms,lrelocs),
        u => W10fFnBuild{x187_build_symbol(name,1,0,build),lsyms,lrelocs})
    case PInst{+inst} W10fFnBuild{+build,+lsyms,+lrelocs}:
      w10f_fn_inst(inst,build,lsyms,lrelocs)
    case other W10fFnBuild{+build,+lsyms,+lrelocs}:
      W10fFnBuild{x187_build_parsed(other,build),lsyms,lrelocs}

law w10f_fn_seq_go:
  for seq: X188Seq
  for rest: List<&2,X188Seq>
  for +st: W10fFnBuild
  for +count: U32
  W10fFnBuild

@unsafe
def w10f_fn_seq_pop(rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match rest:
    case Nil{}: st
    case Con{head,tail}: w10f_fn_seq_go(head,tail,st,count)

@unsafe
def w10f_fn_after_one(ok: Bool, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match ok:
    case True{}: w10f_fn_seq_pop(rest,st,count)
    case False{}: st

@unsafe
def w10f_fn_seq_step(seq: X188Seq, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match seq:
    case X188Empty{}: w10f_fn_seq_pop(rest,st,count)
    case X188One{item}:
      +st2 = w10f_fn_parsed(item,st)
      w10f_fn_after_one(w10f_fn_st_ok(st2),rest,st2,count)
    case X188Join{left,right}: w10f_fn_seq_go(left,Con{right,rest},st,count)

@unsafe
def w10f_fn_seq_chk(ok: Bool, seq: X188Seq, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match ok:
    case True{}: w10f_fn_seq_step(seq,rest,st,U32.inc(count))
    case False{}:
      match st:
        case W10fFnBuild{build,lsyms,lrelocs}:
          W10fFnBuild{x187_build_error("x86 object fragment count exceeds bound",build),lsyms,lrelocs}

@unsafe
def w10f_fn_seq_go(seq, rest, st, count):
  w10f_fn_seq_chk(U32.is_lt(count,67108864),seq,rest,st,count)

@unsafe
def w10f_fn_chunks(chunks: List<&2,X188Seq>, +st: W10fFnBuild) -> W10fFnBuild:
  match chunks:
    case Nil{}: st
    case Con{+head,+rest}:
      nt_choose(W10fFnBuild,w10f_fn_st_ok(st),
        u => w10f_fn_chunks(rest,w10f_fn_seq_go(head,[],st,0)),
        u => st)

@unsafe
def w10f_output_fn(output, build):
  match output:
    case X181Output{+chunks,+error}:
      nt_choose(X187Build,String.is_empty(error) && String.is_empty(x187_build_message(build)),
        u => w10f_fn_finish(w10f_fn_chunks(chunks,W10fFnBuild{build,missing(),[]})),
        u => x187_build_error(p111_first(x187_build_message(build),error),build))

# --- Part B: Zero-Copy Tail-Fused ELF Emission (`w10f_elf_sections_emit_rev`) ---


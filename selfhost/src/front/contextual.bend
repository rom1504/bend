
# Resolution selects the declaration table named by the syntax. A local def
# named Done must not hide Base's Done constructor, or vice versa.
@unsafe
def f_context_known(+name: String, +scope: FParseScope, +constructor: Bool) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, view}:
      f_choose(Bool, constructor,
        u => Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")),
        u => f_declared(name, prior))

@unsafe
def f_context_resolve_table(+term: KTerm, +scope: FParseScope, +constructor: Bool) -> KTerm:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, view}:
      +name = nm(term)
      +alias = f_alias(name, aliases)
      +near = f_choose(String, p88_string_eq(alias, name), u => f_qual_name(name, ns), u => alias)
      f_choose(KTerm, p88_string_eq(near, name),
        u => kt_span("Ref", name, 0, 1, Nil{}, kb(term), ke(term)),
        u => f_choose(KTerm, f_choose(Bool, p88_string_eq(alias, name), u => False{}, u => f_context_known(alias, scope, constructor) && f_context_known(name, scope, constructor)),
          u => fpe_point_at(k_with_span(term, ke(term), ke(term)), "expected an unambiguous name (an import alias shadows " ++ name ++ ")", "an unambiguous name (the alias " ++ f_import_alias_head(name) ++ " shadows " ++ name ++ ")"),
          u => kt_span("Ref", f_choose(String, f_context_known(near, scope, constructor) || Bool.not(f_context_known(name, scope, constructor)), u => near, u => name), 0, 1, Nil{}, kb(term), ke(term))))

# Sugar uses its file's own spelling, without applying import aliases.
@unsafe
def f_context_own(+name: String, +input: FInput, +constructor: Bool) -> String:
  match input:
    case FInput{tokens,FParseContext{+scope,env,next}}:
      match scope:
        case FParseScope{prior,index,ctorIndex,+ns,aliases,view}:
          +near = f_qual_name(name,ns)
          f_choose(String,p88_string_eq(near,name),u => name,
            u => f_choose(String,f_context_known(near,scope,constructor) || Bool.not(f_context_known(name,scope,constructor)),u => near,u => name))

# Module: src/front/contextual.bend:4
@unsafe
def f_context_resolve(+term: KTerm, +scope: FParseScope) -> KTerm:
  f_context_resolve_table(term, scope, False{})

# Module: src/front/contextual.bend:14

@unsafe
def f_context_name(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +bound = f_env(nm(term), env)
          f_choose(FParsed, p98_tag_eq(bound, "Absent"),
            u => f_context_name_resolved(term, input, f_context_resolve(term, scope)),
            u => FParsed{kt_span("Var", nm(bound), ix(bound), 1, Nil{}, kb(term), ke(term)), input})

# Module: src/front/contextual.bend:25
@unsafe
def f_context_name_resolved(+term: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_choose(FParsed, p98_tag_eq(resolved, "Error"), u => f_context_error_at(resolved, input, ke(term)), u => f_choose(FParsed, String.contains(nm(term), "."), u => FParsed{resolved, input},
            u => FParsed{kt_span("FName", nm(term), 0, 1, [kt_span("Var", nm(term), next, 1, Nil{}, kb(term), ke(term)), resolved], kb(term), ke(term)), FInput{tokens, FParseContext{scope, env, U32.add(next, 1)}}}))

# Module: src/front/contextual.bend:34
@unsafe
def f_context_open(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +binder = kt_span("Var", nm(term), next, qt(term), Nil{}, kb(term), ke(term))
          FParsed{binder, FInput{tokens, FParseContext{scope, f_choose(List<&2,KTerm>, p88_string_eq(nm(term), "_"), u => env, u => Con{binder, env}), U32.add(next, 1)}}}

# Module: src/front/contextual.bend:43
@unsafe
def f_context_close(+input: FInput, +outer: List<&2,KTerm>) -> FInput:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: FInput{tokens, FParseContext{scope, outer, next}}

# Module: src/front/contextual.bend:50
@unsafe
def f_context_rewind(+old: FInput, +input: FInput) -> FInput:
  match old:
    case FInput{tokens, ignored}:
      match input:
        case FInput{discarded, context}: FInput{tokens, context}

# Module: src/front/contextual.bend:57
@unsafe
def f_context_parameters(+parameters: List<&2,KTerm>, +env: List<&2,KTerm>) -> List<&2,KTerm>:
  match parameters:
    case Nil{}: env
    case Con{parameter, rest}:
      f_context_parameters(rest, f_choose(List<&2,KTerm>, p88_string_eq(nm(parameter), "_"), u => env, u => Con{parameter, env}))

# Module: src/front/contextual.bend:64
@unsafe
def f_context_stop(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Error")

# Module: src/front/contextual.bend:68
@unsafe
def f_context_atom_name(+input: FInput) -> FParsed:
  f_context_name(kt_span("Ref", f_tx(input), 0, 1, Nil{}, f_begin(input), f_end(input)), f_tl(input))

# Module: src/front/contextual.bend:72
@unsafe
def f_context_call_head(+term: KTerm) -> KTerm:
  f_choose(KTerm, p98_tag_eq(term, "FName"), u => k_with_span(kid(term, 1), kb(term), ke(term)), u => term)

# Module: src/front/contextual.bend:76
@unsafe
def f_context_grow(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => p, u => f_grow_existing(p, min))

# Module: src/front/contextual.bend:82
@unsafe
def f_context_failure_rest(+start: FInput, +end: FInput) -> FInput:
  end

# Module: src/front/contextual.bend:86
@unsafe
def f_context_error_at(+error: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  FParsed{error, f_prepend(FToken{"", f_line(input), f_col(input), 0, cursor, cursor, cursor}, f_empty(input))}

# Module: src/front/contextual.bend:90
@unsafe
def f_context_pattern(+pattern: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +syntax = f_context_syntax(pattern)
          f_choose(FParsed, p98_tag_eq(syntax, "Var"),
            u => f_context_pattern_named(syntax, input, cursor, f_context_resolve_table(k_with_span(syntax, cursor, cursor), scope, True{})),
            u => f_choose(FParsed, core_literal(pattern), u => f_context_pattern(core_literal_step(pattern), input, cursor), u => f_choose(FParsed, p98_tag_eq(pattern, "Ctr"), u => f_context_pattern_ctor(pattern, input, cursor, scope), u => f_context_pattern_computed(pattern, input, cursor, f_context_higher(pattern)))))

# Module: src/front/contextual.bend:101
@unsafe
def f_context_pattern_named(+pattern: KTerm, +input: FInput, +cursor: U32, +resolved: KTerm) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              f_choose(FParsed, p98_tag_eq(resolved, "Error"), u => f_context_error_at(resolved, input, cursor),
                u => f_context_pattern_checked(pattern, input, cursor, f_valid_var_pattern(pattern, f_ctor_index_find(nm(resolved), ctorIndex))))

# Module: src/front/contextual.bend:112

@unsafe
def f_context_pattern_checked(+pattern: KTerm, +input: FInput, +cursor: U32, +error: Maybe<&2,KTerm>) -> FParsed:
  match error:
    case Some{error}: f_context_error_at(error, input, cursor)
    case None{}: f_context_open(pattern, input)

# Module: src/front/contextual.bend:118
@unsafe
def f_context_pattern_computed(+pattern: KTerm, +input: FInput, +cursor: U32, +observed: KTerm) -> FParsed:
  f_choose(FParsed, f_context_stop(observed), u => FParsed{observed, input},
    u => f_context_pattern_observed(pattern, input, cursor, f_fresh_term(observed, f_context_free_env(f_context_outer(input)), 0)))

# Module: src/front/contextual.bend:123
@unsafe
def f_context_pattern_observed(+pattern: KTerm, +input: FInput, +cursor: U32, +fresh: FFresh) -> FParsed:
  match fresh:
    case FFresh{term, next}: f_context_error_at(f_computed_pattern_error(pattern, term), input, cursor)

# Module: src/front/contextual.bend:128
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
def f_context_let_done(+pattern: KTerm, +value: KTerm, +outer: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{body, rest}:
      f_choose(FParsed, f_context_stop(body), u => parsed, u => FParsed{kt_span("Local", "", 0, 1, [pattern, f_choose(KTerm, p98_tag_eq(pattern, "Ctr"), u => f_context_head(value), u => value), body], kb(pattern), ke(pattern)), f_context_close(rest, outer)})

# Module: src/front/contextual.bend:150
@unsafe
def f_context_free_env(+env: List<&2,KTerm>) -> List<&2,KTerm>:
  match env:
    case Nil{}: Nil{}
    case Con{binding, rest}: Con{kt("Map", "", ix(binding), 0, [ref(nm(binding))]), f_context_free_env(rest)}

# Private scoped heads preserve the parser's syntax/value distinction.

# Module: src/front/contextual.bend:157
@unsafe
def f_context_head(+term: KTerm) -> KTerm:
  f_choose(KTerm, p98_tag_eq(term, "FName"), u => f_context_syntax(term), u => f_choose(KTerm, p98_tag_eq(term, "Ref"), u => kt_span("FComputedHead", "", 0, 1, [term], kb(term), ke(term)), u => term))

# Module: src/front/contextual.bend:161
@unsafe
def f_context_atom_done(+p: FParsed) -> FParsed:
  match p:
    case FParsed{term, rest}: FParsed{f_choose(KTerm, p98_tag_eq(term, "Literal"), u => f_literal_at(term), u => term), rest}

# Module: src/front/contextual.bend:166
@unsafe
def f_context_constructor(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_context_constructor_done(term, input, f_context_resolve_table(k_with_span(term, f_previous_end(input), f_previous_end(input)), scope, True{}))

# Module: src/front/contextual.bend:173
@unsafe
def f_context_constructor_done(+term: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  f_choose(FParsed, f_context_stop(resolved), u => f_context_error_at(resolved, input, f_previous_end(input)), u => FParsed{kt_span("Ctr", nm(resolved), 0, 1, ks(term), kb(term), ke(term)), input})

# Module: src/front/contextual.bend:177
@unsafe
def f_context_pattern_ctor(+term: KTerm, +input: FInput, +cursor: U32, +scope: FParseScope) -> FParsed:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      f_context_ctor_checked(term, input, cursor, f_valid_ctor_head(term, f_ctor_index_find(nm(term), ctorIndex)))

# Module: src/front/contextual.bend:183

@unsafe
def f_context_patterns(+owner: KTerm, +patterns: List<&2,KTerm>, +input: FInput, +cursor: U32, +acc: List<&2,KTerm>) -> FParsed:
  match patterns:
    case Nil{}: FParsed{k_with_children(owner, List.reverse(&2, KTerm, acc)), input}
    case Con{pattern, rest}: f_context_patterns_next(owner, rest, cursor, acc, f_context_pattern(pattern, input, cursor))

# Module: src/front/contextual.bend:189
@unsafe
def f_context_patterns_next(+owner: KTerm, +patterns: List<&2,KTerm>, +cursor: U32, +acc: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_patterns(owner, patterns, rest, cursor, Con{term, acc}))

# Module: src/front/contextual.bend:194
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
def f_context_close_done(+parsed: FParsed, +outer: List<&2,KTerm>) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => FParsed{term, f_context_close(rest, outer)})

# Module: src/front/contextual.bend:211
@unsafe
def f_context_flat(+parsed: FParsed, +vars: List<&2,KTerm>) -> FParsed:
  match parsed:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_flat_input(term, f_space(rest), vars))

# Module: src/front/contextual.bend:217
@unsafe
def f_context_flat_input(+term: KTerm, +input: FInput, +vars: List<&2,KTerm>) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_context_flat_done(input, ff_flat(term, vars, next))

# Module: src/front/contextual.bend:225
@unsafe
def f_context_group_done(+parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_choose(FParsed, f_eq(f_tx(rest), ":"), u => f_group_namespace(term, f_expr(f_tl(rest), 0)), u => f_expect(parsed, ")")))

# Module: src/front/contextual.bend:230
@unsafe
def f_context_ctor_checked(+term: KTerm, +input: FInput, +cursor: U32, +error: Maybe<&2,KTerm>) -> FParsed:
  match error:
    case Some{error}: f_context_error_at(error, input, cursor)
    case None{}: f_context_patterns(term, ks(term), input, cursor, Nil{})

# Module: src/front/contextual.bend:236
@unsafe
def f_context_flat_done(+input: FInput, +flat: FFlatten) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match flat:
            case FFlatten{body, after}: FParsed{body, FInput{tokens, FParseContext{scope, env, after}}}

# Module: src/front/contextual.bend:245
@unsafe
def f_context_header(+d: KDef, +ns: String, +aliases: List<&2,KTerm>) -> KDef:
  +alias = f_alias(dn(d), aliases)
  KDef{f_choose(String, f_eq(alias, dn(d)), u => f_qual_name(dn(d), ns), u => alias), dk(d), da(d), dx(d), dt(d), atom("Absent"), f_context_headers(dc(d), ns, aliases), db(d), du(d)}

# Module: src/front/contextual.bend:250
@unsafe
def f_context_headers(+defs: List<&2,KDef>, +ns: String, +aliases: List<&2,KTerm>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{f_context_header(d, ns, aliases), f_context_headers(rest, ns, aliases)}

# Module: src/front/contextual.bend:256
@unsafe
def f_context_declare(+d: KDef, +scope: FParseScope) -> FParseScope:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      p144p_declared(f_context_header(d, ns, aliases), prior, index, ctorIndex, ns, aliases, p144p_view)

# Module: src/front/contextual.bend:262

@unsafe
def f_context_declared(+d: KDef, +prior: List<&2,KDef>, +index: KDef, +ctorIndex: KDef, +ns: String, +aliases: List<&2,KTerm>) -> FParseScope:
  FParseScope{Con{d, prior}, index_set(index, d, index_hash(dn(d), 2166136261), 32), f_ctor_index_def(d, ctorIndex), ns, aliases, None{}}

# Module: src/front/contextual.bend:266

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
def f_context_definition_done(+p: FParsed) -> FParsed:
  match p:
    case FParsed{term, rest}:
      match rest:
        case FInput{tokens, context}:
          +checked = f_context_materialize(term)
          FParsed{checked, rest}

# Header entry resets the declaration-local fresh counter, as parse_book does.

# Module: src/front/contextual.bend:304
@unsafe
def f_context_enter(+input: FInput, +scope: FParseScope) -> FInput:
  match input:
    case FInput{tokens, context}:
      match scope:
        case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}: FInput{tokens, FParseContext{scope, Nil{}, 0}}

# Module: src/front/contextual.bend:311

@unsafe
def f_context_tele(+binder: KTerm, +temp: Bool, +ty: KTerm, +end: String, +acc: List<&2,KTerm>, +opened: FParsed) -> FParsed:
  match opened:
    case FParsed{bound, input}:
      f_tele(f_choose(FInput, f_eq(f_tx(input), ","), u => f_tl(input), u => input), end, Con{kt_span(f_choose(String, temp, u => "Template", u => "Bind"), nm(bound), ix(bound), qt(binder), [ty], kb(binder), ke(binder)), acc})

# Module: src/front/contextual.bend:317
@unsafe
def f_context_outer(+input: FInput) -> List<&2,KTerm>:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: env

# Module: src/front/contextual.bend:324
@unsafe
def f_context_syntax(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_eq(tg(term), "FName"), u => k_with_span(kid(term, 0), kb(term), ke(term)), u => term)

# Module: src/front/contextual.bend:328
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
def f_context_templates(+head: KTerm, +input: FInput, +count: U32, +left: U32, +acc: List<&2,KTerm>) -> FParsed:
  f_choose(FParsed, U32.is_gt(count, 0) && f_eq(f_tx(input), "~"),
    u => f_choose(FParsed, U32.is_eq(left, 0),
      u => fpe_error(input, "too many template arguments", "a term (" ++ name_key(nm(head)) ++ " takes " ++ U32.show(count) ++ " ~)"),
      u => f_context_template_next(head, count, U32.sub(left, 1), acc, f_expr(f_tl(input), 0))),
    u => f_args(input, ")", acc))

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
  f_choose(FParsed, f_eq(tg(f_context_syntax(term)), "Var"), u => f_context_pattern(term, input, cursor),
    u => f_context_error_at(fpe_message_at(term, "a name (a parallel or typed let binds names; destructure in its body)", "a name (a parallel or typed let binds names; destructure in its body)"), input, cursor))

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
def f_context_result(+result: FResult) -> FResult:
  match result:
    case FResult{book, error, imports}: FResult{f_context_defs(book, String.is_empty(error)), error, imports}

# Module: src/front/contextual.bend:468
@unsafe
def f_context_defs(+defs: List<&2,KDef>, +complete: Bool) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{KDef{dn(d), dk(d), da(d), dx(d), f_choose(KTerm, f_eq(tg(dt(d)), "ImportLaw"), u => dt(d), u => f_choose(KTerm, complete, u => f_context_lower(dt(d)), u => dt(d))), dv(d), f_context_defs(dc(d), complete), db(d), du(d)}, f_context_defs(rest, complete)}

# Module: src/front/contextual.bend:474
@unsafe
def f_context_module(+d: KDef, +ns: String) -> KDef:
  KDef{f_choose(String, f_eq(dk(d), "ImportFill"), u => dn(d), u => f_qual_name(dn(d), ns)), f_choose(String, f_eq(dk(d), "ImportFill"), u => "Def", u => dk(d)), da(d), dx(d), dt(d), dv(d), f_context_modules(dc(d), ns), db(d), du(d)}

# Module: src/front/contextual.bend:478
@unsafe
def f_context_modules(+defs: List<&2,KDef>, +ns: String) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{f_context_module(d, ns), f_context_modules(rest, ns)}

# Module: src/front/contextual.bend:484
@unsafe
def f_context_scope(+input: FInput, +scope: FParseScope) -> FInput:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{old, env, next}: FInput{tokens, FParseContext{scope, env, next}}

# Module: src/front/contextual.bend:498
@unsafe
def f_context_type_name(+name: String, +input: FInput) -> String:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: nm(f_context_resolve(ref(name), scope))

# Module: src/front/contextual.bend:505
@unsafe
def f_context_mark(+parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, input}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_mark_input(term, input))

# Module: src/front/contextual.bend:510
@unsafe
def f_context_mark_input(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              +syntax = f_context_syntax(term)
              +resolved = f_choose(KTerm, f_eq(tg(term), "ADT"), u => term, u => f_context_resolve(syntax, scope))
              f_context_mark_known(term, syntax, resolved, p144p_find(nm(resolved), prior, p144p_view), input)

# Module: src/front/contextual.bend:522

@unsafe
def f_context_mark_known(+term: KTerm, +syntax: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  f_choose(FParsed, f_context_stop(resolved), u => FParsed{resolved, input},
    u => f_choose(FParsed, f_eq(tg(syntax), "Var") && Bool.not(f_eq(dk(definition), "ADT")),
      u => FParsed{kt_span("FName", nm(syntax), 0, 2, [kt_span("Var", nm(syntax), 4294967295, 2, Nil{}, kb(term), ke(term)), kt_span("FUnboundVar", nm(syntax), 0, 0, Nil{}, kb(term), ke(term))], kb(term), ke(term)), input},
      u => f_choose(FParsed, f_eq(dk(definition), "ADT") && U32.is_gt(f_leading_quants(dt(definition)), 0) && (f_eq(tg(term), "ADT") || U32.is_eq(f_leading_quants(dt(definition)), da(definition))),
        u => FParsed{f_adt(kt_span(f_choose(String, f_eq(tg(term), "ADT"), u => "ADT", u => "Ref"), nm(resolved), 0, 2, ks(term), kb(term), ke(term)), f_choose(List<&2,KTerm>, f_eq(tg(term), "ADT"), u => ks(term), u => Nil{}), definition), input},
        u => fpe_error(f_space(input), "+ requires a binder or quantified datatype", "a quantified datatype after + (+D<..> sets D's leading quantities to &2)"))))

# Module: src/front/contextual.bend:531
@unsafe
def f_context_statement_more(+term: KTerm, +input: FInput, +column: U32, +begin: U32) -> FParsed:
  f_choose(FParsed, f_binding_head(input), u => f_statement_more(FParsed{term, input}),
    u => f_context_write_more(term, input, column, f_context_write(term, begin, input)))

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
def f_context_signature(+term: KTerm, +input: FInput) -> KTerm:
  f_context_higher(term)

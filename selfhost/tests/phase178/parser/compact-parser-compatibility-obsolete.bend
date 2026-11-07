

@unsafe
def p140p_result(book: List<&2,KDef>, error: KTerm, imports: List<&2,KTerm>) -> P140PStop:
  P140PDone{f_result(book,error,imports)}

law p140p_tops:
  for +p140p_stop: U32
  for +ts0: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_tops(p140p_stop, ts0, book, imports, unsafe, scope):
  p140p_top(p140p_stop, f_skip(ts0), book, imports, unsafe, scope)


law p140p_top:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_top(p140p_stop, ts, book, imports, unsafe, scope):
  f_choose(P140PStop, U32.is_gt(p140p_stop,0) && U32.is_ge(f_begin(ts),p140p_stop) && (f_eq(f_tx(ts),"def") || f_eq(f_tx(ts),"law") || f_eq(f_tx(ts),"type")),
    u => P140PCut{ts,book,imports,unsafe,scope},
    u => f_choose(P140PStop, unsafe,
    u => f_choose(P140PStop, f_eq(f_tx(ts), "def"), u => p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope), u => p140p_result(book, f_pn(fpe_error(ts, "expected def after @unsafe", "'def' (@unsafe marks the def below it)")), imports)),
    u => p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope)))


law p140p_top_ready:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope):
  f_choose(P140PStop, f_eq(f_tx(ts), "<eof>"), u => p140p_result(book, atom("Absent"), imports),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "@") && f_eq(f_tx(f_tl(ts)), "unsafe"), u => p140p_tops(p140p_stop, f_tl(f_tl(ts)), book, imports, True{}, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "import"), u => p140p_import_leading(p140p_stop, ts, book, imports, unsafe),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "law"), u => p140p_named_top(p140p_stop, f_space(f_tl(ts)), book, imports, False{}, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "def"), u => p140p_def_header(p140p_stop, f_space(f_tl(ts)), book, imports, unsafe, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "type"), u => p140p_named_top(p140p_stop, f_space(f_tl(ts)), book, imports, True{}, scope),
    u => p140p_result(book, f_pn(f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_err(ts, "expected def, law, type or import"), u => fpe_error(ts, "expected def, law, type or import", "'def', 'type' or 'law'"))), imports)))))))


law p140p_def_type:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_def_type(p140p_stop, name, pars, p, book, imports, unsafe, scope):
  p177dr_type(p140p_stop, name, pars, p, book, imports, unsafe, scope, None{})


law p140p_def_body:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_def_body(p140p_stop, name, pars, ty, p, book, imports, unsafe, scope):
  p177dr_body(p140p_stop, name, pars, ty, p, book, imports, unsafe, scope, None{})


law p140p_foreign:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +paths: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_foreign(p140p_stop, name, pars, ty, ts, book, imports, unsafe, paths, scope):
  f_choose(P140PStop, f_eq(f_tx(ts), "import"), u => f_choose(P140PStop, f_foreign_path_valid(ts), u => p140p_foreign(p140p_stop, name, pars, ty, f_skip(f_tl(f_tl(ts))), book, imports, unsafe, Con{kt("Path", f_unquote(f_tx(f_tl(ts))), 0, 0, Nil{}), paths}, scope), u => p140p_result(book, fpe_foreign(f_space(f_tl(ts))), imports)), u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", terms_len(pars), 0, ty, kt("Foreign", name, 0, 0, List.reverse(&2, KTerm, paths)), Nil{}, False{}, unsafe}, book, imports, scope, True{}))


law p140p_law:
  for +p140p_stop: U32
  for +name: String
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_law(p140p_stop, name, ts, book, imports, clauses, scope):
  f_choose(P140PStop, f_valid_name(name) && f_eq(dk(f_decl_local(name, book, scope)), "Missing"), u => p140p_law_base(p140p_stop, name, ts, book, imports, clauses, scope), u => p140p_result(book, kt("Error", "invalid or reserved law name: " ++ name, 0, 0, Nil{}), imports))


law p140p_law_clause:
  for +p140p_stop: U32
  for +name: String
  for +exi: Bool
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_law_clause(p140p_stop, name, exi, ts, book, imports, clauses, scope):
  f_choose(P140PStop, Bool.not(exi) && f_eq(f_tx(ts), "~") && U32.is_lt(f_templates(clauses), terms_len(clauses)),
    u => p140p_result(book, f_pn(fpe_error(ts, "expected a plain clause (only leading clauses take ~)", "a plain clause (only leading clauses take ~)")), imports),
    u => p140p_law_type(p140p_stop, name, kt_span(f_choose(String, exi, u => "Exists", u => f_choose(String, f_eq(f_tx(ts), "~"), u => "Template", u => "Bind")), f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), Nil{}, f_begin(f_unmark(ts)), f_end(f_unmark(ts))), f_expr(f_tl(f_tl(f_unmark(ts))), 0), book, imports, clauses, scope))


law p140p_law_type:
  for +p140p_stop: U32
  for +name: String
  for +binder: KTerm
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_law_type(p140p_stop, name, binder, p, book, imports, clauses, scope):
  match p:
    case FParsed{ty, ts}:
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports), u => p140p_context_law_open(p140p_stop, name, binder, ty, f_context_open(binder, ts), book, imports, clauses, scope))


law p140p_law_end:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_law_end(p140p_stop, name, p, book, imports, clauses, scope):
  match p:
    case FParsed{ty, ts}:
      +signature = f_context_signature(f_law_bind(clauses, ty), ts)
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
          u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", f_law_arity(clauses), f_templates(clauses), signature, atom("Absent"), Nil{}, False{}, False{}}, book, imports, scope, True{})))


law p140p_type:
  for +p140p_stop: U32
  for +name: String
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_type(p140p_stop, name, ts, book, imports, scope):
  f_choose(P140PStop, f_valid_name(name) && f_eq(dk(f_decl_local(name, book, scope)), "Missing"), u => p140p_type_named(p140p_stop, name, ts, book, imports, scope), u => p140p_result(book, kt("Error", "invalid or reserved datatype name: " ++ name, 0, 0, Nil{}), imports))


law p140p_type_params:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_type_params(p140p_stop, name, p, book, imports, scope):
  match p:
    case FParsed{pars, ts}:
      f_choose(P140PStop, f_eq(tg(pars), "Error"), u => p140p_result(book, pars, imports), u => p140p_type_kind(p140p_stop, name, ks(pars), f_expect(f_expr_after(f_expect(FParsed{pars, ts}, "is"), 0), ":"), book, imports, scope))


law p140p_type_kind:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_type_kind(p140p_stop, name, pars, p, book, imports, scope):
  match p:
    case FParsed{ty, ts}:
      f_choose(P140PStop, f_eq(tg(ty), "Error"), u => p140p_result(book, ty, imports), u => p140p_context_type_start(p140p_stop, name, pars, ty, ts, book, imports, scope))


law p140p_type_ctors:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +ctors: List<&2, KDef>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_type_ctors(p140p_stop, name, pars, ty, ts, book, imports, ctors, scope):
  f_choose(P140PStop, (f_ascii_alpha(f_head(f_tx(ts))) || Char.is_eq(f_head(f_tx(ts)), '_')) && Bool.not(f_eq(f_tx(ts), "def") || f_eq(f_tx(ts), "type") || f_eq(f_tx(ts), "law")),
    u => p140p_type_ctor_header(p140p_stop, name, pars, ty, ts, book, imports, ctors, scope),
    u => p140p_context_publish(p140p_stop, ts, KDef{name, "ADT", terms_len(pars), 0, ty, atom("Absent"), List.reverse(&2, KDef, ctors), False{}, False{}}, book, imports, scope, False{}))


law p140p_type_ctor:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ctor: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +ctors: List<&2, KDef>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_type_ctor(p140p_stop, name, pars, ty, ctor, p, book, imports, ctors, scope):
  match p:
    case FParsed{fields, ts}:
      +signature = f_context_signature(f_tbind(pars, f_tbind(ks(fields), kt("ADT", f_context_type_name(name, ts), 0, 1, f_vars(pars)))), ts)
      f_choose(P140PStop, f_context_stop(fields), u => p140p_result(book, fields, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
          u => p140p_type_ctors(p140p_stop, name, pars, ty, f_context_close(f_space(ts), f_context_parameters(pars, Nil{})), book, imports, Con{KDef{ctor, "Ctr", terms_len(ks(fields)), 0, signature, kt("Absent", ctor, 0, 0, Nil{}), Nil{}, False{}, False{}}, ctors}, scope)))


law p140p_import_leading:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  P140PStop

@unsafe
def p140p_import_leading(p140p_stop, ts, book, imports, unsafe):
  match book:
    case Nil{}:
      f_choose(P140PStop, unsafe, u => p140p_result(book, f_pn(fpe_error(ts, "expected def after @unsafe", "'def' (@unsafe marks the def below it)")), imports), u => p140p_import(p140p_stop, ts, book, imports))
    case Con{d, rest}:
      p140p_result(book, f_pn(fpe_error(ts, "expected def, law or type; imports must precede declarations", "'def', 'type' or 'law'")), imports)


law p140p_law_where:
  for +p140p_stop: U32
  for +name: String
  for +binder: KTerm
  for +ty: KTerm
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_law_where(p140p_stop, name, binder, ty, p, book, imports, clauses, scope):
  match p:
    case FParsed{predicate, ts}:
      f_choose(P140PStop, f_context_stop(predicate), u => p140p_result(book, predicate, imports),
        u => p140p_law(p140p_stop, name, f_skip(ts), book, imports, Con{k_with_children(binder, [f_app_span(k_with_span(ref("Exists"), kb(binder), ke(binder)), [ty, k_lam(nm(binder), ix(binder), 1, [predicate], kb(binder), ke(binder), False{})], kb(binder), ke(binder))]), clauses}, scope))


law p140p_def_prior:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +old: KDef
  for +nameTokens: FInput
  for +scope: FParseScope
  P140PStop

@unsafe
def p140p_def_prior(p140p_stop, name, p, book, imports, unsafe, old, nameTokens, scope):
  p177dr_prior(p140p_stop, name, p, book, imports, unsafe, old, nameTokens, scope, None{})


law p140p_import_path:
  for +p140p_stop: U32
  for +ts: FInput
  for +start: FInput
  for +path: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +header: FInput
  P140PStop

@unsafe
def p140p_import_path(p140p_stop, ts, start, path, book, imports, header):
  f_choose(P140PStop, f_eq(f_tx(ts), "as"),
    u => p140p_import_alias(p140p_stop, ts, start, path, book, imports, header),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "\n") || f_eq(f_tx(ts), "<eof>"),
      u => f_choose(P140PStop, f_eq(path, "Base"), u => p140p_tops(p140p_stop, ts, book, Con{kt("Import", path, f_line(start), f_col(start), Nil{}), imports}, False{}, f_parse_scope_empty()),
        u => p140p_result(book, f_import_header_error(f_choose(FInput, String.is_empty(path), u => header, u => start)), imports)),
      u => f_choose(P140PStop, String.is_empty(path) || U32.is_eq(f_col(ts), U32.add(f_col(start), U32.from_nat(String.length(path)))),
        u => p140p_import_path(p140p_stop, f_tl(ts), start, path ++ f_import_token_text(ts), book, imports, header),
        u => p140p_result(book, f_import_header_error(header), imports))))

@unsafe
def p140p_context_publish(+p140p_stop: U32, +ts: FInput, +d: KDef, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: FParseScope, +space: Bool) -> P140PStop:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      p140p_top(p140p_stop, f_choose(FInput, space, u => f_space(ts), u => ts), Con{d, book}, imports, False{}, f_context_declare(d, scope))

@unsafe
def p140p_context_law_open(+p140p_stop: U32, +name: String, +binder: KTerm, +ty: KTerm, +opened: FParsed, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +clauses: List<&2,KTerm>, +scope: FParseScope) -> P140PStop:
  match opened:
    case FParsed{bound, ts}:
      +clause = kt_span(tg(binder), nm(binder), ix(bound), qt(binder), Nil{}, kb(binder), ke(binder))
      f_choose(P140PStop, f_eq(f_tx(f_skip(ts)), "where"), u => p140p_law_where(p140p_stop, name, clause, ty, f_expr(f_tl(f_skip(ts)), 0), book, imports, clauses, scope), u => p140p_law(p140p_stop, name, f_skip(ts), book, imports, Con{k_with_children(clause, [ty]), clauses}, scope))


@unsafe
def p140p_context_type_start(+p140p_stop: U32, +name: String, +pars: List<&2,KTerm>, +ty: KTerm, +input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: FParseScope) -> P140PStop:
  +signature = f_context_signature(f_tbind(pars, ty), input)
  +declared = f_context_declare(KDef{name, "ADT", terms_len(pars), 0, signature, atom("Absent"), Nil{}, False{}, False{}}, scope)
  f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
    u => p140p_type_ctors(p140p_stop, name, pars, signature, f_context_scope(f_space(input), declared), book, imports, Nil{}, declared))
# Resolve one exact raw local declaration, then carry it through the unchanged
# definition parser. No index hit is treated as the raw local definition.

@unsafe
def p140p_def_header(+p140p_stop: U32, +ts: FInput,
  +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool,
  +scope: FParseScope) -> P140PStop:
  +suffix = f_eq(f_tx(f_tl(ts)), "?") && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts)))))
  +rest = f_space(f_choose(FInput, suffix, u => f_tl(f_tl(ts)), u => f_tl(ts)))
  f_choose(P140PStop, f_valid_name(f_tx(ts)),
    u => p177dr_resolve(p140p_stop, ts, rest, book, imports, unsafe || suffix, scope, f_decl_local(f_tx(ts), book, scope)),
    u => p140p_result(book, f_pn(fpe_name_error(ts)), imports))


@unsafe
def p140p_import(+p140p_stop: U32, 
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>,
) -> P140PStop:
  p140p_import_path(p140p_stop, f_tl(ts), f_tl(ts), "", book, imports, ts)


@unsafe
def p140p_def_base(+p140p_stop: U32, 
  +name: String,
  +p: FParsed,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>,
  +unsafe: Bool, +scope: FParseScope
) -> P140PStop:
  p177dr_base(p140p_stop, name, p, book, imports, unsafe, scope, None{}, missing())


@unsafe
def p140p_law_base(+p140p_stop: U32, 
  +name: String,
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>,
  +clauses: List<&2, KTerm>, +scope: FParseScope
) -> P140PStop:
  f_choose(P140PStop, f_eq(f_tx(ts), "for") || f_eq(f_tx(ts), "exs"), u => p140p_law_clause(p140p_stop, name, f_eq(f_tx(ts), "exs"), f_tl(ts), book, imports, clauses, scope), u => p140p_law_end(p140p_stop, name, f_expr(ts, 0), book, imports, List.reverse(&2, KTerm, clauses), scope))


@unsafe
def p140p_type_base(+p140p_stop: U32, 
  +name: String,
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>, +scope: FParseScope
) -> P140PStop:
  f_choose(P140PStop, f_eq(f_tx(ts), "<") || f_eq(f_tx(ts), "<-"), u => p140p_type_params(p140p_stop, name, f_tele(f_choose(FInput, f_eq(f_tx(ts), "<-"), u => f_prepend(FToken{"-", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts)), u => f_tl(ts)), ">", Nil{}), book, imports, scope), u => p140p_type_params(p140p_stop, name, FParsed{kt("Tele", "", 0, 0, Nil{}), ts}, book, imports, scope))


@unsafe
def p140p_type_ctor_header(+p140p_stop: U32, 
  +name: String, +pars: List<&2,KTerm>, +ty: KTerm, +ts: FInput,
  +book: List<&2,KDef>, +imports: List<&2,KTerm>, +ctors: List<&2,KDef>, +scope: FParseScope,
) -> P140PStop:
  f_choose(P140PStop, f_valid_name(f_tx(ts)),
    u => f_choose(P140PStop, f_eq(f_alias(f_tx(ts), imports), f_tx(ts)),
      u => f_choose(P140PStop, Bool.not(f_eq(dk(f_find(f_tx(ts), ctors)), "Missing")) || f_decl_ctor_taken(f_tx(ts), book, scope),
      u => p140p_result(book, f_pn(fpe_word(ts, "expected a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")", "a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")")), imports),
    u => f_choose(P140PStop, f_eq(f_tx(f_space(f_tl(ts))), "{"),
      u => p140p_type_ctor(p140p_stop, name, pars, ty, f_tx(ts), f_tele(f_tl(f_space(f_tl(ts))), "}", Nil{}), book, imports, ctors, scope),
      u => p140p_result(book, f_pn(fpe_error(f_space(f_tl(ts)), "expected {", "'{'")), imports))),
    u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a constructor", "a fresh constructor name (" ++ f_import_alias_head(f_tx(ts)) ++ " is an import's alias)")), imports)),
    u => p140p_result(book, f_pn(fpe_name_error(ts)), imports))


@unsafe
def p140p_type_named(+p140p_stop: U32, 
  +name: String,
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>, +scope: FParseScope
) -> P140PStop:
  f_choose(P140PStop, f_eq(f_tx(ts), "<>"), u => p140p_type_params(p140p_stop, name, FParsed{kt("Tele", "", 0, 0, Nil{}), f_tl(ts)}, book, imports, scope), u => p140p_type_base(p140p_stop, name, ts, book, imports, scope))


@unsafe
def p140p_def_header_prior(+p140p_stop: U32, +nameTokens: FInput, +rest: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +old: KDef, +scope: FParseScope) -> P140PStop:
  p177dr_header_prior(p140p_stop, nameTokens, rest, book, imports, unsafe, old, scope, None{})


@unsafe
def p140p_named_top(+p140p_stop: U32, +ts: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +datatype: Bool, +scope: FParseScope) -> P140PStop:
  f_choose(P140PStop, f_valid_name(f_tx(ts)), u => f_choose(P140PStop, f_eq(f_alias(f_tx(ts), imports), f_tx(ts)), u => f_choose(P140PStop, f_decl_taken(f_tx(ts), book, scope), u => p140p_result(book, f_pn(fpe_word(ts, "duplicate declaration", "a fresh name (duplicate declaration: " ++ f_tx(ts) ++ ")")), imports),
      u => f_choose(P140PStop, datatype, u => p140p_type(p140p_stop, f_tx(ts), f_context_enter(f_tl(ts), scope), book, imports, scope), u => p140p_law_header(p140p_stop, f_tx(ts), f_expect(FParsed{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, f_context_enter(f_space(f_tl(ts)), scope)}, ":"), book, imports, scope))),
    u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a new declaration", "a fresh name (" ++ f_import_alias_head(f_tx(ts)) ++ " is an import's alias)")), imports)),
    u => p140p_result(book, f_pn(fpe_name_error(ts)), imports))


@unsafe
def p140p_law_header(+p140p_stop: U32, +name: String, +p: FParsed, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: FParseScope) -> P140PStop:
  match p:
    case FParsed{n, ts}: f_choose(P140PStop, f_eq(tg(n), "Error"), u => p140p_result(book, n, imports), u => p140p_law(p140p_stop, name, f_skip(ts), book, imports, Nil{}, scope))


@unsafe
def p140p_def_context_header(+p140p_stop: U32, +ts: FInput, +rest: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +old: KDef, +scope: FParseScope) -> P140PStop:
  p177dr_context_header(p140p_stop, ts, rest, book, imports, unsafe, old, scope, None{})


@unsafe
def p140p_import_alias(+p140p_stop: U32, 
  +ts: FInput,
  +start: FInput,
  +path: String,
  +book: List<&2,KDef>,
  +imports: List<&2,KTerm>,
  +header: FInput,
) -> P140PStop:
  +alias = f_tx(f_tl(ts))
  +rest = f_tl(f_tl(ts))
  f_choose(P140PStop, f_alias_valid(alias) && (f_eq(f_tx(rest), "\n") || f_eq(f_tx(rest), "<eof>")) && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_gt(f_col(ts), U32.add(f_col(start), U32.from_nat(String.length(path)))),
    u => f_choose(P140PStop, String.ends_with(path, ".bend"),
      u => f_choose(P140PStop, f_import_used(alias, imports),
        u => p140p_result(book, fpe_line(start, "expected a fresh alias (" ++ alias ++ " names an earlier import)", "a fresh alias (" ++ alias ++ " names an earlier import)"), imports),
        u => f_choose(P140PStop, f_import_valid(path),
          u => p140p_tops(p140p_stop, rest, book, Con{kt("Import", path, f_line(start), f_col(start), [kt("Alias", alias, 0, 0, Nil{})]), imports}, False{}, f_parse_scope_empty()),
          u => p140p_result(book, f_import_raw(f_pn(fpe_span(start, start, "invalid import path", "an import path of plain names (letters, digits, _ and -; the hub's files import the hub's)", "'" ++ path ++ "'"))), imports))),
      u => p140p_result(book, f_import_raw(f_pn(fpe_span(start, start, "an import requires a .bend path and a valid alias", "an import of a .bend file", "'" ++ path ++ "'"))), imports)),
    u => p140p_result(book, f_import_header_error(header), imports))


@unsafe
def p140p_prefix(+old: String, +current: String, +left: U32) -> P140PMatch:
  nt_choose(P140PMatch,U32.is_eq(left,0),u => P140PMatch{current,True{}},u =>
    p140p_prefix_nonempty(old,current,left))


@unsafe
def p140p_prefix_nonempty(old: String, current: String, +left: U32) -> P140PMatch:
  match old current:
    case SCon{+a,ar} SCon{+b,br}:
      nt_choose(P140PMatch,Char.is_eq(a,b) && U32.is_ge(left,dg_units(a)),
        u => p140p_prefix(ar,br,U32.sub(left,dg_units(a))),u => P140PMatch{"",False{}})
    case _ _: P140PMatch{"",False{}}

# Preserve KDef variant, not merely its exported projection fields.

@unsafe
def p140p_variant(d: KDef) -> U32:
  match d:
    case KDef{n,k,a,x,t,v,c,b,u}: 0
    case KIndexLeaf{h,b}: 1
    case KIndexNode{h,m,l,r}: 2


@unsafe
def p140p_defs(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+b,br}:
      nt_choose(Bool,U32.is_eq(p140p_variant(a),p140p_variant(b)) && f_fresh_prefix_exact_head(a,b),
        u => p140p_defs(norm_defs_join(dc(a),ar),norm_defs_join(dc(b),br)),u => False{})
    case _ _: False{}


@unsafe
def p140p_scope_same(a: FParseScope, b: FParseScope) -> Bool:
  match a b:
    case FParseScope{ap,ai,ac,an,aa, +p144p_view0} FParseScope{bp,bi,bc,bn,ba, +p144p_view1}:
      String.eq(an,bn) && f_fresh_prefix_exact_terms(aa,ba) &&
      p140p_defs(ap,bp) && p140p_defs([ai,ac],[bi,bc]) && p144p_view_same(p144p_view0,p144p_view1)

@unsafe
def p140p_token_same(a: FToken, b: FToken) -> Bool:
  match a b:
    case FToken{at,al,ac,ak,ab,ae,ap} FToken{bt,bl,bc,bk,bb,be,bp}:
      String.eq(at,bt) && U32.is_eq(al,bl) && U32.is_eq(ac,bc) && U32.is_eq(ak,bk) &&
      U32.is_eq(ab,bb) && U32.is_eq(ae,be) && U32.is_eq(ap,bp)

# An emitted newline proves original lexer depth0. A synthetic parser token
# cannot manufacture a checkpoint: the complete current token must occur in
# the original lexical stream, immediately following such a newline.

@unsafe
def p140p_prior(tokens: List<&2,FToken>, +wanted: FToken, previous: Maybe<&2,FToken>) -> Maybe<&2,FToken>:
  match tokens:
    case Nil{}: None{}
    case Con{+token,rest}:
      nt_choose(Maybe<&2,FToken>,p140p_token_same(token,wanted),
        u => p140p_prior_valid(previous),u => p140p_prior(rest,wanted,Some{token}))


@unsafe
def p140p_prior_valid(previous: Maybe<&2,FToken>) -> Maybe<&2,FToken>:
  match previous:
    case None{}: None{}
    case Some{+token}:
      nt_choose(Maybe<&2,FToken>,String.eq(f_raw_tx([token]),"\n"),u => Some{token},u => None{})


@unsafe
def p140p_checkpoint(+source: String, +initial: FParseScope, +start: U32, +tokens: List<&2,FToken>, +input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope) -> Maybe<&2,P140PCache>:
  match input:
    case FInput{remaining,context}:
      match remaining:
        case Nil{}: None{}
        case Con{+token,rest}:
          p140p_checkpoint_previous(source,initial,start,token,context,book,imports,unsafe,scope,
            p140p_prior(tokens,token,None{}))


@unsafe
def p140p_checkpoint_previous(+source: String, +initial: FParseScope, +start: U32, +token: FToken, +context: FParseContext, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope, previous: Maybe<&2,FToken>) -> Maybe<&2,P140PCache>:
  match previous:
    case None{}: None{}
    case Some{prior}:
      nt_choose(Maybe<&2,P140PCache>,U32.is_gt(start,0) && U32.is_gt(f_raw_begin([token]),start),
        u => Some{P140PCache{source,initial,start,token,prior,context,book,imports,unsafe,scope}},u => None{})


@unsafe
def p140p_seed_finished(+result: FResult, cache: Maybe<&2,P140PCache>) -> P140PParsed:
  match result:
    case FResult{book,+error,imports}:
      P140PParsed{result,nt_choose(Maybe<&2,P140PCache>,String.is_empty(error),u => cache,u => None{}),False{}}


@unsafe
def p140p_seed_stopped(+source: String, +initial: FParseScope, +start: U32, +tokens: List<&2,FToken>, stopped: P140PStop) -> P140PParsed:
  match stopped:
    case P140PDone{raw}: P140PParsed{f_context_result(fpe_finish_indexed(start,source,raw)),None{},False{}}
    case P140PCut{+input,+book,+imports,+unsafe,+scope}:
      p140p_seed_finished(f_context_result(fpe_finish_indexed(start,source,f_top(input,book,imports,unsafe,scope))),
        p140p_checkpoint(source,initial,start,tokens,input,book,imports,unsafe,scope))


@unsafe
def p140p_seed_tokens(+source: String, +scope: FParseScope, +start: U32, +hint: U32, +imports: List<&2,KTerm>, +tokens: List<&2,FToken>) -> P140PParsed:
  p140p_seed_stopped(source,scope,start,tokens,
    p140p_tops(hint,f_input(tokens),[],List.reverse(&2,KTerm,imports),False{},scope))


@unsafe
def p140p_seed(+source: String, +header: FHeader, +scope: FParseScope, +start: U32, +hint: U32) -> P140PParsed:
  match header:
    case FHeader{+imports,+error,+body,+line,+offset}:
      nt_choose(P140PParsed,String.is_empty(error),
        u => p140p_seed_tokens(source,scope,start,hint,imports,
          f_lex_cursor(body,line,0,0,[],f_cursor_add(start,offset),f_cursor_add(start,offset))),
        u => P140PParsed{f_body_header(source,header,scope,start),None{},False{}})

# Keep the previous lexical token solely as scanner lookbehind. Remove its
# copied output token before parsing; all new suffix token spans remain exact.

@unsafe
def p140p_relex(+tail: String, token: FToken, previous: FToken) -> List<&2,FToken>:
  match token:
    case FToken{text,line,column,kind,begin,end,previousEnd}:
      f_raw_tl(f_lex_cursor(tail,line,column,0,[previous],begin,previousEnd))


@unsafe
def p140p_resume_match(+source: String, +header: FHeader, +initial: FParseScope, +start: U32, +cache: P140PCache, matched: P140PMatch) -> P140PParsed:
  match matched:
    case P140PMatch{tail,same}:
      nt_choose(P140PParsed,same,u => p140p_resume_tail(source,header,cache,tail),
        u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})

# The first suffix token is lookahead of the completed preceding expression.
# A changed operator can retroactively extend that expression across a newline.
# Require the exact original declaration token before trusting the checkpoint.

@unsafe
def p140p_resume_tail(+source: String, +header: FHeader, +cache: P140PCache, tail: String) -> P140PParsed:
  match cache:
    case P140PCache{old,initial,start,+token,previous,context,book,imports,unsafe,scope}:
      p140p_resume_lexed(source,header,cache,p140p_relex(tail,token,previous))


@unsafe
def p140p_resume_lexed(+source: String, +header: FHeader, +cache: P140PCache, +tokens: List<&2,FToken>) -> P140PParsed:
  match cache:
    case P140PCache{old,+initial,+start,+token,previous,+context,+book,+imports,+unsafe,+scope}:
      nt_choose(P140PParsed,p140p_first_token(tokens,token),
        u => P140PParsed{f_context_result(fpe_finish_indexed(start,source,
          f_top(FInput{tokens,context},book,imports,unsafe,scope))),Some{cache},True{}},
        u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})


@unsafe
def p140p_first_token(tokens: List<&2,FToken>, expected: FToken) -> Bool:
  match tokens:
    case Nil{}: False{}
    case Con{token,rest}: p140p_token_same(token,expected)


@unsafe
def p140p_resume(+source: String, +header: FHeader, +initial: FParseScope, +start: U32, checkpoint: Maybe<&2,P140PCache>) -> P140PParsed:
  match checkpoint:
    case None{}: P140PParsed{f_body_header(source,header,initial,start),None{},False{}}
    case Some{+cache}:
      match cache:
        case P140PCache{+old,+prior,+origin,+token,previous,context,book,imports,unsafe,scope}:
          nt_choose(P140PParsed,U32.is_eq(start,origin) && p140p_scope_same(initial,prior),
            u => p140p_resume_match(source,header,initial,start,cache,
              p140p_prefix(old,source,U32.sub(f_raw_begin([token]),origin))),
            u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})


@unsafe
def p140p_parsed_result(parsed: P140PParsed) -> FResult:
  match parsed:
    case P140PParsed{result,cache,hit}: result


@unsafe
def p140p_parsed_cache(parsed: P140PParsed) -> Maybe<&2,P140PCache>:
  match parsed:
    case P140PParsed{result,cache,hit}: cache


@unsafe
def p140p_parsed_hit(parsed: P140PParsed) -> Bool:
  match parsed:
    case P140PParsed{result,cache,hit}: hit

@unsafe
def p140p_landmark(tokens: List<&2,FToken>, +edit: U32, +best: U32) -> U32:
  match tokens:
    case Nil{}: best
    case Con{token,rest}:
      match token:
        case FToken{+text,line,column,kind,+begin,end,previous}:
          nt_choose(U32,U32.is_gt(begin,edit),u => best,
            u => p140p_landmark(rest,edit,
              nt_choose(U32,U32.is_eq(column,0) && (String.eq(text,"def") || String.eq(text,"law") || String.eq(text,"type")),
                u => begin,u => best)))


@unsafe
def p140p_seed_before(+source: String, +header: FHeader, +scope: FParseScope, +start: U32, +edit: U32) -> P140PParsed:
  match header:
    case FHeader{+imports,+error,+body,+line,+offset}:
      nt_choose(P140PParsed,String.is_empty(error) && U32.is_gt(edit,0),
        u => p140p_before_tokens(source,scope,start,edit,imports,
          f_lex_cursor(body,line,0,0,[],f_cursor_add(start,offset),f_cursor_add(start,offset))),
        u => P140PParsed{f_body_header(source,header,scope,start),None{},False{}})


@unsafe
def p140p_before_tokens(+source: String, +scope: FParseScope, +start: U32, +edit: U32, +imports: List<&2,KTerm>, +tokens: List<&2,FToken>) -> P140PParsed:
  p140p_before_stopped(source,scope,start,edit,tokens,
    p140p_tops(p140p_landmark(tokens,edit,0),f_input(tokens),[],List.reverse(&2,KTerm,imports),False{},scope))


@unsafe
def p140p_before_stopped(+source: String, +initial: FParseScope, +start: U32, +edit: U32, +tokens: List<&2,FToken>, +stopped: P140PStop) -> P140PParsed:
  match stopped:
    case P140PDone{raw}: p140p_seed_stopped(source,initial,start,tokens,stopped)
    case P140PCut{+input,+book,+imports,+unsafe,+scope}:
      nt_choose(P140PParsed,U32.is_le(f_begin(input),edit),
        u => p140p_seed_stopped(source,initial,start,tokens,stopped),
        u => P140PParsed{f_context_result(fpe_finish_indexed(start,source,f_top(input,book,imports,unsafe,scope))),None{},False{}})
# A captured local declaration belongs to the unchanged outer book and scope.
# Direct continuation APIs pass None, retaining their original lookup points.
# In particular, a caller-supplied old declaration validates parameters but is
# not the result of the later local-or-prior lookup on that compatibility path.
@unsafe
def p140p_def_local(+local: Maybe<&2,KDef>, +name: String, +book: List<&2,KDef>, +scope: FParseScope) -> KDef:
  match local:
    case None{}: f_decl_local(name, book, scope)
    case Some{found}: found

@unsafe
def p140p_def_old(+local: Maybe<&2,KDef>, +old: KDef, +name: String, +book: List<&2,KDef>, +scope: FParseScope) -> KDef:
  match local:
    case None{}: f_decl_find(name, book, scope)
    case Some{found}: old

law p177dr_resolve:
  for +stop: U32
  for +ts: FInput
  for +rest: FInput
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  for +local: KDef
  P140PStop

law p177dr_context_header:
  for +p140p_stop: U32
  for +ts: FInput
  for +rest: FInput
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +old: KDef
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  P140PStop

law p177dr_header_prior:
  for +p140p_stop: U32
  for +nameTokens: FInput
  for +rest: FInput
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +old: KDef
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  P140PStop

law p177dr_prior:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +old: KDef
  for +nameTokens: FInput
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  P140PStop

law p177dr_base:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  for +old: KDef
  P140PStop

law p177dr_type:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2,KTerm>
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  P140PStop

law p177dr_body:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2,KTerm>
  for +ty: KTerm
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  for +local: Maybe<&2,KDef>
  P140PStop

law p177dr_taken:
  for +name: String
  for +scope: FParseScope
  for +local: KDef
  Bool

@unsafe
def p177dr_resolve(stop,ts,rest,book,imports,unsafe,scope,local):
  p177dr_context_header(stop,ts,rest,book,imports,unsafe,
    f_choose(KDef,f_eq(dk(local),"Missing"),
      u => f_decl_local_ctor(f_tx(ts),book,scope,f_decl_prior(f_tx(ts),scope)),
      u => local),scope,Some{local})

@unsafe
def p177dr_taken(name,scope,local):
  match scope:
    case FParseScope{prior,index,ctorIndex,ns,aliases,view}:
      Bool.not(f_eq(dk(local),"Missing")) ||
        Bool.not(f_eq(dk(index_find(index,name,index_hash(name,2166136261),32)),"Absent")) ||
        Bool.not(f_eq(dk(index_find(index,f_qual_name(name,ns),index_hash(f_qual_name(name,ns),2166136261),32)),"Absent"))

@unsafe
def p177dr_context_header(p140p_stop, ts, rest, book, imports, unsafe, old, scope, local):
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      +name = f_tx(ts)
      +alias = f_alias(name, aliases)
      f_choose(P140PStop, f_choose(Bool, f_eq(alias, name), u => False{}, u => f_declared(alias, prior) && f_declared(name, prior)),
        u => p140p_result(book, fpe_point_at(kt_span("Ref", name, 0, 1, Nil{}, f_end(ts), f_end(ts)), "ambiguous imported declaration", "an unambiguous name (the alias " ++ f_import_alias_head(name) ++ " shadows " ++ name ++ ")"), imports),
        u => f_choose(P140PStop, Bool.not(f_def_fillable(old)) && Bool.not(f_eq(alias, name)),
          u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a new declaration", "a fresh name (" ++ f_import_alias_head(name) ++ " is an import's alias)")), imports),
          u => f_choose(P140PStop, f_choose(Bool, f_def_fillable(old), u => False{}, u => p177dr_taken(name, scope, p140p_def_local(local, name, book, scope))),
            u => p140p_result(book, f_pn(fpe_word(ts, "duplicate declaration", "a fresh name (duplicate declaration: " ++ name ++ ")")), imports),
            u => p177dr_header_prior(p140p_stop, ts, rest, book, imports, unsafe, old, scope, local))))

@unsafe
def p177dr_header_prior(p140p_stop, nameTokens, rest, book, imports, unsafe, old, scope, local):
  f_choose(P140PStop, f_eq(dk(old), "Missing") || f_def_fillable(old),
    u => f_choose(P140PStop, f_eq(f_tx(rest), "("),
      u => f_choose(P140PStop, f_def_fillable(old) && f_eq(f_tx(f_skip(f_tl(rest))), "~"),
        u => p140p_result(book, f_pn(fpe_name_error(f_skip(f_tl(rest)))), imports),
        u => p177dr_prior(p140p_stop, f_tx(nameTokens), f_tele(f_context_enter(f_tl(rest), scope), ")", Nil{}), book, imports, unsafe, old, nameTokens, scope, local)),
      u => p140p_result(book, f_pn(fpe_error(rest, "expected (", "'('")), imports)),
    u => p140p_result(book, f_pn(fpe_word(nameTokens, "a definition must uniquely fill its law with plain parameter names", "a fresh name (duplicate declaration: " ++ f_tx(nameTokens) ++ ")")), imports))

@unsafe
def p177dr_prior(p140p_stop, name, p, book, imports, unsafe, old, nameTokens, scope, local):
  f_choose(P140PStop, f_eq(tg(f_pn(p)), "Error"), u => p140p_result(book, f_pn(p), imports),
    u => f_choose(P140PStop, f_eq(dk(old), "Missing"),
      u => f_choose(P140PStop, Bool.not(f_eq(f_alias(name, imports), name)) && f_eq(f_tx(f_pr(p)), "->"),
        u => p140p_result(book, f_pn(fpe_word(nameTokens, "an import alias can only name a law fill without a return annotation", "a fresh name (" ++ f_import_alias_head(name) ++ " is an import's alias)")), imports),
        u => p177dr_base(p140p_stop, name, p, book, imports, unsafe, scope, local, old)),
      u => f_choose(P140PStop, Bool.not(f_bare_params(ks(f_pn(p)))),
        u => p140p_result(book, f_pn(fpe_error(f_pr(p), "a law fill requires plain parameter names", "a name")), imports),
        u => f_choose(P140PStop, U32.is_lt(terms_len(ks(f_pn(p))), dx(old)),
          u => p140p_result(book, f_pn(fpe_error(f_pr(p), "a law fill requires its template parameters", "a name for each ~ clause of the law (" ++ U32.show(dx(old)) ++ ")")), imports),
          u => f_choose(P140PStop, f_eq(f_tx(f_pr(p)), ":"),
            u => p177dr_base(p140p_stop, name, p, book, imports, unsafe, scope, local, old),
            u => p140p_result(book, f_pn(fpe_error(f_pr(p), "expected : (a definition filling a law has no return annotation)", "':'")), imports))))))

@unsafe
def p177dr_base(p140p_stop, name, p, book, imports, unsafe, scope, local, old):
  match p:
    case FParsed{+pars, +ts}:
      f_choose(P140PStop, f_eq(tg(pars), "Error"), u => p140p_result(book, pars, imports), u => f_choose(P140PStop, f_eq(f_tx(ts), "->"), u => p177dr_type(p140p_stop, name, ks(pars), f_expr(f_tl(ts), 0), book, imports, unsafe, scope, local), u => p177dr_type(p140p_stop, name, ks(pars), FParsed{f_choose(KTerm, f_eq(dk(p140p_def_local(local, name, book, scope)), "Missing") && (Bool.not(f_eq(f_alias(name, imports), name)) || f_def_fillable(p140p_def_old(local, old, name, book, scope))), u => kt("ImportLaw", name, 0, 0, ks(pars)), u => dt(p140p_def_local(local, name, book, scope))), ts}, book, imports, unsafe, scope, local)))

@unsafe
def p177dr_type(p140p_stop, name, pars, p, book, imports, unsafe, scope, local):
  match p:
    case FParsed{ty, ts}:
      +signature = f_context_signature(f_choose(KTerm, f_eq(dk(p140p_def_local(local, name, book, scope)), "Missing") && Bool.not(f_eq(tg(ty), "ImportLaw")), u => f_tbind(pars, ty), u => ty), ts)
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
        u => f_choose(P140PStop, f_eq(tg(ty), "Absent"), u => p140p_result(book, f_pn(fpe_error(ts, "definition without return type needs a law: " ++ name, "'->' (a def with no return type fills a law; no law named " ++ name ++ " is in scope)")), imports),
        u => f_choose(P140PStop, f_eq(f_tx(f_skip(f_tl(ts))), "import"), u => p140p_foreign(p140p_stop, name, pars, signature, f_skip(f_tl(ts)), book, imports, unsafe, Nil{}, scope),
          u => p177dr_body(p140p_stop, name, pars, signature, f_context_definition(name, pars, signature, f_expect(FParsed{ty, ts}, ":"), scope), book, imports, unsafe, scope, local)))))

@unsafe
def p177dr_body(p140p_stop, name, pars, ty, p, book, imports, unsafe, scope, local):
  match p:
    case FParsed{body, ts}:
      f_choose(P140PStop, f_context_stop(body), u => p140p_result(book, body, imports), u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", terms_len(pars), f_choose(U32, f_eq(dk(p140p_def_local(local, name, book, scope)), "Missing"), u => f_templates(pars), u => dx(p140p_def_local(local, name, book, scope))), ty, body, Nil{}, False{}, unsafe}, book, imports, scope, True{}))

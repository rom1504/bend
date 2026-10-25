# Mechanical derivative of the34 actual FRawResult parser SCC entries.
# Only checkpoint transport, threaded stop cursor, and f_top stop branch differ.

law p140p_tops:
  for +p140p_stop: U32
  for +ts0: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

law p140p_top:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

law p140p_top_ready:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  P140PStop

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

law p140p_law:
  for +p140p_stop: U32
  for +name: String
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

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

law p140p_law_end:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

law p140p_type:
  for +p140p_stop: U32
  for +name: String
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

law p140p_type_params:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

law p140p_type_kind:
  for +p140p_stop: U32
  for +name: String
  for +pars: List<&2, KTerm>
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +scope: FParseScope
  P140PStop

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

law p140p_import_leading:
  for +p140p_stop: U32
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  P140PStop

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
def p140p_context_publish(+p140p_stop: U32, +ts: FInput, +d: KDef, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: FParseScope, +space: Bool) -> P140PStop:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases}:
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

@unsafe
def p140p_tops(p140p_stop, ts0, book, imports, unsafe, scope):
  p140p_top(p140p_stop, f_skip(ts0), book, imports, unsafe, scope)

@unsafe
def p140p_top(p140p_stop, ts, book, imports, unsafe, scope):
  f_choose(P140PStop, U32.is_gt(p140p_stop,0) && U32.is_ge(f_begin(ts),p140p_stop) && (f_eq(f_tx(ts),"def") || f_eq(f_tx(ts),"law") || f_eq(f_tx(ts),"type")),
    u => P140PCut{ts,book,imports,unsafe,scope},
    u => f_choose(P140PStop, unsafe,
    u => f_choose(P140PStop, f_eq(f_tx(ts), "def"), u => p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope), u => p140p_result(book, f_pn(fpe_error(ts, "expected def after @unsafe", "'def' (@unsafe marks the def below it)")), imports)),
    u => p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope)))

@unsafe
def p140p_top_ready(p140p_stop, ts, book, imports, unsafe, scope):
  f_choose(P140PStop, f_eq(f_tx(ts), "<eof>"), u => p140p_result(book, atom("Absent"), imports),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "@") && f_eq(f_tx(f_tl(ts)), "unsafe"), u => p140p_tops(p140p_stop, f_tl(f_tl(ts)), book, imports, True{}, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "import"), u => p140p_import_leading(p140p_stop, ts, book, imports, unsafe),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "law"), u => p140p_named_top(p140p_stop, f_space(f_tl(ts)), book, imports, False{}, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "def"), u => p140p_def_header(p140p_stop, f_space(f_tl(ts)), book, imports, unsafe, scope),
    u => f_choose(P140PStop, f_eq(f_tx(ts), "type"), u => p140p_named_top(p140p_stop, f_space(f_tl(ts)), book, imports, True{}, scope),
    u => p140p_result(book, f_pn(f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_err(ts, "expected def, law, type or import"), u => fpe_error(ts, "expected def, law, type or import", "'def', 'type' or 'law'"))), imports)))))))

@unsafe
def p140p_def_header(+p140p_stop: U32, 
  +ts: FInput,
  +book: List<&2,KDef>,
  +imports: List<&2,KTerm>,
  +unsafe: Bool, +scope: FParseScope
) -> P140PStop:
  +suffix = f_eq(f_tx(f_tl(ts)), "?") && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts)))))
  +rest = f_space(f_choose(FInput, suffix, u => f_tl(f_tl(ts)), u => f_tl(ts)))
  f_choose(P140PStop, Bool.not(f_valid_name(f_tx(ts))),
    u => p140p_result(book, f_pn(fpe_name_error(ts)), imports),
    u => p140p_def_context_header(p140p_stop, ts, rest, book, imports, unsafe || suffix, f_decl_find(f_tx(ts), book, scope), scope))

@unsafe
def p140p_import(+p140p_stop: U32, 
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>,
) -> P140PStop:
  p140p_import_path(p140p_stop, f_tl(ts), f_tl(ts), "", book, imports, ts)

@unsafe
def p140p_import_leading(p140p_stop, ts, book, imports, unsafe):
  match book:
    case Nil{}:
      f_choose(P140PStop, unsafe, u => p140p_result(book, f_pn(fpe_error(ts, "expected def after @unsafe", "'def' (@unsafe marks the def below it)")), imports), u => p140p_import(p140p_stop, ts, book, imports))
    case Con{d, rest}:
      p140p_result(book, f_pn(fpe_error(ts, "expected def, law or type; imports must precede declarations", "'def', 'type' or 'law'")), imports)

@unsafe
def p140p_def_base(+p140p_stop: U32, 
  +name: String,
  +p: FParsed,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>,
  +unsafe: Bool, +scope: FParseScope
) -> P140PStop:
  match p:
    case FParsed{+pars, +ts}:
      f_choose(P140PStop, f_eq(tg(pars), "Error"), u => p140p_result(book, pars, imports), u => f_choose(P140PStop, f_eq(f_tx(ts), "->"), u => p140p_def_type(p140p_stop, name, ks(pars), f_expr(f_tl(ts), 0), book, imports, unsafe, scope), u => p140p_def_type(p140p_stop, name, ks(pars), FParsed{f_choose(KTerm, f_eq(dk(f_decl_local(name, book, scope)), "Missing") && (Bool.not(f_eq(f_alias(name, imports), name)) || f_def_fillable(f_decl_find(name, book, scope))), u => kt("ImportLaw", name, 0, 0, ks(pars)), u => dt(f_decl_local(name, book, scope))), ts}, book, imports, unsafe, scope)))

@unsafe
def p140p_def_type(p140p_stop, name, pars, p, book, imports, unsafe, scope):
  match p:
    case FParsed{ty, ts}:
      +signature = f_context_signature(f_def_signature(name, pars, ty, book, scope), ts)
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
        u => f_choose(P140PStop, f_eq(tg(ty), "Absent"), u => p140p_result(book, f_pn(fpe_error(ts, "definition without return type needs a law: " ++ name, "'->' (a def with no return type fills a law; no law named " ++ name ++ " is in scope)")), imports),
        u => f_choose(P140PStop, f_eq(f_tx(f_skip(f_tl(ts))), "import"), u => p140p_foreign(p140p_stop, name, pars, signature, f_skip(f_tl(ts)), book, imports, unsafe, Nil{}, scope),
          u => p140p_def_body(p140p_stop, name, pars, signature, f_context_definition(name, pars, signature, f_expect(FParsed{ty, ts}, ":"), scope), book, imports, unsafe, scope)))))

@unsafe
def p140p_def_body(p140p_stop, name, pars, ty, p, book, imports, unsafe, scope):
  match p:
    case FParsed{body, ts}:
      f_choose(P140PStop, f_context_stop(body), u => p140p_result(book, body, imports), u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", terms_len(pars), f_choose(U32, f_eq(dk(f_decl_local(name, book, scope)), "Missing"), u => f_templates(pars), u => dx(f_decl_local(name, book, scope))), ty, body, Nil{}, False{}, unsafe}, book, imports, scope, True{}))

@unsafe
def p140p_foreign(p140p_stop, name, pars, ty, ts, book, imports, unsafe, paths, scope):
  f_choose(P140PStop, f_eq(f_tx(ts), "import"), u => f_choose(P140PStop, f_foreign_path_valid(ts), u => p140p_foreign(p140p_stop, name, pars, ty, f_skip(f_tl(f_tl(ts))), book, imports, unsafe, Con{kt("Path", f_unquote(f_tx(f_tl(ts))), 0, 0, Nil{}), paths}, scope), u => p140p_result(book, fpe_foreign(f_space(f_tl(ts))), imports)), u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", terms_len(pars), 0, ty, kt("Foreign", name, 0, 0, List.reverse(&2, KTerm, paths)), Nil{}, False{}, unsafe}, book, imports, scope, True{}))

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
def p140p_law_clause(p140p_stop, name, exi, ts, book, imports, clauses, scope):
  f_choose(P140PStop, Bool.not(exi) && f_eq(f_tx(ts), "~") && U32.is_lt(f_templates(clauses), terms_len(clauses)),
    u => p140p_result(book, f_pn(fpe_error(ts, "expected a plain clause (only leading clauses take ~)", "a plain clause (only leading clauses take ~)")), imports),
    u => p140p_law_type(p140p_stop, name, kt_span(f_choose(String, exi, u => "Exists", u => f_choose(String, f_eq(f_tx(ts), "~"), u => "Template", u => "Bind")), f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), Nil{}, f_begin(f_unmark(ts)), f_end(f_unmark(ts))), f_expr(f_tl(f_tl(f_unmark(ts))), 0), book, imports, clauses, scope))

@unsafe
def p140p_law_type(p140p_stop, name, binder, p, book, imports, clauses, scope):
  match p:
    case FParsed{ty, ts}:
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports), u => p140p_context_law_open(p140p_stop, name, binder, ty, f_context_open(binder, ts), book, imports, clauses, scope))

@unsafe
def p140p_law_end(p140p_stop, name, p, book, imports, clauses, scope):
  match p:
    case FParsed{ty, ts}:
      +signature = f_context_signature(f_law_bind(clauses, ty), ts)
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
          u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", f_law_arity(clauses), f_templates(clauses), signature, atom("Absent"), Nil{}, False{}, False{}}, book, imports, scope, True{})))

@unsafe
def p140p_type_base(+p140p_stop: U32, 
  +name: String,
  +ts: FInput,
  +book: List<&2, KDef>,
  +imports: List<&2, KTerm>, +scope: FParseScope
) -> P140PStop:
  f_choose(P140PStop, f_eq(f_tx(ts), "<") || f_eq(f_tx(ts), "<-"), u => p140p_type_params(p140p_stop, name, f_tele(f_choose(FInput, f_eq(f_tx(ts), "<-"), u => f_prepend(FToken{"-", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts)), u => f_tl(ts)), ">", Nil{}), book, imports, scope), u => p140p_type_params(p140p_stop, name, FParsed{kt("Tele", "", 0, 0, Nil{}), ts}, book, imports, scope))

@unsafe
def p140p_type_params(p140p_stop, name, p, book, imports, scope):
  match p:
    case FParsed{pars, ts}:
      f_choose(P140PStop, f_eq(tg(pars), "Error"), u => p140p_result(book, pars, imports), u => p140p_type_kind(p140p_stop, name, ks(pars), f_expect(f_expr_after(f_expect(FParsed{pars, ts}, "is"), 0), ":"), book, imports, scope))

@unsafe
def p140p_type_kind(p140p_stop, name, pars, p, book, imports, scope):
  match p:
    case FParsed{ty, ts}:
      f_choose(P140PStop, f_eq(tg(ty), "Error"), u => p140p_result(book, ty, imports), u => p140p_context_type_start(p140p_stop, name, pars, ty, ts, book, imports, scope))

@unsafe
def p140p_type_ctors(p140p_stop, name, pars, ty, ts, book, imports, ctors, scope):
  f_choose(P140PStop, (f_ascii_alpha(f_head(f_tx(ts))) || Char.is_eq(f_head(f_tx(ts)), '_')) && Bool.not(f_eq(f_tx(ts), "def") || f_eq(f_tx(ts), "type") || f_eq(f_tx(ts), "law")),
    u => p140p_type_ctor_header(p140p_stop, name, pars, ty, ts, book, imports, ctors, scope),
    u => p140p_context_publish(p140p_stop, ts, KDef{name, "ADT", terms_len(pars), 0, ty, atom("Absent"), List.reverse(&2, KDef, ctors), False{}, False{}}, book, imports, scope, False{}))

@unsafe
def p140p_type_ctor_header(+p140p_stop: U32, 
  +name: String, +pars: List<&2,KTerm>, +ty: KTerm, +ts: FInput,
  +book: List<&2,KDef>, +imports: List<&2,KTerm>, +ctors: List<&2,KDef>, +scope: FParseScope,
) -> P140PStop:
  f_choose(P140PStop, Bool.not(f_valid_name(f_tx(ts))),
    u => p140p_result(book, f_pn(fpe_name_error(ts)), imports),
    u => f_choose(P140PStop, Bool.not(f_eq(f_alias(f_tx(ts), imports), f_tx(ts))),
      u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a constructor", "a fresh constructor name (" ++ f_import_alias_head(f_tx(ts)) ++ " is an import's alias)")), imports),
    u => f_choose(P140PStop, Bool.not(f_eq(dk(f_find(f_tx(ts), ctors)), "Missing")) || f_decl_ctor_taken(f_tx(ts), book, scope),
      u => p140p_result(book, f_pn(fpe_word(ts, "expected a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")", "a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")")), imports),
    u => f_choose(P140PStop, f_eq(f_tx(f_space(f_tl(ts))), "{"),
      u => p140p_type_ctor(p140p_stop, name, pars, ty, f_tx(ts), f_tele(f_tl(f_space(f_tl(ts))), "}", Nil{}), book, imports, ctors, scope),
      u => p140p_result(book, f_pn(fpe_error(f_space(f_tl(ts)), "expected {", "'{'")), imports)))))

@unsafe
def p140p_type_ctor(p140p_stop, name, pars, ty, ctor, p, book, imports, ctors, scope):
  match p:
    case FParsed{fields, ts}:
      +signature = f_context_signature(f_tbind(pars, f_tbind(ks(fields), kt("ADT", f_context_type_name(name, ts), 0, 1, f_vars(pars)))), ts)
      f_choose(P140PStop, f_context_stop(fields), u => p140p_result(book, fields, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
          u => p140p_type_ctors(p140p_stop, name, pars, ty, f_context_close(f_space(ts), f_context_parameters(pars, Nil{})), book, imports, Con{KDef{ctor, "Ctr", terms_len(ks(fields)), 0, signature, kt("Absent", ctor, 0, 0, Nil{}), Nil{}, False{}, False{}}, ctors}, scope)))

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
  f_choose(P140PStop, f_eq(dk(old), "Missing") || f_def_fillable(old),
    u => f_choose(P140PStop, f_eq(f_tx(rest), "("),
      u => f_choose(P140PStop, f_def_fillable(old) && f_eq(f_tx(f_skip(f_tl(rest))), "~"),
        u => p140p_result(book, f_pn(fpe_name_error(f_skip(f_tl(rest)))), imports),
        u => p140p_def_prior(p140p_stop, f_tx(nameTokens), f_tele(f_context_enter(f_tl(rest), scope), ")", Nil{}), book, imports, unsafe, old, nameTokens, scope)),
      u => p140p_result(book, f_pn(fpe_error(rest, "expected (", "'('")), imports)),
    u => p140p_result(book, f_pn(fpe_word(nameTokens, "a definition must uniquely fill its law with plain parameter names", "a fresh name (duplicate declaration: " ++ f_tx(nameTokens) ++ ")")), imports))

@unsafe
def p140p_law(p140p_stop, name, ts, book, imports, clauses, scope):
  f_choose(P140PStop, f_valid_name(name) && f_eq(dk(f_decl_local(name, book, scope)), "Missing"), u => p140p_law_base(p140p_stop, name, ts, book, imports, clauses, scope), u => p140p_result(book, kt("Error", "invalid or reserved law name: " ++ name, 0, 0, Nil{}), imports))

@unsafe
def p140p_type(p140p_stop, name, ts, book, imports, scope):
  f_choose(P140PStop, f_valid_name(name) && f_eq(dk(f_decl_local(name, book, scope)), "Missing"), u => p140p_type_named(p140p_stop, name, ts, book, imports, scope), u => p140p_result(book, kt("Error", "invalid or reserved datatype name: " ++ name, 0, 0, Nil{}), imports))

@unsafe
def p140p_named_top(+p140p_stop: U32, +ts: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +datatype: Bool, +scope: FParseScope) -> P140PStop:
  f_choose(P140PStop, Bool.not(f_valid_name(f_tx(ts))), u => p140p_result(book, f_pn(fpe_name_error(ts)), imports),
    u => f_choose(P140PStop, Bool.not(f_eq(f_alias(f_tx(ts), imports), f_tx(ts))), u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a new declaration", "a fresh name (" ++ f_import_alias_head(f_tx(ts)) ++ " is an import's alias)")), imports),
    u => f_choose(P140PStop, f_decl_taken(f_tx(ts), book, scope), u => p140p_result(book, f_pn(fpe_word(ts, "duplicate declaration", "a fresh name (duplicate declaration: " ++ f_tx(ts) ++ ")")), imports),
      u => f_choose(P140PStop, datatype, u => p140p_type(p140p_stop, f_tx(ts), f_context_enter(f_tl(ts), scope), book, imports, scope), u => p140p_law_header(p140p_stop, f_tx(ts), f_expect(FParsed{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, f_context_enter(f_space(f_tl(ts)), scope)}, ":"), book, imports, scope)))))

@unsafe
def p140p_law_header(+p140p_stop: U32, +name: String, +p: FParsed, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: FParseScope) -> P140PStop:
  match p:
    case FParsed{n, ts}: f_choose(P140PStop, f_eq(tg(n), "Error"), u => p140p_result(book, n, imports), u => p140p_law(p140p_stop, name, f_skip(ts), book, imports, Nil{}, scope))

@unsafe
def p140p_def_context_header(+p140p_stop: U32, +ts: FInput, +rest: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +old: KDef, +scope: FParseScope) -> P140PStop:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases}:
      +name = f_tx(ts)
      +alias = f_alias(name, aliases)
      f_choose(P140PStop, f_choose(Bool, Bool.not(f_eq(alias, name)), u => f_declared(alias, prior) && f_declared(name, prior), u => False{}),
        u => p140p_result(book, fpe_point_at(kt_span("Ref", name, 0, 1, Nil{}, f_end(ts), f_end(ts)), "ambiguous imported declaration", "an unambiguous name (the alias " ++ f_import_alias_head(name) ++ " shadows " ++ name ++ ")"), imports),
        u => f_choose(P140PStop, Bool.not(f_def_fillable(old)) && Bool.not(f_eq(alias, name)),
          u => p140p_result(book, f_pn(fpe_word(ts, "an import alias cannot name a new declaration", "a fresh name (" ++ f_import_alias_head(name) ++ " is an import's alias)")), imports),
          u => f_choose(P140PStop, f_choose(Bool, Bool.not(f_def_fillable(old)), u => f_decl_taken(name, book, scope), u => False{}),
            u => p140p_result(book, f_pn(fpe_word(ts, "duplicate declaration", "a fresh name (duplicate declaration: " ++ name ++ ")")), imports),
            u => p140p_def_header_prior(p140p_stop, ts, rest, book, imports, unsafe, old, scope))))

@unsafe
def p140p_law_where(p140p_stop, name, binder, ty, p, book, imports, clauses, scope):
  match p:
    case FParsed{predicate, ts}:
      f_choose(P140PStop, f_context_stop(predicate), u => p140p_result(book, predicate, imports),
        u => p140p_law(p140p_stop, name, f_skip(ts), book, imports, Con{k_with_children(binder, [f_app_span(k_with_span(ref("Exists"), kb(binder), ke(binder)), [ty, k_lam(nm(binder), ix(binder), 1, [predicate], kb(binder), ke(binder), False{})], kb(binder), ke(binder))]), clauses}, scope))

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
def p140p_def_prior(p140p_stop, name, p, book, imports, unsafe, old, nameTokens, scope):
  f_choose(P140PStop, f_eq(tg(f_pn(p)), "Error"), u => p140p_result(book, f_pn(p), imports),
    u => f_choose(P140PStop, f_eq(dk(old), "Missing"),
      u => f_choose(P140PStop, Bool.not(f_eq(f_alias(name, imports), name)) && f_eq(f_tx(f_pr(p)), "->"),
        u => p140p_result(book, f_pn(fpe_word(nameTokens, "an import alias can only name a law fill without a return annotation", "a fresh name (" ++ f_import_alias_head(name) ++ " is an import's alias)")), imports),
        u => p140p_def_base(p140p_stop, name, p, book, imports, unsafe, scope)),
      u => f_choose(P140PStop, Bool.not(f_bare_params(ks(f_pn(p)))),
        u => p140p_result(book, f_pn(fpe_error(f_pr(p), "a law fill requires plain parameter names", "a name")), imports),
        u => f_choose(P140PStop, U32.is_lt(terms_len(ks(f_pn(p))), dx(old)),
          u => p140p_result(book, f_pn(fpe_error(f_pr(p), "a law fill requires its template parameters", "a name for each ~ clause of the law (" ++ U32.show(dx(old)) ++ ")")), imports),
          u => f_choose(P140PStop, f_eq(f_tx(f_pr(p)), ":"),
            u => p140p_def_base(p140p_stop, name, p, book, imports, unsafe, scope),
            u => p140p_result(book, f_pn(fpe_error(f_pr(p), "expected : (a definition filling a law has no return annotation)", "':'")), imports))))))

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

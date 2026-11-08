
# Module: src/front/declarations.bend:2
type FResult is Data:
  FResult{+book: List<&2, KDef>, +error: String, +imports: List<&2, KTerm>}

# Internal parser transport only; public FResult remains unchanged.

# Module: src/front/declarations.bend:6
type FRawResult is Data:
  FRawResult{+book: List<&2, KDef>, +error: KTerm, +imports: List<&2, KTerm>}

# Module: src/front/declarations.bend:673
type FParseScope is Data:
  FParseScope{+prior: List<&2,KDef>, +index: KDef, +ctors: KDef, +ns: String, +aliases: List<&2,KTerm>, +priorView: Maybe<&2,KDef>}

# Module: src/front/declarations.bend:9
law f_tops:
  for +ts0: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  FRawResult

# Module: src/front/declarations.bend:17
law f_top:
  for +ts: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  FRawResult

# Module: src/front/declarations.bend:25
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
law f_law_arity:
  for +clauses: List<&2, KTerm>
  U32

# Module: src/front/declarations.bend:653
law fpe_foreign:
  for +ts: FInput
  KTerm

# Module: src/front/declarations.bend:234
@unsafe
def f_result(
  +book: List<&2, KDef>,
  +err: KTerm,
  +imports: List<&2, KTerm>,
) -> FRawResult:
  FRawResult{List.reverse(&2, KDef, book), err, List.reverse(&2, KTerm, imports)}

# Module: src/front/declarations.bend:242
@unsafe
def f_find(
  +name: String,
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      KDef{name, "Missing", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}
    case Con{+d, ds}:
      f_find_next(name, d, ds, p137q_key_eq(name, d))

# Module: src/front/declarations.bend:253

@unsafe
def f_find_next(
  +name: String, +d: KDef, +ds: List<&2, KDef>, +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: f_find(name, ds)

# Module: src/front/declarations.bend:261
@unsafe
def f_tops(ts0, book, imports, unsafe, scope):
  p141p_raw(p140p_tops(0,ts0,book,imports,unsafe,scope))

@unsafe
def f_top(ts, book, imports, unsafe, scope):
  p141p_raw(p140p_top(0,ts,book,imports,unsafe,scope))

@unsafe
def f_tele(ts0, end, acc):
  f_tele_at(f_skip(ts0), end, acc)

# Module: src/front/declarations.bend:323
@unsafe
def f_tele_at(ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(ts), end), u => FParsed{kt("Tele", "", 0, 0, List.reverse(&2, KTerm, acc)), f_tl(ts)}, u => f_validate_param(ts, end, acc))

# Module: src/front/declarations.bend:327
@unsafe
def f_tele_binder(
  +binder: KTerm,
  +temp: Bool,
  +ts: FInput,
  +end: String,
  +acc: List<&2, KTerm>,
) -> FParsed:
  f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_tele_type(binder, temp, f_expr(f_tl(ts), 0), end, acc), u => f_choose(FParsed, U32.is_eq(qt(binder), 1) && Bool.not(temp), u => f_tele_type(kt_span(tg(binder), nm(binder), ix(binder), 0, Nil{}, kb(binder), ke(binder)), temp, FParsed{k_with_span(atom("Qnt"), kb(binder), ke(binder)), ts}, end, acc), u => fpe_error(ts, "expected : (a marked parameter requires its type)", "':'")))

# Module: src/front/declarations.bend:337
@unsafe
def f_tele_type(binder, temp, p, end, acc):
  match p:
    case FParsed{ty, ts}:
      f_choose(FParsed, f_context_stop(ty), u => p, u => f_context_tele(binder, temp, ty, end, acc, f_context_open(binder, ts)))

# Module: src/front/declarations.bend:343
@unsafe
def f_tbind(
  +pars: List<&2, KTerm>,
  +result: KTerm,
) -> KTerm:
  match pars:
    case Nil{}:
      result
    case Con{+p, ps}:
      kt_span("All", nm(p), ix(p), qt(p), [kid(p, 0), f_tbind(ps, result)], kb(p), ke(p))

# Module: src/front/declarations.bend:354
@unsafe
def f_lbind(
  +pars: List<&2, KTerm>,
  +body: KTerm,
) -> KTerm:
  match pars:
    case Nil{}:
      body
    case Con{+p, ps}:
      k_lam(nm(p), ix(p), qt(p), [f_lbind(ps, body)], kb(p), ke(p), True{})

# Module: src/front/declarations.bend:365
@unsafe
def f_templates(
  +pars: List<&2, KTerm>,
) -> U32:
  match pars:
    case Nil{}:
      0
    case Con{p, ps}:
      U32.add(f_choose(U32, f_eq(tg(p), "Template"), u => 1, u => 0), f_templates(ps))

# Module: src/front/declarations.bend:402
@unsafe
def f_law_bind(
  +clauses: List<&2, KTerm>,
  +ty: KTerm,
  +exists: String,
) -> KTerm:
  match clauses:
    case Nil{}:
      ty
    case Con{+c, cs}:
      f_choose(KTerm, f_eq(tg(c), "Exists"), u => f_app_span(kt_span("Ref", exists, 0, 1, Nil{}, kb(c), ke(c)), [kid(c, 0), k_lam(nm(c), ix(c), 1, [f_law_bind(cs, ty, exists)], kb(c), ke(c), False{})], kb(c), ke(c)), u => kt_span("All", nm(c), ix(c), qt(c), [kid(c, 0), f_law_bind(cs, ty, exists)], kb(c), ke(c)))

# Module: src/front/declarations.bend:445
@unsafe
def f_body(ts):
  f_body_context(ts, 0)

# Module: src/front/declarations.bend:509
@unsafe
def f_body_at(
  +ts: FInput,
) -> FParsed:
  f_choose(FParsed, f_eq(f_tx(ts), "-"), u => f_erased_local(f_tl(ts), f_begin(ts), f_col(ts)), u => f_choose(FParsed, f_eq(f_tx(ts), "match"), u => f_locate(f_match_heads(f_tl(ts), f_col(ts), Nil{}), f_begin(ts), False{}, True{}, False{}), u => f_statement(f_expr(ts, 0), f_begin(ts), f_col(ts))))

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
def f_let_ann(
  +ty: KTerm,
  +p: FParsed,
  +begin: U32,
) -> FParsed:
  match p:
    case FParsed{v, ts}:
      FParsed{f_choose(KTerm, f_context_stop(v), u => v, u => kt_span("Ann", "", 0, 1, [v, ty], begin, f_begin(f_space(ts)))), ts}

# Module: src/front/declarations.bend:536
@unsafe
def f_let_value(pat, p):
  match p:
    case FParsed{v, ts}:
      f_choose(FParsed, f_context_stop(v), u => FParsed{v, ts}, u => f_context_let(pat, v, ts))

# Module: src/front/declarations.bend:542
@unsafe
def f_match_heads(ts, indent, acc):
  f_choose(FParsed, List.is_empty(&2, KTerm, acc) && (f_eq(f_tx(ts), ":") || f_eq(f_tx(ts), ",")), u => fpe_error(ts, "expected term", "a term"), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_match_begin(f_skip(f_tl(ts)), indent, List.reverse(&2, KTerm, acc)), u => f_match_head(f_expr(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, acc)))

# Module: src/front/declarations.bend:546
@unsafe
def f_match_head(p, indent, acc):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_match_heads(ts, indent, Con{f_context_head(n), acc}))

# Module: src/front/declarations.bend:552
@unsafe
def f_match_cases(
  +ts: FInput,
  +indent: U32,
  +heads: List<&2, KTerm>,
  +rows: List<&2, KTerm>,
) -> FParsed:
  f_choose(FParsed, f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), indent), u => f_case_pats(f_tl(ts), indent, heads, rows, Nil{}, f_skip(f_tl(ts))), u => FParsed{kt("Match", "", 0, 1, Con{kt("Heads", "", 0, 1, heads), List.reverse(&2, KTerm, rows)}), ts})

# Module: src/front/declarations.bend:561
@unsafe
def f_case_pats(ts, indent, heads, rows, pats, start):
  f_choose(FParsed, List.is_empty(&2, KTerm, pats) && (f_eq(f_tx(ts), ":") || f_eq(f_tx(ts), ",")), u => fpe_error(ts, "expected term", "a term"), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_choose(FParsed, U32.is_eq(terms_len(pats), terms_len(heads)), u => f_context_case(ts, indent, heads, rows, List.reverse(&2, KTerm, pats)), u => fpe_span(start, ts, "one pattern is required per match scrutinee", U32.show(terms_len(heads)) ++ " patterns (one per scrutinee)", "")), u => f_case_pat(f_expr(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, heads, rows, pats, start)))

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
def f_def_fillable(+old: KDef) -> Bool:
  f_eq(dk(old), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(db(old))

# Module: src/front/declarations.bend:617
@unsafe
def f_body_context(ts, outer):
  f_body_context_at(f_skip(ts), outer)

# Module: src/front/declarations.bend:621
@unsafe
def f_body_context_at(ts, outer):
  f_body_context_existing(ts, outer)

# Module: src/front/declarations.bend:625
@unsafe
def f_body_context_existing(+ts: FInput, +outer: U32) -> FParsed:
  f_choose(FParsed, f_eq(f_tx(ts), "match"), u => f_locate(f_match_heads(f_tl(ts), outer, Nil{}), f_begin(ts), False{}, True{}, False{}), u => f_body_at(ts))

# Module: src/front/declarations.bend:629
@unsafe
def f_match_begin(ts, outer, heads):
  f_choose(FParsed, f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), outer), u => f_match_cases(ts, U32.sub(f_col(ts), 1), heads, Nil{}), u => FParsed{kt("Match", "", 0, 1, [kt("Heads", "", 0, 1, heads)]), ts})

# Module: src/front/declarations.bend:637
@unsafe
def f_law_arity(clauses):
  match clauses:
    case Nil{}:
      0
    case Con{c, rest}:
      f_choose(U32, f_eq(tg(c), "Exists"), u => 0, u => U32.add(1, f_law_arity(rest)))

# Module: src/front/declarations.bend:645
@unsafe
def fpe_foreign(ts):
  f_choose(KTerm, Char.is_eq(f_head(f_tx(ts)), '"'), u => kt("Error", "foreign import requires a quoted .c or .js path", 0, 0, Nil{}), u => f_pn(fpe_legacy(ts, "foreign import requires a quoted .c or .js path", "'\"'")))

# Module: src/front/declarations.bend:662
@unsafe
def f_parse_scope_empty() -> FParseScope:
  FParseScope{Nil{}, missing(), missing(), "", Nil{}, None{}}

# Module: src/front/declarations.bend:681

@unsafe
def f_decl_prior(+name: String, +scope: FParseScope) -> KDef:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      +alias = f_alias(name, aliases)
      +own = f_choose(String, f_eq(alias, name), u => f_qual_name(name, ns), u => alias)
      +near = index_find(index, own, index_hash(own, 2166136261), 32)
      +far = index_find(index, name, index_hash(name, 2166136261), 32)
      +found = f_choose(KDef, Bool.not(f_eq(dk(near), "Absent")) || f_eq(dk(far), "Absent"), u => near, u => far)
      f_choose(KDef, f_eq(dk(found), "Absent"), u => f_find(name, Nil{}), u => found)

# Module: src/front/declarations.bend:698
@unsafe
def f_decl_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      Bool.not(f_eq(dk(f_decl_local(name, book, scope)), "Missing")) || Bool.not(f_eq(dk(index_find(index, name, index_hash(name, 2166136261), 32)), "Absent")) || Bool.not(f_eq(dk(index_find(index, f_qual_name(name, ns), index_hash(f_qual_name(name, ns), 2166136261), 32)), "Absent"))

# Module: src/front/declarations.bend:704

@unsafe
def f_decl_ctor_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      Bool.not(f_eq(dk(f_ctor_lookup(name, book)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_qual_name(name, ns), ctorIndex)), "Missing"))

# Every local declaration also publishes its mapped header in scope.index.
# A miss proves local absence; hits retain the original first-event scan.

# Module: src/front/declarations.bend:736

@unsafe
def f_decl_local(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> KDef:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      +alias = f_alias(name, aliases)
      +key = f_choose(String, f_eq(alias, name), u => f_qual_name(name, ns), u => alias)
      f_find(name, f_choose(List<&2,KDef>, f_eq(dk(index_find(index, key, index_hash(key, 2166136261), 32)), "Absent"), u => Nil{}, u => book))

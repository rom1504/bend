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

law p177dr_context_header:
  for +p140p_stop: U32
  for +ts: FInput
  for +rest: FInput
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +old: KDef
  for +scope: FParseScope
  for +local: KDef
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
  for +local: KDef
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
  for +local: KDef
  P140PStop

law p177dr_base:
  for +p140p_stop: U32
  for +name: String
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2,KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  for +local: KDef
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
  for +local: KDef
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
  for +local: KDef
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
      u => local),scope,local)

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
          u => f_choose(P140PStop, f_choose(Bool, f_def_fillable(old), u => False{}, u => p177dr_taken(name, scope, local)),
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
      f_choose(P140PStop, f_eq(tg(pars), "Error"), u => p140p_result(book, pars, imports), u => f_choose(P140PStop, f_eq(f_tx(ts), "->"), u => p177dr_type(p140p_stop, name, ks(pars), f_expr(f_tl(ts), 0), book, imports, unsafe, scope, local), u => p177dr_type(p140p_stop, name, ks(pars), FParsed{f_choose(KTerm, f_eq(dk(local), "Missing") && (Bool.not(f_eq(f_alias(name, imports), name)) || f_def_fillable(old)), u => kt("ImportLaw", name, 0, 0, ks(pars)), u => dt(local)), ts}, book, imports, unsafe, scope, local)))

@unsafe
def p177dr_type(p140p_stop, name, pars, p, book, imports, unsafe, scope, local):
  match p:
    case FParsed{ty, ts}:
      +signature = f_context_signature(f_choose(KTerm, f_eq(dk(local), "Missing") && Bool.not(f_eq(tg(ty), "ImportLaw")), u => f_tbind(pars, ty), u => ty), ts)
      f_choose(P140PStop, f_context_stop(ty), u => p140p_result(book, ty, imports),
        u => f_choose(P140PStop, f_context_stop(signature), u => p140p_result(book, signature, imports),
        u => f_choose(P140PStop, f_eq(tg(ty), "Absent"), u => p140p_result(book, f_pn(fpe_error(ts, "definition without return type needs a law: " ++ name, "'->' (a def with no return type fills a law; no law named " ++ name ++ " is in scope)")), imports),
        u => f_choose(P140PStop, f_eq(f_tx(f_skip(f_tl(ts))), "import"), u => p140p_foreign(p140p_stop, name, pars, signature, f_skip(f_tl(ts)), book, imports, unsafe, Nil{}, scope),
          u => p177dr_body(p140p_stop, name, pars, signature, f_context_definition(name, pars, signature, f_expect(FParsed{ty, ts}, ":"), scope), book, imports, unsafe, scope, local)))))

@unsafe
def p177dr_body(p140p_stop, name, pars, ty, p, book, imports, unsafe, scope, local):
  match p:
    case FParsed{body, ts}:
      f_choose(P140PStop, f_context_stop(body), u => p140p_result(book, body, imports), u => p140p_context_publish(p140p_stop, ts, KDef{name, "Def", terms_len(pars), f_choose(U32, f_eq(dk(local), "Missing"), u => f_templates(pars), u => dx(local)), ty, body, Nil{}, False{}, unsafe}, book, imports, scope, True{}))

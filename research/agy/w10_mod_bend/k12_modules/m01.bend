# Module m01 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=930 laws=65 sccs=810 deps=[m00] cross_imports=436 fid_base=5120..10239

law core_subst_stable_app_tail:
  for +f: KTerm
  for +tail: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:459
law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

# Module: src/core/index.bend:9
law norm_exact_head:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:420
law kr_push:
  for +name: String
  for +names: List<&2, String>
  List<&2, String>

# Module: src/core/pretty.bend:10
law infer_var:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:25
law check_open_message:
  for +n: U32
  String

# Module: src/check/kernel.bend:313
law ka_spine_eligible:
  for +t: KTerm
  Bool

# Module: src/check/annotate.bend:268
law f_matcher_tail:
  for +name: String
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:229
law f_law_arity:
  for +clauses: List<&2, KTerm>
  U32

# Module: src/front/declarations.bend:653
law ff_let:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:22
law ff_lam:
  for +v: KTerm
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:50
law ff_fields:
  for +ps: List<&2, KTerm>
  for +q: U32
  for +next: U32
  FFields

# Module: src/front/flatten.bend:67
law ff_miss_done:
  for +c: KTerm
  for +hit: KTerm
  for +r: FFlatten
  for +origin: KTerm
  FFlatten

# Module: src/front/elaborate.bend:3
law f_env:
  for +name: String
  for +env: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:8
law f_namespace_head:
  for +t: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:138
law f_parallel_body:
  for +pats: List<&2, KTerm>
  for +vals: List<&2, KTerm>
  for +p: FParsed
  FParsed

# Module: src/front/parallel.bend:28
law f_unlamb:
  for +body: KTerm
  for +n: U32
  KTerm

# Module: src/front/parallel.bend:38
law f_name_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:152
law f_path_parent:
  for +parts: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:23
law f_path_join_parts:
  for +parts: List<&2,String>
  for +acc: String
  String

# Freshness is checked only after all existing graph/parser/elaborator errors.
# The index stores latest prior events; constructors have a separate namespace.

# Module: src/load/graph.bend:30
law fpe_term:
  for +t: KTerm
  KTerm

# Module: src/load/graph.bend:301
law fpe_terms:
  for +ts: List<&2,KTerm>
  KTerm

# Module: src/load/graph.bend:308
law fpe_terms_next:
  for +error: KTerm
  for +rest: List<&2,KTerm>
  KTerm

# Module: src/load/graph.bend:312
law fpe_unique_source:
  for +path: String
  for +sources: List<&2,FSource>
  for +found: KTerm
  KTerm

# Module: src/load/graph.bend:340
law f_seed_matches:
  for +source: FSource
  for +path: String
  for +text: String
  Bool

# Module: src/load/seed.bend:15
law fs_inject:
  for +g: FGraph
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:48
law f_source:
  for +name: String
  for +sources: List<&2, FSource>
  FSource

# Module: src/load/modules.bend:22
law dg_origin_found:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +rest: List<&2, KTerm>
  for +found: DSpan
  DSpan

# Module: src/diagnostic/produce.bend:16
law j_word:
  for +t: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:40
law j_word_bit:
  for +bit: KTerm
  for +rest: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/common/queries.bend:17
law j_call_spine:
  for +t: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:56
law j_arm_tel:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +ret: KTerm
  KTerm

# Module: src/back/common/queries.bend:162
law j_io_spine:
  for +t: KTerm
  for +args: U32
  Bool

# Module: src/back/common/queries.bend:197
law j_escape_char_on:
  for +c: Char
  for +key: U32
  String

# Module: src/back/js/shared-text.bend:47
law j_nat:
  for +t: KTerm
  for +acc: Nat
  Maybe<&2, Nat>

# Module: src/back/js/literals.bend:62
law j_l_name:
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:7
law nc_ctor_encode:
  for +name: String
  String

# Module: src/back/native/identity.bend:15
law nc_bangs_term:
  for +t: KTerm
  List<&2, String>

# Module: src/back/native/book.bend:351
law dr_lines:
  for names: List<&2,String>
  String

# Module: src/driver/api.bend:34
@unsafe
def typ(
  +q: U32,
) -> KTerm:
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

# Module: src/core/term.bend:167
@unsafe
def w7_br_0(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_force(kid(t, 0))
    case False{}:
      t

@unsafe
def w7_br_1(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_force(kid(t, 0))
    case False{}:
      w7_br_0(p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), t)

@unsafe
def core_force(
  +t: KTerm,
) -> KTerm:
  w7_br_1(p98_tag_eq(t, "Ann"), t)

# Module: src/core/term.bend:399
@unsafe
def core_subst_stable_app_tail(f, tail):
  match tail:
    case Nil{}: False{}
    case Con{x, rest}: core_subst_stable_app_last(f, x, rest)

# Module: src/core/term.bend:484
@unsafe
def w7_br_6(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_literal_string(kl_text(t), kb(t), ke(t))
    case False{}:
      kt_span("Ctr", nm(t), 0, 1, [core_literal_word(kl_number(t), 32, kb(t), ke(t))], kb(t), ke(t))

@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      match right:
        case True{}: index_first(rest)
        case False{}: h

# Module: src/core/index.bend:61
@unsafe
def w7_ctor_tree_list(+ds: List<&2, KDef>) -> KDef:
  match ds:
    case Nil{}:
      missing()
    case Con{idx, tail}:
      w7_ctor_tree_tail(tail)

@unsafe
def norm_apply(
  +t: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  match args:
    case Nil{}:
      t
    case Con{h, rest}:
      norm_apply(app(t, h), rest)

# Module: src/core/normalize.bend:17
@unsafe
def w7_br_28(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      a
    case False{}:
      w7_br_27(Bool.and(U32.is_eq(qt(b), 1), Bool.not(p98_tag_eq(a, "Qua"))), a, b)

@unsafe
def norm_max_term(
  +t: KTerm,
) -> U32:
  norm_max_walk(Con{t, Nil{}}, 0)

# Module: src/core/normalize.bend:240
@unsafe
def norm_subset(
  +as: List<&2, String>,
  +bs: List<&2, String>,
) -> Bool:
  match bs:
    case Nil{}:
      True{}
    case Con{h, t}:
      Bool.and(has_name(as, h), norm_subset(as, t))

# Module: src/core/normalize.bend:276
@unsafe
def norm_exact_head(a, b):
  p98_tag_eq(a, tg(b)) && kc(Bool, core_literal(a), u => core_literal_same(a, b), u => True{}) && p88_string_eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(b))) && norm_exact_names(rm(a), rm(b))

# Module: src/core/normalize.bend:444
law g_class_root:
  for +classes: GClasses
  for +id: U32
  U32

@unsafe
def g_class_root_entry(+classes: GClasses, +id: U32, +entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: id
    case Some{GClassEntry{parent,rank}}:
      kc(U32,U32.is_eq(parent,id),u => id,u => g_class_root(classes,parent))

@unsafe
def g_class_root(classes,id):
  g_class_root_entry(classes,id,g_class_get(classes,id))

@unsafe
def w7_br_66(w7_c: Bool, +classes: GClasses, +id: U32, +rank: U32) -> GClasses:
  match w7_c:
    case True{}:
      g_class_put(classes,id,GClassEntry{id,U32.add(rank,1)})
    case False{}:
      classes

@unsafe
def g_share(
  +st: GState,
  +t: KTerm,
) -> GResult:
  w7_br_72(p98_tag_eq(t, "GCell"), st, t)

# Module: src/core/graph.bend:291
@unsafe
def g_shared_domain(+t: KTerm, +r: GResult) -> GResult:
  match r:
    case GResult{state, term}:
      GResult{state, k_with_children(t, Con{term, Con{kid(t, 1), Nil{}}})}

# Module: src/core/reach.bend:70
@unsafe
def kr_push(name, names):
  kc(List<&2, String>, has_name(names, name), u => names, u => Con{name, names})

# Module: src/core/pretty.bend:137
@unsafe
def kp_is(
  +t: KTerm,
  +tag: String,
  +name: String,
) -> Bool:
  kp_eq(tg(t), tag) && kp_eq(nm(t), name)

# Module: src/core/pretty.bend:152
@unsafe
def kp_quant(
  +q: U32,
) -> String:
  w7_br_96(U32.is_eq(q, 0), q)

# Module: src/core/pretty.bend:158
@unsafe
def kp_alias_name(+aliases: List<&2,KTerm>, +ns: String, +local: String, +name: String) -> String:
  match aliases:
    case Nil{}: name_key(name)
    case Con{im, rest}:
      kc(String, Bool.not(List.is_empty(&2,KTerm,ks(im))) && p88_string_eq(ns, nm(im)), u => nm(kid(im, 0)) ++ "." ++ local, u => kp_alias_name(rest, ns, local, name))

# Module: src/core/pretty.bend:183
@unsafe
def kp_scope(
  env: List<&2, KPName>,
  +id: U32,
  +name: String,
) -> String:
  match env:
    case Nil{}: name ++ "^" ++ U32.show(id)
    case Con{KPFile{ns, aliases}, tail}: kp_scope(tail, id, name)
    case Con{KPName{+n, +i, +depth}, +tail}:
      kc(String, kp_eq(n, name), u => kc(String, U32.is_eq(i, id), u => name, u => name ++ "^" ++ U32.show(kp_index(tail, id))), u => kp_scope(tail, id, name))

# Module: src/core/pretty.bend:214
@unsafe
def kp_bound(
  env: List<&2, KPName>,
  +name: String,
) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{KPFile{ns, aliases}, t}: kp_bound(t, name)
    case Con{KPName{n, i, depth}, t}: kp_eq(n, name) || kp_bound(t, name)

# Module: src/core/pretty.bend:241
@unsafe
def w7_br_99(w7_c: Bool, +t: KTerm, +acc: List<&2, KTerm>) -> KPChain:
  match w7_c:
    case True{}:
      kp_spine(kid(t, 0), Con{kid(t, 1), acc})
    case False{}:
      KPChain{acc, t}

@unsafe
def kp_spine(
  +t: KTerm,
  +acc: List<&2, KTerm>,
) -> KPChain:
  w7_br_99(kp_eq(tg(t), "App"), t, acc)

# Module: src/core/pretty.bend:276
@unsafe
def w7_br_100(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      s
    case False{}:
      kp_float_point(s)

@unsafe
def w7_br_101(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      kp_digit(n)
    case False{}:
      kp_hex(U32.div(n, 16)) ++ kp_digit(U32.mod(n, 16))

@unsafe
def kp_hex(
  +n: U32,
) -> String:
  w7_br_101(U32.is_lt(n, 16), n)

# Module: src/core/pretty.bend:349
@unsafe
def w7_br_109(w7_c: Bool, +t: KTerm, +n: Nat, +p: U32) -> String:
  match w7_c:
    case True{}:
      Nat.show(Nat.add(n, U32.to_nat(kl_number(t)))) ++ "n"
    case False{}:
      kp_par(Nat.show(n) ++ "n+" ++ U32.show(kl_number(t)) ++ "n", U32.is_gt(p, 2))

@unsafe
def qadd(
  +a: U32,
  +b: U32,
) -> U32:
  w7_br_142(U32.is_eq(a, 0), a, b)

# Module: src/check/quantity.bend:59
@unsafe
def unargs(
  +t: KTerm,
  +acc: List<&2, KTerm>,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, p98_tag_eq(t, "App"), u => unargs(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/check/kernel.bend:634
@unsafe
def infer_var(e, ctx, t, dem):
  +bound = ctx_get(ctx, ix(t))
  kc(KChecking, p98_tag_eq(bound, "Absent"), u => bad(cw(e), "unbound variable"), u => ok(cw(e), k_with_children(t, Nil{}), kid(bound, 0), Con{kt("Use", "", ix(t), dem, Nil{}), Nil{}}))

# Module: src/check/kernel.bend:664
@unsafe
def w7_br_174(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      dg_bad_detail(cw(e), "reflexivity endpoints differ", kid(ty, 0), kid(ty, 1))

@unsafe
def w7_br_184(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      kid(t, 1)

@unsafe
def check_open_message(n):
  w7_br_189(U32.is_eq(n, 0), n)

# Module: src/check/kernel.bend:934
@unsafe
def w7_br_201(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      foreign_head(kid(t, 0))
    case False{}:
      t

@unsafe
def foreign_head(
  +t: KTerm,
) -> KTerm:
  w7_br_201(p98_tag_eq(t, "App"), t)

# Module: src/check/kernel.bend:1025
@unsafe
def sk_width(+s: String, +n: U32) -> U32:
  match s:
    case SNil{}: n
    case SCon{c, rest}: sk_width(rest, U32.add(n, dg_units(c)))

# Module: src/check/specialize.bend:104
@unsafe
def w7_br_298(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      ka_spine_eligible(kid(t, 0))
    case False{}:
      p98_tag_eq(t, "Ref") || p98_tag_eq(t, "Var")

@unsafe
def ka_spine_eligible(t):
  w7_br_298(p98_tag_eq(t, "App"), t)

# Module: src/check/annotate.bend:302
@unsafe
def f_raw_skip(
  +ts: List<&2, FToken>,
) -> List<&2, FToken>:
  f_choose(List<&2, FToken>, Bool.or(f_eq(f_raw_tx(ts), "\n"), f_eq(f_raw_tx(ts), ";")),
    u => f_raw_skip(f_raw_tl(ts)), u => ts)

# Module: src/front/lexer.bend:125
@unsafe
def w7_lex_q_eq(isEq: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEq:
    case True{}:
      P150LQuoted{String.reverse(SCon{head, acc}), rest, U32.add(n, 1), U32.add(width, 1), l, U32.add(c, 1)}
    case False{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, dg_units(head)), l, U32.add(c, 1))

@unsafe
def w7_lex_q_nl(isNl: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isNl:
    case True{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, 1), U32.add(l, 1), 0)
    case False{}:
      w7_lex_q_eq(Char.is_eq(head, quote), head, rest, quote, acc, n, width, l, c)

@unsafe
def w7_lex_q_esc(isEsc: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEsc:
    case True{}:
      p150l_escape(rest, quote, acc, n, width, l, c)
    case False{}:
      w7_lex_q_nl(f_ascii_char_eq(head, '
'), head, rest, quote, acc, n, width, l, c)

@unsafe
def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      w7_lex_q_esc(f_ascii_char_eq(head, '\\'), head, rest, quote, acc, n, width, l, c)

@unsafe
def p150l_escape(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,2),U32.add(l,1),0),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,U32.add(1,dg_units(head))),l,U32.add(c,2)))

@unsafe
def p150l_triple(+a: Char, +b: Char, +c: Char) -> Bool:
  w7_br_301(f_ascii_char_eq(a,'.'), a, b, c)

@unsafe
def f_raw_space(
  +ts: List<&2,FToken>,
) -> List<&2,FToken>:
  f_choose(List<&2,FToken>, f_eq(f_raw_tx(ts), "\n"), u => f_raw_space(f_raw_tl(ts)), u => ts)

# Stage18 representation ablation: the shared context is inert.

# Module: src/front/lexer.bend:329
@unsafe
def f_input(+tokens: List<&2,FToken>) -> FInput:
  FInput{tokens, FParseContext{f_parse_scope_empty(), Nil{}, 0}}

# Module: src/front/lexer.bend:333
@unsafe
def w7_br_302(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_span(kid(term, 1), kb(term), ke(term))
    case False{}:
      term

@unsafe
def f_context_free_env(+env: List<&2,KTerm>) -> List<&2,KTerm>:
  match env:
    case Nil{}: Nil{}
    case Con{binding, rest}: Con{kt("Map", "", ix(binding), 0, [ref(nm(binding))]), f_context_free_env(rest)}

# Private scoped heads preserve the parser's syntax/value distinction.

# Module: src/front/contextual.bend:157
@unsafe
def f_context_close_done(+parsed: FParsed, +outer: List<&2,KTerm>) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => FParsed{term, f_context_close(rest, outer)})

# Module: src/front/contextual.bend:211
@unsafe
def w7_br_307(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_span(kid(term, 0), kb(term), ke(term))
    case False{}:
      term

@unsafe
def f_group_ann(
  +n: KTerm,
  +p: FParsed,
) -> FParsed:
  match p:
    case FParsed{ty, ts}:
      FParsed{f_choose(KTerm, f_eq(tg(n), "Error"), u => n, u => f_choose(KTerm, f_eq(tg(ty), "Error"), u => ty, u => kt("Ann", "", 0, 1, [n, ty]))), ts}

# Module: src/front/parser.bend:345
@unsafe
def w7_br_327(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      11
    case False{}:
      w7_br_326(f_eq(s, "*") || f_eq(s, "/") || f_eq(s, "%"))

@unsafe
def w7_br_344(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".or"
    case False{}:
      w7_br_343(f_eq(s, ".^."), s)

@unsafe
def f_matcher_tail(name, n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{f_choose(KTerm, f_context_stop(n), u => n, u => f_choose(KTerm, f_context_stop(m), u => m, u => kt("Mat", name, 0, 1, [n, m]))), ts}

# Module: src/front/parser.bend:476
@unsafe
def f_family_range(+p: FParsed, +end: U32) -> FParsed:
  match p:
    case FParsed{n, ts}: FParsed{f_choose(KTerm, f_eq(tg(n), "Error"), u => n, u => k_with_span(n, end, end)), ts}

# Only explicitly desugared list/tuple/existential/matcher trees use this walk.
# Existing child origins are boundaries, so parsed subtrees are never revisited.

# Module: src/front/parser.bend:638
@unsafe
def fpe_point_at(+term: KTerm, +legacy: String, +expected: String) -> KTerm:
  kt_span("Error", legacy, 0, 0, [kt("ParseExpected", expected, 0, 0, Nil{}), atom("ParseObservedPoint")], kb(term), ke(term))

# Module: src/front/parser.bend:717
@unsafe
def fpe_point_observed(+source: String, +offset: U32) -> String:
  match source:
    case SNil{}: "end of input"
    case SCon{c, rest}:
      f_choose(String, U32.is_lt(offset, dg_units(c)),
        u => f_choose(String, U32.is_le(Char.to_u32(c), 65535), u => "'" ++ SCon{c, ""} ++ "'", u => ""),
        u => fpe_point_observed(rest, U32.sub(offset, dg_units(c))))

# Module: src/front/parser.bend:726
@unsafe
def fpe_name_text(+text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{c, rest}: f_ident(c) && fpe_name_text(rest)

# Authentic parser spans are UTF16 scalar boundaries, not String character counts.

# Module: src/front/parser.bend:769
@unsafe
def fpe_source_slice(+source: String, +begin: U32, +end: U32) -> String:
  match source:
    case SNil{}: ""
    case SCon{c, rest}:
      f_choose(String, U32.is_ge(begin, dg_units(c)),
        u => fpe_source_slice(rest, U32.sub(begin, dg_units(c)), U32.sub(end, dg_units(c))),
        u => f_choose(String, U32.is_ge(end, dg_units(c)), u => SCon{c, fpe_source_slice(rest, 0, U32.sub(end, dg_units(c)))}, u => ""))

# Module: src/front/declarations.bend:234
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
def f_law_arity(clauses):
  match clauses:
    case Nil{}:
      0
    case Con{c, rest}:
      f_choose(U32, f_eq(tg(c), "Exists"), u => 0, u => U32.add(1, f_law_arity(rest)))

# Module: src/front/declarations.bend:645
@unsafe
def ff_let(t, vars, r):
  match r:
    case FFlatten{+body, next}:
      f_choose(FFlatten, ff_failed(body), u => FFlatten{body, next}, u => FFlatten{f_choose(KTerm, f_eq(tg(body), "Lam"), u => f_lbind(vars, kt_span("Let", "", 0, 1, [kt_span("Bind", nm(kid(t, 0)), ix(kid(t, 0)), qt(kid(t, 0)), [kid(t, 1)], kb(kid(t, 0)), ke(kid(t, 0))), kid(body, 0)], kb(t), ke(t))), u => fpe_message_at(kid(t, 0), "a match cannot scrutinize a local binding", "a parameter or field scrutinee (a match cannot scrutinize a local binder: give it its own def)")), next})

# Module: src/front/flatten.bend:120
@unsafe
def ff_lam(v, r):
  match r:
    case FFlatten{body, next}:
      f_choose(FFlatten, ff_failed(body), u => FFlatten{body, next}, u => FFlatten{k_lam(nm(v), ix(v), qt(v), [body], kb(v), ke(v), True{}), next})

# Module: src/front/flatten.bend:148
@unsafe
def ff_fields(ps, q, next):
  match ps:
    case Nil{}:
      FFields{Nil{}, next}
    case Con{+p, rest}:
      f_choose(FFields, f_eq(tg(p), "Var"), u => ff_field_cons(kt_span("Var", nm(p), ix(p), f_choose(U32, U32.is_eq(q, 2), u => 2, u => qt(p)), Nil{}, kb(p), ke(p)), ff_fields(rest, q, next)), u => ff_field_cons(kt_span("Var", "_" ++ U32.show(next), U32.add(2147483648, next), q, Nil{}, kb(p), ke(p)), ff_fields(rest, q, U32.add(next, 1))))

# Module: src/front/flatten.bend:160
@unsafe
def ff_miss_done(c, hit, r, origin):
  match r:
    case FFlatten{miss, next}:
      f_choose(FFlatten, ff_failed(miss), u => FFlatten{miss, next}, u => FFlatten{kt_span("Mat", nm(c), 0, 1, [hit, miss], kb(c), ke(c)), next})

# Module: src/front/flatten.bend:184
@unsafe
def f_env(name, env):
  match env:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+x, xs}:
      f_choose(KTerm, f_eq(name, nm(x)) && (Bool.not(f_eq(name, "_")) || f_eq(tg(x), "RewriteVar")), u => x, u => f_env(name, xs))

# Module: src/front/elaborate.bend:68
@unsafe
def f_rowpat(
  +r: KTerm,
) -> KTerm:
  kid(kid(r, 0), 0)

# Module: src/front/elaborate.bend:110
@unsafe
def w7_br_425(w7_c: Bool, +origin: KTerm, +rest: String, +offset: U32, +legacy: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_span(legacy, kb(origin), ke(origin))
    case False{}:
      fpe_expected_at(k_with_span(origin, U32.add(kb(origin), offset), U32.add(kb(origin), offset)), nm(legacy), "a numeric literal (NUMBER is U32, NUMBER n is Nat)", "'" ++ SCon{f_head(rest), ""} ++ "'")

@unsafe
def f_last(
  +xs: List<&2, KTerm>,
) -> KTerm:
  match xs:
    case Nil{}:
      atom("Absent")
    case Con{+x, xt}:
      f_choose(KTerm, U32.is_eq(terms_len(xt), 0), u => x, u => f_last(xt))

# Module: src/front/sugar.bend:18
@unsafe
def f_do_var(+term: KTerm, +input: FInput) -> Bool:
  f_eq(tg(term), "Var") || f_eq(tg(term), "FName")

# Module: src/front/sugar.bend:101
@unsafe
def w7_br_463(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_nat_prefix(kl_number(a), b)
    case False{}:
      f_app(ref("Nat.add"), [a, b])

@unsafe
def w7_br_466(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_namespace_head(kid(t, 0))
    case False{}:
      t

@unsafe
def f_namespace_head(t):
  w7_br_466(f_eq(tg(t), "App") || f_eq(tg(t), "Call"), t)

# Module: src/front/literals_arrays.bend:147
@unsafe
def w7_br_467(w7_c: Bool, +size: KTerm, +value: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      fpe_message_at(size, nm(value), "a power of two count (^d takes a depth)")
    case False{}:
      k_with_span(value, kb(size), ke(size))

@unsafe
def w7_br_478(w7_c: Bool, +term: KTerm, +head: KTerm, +arg: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      head
    case False{}:
      w7_br_477(f_context_stop(arg), term, head, arg)

@unsafe
def f_context_write_var(+term: KTerm, +begin: U32) -> KTerm:
  w7_br_481((f_eq(tg(term), "Var") || f_eq(tg(term), "FName")) && U32.is_gt(begin, 0) && U32.is_eq(kb(term), begin), term)

# Module: src/front/literals_arrays.bend:225
@unsafe
def f_context_material_deferred(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>) -> Bool:
  match term:
    case KLiteral{_, _, _, _, _}: False{}
    case KLambda{_, _, _, _, _, _, _, _}: True{}
    case KTerm{tag, _, _, _, _, _, _, _}:
      f_eq(tag, "Lam") || (f_eq(tag, "All") && Bool.not(List.is_empty(&2,KTerm,built))) || (f_eq(tag, "Let") && List.is_empty(&2,KTerm,rest))

@unsafe
def f_parallel_body(pats, vals, p):
  match p:
    case FParsed{body, ts}:
      FParsed{f_choose(KTerm, f_context_stop(body), u => body, u => kt("Parallel", "", 0, 1, [kt("Patterns", "", 0, 1, pats), kt("Values", "", 0, 1, vals), body])), ts}

# Module: src/front/parallel.bend:79
@unsafe
def w7_br_487(w7_c: Bool, +body: KTerm, +n: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_unlamb(kid(body, 0), U32.sub(n, 1))
    case False{}:
      kt("Error", "cannot match a parallel let binding", 0, 0, Nil{})

@unsafe
def w7_br_488(w7_c: Bool, +body: KTerm, +n: U32) -> KTerm:
  match w7_c:
    case True{}:
      body
    case False{}:
      w7_br_487(f_eq(tg(body), "Lam"), body, n)

@unsafe
def f_unlamb(body, n):
  w7_br_488(U32.is_eq(n, 0), body, n)

# Module: src/front/parallel.bend:91
@unsafe
def w7_rename_ref(isRef: Bool, +t: KTerm, +m: KTerm) -> KTerm:
  match isRef:
    case True{}:
      k_with_span(kid(m, 0), kb(t), ke(t))
    case False{}:
      kt_span("Var", nm(t), ix(kid(m, 0)), qt(t), Nil{}, kb(t), ke(t))

@unsafe
def w7_br_495(w7_c: Bool, +ty: KTerm) -> U32:
  match w7_c:
    case True{}:
      U32.add(1, f_leading_quants(kid(ty, 1)))
    case False{}:
      0

@unsafe
def f_leading_quants(
  +ty: KTerm,
) -> U32:
  w7_br_495(f_eq(tg(ty), "All") && f_eq(tg(kid(ty, 0)), "Qnt"), ty)

# Module: src/front/families.bend:39
@unsafe
def w7_reserved_c(c0: U32, +s: String) -> Bool:
  match c0:
    case 100:
      f_eq(s, "def") || f_eq(s, "do")
    case 116:
      f_eq(s, "type")
    case 108:
      f_eq(s, "law")
    case 109:
      f_eq(s, "match")
    case 99:
      f_eq(s, "case")
    case 114:
      f_eq(s, "return")
    case 102:
      f_eq(s, "for")
    case 101:
      f_eq(s, "exs")
    case 119:
      f_eq(s, "where")
    case 105:
      f_eq(s, "is") || f_eq(s, "import")
    case 84:
      f_eq(s, "Type")
    case 68:
      f_eq(s, "Data")
    case 75:
      f_eq(s, "Kind")
    case 81:
      f_eq(s, "Quant")
    case _:
      False{}

@unsafe
def f_named_field(+name: String, +fields: List<&2,KTerm>) -> Bool:
  match fields:
    case Nil{}: False{}
    case Con{field, rest}: f_eq(name, nm(field)) || f_named_field(name, rest)

# Module: src/front/validate.bend:145
@unsafe
def w7_br_507(w7_c: Bool, +s: String) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      f_ident(f_head(s)) && (Bool.not(Char.is_eq(f_head(s), '.')) || f_ascii_alpha(f_head(f_tail(s))) || Char.is_eq(f_head(f_tail(s)), '_')) && f_name_chars(f_tail(s))

@unsafe
def f_name_chars(s):
  w7_br_507(String.is_empty(s), s)

# Module: src/front/validate.bend:164
@unsafe
def f_bare_params(
  +params: List<&2, KTerm>,
) -> Bool:
  match params:
    case Nil{}:
      True{}
    case Con{+p, rest}:
      f_eq(tg(kid(p, 0)), "Qnt") && Bool.not(f_eq(tg(p), "Template")) && f_bare_params(rest)

# Module: src/front/validate.bend:174
@unsafe
def f_import_used(+name: String, +imports: List<&2,KTerm>) -> Bool:
  match imports:
    case Nil{}: False{}
    case Con{im, rest}: p88_string_eq(name, nm(kid(im, 0))) || f_import_used(name, rest)

# Module: src/front/validate.bend:217
@unsafe
def f_match_error(+head: KTerm, +origin: KTerm) -> KTerm:
  +legacy : String = "match requires an unconsumed parameter or constructor field"
  f_choose(KTerm, f_eq(tg(head), "Var") || f_eq(tg(head), "Ref"),
    u => fpe_match_at(head, head, legacy, 0),
    u => f_choose(KTerm, f_eq(tg(head), "Ctr") || f_eq(tg(head), "Literal") || core_literal(head),
      u => fpe_match_at(head, origin, legacy, 1),
      u => fpe_message_at(f_choose(KTerm, U32.is_gt(kb(head), 0), u => head, u => origin), legacy, "a parameter or field scrutinee (a match cannot scrutinize a computed value: give it its own def)")))

# Module: src/front/validate.bend:226
@unsafe
def f_import_raw(+error: KTerm) -> KTerm:
  k_with_children(error, [kid(error, 0), kid(error, 1), kid(error, 2), {KTerm{"ParseRaw", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])

# Module: src/load/graph.bend:89
@unsafe
def f_path_parent(parts):
  match parts:
    case Nil{}:
      [".."]
    case Con{+p, rest}:
      f_choose(List<&2,String>, f_eq(p, ".."), u => Con{"..", Con{p, rest}}, u => rest)

# Module: src/load/graph.bend:111
@unsafe
def f_path_join_parts(parts, acc):
  match parts:
    case Nil{}:
      acc
    case Con{part, rest}:
      f_path_join_parts(rest, acc ++ f_choose(String, String.is_empty(acc) || f_eq(acc, "/"), u => "", u => "/") ++ part)

# Module: src/load/graph.bend:119
@unsafe
def f_graph_source(
  +path: String,
  +sources: List<&2,FSource>,
) -> FSource:
  match sources:
    case Nil{}:
      FSource{"", "", ""}
    case Con{+s, rest}:
      f_choose(FSource, f_eq(path, f_source_name(s)) || f_eq(path, f_source_path(s)), u => s, u => f_graph_source(path, rest))

# Module: src/load/graph.bend:143
@unsafe
def w7_br_522(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Error", "imported law fills require the canonical graph loader", 0, 0, Nil{})
    case False{}:
      fpe_terms(ks(t))

@unsafe
def w7_br_523(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_521(String.is_empty(nm(t)), t)
    case False{}:
      w7_br_522(f_eq(tg(t), "ImportLaw"), t)

@unsafe
def fpe_term(t):
  w7_br_523(f_eq(tg(t), "Error"), t)

# Module: src/load/graph.bend:365
@unsafe
def fpe_terms(ts):
  match ts:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_terms_next(fpe_term(head), tail)

# Module: src/load/graph.bend:370
@unsafe
def w7_br_524(w7_c: Bool, +error: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      fpe_terms(rest)
    case False{}:
      error

@unsafe
def fpe_terms_next(error, rest):
  w7_br_524(f_eq(tg(error), "Absent"), error, rest)

# Module: src/load/graph.bend:373
@unsafe
def fpe_unique_source(path, sources, found):
  match sources:
    case Nil{}: found
    case Con{head, tail}:
      f_choose(KTerm, p88_string_eq(path, f_source_path(head)), u => f_choose(KTerm, f_eq(tg(found), "Absent"), u => fpe_unique_source(path, tail, kt("ParseSource", f_source_text(head), 0, 0, Nil{})), u => {KTerm{"Ambiguous", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => fpe_unique_source(path, tail, found))

# Module: src/load/graph.bend:409
@unsafe
def f_seed_matches(source, path, text):
  Bool.not(String.is_empty(path)) && f_eq(f_source_name(source), "Base") && f_eq(f_source_path(source), path) && f_seed_text_equal(f_source_text(source), text)

# Module: src/load/seed.bend:84
@unsafe
def fs_inject(g, seed):
  match g:
    case FGraph{book, err, done}:
      FGraph{norm_defs_join(book, fs_book(seed)), err, Con{kt("Loaded", fs_path(seed), f_graph_count_defs(fs_book(seed), 0), 0, [ref("")]), done}}

# Module: src/load/seed.bend:120
@unsafe
def f_source(name, sources):
  match sources:
    case Nil{}:
      FSource{"", "", ""}
    case Con{+source, rest}:
      f_choose(FSource, f_eq(name, f_source_name(source)), u => source, u => f_source(name, rest))

# Module: src/load/modules.bend:83
@unsafe
def f_header_line(+source: String, +acc: String, +size: U32) -> FScanned:
  match source:
    case SNil{}: FScanned{String.reverse(acc), "", size}
    case SCon{c, rest}:
      f_choose(FScanned, Char.is_eq(c, '\n'), u => FScanned{String.reverse(SCon{c, acc}), rest, U32.add(size, 1)}, u => f_header_line(rest, SCon{c, acc}, U32.add(size, dg_units(c))))

# Module: src/load/modules.bend:165
@unsafe
def w7_br_539(w7_c: Bool, +source: String) -> String:
  match w7_c:
    case True{}:
      f_header_space(f_tail(source))
    case False{}:
      source

@unsafe
def f_header_space(+source: String) -> String:
  w7_br_539(Bool.not(String.is_empty(source)) && f_ascii_space(f_head(source)), source)

# Module: src/load/modules.bend:169
@unsafe
def f_prefix_source_completed(+prefix: List<&2,KDef>, +count: U32, +ready: Bool, +completion: FCompletion) -> FPrefixCompletion:
  match completion:
    case FCompletion{graph, parsed}:
      match graph:
        case FGraph{book, error, done}:
          kc(FPrefixCompletion, ready && String.is_empty(error),
            u => f_prefix_source_tail(graph, parsed, prefix, count, f_prefix_drop(book, count)),
            u => FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, count, False{}}, parsed})

# Module: src/load/prefix.bend:220
@unsafe
def dg_width(
  +s: String,
) -> U32:
  match s:
    case SNil{}: 0
    case SCon{c, rest}: U32.add(dg_units(c), dg_width(rest))

# Module: src/diagnostic/render.bend:57
@unsafe
def dg_line_at(
  +s: String,
  +offset: U32,
  +line: U32,
) -> U32:
  match s:
    case SNil{}: line
    case SCon{c, rest}:
      kc(U32, U32.is_lt(offset, dg_units(c)), u => line, u => dg_line_at(rest, U32.sub(offset, dg_units(c)), kc(U32, Char.is_eq(c, '\n'), u => U32.add(line, 1), u => line)))

# Module: src/diagnostic/render.bend:68
@unsafe
def dg_marker_left(
  +source: String,
  +offset: U32,
  +left: String,
) -> String:
  match source:
    case SNil{}: left
    case SCon{c, rest}:
      kc(String, U32.is_eq(offset, 0), u => left, u => kc(String, U32.is_lt(offset, dg_units(c)), u => left ++ dg_padding(offset), u => dg_marker_left(rest, U32.sub(offset, dg_units(c)), kc(String, Char.is_eq(c, '\n'), u => "", u => left ++ kc(String, Char.is_eq(c, '\t'), u => "\t", u => dg_padding(dg_units(c)))))))

# Module: src/diagnostic/render.bend:115
@unsafe
def dg_scope(
  +ctx: List<&2, KTerm>,
  +env: List<&2, KPName>,
) -> List<&2, KPName>:
  match ctx:
    case Nil{}: env
    case Con{h, rest}: dg_scope(rest, kp_bind(env, h))


# book_load blanks leading imports while retaining their newlines. Coordinates
# still use the immutable raw source; only the displayed lines differ.

# Module: src/diagnostic/render.bend:227
@unsafe
def dg_as_expr(
  +t: KTerm,
) -> DExpr:
  w7_br_555(p98_tag_eq(t, "DText"), t)

# Module: src/diagnostic/trace.bend:101
@unsafe
def dg_origin_trail(
  +origins: List<&2, DOrigin>,
  +name: String,
  +trail: List<&2, KTerm>,
) -> DSpan:
  match trail:
    case Nil{}: DNoSpan{}
    case Con{h, rest}: dg_origin_found(origins, name, rest, dg_origin_span(origins, kb(h), ke(h)))

# Module: src/diagnostic/produce.bend:69
@unsafe
def w7_br_559(w7_c: Bool, +origins: List<&2, DOrigin>, +name: String, +rest: List<&2, KTerm>, +found: DSpan) -> DSpan:
  match w7_c:
    case True{}:
      found
    case False{}:
      dg_origin_trail(origins, name, rest)

@unsafe
def dg_origin_found(origins, name, rest, found):
  w7_br_559(dg_has_span(found), origins, name, rest, found)

# Module: src/diagnostic/produce.bend:73
@unsafe
def j_word(t, at, acc):
  kc(Maybe<&2, U32>, p98_tag_eq(t, "Ctr"), u => kc(Maybe<&2, U32>, p88_string_eq(nm(t), "WNil"), u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), u => Some{acc}, u => None{}), u => kc(Maybe<&2, U32>, p88_string_eq(nm(t), "WCon") && U32.is_lt(at, 32), u => j_word_bit(j_strip(kid(t, 0)), j_strip(kid(t, 1)), at, acc), u => None{})), u => None{})

# Module: src/back/common/literals.bend:48
@unsafe
def j_word_bit(bit, rest, at, acc):
  kc(Maybe<&2, U32>, p98_tag_eq(bit, "Ctr") && (p88_string_eq(nm(bit), "True") || p88_string_eq(nm(bit), "False")), u => j_word(rest, U32.add(at, 1), U32.or(acc, kc(U32, p88_string_eq(nm(bit), "True"), u => U32.shln(1, U32.to_nat(at)), u => 0))), u => None{})

# Module: src/back/common/literals.bend:52
law j_env:
  for +env: List<&2, KTerm>
  for +id: U32
  KTerm

@unsafe
def w5c2_j_env_if(hit: Bool, +h: KTerm, +rest: List<&2, KTerm>, +id: U32) -> KTerm:
  match hit:
    case True{}: kid(h, 0)
    case False{}: j_env(rest, id)

@unsafe
def j_env(env, id):
  match env:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      w5c2_j_env_if(U32.is_eq(ix(h), id), h, rest, id)

# Module: src/back/common/queries.bend:24
@unsafe
def w5c2_j_spine_app(is_app: Bool, +tag: String, +name: String, +kids: List<&2, KTerm>, +args: List<&2, KTerm>) -> KTerm:
  match is_app:
    case False{}: w5c2_j_spine_ref(String.eq(tag, "Ref"), name, args)
    case True{}:
      match kids:
        case Con{f, Con{x, _}}: j_call_spine(f, Con{x, args})
        case Con{f, Nil{}}: j_call_spine(f, Con{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args})
        case Nil{}: j_call_spine({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args})

@unsafe
def w5c2_j_spine_ann(is_ann: Bool, +tag: String, +name: String, +kids: List<&2, KTerm>, +args: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: w5c2_j_spine_app(String.eq(tag, "App"), tag, name, kids, args)
    case True{}:
      match kids:
        case Con{h, _}: j_call_spine(h, args)
        case Nil{}: j_call_spine({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args)

@unsafe
def j_call_spine(t, args):
  match t:
    case KTerm{tag, name, _, _, kids, _, _, _}:
      w5c2_j_spine_ann(String.eq(tag, "Ann"), tag, name, kids, args)
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/back/common/queries.bend:63
@unsafe
def w7_br_572(w7_c: Bool, +book: List<&2, KDef>, +tel: KTerm, +ret: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      all(qt(tel), nm(tel), ix(tel), kid(tel, 0), j_arm_tel(book, kid(tel, 1), ret))
    case False{}:
      ret

@unsafe
def j_arm_tel(book, tel, ret):
  w7_br_572(p98_tag_eq(tel, "All"), book, tel, ret)

# Module: src/back/common/queries.bend:168
@unsafe
def w7_br_574(w7_c: Bool, +t: KTerm, +args: U32) -> Bool:
  match w7_c:
    case True{}:
      j_io_spine(kid(t, 0), U32.add(args, 1))
    case False{}:
      p98_tag_eq(t, "Ref") && p88_string_eq(nm(t), "IO") && U32.is_eq(args, 1)

@unsafe
def j_io_spine(t, args):
  w7_br_574(p98_tag_eq(t, "App"), t, args)

# Module: src/back/common/queries.bend:203
@unsafe
def j_escape_char_on(c, key):
  match key:
    case 34:
      "\\\""
    case 92:
      "\\\\"
    case 10:
      "\\n"
    case 13:
      "\\r"
    case 9:
      "\\t"
    case 0:
      "\\x00"
    case n:
      kc(String, U32.is_gt(n, 1114111) || (U32.is_ge(n, 55296) && U32.is_le(n, 57343)),
        u => "\\uDC00" ++ j_escape_unit(U32.shrn(n, 22n)) ++
          j_escape_unit(U32.and(U32.shrn(n, 11n), 2047)) ++ j_escape_unit(U32.and(n, 2047)),
        u => Char.show(Char.from_u32(n)))

# Emit ASCII source for the three payload units of a non-scalar Char. Raw
# non-scalars would be replaced when compiler output crosses its host boundary.
@unsafe
def j_nat(t, acc):
  kc(Maybe<&2, Nat>, core_nat(t), u => Some{Nat.add(acc, U32.to_nat(kl_number(t)))}, u =>
  kc(Maybe<&2, Nat>, p98_tag_eq(t, "Ctr"), u => kc(Maybe<&2, Nat>, p88_string_eq(nm(t), "Zero"), u => Some{acc}, u => kc(Maybe<&2, Nat>, p88_string_eq(nm(t), "Succ"), u => j_nat(j_strip(kid(t, 0)), Nat.add(acc, 1n)), u => None{})), u => None{}))

# Module: src/back/js/literals.bend:67
@unsafe
def w7_br_604(w7_c: Bool, +name: String) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_603(String.contains(name, "|"), name)

@unsafe
def j_u32_bounded(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}:
      kc(Bool, U32.is_eq(fuel, 0), u => False{}, u =>
        j_u32_bounded(kc(List<&2,KTerm>, p98_tag_eq(t, "Ann"),
          u => Con{kid(t, 0), rest}, u => List.append(&2, KTerm, ks(t), rest)), U32.sub(fuel, 1)))

# Module: src/back/js/primitive.bend:7
@unsafe
def j_primitive_arity(+name: String) -> U32:
  w7_br_606(String.contains("|U32.inc|U32.not|U32.shl|U32.shr|U32.is_zero|U32.to_nat|U32.from_nat|U32.to_f32|F32.neg|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|", "|" ++ name ++ "|"))

# Module: src/back/js/primitive.bend:15
@unsafe
def w7_br_608(w7_c: Bool, +name: String) -> String:
  match w7_c:
    case True{}:
      "Nat"
    case False{}:
      w7_br_607(String.starts_with(name, "F32."))

@unsafe
def w7_br_610(w7_c: Bool, +name: String) -> String:
  match w7_c:
    case True{}:
      "Nat"
    case False{}:
      w7_br_609(p88_string_eq(name, "U32.to_f32") || String.starts_with(name, "F32."))

@unsafe
def w7_br_614(w7_c: Bool, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(ty, 1)
    case False{}:
      ty

@unsafe
def w7_br_615(w7_c: Bool, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(ty, 2)
    case False{}:
      kid(kid(ty, 3), 0)

@unsafe
def j_map_sigma_kind(+ty: KTerm, +qa: U32, +qb: U32) -> Bool:
  +q = kid(ty, 0)
  p98_tag_eq(ty, "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    kc(Bool, p98_tag_eq(q, "Qua"), u => U32.is_eq(qt(q), kc(U32, U32.is_eq(qa, 1) || U32.is_eq(qb, 1), u => 1, u => 2)) && List.is_empty(&2,KTerm, ks(q)), u =>
      p98_tag_eq(q, "Min") && U32.is_eq(terms_len(ks(q)), 2) && p98_tag_eq(kid(q, 0), "Qua") && U32.is_eq(qt(kid(q, 0)), qa) &&
      List.is_empty(&2,KTerm, ks(kid(q, 0))) && p98_tag_eq(kid(q, 1), "Qua") && U32.is_eq(qt(kid(q, 1)), qb) && List.is_empty(&2,KTerm, ks(kid(q, 1))))

# Unit stays an internal nullary tagged value. This exact native owner proof
# neither widens scalar public roots nor admits arbitrary Map payload ADTs.

# Module: src/back/js/jpure.bend:1518
@unsafe
def j_fusion_after(+t: KTerm, +left: U32) -> KTerm:
  +h = j_strip(t)
  kc(KTerm, U32.is_eq(left, 0), u => h, u =>
    kc(KTerm, p98_tag_eq(h, "Lam") && U32.is_eq(terms_len(ks(h)), 1),
      u => j_fusion_after(kid(h, 0), U32.sub(left, 1)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/js/region.bend:862
@unsafe
def j_fusion_binder(+t: KTerm, +at: U32) -> KTerm:
  +h = j_strip(t)
  kc(KTerm, p98_tag_eq(h, "Lam"), u =>
    kc(KTerm, U32.is_eq(at, 0), u => h, u => j_fusion_binder(kid(h, 0), U32.sub(at, 1))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/js/region.bend:868
@unsafe
def j_fusion_cases(+t: KTerm, +empty: String, +link: String) -> Bool:
  +h = j_strip(t)
  +r = j_strip(kid(h, 1))
  p98_tag_eq(h, "Mat") && p88_string_eq(nm(h), empty) && U32.is_eq(terms_len(ks(h)), 2) &&
    p98_tag_eq(r, "Mat") && p88_string_eq(nm(r), link) && U32.is_eq(terms_len(ks(r)), 2) &&
    p98_tag_eq(j_strip(kid(r, 1)), "Efq")

# Module: src/back/js/region.bend:885
@unsafe
def w7_br_625(w7_c: Bool, +t: KTerm, +id: U32, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      Bool.not(U32.is_eq(ix(t), id))
    case False{}:
      j_callback_runtime_absent_terms(ks(t), id, U32.sub(fuel, 1))

@unsafe
def w7_br_626(w7_c: Bool, +t: KTerm, +id: U32, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      j_callback_runtime_absent(kid(t, 0), id, U32.sub(fuel, 1))
    case False{}:
      w7_br_625(p98_tag_eq(t, "Var"), t, id, fuel)

@unsafe
def w7_br_627(w7_c: Bool, +t: KTerm, +id: U32, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      w7_br_626(p98_tag_eq(t, "Ann"), t, id, fuel)
    case False{}:
      False{}

@unsafe
def j_callback_runtime_absent(+t: KTerm, +id: U32, +fuel: U32) -> Bool:
  w7_br_627(U32.is_gt(fuel, 0), t, id, fuel)

# Module: src/back/js/region.bend:1260
@unsafe
def j_callback_runtime_absent_terms(+ts: List<&2,KTerm>, +id: U32, +fuel: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, j_callback_runtime_absent(h, id, fuel),
        u => j_callback_runtime_absent_terms(rest, id, fuel), u => False{})

# Module: src/back/js/fold.bend:4
@unsafe
def j_list_ground_kind(+ty: KTerm) -> Bool:
  p98_tag_eq(ty, "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2)

# Module: src/back/js/fold.bend:304
@unsafe
def j_l_name(t):
  j_l_names(rm(t))

# Module: src/back/js/emit.bend:567
@unsafe
def nt_count(-A: Data, xs: List<&2, A>) -> U32:
  nt_count_go(A, xs, 0)

# Module: src/back/native/text.bend:40
@unsafe
def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)

# Module: src/back/native/text.bend:50
@unsafe
def w5c2_is_clean(s: String) -> Bool:
  match s:
    case SNil{}: True{}
    case SCon{h, t}: w5c2_clean_char_ok(Char.to_u32(h)) && w5c2_is_clean(t)

@unsafe
def w5c2_clean_slow(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}: SCon{w5c2_clean_pick(w5c2_clean_char_ok(Char.to_u32(h)), h), w5c2_clean_slow(t)}

@unsafe
def nt_fid(k: String) -> String:
  "FID_" ++ nc_ctor_codes(k)

# Module: src/back/native/text.bend:61
@unsafe
def nt_replace(+s: String, +key: String, +value: String) -> String:
  match key:
    case SNil{}: value ++ s
    case SCon{kh, _}: w5c2_rep_scan(s, key, Char.to_u32(kh), String.length(key), value)

# Module: src/back/native/identity.bend:37
@unsafe
def nc_ctor_encode(name):
  "$ctor." ++ nc_ctor_codes(name)

# Module: src/back/native/identity.bend:58
@unsafe
def nk_kind(+id: U32, env: List<&2, NC_Binding>) -> N_WordKind:
  match env:
    case Nil{}: N_W64{}
    case Con{NC_Binding{at, word, +kind}, rest}: nt_choose(N_WordKind, U32.is_eq(id, at), u => kind, u => nk_kind(id, rest))

# Module: src/back/native/layout.bend:18
@unsafe
def nk_field_binding(+id: U32, +mask: U32, +i: U32) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id), nt_choose(N_WordKind, U32.is_ne(U32.and(mask, U32.shln(1, U32.to_nat(i))), 0), u => N_W32{}, u => N_W64{})}

# Module: src/back/native/intrinsic.bend:4
@unsafe
def w5c2_ni_u32_3(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_not"), "((u64)~(u32)($0))",
  w5c2_str_pick(String.eq(k, "u32_is_zero"), "U32_BIN($0, ==, 0)",
  w5c2_str_pick(String.eq(k, "u32_cmp"), "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))",
  w5c2_str_pick(String.eq(k, "u32_to_f32"), "f32_rewrap((f32)(u32)($0))",
  w5c2_str_pick(String.eq(k, "u32_to_nat"), "((u64)$0)",
  w5c2_str_pick(String.eq(k, "u32_from_nat"), "((u64)(u32)($0))", ""))))))

@unsafe
def w5c2_ni_f32_3(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_floor"), "f32_rewrap((f32)floor(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_ceil"), "f32_rewrap((f32)ceil(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_trunc"), "f32_rewrap((f32)trunc(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_abs"), "f32_rewrap((f32)fabs(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_pow"), "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_atan2"), "f32_rewrap((f32)atan2(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_mod"), "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_neg"), "f32_rewrap(-f32_unbox($0))",
  w5c2_str_pick(String.eq(k, "f32_to_u32"), "f32_to_u32($0)",
  w5c2_str_pick(String.eq(k, "f32_bits"), "$0",
  w5c2_str_pick(String.eq(k, "f32_show"), "f32_show(e, $0)",
  w5c2_str_pick(String.eq(k, "f32_read"), "f32_read(e, $0)", ""))))))))))))

@unsafe
def w5c2_ni_nat(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "nat_add"), "nat_chk(e, $0 + $1)",
  w5c2_str_pick(String.eq(k, "nat_sub"), "($0 < $1 ? 0 : $0 - $1)",
  w5c2_str_pick(String.eq(k, "nat_mul"), "nat_mul(e, $0, $1)",
  w5c2_str_pick(String.eq(k, "nat_double"), "nat_chk(e, $0 + $0)",
  w5c2_str_pick(String.eq(k, "nat_cmp"), "(($0 > $1) + ($0 >= $1))",
  w5c2_str_pick(String.eq(k, "nat_is_lt"), "($0 < $1)", ""))))))

@unsafe
def w5c2_ni_bool(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "bool_or"), "(native_bool($0) | native_bool($1))",
  w5c2_str_pick(String.eq(k, "bool_xor"), "(native_bool($0) ^ native_bool($1))", ""))

@unsafe
def nb_max(+a: U32, +b: U32) -> U32:
  w7_br_636(U32.is_gt(a, b), a, b)

# Module: src/back/native/tables.bend:134
@unsafe
def nu_join(+s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  w5c2_nu_join_lr(U32.is_eq(U32.and(key, mask), 0), s, key, mask)

# Module: src/back/native/uses.bend:22
@unsafe
def nct_cat_left(left: NC_Text, +right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: right
    case False{}: nct_cat_right(left, right, nct_empty(right))

@unsafe
def w7_br_648(w7_c: Bool, +a: NC_Code, +b: NC_Code) -> String:
  match w7_c:
    case True{}:
      nc_error(b)
    case False{}:
      nc_error(a)

@unsafe
def nc_fail(+msg: String, +n: U32) -> NC_Code:
  NC_Code{nct_leaf(""), Nil{}, n, msg, Nil{}}

# Module: src/back/native/bridge.bend:80
@unsafe
def nc_uses_has(+uses: NU_Set, +id: U32) -> Bool:
  nu_has(uses, id)

# Module: src/back/native/bridge.bend:144
law nc_live_uses:
  for env: List<&2, NC_Binding>
  for +uses: NU_Set
  List<&2, NC_Binding>

@unsafe
def w5c2_nc_live_if(has: Bool, +id: U32, +word: String, +kind: N_WordKind, rest: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, NC_Binding>:
  match has:
    case True{}: Con{NC_Binding{id, word, kind}, nc_live_uses(rest, uses)}
    case False{}: nc_live_uses(rest, uses)

@unsafe
def nc_live_uses(env, uses):
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, rest}:
      w5c2_nc_live_if(nu_has(uses, id), id, word, kind, rest, uses)

# Module: src/back/native/bridge.bend:151
@unsafe
def nc_sequence(+tag: String, +name: String, +xs: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match xs:
    case Nil{}: kt(tag, name, 0, 0, List.reverse(&2, KTerm, acc))
    case Con{+h, +t}: nc_mklet(nc_id(n), h, nc_sequence(tag, name, t, Con{var("", nc_id(n)), acc}, U32.inc(n)))

# Module: src/back/native/bridge.bend:335
@unsafe
def w7_br_666(w7_c: Bool, +term: KTerm, +count: U32, +i: U32, +n: U32) -> KTerm:
  match w7_c:
    case True{}:
      term
    case False{}:
      nc_field_apps(app(term, var("", nc_id(U32.add(n, i)))), count, U32.inc(i), n)

@unsafe
def nc_field_apps(+term: KTerm, +count: U32, +i: U32, +n: U32) -> KTerm:
  w7_br_666(U32.is_eq(i, count), term, count, i, n)

# The checked Base alias shares Array.get's ownership, arity and layout gates.
# Keep the existing bounded read implementation; the unchecked contract only
# permits indices below capacity. Non-native definitions still fail db admission.
# Module: src/back/native/bridge.bend:502
@unsafe
def w5c2_cl_ch_up(is_up: Bool, +c: U32, +h: Char) -> Char:
  match is_up:
    case True{}: Char.from_u32(U32.add(c, 32))
    case False{}: w5c2_clean_pick((U32.is_ge(c, 97) && U32.is_le(c, 122)) || (U32.is_ge(c, 48) && U32.is_le(c, 57)) || U32.is_eq(c, 95), h)

@unsafe
def w5c2_pn_u2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "U32.inc"), "u32_inc",
  w5c2_str_pick(String.eq(k, "U32.shl"), "u32_shl",
  w5c2_str_pick(String.eq(k, "U32.shr"), "u32_shr",
  w5c2_str_pick(String.eq(k, "U32.shln"), "u32_shln",
  w5c2_str_pick(String.eq(k, "U32.shrn"), "u32_shrn",
  w5c2_str_pick(String.eq(k, "U32.div"), "u32_div",
  w5c2_str_pick(String.eq(k, "U32.mod"), "u32_mod",
  w5c2_str_pick(String.eq(k, "U32.not"), "u32_not",
  w5c2_str_pick(String.eq(k, "U32.is_zero"), "u32_is_zero",
  w5c2_str_pick(String.eq(k, "U32.to_nat"), "u32_to_nat",
  w5c2_str_pick(String.eq(k, "U32.from_nat"), "u32_from_nat",
  w5c2_str_pick(String.eq(k, "U32.to_f32"), "u32_to_f32",
  w5c2_str_pick(String.eq(k, "U32.cmp"), "u32_cmp", "")))))))))))))

@unsafe
def w5c2_pn_u1(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "U32.add"), "u32_add",
  w5c2_str_pick(String.eq(k, "U32.sub"), "u32_sub",
  w5c2_str_pick(String.eq(k, "U32.mul"), "u32_mul",
  w5c2_str_pick(String.eq(k, "U32.and"), "u32_and",
  w5c2_str_pick(String.eq(k, "U32.or"), "u32_or",
  w5c2_str_pick(String.eq(k, "U32.xor"), "u32_xor",
  w5c2_str_pick(String.eq(k, "U32.is_eq"), "u32_is_eq",
  w5c2_str_pick(String.eq(k, "U32.is_ne"), "u32_is_ne",
  w5c2_str_pick(String.eq(k, "U32.is_lt"), "u32_is_lt",
  w5c2_str_pick(String.eq(k, "U32.is_le"), "u32_is_le",
  w5c2_str_pick(String.eq(k, "U32.is_gt"), "u32_is_gt",
  w5c2_str_pick(String.eq(k, "U32.is_ge"), "u32_is_ge", ""))))))))))))

@unsafe
def w5c2_pn_f(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "F32.add"), "f32_add",
  w5c2_str_pick(String.eq(k, "F32.sub"), "f32_sub",
  w5c2_str_pick(String.eq(k, "F32.mul"), "f32_mul",
  w5c2_str_pick(String.eq(k, "F32.div"), "f32_div",
  w5c2_str_pick(String.eq(k, "F32.is_lt"), "f32_is_lt",
  w5c2_str_pick(String.eq(k, "F32.is_le"), "f32_is_le",
  w5c2_str_pick(String.eq(k, "F32.is_gt"), "f32_is_gt",
  w5c2_str_pick(String.eq(k, "F32.is_ge"), "f32_is_ge",
  w5c2_str_pick(String.eq(k, "F32.is_eq"), "f32_is_eq",
  w5c2_str_pick(String.eq(k, "F32.sqrt"), "f32_sqrt",
  w5c2_str_pick(String.eq(k, "F32.neg"), "f32_neg",
  w5c2_str_pick(String.eq(k, "F32.from_nat"), "f32_from_nat", ""))))))))))))

@unsafe
def w5c2_pn_a(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "Array.get"), "array_get",
  w5c2_str_pick(String.eq(k, "Array.get_unchecked"), "array_get",
  w5c2_str_pick(String.eq(k, "Array.set"), "array_set",
  w5c2_str_pick(String.eq(k, "Array.new"), "array_new",
  w5c2_str_pick(String.eq(k, "Array.size"), "array_size",
  w5c2_str_pick(String.eq(k, "Array.swap"), "array_swap",
  w5c2_str_pick(String.eq(k, "Array.clone"), "array_clone", "")))))))

@unsafe
def w5c2_pn_nb(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "Nat.add"), "nat_add",
  w5c2_str_pick(String.eq(k, "Nat.sub"), "nat_sub",
  w5c2_str_pick(String.eq(k, "Nat.mul"), "nat_mul",
  w5c2_str_pick(String.eq(k, "Nat.is_lt"), "nat_is_lt",
  w5c2_str_pick(String.eq(k, "Nat.divmod"), "nat_divmod",
  w5c2_str_pick(String.eq(k, "Bool.or"), "bool_or",
  w5c2_str_pick(String.eq(k, "Bool.xor"), "bool_xor", "")))))))

@unsafe
def w5c2_arity_u32(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "u32_add") || String.eq(k, "u32_sub") || String.eq(k, "u32_and") ||
    String.eq(k, "u32_or") || String.eq(k, "u32_xor") || String.eq(k, "u32_mul") ||
    String.eq(k, "u32_is_eq") || String.eq(k, "u32_is_ne") || String.eq(k, "u32_is_lt") ||
    String.eq(k, "u32_is_le") || String.eq(k, "u32_is_gt") || String.eq(k, "u32_is_ge") ||
    String.eq(k, "u32_shln") || String.eq(k, "u32_shrn") || String.eq(k, "u32_div") ||
    String.eq(k, "u32_mod") || String.eq(k, "u32_cmp"))

@unsafe
def w5c2_arity_f32(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "f32_add") || String.eq(k, "f32_sub") || String.eq(k, "f32_mul") ||
    String.eq(k, "f32_div") || String.eq(k, "f32_is_eq") || String.eq(k, "f32_is_ne") ||
    String.eq(k, "f32_is_lt") || String.eq(k, "f32_is_le") || String.eq(k, "f32_is_gt") ||
    String.eq(k, "f32_is_ge") || String.eq(k, "f32_pow") || String.eq(k, "f32_atan2") ||
    String.eq(k, "f32_mod"))

@unsafe
def w5c2_arity_nat(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "nat_add") || String.eq(k, "nat_sub") || String.eq(k, "nat_mul") ||
    String.eq(k, "nat_cmp") || String.eq(k, "nat_is_lt") || String.eq(k, "nat_divmod"))

@unsafe
def w5c2_arity_arr3(is3: Bool, +k: String) -> U32:
  match is3:
    case True{}: 3
    case False{}: w5c2_arity_2_if(String.eq(k, "array_new") || String.eq(k, "array_get"))

@unsafe
def nc_prim_args(+n: U32, +i: U32) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, U32.is_eq(i, n), u => Nil{}, u => Con{var("", U32.add(4000000000, i)), nc_prim_args(n, U32.inc(i))})

# Module: src/back/native/bridge.bend:541
@unsafe
def w7_br_668(w7_c: Bool, +t: KTerm, +bit: U32, +value: U32) -> NC_Literal:
  match w7_c:
    case True{}:
      nc_word_literal(kid(t, 1), U32.inc(bit), U32.or(value, nt_choose(U32, p88_string_eq(nm(kid(t, 0)), "True"), u => U32.shln(1, U32.to_nat(bit)), u => 0)))
    case False{}:
      NC_Literal{False{}, 0}

@unsafe
def w7_br_669(w7_c: Bool, +t: KTerm, +bit: U32, +value: U32) -> NC_Literal:
  match w7_c:
    case True{}:
      NC_Literal{True{}, value}
    case False{}:
      w7_br_668(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "WCon") && U32.is_lt(bit, 32) && p98_tag_eq(kid(t, 0), "Ctr") && (p88_string_eq(nm(kid(t, 0)), "True") || p88_string_eq(nm(kid(t, 0)), "False")), t, bit, value)

@unsafe
def nc_word_literal(+t: KTerm, +bit: U32, +value: U32) -> NC_Literal:
  w7_br_669(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "WNil"), t, bit, value)

# Module: src/back/native/bridge.bend:573
@unsafe
def w7_br_671(w7_c: Bool, +t: KTerm, +value: U32) -> NC_Literal:
  match w7_c:
    case True{}:
      nc_nat_literal(kid(t, 0), U32.inc(value))
    case False{}:
      NC_Literal{False{}, 0}

@unsafe
def w7_br_672(w7_c: Bool, +t: KTerm, +value: U32) -> NC_Literal:
  match w7_c:
    case True{}:
      NC_Literal{True{}, value}
    case False{}:
      w7_br_671(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "Succ"), t, value)

@unsafe
def w7_br_673(w7_c: Bool, +t: KTerm, +value: U32) -> NC_Literal:
  match w7_c:
    case True{}:
      w7_br_670(U32.is_le(kl_number(t), U32.sub(4294967295, value)), t, value)
    case False{}:
      w7_br_672(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "Zero"), t, value)

@unsafe
def nc_nat_literal(+t: KTerm, +value: U32) -> NC_Literal:
  w7_br_673(core_nat(t), t, value)

# Module: src/back/native/bridge.bend:579
law w5c3_nd_arg_count:
  for +t: KTerm
  for +acc: U32
  U32

@unsafe
def w5c3_nd_arg_count_if(is_app: Bool, +t: KTerm, +acc: U32) -> U32:
  match is_app:
    case True{}: w5c3_nd_arg_count(kid(t, 0), U32.inc(acc))
    case False{}: acc

@unsafe
def w5c3_nd_arg_count(t, acc):
  w5c3_nd_arg_count_if(p98_tag_eq(t, "App"), t, acc)

@unsafe
def w5c3_nd_head_step(is_app: Bool, +t: KTerm) -> KTerm:
  match is_app:
    case True{}: nd_head(kid(t, 0))
    case False{}: t

# Module: src/back/native/direct.bend:66
@unsafe
def nd_head(+t: KTerm) -> KTerm:
  w5c3_nd_head_step(p98_tag_eq(t, "App"), t)

@unsafe
def w5c3_nd_args_step(is_app: Bool, +t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  match is_app:
    case True{}: nd_args(kid(t, 0), Con{kid(t, 1), acc})
    case False{}: acc

# Module: src/back/native/direct.bend:70
@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  w5c3_nd_args_step(p98_tag_eq(t, "App"), t, acc)

# Module: src/back/native/direct.bend:74
@unsafe
def w7_br_683(w7_c: Bool, +t: KTerm, +n: U32) -> U32:
  match w7_c:
    case True{}:
      nd_leading(kid(t, 0), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(t), 0)))))
    case False{}:
      n

@unsafe
def w7_br_684(w7_c: Bool, +t: KTerm, +n: U32) -> U32:
  match w7_c:
    case True{}:
      nd_leading(kid(t, 0), n)
    case False{}:
      w7_br_683(p98_tag_eq(t, "Lam"), t, n)

@unsafe
def nd_leading(+t: KTerm, +n: U32) -> U32:
  w7_br_684(p98_tag_eq(t, "Ann"), t, n)

# Module: src/back/native/direct.bend:79
@unsafe
def nd_reapply(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: nd_reapply(app(head, h), rest)

# Module: src/back/native/direct.bend:102
@unsafe
def nd_match_sequence(+head: KTerm, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt("NMatch", "", 0, 0, Con{head, nt_reverse(KTerm, acc, Nil{})})
    case Con{+h, +rest}: nc_mklet(nc_id(n), h, nd_match_sequence(head, rest, Con{var("", nc_id(n)), acc}, U32.inc(n)))

# Module: src/back/native/direct.bend:134
@unsafe
def nd_match_rest(+t: KTerm) -> List<&2, KTerm>:
  nd_match_rest_list(ks(t))

# Module: src/back/native/direct.bend:138
@unsafe
def w7_br_685(w7_c: Bool, +t: KTerm, +params: List<&2, NC_Binding>, +depth: U32) -> Bool:
  match w7_c:
    case True{}:
      nd_comb_closed(kid(t, 0), params, U32.sub(depth, 1)) && nd_comb_closed(kid(t, 1), params, U32.sub(depth, 1))
    case False{}:
      False{}

@unsafe
def w7_br_686(w7_c: Bool, +t: KTerm, +params: List<&2, NC_Binding>, +depth: U32) -> Bool:
  match w7_c:
    case True{}:
      Bool.not(p88_string_eq(nc_word(ix(t), params), "NATIVE_UNBOUND_VARIABLE"))
    case False{}:
      w7_br_685(p98_tag_eq(t, "App") && U32.is_gt(depth, 0), t, params, depth)

@unsafe
def nd_comb_closed(+t: KTerm, +params: List<&2, NC_Binding>, +depth: U32) -> Bool:
  w7_br_686(p98_tag_eq(t, "Var"), t, params, depth)

# Module: src/back/native/direct.bend:170
@unsafe
def w7_br_687(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      nt_bool(U32.is_eq(ix(t), id))
    case False{}:
      U32.add(nd_comb_uses(kid(t, 0), id), nd_comb_uses(kid(t, 1), id))

@unsafe
def nd_comb_uses(+t: KTerm, +id: U32) -> U32:
  w7_br_687(p98_tag_eq(t, "Var"), t, id)

# Module: src/back/native/direct.bend:175
@unsafe
def w7_br_689(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nd_body(kid(t, 0))
    case False{}:
      t

@unsafe
def nd_body(+t: KTerm) -> KTerm:
  w7_br_689(p98_tag_eq(t, "Lam"), t)

# Module: src/back/native/direct.bend:263
@unsafe
def nd_bindings(+t: KTerm, +acc: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, p98_tag_eq(t, "Lam"), u => nd_bindings(kid(t, 0), Con{nc_binding(ix(t)), acc}), u => nt_reverse(NC_Binding, acc, Nil{}))

# Module: src/back/native/direct.bend:271
@unsafe
def nd_entry_params(+left: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(left, 0), u => Nil{}, u =>
    Con{nc_binding(nc_id(n)), nd_entry_params(U32.sub(left, 1), U32.inc(n))})

# Module: src/back/native/direct.bend:276
@unsafe
def nd_entry_args(params: List<&2, NC_Binding>) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{id, word, kind}, rest}: Con{var("", id), nd_entry_args(rest)}

# Named user-function values retain the curried ownership ABI. Their final
# closure tail-calls the full direct worker so only one copy of the actual
# body is lowered. Foreign, intrinsic and bang entries keep their old path.

# Module: src/back/native/direct.bend:297
@unsafe
def w7_br_691(w7_c: Bool, +bits: U32) -> N_WordKind:
  match w7_c:
    case True{}:
      N_W32{}
    case False{}:
      w7_br_690(U32.is_eq(bits, 2))

@unsafe
def nq_layout_dep(+ty: KTerm, ids: List<&2, U32>) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{id, rest}: nc_occurs(ty, id) || nq_layout_dep(ty, rest)

# Module: src/back/native/product-layout.bend:35
@unsafe
def w7_br_697(w7_c: Bool, +t: KTerm, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_reduce_app(nq_layout_reduce(kid(t, 0), U32.sub(fuel, 1)), U32.sub(fuel, 1))
    case False{}:
      t

@unsafe
def w7_br_698(w7_c: Bool, +t: KTerm, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_reduce(kid(t, 0), U32.sub(fuel, 1))
    case False{}:
      w7_br_697(p98_tag_eq(t, "App"), t, fuel)

@unsafe
def w7_br_699(w7_c: Bool, +t: KTerm, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      w7_br_698(p98_tag_eq(t, "Ann"), t, fuel)

@unsafe
def nq_layout_reduce(+t: KTerm, +fuel: U32) -> KTerm:
  w7_br_699(U32.is_eq(fuel, 0), t, fuel)

# Module: src/back/native/product-layout.bend:59
@unsafe
def w7_br_700(w7_c: Bool, +head: KTerm, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_reduce(kid(head, 0), fuel)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def nq_layout_reduce_app(+head: KTerm, +fuel: U32) -> KTerm:
  w7_br_700(p98_tag_eq(head, "Lam") && Bool.not(nc_occurs(kid(head, 0), ix(head))), head, fuel)

# Resolve finite syntax aliases as a head/argument machine. Each transition
# spends fuel; revisiting a definition fails. No matcher, primitive or effect is
# evaluated. Substitution growth is checked before constructing the new syntax.

# Module: src/back/native/product-layout.bend:67
@unsafe
def nq_layout_size(ts: List<&2, KTerm>, +left: U32) -> U32:
  U32.sub(4097, nq_layout_remaining(ts, left))

# Module: src/back/native/product-layout.bend:105
@unsafe
def w5c2_nq_sub_if(is_var: Bool, +t: KTerm, +n: U32, +id: U32, +value: KTerm) -> KTerm:
  match is_var:
    case True{}: w5c2_nq_sub_var(U32.is_eq(n, id), t, value)
    case False{}: k_rebuild(t, nm(t), n, qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t))

@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KTerm{tag, _, n, _, _, _, _, _}:
      w5c2_nq_sub_if(String.eq(tag, "Var"), t, n, id, value)
    case KLambda{name, n, quant, kids, removed, begin, end, present}:
      KLambda{name, n, quant, nq_layout_subst_list(kids, id, value), removed, begin, end, present}
    case KLiteral{_, _, _, _, _}: t

# Module: src/back/native/product-layout.bend:120
@unsafe
def nq_layout_subst_list(ts: List<&2, KTerm>, +id: U32, +value: KTerm) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nq_layout_subst(h, id, value), nq_layout_subst_list(rest, id, value)}

# Module: src/back/native/product-layout.bend:126
@unsafe
def nq_width(+shape: KTerm) -> U32:
  w7_br_706(p98_tag_eq(shape, "NQShape"), shape)

# Module: src/back/native/product.bend:18
@unsafe
def w7_br_707(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      nw_uses(ks(t), id)
    case False{}:
      nq_uses_list(ks(t), id)

@unsafe
def w7_br_708(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      U32.max(nq_uses(kid(t, 0), id), nq_uses(kid(t, 1), id))
    case False{}:
      w7_br_707(p98_tag_eq(t, "NWPattern"), t, id)

@unsafe
def w7_br_709(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      nt_bool(U32.is_eq(ix(t), id))
    case False{}:
      w7_br_708(p98_tag_eq(t, "Mat") && U32.is_eq(terms_len(ks(t)), 2), t, id)

@unsafe
def nq_uses(+t: KTerm, +id: U32) -> U32:
  w7_br_709(p98_tag_eq(t, "Var"), t, id)

# Module: src/back/native/product.bend:106
@unsafe
def nq_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_uses(h, id), nq_uses_list(rest, id)))

# Module: src/back/native/product.bend:112
@unsafe
def w7_br_710(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      nq_min_uses_list(ks(t), id)

@unsafe
def w7_br_711(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      U32.min(nq_min_uses(kid(t, 0), id), nq_min_uses(kid(t, 1), id))
    case False{}:
      w7_br_710(p98_tag_eq(t, "NWPattern"), t, id)

@unsafe
def w7_br_712(w7_c: Bool, +t: KTerm, +id: U32) -> U32:
  match w7_c:
    case True{}:
      nt_bool(U32.is_eq(ix(t), id))
    case False{}:
      w7_br_711(p98_tag_eq(t, "Mat") && U32.is_eq(terms_len(ks(t)), 2), t, id)

@unsafe
def nq_min_uses(+t: KTerm, +id: U32) -> U32:
  w7_br_712(p98_tag_eq(t, "Var"), t, id)

# Module: src/back/native/product.bend:117
@unsafe
def nq_min_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_min_uses(h, id), nq_min_uses_list(rest, id)))

# Module: src/back/native/product.bend:123
@unsafe
def nq_bundle_params(+count: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, 0), u => Nil{}, u => Con{nc_binding(nc_id(n)), nq_bundle_params(U32.sub(count, 1), U32.inc(n))})

# Module: src/back/native/product.bend:193
@unsafe
def nq_opaque_args(+tag: String, +name: String, args: List<&2, KTerm>, +done: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt(tag, name, 0, 0, List.reverse(&2, KTerm, done))
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(arg, "NQBundle"),
        u => nc_mklet(nc_id(n), kt("NQBox", nm(arg), 0, 0, ks(arg)), nq_opaque_args(tag, name, rest, Con{var("", nc_id(n)), done}, U32.inc(n))),
        u => nq_opaque_args(tag, name, rest, Con{arg, done}, n))

# Module: src/back/native/product.bend:220
@unsafe
def nq_args_known(shapes: List<&2, KTerm>, args: List<&2, KTerm>) -> Bool:
  match shapes, args:
    case Nil{}, Nil{}: True{}
    case Con{+shape, rest}, Con{+arg, more}:
      nt_choose(Bool, p98_tag_eq(shape, "NQShape"),
        u => (p98_tag_eq(arg, "NQBundle") || p98_tag_eq(arg, "Ctr") || p98_tag_eq(arg, "NCtr")) && p88_string_eq(nm(shape), nm(arg)) && U32.is_eq(ix(shape), terms_len(ks(arg))),
        u => True{}) && nq_args_known(rest, more)
    case _, _: False{}

# A neutral source telescope fixes all live parameter and result shapes once.

# Module: src/back/native/product.bend:282
@unsafe
def nw_var_same(+a: U32, +b: U32, pairs: List<&2, KTerm>) -> Bool:
  match pairs:
    case Nil{}: U32.is_eq(a, b)
    case Con{+p, rest}:
      nt_choose(Bool, U32.is_eq(ix(p), a), u => U32.is_eq(qt(p), b),
        u => nt_choose(Bool, U32.is_eq(qt(p), b), v => False{}, v => nw_var_same(a, b, rest)))

# Module: src/back/native/word-pattern.bend:29
@unsafe
def w7_br_720(w7_c: Bool, +t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  match w7_c:
    case True{}:
      nw_arms(kid(t, 1), zero, kid(t, 0), hasZero, True{})
    case False{}:
      NW_Arms{zero, one, t, hasZero, hasOne, False{}}

@unsafe
def w7_br_721(w7_c: Bool, +t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  match w7_c:
    case True{}:
      nw_arms(kid(t, 1), kid(t, 0), one, True{}, hasOne)
    case False{}:
      w7_br_720(p88_string_eq(nm(t), "True") && Bool.not(hasOne), t, zero, one, hasZero, hasOne)

@unsafe
def w7_br_722(w7_c: Bool, +t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  match w7_c:
    case True{}:
      w7_br_721(p88_string_eq(nm(t), "False") && Bool.not(hasZero), t, zero, one, hasZero, hasOne)
    case False{}:
      NW_Arms{zero, one, t, hasZero, hasOne, False{}}

@unsafe
def w7_br_723(w7_c: Bool, +t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  match w7_c:
    case True{}:
      w7_br_722(U32.is_eq(ix(t), 1) && U32.is_eq(terms_len(ks(t)), 2), t, zero, one, hasZero, hasOne)
    case False{}:
      NW_Arms{zero, one, t, hasZero, hasOne, True{}}

@unsafe
def nw_arms(+t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  w7_br_723(p98_tag_eq(t, "Mat"), t, zero, one, hasZero, hasOne)

# Module: src/back/native/word-pattern.bend:57
@unsafe
def nw_rebuild(bits: List<&2, KTerm>, +word: KTerm) -> KTerm:
  match bits:
    case Nil{}: word
    case Con{h, rest}: nw_rebuild(rest, nw_word(h, word))

# Module: src/back/native/word-pattern.bend:67
@unsafe
def w7_br_726(w7_c: Bool, +t: KTerm, +depth: U32, +value: U32) -> NW_Rows:
  match w7_c:
    case True{}:
      NW_Rows{True{}, [nw_row(kid(t, 0), depth, value, 0)]}
    case False{}:
      NW_Rows{False{}, Nil{}}

@unsafe
def w7_br_730(w7_c: Bool, +mat: KTerm) -> Bool:
  match w7_c:
    case True{}:
      U32.is_eq(ix(mat), 2) && U32.is_eq(terms_len(ks(mat)), 2) && p98_tag_eq(kid(mat, 1), "Efq")
    case False{}:
      False{}

@unsafe
def w7_br_732(w7_c: Bool, +depth: U32, +value: U32, +tail: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      tail
    case False{}:
      nw_prefix(U32.sub(depth, 1), value, nw_word(kt("NWord", U32.show(U32.and(U32.shrn(value, U32.to_nat(U32.sub(depth, 1))), 1)), 0, 0, Nil{}), tail))

@unsafe
def nw_prefix(+depth: U32, +value: U32, +tail: KTerm) -> KTerm:
  w7_br_732(U32.is_eq(depth, 0), depth, value, tail)

# Module: src/back/native/word-pattern.bend:157
@unsafe
def nw_value(row: KTerm) -> U32:
  nw_value_result(U32.read(nm(row)))

# Module: src/back/native/word-pattern.bend:161
@unsafe
def nw_uses(rows: List<&2, KTerm>, +id: U32) -> U32:
  match rows:
    case Nil{}: 0
    case Con{row, rest}: U32.max(nq_uses(kid(row, 0), id), nw_uses(rest, id))

# Module: src/back/native/show.bend:35
@unsafe
def w5c2_nc_atomic_go(is_a: Bool, +k: String) -> U32:
  match is_a:
    case False{}: 0
    case True{}:
      w5c2_u32_pick(String.eq(k, "array_atomic_add"), 1,
      w5c2_u32_pick(String.eq(k, "array_atomic_min"), 2,
      w5c2_u32_pick(String.eq(k, "array_atomic_max"), 3,
      w5c2_u32_pick(String.eq(k, "array_atomic_and"), 4,
      w5c2_u32_pick(String.eq(k, "array_atomic_or"), 5,
      w5c2_u32_pick(String.eq(k, "array_atomic_xor"), 6,
      w5c2_u32_pick(String.eq(k, "array_atomic_exch"), 7,
      w5c2_u32_pick(String.eq(k, "array_atomic_cas"), 8,
      w5c2_u32_pick(String.eq(k, "array_atomic_fadd"), 9, 0)))))))))

def no_effect_foreign_allowed(trusted: Bool, filled: Bool, name: String) -> Bool:
  trusted && filled && no_effect_provider_member(["IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err", "File.open", "File.open_bytes", "File.read", "File.read_line", "File.read_bytes", "File.read_at", "File.size", "File.write", "File.write_bytes", "File.write_at", "File.close"], name)

# Checked observer permission is independent of packed arrays and narrowing.
# The host authenticates Base/runtime/provider bytes; names alone grant nothing.
# Keep the old rewrite refusal. The observer's own typed schema/residual checks
# separately exclude Array roots, allocating Word views and foreign calls.
@unsafe
def nh_add(+key: String, +hot: List<&2, String>) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(hot, key), u => hot, u => Con{key, hot})

# Module: src/back/native/sharing.bend:10
@unsafe
def nc_bangs_terms(
  +ts: List<&2, KTerm>,
) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: List.append(&2, String, nc_bangs_term(h), nc_bangs_terms(rest))

# Module: src/back/native/book.bend:246
@unsafe
def nc_bangs_term(t):
  nt_choose(List<&2, String>, p98_tag_eq(t, "Var"), u => Nil{}, u => nt_choose(List<&2, String>, p98_tag_eq(t, "Ref") && U32.is_eq(qt(t), 3), u => [nm(t)], u => nt_choose(List<&2, String>, p98_tag_eq(t, "Ann"), u => nc_bangs_term(kid(t, 0)), u => nc_bangs_terms(ks(t)))))

# Bang metadata follows the same erased runtime closure as native emission.
# Dead imported definitions must not change scheduling or worker admission.

# Module: src/back/native/book.bend:252
@unsafe
def ns_image_terms_rev(ws: List<&2, String>, terms: List<&2, KTerm>) -> List<&2, KTerm>:
  match ws:
    case Nil{}: nt_reverse(KTerm, terms, Nil{})
    case Con{h, rest}: ns_image_terms_rev(rest, Con{kt("StaticWord", h, 0, 0, Nil{}), terms})

# Exclude constructors with special runtime treatment, including all IO nodes.
# Scalar wrappers only become static after the existing literal pass proves
# them. Exact constructor arity rejects malformed raw graphs.

# Module: src/back/native/static.bend:63
@unsafe
def w7_br_740(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      ns_canonical(nm(t), U32.read(nm(t)))
    case False{}:
      False{}

@unsafe
def no_layout_valid(+layout: NO_Layout) -> Bool:
  match layout:
    case NO_Layout{key, +ctor, +storage, +width}:
      nt_choose(Bool, p88_string_eq(storage, "Boxed"), u => U32.is_ge(width, 2) && Bool.not(nb_contains(["ALeaf", "ANode", "U32", "F32", "Chr", "Succ", "Zero", "True", "False"], ctor)), u =>
      nt_choose(Bool, p88_string_eq(storage, "Succ"), u => p88_string_eq(ctor, "Succ") && U32.is_eq(width, 1), u =>
      nt_choose(Bool, p88_string_eq(storage, "Char"), u => p88_string_eq(ctor, "Chr") && U32.is_eq(width, 1), u =>
        p88_string_eq(storage, "Nullary") && U32.is_eq(width, 0) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode"], ctor)))))

# Module: src/back/native/observer-emitter.bend:49
@unsafe
def no_binders_valid(fields: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+field, rest}: p98_tag_eq(field, "Var") && p88_string_eq(nc_word(ix(field), env), "NATIVE_UNBOUND_VARIABLE") && no_binders_valid(rest, Con{nc_binding(ix(field)), env})

# Module: src/back/native/observer-emitter.bend:55
@unsafe
def no_bind_fields(fields: List<&2, KTerm>, env: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  match fields:
    case Nil{}: env
    case Con{field, rest}: no_bind_fields(rest, Con{nc_binding(ix(field)), env})

# Module: src/back/native/observer-emitter.bend:61
@unsafe
def nol_field_cons(+field: KTerm, +tail: KTerm) -> KTerm:
  w7_br_755(p98_tag_eq(tail, "NO_Types"), field, tail)

# Module: src/back/native/observer-layout.bend:51
@unsafe
def nol_wrap_root(+ty: KTerm, +params: List<&2, KTerm>, roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  match roots:
    case Nil{}: nol_wrap_fail("extra returned root", Nil{}, shells, observation)
    case Con{+index, +rest}:
      +param = terms_at(params, index)
      nt_choose(NOL_Wrap, p88_string_eq(nm(param), nm(ty)), u => NOL_Wrap{param, rest, shells, observation, ""}, u => nol_wrap_fail("root projection order or type", roots, shells, observation))

# Module: src/back/native/observer-layout.bend:191
@unsafe
def no_literal_demanding_ctor(+name: String) -> Bool:
  nb_contains(["Succ", "U32", "F32"], name)

# Module: src/back/native/observer-analysis.bend:28
@unsafe
def w7_br_764(w7_c: Bool, +value: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(value, 0)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def noa_env(+id: U32, xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+x, +rest}: nt_choose(KTerm, U32.is_eq(ix(x), id), u => kid(x, 0), u => noa_env(id, rest))

# Module: src/back/native/observer-analysis.bend:113
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
def noa_field_values(+owner: String, +ctor: String, +origin: KTerm, fields: List<&2, String>, +i: U32, +n: U32) -> List<&2, KTerm>:
  match fields:
    case Nil{}: Nil{}
    case Con{+ty, +rest}: Con{noa_atom(ty, kt("OField", ctor, i, 0, [origin, ref(owner)]), var("", nc_id(n))), noa_field_values(owner, ctor, origin, rest, U32.inc(i), U32.inc(n))}

# Module: src/back/native/observer-analysis.bend:311
@unsafe
def noa_value_words(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{kid(h, 1), noa_value_words(rest)}

# Module: src/back/native/observer-analysis.bend:323
@unsafe
def noa_entry_values(params: List<&2, KTerm>, +i: U32) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{noa_atom(nm(p), kt("OArg", "", i, 0, Nil{}), p), noa_entry_values(rest, U32.inc(i))}

# Module: src/back/native/observer-analysis.bend:364
@unsafe
def noa_actuals(params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: noa_bind(ix(p), a, noa_actuals(ps, rest))
    case _, _: Nil{}

# Module: src/back/native/observer-analysis.bend:436
@unsafe
def no_plan_params(params: List<&2, KTerm>) -> List<&2, NC_Binding>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{nc_binding(ix(p)), no_plan_params(rest)}

# Module: src/back/native/observer-plan.bend:33
@unsafe
def no_plan_refuse(owner: String, +reason: String) -> NO_Plan:
  NO_Plan{owner, NO_Schema{Nil{}, Nil{}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, 0, "", Nil{}, 0, reason}, noa_fail(reason, 0, 4096), reason}

# Module: src/back/native/observer-plan.bend:37
@unsafe
def no_plan_result(name: String, schema: NO_Schema, +analysis: NO_Analysis) -> NO_Plan:
  NO_Plan{name, schema, analysis, noa_error(analysis)}

# Called inside the checked-permission branch, using the existing live/bang lists.

# Module: src/back/native/observer-integration.bend:23
@unsafe
def dr_lines(names):
  match names:
    case Nil{}: ""
    case Con{+name, +rest}: "- " ++ name_key(name) ++ "\n" ++ dr_lines(rest)
@unsafe
def p88_digits(text: String, +acc: U32, +digits: U32) -> P88Number:
  match text:
    case SCon{'\n',tail}: P88Number{P88Cursor{tail,p130m_status(U32.is_ne(digits,0),1)},acc}
    case SCon{Chr{c},tail}:
      +d = U32.sub(c,48)
      p88_digit(tail,acc,digits,d,U32.is_lt(d,10) && U32.is_lt(digits,10) && (U32.is_eq(digits,0) || U32.is_ne(acc,0)) && (U32.is_lt(acc,429496729) || (U32.is_eq(acc,429496729) && U32.is_le(d,5))))
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_digit(text: String, acc: U32, digits: U32, digit: U32, ok: Bool) -> P88Number:
  match ok:
    case True{}: p88_digits(text,U32.add(U32.mul(acc,10),digit),U32.inc(digits))
    case False{}: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_text_gate(text: String, size: U32, mode: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size,text,"",mode)
    case False{}: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, read: P88Number) -> P88Step:
  match read:
    case P88Number{P88Cursor{text,+mode},n}:
      p130m_number_read(nodes,strings,made,sn,begin,end,text,mode,n,p130m_valid(mode))
# Isolated scalar spellings of two closed, fixed-result U32 tables.
# Literal values become scalar equality operands, never literal patterns.
# A finite safe chooser retains p112fp_binary safety and lazy result selection.
@unsafe
def p151_roles(+tag: U32) -> List<&2,U32>:
  p151_choose(List<&2,U32>,U32.is_eq(tag,1),u => [13,14],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,2),u => [3,3,1,1,6,8,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,3),u => [3,1,1,6,8,1,1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,4),u => [3,1,3,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,5),u => [3,3,1,1,4,4,7,2,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,6),u => [1,7],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,7),u => [1,1,5,5],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,8),u => [1,1,1,7,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,9),u => [1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,10),u => [9,7,7,7,7,7,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,11),u => [5,5,1,2],u => [])))))))))))


# Preserve the original plain public argument quantity and unsafe annotation.
@unsafe
def p88_bool_value(state: P88State, n: U32) -> P88Step:
  match n:
    case 0: P88Step{state,P88Bool{False{}}}
    case 1: P88Step{state,P88Bool{True{}}}
    case other: P88Step{p88_state_bad(state),P88Bad{}}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:162
@unsafe
def p88_node_got(cursor: P88Cursor, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, role: U32, pair: Array<P88Node> & P88Node) -> P88Step:
  (nodes, node) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, p88_role_empty(role, node)}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:185
@unsafe
def p88_string_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_string_got(cursor,nodes,made,sn,begin,end,Array.get(String,strings,id))

@unsafe
def p88_build(tag: U32, fields: List<&2,P88Node>, +begin: U32, +end: U32) -> P88Node:
  match tag fields:
    case 0 Nil{}: P88Empty{}
    case 1 Con{P88Term{h}, Con{P88Empty{}, Nil{}}}: P88Terms{[h]}
    case 1 Con{P88Def{h}, Con{P88Empty{}, Nil{}}}: P88Defs{[h]}
    case 1 Con{P88String{h}, Con{P88Empty{}, Nil{}}}: P88Strings{[h]}
    case 1 Con{P88Term{h}, Con{P88Terms{t}, Nil{}}}: P88Terms{Con{h, t}}
    case 1 Con{P88Def{h}, Con{P88Defs{t}, Nil{}}}: P88Defs{Con{h, t}}
    case 1 Con{P88String{h}, Con{P88Strings{t}, Nil{}}}: P88Strings{Con{h, t}}
    case 2 Con{P88String{a}, Con{P88String{b}, Con{P88Word{c}, Con{P88Word{d}, Con{P88Terms{e}, Con{P88Strings{f}, Con{P88Word{+g}, Con{P88Word{+h}, Nil{}}}}}}}}}:
      p88_valid_node(P88Term{KTerm{a,b,c,d,e,f,g,h}}, p88_span(g,h,begin,end))
    case 3 Con{P88String{a}, Con{P88Word{b}, Con{P88Word{c}, Con{P88Terms{d}, Con{P88Strings{e}, Con{P88Word{+f}, Con{P88Word{+g}, Con{P88Bool{h}, Nil{}}}}}}}}}:
      p88_valid_node(P88Term{KLambda{a,b,c,d,e,f,g,h}}, p88_span(f,g,begin,end))
    case 4 Con{P88String{+a}, Con{P88Word{+b}, Con{P88String{+c}, Con{P88Word{+d}, Con{P88Word{+e}, Nil{}}}}}}:
      p88_valid_node(P88Term{KLiteral{a,b,c,d,e}}, p88_span(d,e,begin,end) && ((agy_str_eq(a,"String") && U32.is_eq(b,0)) || ((agy_str_eq(a,"Nat") || agy_str_eq(a,"U32") || agy_str_eq(a,"F32")) && String.is_empty(c))))
    case 5 Con{P88String{a}, Con{P88String{b}, Con{P88Word{c}, Con{P88Word{d}, Con{P88Term{e}, Con{P88Term{f}, Con{P88Defs{g}, Con{P88Bool{h}, Con{P88Bool{i}, Nil{}}}}}}}}}}:
      P88Def{KDef{a,b,c,d,e,f,g,h,i}}
    case 6 Con{P88Word{a}, Con{P88Defs{b}, Nil{}}}: P88Def{KIndexLeaf{a,b}}
    case 7 Con{P88Word{a}, Con{P88Word{b}, Con{P88Def{c}, Con{P88Def{d}, Nil{}}}}}: P88Def{KIndexNode{a,b,c,d}}
    case 8 Con{P88Word{a}, Con{P88Word{b}, Con{P88Word{c}, Con{P88Defs{d}, Con{P88Bool{e}, Nil{}}}}}}: P88Checked{KBasePrefixState{a,b,c,d,e}}
    case 9 Con{P88Word{a}, Con{P88Bool{b}, Nil{}}}: P88Fresh{FFreshPrefixState{a,b}}
    case 10 Con{P88Checked{a}, Con{P88Defs{b}, Con{P88Defs{c}, Con{P88Defs{d}, Con{P88Defs{e}, Con{P88Defs{f}, Con{P88Word{g}, Con{P88Word{h}, Nil{}}}}}}}}}: P88World{KBasePreparedWorld{a,b,c,d,e,f,g,h}}
    case 11 Con{P88Def{a}, Con{P88Def{b}, Con{P88Word{c}, Con{P88Bool{d}, Nil{}}}}}: P88Frontend{FReadyPrefixState{a,b,c,d}}
    case t other: P88Bad{}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:238
@unsafe
def p86_width(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{char, rest}: p86_width(rest, U32.add(count, dg_units(char)))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:420
@unsafe
def p205_pair(+name: String, a: KTerm, b: KTerm) -> KTerm:
  app(app(ref(name),a),b)

# One tail site per owner. Advance the book's checked binder bound after each
# accepted owner, including other passes which mint binders in this request.
@unsafe
def p205_rewrap(+original: KTerm, +child: KTerm, +prefix: List<&2,KTerm>) -> KTerm:
  w7_br_793(p98_tag_eq(child,"Absent"), original, child, prefix)

@unsafe
def w7_br_796(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_children(t,[])
    case False{}:
      k_with_children(t,p205u_clean_fields(ks(t)))

@unsafe
def w7_br_797(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_clean(kid(t,0))
    case False{}:
      w7_br_796(p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"), t)

@unsafe
def p205u_clean( +t: KTerm) -> KTerm:
  w7_br_797(p98_tag_eq(t,"Ann"), t)
@unsafe
def p205u_clean_fields( +xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{p205u_clean(x),p205u_clean_fields(rest)}

@unsafe
def w5c3_refs_if(is_ref: Bool, +t: KTerm, +name: String) -> U32:
  match is_ref:
    case True{}: w5c3_b2u(String.eq(nm(t),name))
    case False{}: p205u_refs_fields(ks(t),name)

@unsafe
def p205u_refs(+t: KTerm, +name: String) -> U32:
  w5c3_refs_if(p98_tag_eq(t,"Ref"), t, name)

@unsafe
def w5c3_refs_rest(sat: Bool, +c: U32, rest: List<&2,KTerm>, +name: String) -> U32:
  match sat:
    case True{}: 2
    case False{}: U32.min(2,U32.add(c,p205u_refs_fields(rest,name)))

@unsafe
def p205u_refs_fields(+xs: List<&2,KTerm>, +name: String) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}:
      +c = p205u_refs(x,name)
      w5c3_refs_rest(U32.is_ge(c,2), c, rest, name)

@unsafe
def w5c3_vars_if(is_var: Bool, +t: KTerm, +id: U32) -> U32:
  match is_var:
    case True{}: w5c3_b2u(U32.is_eq(ix(t),id))
    case False{}: p205u_vars_fields(ks(t),id)

@unsafe
def p205u_vars(+t: KTerm, +id: U32) -> U32:
  w5c3_vars_if(p98_tag_eq(t,"Var"), t, id)

@unsafe
def w5c3_vars_rest(sat: Bool, +c: U32, rest: List<&2,KTerm>, +id: U32) -> U32:
  match sat:
    case True{}: 2
    case False{}: U32.min(2,U32.add(c,p205u_vars_fields(rest,id)))

@unsafe
def p205u_vars_fields(+xs: List<&2,KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}:
      +c = p205u_vars(x,id)
      w5c3_vars_rest(U32.is_ge(c,2), c, rest, id)

@unsafe
def p205u_at( +xs: List<&2,KTerm>, +index: U32) -> KTerm:
  match xs index:
    case Con{x,rest} 0: x
    case Con{x,rest} _: p205u_at(rest,U32.sub(index,1))
    case _ _: atom("Absent")

# Leading dynamic parameters are allowed (packet state before the String).
@unsafe
def p205u_headshape( +t: KTerm, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool,U32.is_eq(fuel,0),u => False{},u =>
  kc(Bool,p98_tag_eq(body,"Lam"),v => p205u_headshape(kid(body,0),U32.sub(fuel,1)),v =>
    p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil")))
@unsafe
def p205u_literal_good( +t: KTerm) -> Bool:
  Bool.not(p98_tag_eq(t,"Absent")) && p205u_length(kl_text(t),64)
@unsafe
def p205u_typed_arg(+arg: KTerm, +ty: KTerm) -> KTerm:
  w7_br_815(p98_tag_eq(ty,"Absent"), arg, ty)

@unsafe
def p205u_finished( +result: P205UResult) -> KTerm:
  match result:
    case P205UResult{term,next,steps,ok}:
      kc(KTerm,ok && U32.is_gt(steps,0) && U32.is_gt(nq_layout_remaining([term],8193),0),u => term,u => atom("Absent"))
# Bound the semantic input walk before cleaning; cached Var/type shadows are
# not executable syntax. This also avoids name lookup for ordinary leaves.
@unsafe
def w5c3_p205u_ch_ann(is_ann: Bool, +t: KTerm) -> List<&2,KTerm>:
  match is_ann:
    case True{}: [kid(t,0)]
    case False{}: w5c3_p205u_ch_leaf(p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"), t)

@unsafe
def w7_br_827(w7_c: Bool, +name: String) -> U32:
  match w7_c:
    case True{}:
      2
    case False{}:
      w7_br_826(agy_str_eq(name, "u32_inc") || agy_str_eq(name, "u32_dec") || agy_str_eq(name, "u32_is_zero") || agy_str_eq(name, "u32_to_nat") || agy_str_eq(name, "u32_from_nat") || agy_str_eq(name, "u32_to_f32") || agy_str_eq(name, "f32_to_u32") || agy_str_eq(name, "f32_neg") || agy_str_eq(name, "f32_abs") || agy_str_eq(name, "f32_bits"))

law ctfe_as_nat:
  for +v: CtfeVal
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def ctfe_as_nat_succ(fields: List<&2, CtfeVal>, +acc: U32) -> Maybe<&2, U32>:
  match fields:
    case Con{inner, Nil{}}:
      kc(Maybe<&2, U32>, U32.is_lt(acc, 4294967295),
        u => ctfe_as_nat(inner, U32.inc(acc)),
        u => None{})
    case _: None{}

@unsafe
def ctfe_as_nat(v, acc):
  match v:
    case CVNat{n}:
      kc(Maybe<&2, U32>, U32.is_le(acc, U32.sub(4294967295, n)),
        u => Some{U32.add(acc, n)},
        u => None{})
    case CVCtr{name, fields}:
      kc(Maybe<&2, U32>, agy_str_eq(name, "Zero"), u => ctfe_as_nat_zero(fields, acc),
        u => kc(Maybe<&2, U32>, agy_str_eq(name, "Succ"), v => ctfe_as_nat_succ(fields, acc), v => None{}))
    case _: None{}

@unsafe
def w7_br_830(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_cmp(U32.cmp(a, b))
    case False{}:
      CVFail{}

@unsafe
def w7_br_849(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_cmp(U32.cmp(a, b))
    case False{}:
      CVFail{}

@unsafe
def w7_br_858(w7_c: Bool, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_ge(a, b))
    case False{}:
      CVFail{}

@unsafe
def w7_br_869(w7_c: Bool, +n: U32, +bits: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVCtr{"WNil", []}
    case False{}:
      CVCtr{"WCon", [ctfe_bool(U32.is_ne(U32.and(n, 1), 0)), ctfe_word_bits(U32.shrn(n, 1n), U32.sub(bits, 1))]}

@unsafe
def ctfe_word_bits(+n: U32, +bits: U32) -> CtfeVal:
  w7_br_869(U32.is_eq(bits, 0), n, bits)

@unsafe
def ctfe_pack_word(+cname: String, +vs: List<&2, CtfeVal>, m: Maybe<&2, U32>) -> CtfeVal:
  match m:
    case Some{+n}: kc(CtfeVal, agy_str_eq(cname, "U32"), u => CVU32{n}, u => CVF32{ctfe_bits_to_f32(n)})
    case None{}: CVCtr{cname, vs}

@unsafe
def ctfe_eval_lit(+t: KTerm, +fuel: U32) -> CtfeRes:
  +k = nm(t)
  kc(CtfeRes, agy_str_eq(k, "U32"), u => CtfeRes{CVU32{kl_number(t)}, fuel}, u =>
  kc(CtfeRes, agy_str_eq(k, "Nat"), u => CtfeRes{CVNat{kl_number(t)}, fuel}, u =>
  kc(CtfeRes, agy_str_eq(k, "F32"), u => CtfeRes{CVF32{ctfe_bits_to_f32(kl_number(t))}, fuel}, u =>
  kc(CtfeRes, agy_str_eq(k, "String"), u => CtfeRes{CVStr{kl_text(t)}, fuel}, u => ctfe_fail(fuel)))))

law ctfe_str_val:
  for +v: CtfeVal
  for +limit: U32
  Maybe<&2, String>

@unsafe
def ctfe_str_scon(fields: List<&2, CtfeVal>, +limit: U32) -> Maybe<&2, String>:
  match fields:
    case Con{CVCtr{cn2, Con{CVU32{code}, Nil{}}}, Con{rest, Nil{}}}:
      kc(Maybe<&2, String>, agy_str_eq(cn2, "Chr"),
        w => ctfe_str_cons(code, ctfe_str_val(rest, U32.sub(limit, 1))),
        w => None{})
    case _: None{}

@unsafe
def ctfe_str_val_go(v: CtfeVal, +limit: U32) -> Maybe<&2, String>:
  match v:
    case CVStr{+s}: kc(Maybe<&2, String>, U32.is_le(U32.from_nat(String.length(s)), limit), w => Some{s}, w => None{})
    case CVCtr{+cname, fields}:
      kc(Maybe<&2, String>, agy_str_eq(cname, "SNil"), u => Some{""},
        u => kc(Maybe<&2, String>, agy_str_eq(cname, "SCon"), w => ctfe_str_scon(fields, limit), w => None{}))
    case _: None{}

@unsafe
def ctfe_str_val(v, limit):
  kc(Maybe<&2, String>, U32.is_eq(limit, 0), u => None{}, u => ctfe_str_val_go(v, limit))

@unsafe
def ctfe_reify_u32(v: CtfeVal) -> KTerm:
  match v:
    case CVU32{n}: KLiteral{"U32", n, "", 0, 0}
    case _: atom("Absent")

@unsafe
def ctfe_reify_nat(m: Maybe<&2, U32>) -> KTerm:
  match m:
    case Some{n}: KLiteral{"Nat", n, "", 0, 0}
    case None{}: atom("Absent")

@unsafe
def ctfe_reify_f32(v: CtfeVal) -> KTerm:
  match v:
    case CVF32{x}: KLiteral{"F32", F32.bits(x), "", 0, 0}
    case _: atom("Absent")

@unsafe
def ctfe_reify_bool(v: CtfeVal) -> KTerm:
  match v:
    case CVCtr{+cn, Nil{}}: kc(KTerm, agy_str_eq(cn, "True") || agy_str_eq(cn, "False"), w => kt("Ctr", cn, 0, 1, []), w => atom("Absent"))
    case _: atom("Absent")

@unsafe
def ctfe_reify_char(v: CtfeVal) -> KTerm:
  match v:
    case CVCtr{cn, Con{CVU32{code}, Nil{}}}: kc(KTerm, agy_str_eq(cn, "Chr"), w => kt("Ctr", "Chr", 0, 1, [KLiteral{"U32", code, "", 0, 0}]), w => atom("Absent"))
    case _: atom("Absent")

@unsafe
def ctfe_reify_str(m: Maybe<&2, String>) -> KTerm:
  match m:
    case Some{s}: KLiteral{"String", 0, s, 0, 0}
    case None{}: atom("Absent")

@unsafe
def agy_abs_apps(+f: KTerm, args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: f
    case Con{a,rest}: agy_abs_apps(app(f,a),rest)

@unsafe
def w7_br_880(w7_c: Bool, +t: KTerm, +n: U32) -> AgyAbsPeel:
  match w7_c:
    case True{}:
      agy_abs_peel_cons(t,agy_abs_peel(kid(t,0),U32.sub(n,1)))
    case False{}:
      AgyAbsPeel{[],t,False{}}

@unsafe
def w7_br_881(w7_c: Bool, +t: KTerm, +n: U32) -> AgyAbsPeel:
  match w7_c:
    case True{}:
      AgyAbsPeel{[],t,True{}}
    case False{}:
      w7_br_880(p98_tag_eq(t,"Lam"), t, n)

@unsafe
def agy_abs_peel(+t: KTerm, +n: U32) -> AgyAbsPeel:
  w7_br_881(U32.is_eq(n,0), t, n)

@unsafe
def agy_abs_check_rest_inv(args: List<&2,KTerm>, r_lams: List<&2,KTerm>) -> Bool:
  match args r_lams:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+l,lr}: agy_abs_is_var(a,ix(l)) && agy_abs_check_rest_inv(ar,lr)
    case _ _: False{}

@unsafe
def agy_abs_check_step_args(+sargs: List<&2,KTerm>, +r_lams: List<&2,KTerm>, +st_idx: U32, +st_id: U32) -> Bool:
  match sargs:
    case Nil{}: False{}
    case Con{+a,Nil{}}: agy_abs_is_var(a,st_id)
    case Con{+a,+rest}:
      p98_tag_eq(a,"Var") && agy_abs_in_inv(r_lams,st_idx,0,ix(a)) && agy_abs_check_step_args(rest,r_lams,st_idx,st_id)

@unsafe
def agy_abs_hole_terms(hs: List<&2,U32>) -> List<&2,KTerm>:
  match hs:
    case Nil{}: []
    case Con{h,rest}: Con{agy_abs_hole(h),agy_abs_hole_terms(rest)}

@unsafe
def agy_abs_build_args(r_lams: List<&2,KTerm>, +st_idx: U32, +cur: U32, +next_st: KTerm) -> List<&2,KTerm>:
  match r_lams:
    case Nil{}: []
    case Con{+l,rest}:
      Con{kc(KTerm,U32.is_eq(cur,st_idx),u => next_st,u => var(nm(l),ix(l))),
        agy_abs_build_args(rest,st_idx,U32.inc(cur),next_st)}

@unsafe
def agy_abs_walk_lam_join(+m: KTerm, +w_body: AgyAbsWalk) -> AgyAbsWalk:
  match w_body:
    case AgyAbsWalk{body2,hit,ok}:
      AgyAbsWalk{agy_abs_lam(nm(m),ix(m),qt(m),body2),hit,ok}

@unsafe
def agy_abs_wrap_lams(lams: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match lams:
    case Nil{}: body
    case Con{+l,rest}: agy_abs_lam(nm(l),ix(l),qt(l),agy_abs_wrap_lams(rest,body))

@unsafe
def agy_bf_apps(+f: KTerm, args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: f
    case Con{a,rest}: agy_bf_apps(app(f,a),rest)

@unsafe
def w7_br_891(w7_c: Bool, +t: KTerm, +n: U32) -> AgyPeel:
  match w7_c:
    case True{}:
      agy_bf_peel_cons(t,agy_bf_peel(kid(t,0),U32.sub(n,1)))
    case False{}:
      AgyPeel{[],t,False{}}

@unsafe
def w7_br_892(w7_c: Bool, +t: KTerm, +n: U32) -> AgyPeel:
  match w7_c:
    case True{}:
      AgyPeel{[],t,True{}}
    case False{}:
      w7_br_891(p98_tag_eq(t,"Lam"), t, n)

@unsafe
def agy_bf_peel(+t: KTerm, +n: U32) -> AgyPeel:
  w7_br_892(U32.is_eq(n,0), t, n)

@unsafe
def agy_bf_vars_match(args: List<&2,KTerm>, lams: List<&2,KTerm>) -> Bool:
  match args lams:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{l,lr}: agy_bf_is_var(a,ix(l)) && agy_bf_vars_match(ar,lr)
    case _ _: False{}

@unsafe
def agy_bf_is_shln_args(+a0: KTerm, +a1: KTerm, +pid: U32) -> AgyStep:
  w7_br_893(core_literal(a0) && agy_str_eq(nm(a0),"U32") && agy_bf_is_var(a1,pid), a0)

law agy_bf_rename_list:
  for xs: List<&2,KTerm>
  for +old: String
  for +nw: String
  List<&2,KTerm>

@unsafe
def w7_br_898(w7_c: Bool, +t: KTerm, +old: String, +nw: String) -> KTerm:
  match w7_c:
    case True{}:
      ref(nw)
    case False{}:
      k_with_children(t,agy_bf_rename_list(ks(t),old,nw))

@unsafe
def agy_bf_rename_ref(+t: KTerm, +old: String, +nw: String) -> KTerm:
  w7_br_898(p98_tag_eq(t,"Ref") && agy_str_eq(nm(t),old), t, old, nw)

@unsafe
def agy_bf_rename_list(xs, old, nw):
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{agy_bf_rename_ref(x,old,nw),agy_bf_rename_list(rest,old,nw)}

@unsafe
def agy_bf_lams_to_vars(lams: List<&2,KTerm>) -> List<&2,KTerm>:
  match lams:
    case Nil{}: []
    case Con{+l,rest}: Con{var(nm(l),ix(l)),agy_bf_lams_to_vars(rest)}

@unsafe
def agy_bf_wrap_lams(lams: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match lams:
    case Nil{}: body
    case Con{+l,rest}: agy_bf_lam(nm(l),ix(l),2,agy_bf_wrap_lams(rest,body))

@unsafe
def agy_bf_fresh_lams(+n: U32, +base_id: U32, +idx: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>,U32.is_eq(idx,n),u => [],
    u => Con{var("agy_p" ++ U32.show(idx),U32.add(base_id,idx)),agy_bf_fresh_lams(n,base_id,U32.inc(idx))})

@unsafe
def agy_bf_wrap_vars(vs: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match vs:
    case Nil{}: body
    case Con{+v,rest}: agy_bf_lam(nm(v),ix(v),2,agy_bf_wrap_vars(rest,body))

@unsafe
def agy_bf_loop_type(+orig_ty: KTerm, +acc_id: U32) -> KTerm:
  +t0 = j_strip(orig_ty)
  +t1 = j_strip(kid(t0,1))
  all(2,nm(t0),ix(t0),kid(t0,0),
    all(2,nm(t1),ix(t1),kid(t1,0),
      all(2,"agy_acc",acc_id,ref("U32"),kid(t1,1))))

@unsafe
def agy_bf_disp_type(+orig_ty: KTerm, +cond_id: U32) -> KTerm:
  all(1,"$agy_c",cond_id,ref("Nat"),j_strip(orig_ty))

@unsafe
def p205v_any(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205v_static(x) || p205v_any(rest)
@unsafe
def w5c3_ar_or(m: Bool, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.or(a,b),"",0,0}
    case False{}: atom("Absent")

@unsafe
def w5c2_rcmp_tf(yes: Bool, no: Bool) -> KTerm:
  match yes:
    case True{}: p205v_bool(True{})
    case False{}:
      match no:
        case True{}: p205v_bool(False{})
        case False{}: atom("Absent")

@unsafe
def w5c2_rcmp_b(ok: Bool, +val: Bool) -> KTerm:
  match ok:
    case True{}: p205v_bool(val)
    case False{}: atom("Absent")

@unsafe
def w5c3_bval_true(m: Bool, +n: String) -> U32:
  match m:
    case True{}: 2
    case False{}: w5c3_bval_false(String.eq(n,"False"))

@unsafe
def w5c3_fb_and4(m: Bool) -> KTerm:
  match m:
    case True{}: p205v_bool(False{})
    case False{}: atom("Absent")

@unsafe
def w5c3_fb_or4(m: Bool) -> KTerm:
  match m:
    case True{}: p205v_bool(True{})
    case False{}: atom("Absent")

@unsafe
def w5c3_mspine_if(is_app: Bool, +t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  match is_app:
    case True{}: p205v_mat_spine(kid(t,0),Con{kid(t,1),args})
    case False{}: P205UFields{Con{t,args},0,0,True{}}

@unsafe
def p205v_mat_spine(+t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  w5c3_mspine_if(p98_tag_eq(t,"App"), t, args)

@unsafe
def p205v_dist_wrap(+old: KTerm, +arg: KTerm, +r: P205UResult) -> P205UResult:
  match r:
    case P205UResult{m2,next,steps,ok}:
      kc(P205UResult,ok,u => P205UResult{app(m2,arg),next,steps,True{}},u => P205UResult{old,next,steps,True{}})

@unsafe
def p205v_finish(+old: KTerm, +result: P205UResult) -> KTerm:
  match result:
    case P205UResult{term,next,steps,ok}:
      kc(KTerm,ok && U32.is_gt(nq_layout_remaining([term],32769),0),u => term,u => old)

@unsafe
def w2d_last(xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{x,Nil{}}: x
    case Con{x,rest}: w2d_last(rest)

@unsafe
def w2d_fold_chr_res(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +mchr: KTerm, +lc: KTerm, +r: W2StepExtract) -> W2Fold:
  match r:
    case W2StepExtract{step_body,True{}}:
      W2Fold{fname,st_ty,nil_br,k_with_children(mchr,[k_with_children(lc,[step_body]),kid(mchr,1)]),True{}}
    case _: W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}

@unsafe
def w2d_fold_lam_res(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +lch: KTerm, +r: W2StepExtract) -> W2Fold:
  match r:
    case W2StepExtract{step_body,True{}}:
      W2Fold{fname,st_ty,nil_br,k_with_children(lch,[step_body]),True{}}
    case _: W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}

@unsafe
def w2d_peel_lets(+t: KTerm) -> W2Lets:
  +s = j_strip(t)
  kc(W2Lets,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2) && p98_tag_eq(kid(s,0),"Bind"),
    u => w2d_peel_lets_cons(kid(s,0),w2d_peel_lets(kid(s,1))),
    u => W2Lets{[],s})

@unsafe
def w7_br_920(w7_c: Bool, +pname: String, +ar: U32, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +call: KTerm) -> W2Builder:
  match w7_c:
    case True{}:
      W2Builder{pname,ar,True{},lams0,lams1,bs,ch_expr,w2d_init(ks(call)),True{}}
    case False{}:
      W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}}

@unsafe
def w2d_builder_fused_ty(+t: KTerm, +rem: U32, +st_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,U32.is_eq(rem,1),
    u => all(2,nm(s),ix(s),st_ty,st_ty),
    u => all(qt(s),nm(s),ix(s),kid(s,0),w2d_builder_fused_ty(kid(s,1),U32.sub(rem,1),st_ty)))

# ==============================================================================
# General Constructor-Loop Unboxing
# ==============================================================================
@unsafe
def w7_br_922(w7_c: Bool, +cname: String, +hid: U32, +rargs: List<&2,KTerm>, +m_expr: KTerm) -> W2UnboxArm:
  match w7_c:
    case True{}:
      W2UnboxArm{cname,hid,kid(m_expr,0),rargs,True{}}
    case False{}:
      W2UnboxArm{"",0,atom("Absent"),[],False{}}

@unsafe
def w2d_strip_alls(+t: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"All"),u => w2d_strip_alls(kid(s,1)),u => s)

@unsafe
def w2d_ann_mat_res(+sm: KTerm, +ty: KTerm) -> KTerm:
  w7_br_930(p98_tag_eq(ty,"Absent"), sm, ty)

@unsafe
def w2d_is_mat_head(+t: KTerm) -> Bool:
  +s = j_strip(t)
  kc(Bool,p98_tag_eq(s,"Mat"),u => True{},u =>
    kc(Bool,p98_tag_eq(s,"App"),v => w2d_is_mat_head(kid(s,0)),v => False{}))

@unsafe
def w2d_pim_app(+arg: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{m2,n1}: FFresh{app(m2,arg),n1}

@unsafe
def w2d_pim_leaf(+leaf: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{fn_f,n1}: FFresh{app(fn_f,leaf),n1}

@unsafe
def w2d_senv_get(+senv: List<&2,W2Bind>, +id: U32) -> KTerm:
  match senv:
    case Nil{}: atom("Absent")
    case Con{W2Bind{bid,rhs},rest}:
      kc(KTerm,U32.is_eq(bid,id),u => rhs,u => w2d_senv_get(rest,id))

@unsafe
def w2d_mat_add_lam(+m: KTerm, +acc_id: U32) -> KTerm:
  +s = j_strip(m)
  kc(KTerm,p98_tag_eq(s,"Efq"),u => s,u =>
  kc(KTerm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    v => k_with_children(s,[w2d_mat_add_lam(kid(s,0),acc_id),w2d_mat_add_lam(kid(s,1),acc_id)]),
    v => agy_bf_lam("$w2acc",acc_id,2,s)))

@unsafe
def w5c3_w2d_ann_out(ch2: Bool, +orig: KTerm, +t2: KTerm) -> KTerm:
  match ch2:
    case True{}: kt("Ann","",0,0,[t2,kid(orig,1)])
    case False{}: orig

@unsafe
def p86_read_more(pair: File & Result<&1,&1,U32 & String,String>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{text}:
      do IO<String>:
        tail : File & Result<&1,&1,U32 & String,String> <- File.read(file, 1)
        p86_read_eof(tail, text)
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:714
@unsafe
def nbc_closed(+t: KTerm, +bound: List<&2, NC_Binding>) -> Bool:
  nt_choose(Bool, core_literal(t), u => p88_string_eq(nm(t), "Nat") || p88_string_eq(nm(t), "U32") || p88_string_eq(nm(t), "F32"), u =>
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => U32.is_eq(terms_len(ks(t)), 0) && Bool.not(p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE")), u =>
  nt_choose(Bool, p98_tag_eq(t, "Lam") && U32.is_eq(terms_len(ks(t)), 1), u =>
    nt_choose(Bool, p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE"), v => nbc_closed(kid(t, 0), Con{nc_binding(ix(t)), bound}), v => False{}), u =>
  nt_choose(Bool, (p98_tag_eq(t, "App") || (p98_tag_eq(t, "Mat") && U32.is_eq(ix(t), 1))) && U32.is_eq(terms_len(ks(t)), 2), u =>
    nbc_closed(kid(t, 0), bound) && nbc_closed(kid(t, 1), bound), u =>
  nt_choose(Bool, p98_tag_eq(t, "NWord") && U32.is_eq(terms_len(ks(t)), 0),
    u => ns_canonical(nm(t), U32.read(nm(t))),
    u => (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Efq")) && U32.is_eq(terms_len(ks(t)), 0))))))

# The erased source retains KLiteral leaves; structured native lowering uses
# NWord. Compact only the bounded callee, never substituted caller callbacks.
# Precheck excludes String literals before compaction: one literal leaf could
# otherwise expand into an unbounded string spine. Unknown kinds stay refused.
# The old unbounded/unknown/foreign fallbacks remain exactly Absent.

@unsafe
def ntr_sequence(+name: String, +fields: U32, xs: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match xs:
    case Nil{}: kt("NTRCons", name, fields, 0, nt_reverse(KTerm, acc, Nil{}))
    case Con{h, rest}: nc_mklet(nc_id(n), h, ntr_sequence(name, fields, rest, Con{var("", nc_id(n)), acc}, U32.inc(n)))


# Phase111 module: selfhost/tools/performance/phase111/segment/model.bend
# Structured CPU segment IR. Values are machine words, never C expressions.
# Binary typ is operand width; comparisons produce U32. Offsets are bytes.
@unsafe
def p111_show_join(+a: P111ShowDesc, +b: P111ShowDesc) -> P111ShowDesc:
  P111ShowDesc{List.append(&2, P111ShowCell, p111_show_cells(a), p111_show_cells(b)), p111_show_types(b),
    nt_choose(String, agy_str_eq(p111_show_error(a), ""), u => p111_show_error(b), u => p111_show_error(a))}

@unsafe
def p111_show_array(+d: P111ShowDesc) -> P111ShowDesc:
  P111ShowDesc{Con{P111ShowWord{6}, List.append(&2, P111ShowCell, p111_show_cells(d), [P111ShowWord{0}])}, p111_show_types(d), p111_show_error(d)}

@unsafe
def p111_show_ctor_id(+name: String, constructors: List<&2, N_Constructor>, +i: U32) -> U32:
  match constructors:
    case Nil{}: 4294967295
    case Con{N_Constructor{key, arity, hot}, +rest}:
      nt_choose(U32, agy_str_eq(name, key), u => i, u => p111_show_ctor_id(name, rest, U32.inc(i)))

@unsafe
def p111_show_offset(offsets: List<&2, U32>, +i: U32) -> U32:
  match offsets:
    case Nil{}: 4294967295
    case Con{+head, +rest}: nt_choose(U32, U32.is_eq(i, 0), u => head, u => p111_show_offset(rest, U32.sub(i, 1)))

@unsafe
def p111_show_resolved(+value: U32, +error: String) -> P111ShowWords:
  nt_choose(P111ShowWords, U32.is_eq(value, 4294967295), u => P111ShowWords{Nil{}, error}, u => P111ShowWords{[value], ""})

@unsafe
def p111_show_words_join(a: P111ShowWords, b: P111ShowWords) -> P111ShowWords:
  match a b:
    case P111ShowWords{first, +error_a} P111ShowWords{second, +error_b}:
      P111ShowWords{List.append(&2, U32, first, second), nt_choose(String, agy_str_eq(error_a, ""), u => error_b, u => error_a)}

@unsafe
def w5c2_opid_u2(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "u32_inc"), 13,
  w5c2_u32_pick(String.eq(k, "u32_shl"), 14,
  w5c2_u32_pick(String.eq(k, "u32_shr"), 15,
  w5c2_u32_pick(String.eq(k, "u32_shln"), 16,
  w5c2_u32_pick(String.eq(k, "u32_shrn"), 17,
  w5c2_u32_pick(String.eq(k, "u32_div"), 18,
  w5c2_u32_pick(String.eq(k, "u32_mod"), 19,
  w5c2_u32_pick(String.eq(k, "u32_not"), 20,
  w5c2_u32_pick(String.eq(k, "u32_is_zero"), 21,
  w5c2_u32_pick(String.eq(k, "u32_cmp"), 22,
  w5c2_u32_pick(String.eq(k, "u32_to_f32"), 23,
  w5c2_u32_pick(String.eq(k, "u32_to_nat"), 24,
  w5c2_u32_pick(String.eq(k, "u32_from_nat"), 25, 0)))))))))))))

@unsafe
def w5c2_opid_f3(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_floor"), 50,
  w5c2_u32_pick(String.eq(k, "f32_ceil"), 51,
  w5c2_u32_pick(String.eq(k, "f32_trunc"), 52,
  w5c2_u32_pick(String.eq(k, "f32_abs"), 53,
  w5c2_u32_pick(String.eq(k, "f32_pow"), 54,
  w5c2_u32_pick(String.eq(k, "f32_atan2"), 55,
  w5c2_u32_pick(String.eq(k, "f32_mod"), 56,
  w5c2_u32_pick(String.eq(k, "f32_neg"), 57,
  w5c2_u32_pick(String.eq(k, "f32_to_u32"), 58,
  w5c2_u32_pick(String.eq(k, "f32_bits"), 59,
  w5c2_u32_pick(String.eq(k, "f32_show"), 60,
  w5c2_u32_pick(String.eq(k, "f32_read"), 61, 0))))))))))))

@unsafe
def w5c2_opid_n(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "nat_add"), 62,
  w5c2_u32_pick(String.eq(k, "nat_sub"), 63,
  w5c2_u32_pick(String.eq(k, "nat_mul"), 64,
  w5c2_u32_pick(String.eq(k, "nat_double"), 65,
  w5c2_u32_pick(String.eq(k, "nat_cmp"), 66,
  w5c2_u32_pick(String.eq(k, "nat_is_lt"), 67,
  w5c2_u32_pick(String.eq(k, "nat_divmod"), 70, 0)))))))

@unsafe
def w5c2_opid_a(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "array_new"), 71,
  w5c2_u32_pick(String.eq(k, "array_get"), 72,
  w5c2_u32_pick(String.eq(k, "array_set"), 73,
  w5c2_u32_pick(String.eq(k, "array_swap"), 74,
  w5c2_u32_pick(String.eq(k, "array_size"), 75,
  w5c2_u32_pick(String.eq(k, "array_clone"), 76,
  w5c2_u32_pick(String.eq(k, "array_atomic_add"), 77,
  w5c2_u32_pick(String.eq(k, "array_atomic_min"), 78,
  w5c2_u32_pick(String.eq(k, "array_atomic_max"), 79,
  w5c2_u32_pick(String.eq(k, "array_atomic_and"), 80,
  w5c2_u32_pick(String.eq(k, "array_atomic_or"), 81,
  w5c2_u32_pick(String.eq(k, "array_atomic_xor"), 82,
  w5c2_u32_pick(String.eq(k, "array_atomic_exch"), 83,
  w5c2_u32_pick(String.eq(k, "array_atomic_cas"), 84,
  w5c2_u32_pick(String.eq(k, "array_atomic_fadd"), 85, 0)))))))))))))))

@unsafe
def w5c2_opid_b(ok: Bool, +k: String) -> U32:
  match ok:
    case True{}: w5c2_u32_pick(String.eq(k, "bool_or"), 68, w5c2_u32_pick(String.eq(k, "bool_xor"), 69, 0))
    case False{}: 0

@unsafe
def p111_values(args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match args:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{N111Local{nc_word(ix(h), env)}, p111_values(rest, env)}

@unsafe
def p111_return(+value: N111Value, +n: U32) -> P111Code:
  P111Code{[N111Store{N111U64{}, N111Local{"scratch"}, 0, value}, N111Call{"reply", N111U64{}, "p111_rt_return", [p111_state(), p111_scratch(), p111_u32(1)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def w5c2_part_nonown(no: Bool, +word: String, +live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>) -> P111Partition:
  match no:
    case True{}: P111Partition{live, drop}
    case False{}: P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}}

law p111_keep:
  for env: List<&2, NC_Binding>
  for +uses: NU_Set
  List<&2, N111Stmt>

@unsafe
def w5c2_p111_keep_if(keep: Bool, +word: String, rest: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match keep:
    case True{}: Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}
    case False{}: p111_keep(rest, uses)

@unsafe
def p111_keep(env, uses):
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, rest}:
      w5c2_p111_keep_if(nu_has(uses, id) && Bool.not(p112to_nonowning(kind)), word, rest, uses)

@unsafe
def p111_params(params: List<&2, NC_Binding>, +held: U32, +capture: U32, +reg: U32) -> List<&2, N111Stmt>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, U32.is_lt(capture, held),
        u => Con{N111Call{word, N111U64{}, "p111_rt_stack_get", [p111_state(), p111_u32(capture)]}, p111_params(rest, held, U32.inc(capture), reg)},
        u => Con{N111Call{word, N111U64{}, "p111_rt_reg_get", [p111_state(), p111_u32(reg)]}, p111_params(rest, held, capture, U32.inc(reg))})

@unsafe
def p111_load_fields(+count: U32, +i: U32, +n: U32) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_eq(count, i), u => Nil{},
    u => Con{N111Load{"v_" ++ U32.show(nc_id(U32.add(n, i))), N111U64{}, N111Local{"scratch"}, U32.mul(i, 8)}, p111_load_fields(count, U32.inc(i), n)})

@unsafe
def p111_field_env(+count: U32, +i: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, i), u => Nil{}, u => Con{nc_binding(nc_id(U32.add(n, i))), p111_field_env(count, U32.inc(i), n)})

@unsafe
def p111_apply(+values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{[N111Call{"reply", N111U64{}, "p111_rt_apply", [p111_state(), p111_word(p111_head(values)), p111_word(p111_head(p111_tail(values)))]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def p111_guard_io(+name: String, +word: N111Value, +body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, agy_str_eq(name, "Emit") || agy_str_eq(name, "Halt"),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"tag_hit", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Emit"}}, N111Bin{"tag_other", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Halt"}}, N111Bin{"valid_tag", N111U32{}, "or", N111Local{"tag_hit"}, N111Local{"tag_other"}}, N111If{N111Local{"valid_tag"}, body, [N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(2)]}, N111Return{N111Local{"reply"}}]}],
    u => body)

@unsafe
def p111_mark_segments(segments: List<&2, N111Segment>, +bang: Bool) -> List<&2, N111Segment>:
  match segments:
    case Nil{}: Nil{}
    case Con{N111Segment{name, arity, result, incoming, flags, body}, rest}:
      Con{N111Segment{name, arity, result, incoming, nt_bool(bang), body}, p111_mark_segments(rest, bang)}

# Native primitives win before Foreign/Absent, exactly as nc_definition_plain.
@unsafe
def p111_runtime_effects(effects: List<&2, String>, +available: List<&2, String>) -> String:
  match effects:
    case Nil{}: ""
    case Con{+name, +rest}:
      nt_choose(String, nb_contains(available, name),
        u => p111_runtime_effects(rest, available),
        u => "foreign provider unavailable in fixed runtime: " ++ name)

@unsafe
def p111v_raw_name(+name: String) -> Bool:
  p111v_raw_name_chars(name,0)

@unsafe
def p111v_operator(+op: String) -> Bool:
  p111v_comparison(op) || String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
  String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") ||
  String.eq(op,"shr") || String.eq(op,"sar")

law w5c3_find_bucket:
  for +tree: KDef
  for +hash: U32
  List<&2,KDef>

@unsafe
def w5c3_fb_lr(go_left: Bool, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match go_left:
    case True{}: w5c3_find_bucket(ra, hash)
    case False{}: w5c3_find_bucket(rb, hash)

@unsafe
def w5c3_fb_pref(ok: Bool, +rm: U32, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match ok:
    case False{}: Nil{}
    case True{}: w5c3_fb_lr(U32.is_eq(U32.and(hash, rm), 0), ra, rb, hash)

@unsafe
def w5c3_fb_node(z: Bool, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +hash: U32) -> List<&2,KDef>:
  match z:
    case True{}: w5c3_fb_leaf(U32.is_eq(rh, hash), [ra, rb])
    case False{}: w5c3_fb_pref(U32.is_eq(U32.and(U32.xor(hash, rh), U32.sub(rm, 1)), 0), rm, ra, rb, hash)

@unsafe
def w5c3_find_bucket(tree, hash):
  match tree:
    case KIndexLeaf{rh, rb}: w5c3_fb_leaf(U32.is_eq(rh, hash), rb)
    case KIndexNode{rh, +rm, +ra, +rb}: w5c3_fb_node(U32.is_eq(rm, 0), rh, rm, ra, rb, hash)
    case _: Nil{}

@unsafe
def w5c3_sig16(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1,2]
    case False{}: w5c3_sig17(String.eq(s,"p111_rt_special_take"))

def p111v_literal(value: N111Value) -> U32:
  match value:
    case N111Const{lo,hi}: w5c3_lit_ok(U32.is_eq(hi,0), lo)
    case _: 4294967295

@unsafe
def w5c3_spec_arity_if(ok: Bool, +kind: U32) -> U32:
  match ok:
    case True{}: p111v_at([0,0,0,0,1,1,1,1,1,2],kind)
    case False{}: 4294967295

@unsafe
def p111v_finish(flow: P111VFlow) -> String:
  match flow:
    case P111VFlow{live,terminal,+error}: w5c3_finish_if(Bool.not(String.is_empty(error)), error, terminal)

@unsafe
def p111q_decimal_step(+value: P111QDecimal, acc: String) -> String:
  match value:
    case P111QDecimal{lo,hi,digit}:
      p111q_decimal_go(lo,hi,SCon{Char.from_u32(U32.add(48,digit)),acc})

@unsafe
def p111q_decimal_go(+lo: U32, +hi: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(lo,0) && U32.is_eq(hi,0),u => acc,
    u => p111q_decimal_step(p111q_div10(lo,hi),acc))

@unsafe
def p111q_ctor_table(constructors: List<&2,N_Constructor>, +hot_table: Bool, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match constructors:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{N_Constructor{name,arity,hot},rest}:
      p111q_ctor_table(rest,hot_table,Con{P111QByte{nt_choose(U32,hot_table,u => nt_bool(hot),u => arity)},acc})

@unsafe
def p111q_ctor_names_go(constructors: List<&2,N_Constructor>, acc: List<&2,String>) -> List<&2,String>:
  match constructors:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{N_Constructor{name,arity,hot},rest}: p111q_ctor_names_go(rest,Con{name,acc})

@unsafe
def p111q_words_go(items: List<&2,U32>, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}: p111q_words_go(rest,Con{P111QWord{head},acc})

@unsafe
def p111q_utf8_char(+code: U32, +acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_lt(code,128),u => Con{P111QByte{code},acc},u =>
    nt_choose(List<&2,P111QDatum>,U32.is_lt(code,2048),u =>
      Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(192,U32.shrn(code,6n))},acc}},u =>
      nt_choose(List<&2,P111QDatum>,U32.is_lt(code,65536),u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(224,U32.shrn(code,12n))},acc}}},u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,12n),63))},Con{P111QByte{U32.add(240,U32.shrn(code,18n))},acc}}}})))

@unsafe
def p111q_string_refs(names: List<&2,String>, +prefix: String, +index: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match names:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{name,rest}:
      p111q_string_refs(rest,prefix,U32.inc(index),Con{P111QReloc{prefix ++ "_" ++ U32.show(index),0},acc})

@unsafe
def p112_scalar_safe(values: List<&2, N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head, rest}: p112_scalar_safe_value(head) && p112_scalar_safe(rest)


@unsafe
def p112_scalar_operands(+a: N111Value, +b: N111Value, body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  Con{N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
    Con{N111Bin{"p112_s_b", N111U64{}, "and", b, p112_scalar_mask()}, body}}


@unsafe
def p112_scalar_shift(op: String, a: N111Value, count: N111Value) -> P111ValueCode:
  p112_scalar_result(
    [N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
     N111Set{"p112_s_b", N111U64{}, count},
     N111Bin{"p112_s_test", N111U64{}, "ult", N111Local{"p112_s_b"}, N111Const{32, 0}},
     N111If{N111Local{"p112_s_test"},
       [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
        N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}])


@unsafe
def p112t_params(+body: List<&2,N111Stmt>, +arity: U32, +index: U32,
  +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  nt_choose(P112TailPrelude,U32.is_eq(index,arity),
    u => P112TailPrelude{True{},nt_reverse(String,params,[]),nt_reverse(N111Stmt,prefix,[]),body},
    u => p112t_param(body,arity,index,params,prefix))


@unsafe
def p112t_param(+body: List<&2,N111Stmt>, +arity: U32, +index: U32,
  +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  match body:
    case Con{+stmt,rest}: p112t_param_stmt(stmt,rest,arity,index,params,prefix)
    case _: P112TailPrelude{False{},[],[],[]}


@unsafe
def p112t_param_stmt(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +arity: U32,
  +index: U32, +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  match stmt:
    case N111Call{+word,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{slot,hi}},Nil{}}}}:
      nt_choose(P112TailPrelude,agy_str_eq(symbol,"p111_rt_reg_get") && agy_str_eq(state,"state") &&
        U32.is_eq(slot,index) && U32.is_eq(hi,0) && Bool.not(nb_contains(params,word)),
        u => p112t_params(rest,arity,U32.inc(index),Con{word,params},Con{stmt,prefix}),
        u => P112TailPrelude{False{},[],[],[]})
    case _: P112TailPrelude{False{},[],[],[]}


@unsafe
def p112t_jump(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      agy_str_eq(symbol,"p111_rt_jump") && agy_str_eq(dest,word) && p112t_jump_args(args,owner,arity)
    case _: False{}


@unsafe
def p112t_runtime_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: agy_str_eq(name,"state") && p112t_buffer_args(rest)
    case _: False{}


@unsafe
def p112a_expand(+mode: U32, +stmt: N111Stmt) -> List<&2, N111Stmt>:
  match stmt:
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U64{}, +word}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 1) || U32.is_eq(mode, 3)) && agy_str_eq(symbol, "p111_rt_tag") && agy_str_eq(context, "state"),
        u => p112a_tag(name, word), u => [stmt])
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U32{}, N111Const{+index, +high}}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 2) || U32.is_eq(mode, 3)) && agy_str_eq(symbol, "p111_rt_reg_get") && agy_str_eq(context, "state") && U32.is_eq(high, 0) && U32.is_lt(index, 255),
        u => [N111Load{name, N111U64{}, N111Local{"state"}, U32.add(40, U32.mul(index, 8))}], u => [stmt])
    case _: [stmt]


@unsafe
def p185_bool_safe(values: List<&2, N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head, rest}: p185_bool_safe_value(head) && p185_bool_safe(rest)


@unsafe
def p112w_result(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{scratch},0,value},Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}}:
      agy_str_eq(scratch,"scratch") && agy_str_eq(symbol,"p111_rt_return") && agy_str_eq(dest,word) && p112w_result_args(args)
    case _: False{}

# Candidate discovery is not admission: ordered stores, arity and the complete
# terminal transition are checked again by p112t_tail.


@unsafe
def p112w_target(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{scratch},offset,value},rest}:
      nt_choose(String,agy_str_eq(scratch,"scratch"),u => p112w_target(rest),u => "")
    case Con{N111Call{dest,N111U64{},symbol,Con{state,Con{N111Arg{N111U32{},N111FuncId{name}},rest}}},Con{N111Return{value},Nil{}}}:
      nt_choose(String,agy_str_eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""


@unsafe
def p112w_call_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p112w_call_args(count,U32.inc(index),acc ++ ", l %p112_arg_" ++ U32.show(index)))


@unsafe
def p112s_term_word(+term: KTerm) -> P112SWord:
  nt_choose(P112SWord,agy_str_eq(tg(term),"NWord"),u => P112SRaw{p112s_uint(U32.read(nm(term)))},u =>
    nt_choose(P112SWord,U32.is_eq(qt(term),1),v => P112SPacked{nm(term),ix(term)},v => P112SBox{nm(term),ix(term)}))


@unsafe
def p112s_word_key(word: P112SWord) -> String:
  match word:
    case P112SRaw{value}: "r" ++ U32.show(value) ++ ";"
    case P112SPacked{name,payload}: "p" ++ nc_ctor_codes(name) ++ ":" ++ U32.show(payload) ++ ";"
    case P112SBox{name,offset}: "b" ++ nc_ctor_codes(name) ++ ":" ++ U32.show(offset) ++ ";"


@unsafe
def p112s_packed(+term: KTerm, fields: List<&2,KTerm>, +image: P112SImage) -> P112STerm:
  match fields:
    case Nil{}: P112STerm{p112s_marker(P112SPacked{nm(term),0}),image}
    case Con{head,Nil{}}: P112STerm{p112s_marker(P112SPacked{nm(term),p112s_uint(U32.read(nm(head)))}),image}
    case _: P112STerm{term,image}


@unsafe
def p112s_immutable_name(+name: String) -> Bool:
  Bool.not(nb_contains(["Zero","Succ","True","False","Chr","U32","F32","ALeaf","ANode","Emit","Halt","Done","Fail"],name))


@unsafe
def p112s_descriptor_items(items: List<&2,P111QDatum>, +index: U32, +size: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}:
      p112s_descriptor_items(rest,U32.inc(index),size,Con{p112s_descriptor_item(head,index,size),acc})


@unsafe
def p112e_tail_scalar(+stmt: N111Stmt, tail: P112TailBody) -> P112TailBody:
  match tail:
    case P112TailBody{+valid,+loops,+body}:
      nt_choose(P112TailBody,valid,u => P112TailBody{True{},loops,Con{P112TailScalar{stmt},body}},
        u => P112TailBody{False{},0,[]})


@unsafe
def p112e_worker_scalar(+stmt: N111Stmt, tail: P112WorkerBody) -> P112WorkerBody:
  match tail:
    case P112WorkerBody{+valid,+calls,+body}:
      nt_choose(P112WorkerBody,valid,u => P112WorkerBody{True{},calls,Con{P112WorkerScalar{stmt},body}},
        u => P112WorkerBody{False{},0,[]})


@unsafe
def p112e_tail_rest(+condition: N111Value, +yes: P112TailBody, +no: P112TailBody, +rest: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(rest),u => p112t_branch(condition,yes,no,rest),u => P112TailBody{False{},0,[]})


@unsafe
def p112f_index_bucket_add(+bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      w7c_p112f_badd(p112f_index_present(p112f_index_bucket(bucket,name)),bucket,segment)


@unsafe
def w7c_p112f_find_leaf(eq: Bool, bucket: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match eq:
    case True{}: p112f_index_bucket(bucket,name)
    case False{}: None{}

@unsafe
def p112f_index_join(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  w7c_p112f_join_lr(U32.and(hash,mask),tree,segment,hash,mask)


@unsafe
def p112f_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112f_clean_name(name)
    case _: True{}


@unsafe
def p112f_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,agy_str_eq(base,"scratch") && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,8),
        u => p112f_frame(rest,U32.inc(index),Con{value,captures}),u => None{})
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,agy_str_eq(symbol,"p111_rt_frame") && agy_str_eq(state,"state") && agy_str_eq(scratch,"scratch") && U32.is_eq(count,index),
        u => Some{P112FusionFrame{nt_reverse(N111Value,captures,[]),name,dest,rest}},u => None{})
    case _: None{}

# The remainder may manipulate frames and transfer control, but cannot observe
# the register bank, popped stack slots, raw state, or arbitrary external effects.


@unsafe
def p112f_callargs(+count: U32, +index: U32, +prefix: String) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{prefix ++ "arg_" ++ U32.show(index)}},p112f_callargs(count,U32.inc(index),prefix)})


@unsafe
def p112m_fresh_env(env: List<&2,NC_Binding>, +n: U32) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{+id,+word,kind},rest}:
      (U32.is_lt(id,nc_id(U32.add(n,2))) || U32.is_gt(id,nc_id(n))) &&
        Bool.not(agy_str_eq(word,"v_" ++ U32.show(nc_id(n))) || agy_str_eq(word,"v_" ++ U32.show(nc_id(U32.inc(n)))) || agy_str_eq(word,"v_" ++ U32.show(nc_id(U32.add(n,2))))) && p112m_fresh_env(rest,n)


@unsafe
def p112m_mask(+depth: U32) -> U32:
  nt_choose(U32,U32.is_eq(depth,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(depth)),1))


@unsafe
def p112r_buffer_sites(+name: String, +sites: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,sites),u => False{},u =>
    agy_str_eq(name,"p112f_" ++ U32.show(index) ++ "_local_scratch") || p112r_buffer_sites(name,sites,U32.inc(index)))


@unsafe
def p112r_tail(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  nt_choose(Bool,U32.is_eq(index,arity),u => p112r_jump(body,owner,arity,buffer),u => p112r_tail_store(body,owner,arity,index,buffer))


@unsafe
def p112r_tail_store(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      agy_str_eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && p112r_tail(rest,owner,arity,U32.inc(index),buffer)
    case _: False{}


@unsafe
def p112r_exit_stores(+count: U32, +index: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_choose(List<&2,P112WorkerStmt>,U32.is_eq(count,index),u => [last],u =>
    Con{P112WorkerScalar{N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),N111Local{"p112f_region_exit_" ++ U32.show(index)}}},p112r_exit_stores(count,U32.inc(index),last)})

# All operands are copied before any canonical slot is overwritten. The exact
# suffix has only pure value stores followed by its transfer, so secondary
# terminal stores can be replaced by this transport without moving owner calls.


@unsafe
def p112r_rest(+condition: N111Value, +yes: P112WorkerBody, +no: P112WorkerBody, +rest: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(rest),u => p112w_branch(condition,yes,no,rest),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112c_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>, +buffer: String) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,agy_str_eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,32),
        u => p112c_frame(rest,U32.inc(index),Con{value,captures},buffer),u => None{})
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,agy_str_eq(symbol,"p111_rt_frame") && agy_str_eq(state,"state") && agy_str_eq(scratch,buffer) && U32.is_eq(count,index),
        u => Some{P112FusionFrame{nt_reverse(N111Value,captures,[]),name,dest,rest}},u => None{})
    case _: None{}

@unsafe
def p113d_call(+name: String, +args: List<&2,N111Value>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,agy_str_eq(name,owner),
    u => nt_choose(P113DCode,p113d_tail(target),u => P113DCode{[P113DAgain{args}],n,"",[]},u => w6_p113d_self_nontail(name,args,target,n)),
    u => p113d_call_target(name,args,target,n))


@unsafe
def p113e_buffers(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},value},rest}: p113e_nonstate_pointer(value) && p113e_buffers(rest)
    case Con{arg,rest}: p113e_buffers(rest)


@unsafe
def p113e_distinct(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+head,+rest}: Bool.not(nb_contains(rest,head)) && p113e_distinct(rest)


@unsafe
def p113_scalar_result_name(+name: String) -> Bool:
  nb_contains([
    "u32_add", "u32_sub", "u32_and", "u32_or", "u32_xor", "u32_mul",
    "u32_is_eq", "u32_is_ne", "u32_is_lt", "u32_is_le", "u32_is_gt", "u32_is_ge",
    "u32_inc", "u32_shl", "u32_shr", "u32_shln", "u32_shrn", "u32_div", "u32_mod", "u32_not", "u32_is_zero",
    "u32_to_f32", "u32_from_nat", "f32_from_nat",
    "f32_add", "f32_sub", "f32_mul", "f32_div",
    "f32_is_eq", "f32_is_ne", "f32_is_lt", "f32_is_le", "f32_is_gt", "f32_is_ge",
    "f32_sqrt", "f32_exp", "f32_log", "f32_log2", "f32_log10", "f32_sin", "f32_cos", "f32_tan",
    "f32_asin", "f32_acos", "f32_atan", "f32_sinh", "f32_cosh", "f32_tanh",
    "f32_floor", "f32_ceil", "f32_trunc", "f32_abs", "f32_pow", "f32_atan2", "f32_mod", "f32_neg",
    "f32_to_u32", "f32_bits", "nat_is_lt", "bool_or", "bool_xor"], name)


@unsafe
def p113p_shapes_valid(shapes: List<&2,KTerm>) -> Bool:
  match shapes:
    case Nil{}: True{}
    case Con{+shape,+rest}: (agy_str_eq(tg(shape),"Absent") || p113p_known(shape)) && p113p_shapes_valid(rest)


@unsafe
def p113pl_zeroes(+count: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(count,0),u => [],u => Con{N111Const{0,0},p113pl_zeroes(U32.sub(count,1))})


@unsafe
def p113df_mask(+mat: KTerm, +count: U32) -> U32:
  nt_choose(U32,agy_str_eq(tg(mat),"Mat") && U32.is_eq(ix(mat),U32.inc(count)) && U32.is_le(count,8),
    u => nt_choose(U32,U32.is_lt(qt(mat),U32.shln(1,U32.to_nat(count))),v => qt(mat),v => 0),
    u => 0)

# Keep the existing local names, IDs and full-Term words. Only ownership kind
# changes. The book argument is reserved for an independently admitted Nat
# extension; the scalar certificate already contains its original type proof.


@unsafe
def p113df_kind(+mask: U32, +i: U32, +prior: N_WordKind) -> N_WordKind:
  nt_choose(N_WordKind,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0),
    u => N_W32{},u => prior)


@unsafe
def p113n_primitive(+name: String) -> Bool:
  nb_contains(["u32_to_nat","nat_add","nat_sub","nat_mul","nat_double"],name)


def p113n_at(kinds: List<&2,N_WordKind>, +index: U32) -> N_WordKind:
  match kinds:
    case Nil{}: N_W64{}
    case Con{head,rest}: nt_choose(N_WordKind,U32.is_eq(index,0),u => head,u => p113n_at(rest,U32.sub(index,1)))


law p113i_get:
  for table: P113ITable
  for +name: String
  for +hash: U32
  for +depth: U32
  Maybe<&2,P113DFunction>

@unsafe
def w7c_p113i_get_br(bit: U32, zero: P113ITable, one: P113ITable, +name: String, +hash: U32, +depth: U32) -> Maybe<&2,P113DFunction>:
  match bit:
    case 0: p113i_get(zero,name,U32.shr(hash),U32.inc(depth))
    case _: p113i_get(one,name,U32.shr(hash),U32.inc(depth))

@unsafe
def p113i_get(table, name, hash, depth):
  match table:
    case P113IEmpty{}: None{}
    case P113IBucket{values}: p113i_bucket(name,values)
    case P113INode{zero,one}:
      w7c_p113i_get_br(U32.and(hash,1),zero,one,name,hash,depth)


law p113i_put:
  for +table: P113ITable
  for +function: P113DFunction
  for +hash: U32
  for +depth: U32
  P113ITable

@unsafe
def w7c_p113i_put_br(bit: U32, +zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match bit:
    case 0: P113INode{p113i_put(zero,function,U32.shr(hash),U32.inc(depth)),one}
    case _: P113INode{zero,p113i_put(one,function,U32.shr(hash),U32.inc(depth))}

@unsafe
def p113i_put_branch(+zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  w7c_p113i_put_br(U32.and(hash,1),zero,one,function,hash,depth)

@unsafe
def p113i_put_node(table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match table:
    case P113INode{+zero,+one}: p113i_put_branch(zero,one,function,hash,depth)
    case _: p113i_put_branch(P113IEmpty{},P113IEmpty{},function,hash,depth)

@unsafe
def w7c_p113i_put_d(atLeaf: Bool, +table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match atLeaf:
    case True{}: p113i_put_leaf(table,function)
    case False{}: p113i_put_node(table,function,hash,depth)

@unsafe
def p113i_put(table, function, hash, depth):
  w7c_p113i_put_d(U32.is_eq(depth,32),table,function,hash,depth)


@unsafe
def p113i_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p113i_name(name)
    case _: True{}


@unsafe
def p113i_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}: p113i_name(head) && p113i_names(rest)


@unsafe
def p113i_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113i_name(word) && p113i_params(rest)

# Count nested scalar branches as real nodes. Saturation avoids wraparound and
# keeps budget arithmetic independent of malformed or very large input graphs.


@unsafe
def p113i_scalar_size(stmt: N111Stmt) -> U32:
  match stmt:
    case N111If{condition,yes,no}: p113i_add(1,p113i_add(p113i_scalars_size(yes),p113i_scalars_size(no)))
    case _: 1


@unsafe
def p113i_scalars_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_add(p113i_scalar_size(head),p113i_scalars_size(rest))


@unsafe
def p113i_scalar_stack(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Alloca{name,bytes,align}: U32.min(bytes,65536)
    case N111If{condition,yes,no}: p113i_stack_add(p113i_scalars_stack(yes),p113i_scalars_stack(no))
    case _: 0


@unsafe
def p113i_scalars_stack(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_stack_add(p113i_scalar_stack(head),p113i_scalars_stack(rest))


@unsafe
def w4c_body_has_arr_pair(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: w4c_stmt_has_arr_pair(s) || w4c_body_has_arr_pair(rest)
    case Con{P113DIf{_,y,n},rest}: w4c_body_has_arr_pair(y) || w4c_body_has_arr_pair(n) || w4c_body_has_arr_pair(rest)
    case Con{_,rest}: w4c_body_has_arr_pair(rest)

@unsafe
def p113j_scratch_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head,rest}: p113j_is_scratch(head) || p113j_scratch_values(rest)


@unsafe
def p113j_scratch_literal(value: N111Value) -> U32:
  match value:
    case N111Const{+count,0}: nt_choose(U32,U32.is_le(count,256),u => U32.max(8,U32.mul(count,8)),u => 2048)
    case _: 2048


@unsafe
def p113j_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  w7c_p113j_calls_acc(body,[])


@unsafe
def p113a_value(n: U32, role: String) -> N111Value:
  N111Local{p113a_name(n,role)}

# A zero means no rewrite. These checks are deliberately redundant with the
# original direct verifier; no unchecked call is made legal by this profile.


@unsafe
def p113a_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p113a_local_name(name) && p113a_names(rest)


@unsafe
def p113a_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113a_local_name(word) && p113a_params(rest)


@unsafe
def w5c2_bits2(ge4: Bool, +v: U32, +b: U32) -> U32:
  match ge4:
    case True{}: w5c2_bits1(U32.is_ge(U32.shrn(v, 2n), 2), U32.add(b, 2))
    case False{}: w5c2_bits1(U32.is_ge(v, 2), b)

@unsafe
def p113k_bound(+bits: U32) -> P113KFact:
  w5c2_p113k_bound_if(U32.is_eq(bits, 0), bits)

@unsafe
def w5c2_p113k_get_rec(record: KDef) -> P113KFact:
  match record:
    case KDef{_, kind, arity, templates, _, val, _, _, _}:
      w5c2_p113k_get_if(String.eq(kind, "P113KFact"), arity, templates, val)
    case _: P113KFact{64, False{}, 0, 0}

@unsafe
def p113k_atom(+value: N111Value, fact: P113KFact) -> N111Value:
  match fact:
    case P113KFact{bits,exact,lo,hi}: w5c2_p113k_atom_if(exact, lo, hi, value)


@unsafe
def p113k_ones(+bits: U32) -> U32:
  w5c2_ones_if(U32.is_eq(bits, 32), bits)

@unsafe
def p113k_scalar_body(result: P113KScalar) -> P113KBody:
  match result:
    case P113KScalar{body,facts}: P113KBody{p113d_scalars(body),facts,False{}}


@unsafe
def w4k_const01_assign(body: List<&2,P113DStmt>) -> KDef:
  match body:
    case Con{P113DScalar{N111Set{d,N111U64{},N111Const{+v,0}}},Nil{}}:
      nt_choose(KDef,U32.is_le(v,1),u => KDef{d,"W4KBit",v,0,atom("Absent"),atom("Absent"),[],False{},False{}},u => missing())
    case Con{P113DScalar{N111Set{r0,N111U64{},N111Const{v0,0}}},Con{P113DScalar{N111Set{d,N111U64{},N111Const{+v,0}}},Nil{}}}:
      nt_choose(KDef,U32.is_le(v,1) && String.starts_with(r0,"p113i_"),
        u => KDef{d,"W4KBit",v,1,atom("Absent"),kt("R0",r0,v0,0,[]),[],False{},False{}},u => missing())
    case _: missing()


@unsafe
def w4g_ic_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_ic_res(n)) && w4g_ic_pure(rest,U32.sub(limit,1))
    case Con{P113DScalar{N111Bin{+n,_,+op,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_ic_res(n)) &&
        Bool.not(agy_str_eq(op,"udiv") || agy_str_eq(op,"urem")) &&
        w4g_ic_pure(rest,U32.sub(limit,1))
    case _: False{}


@unsafe
def w4g_ic_last_u64_dst(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{P113DScalar{N111Set{n,N111U64{},_}},Nil{}}: n
    case Con{P113DScalar{N111Bin{n,N111U64{},+op,_,_}},Nil{}}:
      nt_choose(String,p111v_comparison(op),u => "",u => n)
    case Con{_,rest}: w4g_ic_last_u64_dst(rest)
    case Nil{}: ""


@unsafe
def w4g_arm_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_reserved(n)) && w4g_arm_pure(rest,U32.sub(limit,1))
    case Con{P113DScalar{N111Bin{+n,_,+op,_,_}},rest}:
      U32.is_gt(limit,0) && Bool.not(w4g_reserved(n)) && w4k_pure_bin(op) && w4g_arm_pure(rest,U32.sub(limit,1))
    case _: False{}


@unsafe
def p113ai_snapshot(+values: List<&2,N111Value>, +n: U32) -> N111Stmt:
  N111Set{"p113ai_array_" ++ U32.show(n),N111U64{},p113ai_first(values)}


@unsafe
def w4k_f32_scale_up(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_up(F32.mul(x,16.0),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_up(F32.mul(x,2.0),U32.sub(k,1))))


@unsafe
def w4k_f32_scale_down(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_down(F32.mul(x,0.0625),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_down(F32.mul(x,0.5),U32.sub(k,1))))


@unsafe
def w4k_f32_bin_eval(+id: U32, ma: Maybe<&2,F32>, mb: Maybe<&2,F32>) -> Maybe<&2,U32>:
  match ma mb:
    case Some{+a} Some{+b}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,26),u => Some{F32.bits(F32.add(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,27),u => Some{F32.bits(F32.sub(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,28),u => Some{F32.bits(F32.mul(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,29),u => Some{F32.bits(F32.div(a,b))},u => None{}))))
    case _ _: None{}


@unsafe
def p113bq_scalar(yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>) -> P113BQDiamond:
  match yes no:
    case Con{N111Set{+a,N111U64{},N111Const{1,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{0,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,False{}},u => P113BQNo{})
    case Con{N111Set{+a,N111U64{},N111Const{0,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{1,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,True{}},u => P113BQNo{})
    case _ _: P113BQNo{}


@unsafe
def p113l_enrich(+answer: P113KFact, op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match answer left right:
    case P113KFact{+bits,+exact,lo,hi} P113KFact{lb,le,ll,lh} P113KFact{rb,re,rl,rh}:
      w5c2_p113l_enr_if(Bool.not(exact) && String.eq(op, "or"), bits, ll, rl, lh, rh, answer)

@unsafe
def p114p_single(+name: String, field: N111Value) -> P111ValueCode:
  P111ValueCode{[
    N111Set{"p114p_payload",N111U64{},field},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p114p_payload"}},
    N111Bin{"p114p_fits",N111U64{},"ule",N111Local{"p114p_payload"},N111Const{4294967295,255}},
    N111If{N111Local{"p114p_fits"},[
      N111Bin{"p114p_metadata",N111U64{},"shl",N111CtorId{name},N111Const{40,0}},
      N111Bin{"p114p_metadata",N111U64{},"or",N111Local{"p114p_metadata"},N111Const{0,16777216}},
      N111Bin{"value",N111U64{},"or",N111Local{"p114p_metadata"},N111Local{"p114p_payload"}}],[
      N111Call{"value",N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{name}},p111_scratch(),p111_u32(1)]}]}],
    N111Local{"value"},""}


def p114h_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p114h_clean_name(name)
    case _: True{}


@unsafe
def p114h_call_loads(+count: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,index),u => [],u =>
    Con{N111Load{p114h_call_name(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)},p114h_call_loads(count,U32.inc(index))})


@unsafe
def p114h_call_args(+count: U32, +index: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{p114h_call_name(index)}},p114h_call_args(count,U32.inc(index))})

# Exact terminal stores have already been checked. Snapshot every argument
# before the private call, preserving the owning single-Term result boundary.


law agy_p114r_body_calls_h:
  for stmts: List<&2,P114RStmt>
  Bool

@unsafe
def p114t_local(site: U32, role: String) -> N111Value:
  N111Local{p114t_name(site,role)}

# Only stack allocations from the authenticated ordinary/fusion/inlining
# factories are supported. This is not an arbitrary pointer-alias certificate.


@unsafe
def p114t_fusion_buffer(+name: String, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,8),u => False{},u =>
    nt_choose(Bool,agy_str_eq(name,"p112f_" ++ U32.show(site) ++ "_local_scratch"),
      v => True{},v => p114t_fusion_buffer(name,U32.inc(site))))


@unsafe
def p114t_negative_bytes(+count: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(count,0),u => N111Const{0,0},
    u => N111Const{U32.sub(0,U32.mul(count,8)),4294967295})

# Preserve the runtime's ordered source-load/destination-store pairs. We do not
# replace this loop with memmove or reorder all loads ahead of all stores.


@unsafe
def p114ts_names(names: List<&2,String>, valid: Bool) -> Bool:
  match names:
    case Nil{}: valid
    case Con{name,rest}: p114ts_names(rest,valid && p114t_local_name(name))


@unsafe
def p114ts_params(params: List<&2,NC_Binding>, valid: Bool) -> Bool:
  match params:
    case Nil{}: valid
    case Con{NC_Binding{id,word,kind},rest}: p114ts_params(rest,valid && p114t_local_name(word))


@unsafe
def p117p_items(items: List<&2,P111QDatum>, +index: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}: p117p_items(rest,U32.inc(index),Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => P111QLong{3,0},u => head),acc})


@unsafe
def p117h_bit(+origin: U32) -> U32:
  nt_choose(U32,U32.is_eq(origin,0),u => 0,u => U32.shln(1,U32.to_nat(U32.sub(origin,1))))


@unsafe
def p117h_name(origin: U32, role: String) -> String:
  p113a_name(origin,"hoist_" ++ role)


@unsafe
def w5_set_loc_sc(sc: N111Stmt) -> W5SetLoc:
  match sc:
    case N111Set{d,_,v}: w5_set_loc_val(d,v)
    case _: W5SetLocNone{}

@unsafe
def w5_arm_loc_pair2(+t: String, +src: String, s2: W5SetLoc) -> W5SetLoc:
  match s2:
    case W5SetLoc{dst,s}: nt_choose(W5SetLoc,agy_str_eq(t,s),u => W5SetLoc{dst,src},u => W5SetLocNone{})
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w4c_nth_val(vals: List<&2,N111Value>, +i: U32) -> Maybe<&2,N111Value>:
  match vals:
    case Nil{}: None{}
    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(i,0),u => Some{v},u => w4c_nth_val(rest,U32.sub(i,1)))

@unsafe
def w4c_nth_param_name(params: List<&2,NC_Binding>, +i: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{_,word,_},rest}: nt_choose(String,U32.is_eq(i,0),u => word,u => w4c_nth_param_name(rest,U32.sub(i,1)))

@unsafe
def w4c_opt_eq2(a: Maybe<&2,U32>, b: Maybe<&2,U32>) -> Bool:
  match a:
    case Some{x}: w4c_opt_eq(b,x)
    case None{}: False{}

@unsafe
def p118t_target(+target: P113PTarget) -> Bool:
  p113pl_tail(target) && agy_str_eq(tg(p113pl_shape(target)),"P118TRMC")


@unsafe
def p118t_finish(values: List<&2,N111Value>, +n: U32) -> P113DCode:
  match values:
    case Con{word,Nil{}}:
      +result = "p118_finished_" ++ U32.show(n)
      P113DCode{[
        P113DScalar{N111Call{result,N111U64{},"p118_rt_finish",
          [p111_state(),p111_word(N111Local{"p118_root"}),p111_word(N111Local{"p118_parent"}),p111_word(word)]}},
        P113DResult{[N111Local{result}]}],U32.inc(n),"",[]}
    case _: p113d_fail("TRMC terminal result must be boxed",n)


@unsafe
def p118c_ordinary(+name: String) -> Bool:
  Bool.not(nb_contains(["Zero","Succ","False","True","Chr","U32","F32",
    "ALeaf","ANode","WNil","WCon","Emit","Halt","Done","Fail"],name))


@unsafe
def p118c_zero_byte(items: List<&2,P111QDatum>) -> Bool:
  p118ns_zero_byte(items,False{})

# Exact mature per-definition observer predicate. In particular trusted AND
# filled foreign permission, native authentication, and Rwt refusal remain.
# Only the new integrated entry uses this loop; mature C/JS policy is untouched.

@unsafe
def p118c_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118c_cap_item(head),u => head),p118c_cap_items(rest,U32.inc(index))}


@unsafe
def w7_patch_prog_item(+item: P111QDatum, +set3: Bool, +or_flags: U32) -> P111QDatum:
  match item:
    case P111QLong{+lo,+hi}:
      nt_choose(P111QDatum,set3,u => P111QLong{U32.or(3,or_flags),0},u => P111QLong{U32.or(lo,or_flags),hi})
    case _: item

@unsafe
def p118z_runtime(+symbol: String) -> Bool:
  match symbol:
    case SCon{Chr{112},SCon{Chr{49},SCon{Chr{49},SCon{Chr{49},SCon{Chr{95},SCon{Chr{114},SCon{Chr{116},SCon{Chr{95},rest}}}}}}}}: p147z_runtime_111(rest)
    case SCon{Chr{112},SCon{Chr{49},SCon{Chr{49},SCon{Chr{56},SCon{Chr{95},SCon{Chr{114},SCon{Chr{116},SCon{Chr{95},rest}}}}}}}}: p147z_runtime_118(rest)
    case "p113_rt_array_pair": True{}
    case "p126_rt_nat_divmod": True{}
    case "p125_rt_concat_typed": True{}
    case _: False{}


@unsafe
def p118z_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118z_cap_item(head),u => head),p118z_cap_items(rest,U32.inc(index))}


def p121f_again(acc: String) -> P113DCode:
  P113DCode{[P113DAgain{[p121f_ref("p121_next_n"),p121f_ref("p121_next_seed"),p121f_ref(acc)]}],9000,"",[]}


@unsafe
def p198e_arm(+cases: KTerm, +name: String, +fuel: U32) -> KTerm:
  +h = j_strip(cases)
  nt_choose(KTerm,U32.is_gt(fuel,0) && p98_tag_eq(h,"Mat") && U32.is_eq(terms_len(ks(h)),2),
    u => nt_choose(KTerm,agy_str_eq(nm(h),name),v => kid(h,0),v => p198e_arm(kid(h,1),name,U32.sub(fuel,1))),
    u => kt("Absent","",0,0,[]))

@unsafe
def p198e_apply(+op: String, +a: KTerm, +b: KTerm) -> KTerm:
  app(app(ref(op),a),b)

# Evaluate a finite, closed constructor expression in the checked word algebra.
# The sole allowed free variable is the actual word argument of this case.
@unsafe
def p198e_domain(+ty: KTerm, +at: U32) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(ty,"All") && Bool.not(U32.is_eq(qt(ty),0)),u =>
    nt_choose(KTerm,U32.is_eq(at,0),v => kid(ty,0),v => p198e_domain(kid(ty,1),U32.sub(at,1))),u => kt("Absent","",0,0,[]))

# Restrict representation equality to a closed, unapplied datatype reference.
# Excludes indexed/dependent products and implicit type arguments.
@unsafe
def p198e_spine(+t: KTerm, +args: List<&2,KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(fuel,0),u => kt("Absent","",0,0,[]),u =>
    nt_choose(KTerm,p98_tag_eq(t,"Ann"),v => p198e_spine(kid(t,0),args,U32.sub(fuel,1)),v =>
    nt_choose(KTerm,p98_tag_eq(t,"App"),w => p198e_spine(kid(t,0),Con{kid(t,1),args},U32.sub(fuel,1)),w =>
    nt_choose(KTerm,p98_tag_eq(t,"Ref"),z => kt("Call",nm(t),0,0,args),z => kt("Absent","",0,0,[])))))

@unsafe
def p198e_mask(+name: String, +source: String) -> N111Stmt:
  p198e_bin(name,"and",p121f_ref(source),N111Const{4294967295,0})

@unsafe
def p198e_again(m: String, b: String) -> P113DCode:
  P113DCode{[P113DAgain{[p121f_ref("epred"),p121f_ref("enext"),p121f_ref(m),p121f_ref(b)]}],90000,"",[]}

@unsafe
def p123a_scale(+name: String, +value: N111Value, +shift: U32) -> N111Stmt:
  nt_choose(N111Stmt,U32.is_le(shift,3),
    u => N111Bin{name,N111U64{},"mul",value,N111Const{nt_choose(U32,U32.is_eq(shift,0),u => 1,u => nt_choose(U32,U32.is_eq(shift,1),u => 2,u => nt_choose(U32,U32.is_eq(shift,2),u => 4,u => 8))),0}},
    u => N111Bin{name,N111U64{},"shl",value,N111Const{shift,0}})


@unsafe
def agy_p114r_body_calls_h(stmts):
  match stmts:
    case Nil{}: False{}
    case Con{P114RScalar{s},rest}:
      agy_p114r_nstmts_calls_h([s]) || agy_p114r_body_calls_h(rest)
    case Con{P114RIf{c,yes,no},rest}:
      agy_p114r_body_calls_h(yes) || agy_p114r_body_calls_h(no) || agy_p114r_body_calls_h(rest)
    case Con{P114RResumeReady{p,call,r},rest}:
      agy_p114r_nstmts_calls_h(call) || agy_p114r_body_calls_h(rest)
    case Con{_,rest}: agy_p114r_body_calls_h(rest)

@unsafe
def p125p_body(left: String, right: String, empty: String, link: String, old: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{"p125_concat_result",N111U64{},"p125_rt_concat_typed",[
     p111_state(),p111_word(N111Local{left}),p111_word(N111Local{right}),
     N111Arg{N111U32{},N111CtorId{empty}},N111Arg{N111U32{},N111CtorId{link}}]}},
   P113DScalar{N111Bin{"p125_concat_yes",N111U64{},"ne",N111Local{"p125_concat_result"},N111Const{0,0}}},
   P113DIf{N111Local{"p125_concat_yes"},[P113DResult{[N111Local{"p125_concat_result"}]}],old}]


@unsafe
def p126s_literal(+kind: String, value: Maybe<&2,U32>) -> KTerm:
  match value:
    case None{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Some{+bits}:
      nt_choose(KTerm,agy_str_eq(kind,"U32") || j_private_float_finite(bits),
        u => kl_make(kind,bits,""),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_last(+value: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(value),u => Some{[kl_number(value)]},u => None{})


@unsafe
def p126s_cells(+word: String, body: List<&2,P113DStmt>, +index: U32) -> Maybe<&2,List<&2,U32>>:
  match body:
    case [P113DResult{[N111Const{bits,hi}]}]:
      nt_choose(Maybe<&2,List<&2,U32>>,U32.is_eq(hi,0),u => Some{[bits]},u => None{})
    case [P113DScalar{N111Bin{+dest,N111U64{},op,N111Local{arg},N111Const{at,hi}}},
          P113DIf{N111Local{cond},[P113DResult{[N111Const{bits,upper}]}],rest}]:
      nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(op,"eq") && agy_str_eq(arg,word) && agy_str_eq(cond,dest) &&
        Bool.not(agy_str_eq(dest,word)) && U32.is_eq(at,index) && U32.is_eq(hi,0) && U32.is_eq(upper,0) && U32.is_lt(index,63),
        u => p126s_cells_cons(bits,p126s_cells(word,rest,U32.inc(index))),u => None{})
    case _: None{}


@unsafe
def p126i_lookup(tables: List<&2,P126ITable>, +name: String) -> Maybe<&2,U32>:
  match tables:
    case Nil{}: None{}
    case Con{P126ITable{key,last},rest}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(key,name),u => Some{last},u => p126i_lookup(rest,name))


@unsafe
def p126dp_code(+left: N111Value, +right: N111Value, +n: U32) -> P113PValueCode:
  +out = "p126dp_out_" ++ U32.show(n)
  +first = "p126dp_first_" ++ U32.show(n)
  +second = "p126dp_second_" ++ U32.show(n)
  P113PValueCode{[
    N111Alloca{out,16,8},
    N111Call{"p126dp_status_" ++ U32.show(n),N111U64{},"p126_rt_nat_divmod",
      [p111_state(),p111_word(left),p111_word(right),N111Arg{N111Ptr{},N111Local{out}}]},
    N111Load{first,N111U64{},N111Local{out},0},
    N111Load{second,N111U64{},N111Local{out},8}],
    [N111Local{first},N111Local{second}],""}


@unsafe
def p126sc_has(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,agy_str_eq(head,name),u => True{},u => p126sc_has(rest,name))


@unsafe
def p126sc_lane_params(+count: U32, +index: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(count,index),u => [],u =>
    Con{NC_Binding{index,"p126scc_arg_" ++ U32.show(index),N_W64{}},p126sc_lane_params(count,U32.inc(index))})


@unsafe
def p126sc_external(calls: List<&2,String>, +left: String, +right: String) -> List<&2,String>:
  match calls:
    case Nil{}: []
    case Con{+name,+rest}: nt_choose(List<&2,String>,p126sc_internal(name,left,right),u => p126sc_external(rest,left,right),u => Con{name,p126sc_external(rest,left,right)})


@unsafe
def p126sc_call_has(calls: List<&2,KTerm>, +name: String) -> Bool:
  match calls:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,agy_str_eq(nm(head),name),u => True{},u => p126sc_call_has(rest,name))


@unsafe
def p128bs_roots(params: List<&2,NC_Binding>, +roots: List<&2,U32>, +i: U32) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},+rest}:
      nt_choose(List<&2,N111Arg>,no_root_index(roots,i),
        u => Con{p111_word(N111Local{word}),p128bs_roots(rest,roots,U32.inc(i))},
        u => p128bs_roots(rest,roots,U32.inc(i)))


@unsafe
def p128bs_guard_args(roots: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match roots:
    case Con{a,Nil{}}: [p111_state(),a,p111_word(N111Const{0,0}),p111_u32(1)]
    case Con{a,Con{b,Nil{}}}: [p111_state(),a,b,p111_u32(2)]
    case _: []


@unsafe
def p128bs_drops(roots: List<&2,N111Arg>, +i: U32) -> List<&2,P113DStmt>:
  match roots:
    case Nil{}: []
    case Con{root,rest}:
      Con{P113DScalar{N111Call{"p128bs_drop_" ++ U32.show(i),N111U64{},"p111_rt_sink",[p111_state(),root]}},p128bs_drops(rest,U32.inc(i))}


@unsafe
def p128br_patch(target: String, workers: P118BWorkers) -> P128BRPatches:
  match workers:
    case P118BWorkers{+functions,error}:
      P128BRPatches{nt_choose(List<&2,P128BRPatch>,List.is_empty(&2,P113DFunction,functions),
        u => [],u => [P128BRPatch{target,functions}]),error}


@unsafe
def p128br_replacement(+name: String, patches: List<&2,P128BRPatch>) -> Maybe<&2,List<&2,P113DFunction>>:
  match patches:
    case Nil{}: None{}
    case Con{P128BRPatch{target,functions},rest}:
      nt_choose(Maybe<&2,List<&2,P113DFunction>>,agy_str_eq(name,target),u => Some{functions},u => p128br_replacement(name,rest))


@unsafe
def p128bl_type(+name: String, types: List<&2,KTerm>) -> KTerm:
  match types:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+head,rest}: nt_choose(KTerm,agy_str_eq(name,nm(head)),u => head,u => p128bl_type(name,rest))


@unsafe
def p128br_retryable(+plan: NO_Plan) -> Bool:
  agy_str_eq(no_plan_error(plan),"observer: helper effect, cycle or depth") ||
    agy_str_eq(no_schema_error(no_plan_schema(plan)),"unsupported or dependent parameter")


@unsafe
def p128bi_parameter(+word: String, params: List<&2,NC_Binding>, +i: U32) -> KTerm:
  match params:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{NC_Binding{id,name,kind},rest}:
      nt_choose(KTerm,agy_str_eq(word,name),u => var("",i),u => p128bi_parameter(word,rest,U32.inc(i)))


@unsafe
def p128bi_match_value(+pattern: KTerm, value: N111Value) -> Bool:
  nt_choose(Bool,agy_str_eq(tg(pattern),"Var"),u => True{},
    u => p128bi_match_constant(pattern,value))


@unsafe
def p128bi_argument(+i: U32, patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> N111Value:
  match patterns args:
    case Con{+pattern,rest} Con{+value,more}:
      nt_choose(N111Value,agy_str_eq(tg(pattern),"Var") && U32.is_eq(ix(pattern),i),
        u => value,u => p128bi_argument(i,rest,more))
    case _ _: N111Const{0,0}


@unsafe
def p130m_initial(text: String, expected: String) -> U32:
  match text:
    case SCon{Chr{+first},rest}:
      p130m_initial_choice(U32.is_ge(first,65536) && U32.is_le(first,131071) && String.starts_with(expected,"p130-word-pair-v1:"))
    case SNil{}: 1


@unsafe
def p130m_word(text: String) -> P88Number:
  match text:
    case SCon{Chr{+lo},SCon{Chr{+hi},tail}}:
      p130m_word_gate(tail,lo,hi,U32.is_ge(lo,65536) && U32.is_le(lo,131071) && U32.is_ge(hi,65536) && U32.is_le(hi,131071))
    case other: P88Number{P88Cursor{"",0},0}


def p131a_low(mode: U32, a: U32, b: U32) -> U32:
  match mode:
    case 0: p131a_add(a,b)
    case 1: U32.min(a,b)
    case other: 0


def p131a_high(mode: U32, a: U32, b: U32) -> U32:
  match mode:
    case 0: p131a_add(a,b)
    case other: U32.max(a,b)

def p131u_max(entries: List<&2,P131UEntry>, id: U32) -> U32:
  p131u_max_loop(entries,id,LT{},0)

@unsafe
def p131p_wrapper_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p131p_wrapper_ok(head,params,result,depth) && p131p_wrapper_fields(rest,params,result,depth)


@unsafe
def p131p_wrapper_ok(+t: KTerm, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  nt_choose(Bool,agy_str_eq(tg(t),"Var"),u => U32.is_eq(ix(t),result) || p131p_parameter(ix(t),params),u =>
    agy_str_eq(tg(t),"Ctr") && U32.is_lt(depth,2) && p131p_wrapper_fields(ks(t),params,result,U32.inc(depth)))


@unsafe
def p131p_argument(+id: U32, params: List<&2,KTerm>, args: List<&2,KTerm>) -> KTerm:
  match params args:
    case Con{p,rest} Con{arg,more}:
      nt_choose(KTerm,U32.is_eq(ix(p),id),u => arg,u => p131p_argument(id,rest,more))
    case _ _: atom("Absent")


def p134v_arg(a: N111Arg, b: N111Arg) -> Bool:
  match a b:
    case N111Arg{at,av} N111Arg{bt,bv}: p134v_type(at,bt) && p134v_value(av,bv)


@unsafe
def p143o_in_range(+id: U32, +n: U32, +left: U32) -> Bool:
  U32.is_lt(U32.sub(nc_id(id),n),left)


@unsafe
def p143o_range_env(+env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    nt_choose(Bool,p88_string_eq(nc_word(nc_id(n),env),"NATIVE_UNBOUND_VARIABLE"),
      u => p143o_range_env(env,U32.inc(n),U32.sub(left,1)),u => False{}))


@unsafe
def p164a_loads(+arity: U32, +at: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(at,arity),u => [],u =>
    Con{N111Call{p164a_arg(at),N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(at)]},
      p164a_loads(arity,U32.inc(at))})



@unsafe
def p164a_args(+arity: U32, +at: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(at,arity),u => [],u =>
    Con{p111_word(N111Local{p164a_arg(at)}),p164a_args(arity,U32.inc(at))})



@unsafe
def p167l_fail(error: String) -> P167Lowered:
  P167Lowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},missing(),error,[]}



@unsafe
def w6_local_find(locals: List<&2,W6Local>, +name: String) -> U32:
  match locals:
    case Nil{}: 4294967295
    case Con{W6Local{+orig,+cid},rest}:
      nt_choose(U32,agy_str_eq(orig,name),u => cid,u => w6_local_find(rest,name))

@unsafe
def w6_use_local_id(+cid: U32, +name: String) -> String:
  nt_choose(String,U32.is_eq(cid,4294967295),u => "v:?" ++ name,u => "v:L" ++ U32.show(cid))

@unsafe
def w6_def_local_id(+locals: List<&2,W6Local>, +next: U32, +chunks: List<&2,String>, +fuel: U32, +name: String, +cid: U32) -> W6CState:
  nt_choose(W6CState,U32.is_eq(cid,4294967295),
    u => W6CState{Con{W6Local{name,next},locals},U32.inc(next),Con{"L" ++ U32.show(next),chunks},fuel},
    u => W6CState{locals,next,Con{"L" ++ U32.show(cid),chunks},fuel})

@unsafe
def w6_canon_finish(st: W6CState) -> String:
  match st:
    case W6CState{locals,next,chunks,fuel}:
      nt_choose(String,U32.is_eq(fuel,0),u => "",u => nt_text_finish(chunks,""))

@unsafe
def w4p_field_locals(+count: U32, +i: U32, +fresh: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(i,count),u => [],
    u => Con{N111Local{"v_" ++ U32.show(nc_id(U32.add(fresh,i)))},w4p_field_locals(count,U32.inc(i),fresh)})

@unsafe
def p168t_accept(original: P113DFunction, +candidate: P113DFunction) -> P113DFunction:
  match candidate:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => candidate,u => original)



# Preparation is retained only when it establishes the original leaf contract.
# Existing leaf owners, non-target consumers and general observer seeds stay exact.
@unsafe
def p169sv_refused(+view_error: String, +original_error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(original_error),
    u => p169s_fail("adapter imports view verification: " ++ view_error),
    u => p169s_fail("adapter renderer original final IR: " ++ original_error))


# Optional native-entry protocol successor. The hosted p169s_plan contract stays
# unchanged. Frontend/Base errors pass through; runtime admission owns compile:.

@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1),u => 2,u => mode)


# Optional same-request cold metadata restoration after the existing full
# verifier and array/transport namespace gates. No emitted body or ID changes.
@unsafe
def p171sc_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +fresh: U32, +result: KTerm, graph: P128BLGraph) -> NO_Schema:
  match graph:
    case P128BLGraph{types,specs,+error}:
      nt_choose(NO_Schema,String.is_empty(error),
        u => NO_Schema{params,roots,var(nm(result),nc_id(fresh)),nc_id(fresh),nm(result),
          specs,U32.inc(fresh),""},
        u => nol_failure(error,fresh))

law p175p_shift_end:
  for +word: String
  Bool

@unsafe
def p175p_shift_end(word):
  f_eq(word,")") || f_eq(word,"}") || f_eq(word,",") || f_eq(word,":") ||
  f_eq(word,">") || f_eq(word,"\n") || f_eq(word,"->") || f_eq(word,"<eof>") || f_eq(word,"]")

@unsafe
def p177s_loop(state: U32, +term: KTerm, +terms: List<&2,KTerm>,
  +id: U32, +value: KTerm, stack: List<&1,P177SFrame>) -> KTerm:
  match state:
    case 0:
      p177s_loop(p177s_visit_state(p98_tag_eq(term,"Var"),U32.is_eq(ix(term),id)),
        term,Nil{},id,value,stack)
    case 1:
      p177s_loop(4,value,Nil{},id,value,stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}:
              p177s_loop(p177s_leaf_state(p88_string_eq(tag,"App")),
                term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KTerm{tag,name,n,quant,Nil{},removed,begin,end},rest,Nil{}},stack})
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177s_loop(4,term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KLambda{name,n,quant,Nil{},removed,begin,end,present},rest,Nil{}},stack})
        case KLiteral{kind,number,text,begin,end}:
          p177s_loop(4,term,Nil{},id,value,stack)
    case 4:
      match stack:
        case Nil{}: term
        case Con{P177SBeta{oldId,oldValue},tail}:
          p177s_loop(4,term,Nil{},oldId,oldValue,tail)
        case Con{P177SNode{shell,rest,done},tail}:
          match rest:
            case Nil{}:
              p177s_loop(5,shell,p177s_reverse(Con{term,done},Nil{}),id,value,tail)
            case Con{head,pending}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{shell,pending,Con{term,done}},tail})
    case 5:
      p177s_loop(p177s_rebuild_state(p98_tag_eq(term,"App")),
        term,terms,id,value,stack)
    case 6:
      p177s_loop(p177s_apply_state(p98_tag_eq(terms_at(terms,0),"Lam")),
        term,terms,id,value,stack)
    case 7:
      p177s_loop(4,k_with_children(term,terms),Nil{},id,value,stack)
    case 8:
      +function = terms_at(terms,0)
      p177s_loop(0,kid(function,0),Nil{},ix(function),terms_at(terms,1),
        Con{P177SBeta{id,value},stack})
    case _:
      p177s_loop(4,kt_span("App","",0,0,[terms_at(terms,0),terms_at(terms,1)],kb(term),ke(term)),
        Nil{},id,value,stack)

@unsafe
def p185cc_class(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 0,u => nt_choose(U32,U32.is_eq(count,2),v => 1,v => 2))

# p111_program is the immutable descriptor passed by the emitted main to
# p111_rt_main. Its fixed offsets are checked independently of the state
# layout. Capability 8 authorizes unsealed cold publication; bit 1 requires
# the selected sequential host ABI (LANE_STEP=1).
@unsafe
def p185cc_reads(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"cold_field_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
      p185cc_reads(buffer,count,site,U32.inc(index))})

@unsafe
def p185pt_local(site: U32, role: String) -> N111Value:
  N111Local{p185pt_name(site,role)}

# Extract tag and auxiliary bits together, masking only RFC. This is exactly
# term_tag==TAG_PAK AND term_aux==expectedCID; all 40 payload bits survive.
# Snapshot before any temporary assignment, scratch write or output binding.
# Generated source locals are v_<id>; the fresh lowering counter distinguishes
# these temporaries, and explicit reserved-prefix input aliases decline.
@unsafe
def p185cb_items(tables: List<&2,P111QData>, +name: String) -> List<&2,P111QDatum>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+key,alignment,exported,items},rest}:
      nt_choose(List<&2,P111QDatum>,agy_str_eq(key,name),u => items,u => p185cb_items(rest,name))

@unsafe
def p185cb_unique(tables: List<&2,P111QData>, +name: String, +found: Bool) -> Bool:
  match tables:
    case Nil{}: found
    case Con{P111QData{key,alignment,exported,items},+rest}:
      nt_choose(Bool,agy_str_eq(key,name),u => nt_choose(Bool,found,v => False{},v => p185cb_unique(rest,name,True{})),
        u => p185cb_unique(rest,name,found))

@unsafe
def p185cb_at(items: List<&2,P111QDatum>, +index: U32) -> P111QDatum:
  match items:
    case Nil{}: P111QZeros{0}
    case Con{head,rest}: nt_choose(P111QDatum,U32.is_eq(index,0),u => head,u => p185cb_at(rest,U32.sub(index,1)))

@unsafe
def p186rt_reads(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"transfer_word_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
      p186rt_reads(buffer,count,site,U32.inc(index))})

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+kind,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          u => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
# A pending continuation frame is distinct from a recursive descent. Preserve
# its exact stores/call, then continue scanning the remaining computation. This
# composes two pushes before a self descent or an already admitted ready call.
# The old successful plan is returned unchanged. New plans still pass through
# p114h_finish/close: at most eight known cases, exact captures and incoming
# result, reserved-name hygiene, and the original scalar/call restrictions.
#
# Each executed PushFrame increments the private depth once. Existing unwind
# pops its FID and captures once in LIFO order. Recursive work stays in the
# explicit runtime stack; this does not introduce recursive machine calls.
# The node stores no region-state variable: case renaming only renames the
# original frame operands, leaving the emitter-owned depth unchanged.

@unsafe
def p186sf_push(+frame: List<&2,N111Stmt>, +name: String, +count: U32, scanned: P114GBody) -> P114GBody:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114GBody,valid,
        u => P114GBody{True{},Con{P114GFrame{name,count},frames},Con{P114RPushFrame{frame},body}},
        u => P114GBody{False{},[],[]})

@unsafe
def p186sf_retried(previous: P114GBody, proposed: P114GBody) -> P114GBody:
  match proposed:
    case P114GBody{+valid,frames,body}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,body},u => previous)

@unsafe
def x188_finish_go(chunks: List<&2,X188Seq>, acc: X188Seq) -> X188Seq:
  match chunks:
    case Nil{}: acc
    case Con{head,rest}: x188_finish_go(rest,x188_cat(head,acc))

def x188_gpr_text(index: U32, +width: U32) -> String:
  match index:
    case 0: nt_choose(String,U32.is_eq(width,64),u => "%rax",u => nt_choose(String,U32.is_eq(width,32),v => "%eax",v => "%al"))
    case 1: nt_choose(String,U32.is_eq(width,64),u => "%rcx",u => nt_choose(String,U32.is_eq(width,32),v => "%ecx",v => "%cl"))
    case 2: nt_choose(String,U32.is_eq(width,64),u => "%rdx",u => nt_choose(String,U32.is_eq(width,32),v => "%edx",v => "%dl"))
    case 3: nt_choose(String,U32.is_eq(width,64),u => "%rbx",u => nt_choose(String,U32.is_eq(width,32),v => "%ebx",v => "%bl"))
    case 4: nt_choose(String,U32.is_eq(width,64),u => "%rsp",u => nt_choose(String,U32.is_eq(width,32),v => "%esp",v => "%spl"))
    case 5: nt_choose(String,U32.is_eq(width,64),u => "%rbp",u => nt_choose(String,U32.is_eq(width,32),v => "%ebp",v => "%bpl"))
    case 6: nt_choose(String,U32.is_eq(width,64),u => "%rsi",u => nt_choose(String,U32.is_eq(width,32),v => "%esi",v => "%sil"))
    case 7: nt_choose(String,U32.is_eq(width,64),u => "%rdi",u => nt_choose(String,U32.is_eq(width,32),v => "%edi",v => "%dil"))
    case n: "%r" ++ U32.show(n) ++ nt_choose(String,U32.is_eq(width,64),u => "",u => nt_choose(String,U32.is_eq(width,32),v => "d",v => "b"))

def x188_signed32(+value: U32) -> String:
  nt_choose(String,U32.is_gt(value,2147483647),u => "-" ++ U32.show(U32.sub(0,value)),u => U32.show(value))

law x181_reg:
  for +n: U32
  X187Operand
law x181_argreg:
  for +n: U32
  X187Operand
law x185_transient_reg:
  for +index: U32
  X187Operand

def x181_frame_alignment(+alignment: U32) -> U32:
  nt_choose(U32,U32.is_eq(alignment,4),u => 4,
    u => nt_choose(U32,U32.is_eq(alignment,8),v => 8,v => 16))

@unsafe
def x181_frame_outgoing(count: U32, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,+calls,params,symbol}:
      +needed = U32.mul(count,16)
      nt_choose(X181Frame,U32.is_gt(needed,calls),
        u => X181Frame{slots,bytes,needed,params,symbol},u => frame)

@unsafe
def w4_vals_state(vs: List<&2,N111Value>) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: w4_val_state(v) || w4_vals_state(rest)

@unsafe
def w4_args_state(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w4_val_state(v) || w4_args_state(rest)

@unsafe
def x186_inline_op_when(enabled: Bool, stmt: N111Stmt) -> X186InlineOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{+buffer}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(X186InlineOp,enabled && agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") &&
          (x200r_sqrt_admitted(id,count,buffer) || nt_choose(Bool,x192_float_unary(id),
            v => x192_float_conversions_enabled() && U32.is_eq(count,1) && Bool.not(agy_str_eq(buffer,"state")),
            v => U32.is_ge(id,26) && p112fp_supported(id,count))),
        u => X186InlineF32{name,id,buffer},u => X186InlineNone{})
    case _: X186InlineNone{}
def x200r_float_unary(+id: U32) -> Bool:
  U32.is_eq(id,36) || x192_float_unary(id)

@unsafe
def x195s_pick(enabled: Bool, stmt: N111Stmt) -> Maybe<&2,X195Sqrt>:
  match stmt:
    case N111Call{name,N111U64{},symbol,[
      N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{36,0}},
      N111Arg{N111Ptr{},N111Local{+buffer}},N111Arg{N111U32{},N111Const{1,0}}]}:
      nt_choose(Maybe<&2,X195Sqrt>,enabled && agy_str_eq(symbol,"p111_rt_op") &&
        agy_str_eq(state,"state") && Bool.not(agy_str_eq(buffer,"state")),
        u => Some{X195Sqrt{name,buffer}},u => None{})
    case _: None{}

def agy_rt_ctor_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor4"),u => 4,u => 0))))

def agy_rt_take_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take4"),u => 4,u => 0))))

def agy_cls_words(+cls: U32) -> U32:
  nt_choose(U32,U32.is_eq(cls,0),u => 1,u => nt_choose(U32,U32.is_eq(cls,1),v => 2,v => 4))

@unsafe
def agy_reuse_vals_use(+target: String, vals: List<&2,N111Value>) -> Bool:
  match vals:
    case Nil{}: False{}
    case Con{v,rest}: agy_reuse_val_uses(target,v) || agy_reuse_vals_use(target,rest)

@unsafe
def agy_reuse_args_use(+target: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_reuse_val_uses(target,v) || agy_reuse_args_use(target,rest)

law agy_reuse_pure_stmts:
  for stmts: List<&2,P113DStmt>
  Bool

@unsafe
def agy_reuse_pure_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: agy_reuse_pure_nstmt(s)
    case P113DIf{c,yes,no}: agy_reuse_pure_stmts(yes) && agy_reuse_pure_stmts(no)
    case _: False{}

@unsafe
def agy_reuse_pure_stmts(stmts):
  match stmts:
    case Nil{}: True{}
    case Con{s,rest}: agy_reuse_pure_stmt(s) && agy_reuse_pure_stmts(rest)

def agy_reuse_ctor_pick(+c1: String, +c2: String) -> String:
  nt_choose(String,String.is_empty(c1),u => c2,u => c1)

@unsafe
def agy_reuse_is_abort(stmts: List<&2,P113DStmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{n,t,+sym,args}},rest}:
      agy_str_eq(sym,"p111_rt_fail") || (agy_str_eq(sym,"p111_rt_sink") && agy_reuse_is_abort(rest))
    case Con{P113DScalar{other},rest}:
      agy_reuse_pure_nstmt(other) && agy_reuse_is_abort(rest)
    case _: False{}

def agy_rt_take_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse4"),u => 4,u => 0))))

def agy_rt_ctor_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse4"),u => 4,u => 0))))

def x186_call_reg32(index: U32) -> X187Operand:
  match index:
    case 0: x188_reg(7,32)
    case 1: x188_reg(6,32)
    case 2: x188_reg(2,32)
    case 3: x188_reg(1,32)
    case 4: x188_reg(8,32)
    case _: x188_reg(9,32)

@unsafe
def x186_call_capacity(plan: X186CallPlan, +bytes: U32, +calls: U32) -> X186CallPlan:
  match plan:
    case X186CallPlan{kind,+count}:
      nt_choose(X186CallPlan,U32.is_ge(bytes,40) && U32.is_le(calls,2147483000) &&
          U32.is_le(bytes,U32.sub(2147483583,calls)) && U32.is_ge(calls,U32.mul(count,16)),
        u => X186CallPlan{kind,count},u => X186CallPlan{0,count})

@unsafe
def x181_condition(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "le",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "ge",u => ""))))))))))

@unsafe
def x181_alu(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"mul"),u => "imul",u =>
    nt_choose(String,agy_str_eq(op,"add") || agy_str_eq(op,"sub") ||
      agy_str_eq(op,"and") || agy_str_eq(op,"or") || agy_str_eq(op,"xor") || x181_shift(op),
      u => op,u => ""))

@unsafe
def w4_pow2_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => w4_pow2_log(U32.shrn(d,1n),U32.inc(shift)))

law w4_bf_no_buf_load:
  for +buf: String
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w4_bf_no_buf_load(buf,body):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Call{d,t,sym,args}},+rest}:
      nt_choose(Bool,agy_str_eq(sym,"p118_rt_borrow_fields"),u => True{},u => w4_bf_no_buf_load(buf,rest))
    case Con{P113DScalar{s},rest}: w4_bf_no_buf_load_scalar(buf,s) && w4_bf_no_buf_load(buf,rest)
    case Con{P113DIf{c,y,n},rest}:
      w4_bf_no_buf_load(buf,y) && w4_bf_no_buf_load(buf,n) && w4_bf_no_buf_load(buf,rest)
    case Con{h,rest}: w4_bf_no_buf_load(buf,rest)

def x190_register_score(+reads: U32, loopState: Bool, policy: U32) -> U32:
  +weight = nt_choose(U32,U32.is_eq(policy,2) && loopState,u => 32,u => 8)
  nt_choose(U32,U32.is_gt(reads,U32.div(4294967295,weight)),
    u => 4294967295,u => U32.mul(reads,weight))

@unsafe
def x185_fact_returns(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{stmt},rest}: x185_fact_scalar_returns([stmt]) || x185_fact_returns(rest)
    case Con{P113DIf{condition,yes,no},rest}: x185_fact_returns(yes) || x185_fact_returns(no) || x185_fact_returns(rest)
    case Con{head,rest}: x185_fact_returns(rest)

def x185_transient_reg(index):
  match index:
    case 0: x188_reg(7,64)
    case 1: x188_reg(6,64)
    case 2: x188_reg(2,64)
    case 3: x188_reg(8,64)
    case _: x188_reg(9,64)

@unsafe
def w4c_sel_arm(body: List<&2,P113DStmt>) -> W4CSelArm:
  match body:
    case Con{P113DScalar{sc},Nil{}}: w4c_sel_arm_scalar(sc)
    case _: W4CSelArmNone{}

@unsafe
def x185_t_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 5
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),
      u => index,u => x185_t_pick(rest,first,U32.inc(index)))

@unsafe
def x185_t_end(ends: List<&2,U32>, +index: U32, +last: U32) -> List<&2,U32>:
  match ends:
    case Nil{}: []
    case Con{head,+rest}: nt_choose(List<&2,U32>,U32.is_eq(index,0),
      u => Con{last,rest},u => Con{head,x185_t_end(rest,U32.sub(index,1),last)})

@unsafe
def x188_physical(+index: U32) -> X185Physical:
  X185Physical{x188_reg(index,64),x188_reg(index,32),x188_reg(index,8)}

@unsafe
def x185_physical_same(reg: X185Physical, name: X187Operand) -> Bool:
  match reg:
    case X185Physical{wide,narrow,byte}: x188_operand_same(wide,name)
    case _: False{}

@unsafe
def x198w_op(stmt: N111Stmt) -> X198WOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+n,0}},Nil{}}}}}}:
      nt_choose(X198WOp,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && Bool.not(agy_str_eq(buf,"state")) &&
        ((U32.is_eq(n,1) && (U32.is_eq(id,24) || U32.is_eq(id,25))) ||
         (U32.is_eq(n,2) && (U32.is_eq(id,63) || U32.is_eq(id,67)))),
        u => X198WOp{name,buf,id},u => X198WNone{})
    case _: X198WNone{}

@unsafe
def agy_has_mem_body(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Load{n,t,b,o}},rest}: True{}
    case Con{P113DScalar{N111Store{t,b,o,v}},rest}: True{}
    case Con{P113DScalar{N111Offset{n,b,by}},rest}: True{}
    case Con{P113DScalar{N111Alloca{n,by,al}},rest}: True{}
    case Con{P113DScalar{N111If{c,yes,no}},rest}: agy_has_mem_scalars(yes) || agy_has_mem_scalars(no) || agy_has_mem_body(rest)
    case Con{P113DIf{c,yes,no},rest}: agy_has_mem_body(yes) || agy_has_mem_body(no) || agy_has_mem_body(rest)
    case Con{head,rest}: agy_has_mem_body(rest)

@unsafe
def w4_cse_comm(+op: String) -> Bool:
  match op:
    case SCon{h,t}:
      +c = Char.to_u32(h)
      nt_choose(Bool,U32.is_eq(c,97),u => agy_str_eq(t,"dd") || agy_str_eq(t,"nd"),u =>
      nt_choose(Bool,U32.is_eq(c,109),u => agy_str_eq(t,"ul"),u =>
      nt_choose(Bool,U32.is_eq(c,111),u => agy_str_eq(t,"r"),u =>
      nt_choose(Bool,U32.is_eq(c,120),u => agy_str_eq(t,"or"),u => False{}))))
    case SNil{}: False{}

law x186_ft_find:
  for trie: X186FactTrie
  for +h: U32
  List<&2,X186Expr>

@unsafe
def w5b_ft_find_br(bit: U32, l: X186FactTrie, r: X186FactTrie, +h: U32) -> List<&2,X186Expr>:
  match bit:
    case 0: x186_ft_find(l,h)
    case _: x186_ft_find(r,h)

@unsafe
def x186_ft_find(trie, h):
  match trie:
    case X186FTNil{}: []
    case X186FTLeaf{stored,items}: w5b_ft_find_leaf(U32.is_eq(stored,h),items)
    case X186FTNode{stored,mask,l,r}: w5b_ft_find_br(U32.and(h,mask),l,r,h)

@unsafe
def x186_ft_join(+trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  w5b_ft_join_br(U32.and(h,mask),trie,item,h,stored,mask)

law x186_at_find:
  for trie: X186AliasTrie
  for +h: U32
  List<&2,X186Alias>

@unsafe
def w5b_at_find_br(bit: U32, l: X186AliasTrie, r: X186AliasTrie, +h: U32) -> List<&2,X186Alias>:
  match bit:
    case 0: x186_at_find(l,h)
    case _: x186_at_find(r,h)

@unsafe
def x186_at_find(trie, h):
  match trie:
    case X186ATNil{}: []
    case X186ATLeaf{stored,items}: w5b_at_find_leaf(U32.is_eq(stored,h),items)
    case X186ATNode{stored,mask,l,r}: w5b_at_find_br(U32.and(h,mask),l,r,h)

@unsafe
def x186_at_join(+trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  w5b_at_join_br(U32.and(h,mask),trie,item,h,stored,mask)

@unsafe
def x186_e_value(value: N111Value, aliases: List<&2,X186Alias>) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias(aliases,name)
    case _: value

law x186_e_kill_aliases:
  for aliases: List<&2,X186Alias>
  for +name: String
  List<&2,X186Alias>

@unsafe
def w5_kill_alias_if(drop: Bool, alias: X186Alias, rest: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match drop:
    case True{}: x186_e_kill_aliases(rest,name)
    case False{}: Con{alias,x186_e_kill_aliases(rest,name)}

@unsafe
def x186_e_kill_aliases(aliases, name):
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          w5_kill_alias_if(String.eq(result,name) || x185_sf_source(value,name),alias,rest,name)

@unsafe
def w4c_dia_pure_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+n,+t,_}: Bool.not(x181_register_reserved(n)) && w4c_sel_width(t)
    case N111Bin{+n,+t,+op,_,_}: Bool.not(x181_register_reserved(n)) && w4k_pure_bin(op) && w4c_sel_width(t)
    case _: False{}

# ---- W5-R1 Pass 3: Multi-Level Pure Scalar cmov Select Helpers ----
@unsafe
def w4c_dia_last_scalar(stmt: N111Stmt) -> W4CLastDst:
  match stmt:
    case N111Set{n,t,_}: W4CLast{n,t}
    case N111Bin{n,t,+op,_,_}:
      W4CLast{n,nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => t)}
    case _: W4CLastNone{}

@unsafe
def w5_as_snap(st: P113DStmt) -> W5SnapSet:
  match st:
    case P113DScalar{sc}: w5_as_snap_sc(sc)
    case _: W5SnapNone{}

@unsafe
def w5_is_cmp0_local(op: String, wantOp: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{0,0}: nt_choose(String,agy_str_eq(op,wantOp),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_is_sub1_local(op: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{1,0}: nt_choose(String,agy_str_eq(op,"sub"),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_nc_val_ok(+v: N111Value, +dst: String, +x: String, +c: String) -> Bool:
  w4c_sel_val(v) && Bool.not(w5_val_eq_name(v,dst)) && Bool.not(w5_val_eq_name(v,x)) && Bool.not(w5_val_eq_name(v,c))

@unsafe
def w5_nc_finish(ch: W5NatChain, +origX: String, +cName: String, +cTyp: N111Type,
    +dst: String, +dstTyp: N111Type, +tail: List<&2,P113DStmt>, +fallback: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match ch:
    case W5NatChain{arms,defVal}:
      Con{P113DScalar{N111Set{dst,dstTyp,defVal}},w5_nc_emit_arms(arms,origX,cName,cTyp,dst,dstTyp,tail)}
    case W5NatChainNone{}: fallback

@unsafe
def w4c_su_subst(v: N111Value, +old: String, +fresh: String) -> N111Value:
  match v:
    case N111Local{+n}: nt_choose(N111Value,agy_str_eq(n,old),u => N111Local{fresh},u => N111Local{n})
    case _: v

@unsafe
def w5b_const_cmp(+op: String, +al: U32, +ah: U32, +bl: U32, +bh: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,agy_str_eq(op,"eq"),
    u => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),v => 1,v => 0)},
    u => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ne"),
      v => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),w => 0,w => 1)},
      v => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ult"),
        w => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_lt(al,bl)),z => 1,z => 0)},
        w => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ule"),
          z => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_le(al,bl)),q => 1,q => 0)},
          z => None{}))))

@unsafe
def w5b_take_sets_rev(rev: List<&2,P113DStmt>, +sets: List<&2,P113DStmt>) -> W5BSplitSets:
  match rev:
    case Nil{}: W5BSplitSets{[],sets}
    case Con{+h,+t}:
      nt_choose(W5BSplitSets,w5b_is_set(h),
        u => w5b_take_sets_rev(t,Con{h,sets}),
        u => W5BSplitSets{nt_reverse(P113DStmt,Con{h,t},[]),sets})

@unsafe
def x186_f_proven_read_footprints(nodes: List<&2,X186FloatNode>) -> List<&2,P113DStmt>:
  x186_f_placement_rows(nodes)

@unsafe
def x186_x_cut(scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}: X186XScan{x185_t_cut(ranges),missing()}

@unsafe
def x186_x_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 14
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),u => index,
      u => x186_x_pick(rest,first,U32.inc(index)))

@unsafe
def w4b_zeros(+n: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => [],u => Con{0,w4b_zeros(U32.sub(n,1))})

@unsafe
def x186_x_move(+source: X187Operand, +target: X187Operand) -> X188Seq:
  nt_choose(X188Seq,x188_operand_same(source,target),u => X188Empty{},u => x188_i2("movaps",source,target))

@unsafe
def x186_x_direct(source: Maybe<&2,X187Operand>, target: X187Operand) -> Bool:
  match source:
    case Some{operand}: Bool.not(x188_operand_same(operand,target))
    case None{}: False{}

# Right is snapshotted first when its home aliases the arithmetic destination.
# The instruction still computes left OP right in the original operand order.
@unsafe
def w2b_x_same_opt(source: Maybe<&2,X187Operand>, target: X187Operand) -> Bool:
  match source:
    case Some{op}: x188_operand_same(op,target)
    case None{}: False{}

@unsafe
def w2b_replace_nth(vals: List<&2,N111Value>, +idx: U32, +repl: N111Value) -> List<&2,N111Value>:
  match vals:
    case Nil{}: []
    case Con{v,+rest}:
      nt_choose(List<&2,N111Value>,U32.is_eq(idx,0),u => Con{repl,rest},u => Con{v,w2b_replace_nth(rest,U32.sub(idx,1),repl)})

@unsafe
def w2_xl_nth(vals: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:
  match vals:
    case Nil{}: None{}
    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{v},u => w2_xl_nth(rest,U32.sub(idx,1)))

@unsafe
def w2_vals_reads(+name: String, values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{v,rest}: w2_val_reads(name,v) || w2_vals_reads(name,rest)

@unsafe
def w2_dstmt_writes(+name: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_scalar_writes(name,s)
    case P113DCall{names,target,args}: w2_names_has(name,names)
    case _: False{}

@unsafe
def w2_int_inv(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "jne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "je",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "jae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "ja",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "jb",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "jge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "jg",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def w2_tbl_match(nodes: List<&2,X186FloatNode>) -> W2TblMatch:
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{inside,N111U64{},op,+val,N111Const{+last,0}}}},
         Con{X186FloatBranch{N111Local{inside2},
               Con{X186FloatPlain{P113DScalar{N111Set{idx1,N111U64{},+val2}}},Nil{}},
               Con{X186FloatPlain{P113DScalar{N111Set{idx2,N111U64{},N111Const{+last2,0}}}},Nil{}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{bytes,N111U64{},shlop,N111Local{idx3},N111Const{3,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Offset{addr,N111Symbol{sym},N111Local{bytes2}}}},
         Con{X186FloatPlain{P113DScalar{N111Load{dest,N111U64{},N111Local{addr2},0}}},rest}}}}}:
      nt_choose(W2TblMatch,
        agy_str_eq(inside,"p195t_inside") && agy_str_eq(inside2,"p195t_inside") &&
        agy_str_eq(op,"ult") && agy_str_eq(idx1,"p195t_index") && agy_str_eq(idx2,"p195t_index") &&
        agy_str_eq(idx3,"p195t_index") && agy_str_eq(bytes,"p195t_bytes") && agy_str_eq(bytes2,"p195t_bytes") &&
        agy_str_eq(shlop,"shl") && agy_str_eq(addr,"p195t_address") && agy_str_eq(addr2,"p195t_address") &&
        U32.is_eq(last,last2) && w2_val_eq(val,val2),
        u => W2TblHit{dest,sym,val,last,rest},
        u => W2TblMiss{})
    case _: W2TblMiss{}

@unsafe
def w2_xl_safe_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_xl_safe_scalar(s)
    case P113DCall{ns,t,args}: False{}
    case P113DIf{c,y,n}: False{}
    case _: True{}

law w2_xl_float_used:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_float_used(name,nodes):
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatValues{dest,+id,l,r},rest}:
      (Bool.not(U32.is_eq(id,23)) && (w2_val_reads(name,l) || w2_val_reads(name,r))) || w2_xl_float_used(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_float_used(name,y) || w2_xl_float_used(name,n) || w2_xl_float_used(name,rest)
    case Con{h,rest}: w2_xl_float_used(name,rest)

@unsafe
def w2_xl_add_const(v: N111Value, +acc: List<&2,U32>) -> List<&2,U32>:
  match v:
    case N111Const{+lo,0}:
      nt_choose(List<&2,U32>,Bool.not(U32.is_eq(lo,0)) && Bool.not(w2_xl_u32_in(lo,acc)),
        u => Con{lo,acc},u => acc)
    case _: acc

@unsafe
def w4_xl_val_not_other_param(found: Maybe<&2,N111Value>, +self: String, +tparams: List<&2,String>) -> Bool:
  match found:
    case Some{N111Local{+x}}: agy_str_eq(x,self) || Bool.not(w2_names_has(x,tparams))
    case _: True{}

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def x194fv_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: x194fv_name(name) && x194fv_names(rest)

def x194fv_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x194fv_name(name)
    case _: True{}

@unsafe
def x194fv_closed(body: List<&2,X186FloatNode>, +name: String, +fuel: U32) -> Bool:
  match body:
    case Con{X186FloatValues{+destination,id,left,right},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case Con{X186FloatPlain{P113DScalar{N111Set{+destination,N111U64{},value}}},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case _: False{}

@unsafe
def w2_fc_finite_some(+bits: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,j_private_float_finite(bits),u => Some{bits},u => None{})

@unsafe
def w5b_l_edges_row(hit: U32, +old: U32, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32) -> U32:
  match hit:
    case 0: old
    case _:
      +a = w5b_u32_if_nz(U32.and(bit,before),before)
      +b = w5b_u32_if_nz(U32.and(bit,after),aw)
      +c = w5b_u32_if_nz(U32.and(bit,writes),after)
      U32.or(old,U32.and(U32.or(a,U32.or(b,c)),U32.not(bit)))

@unsafe
def x190_l_position(+name: String, params: List<&2,String>, +index: U32) -> U32:
  match params:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,agy_str_eq(name,head),u => index,u => x190_l_position(name,rest,U32.inc(index)))

@unsafe
def x190_l_pick(groups: List<&2,U32>, +edges: U32, +position: U32, +register: U32) -> U32:
  match groups:
    case Nil{}: 5
    case Con{mask,rest}:
      nt_choose(U32,U32.is_eq(U32.and(mask,edges),0) && U32.is_ge(position,x190_l_abi(register)),
        u => register,u => x190_l_pick(rest,edges,position,U32.inc(register)))

@unsafe
def x190_l_group(groups: List<&2,U32>, +register: U32, +bit: U32) -> List<&2,U32>:
  match groups:
    case Nil{}: []
    case Con{+mask,+rest}: nt_choose(List<&2,U32>,U32.is_eq(register,0),
      u => Con{U32.or(mask,bit),rest},u => Con{mask,x190_l_group(rest,U32.sub(register,1),bit)})

@unsafe
def x190_l_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +register: U32, +seen: Bool) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && U32.is_eq(U32.and(mask,edges),0) && U32.is_ge(position,x190_l_abi(register)))) &&
        x190_l_valid_groups(rest,bit,edges,position,U32.inc(register),seen || here)

@unsafe
def x190_l_home(groups: List<&2,U32>, +bit: U32, +register: U32) -> U32:
  match groups:
    case Nil{}: 5
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_l_home(rest,bit,U32.inc(register)),u => register)

@unsafe
def x203_prefix(rows: List<&2,X181RegisterChoice>, +limit: U32) -> List<&2,X181RegisterChoice>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_choose(List<&2,X181RegisterChoice>,U32.is_eq(limit,0),
      u => [],u => Con{head,x203_prefix(rest,U32.sub(limit,1))})

def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,U32.is_lt(color,4),u => U32.and(edges,U32.not(bit)),u => edges)

def x190_j_allowed(bit: U32, edges: U32, position: U32, +color: U32) -> Bool:
  nt_choose(Bool,U32.is_lt(color,4),u => True{},u =>
    U32.is_lt(color,9) && U32.is_eq(U32.and(bit,edges),0) && U32.is_ge(position,x190_l_abi(U32.sub(color,4))))

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def w5c_occ_add(occ: List<&2,List<&2,W5CIntv>>, +idx: U32, +intv: W5CIntv) -> List<&2,List<&2,W5CIntv>>:
  match occ:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,List<&2,W5CIntv>>,U32.is_eq(idx,0),
        u => Con{Con{intv,head},rest},
        u => Con{head,w5c_occ_add(rest,U32.sub(idx,1),intv)})

law w5c_pj_pick:
  for ends: List<&2,U32>
  for occ: List<&2,List<&2,W5CIntv>>
  for +first: U32
  for +last: U32
  for +index: U32
  U32

@unsafe
def w5c_pj_pick_step(+endPos: U32, +restE: List<&2,U32>, occ: List<&2,List<&2,W5CIntv>>,
    +first: U32, +last: U32, +index: U32) -> U32:
  match occ:
    case Nil{}: 5
    case Con{olist,+restO}:
      nt_choose(U32,U32.is_lt(endPos,first) && w5c_intv_disjoint(first,last,olist),
        u => index,
        u => w5c_pj_pick(restE,restO,first,last,U32.inc(index)))

@unsafe
def w5c_pj_pick(ends,occ,first,last,index):
  match ends:
    case Nil{}: 5
    case Con{endPos,restE}: w5c_pj_pick_step(endPos,restE,occ,first,last,index)

@unsafe
def x190_branch_inverse(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "jne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "je",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "jae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "ja",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "jb",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "jge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "jg",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def x190_branch_terminal(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DResult{values},rest}: True{}
    case Con{P113DAgain{values},rest}: True{}
    case Con{P113DScalar{N111Return{value}},rest}: True{}
    case Con{P113DIf{condition,yes,no},rest}:
      (x190_branch_terminal(yes) && x190_branch_terminal(no)) || x190_branch_terminal(rest)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      (x190_branch_terminal(x181_scalar_rows(yes)) && x190_branch_terminal(x181_scalar_rows(no))) || x190_branch_terminal(rest)
    case Con{head,rest}: x190_branch_terminal(rest)

@unsafe
def x191_scale(+op: String, value: N111Value) -> U32:
  match value:
    case N111Const{+lo,0}:
      nt_choose(U32,agy_str_eq(op,"mul") &&
          (U32.is_eq(lo,1) || U32.is_eq(lo,2) || U32.is_eq(lo,4) || U32.is_eq(lo,8)),
        u => lo,u => nt_choose(U32,agy_str_eq(op,"shl") && U32.is_le(lo,3),
          v => x191_shift_scale(lo),v => 0))
    case _: 0

@unsafe
def x191_commutative(+op: String) -> Bool:
  x191_alu(op) && Bool.not(agy_str_eq(op,"sub"))

@unsafe
def x192_address_lookup(aliases: List<&2,X192AddressAlias>, +name: String) -> Maybe<&2,X191Address>:
  match aliases:
    case Nil{}: None{}
    case Con{X192AddressAlias{other,address,reads},rest}:
      nt_choose(Maybe<&2,X191Address>,agy_str_eq(name,other),u => Some{address},u => x192_address_lookup(rest,name))

@unsafe
def x192_address_used(aliases: List<&2,X192AddressAlias>, +name: String) -> List<&2,X192AddressAlias>:
  match aliases:
    case Nil{}: []
    case Con{X192AddressAlias{+other,address,+reads},rest}:
      Con{X192AddressAlias{other,address,nt_choose(U32,agy_str_eq(name,other),u => U32.inc(reads),u => reads)},
        x192_address_used(rest,name)}

@unsafe
def x192_address_writes_alias(aliases: List<&2,X192AddressAlias>, +name: String) -> Bool:
  match aliases:
    case Nil{}: False{}
    case Con{X192AddressAlias{other,X191Address{base,index,scale,disp},reads},rest}:
      agy_str_eq(name,other) || x185_sf_source(base,name) || x185_sf_source(index,name) ||
        x192_address_writes_alias(rest,name)

@unsafe
def x191_ff_store(item: X187Parsed) -> X191FrameStore:
  match item:
    case PInst{X187Instruction{op,[X187Reg{+source,64,False{}},X187Mem{5,+displacement}]}}:
      nt_choose(X191FrameStore,agy_str_eq(op,"movq") && x191_ff_register(source) && x191_ff_private(displacement),
        u => X191FrameStore{source,displacement},u => X191FrameStoreNone{})
    case _: X191FrameStoreNone{}

@unsafe
def x191_ff_item(+item: X187Parsed, previous: X191FrameStore) -> X188Seq:
  match item previous:
    case PInst{X187Instruction{op,[X187Mem{5,offset},X187Reg{+destination,64,False{}}]}} X191FrameStore{+source,displacement}:
      nt_choose(X188Seq,agy_str_eq(op,"movq") && U32.is_eq(offset,displacement) && x191_ff_register(destination),
        u => nt_choose(X188Seq,U32.is_eq(source,destination),v => X188Empty{},
          v => x188_i2("movq",x188_reg(source,64),x188_reg(destination,64))),
        u => X188One{item})
    case _ _: X188One{item}

@unsafe
def p198q_search(+d: U32, +q: U32, +r: U32, +s: U32, +scale: U32) -> P198Quot:
  nt_choose(P198Quot,U32.is_le(U32.sub(d,r),scale) && U32.is_lt(q,4294967295),
    u => P198Magic{U32.inc(q),U32.add(32,s)},u =>
    nt_choose(P198Quot,U32.is_lt(q,2147483648) && U32.is_lt(s,16),v =>
      p198q_search(d,U32.add(U32.mul(q,2),U32.div(U32.mul(r,2),d)),U32.mod(U32.mul(r,2),d),U32.inc(s),U32.mul(scale,2)),
      v => P198NoQuot{}))

@unsafe
def p198q_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => p198q_log(U32.shrn(d,1n),U32.inc(shift)))

@unsafe
def x198qm_imm(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Imm{value,0},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,agy_str_eq(op,"movabsq") && U32.is_eq(dst,target),u => value,u => 0)
    case _: 0

@unsafe
def x198qm_lea(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Mem{5,offset},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,agy_str_eq(op,"leaq") && U32.is_eq(dst,target),u => offset,u => 0)
    case _: 0

@unsafe
def w4_qm_load0_src(item: X188Seq) -> Maybe<&2,X187Operand>:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{+src,64,False{}},X187Reg{11,64,False{}}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq") && U32.is_lt(src,16) &&
          Bool.not(U32.is_eq(src,4) || U32.is_eq(src,5) || U32.is_eq(src,10) || U32.is_eq(src,11)),
        u => Some{x188_reg(src,32)},u => None{})
    case X188One{PInst{X187Instruction{op,[X187Mem{5,+disp},X187Reg{11,64,False{}}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq"),u => Some{X187Mem{5,disp}},u => None{})
    case _: None{}

@unsafe
def w4_qm_store0_direct(item: X188Seq) -> Maybe<&2,X187Operand>:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{+src,64,False{}},X187Mem{10,0}]}}}:
      nt_choose(Maybe<&2,X187Operand>,agy_str_eq(op,"movq") && U32.is_lt(src,16) &&
          Bool.not(U32.is_eq(src,4) || U32.is_eq(src,5) || U32.is_eq(src,10)),
        u => Some{x188_reg(src,32)},u => None{})
    case _: None{}

@unsafe
def w2c_drop_movd_roundtrip(output: List<&2,X188Seq>, +r: U32, +x: U32) -> Bool:
  match output:
    case Con{prev,rest}: w2c_movd_inverse(prev,r,x)
    case Nil{}: False{}

law x197d_flags_dead:
  for todo: List<&2,X188Seq>
  for +budget: U32
  Bool

@unsafe
def x197d_flags_next(next: Maybe<&2,X197DHead>, budget: U32) -> Bool:
  match next:
    case Some{X197DHead{PInst{X187Instruction{+op,[a,b]}},rest}}:
      nt_choose(Bool,x197d_flag_kill(op),u => True{},u =>
        nt_choose(Bool,x197d_flag_pass(op),v => x197d_flags_dead(rest,budget),v => False{}))
    case _: False{}

@unsafe
def x197d_flags_dead(todo,budget):
  nt_choose(Bool,U32.is_gt(budget,0),u => x197d_flags_next(x197d_next(todo),U32.sub(budget,1)),u => False{})

# Both operands must already be valid signed32 machine immediates. Negating
# INT32_MIN cannot fit a LEA displacement and retains the exact original pair.
@unsafe
def x197d_displacement(+op: String, +lo: U32, +hi: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,x187_e_signed32(lo,hi),u =>
    nt_choose(Maybe<&2,U32>,agy_str_eq(op,"addq"),v => Some{lo},v =>
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,"subq") && Bool.not(U32.is_eq(lo,2147483648)),
        w => Some{U32.sub(0,lo)},w => None{})),u => None{})

@unsafe
def w4_peep_flat(todo: List<&2,X188Seq>, acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match todo:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{X188Empty{},rest}: w4_peep_flat(rest,acc)
    case Con{X188Join{a,b},rest}: w4_peep_flat(Con{a,Con{b,rest}},acc)
    case Con{X188One{item},rest}: w4_peep_flat(rest,Con{item,acc})

@unsafe
def w4_peep_flags_kill_op(+op: String) -> Bool:
  x197d_flag_kill(op) || agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || agy_str_eq(op,"testb") ||
  agy_str_eq(op,"andl") || agy_str_eq(op,"andq") || agy_str_eq(op,"orl") || agy_str_eq(op,"orq") ||
  agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq") || agy_str_eq(op,"imull") || agy_str_eq(op,"imulq") ||
  agy_str_eq(op,"jmp") || agy_str_eq(op,"ret") || agy_str_eq(op,"call")

@unsafe
def w4_peep_reg_dead(+r: U32, items: List<&2,X187Parsed>, +budget: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{+op,[+src,+dst]}},+rest}:
      nt_choose(Bool,U32.is_eq(budget,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
            agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq"),
          v => nt_choose(Bool,w4_peep_op_uses_reg(src,r),w => False{},w =>
            nt_choose(Bool,w4_peep_dst_kills(dst,r),z => True{},z =>
              nt_choose(Bool,w4_peep_op_uses_reg(dst,r),q => False{},q => w4_peep_reg_dead(r,rest,U32.sub(budget,1))))),
          v => nt_choose(Bool,(agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq")) && w4_peep_xor_self_kills(src,dst,r),
            w => True{},
            w => nt_choose(Bool,w4_peep_op_uses_reg(src,r) || w4_peep_op_uses_reg(dst,r),
              z => False{},z => w4_peep_reg_dead(r,rest,U32.sub(budget,1))))))
    case Con{PInst{X187Instruction{+op,[X187Target{_}]}},rest}:
      nt_choose(Bool,U32.is_gt(budget,0) && agy_str_eq(op,"call") &&
          (U32.is_eq(r,0) || U32.is_eq(r,2) || U32.is_eq(r,10) || U32.is_eq(r,11)),
        v => True{},v => False{})
    case _: False{}

@unsafe
def w4_leaf_collect_saves(+items: List<&2,X187Parsed>, +prefix: List<&2,X187Parsed>, +saved: List<&2,U32>) -> W4LeafPrologue:
  match items:
    case Con{PInst{X187Instruction{+op,[X187Reg{+r,64,False{}},X187Mem{5,+disp}]}},+rest}:
      nt_choose(W4LeafPrologue,agy_str_eq(op,"movq") && w4_leaf_is_callee(r,disp),
        u => w4_leaf_collect_saves(rest,prefix,Con{r,saved}),
        u => W4LeafPrologue{prefix,nt_reverse(U32,saved,[]),Con{PInst{X187Instruction{op,[X187Reg{r,64,False{}},X187Mem{5,disp}]}},rest}})
    case _: W4LeafPrologue{prefix,nt_reverse(U32,saved,[]),items}

@unsafe
def w4_leaf_match_end(items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Con{PInst{X187Instruction{e1,[X187Reg{5,64,False{}},X187Reg{4,64,False{}}]}},
         Con{PInst{X187Instruction{e2,[X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{e3,Nil{}}},rest}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(e1,"movq") && agy_str_eq(e2,"popq") && agy_str_eq(e3,"ret"),
        u => Some{rest},u => None{})
    case _: None{}

@unsafe
def w4_leaf_args_bad(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4_leaf_arg_bad(a) || w4_leaf_args_bad(rest)

@unsafe
def w4_leaf_pushes(saved: List<&2,U32>) -> List<&2,X188Seq>:
  match saved:
    case Nil{}: []
    case Con{r,rest}: Con{x188_i1("pushq",x188_reg(r,64)),w4_leaf_pushes(rest)}

@unsafe
def w4_leaf_pops_rev(saved: List<&2,U32>, acc: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match saved:
    case Nil{}: acc
    case Con{r,rest}: w4_leaf_pops_rev(rest,Con{x188_i1("popq",x188_reg(r,64)),acc})

@unsafe
def w4_leaf_args_use_r12(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4_leaf_arg_uses_r12(a) || w4_leaf_args_use_r12(rest)

@unsafe
def w4_leaf_drop_r12_list(saved: List<&2,U32>) -> List<&2,U32>:
  match saved:
    case Nil{}: []
    case Con{+r,+rest}: nt_choose(List<&2,U32>,U32.is_eq(r,12),u => w4_leaf_drop_r12_list(rest),u => Con{r,w4_leaf_drop_r12_list(rest)})

@unsafe
def w4_leaf_strip_r12_init(items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}: nt_choose(List<&2,X187Parsed>,w4_leaf_is_r12_init(h),u => w4_leaf_strip_r12_init(rest),u => Con{h,w4_leaf_strip_r12_init(rest)})

@unsafe
def w4b_args_read_reg(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4b_op_reads_reg(r,a) || w4b_args_read_reg(r,rest)

# W5C-C1: O(1) first-char opcode classifiers + O(log L) W5BLblTrie + zero-closure w4b_reg_dead
# (fused with W5B-R2 seen cycle-set, setcc;movzbl overwrite check, and hops=8)
@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_wo_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_alu_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_alu32_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5b_dead_after_setcc(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>) -> Bool:
  match args:
    case Con{X187Reg{dr,8,False{}},Nil{}}:
      U32.is_eq(dr,r) && w5b_dead_movzbl(r,rest)
    case _: False{}

@unsafe
def w5c_lbl_find_leaf(eq: Bool, items: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: w5c_lbl_bkt_find(items,lbl)
    case False{}: None{}

@unsafe
def w5c_lbl_join(+trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  w5c_lbl_join_br(U32.and(h,mask),trie,entry,h,stored,mask)

@unsafe
def w4b_op_reg_mask(op: X187Operand) -> U32:
  match op:
    case X187Reg{i,_,False{}}: w4b_bit(i)
    case X187Mem{b,_}: w4b_bit(b)
    case X187Indexed{b,i,_,_}: U32.or(w4b_bit(b),w4b_bit(i))
    case _: 0

@unsafe
def w4b_is_magic_pair(a: W4BImmReg, b: W4BRR) -> Maybe<&2,U32>:
  match a b:
    case W4BImmReg{op0,m,hi,r0,w0} W4BRR{op1,s,ws,d,wd}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op0,"movl") && U32.is_eq(hi,0) && U32.is_eq(r0,11) && U32.is_eq(w0,32) &&
          agy_str_eq(op1,"imulq") && U32.is_eq(s,11) && U32.is_eq(ws,64) && U32.is_eq(d,0) && U32.is_eq(wd,64) &&
          U32.is_ge(m,256),
        u => Some{m},u => None{})
    case _ _: None{}

@unsafe
def w4b_free_regs(cands: List<&2,U32>, +mask: U32) -> List<&2,U32>:
  match cands:
    case Nil{}: []
    case Con{+r,+rest}:
      nt_choose(List<&2,U32>,U32.is_eq(U32.and(mask,w4b_bit(r)),0),
        u => Con{r,w4b_free_regs(rest,mask)},
        u => w4b_free_regs(rest,mask))

@unsafe
def w4b_lookup_magic(+m: U32, mp: List<&2,W4BMagicMap>) -> Maybe<&2,U32>:
  match mp:
    case Nil{}: None{}
    case Con{W4BMagicEntry{imm,reg},rest}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(imm,m),u => Some{reg},u => w4b_lookup_magic(m,rest))

@unsafe
def w4b_take_exit_ret(next: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  match next:
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl),
        u => W4BExitSplit{nt_reverse(X187Parsed,Con{PInst{X187Instruction{"ret",[]}},acc},[]),rest},
        u => W4BExitNone{})
    case _: W4BExitNone{}

@unsafe
def w4b_test_inst(+r: U32, +w: U32) -> X187Parsed:
  nt_choose(X187Parsed,U32.is_eq(w,64),
    u => PInst{X187Instruction{"testq",[X187Reg{r,64,False{}},X187Reg{r,64,False{}}]}},
    u => PInst{X187Instruction{"testl",[X187Reg{r,32,False{}},X187Reg{r,32,False{}}]}})

@unsafe
def w4b_taildup_replace(items: List<&2,X187Parsed>, +mergeLbl: String, +mv: X187Parsed,
    +tst: X187Parsed, +jne: X187Parsed, +exitLbl: String) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(mergeLbl,w4b_as_branch(h)),
        u => Con{mv,Con{tst,Con{jne,Con{PInst{X187Instruction{"jmp",[X187Target{exitLbl}]}},
               w4b_taildup_replace(rest,mergeLbl,mv,tst,jne,exitLbl)}}}},
        u => Con{h,w4b_taildup_replace(rest,mergeLbl,mv,tst,jne,exitLbl)})

@unsafe
def w4c_taildup_replace2(items: List<&2,X187Parsed>, +mergeLbl: String, +mv1: X187Parsed, +mv2: X187Parsed,
    +tst: X187Parsed, +jne: X187Parsed, +exitLbl: String) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(mergeLbl,w4b_as_branch(h)),
        u => Con{mv1,Con{mv2,Con{tst,Con{jne,Con{PInst{X187Instruction{"jmp",[X187Target{exitLbl}]}},
               w4c_taildup_replace2(rest,mergeLbl,mv1,mv2,tst,jne,exitLbl)}}}}},
        u => Con{h,w4c_taildup_replace2(rest,mergeLbl,mv1,mv2,tst,jne,exitLbl)})

@unsafe
def w4c_as_addl_mem_reg(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Indexed{b,idx,sc,disp},Con{X187Reg{r,32,False{}},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"addl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

@unsafe
def w4c_as_movl_reg_mem(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Reg{r,32,False{}},Con{X187Indexed{b,idx,sc,disp},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"movl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

@unsafe
def w5_is_mov_not_writing(item: X187Parsed, +r: U32) -> Bool:
  match item:
    case PInst{X187Instruction{+op,args}}:
      (agy_str_eq(op,"movq") || agy_str_eq(op,"movl")) && w5_mov_args_ok(args,r)
    case _: False{}

@unsafe
def w5_is_testq_r(item: X187Parsed, +r: U32) -> Bool:
  w5_check_testq_r(w4b_as_rr(item),r)

@unsafe
def w5_check_jz_jnz(br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{+jop,_}: w4_peep_is_jz_jnz(jop)
    case W4BBranchNone{}: False{}

@unsafe
def w4c_map_get(m: W4CMap, +k: U32, +sh: U32) -> U32:
  match m:
    case W4CMEmpty{}: 0
    case W4CMLeaf{lk,lv}: nt_choose(U32,U32.is_eq(lk,k),u => lv,u => 0)
    case W4CMNode{z,o}:
      nt_choose(U32,U32.is_eq(U32.and(sh,1),0),
        u => w4c_map_get(z,k,U32.shr(sh)),
        u => w4c_map_get(o,k,U32.shr(sh)))

@unsafe
def w4c_shift_by(+x: U32, +n: U32) -> U32:
  nt_choose(U32,U32.is_eq(n,0),u => x,u => w4c_shift_by(U32.shr(x),U32.sub(n,1)))

@unsafe
def w4c_op_is_rbp_mem(op: X187Operand) -> Maybe<&2,U32>:
  match op:
    case X187Mem{+b,+d}: nt_choose(Maybe<&2,U32>,w4c_is_neg_rbp(b,d),u => Some{d},u => None{})
    case _: None{}

@unsafe
def w4c_args_has_rbp(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_op_has_rbp(a) || w4c_args_has_rbp(rest)

@unsafe
def w4c_args_read_xmm(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_op_is_xmm(r,a) || w4c_args_read_xmm(r,rest)

@unsafe
def w4c_as_movq_xm(item: X187Parsed) -> W4CMovqXmmMem:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{xr,_,True{}},Con{X187Mem{b,d},Nil{}}}}}:
      nt_choose(W4CMovqXmmMem,agy_str_eq(op,"movq") && w4c_is_neg_rbp(b,d),u => W4CMXMYes{xr,d},u => W4CMXMNo{})
    case _: W4CMXMNo{}

@unsafe
def w4c_as_load_xmm(item: X187Parsed) -> W4CLoadXmm:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CLoadXmm,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps"),u => W4CLXYes{op,src,dr},u => W4CLXNo{})
    case _: W4CLXNo{}

@unsafe
def w4c_as_fop_mem(item: X187Parsed) -> W4CFopMem:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CFopMem,w4c_is_fop(op) && w4c_is_neg_rbp(b,d),u => W4CFMYes{op,d,dr},u => W4CFMNo{})
    case _: W4CFMNo{}

@unsafe
def w4c_as_fop_any(item: X187Parsed) -> W4CFopAny:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CFopAny,w4c_is_fop(op),u => W4CFAYes{op,src,dr},u => W4CFANo{})
    case _: W4CFANo{}

@unsafe
def w4c_op_safe_for_xmm1(+disp: U32, +op: X187Operand) -> Bool:
  Bool.not(w4c_op_is_xmm(0,op)) && Bool.not(w4c_op_is_xmm(1,op)) && Bool.not(w4c_op_is_slot(disp,op))

@unsafe
def w4c_fwd_xmm1_inst(+disp: U32, inst: X187Instruction) -> Maybe<&2,X187Instruction>:
  match inst:
    case X187Instruction{+op,Con{X187Mem{b,d},Con{X187Reg{+dr,_,True{}},Nil{}}}}:
      nt_choose(Maybe<&2,X187Instruction>,w4c_is_fop(op) && U32.is_eq(b,5) && U32.is_eq(d,disp) && Bool.not(U32.is_eq(dr,1)),
        u => Some{X187Instruction{op,[x188_xmm(1),x188_xmm(dr)]}},u => None{})
    case _: None{}

@unsafe
def w4c_is_bb_end(item: X187Parsed) -> Bool:
  match item:
    case PLabel{_}: True{}
    case PInst{X187Instruction{op,_}}: w4c_is_ctrl(op)
    case _: True{}

@unsafe
def w4c_split_bb(items: List<&2,X187Parsed>, +cur: List<&2,X187Parsed>,
    +acc: List<&2,List<&2,X187Parsed>>) -> List<&2,List<&2,X187Parsed>>:
  match items:
    case Nil{}: nt_reverse(List<&2,X187Parsed>,Con{nt_reverse(X187Parsed,cur,[]),acc},[])
    case Con{+h,+rest}:
      match h:
        case PLabel{_}:
          w4c_split_bb(rest,[h],Con{nt_reverse(X187Parsed,cur,[]),acc})
        case PInst{X187Instruction{op,_}}:
          nt_choose(List<&2,List<&2,X187Parsed>>,w4c_is_ctrl(op),
            u => w4c_split_bb(rest,[],Con{nt_reverse(X187Parsed,Con{h,cur},[]),acc}),
            u => w4c_split_bb(rest,Con{h,cur},acc))
        case _: w4c_split_bb(rest,Con{h,cur},acc)

@unsafe
def w4c_replace_op(+from: U32, +to: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{+b,+d}: nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,from),u => X187Mem{5,to},u => X187Mem{b,d})
    case _: op

@unsafe
def w5_args_touch_slot(+disp: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w5_op_is_slot(disp,a) || w5_args_touch_slot(disp,rest)

@unsafe
def w4c_slot_written(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w5_inst_writes_slot(disp,h) || w4c_slot_written(disp,rest)

@unsafe
def w4c_gpr_in_args(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_gpr_in_op(r,a) || w4c_gpr_in_args(r,rest)

@unsafe
def w4c_as_load_r10(item: X187Parsed) -> Maybe<&2,U32>:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{r,w,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,"movq") && w4c_is_neg_rbp(b,d) && U32.is_eq(r,10) && U32.is_eq(w,64),
        u => Some{d},u => None{})
    case _: None{}

@unsafe
def w4c_as_store_r10_dst(dst: X187Operand) -> W4CStoreR10:
  match dst:
    case X187Mem{b,d}: nt_choose(W4CStoreR10,w4c_is_neg_rbp(b,d),v => W4CSRMem{d},v => W4CSRNo{})
    case X187Reg{dr,dw,False{}}: nt_choose(W4CStoreR10,U32.is_eq(dw,64) && Bool.not(U32.is_eq(dr,10)) && Bool.not(U32.is_eq(dr,4)) && Bool.not(U32.is_eq(dr,5)),v => W4CSRGpr{dr},v => W4CSRNo{})
    case _: W4CSRNo{}

@unsafe
def w5_count_slot_reads_args(+disp: U32, args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w5_count_slot_reads_args(disp,rest,w5_inc_if(w5_op_is_slot(disp,a),acc))

@unsafe
def w4c_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  w5_inst_writes_slot(disp,item)

@unsafe
def w5_as_movaps(item: X187Parsed) -> W5Movaps:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,_,True{}},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5Movaps,agy_str_eq(op,"movaps"),u => W5MAYes{sr,dr},u => W5MANo{})
    case _: W5MANo{}

@unsafe
def w5_as_movd_slot(item: X187Parsed) -> W5MovdSlot:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5MovdSlot,agy_str_eq(op,"movd") && U32.is_eq(b,5),u => W5MSYes{d,dr},u => W5MSNo{})
    case _: W5MSNo{}

@unsafe
def w5_as_xmm_prod(item: X187Parsed) -> W5XmmProd:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5XmmProd,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps") || agy_str_eq(op,"sqrtss"),
        u => W5XPYes{op,src,dr},u => W5XPNo{})
    case _: W5XPNo{}

@unsafe
def w5_xmm_fold_last(ma: W5Movaps, +i0: X187Parsed, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ma:
    case W5MAYes{a,b}:
      nt_choose(List<&2,X187Parsed>,U32.is_eq(a,b),
        u => nt_reverse(X187Parsed,acc,[]),
        u => nt_reverse(X187Parsed,Con{i0,acc},[]))
    case W5MANo{}: nt_reverse(X187Parsed,Con{i0,acc},[])

@unsafe
def w5_as_load_rbp(item: X187Parsed) -> W5LoadRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5LoadRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5LRYes{d,dr},u => W5LRNo{})
    case _: W5LRNo{}

@unsafe
def w5_as_store_rbp(item: X187Parsed) -> W5StoreRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Mem{b,d},Nil{}}}}}:
      nt_choose(W5StoreRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5SRYes{sr,d},u => W5SRNo{})
    case _: W5SRNo{}

@unsafe
def w5_as_movq_to_reg(item: X187Parsed) -> W5MovqToReg:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5MovqToReg,agy_str_eq(op,"movq"),u => W5MTRYes{src,dr},u => W5MTRNo{})
    case _: W5MTRNo{}

@unsafe
def w5_as_movq_from_reg(item: X187Parsed) -> W5MovqFromReg:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{dst,Nil{}}}}}:
      nt_choose(W5MovqFromReg,agy_str_eq(op,"movq"),u => W5MFRYes{sr,dst},u => W5MFRNo{})
    case _: W5MFRNo{}

@unsafe
def w5_as_setcc(item: X187Parsed) -> W5Setcc:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{r,8,False{}},Nil{}}}}:
      nt_choose(W5Setcc,w4_peep_is_setcc(op),u => W5SetYes{op,r},u => W5SetNo{})
    case _: W5SetNo{}

@unsafe
def w5_as_movzbl(item: X187Parsed) -> W5Movzbl:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,8,False{}},Con{X187Reg{dr,32,False{}},Nil{}}}}}:
      nt_choose(W5Movzbl,agy_str_eq(op,"movzbl"),u => W5MZYes{sr,dr},u => W5MZNo{})
    case _: W5MZNo{}

@unsafe
def w5_src_ok_cmov(+rN: U32, src: X187Operand) -> Bool:
  match src:
    case X187Reg{r,64,False{}}: w5_not_scratch(r) && Bool.not(U32.is_eq(r,rN))
    case X187Mem{b,_}: U32.is_eq(b,5)
    case _: False{}

@unsafe
def w5_dst_ok_cmov(+rN: U32, dst: X187Operand) -> Bool:
  match dst:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Reg{r,64,False{}}: Bool.not(U32.is_eq(r,rN)) && w5_not_scratch(r)
    case _: False{}

@unsafe
def w5_g11_inv_jcc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),v => "cmovneq",v => ""))

@unsafe
def w5b_g12_flip_cmov(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"cmovneq"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"cmoveq"),v => "cmovneq",v => ""))

@unsafe
def w5_op_flags(op: X187Operand) -> U32:
  match op:
    case X187Reg{_,_,True{}}: 1
    case X187Mem{b,d}: w5_bit_if(w4c_is_neg_rbp(b,d),2,0)
    case _: 0

@unsafe
def w5b_rew_op(+disp: U32, +rFree: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{b,+d}:
      nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,disp),
        u => x188_reg(rFree,64),u => X187Mem{b,d})
    case other: other

@unsafe
def w5b_inv_cc(+cc: String) -> String:
  nt_choose(String,agy_str_eq(cc,"e"),u => "ne",u =>
  nt_choose(String,agy_str_eq(cc,"ne"),u => "e",u =>
  nt_choose(String,agy_str_eq(cc,"z"),u => "nz",u =>
  nt_choose(String,agy_str_eq(cc,"nz"),u => "z",u =>
  nt_choose(String,agy_str_eq(cc,"a"),u => "be",u =>
  nt_choose(String,agy_str_eq(cc,"be"),u => "a",u =>
  nt_choose(String,agy_str_eq(cc,"ae"),u => "b",u =>
  nt_choose(String,agy_str_eq(cc,"b"),u => "ae",u =>
  nt_choose(String,agy_str_eq(cc,"g"),u => "le",u =>
  nt_choose(String,agy_str_eq(cc,"le"),u => "g",u =>
  nt_choose(String,agy_str_eq(cc,"ge"),u => "l",u =>
  nt_choose(String,agy_str_eq(cc,"l"),u => "ge",u => ""))))))))))))

@unsafe
def w5b_set_cc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"sete"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"setne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"seta"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"setae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"setb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"setbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"setg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"setge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"setl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"setle"),u => "le",u => ""))))))))))

@unsafe
def w5b_is_je_jne(item: X187Parsed) -> Maybe<&2,String>:
  match item:
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      nt_choose(Maybe<&2,String>,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),
        u => Some{"E:" ++ lbl},
        u => nt_choose(Maybe<&2,String>,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),
          v => Some{"N:" ++ lbl},v => None{}))
    case _: None{}

@unsafe
def w5b_jcc_name(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"je"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"jne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"jz"),u => "z",u =>
  nt_choose(String,agy_str_eq(op,"jnz"),u => "nz",u =>
  nt_choose(String,agy_str_eq(op,"ja"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"jae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"jb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"jbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"jg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"jge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"jl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"jle"),u => "le",u => ""))))))))))))

@unsafe
def w5c_movq_dst(inst: X187Parsed, +rD: U32) -> U32:
  match inst:
    case PInst{X187Instruction{op1,Con{X187Reg{r1,64,False{}},Con{X187Reg{r2,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op1,"movq") && U32.is_eq(r1,rD),u => r2,u => 99)
    case _: 99

@unsafe
def w7_len_gt(items: List<&2,X187Parsed>, +limit: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{_,rest}:
      nt_choose(Bool,U32.is_eq(limit,0),u => True{},u => w7_len_gt(rest,U32.sub(limit,1)))

@unsafe
def x199s_flat(todo: List<&2,X188Seq>, +fuel: U32, acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match todo:
    case Nil{}: Some{nt_reverse(X187Parsed,acc,[])}
    case Con{X188Empty{},rest}: x199s_flat(rest,fuel,acc)
    case Con{X188Join{a,b},rest}: x199s_flat(Con{a,Con{b,rest}},fuel,acc)
    case Con{X188One{item},rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fuel,0),u => None{},
        u => x199s_flat(rest,U32.sub(fuel,1),Con{item,acc}))

@unsafe
def x199s_plain(+op: String) -> Bool:
  x197d_flag_pass(op) || x197d_flag_kill(op) || agy_str_eq(op,"cmovaeq") || agy_str_eq(op,"cmovbq") ||
    agy_str_eq(op,"cmoveq") || agy_str_eq(op,"cmovneq") || agy_str_eq(op,"cmovaq") || agy_str_eq(op,"imull") || agy_str_eq(op,"imulq")

# Every admitted intervening operation has exactly two explicit operands.
# A label, other opcode, indirect clobber, call or control transfer ends the window.
@unsafe
def x199s_count_arg(arg: X187Operand, +disp: U32, +wide: Bool) -> U32:
  match arg:
    case X187Mem{5,+offset}: Bool.to_u32(U32.is_lt(U32.sub(offset,disp),8) ||
      U32.is_lt(U32.sub(disp,offset),nt_choose(U32,wide,u => 32,u => 8)))
    case X187Reg{5,width,False{}}: 3
    case X187Indexed{5,index,scale,offset}: 3
    case X187Indexed{base,5,scale,offset}: 3
    case _: 0

@unsafe
def x200s_canonical(+op: String, args: List<&2,X187Operand>) -> Bool:
  match args:
    case [a]: U32.is_eq(x200s_regnum(a),5) && (agy_str_eq(op,"pushq") || agy_str_eq(op,"popq"))
    case [a,b]:
      +l = x200s_regnum(a)
      +r = x200s_regnum(b)
      agy_str_eq(op,"movq") && ((U32.is_eq(l,4) && U32.is_eq(r,5)) || (U32.is_eq(l,5) && U32.is_eq(r,4)))
    case _: False{}

@unsafe
def x199s_lookup(found: List<&2,X191FrameStore>, +offset: U32) -> U32:
  match found:
    case Nil{}: 16
    case Con{X191FrameStore{r,d},rest}: nt_choose(U32,U32.is_eq(d,offset),u => r,u => x199s_lookup(rest,offset))
    case Con{X191FrameStoreNone{},rest}: x199s_lookup(rest,offset)

@unsafe
def x199s_load(+item: X187Parsed,+dst: U32,+reg: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_lt(reg,16),u => nt_choose(X188Seq,U32.is_eq(reg,dst),v => X188Empty{},
    v => x188_i2("movq",x188_reg(reg,64),x188_reg(dst,64))),u => X188One{item})

@unsafe
def x194_ps_source(names: List<&2,String>, value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x194_ps_member(names,name)
    case _: False{}

@unsafe
def x194_ps_disjoint(names: List<&2,String>, +other: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(x194_ps_member(other,name)) && x194_ps_disjoint(rest,other)

@unsafe
def x197ms_inverse(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "le",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "l",u => ""))))))))))

def x181_reg(n):
  match n:
    case 0: x188_reg(12,64)
    case 1: x188_reg(3,64)
    case 2: x188_reg(13,64)
    case 3: x188_reg(14,64)
    case _: x188_reg(15,64)

def x181_argreg(n):
  match n:
    case 0: x188_reg(7,64)
    case 1: x188_reg(6,64)
    case 2: x188_reg(2,64)
    case 3: x188_reg(1,64)
    case 4: x188_reg(8,64)
    case _: x188_reg(9,64)

@unsafe
def x181_if_end(+label: U32, +yes_end: Bool, +frame: X181Frame, no: X181Code) -> X181Code:
  match no:
    case X181Code{chunks,next,+terminal,error}:
      X181Code{nt_choose(List<&2,X188Seq>,yes_end && terminal,u => chunks,
        u => Con{X188One{PLabel{x181_label(U32.inc(label),frame)}},chunks}),next,yes_end && terminal,error}

@unsafe
def x181_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

law w2_asr_strip_self:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+a,N111U64{},N111Local{+b}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(a,b),u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},w2_asr_strip_self(rest)})
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case Con{P113DScalar{N111Bin{+d,+t,+op,N111Const{2,0},+x}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,N111Const{2,0},x}},w2_asr_strip_self(rest)})
    case Con{P113DScalar{N111Bin{+d,+t,+op,+x,N111Const{2,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,x,N111Const{2,0}}},w2_asr_strip_self(rest)})
    case Con{head,rest}: Con{head,w2_asr_strip_self(rest)}

@unsafe
def w5_vals_has(vs: List<&2,N111Value>, +target: String) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: w5_val_is(v,target) || w5_vals_has(rest,target)

@unsafe
def w5_args_has(args: List<&2,N111Arg>, +target: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w5_val_is(v,target) || w5_args_has(rest,target)

@unsafe
def x198a_temp(+name: String, +params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || x181_register_reserved(name) || nb_contains(params,name))

@unsafe
def x198a_word(value: N111Value, +params: List<&2,String>) -> Bool:
  match value:
    case N111Const{lo,hi}: True{}
    case N111Local{name}: nb_contains(params,name)
    case _: False{}

def x198_sym_node(+a: U32, +b: U32) -> U32:
  nt_choose(U32,x198_sym_range(a,3,6) && x198_sym_range(b,3,6),
    u => U32.add(256,U32.add(U32.mul(U32.sub(a,3),4),U32.sub(b,3))),
    u => nt_choose(U32,x198_sym_range(a,256,271) && x198_sym_range(b,256,271),
      v => U32.add(512,U32.add(U32.mul(U32.sub(a,256),16),U32.sub(b,256))),v => 0))

def x198_perm_reg(n: U32) -> X187Operand: x188_reg(n,64)

def x198_perm_slot(+slot: U32) -> X187Operand:
  X187Indexed{10,nt_choose(U32,U32.is_lt(slot,2),u => 8,u => 9),8,U32.mul(U32.and(slot,1),8)}

def agy_da_vals_use(vs: List<&2,N111Value>, +name: String) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: agy_da_val_uses(v,name) || agy_da_vals_use(rest,name)

def agy_da_args_use(args: List<&2,N111Arg>, +name: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: agy_da_val_uses(v,name) || agy_da_args_use(rest,name)

@unsafe
def x181_hygiene_name(+name: String) -> String:
  nt_choose(String,String.starts_with(name,"__x181"),
    u => "x86 reserved local name: " ++ name,u => "")

@unsafe
def x198n_get(+name: String, env: List<&2,X198NBinding>) -> X198NFact:
  match env:
    case Nil{}: X198NUnknown{}
    case Con{X198NBinding{key,+fact},rest}: nt_choose(X198NFact,agy_str_eq(name,key),u => fact,u => x198n_get(name,rest))

@unsafe
def x198n_constant(answer: P113KFact) -> X198NFact:
  match answer:
    case P113KFact{bits,exact,lo,hi}: nt_choose(X198NFact,exact,u => X198NConst{lo,hi},u => X198NUnknown{})

def x198n_name(+name: String, +params: List<&2,String>) -> Bool:
  Bool.not(nb_contains(params,name) || String.starts_with(name,"p198n_") || String.starts_with(name,"p198a_"))

@unsafe
def x198n_split(body: List<&2,P113DStmt>) -> Maybe<&2,X198NLoop>:
  match body:
    case [P113DAgain{values}]: Some{X198NLoop{[],values}}
    case Con{head,rest}: x198n_split_add(head,x198n_split(rest))
    case Nil{}: None{}

# These kinds come from the verified direct worker, before conversion to names.
@unsafe
def x198n_types(params: List<&2,NC_Binding>, +fuel: String) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,+name,+kind},rest}:
      nt_choose(Bool,agy_str_eq(name,fuel),u => x198n_fuel_kind(kind),u => x198n_word_kind(kind)) && x198n_types(rest,fuel)

@unsafe
def x198n_initial(params: List<&2,NC_Binding>, +fuel: String, +mode: String) -> List<&2,X198NBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198NBinding{name,nt_choose(X198NFact,agy_str_eq(name,fuel),u => X198NNonzero{False{}},u =>
        nt_choose(X198NFact,agy_str_eq(name,mode),v => X198NNonzero{True{}},v => X198NAlias{name,True{}}))},x198n_initial(rest,fuel,mode)}

@unsafe
def x198n_return(values: List<&2,N111Value>, +params: List<&2,String>, +fuel: String, +mode: String) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{N111Const{lo,hi},rest}: x198n_return(rest,params,fuel,mode)
    case Con{N111Local{+name},rest}: nb_contains(params,name) && Bool.not(agy_str_eq(name,fuel) || agy_str_eq(name,mode)) && x198n_return(rest,params,fuel,mode)
    case _: False{}

@unsafe
def x198n_composed(choice: Maybe<&2,String>, +test: P113DStmt, +condition: N111Value, +returned: List<&2,N111Value>, +positive: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x198n_selected(choice,[test,P113DIf{condition,[P113DResult{returned}],positive}],test,condition,returned,positive)

# Experimental runtime fixed-state certificate. Facts: 0 unknown, 1 independent
# of fuel/counter, 2 counter plus an independent U32 delta, 3 full fuel minus one.
@unsafe
def x198o_get(+name: String, env: List<&2,X198ABinding>) -> U32:
  match env:
    case Nil{}: 0
    case Con{X198ABinding{key,fact},rest}: nt_choose(U32,agy_str_eq(name,key),u => fact,u => x198o_get(name,rest))

@unsafe
def x198o_initial(params: List<&2,NC_Binding>, +fuel: String, +counter: String) -> List<&2,X198ABinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198ABinding{name,nt_choose(U32,agy_str_eq(name,fuel),u => 0,u => nt_choose(U32,agy_str_eq(name,counter),v => 2,v => 1))},x198o_initial(rest,fuel,counter)}

@unsafe
def x198o_argument(params: List<&2,String>, values: List<&2,N111Value>, +wanted: String) -> N111Value:
  match params values:
    case Con{name,ps} Con{+value,vs}: nt_choose(N111Value,agy_str_eq(name,wanted),u => value,u => x198o_argument(ps,vs,wanted))
    case _ _: N111Const{0,0}

@unsafe
def x198o_guards(params: List<&2,String>, values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match params values:
    case Con{+name,ps} Con{+value,vs}:
      +rest = x198o_guards(ps,vs,fuel,counter)
      nt_choose(List<&2,P113DStmt>,agy_str_eq(name,fuel) || agy_str_eq(name,counter) || x185_sf_source(value,name),u => rest,u =>
        Con{P113DScalar{N111Bin{"p198a_eq",N111U64{},"eq",N111Local{name},value}},Con{P113DScalar{N111Bin{"p198a_same",N111U32{},"and",N111Local{"p198a_same"},N111Local{"p198a_eq"}}},rest}})
    case _ _: []

@unsafe
def x198o_progress_get(+name: String, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match env:
    case Nil{}: X198OProgress{X198NUnknown{},"",""}
    case Con{X198OProgressBinding{key,+value},rest}: nt_choose(X198OProgress,agy_str_eq(name,key),u => value,u => x198o_progress_get(name,rest))

@unsafe
def x198o_progress_initial(params: List<&2,NC_Binding>, +fuel: String) -> List<&2,X198OProgressBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      +isFuel = agy_str_eq(name,fuel)
      Con{X198OProgressBinding{name,X198OProgress{
        nt_choose(X198NFact,isFuel,u => X198NUnknown{},u => X198NAlias{name,True{}}),
        "",
        nt_choose(String,isFuel,u => "",u => name)}},x198o_progress_initial(rest,fuel)}

@unsafe
def x198o_progress_alias(value: X198NFact) -> String:
  match value:
    case X198NAlias{+name,narrow}: nt_choose(String,narrow,u => name,u => "")
    case _: ""

@unsafe
def w4_progress_parity(+op: String, +left: X198NFact, +right: X198NFact, +lsp: String, +rsp: String) -> String:
  nt_choose(String,agy_str_eq(op,"mul") && w4_const_odd(right) && Bool.not(String.is_empty(lsp)),u => lsp,u =>
  nt_choose(String,agy_str_eq(op,"mul") && w4_const_odd(left) && Bool.not(String.is_empty(rsp)),v => rsp,v =>
  nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_even(right) && Bool.not(String.is_empty(lsp)),w => lsp,w =>
  nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_even(left) && Bool.not(String.is_empty(rsp)),z => rsp,z => ""))))

@unsafe
def agy_la_finish_arg4(args: List<&2,N111Arg>, +bname: String) -> Bool:
  match args:
    case Con{_,Con{_,Con{_,Con{N111Arg{_,val},Nil{}}}}}: agy_la_is_local(val,bname)
    case _: False{}

@unsafe
def agy_la_ext_arg3(args: List<&2,N111Arg>, +con_name: String) -> Bool:
  match args:
    case Con{_,Con{_,Con{N111Arg{_,cv},Con{_,Con{N111Arg{_,N111Const{1,0}},Nil{}}}}}}:
      agy_str_eq(agy_la_extract_ctor(cv),con_name)
    case _: False{}

@unsafe
def agy_la_find_tag_cmp(stmts: List<&2,P113DStmt>, +cond: String) -> String:
  match stmts:
    case Nil{}: ""
    case Con{P113DScalar{N111Bin{dst,_,op,l,r}},rest}:
      nt_choose(String,agy_str_eq(dst,cond) && agy_str_eq(op,"eq"),u =>
        nt_choose(String,Bool.not(String.is_empty(agy_la_extract_ctor(r))),
          v => agy_la_extract_ctor(r),v => agy_la_extract_ctor(l)),
        u => agy_la_find_tag_cmp(rest,cond))
    case Con{_,rest}: agy_la_find_tag_cmp(rest,cond)

@unsafe
def x202k_digit_name(name: String) -> Bool:
  match name:
    case SCon{a,SCon{b,+suffix}}: Char.is_eq(a,'v') && Char.is_eq(b,'_') && Bool.not(String.is_empty(suffix)) && x202k_digits(suffix)
    case _: False{}

def x192h_stack(symbol: String, destination: String, count: U32) -> P113DStmt:
  P113DScalar{N111Call{destination,N111U64{},symbol,[p111_state(),p111_u32(count)]}}

@unsafe
def x192h_values(names: List<&2,String>) -> List<&2,N111Value>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{x192h_v(name),x192h_values(rest)}

def x192h_increment() -> P113DStmt:
  P113DScalar{N111Bin{"p114r_depth",N111U64{},"add",x192h_v("p114r_depth"),x192h_c(1)}}

@unsafe
def x192h_snapshots(+count: U32, +index: U32, +buffer: String) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,count),u => [],u =>
    Con{P113DScalar{N111Load{x192h_edge_name(index),N111U64{},x192h_v(buffer),U32.mul(index,8)}},
      x192h_snapshots(count,U32.inc(index),buffer)})

@unsafe
def x192h_edges(+count: U32, +index: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(index,count),u => [],u =>
    Con{x192h_v(x192h_edge_name(index)),x192h_edges(count,U32.inc(index))})

@unsafe
def x192h_public_args(params: List<&2,String>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: [N111Arg{N111U64{},x192h_c(0)},N111Arg{N111U64{},x192h_c(0)},N111Arg{N111U64{},x192h_c(0)}]
    case Con{name,rest}: Con{N111Arg{N111U64{},x192h_v(name)},x192h_public_args(rest)}

@unsafe
def x198pw_arm(+t: KTerm,+name: String,+left: U32) -> KTerm:
  +u = nc_unann(t)
  nt_choose(KTerm,U32.is_gt(left,0) && agy_str_eq(tg(u),"Mat") && U32.is_eq(terms_len(ks(u)),2),
    x => nt_choose(KTerm,agy_str_eq(nm(u),name),y => kid(u,0),y => x198pw_arm(kid(u,1),name,U32.sub(left,1))),
    x => atom("Absent"))

@unsafe
def x198pw_spine(+t: KTerm,+acc: List<&2,KTerm>,+left: U32) -> KPChain:
  +u = nc_unann(t)
  nt_choose(KPChain,agy_str_eq(tg(u),"App") && U32.is_gt(left,0) && U32.is_eq(terms_len(ks(u)),2),
    v => x198pw_spine(kid(u,0),Con{kid(u,1),acc},U32.sub(left,1)),v => KPChain{acc,u})

def x198pw_leaf(v: String) -> X198PWPattern: X198PWCtr{"leaf",[x198pw_v(v)]}

def x198pw_recur(x: String,y: String) -> X198PWPattern:
  X198PWCall{"self",[x198pw_v(x),x198pw_v(y),x198pw_v("d")]}

def x198pw_root_leaf() -> X198PWPattern:
  X198PWCase{"leaf",X198PWLam{"a",X198PWCase{"leaf",X198PWLam{"b",X198PWLam{"d",
    X198PWCall{"leafFunction",[x198pw_v("a"),x198pw_v("b"),x198pw_v("d")]}}}}}}

def x198pw_join() -> X198PWPattern:
  x198pw_two("node","a","b",x198pw_two("node","c","d",x198pw_node(
    x198pw_node(x198pw_v("a"),x198pw_v("c")),x198pw_node(x198pw_v("b"),x198pw_v("d")))))

def x198pw_leaf_function() -> X198PWPattern:
  x198pw_three("a","b","d",X198PWCall{"order",[x198pw_v("a"),x198pw_v("b"),
    X198PWCall{"xor",[x198pw_v("d"),X198PWCall{"gt",[x198pw_v("a"),x198pw_v("b")]}]}]})

@unsafe
def x198pw_tel(+t: KTerm,names: List<&2,String>,+result: String) -> Bool:
  match names:
    case Nil{}: x198pw_ty(t,result)
    case Con{name,rest}: agy_str_eq(tg(t),"All") && U32.is_gt(qt(t),0) && U32.is_eq(terms_len(ks(t)),2) &&
      x198pw_ty(kid(t,0),name) && x198pw_tel(kid(t,1),rest,result)

def agy_zip_pat_insert() -> AgyZipPat:
  AgyZLam{"fuel",AgyZLam{"x",AgyZLam{"t",
    AgyZCall{"fin",[agy_z_v("x"),
      AgyZCall{"down",[agy_z_v("fuel"),agy_z_v("x"),
        AgyZCtr{"pair",[agy_z_v("t"),AgyZCtr{"nil",[]}]}]}]} }}}

def agy_zip_pat_fin_leaf() -> AgyZipPat:
  AgyZLam{"x",AgyZCase{"pair",AgyZCase{"leaf",AgyZLam{"path",
    AgyZCall{"up",[agy_z_v("path"),AgyZCtr{"node",[AgyZCtr{"leaf",[]},agy_z_v("x"),AgyZCtr{"leaf",[]}]}]}}}}}

def agy_zip_pat_fin_node() -> AgyZipPat:
  AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",
    AgyZCall{"up",[agy_z_v("path"),AgyZCtr{"node",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r")]}]}}}}}}}}

def agy_zip_pat_up_nil() -> AgyZipPat:
  AgyZCase{"nil",AgyZLam{"acc",agy_z_v("acc")}}

def agy_zip_pat_up_con(dir: String, a: String, b: String) -> AgyZipPat:
  AgyZCase{"con",AgyZCase{"frame",AgyZLam{"v",AgyZLam{"other",AgyZCase{dir,AgyZLam{"rest",AgyZLam{"acc",
    AgyZCall{"up",[agy_z_v("rest"),AgyZCtr{"node",[agy_z_v(a),agy_z_v("v"),agy_z_v(b)]}]}}}}}}}}

def agy_zip_pat_down_zero() -> AgyZipPat:
  AgyZCase{"zero",AgyZLam{"x",AgyZLam{"st",agy_z_v("st")}}}

# Post-AGY-005b down: Succ arm directly matches st = (Leaf, path) -> (Leaf, path) and (Node, path) -> down(f, x, pick(...))
def agy_zip_pat_down_succ_leaf() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"leaf",AgyZLam{"path",
    AgyZCtr{"pair",[AgyZCtr{"leaf",[]},agy_z_v("path")]}}}}}}}

def agy_zip_pat_down_succ_node_let() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v0",AgyZLam{"r",AgyZLam{"path",
    AgyZLet1{"v",agy_z_v("v0"),
      AgyZCall{"down",[agy_z_v("f"),agy_z_v("x"),
        AgyZCall{"pick",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r"),agy_z_v("path"),
          AgyZCall{"lt",[agy_z_v("x"),agy_z_v("v")]}]}]}}}}}}}}}}}

def agy_zip_pat_down_succ_node_dir() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",
    AgyZCall{"down",[agy_z_v("f"),agy_z_v("x"),
      AgyZCall{"pick",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r"),agy_z_v("path"),
        AgyZCall{"lt",[agy_z_v("x"),agy_z_v("v")]}]}]} }}}}}}}}}

def agy_zip_pat_pick(+dir: String, keep: String, save: String) -> AgyZipPat:
  AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",AgyZCase{dir,
    AgyZCtr{"pair",[agy_z_v(keep),AgyZCtr{"con",[AgyZCtr{"frame",[agy_z_v("v"),agy_z_v(save),AgyZCtr{dir,[]}]},agy_z_v("path")]}]}}}}}}

def agy_ro_ty(+t: KTerm, +name: String) -> Bool:
  +u = nc_unann(t)
  (p88_string_eq(tg(u),"Ref") || p88_string_eq(tg(u),"ADT")) && p88_string_eq(nm(u),name) && List.is_empty(&2,KTerm,ks(u))

def agy_ro_prim_op(+name: String) -> String:
  nt_choose(String,p88_string_eq(name,"u32_add"),u => "addl",u =>
    nt_choose(String,p88_string_eq(name,"u32_sub"),u => "subl",u =>
      nt_choose(String,p88_string_eq(name,"u32_mul"),u => "imull",u =>
        nt_choose(String,p88_string_eq(name,"u32_xor"),u => "xorl",u =>
          nt_choose(String,p88_string_eq(name,"u32_and"),u => "andl",u =>
            nt_choose(String,p88_string_eq(name,"u32_or"),u => "orl",u => ""))))))

@unsafe
def agy_ro_lookup_var(+vid: U32, +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  nt_choose(Maybe<&2,KTerm>,has_x && U32.is_eq(vid,x_id),
    u => Some{kt("RoParamX","",0,0,[])},u =>
    nt_choose(Maybe<&2,KTerm>,U32.is_eq(f0_k,1) && U32.is_eq(vid,f0_id),
      v => Some{kt("RoField","",0,0,[])},v =>
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(f1_k,1) && U32.is_eq(vid,f1_id),
        w => Some{kt("RoField","",1,0,[])},w => None{})))

@unsafe
def agy_ro_rec_field(+t: KTerm, +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32) -> U32:
  # Returns 1 for field 0, 2 for field 1, 0 for invalid
  +u = nc_unann(t)
  nt_choose(U32,agy_str_eq(tg(u),"Var"),
    v => nt_choose(U32,U32.is_eq(f0_k,2) && U32.is_eq(ix(u),f0_id),
      w => 1,
      w => nt_choose(U32,U32.is_eq(f1_k,2) && U32.is_eq(ix(u),f1_id),z => 2,z => 0)),
    v => 0)

@unsafe
def agy_ro_is_x(+t: KTerm, +x_id: U32, +has_x: Bool) -> Bool:
  +u = nc_unann(t)
  has_x && agy_str_eq(tg(u),"Var") && U32.is_eq(ix(u),x_id)

@unsafe
def agy_ro_expr_has_rec(+e: KTerm) -> Bool:
  nt_choose(Bool,agy_str_eq(tg(e),"RoRec"),u => True{},u =>
    nt_choose(Bool,agy_str_eq(tg(e),"RoBin") && U32.is_eq(terms_len(ks(e)),2),
      v => agy_ro_expr_has_rec(kid(e,0)) || agy_ro_expr_has_rec(kid(e,1)),
      v => False{}))

def agy_ro_is_inline_u32(fs: List<&2,U32>) -> U32:
  match fs:
    case Con{k0,Nil{}}: nt_choose(U32,U32.is_eq(k0,1),u => 1,u => 0)
    case _: 0

@unsafe
def agy_ro_check_finish(+owner: String, +arity: U32, res: Maybe<&2,List<&2,KTerm>>) -> Maybe<&2,KDef>:
  match res:
    case None{}: None{}
    case Some{cases}:
      +key = agy_ro_key("$direct." ++ owner)
      Some{KDef{key,"AgyRoRecCertified",arity,0,kt("RoCases","",0,0,cases),kt("None","",0,0,[]),[],False{},False{}}}

def agy_fl_pat_z_node() -> X198PWPattern:
  X198PWCase{"zero",X198PWLam{"s",x198pw_two("node","a","b",x198pw_node(x198pw_v("a"),x198pw_v("b")))}}

def agy_fl_pat_s_node() -> X198PWPattern:
  X198PWCase{"succ",X198PWLam{"p",X198PWLam{"s",x198pw_two("node","wa","wb",
    X198PWLet2{
      X198PWCall{"self",[x198pw_v("p"),x198pw_v("s"),X198PWCall{"wn",[x198pw_v("wa"),x198pw_v("s")]}]},
      X198PWCall{"self",[x198pw_v("p"),x198pw_v("s"),X198PWCall{"wn",[x198pw_v("wb"),x198pw_v("s")]}]},
      x198pw_node(x198pw_v("res0"),x198pw_v("res1"))})}}}

def agy_fl_pat_wn_node() -> X198PWPattern:
  x198pw_two("node","a","b",X198PWLam{"s",X198PWCall{"warp",[x198pw_v("a"),x198pw_v("b"),x198pw_v("s")]}})

@unsafe
def agy_fl_check_warp(+book: List<&2,KDef>, +owner: String, +wn: String, +leaf_id: String, +node_id: String,
    +warp_name: String, wp: X198PWPlan) -> AgyFlowPlan:
  match wp:
    case X198PWPlan{w_owner,w_leaf,w_node}:
      nt_choose(AgyFlowPlan,agy_str_eq(w_leaf,leaf_id) && agy_str_eq(w_node,node_id),
        u => AgyFlowPlan{owner,leaf_id,node_id,warp_name,wn},
        u => AgyFlowNone{})
    case _: AgyFlowNone{}

@unsafe
def x193f_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x193f_clean_name(name)
    case _: True{}

@unsafe
def x193f_loads(+count: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,index),u => [],u =>
    Con{N111Load{x193f_arg_name(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)},
      x193f_loads(count,U32.inc(index))})

@unsafe
def x193f_args(+count: U32, +index: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{p111_word(N111Local{x193f_arg_name(index)}),x193f_args(count,U32.inc(index))})

# This is p112w_call(...,public=True) in structured scalar IR. rt_return must
# remain: its pending caller continuation is outside the helper's native frame.
@unsafe
def x193fb_budget(+before: U32, after: U32) -> Bool:
  U32.is_le(before,2147483639) &&
    U32.is_le(after,U32.add(U32.mul(before,x193fb_ratio()),x193fb_slack()))

@unsafe
def x195t_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: x195t_name(name) && x195t_names(rest)

def x195t_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x195t_name(name)
    case _: True{}

def x199s_narrow(+token: U32) -> U32:
  nt_choose(U32,U32.is_eq(token,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(token,4),v => 17,v =>
      nt_choose(U32,U32.is_eq(token,7) || U32.is_eq(token,8) || U32.is_eq(token,9) ||
        U32.is_eq(token,11) || U32.is_eq(token,12) || U32.is_eq(token,13) ||
        U32.is_eq(token,16) || U32.is_eq(token,17) || U32.is_eq(token,18) || U32.is_eq(token,19),w => token,w => 0)))

@unsafe
def x199s_result(body: List<&2,P113DStmt>, array: String, carry: String) -> Bool:
  match body:
    case Con{P113DResult{Con{a,Con{c,Nil{}}}},Nil{}}: x185_sf_source(a,array) && x185_sf_source(c,carry)
    case _: False{}

def agy_dp_narrow(+t: U32) -> U32:
  nt_choose(U32,U32.is_eq(t,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(t,3),v => 12,v =>
      nt_choose(U32,U32.is_eq(t,11) || U32.is_eq(t,12) || U32.is_eq(t,13) ||
        U32.is_eq(t,17) || U32.is_eq(t,20) || U32.is_eq(t,24) || U32.is_eq(t,28) ||
        U32.is_eq(t,32) || U32.is_eq(t,33) || U32.is_eq(t,34) || U32.is_eq(t,36) ||
        U32.is_eq(t,37) || U32.is_eq(t,39) || U32.is_eq(t,50) || U32.is_eq(t,51),w => t,w => 0)))

@unsafe
def agy_dp_result(body: List<&2,P113DStmt>, a: String, b: String, p: String, c: String) -> Bool:
  match body:
    case Con{P113DResult{Con{r0,Con{r1,Con{r2,Con{r3,Nil{}}}}}},Nil{}}:
      x185_sf_source(r0,a) && x185_sf_source(r1,b) && x185_sf_source(r2,c) && x185_sf_source(r3,p)
    case _: False{}

@unsafe
def w5_lcu_vals_has(+name: String, vs: List<&2,N111Value>) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{h,rest}: w5_lcu_val_is(name,h) || w5_lcu_vals_has(name,rest)

@unsafe
def w5_lcu_args_has(+name: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: w5_lcu_val_is(name,v) || w5_lcu_args_has(name,rest)

@unsafe
def w5_lcu_nth_val(vs: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:
  match vs:
    case Nil{}: None{}
    case Con{h,rest}:
      nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{h},u => w5_lcu_nth_val(rest,U32.sub(idx,1)))

@unsafe
def w5_lcu_match_ctor_args(+aName: String, args: List<&2,N111Arg>) -> W5LcuCtor:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+st}},
         Con{N111Arg{N111U32{},N111CtorId{+c}},
         Con{N111Arg{N111Ptr{},N111Local{+buf}},
         Con{N111Arg{N111U32{},N111Const{+a,0}},Nil{}}}}}:
      nt_choose(W5LcuCtor,agy_str_eq(st,"state") && Bool.not(agy_str_eq(buf,"state")) && U32.is_ge(a,1) && U32.is_le(a,8),
        u => W5LcuYes{c,a,buf,[],aName},
        u => W5LcuNo{})
    case _: W5LcuNo{}

@unsafe
def w5_lcu_collect_stores(revPrefix: List<&2,P113DStmt>, +buf: String, +wantOff: U32, +acc: List<&2,N111Value>) -> Maybe<&2,List<&2,N111Value>>:
  match revPrefix:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b},+off,+v}},rest}:
      nt_choose(Maybe<&2,List<&2,N111Value>>,agy_str_eq(b,buf) && U32.is_eq(off,wantOff),
        u => nt_choose(Maybe<&2,List<&2,N111Value>>,U32.is_eq(wantOff,0),
          w => Some{Con{v,acc}},
          w => w5_lcu_collect_stores(rest,buf,U32.sub(wantOff,8),Con{v,acc})),
        u => None{})
    case _: None{}

@unsafe
def w5_lcu_drop_n(xs: List<&2,P113DStmt>, +n: U32) -> List<&2,P113DStmt>:
  match xs:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => Con{h,rest},u => w5_lcu_drop_n(rest,U32.sub(n,1)))

@unsafe
def w5_lcu_merge_scan_mc(+cur: W5LcuScan, +seen: Bool, +c0: String, +a0: U32, mc: W5LcuCtor) -> W5LcuScan:
  match mc:
    case W5LcuNo{}: W5LcuScan{False{},seen,c0,a0}
    case W5LcuYes{+c,+a,_,_,_}:
      nt_choose(W5LcuScan,Bool.not(seen),
        w => W5LcuScan{True{},True{},c,a},
        w => nt_choose(W5LcuScan,agy_str_eq(c0,c) && U32.is_eq(a0,a),
          z => cur,
          z => W5LcuScan{False{},True{},c0,a0}))

@unsafe
def w5_lcu_is_tag_call(+pName: String, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_tag") && w5_lcu_is_tag_args(pName,args)

@unsafe
def w5_lcu_is_take_call(+pName: String, +arity: U32, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_take") && w5_lcu_is_take_args(pName,arity,args)

@unsafe
def w5_lcu_is_sink_call(+pName: String, +sym: String, args: List<&2,N111Arg>) -> Bool:
  agy_str_eq(sym,"p111_rt_sink") && w5_lcu_is_tag_args(pName,args)

@unsafe
def w5_lcu_check_use_res(+idx: U32, +pName: String, +ctor: String, +arity: U32, ures: W5LcuUse) -> W5LcuCand:
  match ures:
    case W5LcuUse{uok,seenTake}:
      nt_choose(W5LcuCand,uok && seenTake,w => W5LcuCandYes{idx,pName,ctor,arity},w => W5LcuCandNo{})

@unsafe
def w5_lcu_field_bindings(+depth: U32, +i: U32, +arity: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,arity),u => [],
    u => Con{NC_Binding{0,w5_lcu_field_name(depth,i),N_W64{}},w5_lcu_field_bindings(depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_stores(+buf: String, +depth: U32, +i: U32, +arity: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(i,arity),u => [],
    u => Con{P113DScalar{N111Store{N111U64{},N111Local{buf},U32.mul(i,8),N111Local{w5_lcu_field_name(depth,i)}}},
             w5_lcu_field_stores(buf,depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_loads(+buf: String, +depth: U32, +i: U32, +arity: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(i,arity),u => [],
    u => Con{P113DScalar{N111Load{w5_lcu_field_name(depth,i),N111U64{},N111Local{buf},U32.mul(i,8)}},
             w5_lcu_field_loads(buf,depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_field_args(+depth: U32, +i: U32, +arity: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(i,arity),u => [],
    u => Con{N111Arg{N111U64{},N111Local{w5_lcu_field_name(depth,i)}},w5_lcu_field_args(depth,U32.inc(i),arity)})

@unsafe
def w5_lcu_count_loads(rest: List<&2,P113DStmt>, +tbuf: String, +arity: U32, +acc: U32) -> U32:
  match rest:
    case Con{P113DScalar{N111Load{_,N111U64{},N111Local{+b},+off}},more}:
      +fidx = U32.div(off,8)
      nt_choose(U32,agy_str_eq(b,tbuf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(fidx,arity),
        u => w5_lcu_count_loads(more,tbuf,arity,U32.inc(acc)),
        u => acc)
    case _: acc

def agy_f32_sse_op(+op_id: U32) -> String:
  nt_choose(String,U32.is_eq(op_id,26),u => "addss",u =>
    nt_choose(String,U32.is_eq(op_id,27),v => "subss",v =>
      nt_choose(String,U32.is_eq(op_id,28),w => "mulss",w =>
        nt_choose(String,U32.is_eq(op_id,29),z => "divss",z => ""))))

def agy_f32_u32_op(+op: String) -> String:
  nt_choose(String,p88_string_eq(op,"add"),u => "addl",u =>
    nt_choose(String,p88_string_eq(op,"sub"),v => "subl",v =>
      nt_choose(String,p88_string_eq(op,"mul"),w => "imull",w =>
        nt_choose(String,p88_string_eq(op,"xor"),z => "xorl",z =>
          nt_choose(String,p88_string_eq(op,"and"),q => "andl",q =>
            nt_choose(String,p88_string_eq(op,"or"),r => "orl",r => ""))))))

@unsafe
def agy_f32_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name))

@unsafe
def agy_f32_result(body: List<&2,P113DStmt>, h: String) -> Bool:
  match body:
    case Con{P113DResult{Con{r0,Nil{}}},Nil{}}: x185_sf_source(r0,h)
    case _: False{}

def agy_f32_max(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_gt(a,b),u => a,u => b)

def agy_f32_u_reg(+idx: U32) -> U32:
  nt_choose(U32,U32.is_eq(idx,0),u => 0,u =>
    nt_choose(U32,U32.is_eq(idx,1),v => 8,v =>
      nt_choose(U32,U32.is_eq(idx,2),w => 9,w => 10)))

@unsafe
def agy_f32_same(+a: KTerm, +b: KTerm) -> Bool:
  agy_str_eq(tg(a),tg(b)) && agy_str_eq(nm(a),nm(b)) && U32.is_eq(ix(a),ix(b)) &&
  nt_choose(Bool,agy_str_eq(tg(a),"FBin") && U32.is_eq(terms_len(ks(a)),2) && U32.is_eq(terms_len(ks(b)),2),
    u => agy_f32_same(kid(a,0),kid(b,0)) && agy_f32_same(kid(a,1),kid(b,1)),
    u => True{})

@unsafe
def agy_map_args_has_ctor(args: List<&2,N111Arg>, +cname: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_map_val_is_ctor(v,cname) || agy_map_args_has_ctor(rest,cname)

@unsafe
def agy_map_args_has_func(args: List<&2,N111Arg>, +fname: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_map_val_has_func(v,fname) || agy_map_args_has_func(rest,fname)

@unsafe
def agy_bp_str(s: String, +h: U32) -> U32:
  match s:
    case SNil{}: agy_bp_mix(h,255)
    case SCon{c,rest}: agy_bp_str(rest,agy_bp_mix(h,Char.to_u32(c)))

@unsafe
def x187_e_le(+word: U32, +count: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(count,0),u => [],
    u => Con{U32.mod(word,256),x187_e_le(U32.div(word,256),U32.sub(count,1))})

@unsafe
def x187_e_rm(value: X187Operand, width: U32, vector: Bool) -> Bool:
  match value:
    case X187Mem{base,disp}: U32.is_lt(base,16)
    case X187Indexed{base,index,scale,disp}: x191_e_indexed_valid(base,index,scale)
    case X187Rip{symbol,lo,hi}: Bool.not(String.is_empty(symbol))
    case _: x187_e_reg(value,width,vector)

def x191_e_rex_x(value: X187Operand) -> U32:
  match value:
    case X187Indexed{base,index,scale,disp}: nt_choose(U32,U32.is_ge(index,8),u => 2,u => 0)
    case _: 0

@unsafe
def x187_e_fits(+lo: U32, +hi: U32, +width: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(width,64),u => x187_e_signed32(lo,hi),u =>
    U32.is_eq(hi,0) && nt_choose(Bool,U32.is_eq(width,8),v => U32.is_le(lo,255),v => True{}))

@unsafe
def w5b_e_prefix_rex(emitRex: Bool, +legacy: U32, +rex: U32) -> List<&2,U32>:
  match emitRex:
    case True{}: w5b_e_prefix_tail(legacy,[rex])
    case False{}: w5b_e_prefix_tail(legacy,[])

@unsafe
def w5b_e_mem_mode(zero: Bool, +disp: U32) -> U32:
  match zero:
    case True{}: 0
    case False{}: w5b_e_mem_mode2(U32.is_le(disp,127) || U32.is_ge(disp,4294967168))

@unsafe
def x202o_dispatch(initial: U32, +tail: String) -> X187Op:
  match initial:
    case 109:
      nt_choose(X187Op,agy_str_eq(tail,"ovq"),u => X187Op{2,64,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovl"),u => X187Op{2,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovd"),u => X187Op{10,0,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovabsq"),u => X187Op{15,64,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovzbl"),u => X187Op{6,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovzwl"),u => X187Op{18,32,183,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovaps"),u => X187Op{7,128,40,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovb"),u => X187Op{2,8,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      X187OpNone{})))))))))
    case 106:
      nt_choose(X187Op,agy_str_eq(tail,"ne"),u => X187Op{9,0,15,133,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"mp"),u => X187Op{9,0,233,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"e"),u => X187Op{9,0,15,132,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"z"),u => X187Op{9,0,15,132,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"a"),u => X187Op{9,0,15,135,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"b"),u => X187Op{9,0,15,130,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ae"),u => X187Op{9,0,15,131,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"be"),u => X187Op{9,0,15,134,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"g"),u => X187Op{9,0,15,143,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ge"),u => X187Op{9,0,15,141,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"l"),u => X187Op{9,0,15,140,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"le"),u => X187Op{9,0,15,142,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"np"),u => X187Op{9,0,15,139,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"nz"),u => X187Op{9,0,15,133,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"p"),u => X187Op{9,0,15,138,0},u =>
      X187OpNone{})))))))))))))))
    case 99:
      nt_choose(X187Op,agy_str_eq(tail,"mpq"),u => X187Op{1,64,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"mpl"),u => X187Op{1,32,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"all"),u => X187Op{9,0,232,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"vtsi2ssq"),u => X187Op{11,64,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movael"),u => X187Op{16,32,67,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"omiss"),u => X187Op{7,128,47,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movaeq"),u => X187Op{16,64,67,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"moval"),u => X187Op{16,32,71,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movaq"),u => X187Op{16,64,71,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movbel"),u => X187Op{16,32,70,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movbeq"),u => X187Op{16,64,70,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movbl"),u => X187Op{16,32,66,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movbq"),u => X187Op{16,64,66,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movel"),u => X187Op{16,32,68,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"moveq"),u => X187Op{16,64,68,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movgel"),u => X187Op{16,32,77,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movgeq"),u => X187Op{16,64,77,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movgl"),u => X187Op{16,32,79,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movgq"),u => X187Op{16,64,79,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movlel"),u => X187Op{16,32,78,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movleq"),u => X187Op{16,64,78,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movll"),u => X187Op{16,32,76,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movlq"),u => X187Op{16,64,76,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movnel"),u => X187Op{16,32,69,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"movneq"),u => X187Op{16,64,69,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"mpb"),u => X187Op{1,8,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"vttss2siq"),u => X187Op{17,64,0,0,0},u =>
      X187OpNone{})))))))))))))))))))))))))))
    case 112:
      nt_choose(X187Op,agy_str_eq(tail,"opq"),u => X187Op{8,64,88,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ushq"),u => X187Op{8,64,80,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"xor"),u => X187Op{7,128,239,0,102},u =>
      X187OpNone{})))
    case 97:
      nt_choose(X187Op,agy_str_eq(tail,"ddq"),u => X187Op{1,64,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ndq"),u => X187Op{1,64,0,4,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ndb"),u => X187Op{1,8,0,4,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ddl"),u => X187Op{1,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ddb"),u => X187Op{1,8,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ddss"),u => X187Op{7,128,88,0,243},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ndl"),u => X187Op{1,32,0,4,0},u =>
      X187OpNone{})))))))
    case 115:
      nt_choose(X187Op,agy_str_eq(tail,"hrq"),u => X187Op{3,64,0,5,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ubq"),u => X187Op{1,64,0,5,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etnp"),u => X187Op{5,8,155,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"eta"),u => X187Op{5,8,151,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etae"),u => X187Op{5,8,147,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etb"),u => X187Op{5,8,146,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etbe"),u => X187Op{5,8,150,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ete"),u => X187Op{5,8,148,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etne"),u => X187Op{5,8,149,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etp"),u => X187Op{5,8,154,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"arl"),u => X187Op{3,32,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"arq"),u => X187Op{3,64,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etg"),u => X187Op{5,8,159,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etge"),u => X187Op{5,8,157,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etl"),u => X187Op{5,8,156,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etle"),u => X187Op{5,8,158,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etnz"),u => X187Op{5,8,149,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"etz"),u => X187Op{5,8,148,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"hll"),u => X187Op{3,32,0,4,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"hlq"),u => X187Op{3,64,0,4,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"hrl"),u => X187Op{3,32,0,5,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ubb"),u => X187Op{1,8,0,5,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ubl"),u => X187Op{1,32,0,5,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ubss"),u => X187Op{7,128,92,0,243},u =>
      nt_choose(X187Op,agy_str_eq(tail,"qrtss"),u => X187Op{7,128,81,0,243},u =>
      X187OpNone{})))))))))))))))))))))))))
    case 108:
      nt_choose(X187Op,agy_str_eq(tail,"eaq"),u => X187Op{12,64,0,0,0},u =>
      X187OpNone{})
    case 120:
      nt_choose(X187Op,agy_str_eq(tail,"orl"),u => X187Op{1,32,0,6,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orb"),u => X187Op{1,8,0,6,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orq"),u => X187Op{1,64,0,6,0},u =>
      X187OpNone{})))
    case 116:
      nt_choose(X187Op,agy_str_eq(tail,"estl"),u => X187Op{13,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"estb"),u => X187Op{13,8,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"estq"),u => X187Op{13,64,0,0,0},u =>
      X187OpNone{})))
    case 114:
      nt_choose(X187Op,agy_str_eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"olw"),u => X187Op{3,32,0,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orw"),u => X187Op{3,32,0,1,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"oll"),u => X187Op{3,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orl"),u => X187Op{3,32,0,1,0},u =>
      X187OpNone{})))))
    case 117:
      nt_choose(X187Op,agy_str_eq(tail,"comiss"),u => X187Op{7,128,46,0,0},u =>
      X187OpNone{})
    case 111:
      nt_choose(X187Op,agy_str_eq(tail,"rb"),u => X187Op{1,8,0,1,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"rl"),u => X187Op{1,32,0,1,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"rq"),u => X187Op{1,64,0,1,0},u =>
      X187OpNone{})))
    case 100:
      nt_choose(X187Op,agy_str_eq(tail,"ivss"),u => X187Op{7,128,94,0,243},u =>
      X187OpNone{})
    case 105:
      nt_choose(X187Op,agy_str_eq(tail,"mull"),u => X187Op{4,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"mulq"),u => X187Op{4,64,0,0,0},u =>
      X187OpNone{}))
    case _: X187OpNone{}

@unsafe
def x191cm_spec(+op: String) -> X187Op:
  nt_choose(X187Op,agy_str_eq(op,"cmovel"),u => X187Op{16,32,68,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovnel"),u => X187Op{16,32,69,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovbl"),u => X187Op{16,32,66,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovbel"),u => X187Op{16,32,70,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmoval"),u => X187Op{16,32,71,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovael"),u => X187Op{16,32,67,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovll"),u => X187Op{16,32,76,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovlel"),u => X187Op{16,32,78,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovgl"),u => X187Op{16,32,79,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovgel"),u => X187Op{16,32,77,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmoveq"),u => X187Op{16,64,68,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovneq"),u => X187Op{16,64,69,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovbq"),u => X187Op{16,64,66,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovbeq"),u => X187Op{16,64,70,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovaq"),u => X187Op{16,64,71,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovaeq"),u => X187Op{16,64,67,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovlq"),u => X187Op{16,64,76,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovleq"),u => X187Op{16,64,78,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovgq"),u => X187Op{16,64,79,0,0},u =>
  nt_choose(X187Op,agy_str_eq(op,"cmovgeq"),u => X187Op{16,64,77,0,0},u =>
  X187OpNone{}))))))))))))))))))))
# ELF64 little-endian ET_REL for AMD64. The encoder supplies actual bytes and
# named RELA records; this module neither parses assembly nor selects opcodes.
# Section identities are fixed: 1=text, 2=rodata, 3=data. Symbol values and
# relocation offsets are section-relative. Addends retain all 64 raw bits.
# Section base alignments are fixed at 16/8/8. The builder must refuse input
# requesting stronger alignment; byte padding alone cannot promise that ABI.
# Limits keep every file offset below U32 overflow; ELF fields remain 64-bit.
@unsafe
def x187_elf_zero(+count: U32, +tail: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(count,0),u => tail,
    u => x187_elf_zero(U32.sub(count,1),Con{0,tail}))

@unsafe
def x187_elf_bytes(bytes: List<&2,U32>, +count: U32) -> Bool:
  match bytes:
    case Nil{}: True{}
    case Con{head,rest}:
      nt_choose(Bool,U32.is_le(head,255) && U32.is_lt(count,67108864),
        u => x187_elf_bytes(rest,U32.inc(count)),u => False{})

@unsafe
def x187_elf_name(name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{+head,rest}:
      nt_choose(Bool,U32.is_lt(count,4096) && U32.is_gt(Char.to_u32(head),0) &&
        U32.is_lt(Char.to_u32(head),128),u => x187_elf_name(rest,U32.inc(count)),u => False{})

@unsafe
def x187_elf_section_size(+section: U32, sizes: X187ElfSizes) -> U32:
  match sizes:
    case X187ElfSizes{text,rodata,data}:
      nt_choose(U32,U32.is_eq(section,1),u => text,
        u => nt_choose(U32,U32.is_eq(section,2),v => rodata,
          v => nt_choose(U32,U32.is_eq(section,3),w => data,w => 0)))

@unsafe
def w7_reloc_enc(+offset: U32, +kind: U32, +symIdx: U32, +lo: U32, +hi: U32, acc: List<&2,U32>) -> List<&2,U32>:
  x201e_u32_reverse(hi,x201e_u32_reverse(lo,x201e_u32_reverse(symIdx,
    x201e_u32_reverse(kind,Con{0,Con{0,Con{0,Con{0,x201e_u32_reverse(offset,acc)}}}}))))

@unsafe
def x201e_checked_size(bytes: List<&2,U32>, +count: U32) -> U32:
  match bytes:
    case Nil{}: count
    case Con{a,Con{b,Con{c,Con{d,rest}}}}:
      nt_choose(U32,U32.is_le(count,67108860) && U32.is_le(U32.or(U32.or(a,b),U32.or(c,d)),255),
        u => x201e_checked_size(rest,U32.add(count,4)),u => 4294967295)
    case Con{a,rest}:
      nt_choose(U32,U32.is_lt(count,67108864) && U32.is_le(a,255),
        u => x201e_checked_size(rest,U32.inc(count)),u => 4294967295)

@unsafe
def x188_branch_encoded(inst: X187Instruction, +encoded: X187Encoded) -> X187Encoded:
  match inst encoded:
    case X187Instruction{op,Con{X187Target{+name},Nil{}}}
      X187Encoded{bytes,Con{X187Relocation{s,o,2,symbol,4294967292,4294967295},Nil{}},error}:
      nt_choose(X187Encoded,String.starts_with(op,"j") && String.starts_with(name,".L"),
        u => X187Encoded{bytes,[X187Relocation{s,o,130,symbol,4294967292,4294967295}],error},
        u => encoded)
    case _ _: encoded

@unsafe
def x188_fixup_word(bytes: List<&2,U32>, patches: List<&2,X187Relocation>, position: U32,
    word: U32, acc: List<&2,U32>) -> X187Encoded:
  match bytes:
    case Con{0,Con{0,Con{0,Con{0,rest}}}}:
      x188_fixup_bytes(rest,patches,U32.add(position,4),nt_reverse(U32,x187_elf_u32(word),acc))
    case _: X187Encoded{[],[],"invalid local branch placeholder"}

@unsafe
def x188_fixup_advance(bytes: List<&2,U32>, patches: List<&2,X187Relocation>, position: U32,
    acc: List<&2,U32>) -> X187Encoded:
  match bytes:
    case Nil{}: X187Encoded{[],[],"local branch fixup outside text"}
    case Con{head,rest}: x188_fixup_bytes(rest,patches,U32.inc(position),Con{head,acc})

@unsafe
def x188_fixup_at(+bytes: List<&2,U32>, +patches: List<&2,X187Relocation>, +position: U32,
    +acc: List<&2,U32>, patch: X187Relocation, rest: List<&2,X187Relocation>) -> X187Encoded:
  match patch:
    case X187Relocation{section,+offset,kind,name,word,hi}:
      nt_choose(X187Encoded,U32.is_lt(offset,position),
        u => X187Encoded{[],[],"overlapping or unordered local branch fixup"},u =>
        nt_choose(X187Encoded,U32.is_eq(offset,position),
          v => x188_fixup_word(bytes,rest,position,word,acc),
          v => x188_fixup_advance(bytes,patches,position,acc)))

@unsafe
def x188_fixup_bytes(bytes: List<&2,U32>, +patches: List<&2,X187Relocation>, position: U32,
    acc: List<&2,U32>) -> X187Encoded:
  match patches:
    case Nil{}: X187Encoded{nt_reverse(U32,acc,bytes),[],""}
    case Con{head,rest}: x188_fixup_at(bytes,patches,position,acc,head,rest)

@unsafe
def x188_symbol_count(names: List<&2,String>, +count: U32, +bytes: U32) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}:
      nt_choose(Bool,U32.is_lt(count,1048575),
        u => x188_symbol_name(head,rest,count,bytes,0),u => False{})

@unsafe
def x188_symbol_name(name: String, rest: List<&2,String>, count: U32, +bytes: U32, +length: U32) -> Bool:
  match name:
    case SNil{}:
      nt_choose(Bool,U32.is_gt(length,0) && U32.is_le(U32.inc(length),U32.sub(67108864,bytes)),
        u => x188_symbol_count(rest,U32.inc(count),U32.add(bytes,U32.inc(length))),u => False{})
    case SCon{+head,tail}:
      nt_choose(Bool,U32.is_lt(length,4096) && U32.is_gt(Char.to_u32(head),0) && U32.is_lt(Char.to_u32(head),128),
        u => x188_symbol_name(tail,rest,count,bytes,U32.inc(length)),u => False{})

@unsafe
def x201f_plan(patches: List<&2,X187Relocation>, +size: U32, end: U32,
    +acc: List<&2,X187Relocation>) -> List<&2,X187Relocation>:
  match patches:
    case Nil{}: acc
    case Con{+patch,rest}:
      match patch:
        case X187Relocation{s,+offset,k,n,lo,hi}:
          nt_choose(List<&2,X187Relocation>,U32.is_le(end,offset) && U32.is_le(offset,size) && U32.is_le(4,U32.sub(size,offset)),
            u => x201f_plan(rest,size,U32.add(offset,4),Con{patch,acc}),u => [])

@unsafe
def x187_print_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  do IO<U32>:
    Unit <- File.close(file)
    x187_print_status(result)

@unsafe
def x202e_open(parts: List<&2,List<&2,U32>>) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","w"))
    x202e_write(parts,file)

def agy_parcg_next_rem(+rem: U32, +shards: U32) -> U32:
  +nxt = U32.inc(rem)
  nt_choose(U32,U32.is_eq(nxt,shards),u => 0,u => nxt)

law agy_lpt_p113_list:
  for +stmts: List<&2,P113DStmt>
  for +acc: U32
  U32

@unsafe
def agy_lpt_p113_stmt(+stmt: P113DStmt, +acc: U32) -> U32:
  match stmt:
    case P113DScalar{s}: agy_lpt_n111_stmt(s,acc)
    case P113DIf{c,yes,no}: agy_lpt_p113_list(no,agy_lpt_p113_list(yes,U32.add(acc,2)))
    case _: U32.add(acc,1)

@unsafe
def agy_lpt_p113_list(stmts, acc):
  match stmts:
    case Nil{}: acc
    case Con{head,rest}: agy_lpt_p113_list(rest,agy_lpt_p113_stmt(head,acc))

@unsafe
def agy_lpt_pub_weight(+seg: N111Segment) -> U32:
  match seg:
    case N111Segment{n,a,r,inc,fl,body}: U32.add(1,agy_lpt_n111_list(body,0))

@unsafe
def agy_lpt_zero_loads(+n: U32, +acc: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => acc,u => agy_lpt_zero_loads(U32.sub(n,1),Con{0,acc}))

@unsafe
def agy_lpt_min_idx_go(+loads: List<&2,U32>, +idx: U32, +best_idx: U32, +best_val: U32) -> U32:
  match loads:
    case Nil{}: best_idx
    case Con{+v,rest}:
      nt_choose(U32,U32.is_lt(v,best_val),
        u => agy_lpt_min_idx_go(rest,U32.add(idx,1),idx,v),
        u => agy_lpt_min_idx_go(rest,U32.add(idx,1),best_idx,best_val))

@unsafe
def agy_lpt_add_load(+loads: List<&2,U32>, +target: U32, +delta: U32) -> List<&2,U32>:
  match loads:
    case Nil{}: []
    case Con{+v,rest}:
      nt_choose(List<&2,U32>,U32.is_eq(target,0),
        u => Con{U32.add(v,delta),rest},
        u => Con{v,agy_lpt_add_load(rest,U32.sub(target,1),delta)})

@unsafe
def agy_lpt_priv_merge(+a: List<&2,AgyLptPriv>, +b: List<&2,AgyLptPriv>) -> List<&2,AgyLptPriv>:
  match a b:
    case Nil{} _: b
    case _ Nil{}: a
    case Con{AgyLptPriv{+wa,+ia},ra} Con{AgyLptPriv{+wb,+ib},rb}:
      nt_choose(List<&2,AgyLptPriv>,U32.is_ge(wa,wb),
        u => Con{AgyLptPriv{wa,ia},agy_lpt_priv_merge(ra,Con{AgyLptPriv{wb,ib},rb})},
        u => Con{AgyLptPriv{wb,ib},agy_lpt_priv_merge(Con{AgyLptPriv{wa,ia},ra},rb)})

@unsafe
def agy_lpt_pub_merge(+a: List<&2,AgyLptPub>, +b: List<&2,AgyLptPub>) -> List<&2,AgyLptPub>:
  match a b:
    case Nil{} _: b
    case _ Nil{}: a
    case Con{AgyLptPub{+wa,+ia},ra} Con{AgyLptPub{+wb,+ib},rb}:
      nt_choose(List<&2,AgyLptPub>,U32.is_ge(wa,wb),
        u => Con{AgyLptPub{wa,ia},agy_lpt_pub_merge(ra,Con{AgyLptPub{wb,ib},rb})},
        u => Con{AgyLptPub{wb,ib},agy_lpt_pub_merge(Con{AgyLptPub{wa,ia},ra},rb)})

@unsafe
def w8_patch_prog_item(+item: P111QDatum, +idx: U32, +fid_base: U32, +mod_name: String) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}:
      nt_choose(P111QDatum,U32.is_eq(idx,4),
        u => P111QLong{U32.add(lo,fid_base),hi},
        u => P111QLong{lo,hi})
    case P111QReloc{+sym,off}:
      nt_choose(P111QDatum,agy_str_eq(sym,"p111_segments") || agy_str_eq(sym,"p111_fid_arity") ||
          agy_str_eq(sym,"p111_fid_flags") || agy_str_eq(sym,"p111_fid_results"),
        u => P111QReloc{"p111_mod_" ++ mod_name ++ "_" ++ sym,off},
        u => P111QReloc{sym,off})
    case other: other


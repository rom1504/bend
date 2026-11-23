# Module m04 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=577 laws=71 sccs=374 deps=[m00,m01,m02,m03] cross_imports=614 fid_base=20480..25599

law subst_terms:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/core/term.bend:347
law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

# Module: src/core/index.bend:308
law norm_let:
  for +ts: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:294
law norm_let_tail:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:312
law norm_cmp_quick:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:492
law g_let_sub:
  for +t: KTerm
  for +bindings: List<&2, KTerm>
  KTerm

# Module: src/core/reach.bend:7
law descend_step:
  for +ord: U32
  for +qs: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +cols: List<&2, KTerm>
  Bool

# Module: src/check/kernel.bend:10
law let_cells:
  for +body: KTerm
  for +bs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:202
law signature_fill_mode:
  for +d: KDef
  for +fill: KDef
  KDef

# Module: src/check/kernel.bend:318
law env_tele_safe_terms:
  for +ts: List<&2,KTerm>
  Bool

# Module: src/check/env-telescope.bend:43
law ff_local:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:16
law ff_match:
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  for +next: U32
  for +origin: KTerm
  FFlatten

# Module: src/front/flatten.bend:36
law ff_column:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  for +next: U32
  for +origin: KTerm
  FFlatten

# Module: src/front/flatten.bend:45
law ff_split:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +next: U32
  for +origin: KTerm
  FFlatten

# Module: src/front/flatten.bend:61
law ff_fields_done:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +r: FFields
  for +origin: KTerm
  FFlatten

# Module: src/front/flatten.bend:83
law ff_hit_done:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +r: FFlatten
  for +origin: KTerm
  FFlatten

# Module: src/front/flatten.bend:94
law f_hit_rows:
  for +rows: List<&2, KTerm>
  for +c: KTerm
  for +fields: List<&2, KTerm>
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:39
law f_validate_result:
  for +r: FResult
  FResult

# Module: src/front/sugar.bend:254
law ffd_walk:
  for +book: List<&2,KDef>
  for +next: U32
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/fresh_work.bend:147
law ffd_type:
  for +definition: KDef
  for +pending: List<&2,KDef>
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  for +result: FFresh
  FFreshDefs

# Module: src/front/fresh_work.bend:154
law ffd_value:
  for +definition: KDef
  for +pending: List<&2,KDef>
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  for +typ: KTerm
  for +result: FFresh
  FFreshDefs

# Module: src/front/fresh_work.bend:162
law ffd_done:
  for +book: List<&2,KDef>
  for +next: U32
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/fresh_work.bend:167
law ffd_frame:
  for +frame: FFDefFrame
  for +ctors: List<&2,KDef>
  for +next: U32
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/freshen.bend:8
law f_fresh_term:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +next: U32
  FFresh

# Module: src/front/freshen.bend:14
law f_unquote:
  for +s: String
  String

# Module: src/load/paths.bend:7
law f_unquote_chars:
  for +s: String
  String

# Module: src/load/paths.bend:11
law f_adt:
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/front/families.bend:9
law f_ctor_lookup:
  for +name: String
  for +book: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:12
law f_ctor_more:
  for +name: String
  for +found: KDef
  for +rest: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:18
law f_fresh_prefix_exact_defs:
  for +left: List<&2,KDef>
  for +right: List<&2,KDef>
  Bool

# Module: src/diagnostic/render.bend:4
law dg_snippet_at:
  for +lines: List<&2, String>
  for +at: U32
  for +left: String
  for +length: U32
  String

# Module: src/diagnostic/render.bend:11
law j_app_type:
  for +ty: KTerm
  for +arg: KTerm
  KTerm

# Module: src/back/common/queries.bend:47
law j_string_text:
  for +value: Maybe<&2, String>
  String

# Module: src/back/js/literals.bend:122
law nc_array_known:
  for +k: String
  Bool

# Module: src/back/native/bridge.bend:582
law nc_compact:
  for +t: KTerm
  KTerm

# Module: src/back/native/bridge.bend:594
law nc_compact_succ:
  for +t: KTerm
  for +count: U32
  KTerm

# Module: src/back/native/word-pattern.bend:22
law noa_equal:
  for +value: KTerm
  for +origin: KTerm
  for +facts: List<&2, KTerm>
  Bool

# Module: src/back/native/observer-analysis.bend:155
@unsafe
def subst_terms(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{subst(h, id, v), subst_terms(t, id, v)}

# Module: src/core/term.bend:388
@unsafe
def w7_br_2(w7_c: Bool, +f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  match w7_c:
    case True{}:
      subst(kid(f, 0), ix(f), x)
    case False{}:
      kt_span("App", "", 0, 0, [f, x], begin, end)

@unsafe
def core_apply_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  w7_br_2(p98_tag_eq(f, "Lam"), f, x, begin, end)

# Module: src/core/term.bend:407
law index_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  for +bits: U32
  KDef

@unsafe
def w5c_idx_find_lr(bit: U32, left: KDef, right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match bit:
    case 0: index_find(left, name, hash, bits)
    case _: index_find(right, name, hash, bits)

@unsafe
def w5_idx_find_kdef_t(isLeaf: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name)
    case False{}: index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)

@unsafe
def w5_idx_find_kdef(isAbs: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isAbs:
    case True{}: missing()
    case False{}: w5_idx_find_kdef_t(U32.is_eq(templates, 0), arity, templates, ctors, name, hash, bits)

@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5_idx_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash, bits)
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}:
      w5c_idx_find_lr(U32.and(hash, mask), left, right, name, hash, bits)

@unsafe
def w5_idx_join_if(goLeft: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(da(tree), mask, index_leaf(d, hash, Nil{}), tree)
    case False{}: index_node(da(tree), mask, tree, index_leaf(d, hash, Nil{}))

@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263
@unsafe
def book_final_seen(
  +seen: KDef,
  +name: String,
  +hash: U32,
) -> Bool:
  p88_string_eq(dk(index_find(seen, name, hash, 32)), "$final.seen")

# Module: src/core/index.bend:400
@unsafe
def norm_let(ts):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      norm_let_tail(h, rest)

# Module: src/core/normalize.bend:300
@unsafe
def norm_let_tail(h, rest):
  match rest:
    case Nil{}:
      h
    case Con{x, xs}:
      subst(norm_let(rest), ix(h), kid(h, 0))

# Module: src/core/normalize.bend:309
@unsafe
def w7_br_34(w7_c: Bool, +book: List<&2, KDef>, +stamp: KDef) -> U32:
  match w7_c:
    case True{}:
      da(stamp)
    case False{}:
      norm_max_book(book)

@unsafe
def w7_br_37(w7_c: Bool, +a: KTerm, +b: KTerm) -> Bool:
  match w7_c:
    case True{}:
      norm_exact(a, b)
    case False{}:
      False{}

@unsafe
def norm_cmp_quick(a, b):
  w7_br_37(p98_tag_eq(a, "App") || p98_tag_eq(a, "Ref") || p98_tag_eq(a, "Var") || p98_tag_eq(a, "GCell"), a, b)

# Module: src/core/normalize.bend:572
@unsafe
def g_class_link(+classes: GClasses, +left: U32, +right: U32,
  +leftRank: U32, +rightRank: U32) -> GClasses:
  w7_br_68(U32.is_eq(left,right), classes, left, right, leftRank, rightRank)

@unsafe
def w7_br_69(w7_c: Bool, +st: GState, +classes: GClasses, +left: U32, +right: U32) -> GState:
  match w7_c:
    case True{}:
      st
    case False{}:
      GCompared{g_heap(st),g_next(st),g_class_link(classes,left,right, g_class_rank_entry(g_class_get(classes,left)),g_class_rank_entry(g_class_get(classes,right)))}

@unsafe
def w7_br_74(w7_c: Bool, +st: GState, +t: KTerm) -> GResult:
  match w7_c:
    case True{}:
      g_shared_domain(t, g_share(st, kid(t, 0)))
    case False{}:
      w7_br_73(p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Eql") || p98_tag_eq(t, "Min") || p98_tag_eq(t, "Typ"), st, t)

@unsafe
def g_share_head(
  +st: GState,
  +t: KTerm,
) -> GResult:
  w7_br_74(p98_tag_eq(t, "All"), st, t)

# Module: src/core/graph.bend:315
@unsafe
def g_let_sub(t, bindings):
  match bindings:
    case Nil{}:
      t
    case Con{h, rest}:
      g_let_sub(subst(t, ix(h), kid(h, 0)), rest)

# A telescope domain is independent of its own binder; its deferred codomain
# stays outside the cell so opening that binder still substitutes the body.

# Module: src/core/graph.bend:482
@unsafe
def w7_br_105(w7_c: Bool, +n: U32, +quote: U32) -> String:
  match w7_c:
    case True{}:
      "\\0"
    case False{}:
      w7_br_104(U32.is_eq(n, 92), n, quote)

@unsafe
def w7_br_106(w7_c: Bool, +n: U32, +quote: U32) -> String:
  match w7_c:
    case True{}:
      "\\r"
    case False{}:
      w7_br_105(U32.is_eq(n, 0), n, quote)

@unsafe
def descend_spine(
  +qs: List<&2, KTerm>,
  +args: List<&2, KTerm>,
  +cols: List<&2, KTerm>,
) -> Bool:
  match cols:
    case Nil{}:
      False{}
    case Con{h, t}:
      descend_step(descend(qt(terms_at(qs, 0)), terms_at(args, 0), h), terms_tail(qs), terms_tail(args), t)

# Module: src/check/quantity.bend:176
@unsafe
def w7_br_151(w7_c: Bool, +qs: List<&2, KTerm>, +args: List<&2, KTerm>, +cols: List<&2, KTerm>) -> Bool:
  match w7_c:
    case True{}:
      descend_spine(qs, args, cols)
    case False{}:
      False{}

@unsafe
def w7_br_152(w7_c: Bool, +ord: U32, +qs: List<&2, KTerm>, +args: List<&2, KTerm>, +cols: List<&2, KTerm>) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_151(U32.is_eq(ord, 1), qs, args, cols)

@unsafe
def descend_step(ord, qs, args, cols):
  w7_br_152(U32.is_eq(ord, 0), ord, qs, args, cols)

# Module: src/check/kernel.bend:465
@unsafe
def w7_br_155(w7_c: Bool, +a: KChecking, +b: KChecking, +t: KTerm, +ty: KTerm, +join: Bool) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_154(good(b), a, b, t, ty, join)
    case False{}:
      a

@unsafe
def both(
  +a: KChecking,
  +b: KChecking,
  +t: KTerm,
  +ty: KTerm,
  +join: Bool,
) -> KChecking:
  w7_br_155(good(a), a, b, t, ty, join)

# Module: src/check/kernel.bend:585
@unsafe
def w7_br_157(w7_c: Bool, +fn: KTerm, +x: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      subst(kid(strip(fn), 0), ix(strip(fn)), x)
    case False{}:
      app(fn, x)

@unsafe
def kapply(
  +fn: KTerm,
  +x: KTerm,
) -> KTerm:
  w7_br_157(p98_tag_eq(strip(fn), "Lam"), fn, x)

# Module: src/check/kernel.bend:620
@unsafe
def w7_br_167(w7_c: Bool, +r: KChecking, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      checked(r, ct(r), ty)
    case False{}:
      kr_from(r, dg_bad_detail(rw(r), "type mismatch", ty, cy(r)))

@unsafe
def w7_br_171(w7_c: Bool, +t: KTerm, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_170(U32.is_gt(uses_get(cs(r), ix(t)), q), t, ty, q, r)
    case False{}:
      r

@unsafe
def let_cells(body, bs):
  match bs:
    case Nil{}:
      body
    case Con{h, t}:
      let_cells(subst(body, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), t)

# Module: src/check/kernel.bend:781
@unsafe
def signature_fill_mode(d, fill):
  w7_br_191(p88_string_eq(dk(fill), "Def"), d, fill)

# Every declaration is visible; only completed bodies may unfold. A separate
# event history retains duplicate/law diagnostics without hiding future types.

# Module: src/check/kernel.bend:947
@unsafe
def self_pending(
  +d: KDef,
  +body: KTerm,
) -> U32:
  w7_br_215(du(d), d, body)

# Module: src/check/kernel.bend:1104
@unsafe
def kw_book(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: book

# Module: src/check/kernel.bend:1214
@unsafe
def kw_memo(+world: KWorld) -> List<&2,KSpecMemo>:
  match world:
    case KWorld{book, memo, fresh, checked}: memo

# Module: src/check/kernel.bend:1219
@unsafe
def kw_fresh(+world: KWorld) -> KWorldFresh:
  match world:
    case KWorld{book, memo, fresh, checked}: fresh

# Module: src/check/kernel.bend:1224
@unsafe
def kw_checked(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: checked

# Module: src/check/kernel.bend:1266
@unsafe
def w7_br_221(w7_c: Bool, +t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      checked(r, k_with_children(t, [ct(r)]), ty)
    case False{}:
      r

@unsafe
def w7_br_222(w7_c: Bool, +t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      checked(r, k_with_children(t, ks(ct(r))), ty)
    case False{}:
      r

@unsafe
def w7_br_229(w7_c: Bool, +site: KTerm, +out: List<&2,KTerm>, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      checked(r, k_with_children(site, ki_reverse_terms(out, [ct(r)])), cy(r))
    case False{}:
      r

@unsafe
def w7_br_236(w7_c: Bool, +e: KEnv, +sp: List<&2,KTerm>, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_235(p88_string_eq(nm(ct(r)), cn(e)) && Bool.not(cu(e)) && Bool.not(descend_spine(cq(e), sp_drop(sp, rx(r)), unargs(cl(e), Nil{}))), r)
    case False{}:
      r

@unsafe
def w7_br_240(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      w7_br_239(p98_tag_eq(t, "App"), t)
    case False{}:
      False{}

@unsafe
def w7_br_241(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_240(env_tele_safe_terms(ks(t)), t)

@unsafe
def env_tele_safe(+t: KTerm) -> Bool:
  w7_br_241(core_literal(t) || p98_tag_eq(t, "Var"), t)

# Module: src/check/env-telescope.bend:23
@unsafe
def env_tele_safe_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: kc(Bool, env_tele_safe(h), u => env_tele_safe_terms(rest), u => False{})

# Module: src/check/env-telescope.bend:29
@unsafe
def env_tele_apply_binding(+t: KTerm, +binding: KTelescopeBinding) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}: subst(t, id, value)

# Module: src/check/env-telescope.bend:34
@unsafe
def env_subst_start(+t: KTerm, +bindings: List<&2,KTelescopeBinding>, +first: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match rest:
    case Nil{}: env_tele_apply_binding(t, first)
    case Con{h, tail}: env_subst_term(t, env_subst_reverse(bindings, Nil{}))

# Module: src/check/env-substitution.bend:35
@unsafe
def sk_names(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{head, rest}: sk_quote(head) ++ kc(String, List.is_empty(&2, String, rest), u => "", u => "," ++ sk_names(rest))

# Module: src/check/specialize.bend:148
@unsafe
def sk_var(+t: KTerm, +env: List<&2,KPName>) -> String:
  match env:
    case Nil{}: sk_variable(nm(t), ix(t))
    case Con{KPFile{ns, aliases}, rest}: sk_var(t, rest)
    case Con{KPName{name, id, depth}, rest}:
      kc(String, U32.is_eq(ix(t), id), u => sk_variable(name, depth), u => sk_var(t, rest))

# Module: src/check/specialize.bend:162
@unsafe
def sk_variable(+name: String, +id: U32) -> String:
  "{\"$\":\"Var\",\"k\":" ++ sk_quote(name) ++ ",\"i\":" ++ kc(String, U32.is_eq(id, 4294967295), u => "-1", u => U32.show(id)) ++ "}"

# Module: src/check/specialize.bend:166
@unsafe
def prefix_state_headers(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, p98_tag_eq(dv(d), "Foreign"), u => d, u => declared(d)), prefix_state_headers(rest)}

# Prefix fills must be internal to the prefix. Otherwise dg_event_publish and
# signature_mode inspect suffix bodies; header equality would not suffice.

# Module: src/check/prefix-state.bend:63
@unsafe
def w7b_subst_if(need: Bool, +t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  match need:
    case True{}: subst(t, id, v)
    case False{}: t

@unsafe
def w7b_subst_fast(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  w7b_subst_if(w7b_needs_subst(t, id), t, id, v)

@unsafe
def w7_br_292(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      typ(2)
    case False{}:
      w7_br_291(p98_tag_eq(t, "Qua") || p98_tag_eq(t, "Min"), t)

@unsafe
def f_context_let_done(+pattern: KTerm, +value: KTerm, +outer: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{body, rest}:
      f_choose(FParsed, f_context_stop(body), u => parsed, u => FParsed{kt_span("Local", "", 0, 1, [pattern, f_choose(KTerm, p98_tag_eq(pattern, "Ctr"), u => f_context_head(value), u => value), body], kb(pattern), ke(pattern)), f_context_close(rest, outer)})

# Module: src/front/contextual.bend:150
@unsafe
def w7_br_311(w7_c: Bool, +term: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{f_adt(kt_span(f_choose(String, f_eq(tg(term), "ADT"), u => "ADT", u => "Ref"), nm(resolved), 0, 2, ks(term), kb(term), ke(term)), f_choose(List<&2,KTerm>, f_eq(tg(term), "ADT"), u => ks(term), u => Nil{}), definition), input}
    case False{}:
      fpe_error(f_space(input), "+ requires a binder or quantified datatype", "a quantified datatype after + (+D<..> sets D's leading quantities to &2)")

@unsafe
def w7_atom_ret_err(isRet: Bool, +ts: FInput) -> FParsed:
  match isRet:
    case True{}:
      fpe_word(ts, "return outside do", "a do-block heading this return")
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_br_331(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      7
    case False{}:
      w7_br_330(f_eq(s, ".^."), s)

@unsafe
def w7_br_332(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      6
    case False{}:
      w7_br_331(f_eq(s, ".|."), s)

@unsafe
def w7_br_348(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".is_ge"
    case False{}:
      w7_br_347(f_eq(s, "<<"), s)

@unsafe
def w7_br_349(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".is_le"
    case False{}:
      w7_br_348(f_eq(s, ">="), s)

@unsafe
def w7_br_382(w7_c: Bool, +ts: FInput) -> FParsed:
  match w7_c:
    case True{}:
      fpe_word(ts, "invalid name", f_choose(String, f_reserved(f_tx(ts)), u => "a name (got the keyword '" ++ f_tx(ts) ++ "')", u => "a name (words joined by dots, got '" ++ f_tx(ts) ++ "')"))
    case False{}:
      fpe_error(ts, "expected a name", "a name")

@unsafe
def fpe_name_error(+ts: FInput) -> FParsed:
  w7_br_382(f_ascii_alpha(f_head(f_tx(ts))) || Char.is_eq(f_head(f_tx(ts)), '_'), ts)

# Module: src/front/parser.bend:616
@unsafe
def f_locate(+p: FParsed, +begin: U32, +force: Bool, +spaced: Bool, +created: Bool) -> FParsed:
  match p:
    case FParsed{n, ts}:
      +end = w7_locate_end(spaced, ts)
      w7_locate_keep(U32.is_eq(begin, 0) || U32.is_lt(end, begin) || f_context_stop(n) || (U32.is_gt(kb(n), 0) && Bool.not(force)), n, begin, end, created, ts)

# Module: src/front/parser.bend:631
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
def w7_br_405(w7_c: Bool, +t: KTerm, +vars: List<&2, KTerm>, +next: U32) -> FFlatten:
  match w7_c:
    case True{}:
      ff_parallel(t, vars, ff_flat(kid(t, 2), ks(kid(t, 0)), next))
    case False{}:
      FFlatten{f_lbind(vars, t), next}

@unsafe
def w7_br_406(w7_c: Bool, +t: KTerm, +vars: List<&2, KTerm>, +next: U32) -> FFlatten:
  match w7_c:
    case True{}:
      ff_local(t, vars, next)
    case False{}:
      w7_br_405(f_eq(tg(t), "Parallel"), t, vars, next)

@unsafe
def w7_br_407(w7_c: Bool, +t: KTerm, +vars: List<&2, KTerm>, +next: U32) -> FFlatten:
  match w7_c:
    case True{}:
      ff_match(ks(kid(t, 0)), f_tail_terms(ks(t)), vars, next, t)
    case False{}:
      w7_br_406(f_eq(tg(t), "Local"), t, vars, next)

@unsafe
def w7_br_408(w7_c: Bool, +t: KTerm, +vars: List<&2, KTerm>, +next: U32) -> FFlatten:
  match w7_c:
    case True{}:
      FFlatten{t, next}
    case False{}:
      w7_br_407(f_eq(tg(t), "Match"), t, vars, next)

@unsafe
def ff_flat(
  +t: KTerm,
  +vars: List<&2, KTerm>,
  +next: U32,
) -> FFlatten:
  w7_br_408(ff_failed(t), t, vars, next)

# Module: src/front/flatten.bend:110
@unsafe
def w7_br_409(w7_c: Bool, +t: KTerm, +vars: List<&2, KTerm>, +next: U32) -> FFlatten:
  match w7_c:
    case True{}:
      ff_match([kid(t, 1)], [kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, [kid(t, 0)]), kid(t, 2)])], vars, next, kid(t, 1))
    case False{}:
      ff_let(t, vars, ff_flat(kid(t, 2), [kid(t, 0)], next))

@unsafe
def ff_local(t, vars, next):
  w7_br_409(f_eq(tg(kid(t, 0)), "Ctr"), t, vars, next)

# Module: src/front/flatten.bend:114
@unsafe
def ff_match(heads, rows, vars, next, origin):
  match heads:
    case Nil{}:
      f_choose(FFlatten, U32.is_eq(terms_len(rows), 0), u => FFlatten{kt_span("Efq", "", 0, 0, Nil{}, kb(origin), ke(origin)), next}, u => ff_flat(kid(terms_at(rows, 0), 1), vars, next))
    case Con{+h, hs}:
      f_choose(FFlatten, f_eq(tg(f_first_ctor(rows)), "Absent") && U32.is_gt(terms_len(rows), 0) && ff_variable(h) && f_has_id(vars, ix(h)), u => ff_match(hs, f_var_rows(rows, h), f_mark_vars(vars, ix(h), f_mark_rows(rows, qt(h))), next, origin), u => ff_column(h, hs, rows, vars, next, origin))

# Module: src/front/flatten.bend:134
@unsafe
def ff_column(h, hs, rows, vars, next, origin):
  match vars:
    case Nil{}:
      FFlatten{f_match_error(h, origin), next}
    case Con{+v, vs}:
      f_choose(FFlatten, ff_variable(h) && U32.is_eq(ix(h), ix(v)), u => ff_split(h, hs, rows, v, vs, f_first_ctor(rows), next, origin), u => ff_lam(v, ff_match(Con{h, hs}, rows, vs, next, origin)))

# Module: src/front/flatten.bend:142
@unsafe
def w7_br_410(w7_c: Bool, +h: KTerm, +hs: List<&2, KTerm>, +rows: List<&2, KTerm>, +v: KTerm, +vs: List<&2, KTerm>, +c: KTerm, +next: U32, +origin: KTerm) -> FFlatten:
  match w7_c:
    case True{}:
      FFlatten{kt_span("Efq", "", 0, 0, Nil{}, kb(origin), ke(origin)), next}
    case False{}:
      ff_fields_done(h, hs, rows, v, vs, c, ff_fields(ks(c), f_mark_rows(rows, qt(v)), next), origin)

@unsafe
def ff_split(h, hs, rows, v, vs, c, next, origin):
  w7_br_410(f_eq(tg(c), "Absent"), h, hs, rows, v, vs, c, next, origin)

# Module: src/front/flatten.bend:152
@unsafe
def ff_fields_done(h, hs, rows, v, vs, c, r, origin):
  match r:
    case FFields{+fields, next}:
      ff_hit_done(h, hs, rows, v, vs, c, ff_match(norm_join(fields, hs), f_hit_rows(rows, c, fields, v), norm_join(fields, vs), next, origin), origin)

# Module: src/front/flatten.bend:172
@unsafe
def ff_hit_done(h, hs, rows, v, vs, c, r, origin):
  match r:
    case FFlatten{hit, next}:
      f_choose(FFlatten, ff_failed(hit), u => FFlatten{hit, next}, u => ff_miss_done(c, hit, ff_match(Con{h, hs}, f_miss_rows(rows, nm(c)), Con{v, vs}, next, origin), origin))

# Module: src/front/flatten.bend:178
@unsafe
def f_hit_rows(rows, c, fields, v):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Var") || f_eq(nm(f_rowpat(r)), nm(c)), u => Con{f_hit_row(r, c, fields, v), f_hit_rows(rs, c, fields, v)}, u => f_hit_rows(rs, c, fields, v))

# Module: src/front/elaborate.bend:142
@unsafe
def w7_br_416(w7_c: Bool, +s: String) -> KTerm:
  match w7_c:
    case True{}:
      f_float(s)
    case False{}:
      f_number(s, 0)

@unsafe
def w7_br_424(w7_c: Bool, +origin: KTerm, +value: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_numeric_error(origin, nm(origin), 0, value)
    case False{}:
      k_with_span(value, kb(origin), ke(origin))

@unsafe
def f_literal_value(+origin: KTerm, +value: KTerm) -> KTerm:
  w7_br_424(f_eq(tg(value), "Error") && f_ascii_digit(f_head(nm(origin))) && U32.is_gt(kb(origin), 0), origin, value)

# Module: src/front/elaborate.bend:231
@unsafe
def f_validate_result(r):
  match r:
    case FResult{+book, +err, imports}:
      FResult{book, f_choose(String, String.is_empty(err), u => f_error_defs(book), u => err), imports}

# Module: src/front/sugar.bend:203
@unsafe
def w7_br_444(w7_c: Bool, +s: String) -> FDecoded:
  match w7_c:
    case True{}:
      FDecoded{f_escape_code(f_head(s)), f_tail(s), ""}
    case False{}:
      FDecoded{0, s, "invalid character escape"}

@unsafe
def w7_br_445(w7_c: Bool, +s: String) -> FDecoded:
  match w7_c:
    case True{}:
      f_decode_unicode(f_tail(f_tail(s)), 0, 0)
    case False{}:
      w7_br_444(f_escape_valid(f_head(s)), s)

@unsafe
def w7_br_453(w7_c: Bool, +code: U32, +tail: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_452(core_literal(tail) && p88_string_eq(nm(tail), "String"), code, tail)
    case False{}:
      kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(code)]), f_string_expand(tail)])

@unsafe
def f_string_cons(+code: U32, +tail: KTerm) -> KTerm:
  w7_br_453(U32.is_le(code, 1114111) && (U32.is_lt(code, 55296) || U32.is_gt(code, 57343)), code, tail)

# Module: src/front/unicode.bend:97
@unsafe
def ffd_walk(book, next, built, stack):
  match book:
    case Nil{}:
      ffd_done(List.reverse(&2,KDef,built), next, stack)
    case Con{+definition, pending}:
      ffd_type(definition, pending, built, stack, f_fresh_term(dt(definition), Nil{}, next))

# Module: src/front/fresh_work.bend:188
@unsafe
def ffd_type(definition, pending, built, stack, result):
  match result:
    case FFresh{typ, next}:
      ffd_value(definition, pending, built, stack, typ, f_fresh_term(dv(definition), Nil{}, next))

# Module: src/front/fresh_work.bend:193
@unsafe
def ffd_value(definition, pending, built, stack, typ, result):
  match result:
    case FFresh{value, next}:
      ffd_walk(dc(definition), next, Nil{}, Con{FFDefFrame{definition, pending, built, typ, value}, stack})

# Module: src/front/fresh_work.bend:198
@unsafe
def ffd_done(book, next, stack):
  match stack:
    case Nil{}:
      FFreshDefs{book, next}
    case Con{frame, rest}:
      ffd_frame(frame, book, next, rest)

# Module: src/front/fresh_work.bend:205
@unsafe
def ffd_frame(frame, ctors, next, stack):
  match frame:
    case FFDefFrame{+definition, pending, built, typ, value}:
      ffd_walk(pending, next, Con{KDef{dn(definition), dk(definition), da(definition), dx(definition), typ, value, ctors, db(definition), du(definition)}, built}, stack)

# Module: src/front/freshen.bend:26
@unsafe
def f_fresh_term(t, env, next):
  f_fresh_stack(t, env, next)

# Module: src/front/freshen.bend:30
@unsafe
def f_unquote(s):
  f_unquote_chars(f_tail(s))

# Module: src/load/paths.bend:27
@unsafe
def w7_br_490(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      SCon{Chr{f_escape_code(f_head(f_tail(s)))}, f_unquote_chars(f_tail(f_tail(s)))}
    case False{}:
      SCon{f_head(s), f_unquote_chars(f_tail(s))}

@unsafe
def w7_br_491(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      w7_br_490(Char.is_eq(f_head(s), '\\'), s)

@unsafe
def f_unquote_chars(s):
  w7_br_491(String.is_empty(s) || Char.is_eq(f_head(s), '"'), s)

# Module: src/load/paths.bend:31
@unsafe
def f_adt(t, args, d):
  w7_br_496(U32.is_eq(qt(t), 2) && (Bool.not(f_eq(dk(d), "ADT")) || U32.is_eq(f_leading_quants(dt(d)), 0) || (Bool.not(f_eq(tg(t), "ADT")) && U32.is_lt(f_leading_quants(dt(d)), da(d)))), t, args, d)

# Module: src/front/families.bend:53
@unsafe
def f_scope_apply_span(+head: KTerm, +args: List<&2,KTerm>, +begin: U32, +end: U32) -> KTerm:
  match args:
    case Nil{}: head
    case Con{a, rest}: f_scope_apply_span(f_scope_app_span(head, a, begin, end), rest, begin, end)

# Module: src/front/families.bend:102
@unsafe
def f_ctor_lookup(name, book):
  match book:
    case Nil{}:
      f_find(name, Nil{})
    case Con{+d, ds}:
      f_ctor_named(name, d, ds, f_eq(dk(d), "Ctr") && f_eq(dn(d), name))

# Module: src/front/validate.bend:37
@unsafe
def f_ctor_named(+name: String, +d: KDef, +rest: List<&2,KDef>, +same: Bool) -> KDef:
  match same:
    case True{}: d
    case False{}: f_ctor_children(name, dc(d), rest)

# Module: src/front/validate.bend:43
@unsafe
def f_ctor_children(+name: String, +children: List<&2,KDef>, +rest: List<&2,KDef>) -> KDef:
  match children:
    case Nil{}: f_ctor_lookup(name, rest)
    case Con{child, tail}: f_ctor_more(name, f_ctor_lookup(name, children), rest)

# Module: src/front/validate.bend:49
@unsafe
def w7_br_499(w7_c: Bool, +name: String, +found: KDef, +rest: List<&2,KDef>) -> KDef:
  match w7_c:
    case True{}:
      f_ctor_lookup(name, rest)
    case False{}:
      found

@unsafe
def f_ctor_more(name, found, rest):
  w7_br_499(f_eq(dk(found), "Missing"), name, found, rest)

# Parser scopes retain the first depth-first constructor for each exact name.

# Module: src/front/validate.bend:54
@unsafe
def w7_br_509(w7_c: Bool, +path: String) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      f_import_local(f_strip_bend(f_choose(String, String.starts_with(path, "./"), u => f_drop_chars(path, 2), u => path)))

@unsafe
def f_import_valid(+path: String) -> Bool:
  w7_br_509(Bool.not(String.starts_with(path, "./") || String.starts_with(path, "../") || String.starts_with(path, "/")) && (String.starts_with(path, "0x") || String.contains(path, "@")), path)

# Module: src/load/imports.bend:42
@unsafe
def f_import_token_text(+ts: FInput) -> String:
  w7_br_514(f_eq(f_tx(ts), "+bind"), ts)

# Module: src/load/imports.bend:78
@unsafe
def w7_br_518(w7_c: Bool, +im: KTerm, +s: FSource, +sources: List<&2,FSource>) -> String:
  match w7_c:
    case True{}:
      f_source_path(f_source("Base", sources))
    case False{}:
      f_path_normal(f_path_join(f_path_dir(f_source_path(s)), nm(im)))

@unsafe
def f_import_pathname(
  +im: KTerm,
  +s: FSource,
  +sources: List<&2,FSource>,
) -> String:
  w7_br_518(f_eq(nm(im), "Base"), im, s, sources)

# Module: src/load/graph.bend:177
@unsafe
def w7_br_531(w7_c: Bool, +d: KDef, +imports: List<&2,KTerm>, +scope: List<&2,KDef>) -> KDef:
  match w7_c:
    case True{}:
      f_graph_fill(d, f_find(f_alias(dn(d), imports), List.reverse(&2, KDef, scope)))
    case False{}:
      d

@unsafe
def f_fresh_prefix_exact_defs(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, f_fresh_prefix_exact_head(a, b),
        u => f_fresh_prefix_exact_defs(norm_defs_join(dc(a), ar), norm_defs_join(dc(b), br)), u => False{})
    case other_left other_right: False{}

# Preparation executes the actual freshener once. Only an already canonical
# prefix admits reuse; next is its returned counter, never a guessed max ID.

# Module: src/load/prefix.bend:48
@unsafe
def f_fresh_prefix_prepared(+prefix: List<&2,KDef>, +result: FFreshDefs) -> FFreshPrefixState:
  match result:
    case FFreshDefs{fresh, next}:
      FFreshPrefixState{next, f_fresh_prefix_exact_defs(prefix, fresh)}

# PRIVATE ordinary-driver provenance path. A carrier is created only by the
# actual leading Base injection and advanced only by native completion below.
# The driver never accepts a caller-created carrier or grants this path to raw
# public seed/API objects. Existing graph/prefix APIs keep structural checks.

# Module: src/load/prefix.bend:111
@unsafe
def f_prefix_complete_ready_seed(+source: FSource, +ns: String, +carrier: FPrefixGraph, +path: String, +text: String, +book: List<&2,KDef>, +state: FReadyPrefixState) -> FPrefixCompletion:
  f_prefix_ready_seed_completed(state, f_prefix_complete_seed(source, ns, carrier, path, text, book))

# Module: src/load/prefix.bend:137
@unsafe
def dg_snippet(
  +span: DSpan,
) -> String:
  match span:
    case DNoSpan{}: ""
    case DSpan{source, begin, end}: dg_snippet_at(String.lines(source), dg_line_at(source, begin, 1), dg_marker_left(source, begin, ""), kc(U32, U32.is_gt(end, begin), u => U32.sub(end, begin), u => 0))

# Module: src/diagnostic/render.bend:104
@unsafe
def dg_snippet_at(lines, at, left, length):
  dg_snippet_lines(lines, at, kc(U32, U32.is_lt(dg_lines_count(lines), U32.add(at, 1)), u => dg_lines_count(lines), u => U32.add(at, 1)), 1, left, length)

# Module: src/diagnostic/render.bend:134
@unsafe
def dg_module_snippet(+span: DSpan) -> String:
  match span:
    case DNoSpan{}: ""
    case DSpan{source, begin, end}:
      dg_snippet_at(dg_module_lines(String.lines(source)), dg_line_at(source, begin, 1), dg_marker_left(source, begin, ""), kc(U32, U32.is_gt(end, begin), u => U32.sub(end, begin), u => 0))

# Module: src/diagnostic/render.bend:234
@unsafe
def dg_report(
  +r: KChecking,
  +name: String,
) -> DDiagnostic:
  dg_report_payload(ct(r), ce(r), name)


# Keep the original closed-argument error, except an actual caller variable.

# Module: src/diagnostic/trace.bend:117
@unsafe
def dg_kind_result(+t: KTerm, +q: U32, +name: String, +site: KTerm, +kind: KTerm, +r: KChecking) -> KChecking:
  w7_br_557(p88_string_eq(ce(r), "type mismatch") && p98_tag_eq(ct(r), "DTrace") && norm_exact(kid(ct(r), 0), kind) && norm_exact(kid(ct(r), 3), t) && (U32.is_eq(kb(t), 0) || U32.is_eq(kb(kid(ct(r), 3)), 0) || (U32.is_eq(kb(t), kb(kid(ct(r), 3))) && U32.is_eq(ke(t), ke(kid(ct(r), 3))))), q, name, site, r)

# Module: src/diagnostic/trace.bend:134
@unsafe
def dg_event_failed(+r: KChecking, +fallback: String) -> DChecking:
  +owner = kc(String, p98_tag_eq(ct(r), "DTrace"), u => nm(ct(r)), u => fallback)
  DChecking{KChecking{ct(r), cy(r), cs(r), kc(String, p88_string_eq(owner, ""), u => "", u => owner ++ ": ") ++ ce(r), rw(r), rx(r)}, dg_report(r, fallback)}

# Module: src/diagnostic/produce.bend:147
@unsafe
def dg_event_output(+d: KDef, +body: KTerm) -> KDef:
  w7_br_563(p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(dv(d), "Absent")) && Bool.not(p98_tag_eq(dv(d), "Foreign")), d, body)

# Module: src/diagnostic/produce.bend:163
@unsafe
def w5c2_j_app_type_if(ok: Bool, +ty: KTerm, +arg: KTerm) -> KTerm:
  match ok:
    case True{}: subst(kid(ty, 1), ix(ty), arg)
    case False{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def j_app_type(ty, arg):
  w5c2_j_app_type_if(p98_tag_eq(ty, "All"), ty, arg)

# Module: src/back/common/queries.bend:53
@unsafe
def w7_br_587(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_quote(kl_text(t))
    case False{}:
      j_word_text(Some{kl_number(t)}, p88_string_eq(nm(t), "F32"))

@unsafe
def w7_br_588(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      U32.show(kl_number(t)) ++ "n"
    case False{}:
      w7_br_587(p88_string_eq(nm(t), "String"), t)

@unsafe
def w7_br_591(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_string_text(j_string(t, ""))
    case False{}:
      ""

@unsafe
def j_string_text(value):
  match value:
    case None{}:
      ""
    case Some{s}:
      j_quote(s)


# Literal compression follows checked type provenance, so ordinary constructors
# named Zero, Succ, SNil, etc. keep their user-defined layout in libraries.

# Module: src/back/js/literals.bend:129
@unsafe
def j_fusion_unlet(+t: KTerm, +left: U32) -> KTerm:
  +h = j_strip(t)
  +b = kid(h, 0)
  kc(KTerm, U32.is_gt(left, 0) && p98_tag_eq(h, "Let") && U32.is_eq(terms_len(ks(h)), 2) &&
    p98_tag_eq(b, "Bind") && Bool.not(U32.is_eq(qt(b), 0)) && U32.is_eq(terms_len(ks(b)), 1) &&
    p98_tag_eq(j_strip(kid(b, 0)), "Var"),
    u => j_fusion_unlet(subst(kid(h, 1), ix(b), j_strip(kid(b, 0))), U32.sub(left, 1)), u => h)

# Module: src/back/js/region.bend:877
@unsafe
def nt_cid(k: String) -> String:
  "CID_" ++ String.to_upper(nt_clean(k))

# Module: src/back/native/text.bend:65
@unsafe
def nt_local(k: String, n: U32) -> String:
  nt_clean(k) ++ "_" ++ U32.show(n)

# Module: src/back/native/text.bend:69
@unsafe
def w5c2_ni_f(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_f32(k)
    case False{}: w5c2_ni_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_ni_u(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_u32(k)
    case False{}: w5c2_ni_f(U32.is_eq(c, 102), c, k)

@unsafe
def ne_ctor_node(+k: String, +alloc: String, +ws: List<&2, String>, +n: U32, +hot: Bool) -> N_Emitted:
  +name = nt_local("nd", n)
  +stores = nt_choose(String, hot && String.starts_with(k, "$ctor."),
    u => "#if NATIVE_COLD_USER_CTORS\n" ++ ne_stores(name, ws, 0, False{}) ++ "#else\n" ++ ne_stores(name, ws, 0, True{}) ++ "#endif\n",
    u => ne_stores(name, ws, 0, hot))
  N_Emitted{"u64 " ++ name ++ " = " ++ alloc ++ ";\n#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_" ++ nt_cid(k) ++ "\n" ++ ne_stores(name, ws, 0, False{}) ++ "#else\n" ++ stores ++ "#endif\n", name, U32.inc(n)}

# Module: src/back/native/emit.bend:24
@unsafe
def ne_wrap_ctor(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_ctr(" ++ nt_cid(k) ++ ", " ++ value ++ ")", n}

# Module: src/back/native/emit.bend:29
@unsafe
def w5c2_nc_uses_if(is_var: Bool, +t: KTerm, +uses: NU_Set) -> NU_Set:
  match is_var:
    case True{}: nu_add(uses, ix(t))
    case False{}: nc_uses_list(ks(t), uses)

@unsafe
def nc_uses_term(+t: KTerm, +uses: NU_Set) -> NU_Set:
  w5c2_nc_uses_if(p98_tag_eq(t, "Var"), t, uses)

# Module: src/back/native/bridge.bend:130
@unsafe
def nc_uses_list(+ts: List<&2, KTerm>, +uses: NU_Set) -> NU_Set:
  match ts:
    case Nil{}: uses
    case Con{h, rest}: nc_uses_list(rest, nc_uses_term(h, uses))

# Module: src/back/native/bridge.bend:136
@unsafe
def nc_uses(+t: KTerm) -> NU_Set:
  nc_uses_term(t, NU_Empty{})

# Module: src/back/native/bridge.bend:140
@unsafe
def nc_ctor_context(+book: List<&2, KDef>) -> KDef:
  nc_ctor_payload(dc(ns_context(book)))

# Module: src/back/native/bridge.bend:407
@unsafe
def w7_br_659(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "(blk_cls(" ++ word ++ ") != 0)"
    case False{}:
      "(term_aux(" ++ word ++ ") == " ++ nt_cid(name) ++ ")"

@unsafe
def w5c2_pn_u_res(hit: String, +k: String) -> String:
  match hit:
    case SNil{}: w5c2_pn_fallback(w5c2_pn_u2(k), k)
    case SCon{a, b}: SCon{a, b}

@unsafe
def w5c2_pn_disp_nb(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_fallback(w5c2_pn_nb(k), k)
    case False{}: w5c2_clean_lower(k)

@unsafe
def w5c2_pn_disp_a(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_fallback(w5c2_pn_a(k), k)
    case False{}: w5c2_pn_disp_nb(U32.is_eq(c, 78) || U32.is_eq(c, 66), k)

@unsafe
def w5c2_prim_a(ok: Bool, +k: String) -> Bool:
  match ok:
    case True{}: nc_array_known(k)
    case False{}: False{}

@unsafe
def w5c2_arity_a(ok: Bool, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_arr4(String.eq(k, "array_atomic_cas"), k)
    case False{}: 1

@unsafe
def w5c2_arity_b(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_2_if(String.eq(k, "bool_or") || String.eq(k, "bool_xor"))
    case False{}: w5c2_arity_a(U32.is_eq(c, 97), k)

@unsafe
def nc_literal(+t: KTerm) -> NC_Literal:
  w7_br_675(core_literal(t) && Bool.not(p88_string_eq(nm(t), "String")), t)

# Module: src/back/native/bridge.bend:587
@unsafe
def nc_compact_list(
  +ts: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nc_compact(h), nc_compact_list(rest)}

# Module: src/back/native/bridge.bend:600
@unsafe
def nc_compact_ctor(+t: KTerm, lit: NC_Literal) -> KTerm:
  match lit:
    case NC_Literal{valid, value}:
      nt_choose(KTerm, valid, u => kt("NWord", U32.show(value), 0, 0, Nil{}), u => nt_choose(KTerm, p88_string_eq(nm(t), "Succ") && U32.is_eq(terms_len(ks(t)), 1), u => nc_compact_succ(kid(t, 0), 1), u => k_rebuild(t, nm(t), ix(t), qt(t), nc_compact_list(ks(t)), Nil{}, 0, 0)))

# Module: src/back/native/bridge.bend:606
@unsafe
def w7_br_676(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      nc_compact_plain(t)

@unsafe
def nc_compact(t):
  w7_br_676(p98_tag_eq(t, "NStatic"), t)

# Module: src/back/native/bridge.bend:610
@unsafe
def w7_br_677(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_compact(core_literal_step(t))
    case False{}:
      kt("NWord", U32.show(kl_number(t)), 0, 0, Nil{})

@unsafe
def w7_br_678(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_compact_ctor(t, nc_literal(t))
    case False{}:
      k_rebuild(t, nm(t), ix(t), qt(t), nc_compact_list(ks(t)), Nil{}, 0, 0)

@unsafe
def w7_br_679(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_677(p88_string_eq(nm(t), "String"), t)
    case False{}:
      w7_br_678(p98_tag_eq(t, "Ctr"), t)

@unsafe
def nc_compact_plain(+t: KTerm) -> KTerm:
  w7_br_679(core_literal(t), t)

# Typed erasure renames user-owned constructors; this pass sees native Succ only.
# Keep the first checked increment: even a malformed foreign U64 tail retains
# its original wrapping/error behavior before the bounded remaining offset.

# Module: src/back/native/bridge.bend:652
@unsafe
def w7_br_680(w7_c: Bool, +t: KTerm, +count: U32) -> KTerm:
  match w7_c:
    case True{}:
      kt("Ctr", "Succ", 0, 0, [nc_compact(t)])
    case False{}:
      kt("NNatAdd", U32.show(U32.sub(count, 1)), 0, 0, [nc_compact(t)])

@unsafe
def w7_br_681(w7_c: Bool, +t: KTerm, +count: U32) -> KTerm:
  match w7_c:
    case True{}:
      nc_compact_succ(kid(t, 0), U32.inc(count))
    case False{}:
      w7_br_680(U32.is_eq(count, 1), t, count)

@unsafe
def w7_br_682(w7_c: Bool, +t: KTerm, +count: U32) -> KTerm:
  match w7_c:
    case True{}:
      nc_compact(t)
    case False{}:
      w7_br_681(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "Succ") && U32.is_eq(terms_len(ks(t)), 1) && U32.is_lt(count, 4294967295), t, count)

@unsafe
def nc_compact_succ(t, count):
  w7_br_682(U32.is_eq(count, 0), t, count)

# Module: src/back/native/direct.bend:5
@unsafe
def nd_comb_try(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  +params = nd_bindings(body, Nil{})
  +value = nd_body(body)
  nt_choose(KTerm, U32.is_eq(nt_count(NC_Binding, params), arity), u =>
    nt_choose(KTerm, nd_comb_closed(value, params, 8), u =>
      nt_choose(KTerm, nd_comb_linear(params, value), u =>
        nt_choose(KTerm, nd_comb_fresh(body, args, env, n, arity),
          u => nd_comb_fill(nd_comb_rename(body, n, arity), args), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/direct.bend:259
@unsafe
def nc_array_known(k):
  match k:
    case SNil{}: False{}
    case SCon{h, _}: w5c2_nc_arr_known_go(U32.is_eq(Char.to_u32(h), 97), k)

# Module: src/back/native/scalar-array.bend:4
@unsafe
def nc_source_bound(+book: List<&2, KDef>, bound: Maybe<&2, U32>) -> U32:
  match bound:
    case None{}: norm_max_book(book)
    case Some{value}: value

# Module: src/back/native/book.bend:276
@unsafe
def ns_body(+book: List<&2, KDef>, +name: String) -> KDef:
  index_find(index_first(dc(ns_context(book))), name, index_hash(name, 2166136261), 32)

# Module: src/back/native/static.bend:54
@unsafe
def ns_ctor_known(+cs: KDef, +name: String, +arity: U32) -> Bool:
  +d = index_find(cs, name, index_hash(name, 2166136261), 32)
  p88_string_eq(dk(d), "NativeStaticCtor") && U32.is_eq(da(d), arity)

# Module: src/back/native/static.bend:73
@unsafe
def ns_packed(+t: KTerm) -> Bool:
  ns_packed_fields(t, ks(t))

# Module: src/back/native/static.bend:116
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
def w7_br_780(w7_c: Bool, +origin: KTerm, +want: KTerm) -> Bool:
  match w7_c:
    case True{}:
      noa_below(kid(origin, 0), want)
    case False{}:
      False{}

@unsafe
def w7_br_781(w7_c: Bool, +origin: KTerm, +want: KTerm) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_780(p98_tag_eq(origin, "OField"), origin, want)

@unsafe
def noa_below(+origin: KTerm, +want: KTerm) -> Bool:
  w7_br_781(norm_exact(origin, want), origin, want)

# Module: src/back/native/observer-analysis.bend:405
@unsafe
def dr_known(+safe: KDef, +name: String) -> Bool:
  p88_string_eq(dk(index_find(safe, name, index_hash(name, 2166136261), 32)), "ReportSafe")

# Module: src/driver/report.bend:123
@unsafe
def p88_field(state: P88State, role: U32) -> P88Step:
  p88_field_number(p88_number(state), role)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:143
@unsafe
def p88_field_number(step: P88Step, role: U32) -> P88Step:
  match step:
    case P88Step{state, P88Word{+n}}:
      match role:
        case 1: P88Step{state, P88Word{n}}
        case 2: p88_bool_value(state,n)
        case 3: p88_string_at(state, n)
        case 13: p88_head_at(state, n, U32.is_ge(n, 2147483648))
        case other: p88_node_at(state, n, role)
    case P88Step{state, other}: P88Step{p88_state_bad(state), P88Bad{}}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:155
@unsafe
def p88_roots_ready(products: P88Products, fresh: FFreshPrefixState, ready: FReadyPrefixState, world: KBasePreparedWorld) -> P88Decoded:
  match fresh ready world:
    case FFreshPrefixState{next,True{}} FReadyPrefixState{names,ctors,count,True{}} KBasePreparedWorld{KBasePrefixState{bound,delta,stamp,patches,True{}},prefix,final,book,checked,seen,todos,checkedBound}:
      p88_roots_gate(products,U32.is_ge(next,1) && U32.is_le(count,65536) && U32.is_le(bound,16777216) && U32.is_le(stamp,delta))
    case f r w: P88DecodeError{"cache readiness"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:320
@unsafe
def p86_prepare_states(+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld) -> P86Preparation:
  match fresh ready world:
    case FFreshPrefixState{next, fresh_ok} FReadyPrefixState{names, ctors, count, ready_ok} KBasePreparedWorld{state, prefix, final, saved, checked, seen, todos, bound}:
      match state:
        case KBasePrefixState{base_bound, delta, stamp, patches, checked_ok}:
          kc(P86Preparation, fresh_ok && ready_ok && checked_ok,
            u => P86PreparationReady{P86Seed{source, book, fresh, ready, world}},
            u => P86PreparationError{"base_prepare: prefix preparation was not eligible"})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:460
@unsafe
def w7_br_800(w7_c: Bool, +body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  match w7_c:
    case True{}:
      p205u_binders(kid(body,0),owner,arity,index)
    case False{}:
      p205u_binders(body,owner,arity,index)

@unsafe
def p205u_character(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  w7_br_800(p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"Chr") && U32.is_eq(terms_len(ks(body)),2) && p98_tag_eq(kid(body,1),"Efq"), body, owner, arity, index)
@unsafe
def w7_br_834(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_lt(a, b))
    case False{}:
      w7_br_833(agy_str_eq(op, "u32_is_le"), op, a, b)

@unsafe
def w7_br_835(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_ne(a, b))
    case False{}:
      w7_br_834(agy_str_eq(op, "u32_is_lt"), op, a, b)

@unsafe
def w7_br_853(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_848(U32.is_eq(b, 0), a, b)
    case False{}:
      w7_br_852(agy_str_eq(op, "nat_is_eq"), op, a, b)

@unsafe
def w7_br_854(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_847(U32.is_eq(b, 0), a, b)
    case False{}:
      w7_br_853(agy_str_eq(op, "nat_mod"), op, a, b)

@unsafe
def w7_br_862(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_ne(a, b))
    case False{}:
      w7_br_861(agy_str_eq(op, "f32_is_lt"), op, a, b)

@unsafe
def w7_br_863(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_eq(a, b))
    case False{}:
      w7_br_862(agy_str_eq(op, "f32_is_ne"), op, a, b)

@unsafe
def ctfe_eval_ctr(+cname: String, r: CtfeListRes) -> CtfeRes:
  match r:
    case CtfeListRes{+vs, +f2, ok}:
      kc(CtfeRes, ok, v => CtfeRes{ctfe_pack_ctr(cname, vs), f2}, v => CtfeRes{CVFail{}, f2})

@unsafe
def w7_br_877(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_f32(v)
    case False{}:
      w7_br_876(agy_str_eq(owner, "Bool"), owner, v)

@unsafe
def w7_br_878(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_nat(ctfe_as_nat(v, 0))
    case False{}:
      w7_br_877(agy_str_eq(owner, "F32"), owner, v)

@unsafe
def agy_abs_subst_lams(+body: KTerm, lams: List<&2,KTerm>, sargs: List<&2,KTerm>) -> KTerm:
  match lams sargs:
    case Nil{} _: body
    case Con{+l,lr} Con{+a,ar}: agy_abs_subst_lams(subst(body,ix(l),a),lr,ar)
    case _ _: body

@unsafe
def w7_br_895(w7_c: Bool, +a0: KTerm, +a1: KTerm, +xid: U32, +pid: U32) -> AgyStep:
  match w7_c:
    case True{}:
      agy_bf_is_shln(a1,pid)
    case False{}:
      w7_br_894(agy_bf_is_var(a1,xid), a0, pid)

@unsafe
def agy_bf_step_pair(+a0: KTerm, +a1: KTerm, +xid: U32, +pid: U32) -> AgyStep:
  w7_br_895(agy_bf_is_var(a0,xid), a0, a1, xid, pid)

@unsafe
def agy_bf_build_dispatch(+raw: KDef, +dname: String, +arity: U32, +bid: U32) -> KDef:
  +vs = agy_bf_fresh_lams(arity,U32.add(bid,120),0)
  +vd = p205u_at(vs,0)
  +cond = app(app(ref("Nat.sub"),vd),app(ref("U32.to_nat"),agy_bf_u32(31)))
  +call = agy_bf_apps(ref(dname),Con{cond,vs})
  dg_event_output(raw,agy_bf_wrap_vars(vs,call))

@unsafe
def w5c3_ar_sub(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.sub(a,b),"",0,0}
    case False{}: w5c3_ar_mul(String.eq(op,"u32_mul"), op, a, b)

@unsafe
def w5c3_ar_add(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.add(a,b),"",0,0}
    case False{}: w5c3_ar_sub(String.eq(op,"u32_sub"), op, a, b)

@unsafe
def w5c2_rcmp_gt(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_gt(la,hb), U32.is_le(ha,lb))
    case False{}: w5c2_rcmp_eq(String.eq(op,"u32_is_eq"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_ge(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_ge(la,hb), U32.is_lt(ha,lb))
    case False{}: w5c2_rcmp_gt(String.eq(op,"u32_is_gt"), op, la, ha, lb, hb)

@unsafe
def w7_br_917(w7_c: Bool, +fname: String, +st_ty: KTerm, +nil_br: KTerm, +scon_br: KTerm) -> W2Fold:
  match w7_c:
    case True{}:
      w2d_fold_lam_res(fname,st_ty,nil_br,scon_br, w2d_extract_step(kid(kid(scon_br,0),0),fname,ix(kid(scon_br,0))))
    case False{}:
      W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}

@unsafe
def w7_br_918(w7_c: Bool, +fname: String, +st_ty: KTerm, +nil_br: KTerm, +scon_br: KTerm) -> W2Fold:
  match w7_c:
    case True{}:
      w2d_fold_chr_res(fname,st_ty,nil_br,scon_br,kid(scon_br,0), w2d_extract_step(kid(kid(kid(scon_br,0),0),0),fname,ix(kid(kid(scon_br,0),0))))
    case False{}:
      w7_br_917(p98_tag_eq(scon_br,"Lam") && p98_tag_eq(kid(scon_br,0),"Lam"), fname, st_ty, nil_br, scon_br)

@unsafe
def w2d_check_rec_peels(+pname: String, +ar: U32, +zp: AgyPeel, +sp: AgyPeel) -> W2Builder:
  match zp sp:
    case AgyPeel{lams0,zbody,ok0} AgyPeel{lams1,sbody,ok1}:
      +zrest = w2d_last(lams0)
      +srest = w2d_last(lams1)
      kc(W2Builder,ok0 && ok1 && agy_bf_is_var(zbody,ix(zrest)),
        u => w2d_check_rec_succ(pname,ar,lams0,lams1,ix(srest),w2d_peel_lets(sbody)),
        u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w7_br_921(w7_c: Bool, +pname: String, +ar: U32, +body: KTerm) -> W2Builder:
  match w7_c:
    case True{}:
      w2d_check_rec_peels(pname,ar,agy_bf_peel(kid(body,0),U32.sub(ar,1)),agy_bf_peel(kid(kid(body,1),0),ar))
    case False{}:
      W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}}

@unsafe
def w7_br_924(w7_c: Bool, +cname: String, +hid: U32, +call: KTerm, +acc_id: U32) -> W2UnboxArm:
  match w7_c:
    case True{}:
      w2d_check_self_arm_st(cname,hid,w2d_init(ks(call)),j_strip(w2d_last(ks(call))),acc_id)
    case False{}:
      W2UnboxArm{"",0,atom("Absent"),[],False{}}

@unsafe
def w2d_check_self_arm_call(+cname: String, +hid: U32, +call: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  w7_br_924(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),hname) && U32.is_eq(terms_len(ks(call)),ar), cname, hid, call, acc_id)

law w2d_rewrite_to_inner:
  for +t: KTerm
  for +hname: String
  for +cname: String
  for +iname: String
  for +ar: U32
  KTerm

@unsafe
def w2d_rewrite_to_inner_list(xs: List<&2,KTerm>, +hname: String, +cname: String, +iname: String, +ar: U32) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{w2d_rewrite_to_inner(x,hname,cname,iname,ar),w2d_rewrite_to_inner_list(rest,hname,cname,iname,ar)}

@unsafe
def w7_br_926(w7_c: Bool, +t: KTerm, +call: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32) -> KTerm:
  match w7_c:
    case True{}:
      w2d_rewrite_to_inner_st(t,w2d_init(ks(call)),j_strip(w2d_last(ks(call))),cname,iname)
    case False{}:
      k_with_children(t,w2d_rewrite_to_inner_list(ks(t),hname,cname,iname,ar))

@unsafe
def w2d_rewrite_to_inner_call(+t: KTerm, +call: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32) -> KTerm:
  w7_br_926(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),hname) && U32.is_eq(terms_len(ks(call)),ar), t, call, hname, cname, iname, ar)

@unsafe
def w7_br_927(w7_c: Bool, +t: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32) -> KTerm:
  match w7_c:
    case True{}:
      w2d_rewrite_to_inner_call(t,j_call_spine(t,[]),hname,cname,iname,ar)
    case False{}:
      k_with_children(t,w2d_rewrite_to_inner_list(ks(t),hname,cname,iname,ar))

@unsafe
def w2d_rewrite_to_inner(t, hname, cname, iname, ar):
  w7_br_927(p98_tag_eq(t,"App"), t, hname, cname, iname, ar)

law w2d_push_into_mat:
  for +fn_term: KTerm
  for +t: KTerm
  for +next: U32
  FFresh

@unsafe
def w2d_pim_pair1(+fn_term: KTerm, +m: KTerm, +r0: FFresh) -> FFresh:
  match r0:
    case FFresh{t0,n1}: w2d_pim_pair2(m,t0,w2d_push_into_mat(fn_term,kid(m,1),n1))

@unsafe
def w2d_push_into_mat(fn_term, t, next):
  +s = j_strip(t)
  kc(FFresh,p98_tag_eq(s,"Efq"),u => FFresh{s,next},u =>
  kc(FFresh,p98_tag_eq(s,"Lam"),v => w2d_pim_lam(s,w2d_push_into_mat(fn_term,kid(s,0),next)),v =>
  kc(FFresh,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),w => w2d_pim_let(kid(s,0),w2d_push_into_mat(fn_term,kid(s,1),next)),w =>
  kc(FFresh,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),x => w2d_pim_pair1(fn_term,s,w2d_push_into_mat(fn_term,kid(s,0),next)),x =>
  kc(FFresh,p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)),y => w2d_pim_app(kid(s,1),w2d_push_into_mat(fn_term,kid(s,0),next)),y =>
    w2d_pim_leaf(s,f_fresh_term(fn_term,[],next)))))))

@unsafe
def w2d_st_snd_ty(+st_ty: KTerm) -> KTerm:
  +s = j_strip(st_ty)
  kc(KTerm,p98_tag_eq(s,"App"),u => w2d_st_snd_ty_call(j_call_spine(s,[])),u => atom("Absent"))

@unsafe
def ntr_eligible(+t: KTerm, +target: NC_Target, +n: U32) -> Bool:
  +count = terms_len(ks(t))
  nt_choose(Bool, ntr_target(target) && U32.is_ge(count, 2) && U32.is_le(count, 8) && U32.is_lt(n, 4294967200), u =>
    nt_choose(Bool, p88_string_eq(nm(t), "Con") || p88_string_eq(nm(t), "SCon") || String.starts_with(nm(t), "$ctor."), v =>
      ntr_tail_eligible(ntr_last(ks(t)), ntr_prefix(ks(t)), target), v => False{}), u => False{})

@unsafe
def ntr_tail_eligible(+call: KTerm, +prefix: List<&2, KTerm>, +target: NC_Target) -> Bool:
  +head = nd_head(call)
  +args = nd_args(call, Nil{})
  +owner = ntr_owner(target)
  p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && p88_string_eq(nm(head), owner) &&
    U32.is_eq(terms_len(args), ntr_params(target)) &&
    Bool.not(ntr_refs(prefix, owner) || ntr_refs(args, owner))

# Ordinary nested lets retain exact left-to-right evaluation and sharing.
@unsafe
def p111_show_names(constructors: List<&2, N_Constructor>) -> List<&2, String>:
  match constructors:
    case Nil{}: Nil{}
    case Con{N_Constructor{name, arity, hot}, rest}: Con{name_key(nc_ctor_display(name)), p111_show_names(rest)}

@unsafe
def p111_show_finish(+constructors: List<&2, N_Constructor>, graph: P111ShowGraph) -> P111Show:
  match graph:
    case P111ShowGraph{+cells, +offsets, +error}:
      nt_choose(P111Show, agy_str_eq(error, ""),
        u => p111_show_finish_words(p111_show_names(constructors), p111_show_resolve_all(cells, offsets, constructors)),
        u => P111Show{Nil{}, Nil{}, error})

@unsafe
def w5c2_opid_df(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_f(k)
    case False{}: w5c2_opid_dn(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_opid_du(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_u(k)
    case False{}: w5c2_opid_df(U32.is_eq(c, 102), c, k)

@unsafe
def p111_take(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2, N111Stmt>:
  p185pt_take(name,word,count,n)

@unsafe
def p111_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  p112_special_test(name, word)

law w5c3_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  KDef

@unsafe
def w5c_find_lr(bit: U32, left: KDef, right: KDef, +name: String, +hash: U32) -> KDef:
  match bit:
    case 0: w5c3_find(left, name, hash)
    case _: w5c3_find(right, name, hash)

@unsafe
def w5c3_find_kdef_t0(t0: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match t0:
    case True{}: w5c3_find_leaf(U32.is_eq(arity, hash), ctors, name)
    case False{}: w5c3_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash)

@unsafe
def w5c3_find_kdef(is_abs: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match is_abs:
    case True{}: missing()
    case False{}: w5c3_find_kdef_t0(U32.is_eq(templates, 0), arity, templates, ctors, name, hash)

@unsafe
def w5c3_find(tree, name, hash):
  match tree:
    case KIndexLeaf{stored, bucket}: w5c3_find_leaf(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}: w5c_find_lr(U32.and(hash, mask), left, right, name, hash)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5c3_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash)

@unsafe
def w5c3_inter_leaf_rb(rb: List<&2,KDef>, +lh: U32, +lb: List<&2,KDef>) -> KDef:
  match rb:
    case Nil{}: missing()
    case Con{_, _}: w5c3_leaf_from(lh, w5c3_inter_buckets(lb, rb))

@unsafe
def w5c3_inter_node_lb(lb2: List<&2,KDef>, +rh: U32, +rb: List<&2,KDef>) -> KDef:
  match lb2:
    case Nil{}: missing()
    case Con{_, _}: w5c3_leaf_from(rh, w5c3_inter_buckets(lb2, rb))

@unsafe
def w5c3_sig9(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,3,1]
    case False{}: w5c3_sig10(String.eq(s,"p111_rt_apply"), s)

@unsafe
def w5c3_sig4(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2,3,1]
    case False{}: w5c3_sig9(String.eq(s,"p111_rt_return"), s)

@unsafe
def w5c3_cc_jump(m: Bool, +symbol: String, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target))
    case False{}: w5c3_cc_clo(String.eq(symbol,"p111_rt_closure"), symbol, target, count)

@unsafe
def w5c3_ctr_stest(m: Bool, +symbol: String, +args: List<&2,N111Arg>) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      U32.is_gt(id,0) && U32.is_lt(id,10)
    case False{}: w5c3_ctr_fail(String.eq(symbol,"p111_rt_fail"), args)

@unsafe
def p111q_main_id(ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,constructors}: da(index_find(functions,"main",index_hash("main",2166136261),32))

@unsafe
def p112_liveness_head(+head: KTerm, +rest: P112Liveness) -> P112Liveness:
  P112LivenessLet{kid(head, 0), ix(head), nc_uses_term(head, p112_liveness_uses(rest)), rest}


@unsafe
def p112_liveness_bind(+value: KTerm, +id: U32, +rest: P112Liveness) -> P112Liveness:
  P112LivenessLet{value, id, nc_uses_term(value, p112_liveness_uses(rest)), rest}

# Preserve nd_bind_value's ordered argument bindings and exact fresh identifiers.


@unsafe
def p112t_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_failure(body),u => P112TailBody{True{},0,p112t_scalars(body)},u =>
    p112t_scan_normal(body,owner,arity))

@unsafe
def p112t_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  match body:
    case Nil{}: P112TailBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112e_tail_yes(condition,no,rest,owner,arity,p112t_scan(yes,owner,arity))
    case Con{+stmt,+rest}:
      nt_choose(P112TailBody,p112t_scalar_safe(stmt),
        u => p112e_tail_scalar(stmt,p112t_scan_normal(rest,owner,arity)),u => P112TailBody{False{},0,[]})

@unsafe
def p112t_admit_prelude(+owner: String, +arity: U32, prelude: P112TailPrelude) -> P112TailPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,+prefix,+body}:
      nt_choose(P112TailPlan,valid,u => p112t_finish(params,prefix,p112t_scan(body,owner,arity)),
        u => P112TailPlan{False{},0,[],[],[]})


@unsafe
def p112t_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_tail(body,owner,arity,0),
    u => P112TailBody{True{},1,p112t_tail_nodes(body,arity)},
    u => nt_choose(P112TailBody,p112t_transition(body),
      v => P112TailBody{True{},0,p112t_scalars(body)},v => p112t_scan_next(body,owner,arity)))


@unsafe
def p112s_context_ctors(book: List<&2,KDef>) -> KDef:
  p112s_context_ctors_list(dc(ns_context(book)))


@unsafe
def p112s_context_nodes(book: List<&2,KDef>) -> KDef:
  p112s_context_nodes_list(dc(ns_context(book)))


@unsafe
def p112e_tail_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>,
  +owner: String, +arity: U32, +yes: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(yes),
    u => p112e_tail_no(condition,rest,owner,arity,yes,p112t_scan(no,owner,arity)),
    u => P112TailBody{False{},0,[]})


@unsafe
def p112e_tail_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32,
  +yes: P112TailBody, +no: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(no),
    u => p112e_tail_rest(condition,yes,no,p112t_scan(rest,owner,arity)),u => P112TailBody{False{},0,[]})


@unsafe
def p112f_index_build(segments: List<&2,N111Segment>, +tree: P112FusionIndex) -> P112FusionIndex:
  match segments:
    case Nil{}: tree
    case Con{+segment,+rest}: p112f_index_build(rest,p112f_index_add(tree,segment))


@unsafe
def p112f_index(segments: List<&2,N111Segment>) -> P112FusionIndex:
  p112f_index_build(segments,P112FusionEmpty{})


@unsafe
def p112f_cont_result(body: List<&2,N111Stmt>, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,agy_str_eq(symbol,"p111_rt_reg_get") && agy_str_eq(state,"state") && Bool.not(nb_contains(captures,word) || agy_str_eq(word,"state") || agy_str_eq(word,"scratch")) && p112f_safe(rest) && U32.is_le(p112f_size(rest),128),
        u => Some{P112FusionCont{nt_reverse(String,captures,[]),word,pop,rest}},u => None{})
    case _: None{}


@unsafe
def p112f_cont_gets(+body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,index),u => p112f_cont_result(body,captures,pop),u =>
    p112f_cont_get(body,count,index,captures,pop))


@unsafe
def p112f_cont_get(body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+slot,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,agy_str_eq(symbol,"p111_rt_stack_get") && agy_str_eq(state,"state") && U32.is_eq(slot,index) && Bool.not(nb_contains(captures,word) || agy_str_eq(word,"state") || agy_str_eq(word,"scratch")),
        u => p112f_cont_gets(rest,count,U32.inc(index),Con{word,captures},pop),u => None{})
    case _: None{}


@unsafe
def p112m_body(+row: KTerm, +rest: List<&2,KTerm>, +n: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(qt(row),0),u => nd_reapply(kid(row,0),rest),
    u => nd_reapply(nw_restore(nd_beta(kid(row,0),nt_choose(List<&2,KTerm>,U32.is_eq(qt(row),1),
      v => [var("",nc_id(U32.add(n,2)))],v => [var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))])),
      nw_prefix(ix(row),nw_value(row),nt_choose(KTerm,U32.is_eq(qt(row),1),
        v => var("",nc_id(U32.add(n,2))),v => nw_word(var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))))),nc_id(n)),rest))


@unsafe
def p112c_candidate(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Bool,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64),
        u => p112f_clean(body),u => False{})


@unsafe
def p112g_pure(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112g_word_type(typ) && p112g_name(name) && p112g_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112g_word_type(typ) && p112g_name(name) && p112g_value(left) && p112g_value(right)
    case _: False{}


@unsafe
def p112h_candidate(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{+condition,+yes,+no}: True{}
    case _: p112g_pure(stmt)

# A successful result is the remaining shared budget. Every statement node,
# including If and both branches (even the unselected branch), costs one.


@unsafe
def p112h_stmt(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,U32.is_eq(left,0),u => None{},u => p112h_stmt_room(stmt,U32.sub(left,1)))


@unsafe
def p112h_stmt_room(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  match stmt:
    case N111If{+condition,+yes,+no}:
      nt_choose(Maybe<&2,U32>,p112h_condition(condition),u => p112h_rest(no,p112h_nodes(yes,left)),u => None{})
    case _: nt_choose(Maybe<&2,U32>,p112g_pure(stmt),u => Some{left},u => None{})


@unsafe
def p112h_nodes(body: List<&2,N111Stmt>, +left: U32) -> Maybe<&2,U32>:
  match body:
    case Nil{}: Some{left}
    case Con{+stmt,+rest}: p112h_rest(rest,p112h_stmt(stmt,left))


@unsafe
def p112h_rest(+body: List<&2,N111Stmt>, result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{+left}: p112h_nodes(body,left)


@unsafe
def p113e_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113e_scalar_safe(head) && p113e_scalars(rest)


@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,agy_str_eq(symbol,"p126_rt_nat_divmod"),u => p113e_runtime_args(args),u => p126dp_original_scalar_safe(stmt))
    case _: p126dp_original_scalar_safe(stmt)

@unsafe
def p113p_transfer(+shape: KTerm, +wanted: KTerm, +values: List<&2,N111Value>) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_shapes_valid([shape,wanted]) && nq_same(shape,wanted) && U32.is_eq(nq_width(shape),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"product result shape mismatch"},
      v => nt_choose(P113PValueCode,p113p_known(shape) && U32.is_eq(ix(shape),nt_count(N111Value,values)),
        w => p113p_boxed(p111_constructor(nm(shape),values)),
        w => P113PValueCode{[],[],"opaque product result width mismatch"})))


@unsafe
def p113p_constructor(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_known(wanted) && agy_str_eq(nm(wanted),name) && U32.is_eq(ix(wanted),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"constructor product shape mismatch"},
      v => p113p_boxed(p111_constructor(name,values))))


@unsafe
def p113pl_output(+shape: KTerm, +values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),
    u => p118t_completed(n,p113p_transfer(shape,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},values)),
    u => p113pl_emitted(target,n,p113p_transfer(shape,p113pl_shape(target),values)))

@unsafe
def p113i_clean(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113i_scalar_clean(stmt) && p113i_clean(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113i_value(condition) && p113i_clean(yes) && p113i_clean(no) && p113i_clean(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113i_names(destinations) && p113i_values(args) && p113i_clean(rest)
    case Con{P113DResult{values},rest}: p113i_values(values) && p113i_clean(rest)
    case Con{P113DAgain{values},rest}: p113i_values(values) && p113i_clean(rest)


@unsafe
def w4i_returns_or_again(body: List<&2,P113DStmt>, +width: U32, +arity: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DAgain{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),arity)
    case Con{P113DIf{condition,yes,no},Nil{}}: w4i_returns_or_again(yes,width,arity) && w4i_returns_or_again(no,width,arity)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && w4i_returns_or_again(rest,width,arity)
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && w4i_returns_or_again(rest,width,arity)
    case Con{P113DCall{destinations,target,args},rest}: w4i_returns_or_again(rest,width,arity)
    case _: False{}


@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +sz = p113i_size(body)
      +arity = nt_count(NC_Binding,params)
      Bool.not(p126s_is_table(function)) && Bool.not(w6_body_calls_self(name,body)) &&
        U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&
        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&
        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))

@unsafe
def p113i_original_clean(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p113i_params(params) && p113i_clean(body)


@unsafe
def p113j_scratch_call(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),0),u => 0,u =>
  nt_choose(U32,agy_str_eq(symbol,"p111_rt_op") || agy_str_eq(symbol,"p111_rt_ctor") ||
      agy_str_eq(symbol,"p111_rt_take") || agy_str_eq(symbol,"p111_rt_special_ctor") ||
      agy_str_eq(symbol,"p113_rt_array_pair"),
    u => p113j_scratch_count(args,2,3),u =>
  nt_choose(U32,agy_str_eq(symbol,"p111_rt_special_take"),
    u => p113j_scratch_count(args,3,4),u => 2048)))


@unsafe
def p113j_scratch_scalar(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Load{name,typ,+base,+offset}:
      nt_choose(U32,p113j_is_scratch(base),u => U32.min(2048,U32.add(offset,8)),u => 0)
    case N111Store{typ,+base,+offset,+value}:
      nt_choose(U32,p113j_is_scratch(value),u => 2048,u =>
        nt_choose(U32,p113j_is_scratch(base),v => U32.min(2048,U32.add(offset,8)),v => 0))
    case N111Call{name,typ,symbol,args}: p113j_scratch_call(symbol,args)
    case N111If{condition,yes,no}:
      nt_choose(U32,p113j_is_scratch(condition),u => 2048,u => U32.max(p113j_scratch_scalars(yes),p113j_scratch_scalars(no)))
    case N111Set{name,typ,value}: nt_choose(U32,p113j_is_scratch(value),u => 2048,u => 0)
    case N111Bin{name,typ,op,left,right}: nt_choose(U32,p113j_is_scratch(left) || p113j_is_scratch(right),u => 2048,u => 0)
    case N111Offset{name,base,bytes}: nt_choose(U32,p113j_is_scratch(base) || p113j_is_scratch(bytes),u => 2048,u => 0)
    case _: 0


@unsafe
def p113j_scratch_scalars(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: U32.max(p113j_scratch_scalar(head),p113j_scratch_scalars(rest))


@unsafe
def p113a_pair_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  +id = p111v_literal(p111v_arg(args,1))
  nt_choose(U32,p113p_array_call(symbol,args) &&
    (U32.is_eq(id,72) || U32.is_eq(id,74) || U32.is_eq(id,75)),u => id,u => 0)


@unsafe
def p113a_call_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{73,0}},
      Con{N111Arg{N111Ptr{},N111Local{+input}},
      Con{N111Arg{N111U32{},N111Const{3,0}},Nil{}}}}}:
        nt_choose(U32,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(input,"state")),u => 73,u => p113a_pair_id(symbol,args))
    case _: p113a_pair_id(symbol,args)


@unsafe
def p113a_rfc_fallback(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32, +heap_min: U32, +slow: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => [
      N111Bin{p113a_name(n,"rfc"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{132,0}},
      N111Bin{p113a_name(n,"rfc_ok"),N111U32{},"and",p113a_value(n,"rfc"),p113a_value(n,"dynamic")},
      N111If{p113a_value(n,"rfc_ok"),p113a_raw(id,destination,output,original,n),slow}],
    u => [
      N111Bin{p113a_name(n,"rfc"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{132,0}},
      N111Bin{p113a_name(n,"rfc_ok"),N111U32{},"and",p113a_value(n,"rfc"),p113a_value(n,"dynamic")},
      N111If{p113a_value(n,"rfc_ok"),[
        N111Bin{p113a_name(n,"rbytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
        N111Offset{p113a_name(n,"rptr"),N111Local{"p113a_heap_base"},p113a_value(n,"rbytes")},
        N111Load{p113a_name(n,"rcell"),N111U64{},p113a_value(n,"rptr"),0},
        N111Bin{p113a_name(n,"location"),N111U64{},"shr",p113a_value(n,"rcell"),N111Const{24,0}},
        N111Bin{p113a_name(n,"rdyn"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
        N111If{p113a_value(n,"rdyn"),p113a_raw(id,destination,output,original,n),slow}],slow}])


@unsafe
def p113a_function_names(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p113a_params(params) && p113a_body_names(body) && p113a_function_names(rest)


@unsafe
def p113a_namespace(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{original,functions}: p113a_function_names(functions)


@unsafe
def w5c2_bits_nz(z: Bool, +v: U32, +b: U32) -> U32:
  match z:
    case True{}: b
    case False{}: w5c2_bits16(U32.is_ge(v, 65536), v, b)

@unsafe
def p113k_bits(+value: U32, +bits: U32) -> U32:
  w5c2_bits_nz(U32.is_eq(value, 0), value, bits)

@unsafe
def w5c2_bs_5(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, N111U32{}, right}
    case False{}:
      w5c2_bs_6(
        (String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
        ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"shl") || String.eq(op,"shr")) && p113k_zero(rf)) ||
        (String.eq(op,"mul") && p113l_exact_one(rf)),
        name, typ, op, left, right, lf, rf)

@unsafe
def w5c2_bs_4(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, N111U32{}, left}
    case False{}:
      w5c2_bs_5(
        U32.is_eq(p111v_type(typ),1) && ((String.eq(op,"eq") && p113l_exact_one(lf)) || (String.eq(op,"ne") && p113k_zero(lf))) && U32.is_le(p113k_bits_of(rf),1),
        name, typ, op, left, right, lf, rf)

@unsafe
def p113e_base_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Bin{name,typ,op,left,right}: True{}
    case N111Call{name,N111U64{},symbol,args}:
      (p112t_runtime_call(symbol) || agy_str_eq(symbol,"p111_rt_fail")) && p113e_runtime_args(args)
    case N111If{condition,yes,no}: p113e_scalars(yes) && p113e_scalars(no)
    case N111Load{name,N111Ptr{},base,offset}: False{}
    case N111Load{name,typ,base,offset}: p113e_nonstate_pointer(base)
    case N111Store{N111Ptr{},base,offset,value}: False{}
    case N111Store{typ,base,offset,value}: p113e_nonstate_pointer(base)
    case N111Alloca{name,bytes,align}: True{}
    case _: False{}


@unsafe
def p114t_known_fid(+name: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      agy_str_eq(dk(index_find(functions,name,index_hash(name,2166136261),32)),"N111Id")

# Exact unsigned two's complement byte offset. Count zero must have high zero.


@unsafe
def p114t_function_names(functions: List<&2,P113DFunction>) -> Bool:
  p114ts_functions(functions,True{})

@unsafe
def p114t_segment_names(segments: List<&2,N111Segment>) -> Bool:
  p114ts_segments(segments,True{})

@unsafe
def p114ts_functions(functions: List<&2,P113DFunction>, valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p114ts_functions(rest,valid && p114t_params(params) && p114t_body_names(body))


@unsafe
def w5_arm_set_dst(body: List<&2,P113DStmt>) -> String:
  w5_loc_dst(w5_arm_loc(body))

@unsafe
def w5_arm_set_src(body: List<&2,P113DStmt>) -> String:
  w5_loc_src(w5_arm_loc(body))

@unsafe
def p118q_sized(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,4))
      nt_choose(N111Stmt,agy_str_eq(symbol,"p118_rt_extend") &&
        U32.is_eq(nt_count(N111Arg,args),5) && U32.is_ge(count,1) && U32.is_le(count,7),
        u => N111Call{name,N111U64{},"p118_rt_extend" ++ U32.show(count),p118xs_prefix(args)},
        u => p118xs_original(stmt))
    case _: p118xs_original(stmt)


@unsafe
def p118z_segments(segments: List<&2,N111Segment>) -> Bool:
  p118ns_segments(segments,True{})


@unsafe
def p118z_direct(body: List<&2,P113DStmt>) -> Bool:
  p118ns_direct(body,True{})


@unsafe
def p118xs_original(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+cid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,agy_str_eq(symbol,"p111_rt_ctor") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_ctor" ++ U32.show(count),[
          p111_state(),N111Arg{N111U32{},N111CtorId{cid}},N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,agy_str_eq(symbol,"p111_rt_take") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_take" ++ U32.show(count),[
          p111_state(),p111_word(term),N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case _: p125v_previous_sized(stmt)

@unsafe
def p118ns_segments(segments: List<&2,N111Segment>, +valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p118ns_segments(rest,valid && U32.is_eq(result,1) && U32.is_le(incoming,1) && p118z_scalars(body,False{}))


@unsafe
def p118ns_direct(body: List<&2,P113DStmt>, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p118ns_direct(rest,valid && p118z_scalar(stmt,True{}))
    case Con{P113DIf{condition,yes,no},rest}: p118ns_direct(rest,valid && p118z_direct(yes) && p118z_direct(no))
    case Con{stmt,rest}: p118ns_direct(rest,valid)


@unsafe
def p118ns_functions(functions: List<&2,P113DFunction>, +valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118ns_functions(rest,valid && p118z_direct(body))


@unsafe
def p118np_walk(todo: List<&2,List<&2,KDef>>, +found: Bool) -> Bool:
  match todo:
    case Nil{}: found
    case Con{Nil{},rest}: p118np_walk(rest,found)
    case Con{Con{+d,following},rest}:
      p118np_walk(Con{dc(d),Con{following,rest}},found || p118np_foreign(d))

@unsafe
def p124r_resume_found(+body: List<&2,N111Stmt>, +tail: List<&2,N111Stmt>, +owner: String,
    +name: String, +captures: U32, +target: String, callable: P124Callable) -> P114GBody:
  match callable:
    case P124Callable{valid,+count,+symbol}:
      nt_choose(P114GBody,valid && Bool.not(agy_str_eq(owner,target)) && p114r_arguments(tail,target,count),
        u => P114GBody{True{},[P114GFrame{name,captures}],[P114RResumeReady{
          p114r_prefix(body,U32.inc(captures)),p124r_call_nodes(tail,count,symbol),N111Local{"p114h_call_result"}}]},
        u => P114GBody{False{},[],[]})


@unsafe
def p125p_previous_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,p118t_import(symbol),u => p113e_runtime_args(args),u =>
        nt_choose(Bool,agy_str_eq(symbol,"p113_rt_array_pair"),v => p113p_array_call(symbol,args) && p113e_runtime_args(args),v => p113e_base_scalar_safe(stmt)))
    case _: p113e_base_scalar_safe(stmt)


@unsafe
def p126r_arguments(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  nt_choose(Bool,p112t_tail(body,owner,arity,0),u => True{},
    u => p126r_arguments_next(body,owner,arity))


@unsafe
def p126r_arguments_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{head,rest}: p126r_scalar(head) && p126r_arguments(rest,owner,arity)
    case _: False{}

@unsafe
def p126dp_original_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,agy_str_eq(symbol,"p125_rt_concat_typed"),u => p113e_runtime_args(args),u => p125p_previous_scalar_safe(stmt))
    case _: p125p_previous_scalar_safe(stmt)


@unsafe
def p128bs_project_guard(+name: String, +typ: N111Type, +args: List<&2,N111Arg>) -> P113DCode:
  +ok = p118b_arg_types(args,[3,2,2,1]) && p111v_state_argument(args) &&
    U32.is_eq(p111v_type(typ),2) &&
    U32.is_ge(p111v_literal(p111v_arg(args,3)),1) &&
    U32.is_le(p111v_literal(p111v_arg(args,3)),2)
  nt_choose(P113DCode,ok,
    u => P113DCode{[P113DScalar{N111Bin{name,N111U64{},"or",p111v_arg(args,1),p111v_arg(args,2)}}],0,"",[]},
    u => p113d_fail("scalar borrowed guard contract",0))

@unsafe
def p128br_held(+origin: KTerm, params: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{head,rest}:
      (no_root_index(roots,i) && noa_below(origin,kt("OArg","",i,0,[]))) ||
        p128br_held(origin,rest,roots,U32.inc(i))


@unsafe
def p128bl_recursive(+owner: KTerm, fields: List<&2,KTerm>, +count: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(count,1)
    case Con{+head,+rest}:
      nt_choose(Bool,agy_str_eq(nm(head),nm(owner)),
        u => norm_exact(head,owner) && U32.is_eq(count,0) && p128bl_recursive(owner,rest,1),
        u => p128bl_recursive(owner,rest,count))


@unsafe
def p128rf_member(+members: KDef, +name: String) -> Bool:
  agy_str_eq(dk(index_find(members,name,index_hash(name,2166136261),32)),"P128ReachMember")


@unsafe
def p128bi_rule(function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{+name,+params,+result,+public,body}:
      match body:
        case Con{P113DCall{Con{+out,Nil{}},+target,args},Con{P113DResult{Con{N111Local{reply},Nil{}}},Nil{}}}:
          +patterns = kt("P128BIPattern","",0,0,p128bi_patterns(args,params))
          +arity = nt_count(NC_Binding,params)
          nt_choose(KDef,public && U32.is_eq(result,1) && agy_str_eq(out,reply) &&
            U32.is_le(arity,4) && U32.is_le(terms_len(ks(patterns)),8) &&
            p128bi_all_patterns(ks(patterns)) && p128bi_once(patterns,arity,0),
            u => KDef{name,"P128BIRule",arity,1,ref(target),patterns,[],False{},False{}},u => missing())
        case _: missing()


@unsafe
def p128bf_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      agy_str_eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count)


@unsafe
def p137qi_returns(body: List<&2,P113DStmt>, +width: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DIf{condition,yes,no},Nil{}}: p137qi_returns(yes,width) && p137qi_returns(no,width)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_returns(rest,width)
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_returns(rest,width)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_returns(rest,width)
    case _: False{}

@unsafe
def p142j_member(seen: KDef, name: String, hash: U32) -> Bool:
  p88_string_eq(dk(index_find(seen,name,hash,32)),"P142JSeen")


@unsafe
def w7c_decl_def(isForeign: Bool, +d: KDef) -> KDef:
  match isForeign:
    case True{}: d
    case False{}: declared(d)

@unsafe
def w7_br_979(w7_c: Bool, +name: String, +found: KDef) -> KDef:
  match w7_c:
    case True{}:
      found
    case False{}:
      f_find(name,[])

@unsafe
def p144p_found(+name: String, +found: KDef) -> KDef:
  w7_br_979(p88_string_eq(dn(found),name), name, found)


@unsafe
def p164a_generic(segments: List<&2,N111Segment>, +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segments:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+head,rest}:
      p164a_generic(rest,nt_choose(List<&2,N111Segment>,p164a_shape(head),u => acc,u => Con{head,acc}))


# Experimental semantic result. Only the separate independent final verifier
# grants emission permission; this lowering record is not a certificate.
law w6_canon_stmts:
  for body: List<&2,N111Stmt>
  for +st: W6CState
  W6CState

@unsafe
def w6_canon_stmt_go(stmt: N111Stmt, +locals: List<&2,W6Local>, +st: W6CState) -> W6CState:
  match stmt:
    case N111Alloca{+name,+bytes,+align}:
      w6_push(w6_def_local(w6_push(st,"A("),name),"," ++ U32.show(bytes) ++ "," ++ U32.show(align) ++ ");")
    case N111Set{+name,typ,val}:
      +vs = w6_canon_val(locals,val)
      w6_push(w6_def_local(w6_push(st,"S("),name),"," ++ w6_type_tag(typ) ++ "," ++ vs ++ ");")
    case N111Bin{+name,typ,+op,left,right}:
      +ls = w6_canon_val(locals,left)
      +rs = w6_canon_val(locals,right)
      w6_push(w6_def_local(w6_push(st,"B("),name),"," ++ w6_type_tag(typ) ++ "," ++ op ++ "," ++ ls ++ "," ++ rs ++ ");")
    case N111Call{+name,typ,+symbol,args}:
      +st1 = w6_canon_args(args,w6_push(w6_def_local(w6_push(st,"C("),name),"," ++ w6_type_tag(typ) ++ "," ++ symbol))
      w6_push(st1,");")
    case N111If{cond,yes,no}:
      +cs = w6_canon_val(locals,cond)
      +st1 = w6_canon_stmts(yes,w6_push(st,"I(" ++ cs ++ ",["))
      +st2 = w6_canon_stmts(no,w6_push(st1,"],["))
      w6_push(st2,"]);")
    case N111Return{val}:
      w6_push(st,"R(" ++ w6_canon_val(locals,val) ++ ");")
    case N111Load{+name,typ,base,+offset}:
      +bs = w6_canon_val(locals,base)
      w6_push(w6_def_local(w6_push(st,"L("),name),"," ++ w6_type_tag(typ) ++ "," ++ bs ++ "," ++ U32.show(offset) ++ ");")
    case N111Store{typ,base,+offset,val}:
      w6_push(st,"W(" ++ w6_type_tag(typ) ++ "," ++ w6_canon_val(locals,base) ++ "," ++ U32.show(offset) ++ "," ++ w6_canon_val(locals,val) ++ ");")
    case N111Offset{+name,base,bytes}:
      +bs = w6_canon_val(locals,base)
      +ys = w6_canon_val(locals,bytes)
      w6_push(w6_def_local(w6_push(st,"O("),name),"," ++ bs ++ "," ++ ys ++ ");")

@unsafe
def w6_canon_stmt(stmt: N111Stmt, +st: W6CState) -> W6CState:
  w6_canon_stmt_go(stmt,w6_st_locals(st),st)

@unsafe
def w6_canon_stmts(body, st):
  match body:
    case Nil{}: st
    case Con{+head,+rest}:
      nt_choose(W6CState,U32.is_eq(w6_st_fuel(st),0),
        u => st,
        u => w6_canon_stmts(rest,w6_canon_stmt(head,w6_dec_fuel(st))))

@unsafe
def w6_canon_seg(+arity: U32, +result: U32, +incoming: U32, +flags: U32, body: List<&2,N111Stmt>) -> String:
  +hdr = U32.show(arity) ++ "|" ++ U32.show(result) ++ "|" ++ U32.show(incoming) ++ "|" ++ U32.show(flags) ++ "|"
  w6_canon_finish(w6_canon_stmts(body,W6CState{[],0,[hdr],33}))

@unsafe
def w4p_unpack_join_shape(+ctor: String, +word: String, +w: U32, +fresh: U32, sub: W4PUnpack) -> W4PUnpack:
  match sub:
    case W4PUnpack{stmts,args,ok}:
      W4PUnpack{nt_append(N111Stmt,p111_take(ctor,N111Local{word},w,fresh),stmts),
        nt_append(N111Value,w4p_field_locals(w,0,fresh),args),ok}

@unsafe
def w4p_try_wrap_unpacked(+fn: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +prodName: String, +rshape: KTerm, +rw: U32, unpacked: W4PUnpack) -> P113DFunction:
  match unpacked:
    case W4PUnpack{+pre,+flatArgs,+ok}:
      nt_choose(P113DFunction,ok,
        z =>
          +retNames = p113pl_names("w4p_ret",rw,0)
          nt_choose(P113DFunction,agy_str_eq(tg(rshape),"NQShape"),
            r => w4p_finish_box(fn,name,params,pre,prodName,flatArgs,retNames,
              p111_constructor(nm(rshape),p113pl_locals(retNames))),
            r => P113DFunction{name,params,1,True{},
              nt_append(P113DStmt,p113d_scalars(pre),
                [P113DCall{retNames,prodName,flatArgs},P113DResult{[N111Local{"w4p_ret_0"}]}])}),
        z => fn)

law p177dr_taken:
  for +name: String
  for +scope: FParseScope
  for +local: KDef
  Bool

@unsafe
def p177dr_taken(name,scope,local):
  match scope:
    case FParseScope{prior,index,ctorIndex,ns,aliases,view}:
      Bool.not(f_eq(dk(local),"Missing")) ||
        Bool.not(f_eq(dk(index_find(index,name,index_hash(name,2166136261),32)),"Absent")) ||
        Bool.not(f_eq(dk(index_find(index,f_qual_name(name,ns),index_hash(f_qual_name(name,ns),2166136261),32)),"Absent"))

@unsafe
def p185cc_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      +meta = dt(entry)
      agy_str_eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count) &&
        agy_str_eq(tg(meta),"P185Constructor") && U32.is_eq(qt(meta),11102) && U32.is_eq(ix(meta),0)

@unsafe
def p185cb_known(+ctor: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      p185cb_marker(dv(index_find(constructors,ctor,index_hash(ctor,2166136261),32)))

@unsafe
def p186rt_fid(+name: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(functions,name,index_hash(name,2166136261),32)
      agy_str_eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65532)

# Snapshot every word before the first destination store, retaining memmove
# semantics even in isolated template controls with overlapping source/state.
def x188_instruction_text(instruction: X187Instruction) -> String:
  match instruction:
    case X187Instruction{op,operands}: "  " ++ op ++ x188_operands_text(operands," ") ++ "\n"

def x188_item_text(item: X187Parsed) -> String:
  match item:
    case PInst{instruction}: x188_instruction_text(instruction)
    case PLabel{name}: name ++ ":\n"
    case PSection{section}:
      match section:
        case 1: ".text\n"
        case 2: ".section .rodata\n"
        case 3: ".data\n"
        case 4: ".section .note.GNU-stack,\"\",@progbits\n"
        case _: ".error \"invalid machine section\"\n"
    case PGlobal{name}: ".globl " ++ name ++ "\n"
    case PType{name,kind}: ".type " ++ name ++ nt_choose(String,U32.is_eq(kind,2),u => ", @function\n",u => ", @object\n")
    case PSize{+name}: ".size " ++ name ++ ", .-" ++ name ++ "\n"
    case PAlign{alignment}: ".balign " ++ U32.show(alignment) ++ "\n"
    case PBytes{bytes}: x188_bytes_text(bytes)
    case PDataReloc{symbol,lo,hi}: ".quad " ++ symbol ++ "+" ++ p111q_u64(lo,hi) ++ "\n"
    case PDatum{datum}: x188_datum_text(datum)
    case PEmpty{}: ""
    case PError{error}: ".error \"" ++ error ++ "\"\n"

law x181_store:
  for +name: String
  for +frame: X181Frame
  for +reg: X187Operand
  X188Seq
@unsafe
def x192_float_conversion_core(id: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,58),u => x192_float_to_u32_core(),u => x192_u32_to_float_core())

@unsafe
def x192_float_cvtt(+src: X187Operand, +dst: X187Operand, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,64,False{}) && x187_e_rm(src,128,True{}),
    u => x187_e_modrm(243,[15,44],True{},x187_e_index(dst),src,False{},[],offset),
    u => x187_e_error())

@unsafe
def agy_rfc_unique_free(+cls: U32, +atOff: U32, +lenOff: U32, +words: U32, +count: U32, +slow: String) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(cls,0),
    u => x188_many([
      x188_i2("movq",X187Mem{8,256},x188_reg(11,64)),
      x188_i2("addq",X187Imm{2,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      agy_copy_words(10,2,11,count,0),
      x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
      x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
      x188_i2("movq",x188_reg(0,64),X187Mem{8,0}),
      x188_i2("addq",X187Imm{2,0},X187Mem{8,256})]),
    u => x188_many([
      x188_i2("movq",X187Mem{8,256},x188_reg(11,64)),
      x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      x188_i2("movq",X187Mem{8,lenOff},x188_reg(11,64)),
      x188_i2("addq",X187Imm{words,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      agy_copy_words(10,2,11,count,0),
      x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
      x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
      x188_i2("addq",X187Imm{1,0},X187Mem{8,256}),
      x188_i2("movq",X187Mem{8,atOff},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
      x188_i2("movq",x188_reg(0,64),X187Mem{8,atOff}),
      x188_i2("addq",X187Imm{words,0},X187Mem{8,lenOff})]))

@unsafe
def x181_local_load(+name: String, frame: X181Frame, reg: X187Operand) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x181_load_slot(index_find(slots,name,index_hash(name,2166136261),32),reg)

@unsafe
def x188_id_load(tree: KDef, +name: String, reg: X187Operand) -> X188Seq:
  x188_id_found(index_find(tree,name,index_hash(name,2166136261),32),reg)

@unsafe
def x181_store(name,frame,reg):
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x181_store_slot(index_find(slots,name,index_hash(name,2166136261),32),reg)

@unsafe
def x185_id_to_const(+value: N111Value, ids: N111Ids) -> N111Value:
  match value ids:
    case N111CtorId{+name} N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(N111Value,agy_str_eq(dk(found),"N111Id"),u => N111Const{da(found),0},u => value)
    case N111FuncId{+name} N111Ids{functions,constructors}:
      +found = index_find(functions,name,index_hash(name,2166136261),32)
      nt_choose(N111Value,agy_str_eq(dk(found),"N111Id"),u => N111Const{da(found),0},u => value)
    case _ _: value

@unsafe
def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_width_reg(typ,10)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      +mulOpt = nt_choose(X188Seq,agy_str_eq(op,"mul"),m => w4_mul_imm(typ,lo,hi,left,x188_reg(10,32)),m => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(mulOpt)),m => mulOpt,m =>
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,x188_reg(10,8)),
            x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}

@unsafe
def x185_physical_instruction(+typ: N111Type, op: String,
    wide: X187Operand, narrow: X187Operand, byte: X187Operand) -> X188Seq:
  x190_operand_instruction(typ,op,wide,narrow,byte,x188_width_reg(typ,11))

@unsafe
def x185_physical_immediate(+typ: N111Type, +op: String, value: N111Value,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_physical_width(typ,wide,narrow)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      +mulOpt = nt_choose(X188Seq,agy_str_eq(op,"mul"),m => w4_mul_imm(typ,lo,hi,left,narrow),m => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(mulOpt)),m => mulOpt,m =>
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,agy_str_eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{}))))
    case _: X188Empty{}

@unsafe
def x194_cr_select(+typ: N111Type, +op: String, +wide: X187Operand,
    +narrow: X187Operand, +byte: X187Operand, right: X185Physical, left: X185Physical) -> X188Seq:
  match right left:
    case X185Physical{rw,rn,rb} X185Physical{lw,ln,lb}:
      nt_choose(X188Seq,x194_cr_enabled() && x190_branch_width(typ) && x194_cr_op(op) &&
          x188_operand_same(rw,wide),
        u => x190_operand_instruction(typ,op,wide,narrow,byte,x188_physical_width(typ,lw,ln)),
        u => X188Empty{})
    case _ _: X188Empty{}

@unsafe
def x198w_found(+dest: String,+buf: String,+id: U32,+facts: List<&2,X185ScratchCell>,found: Maybe<&2,N111Value>) -> Maybe<&2,N111Stmt>:
  match found:
    case Some{+x}:
      nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,24),u => Some{N111Set{dest,N111U64{},x}},u =>
        nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,25),v => Some{N111Bin{dest,N111U64{},"and",x,N111Const{4294967295,0}}},v =>
          nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,67),w =>
            x198w_lt(dest,x,x185_sf_find(facts,buf,8,N111U64{})),w => None{})))
    case _: None{}

@unsafe
def x198w_known(op: X198WOp,+facts: List<&2,X185ScratchCell>) -> Maybe<&2,N111Stmt>:
  match op:
    case X198WOp{dest,+buf,id}: x198w_found(dest,buf,id,facts,x185_sf_find(facts,buf,0,N111U64{}))
    case _: None{}

@unsafe
def x186_p_pick(todo: List<&2,X186Move>, +all: List<&2,X186Move>) -> X186Pick:
  match todo:
    case Nil{}: X186PickNone{}
    case Con{+move,+rest}:
      match move:
        case X186Move{destination,source,home,read}:
          nt_choose(X186Pick,Bool.not(x186_p_read(home,all)),
            u => X186Pick{move,rest},u => x186_p_pick_cons(move,x186_p_pick(rest,all)))

@unsafe
def w5b_e_written_hit(hit: Bool, +state: X186ExprState, facts: List<&2,X186Expr>, aliases: List<&2,X186Alias>,
    +fc: U32, +ac: U32, mentioned: KDef, ft: X186FactTrie, at: X186AliasTrie, +name: String) -> X186ExprState:
  match hit:
    case False{}: state
    case True{}:
      +nf = x186_e_kill_facts(facts,name)
      +na = x186_e_kill_aliases(aliases,name)
      +nfc = nt_count(X186Expr,nf)
      +nac = nt_count(X186Alias,na)
      X186ExprState{nf,na,nfc,nac,mentioned,
        w5b_ft_prune_if(U32.is_eq(nfc,fc),ft,name),
        w5b_at_prune_if(U32.is_eq(nac,ac),at,name)}

@unsafe
def w5b_e_written_nonempty(empty: Bool, +state: X186ExprState, facts: List<&2,X186Expr>, aliases: List<&2,X186Alias>,
    +fc: U32, +ac: U32, +mentioned: KDef, ft: X186FactTrie, at: X186AliasTrie, +name: String) -> X186ExprState:
  match empty:
    case True{}: state
    case False{}:
      w5b_e_written_hit(
        String.eq(dk(index_find(mentioned,name,index_hash(name,2166136261),32)),"X186M"),
        state,facts,aliases,fc,ac,mentioned,ft,at,name)

@unsafe
def w5_as_sel_yes(+cond: N111Value, ya: W4CSelArm, no: List<&2,P113DStmt>) -> W5Sel:
  match ya:
    case W4CSelArm{a,ta,va}: w5_as_sel_no(cond,a,ta,va,w4c_sel_arm(no))
    case W4CSelArmNone{}: W5SelNone{}

@unsafe
def w5_as_sel(+cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> W5Sel:
  w5_as_sel_yes(cond,w4c_sel_arm(yes),no)

law w5_nc_collect:
  for +body: List<&2,P113DStmt>
  for +curX: String
  for +k: U32
  for +dst: String
  for +typW: U32
  for +origX: String
  for +cName: String
  for +acc: List<&2,W5NatArm>
  for +fuel: U32
  W5NatChain

@unsafe
def w5_nc_try_step(arm: W4CSelArm, +nextX: String, +no: List<&2,P113DStmt>, +k: U32,
    +dst: String, +typW: U32, +origX: String, +cName: String, +acc: List<&2,W5NatArm>, +fuel: U32) -> W5NatChain:
  match arm:
    case W4CSelArm{+adst,+atyp,+aval}:
      nt_choose(W5NatChain,
        agy_str_eq(adst,dst) && U32.is_eq(p111v_type(atyp),typW) &&
        w5_nc_val_ok(aval,dst,origX,cName) && Bool.not(w5_val_eq_name(aval,nextX)),
        u => w5_nc_collect(no,nextX,U32.inc(k),dst,typW,origX,cName,Con{W5NatArm{k,aval},acc},U32.sub(fuel,1)),
        u => W5NatChainNone{})
    case W4CSelArmNone{}: W5NatChainNone{}

@unsafe
def w5_nc_collect_step(body: List<&2,P113DStmt>, +curX: String, +k: U32, +dst: String, +typW: U32,
    +origX: String, +cName: String, +acc: List<&2,W5NatArm>, +fuel: U32) -> W5NatChain:
  match body:
    case Con{P113DScalar{N111Bin{+nextX,_,subOp,subL,subR}},
         Con{P113DScalar{N111Bin{+c2,_,eqOp,eqL,eqR}},
         Con{P113DIf{cond2,+yes2,+no2},Nil{}}}}:
      nt_choose(W5NatChain,
        agy_str_eq(w5_is_sub1_local(subOp,subL,subR),curX) &&
        agy_str_eq(w5_is_cmp0_local(eqOp,"eq",eqL,eqR),nextX) &&
        w5_val_eq_name(cond2,c2) &&
        Bool.not(agy_str_eq(nextX,dst)) && Bool.not(agy_str_eq(nextX,origX)) &&
        Bool.not(agy_str_eq(c2,dst)) && Bool.not(agy_str_eq(c2,origX)),
        v => w5_nc_try_step(w4c_sel_arm(yes2),nextX,no2,k,dst,typW,origX,cName,acc,fuel),
        v => W5NatChainNone{})
    case _: w5_nc_def_arm(w4c_sel_arm(body),dst,typW,origX,cName,acc)

@unsafe
def w5_nc_collect(body,curX,k,dst,typW,origX,cName,acc,fuel):
  nt_choose(W5NatChain,U32.is_eq(fuel,0),u => W5NatChainNone{},
    u => w5_nc_collect_step(body,curX,k,dst,typW,origX,cName,acc,fuel))

@unsafe
def w5_nc_start(arm0: W4CSelArm, +origX: String, +cName: String, +cTyp: N111Type,
    +no: List<&2,P113DStmt>, +tail: List<&2,P113DStmt>, +fallback: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match arm0:
    case W4CSelArm{+dst,+dstTyp,+val0}:
      +tw = p111v_type(dstTyp)
      nt_choose(List<&2,P113DStmt>,
        Bool.not(x181_register_reserved(dst)) && w4c_sel_width(dstTyp) &&
        Bool.not(agy_str_eq(dst,origX)) && Bool.not(agy_str_eq(dst,cName)) &&
        w5_nc_val_ok(val0,dst,origX,cName),
        u => w5_nc_finish(w5_nc_collect(no,origX,1,dst,tw,origX,cName,[W5NatArm{0,val0}],8),
          origX,cName,cTyp,dst,dstTyp,tail,fallback),
        u => fallback)
    case W4CSelArmNone{}: fallback

@unsafe
def w5b_in_sets(+x: String, +typ: N111Type, +v: N111Value, sets: List<&2,P113DStmt>) -> Bool:
  match sets:
    case Nil{}: False{}
    case Con{P113DScalar{N111Set{n,nt,nv}},t}:
      nt_choose(Bool,agy_str_eq(n,x) && w5b_typ_eq(nt,typ) && w5b_val_eq(nv,v),
        u => True{},u => w5b_in_sets(x,typ,v,t))
    case Con{_,t}: w5b_in_sets(x,typ,v,t)

@unsafe
def w5b_has_common_set(ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>) -> Bool:
  match ySets:
    case Nil{}: False{}
    case Con{P113DScalar{N111Set{x,typ,v}},t}:
      nt_choose(Bool,w5b_in_sets(x,typ,v,nSets),u => True{},u => w5b_has_common_set(t,nSets))
    case Con{_,t}: w5b_has_common_set(t,nSets)

@unsafe
def x186_f_operation(stmt: N111Stmt, +facts: List<&2,X185ScratchCell>, operation: X186InlineOp) -> X186FloatNode:
  match operation:
    case X186InlineF32{destination,+id,+buffer}:
      x186_f_values(stmt,destination,id,x185_sf_find(facts,buffer,0,N111U64{}),
        x185_sf_find(facts,buffer,nt_choose(U32,x200r_float_unary(id),u => 0,u => 8),N111U64{}))
    case X186InlineNone{}: X186FloatPlain{P113DScalar{stmt}}
law w2_dstmts_reads:
  for +name: String
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w2_dstmt_reads(+name: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: w2_scalar_reads(name,s)
    case P113DIf{c,yes,no}: w2_val_reads(name,c) || w2_dstmts_reads(name,yes) || w2_dstmts_reads(name,no)
    case P113DCall{names,target,args}: w2_vals_reads(name,args)
    case P113DResult{vals}: w2_vals_reads(name,vals)
    case P113DAgain{vals}: w2_vals_reads(name,vals)

@unsafe
def w2_dstmts_reads(name,body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: w2_dstmt_reads(name,head) || w2_dstmts_reads(name,rest)

law w2_dead_in:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  for +tail: List<&2,List<&2,X186FloatNode>>
  for +fuel: U32
  Bool

@unsafe
def w2_dead_tail(+name: String, tail: List<&2,List<&2,X186FloatNode>>, +fuel: U32) -> Bool:
  match tail:
    case Nil{}: True{}
    case Con{head,rest}: w2_dead_in(name,head,rest,fuel)

@unsafe
def w2_dead_in_step(+name: String, nodes: List<&2,X186FloatNode>, +tail: List<&2,List<&2,X186FloatNode>>, +fuel: U32) -> Bool:
  match nodes:
    case Nil{}: w2_dead_tail(name,tail,U32.sub(fuel,1))
    case Con{X186FloatValues{dest,id,left,right},rest}:
      nt_choose(Bool,w2_val_reads(name,left) || w2_val_reads(name,right),v => False{},
        v => nt_choose(Bool,agy_str_eq(dest,name),w => True{},
          w => w2_dead_in(name,rest,tail,U32.sub(fuel,1))))
    case Con{X186FloatBranch{cond,yes,no},+rest}:
      nt_choose(Bool,w2_val_reads(name,cond),v => False{},
        v => w2_dead_in(name,yes,Con{rest,tail},U32.sub(fuel,1)) &&
             w2_dead_in(name,no,Con{rest,tail},U32.sub(fuel,1)))
    case Con{X186FloatPlain{+stmt},rest}:
      nt_choose(Bool,w2_dstmt_reads(name,stmt),v => False{},
        v => nt_choose(Bool,w2_dstmt_terminal(stmt) || w2_dstmt_writes(name,stmt),w => True{},
          w => w2_dead_in(name,rest,tail,U32.sub(fuel,1))))

@unsafe
def w2_dead_in(name,nodes,tail,fuel):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u => w2_dead_in_step(name,nodes,tail,fuel))

@unsafe
def w2b_bool_cid_imm(ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,"True",index_hash("True",2166136261),32)
      nt_choose(U32,agy_str_eq(dk(found),"N111Id"),u => U32.or(da(found),65536),u => 0)

law w2_xl_only_float:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_only_float(name,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,+id,l,r},rest}:
      (Bool.not(U32.is_eq(id,23)) || Bool.not(w2_val_reads(name,l))) && w2_xl_only_float(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      Bool.not(w2_val_reads(name,c)) && w2_xl_only_float(name,y) && w2_xl_only_float(name,n) && w2_xl_only_float(name,rest)
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w2_xl_only_float(name,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_reads(name,stmt)) && w2_xl_only_float(name,rest)

@unsafe
def x190_l_event(reads: U32, +writes: U32, flow: X190LFlow, env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{+after,+graph} X190LEnv{ids,parameters,header,+collect}:
      +before = U32.or(reads,U32.and(after,U32.not(writes)))
      X190LFlow{before,nt_choose(List<&2,U32>,collect,
        u => x190_l_edges(graph,1,before,after,writes),u => graph)}

# A real call is a fixed-register clobber. Self edges mark values live across
# it as unallocatable. Arguments are snapshotted by x186_call_arguments when
# any source is transient; multi-results are modelled as simultaneous writes.
@unsafe
def x190_l_call(reads: U32, +writes: U32, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{+live,+graph} X190LEnv{ids,parameters,header,collect}:
      x190_l_event(reads,writes,X190LFlow{live,nt_choose(List<&2,U32>,collect,
        u => x190_l_block(graph,U32.and(live,U32.not(writes)),1),u => graph)},env)

@unsafe
def x190_l_joined(reads: U32, yes: U32, env: X190LEnv, no: X190LFlow) -> X190LFlow:
  match no:
    case X190LFlow{live,graph}: x190_l_event(U32.or(reads,yes),0,X190LFlow{live,graph},env)

@unsafe
def x190_l_terminal(reads: U32, flow: X190LFlow, env: X190LEnv) -> X190LFlow:
  match flow:
    case X190LFlow{live,graph}: x190_l_event(reads,0,X190LFlow{0,graph},env)

@unsafe
def x203_rank(names: List<&2,String>, +counts: KDef, +slots: KDef,
    +ranked: List<&2,X181RegisterChoice>) -> List<&2,X181RegisterChoice>:
  match names:
    case Nil{}: ranked
    case Con{+name,rest}:
      +hash = index_hash(name,2166136261)
      +score = da(index_find(counts,name,hash,32))
      x203_rank(rest,counts,slots,nt_choose(List<&2,X181RegisterChoice>,U32.is_gt(score,0),
        u => nt_choose(List<&2,X181RegisterChoice>,agy_str_eq(dk(index_find(slots,name,hash,32)),"X181Stack"),
          v => x203_insert(ranked,name,score,32),v => ranked),u => ranked))

@unsafe
def x190_branch_immediate_to(+typ: N111Type, value: N111Value, +ids: N111Ids, destination: X187Operand) -> X188Seq:
  match value ids:
    case N111Const{+lo,hi} _:
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),
        u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{lo,0},destination),
        u => X188Empty{})
    case N111CtorId{+name} N111Ids{functions,constructors}:
      x190_branch_id_imm(typ,index_find(constructors,name,index_hash(name,2166136261),32),destination)
    case N111FuncId{+name} N111Ids{functions,constructors}:
      x190_branch_id_imm(typ,index_find(functions,name,index_hash(name,2166136261),32),destination)
    case _ _: X188Empty{}

@unsafe
def x198qm_calculate(+srcOp: X187Operand, +d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:
  match plan:
    case P198Shift{shift}:
      x188_many([x188_i2("movl",srcOp,x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("andl",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),
          u => x188_i2("shrl",X187Imm{shift,0},x188_reg(0,32)))])
    case P198Magic{m,s}:
      x188_many([x188_i2("movl",srcOp,x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("movl",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),
        x188_i2("movl",X187Imm{m,0},x188_reg(11,32)),x188_i2("imulq",x188_reg(11,64),x188_reg(0,64)),
        x188_i2("shrq",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,
          u => x188_many([w4_qm_mul_d(d),
            x188_i2("subl",x188_reg(0,32),x188_reg(10,32)),x188_i2("movl",x188_reg(10,32),x188_reg(0,32))]),
          u => X188Empty{})])
    case P198NoQuot{}: X188Empty{}

@unsafe
def w4_qm_finish(div: W4QMDividend, +d: U32, +id: U32, +plan: P198Quot) -> List<&2,X188Seq>:
  match div:
    case W4QMDividend{srcOp,rest2}: Con{x198qm_calculate(srcOp,d,U32.is_eq(id,19),plan),rest2}

@unsafe
def w4_leaf_shrink(items: List<&2,X187Parsed>, original: X188Seq) -> X188Seq:
  w4_leaf_shrink_pro(w4_leaf_parse_prologue(items,[]),original)

# W4-7 Pass 2: General copy-forwarding & flag-reuse peephole.
law w4b_copy_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

law w5c_copy_peep_t:
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +out: List<&2,X188Seq>
  for +changed: Bool
  W5BPeepOut

@unsafe
def w5c_cp_jcc_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{i3,tail},lbls,Con{X188One{i1},Con{X188One{i0},out}},True{})
    case False{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_jcc_t(br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match br:
    case W4BBranch{jop,_}: w5c_cp_jcc_if(w4_peep_is_jz_jnz(jop),i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BBranchNone{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf4_if(ok: Bool, +a: U32, +b: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{"subl",[X187Reg{a,32,False{}},X187Reg{b,32,False{}}]}},tail},lbls,out,True{})
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold4_t(r4: W4BRR, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r4:
    case W4BRR{op4,s4,ws4,d4,wd4}:
      +ok = String.eq(op4,"movq") && U32.is_eq(s4,a) && U32.is_eq(ws4,64) && U32.is_eq(d4,b) && U32.is_eq(wd4,64) &&
            Bool.not(U32.is_eq(a,b) || U32.is_eq(t,a) || U32.is_eq(t,b) || U32.is_eq(t,11) || U32.is_eq(a,11) || U32.is_eq(b,11)) &&
            w5c_reg_dead_t(t,tail,lbls,36) && w5c_reg_dead_t(a,tail,lbls,36) && w5c_reg_dead_t(11,tail,lbls,36)
      w5c_sf4_if(ok,a,b,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf3_if(ok: Bool, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold4_t(w4b_as_rr(i4),b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold3_t(r3: W4BRR, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r3:
    case W4BRR{op3,s3,ws3,d3,wd3}:
      w5c_sf3_if(String.eq(op3,"subl") && U32.is_eq(s3,11) && U32.is_eq(ws3,32) && U32.is_eq(d3,a) && U32.is_eq(wd3,32),
        i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf2_if(ok: Bool, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold3_t(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold2_t(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      w5c_sf2_if(String.eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold_t(+b: U32, +t: U32, +a: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{i2,Con{i3,Con{i4,tail}}}:
      w5c_sub_fold2_t(w4b_as_rr(i2),i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_chk_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_check_jcc_t(w4b_as_branch(i3),i0,i1,i2,i3,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_test_t(tr: W4BRR, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match tr:
    case W4BRR{top,s,ws,d,wd}:
      w5c_cp_chk_if(String.eq(top,"testq") && U32.is_eq(s,c) && U32.is_eq(d,c) && U32.is_eq(ws,64) && U32.is_eq(wd,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_cmp_t(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      w5c_cp_chk_if(String.eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) && U32.is_eq(cr,c) && U32.is_eq(cw,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BImmRegNone{}: w5c_copy_check_test_t(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)

@unsafe
def w5c_copy_after_sub_t(+c: U32, +rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{+i2,Con{+i3,+tail}}: w5c_copy_check_cmp_t(w4b_as_imm_reg(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_r6(ok: Bool, +s: U32, +t: U32, +t2: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold_t(s,t,t2,i0,i1,rest,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_r5(ok: Bool, +isMov32: Bool, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(rest,lbls,Con{X188One{i0},out},True{})
    case False{}:
      w5c_cp_r6(isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) && U32.is_eq(d,11),
        s,t,t2,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r4(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_after_sub_t(d,rest,i0,i1,lbls,out,chg)
    case False{}:
      w5c_cp_r5(String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
          U32.is_eq(t,t2) && U32.is_eq(t,d) && (isMov32 || w4b_is_alu32_rr(op0)),
        isMov32,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r3(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{op0,[X187Reg{t,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      w5c_cp_r4(String.eq(op0,"subl") && String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
        isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r2(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok3 = U32.is_eq(ws,32) && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && U32.is_eq(s,d) && Bool.not(U32.is_eq(t,d)) &&
             (String.eq(op0,"addl") || String.eq(op0,"imull") || String.eq(op0,"andl") || String.eq(op0,"orl") || String.eq(op0,"xorl")) &&
             w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r3(ok3,isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r1(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok2 = isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r2(ok2,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_copy_pair_t(+op0: String, +s: U32, +ws: U32, +t: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match i1:
    case PInst{X187Instruction{+op1,Con{X187Reg{+t2,+wt2,False{}},Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      +isMov32 = String.eq(op0,"movl") && U32.is_eq(ws,32)
      +ok1 = isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r1(ok1,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_i0(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +changed: Bool) -> W5BPeepOut:
  match i0:
    case PInst{X187Instruction{+op0,Con{X187Reg{+s,+ws,False{}},Con{X187Reg{+t,32,False{}},Nil{}}}}}:
      w5c_copy_pair_t(op0,s,ws,t,i0,i1,rest,lbls,out,changed)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},changed)

@unsafe
def w5c_copy_peep_t(items,lbls,out,changed):
  match items:
    case Nil{}: W5BPeepOut{changed,out}
    case Con{+i0,Con{+i1,+rest}}: w5c_copy_i0(i0,i1,rest,lbls,out,changed)
    case Con{h,rest}: w5c_copy_peep_t(rest,lbls,Con{X188One{h},out},changed)

@unsafe
def w4b_copy_peep(items,fnItems,out):
  w5c_peep_seq(w5c_copy_peep_t(items,w5c_lbl_build(fnItems),out,False{}))

# W4-7 Pass 3: General loop-invariant magic-constant hoisting (LICM) in call-free loops.
@unsafe
def w4b_rotate_check_hdr(cm: W4BImmReg, br: W4BBranch, +i0: X187Parsed, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cm:
    case W4BImmReg{cmpop,lo,hi,r,w}: w4c_rotate_check_cmp(cmpop,lo,hi,r,w,br,before,loopLbl,afterHdr,orig)
    case W4BImmRegNone{}: w4c_rotate_check_test(w4b_as_rr(i0),br,before,loopLbl,afterHdr,orig)

@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{+i0,Con{i1,afterHdr}}:
      w4b_rotate_check_hdr(w4b_as_imm_reg(i0),w4b_as_branch(i1),i0,before,loopLbl,afterHdr,orig)
    case _: orig

@unsafe
def w4c_add_args_reads(args: List<&2,X187Operand>, +m: W4CMap) -> W4CMap:
  match args:
    case Nil{}: m
    case Con{a,rest}: w4c_add_args_reads(rest,w4c_add_op_read(a,m))

@unsafe
def w4c_inst_reads(item: X187Parsed, +m: W4CMap) -> W4CMap:
  match item:
    case PInst{X187Instruction{+op,+args}}:
      match args:
        case Con{+src,Con{X187Mem{+b,+d},Nil{}}}:
          nt_choose(W4CMap,w4c_is_write_only_mem(op),
            u => w4c_add_op_read(src,m),
            u => w4c_add_op_read(X187Mem{b,d},w4c_add_op_read(src,m)))
        case _: w4c_add_args_reads(args,m)
    case _: m

@unsafe
def w4c_count_writes(items: List<&2,X187Parsed>, +m: W4CMap) -> W4CMap:
  match items:
    case Nil{}: m
    case Con{h,rest}: w4c_count_writes(rest,w4c_inst_writes(h,m))

# Check if xmm1 is dead before next write/branch/call (conservative, 1-scrutinee).
law w4c_xmm_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# Forward %xmm1 for subsequent <fop> disp(%rbp), %xmmB until %xmm1 or disp(%rbp) is written or ctrl/label.
law w4c_fwd_xmm1:
  for +disp: U32
  for +items: List<&2,X187Parsed>
  for +fuel: U32
  List<&2,X187Parsed>

@unsafe
def w4c_fwd_xmm1_apply(+disp: U32, +h: X187Parsed, r: Maybe<&2,X187Instruction>, +rest: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match r:
    case Some{ni}: Con{PInst{ni},w4c_fwd_xmm1(disp,rest,U32.sub(fuel,1))}
    case None{}: Con{h,w4c_fwd_xmm1(disp,rest,U32.sub(fuel,1))}

@unsafe
def w4c_fwd_xmm1_step(+disp: U32, +h: X187Parsed, +inst: X187Instruction, +rest: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match inst:
    case X187Instruction{+op,_}:
      nt_choose(List<&2,X187Parsed>,w4c_is_ctrl(op) || w4c_inst_writes_xmm1(inst) || U32.is_gt(w4c_get_cnt(w4c_inst_writes(h,W4CMEmpty{}),disp),0),
        u => Con{h,rest},
        u => w4c_fwd_xmm1_apply(disp,h,w4c_fwd_xmm1_inst(disp,inst),rest,fuel))

@unsafe
def w4c_fwd_xmm1_go(+disp: U32, +items: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match items:
    case Con{+h,+rest}:
      match h:
        case PInst{inst}: w4c_fwd_xmm1_step(disp,h,inst,rest,fuel)
        case _: items
    case _: items

@unsafe
def w4c_fwd_xmm1(disp,items,fuel):
  nt_choose(List<&2,X187Parsed>,U32.is_eq(fuel,0),u => items,u => w4c_fwd_xmm1_go(disp,items,fuel))

# Rule C1e: 5-inst 2-term xmm0/xmm1 tree:
law w4c_try_tree5_a:
  for +disp: U32
  for l1: W4CLoadXmm
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_b:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_c:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_d:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_a:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_b:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for +s1: X187Operand
  for +d1: U32
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_ld:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_fop:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for f1: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w4c_try_tree5(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +i4: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(w4c_get_cnt(reads,disp),1),
    u => w4c_try_tree5_a(disp,w4c_as_load_xmm(i1),w4c_as_fop_any(i2),w4c_as_load_xmm(i3),w4c_as_load_xmm(i4),rest,fnItems,reads,acc),
    u => None{})

@unsafe
def w4c_try_tree5_a(disp,l1,f2,l3,l4,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{+op1,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,0) && w4c_op_safe_for_xmm1(disp,s1),
        u => w4c_try_tree5_b(disp,op1,s1,f2,l3,l4,rest,fnItems,reads,acc),u => None{})
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_tree5_b(disp,op1,s1,f2,l3,l4,rest,fnItems,reads,acc):
  match f2:
    case W4CFAYes{+op2,+s2,+d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d2,0) && w4c_op_safe_for_xmm1(disp,s2),
        u => w4c_try_tree5_c(disp,op1,s1,op2,s2,l3,l4,rest,fnItems,reads,acc),u => None{})
    case W4CFANo{}: None{}

@unsafe
def w4c_try_tree5_c(disp,op1,s1,op2,s2,l3,l4,rest,fnItems,reads,acc):
  match l3:
    case W4CLXYes{+op3,+s3,+d3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op3,"movaps") && w4c_op_is_xmm(0,s3) && U32.is_eq(d3,1),
        u => w4c_try_tree5_d(disp,op1,s1,op2,s2,l4,rest,fnItems,reads,acc),u => None{})
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_tree5_d(disp,op1,s1,op2,s2,l4,rest,fnItems,reads,acc):
  match l4:
    case W4CLXYes{+op4,+s4,+d4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op4,"movd") && w4c_op_is_slot(disp,s4) && U32.is_eq(d4,0),
        u => Some{w4c_xmm_peep(rest,fnItems,reads,
          Con{PInst{X187Instruction{op2,[s2,x188_xmm(1)]}},
          Con{PInst{X187Instruction{op1,[s1,x188_xmm(1)]}},acc}})},
        u => None{})
    case W4CLXNo{}: None{}

# Rule C1f: 3-inst movq %xmm0, disp(%rbp) ; <fop1> %xmm0, %xmm0 ; <fop2> disp(%rbp), %xmm0
@unsafe
def w4c_try_cube3_b(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, f2: W4CFopMem,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFMYes{+fop2,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp) && U32.is_eq(fdst,0) && w4c_xmm_dead(1,rest,fnItems,400,2),
        u => Some{w4c_xmm_peep(w4c_fwd_xmm1(disp,rest,16),fnItems,reads,
          Con{PInst{X187Instruction{fop2,[x188_xmm(1),x188_xmm(0)]}},
          Con{i1,Con{PInst{X187Instruction{"movaps",[x188_xmm(0),x188_xmm(1)]}},Con{i0,acc}}}})},
        u => None{})
    case W4CFMNo{}: None{}

@unsafe
def w4c_try_cube3_a(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, f1: W4CFopAny, +i2: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{_,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,0) && w4c_op_is_xmm(0,s1),
        u => w4c_try_cube3_b(disp,i0,i1,w4c_as_fop_mem(i2),rest,fnItems,reads,acc),u => None{})
    case W4CFANo{}: None{}

# Rule C1c/C1d: 3-inst movq %xmmA, disp(%rbp) ; <ld> s1, %xmmB ; <fop> disp(%rbp), %xmmB
@unsafe
def w4c_try_peep3(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w4c_try_peep3_a(xr,disp,i0,i1,w4c_as_load_xmm(i1),w4c_as_fop_mem(i2),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep3_a(xr,disp,i0,i1,l1,f2,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{_,+s1,+d1}:
      w4c_try_peep3_b(xr,disp,i0,i1,s1,d1,f2,rest,fnItems,reads,acc)
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_peep3_b(xr,disp,i0,i1,s1,d1,f2,rest,fnItems,reads,acc):
  match f2:
    case W4CFMYes{+fop,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp) && U32.is_eq(fdst,d1),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(d1,xr)),
          v => Some{w4c_xmm_peep(rest,fnItems,reads,
            Con{PInst{X187Instruction{fop,[x188_xmm(xr),x188_xmm(d1)]}},Con{i1,Con{i0,acc}}})},
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0) && w4c_op_safe_for_xmm1(disp,s1) && w4c_xmm_dead(1,rest,fnItems,400,2),
            w => Some{w4c_xmm_peep(w4c_fwd_xmm1(disp,rest,16),fnItems,reads,
              Con{PInst{X187Instruction{fop,[x188_xmm(1),x188_xmm(0)]}},
              Con{i1,Con{PInst{X187Instruction{"movaps",[x188_xmm(0),x188_xmm(1)]}},Con{i0,acc}}}})},
            w => None{})),
        u => None{})
    case W4CFMNo{}: None{}

# Rule C1a/C1b: 2-inst movq %xmmA, disp(%rbp) ; movd disp(%rbp), %xmmB  OR  <fop> disp(%rbp), %xmmB
@unsafe
def w4c_try_peep2(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w4c_try_peep2_ld(xr,disp,i0,i1,w4c_as_load_xmm(i1),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep2_ld(xr,disp,i0,i1,l1,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{+op1,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"movd") && w4c_op_is_slot(disp,s1),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,xr),
          v => Some{w4c_xmm_peep(Con{i0,rest},fnItems,reads,acc)},
          v => Some{w4c_xmm_peep(rest,fnItems,reads,
            Con{PInst{X187Instruction{"movaps",[x188_xmm(xr),x188_xmm(d1)]}},Con{i0,acc}})}),
        u => w4c_try_peep2_fop(xr,disp,i0,w4c_as_fop_mem(i1),rest,fnItems,reads,acc))
    case W4CLXNo{}: w4c_try_peep2_fop(xr,disp,i0,w4c_as_fop_mem(i1),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep2_fop(xr,disp,i0,f1,rest,fnItems,reads,acc):
  match f1:
    case W4CFMYes{+fop,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp),
        u => Some{w4c_xmm_peep(rest,fnItems,reads,
          Con{PInst{X187Instruction{fop,[x188_xmm(xr),x188_xmm(fdst)]}},Con{i0,acc}})},
        u => None{})
    case W4CFMNo{}: None{}

@unsafe
def w4c_xmm_peep_hit3(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i3,Con{+i4,+r4}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0),
        u => w4c_try_tree5(disp,i0,i1,i2,i3,i4,r4,fnItems,reads,acc),u => None{})
    case _: None{}

@unsafe
def w4c_xmm_peep_hit2(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, r1: List<&2,X187Parsed>,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case Con{+i2,+r2}:
      w4c_or_peep(w4c_xmm_peep_hit3(xr,disp,i0,i1,i2,r2,fnItems,reads,acc),
        u => w4c_or_peep(w4c_try_peep3(xr,disp,i0,i1,i2,r2,fnItems,reads,acc),
          v => w4c_or_peep(nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0),
              w => w4c_try_cube3_a(disp,i0,i1,w4c_as_fop_any(i1),i2,r2,fnItems,reads,acc),w => None{}),
            w => w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc}))))
    case _: w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc})

@unsafe
def w4c_xmm_peep_hit(+xr: U32, +disp: U32, +i0: X187Parsed, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tail:
    case Con{+i1,+r1}:
      w4c_or_peep(w4c_try_peep2(xr,disp,i0,i1,r1,fnItems,reads,acc),
        u => w4c_xmm_peep_hit2(xr,disp,i0,i1,r1,tail,fnItems,reads,acc))
    case Nil{}: nt_reverse(X187Parsed,Con{i0,acc},[])

@unsafe
def w4c_xmm_peep_step(m: W4CMovqXmmMem, +i0: X187Parsed, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match m:
    case W4CMXMYes{xr,disp}: w4c_xmm_peep_hit(xr,disp,i0,tail,fnItems,reads,acc)
    case W4CMXMNo{}: w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc})

@unsafe
def w4c_xmm_peep(items,fnItems,reads,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+tail}: w4c_xmm_peep_step(w4c_as_movq_xm(i0),i0,tail,fnItems,reads,acc)

# ---- Sub-pass C2 & C3: Straight-line Basic Block Split + Copy-Fwd + Backedge Coalesce ----
law w4c_fwd_bb:
  for items: List<&2,X187Parsed>
  for +totR: W4CMap
  for +totW: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w5_fwd_do(ok: Bool, +src: U32, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ok:
    case True{}: w4c_fwd_bb(w4c_replace_slot(d,src,rest),totR,totW,acc)
    case False{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w5_fwd_check(cand: Bool, +src: U32, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cand:
    case False{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})
    case True{}:
      w5_fwd_do(U32.is_eq(w5_count_slot_reads(d,rest,0),w4c_get_cnt(totR,d)) && Bool.not(w4c_slot_written(src,rest)),
        src,d,i0,i1,rest,totR,totW,acc)

@unsafe
def w4c_fwd_try(+src: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      w5_fwd_check(Bool.not(U32.is_eq(src,d)) && U32.is_eq(w4c_get_cnt(totW,d),1),src,d,i0,i1,rest,totR,totW,acc)
    case _: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w4c_fwd_step(ld: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ld:
    case Some{src}: w4c_fwd_try(src,w4c_as_store_r10(i1),i0,i1,rest,totR,totW,acc)
    case None{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w4c_fwd_bb(items,totR,totW,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+rest}}: w4c_fwd_step(w4c_as_load_r10(i0),i0,i1,rest,totR,totW,acc)
    case Con{h,rest}: w4c_fwd_bb(rest,totR,totW,Con{h,acc})

@unsafe
def w4c_fwd_bbs(bbs: List<&2,List<&2,X187Parsed>>, +totR: W4CMap, +totW: W4CMap) -> List<&2,List<&2,X187Parsed>>:
  match bbs:
    case Nil{}: []
    case Con{b,rest}: Con{w4c_fwd_bb(b,totR,totW,[]),w4c_fwd_bbs(rest,totR,totW)}

law w4c_coal_bb:
  for items: List<&2,X187Parsed>
  for +totR: W4CMap
  for +totW: W4CMap
  for +bbR: W4CMap
  for +bbW: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w4c_coal_mem(+tmp: U32, +dst: U32, sp: W4CDefSplit, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W4CDSNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})
    case W4CDSYes{+between,+defInst,+beforeRev}:
      +ok = Bool.not(w4c_slot_touched(tmp,beforeRev)) && Bool.not(w4c_slot_touched(tmp,rest)) &&
            Bool.not(w4c_slot_touched(dst,between))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_coal_bb(rest,totR,totW,bbR,bbW,
          nt_append(X187Parsed,nt_reverse(X187Parsed,w4c_replace_slot(tmp,dst,between),[]),
            Con{w4c_replace_inst(tmp,dst,defInst),beforeRev})),
        u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))

@unsafe
def w4c_coal_gpr_def(+tmp: U32, +reg: U32, dm: W4CMovqXmmMem, +between: List<&2,X187Parsed>,
    +beforeRev: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dm:
    case W4CMXMYes{+xr,+d}:
      +ok = U32.is_eq(d,tmp) && Bool.not(w4c_slot_touched(tmp,beforeRev)) &&
            Bool.not(w4c_slot_touched(tmp,between)) && Bool.not(w4c_slot_touched(tmp,rest)) &&
            Bool.not(w4c_gpr_touched(reg,between))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_coal_bb(rest,totR,totW,bbR,bbW,
          nt_append(X187Parsed,nt_reverse(X187Parsed,between,[]),
            Con{PInst{X187Instruction{"movd",[x188_xmm(xr),X187Reg{reg,32,False{}}]}},beforeRev})),
        u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))
    case W4CMXMNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_gpr(+tmp: U32, +reg: U32, sp: W4CDefSplit, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W4CDSNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})
    case W4CDSYes{between,defInst,beforeRev}:
      w4c_coal_gpr_def(tmp,reg,w4c_as_movq_xm(defInst),between,beforeRev,i0,i1,rest,totR,totW,bbR,bbW,acc)

@unsafe
def w4c_coal_dispatch(+tmp: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      nt_choose(List<&2,X187Parsed>,Bool.not(U32.is_eq(tmp,d)),
        v => w4c_coal_mem(tmp,d,w4c_find_def_back(tmp,acc,[]),i0,i1,rest,totR,totW,bbR,bbW,acc),
        v => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))
    case W4CSRGpr{+r}:
      w4c_coal_gpr(tmp,r,w4c_find_def_back(tmp,acc,[]),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case W4CSRNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_try(+tmp: U32, +dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +localOnly = U32.is_eq(w4c_get_cnt(totW,tmp),1) && U32.is_eq(w4c_get_cnt(bbW,tmp),1) &&
               U32.is_eq(w4c_get_cnt(totR,tmp),w4c_get_cnt(bbR,tmp))
  nt_choose(List<&2,X187Parsed>,localOnly,
    u => w4c_coal_dispatch(tmp,dst,i0,i1,rest,totR,totW,bbR,bbW,acc),
    u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))

@unsafe
def w4c_coal_step(ld: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ld:
    case Some{tmp}: w4c_coal_try(tmp,w4c_as_store_r10(i1),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case None{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_bb(items,totR,totW,bbR,bbW,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+rest}}: w4c_coal_step(w4c_as_load_r10(i0),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case Con{h,rest}: w4c_coal_bb(rest,totR,totW,bbR,bbW,Con{h,acc})

law w5_gpr_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# G1: movq d1(%rbp), %rB; <comm64> %rA, %rB; movq d2(%rbp), %rA; <comm64> %rB, %rA (%rB dead)
@unsafe
def w5_g2_f(+rC: U32, +srcY: X187Operand, +rN: U32, +cmop: String, st5: W5MovqFromReg,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st5:
    case W5MFRYes{s5,+dst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s5,11) && w5_dst_ok_cmov(rN,dst) &&
        w4b_reg_dead(0,r6,fnItems,96) && w4b_reg_dead(10,r6,fnItems,96) &&
        w4b_reg_dead(11,r6,fnItems,96) && w4b_reg_dead(rN,r6,fnItems,96),
        u => Some{w5_gpr_peep(r6,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},
          Con{PInst{X187Instruction{cmop,[srcY,x188_reg(rN,64)]}},
          Con{PInst{X187Instruction{"testl",[x188_reg(rC,32),x188_reg(rC,32)]}},acc}}})},
        u => None{})
    case W5MFRNo{}: None{}

@unsafe
def w5_g2_e(+rC: U32, +srcY: X187Operand, +rN: U32, rr4: W4BRR, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr4:
    case W4BRR{+cmop,10,64,11,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(cmop,"cmovneq") || agy_str_eq(cmop,"cmoveq"),
        u => w5_g2_f(rC,srcY,rN,cmop,w5_as_movq_from_reg(i5),r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_d(+rC: U32, +srcY: X187Operand, +rN: U32, rr3: W4BRR, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{top,0,32,0,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(top,"testl"),
        u => w5_g2_e(rC,srcY,rN,w4b_as_rr(i4),i5,r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_c(+rC: U32, +srcY: X187Operand, rr2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,+rN,64,11,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && w5_not_scratch(rN) && Bool.not(U32.is_eq(rN,rC)) &&
        w5_src_ok_cmov(rN,srcY),
        u => w5_g2_d(rC,srcY,rN,w4b_as_rr(i3),i4,i5,r6,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g2_b(+rC: U32, m1: W5MovqToReg, +i2: X187Parsed, +i3: X187Parsed, +i4: X187Parsed, +i5: X187Parsed,
    +r6: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MTRYes{srcY,10}: w5_g2_c(rC,srcY,w4b_as_rr(i2),i3,i4,i5,r6,fnItems,acc)
    case _: None{}

# G3: movq %rA, %rT; movq %rB, %rA; movq %rT, %rB; <comm> %rA, %rB (%rT,%rA dead) -> <comm> %rA, %rB
@unsafe
def w5_g3_d(+rA: U32, +rB: U32, +rT: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{+op3,s3,+w3,d3,dw3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(w3,dw3) && U32.is_eq(s3,rA) && U32.is_eq(d3,rB) &&
        ((U32.is_eq(w3,32) && w5_is_comm32(op3)) || (U32.is_eq(w3,64) && w5_is_comm64(op3))) &&
        w4b_reg_dead(rT,r4,fnItems,96) && w4b_reg_dead(rA,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op3,[x188_reg(rA,w3),x188_reg(rB,w3)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g3_c(+rA: U32, +rB: U32, +rT: U32, rr2: W4BRR, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,64,d2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,rT) && U32.is_eq(d2,rB),
        u => w5_g3_d(rA,rB,rT,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case _: None{}

# G4: movq %rA, %rT; movq %rD, %rA; subl %rT32, %rA32; movq %rA, %rD (%rT,%rA dead) -> subl %rA32, %rD32
@unsafe
def w5_g4_d(+rA: U32, +rD: U32, +rT: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,"movq") && U32.is_eq(s3,rA) && U32.is_eq(d3,rD) &&
        w4b_reg_dead(rT,r4,fnItems,96) && w4b_reg_dead(rA,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{"subl",[x188_reg(rA,32),x188_reg(rD,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g4_c(+rA: U32, +rD: U32, +rT: U32, rr2: W4BRR, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,d2,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"subl") && U32.is_eq(s2,rT) && U32.is_eq(d2,rA),
        u => w5_g4_d(rA,rD,rT,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_g34_b(+rA: U32, +rT: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,+rB,64,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_eq(d1,rA) && Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rT)),
        u => w4c_or_peep_opt(w5_g3_c(rA,rB,rT,w4b_as_rr(i2),i3,r4,fnItems,acc),
          v => w5_g4_c(rA,rB,rT,w4b_as_rr(i2),i3,r4,fnItems,acc)),
        u => None{})
    case _: None{}

# G5: movq %rA, %rB; cmpq $C, %rB; setcc %rB8; movzbl %rB8, %rB32 -> cmpq $C, %rA; setcc %rB8; movzbl %rB8, %rB32
@unsafe
def w5_g5_d(+rA: U32, +rB: U32, +lo: U32, +hi: U32, +setop: String, mz3: W5Movzbl,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mz3:
    case W5MZYes{sr,dr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rB) && U32.is_eq(dr,rB),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{"movzbl",[x188_reg(rB,8),x188_reg(rB,32)]}},
          Con{PInst{X187Instruction{setop,[x188_reg(rB,8)]}},
          Con{PInst{X187Instruction{"cmpq",[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}}})},
        u => None{})
    case W5MZNo{}: None{}

@unsafe
def w5_g5_c(+rA: U32, +rB: U32, +lo: U32, +hi: U32, sc2: W5Setcc, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match sc2:
    case W5SetYes{setop,sr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rB),
        u => w5_g5_d(rA,rB,lo,hi,setop,w5_as_movzbl(i3),r4,fnItems,acc),
        u => None{})
    case W5SetNo{}: None{}

@unsafe
def w5_g5_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"cmpq") && U32.is_eq(d1,rB),
        u => w5_g5_c(rA,rB,lo,hi,w5_as_setcc(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G6a: movq %rA, %rB; imull $3, %rB32; addl %rB32, %rD32 (%rB dead) -> leaq (%rA,%rA,2), %rB; addl %rB32, %rD32
# G6b: movq %rA, %rB; addl $c, %rB32; subl %rB32, %rD32 (%rB dead) -> leaq c(%rA), %rB; subl %rB32, %rD32
# G7:  movq %rA, %rB; andq $M, %rB; movq %rB, disp(%rbp) (%rA,%rB dead) -> andq $M, %rA; movq %rA, disp(%rbp)
@unsafe
def w5_g6a_c(+rA: U32, +rB: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"addl") && U32.is_eq(s2,rB) && Bool.not(U32.is_eq(rB,rD)) &&
        Bool.not(U32.is_eq(rA,4)) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"addl",[x188_reg(rB,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"leaq",[X187Indexed{rA,rA,2,0},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g6b_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{+op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        (agy_str_eq(op2,"subl") || agy_str_eq(op2,"addl")) && U32.is_eq(s2,rB) &&
        Bool.not(U32.is_eq(rB,rD)) && U32.is_le(c,2147483647) &&
        w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{op2,[x188_reg(rB,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"leaq",[X187Mem{rA,c},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g7_c(+rA: U32, +rB: U32, +op1: String, +lo: U32, +hi: U32, st2: W5StoreRbp, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W5SRYes{sr,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sr,rB) && Bool.not(U32.is_eq(rA,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{op1,[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case W5SRNo{}: None{}

@unsafe
def w5_g67_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{+op1,+lo,+hi,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && U32.is_eq(hi,0),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"imull") && U32.is_eq(lo,3),
          v => w5_g6a_c(rA,rB,w4b_as_rr(i2),r3,fnItems,acc),
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl"),
            w => w5_g6b_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
            w => None{})),
        u => None{})
    case W4BImmReg{+op1,+lo,+hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(d1,rB) && (agy_str_eq(op1,"andq") || agy_str_eq(op1,"shlq") || agy_str_eq(op1,"shrq")),
        u => w5_g7_c(rA,rB,op1,lo,hi,w5_as_store_rbp(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

# G10: movq %rA, %rB; movq %rB, %rC (%rB dead) -> movq %rA, %rC
@unsafe
def w5b_g10_b(+rA: U32, +rB: U32, rr1: W4BRR, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,s1,64,+rC,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rC,rB)) &&
        w4b_reg_dead(rB,r2,fnItems,96),
        u => Some{nt_choose(List<&2,X187Parsed>,U32.is_eq(rA,rC),
          v => w5_gpr_peep(r2,fnItems,acc),
          v => w5_gpr_peep(r2,fnItems,Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},acc}))},
        u => None{})
    case _: None{}

# G6c: movl %rA32, %rB32; addl $c, %rB32; imull %rB32, %rD32 (%rA,%rB dead) -> addl $c, %rA32; imull %rA32, %rD32
@unsafe
def w5_g6c_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,32,+rD,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"imull") && U32.is_eq(s2,rB) && Bool.not(U32.is_eq(rA,rD)) && Bool.not(U32.is_eq(rB,rD)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"imull",[x188_reg(rA,32),x188_reg(rD,32)]}},
          Con{PInst{X187Instruction{"addl",[X187Imm{c,0},x188_reg(rA,32)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_g6c_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,0,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl") && U32.is_eq(d1,rB),
        u => w5_g6c_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

# G8: xorl $1, %r32; xorq $1, %r64 (flags dead) -> movl %r32, %r32
@unsafe
def w5_g8_b(+r: U32, im1: W4BImmReg, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,1,0,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"xorq") && U32.is_eq(d1,r) && w4_peep_flags_dead_list(r2,16),
        u => Some{w5_gpr_peep(r2,fnItems,Con{PInst{X187Instruction{"movl",[x188_reg(r,32),x188_reg(r,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr64_g2(+rA: U32, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed, r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r4:
    case Con{+i4,Con{+i5,+r6}}: w5_g2_b(rA,w5_as_movq_to_reg(i1),i2,i3,i4,i5,r6,fnItems,acc)
    case _: None{}

# G1-gen: movq src1, %rB; <comm64> %rA, %rB; movq src2, %rA; <comm64> %rB, %rA (%rB dead)
#         -> <comm64> src1, %rA; <comm64> src2, %rA (src1,src2 in {d(%rbp), %rC})
@unsafe
def w5b_g1_d(+src1: X187Operand, +src2: X187Operand, +op1: String, +rA: U32, +rB: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,op1) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
        w4b_reg_dead(rB,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op1,[src2,x188_reg(rA,64)]}},
          Con{PInst{X187Instruction{op1,[src1,x188_reg(rA,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5b_g1_c(+src1: X187Operand, +op1: String, +rA: U32, +rB: U32, mv2: W5MovqToReg, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mv2:
    case W5MTRYes{+src2,dr2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(dr2,rA) && w5b_g1_src_ok(rA,rB,src2),
        u => w5b_g1_d(src1,src2,op1,rA,rB,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case W5MTRNo{}: None{}

@unsafe
def w5b_g1_b(+src1: X187Operand, +rB: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{+op1,+rA,64,dr1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op1) && U32.is_eq(dr1,rB) && Bool.not(U32.is_eq(rA,rB)) &&
        Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)) && w5b_g1_src_ok(rA,rB,src1),
        u => w5b_g1_c(src1,op1,rA,rB,w5_as_movq_to_reg(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G11: jne/je L; movq -disp(%rbp), %r64; jmp L; L: -> cmoveq/cmovneq -disp(%rbp), %r64; L:
@unsafe
def w5_g11_d(+cmop: String, +d: U32, +r: U32, +lbl: String, i3: X187Parsed, +r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i3:
    case PLabel{+l3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l3,lbl),
        u => Some{w5_gpr_peep(Con{PLabel{l3},r4},fnItems,
          Con{PInst{X187Instruction{cmop,[X187Mem{5,d},x188_reg(r,64)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g11_c(+cmop: String, +d: U32, +r: U32, +lbl: String, br2: W4BBranch, +i3: X187Parsed, +r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match br2:
    case W4BBranch{op2,t2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op2,"jmp") && agy_str_eq(t2,lbl),
        u => w5_g11_d(cmop,d,r,lbl,i3,r4,fnItems,acc),
        u => None{})
    case W4BBranchNone{}: None{}

@unsafe
def w5_g11_b(+cmop: String, +lbl: String, ld1: W5LoadRbp, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d,r}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5_g11_c(cmop,d,r,lbl,w4b_as_branch(i2),i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_try_jcc(br0: W4BBranch, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match br0:
    case W4BBranch{op0,lbl}:
      +cmop = w5_g11_inv_jcc(op0)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(String.is_empty(cmop)),
        u => w5_g11_b(cmop,lbl,w5_as_load_rbp(i1),r2,fnItems,acc),
        u => None{})
    case W4BBranchNone{}: None{}

# G10: movq %rA, %rB; addl $c, %rB32; movq %rB, %rA (rB dead) -> addl $c, %rA32
@unsafe
def w5_g10_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,64,d2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,rB) && U32.is_eq(d2,rA) &&
        w4b_reg_dead(rB,r3,fnItems,64),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"addl",[X187Imm{c,0},x188_reg(rA,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g10_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,0,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"addl") && U32.is_eq(d1,rB) && Bool.not(U32.is_eq(rA,rB)),
        u => w5_g10_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5b_g1_b(x188_reg(rA,64),rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          v2 => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
              x => w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc),
                y => w4c_or_peep_opt(w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,Con{i3,r4}},fnItems,acc),
                  z => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc)))))))
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w4c_or_peep_opt(w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc),
          v => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc)))
    case Nil{}: w5b_g10_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)

# G9: movl %rA32, %rB32; movl %rB32, %rC32 -> movl %rA32, %rB32; movl %rA32, %rC32
@unsafe
def w5_g9_b(+rA: U32, +rB: U32, rr1: W4BRR, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,s1,32,+rC,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movl") && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rC,rA)) && Bool.not(U32.is_eq(rC,rB)),
        u => Some{w5_gpr_peep(r2,fnItems,
          Con{PInst{X187Instruction{"movl",[x188_reg(rA,32),x188_reg(rC,32)]}},
          Con{PInst{X187Instruction{"movl",[x188_reg(rA,32),x188_reg(rB,32)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr32_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g6c_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w5_g9_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc))
    case Nil{}: w5_g9_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)

law w5b_g12_scan:
  for +rC: U32
  for items: List<&2,X187Parsed>
  for +mid: List<&2,X187Parsed>
  for +budget: U32
  for +fnItems: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5b_g12_scan_go(+rC: U32, items: List<&2,X187Parsed>, +mid: List<&2,X187Parsed>,
    +budget: U32, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Con{+h,Con{+h2,+rest}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_g12_is_testl_self(rC,h),
        v => w5b_g12_found_cmov(rC,w5b_g12_match_cmov(rC,h2),mid,rest,fnItems),
        v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_g12_safe_mid(rC,h),
          w => w5b_g12_scan(rC,Con{h2,rest},Con{h,mid},U32.sub(budget,1),fnItems),
          w => None{}))
    case _: None{}

@unsafe
def w5b_g12_scan(rC,items,mid,budget,fnItems):
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(budget,0),u => None{},
    u => w5b_g12_scan_go(rC,items,mid,budget,fnItems))

@unsafe
def w5b_g12_apply(res: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match res:
    case Some{rewritten}: Some{w5_gpr_peep(rewritten,fnItems,acc)}
    case None{}: None{}

@unsafe
def w5b_g12_c(+rC: U32, mz2: W5Movzbl, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mz2:
    case W5MZYes{sr,dr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rC) && U32.is_eq(dr,rC),
        u => w5b_g12_apply(w5b_g12_scan(rC,r3,[],16,fnItems),fnItems,acc),
        u => None{})
    case W5MZNo{}: None{}

@unsafe
def w5b_g12_b_r2(+rC: U32, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}: w5b_g12_c(rC,w5_as_movzbl(i2),r3,fnItems,acc)
    case Nil{}: None{}

@unsafe
def w5b_g12_b(+rC: U32, sc1: W5Setcc, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match sc1:
    case W5SetYes{op,sr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op,"sete") && U32.is_eq(sr,rC),
        u => w5b_g12_b_r2(rC,r2,fnItems,acc),
        u => None{})
    case W5SetNo{}: None{}

@unsafe
def w5b_g15_c(+d1: U32, +rA: U32, +d2: U32, +rB: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{+op2,s2,64,d_2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op2) && U32.is_eq(s2,rA) && U32.is_eq(d_2,rB) &&
        Bool.not(U32.is_eq(rA,rB)) && Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{op2,[X187Mem{5,d1},x188_reg(rB,64)]}},
          Con{PInst{X187Instruction{"movq",[X187Mem{5,d2},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5b_g15_b(+d1: U32, +rA: U32, ld1: W5LoadRbp, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d2,rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rA,rB)),
        u => w5b_g15_c(d1,rA,d2,rB,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_try_ld(ld0: W5LoadRbp, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld0:
    case W5LRYes{d1,rB}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}:
          w4c_or_peep_opt(w5b_g1_b(X187Mem{5,d1},rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            u => w5b_g15_b(d1,rB,w5_as_load_rbp(i1),i2,Con{i3,r4},fnItems,acc))
        case Con{+i2,+r3}: w5b_g15_b(d1,rB,w5_as_load_rbp(i1),i2,r3,fnItems,acc)
        case Nil{}: None{}
    case W5LRNo{}: None{}

@unsafe
def w5c_gpr_or(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{out}: out
    case None{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_ld_if(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match neg:
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}: w5c_gpr_or(w5_gpr_try_ld(W5LRYes{disp,rB},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_rr64_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_try_movq_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Mem{5,disp}: w5c_gpr_ld_if(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5c_gpr_rr64_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_try_cmpq_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Imm{0,0}: w5c_gpr_or(w5b_g12_b(rB,w5_as_setcc(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_rr32_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_try_movl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Reg{+rA,32,False{}}: w5c_gpr_rr32_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_try_xorl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Imm{1,0}: w5c_gpr_or(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_cmp(isCmpq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isCmpq:
    case True{}: w5c_gpr_try_cmpq_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64(isMovq: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5c_gpr_try_movq_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op64_cmp(String.eq(op,"cmpq"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_op32_xor(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isXor:
    case True{}: w5c_gpr_try_xorl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op32(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovl:
    case True{}: w5c_gpr_try_movl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op32_xor(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_wd(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match wd:
    case 64: w5c_gpr_op64(String.eq(op,"movq"),op,src,d,i0,i1,r2,fnItems,acc)
    case 32: w5c_gpr_op32(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5c_gpr_wd(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      w5c_gpr_or(w5_gpr_try_jcc(W4BBranch{op,lbl},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5_gpr_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+r2}}: w5_gpr_step(i0,i1,r2,fnItems,acc)
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])

# W5-C1: Single-pass bitmask scanner + zero-roundtrip sequence flattener + guarded post-select
@unsafe
def w5b_scan_slot_args(+op: String, args: List<&2,X187Operand>, +afterLbl: Bool, +counts: W4CMap, +bad: W4CMap) -> W5BSlotScan:
  match args:
    case Con{X187Mem{b,+d},Con{+dst,Nil{}}}:
      nt_choose(W5BSlotScan,w4c_is_neg_rbp(b,d),
        v => nt_choose(W5BSlotScan,
          U32.is_ge(w4c_slot_key(d),48) && w5b_is_gpr64_slot_op(op) && w5b_is_gpr64_reg(dst),
          w => W5BSlotScan{nt_choose(W4CMap,afterLbl,
            x => w5b_map_inc8(counts,w4c_slot_key(d)),
            x => w4c_map_inc(counts,w4c_slot_key(d),w4c_slot_key(d),0)),bad},
          w => W5BSlotScan{counts,w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0)}),
        v => W5BSlotScan{counts,w5b_mark_bad_op(dst,bad)})
    case Con{+src,Con{X187Mem{b,+d},Nil{}}}:
      nt_choose(W5BSlotScan,w4c_is_neg_rbp(b,d),
        v => nt_choose(W5BSlotScan,
          U32.is_ge(w4c_slot_key(d),48) && w5b_is_gpr64_slot_op(op) && w5b_is_gpr64_or_imm(src),
          w => W5BSlotScan{w4c_map_inc(counts,w4c_slot_key(d),w4c_slot_key(d),0),bad},
          w => W5BSlotScan{counts,w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0)}),
        v => W5BSlotScan{counts,w5b_mark_bad_op(src,bad)})
    case _: W5BSlotScan{counts,w5b_mark_bad_args(args,bad)}

@unsafe
def w5b_scan_slot_inst(+op: String, +args: List<&2,X187Operand>, beforeInit: Bool,
    +afterLbl: Bool, st: W5BSlotScan) -> W5BSlotScan:
  match st:
    case W5BSlotScan{+counts,+bad}:
      nt_choose(W5BSlotScan,beforeInit,
        u => W5BSlotScan{counts,w5b_mark_bad_args(args,bad)},
        u => w5b_scan_slot_args(op,args,afterLbl,counts,bad))

@unsafe
def w5b_promote_do(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>, best: W5BBestSlot) -> List<&2,X187Parsed>:
  match best:
    case W5BBestSlot{+k,cnt}:
      nt_choose(List<&2,X187Parsed>,U32.is_eq(k,0),u => items,
        u => w5b_rew_items(U32.sub(0,k),rFree,isR12,items,[]))

@unsafe
def w5b_promote_pick(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>, st: W5BSlotScan) -> List<&2,X187Parsed>:
  match st:
    case W5BSlotScan{counts,bad}: w5b_promote_do(rFree,isR12,items,w5b_pick_best(counts,bad,W5BBestSlot{0,2}))

@unsafe
def w5b_try_ror16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{ra3,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{ra4,w4,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shrq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"movq") &&
            (agy_str_eq(op4,"shll") || agy_str_eq(op4,"shlq")) &&
            agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2,rA) && U32.is_eq(rx3,rX) &&
            U32.is_eq(ra3,rA) && U32.is_eq(ra4,rA) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rorw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try 16-bit rotate pattern R2 (shl-first):
#   movq %rX, %rA; shlq $k, %rA; movl %rA32, %rA32; movq %rX, %rB; shrq $(16-k), %rB; orq %rB, %rA; andq $65535, %rA
@unsafe
def w5b_try_rol16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2a,32,False{}},Con{X187Reg{ra2b,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{rb4,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shlq") && agy_str_eq(op2,"movl") && agy_str_eq(op3,"movq") &&
            agy_str_eq(op4,"shrq") && agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2a,rA) && U32.is_eq(ra2b,rA) &&
            U32.is_eq(rx3,rX) && U32.is_eq(rb4,rB) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rolw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne -> cmp + j<cc>
@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    # Pattern B2a: setcc %rA8; movzbl %rA8,%rA32; xorl $1,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opX,"xorl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rx,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B2b: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; xorl $1,%rB32; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opX,"xorl") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) && U32.is_eq(rx,rB) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B1: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isE),[X187Target{lbl}]}},tail}}},
        u => None{})
    case _: None{}

# Try movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d -> cmpq %rB, %rA; setcc; movzbl
@unsafe
def w5b_try_cmp_bounce(+rA: U32, +rT1: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{+rB,64,False{}},Con{X187Reg{+rT2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{c1,64,False{}},Con{X187Reg{c2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opS,Con{X187Reg{rs,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},+tail}}}}:
      +ok = agy_str_eq(op1,"movq") && agy_str_eq(op2,"cmpq") && agy_str_eq(opZ,"movzbl") &&
            Bool.not(String.is_empty(w5b_set_cc(opS))) &&
            U32.is_eq(c1,rT2) && U32.is_eq(c2,rT1) && U32.is_eq(rs,rT1) &&
            U32.is_eq(rz1,rT1) && U32.is_eq(rz2,rT1) &&
            Bool.not(U32.is_eq(rT1,rT2)) && Bool.not(U32.is_eq(rB,rT1)) &&
            w5b_reg_dead_fast(rT2,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

# Try spill-bounce: movq %rS, %rT; movq %rT, d(%rbp) (rT in {10,11}, rT dead) -> movq %rS, d(%rbp)
@unsafe
def w5b_try_spill_bounce(+rS: U32, +rT: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{rt1,64,False{}},Con{X187Mem{5,+disp},Nil{}}}}},+tail}:
      +ok = agy_str_eq(op1,"movq") && U32.is_eq(rt1,rT) && (U32.is_eq(rT,10) || U32.is_eq(rT,11)) &&
            Bool.not(U32.is_eq(rS,rT)) && w5b_reg_dead_fast(rT,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[x188_reg(rS,64),X187Mem{5,disp}]}},tail}},
        u => None{})
    case _: None{}

# Try select-bounce: movq %r10, %rax; movq d(%rbp), %r10; movq %rN, %r11; testl %eax,%eax; cmovneq %r10,%r11; movq %r11, dst
#   (%rax,%r10,%r11,%rN dead) -> movq d(%rbp), %r11; testl %r10d,%r10d; cmovneq %r11,%rN; movq %rN, dst
@unsafe
def w5b_try_sel_bounce(+rA: U32, +rD: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{+srcY,Con{X187Reg{r10a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+rN,64,False{}},Con{X187Reg{r11a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{0,32,False{}},Con{X187Reg{0,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Reg{r10b,64,False{}},Con{X187Reg{r11b,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{r11c,64,False{}},Con{+dst,Nil{}}}}},+tail}}}}}:
      +ok = U32.is_eq(rA,10) && U32.is_eq(rD,0) &&
            agy_str_eq(op1,"movq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"testl") &&
            agy_str_eq(op4,"cmovneq") && agy_str_eq(op5,"movq") &&
            U32.is_eq(r10a,10) && U32.is_eq(r11a,11) && U32.is_eq(r10b,10) &&
            U32.is_eq(r11b,11) && U32.is_eq(r11c,11) &&
            Bool.not(U32.is_eq(rN,10)) && Bool.not(U32.is_eq(rN,11)) && Bool.not(U32.is_eq(rN,0)) &&
            w5b_reg_dead_fast(0,tail,fnItems) && w5b_reg_dead_fast(10,tail,fnItems) &&
            w5b_reg_dead_fast(11,tail,fnItems) && w5b_reg_dead_fast(rN,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[srcY,x188_reg(11,64)]}},
                  Con{PInst{X187Instruction{"testl",[x188_reg(10,32),x188_reg(10,32)]}},
                  Con{PInst{X187Instruction{"cmovneq",[x188_reg(11,64),x188_reg(rN,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},tail}}}}},
        u => None{})
    case _: None{}

# Try duplicate load before imull: movq d(%rbp), %rA; movq d(%rbp), %rB; imull %rA32, %rB32 (%rA dead)
@unsafe
def w5b_try_dup_square(+d1: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Mem{5,d2},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+m1,32,False{}},Con{X187Reg{+m2,32,False{}},Nil{}}}}},+tail}}:
      +okA = agy_str_eq(op1,"movq") && agy_str_eq(op2,"imull") && U32.is_eq(d1,d2) &&
             Bool.not(U32.is_eq(rA,rB)) && U32.is_eq(m1,rA) && U32.is_eq(m2,rB) &&
             w5b_reg_dead_fast(rA,tail,fnItems)
      +okB = agy_str_eq(op1,"movq") && agy_str_eq(op2,"imull") && U32.is_eq(d1,d2) &&
             Bool.not(U32.is_eq(rA,rB)) && U32.is_eq(m1,rB) && U32.is_eq(m2,rA) &&
             w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,okA,
        u => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rB,64)]}},
                  Con{PInst{X187Instruction{"imull",[x188_reg(rB,32),x188_reg(rB,32)]}},tail}}},
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,okB,
          v => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rA,64)]}},
                    Con{PInst{X187Instruction{"imull",[x188_reg(rA,32),x188_reg(rA,32)]}},tail}}},
          v => None{}))
    case _: None{}

law w5b_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w5b_peep_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{rewritten}: w5b_peep(rewritten,fnItems,acc)
    case None{}: w5b_peep(rest,fnItems,Con{i0,acc})

# W5C-R1: General x86-64 load-bounce & 64-bit imm ALU-bounce peepholes
@unsafe
def w5c_try_load_bounce(+d1: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{+rS,64,False{}},Con{X187Reg{+rD,64,False{}},Nil{}}}}},+tail}:
      +ok = (U32.is_eq(rA,10) || U32.is_eq(rA,11)) && agy_str_eq(op1,"movq") &&
            U32.is_eq(rS,rA) && Bool.not(U32.is_eq(rD,rA)) && w5b_reg_dead_fast(rA,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rD,64)]}},tail}},
        u => None{})
    case _: None{}

@unsafe
def w5c_movzbl_copy(+rB: U32, +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tail:
    case Con{+i2,+tail2}:
      nt_choose(List<&2,X187Parsed>,U32.is_lt(rB,16) && w5c_is_self_movl(i2,rB),
        u => w5b_peep(Con{i1,tail2},fnItems,Con{i0,acc}),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case Nil{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_try_alu64_bounce(+rA: U32, +rB: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{+op1,Con{+imm,Con{X187Reg{+r1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+r2,64,False{}},Con{X187Reg{+r3,64,False{}},Nil{}}}}},+tail}}:
      +ok = (U32.is_eq(rB,10) || U32.is_eq(rB,11)) && Bool.not(U32.is_eq(rA,rB)) &&
            (agy_str_eq(op1,"addq") || agy_str_eq(op1,"subq")) && w5c_is_imm(imm) &&
            U32.is_eq(r1,rB) && agy_str_eq(op2,"movq") && U32.is_eq(r2,rB) && U32.is_eq(r3,rA) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{op1,[imm,x188_reg(rA,64)]}},tail}},
        u => None{})
    case _: None{}

@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w4c_or_peep_opt(w5b_try_spill_bounce(rA,rB,rest,fnItems),
            q => w5c_try_alu64_bounce(rA,rB,rest,fnItems))))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)

@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{+i1,+tail}:
      nt_choose(List<&2,X187Parsed>,w5c_is_self_movl(i1,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5c_movzbl_copy(w5c_movq_dst(i1,rD),i0,i1,rest,tail,fnItems,acc))
    case Nil{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_cmp_if(isCmp: Bool, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isCmp:
    case True{}: w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_rr64_if(isMovq: Bool, +op: String, +rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5b_peep_movq(rA,rB,i0,rest,fnItems,acc)
    case False{}: w5c_bp_cmp_if(w5b_is_cmp(op),i0,rest,fnItems,acc)

@unsafe
def w5c_bp_mz_if(isMz: Bool, +rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMz:
    case True{}: w5b_peep_movzbl(rD,i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_ds_if(isMovq: Bool, +d1: U32, +rA: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5b_peep_apply(w4c_or_peep_opt(w5b_try_dup_square(d1,rA,rest,fnItems),
      v => w5c_try_load_bounce(d1,rA,rest,fnItems)),i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      w5c_bp_rr64_if(String.eq(op,"movq"),op,rA,rB,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      w5c_bp_mz_if(String.eq(op,"movzbl"),rD,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      w5c_bp_ds_if(String.eq(op,"movq"),d1,rA,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+l1},Nil{}}}}:
      w5b_peep_apply(w5b_try_jcc_jmp(op,l1,rest),i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,_}}:
      w5c_bp_cmp_if(w5b_is_cmp(op),i0,rest,fnItems,acc)
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+rest}: w5b_peep_inst(i0,rest,fnItems,acc)

@unsafe
def w5c_lbl_build_if(hasLbl: Bool, items: List<&2,X187Parsed>) -> W5BLblTrie:
  match hasLbl:
    case True{}: w5c_lbl_build(items)
    case False{}: W5BLNil{}

@unsafe
def w5c_copy_peep2(r1: W5BPeepOut, +hasLbl: Bool, f1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BPeepOut{False{},_}: f1
    case W5BPeepOut{True{},seq2}:
      +f2 = w5_flat_rev_seq(seq2,[])
      w5_flat_rev_seq(w5c_peep_seq(w5c_copy_peep_t(f2,w5c_lbl_build_if(hasLbl,f2),[],False{})),[])

@unsafe
def w7_leaf_shrink_if(isLeaf: Bool, +f3: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isLeaf:
    case False{}: w5_flat_rev_seq(w4c_peep_cfg(f3,f3,[]),[])
    case True{}:
      +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
      +f4 = w4_peep_flat([peep4],[])
      w4_peep_flat([w4_leaf_shrink(f4,peep4)],[])

@unsafe
def w7_peep_cfg2(changed: Bool, +b1b: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match changed:
    case False{}: b1b
    case True{}: w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])

@unsafe
def x199s_add(store: X191FrameStore, +rest: List<&2,X187Parsed>, +all: List<&2,X187Parsed>, +slots: KDef,
    +label: String, +found: List<&2,X191FrameStore>) -> List<&2,X191FrameStore>:
  match store:
    case X191FrameStore{+r,+disp}:
      nt_choose(List<&2,X191FrameStore>,(U32.is_eq(r,0) || U32.is_eq(r,11)) && U32.is_gt(U32.sub(0,disp),48),u =>
        nt_choose(List<&2,X191FrameStore>,x199s_window(rest,r,disp,label,24),v =>
          nt_choose(List<&2,X191FrameStore>,U32.is_eq(x199s_count(all,disp,0),2) && x199s_owned(slots,U32.sub(0,disp)),
            w => Con{X191FrameStore{r,disp},found},w => found),v => found),u => found)
    case _: found

@unsafe
def x191_select_plan(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> Maybe<&2,X191SelectPlan>:
  match yes no:
    case Con{P113DScalar{N111Set{+a,+ta,+va}},ar}
         Con{P113DScalar{N111Set{b,tb,+vb}},br}:
      nt_choose(Maybe<&2,X191SelectPlan>,agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          x191_select_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          x191_select_value(va) && x191_select_value(vb),u =>
        x191_select_ready(ta,va,vb,x191_select_names(a,x191_select_tail(ar,br,ta,a,3))),u => None{})
    case _ _: None{}

@unsafe
def x194_ps_scan(body: List<&2,P113DStmt>, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +current: String, +invert: Bool,
    +names: List<&2,String>, +fuel: U32) -> Maybe<&2,X194Select>:
  match body:
    case Con{P113DIf{condition,Nil{},Nil{}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x185_sf_source(condition,current),
        u => x194_ps_scan(rest,typ,op,left,right,current,invert,Con{current,names},U32.sub(fuel,1)),u => None{})
    case Con{P113DScalar{N111If{condition,Nil{},Nil{}}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x185_sf_source(condition,current),
        u => x194_ps_scan(rest,typ,op,left,right,current,invert,Con{current,names},U32.sub(fuel,1)),u => None{})
    case Con{P113DIf{condition,yes,no},rest}:
      x194_ps_finish(x191_select_plan(yes,no),condition,rest,typ,op,left,right,current,invert,names)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x194_ps_finish(x191_select_plan(x181_scalar_rows(yes),x181_scalar_rows(no)),condition,rest,typ,op,left,right,current,invert,names)
    case Con{P113DScalar{N111Set{+name,width,value}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x190_branch_width(width) &&
          Bool.not(x181_register_reserved(name)) && x185_sf_source(value,current),
        u => x194_ps_scan(rest,typ,op,left,right,name,invert,Con{name,names},U32.sub(fuel,1)),u => None{})
    case Con{P113DScalar{N111Bin{+name,width,operation,value,N111Const{1,0}}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x190_branch_width(width) &&
          Bool.not(x181_register_reserved(name)) && agy_str_eq(operation,"xor") && x185_sf_source(value,current),
        u => x194_ps_scan(rest,typ,op,left,right,name,Bool.not(invert),Con{name,names},U32.sub(fuel,1)),u => None{})
    case _: None{}

@unsafe
def w5_can_sink_tail(stmts: List<&2,P113DStmt>, +p: String, +n: String, +sawMid: Bool) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DAgain{vs},Nil{}}: sawMid && w5_vals_has(vs,p)
    case Con{st,rest}: w5_stmt_safe(st,p,n) && w5_can_sink_tail(rest,p,n,True{})

law w5_sink_body:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_try_sink_bin_r(+subStmt: P113DStmt, +p: String, +op: String, +n: String, r: N111Value,
    +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match r:
    case N111Const{1,0}:
      nt_choose(List<&2,P113DStmt>,
        agy_str_eq(op,"sub") && Bool.not(agy_str_eq(p,n)) &&
        Bool.not(x181_register_reserved(p)) && Bool.not(x181_register_reserved(n)) &&
        w5_can_sink_tail(rest,p,n,False{}),
        u => w5_sink_body(w5_insert_before_again(rest,subStmt)),
        u => Con{subStmt,w5_sink_body(rest)})
    case _: Con{subStmt,w5_sink_body(rest)}

@unsafe
def w5_try_sink_bin(+subStmt: P113DStmt, +p: String, +op: String, l: N111Value, r: N111Value,
    +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match l:
    case N111Local{+n}: w5_try_sink_bin_r(subStmt,p,op,n,r,rest)
    case _: Con{subStmt,w5_sink_body(rest)}

@unsafe
def w5_sink_scalar(+stmt: P113DStmt, sc: N111Stmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match sc:
    case N111Bin{p,_,op,l,r}: w5_try_sink_bin(stmt,p,op,l,r,rest)
    case _: Con{stmt,w5_sink_body(rest)}

@unsafe
def w5_sink_body(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{+sc},+rest}: w5_sink_scalar(P113DScalar{sc},sc,rest)
    case Con{P113DIf{cond,yes,no},rest}: Con{P113DIf{cond,w5_sink_body(yes),w5_sink_body(no)},w5_sink_body(rest)}
    case Con{h,rest}: Con{h,w5_sink_body(rest)}

def x198_perm_fast(+id: U32, +a: U32, +b: U32, +slow: String) -> X188Seq:
  x188_many([x198_perm_shape(6,id,slow),x198_perm_shape(2,id,slow),
    x188_i2("cmpq",x198_perm_reg(6),x198_perm_reg(2)),x188_i1("je",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x198_perm_reg(1)),
    x188_i2("andq",X187Imm{9,0},x198_perm_reg(1)),
    x188_i2("cmpq",X187Imm{9,0},x198_perm_reg(1)),x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x198_perm_reg(1)),
    x188_i2("addq",X187Imm{127,0},x198_perm_reg(1)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x198_perm_reg(1)),
    x188_i2("addq",X187Imm{51413504,0},x198_perm_reg(1)),
    x188_i2("movabsq",X187Imm{4294967295,255},x198_perm_reg(0)),
    x198_perm_bound(6,8,slow),x198_perm_bound(2,9,slow),
    x188_i2("movq",X187Mem{7,0},x198_perm_reg(10)),
    x188_i2("movq",x198_perm_slot(a),x198_perm_reg(0)),x188_i2("movq",x198_perm_slot(b),x198_perm_reg(11)),
    x188_i2("movq",x198_perm_reg(11),x198_perm_slot(a)),x188_i2("movq",x198_perm_reg(0),x198_perm_slot(b)),
    x188_i2("subq",X187Imm{24,0},x198_perm_reg(4)),
    x188_i2("movq",x198_perm_reg(6),X187Mem{4,0}),x188_i2("movq",x198_perm_reg(2),X187Mem{4,8}),
    x188_i2("movl",X187Imm{id,0},x188_reg(6,32)),x188_i2("movq",x198_perm_reg(4),x198_perm_reg(2)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),x188_i2("addq",X187Imm{24,0},x198_perm_reg(4)),x188_i0("ret")])

def x198_perm_wrapper(+symbol: String, +slow: String, id: U32, a: U32, b: U32) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},
    X188One{PLabel{symbol}},x198_perm_fast(id,a,b,slow),X188One{PSize{symbol}}])],""}

law x198o_eval:
  for body: List<&2,P113DStmt>
  for +env: List<&2,X198ABinding>
  for +fuel: String
  X198AState

@unsafe
def x198o_continue(body: List<&2,P113DStmt>, fuel: String, +state: X198AState) -> X198AState:
  match state:
    case X198AState{+valid,+env}: nt_choose(X198AState,valid,u => x198o_eval(body,env,fuel),u => state)

@unsafe
def x198o_branch(+condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +env: List<&2,X198ABinding>, +fuel: String) -> X198AState:
  nt_choose(X198AState,U32.is_eq(x198o_value(condition,env),1),u => x198o_join(x198o_eval(yes,env,fuel),x198o_eval(no,env,fuel)),u => X198AState{False{},[]})

@unsafe
def x198o_eval(body,env,fuel):
  match body:
    case Nil{}: X198AState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198AState,x190_branch_width(typ),u => x198o_eval(rest,Con{X198ABinding{name,nt_choose(U32,U32.is_eq(x198o_value(value,env),3) && U32.is_eq(p113k_width(typ),32),v => 0,v => x198o_value(value,env))},env},fuel),u => X198AState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198AState,x190_branch_width(typ) && x198n_op(op),u =>
        x198o_eval(rest,Con{X198ABinding{name,nt_choose(U32,agy_str_eq(op,"sub") && x185_sf_source(left,fuel) && x192_p_constant(right,1) && U32.is_eq(p113k_width(typ),64),v => 3,v => x198o_bin(typ,op,x198o_value(left,env),x198o_value(right,env)))},env},fuel),u => X198AState{False{},[]})
    case Con{P113DIf{condition,yes,no},rest}: x198o_continue(rest,fuel,x198o_branch(condition,yes,no,env,fuel))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}: x198o_continue(rest,fuel,x198o_branch(condition,x181_scalar_rows(yes),x181_scalar_rows(no),env,fuel))
    case _: X198AState{False{},[]}

@unsafe
def agy_la_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,agy_str_eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_la_detect(function: P113DFunction) -> String & String:
  match function:
    case P113DFunction{+name,Con{NC_Binding{_,aname,_},Con{NC_Binding{_,bname,_},Con{NC_Binding{_,rname,_},Con{NC_Binding{_,pname,_},Nil{}}}}},1,False{},body}:
      nt_choose(String & String,String.starts_with(name,"$p118.trmc.") &&
          agy_str_eq(rname,"p118_root") && agy_str_eq(pname,"p118_parent"),
        u => agy_la_match_body(body,Nil{},aname,bname),u => ("",""))
    case _: ("","")

# Zero-stack-frame in-place owned list/string append wrapper for TRMC worker:
# Args: %rdi=state, %rsi=a, %rdx=b, %rcx=p118_root, %r8=p118_parent
# Supports both tag==0x02 (unshared) and tag==0x82 with rc==1 (uniquely owned RFC)!
# Never mutates until SNil/Nil is reached, so any shared node (rc>=2) bails cleanly!
@unsafe
def agy_sh_cid(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,agy_str_eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_sh_streq_loop(+pfx: String, +l_true: String, +l_false: String, +l_bail: String,
    +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +l_lp = pfx ++ "_lp"
  +l_anil = pfx ++ "_an"
  +l_adir = pfx ++ "_ad"
  +l_bdir = pfx ++ "_bd"
  +l_schr = pfx ++ "_sc"
  x188_many([
    x188_label(l_lp),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_anil}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_false}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_adir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_adir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_bdir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_bdir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("orq",x188_reg(3,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jnz",X187Target{l_schr}),
    x188_i2("cmpl",x188_reg(3,32),x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false}),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_schr),
    agy_sh_unpack_chr(pfx ++ "_c1",l_bail,chr_cid),
    x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    agy_sh_unpack_chr(pfx ++ "_c2",l_bail,chr_cid),
    x188_i2("cmpl",x188_reg(13,32),x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false}),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_anil),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_false})])

@unsafe
def agy_sh_emit_streq(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32,
    +check_same: Bool, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_eq_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +l_true = pfx ++ "_tr"
  +l_false = pfx ++ "_fl"
  +l_bail = pfx ++ "_bl"
  +same_chk = nt_choose(X188Seq,check_same,
    u => x188_many([
      x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
      x188_i1("jne",X187Target{slow})]),
    u => X188Empty{})
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    same_chk,
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(12,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(9,64)),
    agy_sh_streq_loop(pfx,l_true,l_false,l_bail,scon,chr),
    agy_sh_epilogue_2(pfx,slow,l_true,l_false,l_bail,owned),
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_sh_emit_hash(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_hs_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +scon_chk = U32.add(131072,scon)
  +l_lp = pfx ++ "_lp"
  +l_dir = pfx ++ "_dr"
  +l_done = pfx ++ "_dn"
  +l_sk = pfx ++ "_sk"
  +done_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk}),
      x188_i1("pushq",x188_reg(3,64)),
      x188_i2("movl",x188_reg(1,32),x188_reg(3,32)),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_i2("movl",x188_reg(3,32),x188_reg(0,32)),
      x188_i1("popq",x188_reg(3,64)),
      x188_i0("ret"),
      x188_label(l_sk),
      x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
      x188_i0("ret")]),
    u => x188_many([
      x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
      x188_i0("ret")]))
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jnz",X187Target{slow}),
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(9,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(2,32),x188_reg(1,32)),
    x188_label(l_lp),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_done}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    agy_sh_unpack_chr(pfx ++ "_c",slow,chr),
    x188_i2("xorl",x188_reg(0,32),x188_reg(1,32)),
    x188_i2("movl",X187Imm{16777619,0},x188_reg(0,32)),
    x188_i2("imull",x188_reg(0,32),x188_reg(1,32)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_done),
    done_seq,
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_sh_match_ch(+pfx: String, +l_false: String, +l_bail: String, +scon_chk: U32, +chr: U32, +ch: U32) -> X188Seq:
  +l_dir = pfx ++ "_dr"
  x188_many([
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_false}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    agy_sh_unpack_chr(pfx ++ "_c",l_bail,chr),
    x188_i2("cmpl",X187Imm{ch,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false})])

@unsafe
def agy_sh_match_lit3(+pfx: String, +l_true: String, +l_false: String, +l_bail: String,
    +scon_chk: U32, +chr: U32, +c0: U32, +c1: U32, +c2: U32) -> X188Seq:
  x188_many([
    agy_sh_match_ch(pfx ++ "_0",l_false,l_bail,scon_chk,chr,c0),
    agy_sh_match_ch(pfx ++ "_1",l_false,l_bail,scon_chk,chr,c1),
    agy_sh_match_ch(pfx ++ "_2",l_false,l_bail,scon_chk,chr,c2),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_false})])

@unsafe
def x202k_calls(+pop: N111Stmt, +get: N111Stmt, rest: List<&2,N111Stmt>, scratch: String) -> Bool:
  match pop get:
    case N111Call{ignored,pt,po,pa} N111Call{saved,gt,go,ga}:
      agy_str_eq(scratch,"scratch") && agy_str_eq(ignored,"ignored") && x202k_index(pop,"p111_rt_stack_pop",1) &&
        x202k_index(get,"p111_rt_stack_get",0) && x204_source_tail(rest,saved)
    case _ _: False{}

@unsafe
def x202k_shape(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Alloca{scratch,2048,8},Con{pop,Con{get,rest}}}: x202k_calls(pop,get,rest,scratch)
    case _: False{}

def x198pw_machine(+prefix: String, +slow: String, +nodeCid: U32, +nodeHead: U32, +leafHi: U32, +falseHi: U32, +trueHi: U32) -> X188Seq:
  x188_many([
    x198pw_part0(slow),
    x198pw_part1(slow),
    x198pw_part2(prefix,falseHi,trueHi),
    x198pw_part3(prefix),
    x198pw_part4(prefix,leafHi),
    x198pw_part5(prefix),
    x198pw_part6(prefix,nodeHead),
    x198pw_part7(prefix),
    x198pw_part8(prefix),
    x198pw_part9(prefix,nodeCid),
    x198pw_part10(slow)])

# A closed positive-path proof for a pairwise tree zipper. Roles are bound to
# program declarations at proof time. Variable roles bind to checked binder
# identities; cached substitution hints on Var are not traversed.
@unsafe
def agy_zip_emit_wrapper(+symbol: String, +slow: String, leaf_cid: U32, node_cid: U32) -> X181Output:
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    agy_zip_machine(".Lagy_zip_" ++ symbol,slow,leaf_cid,node_cid),
    X188One{PSize{symbol}}])],""}

law agy_ro_emit_expr:
  for +e: KTerm
  for +rec_lbl: String
  for +bail_lbl: String
  for +tag: String
  for +inline_f0: Bool
  X188Seq

@unsafe
def agy_ro_emit_bin(+op: String, +left: KTerm, +right: KTerm, +rec_lbl: String, +bail_lbl: String, +tag: String, +inline_f0: Bool) -> X188Seq:
  +rb_bail = bail_lbl ++ "_p" ++ tag
  +rb_done = bail_lbl ++ "_d" ++ tag
  nt_choose(X188Seq,agy_str_eq(tg(right),"RoBin") || agy_str_eq(tg(right),"RoRec"),
    u => x188_many([
      agy_ro_emit_expr(left,rec_lbl,bail_lbl,tag ++ "l",inline_f0),
      x188_i1("pushq",x188_reg(3,64)),
      x188_i2("movl",x188_reg(0,32),x188_reg(3,32)),
      agy_ro_emit_expr(right,rec_lbl,rb_bail,tag ++ "r",inline_f0),
      agy_ro_emit_bin_op(op,3),
      x188_i1("popq",x188_reg(3,64)),
      x188_i1("jmp",X187Target{rb_done}),
      x188_label(rb_bail),
      x188_i1("popq",x188_reg(3,64)),
      x188_i1("jmp",X187Target{bail_lbl}),
      x188_label(rb_done)]),
    u => x188_many([
      agy_ro_emit_expr(left,rec_lbl,bail_lbl,tag ++ "l",inline_f0),
      x188_i2("movl",x188_reg(0,32),x188_reg(2,32)),
      agy_ro_emit_expr(right,rec_lbl,bail_lbl,tag ++ "r",inline_f0),
      agy_ro_emit_bin_op(op,2)]))

@unsafe
def agy_ro_emit_expr(e,rec_lbl,bail_lbl,tag,inline_f0):
  +t = tg(e)
  nt_choose(X188Seq,agy_str_eq(t,"RoConst"),
    u => x188_i2("movl",X187Imm{ix(e),0},x188_reg(0,32)),u =>
    nt_choose(X188Seq,agy_str_eq(t,"RoParamX"),
      v => x188_i2("movl",x188_reg(13,32),x188_reg(0,32)),v =>
      nt_choose(X188Seq,agy_str_eq(t,"RoField"),
        w => nt_choose(X188Seq,inline_f0 && U32.is_eq(ix(e),0),
          k => x188_i2("movl",x188_reg(6,32),x188_reg(0,32)),
          k => x188_i2("movl",X187Indexed{12,14,8,U32.mul(ix(e),8)},x188_reg(0,32))),w =>
        nt_choose(X188Seq,agy_str_eq(t,"RoRec"),
          z => x188_many([
            x188_i2("movq",X187Indexed{12,14,8,U32.mul(ix(e),8)},x188_reg(6,64)),
            x188_i1("call",X187Target{rec_lbl}),
            x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
            x188_i1("jne",X187Target{bail_lbl})]),
          z => nt_choose(X188Seq,agy_str_eq(t,"RoBin") && U32.is_eq(terms_len(ks(e)),2),
            q => agy_ro_emit_bin(nm(e),kid(e,0),kid(e,1),rec_lbl,bail_lbl,tag,inline_f0),
            q => X188Empty{})))))

@unsafe
def agy_ro_emit_arms(cases: List<&2,KTerm>, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: X188Empty{}
    case Con{+c,rest}:
      +lbl = prefix ++ "_c" ++ U32.show(idx)
      +rec_lbl = prefix ++ "_rec"
      +expr = kid(c,0)
      +inline_arm = nt_choose(X188Seq,U32.is_eq(qt(c),1),
        u => x188_many([
          x188_label(prefix ++ "_in" ++ U32.show(idx)),
          agy_ro_emit_expr(expr,rec_lbl,prefix ++ "_bail","i",True{}),
          x188_i0("ret")]),
        u => X188Empty{})
      +arm_code = nt_choose(X188Seq,U32.is_eq(ix(c),0),
        u => x188_many([
          x188_label(lbl),
          agy_ro_emit_expr(expr,rec_lbl,prefix ++ "_bail","0",False{}),
          x188_i0("ret")]),
        u => x188_many([
          inline_arm,
          x188_label(lbl),
          x188_i1("pushq",x188_reg(14,64)),
          x188_i2("movq",x188_reg(8,64),x188_reg(14,64)),
          x188_i2("subl",X187Imm{1,0},x188_reg(1,32)),
          agy_ro_emit_expr(expr,rec_lbl,lbl ++ "_b","0",False{}),
          x188_i2("addl",X187Imm{1,0},x188_reg(1,32)),
          x188_i1("popq",x188_reg(14,64)),
          x188_i0("ret"),
          x188_label(lbl ++ "_b"),
          x188_i2("addl",X187Imm{1,0},x188_reg(1,32)),
          x188_i1("popq",x188_reg(14,64)),
          x188_i0("ret")]))
      x188_cat(arm_code,agy_ro_emit_arms(rest,prefix,U32.inc(idx)))

@unsafe
def x198pw_emit_wrapper(+symbol: String,+slow: String,leaf: U32,+node: U32,no: U32,yes: U32) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    x198pw_machine(".Lp198pair_" ++ symbol,slow,node,U32.add(131072,node),U32.add(16777216,U32.mul(leaf,256)),
      U32.add(16777216,U32.mul(no,256)),U32.add(16777216,U32.mul(yes,256))),X188One{PSize{symbol}}])],""}

@unsafe
def agy_fl_emit_wrapper(+symbol: String, +slow: String, +warp_sym: String, +wn_sym: String,
    leaf_cid: U32, node_cid: U32) -> X181Output:
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    agy_fl_machine(".Lagy_fl_" ++ symbol,slow,warp_sym,wn_sym,leaf_cid,node_cid),
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_al_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,agy_str_eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

law x195t_body:
  for body: List<&2,P113DStmt>
  for +tables: List<&2,P126ITable>
  List<&2,P113DStmt>

@unsafe
def x195t_stmt(+stmt: P113DStmt, +tables: List<&2,P126ITable>) -> List<&2,P113DStmt>:
  match stmt:
    case P113DCall{[name],+target,[value]}:
      x195t_found(stmt,name,target,value,p126i_lookup(tables,target))
    case P113DIf{condition,yes,no}: [P113DIf{condition,x195t_body(yes,tables),x195t_body(no,tables)}]
    case _: [stmt]

@unsafe
def x195t_body(body,tables):
  match body:
    case Nil{}: []
    case Con{head,rest}: nt_append(P113DStmt,x195t_stmt(head,tables),x195t_body(rest,tables))

@unsafe
def x195t_when(enabled: Bool, +function: P113DFunction, +tables: List<&2,P126ITable>) -> P113DFunction:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      nt_choose(P113DFunction,enabled && U32.is_lt(p113i_size(body),4096) &&
          x195t_names(x181_param_names(params)) && x195t_clean_body(body) && p126i_calls(body,tables),
        u => P113DFunction{name,params,result,public,x195t_body(body,tables)},u => function)

# Each canonical table function still emits its original entry/forwarder. The
# extra readonly data exactly matches p126s_render and is emitted once here.
@unsafe
def x185_array_dispatch(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32) -> List<&2,N111Stmt>:
  x185_array_dispatch_ex(name,params,result,used,[])

# Semantic tokens describe only the certified modular recurrence. Zero means
# unknown/refusal. Names are arbitrary; metadata names come from the guarded
# p117 factory, never from matching a user function's spelling.
@unsafe
def agy_dp_emit_x86(+symbol: String, +slow: String, +heap_min: U32) -> X181Output:
  +p = ".Lagydp_" ++ symbol
  +miss = p ++ "_miss"
  +loop = p ++ "_loop"
  # Stack after 9 pushes (72 bytes) + 8-byte slot for j_u64 (total 80 bytes):
  #   0(%rsp)  = j_u64
  #   8(%rsp)  = saved %r9 (a)
  #  16(%rsp)  = saved %r8 (ai)
  #  24(%rsp)  = saved %rcx (j)
  #  32(%rsp)  = saved %rdx (n)
  #  40(%rsp)  = saved %r15
  #  48(%rsp)  = saved %r14
  #  56(%rsp)  = saved %r13
  #  64(%rsp)  = saved %r12
  #  72(%rsp)  = saved %rbx
  #  80(%rsp)  = return addr
  #  88(%rsp)  = b
  #  96(%rsp)  = prev
  # 104(%rsp)  = cur
  +code = x188_many([
    # Fast n == 0 check before pushing
    x188_i2("cmpq",X187Imm{0,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{p ++ "_nz"}),
    x188_i2("movq",x188_reg(9,64),X187Mem{6,0}),
    x188_i2("movq",X187Mem{4,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,8}),
    x188_i2("movq",X187Mem{4,24},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,16}),
    x188_i2("movq",X187Mem{4,16},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,24}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i0("ret"),
    x188_label(p ++ "_nz"),
    # Guard n <= 0x7fffffff and j_u64 + n <= 0xffffffff
    x188_i2("movabsq",X187Imm{2147483647,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(2,64)),
    x188_i1("ja",X187Target{slow}),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("addq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("ja",X187Target{slow}),
    # Save callee-saved + incoming regs
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(2,64)),
    x188_i1("pushq",x188_reg(1,64)),
    x188_i1("pushq",x188_reg(8,64)),
    x188_i1("pushq",x188_reg(9,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(10,32)),
    x188_i1("pushq",x188_reg(10,64)),
    # %r12 = j_u64 + n
    x188_i2("movq",x188_reg(0,64),x188_reg(12,64)),
    # Check & decode b -> %rbx, prev -> %r13, cur -> %r14
    agy_dp_check_arr(88,3,False{},heap_min,miss),
    agy_dp_check_arr(96,13,True{},heap_min,miss),
    agy_dp_check_arr(104,14,True{},heap_min,miss),
    # Non-aliasing: cur != prev && cur != b
    x188_i2("cmpq",x188_reg(13,64),x188_reg(14,64)),
    x188_i1("je",X187Target{miss}),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(14,64)),
    x188_i1("je",X187Target{miss}),
    # Setup loop registers:
    # %r15d = ai, %rcx = n, %r8d = diag = prev[j], %r9d = left = cur[j], %r11 = 0
    x188_i2("movl",X187Mem{4,16},x188_reg(15,32)),
    x188_i2("movq",X187Mem{4,32},x188_reg(1,64)),
    x188_i2("movl",X187Mem{13,0},x188_reg(8,32)),
    x188_i2("movl",X187Mem{14,0},x188_reg(9,32)),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    # Tight 17-instruction zero-spill 3-cycle-critical-path inner loop
    x188_label(loop),
    x188_i2("movl",X187Indexed{3,11,4,0},x188_reg(0,32)),
    x188_i2("cmpl",x188_reg(0,32),x188_reg(15,32)),
    x188_i1("setne",x188_reg(2,8)),
    x188_i2("movzbl",x188_reg(2,8),x188_reg(2,32)),
    x188_i2("addl",x188_reg(2,32),x188_reg(8,32)),
    x188_i2("movl",X187Indexed{13,11,4,4},x188_reg(0,32)),
    x188_i2("movl",x188_reg(0,32),x188_reg(2,32)),
    x188_i2("addl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("cmpl",x188_reg(8,32),x188_reg(2,32)),
    x188_i2("cmovael",x188_reg(8,32),x188_reg(2,32)),
    x188_i2("addl",X187Imm{1,0},x188_reg(9,32)),
    x188_i2("cmpl",x188_reg(2,32),x188_reg(9,32)),
    x188_i2("cmovael",x188_reg(2,32),x188_reg(9,32)),
    x188_i2("movl",x188_reg(9,32),X187Indexed{14,11,4,4}),
    x188_i2("movl",x188_reg(0,32),x188_reg(8,32)),
    x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{loop}),
    # Store (a, b, cur, prev) to (%rsi)
    x188_i2("movq",X187Mem{4,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,0}),
    x188_i2("movq",X187Mem{4,88},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,8}),
    x188_i2("movq",X187Mem{4,104},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,16}),
    x188_i2("movq",X187Mem{4,96},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,24}),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i0("ret"),
    # Miss: restore all incoming registers and jump to slow
    x188_label(miss),
    x188_i2("addq",X187Imm{8,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(9,64)),
    x188_i1("popq",x188_reg(8,64)),
    x188_i1("popq",x188_reg(1,64)),
    x188_i1("popq",x188_reg(2,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    code,X188One{PSize{symbol}}])],""}

@unsafe
def w5_lcu_check_param(+idx: U32, +pName: String, +nParams: U32, +body: List<&2,P113DStmt>) -> W5LcuCand:
  w5_lcu_check_scan_res(idx,pName,nParams,body,w5_lcu_scan_agains(body,[],idx,W5LcuScan{True{},False{},"",0}))

law w5_lcu_find_param:
  for params: List<&2,NC_Binding>
  for +idx: U32
  for +nParams: U32
  for +body: List<&2,P113DStmt>
  W5LcuCand

@unsafe
def w5_lcu_find_param_res(cand: W5LcuCand, rest: List<&2,NC_Binding>, +idx: U32, +nParams: U32, +body: List<&2,P113DStmt>) -> W5LcuCand:
  match cand:
    case W5LcuCandYes{i,pn,c,a}: W5LcuCandYes{i,pn,c,a}
    case W5LcuCandNo{}: w5_lcu_find_param(rest,U32.inc(idx),nParams,body)

@unsafe
def w5_lcu_find_param(params,idx,nParams,body):
  match params:
    case Nil{}: W5LcuCandNo{}
    case Con{NC_Binding{_,pName,_},rest}:
      w5_lcu_find_param_res(w5_lcu_check_param(idx,pName,nParams,body),rest,idx,nParams,body)

# Helpers for generating field names, bindings, stores, loads, and spliced lists
@unsafe
def agy_f32_get(env: KDef, +name: String) -> KDef:
  index_find(env,name,index_hash(name,2166136261),32)

@unsafe
def agy_f32_collect_opt(opt: Maybe<&2,KTerm>, cs: List<&2,U32>) -> List<&2,U32>:
  match opt:
    case None{}: cs
    case Some{e}: agy_f32_collect_c(e,cs)

@unsafe
def agy_f32_emit_obs2(obs: Maybe<&2,KTerm>, +cs: List<&2,U32>, +p: String) -> X188Seq:
  match obs:
    case None{}: X188Empty{}
    case Some{oe}:
      x188_many([
        agy_f32_emit_f2(oe,cs,2),
        x188_i2("movd",x188_xmm(2),x188_reg(2,32)),
        x188_i2("cmpl",X187Imm{1333788672,0},x188_reg(2,32)),
        x188_i1("jae",X187Target{p ++ "_oz"}),
        x188_i2("cvttss2siq",x188_xmm(2),x188_reg(2,64)),
        x188_i1("jmp",X187Target{p ++ "_od"}),
        x188_label(p ++ "_oz"),
        x188_i2("xorl",x188_reg(2,32),x188_reg(2,32)),
        x188_label(p ++ "_od")])

@unsafe
def agy_map_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,agy_str_eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_map_unpack_key(+prefix: String, +bail: String, +snil_hi: U32, +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +l_lp = prefix ++ "_uk_lp"
  +l_dir = prefix ++ "_uk_dr"
  +l_dn = prefix ++ "_uk_dn"
  x188_many([
    x188_i2("xorl",x188_reg(15,32),x188_reg(15,32)),
    x188_label(l_lp),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_dn}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(15,64)),
    x188_i1("jae",X187Target{bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(1,64)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{13,0,8,0},x188_reg(9,64)),
    x188_i2("movq",X187Mem{9,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{9,8},x188_reg(8,64)),
    agy_map_unpack_chr(prefix ++ "_ukc",bail,chr_cid),
    x188_i2("movl",x188_reg(0,32),X187Indexed{5,15,4,0}),
    x188_i2("addq",X187Imm{1,0},x188_reg(15,64)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_dn)])

# Shared bit(kbuf, %r15=klen, %rax=pos) -> %eax in {0,1}; clobbers %rcx, %rdx; jumps to bail if pos >= 2112
@unsafe
def agy_map_cmp_diff(+prefix: String, +eq_lbl: String, +diff_lbl: String, +bail: String,
    +snil_hi: U32, +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +chr_chk = U32.add(65536,chr_cid)
  +l_lp = prefix ++ "_cd_lp"
  +l_dir = prefix ++ "_cd_dr"
  +l_len = prefix ++ "_cd_ln"
  +l_msb = prefix ++ "_cd_mb"
  +l_dif = prefix ++ "_cd_df"
  x188_many([
    x188_i2("xorl",x188_reg(10,32),x188_reg(10,32)),
    x188_label(l_lp),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_len}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(1,64)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{13,0,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    agy_map_unpack_chr(prefix ++ "_cdc",bail,chr_cid),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(10,64)),
    x188_i1("je",X187Target{l_dif}),
    x188_i2("movl",X187Indexed{5,10,4,0},x188_reg(1,32)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{l_msb}),
    x188_i2("addq",X187Imm{1,0},x188_reg(10,64)),
    x188_i1("jmp",X187Target{l_lp}),
    # leaf_k hit SNil: equal iff ci == klen, else diff = ci * 33
    x188_label(l_len),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(10,64)),
    x188_i1("je",X187Target{eq_lbl}),
    x188_label(l_dif),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(0,64)),
    x188_i2("addq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{diff_lbl}),
    # Char mismatch: %eax = cx ^ cy != 0 -> off = 33 - msb32(%eax)
    x188_label(l_msb),
    x188_i2("movl",X187Imm{33,0},x188_reg(2,32)),
    x188_label(prefix ++ "_cd_m2"),
    x188_i2("subl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("shrl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jnz",X187Target{prefix ++ "_cd_m2"}),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(0,64)),
    x188_i2("addq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("addq",x188_reg(2,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{diff_lbl})])

@unsafe
def agy_map_set_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +mleaf_hi = U32.add(33554432,U32.mul(mleaf,256))
  +mnode_hi = U32.add(33554432,U32.mul(mnode,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_tip_root = prefix ++ "_tr"
  +l_desc = prefix ++ "_ds"
  +l_leaf = prefix ++ "_lf"
  +l_eq = prefix ++ "_eq"
  +l_diff = prefix ++ "_df"
  +l_sp_lp = prefix ++ "_sl"
  +l_sp_ok = prefix ++ "_so"
  +l_sp_b1 = prefix ++ "_s1"
  +l_sp_wr = prefix ++ "_sw"
  x188_many([
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[mleaf], !cid_hot[mnode]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{mleaf,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movl",X187Imm{mnode,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    # Prologue: 6 pushes (%rbp + 5) + sub $1320 -> 16B aligned; %rbp = %rsp
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(14,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(14,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(14,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(14,64)),
    # Load m, key, x from state->regs[0..2]
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,1280}),
    x188_i2("movq",X187Mem{12,48},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,1288}),
    x188_i2("movq",X187Mem{12,56},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{4,1296}),
    # Check if m == MTip{} (fast empty-map insert!)
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("je",X187Target{l_tip_root}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Descend map: %r8=cur, %r9=slot_ptr (0=root), %rbx=depth (0..64)
    x188_i2("movq",X187Mem{4,1280},x188_reg(8,64)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("xorl",x188_reg(3,32),x188_reg(3,32)),
    x188_label(l_desc),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{mleaf_chk,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(3,64)),
    x188_i1("jae",X187Target{l_bail}),
    # Extract loc, check loc >= HEAP_OFF
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    # Record path[depth] = {slot_ptr=%r9, pos=mem[loc+0]} at 256(%rsp + depth*16)
    x188_i2("movq",x188_reg(3,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{4,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(9,64),X187Indexed{5,11,1,256}),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Indexed{5,11,1,264}),
    x188_i2("addq",X187Imm{1,0},x188_reg(3,64)),
    # Compute bit(kbuf, klen, pos=%rax) -> %eax in {0,1}
    agy_map_bit_at(prefix ++ "_d",l_bail),
    # Next slot_ptr = &mem[loc + 1 + bit] = %r10 + 8 + bit*8
    x188_i2("leaq",X187Indexed{10,0,8,8},x188_reg(9,64)),
    x188_i2("movq",X187Mem{9,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Hit MTip at root: alloc MLeaf{key, x} from class-1 freelist (atOff=8, lenOff=264, words=2)
    x188_label(l_tip_root),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",X187Mem{4,1296},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,8}),
    x188_i2("movabsq",X187Imm{0,mleaf_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Hit MLeaf (%r8=leaf_term, %r9=leaf_slot_ptr, %rbx=depth)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save leaf_slot_ptr at 1304(%rsp) temporarily, leaf_ptr in %r8
    x188_i2("movq",x188_reg(9,64),X187Mem{4,1304}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(8,64)),
    # Compare kbuf[0..%r15) against leaf_k = (%r8)
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_eq,l_diff,l_bail,snil_hi,scon,chr),

    # Equal: replace value in-place! Save leaf_ptr in %rbx, old_v in %r15, overwrite (%rbx+8)=orig_x, sink orig_key & old_v
    x188_label(l_eq),
    x188_i2("movq",x188_reg(8,64),x188_reg(3,64)),
    x188_i2("movq",X187Mem{3,8},x188_reg(15,64)),
    x188_i2("movq",X187Mem{4,1296},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,8}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i2("movq",X187Mem{4,1280},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Unequal: %rax = diff. Check class-1 (atOff=8) AND class-2 (atOff=16) freelists non-empty BEFORE mutating!
    x188_label(l_diff),
    x188_i2("movq",X187Mem{12,8},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,8},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("movq",X187Mem{10,16},x188_reg(9,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jz",X187Target{l_bail}),
    # Save diff in %r8
    x188_i2("movq",x188_reg(0,64),x188_reg(8,64)),
    # Compute new_bit = bit(kbuf, klen, diff=%rax) -> %eax in {0,1}; save in %r15 (klen no longer needed!)
    agy_map_bit_at(prefix ++ "_n",l_bail),
    x188_i2("movl",x188_reg(0,32),x188_reg(15,32)),
    # Find splice_slot_ptr: first path[i].pos > diff (%r8), else leaf_slot_ptr (1304(%rsp))
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_label(l_sp_lp),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(1,64)),
    x188_i1("je",X187Target{l_sp_ok}),
    x188_i2("movq",x188_reg(1,64),x188_reg(2,64)),
    x188_i2("shlq",X187Imm{4,0},x188_reg(2,64)),
    x188_i2("movq",X187Indexed{5,2,1,264},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("ja",X187Target{prefix ++ "_sf"}),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jmp",X187Target{l_sp_lp}),
    x188_label(prefix ++ "_sf"),
    x188_i2("movq",X187Indexed{5,2,1,256},x188_reg(3,64)),
    x188_i1("jmp",X187Target{prefix ++ "_sa"}),
    x188_label(l_sp_ok),
    x188_i2("movq",X187Mem{4,1304},x188_reg(3,64)),
    # %rbx = splice_slot_ptr (0 if root!). Load old_sub into %r9:
    x188_label(prefix ++ "_sa"),
    x188_i2("testq",x188_reg(3,64),x188_reg(3,64)),
    x188_i1("jz",X187Target{prefix ++ "_sr"}),
    x188_i2("movq",X187Mem{3,0},x188_reg(9,64)),
    x188_i1("jmp",X187Target{prefix ++ "_al"}),
    x188_label(prefix ++ "_sr"),
    x188_i2("movq",X187Mem{4,1280},x188_reg(9,64)),
    # Pop MLeaf (class 1) -> %r11, MNode (class 2) -> %r10 (both verified non-empty above!)
    x188_label(prefix ++ "_al"),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    # Alloc MLeaf (class 1)
    x188_i2("movq",X187Mem{0,8},x188_reg(11,64)),
    x188_i2("leaq",X187Indexed{13,11,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{1,0}),
    x188_i2("movq",X187Mem{4,1296},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{1,8}),
    x188_i2("movabsq",X187Imm{0,mleaf_hi},x188_reg(2,64)),
    x188_i2("orq",x188_reg(2,64),x188_reg(11,64)),
    # Alloc MNode (class 2): %r11=new_leaf, %r9=old_sub, %r8=diff, %r15=new_bit
    x188_i2("movq",X187Mem{0,16},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,16}),
    x188_i2("subq",X187Imm{4,0},X187Mem{0,272}),
    x188_i2("movq",x188_reg(8,64),X187Mem{1,0}),
    x188_i2("testl",x188_reg(15,32),x188_reg(15,32)),
    x188_i1("jnz",X187Target{l_sp_b1}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,8}),
    x188_i2("movq",x188_reg(9,64),X187Mem{1,16}),
    x188_i1("jmp",X187Target{l_sp_wr}),
    x188_label(l_sp_b1),
    x188_i2("movq",x188_reg(9,64),X187Mem{1,8}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,16}),
    x188_label(l_sp_wr),
    x188_i2("movabsq",X187Imm{0,mnode_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("testq",x188_reg(3,64),x188_reg(3,64)),
    x188_i1("jz",X187Target{l_ret}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,0}),
    x188_i2("movq",X187Mem{4,1280},x188_reg(0,64)),

    # Return result_m (%rax) via p111_rt_return(state, &out, 1)
    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,1304}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,1304},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    # Bailout: zero heap mutations occurred! Restore %rdi=state and jump to slow
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_map_del_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_tip_root = prefix ++ "_tr"
  +l_desc = prefix ++ "_ds"
  +l_leaf = prefix ++ "_lf"
  +l_eq = prefix ++ "_eq"
  +l_miss = prefix ++ "_ms"
  +l_pfree = prefix ++ "_pf"
  +l_sink = prefix ++ "_sn"
  x188_many([
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[mnode]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{mnode,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    # Stack layout (328 bytes, 16B aligned after 6 pushes; %rbp = %rsp):
    #   0..255: kbuf[64]
    #   256: orig_m
    #   264: orig_key
    #   272: parent_loc (0 if root)
    #   280: parent_slot_ptr (0 if parent is root)
    #   288: sibling_term
    #   296: saved leaf_k / leaf_v
    #   304: out_slot
    x188_i2("subq",X187Imm{328,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(14,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(14,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(14,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,256}),
    x188_i2("movq",X187Mem{12,48},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,264}),
    # Check if m == MTip{}
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("je",X187Target{l_tip_root}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Descend: %r8=cur, %rbx=cur_slot_ptr (0=root); parent_loc=0
    x188_i2("movq",X187Mem{4,256},x188_reg(8,64)),
    x188_i2("xorl",x188_reg(3,32),x188_reg(3,32)),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,272}),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,280}),
    x188_label(l_desc),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{mleaf_chk,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save parent_loc=%r10, parent_slot_ptr=%rbx
    x188_i2("movq",x188_reg(10,64),X187Mem{4,272}),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,280}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    agy_map_bit_at(prefix ++ "_d",l_bail),
    # Child slot = &mem[loc + 1 + bit], sibling = mem[loc + 1 + (1 - bit)]
    x188_i2("leaq",X187Indexed{10,0,8,8},x188_reg(3,64)),
    x188_i2("xorl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("movq",X187Indexed{10,0,8,8},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{4,288}),
    x188_i2("movq",X187Mem{3,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Root MTip: sink key, return MTip
    x188_label(l_tip_root),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk0"),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Hit MLeaf (%r8=leaf_term)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save leaf_loc in %rbx, leaf_ptr in %r8
    x188_i2("movq",x188_reg(10,64),x188_reg(3,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_eq,l_miss,l_bail,snil_hi,scon,chr),

    # Key not found: sink orig_key, return orig_m unchanged!
    x188_label(l_miss),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_skm"),
    x188_i2("movq",X187Mem{4,256},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Key found! Check freelist room (ALC_LEN[1]+2 < 32768 and ALC_LEN[2]+4 < 32768) BEFORE mutating!
    x188_label(l_eq),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,264},x188_reg(10,64)),
    x188_i2("addq",X187Imm{2,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(10,64)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",X187Mem{0,272},x188_reg(11,64)),
    x188_i2("addq",X187Imm{4,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{l_bail}),
    # Load leaf_k (%r14, HEAP_OFF no longer needed!) and leaf_v (%r15, klen no longer needed!)
    x188_i2("movq",X187Mem{8,0},x188_reg(14,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(15,64)),
    # Free leaf_loc (%rbx) to class 1
    x188_i2("movq",X187Mem{0,8},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("movq",x188_reg(3,64),X187Mem{0,8}),
    x188_i2("movq",x188_reg(10,64),X187Mem{0,264}),
    # Check parent_loc (272(%rsp)): if 0 -> root was MLeaf -> result = MTip!
    x188_i2("movq",X187Mem{4,272},x188_reg(2,64)),
    x188_i2("testq",x188_reg(2,64),x188_reg(2,64)),
    x188_i1("jnz",X187Target{l_pfree}),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(3,64)),
    x188_i1("jmp",X187Target{l_sink}),
    # Free parent_loc (%rdx) to class 2 and splice sibling (288(%rsp))
    x188_label(l_pfree),
    x188_i2("leaq",X187Indexed{13,2,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{0,16},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,16}),
    x188_i2("movq",x188_reg(11,64),X187Mem{0,272}),
    x188_i2("movq",X187Mem{4,280},x188_reg(9,64)),
    x188_i2("movq",X187Mem{4,288},x188_reg(3,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jz",X187Target{l_sink}),
    x188_i2("movq",x188_reg(3,64),X187Mem{9,0}),
    x188_i2("movq",X187Mem{4,256},x188_reg(3,64)),
    # Sink orig_key (264(%rsp)), leaf_k (%r14), leaf_v (%r15); result_m is in %rbx!
    x188_label(l_sink),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk3"),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),

    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,304}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,304},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_map_get_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32, +tup: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +tup_hi = U32.add(33554432,U32.mul(tup,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_desc = prefix ++ "_ds"
  +l_ndir = prefix ++ "_nd"
  +l_leaf = prefix ++ "_lf"
  +l_ldir = prefix ++ "_ld"
  +l_hit = prefix ++ "_ht"
  +l_miss = prefix ++ "_ms"
  +l_mk = prefix ++ "_mk"
  x188_many([
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[tup]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{tup,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    # Prologue: 6 pushes + sub $328 -> 16B aligned; %rbp = %rsp
    # 0..255: kbuf; 256: orig_d; 264: orig_m; 272: orig_key; 280: out_slot
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{328,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    # Load d (40), m (48), key (56)
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,256}),
    x188_i2("movq",X187Mem{12,48},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{4,264}),
    x188_i2("movq",X187Mem{12,56},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,272}),
    # Check m == MTip{}
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(1,64)),
    x188_i1("je",X187Target{l_miss}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Read-only descent (supports both TAG_CTR and RFC|TAG_CTR and static maps!)
    x188_i2("movq",X187Mem{4,264},x188_reg(8,64)),
    x188_label(l_desc),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_miss}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{mleaf_chk,0},x188_reg(0,32)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpl",X187Imm{mnode_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(8,64)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jz",X187Target{l_ndir}),
    x188_i2("movq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_label(l_ndir),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    agy_map_bit_at(prefix ++ "_g",l_bail),
    x188_i2("movq",X187Indexed{10,0,8,8},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Leaf reached: unwrap RFC if needed, compare leaf_k against kbuf
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(8,64)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jz",X187Target{l_ldir}),
    x188_i2("movq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_label(l_ldir),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{3,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_hit,l_miss,l_bail,snil_hi,scon,chr),

    # Hit: check leaf_v is trivial (< 0x0200000000000000) and class-1 freelist non-empty
    x188_label(l_hit),
    x188_i2("movq",X187Mem{3,8},x188_reg(15,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    # Sink orig_key and orig_d, then build Tuple{orig_m, %r15}
    x188_i2("movq",X187Mem{4,272},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",X187Mem{4,256},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i1("jmp",X187Target{l_mk}),

    # Miss: check class-1 freelist non-empty, sink orig_key, build Tuple{orig_m, orig_d}
    x188_label(l_miss),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("movq",X187Mem{4,272},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk3"),
    x188_i2("movq",X187Mem{4,256},x188_reg(15,64)),

    # Allocate Tuple{orig_m, %r15} from class-1 freelist
    x188_label(l_mk),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,264},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",x188_reg(15,64),X187Mem{11,8}),
    x188_i2("movabsq",X187Imm{0,tup_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),

    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,280}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,280},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def x187_e_modrm(+legacy: U32, +codes: List<&2,U32>, wide: Bool, +reg: U32, +operand: X187Operand,
    force: Bool, +tail: List<&2,U32>, offset: U32) -> X187Encoded:
  +prefix = nt_append(U32,x187_e_prefix(legacy,wide,reg,operand,force),codes)
  x187_e_finish(prefix,tail,x187_e_address(operand,reg,U32.add(offset,nt_count(U32,prefix)),nt_count(U32,tail)))

@unsafe
def x187_e_mov_immediate(+dst: X187Operand, +lo: U32, +hi: U32, +width: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,width,False{}),u => x187_e_reg_immediate(dst,lo,hi,width),u =>
    nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),v =>
      x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),w => 198,w => 199)],U32.is_eq(width,64),0,dst,
        False{},x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),w => 1,w => 4)),offset),v => x187_e_error()))

@unsafe
def x187_e_alu(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 128,v => 129)],U32.is_eq(width,64),ext,dst,
          x187_e_byte(dst),x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),v => 1,v => 4)),offset),u => x187_e_error())
    case _:
      +code = U32.add(U32.mul(ext,8),nt_choose(U32,U32.is_eq(width,8),u => 0,u => 1))
      nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[code],U32.is_eq(width,64),x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u =>
      nt_choose(X187Encoded,x187_e_rm(src,width,False{}) && x187_e_reg(dst,width,False{}),u =>
        x187_e_modrm(0,[U32.add(code,2)],U32.is_eq(width,64),x187_e_index(dst),src,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error()))

@unsafe
def x187_e_test(+src: X187Operand, +dst: X187Operand, +width: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
    x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 132,v => 133)],U32.is_eq(width,64),
      x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error())

@unsafe
def x187_e_shift(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,0}:
      nt_choose(X187Encoded,U32.is_le(lo,255) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(prefix,[193],U32.is_eq(width,64),ext,dst,False{},[lo],offset),u => x187_e_error())
    case X187Reg{1,8,False{}}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(prefix,[211],U32.is_eq(width,64),ext,dst,False{},[],offset),u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_e_imul(+src: X187Operand, +dst: X187Operand, +width: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[105],U32.is_eq(width,64),x187_e_index(dst),dst,False{},x187_e_le(lo,4),offset),u => x187_e_error())
    case _:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) && x187_e_rm(src,width,False{}),u =>
        x187_e_modrm(0,[15,175],U32.is_eq(width,64),x187_e_index(dst),src,False{},[],offset),u => x187_e_error())

@unsafe
def x187_e_sse(+src: X187Operand, +dst: X187Operand, legacy: U32, code: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,128,True{}),u =>
    x187_e_modrm(legacy,[15,code],False{},x187_e_index(dst),src,False{},[],offset),u => x187_e_error())

@unsafe
def x187_e_movd(+src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,32,False{}),u =>
    x187_e_modrm(102,[15,110],False{},x187_e_index(dst),src,False{},[],offset),u =>
  nt_choose(X187Encoded,x187_e_reg(src,128,True{}) && x187_e_rm(dst,32,False{}),u =>
    x187_e_modrm(102,[15,126],False{},x187_e_index(src),dst,False{},[],offset),u => x187_e_error()))

@unsafe
def w5c_es_f5(ok: Bool, +operand: X187Operand, +code: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f6(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f11(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f12(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f18(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,183],False{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def x191cm_pair(+src: X187Operand, +dst: X187Operand, +width: U32, +code: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,(U32.is_eq(width,32) || U32.is_eq(width,64)) &&
      U32.is_ge(code,64) && U32.is_le(code,79) &&
      x187_e_reg(dst,width,False{}) && x187_e_rm(src,width,False{}),u =>
    x187_e_modrm(0,[15,code],U32.is_eq(width,64),x187_e_index(dst),src,False{},[],offset),
    u => x187_e_error())

law x187_elf_layout_step:
  for +head: X187ElfSection
  for +rest: List<&2,X187ElfSection>
  for +layout: X187ElfLayout
  X187ElfLayout

@unsafe
def x187_elf_layout(sections: List<&2,X187ElfSection>, layout: X187ElfLayout) -> X187ElfLayout:
  match sections:
    case Nil{}: layout
    case Con{head,rest}: x187_elf_layout_step(head,rest,layout)

@unsafe
def x201e_layout_bytes(bytes: List<&2,U32>, +size: U32, body: List<&2,U32>,
    +start: U32, meta: X187ElfSection, rest: List<&2,X187ElfSection>, headers: List<&2,U32>) -> X187ElfLayout:
  match bytes:
    case Nil{}:
      x187_elf_layout(rest,X187ElfLayout{U32.add(start,size),body,
        nt_reverse(U32,x187_elf_section_header(meta,start,size),headers)})
    case Con{a,Con{b,Con{c,Con{d,more}}}}:
      x201e_layout_bytes(more,U32.add(size,4),Con{d,Con{c,Con{b,Con{a,body}}}},start,meta,rest,headers)
    case Con{a,more}:
      x201e_layout_bytes(more,U32.inc(size),Con{a,body},start,meta,rest,headers)

@unsafe
def x187_elf_layout_step(head, rest, layout):
  match head layout:
    case X187ElfSection{name,kind,flags,+alignment,entry,link,info,bytes} X187ElfLayout{+offset,body,headers}:
      +start = x187_elf_align(offset,alignment)
      x201e_layout_bytes(bytes,0,x187_elf_zero(U32.sub(start,offset),body),start,
        X187ElfSection{name,kind,flags,alignment,entry,link,info,[]},rest,headers)

@unsafe
def x187_elf_finish(layout: X187ElfLayout) -> X187ObjectResult:
  match layout:
    case X187ElfLayout{+offset,body,headers}:
      +sectionOffset = x187_elf_align(offset,8)
      X187ObjectResult{x187_elf_cat(x187_elf_header(sectionOffset),
        nt_reverse(U32,body,x187_elf_zero(U32.sub(sectionOffset,offset),nt_reverse(U32,headers,[])))),""}

@unsafe
def w7_elf_sections_emit(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rp: W7RelocParts) -> X187ObjectResult:
  match rp:
    case W7RelocParts{r1,+n1,r2,+n2,r3,+n3}:
      +shstr = nt_reverse(U32,x187_elf_ascii(
        "\0.text\0.rodata\0.data\0.rela.text\0.rela.rodata\0.rela.data\0.symtab\0.strtab\0.shstrtab\0.note.GNU-stack\0",[]),[])
      +shstrSize : U32 = 98
      +symSize = U32.mul(count,24)
      +o1 = x187_elf_align(64,16)
      +e1 = U32.add(o1,ts)
      +o2 = x187_elf_align(e1,8)
      +e2 = U32.add(o2,rs)
      +o3 = x187_elf_align(e2,8)
      +e3 = U32.add(o3,ds)
      +o4 = x187_elf_align(e3,8)
      +e4 = U32.add(o4,n1)
      +o5 = x187_elf_align(e4,8)
      +e5 = U32.add(o5,n2)
      +o6 = x187_elf_align(e5,8)
      +e6 = U32.add(o6,n3)
      +o7 = x187_elf_align(e6,8)
      +e7 = U32.add(o7,symSize)
      +o8 = e7
      +e8 = U32.add(o8,stringSize)
      +o9 = e8
      +e9 = U32.add(o9,shstrSize)
      +o10 = e9
      +shOff = x187_elf_align(o10,8)
      +shdrs = x187_elf_zero(64,
        w7_shdr(1,1,6,o1,ts,0,0,16,0,
        w7_shdr(7,1,2,o2,rs,0,0,8,0,
        w7_shdr(15,1,3,o3,ds,0,0,8,0,
        w7_shdr(21,4,0,o4,n1,7,1,8,24,
        w7_shdr(32,4,0,o5,n2,7,2,8,24,
        w7_shdr(45,4,0,o6,n3,7,3,8,24,
        w7_shdr(56,2,0,o7,symSize,8,firstGlobal,8,24,
        w7_shdr(64,3,0,o8,stringSize,0,0,1,0,
        w7_shdr(72,3,0,o9,shstrSize,0,0,1,0,
        w7_shdr(82,1,0,o10,0,0,0,1,0,[])))))))))))
      +t10 = x187_elf_zero(U32.sub(shOff,o10),shdrs)
      +t9 = x187_elf_cat(shstr,t10)
      +t8 = nt_reverse(U32,strings,t9)
      +t7 = nt_reverse(U32,table,t8)
      +t6 = nt_reverse(U32,r3,x187_elf_zero(U32.sub(o7,e6),t7))
      +t5 = nt_reverse(U32,r2,x187_elf_zero(U32.sub(o6,e5),t6))
      +t4 = nt_reverse(U32,r1,x187_elf_zero(U32.sub(o5,e4),t5))
      +t3 = x187_elf_cat(data,x187_elf_zero(U32.sub(o4,e3),t4))
      +t2 = x187_elf_cat(rodata,x187_elf_zero(U32.sub(o3,e2),t3))
      +t1 = x187_elf_cat(text,x187_elf_zero(U32.sub(o2,e1),t2))
      X187ObjectResult{x187_elf_cat(x187_elf_header(shOff),x187_elf_zero(U32.sub(o1,64),t1)),""}

@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      match section:
        case 1: w7_bb_apply(1,ts,w7_rev_count(bytes,t,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case 2: w7_bb_apply(2,rs,w7_rev_count(bytes,r,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case 3: w7_bb_apply(3,ds,w7_rev_count(bytes,d,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case _: x187_build_error("invalid object section",build)

# Symbol fields: arity=section, templates=value, typ.id=size, typ.quant=kind,
# native=global, unsafe=defined. Every name is entered once, definitions may
# follow references. Duplicate definitions and unresolved local labels fail.
@unsafe
def x202e_plan(sections: List<&2,X187ElfSection>, +offset: U32, parts: List<&2,List<&2,U32>>, headers: List<&2,U32>) -> IO(U32):
  match sections:
    case Nil{}:
      +shoff = x187_elf_align(offset,8)
      x202e_open(Con{x187_elf_header(shoff),nt_reverse(List<&2,U32>,parts,
        [x187_elf_zero(U32.sub(shoff,offset),[]),nt_reverse(U32,headers,[])])})
    case Con{+section,rest}:
      match section:
        case X187ElfSection{name,kind,flags,+alignment,entry,link,info,+bytes}:
          +start = x187_elf_align(offset,alignment)
          +size = nt_count(U32,bytes)
          x202e_plan(rest,U32.add(start,size),Con{bytes,Con{x187_elf_zero(U32.sub(start,offset),[]),parts}},
            nt_reverse(U32,x187_elf_section_header(section,start,size),headers))

@unsafe
def x202t_plan(+sections: List<&2,X187ElfSection>, sizes: List<&2,U32>, +offset: U32,
    parts: List<&2,List<&2,U32>>, headers: List<&2,U32>) -> IO(U32):
  match sections sizes:
    case Con{X187ElfSection{name,kind,flags,+alignment,entry,link,info,bytes},rest} Con{+size,sizesRest}:
      +start = x187_elf_align(offset,alignment)
      header = x187_elf_section_header(X187ElfSection{name,kind,flags,alignment,entry,link,info,[]},start,size)
      x202t_plan(rest,sizesRest,U32.add(start,size),Con{bytes,Con{x187_elf_zero(U32.sub(start,offset),[]),parts}},
        nt_reverse(U32,header,headers))
    case _ _: x202e_plan(sections,offset,parts,headers)



@unsafe
def w8_relocate_cursor(cursor: P134Cursor, +fid_base: U32, +mod_name: String) -> P134Cursor:
  match cursor:
    case P134Private{fns,ctx,next}:
      P134Private{fns,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Legacy{es,ctx,next}:
      P134Legacy{es,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Public{segs,ctx,next}:
      P134Public{segs,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Tables{tables}:
      P134Tables{Con{P111QData{"p111_mod_" ++ mod_name ++ "_fid_base",8,True{},[P111QLong{fid_base,0}]},
        w8_relocate_tables(tables,fid_base,mod_name)}}
    case other: other


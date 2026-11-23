# Module m05b (K=14 acyclic topological split of wave12_unified/compiler.bend)
# defs=374 laws=36 sccs=298 deps=[m00a,m00b,m01,m02,m03,m04,m05a] cross_imports=457 fid_base=30000..33199

law dead_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/check/kernel.bend:216
law mat_goal:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:252
law mat_goal_head:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:269
law tele_quantities_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:305
law tele_tip_head:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:342
law env_tele_fill_eager:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  KTerm

# Module: src/check/env-telescope.bend:92
law sp_keys:
  for +ts: List<&2, KTerm>
  String

# Module: src/check/specialize.bend:18
law base_prefix_patch:
  for +defs: List<&2,KDef>
  for +patches: List<&2,KDef>
  List<&2,KDef>

# Module: src/check/prefix-state.bend:80
law base_prefix_deltas:
  for +defs: List<&2,KDef>
  for +raw: List<&2,KDef>
  List<&2,KDef>

# Module: src/check/annotate.bend:5
law f_all_body:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +a: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:66
law f_tuple:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:75
law f_equation_type:
  for +a: KTerm
  for +b: KTerm
  for +neg: Bool
  for +opBegin: U32
  for +opEnd: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:104
law fpe_message:
  for +source: String
  for +offset: U32
  for +end: U32
  for +error: KTerm
  for +observed: String
  String

# Module: src/front/parser.bend:554
law f_namespace_operator:
  for +head: KTerm
  for +input: FInput
  Bool

# Module: src/front/parallel.bend:3
law f_graph_aliases:
  for +imports: List<&2, KTerm>
  for +source: FSource
  for +sources: List<&2,FSource>
  for +root: String
  List<&2, KTerm>

# Module: src/load/graph.bend:66
law j_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/back/common/queries.bend:27
law j_type_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +key: String
  KTerm

# Module: src/back/common/queries.bend:38
law j_specialize:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:134
law j_literal_provenance:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +literal: String
  String

# Module: src/back/js/validate.bend:11
law j_layout_array_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  Bool

# Module: src/back/js/validate.bend:269
law nc_live_count_head:
  for +book: List<&2, KDef>
  for +head: KTerm
  for +left: U32
  U32

# Erasure consumes annotate_book output. Type annotations determine erased
# arguments, constructor fields, lambda binders, and match-field arities.

# Module: src/back/native/erase.bend:10
@unsafe
def core_literal_type(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), nm(t)) && List.is_empty(&2, String, rm(ty)) && db(lookup(book, nm(t)))

# Module: src/core/term.bend:529
law index_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

law index_insert_legacy:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

@unsafe
def w5_idx_ins_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, index_insert(left, d, hash, mask), right)
    case False{}: index_node(stored, split, left, index_insert(right, d, hash, mask))

@unsafe
def w5_idx_ins_split(doJoin: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match doJoin:
    case True{}: index_join(tree, d, hash, mask)
    case False{}: w5_idx_ins_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash, mask)

@unsafe
def w5_idx_ins_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match isZero:
    case True{}: index_insert_legacy(tree, d, hash, mask)
    case False{}: w5_idx_ins_split(Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:203
@unsafe
def index_insert(tree, d, hash, mask):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      w5_idx_ins_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      w5_idx_ins_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:224
@unsafe
def w7_br_8(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_node(da(tree), dx(tree), index_insert(index_child(tree, False{}), d, hash, mask), index_child(tree, True{}))
    case False{}:
      index_node(da(tree), dx(tree), index_child(tree, False{}), index_insert(index_child(tree, True{}), d, hash, mask))

@unsafe
def w7_br_9(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_leaf(d, hash, dc(tree))
    case False{}:
      w7_br_8(U32.is_eq(U32.and(hash, dx(tree)), 0), tree, d, hash, mask)

@unsafe
def w7_br_10(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_join(tree, d, hash, mask)
    case False{}:
      w7_br_9(U32.is_eq(dx(tree), 0), tree, d, hash, mask)

@unsafe
def index_insert_legacy(tree, d, hash, mask):
  w7_br_10(Bool.not(U32.is_eq(mask, 0)) && (U32.is_eq(dx(tree), 0) || U32.is_lt(mask, dx(tree))), tree, d, hash, mask)

# Module: src/core/index.bend:239
@unsafe
def w7_ctor_exists_hit(isAbs: Bool, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAbs:
    case True{}:
      w7_ctor_exists_linear(rest, name)
    case False{}:
      True{}

@unsafe
def w7_ctor_exists_adt(isAdt: Bool, +h: KDef, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAdt:
    case True{}:
      w7_ctor_exists_hit(p88_string_eq(dk(lookup(dc(h), name)), "Absent"), rest, name)
    case False{}:
      w7_ctor_exists_linear(rest, name)

@unsafe
def w7_ctor_exists_linear(+ds: List<&2, KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      w7_ctor_exists_adt(p88_string_eq(dk(h), "ADT"), h, rest, name)

@unsafe
def w7_ctor_exists_tail(+tail: List<&2, KDef>, +rest: List<&2, KDef>, +name: String) -> Bool:
  match tail:
    case Nil{}:
      w7_ctor_exists_linear(rest, name)
    case Con{ctors, _}:
      Bool.not(p88_string_eq(dk(index_find(ctors, name, index_hash(name, 2166136261), 32)), "Absent"))

@unsafe
def book_put_many_cache_name(+cache: KDef, +rest: List<&2,KDef>, +name: String) -> Bool:
  w7_br_12(p88_string_eq(name, ""), cache, rest, name)

# Module: src/core/index.bend:461
@unsafe
def book_put_many_cache_valid(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, more}:
      kc(Bool, book_put_many_cache_name(cache, rest, dn(d)),
        u => book_put_many_cache_valid(cache, rest, more), u => False{})

# Module: src/core/index.bend:469
@unsafe
def g_wnf(
  +book: List<&2, KDef>,
  +st: GState,
  +t: KTerm,
) -> GResult:
  g_eval(book, st, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{})

# Module: src/core/graph.bend:335
@unsafe
def w7_br_94(w7_c: Bool, +book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  match w7_c:
    case True{}:
      kr_parent(book, name)
    case False{}:
      d

@unsafe
def kp_escape(
  +n: U32,
  +quote: U32,
) -> String:
  w7_br_108(U32.is_eq(n, 10), n, quote)

# Module: src/core/pretty.bend:366
@unsafe
def ctx_dead(
  +book: List<&2, KDef>,
  +ctx: List<&2, KTerm>,
) -> Bool:
  match ctx:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, U32.is_eq(qt(h), 0), u => ctx_dead(book, t), u => dead_type(book, wnf(book, kid(h, 0))) || ctx_dead(book, t))

# Module: src/check/kernel.bend:821
@unsafe
def dead_type(book, ty):
  p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT") && defs_empty(remaining(dc(lookup(book, nm(ty))), rm(ty)))

# Module: src/check/kernel.bend:825
@unsafe
def w7_br_180(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +a: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      dg_bad_detail(cw(e), "nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)

@unsafe
def mat_rest(
  +book: List<&2, KDef>,
  +t: KTerm,
  +a: KTerm,
) -> KTerm:
  w7_br_184(Bool.not(p98_tag_eq(kid(t, 1), "Mat")) && defs_empty(remaining(dc(lookup(book, nm(a))), Con{nm(t), rm(a)})), t)

# Module: src/check/kernel.bend:855
@unsafe
def w7_br_185(w7_c: Bool, +book: List<&2, KDef>, +goal: KTerm, +tel: KTerm, +n: U32, +name: String, +xs: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      subst(kid(goal, 1), ix(goal), kt("Ctr", name, 0, 0, norm_join(xs, Nil{})))
    case False{}:
      mat_goal_head(book, goal, wnf(book, tel), n, name, xs)

@unsafe
def mat_goal(book, goal, tel, n, name, xs):
  w7_br_185(U32.is_eq(n, 0), book, goal, tel, n, name, xs)

# Module: src/check/kernel.bend:859
@unsafe
def mat_goal_head(book, goal, tel, n, name, xs):
  all(kc(U32, U32.is_eq(qt(tel), 0), u => 0, u => kc(U32, U32.is_eq(qt(tel), 1), u => qt(goal), u => qadd(qt(goal), qt(goal)))), nm(tel), ix(tel), kid(tel, 0), mat_goal(book, goal, kid(tel, 1), U32.sub(n, 1), name, norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})))

# Module: src/check/kernel.bend:863
@unsafe
def tele_quantities(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => tele_quantities_head(book, wnf(book, ty), n))

# Module: src/check/kernel.bend:900
@unsafe
def tele_quantities_head(book, ty, n):
  Con{qua(kc(U32, p98_tag_eq(ty, "All"), u => qt(ty), u => 1)), tele_quantities(book, kid(ty, 1), U32.sub(n, 1))}

# Module: src/check/kernel.bend:904
@unsafe
def signature_mode(
  +d: KDef,
  +later: List<&2, KDef>,
) -> KDef:
  w7_br_190(p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent"), d, later)

# Module: src/check/kernel.bend:941
@unsafe
def tele_tip(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  tele_tip_head(book, wnf(book, t))

# Module: src/check/kernel.bend:1037
@unsafe
def w7_br_202(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      tele_tip(book, kid(t, 1))
    case False{}:
      t

@unsafe
def tele_tip_head(book, t):
  w7_br_202(p98_tag_eq(t, "All"), book, t)

# Module: src/check/kernel.bend:1041
@unsafe
def kw_restore_definition(+world: KWorld, +d: KDef, +r: KChecking) -> KChecking:
  w7_br_220(good(r) && U32.is_gt(dx(d), 0), world, r)

# Module: src/check/kernel.bend:1252
@unsafe
def kw_floor_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_max_walk(saved, norm_book_bound(kw_book(world))))

# Module: src/check/kernel.bend:1380
@unsafe
def kw_temp_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_book_bound(kw_book(world)))

# Module: src/check/kernel.bend:1394
@unsafe
def w7_br_244(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      env_tele_fill_eager(book, subst(kid(tel, 1), ix(tel), h), rest)
    case False{}:
      {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def env_tele_fill_eager_head(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  w7_br_244(p98_tag_eq(tel, "All"), book, tel, h, rest)

# Module: src/check/env-telescope.bend:68
@unsafe
def env_tele_fill_eager(book, tel, args):
  match args:
    case Nil{}: tel
    case Con{h, rest}: env_tele_fill_eager_head(book, wnf(book, tel), h, rest)

# Module: src/check/env-telescope.bend:74
@unsafe
def sp_keys(ts):
  match ts:
    case Nil{}: ""
    case Con{head, rest}: term_key(head) ++ kc(String, List.is_empty(&2, KTerm, rest), u => "", u => "\n" ++ sp_keys(rest))

# Module: src/check/specialize.bend:142
@unsafe
def sp_live_ref(+world: KWorld, +head: KTerm, +name: String, +consumed: U32) -> KChecking:
  KChecking{KTerm{"Ref", name, ix(head), qt(head), ks(head), rm(head), kb(head), ke(head)}, dt(lookup(kw_book(world), name)), Nil{}, "", world, consumed}

# Module: src/check/specialize.bend:367
@unsafe
def base_prefix_deltas(defs, raw):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, prefix_state_exact_def(d, lookup(raw, dn(d))),
      u => base_prefix_deltas(rest, raw), u => Con{d, base_prefix_deltas(rest, raw)})

# Module: src/check/prefix-state.bend:97
@unsafe
def base_prefix_patch(defs, patches):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, p88_string_eq(dk(lookup(patches, dn(d))), "Absent"), u => d, u => lookup(patches, dn(d))), base_prefix_patch(rest, patches)}

# Module: src/check/prefix-state.bend:103
@unsafe
def base_prefix_closed(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, base_prefix_closed_terms(Con{dt(d), Con{dv(d), Nil{}}}, context) && base_prefix_closed(dc(d), context), u => base_prefix_closed(rest, context), u => False{})

# Module: src/check/prefix-state.bend:126
@unsafe
def w7b_wnf_go(fast: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match fast:
    case True{}: t
    case False{}: wnf(book, t)

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
def f_context_constructor(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_context_constructor_done(term, input, f_context_resolve_table(k_with_span(term, f_previous_end(input), f_previous_end(input)), scope, True{}))

# Module: src/front/contextual.bend:173
@unsafe
def f_context_mark_known(+term: KTerm, +syntax: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  w7_br_313(f_context_stop(resolved), term, syntax, resolved, definition, input)

# Module: src/front/contextual.bend:531
@unsafe
def f_all_body(name, id, q, exi, a, p):
  match p:
    case FParsed{b, ts}:
      FParsed{f_choose(KTerm, f_context_stop(b), u => b, u => f_choose(KTerm, exi, u => f_app(kt("Ref", f_context_own("Exists", ts, False{}), 0, 1, Nil{}), [a, k_lam(name, id, q, [b], 0, 0, False{})]), u => kt("All", name, id, q, [a, b]))), ts}

# Module: src/front/parser.bend:324
@unsafe
def f_tuple(n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{f_choose(KTerm, f_context_stop(m), u => m, u => kt("Ctr", f_context_own("Tuple", ts, True{}), 0, 1, [n, m])), ts}

# Module: src/front/parser.bend:351
@unsafe
def f_list(
  +p: FParsed,
) -> FParsed:
  match p:
    case FParsed{+n, ts}:
      FParsed{f_choose(KTerm, f_eq(tg(n), "Error"), u => n, u => f_list_nodes(ks(n), f_context_own("Con", ts, True{}), f_context_own("Nil", ts, True{}))), ts}

# Module: src/front/parser.bend:359
@unsafe
def f_equation_type(a, b, neg, opBegin, opEnd, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{f_choose(KTerm, neg, u => kt("All", "_", 0, 1, [kt("Eql", "", 0, 1, [a, b, ty]), kt_span("FGlobal", f_context_own("Empty", ts, False{}), 0, 1, Nil{}, opBegin, opEnd)]), u => kt("Eql", "", 0, 1, [a, b, ty])), ts}

# Module: src/front/parser.bend:389
@unsafe
def w7_br_335(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      3
    case False{}:
      w7_br_334(f_eq(s, "&&"), s)

@unsafe
def w7_br_352(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".mod"
    case False{}:
      w7_br_351(f_eq(s, "<"), s)

@unsafe
def fpe_message(source, offset, end, error, observed):
  "Error:\n- expected : " ++ nm(kid(error, 0)) ++ "\n- observed : " ++ observed ++ "\nLocation:" ++ fpe_snippet(source, offset, end, error)

# A range is explicit producer data; point diagnostics retain their old path.

# Module: src/front/parser.bend:582
@unsafe
def w7_br_443(w7_c: Bool, +s: String) -> FDecoded:
  match w7_c:
    case True{}:
      FDecoded{0, "", "expected character"}
    case False{}:
      w7_br_442(Char.is_eq(f_head(s), '\\'), s)

@unsafe
def f_namespace_operator(head, input):
  f_eq(tg(head), "Ref") && (f_implicit_operator(nm(head)) || f_eq(nm(head), f_context_own("Bool.and", input, False{})) || f_eq(nm(head), f_context_own("Bool.or", input, False{})) || f_eq(nm(head), f_context_own("String.append", input, False{})))

# Module: src/front/literals_arrays.bend:155
@unsafe
def w7_br_469(w7_c: Bool, +n: KTerm, +ty: KTerm, +ts: FInput, +depth: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{depth, ts}
    case False{}:
      FParsed{f_scope_apply_span(ref(f_context_own("Array.new", ts, False{})), [ty, depth, n], 0, 0), ts}

@unsafe
def f_context_write(+term: KTerm, +begin: U32, +input: FInput) -> KTerm:
  w7_br_480(f_eq(tg(term), "App") && f_eq(tg(kid(term, 0)), "App") && f_eq(tg(kid(kid(term, 0), 0)), "App") && f_eq(tg(kid(kid(kid(term, 0), 0), 0)), "App") && f_eq(tg(kid(kid(kid(kid(term, 0), 0), 0), 0)), "Ref") && f_eq(nm(kid(kid(kid(kid(term, 0), 0), 0), 0)), f_context_own("Array.set", input, False{})), term, begin)

# Module: src/front/literals_arrays.bend:221
@unsafe
def f_fresh_result(
  +r: FResult,
) -> FResult:
  match r:
    case FResult{book, err, imports}:
      f_fresh_result_end(f_fresh_defs(book, 1), err, imports)

# Module: src/front/freshen.bend:53
@unsafe
def f_graph_aliases(imports, source, sources, root):
  match imports:
    case Nil{}:
      Nil{}
    case Con{+im, rest}:
      Con{kt("Import", f_import_namespace_at(im, source, sources, root), 0, 0, ks(im)), f_graph_aliases(rest, source, sources, root)}

# Module: src/load/graph.bend:193
@unsafe
def f_fresh_prefix_prepare(+prefix: List<&2,KDef>) -> FFreshPrefixState:
  f_fresh_prefix_prepared(prefix, f_fresh_defs(prefix, 1))

# Module: src/load/prefix.bend:52
@unsafe
def dg_family(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  match book:
    case Nil{}: ""
    case Con{d, rest}: kc(String, p88_string_eq(dk(d), "ADT") && Bool.not(p88_string_eq(dk(lookup(dc(d), name)), "Absent")), u => dn(d), u => dg_family(rest, name))

# Module: src/diagnostic/trace.bend:74
@unsafe
def dg_datatype_braces(+book: List<&2,KDef>, +name: String) -> String:
  +bare = dg_unqualified_name(name,name)
  +found = kc(String,p88_string_eq(dk(lookup(book,name)),"ADT"),u => name,
    u => kc(String,p88_string_eq(dk(lookup(book,bare)),"ADT"),v => bare,v => ""))
  kc(String,Bool.not(String.is_empty(found)) && String.is_empty(dg_family(book,name)),
    u => "Note: " ++ found ++ " is a datatype: write its arguments as <>",u => "")

@unsafe
def w7_br_546(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(ty, kc(KTerm, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_text("non-inferrable term"), u => ref(dg_family(cb(e), nm(t)))))
    case False{}:
      kt("DDetail", "", 0, 0, [dg_text(code), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])

@unsafe
def w7_br_564(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ name_key(nm(ty)) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t)
    case False{}:
      dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))

@unsafe
def j_type(book, env, t):
  j_type_on(book, env, t, tg(t))

# Module: src/back/common/queries.bend:35
@unsafe
def w7_br_567(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      j_app_type(wnf(book, j_type(book, env, kid(t, 0))), kid(t, 1))
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_568(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      dt(lookup(book, nm(t)))
    case False{}:
      w7_br_567(p88_string_eq(key, "App"), book, env, t)

@unsafe
def w7_br_569(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      j_env(env, ix(t))
    case False{}:
      w7_br_568(p88_string_eq(key, "Ref"), book, env, t, key)

@unsafe
def w7_br_570(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      kid(t, 1)
    case False{}:
      w7_br_569(p88_string_eq(key, "Var"), book, env, t, key)

@unsafe
def j_type_on(book, env, t, key):
  w7_br_570(p88_string_eq(key, "Ann"), book, env, t, key)

# Module: src/back/common/queries.bend:44
@unsafe
def j_specialize(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, rest}:
      j_specialize(book, j_app_type(wnf(book, tel), h), rest)

# Module: src/back/common/queries.bend:141
@unsafe
def jd_domains(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  jd_domains_head(book, wnf(book, ty))

# Module: src/back/common/arity.bend:19
@unsafe
def w7_br_576(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm) -> U32:
  match w7_c:
    case True{}:
      U32.inc(jd_domains(book, kid(ty, 1)))
    case False{}:
      0

@unsafe
def jd_domains_head(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  w7_br_576(p98_tag_eq(ty, "All"), book, ty)

# Module: src/back/common/arity.bend:23
@unsafe
def w7_br_577(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise_typed(book, j_strip(t), left, wnf(book, kid(t, 1)))
    case False{}:
      jd_raise_head(book, j_strip(t), left)

@unsafe
def w7_br_578(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      w7_br_577(p98_tag_eq(j_strip(t), "Mat"), book, t, left)
    case False{}:
      jd_raise_head(book, j_strip(t), left)

@unsafe
def jd_raise(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  w7_br_578(p98_tag_eq(t, "Ann"), book, t, left)

# Checked annotation supplies the matcher owner. Constructor names are unique
# in checked books; unknown/unannotated inputs retain the original global search.

# Module: src/back/common/arity.bend:33
@unsafe
def w7_br_579(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  match w7_c:
    case True{}:
      jd_raise_domain(book, t, left, wnf(book, kid(ty, 0)))
    case False{}:
      jd_raise_head(book, t, left)

@unsafe
def jd_raise_typed(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  w7_br_579(p98_tag_eq(ty, "All"), book, t, left, ty)

# Module: src/back/common/arity.bend:38
@unsafe
def w12_jd_raise_mat(isLitU32: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  match isLitU32:
    case True{}:
      U32.min(jd_raise(book, kid(t, 0), jd_raise_arm(left, 0)), jd_raise(book, kid(t, 1), left))
    case False{}:
      jd_raise_match(book, t, left, j_layout_ctor(book, domain, nm(t)))

@unsafe
def w7_br_580(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  match w7_c:
    case True{}:
      w12_jd_raise_mat(p88_string_eq(nm(t), "#U32"), book, t, left, domain)
    case False{}:
      jd_raise_head(book, t, left)

@unsafe
def jd_raise_domain(+book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  w7_br_580(p98_tag_eq(domain, "ADT"), book, t, left, domain)

# Module: src/back/common/arity.bend:43
@unsafe
def jd_raise_match(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ctor: KDef) -> U32:
  U32.min(jd_raise(book, kid(t, 0), jd_raise_arm(left, da(ctor))),
    jd_raise(book, kid(t, 1), left))

# Module: src/back/common/arity.bend:48
@unsafe
def w7_br_581(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise(book, kid(t, 0), U32.sub(left, 1))
    case False{}:
      U32.inc(jd_raise(book, kid(t, 0), 0))

@unsafe
def w7_br_583(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise_match(book, t, left, j_find_ctor(book, nm(t)))
    case False{}:
      w7_br_582(p98_tag_eq(t, "Efq"))

@unsafe
def w7_br_584(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      w7_br_581(U32.is_gt(left, 0) && U32.is_lt(left, 2147483648), book, t, left)
    case False{}:
      w7_br_583(p98_tag_eq(t, "Mat"), book, t, left)

@unsafe
def jd_raise_head(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  w7_br_584(p98_tag_eq(t, "Lam"), book, t, left)

# Module: src/back/common/arity.bend:57
@unsafe
def w7_br_585(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      jd_live_arity_head(book, wnf(book, ty), left)

@unsafe
def jd_live_arity(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  w7_br_585(U32.is_eq(left, 0), book, ty, left)

# Module: src/back/common/arity.bend:67
@unsafe
def w7_br_586(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      U32.add(kc(U32, U32.is_eq(qt(ty), 0), u => 0, u => 1), jd_live_arity(book, kid(ty, 1), U32.sub(left, 1)))
    case False{}:
      0

@unsafe
def jd_live_arity_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  w7_br_586(p98_tag_eq(ty, "All"), book, ty, left)

# Module: src/back/common/native-facts.bend:6
@unsafe
def j_u32_native_book(+book: List<&2,KDef>) -> Bool:
  j_u32_native_ctor(book, "U32", "U32") &&
  j_u32_native_ctor(book, "Word.Nil", "WNil") &&
  j_u32_native_ctor(book, "Word.Con", "WCon") &&
  j_u32_native_ctor(book, "Bool", "False") &&
  j_u32_native_ctor(book, "Bool", "True") &&
  p88_string_eq(dk(lookup(book, "Word")), "Def") && db(lookup(book, "Word"))

# Module: src/back/js/shared-text.bend:7
@unsafe
def w7_br_594(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_word_text(j_word(j_strip(kid(t, 0)), 0, 0), True{})
    case False{}:
      w7_br_593(p88_string_eq(nm(t), "Chr"), t)

@unsafe
def j_literal_provenance(book, ty, literal):
  w7_br_596(j_literal_owner(book, ty), literal)

# Module: src/back/js/validate.bend:6
@unsafe
def j_layout_array_intrinsic(book, f):
  w7b_arr_intr_if(p98_tag_eq(f, "Ref"), book, f)

# Module: src/back/js/validate.bend:276
@unsafe
def j_layout_element_open(+book: List<&2,KDef>, +element: KTerm) -> Bool:
  +tag = tg(wnf(book, element))
  Bool.not(p88_string_eq(tag, "ADT") || p88_string_eq(tag, "Eql"))

# Module: src/back/js/validate.bend:295
@unsafe
def j_string_owner_header(+book: List<&2,KDef>, +name: String, +count: U32) -> Bool:
  +owner = lookup(book, name)
  +kind = wnf(book, dt(owner))
  p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), count) && p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) && List.is_empty(&2, KTerm, ks(kid(kind, 0)))

# Module: src/back/js/jpure.bend:586
@unsafe
def j_map_cmp_ctor(+book: List<&2,KDef>, +c: KDef, +name: String, +ty: KTerm) -> Bool:
  j_pure_native_ctor(c, name, 0) && j_map_cmp_nominal(ty) && j_map_cmp_nominal(wnf(book, dt(c)))

# Module: src/back/js/jpure.bend:1376
@unsafe
def j_callback_type_domain(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  p98_tag_eq(h, "Typ") && p88_string_eq(nm(h), "") && U32.is_eq(ix(h), 0) && U32.is_eq(qt(h), 0) &&
    List.is_empty(&2, String, rm(h)) && U32.is_eq(terms_len(ks(h)), 1) &&
    p98_tag_eq(kid(h, 0), "Qua") && p88_string_eq(nm(kid(h, 0)), "") && U32.is_eq(ix(kid(h, 0)), 0) &&
    U32.is_eq(qt(kid(h, 0)), 1) && List.is_empty(&2, String, rm(kid(h, 0))) && U32.is_eq(terms_len(ks(kid(h, 0))), 0)

# Module: src/back/js/region.bend:1100
@unsafe
def j_fold_root_result(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  +head = wnf(book, ty)
  kc(KTerm, U32.is_eq(left, 0), u => head, u => j_fold_root_result(book, kid(head, 1), U32.sub(left, 1)))

# Grounded first-order List; every other instantiation retains generic emission.

# Module: src/back/js/fold.bend:284
@unsafe
def ni_template(+k: String) -> String:
  w5c2_ni_from_nat(String.eq(k, "f32_from_nat"), k)

# Module: src/back/native/intrinsic.bend:78
@unsafe
def nc_tele_fill(+book: List<&2, KDef>, +tel: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: tel
    case Con{h, rest}:
      +head = wnf(book, tel)
      nc_tele_fill(book, subst(kid(head, 1), ix(head), h), rest)

# Module: src/back/native/erase.bend:29
@unsafe
def w7_br_637(w7_c: Bool, +book: List<&2, KDef>, +tel: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      nc_live_count_head(book, wnf(book, tel), left)

@unsafe
def nc_live_count(+book: List<&2, KDef>, +tel: KTerm, +left: U32) -> U32:
  w7_br_637(U32.is_eq(left, 0), book, tel, left)

# Module: src/back/native/erase.bend:33
@unsafe
def nc_live_count_head(book, head, left):
  U32.add(nt_bool(Bool.not(U32.is_eq(qt(head), 0))), nc_live_count(book, kid(head, 1), U32.sub(left, 1)))

# Module: src/back/native/erase.bend:37
@unsafe
def w7_br_649(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "blk_node(e, " ++ nc_head(ws) ++ ", " ++ nc_head(nc_tail(ws)) ++ ")", n}
    case False{}:
      ne_constructor(name, ws, False{}, n, True{})

@unsafe
def w7_br_658(w7_c: Bool, +book: List<&2, KDef>, +name: String) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      w7_br_657(p88_string_eq(name, "Zero") || p88_string_eq(name, "True") || p88_string_eq(name, "False"), book, name)

@unsafe
def w7_br_662(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "(" ++ word ++ " != 0)"
    case False{}:
      w7_br_661(p88_string_eq(name, "Chr") || p88_string_eq(name, "U32") || p88_string_eq(name, "F32"), name, word)

@unsafe
def nc_primitive_name(+k: String) -> String:
  match k:
    case SNil{}: ""
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_pn_disp_u(U32.is_eq(c, 85), c, k)

# Module: src/back/native/bridge.bend:510
@unsafe
def w5c2_prim_f(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_f32(k)
    case False{}: w5c2_prim_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_arity_u(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_u32(k)
    case False{}: w5c2_arity_f(U32.is_eq(c, 102), c, k)

@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, p98_tag_eq(tel, "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

# Module: src/back/native/direct.bend:84
@unsafe
def w4c_field_is_nat(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, "Nat")
  p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), "Nat") && p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head))

@unsafe
def w4c_field_is_w32(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, nm(head))
  p98_tag_eq(head, "ADT") && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) &&
    nb_contains(["U32", "F32", "Char", "Bool"], nm(head))

@unsafe
def w7_br_693(w7_c: Bool, +book: List<&2, KDef>, +field: KTerm) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      w7_br_692(w4c_field_is_nat(book, field))

@unsafe
def nq_layout_type(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_eval(book, ty, Nil{}, Nil{}, 64)

# Module: src/back/native/product-layout.bend:71
@unsafe
def nq_info(+target: NC_Target, +name: String) -> KDef:
  match target:
    case NC_Scheduler{}: missing()
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}: lookup(signatures, name)

# A virtual bundle has already evaluated fields, each represented by a Var.
# A single-use substitution keeps the existing scalar ownership environment.

# Module: src/back/native/product.bend:101
@unsafe
def nq_ctor_shape(+value: KTerm, +target: NC_Target) -> KTerm:
  +d = nq_info(target, "$constructor." ++ nm(value))
  nt_choose(KTerm, p88_string_eq(dk(d), "NQConstructor") && U32.is_eq(ix(dt(d)), terms_len(ks(value))), u => dt(d), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/product.bend:137
@unsafe
def nw_apply(+body: KTerm, +word: KTerm, +fields: U32) -> KTerm:
  w7_br_724(U32.is_eq(fields, 2), body, word)

# Module: src/back/native/word-pattern.bend:73
@unsafe
def nc_foreign_tel(+book: List<&2, KDef>, +ty: KTerm, +name: String, +args: List<&2, KTerm>, +n: U32) -> KTerm:
  +tel = wnf(book, ty)
  nt_choose(KTerm, p98_tag_eq(tel, "All"),
    u => nt_choose(KTerm, U32.is_eq(qt(tel), 0),
      u => nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), {KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), name, args, U32.inc(n)),
      u => k_lam("", nc_id(n), 1, [nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), var("", nc_id(n))), name, List.append(&2, KTerm, args, [var("", nc_id(n))]), U32.inc(n))], 0, 0, False{})),
    u => kt("NCtr", name, 0, 0, args))

# Module: src/back/native/book.bend:62
@unsafe
def w7_br_737(w7_c: Bool, +book: List<&2, KDef>, +tel: KTerm, +n: U32) -> KTerm:
  match w7_c:
    case True{}:
      tel
    case False{}:
      nc_skip_tel(book, kid(wnf(book, tel), 1), U32.sub(n, 1))

@unsafe
def nc_skip_tel(+book: List<&2, KDef>, +tel: KTerm, +n: U32) -> KTerm:
  w7_br_737(U32.is_eq(n, 0), book, tel, n)

# Module: src/back/native/book.bend:157
@unsafe
def nc_all_args(+book: List<&2, KDef>, +ty: KTerm) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, p98_tag_eq(tel, "All"), u => U32.add(nt_bool(Bool.not(U32.is_eq(qt(tel), 0))), nc_all_args(book, kid(tel, 1))), u => 0)

# Module: src/back/native/book.bend:179
@unsafe
def nc_paths_of(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: List.append(&2, String, nc_c_paths(ks(nc_unann(dv(lookup(book, name))))), nc_paths_of(book, rest))

# Selective annotation keeps all original type-level definitions in scope.
# The host asks reach_book for main's closure, annotates it in the original
# context, and replaces only those entries before native emission.

# Module: src/back/native/book.bend:316
@unsafe
def nc_context_defs(book: List<&2, KDef>, +annotated: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, KDef>, p88_string_eq(dk(d), "BookCache"),
        u => nc_context_defs(rest, annotated),
        u => Con{nc_context_pick(d, lookup(annotated, dn(d))), nc_context_defs(rest, annotated)})

# Build an immutable first-match index once for plain annotation lists.
# A cache sentinel anywhere changes lookup semantics, so retain that input.

# Module: src/back/native/book.bend:341
@unsafe
def ns_ctor(+cs: KDef, +name: String, +arity: U32) -> Bool:
  w7_br_739(nb_contains(["Zero", "Succ", "True", "False", "Chr", "U32", "F32", "ALeaf", "ANode", "Emit", "Halt", "Done", "Fail"], name), cs, name, arity)

# Module: src/back/native/static.bend:68
@unsafe
def nol_owner(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  p98_tag_eq(ty, "ADT") && List.is_empty(&2, String, rm(ty)) && p88_string_eq(dk(d), "ADT") && U32.is_eq(dx(d), 0) && U32.is_eq(terms_len(ks(ty)), da(d))

# Read exactly the declared live fields after specializing type parameters.
# All aliases/substitutions retain the existing 64-step/4096-node limits.
# Prior field dependencies and indexed constructor results decline. Unlike
# nq_layout_leaf, a nested Sigma is not rejected for sharing its owner's name.

# Module: src/back/native/observer-layout.bend:33
@unsafe
def no_literal_native(+book: List<&2, KDef>, +kind: String) -> Bool:
  +d = lookup(book, kind)
  p88_string_eq(dk(d), "ADT") && db(d) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0)

# The child is the emitter atom; name is the exact scalar kind and id the U32
# payload. F32 retains its raw bits. Nat literals fit below native NAT_IMM.

# Module: src/back/native/observer-literals.bend:13
@unsafe
def no_literal_typed(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  w7_br_762(core_literal(t) && nb_contains(["Nat", "U32", "F32"], nm(t)) && no_literal_native(book, nm(t)), t)

# Optional: one structural step only. The caller must re-enter its ordinary
# budgeted evaluator and spend fuel again; never recursively expand here.

# Module: src/back/native/observer-literals.bend:21
@unsafe
def no_literal_string_step(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  w7_br_763(core_literal(t) && p88_string_eq(nm(t), "String") && no_literal_native(book, "String"), t)

# A virtual constructor would erase nat_chk/term_word demand. Refuse even if
# the value will be discarded later. Source KLiteral is handled above instead.
# Chr is separate: admit only one argument whose exact proven type is U32.

# Module: src/back/native/observer-literals.bend:29
@unsafe
def driver_emit_owned(
  +book: List<&2,KDef>,
) -> String:
  +error = driver_owned_names(driver_owned_candidates(book), ["IO", "Sigma", "String", "Word.Con", "IO.OP", "Result", "Poll", "Maybe", "Bool", "Unit", "Nat", "U32", "F32", "Char", "Array"])
  kc(String, p88_string_eq(error, ""), u => driver_foreign_names(book, book), u => error)

# Native definitions cannot violate the owned-name rule. Filter once instead
# of revisiting the same native prefix for each reserved name. Retain duplicates
# and source order; foreign/constructor policy still receives the original book.

# Module: src/driver/api.bend:86
@unsafe
def p88_roots(state: P88State, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match roles:
    case Nil{}: p88_roots_done(state,List.reverse(&2,P88Node,values))
    case Con{role,rest}: p88_roots_next(p88_field(state,role),rest,values)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:300
@unsafe
def p88_roots_next(step: P88Step, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match step:
    case P88Step{state,P88Bad{}}: P88DecodeError{"cache root"}
    case P88Step{state,value}: p88_roots(state,roles,Con{value,values})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:306
@unsafe
def p205z_guard(+book: List<&2,KDef>, +rep: KTerm, +join: KTerm, +split: KTerm) -> KTerm:
  +base = norm_book_bound(book)
  kc(KTerm,U32.is_lt(base,4294900000),u => p205z_build(base,rep,join,split),u => atom("Absent"))

@unsafe
def w7_br_799(w7_c: Bool, +body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  match w7_c:
    case True{}:
      p205u_shape(kid(body,0),owner,arity,U32.inc(index))
    case False{}:
      w7_br_798(p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2), body, owner, arity, index)

@unsafe
def p205u_shape(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  w7_br_799(p98_tag_eq(body,"Lam") && U32.is_lt(index,4), body, owner, arity, index)
@unsafe
def w7_br_802(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      w7_br_801(p98_tag_eq(t,"Ref"), book, t)

@unsafe
def p205u_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),u => p205u_closed_type(book,ty),u =>
    kc(KTerm,p98_tag_eq(ty,"All"),v => p205u_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))
@unsafe
def w7_br_808(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_closed_type(book,dt(lookup(book,nm(t))))
    case False{}:
      atom("Absent")

@unsafe
def w7_br_838(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.or(a, b)}
    case False{}:
      w7_br_837(agy_str_eq(op, "u32_xor"), op, a, b)

@unsafe
def w7_br_857(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_845(U32.is_le(a, U32.sub(4294967295, b)), a, b)
    case False{}:
      w7_br_856(agy_str_eq(op, "nat_sub"), op, a, b)

@unsafe
def w7_br_866(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVF32{F32.sub(a, b)}
    case False{}:
      w7_br_865(agy_str_eq(op, "f32_mul"), op, a, b)

@unsafe
def ctfe_reify(+owner: String, +v: CtfeVal) -> KTerm:
  w7_br_879(agy_str_eq(owner, "U32"), owner, v)

@unsafe
def agy_abs_ctor_arity(+ctx: List<&2,KDef>, +cname: String) -> U32:
  +parent = kr_parent(ctx,cname)
  kc(U32,agy_str_eq(dk(parent),"Absent"),u => 999999,u => agy_abs_ctor_arity_def(lookup(dc(parent),cname)))

@unsafe
def agy_bf_check_right(+call: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  +c = j_call_spine(call,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && agy_str_eq(nm(c),fname),
    u => agy_bf_check_right_args(ks(c),lams1),
    u => AgyStep{0,False{}})

@unsafe
def p205v_result_type(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  +ty = j_strip(t)
  kc(Bool,p98_tag_eq(ty,"All"),u => p205v_result_type(book,kid(ty,1)),u =>
    p205v_closed_ty(book,ty,4))

@unsafe
def w5c3_bin_ge(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_ge(a,b))
    case False{}: p205v_arithmetic(op,a,b)

@unsafe
def w5c2_rcmp_ok(ok: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match ok:
    case False{}: atom("Absent")
    case True{}: w5c2_rcmp_le(String.eq(op,"u32_is_le"), op, la, ha, lb, hb)

@unsafe
def p205v_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),
    u => kc(KTerm,p205v_closed_ty(book,ty,4),v => ty,v => atom("Absent")),
    u => kc(KTerm,p98_tag_eq(ty,"All"),v => p205v_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))

@unsafe
def w7_br_919(w7_c: Bool, +fname: String, +st_ty: KTerm, +body: KTerm) -> W2Fold:
  match w7_c:
    case True{}:
      w2d_fold_scon(fname,st_ty,kid(body,0),kid(kid(body,1),0))
    case False{}:
      W2Fold{fname,st_ty,atom("Absent"),atom("Absent"),False{}}

@unsafe
def w2d_mat_type(+book: List<&2,KDef>, +m: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  +sm = j_strip(m)
  kc(KTerm,p98_tag_eq(sm,"Mat") && U32.is_eq(terms_len(ks(sm)),2),u =>
    w2d_mat_type_go(book,sm,st_ty,ret_ty,
      kc(KTerm,agy_str_eq(nm(sm),"Tuple"),v => st_ty,v => w2d_ctor_owner_ty(book,nm(sm)))),
    u => ret_ty)

@unsafe
def w7_br_928(w7_c: Bool, +book: List<&2,KDef>, +sm: KTerm, +st_ty: KTerm, +ret_ty: KTerm, +dom: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      atom("Absent")
    case False{}:
      all(1,"$w2m",0,dom,w2d_mat_type_cod(book,j_strip(kid(sm,0)),st_ty,ret_ty))

@unsafe
def w2d_mat_type_go(+book: List<&2,KDef>, +sm: KTerm, +st_ty: KTerm, +ret_ty: KTerm, +dom: KTerm) -> KTerm:
  w7_br_928(p98_tag_eq(dom,"Absent"), book, sm, st_ty, ret_ty, dom)

@unsafe
def w7_br_929(w7_c: Bool, +book: List<&2,KDef>, +br: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w2d_mat_type(book,br,st_ty,ret_ty)
    case False{}:
      ret_ty

@unsafe
def w2d_mat_type_cod(+book: List<&2,KDef>, +br: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  w7_br_929(p98_tag_eq(br,"Mat"), book, br, st_ty, ret_ty)

@unsafe
def p152c_nullary(+constructors: KDef, +term: KTerm) -> Bool:
  p98_tag_eq(term,"NStatic") && U32.is_eq(qt(term),1) && U32.is_eq(ix(term),0) &&
    List.is_empty(&2,KTerm,ks(term)) && p112s_constructor_ok(constructors,nm(term),0)

@unsafe
def p152c_immediate(+book: List<&2,KDef>, +term: KTerm) -> Bool:
  p98_tag_eq(dt(ns_context(book)),"P112StaticImage") && p152c_nullary(p112s_context_ctors(book),term)

@unsafe
def p152c_pair(+constructors: KDef, +source: KTerm, +prepared: KTerm) -> Bool:
  nt_choose(Bool,p98_tag_eq(prepared,"NStatic"),
    u => p98_tag_eq(source,"Ctr") && agy_str_eq(nm(source),nm(prepared)) &&
      List.is_empty(&2,KTerm,ks(source)) && p152c_nullary(constructors,prepared),
    u => p152c_variant(source,prepared) && agy_str_eq(tg(source),tg(prepared)) &&
      agy_str_eq(nm(source),nm(prepared)) && U32.is_eq(ix(source),ix(prepared)) &&
      U32.is_eq(qt(source),qt(prepared)) && U32.is_eq(kb(source),kb(prepared)) &&
      U32.is_eq(ke(source),ke(prepared)) && p152c_strings(rm(source),rm(prepared)) &&
      p152c_pairs(constructors,ks(source),ks(prepared)))

@unsafe
def p152c_pairs(+constructors: KDef, a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p152c_pair(constructors,x,y) && p152c_pairs(constructors,xs,ys)
    case _ _: False{}

# Same-name freshly prepared fact with its retained erased source. A bounded
# correspondence check rejects stale substitutions, fields, boxes and scalars.
# Actual factory preparation already blocked effects before producing markers.
@unsafe
def p111_op_id(+name: String) -> U32:
  w5c2_opid_fn(String.eq(name, "f32_from_nat"), name)

@unsafe
def p111v_signature(+symbol: String) -> List<&2,U32>:
  w5c3_sig1(String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink") || String.eq(symbol,"p111_rt_tag"), symbol)

@unsafe
def p111v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: KDef, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p111v_value(value,width,live,ids) && p111v_args(rest,more,live,ids)
    case _ _: False{}

@unsafe
def p111v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: KDef) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p111v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

@unsafe
def p111q_tables(+program: P111Program, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,[
        P111QData{"p111_segments",8,False{},p111q_segment_table(segments,0,[])},
        P111QData{"p111_fid_arity",1,False{},p111q_segment_table(segments,1,[])},
        P111QData{"p111_fid_flags",1,False{},p111q_segment_table(segments,2,[])},
        P111QData{"p111_fid_results",1,False{},p111q_segment_table(segments,3,[])},
        P111QData{"p111_cid_arity",1,False{},p111q_ctor_table(constructors,False{},[])},
        P111QData{"p111_cid_hot",1,False{},p111q_ctor_table(constructors,True{},[])},
        P111QData{"p111_show_desc",4,False{},p111q_nonempty(p111q_words(show))},
        p111q_descriptor(program,ids)],
        nt_append(P111QData,p111q_strings(p111q_ctor_names(constructors),"p111_cid_names"),
          nt_append(P111QData,p111q_strings(show_names,"p111_show_names"),p111q_strings(effects,"p111_effects"))))


@unsafe
def p112w_public(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  p112w_public_target(body,owner,ready,p112w_target(body))


@unsafe
def p112w_public_target(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef, +target: String) -> List<&2,P112WorkerStmt>:
  +count = da(p111v_get(ready,target))
  nt_choose(List<&2,P112WorkerStmt>,p112w_ready(ready,target) && Bool.not(agy_str_eq(owner,target)) && p112t_tail(body,target,count,0),
    u => p112w_nodes(body,count,P112WorkerCall{target,count}),u => p112w_public_next(body,owner,ready))


@unsafe
def p112w_public_next(body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{N111If{condition,yes,no},rest}:
      Con{P112WorkerIf{condition,p112w_public(yes,owner,ready),p112w_public(no,owner,ready)},p112w_public(rest,owner,ready)}
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_public(rest,owner,ready)}


@unsafe
def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  nt_choose(P112STerm,agy_str_eq(tg(term),"NWord"),u => P112STerm{term,image},u =>
    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>
      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => P112STerm{term,image}),
      u => P112STerm{term,image}))


@unsafe
def p112s_word_valid(word: P112SWord, +constructors: KDef, +nodes: KDef) -> Bool:
  match word:
    case P112SRaw{value}: True{}
    case P112SPacked{+name,+payload}:
      +found = p112s_find(constructors,name)
      p112s_constructor_ok(constructors,name,dx(found)) &&
        ((U32.is_eq(dx(found),0) && U32.is_eq(payload,0)) || (U32.is_eq(dx(found),1) && String.starts_with(name,"$ctor.")))
    case P112SBox{+name,+offset}:
      +found = p112s_find(nodes,U32.show(offset))
      agy_str_eq(dk(found),"P112StaticNode") && agy_str_eq(tg(dt(found)),name) &&
        U32.is_gt(dx(found),0) && p112s_constructor_ok(constructors,name,dx(found))


@unsafe
def p112s_fields_valid(fields: List<&2,P112SWord>, +constructors: KDef, +nodes: KDef) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p112s_word_valid(head,constructors,nodes) && p112s_fields_valid(rest,constructors,nodes)


@unsafe
def p112s_value(+book: List<&2,KDef>, +term: KTerm) -> P111ValueCode:
  +word = p112s_term_word(term)
  +constructors = p112s_context_ctors(book)
  +valid = agy_str_eq(tg(dt(ns_context(book))),"P112StaticImage") && agy_str_eq(tg(term),"NStatic") &&
    List.is_empty(&2,KTerm,ks(term)) && U32.is_le(qt(term),1) && p112s_word_valid(word,constructors,p112s_context_nodes(book))
  nt_choose(P111ValueCode,valid,u => P111ValueCode{[],p112s_word(word,constructors),""},
    u => P111ValueCode{[],N111Const{0,0},"static word outside its fresh validated image"})


@unsafe
def p112s_image_fields(fields: List<&2,P112SWord>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match fields:
    case Nil{}: acc
    case Con{head,rest}: p112s_image_fields(rest,constructors,Con{p112s_datum(p112s_word(head,constructors)),acc})


@unsafe
def p112s_image_items(nodes: List<&2,P112SNode>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match nodes:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{P112SNode{offset,name,fields},rest}:
      p112s_image_items(rest,constructors,p112s_image_fields(fields,constructors,acc))

# ABI11101 has 24 eight-byte descriptor slots. Only static_words (slot8,
# byte64) and static_image (slot19,byte152) differ from the selected descriptor.


@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  w5c2_p112f_state(String.eq(name, "state"), prefix, name)


@unsafe
def p112f_cont(segment: N111Segment, +count: U32) -> Maybe<&2,P112FusionCont>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(arity,U32.inc(count)) && U32.is_eq(result,1) && U32.is_eq(incoming,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_cont_body(body,count),u => None{})


@unsafe
def p112r_scalar(+stmt: N111Stmt, +symbols: KDef, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      (p112t_runtime_call(symbol) && p112r_runtime_args(args,sites)) || p112r_private_call(stmt,symbols)
    case N111Load{+name,N111U64{},N111Local{+base},+offset}: p112r_buffer(base,sites)
    case N111Store{N111U64{},N111Local{+base},+offset,+value}: p112r_buffer(base,sites)
    case N111Alloca{+name,2048,8}: Bool.not(agy_str_eq(name,"scratch")) && p112r_buffer(name,sites)
    case _: p112t_scalar_safe(stmt)


@unsafe
def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)

@unsafe
def w6_p113d_deps_self(calls: List<&2,String>, +index: KDef, +owner: String) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{+head,rest}: (agy_str_eq(head,owner) || p113d_ready(index,head)) && w6_p113d_deps_self(rest,index,owner)


@unsafe
def p113e_values(values: List<&2,N111Value>, +live: KDef, +ids: N111Ids) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p111v_value(head,2,live,ids) && p113e_values(rest,live,ids)


@unsafe
def p113e_vector(+values: List<&2,N111Value>, +count: U32, +live: KDef, +ids: N111Ids) -> P111VFlow:
  nt_choose(P111VFlow,U32.is_eq(nt_count(N111Value,values),count) && p113e_values(values,live,ids),
    u => P111VFlow{live,True{},""},u => P111VFlow{live,False{},"direct terminal vector has wrong arity/type or undefined value"})


@unsafe
def p113a_scan_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))


@unsafe
def p113a_scan_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(p113a_template_sunk(stmt,n,heap_min,v0,v1,v2))),
        p113a_scan(rest,U32.inc(n),heap_min))
    case P113ASunkNo{}: p113a_scan_step(body,n,heap_min)


@unsafe
def p113a_scan(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  p113a_scan_sunk(p113a_match_sunk(body),body,n,heap_min)


@unsafe
def p113a_scan_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p113a_scan_no(condition,body,rest,heap_min,p113a_scan(no,next,heap_min))


@unsafe
def p113a_scan_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p113a_scan(rest,next,heap_min))


@unsafe
def p113k_value(value: N111Value, +facts: KDef) -> P113KFact:
  match value:
    case N111Const{lo,hi}: p113k_exact(lo,hi)
    case N111Local{name}: p113k_get(facts,name)
    case _: p113k_bound(64)


@unsafe
def w5c2_join_fact_if(same: Bool, +lb: U32, +ll: U32, +lh: U32, +rb: U32, +rl: U32, +rh: U32) -> P113KFact:
  match same:
    case True{}: p113k_exact(ll, lh)
    case False{}: P113KFact{U32.max(lb, rb), False{}, U32.and(ll, rl), U32.and(lh, rh)}

@unsafe
def w5c2_p113k_limit_if(exact: Bool, +bits: U32, +lo: U32, +nhi: U32, +width: U32) -> P113KFact:
  match exact:
    case True{}: p113k_exact(lo, nhi)
    case False{}: P113KFact{U32.min(bits, width), False{}, lo, nhi}

@unsafe
def p113k_shift(+left: P113KFact, +amount: U32, +right: Bool) -> P113KFact:
  match left:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,U32.is_eq(amount,0),u => left,u =>
      nt_choose(P113KFact,exact,
        u =>
      nt_choose(P113KFact,U32.is_lt(amount,32),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.or(U32.shrn(lo,U32.to_nat(amount)),U32.shln(hi,U32.to_nat(U32.sub(32,amount)))),U32.shrn(hi,U32.to_nat(amount))),
          v => p113k_exact(U32.shln(lo,U32.to_nat(amount)),U32.or(U32.shln(hi,U32.to_nat(amount)),U32.shrn(lo,U32.to_nat(U32.sub(32,amount)))))),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.shrn(hi,U32.to_nat(U32.sub(amount,32))),0),
          v => p113k_exact(0,U32.shln(lo,U32.to_nat(U32.sub(amount,32)))))),u => p113k_bound(nt_choose(U32,right,v => nt_choose(U32,U32.is_ge(amount,bits),w => 0,w => U32.sub(bits,amount)),v => U32.min(64,U32.add(bits,amount))))))


@unsafe
def p113k_unsigned(+op: String, +equal: Bool, +less: Bool) -> P113KFact:
  nt_choose(P113KFact,agy_str_eq(op,"eq"),u => p113k_exact(Bool.to_u32(equal),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ne"),u => p113k_exact(Bool.to_u32(Bool.not(equal)),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ult"),u => p113k_exact(Bool.to_u32(less),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ule"),u => p113k_exact(Bool.to_u32(less || equal),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ugt"),u => p113k_exact(Bool.to_u32(Bool.not(less || equal)),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"uge"),u => p113k_exact(Bool.to_u32(Bool.not(less)),0),u => p113k_bound(1)))))))


@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{_, exact, +lo, +hi}:
      w5c2_bs_1(exact, lo, hi, name, typ, op, left, right, lf, rf)


@unsafe
def w4g_ic_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +subj: String, +facts: KDef, +otherR: KDef, +otherW: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case _: False{}


@unsafe
def w4k_dce_scalars(body: List<&2,N111Stmt>, +used: KDef) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{N111Set{+name,typ,v},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name),
        u => Con{N111Set{name,typ,v},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111Bin{+name,typ,+op,l,r},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{N111Bin{name,typ,op,l,r},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111If{cond,yes,no},rest}:
      Con{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)},w4k_dce_scalars(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_scalars(rest,used)}


@unsafe
def w4k_dce_body(body: List<&2,P113DStmt>, +used: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+name,typ,v}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name),
        u => Con{P113DScalar{N111Set{name,typ,v}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111Bin{+name,typ,+op,l,r}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{P113DScalar{N111Bin{name,typ,op,l,r}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111If{cond,yes,no}},rest}:
      Con{P113DScalar{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)}},w4k_dce_body(rest,used)}
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w4k_dce_body(yes,used),w4k_dce_body(no,used)},w4k_dce_body(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_body(rest,used)}


@unsafe
def w4g_resolve(+env: W4GCopyEnv, +name: String) -> String:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +entry = p111v_get(aliases,name)
      nt_choose(String,agy_str_eq(dk(entry),"W4GAlias"),
        u =>
          +src = nm(dv(entry))
          nt_choose(String,U32.is_eq(da(entry),w4g_ver(vers,src)),v => src,v => name),
        u => name)


@unsafe
def w4g_arm_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forbidden: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case _: False{}


@unsafe
def w4g_cond_not_written(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4g_live_has(writes,n))
    case _: True{}


@unsafe
def w4k_add_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +s_lo = U32.add(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(s_lo,0),
    u => p113k_exact(s_lo,U32.add(U32.add(lh,rh),Bool.to_u32(U32.is_lt(s_lo,ll)))))


@unsafe
def w4k_sub_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +d_lo = U32.sub(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(d_lo,0),
    u => p113k_exact(d_lo,U32.sub(U32.sub(lh,rh),Bool.to_u32(U32.is_lt(ll,rl)))))


@unsafe
def w4k_mul_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32, +lb: U32, +rb: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(U32.mul(ll,rl),0),
    u => nt_choose(P113KFact,U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_le(ll,65535) && U32.is_le(rl,65535),
      v => p113k_exact(U32.mul(ll,rl),0),
      v => p113k_bound(U32.min(width,U32.add(lb,rb)))))


@unsafe
def w5c2_p113l_rel_check(found: KDef, +facts: KDef, +name: String) -> KDef:
  match found:
    case KDef{_, kind, _, _, ftyp, fval, _, _, _}:
      w5c2_p113l_rel_ok(
        String.eq(kind, "P113LRelation") &&
        U32.is_eq(ix(ftyp), p113l_version(facts, nm(fval))) &&
        U32.is_eq(qt(ftyp), p113l_version(facts, name)), found)
    case _: missing()

@unsafe
def p117h_value(value: N111Value, +facts: KDef) -> U32:
  match value:
    case N111Local{name}: p117h_get(facts,name)
    case _: 0


@unsafe
def p117h_load(+base: N111Value, +offset: U32, +slots: KDef) -> U32:
  +key = p117h_slot(base,offset)
  nt_choose(U32,agy_str_eq(key,""),u => 0,u => p117h_get(slots,key))


@unsafe
def p117h_backedge(values: List<&2,N111Value>, +facts: KDef, +origin: U32, +count: U32) -> U32:
  match values:
    case Nil{}: nt_choose(U32,U32.is_eq(origin,U32.inc(count)),u => 65535,u => 0)
    case Con{value,rest}:
      U32.and(p117h_backedge(rest,facts,U32.inc(origin),count),
        nt_choose(U32,U32.is_eq(p117h_value(value,facts),origin),u => 65535,
          u => U32.xor(65535,p117h_bit(origin))))


@unsafe
def p117h_rewrite_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117h_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117h_template(stmt,n,origin))),
          p117h_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117h_rewrite_yes(condition,no,rest,heap_min,used,sites,p117h_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117h_rewrite(rest,n,heap_min,used,sites))


@unsafe
def p117h_rewrite_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117h_template_sunk(stmt,n,origin,v0,v1,v2)))),
        p117h_rewrite(rest,U32.inc(n),heap_min,used,sites))
    case P113ASunkNo{}: p117h_rewrite_step(body,n,heap_min,used,sites)


@unsafe
def p117h_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117h_rewrite_sunk(p113a_match_sunk(body),body,n,heap_min,used,sites)


@unsafe
def p117h_rewrite_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p117h_rewrite_no(condition,body,rest,heap_min,used,sites,p117h_rewrite(no,next,heap_min,used,sites))


@unsafe
def p117h_rewrite_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p117h_rewrite(rest,next,heap_min,used,sites))

@unsafe
def p117v_all(+sites: KDef, +count: U32, +used: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,count),u => True{},u =>
    U32.is_gt(U32.and(used,p117h_bit(p117h_get(sites,U32.show(index)))),0) && p117v_all(sites,count,used,U32.inc(index)))


@unsafe
def p117v_address_pick(+id: U32, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(p117h_get(nomask,U32.show(n)),1),
    u => p117v_address_nomask(id,n,origin),
    u => p117h_address(id,n,origin))

@unsafe
def p117v_template_ex(+original: N111Stmt, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def p117v_template_sunk_ex(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def w4c_val_bm_opt(mv: Maybe<&2,N111Value>, +env: KDef) -> Maybe<&2,U32>:
  match mv:
    case Some{v}: w4c_val_bm_env(v,env)
    case None{}: None{}

# Flow-sensitive check for countdown param `pidx`: every P113DAgain is under `pidx != 0` and passes `DEC(pidx)`.
@unsafe
def p118t_extend_contract(+args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +constructor: KDef) -> Bool:
  +count = p111v_literal(p111v_arg(args,4))
  p111v_args(args,[3,2,1,3,1],live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(agy_str_eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) &&
    p111v_buffer(args,3,count,live)


@unsafe
def p118b_project_borrow(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +ids: N111Ids) -> P113DCode:
  +ctor = p111v_target(p111v_arg(args,3),ids,True{})
  +count = p111v_literal(p111v_arg(args,4))
  +ok = p118b_arg_types(args,[3,2,3,1,1]) && U32.is_eq(p111v_type(typ),2) &&
    Bool.not(agy_str_eq(dk(ctor),"Absent")) && U32.is_eq(da(ctor),count) &&
    U32.is_ge(count,2) && U32.is_le(count,16)
  +projected : N111Stmt = N111Call{name,typ,"p111_rt_take",[
    p111_state(),p111_word(p111v_arg(args,1)),N111Arg{N111Ptr{},p111v_arg(args,2)},p111_u32(count)]}
  nt_choose(P113DCode,ok && p111v_state_argument(args),
    u => P113DCode{[P113DScalar{projected}],0,"",[]},
    u => p113d_fail("borrowed import: constructor/count contract",0))


@unsafe
def p118b_without(functions: List<&2,P113DFunction>, replaced: KDef) -> List<&2,P113DFunction>:
  p118ns_without(functions,replaced,[])

@unsafe
def p123p_get(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@p123predicate:" ++ name)
  nt_choose(KDef,agy_str_eq(dk(found),"P123Predicate"),u =>
    nt_choose(KDef,U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
      U32.is_eq(qt(dt(found)),p113l_version(facts,name)),v => found,v => missing()),u => missing())


@unsafe
def p124r_legacy(+ready: KDef, +name: String) -> P124Callable:
  +count = da(p111v_get(ready,name))
  nt_choose(P124Callable,p112w_ready(ready,name) && U32.is_le(count,8),
    u => P124Callable{True{},count,p112w_symbol(name)},u => P124Callable{False{},0,""})


law p126sc_partner:
  for +calls: List<&2,String>
  for +left: P113DFunction
  for +index: P113ITable
  for +counts: KDef
  for +slot: U32
  for +done: KDef
  Maybe<&2,P113DFunction>

@unsafe
def p126sc_partner(calls,left,index,counts,slot,done):
  match calls:
    case Nil{}: None{}
    case Con{+name,rest}: p126sc_partner_next(rest,left,index,counts,slot,done,p126sc_partner_try(left,counts,slot,done,p113i_get(index,name,index_hash(name,2166136261),0)))


@unsafe
def p126sc_partner_next(+calls: List<&2,String>, +left: P113DFunction, +index: P113ITable, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: p126sc_partner(calls,left,index,counts,slot,done)
    case Some{right}: Some{right}


@unsafe
def p128bi_function(function: P113DFunction, index: KDef) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,p128bi_body(body,index)}


@unsafe
def w5c2_orig_set_if(is_abs: Bool, +tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match is_abs:
    case True{}: index_leaf(d, hash, Nil{})
    case False{}: index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash)))))

@unsafe
def p131rg_symbol_available(book: List<&2,KDef>) -> Bool:
  agy_str_eq(dk(lookup(book,p131rg_opaque())),"Absent")


@unsafe
def p144o_query(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> Bool:
  match facts:
    case P144OFacts{+names,valid}:
      nt_choose(Bool,valid,u => nb_contains(names,name),u => p144o_original(book,name))


@unsafe
def p144o_owned_term(+book: List<&2,KDef>, +query: String, term: KTerm) -> Bool:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(Bool,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => nb_contains(names,query),u => p144o_original(book,query))
    case _: p144o_original(book,query)

@unsafe
def w6_alias(+alias: KDef, +name: String) -> String:
  w7c_w6_alias_k(String.starts_with(name,"$p111.k."),alias,name)

@unsafe
def w4p_to_candidates(fns: List<&2,P113DFunction>, +ready: KDef, +signatures: List<&2,KDef>, +prodIdx: KDef) -> List<&2,P113DCandidate>:
  match fns:
    case Nil{}: []
    case Con{+fn,+rest}:
      match fn:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DCandidate>,p113d_ready(ready,name),
            u => w4p_to_candidates(rest,ready,signatures,prodIdx),
            u => Con{w4p_cand_of(w4p_try_wrap(fn,signatures,prodIdx)),w4p_to_candidates(rest,ready,signatures,prodIdx)})

@unsafe
def w7_pre_nodes(+book: List<&2,KDef>, xs: List<&2,String>, +remSet: KDef, +acc: List<&2,W7PreNode>) -> List<&2,W7PreNode>:
  match xs:
    case Nil{}: nt_reverse(W7PreNode,acc,[])
    case Con{+name,+rest}:
      nt_choose(List<&2,W7PreNode>,U32.is_gt(da(p111v_get(remSet,name)),0),
        u => w7_pre_nodes(book,rest,remSet,Con{W7PreNode{name,w7_pre_term(dv(lookup(book,name)),name,remSet,[])},acc}),
        u => w7_pre_nodes(book,rest,remSet,acc))

@unsafe
def p168j_eligible(segment: N111Segment, +direct: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(Bool,p169q_metadata(arity,result,incoming,flags),
        u => p169q_import(name,arity,direct),u => False{})



@unsafe
def p168j_candidates(segments: List<&2,N111Segment>, +imports: KDef,
    +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,P112MultiCandidate>,p169q_metadata(arity,result,incoming,flags),
            u => nt_choose(List<&2,P112MultiCandidate>,p112w_ready(imports,name),
              v => p168j_candidates(rest,imports,acc),
              v => nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
                w => p168j_candidates(rest,imports,Con{P112MultiCandidate{segment},acc}),
                w => p168j_candidates(rest,imports,acc))),
            u => p168j_candidates(rest,imports,acc))



@unsafe
def p168j_forwards(functions: List<&2,P113DFunction>, +ready: KDef,
    acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p168j_forwards(rest,ready,Con{p168j_forward_if(head,ready),acc})


# Exact Phase168 import-seeded emission preparation, with text left in the
# maintained cursor until IO consumes it. This record is not a certificate:
# normal entry constructs it only after both unchanged actual-program gates.
@unsafe
def p169a_namespace(+original: P111Program, +nodes: List<&2,P112SNode>,
    +view: List<&2,P113DFunction>, +certificate: P113ACertificate) -> String:
  +direct : P113DProgram = P113DProgram{P112StaticProgram{original,nodes},view}
  p114t_verify_done(P113AProgram{direct,certificate},p113a_verify_after(direct,certificate,""))



# The certificate is constructed by unchanged p169a_view from this exact
# request. scalar=False implies p118c_plan's ns_definitions permission=False;
# skip only that redundant failed derivation. unshared is not cold authority.
@unsafe
def p185cc_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_ctor") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,1) && U32.is_le(count,4) &&
          p114t_buffer(buffer) && p185cc_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P114TExpansion{p185cb_construct(stmt,dest,ctor,buffer,count,ids,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
# Ordinary match lowering already supplies the checked constructor identity
# and its field count. Unlike a late runtime-call recognizer, this factory has
# the expected CID; the unchanged verifier resolves its N111CtorId. Neither
# a source constructor spelling nor a tag alone is sufficient to take a word.
# The same structured IR reaches both QBE and direct x86.

@unsafe
def p185cb_bucket(bucket: List<&2,KDef>, +ready: Bool, +metadata: KDef) -> List<&2,KDef>:
  match bucket:
    case Nil{}: []
    case Con{head,rest}: Con{p185cb_tree(head,ready,metadata),p185cb_bucket(rest,ready,metadata)}

@unsafe
def p185cb_tree(+tree: KDef, +ready: Bool, +metadata: KDef) -> KDef:
  match tree:
    case KIndexLeaf{hash,bucket}: KIndexLeaf{hash,p185cb_bucket(bucket,ready,metadata)}
    case KIndexNode{hash,mask,left,right}: KIndexNode{hash,mask,p185cb_tree(left,ready,metadata),p185cb_tree(right,ready,metadata)}
    case KDef{name,+kind,cid,arity,typ,value,children,native,unsafe}:
      nt_choose(KDef,agy_str_eq(kind,"N111Id"),u => p185cb_entry(tree,ready,metadata),
        u => KDef{name,kind,cid,arity,typ,value,p185cb_bucket(children,ready,metadata),native,unsafe})

@unsafe
def w11_p186ch_take_r2(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, r2: List<&2,N111Arg>) -> P114TExpansion:
  match r2:
    case Con{a2,r3}: w11_p186ch_take_r3(stmt,dest,a0,a1,a2,r3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor(+stmt: N111Stmt, +dest: String, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{a0,r1}: w11_p186ch_ctor_r1(stmt,dest,a0,r1)
    case _: P114TExpansion{[stmt],False{}}

law x181_load:
  for +value: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  for +reg: X187Operand
  X188Seq
law x181_return:
  for +text: X188Seq
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x181_epilogue:
  for +frame: X181Frame
  X188Seq

@unsafe
def w4_u32_to_r10(source: Maybe<&2,X187Operand>, value: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match source:
    case Some{operand}: x188_i2("movd",operand,x188_reg(10,32))
    case None{}: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movl",x188_reg(10,32),x188_reg(10,32)))

@unsafe
def x192_float_conversion_buffer(name: String, id: U32, buffer: String,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x192_float_conversion_core(id),x181_store(name,frame,x188_reg(10,64))])

# CVTTSS2SI r64,xmm/m32: F3 REX.W 0F 2C /r. Reject every wrong width/class;
# ordinary/indexed/RIP memory forms share the existing checked ModRM encoder.
@unsafe
def x186_float_source(value: N111Value, frame: X181Frame) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_float_home(name,frame,True{})
    case _: None{}

@unsafe
def w2_float_const_load(value: N111Value, ids: N111Ids, frame: X181Frame, +xmm: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,0}:
      nt_choose(X188Seq,U32.is_eq(lo,0),u => x188_i2("pxor",xmm,xmm),
        u => x188_cat(x188_i2("movl",X187Imm{lo,0},x188_reg(10,32)),x188_i2("movd",x188_reg(10,32),xmm)))
    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movd",x188_reg(10,32),xmm))

@unsafe
def x186_float_publish(+name: String, source: X187Operand, +frame: X181Frame) -> X188Seq:
  x186_float_publish_to(x186_float_home(name,frame,True{}),name,source,frame)

law agy_reuse_find:
  for +cls: U32
  for +rname: String
  for +ids: N111Ids
  for stmts: List<&2,P113DStmt>
  AgyReuseMatch

@unsafe
def agy_reuse_find_if(+cls: U32, +rname: String, +ids: N111Ids, +cond: N111Value,
    +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>,
    m1: AgyReuseMatch, m2: AgyReuseMatch) -> AgyReuseMatch:
  match m1 m2:
    case AgyReuseMatch{ok1,+c1,yes2} AgyReuseMatch{ok2,+c2,no2}:
      +chosen = agy_reuse_ctor_pick(c1,c2)
      nt_choose(AgyReuseMatch,ok1 && ok2 && agy_reuse_ctor_compat(c1,c2),
        u => AgyReuseMatch{True{},chosen,Con{P113DIf{cond,yes2,no2},rest}},
        u => nt_choose(AgyReuseMatch,agy_reuse_pure_stmts(yes) && agy_reuse_pure_stmts(no),
          v => agy_reuse_prepend(P113DIf{cond,yes,no},agy_reuse_find(cls,rname,ids,rest)),
          v => AgyReuseMatch{False{},"",Con{P113DIf{cond,yes,no},rest}}))

@unsafe
def agy_reuse_find_call(+cls: U32, +rname: String, +ids: N111Ids, +cname: String,
    +typ: N111Type, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>) -> AgyReuseMatch:
  nt_choose(AgyReuseMatch,agy_str_eq(sym,"p111_rt_fail") || (agy_str_eq(sym,"p111_rt_sink") && agy_reuse_is_abort(rest)),
    u => AgyReuseMatch{True{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}},
    u => agy_reuse_find_ctor(cls,rname,ids,cname,typ,sym,args,rest))

@unsafe
def agy_reuse_find(cls,rname,ids,stmts):
  match stmts:
    case Nil{}: AgyReuseMatch{False{},"",[]}
    case Con{+head,+rest}:
      match head:
        case P113DScalar{N111Call{cname,typ,sym,args}}:
          agy_reuse_find_call(cls,rname,ids,cname,typ,sym,args,rest)
        case P113DScalar{other}:
          nt_choose(AgyReuseMatch,agy_reuse_pure_nstmt(other),
            u => agy_reuse_prepend(head,agy_reuse_find(cls,rname,ids,rest)),
            u => AgyReuseMatch{False{},"",stmts})
        case P113DIf{cond,yes,no}:
          agy_reuse_find_if(cls,rname,ids,cond,yes,no,rest,
            agy_reuse_find(cls,rname,ids,yes),agy_reuse_find(cls,rname,ids,no))
        case _: AgyReuseMatch{False{},"",stmts}

@unsafe
def x186_call_scan(args: List<&2,N111Arg>, +slots: KDef, +bytes: U32,
    +count: U32, +kind: U32) -> X186CallPlan:
  match args:
    case Nil{}: X186CallPlan{kind,count}
    case Con{N111Arg{typ,value},rest}:
      +value_kind = x186_call_value(value,slots,bytes)
      nt_choose(X186CallPlan,U32.is_ge(count,512),u => X186CallPlan{0,513},u =>
        nt_choose(X186CallPlan,U32.is_eq(value_kind,0),v => X186CallPlan{0,0},v =>
          x186_call_scan(rest,slots,bytes,U32.inc(count),U32.max(kind,value_kind))))

@unsafe
def x186_call_plan(args: List<&2,N111Arg>, frame: X181Frame) -> X186CallPlan:
  match frame:
    case X181Frame{slots,+bytes,+calls,params,symbol}:
      x186_call_capacity(x186_call_scan(args,slots,bytes,0,1),bytes,calls)

@unsafe
def x186_call_direct(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{+typ,+value},rest}:
      x188_cat(nt_choose(X188Seq,U32.is_lt(index,6),
        u => x188_cat(x181_load(value,ids,frame,x181_argreg(index)),x186_call_mask(typ,x186_call_reg32(index))),
        u => x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
          x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)})])),
        x186_call_direct(rest,ids,frame,U32.inc(index)))

@unsafe
def x186_call_snapshot(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame,
    +base: U32, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
        x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.add(base,U32.mul(index,8))}),
        x186_call_snapshot(rest,ids,frame,base,U32.inc(index))])

@unsafe
def agy_call_stack_args(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_cat(nt_choose(X188Seq,U32.is_ge(index,6),
        u => x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
          x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)})]),
        u => X188Empty{}),
        agy_call_stack_args(rest,ids,frame,U32.inc(index)))

law agy_call_reg_moves:
  for args: List<&2,N111Arg>
  for +slots: KDef
  for +index: U32
  List<&2,AgyCallMove>

@unsafe
def agy_call_reg_move_one(+index: U32, +typ: N111Type, +value: N111Value,
    +rest: List<&2,N111Arg>, +slots: KDef) -> List<&2,AgyCallMove>:
  +dst = agy_call_phys_reg(index)
  +src = agy_call_src_reg(value,slots)
  nt_choose(List<&2,AgyCallMove>,U32.is_eq(src,dst) && Bool.not(U32.is_eq(p111v_type(typ),1)),
    v => agy_call_reg_moves(rest,slots,U32.inc(index)),
    v => Con{AgyCallMove{index,dst,src,typ,value},agy_call_reg_moves(rest,slots,U32.inc(index))})

@unsafe
def agy_call_reg_moves(args,slots,index):
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}:
      nt_choose(List<&2,AgyCallMove>,U32.is_ge(index,6),u => [],
        u => agy_call_reg_move_one(index,typ,value,rest,slots))

@unsafe
def agy_call_emit_move(m: AgyCallMove, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match m:
    case AgyCallMove{+dstIdx,+dstReg,+srcReg,+typ,value}:
      nt_choose(X188Seq,U32.is_eq(srcReg,10),
        u => x188_cat(x188_i2("movq",x188_reg(10,64),x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx))),
        u => nt_choose(X188Seq,U32.is_eq(srcReg,dstReg),
          v => x186_call_mask(typ,x186_call_reg32(dstIdx)),
          v => x188_cat(x181_load(value,ids,frame,x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx)))))

@unsafe
def x181_load(value,ids,frame,reg):
  match value:
    case N111Local{name}: x181_local_load(name,frame,reg)
    case N111Const{lo,hi}: x188_i2("movabsq",X187Imm{lo,hi},reg)
    case N111Symbol{name}: x188_i2("leaq",X187Rip{name,0,0},reg)
    case N111FuncId{name}: x181_function_id(ids,name,reg)
    case N111CtorId{name}: x181_constructor_id(ids,name,reg)

@unsafe
def x181_address(base: N111Value, +offset: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),nt_choose(X188Seq,U32.is_eq(offset,0),u => X188Empty{},u =>
    x188_many([x188_i2("movabsq",X187Imm{offset,0},x188_reg(11,64)),x188_i2("addq",x188_reg(11,64),x188_reg(10,64))])))

@unsafe
def x185_late_previous(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_constructor(stmt,ids,site,
          nt_choose(P114TExpansion,x185_ctor_enabled(),
            v => p185cc_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x185_late_constructor(+stmt: N111Stmt, ids: N111Ids, site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_transport(p114t_expand(p118q_sized(stmt),ids,site)))

@unsafe
def x185_copy_value(value: N111Value, aliases: KDef) -> N111Value:
  match value:
    case N111Local{name}: N111Local{x185_copy_name(name,aliases)}
    case _: value

@unsafe
def x185_physical_source(value: N111Value, frame: X181Frame, reg: X187Operand) -> Bool:
  match value:
    case N111Local{name}: x185_physical_same(x185_physical_home(name,frame),reg)
    case _: False{}

@unsafe
def x185_physical_load(+value: N111Value, +ids: N111Ids, +frame: X181Frame, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,x185_physical_source(value,frame,reg),u => X188Empty{},u => x181_load(value,ids,frame,reg))

@unsafe
def x190_value_home(value: N111Value, frame: X181Frame) -> X185Physical:
  match value:
    case N111Local{name}: x185_physical_home(name,frame)
    case _: X185PhysicalNone{}

# A direct right operand survives the left move only when its home differs
# from the destination, or when that move is itself absent. Shifts keep r11/rcx.
@unsafe
def x185_sf_scalar(+stmt: N111Stmt, +buffers: KDef, +facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match stmt:
    case N111Store{+typ,N111Local{+buffer},+offset,value}:
      X185ScratchStep{P113DScalar{stmt},nt_choose(List<&2,X185ScratchCell>,x185_sf_cell(buffer,offset,typ,buffers),
        u => x185_sf_insert(X185ScratchCell{buffer,offset,typ,value},x185_sf_overlap(facts,buffer,offset,typ)),u => [])}
    case N111Store{typ,base,offset,value}: X185ScratchStep{P113DScalar{stmt},[]}
    case N111Load{+name,+typ,N111Local{+buffer},+offset}:
      nt_choose(X185ScratchStep,List.is_empty(&2,X185ScratchCell,facts),
        u => X185ScratchStep{P113DScalar{stmt},[]},
        u => X185ScratchStep{x185_sf_loaded(stmt,name,typ,nt_choose(Maybe<&2,N111Value>,x185_sf_cell(buffer,offset,typ,buffers),
          v => x185_sf_find(facts,buffer,offset,typ),v => None{})),x185_sf_written(facts,name)})
    case N111Load{name,typ,base,offset}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Set{name,typ,value}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Bin{name,typ,op,left,right}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Offset{name,base,bytes}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Alloca{name,bytes,align}: X185ScratchStep{P113DScalar{stmt},x186_sf_allocated(facts,name)}
    case N111Call{name,typ,symbol,args}: X185ScratchStep{P113DScalar{stmt},x186_sf_inline(x186_inline_op(stmt),facts)}
    case _: X185ScratchStep{P113DScalar{stmt},[]}

@unsafe
def x186_m_cell(+name: String, +offset: U32, +typ: N111Type, +buffers: KDef) -> Bool:
  x185_sf_cell(name,offset,typ,buffers) && U32.is_eq(U32.mod(offset,4),0)

@unsafe
def x186_p_zip(params: List<&2,String>, values: List<&2,N111Value>, +slots: KDef,
    +moves: List<&2,X186Move>) -> Maybe<&2,List<&2,X186Move>>:
  match params values:
    case Nil{} Nil{}: Some{nt_reverse(X186Move,moves,[])}
    case Con{+name,rest} Con{+value,more}:
      +home = p111v_get(slots,name)
      nt_choose(Maybe<&2,List<&2,X186Move>>,x186_p_word_home(home,True{}) &&
          x186_p_source_valid(value,slots) && Bool.not(x186_p_dest_used(home,moves)),
        u => x186_p_zip(rest,more,slots,Con{X186Move{name,value,home,x186_p_source(value,slots)},moves}),
        u => None{})
    case _ _: None{}

@unsafe
def x190_move_selected(name: String, value: N111Value, ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: x181_store(name,frame,wide)
    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x181_store(name,frame,x188_reg(10,64)))

# A 32-bit destination write both truncates and clears the upper half, including
# source=destination. Stack locals are complete allocated 64-bit frame words.
@unsafe
def w4c_e_kill_val(v: N111Value, state: X186ExprState) -> X186ExprState:
  match v:
    case N111Local{n}: x186_e_written(state,n)
    case _: state

@unsafe
def w5_sel_nonlast_ok(s: W5Sel, +dst: String, +forb: KDef) -> Bool:
  match s:
    case W5Sel{_,+n,_,_,_}:
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) && Bool.not(w4c_dia_has(forb,n))
    case W5SelNone{}: False{}

@unsafe
def w4c_dia_cond_ok(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4c_dia_has(writes,n))
    case N111Const{_,_}: True{}
    case _: False{}

@unsafe
def w5_dia_collapse_pair2(+h1: P113DStmt, +h2: P113DStmt, +t: String, +v: N111Value,
    s2: W5SnapSet, +afterLive: KDef) -> List<&2,P113DStmt>:
  match s2:
    case W5Snap{dst,dt,v2}:
      nt_choose(List<&2,P113DStmt>,w5_snap_local_eq(v2,t) && Bool.not(w4c_dia_has(afterLive,t)),
        u => [P113DScalar{N111Set{dst,dt,v}}],
        u => [h1,h2])
    case W5SnapNone{}: [h1,h2]

@unsafe
def w5b_val_unmodified(v: N111Value, +x: String, +allW: KDef) -> Bool:
  match v:
    case N111Const{_,_}: True{}
    case N111Local{+vn}: Bool.not(agy_str_eq(vn,x)) && Bool.not(w5b_has_name(vn,allW))
    case _: False{}

@unsafe
def w5b_can_hoist(stmt: P113DStmt, +nSets: List<&2,P113DStmt>, +preW: KDef, +ySetW: KDef,
    +nSetW: KDef, +setR: KDef, +allW: KDef) -> Bool:
  match stmt:
    case P113DScalar{N111Set{+x,+typ,+v}}:
      Bool.not(w5b_has_name(x,preW)) &&
      U32.is_eq(w5b_cnt_name(x,ySetW),1) &&
      U32.is_eq(w5b_cnt_name(x,nSetW),1) &&
      Bool.not(w5b_has_name(x,setR)) &&
      w5b_val_unmodified(v,x,allW) &&
      w5b_in_sets(x,typ,v,nSets)
    case _: False{}

@unsafe
def w5b_filter_sets(sets: List<&2,P113DStmt>, +hoistNames: KDef, +keepHoisted: Bool) -> List<&2,P113DStmt>:
  match sets:
    case Nil{}: []
    case Con{+h,+t}:
      match h:
        case P113DScalar{N111Set{+x,_,_}}:
          +isH = w5b_has_name(x,hoistNames)
          nt_choose(List<&2,P113DStmt>,nt_choose(Bool,keepHoisted,u => isH,u => Bool.not(isH)),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)},
            u => w5b_filter_sets(t,hoistNames,keepHoisted))
        case _:
          nt_choose(List<&2,P113DStmt>,keepHoisted,
            u => w5b_filter_sets(t,hoistNames,keepHoisted),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)})

@unsafe
def x186_x_source(value: N111Value, homes: KDef) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_x_home(name,homes)
    case N111Const{lo,0}: x186_x_home("$w2c_" ++ U32.show(lo),homes)
    case _: None{}

@unsafe
def w2_phys_load(lh: X185Physical, left: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match lh:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(left,ids,frame,x188_reg(10,64))

@unsafe
def w2_phys_val(value: N111Value, frame: X181Frame) -> X185Physical:
  match value:
    case N111Local{name}: x185_physical_home(name,frame)
    case _: X185PhysicalNone{}

@unsafe
def w2_tbl_store(+dest: String, sym: String, +frame: X181Frame, homes: KDef) -> X188Seq:
  w2_tbl_store_to(x186_x_home(dest,homes),dest,sym,frame)

@unsafe
def w2_tbl_clamp(val: N111Value, +last: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_many([
    x181_load(val,ids,frame,x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{last,0},x188_reg(10,64)),
    x188_i2("movl",X187Imm{last,0},x188_reg(11,32)),
    x188_i2("cmovaeq",x188_reg(11,64),x188_reg(10,64))])

@unsafe
def w4b_xl_start_reg(+tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>, +hotConsts: List<&2,U32>) -> U32:
  +need = U32.add(w4b_xl_count_params(tparams,0,tparams,nodes,0),w4b_u32_len(hotConsts,0))
  nt_choose(U32,U32.is_le(need,6),u => 10,u =>
    nt_choose(U32,U32.is_ge(need,8),u => 8,u => U32.sub(16,need)))

@unsafe
def x190_l_value(value: N111Value, ids: KDef) -> U32:
  match value:
    case N111Local{name}: x190_l_bit(name,ids)
    case _: 0

@unsafe
def x190_l_values(values: List<&2,N111Value>, +ids: KDef) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.or(x190_l_value(value,ids),x190_l_values(rest,ids))

@unsafe
def x190_l_names(names: List<&2,String>, +ids: KDef) -> U32:
  match names:
    case Nil{}: 0
    case Con{name,rest}: U32.or(x190_l_bit(name,ids),x190_l_names(rest,ids))

# Greedy priority is total body/setup read count, with body encounter ties. Saved homes are
# already installed and never enter this candidate pool. At most 32 names are
# considered; zero-read writes still matter whenever their name is a candidate.
@unsafe
def x190_l_args(args: List<&2,N111Arg>, +ids: KDef) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.or(x190_l_value(value,ids),x190_l_args(rest,ids))

@unsafe
def x190_l_inline(operation: X186InlineOp, reads: U32, writes: U32, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match operation env:
    case X186InlineF32{name,id,buffer} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(x190_l_bit(buffer,ids),x190_l_bit(name,ids),flow,env)
    case _ _: x190_l_call(reads,writes,flow,env)

@unsafe
def x190_l_incoming(params: List<&2,String>, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match params env:
    case Nil{} _: flow
    case Con{name,rest} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(0,x190_l_bit(name,ids),x190_l_incoming(rest,flow,env),env)

# Prologue copies read ABI arguments in order. A candidate parameter may use
# only a source register already consumed at that point. Nonparameters begin
# after the prologue and have no such restriction.
@unsafe
def w5c_pj_collect(names: List<&2,String>, +groups: List<&2,U32>, +header: U32,
    +ranges: KDef, +bReads: KDef, +bWrites: KDef, +bit: U32, st: W5CPJState) -> W5CPJState:
  match names:
    case Nil{}: st
    case Con{+name,rest}:
      w5c_pj_collect(rest,groups,header,ranges,bReads,bWrites,U32.shl(bit),
        w5c_pj_collect_one(name,x190_j_home(groups,bit,0),bit,header,ranges,bReads,bWrites,st))

@unsafe
def x190_branch_allowed(name: String, typ: N111Type, op: String,
    condition: N111Value, facts: X190BranchFacts) -> Bool:
  x190_branch_allowed_when(x190_branch_reuse_enabled(),name,typ,op,condition,facts)

# The existing layout falls through to yes and jumps to no. Invert the exact
# signed/unsigned predicate; no complementary-condition or dominance inference.
@unsafe
def x190_branch_load(value: N111Value, ids: N111Ids, frame: X181Frame, physical: X185Physical, scratch: X187Operand) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(value,ids,frame,scratch)

# Comparisons preserve both physical operands, including equal homes. Unknown
# operands use distinct reserved scratch registers outside the allocated pool.
@unsafe
def x198h_tail(fid: String, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_many([
        x181_load(N111Local{"state"},ids,frame,x188_reg(7,64)),
        x188_i2("movl",X187Imm{4294967295,0},X187Mem{7,32}),
        x186_saves_text(x186_saves_mask(frame),0,True{}),
        x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
        x188_i1("jmp",X187Target{p111q_symbol(fid)})]),chunks},next,True{},error}

@unsafe
def w12_i_st_and(body: List<&2,P113DStmt>, +orig: List<&2,P113DStmt>, +wantXor: Bool, +oRaw: String, +b1: String, +oExp: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+b2,t,op,N111Local{b1b},N111Const{8388607,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"and") && agy_str_eq(b1b,b1),
        u => w12_i_st_opt_exp(rest,orig,wantXor,oRaw,b2,oExp),u => orig)
    case _: orig

@unsafe
def x191_load_alu(+loaded: String, +typ: N111Type, address: X191Address,
    body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Bin{name,+other,+op,left,right}},rest}:
      nt_choose(Maybe<&2,X191Pick>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x191_alu_found(x191_alu_left(loaded,op,left,right),rest,name,other,op,address),u => None{})
    case _: None{}

@unsafe
def x191_access(+address: X191Address, +pointer: String, body: List<&2,P113DStmt>,
    +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match address body:
    case X191Address{+base,+index,+scale,disp} Con{P113DScalar{N111Load{+name,+typ,N111Local{source},+offset}},+rest}:
      nt_choose(Maybe<&2,X191Pick>,agy_str_eq(pointer,source) && U32.is_le(offset,2147483647),u =>
        x191_load_chosen(x191_load_alu(name,typ,X191Address{base,index,scale,offset},rest,facts),
          rest,name,typ,X191Address{base,index,scale,offset}),u => None{})
    case X191Address{base,index,scale,disp} Con{P113DScalar{N111Store{typ,N111Local{source},+offset,value}},rest}:
      nt_choose(Maybe<&2,X191Pick>,agy_str_eq(pointer,source) && U32.is_le(offset,2147483647),
        u => Some{X191Pick{rest,X191Store{typ,X191Address{base,index,scale,offset},value}}},u => None{})
    case _ _: None{}

@unsafe
def x191_reg(value: N111Value, frame: X181Frame, fallback: U32) -> U32:
  x191_reg_home(x190_value_home(value,frame),fallback)

@unsafe
def x191_destination(name: String, frame: X181Frame) -> U32:
  x191_reg_home(x185_physical_home(name,frame),0)

@unsafe
def x191_publish(+name: String, +reg: U32, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(reg,x191_destination(name,frame)) && Bool.not(U32.is_eq(reg,0)),
    u => X188Empty{},u => x181_store(name,frame,x188_reg(reg,64)))

@unsafe
def x192_address_aliases_done(aliases: List<&2,X192AddressAlias>, +facts: X190BranchFacts) -> Bool:
  match aliases:
    case Nil{}: True{}
    case Con{X192AddressAlias{name,address,+reads},rest}:
      U32.is_gt(reads,0) && x192_address_name(name,reads,facts) && x192_address_aliases_done(rest,facts)

@unsafe
def x192_address_fuse_pair(+load: X191Operation, +stmt: P113DStmt,
    +rest: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match load stmt:
    case X191Load{+loaded,+typ,address} P113DScalar{N111Bin{name,+other,+op,left,right}}:
      nt_choose(List<&2,X192AddressRow>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x192_address_fuse_left(x191_alu_left(loaded,op,left,right),load,stmt,name,other,op,address,
          x192_address_fuse(rest,facts)),
        u => Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)})
    case _ _: Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)}

@unsafe
def x192_address_fuse(rows: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match rows:
    case Con{X192AddressMemory{load},Con{X192AddressPlain{stmt},rest}}:
      x192_address_fuse_pair(load,stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_address_fuse(rest,facts)}
    case Nil{}: []

law x192_address_scan:
  for +body: List<&2,P113DStmt>
  for +scaled: String
  for +index: N111Value
  for +scale: U32
  for +aliases: List<&2,X192AddressAlias>
  for +uses: U32
  for +accesses: U32
  for +fuel: U32
  for +reversed: List<&2,X192AddressRow>
  for +facts: X190BranchFacts
  Maybe<&2,X192AddressPick>

@unsafe
def x192_address_memory(found: Maybe<&2,X191Address>, +stmt: P113DStmt, +rest: List<&2,P113DStmt>,
    +scaled: String, +index: N111Value, +scale: U32, +aliases: List<&2,X192AddressAlias>,
    +uses: U32, +accesses: U32, +fuel: U32, +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match found stmt:
    case Some{address} P113DScalar{N111Load{+name,typ,N111Local{pointer},+offset}}:
      nt_choose(Maybe<&2,X192AddressPick>,U32.is_le(offset,2147483647) && x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,x192_address_used(aliases,pointer),uses,U32.inc(accesses),fuel,
          Con{X192AddressMemory{X191Load{name,typ,x192_address_displacement(address,offset)}},reversed},facts),u => None{})
    case Some{address} P113DScalar{N111Store{typ,N111Local{pointer},+offset,value}}:
      nt_choose(Maybe<&2,X192AddressPick>,U32.is_le(offset,2147483647),
        u => x192_address_scan(rest,scaled,index,scale,x192_address_used(aliases,pointer),uses,U32.inc(accesses),fuel,
          Con{X192AddressMemory{X191Store{typ,x192_address_displacement(address,offset),value}},reversed},facts),u => None{})
    case _ _: None{}

@unsafe
def x192_address_scan_plain(+stmt: P113DStmt, rest: List<&2,P113DStmt>, +scaled: String, +index: N111Value, +scale: U32,
    +aliases: List<&2,X192AddressAlias>, +uses: U32, +accesses: U32, +fuel: U32,
    +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match stmt:
    case P113DScalar{N111Load{name,typ,N111Local{pointer},offset}}:
      x192_address_memory(x192_address_lookup(aliases,pointer),stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case P113DScalar{N111Store{typ,N111Local{pointer},offset,value}}:
      x192_address_memory(x192_address_lookup(aliases,pointer),stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case P113DScalar{N111Bin{+name,typ,op,left,right}}:
      nt_choose(Maybe<&2,X192AddressPick>,x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,aliases,uses,accesses,fuel,Con{X192AddressPlain{stmt},reversed},facts),u => None{})
    case P113DScalar{N111Set{+name,typ,value}}:
      nt_choose(Maybe<&2,X192AddressPick>,x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,aliases,uses,accesses,fuel,Con{X192AddressPlain{stmt},reversed},facts),u => None{})
    case _: None{}

@unsafe
def x192_address_scan_step(body: List<&2,P113DStmt>, +scaled: String, +index: N111Value, +scale: U32,
    +aliases: List<&2,X192AddressAlias>, +uses: U32, +accesses: U32, +fuel: U32,
    +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match body:
    case Con{P113DScalar{N111Offset{+name,+base,N111Local{source}}},rest}:
      nt_choose(Maybe<&2,X192AddressPick>,agy_str_eq(source,scaled) &&
          x192_address_write(name,scaled,index,aliases) && Bool.not(x185_sf_source(base,name)),
        u => x192_address_scan(rest,scaled,index,scale,Con{X192AddressAlias{name,X191Address{base,index,scale,0},0},aliases},
          U32.inc(uses),accesses,fuel,reversed,facts),u => None{})
    case Con{stmt,rest}:
      x192_address_scan_plain(stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case Nil{}: None{}

@unsafe
def x192_address_scan(body,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts):
  nt_choose(Maybe<&2,X192AddressPick>,U32.is_ge(accesses,2) && x192_address_name(scaled,uses,facts) &&
      x192_address_aliases_done(aliases,facts),
    u => Some{X192AddressPick{body,x192_address_fuse(nt_reverse(X192AddressRow,reversed,[]),facts)}},
    u => nt_choose(Maybe<&2,X192AddressPick>,U32.is_eq(fuel,0),v => None{},
      v => x192_address_scan_step(body,scaled,index,scale,aliases,uses,accesses,U32.sub(fuel,1),reversed,facts)))

@unsafe
def x198qm_item(+item: X187Parsed, +previous: X191FrameStore, +output: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match item:
    case PInst{X187Instruction{op,[X187Target{name}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"call") && agy_str_eq(name,"p111_rt_op"),
        u => x198qm_window(output,X188One{item}),u => Con{x191_ff_item(item,previous),output})
    case PInst{X187Instruction{op,[X187Reg{r,32,False{}},X187Reg{x,128,True{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movd") && w2c_drop_movd_roundtrip(output,r,x),
        u => output,u => Con{x191_ff_item(item,previous),output})
    case _: Con{x191_ff_item(item,previous),output}

@unsafe
def w4c_sub_fold2(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        u => w4c_sub_fold3(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_check_cmp(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
          U32.is_eq(cr,c) && U32.is_eq(cw,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BImmRegNone{}: w4b_copy_check_test(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,fnItems,out)

@unsafe
def w4c_backedge_coalesce(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +totR = w4c_count_reads(items,W4CMEmpty{})
  +totW = w4c_count_writes(items,W4CMEmpty{})
  w4c_join_bbs(w4c_coal_bbs(w4c_split_bb(items,[],[]),totR,totW))

# Sub-pass C4: Dead negative-%rbp stack-slot store elimination
@unsafe
def w5_g1_b(+d1: U32, +rB: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{+op1,+rA,64,dr1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op1) && U32.is_eq(dr1,rB) && Bool.not(U32.is_eq(rA,rB)) &&
        Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)),
        u => w5_g1_c(d1,op1,rA,rB,w5_as_load_rbp(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G2: movq %rC, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst
@unsafe
def w5b_promote_one(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w5b_promote_pick(rFree,isR12,items,w5b_scan_slots(items,isR12,False{},W5BSlotScan{W4CMEmpty{},W4CMEmpty{}}))

@unsafe
def w11_rot16_s6(+rotOp: String, +rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i6,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i6,"andq",65535,rA,64) && w5b_reg_dead_fast(rB,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{rotOp,[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_tail(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iT,rJ}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(iT,"testl",rB,32,rB,32),
        u => w11_cmp_jcc_j(cmpInst,cc,rA,rB,inv,rJ,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s4(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32, +opS: String,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"movzbl",rT1,8,rT1,32) && w5b_reg_dead_fast(rT2,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s4(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,r5}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"cmovneq",10,64,11,64),
        u => w11_sel_bounce_s5(srcY,rN,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def x199s_apply(+code: X188Seq,slots: KDef,label: String) -> X188Seq:
  x199s_check(x199s_flat([code],640,[]),code,slots,label)

@unsafe
def x191_select_emit(condition: N111Value, plan: X191SelectPlan,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X191SelectPlan{+typ,yes,no,names}:
      x188_many([x181_load(condition,ids,frame,x188_reg(0,64)),
        x181_load(yes,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),
        x181_load(no,ids,frame,x188_reg(11,64)),x181_mask(typ,x188_reg(11,32)),
        x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
        x188_i2(x181_width(typ,"cmovneq","cmovnel"),x188_width_reg(typ,10),x188_width_reg(typ,11)),
        x191_select_publish(names,frame)])

@unsafe
def x197ms_destination(names: List<&2,String>, frame: X181Frame) -> X185Physical:
  match names:
    case Con{name,rest}: x185_physical_home(name,frame)
    case Nil{}: X185PhysicalNone{}

# A store never changes its source register. Skipping a same-home publication
# preserves the actual assigned value; stack publications are always emitted.
@unsafe
def x197ms_publish(names: List<&2,String>, +frame: X181Frame, +result: X187Operand) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{+name,rest}:
      x188_cat(nt_choose(X188Seq,x185_physical_same(x185_physical_home(name,frame),result),
        u => X188Empty{},u => x181_store(name,frame,result)),x197ms_publish(rest,frame,result))

# CMP has already read both original operands. If result aliases yes, preserve
# that value and select no under the complementary predicate. Otherwise result
# either already holds no, or receives a width-correct MOV before CMOV yes.
# Explicit MOVL normalization covers a not-taken CMOV and noncanonical high bits.
@unsafe
def x197ms_select(+typ: N111Type, +op: String, +names: List<&2,String>, +frame: X181Frame,
    +yw: X187Operand, +yn: X187Operand, +nw: X187Operand, +nn: X187Operand,
    +dw: X187Operand, +dn: X187Operand) -> X188Seq:
  x188_many([
    nt_choose(X188Seq,x188_operand_same(dw,yw),u =>
      x188_many([x181_mask(typ,dn),
        x188_i2("cmov" ++ x197ms_inverse(op) ++ x181_width(typ,"q","l"),
          x188_physical_width(typ,nw,nn),x188_physical_width(typ,dw,dn))]),u =>
      x188_many([
        nt_choose(X188Seq,x188_operand_same(dw,nw),v => x181_mask(typ,dn),v =>
          x188_i2(x181_width(typ,"movq","movl"),x188_physical_width(typ,nw,nn),x188_physical_width(typ,dw,dn))),
        x188_i2("cmov" ++ x181_condition(op) ++ x181_width(typ,"q","l"),
          x188_physical_width(typ,yw,yn),x188_physical_width(typ,dw,dn))])),
    x197ms_publish(names,frame,dw)])

@unsafe
def w2_cmov_load(value: N111Value, ids: N111Ids, frame: X181Frame, +regIdx: U32) -> X188Seq:
  match value:
    case N111Const{+lo,0}: x188_i2("movl",X187Imm{lo,0},x188_reg(regIdx,32))
    case _: x181_load(value,ids,frame,x188_reg(regIdx,64))

@unsafe
def x192_p_binary(+stmt: N111Stmt, +facts: KDef) -> N111Stmt:
  match stmt:
    case N111Bin{+name,typ,+op,+left,+right}:
      nt_choose(N111Stmt,x190_branch_width(typ) && (agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) &&
          x192_p_boolean(left,facts) && (x192_p_constant(right,0) || x192_p_constant(right,1)),
        u => nt_choose(N111Stmt,Bool.xor(agy_str_eq(op,"eq"),x192_p_constant(right,0)),
          v => N111Set{name,N111U32{},left},v => N111Bin{name,N111U32{},"xor",left,N111Const{1,0}}),
        u => stmt)
    case _: stmt

@unsafe
def x192_p_plan(+condition: N111Value, facts: KDef, plan: Maybe<&2,X191SelectPlan>) -> Maybe<&2,List<&2,P113DStmt>>:
  match plan:
    case Some{X191SelectPlan{+typ,+yes,+no,+names}}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,x186_e_equal(yes,no),
        u => Some{x192_p_chain(names,typ,yes,False{})},u =>
          nt_choose(Maybe<&2,List<&2,P113DStmt>>,x192_p_boolean(condition,facts) &&
              ((x192_p_constant(yes,1) && x192_p_constant(no,0)) ||
               (x192_p_constant(yes,0) && x192_p_constant(no,1))),
            v => Some{x192_p_chain(names,typ,condition,x192_p_constant(yes,0))},v => None{}))
    case None{}: None{}

def x181_epilogue(frame):
  x188_many([x186_saves_text(x186_saves_mask(frame),0,True{}),
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret")])

def x181_return(text,frame,code):
  match code:
    case X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_cat(text,x181_epilogue(frame)),chunks},next,True{},error}

@unsafe
def x181_load_results(names: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match names:
    case Nil{}: code
    case Con{name,rest}:
      x181_load_results(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_results"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x181_tail_snapshot(values: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match values:
    case Nil{}: code
    case Con{head,rest}:
      x181_tail_snapshot(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(head,ids,frame,x188_reg(10,64)),
          x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",x188_reg(10,64),X187Mem{11,offset})]),code))

@unsafe
def x181_tail_moves(params: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match params code:
    case Nil{} X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_i1("jmp",X187Target{x181_loop_label(frame)}),chunks},next,True{},error}
    case Con{name,rest} _:
      x181_tail_moves(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x181_prologue(+frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,+bytes,+calls,+params,+symbol}:
      x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
        x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
        x188_i2("subq",X187Imm{U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48),0},x188_reg(4,64)),
        x186_saves_text(x186_saves_mask(frame),0,False{}),x181_incoming(params,0,frame,[])])

law w2_asr_body:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

law w2_asr_replace_or:
  for +stmts: List<&2,P113DStmt>
  for +s1: String
  for +m: String
  for +v: N111Value
  for +k: U32
  for +fuel: U32
  List<&2,P113DStmt>

@unsafe
def w2_asr_replace_head(+h: P113DStmt, +rest: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:
  match h:
    case P113DScalar{N111Bin{dest,typ,op,+l,+r}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"or") &&
          ((agy_str_eq(w2_asr_val_local(l),s1) && agy_str_eq(w2_asr_val_local(r),m)) ||
           (agy_str_eq(w2_asr_val_local(l),m) && agy_str_eq(w2_asr_val_local(r),s1))),
        u => Con{P113DScalar{N111Bin{dest,N111U32{},"sar",v,N111Const{k,0}}},w2_asr_body(rest)},
        u => nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),
          z => Con{h,w2_asr_body(rest)},
          z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))}))
    case _: nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),
      z => Con{h,w2_asr_body(rest)},
      z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))})

@unsafe
def w2_asr_replace_or_go(stmts: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: []
    case Con{h,rest}: w2_asr_replace_head(h,rest,s1,m,v,k,fuel)

@unsafe
def w2_asr_replace_or(stmts,s1,m,v,k,fuel):
  nt_choose(List<&2,P113DStmt>,U32.is_eq(fuel,0),u => stmts,u => w2_asr_replace_or_go(stmts,s1,m,v,k,fuel))

@unsafe
def w2_asr_try(found: Maybe<&2,String>, +s1: String, +v: N111Value, +k: U32,
    +sel_rest: List<&2,P113DStmt>, +orig_head: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match found:
    case Some{m}:
      nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,orig_head),
        u => Con{orig_head,w2_asr_body(orig_tail)},
        u => Con{orig_head,w2_asr_replace_or(orig_tail,s1,m,v,k,24)})
    case None{}: Con{orig_head,w2_asr_body(orig_tail)}

@unsafe
def w2_asr_after(+s1: String, +s2: String, +v1: N111Value, +k: U32, +after: List<&2,P113DStmt>,
    +h1: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +sel = x194_ps_pick(after)
  w2_asr_try(w2_asr_match_sel(sel,s2,w2_asr_mask(k)),s1,v1,k,w2_asr_sel_rest(sel),h1,orig_tail)

@unsafe
def w2_asr_triple(+h1: P113DStmt, +h2: P113DStmt, +h3: P113DStmt, +after: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match h1 h2 h3:
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Set{+s1c,t1c,N111Local{+s1ref}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op1,"shr") && agy_str_eq(op2,"shr") &&
          agy_str_eq(s1,s1ref) && U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1c,s2,v1,k,after,h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}
         _:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op1,"shr") && agy_str_eq(op2,"shr") &&
          U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1,s2,v1,k,Con{h3,after},h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case _ _ _: Con{h1,w2_asr_body(Con{h2,Con{h3,after}})}

@unsafe
def w2_asr_body(body):
  match body:
    case Nil{}: []
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_body(yes),w2_asr_body(no)},w2_asr_body(rest)}
    case Con{h1,Con{h2,Con{h3,after}}}: w2_asr_triple(h1,h2,h3,after)
    case Con{head,rest}: Con{head,w2_asr_body(rest)}

@unsafe
def x198a_id(+record: KDef) -> P113KFact:
  nt_choose(P113KFact,agy_str_eq(dk(record),"N111Id"),u => p113k_exact(da(record),0),u => p113k_bound(64))

law agy_da_try_window:
  for +s0: N111Stmt
  for +s1: N111Stmt
  for +s2: N111Stmt
  for +dsts: List<&2,String>
  for +target: String
  for +dargs: List<&2,N111Value>
  for +s4: N111Stmt
  for +rest: List<&2,P113DStmt>
  for +ids: N111Ids
  for +seq: U32
  List<&2,P113DStmt>

@unsafe
def agy_da_rewrite_body(body: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{+s0},
         Con{P113DScalar{+s1},
         Con{P113DScalar{+s2},
         Con{P113DCall{+dsts,+target,+dargs},
         Con{P113DScalar{+s4},+rest}}}}}:
      agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq)
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,agy_da_rewrite_body(yes,ids,U32.add(seq,1)),agy_da_rewrite_body(no,ids,U32.add(seq,17))},
          agy_da_rewrite_body(rest,ids,U32.add(seq,33))}
    case Con{head,rest}:
      Con{head,agy_da_rewrite_body(rest,ids,seq)}

@unsafe
def agy_da_emit_if(+cls: U32, +n_val: N111Value, +seed_val: N111Value, +acc0_val: N111Value, +accout: String,
    +s0: N111Stmt, +s1: N111Stmt, +s2: N111Stmt, +dsts: List<&2,String>, +target: String,
    +dargs: List<&2,N111Value>, +s4: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  +k = U32.shln(1,U32.to_nat(cls))
  +pfx = "agy_da_" ++ U32.show(seq) ++ "_"
  +cond = pfx ++ "c"
  +n32 = pfx ++ "n"
  +s32 = pfx ++ "s"
  +prod = pfx ++ "p"
  +a32 = pfx ++ "a"
  +fast : List<&2,P113DStmt> = [
    P113DScalar{N111Set{n32,N111U32{},n_val}},
    P113DScalar{N111Set{s32,N111U32{},seed_val}},
    P113DScalar{N111Bin{prod,N111U32{},"mul",N111Local{n32},N111Local{s32}}},
    P113DScalar{N111Set{a32,N111U32{},acc0_val}},
    P113DScalar{N111Bin{accout,N111U32{},"add",N111Local{a32},N111Local{prod}}}]
  +slow : List<&2,P113DStmt> = [
    P113DScalar{s0},P113DScalar{s1},P113DScalar{s2},P113DCall{dsts,target,dargs},P113DScalar{s4}]
  Con{P113DScalar{N111Bin{cond,N111U64{},"ule",n_val,N111Const{k,0}}},
    Con{P113DIf{N111Local{cond},fast,slow},
      agy_da_rewrite_body(rest,ids,U32.add(seq,1))}}


@unsafe
def agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq):
  match s0 s1 s2 dsts dargs s4:
    case N111Store{N111U64{},N111Local{b0},0,N111Const{+cls,0}}
         N111Store{N111U64{},N111Local{b1},8,+seed_val}
         N111Call{+arr,N111U64{},op_sym,Con{N111Arg{_,N111Local{st0}},Con{N111Arg{_,N111Const{71,0}},Con{N111Arg{_,N111Local{b2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}
         Con{+aout,Con{+accout,Nil{}}}
         Con{+n_val,Con{i0_val,Con{N111Local{arrarg},Con{+acc0_val,Nil{}}}}}
         N111Call{_,N111U64{},sink_sym,Con{N111Arg{_,N111Local{st1}},Con{N111Arg{_,N111Local{sinkarg}},Nil{}}}}:
      +ok = agy_str_eq(b0,b1) && agy_str_eq(b0,b2) &&
            agy_str_eq(st0,"state") && agy_str_eq(st1,"state") &&
            agy_str_eq(op_sym,"p111_rt_op") && agy_str_eq(sink_sym,"p111_rt_sink") &&
            U32.is_le(cls,16) && agy_str_eq(arrarg,arr) && agy_str_eq(sinkarg,aout) &&
            Bool.not(agy_str_eq(aout,accout)) && agy_da_is_marked(target,ids) &&
            Bool.not(agy_da_stmts_use(rest,arr)) && Bool.not(agy_da_stmts_use(rest,aout))
      nt_choose(List<&2,P113DStmt>,ok,
        u => agy_da_emit_if(cls,n_val,seed_val,acc0_val,accout,s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq),
        u => Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)})
    case _ _ _ _ _ _:
      Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)}



law agy_zip_target_sym:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  String

law agy_zip_wrap_direct:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  for +orig: X181Output
  for +entry: KDef
  X181Output

@unsafe
def x198pw_data(+book: List<&2,KDef>,+ty: String,+leaf: String,+node: String) -> Bool:
  +d = lookup(book,ty)
  agy_str_eq(dk(d),"ADT") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d)) &&
    x198pw_layout(dc(d),ty,leaf,node)

@unsafe
def agy_zip_wrap_direct(name,symbol,ids,orig,entry):
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  +slow = "agy_zip_slow_" ++ symbol
  nt_choose(X181Output,agy_str_eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => x181_program_join(agy_zip_emit_wrapper(symbol,slow,da(leaf_id),da(node_id)),orig),
    u => orig)

@unsafe
def agy_zip_target_sym(name,symbol,ids):
  +entry = agy_zip_get_mark(name,ids)
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  nt_choose(String,agy_str_eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => "agy_zip_slow_" ++ symbol,
    u => symbol)



# ============================================================================
# AGY-W2-ROREC: Borrowed Native-Recursion Fast Path for Read-Only ADT->U32
# ============================================================================

# Compact expression encoding in KTerm:
#   kt("RoConst", "", val, 0, [])
#   kt("RoParamX", "", 0, 0, [])
#   kt("RoField", "", field_idx, 0, [])
#   kt("RoRec", "", field_idx, 0, [])
#   kt("RoBin", op, 0, 0, [left, right])
# Case encoding in KTerm:
#   kt("RoCase", ctor_identity, ctor_arity, 0, [expr])
# Plan stored in N111Ids fs under "$agy.rorec/" ++ "$direct." ++ owner:
#   KDef{key, "AgyRoRecCertified", arity, 0, kt("RoCases", "", 0, 0, cases), kt("None", "", 0, 0, []), [], False{}, False{}}

@unsafe
def agy_ro_check_cids(cases: List<&2,KTerm>, +ids: N111Ids) -> Bool:
  match cases:
    case Nil{}: True{}
    case Con{+c,rest}:
      +cid = x198pw_cid(nm(c),ids)
      x198pw_has_cid(cid,ix(c)) && agy_ro_check_cids(rest,ids)

@unsafe
def agy_ro_emit_nullary_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_eq(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => nt_choose(X188Seq,U32.is_eq(qt(c),1),
          v => x188_many([
            x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
            x188_i1("je",X187Target{prefix ++ "_in" ++ U32.show(idx)}),
            agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
          v => agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))))

@unsafe
def agy_ro_emit_boxed_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_gt(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx)))

@unsafe
def agy_ro_emit_wrapper(+symbol: String, +slow: String, +arity: U32, +cases: List<&2,KTerm>, +ids: N111Ids) -> X181Output:
  +prefix = ".Lagyro_" ++ symbol
  +rec_lbl = prefix ++ "_rec"
  +has_x = U32.is_eq(arity,2)
  # Check mode == 0 and depth == 0:
  # arity 1: rdi=state, rsi=e, rdx=mode, rcx=depth, r8=value
  # arity 2: rdi=state, rsi=e, rdx=x, rcx=mode, r8=depth, r9=value
  +mode_reg = nt_choose(U32,has_x,u => 1,u => 2)
  +depth_reg = nt_choose(U32,has_x,u => 8,u => 1)
  +entry = x188_many([
    x188_i2("cmpq",X187Imm{0,0},x188_reg(mode_reg,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(depth_reg,64)),
    x188_i1("jne",X187Target{slow}),
    # Check tag of e (%rsi)
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(0,64)),
    x188_i1("je",X187Target{prefix ++ "_null_entry"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    # tag == 0x82 (130): check rc >= 2
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jb",X187Target{slow}),
    # Save callee-saved regs + state/e/x for possible bailout
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(15,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    # Success! Decrement root refcount by 1
    x188_i2("movq",X187Indexed{12,15,8,0},x188_reg(10,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Indexed{12,15,8,0}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Nullary entry (tag == 1): no refcount to decrement
    x188_label(prefix ++ "_null_entry"),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(12,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Miss / bailout: restore all incoming registers and jump to slow
    x188_label(prefix ++ "_miss"),
    x188_i1("popq",x188_reg(6,64)),
    x188_i1("popq",x188_reg(7,64)),
    nt_choose(X188Seq,has_x,
      u => x188_many([
        x188_i2("movl",x188_reg(13,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
        x188_i2("xorl",x188_reg(9,32),x188_reg(9,32))]),
      u => x188_many([
        x188_i2("xorl",x188_reg(2,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32))])),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow}),
    # Internal recursive helper
    x188_label(rec_lbl),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("je",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_null"}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(8,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_boxed"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",X187Indexed{12,8,8,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_label(prefix ++ "_boxed"),
    agy_ro_emit_boxed_dispatch(cases,ids,prefix,0),
    x188_label(prefix ++ "_null"),
    agy_ro_emit_nullary_dispatch(cases,ids,prefix,0),
    agy_ro_emit_arms(cases,prefix,0),
    x188_label(prefix ++ "_bail"),
    x188_i2("movl",X187Imm{1,0},x188_reg(11,32)),
    x188_i0("ret")])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    entry,X188One{PSize{symbol}}])],""}

@unsafe
def agy_al_is_match(+name: String, +params: List<&2,String>, +ids: N111Ids) -> Bool:
  agy_bp_has_mark(ids,"$agy.bp/arr") &&
  (agy_str_eq(name,"$direct.Array.to_list.go~0") || agy_str_eq(name,"Array.to_list.go~0")) &&
  U32.is_eq(nt_count(String,params),6) &&
  U32.is_lt(agy_al_ctor_id(ids,"Con"),65536)

# Fast path for p114r_$direct.Array.to_list.go~0(st=%rdi, a=%rsi, acc=%rdx, mode=%rcx, depth=%r8, val=%r9)
@unsafe
def x181_program_value(value: N111Value, +available: KDef) -> String:
  match value:
    case N111Symbol{symbol}: x181_program_symbol(symbol,available)
    case _: ""

@unsafe
def x181_forward(+function: P113DFunction, +ready: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      nt_choose(X181Output,x181_forward_selected(name,ready),
        u => nt_choose(X181Output,U32.is_eq(result,1) &&
            U32.is_eq(da(p111v_get(ready,name)),nt_count(NC_Binding,params)),
          v => X181Output{[x188_many([X188One{PSection{1}},X188One{PType{p112w_symbol(name),2}},
            x188_label(p112w_symbol(name)),x188_i1("jmp",X187Target{p113e_symbol(name)}),
            X188One{PSize{p112w_symbol(name)}}])],""},
          v => X181Output{[],"x86 imported worker signature mismatch: " ++ name}),
        u => X181Output{[],""})

@unsafe
def x199s_again(values: List<&2,N111Value>, state: X199ScanState) -> Bool:
  match values state:
    case Con{a,Con{b,Con{c,Con{d,Nil{}}}}} X199ScanState{+env,+loads,+stores}:
      U32.is_eq(loads,1) && U32.is_eq(stores,1) && U32.is_eq(x199s_token(a,env),10) &&
        U32.is_eq(x199s_token(b,env),12) && U32.is_eq(x199s_token(c,env),3) && U32.is_eq(x199s_token(d,env),18)
    case _ _: False{}

@unsafe
def agy_dp_again(values: List<&2,N111Value>, a: String, b: String, p: String, c: String, state: AgyDpState) -> Bool:
  match values state:
    case Con{v0,Con{v1,Con{v2,Con{v3,Con{v4,Con{v5,Con{v6,Nil{}}}}}}}} AgyDpState{+env,+stores}:
      U32.is_eq(stores,1) &&
      U32.is_eq(agy_dp_tok(v0,env),10) &&
      U32.is_eq(agy_dp_tok(v1,env),13) &&
      agy_dp_is_ai(agy_dp_tok(v2,env)) &&
      x185_sf_source(v3,a) && x185_sf_source(v4,b) &&
      x185_sf_source(v5,p) && x185_sf_source(v6,c)
    case _ _: False{}

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
def agy_f32_again(values: List<&2,N111Value>, st: AgyF32State) -> AgyF32Plan:
  match values st:
    case Con{v0,Con{v1,Con{v2,Nil{}}}} AgyF32State{+env,s0,s8,obs,has_obs}:
      nt_choose(AgyF32Plan,agy_f32_val_fuel(v0,env,"FuelSub"),
        u => agy_f32_finish_again(agy_f32_val_f(v1,env),agy_f32_val_u(v2,env),obs),
        u => AgyF32No{})
    case _ _: AgyF32No{}

@unsafe
def agy_map_kind(segment: N111Segment, +ids: N111Ids) -> U32:
  match segment:
    case N111Segment{+name,+arity,+result,incoming,flags,+body}:
      nt_choose(U32,agy_bp_has_mark(ids,"$agy.bp/map") && U32.is_eq(arity,3) && U32.is_eq(result,1) && agy_map_has_ctors(ids),u =>
        nt_choose(U32,(agy_str_eq(name,"$direct.Map.get") || agy_str_eq(name,"Map.get")) &&
          agy_map_stmts_has_ctor(body,"MTip") && agy_map_stmts_has_ctor(body,"MLeaf") &&
          agy_map_stmts_has_ctor(body,"MNode"),
          v => 1,v =>
        nt_choose(U32,(agy_str_eq(name,"$direct.Map.set") || agy_str_eq(name,"Map.set")) &&
          agy_map_stmts_has_func(body,"Map.seek"),
          w => 2,w => 0)),
        u => 0)

# Shared inline map_bit sequence:
# Inputs: %r13 = heap, %rdi = pos (u64 Nat), key_reg = key (String), %rsi = preserved (MNode loc)
# Clobbers: %rax (temp), %rcx, %rdx, %r8, %r9, %rdi
# Branches to l_bit0 (bit=0), l_bit1 (bit=1), or l_bail (unexpected tag / pos >= 2^32)
@unsafe
def agy_bp_list(+book: List<&2,KDef>, names: List<&2,String>, +h: U32) -> U32:
  match names:
    case Nil{}: h
    case Con{n,rest}:
      +h1 = agy_bp_def(book,n,h)
      nt_choose(U32,U32.is_eq(h1,0),u => 0,u => agy_bp_list(book,rest,h1))

@unsafe
def agy_sh_def_pin(+book: List<&2,KDef>, +name: String, +h1: U32, +h2: U32) -> Bool:
  U32.is_eq(agy_sh_def_hash(book,name,2166136261),h1) &&
  U32.is_eq(agy_sh_def_hash(book,name,33554467),h2)

@unsafe
def agy_sh_str_adts_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"String","SNil",0) &&
  agy_map_has_ctor(book,"String","SCon",2) &&
  agy_map_has_ctor(book,"Char","Chr",1) &&
  agy_map_has_ctor(book,"Bool","False",0) &&
  agy_map_has_ctor(book,"Bool","True",0)

@unsafe
def agy_sh_kterm_adt_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"KTerm","KTerm",8) &&
  agy_map_has_ctor(book,"KTerm","KLambda",8) &&
  agy_map_has_ctor(book,"KTerm","KLiteral",5)

@unsafe
def x181_program_data_items(items: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match items:
    case Nil{}: X181Output{nt_reverse(X188Seq,acc,[]),""}
    case Con{+head,rest}:
      x181_program_data_item(head,rest,available,acc)

@unsafe
def x181_program_data_item(+item: P111QDatum, rest: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match item:
    case P111QReloc{+symbol,offset}:
      nt_choose(X181Output,String.is_empty(x181_program_symbol(symbol,available)),
        u => x181_program_data_items(rest,available,Con{x181_program_datum(item),acc}),
        u => X181Output{[],x181_program_symbol(symbol,available)})
    case _: x181_program_data_items(rest,available,Con{x181_program_datum(item),acc})

@unsafe
def x181_stream_datum_error(item: P111QDatum, +available: KDef) -> String:
  match item:
    case P111QReloc{symbol,offset}: x181_program_symbol(symbol,available)
    case _: ""

@unsafe
def x187_e_selected(spec: X187Op, operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match spec operands:
    case X187Op{14,width,code,extra,prefix} Nil{}: x187_e_ok([195])
    case X187Op{family,width,code,extra,prefix} Con{operand,Nil{}}: x187_e_single(operand,family,width,code,extra,offset)
    case X187Op{family,width,code,extra,prefix} Con{src,Con{dst,Nil{}}}: x187_e_pair(src,dst,family,width,code,extra,prefix,offset)
    case _ _: x187_e_error()

@unsafe
def x187_elf_relocs_valid(items: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{head,rest}:
      nt_choose(Bool,U32.is_lt(count,1048576) && x187_elf_reloc_valid(head,sizes,index),
        u => x187_elf_relocs_valid(rest,sizes,index,U32.inc(count)),u => False{})

@unsafe
def w7_elf_sections_fast(object: X187Object, sizes: X187ElfSizes, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,error}:
      w7_elf_sections_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
        w7_relocs_part(relocations,index,[],0,[],0,[],0))

@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w7c_elf_checked_go(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})

@unsafe
def agy_p114h_filter_segs(segs: List<&2,N111Segment>, +direct: KDef, +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+seg,+rest}:
      agy_p114h_filter_segs(rest,direct,nt_choose(List<&2,N111Segment>,agy_p114h_seg_eligible(seg,direct,missing()),
        u => Con{seg,acc},u => acc))

@unsafe
def x202p_x187_elf_sections(object: X187Object, symbols: X187ElfSymbols, rawSizes: X187ElfSizes) -> IO(U32):
  match object symbols:
    case X187Object{text,rodata,data,items,+relocations}
      X187ElfSymbols{+index,count,firstGlobal,table,strings,stringSize,error}:
      +sectionNames = nt_reverse(U32,x187_elf_ascii(
          "\0.text\0.rodata\0.data\0.rela.text\0.rela.rodata\0.rela.data\0.symtab\0.strtab\0.shstrtab\0.note.GNU-stack\0",[]),[])
      x202t_plan([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,x187_elf_relocs(relocations,1,index,[])},
        X187ElfSection{32,4,0,8,24,7,2,x187_elf_relocs(relocations,2,index,[])},
        X187ElfSection{45,4,0,8,24,7,3,x187_elf_relocs(relocations,3,index,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,nt_reverse(U32,table,[])},
        X187ElfSection{64,3,0,1,0,0,0,nt_reverse(U32,strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,sectionNames},
        X187ElfSection{82,1,0,1,0,0,0,[]}],x202t_sizes(rawSizes,x202t_rela_counts(relocations,0,0,0),count,stringSize,nt_count(U32,sectionNames)),64,[],x187_elf_zero(64,[]))

@unsafe
def x202p_x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> IO(U32):
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSizes{+ts,+rs,+ds}
      X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => w10f_x202p_elf_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => IO.die(U32,1,error))

@unsafe
def w11_seg_not_weak(+segment: N111Segment, +weak_set: KDef) -> Bool:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      Bool.not(w10_is_weak_sym(weak_set,p111q_symbol(name)))

@unsafe
def w10f_elf_checked_rev(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, relocations: List<&2,X187Relocation>,
    +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match sizes symbols:
    case X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10f_elf_checked_go(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})

@unsafe
def w10_if_force_cps(+abi: W10IfAbi, +name: String) -> Bool:
  match abi:
    case W10IfAbi{+direct, +public}:
      +key = "$direct." ++ name
      (w10_if_abi_has(public, key) && Bool.not(w10_if_abi_has(direct, key))) ||
      (w10_if_abi_has(public, name) && Bool.not(w10_if_abi_has(direct, name)))

@unsafe
def w10_if_h_defs(+h: W10IfHash, ds: List<&2, KDef>, +abi: W10IfAbi) -> W10IfHash:
  match ds:
    case Nil{}: h
    case Con{KDef{+name, +kind, +arity, +templates, +typ, value, +ctors, native, unsafe}, +rest}:
      nt_choose(W10IfHash, agy_str_eq(name, "main"),
        u => w10_if_h_defs(h, rest, abi),
        u =>
          +h1 = w10_if_h_u32(w10_if_h_u32(w10_if_h_str(w10_if_h_str(w10_if_h_byte(h, 6), name), kind), arity), templates)
          +h2 = w10_if_h_term(h1, typ, Nil{})
          +h3 = nt_choose(W10IfHash, agy_str_eq(kind, "ADT"),
            v => w10_if_h_ctors(h2, ctors),
            v => nt_choose(W10IfHash, agy_str_eq(kind, "Def"),
              w => w10_if_h_byte(h2, nt_choose(U32, w10_if_force_cps(abi, name), z => 2, z => 1)),
              w => h2))
          w10_if_h_defs(h3, rest, abi))
    case Con{_, rest}: w10_if_h_defs(h, rest, abi)

# --- Fast direct-only ABI extraction (zero CPS lowering, zero IR verification, zero x86 pass) ---

@unsafe
def w10_if_drop_upstream_stubs(+book: List<&2, KDef>, +suf_set: KDef, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, w10_if_abi_has(suf_set, name),
        u => Con{name, w10_if_drop_upstream_stubs(book, suf_set, rest)},
        u => nt_choose(List<&2, String>, U32.is_eq(w10_if_stub_kind(book, name), 0),
          v => Con{name, w10_if_drop_upstream_stubs(book, suf_set, rest)},
          v => w10_if_drop_upstream_stubs(book, suf_set, rest)))


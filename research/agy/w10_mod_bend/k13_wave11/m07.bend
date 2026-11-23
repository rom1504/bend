# Module m07 (K=13 acyclic topological split of wave11_unified/compiler.bend)
# defs=698 laws=55 sccs=538 deps=[m00a,m00b,m01,m02,m03,m04,m05,m06] cross_imports=648 fid_base=38000..43199

law book_final_scan:
  for +book: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:320
law book_final_step:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  for +hash: U32
  List<&2,KDef>

# Module: src/core/index.bend:329
law norm_compare:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:282
law kr_filter:
  for book: List<&2, KDef>
  for +live: List<&2, String>
  List<&2, KDef>

# Module: src/core/reach.bend:12
law check_fits:
  for +e: KEnv
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:106
law ka_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:47
law ka_type_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:53
law fpe_here:
  for +source: String
  for +rest: String
  for +offset: U32
  for +error: KTerm
  String

# Module: src/front/parser.bend:542
law f_literal:
  for +s: String
  KTerm

# Module: src/front/elaborate.bend:55
law f_array_size:
  for +n: KTerm
  for +ty: KTerm
  for +count: Bool
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:36
law f_nat_extend:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:134
law f_graph_fresh_result:
  for +r: FResult
  FResult

# Module: src/load/graph.bend:34
law f_graph_fresh_names:
  for +todo: List<&2,KDef>
  for +done: KDef
  String

# Module: src/load/graph.bend:39
law f_graph_fresh_hashed:
  for +rest: List<&2,KDef>
  for +done: KDef
  for +d: KDef
  for +hash: U32
  String

# Module: src/load/graph.bend:46
law j_literal_node:
  for +t: KTerm
  String

# Module: src/back/js/literals.bend:19
law nc_erase:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/back/native/erase.bend:15
law nc_erase_list:
  for +book: List<&2, KDef>
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/native/bridge.bend:97
law nc_context_index:
  for annotated: List<&2, KDef>
  List<&2, KDef>

# Module: src/back/native/book.bend:5
@unsafe
def index_build(
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

# Module: src/core/index.bend:259
@unsafe
def w7_ctor_index_build_step(isAdt: Bool, +h: KDef, +rest: List<&2, KDef>) -> KDef:
  match isAdt:
    case True{}:
      w7_ctor_index_add(dc(h), w7_ctor_index_build(rest))
    case False{}:
      w7_ctor_index_build(rest)

@unsafe
def w7_ctor_index_build(+book: List<&2, KDef>) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      w7_ctor_index_build_step(p88_string_eq(dk(h), "ADT"), h, rest)

@unsafe
def w7_book_put_ctors_step(isAdt: Bool, +cache: KDef, +d: KDef) -> KDef:
  match isAdt:
    case True{}:
      w7_ctor_index_add(dc(d), w7_ctor_tree_of(cache))
    case False{}:
      w7_ctor_tree_of(cache)

@unsafe
def w7_book_put_ctors(+cache: KDef, +d: KDef) -> KDef:
  w7_book_put_ctors_step(p88_string_eq(dk(d), "ADT"), cache, d)

@unsafe
def w7_book_put_step(isCache: Bool, +h: KDef, +rest: List<&2, KDef>, +book: List<&2, KDef>, +d: KDef) -> List<&2, KDef>:
  match isCache:
    case True{}:
      Con{KDef{dn(h), dk(h), da(h), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Con{w7_book_put_ctors(h, d), Nil{}}}, True{}, False{}}, Con{d, index_put_rest(h, rest, dn(d))}}
    case False{}:
      Con{d, index_remove(book, dn(d))}

@unsafe
def book_cached(
  +book: List<&2, KDef>,
  +bound: U32,
) -> List<&2, KDef>:
  Con{KDef{"$kernel.cache", "BookCache", bound, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_build(book), Con{w7_ctor_index_build(book), Nil{}}}, True{}, False{}}, book}

# A cached name miss proves the declaration list contains nothing to remove.
# Missing definitions have the empty name. Preserve the generic empty-name case
# through filtering, even for malformed/duplicate books supplied through the API.

# Module: src/core/index.bend:273
@unsafe
def book_context(
  +book: List<&2, KDef>,
) -> List<&2, KDef>:
  match book:
    case Nil{}:
      book_cached(book, 0)
    case Con{h, rest}:
      kc(List<&2, KDef>, p88_string_eq(dk(h), "BookCache"), u => book, u => book_cached(book, norm_max_book(book)))


# Exact final-definition selection. Short event lists use the original scan.
# Marker values distinguish even the empty name from an unsuccessful lookup.

# Module: src/core/index.bend:340
@unsafe
def book_final_fast(
  +book: List<&2,KDef>,
  +done: List<&2,KDef>,
) -> List<&2,KDef>:
  kc(List<&2,KDef>, book_final_large(book, 256),
    u => kc(List<&2,KDef>, book_final_names_valid(book),
      u => kc(List<&2,KDef>, book_final_names_valid(done),
        u => book_final_scan(book_final_reverse(book, Nil{}), missing(), Nil{}, done),
        u => book_final_legacy(book, done)),
      u => book_final_legacy(book, done)),
    u => book_final_legacy(book, done))

# Module: src/core/index.bend:386
@unsafe
def book_final_scan(book, seen, kept, done):
  match book:
    case Nil{}: book_final_reverse(kept, book_final_filter(done, seen))
    case Con{d, rest}:
      book_final_step(d, rest, seen, kept, done, index_hash(dn(d), 2166136261))

# Module: src/core/index.bend:407
@unsafe
def book_final_step(d, rest, seen, kept, done, hash):
  kc(List<&2,KDef>, book_final_seen(seen, dn(d), hash),
    u => book_final_scan(rest, seen, kept, done),
    u => book_final_scan(rest,
      index_set(seen, KDef{dn(d), "$final.seen", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}}, hash, 32),
      Con{d, kept}, done))

# Module: src/core/index.bend:415
@unsafe
def index_set_many(+tree: KDef, +defs: List<&2,KDef>) -> KDef:
  match defs:
    case Nil{}: tree
    case Con{d, rest}:
      index_set_many(index_set(tree, d, index_hash(dn(d), 2166136261), 32), rest)

# Module: src/core/index.bend:455
@unsafe
def book_put_many_cached(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  Con{KDef{dn(cache), dk(cache), da(cache), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
    Con{index_set_many(index_first(dc(cache)), defs), Nil{}}, True{}, False{}},
    book_final_fast(defs, rest)}

# Module: src/core/index.bend:475
@unsafe
def compare(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
) -> Bool:
  w7_br_30(norm_exact(a, b), book, a, b, le)

# Module: src/core/normalize.bend:261
@unsafe
def norm_compare(book, a, b, le, fresh):
  w7_br_31(norm_exact(a, b), book, a, b, le, fresh)

# Module: src/core/normalize.bend:265
@unsafe
def kr_filter(book, live):
  p128rf_filter(book,p128rf_members(live,missing()))

@unsafe
def kp_show(
  +t: KTerm,
) -> String:
  kp_go(t, 0, Nil{})

# Module: src/core/pretty.bend:202
@unsafe
def tele_fill(
  +book: List<&2, KDef>,
  +tel: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  env_tele_fill(book, tel, args)

# Module: src/check/kernel.bend:714
@unsafe
def w7_br_168(w7_c: Bool, +r: KChecking, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_167(compare(kw_book(rw(r)), cy(r), ty, True{}), r, ty)
    case False{}:
      r

@unsafe
def check_fits(e, r, ty):
  w7_br_168(good(r), r, ty)

# Module: src/check/kernel.bend:734
@unsafe
def w7_br_175(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_174(compare(cb(e), kid(ty, 0), kid(ty, 1), False{}), e, t, ty)
    case False{}:
      bad(cw(e), "reflexivity requires equality goal")

@unsafe
def w7_br_192(w7_c: Bool, +done: List<&2, KDef>, +d: KDef) -> String:
  match w7_c:
    case True{}:
      constructor_names(done, dc(d), Nil{})
    case False{}:
      ""

@unsafe
def w7_br_194(w7_c: Bool, +done: List<&2, KDef>, +d: KDef, +old: KDef) -> String:
  match w7_c:
    case True{}:
      w7_br_193(compare(done, dt(old), dt(d), False{}) && U32.is_eq(dx(old), dx(d)))
    case False{}:
      "duplicate declaration"

@unsafe
def w7_br_195(w7_c: Bool, +done: List<&2, KDef>, +d: KDef, +old: KDef) -> String:
  match w7_c:
    case True{}:
      w7_br_192(p88_string_eq(dk(d), "ADT"), done, d)
    case False{}:
      w7_br_194(p88_string_eq(dk(old), "Def") && p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(old), "Absent") && Bool.not(p98_tag_eq(dv(d), "Absent")), done, d, old)

@unsafe
def kw_bound_book(+book: List<&2,KDef>, +bound: U32) -> List<&2,KDef>:
  match book:
    case Nil{}: book_cached(book, bound)
    case Con{h, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), norm_max(da(h), bound), dx(h), dt(h), dv(h), dc(h), db(h), du(h)}, rest}, u => book_cached(book, bound))

# Module: src/check/kernel.bend:1401
@unsafe
def base_prefix_final(+prefix: List<&2,KDef>) -> List<&2,KDef>:
  book_final_reverse(book_final_fast(prefix, Nil{}), Nil{})

# Module: src/check/prefix-state.bend:90
@unsafe
def base_prefix_world_order_tail(+book: List<&2,KDef>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, more}: Con{cache, prefix_state_join(prefix, book_final_fast(prefix_state_headers(suffix), Nil{}))}

# Module: src/check/prefix-state.bend:303
@unsafe
def agy_stops_set(names: List<&2, String>, acc: KDef) -> KDef:
  match names:
    case Nil{}: acc
    case Con{+name, rest}:
      agy_stops_set(rest, index_set(acc, KDef{name, "P142JSeen", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}},
        index_hash(name, 2166136261), 32))

@unsafe
def ka_type(e, ctx, t):
  ka_type_node(e, ctx, core_beta(t))

# Module: src/check/annotate.bend:194
@unsafe
def w7_br_293(w7_c: Bool, +e: KEnv, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      tele_fill(cb(e), dt(lookup(cb(e), nm(t))), ks(t))
    case False{}:
      w7_br_292(p98_tag_eq(t, "Eql"), t)

@unsafe
def w7_br_294(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_type_app(e, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0))))
    case False{}:
      w7_br_293(p98_tag_eq(t, "ADT"), e, t)

@unsafe
def w7_br_295(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(t, 1)
    case False{}:
      w7_br_294(p98_tag_eq(t, "App"), e, ctx, t)

@unsafe
def w7_br_296(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      dt(lookup(cb(e), nm(t)))
    case False{}:
      w7_br_295(p98_tag_eq(t, "Ann"), e, ctx, t)

@unsafe
def w7_br_297(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(ctx_get(ctx, ix(t)), 0)
    case False{}:
      w7_br_296(p98_tag_eq(t, "Ref"), e, ctx, t)

@unsafe
def ka_type_node(e, ctx, t):
  w7_br_297(p98_tag_eq(t, "Var"), e, ctx, t)

# Module: src/check/annotate.bend:206
@unsafe
def f_context_pattern_observed(+pattern: KTerm, +input: FInput, +cursor: U32, +fresh: FFresh) -> FParsed:
  match fresh:
    case FFresh{term, next}: f_context_error_at(f_computed_pattern_error(pattern, term), input, cursor)

# Module: src/front/contextual.bend:128
@unsafe
def f_context_declare(+d: KDef, +scope: FParseScope) -> FParseScope:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      p144p_declared(f_context_header(d, ns, aliases), prior, index, ctorIndex, ns, aliases, p144p_view)

# Module: src/front/contextual.bend:266

@unsafe
def w7_br_357(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "Bool.and"
    case False{}:
      w7_br_356(f_eq(s, "+"), s)

@unsafe
def w7_br_358(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "Bool.or"
    case False{}:
      w7_br_357(f_eq(s, "&&"), s)

@unsafe
def w7_br_359(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "String.append"
    case False{}:
      w7_br_358(f_eq(s, "||"), s)

@unsafe
def w7_br_374(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_observe(source, rest, offset, error, "end of input")
    case False{}:
      nm(error)

@unsafe
def w7_br_375(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      nm(error)
    case False{}:
      fpe_observe(source, rest, offset, error, "'" ++ SCon{f_head(rest), ""} ++ "'")

@unsafe
def w7_br_376(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      w7_br_374(p88_string_eq(nm(kid(error, 1)), "<eof>"), source, rest, offset, error)
    case False{}:
      w7_br_375(Bool.not(U32.is_eq(Char.to_u32(f_head(rest)), Char.to_u32(f_head(nm(kid(error, 1)))))) || U32.is_gt(Char.to_u32(f_head(rest)), 65535) || (U32.is_ge(Char.to_u32(f_head(rest)), 55296) && U32.is_le(Char.to_u32(f_head(rest)), 57343)), source, rest, offset, error)

@unsafe
def fpe_here(source, rest, offset, error):
  w7_br_376(String.is_empty(rest), source, rest, offset, error)

# Module: src/front/parser.bend:577
@unsafe
def w7_br_418(w7_c: Bool, +s: String) -> KTerm:
  match w7_c:
    case True{}:
      f_string(f_tail(s))
    case False{}:
      w7_br_417(Char.is_eq(f_head(s), '\''), s)

@unsafe
def f_literal(s):
  w7_br_418(Char.is_eq(f_head(s), '"'), s)

# Module: src/front/elaborate.bend:177
@unsafe
def w7_br_423(w7_c: Bool, +origin: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_span(f_string_at(f_tail(nm(origin)), origin), kb(origin), ke(origin))
    case False{}:
      f_literal_value(origin, f_literal(nm(origin)))

@unsafe
def f_array_size(n, ty, count, p):
  match p:
    case FParsed{+size, +ts}:
      f_choose(FParsed, f_eq(tg(size), "Error"), u => FParsed{size, ts}, u => f_array_closed(n, ty, count, f_expect(FParsed{size, f_space(ts)}, "]")))

# Module: src/front/literals_arrays.bend:100
@unsafe
def f_nat_extend(a, b):
  f_nat_extend_value(a, b, f_choose(KTerm, f_eq(tg(b), "Literal") && String.ends_with(nm(b), "n"), u => f_literal(nm(b)), u => b))

# Module: src/front/literals_arrays.bend:126
@unsafe
def f_array_closed(+n: KTerm, +ty: KTerm, +count: Bool, +p: FParsed) -> FParsed:
  match p:
    case FParsed{size, ts}:
      f_choose(FParsed, f_context_stop(size), u => p,
        u => f_array_namespaced(size, ty, count, ts, f_context_namespace(n, ty, ts)))

# Module: src/front/literals_arrays.bend:166
@unsafe
def f_ctor_index(+book: List<&2,KDef>, +tree: KDef) -> KDef:
  match book:
    case Nil{}: tree
    case Con{d, rest}: f_ctor_index_def(d, f_ctor_index(rest, tree))

# Module: src/front/validate.bend:60
@unsafe
def f_ctor_index_def(+d: KDef, +tree: KDef) -> KDef:
  +children = f_ctor_index(dc(d), tree)
  f_choose(KDef, f_eq(dk(d), "Ctr"), u => index_set(children, d, index_hash(dn(d), 2166136261), 32), u => children)

# Module: src/front/validate.bend:65
@unsafe
def f_computed_pattern_error(+pattern: KTerm, +observed: KTerm) -> KTerm:
  fpe_expected_at(pattern, "expected a binder or constructor pattern", "a pattern (a binder or a constructor)", kp_show(observed))

# Module: src/load/imports.bend:13
@unsafe
def f_graph_result(
  +g: FGraph,
) -> FResult:
  match g:
    case FGraph{book, err, done}:
      f_fresh_result(f_graph_fresh_result(f_validate_result(FResult{book, err, Nil{}})))

# Module: src/load/graph.bend:158
@unsafe
def f_graph_fresh_result(r):
  match r:
    case FResult{+book, +err, +imports}:
      f_choose(FResult, String.is_empty(err), u => FResult{book, f_graph_fresh_names(book, missing()), imports}, u => FResult{book, err, imports})

# Module: src/load/graph.bend:260
@unsafe
def f_graph_fresh_names(todo, done):
  match todo:
    case Nil{}:
      ""
    case Con{+d, rest}:
      f_graph_fresh_hashed(rest, done, d, index_hash(dn(d), 2166136261))

# Module: src/load/graph.bend:268
@unsafe
def w7_br_520(w7_c: Bool, +rest: List<&2,KDef>, +done: KDef, +d: KDef, +hash: U32) -> String:
  match w7_c:
    case True{}:
      f_graph_fresh_names(rest, index_set(done, d, hash, 32))
    case False{}:
      "expected a fresh name (duplicate declaration: " ++ dn(d) ++ ")"

@unsafe
def f_graph_fresh_name(
  +rest: List<&2,KDef>,
  +done: KDef,
  +d: KDef,
  +hash: U32,
  +old: KDef,
) -> String:
  w7_br_520(f_eq(dk(old), "Absent") || (f_eq(dk(old), "Def") && f_eq(dk(d), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(f_eq(tg(dv(d)), "Absent")) && (Bool.not(db(old)) || db(d))), rest, done, d, hash)

# Module: src/load/graph.bend:278
@unsafe
def f_graph_fresh_hashed(rest, done, d, hash):
  f_graph_fresh_name(rest, done, d, hash, index_find(done, dn(d), hash, 32))

# Refine only the error already selected by graph validation. Success is O(1).

# Module: src/load/graph.bend:347
@unsafe
def f_ready_prefix_prepare(+prefix: List<&2,KDef>) -> FReadyPrefixState:
  FReadyPrefixState{index_build(List.reverse(&2,KDef,prefix)), f_ctor_index(prefix, missing()), f_graph_count_defs(prefix, 0), String.is_empty(f_error_defs(prefix)) && String.is_empty(f_graph_fresh_names(prefix, missing()))}

# Module: src/load/prefix.bend:121
@unsafe
def f_prefix_ready_source_completed(+prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +baseNames: KDef, +names: KDef, +ctors: KDef, +completion: FIndexedCompletion) -> FPrefixCompletion:
  match completion:
    case FIndexedCompletion{graph, parsed, fragment}:
      match graph:
        case FGraph{book, error, done}:
          kc(FPrefixCompletion, String.is_empty(error),
            u => FPrefixCompletion{FReadyPrefixGraph{graph, prefix, norm_defs_join(suffix, fragment), count, True{}, f_prefix_names_extend(fragment, names), f_prefix_ctors_extend(fragment, ctors), baseNames}, parsed},
            u => FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, count, False{}}, parsed})

# Module: src/load/prefix.bend:195
@unsafe
def f_prefix_names_extend(+defs: List<&2,KDef>, +names: KDef) -> KDef:
  match defs:
    case Nil{}: names
    case Con{d, rest}: f_prefix_names_extend(rest, index_set(names, d, index_hash(dn(d), 2166136261), 32))

# Module: src/load/prefix.bend:201
@unsafe
def f_prefix_ctors_extend(+defs: List<&2,KDef>, +ctors: KDef) -> KDef:
  match defs:
    case Nil{}: ctors
    case Con{d, rest}:
      +hash = index_hash(dn(d), 2166136261)
      +next = kc(KDef, p88_string_eq(dk(d), "Ctr") && p88_string_eq(dk(index_find(ctors, dn(d), hash, 32)), "Absent"), u => index_set(ctors, d, hash, 32), u => ctors)
      f_prefix_ctors_extend(rest, f_prefix_ctors_extend(dc(d), next))

# Module: src/load/prefix.bend:210
@unsafe
def f_prefix_ready_validate(+whole: List<&2,KDef>, +suffix: List<&2,KDef>, +error: String, +baseNames: KDef) -> FResult:
  f_prefix_ready_validated(whole, baseNames, f_validate_result(FResult{suffix, error, Nil{}}))

# Module: src/load/prefix.bend:244
@unsafe
def f_prefix_ready_validated(+whole: List<&2,KDef>, +baseNames: KDef, +validated: FResult) -> FResult:
  match validated:
    case FResult{book, checked, imports}:
      FResult{whole, kc(String, String.is_empty(checked), u => f_graph_fresh_names(book, baseNames), u => checked), imports}

# Module: src/load/prefix.bend:250
@unsafe
def w7_br_551(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text("a filled definition (an unfilled law is a dead claim: live code cannot use it)"), t)
    case False{}:
      w7_br_550(p88_string_eq(code, "a family requires angle-bracket parameters"), e, t, ty, code)

@unsafe
def w7_br_552(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text("a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)"), t)
    case False{}:
      w7_br_551(p88_string_eq(code, "live use of an unfilled law"), e, t, ty, code)

@unsafe
def j_literal(
  +t: KTerm,
) -> String:
  j_literal_node(j_strip(t))

# Module: src/back/js/literals.bend:15
@unsafe
def j_literal_node(t):
  w7_br_590(core_literal(t), t)

# Module: src/back/js/literals.bend:24
@unsafe
def j_literal_typed(
  +book: List<&2, KDef>,
  +t: KTerm,
  +ty: KTerm,
) -> String:
  +literal = j_literal(t)
  kc(String, p88_string_eq(literal, ""), u => "", u => j_literal_provenance(book, wnf(book, ty), literal))

# Module: src/back/js/literals.bend:138
@unsafe
def w7_br_599(w7_c: Bool, +main: KDef) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      "main's type " ++ kp_show(dt(main)) ++ " cannot be printed (a function, a Type, an erased or dependent field)"

@unsafe
def w7_br_600(w7_c: Bool, +book: List<&2, KDef>, +main: KDef) -> String:
  match w7_c:
    case True{}:
      w7_br_598(p98_tag_eq(j_strip(dv(main)), "Foreign"))
    case False{}:
      w7_br_599(j_printable(book, dt(main), Nil{}, 0), main)

@unsafe
def w7_br_613(w7_c: Bool, +book: List<&2,KDef>, +spine: KTerm) -> Bool:
  match w7_c:
    case True{}:
      j_primitive_definition(book, lookup(book, nm(spine)), terms_len(ks(spine)))
    case False{}:
      False{}

@unsafe
def j_primitive_call(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  w7_br_613(p98_tag_eq(spine, "Call") && j_primitive_known(nm(spine)), book, spine)

# Module: src/back/js/local.bend:6
@unsafe
def j_pure_same_check(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u => j_pure_same_heads(book, wnf(book, a), wnf(book, b), U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:492
@unsafe
def j_pure_same_heads(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Maybe") || p88_string_eq(nm(b), "Maybe"), u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, a) && j_map_maybe_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Map") || p88_string_eq(nm(b), "Map"), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "List") || p88_string_eq(nm(b), "List"), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, a) && j_pure_list_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Sigma") || p88_string_eq(nm(b), "Sigma"), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b) &&
      U32.is_eq(qt(kid(a, 0)), qt(kid(b, 0))) && U32.is_eq(qt(kid(a, 1)), qt(kid(b, 1))), u =>
      j_pure_same_next(book, kid(kid(a, 3), 0), kid(kid(b, 3), 0),
        j_pure_same_check(book, kid(a, 2), kid(b, 2), fuel)), u => None{}), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(a, "ADT") && p98_tag_eq(b, "ADT") && p88_string_eq(nm(a), nm(b)) &&
      List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)) &&
      List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))))

# Module: src/back/js/jpure.bend:512
@unsafe
def j_pure_same_next(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case Some{fuel}: j_pure_same_check(book, a, b, fuel)
    case None{}: None{}

# Native constructors retain exact field quantities and complete terminal type.
# A List tail is checked against its current specialization, not recursively
# re-expanded. Its element already consumes the shared type-proof budget.

# Module: src/back/js/jpure.bend:521
@unsafe
def j_string_char_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  w7_br_618(j_string_owner(book, ty, "Char", 1), book)

# Module: src/back/js/jpure.bend:590
@unsafe
def w7_br_619(w7_c: Bool, +book: List<&2,KDef>) -> Bool:
  match w7_c:
    case True{}:
      j_string_string_fields(book)
    case False{}:
      False{}

@unsafe
def j_string_string_fields(+book: List<&2,KDef>) -> Bool:
  +cs = dc(lookup(book, "String"))
  +nil = lookup(cs, "SNil")
  +con = lookup(cs, "SCon")
  +tel = wnf(book, dt(con))
  +rest = wnf(book, kid(tel, 1))
  j_pure_native_ctor(nil, "SNil", 0) && j_pure_native_ctor(con, "SCon", 2) &&
    j_string_owner(book, wnf(book, dt(nil)), "String", 2) && p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
    U32.is_eq(terms_len(ks(tel)), 2) && j_string_char_type(book, wnf(book, kid(tel, 0))) &&
    p98_tag_eq(rest, "All") && U32.is_eq(qt(rest), 1) && U32.is_eq(terms_len(ks(rest)), 2) &&
    j_string_owner(book, wnf(book, kid(rest, 0)), "String", 2) && j_string_owner(book, wnf(book, kid(rest, 1)), "String", 2)

# Exact native Map<&2,scalar-or-Unit> specialization. Constructor rows are validated;
# owner names alone never grant shape/ownership or public argument permission.

# Module: src/back/js/jpure.bend:667
@unsafe
def j_pure_map_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Map")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Map") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && (j_region_scalar(book, kid(ty, 1)) || j_pure_unit_type(book, kid(ty, 1))) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "MTip"), "MTip", 0) &&
    j_pure_native_ctor(lookup(dc(owner), "MLeaf"), "MLeaf", 2) &&
    j_pure_native_ctor(lookup(dc(owner), "MNode"), "MNode", 3)

# Module: src/back/js/jpure.bend:684
@unsafe
def j_pure_unit_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  w7_br_620(j_string_owner(book, wnf(book, ty), "Unit", 1), book)

# Module: src/back/js/jpure.bend:1523
@unsafe
def j_fusion_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, p98_tag_eq(h, "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
    kc(Bool, p98_tag_eq(h, "Lit"), u => p88_string_eq(nm(h), "U32"), u =>
      p98_tag_eq(s, "Call") && j_primitive_call(book, s) && U32.is_eq(terms_len(ks(s)), 2) &&
      (p88_string_eq(nm(s), "U32.add") || p88_string_eq(nm(s), "U32.sub") || p88_string_eq(nm(s), "U32.mul") ||
       p88_string_eq(nm(s), "U32.mod") || p88_string_eq(nm(s), "U32.is_eq") ||
       p88_string_eq(nm(s), "U32.is_gt") || p88_string_eq(nm(s), "U32.is_lt")) &&
      j_fusion_scalars(book, ks(s), vars)))

# Module: src/back/js/region.bend:849
@unsafe
def j_fusion_scalars(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +vars: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_fusion_scalar(book, h, vars) && j_fusion_scalars(book, rest, vars)

# Module: src/back/js/region.bend:855
@unsafe
def j_callback_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>, +pred: U32, +fuel: U32) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, p98_tag_eq(h, "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
      kc(Bool, p98_tag_eq(h, "Lit"), u => p88_string_eq(nm(h), "U32"), u =>
        kc(Bool, j_fusion_call(s, "U32.from_nat", 1) && j_primitive_call(book, s),
          u => j_fusion_var(kid(s, 0), pred), u =>
          kc(Bool, p98_tag_eq(s, "Call") && U32.is_eq(terms_len(ks(s)), 2) &&
            (p88_string_eq(nm(s), "U32.add") || p88_string_eq(nm(s), "U32.sub") || p88_string_eq(nm(s), "U32.mul") || p88_string_eq(nm(s), "U32.mod")) &&
            j_primitive_call(book, s), u =>
            kc(Bool, j_callback_scalar(book, kid(s, 0), vars, pred, U32.sub(fuel, 1)),
              u => j_callback_scalar(book, kid(s, 1), vars, pred, U32.sub(fuel, 1)), u => False{}), u => False{})))), u => False{})

# The exact generic composition domain is Type&1, with three erased q0
# binders. Type&2 native U32 is specialized only after that formal proof.

# Module: src/back/js/region.bend:1092
@unsafe
def w7_br_621(w7_c: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match w7_c:
    case True{}:
      j_callback_compose_on(book, d)
    case False{}:
      False{}

@unsafe
def w7_br_622(w7_c: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match w7_c:
    case True{}:
      w7_br_621(j_u32_bounded([dt(d), dv(d)], 2048), book, d)
    case False{}:
      False{}

@unsafe
def j_callback_compose(+book: List<&2,KDef>, +d: KDef) -> Bool:
  w7_br_622(j_fusion_def(d, 5) && p98_tag_eq(j_strip(dv(d)), "Lam"), book, d)

# Module: src/back/js/region.bend:1244
@unsafe
def j_list_ground_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  +d = lookup(book, "List")
  kc(Bool, j_list_ground_head(book, head) && p88_string_eq(dk(d), "ADT") && db(d) &&
    U32.is_eq(dx(d), 0) && U32.is_eq(da(d), 2) && U32.is_eq(j_region_def_count(dc(d)), 2), u =>
    j_list_ground_kind(wnf(book, j_specialize(book, dt(d), ks(head)))) &&
      j_list_ground_ctor(book, lookup(dc(d), "Nil"), head, 0) && j_list_ground_ctor(book, lookup(dc(d), "Con"), head, 2), u => False{})

# Module: src/back/js/fold.bend:299
@unsafe
def j_list_ground_ctor(+book: List<&2,KDef>, +c: KDef, +ty: KTerm, +fields: U32) -> Bool:
  w7_br_628(p88_string_eq(dk(c), "Ctr") && db(c) && U32.is_eq(dx(c), 0) && U32.is_eq(da(c), fields), book, c, ty, fields)

# Module: src/back/js/fold.bend:309
@unsafe
def nc_ctor_identity(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  w7_br_629(nc_ctor_owned(book, name), name)

# Module: src/back/native/identity.bend:44
@unsafe
def nc_erase_args(
  +book: List<&2, KDef>,
  +tel: KTerm,
  +xs: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      +head = wnf(book, tel)
      nt_choose(List<&2, KTerm>, U32.is_eq(qt(head), 0),
        u => nc_erase_args(book, subst(kid(head, 1), ix(head), h), rest),
        u => Con{nc_erase(book, h), nc_erase_args(book, subst(kid(head, 1), ix(head), h), rest)})

# Module: src/back/native/erase.bend:51
@unsafe
def nc_erase_mat(+book: List<&2, KDef>, +t: KTerm, +adt: KTerm) -> KTerm:
  +ctr = lookup(dc(lookup(book, nm(adt))), nm(t))
  +count = nc_live_count(book, nc_tele_fill(book, dt(ctr), ks(adt)), da(ctr))
  kt("Mat", nt_choose(String, db(lookup(book, nm(adt))), u => nm(t), u => nc_ctor_identity(book, nm(t))), U32.inc(count), nh_field_mask(book, nc_tele_fill(book, dt(ctr), ks(adt)), da(ctr), 0), nc_erase_list(book, ks(t)))

# Module: src/back/native/erase.bend:57
@unsafe
def w7_br_638(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_erase_mat(book, t, wnf(book, kid(ty, 0)))
    case False{}:
      nc_erase(book, t)

@unsafe
def w7_br_639(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Ctr", nt_choose(String, db(lookup(book, nm(ty))), u => nm(t), u => nc_ctor_identity(book, nm(t))), ix(t), qt(t), nc_erase_args(book, nc_tele_fill(book, dt(lookup(dc(lookup(book, nm(ty))), nm(t))), ks(ty)), ks(t)))
    case False{}:
      w7_br_638(p98_tag_eq(t, "Mat"), book, t, ty)

@unsafe
def w7_br_640(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      w7_br_639(p98_tag_eq(t, "Ctr"), book, t, ty)

@unsafe
def nc_erase_annotated(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  w7_br_640(p98_tag_eq(ty, "Eql"), book, t, ty)

# Module: src/back/native/erase.bend:66
@unsafe
def nc_erase_list(book, ts):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nc_erase(book, h), nc_erase_list(book, rest)}

# Module: src/back/native/erase.bend:72
@unsafe
def w7_br_641(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_erase(book, kid(t, 0))
    case False{}:
      k_rebuild(t, nm(t), ix(t), qt(t), nc_erase_list(book, ks(t)), Nil{}, 0, 0)

@unsafe
def w7_br_642(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_641(U32.is_eq(qt(wnf(book, kid(kid(t, 0), 1))), 0), book, t)
    case False{}:
      k_rebuild(t, nm(t), ix(t), qt(t), nc_erase_list(book, ks(t)), Nil{}, 0, 0)

@unsafe
def nc_erase_app(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  w7_br_642(p98_tag_eq(kid(t, 0), "Ann"), book, t)

# Module: src/back/native/erase.bend:78
@unsafe
def w7_br_643(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_erase_app(book, t)
    case False{}:
      k_rebuild(t, nt_choose(String, p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Mat"), u => nc_ctor_identity(book, nm(t)), u => nm(t)), ix(t), qt(t), nc_erase_list(book, ks(t)), Nil{}, 0, 0)

@unsafe
def w7_br_644(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_erase(book, kid(t, 0))
    case False{}:
      w7_br_643(p98_tag_eq(t, "App"), book, t)

@unsafe
def w7_br_645(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      nc_erase_annotated(book, kid(t, 0), wnf(book, kid(t, 1)))
    case False{}:
      w7_br_644(p98_tag_eq(t, "Lam") && U32.is_eq(qt(t), 0), book, t)

@unsafe
def w7_br_646(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      var(nm(t), ix(t))
    case False{}:
      w7_br_645(p98_tag_eq(t, "Ann"), book, t)

@unsafe
def w7_br_647(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      w7_br_646(p98_tag_eq(t, "Var"), book, t)

@unsafe
def nc_erase(book, t):
  w7_br_647(core_literal(t), book, t)

# Module: src/back/native/uses.bend:9
@unsafe
def w7_br_654(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "1", n}
    case False{}:
      w7_br_653(p88_string_eq(name, "Succ"), name, ws, n)

@unsafe
def w7_br_655(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "0", n}
    case False{}:
      w7_br_654(p88_string_eq(name, "True"), name, ws, n)

@unsafe
def nc_constructor_value(+name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  w7_br_655(p88_string_eq(name, "Zero") || p88_string_eq(name, "False"), name, ws, n)

# Module: src/back/native/bridge.bend:374
@unsafe
def nc_ctor_index(ds: List<&2, KDef>, +tree: KDef) -> KDef:
  match ds:
    case Nil{}: tree
    case Con{+d, rest}:
      +next = nt_choose(KDef, p88_string_eq(dk(d), "Ctr") && p88_string_eq(dk(index_find(tree, dn(d), index_hash(dn(d), 2166136261), 32)), "Absent"),
        u => index_set(tree, d, index_hash(dn(d), 2166136261), 32), u => tree)
      nc_ctor_index(rest, nc_ctor_index(dc(d), next))

# Module: src/back/native/bridge.bend:403
@unsafe
def nc_ctor_prepare(+book: List<&2, KDef>) -> KDef:
  +prior = nc_ctor_context(book)
  nt_choose(KDef, p88_string_eq(dk(prior), "NativeCtorIndex"), u => prior,
    u => KDef{"$native.ctors", "NativeCtorIndex", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [nc_ctor_index(book, missing())], False{}, False{}})

# Module: src/back/native/bridge.bend:420
@unsafe
def w5c2_nc_native_def_if(is_base: Bool, +d: KDef) -> Bool:
  match is_base:
    case True{}: nc_native_marked(d)
    case False{}: False{}

@unsafe
def nc_native_def(+d: KDef) -> Bool:
  w5c2_nc_native_def_if(db(d), d)

# Module: src/back/native/bridge.bend:516
@unsafe
def nc_ref_name(+book: List<&2, KDef>, +name: String) -> String:
  w5c2_nc_ref_if(nc_native_def(lookup(book, name)), name)

# Module: src/back/native/bridge.bend:529
@unsafe
def w5c3_nd_head_if(is_ref: Bool, +book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  match is_ref:
    case True{}:
      +hname = nm(head)
      w5c3_nd_head_nat(nc_native_def(lookup(book, hname)), t, hname)
    case False{}: ""

# Module: src/back/native/direct.bend:16
@unsafe
def nd_arity_plain(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, p98_tag_eq(nc_unann(dv(d)), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d)))))

# Module: src/back/native/direct.bend:96
@unsafe
def nq_layout(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_head(book, nq_layout_type(book, ty))

# Module: src/back/native/product-layout.bend:9
@unsafe
def nq_call_shape(+book: List<&2, KDef>, +name: String, +args: List<&2, KTerm>, +target: NC_Target) -> KTerm:
  +d = lookup(book, name)
  +info = nq_info(target, name)
  nt_choose(KTerm, nc_native_def(d) && nq_pair_primitive(nc_primitive_name(name)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u =>
    nt_choose(KTerm, p98_tag_eq(dv(info), "NQSig") && nq_args_known(ks(dv(info)), args), u => dt(info), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/product.bend:271
@unsafe
def w7_br_713(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      nq_tele_head(book, nq_layout_reduce(ty, 64), left, fuel, shapes)

@unsafe
def w7_br_714(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      kt("NQTele", "", 0, 0, Con{nq_layout(book, ty), List.reverse(&2, KTerm, shapes)})
    case False{}:
      w7_br_713(U32.is_eq(fuel, 0), book, ty, left, fuel, shapes)

@unsafe
def nq_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  w7_br_714(U32.is_eq(left, 0), book, ty, left, fuel, shapes)

# Module: src/back/native/product.bend:287
@unsafe
def w7_br_715(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      nq_tele(book, kid(head, 1), left, U32.sub(fuel, 1), shapes)
    case False{}:
      nq_tele(book, kid(head, 1), U32.sub(left, 1), U32.sub(fuel, 1), Con{nq_layout(book, kid(head, 0)), shapes})

@unsafe
def w7_br_716(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_715(U32.is_eq(qt(head), 0), book, head, left, fuel, shapes)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def nq_tele_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  w7_br_716(p98_tag_eq(head, "All"), book, head, left, fuel, shapes)

# Module: src/back/native/product.bend:293
@unsafe
def nc_show_find(+book: List<&2, KDef>, +ty: KTerm, types: List<&2, KTerm>, +i: U32) -> U32:
  match types:
    case Nil{}: 4294967295
    case Con{h, +rest}: nt_choose(U32, norm_compare(book, ty, h, False{}, 4000000000), u => i, u => nc_show_find(book, ty, rest, U32.inc(i)))

# Module: src/back/native/array.bend:14
@unsafe
def w5c2_ns_gen_arr_ref(is_ref: Bool, +book: List<&2, KDef>, +name: String) -> Bool:
  match is_ref:
    case False{}: False{}
    case True{}: w5c2_ns_gen_arr_prim(nc_native_def(lookup(book, name)), name)

@unsafe
def nc_ctor_specs(+book: List<&2, KDef>, cs: List<&2, KDef>, +params: U32) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: Nil{}
    case Con{+c, rest}: Con{N_Constructor{nc_ctor_identity(book, dn(c)), nc_live_count(book, nc_skip_tel(book, dt(c), params), da(c)), True{}}, nc_ctor_specs(book, rest, params)}

# Module: src/back/native/book.bend:163
@unsafe
def nc_annotation_stops(book: List<&2, KDef>) -> List<&2, String>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, String>, nc_native_def(d),
        u => Con{dn(d), nc_annotation_stops(rest)},
        u => nc_annotation_stops(rest))

# Module: src/back/native/book.bend:325
@unsafe
def nc_context_index(annotated):
  match annotated:
    case Nil{}: Nil{}
    case Con{+head, +rest}:
      nt_choose(List<&2, KDef>, nc_context_has_cache(Con{head, rest}), u => Con{head, rest}, u => book_cached(Con{head, rest}, 0))

# Module: src/back/native/book.bend:348
@unsafe
def ns_ctor_index(cs: List<&2, N_Constructor>, +index: KDef) -> KDef:
  match cs:
    case Nil{}: index
    case Con{N_Constructor{+name, arity, hot}, rest}:
      ns_ctor_index(rest, index_set(index, KDef{name, "NativeStaticCtor", arity, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

# Module: src/back/native/static.bend:80
@unsafe
def ns_attach_book(+book: List<&2, KDef>, +facts: List<&2, KDef>, +size: U32, +words: List<&2, String>) -> List<&2, KDef>:
  match book:
    case Con{cache, rest}:
      Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
        [index_first(dc(cache)), KDef{"$native.static", "NativeStaticContext", 0, 0, kt("NativeImage", "", size, 0, ns_image_terms(nt_reverse(String, words, Nil{}))), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [index_build(facts), nc_ctor_prepare(book)], False{}, False{}}], db(cache), du(cache)}, rest}
    case _: book

# Module: src/back/native/request.bend:10
@unsafe
def nol_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  nt_choose(Bool, nol_plain(ty) && nol_owner(book, ty),
    u => nt_choose(Bool, db(d) && nb_contains(["Nat", "Char", "U32", "F32"], dn(d)),
      v => True{}, v => Bool.not(List.is_empty(&2, KDef, dc(d))) && nol_enum(book, ty, dc(d), 32)), u => False{})

# Module: src/back/native/observer-layout.bend:72
@unsafe
def nol_spec(+book: List<&2, KDef>, +owner: String, +ctr: KDef, +storage: String, +fields: List<&2, KTerm>) -> NO_Spec:
  +key = nc_ctor_identity(book, dn(ctr))
  NO_Spec{NO_Layout{key, key, storage, terms_len(fields)}, owner, nol_type_names(fields)}

# Module: src/back/native/observer-layout.bend:83
@unsafe
def nol_root_fields(+book: List<&2, KDef>, +owner: String, fields: List<&2, KTerm>, +recursive: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(recursive, 1)
    case Con{+h, +rest}:
      nt_choose(Bool, nol_plain(h) && p88_string_eq(nm(h), owner),
        u => U32.is_eq(recursive, 0) && nol_root_fields(book, owner, rest, 1),
        u => nol_scalar(book, h) && nol_root_fields(book, owner, rest, recursive))

# Module: src/back/native/observer-layout.bend:92
@unsafe
def w7_br_767(w7_c: Bool, +ctx: NO_Context, +v: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      noa_scalar_ctor(ctx, v, noa_spec(nm(v), no_schema_specs(noa_schema(ctx))))
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_768(w7_c: Bool, +ctx: NO_Context, +v: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(v, 1)
    case False{}:
      w7_br_767(p98_tag_eq(v, "OC"), ctx, v)

@unsafe
def noa_scalar(+ctx: NO_Context, +v: KTerm) -> KTerm:
  w7_br_768(p98_tag_eq(v, "OA") && nol_scalar(noa_book(ctx), kt("ADT", nm(v), 0, 0, Nil{})), ctx, v)

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
def w7_br_769(w7_c: Bool, +ctx: NO_Context, +ty: KTerm, +args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      noa_call_types(ctx, nq_layout_type(noa_book(ctx), ty), args, U32.sub(fuel, 1))

@unsafe
def noa_call_result(+ctx: NO_Context, +ty: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  w7_br_769(U32.is_eq(fuel, 0), ctx, ty, args, fuel)

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
def noa_root_param(+ctx: NO_Context, +p: KTerm) -> Bool:
  Bool.not(nol_scalar(noa_book(ctx), kt("ADT", nm(p), 0, 0, Nil{})))

# Module: src/back/native/observer-analysis.bend:409
@unsafe
def no_candidate_names(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, String>, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{name, no_candidate_names(book, rest, bangs)}, u => no_candidate_names(book, rest, bangs))

# Module: src/driver/report.bend:64
law p175rn_walk:
  for book: List<&2,KDef>
  for +members: KDef
  List<&2,String>

@unsafe
def dr_own_names(+book: List<&2,KDef>, +seen: List<&2,String>) -> List<&2,String>:
  p175rn_walk(book,p142j_members(seen,missing()))

# Owned successful requests need the same dependency result for both fields.
# This query only follows names; no fresh binder allocation consults the bound.

# Module: src/driver/report.bend:108
@unsafe
def dr_mark_safe(names: List<&2, String>, +safe: KDef) -> KDef:
  match names:
    case Nil{}: safe
    case Con{+name, rest}:
      dr_mark_safe(rest, index_set(safe, KDef{name, "ReportSafe", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

@unsafe
def agy_ctor_parent_add(ctors: List<&2, KDef>, +adt: KDef, +acc: KDef) -> KDef:
  match ctors:
    case Nil{}: acc
    case Con{+c, rest}:
      +cname = dn(c)
      +entry : KDef = KDef{cname, "AgyCtorParent", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{adt, Nil{}}, False{}, False{}}
      agy_ctor_parent_add(rest, adt, index_set(acc, entry, index_hash(cname, 2166136261), 32))

@unsafe
def agy_ctor_parent_index(book: List<&2, KDef>, +acc: KDef) -> KDef:
  match book:
    case Nil{}: acc
    case Con{+d, rest}:
      agy_ctor_parent_index(rest, kc(KDef, p88_string_eq(dk(d), "ADT"),
        u => agy_ctor_parent_add(dc(d), d, acc), u => acc))

law agy_dr_walk_def:
  for +book: List<&2, KDef>
  for +cidx: KDef
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +seen_set: KDef
  for +safe: KDef
  for +d: KDef
  DR_Closure

@unsafe
def agy_dr_walk(+book: List<&2, KDef>, +cidx: KDef, todo: List<&2, String>, +seen: List<&2, String>, +seen_set: KDef, +safe: KDef) -> DR_Closure:
  match todo:
    case Nil{}: DR_Closure{False{}, seen}
    case Con{+name, +rest}:
      +h = index_hash(name, 2166136261)
      kc(DR_Closure, p88_string_eq(dk(index_find(seen_set, name, h, 32)), "ReportSeen") ||
          p88_string_eq(dk(index_find(safe, name, h, 32)), "ReportSafe"),
        u => agy_dr_walk(book, cidx, rest, seen, seen_set, safe),
        u => agy_dr_walk_def(book, cidx, rest, Con{name, seen},
          index_set(seen_set, KDef{name, "ReportSeen", 0, 0,
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, h, 32),
          safe, agy_kr_resolve_cidx(book, cidx, name, h)))

@unsafe
def w7_br_787(w7_c: Bool, +book: List<&2, KDef>, +cidx: KDef, +todo: List<&2, String>, +seen: List<&2, String>, +seen_set: KDef, +safe: KDef, +d: KDef) -> DR_Closure:
  match w7_c:
    case True{}:
      DR_Closure{True{}, seen}
    case False{}:
      agy_dr_walk(book, cidx, agy_dr_deps(d, todo), seen, seen_set, safe)

@unsafe
def agy_dr_walk_def(book, cidx, todo, seen, seen_set, safe, d):
  w7_br_787(du(d) || (p98_tag_eq(dv(d), "Foreign") && Bool.not(db(d))), book, cidx, todo, seen, seen_set, safe, d)

law agy_dr_cached_step:
  for +book: List<&2, KDef>
  for +cidx: KDef
  for +name: String
  for +rest: List<&2, String>
  for +safe: KDef
  for result: DR_Closure
  List<&2, String>

@unsafe
def agy_dr_cached_go(+book: List<&2, KDef>, +cidx: KDef, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      agy_dr_cached_step(book, cidx, name, rest, safe, agy_dr_walk(book, cidx, [name], Nil{}, missing(), safe))

@unsafe
def agy_dr_cached_step(book, cidx, name, rest, safe, result):
  match result:
    case DR_Closure{+bad, +seen}:
      kc(List<&2, String>, bad, u => Con{name, agy_dr_cached_go(book, cidx, rest, safe)},
        u => agy_dr_cached_go(book, cidx, rest, dr_mark_safe(seen, safe)))

# Module: src/driver/report.bend:130
@unsafe
def dr_walk(+book: List<&2, KDef>, todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef) -> DR_Closure:
  agy_dr_walk(book, agy_ctor_parent_index(book, missing()), todo, seen, missing(), safe)

# Module: src/driver/report.bend:145
@unsafe
def dr_cached_names(+book: List<&2, KDef>, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  agy_dr_cached_go(book, agy_ctor_parent_index(book, missing()), names, safe)

# Module: src/driver/api.bend:15
@unsafe
def driver_final(
  +book: List<&2,KDef>,
  +done: List<&2,KDef>,
) -> List<&2,KDef>:
  book_final_fast(book, done)

# Module: src/driver/api.bend:29
@unsafe
def p88_header_stamp(read: P88TextRead, expected: String, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},stamp}:
      p88_header_gate(P88Cursor{text,mode},begin,end,p130m_valid(mode) && agy_str_eq(stamp,expected))

@unsafe
def p88_header_gate(cursor: P88Cursor, +begin: U32, +end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_header_nodes(p88_u32(cursor),begin,end)
    case False{}: P88DecodeError{"cache stamp"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:363
@unsafe
def p88_header_nodes(read: P88Number, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88Number{cursor,n}: p88_header_counts(p88_u32(cursor),n,begin,end)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:368
@unsafe
def p205_fields(ps: List<&2,P205Pattern>, ts: List<&2,KTerm>, +env: List<&2,U32>, state: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match state:
    case None{}: None{}
    case Some{roles}: p205_fields_found(ps,ts,env,roles)

@unsafe
def p205_fields_found(ps: List<&2,P205Pattern>, ts: List<&2,KTerm>, +env: List<&2,U32>, +roles: KDef) -> Maybe<&2,KDef>:
  match ps ts:
    case Nil{} Nil{}: Some{roles}
    case Con{p,pr} Con{t,tr}: p205_fields(pr,tr,env,p205_match(p,j_strip(t),env,roles))
    case _ _: None{}

@unsafe
def p205_bind_body(p: P205Pattern, t: KTerm, env: List<&2,U32>, state: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match state:
    case None{}: None{}
    case Some{roles}: p205_match(p,j_strip(t),env,roles)

@unsafe
def p205_match(p: P205Pattern, +t: KTerm, +env: List<&2,U32>, +roles: KDef) -> Maybe<&2,KDef>:
  match p:
    case L205{inner}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Lam") && U32.is_ne(qt(t),0) && U32.is_eq(terms_len(ks(t)),1),
        u => p205_match(inner,j_strip(kid(t,0)),Con{ix(t),env},roles),u => None{})
    case B205{value,inner}:
      +b = kid(t,0)
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Let") && p98_tag_eq(b,"Bind") && U32.is_ne(qt(b),0) &&
          U32.is_eq(terms_len(ks(t)),2) && U32.is_eq(terms_len(ks(b)),1),
        u => p205_bind_body(inner,kid(t,1),Con{ix(b),env},p205_match(value,j_strip(kid(b,0)),env,roles)),u => None{})
    case V205{depth}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Var") && p205_var_at(ix(t),env,depth),u => Some{roles},u => None{})
    case R205{role}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Ref") && List.is_empty(&2,KTerm,ks(t)),u => p205_role(roles,role,nm(t)),u => None{})
    case N205{tag,name,children}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,tag) && agy_str_eq(nm(t),name) && List.is_empty(&2,String,rm(t)),
        u => p205_fields(children,ks(t),env,Some{roles}),u => None{})

@unsafe
def p205_verify(+book: List<&2,KDef>, state: Maybe<&2,KDef>, +role: String, eqn: P205Equation) -> Maybe<&2,KDef>:
  match state eqn:
    case Some{+roles} P205Equation{args,pattern}:
      +d = lookup(book,dk(p111v_get(roles,role)))
      kc(Maybe<&2,KDef>,agy_str_eq(dk(d),"Def") && U32.is_eq(dx(d),0) && (Bool.not(db(d)) || agy_str_eq(dn(d),"String.append")) && p205_signature(dt(d),args),
        u => p205_match(pattern,j_strip(dv(d)),[],roles),u => None{})
    case _ _: None{}

@unsafe
def w7_br_803(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      p205u_call_eval(book,t,next,steps,U32.sub(fuel,1),j_call_spine(t,[]))
    case False{}:
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,U32.sub(fuel,1)))

@unsafe
def w7_br_804(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match w7_c:
    case True{}:
      P205UResult{t,next,steps,False{}}
    case False{}:
      w7_br_803(p98_tag_eq(t,"App"), book, t, next, steps, fuel)

@unsafe
def p205u_eval(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  w7_br_804(U32.is_eq(fuel,0) || U32.is_ge(steps,65), book, t, next, steps, fuel)
@unsafe
def w7_br_805(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  match w7_c:
    case True{}:
      p205u_definition(book,t,next,steps,fuel,call,lookup(book,nm(call)))
    case False{}:
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel))

@unsafe
def p205u_call_eval(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  w7_br_805(p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5) && p205u_any_static(book,ks(call)), book, t, next, steps, fuel, call)
@unsafe
def w7_br_806(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  match w7_c:
    case True{}:
      p205u_definition_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d)))
    case False{}:
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel))

@unsafe
def p205u_definition(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  w7_br_806(agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) && U32.is_eq(terms_len(ks(call)),da(d)) && p205u_headshape(dv(d),5) && p205u_room([dv(d)],512), book, t, next, steps, fuel, call, d)
@unsafe
def w7_br_807(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +body: KTerm) -> P205UResult:
  match w7_c:
    case True{}:
      p205u_fresh(book,ks(call),next,steps,fuel,f_fresh_term(body,[],next))
    case False{}:
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel))

@unsafe
def p205u_definition_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  w7_br_807(U32.is_gt(nq_layout_remaining([body],513),0) && p205u_shape(body,dn(d),da(d),0) && p205u_static_arg(book,body,ks(call)), book, t, next, steps, fuel, call, body)
@unsafe
def p205u_fresh( +book: List<&2,KDef>, +args: List<&2,KTerm>, +old: U32, +steps: U32, +fuel: U32, +fresh: FFresh) -> P205UResult:
  match fresh:
    case FFresh{body,next}: p205u_apply(book,body,args,next,steps,fuel)

@unsafe
def p205u_apply(+book: List<&2,KDef>, +body: KTerm, +args: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match args:
    case Nil{}: p205u_eval(book,body,next,steps,fuel)
    case Con{+arg,+rest}:
      kc(P205UResult,p98_tag_eq(body,"Lam") && U32.is_ne(qt(body),0) && U32.is_ne(qt(body),3),u =>
        kc(P205UResult,core_literal(arg),v => p205u_apply(book,subst(kid(body,0),ix(body),arg),rest,next,steps,fuel),v =>
          p205u_bound(book,body,arg,p205u_apply(book,kid(body,0),rest,next,steps,fuel))),u =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil"),v =>
        p205u_string(book,body,rest,next,steps,fuel,p205u_literal(book,arg)),v =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"Chr") && j_fusion_ctor(arg,"Chr",1),w =>
        p205u_apply(book,kid(body,0),Con{kid(arg,0),rest},next,steps,fuel),w => P205UResult{body,next,steps,False{}})))
# Recover only closed monomorphic result domains. Unknown/dependent/function
# types remain unannotated and the ordinary whole-definition recheck decides.
@unsafe
def p205u_bound(+book: List<&2,KDef>, +binder: KTerm, +arg: KTerm, +result: P205UResult) -> P205UResult:
  match result:
    case P205UResult{body,next,steps,ok}:
      P205UResult{kt("Let","",0,0,[kt("Bind",nm(binder),ix(binder),2,[p205u_typed_arg(arg,p205u_bind_type(book,arg))]),body]),next,steps,ok}
@unsafe
def w7_br_816(w7_c: Bool, +book: List<&2,KDef>, +body: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32, +literal: KTerm) -> P205UResult:
  match w7_c:
    case True{}:
      P205UResult{body,next,steps,False{}}
    case False{}:
      p205u_string_chars(book,body,rest,next,steps,fuel,kl_text(literal))

@unsafe
def p205u_string( +book: List<&2,KDef>, +body: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32, +literal: KTerm) -> P205UResult:
  w7_br_816(p98_tag_eq(literal,"Absent"), book, body, rest, next, steps, fuel, literal)
@unsafe
def p205u_string_chars(+book: List<&2,KDef>, +body: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32, +text: String) -> P205UResult:
  match text:
    case SNil{}: p205u_apply(book,kid(body,0),rest,next,U32.inc(steps),fuel)
    case SCon{c,tail}:
      p205u_apply(book,kid(kid(body,1),0),Con{kt("Ctr","Chr",0,1,[KLiteral{"U32",Char.to_u32(c),"",0,0}]),Con{KLiteral{"String",0,tail,0,0},rest}},next,U32.inc(steps),fuel)

@unsafe
def p205u_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205u_field_next(book,rest,fuel,p205u_eval(book,x,next,steps,fuel))
@unsafe
def p205u_field_next( +book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      kc(P205UFields,ok,u => p205u_field_join(term,ok,p205u_fields(book,rest,next,steps,fuel)),u => P205UFields{[],next,steps,False{}})
@unsafe
def w7_br_843(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.sub(a, b)}
    case False{}:
      w7_br_842(agy_str_eq(op, "u32_mul"), op, a, b)

@unsafe
def w7_br_844(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.add(a, b)}
    case False{}:
      w7_br_843(agy_str_eq(op, "u32_sub"), op, a, b)

@unsafe
def ctfe_run_u32_bin(+op: String, +a: U32, +b: U32) -> CtfeVal:
  w7_br_844(agy_str_eq(op, "u32_add"), op, a, b)

@unsafe
def agy_bf_add_def(+context: List<&2,KDef>, +d: KDef) -> List<&2,KDef>:
  +raw_list = {Con{d,agy_bf_strip_cache(context)} : List<&2,KDef>}
  book_cached(raw_list,norm_max_defs([d],norm_book_bound(context)))

@unsafe
def p205v_binary(+op: String, +a: U32, +b: U32) -> KTerm:
  w5c3_bin_eq(String.eq(op,"u32_is_eq"), op, a, b)

@unsafe
def w2d_hoist_fst_ann(+ctx: List<&2,KDef>, +t: KTerm, +st_ty: KTerm, +acc_ty: KTerm) -> KTerm:
  w2d_hoist_fst(ctx,st_ty,acc_ty,t)

@unsafe
def w2d_bind_acc_wrap(+aid: U32, +acc_expr: KTerm, +acc_ty: KTerm, +res: W2State) -> W2State:
  match res:
    case W2State{ctx2,added2,next2,body2,ch2}:
      +ty_acc = kc(KTerm,p98_tag_eq(acc_ty,"Absent"),u => p205u_bind_type(ctx2,acc_expr),u => acc_ty)
      +b = kt("Bind","$w2a",aid,2,[p205u_typed_arg(acc_expr,ty_acc)])
      W2State{ctx2,added2,next2,kt("Let","",0,0,[b,body2]),ch2}

@unsafe
def w2d_is_str_rhs(+ctx: List<&2,KDef>, +rhs: KTerm) -> Bool:
  +ty = j_strip(p205u_bind_type(ctx,rhs))
  ((p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && agy_str_eq(nm(ty),"String")) ||
    (p98_tag_eq(j_strip(rhs),"Ctr") && (agy_str_eq(nm(j_strip(rhs)),"SCon") || agy_str_eq(nm(j_strip(rhs)),"SNil")))

@unsafe
def p111_show_ref(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +id = nc_show_find(book, ty, types, 0)
  nt_choose(P111ShowDesc, U32.is_eq(id, 4294967295),
    u => P111ShowDesc{[P111ShowRef{terms_len(types)}], List.append(&2, KTerm, types, [ty]), ""},
    u => P111ShowDesc{[P111ShowRef{id}], types, ""})

@unsafe
def p111_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  p112_intrinsic(name, values)

@unsafe
def p111_value(+t: KTerm, +env: List<&2, NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "Var"), u => P111ValueCode{Nil{}, N111Local{nc_word(ix(t), env)}, ""}, u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NWord"), u => p111_uint(U32.read(nm(t))), u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NCtr"), u => p111_constructor(nm(t), p111_values(ks(t), env)), u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NOp"), u => p111_intrinsic(nm(t), p111_values(ks(t), env)), u =>
    P111ValueCode{Nil{}, N111Const{0, 0}, "not a native evaluated value"}))))

@unsafe
def p111_nat_sum_join(first: P111ValueCode, +offset: U32, +n: U32) -> P111Code:
  match first:
    case P111ValueCode{+body, +word, +error}:
      p111_prepend(body, p111_value_return(p111_intrinsic("nat_add", [word, N111Const{offset, 0}]), n))

@unsafe
def p111_is_foreign(+definition: KDef) -> Bool:
  nt_choose(Bool, nc_native_def(definition), u => False{}, u => nc_foreign(definition))

@unsafe
def w5c3_decl_check(bad_change: Bool, is_abs: Bool, +index: KDef, +name: String, +h: U32, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match bad_change:
    case True{}: P111VScan{index,"local width/allocation changes: " ++ name,count}
    case False{}:
      P111VScan{p111v_put_h(index,name,h,w5c3_str2_if(alloca,"alloca","local"),width,capacity),"",w5c3_u32_if(is_abs,U32.inc(count),count)}

@unsafe
def w5c3_decl_name(bad_name: Bool, +index: KDef, +name: String, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match bad_name:
    case True{}: P111VScan{index,"invalid/reserved local name: " ++ name,count}
    case False{}:
      +h = index_hash(name, 2166136261)
      +old = w5c3_find(index, name, h)
      +is_abs = String.eq(dk(old),"Absent")
      w5c3_decl_check(Bool.not(is_abs) && (alloca || String.eq(dk(old),"alloca") || Bool.not(U32.is_eq(da(old),width))),
        is_abs, index, name, h, width, capacity, alloca, count)

@unsafe
def w5c3_decl_err(has_err: Bool, +scan: P111VScan, +index: KDef, +name: String, +width: U32, +capacity: U32, +alloca: Bool, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_decl_name(Bool.not(p111v_name_chars(name,0)) || String.eq(name,"state"), index, name, width, capacity, alloca, count)

@unsafe
def p111v_assign(+name: String, +schema: KDef, +live: KDef) -> KDef:
  +h = index_hash(name, 2166136261)
  +found = w5c3_find(schema, name, h)
  p111v_put_h(live, name, h, dk(found), da(found), dx(found))

@unsafe
def w5c3_step_name(empty: Bool, +name: String, +schema: KDef, +live: KDef) -> P111VFlow:
  match empty:
    case True{}: P111VFlow{live,False{},""}
    case False{}: P111VFlow{p111v_assign(name,schema,live),False{},""}

@unsafe
def p111v_step(+ok: Bool, +name: String, +schema: KDef, +live: KDef, +message: String) -> P111VFlow:
  match ok:
    case True{}: w5c3_step_name(String.is_empty(name), name, schema, live)
    case False{}: P111VFlow{live,False{},message}

law w5c3_inter_slow_bucket:
  for +bucket: List<&2,KDef>
  for +other: KDef
  for +out: KDef
  KDef

@unsafe
def w5c3_isb_step(is_abs: Bool, +head: KDef, +found: KDef, +h: U32, rest: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: w5c3_inter_slow_bucket(rest, other, out)
    case False{}:
      +cap = w5c3_u32_if(U32.is_eq(dx(head), dx(found)), dx(head), 0)
      w5c3_inter_slow_bucket(rest, other, p111v_put_h(out, dn(head), h, dk(head), da(head), cap))

@unsafe
def w5c3_inter_slow_bucket(bucket, other, out):
  match bucket:
    case Nil{}: out
    case Con{+head, rest}:
      +h = index_hash(dn(head), 2166136261)
      +found = w5c3_find(other, dn(head), h)
      w5c3_isb_step(String.eq(dk(found), "Absent"), head, found, h, rest, other, out)

@unsafe
def w5c3_inter_slow(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash, bucket}: w5c3_inter_slow_bucket(bucket, right, out)
    case KIndexNode{hash, mask, a, b}: w5c3_inter_slow(b, right, w5c3_inter_slow(a, right, out))
    case _: out

law w5c3_inter_tree:
  for +left: KDef
  for +right: KDef
  KDef

@unsafe
def w5c3_in_eq_pref(ok: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_inter_combine(lh, lm, w5c3_inter_tree(la, ra), w5c3_inter_tree(lb, rb))

@unsafe
def w5c3_in_side(go_left: Bool, +a: KDef, +b: KDef, +other: KDef) -> KDef:
  match go_left:
    case True{}: w5c3_inter_tree(a, other)
    case False{}: w5c3_inter_tree(b, other)

@unsafe
def w5c3_in_side_r(go_left: Bool, +left: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match go_left:
    case True{}: w5c3_inter_tree(left, ra)
    case False{}: w5c3_inter_tree(left, rb)

@unsafe
def w5c3_in_lt_pref(ok: Bool, +rh: U32, +lm: U32, +la: KDef, +lb: KDef, +right: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_in_side(U32.is_eq(U32.and(rh, lm), 0), la, lb, right)

@unsafe
def w5c3_in_gt_pref(ok: Bool, +lh: U32, +rm: U32, +left: KDef, +ra: KDef, +rb: KDef) -> KDef:
  match ok:
    case False{}: missing()
    case True{}: w5c3_in_side_r(U32.is_eq(U32.and(lh, rm), 0), left, ra, rb)

@unsafe
def w5c3_in_cmp(lt: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match lt:
    case True{}: w5c3_in_lt_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right)
    case False{}: w5c3_in_gt_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, rm, left, ra, rb)

@unsafe
def w5c3_in_eq(eq: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match eq:
    case True{}: w5c3_in_eq_pref(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), lh, lm, la, lb, ra, rb)
    case False{}: w5c3_in_cmp(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right)

@unsafe
def w5c3_in_nn(z: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef) -> KDef:
  match z:
    case True{}: w5c3_inter_slow(left, right, missing())
    case False{}: w5c3_in_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right)

@unsafe
def w5c3_inter_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef) -> KDef:
  match right:
    case KIndexLeaf{+rh, rb}: w5c3_inter_node_lb(w5c3_find_bucket(left, rh), rh, rb)
    case KIndexNode{rh, +rm, +ra, +rb}:
      w5c3_in_nn(U32.is_eq(lm, 0) || U32.is_eq(rm, 0), lh, lm, la, lb, left, rh, rm, ra, rb, right)
    case _: missing()

@unsafe
def w5c3_inter_tree(left, right):
  match left:
    case KIndexLeaf{lh, lb}: w5c3_inter_leaf(lh, lb, right)
    case KIndexNode{lh, lm, la, lb}: w5c3_inter_node(lh, lm, la, lb, left, right)
    case _: missing()

@unsafe
def p111v_intersection_bucket(+bucket: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  w5c3_inter_slow_bucket(bucket, other, out)

@unsafe
def w5c3_ctr_sget(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_gt(incoming,0) && U32.is_lt(p111v_literal(p111v_arg(args,1)),U32.sub(arity,incoming))
    case False{}: w5c3_ctr_spop(String.eq(symbol,"p111_rt_stack_pop"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_rget(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_lt(p111v_literal(p111v_arg(args,1)),w5c3_u32_if(U32.is_gt(incoming,0),incoming,arity))
    case False{}: w5c3_ctr_sget(String.eq(symbol,"p111_rt_stack_get"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_ret(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  match m:
    case True{}: U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p111v_buffer(args,1,result,live)
    case False{}: w5c3_ctr_rget(String.eq(symbol,"p111_rt_reg_get"), symbol, args, live, arity, incoming)

@unsafe
def p111v_offset(+name: String, +base: N111Value, +bytes: N111Value, +live: KDef, +ids: N111Ids) -> P111VFlow:
  match base:
    case N111Local{bname}:
      +offset = p111v_literal(bytes)
      +found = p111v_get(live, bname)
      +capacity = dx(found)
      w5c3_offset_if(Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),3) && p111v_value(bytes,2,live,ids) && U32.is_le(offset,capacity),
        name, live, capacity, offset)
    case _: P111VFlow{live,False{},"unbounded or ill-typed pointer offset"}

@unsafe
def w5c3_fn_abi(bad: Bool, +name: String, +h: U32, +arity: U32, +incoming: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"segment metadata exceeds ABI capacity: " ++ name,count}
    case False{}: p111v_functions(rest,P111VScan{p111v_put_h(index,name,h,"function",arity,incoming),"",U32.inc(count)})

@unsafe
def w5c3_fn_dup(bad: Bool, +name: String, +h: U32, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"invalid/duplicate segment name: " ++ name,count}
    case False{}: w5c3_fn_abi(U32.is_gt(arity,255) || U32.is_gt(result,255) || U32.is_gt(incoming,arity) || U32.is_gt(flags,255), name, h, arity, incoming, rest, index, count)

@unsafe
def w5c3_fn_cap(full: Bool, +name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match full:
    case True{}: P111VScan{index,"segment count exceeds 16-bit FID capacity with four runtime IDs",count}
    case False{}:
      +h = index_hash(name, 2166136261)
      w5c3_fn_dup(Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(w5c3_find(index,name,h)),"Absent")), name, h, arity, result, incoming, flags, rest, index, count)

@unsafe
def w5c3_fn_err(has_err: Bool, +scan: P111VScan, +name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, rest: List<&2,N111Segment>, +index: KDef, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_fn_cap(U32.is_ge(count,65532), name, arity, result, incoming, flags, rest, index, count)

@unsafe
def p111v_functions(+segments: List<&2,N111Segment>, +scan: P111VScan) -> P111VScan:
  match segments:
    case Nil{}: scan
    case Con{N111Segment{+name,+arity,result,+incoming,flags,body},rest}:
      match scan:
        case P111VScan{+index,+error,+count}:
          w5c3_fn_err(Bool.not(String.is_empty(error)), scan, name, arity, result, incoming, flags, rest, index, count)

@unsafe
def w5c3_ct_abi(bad: Bool, +name: String, +h: U32, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"constructor arity exceeds ABI capacity: " ++ name,count}
    case False{}: p111v_constructors(rest,P111VScan{p111v_put_h(index,name,h,"constructor",arity,0),"",U32.inc(count)})

@unsafe
def w5c3_ct_dup(bad: Bool, +name: String, +h: U32, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match bad:
    case True{}: P111VScan{index,"invalid/duplicate constructor name: " ++ name,count}
    case False{}: w5c3_ct_abi(U32.is_gt(arity,255), name, h, arity, rest, index, count)

@unsafe
def w5c3_ct_cap(full: Bool, +name: String, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match full:
    case True{}: P111VScan{index,"constructor count exceeds 16-bit CID capacity",count}
    case False{}:
      +h = index_hash(name, 2166136261)
      w5c3_ct_dup(Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(w5c3_find(index,name,h)),"Absent")), name, h, arity, rest, index, count)

@unsafe
def w5c3_ct_err(has_err: Bool, +scan: P111VScan, +name: String, +arity: U32, rest: List<&2,N_Constructor>, +index: KDef, +count: U32) -> P111VScan:
  match has_err:
    case True{}: scan
    case False{}: w5c3_ct_cap(U32.is_ge(count,65535), name, arity, rest, index, count)

@unsafe
def p111v_constructors(+constructors: List<&2,N_Constructor>, +scan: P111VScan) -> P111VScan:
  match constructors:
    case Nil{}: scan
    case Con{N_Constructor{+name,+arity,hot},rest}:
      match scan:
        case P111VScan{+index,+error,+count}:
          w5c3_ct_err(Bool.not(String.is_empty(error)), scan, name, arity, rest, index, count)

@unsafe
def p111q_insert(+tree: KDef, +name: String, id: U32) -> KDef:
  index_set(tree,KDef{name,"N111Id",id,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p111q_function_ids(segments: List<&2,N111Segment>, +next: U32, tree: KDef) -> KDef:
  match segments:
    case Nil{}: tree
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_function_ids(rest,U32.inc(next),p111q_insert(tree,name,next))

@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,+hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,kt("P185Constructor","",nt_choose(U32,hot,u => 1,u => 0),11102,[]),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
          index_hash(name,2166136261),32))

@unsafe
def p111q_ids(+program: P111Program) -> N111Ids:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      N111Ids{p111q_function_ids(segments,0,missing()),p111q_constructor_ids(constructors,0,missing())}

@unsafe
def p112_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  +arity = p112_scalar_arity(id)
  nt_choose(P111ValueCode, U32.is_gt(arity, 0) && U32.is_eq(arity, nt_count(N111Value, values)) && p112_scalar_safe(values),
    u => p112_scalar_dispatch(id, values),
    u => nt_choose(P111ValueCode, (U32.is_eq(id, 68) || U32.is_eq(id, 69)) &&
      U32.is_eq(nt_count(N111Value, values), 2) && p185_bool_safe(values),
      v => p185_bool_binary(nt_choose(String, U32.is_eq(id, 68), w => "or", w => "xor"),
        p111_head(values), p111_head(p111_tail(values))),
      v => p112_intrinsic_fallback(name, values)))


@unsafe
def p112s_ctors(constructors: List<&2,N_Constructor>, +next: U32, index: KDef) -> KDef:
  match constructors:
    case Nil{}: index
    case Con{N_Constructor{+name,arity,hot},rest}:
      p112s_ctors(rest,U32.inc(next),index_set(index,KDef{name,"P112StaticCtor",next,arity,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32))


@unsafe
def p112s_block_effects(index: KDef, names: List<&2,String>) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p112s_block_effects(index_set(index,KDef{name,"P112StaticForeign",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32),rest)


@unsafe
def w8_p112s_intern_hit(hit: Bool, +old: KDef, +term: KTerm, +fields: List<&2,P112SWord>, +key: String, +hash: U32, +size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String) -> P112STerm:
  match hit:
    case True{}:
      P112STerm{p112s_marker(P112SBox{nm(term),da(old)}),P112SImage{size,nodes,index,error}}
    case False{}:
      +count = nt_count(P112SWord,fields)
      w8_p112s_intern_fit(U32.is_le(size,65536) && U32.is_le(count,U32.sub(65536,size)),term,fields,key,hash,count,size,nodes,index,error)

@unsafe
def p112s_intern(+term: KTerm, +fields: List<&2,P112SWord>, image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{+size,+nodes,+index,+error}:
      +key = nc_ctor_codes(nm(term)) ++ ":" ++ p112s_fields_key(fields)
      +hash = index_hash(key,2166136261)
      +old = w5c3_find(index,key,hash)
      w8_p112s_intern_hit(agy_str_eq(dk(old),"P112StaticIntern"),old,term,fields,key,hash,size,nodes,index,error)


@unsafe
def p112s_attach_book(book: List<&2,KDef>, +facts: List<&2,KDef>, +size: U32, +nodes: List<&2,P112SNode>, +constructors: KDef, +error: String) -> P112SPrepared:
  match book:
    case Con{+cache,+rest}:
      P112SPrepared{Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
        [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,kt("P112StaticImage","",size,0,[]),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[index_build(facts),nc_ctor_prepare(Con{cache,rest}),constructors,p112s_node_index(nodes,missing())],False{},False{}}],db(cache),du(cache)},rest},nodes,error}
    case _: P112SPrepared{book,[],"static preparation requires a fresh cached request"}


@unsafe
def p112s_nodes_error(nodes: List<&2,P112SNode>, +constructors: KDef, +prior: KDef, +next: U32) -> String:
  match nodes:
    case Nil{}: ""
    case Con{+node,+rest}:
      p112s_node_error(node,rest,constructors,prior,next)


@unsafe
def p112s_node_error(node: P112SNode, +rest: List<&2,P112SNode>, +constructors: KDef, +prior: KDef, +next: U32) -> String:
  match node:
    case P112SNode{+offset,+name,+fields}:
      +count = nt_count(P112SWord,fields)
      nt_choose(String,Bool.not(U32.is_eq(offset,next)) || U32.is_eq(count,0) || U32.is_gt(next,65536) || U32.is_gt(count,U32.sub(65536,next)),
        u => "static image offset or word budget invalid",u =>
      nt_choose(String,p112s_constructor_ok(constructors,name,count),u =>
      nt_choose(String,p112s_fields_valid(fields,constructors,prior),u =>
        p112s_nodes_error(rest,constructors,p112s_node_index([P112SNode{offset,name,fields}],prior),U32.add(next,count)),u => "static image child is not a prior immutable word"),u => "static image constructor or arity invalid"))


@unsafe
def p112s_image_error(bundle: P112StaticProgram) -> String:
  match bundle:
    case P112StaticProgram{P111Program{segments,constructors,show,show_names,effects,pure},nodes}:
      p112s_nodes_error(nodes,p112s_block_effects(p112s_ctors(constructors,0,missing()),effects),missing(),0)


@unsafe
def p112s_tables(+program: P111Program, +nodes: List<&2,P112SNode>, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,p112s_patch_tables(p111q_tables(program,ids),p112s_size(nodes,0),[]),
        [P111QData{"p111_static_image",8,False{},p112s_image_items(nodes,p112s_ctors(constructors,0,missing()),[])}])


@unsafe
def p112f_fused(frame: P112FusionFrame, +cont: P112FusionCont, +target: String, +arity: U32, +site: U32) -> List<&2,N111Stmt>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +prefix = "p112f_" ++ U32.show(site) ++ "_"
      nt_append(N111Stmt,p112f_snapshots(captures,prefix,"capture_",0),
        Con{N111Set{dest,N111U64{},N111Const{0,0}},
          nt_append(N111Stmt,p112f_snapshots(p112f_values(tail,arity),prefix,"arg_",0),
            Con{N111Call{prefix ++ "result",N111U64{},p112w_symbol(target),Con{p111_state(),p112f_callargs(arity,0,prefix)}},p112f_inline(cont,prefix)})})


@unsafe
def p112f_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,N111Segment>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame found:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+tail} Some{+segment}:
      p112f_cont_found(frame,target,arity,site,p112f_cont(segment,nt_count(N111Value,captures)))


@unsafe
def p112f_cont_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,P112FusionCont>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+cont}: Some{p112f_fused(frame,cont,target,arity,site)}


@unsafe
def p112c_freeze(+segment: N111Segment, +rank: U32, +sites: U32, +next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,p112w_admitted(plan),u => p112c_insert(segment,rank,sites,next,plan),u => next)


@unsafe
def p112c_insert(+segment: N111Segment, +rank: U32, +sites: U32, next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  match segment next:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,rank),p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,rank),
        Con{P112RegionEntry{segment,plan,rank,sites},entries},U32.inc(workers),U32.add(fusions,sites)}


@unsafe
def p112c_fused(segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry, fused: P112FusionBody) -> P112RegionRegistry:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      p112c_freeze(transformed,rank,count,next,p112c_plan(transformed,old,symbols,count))

# This helper receives only a qualified typed candidate from p112c_candidates.


@unsafe
def p113d_nat_join(first: P111ValueCode, offset: U32, target: P113DTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113d_emitted(target,n,p111_intrinsic("nat_add",[word,N111Const{offset,0}])))


law p113d_passes:
  for +candidates: List<&2,P113DCandidate>
  for +index: KDef
  for +functions: List<&2,P113DFunction>
  for +fuel: U32
  List<&2,P113DFunction>


@unsafe
def p113d_pass_next(+fuel: U32, pass: P113DPass) -> List<&2,P113DFunction>:
  match pass:
    case P113DPass{index,+functions,waiting,count}:
      nt_choose(List<&2,P113DFunction>,U32.is_eq(count,0),u => nt_reverse(P113DFunction,functions,[]),
        u => p113d_passes(waiting,index,functions,U32.sub(fuel,1)))


@unsafe
def p113d_passes(candidates,index,functions,fuel):
  nt_choose(List<&2,P113DFunction>,U32.is_eq(fuel,0),u => nt_reverse(P113DFunction,functions,[]),
    u => p113d_pass_next(fuel,p113d_pass(candidates,index,functions,[],0)))
# Forward signatures only; place before the nine replacement definitions.
@unsafe
def p113e_insert(+index: KDef, +record: KDef) -> KDef:
  index_set(index,record,index_hash(dn(record),2166136261),32)


@unsafe
def p113e_signatures(functions: List<&2,P113DFunction>, index: KDef) -> KDef:
  match functions:
    case Nil{}: index
    case Con{function,rest}: p113e_signatures(rest,p113e_insert(index,p113e_signature(function)))


@unsafe
def p113e_originals(segments: List<&2,N111Segment>, index: KDef) -> KDef:
  match segments:
    case Nil{}: index
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p113e_originals(rest,p113e_insert(index,KDef{name,"P113Original",arity,incoming,atom("Absent"),kt("P113Meta","",flags,result,[]),[],False{},False{}}))


@unsafe
def p113e_assign_names(names: List<&2,String>, +schema: KDef, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{head,rest}: p113e_assign_names(rest,schema,p111v_assign(head,schema,live))


@unsafe
def p113e_call(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef) -> P111VFlow:
  +signature = p111v_get(ready,target)
  nt_choose(P111VFlow,agy_str_eq(dk(signature),"P113Direct") && U32.is_eq(da(signature),nt_count(N111Value,args)) &&
    U32.is_eq(dx(signature),nt_count(String,destinations)) && p113e_distinct(destinations) && p113e_values(args,live,ids),
    u => P111VFlow{p113e_assign_names(destinations,schema,live),False{},""},
    u => P111VFlow{live,False{},"unknown/cyclic direct call or argument/result mismatch: " ++ target})


@unsafe
def p113pl_nat_join(first: P111ValueCode, offset: U32, target: P113PTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113pl_boxed(p111_intrinsic("nat_add",[word,N111Const{offset,0}]),target,n))


@unsafe
def p113n_field_kinds(+book: List<&2,KDef>, +name: String, +count: U32) -> List<&2,N_WordKind>:
  +d = nc_find_ctor(book,nc_ctor_display(name))
  nt_choose(List<&2,N_WordKind>,agy_str_eq(dk(d),"Ctr") && U32.is_le(da(d),8),
    u => nt_choose(List<&2,N_WordKind>,agy_str_eq(name,nc_ctor_identity(book,dn(d))) &&
      U32.is_eq(count,nc_live_count(book,dt(d),da(d))) && p113n_closed_owner(book,p113n_ctor_end(book,dt(d),da(d))),
      v => nf_kind_tele(book,dt(d),count,32),v => nf_opaque_kinds(count)),
    u => nf_opaque_kinds(count))


@unsafe
def p113i_scan(body: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match body:
    case Nil{}: P113IScan{[],site,budget}
    case Con{P113DIf{condition,yes,no},rest}:
      p113i_scan_yes(condition,no,rest,table,p113i_scan(yes,table,site,budget))
    case Con{+stmt,rest}: p113i_scan_stmt(stmt,rest,table,site,budget)


@unsafe
def p113i_scan_yes(+condition: N111Value, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, yes: P113IScan) -> P113IScan:
  match yes:
    case P113IScan{body,next,budget}: p113i_scan_no(condition,body,rest,table,p113i_scan(no,table,next,budget))


@unsafe
def p113i_scan_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, no: P113IScan) -> P113IScan:
  match no:
    case P113IScan{body,next,budget}: p113i_prepend(P113DIf{condition,yes,body},p113i_scan(rest,table,next,budget))


@unsafe
def p113i_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,64),
        u => p113j_scan_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))


@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +tiny = U32.is_le(p113i_size(body),64) && U32.is_eq(p113j_scratch(body),0) && w5_body_no_dcalls(body)
      nt_choose(List<&2,P113DStmt>,tiny,
        u => nt_append(P113DStmt,p113i_bind(params,args,prefix),
          w5_expand_peel(body,prefix,destinations,P113DFunction{name,params,result,public,body},2)),
        u => nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
          nt_append(P113DStmt,p113i_bind(params,args,prefix),w4i_expand(body,prefix,destinations,name))))


@unsafe
def p113j_scan_found(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, found: Maybe<&2,P113DFunction>) -> P113IScan:
  match found:
    case None{}: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))
    case Some{+function}: p113j_scan_cost(stmt,rest,table,site,budget,destinations,args,function,p113j_cost(function))


@unsafe
def p113j_scan_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  +eff = nt_choose(U32,w4g_has_const_arg(args),u => U32.max(1,U32.div(cost,4)),u => cost)
  nt_choose(P113IScan,U32.is_le(eff,budget),
    u => p113i_join(p113j_inline(function,args,destinations,"p113i_" ++ U32.show(site) ++ "_"),
      p113i_scan(rest,table,U32.inc(site),U32.sub(budget,eff))),
    u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))


@unsafe
def p113k_kill(names: List<&2,String>, facts: KDef) -> KDef:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p113k_kill(rest,p113k_put(facts,name,p113k_bound(64)))


@unsafe
def w5c2_join_pair_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +ra: U32, +rx: U32, +rv: KTerm, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}:
      p113k_join_insert(out, name, hash, p113k_join_fact(
        P113KFact{la, U32.is_eq(lx, 1), ix(lv), qt(lv)},
        P113KFact{ra, U32.is_eq(rx, 1), ix(rv), qt(rv)}))

@unsafe
def w5c2_join_found(+found: KDef, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +out: KDef) -> KDef:
  match found:
    case KDef{_, rkind, ra, rx, _, rv, _, _, _}:
      w5c2_join_pair_ok(String.eq(rkind, "P113KFact"), name, hash, la, lx, lv, ra, rx, rv, out)
    case _: out

@unsafe
def w5c2_join_rec_h_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +right: KDef, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}: w5c2_join_found(index_find(right, name, hash, 32), name, hash, la, lx, lv, out)

@unsafe
def w5c2_join_rec_b_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}: w5c2_join_found(index_bucket(rbucket, name), name, hash, la, lx, lv, out)

@unsafe
def p113k_bin_fact(+typ: N111Type, +op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  +width = p113k_width(typ)
  p113k_limit(p113k_binary(op,p113k_limit(left,width),p113k_limit(right,width),width),width)


@unsafe
def w4g_ic_mark_val(v: N111Value, m: KDef) -> KDef:
  match v:
    case N111Local{n}: w4g_ic_mark(m,n)
    case _: m


@unsafe
def w4g_ic_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{n,_,_}},rest}: w4g_ic_writes(rest,w4g_ic_mark(acc,n))
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},rest}: w4g_ic_writes(rest,w4g_ic_mark(acc,n))
    case Con{_,rest}: w4g_ic_writes(rest,acc)


@unsafe
def w4g_ic_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(r,w4g_ic_mark_val(l,acc)))
    case Con{_,rest}: w4g_ic_reads(rest,acc)


@unsafe
def w4k_mark_val(value: N111Value, used: KDef) -> KDef:
  match value:
    case N111Local{+name}: index_set(used,KDef{name,"W4KUsed",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)
    case _: used


@unsafe
def w4k_mark_vals(values: List<&2,N111Value>, used: KDef) -> KDef:
  match values:
    case Nil{}: used
    case Con{v,rest}: w4k_mark_vals(rest,w4k_mark_val(v,used))


@unsafe
def w4k_mark_args(args: List<&2,N111Arg>, used: KDef) -> KDef:
  match args:
    case Nil{}: used
    case Con{N111Arg{typ,v},rest}: w4k_mark_args(rest,w4k_mark_val(v,used))


law w4k_mark_scalars:
  for body: List<&2,N111Stmt>
  for used: KDef
  KDef


@unsafe
def w4k_mark_scalar(stmt: N111Stmt, used: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,v}: w4k_mark_val(v,used)
    case N111Bin{name,typ,op,l,r}: w4k_mark_val(r,w4k_mark_val(l,used))
    case N111Call{name,typ,sym,args}: w4k_mark_args(args,used)
    case N111If{cond,yes,no}: w4k_mark_scalars(no,w4k_mark_scalars(yes,w4k_mark_val(cond,used)))
    case N111Load{name,typ,base,off}: w4k_mark_val(base,used)
    case N111Store{typ,base,off,v}: w4k_mark_val(v,w4k_mark_val(base,used))
    case N111Offset{name,base,bytes}: w4k_mark_val(bytes,w4k_mark_val(base,used))
    case N111Return{v}: w4k_mark_val(v,used)
    case _: used


@unsafe
def w4k_mark_scalars(body, used):
  match body:
    case Nil{}: used
    case Con{s,rest}: w4k_mark_scalars(rest,w4k_mark_scalar(s,used))


@unsafe
def w4g_bump_names(names: List<&2,String>, +env: W4GCopyEnv) -> W4GCopyEnv:
  match names:
    case Nil{}: env
    case Con{n,rest}: w4g_bump_names(rest,w4g_bump(env,n))


@unsafe
def w4g_record_alias_in(env: W4GCopyEnv, +dst: String, +rsrc: String) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +sv = w4g_ver(vers,rsrc)
      +ent : KDef = KDef{dst,"W4GAlias",sv,0,atom("Absent"),kt("W4GSrc",rsrc,0,0,[]),[],False{},False{}}
      W4GCopyEnv{vers,index_set(aliases,ent,index_hash(dst,2166136261),32)}


@unsafe
def w4g_record_alias(+env: W4GCopyEnv, +dst: String, +rsrc: String) -> W4GCopyEnv:
  w4g_record_alias_in(w4g_bump(env,dst),dst,rsrc)


law w4g_cscalars:
  for stmts: List<&2,N111Stmt>
  for +env: W4GCopyEnv
  W4GCopySc


@unsafe
def w4g_cscalar(stmt: N111Stmt, +env: W4GCopyEnv) -> W4GCopySc:
  match stmt:
    case N111Set{+dst,+typ,N111Local{+src}}:
      +rsrc = w4g_resolve(env,src)
      +is64 = U32.is_eq(p111v_type(typ),2)
      nt_choose(W4GCopySc,is64 && agy_str_eq(dst,rsrc) && Bool.not(w4g_reserved(dst)),
        u => W4GCopySc{[],env},
        u => nt_choose(W4GCopySc,is64 && Bool.not(w4g_reserved(dst)) && Bool.not(w4g_reserved(rsrc)),
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_record_alias(env,dst,rsrc)},
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_bump(env,dst)}))
    case N111Set{+dst,+typ,val}:
      W4GCopySc{[N111Set{dst,typ,w4g_cval(env,val)}],w4g_bump(env,dst)}
    case N111Bin{+dst,+typ,+op,l,r}:
      W4GCopySc{[N111Bin{dst,typ,op,w4g_cval(env,l),w4g_cval(env,r)}],w4g_bump(env,dst)}
    case N111Offset{+dst,b,by}:
      W4GCopySc{[N111Offset{dst,w4g_cval(env,b),w4g_cval(env,by)}],w4g_bump(env,dst)}
    case N111Load{+dst,+typ,b,off}:
      W4GCopySc{[N111Load{dst,typ,w4g_cval(env,b),off}],w4g_bump(env,dst)}
    case N111Store{typ,b,off,v}:
      W4GCopySc{[N111Store{typ,w4g_cval(env,b),off,w4g_cval(env,v)}],env}
    case N111Call{+dst,+typ,+sym,args}:
      W4GCopySc{[N111Call{dst,typ,sym,w4g_cargs(env,args)}],w4g_bump(env,dst)}
    case N111Alloca{+dst,bytes,align}:
      W4GCopySc{[N111Alloca{dst,bytes,align}],w4g_bump(env,dst)}
    case N111Return{v}:
      W4GCopySc{[N111Return{w4g_cval(env,v)}],env}
    case N111If{cond,yes,no}:
      w4g_cscalar_if(cond,env,w4g_cscalars(yes,env),w4g_cscalars(no,env))


@unsafe
def w4g_cscalars_next(res: W4GCopySc, rest: List<&2,N111Stmt>) -> W4GCopySc:
  match res:
    case W4GCopySc{pre,env}: w4g_cscalars_join(pre,w4g_cscalars(rest,env))


@unsafe
def w4g_cscalars(stmts, env):
  match stmts:
    case Nil{}: W4GCopySc{[],env}
    case Con{s,rest}: w4g_cscalars_next(w4g_cscalar(s,env),rest)


@unsafe
def w4g_live_val(v: N111Value, live: KDef) -> KDef:
  match v:
    case N111Local{n}: w4g_live_mark(live,n)
    case _: live


@unsafe
def w4g_live_vals(vs: List<&2,N111Value>, live: KDef) -> KDef:
  match vs:
    case Nil{}: live
    case Con{v,rest}: w4g_live_vals(rest,w4g_live_val(v,live))


@unsafe
def w4g_live_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{_,v},rest}: w4g_live_args(rest,w4g_live_val(v,live))


@unsafe
def w4g_live_kills(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{n,rest}: w4g_live_kills(rest,w4g_live_kill(live,n))


@unsafe
def w5b_w4g_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w5b_w4g_union_bkt(hash,rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),hash,h,out))

@unsafe
def w4g_live_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w4g_live_union_bucket(rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),index_hash(dn(h),2166136261),h,out))

@unsafe
def w4g_live_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_w4g_union_bkt(hash,bucket,out)
    case KIndexNode{_,_,a,b}: w4g_live_union(b,w4g_live_union(a,out))
    case _: out


@unsafe
def w4g_live_base() -> KDef:
  w4g_live_mark(w4g_live_mark(w4g_live_mark(w4g_live_mark(w4g_live_mark(missing(),
    "state"),"scratch"),"__x181_result_out"),"__x181_results"),"__x181_tail")


# Pure-diamond if-conversion helpers (100% general).
@unsafe
def w4g_arm_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{n,_,_}},rest}: w4g_arm_writes(rest,w4g_live_mark(acc,n))
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},rest}: w4g_arm_writes(rest,w4g_live_mark(acc,n))
    case Con{_,rest}: w4g_arm_writes(rest,acc)


@unsafe
def w4g_arm_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_arm_reads(rest,w4g_live_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_arm_reads(rest,w4g_live_val(r,w4g_live_val(l,acc)))
    case Con{_,rest}: w4g_arm_reads(rest,acc)


@unsafe
def w4g_bwd_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef, yes: W4GBwd, no: W4GBwd) -> W4GBwd:
  match yes no:
    case W4GBwd{Nil{},yl} W4GBwd{Nil{},nl}:
      W4GBwd{rest,w4g_live_union(yl,nl)}
    case W4GBwd{yb,yl} W4GBwd{nb,nl}:
      W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))}


@unsafe
def w4c_seed_w32_facts(params: List<&2,NC_Binding>, +facts: KDef) -> KDef:
  match params:
    case Nil{}: facts
    case Con{NC_Binding{_,word,N_W32{}},rest}:
      w4c_seed_w32_facts(rest,p113k_put(facts,word,p113k_bound(32)))
    case Con{_,rest}: w4c_seed_w32_facts(rest,facts)

@unsafe
def p113ai_intrinsic(+name: String, +values: List<&2,N111Value>, +n: U32) -> P111ValueCode:
  nt_choose(P111ValueCode,agy_str_eq(name,"array_set") && U32.is_eq(nt_count(N111Value,values),3),
    u => p113ai_set_done(values,n,p111_intrinsic(name,values)),
    u => p111_intrinsic(name,values))


@unsafe
def w4k_invalidate_ptr_args(args: List<&2,N111Arg>, +facts: KDef) -> KDef:
  match args:
    case Nil{}: facts
    case Con{N111Arg{N111Ptr{},N111Local{+buf}},+rest}:
      nt_choose(KDef,agy_str_eq(buf,"state"),
        u => w4k_invalidate_ptr_args(rest,facts),
        u => w4k_invalidate_ptr_args(rest,
          p113k_put(p113k_put(facts,w4k_slot_key(buf,0),p113k_bound(64)),w4k_slot_key(buf,8),p113k_bound(64))))
    case Con{_,rest}: w4k_invalidate_ptr_args(rest,facts)


@unsafe
def w4k_fold_u32_to_f32(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef, fact0: P113KFact) -> P113KScalar:
  match fact0:
    case P113KFact{b0,True{},+lo0,0}:
      +bits = F32.bits(U32.to_f32(lo0))
      P113KScalar{[N111Set{name,N111U64{},N111Const{bits,0}}],p113k_put(facts,name,p113k_exact(bits,0))}
    case _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_fold_f32_bin_done(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef, res: Maybe<&2,U32>) -> P113KScalar:
  match res:
    case Some{+bits}:
      P113KScalar{[N111Set{name,N111U64{},N111Const{bits,0}}],p113k_put(facts,name,p113k_exact(bits,0))}
    case None{}:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_fold_f32_bin(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +id: U32, +facts: KDef, fact0: P113KFact, fact1: P113KFact) -> P113KScalar:
  match fact0 fact1:
    case P113KFact{b0,True{},+lo0,0} P113KFact{b1,True{},+lo1,0}:
      w4k_fold_f32_bin_done(name,typ,symbol,args,facts,w4k_f32_bin_eval(id,w4k_bits_to_f32(lo0),w4k_bits_to_f32(lo1)))
    case _ _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(32))}


@unsafe
def w4k_call_fold(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +facts: KDef) -> P113KScalar:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U64{},+val},Nil{}}}:
      +vf = p113k_value(val,facts)
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_sink") && agy_str_eq(state,"state") && U32.is_le(p113k_bits_of(vf),56),
        u => P113KScalar{[N111Set{name,N111U64{},N111Const{0,0}}],p113k_put(facts,name,p113k_exact(0,0))},u =>
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_keep") && agy_str_eq(state,"state") && U32.is_le(p113k_bits_of(vf),56),
        u => P113KScalar{[N111Set{name,N111U64{},p113k_replace(val,facts)}],p113k_put(facts,name,vf)},u =>
        P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buf}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}:
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && U32.is_eq(id,23) && U32.is_eq(count,1),
        u => w4k_fold_u32_to_f32(name,typ,symbol,args,facts,p113k_get(facts,w4k_slot_key(buf,0))),u =>
      nt_choose(P113KScalar,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && U32.is_ge(id,26) && U32.is_le(id,29) && U32.is_eq(count,2),
        u => w4k_fold_f32_bin(name,typ,symbol,args,id,facts,p113k_get(facts,w4k_slot_key(buf,0)),p113k_get(facts,w4k_slot_key(buf,8))),u =>
        P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}))
    case _ _:
      P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(w4k_invalidate_ptr_args(args,facts),name,p185k_call_fact(typ,symbol,args))}


@unsafe
def w4k_store_facts(typ: N111Type, base: N111Value, +offset: U32, value: N111Value, +facts: KDef) -> KDef:
  match typ base:
    case N111U64{} N111Local{+buf}:
      nt_choose(KDef,U32.is_eq(offset,0) || U32.is_eq(offset,8),
        u => p113k_put(facts,w4k_slot_key(buf,offset),p113k_value(value,facts)),
        u => facts)
    case _ _: facts


@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts, KDef{key, "P113LRelation", truth, 0, kt("Epoch", "", version, p113l_version(facts, name), []), kt("Subject", subject, 0, 0, []), [], False{}, False{}}, index_hash(key, 2166136261), 32)

@unsafe
def w5c2_p113l_copy_ok(ok: Bool, +after: KDef, +name: String, +fval: KTerm, +ftyp: KTerm, +arity: U32, +invert: Bool) -> KDef:
  match ok:
    case True{}: p113l_relate(after, name, nm(fval), ix(ftyp), U32.xor(arity, Bool.to_u32(invert)))
    case False{}: after

@unsafe
def w5c2_p113l_copy_rec(record: KDef, +after: KDef, +name: String, +invert: Bool) -> KDef:
  match record:
    case KDef{_, kind, arity, _, ftyp, fval, _, _, _}:
      w5c2_p113l_copy_ok(String.eq(kind, "P113LRelation"), after, name, fval, ftyp, arity, invert)
    case _: after

@unsafe
def w5c2_p113l_cmp_if(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +subject: String, +lo: U32) -> KDef:
  match ok:
    case True{}: p113l_relate(after, name, subject, p113l_version(before, subject), U32.xor(lo, Bool.to_u32(String.eq(op, "ne"))))
    case False{}: after

@unsafe
def p113l_comparison(+before: KDef, +after: KDef, +name: String, +op: String, left: N111Value, right: N111Value) -> KDef:
  match left right:
    case N111Local{+subject} N111Const{+lo,+hi}:
      w5c2_p113l_cmp_if((String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p113k_get(before,subject)),1), before, after, name, op, subject, lo)
    case _ _: after

@unsafe
def w5c2_p113l_assume_ok(ok: Bool, +facts: KDef, +subj: String, +arity: U32, +truth: Bool) -> KDef:
  match ok:
    case True{}: p113k_put(facts, subj, p113k_exact(U32.xor(arity, Bool.to_u32(Bool.not(truth))), 0))
    case False{}: facts

@unsafe
def w5c2_p113l_assume_rec(record: KDef, +facts: KDef, +truth: Bool) -> KDef:
  match record:
    case KDef{_, kind, arity, _, _, fval, _, _, _}:
      +subj = nm(fval)
      w5c2_p113l_assume_ok(String.eq(kind, "P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts, subj)), 1), facts, subj, arity, truth)
    case _: facts

@unsafe
def p113l_assume(+facts: KDef, condition: N111Value, +truth: Bool) -> KDef:
  match condition:
    case N111Local{name}: w5c2_p113l_assume_rec(p113l_relation(facts, name), facts, truth)
    case _: facts


@unsafe
def p114h_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112t_failure(body),u => P114GBody{True{},[],[P114RFailure{body}]},
    u => p114h_scan_normal(body,owner,arity,ready))


@unsafe
def p114h_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112w_result(body),
    u => P114GBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114GBody,p112t_tail(body,owner,arity,0),
    u => P114GBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114h_scan_target(body,owner,arity,ready,p112w_target(body))))


@unsafe
def p114h_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready),
    u => p124r_terminal(body,owner,arity,ready,target,p124r_lookup(ready,target)),
    u => p124r_original_target(body,owner,arity,ready,target))

@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  p186sf_frame(body,owner,arity,ready,frame)

@unsafe
def p186sf_previous_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p126r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => p124r_resume(body,tail,owner,name,count,ready))
    case None{}: p114h_scan_next(body,owner,arity,ready)

@unsafe
def p114h_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  match body:
    case Nil{}: P114GBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114g_branch(condition,p114h_scan(yes,owner,arity,ready),p114h_scan(no,owner,arity,ready),p114h_scan(rest,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P114GBody,p112t_scalar_safe(stmt),
        u => p114g_prepend(stmt,p114h_scan_normal(rest,owner,arity,ready)),
        u => p114g_prepend(stmt,p114h_scan(rest,owner,arity,ready)))

# A missing case has an impossible capture count; real layouts are 0..8.


@unsafe
def p117h_put(facts: KDef, +name: String, origin: U32) -> KDef:
  index_set(facts,KDef{name,"P117HOrigin",origin,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32)


@unsafe
def p117h_seed(params: List<&2,NC_Binding>, +origin: U32, facts: KDef) -> KDef:
  match params:
    case Nil{}: facts
    case Con{NC_Binding{id,name,kind},rest}: p117h_seed(rest,U32.inc(origin),p117h_put(facts,name,origin))


@unsafe
def p117h_write(+base: N111Value, +offset: U32, +origin: U32, +slots: KDef) -> KDef:
  +key = p117h_slot(base,offset)
  nt_choose(KDef,agy_str_eq(key,""),u => missing(),u => p117h_put(slots,key,origin))


@unsafe
def p117h_set(+name: String, origin: U32, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_put(facts,name,origin),slots,
        nt_choose(U32,p117h_buffer(name),u => 0,u => mask),used,again,left,next,sites}


@unsafe
def p117h_kill(names: List<&2,String>, facts: KDef) -> KDef:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p117h_kill(rest,p117h_put(facts,name,0))

# Calls invalidate all scratch/output memory knowledge, even when their normal
# signature does not mention a buffer. Verified array helpers restore only their
# exact transfer identity, never payload knowledge or uniqueness.

@unsafe
def p117h_call(+name: String, +id: U32, +args: List<&2,N111Arg>, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,+slots,mask,used,again,left,next,sites}:
      +origin = nt_choose(U32,U32.is_eq(id,0),u => 0,u => p117h_load(p111v_arg(args,2),0,slots))
      P117HScan{p117h_put(facts,name,nt_choose(U32,U32.is_eq(id,73),u => origin,u => 0)),
        nt_choose(KDef,U32.is_eq(id,72) || U32.is_eq(id,74) || U32.is_eq(id,75),
          u => p117h_write(p111v_arg(args,4),0,origin,missing()),u => missing()),
        nt_choose(U32,p117h_buffer(name),u => 0,u => mask),U32.or(used,p117h_bit(origin)),again,left,
        nt_choose(U32,U32.is_eq(id,0),u => next,u => U32.inc(next)),
        nt_choose(KDef,U32.is_eq(id,0),u => sites,u => p117h_put(sites,U32.show(next),origin))}


@unsafe
def p117h_diamond(diamond: P113BQDiamond, +scan: P117HScan) -> P117HScan:
  match diamond:
    case P113BQYes{name,invert}: p117h_set(name,0,scan)
    case P113BQNo{}: p117h_abort(scan)

# Exact immutable-origin intersection. Unknown/absent facts are not retained;
# equality of mutable variable names alone would not establish a shared origin.

@unsafe
def p117h_common_bucket(bucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      +name = dn(head)
      +origin = da(head)
      p117h_common_bucket(rest,right,nt_choose(KDef,
        agy_str_eq(dk(head),"P117HOrigin") && U32.is_gt(origin,0) && U32.is_eq(origin,p117h_get(right,name)),
        u => p117h_put(out,name,origin),u => out))


@unsafe
def p117h_common(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p117h_common_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p117h_common(b,right,p117h_common(a,right,out))
    case _: out

# Each branch starts with the same incoming facts. Site records/backedge
# obligations accumulate across both arms; continuing facts must agree exactly.
# Including a terminal arm in the intersection is conservative.

@unsafe
def w4c_env_copy(+env: KDef, +dest: String, +src: String) -> KDef:
  +d = p111v_get(env,src)
  +t = dk(d)
  nt_choose(KDef,agy_str_eq(t,"BM") || agy_str_eq(t,"INC") || agy_str_eq(t,"DEC") ||
      agy_str_eq(t,"NZ") || agy_str_eq(t,"PRM") ||
      agy_str_eq(t,"ISUM") || agy_str_eq(t,"MIN") ||
      String.starts_with(t,"LT_") || String.starts_with(t,"NLT_"),
    u => p111v_put(env,dest,t,da(d),dx(d)),
    u => w4c_env_kill(env,dest))

@unsafe
def w4c_env_put_param(mp: Maybe<&2,U32>, +env: KDef, +dest: String, +tag: String, +dxv: U32) -> KDef:
  match mp:
    case Some{pi}: p111v_put(env,dest,tag,pi,dxv)
    case None{}: w4c_env_kill(env,dest)

# ---- W5-R1 Pass 5a: Invariant-Bounded min(x, inv_k) + inv_base BCE ----
@unsafe
def w5_step_bin_locals(+op: String, +dest: String, +lsrc: String, +rsrc: String, +env: KDef) -> KDef:
  nt_choose(KDef,(agy_str_eq(op,"ult") || agy_str_eq(op,"ule")) &&
      Bool.not(String.is_empty(lsrc)) && Bool.not(String.is_empty(rsrc)),
    u =>
      +rd = p111v_get(env,rsrc)
      nt_choose(KDef,agy_str_eq(dk(rd),"PRM"),
        v => p111v_put(env,dest,"LT_" ++ lsrc,da(rd),0),
        v => w4c_env_kill(env,dest)),
    u => nt_choose(KDef,agy_str_eq(op,"add") &&
        Bool.not(String.is_empty(lsrc)) && Bool.not(String.is_empty(rsrc)),
      v =>
        +ld = p111v_get(env,lsrc)
        +rd = p111v_get(env,rsrc)
        nt_choose(KDef,agy_str_eq(dk(ld),"PRM") && agy_str_eq(dk(rd),"MIN"),
          w => p111v_put(env,dest,"ISUM",da(ld),da(rd)),
          w => nt_choose(KDef,agy_str_eq(dk(rd),"PRM") && agy_str_eq(dk(ld),"MIN"),
            x => p111v_put(env,dest,"ISUM",da(rd),da(ld)),
            x => w4c_env_kill(env,dest))),
      v => w4c_env_kill(env,dest)))

@unsafe
def w4c_step_bin_r(rc: Maybe<&2,U32>, +dest: String, +op: String, +lsrc: String, +lc: Maybe<&2,U32>, +rsrc: String, +env: KDef) -> KDef:
  match rc:
    case Some{+lo}:
      nt_choose(KDef,agy_str_eq(op,"and") && U32.is_eq(lo,4294967295) && Bool.not(String.is_empty(lsrc)),
        u => w4c_env_copy(env,dest,lsrc),
        u => nt_choose(KDef,agy_str_eq(op,"and") && U32.is_le(lo,2147483647),
          v => p111v_put(env,dest,"BM",lo,0),
          v => nt_choose(KDef,agy_str_eq(op,"add") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
            w => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"INC",1),
            w => nt_choose(KDef,agy_str_eq(op,"sub") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
              x => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"DEC",2),
              x => nt_choose(KDef,agy_str_eq(op,"ne") && U32.is_eq(lo,0) && Bool.not(String.is_empty(lsrc)),
                y => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"NZ",3),
                y => nt_choose(KDef,agy_str_eq(op,"xor") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
                  z =>
                    +ld = p111v_get(env,lsrc)
                    nt_choose(KDef,String.starts_with(dk(ld),"LT_"),
                      q => p111v_put(env,dest,"N" ++ dk(ld),da(ld),dx(ld)),
                      q => w4c_env_kill(env,dest)),
                  z => nt_choose(KDef,agy_str_eq(op,"urem") && U32.is_gt(lo,0) && U32.is_le(lo,2147483647),
                    q => p111v_put(env,dest,"BM",U32.sub(lo,1),0),
                    q => w4c_env_kill(env,dest))))))))
    case None{}:
      match lc:
        case Some{+lo}:
          nt_choose(KDef,agy_str_eq(op,"and") && U32.is_eq(lo,4294967295) && Bool.not(String.is_empty(rsrc)),
            u => w4c_env_copy(env,dest,rsrc),
            u => nt_choose(KDef,agy_str_eq(op,"and") && U32.is_le(lo,2147483647),
              v => p111v_put(env,dest,"BM",lo,0),
              v => nt_choose(KDef,agy_str_eq(op,"add") && U32.is_eq(lo,1) && Bool.not(String.is_empty(rsrc)),
                w => w4c_env_put_param(w4c_env_param_idx(env,rsrc),env,dest,"INC",1),
                w => w4c_env_kill(env,dest))))
        case None{}: w5_step_bin_locals(op,dest,lsrc,rsrc,env)

@unsafe
def w4c_step_set(val: N111Value, +dest: String, +env: KDef) -> KDef:
  match val:
    case N111Local{src}: w4c_env_copy(env,dest,src)
    case N111Const{+lo,0}:
      nt_choose(KDef,U32.is_le(lo,2147483647),
        u => p111v_put(env,dest,"BM",lo,0),
        u => w4c_env_kill(env,dest))
    case _: w4c_env_kill(env,dest)

@unsafe
def w5_step_store_val(val: N111Value, +buf: String, +env: KDef) -> KDef:
  match val:
    case N111Const{+lo,0}:
      nt_choose(KDef,U32.is_gt(lo,0) && U32.is_le(lo,2147483647),
        v => p111v_put(env,"__st8_" ++ buf,"C8",lo,0),
        v => w4c_env_kill(env,"__st8_" ++ buf))
    case N111Local{src}: w4c_env_copy(env,"__st8_" ++ buf,src)
    case _: w4c_env_kill(env,"__st8_" ++ buf)

@unsafe
def w5_step_rt_call(+dest: String, +sym: String, args: List<&2,N111Arg>, +env: KDef) -> KDef:
  match args:
    case Con{_,Con{N111Arg{_,N111Const{19,0}},Con{N111Arg{_,N111Local{buf}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}:
      nt_choose(KDef,agy_str_eq(sym,"p111_rt_op"),
        u =>
          +sd = p111v_get(env,"__st8_" ++ buf)
          nt_choose(KDef,agy_str_eq(dk(sd),"C8") && U32.is_gt(da(sd),0),
            v => p111v_put(env,dest,"BM",U32.sub(da(sd),1),0),
            v => w4c_env_kill(env,dest)),
        u => w4c_env_kill(env,dest))
    case _: w4c_env_kill(env,dest)

@unsafe
def w4c_kill_names(names: List<&2,String>, +env: KDef) -> KDef:
  match names:
    case Nil{}: env
    case Con{nm,rest}: w4c_kill_names(rest,w4c_env_kill(env,nm))

@unsafe
def w4c_bce_site_local(idxVal: N111Value, +n: U32, +origin: U32, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match idxVal:
    case N111Local{+inm}:
      +d = p111v_get(env,inm)
      +maskRef = p117h_ref(origin,"mask")
      +pfx = "w4c_bce_" ++ U32.show(n) ++ "_"
      # Case 2: bitmask-wrapped param j (PRM with pbmMap entry)
      nt_choose(W4CBCEPlan,agy_str_eq(dk(d),"PRM") && U32.is_eq(dx(p111v_get(pbmMap,U32.show(da(d)))),1),
        u =>
          +bound = da(p111v_get(pbmMap,U32.show(da(d))))
          +pname = w4c_nth_param_name(params,da(d))
          W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
            nt_append(N111Stmt,guards,
              nt_append(N111Stmt,w4c_guard_ule(pfx ++ "pbm",N111Const{bound,0},maskRef),
                w4c_guard_ule(pfx ++ "pinit",N111Local{pname},maskRef))),U32.inc(n)},
        # Case 3: unit-stride IV param j (PRM in ivMask) OR j+1 (INC in ivMask under countdown guard)
        u =>
          +isIv = Bool.not(String.is_empty(cntName)) &&
            ((agy_str_eq(dk(d),"PRM") && w4c_has_bit(ivMask,da(d))) ||
             (guarded && agy_str_eq(dk(d),"INC") && w4c_has_bit(ivMask,da(d))))
          +isTightPrm = guarded && agy_str_eq(dk(d),"PRM")
          nt_choose(W4CBCEPlan,isIv,
            v =>
              +pname = w4c_nth_param_name(params,da(d))
              +sumName = pfx ++ "sum"
              +gStmts = nt_choose(List<&2,N111Stmt>,isTightPrm,
                t =>
                  +nzName = pfx ++ "nz"
                  +cmName = pfx ++ "cm"
                  +prep: List<&2,N111Stmt> = [
                    N111Bin{nzName,N111U64{},"ne",N111Local{cntName},N111Const{0,0}},
                    N111Bin{cmName,N111U64{},"sub",N111Local{cntName},N111Local{nzName}}]
                  nt_append(N111Stmt,prep,
                    nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                      nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cmName},maskRef),
                        Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cmName}},
                          w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)}))),
                t =>
                  nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                    nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cntName},maskRef),
                      Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cntName}},
                        w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)})))
              W4CBCEPlan{p117h_put(nomask,U32.show(n),1),nt_append(N111Stmt,guards,gStmts),U32.inc(n)},
            v =>
              +invMask = da(p111v_get(pbmMap,"__inv__"))
              nt_choose(W4CBCEPlan,
                agy_str_eq(dk(d),"ISUM") && w4c_has_bit(invMask,da(d)) && w4c_has_bit(invMask,dx(d)),
                w =>
                  +bname = w4c_nth_param_name(params,da(d))
                  +kname = w4c_nth_param_name(params,dx(d))
                  +sumNm = pfx ++ "isum"
                  +gB = w4c_guard_ule(pfx ++ "ib",N111Local{bname},maskRef)
                  +gK = w4c_guard_ule(pfx ++ "ik",N111Local{kname},maskRef)
                  +gAdd: List<&2,N111Stmt> = [N111Bin{sumNm,N111U32{},"add",N111Local{bname},N111Local{kname}}]
                  +gSum = w4c_guard_ule(pfx ++ "is",N111Local{sumNm},maskRef)
                  W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
                    nt_append(N111Stmt,guards,nt_append(N111Stmt,gB,nt_append(N111Stmt,gK,nt_append(N111Stmt,gAdd,gSum)))),U32.inc(n)},
                w => nt_choose(W4CBCEPlan,agy_str_eq(dk(d),"BM"),
                  z => W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
                    nt_append(N111Stmt,guards,w4c_guard_ule(pfx ++ "bm",N111Const{da(d),0},maskRef)),U32.inc(n)},
                  z => W4CBCEPlan{nomask,guards,U32.inc(n)}))))
    case _: W4CBCEPlan{nomask,guards,U32.inc(n)}

@unsafe
def w4c_bce_site_bm(mb: Maybe<&2,U32>, +n: U32, +origin: U32, +idxVal: N111Value, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match mb:
    case Some{+bound}:
      +maskRef = p117h_ref(origin,"mask")
      +pfx = "w4c_bce_" ++ U32.show(n) ++ "_"
      W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
        nt_append(N111Stmt,guards,w4c_guard_ule(pfx ++ "bm",N111Const{bound,0},maskRef)),U32.inc(n)}
    case None{}: w4c_bce_site_local(idxVal,n,origin,guarded,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def p118b_eval_call(+t: KTerm, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,+values,next,error}:
      +value = nt_choose(P111ValueCode,agy_str_eq(tg(t),"NOp"),
        u => p111_intrinsic(nm(t),values),u => p111_constructor(nm(t),values))
      p113d_join(P113DCode{body,next,error,[]},
        p113d_emitted(P113DLocal{p118b_value_name(n)},next,value))


@unsafe
def p118b_project_functions(functions: List<&2,P113DFunction>, ids: N111Ids) -> P118BWorkers:
  p118ns_project_functions(functions,ids,[],"")


@unsafe
def p118c_ctors(ctors: List<&2,N_Constructor>, cold: List<&2,String>) -> List<&2,N_Constructor>:
  p118ns_ctors(ctors,cold,[])


@unsafe
def p118ns_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:
  match cold:
    case Nil{}: ctors
    case _: w7_p118ns_ctors_set(ctors,w7_str_set(cold,missing()),reversed)


@unsafe
def p118ns_effect_definition(+d: KDef) -> Bool:
  nt_choose(Bool,nc_native_def(d),u => True{},u => nt_choose(Bool,nc_foreign(d),
    v => no_effect_foreign_allowed(db(d),agy_str_eq(tg(nc_unann(dv(d))),"Foreign"),dn(d)),
    v => agy_str_eq(dk(d),"Def") && no_effect_terms([dv(d)])))


@unsafe
def p198e_op(+book: List<&2,KDef>, +arm: KTerm, +name: String) -> String:
  +first = j_fusion_binder(arm,0)
  +second = j_fusion_binder(arm,1)
  +call = j_call_spine(j_fusion_after(arm,2),[])
  +l = j_call_spine(kid(call,0),[])
  +r = j_call_spine(kid(call,1),[])
  nt_choose(String,p98_tag_eq(first,"Lam") && j_fusion_var(j_fusion_after(arm,1),ix(first)),
    u => "leaf",u => nt_choose(String,p98_tag_eq(first,"Lam") && p98_tag_eq(second,"Lam") &&
      (agy_str_eq(nm(call),"U32.add") || agy_str_eq(nm(call),"U32.sub") || agy_str_eq(nm(call),"U32.mul")) &&
      j_primitive_call(book,call) && j_fusion_call(l,name,1) && j_fusion_var(kid(l,0),ix(first)) &&
      j_fusion_call(r,name,1) && j_fusion_var(kid(r,0),ix(second)), v => nm(call),v => ""))

@unsafe
def p123p_old_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  +answer = p113k_bin_fact(typ,op,lf,rf)
  P113KScalar{[p113k_bin_stmt(name,typ,op,p113k_replace(left,facts),p113k_replace(right,facts),lf,rf,answer)],p113k_put(facts,name,answer)}


@unsafe
def p123p_put(+facts: KDef, +name: String, +root: String, invert: U32) -> KDef:
  +key = "@p123predicate:" ++ name
  index_set(facts,KDef{key,"P123Predicate",invert,0,
    kt("Epoch","",p113l_version(facts,root),p113l_version(facts,name),[]),
    kt("Root",root,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)


@unsafe
def p123p_copy(+before: KDef, +after: KDef, +name: String, value: N111Value) -> KDef:
  match value:
    case N111Local{source}:
      +record = p123p_get(before,source)
      nt_choose(KDef,agy_str_eq(dk(record),"P123Predicate"),u =>
        nt_choose(KDef,U32.is_eq(ix(dt(record)),p113l_version(after,nm(dv(record)))),
          v => p123p_put(after,name,nm(dv(record)),da(record)),v => after),u => after)
    case _: after

# A recognized diamond writes only its destination. The join may reset epochs,
# but cannot alter the separately named root value; capture the new epoch.

@unsafe
def p123p_diamond(+before: KDef, +after: KDef, condition: N111Value, diamond: P113BQDiamond) -> KDef:
  match condition diamond:
    case N111Local{source} P113BQYes{+name,invert}:
      +record = p123p_get(before,source)
      nt_choose(KDef,agy_str_eq(dk(record),"P123Predicate") && Bool.not(agy_str_eq(name,nm(dv(record)))),
        u => p123p_put(after,name,nm(dv(record)),U32.xor(da(record),Bool.to_u32(invert))),u => after)
    case _ _: after


@unsafe
def p123p_record(stmt: N111Stmt, +before: KDef, +after: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p123p_copy(before,after,name,value)
    case N111Bin{+name,typ,op,left,right}:
      nt_choose(KDef,p111v_comparison(op),u => p123p_put(after,name,name,0),u => after)
    case N111If{condition,yes,no}: p123p_diamond(before,after,condition,p113bq_scalar(yes,no))
    case _: after


@unsafe
def p123p_pick(+op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  w5c2_p123p_pick_eq(String.eq(op, "eq") || String.eq(op, "ne"), op, left, right, facts)

@unsafe
def w5c2_p123p_bin_if(hit: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  match hit:
    case True{}:
      P113KScalar{[w5c2_p123p_bin_stmt(U32.is_eq(da(record), 0), name, nm(dv(record)))],
        p113k_put(facts, name, p113k_bin_fact(typ, op, lf, rf))}
    case False{}: p123p_old_bin(name, typ, op, left, right, facts, lf, rf)

@unsafe
def p124r_known(+ready: KDef, +name: String) -> Bool:
  nt_choose(Bool,p124r_is_view(ready),u => p124r_valid(p124r_lookup(ready,name)),u => p112w_ready(ready,name))

# Original tail remains the independent arity/transport check. Every argument is
# loaded before the call, so neither helper scratch nor captures can clobber it.

@unsafe
def p124r_terminal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef,
    +target: String, callable: P124Callable) -> P114GBody:
  match callable:
    case P124Callable{valid,+count,+symbol}:
      nt_choose(P114GBody,valid && Bool.not(agy_str_eq(owner,target)) && p112t_tail(body,target,count,0),
        u => P114GBody{True{},[],p114h_scalars(p124r_call_nodes(body,count,symbol),[P114RResult{N111Local{"p114h_call_result"}}])},
        u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))

# Discovery does not prove admission: p114r_arguments checks the complete exact
# argument stores and terminal jump independently before a node is constructed.

@unsafe
def p124r_resume_target(body: List<&2,N111Stmt>, tail: List<&2,N111Stmt>, owner: String,
    name: String, captures: U32, ready: KDef, +target: String) -> P114GBody:
  p124r_resume_found(body,tail,owner,name,captures,target,p124r_lookup(ready,target))


@unsafe
def p124r_resume(+body: List<&2,N111Stmt>, +tail: List<&2,N111Stmt>, +owner: String,
    +name: String, +captures: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready) && U32.is_le(captures,8),
    u => p124r_resume_target(body,tail,owner,name,captures,ready,p124r_target(tail)),
    u => P114GBody{False{},[],[]})



@unsafe
def p124r_original_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P114GBody,p112w_ready(ready,target) && Bool.not(agy_str_eq(owner,target)) && U32.is_le(count,8) && p112t_tail(body,target,count,0),
    u => p114h_call(body,target,count),u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))


law p126s_eval:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_eval(book,term,kind,fuel):
  nt_choose(KTerm,U32.is_gt(fuel,0),u =>
    p126s_eval_next(book,j_strip(term),kind,U32.sub(fuel,1),p126s_atom(j_strip(term),kind)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_primitive_first(+book: List<&2,KDef>, +call: KTerm, +fuel: U32, +first: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(first),u =>
    nt_choose(KTerm,agy_str_eq(nm(call),"U32.to_f32"),u => p126s_result(nm(call),kl_number(first),0),u =>
      p126s_primitive_second(nm(call),first,p126s_eval(book,kid(call,1),"F32",fuel))),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


law p126s_helper_arg:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +ty: KTerm
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_helper_arg(book,body,ty,arg,rest,kind,fuel):
  +input = p126s_kind(book,kid(ty,0))
  nt_choose(KTerm,agy_str_eq(tg(body),"Lam") && U32.is_eq(terms_len(ks(body)),1) && agy_str_eq(j_l_name(body),"") &&
    agy_str_eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) && Bool.not(String.is_empty(input)),u =>
      p126s_helper_value(book,body,ty,rest,kind,fuel,p126s_eval(book,arg,input,fuel)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_helper(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +kind: String, +fuel: U32) -> KTerm:
  match args:
    case Nil{}:
      nt_choose(KTerm,agy_str_eq(p126s_kind(book,ty),kind),u => p126s_eval(book,body,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{arg,rest}: p126s_helper_arg(book,j_strip(body),wnf(book,ty),arg,rest,kind,fuel)


@unsafe
def p126s_helper_value(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +rest: List<&2,KTerm>, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u =>
    p126s_helper(book,subst(kid(body,0),ix(body),value),subst(kid(ty,1),ix(ty),value),rest,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_call(+book: List<&2,KDef>, +call: KTerm, +kind: String, +fuel: U32) -> KTerm:
  +name = nm(call)
  +d = lookup(book,name)
  nt_choose(KTerm,agy_str_eq(kind,"F32") && String.contains("|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|","|" ++ name ++ "|") && j_primitive_call(book,call),
    u => p126s_primitive_first(book,call,fuel,p126s_eval(book,kid(call,0),j_primitive_input(name,0),fuel)),u =>
    nt_choose(KTerm,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || nc_foreign(d)) && U32.is_eq(dx(d),0) &&
      U32.is_gt(da(d),0) && U32.is_le(da(d),2) && U32.is_eq(da(d),terms_len(ks(call))) && j_u32_bounded([dv(d)],64),
      u => p126s_helper(book,dv(d),dt(d),ks(call),kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p126s_eval_spine(+book: List<&2,KDef>, +kind: String, +fuel: U32, +spine: KTerm) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(spine),"Call"),u => p126s_call(book,spine,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_eval_next(+book: List<&2,KDef>, +term: KTerm, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u => value,u => p126s_eval_spine(book,kind,fuel,j_call_spine(term,[])))


@unsafe
def p126sc_worker(+left: P113DFunction, +right: P113DFunction, +name: String) -> P113DCandidate:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +lb = p126sc_body(left)
  +rb = p126sc_body(right)
  +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
  +params : List<&2,NC_Binding> = Con{NC_Binding{4294967295,"p126scc_tag",N_W64{}},p126sc_lane_params(width,0)}
  +yes = nt_append(P113DStmt,p126sc_bind(p126sc_params(left),"p113i_14_",0),p126sc_rewrite(lb,"p113i_14_",ln,rn,0,width))
  +no = nt_append(P113DStmt,p126sc_bind(p126sc_params(right),"p113i_15_",0),p126sc_rewrite(rb,"p113i_15_",ln,rn,1,width))
  +body : List<&2,P113DStmt> = nt_append(P113DStmt,p113j_scratch_alloc(lb,"p113i_14_"),nt_append(P113DStmt,p113j_scratch_alloc(rb,"p113i_15_"),[
    P113DScalar{N111Bin{"p126scc_side",N111U64{},"eq",N111Local{"p126scc_tag"},N111Const{0,0}}},P113DIf{N111Local{"p126scc_side"},yes,no}]))
  P113DCandidate{P113DFunction{name,params,1,False{},body},"",p126sc_external(nt_append(String,p113j_calls(lb),p113j_calls(rb)),ln,rn)}


@unsafe
def p126sc_counts(candidates: List<&2,P113DCandidate>, +counts: KDef, +slot: U32) -> KDef:
  match candidates:
    case Nil{}: counts
    case Con{P113DCandidate{function,error,calls},rest}:
      +name = p126sc_name(function)
      p126sc_counts(rest,index_set(counts,KDef{name,"P126Count",U32.inc(da(p111v_get(counts,name))),slot,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},kt("Calls","",0,0,p126sc_call_terms(calls)),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(slot))


law p126sc_walk:
  for +candidates: List<&2,P113DCandidate>
  for +index: P113ITable
  for +counts: KDef
  for +done: KDef
  for +slot: U32
  for +acc: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

@unsafe
def p126sc_walk(candidates,index,counts,done,slot,acc):
  match candidates:
    case Nil{}: nt_reverse(P113DCandidate,acc,[])
    case Con{candidate,rest}: p126sc_one(candidate,rest,index,counts,done,slot,acc)


@unsafe
def p126sc_found(+candidate: P113DCandidate, +left: P113DFunction, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>, found: Maybe<&2,P113DFunction>) -> List<&2,P113DCandidate>:
  match found:
    case None{}: p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})
    case Some{+right}:
      +worker = "$p126scc." ++ U32.show(slot)
      +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
      nt_choose(List<&2,P113DCandidate>,agy_str_eq(dk(p111v_get(counts,worker)),"Absent"),
        u => p126sc_walk(rest,index,counts,p111v_put(p111v_put(done,p126sc_name(left),"P126Used",0,0),p126sc_name(right),"P126Used",0,0),U32.inc(slot),
          Con{p126sc_wrapper(right,worker,1,width),Con{p126sc_wrapper(left,worker,0,width),Con{p126sc_worker(left,right,worker),acc}}}),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc}))


@unsafe
def p126sc_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidate:
    case P113DCandidate{+function,+error,+calls}:
      +name = p126sc_name(function)
      nt_choose(List<&2,P113DCandidate>,agy_str_eq(dk(p111v_get(done,name)),"Absent"),
        u => nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
          v => p126sc_found(candidate,function,rest,index,counts,done,slot,acc,p126sc_partner(calls,function,index,counts,slot,done)),
          v => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),acc))


@unsafe
def p126sc_candidates_counted(+candidates: List<&2,P113DCandidate>, +counts: KDef) -> List<&2,P113DCandidate>:
  p126sc_walk(candidates,p126sc_index(candidates,counts,P113IEmpty{}),counts,missing(),0,[])


@unsafe
def p128rf_members(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}:
      p128rf_members(rest,index_set(tree,
        KDef{name,"P128ReachMember",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
        index_hash(name,2166136261),32))


@unsafe
def p128bi_index(+index: KDef, +rule: KDef) -> KDef:
  +target = nm(dt(rule))
  +old = index_find(index,target,index_hash(target,2166136261),32)
  nt_choose(KDef,agy_str_eq(dk(rule),"P128BIRule"),
    u => p113e_insert(index,KDef{target,"P128BIRules",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},Con{rule,dc(old)},False{},False{}}),
    u => index)


@unsafe
def p128bi_walk(functions: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          p128bi_step(head,rest,patches,index,reversed,p128br_replacement(name,patches))


@unsafe
def p128bi_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>, replacement: Maybe<&2,List<&2,P113DFunction>>) -> List<&2,P113DFunction>:
  match replacement:
    case None{}: p128bi_walk(rest,patches,index,Con{p128bi_function(original,index),reversed})
    case Some{functions}: p128bi_walk(rest,patches,p128bi_index(index,p128bi_rule(original)),nt_reverse(P113DFunction,functions,reversed))

@unsafe
def p134e_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +ids: N111Ids, +index: P112FusionIndex,
    +heap: U32, +mode: U32, +tables: List<&2,P111QData>, registry: P112RegionRegistry) -> P134Cursor:
  match registry:
    case P112RegionRegistry{+ready,symbols,+entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      +lookups = nt_choose(List<&2,P126ITable>,U32.is_eq(mode,2),u => p126i_catalogue(functions,[]),u => [])
      +ids = p185cb_bind(ids,tables)
      +context : P134Context = P134Context{ids,index,direct,ready,p124r_view(ready,direct),lookups,heap,mode}
      +public : P134Cursor = P134Public{segments,context,P134Tables{tables}}
      +legacy = nt_choose(P134Cursor,List.is_empty(&2,N111Segment,segments),u => public,
        u => P134Legacy{nt_reverse(P112RegionEntry,entries,[]),context,public})
      P134Private{functions,context,legacy}

@unsafe
def p142j_mark(seen: KDef, name: String, hash: U32) -> KDef:
  index_set(seen,KDef{name,"P142JSeen",0,0,
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},[],False{},False{}},hash,32)

# Test/bridge helper: the production checked entry starts from missing().

@unsafe
def p142j_members(names: List<&2,String>, seen: KDef) -> KDef:
  match names:
    case Nil{}: seen
    case Con{+name,rest}: p142j_members(rest,p142j_mark(seen,name,index_hash(name,2166136261)))

law p142r_visit_c:
  for +book: List<&2,KDef>
  for +cidx: KDef
  for todo: List<&2,String>
  for +seen: List<&2,String>
  for +members: KDef
  for +stops: KDef
  List<&2,String>

@unsafe
def p142r_kr_visit(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>) -> List<&2,String>:
  p142r_visit_c(book,agy_ctor_parent_index(book,missing()),todo,seen,p142j_members(seen,missing()),p142j_members(stops,missing()))


@unsafe
def p142r_resolved_c(book: List<&2,KDef>, cidx: KDef, +todo: List<&2,String>, seen: List<&2,String>, members: KDef, +stops: KDef, +d: KDef, +name: String) -> List<&2,String>:
  +h = index_hash(name,2166136261)
  +deps = agy_dr_refs(dt(d),agy_dr_ctor_refs(dc(d),kc(List<&2,String>,p142j_member(stops,name,h),u => todo,u => agy_dr_refs(dv(d),todo))))
  p142r_visit_c(book,cidx,deps,Con{name,seen},p142j_mark(members,name,h),stops)


@unsafe
def p142r_def_c(+book: List<&2,KDef>, +cidx: KDef, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: KDef, +d: KDef) -> List<&2,String>:
  kc(List<&2,String>,p88_string_eq(dk(d),"Absent"),
    u => p142r_visit_c(book,cidx,todo,seen,members,stops),
    u => p142r_resolved_c(book,cidx,todo,seen,members,stops,d,dn(d)))


@unsafe
def p142r_name_c(+book: List<&2,KDef>, +cidx: KDef, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: KDef, +name: String, +hash: U32) -> List<&2,String>:
  kc(List<&2,String>,p142j_member(members,name,hash),
    u => p142r_visit_c(book,cidx,todo,seen,members,stops),
    u => p142r_def_c(book,cidx,todo,Con{name,seen},p142j_mark(members,name,hash),stops,agy_kr_resolve_cidx(book,cidx,name,hash)))


@unsafe
def p142r_visit_c(book, cidx, todo, seen, members, stops):
  match todo:
    case Nil{}: seen
    case Con{+name,rest}:
      p142r_name_c(book,cidx,rest,seen,members,stops,name,index_hash(name,2166136261))

@unsafe
def p143cs_build(todo: List<&2,KDef>) -> P143CSchedule:
  match todo:
    case Nil{}: P143CSchedule{missing(),[]}
    case Con{head,rest}: p143cs_step(head,p143cs_build(rest))


@unsafe
def p143cs_step(+head: KDef, tail: P143CSchedule) -> P143CSchedule:
  match tail:
    case P143CSchedule{+index,events}:
      +next = index_find(index,dn(head),index_hash(dn(head),2166136261),32)
      P143CSchedule{
        nt_choose(KDef,p88_string_eq(dk(head),"BookCache"),
          u => index_first(dc(head)),
          u => index_set(index,head,index_hash(dn(head),2166136261),32)),
        Con{P143CEvent{head,next},events}}


@unsafe
def p143cs_plan(todo: List<&2,KDef>) -> List<&2,P143CEvent>:
  p143cs_events(p143cs_build(todo))


@unsafe
def p143cp_canon(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(head),"BookCache"),
        u => Con{head,book_final_fast(List.reverse(&2,KDef,rest),[])},
        u => book_final_fast(List.reverse(&2,KDef,Con{head,rest}),[]))


@unsafe
def p143cp_logged(+cache: KDef, rest: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
    Con{index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32), Con{w7_book_put_ctors(cache, definition), Nil{}}},
    True{},False{}},Con{definition,rest}}


@unsafe
def w7c_ctor_add_if_adt(isAdt: Bool, +d: KDef, +ctors: KDef) -> KDef:
  match isAdt:
    case True{}: w7_ctor_index_add(dc(d), ctors)
    case False{}: ctors

@unsafe
def w7c_declare_loop(+todo: List<&2,KDef>, +names: KDef, +ctors: KDef) -> List<&2,KDef>:
  match todo:
    case Nil{}: Con{names, Con{ctors, Nil{}}}
    case Con{d, rest}:
      +d2 = w7c_decl_def(p98_tag_eq(dv(d), "Foreign"), d)
      w7c_declare_loop(rest, index_set(names, d2, index_hash(dn(d2), 2166136261), 32), w7c_ctor_add_if_adt(p88_string_eq(dk(d2), "ADT"), d2, ctors))

@unsafe
def w7c_init_ctors(+dc_list: List<&2,KDef>, +rows: List<&2,KDef>) -> KDef:
  match dc_list:
    case Nil{}: w7_ctor_index_build(rows)
    case Con{_, tail}:
      match tail:
        case Nil{}: w7_ctor_index_build(rows)
        case Con{ctors, _}: ctors

@unsafe
def p144p_ready_scope(+scope: FParseScope) -> FParseScope:
  match scope:
    case FParseScope{+prior,index,ctors,ns,aliases,view}:
      match view:
        case None{}: FParseScope{prior,index,ctors,ns,aliases,Some{index_build(prior)}}
        case Some{ready}: scope


@unsafe
def p144p_update(+definition: KDef, view: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match view:
    case None{}: None{}
    case Some{index}: Some{index_set(index,definition,index_hash(dn(definition),2166136261),32)}


@unsafe
def p144p_declared(+d: KDef, +prior: List<&2,KDef>, +index: KDef,
    +ctorIndex: KDef, +ns: String, +aliases: List<&2,KTerm>, view: Maybe<&2,KDef>) -> FParseScope:
  FParseScope{Con{d,prior},index_set(index,d,index_hash(dn(d),2166136261),32),
    f_ctor_index_def(d,ctorIndex),ns,aliases,p144p_update(d,view)}

@unsafe
def p144o_build(book: List<&2,KDef>) -> P144OFacts:
  p144o_rows(book,missing(),[])


@unsafe
def p144o_rows(book: List<&2,KDef>, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match book:
    case Nil{}: P144OFacts{nt_reverse(String,positive,[]),True{}}
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p137q_is_adt(head),
        u => p144o_children(rest,dc(head),db(head),missing(),claimed,positive),
        u => p144o_rows(rest,claimed,positive))


@unsafe
def p144o_children(+rows: List<&2,KDef>, children: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match children:
    case Nil{}: p144o_rows(rows,claimed,positive)
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p88_string_eq(dk(head),"BookCache") || Bool.not(book_final_name_valid(dn(head))),
        u => P144OFacts{[],False{}},
        u => p144o_child(rows,rest,owned,seen,claimed,positive,head,index_hash(dn(head),2166136261)))


@unsafe
def p144o_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>, +head: KDef, +hash: U32) -> P144OFacts:
  +name = dn(head)
  nt_choose(P144OFacts,p142j_member(seen,name,hash),
    u => p144o_children(rows,rest,owned,seen,claimed,positive),
    u => nt_choose(P144OFacts,p137q_is_ctr(head) && Bool.not(p142j_member(claimed,name,hash)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),p142j_mark(claimed,name,hash),
        nt_choose(List<&2,String>,owned,w => Con{name,positive},w => positive)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),claimed,positive)))


@unsafe
def p144o_constructors(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match facts:
    case P144OFacts{+names,valid}:
      match valid:
        case True{}: w7c_p144o_constructors_set(book,definitions,p142j_members(names,missing()))
        case False{}: p144o_constructors_fallback(book,definitions,facts)

@unsafe
def p144o_ctor_carrier(+context: KDef, facts: P144OFacts) -> KDef:
  match context facts:
    case KDef{+name,+kind,+arity,+templates,+typ,+value,+children,+native,+uns} P144OFacts{+names,valid}:
      nt_choose(KDef,valid && p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns) && p98_tag_eq(typ,"Absent"),
        u => KDef{name,kind,arity,templates,KTerm{"P144Ownership","",0,1,[],names,0,0},value,
          Con{index_first(children),Con{p142j_members(names,missing()),Nil{}}},native,uns},
        u => context)
    case _ _: context


@unsafe
def p144ce_build(book: List<&2,KDef>) -> P144CEFacts:
  p144ce_rows(book,missing())


@unsafe
def p144ce_rows(book: List<&2,KDef>, +members: KDef) -> P144CEFacts:
  match book:
    case Nil{}: P144CEFacts{members,True{}}
    case Con{+parent,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dk(parent)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(parent),"BookCache"),
          v => p144ce_rows(rest,members),
          v => p144ce_children(rest,dc(parent),missing(),members)),
        u => P144CEFacts{missing(),False{}})


@unsafe
def p144ce_children(+rows: List<&2,KDef>, children: List<&2,KDef>,
    +seen: KDef, +members: KDef) -> P144CEFacts:
  match children:
    case Nil{}: p144ce_rows(rows,members)
    case Con{+head,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dn(head)) && book_final_name_valid(dk(head)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(head),"BookCache"),
          v => P144CEFacts{missing(),False{}},
          v => p144ce_child(rows,rest,seen,members,head,index_hash(dn(head),2166136261))),
        u => P144CEFacts{missing(),False{}})


@unsafe
def p144ce_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +seen: KDef,
    +members: KDef, +head: KDef, +hash: U32) -> P144CEFacts:
  +name = dn(head)
  nt_choose(P144CEFacts,p142j_member(seen,name,hash),
    u => p144ce_children(rows,rest,seen,members),
    u => p144ce_children(rows,rest,p142j_mark(seen,name,hash),
      nt_choose(KDef,p88_string_eq(dk(head),"Absent"),
        v => members,v => p142j_mark(members,name,hash))))


@unsafe
def p144ce_disjoint_go(defs: List<&2,KDef>, +context: List<&2,KDef>, +facts: P144CEFacts) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{+definition,rest}:
      nt_choose(Bool,Bool.not(p144ce_query(context,facts,dn(definition))) &&
        p144ce_disjoint_go(dc(definition),context,facts),
        u => p144ce_disjoint_go(rest,context,facts),u => False{})



@unsafe
def p164a_put(+index: KDef, source: String, +owner: String, arity: U32) -> KDef:
  p113e_insert(index,KDef{owner,"P164Adapter",arity,0,ref(source),atom("Absent"),[],False{},False{}})



@unsafe
def p167l_mark(+index: KDef, name: String) -> KDef:
  p113e_insert(index,KDef{name,"P167Seen",0,0,atom("Absent"),atom("Absent"),[],False{},False{}})



@unsafe
def p167l_demand(+name: String, demand: P167Demand) -> P167Demand:
  match demand:
    case P167Demand{+todo,+asked,+count}:
      +h = index_hash(name,2166136261)
      w7c_p167l_demand_if(agy_str_eq(dk(w5c3_find(asked,name,h)),"Absent"),name,h,todo,asked,count)



@unsafe
def p167l_value(value: N111Value, demand: P167Demand) -> P167Demand:
  match value:
    case N111FuncId{name}: p167l_demand(name,demand)
    case _: demand



@unsafe
def p167l_values(values: List<&2,N111Value>, demand: P167Demand) -> P167Demand:
  match values:
    case Nil{}: demand
    case Con{head,rest}: p167l_values(rest,p167l_value(head,demand))



@unsafe
def p167l_args(args: List<&2,N111Arg>, demand: P167Demand) -> P167Demand:
  match args:
    case Nil{}: demand
    case Con{N111Arg{typ,value},rest}: p167l_args(rest,p167l_value(value,demand))



@unsafe
def p167l_present(segments: List<&2,N111Segment>, present: KDef) -> KDef:
  match segments:
    case Nil{}: present
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p167l_present(rest,p167l_mark(present,name))



@unsafe
def w7c_p167l_cat_err(hasErr: Bool, +name: String, +source: String, +kind: String, +arity: U32, +allowed: Bool, +index: KDef, +error: String) -> P167Catalogue:
  match hasErr:
    case True{}: P167Catalogue{index,error}
    case False{}:
      +h = index_hash(name,2166136261)
      +old = w5c3_find(index,name,h)
      w7c_p167l_cat_old(agy_str_eq(dk(old),"Absent"),old,name,h,source,kind,arity,allowed,index)

@unsafe
def p167l_catalogue_put(+name: String, +source: String, +kind: String, +arity: U32,
    +allowed: Bool, catalogue: P167Catalogue) -> P167Catalogue:
  match catalogue:
    case P167Catalogue{+index,+error}:
      w7c_p167l_cat_err(Bool.not(String.is_empty(error)),name,source,kind,arity,allowed,index,error)



@unsafe
def w6_map_put(+index: KDef, +key: String, +val: String) -> KDef:
  p113e_insert(index,KDef{key,"W6",0,0,ref(val),atom("Absent"),[],False{},False{}})

law w6_dedup_scan:
  for segs: List<&2,N111Segment>
  for acc: W6DedupAcc
  W6DedupAcc

@unsafe
def w7c_w6_dedup_hit(absent: Bool, +rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  match absent:
    case True{}:
      w6_dedup_scan(rest,W6DedupAcc{p131i_insert(seen,KDef{key,"W6",0,0,ref(name),atom("Absent"),[],False{},False{}},kh),alias,Con{seg,kept},merged})
    case False{}:
      w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)})

@unsafe
def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  w7c_w6_dedup_hit(agy_str_eq(dk(found),"Absent"),rest,seg,name,key,kh,found,seen,alias,kept,merged)

@unsafe
def w7c_w6_dedup_nonempty(empty: Bool, +rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  match empty:
    case True{}: w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged})
    case False{}:
      +kh = index_hash(key,2166136261)
      w6_dedup_lookup(rest,seg,name,key,kh,w5c3_find(seen,key,kh),seen,alias,kept,merged)

@unsafe
def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  w7c_w6_dedup_nonempty(String.is_empty(key),rest,seg,name,key,seen,alias,kept,merged)

@unsafe
def w6_dedup_step(+seg: N111Segment, +rest: List<&2,N111Segment>, acc: W6DedupAcc) -> W6DedupAcc:
  match seg acc:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} W6DedupAcc{+seen,+alias,+kept,+merged}:
      nt_choose(W6DedupAcc,String.starts_with(name,"$p111.k."),
        u => w6_dedup_check(rest,seg,name,w6_canon_seg(arity,result,incoming,flags,body),seen,alias,kept,merged),
        u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}))

@unsafe
def w6_dedup_scan(segs, acc):
  match segs:
    case Nil{}: acc
    case Con{seg,rest}: w6_dedup_step(seg,rest,acc)

@unsafe
def w4p_adapt_functions(+fns: List<&2,P113DFunction>, +ready: KDef, +workers: List<&2,P113DFunction>,
    +signatures: List<&2,KDef>) -> List<&2,P113DFunction>:
  +prodIdx = w4p_prod_index(fns,missing())
  +cands = w4p_to_candidates(fns,ready,signatures,prodIdx)
  +fns2 = p113d_passes(cands,ready,nt_reverse(P113DFunction,workers,[]),32)
  nt_choose(List<&2,P113DFunction>,U32.is_eq(nt_count(P113DFunction,fns2),nt_count(P113DFunction,fns)),
    u => fns2,u => fns)

law w7_pre_peel:
  for +nodes: List<&2,W7PreNode>
  for +ready: KDef
  for +admitted: List<&2,String>
  for +fuel: U32
  List<&2,String>

@unsafe
def w7_pre_peel_next(+fuel: U32, pass: W7PrePass) -> List<&2,String>:
  match pass:
    case W7PrePass{+ready,+admitted,+waiting,count}:
      nt_choose(List<&2,String>,U32.is_eq(count,0),
        u => nt_reverse(String,admitted,[]),
        u => w7_pre_peel(waiting,ready,admitted,U32.sub(fuel,1)))

@unsafe
def w7_pre_peel(nodes, ready, admitted, fuel):
  nt_choose(List<&2,String>,U32.is_eq(fuel,0),
    u => nt_reverse(String,admitted,[]),
    u => w7_pre_peel_next(fuel,w7_pre_pass(nodes,ready,admitted,[],0)))

@unsafe
def p168j_imports(segments: List<&2,N111Segment>, +direct: KDef, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: registry
    case Con{+head,rest}:
      p168j_imports(rest,direct,nt_choose(P112RegionRegistry,p168j_eligible(head,direct),
        u => p168j_insert(head,registry),u => registry))



@unsafe
def w7c_p112c_try_admit(admitted: Bool, +cand: P112MultiCandidate, +transformed: N111Segment, +rank: U32, +sites: U32,
    +next: P112RegionRegistry, +plan: P112WorkerPlan, +waiting: List<&2,P112MultiCandidate>, +added: U32) -> W7C112CPass:
  match admitted:
    case True{}: W7C112CPass{p112c_insert(transformed,rank,sites,next,plan),waiting,U32.inc(added)}
    case False{}: W7C112CPass{next,Con{cand,waiting},added}

@unsafe
def w7c_p112c_fused(+cand: P112MultiCandidate, segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32,
    +next: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32, fused: P112FusionBody) -> W7C112CPass:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed : N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      +plan = p112c_plan(transformed,old,symbols,count)
      w7c_p112c_try_admit(p112w_admitted(plan),cand,transformed,rank,count,next,plan,waiting,added)

law p171s_seed:
  for +seen: List<&2,KDef>
  List<&2,KDef>

@unsafe
def w7c_p171s_seed_step(isCache: Bool, +cache: KDef, +tail: List<&2,KDef>, +seen: List<&2,KDef>) -> List<&2,KDef>:
  match isCache:
    case True{}:
      +ctor_rows = p171s_constructor_rows(tail)
      Con{KDef{dn(cache),dk(cache),da(cache),0,
        {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
        Con{index_first(dc(cache)), Con{w7_ctor_index_build(ctor_rows), Nil{}}},True{},False{}}, ctor_rows}
    case False{}:
      seen

@unsafe
def p171s_seed(seen):
  match seen:
    case Nil{}: seen
    case Con{+cache,tail}:
      w7c_p171s_seed_step(p88_string_eq(dk(cache),"BookCache"), cache, tail, seen)

@unsafe
def p171s_cached(+cache: KDef, +rows: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  Con{KDef{dn(cache),dk(cache),da(cache),0,
    {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},{KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
    Con{index_set(index_first(dc(cache)),definition,index_hash(dn(definition),2166136261),32), Con{w7_book_put_ctors(cache, definition), Nil{}}},True{},False{}},
    rows}

@unsafe
def p175rn_name(+rest: List<&2,KDef>, +members: KDef, +name: String, +hash: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,p142j_member(members,name,hash),
    u => p175rn_walk(rest,members),
    u => Con{name,p175rn_walk(rest,p142j_mark(members,name,hash))})

@unsafe
def p175rn_walk(book,members):
  match book:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,db(head),
        u => p175rn_walk(rest,members),
        u => p175rn_name(rest,members,dn(head),index_hash(dn(head),2166136261)))
# One recursive owner includes ordinary substitution AND eager App beta work.
# A beta frame restores the enclosing substitution before its next sibling.
@unsafe
def p185cb_bind(+ids: N111Ids, +tables: List<&2,P111QData>) -> N111Ids:
  +header = p185cb_items(tables,"p111_program")
  p185cb_scanned(ids,p185cb_number(p185cb_at(header,3)),
    nt_choose(P111VScan,p185cb_header(tables,header),
      u => p185cb_scan(p185cb_items(tables,"p111_cid_arity"),p185cb_items(tables,"p111_cid_hot"),0,missing()),
      u => P111VScan{missing(),"unpaired descriptor",0}))

@unsafe
def p186sf_retry(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,name,dest,tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8),
        u => p186sf_push(p114r_prefix(body,U32.inc(count)),name,count,p114h_scan(tail,owner,arity,ready)),
        u => P114GBody{False{},[],[]})
    case None{}: P114GBody{False{},[],[]}

@unsafe
def p186sf_selected(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>, +previous: P114GBody) -> P114GBody:
  match previous:
    case P114GBody{+valid,frames,lowered}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,lowered},
        u => p186sf_retried(previous,p186sf_retry(body,owner,arity,ready,frame)))

@unsafe
def p186sf_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  p186sf_selected(body,owner,arity,ready,frame,p186sf_previous_frame(body,owner,arity,ready,frame))
# Machine object boundary. Bytes are U32 values restricted to0..255. Registers
# use architectural encoding numbers; byte registers4..7 mean spl/bpl/sil/dil,
# never ah/ch/dh/bh. Displacements/addends carry exact two's-complement bits.
law x181_call_text:
  for +symbol: String
  for +args: List<&2,N111Arg>
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

law x185_physical_binary:
  for name: String
  for +typ: N111Type
  for +op: String
  for +left: N111Value
  for +right: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

# Typed late address-selection plans, declared before emission modules.
law x181_frame_scalars:
  for body: List<&2,N111Stmt>
  for frame: X181Frame
  X181Frame

law x181_frame_stmts:
  for body: List<&2,P113DStmt>
  for frame: X181Frame
  X181Frame

@unsafe
def x181_frame_home(+name: String, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      nt_choose(X181Frame,agy_str_eq(dk(p111v_get(slots,name)),"Absent"),
        u => X181Frame{p111v_put(slots,name,"X181Stack",x181_frame_align(U32.add(bytes,8),8),8),
          x181_frame_align(U32.add(bytes,8),8),calls,params,symbol},
        u => frame)

@unsafe
def x181_frame_names(names: List<&2,String>, frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{name,rest}: x181_frame_names(rest,x181_frame_home(name,frame))

# A buffer address is rbp-da and its accessible size is dx. Reuse only when
# both capacity and alignment suffice; implicit scratch can therefore share
# the same region with its explicit, verified alloca declaration.
@unsafe
def x181_frame_buffer(+name: String, +bytes: U32, alignment: U32,
  +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,used,calls,params,symbol}:
      +old = p111v_get(slots,name)
      +size = nt_choose(U32,U32.is_eq(bytes,0),u => 1,u => bytes)
      +align = x181_frame_alignment(alignment)
      +end = x181_frame_align(U32.add(used,size),align)
      nt_choose(X181Frame,agy_str_eq(dk(old),"X181Buffer") &&
        U32.is_ge(dx(old),size) && U32.is_eq(U32.mod(da(old),align),0),
        u => frame,
        u => X181Frame{p111v_put(slots,name,"X181Buffer",end,size),end,calls,params,symbol})

# Staging every argument and reserving another word per argument covers both
# register arguments and the stack-argument copy. It is deliberately generous.
@unsafe
def x181_frame_scalar(stmt: N111Stmt, frame: X181Frame) -> X181Frame:
  match stmt:
    case N111Set{name,typ,value}: x181_frame_home(name,frame)
    case N111Bin{name,typ,op,left,right}: x181_frame_home(name,frame)
    case N111Call{name,typ,symbol,args}:
      x181_frame_outgoing(nt_count(N111Arg,args),x181_frame_home(name,frame))
    case N111If{condition,yes,no}:
      x181_frame_scalars(no,x181_frame_scalars(yes,frame))
    case N111Return{value}: frame
    case N111Load{name,typ,base,offset}: x181_frame_home(name,frame)
    case N111Store{typ,base,offset,value}: frame
    case N111Offset{name,base,bytes}: x181_frame_home(name,frame)
    case N111Alloca{name,bytes,align}: x181_frame_buffer(name,bytes,align,frame)

@unsafe
def x181_frame_scalars(body,frame):
  match body:
    case Nil{}: frame
    case Con{head,rest}: x181_frame_scalars(rest,x181_frame_scalar(head,frame))

@unsafe
def x181_frame_stmt(stmt: P113DStmt, frame: X181Frame) -> X181Frame:
  match stmt:
    case P113DScalar{scalar}: x181_frame_scalar(scalar,frame)
    case P113DIf{condition,yes,no}:
      x181_frame_stmts(no,x181_frame_stmts(yes,frame))
    case P113DCall{+destinations,target,args}:
      x181_frame_outgoing(U32.add(U32.inc(nt_count(N111Value,args)),
        nt_choose(U32,U32.is_eq(nt_count(String,destinations),1),u => 0,u => 1)),
        x181_frame_names(destinations,frame))
    case P113DResult{values}: frame
    case P113DAgain{values}: frame

@unsafe
def x181_frame_stmts(body,frame):
  match body:
    case Nil{}: frame
    case Con{head,rest}: x181_frame_stmts(rest,x181_frame_stmt(head,frame))

@unsafe
def agy_mark_bounded_frame(+symbol: String, body: List<&2,P113DStmt>, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,sym}:
      nt_choose(X181Frame,(String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
          U32.is_le(p113i_size(body),512),
        u => X181Frame{p111v_put(slots,"__agy_ctor_ok","X186SavedMask",1,0),bytes,calls,params,sym},
        u => frame)

# W4-4 Pass 4a: Detect whether "state" is ever referenced in a function body.
@unsafe
def x186_u32_float_probe(+stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x198w_probe(x198w_op(stmt),stmt,ids,frame)

# ABI11102 unary numeric conversions. Input/output are canonical low32 words.
# Only reserved r10/r11, xmm0/xmm1 and flags are clobbered. Arithmetic rounding
# points remain unchanged; CVTSI2SS rounds once, CVTTSS2SI always truncates.
@unsafe
def x192_float_conversion(+name: String, +id: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,23),
    u => w4_u32_to_f32(name,value,ids,frame,homes),
    u => x188_many([x186_x_load(value,ids,frame,homes,x188_xmm(0)),
      x192_float_conversion_core(id),x186_x_compare_result(x186_x_home(name,homes),name,frame)]))

@unsafe
def x185_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x186_float_operation(x186_inline_op(stmt),ids,frame)

@unsafe
def x195s_previous(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  +floating = x185_float_probe(N111Call{name,typ,symbol,args},ids,frame)
  +text = nt_choose(X188Seq,x188_empty(floating),
    u => x186_u32_float_probe(N111Call{name,typ,symbol,args},ids,frame),u => floating)
  x181_add(nt_choose(X188Seq,x188_empty(text),
    u => x188_many([x181_call_text(symbol,args,ids,frame),
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1),v => x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),v => X188Empty{}),
      x181_store(name,frame,x188_reg(0,64))]),u => text),code)

@unsafe
def agy_rt_ctor_text(+name: String, +symbol: String, +args: List<&2,N111Arg>, +cid: U32,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(1,64)),
    x188_i2("movzbl",X187Indexed{1,6,1,0},x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,atOff}),
    x188_i2("subq",X187Imm{words,0},X187Mem{8,lenOff}),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_take_text(+name: String, +symbol: String, +args: List<&2,N111Arg>,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  +rfc = x181_label(U32.add(site,2),frame)
  +shared = x181_label(U32.add(site,3),frame)
  +lbase = U32.add(site,4)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("andl",X187Imm{127,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jl",X187Target{rfc}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,lenOff},x188_reg(11,64)),
    x188_i2("addq",X187Imm{words,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,1,count,0),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,atOff}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,lenOff}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(rfc),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",X187Indexed{9,1,8,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(8,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("ja",X187Target{shared}),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    agy_rfc_unique_free(cls,atOff,lenOff,words,count,slow),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(shared),
    agy_rfc_check_fields(count,0,frame,lbase,slow),
    agy_rfc_bump_fields(count,0,frame,lbase),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_take_reuse_text(+name: String, +count: U32, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  +fallback = "p125_rt_take" ++ U32.show(count)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,11,count,0),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{fallback}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_ctor_reuse_text(+name: String, +count: U32, +args: List<&2,N111Arg>, +cid: U32,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +normal = x181_label(site,frame)
  +slow = x181_label(U32.inc(site),frame)
  +done = x181_label(U32.add(site,2),frame)
  +fallback = "p125_rt_ctor" ++ U32.show(count)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jz",X187Target{normal}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,1,8,0},x188_reg(10,64)),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(0,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(normal),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(1,64)),
    x188_i2("movzbl",X187Indexed{1,6,1,0},x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,atOff}),
    x188_i2("subq",X187Imm{words,0},X187Mem{8,lenOff}),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{fallback}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_sink_skip_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +triv_ok = x181_label(U32.inc(site),frame)
  +slow = x181_label(U32.add(site,2),frame)
  +done = x181_label(U32.add(site,3),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jbe",X187Target{slow}),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{triv_ok}),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("jae",X187Target{slow}),
    x188_label(triv_ok),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_keep_fast_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +triv_ok = x181_label(U32.inc(site),frame)
  +slow = x181_label(U32.add(site,2),frame)
  +done = x181_label(U32.add(site,3),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{16777214,0},x188_reg(0,32)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{triv_ok}),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("jae",X187Target{slow}),
    x188_label(triv_ok),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_borrow_safe_text(+name: String, +count: U32, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv1 = x181_label(site,frame)
  +chk2 = x181_label(U32.inc(site),frame)
  +triv2 = x181_label(U32.add(site,2),frame)
  +ret0 = x181_label(U32.add(site,3),frame)
  +slow = x181_label(U32.add(site,4),frame)
  +done = x181_label(U32.add(site,5),frame)
  +check_second = nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => x188_many([
    x188_i2("testq",x188_reg(2,64),x188_reg(2,64)),
    x188_i1("jge",X187Target{triv2}),
    x188_i2("movq",x188_reg(2,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{chk2}),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(10,64)),
    x188_i1("je",X187Target{ret0}),
    x188_label(chk2),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",X187Indexed{9,10,8,0},x188_reg(11,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(11,32)),
    x188_i1("jbe",X187Target{ret0}),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv2),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow})]))
  +after1 = nt_choose(String,U32.is_eq(count,1),u => done,u => chk2)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv1}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Indexed{9,8,8,0},x188_reg(11,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(11,32)),
    x188_i1("jbe",X187Target{ret0}),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    nt_choose(X188Seq,U32.is_eq(count,1),u => x188_i1("jmp",X187Target{done}),u => X188Empty{}),
    nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => check_second),
    nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => x188_many([
      x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
      x188_i1("jmp",X187Target{done})])),
    x188_label(triv1),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow}),
    nt_choose(X188Seq,U32.is_eq(count,1),
      u => x188_many([x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),x188_i1("jmp",X187Target{done})]),
      u => x188_i1("jmp",X187Target{slow})),
    x188_label(ret0),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p118_rt_borrow_scalar_safe"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def x181_call_text(symbol,args,ids,frame):
  x188_many([x186_call_arguments(args,ids,frame),x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol})])

# Unsigned offsets above INT32_MAX must not become signed displacements.
@unsafe
def x185_late_scalar(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
    u => x186_late_char(stmt,ids,site,bfMask,p186ch_expand(stmt)),u => p112a_expand(3,stmt))

law x185_late_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +site: U32
  P113ABody

@unsafe
def w5b_late_store_call(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, matched: Maybe<&2,List<&2,P113DStmt>>) -> P113ABody:
  match matched:
    case Some{expanded}:
      p113a_prefix(expanded,
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case None{}:
      +s0 : N111Stmt = N111Store{styp,N111Local{sbuf},0,sval}
      +c0 : P113DStmt = P113DScalar{N111Call{dest,N111U64{},sym,args}}
      +r0 : List<&2,P113DStmt> = Con{c0,rest}
      p113a_prefix(x181_scalar_rows(x185_late_scalar(s0,ids,site,w4_bf_mask_for(s0,r0,ids,site))),
        x185_late_stmts(r0,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))

@unsafe
def x185_late_stmts(body,ids,site):
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111Store{+styp,N111Local{+sbuf},0,+sval}},
         Con{P113DScalar{N111Call{+dest,N111U64{},+sym,+args}},+rest}}:
      w5b_late_store_call(styp,sbuf,sval,dest,sym,args,rest,ids,site,
        w5b_match_succ_pair(styp,sbuf,sval,dest,sym,args,site))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes(condition,x181_scalar_rows(no),rest,ids,x185_late_stmts(x181_scalar_rows(yes),ids,site))
    case Con{P113DScalar{+stmt},+rest}:
      p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site,w4_bf_mask_for(stmt,rest,ids,site))),
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes(condition,no,rest,ids,x185_late_stmts(yes,ids,site))
    case Con{head,rest}: p113a_prefix([head],x185_late_stmts(rest,ids,site))

@unsafe
def x185_late_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: x185_late_no(condition,body,rest,ids,x185_late_stmts(no,ids,next))

@unsafe
def x185_late_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],x185_late_stmts(rest,ids,next))

law x181_register_place:
  for +names: List<&2,String>
  for +counts: KDef
  for +frame: X181Frame
  for +register: U32
  X181Frame

@unsafe
def w5b_reads_rec_go(fresh: Bool, +name: String, +counts: KDef, +reversedNames: List<&2,String>, +h: U32, +old: KDef) -> X181ReadCounts:
  match fresh:
    case True{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",1,0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        Con{name,reversedNames}}
    case False{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",x181_read_increment(da(old)),0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        reversedNames}

@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +h = index_hash(name,2166136261)
      +old = index_find(counts,name,h,32)
      w5b_reads_rec_go(String.eq(dk(old),"Absent"),name,counts,reversedNames,h,old)

@unsafe
def w5b_reads_name_go(res: Bool, +name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  match res:
    case True{}: counts
    case False{}: x181_reads_record(name,counts)

@unsafe
def x181_register_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x181_register_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

@unsafe
def x181_register_chosen(names: List<&2,String>, counts: KDef, +frame: X181Frame,
  +register: U32, choice: X181RegisterChoice) -> X181Frame:
  match choice:
    case X181RegisterChoice{name,reads}:
      nt_choose(X181Frame,U32.is_ge(reads,3),
        u => x181_register_place(names,counts,x181_register_install(name,register,frame),U32.inc(register)),
        u => frame)

# At most four scans of distinct names. Once promoted, a slot is not Stack,
# so subsequent scans cannot select it again. No scan occurs per read.
@unsafe
def x181_register_place(names,counts,frame,register):
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      nt_choose(X181Frame,U32.is_gt(register,4),u => frame,
        u => x181_register_chosen(names,counts,frame,register,
          x181_register_best(names,counts,slots,X181RegisterChoice{"",2})))

@unsafe
def x181_register_counted(frame: X181Frame, reads: X181ReadCounts) -> X181Frame:
  match reads:
    case X181ReadCounts{counts,reversedNames}:
      x181_register_place(nt_reverse(String,reversedNames,[]),counts,frame,1)

# Bounded selection-policy experiment. Zero retains the original static-read
# threshold; one weights reads in functions with a backedge; two additionally
# favors parameter and setup-only homes. Physical placement remains unchanged.
@unsafe
def x190_register_scores(names: List<&2,String>, +writes: KDef,
    +params: List<&2,String>, +policy: U32, +counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{+name,rest}:
      +h = index_hash(name,2166136261)
      x190_register_scores(rest,writes,params,policy,
        index_set(counts,KDef{name,"X181Reads",x190_register_score(da(index_find(counts,name,h,32)),
          nb_contains(params,name) || U32.is_eq(da(index_find(writes,name,h,32)),0),policy),0,
          atom("Absent"),atom("Absent"),[],False{},False{}},h,32))

@unsafe
def w5b_copy_write_go(sat: Bool, +cur: U32, +name: String, +counts: KDef, +h: U32) -> KDef:
  match sat:
    case True{}: counts
    case False{}:
      index_set(counts,KDef{name,"X185Writes",U32.inc(cur),0,
        atom("Absent"),atom("Absent"),[],False{},False{}},h,32)

@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  +h = index_hash(name,2166136261)
  +cur = da(index_find(counts,name,h,32))
  w5b_copy_write_go(U32.is_ge(cur,2),cur,name,counts,h)

@unsafe
def x185_copy_writes_names(names: List<&2,String>, counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{name,rest}: x185_copy_writes_names(rest,x185_copy_write(name,counts))

@unsafe
def x185_copy_writes_scalar(stmt: N111Stmt, counts: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: x185_copy_write(name,counts)
    case N111Bin{name,typ,op,left,right}: x185_copy_write(name,counts)
    case N111Call{name,typ,symbol,args}: x185_copy_write(name,counts)
    case N111If{condition,yes,no}: x185_copy_writes_scalars(no,x185_copy_writes_scalars(yes,counts))
    case N111Load{name,typ,base,offset}: x185_copy_write(name,counts)
    case N111Offset{name,base,bytes}: x185_copy_write(name,counts)
    case N111Alloca{name,bytes,align}: x185_copy_write(name,counts)
    case _: counts

@unsafe
def x185_copy_writes_scalars(body: List<&2,N111Stmt>, counts: KDef) -> KDef:
  match body:
    case Nil{}: counts
    case Con{head,rest}: x185_copy_writes_scalars(rest,x185_copy_writes_scalar(head,counts))

@unsafe
def x185_copy_record(+name: String, +typ: N111Type, +source: String, +counts: KDef,
    +params: List<&2,String>, +aliases: KDef) -> KDef:
  nt_choose(KDef,Bool.not(U32.is_eq(p111v_type(typ),1)) && Bool.not(agy_str_eq(name,source)) &&
      Bool.not(nb_contains(params,name)) && U32.is_eq(da(p111v_get(counts,name)),1) &&
      U32.is_eq(da(p111v_get(counts,source)),1),
    u => index_set(aliases,KDef{name,"X185Alias",0,0,atom("Absent"),
      kt("X185Local",x185_copy_name(source,aliases),0,0,[]),[],False{},False{}},index_hash(name,2166136261),32),
    u => aliases)

@unsafe
def x185_copy_alias_scalar(stmt: N111Stmt, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,N111Local{source}}: x185_copy_record(name,typ,source,counts,params,aliases)
    case N111If{condition,yes,no}: x185_copy_alias_scalars(no,counts,params,x185_copy_alias_scalars(yes,counts,params,aliases))
    case _: aliases

@unsafe
def x185_copy_alias_scalars(body: List<&2,N111Stmt>, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match body:
    case Nil{}: aliases
    case Con{head,rest}: x185_copy_alias_scalars(rest,counts,params,x185_copy_alias_scalar(head,counts,params,aliases))

@unsafe
def x185_copy_aliases(body: List<&2,P113DStmt>, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match body:
    case Nil{}: aliases
    case Con{P113DScalar{stmt},rest}: x185_copy_aliases(rest,counts,params,x185_copy_alias_scalar(stmt,counts,params,aliases))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_copy_aliases(rest,counts,params,x185_copy_aliases(no,counts,params,x185_copy_aliases(yes,counts,params,aliases)))
    case Con{head,rest}: x185_copy_aliases(rest,counts,params,aliases)

@unsafe
def x185_t_range(+name: String, first: U32, last: U32, region: U32, ranges: KDef) -> KDef:
  index_set(ranges,KDef{name,"X185TRange",first,last,kt("X185TRegion","",region,0,[]),
    atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def w5b_te_wr(write: Bool, +name: String, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match write:
    case True{}: X185TScan{x185_t_range(name,position,position,region,ranges),Con{name,names},position,region}
    case False{}: x185_t_forbid(name,scan)

@unsafe
def w5b_te_same_reg(same: Bool, +name: String, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match same:
    case True{}: X185TScan{x185_t_range(name,da(old),position,region,ranges),names,position,region}
    case False{}: x185_t_forbid(name,scan)

@unsafe
def w5b_te_is_rng(isRng: Bool, +name: String, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match isRng:
    case True{}: w5b_te_same_reg(U32.is_eq(ix(dt(old)),region),name,old,ranges,names,position,region,scan)
    case False{}: scan

@unsafe
def x185_t_forbid_value(value: N111Value, scan: X185TScan) -> X185TScan:
  match value:
    case N111Local{name}: x185_t_forbid(name,scan)
    case _: scan

@unsafe
def x185_t_forbid_values(values: List<&2,N111Value>, scan: X185TScan) -> X185TScan:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x185_t_forbid_values(rest,x185_t_forbid_value(head,scan))

@unsafe
def x185_t_forbid_args(args: List<&2,N111Arg>, scan: X185TScan) -> X185TScan:
  match args:
    case Nil{}: scan
    case Con{N111Arg{typ,value},rest}: x185_t_forbid_args(rest,x185_t_forbid_value(value,scan))

@unsafe
def x185_t_forbid_names(names: List<&2,String>, scan: X185TScan) -> X185TScan:
  match names:
    case Nil{}: scan
    case Con{name,rest}: x185_t_forbid_names(rest,x185_t_forbid(name,scan))

# Statement endpoints are inclusive. All operand reads precede the write at
# the same position, so even an ending source cannot share this destination.
@unsafe
def x185_t_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x185_t_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

law x185_t_place:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  X181Frame

law w4c_t_place_cap:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  for +maxSpan: U32
  X181Frame

@unsafe
def w4c_t_chosen_cap(name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +maxSpan: U32, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => w4c_t_place_cap(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last),maxSpan),
    u => w4c_t_place_cap(rest,ranges,frame,ends,maxSpan))

@unsafe
def w4c_t_place_cap(names,ranges,frame,ends,maxSpan):
  match names frame:
    case Nil{} _: frame
    case Con{+name,+rest} X181Frame{+slots,bytes,calls,params,symbol}:
      +range = p111v_get(ranges,name)
      +spanOk = U32.is_eq(maxSpan,0) || U32.is_le(U32.sub(dx(range),da(range)),maxSpan)
      nt_choose(X181Frame,agy_str_eq(dk(range),"X185TRange") &&
          agy_str_eq(dk(p111v_get(slots,name)),"X181Stack") && spanOk,
        u => w4c_t_chosen_cap(name,rest,ranges,frame,ends,maxSpan,x185_t_pick(ends,da(range),0),dx(range)),
        u => w4c_t_place_cap(rest,ranges,frame,ends,maxSpan))

@unsafe
def x185_t_place(names,ranges,frame,ends):
  w4c_t_place_cap(names,ranges,frame,ends,0)

@unsafe
def x185_t_scanned(frame: X181Frame, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{ranges,names,+position,region}:
      +cap = nt_choose(U32,U32.is_gt(position,256),u => 48,u => 0)
      w4c_t_place_cap(nt_reverse(String,names,[]),ranges,frame,[0,0,0,0,0],cap)

# Setup is scanned only to exclude its definitions. Such values can survive
# every Again even after their last lexical body read. No entry or call moves
# are changed, and the existing four unique callee-saved homes stay reserved.
@unsafe
def x185_d_names(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{name,rest}: x185_d_names(rest,x185_d_mark(live,name))

@unsafe
def x185_d_kills(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{name,rest}: x185_d_kills(rest,x185_d_kill(live,name))

@unsafe
def x185_d_value(value: N111Value, live: KDef) -> KDef:
  match value:
    case N111Local{name}: x185_d_mark(live,name)
    case _: live

@unsafe
def x185_d_values(values: List<&2,N111Value>, live: KDef) -> KDef:
  match values:
    case Nil{}: live
    case Con{head,rest}: x185_d_values(rest,x185_d_value(head,live))

@unsafe
def x185_d_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{typ,value},rest}: x185_d_args(rest,x185_d_value(value,live))

@unsafe
def w5b_d_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      w5b_d_union_bkt(hash,rest,w5b_d_ins_if(U32.is_gt(da(head),0),hash,head,out))

@unsafe
def w5b_d_mark_if(live: Bool, head: KDef, out: KDef) -> KDef:
  match live:
    case True{}: x185_d_mark(out,dn(head))
    case False{}: out

@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      x185_d_union_bucket(rest,w5b_d_mark_if(U32.is_gt(da(head),0),head,out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: w5b_d_union_bkt(hash,bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out

# Implicit machine inputs have reserved names and their definitions are never
# removed, even when the semantic row does not expose its ABI buffer operand.
@unsafe
def x185_d_base() -> KDef:
  x185_d_names(["state","scratch","__x181_result_out","__x181_results","__x181_tail"],missing())

@unsafe
def x185_d_if_done(+condition: N111Value, rest: List<&2,P113DStmt>, yes: X185Dead, no: X185Dead) -> X185Dead:
  match yes no:
    case X185Dead{Nil{},yl} X185Dead{Nil{},nl}:
      X185Dead{rest,x185_d_union(yl,nl)}
    case X185Dead{yb,yl} X185Dead{nb,nl}:
      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}

@unsafe
def x190_binary_direct(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    narrow: X187Operand, byte: X187Operand, right: X185Physical) -> X188Seq:
  x194_cr_direct(typ,op,left,ids,frame,wide,narrow,byte,right)

@unsafe
def x185_physical_selected(+typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, reg: X185Physical) -> X188Seq:
  match reg:
    case X185Physical{+wide,+narrow,+byte}:
      +instruction = x185_physical_instruction(typ,op,wide,narrow,byte)
      +direct = nt_choose(X188Seq,x190_operands_enabled(),
        u => x190_binary_direct(typ,op,left,ids,frame,wide,narrow,byte,x190_value_home(right,frame)),u => X188Empty{})
      +immediate = nt_choose(X188Seq,x185_machine_enabled(),
        u => x185_physical_immediate(typ,op,x185_id_to_const(right,ids),wide,narrow,byte),u => X188Empty{})
      nt_choose(X188Seq,x188_empty(instruction),u => X188Empty{},u =>
        nt_choose(X188Seq,x188_empty(immediate),v =>
          nt_choose(X188Seq,x188_empty(direct),w =>
            x188_many([x181_load(right,ids,frame,x188_reg(11,64)),x185_physical_load(left,ids,frame,wide),instruction]),w => direct),
          v => x188_cat(x185_physical_load(left,ids,frame,wide),immediate)))
    case _: X188Empty{}

@unsafe
def x185_physical_binary(name,typ,op,left,right,ids,frame):
  nt_choose(X188Seq,x185_register_binary_enabled(),
    u => x185_physical_selected(typ,op,left,right,ids,frame,x185_physical_home(name,frame)),u => X188Empty{})

# Experimental physical right-home selection for integer commutative ALU.
# No expression/value motion, allocation change, or additional analysis walk.
@unsafe
def x185_sf_blocks(names: List<&2,String>, buffers: KDef) -> KDef:
  match names:
    case Nil{}: buffers
    case Con{name,rest}: x185_sf_blocks(rest,x185_sf_block(name,buffers))

@unsafe
def x185_sf_alloca(+name: String, +bytes: U32, +buffers: KDef) -> KDef:
  +old = p111v_get(buffers,name)
  nt_choose(KDef,(x181_register_reserved(name) && Bool.not(agy_str_eq(name,"scratch"))),
    u => x185_sf_block(name,buffers),u => nt_choose(KDef,agy_str_eq(dk(old),"X185ScratchBlocked"),u => buffers,
    u => nt_choose(KDef,U32.is_gt(bytes,0) && U32.is_le(bytes,2048),
      v => p111v_put(buffers,name,"X185ScratchBuffer",
        nt_choose(U32,agy_str_eq(dk(old),"X185ScratchBuffer"),w => U32.min(bytes,da(old)),w => bytes),0),
      v => x185_sf_block(name,buffers))))

law x185_sf_buffers:
  for body: List<&2,P113DStmt>
  for buffers: KDef
  KDef

@unsafe
def x185_sf_scalar_buffer(stmt: N111Stmt, buffers: KDef) -> KDef:
  match stmt:
    case N111Alloca{name,bytes,align}: x185_sf_alloca(name,bytes,buffers)
    case N111Set{name,typ,value}: x185_sf_block(name,buffers)
    case N111Bin{name,typ,op,left,right}: x185_sf_block(name,buffers)
    case N111Load{name,typ,base,offset}: x185_sf_block(name,buffers)
    case N111Offset{name,base,bytes}: x185_sf_block(name,buffers)
    case N111Call{name,typ,symbol,args}: x185_sf_block(name,buffers)
    case N111If{condition,yes,no}:
      x185_sf_buffers(x181_scalar_rows(no),x185_sf_buffers(x181_scalar_rows(yes),buffers))
    case _: buffers

@unsafe
def x185_sf_buffers(body,buffers):
  match body:
    case Nil{}: buffers
    case Con{P113DScalar{stmt},rest}: x185_sf_buffers(rest,x185_sf_scalar_buffer(stmt,buffers))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_sf_buffers(rest,x185_sf_buffers(no,x185_sf_buffers(yes,buffers)))
    case Con{P113DCall{names,target,args},rest}: x185_sf_buffers(rest,x185_sf_blocks(names,buffers))
    case Con{head,rest}: x185_sf_buffers(rest,buffers)

@unsafe
def x186_m_escape(name: String, scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{buffers,reads,used}: X186Memory{x185_sf_block(name,buffers),reads,used}

@unsafe
def x186_m_value(value: N111Value, scan: X186Memory) -> X186Memory:
  match value:
    case N111Local{name}: x186_m_escape(name,scan)
    case _: scan

@unsafe
def x186_m_read(+name: String, +offset: U32, +typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{+buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),
        u => x186_m_read_second(name,offset,typ,buffers,
          p111v_put(reads,x186_m_key(name,offset),"X186Read",1,0),p111v_put(used,name,"X186Used",1,0)),
        u => x186_m_escape(name,scan))

@unsafe
def x186_m_store(+name: String, offset: U32, typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),u => scan,u => x186_m_escape(name,scan))

@unsafe
def x186_m_add_name(+m: KDef, +name: String) -> KDef:
  +h = index_hash(name,2166136261)
  w5b_m_add_if(String.eq(dk(index_find(m,name,h,32)),"X186M"),m,name,h)

@unsafe
def x186_m_add_val(+m: KDef, v: N111Value) -> KDef:
  match v:
    case N111Local{name}: x186_m_add_name(m,name)
    case _: m

@unsafe
def x186_e_remember_alias(+state: X186ExprState, +name: String, +typ: N111Type, +value: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(ac,1024),
        u =>
          +item : X186Alias = X186Alias{name,value}
          +h = index_hash(name,2166136261)
          +m1 = x186_m_add_val(x186_m_add_name(mentioned,name),value)
          X186ExprState{facts,Con{item,aliases},fc,U32.inc(ac),m1,ft,x186_at_insert(at,item,h)},
        u => state)

@unsafe
def x186_e_insert(+state: X186ExprState, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +eh: U32) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) && U32.is_lt(fc,1024),
        u =>
          +item : X186Expr = X186Expr{name,kind,typ,op,left,right}
          +m1 = x186_m_add_val(x186_m_add_val(x186_m_add_name(mentioned,name),left),right)
          X186ExprState{Con{item,facts},aliases,U32.inc(fc),ac,m1,x186_ft_insert(ft,item,eh),at},
        u => state)

@unsafe
def w5_sel_write(s: W5Sel, acc: KDef) -> KDef:
  match s:
    case W5Sel{_,dst,_,_,_}: x185_d_mark(acc,dst)
    case W5SelNone{}: acc

@unsafe
def w5_sel_read(s: W5Sel, acc: KDef) -> KDef:
  match s:
    case W5Sel{c,_,_,va,vb}: x185_d_value(vb,x185_d_value(va,x185_d_value(c,acc)))
    case W5SelNone{}: acc

@unsafe
def w4c_dia_write_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: x185_d_mark(acc,n)
    case N111Bin{n,_,_,_,_}: x185_d_mark(acc,n)
    case _: acc

@unsafe
def w4c_dia_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_writes(rest,w4c_dia_write_scalar(sc,acc))
    case Con{P113DIf{c,y,n},rest}: w4c_dia_writes(rest,w5_sel_write(w5_as_sel(c,y,n),acc))
    case Con{_,rest}: w4c_dia_writes(rest,acc)

@unsafe
def w4c_dia_read_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{_,_,v}: x185_d_value(v,acc)
    case N111Bin{_,_,_,l,r}: x185_d_value(r,x185_d_value(l,acc))
    case _: acc

@unsafe
def x190_v_set(+name: String, +typ: N111Type, +value: N111Value, +state: X190Values) -> X190ValueStep:
  +zero = x190_v_zero(value,state)
  +narrow = U32.is_eq(p111v_type(typ),1)
  +outType = nt_choose(N111Type,narrow && zero,u => N111U64{},u => typ)
  +written = x190_v_written(name,narrow || zero,state)
  X190ValueStep{P113DScalar{N111Set{name,outType,value}},nt_choose(X190Values,Bool.not(narrow) || zero,
    u => x190_v_alias(name,value,written),u => written)}

@unsafe
def w5b_v_binary_go(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +state: X190Values, folded: Maybe<&2,U32>) -> X190ValueStep:
  match folded:
    case Some{v}: x190_v_set(name,typ,N111Const{v,0},state)
    case None{}:
      nt_choose(X190ValueStep,agy_str_eq(op,"and") && x190_v_mask(right),
        u => x190_v_set(name,N111U32{},left,state),u =>
          X190ValueStep{P113DScalar{N111Bin{name,typ,op,left,right}},
            x190_v_written(name,U32.is_eq(p111v_type(typ),1) || p111v_comparison(op),state)})

law x195bf_kill_body:
  for body: List<&2,P113DStmt>
  for state: X190Values
  X190Values

@unsafe
def x195bf_kill_scalar(stmt: N111Stmt, state: X190Values) -> X190Values:
  match stmt:
    case N111Set{name,typ,value}: x190_v_written(name,False{},state)
    case N111Bin{name,typ,op,left,right}: x190_v_written(name,False{},state)
    case N111Offset{name,base,bytes}: x190_v_written(name,False{},state)
    case N111Load{name,typ,base,offset}: x190_v_written(name,False{},state)
    case N111Alloca{name,bytes,align}: x190_v_written(name,False{},state)
    case N111Store{typ,base,offset,value}: state
    case N111If{condition,yes,no}:
      x195bf_kill_body(x181_scalar_rows(no),x195bf_kill_body(x181_scalar_rows(yes),state))
    case _: x190_v_empty()

@unsafe
def x195bf_kill_stmt(stmt: P113DStmt, state: X190Values) -> X190Values:
  match stmt:
    case P113DScalar{scalar}: x195bf_kill_scalar(scalar,state)
    case P113DIf{condition,yes,no}: x195bf_kill_body(no,x195bf_kill_body(yes,state))
    case _: x190_v_empty()

@unsafe
def x195bf_kill_body(body,state):
  match body:
    case Nil{}: state
    case Con{head,rest}: x195bf_kill_body(rest,x195bf_kill_stmt(head,state))

@unsafe
def x195bf_join(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, state: X190Values) -> X190Values:
  x195bf_kill_body(no,x195bf_kill_body(yes,state))

# W5B-R3: General P113DIf constant-branch folding & O(N)-guarded invariant trailing-copy hoisting
@unsafe
def w5b_put_names(names: List<&2,String>, +m: KDef) -> KDef:
  match names:
    case Nil{}: m
    case Con{n,t}: w5b_put_names(t,w5b_put_name(n,m))

law w5b_writes_body:
  for body: List<&2,P113DStmt>
  for +m: KDef
  KDef

@unsafe
def w5b_writes_scalar(stmt: N111Stmt, +m: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: w5b_put_name(n,m)
    case N111Bin{n,_,_,_,_}: w5b_put_name(n,m)
    case N111Offset{n,_,_}: w5b_put_name(n,m)
    case N111Load{n,_,_,_}: w5b_put_name(n,m)
    case N111Call{n,_,_,_}: w5b_put_name(n,m)
    case N111Alloca{n,_,_}: w5b_put_name(n,m)
    case N111If{_,yes,no}: w5b_writes_body(x181_scalar_rows(no),w5b_writes_body(x181_scalar_rows(yes),m))
    case _: m

@unsafe
def w5b_writes_body(body,m):
  match body:
    case Nil{}: m
    case Con{P113DScalar{s},t}: w5b_writes_body(t,w5b_writes_scalar(s,m))
    case Con{P113DIf{_,yes,no},t}: w5b_writes_body(t,w5b_writes_body(no,w5b_writes_body(yes,m)))
    case Con{P113DCall{ns,_,_},t}: w5b_writes_body(t,w5b_put_names(ns,m))
    case Con{_,t}: w5b_writes_body(t,m)

@unsafe
def w5b_sets_reads(sets: List<&2,P113DStmt>, +m: KDef) -> KDef:
  match sets:
    case Nil{}: m
    case Con{P113DScalar{N111Set{_,_,N111Local{v}}},t}: w5b_sets_reads(t,w5b_put_name(v,m))
    case Con{_,t}: w5b_sets_reads(t,m)

@unsafe
def w5b_collect_hoist(ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>, +preW: KDef,
    +ySetW: KDef, +nSetW: KDef, +setR: KDef, +allW: KDef, +hoistNames: KDef) -> KDef:
  match ySets:
    case Nil{}: hoistNames
    case Con{+h,+t}:
      match h:
        case P113DScalar{N111Set{+x,_,_}}:
          nt_choose(KDef,w5b_can_hoist(h,nSets,preW,ySetW,nSetW,setR,allW),
            u => w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,w5b_put_name(x,hoistNames)),
            u => w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,hoistNames))
        case _: w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,hoistNames)

@unsafe
def x195cf_kill_names(names: List<&2,String>, state: X190Values) -> X190Values:
  match names:
    case Nil{}: state
    case Con{name,rest}: x195cf_kill_names(rest,x190_v_written(name,False{},state))

@unsafe
def x195cf_after_call(names: List<&2,String>, state: X190Values) -> X190Values:
  nt_choose(X190Values,x195cf_enabled(),
    u => x195cf_kill_names(names,state),u => x190_v_empty())

@unsafe
def x186_f_values_text(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_values(name,left,ids,frame,missing()),
    u => nt_choose(X188Seq,x192_float_unary(id),
    u => x192_float_conversion(name,id,left,ids,frame,missing()),
    u => x188_many([x186_float_load(left,ids,frame,x188_xmm(0)),x186_float_load(right,ids,frame,x188_xmm(1)),
      x186_float_finish(name,id,frame)])))
@unsafe
def w2_x_forbid_val(value: N111Value, ranges: X185TScan) -> X185TScan:
  match value:
    case N111Local{name}: x185_t_forbid(name,ranges)
    case _: ranges

@unsafe
def x186_x_scanned(scan: X186XScan) -> KDef:
  match scan:
    case X186XScan{X185TScan{ranges,names,position,region},canonical}:
      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),[0,0,0,0,0,0,0,0,0,0,0,0,0,0])

@unsafe
def x186_x_scanned_capped(scan: X186XScan, +tempRegs: U32) -> KDef:
  match scan:
    case X186XScan{X185TScan{ranges,names,position,region},canonical}:
      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),w4b_zeros(tempRegs))

@unsafe
def w2b_x_arith_emit(+name: String, id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +destination: Maybe<&2,X187Operand>, +target: X187Operand) -> X188Seq:
  +source = x186_x_source(right,homes)
  +direct = x186_x_direct(source,target)
  +fmem = x186_float_source(right,frame)
  +use_mem = Bool.not(x186_float_present(source)) && w2c_is_mem(fmem)
  x188_many([
    nt_choose(X188Seq,direct || use_mem,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),
    x186_x_load(left,ids,frame,homes,target),
    x188_i2(x185_float_arithmetic(id),
      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),
        u => nt_choose(X187Operand,use_mem,v => x186_float_operand(fmem,x188_xmm(1)),v => x188_xmm(1))),target),
    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])

@unsafe
def x186_x_arithmetic(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +destination = x186_x_home(name,homes)
  +target = x186_float_operand(destination,x188_xmm(0))
  +comm = (U32.is_eq(id,26) || U32.is_eq(id,28)) && w2b_x_same_opt(x186_x_source(right,homes),target) &&
          Bool.not(w2b_x_same_opt(x186_x_source(left,homes),target))
  nt_choose(X188Seq,comm,
    u => w2b_x_arith_emit(name,id,right,left,ids,frame,homes,destination,target),
    u => w2b_x_arith_emit(name,id,left,right,ids,frame,homes,destination,target))

@unsafe
def x186_x_compare(+name: String, id: U32, left: N111Value, right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +destination = x186_x_home(name,homes)
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),x186_x_load(right,ids,frame,homes,x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(1),x188_xmm(0)),x185_float_compare(id),
    x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32)),x186_x_compare_result(destination,name,frame)])

@unsafe
def x200r_sqrt_values(name: String, left: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_emit(+name: String, +left: N111Value, +ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,U32.is_le(next,4294967293),
        u => X181Code{Con{x200r_sqrt_core(name,left,ids,frame,homes,next),chunks},U32.add(next,2),terminal,error},
        u => x181_add(x200r_sqrt_values(name,left,ids,frame,homes),code))

@unsafe
def w2_xl_again_update(found: Maybe<&2,N111Value>, +xmm: U32, ids: N111Ids, frame: X181Frame, homes: KDef) -> X188Seq:
  match found:
    case Some{val}: x186_x_load(val,ids,frame,homes,x188_xmm(xmm))
    case None{}: X188Empty{}

law w4_xl_again_updates:
  for +i: U32
  for +cnt: U32
  for +vals: List<&2,N111Value>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  X188Seq

@unsafe
def w4_xl_again_step(+i: U32, +cnt: U32, +vals: List<&2,N111Value>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +ce: KDef) -> X188Seq:
  x188_cat(w2_xl_again_update(w2_xl_nth(vals,da(ce)),dx(ce),ids,frame,homes),
    w4_xl_again_updates(U32.inc(i),cnt,vals,ids,frame,homes))

@unsafe
def w4_xl_again_updates(i,cnt,vals,ids,frame,homes):
  nt_choose(X188Seq,U32.is_ge(i,cnt),u => X188Empty{},
    u => w4_xl_again_step(i,cnt,vals,ids,frame,homes,p111v_get(homes,"$w4_cx_" ++ U32.show(i))))

@unsafe
def w2_fbranch_code(+id: U32, left: N111Value, right: N111Value, label: U32,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +swap = U32.is_eq(id,32) || U32.is_eq(id,33)
  +jcc = nt_choose(String,U32.is_eq(id,32) || U32.is_eq(id,34),u => "jbe",u => "jb")
  x188_many([
    x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x186_x_load(right,ids,frame,homes,x188_xmm(1)),
    nt_choose(X188Seq,swap,
      u => x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
      u => x188_i2("ucomiss",x188_xmm(1),x188_xmm(0))),
    x188_i1(jcc,X187Target{x181_label(label,frame)})])

@unsafe
def w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +hotConsts: List<&2,U32>, +startReg: U32, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  match plan:
    case W2XLoopPlan{homes,pre,carried,active}:
      match carried:
        case Con{W4Carried{+cname,+cidx,+cxmm},Nil{}}:
          +st1 = w2_xl_assign_consts(hotConsts,
                   w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,U32.inc(cxmm)}))
          w4_xl_pick_more(tparams,0,cidx,tparams,nodes,ids,frame,st1,[W4Carried{cname,cidx,cxmm}])
        case _:
          w4_xl_alloc_plan(w2_xl_assign_consts(hotConsts,
            w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,startReg})))

@unsafe
def x194fv_when(enabled: Bool, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  +rows = x186_f_placement_rows(nodes)
  nt_choose(List<&2,X186FloatNode>,enabled &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(rows)),4096) &&
      x194fv_names(params) && x194fv_clean_body(setup) && x194fv_clean_body(rows),
    u => x194fv_walk(nodes,"",0,missing()),u => nodes)

@unsafe
def x194fv_nodes(params: List<&2,String>, setup: List<&2,P113DStmt>,
    nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  x194fv_when(x194fv_enabled(),params,setup,nodes)

# Integration point is after float scratch pruning and before all placement.
# Wave2 Track A: General F32 constant folding & propagation on X186FloatNode.
@unsafe
def w2_fc_kill_stmt(stmt: P113DStmt, env: KDef) -> KDef:
  match stmt:
    case P113DScalar{scalar}: w2_fc_kill_scalar(scalar,env)
    case P113DCall{names,target,args}: w2_fc_kill_names(names,env)
    case P113DIf{condition,yes,no}: missing()
    case _: env

law w2_fc_nodes:
  for nodes: List<&2,X186FloatNode>
  for +env: KDef
  List<&2,X186FloatNode>

@unsafe
def w2_fc_after_fold(folded: Maybe<&2,U32>, +dest: String, id: U32, left: N111Value,
    right: N111Value, rest: List<&2,X186FloatNode>, +env: KDef) -> List<&2,X186FloatNode>:
  match folded:
    case Some{+bits}:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},N111Const{bits,0}}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"W2Const",bits,0))}
    case None{}:
      Con{X186FloatValues{dest,id,left,right},w2_fc_nodes(rest,p111v_put(env,dest,"Absent",0,0))}

@unsafe
def w2_fc_set(+dest: String, +val: N111Value, rest: List<&2,X186FloatNode>, +env: KDef) -> List<&2,X186FloatNode>:
  match val:
    case N111Const{lo,0}:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},N111Const{lo,0}}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"W2Const",lo,0))}
    case _:
      Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},val}}},
        w2_fc_nodes(rest,p111v_put(env,dest,"Absent",0,0))}

@unsafe
def w2_fc_nodes(nodes,env):
  match nodes:
    case Nil{}: []
    case Con{X186FloatValues{dest,+id,left,right},rest}:
      +l2 = w2_fc_resolve(left,env)
      +r2 = w2_fc_resolve(right,env)
      w2_fc_after_fold(w2_fc_try_fold(id,l2,r2),dest,id,l2,r2,rest,env)
    case Con{X186FloatPlain{P113DScalar{N111Set{dest,N111U64{},val}}},rest}:
      w2_fc_set(dest,w2_fc_resolve(val,env),rest,env)
    case Con{X186FloatBranch{condition,yes,no},rest}:
      Con{X186FloatBranch{condition,w2_fc_nodes(yes,env),w2_fc_nodes(no,env)},w2_fc_nodes(rest,missing())}
    case Con{X186FloatPlain{+stmt},rest}:
      Con{X186FloatPlain{stmt},w2_fc_nodes(rest,w2_fc_kill_stmt(stmt,env))}

@unsafe
def x190_l_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +register = x190_l_home(groups,bit,0)
      x190_l_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(register,5),
        u => x185_t_install(name,register,frame),u => frame))

@unsafe
def x203_candidates(names: List<&2,String>, counts: KDef, slots: KDef) -> X190LCandidates:
  x203_choices(x203_rank(names,counts,slots,[]),1,missing(),[])

@unsafe
def x190_a_tail(params: List<&2,String>, values: List<&2,N111Value>, +ids: KDef, affinities: KDef) -> KDef:
  match params values:
    case Con{name,rest} Con{value,more}: x190_a_tail(rest,more,ids,x190_a_pair(name,value,ids,affinities))
    case _ _: affinities

@unsafe
def x190_a_body(body: List<&2,P113DStmt>, +ids: KDef, +params: List<&2,String>, affinities: KDef) -> KDef:
  match body:
    case Nil{}: affinities
    case Con{P113DScalar{N111Set{name,typ,value}},rest}:
      x190_a_body(rest,ids,params,x190_a_pair(name,value,ids,affinities))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x190_a_body(rest,ids,params,x190_a_body(x181_scalar_rows(no),ids,params,
        x190_a_body(x181_scalar_rows(yes),ids,params,affinities)))
    case Con{P113DIf{condition,yes,no},rest}:
      x190_a_body(rest,ids,params,x190_a_body(no,ids,params,x190_a_body(yes,ids,params,affinities)))
    case Con{P113DAgain{values},rest}: x190_a_body(rest,ids,params,x190_a_tail(params,values,ids,affinities))
    case Con{head,rest}: x190_a_body(rest,ids,params,affinities)

@unsafe
def x190_j_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +color = x190_j_home(groups,bit,0)
      x190_j_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(color,4),
        u => x181_register_install(name,U32.inc(color),frame),u =>
          nt_choose(X181Frame,U32.is_lt(color,9),v => x185_t_install(name,U32.sub(color,4),frame),v => frame)))

# Every refusal returns through the complete previous allocator, including its
# saved-home selection. Never leave a fresh stack-only frame on a joint refusal.
law w5c_pj_place:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  for +occ: List<&2,List<&2,W5CIntv>>
  for +maxSpan: U32
  X181Frame

@unsafe
def w5c_pj_chosen(+name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +occ: List<&2,List<&2,W5CIntv>>, +maxSpan: U32, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => w5c_pj_place(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last),occ,maxSpan),
    u => w5c_pj_place(rest,ranges,frame,ends,occ,maxSpan))

@unsafe
def w5c_pj_place(names,ranges,frame,ends,occ,maxSpan):
  match names:
    case Nil{}: frame
    case Con{+name,+rest}:
      match frame:
        case X181Frame{+slots,bytes,calls,params,symbol}:
          +range = p111v_get(ranges,name)
          +spanOk = U32.is_eq(maxSpan,0) || U32.is_le(U32.sub(dx(range),da(range)),maxSpan)
          nt_choose(X181Frame,agy_str_eq(dk(range),"X185TRange") &&
              agy_str_eq(dk(p111v_get(slots,name)),"X181Stack") && spanOk,
            u => w5c_pj_chosen(name,rest,ranges,frame,ends,occ,maxSpan,
              w5c_pj_pick(ends,occ,da(range),dx(range),0),dx(range)),
            u => w5c_pj_place(rest,ranges,frame,ends,occ,maxSpan))

@unsafe
def w5c_pj_run(frame: X181Frame, +ranges: KDef, allNames: List<&2,String>, +position: U32, st: W5CPJState) -> X181Frame:
  match st:
    case W5CPJState{ends,occ}:
      +cap = nt_choose(U32,U32.is_gt(position,256),u => 48,u => 0)
      w5c_pj_place(nt_reverse(String,allNames,[]),ranges,frame,ends,occ,cap)

@unsafe
def x190_j_weighted(reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{counts,+names}:
      X181ReadCounts{x190_register_scores(names,missing(),[],1,counts),names}

# Profitability only: a syntactic read on a path to Again receives seven
# extra votes (eight total). Exit-only and setup reads keep one vote. Identity
# backedge transports receive no bonus; they do not consume their own home.
# This walk never changes liveness, graph edges, call clobbers or validation.
# It runs only inside the existing 256-statement / 64-parameter joint bound.
@unsafe
def x191_reads_merge(left: X181ReadCounts, right: X181ReadCounts) -> X181ReadCounts:
  match left:
    case X181ReadCounts{counts,names}: x191_reads_merge_names(names,counts,right)

@unsafe
def x191_loop_cons(head: X191LoopReads, rest: X191LoopReads) -> X191LoopReads:
  match head rest:
    case X191LoopReads{+a,hot,+falls} X191LoopReads{b,restHot,restFalls}:
      X191LoopReads{nt_choose(X181ReadCounts,falls,u => x191_reads_merge(a,b),u => a),hot,falls && restFalls}

@unsafe
def x191_loop_counted(all: X181ReadCounts, repeated: X191LoopReads) -> X181ReadCounts:
  match all repeated:
    case X181ReadCounts{counts,+names} X191LoopReads{X181ReadCounts{hot,hotNames},reaches,falls}:
      X181ReadCounts{x191_loop_scores(names,hot,counts),names}

@unsafe
def x190_branch_pair(body: List<&2,P113DStmt>, +pairs: KDef) -> KDef:
  match body:
    case Con{P113DScalar{N111Bin{+name,typ,op,left,right}},Con{P113DIf{condition,yes,no},rest}}:
      nt_choose(KDef,x190_branch_shape(name,typ,op,condition),u => x190_branch_pair_record(name,pairs),u => pairs)
    case Con{P113DScalar{N111Bin{+name,typ,op,left,right}},Con{P113DScalar{N111If{condition,yes,no}},rest}}:
      nt_choose(KDef,x190_branch_shape(name,typ,op,condition),u => x190_branch_pair_record(name,pairs),u => pairs)
    case _: pairs

law x190_branch_pairs:
  for +body: List<&2,P113DStmt>
  for pairs: KDef
  KDef

@unsafe
def x190_branch_pairs_stmt(stmt: P113DStmt, pairs: KDef) -> KDef:
  match stmt:
    case P113DIf{condition,yes,no}: x190_branch_pairs(no,x190_branch_pairs(yes,pairs))
    case P113DScalar{N111If{condition,yes,no}}:
      x190_branch_pairs(x181_scalar_rows(no),x190_branch_pairs(x181_scalar_rows(yes),pairs))
    case _: pairs

@unsafe
def x190_branch_pairs(body,pairs):
  match body:
    case Nil{}: pairs
    case Con{head,rest}: x190_branch_pairs(rest,x190_branch_pairs_stmt(head,
      x194_ps_count_pick(x194_ps_pick(body),x190_branch_pair(body,pairs))))

@unsafe
def w4b_find_loop(+items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  +jmps = w7_collect_jmps(items,missing())
  nt_choose(W4BLoopSplit,agy_str_eq(dk(jmps),"Absent"),
    u => W4BLoopNone{},
    u => w7_find_loop_go(items,before,jmps))

@unsafe
def w4b_licm_magic(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  nt_choose(List<&2,X187Parsed>,w4b_has_call(items),u => items,u => w4b_licm_apply(w4b_find_loop(items,[]),items))

# W4-7 Pass 4: General bottom-tested tail-loop rotation.
@unsafe
def w4b_rotate_loop(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4b_rotate_apply(w4b_find_loop(items,[]),items)

@unsafe
def w11_ror16_rb(+rX: U32, +rA: U32, +k: U32, rb_opt: Maybe<&2,U32>, r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{+rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)),
        u => w11_ror16_s3(rX,rA,rB,k,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_s2(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}: w11_ror16_rb(rX,rA,k,w11_inst_reg_dst(i2,"movq",rA,64,64),r3,fnItems)
    case _: None{}

@unsafe
def w11_ror16_k(+rX: U32, +rA: U32, k_opt: Maybe<&2,U32>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match k_opt:
    case Some{+k}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_ge(k,1) && U32.is_le(k,15),
        u => w11_ror16_s2(rX,rA,k,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_s3(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}: w11_rol16_rb(rX,rA,k,w11_inst_reg_dst(i3,"movq",rX,64,64),r4,fnItems)
    case _: None{}

@unsafe
def w11_rol16_s2(+rX: U32, +rA: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i2,"movl",rA,32,rA,32),
        u => w11_rol16_s3(rX,rA,k,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_k(+rX: U32, +rA: U32, k_opt: Maybe<&2,U32>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match k_opt:
    case Some{+k}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_ge(k,1) && U32.is_le(k,15),
        u => w11_rol16_s2(rX,rA,k,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_s0(+cmpInst: X187Parsed, s_opt: Maybe<&2,W11SetCC>, r1: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s_opt:
    case Some{W11SetCC{opSet,rA}}: w11_cmp_jcc_s1(cmpInst,w5b_set_cc(opSet),rA,r1,fnItems)
    case _: None{}

@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i0,r1}: w11_cmp_jcc_s0(cmpInst,w11_inst_setcc(i0),r1,fnItems)
    case _: None{}

# Try movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d -> cmpq %rB, %rA; setcc; movzbl
@unsafe
def w5b_try_cmp_bounce(+rA: U32, +rT1: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_cmp_bounce_s1(rA,rT1,w11_inst_reg_reg(i1,"movq",64,64),r2,fnItems)
    case _: None{}

# Try spill-bounce: movq %rS, %rT; movq %rT, d(%rbp) (rT in {10,11}, rT dead) -> movq %rS, d(%rbp)
@unsafe
def w11_sel_bounce_s1(rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}: w11_sel_bounce_src(w11_inst_any_reg(i1,"movq",10,64),r2,fnItems)
    case _: None{}

@unsafe
def w5b_try_sel_bounce(+rA: U32, +rD: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rA,10) && U32.is_eq(rD,0),
    u => w11_sel_bounce_s1(rest,fnItems),
    u => None{})

# Try duplicate load before imull: movq d(%rbp), %rA; movq d(%rbp), %rB; imull %rA32, %rB32 (%rA dead)
@unsafe
def x194_ps_count_pick(pick: Maybe<&2,X194Select>, pairs: KDef) -> KDef:
  match pick:
    case Some{X194Select{rest,typ,op,left,right,invert,selected,names}}: x194_ps_count(names,pairs)
    case None{}: pairs

# Every actual read of each removed local must be accounted for by one of
# these exact comparison corridors. Parameters and setup definitions refuse.
# Repeated mutable names are allowed only under that complete-use certificate.
@unsafe
def x194_ps_emit(+plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +selected = x197ms_pick(plan,frame)
  nt_choose(X188Seq,x188_empty(selected),u => x197ms_previous(plan,ids,frame),u => selected)

@unsafe
def x192_p_scalar_facts(stmt: N111Stmt, +facts: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: x192_p_write(facts,name,x190_branch_width(typ) && x192_p_boolean(value,facts))
    case N111Bin{+name,typ,+op,+left,+right}:
      x192_p_write(facts,name,x190_branch_width(typ) &&
        (p111v_comparison(op) || ((agy_str_eq(op,"and") || agy_str_eq(op,"or") || agy_str_eq(op,"xor")) &&
          x192_p_boolean(left,facts) && x192_p_boolean(right,facts))))
    case N111Load{name,typ,base,offset}: x192_p_write(facts,name,False{})
    case N111Offset{name,base,bytes}: x192_p_write(facts,name,False{})
    case N111Alloca{name,bytes,align}: x192_p_write(facts,name,False{})
    case N111Store{typ,base,offset,value}: facts
    case _: missing()

law x192_p_body:
  for body: List<&2,P113DStmt>
  for facts: KDef
  List<&2,P113DStmt>

@unsafe
def x192_p_if_chosen(chosen: Maybe<&2,List<&2,P113DStmt>>, condition: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  match chosen:
    case Some{rows}: x192_p_body(nt_append(P113DStmt,rows,rest),facts)
    case None{}: Con{P113DIf{condition,x192_p_body(yes,facts),x192_p_body(no,facts)},x192_p_body(rest,missing())}

@unsafe
def x192_p_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  x192_p_if_chosen(x192_p_plan(condition,facts,x191_select_plan(yes,no)),condition,yes,no,rest,facts)

@unsafe
def x192_p_scalar(stmt: N111Stmt, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  +ready = x192_p_binary(stmt,facts)
  Con{P113DScalar{ready},x192_p_body(rest,x192_p_scalar_facts(ready,facts))}

@unsafe
def x192_p_body(body,facts):
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x192_p_if(condition,yes,no,rest,facts)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x192_p_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,facts)
    case Con{P113DScalar{stmt},rest}: x192_p_scalar(stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_p_body(rest,missing())}

@unsafe
def x181_call(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>,
  +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match destinations:
    case Con{name,Nil{}}:
      x181_add(x188_cat(x181_call_text(p113e_symbol(target),Con{N111Arg{N111Ptr{},N111Local{"state"}},x181_args(args)},ids,frame),
        x181_store(name,frame,x188_reg(0,64))),code)
    case _:
      x181_load_results(destinations,0,ids,frame,x181_add(
        x181_call_text(p113e_symbol(target),Con{N111Arg{N111Ptr{},N111Local{"state"}},
          Con{N111Arg{N111Ptr{},N111Local{"__x181_results"}},x181_args(args)}},ids,frame),code))

@unsafe
def x181_again(+values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  x186_again_planned(values,ids,frame,code,x186_parallel(x181_tail_args(frame),values,ids,frame))

@unsafe
def x198a_back(params: List<&2,String>, values: List<&2,N111Value>, +fuel: String, +pred: String,
    +bindings: List<&2,X186Alias>, +facts: KDef) -> Maybe<&2,KDef>:
  match params values:
    case Nil{} Nil{}: Some{facts}
    case Con{+param,+ps} Con{+value,+vs}:
      nt_choose(Maybe<&2,KDef>,agy_str_eq(param,fuel),u =>
        nt_choose(Maybe<&2,KDef>,x185_sf_source(value,pred),
          v => x198a_back(ps,vs,fuel,pred,bindings,facts),v => None{}),u =>
        x198a_back_word(param,x186_e_value(value,bindings),ps,vs,fuel,pred,bindings,facts))
    case _ _: None{}

@unsafe
def x198a_back_word(+param: String, value: N111Value, ps: List<&2,String>, vs: List<&2,N111Value>,
    +fuel: String, +pred: String, +bindings: List<&2,X186Alias>, +facts: KDef) -> Maybe<&2,KDef>:
  match value:
    case N111Const{lo,hi}:
      x198a_back(ps,vs,fuel,pred,bindings,p113k_put(facts,param,p113k_exact(lo,hi)))
    case N111Local{name}: nt_choose(Maybe<&2,KDef>,agy_str_eq(name,param),
      u => x198a_back(ps,vs,fuel,pred,bindings,facts),u => None{})
    case _: None{}

@unsafe
def x198a_eval(prefix: List<&2,P113DStmt>, +condition: N111Value, +truth: Bool,
    +loop: X198ACountdown, +facts: KDef) -> Bool:
  match prefix loop:
    case Nil{} X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_truth(x198a_fact(condition,facts,ids),truth)
    case Con{P113DScalar{N111Bin{+name,+typ,+op,l,r}},rest} X198ACountdown{params,fuel,pred,buffer,+ids}:
      +left = x198a_fact(l,facts,ids)
      +right = x198a_fact(r,facts,ids)
      x198a_free(name,loop) && x190_branch_width(typ) && x198a_exact(left) && x198a_exact(right) &&
        x198a_op(op,right,typ) && x198a_eval(rest,condition,truth,loop,
          p113k_put(facts,name,p113k_bin_fact(typ,op,left,right)))
    case _ _: False{}

@unsafe
def x198a_cert(facts: Maybe<&2,KDef>, prefix: List<&2,P113DStmt>, condition: N111Value,
    truth: Bool, loop: X198ACountdown) -> Bool:
  match facts:
    case Some{table}: x198a_eval(prefix,condition,truth,loop,table)
    case None{}: False{}

def x198_sym_bind(+env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"X198Token",token,0)

def x198_sym_assign(name: String, +t: U32, state: X198Sym) -> X198Sym:
  match state:
    case X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_gt(t,0),u => X198Sym{x198_sym_bind(env,name,t),ctor,taken,made,s0,s1},u => X198Refuse{})
    case _: X198Refuse{}

def x198_sym_bin(name: String, +op: String, +x: U32, y: N111Value, +s: X198Sym) -> X198Sym:
  match y s:
    case N111Const{40,0} _:
      nt_choose(X198Sym,p88_string_eq(op,"shr") && x198_sym_range(x,1,2),u => x198_sym_assign(name,U32.add(10,x),s),u => X198Refuse{})
    case N111Const{65535,0} _:
      nt_choose(X198Sym,p88_string_eq(op,"and") && x198_sym_range(x,11,12),u => x198_sym_assign(name,U32.add(10,x),s),u => X198Refuse{})
    case N111CtorId{+c} X198Sym{env,+ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,p88_string_eq(op,"eq") && x198_sym_range(x,21,22) && Bool.not(String.is_empty(c)) &&
          (String.is_empty(ctor) || p88_string_eq(ctor,c)),
        u => X198Sym{x198_sym_bind(env,name,U32.add(10,x)),c,taken,made,s0,s1},u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_sym_op(+name: String, +fun: String, arg: N111Arg, +s: X198Sym) -> X198Sym:
  match arg s:
    case N111Arg{N111U64{},word} X198Sym{+env,ctor,+taken,made,s0,s1}:
      +id = x198_sym_get(word,env)
      nt_choose(X198Sym,p88_string_eq(fun,"p125_rt_take2") && x198_sym_range(id,1,2) && U32.is_eq(U32.and(taken,id),0),
        u => X198Sym{x198_sym_bind(env,name,9),ctor,U32.or(taken,id),made,U32.inc(U32.mul(2,id)),U32.add(2,U32.mul(2,id))},
        u => X198Refuse{})
    case N111Arg{N111U32{},N111CtorId{c}} X198Sym{env,+ctor,taken,+made,+s0,+s1}:
      +v = x198_sym_node(s0,s1)
      nt_choose(X198Sym,p88_string_eq(fun,"p125_rt_ctor2") && Bool.not(String.is_empty(ctor)) && p88_string_eq(ctor,c) &&
          U32.is_lt(made,3) && U32.is_gt(v,0),
        u => X198Sym{x198_sym_bind(env,name,v),ctor,taken,U32.inc(made),s0,s1},u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_sym_call(+name: String, +fun: String, args: List<&2,N111Arg>, +s: X198Sym) -> X198Sym:
  match args s:
    case Con{N111Arg{N111Ptr{},sv},Con{av,Con{N111Arg{N111Ptr{},buf},Nil{}}}} X198Sym{+env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(sv,env),7) && U32.is_eq(x198_sym_get(buf,env),8),
        u => x198_sym_op(name,fun,av,s),u => X198Refuse{})
    case _ _: X198Refuse{}

@unsafe
def x198n_exact_bin(typ: N111Type, op: String, left: X198NFact, right: X198NFact) -> X198NFact:
  match left right:
    case X198NConst{a,b} X198NConst{c,d}: x198n_constant(p113k_bin_fact(typ,op,p113k_exact(a,b),p113k_exact(c,d)))
    case _ _: X198NUnknown{}

# Only trap-free integer operations may be discarded by this certificate.
@unsafe
def x198n_bin(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact) -> X198NFact:
  nt_choose(X198NFact,agy_str_eq(op,"or") && (x198n_nonzero(left) || x198n_nonzero(right)),u =>
    nt_choose(X198NFact,x198n_equal(left,right),v => x198n_width(left,typ),v => X198NNonzero{x198n_low_nonzero(left) || x198n_low_nonzero(right)}),u =>
  nt_choose(X198NFact,(agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) &&
    ((x198n_zero(left) && x198n_nonzero(right)) || (x198n_zero(right) && x198n_nonzero(left))),u =>
      X198NConst{nt_choose(U32,agy_str_eq(op,"ne"),v => 1,v => 0),0},u =>
  nt_choose(X198NFact,x198n_zero(right) && (agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"shl") || agy_str_eq(op,"shr") || agy_str_eq(op,"sar")),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,x198n_zero(left) && (agy_str_eq(op,"add") || agy_str_eq(op,"or") || agy_str_eq(op,"xor")),u => x198n_width(right,typ),u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && (x198n_zero(left) || x198n_zero(right)),u => X198NConst{0,0},u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && x198n_one(right),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && x198n_one(left),u => x198n_width(right,typ),u =>
    x198n_exact_bin(typ,op,left,right))))))))

@unsafe
def x192h_case(item: P114HCase, +index: U32, params: List<&2,String>) -> List<&2,P113DStmt>:
  match item:
    case P114HCase{name,captures,result,pop,body}:
      nt_append(P113DStmt,x192h_case_prefix(captures,result,pop,index),
        x192h_body(p114h_rename(body,p114h_prefix(index)),params,p112f_name(p114h_prefix(index),"scratch")))

@unsafe
def x192h_dispatch(cases: List<&2,P114HCase>, +index: U32, +params: List<&2,String>) -> List<&2,P113DStmt>:
  match cases:
    case Nil{}:
      [x192h_stack("p111_rt_fail","p114h_bad",4),P113DResult{[x192h_v("p114h_bad")]}]
    case Con{+head,rest}:
      match head:
        case P114HCase{name,captures,result,pop,body}:
          [P113DScalar{N111Bin{"p114h_test",N111U64{},"eq",x192h_v("p114h_fid"),N111FuncId{name}}},
           P113DIf{x192h_v("p114h_test"),x192h_case(head,index,params),x192h_dispatch(rest,U32.inc(index),params)}]

@unsafe
def x192h_unwind(cases: List<&2,P114HCase>, params: List<&2,String>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p114r_pending",N111U64{},"ne",x192h_v("p114r_depth"),x192h_c(0)}},
   P113DIf{x192h_v("p114r_pending"),
     Con{P113DScalar{N111Bin{"p114r_depth",N111U64{},"sub",x192h_v("p114r_depth"),x192h_c(1)}},
     Con{x192h_stack("p111_rt_stack_pop","p114h_popped",1),
     Con{x192h_stack("p111_rt_stack_get","p114h_fid",0),x192h_dispatch(cases,0,params)}}},
     [P113DResult{[x192h_v("p114r_value")]}]}]

def x198pw_put(+map: KDef,+role: String,name: String) -> KDef:
  index_set(map,KDef{role,"X198PWName",0,0,kt("Name",name,0,0,[]),atom("Absent"),[],False{},False{}},
    index_hash(role,2166136261),32)

def x198pw_role(+role: String,+value: String,+state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +old = x198pw_name(roles,role)
      nt_choose(X198PWState,String.is_empty(value),u => X198PWBad{},u =>
        nt_choose(X198PWState,String.is_empty(old),v => X198PWState{x198pw_put(roles,role,value),vars},
          v => nt_choose(X198PWState,p88_string_eq(old,value),w => state,w => X198PWBad{})))
    case X198PWBad{}: X198PWBad{}

law x198pw_match:
  for +p: X198PWPattern
  for +term: KTerm
  for +state: X198PWState
  X198PWState

@unsafe
def x198pw_seq(patterns: List<&2,X198PWPattern>, terms: List<&2,KTerm>, +state: X198PWState) -> X198PWState:
  match patterns terms state:
    case Nil{} Nil{} _: state
    case Con{p,ps} Con{t,ts} X198PWState{roles,vars}: x198pw_seq(ps,ts,x198pw_match(p,t,state))
    case _ _ _: X198PWBad{}

@unsafe
def x198pw_call_match(role: String,ps: List<&2,X198PWPattern>,chain: KPChain,s: X198PWState) -> X198PWState:
  match chain:
    case KPChain{args,+head}:
      nt_choose(X198PWState,agy_str_eq(tg(head),"Ref") && List.is_empty(&2,KTerm,ks(head)),
        u => x198pw_seq(ps,args,x198pw_role(role,nm(head),s)),u => X198PWBad{})

@unsafe
def x198pw_two_bind(+a: KTerm,+b: KTerm,body: KTerm,pa: X198PWPattern,pb: X198PWPattern,pbody: X198PWPattern,s: X198PWState) -> X198PWState:
  nt_choose(X198PWState,agy_str_eq(tg(a),"Bind") && agy_str_eq(tg(b),"Bind") &&
      U32.is_eq(terms_len(ks(a)),1) && U32.is_eq(terms_len(ks(b)),1),
    u => x198pw_match(pbody,body,x198pw_bind("res1",ix(b),
      x198pw_match(pb,kid(b,0),x198pw_bind("res0",ix(a),x198pw_match(pa,kid(a,0),s))))),
    u => X198PWBad{})

@unsafe
def x198pw_match_term(p: X198PWPattern,+t: KTerm,+state: X198PWState) -> X198PWState:
  match p state:
    case X198PWCase{role,body} X198PWState{roles,vars}:
      x198pw_match(body,x198pw_arm(t,x198pw_name(roles,role),8),state)
    case X198PWLam{slot,body} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Lam") && U32.is_eq(terms_len(ks(t)),1) && U32.is_gt(qt(t),0),
        u => x198pw_match(body,kid(t,0),x198pw_bind(slot,ix(t),state)),u => X198PWBad{})
    case X198PWVar{slot} X198PWState{roles,vars}:
      +v = p111v_get(vars,slot)
      nt_choose(X198PWState,agy_str_eq(tg(t),"Var") && agy_str_eq(dk(v),"X198PWVar") && U32.is_eq(ix(t),da(v)),
        u => state,u => X198PWBad{})
    case X198PWCall{role,args} X198PWState{roles,vars}: x198pw_call_match(role,args,x198pw_spine(t,[],4),state)
    case X198PWCtr{+role,fields} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Ctr") && agy_str_eq(nm(t),x198pw_name(roles,role)),
        u => x198pw_seq(fields,ks(t),state),u => X198PWBad{})
    case X198PWLet2{pa,pb,pr} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Let") && U32.is_eq(terms_len(ks(t)),3),
        u => x198pw_two_bind(kid(t,0),kid(t,1),kid(t,2),pa,pb,pr,state),u => X198PWBad{})
    case _ _: X198PWBad{}

@unsafe
def x198pw_match(p,term,state):
  x198pw_match_term(p,nc_unann(term),state)

@unsafe
def x198pw_intrinsic(+book: List<&2,KDef>,+roles: KDef, role: String, code: String) -> Bool:
  +d = lookup(book,x198pw_name(roles,role))
  nc_native_def(d) && U32.is_eq(da(d),2) && agy_str_eq(nc_primitive_name(dn(d)),code)

@unsafe
def x198pw_validate_data(+book: List<&2,KDef>,+ty: String,+d: KDef,plan: X198PWPlan) -> X198PWPlan:
  match plan:
    case X198PWNone{}: X198PWNone{}
    case X198PWPlan{+owner,+leaf,+node}:
      +a = nm(nc_unann(dv(d)))
      +b = nm(nc_unann(kid(nc_unann(dv(d)),1)))
      nt_choose(X198PWPlan,(agy_str_eq(nc_ctor_identity(book,a),leaf) && x198pw_data(book,ty,a,b)) ||
          (agy_str_eq(nc_ctor_identity(book,b),leaf) && x198pw_data(book,ty,b,a)),
        u => X198PWPlan{owner,leaf,node},u => X198PWNone{})

@unsafe
def x198pw_mark(plans: List<&2,X198PWPlan>,ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{X198PWPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = x198pw_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"X198PWCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      x198pw_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def x198pw_context(+plans: List<&2,X198PWPlan>,ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{x198pw_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def x198pw_cursor(+plans: List<&2,X198PWPlan>,cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case p: p

law agy_zip_match:
  for +p: AgyZipPat
  for +term: KTerm
  for +state: X198PWState
  X198PWState

@unsafe
def agy_zip_seq(ps: List<&2,AgyZipPat>, ts: List<&2,KTerm>, +s: X198PWState) -> X198PWState:
  match ps ts s:
    case Nil{} Nil{} _: s
    case Con{p,pr} Con{t,tr} X198PWState{roles,vars}: agy_zip_seq(pr,tr,agy_zip_match(p,t,s))
    case _ _ _: X198PWBad{}

@unsafe
def agy_zip_call_m(role: String, ps: List<&2,AgyZipPat>, chain: KPChain, s: X198PWState) -> X198PWState:
  match chain:
    case KPChain{args,+head}:
      nt_choose(X198PWState,agy_str_eq(tg(head),"Ref") && List.is_empty(&2,KTerm,ks(head)),
        u => agy_zip_seq(ps,args,x198pw_role(role,nm(head),s)),u => X198PWBad{})

@unsafe
def agy_zip_let1_m(slot: String, pv: AgyZipPat, pb: AgyZipPat, +b: KTerm, body: KTerm, s: X198PWState) -> X198PWState:
  nt_choose(X198PWState,agy_str_eq(tg(b),"Bind") && U32.is_eq(terms_len(ks(b)),1),
    u => agy_zip_match(pb,body,x198pw_bind(slot,ix(b),agy_zip_match(pv,kid(b,0),s))),
    u => X198PWBad{})

@unsafe
def agy_zip_match_t(p: AgyZipPat, +t: KTerm, +s: X198PWState) -> X198PWState:
  match p s:
    case AgyZCase{+role,body} X198PWState{+roles,vars}:
      +expected = x198pw_name(roles,role)
      nt_choose(X198PWState,String.is_empty(expected),
        u => nt_choose(X198PWState,agy_str_eq(tg(t),"Mat") && U32.is_eq(terms_len(ks(t)),2),
          v => agy_zip_match(body,kid(t,0),x198pw_role(role,nm(t),s)),
          v => X198PWBad{}),
        u => agy_zip_match(body,x198pw_arm(t,expected,8),s))
    case AgyZLam{slot,body} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Lam") && U32.is_eq(terms_len(ks(t)),1) && U32.is_gt(qt(t),0),
        u => agy_zip_match(body,kid(t,0),x198pw_bind(slot,ix(t),s)),u => X198PWBad{})
    case AgyZVar{slot} X198PWState{roles,vars}:
      +v = p111v_get(vars,slot)
      nt_choose(X198PWState,agy_str_eq(tg(t),"Var") && agy_str_eq(dk(v),"X198PWVar") && U32.is_eq(ix(t),da(v)),
        u => s,u => X198PWBad{})
    case AgyZCall{role,args} X198PWState{roles,vars}:
      agy_zip_call_m(role,args,x198pw_spine(t,[],8),s)
    case AgyZCtr{+role,fields} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Ctr") && U32.is_eq(terms_len(ks(t)),nt_count(AgyZipPat,fields)),
        u => agy_zip_seq(fields,ks(t),x198pw_role(role,nm(t),s)),u => X198PWBad{})
    case AgyZLet1{slot,pv,pb} X198PWState{roles,vars}:
      nt_choose(X198PWState,agy_str_eq(tg(t),"Let") && U32.is_eq(terms_len(ks(t)),2),
        u => agy_zip_let1_m(slot,pv,pb,kid(t,0),kid(t,1),s),u => X198PWBad{})
    case _ _: X198PWBad{}

@unsafe
def agy_zip_match(p,term,state):
  agy_zip_match_t(p,nc_unann(term),state)

@unsafe
def w4c_zip_set(plans: List<&2,AgyZipPlan>, +acc: KDef) -> KDef:
  match plans:
    case Nil{}: acc
    case Con{AgyZipPlan{+owner,_,_},rest}:
      +k = "$direct." ++ owner
      +e : KDef = KDef{k,"P113Direct",0,0,kt("Type","",0,0,[]),kt("Type","",0,0,[]),[],False{},False{}}
      w4c_zip_set(rest,index_set(acc,e,index_hash(k,2166136261),32))
    case Con{_,rest}: w4c_zip_set(rest,acc)

@unsafe
def agy_zip_mark(plans: List<&2,AgyZipPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyZipPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = agy_zip_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"AgyZipCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      agy_zip_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_zip_context(+plans: List<&2,AgyZipPlan>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_zip_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_zip_cursor(+plans: List<&2,AgyZipPlan>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case p: p

law agy_ro_parse_expr:
  for +book: List<&2,KDef>
  for +owner: String
  for +t: KTerm
  for +f0_id: U32
  for +f0_k: U32
  for +f1_id: U32
  for +f1_k: U32
  for +x_id: U32
  for +has_x: Bool
  for +fuel: U32
  Maybe<&2,KTerm>

@unsafe
def agy_ro_parse_bin_l(+book: List<&2,KDef>, +owner: String, +op: String, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32,
    ra: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match ra:
    case None{}: None{}
    case Some{ea}:
      agy_ro_parse_bin_r(op,ea,agy_ro_parse_expr(book,owner,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_bin(+book: List<&2,KDef>, +owner: String, +op: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  agy_ro_parse_bin_l(book,owner,op,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel,
    agy_ro_parse_expr(book,owner,a,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_prim(+book: List<&2,KDef>, +owner: String, +fn_name: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  +d = lookup(book,fn_name)
  +op = agy_ro_prim_op(nc_primitive_name(dn(d)))
  nt_choose(Maybe<&2,KTerm>,nc_native_def(d) && U32.is_eq(da(d),2) && Bool.not(String.is_empty(op)),
    u => agy_ro_parse_bin(book,owner,op,a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel),
    u => None{})

@unsafe
def agy_ro_parse_app(+book: List<&2,KDef>, +owner: String, spine: KPChain,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  match spine:
    case KPChain{Con{+a,Nil{}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,Bool.not(has_x) && agy_str_eq(tg(hu),"Ref") && agy_str_eq(nm(hu),owner),
        u => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
          v => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
          v => None{}),
        u => None{})
    case KPChain{Con{+a,Con{+b,Nil{}}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(hu),"Ref"),
        u => nt_choose(Maybe<&2,KTerm>,has_x && agy_str_eq(nm(hu),owner) && agy_ro_is_x(b,x_id,has_x),
          v => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
            w => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
            w => None{}),
          v => agy_ro_parse_prim(book,owner,nm(hu),a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel)),
        u => None{})
    case _: None{}

@unsafe
def agy_ro_parse_expr(book,owner,t,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel):
  +u = nc_unann(t)
  nt_choose(Maybe<&2,KTerm>,U32.is_eq(fuel,0),u0 => None{},u0 =>
    nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"Lit") && agy_str_eq(nm(u),"U32"),
      u1 => Some{kt("RoConst","",kl_number(u),0,[])},u1 =>
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"Var"),
        u2 => agy_ro_lookup_var(ix(u),f0_id,f0_k,f1_id,f1_k,x_id,has_x),u2 =>
        nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"App"),
          u3 => agy_ro_parse_app(book,owner,x198pw_spine(u,[],4),f0_id,f0_k,f1_id,f1_k,x_id,has_x,U32.sub(fuel,1)),
          u3 => None{}))))

@unsafe
def agy_ro_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_ro_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_ro_context(+entries: List<&2,KDef>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_ro_mark(entries,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_ro_cursor(+entries: List<&2,KDef>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case p: p

@unsafe
def agy_fl_mark(plans: List<&2,AgyFlowPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyFlowPlan{owner,leaf,node,warp,wn},rest} N111Ids{+fs,cs}:
      +key = agy_fl_key("$direct." ++ owner)
      +c0 : KDef = KDef{"w","Name",0,0,kt("Name",warp,0,0,[]),kt("Name",wn,0,0,[]),[],False{},False{}}
      +entry : KDef = KDef{key,"AgyFlowCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[c0],False{},False{}}
      agy_fl_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_fl_context(+plans: List<&2,AgyFlowPlan>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_fl_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_fl_cursor(+plans: List<&2,AgyFlowPlan>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case p: p

@unsafe
def x181_cursor_index(cursor: P134Cursor, index: KDef) -> KDef:
  match cursor:
    case P134Private{functions,P134Context{ids,fusion,direct,ready,view,lookups,heap,mode},next}:
      x181_cursor_index(next,x181_forward_index(functions,ready,index))
    case P134Legacy{entries,context,next}: x181_cursor_index(next,index)
    case P134Public{segments,context,next}: x181_cursor_index(next,index)
    case _: index

@unsafe
def x199s_seed(fuel: String, index: String, array: String, carry: String) -> KDef:
  x199s_put(x199s_put(x199s_put(x199s_put(x199s_put(x199s_put(missing(),
    fuel,1),index,2),array,3),carry,4),p117h_name(3,"base"),5),p117h_name(3,"mask"),6)

@unsafe
def x199s_bound(+name: String, +token: U32, params: List<&2,String>, state: X199ScanState) -> Maybe<&2,X199ScanState>:
  match state:
    case X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_gt(token,0) && x199s_free(name,params),
        u => Some{X199ScanState{x199s_put(env,name,token),loads,stores}},u => None{})

@unsafe
def x199s_scalar(stmt: N111Stmt, params: List<&2,String>, +state: X199ScanState) -> Maybe<&2,X199ScanState>:
  match stmt state:
    case N111Set{name,N111U64{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_token(value,env),params,state)
    case N111Set{name,N111U32{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_narrow(x199s_token(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_bin(typ,op,x199s_token(left,env),x199s_token(right,env)),params,state)
    case N111Offset{name,base,bytes} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),5) && U32.is_eq(x199s_token(bytes,env),14),
        u => x199s_bound(name,15,params,state),u => None{})
    case N111Load{name,N111U32{},base,offset} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(loads,0) && U32.is_eq(stores,0),
        u => x199s_bound(name,16,params,X199ScanState{env,1,0}),u => None{})
    case N111Store{N111U32{},base,offset,value} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(x199s_token(value,env),19) && U32.is_eq(loads,1) && U32.is_eq(stores,0),
        u => Some{X199ScanState{env,1,1}},u => None{})
    case _ _: None{}

@unsafe
def agy_dp_seed(fuel: String, idx: String, ai: String) -> KDef:
  agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(agy_dp_put(
    agy_dp_put(agy_dp_put(agy_dp_put(missing(),
      fuel,1),idx,2),ai,3),
    p117h_name(5,"base"),4),p117h_name(5,"mask"),5),
    p117h_name(6,"base"),6),p117h_name(6,"mask"),7),
    p117h_name(7,"base"),8),p117h_name(7,"mask"),9)

@unsafe
def agy_dp_bound(+name: String, +token: U32, params: List<&2,String>, state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match state:
    case AgyDpState{+env,+stores}:
      nt_choose(Maybe<&2,AgyDpState>,U32.is_gt(token,0) && agy_dp_free(name,params),
        u => Some{AgyDpState{agy_dp_put(env,name,token),stores}},u => None{})

@unsafe
def agy_dp_scalar(stmt: N111Stmt, params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match stmt state:
    case N111Set{name,N111U64{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_tok(value,env),params,state)
    case N111Set{name,N111U32{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_narrow(agy_dp_tok(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_bin(typ,op,agy_dp_tok(left,env),agy_dp_tok(right,env)),params,state)
    case N111Offset{name,base,bytes} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +yt = agy_dp_tok(bytes,env)
      +tok = nt_choose(U32,U32.is_eq(bt,4) && U32.is_eq(yt,15),u => 16,u =>
        nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,22),v => 23,v =>
          nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,26),w => 27,w =>
            nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,30),z => 31,z =>
              nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,41),q => 42,q => 0)))))
      agy_dp_bound(name,tok,params,state)
    case N111Load{name,N111U32{},base,offset} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +tok = nt_choose(U32,U32.is_eq(offset,0) && U32.is_eq(stores,0),u =>
        nt_choose(U32,U32.is_eq(bt,16),v => 17,v =>
          nt_choose(U32,U32.is_eq(bt,23),w => 24,w =>
            nt_choose(U32,U32.is_eq(bt,27),z => 28,z =>
              nt_choose(U32,U32.is_eq(bt,31),q => 32,q => 0)))),u => 0)
      agy_dp_bound(name,tok,params,state)
    case N111Store{N111U32{},base,offset,value} AgyDpState{+env,+stores}:
      nt_choose(Maybe<&2,AgyDpState>,U32.is_eq(agy_dp_tok(base,env),42) && U32.is_eq(offset,0) &&
          U32.is_eq(agy_dp_tok(value,env),39) && U32.is_eq(stores,0),
        u => Some{AgyDpState{env,1}},u => None{})
    case _ _: None{}

@unsafe
def agy_dp_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match yes no state:
    # Skip empty no-op diamonds left by predicate pass
    case Nil{} Nil{} _: Some{state}
    # Select diamond: if cond: dst = yv else: dst = nv
    case Con{P113DScalar{N111Set{+yn,N111U64{},yv}},Nil{}}
         Con{P113DScalar{N111Set{+nn,N111U64{},nv}},Nil{}}
         AgyDpState{+env,+stores}:
      +ct = agy_dp_tok(cond,env)
      +yt = agy_dp_tok(yv,env)
      +nt = agy_dp_tok(nv,env)
      +tok = nt_choose(U32,agy_str_eq(yn,nn),u =>
        nt_choose(U32,(U32.is_eq(ct,19) && U32.is_eq(yt,50) && U32.is_eq(nt,51)) ||
            (U32.is_eq(ct,18) && U32.is_eq(yt,51) && U32.is_eq(nt,50)),v => 20,v =>
          nt_choose(U32,U32.is_eq(ct,35) && U32.is_eq(yt,33) && U32.is_eq(nt,34),w => 36,w =>
            nt_choose(U32,U32.is_eq(ct,38) && U32.is_eq(yt,36) && U32.is_eq(nt,37),z => 39,z => 0))),u => 0)
      agy_dp_bound(yn,tok,params,state)
    case _ _ _: None{}

@unsafe
def agy_f32_put(env: KDef, +name: String, kind: String, expr: KTerm) -> KDef:
  +entry : KDef = KDef{name,kind,0,0,kt("None","",0,0,[]),expr,[],False{},False{}}
  index_set(env,entry,index_hash(name,2166136261),32)

@unsafe
def agy_f32_call_fbin2(+dst: String, +sse: String, r0: Maybe<&2,KTerm>, r1: Maybe<&2,KTerm>,
    params: List<&2,String>, +env: KDef, +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0 r1:
    case Some{e0} Some{e1}:
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"F32Expr",kt("FBin",sse,0,0,[e0,e1])),None{},None{},obs,has_obs}},
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_call_fbin(+dst: String, +sse: String, s0: Maybe<&2,N111Value>, s8: Maybe<&2,N111Value>,
    params: List<&2,String>, +env: KDef, +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match s0 s8:
    case Some{v0} Some{v1}:
      agy_f32_call_fbin2(dst,sse,agy_f32_val_f(v0,env),agy_f32_val_f(v1,env),params,env,obs,has_obs)
    case _ _: None{}

@unsafe
def agy_f32_call_tou32_2(+dst: String, r0: Maybe<&2,KTerm>, params: List<&2,String>,
    +env: KDef, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0:
    case Some{e0}:
      nt_choose(Maybe<&2,AgyF32State>,Bool.not(has_obs) && agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"U32Expr",kt("UObs","",0,0,[])),None{},None{},Some{e0},True{}}},
        u => None{})
    case None{}: None{}

@unsafe
def agy_f32_call_tou32(+dst: String, s0: Maybe<&2,N111Value>, params: List<&2,String>,
    +env: KDef, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match s0:
    case Some{v0}:
      agy_f32_call_tou32_2(dst,agy_f32_val_f(v0,env),params,env,has_obs)
    case None{}: None{}

@unsafe
def agy_f32_bin_u(+dst: String, +alu: String, r0: Maybe<&2,KTerm>, r1: Maybe<&2,KTerm>,
    params: List<&2,String>, +env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>,
    +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match r0 r1:
    case Some{e0} Some{e1}:
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"U32Expr",kt("UBin",alu,0,0,[e0,e1])),s0,s8,obs,has_obs}},
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_set_copy(+dst: String, +val: N111Value, params: List<&2,String>,
    +env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>,
    +obs: Maybe<&2,KTerm>, +has_obs: Bool) -> Maybe<&2,AgyF32State>:
  match val:
    case N111Local{src}:
      +d = agy_f32_get(env,src)
      nt_choose(Maybe<&2,AgyF32State>,agy_f32_free(dst,params) &&
          (agy_str_eq(dk(d),"F32Expr") || agy_str_eq(dk(d),"U32Expr")),
        u => Some{AgyF32State{agy_f32_put(env,dst,dk(d),dv(d)),s0,s8,obs,has_obs}},
        u => None{})
    case _: None{}

@unsafe
def agy_f32_seed(fuel: String, x: String, h: String) -> KDef:
  agy_f32_put(agy_f32_put(agy_f32_put(missing(),
    fuel,"Fuel",kt("None","",0,0,[])),
    x,"F32Expr",kt("FVarX","",0,0,[])),
    h,"U32Expr",kt("UVarH","",0,0,[]))

@unsafe
def agy_da_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_da_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_da_context(+entries: List<&2,KDef>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_da_mark(entries,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_da_cursor(+entries: List<&2,KDef>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case p: p

@unsafe
def agy_bp_mark_ids(ids: N111Ids, +key: String) -> N111Ids:
  match ids:
    case N111Ids{+fs,cs}:
      +entry : KDef = KDef{key,"AgyBasePinned",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
      N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}

@unsafe
def agy_bp_ctx(ctx: P134Context, +map_ok: Bool, +arr_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +ids1 = nt_choose(N111Ids,map_ok,u => agy_bp_mark_ids(ids,"$agy.bp/map"),u => ids)
      +ids2 = nt_choose(N111Ids,arr_ok,u => agy_bp_mark_ids(ids1,"$agy.bp/arr"),u => ids1)
      P134Context{ids2,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_bp_cursor(cursor: P134Cursor, +map_ok: Bool, +arr_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}
    case P134Public{ss,c,next}: P134Public{ss,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}
    case p: p

@unsafe
def agy_sh_ctx(ctx: P134Context, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +i1 = nt_choose(N111Ids,eq_go_ok,u => agy_bp_mark_ids(ids,"$agy.sh/eq_go"),u => ids)
      +i2 = nt_choose(N111Ids,eq_ok,u => agy_bp_mark_ids(i1,"$agy.sh/eq"),u => i1)
      +i3 = nt_choose(N111Ids,agy_eq_ok,u => agy_bp_mark_ids(i2,"$agy.sh/agy_eq"),u => i2)
      +i4 = nt_choose(N111Ids,base_eq_ok,u => agy_bp_mark_ids(i3,"$agy.sh/base_eq"),u => i3)
      +i5 = nt_choose(N111Ids,hash_ok,u => agy_bp_mark_ids(i4,"$agy.sh/hash"),u => i4)
      +i6 = nt_choose(N111Ids,tageq_ok,u => agy_bp_mark_ids(i5,"$agy.sh/tageq"),u => i5)
      +i7 = nt_choose(N111Ids,tageq_read_ok,u => agy_bp_mark_ids(i6,"$agy.sh/tageq_read"),u => i6)
      P134Context{i7,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_sh_cursor(cursor: P134Cursor, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Public{ss,c,next}: P134Public{ss,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case p: p

@unsafe
def agy_map_mark_one(ids: N111Ids, +name: String, +kind: String) -> N111Ids:
  match ids:
    case N111Ids{+fs,cs}:
      +key = agy_map_key(name)
      +entry : KDef = KDef{key,kind,0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
      N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}

def agy_map_context(ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_map_mark_one(agy_map_mark_one(agy_map_mark_one(ids,
          "$direct.Map.set","AgyMapSet"),"$direct.Map.del","AgyMapDel"),"$direct.Map.get","AgyMapGet"),
        idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_map_cursor(cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_map_context(c),agy_map_cursor(next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_map_context(c),agy_map_cursor(next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_map_context(c),agy_map_cursor(next)}
    case p: p

law x187_elf_symbols_step:
  for +head: X187Symbol
  for +rest: List<&2,X187Symbol>
  for +globals: Bool
  for +sizes: X187ElfSizes
  for +state: X187ElfSymbols
  X187ElfSymbols
@unsafe
def x187_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}
      X187ElfSymbols{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}:
      w7c_elf_sym_add_ascii(name,section,value,size,global,kind,sizes,index,count,firstGlobal,table,strings,stringSize,error,
        w7c_elf_ascii_valid(name,strings,0))

@unsafe
def x187_elf_symbols(items: List<&2,X187Symbol>, +globals: Bool, +sizes: X187ElfSizes,
    +state: X187ElfSymbols) -> X187ElfSymbols:
  match items:
    case Nil{}: state
    case Con{+head,rest}:
      x187_elf_symbols_step(head,rest,globals,sizes,state)

@unsafe
def x187_elf_symbols_step(head, rest, globals, sizes, state):
  match head:
    case X187Symbol{name,section,value,size,+global,kind}:
      x187_elf_symbols(rest,globals,sizes,
        nt_choose(X187ElfSymbols,(global && globals) || (Bool.not(global) && Bool.not(globals)),
          u => x187_elf_symbol_add(head,sizes,state),u => state))

@unsafe
def x187_build_name(+name: String, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,+symbols,names,relocs,error}:
      nt_choose(X187Build,agy_str_eq(dk(p111v_get(symbols,name)),"Absent"),
        u => X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",0,0,KTerm{"","",0,0,[],[],0,0},atom("Absent"),[],False{},False{}},
          index_hash(name,2166136261),32),Con{name,names},relocs,error},u => build)

@unsafe
def x187_build_symbol_known(+name: String, +mode: U32, +value: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+s,t,r,d,ts,rs,ds,+symbols,names,relocs,error}:
      x187_build_symbol_update(name,mode,value,build,p111v_get(symbols,name))

@unsafe
def x187_build_symbol_update(+name: String, +mode: U32, +value: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build old:
    case X187Build{+s,t,r,d,ts,rs,ds,symbols,names,relocs,error}
      KDef{on,ok,+section,+offset,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},ov,oc,+global,+defined}:
      nt_choose(X187Build,(U32.is_eq(mode,1) && defined) ||
          (U32.is_eq(mode,4) && (Bool.not(defined) || Bool.not(U32.is_eq(s,section)) || U32.is_lt(x187_build_offset(build),offset))),
        u => x187_build_error("duplicate symbol or invalid size: " ++ name,build),u =>
        X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",nt_choose(U32,U32.is_eq(mode,1),v => s,v => section),
            nt_choose(U32,U32.is_eq(mode,1),v => x187_build_offset(build),v => offset),
            KTerm{"","",nt_choose(U32,U32.is_eq(mode,4),v => U32.sub(x187_build_offset(build),offset),v => size),
              nt_choose(U32,U32.is_eq(mode,3),v => value,v => kind),[],[],0,0},atom("Absent"),[],
            global || U32.is_eq(mode,2),defined || U32.is_eq(mode,1)},index_hash(name,2166136261),32),names,relocs,error})
    case _ _: x187_build_error("invalid object symbol record",build)

@unsafe
def x201s_update(+hash: U32, +name: String, +mode: U32, +value: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build old:
    case X187Build{+s,t,r,d,ts,rs,ds,symbols,names,relocs,error}
      KDef{on,ok,+section,+offset,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},ov,oc,+global,+defined}:
      nt_choose(X187Build,(U32.is_eq(mode,1) && defined) ||
          (U32.is_eq(mode,4) && (Bool.not(defined) || Bool.not(U32.is_eq(s,section)) || U32.is_lt(x187_build_offset(build),offset))),
        u => x187_build_error("duplicate symbol or invalid size: " ++ name,build),u =>
        X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",nt_choose(U32,U32.is_eq(mode,1),v => s,v => section),
            nt_choose(U32,U32.is_eq(mode,1),v => x187_build_offset(build),v => offset),
            KTerm{"","",nt_choose(U32,U32.is_eq(mode,4),v => U32.sub(x187_build_offset(build),offset),v => size),
              nt_choose(U32,U32.is_eq(mode,3),v => value,v => kind),[],[],0,0},atom("Absent"),[],
            global || U32.is_eq(mode,2),defined || U32.is_eq(mode,1)},hash,32),names,relocs,error})
    case _ _: x187_build_error("invalid object symbol record",build)


@unsafe
def x201s_found(+name: String, +mode: U32, +value: U32, +hash: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,agy_str_eq(dk(old),"Absent"),u =>
        nt_choose(X187Build,U32.is_eq(mode,4),v =>
          x187_build_symbol_known(name,mode,value,x187_build_name(name,build)),v =>
          x201s_update(hash,name,mode,value,X187Build{s,t,r,d,ts,rs,ds,symbols,Con{name,names},relocs,error},
            KDef{name,"X187Sym",0,0,KTerm{"","",0,0,[],[],0,0},atom("Absent"),[],False{},False{}})),
        u => x201s_update(hash,name,mode,value,build,old))

@unsafe
def x187_build_relocation(+reloc: X187Relocation, +build: X187Build) -> X187Build:
  match reloc:
    case X187Relocation{s,o,k,name,lo,hi}: x187_build_relocation_known(reloc,x187_build_name(name,build))

@unsafe
def x187_build_relocations(+relocs: List<&2,X187Relocation>, +build: X187Build) -> X187Build:
  match relocs:
    case Nil{}: build
    case Con{head,rest}: x187_build_relocations(rest,x187_build_relocation(head,build))

@unsafe
def x187_build_datum(datum: P111QDatum, +build: X187Build) -> X187Build:
  match datum:
    case P111QByte{+value}:
      nt_choose(X187Build,U32.is_le(value,255),u => x187_build_bytes([value],build),
        u => x187_build_error("data width overflow",build))
    case P111QWord{value}: x187_build_bytes(x187_elf_u32(value),build)
    case P111QLong{lo,hi}: x187_build_bytes(x187_elf_u64(lo,hi),build)
    case P111QReloc{name,offset}:
      x187_build_bytes([0,0,0,0,0,0,0,0],x187_build_relocation(
        X187Relocation{x187_build_section(build),x187_build_offset(build),1,name,offset,0},build))
    case P111QZeros{+count}:
      nt_choose(X187Build,U32.is_gt(count,8388608),
        u => x187_build_error("zero directive exceeds 8MiB",build),u =>
        nt_choose(X187Build,U32.is_gt(x187_build_offset(build),U32.sub(134217728,count)),
          v => x187_build_error("x86 object section exceeds 128 MiB bound",build),
          v => x187_build_bytes(x187_build_fill(count,0,[]),build)))

@unsafe
def x188_fixup_symbol(+reloc: X187Relocation, +size: U32, +state: X188Fixups, symbol: KDef) -> X188Fixups:
  match reloc symbol:
    case X187Relocation{+section,+offset,kind,+name,+lo,+hi}
      KDef{n,k,+targetSection,+value,typ,v,c,+global,+defined}:
      nt_choose(X188Fixups,defined && Bool.not(global) && String.starts_with(name,".L") &&
          U32.is_eq(section,1) && U32.is_eq(targetSection,1),u =>
        nt_choose(X188Fixups,U32.is_eq(lo,4294967292) && U32.is_eq(hi,4294967295) &&
            U32.is_le(value,size) && U32.is_le(offset,size) && U32.is_le(4,U32.sub(size,offset)),
          v => x188_fixup_add(X187Relocation{1,offset,2,name,U32.sub(value,U32.add(offset,4)),0},state),
          v => x188_fixup_error("invalid local branch fixup",state)),u =>
        x188_fixup_keep(X187Relocation{section,offset,2,name,lo,hi},state))
    case X187Relocation{section,offset,kind,name,lo,hi} _:
      x188_fixup_keep(X187Relocation{section,offset,2,name,lo,hi},state)

@unsafe
def x188_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{section,offset,+kind,name,lo,hi}:
      nt_choose(X188Fixups,U32.is_eq(kind,131),
        u => x188_fixup_add(X187Relocation{1,offset,2,"",lo,0},state),
        u => nt_choose(X188Fixups,U32.is_eq(kind,130),
          v => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
          v => x188_fixup_keep(reloc,state)))

@unsafe
def w10_weak_from_book(book: List<&2,KDef>, +acc: KDef) -> KDef:
  match book:
    case Nil{}: acc
    case Con{KDef{+name,+kind,arity,templates,typ,value,ctors,native,unsafe},+rest}:
      nt_choose(KDef,agy_str_eq(kind,"Def"),
        u => w10_weak_from_book(rest,w10_weak_add_def(name,acc)),
        u => w10_weak_from_book(rest,acc))
    case Con{_,rest}: w10_weak_from_book(rest,acc)

@unsafe
def w10_weak_from_seed(seed: P86Seed) -> KDef:
  match seed:
    case P86Seed{src,book,fresh,ready,world}:
      w10_weak_from_book(book,missing())

@unsafe
def w10_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}
      X187ElfSymbols{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}:
      w10_elf_sym_add_ascii(name,section,value,size,global,kind,sizes,weak_set,index,count,firstGlobal,table,strings,stringSize,error,
        w7c_elf_ascii_valid(name,strings,0))

law w10_elf_symbols_step:
  for +head: X187Symbol
  for +rest: List<&2,X187Symbol>
  for +globals: Bool
  for +sizes: X187ElfSizes
  for +weak_set: KDef
  for +state: X187ElfSymbols
  X187ElfSymbols

@unsafe
def w10_elf_symbols(items: List<&2,X187Symbol>, +globals: Bool, +sizes: X187ElfSizes,
    +weak_set: KDef, +state: X187ElfSymbols) -> X187ElfSymbols:
  match items:
    case Nil{}: state
    case Con{+head,rest}:
      w10_elf_symbols_step(head,rest,globals,sizes,weak_set,state)

@unsafe
def w10_elf_symbols_step(head, rest, globals, sizes, weak_set, state):
  match head:
    case X187Symbol{name,section,value,size,+global,kind}:
      w10_elf_symbols(rest,globals,sizes,weak_set,
        nt_choose(X187ElfSymbols,(global && globals) || (Bool.not(global) && Bool.not(globals)),
          u => w10_elf_symbol_add(head,sizes,weak_set,state),u => state))

@unsafe
def w10f_fn_label_local(+name: String, +ts: U32, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  +h = index_hash(name,2166136261)
  nt_choose(W10fFnBuild,agy_str_eq(dk(w5c3_find(lsyms,name,h)),"W10fL"),
    u => W10fFnBuild{x187_build_error("duplicate symbol or invalid size: " ++ name,build),lsyms,lrelocs},
    u => W10fFnBuild{build,p111v_put_h(lsyms,name,h,"W10fL",ts,0),lrelocs})

law w10f_fn_resolve:
  for lrelocs: List<&2,X187Relocation>
  for +lsyms: KDef
  for +acc: List<&2,X187Relocation>
  for +build: X187Build
  X187Build

@unsafe
def w10f_fn_resolve_one(+reloc: X187Relocation, +rest: List<&2,X187Relocation>, +lsyms: KDef,
    +acc: List<&2,X187Relocation>, +build: X187Build, +entry: KDef) -> X187Build:
  match reloc:
    case X187Relocation{sec,+off,knd,+sym,lo,hi}:
      nt_choose(X187Build,agy_str_eq(dk(entry),"W10fL"),
        u => w10f_fn_resolve(rest,lsyms,
          Con{X187Relocation{1,off,131,"",U32.sub(da(entry),U32.add(off,4)),0},acc},build),
        u => w10f_fn_resolve(rest,lsyms,acc,x187_build_relocation(reloc,build)))

@unsafe
def w10f_fn_resolve_item(+reloc: X187Relocation, rest: List<&2,X187Relocation>, +lsyms: KDef,
    acc: List<&2,X187Relocation>, build: X187Build) -> X187Build:
  match reloc:
    case X187Relocation{sec,off,knd,+sym,lo,hi}:
      w10f_fn_resolve_one(reloc,rest,lsyms,acc,build,p111v_get(lsyms,sym))

@unsafe
def w10f_fn_resolve(lrelocs, lsyms, acc, build):
  match lrelocs:
    case Nil{}: w10f_fn_push_relocs(acc,build)
    case Con{reloc,rest}:
      w10f_fn_resolve_item(reloc,rest,lsyms,acc,build)

@unsafe
def w10_if_collect_abi(cursor: P134Cursor, +direct: KDef, +public: KDef) -> W10IfAbi:
  match cursor:
    case P134Private{fns, ctx, next}:
      w10_if_collect_abi(next, w10_if_add_direct(fns, direct), public)
    case P134Legacy{entries, ctx, next}:
      w10_if_collect_abi(next, direct, public)
    case P134Public{segs, ctx, next}:
      w10_if_collect_abi(next, direct, w10_if_add_public(segs, public))
    case _: W10IfAbi{direct, public}

# --- ABI-matched self-recursive stub builder & span zeroing ---

@unsafe
def w10_if_intern_str(enc: W10IfEnc, +s: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(sm, s)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{p111v_put(sm, s, "S", sn, 0), Con{w10_if_push_str(s), sr}, U32.inc(sn), rm, rr, rn}, sn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_intern_rec(enc: W10IfEnc, +wire: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(rm, wire)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{sm, sr, sn, p111v_put(rm, wire, "R", rn, 0), Con{wire, rr}, U32.inc(rn)}, rn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_enc_nil(enc: W10IfEnc) -> W10IfRes:
  w10_if_intern_rec(enc, w10_if_w(0, w10_if_w(0, SNil{})))

@unsafe
def w10_if_enc_con(enc: W10IfEnc, +a: U32, +b: U32) -> W10IfRes:
  w10_if_intern_rec(enc, w10_if_w(1, w10_if_w(2, w10_if_w(a, w10_if_w(b, SNil{})))))

@unsafe
def w10_if_enc_strs(enc: W10IfEnc, xs: List<&2, String>) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_intern_str(enc, h)
      +r2 = w10_if_enc_strs(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), U32.add(w10_if_res_id(r1), 2147483648), w10_if_res_id(r2))

@unsafe
def w10_if_mark_patches(ps: List<&2, KDef>, bad: KDef) -> KDef:
  match ps:
    case Nil{}: bad
    case Con{p, rest}:
      w10_if_mark_patches(rest, p111v_put(bad, dn(p), "B", 1, 0))

@unsafe
def w10_if_mark_dups(ds: List<&2, KDef>, +seen: KDef, +bad: KDef) -> KDef:
  match ds:
    case Nil{}: bad
    case Con{KDef{+name, _, _, _, _, _, _, _, _}, +rest}:
      nt_choose(KDef, w10_if_abi_has(seen, name),
        u => w10_if_mark_dups(rest, seen, p111v_put(bad, name, "B", 1, 0)),
        u => w10_if_mark_dups(rest, p111v_put(seen, name, "S", 1, 0), bad))
    case Con{_, rest}: w10_if_mark_dups(rest, seen, bad)

@unsafe
def w10_if_cache_put(h: KDef, +id: U32, +bad: KDef, +cache: KDef) -> KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      nt_choose(KDef, w10_if_abi_has(bad, name),
        u => cache,
        u => p111v_put(cache, name, "C", id, 0))
    case _: cache

@unsafe
def w10_if_enc_book_join(+id1: U32, pair: W10IfRes & KDef) -> W10IfRes & KDef:
  (+r2, cache2) = pair
  (w10_if_enc_con(w10_if_res_enc(r2), id1, w10_if_res_id(r2)), cache2)

@unsafe
def w10_if_enc_fresh(enc: W10IfEnc, fr: FFreshPrefixState) -> W10IfRes:
  match fr:
    case FFreshPrefixState{next, ready}:
      +wire = w10_if_w(9, w10_if_w(2, w10_if_w(next, w10_if_w(Bool.to_u32(ready), SNil{}))))
      w10_if_intern_rec(enc, wire)


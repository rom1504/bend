# Module m11 (K=14 acyclic topological split of wave13_unified/compiler.bend)
# defs=460 laws=36 sccs=359 deps=[m00a,m00b,m01,m02,m03,m04,m05a,m05b,m06,m07,m08,m09,m10] cross_imports=570 fid_base=58200..65531

law check_definition_type:
  for +book: List<&2, KDef>
  for +d: KDef
  for +e: KEnv
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:331
law f_tops:
  for +ts0: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  FRawResult

# Module: src/front/declarations.bend:25
law f_graph_load:
  for +path: String
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

# Module: src/load/graph.bend:54
law f_graph_finish:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +g: FGraph
  for +sources: List<&2,FSource>
  for +fallback: String
  FGraph

# Module: src/load/graph.bend:76
law f_graph_finish_alias:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +prior: List<&2,KDef>
  for +err: String
  for +done: List<&2, KTerm>
  for +sources: List<&2,FSource>
  for +fallback: String
  FGraph

# Module: src/load/graph.bend:231
law f_graph_result_at:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  FResult

# Module: src/load/graph.bend:286
law fpe_graph_result:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  for +result: FResult
  FResult

# Module: src/load/graph.bend:291
law fpe_rejected:
  for +result: FResult
  for +book: List<&2,KDef>
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  FResult

# Module: src/load/graph.bend:297
law fpe_selected:
  for +legacy: String
  for +owner: KTerm
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  String

# Module: src/load/graph.bend:331
law fs_load:
  for +path: String
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:24
law fs_source:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:33
law fs_cached:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +entry: KTerm
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:43
law fs_parsed:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +r: FHeader
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:58
law fs_imports:
  for +s: FSource
  for +ns: String
  for +header: FHeader
  for +imports: List<&2, KTerm>
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:134
law dg_check_events:
  for +todo: List<&2,KDef>
  for +world: KWorld
  for +seen: List<&2,KDef>
  DChecking

# Module: src/diagnostic/produce.bend:201
@unsafe
def w7_br_198(w7_c: Bool, +d: KDef, +e: KEnv, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_adt_declaration(ke_world(e, rw(r)), d)
    case False{}:
      w7_br_197(p98_tag_eq(dv(d), "Absent"), d, e, r)

@unsafe
def w7_br_199(w7_c: Bool, +d: KDef, +e: KEnv, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_198(p88_string_eq(dk(d), "ADT"), d, e, r)
    case False{}:
      r

@unsafe
def check_definition_type(book, d, e, r):
  w7_br_199(good(r), d, e, r)

# Module: src/check/kernel.bend:1013
@unsafe
def check_definition_world(+world: KWorld, +d: KDef, +depth: U32) -> KChecking:
  +e: KEnv = KEnv{world, dn(d), ref(dn(d)), 0, Nil{}, du(d), depth}
  check_definition_type(kw_book(world), d, e, check(e, Nil{}, dt(d), 0, typ(1)))

# A translated failure retains the completed check's actual world and transport.

# Module: src/check/kernel.bend:1258
@unsafe
def base_prefix_resume_saved(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>) -> DChecking:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      +ordered = base_prefix_patch(final, book_context(patches))
      +seed = book_cached(Nil{}, bound)
      +declared = check_declarations(prefix_state_join(prefix, suffix), seed)
      +world: KWorld = KWorld{kw_bound_book(base_prefix_put(declared, final), U32.add(bound, stamp)), Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, book_final_reverse(ordered, Nil{})}
      dg_check_events(suffix, world, base_prefix_seen(prefix, bound))

# PRIVATE ready world. Its producer consumes the identity-bound checked prefix
# state; the driver binds this whole immutable record to that same Base seed.
# Raw books and old prefix-state exports retain their full admission paths.

# Module: src/check/prefix-state.bend:275
@unsafe
def base_prefix_world_prepare(+prefix: List<&2,KDef>, +state: KBasePrefixState) -> KBasePreparedWorld:
  +bound = norm_max_book(prefix)
  +final = base_prefix_final(prefix)
  kc(KBasePreparedWorld, base_prefix_admitted_bound(state, prefix, Nil{}, bound, final, bound),
    u => base_prefix_world_saved(prefix, state, final, bound, rw(dg_checking_result(base_prefix_resume_saved(state, prefix, Nil{}, bound, final)))),
    u => KBasePreparedWorld{KBasePrefixState{bound, 0, 0, Nil{}, False{}}, prefix, final, Nil{}, Nil{}, Nil{}, 0, 0})

# Module: src/check/prefix-state.bend:283
@unsafe
def base_prefix_resume_world(+prepared: KBasePreparedWorld, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state, prefix, final, book, checked, seen, todos, checkedBound}:
      base_prefix_world_resume_state(state, book, checked, seen, suffix, bound)

# Module: src/check/prefix-state.bend:309
@unsafe
def base_prefix_world_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>, +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      +declared = check_declarations(suffix, kw_bound_book(book, U32.add(bound, stamp)))
      +ordered = base_prefix_world_order(declared, base_prefix_world_raw(book), suffix)
      +world: KWorld = KWorld{ordered, Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, checked}
      dg_check_events(suffix, world, kw_bound_book(seen, bound))

# Full hash collisions preserve lookup semantics but change the exact bucket
# event order when suffix headers move after Base publication. Retain the old
# replay path for that rare case instead of weakening whole-world equality.

# Module: src/check/prefix-state.bend:321
@unsafe
def base_prefix_world_check_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos, checkedBound}:
      kc(DChecking, base_prefix_world_hash_disjoint(suffix, index_first(dc(index_first(saved)))),
        u => base_prefix_resume_world(prepared, suffix, bound),
        u => base_prefix_resume_saved(state, prefix, suffix, bound, final))

# Count holes in final original events, not elaborated bodies. Admitted prefix
# and suffix names are disjoint, so finalization cannot remove a prefix event.
# Version-two host admission binds this precomputed count to the actual world.

# Module: src/check/prefix-state.bend:392
@unsafe
def base_prefix_program_world_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool, +origins: List<&2,DOrigin>) -> DResult:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos, checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
      kc(DResult, ready && String.is_empty(error) && base_prefix_world_admitted(state, suffix, bound, final, saved),
        u => driver_program_checked_prefix(suffix, todos, origins, base_prefix_world_check_admitted(prepared, prefix, suffix, bound)),
        u => driver_program_checked(book, origins, dg_check_world(book)))

# Module: src/check/prefix-state.bend:401
@unsafe
def check_program_diagnostic_world(+load: FPrefixLoad, +origins: List<&2,DOrigin>, +prepared: KBasePreparedWorld) -> DResult:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{book, error, imports}:
              base_prefix_program_world_book(prepared, book, error, prefix, suffix, ready, origins)

# PRIVATE context for the successful result of this same admitted world check.
# The driver couples that result, load and prepared seed; a raw book supplied by
# a public caller does not acquire this permission. Public book_context is intact.

# Module: src/check/prefix-state.bend:414
@unsafe
def f_tops(ts0, book, imports, unsafe, scope):
  p141p_raw(p140p_tops(0,ts0,book,imports,unsafe,scope))

@unsafe
def f_load_graph(
  +main: String,
  +sources: List<&2,FSource>,
) -> FResult:
  f_graph_result_at(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}), sources)

# Module: src/load/graph.bend:150
@unsafe
def f_graph_load(path, ns, sources, g, stack):
  # fs_source rejects empty source paths before this disabled seed can match.
  fs_load(path, ns, sources, g, stack, FSeed{"", Nil{}, f_path_dir(f_source_path(f_graph_source(path, sources)))})

# Module: src/load/graph.bend:163
@unsafe
def f_graph_finish(s, ns, book, imports, g, sources, fallback):
  match g:
    case FGraph{prior, +err, done}:
      # Reuse the ordinary freshness rule before module qualification can hide
      # a collision with Base or another declaration in the root namespace.
      f_graph_finish_alias(s, ns, f_graph_fill_defs(book, imports, prior), imports, prior, f_choose(String, String.is_empty(err) && String.is_empty(fallback), u => f_graph_fresh_names(book, index_build(List.reverse(&2,KDef,prior))), u => err), done, sources, fallback)

# Module: src/load/graph.bend:201
@unsafe
def f_graph_finish_indexed(+source: FSource, +ns: String, +imports: List<&2,KTerm>, +graph: FGraph, +sources: List<&2,FSource>, +names: KDef, +parsed: FResult) -> FIndexedCompletion:
  match graph parsed:
    case FGraph{prior, error, done} FResult{book, fallback, parsedImports}:
      +filled = f_graph_fill_defs(book, imports, prior)
      +selected = kc(String, String.is_empty(error) && String.is_empty(fallback), u => f_graph_fresh_names(book, names), u => error)
      +loaded: List<&2,KTerm> = Con{kt("Loaded", f_source_path(source), f_graph_count_defs(filled, 0), 0, Con{ref(ns), imports}), done}
      +fragment = f_path_defs(f_context_modules(filled, ns), f_path_dir(f_source_path(source)), f_eq(f_source_name(source), "Base"))
      FIndexedCompletion{f_graph_finish_module(source, prior, selected, loaded, fragment, sources, fallback), parsed, fragment}

# Module: src/load/graph.bend:211
@unsafe
def f_graph_finish_alias(s, ns, book, imports, prior, err, done, sources, fallback):
  f_graph_finish_module(s, prior, err, Con{kt("Loaded", f_source_path(s), f_graph_count_defs(book, 0), 0, Con{ref(ns), imports}), done}, f_path_defs(f_context_modules(book, ns), f_path_dir(f_source_path(s)), f_eq(f_source_name(s), "Base")), sources, fallback)

# Dependency completion checks only its new fragment, never cached prior terms.

# Module: src/load/graph.bend:216
@unsafe
def f_graph_finish_module(+source: FSource, +prior: List<&2,KDef>, +error: String, +done: List<&2,KTerm>, +book: List<&2,KDef>, +sources: List<&2,FSource>, +fallback: String) -> FGraph:
  FGraph{norm_defs_join(prior, book), f_choose(String, String.is_empty(error), u => f_graph_module_error(source, fpe_defs(book), sources, fallback), u => error), done}

# Module: src/load/graph.bend:220
@unsafe
def w7_br_519(w7_c: Bool, +source: FSource, +error: KTerm, +sources: List<&2,FSource>, +fallback: String) -> String:
  match w7_c:
    case True{}:
      fallback
    case False{}:
      fpe_source_render(nm(error), error, f_choose(KTerm, U32.is_gt(kb(error), 0), u => fpe_located_source(error, sources), u => kt("ParseSource", f_source_text(source), 0, 0, Nil{})))

@unsafe
def f_graph_module_error(+source: FSource, +error: KTerm, +sources: List<&2,FSource>, +fallback: String) -> String:
  w7_br_519(f_eq(tg(error), "Absent"), source, error, sources, fallback)

# Module: src/load/graph.bend:248
@unsafe
def f_graph_result_at(graph, sources):
  fpe_graph_result(graph, sources, f_graph_result(graph))

# Module: src/load/graph.bend:350
@unsafe
def fpe_graph_result(graph, sources, result):
  match graph:
    case FGraph{book, error, done}:
      f_choose(FResult, String.is_empty(error), u => fpe_rejected(result, book, done, sources), u => result)

# Module: src/load/graph.bend:355
@unsafe
def fpe_rejected(result, book, done, sources):
  match result:
    case FResult{out, +error, imports}:
      FResult{out, f_choose(String, String.is_empty(error), u => error, u => fpe_selected(error, fpe_find(book, 0), done, sources)), imports}

# Exactly the existing f_error_* traversal order, including empty-name Error skip.

# Module: src/load/graph.bend:362
@unsafe
def w7_br_527(w7_c: Bool, +legacy: String, +owner: KTerm, +done: List<&2,KTerm>, +sources: List<&2,FSource>) -> String:
  match w7_c:
    case True{}:
      fpe_source_render(legacy, kid(owner, 0), f_choose(KTerm, U32.is_gt(kb(kid(owner, 0)), 0), u => fpe_located_source(kid(owner, 0), sources), u => fpe_unique_source(fpe_owner_path(List.reverse(&2, KTerm, done), ix(owner)), sources, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))
    case False{}:
      legacy

@unsafe
def fpe_selected(legacy, owner, done, sources):
  w7_br_527(f_eq(tg(owner), "ParseOwner") && p88_string_eq(nm(kid(owner, 0)), legacy), legacy, owner, done, sources)

# Module: src/load/graph.bend:397
@unsafe
def fs_load(path, ns, sources, g, stack, seed):
  fs_source(f_graph_source(path, sources), ns, sources, g, stack, seed)

# Module: src/load/seed.bend:104
@unsafe
def fs_source(s, ns, sources, g, stack, seed):
  match g:
    case FGraph{book, +err, +done}:
      f_choose(FGraph, Bool.not(String.is_empty(err)), u => FGraph{book, err, done}, u => f_choose(FGraph, String.is_empty(f_source_path(s)), u => FGraph{book, "module source was not supplied", done}, u => f_choose(FGraph, has_name(stack, f_source_path(s)), u => FGraph{book, "cyclic import through " ++ f_source_path(s), done}, u => fs_cached(s, ns, sources, FGraph{book, err, done}, stack, f_env(f_source_path(s), done), seed))))

# Module: src/load/seed.bend:110
@unsafe
def w7_br_533(w7_c: Bool, +s: FSource, +ns: String, +sources: List<&2, FSource>, +g: FGraph, +stack: List<&2, String>, +seed: FSeed) -> FGraph:
  match w7_c:
    case True{}:
      fs_inject(g, seed)
    case False{}:
      fs_parsed(s, ns, sources, g, Con{f_source_path(s), stack}, f_source_header(s), seed)

@unsafe
def w7_br_534(w7_c: Bool, +s: FSource, +ns: String, +sources: List<&2, FSource>, +g: FGraph, +stack: List<&2, String>, +seed: FSeed) -> FGraph:
  match w7_c:
    case True{}:
      w7_br_533(String.is_empty(ns) && f_eq(f_source_name(s), "Base") && f_eq(f_source_path(s), fs_path(seed)), s, ns, sources, g, stack, seed)
    case False{}:
      g

@unsafe
def fs_cached(s, ns, sources, g, stack, entry, seed):
  w7_br_534(f_eq(tg(entry), "Absent"), s, ns, sources, g, stack, seed)

# Module: src/load/seed.bend:114
@unsafe
def fs_parsed(s, ns, sources, g, stack, r, seed):
  fs_imports(s, ns, r, f_header_imports(r), sources, g, stack, seed)

# Module: src/load/seed.bend:124
@unsafe
def fs_imports(s, ns, header, imports, sources, g, stack, seed):
  match imports:
    case Nil{}:
      f_completion_graph(f_complete_source(s, ns, header, sources, g, fs_root(seed)))
    case Con{im, rest}:
      fs_imports(s, ns, header, rest, sources, fs_load(f_import_pathname(im, s, sources), f_import_namespace_at(im, s, sources, fs_root(seed)), sources, g, stack, seed), stack, seed)


# Compare the complete source through the canonical String equality primitive.
# Native compiler images compare primitive text directly without constructing tails.

# Module: src/load/seed.bend:140
@unsafe
def f_header_scan(+source: String, +full: String, +start: U32, +line: U32, +offset: U32, +prefix: String) -> FHeader:
  f_header_next(f_header_line(source, "", 0), source, full, start, line, offset, prefix)

# Module: src/load/modules.bend:178
@unsafe
def f_header_next(+scanned: FScanned, +source: String, +full: String, +start: U32, +line: U32, +offset: U32, +prefix: String) -> FHeader:
  match scanned:
    case FScanned{word, rest, size}:
      f_choose(FHeader, Bool.not(String.is_empty(source)) && f_header_prefix(word),
        u => f_header_scan(rest, full, start, U32.add(line, 1), U32.add(offset, size), prefix ++ word),
        u => f_header_result(fpe_finish_indexed(start, full, f_tops(f_input(f_lex_cursor(prefix, 1, 0, 0, Nil{}, start, start)), Nil{}, Nil{}, False{}, f_parse_scope_empty())), source, line, offset))

# Module: src/load/modules.bend:186
@unsafe
def f_source_header(+source: FSource) -> FHeader:
  match source:
    case FSource{name, path, text}: f_header_scan(text, text, 0, 1, 0, "")
    case FCompletedSource{name, path, text, parsed}: f_header_supplied(parsed)
    case FLocatedSource{inner, begin, end}: f_source_header_at(inner, begin)

# Module: src/load/modules.bend:198
@unsafe
def f_source_header_at(+source: FSource, +start: U32) -> FHeader:
  match source:
    case FSource{name, path, text}: f_header_scan(text, text, start, 1, 0, "")
    case FCompletedSource{name, path, text, parsed}: f_header_supplied(parsed)
    case FLocatedSource{inner, begin, end}: FHeader{Nil{}, "nested source interval", "", 1, 0}

# Module: src/load/modules.bend:205
@unsafe
def f_source_body(+source: FSource, +header: FHeader, +prior: List<&2,KDef>, +ns: String, +aliases: List<&2,KTerm>, +start: U32) -> FResult:
  match source:
    case FSource{name, path, text}: f_body_header(text, header, FParseScope{prior, index_build(List.reverse(&2,KDef,prior)), f_ctor_index(prior, missing()), ns, aliases, None{}}, start)
    case FCompletedSource{name, path, text, parsed}: parsed
    case FLocatedSource{inner, begin, end}: f_source_body(inner, header, prior, ns, aliases, begin)

# Module: src/load/modules.bend:222

@unsafe
def f_body_header(+source: String, +header: FHeader, +scope: FParseScope, +start: U32) -> FResult:
  match header:
    case FHeader{imports, error, body, line, offset}:
      f_choose(FResult, String.is_empty(error),
        u => f_context_result(fpe_finish_indexed(start, source, f_tops(f_input(f_lex_cursor(body, line, 0, 0, Nil{}, f_cursor_add(start, offset), f_cursor_add(start, offset))), Nil{}, List.reverse(&2,KTerm,imports), False{}, p144p_ready_scope(scope)))),
        u => FResult{Nil{}, error, imports})

# Module: src/load/modules.bend:230

@unsafe
def f_complete_source(+source: FSource, +ns: String, +header: FHeader, +sources: List<&2,FSource>, +graph: FGraph, +root: String) -> FCompletion:
  match graph:
    case FGraph{book, error, done}:
      f_choose(FCompletion, String.is_empty(error),
        u => f_complete_aliases(source, ns, header, graph, f_graph_aliases(f_header_imports(header), source, sources, root), book, sources),
        u => FCompletion{graph, FResult{Nil{}, error, Nil{}}})

# Module: src/load/modules.bend:238
@unsafe
def f_complete_aliases(+source: FSource, +ns: String, +header: FHeader, +graph: FGraph, +aliases: List<&2,KTerm>, +prior: List<&2,KDef>, +sources: List<&2,FSource>) -> FCompletion:
  f_complete_parsed(source, ns, aliases, graph, f_source_body(source, header, prior, ns, aliases, 0), sources)

# Module: src/load/modules.bend:242
@unsafe
def f_complete_parsed(+source: FSource, +ns: String, +aliases: List<&2,KTerm>, +graph: FGraph, +parsed: FResult, +sources: List<&2,FSource>) -> FCompletion:
  match parsed:
    case FResult{book, error, imports}:
      FCompletion{f_graph_finish(source, ns, book, aliases, graph, sources, error), parsed}

# Private admitted-prefix path: the scope indexes describe the exact prior
# graph book. Contextual parsing and completion of the new source are unchanged.

# Module: src/load/modules.bend:250
@unsafe
def f_complete_source_indexed(+source: FSource, +ns: String, +header: FHeader, +sources: List<&2,FSource>, +graph: FGraph, +root: String, +names: KDef, +ctors: KDef) -> FIndexedCompletion:
  match graph:
    case FGraph{book, error, done}:
      kc(FIndexedCompletion, String.is_empty(error),
        u => f_complete_aliases_indexed(source, ns, header, graph, f_graph_aliases(f_header_imports(header), source, sources, root), book, sources, names, ctors),
        u => FIndexedCompletion{graph, FResult{Nil{}, error, Nil{}}, Nil{}})

# Module: src/load/modules.bend:258
@unsafe
def f_complete_aliases_indexed(+source: FSource, +ns: String, +header: FHeader, +graph: FGraph, +aliases: List<&2,KTerm>, +prior: List<&2,KDef>, +sources: List<&2,FSource>, +names: KDef, +ctors: KDef) -> FIndexedCompletion:
  f_graph_finish_indexed(source, ns, aliases, graph, sources, names, f_source_body_indexed(source, header, FParseScope{prior, names, ctors, ns, aliases, None{}}, 0))

# Module: src/load/modules.bend:262

@unsafe
def f_source_body_indexed(+source: FSource, +header: FHeader, +scope: FParseScope, +start: U32) -> FResult:
  match source:
    case FSource{name, path, text}: f_body_header(text, header, scope, start)
    case FCompletedSource{name, path, text, parsed}: parsed
    case FLocatedSource{inner, begin, end}: f_source_body_indexed(inner, header, scope, begin)

# Module: src/load/modules.bend:269
@unsafe
def f_prefix_complete_source(+source: FSource, +ns: String, +header: FHeader, +sources: List<&2,FSource>, +carrier: FPrefixGraph, +root: String) -> FPrefixCompletion:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      f_prefix_source_completed(prefix, count, ready, f_complete_source(source, ns, header, sources, graph, root))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      kc(FPrefixCompletion, ready,
        u => f_prefix_ready_source_completed(prefix, suffix, count, baseNames, names, ctors, f_complete_source_indexed(source, ns, header, sources, graph, root, names, ctors)),
        u => f_prefix_source_completed(prefix, count, False{}, f_complete_source(source, ns, header, sources, graph, root)))

# Carry the actual completed fragment instead of walking the Base spine twice
# to rediscover it. Prior suffix cells and all prior term trees stay unchanged.

# Module: src/load/prefix.bend:185
@unsafe
def f_prefix_graph_trace(+carrier: FPrefixGraph, +sources: List<&2,FSource>, +state: FFreshPrefixState) -> FPrefixLoad:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      match graph state:
        case FGraph{book, error, done} FFreshPrefixState{next, fresh_ready}:
          f_prefix_trace_validated(graph, sources, prefix, suffix, next, ready && fresh_ready,
            f_graph_fresh_result(f_validate_result(FResult{book, error, Nil{}})))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      match graph state:
        case FGraph{book, error, done} FFreshPrefixState{next, fresh_ready}:
          kc(FPrefixLoad, ready && fresh_ready,
            u => f_prefix_trace_validated(graph, sources, prefix, suffix, next, True{}, f_prefix_ready_validate(book, suffix, error, baseNames)),
            u => f_prefix_graph_trace(FPrefixGraph{graph, prefix, suffix, count, ready}, sources, state))

# Module: src/load/prefix.bend:240
@unsafe
def f_prefix_trace_validated(+graph: FGraph, +sources: List<&2,FSource>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +next: U32, +ready: Bool, +validated: FResult) -> FPrefixLoad:
  match validated:
    case FResult{book, error, imports}:
      kc(FPrefixLoad, ready && String.is_empty(error),
        u => f_prefix_trace_fresh(graph, sources, prefix, imports, f_fresh_defs(suffix, next)),
        u => f_prefix_trace_fallback(graph, sources, validated))

# Module: src/load/prefix.bend:258
@unsafe
def f_prefix_trace_fresh(+graph: FGraph, +sources: List<&2,FSource>, +prefix: List<&2,KDef>, +imports: List<&2,KTerm>, +fresh: FFreshDefs) -> FPrefixLoad:
  match graph fresh:
    case FGraph{book, error, done} FFreshDefs{suffix, next}:
      FPrefixLoad{FLoadTrace{fpe_graph_result(graph, sources, FResult{norm_defs_join(prefix, suffix), "", imports}), done, sources}, prefix, suffix, True{}}

# Module: src/load/prefix.bend:264
@unsafe
def f_prefix_trace_fallback(+graph: FGraph, +sources: List<&2,FSource>, +validated: FResult) -> FPrefixLoad:
  match graph:
    case FGraph{book, error, done}:
      FPrefixLoad{FLoadTrace{fpe_graph_result(graph, sources, f_fresh_result(validated)), done, sources}, Nil{}, Nil{}, False{}}

# Module: src/diagnostic/render.bend:43
@unsafe
def dg_check_world(+book: List<&2,KDef>) -> DChecking:
  dg_check_seed(book, norm_max_book(book))

# Module: src/diagnostic/produce.bend:112
@unsafe
def dg_check_seed(+book: List<&2,KDef>, +bound: U32) -> DChecking:
  +seed = book_cached(Nil{}, bound)
  dg_check_events(book, kw_seed(check_declarations(book, seed), bound), seed)

# Module: src/diagnostic/produce.bend:123
@unsafe
def dg_check_events(todo, world, seen):
  match todo:
    case Nil{}: DChecking{bad(world, ""), dg_no_report("", "")}
    case Con{d, rest}:
      dg_check_guard(rest, world, seen, d, event_error(seen, d, lookup(seen, dn(d))))

# Module: src/diagnostic/produce.bend:130
@unsafe
def w7_br_560(w7_c: Bool, +rest: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>, +d: KDef, +guard: String) -> DChecking:
  match w7_c:
    case True{}:
      dg_check_next(rest, seen, d, check_definition_world(world, signature_mode(d, rest), 0))
    case False{}:
      DChecking{bad(world, dn(d) ++ ": " ++ guard), dg_no_report(dn(d), guard)}

@unsafe
def dg_check_guard(+rest: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>, +d: KDef, +guard: String) -> DChecking:
  w7_br_560(p88_string_eq(guard, ""), rest, world, seen, d, guard)

# Module: src/diagnostic/produce.bend:136
@unsafe
def w7_br_561(w7_c: Bool, +rest: List<&2,KDef>, +seen: List<&2,KDef>, +d: KDef, +r: KChecking) -> DChecking:
  match w7_c:
    case True{}:
      dg_check_events(rest, dg_event_publish(rest, d, r), book_put(seen, d))
    case False{}:
      dg_event_failed(r, dn(d))

@unsafe
def dg_check_next(+rest: List<&2,KDef>, +seen: List<&2,KDef>, +d: KDef, +r: KChecking) -> DChecking:
  w7_br_561(good(r), rest, seen, d, r)

# Module: src/diagnostic/produce.bend:142
@unsafe
def p86_prepare(+path: String, +text: String) -> P86Preparation:
  +source = f_source_located(FSource{"Base", path, text}, 1, U32.add(p86_width(text, 0), 2))
  p86_prepare_loaded(source, f_load_graph("Base", [source]))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:425
@unsafe
def p86_prepare_loaded(+source: FSource, loaded: FResult) -> P86Preparation:
  match loaded:
    case FResult{+book, +error, imports}:
      kc(P86Preparation, String.is_empty(error),
        u => p86_prepare_check(source, book, dg_check_world(book)),
        u => P86PreparationError{"base_parse: " ++ error})

# Preserve check_book's ordinary diagnostic path while retaining its checked
# world for the existing prefix-admission construction.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:435
@unsafe
def p86_prepare_check(+source: FSource, +book: List<&2,KDef>, +checked: DChecking) -> P86Preparation:
  p86_prepare_checked(source, book, checked, dg_result_error(dg_legacy_result(book, Nil{}, checked)))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:439
@unsafe
def w7_br_788(w7_c: Bool, +source: FSource, +book: List<&2,KDef>, +checked: DChecking, +error: String) -> P86Preparation:
  match w7_c:
    case True{}:
      p86_prepare_states(source, book, f_fresh_prefix_prepare(book), f_ready_prefix_prepare(book), base_prefix_world_prepare(book, p86_checked_prefix(book, checked)))
    case False{}:
      P86PreparationError{"base_check: " ++ error}

@unsafe
def p86_prepare_checked(+source: FSource, +book: List<&2,KDef>, +checked: DChecking, +error: String) -> P86Preparation:
  w7_br_788(String.is_empty(error), source, book, checked, error)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:450
@unsafe
def p86_plan(+seed: P86Seed, +path: String, +text: String) -> P86Plan:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p86_plan_header(seed, source, f_source_header(source))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:475
@unsafe
def p86_plan_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_imported(seed, source, header, p86_import_error(imports, False{})),
        u => P86PlanError{"parse: " ++ error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:483
@unsafe
def w7_br_789(w7_c: Bool, +seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P86Plan:
  match w7_c:
    case True{}:
      p86_plan_seed(seed, source, header)
    case False{}:
      P86PlanError{"load: " ++ error}

@unsafe
def p86_plan_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P86Plan:
  w7_br_789(String.is_empty(error), seed, source, header, error)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:488
@unsafe
def p86_plan_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p86_plan_seeded(seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:495
@unsafe
def p86_plan_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          kc(P86Plan, String.is_empty(error),
            u => p86_plan_completed(seed, source,
              f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
            u => P86PlanError{"parse: " ++ error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:506
@unsafe
def p86_plan_completed(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p86_plan_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:512
@unsafe
def p86_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P86Plan, String.is_empty(error),
                u => p86_plan_checked(load, world, original, nt_choose(DResult,p143cg_enough(suffix,256),
                  v => p143cb_program(load,Nil{},world,True{}),
                  v => check_program_diagnostic_world(load,Nil{},world))),
                u => P86PlanError{"parse: " ++ error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:524

@unsafe
def p86_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +original: List<&2,KDef>, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_reported(load, world, book, driver_report_data(original)),
        u => P86PlanError{"check: " ++ error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:532
@unsafe
def p86_plan_reported(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, report: DR_Report) -> P86Plan:
  match report:
    case DR_Report{+verdict, names}:
      p86_plan_owned(load, world, book, verdict, driver_emit_owned(book))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:538
@unsafe
def w7_br_790(w7_c: Bool, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  match w7_c:
    case True{}:
      p86_plan_entry(load, world, book, verdict, j_compile_error(book))
    case False{}:
      P86PlanError{"compile: " ++ error}

@unsafe
def p86_plan_owned(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  w7_br_790(String.is_empty(error), load, world, book, verdict, error)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:544
@unsafe
def w7_br_791(w7_c: Bool, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  match w7_c:
    case True{}:
      p86_plan_context(book_context_world(book, load, world), verdict)
    case False{}:
      P86PlanError{"compile: " ++ error}

@unsafe
def p86_plan_entry(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  w7_br_791(String.is_empty(error), load, world, book, verdict, error)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:550
@unsafe
def p86_plan_context(+context: List<&2,KDef>, +verdict: String) -> P86Plan:
  +stops = nc_annotation_stops(context)
  p86_plan_annotated(context, stops, verdict, annotate_selected(context, reach_book(context, ["main"], stops), stops))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:555
# Equation patterns operate on checked, first-order, non-erased functions.
# A role denotes the *same* resolved declaration throughout the equation graph.
# Binder references are lexical positions. Source spellings are immaterial.
law w2d_plan:
  for +ctx: List<&2,KDef>
  for +stops: List<&2,String>
  for +verdict: String
  for +defs: List<&2,KDef>
  P86Plan

@unsafe
def p205u_variant(+book: List<&2,KDef>, +input: KTerm) -> KTerm:
  p205v_on(book,p205u_attempt(book,input))

@unsafe
def p205u_select(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  +first = p205u_attempt(context,dv(raw))
  p205u_scalar_checked(context,raw,first,p205u_check(context,raw,p205v_on(context,first)))

# One fresh-id-producing edit per request. Text-only edits do not use this slot.
@unsafe
def p205u_pick(+context: List<&2,KDef>, +raw: KDef, +used: Bool) -> P205UPick:
  +text = kc(KTerm,p205_returns_string(dt(raw)),u => p205_tail(context,dv(raw)),u => atom("Absent"))
  kc(P205UPick,p98_tag_eq(text,"Absent"),u =>
    kc(P205UPick,used,v => P205UPick{missing(),True{}},v =>
      p205u_record(p205u_select(context,raw),used)),u =>
      P205UPick{p205u_check(context,raw,text),used})
@unsafe
def p205u_decls(+context: List<&2,KDef>, +defs: List<&2,KDef>, +edits: KDef, +used: Bool) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{d,rest}:
      p205u_next_decl(context,rest,edits,kc(P205UPick,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => p205u_pick(context,lookup(context,dn(d)),used),u => P205UPick{missing(),used}))
@unsafe
def p205u_next_decl(+context: List<&2,KDef>, +rest: List<&2,KDef>, +edits: KDef, +pick: P205UPick) -> KDef:
  match pick:
    case P205UPick{change,used}:
      p205u_decls(p205z_advance(context,change),rest,kc(KDef,agy_str_eq(dk(change),"Absent"),u => edits,u =>
        index_set(edits,change,index_hash(dn(change),2166136261),32)),used)
@unsafe
def p205u_list(+context: List<&2,KDef>, +defs: List<&2,KDef>, +used: Bool) -> List<&2,KDef>:
  match defs:
    case Nil{}: []
    case Con{d,rest}:
      p205u_next_list(context,d,rest,kc(P205UPick,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => p205u_pick(context,lookup(context,dn(d)),used),u => P205UPick{missing(),used}))
@unsafe
def p205u_next_list(+context: List<&2,KDef>, +original: KDef, +rest: List<&2,KDef>, +pick: P205UPick) -> List<&2,KDef>:
  match pick:
    case P205UPick{change,used}:
      Con{kc(KDef,agy_str_eq(dk(change),"Absent"),u => original,u => change),p205u_list(p205z_advance(context,change),rest,used)}

@unsafe
def w7_br_824(w7_c: Bool, +context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  match w7_c:
    case True{}:
      w2d_plan(context,stops,verdict,candidate)
    case False{}:
      w2d_plan(context,stops,verdict,original)

@unsafe
def p205_candidate(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  w7_br_824(String.is_empty(jl_checked_error(context,candidate,["main"],stops)), context, stops, verdict, original, candidate)

@unsafe
def w7_br_825(w7_c: Bool, +context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +edits: KDef) -> P86Plan:
  match w7_c:
    case True{}:
      w2d_plan(context,stops,verdict,original)
    case False{}:
      p205_candidate(p205z_advance(context,edits),stops,verdict,original,p205_overlay(original,edits))

@unsafe
def p205_ready(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +edits: KDef) -> P86Plan:
  w7_br_825(agy_str_eq(dk(edits),"Absent"), context, stops, verdict, original, edits)

@unsafe
def agy_ctfe_plan(+context: List<&2, KDef>, +stops: List<&2, String>, +verdict: String, +annotated: List<&2, KDef>) -> P86Plan:
  +e1 = ctfe_decls(context, annotated, missing())
  +has_e1 = Bool.not(agy_str_eq(dk(e1), "Absent"))
  +ctx1 = kc(List<&2, KDef>, has_e1, u => p205z_advance(context, e1), u => context)
  +ann1 = kc(List<&2, KDef>, has_e1, u => p205_overlay(annotated, e1), u => annotated)
  +ok1 = has_e1 && String.is_empty(jl_checked_error(ctx1, ann1, ["main"], stops))
  +ctx2 = kc(List<&2, KDef>, ok1, u => ctx1, u => context)
  +ann2 = kc(List<&2, KDef>, ok1, u => ann1, u => annotated)
  p205_ready(ctx2, stops, verdict, ann2, p205u_decls(ctx2, ann2, missing(), False{}))


# AGY-005b: General Absorbing-State Early-Exit for Fueled Tail-Recursive Loops.
# Recognizes pure, safe fueled tail-recursive loops:
#   f(0n,   a..., st, b...) = st
#   f(1n+p, a..., st, b...) = f(p, a..., step(inv..., st), b...)
# where `step` is a pure, non-recursive Def whose arguments before `st` are
# invariant parameters of `f`. Inlines `step` into `f`'s Succ branch, tracks
# the matched pattern of `st` across nested `Mat`/`Lam` nodes, and whenever a
# match arm returns the exact reconstructed/unchanged `st`, emits an immediate
# early return instead of recursing `f(p, ..., st)`. Rechecks with
# `check_definition_body` + `ka_def`.

@unsafe
def agy_abs_match_sbody_call(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +cargs: List<&2,KTerm>) -> AgyAbsResult:
  +next_st = kc(KTerm,agy_abs_is_var(p205u_at(cargs,0),ix(p_lam)),
    v => agy_abs_check_call_args(List.tail(&2,KTerm,cargs),r_lams,st_idx,0),
    v => atom("Absent"))
  kc(AgyAbsResult,Bool.not(p98_tag_eq(next_st,"Absent")),
    v => agy_abs_check_step(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,next_st),
    v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_sbody(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +sbody: KTerm) -> AgyAbsResult:
  +c = j_call_spine(sbody,[])
  kc(AgyAbsResult,p98_tag_eq(c,"Call") && agy_str_eq(nm(c),fname) && U32.is_eq(terms_len(ks(c)),arity),
    u => agy_abs_match_sbody_call(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,p_lam,r_lams,ks(c)),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_peels_go(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, lams1: List<&2,KTerm>, +sbody: KTerm) -> AgyAbsResult:
  match lams1:
    case Con{p_lam,r_lams}: agy_abs_match_sbody(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,p_lam,r_lams,sbody)
    case Nil{}: AgyAbsResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def agy_abs_match_peels(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +zp: AgyAbsPeel, +sp: AgyAbsPeel) -> AgyAbsResult:
  match zp sp:
    case AgyAbsPeel{lams0,zbody,ok0} AgyAbsPeel{lams1,sbody,ok1}:
      +st_idx = kc(U32,ok0 && ok1 && p98_tag_eq(zbody,"Var"),u => agy_abs_find_var(lams0,ix(zbody),0),u => 999999)
      kc(AgyAbsResult,U32.is_lt(st_idx,U32.sub(arity,1)),
        u => agy_abs_match_peels_go(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,lams1,sbody),
        u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def w7_br_889(w7_c: Bool, +ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +msucc: KTerm) -> AgyAbsResult:
  match w7_c:
    case True{}:
      agy_abs_match_peels(ctx,orig_d,raw,rest,fname,arity,zbr,agy_abs_peel(zbr,U32.sub(arity,1)),agy_abs_peel(kid(msucc,0),arity))
    case False{}:
      AgyAbsResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def agy_abs_match_succ(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +msucc: KTerm) -> AgyAbsResult:
  w7_br_889(p98_tag_eq(msucc,"Mat") && agy_str_eq(nm(msucc),"Succ") && U32.is_eq(terms_len(ks(msucc)),2) && p98_tag_eq(kid(msucc,1),"Efq"), ctx, orig_d, raw, rest, fname, arity, zbr, msucc)

@unsafe
def w7_br_890(w7_c: Bool, +ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +clean: KTerm) -> AgyAbsResult:
  match w7_c:
    case True{}:
      agy_abs_match_succ(ctx,orig_d,raw,rest,dn(raw),arity,kid(clean,0),kid(clean,1))
    case False{}:
      AgyAbsResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def agy_abs_try_body(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +clean: KTerm) -> AgyAbsResult:
  w7_br_890(p98_tag_eq(clean,"Mat") && agy_str_eq(nm(clean),"Zero") && U32.is_eq(terms_len(ks(clean)),2), ctx, orig_d, raw, rest, arity, clean)

@unsafe
def agy_abs_try_def(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyAbsResult:
  +t0 = j_strip(dt(raw))
  +arity = da(raw)
  +ok_sig = agy_str_eq(dk(raw),"Def") && Bool.not(db(raw) || du(raw)) && U32.is_eq(dx(raw),0) &&
    U32.is_ge(arity,2) && p98_tag_eq(t0,"All") && p198e_owner(kid(t0,0),"Nat")
  kc(AgyAbsResult,ok_sig,
    u => agy_abs_try_body(ctx,orig_d,raw,rest,arity,p205u_clean(dv(raw))),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_pass_step(+d: KDef, +tail_res: AgyAbsResult) -> AgyAbsResult:
  match tail_res:
    case AgyAbsResult{ctx1,out1,ch1}:
      +raw = lookup(ctx1,dn(d))
      agy_abs_join(ch1,kc(AgyAbsResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_abs_try_def(ctx1,d,raw,out1),
        u => AgyAbsResult{ctx1,Con{d,out1},False{}}))

@unsafe
def agy_abs_pass(+context: List<&2,KDef>, defs: List<&2,KDef>) -> AgyAbsResult:
  match defs:
    case Nil{}: AgyAbsResult{context,[],False{}}
    case Con{+d,rest}: agy_abs_pass_step(d,agy_abs_pass(context,rest))

@unsafe
def agy_abs_plan_go(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>, +res: AgyAbsResult) -> P86Plan:
  match res:
    case AgyAbsResult{ctx1,defs1,changed}:
      kc(P86Plan,changed && String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => agy_ctfe_plan(ctx1,stops,verdict,defs1),
        u => agy_ctfe_plan(context,stops,verdict,annotated))

@unsafe
def agy_abs_plan(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  agy_abs_plan_go(context,stops,verdict,annotated,agy_abs_pass(context,annotated))


# AGY-001: General Binary-Fork Nat-Depth U32.add Reduction Linearization.
# Rewrites checked binary-fork U32.add reductions:
#   f(0n, x, a...)   = BASE(x, a...)
#   f(1n+p, x, a...) = let a = f(p, x, a...); b = f(p, x + (STEP << p), a...) in a + b
# into a guarded tail-recursive Nat loop for d < 32n, preserving exact fallback for d >= 32n.

@unsafe
def agy_bf_match_peels(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +zp: AgyPeel, +sp: AgyPeel) -> AgyBFResult:
  match zp sp:
    case AgyPeel{lams0,base_expr,ok0} AgyPeel{lams1,succ_body,ok1}:
      kc(AgyBFResult,ok0 && ok1 && U32.is_eq(p205u_refs(base_expr,fname),0),
        u => agy_bf_emit(context,orig_d,raw,rest,fname,arity,clean,lams0,base_expr,agy_bf_check_succ(succ_body,fname,lams1)),
        u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def w7_br_899(w7_c: Bool, +context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +zbr: KTerm, +msucc: KTerm) -> AgyBFResult:
  match w7_c:
    case True{}:
      agy_bf_match_peels(context,orig_d,raw,rest,fname,arity,clean,agy_bf_peel(zbr,U32.sub(arity,1)),agy_bf_peel(kid(msucc,0),arity))
    case False{}:
      AgyBFResult{context,Con{orig_d,rest},False{}}

@unsafe
def agy_bf_match_succ(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +zbr: KTerm, +msucc: KTerm) -> AgyBFResult:
  w7_br_899(p98_tag_eq(msucc,"Mat") && agy_str_eq(nm(msucc),"Succ") && U32.is_eq(terms_len(ks(msucc)),2) && p98_tag_eq(kid(msucc,1),"Efq"), context, orig_d, raw, rest, fname, arity, clean, zbr, msucc)

@unsafe
def w7_br_900(w7_c: Bool, +context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm) -> AgyBFResult:
  match w7_c:
    case True{}:
      agy_bf_match_succ(context,orig_d,raw,rest,fname,arity,clean,kid(clean,0),kid(clean,1))
    case False{}:
      AgyBFResult{context,Con{orig_d,rest},False{}}

@unsafe
def agy_bf_match_body(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm) -> AgyBFResult:
  w7_br_900(p98_tag_eq(clean,"Mat") && agy_str_eq(nm(clean),"Zero") && U32.is_eq(terms_len(ks(clean)),2), context, orig_d, raw, rest, fname, arity, clean)

@unsafe
def agy_bf_try_def(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyBFResult:
  +fname = dn(raw)
  +arity = kc(U32,agy_str_eq(dk(raw),"Def") && Bool.not(db(raw) || du(raw)) && U32.is_eq(dx(raw),0),
    u => agy_bf_type_arity(dt(raw)),u => 0)
  kc(AgyBFResult,U32.is_ge(arity,2),
    u => agy_bf_match_body(context,orig_d,raw,rest,fname,arity,p205u_clean(dv(raw))),
    u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      +raw = lookup(ctx1,dn(d))
      agy_bf_join(ch1,kc(AgyBFResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_bf_try_def(ctx1,d,raw,out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))

@unsafe
def agy_bf_pass(+context: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{context,[],False{}}
    case Con{+d,rest}: agy_bf_pass_step(d,agy_bf_pass(context,rest))

@unsafe
def agy_bf_plan_go(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>, +res: AgyBFResult) -> P86Plan:
  match res:
    case AgyBFResult{ctx1,defs1,changed}:
      kc(P86Plan,changed && String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => agy_abs_plan(ctx1,stops,verdict,defs1),
        u => agy_abs_plan(context,stops,verdict,annotated))

@unsafe
def agy_bf_plan(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  agy_bf_plan_go(context,stops,verdict,annotated,agy_bf_pass(context,annotated))


# Wave 2 Track D: General Scalar/Interval Specialization + String Foldl Deforestation (W2D)
#
# 1. p205v (extended): specializes bounded pure helpers on constant/constructor operands,
#    folds total native U32 ops with literal OR sound U32 interval operands (mod/and/add),
#    folds Bool.and/Bool.or, reduces App(Mat, Ctr), and eliminates unused pure Let bindings.
# 2. w2d: general String left-fold shortcut deforestation + Constructor-Loop Unboxing.
#    Every synthesized helper and rewritten definition is mandatorily rechecked by Bend's
#    kernel checker (check_definition_body + ka_def + jl_checked_error), with exact fallback.

@unsafe
def w2d_try_unbox_loop(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32) -> W2State:
  +body = p205u_clean(dv(hdef))
  kc(W2State,p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"Zero") &&
    p98_tag_eq(kid(body,1),"Mat") && agy_str_eq(nm(kid(body,1)),"Succ"),
    u => w2d_try_unbox_peel(ctx,added,hdef,raw_body,hname,ar,next,kid(body,0),agy_bf_peel(kid(kid(body,1),0),U32.sub(ar,1))),
    u => W2State{ctx,added,next,atom("Absent"),False{}})

# ==============================================================================
# Build & check fused worker P$w2d$F
# ==============================================================================
@unsafe
def w2d_build_fused_check(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +wrapped: KTerm, +next3: U32) -> W2State:
  +raw_s = agy_bf_wrap_lams(s_lams_init,wrapped)
  +opt_body = kt("Mat","Zero",0,0,[z_body,kt("Mat","Succ",0,0,[raw_s,atom("Efq")])])
  +hdef = {KDef{hname,"Def",ar,0,hty,opt_body,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,agy_str_eq(dk(chk),"Absent"),
    u => W2State{ctx,added,next3,atom("Absent"),False{}},
    u => w2d_after_fused_res(ctx,added,next3,chk,hname,w2d_try_unbox_loop(ctx,added,chk,opt_body,hname,ar,next3)))

@unsafe
def w2d_build_fused_opt(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +rargs: List<&2,KTerm>, +step_ch: KTerm, +next2: U32) -> W2State:
  +ev = p205v_eval(ctx,step_ch,U32.inc(U32.max(next2,norm_max_term(step_ch))),0,256)
  +sc1 = p205v_finish(step_ch,ev)
  +wrapped = w2d_wrap_rec_in_step_opt(ctx,sc1,hname,rargs,bs,st_ty)
  kc(W2State,p98_tag_eq(wrapped,"Absent"),
    u => W2State{ctx,added,U32.add(next2,64),atom("Absent"),False{}},
    u => w2d_build_fused_check(ctx,added,hname,ar,hty,z_body,s_lams_init,wrapped,U32.add(next2,64)))

@unsafe
def w2d_build_fused_apply_ch(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +rargs: List<&2,KTerm>, +ev: P205UResult) -> W2State:
  match ev:
    case P205UResult{step_ch,n2,_,_}:
      w2d_build_fused_opt(ctx,added,hname,ar,hty,st_ty,z_body,s_lams_init,bs,rargs,step_ch,n2)

@unsafe
def w2d_build_fused_fresh(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rargs: List<&2,KTerm>, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{step_fresh,next2}:
      w2d_build_fused_apply_ch(ctx,added,hname,ar,hty,st_ty,z_body,s_lams_init,bs,rargs,
        p205v_apply(ctx,step_fresh,[ch_expr],next2,0,128))

@unsafe
def w2d_build_fused(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +hname: String, +pname: String, +ar: U32, +st_ty: KTerm, +step_fn: KTerm, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rargs: List<&2,KTerm>) -> W2State:
  +pd = lookup(ctx,pname)
  +hty = w2d_builder_fused_ty(dt(pd),ar,st_ty)
  +zvs = agy_bf_fresh_lams(U32.sub(ar,1),next,0)
  +z_body = agy_bf_wrap_vars(zvs,w2d_last(zvs))
  w2d_build_fused_fresh(ctx,added,hname,ar,hty,st_ty,z_body,w2d_init(lams1),bs,ch_expr,rargs,f_fresh_term(step_fn,[],U32.add(next,16)))

@unsafe
def w2d_ensure_fused(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +fold: W2Fold, +b: W2Builder) -> W2State:
  match fold b:
    case W2Fold{fname,st_ty,_,step_fn,_} W2Builder{pname,ar,_,lams0,lams1,bs,ch_expr,rargs,_}:
      +hname = pname ++ "$w2d$" ++ fname
      kc(W2State,Bool.not(agy_str_eq(dk(lookup(ctx,hname)),"Absent")),
        u => W2State{ctx,added,next,ref(hname),False{}},
        u => w2d_build_fused(ctx,added,next,hname,pname,ar,st_ty,step_fn,lams0,lams1,bs,ch_expr,rargs))

# ==============================================================================
# Common-Tuple-Fst Hoisting & Branch-Push
# ==============================================================================
law w2d_push:
  for +ctx: List<&2,KDef>
  for +added: List<&2,KDef>
  for +senv: List<&2,W2Bind>
  for +next: U32
  for +fold: W2Fold
  for +prod: KTerm
  for +st: KTerm
  for +fuel: U32
  W2State

@unsafe
def w2d_reduce_step(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +next: U32, +step_fn: KTerm, +ch: KTerm, +st: KTerm) -> FFresh:
  w2d_reduce_step_fr(ctx,st_ty,acc_ty,ch,st,f_fresh_term(step_fn,[],next))

@unsafe
def w2d_bind_acc_and_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +acc_expr: KTerm, +acc_ty: KTerm, +fuel: U32) -> W2State:
  +st_v = kt("Ctr","Tuple",0,1,[c_fst,var("$w2a",next)])
  w2d_bind_acc_wrap(next,acc_expr,acc_ty,w2d_push(ctx,added,senv,U32.inc(next),fold,tail,st_v,fuel))

@unsafe
def w2d_bind_state_and_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +st_expr: KTerm, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,st_ty,_,_,_}:
      +se = j_strip(st_expr)
      +acc_ty = w2d_st_snd_ty(st_ty)
      kc(W2State,p98_tag_eq(se,"Ctr") && agy_str_eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(j_strip(kid(se,0)),"Ctr") && List.is_empty(&2,KTerm,ks(j_strip(kid(se,0)))) &&
        Bool.not(p98_tag_eq(j_strip(kid(se,1)),"Var") || p205v_static(j_strip(kid(se,1)))),
        u => w2d_bind_acc_and_go(ctx,added,senv,next,fold,tail,j_strip(kid(se,0)),kid(se,1),acc_ty,fuel),
        u => w2d_push(ctx,added,senv,next,fold,tail,se,fuel))

@unsafe
def w7_br_934(w7_c: Bool, +ctx: List<&2,KDef>, +sc: KTerm, +call: KTerm, +next: U32) -> FFresh:
  match w7_c:
    case True{}:
      w2d_inline_small_char_def(ctx,sc,call,lookup(ctx,nm(call)),next)
    case False{}:
      FFresh{sc,next}

@unsafe
def w2d_inline_small_char_call(+ctx: List<&2,KDef>, +sc: KTerm, +call: KTerm, +next: U32) -> FFresh:
  w7_br_934(p98_tag_eq(call,"Call") && U32.is_le(terms_len(ks(call)),4), ctx, sc, call, next)

@unsafe
def w2d_inline_small_char(+ctx: List<&2,KDef>, +ch: KTerm, +next: U32) -> FFresh:
  +sc = j_strip(ch)
  kc(FFresh,p98_tag_eq(sc,"App"),u =>
    w2d_inline_small_char_call(ctx,sc,j_call_spine(sc,[]),next),
    u => FFresh{sc,next})

@unsafe
def w2d_scon_mat_ch_lifted(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +fuel: U32, +lifted: W2State) -> W2State:
  match lifted:
    case W2State{ctx2,added2,_,acc2,_}:
      w2d_bind_state_and_go(ctx2,added2,senv,next,fold,tail,kt("Ctr","Tuple",0,1,[c_fst,acc2]),fuel)

@unsafe
def w2d_scon_mat_ch_raw(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +raw: FFresh) -> W2State:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,512)
      +e1 = w2d_hoist_fst_ann(ctx,p205v_finish(e0,ev),st_ty,acc_ty)
      +se = j_strip(e1)
      +sst = j_strip(st)
      +n3 = U32.inc(U32.max(n2,norm_max_term(e1)))
      # If e1 = Tuple{C, App(App(Mat, a0), a1)} and st = Tuple{_, Var acc_id}, lift Mat to a top-level Def!
      kc(W2State,p98_tag_eq(se,"Ctr") && agy_str_eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(sst,"Ctr") && agy_str_eq(nm(sst),"Tuple") && p98_tag_eq(j_strip(kid(sst,1)),"Var"),
        u => w2d_scon_mat_ch_lifted(ctx,added,senv,U32.inc(n3),fold,tail,kid(se,0),fuel,
               w2d_lift_mat2_acc(ctx,added,"$w2d$m2$" ++ nm(j_strip(kid(se,0))) ++ "$" ++ U32.show(n3) ++ "$" ++ U32.show(nt_count(KDef,ctx)),kid(se,1),ix(j_strip(kid(sst,1))),acc_ty,j_strip(kid(sst,1)))),
        u => w2d_bind_state_and_go(ctx,added,senv,n3,fold,tail,e1,fuel))

@unsafe
def w2d_scon_mat_ch_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +cid: U32, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +ch_mat: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{sf,n1}:
      +fn_c = agy_bf_lam("$w2c",cid,2,app(app(sf,var("$w2c",cid)),st))
      w2d_scon_mat_ch_raw(ctx,added,senv,fold,st_ty,acc_ty,tail,st,fuel,w2d_push_into_mat(fn_c,ch_mat,n1))

@unsafe
def w2d_scon_direct_lifted(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +n1: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +fuel: U32, +lifted: W2State) -> W2State:
  match lifted:
    case W2State{ctx2,added2,_,acc2,_}:
      w2d_bind_state_and_go(ctx2,added2,senv,n1,fold,tail,kt("Ctr","Tuple",0,1,[c_fst,acc2]),fuel)

@unsafe
def w2d_scon_direct_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +ch: KTerm, +tail: KTerm, +fuel: U32, +r: FFresh) -> W2State:
  match r:
    case FFresh{st1,n1}:
      +se = j_strip(st1)
      # If st1 = Tuple{C, App(Ann(Mat "Tuple" ...), arg)} where ch is literal Chr{code}, lift Mat to $w2d$ch$<code>!
      kc(W2State,p98_tag_eq(se,"Ctr") && agy_str_eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(j_strip(kid(se,1)),"App") && p98_tag_eq(j_strip(kid(j_strip(kid(se,1)),0)),"Mat") &&
        agy_str_eq(nm(j_strip(kid(j_strip(kid(se,1)),0))),"Tuple") &&
        p98_tag_eq(j_strip(ch),"Ctr") && agy_str_eq(nm(j_strip(ch)),"Chr") && p205v_static(j_strip(ch)),
        u => w2d_scon_direct_lifted(ctx,added,senv,U32.inc(n1),fold,tail,kid(se,0),fuel,
               w2d_lift_closed_mat(ctx,added,"$w2d$ch$" ++ U32.show(w2d_u32_or0(j_u32(j_strip(kid(j_strip(ch),0))))) ++ "$" ++ U32.show(n1) ++ "$" ++ U32.show(nt_count(KDef,ctx)),st_ty,acc_ty,
                 kid(j_strip(kid(se,1)),0),kid(j_strip(kid(se,1)),1))),
        u => w2d_bind_state_and_go(ctx,added,senv,n1,fold,tail,st1,fuel))

@unsafe
def w2d_push_scon_ch(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +step_fn: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +ch_opt: FFresh) -> W2State:
  match ch_opt:
    case FFresh{ch2,n1}:
      kc(W2State,w2d_is_small_mat(ch2),
        u => w2d_scon_mat_ch_fr(ctx,added,senv,n1,fold,st_ty,acc_ty,ch2,tail,st,fuel,f_fresh_term(step_fn,[],U32.inc(n1))),
        u => w2d_scon_direct_res(ctx,added,senv,fold,st_ty,acc_ty,ch2,tail,fuel,w2d_reduce_step(ctx,st_ty,acc_ty,n1,step_fn,ch2,st)))

@unsafe
def w2d_push_scon(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +ch: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,st_ty,_,step_fn,_}:
      w2d_push_scon_ch(ctx,added,senv,fold,st_ty,w2d_st_snd_ty(st_ty),step_fn,tail,st,fuel,w2d_inline_small_char(ctx,ch,next))

@unsafe
def w2d_push_let(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +b: KTerm, +body: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +rhs = kid(b,0)
  +bid = ix(b)
  +uses = p205u_vars(body,bid)
  kc(W2State,U32.is_eq(uses,0) && p205v_pure(ctx,rhs,16),
    u => w2d_push(ctx,added,senv,next,fold,body,st,fuel),u =>
  kc(W2State,U32.is_eq(uses,1) && w2d_is_str_rhs(ctx,rhs),
    v => w2d_push(ctx,added,Con{W2Bind{bid,rhs},senv},next,fold,body,st,fuel),
    v => w2d_push_let_keep(b,w2d_push(ctx,added,senv,next,fold,body,st,fuel))))

@unsafe
def w2d_push_inline_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32, +ev: P205UResult) -> W2State:
  match ev:
    case P205UResult{term,n2,_,True{}}: w2d_push(ctx,added,senv,n2,fold,term,st,fuel)
    case P205UResult{_,n2,_,False{}}: w2d_push_fallback(ctx,added,senv,n2,fold,prod,st)

@unsafe
def w2d_push_inline_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +prod: KTerm, +args: List<&2,KTerm>, +st: KTerm, +fuel: U32, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{fb,n1}: w2d_push_inline_res(ctx,added,senv,fold,prod,st,fuel,p205v_apply(ctx,fb,args,n1,0,256))

@unsafe
def w2d_push_after_builder(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +href: KTerm, +bargs: List<&2,KTerm>, +rest_str: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +raw_call = agy_bf_apps(href,nt_append(KTerm,bargs,[st]))
  +ev = p205v_eval(ctx,raw_call,U32.inc(U32.max(next,norm_max_term(raw_call))),0,256)
  +st1 = p205v_finish(raw_call,ev)
  +n2 = U32.inc(U32.max(next,norm_max_term(st1)))
  w2d_push(ctx,added,senv,n2,fold,rest_str,st1,fuel)

@unsafe
def w2d_push_rec_ens(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +st: KTerm, +fuel: U32, +ens: W2State) -> W2State:
  match ens:
    case W2State{ctx2,added2,next2,href,_}:
      kc(W2State,p98_tag_eq(href,"Absent"),
        u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st),
        u => w2d_push_after_builder(ctx2,added2,senv,next2,fold,href,w2d_init(ks(call)),w2d_last(ks(call)),st,fuel))

@unsafe
def w2d_push_rec_builder(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +b: W2Builder, +st: KTerm, +fuel: U32) -> W2State:
  match b:
    case W2Builder{_,_,_,_,_,_,_,_,True{}}:
      w2d_push_rec_ens(ctx,added,senv,next,fold,prod,call,st,fuel,w2d_ensure_fused(ctx,added,next,fold,b))
    case _: w2d_push_fallback(ctx,added,senv,next,fold,prod,st)

@unsafe
def w7_br_937(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +d: KDef, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_inline_fr(ctx,added,senv,fold,prod,ks(call),st,fuel,f_fresh_term(p205u_clean(dv(d)),[],next))
    case False{}:
      w2d_push_rec_builder(ctx,added,senv,next,fold,prod,call,w2d_check_rec_builder(d),st,fuel)

@unsafe
def w2d_push_call_def(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +d: KDef, +st: KTerm, +fuel: U32) -> W2State:
  w7_br_937(agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) && U32.is_eq(da(d),terms_len(ks(call))) && U32.is_eq(p205u_refs(dv(d),dn(d)),0) && p205u_room([dv(d)],128) && p198e_owner(p205u_after_args(ctx,dt(d),da(d)),"String"), ctx, added, senv, next, fold, prod, call, d, st, fuel)

@unsafe
def w7_br_938(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_call_def(ctx,added,senv,next,fold,prod,call,lookup(ctx,nm(call)),st,fuel)
    case False{}:
      w2d_push_fallback(ctx,added,senv,next,fold,prod,st)

@unsafe
def w2d_push_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  w7_br_938(p98_tag_eq(call,"Call") && U32.is_ge(terms_len(ks(call)),2) && U32.is_le(terms_len(ks(call)),5), ctx, added, senv, next, fold, prod, call, st, fuel)

@unsafe
def w2d_push_nil(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +st: KTerm) -> W2State:
  match fold:
    case W2Fold{_,_,nil_fn,_,_}:
      w2d_push_nil_fr(ctx,added,senv,st,f_fresh_term(nil_fn,[],next))

@unsafe
def w2d_push_var(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +found = w2d_senv_get(senv,ix(prod))
  kc(W2State,p98_tag_eq(found,"Absent"),
    u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st),
    u => w2d_push(ctx,added,w2d_senv_del(senv,ix(prod)),next,fold,found,st,fuel))

@unsafe
def w7_br_939(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_call(ctx,added,senv,next,fold,prod,j_call_spine(prod,[]),st,fuel)
    case False{}:
      w2d_push_fallback(ctx,added,senv,next,fold,prod,st)

@unsafe
def w7_br_940(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_let(ctx,added,senv,next,fold,kid(prod,0),w2d_let_rest(List.tail(&2,KTerm,ks(prod))),st,fuel)
    case False{}:
      w7_br_939(p98_tag_eq(prod,"App"), ctx, added, senv, next, fold, prod, st, fuel)

@unsafe
def w7_br_941(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_scon(ctx,added,senv,next,fold,kid(prod,0),kid(prod,1),st,fuel)
    case False{}:
      w7_br_940(p98_tag_eq(prod,"Let") && U32.is_ge(terms_len(ks(prod)),2) && p98_tag_eq(kid(prod,0),"Bind"), ctx, added, senv, next, fold, prod, st, fuel)

@unsafe
def w7_br_942(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_nil(ctx,added,senv,next,fold,st)
    case False{}:
      w7_br_941(p98_tag_eq(prod,"Ctr") && agy_str_eq(nm(prod),"SCon") && U32.is_eq(terms_len(ks(prod)),2), ctx, added, senv, next, fold, prod, st, fuel)

@unsafe
def w7_br_943(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_var(ctx,added,senv,next,fold,prod,st,fuel)
    case False{}:
      w7_br_942(p98_tag_eq(prod,"Ctr") && agy_str_eq(nm(prod),"SNil") && List.is_empty(&2,KTerm,ks(prod)), ctx, added, senv, next, fold, prod, st, fuel)

@unsafe
def w2d_push_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  w7_br_943(p98_tag_eq(prod,"Var"), ctx, added, senv, next, fold, prod, st, fuel)

@unsafe
def w7_br_944(w7_c: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match w7_c:
    case True{}:
      w2d_push_fallback(ctx,added,senv,next,fold,prod,st)
    case False{}:
      w2d_push_go(ctx,added,senv,next,fold,j_strip(prod),st,U32.sub(fuel,1))

@unsafe
def w2d_push(ctx, added, senv, next, fold, prod, st, fuel):
  w7_br_944(U32.is_eq(fuel,0), ctx, added, senv, next, fold, prod, st, fuel)

# ==============================================================================
# Top-level W2D Walker and Plan Integration
# ==============================================================================
law w2d_walk:
  for +ctx: List<&2,KDef>
  for +added: List<&2,KDef>
  for +next: U32
  for +t: KTerm
  for +fuel: U32
  W2State

@unsafe
def w2d_walk_step(+parent: KTerm, +rest: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,x2,ch2}:
      w2d_walk_list(ctx2,added2,next2,parent,rest,Con{x2,acc},ch || ch2,fuel)

@unsafe
def w2d_walk_list(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32) -> W2State:
  match xs:
    case Nil{}: W2State{ctx,added,next,k_with_children(parent,nt_reverse(KTerm,acc,[])),ch}
    case Con{x,rest}: w2d_walk_step(parent,rest,acc,ch,fuel,w2d_walk(ctx,added,next,x,fuel))

@unsafe
def w2d_walk_children(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +fuel: U32) -> W2State:
  w2d_walk_list(ctx,added,next,parent,xs,[],False{},fuel)

@unsafe
def w2d_walk_check_fold(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fold: W2Fold, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,_,_,_,True{}}:
      w2d_push(ctx,added,[],next,fold,p205u_at(ks(call),0),p205u_at(ks(call),1),256)
    case _: w2d_walk_children(ctx,added,next,t,ks(t),fuel)

@unsafe
def w5c3_w2d_call_if(ok: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  match ok:
    case True{}: w2d_walk_check_fold(ctx,added,next,t,call,w2d_check_fold(ctx,lookup(ctx,nm(call))),fuel)
    case False{}: w2d_walk_children(ctx,added,next,t,ks(t),fuel)

@unsafe
def w2d_walk_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  w5c3_w2d_call_if(p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2) && w2d_is_fusable_prod(p205u_at(ks(call),0)),
    ctx, added, next, t, call, fuel)

@unsafe
def w5c3_w2d_app(is_app: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +f1: U32) -> W2State:
  match is_app:
    case True{}: w2d_walk_call(ctx,added,next,t,j_call_spine(t,[]),f1)
    case False{}: w2d_walk_children(ctx,added,next,t,ks(t),f1)

@unsafe
def w5c3_w2d_ann(is_ann: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +f1: U32) -> W2State:
  match is_ann:
    case True{}: w2d_walk_ann(ctx,added,next,t,f1)
    case False{}: w5c3_w2d_app(p98_tag_eq(t,"App"), ctx, added, next, t, f1)

@unsafe
def w5c3_w2d_fuel(z: Bool, +ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +fuel: U32) -> W2State:
  match z:
    case True{}: W2State{ctx,added,next,t,False{}}
    case False{}: w5c3_w2d_ann(p98_tag_eq(t,"Ann"), ctx, added, next, t, U32.sub(fuel,1))

@unsafe
def w2d_walk(ctx, added, next, t, fuel):
  w5c3_w2d_fuel(U32.is_eq(fuel,0), ctx, added, next, t, fuel)

@unsafe
def w2d_walk_ann(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +fuel: U32) -> W2State:
  w2d_walk_ann_res(t,w2d_walk(ctx,added,next,kid(t,0),fuel))

@unsafe
def w2d_try_def(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyBFResult:
  +body = dv(raw)
  +next0 = U32.inc(U32.max(norm_book_bound(ctx),norm_max_term(body)))
  w2d_try_def_res(ctx,orig_d,raw,rest,w2d_walk(ctx,[],next0,body,256))

@unsafe
def w2d_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      agy_bf_join(ch1,kc(AgyBFResult,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => w2d_try_def(ctx1,d,d,out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))

@unsafe
def w2d_pass(+ctx: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{ctx,[],False{}}
    case Con{+d,rest}: w2d_pass_step(d,w2d_pass(ctx,rest))

@unsafe
def w2d_plan(ctx, stops, verdict, defs):
  w2d_plan_res(ctx,stops,verdict,defs,w2d_pass(ctx,defs))


@unsafe
def p86_plan_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  +error = jl_checked_error(context, annotated, ["main"], stops)
  kc(P86Plan, String.is_empty(error),
    u => agy_bf_plan(context,stops,verdict,annotated),
    u => P86PlanError{"compile: " ++ error})

# Sized read plus EOF verification, adapted from the historical rapid host.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:692
law w8_p113pl_cands_loop:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  for +bangMap: KDef
  for +signatures: List<&2,KDef>
  for +acc: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

@unsafe
def w8_p113pl_cands_flat(isFlat: Bool, +book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangMap: KDef, +signatures: List<&2,KDef>, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match isFlat:
    case True{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,Con{p113pl_flat_candidate(book,name,signatures),acc})
    case False{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,acc)

@unsafe
def w8_p113pl_cands_ok(ok: Bool, +book: List<&2,KDef>, +name: String, +definition: KDef, +rest: List<&2,String>, +bangMap: KDef, +signatures: List<&2,KDef>, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match ok:
    case True{}:
      +sel = p121f_selected(book,name,signatures,p121f_plan(book,definition))
      +acc1 = w8_push_rev(sel,acc)
      +info = lookup(signatures,name)
      w8_p113pl_cands_flat(agy_str_eq(tg(dv(info)),"NQSig"),book,name,rest,bangMap,signatures,acc1)
    case False{}: w8_p113pl_cands_loop(book,rest,bangMap,signatures,acc)

@unsafe
def w8_p113pl_cands_loop(book,names,bangMap,signatures,acc):
  match names:
    case Nil{}: nt_reverse(P113DCandidate,acc,[])
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +bh = index_hash(name,2166136261)
      +isBang = Bool.not(agy_str_eq(dk(w5c3_find(bangMap,name,bh)),"Absent"))
      w8_p113pl_cands_ok(agy_str_eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || isBang) && U32.is_le(nd_arity(book,name),64),
        book,name,definition,rest,bangMap,signatures,acc)

@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  w8_p113pl_cands_loop(book,names,w8_bangs_index(bangs,missing()),signatures,[])

@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match table:
    case P113IEmpty{}: w7_p113k_once(function)
    case _: w7_p113i_nonempty(function,table)


@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p198e_select(book,name,signatures,plan,p198e_plan(book,lookup(book,name)))

@unsafe
def p128br_replan(+book: List<&2,KDef>, +plan: NO_Plan, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +schema = no_plan_schema(plan)
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(no_plan_owner(plan),schema,noa_analyze_ready(NO_Context{book,no_plan_owner(plan),schema,helpers})),
    u => p128br_plan(book,no_plan_owner(plan),helpers))

law p171sc_retry:
  for +book: List<&2,KDef>
  for plans: List<&2,NO_Plan>
  for +original: List<&2,P113DFunction>
  for +helpers: List<&2,P128BRHelper>
  for +catalogue: Maybe<&2,List<&2,NO_Spec>>
  P128BRPatches

@unsafe
def p128br_retry_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  p171sc_retry(book,plans,original,helpers,None{})


@unsafe
def p141p_raw(stopped: P140PStop) -> FRawResult:
  match stopped:
    case P140PDone{raw}: raw
    case P140PCut{input,book,imports,unsafe,scope}:
      p141p_raw(p140p_top(0,input,book,imports,unsafe,scope))


@unsafe
def p143cp_walk(events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +logging: Bool) -> DChecking:
  match events:
    case Nil{}: DChecking{bad(world,""),dg_no_report("","")}
    case Con{P143CEvent{+definition,+next},+rest}:
      p143cp_guard(rest,world,seen,definition,next,logging,
        event_error(seen,definition,lookup(seen,dn(definition))))


@unsafe
def w7_br_976(w7_c: Bool, +rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +definition: KDef, +next: KDef, +logging: Bool, +guard: String) -> DChecking:
  match w7_c:
    case True{}:
      p143cp_next(rest,seen,definition,next,logging, check_definition_world(world,p143cs_mode(definition,next),0))
    case False{}:
      DChecking{bad(world,dn(definition) ++ ": " ++ guard),dg_no_report(dn(definition),guard)}

@unsafe
def p143cp_guard(+rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>,
    +definition: KDef, +next: KDef, +logging: Bool, +guard: String) -> DChecking:
  w7_br_976(p88_string_eq(guard,""), rest, world, seen, definition, next, logging, guard)


@unsafe
def w7_br_977(w7_c: Bool, +rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef, +next: KDef, +logging: Bool, +result: KChecking) -> DChecking:
  match w7_c:
    case True{}:
      p143cp_walk(rest,p143cp_publish(definition,next,result,logging),book_put(seen,definition),logging)
    case False{}:
      dg_event_failed(result,dn(definition))

@unsafe
def p143cp_next(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +logging: Bool, +result: KChecking) -> DChecking:
  w7_br_977(good(result), rest, seen, definition, next, logging, result)


@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = w7c_declare_cached(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world : KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p156cp_start(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)


@unsafe
def p143cb_resume(prepared: KBasePreparedWorld, suffix: List<&2,KDef>, bound: U32, logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,prefix,final,book,checked,seen,todos,checkedBound}:
      p143cb_resume_state(state,book,checked,seen,suffix,bound,logging)


@unsafe
def p143cb_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>,
    +bound: U32, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      nt_choose(DChecking,p143cp_regular(suffix) &&
        base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
        u => p143cb_resume(prepared,suffix,bound,logging),
        u => base_prefix_world_check_admitted(prepared,prefix,suffix,bound))


@unsafe
def p143cb_program_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool,
    +origins: List<&2,DOrigin>, +logging: Bool) -> DResult:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DResult,ready && String.is_empty(error) &&
        base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => driver_program_checked_prefix(suffix,todos,origins,
          p143cb_admitted(prepared,prefix,suffix,bound,logging)),
        u => driver_program_checked(book,origins,dg_check_world(book)))


@unsafe
def p143cb_program(load: FPrefixLoad, +origins: List<&2,DOrigin>, +prepared: KBasePreparedWorld,
    +logging: Bool) -> DResult:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p143cb_program_book(prepared,book,error,prefix,suffix,ready,origins,logging)

@unsafe
def p168_finished(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, patches: P128BRPatches) -> P167Lowered:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_finish_functions(source,book,names,constructors,nodes,bangs,
          nt_append(U32,stats,[nt_count(P128BRPatch,edits)]),p128br_apply(functions,edits)),
        u => p167l_fail("early scalar consumer retry: " ++ error))



@unsafe
def p168_finish_functions(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_stats(p167l_functions(source,book,names,constructors,nodes,bangs,functions),
    nt_append(U32,stats,[nt_count(P113DFunction,functions)]))



@unsafe
def p168_retry(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>,
    +retry: List<&2,NO_Plan>) -> P167Lowered:
  p168_finished(source,book,names,constructors,nodes,bangs,
    nt_append(U32,stats,[nt_count(P128BRHelper,helpers),nt_count(NO_Plan,retry)]),functions,
    p128br_retry_plans(book,retry,functions,helpers))



@unsafe
def p168_scalar_verified(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, +added: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_retry(source,book,names,constructors,nodes,bangs,
      nt_append(U32,stats,[nt_count(P113DFunction,added)]),
      nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing()))),helpers,retry),
    u => p167l_fail("early scalar closed-worker verification: " ++ error))



@unsafe
def p168_scalar_result(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+added,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scalar_verified(source,book,names,constructors,nodes,bangs,stats,functions,added,helpers,retry,
          p167ob_seed_verify(constructors,added)),
        u => p167l_fail("early scalar production: " ++ error))



@unsafe
def p168_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p168_scalars(book,retry,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))



# New internal mode2 differs only at the protected ordinary-composition step.
# The old mode1 and mode0 bodies are copied exactly from the admission treatment.
@unsafe
def p168_closed(+mode: U32, +source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +stats: List<&2,U32>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  +stats = nt_append(U32,stats,[nt_count(P113DFunction,functions)])
  nt_choose(P167Lowered,U32.is_eq(mode,2),
    u => p169o_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
      p169q_plans(book,retry),seeds,functions),
    u => nt_choose(P167Lowered,U32.is_eq(mode,1),
      v => p169q_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
        p169q_plans(book,retry),seeds,functions),
      v => p168_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,retry,functions)))



# W4-6 Pass 1: General $direct.<f> -> $product.<f> boxed-entry unboxing adapter.
# When a public $direct.<f> has a verified $product.<f> worker in the admitted set,
# replace $direct.<f>'s body with a thin wrapper that unpacks boxed product args once,
# calls $product.<f>, and boxes the returned product (if any), then re-toposorts via p113d_passes.

@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +signatures: List<&2,KDef>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  +fns0 = p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32)
  +fns1 = w4p_adapt_functions(fns0,ready,workers,signatures)
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,fns1)



@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  +sigs = book_cached(nq_signatures(book,names),0)
  +filtered = w7_filter_remaining(book,remaining,bangs)
  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,
    sigs,p113pl_candidates(book,filtered,bangs,sigs))



@unsafe
def p168_seed_verified(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_selected(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
      p167ob_remaining(book,names,bangs,p113e_signatures(workers,missing()))),
    u => p167l_fail("early scalar observer verification: " ++ error))



@unsafe
def p168_scanned(mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_seed_verified(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
          p167ob_seed_verify(constructors,workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))



@unsafe
def p168_prepared(mode: U32, source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scanned(mode,source,book,names,constructors,nodes,bangs,
          p128br_scan(book,no_candidate_names(book,names,bangs),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))



@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,p112s_prepare(book,names,constructors))



# Do not authorize this from the later prepared book, a workload name or a
# caller-supplied certificate. Invalid public modes fail before any lowering.
@unsafe
def p168_request_mode(+mode: U32, +request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,U32.is_gt(mode,1),u => p167l_fail("early scalar mode must be 0 or 1"),u =>
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v => p168_catalogued(nt_choose(U32,U32.is_eq(mode,1),
            w => p169o_certified(mode,p113a_certificate(request)),w => mode),
            source,book,names,nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error)))


# Experimental alternative to broad p168_inline. Load after early-scalars.bend
# with the sole explicit experimental override p168_closed. Frozen API01 keeps
# its original policy; in this API mode0 is unchanged and mode1 is selective.

@unsafe
def p168t_target(+original: P113DFunction, table: P113ITable) -> P113DFunction:
  match original:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => original,
        u => p168t_accept(original,p113i_function(original,table)))



@unsafe
def p168t_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p168t_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p168t_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p168t_walk(rest,seeds,blocked,targets,
                nt_choose(P113ITable,p113i_original_clean(head) && p128bs_leaf(body),
                  w => p113i_table_function(head,table),w => table),Con{head,reversed})))



@unsafe
def p168t_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p168t_walk(functions,seeds,blocked,targets,P113IEmpty{},[])


# Renderer-only callable metadata experiment. The semantic program remains
# private and must pass p167ob_final unchanged before this copy is constructed.
# Only an actual authenticated adapter can grant a public renderer signature.

@unsafe
def p169s_lowered(+request: NR_Request, lowered: P167Lowered) -> P169Prepared:
  match request lowered:
    case NR_Request{source,+book,names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169a_original(request,adapters,program,
          p167v_original(book,nc_bangs_names(book,names),program,adapters)),
        u => p169s_fail("adapter renderer lowering: " ++ error))


# Private Phase169 successor. No producer-owned Boolean authorizes machine code:
# the unchanged eligibility predicate is evaluated against this exact prepared
# book and immutable plan, then reused only before those inputs can change.

@unsafe
def p169q_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, plans: List<&2,P169ScalarPlan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p169q_scalars(book,plans,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))



@unsafe
def p169q_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p168t_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))


# Independent optional ablation. Every True condition is identical to the
# maintained p128bs_eligible; expensive stages run only after prior admission.

@unsafe
def p156cp_continue(rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    world: KWorld, dirty: Bool) -> DChecking:
  p156cp_walk(rest,world,p171s_put(seen,definition),dirty)



@unsafe
def p156cp_stored(rest: List<&2,P143CEvent>, seen: List<&2,KDef>, +definition: KDef,
    term: KTerm, world: KWorld, book: List<&2,KDef>, dirty: Bool) -> DChecking:
  p156cp_continue(rest,seen,definition,
    kw_put_checked(kw_with_book(world,book),dg_event_output(definition,term)),dirty)



@unsafe
def w7c_p156cp_put_cached(canLog: Bool, +rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +cache: KDef, +tail: List<&2,KDef>, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match canLog:
    case True{}:
      p156cp_stored(rest,seen,definition,term,world,p143cp_logged(cache,tail,definition),True{})
    case False{}:
      p156cp_stored(rest,seen,definition,term,world,
        book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{})

@unsafe
def p156cp_put(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match book:
    case Nil{}: p156cp_stored(rest,seen,definition,term,world,book_put(book,definition),False{})
    case Con{+cache,+tail}:
      w7c_p156cp_put_cached(p88_string_eq(dk(cache),"BookCache") && Bool.not(p88_string_eq(dk(definition),"BookCache")),
        rest,seen,definition,term,world,cache,tail,book,dirty)



@unsafe
def w7_br_980(w7_c: Bool, +rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef, +result: KChecking, +dirty: Bool) -> DChecking:
  match w7_c:
    case True{}:
      p156cp_put(rest,seen,definition,ct(result),rw(result),kw_book(rw(result)),dirty)
    case False{}:
      p156cp_continue(rest,seen,definition,rw(result),dirty)

@unsafe
def p156cp_publish(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +result: KChecking, +dirty: Bool) -> DChecking:
  w7_br_980(p88_string_eq(dk(next),"Absent"), rest, seen, definition, result, dirty)



@unsafe
def w7_br_981(w7_c: Bool, +rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef, +next: KDef, +dirty: Bool, +result: KChecking) -> DChecking:
  match w7_c:
    case True{}:
      p156cp_publish(rest,seen,definition,next,result,dirty)
    case False{}:
      dg_event_failed(result,dn(definition))

@unsafe
def p156cp_next(+rest: List<&2,P143CEvent>, +seen: List<&2,KDef>, +definition: KDef,
    +next: KDef, +dirty: Bool, +result: KChecking) -> DChecking:
  w7_br_981(good(result), rest, seen, definition, next, dirty, result)



@unsafe
def w7_br_982(w7_c: Bool, +rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +definition: KDef, +next: KDef, +dirty: Bool, +guard: String) -> DChecking:
  match w7_c:
    case True{}:
      p156cp_next(rest,seen,definition,next,dirty, check_definition_world(world,p143cs_mode(definition,next),0))
    case False{}:
      DChecking{bad(world,dn(definition) ++ ": " ++ guard),dg_no_report(dn(definition),guard)}

@unsafe
def p156cp_guard(+rest: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>,
    +definition: KDef, +next: KDef, +dirty: Bool, +guard: String) -> DChecking:
  w7_br_982(p88_string_eq(guard,""), rest, world, seen, definition, next, dirty, guard)



@unsafe
def p156cp_walk(events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, +dirty: Bool) -> DChecking:
  match events:
    case Nil{}: DChecking{bad(world,""),dg_no_report("","")}
    case Con{P143CEvent{+definition,+next},+rest}:
      p156cp_guard(rest,world,seen,definition,next,dirty,
        event_error(seen,definition,lookup(seen,dn(definition))))
# Inserted immediately before the first replacement's lexical use.
@unsafe
def w7_br_983(w7_c: Bool, +events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>) -> DChecking:
  match w7_c:
    case True{}:
      p156cp_walk(events,world,p171s_seed(seen),True{})
    case False{}:
      p143cp_walk(events,world,seen,False{})

@unsafe
def p156cp_start(+events: List<&2,P143CEvent>, +world: KWorld, +seen: List<&2,KDef>, logging: Bool) -> DChecking:
  w7_br_983(logging, events, world, seen)


# Optional private Phase169 successor: original/static/adapter admission and
# private-input discipline stay unchanged. The SAME flag-only renderer view
# receives the full unchanged borrowed/direct body verifier exactly once.
# Public flags only add the existing original-wrapper ABI obligation; body
# projection and dependency-call contracts do not consume signature public bits.
# No producer certificate, body hash or trusted Boolean replaces verification.

@unsafe
def p169np_admitted(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_lowered(request,p168_request_mode(1,request)),
    u => p169s_fail("compile: " ++ error))



@unsafe
def p169np_plan(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      p169np_admitted(request,p111_runtime_admission(request))


# Optional restoration of the maintained source-authorized mode2 renderer.
# The actual request derives its certificate; no workload/name selects a mode.

@unsafe
def p169a_view(+request: NR_Request, +adapters: KDef, +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169a_checked(request,adapters,program,original,nodes,view,p113a_certificate(request),
        p118b_verify_functions(view,original))



@unsafe
def p169a_original(request: NR_Request, adapters: KDef, +program: P113DProgram,
    +error: String) -> P169Prepared:
  match program:
    case P113DProgram{original,+functions}:
      nt_choose(P169Prepared,String.is_empty(error),u =>
        nt_choose(P169Prepared,p167v_private(functions),
          v => p169a_view(request,adapters,program),
          v => p169s_fail("adapter renderer original final IR: observer first final worker must be private")),
        u => p169s_fail("adapter renderer original final IR: " ++ error))


# Optional bounded ordinary composition BEFORE borrowed-worker conversion.
# Seed and every retry owner remain excluded from table publication. The only
# extra work is ordinary nonblocked p113i_function plus its original table gate.
# Normal entry derives the existing certificate from the actual request; mode2
# is internal only. The public p168_request_mode still admits only modes0/1.

law p169o_walk:
  for functions: List<&2,P113DFunction>
  for +seeds: KDef
  for +blocked: KDef
  for +targets: KDef
  for +zipOwners: KDef
  for +table: P113ITable
  for +reversed: List<&2,P113DFunction>
  List<&2,P113DFunction>

@unsafe
def p169o_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    blocked: KDef, targets: KDef, +zipOwners: KDef, +table: P113ITable,
    reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p169o_walk(rest,seeds,blocked,targets,zipOwners,
    nt_choose(P113ITable,Bool.not(p113d_ready(zipOwners,w4c_fn_name(original))) && p113i_original_clean(original),
      u => p113i_table_function(function,table),u => table),Con{function,reversed})



@unsafe
def w7c_p169o_tgt(isTgt: Bool, +head: P113DFunction, rest: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef, +targets: KDef, +zipOwners: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match isTgt:
    case True{}: p169o_walk(rest,seeds,blocked,targets,zipOwners,table,Con{p168t_target(head,table),reversed})
    case False{}: p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,p113i_function(head,table))

@unsafe
def w7c_p169o_seed(isSeed: Bool, +head: P113DFunction, +name: String, +h: U32, rest: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef, +targets: KDef, +zipOwners: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match isSeed:
    case True{}:
      p169o_walk(rest,seeds,blocked,targets,zipOwners,
        nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && agy_str_eq(dk(w5c3_find(zipOwners,name,h)),"Absent") && p113i_original_clean(head),
          w => p113i_table_function(head,table),w => table),Con{head,reversed})
    case False{}:
      w7c_p169o_tgt(Bool.not(agy_str_eq(dk(w5c3_find(targets,name,h)),"Absent")),head,rest,seeds,blocked,targets,zipOwners,table,reversed)

@unsafe
def p169o_walk(functions,seeds,blocked,targets,zipOwners,table,reversed):
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          +h = index_hash(name,2166136261)
          w7c_p169o_seed(agy_str_eq(dk(w5c3_find(seeds,name,h)),"P113Direct"),head,name,h,rest,seeds,blocked,targets,zipOwners,table,reversed)



@unsafe
def p169o_selected(functions: List<&2,P113DFunction>, seeds: KDef, zipOwners: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p169o_walk(functions,seeds,blocked,targets,zipOwners,P113IEmpty{},[])



@unsafe
def p169o_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  +zipOwners = w4c_zip_owners_map(book)
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p169o_selected(functions,seeds,zipOwners,p169q_selection(book,plans,missing(),missing())))



@unsafe
def p171sc_replan(+book: List<&2,KDef>, +plan: NO_Plan, +helpers: List<&2,P128BRHelper>,
    +catalogue: Maybe<&2,List<&2,NO_Spec>>) -> P171SCPlan:
  nt_choose(P171SCPlan,String.is_empty(no_schema_error(no_plan_schema(plan))),
    u => P171SCPlan{p128br_replan(book,plan,helpers),catalogue},
    u => p171sc_ordinary(book,no_plan_owner(plan),helpers,catalogue,no_schema(book,lookup(book,no_plan_owner(plan)),0)))

@unsafe
def p171sc_retry_step(+book: List<&2,KDef>, +rest: List<&2,NO_Plan>,
    +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, planned: P171SCPlan) -> P128BRPatches:
  match planned:
    case P171SCPlan{+plan,catalogue}:
      p128br_join(p128br_candidate(book,no_plan_owner(plan),original,plan),
        p171sc_retry(book,rest,original,helpers,catalogue))

@unsafe
def p171sc_retry(book,plans,original,helpers,catalogue):
  match plans:
    case Nil{}: P128BRPatches{[],""}
    case Con{plan,rest}:
      p171sc_retry_step(book,rest,original,helpers,p171sc_replan(book,plan,helpers,catalogue))
law x181_direct:
  for +function: P113DFunction
  for +ids: N111Ids
  X181Output
law x181_segment:
  for +segment: N111Segment
  for +ids: N111Ids
  X181Output
@unsafe
def x186_f_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  +placement = x186_f_placement_rows(nodes)
  +all = nt_append(P113DStmt,setup,placement)
  x186_x_select_frame(symbol,params,setup,nodes,ids,x186_saves_frame(x190_allocate_frame(
    x181_frame(symbol,params,all),params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,u => all))))

@unsafe
def x186_f_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +all = nt_append(P113DStmt,setup,body)
  nt_choose(X181Output,x191_address_enabled() || x191_memory_alu_enabled() || x192_shared_address_enabled(),
    u => x191_ordinary(symbol,params,setup,body,ids),
    u => x185_function_frame(symbol,setup,body,ids,x190_allocate_frame(
    x181_frame(symbol,params,all),params,setup,body,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => body,u => all))))
# XMM homes belong only to closed straight-line F32/canonical-copy regions.
# Every ordinary operation cuts the region. Existing inclusive ranges exclude
# all names read/written across a cut, parameters, setup and reserved names.
# A name with ANY noncanonical definition is excluded globally. Thus an XMM
# value always denotes the entire canonical zero-extended64 word, not merely
# the low bits of an arbitrary word. Original GPR frame metadata is unchanged.
@unsafe
def x194fv_place(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  x186_f_place(symbol,params,setup,w2b_coalesce(x194fv_nodes(params,setup,w2_fc_prune(w2_fc_nodes(nodes,missing()),[])),params,[]),ids)

@unsafe
def x186_float_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x186_float_values_enabled() && x185_float_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x194fv_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
# Bounded caller-register allocation for bounded structured bodies and call-free live ranges.
# Input has saved homes installed but no transient homes yet.
# Candidate IDs are bits; noncandidates keep their existing frame homes. The
# loop header is a least fixed point, Again defines its parameter vector in
# parallel, and setup/incoming writes participate in the same interference.
# Every admitted operation preserves rdi/rsi/rdx/r8/r9 except its destination.
# Call-crossing values keep their old homes; size/validation refusal retains the old placer.
@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, +header: U32, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])),header)

@unsafe
def x190_j_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_j_graphed(frame,params,setup,body,registerBody,names,ids,header,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_selected(+frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x190_j_solved(frame,params,setup,body,registerBody,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))

@unsafe
def x190_j_counted(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,+names}:
      +nCands = nt_count(String,names)
      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) ||
          (U32.is_gt(nCands,256) && U32.is_le(nt_count(String,params),8)),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),
        u => x190_j_selected(frame,params,setup,body,registerBody,
          x203_candidates(nt_reverse(String,names,[]),reads,slots)))

# Prefer repeated body uses over once-only setup reads when admitting the
# bounded candidate set. This changes priority only, never graph legality.
@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(x190_register_loop(body)) && w7b_stmts_has_call(body),
    u => frame,
    u => nt_choose(X181Frame,U32.is_le(sz,2048) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
      v => x190_j_counted(frame,params,setup,body,registerBody,
        x191_joint_reads(setup,body,x181_tail_args(frame))),
      v => x190_allocate_legacy(frame,params,setup,body,registerBody)))

@unsafe
def x190_allocate_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_joint_registers_enabled(),
    u => x190_joint_frame(frame,params,setup,body,registerBody),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))
# Adjacent comparison/branch selection over the complete function's local
# read/write facts. The original single-use rule remains the fast path. An
# optional bounded certificate admits repeated names only when every read is
# paired with its own adjacent comparison. Parameters/setup stay protected;
# continuations, branch arms and Again arguments all contribute to read counts.
@unsafe
def x191_ordinary_facts(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids, +facts: X190BranchFacts) -> X181Output:
  +placement = x191_placement(body,facts)
  x191_function_saved(symbol,setup,body,facts,ids,x186_saves_frame(x190_allocate_frame(
    x181_frame(symbol,params,nt_append(P113DStmt,setup,body)),params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,
        u => nt_append(P113DStmt,setup,placement)))))

@unsafe
def x191_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x191_ordinary_facts(symbol,params,setup,body,ids,x190_branch_facts(params,setup,body))
# Bounded shared effective-address selection. A window contains at most sixteen
# original rows, starting with a U64 scale. Every eliminated name has one
# unprotected definition and ALL its reads are accounted for by selected uses.
# No memory operation moves: only address arithmetic disappears. Calls, control
# flow and allocation stop the window. Writes to a delayed address input refuse.
@unsafe
def x181_function(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_setup(symbol,params,[],body,ids)

# Setup executes once. Again only reaches the body label, so invariant array
# metadata is not recomputed from changing parameter homes on a backedge.
@unsafe
def x185_function_late_setup_h(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, +hasHeap: Bool, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x185_function_late_body(symbol,params,ready,ids,x185_late_stmts_h(body,ids,next,hasHeap))

@unsafe
def x185_function_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => nt_choose(X181Output,x190_register_loop(body) && w12_has_borrow_fields(body),
      v => x185_function_late_setup_h(symbol,params,body,ids,True{},
             x185_late_stmts(nt_append(P113DStmt,setup,[P113DScalar{N111Load{"p114t_borrow_heap",N111Ptr{},N111Local{"state"},0}}]),ids,0)),
      v => x185_function_late_setup(symbol,params,body,ids,x185_late_stmts(setup,ids,0))),
    u => x185_function_place(symbol,params,setup,body,ids))

@unsafe
def x185_function_late_setup(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x185_function_late_body(symbol,params,ready,ids,x185_late_stmts(body,ids,next))

@unsafe
def x185_function_late_body(symbol: String, params: List<&2,String>, setup: List<&2,P113DStmt>,
    ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,next}: x185_function_place(symbol,params,setup,ready,ids)

@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,params,setup,x185_dead_body(setup,x185_copy_function(params,setup,body)),ids),
    u => x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids))

# Wave2 Pass 2b: General arithmetic shift right (asr -> sarl $k) recognition on P113DStmt.
# Tracks recent `s1 = shr(v, k)` (and copies `s1c = s1`) so intervening copies do not block matching.
@unsafe
def x186_function_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,w5_sink_body(agy_reuse_body(symbol,ids,agy_asr_and_dead(setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))))),ids)

# ---- W5-R1 Pass 2: General Loop-Counter Decrement Sinking ----
@unsafe
def x198_perm_selected(plan: X198Perm, +symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  match plan:
    case X198Perm{+ctor,a,b}:
      +slow = "p198r_original_" ++ symbol
      nt_choose(X181Output,p185cc_known(ctor,2,ids),u => x181_program_join(
        x198_perm_wrapper(symbol,slow,x198_perm_cid(ctor,ids),a,b),x186_float_function(slow,params,setup,body,ids)),
        u => x186_float_function(symbol,params,setup,body,ids))
    case X198NoPerm{}: x186_float_function(symbol,params,setup,body,ids)

@unsafe
def x198p_after_absorb(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,String.starts_with(symbol,"p113d_FID_"),
    u => x198_perm_selected(x198_perm_pick(params,setup,body),symbol,params,setup,body,ids),
    u => x186_float_function(symbol,params,setup,body,ids))


# ============================================================================
# AGY-W2B-DEADARR: IR Peephole for Fresh-Array Scan4 Closed Form
# ============================================================================

@unsafe
def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x198p_after_absorb(symbol,params,setup,x198a_body(agy_da_rewrite_body(body,ids,0),params,setup,ids),ids)

@unsafe
def x198n_normalized_h(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,names,setup,x198n_body(agy_asr_and_dead(setup,x185_dead_body(setup,
    x185_copy_function(names,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(names,setup,body))))))),params),ids)

@unsafe
def x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x198n_normalized_h(symbol,names,params,[],body,ids)

@unsafe
def x198n_place_h(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,names,setup,x185_dead_body(setup,x185_copy_function(names,setup,body)),ids),
    u => x198n_normalized_h(symbol,names,params,setup,x185_prepare_body(names,setup,x185_scratch_body(names,setup,body)),ids))

@unsafe
def x198n_place(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x198n_place_h(symbol,names,params,[],body,ids)

@unsafe
def x198n_late_h(symbol: String, names: List<&2,String>, params: List<&2,NC_Binding>, setup: List<&2,P113DStmt>, ids: N111Ids, result: P113ABody) -> X181Output:
  match result:
    case P113ABody{body,next}: x198n_place_h(symbol,names,params,setup,body,ids)

@unsafe
def x198n_late(symbol: String, names: List<&2,String>, params: List<&2,NC_Binding>, ids: N111Ids, result: P113ABody) -> X181Output:
  match result:
    case P113ABody{body,next}: x198n_place(symbol,names,params,body,ids)

@unsafe
def agy_la_try(+function: P113DFunction, +ids: N111Ids, pair: String & String) -> Maybe<&2,X181Output>:
  match function pair:
    case P113DFunction{+name,+params,+result,public,+body} Tuple{+nil_n,+con_n}:
      +ncid = agy_la_ctor_id(ids,nil_n)
      +ccid = agy_la_ctor_id(ids,con_n)
      nt_choose(Maybe<&2,X181Output>,Bool.not(String.is_empty(nil_n)) &&
          Bool.not(String.is_empty(con_n)) && U32.is_lt(ncid,65536) && U32.is_lt(ccid,65536),
        u =>
          +sym = p113e_symbol(name)
          +slow = sym ++ "__slow"
          +pnames : List<&2,String> = Con{"state",x181_param_names(params)}
          Some{x181_program_join(agy_la_emit_fast(sym,slow,ncid,ccid),x181_function(slow,pnames,body,ids))},
        u => None{})

@unsafe
def x181_direct_orig_la(+function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      +sym = p113e_symbol(name)
      +emit_sym = nt_choose(String,U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_zip_target_sym(name,sym,ids),u => sym)
      +core = nt_choose(X181Output,String.is_empty(error),u =>
        nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
          nt_choose(X181Output,x190_register_loop(body) && w12_has_borrow_fields(body),
            w => x198n_late_h(emit_sym,names,params,[P113DScalar{N111Load{"p114t_borrow_heap",N111Ptr{},N111Local{"state"},0}}],ids,x185_late_stmts_h(body,ids,0,True{})),
            w => x198n_late(emit_sym,names,params,ids,x185_late_stmts(body,ids,0))),v =>
          x181_function(emit_sym,names,body,ids)),u => X181Output{[],error})
      nt_choose(X181Output,String.is_empty(error) && U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_zip_wrap_direct(name,sym,ids,core,agy_zip_get_mark(name,ids)),u => core)

# Match the complete scalar segment after public fusion and hygiene admission.

@unsafe
def x181_direct_after_la(la: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:
  match la:
    case Some{out}: out
    case None{}: x181_direct_orig_la(function,ids)


# ============================================================================
# AGY-W5B-STRHASH: Native x86-64 Emitters for String Eq / FNV-1a Hash / Tag Eq
# ============================================================================

@unsafe
def agy_sh_wrap(+function: P113DFunction, +ids: N111Ids, +fast: X181Output, +slow: String) -> Maybe<&2,X181Output>:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +pnames : List<&2,String> = Con{"state",x181_param_names(params)}
      Some{x181_program_join(fast,x181_function(slow,pnames,body,ids))}

@unsafe
def agy_sh_try_order_or_tageq(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32, +chr: U32) -> Maybe<&2,X181Output>:
  +lt_c = agy_sh_cid(ids,"LT")
  +eq_c = agy_sh_cid(ids,"EQ")
  +gt_c = agy_sh_cid(ids,"GT")
  +ord_ok = U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
    U32.is_lt(lt_c,65536) && U32.is_lt(eq_c,65536) && U32.is_lt(gt_c,65536)
  nt_choose(Maybe<&2,X181Output>,ord_ok && agy_str_eq(name,"$p118borrow.read.String.order.go"),
    u => agy_sh_wrap(function,ids,agy_sh_emit_strcmp(sym,slow,snil,scon,chr,lt_c,eq_c,gt_c,False{}),slow),
    u => nt_choose(Maybe<&2,X181Output>,ord_ok &&
        (agy_str_eq(name,"$direct.String.order.go") || agy_str_eq(name,"$p128borrow.owned.String.order.go")),
      v => agy_sh_wrap(function,ids,agy_sh_emit_strcmp(sym,slow,snil,scon,chr,lt_c,eq_c,gt_c,True{}),slow),
      v => agy_sh_try_tageq(function,ids,name,arity,sym,slow,snil,scon,chr)))

@unsafe
def agy_sh_try_tageq(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32, +chr: U32) -> Maybe<&2,X181Output>:
  +kterm = agy_sh_cid2(ids,"KTerm","$ctor.75_84_101_114_109_")
  +klam = agy_sh_cid2(ids,"KLambda","$ctor.75_76_97_109_98_100_97_")
  +klit = agy_sh_cid2(ids,"KLiteral","$ctor.75_76_105_116_101_114_97_108_")
  +kt_cids = U32.is_eq(arity,2) && U32.is_lt(kterm,65536) && U32.is_lt(klam,65536) && U32.is_lt(klit,65536)
  +tq_ok = kt_cids && agy_sh_has_mark(ids,"$agy.sh/tageq")
  +tqr_ok = kt_cids && agy_sh_has_mark(ids,"$agy.sh/tageq_read")
  nt_choose(Maybe<&2,X181Output>,
    (tq_ok && agy_str_eq(name,"$p118borrow.read.p98_tag_eq")) ||
    (tqr_ok && agy_str_eq(name,"$p118borrow.read.p98_tag_eq_read")),
    d => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,False{}),slow),
    d => nt_choose(Maybe<&2,X181Output>,
      (tq_ok && (agy_str_eq(name,"$direct.p98_tag_eq") || agy_str_eq(name,"$p128borrow.owned.p98_tag_eq"))) ||
      (tqr_ok && (agy_str_eq(name,"$direct.p98_tag_eq_read") || agy_str_eq(name,"$p128borrow.owned.p98_tag_eq_read"))),
      e => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,True{}),slow),
      e => None{}))

@unsafe
def agy_sh_try(+function: P113DFunction, +ids: N111Ids) -> Maybe<&2,X181Output>:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +arity = nt_count(NC_Binding,params)
      +snil = agy_sh_cid(ids,"SNil")
      +scon = agy_sh_cid(ids,"SCon")
      +chr = agy_sh_cid(ids,"Chr")
      +str_cids = U32.is_eq(result,1) && U32.is_lt(snil,65536) && U32.is_lt(scon,65536) && U32.is_lt(chr,65536)
      +sym = p113e_symbol(name)
      +slow = sym ++ "__sh_slow"
      nt_choose(Maybe<&2,X181Output>,Bool.not(str_cids),u => None{},u =>
        # 1. p88_string_eq_go (arity 3)
        nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/eq_go") &&
            agy_str_eq(name,"$p118borrow.read.p88_string_eq_go"),
          v => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,True{},False{}),slow),
          v => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/eq_go") &&
              (agy_str_eq(name,"$direct.p88_string_eq_go") || agy_str_eq(name,"$p128borrow.owned.p88_string_eq_go")),
            w => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,True{},True{}),slow),
        # 2. p88_string_eq (arity 2)
            w => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/eq") &&
                agy_str_eq(name,"$p118borrow.read.p88_string_eq"),
              x => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},False{}),slow),
              x => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/eq") &&
                  (agy_str_eq(name,"$direct.p88_string_eq") || agy_str_eq(name,"$p128borrow.owned.p88_string_eq")),
                y => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},True{}),slow),
        # 3. agy_str_eq (arity 2)
                y => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/agy_eq") &&
                    agy_str_eq(name,"$p118borrow.read.agy_str_eq"),
                  z0 => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},False{}),slow),
                  z0 => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/agy_eq") &&
                      (agy_str_eq(name,"$direct.agy_str_eq") || agy_str_eq(name,"$p128borrow.owned.agy_str_eq")),
                    z1 => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},True{}),slow),
        # 4. Base String.eq (arity 2)
                    z1 => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
                        agy_str_eq(name,"$p118borrow.read.String.eq"),
                      z => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},False{}),slow),
                      z => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
                          (agy_str_eq(name,"$direct.String.eq") || agy_str_eq(name,"$p128borrow.owned.String.eq")),
                        a => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},True{}),slow),
        # 5. index_hash (arity 2)
                        a => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/hash") &&
                            agy_str_eq(name,"$p118borrow.read.index_hash"),
                          b => agy_sh_wrap(function,ids,agy_sh_emit_hash(sym,slow,snil,scon,chr,False{}),slow),
                          b => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/hash") &&
                              (agy_str_eq(name,"$direct.index_hash") || agy_str_eq(name,"$p128borrow.owned.index_hash")),
                            c => agy_sh_wrap(function,ids,agy_sh_emit_hash(sym,slow,snil,scon,chr,True{}),slow),
        # 6. String.order.go (arity 3) + p98_tag_eq / p98_tag_eq_read (arity 2)
                            c => agy_sh_try_order_or_tageq(function,ids,name,arity,sym,slow,snil,scon,chr))))))))))))

@unsafe
def x181_direct_after_sh(sh: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:
  match sh:
    case Some{out}: out
    case None{}: x181_direct_after_la(agy_la_try(function,ids,agy_la_detect(function)),function,ids)

@unsafe
def x181_direct(function,ids):
  x181_direct_after_sh(agy_sh_try(function,ids),function,ids)
@unsafe
def x181_segment(segment,ids):
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,+body}:
      +error = x181_hygiene_scalars(body)
      nt_choose(X181Output,String.is_empty(error),
        u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),v => x181_function(p111q_symbol(name),["state"],x181_scalar_rows(body),ids)),
        u => X181Output{[],error})

# The branch plan sees setup and incoming definitions as well as the loop body.
@unsafe
def x192h_output_or_original(segment: N111Segment, ids: N111Ids, +candidate: X181Output) -> X181Output:
  match candidate:
    case X181Output{chunks,error}:
      nt_choose(X181Output,String.is_empty(error),u => candidate,u => x181_segment(segment,ids))

# Generated by machine.py. Checked typed instruction sequence; no assembly parser or C helper.

@unsafe
def agy_ro_worker(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +symbol = p114r_symbol(name)
  +entry = agy_ro_get_mark(name,ids)
  +slow = "p198w_original_" ++ symbol
  +arity = da(entry)
  +cases = ks(dt(entry))
  nt_choose(X181Output,agy_str_eq(dk(entry),"AgyRoRecCertified") && agy_ro_h_args(params,arity) && agy_ro_check_cids(cases,ids),
    u => x181_program_join(agy_ro_emit_wrapper(symbol,slow,arity,cases,ids),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))


@unsafe
def x198pw_worker_cids(+symbol: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+leaf: String,+node: String) -> X181Output:
  +leafId = x198pw_cid(leaf,ids)
  +nodeId = x198pw_cid(node,ids)
  +no = x198pw_cid("False",ids)
  +yes = x198pw_cid("True",ids)
  +slow = "p198w_original_" ++ symbol
  nt_choose(X181Output,p185cc_known(node,2,ids) && x198pw_has_cid(leafId,1) && x198pw_has_cid(no,0) && x198pw_has_cid(yes,0) &&
      U32.is_ne(da(leafId),da(nodeId)) && U32.is_ne(da(no),da(yes)),
    u => x181_program_join(x198pw_emit_wrapper(symbol,slow,da(leafId),da(nodeId),da(no),da(yes)),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))


# ============================================================================
# AGY-W2B-4: Certified Native In-Place Bitonic `flow` Fast Path
# ============================================================================

@unsafe
def agy_fl_worker_cids(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, +leaf: String, +node: String, +warp: String, +wn: String) -> X181Output:
  +leaf_id = x198pw_cid(leaf,ids)
  +node_id = x198pw_cid(node,ids)
  +slow = "agy_flow_slow_" ++ symbol
  +warp_sym = p114r_symbol("$direct." ++ warp)
  +wn_sym = p114r_symbol("$direct." ++ wn)
  nt_choose(X181Output,x198pw_has_cid(leaf_id,1) && x198pw_has_cid(node_id,2) && U32.is_ne(da(leaf_id),da(node_id)),
    u => x181_program_join(agy_fl_emit_wrapper(symbol,slow,warp_sym,wn_sym,da(leaf_id),da(node_id)),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))

@unsafe
def agy_fl_worker_child(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, +leaf: String, +node: String, cs: List<&2,KDef>) -> X181Output:
  match cs:
    case Con{+c0,Nil{}}: agy_fl_worker_cids(symbol,params,setup,body,ids,leaf,node,nm(dt(c0)),nm(dv(c0)))
    case _: x185_function_setup(symbol,params,setup,body,ids)

@unsafe
def agy_fl_try_worker(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +symbol = p114r_symbol(name)
  +entry = agy_fl_get_mark(name,ids)
  nt_choose(X181Output,agy_str_eq(dk(entry),"AgyFlowCertified") && x198pw_h_args(params),
    u => agy_fl_worker_child(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry)),dc(entry)),
    u => agy_ro_worker(name,params,setup,body,ids))


# === AGY-W2C-ARRLIST ===

@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,agy_str_eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => nt_choose(X181Output,agy_al_is_match(name,params,ids),
      v =>
        +slow = "agy_al_orig_" ++ symbol
        x181_program_join(agy_al_emit_fast(symbol,slow,agy_al_ctor_id(ids,"Con")),
          x185_function_setup(slow,params,setup,body,ids)),
      v => agy_fl_try_worker(name,params,setup,body,ids)))

@unsafe
def x192h_emit_checked(+segment: N111Segment,+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>,+adapter: List<&2,P113DStmt>,+ids: N111Ids,+available: KDef) -> X181Output:
  +error = p111_first(x181_program_stmts(setup,available),p111_first(x181_program_stmts(body,available),
    p111_first(x181_program_stmts(adapter,available),p111_first(x181_hygiene_names(params),
      p111_first(x181_hygiene_stmts(setup),p111_first(x181_hygiene_stmts(body),x181_hygiene_stmts(adapter)))))))
  nt_choose(X181Output,String.is_empty(error),u => x192h_output_or_original(segment,ids,
    x181_program_join(x198pw_worker(name,params,setup,body,ids,x198pw_get_mark(name,ids)),
      x185_function_setup(p111q_symbol(name),["state"],[],adapter,ids))),u => x181_segment(segment,ids))

@unsafe
def x192h_public_planned(+segment: N111Segment, +ids: N111Ids, available: KDef, plan: P114HPlan) -> X181Output:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,original} P114HPlan{valid,+params,body,+cases}:
      nt_choose(X181Output,valid,u => x192h_emit_checked(segment,name,x192h_formals(params),
        Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)},
        x192h_worker_body(params,body,cases),x192h_adapter(name,params),ids,available),
        u => x181_segment(segment,ids))
# Experimental x86 consumers of the ORIGINAL bounded closed-continuation and
# ready-public-tail planners. Original final verification remains prerequisite.
# These independent toggles are changed only in frozen experimental variants.
@unsafe
def x193f_emit_planned(+original: N111Segment, +ids: N111Ids, plan: X193FBody) -> X181Output:
  match original plan:
    case N111Segment{name,arity,result,incoming,flags,old} X193FBody{body,calls,+error}:
      nt_choose(X181Output,String.is_empty(error),u => x192h_output_or_original(original,ids,
        x181_segment(N111Segment{name,arity,result,incoming,flags,body},ids)),u => x181_segment(original,ids))

@unsafe
def x193f_fallback(+segment: N111Segment, index: P112FusionIndex, +ids: N111Ids,
    ready: KDef, available: KDef) -> X181Output:
  x193f_emit_planned(segment,ids,x193f_plan(segment,index,ready,available,x193f_fusion_enabled(),x193f_tail_enabled()))

# This adapter queries exactly the original H plan and gives it first refusal.
# A valid H plan keeps its original selector/fallback behavior. Complete direct
# workers and generic mode remain excluded by the existing program.bend caller.
@unsafe
def x193f_after_h(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +available: KDef, +plan: P114HPlan) -> X181Output:
  nt_choose(X181Output,p114h_valid(plan),u => x192h_public_planned(segment,ids,available,plan),
    u => x193f_fallback(segment,index,ids,ready,available))

@unsafe
def x193f_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +available: KDef) -> X181Output:
  nt_choose(X181Output,x192h_regions_enabled(),u =>
    x193f_after_h(segment,index,ids,ready,available,p114h_plan(segment,index,view)),
    u => x193f_fallback(segment,index,ids,ready,available))

# Optional profitability consumer only. Original p112c_plan_index remains the
# semantic planner; this hook receives its already constructed complete plan.
# Two existing linear statement counts run only when that plan fused a site.
# Rejection still permits the independent ready-tail optimization on ORIGINAL
# input, never a prefix of an over-budget fused candidate.
# Count nested branches with the same existing p112f_size convention as the
# original continuation admission: one per statement, including each If.

@unsafe
def x185_array_emit(function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      x185_function_setup(symbol,Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
        u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})},
        x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body,ids)

@unsafe
def x185_array_plain(+function: P113DFunction, ids: N111Ids, heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x185_array_emit(p113a_function(function,heap),p113e_symbol(name),[],ids)

@unsafe
def x199s_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,x199s_select(params,body),ids)

@unsafe
def x199s_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x199s_copied(symbol,params,setup,x185_dead_body(setup,w2_asr_body(w2_asr_strip_self(x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))))),ids)

@unsafe
def x199s_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x199s_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids)

@unsafe
def x199s_late_body(symbol: String, params: List<&2,String>, setup: List<&2,P113DStmt>,
    ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,next}: x199s_place(symbol,params,setup,ready,ids)

@unsafe
def x199s_late_setup(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x199s_late_body(symbol,params,ready,ids,x185_late_stmts(body,ids,next))

@unsafe
def x199s_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => x199s_late_setup(symbol,params,body,ids,x185_late_stmts(setup,ids,0)),
    u => x199s_place(symbol,params,setup,body,ids))


# ============================================================================
# AGY-W2-DPLOOP: Certified 1D Stencil / Recurrence Fast Path for p117v Loops
# ============================================================================
# Semantic tokens (0 = unknown/refusal):
#   1: fuel (n)            2: idx (j, u64)        3: ai (u64)
#   4: b_base              5: b_mask
#   6: p_base              7: p_mask
#   8: c_base              9: c_mask
#  10: fuel - 1           11: idx (u32)          12: ai (u32)
#  13: idx + 1 (u32)      14: idx & b_mask       15: (idx & b_mask)*4
#  16: b_cell             17: bj = B[j]          18: ne(ai, bj)
#  19: xor(ne(ai,bj), 1)  20: cost = (ai!=bj)?1:0
#  21: idx & p_mask       22: (idx & p_mask)*4   23: p_cell_j
#  24: diag = P[j]        25: (idx+1) & p_mask   26: ((idx+1)&p_mask)*4
#  27: p_cell_j1          28: up = P[j+1]
#  29: idx & c_mask       30: (idx & c_mask)*4   31: c_cell_j
#  32: left = C[j]        33: up + 1             34: left + 1
#  35: ult(up+1, left+1)  36: m1 = min(up+1, left+1)
#  37: diag + cost        38: ult(m1, diag+cost) 39: v = min(m1, diag+cost)
#  40: (idx+1) & c_mask   41: ((idx+1)&c_mask)*4 42: c_cell_j1
#  50: const 0            51: const 1            52: const 4

@unsafe
def agy_dp_try(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, +heap_min: U32, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> X181Output:
  +cleaned = x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,
        x185_prepare_body(params,setup,x185_scratch_body(params,setup,body))))))))
  +slow = "agy_dp_slow_" ++ symbol
  nt_choose(X181Output,agy_dp_certify(params,cleaned),
    u => x181_program_join(agy_dp_emit_x86(symbol,slow,heap_min),
      x185_array_emit(function,slow,prelude,ids)),
    u => x185_array_emit(function,symbol,prelude,ids))

@unsafe
def agy_dp_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, +used: U32, +heap_min: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      nt_choose(X181Output,U32.is_eq(result,4) && U32.is_eq(nt_count(NC_Binding,params),7) && U32.is_eq(used,112),
        u => agy_dp_try(function,symbol,prelude,ids,heap_min,
          Con{"state",Con{"__x181_result_out",x181_param_names(params)}},
          x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body),
        u => x185_array_emit(function,symbol,prelude,ids))


@unsafe
def x199s_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, +used: U32, +heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      nt_choose(X181Output,x199s_enabled() && U32.is_eq(result,2) &&
          U32.is_eq(nt_count(NC_Binding,params),4) && U32.is_eq(used,p117h_bit(3)),
        u => x199s_setup(symbol,Con{"state",Con{"__x181_result_out",x181_param_names(params)}},
          x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body,ids),
        u => agy_dp_array_emit(function,symbol,prelude,ids,used,heap))

# Only the guarded mode-2 array version can enter the new selector.
# The original fallback worker and dispatch/setup factories are unchanged.
@unsafe
def x185_array_version_plan(plan: W4CBCEPlan, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +result: U32, +public: Bool, +body: List<&2,P113DStmt>, +ids: N111Ids, +heap: U32, +used: U32, +sites: KDef) -> X181Output:
  match plan:
    case W4CBCEPlan{nomask,guards,_}:
      x181_program_join(x185_array_emit(p113a_function(function,heap),"p117v_" ++ nt_fid(name),[],ids),
        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite_ex(body,0,heap,used,sites,nomask)),
          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),
            x185_array_dispatch_ex(name,params,result,used,guards)),ids,used,heap))

@unsafe
def x185_array_version(+function: P113DFunction, +ids: N111Ids, +heap: U32, +used: U32, +sites: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      x185_array_version_plan(w4c_bce_analyze(params,body,used,sites),function,name,params,result,public,body,ids,heap,used,sites)


@unsafe
def x185_array_scanned(+function: P113DFunction, +ids: N111Ids, +heap: U32, scan: P117HScan) -> X181Output:
  match function scan:
    case P113DFunction{+name,+params,result,public,+body} P117HScan{facts,slots,+mask,+used,+again,left,+next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(X181Output,again && U32.is_gt(used,0) && U32.is_gt(next,0) &&
          U32.is_le(p113i_size(body),1024) && p117v_all(sites,next,used,0),
        u => x185_array_version(function,ids,heap,used,sites),
        u => nt_choose(X181Output,again && U32.is_gt(used,0),
          v => x185_array_emit(p113a_function_done(name,params,result,public,p117h_rewrite(body,0,heap,used,sites)),
            p113e_symbol(name),p117h_prelude(params,1,used,heap),ids),
          v => x185_array_plain(function,ids,heap)))

# ============================================================================
# W5-R4 Pass 2: General Loop-Carried Product Unboxing across P113DAgain
# ============================================================================
@unsafe
def x185_array_selected_core(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),
        u => x185_array_plain(function,ids,heap),
        u => x185_array_scanned(function,ids,heap,p117h_walk(body,count,
          P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()})))

law w5_lcu_selected:
  for +function: P113DFunction
  for +ids: N111Ids
  for +heap: U32
  for +depth: U32
  X181Output

@unsafe
def w5_lcu_apply(+function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +public: Bool, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +heap: U32, +depth: U32, cand: W5LcuCand) -> X181Output:
  match cand:
    case W5LcuCandNo{}: x185_array_selected_core(function,ids,heap)
    case W5LcuCandYes{+idx,+pName,+ctor,+arity}:
      +wName = "$lcu" ++ U32.show(depth) ++ "." ++ name
      +wSym = p113e_symbol(wName)
      +fbSym = "w5_lcu_fb_" ++ U32.show(depth) ++ "_" ++ nt_fid(name)
      +wParams = w5_lcu_splice_params(params,idx,w5_lcu_field_bindings(depth,0,arity))
      +wBody0 = w5_lcu_rewrite(body,[],idx,pName,ctor,arity,depth)
      +wBody1 = w4g_bwd_dce(w4g_copy_pass(wBody0))
      +workerFn : P113DFunction = P113DFunction{wName,wParams,1,False{},wBody1}
      +bufName = "w5_lcu_in_" ++ U32.show(depth)
      +wrapYes : List<&2,P113DStmt> = nt_append(P113DStmt,[
        P113DScalar{N111Alloca{bufName,U32.mul(arity,8),8}},
        P113DScalar{N111Call{"w5_lcu_ign",N111U64{},"p111_rt_take",[p111_state(),N111Arg{N111U64{},N111Local{pName}},N111Arg{N111Ptr{},N111Local{bufName}},p111_u32(arity)]}}],
        nt_append(P113DStmt,w5_lcu_field_loads(bufName,depth,0,arity),[
          P113DScalar{N111Call{"w5_lcu_out",N111U64{},wSym,Con{p111_state(),w5_lcu_splice_args(params,idx,w5_lcu_field_args(depth,0,arity))}}},
          P113DResult{[N111Local{"w5_lcu_out"}]}]))
      +wrapNo : List<&2,P113DStmt> = [
        P113DScalar{N111Call{"w5_lcu_fb",N111U64{},fbSym,Con{p111_state(),x185_array_arguments(params)}}},
        P113DResult{[N111Local{"w5_lcu_fb"}]}]
      +wrapBody : List<&2,P113DStmt> = [
        P113DScalar{N111Call{"w5_lcu_tag",N111U64{},"p111_rt_tag",[p111_state(),N111Arg{N111U64{},N111Local{pName}}]}},
        P113DScalar{N111Bin{"w5_lcu_ok",N111U64{},"eq",N111Local{"w5_lcu_tag"},N111CtorId{ctor}}},
        P113DIf{N111Local{"w5_lcu_ok"},wrapYes,wrapNo}]
      +wrapFn : P113DFunction = P113DFunction{name,params,1,public,wrapBody}
      x181_program_join(
        x185_array_emit(p113a_function(function,heap),fbSym,[],ids),
        x181_program_join(
          w5_lcu_selected(workerFn,ids,heap,U32.inc(depth)),
          x185_array_emit(wrapFn,p113e_symbol(name),[],ids)))

@unsafe
def w5_lcu_selected(function,ids,heap,depth):
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +nParams = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_lt(depth,2) && U32.is_eq(result,1) && U32.is_le(nParams,12) &&
          U32.is_le(p113i_size(body),1024) && x190_register_loop(body),
        u => w5_lcu_apply(function,name,params,public,body,ids,heap,depth,w5_lcu_find_param(params,0,nParams,body)),
        u => x185_array_selected_core(function,ids,heap))

@unsafe
def x185_array_selected(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  w5_lcu_selected(function,ids,heap,0)


# ============================================================================
# AGY-W2B-F32LOOP: General XMM Loop-Carried F32 Recurrence + Constant Hoisting
# ============================================================================
# AST encoded in KTerm:
#   F32 exprs:
#     kt("FVarX", "", 0, 0, [])
#     kt("FConst", "", bits_u32, 0, [])
#     kt("FBin", sse_op, 0, 0, [left, right])   # addss / subss / mulss / divss
#   U32 exprs:
#     kt("UVarH", "", 0, 0, [])
#     kt("UObs", "", 0, 0, [])                  # f32_to_u32(obs_expr)
#     kt("UConst", "", val_u32, 0, [])
#     kt("UBin", alu_op, 0, 0, [left, right])   # addl / subl / imull / xorl / andl / orl
# Env entries in KDef:
#   kind = "F32Expr" -> dv = KTerm (F32 expr)
#   kind = "U32Expr" -> dv = KTerm (U32 expr)
#   kind = "FuelSub" -> da = 1 (n - 1)
#   kind = "Fuel"    -> da = 1 (n)

@unsafe
def agy_f32_emit_plan(+symbol: String, +function: P113DFunction, +ids: N111Ids, plan: AgyF32Plan) -> X181Output:
  match plan:
    case AgyF32No{}: x181_direct(function,ids)
    case AgyF32Yes{+ye,+obs,+he}:
      +obs2 = agy_f32_subst_opt(obs,ye)
      +cs = agy_f32_collect_opt(obs2,agy_f32_collect_c(ye,[]))
      +ok = U32.is_le(nt_count(U32,cs),8) && U32.is_le(agy_f32_depth(ye),5) &&
            U32.is_le(agy_f32_opt_depth(obs2),5) && U32.is_le(agy_f32_u_depth(he),3) &&
            Bool.not(agy_str_eq(tg(he),"UVarH"))
      nt_choose(X181Output,ok,
        u => agy_f32_emit_x86_v2(symbol,ye,obs2,he,cs),
        u => x181_direct(function,ids))

@unsafe
def agy_f32_try_run(+function: P113DFunction, +symbol: String, +params: List<&2,String>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +cleaned = x185_dead_body([],
    x185_copy_function(params,[],x186_expression_body([],
      x190_local_values_body([],x192_predicate_body(x186_private_body(params,[],
        x185_prepare_body(params,[],x185_scratch_body(params,[],body))))))))
  agy_f32_emit_plan(symbol,function,ids,agy_f32_certify(params,cleaned))

@unsafe
def w5b_f32_dispatch(ok: Bool, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  match ok:
    case True{}: agy_f32_try_run(function,p113e_symbol(name),Con{"state",x181_param_names(params)},body,ids)
    case False{}: x181_direct(function,ids)

@unsafe
def agy_f32_try_direct(+function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      w5b_f32_dispatch(
        U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3) && U32.is_eq(w5b_f32_scan_body(body,0),3),
        function,name,params,body,ids)



# ============================================================================
# AGY-W2B-DEADARR: P134Private x199s Scan4 Certifier
# ============================================================================

@unsafe
def agy_da_check_scan(+f: P113DFunction, +heap: U32) -> Bool:
  match f:
    case P113DFunction{+name,+params,+result,public,+body}:
      +scan = p117h_walk(body,4,
        P117HScan{p117h_seed(params,1,missing()),missing(),15,0,False{},8192,0,missing()})
      agy_da_check_scanned(f,heap,scan)

@unsafe
def agy_da_is_x199s(+f: P113DFunction, +heap: U32) -> Bool:
  match f:
    case P113DFunction{+name,+params,+result,public,+body}:
      nt_choose(Bool,x199s_enabled() && U32.is_eq(result,2) && U32.is_eq(nt_count(NC_Binding,params),4) &&
          U32.is_gt(p113a_count_body(body,0),0) && p113a_params(params) && p113a_body_names(body) &&
          p117h_params_clean(params),
        u => agy_da_check_scan(f,heap),
        u => False{})

@unsafe
def agy_da_collect_priv(fs: List<&2,P113DFunction>, +heap: U32, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match fs:
    case Nil{}: acc
    case Con{+f,rest}:
      match f:
        case P113DFunction{+name,_,_,_,_}:
          +acc2 = nt_choose(List<&2,KDef>,agy_da_is_x199s(f,heap),
            u => Con{KDef{agy_da_key(name),"AgyScan4",0,0,kt("None","",0,0,[]),kt("None","",0,0,[]),[],False{},False{}},acc},
            u => acc)
          agy_da_collect_priv(rest,heap,acc2)

@unsafe
def agy_da_scan_cursor(cursor: P134Cursor, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match cursor:
    case P134Private{fs,P134Context{ids,idx,direct,ready,view,lookups,+heap,+mode},next}:
      +acc2 = nt_choose(List<&2,KDef>,U32.is_eq(mode,2),u => agy_da_collect_priv(fs,heap,acc),u => acc)
      agy_da_scan_cursor(next,acc2)
    case P134Public{_,_,next}: agy_da_scan_cursor(next,acc)
    case P134Legacy{_,_,next}: agy_da_scan_cursor(next,acc)
    case _: acc

@unsafe
def agy_da_annotate(+prepared: P169Prepared) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +entries = nt_choose(List<&2,KDef>,String.is_empty(error),u => agy_da_scan_cursor(cursor,[]),u => [])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_da_cursor(entries,cursor),u => cursor),error}


@unsafe
def x185_array_function(+function: P113DFunction, +ids: N111Ids, +heap: U32, +mode: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,Bool.not(String.is_empty(error)),u => X181Output{[],error},u =>
        nt_choose(X181Output,U32.is_eq(mode,2) && U32.is_gt(p113a_count_body(body,0),0) &&
          p113a_params(params) && p113a_body_names(body),
          v => x185_array_selected(function,ids,heap),v => agy_f32_try_direct(function,ids)))

@unsafe
def x181_program_private(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{name,params,result,public,body} P134Context{+ids,index,direct,ready,view,+lookups,+heap,+mode}:
      +enabled = x195t_enabled() && U32.is_eq(mode,2)
      x181_program_join(X181Output{[],x181_program_stmts(body,available)},
        x181_program_join(nt_choose(X181Output,enabled,
          u => x195t_data(function,lookups,available),u => X181Output{[],""}),
          x181_program_join(x185_array_function(x195t_when(enabled,function,lookups),ids,heap,mode),
            x181_forward(function,ready))))


# === AGY-W2C-MAPFAST ===

@unsafe
def agy_map_emit_public(+segment: N111Segment, +ids: N111Ids, +kind: U32) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,+body}:
      +sym = p111q_symbol(name)
      +slow = sym ++ "__slow"
      +fast = nt_choose(X181Output,U32.is_eq(kind,1),
        u => agy_map_get_fast(sym,slow,ids),
        u => agy_map_set_fast(sym,slow,ids))
      +slow_out = x181_function(slow,["state"],x181_scalar_rows(body),ids)
      x181_program_join(fast,slow_out)


# ============================================================================
# AGY-W2C-1: Certified In-Place Radix-Trie `Map.set` & `Map.del` Fast Paths
# ============================================================================


# === AGY-W2-BASEPIN ===
@unsafe
def agy_map_emit_segment(+segment: N111Segment, +ids: N111Ids, +kind: U32) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      +sym = p111q_symbol(name)
      +slow = "agy_map_slow_" ++ sym
      +mtip = x198pw_cid("MTip",ids)
      +mleaf = x198pw_cid("MLeaf",ids)
      +mnode = x198pw_cid("MNode",ids)
      +snil = x198pw_cid("SNil",ids)
      +scon = x198pw_cid("SCon",ids)
      +chr = x198pw_cid("Chr",ids)
      +tup = x198pw_cid("Tuple",ids)
      nt_choose(X181Output,
          x198pw_has_cid(mtip,0) && x198pw_has_cid(mleaf,2) && x198pw_has_cid(mnode,3) &&
          x198pw_has_cid(snil,0) && x198pw_has_cid(scon,2) && x198pw_has_cid(chr,1) &&
          x198pw_has_cid(tup,2),
        u => x181_program_join(
          agy_map_emit_wrap(sym,slow,kind,da(mtip),da(mleaf),da(mnode),da(snil),da(scon),da(chr),da(tup)),
          nt_choose(X181Output,U32.is_eq(kind,0),
            q => x181_program_join(agy_map_set_fast(slow,slow ++ "__rec",ids),
              x181_function(slow ++ "__rec",["state"],x181_scalar_rows(body),ids)),
            q => x181_function(slow,["state"],x181_scalar_rows(body),ids))),
        u => x181_segment(segment,ids))

@unsafe
def agy_map_try_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +available: KDef) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      +mark = agy_map_get_mark(name,ids)
      nt_choose(X181Output,agy_str_eq(dk(mark),"AgyMapSet"),
        u => agy_map_emit_segment(segment,ids,0),
        u => nt_choose(X181Output,agy_str_eq(dk(mark),"AgyMapDel"),
          v => agy_map_emit_segment(segment,ids,1),
          v => nt_choose(X181Output,agy_str_eq(dk(mark),"AgyMapGet"),
            w => agy_map_emit_public(segment,ids,1),
            w => x193f_public(segment,index,ids,ready,view,available))))


@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,+direct,ready,view,lookups,heap,+mode}:
      +function = p111v_get(direct,name)
      +is_direct = agy_str_eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)
      +mark = agy_map_get_mark(name,ids)
      +use_w2cm = Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct) &&
        (agy_str_eq(dk(mark),"AgyMapSet") || agy_str_eq(dk(mark),"AgyMapDel") || agy_str_eq(dk(mark),"AgyMapGet"))
      +mkind = nt_choose(U32,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct) && Bool.not(use_w2cm),
        u => agy_map_kind(segment,ids),u => 0)
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},
        nt_choose(X181Output,use_w2cm,
          u => agy_map_try_public(segment,index,ids,ready,view,available),
          u => nt_choose(X181Output,U32.is_gt(mkind,0),
            v => agy_map_emit_public(segment,ids,mkind),
            v => nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),
              w => x193f_public(segment,index,ids,ready,view,available),w => x181_segment(segment,ids)))))


@unsafe
def x181_stream_written(pair: File & Result<&1,&1,U32 & String,Unit>,
    rest: List<&2,X188Seq>, next: P134Cursor, available: KDef, ending: X188Seq) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: x181_stream_chunks(file,rest,next,available,ending)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def x181_stream_chunks(file: File, chunks: List<&2,X188Seq>, next: P134Cursor,
    available: KDef, ending: X188Seq) -> IO(U32):
  match chunks:
    case Nil{}: x181_stream_drain(file,next,available,ending)
    case Con{head,rest}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,x188_render(head))
        x181_stream_written(pair,rest,next,available,ending)

@unsafe
def x181_stream_piece_checked(file: File, chunks: List<&2,X188Seq>, next: P134Cursor,
    available: KDef, ending: X188Seq, error: String) -> IO(U32):
  match error:
    case SNil{}: x181_stream_chunks(file,chunks,next,available,ending)
    case SCon{head,tail}: x181_stream_fail(file,SCon{head,tail})

@unsafe
def x181_stream_piece(file: File, piece: X181Output, next: P134Cursor,
    available: KDef, ending: X188Seq) -> IO(U32):
  match piece:
    case X181Output{chunks,error}: x181_stream_piece_checked(file,chunks,next,available,ending,error)

@unsafe
def x181_stream_data_written(file: File, slice: X181StreamSlice,
    tables: List<&2,P111QData>, available: KDef, ending: X188Seq) -> IO(U32):
  match slice:
    case X181StreamSlice{text,rest,error}:
      x181_stream_piece(file,X181Output{[text],error},P134Data{rest,False{},tables},available,ending)

@unsafe
def x181_stream_table(file: File, data: P111QData,
    rest: List<&2,P111QData>, available: KDef) -> IO(U32):
  match data:
    case P111QData{+name,alignment,exported,items}:
      x181_stream_piece(file,X181Output{[x188_table_head(name,alignment,exported)],""},
        P134Data{items,True{},rest},available,X188One{PSize{name}})

@unsafe
def x181_stream_drain(file: File, cursor: P134Cursor, +available: KDef, ending: X188Seq) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Private{Con{head,rest},+context,next}:
      x181_stream_piece(file,x181_program_private(head,context,available),
        P134Private{rest,context,next},available,X188Empty{})
    case P134Legacy{entries,context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Public{Nil{},context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Public{Con{head,rest},+context,next}:
      x181_stream_piece(file,x181_program_public(head,context,available),
        P134Public{rest,context,next},available,X188Empty{})
    case P134Tables{Nil{}}: x181_stream_drain(file,P134Main{},available,X188Empty{})
    case P134Tables{Con{head,rest}}: x181_stream_table(file,head,rest,available)
    case P134Data{Nil{},first,rest}:
      x181_stream_piece(file,X181Output{[ending],""},P134Tables{rest},available,X188Empty{})
    case P134Data{Con{head,rest},first,tables}:
      x181_stream_data_written(file,x181_stream_data_slice(Con{head,rest},available,128,[]),tables,available,ending)
    case P134Main{}:
      x181_stream_piece(file,X181Output{[x181_program_main(),x181_program_note()],""},P134End{},available,X188Empty{})
    case P134End{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)

@unsafe
def x181_stream_start(+cursor: P134Cursor, available: KDef) -> IO(U32):
  match cursor:
    case P134Data{items,first,rest}: IO.die(U32,1,"x86 requires a complete data cursor")
    case P134End{}: IO.die(U32,1,"x86 cursor ended before program tables and entry")
    case _:
      do IO<U32>:
        file : File <- IO.try(File,File.open("/dev/stdout","a"))
        x181_stream_drain(file,cursor,available,X188Empty{})

# Forwarder text is ignored; program.bend reconstructs the checked import ABI.
# The complete import index is computed once, before any body is released.
@unsafe
def x181_print(prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => x181_stream_start(cursor,x181_cursor_index(cursor,missing())),
        u => IO.die(U32,1,error))
# Finite AMD64 instruction encoder for the maintained AT&T selection surface.
# No instruction relaxation: calls/jumps use rel32; base memory uses disp0/8/32.
# Unsupported forms return an error and no bytes, never a guessed encoding.
@unsafe
def x187_cursor(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => x187_cursor_good(cursor,available,build),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def x187_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build))
    case P134Tables{Nil{}}: x187_cursor(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x201f_finish(x187_build_seq(x181_program_main(),build))
    case _: X187ObjectResult{[],"incomplete object cursor"}


@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => X187ObjectResult{[],error})

# General -O0 / fast object emission mode (`x86-object-fast` / `x187_prepared_fast`):
# Runs required late lowering (x185_late_stmts) + direct stack-frame emission (x181_stmts) + fast ELF,
# skipping optional multi-pass IR optimizations, liveness/regalloc, and post-select peepholes.
@unsafe
def x181_program_private_fast(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{+name,+params,+result,public,+body} P134Context{+ids,index,direct,+ready,view,lookups,heap,mode}:
      +pnames = x181_param_names(params)
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => pnames,u => Con{"__x181_result_out",pnames})}
      +error = p111_first(x181_program_stmts(body,available),p111_first(x181_hygiene_names(pnames),x181_hygiene_stmts(body)))
      nt_choose(X181Output,String.is_empty(error),
        u => w9_private_fast_sh(agy_sh_try(function,ids),function,p113e_symbol(name),names,body,ids,ready),
        u => X181Output{[],error})

law x187_cursor_fast:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  X187ObjectResult

law w13c_pub_emit_fast:
  for +segment: N111Segment
  for context: P134Context
  for +available: KDef
  for +build: X187Build
  X187Build

@unsafe
def x187_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build))
    case P134Tables{Nil{}}: x187_cursor_fast(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: w10f_x201f_finish_any(x187_build_seq(x181_program_main(),build),False{},missing())
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def x187_cursor_fast(cursor,available,build):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => x187_cursor_fast_good(cursor,available,build),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def x187_prepared_fast(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor_fast(cursor,avail,x187_build_empty()),
        u => X187ObjectResult{[],error})

@unsafe
def x202p_x187_cursor(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => x202p_x187_cursor_good(cursor,available,build),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def x202p_x187_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: x202p_x187_cursor(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x202p_x187_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build))
    case P134Legacy{entries,context,next}: x202p_x187_cursor(next,available,build)
    case P134Public{Nil{},context,next}: x202p_x187_cursor(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x202p_x187_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build))
    case P134Tables{Nil{}}: x202p_x187_cursor(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x202p_x187_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x202p_x201f_finish(x187_build_seq(x181_program_main(),build))
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def x202p_x187_prepared(+prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),u => x202p_x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => IO.die(U32,1,error))

@unsafe
def x187_print(prepared: P169Prepared) -> IO(U32):
  x202p_x187_prepared(prepared)

@unsafe
def x198pw_after(+prepared: P169Prepared,+r: NR_Request) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,cursor,+error}:
      nt_choose(P169Prepared,String.is_empty(error),u => agy_sh_annotate(r,agy_bp_annotate(r,agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))))),u => prepared)

@unsafe
def x198pw_plan(+plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanReady{request,verdict}: x198pw_after(p169np_plan(plan),request)
    case _: p169np_plan(plan)

@unsafe
def x198pw_prepared(+path: String,+source: String,prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: x198pw_plan(p86_plan(seed,path,source))

@unsafe
def x198pw_compile(+path: String,+source: String,+base_path: String,+base: String,
    +carrier: String,+stamp: String,+cached: Bool) -> P169Prepared:
  x198pw_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

# === W13-D: Fast -O0 lowering pipeline (`x198pw_plan_fast`) ===
# Used ONLY by -O0 entry points (`x86-module-fast` / `x86-object-fast`).
# -O2 (`x86-object` / `x86-module` / `x86` / `x86-shard` / `x86-iface`) stays 100% untouched.
# Preserves exact cross-module `$direct.*` + `p111_FID_*` ABI (matching `x86-iface`),
# `p111_runtime_admission`, `nc_compile_error_known`, `p167ob_permission`, `p112s_prepare`,
# `p128br_scan`, `p167ob_seed_verify`, `p113d_passes`, and `p167l_functions` (`w6_dedup_segments`).
# Skips -O2-only optimization & redundant passes:
#   - `nq_signatures`, `p121f_plan`, `p198e_plan`, `p121c_admitted`, `p125p_select`,
#     `p118t_retry`, `p113pl_flat_candidate`, `p126sc_candidates`
#   - `w4p_adapt_functions`, `p169o_closed` (`p113i` inlining, `p113k` folding, `p169q_scalars`, `p128br_retry_plans`)
#   - `p167v_original`, `p118b_verify_functions`, `p167live_eligible`, `p169a_namespace`, `p169c_selected` (cold tables)
#   - `p112f_index`, `p168j_imports`, `p168j_registry` (6-round fusion), `p168j_forwards`
#   - `x198pw_after` (7 -O2 annotation passes)

@unsafe
def w13d_p168_selected_fast(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, +remaining: List<&2,String>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  +filtered = w7_filter_remaining(book,remaining,bangs)
  +raw = w13d_p113pl_candidates_fast(book,filtered,bangs)
  +fns0 = p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32)
  p167l_functions(source,book,names,constructors,nodes,bangs,fns0)

@unsafe
def w13d_p168_seed_verified_fast(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => w13d_p168_selected_fast(source,book,names,constructors,nodes,bangs,workers,
      p167ob_remaining(book,names,bangs,p113e_signatures(workers,missing()))),
    u => p167l_fail("early scalar observer verification: " ++ error))

@unsafe
def w13d_p168_scanned_fast(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => w13d_p168_seed_verified_fast(source,book,names,constructors,nodes,bangs,workers,
          p167ob_seed_verify(constructors,workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))

@unsafe
def w13d_p168_prepared_fast(source: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => w13d_p168_scanned_fast(source,book,names,constructors,nodes,bangs,
          p128br_scan(book,no_candidate_names(book,names,bangs),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def w13d_p168_fast(+request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v =>
            +ctors = nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))
            w13d_p168_prepared_fast(source,names,ctors,p112s_prepare(book,names,ctors)),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error))

@unsafe
def w13d_p169np_admitted_fast(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => w13d_p169s_lowered_fast(w13d_p168_fast(request)),
    u => p169s_fail("compile: " ++ error))

@unsafe
def x198pw_plan_fast(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      w13d_p169np_admitted_fast(request,p111_runtime_admission(request))

@unsafe
def x198pw_prepared_fast(+path: String,+source: String,prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: x198pw_plan_fast(p86_plan(seed,path,source))

@unsafe
def x198pw_compile_fast(+path: String,+source: String,+base_path: String,+base: String,
    +carrier: String,+stamp: String,+cached: Bool) -> P169Prepared:
  x198pw_prepared_fast(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))


# Native x86 request protocol. The shared accepted-source and final native-body
# verification path constructs the cursor before emission.
@unsafe
def x181_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +object: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x187_print_mode(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),object),
      u => x187_print_mode(x198pw_compile(path,source,base_path,base,"",stamp,False{}),object))


# === AGY-W3B-PARCG ===
law agy_parcg_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +shard: U32
  for +shards: U32
  for +rem: U32
  X187ObjectResult

@unsafe
def agy_parcg_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +shard: U32, +shards: U32, +rem: U32) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Private{Con{head,rest},+context,next}:
      agy_parcg_cursor(P134Private{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_private(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Legacy{entries,context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Public{Nil{},context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Public{Con{head,rest},+context,next}:
      agy_parcg_cursor(P134Public{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_public(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Tables{Nil{}}: agy_parcg_cursor(P134Main{},available,build,shard,shards,0)
    case P134Tables{Con{head,rest}}:
      nt_choose(X187ObjectResult,U32.is_eq(shard,0),
        u => agy_parcg_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),shard,shards,0),
        u => agy_parcg_cursor(P134Main{},available,build,shard,shards,0))
    case P134Main{}:
      nt_choose(X187ObjectResult,U32.is_eq(shard,0),
        u => agy_parcg_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_finish(build))
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def agy_parcg_cursor(cursor, available, build, shard, shards, rem):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => agy_parcg_cursor_good(cursor,available,build,shard,shards,rem),
    u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def agy_parcg_emit_shard(+ready: AgyParCgReady, +shard: U32, +shards: U32) -> X187ObjectResult:
  match ready:
    case AgyParCgReady{+cursor,+available,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,U32.is_le(shards,1),
          v => x187_cursor(cursor,available,x187_build_empty()),
          v => agy_parcg_cursor(cursor,available,x187_build_empty(),shard,shards,0)),
        u => X187ObjectResult{[],error})


# === AGY-W5B-PARCG-PRESLICED ===
law agy_parcg_presliced_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +is_main: Bool
  X187ObjectResult

@unsafe
def agy_parcg_presliced_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +is_main: Bool) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: agy_parcg_presliced_cursor(next,available,build,is_main)
    case P134Private{Con{head,rest},+context,next}:
      agy_parcg_presliced_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build),is_main)
    case P134Legacy{entries,context,next}: agy_parcg_presliced_cursor(next,available,build,is_main)
    case P134Public{Nil{},context,next}: agy_parcg_presliced_cursor(next,available,build,is_main)
    case P134Public{Con{head,rest},+context,next}:
      agy_parcg_presliced_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build),is_main)
    case P134Tables{Nil{}}: agy_parcg_presliced_cursor(P134Main{},available,build,is_main)
    case P134Tables{Con{head,rest}}:
      nt_choose(X187ObjectResult,is_main,
        u => agy_parcg_presliced_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),is_main),
        u => agy_parcg_presliced_cursor(P134Main{},available,build,is_main))
    case P134Main{}:
      nt_choose(X187ObjectResult,is_main,
        u => agy_parcg_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_finish(build))
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def agy_parcg_presliced_cursor(cursor, available, build, is_main):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => agy_parcg_presliced_good(cursor,available,build,is_main),
    u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def agy_parcg_emit_presliced(+ready: AgyParCgReady, +is_main: Bool) -> X187ObjectResult:
  match ready:
    case AgyParCgReady{+cursor,+available,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => agy_parcg_presliced_cursor(cursor,available,x187_build_empty(),is_main),
        u => X187ObjectResult{[],error})

@unsafe
def x187_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(shards,1),
    u => x187_prepared(prepared),
    u => agy_parcg_emit_shard(agy_parcg_prepare_cursor(prepared),shard,shards))

law agy_parcg_native_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +shard: U32
  for +shards: U32
  for +rem: U32
  IO(U32)

@unsafe
def agy_parcg_native_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +shard: U32, +shards: U32, +rem: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Private{Con{head,rest},+context,next}:
      agy_parcg_native_cursor(P134Private{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_private(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Legacy{entries,context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Public{Nil{},context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Public{Con{head,rest},+context,next}:
      agy_parcg_native_cursor(P134Public{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_public(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Tables{Nil{}}: agy_parcg_native_cursor(P134Main{},available,build,shard,shards,0)
    case P134Tables{Con{head,rest}}:
      nt_choose(IO(U32),U32.is_eq(shard,0),
        u => agy_parcg_native_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),shard,shards,0),
        u => agy_parcg_native_cursor(P134Main{},available,build,shard,shards,0))
    case P134Main{}:
      nt_choose(IO(U32),U32.is_eq(shard,0),
        u => agy_parcg_native_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_native_finish(build))
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def agy_parcg_native_cursor(cursor, available, build, shard, shards, rem):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => agy_parcg_native_cursor_good(cursor,available,build,shard,shards,rem),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_parcg_native_prepared(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),
        v => agy_parcg_native_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty(),shard,shards,0),
        v => IO.die(U32,1,error))

@unsafe
def x202p_x187_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(shards,1),
    u => x202p_x187_prepared(prepared),
    u => agy_parcg_native_prepared(prepared,shard,shards))

@unsafe
def agy_parcg_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +shard: U32, +shards: U32) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x202p_x187_prepared_shard(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),shard,shards),
      u => x202p_x187_prepared_shard(x198pw_compile(path,source,base_path,base,"",stamp,False{}),shard,shards))

@unsafe
def agy_parcg_entry_shard(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, shard_m: Maybe<&2,U32>, shards_m: Maybe<&2,U32>) -> IO(U32):
  match shard_m shards_m:
    case Some{+shard} Some{+shards}:
      nt_choose(IO(U32),U32.is_ge(shards,1) && U32.is_lt(shard,shards),
        u => agy_parcg_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),shard,shards),
        u => IO.die(U32,2,"expected 0 <= shard < shards and shards >= 1"))
    case _ _: IO.die(U32,2,"expected U32 shard and shards arguments")


# === AGY-W6-NATIVE-LPT-SHARD ===
@unsafe
def agy_lpt_emit_priv(+xs: List<&2,AgyLptPriv>, +context: P134Context, +available: KDef,
    +build: X187Build, +loads: List<&2,U32>, +shard: U32) -> AgyLptPrivOut:
  match xs:
    case Nil{}: AgyLptPrivOut{build,loads}
    case Con{AgyLptPriv{+w,item},rest}:
      nt_choose(AgyLptPrivOut,String.is_empty(x187_build_message(build)),u =>
        agy_lpt_emit_priv_step(w,item,rest,context,available,build,loads,shard,agy_lpt_min_idx(loads)),
        u => AgyLptPrivOut{build,loads})

@unsafe
def agy_lpt_emit_priv_step(+w: U32, item: P113DFunction, rest: List<&2,AgyLptPriv>, +context: P134Context,
    +available: KDef, +build: X187Build, +loads: List<&2,U32>, +shard: U32, +bucket: U32) -> AgyLptPrivOut:
  agy_lpt_emit_priv(rest,context,available,
    nt_choose(X187Build,U32.is_eq(bucket,shard),u => x187_output(x181_program_private(item,context,available),build),u => build),
    agy_lpt_add_load(loads,bucket,w),shard)

@unsafe
def agy_lpt_emit_pub(+xs: List<&2,AgyLptPub>, +context: P134Context, +available: KDef,
    +build: X187Build, +loads: List<&2,U32>, +shard: U32) -> AgyLptPrivOut:
  match xs:
    case Nil{}: AgyLptPrivOut{build,loads}
    case Con{AgyLptPub{+w,item},rest}:
      nt_choose(AgyLptPrivOut,String.is_empty(x187_build_message(build)),u =>
        agy_lpt_emit_pub_step(w,item,rest,context,available,build,loads,shard,agy_lpt_min_idx(loads)),
        u => AgyLptPrivOut{build,loads})

@unsafe
def agy_lpt_emit_pub_step(+w: U32, item: N111Segment, rest: List<&2,AgyLptPub>, +context: P134Context,
    +available: KDef, +build: X187Build, +loads: List<&2,U32>, +shard: U32, +bucket: U32) -> AgyLptPrivOut:
  agy_lpt_emit_pub(rest,context,available,
    nt_choose(X187Build,U32.is_eq(bucket,shard),u => x187_output(x181_program_public(item,context,available),build),u => build),
    agy_lpt_add_load(loads,bucket,w),shard)

law agy_lpt_native_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +loads: List<&2,U32>
  for +shard: U32
  for +table_shard: U32
  IO(U32)

@unsafe
def agy_lpt_cursor_after(+next: P134Cursor, +available: KDef, +shard: U32, +table_shard: U32, out: AgyLptPrivOut) -> IO(U32):
  match out:
    case AgyLptPrivOut{build,loads}: agy_lpt_native_cursor(next,available,build,loads,shard,table_shard)

@unsafe
def agy_lpt_native_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +table_shard: U32) -> IO(U32):
  match cursor:
    case P134Private{fns,+context,next}:
      agy_lpt_cursor_after(next,available,shard,table_shard,
        agy_lpt_emit_priv(agy_lpt_priv_sort(agy_lpt_priv_wrap(fns,[])),context,available,build,loads,shard))
    case P134Legacy{entries,context,next}: agy_lpt_native_cursor(next,available,build,loads,shard,table_shard)
    case P134Public{segs,+context,next}:
      agy_lpt_cursor_after(next,available,shard,table_shard,
        agy_lpt_emit_pub(agy_lpt_pub_sort(agy_lpt_pub_wrap(segs,[])),context,available,build,loads,shard))
    case P134Tables{Nil{}}: agy_lpt_native_cursor(P134Main{},available,build,loads,shard,agy_lpt_min_idx(loads))
    case P134Tables{Con{head,rest}}:
      agy_lpt_tables_step(head,rest,available,build,loads,shard,agy_lpt_min_idx(loads))
    case P134Main{}:
      nt_choose(IO(U32),U32.is_eq(shard,table_shard),
        u => agy_parcg_native_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_native_finish(build))
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def agy_lpt_tables_go(+tables: List<&2,P111QData>, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +owner: U32) -> IO(U32):
  match tables:
    case Nil{}: agy_lpt_native_cursor(P134Main{},available,build,loads,shard,owner)
    case Con{head,rest}:
      nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
        u => agy_lpt_tables_go(rest,available,x187_output(x181_program_data(head,available),build),loads,shard,owner),
        u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_lpt_tables_step(head: P111QData, rest: List<&2,P111QData>, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +owner: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_eq(shard,owner),
    u => agy_lpt_tables_go(rest,available,x187_output(x181_program_data(head,available),build),loads,shard,owner),
    u => agy_lpt_native_cursor(P134Main{},available,build,loads,shard,owner))

@unsafe
def agy_lpt_native_cursor(cursor, available, build, loads, shard, table_shard):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => agy_lpt_native_cursor_good(cursor,available,build,loads,shard,table_shard),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_lpt_native_prepared(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),
        v => agy_lpt_native_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty(),agy_lpt_zero_loads(shards,[]),shard,0),
        v => IO.die(U32,1,error))

@unsafe
def agy_lpt_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(shards,1),
    u => x202p_x187_prepared(prepared),
    u => agy_lpt_native_prepared(prepared,shard,shards))

@unsafe
def agy_lpt_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +shard: U32, +shards: U32) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        agy_lpt_prepared_shard(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),shard,shards),
      u => agy_lpt_prepared_shard(x198pw_compile(path,source,base_path,base,"",stamp,False{}),shard,shards))

@unsafe
def agy_lpt_entry_shard(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, shard_m: Maybe<&2,U32>, shards_m: Maybe<&2,U32>) -> IO(U32):
  match shard_m shards_m:
    case Some{+shard} Some{+shards}:
      nt_choose(IO(U32),U32.is_ge(shards,1) && U32.is_lt(shard,shards),
        u => agy_lpt_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),shard,shards),
        u => IO.die(U32,2,"expected 0 <= shard < shards and shards >= 1"))
    case _ _: IO.die(U32,2,"expected U32 shard and shards arguments")

@unsafe
def x187_print_fast(prepared: P169Prepared) -> IO(U32):
  x187_print_result(x187_prepared_fast(prepared))

@unsafe
def x181_request_fast(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x187_print_fast(x198pw_compile_fast(path,source,base_path,base,carrier,stamp,True{})),
      u => x187_print_fast(x198pw_compile_fast(path,source,base_path,base,"",stamp,False{})))

# Wave 8: Per-module disjoint 16-bit FID base + link-time table merge exports.
@unsafe
def w8_module_cursor(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_module_cursor_good(cursor,available,build),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_module_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w8_module_cursor(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      w8_module_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build))
    case P134Legacy{entries,context,next}: w8_module_cursor(next,available,build)
    case P134Public{Nil{},context,next}: w8_module_cursor(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      w8_module_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build))
    case P134Tables{Nil{}}: w8_module_cursor(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      w8_module_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x202p_x201f_finish(build)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_module_prepared(+prepared: P169Prepared, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w8_module_cursor(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty()),
          v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w8_module_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        w8_module_prepared(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),fid_base,mod_name),
      u => w8_module_prepared(x198pw_compile(path,source,base_path,base,"",stamp,False{}),fid_base,mod_name))


# === WAVE 10 M1: Pure-Bend x86-merge-obj ===
# Wave 10 M1: 100% Pure-Bend Link-Time Segment Table Merge Object Emitter (`x86-merge-obj`)
#
# Replaces `research/agy/w8_fid_base/p111_link_merge.c` completely with zero C,
# emitting a relocatable x86-64 ELF `.o` via `compiler.bend`'s existing
# `x188_*` x86-64 encoder and `x187_*` / `x202p_x201f_finish` ELF emitter.
#
# CLI mode (dispatched from `w8_dispatch_args`):
#   x86-merge-obj ENTRY_MOD MOD0 [MOD1 ...]
#
# Emits:
#   .data (section 3):
#     - global p111_program           (192 bytes, ABI11102 P111Program)
#     - local  w8_merged_segments     (65532 * 8 = 524256 bytes)
#     - local  w8_merged_fid_arity    (65532 bytes)
#     - local  w8_merged_fid_flags    (65532 bytes)
#     - local  w8_merged_fid_results  (65532 bytes)
#   .text (section 1):
#     - local  w8_unused_seg          (`ret`)
#     - global main(argc, argv):
#         preserves %edi (argc) and %rsi (argv) across all loops using only
#         caller-saved scratch registers (%rax, %rcx, %rdx, %r8..%r11), merges
#         all module segment tables at `p111_mod_<M>_fid_base`, sets `main_fid`
#         from `p111_mod_<ENTRY_MOD>_program`, and tail-calls `p111_rt_main`.

law w10_module_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10_module_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x201f_finish(build,weak_set)
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def w10_module_cursor(cursor, available, build, weak_set):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_good(cursor,available,build,weak_set),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def w10_module_prepared(+prepared: P169Prepared, seed: P86Seed, +fid_base: U32, +mod_name: String) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      +weak_set = w10_weak_from_seed(seed)
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => nt_choose(X187ObjectResult,U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => X187ObjectResult{[],"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"}),
        u => X187ObjectResult{[],error})

# --- IO(U32) streaming path (used by native `x86-module` CLI) ---

@unsafe
def w11_program_public_mod(+segment: N111Segment, context: P134Context, +available: KDef, +weak_set: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      nt_choose(X181Output,w10_is_weak_sym(weak_set,p111q_symbol(name)),
        u => x181_program_join(X181Output{[],x181_program_scalars(body,available)},x181_segment(segment,ids)),
        u => x181_program_public(segment,context,available))

law w10_module_cursor_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)

@unsafe
def w10_module_cursor_io_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Public{rest,context,next},available,x187_output(w11_program_public_mod(head,context,available,weak_set),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w10_module_cursor_io(cursor, available, build, weak_set):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_io_good(cursor,available,build,weak_set),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w10_module_prepared_io(+prepared: P169Prepared, +weak_set: KDef, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_io(w8_relocate_cursor(w11_enrich_cursor_mod(cursor,avail,weak_set),fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w10_module_prep_run(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_io(x198pw_plan(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)

@unsafe
def w10_module_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +prep : P86Preparation = nt_choose(P86Preparation,cached,
      u => p88_cache_prepare(base_path,base,carrier,stamp),
      u => p86_prepare(base_path,base))
    w10_module_prep_run(path,source,fid_base,mod_name,prep)

# === WAVE 10 PHASE 3 (P3-A): Zero-Copy Per-Function .L* Resolution + Tail-Fused ELF ===

@unsafe
def w13c_pub_emit_body(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +build: X187Build) -> X187Build:
  +uses_state = w4_body_uses_state(body)
  +stateKind = nt_choose(String,uses_state,u => "X181Register",u => "X181UnusedState")
  +savedMask = nt_choose(U32,uses_state,u => 1,u => 0)
  +s0 = p111v_put(p111v_put(missing(),"state",stateKind,0,8),"__x181_saved_mask","X186SavedMask",savedMask,0)
  +init : X181Frame = X181Frame{s0,40,0,["state"],""}
  +f1 = x181_frame_buffer("scratch",2048,16,init)
  +f2 = x181_frame_buffer("__x181_results",64,16,f1)
  +f3 = x181_frame_buffer("__x181_tail",8,8,f2)
  w13c_pub_emit_framed(sym,body,ids,uses_state,build,x181_frame_stmts(body,f3))

@unsafe
def w13c_pub_emit_late(+sym: String, +ids: N111Ids, +build: X187Build, late: P113ABody) -> X187Build:
  match late:
    case P113ABody{ready,_}: w13c_pub_emit_body(sym,ready,ids,build)

@unsafe
def w13c_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)
      nt_choose(X187Build,String.is_empty(error),
        v =>
          +sym = p111q_symbol(name)
          nt_choose(X187Build,x202k_shape(body),
            w => w13c_emit_x202k(sym,build),
            w =>
              +rows = x181_scalar_rows(body)
              nt_choose(X187Build,x185_late_enabled() && p114t_scalar_list_names(body),
                z => w13c_pub_emit_late(sym,ids,build,x185_late_stmts(rows,ids,0)),
                z => w13c_pub_emit_body(sym,rows,ids,build))),
        v => x187_build_error(error,build))

@unsafe
def w13c_pub_emit_fast(segment, context, available, build):
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => w13c_pub_emit_seg(segment,context,available,build),
    u => build)

# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ===

law w10_module_cursor_fast:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10_module_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10f_x201f_finish_any(build,True{},weak_set)
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def w10_module_cursor_fast(cursor, available, build, weak_set):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_fast_good(cursor,available,build,weak_set),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def w10_module_prepared_fast(+prepared: P169Prepared, seed: P86Seed, +fid_base: U32, +mod_name: String) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      +weak_set = w10_weak_from_seed(seed)
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => nt_choose(X187ObjectResult,U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_fast(w8_relocate_cursor(cursor,fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => X187ObjectResult{[],"x86-module-fast: fid_base + segment_count exceeds 16-bit FID capacity (65532)"}),
        u => X187ObjectResult{[],error})

law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)

@unsafe
def w10_module_cursor_fast_io_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w10_module_cursor_fast_io(cursor, available, build, weak_set):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_fast_io_good(cursor,available,build,weak_set),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w10_module_prepared_fast_io(+prepared: P169Prepared, +weak_set: KDef, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_fast_io(w8_relocate_cursor(cursor,fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => IO.die(U32,1,"x86-module-fast: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan_fast(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)

@unsafe
def w10_module_request_fast(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +prep : P86Preparation = nt_choose(P86Preparation,cached,
      u => p88_cache_prepare(base_path,base,carrier,stamp),
      u => p86_prepare(base_path,base))
    w10_module_prep_run_fast(path,source,fid_base,mod_name,prep)

@unsafe
def w10_module_fast_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w10_module_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")


# === WAVE 10 M3: Pure-Bend x86-iface ===
# === AGY-W10-M3-IFACE: Pure-Bend x86-iface (.p130 interface carrier emitter) ===
# Eliminates build_iface_carrier.mjs completely:
#   x86-iface ABS_PREFIX ABS_BASE live|cache ABS_BASE_CARRIER STAMP
#   - Loads Base via p88_cache_prepare (or p86_prepare in live mode)
#   - Checks PREFIX via p86_plan & extracts exact direct/CPS ABI from x198pw_plan
#   - Replaces non-Base Def bodies with ABI-matched self-recursive stubs (no nm!)
#   - Computes deterministic dual 32-bit FNV-1a interface stamp (types + sigs + ABI only)
#   - Streams exact .p130 word-pair carrier to stdout and prints stamp to stderr

@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      nt_choose(IO(U32), w10_if_all_stub_defs(fresh_suffix),
        u =>
          +s_ready : FReadyPrefixState = w10_if_ready_extend(base_ready, s_book, fresh_suffix)
          w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),
        u =>
          +s_ready : FReadyPrefixState = f_ready_prefix_prepare(s_book)
          +checked : DChecking = base_prefix_resume_world(base_world, fresh_suffix, norm_max_book(s_book))
          nt_choose(IO(U32), good(dg_checking_result(checked)),
            v =>
              +s_state : KBasePrefixState = w10_if_mark_ready(p86_checked_prefix(s_book, checked))
              +s_world : KBasePreparedWorld = base_prefix_world_prepare(s_book, s_state)
              w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),
            v => IO.die(U32, 1, "x86-iface: stub check failed: " ++ ce(dg_checking_result(checked)))))

@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, +base_ready, +base_world}:
      +stamp = w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi))
      +stripped = w10_if_strip_suffix(suffix, abi, missing())
      w10_if_emit_freshened(stamp, base_book, base_ready, base_world, f_fresh_defs(stripped, base_next))

# --- Upstream stub fast-path for direct-ABI scan (strips Ann wrappers!) ---

@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, active_filtered, bangs, sigs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          +scan_names = w10_if_drop_upstream_stubs(sbook, suf_set, no_candidate_names(sbook, names, bangs))
          w10_if_fast_abi_scan(seed, suffix, suf_set, sbook, names, bangs,
            p128br_scan(sbook, scan_names, Nil{}, Nil{}, Nil{}, Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u =>
          +ctors = nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
          w10_if_fast_abi_prep(seed, suffix, names, p112s_prepare(book, names, ctors)),
        u => IO.die(U32, 1, "x86-iface: " ++ err))

@unsafe
def w10_if_run_fast_plan(+seed: P86Seed, +suffix: List<&2, KDef>, plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{err}: IO.die(U32, 1, "x86-iface: " ++ err)
    case P86PlanReady{request, verdict}:
      w10_if_fast_abi_req(seed, suffix, request)

@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => w10_if_run_fast_plan(seed, suffix, p86_plan_loaded(seed, load)),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))

@unsafe
def w10_if_run_comp2(+seed: P86Seed, +source: FSource, +base: FSource, +fresh: FFreshPrefixState, comp2: FPrefixCompletion) -> IO(U32):
  match comp2:
    case FPrefixCompletion{carrier2, _}:
      w10_if_run_trace(seed, f_prefix_graph_trace(carrier2, [source, base], fresh))

@unsafe
def w10_if_run_comp1(+seed: P86Seed, +source: FSource, +base: FSource, +fresh: FFreshPrefixState, +header: FHeader, comp1: FPrefixCompletion) -> IO(U32):
  match comp1:
    case FPrefixCompletion{+carrier, FResult{_, +perr, _}}:
      nt_choose(IO(U32), String.is_empty(perr),
        w => w10_if_run_comp2(seed, source, base, fresh, f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
        w => IO.die(U32, 1, "x86-iface base seed: " ++ perr))

@unsafe
def w10_if_run_hdr(+seed: P86Seed, +base: FSource, +book: List<&2, KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +source: FSource, +header: FHeader) -> IO(U32):
  match header:
    case FHeader{+imports, +herr, body, line, offset}:
      nt_choose(IO(U32), String.is_empty(herr),
        u =>
          +ierr = p86_import_error(imports, False{})
          nt_choose(IO(U32), String.is_empty(ierr),
            v => w10_if_run_comp1(seed, source, base, fresh, header, f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready)),
            v => IO.die(U32, 1, "x86-iface import: " ++ ierr)),
        u => IO.die(U32, 1, "x86-iface header: " ++ herr))

@unsafe
def w10_if_run_prepared(+path: String, +text: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{+seed}:
      match seed:
        case P86Seed{+base, +book, +fresh, +ready, world}:
          +begin = f_source_end(base)
          +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
          w10_if_run_hdr(seed, base, book, fresh, ready, source, f_source_header(source))

@unsafe
def w10_iface_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32), cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        w10_if_run_prepared(path, source, p88_cache_prepare(base_path, base, carrier, stamp)),
      u => w10_if_run_prepared(path, source, p86_prepare(base_path, base)))

@unsafe
def w8_module_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w10_module_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")

# Wave 8: Pure-Bend live build tracing & stage profiler (`--trace`).
@unsafe
def w8_tr_compile_prep(+trace: Bool, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(W10TrCompiled):
  match prep:
    case P86PreparationError{error}:
      do IO<W10TrCompiled>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(W10TrCompiled,W10TrCompiled{p169s_fail(error),missing()})
    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,nt_choose(P169Prepared,fast,u => x198pw_plan_fast(plan),u => x198pw_plan(plan)))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared,weak_set)

@unsafe
def w8_tr_compile(+trace: Bool, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +base_path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(W10TrCompiled):
  do IO<W10TrCompiled>:
    +t0 : Nat <- IO.now()
    +prep : P86Preparation <- IO.pure(P86Preparation,
      nt_choose(P86Preparation,cached,
        u => p88_cache_prepare(base_path,base,carrier,stamp),
        u => p86_prepare(base_path,base)))
    +t1 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=prep ms=" ++ w8_tr_ms(t0,t1))
    w8_tr_compile_prep(trace,fast,is_mod,path,source,t1,prep)

@unsafe
def w8_tr_emit_cursor(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_tr_emit_good(trace,fast,is_mod,weak_set,t_start,cursor,avail,build,priv_n,pub_n,total_segs),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_tr_emit_priv(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: P113DFunction, rest: List<&2,P113DFunction>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = w10f_output_fn(out,build)
    +n2 : U32 = U32.inc(priv_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,500),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_priv done=" ++ U32.show(n2) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Private{rest,ctx,next},avail,b2,n2,pub_n,total_segs)

@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +b2 : X187Build = nt_choose(X187Build,fast,
      u => w13c_pub_emit_fast(head,ctx,avail,build),
      u => w10f_output_fn(nt_choose(X181Output,is_mod,
        v => w11_program_public_mod(head,ctx,avail,weak_set),
        v => x181_program_public(head,ctx,avail)),build))
    +n2 : U32 = U32.inc(pub_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,2000),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Public{rest,ctx,next},avail,b2,priv_n,n2,total_segs)

@unsafe
def w8_tr_emit_good(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_priv_done count=" ++ U32.show(priv_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Private{Con{head,rest},ctx,next}:
      w8_tr_emit_priv(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Legacy{es,ctx,next}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Con{head,rest},ctx,next}:
      w8_tr_emit_pub(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Nil{}}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Main{},avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Con{head,rest}}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Tables{rest},avail,x187_output(x181_program_data(head,avail),build),priv_n,pub_n,total_segs)
    case P134Main{}:
      do IO<U32>:
        +t_elf0 : Nat <- IO.now()
        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => w10_x202p_x201f_finish(build,weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(),build)))
        +t_elf1 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_elf ms=" ++ w8_tr_ms(t_elf0,t_elf1) ++ " total_ms=" ++ w8_tr_ms(t_start,t_elf1))
        IO.pure(U32,rc)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_tr_run_prepared(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, compiled: W10TrCompiled) -> IO(U32):
  match compiled:
    case W10TrCompiled{P169Prepared{fw,+cursor,+error},+weak_set}:
      nt_choose(IO(U32),String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor,missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32),is_mod && U32.is_gt(U32.add(fid_base,segs),65532),
            v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = nt_choose(P134Cursor,fast,w => cursor,
                w => nt_choose(P134Cursor,is_mod,z => w11_enrich_cursor_mod(cursor,avail,weak_set),z => agy_enrich_cursor(cursor,avail)))
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)
              w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t0,cur2,avail,x187_build_empty(),0,0,segs)),
        u => IO.die(U32,1,error))

@unsafe
def w8_tr_run_obj(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => nt_choose(String,fast,v => " mode=x86-module-fast mod=",v => " mode=x86-module mod=") ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=read ms=" ++ w8_tr_ms(t0,t_rd))
    +compiled : W10TrCompiled <- w8_tr_compile(trace,fast,is_mod,path,source,base_path,base,carrier,stamp,cached)
    w8_tr_run_prepared(trace,fast,is_mod,fid_base,mod_name,t0,compiled)

@unsafe
def w8_tr_mod_fid(fid_m: Maybe<&2,U32>, +fast: Bool, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: w8_tr_run_obj(True{},fast,True{},fb,mod_name,path,base,carrier,stamp,cached)
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def w8_tr_entry(+args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_run_obj(True{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(U32.read(fid_s),agy_str_eq(program,"x86-module-fast"),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)

@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86") || agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast") || agy_str_eq(program,"x86-iface")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-iface"),
          v => w10_iface_request(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
          v => nt_choose(IO(U32),agy_str_eq(program,"x86-object-fast"),
            w => x181_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
            w => x181_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),agy_str_eq(program,"x86-object")))),
        u => IO.die(U32,2,"expected x86|x86-object|x86-object-fast|x86-iface, absolute input/Base paths and live|cache mode"))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-shard") || agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-module-fast"),
          v => w10_module_fast_entry(path,base,mode,carrier,stamp,U32.read(shard_s),shards_s),
          v => nt_choose(IO(U32),agy_str_eq(program,"x86-module"),
            w => w8_module_entry(path,base,mode,carrier,stamp,U32.read(shard_s),shards_s),
            w => nt_choose(IO(U32),agy_str_eq(program,"x86-shard"),
              z => agy_lpt_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
              z => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s))))),
        u => IO.die(U32,2,"expected x86-object|x86-shard|x86-module|x86-module-fast, absolute input/Base paths, live|cache mode, and shard/shards or fid_base/mod_name"))
    case _: IO.die(U32,2,"usage: x86|x86-object|x86-object-fast|x86-shard|x86-module|x86-module-fast ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS | FID_BASE MOD_NAME]")

@unsafe
def x187_print_mode(+prepared: P169Prepared, object: Bool) -> IO(U32):
  nt_choose(IO(U32),object,u => x187_print(prepared),u => x181_print(prepared))
# IO.args includes argv[0] under bend-rts-v1. The request starts after it.
# P5-F: Pure-Bend `--trace-slow <ms>` per-function slow-cliff profiler.
# Uses native IO.now() and IO.print_err() effects; stdout .o bytes are untouched.
# Instruments:
#   - stage=parse     : per top-level decl (def/law/type, incl. ff_match) via p140p_tops cut
#   - stage=check     : per KDef typecheck via check_definition_world
#   - stage=x187_priv : per P113DFunction codegen (-O0 and -O2)
#   - stage=x187_pub  : per N111Segment codegen (-O0 and -O2)

law ts_tops_io:
  for +thresh: Nat
  for +ts0: FInput
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +scope: FParseScope
  IO(FRawResult)

@unsafe
def ts_tops_step_io(+thresh: Nat, +t0: Nat, +t1: Nat, step: P140PStop) -> IO(FRawResult):
  match step:
    case P140PDone{+raw}:
      do IO<FRawResult>:
        _ : Unit <- ts_log_slow(thresh, "parse", ts_raw_head_name(raw), t0, t1)
        IO.pure(FRawResult, raw)
    case P140PCut{+ts2, +book2, +imports2, +unsafe2, +scope2}:
      do IO<FRawResult>:
        _ : Unit <- ts_log_slow(thresh, "parse", ts_head_def_name(book2), t0, t1)
        ts_tops_io(thresh, ts2, book2, imports2, unsafe2, scope2)

@unsafe
def ts_tops_io(thresh, ts0, book, imports, unsafe, scope):
  do IO<FRawResult>:
    +t0 : Nat <- IO.now()
    +stop : U32 = U32.inc(f_begin(f_skip(ts0)))
    +step : P140PStop <- IO.pure(P140PStop, p140p_tops(stop, ts0, book, imports, unsafe, scope))
    +t1 : Nat <- IO.now()
    ts_tops_step_io(thresh, t0, t1, step)

@unsafe
def ts_body_header_io(+thresh: Nat, +source: String, +header: FHeader, +scope: FParseScope, +start: U32) -> IO(FResult):
  match header:
    case FHeader{+imports, +error, +body, +line, +offset}:
      nt_choose(IO(FResult), String.is_empty(error),
        u => do IO<FResult>:
          +inp : FInput = f_input(f_lex_cursor(body, line, 0, 0, Nil{}, f_cursor_add(start, offset), f_cursor_add(start, offset)))
          +raw : FRawResult <- ts_tops_io(thresh, inp, Nil{}, List.reverse(&2, KTerm, imports), False{}, p144p_ready_scope(scope))
          IO.pure(FResult, f_context_result(fpe_finish_indexed(start, source, raw))),
        u => IO.pure(FResult, FResult{Nil{}, error, imports}))

@unsafe
def ts_source_body_indexed_io(+thresh: Nat, +source: FSource, +header: FHeader, +scope: FParseScope, +start: U32) -> IO(FResult):
  match source:
    case FSource{name, path, +text}: ts_body_header_io(thresh, text, header, scope, start)
    case FCompletedSource{name, path, text, +parsed}: IO.pure(FResult, parsed)
    case FLocatedSource{+inner, +begin, end}: ts_source_body_indexed_io(thresh, inner, header, scope, begin)

@unsafe
def ts_complete_aliases_indexed_io(+thresh: Nat, +source: FSource, +ns: String, +header: FHeader,
    +graph: FGraph, +aliases: List<&2, KTerm>, +prior: List<&2, KDef>, +sources: List<&2, FSource>,
    +names: KDef, +ctors: KDef) -> IO(FIndexedCompletion):
  do IO<FIndexedCompletion>:
    +parsed : FResult <- ts_source_body_indexed_io(thresh, source, header, FParseScope{prior, names, ctors, ns, aliases, None{}}, 0)
    IO.pure(FIndexedCompletion, f_graph_finish_indexed(source, ns, aliases, graph, sources, names, parsed))

@unsafe
def ts_complete_source_indexed_io(+thresh: Nat, +source: FSource, +ns: String, +header: FHeader,
    +sources: List<&2, FSource>, +graph: FGraph, +root: String, +names: KDef, +ctors: KDef) -> IO(FIndexedCompletion):
  match graph:
    case FGraph{+book, +error, done}:
      nt_choose(IO(FIndexedCompletion), String.is_empty(error),
        u => ts_complete_aliases_indexed_io(thresh, source, ns, header, graph,
          f_graph_aliases(f_header_imports(header), source, sources, root), book, sources, names, ctors),
        u => IO.pure(FIndexedCompletion, FIndexedCompletion{graph, FResult{Nil{}, error, Nil{}}, Nil{}}))

@unsafe
def ts_prefix_complete_source_io(+thresh: Nat, +source: FSource, +ns: String, +header: FHeader,
    +sources: List<&2, FSource>, +carrier: FPrefixGraph, +root: String) -> IO(FPrefixCompletion):
  match carrier:
    case FPrefixGraph{+graph, +prefix, suffix, +count, +ready}:
      IO.pure(FPrefixCompletion, f_prefix_source_completed(prefix, count, ready, f_complete_source(source, ns, header, sources, graph, root)))
    case FReadyPrefixGraph{+graph, +prefix, +suffix, +count, +ready, +names, +ctors, +baseNames}:
      nt_choose(IO(FPrefixCompletion), ready,
        u => do IO<FPrefixCompletion>:
          +ic : FIndexedCompletion <- ts_complete_source_indexed_io(thresh, source, ns, header, sources, graph, root, names, ctors)
          IO.pure(FPrefixCompletion, f_prefix_ready_source_completed(prefix, suffix, count, baseNames, names, ctors, ic)),
        u => IO.pure(FPrefixCompletion, f_prefix_source_completed(prefix, count, False{}, f_complete_source(source, ns, header, sources, graph, root))))

# --- Stage 2: Per-definition typechecking inside p156cp_walk ---

@unsafe
def ts_p156cp_walk_io(+thresh: Nat, events: List<&2, P143CEvent>, +world: KWorld,
    +seen: List<&2, KDef>, +dirty: Bool) -> IO(DChecking):
  match events:
    case Nil{}: IO.pure(DChecking, DChecking{bad(world, ""), dg_no_report("", "")})
    case Con{P143CEvent{+definition, +next}, +rest}:
      +guard : String = event_error(seen, definition, lookup(seen, dn(definition)))
      nt_choose(IO(DChecking), p88_string_eq(guard, ""),
        u => do IO<DChecking>:
          +t0 : Nat <- IO.now()
          +res : KChecking <- IO.pure(KChecking, check_definition_world(world, p143cs_mode(definition, next), 0))
          +t1 : Nat <- IO.now()
          _ : Unit <- ts_log_slow(thresh, "check", dn(definition), t0, t1)
          nt_choose(IO(DChecking), good(res),
            v => nt_choose(IO(DChecking), p88_string_eq(dk(next), "Absent"),
              w => do IO<DChecking>:
                +bk : List<&2, KDef> = kw_book(rw(res))
                +bk2 : List<&2, KDef> = ts_p156cp_book(definition, bk, dirty)
                +d2 : Bool = ts_p156cp_dirty(definition, bk)
                +w2 : KWorld = kw_put_checked(kw_with_book(rw(res), bk2), dg_event_output(definition, ct(res)))
                ts_p156cp_walk_io(thresh, rest, w2, p171s_put(seen, definition), d2),
              w => ts_p156cp_walk_io(thresh, rest, rw(res), p171s_put(seen, definition), dirty)),
            v => IO.pure(DChecking, dg_event_failed(res, dn(definition)))),
        u => IO.pure(DChecking, DChecking{bad(world, dn(definition) ++ ": " ++ guard), dg_no_report(dn(definition), guard)}))

@unsafe
def ts_p143cb_resume_state_io(+thresh: Nat, +state: KBasePrefixState, +book: List<&2, KDef>,
    +checked: List<&2, KDef>, +seen: List<&2, KDef>, +suffix: List<&2, KDef>, +bound: U32) -> IO(DChecking):
  match state:
    case KBasePrefixState{+base_bound, +delta, +stamp, patches, ready}:
      do IO<DChecking>:
        +declared : List<&2, KDef> = w7c_declare_cached(suffix, kw_bound_book(book, U32.add(bound, stamp)))
        +ordered : List<&2, KDef> = base_prefix_world_order(declared, base_prefix_world_raw(book), suffix)
        +world : KWorld = KWorld{ordered, Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, checked}
        +dc : DChecking <- ts_p156cp_walk_io(thresh, p143cs_plan(suffix), world, p171s_seed(kw_bound_book(seen, bound)), True{})
        IO.pure(DChecking, p143cp_result(dc, True{}))

@unsafe
def ts_p143cb_admitted_io(+thresh: Nat, +prepared: KBasePreparedWorld, +prefix: List<&2, KDef>,
    +suffix: List<&2, KDef>, +bound: U32) -> IO(DChecking):
  match prepared:
    case KBasePreparedWorld{+state, original, final, +saved, +checked, +seen, todos, checkedBound}:
      nt_choose(IO(DChecking), p143cp_regular(suffix) &&
        base_prefix_world_hash_disjoint(suffix, index_first(dc(index_first(saved)))),
        u => ts_p143cb_resume_state_io(thresh, state, saved, checked, seen, suffix, bound),
        u => IO.pure(DChecking, base_prefix_world_check_admitted(prepared, prefix, suffix, bound)))

@unsafe
def ts_p143cb_program_io(+thresh: Nat, +load: FPrefixLoad, +origins: List<&2, DOrigin>,
    +prepared: KBasePreparedWorld) -> IO(DResult):
  match load:
    case FPrefixLoad{trace, +prefix, +suffix, +ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+book, +error, imports}:
              match prepared:
                case KBasePreparedWorld{+state, original, +final, +saved, checked, seen, +todos, checkedBound}:
                  +bound : U32 = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
                  nt_choose(IO(DResult), ready && String.is_empty(error) &&
                    base_prefix_world_admitted(state, suffix, bound, final, saved),
                    u => do IO<DResult>:
                      +dc : DChecking <- ts_p143cb_admitted_io(thresh, prepared, prefix, suffix, bound)
                      IO.pure(DResult, driver_program_checked_prefix(suffix, todos, origins, dc)),
                    u => IO.pure(DResult, driver_program_checked(book, origins, dg_check_world(book))))

# --- IO driver for p86_plan (parse + check + annotate) ---

@unsafe
def ts_p86_plan_loaded_io(+thresh: Nat, +seed: P86Seed, +load: FPrefixLoad) -> IO(P86Plan):
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, +suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              nt_choose(IO(P86Plan), String.is_empty(error),
                u => do IO<P86Plan>:
                  +tc0 : Nat <- IO.now()
                  +dres : DResult <- nt_choose(IO(DResult), p143cg_enough(suffix, 256),
                    v => ts_p143cb_program_io(thresh, load, Nil{}, world),
                    v => IO.pure(DResult, check_program_diagnostic_world(load, Nil{}, world)))
                  +tc1 : Nat <- IO.now()
                  _ : Unit <- w8_tr_log(True{}, "stage=check ms=" ++ w8_tr_ms(tc0, tc1))
                  +ta0 : Nat <- IO.now()
                  +plan : P86Plan <- IO.pure(P86Plan, p86_plan_checked(load, world, original, dres))
                  +ta1 : Nat <- IO.now()
                  _ : Unit <- w8_tr_log(True{}, "stage=annotate ms=" ++ w8_tr_ms(ta0, ta1))
                  IO.pure(P86Plan, plan),
                u => IO.pure(P86Plan, P86PlanError{"parse: " ++ error}))

@unsafe
def ts_p86_plan_comp2_io(+thresh: Nat, +seed: P86Seed, +source: FSource, +base: FSource,
    +fresh: FFreshPrefixState, comp2: FPrefixCompletion) -> IO(P86Plan):
  match comp2:
    case FPrefixCompletion{+carrier2, parsed2}:
      ts_p86_plan_loaded_io(thresh, seed, f_prefix_graph_trace(carrier2, [source, base], fresh))

@unsafe
def ts_p86_plan_seeded_io(+thresh: Nat, +seed: P86Seed, +source: FSource, +header: FHeader,
    completion: FPrefixCompletion) -> IO(P86Plan):
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{+carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          nt_choose(IO(P86Plan), String.is_empty(error),
            u => do IO<P86Plan>:
              +tp0 : Nat <- IO.now()
              +comp2 : FPrefixCompletion <- ts_prefix_complete_source_io(thresh, source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))
              +tp1 : Nat <- IO.now()
              _ : Unit <- w8_tr_log(True{}, "stage=parse ms=" ++ w8_tr_ms(tp0, tp1))
              ts_p86_plan_comp2_io(thresh, seed, source, base, fresh, comp2),
            u => IO.pure(P86Plan, P86PlanError{"parse: " ++ error}))

@unsafe
def ts_p86_plan_header_io(+thresh: Nat, +seed: P86Seed, +base: FSource, +book: List<&2, KDef>,
    +ready: FReadyPrefixState, +source: FSource, +header: FHeader) -> IO(P86Plan):
  match header:
    case FHeader{+imports, +error, body, line, offset}:
      nt_choose(IO(P86Plan), String.is_empty(error),
        u => do IO<P86Plan>:
          +ierr : String = p86_import_error(imports, False{})
          nt_choose(IO(P86Plan), String.is_empty(ierr),
            v => ts_p86_plan_seeded_io(thresh, seed, source, header,
              f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready)),
            v => IO.pure(P86Plan, P86PlanError{"load: " ++ ierr})),
        u => IO.pure(P86Plan, P86PlanError{"parse: " ++ error}))

@unsafe
def ts_p86_plan_io(+thresh: Nat, +seed: P86Seed, +path: String, +text: String) -> IO(P86Plan):
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      +begin : U32 = f_source_end(base)
      +source : FSource = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      ts_p86_plan_header_io(thresh, seed, base, book, ready, source, f_source_header(source))

# --- Stage 3 & 4: Per-function x187_priv & x187_pub codegen ---

@unsafe
def ts_compile_prep(+thresh: Nat, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(W10TrCompiled):
  match prep:
    case P86PreparationError{error}:
      do IO<W10TrCompiled>:
        _ : Unit <- w8_tr_log(True{}, "stage=prep_error msg=" ++ error)
        IO.pure(W10TrCompiled, W10TrCompiled{p169s_fail(error), missing()})
    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef, is_mod, u => w10_weak_from_seed(seed), u => missing())
        +plan : P86Plan <- ts_p86_plan_io(thresh, seed, path, source)
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(True{}, "stage=p86_plan ms=" ++ w8_tr_ms(t1, t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared, nt_choose(P169Prepared, fast, u => x198pw_plan_fast(plan), u => x198pw_plan(plan)))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(True{}, t2, t3, prepared, weak_set)

@unsafe
def ts_compile(+thresh: Nat, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +base_path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(W10TrCompiled):
  do IO<W10TrCompiled>:
    +t0 : Nat <- IO.now()
    +prep : P86Preparation <- IO.pure(P86Preparation,
      nt_choose(P86Preparation, cached,
        u => p88_cache_prepare(base_path, base, carrier, stamp),
        u => p86_prepare(base_path, base)))
    +t1 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(True{}, "stage=prep ms=" ++ w8_tr_ms(t0, t1))
    ts_compile_prep(thresh, fast, is_mod, path, source, t1, prep)

law ts_emit_cursor:
  for +thresh: Nat
  for +fast: Bool
  for +is_mod: Bool
  for +weak_set: KDef
  for +t_start: Nat
  for +cursor: P134Cursor
  for +avail: KDef
  for +build: X187Build
  for +priv_n: U32
  for +pub_n: U32
  for +total_segs: U32
  IO(U32)

@unsafe
def ts_emit_priv(+thresh: Nat, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: P113DFunction, rest: List<&2, P113DFunction>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +n2 : U32 = U32.inc(priv_n)
    +fname : String = ts_priv_name(head)
    _ : Unit <- ts_log_enter(thresh, "x187_priv", n2, fname)
    +tf0 : Nat <- IO.now()
    +out : X181Output <- IO.pure(X181Output, nt_choose(X181Output, fast,
      u => x181_program_private_fast(head, ctx, avail),
      u => x181_program_private(head, ctx, avail)))
    +b2 : X187Build <- IO.pure(X187Build, w10f_output_fn(out, build))
    +tf1 : Nat <- IO.now()
    _ : Unit <- ts_log_slow(thresh, "x187_priv", fname, tf0, tf1)
    _ : Unit <- nt_choose(IO(Unit), U32.is_eq(U32.mod(n2, 500), 0),
      u => w8_tr_log(True{}, "stage=x187_priv done=" ++ U32.show(n2) ++ " elapsed=" ++ w8_tr_ms(t_start, tf1)),
      u => IO.pure(Unit, Unit{}))
    ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, P134Private{rest, ctx, next}, avail, b2, n2, pub_n, total_segs)

@unsafe
def ts_emit_pub(+thresh: Nat, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: N111Segment, rest: List<&2, N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +n2 : U32 = U32.inc(pub_n)
    +sname : String = ts_pub_name(head)
    _ : Unit <- ts_log_enter(thresh, "x187_pub", n2, sname)
    +tf0 : Nat <- IO.now()
    +b2 : X187Build <- IO.pure(X187Build, nt_choose(X187Build, fast,
      u => w13c_pub_emit_fast(head, ctx, avail, build),
      u => w10f_output_fn(nt_choose(X181Output, is_mod,
        v => w11_program_public_mod(head, ctx, avail, weak_set),
        v => x181_program_public(head, ctx, avail)), build)))
    +tf1 : Nat <- IO.now()
    _ : Unit <- ts_log_slow(thresh, "x187_pub", sname, tf0, tf1)
    _ : Unit <- nt_choose(IO(Unit), U32.is_eq(U32.mod(n2, 2000), 0),
      u => w8_tr_log(True{}, "stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start, tf1)),
      u => IO.pure(Unit, Unit{}))
    ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, P134Public{rest, ctx, next}, avail, b2, priv_n, n2, total_segs)

@unsafe
def ts_emit_good(+thresh: Nat, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{}, ctx, next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(True{}, "stage=x187_priv_done count=" ++ U32.show(priv_n) ++ " elapsed=" ++ w8_tr_ms(t_start, tn))
        ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, next, avail, build, priv_n, pub_n, total_segs)
    case P134Private{Con{head, rest}, ctx, next}:
      ts_emit_priv(thresh, fast, is_mod, weak_set, t_start, head, rest, ctx, next, avail, build, priv_n, pub_n, total_segs)
    case P134Legacy{es, ctx, next}:
      ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, next, avail, build, priv_n, pub_n, total_segs)
    case P134Public{Nil{}, ctx, next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(True{}, "stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start, tn))
        ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, next, avail, build, priv_n, pub_n, total_segs)
    case P134Public{Con{head, rest}, ctx, next}:
      ts_emit_pub(thresh, fast, is_mod, weak_set, t_start, head, rest, ctx, next, avail, build, priv_n, pub_n, total_segs)
    case P134Tables{Nil{}}:
      ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, P134Main{}, avail, build, priv_n, pub_n, total_segs)
    case P134Tables{Con{head, rest}}:
      ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, P134Tables{rest}, avail, x187_output(x181_program_data(head, avail), build), priv_n, pub_n, total_segs)
    case P134Main{}:
      do IO<U32>:
        +t_elf0 : Nat <- IO.now()
        +rc : U32 <- nt_choose(IO(U32), is_mod,
          u => w10_x202p_x201f_finish(build, weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(), build)))
        +t_elf1 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(True{}, "stage=x187_elf ms=" ++ w8_tr_ms(t_elf0, t_elf1) ++ " total_ms=" ++ w8_tr_ms(t_start, t_elf1))
        IO.pure(U32, rc)
    case _: IO.die(U32, 1, "incomplete object cursor")

@unsafe
def ts_emit_cursor(thresh, fast, is_mod, weak_set, t_start, cursor, avail, build, priv_n, pub_n, total_segs):
  nt_choose(IO(U32), String.is_empty(x187_build_message(build)),
    u => ts_emit_good(thresh, fast, is_mod, weak_set, t_start, cursor, avail, build, priv_n, pub_n, total_segs),
    u => IO.die(U32, 1, x187_build_message(build)))

@unsafe
def ts_run_prepared(+thresh: Nat, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, compiled: W10TrCompiled) -> IO(U32):
  match compiled:
    case W10TrCompiled{P169Prepared{fw, +cursor, +error}, +weak_set}:
      nt_choose(IO(U32), String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor, missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32), is_mod && U32.is_gt(U32.add(fid_base, segs), 65532),
            v => IO.die(U32, 1, "x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = nt_choose(P134Cursor, fast, w => cursor,
                w => nt_choose(P134Cursor, is_mod, z => w11_enrich_cursor_mod(cursor, avail, weak_set), z => agy_enrich_cursor(cursor, avail)))
              +cur2 : P134Cursor = nt_choose(P134Cursor, is_mod, w => w8_relocate_cursor(enr, fid_base, mod_name), w => enr)
              ts_emit_cursor(thresh, fast, is_mod, weak_set, t0, cur2, avail, x187_build_empty(), 0, 0, segs)),
        u => IO.die(U32, 1, error))

@unsafe
def ts_run_obj(+thresh: Nat, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(True{}, "start src=" ++ path ++ " slow_ms=" ++ Nat.show(thresh) ++ nt_choose(String, is_mod, u => nt_choose(String, fast, v => " mode=x86-module-fast mod=", v => " mode=x86-module mod=") ++ mod_name ++ " fid_base=" ++ U32.show(fid_base), u => nt_choose(String, fast, v => " mode=x86-object-fast", v => " mode=x86-object")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String), cached, u => p86_read_file(carrier_path), u => IO.pure(String, ""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(True{}, "stage=read ms=" ++ w8_tr_ms(t0, t_rd))
    +compiled : W10TrCompiled <- ts_compile(thresh, fast, is_mod, path, source, base_path, base, carrier, stamp, cached)
    ts_run_prepared(thresh, fast, is_mod, fid_base, mod_name, t0, compiled)

@unsafe
def ts_mod_fid(+thresh: Nat, fid_m: Maybe<&2, U32>, +fast: Bool, +mod_name: String, +path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: ts_run_obj(thresh, fast, True{}, fb, mod_name, path, base, carrier, stamp, cached)
    case _: IO.die(U32, 2, "expected U32 fid_base argument")

@unsafe
def ts_entry(+thresh: Nat, +args: List<&1, String>) -> IO(U32):
  match args:
    case Con{+program, Con{+path, Con{+base, Con{+mode, Con{+carrier, Con{+stamp, Nil{}}}}}}}:
      nt_choose(IO(U32), (agy_str_eq(program, "x86-object") || agy_str_eq(program, "x86-object-fast")) && String.starts_with(path, "/") &&
        String.starts_with(base, "/") &&
        (agy_str_eq(mode, "live") || (agy_str_eq(mode, "cache") && String.starts_with(carrier, "/"))),
        u => ts_run_obj(thresh, agy_str_eq(program, "x86-object-fast"), False{}, 0, "", path, base, carrier, stamp, agy_str_eq(mode, "cache")),
        u => x181_entry_args(args))
    case Con{+program, Con{+path, Con{+base, Con{+mode, Con{+carrier, Con{+stamp, Con{+fid_s, Con{+mod_name, Nil{}}}}}}}}}:
      nt_choose(IO(U32), (agy_str_eq(program, "x86-module") || agy_str_eq(program, "x86-module-fast")) && String.starts_with(path, "/") &&
        String.starts_with(base, "/") &&
        (agy_str_eq(mode, "live") || (agy_str_eq(mode, "cache") && String.starts_with(carrier, "/"))),
        u => ts_mod_fid(thresh, U32.read(fid_s), agy_str_eq(program, "x86-module-fast"), mod_name, path, base, carrier, stamp, agy_str_eq(mode, "cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)

@unsafe
def ts_parse_thresh_m(m: Maybe<&2, Nat>, +rest: List<&1, String>) -> IO(U32):
  match m:
    case Some{+thresh}: ts_entry(thresh, rest)
    case _: IO.die(U32, 2, "expected Nat threshold after --trace-slow")

@unsafe
def ts_parse_thresh(args: List<&1, String>) -> IO(U32):
  match args:
    case Con{+ms_s, +rest}: ts_parse_thresh_m(Nat.read(ms_s), rest)
    case _: IO.die(U32, 2, "expected <ms> after --trace-slow")

@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace-slow"),
        u => ts_parse_thresh(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"--trace"),
          v => w8_tr_entry(rest),
          v => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
            w => w10_merge_entry(rest),
            w => x181_entry_args(Con{head,rest}))))
    case Nil{}: x181_entry_args(Nil{})

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    w8_dispatch_args(List.tail(&1,String,args))

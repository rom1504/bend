
# Module: src/load/graph.bend:4
type FGraph is Data:
  FGraph{+book: List<&2, KDef>, +error: String, +done: List<&2, KTerm>}

# Module: src/load/imports.bend:3
law f_path_parts:
  for +s: String
  for +part: String
  for +parts: List<&2,String>
  for +abs: Bool
  String

# Module: src/load/graph.bend:14
law f_path_push:
  for +part: String
  for +parts: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:19
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
law f_graph_load:
  for +path: String
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

# Module: src/load/graph.bend:54
law f_graph_error:
  for +g: FGraph
  for +err: String
  FGraph

# Module: src/load/graph.bend:59
law f_graph_aliases:
  for +imports: List<&2, KTerm>
  for +source: FSource
  for +sources: List<&2,FSource>
  for +root: String
  List<&2, KTerm>

# Module: src/load/graph.bend:66
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

# Module: src/load/graph.bend:227
law f_graph_trace:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  FLoadTrace

# Module: src/load/graph.bend:231
law f_graph_count_defs:
  for +book: List<&2,KDef>
  for +count: U32
  U32

# Module: src/load/graph.bend:282
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
law fpe_term:
  for +t: KTerm
  KTerm

# Module: src/load/graph.bend:301
law fpe_defs:
  for +ds: List<&2,KDef>
  KTerm

# Module: src/load/graph.bend:305
law fpe_terms:
  for +ts: List<&2,KTerm>
  KTerm

# Module: src/load/graph.bend:308
law fpe_terms_next:
  for +error: KTerm
  for +rest: List<&2,KTerm>
  KTerm

# Module: src/load/graph.bend:312
law fpe_defs_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  KTerm

# Module: src/load/graph.bend:316
law fpe_find:
  for +ds: List<&2,KDef>
  for +index: U32
  KTerm

# Module: src/load/graph.bend:320
law fpe_find_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  for +index: U32
  KTerm

# Module: src/load/graph.bend:325
law fpe_selected:
  for +legacy: String
  for +owner: KTerm
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  String

# Module: src/load/graph.bend:331
law fpe_owner_path:
  for +done: List<&2,KTerm>
  for +index: U32
  String

# Module: src/load/graph.bend:335
law fpe_unique_source:
  for +path: String
  for +sources: List<&2,FSource>
  for +found: KTerm
  KTerm

# Module: src/load/graph.bend:340
law fpe_source_render:
  for +legacy: String
  for +error: KTerm
  for +source: KTerm
  String

# Module: src/load/graph.bend:89
@unsafe
def f_path_normal(
  +s: String,
) -> String:
  f_path_parts(s, "", Nil{}, Char.is_eq(f_head(s), '/'))

# Module: src/load/graph.bend:95
@unsafe
def f_path_parts(s, part, parts, abs):
  f_choose(String, String.is_empty(s), u => f_path_join_parts(List.reverse(&2, String, f_path_push(part, parts)), f_choose(String, abs, u => "/", u => "")), u => f_choose(String, Char.is_eq(f_head(s), '/'), u => f_path_parts(f_tail(s), "", f_path_push(part, parts), abs), u => f_path_parts(f_tail(s), part ++ SCon{f_head(s), ""}, parts, abs)))

# Module: src/load/graph.bend:99
@unsafe
def f_path_push(part, parts):
  f_choose(List<&2,String>, String.is_empty(part) || f_eq(part, "."), u => parts, u => f_choose(List<&2,String>, f_eq(part, ".."), u => f_path_parent(parts), u => Con{part, parts}))

# Module: src/load/graph.bend:103
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
def f_drop_chars(
  +s: String,
  +n: U32,
) -> String:
  f_choose(String, U32.is_eq(n, 0), u => s, u => f_drop_chars(f_tail(s), U32.sub(n, 1)))

# Module: src/load/graph.bend:126
@unsafe
def f_strip_bend(
  +s: String,
) -> String:
  String.reverse(f_drop_chars(String.reverse(s), 5))

# Module: src/load/graph.bend:132
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
def f_load_graph(
  +main: String,
  +sources: List<&2,FSource>,
) -> FResult:
  f_graph_result_at(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}), sources)

# Module: src/load/graph.bend:150
@unsafe
def f_graph_result(
  +g: FGraph,
) -> FResult:
  match g:
    case FGraph{book, err, done}:
      f_fresh_result(f_graph_fresh_result(f_validate_result(FResult{book, err, Nil{}})))

# Module: src/load/graph.bend:158
@unsafe
def f_graph_load(path, ns, sources, g, stack):
  # fs_source rejects empty source paths before this disabled seed can match.
  fs_load(path, ns, sources, g, stack, FSeed{"", Nil{}, f_path_dir(f_source_path(f_graph_source(path, sources)))})

# Module: src/load/graph.bend:163
@unsafe
def f_graph_error(g, err):
  match g:
    case FGraph{book, old, done}:
      FGraph{book, err, done}

# Module: src/load/graph.bend:169
@unsafe
def f_import_pathname(
  +im: KTerm,
  +s: FSource,
  +sources: List<&2,FSource>,
) -> String:
  f_choose(String, f_eq(nm(im), "Base"), u => f_source_path(f_source("Base", sources)), u => f_path_normal(f_path_join(f_path_dir(f_source_path(s)), nm(im))))

# Module: src/load/graph.bend:177
@unsafe
def f_graph_aliases(imports, source, sources, root):
  match imports:
    case Nil{}:
      Nil{}
    case Con{+im, rest}:
      Con{kt("Import", f_import_namespace_at(im, source, sources, root), 0, 0, ks(im)), f_graph_aliases(rest, source, sources, root)}

# Alias ambiguity uses the loaded declaration scope before rewriting names.

# Module: src/load/graph.bend:186
@unsafe
def f_alias_named(+t: KTerm, +imports: List<&2,KTerm>, +scope: List<&2,KDef>, +name: String) -> KTerm:
  kc(KTerm, core_literal(t), u => t, u =>
    f_choose(KTerm, f_choose(Bool, p88_string_eq(name, nm(t)), u => False{}, u => f_declared(name, scope) && f_declared(nm(t), scope)),
    u => fpe_point_at(k_with_span(t, ke(t), ke(t)), "expected an unambiguous name (an import alias shadows " ++ nm(t) ++ ")", "an unambiguous name (the alias " ++ f_import_alias_head(nm(t)) ++ " shadows " ++ nm(t) ++ ")"),
    u => k_rebuild(t, name, ix(t), qt(t), ks(t), rm(t), kb(t), ke(t))))

# Module: src/load/graph.bend:193
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
def f_graph_module_error(+source: FSource, +error: KTerm, +sources: List<&2,FSource>, +fallback: String) -> String:
  f_choose(String, f_eq(tg(error), "Absent"), u => fallback, u => fpe_source_render(nm(error), error, f_choose(KTerm, U32.is_gt(kb(error), 0), u => fpe_located_source(error, sources), u => kt("ParseSource", f_source_text(source), 0, 0, Nil{}))))


# Request-local trace of the exact graph that produced the freshened core.
# Loaded.id records declaration-event count, including separate law/fill events.

# Module: src/load/graph.bend:237
@unsafe
def f_load_graph_trace(
  +main: String,
  +sources: List<&2,FSource>,
) -> FLoadTrace:
  f_graph_trace(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}), sources)

# Module: src/load/graph.bend:243
@unsafe
def f_graph_trace(graph, sources):
  match graph:
    case FGraph{book, error, done}:
      FLoadTrace{f_graph_result_at(graph, sources), done, sources}

# Module: src/load/graph.bend:248
@unsafe
def f_graph_count_defs(book, count):
  match book:
    case Nil{}: count
    case Con{head, tail}: f_graph_count_defs(tail, U32.add(count, 1))

# Module: src/load/graph.bend:254
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
def f_graph_fresh_name(
  +rest: List<&2,KDef>,
  +done: KDef,
  +d: KDef,
  +hash: U32,
  +old: KDef,
) -> String:
  f_choose(String, f_eq(dk(old), "Absent") || (f_eq(dk(old), "Def") && f_eq(dk(d), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(f_eq(tg(dv(d)), "Absent")) && (Bool.not(db(old)) || db(d))), u => f_graph_fresh_names(rest, index_set(done, d, hash, 32)), u => "expected a fresh name (duplicate declaration: " ++ dn(d) ++ ")")

# Module: src/load/graph.bend:278
@unsafe
def f_graph_fresh_hashed(rest, done, d, hash):
  f_graph_fresh_name(rest, done, d, hash, index_find(done, dn(d), hash, 32))

# Refine only the error already selected by graph validation. Success is O(1).

# Module: src/load/graph.bend:347
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
def fpe_term(t):
  f_choose(KTerm, f_eq(tg(t), "Error"), u => f_choose(KTerm, String.is_empty(nm(t)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => t), u => f_choose(KTerm, f_eq(tg(t), "ImportLaw"), u => kt("Error", "imported law fills require the canonical graph loader", 0, 0, Nil{}), u => fpe_terms(ks(t))))

# Module: src/load/graph.bend:365
@unsafe
def fpe_terms(ts):
  match ts:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_terms_next(fpe_term(head), tail)

# Module: src/load/graph.bend:370
@unsafe
def fpe_terms_next(error, rest):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_terms(rest), u => error)

# Module: src/load/graph.bend:373
@unsafe
def fpe_def(
  +d: KDef,
) -> KTerm:
  fpe_defs_next(fpe_terms([dt(d), dv(d)]), dc(d))

# Module: src/load/graph.bend:378
@unsafe
def fpe_defs(ds):
  match ds:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_defs_next(fpe_def(head), tail)

# Module: src/load/graph.bend:383
@unsafe
def fpe_defs_next(error, rest):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_defs(rest), u => error)

# Module: src/load/graph.bend:386
@unsafe
def fpe_find(ds, index):
  match ds:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_find_next(fpe_def(head), tail, index)

# Module: src/load/graph.bend:391
@unsafe
def fpe_find_next(error, rest, index):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_find(rest, U32.add(index, 1)), u => kt("ParseOwner", "", index, 0, [error]))

# Module: src/load/graph.bend:394
@unsafe
def fpe_selected(legacy, owner, done, sources):
  f_choose(String, f_eq(tg(owner), "ParseOwner") && p88_string_eq(nm(kid(owner, 0)), legacy), u => fpe_source_render(legacy, kid(owner, 0), f_choose(KTerm, U32.is_gt(kb(kid(owner, 0)), 0), u => fpe_located_source(kid(owner, 0), sources), u => fpe_unique_source(fpe_owner_path(List.reverse(&2, KTerm, done), ix(owner)), sources, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))), u => legacy)

# Module: src/load/graph.bend:397
@unsafe
def fpe_owner_path(done, index):
  match done:
    case Nil{}: ""
    case Con{head, tail}:
      f_choose(String, U32.is_lt(index, ix(head)), u => nm(head), u => fpe_owner_path(tail, U32.sub(index, ix(head))))

# Module: src/load/graph.bend:403
@unsafe
def fpe_unique_source(path, sources, found):
  match sources:
    case Nil{}: found
    case Con{head, tail}:
      f_choose(KTerm, p88_string_eq(path, f_source_path(head)), u => f_choose(KTerm, f_eq(tg(found), "Absent"), u => fpe_unique_source(path, tail, kt("ParseSource", f_source_text(head), 0, 0, Nil{})), u => {KTerm{"Ambiguous", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => fpe_unique_source(path, tail, found))

# Module: src/load/graph.bend:409
@unsafe
def fpe_source_render(legacy, error, source):
  f_choose(String, f_eq(tg(source), "ParseSource"), u => f_choose(String, U32.is_gt(kb(source), 0), u => fpe_origin_render(nm(source), kb(source), error), u => fpe_render(nm(source), error)), u => legacy)

# Canonical module namespaces are relative to the entry's real directory.
# Reaching a file through another spelling therefore cannot create another name.

# Module: src/load/graph.bend:415
@unsafe
def f_relative_parts(+root: List<&2,String>, +file: List<&2,String>) -> String:
  match root file:
    case Con{r, rs} Con{f, fs}:
      f_choose(String, p88_string_eq(r, f), u => f_relative_parts(rs, fs), u => f_relative_parents(root) ++ f_path_join_parts(file, ""))
    case _ _:
      f_relative_parents(root) ++ f_path_join_parts(file, "")

# Module: src/load/graph.bend:423
@unsafe
def f_relative_parents(+root: List<&2,String>) -> String:
  match root:
    case Nil{}: ""
    case Con{part, rest}: "../" ++ f_relative_parents(rest)

# Module: src/load/graph.bend:429
@unsafe
def f_import_namespace_at(+im: KTerm, +source: FSource, +sources: List<&2,FSource>, +root: String) -> String:
  f_choose(String, f_eq(nm(im), "Base"), u => "", u => f_strip_bend(f_relative_parts(f_path_segments(f_path_normal(root)), f_path_segments(f_source_path(f_graph_source(f_import_pathname(im, source, sources), sources))))))

# Module: src/load/graph.bend:433
@unsafe
def f_path_segments(+path: String) -> List<&2,String>:
  f_path_nonempty(String.split(path, '/'))

# Module: src/load/graph.bend:437
@unsafe
def f_path_nonempty(parts: List<&2,String>) -> List<&2,String>:
  match parts:
    case Nil{}: Nil{}
    case Con{+part, +rest}:
      f_choose(List<&2,String>, String.is_empty(part), u => f_path_nonempty(rest), u => Con{part, f_path_nonempty(rest)})

# Imported fills retain telescope metadata until dependencies have loaded.
# The temporary kind protects the canonical law type/name from qualification;
# contextual module completion eliminates it before checker entry.

# Module: src/load/graph.bend:447
@unsafe
def f_graph_fill_defs(+defs: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      Con{f_graph_fill_alias(KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d), f_graph_fill_defs(dc(d), imports, scope), db(d), du(d)}, imports, scope), f_graph_fill_defs(rest, imports, scope)}

# Module: src/load/graph.bend:454
@unsafe
def f_graph_fill_alias(+d: KDef, +imports: List<&2,KTerm>, +scope: List<&2,KDef>) -> KDef:
  f_choose(KDef, f_eq(tg(dt(d)), "ImportLaw"), u => f_graph_fill(d, f_find(f_alias(dn(d), imports), List.reverse(&2, KDef, scope))), u => d)

# Module: src/load/graph.bend:458
@unsafe
def f_graph_fill(+d: KDef, +old: KDef) -> KDef:
  f_choose(KDef, f_eq(dk(old), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(db(old)) && f_bare_params(ks(dt(d))) && U32.is_ge(da(d), dx(old)) && (Bool.not(f_eq(tg(dv(d)), "Foreign")) || U32.is_eq(dx(old), 0)),
    u => KDef{dn(old), "ImportFill", da(d), dx(old), dt(old), dv(d), Nil{}, False{}, du(old) || du(d)},
    u => KDef{dn(d), "Def", da(d), dx(d), kt("Error", "an imported definition must uniquely fill a non-native law with plain parameter names", 0, 0, Nil{}), dv(d), dc(d), db(d), du(d)})

# The first selected frontend Error keeps its existing traversal order. Located
# errors resolve directly through source ownership, including imported aliases.

# Module: src/load/graph.bend:466
@unsafe
def fpe_located_source(+error: KTerm, +sources: List<&2,FSource>) -> KTerm:
  match sources:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, rest}:
      f_choose(KTerm, U32.is_gt(f_source_begin(head), 0) && U32.is_ge(kb(error), f_source_begin(head)) && U32.is_ge(ke(error), kb(error)) && U32.is_lt(ke(error), f_source_end(head)),
        u => kt_span("ParseSource", f_source_text(head), 0, 0, Nil{}, f_source_begin(head), f_source_end(head)),
        u => fpe_located_source(error, rest))

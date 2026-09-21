# Canonical file identity is separate from each importing module's aliases.
# The host supplies lexical paths and canonical paths; all graph and namespace
# decisions, including namespace conflicts and cycles, are implemented here.
type FGraph is Data:
  FGraph{+book: List<&2, KDef>, +error: String, +done: List<&2, KTerm>}

law f_path_normal:
  for +s: String
  String

law f_path_parts:
  for +s: String
  for +part: String
  for +parts: List<&2,String>
  for +abs: Bool
  String

law f_path_push:
  for +part: String
  for +parts: List<&2,String>
  List<&2,String>

law f_path_parent:
  for +parts: List<&2,String>
  List<&2,String>

law f_path_join_parts:
  for +parts: List<&2,String>
  for +acc: String
  String

law f_drop_chars:
  for +s: String
  for +n: U32
  String

law f_strip_bend:
  for +s: String
  String

law f_graph_source:
  for +path: String
  for +sources: List<&2,FSource>
  FSource

law f_load_graph:
  for +main: String
  for +sources: List<&2,FSource>
  FResult

law f_graph_result:
  for +g: FGraph
  FResult

law f_graph_load:
  for +path: String
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

law f_graph_source_load:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

law f_graph_cached:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  for +entry: KTerm
  FGraph

law f_graph_error:
  for +g: FGraph
  for +err: String
  FGraph

law f_graph_parsed:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  for +r: FResult
  FGraph

law f_import_namespace:
  for +im: KTerm
  for +ns: String
  String

law f_import_pathname:
  for +im: KTerm
  for +s: FSource
  for +sources: List<&2,FSource>
  String

law f_graph_imports:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +allimports: List<&2, KTerm>
  for +imports: List<&2, KTerm>
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

law f_graph_aliases:
  for +imports: List<&2, KTerm>
  for +ns: String
  List<&2, KTerm>

law f_alias_term:
  for +t: KTerm
  for +imports: List<&2, KTerm>
  KTerm

law f_alias_terms:
  for +ts: List<&2, KTerm>
  for +imports: List<&2, KTerm>
  List<&2, KTerm>

law f_alias_defs:
  for +ds: List<&2,KDef>
  for +imports: List<&2, KTerm>
  List<&2,KDef>

law f_graph_finish:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +g: FGraph
  FGraph

law f_graph_finish_alias:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +prior: List<&2,KDef>
  for +err: String
  for +done: List<&2, KTerm>
  FGraph

@unsafe
def f_path_normal(s):
  f_path_parts(s, "", Nil{}, Char.is_eq(f_head(s), '/'))

@unsafe
def f_path_parts(s, part, parts, abs):
  f_choose(String, String.is_empty(s), u => f_path_join_parts(List.reverse(&2, String, f_path_push(part, parts)), f_choose(String, abs, u => "/", u => "")), u => f_choose(String, Char.is_eq(f_head(s), '/'), u => f_path_parts(f_tail(s), "", f_path_push(part, parts), abs), u => f_path_parts(f_tail(s), part ++ SCon{f_head(s), ""}, parts, abs)))

@unsafe
def f_path_push(part, parts):
  f_choose(List<&2,String>, String.is_empty(part) || f_eq(part, "."), u => parts, u => f_choose(List<&2,String>, f_eq(part, ".."), u => f_path_parent(parts), u => Con{part, parts}))

@unsafe
def f_path_parent(parts):
  match parts:
    case Nil{}:
      [".."]
    case Con{+p, rest}:
      f_choose(List<&2,String>, f_eq(p, ".."), u => Con{"..", Con{p, rest}}, u => rest)

@unsafe
def f_path_join_parts(parts, acc):
  match parts:
    case Nil{}:
      acc
    case Con{part, rest}:
      f_path_join_parts(rest, acc ++ f_choose(String, String.is_empty(acc) || f_eq(acc, "/"), u => "", u => "/") ++ part)

@unsafe
def f_drop_chars(s, n):
  f_choose(String, U32.is_eq(n, 0), u => s, u => f_drop_chars(f_tail(s), U32.sub(n, 1)))

@unsafe
def f_strip_bend(s):
  String.reverse(f_drop_chars(String.reverse(s), 5))

@unsafe
def f_graph_source(path, sources):
  match sources:
    case Nil{}:
      FSource{"", "", ""}
    case Con{+s, rest}:
      f_choose(FSource, f_eq(path, f_source_name(s)) || f_eq(path, f_source_path(s)), u => s, u => f_graph_source(path, rest))

@unsafe
def f_load_graph(main, sources):
  f_graph_result(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}))

@unsafe
def f_graph_result(g):
  match g:
    case FGraph{book, err, done}:
      f_fresh_result(f_validate_result(FResult{book, err, Nil{}}))

@unsafe
def f_graph_load(path, ns, sources, g, stack):
  f_graph_source_load(f_graph_source(path, sources), ns, sources, g, stack)

@unsafe
def f_graph_source_load(s, ns, sources, g, stack):
  match g:
    case FGraph{book, +err, +done}:
      f_choose(FGraph, Bool.not(String.is_empty(err)), u => FGraph{book, err, done}, u => f_choose(FGraph, String.is_empty(f_source_path(s)), u => FGraph{book, "module source was not supplied", done}, u => f_choose(FGraph, has_name(stack, f_source_path(s)), u => FGraph{book, "cyclic import through " ++ f_source_path(s), done}, u => f_graph_cached(s, ns, sources, FGraph{book, err, done}, stack, f_env(f_source_path(s), done)))))

@unsafe
def f_graph_cached(s, ns, sources, g, stack, entry):
  f_choose(FGraph, f_eq(tg(entry), "Absent"), u => f_graph_parsed(s, ns, sources, g, Con{f_source_path(s), stack}, f_parse(f_source_text(s))), u => f_choose(FGraph, f_eq(nm(kid(entry, 0)), ns), u => g, u => f_graph_error(g, "one namespace per source file: " ++ f_source_path(s))))

@unsafe
def f_graph_error(g, err):
  match g:
    case FGraph{book, old, done}:
      FGraph{book, err, done}

@unsafe
def f_graph_parsed(s, ns, sources, g, stack, r):
  match r:
    case FResult{book, +err, imports}:
      f_choose(FGraph, String.is_empty(err), u => f_graph_imports(s, ns, book, imports, imports, sources, g, stack), u => f_graph_error(g, err))

@unsafe
def f_import_namespace(im, ns):
  f_choose(String, f_eq(nm(im), "Base"), u => "", u => f_strip_bend(f_path_normal(f_path_join(f_path_dir(ns), nm(im)))))

@unsafe
def f_import_pathname(im, s, sources):
  f_choose(String, f_eq(nm(im), "Base"), u => f_source_path(f_source("Base", sources)), u => f_path_normal(f_path_join(f_path_dir(f_source_path(s)), nm(im))))

@unsafe
def f_graph_imports(s, ns, book, allimports, imports, sources, g, stack):
  match imports:
    case Nil{}:
      f_graph_finish(s, ns, book, f_graph_aliases(allimports, ns), g)
    case Con{+im, rest}:
      f_graph_imports(s, ns, book, allimports, rest, sources, f_graph_load(f_import_pathname(im, s, sources), f_import_namespace(im, ns), sources, g, stack), stack)

@unsafe
def f_graph_aliases(imports, ns):
  match imports:
    case Nil{}:
      Nil{}
    case Con{+im, rest}:
      Con{kt("Import", f_import_namespace(im, ns), 0, 0, ks(im)), f_graph_aliases(rest, ns)}

@unsafe
def f_alias_term(t, imports):
  KTerm{tg(t), f_choose(String, f_eq(tg(t), "Ref") || f_eq(tg(t), "ADT") || f_eq(tg(t), "Ctr") || f_eq(tg(t), "Mat"), u => f_alias(nm(t), imports), u => nm(t)), ix(t), qt(t), f_alias_terms(ks(t), imports), rm(t)}

@unsafe
def f_alias_terms(ts, imports):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_alias_term(t, imports), f_alias_terms(rest, imports)}

@unsafe
def f_alias_defs(ds, imports):
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), f_alias_term(dt(d), imports), f_alias_term(dv(d), imports), f_alias_defs(dc(d), imports), db(d), du(d)}, f_alias_defs(rest, imports)}

@unsafe
def f_graph_finish(s, ns, book, imports, g):
  match g:
    case FGraph{prior, err, done}:
      f_graph_finish_alias(s, ns, f_alias_defs(book, imports), imports, prior, err, done)

@unsafe
def f_graph_finish_alias(s, ns, book, imports, prior, err, done):
  FGraph{f_defs_append(prior, f_path_defs(f_module_defs(book, Nil{}, f_family_book(prior), ns, imports), f_path_dir(f_source_path(s)), f_eq(f_source_name(s), "Base"))), err, Con{kt("Loaded", f_source_path(s), 0, 0, [ref(ns)]), done}}


law f_module_defs:
  for +todo: List<&2, KDef>
  for +visible: List<&2, KDef>
  for +scope: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

law f_module_def:
  for +d: KDef
  for +rest: List<&2, KDef>
  for +visible: List<&2, KDef>
  for +scope: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

@unsafe
def f_module_defs(todo, visible, scope, ns, imports):
  match todo:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      f_module_def(d, rest, Con{d, visible}, f_choose(List<&2,KDef>, f_eq(dk(d), "ADT") || U32.is_gt(dx(d), 0), u => Con{d, scope}, u => scope), ns, imports)

@unsafe
def f_module_def(d, rest, visible, scope, ns, imports):
  Con{f_choose(KDef, String.is_empty(ns), u => f_elab_def(d, scope), u => f_qual_def(f_elab_def(d, scope), visible, ns, imports)), f_module_defs(rest, visible, scope, ns, imports)}

# Reporting uses the main module's declaration events, excluding dependencies.
# Upstream appends to book.order only for def/type/law declarations; constructors
# remain nested and lowering introduces terms rather than declaration events.
# Thus this source selection exactly recovers order.slice(n0), without rerunning
# imported modules or changing FResult's stable ABI. Call after a successful load.
law f_main_names:
  for +main: String
  for +sources: List<&2,FSource>
  List<&2,String>

law f_main_result_names:
  for +r: FResult
  List<&2,String>

law f_main_order:
  for +book: List<&2,KDef>
  for +seen: List<&2,String>
  List<&2,String>

law f_main_seen:
  for +name: String
  for +seen: List<&2,String>
  Bool

@unsafe
def f_main_names(main, sources):
  f_main_result_names(f_parse(f_source_text(f_graph_source(main, sources))))

@unsafe
def f_main_result_names(r):
  match r:
    case FResult{book, error, imports}:
      f_choose(List<&2,String>, String.is_empty(error), u => f_main_order(book, Nil{}), u => Nil{})

@unsafe
def f_main_order(book, seen):
  match book:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      f_choose(List<&2,String>, f_main_seen(dn(d), seen), u => f_main_order(rest, seen), u => Con{dn(d), f_main_order(rest, Con{dn(d), seen})})

@unsafe
def f_main_seen(name, seen):
  match seen:
    case Nil{}:
      False{}
    case Con{head, rest}:
      String.eq(name, head) || f_main_seen(name, rest)

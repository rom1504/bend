# Versioned native graph transport. No compiler syntax is parsed by the host.
type RapidGraphFields is Data:
  RapidGraphFields{+fields: List<&2, String>, +error: String}

type RapidGraphManifest is Data:
  RapidGraphManifest{+main: String, +modules: List<&2, KTerm>, +assets: List<&2, KTerm>, +error: String}

type RapidGraphRead is Data:
  RapidGraphRead{+text: String, +error: String}

type RapidGraphSources is Data:
  RapidGraphSources{+sources: List<&2, FSource>, +error: String}

type RapidGraphAssets is Data:
  RapidGraphAssets{+sources: List<&2, KTerm>, +error: String}

law rapid_graph_wire:
  for +text: String
  for +word: String
  for +fields: List<&2, String>
  for +width: U32
  for +count: U32
  RapidGraphFields

@unsafe
def rapid_graph_wire(text, word, fields, width, count):
  match text:
    case SNil{}:
      kc(RapidGraphFields, U32.is_eq(width, 0),
        u => RapidGraphFields{List.reverse(&2, String, fields), ""},
        u => RapidGraphFields{Nil{}, "unterminated graph transport field"})
    case SCon{+c, rest}:
      kc(RapidGraphFields, U32.is_gt(width, 8192) || U32.is_gt(count, 20000),
        u => RapidGraphFields{Nil{}, "graph transport limit exceeded"},
        u => kc(RapidGraphFields, U32.is_eq(Char.to_u32(c), 0),
          v => rapid_graph_wire(rest, "", Con{String.reverse(word), fields}, 0, U32.add(count, 1)),
          v => rapid_graph_wire(rest, SCon{c, word}, fields, U32.add(width, 1), count)))

law rapid_graph_bad:
  RapidGraphManifest

@unsafe
def rapid_graph_bad():
  RapidGraphManifest{"", Nil{}, Nil{}, "invalid graph transport records"}

law rapid_graph_records:
  for +main: String
  for +fields: List<&2, String>
  for +modules: List<&2, KTerm>
  for +assets: List<&2, KTerm>
  for +count: U32
  for +asset_id: U32
  RapidGraphManifest

@unsafe
def rapid_graph_records(main, fields, modules, assets, count, asset_id):
  kc(RapidGraphManifest, U32.is_gt(count, 4096),
    u => rapid_graph_bad(),
    u => rapid_graph_records_unchecked(main, fields, modules, assets, count, asset_id))

law rapid_graph_records_unchecked:
  for +main: String
  for +fields: List<&2, String>
  for +modules: List<&2, KTerm>
  for +assets: List<&2, KTerm>
  for +count: U32
  for +asset_id: U32
  RapidGraphManifest

@unsafe
def rapid_graph_records_unchecked(main, fields, modules, assets, count, asset_id):
  match fields:
    case Con{tag, Nil{}}:
      kc(RapidGraphManifest, String.eq(tag, "E"),
        v => RapidGraphManifest{main, List.reverse(&2, KTerm, modules), List.reverse(&2, KTerm, assets), ""},
        v => rapid_graph_bad())
    case Con{+tag, Con{+name, Con{+physical, rest}}}:
      kc(RapidGraphManifest, String.eq(tag, "S"),
        v => rapid_graph_record_source(main, name, physical, rest, modules, assets, count, asset_id),
        v => kc(RapidGraphManifest, String.eq(tag, "A") && String.starts_with(name, "/") && String.starts_with(physical, "/"),
          w => rapid_graph_records(main, rest, modules, Con{kt("Asset", name, asset_id, 0, [ref(physical)]), assets}, U32.add(count, 1), U32.add(asset_id, 1)),
          w => rapid_graph_bad()))
    case other: rapid_graph_bad()

law rapid_graph_header:
  for +result: RapidGraphFields
  RapidGraphManifest

@unsafe
def rapid_graph_header(result):
  match result:
    case RapidGraphFields{fields, +error}:
      kc(RapidGraphManifest, Bool.not(String.eq(error, "")),
        u => RapidGraphManifest{"", Nil{}, Nil{}, error},
        u => rapid_graph_header_fields(fields))

law rapid_graph_header_fields:
  for +fields: List<&2, String>
  RapidGraphManifest

@unsafe
def rapid_graph_header_fields(fields):
  match fields:
    case Con{version, Con{+main, rest}}:
      kc(RapidGraphManifest, String.eq(version, "BEND_GRAPH_1") && String.starts_with(main, "/"),
        v => rapid_graph_records(main, rest, Nil{}, Nil{}, 0, 0),
        v => rapid_graph_bad())
    case other: rapid_graph_bad()

law rapid_graph_parse:
  for +text: String
  RapidGraphManifest

@unsafe
def rapid_graph_parse(text):
  rapid_graph_header(rapid_graph_wire(text, "", Nil{}, 0, 0))

law rapid_graph_read_error:
  for +error: U32 & String
  RapidGraphRead

@unsafe
def rapid_graph_read_error(error):
  (code, message) = error
  RapidGraphRead{"", message}

law rapid_graph_read_eof:
  for pair: File & Result<&1, &1, U32 & String, String>
  for +text: String
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read_eof(pair, text):
  (file, result) = pair
  do IO<RapidGraphRead>:
    Unit <- File.close(file)
    IO.pure(RapidGraphRead, rapid_graph_eof_result(result, text))

law rapid_graph_read_more:
  for pair: File & Result<&1, &1, U32 & String, String>
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read_more(pair):
  (file, result) = pair
  match result:
    case Done{text}:
      do IO<RapidGraphRead>:
        tail : File & Result<&1, &1, U32 & String, String> <- File.read(file, 1)
        rapid_graph_read_eof(tail, text)
    case Fail{error}:
      do IO<RapidGraphRead>:
        Unit <- File.close(file)
        IO.pure(RapidGraphRead, rapid_graph_read_error(error))

law rapid_graph_read_sized:
  for pair: File & Result<&1, &1, U32 & String, U32>
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read_sized(pair):
  (file, result) = pair
  match result:
    case Done{+size}:
      rapid_graph_read_size_limit(file, size, U32.is_gt(size, 16777216))
    case Fail{error}:
      do IO<RapidGraphRead>:
        Unit <- File.close(file)
        IO.pure(RapidGraphRead, rapid_graph_read_error(error))

law rapid_graph_read_opened:
  for result: Result<&1, &1, U32 & String, File>
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read_opened(result):
  match result:
    case Done{file}:
      do IO<RapidGraphRead>:
        pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
        rapid_graph_read_sized(pair)
    case Fail{error}: IO.pure(RapidGraphRead, rapid_graph_read_error(error))

law rapid_graph_read:
  for +path: String
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read(path):
  do IO<RapidGraphRead>:
    result : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    rapid_graph_read_opened(result)

law rapid_graph_sources:
  for +modules: List<&2, KTerm>
  IO(RapidGraphSources)

@unsafe
def rapid_graph_sources(modules):
  match modules:
    case Nil{}: IO.pure(RapidGraphSources, RapidGraphSources{Nil{}, ""})
    case Con{+module, rest}:
      do IO<RapidGraphSources>:
        read : RapidGraphRead <- rapid_graph_read(nm(kid(module, 1)))
        rapid_graph_source_read(module, rest, read)

law rapid_graph_source_read:
  for +module: KTerm
  for +rest: List<&2, KTerm>
  for +read: RapidGraphRead
  IO(RapidGraphSources)

@unsafe
def rapid_graph_source_read(module, rest, read):
  match read:
    case RapidGraphRead{text, +error}:
      kc(IO(RapidGraphSources), Bool.not(String.eq(error, "")),
        u => IO.pure(RapidGraphSources, RapidGraphSources{Nil{}, error}),
        u => IO.bind(RapidGraphSources, RapidGraphSources, rapid_graph_sources(rest), tail => rapid_graph_source_cons(FSource{nm(module), nm(kid(module, 0)), text}, tail)))

law rapid_graph_source_cons:
  for +source: FSource
  for +tail: RapidGraphSources
  IO(RapidGraphSources)

@unsafe
def rapid_graph_source_cons(source, tail):
  match tail:
    case RapidGraphSources{sources, error}: IO.pure(RapidGraphSources, RapidGraphSources{Con{source, sources}, error})

law rapid_graph_assets:
  for +paths: List<&2, String>
  for +available: List<&2, KTerm>
  for +seen: List<&2, String>
  IO(RapidGraphAssets)

@unsafe
def rapid_graph_assets(paths, available, seen):
  match paths:
    case Nil{}: IO.pure(RapidGraphAssets, RapidGraphAssets{Nil{}, ""})
    case Con{+path, rest}:
      kc(IO(RapidGraphAssets), has_name(seen, path),
        u => rapid_graph_assets(rest, available, seen),
        u => rapid_graph_asset(path, rest, available, seen, rapid_graph_find_asset(path, available)))

law rapid_graph_asset:
  for +path: String
  for +rest: List<&2, String>
  for +available: List<&2, KTerm>
  for +seen: List<&2, String>
  for +asset: KTerm
  IO(RapidGraphAssets)

@unsafe
def rapid_graph_asset(path, rest, available, seen, asset):
  kc(IO(RapidGraphAssets), String.eq(tg(asset), "Absent"),
    u => IO.pure(RapidGraphAssets, RapidGraphAssets{Nil{}, "foreign JavaScript source was not supplied: " ++ path}),
    u => IO.bind(RapidGraphRead, RapidGraphAssets, rapid_graph_read(nm(kid(asset, 0))), read => rapid_graph_asset_read(path, rest, available, seen, ix(asset), read)))

law rapid_graph_asset_read:
  for +path: String
  for +rest: List<&2, String>
  for +available: List<&2, KTerm>
  for +seen: List<&2, String>
  for +id: U32
  for +read: RapidGraphRead
  IO(RapidGraphAssets)

@unsafe
def rapid_graph_asset_read(path, rest, available, seen, id, read):
  match read:
    case RapidGraphRead{text, +error}:
      kc(IO(RapidGraphAssets), Bool.not(String.eq(error, "")),
        u => IO.pure(RapidGraphAssets, RapidGraphAssets{Nil{}, "cannot read foreign JavaScript source " ++ path ++ ": " ++ error}),
        u => do IO<RapidGraphAssets>:
          Unit <- IO.print_err("asset_used=" ++ U32.show(id))
          tail : RapidGraphAssets <- rapid_graph_assets(rest, available, Con{path, seen})
          rapid_graph_asset_cons(kt("Source", path, 0, 0, [kt("Text", text, 0, 0, Nil{})]), tail))

law rapid_graph_asset_cons:
  for +source: KTerm
  for +tail: RapidGraphAssets
  IO(RapidGraphAssets)

@unsafe
def rapid_graph_asset_cons(source, tail):
  match tail:
    case RapidGraphAssets{sources, error}: IO.pure(RapidGraphAssets, RapidGraphAssets{Con{source, sources}, error})

law rapid_graph_plan:
  for +plan: RapidBundlePlan
  for +runtime: String
  for +library: Bool
  for +assets: List<&2, KTerm>
  IO(RapidBundleResult)

@unsafe
def rapid_graph_plan(plan, runtime, library, assets):
  match plan:
    case RapidBundleFailure{error, phase, checked}: IO.pure(RapidBundleResult, rapid_bundle_error(phase, checked, error))
    case RapidBundleReady{+context, +annotated}:
      do IO<RapidBundleResult>:
        read : RapidGraphAssets <- rapid_graph_assets(j_foreign_paths(annotated), assets, Nil{})
        rapid_graph_emit(RapidBundleReady{context, annotated}, runtime, library, read)

law rapid_graph_emit:
  for +plan: RapidBundlePlan
  for +runtime: String
  for +library: Bool
  for +read: RapidGraphAssets
  IO(RapidBundleResult)

@unsafe
def rapid_graph_emit(plan, runtime, library, read):
  match read:
    case RapidGraphAssets{sources, +error}:
      IO.pure(RapidBundleResult, kc(RapidBundleResult, String.eq(error, ""),
        u => rapid_bundle_finalize(plan, runtime, library, sources),
        u => rapid_bundle_error("compile", True{}, error)))

law rapid_graph_loaded:
  for +main: String
  for +loaded: RapidGraphSources
  for +runtime: String
  for +library: Bool
  for +assets: List<&2, KTerm>
  IO(RapidBundleResult)

@unsafe
def rapid_graph_loaded(main, loaded, runtime, library, assets):
  match loaded:
    case RapidGraphSources{sources, +error}:
      kc(IO(RapidBundleResult), String.eq(error, ""),
        u => rapid_graph_plan(rapid_bundle_loaded(f_load_graph(main, sources), runtime, library), runtime, library, assets),
        u => IO.pure(RapidBundleResult, rapid_bundle_error("load", False{}, error)))

law rapid_graph_manifest:
  for +manifest: RapidGraphManifest
  for +runtime: String
  for +library: Bool
  IO(RapidBundleResult)

@unsafe
def rapid_graph_manifest(manifest, runtime, library):
  match manifest:
    case RapidGraphManifest{main, modules, assets, +error}:
      kc(IO(RapidBundleResult), String.eq(error, ""),
        u => IO.bind(RapidGraphSources, RapidBundleResult, rapid_graph_sources(modules), sources => rapid_graph_loaded(main, sources, runtime, library, assets)),
        u => IO.pure(RapidBundleResult, rapid_bundle_error("load", False{}, error)))

law rapid_graph_inputs:
  for +manifest: RapidGraphRead
  for +runtime: RapidGraphRead
  for +library: Bool
  IO(RapidBundleResult)

@unsafe
def rapid_graph_inputs(manifest, runtime, library):
  match manifest:
    case RapidGraphRead{text, +error}:
      kc(IO(RapidBundleResult), String.eq(error, ""),
        u => rapid_graph_runtime(text, runtime, library),
        u => IO.pure(RapidBundleResult, rapid_bundle_error("load", False{}, error)))

law rapid_graph_runtime:
  for +text: String
  for +runtime: RapidGraphRead
  for +library: Bool
  IO(RapidBundleResult)

@unsafe
def rapid_graph_runtime(text, runtime, library):
  match runtime:
    case RapidGraphRead{runtime_text, +runtime_error}:
      kc(IO(RapidBundleResult), String.eq(runtime_error, ""),
        v => rapid_graph_manifest(rapid_graph_parse(text), runtime_text, library),
        v => IO.pure(RapidBundleResult, rapid_bundle_error("load", False{}, runtime_error)))

law rapid_graph_paths:
  for +manifest_path: String
  for +runtime_path: String
  for +output: String
  for +mode: String
  IO(U32)

@unsafe
def rapid_graph_paths(manifest_path, runtime_path, output, mode):
  kc(IO(U32), String.eq(mode, "program") || String.eq(mode, "library"),
    u => do IO<U32>:
      before : Nat <- IO.now()
      manifest : RapidGraphRead <- rapid_graph_read(manifest_path)
      runtime : RapidGraphRead <- rapid_graph_read(runtime_path)
      +result : RapidBundleResult <- rapid_graph_inputs(manifest, runtime, String.eq(mode, "library"))
      consumed : Nat = rapid_bundle_consumed(result)
      after : Nat <- IO.now()
      rapid_bundle_finish(result, output, Nat.sub(after, before), consumed),
    u => IO.die(U32, 2, "phase=load checked=False: graph mode must be program or library"))

law rapid_graph_find_asset:
  for +path: String
  for +available: List<&2, KTerm>
  KTerm

@unsafe
def rapid_graph_find_asset(path, available):
  rapid_graph_asset_resolve(f_path_normal(path), available, rapid_graph_asset_named(f_path_normal(path), available))

law rapid_graph_asset_named:
  for +path: String
  for available: List<&2, KTerm>
  KTerm

@unsafe
def rapid_graph_asset_named(path, available):
  match available:
    case Nil{}: kt("Absent", "", 0, 0, Nil{})
    case Con{+asset, rest}:
      kc(KTerm, String.eq(path, nm(asset)), u => asset, u => rapid_graph_asset_named(path, rest))

law rapid_graph_asset_physical:
  for +path: String
  for available: List<&2, KTerm>
  KTerm

@unsafe
def rapid_graph_asset_physical(path, available):
  match available:
    case Nil{}: kt("Absent", "", 0, 0, Nil{})
    case Con{+asset, rest}:
      kc(KTerm, String.eq(path, nm(kid(asset, 0))), u => asset, u => rapid_graph_asset_physical(path, rest))

law rapid_graph_asset_resolve:
  for +path: String
  for available: List<&2, KTerm>
  for +named: KTerm
  KTerm

@unsafe
def rapid_graph_asset_resolve(path, available, named):
  kc(KTerm, String.eq(tg(named), "Absent"), u => rapid_graph_asset_physical(path, available), u => named)

law rapid_graph_record_source:
  for +main: String
  for +name: String
  for +physical: String
  for +rest: List<&2, String>
  for +modules: List<&2, KTerm>
  for +assets: List<&2, KTerm>
  for +count: U32
  for +asset_id: U32
  RapidGraphManifest

@unsafe
def rapid_graph_record_source(main, name, physical, rest, modules, assets, count, asset_id):
  match rest:
    case Con{+snapshot, tail}:
      kc(RapidGraphManifest, (String.eq(name, "Base") || String.starts_with(name, "/")) && String.starts_with(physical, "/") && String.starts_with(snapshot, "/"),
        w => rapid_graph_records(main, tail, Con{kt("Source", name, 0, 0, [ref(physical), ref(snapshot)]), modules}, assets, U32.add(count, 1), asset_id),
        w => rapid_graph_bad())
    case other: rapid_graph_bad()

law rapid_graph_eof_result:
  for result: Result<&1, &1, U32 & String, String>
  for +text: String
  RapidGraphRead

@unsafe
def rapid_graph_eof_result(result, text):
  match result:
    case Done{tail}: kc(RapidGraphRead, String.eq(tail, ""), u => RapidGraphRead{text, ""}, u => RapidGraphRead{"", "file was not completely read"})
    case Fail{error}: rapid_graph_read_error(error)

law rapid_graph_read_size_limit:
  for file: File
  for size: U32
  for large: Bool
  IO(RapidGraphRead)

@unsafe
def rapid_graph_read_size_limit(file, size, large):
  match large:
    case True{}: IO.bind(Unit, RapidGraphRead, File.close(file), v => IO.pure(RapidGraphRead, RapidGraphRead{"", "file exceeds 16 MiB"}))
    case False{}: IO.bind(File & Result<&1, &1, U32 & String, String>, RapidGraphRead, File.read(file, size), rapid_graph_read_more)

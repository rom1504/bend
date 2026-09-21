# Closed-bundle experimental native host. Compiler algorithms remain Bend.
# Supply absolute canonical paths. This first driver accepts one main module and
# its optional Base import; other modules and external JS foreign files reject.
# No parsed/checker cache is used. Reads precede timing; writing follows timing.
# Assemble after compiler modules: main(INPUT, BASE, RUNTIME, OUTPUT, MODE).

type RapidBundleResult is Data:
  RapidBundleResult{+source: String, +error: String, +phase: String, checked: Bool}

law rapid_bundle_error:
  for +phase: String
  for checked: Bool
  for +error: String
  RapidBundleResult

law rapid_bundle_import_error:
  for imports: List<&2, KTerm>
  String

law rapid_bundle_has_base:
  for imports: List<&2, KTerm>
  Bool

law rapid_bundle_foreign_error:
  for paths: List<&2, String>
  String

law rapid_bundle_emit:
  for +context: List<&2, KDef>
  for +selected: List<&2, KDef>
  for +roots: List<&2, String>
  for +stops: List<&2, String>
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_annotate:
  for +context: List<&2, KDef>
  for +annotated: List<&2, KDef>
  for +roots: List<&2, String>
  for +stops: List<&2, String>
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_foreign:
  for +context: List<&2, KDef>
  for +annotated: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  for +error: String
  RapidBundleResult

law rapid_bundle_reach:
  for +context: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_entry:
  for +book: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_specialized:
  for +book: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_specialize:
  for +specialized: KSpecialized
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_todos:
  for +book: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  for +todos: U32
  RapidBundleResult

law rapid_bundle_owned:
  for +book: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  for +error: String
  RapidBundleResult

law rapid_bundle_checked:
  for +book: List<&2, KDef>
  for +runtime: String
  for +library: Bool
  for +error: String
  RapidBundleResult

law rapid_bundle_loaded:
  for loaded: FResult
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_base_parsed:
  for +input: String
  for +base_path: String
  for +text: String
  for +base_text: String
  for +runtime: String
  for +library: Bool
  for +main_parsed: FResult
  for +base_parsed: FResult
  RapidBundleResult

law rapid_bundle_main_parsed:
  for +input: String
  for +base_path: String
  for +text: String
  for +base_text: String
  for +runtime: String
  for +library: Bool
  for +parsed: FResult
  RapidBundleResult

law rapid_bundle_compile:
  for +input: String
  for +base_path: String
  for +text: String
  for +base_text: String
  for +runtime: String
  for +library: Bool
  RapidBundleResult

law rapid_bundle_read_close:
  for pair: File & Result<&1, &1, U32 & String, String>
  IO(String)

law rapid_bundle_read_more:
  for pair: File & Result<&1, &1, U32 & String, String>
  IO(String)

law rapid_bundle_read_eof:
  for pair: File & Result<&1, &1, U32 & String, String>
  for text: String
  IO(String)

law rapid_bundle_read_sized:
  for pair: File & Result<&1, &1, U32 & String, U32>
  IO(String)

law rapid_bundle_read_file:
  for path: String
  IO(String)

law rapid_bundle_write_close:
  for pair: File & Result<&1, &1, U32 & String, Unit>
  IO(Unit)

law rapid_bundle_write_file:
  for path: String
  for text: String
  IO(Unit)

law rapid_bundle_finish:
  for result: RapidBundleResult
  for output: String
  for elapsed: Nat
  for consumed: Nat
  IO(U32)

law rapid_bundle_consumed:
  for result: RapidBundleResult
  Nat

law rapid_bundle_timed:
  for +input: String
  for +base_path: String
  for text: String
  for base_text: String
  for runtime: String
  for output: String
  for library: Bool
  IO(U32)

law rapid_bundle_paths:
  for +input: String
  for +base_path: String
  for runtime_path: String
  for output: String
  for library: Bool
  IO(U32)

law rapid_bundle_cli:
  for args: List<&1, String>
  IO(U32)

law main:
  IO(U32)

@unsafe
def rapid_bundle_error(phase, checked, error):
  RapidBundleResult{"", error, phase, checked}

@unsafe
def rapid_bundle_import_error(imports):
  match imports:
    case Nil{}: ""
    case Con{+im, rest}:
      kc(String, String.eq(nm(im), "Base"),
        u => rapid_bundle_import_error(rest),
        u => "closed bundle supports only import Base; requested: " ++ nm(im))

@unsafe
def rapid_bundle_has_base(imports):
  match imports:
    case Nil{}: False{}
    case Con{im, rest}: String.eq(nm(im), "Base") || rapid_bundle_has_base(rest)

@unsafe
def rapid_bundle_foreign_error(paths):
  match paths:
    case Nil{}: ""
    case Con{path, rest}: "closed bundle does not supply foreign JavaScript source: " ++ path

@unsafe
def rapid_bundle_emit(context, selected, roots, stops, runtime, library):
  +error = j_foreign_error(selected)
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => rapid_bundle_annotate(context, annotate_selected(context, selected, stops), roots, stops, runtime, library))

@unsafe
def rapid_bundle_annotate(context, annotated, roots, stops, runtime, library):
  +error = j_layout_error(context, annotated, roots, stops)
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => rapid_bundle_foreign(context, annotated, runtime, library, rapid_bundle_foreign_error(j_foreign_paths(annotated))))

@unsafe
def rapid_bundle_foreign(context, annotated, runtime, library, error):
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => RapidBundleResult{runtime ++ "\n" ++ j_modules(annotated, Nil{}) ++ "\n" ++ kc(String, library, u => j_library_selected(context, annotated), u => j_program_selected(context, annotated)), "", "compile", True{}})

@unsafe
def rapid_bundle_reach(context, runtime, library):
  +roots = j_roots(context, library)
  +stops = j_stops(context)
  rapid_bundle_emit(context, reach_book(context, roots, stops), roots, stops, runtime, library)

@unsafe
def rapid_bundle_entry(book, runtime, library):
  +error = kc(String, library, u => "", u => j_compile_error(book))
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => rapid_bundle_reach(book_context(book), runtime, library))

@unsafe
def rapid_bundle_specialized(book, runtime, library):
  +error = driver_emit_owned(book)
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => rapid_bundle_entry(book, runtime, library))

@unsafe
def rapid_bundle_specialize(specialized, runtime, library):
  +error = specialized_error(specialized)
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("check", True{}, error),
    u => rapid_bundle_specialized(specialized_book(specialized), runtime, library))

@unsafe
def rapid_bundle_todos(book, runtime, library, todos):
  kc(RapidBundleResult, U32.is_eq(todos, 0),
    u => rapid_bundle_specialize(specialize_book(book), runtime, library),
    u => rapid_bundle_error("check", True{}, U32.show(todos) ++ " TODO" ++ kc(String, U32.is_eq(todos, 1), u => "", u => "s") ++ " found.\nThe code is incomplete, and not a valid proof yet."))

@unsafe
def rapid_bundle_owned(book, runtime, library, error):
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("compile", True{}, error),
    u => rapid_bundle_todos(book, runtime, library, driver_todos(book)))

@unsafe
def rapid_bundle_checked(book, runtime, library, error):
  kc(RapidBundleResult, Bool.not(String.eq(error, "")),
    u => rapid_bundle_error("check", True{}, error),
    u => rapid_bundle_owned(book, runtime, library, driver_owned(book)))

@unsafe
def rapid_bundle_loaded(loaded, runtime, library):
  match loaded:
    case FResult{+book, +error, imports}:
      kc(RapidBundleResult, Bool.not(String.eq(error, "")),
        u => rapid_bundle_error("parse", False{}, error),
        u => rapid_bundle_checked(book, runtime, library, check_book(book)))

@unsafe
def rapid_bundle_base_parsed(input, base_path, text, base_text, runtime, library, main_parsed, base_parsed):
  match base_parsed:
    case FResult{book, +error, +imports}:
      kc(RapidBundleResult, Bool.not(String.eq(error, "")),
        u => rapid_bundle_error("parse", False{}, error),
        u => kc(RapidBundleResult, Bool.not(String.eq(rapid_bundle_import_error(imports), "")),
          v => rapid_bundle_error("load", False{}, rapid_bundle_import_error(imports)),
          v => rapid_bundle_loaded(f_load_graph(input, [f_source_parsed(input, input, text, main_parsed), f_source_parsed("Base", base_path, base_text, base_parsed)]), runtime, library)))

@unsafe
def rapid_bundle_main_parsed(input, base_path, text, base_text, runtime, library, parsed):
  match parsed:
    case FResult{book, +error, +imports}:
      kc(RapidBundleResult, Bool.not(String.eq(error, "")),
        u => rapid_bundle_error("parse", False{}, error),
        u => kc(RapidBundleResult, Bool.not(String.eq(rapid_bundle_import_error(imports), "")),
          v => rapid_bundle_error("load", False{}, rapid_bundle_import_error(imports)),
          v => kc(RapidBundleResult, rapid_bundle_has_base(imports),
            w => rapid_bundle_base_parsed(input, base_path, text, base_text, runtime, library, parsed, f_parse(base_text)),
            w => rapid_bundle_loaded(f_load_graph(input, [f_source_parsed(input, input, text, parsed)]), runtime, library))))

@unsafe
def rapid_bundle_compile(input, base_path, text, base_text, runtime, library):
  rapid_bundle_main_parsed(input, base_path, text, base_text, runtime, library, f_parse(text))

# IO helpers close handles before propagating their read/write result.
@unsafe
def rapid_bundle_read_close(pair):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    IO.pass(String, result)

# Verify EOF after the sized read: a short read must not compile a prefix.
@unsafe
def rapid_bundle_read_eof(pair, text):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    tail : String <- IO.pass(String, result)
    kc(IO(String), String.eq(tail, ""),
      u => IO.pure(String, text),
      u => IO.die(String, 1, "closed bundle input was not completely read"))

@unsafe
def rapid_bundle_read_more(pair):
  (file, result) = pair
  match result:
    case Done{text}:
      do IO<String>:
        tail : File & Result<&1, &1, U32 & String, String> <- File.read(file, 1)
        rapid_bundle_read_eof(tail, text)
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def rapid_bundle_read_sized(pair):
  (file, result) = pair
  match result:
    case Done{size}:
      do IO<String>:
        read : File & Result<&1, &1, U32 & String, String> <- File.read(file, size)
        rapid_bundle_read_more(read)
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def rapid_bundle_read_file(path):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
    rapid_bundle_read_sized(pair)

@unsafe
def rapid_bundle_write_close(pair):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    IO.pass(Unit, result)

@unsafe
def rapid_bundle_write_file(path, text):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "w"))
    pair : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, text)
    rapid_bundle_write_close(pair)

@unsafe
def rapid_bundle_finish(result, output, elapsed, consumed):
  match result:
    case RapidBundleResult{source, +error, +phase, +checked}:
      do IO<U32>:
        Unit <- IO.print_err("compile_ms=" ++ Nat.show(elapsed))
        Unit <- IO.print_err("consumed_chars=" ++ Nat.show(consumed))
        kc(IO(U32), String.eq(error, ""),
          u => IO.bind(Unit, U32, rapid_bundle_write_file(output, source), v => IO.pure(U32, 0)),
          u => IO.die(U32, 1, "phase=" ++ phase ++ " checked=" ++ Bool.show(checked) ++ ": " ++ error))

# Consume every output/error character before the second clock so deferred
# construction cannot move work into file output after the timed pipeline.
@unsafe
def rapid_bundle_consumed(result):
  match result:
    case RapidBundleResult{source, error, phase, checked}:
      Nat.add(String.length(source), String.length(error))

@unsafe
def rapid_bundle_timed(input, base_path, text, base_text, runtime, output, library):
  do IO<U32>:
    before : Nat <- IO.now()
    +result : RapidBundleResult = rapid_bundle_compile(input, base_path, text, base_text, runtime, library)
    consumed : Nat = rapid_bundle_consumed(result)
    after : Nat <- IO.now()
    rapid_bundle_finish(result, output, Nat.sub(after, before), consumed)

@unsafe
def rapid_bundle_paths(input, base_path, runtime_path, output, library):
  do IO<U32>:
    text : String <- rapid_bundle_read_file(input)
    base_text : String <- rapid_bundle_read_file(base_path)
    runtime : String <- rapid_bundle_read_file(runtime_path)
    rapid_bundle_timed(input, base_path, text, base_text, runtime, output, library)

@unsafe
def rapid_bundle_cli(args):
  match args:
    case Con{+input, Con{+base_path, Con{+runtime_path, Con{+output, Con{+mode, Nil{}}}}}}:
      kc(IO(U32), (String.eq(mode, "program") || String.eq(mode, "library")) && String.starts_with(input, "/") && String.starts_with(base_path, "/") && String.starts_with(runtime_path, "/") && String.starts_with(output, "/"),
        u => rapid_bundle_paths(input, base_path, runtime_path, output, String.eq(mode, "library")),
        u => IO.die(U32, 2, "closed bundle requires absolute canonical paths and program or library mode"))
    case other:
      IO.die(U32, 2, "usage: native-bundle INPUT BASE RUNTIME OUTPUT program|library")

@unsafe
def main():
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    rapid_bundle_cli(args)

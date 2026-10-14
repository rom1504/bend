# Disposable Phase86 native-host entry. Assemble after the CURRENT manifest.
# Root freezes/audits Base, runtime and EFFECTDIR; only the three audited scalar
# Base effects are admitted. This is a prepared-session experiment, not a CLI.
# RUNTIME names the authenticated runtime whose five prepared sibling files
# RUNTIME.part0 .. RUNTIME.part4 are supplied by the root harness.
import Base

type P86Seed is Data:
  P86Seed{+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}

type P86Preparation is Data:
  P86PreparationError{+error: String}
  P86PreparationReady{+seed: P86Seed}

type P86Plan is Data:
  P86PlanError{+error: String}
  P86PlanReady{+request: NR_Request, +verdict: String}

type P86Result is Data:
  P86Result{+source: String, +error: String, +verdict: String}

# The ordinary host supplies JS UTF-16 lengths. This tail loop computes the
# same transport metadata in either execution backend, without dg_width's
# diagnostic-sized recursion on the entire75KiB Base source.
@unsafe
def p86_width(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{char, rest}: p86_width(rest, U32.add(count, dg_units(char)))

@unsafe
def p86_prepare(+path: String, +text: String) -> P86Preparation:
  +source = f_source_located(FSource{"Base", path, text}, 1, U32.add(p86_width(text, 0), 2))
  p86_prepare_loaded(source, f_load_graph("Base", [source]))

@unsafe
def p86_prepare_loaded(+source: FSource, loaded: FResult) -> P86Preparation:
  match loaded:
    case FResult{+book, +error, imports}:
      kc(P86Preparation, String.is_empty(error),
        u => p86_prepare_checked(source, book, check_book(book)),
        u => P86PreparationError{"base_parse: " ++ error})

@unsafe
def p86_prepare_checked(+source: FSource, +book: List<&2,KDef>, +error: String) -> P86Preparation:
  kc(P86Preparation, String.is_empty(error),
    u => p86_prepare_states(source, book, f_fresh_prefix_prepare(book), f_ready_prefix_prepare(book), base_prefix_world_prepare(book, base_prefix_prepare(book))),
    u => P86PreparationError{"base_check: " ++ error})

@unsafe
def p86_prepare_states(+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld) -> P86Preparation:
  match fresh ready world:
    case FFreshPrefixState{next, fresh_ok} FReadyPrefixState{names, ctors, count, ready_ok} KBasePreparedWorld{state, prefix, final, saved, checked, seen, todos, bound}:
      match state:
        case KBasePrefixState{base_bound, delta, stamp, patches, checked_ok}:
          kc(P86Preparation, fresh_ok && ready_ok && checked_ok,
            u => P86PreparationReady{P86Seed{source, book, fresh, ready, world}},
            u => P86PreparationError{"base_prepare: prefix preparation was not eligible"})

@unsafe
def p86_import_error(imports: List<&2,KTerm>, found: Bool) -> String:
  match imports:
    case Nil{}: kc(String, found, u => "", u => "pilot requires import Base")
    case Con{+im, rest}: kc(String, String.eq(nm(im), "Base"),
      u => p86_import_error(rest, True{}), u => "pilot rejects additional import: " ++ nm(im))

@unsafe
def p86_plan(+seed: P86Seed, +path: String, +text: String) -> P86Plan:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p86_plan_header(seed, source, f_source_header(source))

@unsafe
def p86_plan_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_imported(seed, source, header, p86_import_error(imports, False{})),
        u => P86PlanError{"parse: " ++ error})

@unsafe
def p86_plan_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_seed(seed, source, header), u => P86PlanError{"load: " ++ error})

@unsafe
def p86_plan_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P86Plan:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p86_plan_seeded(seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))

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

@unsafe
def p86_plan_completed(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p86_plan_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh))

@unsafe
def p86_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P86Plan, String.is_empty(error),
                u => p86_plan_checked(load, world, original, check_program_diagnostic_world(load, Nil{}, world)),
                u => P86PlanError{"parse: " ++ error})

@unsafe
def p86_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +original: List<&2,KDef>, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P86Plan, String.is_empty(error),
        u => p86_plan_reported(load, world, book, driver_report_data(original)),
        u => P86PlanError{"check: " ++ error})

@unsafe
def p86_plan_reported(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, report: DR_Report) -> P86Plan:
  match report:
    case DR_Report{+verdict, names}:
      p86_plan_owned(load, world, book, verdict, driver_emit_owned(book))

@unsafe
def p86_plan_owned(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_entry(load, world, book, verdict, j_compile_error(book)),
    u => P86PlanError{"compile: " ++ error})

@unsafe
def p86_plan_entry(+load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P86Plan:
  kc(P86Plan, String.is_empty(error),
    u => p86_plan_context(book_context_world(book, load, world), verdict),
    u => P86PlanError{"compile: " ++ error})

@unsafe
def p86_plan_context(+context: List<&2,KDef>, +verdict: String) -> P86Plan:
  +stops = nc_annotation_stops(context)
  p86_plan_annotated(context, stops, verdict, annotate_selected(context, reach_book(context, ["main"], stops), stops))

@unsafe
def p86_plan_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  +error = jl_checked_error(context, annotated, ["main"], stops)
  kc(P86Plan, String.is_empty(error),
    u => P86PlanReady{nr_prepare_annotated(context, annotated), verdict},
    u => P86PlanError{"compile: " ++ error})

# The root harness audits exact pinned Base and these three effect bytes before
# invocation. Arbitrary paths/foreign effects cannot acquire effectsSafe here.
@unsafe
def p86_effect_file(+base: String, +path: String) -> String:
  +dir = f_path_dir(base) ++ "effs/"
  +dot = f_path_dir(base) ++ "./effs/"
  kc(String, String.eq(path, dir ++ "args.c") || String.eq(path, dot ++ "args.c"), u => "args.c", u =>
    kc(String, String.eq(path, dir ++ "print.c") || String.eq(path, dot ++ "print.c"), u => "print.c", u =>
      kc(String, String.eq(path, dir ++ "now.c") || String.eq(path, dot ++ "now.c"), u => "now.c", u => "")))

@unsafe
def p86_effects(+request: NR_Request, +base: String, +directory: String, paths: List<&2,String>, +seen: List<&2,String>, +text: String) -> IO(String):
  match paths:
    case Nil{}: IO.pure(String, text)
    case Con{+path, +rest}:
      kc(IO(String), has_name(seen, path),
        u => p86_effects(request, base, directory, rest, seen, text),
        u => p86_effect_read(request, base, directory, path, rest, seen, text, p86_effect_file(base, path)))

@unsafe
def p86_effect_read(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +file: String) -> IO(String):
  kc(IO(String), String.is_empty(file),
    u => IO.die(String, 1, "compile: pilot rejects foreign path " ++ path),
    u => do IO<String>:
      source : String <- p86_read_file(directory ++ "/" ++ file)
      p86_effect_parsed(request, base, directory, path, rest, seen, text, source))

@unsafe
def p86_effect_parsed(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +source: String) -> IO(String):
  match request:
    case NR_Request{+book, erased, names, paths, +scope, bound}:
      p86_effect_checked(request, base, directory, path, rest, seen, text, source, kf_source(book, scope, path, source))

@unsafe
def p86_effect_checked(+request: NR_Request, +base: String, +directory: String, +path: String, +rest: List<&2,String>, +seen: List<&2,String>, +text: String, +source: String, +parsed: KF_Source) -> IO(String):
  match request parsed:
    case NR_Request{+book, erased, names, paths, +scope, bound} KF_Source{parts, +error}:
      kc(IO(String), String.is_empty(error),
        u => p86_effects(request, base, directory, rest, Con{path, seen}, text ++ kc(String, List.is_empty(&2, String, seen), v => "", v => "\n") ++ nc_foreign_source(book, scope, path, source, parsed)),
        u => IO.die(String, 1, "compile: " ++ error))

@unsafe
def p86_compile(plan: P86Plan, +runtime: NE_Runtime, +base: String, +directory: String) -> IO(P86Result):
  match plan:
    case P86PlanError{error}: IO.pure(P86Result, P86Result{"", error, ""})
    case P86PlanReady{+request, +verdict}:
      match request:
        case NR_Request{source, book, names, paths, scope, bound}:
          do IO<P86Result>:
            effects : String <- p86_effects(request, base, directory, paths, Nil{}, "")
            IO.pure(P86Result, p86_emitted(nr_compile_prepared(request, runtime, effects, True{}), verdict))

@unsafe
def p86_emitted(result: NC_Result, verdict: String) -> P86Result:
  match result:
    case NC_Result{source, error}: P86Result{source, error, verdict}

@unsafe
def p86_consumed(+result: P86Result) -> Nat:
  match result:
    case P86Result{source, error, verdict}: Nat.add(String.length(source), Nat.add(String.length(error), String.length(verdict)))

@unsafe
def p86_requests(+seed: P86Seed, +runtime: NE_Runtime, +input: String, +text: String, +base: String, +directory: String, +output: String, +left: U32, +call: U32) -> IO(U32):
  do IO<U32>:
    before : Nat <- IO.now()
    +result : P86Result <- p86_compile(p86_plan(seed, input, text), runtime, base, directory)
    consumed : Nat = p86_consumed(result)
    after : Nat <- IO.now()
    Unit <- IO.print_err("request=" ++ U32.show(call) ++ " request_ms=" ++ Nat.show(Nat.sub(after, before)) ++ " consumed_chars=" ++ Nat.show(consumed))
    p86_request_finished(seed, runtime, input, text, base, directory, output, left, call, result)

@unsafe
def p86_request_finished(+seed: P86Seed, +runtime: NE_Runtime, +input: String, +text: String, +base: String, +directory: String, +output: String, +left: U32, +call: U32, result: P86Result) -> IO(U32):
  match result:
    case P86Result{+source, +error, +verdict}:
      kc(IO(U32), String.is_empty(error),
        u => do IO<U32>:
          Unit <- p86_write_file(output ++ "." ++ U32.show(call) ++ ".c", source)
          kc(IO(U32), U32.is_eq(left, 1),
            v => do IO<U32>:
              Unit <- IO.print_err(verdict)
              IO.pure(U32, 0),
            v => p86_requests(seed, runtime, input, text, base, directory, output, U32.sub(left, 1), U32.add(call, 1))),
        u => IO.die(U32, 1, error))

@unsafe
def p86_runtime_prepared(+seed: P86Seed, +input: String, +text: String, +base: String, +directory: String, +output: String, +count: U32, +runtime: NE_Runtime, before: Nat) -> IO(U32):
  match runtime:
    case NE_Text{raw}: IO.die(U32, 1, "runtime_prepare: canonical template markers missing")
    case NE_Parts{parts}:
      do IO<U32>:
        after : Nat <- IO.now()
        Unit <- IO.print_err("runtime_prepare_ms=" ++ Nat.show(Nat.sub(after, before)))
        p86_requests(seed, runtime, input, text, base, directory, output, count, 1)

# The root verifies every part against the existing Bend-produced canonical
# template artifact and checks their concatenation against the raw runtime.
# This host transport replaces no compiler algorithm and rescans no template.
@unsafe
def p86_runtime_read(+path: String) -> IO(NE_Runtime):
  do IO<NE_Runtime>:
    part0 : String <- p86_read_file(path ++ ".part0")
    part1 : String <- p86_read_file(path ++ ".part1")
    part2 : String <- p86_read_file(path ++ ".part2")
    part3 : String <- p86_read_file(path ++ ".part3")
    part4 : String <- p86_read_file(path ++ ".part4")
    IO.pure(NE_Runtime, NE_Parts{[part0, part1, part2, part3, part4]})

@unsafe
def p86_base_prepared(+input: String, +text: String, +base: String, +runtime_path: String, +directory: String, +output: String, +count: U32, prepared: P86Preparation, before: Nat) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        after : Nat <- IO.now()
        Unit <- IO.print_err("base_prepare_ms=" ++ Nat.show(Nat.sub(after, before)))
        start : Nat <- IO.now()
        runtime : NE_Runtime <- p86_runtime_read(runtime_path)
        p86_runtime_prepared(seed, input, text, base, directory, output, count, runtime, start)

@unsafe
def p86_paths(+input: String, +base: String, runtime: String, +directory: String, +output: String, +count: U32) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    before : Nat <- IO.now()
    p86_base_prepared(input, text, base, runtime, directory, output, count, p86_prepare(base, base_text), before)

# Sized read plus EOF verification, adapted from the historical rapid host.
@unsafe
def p86_read_eof(pair: File & Result<&1,&1,U32 & String,String>, text: String) -> IO(String):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    tail : String <- IO.pass(String, result)
    kc(IO(String), String.is_empty(tail), u => IO.pure(String, text),
      u => IO.die(String, 1, "input was not completely read"))

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

@unsafe
def p86_read_sized(pair: File & Result<&1,&1,U32 & String,U32>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{+size}:
      p86_read_limit(file, size, U32.is_le(size, 16777216))
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def p86_read_limit(file: File, size: U32, allowed: Bool) -> IO(String):
  match allowed:
    case True{}:
      do IO<String>:
        read : File & Result<&1,&1,U32 & String,String> <- File.read(file, size)
        p86_read_more(read)
    case False{}:
      do IO<String>:
        Unit <- File.close(file)
        IO.die(String, 1, "input exceeds 16 MiB")

@unsafe
def p86_read_file(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1,&1,U32 & String,U32> <- File.size(file)
    p86_read_sized(pair)

@unsafe
def p86_write_close(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    IO.pass(Unit, result)

@unsafe
def p86_write_file(path: String, text: String) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "w"))
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file, text)
    p86_write_close(pair)

@unsafe
def p86_cli(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program, Con{+input, Con{+base, Con{+runtime, Con{+directory, Con{+output, Con{+count, Nil{}}}}}}}}:
      kc(IO(U32), String.starts_with(input, "/") && String.starts_with(base, "/") && String.starts_with(runtime, "/") && String.starts_with(directory, "/") && String.starts_with(output, "/") && (String.eq(count, "1") || String.eq(count, "5")),
        u => p86_paths(input, base, runtime, directory, output, kc(U32, String.eq(count, "1"), v => 1, v => 5)),
        u => IO.die(U32, 2, "expected absolute paths and COUNT 1 or 5"))
    case other: IO.die(U32, 2, "usage: compiler INPUT BASE RUNTIME EFFECTDIR OUTPUT COUNT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p86_cli(args)

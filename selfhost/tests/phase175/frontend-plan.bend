# Experimental frontend-only stage stops. Same maintained computations and error order.
# Request mode is independently compared with ordinary p86_plan; no backend is called.
type P175Frontend is Data:
  P175FError{+error: String}
  P175FBook{+stage: String, +book: List<&2,KDef>, +verdict: String}
  P175FRequest{+request: NR_Request, +verdict: String}


def p175fp_ordinary(plan: P86Plan) -> P175Frontend:
  match plan:
    case P86PlanError{error}: P175FError{error}
    case P86PlanReady{request,verdict}: P175FRequest{request,verdict}

@unsafe
def p175fp_annotation_result(annotated: List<&2,KDef>, verdict: String, +error: String) -> P175Frontend:
  kc(P175Frontend,String.is_empty(error),
    u => P175FBook{"annotation",annotated,verdict},
    u => P175FError{"compile: " ++ error})

# The complete request delegates to the original boundary exactly once, so
# explicit candidate replacements of p86_plan_annotated remain under test.
@unsafe
def p175fp_annotated(+mode: String, +context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P175Frontend:
  nt_choose(P175Frontend,String.eq(mode,"annotation"),
    u => p175fp_annotation_result(annotated,verdict,jl_checked_error(context,annotated,["main"],stops)),
    u => p175fp_ordinary(p86_plan_annotated(context,stops,verdict,annotated)))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:550
@unsafe
def p175fp_context(+mode: String, +context: List<&2,KDef>, +verdict: String) -> P175Frontend:
  nt_choose(P175Frontend,String.eq(mode,"context"),
    u => P175FBook{"context",context,verdict}, u =>
      +stops = nc_annotation_stops(context)
      p175fp_annotated(mode, context, stops, verdict, annotate_selected(context, reach_book(context, ["main"], stops), stops)))


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:544
@unsafe
def p175fp_entry(+mode: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P175Frontend:
  kc(P175Frontend, String.is_empty(error),
    u => p175fp_context(mode, book_context_world(book, load, world), verdict),
    u => P175FError{"compile: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:538
@unsafe
def p175fp_owned(+mode: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, +verdict: String, +error: String) -> P175Frontend:
  kc(P175Frontend, String.is_empty(error),
    u => p175fp_entry(mode, load, world, book, verdict, j_compile_error(book)),
    u => P175FError{"compile: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:532
@unsafe
def p175fp_reported(+mode: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2,KDef>, report: DR_Report) -> P175Frontend:
  match report:
    case DR_Report{+verdict, names}:
      p175fp_owned(mode, load, world, book, verdict, driver_emit_owned(book))


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:524

@unsafe
def p175fp_checked(+mode: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +original: List<&2,KDef>, result: DResult) -> P175Frontend:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P175Frontend, String.is_empty(error),
        u => nt_choose(P175Frontend,String.eq(mode,"check"),
          v => P175FBook{"check",book,""},
          v => p175fp_reported(mode, load, world, book, driver_report_data(original))),
        u => P175FError{"check: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:512
@unsafe
def p175fp_loaded(+mode: String, +seed: P86Seed, +load: FPrefixLoad) -> P175Frontend:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P175Frontend, String.is_empty(error),
                u => nt_choose(P175Frontend,String.eq(mode,"parse"),
                  v => P175FBook{"parse",original,""},
                  v => p175fp_checked(mode, load, world, original, nt_choose(DResult,p143cg_enough(suffix,256),
                    w => p143cb_program(load,Nil{},world,True{}),
                    w => check_program_diagnostic_world(load,Nil{},world)))),
                u => P175FError{"parse: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:506
@unsafe
def p175fp_completed(+mode: String, +seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P175Frontend:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p175fp_loaded(mode, seed, f_prefix_graph_trace(carrier, [source, base], fresh))


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:495
@unsafe
def p175fp_seeded(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P175Frontend:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          kc(P175Frontend, String.is_empty(error),
            u => p175fp_completed(mode, seed, source,
              f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
            u => P175FError{"parse: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:488
@unsafe
def p175fp_seed(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader) -> P175Frontend:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p175fp_seeded(mode, seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:483
@unsafe
def p175fp_imported(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P175Frontend:
  kc(P175Frontend, String.is_empty(error),
    u => p175fp_seed(mode, seed, source, header), u => P175FError{"load: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:475
@unsafe
def p175fp_header(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader) -> P175Frontend:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P175Frontend, String.is_empty(error),
        u => p175fp_imported(mode, seed, source, header, p86_import_error(imports, False{})),
        u => P175FError{"parse: " ++ error})


# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:467
@unsafe
def p175fp_plan(+mode: String, +seed: P86Seed, +path: String, +text: String) -> P175Frontend:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p175fp_header(mode, seed, source, f_source_header(source))


# Independent unchanged orchestration path for complete small-value comparisons.
@unsafe
def p175fp_reference(seed: P86Seed, path: String, text: String) -> P175Frontend:
  p175fp_ordinary(p86_plan(seed,path,text))

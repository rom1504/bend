# Alternative parser-only orchestration; do not combine with frontend-plan.bend.
# The result datatype/digest stay identical to the full service for exact comparison.

# Experimental frontend-only stage stops. Same maintained computations and error order.
# Request mode is independently compared with ordinary p86_plan; no backend is called.
type P175Frontend is Data:
  P175FError{+error: String}
  P175FBook{+stage: String, +book: List<&2,KDef>, +verdict: String}
  P175FRequest{+request: NR_Request, +verdict: String}

# Same parsed success/error boundary; checker and postchecks are unreachable.
@unsafe
def p175fp_loaded(+mode: String, +seed: P86Seed, +load: FPrefixLoad) -> P175Frontend:
  match seed load:
    case P86Seed{base, book, fresh, ready, world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P175Frontend,String.is_empty(error),
                u => P175FBook{"parse",original,""},
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

# Actual loader suffix admission for large publication controls. No host parsing.
# The mode argument is retained for the common parser transport; pass "parse".
type P175PAResult is Data:
  P175PAError{+error: String}
  P175PAReady{+suffixCount: U32, +ordinaryCount: U32, +compact: Bool}

@unsafe
def p175pa_count(definitions: List<&2,KDef>, count: U32) -> U32:
  match definitions:
    case Nil{}: count
    case Con{head,rest}: p175pa_count(rest,U32.inc(count))

@unsafe
def p175pa_ordinary_count(definitions: List<&2,KDef>, count: U32) -> U32:
  match definitions:
    case Nil{}: count
    case Con{head,rest}:
      p175pa_ordinary_count(rest,U32.add(count,nt_choose(U32,p143cp_childless(head),u => 1,u => 0)))

@unsafe
def p175pa_loaded(+mode: String, +seed: P86Seed, +load: FPrefixLoad) -> P175PAResult:
  match seed load:
    case P86Seed{base,book,fresh,ready,world} FPrefixLoad{trace,prefix,+suffix,eligible}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{original,+error,imports}:
              kc(P175PAResult,String.is_empty(error),
                u => P175PAReady{p175pa_count(suffix,0),p175pa_ordinary_count(suffix,0),p143cg_enough(suffix,256)},
                u => P175PAError{"parse: " ++ error})




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:506
@unsafe
def p175pa_completed(+mode: String, +seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P175PAResult:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p175pa_loaded(mode, seed, f_prefix_graph_trace(carrier, [source, base], fresh))




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:495
@unsafe
def p175pa_seeded(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P175PAResult:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          kc(P175PAResult, String.is_empty(error),
            u => p175pa_completed(mode, seed, source,
              f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
            u => P175PAError{"parse: " ++ error})




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:488
@unsafe
def p175pa_seed(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader) -> P175PAResult:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p175pa_seeded(mode, seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:483
@unsafe
def p175pa_imported(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P175PAResult:
  kc(P175PAResult, String.is_empty(error),
    u => p175pa_seed(mode, seed, source, header), u => P175PAError{"load: " ++ error})




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:475
@unsafe
def p175pa_header(+mode: String, +seed: P86Seed, +source: FSource, +header: FHeader) -> P175PAResult:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P175PAResult, String.is_empty(error),
        u => p175pa_imported(mode, seed, source, header, p86_import_error(imports, False{})),
        u => P175PAError{"parse: " ++ error})




# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:467
@unsafe
def p175pa_plan(+mode: String, +seed: P86Seed, +path: String, +text: String) -> P175PAResult:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p175pa_header(mode, seed, source, f_source_header(source))

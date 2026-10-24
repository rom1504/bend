# Exact parse/import prefix copied from qualified Phase134. Only continuation
# names and result transport change; original declarations remain untouched.

@unsafe
def p136f_parse(+seed: P86Seed, +path: String, +text: String) -> P136Step:
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      p136f_parse_header(seed, source, f_source_header(source))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:475

@unsafe
def p136f_parse_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P136Step:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      kc(P136Step, String.is_empty(error),
        u => p136f_parse_imported(seed, source, header, p86_import_error(imports, False{})),
        u => P136Plan{P86PlanError{"parse: " ++ error}})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:483

@unsafe
def p136f_parse_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P136Step:
  kc(P136Step, String.is_empty(error),
    u => p136f_parse_seed(seed, source, header), u => P136Plan{P86PlanError{"load: " ++ error}})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:488

@unsafe
def p136f_parse_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P136Step:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      p136f_parse_seeded(seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:495

@unsafe
def p136f_parse_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P136Step:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          kc(P136Step, String.is_empty(error),
            u => p136f_parse_completed(seed, source,
              f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
            u => P136Plan{P86PlanError{"parse: " ++ error}})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:506

@unsafe
def p136f_parse_completed(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P136Step:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      p136f_parse_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:512

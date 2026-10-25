# Actual P86 loader path; hint is an edit position, with a cold lexical landmark. Cache values are private, process-local products of
# p140p_seed, under a fixed compiler. Headers are always scanned from this source.
# Completion, validation, diagnostics and global freshening remain original.
type P140PLoadResult is Data:
  P140PLoadReady {+load: FPrefixLoad, +cache: Maybe<&2,P140PCache>, +hit: Bool}
  P140PLoadError {+error: String, +cache: Maybe<&2,P140PCache>}

@unsafe
def p140pl_load(+seed: P86Seed, +path: String, +text: String, cache: Maybe<&2,P140PCache>, hint: U32) -> P140PLoadResult:
  match seed:
    case P86Seed{+base,book,fresh,ready,world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path,path,text},begin,U32.add(U32.add(begin,p86_width(text,0)),1))
      p140pl_header(seed,source,f_source_header(source),cache,hint)

@unsafe
def p140pl_header(+seed: P86Seed, +source: FSource, +header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32) -> P140PLoadResult:
  match header:
    case FHeader{imports,+error,body,line,offset}:
      nt_choose(P140PLoadResult,String.is_empty(error),
        u => p140pl_imported(seed,source,header,cache,hint,p86_import_error(imports,False{})),
        u => P140PLoadError{"parse: " ++ error,cache})

@unsafe
def p140pl_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32, +error: String) -> P140PLoadResult:
  nt_choose(P140PLoadResult,String.is_empty(error),
    u => p140pl_seed(seed,source,header,cache,hint),u => P140PLoadError{"load: " ++ error,cache})

@unsafe
def p140pl_seed(+seed: P86Seed, source: FSource, header: FHeader, cache: Maybe<&2,P140PCache>, hint: U32) -> P140PLoadResult:
  match seed:
    case P86Seed{+base,+book,fresh,+ready,world}:
      p140pl_seeded(seed,source,header,cache,hint,
        f_prefix_complete_ready_seed(base,"",f_prefix_graph_empty(),f_source_path(base),f_source_text(base),book,ready))

@unsafe
def p140pl_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32, completion: FPrefixCompletion) -> P140PLoadResult:
  match completion:
    case FPrefixCompletion{carrier,parsed}:
      match parsed:
        case FResult{defs,+error,imports}:
          nt_choose(P140PLoadResult,String.is_empty(error),
            u => p140pl_complete(seed,source,header,cache,hint,carrier),
            u => P140PLoadError{"parse: " ++ error,cache})

@unsafe
def p140pl_complete(+seed: P86Seed, +source: FSource, +header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32, +carrier: FPrefixGraph) -> P140PLoadResult:
  match carrier:
    case FPrefixGraph{graph,prefix,suffix,count,ready}:
      p140pl_fallback(seed,source,header,cache,carrier)
    case FReadyPrefixGraph{+graph,prefix,suffix,count,ready,names,ctors,baseNames}:
      nt_choose(P140PLoadResult,ready,u => p140pl_ready(seed,source,header,cache,hint,carrier,graph,names,ctors),
        u => p140pl_fallback(seed,source,header,cache,carrier))

@unsafe
def p140pl_fallback(+seed: P86Seed, +source: FSource, header: FHeader, cache: Maybe<&2,P140PCache>, carrier: FPrefixGraph) -> P140PLoadResult:
  match seed:
    case P86Seed{+base,book,fresh,ready,world}:
      p140pl_completed(seed,source,cache,False{},
        f_prefix_complete_source(source,"",header,[source,base],carrier,f_path_dir(f_source_path(source))))

@unsafe
def p140pl_ready(+seed: P86Seed, +source: FSource, +header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32, +carrier: FPrefixGraph, +graph: FGraph, +names: KDef, +ctors: KDef) -> P140PLoadResult:
  match seed graph:
    case P86Seed{+base,book,fresh,ready,world} FGraph{+prior,+error,done}:
      nt_choose(P140PLoadResult,String.is_empty(error),
        u => p140pl_aliases(seed,source,header,cache,hint,carrier,graph,names,ctors,prior,
          f_graph_aliases(f_header_imports(header),source,[source,base],f_path_dir(f_source_path(source)))),
        u => p140pl_fallback(seed,source,header,cache,carrier))

@unsafe
def p140pl_aliases(+seed: P86Seed, +source: FSource, header: FHeader, +cache: Maybe<&2,P140PCache>, +hint: U32, +carrier: FPrefixGraph, +graph: FGraph, +names: KDef, ctors: KDef, prior: List<&2,KDef>, +aliases: List<&2,KTerm>) -> P140PLoadResult:
  p140pl_parsed(seed,source,carrier,graph,names,aliases,
    p140pl_parse(f_source_text(source),header,FParseScope{prior,names,ctors,"",aliases},f_source_begin(source),hint,cache))

@unsafe
def p140pl_parse(+text: String, +header: FHeader, +scope: FParseScope, +start: U32, hint: U32, +cache: Maybe<&2,P140PCache>) -> P140PParsed:
  match cache:
    case None{}: p140p_seed_before(text,header,scope,start,hint)
    case Some{checkpoint}: p140p_resume(text,header,scope,start,cache)

@unsafe
def p140pl_parsed(+seed: P86Seed, +source: FSource, carrier: FPrefixGraph, graph: FGraph, names: KDef, aliases: List<&2,KTerm>, parsed: P140PParsed) -> P140PLoadResult:
  match seed parsed:
    case P86Seed{+base,book,fresh,ready,world} P140PParsed{result,cache,hit}:
      p140pl_indexed(seed,source,cache,hit,carrier,
        f_graph_finish_indexed(source,"",aliases,graph,[source,base],names,result))

@unsafe
def p140pl_indexed(+seed: P86Seed, +source: FSource, +cache: Maybe<&2,P140PCache>, +hit: Bool, carrier: FPrefixGraph, completion: FIndexedCompletion) -> P140PLoadResult:
  match carrier:
    case FReadyPrefixGraph{graph,prefix,suffix,count,ready,names,ctors,baseNames}:
      p140pl_completed(seed,source,cache,hit,
        f_prefix_ready_source_completed(prefix,suffix,count,baseNames,names,ctors,completion))
    case FPrefixGraph{graph,prefix,suffix,count,ready}:
      P140PLoadError{"internal parser indexed completion",cache}

@unsafe
def p140pl_completed(seed: P86Seed, +source: FSource, cache: Maybe<&2,P140PCache>, hit: Bool, completion: FPrefixCompletion) -> P140PLoadResult:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      P140PLoadReady{f_prefix_graph_trace(carrier,[source,base],fresh),cache,hit}

# Reference loader composition for the bridge screen. This calls the original
# complete-source path and original global freshening, with no parser overlay.
@unsafe
def p140pl_reference(+seed: P86Seed, +path: String, +text: String) -> FPrefixLoad:
  match seed:
    case P86Seed{+base,+book,fresh,+ready,world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path,path,text},begin,U32.add(U32.add(begin,p86_width(text,0)),1))
      p140pl_reference_seeded(seed,source,f_source_header(source),
        f_prefix_complete_ready_seed(base,"",f_prefix_graph_empty(),f_source_path(base),f_source_text(base),book,ready))

@unsafe
def p140pl_reference_seeded(+seed: P86Seed, +source: FSource, header: FHeader, completion: FPrefixCompletion) -> FPrefixLoad:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      p140pl_reference_completed(seed,source,
        f_prefix_complete_source(source,"",header,[source,base],carrier,f_path_dir(f_source_path(source))))

@unsafe
def p140pl_reference_completed(seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> FPrefixLoad:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      f_prefix_graph_trace(carrier,[source,base],fresh)

@unsafe
def p140pl_plan(+seed: P86Seed, parsed: P140PLoadResult) -> P86Plan:
  match parsed:
    case P140PLoadError{error,cache}: P86PlanError{error}
    case P140PLoadReady{load,cache,hit}: p86_plan_loaded(seed,load)

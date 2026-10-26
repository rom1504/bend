# Private experimental loader. Original completion, validation, freshening
# fallback and complete load shape remain authoritative. No source overrides.
type P142FLResult is Data:
  P142FLResult{+loaded: P140PLoadResult, +cache: P142FFCache, +stats: List<&2,U32>}

@unsafe
def p142fl_load(+seed: P86Seed, +path: String, +text: String, +parser: Maybe<&2,P140PCache>, +hint: U32, +cache: P142FFCache) -> P142FLResult:
  +begin = f_source_end(p142fl_base(seed))
  +source = f_source_located(FSource{path,path,text},begin,U32.add(U32.add(begin,p86_width(text,0)),1))
  p142fl_header(seed,path,text,parser,hint,cache,source,f_source_header(source))

def p142fl_base(seed: P86Seed) -> FSource:
  match seed:
    case P86Seed{base,book,fresh,ready,world}: base

@unsafe
def p142fl_error(error: String, parser: Maybe<&2,P140PCache>, cache: P142FFCache) -> P142FLResult:
  P142FLResult{P140PLoadError{error,parser},cache,[]}

@unsafe
def p142fl_header(+seed: P86Seed, +path: String, +text: String, +parser: Maybe<&2,P140PCache>, +hint: U32, +cache: P142FFCache, +source: FSource, +header: FHeader) -> P142FLResult:
  match header:
    case FHeader{imports,error,body,line,offset}:
      nt_choose(P142FLResult,String.is_empty(error),
        u => p142fl_imported(seed,path,text,parser,hint,cache,source,header,p86_import_error(imports,False{})),
        u => p142fl_error("parse: " ++ error,parser,cache))

@unsafe
def p142fl_imported(+seed: P86Seed, path: String, text: String, +parser: Maybe<&2,P140PCache>, hint: U32, +cache: P142FFCache, source: FSource, header: FHeader, +error: String) -> P142FLResult:
  nt_choose(P142FLResult,String.is_empty(error),
    u => p142fl_seed(seed,path,text,parser,hint,cache,source,header),
    u => p142fl_error("load: " ++ error,parser,cache))

@unsafe
def p142fl_seed(+seed: P86Seed, path: String, text: String, parser: Maybe<&2,P140PCache>, hint: U32, cache: P142FFCache, source: FSource, header: FHeader) -> P142FLResult:
  match seed:
    case P86Seed{+base,+book,fresh,+ready,world}:
      p142fl_seeded(seed,path,text,parser,hint,cache,source,header,
        f_prefix_complete_ready_seed(base,"",f_prefix_graph_empty(),f_source_path(base),f_source_text(base),book,ready))

@unsafe
def p142fl_seeded(+seed: P86Seed, +path: String, +text: String, +parser: Maybe<&2,P140PCache>, +hint: U32, +cache: P142FFCache, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P142FLResult:
  match completion:
    case FPrefixCompletion{+carrier,FResult{defs,error,imports}}:
      nt_choose(P142FLResult,String.is_empty(error),
        u => p142fl_ready(seed,path,text,parser,hint,cache,source,header,carrier),
        u => p142fl_error("parse: " ++ error,parser,cache))

@unsafe
def p142fl_fallback(seed: P86Seed, path: String, text: String, parser: Maybe<&2,P140PCache>, hint: U32) -> P142FLResult:
  P142FLResult{p140pl_load(seed,path,text,parser,hint),P142FFEmpty{},[0,0,0]}

@unsafe
def p142fl_ready(+seed: P86Seed, +path: String, +text: String, +parser: Maybe<&2,P140PCache>, +hint: U32, +cache: P142FFCache, +source: FSource, +header: FHeader, +carrier: FPrefixGraph) -> P142FLResult:
  match carrier:
    case FReadyPrefixGraph{+graph,prefix,suffix,count,+ready,names,ctors,baseNames}:
      nt_choose(P142FLResult,ready,
        u => p142fl_aliases(seed,path,text,parser,hint,cache,source,header,carrier,graph,names,ctors,
          f_graph_aliases(f_header_imports(header),source,[source,p142fl_base(seed)],f_path_dir(f_source_path(source)))),
        u => p142fl_fallback(seed,path,text,parser,hint))
    case _: p142fl_fallback(seed,path,text,parser,hint)

@unsafe
def p142fl_aliases(+seed: P86Seed, path: String, text: String, +parser: Maybe<&2,P140PCache>, +hint: U32, cache: P142FFCache, +source: FSource, +header: FHeader, carrier: FPrefixGraph, +graph: FGraph, +names: KDef, ctors: KDef, +aliases: List<&2,KTerm>) -> P142FLResult:
  match graph:
    case FGraph{prior,+error,done}:
      nt_choose(P142FLResult,String.is_empty(error),
        u => p142fl_parsed(seed,cache,source,carrier,graph,names,aliases,
          p140pl_parse(f_source_text(source),header,FParseScope{prior,names,ctors,"",aliases},f_source_begin(source),hint,parser)),
        u => p142fl_fallback(seed,path,text,parser,hint))

@unsafe
def p142fl_parsed(+seed: P86Seed, cache: P142FFCache, +source: FSource, carrier: FPrefixGraph, graph: FGraph, names: KDef, aliases: List<&2,KTerm>, parsed: P140PParsed) -> P142FLResult:
  match parsed:
    case P140PParsed{result,parser,hit}:
      p142fl_indexed(seed,cache,source,carrier,parser,hit,
        f_graph_finish_indexed(source,"",aliases,graph,[source,p142fl_base(seed)],names,result))

@unsafe
def p142fl_indexed(seed: P86Seed, +cache: P142FFCache, source: FSource, carrier: FPrefixGraph, +parser: Maybe<&2,P140PCache>, hit: Bool, completed: FIndexedCompletion) -> P142FLResult:
  match carrier:
    case FReadyPrefixGraph{graph,prefix,suffix,count,ready,names,ctors,baseNames}:
      p142fl_completed(seed,cache,source,parser,hit,f_prefix_ready_source_completed(prefix,suffix,count,baseNames,names,ctors,completed))
    case _: p142fl_error("internal parser indexed completion",parser,cache)

@unsafe
def p142fl_completed(+seed: P86Seed, cache: P142FFCache, +source: FSource, parser: Maybe<&2,P140PCache>, hit: Bool, completion: FPrefixCompletion) -> P142FLResult:
  match seed completion:
    case P86Seed{base,book,+fresh,ready,world} FPrefixCompletion{+carrier,parsed}:
      p142fl_trace(carrier,[source,base],fresh,parser,hit,cache)

@unsafe
def p142fl_original(+carrier: FPrefixGraph, +sources: List<&2,FSource>, fresh: FFreshPrefixState, parser: Maybe<&2,P140PCache>, hit: Bool) -> P142FLResult:
  P142FLResult{P140PLoadReady{f_prefix_graph_trace(carrier,sources,fresh),parser,hit},P142FFEmpty{},[0,0,0]}

@unsafe
def p142fl_trace(+carrier: FPrefixGraph, +sources: List<&2,FSource>, +fresh: FFreshPrefixState, +parser: Maybe<&2,P140PCache>, +hit: Bool, cache: P142FFCache) -> P142FLResult:
  match carrier fresh parser:
    case FReadyPrefixGraph{+graph,prefix,+suffix,count,ready,names,ctors,baseNames} FFreshPrefixState{next,fresh_ready} Some{checkpoint}:
      nt_choose(P142FLResult,ready && fresh_ready,
        u => p142fl_validated(carrier,sources,fresh,parser,hit,cache,next,p142fl_cut(checkpoint),
          f_prefix_ready_validate(p142fl_book(graph),suffix,p142fl_graph_error(graph),baseNames)),
        u => p142fl_original(carrier,sources,fresh,parser,hit))
    case _ _ _: p142fl_original(carrier,sources,fresh,parser,hit)

def p142fl_book(graph: FGraph) -> List<&2,KDef>:
  match graph:
    case FGraph{book,error,done}: book

def p142fl_graph_error(graph: FGraph) -> String:
  match graph:
    case FGraph{book,error,done}: error

def p142fl_cut(parser: P140PCache) -> U32:
  match parser:
    case P140PCache{source,initial,start,token,previous,context,book,imports,unsafe,scope}: nt_count(KDef,book)

@unsafe
def p142fl_validated(+carrier: FPrefixGraph, +sources: List<&2,FSource>, +fresh: FFreshPrefixState, +parser: Maybe<&2,P140PCache>, +hit: Bool, cache: P142FFCache, next: U32, +cut: U32, +validated: FResult) -> P142FLResult:
  match carrier validated:
    case FReadyPrefixGraph{+graph,+prefix,suffix,count,ready,names,ctors,baseNames} FResult{book,+error,+imports}:
      nt_choose(P142FLResult,String.is_empty(error),
        u => p142fl_freshened(graph,sources,prefix,imports,parser,hit,cut,p142ff_apply(suffix,next,cut,cache)),
        u => P142FLResult{P140PLoadReady{f_prefix_trace_fallback(graph,sources,validated),parser,hit},P142FFEmpty{},[0,cut,0]})
    case _ _: p142fl_original(carrier,sources,fresh,parser,hit)

@unsafe
def p142fl_freshened(graph: FGraph, sources: List<&2,FSource>, prefix: List<&2,KDef>, imports: List<&2,KTerm>, parser: Maybe<&2,P140PCache>, parsed: Bool, cut: U32, result: P142FFResult) -> P142FLResult:
  match result:
    case P142FFResult{value,cache,hit}:
      P142FLResult{P140PLoadReady{f_prefix_trace_fresh(graph,sources,prefix,imports,value),parser,parsed},cache,[Bool.to_u32(hit),cut,1]}

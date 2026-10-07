# Private prepared alpha-renaming certificate. The driver binds this compact
# state to one exact cached book/API/Base/path/interval; it is not a public proof.
type FFreshPrefixState is Data:
  FFreshPrefixState{+next: U32, +ready: Bool}

type FFreshPrefixTail is Data:
  FFreshPrefixTail{+suffix: List<&2,KDef>, +matched: Bool}

law f_fresh_prefix_exact_defs:
  for +left: List<&2,KDef>
  for +right: List<&2,KDef>
  Bool

@unsafe
def f_fresh_prefix_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KAnnotation{term, typ}:
      3
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2

# Unlike conversion equality, a loader snapshot retains variant, source spans
# and explicit Lambda quantity presence. Worklists avoid nested tree recursion.
@unsafe
def f_fresh_prefix_exact_terms(+left: List<&2,KTerm>, +right: List<&2,KTerm>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, U32.is_eq(f_fresh_prefix_variant(a), f_fresh_prefix_variant(b)) && norm_exact_head(a, b) && Bool.not(Bool.xor(k_quantity_present(a), k_quantity_present(b))) && U32.is_eq(kb(a), kb(b)) && U32.is_eq(ke(a), ke(b)),
        u => f_fresh_prefix_exact_terms(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_left other_right: False{}

@unsafe
def f_fresh_prefix_exact_head(+a: KDef, +b: KDef) -> Bool:
  String.eq(dn(a), dn(b)) && String.eq(dk(a), dk(b)) && U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && Bool.not(Bool.xor(db(a), db(b))) && Bool.not(Bool.xor(du(a), du(b))) && U32.is_eq(f_graph_count_defs(dc(a), 0), f_graph_count_defs(dc(b), 0)) && f_fresh_prefix_exact_terms([dt(a), dv(a)], [dt(b), dv(b)])

@unsafe
def f_fresh_prefix_exact_defs(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, f_fresh_prefix_exact_head(a, b),
        u => f_fresh_prefix_exact_defs(norm_defs_join(dc(a), ar), norm_defs_join(dc(b), br)), u => False{})
    case other_left other_right: False{}

# Preparation executes the actual freshener once. Only an already canonical
# prefix admits reuse; next is its returned counter, never a guessed max ID.
@unsafe
def f_fresh_prefix_prepare(+prefix: List<&2,KDef>) -> FFreshPrefixState:
  f_fresh_prefix_prepared(prefix, f_fresh_defs(prefix, 1))

@unsafe
def f_fresh_prefix_prepared(+prefix: List<&2,KDef>, +result: FFreshDefs) -> FFreshPrefixState:
  match result:
    case FFreshDefs{fresh, next}:
      FFreshPrefixState{next, f_fresh_prefix_exact_defs(prefix, fresh)}

@unsafe
def f_fresh_prefix_tail(+whole: List<&2,KDef>, +prefix: List<&2,KDef>) -> FFreshPrefixTail:
  match whole prefix:
    case rest Nil{}: FFreshPrefixTail{rest, True{}}
    case Con{a, ar} Con{b, br}:
      kc(FFreshPrefixTail, f_fresh_prefix_exact_head(a, b) && f_fresh_prefix_exact_defs(dc(a), dc(b)),
        u => f_fresh_prefix_tail(ar, br), u => FFreshPrefixTail{Nil{}, False{}})
    case other_whole other_prefix: FFreshPrefixTail{Nil{}, False{}}

@unsafe
def f_fresh_prefix_finish(+prefix: List<&2,KDef>, +result: FFreshDefs, +imports: List<&2,KTerm>) -> FResult:
  match result:
    case FFreshDefs{suffix, next}:
      FResult{norm_defs_join(prefix, suffix), "", imports}

@unsafe
def f_fresh_prefix_selected(+original: FResult, +prefix: List<&2,KDef>, +next: U32, +imports: List<&2,KTerm>, +tail: FFreshPrefixTail) -> FResult:
  match tail:
    case FFreshPrefixTail{suffix, matched}:
      kc(FResult, matched,
        u => f_fresh_prefix_finish(prefix, f_fresh_defs(suffix, next), imports),
        u => f_fresh_result(original))

@unsafe
def f_fresh_prefix_result(+original: FResult, +prefix: List<&2,KDef>, +state: FFreshPrefixState) -> FResult:
  match original state:
    case FResult{book, error, imports} FFreshPrefixState{next, ready}:
      kc(FResult, ready && String.is_empty(error),
        u => f_fresh_prefix_selected(original, prefix, next, imports, f_fresh_prefix_tail(book, prefix)),
        u => f_fresh_result(original))

# This optional private entry preserves graph validation, freshness diagnostics
# and origin refinement. Failed/error/nonleading certificates take the old path.
@unsafe
def f_graph_trace_from_prefix(+graph: FGraph, +sources: List<&2,FSource>, +prefix: List<&2,KDef>, +state: FFreshPrefixState) -> FLoadTrace:
  match graph:
    case FGraph{book, error, done}:
      FLoadTrace{fpe_graph_result(graph, sources,
        f_fresh_prefix_result(f_graph_fresh_result(f_validate_result(FResult{book, error, Nil{}})), prefix, state)), done, sources}

# PRIVATE ordinary-driver provenance path. A carrier is created only by the
# actual leading Base injection and advanced only by native completion below.
# The driver never accepts a caller-created carrier or grants this path to raw
# public seed/API objects. Existing graph/prefix APIs keep structural checks.
type FPrefixGraph is Data:
  FPrefixGraph{+graph: FGraph, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +ready: Bool}
  FReadyPrefixGraph{+graph: FGraph, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +ready: Bool, +names: KDef, +ctors: KDef, +baseNames: KDef}

# Private immutable parser scope, prepared only for the exact admitted Base.
# Names retain the latest declaration event; constructors retain the first DFS.
type FReadyPrefixState is Data:
  FReadyPrefixState{+names: KDef, +ctors: KDef, +count: U32, +ready: Bool}

@unsafe
def f_ready_prefix_prepare(+prefix: List<&2,KDef>) -> FReadyPrefixState:
  FReadyPrefixState{index_build(List.reverse(&2,KDef,prefix)), f_ctor_index(prefix, missing()), f_graph_count_defs(prefix, 0), String.is_empty(f_error_defs(prefix)) && String.is_empty(f_graph_fresh_names(prefix, missing()))}

type FPrefixCompletion is Data:
  FPrefixCompletion{+carrier: FPrefixGraph, +parsed: FResult}

type FPrefixLoad is Data:
  FPrefixLoad{+trace: FLoadTrace, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool}

@unsafe
def f_prefix_graph_empty() -> FPrefixGraph:
  FPrefixGraph{FGraph{Nil{}, "", Nil{}}, Nil{}, Nil{}, 0, False{}}

@unsafe
def f_prefix_complete_seed(+source: FSource, +ns: String, +carrier: FPrefixGraph, +path: String, +text: String, +book: List<&2,KDef>) -> FPrefixCompletion:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      f_prefix_seed_completed(graph, ns, ready, book, f_complete_seed(source, graph, path, text, book))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      f_prefix_seed_completed(graph, ns, ready, book, f_complete_seed(source, graph, path, text, book))

@unsafe
def f_prefix_complete_ready_seed(+source: FSource, +ns: String, +carrier: FPrefixGraph, +path: String, +text: String, +book: List<&2,KDef>, +state: FReadyPrefixState) -> FPrefixCompletion:
  f_prefix_ready_seed_completed(state, f_prefix_complete_seed(source, ns, carrier, path, text, book))

@unsafe
def f_prefix_ready_seed_completed(+state: FReadyPrefixState, +completed: FPrefixCompletion) -> FPrefixCompletion:
  match state completed:
    case FReadyPrefixState{names, ctors, count, ready} FPrefixCompletion{carrier, parsed}:
      match carrier:
        case FPrefixGraph{graph, prefix, suffix, actual, eligible}:
          kc(FPrefixCompletion, eligible && ready && U32.is_eq(count, actual),
            u => FPrefixCompletion{FReadyPrefixGraph{graph, prefix, suffix, count, True{}, names, ctors, names}, parsed},
            u => completed)
        case FReadyPrefixGraph{graph, prefix, suffix, actual, eligible, oldNames, oldCtors, baseNames}: completed

@unsafe
def f_prefix_seed_completed(+prior: FGraph, +ns: String, +prior_ready: Bool, +prefix: List<&2,KDef>, +completion: FCompletion) -> FPrefixCompletion:
  match prior completion:
    case FGraph{book, error, done} FCompletion{graph, parsed}:
      f_prefix_seed_graph(graph, parsed, prefix, Bool.not(prior_ready) && List.is_empty(&2, KDef, book) && List.is_empty(&2, KTerm, done) && String.is_empty(error) && String.is_empty(ns))

@unsafe
def f_prefix_seed_graph(+graph: FGraph, +parsed: FResult, +prefix: List<&2,KDef>, +eligible: Bool) -> FPrefixCompletion:
  match graph parsed:
    case FGraph{book, error, done} FResult{definitions, parse_error, imports}:
      FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, f_graph_count_defs(prefix, 0), eligible && String.is_empty(error) && String.is_empty(parse_error)}, parsed}

# Native completion qualifies/fills/paths only its new fragment; prior KDefs
# remain untouched in norm_defs_join(prior,new). Drop only the certified number
# of top-level event cells to retain the actual suffix, without inspecting terms.
@unsafe
def f_prefix_drop(+book: List<&2,KDef>, +count: U32) -> FFreshPrefixTail:
  kc(FFreshPrefixTail, U32.is_eq(count, 0), u => FFreshPrefixTail{book, True{}}, u => f_prefix_drop_next(book, count))

@unsafe
def f_prefix_drop_next(+book: List<&2,KDef>, +count: U32) -> FFreshPrefixTail:
  match book:
    case Nil{}: FFreshPrefixTail{Nil{}, False{}}
    case Con{d, rest}: f_prefix_drop(rest, U32.sub(count, 1))

@unsafe
def f_prefix_complete_source(+source: FSource, +ns: String, +header: FHeader, +sources: List<&2,FSource>, +carrier: FPrefixGraph, +root: String) -> FPrefixCompletion:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      f_prefix_source_completed(prefix, count, ready, f_complete_source(source, ns, header, sources, graph, root))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      kc(FPrefixCompletion, ready,
        u => f_prefix_ready_source_completed(prefix, suffix, count, baseNames, names, ctors, f_complete_source_indexed(source, ns, header, sources, graph, root, names, ctors)),
        u => f_prefix_source_completed(prefix, count, False{}, f_complete_source(source, ns, header, sources, graph, root)))

# Carry the actual completed fragment instead of walking the Base spine twice
# to rediscover it. Prior suffix cells and all prior term trees stay unchanged.
@unsafe
def f_prefix_ready_source_completed(+prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +baseNames: KDef, +names: KDef, +ctors: KDef, +completion: FIndexedCompletion) -> FPrefixCompletion:
  match completion:
    case FIndexedCompletion{graph, parsed, fragment}:
      match graph:
        case FGraph{book, error, done}:
          kc(FPrefixCompletion, String.is_empty(error),
            u => FPrefixCompletion{FReadyPrefixGraph{graph, prefix, norm_defs_join(suffix, fragment), count, True{}, f_prefix_names_extend(fragment, names), f_prefix_ctors_extend(fragment, ctors), baseNames}, parsed},
            u => FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, count, False{}}, parsed})

@unsafe
def f_prefix_names_extend(+defs: List<&2,KDef>, +names: KDef) -> KDef:
  match defs:
    case Nil{}: names
    case Con{d, rest}: f_prefix_names_extend(rest, index_set(names, d, index_hash(dn(d), 2166136261), 32))

@unsafe
def f_prefix_ctors_extend(+defs: List<&2,KDef>, +ctors: KDef) -> KDef:
  match defs:
    case Nil{}: ctors
    case Con{d, rest}:
      +hash = index_hash(dn(d), 2166136261)
      +next = kc(KDef, String.eq(dk(d), "Ctr") && String.eq(dk(index_find(ctors, dn(d), hash, 32)), "Absent"), u => index_set(ctors, d, hash, 32), u => ctors)
      f_prefix_ctors_extend(rest, f_prefix_ctors_extend(dc(d), next))

@unsafe
def f_prefix_source_completed(+prefix: List<&2,KDef>, +count: U32, +ready: Bool, +completion: FCompletion) -> FPrefixCompletion:
  match completion:
    case FCompletion{graph, parsed}:
      match graph:
        case FGraph{book, error, done}:
          kc(FPrefixCompletion, ready && String.is_empty(error),
            u => f_prefix_source_tail(graph, parsed, prefix, count, f_prefix_drop(book, count)),
            u => FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, count, False{}}, parsed})

@unsafe
def f_prefix_source_tail(+graph: FGraph, +parsed: FResult, +prefix: List<&2,KDef>, +count: U32, +tail: FFreshPrefixTail) -> FPrefixCompletion:
  match tail:
    case FFreshPrefixTail{suffix, matched}: FPrefixCompletion{FPrefixGraph{graph, prefix, suffix, count, matched}, parsed}

@unsafe
def f_prefix_graph_trace(+carrier: FPrefixGraph, +sources: List<&2,FSource>, +state: FFreshPrefixState) -> FPrefixLoad:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      match graph state:
        case FGraph{book, error, done} FFreshPrefixState{next, fresh_ready}:
          f_prefix_trace_validated(graph, sources, prefix, suffix, next, ready && fresh_ready,
            f_graph_fresh_result(f_validate_result(FResult{book, error, Nil{}})))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      match graph state:
        case FGraph{book, error, done} FFreshPrefixState{next, fresh_ready}:
          kc(FPrefixLoad, ready && fresh_ready,
            u => f_prefix_trace_validated(graph, sources, prefix, suffix, next, True{}, f_prefix_ready_validate(book, suffix, error, baseNames)),
            u => f_prefix_graph_trace(FPrefixGraph{graph, prefix, suffix, count, ready}, sources, state))

@unsafe
def f_prefix_ready_validate(+whole: List<&2,KDef>, +suffix: List<&2,KDef>, +error: String, +baseNames: KDef) -> FResult:
  f_prefix_ready_validated(whole, baseNames, f_validate_result(FResult{suffix, error, Nil{}}))

@unsafe
def f_prefix_ready_validated(+whole: List<&2,KDef>, +baseNames: KDef, +validated: FResult) -> FResult:
  match validated:
    case FResult{book, checked, imports}:
      FResult{whole, kc(String, String.is_empty(checked), u => f_graph_fresh_names(book, baseNames), u => checked), imports}

@unsafe
def f_prefix_trace_validated(+graph: FGraph, +sources: List<&2,FSource>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +next: U32, +ready: Bool, +validated: FResult) -> FPrefixLoad:
  match validated:
    case FResult{book, error, imports}:
      kc(FPrefixLoad, ready && String.is_empty(error),
        u => f_prefix_trace_fresh(graph, sources, prefix, imports, f_fresh_defs(suffix, next)),
        u => f_prefix_trace_fallback(graph, sources, validated))

@unsafe
def f_prefix_trace_fresh(+graph: FGraph, +sources: List<&2,FSource>, +prefix: List<&2,KDef>, +imports: List<&2,KTerm>, +fresh: FFreshDefs) -> FPrefixLoad:
  match graph fresh:
    case FGraph{book, error, done} FFreshDefs{suffix, next}:
      FPrefixLoad{FLoadTrace{fpe_graph_result(graph, sources, FResult{norm_defs_join(prefix, suffix), "", imports}), done, sources}, prefix, suffix, True{}}

@unsafe
def f_prefix_trace_fallback(+graph: FGraph, +sources: List<&2,FSource>, +validated: FResult) -> FPrefixLoad:
  match graph:
    case FGraph{book, error, done}:
      FPrefixLoad{FLoadTrace{fpe_graph_result(graph, sources, f_fresh_result(validated)), done, sources}, Nil{}, Nil{}, False{}}

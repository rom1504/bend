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

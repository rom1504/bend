# Exact call components over worker IR, independent of source/type analysis.
# Three words bound the graph to 96 functions. Warshall runs exactly n pivots;
# an invalid target, oversized graph or missing row fails instead of guessing.
type JWReach is Data:
  JWReach{+lo: U32, +mid: U32, +hi: U32}

@unsafe
def jw_graph_count(+functions: List<&2,JWFunction>, +at: U32) -> U32:
  match functions:
    case Nil{}: at
    case Con{f, rest}:
      kc(U32, U32.is_eq(at, 96), u => 97, u => jw_graph_count(rest, U32.inc(at)))

@unsafe
def jw_graph_mask(+at: U32) -> U32:
  jw_graph_shift(U32.mod(at, 32), 1)

@unsafe
def jw_graph_shift(+left: U32, +bit: U32) -> U32:
  kc(U32, U32.is_eq(left, 0), u => bit, u => jw_graph_shift(U32.sub(left, 1), U32.shl(bit)))

@unsafe
def jw_graph_bit(+at: U32, +mask: U32) -> JWReach:
  kc(JWReach, U32.is_lt(at, 32), u => JWReach{mask, 0, 0}, u =>
    kc(JWReach, U32.is_lt(at, 64), u => JWReach{0, mask, 0}, u => JWReach{0, 0, mask}))

@unsafe
def jw_graph_has(+row: JWReach, +at: U32, +mask: U32) -> Bool:
  match row:
    case JWReach{lo, mid, hi}:
      Bool.not(U32.is_eq(U32.and(mask, kc(U32, U32.is_lt(at, 32), u => lo,
        u => kc(U32, U32.is_lt(at, 64), u => mid, u => hi))), 0))

@unsafe
def jw_graph_union(+a: JWReach, +b: JWReach) -> JWReach:
  match a:
    case JWReach{al, am, ah}:
      match b:
        case JWReach{bl, bm, bh}: JWReach{U32.or(al, bl), U32.or(am, bm), U32.or(ah, bh)}

@unsafe
def jw_graph_edges(+code: List<&2,JWInstruction>, +total: U32, +row: JWReach) -> Maybe<&2,JWReach>:
  match code:
    case Nil{}: Some{row}
    case Con{JWDirectCall{slot, target, args}, rest}:
      kc(Maybe<&2,JWReach>, U32.is_lt(target, total),
        u => jw_graph_edges(rest, total, jw_graph_union(row, jw_graph_bit(target, jw_graph_mask(target)))), u => None{})
    case Con{JWCallValues{slots, target, args}, rest}:
      kc(Maybe<&2,JWReach>, U32.is_lt(target, total),
        u => jw_graph_edges(rest, total, jw_graph_union(row, jw_graph_bit(target, jw_graph_mask(target)))), u => None{})
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jw_graph_branches(jw_graph_edges(yes, total, row), no, rest, total)
    case Con{other, rest}: jw_graph_edges(rest, total, row)

@unsafe
def jw_graph_branches(+first: Maybe<&2,JWReach>, +no: List<&2,JWInstruction>, +rest: List<&2,JWInstruction>, +total: U32) -> Maybe<&2,JWReach>:
  match first:
    case None{}: None{}
    case Some{left}: jw_graph_resume(jw_graph_edges(no, total, left), rest, total)

@unsafe
def jw_graph_resume(+first: Maybe<&2,JWReach>, +rest: List<&2,JWInstruction>, +total: U32) -> Maybe<&2,JWReach>:
  match first:
    case None{}: None{}
    case Some{row}: jw_graph_edges(rest, total, row)

@unsafe
def jw_graph_rows(+functions: List<&2,JWFunction>, +total: U32, +at: U32) -> Maybe<&2,List<&2,JWReach>>:
  match functions:
    case Nil{}: Some{Nil{}}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(Maybe<&2,List<&2,JWReach>>, valid, u =>
        jw_graph_rows_next(jw_graph_edges(code, total, jw_graph_bit(at, jw_graph_mask(at))), rest, total, at), u => None{})

@unsafe
def jw_graph_rows_next(+first: Maybe<&2,JWReach>, +rest: List<&2,JWFunction>, +total: U32, +at: U32) -> Maybe<&2,List<&2,JWReach>>:
  match first:
    case None{}: None{}
    case Some{row}: jw_graph_rows_cons(row, jw_graph_rows(rest, total, U32.inc(at)))

@unsafe
def jw_graph_rows_cons(+row: JWReach, +more: Maybe<&2,List<&2,JWReach>>) -> Maybe<&2,List<&2,JWReach>>:
  match more:
    case None{}: None{}
    case Some{rows}: Some{Con{row, rows}}

@unsafe
def jw_graph_row(+rows: List<&2,JWReach>, +at: U32) -> Maybe<&2,JWReach>:
  match rows:
    case Nil{}: None{}
    case Con{row, rest}:
      kc(Maybe<&2,JWReach>, U32.is_eq(at, 0), u => Some{row}, u => jw_graph_row(rest, U32.sub(at, 1)))

@unsafe
def jw_graph_pivot(+rows: List<&2,JWReach>, +pivot: JWReach, +at: U32, +mask: U32) -> List<&2,JWReach>:
  match rows:
    case Nil{}: Nil{}
    case Con{row, rest}:
      Con{kc(JWReach, jw_graph_has(row, at, mask), u => jw_graph_union(row, pivot), u => row),
        jw_graph_pivot(rest, pivot, at, mask)}

@unsafe
def jw_graph_close(+rows: List<&2,JWReach>, +at: U32, +total: U32) -> Maybe<&2,List<&2,JWReach>>:
  kc(Maybe<&2,List<&2,JWReach>>, U32.is_eq(at, total), u => Some{rows}, u =>
    jw_graph_close_next(rows, jw_graph_row(rows, at), at, total))

@unsafe
def jw_graph_close_next(+rows: List<&2,JWReach>, +pivot: Maybe<&2,JWReach>, +at: U32, +total: U32) -> Maybe<&2,List<&2,JWReach>>:
  match pivot:
    case None{}: None{}
    case Some{row}: jw_graph_close(jw_graph_pivot(rows, row, at, jw_graph_mask(at)), U32.inc(at), total)

@unsafe
def jw_graph_min(+row: JWReach, +rows: List<&2,JWReach>, +node: U32, +mask: U32, +at: U32) -> Maybe<&2,U32>:
  match rows:
    case Nil{}: None{}
    case Con{other, rest}:
      kc(Maybe<&2,U32>, jw_graph_has(row, at, jw_graph_mask(at)) && jw_graph_has(other, node, mask),
        u => Some{at}, u => jw_graph_min(row, rest, node, mask, U32.inc(at)))

@unsafe
def jw_graph_labels(+all: List<&2,JWReach>, +rows: List<&2,JWReach>, +at: U32) -> Maybe<&2,List<&2,U32>>:
  match rows:
    case Nil{}: Some{Nil{}}
    case Con{row, rest}:
      jw_graph_labels_next(jw_graph_min(row, all, at, jw_graph_mask(at), 0), all, rest, at)

@unsafe
def jw_graph_labels_next(+first: Maybe<&2,U32>, +all: List<&2,JWReach>, +rest: List<&2,JWReach>, +at: U32) -> Maybe<&2,List<&2,U32>>:
  match first:
    case None{}: None{}
    case Some{label}: jw_graph_labels_cons(label, jw_graph_labels(all, rest, U32.inc(at)))

@unsafe
def jw_graph_labels_cons(+label: U32, +more: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match more:
    case None{}: None{}
    case Some{labels}: Some{Con{label, labels}}

@unsafe
def jw_components(+functions: List<&2,JWFunction>) -> Maybe<&2,List<&2,U32>>:
  +total = jw_graph_count(functions, 0)
  kc(Maybe<&2,List<&2,U32>>, U32.is_gt(total, 0) && U32.is_lt(total, 97), u =>
    jw_components_rows(jw_graph_rows(functions, total, 0), total), u => None{})

@unsafe
def jw_components_rows(+rows: Maybe<&2,List<&2,JWReach>>, +total: U32) -> Maybe<&2,List<&2,U32>>:
  match rows:
    case None{}: None{}
    case Some{graph}: jw_components_closed(jw_graph_close(graph, 0, total))

@unsafe
def jw_components_closed(+rows: Maybe<&2,List<&2,JWReach>>) -> Maybe<&2,List<&2,U32>>:
  match rows:
    case None{}: None{}
    case Some{closed}: jw_graph_labels(closed, closed, 0)

@unsafe
def jw_component_at(+labels: List<&2,U32>, +at: U32) -> U32:
  match labels:
    case Nil{}: 4294967295
    case Con{label, rest}:
      kc(U32, U32.is_eq(at, 0), u => label, u => jw_component_at(rest, U32.sub(at, 1)))

@unsafe
def jw_same_component(+labels: List<&2,U32>, +a: U32, +b: U32) -> Bool:
  +left = jw_component_at(labels, a)
  +right = jw_component_at(labels, b)
  Bool.not(U32.is_eq(left, 4294967295) || U32.is_eq(right, 4294967295)) && U32.is_eq(left, right)

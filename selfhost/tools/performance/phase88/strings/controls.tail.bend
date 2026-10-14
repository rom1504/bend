type P88StringCheck is Data:
  P88StringCheck{a: U32, b: U32, oldEq: U32, sharedEq: U32, ownedEq: U32, oldOrder: U32, sharedOrder: U32, ownedOrder: U32, lenA: U32, lenB: U32, sumA: U32, sumB: U32}

def p88_codes(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, t}: SCon{Char.from_u32(h), p88_codes(t)}

def p88_copy(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{h, t}: SCon{h, p88_copy(t)}

def p88_order_number(c: Cmp) -> U32:
  match c:
    case LT{}: 0
    case EQ{}: 1
    case GT{}: 2

def p88_length(s: String, n: U32) -> U32:
  match s:
    case SNil{}: n
    case SCon{h, t}: p88_length(t, U32.inc(n))

def p88_sum(s: String, n: U32) -> U32:
  match s:
    case SNil{}: n
    case SCon{h, t}: p88_sum(t, U32.add(n, Char.to_u32(h)))

def p88_check(i: U32, j: U32, +a: String, +b: String) -> P88StringCheck:
  old_eq = Bool.to_u32(String.eq(a, b))
  shared_eq = Bool.to_u32(p88_string_eq(a, b))
  owned_eq = Bool.to_u32(p88_string_eq(p88_copy(a), p88_copy(b)))
  old_order = p88_order_number(String.order(a, b))
  shared_order = p88_order_number(p88_string_order(a, b))
  owned_order = p88_order_number(p88_string_order(p88_copy(a), p88_copy(b)))
  P88StringCheck{i, j, old_eq, shared_eq, owned_eq, old_order, shared_order, owned_order, p88_length(a, 0), p88_length(b, 0), p88_sum(a, 0), p88_sum(b, 0)}

def p88_columns(+a: String, +i: U32, bs: List<&2, String>, +j: U32, acc: List<&2, P88StringCheck>) -> List<&2, P88StringCheck>:
  match bs:
    case Nil{}: acc
    case Con{+b, rest}: p88_columns(a, i, rest, U32.inc(j), Con{p88_check(i, j, a, b), acc})

def p88_rows(+all: List<&2, String>, rows: List<&2, String>, +i: U32, acc: List<&2, P88StringCheck>) -> List<&2, P88StringCheck>:
  match rows:
    case Nil{}: acc
    case Con{+a, rest}: p88_rows(all, rest, U32.inc(i), p88_columns(a, i, all, 0, acc))

def main() -> List<&2, P88StringCheck>:
  +words = p88_corpus()
  p88_rows(words, words, 0, Nil{})

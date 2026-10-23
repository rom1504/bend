import Base

# The scalar accumulator precedes the strings, matching Bend's binder-order
# rule. The original v01 parser failure is preserved as negative fixture data.
def p130s_order_go(order: Cmp, a: String, b: String) -> Cmp:
  match order:
    case LT{}: LT{}
    case GT{}: GT{}
    case EQ{}:
      match a b:
        case SNil{} SNil{}: EQ{}
        case SNil{} SCon{head,tail}: LT{}
        case SCon{head,tail} SNil{}: GT{}
        case SCon{ha,ta} SCon{hb,tb}:
          p130s_order_go(U32.cmp(Char.to_u32(ha),Char.to_u32(hb)),ta,tb)

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(EQ{},a,b)

# Ordinary source workload, identical in both variants except p130s_query.
def p130s_code(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

def p130s_prefix(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(955),p130s_prefix(rest)}

def p130s_pairs(+prefix: String) -> List<&2,String & String>:
  [(prefix,prefix),(prefix,prefix ++ "a"),(prefix ++ "a",prefix),
   (prefix ++ "λ",prefix ++ "中"),(prefix ++ "🙂",prefix ++ "λ"),
   (prefix ++ "same",prefix ++ "same"),(prefix,"!" ++ prefix),("!" ++ prefix,prefix),
   (SCon{Char.from_u32(0),prefix},SCon{Char.from_u32(1),prefix}),
   (prefix ++ SCon{Char.from_u32(57344),SNil{}},prefix ++ SCon{Char.from_u32(65536),SNil{}})]


def p130sc_compare(+a: String, +b: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p130s_code(String.order(a,b))))
    IO.print(U32.show(p130s_code(p130s_order(a,b))))

def p130sc_pair(pair: String & String) -> IO(Unit):
  (a,b) = pair
  p130sc_compare(a,b)

def p130sc_rows(pairs: List<&2,String & String>) -> IO(Unit):
  match pairs:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{pair,rest}:
      do IO<Unit>:
        Unit <- p130sc_pair(pair)
        p130sc_rows(rest)

def p130sc_long() -> IO(Unit):
  +a = p130s_prefix(16384n)
  +b = p130s_prefix(16384n)
  do IO<Unit>:
    Unit <- p130sc_compare(a,b)
    Unit <- p130sc_compare(a,a)
    Unit <- p130sc_compare(a,b ++ "🙂")
    Unit <- p130sc_compare(a ++ "中",b)
    IO.print(Nat.show(String.length(a)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- p130sc_rows(p130s_pairs(p130s_prefix(0n)))
    Unit <- p130sc_rows(p130s_pairs(p130s_prefix(1n)))
    Unit <- p130sc_rows(p130s_pairs(p130s_prefix(17n)))
    p130sc_long()

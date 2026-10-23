import Base

# Uses the structurally decreasing first String argument and the safe matched
# shape previously exercised in Phase89/equality/controls.bend. The accumulator
# follows the roots; a single ordered multi-match avoids v01's binder violation.
def p130s_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match a b order:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h,t} LT{}: LT{}
    case SNil{} SCon{h,t} EQ{}: LT{}
    case SNil{} SCon{h,t} GT{}: GT{}
    case SCon{h,t} SNil{} LT{}: LT{}
    case SCon{h,t} SNil{} EQ{}: GT{}
    case SCon{h,t} SNil{} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} LT{}: LT{}
    case SCon{ha,ta} SCon{hb,tb} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} EQ{}:
      p130s_order_go(ta,tb,U32.cmp(Char.to_u32(ha),Char.to_u32(hb)))

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(a,b,EQ{})

type P130SCase is Data:
  P130SCase{left: String, right: String}

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

def p130s_pairs(+prefix: String) -> List<&2,P130SCase>:
  [P130SCase{prefix,prefix},P130SCase{prefix,prefix ++ "a"},P130SCase{prefix ++ "a",prefix},
   P130SCase{prefix ++ "λ",prefix ++ "中"},P130SCase{prefix ++ "🙂",prefix ++ "λ"},
   P130SCase{prefix ++ "same",prefix ++ "same"},P130SCase{prefix,"!" ++ prefix},P130SCase{"!" ++ prefix,prefix},
   P130SCase{SCon{Char.from_u32(0),prefix},SCon{Char.from_u32(1),prefix}},
   P130SCase{prefix ++ SCon{Char.from_u32(57344),SNil{}},prefix ++ SCon{Char.from_u32(65536),SNil{}}}]


def p130sc_compare(+a: String, +b: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p130s_code(String.order(a,b))))
    IO.print(U32.show(p130s_code(p130s_order(a,b))))

def p130sc_pair(pair: P130SCase) -> IO(Unit):
  match pair:
    case P130SCase{a,b}: p130sc_compare(a,b)

def p130sc_rows(pairs: List<&2,P130SCase>) -> IO(Unit):
  match pairs:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{pair,rest}:
      do IO<Unit>:
        Unit <- p130sc_pair(pair)
        p130sc_rows(rest)

def p130sc_long() -> IO(Unit):
  +a : String = p130s_prefix(16384n)
  +b : String = p130s_prefix(16384n)
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

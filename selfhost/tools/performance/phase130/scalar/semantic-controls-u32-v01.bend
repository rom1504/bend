import Base

# Scalar-code discriminator. Roots stay structurally first and all state is
# nonowning. Two primitive predicates replace U32.cmp's enum transport.
def p130u_finish(same: Bool, less: Bool, ending: U32) -> U32:
  match same less:
    case True{} _: ending
    case False{} True{}: 1
    case False{} False{}: 3

def p130u_go(a: String, b: String, same: Bool, less: Bool) -> U32:
  match a b same:
    case SNil{} SNil{} equal:
      p130u_finish(equal,less,2)
    case SNil{} SCon{head,tail} equal:
      p130u_finish(equal,less,1)
    case SCon{head,tail} SNil{} equal:
      p130u_finish(equal,less,3)
    case SCon{ha,ta} SCon{hb,tb} False{}:
      p130u_finish(False{},less,2)
    case SCon{+ha,ta} SCon{+hb,tb} True{}:
      p130u_go(ta,tb,U32.is_eq(Char.to_u32(ha),Char.to_u32(hb)),
        U32.is_lt(Char.to_u32(ha),Char.to_u32(hb)))

def p130u_order(a: String, b: String) -> U32:
  p130u_go(a,b,True{},False{})

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
    IO.print(U32.show(p130u_order(a,b)))

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

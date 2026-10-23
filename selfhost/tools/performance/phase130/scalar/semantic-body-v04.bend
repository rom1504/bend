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

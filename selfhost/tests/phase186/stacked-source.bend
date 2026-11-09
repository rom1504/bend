import Base

def repeat.shared(n: Nat, +shared: String, tail: String) -> String:
  match n:
    case 0n: tail
    case 1n+p:
      String.append(shared, String.append("|", repeat.shared(p, shared, tail)))

def alternate.shared(n: Nat, odd: Bool, +shared: String) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p:
      match odd:
        case True{}:
          String.append(shared, String.append("!", alternate.shared(p, False{}, shared)))
        case False{}:
          String.append("?", alternate.shared(p, True{}, shared))

def main() -> IO(Unit):
  do IO<Unit>:
    +shared = String.append(U32.show(17), "x")
    Unit <- IO.print(repeat.shared(3n, shared, "z"))
    Unit <- IO.print(repeat.shared(0n, shared, "zero"))
    IO.print(alternate.shared(4n, True{}, shared))

#| 17x|17x|17x|z
#| zero
#| 17x!?17x!?

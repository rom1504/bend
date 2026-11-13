import Base

# Adapted from the independently retained Phase186 stacked-source shape.
# The shared heap string is captured repeatedly and read again after return.
def recur.sharing.repeat(n: Nat, +shared: String, tail: String) -> String:
  match n:
    case 0n: tail
    case 1n+p:
      String.append(shared, String.append("|", recur.sharing.repeat(p, shared, tail)))

def recur.sharing.alternate(n: Nat, odd: Bool, +shared: String) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p:
      match odd:
        case True{}:
          String.append(shared, String.append("!", recur.sharing.alternate(p, False{}, shared)))
        case False{}:
          String.append("?", recur.sharing.alternate(p, True{}, shared))

def main() -> IO(Unit):
  do IO<Unit>:
    +shared = String.append(U32.show(73), "q")
    Unit <- IO.print(recur.sharing.repeat(0n, shared, "zero"))
    Unit <- IO.print(recur.sharing.repeat(4n, shared, "end"))
    Unit <- IO.print(recur.sharing.alternate(5n, True{}, shared))
    IO.print(shared)
#| zero
#| 73q|73q|73q|73q|end
#| 73q!?73q!?73q!
#| 73q

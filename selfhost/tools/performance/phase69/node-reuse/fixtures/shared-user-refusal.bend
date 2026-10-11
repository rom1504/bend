import Base

type Branch is Data:
  Tip{value: Nat}
  Fork{left: Branch, right: Branch}

def sum(t: Branch) -> Nat:
  match t:
    case Tip{x}: x
    case Fork{a, b}: Nat.add(sum(a), sum(b))

def main() -> Nat:
  +t = Fork{Tip{3n}, Fork{Tip{5n}, Tip{7n}}}
  Nat.add(sum(t), sum(t))

#|30n

import Base

type Branch is Data:
  Tip{value: Nat}
  Fork{left: Branch, right: Branch}

def sum(t: Branch) -> Nat:
  match t:
    case Tip{x}: x
    case Fork{a, b}: Nat.add(sum(a), sum(b))

def rotate(a: Branch, b: Branch) -> Branch:
  match a b:
    case Fork{a0, a1} Fork{b0, b1}: Fork{Fork{a0, b0}, Fork{a1, b1}}
    case Fork{a0, a1} Tip{x}: Fork{a0, Fork{a1, Tip{x}}}
    case Tip{x} Fork{b0, b1}: Fork{Tip{x}, Fork{b0, b1}}
    case Tip{x} Tip{y}: Fork{Tip{x}, Tip{y}}

def main() -> Nat:
  sum(rotate(Fork{Tip{3n}, Tip{5n}}, Fork{Tip{7n}, Tip{11n}}))

#|26n

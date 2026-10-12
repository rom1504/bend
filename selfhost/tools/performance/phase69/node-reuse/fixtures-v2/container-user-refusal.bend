import Base

type Branch is Data:
  Tip{value: Nat}
  Fork{left: Branch, right: Branch}

def make(+n: Nat) -> Branch:
  Fork{Tip{n}, Tip{Nat.add(n, 1n)}}

def sum(t: Branch) -> Nat:
  match t:
    case Tip{x}: x
    case Fork{a, b}: Nat.add(sum(a), sum(b))

def total(xs: List<&2, Branch>) -> Nat:
  match xs:
    case Nil{}: 0n
    case Con{h, rest}: Nat.add(sum(h), total(rest))

# A trusted Base List must not hide the shared user ADTs in its elements.
def main() -> Nat:
  +xs : List<&2, Branch> = [make(5n), make(7n)]
  Nat.add(total(xs), total(xs))

#|52n

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

# List is a trusted Base constructor, but its user ADT parameter must disqualify
# the entire program when this list is duplicated.
def main() -> Nat:
  +xs = [make(5n), make(7n)]
  Nat.add(total(xs), total(xs))

#|52n

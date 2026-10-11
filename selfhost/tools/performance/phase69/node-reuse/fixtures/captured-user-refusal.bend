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

# The parent is used once in the lambda syntax, but duplicating the closure
# duplicates its capture transitively. Functions must remain opaque to the
# array-free exception in the no-sharing certificate.
def delayed(+t: Branch) -> Nat -> Nat:
  n => Nat.add(sum(t), n)

def main() -> Nat:
  +f = delayed(make(5n))
  Nat.add(f(1n), f(2n))

#|25n

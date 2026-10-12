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

# A function is affine: copying the closure itself is not well typed.
# Instead copy the dynamic user parent inside the single closure body.
# The no-sharing certificate must inspect captured uses under lambdas.
def delayed(+t: Branch) -> Nat -> Nat:
  n => Nat.add(sum(t), Nat.add(sum(t), n))

def main() -> Nat:
  f = delayed(make(5n))
  f(3n)

#|25n

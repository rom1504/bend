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

# The constructor depends on a function parameter so static literal lifting
# cannot make the sharing test vacuous merely by interning the source tree.
def main() -> Nat:
  +t = make(5n)
  Nat.add(sum(t), sum(t))

#|22n

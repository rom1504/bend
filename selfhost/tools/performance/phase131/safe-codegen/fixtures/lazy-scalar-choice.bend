import Base

def overflow(n: Nat) -> Nat:
  1n+n

def fallback(value: Nat, tail: Unit -> Nat, order: Cmp) -> Nat:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 0n

# The dangerous literal callback must remain delayed and unselected.
def main() -> Nat:
  fallback(7n,u => overflow(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n))),EQ{})

#|7

import Base

def overflow(n: Nat) -> Nat:
  1n+n

def fallback(value: Nat, tail: Unit -> Nat, order: Cmp) -> Nat:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 0n

# The first nonliteral argument is strict even when GT returns the constant.
# Native execution must preserve the original overflow failure, not print zero.
def main() -> Nat:
  fallback(overflow(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n))),u => 7n,GT{})

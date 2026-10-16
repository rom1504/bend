import Base

# The first actual is strict despite being unused. Substituting it away would
# remove the native Nat overflow error. Literal branch bodies remain delayed.
def strict_select(ignored: Nat, +flag: Bool, yes: Unit -> Nat, no: Unit -> Nat) -> Nat:
  match flag:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def overflow(n: Nat) -> Nat:
  1n+n

def main() -> Nat:
  strict_select(overflow(281474976710655n), True{}, u => 7n, u => 9n)

# Native execution must retain the baseline overflow failure; no success oracle.

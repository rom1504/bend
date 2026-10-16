import Base

# An admitted prefix must remain private if a later iteration fails.
def partial_then_fail(n: Nat, value: Nat) -> List<&2, Nat>:
  match n:
    case 0n: Con{1n+value, Nil{}}
    case Succ{+rest}: Con{1n+rest, partial_then_fail(rest, value)}

def main() -> List<&2, Nat>:
  partial_then_fail(1000n, Nat.add(Nat.pow(2n, 47n), Nat.sub(Nat.pow(2n, 47n), 1n)))

# Native execution must match the baseline Nat overflow exit/stdout/stderr.
# A successful printed list is a failure. This checks late failure, not leak size.

import Base

# This user name normalizes to the builtin Nat.add key in C emission.
# Source provenance must keep its own implementation.
def nat_add(a: Nat, b: Nat) -> Nat:
  a

def main() -> Nat:
  nat_add(3n, 4n)

#|3n

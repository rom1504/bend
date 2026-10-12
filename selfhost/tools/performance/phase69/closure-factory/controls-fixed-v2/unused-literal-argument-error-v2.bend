# The combinator is linear, but its literal f ignores its argument.
# CBV still evaluates g(x); substituting with core_rebuild would erase it.
import Base

def after(f: Nat -> U32, g: U32 -> Nat, x: U32) -> U32:
  f(g(x))

def overflow(n: U32) -> Nat:
  +value = {n : U32}
  Nat.mul(U32.to_nat(value), U32.to_nat(value))

def main() -> U32:
  f = {after(y => 0, overflow) : U32 -> U32}
  f(16777216)

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1

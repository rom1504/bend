# Inlining an outer literal must not normalize away the inner application's
# argument. Native beta must sequence the overflowing Nat before discarding it.
import Base

def before(f: U32 -> U32, g: U32 -> U32, x: U32) -> U32:
  g(f(x))

def overflow(+n: U32) -> Nat:
  Nat.mul(U32.to_nat(n), U32.to_nat(n))

def main() -> U32:
  f = {before(x => {(y => 0) : Nat -> U32}(overflow(x)), x => x) : U32 -> U32}
  f(16777216)

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1

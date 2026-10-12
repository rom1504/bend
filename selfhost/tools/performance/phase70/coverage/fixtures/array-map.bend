# Phase70 adapter of tests/run/array_map_loop.bend. The original map/convert/fold
# functions are imported unchanged. Input generation varies length and seed.
import Base
import ../../../../../../tests/run/array_map_loop.bend as A

def fill(n: Nat, +i: U32, +seed: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+p:
      fill(p, U32.inc(i), seed, Array.set(U32, a, i, U32.add(seed, U32.mul(i, 3))))

def bench(size: U32, +seed: U32) -> U32:
  A.sum(A.ones(A.big(fill(U32.to_nat(size), 0, seed, [seed : U32*1024n]))))

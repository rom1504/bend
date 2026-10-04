# A tail-only component entered beneath pending non-tail continuations.
import Base

def exhausted.keep(-T: Type, value: T) -> T:
  value

@unsafe
def exhausted.drain(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest: exhausted.drain(rest, U32.add(seed, 7))

@unsafe
def exhausted.layers(n: Nat, tail: Nat, +seed: U32) -> U32:
  match n:
    case 0n: exhausted.drain(tail, seed)
    case 1n+rest:
      answer = exhausted.layers(rest, tail, U32.add(seed, 3))
      U32.add(answer, U32.xor(seed, 85))

def bench(depth: U32, tail: U32, seed: U32) -> U32:
  exhausted.keep(U32, exhausted.layers(U32.to_nat(depth), U32.to_nat(tail), seed))

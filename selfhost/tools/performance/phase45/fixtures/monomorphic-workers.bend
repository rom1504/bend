# First-order aliases only: no erased conduit and no benchmark-name admission.
import Base

@unsafe
def cedar(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest:
      answer = elm(rest, U32.add(seed, 3))
      U32.sub(U32.mul(answer, 5), seed)

@unsafe
def elm(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: U32.add(seed, 11)
    case 1n+rest:
      answer = cedar(rest, U32.add(seed, 7))
      U32.add(answer, U32.mul(seed, 9))

@unsafe
def brook(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest: creek(rest, U32.add(seed, 2))

@unsafe
def creek(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: U32.add(seed, 13)
    case 1n+rest: brook(rest, U32.add(seed, 6))

def bench(size: U32, seed: U32) -> U32:
  cedar(U32.to_nat(size), seed)

def tail_check(size: U32, seed: U32) -> U32:
  brook(U32.to_nat(size), seed)

def plain_literal() -> U32:
  19

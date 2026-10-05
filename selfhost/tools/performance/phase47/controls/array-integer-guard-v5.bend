import Base

def sieve.quotient(numerator: U32, divisor: U32) -> U32:
  +answer: U32 = U32.div(numerator, divisor)
  answer

def sieve.write(+i: U32, total: U32, divisor: U32,
                pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, old) = pair
  +next = sieve.quotient(U32.add(U32.add(total, old), U32.inc(i)), divisor)
  (Array.set(U32, a, i, next), next)

def sieve.cell(+i: U32, divisor: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  (a, total) = state
  sieve.write(i, total, divisor, Array.get(U32, a, i))

def sieve.loop(+n: Nat, +i: U32, +divisor: U32,
               state: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n: state
    case 1n+p: sieve.loop(p, U32.inc(i), divisor, sieve.cell(i, divisor, state))

def sieve.finish(state: Array<U32> & U32) -> U32:
  (a, total) = state
  total

def integer(turns: U32, seed: U32, divisor: U32) -> U32:
  sieve.finish(sieve.loop(U32.to_nat(turns), 0, divisor,
    (Array.new(U32, 2n, seed), 0)))

# An unused input still participates in the canonical F32 entry predicate.
def floating(turns: U32, seed: U32, divisor: U32, ignored: F32) -> U32:
  integer(turns, seed, divisor)

def Haze() -> Type:
  F32

def aliased(turns: U32, seed: U32, divisor: U32, ignored: Haze) -> U32:
  integer(turns, seed, divisor)

def binary(+depth: Nat, +turns: U32, +seed: U32, +divisor: U32) -> U32:
  match depth:
    case 0n: integer(turns, seed, divisor)
    case 1n+p:
      left right = binary(p, turns, seed, divisor) binary(p, turns, U32.inc(seed), divisor)
      U32.add(left, right)

def plain(numerator: U32, divisor: U32) -> U32:
  sieve.quotient(numerator, divisor)

def sieve.callback_read(divisor: U32, pair: Array<U32> & U32) -> U32:
  (a, numerator) = pair
  sieve.quotient(numerator, divisor)

# The callback is evaluated before the public read and division. It may replace
# floor, install floating hooks, reenter a scalar root, or throw.
def public_callback(a: Array<U32>, callback: U32 -> U32) -> U32:
  sieve.callback_read(callback(3), Array.get(U32, a, 0))

def bench(turns: U32, seed: U32) -> U32:
  integer(turns, seed, 3)

def main() -> U32:
  bench(9, 17)

# Independent known captured functions. Materialized composition is retained.
import Base

law combine:
  for -A: Type
  for -B: Type
  for -C: Type
  for f: A -> B
  for g: B -> C
  A -> C

def combine(A, B, C, f, g):
  x => g(f(x))

law affine_factory:
  for +n: Nat
  U32 -> U32

def affine_factory(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(1, U32.from_nat(p))
      combine(U32, U32, U32, x => U32.add(U32.mul(x, k), 3), affine_factory(p))

law reverse_factory:
  for +n: Nat
  U32 -> U32

def reverse_factory(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(1, U32.from_nat(p))
      combine(U32, U32, U32, x => U32.sub(k, x), reverse_factory(p))

def affine_result(size: U32, seed: U32) -> U32:
  affine_factory(U32.to_nat(size))(seed)

def reverse_result(size: U32, seed: U32) -> U32:
  reverse_factory(U32.to_nat(size))(seed)

# Same six lambda positions, but its prefix is live q2 U32, never erased Type.
# The callback source proof must refuse this factory/root, even when values agree.
law live_combine:
  for +first: U32
  for +second: U32
  for +third: U32
  for f: U32 -> U32
  for g: U32 -> U32
  U32 -> U32

def live_combine(first, second, third, f, g):
  x => g(f(x))

law live_factory:
  for +n: Nat
  U32 -> U32

def live_factory(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(1, U32.from_nat(p))
      live_combine(0, 0, 0, x => U32.add(x, k), live_factory(p))

def live_result(size: U32, seed: U32) -> U32:
  live_factory(U32.to_nat(size))(seed)

# Changed capture depends on seed and is outside the first factory signature.
# It must not be folded into a stale single scalar slot.
law seeded_factory:
  for +n: Nat
  for +seed: U32
  U32 -> U32

def seeded_factory(n, seed):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(seed, U32.from_nat(p))
      combine(U32, U32, U32, x => U32.sub(k, x), seeded_factory(p, U32.add(seed, 1)))

def seeded_result(size: U32, +seed: U32) -> U32:
  seeded_factory(U32.to_nat(size), seed)(seed)

# Retaining a returned callback crosses the private scalar boundary.
def retained(size: U32) -> U32 -> U32:
  affine_factory(U32.to_nat(size))

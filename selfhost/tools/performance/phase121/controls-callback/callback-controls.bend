# Ordinary renamed closure controls. Captures and leaves use different,
# wrap-heavy arithmetic; descending composition order is observable.
import Base

law link:
  for -A: Type
  for -B: Type
  for -C: Type
  for f: A -> B
  for g: B -> C
  A -> C

def link(A, B, C, f, g):
  x => g(f(x))

law braid:
  for +n: Nat
  U32 -> U32

def braid(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(U32.mul(U32.from_nat(p), 4294967291), 7)
      link(U32, U32, U32, x => U32.add(U32.mul(x, 33), k), braid(p))

def braided(size: U32, seed: U32) -> U32:
  braid(U32.to_nat(size))(seed)

# A returned function is an ordinary supported source value. The new scalar
# root optimization must refuse this escaping boundary.
def escaped(size: U32) -> U32 -> U32:
  braid(U32.to_nat(size))

def through_escaped(size: U32, seed: U32) -> U32:
  escaped(size)(seed)

# This reverse composition is well typed: f takes B to C and g takes A to B.
# At U32 it has the same scalar function types but the opposite application
# order. A matcher that checks names/signatures alone would miscompile it.
law link_back:
  for -A: Type
  for -B: Type
  for -C: Type
  for f: B -> C
  for g: A -> B
  A -> C

def link_back(A, B, C, f, g):
  x => f(g(x))

law braid_back:
  for +n: Nat
  U32 -> U32

def braid_back(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(U32.mul(U32.from_nat(p), 4294967291), 7)
      link_back(U32, U32, U32, x => U32.add(U32.mul(x, 33), k), braid_back(p))

def backwards(size: U32, seed: U32) -> U32:
  braid_back(U32.to_nat(size))(seed)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(braided(0, 0)))
    Unit <- IO.print(U32.show(through_escaped(0, 0)))
    Unit <- IO.print(U32.show(backwards(0, 0)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(braided(0, 1)))
    Unit <- IO.print(U32.show(through_escaped(0, 1)))
    Unit <- IO.print(U32.show(backwards(0, 1)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(braided(0, 4294967295)))
    Unit <- IO.print(U32.show(through_escaped(0, 4294967295)))
    Unit <- IO.print(U32.show(backwards(0, 4294967295)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(braided(1, 0)))
    Unit <- IO.print(U32.show(through_escaped(1, 0)))
    Unit <- IO.print(U32.show(backwards(1, 0)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(braided(1, 1)))
    Unit <- IO.print(U32.show(through_escaped(1, 1)))
    Unit <- IO.print(U32.show(backwards(1, 1)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(braided(1, 4294967295)))
    Unit <- IO.print(U32.show(through_escaped(1, 4294967295)))
    Unit <- IO.print(U32.show(backwards(1, 4294967295)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(braided(2, 0)))
    Unit <- IO.print(U32.show(through_escaped(2, 0)))
    Unit <- IO.print(U32.show(backwards(2, 0)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(braided(2, 1)))
    Unit <- IO.print(U32.show(through_escaped(2, 1)))
    Unit <- IO.print(U32.show(backwards(2, 1)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(braided(2, 4294967295)))
    Unit <- IO.print(U32.show(through_escaped(2, 4294967295)))
    Unit <- IO.print(U32.show(backwards(2, 4294967295)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(braided(17, 0)))
    Unit <- IO.print(U32.show(through_escaped(17, 0)))
    Unit <- IO.print(U32.show(backwards(17, 0)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(braided(17, 1)))
    Unit <- IO.print(U32.show(through_escaped(17, 1)))
    Unit <- IO.print(U32.show(backwards(17, 1)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(braided(17, 4294967295)))
    Unit <- IO.print(U32.show(through_escaped(17, 4294967295)))
    Unit <- IO.print(U32.show(backwards(17, 4294967295)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(braided(257, 0)))
    Unit <- IO.print(U32.show(through_escaped(257, 0)))
    Unit <- IO.print(U32.show(backwards(257, 0)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(braided(257, 1)))
    Unit <- IO.print(U32.show(through_escaped(257, 1)))
    Unit <- IO.print(U32.show(backwards(257, 1)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(braided(257, 4294967295)))
    Unit <- IO.print(U32.show(through_escaped(257, 4294967295)))
    IO.print(U32.show(backwards(257, 4294967295)))

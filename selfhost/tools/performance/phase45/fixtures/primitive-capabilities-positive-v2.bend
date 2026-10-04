# Independent positive-arity roots exercise all-branch primitive provenance.
# Nat loop construction/matching also exercises the private Number-Nat graph.
import Base

def chroma.keep(-T: Type, value: T) -> T:
  value

def chroma.route(+v: U32, test: Bool) -> U32:
  match test:
    case False{}:
      U32.add(U32.mul(v, 3), 1)
    case True{}:
      U32.sub(U32.xor(v, 31), 7)

def chroma.walk(n: Nat, +v: U32) -> U32:
  match n:
    case 0n:
      v
    case 1n+p:
      chroma.walk(p, chroma.route(v, U32.is_zero(v)))

def viridian(seed: U32) -> U32:
  chroma.keep(U32, chroma.walk(7n, seed))

def amber(seed: U32) -> U32:
  chroma.keep(U32, chroma.walk(2n, seed))

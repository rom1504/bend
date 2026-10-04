# Independent renamed nullary roots exercise all-branch primitive provenance.
import Base

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

def verdant() -> U32:
  chroma.walk(7n, 17)

def ochre() -> U32:
  chroma.walk(2n, 0)

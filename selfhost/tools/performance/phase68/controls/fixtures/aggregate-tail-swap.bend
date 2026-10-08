# A record crosses a partial callback, tail argument permutation, return,
# and a shared local. Three swaps: (4,9)->(9,5)->(5,10)->(10,6).
# score=1006; two surviving uses produce 1006*1000 + 1006 = 1007006.
import Base

type Pair68 is Data:
  Pair68{a: U32, b: U32}

def twist68(n: Nat, p: Pair68) -> Pair68:
  match n:
    case 0n:
      p
    case 1n+rest:
      match p:
        case Pair68{a, b}:
          twist68(rest, Pair68{b, U32.add(a, 1)})

def apply_pair68(f: Pair68 -> Pair68, p: Pair68) -> Pair68:
  f(p)

def score68(p: Pair68) -> U32:
  match p:
    case Pair68{a, b}:
      U32.add(U32.mul(a, 100), b)

def main() -> U32:
  +p = apply_pair68(twist68(3n), Pair68{4, 9})
  U32.add(U32.mul(score68(p), 1000), score68(p))

#|1007006

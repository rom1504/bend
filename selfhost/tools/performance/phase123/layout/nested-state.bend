# Independent result: three increments wrap MAX-1 to 1, count7 to10.
# Final list [0,MAX,MAX-1,10,20] sums to27 modulo2^32; shared original sums30.
import Base

def sum123(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case h <> t: sum123(t, U32.add(acc, h))

def len123(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case h <> t: U32.add(1, len123(t))

def advance123(n: Nat, state: U32 & U32 & List<&2, U32>) -> U32 & U32 & List<&2, U32>:
  match n:
    case 0n: state
    case 1n+p:
      (+cur, count, acc) = state
      advance123(p, (U32.add(cur, 1), U32.add(count, 1), cur <> acc))

def main() -> U32 & U32 & U32 & U32 & U32:
  +initial = [10, 20]
  (cur, count, +final) = advance123(3n, (4294967294, 7, initial))
  (cur, count, len123(final), sum123(final, 0), sum123(initial, 0))

#|(1, 10, 5, 27, 30)

import Base

def Counter() -> Data:
  Nat

@unsafe
def left(n: Counter, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: right(p, U32.add(acc, 1), 7)

@unsafe
def right(n: Counter, acc: U32, pad: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: left(p, U32.add(acc, pad))

def probe(n: Nat) -> U32:
  left(n, 0)

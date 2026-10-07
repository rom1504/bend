import Base

def Counter() -> Data:
  Nat

law left:
  for n: Counter
  for acc: U32
  U32

law right:
  for n: Counter
  for acc: U32
  for pad: U32
  U32

def left(n, acc):
  match n:
    case 0n: acc
    case 1n+p: right(p, U32.add(acc, 1), 7)

def right(n, acc, pad):
  match n:
    case 0n: acc
    case 1n+p: left(p, U32.add(acc, pad))

def probe(n: Nat) -> U32:
  left(n, 0)

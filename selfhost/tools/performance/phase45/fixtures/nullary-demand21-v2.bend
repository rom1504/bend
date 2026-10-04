# Independent nullary contextual-entry ABI, demand and reentry controls.
# This is untimed correctness input; no timed program names are recognized.
import Base

def demand.keep(-T: Type, value: T) -> T:
  value

def demand.step(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest: demand.step(rest, U32.inc(seed))

def demand.left() -> U32:
  demand.step(2n, 7)

def demand.right() -> U32:
  demand.step(1n, 3)

def demand.word() -> String:
  String.append("α", "β")

def bench() -> U32:
  demand.keep(U32, U32.sub(U32.mul(demand.left(), 10), demand.left()))

def ordered() -> U32:
  demand.keep(U32, U32.sub(demand.left(), demand.right()))

def text() -> String:
  demand.keep(String, String.append(demand.word(), demand.word()))

type Coin is Data:
  Coin{+face: U32}

def demand.coin() -> Coin:
  Coin{demand.left()}

def coin.value(value: Coin) -> U32:
  match value:
    case Coin{face}: face

def inside() -> U32:
  demand.keep(U32, U32.add(coin.value(demand.coin()), coin.value(demand.coin())))

# Unsupported public results and graph-free literals retain ordinary fn0.
def returned() -> Coin:
  demand.keep(Coin, demand.coin())

def returned_closure() -> U32 -> U32:
  value => U32.add(value, demand.left())

def action() -> IO(Unit):
  IO.print("nullary action must not execute during import")

def plain() -> U32:
  7

def positive(value: U32) -> U32:
  U32.add(value, demand.left())

# Build the largest supported Nat from compact U32-sized literals, then fail
# through the source successor operation. No injected diagnostic throw.
def overflow() -> Nat:
  +n0: Nat = 4294967295n
  +n1 = Nat.add(n0, n0)
  +n2 = Nat.add(n1, n1)
  +n3 = Nat.add(n2, n2)
  +n4 = Nat.add(n3, n3)
  +n5 = Nat.add(n4, n4)
  +n6 = Nat.add(n5, n5)
  +n7 = Nat.add(n6, n6)
  +n8 = Nat.add(n7, n7)
  +n9 = Nat.add(n8, n8)
  +n10 = Nat.add(n9, n9)
  +n11 = Nat.add(n10, n10)
  +n12 = Nat.add(n11, n11)
  +n13 = Nat.add(n12, n12)
  +n14 = Nat.add(n13, n13)
  +n15 = Nat.add(n14, n14)
  +n16 = Nat.add(n15, n15)
  +largest = Nat.add(n16, 65535n)
  demand.keep(Nat, Succ{largest})

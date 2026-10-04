# Independent demand/order controls for computed zero-argument definitions.
import Base

def demand.left() -> U32:
  U32.add(7, 2)

def demand.right() -> U32:
  U32.sub(7, 3)

def demand.word() -> String:
  String.append("α", "β")

def bench() -> U32:
  U32.sub(U32.mul(demand.left(), 10), demand.left())

def ordered() -> U32:
  U32.sub(demand.left(), demand.right())

def text() -> String:
  String.append(demand.word(), demand.word())

type Coin is Data:
  Coin{+face: U32}

def demand.coin() -> Coin:
  Coin{demand.left()}

def coin.value(value: Coin) -> U32:
  match value:
    case Coin{face}: face

def inside() -> U32:
  U32.add(coin.value(demand.coin()), coin.value(demand.coin()))

# These public boundaries remain outside the new nullary scalar/String entry.
def returned() -> Coin:
  demand.coin()

def positive(value: U32) -> U32:
  U32.add(value, demand.left())

# An already admitted positive-arity root for native-error unwind controls.
def demand.keep(-T: Type, value: T) -> T:
  value

def demand.descend(n: Nat, seed: Nat) -> Nat:
  match n:
    case 0n: Nat.add(seed, 1n)
    case 1n+rest: demand.descend(rest, seed)

def error_check(seed: Nat) -> Nat:
  demand.keep(Nat, demand.descend(1n, seed))

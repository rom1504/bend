import Base

def carry(-T: Type, value: T) -> T:
  value

type Beacon is Data:
  Lantern{left: U32, right: U32}
  Pebble{value: U32}

type Measure is Data:
  Measured{value: U32, checked: Nat}

def prism.pair(+x: U32) -> U32 & U32:
  (U32.add(x, 1), U32.mul(x, 3))

def prism.score(pair: U32 & U32) -> U32:
  (a, b) = pair
  U32.xor(a, b)

def prism.step(x: U32) -> U32:
  prism.score(prism.pair(x))

def prism.walk(+n: Nat, seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+p: prism.walk(p, prism.step(seed))

def bench(n: U32, seed: U32) -> U32:
  carry(U32, prism.walk(U32.to_nat(n), seed))

def prism.make(+x: U32) -> Beacon:
  Lantern{U32.add(x, 2), U32.add(x, 7)}

# The first projected field has two users; it must not be recomputed twice.
def prism.read(value: Beacon) -> U32:
  match value:
    case Lantern{a, b}: U32.add(U32.add(a, a), b)
    case Pebble{x}: U32.xor(x, 85)

def tagged(x: U32) -> U32:
  carry(U32, prism.read(prism.make(x)))

def mismatch(x: U32) -> U32:
  carry(U32, prism.read(Pebble{x}))

# Distinct arms reuse source spellings; generated slot numbers may also repeat.
def branch(flag: Bool, +x: U32) -> U32:
  match flag:
    case True{}:
      +saved = U32.add(x, 3)
      carry(U32, prism.read(prism.make(saved)))
    case False{}:
      +saved = U32.xor(x, 9)
      carry(U32, prism.read(Pebble{saved}))

def prism.checked(+x: U32, n: Nat) -> Measure:
  Measured{x, Nat.add(n, 1n)}

# Dropping the unused field's computation would lose checked overflow.
def prism.first(value: Measure) -> U32:
  match value:
    case Measured{x, ignored}: x

def checked_field(x: U32, n: Nat) -> U32:
  carry(U32, prism.first(prism.checked(x, n)))

def signal.left(x: U32) -> U32:
  U32.add(x, 11)

def signal.right(x: U32) -> U32:
  U32.add(x, 23)

def signal.make(+x: U32) -> Beacon:
  Lantern{signal.left(x), signal.right(x)}

def ordered(x: U32) -> U32:
  carry(U32, prism.read(signal.make(x)))

# Public constructor and tuple shape/field values remain part of the ABI.
def public_record(x: U32) -> Beacon:
  carry(Beacon, prism.make(x))

def public_pair(x: U32) -> U32 & U32:
  carry(U32 & U32, prism.pair(x))

def public_consume(value: Beacon) -> U32:
  prism.read(value)

def main() -> U32:
  bench(5, 3)

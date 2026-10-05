import Base

def shelter(-T: Type, value: T) -> T:
  value

def stream.make(n: Nat, +seed: U32) -> List<&2,U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: U32.mod(seed, 5) <> stream.make(p, U32.add(seed, 1))

def parcel.step(+current: U32, +head: U32, +count: U32,
  +saved: List<&2,U32 & U32>, same: Bool) -> U32 & U32 & List<&2,U32 & U32>:
  match same:
    case True{}: (current, U32.add(count, 1), saved)
    case False{}: (head, 1, (count, current) <> saved)

def parcel.walk(xs: List<&2,U32>, state: U32 & U32 & List<&2,U32 & U32>) -> List<&2,U32 & U32>:
  match xs:
    case Nil{}:
      (current, count, saved) = state
      (count, current) <> saved
    case Con{head0, tail}:
      (current0, count, saved) = state
      +head = head0
      +current = current0
      parcel.walk(tail, parcel.step(current, head, count, saved, U32.is_eq(current, head)))

def parcel.length(xs: List<&2,U32 & U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{pair, tail}: U32.add(1, parcel.length(tail))

def parcel.sum(xs: List<&2,U32 & U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{pair, tail}:
      (count, value) = pair
      U32.add(U32.mul(count, value), parcel.sum(tail))

def parcel.run(n: U32, +seed: U32) -> U32:
  +encoded = parcel.walk(stream.make(U32.to_nat(n), seed), (U32.mod(seed, 5), 0, Nil{}))
  U32.add(U32.mul(parcel.length(encoded), 1009), parcel.sum(encoded))

def bench(n: U32, seed: U32) -> U32:
  shelter(U32, parcel.run(n, seed))

# Non-tail recursion retains a caller frame while a private pair producer
# returns through the explicit scalar protocol after that continuation resumes.
def tower.pair(+x: U32) -> U32 & U32:
  (x, U32.add(x, 1))

def tower.read(pair: U32 & U32) -> U32:
  (a0, b) = pair
  +a = a0
  U32.xor(U32.add(a, a), b)

def tower.walk(n: Nat, +x: U32) -> U32:
  match n:
    case 0n: tower.read(tower.pair(x))
    case 1n+p:
      U32.add(tower.walk(p, U32.add(x, 1)), tower.read(tower.pair(x)))

def deep(n: U32, x: U32) -> U32:
  shelter(U32, tower.walk(U32.to_nat(n), x))

type Cabinet is Data:
  Drawer{+a: U32, b: U32}

def cabinet.make(+x: U32) -> Cabinet & U32:
  (Drawer{U32.add(x, 2), U32.add(x, 7)}, U32.mul(x, 3))

def cabinet.read(pair: Cabinet & U32) -> U32:
  (box, score) = pair
  match box:
    case Drawer{a, b}: U32.add(U32.add(a, a), U32.add(b, score))

def record(x: U32) -> U32:
  shelter(U32, cabinet.read(cabinet.make(x)))

def checked.make(x: U32, n: Nat) -> U32 & Nat:
  (x, Nat.add(n, 1n))

def checked.first(pair: U32 & Nat) -> U32:
  (x, ignored) = pair
  x

def checked_field(x: U32, n: Nat) -> U32:
  shelter(U32, checked.first(checked.make(x, n)))

def signal.left(x: U32) -> U32:
  U32.add(x, 11)

def signal.right(x: U32) -> U32:
  U32.add(x, 23)

def signal.pair(+x: U32) -> U32 & U32:
  (signal.left(x), signal.right(x))

def ordered(x: U32) -> U32:
  shelter(U32, tower.read(signal.pair(x)))

def cabinet.box(pair: Cabinet & U32) -> Cabinet:
  (box, ignored) = pair
  box

def public_record(x: U32) -> Cabinet:
  shelter(Cabinet, cabinet.box(cabinet.make(x)))

def public_pair(x: U32) -> U32 & U32:
  shelter(U32 & U32, signal.pair(x))

def public_shared(x: U32) -> Cabinet & Cabinet:
  +box = Drawer{x, U32.add(x, 1)}
  shelter(Cabinet & Cabinet, (box, box))

def main() -> U32:
  bench(8, 3)

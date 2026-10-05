import Base

# Both array handles originate in the scalar-input root; internal records keep
# their affine fields, and the final public shell contains the original handles.
type Parcel is Type:
  Parcel{left: Array<U32>, right: Array<U32>, +score: U32}

def parcel.right(+i: U32, b: Array<U32>, +acc: U32, r: Array<U32> & U32) -> Parcel:
  (a, old) = r
  +next = U32.add(U32.add(acc, old), 1)
  Parcel{Array.set(U32, a, i, U32.xor(next, i)), Array.set(U32, b, U32.inc(i), U32.add(next, 3)), next}

def parcel.step(+i: U32, st: Parcel) -> Parcel:
  Parcel{a, b, acc} = st
  parcel.right(i, b, acc, Array.get(U32, a, i))

def parcel.loop(+n: Nat, +i: U32, st: Parcel) -> Parcel:
  match n:
    case 0n: st
    case 1n+q: parcel.loop(q, U32.inc(i), parcel.step(i, st))

def make(+n: U32, +seed: U32) -> Parcel:
  parcel.loop(U32.to_nat(n), 0, Parcel{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)), 0})

# Public container arguments must not receive the closed ownership permission.
def external(+n: U32, st: Parcel) -> Parcel:
  parcel.loop(U32.to_nat(n), 0, st)

def touch(a: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  Array.set(U32, a, i, v)

type Nest is Type:
  Nest{inner: Parcel}

def nested(+n: U32, +seed: U32) -> Nest:
  Nest{make(n, seed)}

# Allocation errors remain demanded through a final returned field.
def failing(+n: U32, +seed: U32) -> Parcel:
  parcel.loop(U32.to_nat(n), 0, Parcel{Array.new(U32, 32n, seed), Array.new(U32, 2n, seed), 0})

def main() -> U32:
  0

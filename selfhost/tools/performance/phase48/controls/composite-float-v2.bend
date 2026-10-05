import Base

type FloatParcel is Type:
  FloatParcel{left: Array<F32>, right: Array<F32>, +last: F32}

# The tuple field is affine; forward it once to an explicitly reusable scalar.
def floatparcel.end(+i: U32, a: Array<F32>, b: Array<F32>, +old: F32) -> FloatParcel:
  FloatParcel{a, Array.set(F32, b, i, F32.add(old, 0.125)), old}

def floatparcel.finish(+i: U32, b: Array<F32>, r: Array<F32> & F32) -> FloatParcel:
  (a, old) = r
  floatparcel.end(i, a, b, old)

def floatparcel.step(+i: U32, st: FloatParcel) -> FloatParcel:
  FloatParcel{a, b, old} = st
  floatparcel.finish(i, b, Array.swap(F32, a, i, 0.25))

def floatparcel.loop(+n: Nat, +i: U32, st: FloatParcel) -> FloatParcel:
  match n:
    case 0n: st
    case 1n+q: floatparcel.loop(q, U32.inc(i), floatparcel.step(i, st))

def make(+n: U32, +seed: F32) -> FloatParcel:
  floatparcel.loop(U32.to_nat(n), 0, FloatParcel{Array.new(F32, 2n, seed), Array.new(F32, 2n, F32.neg(seed)), 0.0})

def external(+n: U32, st: FloatParcel) -> FloatParcel:
  floatparcel.loop(U32.to_nat(n), 0, st)

def touch(a: Array<F32>, +i: U32, +v: F32) -> Array<F32>:
  Array.set(F32, a, i, v)

def main() -> U32:
  0

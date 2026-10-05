import Base

def raw(u: U32) -> F32:
  U32{w} = u
  F32{w}

def word(f: F32) -> U32:
  F32{w} = f
  U32{w}

def bu(b: Bool) -> U32:
  match b:
    case False{}:
      0
    case True{}:
      1

def arithmetic.nan() -> U32:
  +zero = {F32.div(0.0, 1.0) : F32}
  +nan = {F32.div(zero, zero) : F32}
  U32.add(bu(F32.is_ne(nan, nan)), U32.add(bu(F32.is_eq(nan, nan)), F32.to_u32(nan)))

def arithmetic.negative.zero() -> U32:
  word(F32.mul(0.0, F32.sub(0.0, 1.0)))

def computed(+f: U32 -> U32, +n: U32) -> U32:
  U32.mul(f(n), U32.add(f(U32.add(n, 1)), 3))

def prior(+f: U32 -> U32, +n: U32) -> U32:
  left = f(n)
  right = f(U32.add(n, 1))
  U32.mul(left, U32.add(right, 3))

def float.computed(+f: U32 -> F32, +n: U32) -> F32:
  F32.add(f(n), f(U32.add(n, 1)))

def deferred(+f: U32 -> U32, n: U32) -> U32 -> U32:
  k => U32.mul(f(n), f(k))

def branch(f: U32 -> U32, n: U32, select: U32) -> U32:
  match select:
    case 0:
      42
    case _:
      f(n)

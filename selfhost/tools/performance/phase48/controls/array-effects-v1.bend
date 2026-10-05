import Base

def wash.step(+i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  (a, +score) = state
  (b, +old) = Array.swap(F32, a, i, (score + 0.25 : F32))
  (c, +near) = Array.get(F32, b, U32.inc(i))
  +value: F32 = (old * 0.5 + near : F32)
  d = Array.set(F32, c, U32.inc(i), value)
  (e, +size) = Array.size(F32, d)
  (e, (score + value + U32.to_f32(size) : F32))

def wash.loop(n: Nat, +i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  match n:
    case Zero{}: state
    case Succ{p}: wash.loop(p, U32.inc(i), wash.step(i, state))

def wash.finish(state: Array<F32> & F32) -> F32:
  (a, score) = state
  score

def floating(+turns: U32, +seed: F32) -> F32:
  wash.finish(wash.loop(U32.to_nat(turns), 0, (Array.new(F32, 2n, seed), seed)))

def integer.step(+i: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  (a, +score) = state
  (b, old) = Array.swap(U32, a, i, U32.inc(score))
  (c, size) = Array.size(U32, b)
  (c, (score + old + size : U32))

def integer.loop(n: Nat, +i: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case Zero{}: state
    case Succ{p}: integer.loop(p, U32.inc(i), integer.step(i, state))

def integer.finish(state: Array<U32> & U32) -> U32:
  (a, score) = state
  score

def integer(+turns: U32, +seed: U32) -> U32:
  integer.finish(integer.loop(U32.to_nat(turns), 0, (Array.new(U32, 2n, seed), seed)))

def source.index(+i: U32) -> U32: i
def source.value(+v: F32) -> F32: v
def swap.old(state: Array<F32> & F32) -> F32:
  (a, old) = state
  old

def ordered(+i: U32, +v: F32) -> F32:
  swap.old(Array.swap(F32, Array.new(F32, 2n, 3.0), source.index(i), source.value(v)))

def external(a: Array<F32>, +i: U32, v: F32) -> Array<F32> & F32:
  Array.swap(F32, a, i, v)

def converted(+turns: U32, +seed: F32) -> U32:
  F32.to_u32(floating(turns, seed))

def bench(+turns: U32, +seed: U32) -> U32:
  converted(turns, U32.to_f32(seed))

def main() -> U32: bench(3, 2)

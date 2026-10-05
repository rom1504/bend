import Base

def wash.sized(+score: F32, +value: F32, pair: Array<F32> & U32) -> Array<F32> & F32:
  (a, +size) = pair
  (a, (score + value + U32.to_f32(size) : F32))

def wash.read(+i: U32, +score: F32, +old: F32, pair: Array<F32> & F32) -> Array<F32> & F32:
  (a, +near) = pair
  +value: F32 = (old * 0.5 + near : F32)
  wash.sized(score, value, Array.size(F32, Array.set(F32, a, U32.inc(i), value)))

def wash.swapped(+i: U32, +score: F32, pair: Array<F32> & F32) -> Array<F32> & F32:
  (a, +old) = pair
  wash.read(i, score, old, Array.get(F32, a, U32.inc(i)))

def wash.step(+i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  (a, +score) = state
  wash.swapped(i, score, Array.swap(F32, a, i, (score + 0.25 : F32)))

def wash.loop(n: Nat, +i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  match n:
    case Zero{}: state
    case Succ{p}: wash.loop(p, U32.inc(i), wash.step(i, state))

def wash.finish(state: Array<F32> & F32) -> F32:
  (a, score) = state
  score

def floating(+turns: U32, +seed: F32) -> F32:
  wash.finish(wash.loop(U32.to_nat(turns), 0, (Array.new(F32, 2n, seed), seed)))

def integer.sized(+score: U32, +old: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, size) = pair
  (a, (score + old + size : U32))

def integer.swapped(+score: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, old) = pair
  integer.sized(score, old, Array.size(U32, a))

def integer.step(+i: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  (a, +score) = state
  integer.swapped(score, Array.swap(U32, a, i, U32.inc(score)))

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

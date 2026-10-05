import Base

def river.read(+i: U32, +sum: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, +value) = pair
  (Array.set(U32, a, i, U32.inc(value)), U32.add(sum, value))

def river.step(+i: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  (a, sum) = state
  river.read(i, sum, Array.get(U32, a, i))

def river.loop(n: Nat, +i: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case Zero{}: state
    case Succ{p}: river.loop(p, U32.inc(i), river.step(i, state))

def river.finish(state: Array<U32> & U32) -> U32:
  (a, sum) = state
  sum

def bench(+turns: U32, +seed: U32) -> U32:
  river.finish(river.loop(U32.to_nat(turns), 0, (Array.new(U32, 2n, seed), 0)))

def main() -> U32: bench(3, 2)

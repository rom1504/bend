import Base

def gleam.finish(+left: F32, pair: Array<F32> & F32) -> U32:
  (a, right) = pair
  F32.to_u32(((left + right) * (6.25 - 2.25) : F32))

def gleam.first(pair: Array<F32> & F32) -> U32:
  (a, left) = pair
  gleam.finish(left, Array.swap(F32, a, 1, 0.25))

def gleam() -> U32:
  gleam.first(Array.swap(F32, {ANode{ALeaf{0.5}, ALeaf{1.5}} : Array<F32>}, 0, 2.0))

def seeded(+left: F32, +right: F32) -> U32:
  gleam.first(Array.swap(F32, {ANode{ALeaf{left}, ALeaf{right}} : Array<F32>}, 0, 2.0))

def measure.finish(pair: Array<F32> & U32) -> U32:
  (a, size) = pair
  size

def measure.pick(flag: Bool, a: Array<F32>) -> U32:
  match flag:
    case True{}: measure.finish(Array.size(F32, a))
    case False{}: 17

def conditional(+seed: F32, +flag: Bool) -> U32:
  measure.pick(flag, {ANode{ALeaf{seed}, ALeaf{seed}} : Array<F32>})

def returned(+seed: F32) -> Array<F32>:
  ANode{ALeaf{seed}, ALeaf{seed}}

def field.value(+seed: F32) -> F32: seed

def computed_field(+seed: F32) -> U32:
  measure.finish(Array.size(F32, {ALeaf{field.value(seed)} : Array<F32>}))

def bench(+left: U32, +right: U32) -> U32:
  seeded(U32.to_f32(left), U32.to_f32(right))

def main() -> U32: gleam()

# A genuine loop is required to amortize a standalone literal-entry proof.
def ember.swapped(+score: F32, pair: Array<F32> & F32) -> Array<F32> & F32:
  (a, old) = pair
  (a, (score + old * 0.5 : F32))

def ember.step(+i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  (a, +score) = state
  ember.swapped(score, Array.swap(F32, a, i, (U32.to_f32(U32.mod(i, 7)) + 0.25 : F32)))

def ember.loop(n: Nat, +i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  match n:
    case Zero{}: state
    case Succ{p}: ember.loop(p, U32.inc(i), ember.step(i, state))

def ember.finish(state: Array<F32> & F32) -> F32:
  (a, score) = state
  score

def cycling(+turns: U32, +seed: F32) -> F32:
  ember.finish(ember.loop(U32.to_nat(turns), 0,
    ({ANode{ALeaf{seed}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def glowing() -> F32:
  ember.finish(ember.loop(37n, 0,
    ({ANode{ALeaf{1.5}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def loop_bench(+turns: U32, +seed: U32) -> U32:
  F32.to_u32(cycling(turns, U32.to_f32(seed)))

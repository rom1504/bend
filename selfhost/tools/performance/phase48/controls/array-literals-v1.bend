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

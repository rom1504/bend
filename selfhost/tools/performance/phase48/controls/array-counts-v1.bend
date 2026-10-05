import Base

def countwork.swapped(+score: F32, pair: Array<F32> & F32) -> Array<F32> & F32:
  (a, old) = pair
  (a, (score + old * 0.5 : F32))

def countwork.step(+i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  (a, +score) = state
  countwork.swapped(score, Array.swap(F32, a, i, (U32.to_f32(U32.mod(i, 7)) + 0.25 : F32)))

def countwork.loop(n: Nat, +i: U32, state: Array<F32> & F32) -> Array<F32> & F32:
  match n:
    case Zero{}: state
    case Succ{p}: countwork.loop(p, U32.inc(i), countwork.step(i, state))

def countwork.finish(state: Array<F32> & F32) -> F32:
  (a, score) = state
  score

# Same loop, differently positioned or represented public count arguments.
def direct(+turns: U32, +seed: F32) -> F32:
  countwork.finish(countwork.loop(U32.to_nat(turns), 0,
    ({ANode{ALeaf{seed}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def shifted(+seed: F32, +turns: U32) -> F32:
  countwork.finish(countwork.loop(U32.to_nat(turns), 0,
    ({ANode{ALeaf{seed}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def natural(+turns: Nat, +seed: F32) -> F32:
  countwork.finish(countwork.loop(turns, 0,
    ({ANode{ALeaf{seed}, ALeaf{0.5}} : Array<F32>}, 0.0)))

# Arithmetic is deliberately outside the decline-only count proof.
def computed(+turns: U32, +seed: F32) -> F32:
  countwork.finish(countwork.loop(U32.to_nat(U32.inc(turns)), 0,
    ({ANode{ALeaf{seed}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def constant() -> F32:
  countwork.finish(countwork.loop(37n, 0,
    ({ANode{ALeaf{1.5}, ALeaf{0.5}} : Array<F32>}, 0.0)))

def main() -> F32: direct(2, 3.0)

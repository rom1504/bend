import Base

type Thicket is Type:
  Branches{left: Array<U32>, right: Array<U32>, total: U32}

def twig.choose(flag: Bool, a: Array<U32>, b: Array<U32>, total: U32) -> Thicket:
  match flag:
    case True{}: Branches{b, a, total}
    case False{}: Branches{a, b, total}

def twig.second(+i: U32, flag: Bool, a: Array<U32>, total: U32, x: U32,
                pair: Array<U32> & U32) -> Thicket:
  (b, y) = pair
  +next = U32.add(U32.add(U32.add(total, x), y), 1)
  twig.choose(flag, Array.set(U32, a, i, U32.xor(next, i)),
    Array.set(U32, b, U32.inc(i), next), next)

def twig.first(+i: U32, flag: Bool, b: Array<U32>, total: U32,
               pair: Array<U32> & U32) -> Thicket:
  (a, x) = pair
  twig.second(i, flag, a, total, x, Array.get(U32, b, U32.inc(i)))

def twig.cell(+i: U32, flag: Bool, state: Thicket) -> Thicket:
  Branches{a, b, total} = state
  twig.first(i, flag, b, total, Array.get(U32, a, i))

def twig.loop(+n: Nat, +i: U32, +flag: Bool, state: Thicket) -> Thicket:
  match n:
    case 0n: state
    case 1n+p: twig.loop(p, U32.inc(i), flag, twig.cell(i, flag, state))

def twig.finish(state: Thicket) -> U32:
  Branches{a, b, total} = state
  total

def leaf(turns: U32, +seed: U32, flag: Bool) -> U32:
  twig.finish(twig.loop(U32.to_nat(turns), 0, flag,
    Branches{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)), 0}))

# Each tree leaf owns fresh arrays. Its public leaf wrapper may be bypassed by
# the existing private scalar-tree emitter, so entry must be observed at canopy.
def canopy(+depth: Nat, +turns: U32, +seed: U32, +flag: Bool) -> U32:
  match depth:
    case 0n: leaf(turns, seed, flag)
    case 1n+q:
      left right = canopy(q, turns, seed, flag) canopy(q, turns, U32.add(seed, U32.shln(1, q)), flag)
      U32.add(U32.mul(left, 3), U32.xor(right, 85))

# Public storage is returned unchanged beside the scalar tree result. This
# wrapper itself cannot acquire the private raw-array representation.
def exposed(depth: Nat, turns: U32, seed: U32, flag: Bool,
            storage: Array<U32>) -> Array<U32> & U32:
  (storage, canopy(depth, turns, seed, flag))

def bench(depth: U32, seed: U32) -> U32:
  canopy(U32.to_nat(depth), 5, seed, True{})

def main() -> U32:
  bench(3, 7)

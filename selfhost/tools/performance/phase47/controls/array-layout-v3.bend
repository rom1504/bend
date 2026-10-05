import Base

type Cradle is Type:
  C2{left: Array<U32>, right: Array<U32>, total: U32}

type Carousel is Type:
  C4{a: Array<U32>, b: Array<U32>, c: Array<U32>, d: Array<U32>, total: U32}

def dual.pick(flag: Bool, a: Array<U32>, b: Array<U32>, total: U32) -> Cradle:
  match flag:
    case True{}: C2{b, a, total}
    case False{}: C2{a, b, total}

def dual.second(+i: U32, flag: Bool, a: Array<U32>, total: U32, x: U32,
                pair: Array<U32> & U32) -> Cradle:
  (b, y) = pair
  +next = U32.add(U32.add(U32.add(total, x), y), 1)
  dual.pick(flag, Array.set(U32, a, i, U32.xor(next, i)),
    Array.set(U32, b, U32.inc(i), next), next)

def dual.first(+i: U32, flag: Bool, b: Array<U32>, total: U32,
               pair: Array<U32> & U32) -> Cradle:
  (a, x) = pair
  dual.second(i, flag, a, total, x, Array.get(U32, b, U32.inc(i)))

def dual.cell(+i: U32, flag: Bool, state: Cradle) -> Cradle:
  C2{a, b, total} = state
  dual.first(i, flag, b, total, Array.get(U32, a, i))

def dual.loop(+n: Nat, +i: U32, +flag: Bool, state: Cradle) -> Cradle:
  match n:
    case 0n: state
    case 1n+p: dual.loop(p, U32.inc(i), flag, dual.cell(i, flag, state))

def dual.finish(state: Cradle) -> U32:
  C2{a, b, total} = state
  total

def dual(+n: U32, +seed: U32, flag: Bool) -> U32:
  dual.finish(dual.loop(U32.to_nat(n), 0, flag,
    C2{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)), 0}))

def quad.pick(flag: Bool, a: Array<U32>, b: Array<U32>, c: Array<U32>,
              d: Array<U32>, total: U32) -> Carousel:
  match flag:
    case True{}: C4{d, a, b, c, total}
    case False{}: C4{b, c, d, a, total}

def quad.second(+i: U32, flag: Bool, a: Array<U32>, c: Array<U32>,
                d: Array<U32>, total: U32, x: U32,
                pair: Array<U32> & U32) -> Carousel:
  (b, y) = pair
  +next = U32.add(U32.add(U32.add(total, x), y), 3)
  quad.pick(flag, a, b, Array.set(U32, c, i, next),
    Array.set(U32, d, U32.add(i, 2), U32.xor(next, U32.inc(i))), next)

def quad.first(+i: U32, flag: Bool, b: Array<U32>, c: Array<U32>,
               d: Array<U32>, total: U32,
               pair: Array<U32> & U32) -> Carousel:
  (a, x) = pair
  quad.second(i, flag, a, c, d, total, x, Array.get(U32, b, U32.inc(i)))

def quad.cell(+i: U32, flag: Bool, state: Carousel) -> Carousel:
  C4{a, b, c, d, total} = state
  quad.first(i, flag, b, c, d, total, Array.get(U32, a, i))

def quad.loop(+n: Nat, +i: U32, +flag: Bool, state: Carousel) -> Carousel:
  match n:
    case 0n: state
    case 1n+p: quad.loop(p, U32.inc(i), flag, quad.cell(i, flag, state))

def quad.finish(state: Carousel) -> U32:
  C4{a, b, c, d, total} = state
  total

def four(+n: U32, +seed: U32, flag: Bool) -> U32:
  quad.finish(quad.loop(U32.to_nat(n), 0, flag,
    C4{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)),
       Array.new(U32, 2n, U32.add(seed, 2)), Array.new(U32, 2n, U32.add(seed, 3)), 0}))

def returned2(+n: U32, +seed: U32, flag: Bool) -> Cradle:
  dual.loop(U32.to_nat(n), 0, flag,
    C2{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)), 0})

def returned4(+n: U32, +seed: U32, flag: Bool) -> Carousel:
  quad.loop(U32.to_nat(n), 0, flag,
    C4{Array.new(U32, 2n, seed), Array.new(U32, 2n, U32.inc(seed)),
       Array.new(U32, 2n, U32.add(seed, 2)), Array.new(U32, 2n, U32.add(seed, 3)), 0})

def external2(n: Nat, flag: Bool, state: Cradle) -> Cradle:
  dual.loop(n, 0, flag, state)

def external4(n: Nat, flag: Bool, state: Carousel) -> Carousel:
  quad.loop(n, 0, flag, state)

def ink.index(x: U32) -> U32:
  U32.inc(x)

def ink.value(x: U32) -> U32:
  U32.mul(x, 7)

def ink.read(pair: Array<U32> & U32) -> U32:
  (a, value) = pair
  value

def ink.finish(a: Array<U32>) -> U32:
  ink.read(Array.get(U32, a, 0))

# A statement write must evaluate its index, then value, before Number(index).
def ink.store(+x: U32, a: Array<U32>) -> Array<U32>:
  Array.set(U32, a, ink.index(x), ink.value(x))

def ink.loop(+n: Nat, +x: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: ink.loop(p, x, ink.store(x, a))

def write_order(x: U32) -> U32:
  ink.finish(ink.loop(1n, x, Array.new(U32, 2n, 0)))

def bench(n: U32, seed: U32) -> U32:
  dual(n, seed, True{})

def main() -> U32:
  bench(9, 3)

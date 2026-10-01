import Base

# Independent shape: distinct input ADTs, a different result ADT, skewed
# producers, mismatched shapes, and a combine that may preserve shared aliases.
type ComponentA is Data:
  AEnd{value: U32}
  AFork{left: ComponentA, right: ComponentA}

type ComponentB is Data:
  BEnd{value: U32}
  BFork{left: ComponentB, right: ComponentB}

type ComponentOut is Data:
  OEnd{value: U32}
  OFork{left: ComponentOut, right: ComponentOut}

def component.join(+left: ComponentOut, right: ComponentOut, flag: Bool) -> ComponentOut:
  match flag:
    case False{}: OFork{left, right}
    case True{}: OFork{left, left}

def component.mix(a: ComponentA, b: ComponentB, +flag: Bool) -> ComponentOut:
  match a b:
    case AEnd{x} BEnd{y}: OEnd{U32.xor(U32.mul(x, 3), y)}
    case AEnd{x} BFork{left, right}: OEnd{U32.add(x, 17)}
    case AFork{left, right} BEnd{y}: OEnd{U32.add(y, 23)}
    case AFork{a0, a1} BFork{b0, b1}:
      left right = component.mix(a0, b0, flag) component.mix(a1, b1, flag)
      component.join(left, right, flag)

def component.makeA(n: Nat, +seed: U32) -> ComponentA:
  match n:
    case 0n: AEnd{seed}
    case 1n+p: AFork{component.makeA(p, U32.inc(seed)), AEnd{seed}}

def component.makeB(n: Nat, +seed: U32) -> ComponentB:
  match n:
    case 0n: BEnd{seed}
    case 1n+p: BFork{component.makeB(p, U32.add(seed, 3)), BEnd{U32.xor(seed, 91)}}

# The changing accumulator deliberately keeps the consumer generic, so an
# earlier one-argument scalar fold cannot hide the new component proof entry.
def component.score(tree: ComponentOut, acc: U32) -> U32:
  match tree:
    case OEnd{x}: U32.add(acc, x)
    case OFork{left, right}: component.score(right, U32.add(component.score(left, acc), 1))

def bench(size: U32, +seed: U32) -> U32:
  component.score(component.mix(component.makeA(U32.to_nat(size), seed),
    component.makeB(U32.to_nat(size), seed), U32.is_zero(U32.mod(seed, 2))), 0)

# Tail-only recursion is intentionally outside the two-result component rule.
def component.tail(a: ComponentA, +seed: U32) -> ComponentOut:
  match a:
    case AEnd{x}: OEnd{U32.add(x, seed)}
    case AFork{left, right}: component.tail(left, seed)

def tail_check(size: U32, +seed: U32) -> U32:
  component.score(component.tail(component.makeA(U32.to_nat(size), seed), seed), 0)

# Full tail-cycle contract: these definitions must keep the runtime trampoline.
law component.cycle:
  for n: Nat
  for +seed: U32
  U32

law component.mutual:
  for n: Nat
  for +seed: U32
  U32

@unsafe
def component.cycle(n, seed):
  match n:
    case 0n: bench(3, seed)
    case 1n+p: component.mutual(p, U32.inc(seed))

@unsafe
def component.mutual(n, seed):
  match n:
    case 0n: bench(3, seed)
    case 1n+p: component.cycle(p, U32.inc(seed))

def main() -> U32:
  bench(3, 17)

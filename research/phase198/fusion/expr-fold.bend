# Interpret each generated constructor with the consumer's wrapping-U32 algebra.
def probe.pick(op: Nat, value: U32, seed: U32) -> U32:
  match op:
    case 0n: U32.add(value, U32.mul(seed, 3))
    case 1n+0n: U32.mul(value, U32.add(U32.mod(seed, 5), 1))
    case 1n+1n+p: U32.sub(value, U32.add(seed, 7))

def probe.eval(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+p:
      probe.pick(U32.to_nat(U32.mod(seed, 3)), probe.eval(p, U32.add(seed, 1)), seed)

def bench(size: U32, seed: U32) -> U32:
  probe.eval(U32.to_nat(size), seed)

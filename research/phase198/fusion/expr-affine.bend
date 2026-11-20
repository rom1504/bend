# The pending context denotes multiplier * recursive-value + offset modulo 2^32.
def probe.affine(n: Nat, +seed: U32, +multiplier: U32, +offset: U32) -> U32:
  match n:
    case 0n: U32.add(U32.mul(multiplier, seed), offset)
    case 1n+p:
      op = U32.to_nat(U32.mod(seed, 3))
      match op:
        case 0n:
          probe.affine(p, U32.inc(seed), multiplier,
            U32.add(offset, U32.mul(multiplier, U32.mul(seed, 3))))
        case 1n+0n:
          probe.affine(p, U32.inc(seed), U32.mul(multiplier, U32.inc(U32.mod(seed, 5))), offset)
        case 1n+1n+q:
          probe.affine(p, U32.inc(seed), multiplier,
            U32.sub(offset, U32.mul(multiplier, U32.add(seed, 7))))

def bench(size: U32, seed: U32) -> U32:
  probe.affine(U32.to_nat(size), seed, 1, 0)

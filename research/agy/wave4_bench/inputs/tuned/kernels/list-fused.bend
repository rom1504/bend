import Base

def fold(n: Nat, +seed: U32, total: U32) -> U32:
  match n:
    case 0n: total
    case 1n+p:
      +v = U32.and(seed,15)
      add = U32.mul(U32.shl(v),Bool.to_u32(U32.is_gt(v,1)))
      fold(p,U32.add(U32.mul(seed,1664525),1013904223),U32.add(total,add))

def bench(n: U32,seed: U32) -> U32:
  fold(U32.to_nat(n),seed,0)

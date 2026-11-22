import Base

def apply(op: Nat, v: U32, seed: U32) -> U32:
  match op:
    case 0n: U32.add(v,U32.mul(seed,3))
    case 1n+0n: U32.mul(v,U32.inc(U32.mod(seed,5)))
    case 1n+1n+p: U32.sub(v,U32.add(seed,7))

def unwind(left: Nat, seed: U32, v: U32) -> U32:
  match left:
    case 0n: v
    case 1n+p:
      +prev = U32.sub(seed,1)
      unwind(p,prev,apply(U32.to_nat(U32.mod(prev,3)),v,prev))

def bench(+n: U32,seed: U32) -> U32:
  +end = U32.add(seed,n)
  unwind(U32.to_nat(n),end,end)

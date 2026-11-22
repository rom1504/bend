import Base

def bump(+k: U32,r: Array<U32> & U32) -> Array<U32>:
  (a,v) = r
  Array.set(U32,a,k,U32.inc(v))

def collect(left: Nat,+seed: U32,+stride: U32,a: Array<U32>) -> Array<U32>:
  match left:
    case 0n: a
    case 1n+p:
      +k = U32.mod(seed,257)
      collect(p,U32.add(seed,stride),stride,bump(k,Array.get_unchecked(U32,a,k)))

def repeat_key(left: Nat,+k: U32,h: U32) -> U32:
  match left:
    case 0n: h
    case 1n+p: repeat_key(p,k,U32.add(U32.mul(h,10),k))

def sorted_fold(left: Nat,+k: U32,h: U32,r: Array<U32> & U32) -> U32:
  match left r:
    case 0n Tuple{a,v}: repeat_key(U32.to_nat(v),k,h)
    case 1n+p Tuple{a,v}:
      +next = U32.inc(k)
      sorted_fold(p,next,repeat_key(U32.to_nat(v),k,h),Array.get_unchecked(U32,a,next))

def bench(n: U32,+seed: U32) -> U32:
  a = collect(U32.to_nat(n),seed,U32.inc(U32.shl(seed)),[0 : U32*512n])
  sorted_fold(256n,0,0,Array.get_unchecked(U32,a,0))

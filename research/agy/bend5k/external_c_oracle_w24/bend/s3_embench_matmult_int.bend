import Base
# s3_embench_matmult_int: Port of Embench-IoT matmult-int (matmult-int.c)
# 20x20 integer matrix multiply, 2000 rounds with diagonal feedback.

type InitSt is Type:
  IS{arr: Array<U32>, seed: U32}

type DotSt is Type:
  DS{a: Array<U32>, b: Array<U32>, sum: U32}

type MatSt is Type:
  MS{a: Array<U32>, b: Array<U32>, res: Array<U32>}

type RoundSt is Type:
  RS{a: Array<U32>, b: Array<U32>, res: Array<U32>, acc: U32}

type HashSt is Type:
  HS{arr: Array<U32>, acc: U32}

def init_arr(+rem: Nat, +idx: U32, st: InitSt) -> InitSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      IS{arr, +seed} = st
      +s1 = U32.mod(U32.add(U32.mul(seed, 133), 81), 8095)
      init_arr(p, U32.inc(idx), IS{Array.set(U32, arr, idx, s1), s1})

def dot_k2(+sum: U32, +av: U32, a1: Array<U32>, rb: Array<U32> & U32) -> DotSt:
  (b1, +bv) = rb
  DS{a1, b1, U32.add(sum, U32.mul(av, bv))}

def dot_k1(+bidx: U32, +sum: U32, b: Array<U32>, ra: Array<U32> & U32) -> DotSt:
  (a1, +av) = ra
  dot_k2(sum, av, a1, Array.get(U32, b, bidx))

def dot_k(+rem: Nat, +aidx: U32, +bidx: U32, st: DotSt) -> DotSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      DS{a, b, +sum} = st
      dot_k(p, U32.inc(aidx), U32.add(bidx, 20), dot_k1(bidx, sum, b, Array.get(U32, a, aidx)))

def mul_j_fin(+ridx: U32, res: Array<U32>, ds: DotSt) -> MatSt:
  DS{a1, b1, +sum} = ds
  MS{a1, b1, Array.set(U32, res, ridx, sum)}

def mul_j(+rem: Nat, +j: U32, +arow: U32, st: MatSt) -> MatSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      MS{a, b, res} = st
      mul_j(p, U32.inc(j), arow, mul_j_fin(U32.add(arow, j), res, dot_k(20n, arow, j, DS{a, b, 0})))

def mul_i(+rem: Nat, +i: U32, st: MatSt) -> MatSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      mul_i(p, U32.inc(i), mul_j(20n, 0, U32.mul(i, 20), st))

def rd_upd(+r: U32, +acc: U32, a: Array<U32>, b: Array<U32>, rr: Array<U32> & U32) -> RoundSt:
  (res1, +diag) = rr
  +acc1 = U32.mul(U32.xor(acc, diag), 16777619)
  +ri = U32.mod(r, 20)
  +rj = U32.mod(U32.add(r, 3), 20)
  +nv = U32.inc(U32.and(diag, 255))
  a1 = Array.set(U32, a, U32.add(U32.mul(ri, 20), rj), nv)
  RS{a1, b, res1, acc1}

def rd_after(+r: U32, +acc: U32, ms: MatSt) -> RoundSt:
  MS{a, b, res} = ms
  +ri = U32.mod(r, 20)
  rd_upd(r, acc, a, b, Array.get(U32, res, U32.add(U32.mul(ri, 20), ri)))

def run_rounds(+rem: Nat, +r: U32, st: RoundSt) -> RoundSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      RS{a, b, res, +acc} = st
      run_rounds(p, U32.inc(r), rd_after(r, acc, mul_i(20n, 0, MS{a, b, res})))

def hash_step(+acc: U32, r: Array<U32> & U32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, v), 16777619)}

def hash_res(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+p:
      HS{arr, +acc} = st
      hash_res(p, U32.inc(idx), hash_step(acc, Array.get(U32, arr, idx)))

def after_rounds(st: RoundSt) -> U32:
  RS{a, b, res, +acc} = st
  hash_res(400n, 0, HS{res, acc})

def after_init_b(a: Array<U32>, ib: InitSt) -> U32:
  IS{b, +s2} = ib
  after_rounds(run_rounds(2000n, 0, RS{a, b, Array.new(U32, 9n, 0), 2166136261}))

def after_init_a(ia: InitSt) -> U32:
  IS{a, +s1} = ia
  after_init_b(a, init_arr(400n, 0, IS{Array.new(U32, 9n, 0), s1}))

def main() -> U32:
  after_init_a(init_arr(400n, 0, IS{Array.new(U32, 9n, 0), 0}))

import Base
# s2_polybench_gemm: Port of PolyBench/C 4.2.1 gemm (MEDIUM_DATASET, float/F32)
# NI=200, NJ=220, NK=240. C := alpha * A * B + beta * C.

type GemmSt is Type:
  GS{c: Array<F32>, a: Array<F32>, b: Array<F32>}

type HashSt is Type:
  HS{arr: Array<F32>, acc: U32}

def init_c_j(+rem: Nat, +i: U32, +j: U32, +base: U32, c: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      c
    case 1n+p:
      +v = F32.div(U32.to_f32(U32.mod(U32.add(U32.mul(i, j), 1), 200)), 200.0)
      init_c_j(p, i, U32.inc(j), base, Array.set(F32, c, U32.add(base, j), v))

def init_c_i(+rem: Nat, +i: U32, c: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      c
    case 1n+p:
      init_c_i(p, U32.inc(i), init_c_j(220n, i, 0, U32.mul(i, 220), c))

def init_a_j(+rem: Nat, +i: U32, +j: U32, +base: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      +v = F32.div(U32.to_f32(U32.mod(U32.mul(i, U32.inc(j)), 240)), 240.0)
      init_a_j(p, i, U32.inc(j), base, Array.set(F32, a, U32.add(base, j), v))

def init_a_i(+rem: Nat, +i: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      init_a_i(p, U32.inc(i), init_a_j(240n, i, 0, U32.mul(i, 240), a))

def init_b_j(+rem: Nat, +i: U32, +j: U32, +base: U32, b: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      b
    case 1n+p:
      +v = F32.div(U32.to_f32(U32.mod(U32.mul(i, U32.add(j, 2)), 220)), 220.0)
      init_b_j(p, i, U32.inc(j), base, Array.set(F32, b, U32.add(base, j), v))

def init_b_i(+rem: Nat, +i: U32, b: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      b
    case 1n+p:
      init_b_i(p, U32.inc(i), init_b_j(220n, i, 0, U32.mul(i, 220), b))

def scale_c_step(+idx: U32, +beta: F32, r: Array<F32> & F32) -> Array<F32>:
  (c1, +v) = r
  Array.set(F32, c1, idx, F32.mul(v, beta))

def scale_c_row(+rem: Nat, +idx: U32, +beta: F32, c: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      c
    case 1n+p:
      scale_c_row(p, U32.inc(idx), beta, scale_c_step(idx, beta, Array.get(F32, c, idx)))

type CbPair is Type:
  CP{c: Array<F32>, b: Array<F32>}

def gemm_j2(+cidx: U32, +aa: F32, b1: Array<F32>, +bv: F32, rc: Array<F32> & F32) -> CbPair:
  (c1, +cv) = rc
  CP{Array.set(F32, c1, cidx, F32.add(cv, F32.mul(aa, bv))), b1}

def gemm_j1(+cidx: U32, +aa: F32, c: Array<F32>, rb: Array<F32> & F32) -> CbPair:
  (b1, +bv) = rb
  gemm_j2(cidx, aa, b1, bv, Array.get(F32, c, cidx))

def gemm_j(+rem: Nat, +cidx: U32, +bidx: U32, +aa: F32, st: CbPair) -> CbPair:
  match rem:
    case 0n:
      st
    case 1n+p:
      CP{c, b} = st
      gemm_j(p, U32.inc(cidx), U32.inc(bidx), aa, gemm_j1(cidx, aa, c, Array.get(F32, b, bidx)))

def gemm_k2(a1: Array<F32>, cb: CbPair) -> GemmSt:
  CP{c1, b1} = cb
  GS{c1, a1, b1}

def gemm_k1(+k: U32, +cbase: U32, +alpha: F32, c: Array<F32>, b: Array<F32>, ra: Array<F32> & F32) -> GemmSt:
  (a1, +av) = ra
  +aa = F32.mul(alpha, av)
  gemm_k2(a1, gemm_j(220n, cbase, U32.mul(k, 220), aa, CP{c, b}))

def gemm_k(+rem: Nat, +k: U32, +cbase: U32, +abase: U32, +alpha: F32, st: GemmSt) -> GemmSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      GS{c, a, b} = st
      gemm_k(p, U32.inc(k), cbase, abase, alpha, gemm_k1(k, cbase, alpha, c, b, Array.get(F32, a, U32.add(abase, k))))

def gemm_i(+rem: Nat, +i: U32, +alpha: F32, +beta: F32, st: GemmSt) -> GemmSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      GS{c, a, b} = st
      +cbase = U32.mul(i, 220)
      +abase = U32.mul(i, 240)
      c1 = scale_c_row(220n, cbase, beta, c)
      st1 = gemm_k(240n, 0, cbase, abase, alpha, GS{c1, a, b})
      gemm_i(p, U32.inc(i), alpha, beta, st1)

def hash_step(+acc: U32, r: Array<F32> & F32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, F32.bits(v)), 16777619)}

def hash_c(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+p:
      HS{arr, +acc} = st
      hash_c(p, U32.inc(idx), hash_step(acc, Array.get(F32, arr, idx)))

def finish_gemm(st: GemmSt) -> U32:
  GS{c1, a1, b1} = st
  hash_c(44000n, 0, HS{c1, 2166136261})

def main() -> U32:
  c = init_c_i(200n, 0, Array.new(F32, 16n, 0.0))
  a = init_a_i(200n, 0, Array.new(F32, 16n, 0.0))
  b = init_b_i(240n, 0, Array.new(F32, 16n, 0.0))
  finish_gemm(gemm_i(200n, 0, 1.5, 1.2, GS{c, a, b}))

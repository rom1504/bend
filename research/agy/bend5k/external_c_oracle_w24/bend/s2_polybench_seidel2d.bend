import Base
# s2_polybench_seidel2d: Port of PolyBench/C 4.2.1 seidel-2d (SMALL_DATASET, float/F32)
# TSTEPS=40, N=120. In-place 9-point Gauss-Seidel stencil.

type HashSt is Type:
  HS{arr: Array<F32>, acc: U32}

def init_j(+rem: Nat, +i: U32, +j: U32, +base: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      +v = F32.div(F32.add(F32.mul(U32.to_f32(i), U32.to_f32(U32.add(j, 2))), 2.0), 120.0)
      init_j(p, i, U32.inc(j), base, Array.set(F32, a, U32.add(base, j), v))

def init_i(+rem: Nat, +i: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      init_i(p, U32.inc(i), init_j(120n, i, 0, U32.mul(i, 120), a))

def sj9(+idx: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a9, +v8) = r
  Array.set(F32, a9, idx, F32.div(F32.add(s, v8), 9.0))

def sj8(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a8, +v7) = r
  sj9(idx, F32.add(s, v7), Array.get(F32, a8, U32.add(dn, 1)))

def sj7(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a7, +v6) = r
  sj8(idx, dn, F32.add(s, v6), Array.get(F32, a7, dn))

def sj6(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a6, +v5) = r
  sj7(idx, dn, F32.add(s, v5), Array.get(F32, a6, U32.sub(dn, 1)))

def sj5(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a5, +v4) = r
  sj6(idx, dn, F32.add(s, v4), Array.get(F32, a5, U32.add(idx, 1)))

def sj4(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a4, +v3) = r
  sj5(idx, dn, F32.add(s, v3), Array.get(F32, a4, idx))

def sj3(+idx: U32, +dn: U32, +s: F32, r: Array<F32> & F32) -> Array<F32>:
  (a3, +v2) = r
  sj4(idx, dn, F32.add(s, v2), Array.get(F32, a3, U32.sub(idx, 1)))

def sj2(+idx: U32, +up: U32, +dn: U32, +v0: F32, r: Array<F32> & F32) -> Array<F32>:
  (a2, +v1) = r
  sj3(idx, dn, F32.add(v0, v1), Array.get(F32, a2, U32.add(up, 1)))

def sj1(+idx: U32, +up: U32, +dn: U32, r: Array<F32> & F32) -> Array<F32>:
  (a1, +v0) = r
  sj2(idx, up, dn, v0, Array.get(F32, a1, up))

def seidel_j(+rem: Nat, +idx: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      +up = U32.sub(idx, 120)
      +dn = U32.add(idx, 120)
      seidel_j(p, U32.inc(idx), sj1(idx, up, dn, Array.get(F32, a, U32.sub(up, 1))))

def seidel_i(+rem: Nat, +i: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      seidel_i(p, U32.inc(i), seidel_j(118n, U32.add(U32.mul(i, 120), 1), a))

def run_t(+rem: Nat, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      run_t(p, seidel_i(118n, 1, a))

def hash_step(+acc: U32, r: Array<F32> & F32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, F32.bits(v)), 16777619)}

def hash_a(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+p:
      HS{arr, +acc} = st
      hash_a(p, U32.inc(idx), hash_step(acc, Array.get(F32, arr, idx)))

def main() -> U32:
  a0 = init_i(120n, 0, Array.new(F32, 14n, 0.0))
  a1 = run_t(40n, a0)
  hash_a(14400n, 0, HS{a1, 2166136261})

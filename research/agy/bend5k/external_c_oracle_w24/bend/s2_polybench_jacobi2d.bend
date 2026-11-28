import Base
# s2_polybench_jacobi2d: Port of PolyBench/C 4.2.1 jacobi-2d (MEDIUM_DATASET, float/F32)
# TSTEPS=100, N=250.

type PairF is Type:
  PF{a: Array<F32>, b: Array<F32>}

type HashSt is Type:
  HS{arr: Array<F32>, acc: U32}

def init_j(+rem: Nat, +i: U32, +j: U32, +base: U32, st: PairF) -> PairF:
  match rem:
    case 0n:
      st
    case 1n+p:
      PF{a, b} = st
      +fi = U32.to_f32(i)
      +va = F32.div(F32.add(F32.mul(fi, U32.to_f32(U32.add(j, 2))), 2.0), 250.0)
      +vb = F32.div(F32.add(F32.mul(fi, U32.to_f32(U32.add(j, 3))), 3.0), 250.0)
      +idx = U32.add(base, j)
      init_j(p, i, U32.inc(j), base, PF{Array.set(F32, a, idx, va), Array.set(F32, b, idx, vb)})

def init_i(+rem: Nat, +i: U32, st: PairF) -> PairF:
  match rem:
    case 0n:
      st
    case 1n+p:
      init_i(p, U32.inc(i), init_j(250n, i, 0, U32.mul(i, 250), st))

def sweep_j5(+idx: U32, +sum: F32, dst: Array<F32>, r: Array<F32> & F32) -> PairF:
  (s5, +v4) = r
  +nv = F32.mul(0.2, F32.add(sum, v4))
  PF{s5, Array.set(F32, dst, idx, nv)}

def sweep_j4(+idx: U32, +sum: F32, dst: Array<F32>, r: Array<F32> & F32) -> PairF:
  (s4, +v3) = r
  sweep_j5(idx, F32.add(sum, v3), dst, Array.get(F32, s4, U32.sub(idx, 250)))

def sweep_j3(+idx: U32, +sum: F32, dst: Array<F32>, r: Array<F32> & F32) -> PairF:
  (s3, +v2) = r
  sweep_j4(idx, F32.add(sum, v2), dst, Array.get(F32, s3, U32.add(idx, 250)))

def sweep_j2(+idx: U32, +v0: F32, dst: Array<F32>, r: Array<F32> & F32) -> PairF:
  (s2, +v1) = r
  sweep_j3(idx, F32.add(v0, v1), dst, Array.get(F32, s2, U32.add(idx, 1)))

def sweep_j1(+idx: U32, dst: Array<F32>, r: Array<F32> & F32) -> PairF:
  (s1, +v0) = r
  sweep_j2(idx, v0, dst, Array.get(F32, s1, U32.sub(idx, 1)))

def sweep_j(+rem: Nat, +idx: U32, st: PairF) -> PairF:
  match rem:
    case 0n:
      st
    case 1n+p:
      PF{src, dst} = st
      sweep_j(p, U32.inc(idx), sweep_j1(idx, dst, Array.get(F32, src, idx)))

def sweep_i(+rem: Nat, +i: U32, st: PairF) -> PairF:
  match rem:
    case 0n:
      st
    case 1n+p:
      sweep_i(p, U32.inc(i), sweep_j(248n, U32.add(U32.mul(i, 250), 1), st))

def swap_pf(st: PairF) -> PairF:
  PF{a, b} = st
  PF{b, a}

def run_t(+rem: Nat, st: PairF) -> PairF:
  match rem:
    case 0n:
      st
    case 1n+p:
      st1 = sweep_i(248n, 1, st)
      st2 = sweep_i(248n, 1, swap_pf(st1))
      run_t(p, swap_pf(st2))

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

def finish_jacobi(st: PairF) -> U32:
  PF{a1, b1} = st
  hash_a(62500n, 0, HS{a1, 2166136261})

def main() -> U32:
  st0 = init_i(250n, 0, PF{Array.new(F32, 16n, 0.0), Array.new(F32, 16n, 0.0)})
  finish_jacobi(run_t(100n, st0))

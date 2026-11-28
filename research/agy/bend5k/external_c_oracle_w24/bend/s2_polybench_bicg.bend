import Base
# s2_polybench_bicg: Port of PolyBench/C 4.2.1 bicg (MEDIUM_DATASET, float/F32)
# M=390, N=410, 40 rounds. s = A^T r, q = A p.

type BicgSt is Type:
  BS{a: Array<F32>, s: Array<F32>, q: Array<F32>, p: Array<F32>, r: Array<F32>}

type RowSt is Type:
  RS{a: Array<F32>, s: Array<F32>, p: Array<F32>, qv: F32}

type HashSt is Type:
  HS{arr: Array<F32>, acc: U32}

def init_p(+rem: Nat, +i: U32, p: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      init_p(q, U32.inc(i), Array.set(F32, p, i, F32.div(U32.to_f32(i), 390.0)))

def init_r(+rem: Nat, +i: U32, r: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      r
    case 1n+q:
      init_r(q, U32.inc(i), Array.set(F32, r, i, F32.div(U32.to_f32(i), 410.0)))

def init_a_j(+rem: Nat, +i: U32, +j: U32, +base: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+q:
      +v = F32.div(U32.to_f32(U32.mod(U32.mul(i, U32.inc(j)), 410)), 410.0)
      init_a_j(q, i, U32.inc(j), base, Array.set(F32, a, U32.add(base, j), v))

def init_a_i(+rem: Nat, +i: U32, a: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      a
    case 1n+q:
      init_a_i(q, U32.inc(i), init_a_j(390n, i, 0, U32.mul(i, 390), a))

def zero_s(+rem: Nat, +i: U32, s: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      s
    case 1n+q:
      zero_s(q, U32.inc(i), Array.set(F32, s, i, 0.0))

def bicg_j3(+aij: F32, +qv: F32, a1: Array<F32>, s2: Array<F32>, rp: Array<F32> & F32) -> RowSt:
  (p1, +pj) = rp
  RS{a1, s2, p1, F32.add(qv, F32.mul(aij, pj))}

def bicg_j2(+j: U32, +ri: F32, +aij: F32, +qv: F32, a1: Array<F32>, p: Array<F32>, rs: Array<F32> & F32) -> RowSt:
  (s1, +sj) = rs
  s2 = Array.set(F32, s1, j, F32.add(sj, F32.mul(ri, aij)))
  bicg_j3(aij, qv, a1, s2, Array.get(F32, p, j))

def bicg_j1(+j: U32, +ri: F32, +qv: F32, s: Array<F32>, p: Array<F32>, ra: Array<F32> & F32) -> RowSt:
  (a1, +aij) = ra
  bicg_j2(j, ri, aij, qv, a1, p, Array.get(F32, s, j))

def bicg_j(+rem: Nat, +j: U32, +aidx: U32, +ri: F32, st: RowSt) -> RowSt:
  match rem:
    case 0n:
      st
    case 1n+q:
      RS{a, s, p, +qv} = st
      bicg_j(q, U32.inc(j), U32.inc(aidx), ri, bicg_j1(j, ri, qv, s, p, Array.get(F32, a, aidx)))

def bicg_i2(+i: U32, qv: Array<F32>, r1: Array<F32>, rs: RowSt) -> BicgSt:
  RS{a1, s1, p1, +qi} = rs
  BS{a1, s1, Array.set(F32, qv, i, qi), p1, r1}

def bicg_i1(+i: U32, a: Array<F32>, s: Array<F32>, qv: Array<F32>, p: Array<F32>, rr: Array<F32> & F32) -> BicgSt:
  (r1, +ri) = rr
  bicg_i2(i, qv, r1, bicg_j(390n, 0, U32.mul(i, 390), ri, RS{a, s, p, 0.0}))

def bicg_i(+rem: Nat, +i: U32, st: BicgSt) -> BicgSt:
  match rem:
    case 0n:
      st
    case 1n+q:
      BS{a, s, qv, p, r} = st
      bicg_i(q, U32.inc(i), bicg_i1(i, a, s, qv, p, Array.get(F32, r, i)))

def rd_pert2(+im: U32, +in_: U32, +sm: F32, a1: Array<F32>, s2: Array<F32>, p1: Array<F32>, r1: Array<F32>, rq: Array<F32> & F32) -> BicgSt:
  (qv2, +qn) = rq
  p2 = Array.set(F32, p1, im, F32.add(F32.mul(sm, 0.001), 0.1))
  r2 = Array.set(F32, r1, in_, F32.add(F32.mul(qn, 0.001), 0.1))
  BS{a1, s2, qv2, p2, r2}

def rd_pert1(+im: U32, +in_: U32, a1: Array<F32>, qv1: Array<F32>, p1: Array<F32>, r1: Array<F32>, rs: Array<F32> & F32) -> BicgSt:
  (s2, +sm) = rs
  rd_pert2(im, in_, sm, a1, s2, p1, r1, Array.get(F32, qv1, in_))

def rd_after(+rd: U32, st: BicgSt) -> BicgSt:
  BS{a1, s1, qv1, p1, r1} = st
  +im = U32.mod(rd, 390)
  +in_ = U32.mod(rd, 410)
  rd_pert1(im, in_, a1, qv1, p1, r1, Array.get(F32, s1, im))

def run_rounds(+rem: Nat, +rd: U32, st: BicgSt) -> BicgSt:
  match rem:
    case 0n:
      st
    case 1n+q:
      BS{a, s, qv, p, r} = st
      s0 = zero_s(390n, 0, s)
      run_rounds(q, U32.inc(rd), rd_after(rd, bicg_i(410n, 0, BS{a, s0, qv, p, r})))

def hash_step(+acc: U32, r: Array<F32> & F32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, F32.bits(v)), 16777619)}

def hash_arr(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+q:
      HS{arr, +acc} = st
      hash_arr(q, U32.inc(idx), hash_step(acc, Array.get(F32, arr, idx)))

def finish_bicg(st: BicgSt) -> U32:
  BS{a1, s1, qv1, p1, r1} = st
  +acc1 = hash_arr(390n, 0, HS{s1, 2166136261})
  hash_arr(410n, 0, HS{qv1, acc1})

def main() -> U32:
  a = init_a_i(410n, 0, Array.new(F32, 18n, 0.0))
  p = init_p(390n, 0, Array.new(F32, 9n, 0.0))
  r = init_r(410n, 0, Array.new(F32, 9n, 0.0))
  s = Array.new(F32, 9n, 0.0)
  qv = Array.new(F32, 9n, 0.0)
  finish_bicg(run_rounds(40n, 0, BS{a, s, qv, p, r}))

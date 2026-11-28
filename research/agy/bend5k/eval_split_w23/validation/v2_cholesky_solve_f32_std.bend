import Base
# v2_cholesky_solve_f32 (std): Dense Cholesky LL^T factorization + triangular solves in F32
# Validation family 2: N = 32 SPD matrix, 110 solves (Newton-Raphson sqrt, bit-identical F32).

type CholSt is Type:
  CS{a: Array<F32>, l: Array<F32>, b: Array<F32>, x: Array<F32>, acc: U32}

type MatPair is Type:
  MP{a: Array<F32>, l: Array<F32>}

type DotRes is Type:
  DR{l: Array<F32>, sum: F32}

type SolDot is Type:
  SD{l: Array<F32>, x: Array<F32>, sum: F32}

type FwdSt is Type:
  FS{l: Array<F32>, b: Array<F32>, x: Array<F32>}

type ChkRes is Type:
  CR{x: Array<F32>, acc: U32}

def fl(+n: U32, +d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def nr_step(+rem: Nat, +x: F32, +y: F32, +half: F32) -> F32:
  match rem:
    case 0n:
      y
    case 1n+p:
      nr_step(p, x, F32.mul(half, F32.add(y, F32.div(x, y))), half)

def nr_sqrt(+x: F32) -> F32:
  +half = fl(1, 2)
  nr_step(6n, x, F32.add(F32.mul(x, half), half), half)

def abs_diff(gt: Bool, +i: U32, +j: U32) -> U32:
  match gt:
    case True{}:
      U32.sub(i, j)
    case False{}:
      U32.sub(j, i)

def entry_val(eq: Bool, +i: U32, +j: U32, +rd: U32, +shift: F32) -> F32:
  match eq:
    case True{}:
      F32.add(F32.add(F32.add(U32.to_f32(32), fl(4, 1)), shift), fl(U32.and(i, 7), 8))
    case False{}:
      +d = abs_diff(U32.is_gt(i, j), i, j)
      F32.add(fl(1, U32.add(d, 2)), fl(U32.and(U32.add(U32.add(i, j), rd), 7), 64))

def fill_row(+rem: Nat, +i: U32, +j: U32, +rd: U32, +shift: F32, +z: F32, mp: MatPair) -> MatPair:
  match rem:
    case 0n:
      mp
    case 1n+p:
      MP{a, l} = mp
      +idx = U32.add(U32.mul(i, 32), j)
      +v = entry_val(U32.is_eq(i, j), i, j, rd, shift)
      fill_row(p, i, U32.inc(j), rd, shift, z, MP{Array.set(F32, a, idx, v), Array.set(F32, l, idx, z)})

def pack_fill(b1: Array<F32>, x: Array<F32>, +acc: U32, mp: MatPair) -> CholSt:
  MP{a1, l1} = mp
  CS{a1, l1, b1, x, acc}

def fill_mat(+rem: Nat, +i: U32, +rd: U32, +shift: F32, +z: F32, st: CholSt) -> CholSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      CS{a, l, b, x, +acc} = st
      +bv = fl(U32.inc(U32.and(U32.add(U32.mul(i, 7), U32.mul(rd, 3)), 63)), 16)
      b1 = Array.set(F32, b, i, bv)
      st1 = pack_fill(b1, x, acc, fill_row(32n, i, 0, rd, shift, z, MP{a, l}))
      fill_mat(p, U32.inc(i), rd, shift, z, st1)

def dot_ljk(+lik: F32, +sum: F32, r: Array<F32> & F32) -> DotRes:
  (l, +ljk) = r
  DR{l, F32.sub(sum, F32.mul(lik, ljk))}

def dot_lik(+jbase: U32, +k: U32, +sum: F32, r: Array<F32> & F32) -> DotRes:
  (l, +lik) = r
  dot_ljk(lik, sum, Array.get(F32, l, U32.add(jbase, k)))

def chol_dot(+rem: Nat, +ibase: U32, +jbase: U32, +k: U32, dr: DotRes) -> DotRes:
  match rem:
    case 0n:
      dr
    case 1n+p:
      DR{l, +sum} = dr
      chol_dot(p, ibase, jbase, U32.inc(k), dot_lik(jbase, k, sum, Array.get(F32, l, U32.add(ibase, k))))

def chol_store_off(+idx: U32, +sum: F32, r: Array<F32> & F32) -> Array<F32>:
  (l, +ljj) = r
  Array.set(F32, l, idx, F32.div(sum, ljj))

def chol_store(eq: Bool, +idx: U32, +jdiag: U32, +sum: F32, l: Array<F32>) -> Array<F32>:
  match eq:
    case True{}:
      Array.set(F32, l, idx, nr_sqrt(sum))
    case False{}:
      chol_store_off(idx, sum, Array.get(F32, l, jdiag))

def chol_after_dot(+i: U32, +j: U32, +idx: U32, +jdiag: U32, a: Array<F32>, dr: DotRes) -> MatPair:
  DR{l1, +sum} = dr
  MP{a, chol_store(U32.is_eq(i, j), idx, jdiag, sum, l1)}

def chol_j_step(+i: U32, +j: U32, +ibase: U32, r: Array<F32> & F32, l: Array<F32>) -> MatPair:
  (a, +aij) = r
  +jbase = U32.mul(j, 32)
  +idx = U32.add(ibase, j)
  +jdiag = U32.add(jbase, j)
  chol_after_dot(i, j, idx, jdiag, a, chol_dot(U32.to_nat(j), ibase, jbase, 0, DR{l, aij}))

def chol_j_loop(+rem: Nat, +i: U32, +j: U32, +ibase: U32, mp: MatPair) -> MatPair:
  match rem:
    case 0n:
      mp
    case 1n+p:
      MP{a, l} = mp
      chol_j_loop(p, i, U32.inc(j), ibase, chol_j_step(i, j, ibase, Array.get(F32, a, U32.add(ibase, j)), l))

def chol_i_loop(+rem: Nat, +i: U32, mp: MatPair) -> MatPair:
  match rem:
    case 0n:
      mp
    case 1n+p:
      +ibase = U32.mul(i, 32)
      chol_i_loop(p, U32.inc(i), chol_j_loop(U32.to_nat(U32.inc(i)), i, 0, ibase, mp))

def fwd_xk(+lik: F32, +sum: F32, l: Array<F32>, r: Array<F32> & F32) -> SolDot:
  (x, +xk) = r
  SD{l, x, F32.sub(sum, F32.mul(lik, xk))}

def fwd_lik(+k: U32, +sum: F32, r: Array<F32> & F32, x: Array<F32>) -> SolDot:
  (l, +lik) = r
  fwd_xk(lik, sum, l, Array.get(F32, x, k))

def fwd_dot(+rem: Nat, +ibase: U32, +k: U32, sd: SolDot) -> SolDot:
  match rem:
    case 0n:
      sd
    case 1n+p:
      SD{l, x, +sum} = sd
      fwd_dot(p, ibase, U32.inc(k), fwd_lik(k, sum, Array.get(F32, l, U32.add(ibase, k)), x))

def fwd_div(+i: U32, +sum: F32, r: Array<F32> & F32, x: Array<F32>) -> MatPair:
  (l, +lii) = r
  MP{l, Array.set(F32, x, i, F32.div(sum, lii))}

def fwd_pack(b: Array<F32>, mp: MatPair) -> FwdSt:
  MP{l2, x2} = mp
  FS{l2, b, x2}

def fwd_after_dot(+i: U32, +idiag: U32, b: Array<F32>, sd: SolDot) -> FwdSt:
  SD{l1, x1, +sum} = sd
  fwd_pack(b, fwd_div(i, sum, Array.get(F32, l1, idiag), x1))

def fwd_step2(+i: U32, +ibase: U32, l: Array<F32>, rb: Array<F32> & F32, x: Array<F32>) -> FwdSt:
  (b, +bi) = rb
  fwd_after_dot(i, U32.add(ibase, i), b, fwd_dot(U32.to_nat(i), ibase, 0, SD{l, x, bi}))

def fwd_loop(+rem: Nat, +i: U32, fs: FwdSt) -> FwdSt:
  match rem:
    case 0n:
      fs
    case 1n+p:
      FS{l, b, x} = fs
      +ibase = U32.mul(i, 32)
      fwd_loop(p, U32.inc(i), fwd_step2(i, ibase, l, Array.get(F32, b, i), x))

def bwd_dot(+rem: Nat, +i: U32, +k: U32, sd: SolDot) -> SolDot:
  match rem:
    case 0n:
      sd
    case 1n+p:
      SD{l, x, +sum} = sd
      +idx = U32.add(U32.mul(k, 32), i)
      bwd_dot(p, i, U32.inc(k), fwd_lik(k, sum, Array.get(F32, l, idx), x))

def bwd_after_dot(+i: U32, sd: SolDot) -> MatPair:
  SD{l1, x1, +sum} = sd
  fwd_div(i, sum, Array.get(F32, l1, U32.add(U32.mul(i, 32), i)), x1)

def bwd_step(+i: U32, l: Array<F32>, rx: Array<F32> & F32) -> MatPair:
  (x, +xi) = rx
  +cnt = U32.sub(31, i)
  bwd_after_dot(i, bwd_dot(U32.to_nat(cnt), i, U32.inc(i), SD{l, x, xi}))

def bwd_loop(+rem: Nat, +rev: U32, mp: MatPair) -> MatPair:
  match rem:
    case 0n:
      mp
    case 1n+p:
      MP{l, x} = mp
      +i = U32.sub(31, rev)
      bwd_loop(p, U32.inc(rev), bwd_step(i, l, Array.get(F32, x, i)))

def chk_step(+acc: U32, r: Array<F32> & F32) -> ChkRes:
  (x, +xi) = r
  +q = F32.to_u32(F32.mul(F32.add(xi, U32.to_f32(16)), U32.to_f32(32768)))
  CR{x, U32.xor(U32.mul(acc, 16777619), q)}

def chk_loop(+rem: Nat, +i: U32, cr: ChkRes) -> ChkRes:
  match rem:
    case 0n:
      cr
    case 1n+p:
      CR{x, +acc} = cr
      chk_loop(p, U32.inc(i), chk_step(acc, Array.get(F32, x, i)))

def rd_after_chk(a1: Array<F32>, l3: Array<F32>, b1: Array<F32>, cr: ChkRes) -> CholSt:
  CR{x3, +acc1} = cr
  CS{a1, l3, b1, x3, acc1}

def rd_after_bwd(a1: Array<F32>, b1: Array<F32>, +acc0: U32, mp: MatPair) -> CholSt:
  MP{l3, x2} = mp
  rd_after_chk(a1, l3, b1, chk_loop(32n, 0, CR{x2, acc0}))

def rd_after_fwd(a1: Array<F32>, +acc0: U32, fs: FwdSt) -> CholSt:
  FS{l2, b1, x1} = fs
  rd_after_bwd(a1, b1, acc0, bwd_loop(32n, 0, MP{l2, x1}))

def rd_after_chol(b0: Array<F32>, x0: Array<F32>, +acc0: U32, mp: MatPair) -> CholSt:
  MP{a1, l1} = mp
  rd_after_fwd(a1, acc0, fwd_loop(32n, 0, FS{l1, b0, x0}))

def rd_after_fill(st: CholSt) -> CholSt:
  CS{a0, l0, b0, x0, +acc0} = st
  rd_after_chol(b0, x0, acc0, chol_i_loop(32n, 0, MP{a0, l0}))

def run_rounds(+rem: Nat, +rd: U32, +z: F32, st: CholSt) -> U32:
  match rem:
    case 0n:
      CS{a, l, b, x, +acc} = st
      acc
    case 1n+p:
      +shift = fl(U32.inc(U32.and(rd, 15)), 32)
      st1 = rd_after_fill(fill_mat(32n, 0, rd, shift, z, st))
      run_rounds(p, U32.inc(rd), z, st1)

def main() -> U32:
  +z = U32.to_f32(0)
  a = Array.new(F32, 10n, z)
  l = Array.new(F32, 10n, z)
  b = Array.new(F32, 5n, z)
  x = Array.new(F32, 5n, z)
  run_rounds(520n, 0, z, CS{a, l, b, x, 2166136261})

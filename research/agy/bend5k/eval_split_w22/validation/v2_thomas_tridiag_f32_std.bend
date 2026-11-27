import Base
# v2_thomas_tridiag_f32 (std): Tridiagonal Thomas Algorithm Solver in F32 (implicit 1D diffusion)
# Validation family 2: N = 2048 grid points, 520 implicit steps (forward elim + back subst).

type TriSt is Type:
  TS{a: Array<F32>, b: Array<F32>, c: Array<F32>, cp: Array<F32>, dp: Array<F32>}

type FwdSt is Type:
  FS{a: Array<F32>, b: Array<F32>, c: Array<F32>, cp: Array<F32>, dp: Array<F32>, pcp: F32, pdp: F32}

type BackSt is Type:
  BS{cp: Array<F32>, dp: Array<F32>, xn: F32}

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def sel_f32(cond: Bool, +t: F32, +f: F32) -> F32:
  match cond:
    case True{}:
      t
    case False{}:
      f

def init_arrs(+rem: Nat, +i: U32, +nlast: U32, +neg_a: F32, st: TriSt) -> TriSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      TS{a, b, c, cp, dp} = st
      +av = sel_f32(U32.is_zero(i), U32.to_f32(0), neg_a)
      +bv = F32.add(fl(3, 2), fl(U32.inc(U32.and(i, 7)), 64))
      +cv = sel_f32(U32.is_eq(i, nlast), U32.to_f32(0), neg_a)
      +dv = F32.sub(fl(U32.and(U32.mul(i, 17), 255), 256), fl(1, 2))
      init_arrs(p, U32.inc(i), nlast, neg_a, TS{
        Array.set(F32, a, i, av),
        Array.set(F32, b, i, bv),
        Array.set(F32, c, i, cv),
        cp,
        Array.set(F32, dp, i, dv)
      })

def fwd_step_d(
  +i: U32, +drive: F32, +ai: F32, +bi: F32, +ci: F32, +prev_cp: F32, +prev_dp: F32,
  a: Array<F32>, b: Array<F32>, c: Array<F32>, cp: Array<F32>, rdp: Array<F32> & F32
) -> FwdSt:
  (dp, +di) = rdp
  +denom = F32.sub(bi, F32.mul(ai, prev_cp))
  +ncp = F32.div(ci, denom)
  +ndp = F32.div(F32.sub(F32.add(di, drive), F32.mul(ai, prev_dp)), denom)
  FS{a, b, c, Array.set(F32, cp, i, ncp), Array.set(F32, dp, i, ndp), ncp, ndp}

def fwd_step_c(
  +i: U32, +drive: F32, +ai: F32, +bi: F32, +prev_cp: F32, +prev_dp: F32,
  a: Array<F32>, b: Array<F32>, rc: Array<F32> & F32, cp: Array<F32>, dp: Array<F32>
) -> FwdSt:
  (c, +ci) = rc
  fwd_step_d(i, drive, ai, bi, ci, prev_cp, prev_dp, a, b, c, cp, Array.get(F32, dp, i))

def fwd_step_b(
  +i: U32, +drive: F32, +ai: F32, +prev_cp: F32, +prev_dp: F32,
  a: Array<F32>, rb: Array<F32> & F32, c: Array<F32>, cp: Array<F32>, dp: Array<F32>
) -> FwdSt:
  (b, +bi) = rb
  fwd_step_c(i, drive, ai, bi, prev_cp, prev_dp, a, b, Array.get(F32, c, i), cp, dp)

def fwd_step_a(
  +i: U32, +drive: F32, +prev_cp: F32, +prev_dp: F32,
  ra: Array<F32> & F32, b: Array<F32>, c: Array<F32>, cp: Array<F32>, dp: Array<F32>
) -> FwdSt:
  (a, +ai) = ra
  fwd_step_b(i, drive, ai, prev_cp, prev_dp, a, Array.get(F32, b, i), c, cp, dp)

def fwd_loop(+rem: Nat, +i: U32, +drive: F32, fs: FwdSt) -> FwdSt:
  match rem:
    case 0n:
      fs
    case 1n+p:
      FS{a, b, c, cp, dp, +pcp, +pdp} = fs
      fwd_loop(p, U32.inc(i), drive, fwd_step_a(i, drive, pcp, pdp, Array.get(F32, a, i), b, c, cp, dp))

def fwd_start_d(
  +rem: Nat, +drive: F32, +b0: F32, +c0: F32,
  a: Array<F32>, b: Array<F32>, c: Array<F32>, cp: Array<F32>, rdp: Array<F32> & F32
) -> FwdSt:
  (dp, +d0) = rdp
  +pcp = F32.div(c0, b0)
  +pdp = F32.div(F32.add(d0, drive), b0)
  fwd_loop(rem, 1, drive, FS{a, b, c, Array.set(F32, cp, 0, pcp), Array.set(F32, dp, 0, pdp), pcp, pdp})

def fwd_start_c(
  +rem: Nat, +drive: F32, +b0: F32,
  a: Array<F32>, b: Array<F32>, rc: Array<F32> & F32, cp: Array<F32>, dp: Array<F32>
) -> FwdSt:
  (c, +c0) = rc
  fwd_start_d(rem, drive, b0, c0, a, b, c, cp, Array.get(F32, dp, 0))

def fwd_start_b(
  +rem: Nat, +drive: F32,
  a: Array<F32>, rb: Array<F32> & F32, c: Array<F32>, cp: Array<F32>, dp: Array<F32>
) -> FwdSt:
  (b, +b0) = rb
  fwd_start_c(rem, drive, b0, a, b, Array.get(F32, c, 0), cp, dp)

def back_step_d(+i: U32, +x_next: F32, +cpi: F32, cp: Array<F32>, rdp: Array<F32> & F32) -> BackSt:
  (dp, +dpi) = rdp
  +xi = F32.sub(dpi, F32.mul(cpi, x_next))
  BS{cp, Array.set(F32, dp, i, xi), xi}

def back_step_c(+i: U32, +x_next: F32, rcp: Array<F32> & F32, dp: Array<F32>) -> BackSt:
  (cp, +cpi) = rcp
  back_step_d(i, x_next, cpi, cp, Array.get(F32, dp, i))

def back_loop(+rem: Nat, +i: U32, bs: BackSt) -> BackSt:
  match rem:
    case 0n:
      bs
    case 1n+p:
      BS{cp, dp, +xn} = bs
      back_loop(p, U32.sub(i, 1), back_step_c(i, xn, Array.get(F32, cp, i), dp))

def do_step_fin(a1: Array<F32>, b1: Array<F32>, c1: Array<F32>, bs: BackSt) -> TriSt:
  BS{cp2, dp2, +x0} = bs
  TS{a1, b1, c1, cp2, dp2}

def do_step_back(+n1: Nat, +nlast2: U32, fs: FwdSt) -> TriSt:
  FS{a1, b1, c1, cp1, dp1, +pcp, +last_dp} = fs
  do_step_fin(a1, b1, c1, back_loop(n1, nlast2, BS{cp1, dp1, last_dp}))

def do_step(+n1: Nat, +nlast2: U32, +drive: F32, st: TriSt) -> TriSt:
  TS{a, b, c, cp, dp} = st
  do_step_back(n1, nlast2, fwd_start_b(n1, drive, a, Array.get(F32, b, 0), c, cp, dp))

def run_steps(+rem: Nat, +step: U32, st: TriSt) -> Array<F32>:
  match rem:
    case 0n:
      TS{a, b, c, cp, dp} = st
      dp
    case 1n+p:
      +drive = F32.sub(fl(U32.inc(U32.and(step, 7)), 64), fl(1, 16))
      run_steps(p, U32.inc(step), do_step(2047n, 2046, drive, st))

def checksum(+rem: Nat, +i: U32, +h: U32, r: Array<F32> & F32) -> U32:
  match rem:
    case 0n:
      (a, v) = r
      h
    case 1n+p:
      (a, +v) = r
      +q = F32.to_u32(F32.mul(F32.add(v, U32.to_f32(16)), U32.to_f32(65536)))
      checksum(p, U32.inc(i), U32.xor(U32.mul(h, 2654435761), q), Array.get(F32, a, U32.inc(i)))

def main() -> U32:
  +z = U32.to_f32(0)
  +neg_a = F32.sub(z, fl(1, 4))
  st1 = init_arrs(2048n, 0, 2047, neg_a, TS{
    Array.new(F32, 11n, z),
    Array.new(F32, 11n, z),
    Array.new(F32, 11n, z),
    Array.new(F32, 11n, z),
    Array.new(F32, 11n, z)
  })
  res = run_steps(1500n, 0, st1)
  checksum(2048n, 0, 2166136261, Array.get(F32, res, 0))

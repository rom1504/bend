import Base
# t2_radix2_fft_f32 (std): Iterative Cooley-Tukey Radix-2 DIT FFT in F32
# Sealed-Test family 2: N = 512 (9 butterfly stages), 220 frames with bit-reversal & twiddles.

type FftSt is Type:
  FS{re: Array<F32>, im: Array<F32>, twr: Array<F32>, twi: Array<F32>}

type PairF is Type:
  PF{a: Array<F32>, b: Array<F32>}

type ChkSt is Type:
  CS{re: Array<F32>, im: Array<F32>, h: U32}

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def poly_cos(+x: F32) -> F32:
  +z = U32.to_f32(0)
  +x2 = F32.mul(x, x)
  +t3 = F32.sub(z, fl(1, 720))
  +t2 = F32.add(fl(1, 24), F32.mul(x2, t3))
  +t1 = F32.add(F32.sub(z, fl(1, 2)), F32.mul(x2, t2))
  F32.add(fl(1, 1), F32.mul(x2, t1))

def poly_sin(+x: F32) -> F32:
  +z = U32.to_f32(0)
  +x2 = F32.mul(x, x)
  +t3 = F32.sub(z, fl(1, 5040))
  +t2 = F32.add(fl(1, 120), F32.mul(x2, t3))
  +t1 = F32.add(F32.sub(z, fl(1, 6)), F32.mul(x2, t2))
  F32.mul(x, F32.add(fl(1, 1), F32.mul(x2, t1)))

def bitrev_go(+rem: Nat, +x: U32, +r: U32) -> U32:
  match rem:
    case 0n:
      r
    case 1n+p:
      bitrev_go(p, U32.shrn(x, 1n), U32.or(U32.shln(r, 1n), U32.and(x, 1)))

def init_tw_branch(
  lt: Bool, +k: U32, +qtr: U32, +hpi: F32, twr: Array<F32>, twi: Array<F32>
) -> PairF:
  match lt:
    case True{}:
      +z = U32.to_f32(0)
      +t = F32.div(F32.mul(hpi, U32.to_f32(k)), U32.to_f32(qtr))
      PF{Array.set(F32, twr, k, poly_cos(t)), Array.set(F32, twi, k, F32.sub(z, poly_sin(t)))}
    case False{}:
      +z = U32.to_f32(0)
      +t = F32.div(F32.mul(hpi, U32.to_f32(U32.sub(k, qtr))), U32.to_f32(qtr))
      PF{Array.set(F32, twr, k, F32.sub(z, poly_sin(t))), Array.set(F32, twi, k, F32.sub(z, poly_cos(t)))}

def init_tw(+rem: Nat, +k: U32, +qtr: U32, +hpi: F32, pf: PairF) -> PairF:
  match rem:
    case 0n:
      pf
    case 1n+p:
      PF{twr, twi} = pf
      init_tw(p, U32.inc(k), qtr, hpi, init_tw_branch(U32.is_lt(k, qtr), k, qtr, hpi, twr, twi))

def init_sig(+rem: Nat, +i: U32, re: Array<F32>, im: Array<F32>) -> PairF:
  match rem:
    case 0n:
      PF{re, im}
    case 1n+p:
      +vr = F32.sub(fl(U32.and(U32.add(U32.mul(i, 13), 7), 255), 256), fl(1, 2))
      +vi = F32.sub(fl(U32.and(U32.add(U32.mul(i, 29), 3), 255), 256), fl(1, 2))
      init_sig(p, U32.inc(i), Array.set(F32, re, i, vr), Array.set(F32, im, i, vi))

def swap_pair_j(+i: U32, +j: U32, +vi: F32, rj: Array<F32> & F32) -> Array<F32>:
  (a, +vj) = rj
  Array.set(F32, Array.set(F32, a, i, vj), j, vi)

def swap_pair(+i: U32, +j: U32, ri: Array<F32> & F32) -> Array<F32>:
  (a, +vi) = ri
  swap_pair_j(i, j, vi, Array.get(F32, a, j))

def bitrev_swap(lt: Bool, +i: U32, +j: U32, re: Array<F32>, im: Array<F32>) -> PairF:
  match lt:
    case True{}:
      PF{swap_pair(i, j, Array.get(F32, re, i)), swap_pair(i, j, Array.get(F32, im, i))}
    case False{}:
      PF{re, im}

def bitrev_perm(+rem: Nat, +i: U32, pf: PairF) -> PairF:
  match rem:
    case 0n:
      pf
    case 1n+p:
      PF{re, im} = pf
      +j = bitrev_go(9n, i, 0)
      bitrev_perm(p, U32.inc(i), bitrev_swap(U32.is_lt(i, j), i, j, re, im))

def bfly_ui(
  +u: U32, +v: U32, +tr: F32, +ti: F32, +ur: F32,
  re: Array<F32>, rim: Array<F32> & F32, twr: Array<F32>, twi: Array<F32>
) -> FftSt:
  (im, +ui) = rim
  re1 = Array.set(F32, Array.set(F32, re, u, F32.add(ur, tr)), v, F32.sub(ur, tr))
  im1 = Array.set(F32, Array.set(F32, im, u, F32.add(ui, ti)), v, F32.sub(ui, ti))
  FS{re1, im1, twr, twi}

def bfly_ur(
  +u: U32, +v: U32, +tr: F32, +ti: F32,
  rre: Array<F32> & F32, im: Array<F32>, twr: Array<F32>, twi: Array<F32>
) -> FftSt:
  (re, +ur) = rre
  bfly_ui(u, v, tr, ti, ur, re, Array.get(F32, im, u), twr, twi)

def bfly_vi(
  +u: U32, +v: U32, +wr: F32, +wi: F32, +vr: F32,
  re: Array<F32>, rim: Array<F32> & F32, twr: Array<F32>, twi: Array<F32>
) -> FftSt:
  (im, +vi) = rim
  +tr = F32.sub(F32.mul(wr, vr), F32.mul(wi, vi))
  +ti = F32.add(F32.mul(wr, vi), F32.mul(wi, vr))
  bfly_ur(u, v, tr, ti, Array.get(F32, re, u), im, twr, twi)

def bfly_vr(
  +u: U32, +v: U32, +wr: F32, +wi: F32,
  rre: Array<F32> & F32, im: Array<F32>, twr: Array<F32>, twi: Array<F32>
) -> FftSt:
  (re, +vr) = rre
  bfly_vi(u, v, wr, wi, vr, re, Array.get(F32, im, v), twr, twi)

def bfly_wi(
  +u: U32, +v: U32, +wr: F32,
  re: Array<F32>, im: Array<F32>, twr: Array<F32>, rtwi: Array<F32> & F32
) -> FftSt:
  (twi, +wi) = rtwi
  bfly_vr(u, v, wr, wi, Array.get(F32, re, v), im, twr, twi)

def bfly_wr(
  +u: U32, +v: U32, +tidx: U32,
  re: Array<F32>, im: Array<F32>, rtwr: Array<F32> & F32, twi: Array<F32>
) -> FftSt:
  (twr, +wr) = rtwr
  bfly_wi(u, v, wr, re, im, twr, Array.get(F32, twi, tidx))

def run_bfly(+rem: Nat, +base: U32, +k: U32, +half: U32, +tw_stride: U32, st: FftSt) -> FftSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      FS{re, im, twr, twi} = st
      +u = U32.add(base, k)
      +v = U32.add(u, half)
      +tidx = U32.mul(k, tw_stride)
      st1 = bfly_wr(u, v, tidx, re, im, Array.get(F32, twr, tidx), twi)
      run_bfly(p, base, U32.inc(k), half, tw_stride, st1)

def run_groups(+rem: Nat, +base: U32, +half: U32, +step: U32, +tw_stride: U32, +half_n: Nat, st: FftSt) -> FftSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      st1 = run_bfly(half_n, base, 0, half, tw_stride, st)
      run_groups(p, U32.add(base, step), half, step, tw_stride, half_n, st1)

def run_stages(+rem: Nat, +s: Nat, st: FftSt) -> FftSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      +half = U32.shln(1, s)
      +step = U32.shln(half, 1n)
      +tw_stride = U32.shrn(512, 1n+s)
      +n_groups = U32.to_nat(tw_stride)
      +half_n = U32.to_nat(half)
      st1 = run_groups(n_groups, 0, half, step, tw_stride, half_n, st)
      run_stages(p, 1n+s, st1)

def norm_im(+i: U32, +inv_s: F32, +drive: F32, re: Array<F32>, rim: Array<F32> & F32) -> PairF:
  (im, +vi) = rim
  PF{re, Array.set(F32, im, i, F32.sub(F32.mul(vi, inv_s), drive))}

def norm_re(+i: U32, +inv_s: F32, +drive: F32, rre: Array<F32> & F32, im: Array<F32>) -> PairF:
  (re, +vr) = rre
  norm_im(i, inv_s, drive, Array.set(F32, re, i, F32.add(F32.mul(vr, inv_s), drive)), Array.get(F32, im, i))

def norm_loop(+rem: Nat, +i: U32, +inv_s: F32, +drive: F32, pf: PairF) -> PairF:
  match rem:
    case 0n:
      pf
    case 1n+p:
      PF{re, im} = pf
      norm_loop(p, U32.inc(i), inv_s, drive, norm_re(i, inv_s, drive, Array.get(F32, re, i), im))

def frame_after_norm(twr: Array<F32>, twi: Array<F32>, pf: PairF) -> FftSt:
  PF{re2, im2} = pf
  FS{re2, im2, twr, twi}

def frame_after_stages(+inv_s: F32, +drive: F32, st: FftSt) -> FftSt:
  FS{re1, im1, twr1, twi1} = st
  frame_after_norm(twr1, twi1, norm_loop(512n, 0, inv_s, drive, PF{re1, im1}))

def frame_after_bitrev(+inv_s: F32, +drive: F32, twr: Array<F32>, twi: Array<F32>, pf: PairF) -> FftSt:
  PF{re0, im0} = pf
  frame_after_stages(inv_s, drive, run_stages(9n, 0n, FS{re0, im0, twr, twi}))

def run_frames(+rem: Nat, +f: U32, +inv_s: F32, st: FftSt) -> PairF:
  match rem:
    case 0n:
      FS{re, im, twr, twi} = st
      PF{re, im}
    case 1n+p:
      FS{re, im, twr, twi} = st
      +drive = F32.sub(fl(U32.inc(U32.and(f, 7)), 64), fl(1, 16))
      run_frames(p, U32.inc(f), inv_s, frame_after_bitrev(inv_s, drive, twr, twi, bitrev_perm(512n, 0, PF{re, im})))

def chk_im(+h1: U32, re: Array<F32>, rim: Array<F32> & F32) -> ChkSt:
  (im, +vi) = rim
  +qi = F32.to_u32(F32.mul(F32.add(vi, U32.to_f32(32)), U32.to_f32(32768)))
  +h2 = U32.xor(U32.mul(h1, 16777619), qi)
  CS{re, im, h2}

def chk_re(+i: U32, +h: U32, rre: Array<F32> & F32, im: Array<F32>) -> ChkSt:
  (re, +vr) = rre
  +qr = F32.to_u32(F32.mul(F32.add(vr, U32.to_f32(32)), U32.to_f32(32768)))
  +h1 = U32.xor(U32.mul(h, 2654435761), qr)
  chk_im(h1, re, Array.get(F32, im, i))

def checksum(+rem: Nat, +i: U32, cs: ChkSt) -> U32:
  match rem:
    case 0n:
      CS{re, im, +h} = cs
      h
    case 1n+p:
      CS{re, im, +h} = cs
      checksum(p, U32.inc(i), chk_re(i, h, Array.get(F32, re, i), im))

def main_chk(pf: PairF) -> U32:
  PF{re1, im1} = pf
  checksum(512n, 0, CS{re1, im1, 2166136261})

def main_run(twr: Array<F32>, twi: Array<F32>, sig: PairF) -> U32:
  PF{re0, im0} = sig
  main_chk(run_frames(440n, 0, fl(1, 24), FS{re0, im0, twr, twi}))

def main_sig(+z: F32, tw: PairF) -> U32:
  PF{twr, twi} = tw
  main_run(twr, twi, init_sig(512n, 0, Array.new(F32, 9n, z), Array.new(F32, 9n, z)))

def main() -> U32:
  +z = U32.to_f32(0)
  main_sig(z, init_tw(256n, 0, 128, fl(1570796, 1000000), PF{Array.new(F32, 8n, z), Array.new(F32, 8n, z)}))

import Base
# v2_fir_filter_f32 (std): 1D FIR digital signal convolution over Array<F32>
# Validation family 2: N = 2048 signal, K = 32 taps, 280 passes.

type TapSt is Type:
  TSt{sig: Array<F32>, kern: Array<F32>, acc: F32}

type FirAll is Type:
  FAll{sig: Array<F32>, kern: Array<F32>, out: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def init_sig(+n: Nat, +i: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), 17)), 255)
      +v = F32.sub(fl(q, 256), fl(1, 2))
      init_sig(p, U32.inc(i), Array.swap(F32, a, i, v))

def init_kern(+n: Nat, +i: U32, +klen: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), 91)), 63)
      +v = F32.mul(F32.sub(fl(q, 64), fl(1, 2)), fl(1, klen))
      init_kern(p, U32.inc(i), klen, Array.swap(F32, a, i, v))

def tap_step.s2(+acc: F32, +sv: F32, sig: Array<F32>, rk: Array<F32> & F32) -> TapSt:
  (kern, +kv) = rk
  TSt{sig, kern, F32.add(acc, F32.mul(sv, kv))}

def tap_step.s1(+k: U32, +acc: F32, rs: Array<F32> & F32, kern: Array<F32>) -> TapSt:
  (sig, +sv) = rs
  tap_step.s2(acc, sv, sig, Array.get(F32, kern, k))

def fir_taps(+rem: Nat, +i: U32, +k: U32, +mask: U32, st: TapSt) -> TapSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      TSt{sig, kern, +acc} = st
      +idx = U32.and(U32.add(i, k), mask)
      fir_taps(p, i, U32.inc(k), mask, tap_step.s1(k, acc, Array.get(F32, sig, idx), kern))

def store_sample(+i: U32, out: Array<F32>, st: TapSt) -> FirAll:
  TSt{sig1, kern1, +acc} = st
  +nv = F32.add(F32.mul(acc, fl(7, 8)), fl(1, 16))
  FAll{sig1, kern1, Array.set(F32, out, i, nv)}

def fir_pass(+rem: Nat, +i: U32, +ktaps: Nat, +mask: U32, fa: FirAll) -> FirAll:
  match rem:
    case 0n:
      fa
    case 1n+p:
      FAll{sig, kern, out} = fa
      fir_pass(p, U32.inc(i), ktaps, mask,
               store_sample(i, out, fir_taps(ktaps, i, 0, mask, TSt{sig, kern, U32.to_f32(0)})))

def swap_io(fa: FirAll) -> FirAll:
  FAll{sig, kern, out} = fa
  FAll{out, kern, sig}

def run_iters(+iters: Nat, +nlen: Nat, +ktaps: Nat, +mask: U32, fa: FirAll) -> Array<F32>:
  match iters:
    case 0n:
      FAll{sig, kern, out} = fa
      sig
    case 1n+p:
      run_iters(p, nlen, ktaps, mask, swap_io(fir_pass(nlen, 0, ktaps, mask, fa)))

def checksum(+n: Nat, +i: U32, +h: U32, r: Array<F32> & F32) -> U32:
  match n:
    case 0n:
      (a, v) = r
      h
    case 1n+p:
      (a, +v) = r
      +q = F32.to_u32(F32.mul(F32.add(v, U32.to_f32(16)), U32.to_f32(65536)))
      checksum(p, U32.inc(i), U32.xor(U32.mul(h, 2654435761), q), Array.get(F32, a, U32.inc(i)))

def main() -> U32:
  sig = init_sig(2048n, 0, (Array.new(F32, 11n, U32.to_f32(0)), U32.to_f32(0)))
  kern = init_kern(32n, 0, 32, (Array.new(F32, 5n, U32.to_f32(0)), U32.to_f32(0)))
  out = Array.new(F32, 11n, U32.to_f32(0))
  res = run_iters(280n, 2048n, 32n, 2047, FAll{sig, kern, out})
  checksum(2048n, 0, 2166136261, Array.get(F32, res, 0))

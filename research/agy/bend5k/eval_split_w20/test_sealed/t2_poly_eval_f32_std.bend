import Base
# t2_poly_eval_f32 (std): Degree-7 Horner polynomial + 4-step Newton-Raphson sweep over Array<F32>
# Sealed-Test family 2: N = 16384 points in [0.5, 2.5), 480 sweeps.

type SweepPair is Type:
  SPair{xs: Array<F32>, out: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def init_xs(+n: Nat, +i: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), 29)), 1023)
      +v = F32.add(fl(q, 512), fl(1, 2))
      init_xs(p, U32.inc(i), Array.swap(F32, a, i, v))

def newton_step(+x: F32, +bias: F32) -> F32:
  +p1 = F32.add(F32.mul(fl(1, 64), x), fl(1, 256))
  +p2 = F32.add(F32.mul(p1, x), fl(1, 16))
  +p3 = F32.add(F32.mul(p2, x), fl(1, 128))
  +p4 = F32.add(F32.mul(p3, x), fl(1, 4))
  +p5 = F32.add(F32.mul(p4, x), fl(1, 16))
  +p6 = F32.add(F32.mul(p5, x), fl(4, 1))
  +p = F32.sub(F32.mul(p6, x), bias)
  +d1 = F32.add(F32.mul(fl(7, 64), x), fl(6, 256))
  +d2 = F32.add(F32.mul(d1, x), fl(5, 16))
  +d3 = F32.add(F32.mul(d2, x), fl(4, 128))
  +d4 = F32.add(F32.mul(d3, x), fl(3, 4))
  +d5 = F32.add(F32.mul(d4, x), fl(2, 16))
  +dp = F32.add(F32.mul(d5, x), fl(4, 1))
  F32.sub(x, F32.div(p, dp))

def sweep_step(+i: U32, +bias: F32, rx: Array<F32> & F32, out: Array<F32>) -> SweepPair:
  (xs, +x0) = rx
  +x1 = newton_step(x0, bias)
  +x2 = newton_step(x1, bias)
  +x3 = newton_step(x2, bias)
  +x4 = newton_step(x3, bias)
  +nv = F32.add(F32.mul(x4, fl(1, 2)), fl(1, 4))
  SPair{xs, Array.set(F32, out, i, nv)}

def sweep_arr(+rem: Nat, +i: U32, +bias: F32, sp: SweepPair) -> SweepPair:
  match rem:
    case 0n:
      sp
    case 1n+p:
      SPair{xs, out} = sp
      sweep_arr(p, U32.inc(i), bias, sweep_step(i, bias, Array.get(F32, xs, i), out))

def swap_pair(sp: SweepPair) -> SweepPair:
  SPair{xs, out} = sp
  SPair{out, xs}

def run_sweeps(+rem: Nat, +sw: U32, sp: SweepPair) -> Array<F32>:
  match rem:
    case 0n:
      SPair{xs, out} = sp
      xs
    case 1n+p:
      +bias = fl(U32.inc(U32.and(sw, 15)), 16)
      run_sweeps(p, U32.inc(sw), swap_pair(sweep_arr(16384n, 0, bias, sp)))

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
  xs = init_xs(16384n, 0, (Array.new(F32, 14n, U32.to_f32(0)), U32.to_f32(0)))
  out = Array.new(F32, 14n, U32.to_f32(0))
  res = run_sweeps(120n, 0, SPair{xs, out})
  checksum(16384n, 0, 2166136261, Array.get(F32, res, 0))

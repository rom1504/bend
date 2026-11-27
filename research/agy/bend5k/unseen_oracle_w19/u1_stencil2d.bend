import Base
# u1_stencil2d: 2D 5-point heat-diffusion Jacobi stencil over Array<F32>
# Unseen benchmark testing 2D indexing, FP arithmetic, and dual-array hoisting.
# Grid: 64x64 (4096 F32 cells), Dirichlet boundary = 0.0, STEPS = 2000 ping-pong sweeps.

type GridPair is Type:
  GPair{a: Array<F32>, b: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def b2u(b: Bool) -> U32:
  match b:
    case False{}:
      0
    case True{}:
      1

def init_val.go(z: Bool, +i: U32) -> F32:
  match z:
    case True{}:
      U32.to_f32(0)
    case False{}:
      fl(U32.and(prng(U32.add(U32.mul(i, 2654435761), 17)), 1023), 1024)

def init_val(inside: U32, +i: U32) -> F32:
  init_val.go(U32.is_zero(inside), i)

def init_grid.go(+n: Nat, +i: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +x = U32.and(i, 63)
      +y = U32.shrn(i, 6n)
      +interior = U32.and(U32.and(b2u(U32.is_gt(x, 0)), b2u(U32.is_lt(x, 63))),
                          U32.and(b2u(U32.is_gt(y, 0)), b2u(U32.is_lt(y, 63))))
      +v = init_val(interior, i)
      init_grid.go(p, U32.inc(i), Array.swap(F32, a, i, v))

def stencil_cell.s5(+i: U32, c: F32, l: F32, ri: F32, u: F32,
                    r: Array<F32> & F32, dst: Array<F32>) -> GridPair:
  (src, d) = r
  +nv = F32.add(F32.mul(fl(1, 2), c),
                F32.mul(fl(1, 8), F32.add(F32.add(l, ri), F32.add(u, d))))
  GPair{src, Array.set(F32, dst, i, nv)}

def stencil_cell.s4(+i: U32, c: F32, l: F32, ri: F32,
                    r: Array<F32> & F32, dst: Array<F32>) -> GridPair:
  (src, u) = r
  stencil_cell.s5(i, c, l, ri, u, Array.get(F32, src, U32.add(i, 64)), dst)

def stencil_cell.s3(+i: U32, c: F32, l: F32,
                    r: Array<F32> & F32, dst: Array<F32>) -> GridPair:
  (src, ri) = r
  stencil_cell.s4(i, c, l, ri, Array.get(F32, src, U32.sub(i, 64)), dst)

def stencil_cell.s2(+i: U32, c: F32,
                    r: Array<F32> & F32, dst: Array<F32>) -> GridPair:
  (src, l) = r
  stencil_cell.s3(i, c, l, Array.get(F32, src, U32.inc(i)), dst)

def stencil_cell.s1(+i: U32, r: Array<F32> & F32, dst: Array<F32>) -> GridPair:
  (src, c) = r
  stencil_cell.s2(i, c, Array.get(F32, src, U32.sub(i, 1)), dst)

def stencil_row(+nx: Nat, +i: U32, gp: GridPair) -> GridPair:
  match nx:
    case 0n:
      gp
    case 1n+p:
      GPair{src, dst} = gp
      stencil_row(p, U32.inc(i), stencil_cell.s1(i, Array.get(F32, src, i), dst))

def stencil_rows(+ny: Nat, +row_base: U32, gp: GridPair) -> GridPair:
  match ny:
    case 0n:
      gp
    case 1n+p:
      stencil_rows(p, U32.add(row_base, 64), stencil_row(62n, U32.inc(row_base), gp))

def swap_gp(gp: GridPair) -> GridPair:
  GPair{a, b} = gp
  GPair{b, a}

def run_steps(+steps: Nat, gp: GridPair) -> Array<F32>:
  match steps:
    case 0n:
      GPair{src, dst} = gp
      src
    case 1n+p:
      run_steps(p, swap_gp(stencil_rows(62n, 64, gp)))

def checksum(+n: Nat, +i: U32, +h: U32, r: Array<F32> & F32) -> U32:
  match n:
    case 0n:
      (a, v) = r
      h
    case 1n+p:
      (a, v) = r
      +q = F32.to_u32(F32.mul(v, U32.to_f32(65536)))
      +nh = U32.xor(U32.mul(h, 2654435761), q)
      checksum(p, U32.inc(i), nh, Array.get(F32, a, U32.inc(i)))

def main() -> U32:
  src = init_grid.go(4096n, 0, (Array.new(F32, 12n, U32.to_f32(0)), U32.to_f32(0)))
  dst = Array.new(F32, 12n, U32.to_f32(0))
  res = run_steps(4000n, GPair{src, dst})
  checksum(4096n, 0, 2166136261, Array.get(F32, res, 0))
